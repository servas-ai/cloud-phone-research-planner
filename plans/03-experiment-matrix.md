# Experiment Matrix

Layer-by-Layer-Vermessung. Jede Zelle = DetectorLab-Score von Probe X gegen Stack-Konfiguration Y, gemittelt ueber N=30 Runs.

## Konfigurations-Achsen

```
              | Real | L0  | L0+L1 | L0+L1+L2 | L0+...+L3 | L0+...+L4 | L0+...+L5 | Full
Probe         |Pixel7|     |       |          |           |           |           |
--------------|------|-----|-------|----------|-----------|-----------|-----------|------
#1 Build FP   |  0.0 | 0.95|  0.05 |   0.05   |   0.05    |   0.05    |   0.05    | 0.05
#2 Integrity  |  0.0 | 1.0 |  0.85 |   0.80   |   0.10    |   0.10    |   0.10    | 0.05
#3 Root       |  0.0 | 0.90|  0.90 |   0.90   |   0.90    |   0.05    |   0.05    | 0.05
#4 Emulator   |  0.0 | 0.80|  0.20 |   0.20   |   0.20    |   0.20    |   0.10    | 0.05
#5 IP/ASN     |  0.0 | 0.95|  0.95 |   0.95   |   0.95    |   0.95    |   0.95    | 0.05
#6 Keystore   |  0.0 | 1.0 |  1.0  |   1.0    |   0.15    |   0.15    |   0.15    | 0.10
... (60 Zeilen)
--------------|------|-----|-------|----------|-----------|-----------|-----------|------
Aggregate     |  0.02| 0.78|  0.55 |   0.42   |   0.28    |   0.18    |   0.12    | 0.06
```

(Werte oben sind **erwartete** Hypothesen, nicht gemessen.)

## Statistische Methodik

| Aspekt | Vorgehen |
|---|---|
| Sample-Size | N=30 pro Konfiguration -> Central Limit Theorem fuer Score-Mittelwerte |
| Konfidenz | 95% Confidence-Intervals via Bootstrap |
| Layer-Wirksamkeit | McNemar-Test zwischen L_n und L_n+1 |
| Inter-Probe-Korrelation | Pearson-Matrix, identifiziert redundante Probes |
| Heatmap | Matrix-Plot mit Diverging-Colormap (gruen=resistent, rot=detektiert) |

## Run-Protokoll

```
1. Container aus Snapshot starten (clean state)
2. DetectorLab APK installieren
3. 30s warten (Sensoren initialisieren)
4. Probe-Suite ausfuehren (~ 2-3 min)
5. JSON-Report in experiments/runs/ ablegen
6. Container zerstoeren
7. Wiederholen N=30
```

## Dokumentation pro Run

```
experiments/runs/{config-id}/{run-N}.json
experiments/runs/{config-id}/manifest.yml   # Modul-Versionen, Egress-IP-ASN
experiments/aggregate/{config-id}.csv       # Mean, StdDev, CI pro Probe
experiments/heatmap.svg
experiments/heatmap.csv
```

## Erwartete "harte" Probes (Hypothesen)

Probes, die selbst im Full-Stack einen Score > 0.1 behalten koennten:

| # | Probe | Warum hart |
|---|---|---|
| #6 | Keystore Attestation | Wenn Keybox revoked oder strenge Cert-Validierung (ROCA) |
| #24 | Sensor FFT | VirtualSensor + Trace-Player kann ML-Klassifikation nicht 1:1 |
| #30 | /proc/version | Host-Kernel leakt durch Container-Boundary |
| #56 | WebGL Fingerprint | Software-Renderer hat eindeutige Signatur |
| #57 | Touch Pressure | Kein realer Capacitive-Sensor verfuegbar |

Wenn Hypothese zutrifft: das sind die Beitraege fuers Paper.
