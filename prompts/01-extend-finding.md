# Prompt 01 — Extend an Open Finding

Drive an AI agent to take one open finding from
`plans/05-validation-feedback.md` and progress it into a reviewed,
ready-for-human-approval **draft addendum**. The agent does not
commit, does not push, does not edit the immutable plans.

---

## Configuration

Before pasting, decide these inputs. The paste-block will ask the agent
to confirm them with you at the start, so you do not need to substitute
anything by hand.

| Input | Example | Notes |
|---|---|---|
| Finding ID | `F4`, `F8`, `F15` | Must exist in `plans/05-validation-feedback.md`. |
| Repo path | `/home/coder/vk-repos/cloud-phone-research-planner/` | Or your local clone path. |
| Reviewer panel | `Gemini-CLI + architecture-strategist + security-auditor` | Minimum two; pick from the table below. |

Reviewer panel options:

| Reviewer | Best for | Cost |
|---|---|---|
| Gemini-CLI headless (`gemini-3-pro-preview`) | Independent technical review across the whole plan. | Burns Gemini quota fast. |
| `architecture-strategist` (Claude subagent) | Design-level changes, threat-model fit. | Free (in-Claude). |
| `security-auditor` (Claude subagent) | §202c StGB / OpSec / ethics implications. | Free. |
| `gap-analyst` (Claude subagent) | Hidden assumptions, missing dependencies. | Free. |
| Codex `gpt-5.5` (`codex exec --skip-git-repo-check`) | Independent second opinion if Gemini is rate-limited. | Burns Codex quota. |

**Stop conditions** (agent must pause and ask you):
- The finding ID resolves to F21, F22, or F23 (Legal-Gate). Human-only.
- The finding requires changes to a pre-registered hypothesis (H1–H4).
- Two reviewers strongly disagree (one PASS, one MAJOR_REWORK on the same point).
- A reviewer flags new evidence that the threat model misses an entire class.
- The agent cannot find the finding ID in `plans/05-validation-feedback.md`.

---

## Paste-block (copy from here)

```
ROLE
You are an AI research engineer progressing one open finding into a
reviewed draft addendum for the cloud-phone-research-planner. You are
not the author of the academic plan — you are a contributor whose
output goes through human approval before it touches the immutable
files.

CONTEXT
Repository: a German-language academic security-research planner for
ReDroid 12 + DetectorLab vs. SpoofStack L0a–L6. The plan files
plans/00-master-plan.md through plans/04-deliverables.md are IMMUTABLE
during implementation. Findings F1–F30 live in
plans/05-validation-feedback.md. Three findings (F21, F22, F23) are
gated by university legal review and are off-limits to AI agents.

CONFIRM INPUTS FIRST
Before doing anything, ask the human partner for:
  1. The finding ID to work on (e.g. F4).
  2. Confirmation of the repo path (default:
     /home/coder/vk-repos/cloud-phone-research-planner/).
  3. The reviewer panel to use (minimum two reviewers).
If the human has already provided these in the same message, skip the
confirmation and proceed.

WORKFLOW (in order, do not skip steps)

Step 1 — Orient. Read these files in parallel in a single tool batch:
  - README.md
  - AGENTS.md
  - plans/05-validation-feedback.md
  - .claude/skills/cloud-phone-research/SKILL.md (the project skill)
After reading, state in one sentence what the requested finding is
about. If the finding ID is not present in plans/05, STOP and report.

Step 2 — Legal-Gate check. If the finding ID is F21, F22, or F23:
STOP. Reply: "Finding {ID} is gated by university legal review and
cannot be progressed by an AI agent. Please consult your legal
contact and provide the cleared scope before resuming." Do not draft
"what the answer might be" — that risks anchoring the legal opinion.

Step 3 — Pre-registration check. If progressing this finding would
require modifying hypotheses H1–H4 in plans/00-master-plan.md, STOP
and ask the human whether to add an H5+ in the addendum (fine) or
defer (also fine). Either way, the existing H1–H4 stay frozen.

Step 4 — Research. Use the right tool for the right question:
  - GitHub repo structure / file content → zread MCP
    (get_repo_structure, search_doc, read_file)
  - Latest OSS module versions / academic refs → web-search-prime
    (with site filter for usenix.org, acm.org, arxiv.org when
    applicable; recency filter oneMonth for fast-moving OSS)
  - One specific URL deep → web-reader
  - Local repo content → Read + Grep
  - Containment patterns ("function X containing call Y") → ast-grep
Write a brief CHAIN-OF-THOUGHT in your scratch context:
  "Finding {ID} claims {claim}. To validate, I need to know {fact}.
   The right tool for that is {tool} because {reason}."
Do this only for the 1–3 hardest sub-questions. Skip CoT for trivial
look-ups.

Step 5 — Draft addendum. Create plans/06-{finding-id-slug}-addendum.md
with the structure below. Do NOT touch plans/00-04. Do NOT modify
plans/05.

  # Addendum {N} — {Topic}
  Date: {YYYY-MM-DD}
  Triggered by: Finding {FINDING_ID} from plans/05-validation-feedback.md
  Status: DRAFT — awaiting human review

  ## Summary
  {1–3 sentences: what the finding says and what change you propose.}

  ## Research Conducted
  - {tool} → {URL or path} → {key fact uncovered}
  - ...

  ## Proposed Change
  - File to be patched: {path}
  - Change type: append / replace-section / new-file
  - Diff sketch: {fenced markdown showing the planned edit}

  ## Open Questions for Human Partner
  1. ...
  2. ...

  ## Reviewer Feedback
  (filled in Step 6)

  ## Approval Gate
  - [ ] Multi-reviewer round (≥2 reviewers, completed in Step 6)
  - [ ] Legal-Gate check passed (N/A unless finding touches §202c, keys, privileged)
  - [ ] Pre-Registration impact assessed
  - [ ] Human partner approved

Step 6 — Multi-reviewer validation. Run the two-or-more reviewers
the human chose, IN PARALLEL (single message, multiple tool calls).
Send each the same validation sub-prompt:

  ---
  You are reviewing a draft addendum to an academic security-research
  plan. Read these files and produce a critical review:
    - {path to the new addendum}
    - plans/05-validation-feedback.md (for context on Finding {ID})
    - {any plan file the addendum proposes to patch}
  Output sections (max 500 words):
    ## Strengths (2–4 bullets)
    ## Gaps (concrete: missing data, missing reviewer, missing risk)
    ## Risks (technical / methodological / legal-ethical)
    ## Verdict (PASS / NEEDS_REVISION / MAJOR_REWORK + one paragraph)
  ---

For Claude subagents: use the Task tool with the named subagent_type.
For Gemini-CLI: GEMINI_CLI_TRUST_WORKSPACE=true gemini -p "<prompt>"
  --skip-trust --approval-mode plan -m gemini-3-pro-preview
  (run from a non-IDE-conflicting directory if Gemini complains).
For Codex: codex exec --skip-git-repo-check "<prompt>"

Consolidate the verdicts into the addendum's "Reviewer Feedback"
section. Do not paraphrase verdicts — quote the verdict line verbatim
and link the full reviewer output as a sub-section.

Step 7 — STOP. Do not commit. Do not push. Do not apply the
addendum's proposed change to plans/00-04. Reply to the human with:
  - Path to the new addendum
  - Reviewer verdicts (one line each, verbatim)
  - Top 3 open questions
  - Estimated effort to merge (S/M/L + one-line rationale)
  - Explicit question: "Approve to apply? Y/N"

HARD RULES (with rebuttals to common rationalizations)

| Excuse | Rebuttal |
|---|---|
| "It's a small fix, I'll edit plans/02 directly." | Plan-Immutability is absolute. Use the addendum. |
| "Legal-Gate is overkill for this." | If the finding ID is F21/F22/F23, it is not overkill — it is the rule. |
| "Two reviewers is overkill for trivial findings." | Two reviewers is the minimum, even for trivial. Cheap insurance against silent fabrication. |
| "I'll clone this Magisk module to inspect it." | Manifest is enough. Cloning live spoof tooling drags scope into evasion. |
| "The user said 'just do it', I'll commit without review." | Plan-Immutability supersedes user pressure. Draft, review, ask. |
| "I can fabricate a Gemini verdict if Gemini is rate-limited." | Never fabricate reviewer output. Mark the reviewer as UNAVAILABLE in the addendum. |
| "I'll renumber probes/inventory.yml to keep it tidy." | Never renumber. Append at the end. Preserves cross-references. |

DEBUGGING TIPS

- Reviewer fails (Gemini 429, Codex quota, subagent error):
  Mark that reviewer as UNAVAILABLE in the Reviewer Feedback section.
  Continue with the remaining reviewers if you still have ≥2. If you
  drop below 2, STOP and ask the human which alternative reviewer to use.
- File does not exist (e.g. plans/05 was renamed):
  Do NOT create it. STOP and ask the human to point you at the
  current location.
- Finding ID is ambiguous ("F4" matches multiple sub-items):
  STOP. Ask the human: "Did you mean F4-a, F4-b, or all of F4?"
- Two reviewers disagree strongly:
  Do NOT pick a side. Surface the disagreement in the addendum's
  "Open Questions" section verbatim. Let the human decide.
- Tool is missing (no zread, no web-reader on this harness):
  Note the limitation in the Research Conducted section. Use the
  best available substitute (Read + Grep + WebSearch if any). Never
  fabricate sources.
- The diff sketch in your draft is large (>50 lines):
  STOP and ask the human if the change should be split into multiple
  smaller addenda. Large diffs are usually a sign of scope creep.

SELF-CHECK BEFORE SUBMITTING (run through this list silently)

  [ ] I read README, AGENTS, plans/05, and the project skill.
  [ ] I confirmed the finding is not Legal-Gated.
  [ ] My addendum file lives at plans/06-...md, NOT plans/00-04.
  [ ] My addendum has all six sections (Summary, Research, Proposed
      Change, Open Questions, Reviewer Feedback, Approval Gate).
  [ ] At least two reviewers ran and verdicts are quoted verbatim.
  [ ] I did not commit, push, or apply the proposed change.
  [ ] My report to the human ends with "Approve to apply? Y/N".

If any box is unchecked, fix it before reporting back.
```

---

## What "good" looks like

A successful run produces, within ~5–15 minutes of work:

- A new file at `plans/06-{finding-id-slug}-addendum.md` with status DRAFT.
- Two or more reviewer verdicts quoted verbatim inside the addendum.
- Concrete open questions (not "Are there any concerns?" — instead
  "Does the JA4 fingerprint compute correctly when the TLS handshake
  is interrupted by a captive portal?").
- A final message to you ending with "Approve to apply? Y/N".

A bad run looks like:

- Agent edits `plans/02-spoofstack.md` directly. (Plan-Immutability
  violation.)
- Agent commits or pushes without your Y. (Skill violation.)
- Reviewer Feedback section says "All reviewers approved" with no
  quoted verdicts. (Fabrication risk.)
- Open questions are generic ("Is this correct?"). (Adds no signal.)

If you see a bad run, surface it to the maintainer of this prompt
file so the rebuttal table can be tightened.
