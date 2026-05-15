# Prompt 02 — Propose a New Detection Probe

Drive an AI agent to propose a brand-new detection probe (not in the
existing 60 + 14-from-Round-1 inventory) and walk it through the full
validation gauntlet — threat-model justification, overlap check,
mitigation reachability, multi-reviewer verdict.

The output is an addendum, never a direct edit to `probes/inventory.yml`.

---

## Configuration

| Input | Example | Notes |
|---|---|---|
| Probe name | `gpu-cmdbuf-pattern` | kebab-case, fits in YAML key. |
| One-sentence description | `GPU command-buffer fingerprint via /dev/dri opcode histogram` | Will appear in the addendum's Summary. |
| Threat-model layer | `Hardware`, `Network`, `Native`, … | Pick from the eight in `docs/threat-model.md`. |
| Reviewer panel | `architecture-strategist + security-auditor + Gemini-CLI` | Minimum two. |

**Stop conditions:**
- An existing probe in `probes/inventory.yml` already covers this exact signal.
- The probe's runtime exceeds 5 seconds without a strong justification.
- Two reviewers strongly disagree on the threat-model layer.

---

## Probe categories worth proposing (for inspiration only)

| Category | Example probe | Why interesting |
|---|---|---|
| Temporal | App-uptime variance vs. system uptime | Detects warm-snapshot containers. |
| Kernel-leak | `/proc/kallsyms` readability | Trivial high-value emulator signal, no L0–L6 mitigation path. |
| Hardware | Thermal-zone realism (`/sys/class/thermal/*`) | ReDroid often missing. |
| Behavioural | Touch-pressure noise distribution | Hard to fake; no real capacitive sensor in container. |
| Network | TLS JA4 client fingerprint | Industry-standard, missing from L6 mitigation. |
| GPU | Command-buffer opcode histogram via `/dev/dri` | Hardware-IP-specific, hard to spoof generically. |

If your candidate is not in one of these buckets, that is fine — but
make the threat-model justification doubly explicit in the addendum.

---

## Paste-block (copy from here)

The outer fence uses tildes (`~~~`) so the inner ```` ```yaml ```` and
```` ```kotlin ```` blocks render correctly. Copy everything between
the two `~~~` markers.

~~~
ROLE
You are an AI research engineer proposing one new detection probe for
the cloud-phone-research-planner. Your output is a draft addendum
that goes through human approval before the probe enters the live
inventory. You are not authorised to edit probes/inventory.yml directly.

CONTEXT
Repository: a research planner for ReDroid 12 + DetectorLab vs.
SpoofStack L0a–L6. The probe inventory in probes/inventory.yml
currently holds 60 base probes plus 14 added in Round-1 patches.
Each probe has: id, name, layer, description,
expected-detection-confidence (vanilla L0a vs. real Pixel 7),
mitigation-layer (L1–L6), runtime-budget-ms.

CONFIRM INPUTS FIRST
Ask the human partner for:
  1. Probe name (kebab-case).
  2. One-sentence description.
  3. Suspected threat-model layer (Application / Framework / Native /
     Kernel / Hardware / Sensors / Network / Behavioural).
  4. Reviewer panel (minimum two).
If already provided in the same message, skip the confirmation.

WORKFLOW (in order)

Step 1 — Orient. Parallel reads:
  - README.md
  - AGENTS.md
  - probes/inventory.yml (the full 60 + 14 inventory)
  - docs/probe-schema.md (the YAML schema)
  - docs/threat-model.md (the eight-layer model)
  - .claude/skills/cloud-phone-research/SKILL.md
After reading, state in one sentence which threat-model layer the
proposed probe targets and which existing probe (if any) is closest.

Step 2 — Overlap check. Use Grep on probes/inventory.yml to find
existing probes that touch the same signal source (same /proc path,
same syscall, same fingerprint family). For each candidate overlap,
write one line:
  "P-{NN} {name} — overlaps on {signal}, but new probe adds {delta}."
If overlap is total (no delta), STOP and report that the probe already
exists. Do not re-propose under a new name.

Step 3 — Threat-model justification. Write a CHAIN-OF-THOUGHT block
covering:
  - What signal does the probe extract? (One sentence.)
  - Why is this signal hard for SpoofStack L1–L6 to fake?
    (One sentence per applicable mitigation layer; "N/A" is fine.)
  - What is the expected detection-confidence on vanilla ReDroid (L0a)
    vs. a real Pixel 7? Quote a number with one decimal place plus
    the source (your own estimate vs. cited measurement).
  - Could a real device legitimately fail this probe? (False-positive
    risk.)
This block goes into the addendum verbatim.

Step 4 — Research the technical basis.
  - GitHub repo implementing the signal → zread MCP
  - Spec / blog explaining the technique → web-reader on the URL
  - Academic citation → web-search-prime with site filter
    (usenix.org, acm.org, arxiv.org, ieee.org)
  - Existing Android API for the probe → Android source via
    cs.android.com (web-reader) — never clone AOSP locally
Write each source with its provenance: URL + commit/version.
Vague references ("according to a paper I recall…") are not allowed.

Step 5 — Capability check. Answer in writing:
  - Does the probe require root, system, or signature-level
    permission on a real device? (Affects baseline measurement
    feasibility.)
If yes, the probe is CONDITIONAL — flag it in the addendum.

Step 6 — Draft addendum at plans/06-new-probe-{slug}-addendum.md:

  # Addendum {N} — New Probe: {NAME}
  Date: {YYYY-MM-DD}
  Triggered by: Human request — propose new probe
  Status: DRAFT — awaiting human review

  ## Summary
  {One sentence: what the probe is and why it matters.}

  ## Threat-Model Justification
  {Chain-of-thought block from Step 3.}

  ## Overlap Check
  {Lines from Step 2.}

  ## Research Conducted
  - {tool} → {URL} → {fact}
  - ...

  ## Proposed YAML Entry
  ```yaml
  - id: P-{NEXT}        # append at end, do NOT renumber
    name: {NAME}
    layer: {LAYER}
    description: {ONE_SENTENCE}
    expected-confidence:
      L0a: {0.0–1.0}
      real-pixel-7: {0.0–1.0}
    mitigation-layer: {L1|L2|L3|L4|L5|L6|none}
    runtime-budget-ms: {<= 5000}
  ```

  ## Implementation Hint (Kotlin pseudocode)
  ```kotlin
  // pseudocode acceptable; not a working implementation
  ```

  ## Risks
  - False-positive risk: ...
  - Mitigation reachability: ...

  ## Open Questions for Human Partner
  1. ...

  ## Reviewer Feedback
  (filled in Step 7)

  ## Approval Gate
  - [ ] ≥2 reviewers ran
  - [ ] Overlap check produced no total-overlap
  - [ ] Human partner approved

Step 7 — Multi-reviewer validation. In parallel (single message,
multiple tool calls), run the chosen reviewers with this sub-prompt:

  ---
  You are reviewing a proposed new detection probe for an academic
  security-research plan. Read these files and give a critical review:
    - {path to the new addendum}
    - probes/inventory.yml (current inventory)
    - docs/threat-model.md (eight-layer model)
  Output sections (max 500 words):
    ## Threat-model fit (does the layer assignment hold?)
    ## Overlap with existing probes (any P-IDs we missed?)
    ## Mitigation reachability (does L1–L6 close it cleanly?)
    ## Verdict (ACCEPT / REJECT / CONDITIONAL + one paragraph)
  ---

For Claude subagents: Task tool with subagent_type.
For Gemini-CLI: GEMINI_CLI_TRUST_WORKSPACE=true gemini -p "<prompt>"
  --skip-trust --approval-mode plan -m gemini-3-pro-preview
For Codex: codex exec --skip-git-repo-check "<prompt>"

Quote each reviewer's verdict line verbatim in the addendum's
Reviewer Feedback section.

Step 8 — STOP. Do NOT edit probes/inventory.yml. Do NOT commit. Do
NOT push. Reply to the human with:
  - Path to the addendum
  - Reviewer verdicts (one line each, verbatim)
  - Recommended decision: ACCEPT / REJECT / CONDITIONAL with one
    paragraph reasoning
  - Top 3 open questions
  - Explicit question: "Approve to apply? Y/N"

HARD RULES (with rebuttals)

| Excuse | Rebuttal |
|---|---|
| "I'll just append to probes/inventory.yml — it's atomic." | inventory.yml is a plan artifact. Use addendum, then human applies. |
| "This probe is similar to P-23, I'll just bump it." | Never modify existing IDs. Append a new probe and document the delta. |
| "Live-platform reachability would make the probe more realistic." | Out of scope. The probe must be measurable from inside DetectorLab without leaving the container. |
| "Runtime is ~30 seconds but it's worth it." | >5 seconds requires explicit justification in the Risks section AND human approval before merge. |
| "I'll cite 'a recent paper' without the URL." | Vague provenance is fabrication-adjacent. URL + commit/version, or do not cite. |

DEBUGGING TIPS

- Cannot find docs/probe-schema.md or docs/threat-model.md:
  STOP. The repo structure may have changed. Ask the human for the
  current paths instead of inventing a schema.
- Probe candidate is too vague (the human said "something with GPU"):
  STOP and clarify. Ask: "Which signal? Render-pipeline timing,
  command-buffer pattern, GPU-memory-region sizes, EGL extension
  list?" Do not guess.
- All reviewers say REJECT but you think it's good:
  Do NOT override. Surface the reviewers' verdicts verbatim and let
  the human decide. Add an "Author Note" subsection with your
  counter-argument if you must.
- Overlap check returns >5 candidates:
  Probe is likely too coarse. STOP and ask the human if it should
  be split into N narrower probes.
- Reviewer fails (Gemini 429, Codex quota):
  Mark as UNAVAILABLE in the Reviewer Feedback. Continue with the
  remaining reviewers if you still have ≥2. Below 2, STOP.

SELF-CHECK BEFORE SUBMITTING

  [ ] Overlap check ran and produced no total-overlap.
  [ ] Threat-model layer was justified, not asserted.
  [ ] Expected-confidence numbers cite a source or are marked
      "author estimate".
  [ ] Runtime budget ≤ 5000 ms (or justified in Risks).
  [ ] Addendum lives at plans/06-...md, not in probes/inventory.yml.
  [ ] At least two reviewers ran; verdicts quoted verbatim.
  [ ] Report to human ends with "Approve to apply? Y/N".

If any box is unchecked, fix it before reporting back.
~~~

---

## What "good" looks like

A successful run produces:

- An addendum at `plans/06-new-probe-{slug}-addendum.md` with all
  required sections.
- A non-trivial overlap check ("P-23 covers /proc readability but
  not the kallsyms-specific check; new probe is justified").
- Confidence numbers with provenance, not bare floats.
- Two or more reviewer verdicts quoted verbatim.
- A clear ACCEPT / REJECT / CONDITIONAL recommendation from the agent.

A bad run looks like:

- Agent appends to `probes/inventory.yml` directly.
- Threat-model layer assignment is unjustified ("Hardware, because GPU").
- Confidence numbers without provenance ("L0a: 0.9, real: 0.1" with no source).
- Reviewer Feedback says "all approved" with no verbatim quotes.
- Agent commits without explicit Y from the human.
