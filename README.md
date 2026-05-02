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

## Repository-Layout

```
.
|-- README.md                    # Dieses Dokument
|-- plans/                       # Phasenpläne, Sprints, Experiment-Matrix
|   |-- 00-master-plan.md
|   |-- 01-detectorlab.md
|   |-- 02-spoofstack.md
|   |-- 03-experiment-matrix.md
|   `-- 04-deliverables.md
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
| DetectorLab MVP | planned | 3–6 |
| SpoofStack Baseline | planned | 3–4 |
| Layer-by-Layer Experiments | planned | 7–10 |
| Paper / Thesis Draft | planned | 11–12 |

Siehe `plans/00-master-plan.md` für Details.

## Lizenz

Forschungs-Code: Apache-2.0. Stack-Konfigurationen: nur als Referenz im Lab, nicht produktionsreif.
