# Prompt 03 — Run a Fresh Multi-Reviewer Validation Round

Use this prompt when you want an AI agent to orchestrate a complete validation round across multiple reviewers (Gemini-CLI + Claude subagents) on the current state of the plans.

This is the prompt that produced `plans/05-validation-feedback.md` (Round 1). Use it for Round 2, Round 3, etc.

---

## How to use

1. Decide on a round name (e.g. `round-2`, `round-3-post-legal-clearance`).
2. Decide on which files are under review (default: all of `plans/00-04` + the latest addenda).
3. Copy the prompt below, replace `{ROUND_NAME}` and `{FILES_UNDER_REVIEW}`.
4. Paste into your agent.

---

## Prompt (copy from here)

```
You are working in /home/coder/vk-repos/cloud-phone-research-planner/.

Activate .claude/skills/cloud-phone-research/SKILL.md and follow it strictly.

Task: run validation {ROUND_NAME} of the academic research plan.

Files under review: {FILES_UNDER_REVIEW}
(Default if unspecified: README.md + plans/00-04 + plans/05-validation-feedback.md + all addenda in plans/06+)

Workflow:

1. Orient: read README.md, AGENTS.md, plans/05-validation-feedback.md, all files-under-review (parallel).
2. For each reviewer below, send the same validation-prompt (see template at end) IN PARALLEL:

   a. Gemini 3 Pro Preview (gemini-cli, headless):
      Command: GEMINI_CLI_TRUST_WORKSPACE=true gemini -p "<prompt>" --skip-trust --approval-mode plan -m gemini-3-pro-preview
      Run from a non-IDE-conflicting directory if Gemini complains about IDE workspace mismatch.

   b. architecture-strategist (Claude subagent):
      Use the Task tool with subagent_type: architecture-strategist
      Frame as: "USENIX Security PC reviewer evaluating this academic plan"

   c. security-auditor (Claude subagent):
      Use the Task tool with subagent_type: security-auditor
      Frame as: "§202c StGB + OpSec auditor for German university research"

   d. gap-analyst (Claude subagent):
      Use the Task tool with subagent_type: gap-analyst
      Frame as: "find unstated assumptions and hidden dependencies"

   e. (Optional, if available) Codex GPT-5.5:
      Command: codex exec --skip-git-repo-check "<prompt>"
      Skip if usage limit reached.

3. Collect all four reviewer outputs.
4. Consolidate into plans/07-{round-name}-feedback.md (do NOT overwrite plans/05).
   Use the same structure as plans/05-validation-feedback.md:
     - Reviewer-Verdicts table
     - Konsens-Findings (Konsens 2+ Reviewer)
     - Reviewer-Konflikte
     - Geplante Datei-Edits (Vorschau)
     - TOP-N BLOCKING (if any)
5. Commit:
   git add plans/07-{round-name}-feedback.md
   git commit -m "validation-{round-name}: 4-reviewer feedback consolidated"
6. STOP. Report to me:
   - Path to consolidated feedback
   - Verdict summary (one line per reviewer)
   - New BLOCKING findings (if any)
   - Findings now resolved by Round 1 patches (if applicable)

Hard rules:
- Do NOT edit plans/05-validation-feedback.md (that's Round 1, frozen)
- Do NOT apply any of the new findings — just consolidate
- If any reviewer fails (usage limit, IDE mismatch, etc.) — note in the report, do not block on it

Validation-prompt template to send to each reviewer:

  ---
  You are validating an academic security research plan for a German university cybersecurity professor.

  Repository: /home/coder/vk-repos/cloud-phone-research-planner/

  Read these files in order: {FILES_UNDER_REVIEW}

  Then produce a critical validation report (max 700 words) with sections:
  ## Strengths (3–5 bullets)
  ## Gaps (detection vectors, statistical rigor, reproducibility, EU/German law, ARM tooling, baselines)
  ## Risks (technical, methodological)
  ## Top-5 Concrete Improvements (with file paths and exact edits)
  ## Verdict (PASS / NEEDS_REVISION / MAJOR_REWORK + one paragraph justification)

  Be rigorous. This is for an academic publication at USENIX/CCS/NDSS.
  ---
```

---

## What "good" looks like

The agent should produce:
- A new file `plans/07-{round-name}-feedback.md` mirroring the structure of `plans/05`
- 4 reviewer verdicts (or 3 + 1 marked unavailable)
- Findings deduplicated and ranked by criticality
- New blockers (if any) flagged at the top
- A clean git commit with descriptive message

The agent should NOT:
- Apply any of the findings (that's a separate human-approved patch round)
- Modify `plans/05-validation-feedback.md`
- Push without explicit human Y

---

## When to run a fresh round

- After every Round-N patch is applied (verify regression-free)
- Before submitting to a paper venue (final pre-submission gate)
- After major OSS-tool version changes (Magisk, ReDroid, PIF) that invalidate prior assumptions
- Before any external collaborator joins (re-baseline)
- Quarterly if research is long-running
