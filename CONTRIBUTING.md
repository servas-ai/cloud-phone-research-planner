# Contributing

This is a research planner repository under active multi-reviewer validation. Plan-Immutability governs most surfaces.

## Before you contribute

1. **Read [`AGENTS.md`](AGENTS.md)** if you are an AI agent or use one. Hard rules apply.
2. **Read [`README.md`](README.md)** for current scope and status.
3. **Read [`plans/00-master-plan.md`](plans/00-master-plan.md)** for the master plan.

## What we accept

| Category | Where | How |
|---|---|---|
| New finding | open a GitHub Issue using the `finding` template | Reviewer panel will weigh in |
| Addendum to an existing plan | add new file under `plans/06+` (NEVER edit `plans/00–04`) | PR with Draft addendum |
| New probe candidate | use [`prompts/02-add-probe.md`](prompts/02-add-probe.md) workflow | Output to `plans/06-new-probe-{slug}-addendum.md` |
| Literature reference | add to a research-note in `docs/research-notes/` first; merge round into `refs/bibliography.md` is human-only | PR |
| Bug in plan-text (typo, broken link) | direct PR is OK on `README`, `docs/research-notes/`, `prompts/`, `experiments/runner/SPEC.md` | Conventional commit style |

## What we do NOT accept

- Direct edits to `plans/00-master-plan.md` through `plans/04-deliverables.md` — these are immutable. Use addenda.
- Live-platform integration (TikTok / Instagram / Snapchat / Roblox / banking apps / etc.) — out of scope.
- Spoofing-tool distribution (Magisk-module dumps, keyboxes, full SpoofStack image hashes) — institutional access only.

## Plan-Immutability — the one rule that overrides everything

Files in `plans/00-master-plan.md` through `plans/04-deliverables.md` cannot be modified during implementation. Even small typo fixes go through the addendum process (`plans/06-…-addendum.md`).

If you think you found an actual bug in a frozen plan, open an issue with the `plan-bug` template and let the maintainer decide.

## Conventional commits

| Type | When |
|---|---|
| `addendum(F-id):` | Drafting a new addendum (`plans/06+`) |
| `validation-round-N:` | Multi-reviewer validation outputs |
| `research(round-N-prep):` | New research notes feeding a future round |
| `docs(readme):` | README polish |
| `feat(agents):` | Agent-tooling (skill, prompts, AGENTS.md) |
| `fix(typo):` | Pure typos in non-frozen files |

## PR checklist

- [ ] No edit to `plans/00-04` (or explicit human-approved exception with addendum link)
- [ ] No edit to `docs/threat-model.md`, `refs/bibliography.md`, `probes/inventory.yml` without research-note + reviewer round
- [ ] Live-platform-test scope-lock honoured (no TikTok / IG / etc. references)
- [ ] If adding probes: passed multi-reviewer round (≥2 reviewers)
- [ ] Mermaid diagrams render on GitHub (preview the PR)
- [ ] Conventional commit message

## Multi-reviewer validation rounds

Major addenda go through a 4-reviewer panel (Gemini-CLI + Claude subagents). Use [`prompts/03-validate-round.md`](prompts/03-validate-round.md) to orchestrate. The verified Gemini-CLI invocation is:

```bash
GEMINI_CLI_TRUST_WORKSPACE=true gemini -p "$(cat prompt.md)" \
  --skip-trust --approval-mode plan -m gemini-3-pro-preview
```

The `[ERROR] [IDEClient] Directory mismatch` warning is non-fatal.

## Code of Conduct

This repository follows the [Contributor Covenant 2.1](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). Be excellent to each other. Academic disagreement welcome; ad-hominem not.

## Questions

Open a GitHub Discussion (preferred) or an Issue with the `question` template.
