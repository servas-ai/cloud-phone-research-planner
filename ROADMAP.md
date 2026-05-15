# Roadmap

> Living document. Updated after every validation round.

```mermaid
gantt
    title Cloud Phone Research Planner — Roadmap
    dateFormat YYYY-MM-DD
    axisFormat KW%V

    section ✅ Done
    Plans v1 (00-04)                       :done, p1, 2026-04-29, 4d
    Validation Round 1 (4 reviewer)        :done, v1, 2026-05-01, 2d
    AGENTS.md + SKILL + Prompts            :done, agents, 2026-05-02, 1d
    Round-2 Subagent Research              :done, r2res, 2026-05-02, 1d
    Round-2 Validation (Gemini)            :done, v2, 2026-05-02, 1d
    A1 KeyDive removal                     :done, a1, 2026-05-03, 1d
    Repo hygiene (LICENSE/CITATION/CI)     :done, hyg, 2026-05-03, 1d

    section 🟡 In Progress
    A2 Coherence Metric Spec               :active, a2, 2026-05-03, 2d

    section 📋 Planned
    Round-2.5 Multi-Reviewer Re-Validation :postR2, after a2, 2d
    DetectorLab Kotlin scaffold            :dl, after a2, 5d
    Hardware Procurement                   :hw, 2026-05-04, 14d

    section 🚀 Implementation
    Track A Sprints 1-5                    :a, 2026-05-25, 35d
    Track B Sprints A-D                    :b, 2026-05-25, 28d
    experiments/runner implementation      :run, 2026-05-25, 14d

    section 📊 Analysis & Paper
    Layer Experiments (8 configs × 60)     :exp, after a, 21d
    Statistical Analysis                   :stats, after exp, 7d
    Paper Draft & Submission               :crit, paper, after stats, 14d
```

## Current Sprint (KW 18, 2026-05-03)

| ID | Task | Owner | Status |
|---|---|---|---|
| A1 | KeyDive citation removed from literature-extensions | AI agent | ✅ DONE |
| A2 | Define mathematical coherence metric | autoresearch subagent | 🟡 IN PROGRESS |

## Findings Status

| State | Count | Findings |
|---|---:|---|
| ✅ Resolved (Round 2) | 6 | F4, F5, F6, F16, F20, F25 |
| 🟡 In Round-2.5 review | 4 | F31 (probe #75), F32 (coherence), A2, A3 |
| 📋 Open (deferred to Round 3) | 17 | F1, F2, F3, F7, F8, F9, F10, F11, F13, F15, F17, F18, F19, F24 |

## Decision Log

| Date | Decision | Rationale |
|---|---|---|
| 2026-05-02 | Adopt 4-reviewer panel as Round-N standard | Round-1 caught 30 findings; single-reviewer would miss most |
| 2026-05-02 | Plan-Immutability is absolute | Hypothesis anchor |
| 2026-05-02 | Public-private reproducibility split | Distribution control |

## Next 3 Concrete Actions

1. **Round-2.5 Validation** — 4-reviewer panel on coherence-metric + post-A1 literature-extensions
2. **DetectorLab Kotlin scaffold** (`:app` Gradle module + Probe interface + JSON-Schema-validation tests)
3. **Probe #75 ARM64 Feasibility-Pilot** plan (F33) — 2-day lab study spec

## Out of Scope (locked)

- Live-platform integration (TikTok / IG / Snapchat / Roblox / banking) — out of scope
- Account-farming workflows — out of scope
- Spoofing-stack distribution — institutional access only
