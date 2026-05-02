# Experiments

Run-Logs, Aggregate-Daten, Heatmap-Generation.

## Struktur

```
experiments/
|-- runs/
|   |-- real-pixel7/
|   |   |-- manifest.yml
|   |   |-- run-001.json
|   |   |-- ...
|   |   `-- run-030.json
|   |-- L0-baseline/
|   |-- L0-L1/
|   |-- L0-L1-L2/
|   |-- L0-L1-L2-L3/
|   |-- L0-L1-L2-L3-L4/
|   |-- L0-L1-L2-L3-L4-L5/
|   `-- full-stack/
|-- aggregate/
|   |-- all-configs.csv          # Pivot: probe_id x config_id -> mean score
|   |-- ci-95.csv                # Confidence-Intervals
|   `-- mcnemar.csv              # Layer-Wirksamkeit
|-- analysis/
|   |-- aggregate.py             # JSON-Logs -> CSV
|   |-- heatmap.py               # CSV -> SVG/PNG
|   |-- mcnemar.R                # Statistische Tests
|   `-- correlation.py           # Inter-Probe-Korrelationen
`-- artifacts/
    |-- heatmap.svg
    |-- heatmap.png
    |-- per-category-heatmap.svg
    `-- layer-effectiveness.svg
```

## Manifest-Beispiel

```yaml
config_id: L0-L1-L2-L3
created: 2026-06-15
container_image_hash: sha256:abc123...
modules:
  redroid: redroid/redroid:12.0.0_64only-2026-06-01
  magisk: v27.2
  rezygisk: v1.3.4
  lsposed: jingmatrix-v1.10.1
  device-spoof-lab-magisk: v2.1.0
  device-spoof-lab-hooks: v2.1.0
  android-faker: v8.7
  play-integrity-fork: v15
  tricky-store: v1.3.0
  keybox: keybox-2026-05-01-batch-A
target_device:
  brand: google
  model: Pixel 7
  fingerprint: google/panther/panther:14/UQ1A.240205.004/...
  security_patch: "2024-08-05"
egress:
  type: lab-lte
  asn_class: mobile
  carrier: Telekom DE
detector_lab_apk: detectorlab-0.1.0.apk
detector_lab_apk_hash: sha256:def456...
```

## Run-Skript (Pseudo-Code)

```bash
#!/bin/bash
CONFIG_ID="$1"
N="${2:-30}"

for i in $(seq 1 $N); do
  docker compose --project-name "${CONFIG_ID}-${i}" up -d
  sleep 30  # init
  adb -s emulator-${CONFIG_ID}-${i} install detectorlab.apk
  adb -s emulator-${CONFIG_ID}-${i} shell am start -n com.example.detectorlab/.MainActivity
  sleep 180  # run probes
  adb -s emulator-${CONFIG_ID}-${i} pull /sdcard/Download/detectorlab-report.json \
       experiments/runs/${CONFIG_ID}/run-$(printf '%03d' $i).json
  docker compose --project-name "${CONFIG_ID}-${i}" down -v
done
```

## Auswertung

```bash
python analysis/aggregate.py experiments/runs > experiments/aggregate/all-configs.csv
python analysis/heatmap.py experiments/aggregate/all-configs.csv \
   --output experiments/artifacts/heatmap.svg
Rscript analysis/mcnemar.R experiments/runs > experiments/aggregate/mcnemar.csv
```
