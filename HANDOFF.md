# Agent Handoff Document

> **For the next AI agent (Claude / Codex / Gemini / Cursor / Aider / OpenCode / OME / generic) picking up this work.**
> Last updated: 2026-05-03 by Claude Opus 4.7 (1M context).
> Last commit: `eb29b6d` (Round-2.5 fixes pushed to origin/main).

---

## TL;DR — 30-second briefing

You are entering a **German academic security-research planner** at `https://github.com/servas-ai/cloud-phone-research-planner` (public). The project plans a 12-week empirical evaluation of Android container detection resistance (ReDroid 12 + DetectorLab as Track A vs. SpoofStack L0a–L6 as Track B). The repo is at `validation-round-2.5: PASS-pending-statistician-sign-off`. Three things are blocked by university legal review (F21/F22/F23) and cannot be progressed by any AI agent. Twelve open findings remain in Round-3+ queue. Plan-Immutability is absolute.

**First commands you should run:**

```bash
cd /home/coder/vk-repos/cloud-phone-research-planner
git pull --ff-only
cat AGENTS.md         # hard rules
cat README.md         # current state, badges, status
cat ROADMAP.md        # what's done, what's next, decision log
cat plans/05-validation-feedback.md   # Round 1 findings F1-F30
cat plans/07-round-2-feedback.md      # Round 2 findings + actions
cat plans/08-round-2-5-feedback.md    # Round 2.5 findings F34-F41 + final verdict
ls .claude/skills/cloud-phone-research/SKILL.md   # the workflow you must follow
ls prompts/00-README.md   # 3 ready-to-paste prompts for common tasks
```

**Hard rules (non-negotiable, see AGENTS.md for full):**

1. **Plan-Immutability** — `plans/00-master-plan.md` through `plans/04-deliverables.md` are immutable. Use addenda (`plans/06+`, `plans/09+`).
2. **Legal-Gate** — F21 / F22 / F23 are human-only. Do not draft answers. Open a `legal-blocked` issue and stop.
3. **Scope-Lock** — No live-platform code (TikTok / Instagram / Snapchat / Roblox / banking / etc.). Out of scope, period.
4. **Reproducibility split** — Public repo never holds keyboxes, exact module-version manifests, or full image hashes. Institutional-only material stays out.
5. **Multi-Reviewer-Discipline** — Major addenda go through ≥2 reviewer pass (Gemini-CLI + Claude subagents). Use `prompts/03-validate-round.md`.

---

## Project north-star

**Research question:**
> Welche Android-Detection-Methoden (Build-Properties, Hardware-Attestation, Sensor-Signaturen, Netzwerk-Fingerprints) bleiben robust gegen Container-basierte Virtualisierung mit ARM-nativen Cloud-Phone-Stacks (ReDroid 12), und welche lassen sich layer-weise schliessen?

**Endprodukt:** Detection-Resistance-Heatmap (75+ Probes × 8 Stack-Konfigurationen × N=60) + Paper bei USENIX Security / ACM CCS / NDSS / IEEE S&P / EuroS&P / WOOT / DIMVA.

**Hypotheses:** H1 (Build/ID-Probes resolvable by L1+L2), H2 (Hardware-Attestation hardest, only L3+keybox), H3 (Sensor-FFT > 0.7 confidence even after VirtualSensor), H4 (IP/ASN strongest single vector), H5 (added Round 2: cross-probe coherence-metric monotone L_AdvA → L_AdvB → L_AdvC).

---

## What is DONE (chronological)

### Plans v1 (immutable)
- `plans/00-master-plan.md` — 12-Wochen-Phasenplan, 4 Hypothesen, Risiken, Erfolgskriterien
- `plans/01-detectorlab.md` — Track A: Kotlin-App Architektur, 5 Sprints, Validierung
- `plans/02-spoofstack.md` — Track B: ReDroid 12 + L0–L6 Layers, Konflikt-Vermeidung
- `plans/03-experiment-matrix.md` — N=30, McNemar, harte Probes
- `plans/04-deliverables.md` — DetectorLab OSS, Paper, Reproducibility-Pack, Thesis-Mapping

### Validation Rounds
- `plans/05-validation-feedback.md` — **Round 1**, 4 Reviewer (Gemini + 3 Claude subagents), 30 Findings F1–F30, all NEEDS_REVISION
- `plans/07-round-2-feedback.md` — **Round 2**, Gemini + verifizierter CLI-Pattern, 5 Actions A1–A5, 6 Findings RESOLVED
- `plans/08-round-2-5-feedback.md` — **Round 2.5**, 3 parallel reviewers, 8 Findings F34–F41 inline-fixed, **PASS-pending-statistician** verdict

### Research Notes (in `docs/research-notes/`)
- `ml-adversary-models.md` — F6: 10-SDK landscape, 10 cross-correlation patterns C1–C10, 9 academic refs, 3-level adversary axis L_AdvA/B/C
- `literature-extensions.md` — F4 + F5 + F31: 27 academic papers + 14 OSS tools + 6 RE reports + 6 German academic groups + 15 BibTeX, KeyDive completely removed
- `coherence-metric-spec.md` — A2 BLOCKING: Hybrid Pearson+Chi² combined via **Brown's method** (NOT Fisher's), pre-clustered at ρ=0.7, BH-FDR-only, ready for statistician sign-off

### Specifications
- `experiments/runner/SPEC.md` — F16: 10-module orchestrator design, deterministic run-IDs (BLAKE3 over canonical_manifest+APK-sha+run_index), F21-aware (refuses privileged:true), F20-aware (image-hash verify), F11-resilient (SQLite journal)
- `registration/osf-preregistration.md` — F13/F32: AsPredicted-format, all H1–H5 verbatim, falsifiability per hypothesis, 7 Researcher-Degrees-of-Freedom acknowledged

### DetectorLab Scaffold (no Legal-Gate impact)
- `detectorlab-skeleton/README.md` — explicit non-build status
- `app/.../core/Probe.kt` — interface contract with 5 invariants
- `app/.../core/ProbeResult.kt` — JSON-Schema v1 binding
- `app/.../core/ProbeContext.kt` — testable abstraction (Round-2.5 F36: split into ProbeContext + ShellProbeContext with AllowlistedCommand enum)
- `app/.../core/Report.kt` — top-level Report data class (added Round-2.5 F38)
- `app/.../core/ProbeRunner.kt` — orchestrator with timeout/failure-isolation/aggregate (added Round-2.5 F38)
- `app/.../probes/buildprop/BuildFingerprintProbe.kt` — Probe #1 reference impl

### Repo Hygiene
- `LICENSE` — official Apache-2.0 (202 lines from apache.org)
- `CITATION.cff` — academic citation format, GitHub-rendered
- `CONTRIBUTING.md` — Plan-Immutability + Legal-Gate + PR checklist + multi-reviewer pattern
- `AGENTS.md` — hard rules for AI agents (Plan-Immutability/Legal-Gate/Scope-Lock + escalation triggers)
- `.claude/skills/cloud-phone-research/SKILL.md` — full Step 0–6 research-loop workflow with frontmatter
- `SKILL.md` (root) — discovery-file for non-Claude agents
- `prompts/00-README.md` + 01–03 — three ready-to-paste prompts (extend-finding / add-probe / validate-round)
- `Justfile` — one-command access (`just validate-gemini`, `just validate-probes`, `just lint`)
- `.editorconfig` — cross-editor consistency
- `.github/workflows/validate.yml` — CI: markdown-lint + link-check + YAML schema + scope-lock check (all hard-fail after Round-2.5 F41)
- `.github/ISSUE_TEMPLATE/finding.yml` + `legal-blocked.yml` — issue templates
- `ROADMAP.md` — living document with Mermaid Gantt, findings status, decision log

### GitHub Issues (live tracking)
- #1 [F21] Privileged Docker — legal-gate, blocking
- #2 [F22] Keybox Provenance §259 StGB — legal-gate, blocking
- #3 [F23] Reproducibility-Pack §202c — legal-gate, blocking
- #4 [F31] cpu_frequency_signature probe candidate — Round-2 discovery
- #5 [F32] ML coherence-metric scope creep — Round-2 methodological
- #6 [F33] Probe #75 ARM64 feasibility risk — Round-2 technical

### Git history
```
eb29b6d  validation-round-2-5: 3-reviewer convergent fixes (8 findings F34-F41 inline)
e8aa904  research(round-3-prep): A2 coherence-metric + OSF pre-reg + DetectorLab scaffold + roadmap
2dbed07  feat(repo-hygiene): A1 fix + LICENSE + CITATION + CONTRIBUTING + CI + Justfile + 6 issues
271ba79  validation-round-2: gemini-cli verified working, NEEDS_REVISION
d674dcb  research(round-2-prep): 4 parallel subagent outputs (1658 lines)
b16389d  feat(agents): add AGENTS.md + cloud-phone-research skill + 3 prompts
0648d5d  docs(readme): polish — badges, TOC, 7 mermaid diagrams, validation panel
778daa4  docs(readme): add 5 Mermaid diagrams (architecture, test-loop, gantt, threat-model, blockers)
20b8b92  validation-round-1: 4-reviewer feedback consolidated
2882237  init: cloud phone research planner with two-track plan
```

---

## What is OPEN — and what to do about it

### 🔴 BLOCKED — human-only (do not touch)

| ID | Item | Owner | Action |
|---|---|---|---|
| **F21-legal** | Privileged Docker container deployment | University Rechtsabteilung + IT-Sec | Schriftliche Freigabe der seccomp+cap_drop-Konfiguration |
| **F22** | Keybox provenance | University Rechtsabteilung | Schriftliche Freigabe (TEE-Extraction von Eigengeräten ODER Hersteller-Erlaubnis) |
| **F23** | Reproducibility-pack split | University Rechtsabteilung | Schriftliche Freigabe der public-vs-institutional-split-Strategie |

If you encounter ANY of these as a next-step requirement, **stop, open a `legal-blocked` GitHub issue, and tell the human partner**. Do not propose answers. Reasoning: legal anchoring risk.

### ⏸ DEFERRED to runner-impl phase (after F21-legal cleared)

| ID | Item |
|---|---|
| F37 | Run-ID material should include `seed` from manifest (or document determinism) |
| F39 | `cap_add: [SYS_ADMIN]` should be narrowed to specific caps with documented rationale |

### 📋 OPEN — Round-3+ queue (17 findings, sorted by priority)

#### High-priority, AI-progressable

1. **F8** — DenyList edge-case in Round 1 (gap-analyst flagged): coherence-metric assumes a clean reference distribution; what if reference contains contamination?
2. **F11** — Container OOM during 30-run loop, no resume protocol → covered by SPEC.md §4 resumability but not explicitly tested.
3. **F12** — IRB approval gating Phase 1 (gap-analyst): create `registration/irb-application.md` skeleton.
4. **F14** — Sensor-trace recording protocol (gap-analyst): create `experiments/feasibility/sensor-trace-recording.md` with DSGVO data-minimization (first/last 60s strip).
5. **F18** — Hardware-Procurement-Plan (gap-analyst): create `registration/hardware-procurement.md` with ARM64-host + 3 baseline-devices + LTE-modem checklist.
6. **F19** — Negative-Controls (gap-analyst): document AVD x86_64 + Genymotion baseline runs.
7. **F24** — iptables-isolation script: create `stack/iptables-isolation.sh` (referenced in SPEC.md §4 but not yet drafted).
8. **F25** — DSGVO assessment of sensor-traces: create `docs/dsgvo-assessment.md` for IRB anhang.
9. **F31 (Issue #4)** — Probe #75 cpu_frequency_signature: use `prompts/02-add-probe.md` workflow.
10. **F33 (Issue #6)** — Probe #75 ARM64 feasibility-pilot: create `experiments/feasibility/probe-75-pilot.md`.

#### Medium-priority, AI-progressable

11. **F1** — Plan-bug fixes if discovered (use `plan-bug` issue template, do not edit plans/00–04 directly).
12. **F2** — ARM64 host platform empirical validation against Apple Silicon (post-procurement).
13. **F3** — Statistical-power-calc with empirical σ from pilot data (post-pilot).
14. **F7** — Sensor FFT classifier specification (training-set + model + train/test split).
15. **F9** — DenyList-vs-DetectorLab boundary tests.
16. **F10** — Multi-app-profile testing on DetectorLab.
17. **F15** — Probe-runtime-budget enforcement test harness.
18. **F17** — OpenGApps vs MicroG installation decision.

#### Low-priority, AI-progressable

19. **F37** — Run-ID seed inclusion (deferred but could be drafted as runner-impl preparation).

### 🟢 NICE-TO-HAVE (not in Findings list, but valuable)

- **Codex GPT-5.5 reviewer pass** — wait until 2026-05-09 quota reset, then run a fourth independent reviewer pass on Round-2.5 PASS state.
- **Statistician outreach email** — draft to CISPA Saarland / TU Darmstadt CYSEC / Cambridge (KeyDroid co-authors) requesting Brown's-method review.
- **Mermaid → SVG export** for paper-ready figures.
- **Eval harness for prompts** (`prompts/eval/`) — regression-test the three agent prompts.
- **Per-harness compatibility transcripts** (record one successful run on each named harness, link from `prompts/00-README.md`).

---

## How to PICK UP and continue

### Step 1 — Activate the project skill

Read `.claude/skills/cloud-phone-research/SKILL.md` end-to-end. It defines Steps 0–6 of the research loop, anti-rationalization rebuttals, and the multi-reviewer pattern. **Activate the skill before anything else.**

### Step 2 — Pick a finding

Use the priority list above. Heuristic:
- **Highest impact, lowest legal risk:** F12 (IRB skeleton), F14 (Sensor-trace protocol), F18 (Hardware procurement)
- **Strongest cross-cutting effect:** F31 (Probe #75) — would also test the `prompts/02-add-probe.md` workflow E2E
- **Smallest scope, fastest closure:** F19 (Negative-Controls — AVD + Genymotion baseline)

If unsure, **ask the human partner** which to pick. Do not silently choose Legal-Gate items (F21/F22/F23).

### Step 3 — Use the prompts

| Goal | Prompt |
|---|---|
| Progress an open finding into a reviewed addendum | `prompts/01-extend-finding.md` |
| Propose a new probe (e.g. for F31) | `prompts/02-add-probe.md` |
| Run a fresh validation round on the current state | `prompts/03-validate-round.md` |

### Step 4 — Output rules

- Output goes to `plans/09-{slug}-addendum.md` or `docs/research-notes/{slug}.md` — never to `plans/00–04`.
- Run multi-reviewer (≥2 reviewers, parallel) before claiming complete.
- Stop on explicit "approve to apply? Y/N" — wait for human Y.
- Commit only after Y. Use Conventional Commit format: `addendum(F-id): description` or `research(round-N-prep): description`.

### Step 5 — Verified Gemini-CLI invocation

```bash
GEMINI_CLI_TRUST_WORKSPACE=true gemini -p "$(cat /tmp/prompt.md)" \
  --skip-trust --approval-mode plan -m gemini-3-pro-preview
```

The `[ERROR] [IDEClient] Directory mismatch` warning is **non-fatal** — output is still produced correctly. Tested across Round 2 + Round 2.5.

### Step 6 — When you are done with a piece of work

1. Run `just lint` to verify markdown + YAML + probe-schema validation passes.
2. Verify CI passes on the PR (`gh pr checks` or wait for the GitHub Actions run on push).
3. Update `ROADMAP.md` (decision log + findings status — this file IS editable, not Plan-Immutable).
4. Add to `plans/N-round-feedback.md` if validation-round-style.
5. Open a GitHub Issue (label: `finding`) for any new finding you discover.
6. Tell the human partner what you did and what's next, in your final reply.

---

## Critical files cheat sheet

| File | Purpose | Editable by AI? |
|---|---|---|
| `README.md` | Public face, badges, quickstart | ✅ |
| `AGENTS.md` | Hard rules | ⚠️ rare changes only, big diff = surface to human |
| `ROADMAP.md` | Living status doc | ✅ regularly |
| `plans/00–04` | Immutable plans | ❌ NEVER |
| `plans/05–08` | Validation history | ❌ historical record |
| `plans/06–09+` | Future addenda | ✅ this is where new work goes |
| `docs/threat-model.md` | Original threat model | ⚠️ via addendum only |
| `docs/research-notes/*` | Research notes feeding future merges | ✅ |
| `docs/probe-schema.md` | JSON-Schema v1 lock | ❌ frozen with OSF |
| `probes/inventory.yml` | The 60+14+1=75 probe inventory | ⚠️ via addendum only |
| `stack/layers.md` | Layer specs | ⚠️ via addendum only |
| `experiments/runner/SPEC.md` | Orchestrator design | ⚠️ via addendum only |
| `registration/osf-preregistration.md` | OSF pre-registration | ❌ frozen at OSF upload |
| `detectorlab-skeleton/` | Pre-implementation Kotlin scaffold | ✅ this scaffold can be deleted by human if Legal-Gate tightens |
| `.github/`, `Justfile`, `.editorconfig`, `LICENSE`, `CITATION.cff`, `CONTRIBUTING.md` | Repo hygiene | ✅ |
| `prompts/00–03` | Agent prompts | ✅ meta-tooling |
| `.claude/skills/cloud-phone-research/SKILL.md` | The skill | ⚠️ rare changes |

---

## Reviewer panel composition (verified working)

For any future validation round:

| Reviewer | Invocation | Status |
|---|---|---|
| Gemini 3 Pro Preview (`gemini-cli` headless) | `GEMINI_CLI_TRUST_WORKSPACE=true gemini -p "$(cat prompt.md)" --skip-trust --approval-mode plan -m gemini-3-pro-preview` | ✅ verified Round 2 + 2.5 |
| `architecture-strategist` (Claude subagent) | Use Task tool with `subagent_type: architecture-strategist` | ✅ verified Round 1 + 2.5 |
| `security-auditor` (Claude subagent) | Use Task tool with `subagent_type: security-auditor` | ✅ verified Round 1 + 2.5 |
| `gap-analyst` (Claude subagent) | Use Task tool with `subagent_type: gap-analyst` | ✅ verified Round 1 |
| `autoresearch` (Claude subagent) | Use Task tool with `subagent_type: autoresearch` | ⚠️ hits usage limit on long runs — reserve for shorter focused research |
| Codex GPT-5.5 (`codex exec`) | `codex exec --skip-git-repo-check "$(cat prompt.md)"` | ⏸ usage-limit until 2026-05-09 |

Standard pattern: Gemini + ≥2 Claude subagents in parallel, then consolidate in `plans/N-round-feedback.md`.

---

## Anti-rationalization reminders (the ones agents fail on most)

| Excuse you might hear yourself making | Rebuttal |
|---|---|
| "It's a small fix, I'll edit plans/02 directly" | Plan-Immutability is absolute. Use addendum. |
| "Legal-Gate is overkill for this" | If F21/F22/F23, it's not. Stop, open `legal-blocked` issue. |
| "I can clone this Magisk module to inspect" | Manifest-only is enough at planning stage. Cloning live spoof tooling drags scope. |
| "The user said 'just do it' — I'll commit without addendum" | Plan-Immutability supersedes user pressure. Draft addendum, ask Y/N. |
| "I'll add a probe directly to inventory.yml" | inventory.yml is plan artifact. Use addendum, then human applies. |
| "I'll skip multi-reviewer for the small ones" | 2 reviewers minimum. Cheap insurance. The 3-reviewer Round 2.5 caught issues no single reviewer found. |
| "I found a better statistical method, let me change H5" | Pre-registration on OSF anchors hypotheses. Add H6 in addendum, never silently change H1–H5. |
| "Brown's method seems Fisher-equivalent, I'll use Fisher" | Round-2.5 F34 explicitly committed to Brown's. Reverting reopens a closed finding. |
| "I'll cite this DRM tool because the disclaimer makes it OK" | Round-2.5 F35 closed exactly this. Strikethrough/disclaimer doesn't satisfy §202c. Physical removal only. |

---

## You are now briefed. Start with `cat AGENTS.md && cat ROADMAP.md && cat plans/08-round-2-5-feedback.md` and pick a finding.

— Claude Opus 4.7 (1M context), session ending 2026-05-03

> If you are a HUMAN reading this: this document is intended for the next AI agent. You may also use it as a status report to share with collaborators or upload to your project-tracking system.
