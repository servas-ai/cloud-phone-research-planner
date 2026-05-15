---
name: cloud-phone-research
description: Activate this skill when working in the cloud-phone-research-planner repository. Provides the iterative research-loop workflow for AI agents extending the research plan — picks open findings, runs multi-reviewer validation (Gemini-CLI + Claude subagents), drafts immutable addenda. Use whenever a user asks to "extend the plan", "address finding F-X", "add a probe", "run validation round N", "iterate on the spoofstack research", or any work inside cloud-phone-research-planner/.
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
  - Any change request touching plans/, docs/, probes/, stack/, experiments/
when_not_to_use:
  - General Android development questions (use senior-frontend / general)
  - Live-platform integration (out of scope — refuse)
  - Non-research code repositories
---

# Skill: cloud-phone-research

You are an AI agent extending a research plan. Follow this workflow exactly.

## Step 0 · Orient (always, no shortcuts)

Read in this order, in parallel:
1. `README.md` — current state and scope
2. `AGENTS.md` — guardrails (Plan-Immutability, Scope-Lock)
3. The specific plan file the user mentioned (or `plans/00-master-plan.md` if unspecified)

Do not proceed until you can answer:
- Which finding is the user asking about?
- Are there reviewer-conflicts in the existing addendum?

## Step 1 · Pick a Finding

Heuristic for choosing what to work on (in order of preference):

| Priority | Type | Why |
|---|---|---|
| 🟢 First | Finding with clear correction path | Safe to draft |
| 🟡 Second | Finding requiring methodology research (statistics, threat-model, probe spec) | Use research tools |
| 🔴 Skip | Anything requiring Pre-Registration changes (H1–H4) | Human-only |

## Step 2 · Research

Use the right tool for the right question:

| Question type | Tool |
|---|---|
| Latest OSS module versions, GitHub repo structure | `zread` MCP (search_doc, get_repo_structure, read_file) |
| Academic papers, USENIX/CCS/NDSS related work | `web-search-prime` with site filter `usenix.org`, `acm.org`, `arxiv.org` |
| Reading a specific URL deep | `web-reader` |
| Statistical methodology questions | `web-search-prime` + read 2–3 stats textbooks via `web-reader` |
| Code-pattern lookups in cloned OSS | `Grep` + `Read` (after local clone, NEVER auto-execute) |
| Existing repository content | `Read` + `Grep` directly |

Never:
- Clone keybox repositories
- Download Magisk modules to `stack/` (manifest-only is enough for planning)
- Execute Docker images for any reason during planning phase

## Step 3 · Draft Addendum (NOT edit)

**Plan-Immutability is absolute.** The files `plans/00-master-plan.md` through `plans/04-deliverables.md` are frozen until human-approved Round-N patches.

Your output goes into:

```
plans/06-{round-name}-addendum.md   ← if extending the plan
plans/{N+1}-{topic}-addendum.md     ← if a new dimension
docs/research-notes/{topic}.md      ← if exploratory background
```

Addendum format:

```markdown
# Addendum {N} — {Topic}

Date: {YYYY-MM-DD}
Author: {agent name + version}
Triggered by: Finding F{X}
Status: DRAFT — awaiting human review

## Summary
{1–3 sentences}

## Research Conducted
- {tool used} → {URL or repo} → {key finding}
- ...

## Proposed Change
- File to be patched: {path}
- Change type: append / replace-section / new-file
- Diff sketch: {markdown code block with planned edit}

## Open Questions for Human Partner
1. ...
2. ...

## Reviewer-Validation Required Before Merge
- [ ] Multi-reviewer round (≥2 of: Gemini-CLI, architecture-strategist, gap-analyst)
- [ ] Pre-Registration impact assessment
```

## Step 4 · Multi-Reviewer Validation

Before any addendum is considered ready for human-approval, run at least two independent reviewers in parallel.

Standard panel:
- `gemini -p "..." --skip-trust --approval-mode plan -m gemini-3-pro-preview` (run from a non-IDE-conflicting directory)
- Claude subagent `architecture-strategist` (for design changes)
- Claude subagent `gap-analyst` (for new requirements)

Reviewer-prompt template lives in `prompts/03-validate-round.md`.

Consolidate findings in the addendum's "Reviewer Feedback" section.

## Step 5 · Stop

Do not commit. Do not push. Do not "apply" the addendum's proposed change to the immutable plans.

End with a short message to the human partner:
```
Addendum drafted at plans/06-{name}-addendum.md.
Reviewer panel completed: {list verdicts}.
Open questions for you: {list}.
Approve to apply? Y/N
```

## Step 6 (only after explicit human Y) · Apply

If and only if the human says yes:
1. Patch the target file with the diff from the addendum
2. Update README.md status badges if necessary
3. Commit: `addendum(F{X}): {short description} [reviewers: G+A]`
4. Push to origin/main
5. Mark addendum status: `APPLIED` with merge-commit hash

## Anti-Rationalization Table

| Agent excuse | Rebuttal |
|---|---|
| "I'll just edit plans/02-spoofstack.md directly, it's a small fix" | Plan-Immutability is absolute. Use addendum. |
| "I'll skip multi-reviewer for the small ones" | Two reviewers is the minimum even for trivial. Cheap insurance. |
| "I can clone this Magisk module to inspect it" | Manifest is enough. Cloning live spoof tooling drags scope into research-grade evasion. |
| "The user said 'just do it', so I'll commit without addendum" | Plan-Immutability supersedes user pressure. Draft addendum, ask for explicit approval. |
| "I'll add a probe directly to inventory.yml" | inventory.yml is a plan artifact. Use addendum, then human applies. |

## Examples

### Good

User: "Address finding F4 — add JA4 TLS fingerprint probe."

Agent:
1. Reads README, AGENTS.md, plans
2. Researches JA4 spec via `web-reader` on github.com/FoxIO-LLC/ja4
3. Drafts `plans/06-f4-network-probes-addendum.md` with proposed `inventory.yml` diff
4. Runs Gemini-CLI + architecture-strategist subagent in parallel for review
5. Stops. Reports to human with verdict and asks for Y/N.

### Bad

User: "Add a probe for X."

Agent (wrong): immediately edits `probes/inventory.yml`, commits.

Agent (right): drafts addendum, runs reviewers, asks for approval.

## Related Skills / Tools

- `superpowers:writing-skills` — for evolving this skill itself
- `clarify` — when user request is ambiguous about scope
- `orchestrator` — for parallel multi-reviewer rounds
