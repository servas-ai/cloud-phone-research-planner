# Stability Agent

> **Role:** SpoofStack lifecycle + health monitoring. Given a layer configuration, brings up a hardened container and watches it stay alive.

## What this agent does

1. Builds a Docker compose file for the requested layer set (L0a..L6)
2. Launches the container with hardened policy (`cap_drop:[ALL]`, seccomp, `no-new-privileges`)
3. Monitors stability for the requested duration (OOM, crashes, module health)
4. Hands the `container_id` to the **Detection Agent** for measurement
5. Emits a stability report (uptime, OOM kills, module failures)

## What this agent does NOT do

- Measure detection — that's the **Detection Agent**'s job.
- Decide which layer config to test next — that's the **Orchestrator**'s job.
- Touch the probe inventory or schema.

## Inputs

```yaml
config:
  layer_set: [L0a, L0b, L1, L2, L3]   # which layers are active
  duration_seconds: 300                # how long to keep it alive
  module_pins:                         # optional version pins
    redroid: "12.0.0_64only-2026-06-01"
    magisk: "v27.2"
```

## Outputs

- `container_id` — a string the Detection Agent uses as its target
- `reports/stability/{run_id}.json` — uptime, OOM kills, healthy bool

## Source layout

```
stack/
└── layers.md                # Definition of L0a..L6 with module manifests
# TODO:
# ├── compose/
# │   ├── L0a-baseline.yml   # vanilla ReDroid 12 only
# │   ├── L0b-root.yml       # + Magisk + ReZygisk + LSPosed
# │   ├── L1-buildprop.yml
# │   ├── L2-identity.yml
# │   ├── L3-integrity.yml
# │   ├── L4-hiding.yml
# │   ├── L5-sensors.yml
# │   └── L6-network.yml
# ├── redroid-seccomp.json   # mandatory seccomp profile
# └── healthcheck.sh
```

## Status

**SCAFFOLD.** Only `stack/layers.md` exists. The actual Docker compose
files, seccomp profile, and healthcheck scripts are not yet written.

To make this agent real:
1. Write the 8 compose files in `stack/compose/`
2. Write the seccomp profile
3. Implement the lifecycle code (Python or Kotlin) — see `agents/orchestrator/SPEC.md` §4
4. Test on an ARM64 host (Apple Silicon or Ampere)

## Hardware requirements

- **ARM64 host** (Apple Silicon M-series, or Ampere/Graviton-class server)
- **LTE modem in the lab** (for L6 Network egress tests)
- **Real Pixel 7** (or similar) as the true-negative baseline
