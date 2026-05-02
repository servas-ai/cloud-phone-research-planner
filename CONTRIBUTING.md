# Contributing

This is an academic research planner repository under active multi-reviewer validation. Contributions are welcome — but the bar is unusual because Plan-Immutability and Legal-Gate rules govern most surfaces.

## Before you contribute

1. **Read [`AGENTS.md`](AGENTS.md)** if you are an AI agent or use one. Hard rules apply.
2. **Read [`README.md`](README.md)** for current scope, status, and blockers.
3. **Read [`plans/05-validation-feedback.md`](plans/05-validation-feedback.md)** + [`plans/07-round-2-feedback.md`](plans/07-round-2-feedback.md) for open findings and required actions.
4. **Read [`docs/ethics-and-scope.md`](docs/ethics-and-scope.md)** for what the project will and will not do.

## What we accept

| Category | Where | How |
|---|---|---|
| New finding (extending Round 1/2) | open a GitHub Issue using the `finding` template | Reviewer panel will weigh in |
| Addendum to an existing plan | add new file under `plans/06+` or `plans/07+` (NEVER edit `plans/00–04`) | PR with Draft addendum |
| New probe candidate | use [`prompts/02-add-probe.md`](prompts/02-add-probe.md) workflow | Output to `plans/06-new-probe-{slug}-addendum.md` |
| Literature reference | add to a research-note in `docs/research-notes/` first; merge round into `refs/bibliography.md` is human-only | PR |
| Bug in plan-text (typo, broken link) | direct PR is OK on `README`, `docs/research-notes/`, `prompts/`, `experiments/runner/SPEC.md` | Conventional commit style |

## What we do NOT accept

- Direct edits to `plans/00-master-plan.md` through `plans/04-deliverables.md` — these are immutable. Use addenda.
- Live-platform integration (TikTok / Instagram / Snapchat / Roblox / banking apps / etc.) — out of scope.
- Spoofing-tool distribution (Magisk-module dumps, keyboxes, full SpoofStack image hashes) — institutional access only.
- Citations to active DRM-circumvention or §202c-grey-area tooling, even read-only. See [`plans/07-round-2-feedback.md`](plans/07-round-2-feedback.md) Action A1 for the precedent.

## Plan-Immutability — the one rule that overrides everything

Files in `plans/00-master-plan.md` through `plans/04-deliverables.md` cannot be modified during implementation. Even small typo fixes go through the addendum process (`plans/06-…-addendum.md`). Why: human pre-registration on OSF anchors the original text.

If you think you found an actual bug in a frozen plan, open an issue with the `plan-bug` template and let the maintainer decide.

## Legal-Gate findings (F21 / F22 / F23)

Three findings are **off-limits to AI agents and external contributors**:
- F21 — Privileged Docker host-root escape
- F22 — Keybox provenance §259 StGB
- F23 — Reproducibility-pack §202c-recipe risk

These require university legal-department clearance in writing. Do not draft "what the answer might be" — that risks anchoring legal opinion. Use the `legal-blocked` issue template if you encounter one.

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
- [ ] No new external dependency in DetectorLab without ethics review
- [ ] Live-platform-test scope-lock honoured (no TikTok / IG / etc. references)
- [ ] §202c / DSGVO / EU 2021/821 considered for any new tool/citation
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
