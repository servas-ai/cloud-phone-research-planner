# Deliverables

## D1 — DetectorLab (Open Source)

| Item | Format | Lizenz |
|---|---|---|
| Source Code | Kotlin/Gradle Repository | Apache-2.0 |
| Pre-built APK | Release-Asset | — |
| Probe-Schema | JSON Schema v1 | CC-BY-4.0 |
| Dokumentation | Markdown + Screenshots | CC-BY-4.0 |

## D2 — Methodologie-Paper

**Titel (Arbeitstitel):** *An Empirical Layer-by-Layer Evaluation of Android Container Detection Resistance*

**Sektionen:**
1. Introduction & Threat Model
2. Related Work (trustdevice-android, AntiFakerAndroidChecker, Cryptomathic 2025)
3. DetectorLab Methodology (60 Probes, Schema, Validation)
4. SpoofStack Architecture (L0-L6)
5. Experiment Matrix & Statistical Analysis
6. Findings: Hard Detection Vectors
7. Discussion: Implications for Anti-Fraud Systems
8. Ethical Considerations
9. Reproducibility Statement

**Zielkonferenzen:**
- USENIX Security
- ACM CCS
- NDSS
- WOOT Workshop
- DIMVA
- IEEE EuroS&P

## D3 — Reproducibility-Pack

```
reproducibility/
|-- detectorlab-v1.0.apk
|-- detectorlab-source.tar.gz
|-- spoofstack-manifests/
|   |-- L0-baseline.yml
|   |-- L0-L1-L2.yml
|   |-- ...
|   `-- full-stack.yml
|-- experiments-data.tar.gz   # alle 30 Runs pro Config als JSON
|-- analyse-scripts/
|   |-- aggregate.py
|   |-- heatmap.py
|   `-- mcnemar.R
`-- README-reproduce.md
```

## D4 — Threat-Model-Dokumentation

STRIDE-orientiert, mappt jede Detection-Methode auf Android-Layer:

```
Application Layer    -> Probes #2 (Play Integrity API), #56 (WebGL)
Framework Layer      -> Probes #11 (Settings.Secure), #16 (GAID)
Native Layer         -> Probes #1 (getprop), #14 (SELinux)
Kernel Layer         -> Probes #4 (/proc/kernel), #30 (/proc/version)
Hardware Layer       -> Probes #6 (TEE Attestation), #24 (Sensor Hardware)
Network Layer        -> Probes #5 (IP/ASN), #18 (VPN), #20 (TZ-Geo)
```

## D5 — Thesis-Kapitel (falls Hochschul-Format)

| Kapitel | Inhalt | Quelle |
|---|---|---|
| 1 Einleitung | Problemstellung, Forschungsfrage | `README.md`, `00-master-plan.md` |
| 2 Grundlagen | Android-Architektur, Container, Detection-Theorie | `docs/threat-model.md` |
| 3 Verwandte Arbeiten | OSS-Tools, kommerzielle Anti-Fraud | `refs/bibliography.md` |
| 4 DetectorLab | Design, 60 Probes, Validation | `01-detectorlab.md` |
| 5 SpoofStack | L0-L6, Konflikt-Vermeidung | `02-spoofstack.md` |
| 6 Experimente | Matrix, Statistik | `03-experiment-matrix.md` |
| 7 Ergebnisse | Heatmap, harte Probes | `experiments/` |
| 8 Diskussion & Ethik | Implikationen, ToS-Grenzen | `docs/ethics-and-scope.md` |
| 9 Fazit & Ausblick | offene Fragen | — |

## Zeitplan-Mapping

| Woche | Deliverable-Fortschritt |
|---|---|
| 1 | D2 Outline, D4 Threat-Model-Skizze |
| 2-6 | D1 DetectorLab |
| 3-4 | D3 SpoofStack-Manifests Phase 1 |
| 7-9 | D3 vollstaendig, Layer-Experimente |
| 10 | Statistische Auswertung, Heatmaps |
| 11 | D2 Paper-Draft, D5 Thesis-Kapitel |
| 12 | Review, Submission |
