# Agent Handoff Document

> **For the next AI agent (Claude / Codex / Gemini / Cursor / Aider / OpenCode / OME / generic) picking up this work.**
> Last updated: 2026-05-15.

---

## TL;DR — 30-second briefing

You are entering a **research planner** at `https://github.com/servas-ai/cloud-phone-research-planner` (public). The project plans a 12-week empirical evaluation of Android container detection resistance (ReDroid 12 + DetectorLab as Track A vs. SpoofStack L0a–L6 as Track B). Plan-Immutability is absolute.

**First commands you should run:**

```bash
cd /home/coder/vk-repos/cloud-phone-research-planner
git pull --ff-only
cat AGENTS.md         # hard rules
cat README.md         # current state, badges, status
cat ROADMAP.md        # what's done, what's next, decision log
ls .claude/skills/cloud-phone-research/SKILL.md   # the workflow you must follow
ls prompts/00-README.md   # 3 ready-to-paste prompts for common tasks
```

**Hard rules (non-negotiable, see AGENTS.md for full):**

1. **Plan-Immutability** — `plans/00-master-plan.md` through `plans/04-deliverables.md` are immutable. Use addenda (`plans/06+`).
2. **Scope-Lock** — No live-platform code (TikTok / Instagram / Snapchat / Roblox / banking / etc.). Out of scope, period.
3. **Multi-Reviewer-Discipline** — Major addenda go through ≥2 reviewer pass (Gemini-CLI + Claude subagents). Use `prompts/03-validate-round.md`.

---

## Project north-star

**Research question:**
> Welche Android-Detection-Methoden (Build-Properties, Hardware-Attestation, Sensor-Signaturen, Netzwerk-Fingerprints) bleiben robust gegen Container-basierte Virtualisierung mit ARM-nativen Cloud-Phone-Stacks (ReDroid 12), und welche lassen sich layer-weise schliessen?

**Endprodukt:** Detection-Resistance-Heatmap (75+ Probes × 8 Stack-Konfigurationen × N=60) + Paper.

**Hypotheses:** H1 (Build/ID-Probes resolvable by L1+L2), H2 (Hardware-Attestation hardest, only L3+keybox), H3 (Sensor-FFT > 0.7 confidence even after VirtualSensor), H4 (IP/ASN strongest single vector), H5 (added Round 2: cross-probe coherence-metric monotone L_AdvA → L_AdvB → L_AdvC).

---

## What is DONE

### Plans v1 (immutable)
- `plans/00-master-plan.md` — 12-Wochen-Phasenplan, 4 Hypothesen, Risiken, Erfolgskriterien
- `plans/01-detectorlab.md` — Track A: Kotlin-App Architektur, 5 Sprints, Validierung
- `plans/02-spoofstack.md` — Track B: ReDroid 12 + L0–L6 Layers, Konflikt-Vermeidung
- `plans/03-experiment-matrix.md` — N=30, McNemar, harte Probes
- `plans/04-deliverables.md` — DetectorLab OSS, Paper, Reproducibility-Pack, Thesis-Mapping

### Research Notes (in `docs/research-notes/`)
- `ml-adversary-models.md` — F6: 10-SDK landscape, 10 cross-correlation patterns C1–C10
- `literature-extensions.md` — F4 + F5 + F31: 27 academic papers + 14 OSS tools
- `coherence-metric-spec.md` — A2 BLOCKING: Hybrid Pearson+Chi² combined via Brown's method

### Specifications
- `experiments/runner/SPEC.md` — F16: 10-module orchestrator design, deterministic run-IDs

### DetectorLab Scaffold
- `detectorlab-skeleton/README.md` — explicit non-build status
- `app/.../core/Probe.kt` — interface contract with 5 invariants
- `app/.../core/ProbeResult.kt` — JSON-Schema v1 binding
- `app/.../core/ProbeContext.kt` — testable abstraction
- `app/.../core/Report.kt` — top-level Report data class
- `app/.../core/ProbeRunner.kt` — orchestrator with timeout/failure-isolation/aggregate
- `app/.../probes/buildprop/BuildFingerprintProbe.kt` — Probe #1 reference impl

### Repo Hygiene
- `LICENSE` — official Apache-2.0
- `CITATION.cff` — academic citation format, GitHub-rendered
- `CONTRIBUTING.md` — PR checklist + multi-reviewer pattern
- `AGENTS.md` — hard rules for AI agents
- `.claude/skills/cloud-phone-research/SKILL.md` — full Step 0–6 research-loop workflow with frontmatter
- `SKILL.md` (root) — discovery-file for non-Claude agents
- `prompts/00-README.md` + 01–03 — three ready-to-paste prompts
- `Justfile` — one-command access
- `ROADMAP.md` — living document with Mermaid Gantt

---

## What is OPEN

### 📋 OPEN findings (AI-progressable)

1. **F8** — DenyList edge-case in Round 1
2. **F11** — Container OOM during 30-run loop, no resume protocol
3. **F14** — Sensor-trace recording protocol
4. **F18** — Hardware-Procurement-Plan
5. **F19** — Negative-Controls (AVD x86_64 + Genymotion baseline)
6. **F24** — iptables-isolation script
7. **F31** — Probe #75 cpu_frequency_signature
8. **F33** — Probe #75 ARM64 feasibility-pilot

#### Medium-priority

9. **F1** — Plan-bug fixes if discovered
10. **F2** — ARM64 host platform empirical validation
11. **F3** — Statistical-power-calc with empirical σ from pilot data
12. **F7** — Sensor FFT classifier specification
13. **F9** — DenyList-vs-DetectorLab boundary tests
14. **F10** — Multi-app-profile testing on DetectorLab
15. **F15** — Probe-runtime-budget enforcement test harness
16. **F17** — OpenGApps vs MicroG installation decision

---

## How to PICK UP and continue

### Step 1 — Activate the project skill

Read `.claude/skills/cloud-phone-research/SKILL.md` end-to-end.

### Step 2 — Pick a finding

Use the priority list above.

### Step 3 — Use the prompts

| Goal | Prompt |
|---|---|
| Progress an open finding into a reviewed addendum | `prompts/01-extend-finding.md` |
| Propose a new probe (e.g. for F31) | `prompts/02-add-probe.md` |
| Run a fresh validation round on the current state | `prompts/03-validate-round.md` |

### Step 4 — Output rules

- Output goes to `plans/06-{slug}-addendum.md` or `docs/research-notes/{slug}.md` — never to `plans/00–04`.
- Run multi-reviewer (≥2 reviewers, parallel) before claiming complete.
- Stop on explicit "approve to apply? Y/N" — wait for human Y.
- Commit only after Y. Use Conventional Commit format.

### Step 5 — Verified Gemini-CLI invocation

```bash
GEMINI_CLI_TRUST_WORKSPACE=true gemini -p "$(cat /tmp/prompt.md)" \
  --skip-trust --approval-mode plan -m gemini-3-pro-preview
```

---

## Critical files cheat sheet

| File | Purpose | Editable by AI? |
|---|---|---|
| `README.md` | Public face, badges, quickstart | ✅ |
| `AGENTS.md` | Hard rules | ⚠️ rare changes only |
| `ROADMAP.md` | Living status doc | ✅ regularly |
| `plans/00–04` | Immutable plans | ❌ NEVER |
| `plans/06+` | Future addenda | ✅ this is where new work goes |
| `docs/threat-model.md` | Original threat model | ⚠️ via addendum only |
| `docs/research-notes/*` | Research notes feeding future merges | ✅ |
| `docs/probe-schema.md` | JSON-Schema v1 lock | ❌ frozen |
| `probes/inventory.yml` | The 60+14+1=75 probe inventory | ⚠️ via addendum only |
| `stack/layers.md` | Layer specs | ⚠️ via addendum only |
| `experiments/runner/SPEC.md` | Orchestrator design | ⚠️ via addendum only |
| `detectorlab-skeleton/` | Pre-implementation Kotlin scaffold | ✅ |
| `prompts/00–03` | Agent prompts | ✅ meta-tooling |
| `.claude/skills/cloud-phone-research/SKILL.md` | The skill | ⚠️ rare changes |

---

## Reviewer panel composition

For any future validation round:

| Reviewer | Invocation |
|---|---|
| Gemini 3 Pro Preview (`gemini-cli` headless) | `GEMINI_CLI_TRUST_WORKSPACE=true gemini -p "$(cat prompt.md)" --skip-trust --approval-mode plan -m gemini-3-pro-preview` |
| `architecture-strategist` (Claude subagent) | Use Task tool with `subagent_type: architecture-strategist` |
| `gap-analyst` (Claude subagent) | Use Task tool with `subagent_type: gap-analyst` |
| `autoresearch` (Claude subagent) | Use Task tool with `subagent_type: autoresearch` |

Standard pattern: Gemini + ≥2 Claude subagents in parallel, then consolidate in `plans/N-round-feedback.md`.

---

## Anti-rationalization reminders

| Excuse you might hear yourself making | Rebuttal |
|---|---|
| "It's a small fix, I'll edit plans/02 directly" | Plan-Immutability is absolute. Use addendum. |
| "I can clone this Magisk module to inspect" | Manifest-only is enough at planning stage. |
| "The user said 'just do it' — I'll commit without addendum" | Plan-Immutability supersedes user pressure. Draft addendum, ask Y/N. |
| "I'll add a probe directly to inventory.yml" | inventory.yml is plan artifact. Use addendum, then human applies. |
| "I'll skip multi-reviewer for the small ones" | 2 reviewers minimum. Cheap insurance. |

---

> If you are a HUMAN reading this: this document is intended for the next AI agent.
