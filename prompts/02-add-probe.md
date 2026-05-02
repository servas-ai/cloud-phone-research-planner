# Prompt 02 — Propose a New Detection Probe

Use this prompt when you want an AI agent to propose a brand-new probe (not in the existing 60 + 14-from-Round-1 inventory) and walk it through the validation gauntlet.

---

## How to use

1. Identify the candidate probe (e.g. "GPU command-buffer pattern", "WebRTC ICE-server reachability", "Pixel-data-pump timing").
2. Copy the prompt below.
3. Replace `{PROBE_NAME}` and `{ONE_SENTENCE_DESCRIPTION}`.
4. Paste into your agent.

---

## Prompt (copy from here)

```
You are working in /home/coder/vk-repos/cloud-phone-research-planner/.

Activate .claude/skills/cloud-phone-research/SKILL.md and follow it strictly.

Task: propose adding a new detection probe to probes/inventory.yml:
  Probe: {PROBE_NAME}
  Description: {ONE_SENTENCE_DESCRIPTION}

Mandatory workflow:

1. Orient (parallel reads): README.md, AGENTS.md, probes/inventory.yml, docs/probe-schema.md, docs/threat-model.md
2. Justify the probe:
   - Which threat-model layer does it cover (Application/Framework/Native/Kernel/Hardware/Network)?
   - What is the expected detection-confidence on vanilla ReDroid (L0a) vs. real Pixel 7?
   - Which mitigation layer would close it (L1–L6)?
   - Is it already partially covered by an existing probe? (cross-check by ID)
3. Research the probe's technical basis:
   - Use zread for any GitHub repo that implements it
   - Use web-search-prime for academic/industry references
   - Use web-reader for specific spec/blog URLs
4. Draft addendum at plans/06-new-probe-{slug}-addendum.md containing:
   - Justification
   - Proposed YAML entry (rank: 60 + N — append, do NOT renumber)
   - Implementation hint for DetectorLab (Kotlin pseudocode acceptable)
   - Risk: does this probe require capability/permission/access that's contentious under DSGVO or §202c?
5. Run multi-reviewer validation:
   - architecture-strategist subagent (does it fit the threat model?)
   - security-auditor subagent (any legal/ethical concerns?)
   - Gemini-CLI headless (independent technical review)
6. STOP. Report:
   - Path to addendum
   - Reviewer verdicts
   - Recommended decision: ACCEPT / REJECT / CONDITIONAL with reasoning

Hard rules:
- Do NOT edit probes/inventory.yml directly. Use addendum.
- Probe must be measurable from inside DetectorLab without leaving the container.
- Probe must not require live-platform interaction.
- Maximum runtime budget: 5 seconds for the probe (anything longer needs a justification).
```

---

## Examples of probe-categories worth adding

| Category | Example | Why interesting |
|---|---|---|
| Temporal | App-uptime variance vs. system uptime | Detects warm-snapshot containers |
| Kernel-leak | `/proc/kallsyms` readability | Trivial high-value emulator signal, no L0–L6 mitigation path |
| Hardware | Thermal-zone realism (`/sys/class/thermal/*`) | ReDroid often missing |
| Behavioral | Touch-pressure noise distribution | Hard to fake, no real capacitive sensor in container |
| Network | TLS JA4 client fingerprint | Industry-standard, missing from L6 mitigation |

---

## What "good" looks like

The agent should NOT just write a YAML stanza. It must:
- Justify against the threat model
- Cross-check existing probes for overlap
- Evaluate L1–L6 mitigation reachability
- Flag DSGVO/§202c implications
- End with reviewer verdicts and a clear ACCEPT/REJECT recommendation
