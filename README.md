# Cloud Phone Research Planner

Akademisches Forschungsprojekt zur empirischen Evaluation der Erkennbarkeit virtualisierter Android-Umgebungen (ReDroid / MobileRun) gegenüber App-seitiger Detection.

> **Hochschulkontext** — Dieses Repository ist die Planungs- und Tracking-App für das Forschungsvorhaben.
> Es enthält **kein** Spoofing-Tooling und **keine** Anleitungen gegen Drittsysteme. Tests laufen ausschliesslich gegen die selbstentwickelte `DetectorLab`-Suite im isolierten Lab.

## Forschungsfrage

> Welche Android-Detection-Methoden (Build-Properties, Hardware-Attestation, Sensor-Signaturen, Netzwerk-Fingerprints) bleiben robust gegen Container-basierte Virtualisierung mit ARM-nativen Cloud-Phone-Stacks (ReDroid 12), und welche lassen sich layer-weise schliessen?

## Zwei Tracks

| Track | Rolle | Inhalt |
|---|---|---|
| **A — DetectorLab** | Red Team / Mess-Oracle | Eigene Android-App, die alle 60 Detection-Punkte standardisiert misst und JSON-Reports erzeugt. Open-Source-Beitrag. |
| **B — SpoofStack** | Blue Team / Subject Under Test | ReDroid-12-basierter Stack mit modular zuschaltbaren Mitigation-Layern (L0–L6). Wird **gegen DetectorLab** geprüft, nicht gegen Live-Plattformen. |

## System-Architektur

```mermaid
flowchart TB
    subgraph LAB["🔬 ISOLIERTES LABOR (eigenes VLAN, keine Live-Plattformen)"]
        direction TB

        subgraph TRACKB["🛡️ TRACK B — SpoofStack (Subject Under Test)"]
            direction TB
            L6["L6 · Network Egress<br/>Lab-LTE-Modem · Mobile-ASN"]
            L5["L5 · Sensor Emulation<br/>VirtualSensor + Trace-Player"]
            L4["L4 · Runtime Hiding<br/>Shamiko + HideMyAppList"]
            L3["L3 · Integrity & Attestation<br/>PIF + TrickyStore + Keybox"]
            L2["L2 · Identity Spoofing<br/>Android Faker"]
            L1["L1 · Build Properties<br/>DeviceSpoofLab Hooks/Magisk"]
            L0B["L0b · Root-Stack<br/>Magisk + ReZygisk + LSPosed"]
            L0A["L0a · Vanilla Container<br/>ReDroid 12 ARM64"]

            L0A --> L0B --> L1 --> L2 --> L3 --> L4 --> L5 --> L6
        end

        subgraph TRACKA["🎯 TRACK A — DetectorLab (Mess-Oracle)"]
            direction TB
            APP["Android-App · Kotlin<br/>Min SDK 30 · Target 34"]
            CORE["ProbeRunner · 60+ Probes<br/>Kategorien: buildprop · integrity · root ·<br/>emulator · network · identity · runtime ·<br/>sensors · ui · env"]
            REPORT["JSON Report v1<br/>Score 0.0–1.0 + Evidence + Confidence"]
            APP --> CORE --> REPORT
        end

        TRACKB -.->|"Probe-Antworten"| TRACKA
        TRACKA -.->|"Detection-Score"| MATRIX
    end

    subgraph ANALYSIS["📊 AUSWERTUNG"]
        direction LR
        MATRIX["Experiment-Matrix<br/>60 Probes × 8 Configs × N=60 Runs"]
        STATS["Statistik<br/>McNemar + Benjamini-Hochberg<br/>2⁶ Fractional-Factorial"]
        HEATMAP["Detection-Resistance-Heatmap"]
        MATRIX --> STATS --> HEATMAP
    end

    subgraph DELIV["📄 DELIVERABLES"]
        direction LR
        OSS["DetectorLab OSS<br/>Apache-2.0"]
        PAPER["Paper<br/>USENIX/CCS/NDSS"]
        THESIS["Thesis-Kapitel"]
        REPRO["Reproducibility-Pack<br/>(institutional access)"]
    end

    LAB --> ANALYSIS --> DELIV

    classDef trackB fill:#fef3e0,stroke:#d97706,stroke-width:2px
    classDef trackA fill:#dcfce7,stroke:#16a34a,stroke-width:2px
    classDef lab fill:#fef9e8,stroke:#a16207,stroke-width:1px
    classDef analysis fill:#dbeafe,stroke:#2563eb,stroke-width:2px
    classDef deliv fill:#f3e8ff,stroke:#9333ea,stroke-width:2px

    class L0A,L0B,L1,L2,L3,L4,L5,L6 trackB
    class APP,CORE,REPORT trackA
    class MATRIX,STATS,HEATMAP analysis
    class OSS,PAPER,THESIS,REPRO deliv
```

## Adversarial Test-Loop

```mermaid
sequenceDiagram
    autonumber
    participant Researcher
    participant Snapshot as Container Snapshot<br/>(L0a → Full-Stack)
    participant SpoofStack as Track B<br/>SpoofStack
    participant DetectorLab as Track A<br/>DetectorLab
    participant Runner as experiments/runner
    participant Stats as Statistical Analysis

    Researcher->>Snapshot: Build immutable image per layer config
    loop N=60 Runs pro Konfiguration
        Runner->>SpoofStack: docker compose up (clean state)
        Runner->>SpoofStack: install DetectorLab.apk
        SpoofStack->>DetectorLab: trigger ProbeRunner
        DetectorLab->>SpoofStack: query Build-Props, Integrity, Root, Sensors, ...
        SpoofStack-->>DetectorLab: spoofed/real responses
        DetectorLab->>Runner: JSON report (60+ probe scores)
        Runner->>Runner: schema-validate + persist run-N.json
        Runner->>SpoofStack: docker compose down -v
    end
    Runner->>Stats: aggregate runs/{config-id}/*.json
    Stats->>Stats: McNemar + BH-FDR + Power-Calc
    Stats->>Researcher: Heatmap + harte-Probes-Liste
```

## 12-Wochen-Phasenplan

```mermaid
gantt
    title Forschungsprojekt — Phasen & Sprints
    dateFormat YYYY-MM-DD
    axisFormat %W

    section Phase 0
    Scope & Ethics & IRB-Submission     :crit, p0a, 2026-05-04, 7d
    OSF Pre-Registration                :crit, p0b, after p0a, 3d
    Hardware-Procurement                :p0c, 2026-05-04, 14d

    section Track A — DetectorLab
    Sprint 1 · Skeleton                 :a1, 2026-05-11, 7d
    Sprint 2 · BuildProp+Root+Emulator  :a2, after a1, 7d
    Sprint 3 · Identity+Runtime         :a3, after a2, 7d
    Sprint 4 · Integrity+Sensor-FFT     :a4, after a3, 7d
    Sprint 5 · Network+Polish           :a5, after a4, 7d

    section Track B — SpoofStack
    Sprint A · L0a/L0b Baseline         :b1, 2026-05-18, 7d
    Sprint B · L1+L2                    :b2, after b1, 7d
    Sprint C · L3+L4 (Keybox-Approval!) :crit, b3, after b2, 7d
    Sprint D · L5+L6                    :b4, after b3, 7d

    section Phase 3-5
    Layer-Experiments (8 configs)       :exp, 2026-06-29, 21d
    Statistical Analysis                :stats, after exp, 7d
    Paper Draft & Submission            :crit, paper, after stats, 14d
```

## Threat-Model Mapping

```mermaid
flowchart LR
    subgraph DETECT["Detection-Layer (Android Stack)"]
        direction TB
        APPL["Application Layer<br/>#2 Play Integrity · #56 WebGL"]
        FRAME["Framework Layer<br/>#11 ANDROID_ID · #16 GAID · #24 Sensors"]
        NATIVE["Native Layer<br/>#1 getprop · #3 su · #14 SELinux"]
        KERNEL["Kernel Layer<br/>#4 QEMU · #30 /proc/version · #62 kallsyms"]
        HARDWARE["Hardware Layer<br/>#6 TEE Attestation · #29 MediaDRM"]
        NETWORK["Network Layer<br/>#5 IP/ASN · #61 JA4 · #62 TCP-Stack"]
    end

    subgraph MITIG["Mitigation-Layer (SpoofStack)"]
        direction TB
        L1M["L1 Build-Props"]
        L2M["L2 Identity"]
        L3M["L3 Integrity"]
        L4M["L4 Hiding"]
        L5M["L5 Sensors"]
        L6M["L6 Network"]
    end

    APPL -.- L3M
    FRAME -.- L2M
    NATIVE -.- L1M
    KERNEL -.- L1M
    HARDWARE -.- L3M
    HARDWARE -.- L5M
    NETWORK -.- L6M
    APPL -.- L4M

    subgraph ADV["Adversary Capability"]
        ADVA["L_AdvA · static-rule"]
        ADVB["L_AdvB · ML-classifier auf Probe-Vector"]
        ADVC["L_AdvC · Deep-ML auf Sensor-Traces"]
    end

    classDef hard fill:#fee2e2,stroke:#dc2626
    classDef soft fill:#dcfce7,stroke:#16a34a
    classDef ext fill:#dbeafe,stroke:#2563eb

    class HARDWARE,NETWORK hard
    class APPL,FRAME soft
    class NATIVE,KERNEL ext
```

## Repository-Layout

```
.
|-- README.md                    # Dieses Dokument
|-- plans/                       # Phasenpläne, Sprints, Experiment-Matrix
|   |-- 00-master-plan.md
|   |-- 01-detectorlab.md
|   |-- 02-spoofstack.md
|   |-- 03-experiment-matrix.md
|   |-- 04-deliverables.md
|   `-- 05-validation-feedback.md  # Multi-Reviewer-Round-1 (4 Reviewer)
|-- docs/                        # Hintergrund + Methodologie
|   |-- ethics-and-scope.md
|   |-- threat-model.md
|   |-- probe-schema.md
|   `-- glossary.md
|-- probes/                      # Probe-Inventar (60 Punkte) als YAML
|   `-- inventory.yml
|-- stack/                       # SpoofStack-Layer-Spezifikationen
|   `-- layers.md
|-- experiments/                 # Run-Logs, Heatmap-Daten, Auswertungen
|   `-- README.md
`-- refs/                        # Literatur & OSS-Baseline-Referenzen
    `-- bibliography.md
```

## Status

| Phase | Status | Woche |
|---|---|---|
| Scope & Ethics | drafted | 1 |
| Probe Inventory | drafted | 1–2 |
| **Validation Round 1** | **NEEDS_REVISION** (4 reviewer) | 1 |
| DetectorLab MVP | blocked by F21/F22/F23 | 3–6 |
| SpoofStack Baseline | blocked by F21/F22 | 3–4 |
| Layer-by-Layer Experiments | planned | 7–10 |
| Paper / Thesis Draft | planned | 11–12 |

Siehe `plans/00-master-plan.md` und `plans/05-validation-feedback.md` für Details.

### Top-3 Blocker vor Phase 0

```mermaid
flowchart LR
    F22["F22 · Keybox-Provenienz<br/>§259 StGB Risiko"]
    F21["F21 · Privileged Docker<br/>Host-Root-Escape"]
    F23["F23 · Reproducibility-Pack<br/>§202c-Recipe"]
    LEGAL["Universitäts-Rechtsabteilung<br/>+ Ethik-Kommission"]
    GO["✅ Phase 0 GO"]

    F22 --> LEGAL
    F21 --> LEGAL
    F23 --> LEGAL
    LEGAL --> GO

    classDef block fill:#fee2e2,stroke:#dc2626,stroke-width:2px
    classDef gate fill:#fef3c7,stroke:#d97706,stroke-width:2px
    classDef go fill:#dcfce7,stroke:#16a34a,stroke-width:2px

    class F22,F21,F23 block
    class LEGAL gate
    class GO go
```

## Lizenz

Forschungs-Code: Apache-2.0. Stack-Konfigurationen: nur als Referenz im Lab, nicht produktionsreif.
