package com.example.detectorlab.probes.env

import com.example.detectorlab.core.PackageManagerView
import com.example.detectorlab.core.ProbeContext
import com.example.detectorlab.core.SensorManagerView
import com.example.detectorlab.core.SensorSample
import com.example.detectorlab.core.TelephonyField
import com.example.detectorlab.core.TimeView
import kotlinx.coroutines.runBlocking
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/**
 * Unit tests for TimeSpoofingProbe (env.time_spoofing, A17 N4).
 *
 * Each delta pair (D1–D4) is exercised in isolation with all other sources
 * clean, verifying correct threshold crossings and score values.
 */
class TimeSpoofingProbeTest {

    private val probe = TimeSpoofingProbe()

    // Base epoch used across tests — any realistic Unix timestamp.
    private val base = 1_700_000_000_000L

    // ── helpers ──────────────────────────────────────────────────────────────

    private fun fakeCtx(
        wallMs: Long      = base,
        elapsedMs: Long   = base,          // normally ≈ wallMs for a clean device
        gpsMs: Long?      = base,
        ntpMs: Long?      = base,
        thresholdsJson: String? = null,    // raw JSON for assets/baselines/time-thresholds.json
    ): ProbeContext = object : ProbeContext {
        override fun getSystemProperty(key: String): String? = null
        override fun fileExists(path: String) = thresholdsJson != null &&
            path == TimeSpoofingProbe.THRESHOLDS_ASSET
        override fun readFile(path: String, maxBytes: Int): String? =
            if (path == TimeSpoofingProbe.THRESHOLDS_ASSET) thresholdsJson else null
        override fun querySettingSecure(key: String): String? = null
        override fun queryTelephonyManager(field: TelephonyField): String? = null
        override fun querySensorManager(): SensorManagerView = object : SensorManagerView {
            override fun listSensorTypes() = emptyList<Int>()
            override fun sampleSensor(sensorType: Int, durationMs: Long) =
                SensorSample(LongArray(0), emptyArray())
        }
        override fun queryPackageManager(): PackageManagerView = object : PackageManagerView {
            override fun isPackageInstalled(packageName: String) = false
            override fun listInstalledPackages() = emptyList<String>()
            override fun listPackagesWithPermission(permission: String) = emptyList<String>()
        }
        override fun queryTimeView(): TimeView = object : TimeView {
            override fun elapsedRealtimeMs(): Long = elapsedMs
            override fun wallClockMs(): Long = wallMs
            override fun gpsTimestampMs(): Long? = gpsMs
            override fun ntpTimestampMs(): Long? = ntpMs
        }
    }

    // ── clean device — no spoofing ────────────────────────────────────────────

    @Test
    fun `clean device — score is 0 when all sources agree`() = runBlocking {
        val result = probe.run(fakeCtx())
        assertFalse(result.failed)
        assertEquals(0.0, result.score)
        assertTrue(result.confidence >= 0.95)
    }

    // ── D1: wall vs elapsed ───────────────────────────────────────────────────

    @Test
    fun `D1 clean — no flag when delta is below threshold`() = runBlocking {
        val result = probe.run(fakeCtx(elapsedMs = base + 1_000L))
        assertFalse(result.failed)
        assertEquals(0.0, result.score)
    }

    @Test
    fun `D1 triggered — score is 0_55 when wall vs elapsed exceeds 30s`() = runBlocking {
        val result = probe.run(fakeCtx(elapsedMs = base + 40_000L))
        assertFalse(result.failed)
        assertEquals(0.55, result.score)
    }

    @Test
    fun `D1 evidence key present`() = runBlocking {
        val result = probe.run(fakeCtx(elapsedMs = base + 40_000L))
        assertTrue(result.evidence.any { it.key == "delta_wall_vs_elapsed_ms" })
    }

    // ── D2: wall vs GPS ───────────────────────────────────────────────────────

    @Test
    fun `D2 clean — no flag when wall and GPS agree within 10s`() = runBlocking {
        val result = probe.run(fakeCtx(gpsMs = base + 5_000L))
        assertFalse(result.failed)
        assertEquals(0.0, result.score)
    }

    @Test
    fun `D2 triggered — score is 0_75 when wall vs GPS exceeds 10s`() = runBlocking {
        val result = probe.run(fakeCtx(gpsMs = base + 15_000L))
        assertFalse(result.failed)
        assertEquals(0.75, result.score)
    }

    @Test
    fun `D2 skipped when GPS unavailable`() = runBlocking {
        val result = probe.run(fakeCtx(gpsMs = null))
        assertFalse(result.failed)
        assertTrue(result.evidence.any {
            it.key == "delta_wall_vs_gps_ms" && it.value.toString().contains("skipped")
        })
    }

    // ── D3: wall vs NTP ───────────────────────────────────────────────────────

    @Test
    fun `D3 clean — no flag when wall and NTP agree within 10s`() = runBlocking {
        val result = probe.run(fakeCtx(ntpMs = base + 5_000L))
        assertFalse(result.failed)
        assertEquals(0.0, result.score)
    }

    @Test
    fun `D3 triggered — score is 0_80 when wall vs NTP exceeds 10s`() = runBlocking {
        val result = probe.run(fakeCtx(ntpMs = base + 20_000L))
        assertFalse(result.failed)
        assertEquals(0.80, result.score)
    }

    @Test
    fun `D3 skipped when NTP unavailable`() = runBlocking {
        val result = probe.run(fakeCtx(ntpMs = null))
        assertFalse(result.failed)
        assertTrue(result.evidence.any {
            it.key == "delta_wall_vs_ntp_ms" && it.value.toString().contains("skipped")
        })
    }

    // ── D4: GPS vs NTP ────────────────────────────────────────────────────────

    @Test
    fun `D4 clean — no flag when GPS and NTP agree within 5s`() = runBlocking {
        val result = probe.run(fakeCtx(gpsMs = base + 1_000L, ntpMs = base + 3_000L))
        assertFalse(result.failed)
        assertEquals(0.0, result.score)
    }

    @Test
    fun `D4 triggered — score is 0_90 when GPS vs NTP exceeds 5s`() = runBlocking {
        val result = probe.run(fakeCtx(gpsMs = base, ntpMs = base + 8_000L))
        assertFalse(result.failed)
        assertEquals(0.90, result.score)
    }

    @Test
    fun `D4 skipped when GPS unavailable`() = runBlocking {
        val result = probe.run(fakeCtx(gpsMs = null, ntpMs = base))
        assertTrue(result.evidence.any {
            it.key == "delta_gps_vs_ntp_ms" && it.value.toString().contains("skipped")
        })
    }

    // ── Score priority — highest delta wins ───────────────────────────────────

    @Test
    fun `max score wins when multiple deltas triggered`() = runBlocking {
        // D1 (0.55) + D3 (0.80) both triggered; result should be 0.80
        val result = probe.run(fakeCtx(
            elapsedMs = base + 40_000L,   // D1 triggered
            ntpMs     = base + 20_000L,   // D3 triggered
        ))
        assertFalse(result.failed)
        assertEquals(0.80, result.score)
    }

    @Test
    fun `confidence is 0_95 when two or more deltas triggered`() = runBlocking {
        val result = probe.run(fakeCtx(
            elapsedMs = base + 40_000L,
            ntpMs     = base + 20_000L,
        ))
        assertEquals(0.95, result.confidence)
    }

    @Test
    fun `confidence is 0_80 when exactly one delta triggered`() = runBlocking {
        val result = probe.run(fakeCtx(ntpMs = base + 20_000L))
        assertEquals(0.80, result.confidence)
    }

    // ── Custom thresholds via asset JSON ─────────────────────────────────────

    @Test
    fun `custom threshold from asset overrides default`() = runBlocking {
        // Lower the wall_vs_ntp threshold to 2s; a 3s delta should now trigger.
        val json = """{"wall_vs_ntp_ms": 2000}"""
        val result = probe.run(fakeCtx(ntpMs = base + 3_000L, thresholdsJson = json))
        assertFalse(result.failed)
        assertEquals(0.80, result.score)
    }

    @Test
    fun `default threshold used when asset absent`() = runBlocking {
        // Default wall_vs_ntp is 10s; a 3s delta should NOT trigger.
        val result = probe.run(fakeCtx(ntpMs = base + 3_000L, thresholdsJson = null))
        assertFalse(result.failed)
        assertEquals(0.0, result.score)
    }

    // ── Probe metadata ────────────────────────────────────────────────────────

    @Test
    fun `probe id is env_time_spoofing`() {
        assertEquals("env.time_spoofing", probe.id)
    }

    @Test
    fun `probe rank is 4`() {
        assertEquals(4, probe.rank)
    }
}
