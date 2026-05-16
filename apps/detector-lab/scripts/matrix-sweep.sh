#!/usr/bin/env bash
# matrix-sweep.sh — CLO-13 baseline-matrix cell sweep driver.
#
# Enumerates all 9 cells (Pixel 8 / 9 / 9 Pro × Android 14 / 15 / 16),
# invokes droidrun-cell.sh for each with the full probe battery
# (W3 probes + Issues 01-08 + freeRASP v18.0.4 + playIntegrityFixDetector
# v2.2 + GrapheneOS Auditor verdicts), and writes JSON to
# apps/detector-lab/out/matrix/<cell>.json.
#
# Wall-clock budgets:
#   - Per-cell hard ceiling: 12 min (720 s)
#   - Total sweep ceiling: 2 h (7200 s)
#
# Usage (CI / dry-run):
#   matrix-sweep.sh --dry-run
#
# Usage (live, Paris box — adb serials mapped in CELL_SERIAL below):
#   matrix-sweep.sh
#
# Individual ADB serial overrides:
#   CELL_SERIAL_pixel8_a14=emulator-5554 matrix-sweep.sh
#
# Exit codes:
#   0  all 9 cells succeeded
#   1  one or more cells failed (cell.json still written for succeeded cells)
#   2  total wall-clock budget exceeded

set -uo pipefail
umask 077

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly LAB_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
readonly REPO_ROOT="$(cd -- "${LAB_DIR}/../.." && pwd)"
readonly CELL_SCRIPT="${SCRIPT_DIR}/droidrun-cell.sh"
readonly FULL_PLAN="${SCRIPT_DIR}/probe-plan-full.json"
readonly OUT_DIR="${LAB_DIR}/out/matrix"
readonly MATRIX_LOG="${OUT_DIR}/sweep.log"

readonly CELL_TIMEOUT_SEC=720   # 12 min per cell
readonly SWEEP_TIMEOUT_SEC=7200 # 2 h total

# 9-cell matrix: (device)-(android-version)
readonly CELLS=(
  pixel8-a14
  pixel8-a15
  pixel8-a16
  pixel9-a14
  pixel9-a15
  pixel9-a16
  pixel9pro-a14
  pixel9pro-a15
  pixel9pro-a16
)

dry_run=0
verbose=0
parallel=0
cells_filter=()
out_dir="${OUT_DIR}"
keep_partial=0
extra_args=()

log()  { printf '[matrix-sweep] %s\n' "$*" >&2; }
logf() { printf "[matrix-sweep] $1\n" "${@:2}" >&2; }
die()  { printf '[matrix-sweep] FATAL: %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Usage: matrix-sweep.sh [options]

Sweeps all 9 baseline-matrix cells and writes JSON to
apps/detector-lab/out/matrix/<cell>.json.

Options:
  --dry-run            Bypass droidrun; use canned probe output (CI mode).
  --cell <id>          Run only the specified cell id (repeatable).
                       Default: all 9 cells.
  --out-dir <path>     Override output directory.
  --plan <path>        Override probe plan JSON.
                       Default: scripts/probe-plan-full.json.
  --parallel           Run cells in parallel (use with caution on real hw).
  --keep-partial       Preserve .partial.json on probe failure.
  --verbose            Print per-cell droidrun-cell.sh output to stderr.
  -h, --help           This message.

Cell ids:
  pixel8-a14   pixel8-a15   pixel8-a16
  pixel9-a14   pixel9-a15   pixel9-a16
  pixel9pro-a14  pixel9pro-a15  pixel9pro-a16

ADB serial mapping (live mode):
  Set CELL_SERIAL_<cell_id_with_dashes_as_underscores> to override per cell.
  E.g. CELL_SERIAL_pixel8_a15=emulator-5554 matrix-sweep.sh
  Or set CELL_SERIAL_DEFAULT for a single-device run.

Exit codes:
  0  All cells succeeded.
  1  One or more cells failed.
  2  Total wall-clock budget (2 h) exceeded.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)      dry_run=1;               shift ;;
    --parallel)     parallel=1;              shift ;;
    --verbose)      verbose=1;               shift ;;
    --keep-partial) keep_partial=1;          shift ;;
    --cell)         cells_filter+=("$2");    shift 2 ;;
    --out-dir)      out_dir="$2";            shift 2 ;;
    --plan)         FULL_PLAN_OVERRIDE="$2"; shift 2 ;;
    -h|--help)      usage; exit 0 ;;
    *)              die "unknown arg: $1 (try --help)" ;;
  esac
done

plan_path="${FULL_PLAN_OVERRIDE:-${FULL_PLAN}}"

[[ -f "${CELL_SCRIPT}" ]]  || die "droidrun-cell.sh not found at ${CELL_SCRIPT}"
[[ -f "${plan_path}" ]]    || die "probe plan not found at ${plan_path}"
command -v jq >/dev/null   || die "jq not on PATH"
command -v python3 >/dev/null || die "python3 not on PATH"

if [[ "${dry_run}" -eq 0 ]]; then
  command -v droidrun >/dev/null || die \
    "droidrun CLI not on PATH; install with: pipx install 'droidrun==0.4.*'"
fi

# Apply cell filter if specified.
cells_to_run=()
if [[ ${#cells_filter[@]} -gt 0 ]]; then
  for c in "${cells_filter[@]}"; do
    found=0
    for known in "${CELLS[@]}"; do
      [[ "${known}" == "${c}" ]] && found=1 && break
    done
    [[ "${found}" -eq 1 ]] || die "unknown cell id: ${c}. Known: ${CELLS[*]}"
    cells_to_run+=("${c}")
  done
else
  cells_to_run=("${CELLS[@]}")
fi

mkdir -p "${out_dir}"

# Build the per-cell adb serial lookup.
# Env var naming: CELL_SERIAL_pixel8_a15 (dashes become underscores).
cell_serial() {
  local cell="$1"
  local varname="CELL_SERIAL_${cell//-/_}"
  # Indirect variable expansion without eval.
  local serial="${!varname:-}"
  if [[ -z "${serial}" ]]; then
    serial="${CELL_SERIAL_DEFAULT:-}"
  fi
  printf '%s' "${serial}"
}

# Run a single cell; called both in sequential and parallel mode.
run_cell() {
  local cell="$1"
  local cell_start
  cell_start=$(date +%s)

  local args=(
    --cell "${cell}"
    --plan "${plan_path}"
    --out-dir "${out_dir}"
    --timeout "${CELL_TIMEOUT_SEC}"
  )
  [[ "${dry_run}"      -eq 1 ]] && args+=(--dry-run)
  [[ "${keep_partial}" -eq 1 ]] && args+=(--keep-partial)

  if [[ "${dry_run}" -eq 0 ]]; then
    local serial
    serial=$(cell_serial "${cell}")
    [[ -n "${serial}" ]] || {
      log "SKIP ${cell}: no ADB serial (set CELL_SERIAL_${cell//-/_} or CELL_SERIAL_DEFAULT)"
      return 1
    }
    args+=(--adb-serial "${serial}")
  fi

  log "START cell=${cell}"
  local cell_out
  # Timeout wrapper honours CELL_TIMEOUT_SEC at the OS level even if
  # droidrun-cell.sh's inner per-probe timeout misfires.
  if [[ "${verbose}" -eq 1 ]]; then
    timeout --kill-after=10 "${CELL_TIMEOUT_SEC}" \
      bash "${CELL_SCRIPT}" "${args[@]}"
    local rc=$?
  else
    cell_out=$(timeout --kill-after=10 "${CELL_TIMEOUT_SEC}" \
      bash "${CELL_SCRIPT}" "${args[@]}" 2>&1)
    local rc=$?
    [[ "${rc}" -ne 0 ]] && log "FAIL cell=${cell} rc=${rc}"$'\n'"${cell_out}"
  fi

  local cell_end
  cell_end=$(date +%s)
  local elapsed=$(( cell_end - cell_start ))

  if [[ "${rc}" -eq 0 ]]; then
    local records
    records=$(jq 'length' "${out_dir}/${cell}.json" 2>/dev/null || echo "?")
    logf "DONE  cell=%-14s elapsed=%3ds probes=%s" "${cell}" "${elapsed}" "${records}"
  elif [[ "${rc}" -eq 124 ]]; then
    logf "TIMEOUT cell=%s elapsed=%ds (limit %ds)" "${cell}" "${elapsed}" "${CELL_TIMEOUT_SEC}"
  else
    logf "FAIL  cell=%-14s rc=%d elapsed=%ds" "${cell}" "${rc}" "${elapsed}"
  fi
  return "${rc}"
}

# ── Main sweep ───────────────────────────────────────────────────────────────

sweep_start=$(date +%s)
log "matrix-sweep start cells=${#cells_to_run[@]} dry_run=${dry_run} plan=${plan_path}"
log "output dir: ${out_dir}"

# Write sweep manifest so partial results are attributable.
manifest_path="${out_dir}/sweep-manifest.json"
jq -n \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --argjson cells "$(printf '%s\n' "${cells_to_run[@]}" | jq -R . | jq -s .)" \
  --arg plan "${plan_path}" \
  --arg dry_run "${dry_run}" \
  '{started_at:$ts, cells:$cells, plan:$plan, dry_run:($dry_run=="1")}' \
  >"${manifest_path}"

failed_cells=()
pids=()
declare -A cell_pid_map

if [[ "${parallel}" -eq 1 ]]; then
  # Parallel mode: launch all cells as background jobs, then wait.
  log "running ${#cells_to_run[@]} cells in parallel"
  for cell in "${cells_to_run[@]}"; do
    run_cell "${cell}" &
    cell_pid_map["${cell}"]=$!
  done
  for cell in "${cells_to_run[@]}"; do
    wait "${cell_pid_map[${cell}]}" || failed_cells+=("${cell}")
  done
else
  # Sequential mode: abort early if total budget is exceeded.
  for cell in "${cells_to_run[@]}"; do
    now=$(date +%s)
    elapsed_total=$(( now - sweep_start ))
    if [[ "${elapsed_total}" -ge "${SWEEP_TIMEOUT_SEC}" ]]; then
      log "ABORT: total sweep budget (${SWEEP_TIMEOUT_SEC}s) exceeded after ${elapsed_total}s"
      # Mark remaining cells as failed.
      remaining=0
      for c in "${cells_to_run[@]}"; do
        [[ "${c}" == "${cell}" ]] && remaining=1
        [[ "${remaining}" -eq 1 ]] && failed_cells+=("${c}")
      done
      break
    fi

    run_cell "${cell}" || failed_cells+=("${cell}")
  done
fi

sweep_end=$(date +%s)
sweep_elapsed=$(( sweep_end - sweep_start ))

# Update manifest with results.
succeeded=$(( ${#cells_to_run[@]} - ${#failed_cells[@]} ))
jq \
  --arg finished_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --argjson elapsed "${sweep_elapsed}" \
  --argjson succeeded "${succeeded}" \
  --argjson total "${#cells_to_run[@]}" \
  --argjson failed "$(printf '%s\n' "${failed_cells[@]:-}" | jq -R . | jq -s .)" \
  '. + {finished_at:$finished_at, elapsed_sec:$elapsed, succeeded:$succeeded,
         total:$total, failed:$failed}' \
  "${manifest_path}" >"${manifest_path}.tmp" && mv "${manifest_path}.tmp" "${manifest_path}"

log "sweep complete: ${succeeded}/${#cells_to_run[@]} cells OK in ${sweep_elapsed}s"
[[ ${#failed_cells[@]} -gt 0 ]] && log "failed cells: ${failed_cells[*]}"

if [[ "${sweep_elapsed}" -ge "${SWEEP_TIMEOUT_SEC}" ]]; then
  exit 2
elif [[ ${#failed_cells[@]} -gt 0 ]]; then
  exit 1
fi
exit 0
