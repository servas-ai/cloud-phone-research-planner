# detector-lab — host-side probe driver harness

This directory hosts the probe-driver harness for the baseline matrix
(`Pixel 8 / 9 / 9 Pro × Android 14 / 15 / 16`, see CLO-13). The on-device
probe code lives in the Gradle project under
`docs/super-action/W3/detector-lab/`, which will be promoted into
`apps/detector-lab/app/` once the W3 sprint is reviewed. The artifacts in
**this** directory are the **host-side** tools that drive a single cell
end-to-end without any manual `adb` invocation.

| File | Role |
|---|---|
| `scripts/droidrun-cell.sh` | one-cell driver — calls droidrun, runs the probe plan, writes schema-v2 JSON |
| `scripts/probe_emit.py` | normalises raw probe output into a `shared/probe-schema.v2.json` record |
| `scripts/probe-plan.json` | default 3-probe smoke plan (auto-generated on first run) |
| `examples/probe-result.fixture.json` | reference schema-v2 record for CI / docs |
| `out/matrix/` | per-cell output (gitignored; only `.gitkeep` is committed) |

## 1. Host-side install

droidrun is a Python CLI; install it once per workstation with `pipx` so the
runtime is isolated from system Python and other research projects.

```bash
# Anchor to the version line CLO-9 is scoped against.
pipx install 'droidrun==0.4.*'

# Sanity check.
droidrun --version

# adb must be on PATH (Google platform-tools 35.x is the W7 pin).
adb --version
```

If your operator workstation already has a different droidrun pinned for
another project, install in an isolated venv instead:

```bash
pipx install --suffix '@cprp' 'droidrun==0.4.*'
DROIDRUN_BIN=droidrun@cprp DROIDRUN_PIN='0.4.*' \
  apps/detector-lab/scripts/droidrun-cell.sh --cell pixel8-a15 --adb-serial …
```

> **Important.** This harness consumes droidrun as a **driver CLI only**. It
> does **not** install the rebranded mobilerun-portal APK or enable the
> accessibility service — that flow lives in
> `docs/super-action/W10/droidrun-install.sh` and is governed by the W10
> integration playbook. CLO-9 (this directory) intentionally stays at host
> scope so the matrix sweep (CLO-13) can run before W10 lands.

## 2. Running one cell

```bash
# Live run against a connected device.
apps/detector-lab/scripts/droidrun-cell.sh \
  --cell pixel8-a15 \
  --adb-serial emulator-5554
# -> writes apps/detector-lab/out/matrix/pixel8-a15.json
```

The script:

1. Validates that `droidrun`, `python3`, and `jq` are on `PATH`
   (`droidrun` check is skipped under `--dry-run`).
2. Reads the probe plan (default 3 probes; override with `--plan`).
3. For each probe, invokes `droidrun adb -s <serial> shell <cmd>` with a
   per-probe timeout (default 180s, override with `--timeout`).
4. Pipes the raw stdout through `probe_emit.py`, which builds a record that
   conforms to [`shared/probe-schema.v2.json`](../../shared/probe-schema.v2.json)
   (CLO-21 META-21). Validation is in-process via `jsonschema`; any drift
   fails the cell.
5. Appends records to `out/matrix/<cell>.partial.json` as it goes; on
   success the file is atomically renamed to `out/matrix/<cell>.json`. Use
   `--keep-partial` to preserve the partial on failure.

## 3. Dry-run / CI mode

`--dry-run` bypasses droidrun and uses canned probe output. This is the path
that CI runs to exercise the script + emitter under
`ajv validate -s shared/probe-schema.v2.json -d 'apps/detector-lab/out/**/*.json'`.

```bash
apps/detector-lab/scripts/droidrun-cell.sh --cell pixel8-a15 --dry-run
python3 -c "
import json, jsonschema
schema = json.load(open('shared/probe-schema.v2.json'))
for r in json.load(open('apps/detector-lab/out/matrix/pixel8-a15.json')):
    jsonschema.validate(r, schema)
print('ok')
"
```

## 4. Authoring a probe plan

The plan is a JSON array of objects with seven keys:

```json
[
  {
    "probe_id": "buildprop.fingerprint",
    "probe_name": "BuildFingerprintProbe",
    "category": "buildprop",
    "layer": "L1",
    "command": "getprop ro.build.fingerprint",
    "scoring": "regex_match",
    "score_pattern": "userdebug|test-keys|generic|emu"
  }
]
```

- `category` must be one of the v2 enum (`buildprop|integrity|root|emulator|network|identity|runtime|sensors|ui|env`).
- `layer` must be one of `L0a|L0b|L0c|L0|L1|L2|L3|L4|L5|L6`.
- `scoring`:
  - `regex_match` — score is 1 if `score_pattern` matches the raw output, else 0.
  - `negated_clean` — score is 0 only if the raw output is **exactly** equal
    to `score_pattern` (e.g. the literal `CLEAN` sentinel); else 1.

Authoring new probe ids: the probe identifier regex is
`^[a-z][a-z0-9]*\.[a-z][a-z0-9_]*$`. See `shared/probes/inventory.yml` for
the canonical 71-probe registry (CLO-22 META-22).

## 5. Schema-v2 envelope

Every record emitted by this harness has the following required fields:

| Field | Type | Purpose |
|---|---|---|
| `schema_version` | const `"2.0"` | Pinned for forward-compat. |
| `probe_id` | string (regex above) | Stable id; foreign-keys into inventory. |
| `probe_name` | string | Human probe class name. |
| `category` | enum | Detection-surface category. |
| `layer` | enum `L0a..L6` | Mitigation layer in BEST-STACK. |
| `score` | `0..1` | 0 = clean, 1 = certain-detected. |
| `runtime_ms` | int ≥ 0 | Wall clock for the probe shell call. |
| `sample_count` | int ≥ 1 | Number of samples (default 1). |
| `seed_ms` | int | Epoch ms at probe start. Reproducibility. |
| `raw` | object | Free-form probe output. |

Optional fields (`confidence`, `evidence`, `repro`, `notes`) follow the
schema. See `examples/probe-result.fixture.json` for a complete record.

## 6. Cross-links

- META-21 (CLO-21) — probe-schema-v2 + CI ajv gate.
- META-22 (CLO-22) — probe inventory canonicalization.
- W10 — droidrun-mobilerun-portal install + rebrand (separate concern).
- CLO-13 — baseline-matrix sweep that consumes `out/matrix/<cell>.json`.
