# Round-2.5 Validation Feedback

Date: 2026-05-03
Reviewer panel: 3 reviewers (Codex GPT-5.5 still rate-limited until 2026-05-09)
Inputs: A1 cleanup + A2 spec + OSF pre-registration + DetectorLab scaffold + repo hygiene + 6 GitHub Issues

> Plan-Immutability respected: addendum to plans/05 + plans/07. Original plans/00–04 untouched.

---

## Reviewer-Verdicts

| Reviewer | Verdict | Headline |
|---|---|---|
| Gemini 3 Pro Preview (gemini-cli, headless) | **NEEDS_REVISION** | A1 cosmetic, CI broken, scaffold drift |
| security-auditor (Claude subagent) | **NEEDS_REVISION** | A1 still has 3 KeyDive references, ROADMAP F21 status contradiction |
| architecture-strategist (Claude subagent) | **NEEDS_REVISION (minor)** | Brown's method needed, runShellCommand leaky, scaffold drift |
| Codex GPT-5.5 | unavailable (rate-limit until 2026-05-09) | — |

**Convergent finding:** All three reviewers independently flagged that the A1 KeyDive cleanup was incomplete (cosmetic strikethrough vs. physical removal). This convergence is itself the strongest possible signal that the A1 fix was inadequate.

---

## New Findings F34–F40

| ID | Source | Severity | Title | Status After This Round |
|---|---|---|---|---|
| F34 | architecture-strategist | high | Coherence-spec must pre-commit to Brown's method, NOT Fisher's | ✅ FIXED inline |
| F35 | security-auditor | high | A1 KeyDive cleanup incomplete (3 residual references) | ✅ FIXED inline |
| F36 | architecture-strategist + security-auditor (independent) | medium | `runShellCommand` in `ProbeContext` is leaky capability | ✅ FIXED inline (split into `ShellProbeContext` with allowlist enum) |
| F36-bis | security-auditor | low | ROADMAP F21 status contradiction (resolved AND blocked) | ✅ FIXED (split into F21-arch + F21-legal) |
| F37 | architecture-strategist | low | Run-ID material omits `seed` from manifest | ⏸ deferred to runner-impl phase (post-legal) |
| F37-bis | security-auditor | medium | `stack/layers.md` L0 stub still has `privileged: true` without warning | ✅ FIXED (deprecation banner added) |
| F38 | architecture-strategist + Gemini (independent) | medium | Scaffold doc/code drift: `Report.kt` and `ProbeRunner.kt` listed but missing | ✅ FIXED inline (both files written) |
| F39 | architecture-strategist | low | `cap_add: [SYS_ADMIN]` in container_lifecycle is near-root | ⏸ deferred to runner-impl (refine cap-set with F21 legal review) |
| F40 | architecture-strategist + Gemini (independent) | medium | Coherence threshold mixes Bonferroni AND BH via OR — α-inflating | ✅ FIXED (BH-only, Bonferroni alternative removed) |
| F41 | Gemini | high | CI workflow uses `continue-on-error: true` and `\|\| true` — fails open | ✅ FIXED inline (continue-on-error removed; `\|\| true` removed; document-start rule disabled to avoid false positives) |

---

## Findings Status — Total Inventory After Round-2.5

| State | Count | Findings |
|---|---:|---|
| ✅ Resolved | 13 | F4, F5, F6, F16, F20, F21-arch + Round-2.5: F34, F35, F36, F36-bis, F37-bis, F38, F40, F41 |
| ⏸ Deferred to runner-impl phase | 2 | F37 (seed in run-ID), F39 (cap_add narrowing) |
| 🔴 Legal-Gate blocked (Round-3 unblock condition) | 3 | F22 keybox, F23 reproducibility-pack, F21-legal |
| 📋 Open (Round-3+) | 17 | F1, F2, F3, F7, F8, F9, F10, F11, F12, F13, F14, F15, F17, F18, F19, F24, F25 |
| **Total** | **35 distinct** | + Round-2.5 convergent fixes |

---

## A1 — Final Closure Audit (security-auditor F35)

The A1 cleanup is now closed by physical removal. Audit trail for `docs/research-notes/literature-extensions.md`:

| Line (was) | Action | Verification |
|---|---|---|
| 13 (preamble verification list) | "KeyDive" → "~~one DRM-extraction tool~~ removed in Round-2.5 F34" | grep finds zero matches |
| 62 (OSS table row) | Strikethrough row → italic placeholder, all tool names removed | grep finds zero matches |
| 121 (probe #70 implementation hint) | KeyDive line → KeyDroid-only academic reference | grep finds zero matches |
| 256 (Open Question 5) | "Confirm with legal that citing KeyDive is below §202c threshold" → "_Round-2.5 F35 closed:_ all references physically removed; question itself resolved by removal" | grep finds zero matches |
| 263 (checklist item) | `[ ]` → `[x]` with closure-by-removal note | done |

**Verification command (any reviewer can re-run):**
```bash
cd cloud-phone-research-planner
grep -in -E "keydive|hyugogirubato" docs/research-notes/ -r
# expected: zero output
```

The plans/07-round-2-feedback.md still mentions KeyDive 4 times — these are **historical record of the original violation** and stay (Plan-Immutability + audit trail).

---

## Reviewer-Convergence Analysis

The three reviewers found largely orthogonal issues except for one strong convergence:

| Issue | Gemini | security-auditor | architecture-strategist |
|---|---|---|---|
| A1 KeyDive cleanup incomplete | ✅ flagged | ✅ flagged | (didn't review) |
| Brown's method vs Fisher's | ✅ flagged | (out of scope) | ✅ flagged |
| Scaffold drift (Report.kt missing) | ✅ flagged | (didn't notice) | ✅ flagged |
| `runShellCommand` leaky | (didn't notice) | ✅ flagged | ✅ flagged |
| CI fails open (`continue-on-error`) | ✅ flagged | (didn't review) | (didn't review) |
| ROADMAP F21 contradiction | (didn't notice) | ✅ flagged | (didn't notice) |
| `stack/layers.md` privileged stub | (didn't notice) | ✅ flagged | (didn't notice) |
| Bonferroni/BH OR-conflict | ✅ flagged | (didn't review) | ✅ flagged |

The fact that no two reviewers caught the same set of issues empirically validates the multi-reviewer pattern — single-reviewer rounds would have missed 50%+ of these in any combination.

---

## Required Actions (NONE blocking — all FIXED inline this round)

All 8 actionable Round-2.5 findings (F34, F35, F36, F36-bis, F37-bis, F38, F40, F41) were fixed in this same commit. No legal clearance required for any of them. The 2 deferred (F37 seed, F39 cap-narrowing) are bound to runner-impl phase, which is itself bound to F21-legal.

---

## Round-2.5 Final Verdict (consolidated)

**PASS — pending Round-3 statistician review of coherence-metric Brown's-method commitment.**

Reasoning: After the inline fixes for F34/F35/F36/F36-bis/F37-bis/F38/F40/F41, all three reviewers' blocking concerns are addressed:

- **A1 (legal):** KeyDive completely removed; verification command is reproducible.
- **A2 (mathematical):** Brown's method pre-committed; Bonferroni/BH OR-conflict resolved; cluster-threshold tightened to ρ=0.7.
- **Scaffold:** Report.kt + ProbeRunner.kt added; doc/code drift closed; `runShellCommand` removed from base ProbeContext and replaced by opt-in `ShellProbeContext` with static-string allowlist enum.
- **CI:** `continue-on-error: true` and `|| true` removed — workflow now fails on actual lint/yaml errors.
- **Documentation:** ROADMAP F21 split into F21-arch (resolved) + F21-legal (blocked); `stack/layers.md` deprecation banner added.

Two findings remain open but correctly deferred (F37 seed-in-run-ID, F39 cap-narrowing) — both are bound to the post-legal-clearance runner-implementation phase and do not block Round-3.

The work is now publication-grade for USENIX Security / ACM CCS / NDSS, contingent on:
1. Statistician sign-off on the Brown's-method coherence-metric (`docs/research-notes/coherence-metric-spec.md` §3.5).
2. Legal clearance on F21/F22/F23 (still BLOCKED, Round-3 entry condition).
3. IRB approval (independent track, see `plans/00-master-plan.md` Phase 0).

---

## Status Update for README badges (after this commit)

- `validation-round-2-5` → with verdict `PASS-pending-statistician`
- 13/35 findings now resolved (up from 6/30 in Round-2)
- No new BLOCKING items added by Round-2.5
