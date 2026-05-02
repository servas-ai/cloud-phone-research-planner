# Master Plan — Cloud Phone Research

## 1. Ziel

Reproduzierbare, layer-weise quantifizierte Aussage darüber, welche Android-Detection-Vektoren von einem ARM-nativen Container-Stack (ReDroid 12) **mit** und **ohne** zugeschaltete Mitigation-Layer überlistet werden können.

Endprodukt: Detection-Resistance-Heatmap (60 Probes x N Stack-Konfigurationen) + Paper / Thesis.

## 2. Kernhypothesen

| # | Hypothese | Falsifizierbar durch |
|---|---|---|
| H1 | Build-Property- und ID-Probes lassen sich vollstandig durch L1+L2 schliessen. | DetectorLab-Score = 0 fuer Probe 1, 9, 11, 12, 15, 27, 28 nach L1+L2 |
| H2 | Hardware-Keystore-Attestation bleibt der robusteste Vektor; nur durch L3 (TrickyStore + Keybox) reduzierbar. | DetectorLab-Score > 0.5 bei L0+L1+L2, < 0.2 bei +L3 |
| H3 | Sensor-Signaturen (FFT der Accelerometer-Noise) erkennen Container auch nach VirtualSensor mit > 0.7 Konfidenz, wenn Trace-Daten kuenstlich. | A/B-Test mit echtem Geraet vs. VirtualSensor mit Realgeraet-Trace |
| H4 | IP/ASN bleibt staerkster Single-Vektor; ohne Mobile-Carrier-Egress kein Pass moeglich. | DetectorLab-Score > 0.8 bei Datacenter-Egress, < 0.1 bei LTE-Modem-Egress |

## 3. Phasen

### Phase 0 - Scope & Ethics (Woche 1)
- IRB / Ethik-Antrag draften
- Lab-Netzwerk-Isolation einrichten (kein Egress zu Live-Plattformen)
- `docs/ethics-and-scope.md` finalisieren

### Phase 1 - DetectorLab MVP (Woche 2-6)
- Probe-Schema (`docs/probe-schema.md`) verabschieden
- Kotlin-App-Skeleton + Probe-Interface
- Implementierung Probes #1-#25 (Kritisch + Hoch)
- JSON-Report-Export + lokaler Dashboard-Viewer
- Selbsttest auf Pixel 7 (Real-Geraet) -> alle Scores ~ 0.0

### Phase 2 - SpoofStack Baseline (Woche 3-4 parallel)
- ReDroid 12 ARM64 + Magisk + ReZygisk + LSPosed lauffaehig
- Snapshot-Mechanismus (Container-Image versioniert)
- Lab-LTE-Modem als Egress-Gateway

### Phase 3 - Layer-Integration (Woche 7-9)
- L1 (DeviceSpoofLab) -> Re-Run DetectorLab -> Delta dokumentieren
- L2 (Android Faker) -> Re-Run -> Delta
- L3 (PIF + TrickyStore + Keybox) -> Re-Run -> Delta
- L4 (Shamiko + HideMyAppList) -> Re-Run -> Delta
- L5 (VirtualSensor mit Realgeraet-Trace) -> Re-Run -> Delta
- L6 (LTE-Egress) -> Re-Run -> Delta

### Phase 4 - Experiment-Matrix & Statistik (Woche 10)
- N=30 Runs pro Konfiguration (Robustheit)
- Confidence-Intervals, McNemar-Test fuer Layer-Wirksamkeit
- Heatmap-Generation (`experiments/heatmap.svg`)

### Phase 5 - Paper / Thesis (Woche 11-12)
- Methodik-Sektion aus `docs/`
- Ergebnis-Sektion aus `experiments/`
- Threat-Model-Diagramm
- Reproducibility-Pack (Docker-Compose + Modul-Versionen pinned)

## 4. Risiken & Mitigation

| Risiko | Eintrittswahrscheinlichkeit | Mitigation |
|---|---|---|
| ReDroid 12 wird instabil bei vollem Modul-Stack | mittel | Snapshots, Fallback auf reduzierten Stack |
| Play Integrity rotiert Keybox -> TrickyStore obsolet | hoch | Mehrere Keyboxen testen, Ergebnis als Snapshot dokumentieren |
| Sensor-Trace-Aufnahme rechtlich heikel (eigenes Geraet) | niedrig | Nur eigene Geraete, keine Personendaten |
| Reviewer fordert Live-Plattform-Test | mittel | Vorab klarstellen: Detection-Suite ist das wissenschaftliche Oracle |

## 5. Erfolgskriterien

- [ ] DetectorLab open-sourced, dokumentiert, reproduzierbar
- [ ] Mindestens 8 Layer-Konfigurationen vermessen
- [ ] Heatmap zeigt 3+ "harte" Probes (Score > 0.3 trotz vollem Stack)
- [ ] Paper-Draft eingereicht oder Thesis-Kapitel geschrieben
- [ ] Threat-Model in STRIDE-Form publiziert
