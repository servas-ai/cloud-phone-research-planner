# Orchestrator Agent

> **Role:** Coordinates Detection + Stability across the full experiment matrix and produces the final heatmap.

## What this agent does

1. Generates the run matrix (e.g. 8 configs × N=60 runs = 480 cycles)
2. For each cell:
   - Calls **Stability Agent** to bring up the container
   - Calls **Detection Agent** to measure detection scores
   - Records the result in `results/journal.sqlite`
   - Calls Stability Agent to tear it down
3. Aggregates all 480 runs into a CSV
4. Generates the final heatmap

## What this agent does NOT do

- Run probes itself (delegates to Detection Agent)
- Manage container lifecycle (delegates to Stability Agent)
- Decide probe definitions (read-only from `shared/`)

## Architecture flow

```
matrix.plan → for each cell:
    Stability.up  → container_id
    Detection.run_suite(container_id) → report
    journal.commit(cell, report)
    Stability.down
→ aggregate.statistics → CSV
→ aggregate.heatmap    → SVG
```

## Files

- `agent.yaml` — Paperclip manifest
- `SPEC.md` — 10-module Python orchestrator design (CLI, container_lifecycle, image_verifier, journal, etc.)
- `EXPERIMENTS.md` — run-protocol documentation, manifest examples

## Status

**SPEC-only.** The actual Python implementation is not written yet.
SPEC.md describes the 10 modules:

1. `runner.py` — Typer CLI entry point
2. `config_loader.py` — YAML + JSON-Schema validation
3. `run_id.py` — BLAKE3 over canonical manifest + APK + seed
4. `container_lifecycle.py` — compose up/down with hardened policy
5. `image_verifier.py` — sha256 image hash pin
6. `report_validator.py` — JSON-Schema Draft 2020-12
7. `journal.py` — SQLite resumability
8. `aggregator.py` — pandas/numpy/scipy
9. `observability.py` — structlog + Prometheus textfile
10. `cli.py` — `run / verify / aggregate / journal` subcommands

To implement: pin versions in `pyproject.toml`, scaffold modules, write tests.
