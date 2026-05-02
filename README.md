# Cloud Phone Research Planner

> Akademisches Forschungsprojekt zur empirischen, layer-weisen Evaluation der Erkennbarkeit virtualisierter Android-Umgebungen (ReDroid 12 / MobileRun-Style Cloud Phones) gegenüber App-seitiger Detection.

<p align="center">
  <a href="#"><img alt="Status" src="https://img.shields.io/badge/status-validation_round_1-orange"></a>
  <a href="#"><img alt="Verdict" src="https://img.shields.io/badge/verdict-NEEDS__REVISION-red"></a>
  <a href="#"><img alt="Reviewer" src="https://img.shields.io/badge/reviewer-4_panels-blue"></a>
  <a href="#"><img alt="Phase" src="https://img.shields.io/badge/phase-0_blocked_by_legal-yellow"></a>
  <a href="#"><img alt="License" src="https://img.shields.io/badge/license-Apache--2.0_(code)-green"></a>
  <a href="#"><img alt="Scope" src="https://img.shields.io/badge/scope-detection__research_only-lightgrey"></a>
</p>

> **Hochschulkontext** — Dieses Repository ist die Planungs- und Tracking-App für das Forschungsvorhaben.
> Es enthält **kein** Spoofing-Tooling und **keine** Anleitungen gegen Drittsysteme. Tests laufen ausschliesslich gegen die selbstentwickelte `DetectorLab`-Suite im isolierten Lab. Live-Plattform-Tests (TikTok / Instagram / etc.) sind explizit **out of scope**.

---

## 📑 Inhaltsverzeichnis

1. [Forschungsfrage](#-forschungsfrage)
2. [Zwei-Track-Methodik](#-zwei-track-methodik)
3. [System-Architektur](#-system-architektur)
4. [Adversarial Test-Loop](#-adversarial-test-loop)
5. [12-Wochen-Phasenplan](#-12-wochen-phasenplan)
6. [Threat-Model Mapping](#-threat-model-mapping)
7. [Repository-Layout](#-repository-layout)
8. [Status & Blocker](#-status--blocker)
9. [Validation Pipeline](#-validation-pipeline)
10. [Reproducibility-Strategie](#-reproducibility-strategie)
11. [Lizenz & Ethik](#-lizenz--ethik)

---

## 🔍 Forschungsfrage

> Welche Android-Detection-Methoden (Build-Properties, Hardware-Attestation, Sensor-Signaturen, Netzwerk-Fingerprints) bleiben **robust** gegen Container-basierte Virtualisierung mit ARM-nativen Cloud-Phone-Stacks (ReDroid 12), und welche lassen sich **layer-weise schliessen**?

**Endprodukt:** Detection-Resistance-Heatmap (60+ Probes × 8 Stack-Konfigurationen) + Paper / Thesis bei USENIX Security · ACM CCS · NDSS · WOOT · DIMVA · IEEE EuroS&P.

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
    subgraph LAB["🔬 ISOLIERTES LABOR · eigenes VLAN · keine Live-Plattformen"]
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
        PAPER["Paper<br/>USENIX/CCS/NDSS"]
        THESIS["Thesis-Kapitel"]
        REPRO["Reproducibility-Pack<br/>institutional access"]
    end

    LAB ==> ANALYSIS ==> DELIV

    classDef trackB fill:#fef3e0,stroke:#d97706,stroke-width:2px,color:#000
    classDef trackA fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#000
    classDef analysis fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#000
    classDef deliv fill:#f3e8ff,stroke:#9333ea,stroke-width:2px,color:#000

    class L0A,L0B,L1,L2,L3,L4,L5,L6 trackB
    class APP,CORE,REPORT trackA
    class MATRIX,STATS,HEATMAP analysis
    class OSS,PAPER,THESIS,REPRO deliv
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

    section 🔒 Phase 0 — Gating
    Legal Clearance (F21/F22/F23)       :crit, p0g, 2026-05-04, 14d
    IRB-Submission + Approval           :crit, p0a, after p0g, 7d
    OSF Pre-Registration                :crit, p0b, after p0a, 3d
    Hardware Procurement                :p0c, 2026-05-04, 14d

    section 🎯 Track A — DetectorLab
    Sprint 1 · Skeleton + Schema        :a1, after p0b, 7d
    Sprint 2 · BuildProp+Root+Emulator  :a2, after a1, 7d
    Sprint 3 · Identity+Runtime         :a3, after a2, 7d
    Sprint 4 · Integrity+Sensor-FFT     :a4, after a3, 7d
    Sprint 5 · Network+TLS+Polish       :a5, after a4, 7d

    section 🛡️ Track B — SpoofStack
    Sprint A · L0a/L0b Baseline         :b1, after p0b, 7d
    Sprint B · L1+L2                    :b2, after b1, 7d
    Sprint C · L3+L4 (Keybox required)  :crit, b3, after b2, 7d
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
    PLANS --> P5["05-validation-feedback.md<br/>📌 4-Reviewer-Round"]

    DOCS --> D1["ethics-and-scope.md"]
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

    class P0,P1,P2,P3,P4,P5 plan
    class D1,D2,D3,D4 doc
    class PI,SL,ER,RB data
```

---

## 🚦 Status & Blocker

| Phase | Status | Woche |
|---|---|---|
| Scope & Ethics | ✅ drafted | 1 |
| Probe Inventory | ✅ drafted (60 Probes, +14 in Round 2) | 1–2 |
| **Validation Round 1** | ⚠️ **NEEDS_REVISION** (4 Reviewer einig) | 1 |
| Legal Clearance | 🔴 **blocked** (F21 / F22 / F23) | 1 |
| DetectorLab MVP | ⏸️ blocked by F21/F22/F23 | 3–6 |
| SpoofStack Baseline | ⏸️ blocked by F21/F22 | 3–4 |
| Layer-by-Layer Experiments | 📋 planned | 7–10 |
| Paper / Thesis Draft | 📋 planned | 11–12 |

### 🚨 Top-3 Blocker vor Phase 0

```mermaid
flowchart LR
    subgraph BLOCKERS["🔴 BLOCKING FINDINGS (Round 1)"]
        F22["⚖️ F22 · Keybox-Provenienz<br/>§259 StGB Risiko<br/>(Receipt of Stolen Property)"]
        F21["💥 F21 · Privileged Docker<br/>Host-Root-Escape<br/>aus Magisk-rooted Container"]
        F23["📜 F23 · Reproducibility-Pack<br/>§202c-Recipe<br/>(Tool-Distribution-Aequivalent)"]
    end

    subgraph GATE["🏛️ Gating-Authority"]
        LEGAL["Universitäts-Rechtsabteilung"]
        ETHICS["Ethik-Kommission"]
        IRB["IRB / Datenschutz"]
    end

    subgraph OUT["🟢 Phase 0 GO"]
        APPROVED["✅ Schriftliche Freigabe<br/>aller drei Stellen"]
    end

    F22 ==> LEGAL
    F21 ==> LEGAL
    F23 ==> LEGAL
    LEGAL ==> ETHICS
    ETHICS ==> IRB
    IRB ==> APPROVED

    classDef block fill:#fee2e2,stroke:#dc2626,stroke-width:3px,color:#000
    classDef gate fill:#fef3c7,stroke:#d97706,stroke-width:2px,color:#000
    classDef go fill:#dcfce7,stroke:#16a34a,stroke-width:3px,color:#000

    class F22,F21,F23 block
    class LEGAL,ETHICS,IRB gate
    class APPROVED go
```

Diese drei MÜSSEN vor Beginn der Implementierungsphase 1 mit Universitäts-Rechtsabteilung und Ethik-Kommission **schriftlich** geklärt sein. Details in [`plans/05-validation-feedback.md`](plans/05-validation-feedback.md).

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
        R4["🔐 security-auditor<br/>(§202c StGB + OpSec)<br/>NEEDS_REVISION"]
    end

    CONSOLIDATE["🧮 Consolidate<br/>30 Findings · 0 Konflikte"]
    ADDENDUM["📌 plans/05-validation-feedback.md"]
    PATCH["📝 Patch-Set Round 2<br/>(nach Legal Clearance)"]

    PLAN --> R1
    PLAN --> R2
    PLAN --> R3
    PLAN --> R4
    R1 --> CONSOLIDATE
    R2 --> CONSOLIDATE
    R3 --> CONSOLIDATE
    R4 --> CONSOLIDATE
    CONSOLIDATE --> ADDENDUM
    ADDENDUM --> PATCH

    classDef plan fill:#dbeafe,stroke:#2563eb,color:#000
    classDef rev fill:#fef3c7,stroke:#d97706,color:#000
    classDef out fill:#dcfce7,stroke:#16a34a,color:#000

    class PLAN plan
    class R1,R2,R3,R4 rev
    class CONSOLIDATE,ADDENDUM,PATCH out
```

| Reviewer | Tool | Verdict | Schwerpunkt |
|---|---|---|---|
| Gemini 3 Pro Preview | `gemini-cli` (headless, --skip-trust) | NEEDS_REVISION | Hardware/Statistik/TLS-Probes |
| architecture-strategist | Claude subagent | NEEDS_REVISION | Threat-Model/Reproducibility/Orchestrator |
| gap-analyst | Claude subagent | 30 Gaps | Operationale Voraussetzungen/IRB-Gating |
| security-auditor | Claude subagent | NEEDS_REVISION | §202c/§259 StGB/OpSec |
| Codex GPT-5.5 | `codex-cli` | unavailable | Usage-Limit bis 2026-05-09 |

---

## 🔁 Reproducibility-Strategie

Zwei-Stufen-Modell (gemäss Finding F23):

| Stufe | Inhalt | Zugang |
|---|---|---|
| **🟢 Public Detection-Reproducibility** | DetectorLab APK · Source · JSON-Schema · aggregate Heatmap-CSV · analysis-Scripts | öffentlich, Apache-2.0 / CC-BY |
| **🔒 Institutional Mitigation-Stack** | exakte Modul-Versionen · TrickyStore-Config · Keybox-Provenance · Container-Image-Hashes | institutional access only · verified academic request |

Damit wird **Detection-Result-Reproducibility** vollumfänglich gewährleistet, ohne dass der publizierte Reproducibility-Pack rechtlich als §202c-Recipe interpretiert werden kann.

---

## ⚖️ Lizenz & Ethik

| Aspekt | Festlegung |
|---|---|
| DetectorLab Code | Apache-2.0 |
| Probe-Schema | CC-BY-4.0 |
| Plan-Dokumente | CC-BY-4.0 |
| Stack-Konfigurationen | nur als Referenz im Lab, **nicht produktionsreif**, **nicht distributable** |
| Live-Plattform-Tests | ❌ explizit out of scope (TikTok / Instagram / etc.) |
| Drittsystem-Zugriff | ❌ kein automatisierter Zugriff |
| Disclosure-Policy | 90-Tage Coordinated · Fallback CERT-Bund/BSI |
| Rechtsrahmen | §202c StGB · §259 StGB · EU 2021/821 (Dual-Use) · DSGVO Art. 89 (Forschungsprivileg) |

Vollständig in [`docs/ethics-and-scope.md`](docs/ethics-and-scope.md).

---

## 📚 Weiterführende Dokumente

- 🗓️ [Master-Plan (12 Wochen)](plans/00-master-plan.md)
- 🎯 [Track A · DetectorLab](plans/01-detectorlab.md)
- 🛡️ [Track B · SpoofStack](plans/02-spoofstack.md)
- 📊 [Experiment-Matrix](plans/03-experiment-matrix.md)
- 📄 [Deliverables](plans/04-deliverables.md)
- ✅ [Validation Round 1 (4 Reviewer)](plans/05-validation-feedback.md)
- 🎯 [Threat-Model](docs/threat-model.md)
- ⚖️ [Ethics & Scope](docs/ethics-and-scope.md)
- 📐 [Probe-Schema v1](docs/probe-schema.md)
- 🧮 [Probe-Inventar (60+ Probes)](probes/inventory.yml)
- 🐳 [SpoofStack-Layer](stack/layers.md)
- 📚 [Bibliography](refs/bibliography.md)

---

<p align="center">
  <em>Built with rigor. Reviewed by four. Blocked by law — until the lawyers say otherwise. 🎓</em>
</p>
