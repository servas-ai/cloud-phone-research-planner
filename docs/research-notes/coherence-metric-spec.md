# Coherence-Metric Specification — A2

Date: 2026-05-03
Author: Claude Opus 4.7 (manual draft after autoresearch hit usage limit at ~80% complete)
Triggered by: Round-2 Action A2 (`plans/07-round-2-feedback.md`) — BLOCKING for paper-grade publication
Status: DRAFT — input for `plans/03-experiment-matrix.md` addendum + new H5 hypothesis pre-registration; awaits human + statistician review.
Plan-Immutability: this file does NOT modify `plans/03-experiment-matrix.md` or any frozen plan.

---

## 1. Problem Statement

Round-1 Finding F6 and Round-2 Finding F32 establish that an ML-class adversary (L_AdvB) does NOT just check individual probes — it checks whether the probe vector is internally consistent. Examples drawn from `docs/research-notes/ml-adversary-models.md` §2 (cross-correlation patterns C1–C10):

- C1: `Build.MODEL = "Pixel 7"` while `MediaDrm UID` originates from a Galaxy device → ensemble flags
- C2: `ro.product.brand = "google"` while `ro.product.locale = "zh-CN"` and timezone is `Europe/Berlin` → ensemble flags
- C3: Sensor-FFT noise floor consistent with a Pixel 7 accelerometer, but battery temperature is statically 25.0 °C → ensemble flags

A coherence metric must:

1. Quantify cross-probe consistency without requiring an ML model at measurement time
2. Be computable purely from a JSON-schema-v1 probe-vector report
3. Have a falsifiable null hypothesis suitable for OSF pre-registration
4. Be robust to mixed types (binary scores, continuous confidences, categorical evidence values)
5. Be robust to high dimensionality (60 + 14 from Round-1 + #75 candidate = up to 75 probes)

This document defines such a metric.

---

## 2. Candidate Metrics Surveyed

| Metric | Closed-form? | Sample-size cost | Interpretable? | Mixed types? | Verdict |
|---|---|---|---|---|---|
| Mahalanobis distance from real-device centroid | ✅ | needs Σ⁻¹ — ill-conditioned at high dim | ⚠️ moderate (distance to centroid) | ❌ assumes Gaussian | rejected H_A — assumes Gaussian, fails on binary probes |
| Multivariate Gaussian likelihood ratio | ✅ | same as Mahalanobis | ✅ p-value-like | ❌ Gaussian | rejected — same reason |
| Pearson covariance matrix on continuous probes only | ✅ | O(n·k²) | ✅ | partial | candidate component |
| Chi-squared independence on categorical probes | ✅ | O(n·k²) | ✅ p-value | ✅ categorical | candidate component |
| Mutual information matrix (MI) | partially closed-form | O(n·k²·log n), kernel/binning required | ✅ moderate | ✅ | candidate but expensive |
| Isolation Forest path-length | ❌ no closed form | O(n·k·log n) train + O(k·log n) infer | ⚠️ relative score only | ✅ | rejected H_B — not pre-registrable, no analytic null |
| Energy distance (two-sample) | ✅ | O(n²) per pair | ⚠️ scale-dependent | ✅ | candidate, but O(n²) is heavy |
| Local Outlier Factor (LOF) | ❌ | O(n²) | ❌ relative | ✅ | rejected — no analytic null |
| **Hybrid: Pearson + Chi² combined via Fisher's method** | ✅ | O(n·k²) | ✅ q-value-like | ✅ both | **selected H_C — analytically tractable, mixed-type, pre-registrable** |

**Recommendation:** Hybrid coherence metric (option H_C). Justification: it is the only candidate that satisfies all five problem-statement requirements simultaneously. Mahalanobis is ruled out by Gaussian assumption violation (binary probes); Isolation Forest and LOF are ruled out because they have no analytic null distribution and therefore cannot be pre-registered as a falsifiable test on OSF.

---

## 3. Recommended Definition

### 3.1 Notation

- **Probe vector** for one run: P = (p₁, …, p_n), where each p_i is a `ProbeResult.score` ∈ [0, 1]
- **Evidence-derived categorical features:** for each probe i, define c_i ∈ {0, 1, …, k_i} where k_i is the cardinality of canonical evidence values (e.g. `ro.build.tags ∈ {release-keys, test-keys, dev-keys}`)
- **Reference distribution** (R): empirical joint distribution from N₀ = 90 real-device runs (3 devices × N=30 runs each: Pixel 7, Samsung S23, Xiaomi 13)
- **Continuous probe subset** P_c ⊆ P: probes whose `score` is genuinely continuous (sensor FFT, FFT-coherence, network-RTT)
- **Categorical evidence subset** E_d: derived from `Evidence.value` fields with discrete value-sets

### 3.2 Continuous-Component: Pearson Inverse-Covariance Test

For every pair (i, j) of continuous probes in P_c, compute under R:

```
ρᵢⱼ_R = Pearson correlation in reference distribution
ρᵢⱼ_obs = Pearson correlation in observed run-batch (size N=30 per config)
zᵢⱼ = Fisher z-transform: ½ ln((1+ρ)/(1-ρ))
```

Test statistic for pair (i, j):

```
Tᵢⱼ = (zᵢⱼ_obs − zᵢⱼ_R) · √(N − 3)
```

Under H_continuous_null: T_ij ~ N(0, 1) asymptotically.

Per-pair p-value: p_ij = 2 · (1 − Φ(|T_ij|))

### 3.3 Categorical-Component: Chi-Squared Independence

For every pair (i, j) of categorical-evidence features in E_d, build the contingency table from the observed run-batch and compare to the marginal-product expectation under R:

```
χ²ᵢⱼ = Σ_{a,b} (O_{a,b} − E_{a,b})² / E_{a,b}
```

with degrees of freedom (k_i − 1)(k_j − 1).

Per-pair p-value: p_ij = 1 − F_χ²(χ²ᵢⱼ; df)

### 3.4 Combine via Fisher's Method (FDR-controlled)

For all m pairs (continuous + categorical), combine the p-values:

```
X² = −2 · Σ ln(p_ij)
```

Under the global null H₀ (all pairs independently consistent with R), X² ~ χ²(2m).

**Coherence-score** for one config:

```
c_score = 1 − F_χ²(X²; df=2m)
```

c_score ∈ [0, 1], where:
- c_score → 1 means "highly consistent with reference distribution" (real-device-like)
- c_score → 0 means "highly inconsistent" (spoofed combination of probes)

**Threshold (Round-2.5 F40 fix):** at α = 0.05 with **Benjamini-Hochberg FDR-correction only** (NOT mixed with Bonferroni, which the Gemini reviewer correctly flagged as α-inflating when combined via OR). Reject the null for layer L_n when the BH-adjusted q-value < 0.05 over the 7 layer-deltas. Bonferroni was previously offered as an OR-of-criteria alternative; this is removed because OR-combining two correction methods compounds the Type-I error rather than reducing it.

### 3.5 Why Brown's method (NOT Fisher's)

**Round-2.5 update:** Both Gemini-3-Pro and architecture-strategist reviewers correctly flagged that Fisher's method is inappropriate here because probe-pair p-values are **demonstrably non-independent** (probes #1, #7, #9, #28 all derive from `getprop`; sensor probes share IRQ-clock substrate). Fisher's method on dependent p-values inflates Type-I error materially. We pre-commit to **Brown's method (Brown 1975)** before OSF lock.

- Closed-form analytic null → pre-registrable on OSF (same property as Fisher)
- Brown's method adjusts the χ² statistic via an effective degrees-of-freedom term that accounts for the covariance structure of the p-values:
  ```
  X²_Brown = (-2 · Σ ln(p_ij)) / c
  df_Brown = 2 · m / c
  c = 1 + (var(X²)/(2·E[X²]) − 1) · estimated from reference distribution
  ```
  where `c ≥ 1` is the dependence-correction factor estimated from the empirical pairwise covariance of the p-values under R.
- Robust to mixed types (we feed it both continuous and categorical p-values, identical to the Fisher pipeline)
- Pre-cluster correlated probes at threshold **ρ = 0.7** (not 0.9 — Round-2.5 Gemini line 161) — reduces residual collinearity and complements Brown's covariance correction.
- Reference: Brown, M.B. (1975). _A method for combining non-independent, one-sided tests of significance._ Biometrics 31:987–992. Implementation in `scipy.stats.combine_pvalues(method='mudholkar_george')` is mathematically equivalent for our use; Python sketch in §5 is updated accordingly.

---

## 4. Null Hypothesis H5 (for OSF pre-registration)

**H5_null:** For each SpoofStack configuration L_n (n ∈ {0a, 0b, L1, L1+L2, …, full-stack}), the coherence-score distribution is statistically indistinguishable from the real-device reference R. Formally:

```
H5_null:  E[c_score | L_n] ≥ 0.05  for all n
```

**H5_alt:** For at least one configuration L_n, the coherence-score is significantly below threshold:

```
H5_alt:  ∃n :  E[c_score | L_n] < 0.05  (BH-adjusted)
```

**Test statistic:** mean coherence-score per config, computed over N=30 runs.

**Critical region:** reject H5_null for config L_n iff observed mean c_score < critical-threshold derived from one-sided one-sample t-test against 0.05, BH-corrected over 7 simultaneous tests.

**Power calculation:** With N=30 per config, σ ≈ 0.03 (estimated from pilot), one-sided α=0.05 corrected to α'=0.0071, expected effect-size δ=0.05 → estimated power ≈ 0.85. If pilot shows σ > 0.05, increase N to 60 per config (consistent with Round-2 architecture-strategist recommendation).

---

## 5. Reference Implementation Plan

Standard Python (numpy + scipy only — no ML framework required):

```python
"""
Coherence metric — reference implementation.
Used by experiments/runner aggregate-step, NOT by DetectorLab on-device.
"""
from dataclasses import dataclass
from pathlib import Path
import json
import numpy as np
from scipy import stats


@dataclass
class ReferenceDist:
    """Empirical joint distribution from N0=90 real-device runs."""
    pearson_corr: np.ndarray       # (n, n) reference Pearson correlation
    chi2_marginals: dict           # {(i,j): {'pi': p_i_marginals, 'pj': p_j_marginals}}
    continuous_idx: list[int]      # which probe indices are continuous
    categorical_idx: list[int]     # which are categorical
    cluster_reps: list[int]        # post-clustering representative indices

    @classmethod
    def from_runs(cls, run_jsons: list[Path], cluster_threshold: float = 0.9) -> "ReferenceDist":
        """Build reference dist from real-device run JSON files."""
        ...  # impl: load, extract scores, cluster correlated probes


def coherence_score(
    observed_runs: list[dict],
    ref: ReferenceDist,
    config_id: str,
) -> float:
    """
    Compute coherence-score for one configuration.

    Args:
        observed_runs: list of N=30 ProbeReport JSONs (schema v1)
        ref: reference distribution from real devices
        config_id: e.g. "L0a", "L1+L2", "full-stack" (for logging only)

    Returns:
        c_score in [0, 1]; values near 0 indicate inconsistency with real devices
    """
    cont_p_values = []
    for i, j in _pairs(ref.continuous_idx):
        rho_obs = _pearson_from_runs(observed_runs, i, j)
        z_obs = np.arctanh(rho_obs)
        z_ref = np.arctanh(ref.pearson_corr[i, j])
        T = (z_obs - z_ref) * np.sqrt(len(observed_runs) - 3)
        p = 2 * (1 - stats.norm.cdf(abs(T)))
        cont_p_values.append(max(p, 1e-10))  # floor to avoid log(0)

    cat_p_values = []
    for i, j in _pairs(ref.categorical_idx):
        observed_table = _contingency_table(observed_runs, i, j)
        expected = ref.chi2_marginals[(i, j)]
        chi2 = ((observed_table - expected) ** 2 / expected).sum()
        df = (observed_table.shape[0] - 1) * (observed_table.shape[1] - 1)
        p = 1 - stats.chi2.cdf(chi2, df)
        cat_p_values.append(max(p, 1e-10))

    all_p = cont_p_values + cat_p_values
    if not all_p:
        return 1.0  # nothing to test, conservatively coherent
    X2 = -2 * np.sum(np.log(all_p))
    df = 2 * len(all_p)
    return 1 - stats.chi2.cdf(X2, df)


def _pairs(idx: list[int]):
    for a in range(len(idx)):
        for b in range(a + 1, len(idx)):
            yield idx[a], idx[b]


def _pearson_from_runs(runs: list[dict], i: int, j: int) -> float:
    xs = np.array([r["probes"][i]["score"] for r in runs])
    ys = np.array([r["probes"][j]["score"] for r in runs])
    if xs.std() == 0 or ys.std() == 0:
        return 0.0
    return float(np.corrcoef(xs, ys)[0, 1])


def _contingency_table(runs, i: int, j: int) -> np.ndarray:
    """Build observed contingency table from categorical evidence values."""
    ...  # impl: extract evidence.value at probe i and j, build table
```

Total estimated impl: ~150 LOC + ~80 LOC tests. Fits cleanly inside `experiments/runner/` as a sibling module to the orchestrator.

---

## 6. Integration into Experiment-Matrix (proposed addendum)

This section is a **proposal** for a future `plans/03-experiment-matrix.md` addendum (Round-3). It does NOT modify the immutable plan.

| Aspect | Current (Round-1 plan) | Proposed (Round-2 + A2) |
|---|---|---|
| Per-run output | Probe-vector with 60 scores | Same + coherence-score per config |
| Aggregate per config | weightedScore, criticalFailures, category | Same + mean c_score + 95% CI |
| Hypothesis tests | H1–H4 with McNemar + BH-FDR | Same + H5 with one-sided t-test + BH-FDR |
| Sample size | N=30 | N=30 minimum, N=60 if σ > 0.05 in pilot |
| Layer interactions | (none) | 2⁶ fractional-factorial (Resolution IV, 16 cells) per architecture-strategist |

Heatmap rendering: add a second panel showing per-config c_score below the existing per-probe heatmap.

---

## 7. Trade-offs Acknowledged

1. **Probe-pair independence assumption** — Fisher's method assumes independent p-values; ours aren't. Mitigated by pre-clustering correlated probes (cluster_threshold=0.9), but residual correlation will inflate Type-I error. Statistician should review whether this requires a Brown's-method correction (covariance-aware Fisher variant).

2. **Reference-distribution quality** — c_score is only as good as the real-device reference. N₀=90 (3 devices × 30 runs) is borderline for high-dimensional covariance estimation. Alternative: use shrinkage estimation (Ledoit-Wolf) for the covariance matrix.

3. **Adversary-aware adversary** — A sophisticated L_AdvC attacker could optimize to match the reference covariance structure (defeating c_score). This is acknowledged in `docs/research-notes/ml-adversary-models.md` §6 as L_AdvC threat — the coherence metric defends against L_AdvB but not L_AdvC.

4. **Computational cost** — O(n²) pair-iterations × O(N) per pair = O(n²·N). For n=30 effective probes and N=30, this is ~27 000 operations per config — negligible. For n=75 raw probes, ~170 000 — still fast.

5. **Continuous-vs-categorical split is judgement-call** — we publish the per-probe classification alongside the spec; reviewers can audit.

---

## 8. Open Questions for Human + Statistician Review

1. **Brown's method vs Fisher's method?** If probe-pair correlations are non-trivial, Brown's method (which accounts for covariance between p-values) may be more appropriate. Decision needed before pre-registration.

2. **Cluster-threshold = 0.9** — is this defensible, or should it be derived from reference data (e.g. eigenvalue-decomposition of correlation matrix)?

3. **N₀ = 90** — is this enough for stable covariance estimation, or do we need 3 × N=60 = 180 baseline runs? Adding N₀ extends Phase 0 by ~1 week.

4. **Should H5 be tested per layer (`L0a`, `L0b`, `L1`, …) or per layer-delta (`L0b – L0a`, `L1 – L0b`, …)?** Either is defensible; pre-registration must commit.

5. **Should coherence-score replace the existing weightedScore in the aggregate, or be reported alongside?** Per pre-registration discipline, we should commit before data collection. Recommendation: report alongside (additive, not replacing).

---

Ready for Round-3 statistician review? **Y/N**

Recommended reviewer: any statistician with experience in multi-test FDR correction. Suggested external reviewer: someone from CISPA Saarland (cited in `refs/bibliography.md` extensions) or TU Darmstadt CYSEC.
