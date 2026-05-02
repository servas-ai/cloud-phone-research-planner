# Prompt 03 — Run a Fresh Multi-Reviewer Validation Round

Drive an AI agent to orchestrate a complete validation round across
multiple independent reviewers (Gemini-CLI + Claude subagents +
optionally Codex). The output is a consolidated feedback file
mirroring the structure of `plans/05-validation-feedback.md` (Round 1).

This is the prompt that produced Round 1. Use it for Round 2, Round 3,
post-Legal-clearance rounds, pre-publication gates, etc.

---

## Configuration

| Input | Example | Notes |
|---|---|---|
| Round name | `round-2`, `round-3-post-legal`, `pre-submission-usenix` | kebab-case, will appear in the output filename. |
| Files under review | `plans/00-04 + plans/05 + all addenda in plans/06+` | Default if unspecified — suitable for most rounds. |
| Reviewer panel | `Gemini-CLI + architecture-strategist + security-auditor + gap-analyst + (optional Codex)` | Aim for 4 independent reviewers. |
| Output filename | auto-derived: `plans/07-{round-name}-feedback.md` | Do not overwrite Round 1 (`plans/05`). |

**Stop conditions:**
- A reviewer returns evidence that the threat model misses an entire class of detection.
- A reviewer flags a Legal-Gate issue not previously surfaced.
- All reviewers fail (rate limits, IDE conflict, missing tools) and you have <2 successful reviews.
- The output file path you computed already exists (would overwrite previous round).
- The human asks you to apply findings — that is a separate, explicitly approved patch round.

---

## When to run a fresh round

- After every Round-N patch is applied, to verify no regression.
- Before submitting to a paper venue (final pre-submission gate).
- After major OSS-tool version changes (Magisk, ReDroid, PIF) that
  invalidate prior assumptions.
- Before any external collaborator joins the project (re-baseline).
- Quarterly if the research is long-running.

---

## Paste-block (copy from here)

```
ROLE
You are an AI research engineer orchestrating one full validation
round of an academic security-research plan. You coordinate multiple
independent reviewers, consolidate their feedback into a single file,
and stop. You do not apply findings — that is a separate human-approved
patch round.

CONTEXT
Repository: a German-language academic security-research planner
(ReDroid 12 + DetectorLab vs. SpoofStack L0a–L6). Round 1 lives at
plans/05-validation-feedback.md and is FROZEN. Round-N output goes
to plans/07-{round-name}-feedback.md, mirroring the structure of
Round 1 (Reviewer-Verdicts table, Konsens-Findings, Reviewer-Konflikte,
Geplante Datei-Edits, TOP-N BLOCKING).

CONFIRM INPUTS FIRST
Ask the human partner for:
  1. Round name (e.g. round-2, pre-submission-usenix).
  2. Files under review (default: README.md + plans/00-04 +
     plans/05-validation-feedback.md + all addenda in plans/06+).
  3. Reviewer panel (default: Gemini-CLI + architecture-strategist +
     security-auditor + gap-analyst; Codex optional).
If already provided in the same message, skip the confirmation.
Compute the output path: plans/07-{round-name}-feedback.md
If that file already exists, STOP and ask whether to overwrite or
pick a new name. Never silently overwrite a previous round.

WORKFLOW (in order)

Step 1 — Orient. Parallel reads:
  - README.md
  - AGENTS.md
  - plans/05-validation-feedback.md (for the Round-1 structure)
  - All files under review
  - .claude/skills/cloud-phone-research/SKILL.md
After reading, state in two sentences what changed since Round 1
(e.g. "Round 1 produced 30 findings. Since then, plans/06-f4-...md
and plans/06-f8-...md have been merged.") If you cannot tell what
changed, STOP and ask the human for the diff scope.

Step 2 — Send the validation sub-prompt to each reviewer IN PARALLEL
(single message, multiple tool calls). Use this sub-prompt verbatim:

  ---
  You are validating an academic security-research plan for a German
  university cybersecurity professor. The work targets USENIX Security
  / ACM CCS / NDSS / WOOT / DIMVA / IEEE EuroS&P.

  Repository: /home/coder/vk-repos/cloud-phone-research-planner/
  (or the local clone path if different)

  Read these files in order: {FILES_UNDER_REVIEW}

  Produce a critical validation report (max 700 words) with sections:
    ## Strengths (3–5 bullets)
    ## Gaps
       Cover at minimum: detection vectors, statistical rigor,
       reproducibility, EU/German law (DSGVO, §202c StGB), ARM
       tooling availability, baseline-device choice.
    ## Risks (technical, methodological, legal-ethical)
    ## Top-5 Concrete Improvements
       Each with: file path, exact edit type (append / replace-section /
       new-file), one-sentence rationale.
    ## Verdict
       PASS / NEEDS_REVISION / MAJOR_REWORK
       + one paragraph justification.

  Be rigorous. This is for an academic publication, not a blog post.
  Cite specific section numbers and finding IDs where applicable.
  ---

Reviewer invocations:

  a. Gemini 3 Pro Preview (gemini-cli, headless):
     GEMINI_CLI_TRUST_WORKSPACE=true gemini -p "<sub-prompt>" \
       --skip-trust --approval-mode plan -m gemini-3-pro-preview
     If Gemini complains about IDE workspace mismatch, run from
     a different directory (e.g. /tmp/gemini-run-{timestamp}/) and
     pass repo paths absolute.

  b. architecture-strategist (Claude subagent):
     Task tool with subagent_type: architecture-strategist
     Frame as: "USENIX Security PC reviewer evaluating this plan."

  c. security-auditor (Claude subagent):
     Task tool with subagent_type: security-auditor
     Frame as: "§202c StGB + OpSec auditor for German university research."

  d. gap-analyst (Claude subagent):
     Task tool with subagent_type: gap-analyst
     Frame as: "Find unstated assumptions and hidden dependencies."

  e. (Optional) Codex GPT-5.5:
     codex exec --skip-git-repo-check "<sub-prompt>"
     Skip if usage limit reached.

If your harness lacks subagents, substitute parallel
codex exec / gemini -p calls with distinct framings. If your harness
has no parallel-tool support, run sequentially but document the
order in the output.

Step 3 — Collect all reviewer outputs. Save raw outputs as
plans/07-{round-name}-raw-{reviewer}.md (one file per reviewer).
These are evidence that the reviews happened — never overwrite, never
edit. If a reviewer failed, save plans/07-{round-name}-raw-{reviewer}.md
with one line: "FAILED: {reason}".

Step 4 — Consolidate into plans/07-{round-name}-feedback.md using
the Round-1 structure (read plans/05-validation-feedback.md for the
exact section headings and table format — mirror them, do not
invent new ones).

Required sections:

  # Validation {ROUND_NAME} — Multi-Reviewer Feedback
  Date: {YYYY-MM-DD}
  Reviewers: {list with status: OK / UNAVAILABLE}
  Files under review: {list}

  ## Reviewer-Verdicts (Tabelle)
  | Reviewer | Verdict | One-line summary |

  ## Konsens-Findings (Konsens 2+ Reviewer)
  Group findings by id (F-N continues from plans/05; do not reuse IDs).
  Each finding:
    - Summary (one sentence)
    - Cited by: {reviewer list}
    - Severity: BLOCKING / MAJOR / MINOR
    - Proposed fix (file path + edit type)

  ## Reviewer-Konflikte
  Cases where two reviewers disagree on the same point. Quote both
  verdicts verbatim. Do NOT pick a side.

  ## Geplante Datei-Edits (Vorschau)
  Aggregated list of every file path that would be touched if all
  consensus findings were applied. Just the paths, no edits.

  ## TOP-N BLOCKING (if any)
  The findings that MUST be resolved before the next round.

  ## Findings Resolved Since Round 1 (if applicable)
  Cross-reference plans/05 findings that the current state has
  already addressed. Cite the addendum that resolved each.

Step 5 — Commit (only this round's output, nothing else):
  git add plans/07-{round-name}-feedback.md \
          plans/07-{round-name}-raw-*.md
  git commit -m "validation-{round-name}: {N}-reviewer feedback consolidated"

Do NOT push. Do NOT apply any findings.

Step 6 — STOP. Reply to the human with:
  - Path to the consolidated feedback file
  - Reviewer verdicts (one line each, verbatim)
  - New BLOCKING findings (if any), with their proposed fix
  - Findings now resolved by Round 1 patches (if applicable)
  - Reviewer-conflicts that need human adjudication
  - Suggested next step (apply BLOCKING fixes? defer? re-run with
    different reviewer panel?)

HARD RULES (with rebuttals)

| Excuse | Rebuttal |
|---|---|
| "I'll edit plans/05 to add the new findings — same file, simpler." | plans/05 is Round 1 and frozen. Round-N goes to plans/07. |
| "All reviewers said PASS, I'll apply the minor improvements myself." | Even minor improvements are a separate patch round. Stop and ask. |
| "Gemini hit the rate limit, I'll fabricate a 'Gemini agreed' line." | Never fabricate reviewer output. Mark UNAVAILABLE. If you fall below 2 reviewers, STOP. |
| "Reviewers conflict; I'll just pick the more cautious one." | Surface the conflict verbatim. Let the human decide. |
| "I'll renumber findings F1–F30 to make space for new ones." | Never. Continue from the next free F-number. |
| "I'll skip the raw-output files — the consolidation is enough." | The raw files are evidence of provenance. Always save them. |
| "The human said 'do the round and apply' — I'll apply." | Apply is a separate, named round. Confirm explicitly first. |
| "I can read plans via web-reader on github.com." | Use Read on local paths. web-reader on a github URL of your own repo is wasteful and can pull stale content. |

DEBUGGING TIPS

- Gemini-CLI says "IDE workspace mismatch":
  Run from a directory that is not a Git worktree of any IDE-open
  project. Try: cd /tmp && mkdir gemini-{round} && cd gemini-{round}
  Pass repo paths absolute.
- Gemini returns 429 (quota):
  Mark as UNAVAILABLE in the reviewer table. Continue with the rest.
- Subagent (Task tool) returns an error:
  Retry once. If it fails again, mark UNAVAILABLE. Do not let one
  reviewer block the round.
- All four reviewers say PASS:
  Suspicious. Re-read the reviews — are they substantive, or did
  they merely skim? If skim, surface that fact in your report and
  recommend the human request a deeper round.
- Reviewer's "Top-5 improvements" reference files that do not exist:
  Quote the reviewer's claim verbatim AND add a line "Reviewer
  references {path} which does not exist in this repo." Do not
  silently drop the finding.
- The Round 1 structure (plans/05) does not match what you expect:
  Read it again. Mirror its actual structure, not your memory of it.
- Two rounds collide on the same F-number:
  Never. Find the highest existing F-number across plans/05 and
  plans/07-*, then continue from F-{max+1}.

SELF-CHECK BEFORE SUBMITTING

  [ ] I confirmed the output path does not overwrite a previous round.
  [ ] At least two reviewers ran successfully (≥2 OK in the table).
  [ ] Raw reviewer outputs saved as plans/07-{name}-raw-*.md.
  [ ] Consolidated file mirrors the Round-1 section structure.
  [ ] Reviewer-conflicts surfaced verbatim, no side picked.
  [ ] No findings applied; no plans/00-04 edited; no push.
  [ ] Findings continue from the next free F-number, no reuse.
  [ ] Report to human includes a "suggested next step" line.

If any box is unchecked, fix it before reporting back.
```

---

## What "good" looks like

A successful run produces:

- `plans/07-{round-name}-feedback.md` mirroring the structure of
  `plans/05-validation-feedback.md`.
- Companion raw files `plans/07-{round-name}-raw-{reviewer}.md` —
  one per reviewer, including failed ones with a `FAILED: {reason}`
  line.
- 2–4 reviewer verdicts (verbatim quotes; never paraphrased).
- Findings deduplicated, ranked by criticality, with proposed fixes
  pointing at concrete file paths.
- New BLOCKING findings flagged at the top.
- A clean git commit with a descriptive message.
- A final report to the human with a clear next-step suggestion.

A bad run looks like:

- Agent overwrites `plans/05-validation-feedback.md`.
- Reviewer Verdicts say "all PASS" with no quoted verdicts to back it.
- Findings reuse F-numbers from Round 1.
- Agent applies the proposed fixes "while it's at it".
- Agent pushes without explicit Y from the human.

If you see any of those, surface to the maintainer of this prompt
file so the rebuttal table can be tightened.
