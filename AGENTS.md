# 🤖 AGENTS.md — Instructions for AI Agents

> **If you are an AI agent (Claude Code · Codex · Gemini CLI · Cursor · Aider · OpenCode · OME · Continue · any other) and you have been pointed at this repository, READ THIS FILE FIRST before doing anything else.**

---

## 🎯 You are entering a research planner repository

**Repository purpose:** Plans, tracks, and validates a research project on Android container detection resistance (ReDroid 12 + DetectorLab vs. SpoofStack L0a–L6).

**You ARE here to:**
- ✅ Extend the planning artifacts (markdown plans, probe inventory, threat model)
- ✅ Answer the research question with academic rigor
- ✅ Implement DetectorLab probes (Kotlin)
- ✅ Improve reproducibility, statistical methodology, threat-model coverage

---

## 🔌 Activate the project skill

This repository ships an embedded skill at `.claude/skills/cloud-phone-research/SKILL.md` (also discoverable as a generic `SKILL.md` for tools that don't use Claude's `.claude/` convention).

**For Claude Code:** the skill is auto-loaded when you cd into this directory.
**For other agents:** read `.claude/skills/cloud-phone-research/SKILL.md` directly and follow its workflow.

---

## 📜 Hard rules

1. **No illegal packages** — Don't introduce license-incompatible or pirated dependencies.
2. **No emoji-bombing** — Emojis only in user-facing markdown (README, plans), never in code files.

---

## 🌐 Useful prompt templates

See `prompts/` directory for ready-to-paste prompts:
- `prompts/01-extend-finding.md` — work an open Finding into a patch-set
- `prompts/02-add-probe.md` — propose a new Detection-Probe
- `prompts/03-validate-round.md` — run a fresh multi-reviewer validation round
