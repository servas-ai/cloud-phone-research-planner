# prompts/ — Agent Onboarding Prompts

This directory ships paste-ready prompts that drive AI agents through the
research-loop of this planner. They are meta-tooling, not plan artifacts:
direct edits are fine, but keep diffs small and focused.

---

## Philosophy

These prompts solve one problem: **an agent that has zero prior context
about this repo must succeed on the first try.** No back-and-forth, no
hallucinated file paths, no skipped guardrails.

Three design rules:

1. **Self-orienting.** Every prompt opens with mandatory reads (README,
   AGENTS.md, the relevant plan file). The agent cannot proceed without
   them. This catches drift between agent runs.

2. **Stop-conditions are explicit.** The agent must pause at named gates
   (multi-reviewer disagreement). No
   "best-guess" continuation past a stop-condition.

3. **Harness-portable.** Prompts work across Claude Code, Codex CLI,
   Gemini CLI, Cursor, Aider, OpenCode, OME, and generic GPT-class tools.
   Tool-specific tricks (Claude personas, Codex apply_patch, Gemini
   thinking blocks) are confined to optional sections labelled "If your
   harness supports X".

---

## Use-case map

| Prompt file | Use when… | Output artefact |
|---|---|---|
| `01-extend-finding.md` | A reviewer finding (F1–F30) needs to be progressed into a draft addendum. | `plans/06-{finding-id}-addendum.md` |
| `02-add-probe.md` | You want to propose a new detection probe (beyond the inventory's 60 + 14). | `plans/06-new-probe-{slug}-addendum.md` |
| `03-validate-round.md` | You need a fresh multi-reviewer validation round (Round 2, 3, …). | `plans/07-{round-name}-feedback.md` |

If your task does not fit one of those three, **don't pick the closest
prompt and force it.** Either:

- Write the request as plain English to the agent and let it choose, or
- Add a new prompt (see "Extending this directory" below).

---

## 5-layer prompt architecture

Each prompt follows the same five layers, in order. This is what makes
them swappable across harnesses.

| Layer | What it is | Why it matters |
|---|---|---|
| **1. Role** | One sentence: who the agent is *for this task*. | Anchors the agent's perspective. NOT "you are a helpful assistant" — that is lazy. We say "you are progressing finding F-X into a reviewed addendum". |
| **2. Context** | What repo, what files, what guardrails apply. | Cuts hallucination. Forces the agent to read the right files before acting. |
| **3. Task** | The numbered workflow, in order. | Makes the work auditable. A reviewer can say "step 4 was skipped". |
| **4. Constraints** | Hard rules, anti-rationalization rebuttals, stop-conditions. | Prevents the predictable failure modes (fabricating reviewer verdicts). |
| **5. Output format** | Exactly what the agent must produce, in what shape. | Reviewers can grade the result against a checklist. |

A "self-check before submitting" checklist sits at the end of each prompt.
It is the agent's last gate before reporting back to the human.

---

## Configuration block, then paste-block

Every prompt has two zones:

1. **Configuration** (above the paste-block) — human-readable. This is
   where you put the actual values for your run (which finding ID,
   which probe, which round name). Read this section, decide your
   inputs, *then* go to the paste-block.

2. **Paste-block** (the fenced code block) — this is what you copy
   into the agent. It contains **no `{PLACEHOLDER}` syntax.** Instead,
   the paste-block instructs the agent to confirm inputs with you at
   the start. This is more robust because:
   - Some harnesses strip or escape `{...}`.
   - Forgetting to substitute a placeholder is a common silent failure.
   - Asking the user for inputs forces a sanity check before work begins.

If you prefer to pre-fill values, just edit the paste-block locally
before pasting. That is supported but not required.

---

## Harness compatibility

| Harness | Notes |
|---|---|
| **Claude Code** | Auto-loads the project skill via `.claude/skills/`. Subagent calls (`architecture-strategist`, `security-auditor`, `gap-analyst`) work natively. Use the Task tool. |
| **Codex CLI** | No subagent system. Replace each Claude subagent with a parallel `codex exec --skip-git-repo-check "<reviewer-prompt>"` call. The agent must explicitly note in its report which reviewers it used. |
| **Gemini CLI** | Use `gemini -p "..." --skip-trust --approval-mode plan -m gemini-3-pro-preview`. Run from a directory that does not conflict with your IDE workspace, or Gemini will refuse. Hits a usage cap quickly — degrade gracefully if 429. |
| **Cursor** | Activate the skill manually (Cursor does not auto-discover `.claude/skills/`). Paste the SKILL.md content into the conversation once at the start of the session. |
| **Aider** | Treat the prompt as the initial `/run` instruction. Aider does not have built-in subagents; use it for the addendum-drafting half, then run reviewers manually via Gemini-CLI / Codex. |
| **OpenCode / OME** | Spawn one OME run per reviewer in parallel. Use the OpenCode-specific delegation pattern (see `opencode-live-ops` skill if available). |
| **Generic GPT-class (no tools)** | Strip the workflow steps that require tool use; ask the model to *describe* the addendum it would draft and the reviewer prompts it would send. The output is a planning artefact, not a finished addendum — apply manually. |

If a harness lacks a feature (no subagents, no web access, no MCP tools),
the prompt's "Debugging tips" section tells the agent how to degrade.
Never fabricate reviewer verdicts. Always report which steps were
skipped.

---

## Tool-use guidance specific to this repo

These tools (when available) are the right ones for the right questions:

| Question | Right tool | Wrong tool |
|---|---|---|
| "What does GitHub repo X look like?" | `zread` MCP (`get_repo_structure`, `read_file`, `search_doc`) | Cloning the repo. |
| "Latest version of OSS module Y?" | `web-search-prime` with `search_recency_filter: oneMonth` | Training-data recall. |
| "Read this specific URL deep" | `web-reader` | `web-search-prime` (returns summaries, not full content). |
| "What does our local file Z contain?" | `Read` + `Grep` | `web-reader` on a github.com URL of the same file. |
| "Find all probes that touch /proc" | `Grep` (text search) | `ast-grep` (overkill for this). |
| "Find all functions that *call* `subprocess.run` (containment)" | `ast-grep` MCP | `Grep` (cannot express containment). |
| "Analyse this screenshot of a paper figure" | `zai-mcp-server` (`image_analysis`, `understand_technical_diagram`) | OCR by hand. |

**Never** clone keybox repositories, download Magisk modules, or run
SpoofStack docker images during planning. Manifest-only is enough.

---

## Extending this directory

To add a new prompt (call it `04-foo.md`):

1. **Confirm it does not duplicate an existing prompt.** If it is a
   variation, extend the existing prompt with a "Variant: foo" section.
2. **Apply the 5-layer architecture.** Role, Context, Task, Constraints,
   Output. No exceptions.
3. **Stay under 400 lines.** Length is not quality. Cut anything that
   does not change agent behaviour.
4. **Test mentally against a zero-context agent.** Read your prompt as
   if you had never seen this repo. Would you succeed?
5. **Add to the Use-case map** in this README.
6. **Test on at least two harnesses.** Claude Code + one of (Codex CLI,
   Gemini CLI, Aider). Note any harness-specific issues in the
   "Harness compatibility" section of the new prompt.
7. **Reference from `AGENTS.md`** "Useful prompt templates" section.

---

## What we rejected

For the record, these patterns were considered and dropped:

- **"You are a helpful assistant" openers.** Lazy, model-specific,
  and trains the agent to be sycophantic instead of rigorous.
- **`{PLACEHOLDER}` syntax inside the paste-block.** Brittle across
  harnesses and a frequent silent-failure cause.
- **Long persona descriptions** ("You are a USENIX Security PC member
  with 15 years of experience…"). The framing for reviewers belongs
  in the *reviewer-sub-prompt*, not the orchestrator prompt.
- **Embedded shell commands without explanation.** Replaced with
  command + one-line rationale + degrade-gracefully fallback.
- **Mandatory chain-of-thought blocks for trivial steps.** CoT is
  added only where it materially changes output quality (probe
  justification, reviewer-conflict resolution).
