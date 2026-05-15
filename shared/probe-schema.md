# Probe Schema v1

Standardisiertes JSON-Schema fuer Probe-Ergebnisse.

## Schema-Datei

`probes/v1-schema.json`:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://detectorlab.example/schema/v1.json",
  "title": "DetectorLab Report v1",
  "type": "object",
  "required": ["schemaVersion", "deviceLabel", "timestamp", "appVersion", "probes", "aggregate"],
  "properties": {
    "schemaVersion": { "const": "1.0" },
    "deviceLabel": { "type": "string", "description": "Lab-internal config ID" },
    "timestamp": { "type": "string", "format": "date-time" },
    "appVersion": { "type": "string", "pattern": "^\\d+\\.\\d+\\.\\d+$" },
    "probes": {
      "type": "array",
      "items": { "$ref": "#/$defs/Probe" }
    },
    "aggregate": { "$ref": "#/$defs/Aggregate" }
  },
  "$defs": {
    "Probe": {
      "type": "object",
      "required": ["id", "rank", "category", "score", "confidence", "evidence", "method", "runtimeMs"],
      "properties": {
        "id":        { "type": "string", "pattern": "^[a-z]+\\.[a-z_]+$" },
        "rank":      { "type": "integer", "minimum": 1, "maximum": 60 },
        "category":  { "enum": ["buildprop", "integrity", "root", "emulator", "network", "identity", "runtime", "sensors", "ui", "env"] },
        "score":     { "type": "number", "minimum": 0, "maximum": 1 },
        "confidence":{ "type": "number", "minimum": 0, "maximum": 1 },
        "evidence":  { "type": "array", "items": { "$ref": "#/$defs/Evidence" } },
        "method":    { "type": "string" },
        "runtimeMs": { "type": "integer", "minimum": 0 }
      }
    },
    "Evidence": {
      "type": "object",
      "required": ["key", "value"],
      "properties": {
        "key":      { "type": "string" },
        "value":    { "type": ["string", "number", "boolean"] },
        "expected": { "type": ["string", "number", "boolean", "null"] }
      }
    },
    "Aggregate": {
      "type": "object",
      "required": ["weightedScore", "criticalFailures", "category"],
      "properties": {
        "weightedScore": { "type": "number", "minimum": 0, "maximum": 1 },
        "criticalFailures": { "type": "integer", "minimum": 0 },
        "category": { "enum": ["CLEAN", "SUSPICIOUS", "DETECTED"] }
      }
    }
  }
}
```

## Score-Semantik

| Score | Bedeutung |
|---|---|
| 0.00–0.05 | Nicht detektiert (echtes Geraet) |
| 0.05–0.30 | Verdacht, aber nicht eindeutig |
| 0.30–0.70 | Erkennbar, mit Confidence |
| 0.70–1.00 | Sicher detektiert |

## Gewichtung im Aggregate

```
weightedScore = sum(probe.score * weight[probe.rank]) / sum(weight[probe.rank])

weight[rank] =
   3.0 if rank in 1..10   (kritisch)
   2.0 if rank in 11..25  (hoch)
   1.0 if rank in 26..40  (mittel)
   0.5 if rank in 41..60  (niedrig + ergaenzend)
```

## Kategorisierung

```
weightedScore < 0.10           -> CLEAN
weightedScore < 0.40           -> SUSPICIOUS
weightedScore >= 0.40          -> DETECTED
criticalFailures >= 3          -> DETECTED (override)
```

## Reproducibility

Jeder Run muss enthalten:
- `manifest.yml` Hash der Stack-Konfiguration
- Zeitstempel
- DetectorLab-App-Version
- Container-Image-Hash
- Egress-IP-ASN (anonymisiert auf /16)
