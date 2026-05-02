# Round-2 Validation Feedback

Date: 2026-05-03
Reviewer: Gemini 3 Pro Preview (gemini-cli, headless)
Inputs: 4 Round-1.5 subagent artifacts (see plans/05-validation-feedback.md context)
Codex GPT-5.5: not available (usage limit until 2026-05-09)
Additional Claude subagents: deferred to Round-2.5 if NEEDS_REVISION items remain after legal-clearance

> Plan-Immutability respected: this is an addendum to plans/05-validation-feedback.md, not an overwrite.

---

## Working command (verified)

```bash
cd /home/coder/vk-repos/cloud-phone-research-planner
GEMINI_CLI_TRUST_WORKSPACE=true gemini -p "$(cat /tmp/prompt.md)" \
  --skip-trust --approval-mode plan -m gemini-3-pro-preview
```

The `[ERROR] [IDEClient] Directory mismatch` warning is non-fatal — output is still produced correctly. Logged for future reference.

---

## Reviewer Verdict

**Final Round-2 Verdict: NEEDS_REVISION**

Justification (verbatim from Gemini):
> "While the theoretical expansion in the ML adversary model and the strict architectural safeguards in the runner specification are unequivocally publication-grade for USENIX/NDSS, the artifact set fails the project's most critical gate: legal safety. Linking to active DRM circumvention tools (KeyDive) in the literature review creates an unacceptable §202c StGB risk that compromises the IRB application. Additionally, the need for an ML 'coherence metric' is a major methodological pivot that must be formalized into the Experiment Matrix before the threat model can be considered complete. Strip the legally hazardous citations and define the mathematical coherence metric to achieve a PASS."

---

## Per-Artifact Verdict

| # | Artifact | Verdict | Ready to merge? |
|---|---|---|---|
| 1 | `docs/research-notes/ml-adversary-models.md` | PASS | Y |
| 2 | `docs/research-notes/literature-extensions.md` | NEEDS_REVISION | **N** (legal blocker) |
| 3 | `experiments/runner/SPEC.md` | PASS | Y |
| 4 | `prompts/00-README.md` + 01-03 | PASS | Y |

### Artifact 1: ML-Adversary
- **Strongest contribution:** Formal Adversary Capability Axis (L_AdvA → L_AdvC) + signal cross-correlation patterns C1–C9. Maps L_AdvB (XGBoost) cleanly to SpoofStack mitigation layers.
- **Weakness:** Open Question 2 (real-device sensor-trace baseline) risks IRB scope creep. Section 6 (coherence metric) shifts statistical analysis without providing the concrete mathematical definition.

### Artifact 2: Literature-Extensions
- **Strongest contribution:** Rigorous mapping of 27 academic papers + 14 OSS tools to probe gaps #61–#74. Identifying Roy Dipta 2024 CPU-frequency side-channel → proposed Probe #75 is top-tier.
- **🔴 Blocker:** Citation of `hyugogirubato/KeyDive` (active Widevine L3 extraction tool). Despite "READ-ONLY ACADEMIC REFERENCE" disclaimer, citing an active DRM circumvention repo in German academic work conflicts directly with F22/F23 strictures and constitutes acute §202c StGB / dual-use legal risk.

### Artifact 3: Orchestrator-SPEC
- **Strongest contribution:** Architectural enforcement of Legal-Gate F21 — hard-coded rejection of `privileged: true`, enforced `seccomp` and `cap_drop: [ALL]` at orchestrator layer. Structural prevention beats policy-only.
- **Weakness:** Section 10 hardcodes 4-containers-per-binder concurrency without empirical validation on target ARM64 host. Risk of race conditions / Binder IPC starvation during Sprint C/D.

### Artifact 4: Prompts
- **Strongest contribution:** 5-layer prompt architecture + Plan-Immutability/Legal-Gate enforcement bulletproofs the agent workflow against hallucination and scope drift.
- **Weakness:** Procedural orchestrators only — does not technically advance the academic core or address F1–F30 directly.

---

## Cross-Artifact Consistency

One notable friction point identified:

- **ML Evaluation Isolation conflict:** `ml-adversary-models.md` Open Question 5 speculates about a "mini-classifier" inside DetectorLab. But `experiments/runner/SPEC.md` §9 strictly expects static `v1-schema.json` output for post-run aggregation. Implementing on-device XGBoost would violate the runner's pure data-extraction paradigm and muddy Track A (measurement) ↔ Data-Analysis boundary.

**Resolution (proposed):** ML-classifier runs offline on the aggregated probe-vector data, not on-device. Update ml-adversary-models.md Open Question 5.

---

## Findings Marked RESOLVED by Round-2 Artifacts

| Finding | Resolved by | Notes |
|---|---|---|
| F4 (Network-Probes unvollständig) | `literature-extensions.md` (JA4, mercury, JA4H identified) | Pending legal-cleanup of artifact |
| F5 (Probe-Inventar Lücken) | `literature-extensions.md` (#64–#74 reference implementations mapped) | Pending legal-cleanup |
| F6 (ML-Adversary fehlt) | `ml-adversary-models.md` (3-level axis + STRIDE × Adv matrix) | Resolved |
| F16 (Automation-Orchestrator fehlt) | `runner/SPEC.md` | Resolved |
| F20 (Container-Update-Drift) | `runner/SPEC.md` deterministic image hashing + BLAKE3 run-IDs | Resolved |
| F21 (Privileged Docker) | `runner/SPEC.md` container-lifecycle preflight | Resolved architecturally |

**6 of 30 findings resolved in Round 2.** Remaining 24 still open, with F22/F23 still requiring human legal clearance.

---

## New Risks Introduced (Round 2)

1. **Legal Attack Surface (§202c StGB):** KeyDive citation in literature-extensions creates severe legal risk. Conflicts directly with the project's cautious Keybox-provenance stance (F22). **Must be stripped before any merge.**

2. **Methodological Scope Creep (ML Coherence):** ml-adversary-models reveals L1/L2 spoofing fails under L_AdvB without cross-correlation coherence-metrics. Requires:
   - New pre-registered hypothesis **H5** (covariance-based detection-resistance)
   - New statistical approach for cross-probe covariance
   - Expansion of Experiment Matrix
   → Surfaces as new Finding **F32** (methodological).

3. **Hardware Scope Creep (Probe #75):** CPU-frequency side-channel on bare-metal ARM64 is experimental. Risks delaying Sprint 1 if sensor proves too noisy outside x86 (Roy Dipta 2024 measured x86 primarily).
   → Surfaces as new Finding **F33** (technical-feasibility).

---

## Required Actions Before PASS (Round 2.5)

### A1 — Legal-Cleanup (BLOCKING)
- File: `docs/research-notes/literature-extensions.md`
- Change: remove KeyDive entry from "New OSS Tools" table; replace with citation of the underlying Widevine paper (Cambridge 2025 KeyDroid) without linking to the extraction tool itself
- Owner: human maintainer (legal judgment call)
- Effort: 5 min

### A2 — Coherence-Metric Definition (BLOCKING for paper-grade)
- File: new `docs/research-notes/coherence-metric-spec.md`
- Change: define the mathematical coherence metric mentioned in ml-adversary-models §6 (covariance over probe-vector? Mahalanobis distance? Mutual-information matrix?)
- Owner: human + statistician
- Effort: 1–2 days

### A3 — Cross-Artifact Consistency (RECOMMENDED)
- File: `docs/research-notes/ml-adversary-models.md` Open Question 5
- Change: clarify that ML-classifier runs offline on aggregated probe-vectors, not on-device
- Owner: AI agent (low-risk addendum)
- Effort: 10 min

### A4 — Probe #75 Feasibility-Pilot (RECOMMENDED)
- File: new `experiments/feasibility/probe-75-pilot.md`
- Change: 2-day pilot study on ARM64 host before committing Probe #75 to inventory
- Owner: human
- Effort: 2 days lab-time

### A5 — Document Findings F31, F32, F33 (HOUSEKEEPING)
- File: `plans/07-round-2-feedback.md` (this file) — already done above
- Add to next addendum master-list
- Owner: AI agent
- Effort: 0 min (this commit)

---

## Reviewer Limitations Acknowledged

This Round-2 was **single-reviewer** (Gemini-only). Round 2.5 should re-validate after A1–A4 with a 3-reviewer panel:
- Gemini-CLI (re-run)
- security-auditor Claude subagent (re-check legal cleanup A1)
- architecture-strategist Claude subagent (validate A2 mathematical formalism)

Codex GPT-5.5 to be added when usage limit resets (2026-05-09).

---

## Status Update for README badges

After A1 completes:
- `validation-round-2-prep` → `validation-round-2`
- 6 of 30 findings now resolved → status: `6/30 resolved` badge

After A1+A2 complete + Round-2.5 multi-reviewer:
- Verdict: PASS (expected, conditional on legal cleanup)
- Phase 0 unblocks for hardware procurement (parallel to legal-clearance)
