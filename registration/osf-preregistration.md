# OSF Pre-Registration

**Title:** An Empirical Layer-by-Layer Evaluation of Android Container Detection Resistance
**Date drafted:** 2026-05-03 · **Status:** DRAFT — pending human + statistician review, then OSF upload
**DOI placeholder:** [issued by OSF on publication] · **Format:** AsPredicted (osf.io/preprints/osf/zab38)
**Repository:** https://github.com/servas-ai/cloud-phone-research-planner
**Trigger:** Round-1 F13 (`plans/05-validation-feedback.md` lines 180–193) + Round-2 F32 (`plans/07-round-2-feedback.md` lines 90–94) — both demand OSF lock before any data collection to forestall HARKing at USENIX Security / ACM CCS / NDSS.

---

## 1. Have data been collected for this study already?

**NO.** As of 2026-05-03 the project is Phase-0 gated, blocked by F21/F22/F23 (`plans/05-validation-feedback.md` lines 271–312). No probe has executed; no JSON reports exist in `experiments/runs/`. OSF lock must precede the L0a baseline run.

A feasibility pilot for Probe #75 (CPU-frequency side-channel, F33 in `plans/07-round-2-feedback.md` lines 96–98) is permitted as go/no-go data only and is excluded from hypothesis testing (see §12).

---

## 2. What's the main question being asked or hypothesis being tested?

**Verbatim from `plans/00-master-plan.md` §2 (lines 11–16):**

| # | Hypothesis | Falsifiable by |
|---|---|---|
| H1 | Build-Property and ID probes can be fully closed by L1+L2. | DetectorLab-Score = 0 for Probes #1, #9, #11, #12, #15, #27, #28 after L1+L2. |
| H2 | Hardware-Keystore-Attestation remains the most robust vector; only reducible via L3 (TrickyStore + Keybox). | DetectorLab-Score > 0.5 at L0+L1+L2, < 0.2 at +L3. |
| H3 | Sensor signatures (FFT of accelerometer noise) detect containers even after VirtualSensor with > 0.7 confidence when trace data is synthetic. | A/B test real device vs. VirtualSensor with real-device-trace. |
| H4 | IP/ASN remains the strongest single vector; without mobile-carrier egress no pass possible. | DetectorLab-Score > 0.8 at datacenter egress, < 0.1 at LTE-modem egress. |

**New hypothesis added per Finding F32 (`plans/07-round-2-feedback.md` lines 90–94 and `docs/research-notes/ml-adversary-models.md` §6 lines 99–109):**

| # | Hypothesis | Falsifiable by |
|---|---|---|
| H5 | SpoofStack L1–L6 detection-rate against an L_AdvB ML classifier (XGBoost on the probe-vector) is monotonically **lower** (i.e. harder to evade) than against L_AdvA static-rule. Equivalently: the cross-probe coherence metric (A2, `plans/07-round-2-feedback.md` lines 109–113) flags ≥ 2 of L1–L5 inconsistent at p < 0.05 even when per-probe scores ≤ 0.10. | Offline XGBoost (10-fold CV, F1 ≥ 0.80 on labeled real-vs-spoofed corpus) shows monotone non-increase of L_AdvB miss-rate across L1→L6. Falsified if L_AdvB miss-rate ≥ L_AdvA miss-rate at any transition. |

H5 added explicitly to prevent HARKing if the A2 coherence-metric analysis yields an unanticipated finding. Re-registration cost acknowledged per `ml-adversary-models.md` OQ1 (line 113).

---

## 3. Describe the key dependent variable(s) specifying how they will be measured.

| Variable | Operational definition | Measurement instrument |
|---|---|---|
| **DetectorLab probe-score** | Continuous ∈ [0.0, 1.0] per probe per run; 0.0 = real device indistinguishable, 1.0 = container certain. | DetectorLab Kotlin app, Probe-Schema v1 JSON (`docs/probe-schema.md`); 60+ probes per run. |
| **Per-config aggregate** | Weighted mean of probe-scores, weighted by probe-criticality per `probes/inventory.yml`. | Offline `experiments/aggregate/{config-id}.csv` (`plans/03-experiment-matrix.md` lines 47–54). |
| **Layer-transition delta** | Δ-score between L_n and L_{n+1}, paired by run-ID. | Paired-difference file from `experiments/runner/`. |
| **Coherence-score** (per A2) | Multivariate consistency metric over the probe-vector — concrete form (Mahalanobis / Mutual-Information / covariance-eigen-spectrum) locked in `docs/research-notes/coherence-metric-spec.md` per A2 (`plans/07-round-2-feedback.md` lines 109–113) **before** data collection. Pre-committed to whichever form the statistician selects (see §12). | Offline post-aggregation script. |
| **L_AdvB classifier output** | Predicted label `{real, spoofed}` and probability ∈ [0,1] from an XGBoost classifier trained on the probe-vector. | Offline scikit-learn / XGBoost pipeline; **not on-device** per cross-artifact resolution in `plans/07-round-2-feedback.md` lines 63–67. |

All scores are derived from probe-output JSON validated against `docs/probe-schema.md` v1; schema-validation failures are quarantined per §6.

---

## 4. How many and which technical conditions will be evaluated?

This is a technical systems experiment. The experimental units are 8 stack
configurations of the ReDroid 12 SpoofStack, each run N=60 times (§7). Derived
from `plans/03-experiment-matrix.md` lines 7–20, with L0a/L0b split per F1
(`plans/05-validation-feedback.md` lines 30–38).

| Config-ID | Stack composition | Role |
|---|---|---|
| C0_real | Real Pixel 7 (no container) | Negative control — all scores expected ≈ 0.0 |
| C1_L0a | Vanilla ReDroid 12 ARM64 (no Magisk) | Container-only baseline |
| C2_L0b | L0a + Magisk + ReZygisk + LSPosed | Root/hooking baseline |
| C3_L0b_L1 | L0b + DeviceSpoofLab Build-Props | Build-property mitigation |
| C4_L0b_L1_L2 | + Android Faker (identity) | Identity mitigation |
| C5_L0b_L1_L2_L3 | + PIF + TrickyStore + Keybox | Integrity & attestation mitigation |
| C6_L0b_L1..L4 | + Shamiko + HideMyAppList | Runtime hiding |
| C7_L0b_L1..L5 | + VirtualSensor + Trace-Player | Sensor mitigation |
| C8_full | + LTE-Egress (L6) | Full stack |

**Positive controls** (per F19, `plans/05-validation-feedback.md` lines 252–259): AVD x86_64 and Genymotion verify DetectorLab flags known emulators (expected per-probe > 0.7).

**Layer-interaction sub-design** per F3 (`plans/05-validation-feedback.md` lines 53–66): 2^6 fractional-factorial Resolution IV (16 cells) over {L1..L6}, in addition to 8 monotone cells. Total: 24 unique configurations (2 overlap with C0_real / C8_full).

---

## 5. Specify exactly which analyses you will conduct to examine the main question/hypothesis.

Per `plans/03-experiment-matrix.md` lines 24–32 and F3 (`plans/05-validation-feedback.md` lines 59–66):

1. **Per-probe layer-transition test (H1–H4):** McNemar paired test on binary "detected / not-detected" between adjacent configurations (L_n vs. L_{n+1}), paired by run-index. Threshold "detected" = score ≥ 0.40 (F13, `plans/05-validation-feedback.md` lines 187–192; thresholds 0.10/0.40 pre-registered).
2. **Multiple-testing correction:** Benjamini-Hochberg FDR at q = 0.05 across ~420 tests (60+ probes × 7 transitions). FDR > FWER rationale in §11.
3. **Effect-size:** Cohen's *g* for paired binary outcomes; 95% bootstrap CIs (10 000 resamples) on per-probe means.
4. **Layer-interaction:** ANOVA on the 2^6 Resolution-IV design — main effects + 2-way interactions for L1..L6.
5. **Coherence analysis (H5):** metric from `coherence-metric-spec.md` (A2). Configurations flagged "incoherent" if metric exceeds C0_real bootstrap 95th percentile.
6. **L_AdvB ML eval (H5):** offline XGBoost on probe-vectors, 10-fold CV, primary F1, secondary ROC-AUC and per-class precision/recall. Trained on labeled {C0_real, C1_L0a, …, C8_full}. Held-out 20% per label-class. Compared against L_AdvA static-rule baseline (threshold 0.40).
7. **Inter-probe correlation:** Pearson matrix per configuration. Probes with |r| > 0.85 in C0_real flagged redundant (`plans/03-experiment-matrix.md` line 29); PCA or domain-grouped scoring applied per F3 line 64.

All analyses scripted in Python (numpy / scipy / statsmodels / scikit-learn / xgboost), seed = 42, in `experiments/analysis/` (to be created).

---

## 6. Describe exactly how outliers will be defined and handled.

| Outlier class | Definition | Handling |
|---|---|---|
| **Schema-validation failure** | JSON fails `docs/probe-schema.md` v1 validation. | Quarantined to `experiments/runs/{config-id}/quarantine/`; excluded from analysis; re-run from clean snapshot per `plans/03-experiment-matrix.md` lines 36–44. |
| **ABORTED_DRIFT run** | Image hash, Magisk module version, or keybox-revocation status changed between snapshot and completion (F20, `plans/05-validation-feedback.md` lines 261–267; `runner/SPEC.md`). | Aborted, snapshot rebuilt, re-run. Partial data deleted. |
| **Statistical outlier (per-probe)** | Score > 3 IQR from per-config median. | Retained in primary analysis (no censoring); sensitivity analysis with outliers removed reported separately. |
| **Coherence-metric outlier** | Per A2 spec — definition pending. | Per A2 spec; default: report and retain. |
| **Hardware fault** | ARM64 crash, LTE drop > 30 s, kernel panic. | Discard, re-run from clean snapshot. Logged in `incidents.log`. |

A run is **valid** iff: (a) schema-validates, (b) image-hash matches manifest, (c) all 60+ probes scored (no NaN), (d) DetectorLab exit-code 0. Quarantined runs excluded from N.

---

## 7. How many observations will be collected or what will determine sample size?

**N = 60 per configuration** per F3 (`plans/05-validation-feedback.md` lines 59–66), revised upward from the original N=30 (`plans/03-experiment-matrix.md` line 27).

**Total runs:** 8 monotone × 60 + 16 fractional-factorial × 60 = **1 440 valid runs**. With ≈ 5 % drift/quarantine, plan for ≈ 1 520 attempts.

**Power calculation:**
- McNemar α = 0.05 two-sided, 1-β = 0.80, target detectable effect = 20-pp difference in detection-rate between adjacent configurations (smallest meaningful "layer-mitigation success" per `plans/03-experiment-matrix.md` Aggregate row).
- Required ≈ 50 discordant pairs per cell. At expected discordance ≈ 0.85 (`plans/03-experiment-matrix.md` lines 11–19), N ≈ 60 satisfies (`plans/05-validation-feedback.md` line 56).
- Post-BH-FDR at q = 0.05 over 420 tests, effective per-test α ≈ 0.0119; N=60 retains power ≥ 0.70 at 20-pp effect — acceptable for exploratory layer-wise analysis.
- H5 ML eval: 8 × 60 = 480 labeled probe-vectors; 10-fold CV ⇒ 48 test/fold/class — adequate for XGBoost on ~60 features (≥ 10× samples-per-feature rule).

**Stopping rule:** N = 60 hard-locked. No early stopping for significance, no continuation past 60. Budget ≈ 1 520 runs × ~5 min ≈ 127 h orchestrator wall-clock, planned for Phase 4 Weeks 7–10 (`plans/00-master-plan.md` Gantt).

---

## 8. Anything else you would like to pre-register?

**Stop conditions** (any one ⇒ rebuild snapshot, document, restart that configuration's N=60 from zero):
1. Keybox revocation mid-study (Play Integrity backend rotation invalidating L3) — re-baseline L3, L4, L5, full-stack.
2. Container-image hash drift (Docker pull, module auto-update, kernel patch) — re-baseline affected configuration only.
3. Magisk / Zygisk / LSPosed module-version change — re-baseline L0b and downstream.
4. DetectorLab APK version change — re-baseline all (Magisk auto-update disabled per F20 line 266).
5. Any pre-registered-hypothesis change ⇒ OSF amendment (§9, §12).

**Lab-isolation verification** (F24, `plans/05-validation-feedback.md` lines 314–322): before each batch, iptables verified to drop all container-egress except via LTE-NAT. Any failure halts data collection.

**Run-determinism artifacts** (F20 + Round-2 `runner/SPEC.md`): each run emits a BLAKE3 run-ID over (image-hash, manifest-hash, APK-hash, timestamp).

---

## 9. Pre-registered analysis plan amendments (post-Round-2)

Two amendments documented ahead of OSF upload, both from Round-2 Gemini review (`plans/07-round-2-feedback.md`):

**Amendment 1 — H5 added (from F32):** Per §2. Rationale: `docs/research-notes/ml-adversary-models.md` §6 (lines 99–109) showed L1, L2, L5 alone fail under L_AdvB even when per-probe scores ≤ 0.10 because they probe single signals without enforcing cross-correlations C1–C9 (lines 28–40). Without H5 pre-registered, any post-hoc coherence-metric finding would constitute HARKing — exactly F13's concern.

**Amendment 2 — Probe #75 with feasibility-pilot gate (F33):** Probe #75 (CPU-frequency side-channel, Roy Dipta 2024 measured x86 primarily) is **conditionally** included:
- 2-day feasibility-pilot per A4 (`plans/07-round-2-feedback.md` lines 121–125) on ARM64 host, only C0_real and C1_L0a, N=10 each.
- **Acceptance criterion:** within-config CV < 30 % AND between-config Cohen's d > 0.8.
- If accepted ⇒ included in main matrix and counted in 60+ set. If not ⇒ dropped, omission documented in paper.
- Pilot data are go/no-go only — never enter hypothesis testing.

Any further amendment requires an OSF amendment with explicit timestamp and reviewer sign-off.

---

## 10. Falsifiability

| H | Falsified iff |
|---|---|
| **H1** | After L1+L2 (C4), any of Probes #1/#9/#11/#12/#15/#27/#28 returns mean > 0.05 over N=60 (95% CI LB > 0.05). Src: `plans/00-master-plan.md` line 13. |
| **H2** | At C2_L0b (L0+L1+L2), Probe #6 mean ≤ 0.5 OR at C5 (+L3) Probe #6 mean ≥ 0.2. Src: line 14. |
| **H3** | A/B with VirtualSensor + real-Pixel-7 trace yields FFT-classifier confidence < 0.7 "container" on spoofed runs (classifier per F14, `plans/05-validation-feedback.md` lines 196–206 — fixed before data collection). Src: line 15. |
| **H4** | At datacenter-egress, IP/ASN Probe #5 mean ≤ 0.8 OR at LTE-egress (C8_full) ≥ 0.1. Src: line 16. |
| **H5** | L_AdvB miss-rate ≥ L_AdvA miss-rate at any L_n → L_{n+1} (no monotone dominance) OR coherence-metric flags < 2 of L1–L5 configurations inconsistent at p < 0.05 when per-probe scores ≤ 0.10. Src: §2. |

---

## 11. Researcher Degrees of Freedom Acknowledged

Per AsPredicted format §11:

1. **N = 60 per cell** — minimum for McNemar power ≥ 0.80 at 20-pp effect after BH-FDR q = 0.05 / 420 tests (§7). N = 100 considered but exceeds the 12-week budget (Gantt, Phase 3–5).
2. **BH-FDR over Bonferroni** — appropriate for exploratory layer-wise analysis where false-positive cost (one extra "this layer matters" claim) ≪ false-negative cost (missing a real layer effect). Bonferroni at α = 0.05/420 = 1.2e-4 would be massively underpowered at N=60.
3. **Coherence-metric form (Mahalanobis / MI / covariance-eigen-spectrum)** — locked by statistician in `coherence-metric-spec.md` per A2 **before** data collection. Pre-commit prevents post-hoc metric-shopping.
4. **Fractional-factorial Resolution IV (16 cells) vs full 2^6 = 64** — full factorial = 64 × 60 = 3 840 runs, 2.7× over orchestrator budget. Resolution IV preserves all main effects; only 3-way interactions are aliased (academically uninteresting).
5. **Detection threshold 0.40** (F13, lines 187–192) — consensus midpoint between noise floor (0.10) and high-confidence detection (0.70). Sensitivity analysis at 0.30 and 0.50 reported supplementary.
6. **XGBoost > LightGBM / RandomForest for L_AdvB** — most-cited fraud-detection-SDK ML baseline (`ml-adversary-models.md` §1; ATLAS 2025 §3). Others reported as robustness checks.
7. **α = 0.05** — USENIX/NDSS standard for empirical security work; combined with FDR-q = 0.05 yields the same effective FDR control as α = 0.01.

---

## 12. Open Decision Points (for amendment if pilot data demands)

Decision-points that may require an OSF amendment (sign-off, timestamp, change-log) if pilot data reveals an unanticipated obstacle:

1. **Coherence-metric form** — pending A2. If a metric outside §3 (Mahalanobis / MI / covariance-eigen-spectrum) is selected, this doc is amended **before** data collection.
2. **Probe #75 inclusion** — pending feasibility-pilot (§9 Amendment 2). Failure ⇒ dropped; never enters main data.
3. **Keybox availability** — If F22 legal-clearance restricts to own-device extraction only (`plans/05-validation-feedback.md` lines 167–171, Option B) and that proves infeasible in Phase 0, **H2 is pre-flagged "unfalsifiable in this study"** per F11 Option C (line 170) and reported as a negative finding ("L3 not testable") — not silently dropped.
4. **L_AdvB training-corpus coverage** — If < 480 valid probe-vectors after quarantine, H5 reported with reduced power and explicit caveat; hypothesis **not** restated.
5. **Fractional-factorial cell collisions** — If a 2^6 cell coincides with a monotone cell (e.g. all-on = C8_full), data pooled with explicit notation; we do **not** treat the same N=60 as N=120.
6. **Schema v1 deprecation** — Mid-study v2 with backward compat ⇒ revalidate prior runs; otherwise quarantine and re-collect. Schema-version recorded per run.
7. **Real-device sensor-trace IRB scope** — Per `ml-adversary-models.md` Open Question 2 (line 114), if IRB declines the n=5-lab-phone trace baseline, H3 falsification (A/B trace-replay) cannot be performed; H3 reported as "untested due to IRB scope" — not re-formulated.

---

## Cross-Reference Audit

| Claim | Source |
|---|---|
| H1–H4 verbatim | `plans/00-master-plan.md` lines 11–16 |
| H5 (new) | `plans/07-round-2-feedback.md` lines 90–94; `ml-adversary-models.md` §6 lines 99–109 |
| Coherence metric (A2), Probe #75 pilot (A4) | `plans/07-round-2-feedback.md` lines 109–113, 121–125 |
| N=60, BH-FDR q=0.05, 2^6 Resolution IV | `plans/05-validation-feedback.md` lines 53–66 (F3) |
| L0a/L0b split | F1 (lines 30–38) |
| Thresholds 0.10/0.40, OSF pre-registration trigger | F13 (lines 180–192) |
| ABORTED_DRIFT | F20 (lines 261–267); `runner/SPEC.md` |
| Keybox Option C (H2 may be unfalsifiable) | F11 (lines 167–171) |
| Lab-isolation iptables | F24 (lines 314–322) |
| Pos/neg controls (AVD, Genymotion) | F19 (lines 252–259) |
| Plan-Immutability observed | `AGENTS.md` rule 1 — this is a new file in `registration/`, not a modification of `plans/00–04`. |

---

Ready for human + statistician review and upload to OSF? Y/N
