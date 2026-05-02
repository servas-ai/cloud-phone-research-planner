# 🤖 AGENTS.md — Instructions for AI Agents

> **If you are an AI agent (Claude Code · Codex · Gemini CLI · Cursor · Aider · OpenCode · OME · Continue · any other) and you have been pointed at this repository, READ THIS FILE FIRST before doing anything else.**

---

## 🎯 You are entering an academic security-research planner repository

**Repository purpose:** Plans, tracks, and validates a 12-week cybersecurity research project on Android container detection resistance (ReDroid 12 + DetectorLab vs. SpoofStack L0a–L6).

**You are NOT here to:**
- ❌ Build TikTok/Instagram bots, account farms, or evasion tools
- ❌ Test against live third-party platforms
- ❌ Source keyboxes from leaked/forum/community channels
- ❌ Add features that violate §202c StGB or §259 StGB

**You ARE here to:**
- ✅ Extend the planning artifacts (markdown plans, probe inventory, threat model)
- ✅ Answer the research question with academic rigor
- ✅ Address open findings in `plans/05-validation-feedback.md`
- ✅ Help draft IRB application, OSF pre-registration, paper outline
- ✅ Implement DetectorLab probes (Kotlin, after legal clearance)
- ✅ Improve reproducibility, statistical methodology, threat-model coverage

---

## 🔌 Activate the project skill

This repository ships an embedded skill at `.claude/skills/cloud-phone-research/SKILL.md` (also discoverable as a generic `SKILL.md` for tools that don't use Claude's `.claude/` convention).

**For Claude Code:** the skill is auto-loaded when you cd into this directory.
**For other agents:** read `.claude/skills/cloud-phone-research/SKILL.md` directly and follow its workflow.

The skill defines:
1. **Plan-Immutability protocol** — never edit `plans/00–04` directly; use addenda
2. **Research-Loop workflow** — how to pick open findings and progress them
3. **Multi-reviewer validation pattern** — Gemini-CLI + Claude subagents in parallel
4. **Legal-gate enforcement** — F21/F22/F23 must be cleared by humans before code
5. **Output format** — what counts as a valid contribution to this repo

---

## 📜 Hard rules (non-negotiable)

1. **Plan-Immutability** — `plans/00-master-plan.md` through `plans/04-deliverables.md` are immutable during implementation. Add findings/changes as `plans/05-…`, `plans/06-…`, etc. Never overwrite.

2. **Legal-Gate before code** — Findings F21 (privileged Docker), F22 (keybox provenance), F23 (reproducibility-pack §202c) MUST be cleared by the university legal department in writing before any DetectorLab/SpoofStack code is written. If you are tempted to "just start the Kotlin skeleton" — stop. The skeleton is fine; the SpoofStack docker-compose with `privileged: true` is not.

3. **Scope-Lock** — DetectorLab is the sole testing target. No code, no documentation, no commit message that references testing against TikTok, Instagram, Snapchat, X, Facebook, Roblox, banking apps, or any other live platform. The product of this research is a **measurement instrument and a methodology paper**, not a bypass.

4. **Reproducibility split** — Public repository contains only what is publishable under §202c StGB and EU 2021/821 (Dual-Use). Sensitive material (keyboxes, exact module-version manifests, container-image hashes that enable full SpoofStack reconstruction) goes into the institutional repository, never here.

5. **Pre-Registration discipline** — Hypotheses H1–H4 in `plans/00-master-plan.md` are intended for OSF pre-registration before any data is collected. Do not silently change them. If you propose a new hypothesis, add it as H5+ in an addendum and flag for re-registration.

6. **No emoji-bombing** — User code conventions: emojis only in user-facing markdown (README, plans), never in code files.

---

## 🔄 Recommended Research-Loop for AI agents

```
1. Read README.md  ─ understand scope and current status
2. Read plans/05-validation-feedback.md  ─ list of open findings F1–F30
3. Read AGENTS.md (this file)  ─ confirm guardrails
4. Pick ONE open finding (start with the smallest, lowest legal-risk)
5. Activate `.claude/skills/cloud-phone-research/SKILL.md`
6. Follow skill workflow:
   a. Research via WebSearch / zread / academic refs
   b. Draft addendum (NEVER edit plans/00-04)
   c. Run multi-reviewer validation (Gemini-CLI + ≥2 Claude subagents)
   d. Consolidate reviewer feedback in plans/06-...md
   e. Stop. Wait for human approval before applying changes.
7. Commit with message format: `addendum(F-id): short description`
```

---

## 🧪 Quick health-check for any agent entering this repo

Before you write a single line, answer these in your scratch context:

- [ ] Did I read `AGENTS.md` (this file)?
- [ ] Did I read `README.md`?
- [ ] Did I read `plans/05-validation-feedback.md`?
- [ ] Did I activate `.claude/skills/cloud-phone-research/SKILL.md`?
- [ ] Am I about to touch `plans/00-04` directly? (If yes — STOP, use addendum)
- [ ] Does my proposed work require Legal-Gate clearance? (If yes — STOP, ask human)
- [ ] Is my work scoped to DetectorLab / planning / methodology — not live-platform attack?

If any answer is "no" / "yes (and I shouldn't)", reset and re-read.

---

## 📞 Escalation triggers

Stop and ask the human partner if:
- A finding requires changing pre-registered hypotheses
- A piece of evidence suggests the threat model misses an entire class
- You discover a vulnerability in a real product mid-research → 90-day Coordinated Disclosure (see `docs/ethics-and-scope.md`)
- A legal/ethical edge case appears that's not in `docs/ethics-and-scope.md`
- You want to add a third-party dependency to DetectorLab
- You want to make any change to the SpoofStack manifests (pre-cleared scope only)

---

## 🌐 Useful prompt templates

See `prompts/` directory for ready-to-paste prompts:
- `prompts/01-extend-finding.md` — work an open Finding into a patch-set
- `prompts/02-add-probe.md` — propose a new Detection-Probe
- `prompts/03-validate-round.md` — run a fresh multi-reviewer validation round
