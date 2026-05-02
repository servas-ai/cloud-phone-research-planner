# Track A — DetectorLab

Eigenstaendige Android-App, die alle Detection-Punkte standardisiert misst. Open-Source-Referenzimplementierung als wissenschaftliches Mess-Instrument.

## Architektur

```
DetectorLab (Kotlin, Min SDK 30, Target SDK 34)
|-- core/
|   |-- Probe.kt              # Interface
|   |-- ProbeResult.kt        # {score, evidence[], method, runtimeMs}
|   |-- ProbeRunner.kt        # Orchestrator
|   `-- Report.kt             # JSON Schema v1
|-- probes/
|   |-- buildprop/            # Probe #1, #7, #9, #27, #28
|   |-- integrity/            # Probe #2, #6
|   |-- root/                 # Probe #3, #14
|   |-- emulator/             # Probe #4, #26, #30
|   |-- network/              # Probe #5, #18, #25, #37, #38
|   |-- identity/             # Probe #11, #12, #15, #16, #17, #21, #22, #29, #31, #32
|   |-- runtime/              # Probe #8, #19, #50
|   |-- sensors/              # Probe #24, #42-45 (mit FFT-Analyse)
|   |-- ui/                   # Probe #23, #46, #52
|   `-- env/                  # Probe #13, #20, #33-36, #40, #47-49
|-- ui/
|   |-- DashboardActivity.kt  # Score-Heatmap
|   |-- ProbeDetailScreen.kt  # Evidence-Drilldown
|   `-- ExportActivity.kt     # JSON-Export, Share via ADB
`-- export/
    `-- v1-schema.json
```

## Probe-Interface

```kotlin
interface Probe {
    val id: String           // "buildprop.fingerprint"
    val rank: Int            // 1..60
    val category: Category
    suspend fun run(ctx: ProbeContext): ProbeResult
}

data class ProbeResult(
    val score: Double,        // 0.0 = real device, 1.0 = certain emulator
    val evidence: List<Evidence>,
    val method: String,       // human-readable methodology
    val runtimeMs: Long,
    val confidence: Double    // statistical confidence
)
```

## Sprint-Plan

### Sprint 1 (Woche 2) — Skeleton
- [ ] Gradle-Projekt + Min-SDK-Konfiguration
- [ ] Probe-Interface + Runner
- [ ] JSON-Report v1
- [ ] Dummy-Probe + Integration-Test

### Sprint 2 (Woche 3) — Basics
- [ ] BuildPropProbe (#1, #7, #9, #27, #28)
- [ ] RootProbe (#3, #14)
- [ ] EmulatorProbe (#4, #26)
- [ ] Selbsttest auf Pixel 7

### Sprint 3 (Woche 4) — Identity & Runtime
- [ ] IdentityProbes (#11, #12, #15, #16, #17, #29)
- [ ] RuntimeProbes (#8, #19, #50)
- [ ] Network-Type-Probe (#25)

### Sprint 4 (Woche 5) — Integrity & Sensors
- [ ] PlayIntegrityProbe (#2)
- [ ] KeystoreAttestationProbe (#6)
- [ ] SensorFFTProbe (#24, #42-45) — 30s Sampling, FFT-Analyse, Noise-Floor

### Sprint 5 (Woche 6) — Network & Polish
- [ ] NetworkProbes (#5, #18, #20, #37)
- [ ] EnvProbes (#13, #33-36, #40)
- [ ] Dashboard-UI mit Heatmap-Visualisierung
- [ ] CI: APK-Build + Probe-Schema-Validation

## Output-Schema (JSON v1)

```json
{
  "schemaVersion": "1.0",
  "deviceLabel": "redroid-12-baseline-001",
  "timestamp": "2026-05-15T14:23:00Z",
  "appVersion": "0.1.0",
  "probes": [
    {
      "id": "buildprop.fingerprint",
      "rank": 1,
      "category": "buildprop",
      "score": 0.95,
      "confidence": 0.99,
      "evidence": [
        {"key": "ro.build.fingerprint", "value": "redroid/redroid_arm64/...", "expected": "google/panther/..."}
      ],
      "method": "Compare ro.build.fingerprint against expected manufacturer pattern",
      "runtimeMs": 4
    }
  ],
  "aggregate": {
    "weightedScore": 0.78,
    "criticalFailures": 7,
    "category": "DETECTED"
  }
}
```

## Validierung

1. **True-Negative-Test**: Auf 3 echten Geraeten (Pixel 7, Samsung S23, Xiaomi 13) muss `weightedScore < 0.05` sein.
2. **True-Positive-Test**: Auf vanilla ReDroid 12 muss `weightedScore > 0.85` sein.
3. **Reproducibility**: 10x Run auf gleicher Konfiguration -> Standardabweichung < 0.02.
