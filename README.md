# Cloud Phone Research Planner

> Forschungsprojekt zur empirischen, layer-weisen Evaluation der Erkennbarkeit virtualisierter Android-Umgebungen (ReDroid 12 / MobileRun-Style Cloud Phones) gegenüber App-seitiger Detection.

<p align="center">
  <a href="#"><img alt="Status" src="https://img.shields.io/badge/status-validation_round_1-orange"></a>
  <a href="#"><img alt="Verdict" src="https://img.shields.io/badge/verdict-NEEDS__REVISION-red"></a>
  <a href="#"><img alt="Reviewer" src="https://img.shields.io/badge/reviewer-4_panels-blue"></a>
  <a href="#"><img alt="License" src="https://img.shields.io/badge/license-Apache--2.0_(code)-green"></a>
  <a href="#"><img alt="Scope" src="https://img.shields.io/badge/scope-detection__research_only-lightgrey"></a>
  <a href="AGENTS.md"><img alt="AI Agents" src="https://img.shields.io/badge/🤖_AI_agents-read_AGENTS.md_first-purple"></a>
  <a href=".claude/skills/cloud-phone-research/SKILL.md"><img alt="Skill" src="https://img.shields.io/badge/skill-cloud--phone--research-9333ea"></a>
  <a href="https://github.com/servas-ai/cloud-phone-research-planner/issues?q=is%3Aissue+is%3Aopen+label%3Afinding"><img alt="Open findings" src="https://img.shields.io/github/issues/servas-ai/cloud-phone-research-planner/finding?label=open%20findings"></a>
  <a href="LICENSE"><img alt="License Apache-2.0" src="https://img.shields.io/badge/license-Apache--2.0-blue"></a>
  <a href="CITATION.cff"><img alt="Citable" src="https://img.shields.io/badge/citable-CITATION.cff-orange"></a>
</p>

> **🤖 AI Agents** — entering this repo? Read [`HANDOFF.md`](HANDOFF.md) for a complete status briefing, then [`AGENTS.md`](AGENTS.md) for the hard rules. Activate the project skill at [`.claude/skills/cloud-phone-research/SKILL.md`](.claude/skills/cloud-phone-research/SKILL.md). Ready-to-paste prompts in [`prompts/`](prompts/).

---

## 📑 Inhaltsverzeichnis

1. [Forschungsfrage](#-forschungsfrage)
2. [Zwei-Track-Methodik](#-zwei-track-methodik)
3. [System-Architektur](#-system-architektur)
4. [Adversarial Test-Loop](#-adversarial-test-loop)
5. [12-Wochen-Phasenplan](#-12-wochen-phasenplan)
6. [Threat-Model Mapping](#-threat-model-mapping)
7. [Repository-Layout](#-repository-layout)
8. [Status](#-status)
9. [Validation Pipeline](#-validation-pipeline)
10. [Reproducibility-Strategie](#-reproducibility-strategie)

---

## ⚡ Quickstart (für menschliche Mitwirkende)

```bash
git clone https://github.com/servas-ai/cloud-phone-research-planner.git
cd cloud-phone-research-planner

# 1. Lies die Eintritts-Dokumente
$EDITOR README.md AGENTS.md plans/00-master-plan.md

# 2. Wähle ein offenes Finding (siehe GitHub Issues mit Label `finding`)
gh issue list --label finding --state open

# 3. Drafte ein Addendum (NIEMALS plans/00-04 editieren)
cp prompts/01-extend-finding.md /tmp/my-prompt.md
# Setze FINDING_ID + Reviewer-Panel im "Configuration"-Block der Datei

# 4. Multi-Reviewer-Validation laufen lassen (verifizierter Befehl)
GEMINI_CLI_TRUST_WORKSPACE=true gemini -p "$(cat /tmp/my-prompt.md)" \
  --skip-trust --approval-mode plan -m gemini-3-pro-preview

# 5. Auf menschliche Y/N warten, dann commiten + pushen
just lint        # validiert markdown + yaml + probe-schema
just status      # planner-spezifischer git status
```

Für **AI-Agents** statt menschlicher Mitwirkender: siehe [`AGENTS.md`](AGENTS.md) zuerst, dann [`.claude/skills/cloud-phone-research/SKILL.md`](.claude/skills/cloud-phone-research/SKILL.md).

---

## 🔍 Forschungsfrage

> Welche Android-Detection-Methoden (Build-Properties, Hardware-Attestation, Sensor-Signaturen, Netzwerk-Fingerprints) bleiben **robust** gegen Container-basierte Virtualisierung mit ARM-nativen Cloud-Phone-Stacks (ReDroid 12), und welche lassen sich **layer-weise schliessen**?

**Endprodukt:** Detection-Resistance-Heatmap (60+ Probes × 8 Stack-Konfigurationen) + Paper / Thesis.

---

## 🧪 Zwei-Track-Methodik

| Track | Rolle | Inhalt |
|---|---|---|
| **🎯 A — DetectorLab** | Red Team / Mess-Oracle | Eigene Android-App (Kotlin), die alle 60+ Detection-Punkte standardisiert misst und JSON-Reports erzeugt. Open-Source-Beitrag. |
| **🛡️ B — SpoofStack** | Blue Team / Subject Under Test | ReDroid-12-basierter Stack mit modular zuschaltbaren Mitigation-Layern (L0a → L6). Wird **gegen DetectorLab** geprüft, nicht gegen Live-Plattformen. |

Adversariell: Beide Tracks werden iterativ gegeneinander gestellt. Die Detection-Suite ist das wissenschaftliche Mess-Instrument; der Mitigation-Stack ist das Untersuchungsobjekt.

---

## 🏗️ System-Architektur

```mermaid
flowchart TB
    subgraph LAB["🔬 ISOLIERTES LABOR · eigenes VLAN"]
        direction TB

        subgraph TRACKB["🛡️ TRACK B · SpoofStack · Subject Under Test"]
            direction TB
            L6["L6 · Network Egress<br/>Lab-LTE-Modem · Mobile-ASN"]
            L5["L5 · Sensor Emulation<br/>VirtualSensor + Trace-Player"]
            L4["L4 · Runtime Hiding<br/>Shamiko + HideMyAppList"]
            L3["L3 · Integrity & Attestation<br/>PIF + TrickyStore + Keybox"]
            L2["L2 · Identity Spoofing<br/>Android Faker"]
            L1["L1 · Build Properties<br/>DeviceSpoofLab Hooks/Magisk"]
            L0B["L0b · Root-Stack<br/>Magisk + ReZygisk + LSPosed"]
            L0A["L0a · Vanilla Container<br/>ReDroid 12 ARM64 Bare-Metal"]

            L0A --> L0B --> L1 --> L2 --> L3 --> L4 --> L5 --> L6
        end

        subgraph TRACKA["🎯 TRACK A · DetectorLab · Mess-Oracle"]
            direction TB
            APP["Android-App · Kotlin<br/>Min SDK 30 · Target 34"]
            CORE["ProbeRunner · 60+ Probes<br/>buildprop · integrity · root · emulator ·<br/>network · identity · runtime · sensors · ui · env"]
            REPORT["JSON Report v1<br/>Score 0.0–1.0 + Evidence + Confidence"]
            APP --> CORE --> REPORT
        end

        TRACKB == "Probe-Antworten<br/>(echt / spoofed)" ==> TRACKA
        TRACKA == "Detection-Score" ==> MATRIX
    end

    subgraph ANALYSIS["📊 AUSWERTUNG"]
        direction LR
        MATRIX["Experiment-Matrix<br/>60+ Probes × 8 Configs × N=60"]
        STATS["Statistik<br/>McNemar + Benjamini-Hochberg<br/>2⁶ Fractional-Factorial"]
        HEATMAP["Detection-Resistance<br/>Heatmap"]
        MATRIX --> STATS --> HEATMAP
    end

    subgraph DELIV["📄 DELIVERABLES"]
        direction LR
        OSS["DetectorLab OSS<br/>Apache-2.0"]
        PAPER["Paper"]
        THESIS["Thesis-Kapitel"]
    end

    LAB ==> ANALYSIS ==> DELIV

    classDef trackB fill:#fef3e0,stroke:#d97706,stroke-width:2px,color:#000
    classDef trackA fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#000
    classDef analysis fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#000
    classDef deliv fill:#f3e8ff,stroke:#9333ea,stroke-width:2px,color:#000

    class L0A,L0B,L1,L2,L3,L4,L5,L6 trackB
    class APP,CORE,REPORT trackA
    class MATRIX,STATS,HEATMAP analysis
    class OSS,PAPER,THESIS deliv
```

---

## 🔁 Adversarial Test-Loop

```mermaid
sequenceDiagram
    autonumber
    participant R as 👤 Researcher
    participant S as 📦 Container Snapshot<br/>(L0a → Full-Stack)
    participant B as 🛡️ Track B<br/>SpoofStack
    participant A as 🎯 Track A<br/>DetectorLab
    participant E as ⚙️ experiments/runner
    participant X as 📊 Statistical Analysis

    R->>S: Build immutable image per layer config
    Note over E,B: 8 Konfigurationen × N=60 Runs = 480 Container-Cycles
    loop N=60 Runs pro Konfiguration
        E->>B: docker compose up (clean state)
        E->>B: install DetectorLab.apk + start probes
        B->>A: trigger ProbeRunner
        A->>B: query Build-Props · Integrity · Root · Sensors · TLS · …
        B-->>A: spoofed / real responses
        A->>E: JSON report (60+ probe scores)
        E->>E: schema-validate + persist run-N.json
        E->>B: docker compose down -v
    end
    E->>X: aggregate runs/{config-id}/*.json
    X->>X: McNemar + BH-FDR + Power-Calc + Effect-Size
    X->>R: Heatmap + Hard-Probes-List + Paper-Figures
```

---

## 🗓️ 12-Wochen-Phasenplan

```mermaid
gantt
    title Forschungsprojekt — Phasen & Sprints (12 Wochen)
    dateFormat YYYY-MM-DD
    axisFormat KW%V

    section 🎯 Track A — DetectorLab
    Sprint 1 · Skeleton + Schema        :a1, 2026-05-04, 7d
    Sprint 2 · BuildProp+Root+Emulator  :a2, after a1, 7d
    Sprint 3 · Identity+Runtime         :a3, after a2, 7d
    Sprint 4 · Integrity+Sensor-FFT     :a4, after a3, 7d
    Sprint 5 · Network+TLS+Polish       :a5, after a4, 7d

    section 🛡️ Track B — SpoofStack
    Sprint A · L0a/L0b Baseline         :b1, 2026-05-04, 7d
    Sprint B · L1+L2                    :b2, after b1, 7d
    Sprint C · L3+L4                    :crit, b3, after b2, 7d
    Sprint D · L5+L6                    :b4, after b3, 7d

    section ⚙️ Tooling
    experiments/runner Orchestrator     :crit, run, after a3, 14d

    section 📊 Phase 3-5
    Layer-Experiments (8 configs × 60)  :exp, after b4, 21d
    Statistical Analysis                :stats, after exp, 7d
    Paper Draft & Submission            :crit, paper, after stats, 14d
```

---

## 🎯 Threat-Model Mapping

```mermaid
flowchart LR
    subgraph DETECT["🔍 Detection-Layer (Android Stack)"]
        direction TB
        APPL["Application Layer<br/>#2 Play Integrity · #56 WebGL"]
        FRAME["Framework Layer<br/>#11 ANDROID_ID · #16 GAID · #24 Sensors"]
        NATIVE["Native Layer<br/>#1 getprop · #3 su · #14 SELinux"]
        KERNEL["Kernel Layer<br/>#4 QEMU · #30 /proc/version · #62 kallsyms"]
        HARDWARE["Hardware Layer<br/>#6 TEE Attestation · #29 MediaDRM · #66 thermal_zones"]
        NETWORK["Network Layer<br/>#5 IP/ASN · #61 JA4 · #62 TCP-Stack"]
    end

    subgraph MITIG["🛡️ Mitigation-Layer (SpoofStack)"]
        direction TB
        L1M["L1 Build-Props"]
        L2M["L2 Identity"]
        L3M["L3 Integrity"]
        L4M["L4 Hiding"]
        L5M["L5 Sensors"]
        L6M["L6 Network"]
    end

    subgraph ADV["⚔️ Adversary Capability"]
        direction TB
        ADVA["L_AdvA · static-rule<br/>(klassische SDKs)"]
        ADVB["L_AdvB · ML-classifier<br/>auf Probe-Vector"]
        ADVC["L_AdvC · Deep-ML<br/>auf Sensor-Traces"]
    end

    APPL -.- L3M
    APPL -.- L4M
    FRAME -.- L2M
    NATIVE -.- L1M
    KERNEL -.- L1M
    HARDWARE === L3M
    HARDWARE === L5M
    NETWORK === L6M

    DETECT --- ADV

    classDef hard fill:#fee2e2,stroke:#dc2626,stroke-width:2px,color:#000
    classDef soft fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#000
    classDef ext fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#000
    classDef adv fill:#fef3c7,stroke:#d97706,stroke-width:2px,color:#000

    class HARDWARE,NETWORK hard
    class APPL,FRAME soft
    class NATIVE,KERNEL ext
    class ADVA,ADVB,ADVC adv
```

**Legende:**
- 🟥 **Hard** = externe Vertrauensanker (TEE, Mobile-Carrier) — schwer zu spoofen
- 🟩 **Soft** = App-interne API-Calls — gut hookable
- 🟦 **External** = OS-Layer-Probes — durch Container-Boundary teilweise leakend
- `===` = primärer Mitigation-Pfad · `-.-` = sekundärer Pfad

---

## 📁 Repository-Layout

```mermaid
flowchart LR
    ROOT[".<br/>cloud-phone-research-planner"] --> README["README.md"]
    ROOT --> PLANS["plans/"]
    ROOT --> DOCS["docs/"]
    ROOT --> PROBES["probes/"]
    ROOT --> STACK["stack/"]
    ROOT --> EXP["experiments/"]
    ROOT --> REFS["refs/"]

    PLANS --> P0["00-master-plan.md"]
    PLANS --> P1["01-detectorlab.md"]
    PLANS --> P2["02-spoofstack.md"]
    PLANS --> P3["03-experiment-matrix.md"]
    PLANS --> P4["04-deliverables.md"]

    DOCS --> D2["threat-model.md"]
    DOCS --> D3["probe-schema.md"]
    DOCS --> D4["glossary.md"]

    PROBES --> PI["inventory.yml<br/>📌 60+ Probes"]
    STACK --> SL["layers.md<br/>📌 L0a–L6"]
    EXP --> ER["README.md<br/>📌 Run-Protocol"]
    REFS --> RB["bibliography.md"]

    classDef plan fill:#dbeafe,stroke:#2563eb,color:#000
    classDef doc fill:#dcfce7,stroke:#16a34a,color:#000
    classDef data fill:#fef3c7,stroke:#d97706,color:#000

    class P0,P1,P2,P3,P4 plan
    class D2,D3,D4 doc
    class PI,SL,ER,RB data
```

---

## 🚦 Status

| Phase | Status | Woche |
|---|---|---|
| Probe Inventory | ✅ drafted (60 Probes, +14 in Round 2) | 1–2 |
| **Validation Round 1** | ⚠️ **NEEDS_REVISION** (4 Reviewer einig) | 1 |
| DetectorLab MVP | 📋 planned | 3–6 |
| SpoofStack Baseline | 📋 planned | 3–4 |
| Layer-by-Layer Experiments | 📋 planned | 7–10 |
| Paper / Thesis Draft | 📋 planned | 11–12 |

---

## 🔬 Validation Pipeline

Der Plan wurde von **vier unabhängigen Reviewern** kreuzvalidiert (Plan-Immutability-Regel: Originale unverändert, Findings als Addendum):

```mermaid
flowchart TB
    PLAN["📋 Plans v1<br/>(00–04)"]

    subgraph REVIEWERS["Multi-Reviewer-Panel · Round 1"]
        direction LR
        R1["🤖 Gemini 3 Pro<br/>(headless gemini-cli)<br/>NEEDS_REVISION"]
        R2["🏛️ architecture-strategist<br/>(USENIX-PC-Stil)<br/>NEEDS_REVISION"]
        R3["🔍 gap-analyst<br/>(unstated assumptions)<br/>30 Findings"]
    end

    CONSOLIDATE["🧮 Consolidate<br/>Findings · 0 Konflikte"]
    PATCH["📝 Patch-Set Round 2"]

    PLAN --> R1
    PLAN --> R2
    PLAN --> R3
    R1 --> CONSOLIDATE
    R2 --> CONSOLIDATE
    R3 --> CONSOLIDATE
    CONSOLIDATE --> PATCH

    classDef plan fill:#dbeafe,stroke:#2563eb,color:#000
    classDef rev fill:#fef3c7,stroke:#d97706,color:#000
    classDef out fill:#dcfce7,stroke:#16a34a,color:#000

    class PLAN plan
    class R1,R2,R3 rev
    class CONSOLIDATE,PATCH out
```

| Reviewer | Tool | Verdict | Schwerpunkt |
|---|---|---|---|
| Gemini 3 Pro Preview | `gemini-cli` (headless, --skip-trust) | NEEDS_REVISION | Hardware/Statistik/TLS-Probes |
| architecture-strategist | Claude subagent | NEEDS_REVISION | Threat-Model/Reproducibility/Orchestrator |
| gap-analyst | Claude subagent | 30 Gaps | Operationale Voraussetzungen |
| Codex GPT-5.5 | `codex-cli` | unavailable | Usage-Limit bis 2026-05-09 |

---

## 🔁 Reproducibility-Strategie

| Stufe | Inhalt | Zugang |
|---|---|---|
| **🟢 Public Detection-Reproducibility** | DetectorLab APK · Source · JSON-Schema · aggregate Heatmap-CSV · analysis-Scripts | öffentlich, Apache-2.0 / CC-BY |
| **🔒 Institutional Mitigation-Stack** | exakte Modul-Versionen · TrickyStore-Config · Container-Image-Hashes | institutional access only · verified academic request |

---

## 🤖 Für AI Agents

Dieses Repository ist **agent-ready**. Drei Eintrittsdateien:

| Datei | Zweck |
|---|---|
| [`AGENTS.md`](AGENTS.md) | Hard rules · Plan-Immutability · Scope-Lock |
| [`.claude/skills/cloud-phone-research/SKILL.md`](.claude/skills/cloud-phone-research/SKILL.md) | Vollständiger Research-Loop-Workflow für Claude Code |
| [`SKILL.md`](SKILL.md) | Generisches Discovery-File für non-Claude-Agents (Codex, Gemini, Cursor, Aider, …) |

**Ready-To-Paste-Prompts** in [`prompts/`](prompts/):

| Prompt | Use-Case |
|---|---|
| [`prompts/01-extend-finding.md`](prompts/01-extend-finding.md) | Open Finding F-{X} aus Round 1 in eine reviewete Addendum-Patch verarbeiten |
| [`prompts/02-add-probe.md`](prompts/02-add-probe.md) | Neue Detection-Probe vorschlagen (mit Threat-Model-Justification + Reviewer-Gauntlet) |
| [`prompts/03-validate-round.md`](prompts/03-validate-round.md) | Frische Multi-Reviewer-Validation-Round (Gemini + Claude-Subagents) orchestrieren |

---

## 📚 Weiterführende Dokumente

- 🗓️ [Master-Plan (12 Wochen)](plans/00-master-plan.md)
- 🎯 [Track A · DetectorLab](plans/01-detectorlab.md)
- 🛡️ [Track B · SpoofStack](plans/02-spoofstack.md)
- 📊 [Experiment-Matrix](plans/03-experiment-matrix.md)
- 📄 [Deliverables](plans/04-deliverables.md)
- 🎯 [Threat-Model](docs/threat-model.md)
- 📐 [Probe-Schema v1](docs/probe-schema.md)
- 🧮 [Probe-Inventar (60+ Probes)](probes/inventory.yml)
- 🐳 [SpoofStack-Layer](stack/layers.md)
- 📚 [Bibliography](refs/bibliography.md)
