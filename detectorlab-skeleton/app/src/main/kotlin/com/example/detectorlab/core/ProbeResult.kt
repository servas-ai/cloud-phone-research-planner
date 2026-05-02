package com.example.detectorlab.core

/**
 * Result of one Probe execution. Maps 1:1 to JSON-Schema-v1
 * (see docs/probe-schema.md).
 *
 * Score semantics:
 *   0.00 - 0.05  Not detected (real device)
 *   0.05 - 0.30  Suspicion, not certain
 *   0.30 - 0.70  Detectable with confidence
 *   0.70 - 1.00  Certainly detected
 */
data class ProbeResult(
    val score: Double,                  // 0.0 .. 1.0, clamped
    val confidence: Double,             // 0.0 .. 1.0, statistical confidence
    val evidence: List<Evidence>,       // ordered, may be empty
    val method: String,                 // human-readable methodology
    val runtimeMs: Long,                // measured wall-clock duration
    val failed: Boolean = false,        // true iff probe could not execute
    val failureReason: String? = null,  // present iff failed=true
) {
    init {
        require(score in 0.0..1.0) { "score out of range: $score" }
        require(confidence in 0.0..1.0) { "confidence out of range: $confidence" }
        require(runtimeMs >= 0) { "runtimeMs must be non-negative: $runtimeMs" }
        require(failed == (failureReason != null)) { "failed-flag and failureReason must agree" }
    }

    companion object {
        fun failed(reason: String, runtimeMs: Long = 0L): ProbeResult = ProbeResult(
            score = 0.0,
            confidence = 0.0,
            evidence = emptyList(),
            method = "(failed)",
            runtimeMs = runtimeMs,
            failed = true,
            failureReason = reason,
        )
    }
}

/**
 * Evidence is a single observation that contributed to the probe's score.
 * Type is intentionally permissive (String | Number | Boolean) to fit JSON-Schema.
 */
data class Evidence(
    val key: String,
    val value: Any,                     // String, Number, or Boolean
    val expected: Any? = null,          // null = no a-priori expectation
)
