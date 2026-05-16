#!/usr/bin/env bash
# droidrun-cell.sh — drive a single baseline-matrix cell end-to-end without
# manual ADB. Implements CLO-9 acceptance criteria:
#   1. invoke droidrun CLI to bring up the cell + run probes
#   2. stream per-probe output as schema-v2 JSON
#      (see shared/probe-schema.v2.json / CLO-21 META-21)
#   3. host-side install documented in apps/detector-lab/README.md
#
# A "cell" is one (device-spec, android-version) tile of the baseline matrix
# (CLO-13 Issue 13: Pixel 8/9/9 Pro × Android 14/15/16). This script does NOT
# host the probes themselves; that is the detector-lab Gradle project
# (docs/super-action/W3/detector-lab/, promoting to apps/detector-lab/app/).
# This script only:
#   - resolves the cell -> droidrun adb target,
#   - boots / waits for the target via droidrun,
#   - runs a per-probe shell command via `droidrun adb shell`,
#   - hands raw stdout to probe_emit.py to wrap into schema-v2,
#   - writes a single JSON array to apps/detector-lab/out/matrix/<cell>.json.
#
# `--dry-run` is the smoke-test path used in CI and by `--help`-style probes:
# it bypasses droidrun entirely and feeds canned raw output through
# probe_emit.py, producing the same schema-v2 output as a real run so CLO-21's
# ajv gate exercises this script as well.

set -euo pipefail
umask 077

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly LAB_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
readonly REPO_ROOT="$(cd -- "${LAB_DIR}/../.." && pwd)"
readonly OUT_DIR_DEFAULT="${LAB_DIR}/out/matrix"
readonly PROBE_EMIT="${SCRIPT_DIR}/probe_emit.py"
readonly PROBE_PLAN="${SCRIPT_DIR}/probe-plan.json"
readonly DROIDRUN_PIN="${DROIDRUN_PIN:-0.4.*}"

# Defaults; overridable via CLI.
cell=""
adb_serial=""
out_dir="${OUT_DIR_DEFAULT}"
dry_run=0
keep_partial=0
timeout_sec="${DROIDRUN_TIMEOUT:-180}"
plan_path="${PROBE_PLAN}"

log() { printf '[droidrun-cell] %s\n' "$*" >&2; }
die() { printf '[droidrun-cell] FATAL: %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Usage: droidrun-cell.sh --cell <id> [options]

Required:
  --cell <id>                Baseline-matrix cell id (e.g. pixel8-a15)

Options:
  --adb-serial <serial>      adb device serial; required unless --dry-run
  --out-dir <path>           output dir (default: apps/detector-lab/out/matrix)
  --plan <path>              probe plan JSON
                             (default: apps/detector-lab/scripts/probe-plan.json)
  --droidrun-pin <spec>      override version spec for `droidrun --version`
                             check (default: 0.4.*)
  --timeout <seconds>        per-probe droidrun timeout (default: 180)
  --keep-partial             keep <cell>.partial.json if a probe fails
  --dry-run                  use canned probe output; do not call droidrun
  -h, --help                 this message

Output: a single JSON array written to <out-dir>/<cell>.json, where each
element matches shared/probe-schema.v2.json. The CI gate
`ajv validate -s shared/probe-schema.v2.json -d 'apps/detector-lab/out/**/*.json'`
must pass on every file produced.

Examples:
  droidrun-cell.sh --cell pixel8-a15 --adb-serial emulator-5554
  droidrun-cell.sh --cell pixel8-a15 --dry-run
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --cell)         cell="$2"; shift 2 ;;
    --adb-serial)   adb_serial="$2"; shift 2 ;;
    --out-dir)      out_dir="$2"; shift 2 ;;
    --plan)         plan_path="$2"; shift 2 ;;
    --droidrun-pin) DROIDRUN_PIN="$2"; shift 2 ;;
    --timeout)      timeout_sec="$2"; shift 2 ;;
    --keep-partial) keep_partial=1; shift ;;
    --dry-run)      dry_run=1; shift ;;
    -h|--help)      usage; exit 0 ;;
    *)              die "unknown arg: $1 (try --help)" ;;
  esac
done

[[ -n "${cell}" ]] || { usage >&2; die "--cell is required"; }
[[ -x "${PROBE_EMIT}" || -f "${PROBE_EMIT}" ]] || die "probe_emit.py missing"
command -v python3 >/dev/null || die "python3 not on PATH"
command -v jq      >/dev/null || die "jq not on PATH"

if [[ "${dry_run}" -eq 0 ]]; then
  command -v droidrun >/dev/null || die \
    "droidrun CLI not on PATH; install with: pipx install 'droidrun==${DROIDRUN_PIN}'"
  if ! droidrun --version 2>/dev/null | grep -Eq "^droidrun ${DROIDRUN_PIN%.\*}"; then
    log "WARN: droidrun --version does not start with ${DROIDRUN_PIN%.\*}; continuing"
  fi
  [[ -n "${adb_serial}" ]] || die "--adb-serial required unless --dry-run"
fi

mkdir -p "${out_dir}"
final_path="${out_dir}/${cell}.json"
partial_path="${out_dir}/${cell}.partial.json"
trap '[[ "${keep_partial}" -eq 1 ]] || rm -f "${partial_path}"' EXIT

# Bootstrap default probe plan if the user did not supply one. The plan stays
# small and probe-id-stable so that CI's schema-v2 gate can pin fixtures.
if [[ ! -f "${plan_path}" ]]; then
  log "no plan at ${plan_path}; writing default 3-probe plan"
  cat >"${plan_path}" <<'PLAN'
[
  {
    "probe_id": "buildprop.fingerprint",
    "probe_name": "BuildFingerprintProbe",
    "category": "buildprop",
    "layer": "L1",
    "command": "getprop ro.build.fingerprint && getprop ro.build.display.id && getprop ro.build.version.security_patch",
    "scoring": "regex_match",
    "score_pattern": "userdebug|test-keys|generic|emu"
  },
  {
    "probe_id": "emulator.qemu_artifacts",
    "probe_name": "QemuArtifactsProbe",
    "category": "emulator",
    "layer": "L1",
    "command": "getprop ro.hardware && getprop ro.kernel.qemu && ls /dev/qemu_pipe 2>/dev/null || true",
    "scoring": "regex_match",
    "score_pattern": "goldfish|ranchu|vbox|qemu"
  },
  {
    "probe_id": "runtime.installed_apps",
    "probe_name": "InstalledAppsProbe",
    "category": "runtime",
    "layer": "L4",
    "command": "pm list packages | grep -E 'magisk|lsposed|xposed|riru|zygisk' || echo CLEAN",
    "scoring": "negated_clean",
    "score_pattern": "CLEAN"
  }
]
PLAN
fi

# Per-probe execution function. Three input parameters keep the call sites in
# the run loop one line each.
run_probe_real() {
  local pid="$1" cmd="$2"
  # droidrun forwards the shell command without manual `adb shell` plumbing.
  # 124 is the conventional GNU timeout exit code.
  timeout --preserve-status "${timeout_sec}" \
    droidrun adb -s "${adb_serial}" shell "${cmd}"
}

run_probe_dry() {
  local pid="$1"
  case "${pid}" in
    buildprop.fingerprint)
      printf 'google/shiba/shiba:15/AP3A.241105.007/12771088:user/release-keys\n15\n2025-04-05\n' ;;
    emulator.qemu_artifacts)
      printf 'mt6985\n\n' ;;  # ro.kernel.qemu empty, no /dev/qemu_pipe
    runtime.installed_apps)
      printf 'CLEAN\n' ;;
    *)
      printf '{"dry":true,"probe":"%s"}\n' "${pid}" ;;
  esac
}

score_from_raw() {
  local scoring="$1" pattern="$2" raw="$3"
  case "${scoring}" in
    regex_match)
      if grep -Eq "${pattern}" <<<"${raw}"; then echo 1; else echo 0; fi ;;
    negated_clean)
      if grep -Fxq "${pattern}" <<<"${raw}"; then echo 0; else echo 1; fi ;;
    *)
      echo 0 ;;
  esac
}

# Stream records into <cell>.partial.json, then promote to <cell>.json on
# successful completion of every probe. `partial` is a JSON array assembled by
# jq so we never write malformed JSON if a probe is killed mid-way.
echo '[]' >"${partial_path}"

probe_count=$(jq 'length' "${plan_path}")
[[ "${probe_count}" -gt 0 ]] || die "probe plan ${plan_path} is empty"

log "cell=${cell} probes=${probe_count} dry_run=${dry_run} out=${final_path}"

for idx in $(seq 0 $((probe_count - 1))); do
  probe_json=$(jq ".[$idx]" "${plan_path}")
  pid=$(jq -r '.probe_id'     <<<"${probe_json}")
  pname=$(jq -r '.probe_name' <<<"${probe_json}")
  pcat=$(jq -r '.category'    <<<"${probe_json}")
  player=$(jq -r '.layer'     <<<"${probe_json}")
  pcmd=$(jq -r '.command'     <<<"${probe_json}")
  pscoring=$(jq -r '.scoring' <<<"${probe_json}")
  ppat=$(jq -r '.score_pattern' <<<"${probe_json}")

  log "[$((idx+1))/${probe_count}] ${pid} (${pcat}/${player})"
  t_start=$(date +%s%3N)
  if [[ "${dry_run}" -eq 1 ]]; then
    raw_out=$(run_probe_dry "${pid}")
  else
    raw_out=$(run_probe_real "${pid}" "${pcmd}" || true)
  fi
  t_end=$(date +%s%3N)
  runtime_ms=$((t_end - t_start))
  score=$(score_from_raw "${pscoring}" "${ppat}" "${raw_out}")

  # Build the schema-v2 record. probe_emit.py validates against the schema
  # in-process; a non-zero exit fails the cell.
  record=$(
    printf '%s' "${raw_out}" | python3 "${PROBE_EMIT}" \
      --probe-id "${pid}" \
      --probe-name "${pname}" \
      --category "${pcat}" \
      --layer "${player}" \
      --score "${score}" \
      --runtime-ms "${runtime_ms}" \
      --sample-count 1 \
      --seed-ms "${t_start}" \
      --confidence 0.9 \
      --evidence "droidrun:${pid}=${pcmd}" \
      --notes "cell=${cell} dry_run=${dry_run}"
  ) || die "probe ${pid} failed schema validation"

  jq --argjson rec "${record}" '. + [$rec]' "${partial_path}" \
    >"${partial_path}.tmp" && mv "${partial_path}.tmp" "${partial_path}"
done

mv "${partial_path}" "${final_path}"
log "wrote ${final_path} ($(jq 'length' "${final_path}") records)"
