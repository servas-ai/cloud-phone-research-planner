# Addendum 10 — H6 Adversarial Detector↔Spoofer Co-Evolution

Date: 2026-05-14
Author: Claude Opus 4.7 (1M context), session driven by human partner
Triggered by: User-initiated methodological extension (not from F1–F41); related to F6 (`plans/05-validation-feedback.md` line 99) and H5 (`registration/osf-preregistration.md` §2) but goes beyond either
Status: DRAFT-REV-2 — Round-3 revisions + Polish-Pass-1 applied 2026-05-14; 3-reviewer sanity round complete (2 PASS, 1 NEEDS_REVISION-minor); awaiting statistician sign-off + human Y/N approval
Plan-Immutability: this file does NOT modify `plans/00–04`, does NOT modify `registration/osf-preregistration.md` until human approval; it PROPOSES amendments at end.

---

## 1. Summary

The existing plan (Round-2.5 PASS-pending-statistician) measures detection-resistance **statically**: 8 fixed SpoofStack configurations × N=60 trials × 75 probes → heatmap snapshot. This addendum proposes a complementary **dynamic** measurement: K iterations of an adversarial co-evolution loop where (a) DetectorLab proposes new probes/weightings derived from the previous iteration's gap, and (b) SpoofStack incorporates a pre-committed mitigation from a fixed mitigation-set. The hypothesis H6 asserts that this loop converges to a non-zero "irreducible detection floor" within bounded adversary **M** and detector **P ∪ P_ext** — i.e., a set of probes that no spoofing layer in the pre-committed mitigation-set can fully neutralize while coherence-detection still fires (`c_score < 0.05`, per `coherence-metric-spec.md` §3.4 where `c_score → 0` means INCONSISTENT / spoofed and `c_score → 1` means HIGHLY CONSISTENT / real-device-like).

H6 is the formalization of the user's "perfectes virtuelles Handy" vision as a falsifiable scientific claim: **a fully indistinguishable cloud phone provably does not exist within bounded adversary M and detector P ∪ P_ext, and we measure how close one can get.** This bounded-language formulation is locked for the abstract, introduction, and conclusion; the unqualified phrase "fully indistinguishable cloud phone provably does not exist" must NEVER appear without the "within bounded adversary M and detector P ∪ P_ext" qualifier.

---

## 2. Motivation and Scientific Gap

### 2.1 What the current plan measures

Per `plans/03-experiment-matrix.md` + `registration/osf-preregistration.md` §4:

- 8 monotone stack configurations (C0_real, C1_L0a, ..., C8_full)
- 16 fractional-factorial cells (Resolution IV) for layer-interaction
- N=60 trials per cell, McNemar paired tests, BH-FDR-q=0.05
- Statistical question: "Given fixed SpoofStack and fixed DetectorLab, what fraction of probes does each layer-config defeat?"

This is a **single-point measurement** in detector-spoofer game-space.

### 2.2 What H6 measures additionally

The same SpoofStack at iteration k+1 is informed by which probes DetectorLab successfully exploited at iteration k. Conversely, DetectorLab at iteration k+1 may be augmented from a pre-committed probe-extension set with probes derived from coherence-metric failures observed at iteration k.

This is **the equilibrium gap of the iterated detector-spoofer game**, not a snapshot.

**Game-theoretic framing:** H6 is a finite-horizon (K=4) sequential Stackelberg game with pre-committed strategy sets M (spoofer) and P ∪ P_ext (detector). The detector moves first each iteration (selects p_ext); the spoofer responds (selects m). This framing follows Madry et al., "Towards Deep Learning Models Resistant to Adversarial Attacks", ICLR 2018, for bounded adversaries with pre-committed move-sets. Stackelberg is chosen over Nash/fictitious-play because the loop is strictly sequential and the move-set is finite and pre-committed; we do not seek a mixed-strategy equilibrium, only the trajectory of pure-strategy best-responses along the greedy frontier.

### 2.3 Why this is novel

| Prior work | Measures | Gap |
|---|---|---|
| Salem 2017 (emulator vs phone ML) | Static classifier on one snapshot | No iteration |
| FAMOS USENIX'24 | Federated production model, no spoof-side | Defender-only |
| ATLAS arXiv 2509.20339 | Session-graph GNN, static labels | No co-evolution |
| Anti-Detect-Browser threads (Pixelscan, CreepJS, FingerprintJS-Pro) | Public adversarial co-evolution, but desktop-browser only, no academic publication, no pre-registration | Mobile cloud phones unstudied |
| Geelark / Multilogin Mobile (commercial) | Closed-source, no published methodology | Not reproducible, not peer-reviewed |
| Madry et al. ICLR 2018 ("Towards Deep Learning Models Resistant to Adversarial Attacks") | Bounded-adversary min-max framing for ML robustness | Image-classifier domain, not detector–spoofer Stackelberg game on Android container features |

To our knowledge, **no peer-reviewed, pre-registered, reproducible adversarial co-evolution study exists for ARM-native Android container detection.** This is the scientific contribution H6 enables.

---

## 3. Hypothesis H6 (proposed for OSF amendment)

### 3.1 Verbal statement

Under an iterative co-evolution loop bounded by pre-committed mitigation-set **M** (defined §4) and pre-committed probe-extension-set **P_ext** (defined §5), executed for **K=4** rounds (justified §7):

**H6_alt:** ALL of the following hold jointly at iteration K:
1. The detection-rate trajectory converges to a non-zero floor δ\* > 0.05;
2. At convergence ≥ 3 probes remain individually detectable (per-probe mean μ_i^(K) > 0.20 over N=60);
3. Coherence-detection still fires, i.e. `c_score^(K) < 0.05` (per `coherence-metric-spec.md` §3.4: `c_score → 0` = INCONSISTENT/spoofed, `c_score → 1` = HIGHLY CONSISTENT/real-device-like — so a small c_score means the coherence detector has NOT been defeated);
4. Convergence is observed: |D^(K) − D^(K−1)| < 0.05 AND |D^(K−1) − D^(K−2)| < 0.05.

**H6_null:** The literal complement of H6_alt — i.e., NOT (δ* > 0.05 AND irreducible-count ≥ 3 AND c_score^(K) < 0.05 AND |D^(K) − D^(K−1)| < 0.05 AND |D^(K−1) − D^(K−2)| < 0.05).

H6_null is partitioned into five named sub-cases. The branches are **jointly exhaustive but NOT mutually exclusive** (two failure modes can co-occur — e.g. branch (a) perfect-spoof while branch (d) coherence-not-broken). **Pre-committed reporting precedence (F-H6-rev-001 resolution):** when multiple branches fire, the primary headline branch is selected by the strict precedence order **e → b → a → c → d**. Rationale: noise/oscillation must dominate equilibrium claims (e, b come first); perfect-spoof (a) is the strongest scientific outcome among non-noise branches; partial outcomes (c, d) follow. Every branch that fires is ALSO reported in the appendix per-branch table; only the headline label uses the precedence.

- **(a) Perfect-spoof:** μ_i^(K) ≤ 0.20 for all probes (spoofer reached indistinguishability within M).
- **(b) Oscillation / limit-cycle:** |D^(k+1) − D^(k)| > 0.10 at some k ≥ 1 — game has no absorbing equilibrium under M.
- **(c) Partial-convergence with low irreducible-count:** convergence observed but Σ_i 1[μ_i^(K) > 0.20] < 3.
- **(d) Coherence-not-broken:** trajectory converges with sufficient irreducible probes but c_score^(K) ≥ 0.05 (detector lost the aggregate signal even though individual probes still fire).
- **(e) Trajectory-too-noisy / chaotic-attractor with sub-threshold amplitude:** within-iteration variance dominates the convergence signal; K=4 cannot distinguish a chaotic attractor with sub-threshold amplitude from a noisy absorbing state. Pre-commit: report trajectory-shape (monotone vs oscillating vs non-monotone) as a primary observation alongside the headline test.

**Convergence taxonomy.** We recognise three convergence modes — absorbing fixed-point, limit-cycle, and chaotic attractor — and we pre-commit that K=4 has limited power to distinguish (a chaotic attractor with sub-threshold amplitude can mimic an absorbing fixed-point). The trajectory-shape diagnostic in §3.3 step 5 is the primary tool for adjudicating this.

### 3.2 Why each branch of the null matters

Branch (a) would falsify the project's thesis that some detection vectors are fundamentally irreducible. Branch (b) would indicate the mitigation-set M is misspecified or the iteration protocol is unstable. Branches (c) and (d) are partial wins for either side and must be reported as such, not as failures. Branch (e) is the noise-floor honesty branch and is necessary for falsifiability.

### 3.3 Operationalization

```
For k in 0..K:
    1. Spoofer-side update at iteration k:
       - At k=0: SpoofStack = C8_full (per §4 baseline)
       - At k>0: SpoofStack = SpoofStack(k-1) ⊕ mitigation_m(k), where
         m(k) = argmax over m ∈ M of expected-detection-rate-reduction
         estimated from iteration k-1 per-probe means
       - The selection rule is pre-committed (greedy, see §4.3)
    2. Detector-side update at iteration k:
       - DetectorLab(k) = DetectorLab(k-1) ∪ p_ext(k), where
         p_ext(k) is selected from P_ext by pre-committed rule (§5.3)
    3. Trial run: N=60 trials of DetectorLab(k) against SpoofStack(k)
    4. Compute: per-probe means μ_i^(k), aggregate detection-rate D^(k),
                coherence c_score^(k)
    5. Convergence check (advisory, not stopping rule):
       |D^(k) - D^(k-1)| < 0.05 for two consecutive k AND k ≥ 2
       (locked value 0.05 per §6.3 / RDF13 — harmonized across §3.3, §3.4, §6.3, §10)

K is HARD-LOCKED at 4 (§7). No early stopping. No K extension.
```

### 3.4 Test statistic

Primary: per-probe mean detection-rate trajectory `μ_i^(0), μ_i^(1), ..., μ_i^(K)`.

H6_alt accepted iff ALL of the following hold:
- Σ_i 1[μ_i^(K) > 0.20] ≥ 3 (irreducible probe count)
- AND `c_score^(K) < 0.05` (coherence-detection fires; per `coherence-metric-spec.md` §3.4 a small c_score means the spoofer FAILED to match real-device coherence — the detector wins on aggregate too)
- AND |D^(K) − D^(K−1)| < 0.05 AND |D^(K−1) − D^(K−2)| < 0.05 (convergence observed, locked threshold 0.05 per §6.3 / RDF13)

H6_null accepted iff any of the above fails; the specific sub-case (a)–(e) per §3.1 must be reported.

### 3.5 Falsifiability

H6_alt is falsifiable by:
- Achieving μ_i^(K) ≤ 0.20 for ALL probes simultaneously (branch a — perfect spoof)
- Observing |D^(k+1) − D^(k)| > 0.10 at any k ≥ 1 (branch b — oscillation/limit-cycle)
- Σ_i 1[μ_i^(K) > 0.20] < 3 despite convergence (branch c — partial-convergence with low irreducible-count)
- `c_score^(K) ≥ 0.05` — coherence-detection does NOT fire at convergence (branch d — coherence is matched; spoofer beat the aggregate detector even though individual probes still fire)
- Trajectory-shape diagnostic indicates within-iteration variance dominates between-iteration variance (branch e — chaotic attractor / noise-dominated)

The trajectory test (§6.2) is a sequential two-sample proportion z-test (Fisher exact at small n) across k = 0..K; runs are NOT paired across iterations (each iteration draws N=60 independent runs from fresh container snapshots), so a paired McNemar would be invalid.

This is a strictly stronger and harder-to-fake hypothesis than H1–H5.

---

## 4. Pre-Committed Mitigation-Set M (locked before iteration k=0)

To prevent post-hoc creativity on the spoofer side (which would inflate apparent convergence), the spoofer's move at each iteration is restricted to a small, pre-committed set of mitigations drawn from existing SpoofStack layers L0a–L6 plus parameter sweeps WITHIN those layers — no new layer types, no third-party modules added mid-loop.

### 4.1 Mitigation-set composition (locked at OSF lock)

| ID | Mitigation | Layer | Parameter axis |
|---|---|---|---|
| M01 | Build-Property catalog rotation | L1 | Choose from {Pixel 7, S23, Xiaomi 13, OnePlus 11} fingerprint preset |
| M02 | MediaDrm UID family enforcement | L1 | Match L1 fingerprint's SoC family |
| M03 | Keybox rotation (within legally-cleared inventory) | L3 | Subject to F22 Legal-Gate sign-off; rotate among ≤3 cleared keyboxes |
| M04 | Sensor-trace replay quality (replay-source phone diversity) | L5 | 1 ↦ 3 ↦ 5 distinct source devices |
| M05 | LTE-egress ASN diversity | L6 | 1 ↦ 3 distinct mobile-carrier ASNs |
| M06 | DenyList expansion (DetectorLab fixture-coverage) | L4 | Coverage 70% ↦ 90% ↦ 99% of the DetectorLab-only DenyList fixture package set (no live third-party app names; lab-fixture packages only — see §9 Scope-Lock) |
| M07 | VBMeta-chain coherence (custom AVB tree) | L0b+ | Off ↦ On |
| M08 | /proc/version forge consistency (kernel string ↔ Build.FINGERPRINT) | L1+L4 | Off ↦ On |

**Mitigation-set size:** |M| = 8. No additions during the loop. New mitigations require an OSF amendment with timestamp; mid-loop additions invalidate the iteration and force re-baselining.

### 4.2 Mitigation eligibility per layer

A mitigation m ∈ M can only be applied if its underlying layer is already active in SpoofStack(k-1). If not, prerequisite layer is activated first, but this counts as one mitigation step.

### 4.3 Selection rule (greedy, pre-committed)

At iteration k, choose:

```
m(k) = argmax over m ∈ M \ applied(k-1) of
       Σ_i  μ_i_predicted^m
```

where μ_i_predicted^m is the **pre-registered prior** estimate of how much mitigation m **REDUCES** probe i's detection-rate from baseline (it is a predicted reduction, NOT a remaining detection-rate). Greedy therefore picks the mitigation with the LARGEST predicted aggregate reduction. Priors are LOW/MED/HIGH; numerically: 0.1 / 0.4 / 0.7 reduction respectively. Ties broken by ID order. Strict-positive rule: any mitigation row whose priors are all 0 (e.g. M03 with zero cleared keyboxes — see §9) is **deterministically skipped** by the argmax (since 0 < any positive prior).

Priors are derived from `docs/research-notes/ml-adversary-models.md` §6 (Layer × Adversary coverage table), per the derivation rule documented in §2 of `experiments/coevolution/mitigation_priors.csv`. The CSV is the canonical artifact. (Earlier draft cited a phantom "Table §6" inside this addendum — that cite is removed.)

This rule is mechanical — no human-in-the-loop deciding mid-iteration what to add. A pre-committed CSV `experiments/coevolution/mitigation_priors.csv` is locked before k=0 begins.

### 4.4 Why mitigation-set is small and prior-driven

A large or adaptive M would let the spoofer effectively trial-and-error its way to convergence, which is a different scientific claim (one about an unbounded adversary). Bounding M to 8 pre-committed moves keeps the question scientific ("what's the equilibrium gap of THIS bounded adversary?") rather than open-ended.

---

## 5. Pre-Committed Probe-Extension-Set P_ext (locked before iteration k=0)

Symmetric constraint on detector side: detector additions are also pre-committed, not adaptive.

### 5.1 Probe-extension-set composition

P_ext consists of 12 candidate probes drawn from the Round-1+2 inventory that are explicitly held OUT of the baseline N=60 trial at k=0, plus 4 newly-proposed probes from Round-2 F31 / F33 / F37.

| ID | Probe | Source | Why held out at k=0 |
|---|---|---|---|
| #75 | cpu_frequency_signature | F31 (Round-2) | Pilot-gated per F33 |
| #76 | sched_runtime_jitter | New (Round-3 candidate) | Tested only as P_ext member |
| #77 | binder_zombie_ratio | New | Tested only as P_ext |
| #78 | gpu_renderer_string_extended | F5 (#65 extension) | Held for P_ext |
| #79 | vbmeta_signature_chain | F5 (#69 extension) | Held for P_ext |
| #80 | thermal_curve_realism | F5 (#66 extension) | Held for P_ext |
| #81 | sensor_imu_eigen_spectrum | F5 (#24 extension) | Held for P_ext |
| #82 | tls_clienthello_jitter | F4 (#61 extension) | Held for P_ext |
| #83 | http2_settings_idle_pattern | F4 (#63 extension) | Held for P_ext |
| #84 | bluetooth_le_mac_pattern | New | Held for P_ext |
| #85 | usb_descriptor_realism | New | Held for P_ext |
| #86 | filesystem_journal_age | New | Held for P_ext |

|P_ext| = 12.

**Pre-committed feasibility gate for new probes.** Probes #76, #77, #84, #85, #86 are NEW (no Round-1 or Round-2 pilot). They must pass a 1-day pilot on C0_real (N=10) and C1_L0a (N=10), accepted iff within-config CV < 30% AND between-config **Cohen's d > 0.8** — **aligned with Probe #75 per `registration/osf-preregistration.md` §9 Amendment 2** (F-H6-rev-004 resolution: the earlier d > 0.5 was inconsistent with the pre-registered standard). Pilot data are go/no-go ONLY and NEVER enter the H6 trajectory. Probes that fail the gate are dropped from P_ext; |P_ext_active| = 12 − (number of failures). The gate runs BEFORE k=0; results are timestamped and locked in the OSF amendment.

**Probe #75 double-membership clarification (F-H6-rev-005).** Probe #75 appears in BOTH the baseline (per `probes/inventory.yml` after Round-2 F31 addition) AND in this §5.1 P_ext table. In `experiments/coevolution/mitigation_priors.csv` it appears as a SINGLE row (§5 of CSV). For BH-FDR family-size accounting (§6.2): #75 is treated as a member of the **baseline-60** at k=0 (passes its own F33 feasibility pilot at Phase 0); the 4 added probes from P_ext at k=1..4 are drawn from {#76, #77, #78, #79, #80, #81, #82, #83, #84, #85, #86} only — #75 is never "added" by the detector during co-evolution (it is always present). This preserves the 60 → 61 → 62 → 63 → 64 trajectory family sizes in §6.2 without off-by-one.

### 5.2 P_ext rationale

If the detector could pull arbitrary probes at iteration k, it could overfit to the spoofer's current state and create artificial detection. Holding P_ext small and pre-committed prevents this overfitting.

### 5.3 Detector-side selection rule (greedy, pre-committed)

At iteration k > 0, the detector adds the probe p\_ext(k) ∈ P_ext \ applied(k-1) that maximizes:

```
p_ext(k) = argmax over p ∈ P_ext \ applied(k-1) of
          ρ(p, spoofed-config-vector at k-1)
```

where ρ is the pre-registered prior expectation that this probe will detect deviation from the current SpoofStack(k-1) configuration. Priors come from the same `mitigation_priors.csv` (asymmetric: each (probe, mitigation) cell holds both reductions and detections).

### 5.4 K=4 ⇒ at most 4 mitigations applied AND at most 4 probes added

The loop terminates having applied 4 mitigations and added 4 probes from P_ext. The final detector has 64 probes (60 baseline + 4 from P_ext); the final spoofer has C8_full + 4 mitigations from M (still within M).

---

## 6. Statistical Methodology (extends `coherence-metric-spec.md` and `osf-preregistration.md` §5)

### 6.1 Sample-size per iteration

N=60 per iteration (same as baseline). Total: 5 × 60 = 300 valid runs for H6 (k=0..K=4). Plus reuse of k=0 data which coincides with C8_full (already in baseline) ⇒ marginal cost = 4 × 60 = 240 runs.

At ~5 minutes per run, **marginal cost = 20h orchestrator wall-clock ON TOP OF the 127h baseline** (`osf-preregistration.md` §7), for a total Phase 4 budget of approximately **147h**. The `ROADMAP.md` Gantt entry currently sized "exp ... 21d" must be extended by **+3 days**; the "stats" and "paper" blocks are unchanged. This Gantt update is bundled into PR-B per §11 (architecture artifacts), separately from the OSF amendment PR-A.

### 6.2 Trajectory test (primary)

**Sequential two-sample proportion z-test (Fisher exact at small n) across k=0..K=4, per probe.** Each iteration's N=60 runs are independent draws from fresh container snapshots; runs are **NOT paired** across iterations. A paired McNemar would be invalid here because (a) iteration k's 60 runs and iteration k+1's 60 runs are different containers, different snapshots, and different sample paths; and (b) the unit of analysis (a single detection-event from a fresh snapshot) has no across-iteration pairing identity. The corrected test is:

```
H_0^i,k:   p_detected^i,k = p_detected^i,k-1
H_a^i,k:   p_detected^i,k < p_detected^i,k-1  (one-sided, spoofer improving)
Test:      two-sample proportion z-test on (60, 60); Fisher exact if any cell count < 5
```

**Multiple-testing control: stratified BH-FDR at q=0.05, per transition.** At each k → k+1 transition, the test family is the (60 baseline probes + min(k, 4) P_ext probes) present at BOTH endpoints. Family sizes:

| Transition | Probes present at both endpoints | Family size |
|---|---:|---:|
| k = 0 → 1 | 60 baseline + 0 P_ext | 60 |
| k = 1 → 2 | 60 + 1 | 61 |
| k = 2 → 3 | 60 + 2 | 62 |
| k = 3 → 4 | 60 + 3 | 63 |
| **Total** |   | **246** |

P_ext probes at their FIRST appearance (no prior-iteration paired endpoint exists) are analyzed via a **separate appendix test** against the N₀=90 real-device reference, NOT trajectory-pairwise. This stratified design replaces the earlier erroneous "75 probes × 4 transitions = 300 tests" denominator.

### 6.3 Convergence test (primary)

Aggregate detection-rate D^(k) = mean over probes of per-probe detection-rate. Convergence is empirically observed iff:

|D^(K) - D^(K-1)| < 0.05 AND |D^(K-1) - D^(K-2)| < 0.05.

Non-convergence (oscillation) is the H6_null branch (b). It must be reported as such, NOT re-formulated mid-analysis.

### 6.4 Irreducible-probe count (secondary)

Σ_i 1[μ\_i^(K) > 0.20] = irreducible-probe count. Threshold 0.20 is pre-registered: above noise floor (per F13 line 188, 0.10/0.40 are pre-registered probe thresholds; 0.20 is midpoint between noise-floor and detection-decisive).

### 6.5 Coherence at convergence (secondary)

`c_score^(K)` is read from `coherence-metric-spec.md` §3.4 in its native sense: `c_score → 1` = HIGHLY CONSISTENT (real-device-like); `c_score → 0` = INCONSISTENT (spoofed). If `c_score^(K) < 0.05`, **coherence-detection still fires** at convergence — the spoofer has NOT closed the cross-probe coherence gap even after K mitigations, and the detector wins on aggregate signal as well as on the irreducible probes. This is the strongest form of H6_alt. Conversely, `c_score^(K) ≥ 0.05` means coherence is matched (H6_null branch d).

### 6.6 Sensitivity analysis

Re-run analysis under three perturbations:
- Probe threshold 0.15, 0.20 (locked), 0.25
- Convergence threshold 0.03, 0.05 (locked), 0.07
- BH-FDR-q = 0.025, 0.05 (locked), 0.10

**Sensitivity analyses are APPENDIX-ONLY.** Primary inference cites only the locked values (probe threshold 0.20, convergence threshold 0.05, BH-FDR q=0.05). Sensitivity rows MUST NOT appear in the abstract, introduction, conclusion, or any headline figure. This restriction is pre-committed and binds the writing pipeline at the OSF amendment timestamp; reopening locked thresholds via sensitivity-band rhetoric is explicitly disallowed.

### 6.7 Cross-test consistency with H5 (Brown's method reconciliation)

H5's coherence test (per `coherence-metric-spec.md` §3.5) uses **Brown's method** to combine non-independent probe-level p-values into the c_score, because the coherence test deliberately operates on a JOINT distribution of correlated probes within a single snapshot. H6's trajectory test (§6.2) tests **independent two-sample proportions across iterations** — different N=60 samples, fresh container snapshots, no within-snapshot correlation entering the iteration-pairwise comparison — so the independence assumption of plain BH-FDR holds within each transition family. H5 and H6 are pre-registered as DIFFERENT hypothesis families; their multiple-testing corrections are computed **within each family**, never pooled. There is no statistical contradiction: Brown's vs BH-FDR is the right method for each family respectively, given their different dependence structures.

---

## 7. Why K=4 (and why not K=∞)

| K | Pro | Con |
|---|---|---|
| 2 | Cheapest (1 transition) | Too short to observe convergence trajectory |
| 3 | Convergence-observable iff trajectory monotone | Marginal |
| **4** | **Sufficient to detect convergence (2 consecutive flat transitions) AND budget-tractable (~20h orchestrator)** | Compromise |
| 6 | Stronger convergence claim | Doubles budget; 8 of 8 mitigations applied = M exhausted ⇒ no degrees-of-freedom test, just enumeration |
| ∞ | Theoretically asymptotic | Computationally infeasible; mitigation-set exhausted at K=8 anyway |

**K=4 hard-locked.** This is a researcher-degree-of-freedom (§11 below).

Note that with K=4 and |M|=8, half of the mitigation-set is left unapplied. This is a feature: it preserves a falsification path (the unapplied mitigations could close the remaining gap, but they didn't get applied because the greedy rule never selected them — meaning their prior reduction was lower than alternatives).

---

## 8. Threats to Validity

| Threat | Mitigation |
|---|---|
| **Overfitting to DetectorLab** | Held-out probes in P_ext NOT used to select mitigations; only used to detect at iteration k. Spoofer doesn't see them at all. |
| **Mitigation-set bias** | M derived from Round-1+2 literature (`ml-adversary-models.md`); reviewed by Round-3 panel; size locked. |
| **Greedy selection is local optimum** | Acknowledged. The trajectory is exploratory along the greedy frontier, not globally optimal. Paper must state this. |
| **Iteration dependence (k+1 reuses k state)** | Runs at iteration k are independent (snapshot-restore per run). Cross-iteration dependence is methodological, not statistical. |
| **Drift in keybox availability mid-loop** | F22 Legal-Gate must clear ≥3 keyboxes before k=0. If a keybox revokes mid-loop, iteration is paused (per `osf-preregistration.md` §8 stop condition). |
| **Real-world detectors are not DetectorLab** | Acknowledged. The paper claims convergence to floor against DetectorLab, NOT against arbitrary commercial detectors. External validity is a known limitation. |
| **HARKing risk** | Mitigated by locking M, P_ext, K, thresholds, selection rules, priors CSV BEFORE k=0. OSF amendment timestamps the lock. |
| **Regression-to-the-mean (RTM)** | Apparent convergence at K=4 could be RTM mimicking equilibrium when between-iteration variance is sampling-noise-dominated. Mitigation: pre-committed between-iteration variance diagnostic — compare Var(D^(0..K)) trajectory against within-iteration bootstrap CI width. If trajectory variance ≤ 1.5 × within-iteration variance, the "convergence" claim is downgraded to "consistent with noise floor" (H6_null branch e) and reported as such in the paper. |

---

## 9. Legal-Gate and Scope-Lock Assessment

| Aspect | Status |
|---|---|
| F21 privileged Docker | UNCHANGED. Same as baseline. No additional escalation. |
| F22 keybox provenance | **EXTENDED** — this is a scope-EXTENSION of F22, not a new gate. Each of ≤3 keyboxes requires individual Rechtsabteilung sign-off per the F22 corrective. **Graceful degradation:** if <3 cleared, M03 active with reduced power (|M_active| includes M03 with the priors-CSV row truncated to cleared keyboxes only); if 0 cleared, M03 is retained in the CSV with priors set to 0 and is deterministically skipped by the strict-positive argmax rule (§4.3). The loop proceeds with the remaining |M_active|. See §12 Q5 for the pre-committed decision rule. |
| F23 reproducibility-pack | UNCHANGED for the public-repo deliverable, EXTENDED on the institutional-only side: the iteration-log + priors-CSV + per-iteration μ_i^(k) matrix + mitigation-history sequence m(1)..m(K) live in the institutional-only repository under the same F23 split as SpoofStack manifests. |
| §202c StGB | **EXTENDED** — the *ordered mitigation trajectory* and *priors-CSV* are themselves a recipe and therefore institutional-only. Co-evolution is a *measurement* of resistance, not a *recipe* for bypass. **Iteration-log + priors-CSV + per-iteration μ_i^(k) matrix + mitigation-history sequence m(1)..m(K) are INSTITUTIONAL-ONLY artifacts** (same F23 split as SpoofStack manifests). The paper publishes only the aggregate convergence curve D^(k) and the irreducible-probe count Σ_i 1[μ_i^(K) > 0.20]. The ordered mitigation sequence and the priors-CSV are NEVER published in the paper body, supplement, or replication archive — only the institutional-only repository. |
| Live-platform scope | UNCHANGED. DetectorLab remains the sole oracle. No live-platform contact. |
| TKG §88 / DSGVO | UNCHANGED. No third-party communication. Sensor traces are own-device only. |

H6 does NOT require *new* Legal-Gate clearance beyond F21/F22/F23 (already in queue), but it does **scope-EXTEND F22 and F23/§202c** as described above — per-keybox Rechtsabteilung sign-off (F22) and institutional-only trajectory artefacts (F23/§202c). M03 is the only mitigation whose breadth depends on F22 outcome; the strict-positive argmax rule guarantees deterministic skip in the worst case.

---

## 10. Researcher Degrees of Freedom (§11 OSF amendment)

In addition to the 7 RDFs in `osf-preregistration.md` §11:

8. **K = 4** — chosen for budget-tractability (§7). K=6 considered but exhausts |M|. K=2 too short.
9. **|M| = 8 mitigations** — covers L1/L3/L4/L5/L6 and parameter axes; chosen for tractability. Larger M considered but would inflate trial-and-error.
10. **|P_ext| = 12 probes** — 3× |M| to ensure detector has room beyond mitigations. Smaller P_ext biases toward null.
11. **Greedy selection rule** — local-optimum acknowledged §8. Alternative: exhaustive search over (K-choose-M, K-choose-P_ext) — exponentially more expensive, not feasible at K=4.
12. **Detection-rate threshold 0.20** for irreducible-probe count — midpoint between noise-floor (0.10) and detection-decisive (0.40); same statistical rationale as F13.
13. **Convergence threshold |ΔD| < 0.05 for two consecutive transitions** — empirical convergence definition; reported as observed-or-not, never adjusted post-hoc.

---

## 11. Proposed Changes (do NOT apply until approval)

### Application split: two sequential PRs

This bundle is **NON-ATOMIC** and applies as two sequential PRs (PR-A blocks PR-B; each PR gets its own OSF amendment timestamp per `registration/osf-preregistration.md` §9 line 152):

- **PR-A — OSF amendment text changes.** Interlocking statistical commitments to §2, §4, §5, §9, §10, §11, §12 of `osf-preregistration.md`. Must land together as a single OSF-timestamped amendment.
- **PR-B — Architecture artifacts.** `experiments/coevolution/mitigation_priors.csv` + `experiments/coevolution/SPEC.md` + `ROADMAP.md` Gantt update (+3 days on the "exp" block). PR-A blocks PR-B.

### File: `registration/osf-preregistration.md` (PR-A)

- Add §2 row for H6 hypothesis (verbatim from §3.1 above, with the exhaustive H6_null partition)
- Add §4 row: "Adversarial co-evolution sub-experiment, K=4, 5 iterations × N=60 = 300 runs (240 marginal after C8_full reuse)"
- Add §5 step: "8. Trajectory test: sequential two-sample proportion z-test (Fisher exact at small n) across iterations; stratified BH-FDR q=0.05 per transition over 246 tests total (60+61+62+63); convergence (|ΔD|<0.05 two-consecutive) and irreducible-count (≥3 with μ>0.20) secondary; coherence-detection-fires (c_score<0.05) confirmatory"
- Add §9 Amendment 3: "H6 co-evolution sub-design — added 2026-05-14"
- Add §10 H6 falsifiability row (5 sub-cases per §3.1)
- Add §11 RDFs 8–13
- Add §12 Open Decision Point: "If F22 clears 0 keyboxes, M03 is retained in CSV with priors=0 and skipped by strict-positive argmax (§4.3); if <3 cleared, M03 active with reduced power"

### File: `plans/03-experiment-matrix.md` — DO NOT MODIFY (plan-immutable)

Reference this addendum from any future `plans/03-...-addendum.md`.

### File: `experiments/coevolution/mitigation_priors.csv` (PR-B)

The CSV at `experiments/coevolution/mitigation_priors.csv` is **authored by Subagent B in this same Round-3 revision pass** and reviewed before OSF lock — NOT a forward reference. Earlier draft incorrectly cited a phantom "Table §6" inside this addendum; that cite is removed, and priors are now sourced from `docs/research-notes/ml-adversary-models.md` §6 (Layer × Adversary table) per the derivation rule in §2 of the CSV itself. Reviewer-checklist item: **CSV reviewed and locked BEFORE OSF amendment timestamp** (added to §13).

### File: `experiments/coevolution/SPEC.md` (PR-B)

`experiments/coevolution/SPEC.md` is **authored by Subagent C in this same Round-3 revision pass**. It declares the coevolution orchestrator as a **STRICT WRAPPER** over the existing runner CLI (no schema changes to runner; no journal extension). The wrapper invokes `runner run` K=5 times with K distinct pre-built manifests, each with its own `container_image_hash` pin. Iteration state lives in a **separate** `iteration_journal.sqlite` alongside (not inside) `runner/journal.sqlite`. Cross-reference SPEC.md when it exists.

### Run-ID derivation (BLAKE3 schema preservation) — §11.x

Coevolution runs use the **existing runner BLAKE3 material UNCHANGED**. Iteration provenance is captured in the per-iteration manifest's `metadata` field, **not** in the run-ID pre-image. This preserves namespace separation (each manifest has a unique `canonical_json` because its mitigation-set, P_ext additions, and `container_image_hash` differ across iterations) without breaking the runner's idempotency invariant. The earlier draft proposal to add `(iteration_k, mitigation_history_hash, probe_extension_history_hash)` to the run-ID material is **dropped**.

### `ROADMAP.md` Gantt (PR-B)

Extend the "exp ... 21d" block by +3 days; "stats" and "paper" blocks unchanged. See §6.1.

---

## 12. Open Questions for Human Partner + Statistician

1. **Is K=4 acceptable, or should we pre-commit to K=6 (full M exhaustion)?** Trade-off: K=6 costs ~30h extra orchestrator time; K=4 leaves 4 mitigations unapplied (a deliberate falsification path).
2. **Should P_ext be 12 probes or expanded to 20?** Smaller P_ext biases toward null (detector can't keep up); larger P_ext leaks trial-and-error.
3. **Greedy vs ε-greedy selection?** Strict greedy is mechanically pre-registrable. ε-greedy (random 10% of moves) would explore alternative trajectories but adds a randomization seed RDF.
4. **Does H6 belong as a sub-hypothesis under H5 (coherence) or as a separate top-level hypothesis?** Recommendation: separate H6 (it tests trajectory, not snapshot).
5. **F22 zero-keybox handling — PRE-COMMITTED RULE (§4.3 strict-positive argmax + §9 graceful degradation):** if F22 clears 0 keyboxes, M03 is RETAINED in `mitigation_priors.csv` with all priors set to 0 and is deterministically skipped by the strict-positive argmax rule; the loop proceeds with |M_active| = 7. If F22 clears <3 (but ≥1), M03 active with reduced power (truncated keybox-rotation row). Re-baselining or deferral are NOT options under this commitment. Reported in the paper as "L3 dimension exercised at reduced power" (or "not exercised") per the actual F22 outcome.
6. **How should the paper frame the result if H6_null branch (b) (oscillation) is observed?** This would be the most interesting finding ("the game has no equilibrium under M"). Pre-commit to reporting it as primary, not as failure.
7. **Reviewer-panel composition:** does the user accept the 12-reviewer panel listed §14, or should we add/remove?

---

## 13. Reviewer-Validation Required Before Merge

- [ ] Multi-reviewer round, ≥10 parallel reviewers (Round-2 12-panel done; Round-3 3-reviewer sanity round pending)
- [ ] Legal-Gate cross-check: F21 UNCHANGED, F22 EXTENDED (per-keybox sign-off), F23/§202c EXTENDED (institutional-only trajectory artefacts) — see §9
- [ ] Pre-Registration impact: OSF amendment timestamp (PR-A) committed BEFORE any iteration starts
- [ ] Statistician sign-off on trajectory-test design — **must explicitly call out**: (a) two-sample proportion z-test (NOT paired McNemar) because iterations draw independent N=60 from fresh snapshots; (b) stratified BH-FDR per transition with family sizes 60/61/62/63 (NOT pooled 246); (c) Brown's method (H5) vs BH-FDR (H6) is correct because the dependence structures differ across the two hypothesis families (§6.7)
- [ ] `experiments/coevolution/mitigation_priors.csv` reviewed and locked BEFORE OSF amendment timestamp (PR-A blocks PR-B; CSV must exist and be reviewed prior to PR-A merge)
- [ ] `experiments/coevolution/SPEC.md` reviewed and confirmed as STRICT WRAPPER over existing runner CLI (no runner schema changes, no journal extension)
- [ ] `ROADMAP.md` Gantt extended +3 days on "exp" block (147h total Phase 4)
- [ ] Plan-Immutability: file is new at `plans/10-...`, not edit of 00–04 ✓ (verified by writer)

---

## 14. Reviewer-Panel Plan (12 parallel reviewers)

Per skill workflow Step 4, with user's explicit "min. 10" demand:

| # | Reviewer | Invocation | Focus |
|---|---|---|---|
| 1 | Gemini 3 Pro (CLI) | `gemini --skip-trust -m gemini-3-pro-preview` | External methodology, statistical rigor |
| 2 | Codex GPT-5.5 (CLI) | `codex exec --skip-git-repo-check` | Independent stats / ML methodology |
| 3 | architecture-strategist | Claude subagent | Plan-coherence with 00–04 |
| 4 | security-auditor | Claude subagent | OpSec / Legal-Gate / §202c |
| 5 | gap-analyst | Claude subagent | Missing requirements, edge cases |
| 6 | quality-auditor | Claude subagent | Rigor, correctness |
| 7 | lead-software-architect | Claude subagent | System-design coherence (runner extension) |
| 8 | pattern-recognition-specialist | Claude subagent | Methodological pattern soundness |
| 9 | adversarial-plan-validator | Claude subagent | Opus+GPT-5.2 cross-validation |
| 10 | code-simplicity-reviewer | Claude subagent | YAGNI check on M, P_ext, K |
| 11 | minimax-reviewer | Claude subagent (MiniMax M2.1, ~8% cost) | Cost-effective second-opinion |
| 12 | glm-reviewer | Claude subagent (GLM-5/4.7) | Third-opinion redundancy |

Consolidation table appended below post-panel completion.

---

## 15. Reviewer Feedback — 12-Panel Consolidation

Panel completed 2026-05-14. All 12 reviewers returned verdicts. Convergence is high: the design's bones are sound, but multiple statistical and engineering details must be fixed before OSF lock.

### 15.1 Verdict Matrix

| # | Reviewer | Verdict | Highest-severity finding |
|---|---|---|---|
| 1 | Gemini 3 Pro (CLI) | NEEDS_REVISION | CRITICAL: McNemar on independent runs invalid; CRITICAL: greedy argmax inverted |
| 2 | Codex GPT-5.5 (CLI) | NEEDS_REVISION | CRITICAL: c_score framing flipped; CRITICAL: McNemar misapplied; HIGH: missing priors CSV |
| 3 | architecture-strategist | NEEDS_REVISION | HIGH: coevolution/SPEC.md is hidden re-architecture; HIGH: BH-FDR denominator wrong; HIGH: F22 mislabeled |
| 4 | security-auditor | NEEDS_REVISION | HIGH: F22 "UNCHANGED" understated; HIGH: §202c trajectory log = recipe |
| 5 | gap-analyst | NEEDS_REVISION | CRITICAL: priors CSV is forward reference; HIGH: 6 unhandled edge cases |
| 6 | quality-auditor | NEEDS_REVISION | HIGH: H6_alt/H6_null non-exhaustive; HIGH: phantom "Table §6" cite |
| 7 | lead-software-architect | NEEDS_REVISION | HIGH: run-ID schema collision; HIGH: §11 bundle non-atomic; HIGH: Gantt impact hidden |
| 8 | pattern-recognition-specialist | NEEDS_REVISION | HIGH: Stackelberg paradigm unnamed; HIGH: convergence taxonomy incomplete (3 modes not 2) |
| 9 | adversarial-plan-validator | NEEDS_REVISION | HIGH: H6_alt/H6_null gap region; HIGH: BH-FDR dependence; HIGH: sensitivity reopens locked thresholds |
| 10 | code-simplicity-reviewer | NEEDS_REVISION | MED: K=4 vs K=3 reconsider; MED: |M|=8 inflated; MED: SPEC.md is architecture debt |
| 11 | minimax-reviewer | NEEDS_REVISION | HIGH: Brown's-method inconsistency with H5; HIGH: 5 new probes need feasibility gate |
| 12 | code-reviewer (glm-replacement) | NEEDS_REVISION | HIGH: regression-to-the-mean unaddressed; HIGH: McNemar invalid; MED: BLAKE3 schema collision |

**Unanimous: 12/12 NEEDS_REVISION. 0 BLOCK. 0 PASS. 0 REJECT.**

### 15.2 Convergent Findings (≥3 reviewers independently identified)

| Convergent finding | Reviewers | Severity (max) | Required fix |
|---|---|---:|---|
| **C1. McNemar on independent samples invalid** | Gemini, Codex, gap, quality, arch, pattern, adversarial, glm-repl, minimax (9) | CRITICAL | Replace with two-sample proportion test / Fisher exact / GEE / permutation. OR enforce paired-seed protocol. Statistician sign-off required. |
| **C2. `mitigation_priors.csv` is forward reference / "Table §6" phantom cite** | Gemini, Codex, gap, quality, arch, minimax (6) | CRITICAL | Author the CSV as a Round-3 deliverable BEFORE OSF lock. Remove phantom "Table §6" cite. Show CSV in addendum so panel can review. |
| **C3. Convergence-threshold inconsistency (0.02 vs 0.05) across §3.3/§3.4/§6.3/§11** | Gemini, gap, arch, Codex, minimax (5) | HIGH | Pick ONE convergence threshold (recommend 0.05 from §6.3/RDF13). Strike all 0.02 references. Verify byte-for-byte consistency. |
| **C4. Probe-count BH-FDR denominator wrong (75 vs 60+min(k,4))** | Gemini, Codex, arch, pattern, minimax (5) | HIGH | Stratify BH-FDR by per-iteration probe set. P_ext probes have no prior-iteration paired test at introduction — must be defined explicitly. |
| **C5. F22 keybox "UNCHANGED" understated — actually EXTENDED** | security, Codex, arch (3) | HIGH | Change §9 row from UNCHANGED to EXTENDED. Each of ≤3 keyboxes needs individual Rechtsabteilung sign-off. Pre-commit graceful degradation when <3 cleared. |
| **C6. §202c risk: published mitigation trajectory IS a recipe** | security, lead-soft (2) | HIGH | Add §9 commitment: iteration-log + priors-CSV + per-iteration μ are institutional-only. Paper publishes only aggregate D^(k) and irreducible-count, NOT the m(1)..m(K) sequence. |
| **C7. H6_alt/H6_null not jointly exhaustive — "no-decision" gap region** | quality, adversarial (2) | HIGH | Rewrite §3.1 so H6_null is the literal complement of H6_alt OR partition the (D, probe-count, c_score) outcome space. |
| **C8. `experiments/coevolution/SPEC.md` undefined / hidden re-architecture** | arch, gap, lead-soft, code-simplicity, glm-repl (5) | HIGH | Either inline a SPEC skeleton into §11 OR declare coevolution as a STRICT WRAPPER over the existing runner CLI (no schema changes). Pick one. |
| **C9. Run-ID BLAKE3 schema collision with runner SPEC.md §6** | arch, lead-soft, glm-repl (3) | HIGH | Either canonicalize iteration_k=0 to reduce to baseline form (preserving reuse claim) OR drop the C8_full reuse claim and budget 300 fresh runs. Version with `schema_version: "runner.coev.v1"`. |

### 15.3 Singleton-but-Material Findings

| Finding | Reviewer | Severity | Why preserved |
|---|---|---:|---|
| **S1. Coherence c_score < 0.05 framing semantically flipped** | Codex | CRITICAL | §3.1 says "preserving coherence" but uses `c_score < 0.05` which the H5 spec defines as INCOHERENT. Fix: clarify whether H6_alt requires coherence to fire (c_score < 0.05) or to be preserved (c_score ≥ 0.05). Rewrite §1, §3.1, §3.4, §6.5 consistently. |
| **S2. Greedy argmax inverted in §4.3** | Gemini | CRITICAL | `argmax over m of Σ_i (μ_i^(k-1) - μ_i_predicted^m)` selects the LEAST effective mitigation. Should be `argmin` OR `argmax over m of Σ_i min(μ_i^(k-1), μ_i_predicted^m)`. |
| **S3. Regression-to-the-mean unaddressed in §8** | glm-replacement | HIGH | RTM is the standard alternative explanation for apparent convergence in small-K repeated measures. Add to §8 with pre-committed between-iteration variance diagnostic. |
| **S4. Stackelberg paradigm unnamed** | pattern-recognition | HIGH | Add citation to Madry et al. or Roughgarden §3. Frame H6 as finite-horizon Stackelberg game with pre-committed strategy sets. |
| **S5. Convergence taxonomy incomplete (3 modes not 2)** | pattern-recognition | HIGH | Add branch (c) "chaotic attractor with sub-threshold amplitude" — K=4 cannot distinguish chaos from noisy absorbing state. Pre-register reporting all three. |
| **S6. 5 new P_ext probes have no feasibility gate** | minimax | HIGH | Probes #76, #77, #84, #85, #86 are NEW — add 1-day pilot gate analogous to Probe #75 (osf-pre-reg §9 Amendment 2). |
| **S7. Brown's-method inconsistency with H5** | minimax | HIGH | H5 mandates Brown's (coherence-metric-spec.md §3.5); H6 trajectory test silently uses Fisher-equivalent BH-FDR. Reconcile or justify family-independence. |
| **S8. §11 bundle is non-atomic — split into 2 PRs** | lead-software-architect | HIGH | OSF amendment (stats commitments) vs architecture artifacts (CSV + SPEC) must be separately timestamped per osf-pre-reg §9 line 152. |
| **S9. Gantt impact hidden in §6.1** | lead-software-architect | HIGH | 20h marginal cost is ON TOP OF 127h baseline (osf-pre-reg §7). State explicitly: total Phase 4 ≈ 147h. Propose ROADMAP.md update as part of the same approval. |
| **S10. Sensitivity bands reopen locked thresholds** | adversarial-plan-validator | HIGH | §6.6 sensitivity (0.03/0.05/0.07) effectively gives 3 thresholds; RDF13 says "never adjusted post-hoc". Pre-commit: sensitivity is appendix-only, MUST NOT appear in abstract/conclusion. |
| **S11. M03 keybox argmax tie-break / no-op handling** | gap-analyst | MED | If F22 clears 0 keyboxes, what does priors-CSV row look like? Pre-commit strict-positive selection rule OR remove M03 from CSV. |
| **S12. M06 "target-app coverage" / "known-good app list" ambiguous re Scope-Lock** | Codex | MED | Rename to DetectorLab-only fixture coverage metric. Explicitly state no live third-party app names referenced. |

### 15.4 Simplification Opportunities (YAGNI)

| Suggestion | Reviewer | Recommendation |
|---|---|---|
| **K=4 → K=3** | code-simplicity | Worth statistician input. If convergence requires monotonicity, K=4 stays. Otherwise K=3 saves 25% budget. |
| **|M|=8 → |M|=6** | code-simplicity | Keeps 2 unapplied falsification path, removes 2 inert rows. Trade-off vs preserving "half-of-M unapplied" rhetorical strength. |
| **CSV as separate artifact → inline table** | code-simplicity | Inline the prior matrix in §4.3 prose. CSV becomes a derived artifact. Reduces sync risk. |
| **9 sensitivity perturbations → 3 mandatory** | code-simplicity | Keep probe-threshold (0.20) sensitivity mandatory; relegate others to replication archive. |
| **6 new RDFs → consolidate** | code-simplicity | Fold RDF 12 under existing RDF 4 (threshold family). Drop RDF 10 (|P_ext| = 3×|M| is deterministic). |

### 15.5 Strengths Affirmed (≥3 reviewers)

| Strength | Affirmed by |
|---|---|
| Plan-Immutability cleanly observed (file is new at `plans/10-...`) | Gemini, Codex, arch, security, lead-soft, adversarial |
| Pre-committed M and P_ext locked before k=0 | all 12 |
| Dual-branch null (perfect spoof vs oscillation) is scientifically honest | quality, code-simplicity, adversarial, minimax, glm-repl |
| K=4 budget table with explicit tradeoffs | gap, code-simplicity, adversarial |
| M03 graceful degradation to |M_active|=7 if F22 partial | security, arch, lead-soft, code-simplicity, minimax |
| Threats-table acknowledges "real-world detectors ≠ DetectorLab" external-validity limit | security, arch, adversarial |

### 15.6 The "USENIX Rejection Vector" (from adversarial-plan-validator)

> "Closed-world equilibrium against your own straw-man detector, dressed up in pre-registration language. M and P_ext are both authored by the same team, drawn from the same priors CSV. The argmax-vs-argmax game is internal solipsism — neither side surprises the other. The 'irreducible floor' measures the team's own priors, not a property of cloud-phone detection in general."

**Required pre-emption:** §1 line 15 says "a fully indistinguishable cloud phone provably does not exist within the bounded mitigation-set M" — but §1 line 16 drops "within M" and reads "a fully indistinguishable cloud phone provably does not exist". This abstract-language slip is exactly what a hostile reviewer will quote. Pre-commit: abstract MUST retain "under bounded adversary M and detector P ∪ P_ext". Lock the language in §11 amendment text.

### 15.7 Consolidation Verdict

The addendum is at **NEEDS_REVISION** but unambiguously **fixable in one revision pass**. No reviewer recommended outright rejection. No reviewer recommended deferring to a follow-up paper. The required revisions cluster into 5 categories:

1. **Statistical correctness (C1, C3, C4, C7, S1, S3, S7)** — replace McNemar with appropriate test, harmonize convergence threshold, fix BH-FDR denominator, fix exhaustivity gap, fix c_score framing, add RTM diagnostic, reconcile with Brown's method.
2. **Pre-commitment hygiene (C2, S2, S6, S10)** — author the priors CSV, fix the argmax inversion, add feasibility gate for new probes, lock sensitivity to appendix.
3. **Legal-Gate precision (C5, C6, S11)** — F22 EXTENDED + per-keybox sign-off, institutional-only iteration log, M03 zero-keybox CSV behavior.
4. **Architecture & engineering (C8, C9, S8, S9)** — split §11 into 2 PRs, define coevolution/SPEC.md or declare wrapper-only, fix BLAKE3 schema, expose Gantt impact.
5. **Methodology framing (S4, S5, S12, YAGNI)** — name Stackelberg, extend convergence taxonomy, scope-lock M06 language, simplify per code-simplicity findings.

None of these require redesigning H6. All are textual/structural fixes within the existing scope. Estimated revision effort: 1–2 hours of focused editing. After revision, re-validation is **not** required to be a full 12-panel — a 3-reviewer sanity round (Gemini + 1 architecture + 1 statistician) is sufficient.

### 15.8 Open Question for Human Partner (overrides all)

Two reviewers (Gemini, Codex) flagged the **greedy argmax inversion** (S2) and the **c_score framing flip** (S1) as **CRITICAL** errors that break the design's stated meaning. These are not opinion-dependent — they are mechanical bugs. Before approving the addendum (even as "apply with revisions"), the human partner must decide:

- **Path A:** Accept that the addendum needs the revisions listed in §15.7 before OSF amendment. AI agent fixes them (1 revision pass), then a 3-reviewer sanity round, then OSF amendment goes up for human + statistician sign-off.
- **Path B:** Reject the addendum in its current form and request a complete redraft.
- **Path C:** Apply as-is with the bugs as caveats (NOT RECOMMENDED — would invalidate any subsequent OSF amendment).

**AI agent recommendation: Path A.** The 12 reviewers were unanimous on NEEDS_REVISION but also unanimous on the design being scientifically valuable. The bugs are mechanical, not conceptual.

---

## 17. Round-3 Revision Log (DRAFT-REV-1)

Applied 2026-05-14 by Subagent A in the 3-subagent parallel revision round. The §15 12-panel feedback is preserved verbatim above as the historical record. Below is the per-finding application log against the current text of §§1–13.

| # | Finding | Severity | Section(s) edited | What changed |
|---|---|---|---|---|
| 1 | **S1** c_score framing flipped | CRITICAL | §1, §3.1, §3.4, §3.5, §6.5 | Clarified c_score → 1 = HIGHLY CONSISTENT / real-device-like; c_score → 0 = INCONSISTENT / spoofed. Rewrote occurrences to "coherence-detection fires (c_score < 0.05)" instead of ambiguous "preserves/breaks coherence". |
| 2 | **S2** greedy argmax inverted | CRITICAL | §4.3 | Changed formula to `argmax over m of Σ_i μ_i_predicted^m`; added explicit note μ is predicted REDUCTION (not remaining detection-rate); strict-positive rule for zero-prior rows. |
| 3 | **C1** McNemar invalid on independent runs | HIGH (9/12) | §3.5, §6.2 | Replaced with two-sample proportion z-test (Fisher exact at small n); explicit independence rationale; §13 statistician sign-off line calls this out. |
| 4 | **C2** priors CSV forward reference + phantom "Table §6" | CRITICAL | §4.3, §11, §13 | Removed phantom Table §6 cite; declared CSV authored by Subagent B in same Round-3 pass; §13 checklist item "CSV reviewed and locked BEFORE OSF amendment timestamp". |
| 5 | **C3** convergence-threshold 0.02 vs 0.05 inconsistency | HIGH | §3.3 step 5 | Replaced 0.02 with 0.05 (locked per §6.3 / RDF13); verified §3.4, §6.3, §10 are byte-consistent. |
| 6 | **C4** BH-FDR denominator wrong (75 vs 60+min(k,4)) | HIGH | §6.2 | Replaced "75×4=300" with stratified per-transition table (60/61/62/63 = 246 total); P_ext first-appearance probes routed to separate appendix test vs N₀=90 real-device reference. |
| 7 | **C5** F22 keybox UNCHANGED understated | HIGH | §9 row, §9 closing, §12 Q5 | F22 changed from UNCHANGED to EXTENDED; per-keybox Rechtsabteilung sign-off; graceful degradation rule (priors=0 + strict-positive skip if 0 cleared); §12 Q5 made into pre-committed rule. |
| 8 | **C6** §202c trajectory-log is a recipe | HIGH | §9 row, §9 (F23 row) | Iteration-log + priors-CSV + per-iteration μ matrix + mitigation-history sequence declared INSTITUTIONAL-ONLY under same F23 split as SpoofStack manifests; paper publishes only D^(k) and irreducible-count. |
| 9 | **C7** H6_alt/H6_null not exhaustive (gap region) | HIGH | §3.1 (rewritten) | H6_null rewritten as literal complement of H6_alt; partitioned into sub-cases (a)–(e); pre-commit to reporting which sub-case applies. |
| 10 | **C8** experiments/coevolution/SPEC.md scope undefined | HIGH | §11 | Declared SPEC.md authored by Subagent C in same Round-3 pass; STRICT WRAPPER over runner CLI (no schema/journal changes); iteration state in separate iteration_journal.sqlite. |
| 11 | **C9** run-ID BLAKE3 schema collision | HIGH | §11.x (new) | Run-ID material UNCHANGED from runner; iteration provenance lives in per-iteration manifest's metadata field; dropped earlier proposal to add iteration_k / mitigation_history_hash / probe_extension_history_hash to run-ID pre-image. |
| 12 | **S3** regression-to-the-mean unaddressed | HIGH | §8 threats-table | Added RTM row with pre-committed between-iteration variance diagnostic (Var(D^(0..K)) vs within-iteration bootstrap CI width × 1.5); downgrade rule to H6_null branch (e). |
| 13 | **S4** Stackelberg paradigm unnamed | HIGH | §2.2, §2.3 | Added game-theoretic framing paragraph (finite-horizon sequential Stackelberg with pre-committed strategy sets); cited Madry et al. ICLR 2018; added prior-work row. |
| 14 | **S5** convergence taxonomy incomplete (3 modes not 2) | HIGH | §3.1 | Added explicit absorbing / limit-cycle / chaotic-attractor enumeration; K=4 limitation noted; trajectory-shape diagnostic pre-committed as primary observation. |
| 15 | **S6** 5 new P_ext probes have no feasibility gate | HIGH | §5.1 footer | Added 1-day pilot gate for #76, #77, #84, #85, #86 (C0_real N=10 + C1_L0a N=10; CV<30% + Cohen's d>0.5 per Probe #75 / Amendment 2); pilot data go/no-go only; |P_ext_active| = 12 − failures. |
| 16 | **S7** Brown's method inconsistency with H5 | HIGH | §6.7 (new) | Added cross-test consistency section: H5 uses Brown's (within-snapshot correlated probes), H6 uses BH-FDR (independent across-iteration samples); families are pre-registered DIFFERENT, corrections never pooled. |
| 17 | **S8** §11 bundle non-atomic | HIGH | §11 | Split into PR-A (OSF amendment text) and PR-B (architecture artifacts: CSV + SPEC.md + ROADMAP Gantt); PR-A blocks PR-B; each gets its own OSF timestamp. |
| 18 | **S9** Gantt impact hidden | HIGH | §6.1 closing | 20h marginal stated as ON TOP OF 127h baseline (147h total Phase 4); ROADMAP.md "exp ... 21d" extended +3 days; "stats" and "paper" unchanged. |
| 19 | **S10** sensitivity bands reopen locked thresholds | HIGH | §6.6 | APPENDIX-ONLY restriction made explicit and pre-committed; sensitivity rows MUST NOT appear in abstract/intro/conclusion/headline figure. |
| 20 | **§1 abstract-language slip** (no "within M") | HIGH | §1 | Bounded-adversary qualifier "within bounded adversary M and detector P ∪ P_ext" locked in §1; unqualified phrase explicitly disallowed in abstract/intro/conclusion. |

### 17.1 Judgment calls

- **C3 (0.02 → 0.05):** Took 0.05 as the locked value, consistent with §6.3 (already 0.05) and RDF13 (already 0.05). The §3.3 occurrence was the lone outlier.
- **C5/§12 Q5:** Replaced the open question with a pre-committed rule (priors=0 + strict-positive skip for zero-cleared keyboxes). This collapses three of the original options into a single deterministic path, which is required for pre-registration; the §15 panel's recommendation was option (a), which is consistent with this rule.
- **C8 (SPEC.md scope):** Followed the panel's "STRICT WRAPPER" framing (not the alternative "inline a SPEC skeleton") because the wrapper-only choice preserves runner schema immutability — a stronger pre-registration commitment.
- **C9 (BLAKE3):** Followed the "preserve runner schema, put iteration provenance in manifest metadata" path rather than version-bumping the run-ID schema; preserves the C8_full reuse claim from §6.1.
- **S10:** Phrased the sensitivity restriction as a binding pre-commitment on the writing pipeline (rather than just an analysis convention) because the §15.6 USENIX-rejection vector specifically targets sensitivity-band rhetoric.

### 17.2 Files NOT touched by Subagent A

Per the parallel-revision contract:
- `experiments/coevolution/mitigation_priors.csv` — authored by Subagent B (this revision pass).
- `experiments/coevolution/SPEC.md` — authored by Subagent C (this revision pass).
- All `plans/00–04*`, `registration/osf-preregistration.md`, and any other repo file: untouched (plan-immutability).

### 17.3 Status of YAGNI suggestions from §15.4

Not applied in this revision pass — those are simplification opportunities, not correctness fixes, and would require fresh user approval to alter the locked design (K=4, |M|=8, |P_ext|=12, full sensitivity grid, 6 RDFs). Deferred to a future revision if the user requests it.

### 17.4 Status of S11/S12 (medium-severity singletons)

- **S11 (M03 zero-keybox CSV)** — addressed via §4.3 strict-positive rule + §9 graceful degradation + §12 Q5 pre-commitment; the CSV-row mechanics are Subagent B's deliverable.
- **S12 (M06 scope-lock language)** — deferred. Recommend Subagent B inspect M06 in the CSV and rename "target-app coverage / known-good app list" to "DetectorLab-only fixture coverage" if needed. Flag here for the Round-3 sanity reviewers.

---

## 18. Polish-Pass-1 Log (DRAFT-REV-2)

Sanity-round findings F-H6-rev-001..006 + Gemini's M06 nit applied 2026-05-14 across 3 files:

| # | Finding | File | Edit |
|---:|---|---|---|
| 1 | C7 mutual-exclusivity precedence | addendum §3.1 | Added precedence rule `e → b → a → c → d` for headline-branch selection; appendix table reports ALL fired branches. |
| 2 | S12 / Gemini-nit M06 language | addendum §4.1 line 145 | Renamed "DenyList expansion (target-app coverage) / known-good app list" → "DenyList expansion (DetectorLab fixture-coverage) / DetectorLab-only DenyList fixture package set". Explicit "no live third-party app names; lab-fixture only". |
| 3 | F-H6-rev-004 (adversarial) Cohen's d alignment | addendum §5.1 footer | d > 0.5 → **d > 0.8** to align with OSF Amendment 2 (Probe #75). |
| 4 | F-H6-rev-005 (architecture) #75 double-membership note | addendum §5.1 footer (new paragraph) | Added explicit clarification: #75 is in baseline at k=0; never "added" by detector during co-evolution; preserves 60→61→62→63→64 family sizes. |
| 5 | F-H6-rev-003 (architecture) argmin vs argmax label | SPEC.md §3 Mermaid line + §14 test name | Renamed `greedy argmin` → `greedy argmax over predicted reduction`. Function name `greedy_argmin` → `greedy_argmax`. Test description aligned with addendum §4.3. |
| 6 | F-H6-rev-002 (architecture) --reuse-c8-baseline default | SPEC.md §17 Q3 | Resolved as RESOLVED rather than open. Default = OFF; addendum §6.1 240-run claim contingent on operator explicitly passing flag; otherwise 300 fresh runs (25h marginal not 20h). |
| 7 | F-H6-rev-001 (architecture) iteration_journal merge | SPEC.md §17 Q1 | Downgraded from open question to binding non-goal (consistent with §1.2). Cross-reference by run_id VALUE only, no SQL FK. |
| 8 | F-H6-rev-006 (architecture) M06 CSV language | mitigation_priors.csv §1 header + §4 layer-map | Renamed "DenyList expansion (70%→90%→99% coverage)" → "DenyList expansion over DetectorLab fixture-package set (NOT live third-party apps; per addendum §9 Scope-Lock)". |

**Files touched in Polish-Pass-1:** plans/10-..., experiments/coevolution/SPEC.md, experiments/coevolution/mitigation_priors.csv. No other repo files changed. NOT committed.

### 18.1 Sanity-Round Verdict Summary

| Sanity reviewer | Verdict | Headline |
|---|---|---|
| Gemini-CLI (#13) | **PASS** | "Round-3 revisions are comprehensive, methodologically sound" — 1 minor (M06) resolved in Polish-Pass-1 |
| Adversarial-plan-validator (#14) | **PASS** (statistician sign-off needed) | 19/22 YES, 2 PARTIAL (C7 mutual-exclusivity → now precedence-locked; S12 M06 → now renamed) |
| Architecture-strategist (#15) | **NEEDS_REVISION (minor)** | 6 F-H6-rev findings → all resolved in Polish-Pass-1 |

**Post-Polish status:** all 12-panel CRITICAL/HIGH findings RESOLVED; all 6 sanity-round F-H6-rev findings RESOLVED; only blocker remaining is statistician sign-off on §13 line a/b/c.

---

## 16. Stop

Per skill workflow Step 5 — this addendum is DRAFT-REV-2 (post-Polish-Pass-1). No commit, no push, no application to plans/00–04 or osf-preregistration.md until: (a) statistician sign-off received on the §13 checklist items, AND (b) explicit human Y/N approval.

**Statistician outreach drafted at `/tmp/h6-statistician-outreach.md` for human partner to send** — see §19 below.

Approve to apply? **Y/N**

---

## 19. Statistician Outreach (drafted, pending human send)

Email/letter template at `/tmp/h6-statistician-outreach.md`. Target recipients (per HANDOFF.md):
- CISPA Helmholtz Center for Information Security (Saarland)
- TU Darmstadt CYSEC
- University of Cambridge (KeyDroid co-authors Blessing/Anderson/Beresford)

Specific asks for statistician sign-off:
1. Two-sample proportion z-test (Fisher exact at small n) vs paired McNemar across iterations — independence justification correct?
2. Stratified BH-FDR-q=0.05 over 246 trajectory tests + separate appendix test for P_ext at first appearance — sound?
3. RTM diagnostic (Var(D^(0..K)) vs within-iteration bootstrap CI × 1.5) — well-defined and pre-committable?
4. Brown's method (H5) vs BH-FDR (H6) family separation — defensible?
5. Cohen's d > 0.8 for new-probe feasibility gate (aligned with Probe #75) — endorsement?
6. K=4 horizon adequacy for trajectory convergence vs Bayesian identifiability tradeoff — comment?

Sign-off can be informal (email reply confirming "design is statistically defensible for OSF pre-registration") — not a full review.
