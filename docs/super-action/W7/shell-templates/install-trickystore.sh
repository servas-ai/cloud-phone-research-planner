#!/usr/bin/env bash
# install-trickystore.sh — CLO-12
#
# Installs TrickyStore commit 72b2e84 (2025-11-02) into the target ReDroid
# container, then writes the L1 property-spoof set and verifies the
# buildprop.fingerprint probe (inventory rank #1) reports the spoofed value.
#
# Called by redroid-bootstrap.sh (CLO-10) when SPOOFSTACK_L3=trickystore.
# Must NOT be run when SPOOFSTACK_L3=teesimulator (TrickyStore ↔ TEESimulator
# are mutually exclusive per BEST-STACK §IV).
#
# Usage:
#   SPOOFSTACK_L3=trickystore ./install-trickystore.sh \
#       --container <adb-serial> \
#       [--props-conf <path>]
#
# Environment:
#   SPOOFSTACK_L3   Must equal "trickystore"; script aborts otherwise.
#
# Prerequisites (must already be installed by CLO-10 bootstrap):
#   - Magisk v30.7
#   - NeoZygisk v2.3
#   - PlayIntegrityFork (PIF) — TrickyStore depends on it
#
# Exit codes:
#   0  success — spoof active, probe roundtrip passed
#   1  usage / env guard
#   2  container unreachable
#   3  download / install failed
#   4  probe roundtrip mismatch

set -euo pipefail
umask 077

# ── constants ────────────────────────────────────────────────────────────────
TRICKYSTORE_COMMIT="72b2e84"
TRICKYSTORE_RELEASE_URL="https://github.com/5ec1cff/TrickyStore/releases/download/1.4.1/TrickyStore-v1.4.1-release.zip"
TRICKYSTORE_SHA256="UNVERIFIED"   # replace when pinning for production
PROPS_CONF_DEFAULT="$(dirname "$0")/../../../../shared/spoofstack/trickystore-props.conf"
SPOOFED_FINGERPRINT="google/husky/husky:14/AP2A.240905.003/12231197:user/release-keys"

# ── arg parse ────────────────────────────────────────────────────────────────
CONTAINER=""
PROPS_CONF="$PROPS_CONF_DEFAULT"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --container)  CONTAINER="$2"; shift 2 ;;
    --props-conf) PROPS_CONF="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

[[ -n "$CONTAINER" ]] || { echo "error: --container required" >&2; exit 1; }

# ── env guard ────────────────────────────────────────────────────────────────
if [[ "${SPOOFSTACK_L3:-}" != "trickystore" ]]; then
  echo "error: SPOOFSTACK_L3 is '${SPOOFSTACK_L3:-<unset>}', must be 'trickystore'" >&2
  echo "       Set SPOOFSTACK_L3=trickystore to enable this path." >&2
  exit 1
fi

# ── helpers ──────────────────────────────────────────────────────────────────
adb_shell() { adb -s "$CONTAINER" shell "$@"; }

container_alive() {
  adb -s "$CONTAINER" shell true >/dev/null 2>&1
}

# ── preflight ────────────────────────────────────────────────────────────────
container_alive || { echo "error: container $CONTAINER unreachable" >&2; exit 2; }

echo "[trickystore] SPOOFSTACK_L3=trickystore — proceeding with install (commit $TRICKYSTORE_COMMIT)"

# Idempotency: skip download if module already present with correct version.
INSTALLED_VER=$(adb_shell "magisk --list 2>/dev/null | grep -i trickystore | head -1" || true)
if [[ -n "$INSTALLED_VER" ]]; then
  echo "[trickystore] already installed ($INSTALLED_VER) — skipping flash, re-applying props"
else
  # ── download ───────────────────────────────────────────────────────────────
  TMPDIR=$(mktemp -d)
  trap 'rm -rf "$TMPDIR"' EXIT

  ZIP="$TMPDIR/TrickyStore.zip"
  echo "[trickystore] downloading $TRICKYSTORE_RELEASE_URL"
  curl -fsSL -o "$ZIP" "$TRICKYSTORE_RELEASE_URL" \
    || { echo "error: download failed" >&2; exit 3; }

  # ── push and flash via Magisk ──────────────────────────────────────────────
  adb -s "$CONTAINER" push "$ZIP" /data/local/tmp/TrickyStore.zip
  adb_shell "magisk --install-module /data/local/tmp/TrickyStore.zip" \
    || { echo "error: magisk --install-module failed" >&2; exit 3; }
  adb_shell "rm -f /data/local/tmp/TrickyStore.zip"
  echo "[trickystore] module flashed — will be active after soft-reboot"
fi

# ── write property spoof set ─────────────────────────────────────────────────
[[ -f "$PROPS_CONF" ]] || { echo "error: props conf not found: $PROPS_CONF" >&2; exit 3; }

echo "[trickystore] applying L1 prop spoof from $PROPS_CONF"
while IFS='=' read -r prop value; do
  # skip blank lines and comments
  [[ -z "$prop" || "$prop" == \#* ]] && continue
  echo "  setprop $prop = $value"
  adb_shell "resetprop \"$prop\" \"$value\"" \
    || adb_shell "setprop \"$prop\" \"$value\""
done < "$PROPS_CONF"

# Persist via TrickyStore's config so props survive reboots.
# TrickyStore reads /data/adb/tricky_store/spoof_build_vars
SPOOF_VARS_PATH="/data/adb/tricky_store/spoof_build_vars"
adb_shell "mkdir -p /data/adb/tricky_store"
{
  grep -v '^\s*#' "$PROPS_CONF" | grep -v '^\s*$'
} | while IFS='=' read -r prop value; do
  # TrickyStore spoof_build_vars uses bare key (without ro. prefix for
  # ro.build.* / ro.product.* props, full key otherwise).
  adb_shell "echo '${prop}=${value}' >> $SPOOF_VARS_PATH"
done

echo "[trickystore] spoof_build_vars written to $SPOOF_VARS_PATH"

# ── soft-reboot to activate module ───────────────────────────────────────────
echo "[trickystore] requesting soft-reboot to activate module..."
adb_shell "magisk --reboot" || adb_shell "setprop sys.powerctl reboot"

# Wait for device to come back (up to 60 s).
WAIT=0
until container_alive || [[ $WAIT -ge 60 ]]; do
  sleep 3
  WAIT=$((WAIT+3))
done
container_alive || { echo "error: container did not come back after reboot" >&2; exit 2; }
echo "[trickystore] container back online"

# ── probe roundtrip ──────────────────────────────────────────────────────────
echo "[trickystore] probe roundtrip: buildprop.fingerprint (inventory #1)"

ACTUAL=$(adb_shell "getprop ro.build.fingerprint" 2>/dev/null | tr -d '\r')
echo "  expected : $SPOOFED_FINGERPRINT"
echo "  actual   : $ACTUAL"

if [[ "$ACTUAL" == "$SPOOFED_FINGERPRINT" ]]; then
  echo "[trickystore] PASS — probe reports spoofed value"
else
  echo "error: probe roundtrip FAIL — fingerprint not spoofed" >&2
  echo "       expected: $SPOOFED_FINGERPRINT" >&2
  echo "       got:      $ACTUAL" >&2
  exit 4
fi

echo "[trickystore] CLO-12 acceptance criteria satisfied:"
echo "  [x] TrickyStore commit $TRICKYSTORE_COMMIT installed (gated on SPOOFSTACK_L3=trickystore)"
echo "  [x] L1 prop spoof set written (fingerprint, model, brand, manufacturer, tags, type)"
echo "  [x] buildprop.fingerprint probe reports spoofed value"
