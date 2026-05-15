# Detection Agent

> **Role:** Measurement oracle. Runs detection probes against an Android target and emits a JSON report.

## What this agent does

1. Loads the 75-probe inventory from `shared/probes/inventory.yml`
2. Runs each probe via `adb` against the target environment
3. Validates results against `shared/probe-schema.md`
4. Emits a single JSON report with per-probe scores (0.0 = real device, 1.0 = obviously container)

## What this agent does NOT do

- Decide which container configuration to test — that's the **Stability Agent**'s job.
- Bring containers up or down — that's the **Orchestrator Agent**'s job.
- Modify probe definitions — they live in `shared/` and are read-only here.

## Inputs

```yaml
target:
  kind: container        # or "device"
  container_id: cph-l3-baseline-001
  # OR for real device:
  # kind: device
  # adb_serial: 12345678
probe_filter:           # optional
  categories: [buildprop, root, integrity]
  # OR ids: [1, 3, 7, 14]
```

## Outputs

`reports/{run_id}.json` — JSON-Schema-validated per the contract in `shared/probe-schema.md`.

## Source layout

```
src/
├── core/                  # Probe contract + runner orchestration
│   ├── Probe.kt           # interface
│   ├── ProbeResult.kt     # data class
│   ├── ProbeContext.kt    # testable abstraction (with ShellProbeContext for allowlist)
│   ├── ProbeRunner.kt     # orchestrator with timeout + failure isolation
│   └── Report.kt          # top-level JSON-Schema binding
└── probes/                # Individual probe implementations
    └── buildprop/
        └── BuildFingerprintProbe.kt  # Probe #1 reference impl
    # TODO: 74 more probes (root, integrity, identity, sensors, network, etc.)
```

## Status

**SCAFFOLD.** Code compiles only conceptually — no Gradle setup yet.

To make this a real Android app:
1. Convert `src/` into a Gradle Android module (`gradle init --type android-application`)
2. Pin deps in `gradle/libs.versions.toml`: Kotlin coroutines, kotlinx.serialization, kotlin.test
3. Wire `ProbeRunner` to a `MainActivity`
4. Add Android manifest with required permissions
5. Implement remaining 74 probes per the inventory
6. CI: APK build + on-real-Pixel-7 score < 0.05 check

## Probe contract (invariants every probe must honor)

1. Complete in ≤ 5 seconds (hard timeout enforced by `ProbeRunner`).
2. Never makes network requests to live third-party services.
3. Produces a deterministic JSON-Schema-valid `ProbeResult`.
4. Never throws uncaught exceptions — failures map to `ProbeResult.failed()`.
5. Declares its category, severity, and android-layer up-front.
6. Runnable on a Pixel 7 (real device) producing score < 0.05 (true-negative test).
7. Runnable on vanilla ReDroid 12 producing score > 0.85 (true-positive test).
