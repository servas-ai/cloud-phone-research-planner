# Addendum 11 — Agentic Adversary Axis (Operator-Capability, Motoric Humanisation, Kernel-Hook, x402)

Date: 2026-05-15
Author: Claude Opus 4.7 (1M context), invoked via `cloud-phone-research` skill
Triggered by: Human-partner-supplied Gemini Deep Research bundle (2026-05-15) on Android stealth automation; background catalogued in `docs/research-notes/agentic-stealth-landscape-2026.md`
Status: **DRAFT-REV-1 — post-Round-1 panel (3/3 NEEDS_REVISION resolved inline 2026-05-15); awaiting human Y/N approval on §5 open questions before merge**
Plan-Immutability: this file does NOT modify `plans/00–04`, `plans/10`, `registration/osf-preregistration.md`, `docs/threat-model.md`, `docs/research-notes/ml-adversary-models.md`, `docs/research-notes/literature-extensions.md`, or `probes/inventory.yml`. It proposes specific changes for application after human approval.

---

## 1. Summary

The human partner supplied an external Deep-Research bundle (Gemini-CLI, 2026-05-15) cataloguing the 2026 Android stealth-automation ecosystem: Bare-Metal ARM cloud phones, agentic LLM-driven device control (AppAgent, AppAgentX, DroidRun, Ghost-in-the-droid), motoric humanisation via Bezier+Perlin (`vincentbavitz/bezmouse` algorithmic prior art), system spoofing (LSPosed, DeviceSpoofLab, PairIP bypass), kernel-level evasion (Zygisk-Next, Shamiko, SuSFS, Purifire/eBPF), keybox-injection arms race (TrickyStore, Integrity Box), and the x402 autonomous-mobile-proxy protocol.

Most of the bundle's content **maps to existing project elements** (see crosswalk in `docs/research-notes/agentic-stealth-landscape-2026.md` §2). Three items are net-new and warrant a Plan-Immutability-compliant patch:

1. **Operator-Capability axis** (O_A / O_B / O_C) — currently the threat model conflates "what the defender's inference model is" with "what the attacker uses to drive the device". Naming the axis lets us state that H1–H6 are conditional on a fixed operator capability.
2. **Kernel-Hook adversary class** (Purifire / eBPF / kprobe) — already implicitly handled by Probes #6 (TEE attestation) and #64 (syscall-latency histogram), but not named in the STRIDE / Adversary-Capability tables. Adding the name lets the paper claim probe-robustness against this adversary class.
3. **Two candidate probes** for a hypothetical future Round-3 OSF amendment:
   - `behavior.touch_kinematic_signature` — extends Probe #57; targets motoric humanisation.
   - `integrity.pairip_resident` — detects whether app integrity-tooling (PairIP `ContentProvider` family) has been disabled.

Neither probe is added by this addendum. They are surfaced as future-round candidates subject to the same feasibility pilot as Probe #75 (`osf-preregistration.md` §9 Amendment 2, CV < 30 %, Cohen's d > 0.8).

H6 (`plans/10-h6-adversarial-coevolution-addendum.md`) is NOT modified. The addendum proposes a §8 Threats-to-Validity clarification only (state explicitly that H6 measures equilibrium against a Detection-Capability adversary without kernel-hook capability and at fixed Operator-Capability). This is a textual clarification, not a design change, and does not require OSF amendment because the H6 design itself is unchanged.

The Legal-Gate (F21/F22/F23) is **NOT loosened**. TrickyStore / Integrity Box content is summarised descriptively, not operationally. The institutional-only split for F23 is preserved.

---

## 2. Research Conducted

| Tool | Source | Key finding |
|---|---|---|
| Human-supplied Gemini Deep-Research bundle | Gemini-CLI session, 2026-05-15 | ~70 URLs across agentic frameworks, motoric humanisation, kernel evasion, x402; full triage in `docs/research-notes/agentic-stealth-landscape-2026.md` §5 |
| `Read` of `docs/research-notes/ml-adversary-models.md` | Local | Round-2 F6 already defines L_AdvA/B/C on the **detector** side; Operator-Capability is genuinely missing |
| `Read` of `docs/research-notes/literature-extensions.md` | Local | He et al. USENIX'23 eBPF cross-container attack already cited; Roy Dipta 2024 frequency fingerprinting already cited — both relevant to Kernel-Hook adversary class |
| `Read` of `plans/10-h6-adversarial-coevolution-addendum.md` | Local | H6 mitigation-set M01–M08 contains no kernel-hook layer; H6 is implicitly conditioned on a non-kernel-hook adversary |
| `Read` of `probes/inventory.yml` (rank 50–60) | Local | Probe #57 `ui.touch_pressure` description mentions Bezier timing at severity=trace; Probe #59 `env.accessibility_services` becomes false-negative against vision-only ADB agents |

Explicit non-actions (per `cloud-phone-research` skill anti-rationalization table):
- Did **not** clone TrickyStore or Integrity Box repositories (manifest-only is sufficient for threat-model citation).
- Did **not** add any Magisk module to `stack/` or `experiments/`.
- Did **not** execute any Docker image.
- Did **not** propose probe additions to `probes/inventory.yml` in this addendum — only as future-round candidates.

---

## 3. Proposed Changes (do NOT apply until human Y/N)

### 3.1 PR-A — `docs/threat-model.md` — Adversary-Capability extension

**Change type:** append to existing "Akteure" / "STRIDE pro Vektor" sections; do NOT rewrite or reorder existing rows.

**Diff sketch (block to append after the current "Vertrauensanker" table):**

```markdown
## Adversary-Capability Decomposition (Round-3 refinement)

The Adversary axes introduced in Round-2 (`docs/research-notes/ml-adversary-models.md`
§5) are refined into three orthogonal sub-axes. **The L_AdvA/B/C definitions
themselves are NOT duplicated here — see `ml-adversary-models.md` §5 for the
canonical Detection-Capability content. This section adds the Operator and
Network sub-axes and the meta-frame only.**

| Sub-axis | Levels | Captures |
|---|---|---|
| Detection-Capability | L_AdvA / L_AdvB / L_AdvC | Defender's inference model (unchanged from Round-2; definitions in `ml-adversary-models.md` §5) |
| Operator-Capability  | O_A / O_B / O_C            | What drives the device (manual script / accessibility-LLM / vision-only-LLM-via-ADB) |
| Network-Capability   | N_A / N_B / N_C            | IP-sourcing capability (residential / mobile-manual / x402-autonomous) |

Operator-Capability is **categorical, not strictly ordinal**: O_C agents lose the
`env.accessibility_services` signal (Probe #59 — see Kernel-Hook table below)
but a careful O_B agent retains it. The axis labels rank capabilities by class
of mechanism, not by monotone strength against every probe.

The H1–H6 results are reported as conditional on a fixed Operator-Capability and
Network-Capability. The H6 Stackelberg game (`plans/10` §2.2) is defined over
Detection-Capability only; Operator and Network are external-validity dimensions.

## Kernel-Hook Adversary Class (Round-3 addition)

A Kernel-Hook adversary intercepts system-calls at kernel level (eBPF, kprobe,
KernelSU mount hiding, Purifire-class evasion engines). Effect: probes that read
from user-space `/proc/*`, `/sys/*`, `getprop`, or syscall return values can be
served forged data without user-space artefact.

| Probe | Robustness vs. Kernel-Hook adversary | Citation status |
|---|---|---|
| #1 build.product / #7 build.fingerprint / #9 build.hardware / #28 build.brand | **Spoofable** at kernel level | well-established |
| #14 SELinux status, #30 /proc/version, #67 cacerts diff | **Spoofable** at kernel level | well-established |
| #6 TEE / StrongBox Keystore Attestation | **Conjectured-robust** — externally rooted via TEE; *qualified by Kuhne et al. ETH "Aster" (Arm CCA, in `literature-extensions.md` §1 — author-anchored row, 2024) which documents TrustZone-to-CCA attestation gaps that a kernel-hook + TEE-coordinated adversary could exploit* | qualified |
| #64 runtime.syscall_latency_histogram (Round-1 F5) | **Conjectured-robust** — observes timing-side-channel divergence (Roy Dipta et al., EuroS&P 2024, in `literature-extensions.md` §1); *generalisation from x86 container-fingerprinting to ARM-Android kernel-hook detection is pending the F31 feasibility-pilot* (`docs/research-notes/literature-extensions.md` §6, Q3) | pending F31 |
| #71 runtime.binder_transaction_cost | **Conjectured-robust** — interface-level latency, but no published falsification attempt cited (Mao et al., USENIX'25 NASS, in `literature-extensions.md` §1, maps surface area only) | empirically unconfirmed |
| #59 env.accessibility_services (vs O_C operator) | **False-negative** against vision-only ADB-injection operators — claim is *architectural inference*; falsification test: deploy ghost-in-the-droid reference impl against ReDroid+#59; if #59 fires, claim refuted | inference, pending experiment |

The H6 mitigation-set M01–M08 (`plans/10` §4.1) does NOT include a kernel-hook
layer; the H6 equilibrium is therefore measured against a non-kernel-hook
adversary. This is a §8 Threats-to-Validity item (clarification only — see §3.4
below).
```

**Acceptance test:** the appended block does not modify any existing row or table heading in `docs/threat-model.md`. `git diff` shows only insertions.

**Citation-anchor convention (architecture-strategist A1).** All cross-file
references in this and subsequent sections use author+venue anchors
(e.g., "Roy Dipta et al., EuroS&P 2024, in `literature-extensions.md` §1"),
**never** numeric table-row indices, because the target table grows over time
and row indices are unstable.

### 3.2 PR-A — `docs/research-notes/literature-extensions.md` — citation rows

**Change type:** append rows to the existing "New Academic References (2022–2026)" table and the "New OSS Tools" table; do NOT renumber existing rows.

**Diff sketch (rows to append at the end of §1).** Before append: 27 entries
total. After append: 30 entries. The §1 closing line "Total: 27
academic/quasi-academic entries (filtered from larger candidate set)" must be
updated to "Total: 30…" — this single-token edit is the only in-place
modification permitted to `literature-extensions.md` in this PR (it is
metadata, not content). All three rows below carry verification labels per
architecture-strategist A1 / gap-analyst G8:

| Year | Venue | Title | Authors | URL | Relevance | Verification |
|---|---|---|---|---|---|---|
| 2025 | arXiv | To Unpack or Not to Unpack: Living with Packers to Enable Dynamic Analysis of Android Apps | author list TBD before merge | https://arxiv.org/abs/2509.16340 | Packer / RASP evasion — counter-defence literature for Kernel-Hook adversary class | **PENDING `web-reader` URL+author-list verification before merge** |
| 2024 | ResearchGate | BPFDex: Enabling Robust Android Apps Unpacking via Android Kernel | author list + DOI TBD before merge | DOI TBD | eBPF-based unpacking — kernel-level inspection prior art for §3.1 Kernel-Hook robustness claim | **PENDING DOI + author-list verification before merge; drop if not resolvable** |
| 2026 | vendor-protocol-spec (no academic anchor) | x402 Protocol Explained: How AI Agents Pay Onchain | Eco (vendor) | https://eco.com/x402-protocol | Network-Capability N_C citation; Discussion-section external-validity item | **Vendor-blog — flagged as such; academic primary citation pending** |

**Do NOT re-add (gap-analyst G9 — already present in `literature-extensions.md` §1):**
- He et al., "Cross Container Attacks: The Bewildered eBPF on Clouds," USENIX Security 2023 — already cited.
- Roy Dipta et al., "Dynamic Frequency-Based Fingerprinting Attacks against Modern Sandbox Environments," EuroS&P 2024 — already cited.

**Diff sketch (rows to append at the end of §2 OSS Tools).** Before append: 14
entries. After append: 21 entries. The §2 closing line "Total: 14 active OSS
tools meeting the 18-month freshness threshold…" must be updated to
"Total: 21…" — same single-token edit policy as §1 above.

| Name | Purpose | Layer / Probe | URL | License | Last commit | Note |
|---|---|---|---|---|---|---|
| TencentQQGYLab/AppAgent | Multimodal LLM-driven Android agent (operator-side prior art) | Discussion §Operator-Capability | https://github.com/TencentQQGYLab/AppAgent | Apache-2.0 | active 2024–2026 | — |
| AppAgentX | Evolving GUI agents on smartphones (operator-side prior art) | Discussion §Operator-Capability | https://appagentx.github.io | OSS | active 2026 | — |
| droidrun/mobilerun | LLM-driven Android automation (operator-side prior art) | Discussion §Operator-Capability | https://github.com/droidrun/mobilerun | OSS | active 2026 | — |
| ghost-in-the-droid/android-agent | Vision-only ADB-driven agent (O_C operator-capability prior art) | Discussion §Operator-Capability, §Probe-#59-degradation | https://github.com/ghost-in-the-droid/android-agent | OSS | active 2026 | — |
| vincentbavitz/bezmouse | Bezier-curve mouse-movement humanisation (algorithmic prior art for §3.5 motoric probe candidate) | candidate Probe #57 extension / `behavior.touch_kinematic_signature` | https://github.com/vincentbavitz/bezmouse | BSD-style | inactive (algorithmic-reference only — policy carve-out from §2 freshness rule) | **Math-not-code-health rationale; Lakatos-style citation** |
| nisrulz/sensey | Android gesture-detection thresholds (calibration prior art) | candidate Probe #57 extension | https://github.com/nisrulz/sensey | Apache-2.0 | active | — |
| jcrevoisier/human-behavior-simulation-kit | Velocity-profile humanisation (algorithmic prior art) | candidate Probe #57 extension | https://github.com/jcrevoisier/human-behavior-simulation-kit | OSS | active | — |

**Explicit non-additions** (kept out of the bibliography per F22 / F23 / §202c):
- TrickyStore, Integrity Box, Zygisk-Next, Shamiko, SuSFS, DeviceSpoofLab-Hooks — these are mitigation tooling; cited only descriptively in `docs/research-notes/agentic-stealth-landscape-2026.md` §5.3 with explicit Legal-Gate framing.

### 3.3 PR-A — `docs/research-notes/ml-adversary-models.md` — §5 table extension

**Change type:** append two rows to the "Adversary Capability Axis" table; do NOT modify the L_AdvA/B/C rows.

**Diff sketch:**

```markdown
| Axis | Level | Adversary Type | Detection Mechanism | Spoofable by SpoofStack? |
|---|---|---|---|---|
| Operator-Capability | O_A | Hand-scripted ADB / Accessibility | Probe #59 fires; Probe #57 shows roboticism | Out of scope for SpoofStack (operator-side) |
| Operator-Capability | O_B | Accessibility-tree-LLM agent (e.g. AppAgent) | Probe #59 fires; Probe #57 shows LLM-pace | Out of scope for SpoofStack (operator-side) |
| Operator-Capability | O_C | Vision-only ADB-injected LLM agent | Probe #59 silent (FN); Probe #57 informative iff motoric humanisation absent | Out of scope for SpoofStack (operator-side); affects probe-validity |
| Network-Capability | N_A | Static residential proxy | Probes #5, #61, #62, #63 unchanged | L6 |
| Network-Capability | N_B | Manually procured mobile (LTE) | Probes #5, #61, #62, #63 unchanged | L6 |
| Network-Capability | N_C | x402-autonomous per-request mobile rotation | Probes #5/#61/#62/#63 still observe device-side signatures; IP-reputation defence degrades | L6 + server-side (out of scope) |
```

### 3.4 PR-A — `plans/10-h6-adversarial-coevolution-addendum.md` — §8 clarification

**Change type:** append one row to the existing Threats-to-Validity table; do NOT modify existing rows.

**Diff sketch (append to §8 table):**

| Threat | Mitigation |
|---|---|
| **H6 Stackelberg game scope** | H6 measures equilibrium against a Detection-Capability adversary (L_AdvA/B/C) with **no kernel-hook capability** (M01–M08 contains no kernel-side mitigation) and at **fixed Operator-Capability** and **fixed Network-Capability** (`docs/threat-model.md` Round-3 Adversary-Capability Decomposition). The convergence floor δ\* is conditional on these. Adversaries with kernel-hook capability (Purifire-class) or stronger Operator/Network capability are out of scope of the H6 game and acknowledged as external-validity limits in the paper Discussion. |

**Note on H6 immutability:** the H6 addendum is itself in DRAFT-REV-2 awaiting statistician sign-off + human Y/N (`plans/10` §22). Appending one row to its §8 table is a textual clarification, not a design change to M, P_ext, K, or any pre-registered statistic. This clarification can land either:
- bundled into the same H6 application PR when the user approves H6, OR
- **separately as part of this Addendum 11's application PR** (recommended — see below).

**Recommendation (revised per architecture-strategist A4): apply separately.** Bundling creates cross-addendum coupling — Addendum 11's completion becomes partially blocked on Addendum 10's statistician sign-off (the actual gating constraint per `README.md`). The §3.4 row is textual only (no M / P_ext / K / threshold / selection-rule / prior change) and does not require an OSF amendment, so the bundling rationale ("single OSF timestamp") is null. Plan-Immutability applies to *approved* plans; `plans/10` is in DRAFT-REV-2 and not yet locked, so touching it from this addendum's PR is permitted.

**Sufficiency caveat (gap-analyst G4).** A single row appended to `plans/10` §8 may not be enough to scope-bound the H6 hypothesis statement in `plans/10` §3.1, where a reader of the hypothesis itself may miss the adversary-class scoping. The minimal additional fix is a **forward reference** in `plans/10` §3.1 of the form:

> *H6 measures equilibrium within adversary class M defined in §4.1; kernel-hook capability is explicitly out of scope and acknowledged in §8 (Round-3 row appended via Addendum 11).*

This forward reference is **still textual only** (does not modify M, P_ext, K, thresholds, selection rules, or priors) and falls within the same clarification-only envelope. Whether to include it is a Y/N item for the human partner (§5 Q3).

### 3.5 Candidate probes for future Round-3 OSF amendment (NOT applied by this addendum)

> **STATUS: NOT APPLIED — CANDIDATE ONLY (architecture-strategist A5).** The two
> sub-tables below have an inventory-entry-like shape; they are deliberately
> *not* probe-inventory additions. No rank number is pre-allocated.

These are surfaced for human-partner decision. Adding either probe requires a future OSF amendment + feasibility pilot (CV < 30 %, Cohen's d > 0.8 per `osf-preregistration.md` §9 Amendment 2). **No probe is added by this addendum.**

#### 3.5.1 `behavior.touch_kinematic_signature` (candidate)

| Field | Value |
|---|---|
| Proposed ID | TBD by future OSF amendment (do NOT pre-allocate a rank number here) |
| Category | `behavior` (new category) or extension of `ui` |
| Severity | high (against O_C-class agentic operator) |
| Android layer | framework + hardware |
| Description | Statistical test on MotionEvent stream: distance from quadratic-Bezier path, velocity profile (accel/decel symmetry), Perlin-jitter signature. Rejects null hypothesis "input came from organic human muscle". |
| Mitigation layer | not_spoofable in current SpoofStack M; partial via L5 motoric trace replay |
| Algorithmic prior art | `vincentbavitz/bezmouse` (math; Lakatos-style citation per A1 footnote), Human-Behavior-Simulation-Kit (velocity), Sensey (calibration) |
| Academic anchor | BehavioSec sensor-touch literature; Lievonen et al. arXiv 2403.03832 (already in `ml-adversary-models.md` §3) |
| Feasibility-pilot risk | Medium — requires lab-recorded baseline of human touch on ≥3 device models, comparable to Probe #24 FFT classifier (F14) |
| **IRB / DSGVO Art. 89 implication** | **Required (security-auditor RR-4 + gap-analyst G5).** Lab-baseline touch recordings from human participants constitute biometric personal data under DSGVO Art. 4(1) when linkable to known lab participants. The existing IRB application (`registration/irb-application.md`) covers "lab telemetry of own/university hardware, no user profiles, no accounts, no person-traces" — touch-kinematic recordings are NOT clearly within that scope. A supplemental IRB amendment + DSGVO Art. 89 research-privilege determination is required **before** the feasibility pilot. See F12 (`plans/05` line 173) and `plans/09-f12-irb-application-addendum.md`. |

#### 3.5.2 `integrity.pairip_resident` (candidate)

| Field | Value |
|---|---|
| Proposed ID | TBD by future OSF amendment (do NOT pre-allocate a rank number here) |
| Category | `integrity` |
| Severity | medium |
| Android layer | application + framework |
| Description | Detects whether `com.pairip.licensecheck` ContentProvider and sibling Activities present in apps that ship them are functionally responsive vs. surgically disabled. Meta-detection of attacker-side bypass. |
| Mitigation layer | L4 |
| Feasibility-pilot risk | Medium — requires lab-installed reference app with PairIP enabled |
| IRB / DSGVO implication | None (no human-subjects data) |

#### 3.5.3 `runtime.adb_uinput_source` (candidate — surfaced by gap-analyst G2)

| Field | Value |
|---|---|
| Proposed ID | TBD by future OSF amendment |
| Category | `runtime` |
| Severity | high (against O_C-class agentic operator that bypasses `env.accessibility_services`) |
| Android layer | kernel + framework |
| Description | Detect origin of input events via PID/UID of the `/dev/uinput` writer; organic user input originates from the framework's `system_server` while ADB-injected events originate from the `shell` user / `adbd` process. Counterfactual probe that recovers detection coverage that Probe #59 loses against vision-only ADB agents. |
| Mitigation layer | L4 (runtime hiding) + Kernel-Hook (against the strongest adversary class) |
| Feasibility-pilot risk | Low — UID/PID inspection is standard Android Framework API surface |
| IRB / DSGVO implication | None |

**Process gate (revised).** Adding any of the three candidates above requires:
0. **IRB / DSGVO pre-assessment** (security-auditor RR-4): confirm whether the
   candidate involves human-subjects data. For §3.5.1, supplemental IRB
   amendment + DSGVO Art. 89 determination is required and must be applied for
   before step 1. For §3.5.2 and §3.5.3, this step is N/A.
1. Human-partner approval of this addendum (Y on §6).
2. Round-3 OSF amendment with timestamped probe spec.
3. Feasibility pilot (`osf-preregistration.md` §9 Amendment 2) on C0_real (N=10) + C1_L0a (N=10).
4. Inclusion in a **new** P_ext set for a hypothetical H7 / H6.1 round — NOT injected into the locked H6 P_ext.

### 3.7 Cascade impact on existing F-findings (gap-analyst G10)

The proposed changes do NOT modify any existing F-finding's correctness, but
they do alter the scope-condition under which several findings hold. Explicit
per-finding cascade trace:

| Finding | Cascade implication |
|---|---|
| **F6** (ML-Adversary L_AdvA/B/C) | If §3.1 is applied, the L_AdvB feature vector is now operator-conditional: probes that false-negative against O_C (notably #59) cannot enter the L_AdvB training set without an Operator-Capability covariate. Required follow-up: F6 corrective in `ml-adversary-models.md` §5 to note the Operator-Capability conditioning. Not an invalidation of F6 — a clarification. |
| **F14** (FFT-Classifier on accel/gyro) | Motoric humanisation (Bezier+Perlin) perturbs the second derivative of position, which couples weakly to accelerometer signal via hand-grip dynamics. F14's classifier may need to handle "agentic-driven-device-on-table" as a covariate class, distinct from "human-held-device". Required follow-up: F14 corrective in `plans/01-detectorlab.md` Probe #24 spec — note this *only* if §3.5.1 motoric probe is ever approved. |
| **F23** (institutional-only reproducibility-pack) | F23 unchanged. The §3.2 commercial-vendor naming (GeeLark, RedFinger, LDCloud, DuoPlus, BitCloudPhone — pending Q6 approval) is at the threat-model citation level and below the §202c threshold, per security-auditor §6 sign-off. |
| **F25** (sensor-trace DSGVO) | The motoric probe candidate §3.5.1 creates an F25-adjacent obligation: lab-recorded touch baselines from human participants are biometric personal data under DSGVO Art. 4(1). The §3.5.1 process-gate step 0 (IRB/DSGVO pre-assessment) covers this directly. |
| **F31** (CPU-frequency feasibility pilot) | §3.1 Kernel-Hook robustness claim for Probe #64 (`runtime.syscall_latency_histogram`) is downgraded to "Conjectured-robust, pending F31" per gap-analyst G3. F31's feasibility pilot becomes the empirical anchor for the Kernel-Hook robustness claim. |
| All other F-findings | No cascade impact. |

### 3.8 PR-B — `docs/research-notes/agentic-stealth-landscape-2026.md`

This file is the background research note. It is committed alongside this addendum (PR-A is the threat-model / lit-extensions / ml-adversary-models / plans-10-§8 patches; PR-B is the standalone note). Both PRs are independent (no blocking dependency) but should be applied as a single human-approved batch for atomic citability.

---

## 4. What this addendum explicitly does NOT change

| Constraint | Compliance |
|---|---|
| `plans/00–04` immutability | ✓ no edits proposed |
| `plans/10` (H6) — design immutable | ✓ only §8 Threats-to-Validity clarification appended (textual; no M / P_ext / K change) |
| `registration/osf-preregistration.md` | ✓ no edits proposed in this PR; candidate probes (§3.5) deferred to future amendment |
| `probes/inventory.yml` v1.0 lock | ✓ no edits proposed; candidate probes named only |
| `stack/layers.md` | ✓ no edits proposed |
| `experiments/coevolution/SPEC.md` / `mitigation_priors.csv` | ✓ no edits proposed |
| F21 privileged Docker | ✓ unchanged |
| F22 keybox provenance | ✓ unchanged; TrickyStore / Integrity Box content is descriptive only |
| F23 institutional-only split | ✓ unchanged; no public-pack content additions touch the institutional side |
| Scope-Lock (no live platforms) | ✓ agentic frameworks named as adversary-side prior art, not as test infrastructure |
| §202c StGB safe-harbour | ✓ everything is threat-model categorisation, not workflow |
| EU 2021/821 dual-use | ✓ defensive research framing preserved |

---

## 5. Open Questions for Human Partner

1. **Operator-Capability axis scope:** apply as a new section in `docs/threat-model.md` (proposed §3.1 above), or only as a Discussion-section item in the eventual paper without a planning artifact change? Recommendation: apply (low cost, high external-validity payoff).
2. **Kernel-Hook adversary class naming:** apply as proposed §3.1, or merge into existing L_AdvA/B/C rows? Recommendation: separate axis — Kernel-Hook is orthogonal to Detection-Capability (a rule-based defender on a kernel-hooked device is still rule-based).
3. **H6 §3.1 forward reference (gap-analyst G4):** in addition to the §8 row append, add a forward reference in `plans/10` §3.1 (hypothesis statement) bounding H6 by adversary-class M? Recommendation: yes — single textual addition, removes scope-ambiguity in the hypothesis itself.
4. **H6 §3.4 bundling decision (architecture-strategist A4):** apply with the H6 approval PR or as a separate PR with this Addendum 11? **Recommendation revised to: separate PR**, since the clarification is textual and does not require OSF amendment, and bundling creates cross-addendum coupling.
5. **Candidate probes (§3.5) — defer to Round-3 OSF amendment or pre-register now?** Recommendation: defer. The current OSF lock is conservative; adding probes without feasibility pilots inflates RDFs. *Note: §3.5.1 motoric probe additionally requires IRB / DSGVO Art. 89 pre-assessment per security-auditor RR-4.*
6. **`vincentbavitz/bezmouse` as algorithmic prior art:** the project is BSD-style but inactive. Cite at the level of "math / algorithm reference impl" (Lakatos-style — the math is what matters, not the codebase health). OK? Recommendation: yes — labelled as "inactive (algorithmic-reference only — policy carve-out)" in the diff.
7. **Cloud-phone vendor naming in `literature-extensions.md`:** include GeeLark / RedFinger / LDCloud / DuoPlus / BitCloudPhone by name in the External-Validity citation row? Recommendation: yes — they are commercial existence proofs, and naming them is below the §202c / Scope-Lock threshold per security-auditor §6 sign-off. **If Y, a corresponding diff row must be drafted in §3.2 (security-auditor RR-5).**
8. **x402 / Network-Capability axis:** the protocol is genuinely 2026-fresh and lightly cited. Should we delay the row addition until a primary academic citation exists, or accept the eco.com / proxies.sx vendor-blog citations as a placeholder? Recommendation: accept as placeholder, label as "vendor-protocol-spec (no academic anchor)" per the diff.
9. **Operator-Capability non-monotonicity / O_D placeholder (gap-analyst G1):** the axis is categorical, not strictly ordinal (O_C loses Probe #59 that O_B retains). Should we introduce an O_D level for "hybrid / RL-on-LLM" agents that may emerge as AppAgentX-style evolution continues? Recommendation: not yet — O_D adds RDF without empirical anchor; defer to a future round when a reference O_D implementation exists.
10. **Fleet-Capability axis (gap-analyst G6):** introduce a fourth sub-axis F_A/B/C for single-instance / small-fleet / industrial-fleet adversaries (orthogonal to Detection/Operator/Network)? Recommendation: defer to Discussion-section only — fleet-coordination affects server-side adversaries which are explicitly out of scope per `ml-adversary-models.md` §4.
11. **Federated-defender countermove paragraph (gap-analyst G7):** add a paragraph to §3.1 noting that fleet-coordinated attackers create graph-detectable structure exploitable by federated defenders (cross-reference `ml-adversary-models.md` C6, C10)? Recommendation: yes if Q10 is approved; defer if Q10 is deferred.
12. **F-finding registration (gap-analyst G11):** retroactively register the new concepts in this addendum as named findings — F42 (Operator-Capability axis missing from Round-1/2), F43 (Kernel-Hook adversary class unnamed), F44 (Fleet-Capability axis missing — open)? Recommendation: yes — preserves traceability convention and provides anchor points for future cascade tracking.
13. **Citation verification gate (gap-analyst G8):** confirm the reviewer-checklist item that every proposed citation URL is fetched via `web-reader` and content-matched before merge? The arXiv 2509.16340 author list and BPFDex DOI must resolve, or those rows must be dropped from the PR.

---

## 6. Reviewer-Validation Required Before Merge

- [x] Multi-reviewer round, ≥ 2 reviewers (Round-1: 3 reviewers completed 2026-05-15; see §8)
- [x] Plan-Immutability check: only diff lines are inserts; running-total updates in `literature-extensions.md` §1/§2 documented as metadata-only edit (architecture-strategist A2)
- [x] Legal-Gate cross-check: F21 / F22 / F23 unchanged (security-auditor sign-off §8 row 2); TrickyStore + Integrity Box cited descriptively only; no SpoofStack content additions
- [x] Scope-Lock check: no live-platform references; agentic frameworks named as prior-art; GoLogin / Multilogin row carries explicit "not a test target" parenthetical (security-auditor RR-3)
- [x] OSF impact check: no OSF amendment required for §3.1–§3.4 (clarifications + literature); §3.5 candidate probes explicitly deferred to future amendment with feasibility pilot **AND** IRB/DSGVO pre-assessment for §3.5.1 (security-auditor RR-4)
- [x] H6 coherence check: §3.4 clarification does NOT change M, P_ext, K, thresholds, selection rules, or priors — confirmed textual only; §3.4 recommendation flipped to "apply separately" (architecture-strategist A4)
- [x] §202c-safe-harbour check: all citations are at threat-model abstraction level, not at tool-execution / recipe level (security-auditor §3 walkthrough)
- [x] EU 2021/821 dual-use check: aligned with `docs/ethics-and-scope.md` existing framing
- [ ] **Citation verification** (gap-analyst G8): every proposed citation URL fetched via `web-reader` and content-matched before merge. arXiv 2509.16340 and BPFDex must resolve, or those rows must be dropped.
- [ ] **Human-partner Y/N on §5 open questions** — required before any commit
- [ ] (Optional) 2-reviewer sanity round (architecture + security) on DRAFT-REV-1 — recommended but non-blocking

---

## 7. Reviewer-Panel Plan (≥ 2 parallel, per skill workflow Step 4)

| # | Reviewer | Focus |
|---|---|---|
| 1 | `architecture-strategist` (Claude subagent) | Plan-coherence with `plans/00–10`; Operator-Capability axis placement; H6 §8 bundling decision |
| 2 | `security-auditor` (Claude subagent) | F21/F22/F23 compliance; §202c / dual-use abstraction level; TrickyStore / Integrity Box descriptive vs operational line |
| 3 (optional) | `gap-analyst` (Claude subagent) | Missing implications, edge cases, future-round consequences |
| 4 (optional) | Gemini-CLI sanity round | External methodology / completeness, since Gemini supplied the source bundle (avoid circularity by asking Gemini to grade the addendum, not the bundle) |

Recommended minimum: panel 1 + 2 (architecture + security). Optional escalation to panel 1+2+3 if the human partner wants a fuller surface-area sweep.

---

## 8. Reviewer Feedback (Round-1 panel completed 2026-05-15)

### 8.1 Verdict matrix

| # | Reviewer | Verdict | Headline |
|---|---|---|---|
| 1 | architecture-strategist | **NEEDS_REVISION** (minor; structurally sound, mechanically leaky) | 5 findings: cross-file numeric row anchors (A1), running-total drift (A2), L_AdvA/B/C non-duplication marker (A3), H6 §3.4 bundling flip (A4), §3.5 NOT APPLIED callout + drop rank pre-allocation (A5). Architectural debt: 0. APPROVABLE after revision. |
| 2 | security-auditor | **NEEDS_REVISION** (5 local annotation additions; structural posture sound) | F21/F22/F23 all UNCHANGED. 5 RRs: §2.6 keybox "private" clarification (RR-1), §2.4 detector-side framing (RR-2), §2.5 Scope-Lock parenthetical (RR-3), §3.5.1 IRB/DSGVO step 0 (RR-4), §3.2 vendor-naming diff row contingent on Q7 (RR-5). Would sign off after RR-1..RR-4 applied. |
| 3 | gap-analyst | **MED-HIGH gap density** (~12 substantive gaps; none blocking) | G1 non-monotone Operator axis, G2 Probe #59 inferred-not-validated, G3 #6/#64/#71 robustness under-cited, G4 H6 §3.1 forward-reference insufficiency, G5 motoric probe IRB flag, G6 fleet-axis missing, G7 federated defender, G8 citation hygiene, G9 duplicate-citation warnings, G10 F6/F14/F23/F25 cascade trace, G11 F42–F44 finding registration, G12 open-Q completeness. |

**Unanimous: 3/3 NEEDS_REVISION. 0 BLOCK. 0 PASS. All findings are textual / annotation / mechanical — no design change required.**

### 8.2 Revision log (applied 2026-05-15, post-Round-1 panel)

| # | Finding | Severity | File / Section edited | What changed |
|---|---|---|---|---|
| 1 | A1 brittle row-number anchors | HIGH | addendum §3.1 (threat-model diff) + new "Citation-anchor convention" footnote | Replaced "row 22" / numeric-line references with author+venue anchors ("Roy Dipta et al., EuroS&P 2024, in `literature-extensions.md` §1"). Added explicit convention note. |
| 2 | A2 running-total drift | MED | addendum §3.2 | Explicitly note 27→30 (§1) and 14→21 (§2) total-line update as the single permitted in-place edit; characterised as metadata, not content. |
| 3 | A3 L_AdvA/B/C duplication risk | MED | addendum §3.1 (threat-model diff) | Added "The L_AdvA/B/C definitions themselves are NOT duplicated here — see `ml-adversary-models.md` §5 for the canonical Detection-Capability content" non-duplication marker. |
| 4 | A4 H6 §3.4 bundling | MED | addendum §3.4 + §5 Q4 | Flipped recommendation to "apply separately"; rationale: bundling creates cross-addendum coupling and the row is textual-only so no OSF amendment required. |
| 5 | A5 §3.5 callout + rank pre-allocation | MED | addendum §3.5 | Added "STATUS: NOT APPLIED — CANDIDATE ONLY" callout; replaced "rank: 87/88" with "TBD by future OSF amendment". |
| 6 | RR-1 keybox "private" not F22-criterion | MED | research-note §2.6 | Appended F22-clarification quote-block: "neither 'private' nor 'uncompromised' status is a legal provenance criterion under F22; only own-device TEE extraction or written manufacturer permission qualifies". |
| 7 | RR-2 motoric techniques detector-side framing | LOW-MED | research-note §2.4 | Prepended one-paragraph quote-block making the detector-side purpose explicit before the four-bullet list. |
| 8 | RR-3 Scope-Lock parenthetical on GoLogin row | LOW | research-note §2.5 | Inserted "(not a test target; named only as adversary-context existence proof)" into the GoLogin Orbita / Multilogin Mimic row. |
| 9 | RR-4 / G5 IRB/DSGVO step 0 | MED | addendum §3.5.1 + §3.5 process gate | Added "IRB / DSGVO Art. 89 implication" row to §3.5.1 candidate-probe table; added Step 0 (IRB/DSGVO pre-assessment) to process gate; cross-reference F12 + `plans/09`. |
| 10 | RR-5 vendor-naming diff row | LOW | addendum §5 Q7 + §3.7 | §5 Q7 now explicitly notes "If Y, a corresponding diff row must be drafted in §3.2"; §3.7 F23 row confirms the §202c sign-off path. |
| 11 | G3 #6/#64/#71 robustness under-cited | HIGH | addendum §3.1 Kernel-Hook table | Downgraded "Robust" to "Conjectured-robust" with citation status column; qualified #6 against Kuhne et al. Aster 2024; qualified #64 with F31 pending feasibility; flagged #71 as empirically unconfirmed. |
| 12 | G2 #59 degradation inferred-not-validated | HIGH | addendum §3.1 Kernel-Hook table + §3.5.3 new candidate | Reframed #59 row as "False-negative — claim is *architectural inference*"; added falsification test; introduced §3.5.3 `runtime.adb_uinput_source` as counterfactual recovery probe. |
| 13 | G4 H6 §3.1 forward-reference | MED | addendum §3.4 + §5 Q3 | Added "Sufficiency caveat" paragraph proposing forward-reference text in `plans/10` §3.1; gated on §5 Q3 human-partner Y/N. |
| 14 | G10 F6/F14/F23/F25 cascade trace | HIGH | addendum new §3.7 | Added §3.7 "Cascade impact on existing F-findings" with explicit per-finding statements for F6, F14, F23, F25, F31. |
| 15 | G11 F-finding registration | MED | addendum §5 Q12 | Surfaced F42 (Operator axis), F43 (Kernel-Hook class), F44 (Fleet-axis open) as Y/N registration item. |
| 16 | G12 open-question completeness | LOW | addendum §5 | Expanded from 7 to 13 open questions (added Q3, Q4, Q5 IRB note, Q9, Q10, Q11, Q12, Q13). |
| 17 | G8 citation hygiene | LOW-MED | addendum §3.2 | Added per-row verification labels: "PENDING `web-reader` URL+author-list verification before merge"; "drop if not resolvable"; bezmouse labelled "inactive (algorithmic-reference only — policy carve-out)". Added §6 reviewer-checklist item for citation verification. |
| 18 | G9 duplicate citation warning | LOW | addendum §3.2 | Added explicit "Do NOT re-add (already present)" callout for He et al. USENIX'23 and Roy Dipta EuroS&P'24. |

### 8.3 Deferred to human-partner decision (open in §5)

The following findings could not be resolved by AI alone and are surfaced as
open questions Q9–Q13 for human-partner adjudication:

- **G1 O_D placeholder** (§5 Q9): recommended defer (adds RDF without empirical anchor).
- **G6 Fleet-Capability axis** (§5 Q10): recommended defer to Discussion-section only.
- **G7 Federated-defender paragraph** (§5 Q11): conditional on Q10.
- **F42/F43/F44 registration** (§5 Q12): recommended yes.
- **Citation verification gate enforcement** (§5 Q13): mandatory before merge.

### 8.4 Post-revision verdict

After applying items 1–18 in §8.2, the addendum status moves from
DRAFT → DRAFT-REV-1 (post-Round-1 panel). All HIGH-severity findings (A1, G2,
G3, G10) are RESOLVED in the addendum text or the candidate-probe surface.
All MED-severity mechanical findings are RESOLVED. The remaining items are
all human-partner Y/N decisions (§5), not reviewer-driven blocks.

Re-review by a 2-reviewer sanity round (architecture + security) is
recommended after the human Y/N answers, but is **not blocking** for the
human approval gate itself.

---

## 9. Application Plan (after explicit human Y)

If and only if the human partner approves with Y:

1. PR-A — apply §3.1 to `docs/threat-model.md`, §3.2 to `docs/research-notes/literature-extensions.md`, §3.3 to `docs/research-notes/ml-adversary-models.md`. Each as APPEND-ONLY edits (no in-place rewrites).
2. §3.4 (H6 §8 clarification) — held until the H6 approval PR bundles it (recommended), or applied separately if the user prefers a separate timestamp.
3. PR-B — commit `docs/research-notes/agentic-stealth-landscape-2026.md` as-is.
4. README.md status-badge update: increment Round counter if the user considers this a Round-3-initiating change; otherwise label as "addendum 11 applied, Round-3 still pending statistician sign-off on H6".
5. Commit message format (per `cloud-phone-research` skill Step 6):
   - PR-A: `addendum(R3-op-capability): operator/kernel-hook adversary axes [reviewers: A+S]`
   - PR-B: `research-note(agentic-stealth-landscape-2026): bundle triage from gemini deep research`
6. Mark this addendum status: `APPLIED` with merge-commit hashes.

---

## 10. Stop

Per `cloud-phone-research` skill Step 5 — no commit, no push, no application until the panel (§7) returns verdicts AND the human partner says Y.

Approve to run the reviewer panel? **Y/N**
