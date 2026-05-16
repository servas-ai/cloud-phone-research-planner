#!/usr/bin/env bash
# bootstrap.sh — Stability Agent container bootstrap
# CLO-14: detects x86_64 host, warns, and downgrades libhoudini severity.
# On ARM64: proceeds normally with full severity ratings.
# On x86_64: proceeds (dev-parity), sets arch_penalty=true in the report.

umask 077
set -euo pipefail

RUN_ID="${PAPERCLIP_RUN_ID:-local-$(date +%s)}"
CONFIG_ID="${CONFIG_ID:-unknown}"
REPORT_DIR="${REPORT_DIR:-reports/stability}"
REPORT_FILE="${REPORT_DIR}/${RUN_ID}.json"

mkdir -p "$REPORT_DIR"

HOST_ARCH=$(uname -m)
ARCH_PENALTY=false
HOST_ARCH_WARNING=false

if [[ "$HOST_ARCH" == "x86_64" || "$HOST_ARCH" == "amd64" ]]; then
  HOST_ARCH_WARNING=true
  ARCH_PENALTY=true

  echo "" >&2
  echo "┌──────────────────────────────────────────────────────────────────┐" >&2
  echo "│  WARNING: x86_64 host detected (CLO-14)                         │" >&2
  echo "│                                                                  │" >&2
  echo "│  ReDroid L0a requires an ARM64 host. On x86_64, libhoudini      │" >&2
  echo "│  translates ARM64 guest instructions and leaks host x86 cap     │" >&2
  echo "│  bits through /proc/cpuinfo (Hard-ceiling #9).                  │" >&2
  echo "│                                                                  │" >&2
  echo "│  Tier-3 libhoudini findings will be recorded as INFO (not HIGH) │" >&2
  echo "│  in the stability report. Run still proceeds for dev parity.    │" >&2
  echo "│                                                                  │" >&2
  echo "│  Use an ARM64 host in CI. See docs/super-action/W7/README.md    │" >&2
  echo "└──────────────────────────────────────────────────────────────────┘" >&2
  echo "" >&2
fi

# Write initial report skeleton. The health-poll loop updates this file.
cat > "$REPORT_FILE" <<EOF
{
  "run_id": "${RUN_ID}",
  "config_id": "${CONFIG_ID}",
  "host_arch": "${HOST_ARCH}",
  "host_arch_warning": ${HOST_ARCH_WARNING},
  "arch_penalty": ${ARCH_PENALTY},
  "container_id": null,
  "layer_set": [],
  "uptime_seconds": 0.0,
  "oom_kills": 0,
  "module_failures": [],
  "healthy": false,
  "note": "libhoudini Tier-3 severity downgraded to INFO when arch_penalty=true (CLO-14)"
}
EOF

echo "[bootstrap] run_id=${RUN_ID} host_arch=${HOST_ARCH} arch_penalty=${ARCH_PENALTY}"
echo "[bootstrap] report: ${REPORT_FILE}"
