# Prompt 01 — Extend an Open Finding

Use this prompt when you want an AI agent to take an open Finding from `plans/05-validation-feedback.md` and progress it into a reviewed, ready-for-human-approval addendum.

---

## How to use

1. Open this repository in any AI agent harness (Claude Code, Codex, Gemini CLI, Cursor, …).
2. Copy the prompt below verbatim.
3. Replace `{FINDING_ID}` with the finding ID (e.g. `F4`, `F8`, `F15`).
4. Paste into your agent.

---

## Prompt (copy from here)

```
You are working in /home/coder/vk-repos/cloud-phone-research-planner/ (or its public clone).

Activate the project skill at .claude/skills/cloud-phone-research/SKILL.md and follow it strictly.

Task: progress finding {FINDING_ID} from plans/05-validation-feedback.md into a draft addendum.

Mandatory workflow:

1. Orient — read README.md, AGENTS.md, plans/05-validation-feedback.md (parallel reads, single message).
2. Confirm finding {FINDING_ID} is NOT Legal-Gated (F21/F22/F23). If it is, stop and explain.
3. Research using the right tool (zread for GitHub repos, web-search-prime for academic refs, web-reader for specific URLs).
4. Draft addendum at plans/06-{finding-id}-addendum.md using the template in the skill.
5. Run multi-reviewer validation (≥2 of: Gemini-CLI headless, architecture-strategist subagent, security-auditor subagent, gap-analyst subagent) in parallel.
6. Consolidate verdicts in the addendum's "Reviewer Feedback" section.
7. STOP. Do not edit plans/00–04. Do not commit. Report to me with:
   - Path to the addendum
   - Reviewer verdicts (one line each)
   - Top 3 open questions for me
   - Estimated effort to merge

Hard rules:
- Plan-Immutability: never edit plans/00-master-plan.md through plans/04-deliverables.md
- Scope-Lock: no live-platform tests, no account-farming use cases, no third-party-platform code
- Legal-Gate: F21/F22/F23 are human-only; do not draft "what the answer might be"
- No emojis in code files; emojis only in user-facing markdown
```

---

## What "good" looks like

The agent should reply within 5–15 minutes of work with:
- A new file at `plans/06-{finding-id}-addendum.md` (DRAFT status)
- 2+ reviewer verdicts inside the addendum
- Specific open questions, not generic ones
- An explicit "approve to apply? Y/N" question at the end

If the agent commits or pushes without your Y — that's a skill-violation, surface it to the maintainer.
