---
name: cloud-phone-research
description: Activate this skill when working in the cloud-phone-research-planner repository. Provides the research-loop workflow for AI agents extending the plan — picks open findings, optionally runs multi-reviewer validation, drafts addenda. Use whenever a user asks to "extend the plan", "address finding F-X", "add a probe", "run validation round N", "iterate on the spoofstack research", or any work inside cloud-phone-research-planner/.
trigger_patterns:
  - "extend the plan"
  - "address finding F"
  - "add probe"
  - "run validation round"
  - "iterate on cloud-phone"
  - "work on spoofstack"
  - "improve detectorlab plan"
when_to_use:
  - Working inside /home/coder/vk-repos/cloud-phone-research-planner/ (or its public clone)
  - User mentions "DetectorLab", "SpoofStack", "ReDroid research"
when_not_to_use:
  - General Android development questions (use senior-frontend / general)
  - Non-research code repositories
---

# Skill: cloud-phone-research

You are an AI agent extending a research plan.

## Step 0 · Orient

Read in this order, in parallel:
1. `README.md` — current state and scope
2. `AGENTS.md` — guardrails
3. The specific plan file the user mentioned (or `plans/00-master-plan.md` if unspecified)

## Step 1 · Pick a Finding

Choose what to work on based on the user's request and the project state.

## Step 2 · Research

Use the right tool for the right question:

| Question type | Tool |
|---|---|
| Latest OSS module versions, GitHub repo structure | `zread` MCP (search_doc, get_repo_structure, read_file) |
| Academic papers, USENIX/CCS/NDSS related work | `web-search-prime` with site filter `usenix.org`, `acm.org`, `arxiv.org` |
| Reading a specific URL deep | `web-reader` |
| Code-pattern lookups | `Grep` + `Read` |
| Existing repository content | `Read` + `Grep` directly |

## Step 3 · Draft / Edit

Edit existing plan files or create new addenda as appropriate. Use markdown.

Addendum format:

```markdown
# Addendum {N} — {Topic}

Date: {YYYY-MM-DD}
Author: {agent name + version}
Triggered by: Finding F{X}

## Summary
{1–3 sentences}

## Research Conducted
- {tool used} → {URL or repo} → {key finding}

## Proposed Change
- File to be patched: {path}
- Change type: append / replace-section / new-file
- Diff sketch: {markdown code block with planned edit}
```

## Step 4 · (Optional) Multi-Reviewer Validation

If you want extra rigor, run reviewers in parallel:
- `gemini -p "..." --skip-trust --approval-mode plan -m gemini-3-pro-preview`
- Claude subagent `architecture-strategist`
- Claude subagent `gap-analyst`

Reviewer-prompt template lives in `prompts/03-validate-round.md`.

## Related Skills / Tools

- `clarify` — when user request is ambiguous about scope
- `orchestrator` — for parallel multi-reviewer rounds
