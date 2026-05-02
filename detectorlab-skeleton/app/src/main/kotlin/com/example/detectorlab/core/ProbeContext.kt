package com.example.detectorlab.core

/**
 * Probe-side abstraction over android.content.Context that lets unit tests
 * provide a fake ProbeContext without instantiating the Android framework.
 *
 * Production impl wraps android.content.Context.
 * Test impl provides controlled fakes.
 */
interface ProbeContext {
    fun getSystemProperty(key: String): String?
    fun fileExists(path: String): Boolean
    fun readFile(path: String, maxBytes: Int = 8192): String?
    fun runShellCommand(cmd: String, timeoutMs: Long = 1000L): ShellResult
    fun querySettingSecure(key: String): String?
    fun queryTelephonyManager(field: TelephonyField): String?
    fun queryPackageManager(): PackageManagerView
    fun querySensorManager(): SensorManagerView
}

data class ShellResult(val exitCode: Int, val stdout: String, val stderr: String)

enum class TelephonyField { IMEI, SERIAL, OPERATOR_NAME, MCC_MNC, SIM_SERIAL }

interface PackageManagerView {
    fun isPackageInstalled(packageName: String): Boolean
    fun listInstalledPackages(): List<String>
}

interface SensorManagerView {
    fun listSensorTypes(): List<Int>
    fun sampleSensor(sensorType: Int, durationMs: Long): SensorSample
}

data class SensorSample(val timestamps: LongArray, val values: Array<FloatArray>)
