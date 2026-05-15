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
    fun querySettingSecure(key: String): String?
    fun queryTelephonyManager(field: TelephonyField): String?
    fun queryPackageManager(): PackageManagerView
    fun querySensorManager(): SensorManagerView
}

/**
 * Shell access is INTENTIONALLY NOT in the base ProbeContext.
 *
 * Round-2.5 Finding F36 (architecture-strategist) + F34 (security-auditor):
 * `runShellCommand(cmd: String)` was a leaky capability that punted security
 * policy to each probe author. The fix is to require shell-using probes to
 * declare a separate capability surface via `ShellProbeContext` with an
 * explicit static-string allowlist enforced by ProbeRunner.
 *
 * Specific probes that require shell (Probe #3 root.su_search, Probe #14
 * root.selinux) opt in by accepting `ShellProbeContext` instead of
 * `ProbeContext`. The allowlist is reviewed at PR time, not at runtime.
 */
interface ShellProbeContext : ProbeContext {
    /** Run a SHELL COMMAND from the static allowlist. Throws if cmd not in allowlist. */
    fun runAllowlistedCommand(cmdId: AllowlistedCommand, timeoutMs: Long = 1000L): ShellResult
}

/** The complete set of permitted shell invocations. Add via PR review only. */
enum class AllowlistedCommand {
    GETPROP_ALL,            // `getprop` — full property dump
    LS_SU_PATHS,            // `ls /sbin/su /system/bin/su /system/xbin/su` (presence check only)
    GETENFORCE,             // `getenforce` — SELinux mode
    UNAME_R,                // `uname -r` — kernel version
    CAT_PROC_VERSION,       // `cat /proc/version` — kernel build banner
    CAT_PROC_CPUINFO,       // `cat /proc/cpuinfo` — CPU architecture probe
    DUMPSYS_BATTERY,        // `dumpsys battery` — battery state probe
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
