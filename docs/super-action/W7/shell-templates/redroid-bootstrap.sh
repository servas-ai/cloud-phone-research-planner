#!/usr/bin/env bash
# redroid-bootstrap.sh — bootstrap Magisk v30.7 + NeoZygisk v2.3 + Vector v2.0
# in a ReDroid 12.0.0-64only-240527 container. Idempotent.
#
# Pinned versions: docs/super-action/W1/BEST-STACK-v2.md §II.
# Mutual exclusion (BEST-STACK §IV): installs NEITHER TrickyStore NOR
# TEESimulator — Issue 11 selects exactly one.
#
# Usage: redroid-bootstrap.sh [--container <serial>] [--magisk-zip <path>]
#        [--neozygisk-zip <path>] [--vector-zip <path>]
#        [--skip-assert] [--dry-run]
#
# Exit: 0 ok/dry-run · 1 assert fail · 2 bad args · 3 adb unreachable
#       4 push/install fail · 5 module enable fail

set -euo pipefail
umask 077

CONTAINER=""
MAGISK_ZIP="assets/magisk-v30.7.apk"
NEOZYGISK_ZIP="assets/NeoZygisk-v2.3.zip"
VECTOR_ZIP="assets/Vector-v2.0.zip"
SKIP_ASSERT=false
DRY_RUN=false

emit_error() { printf '{"status":"failed","error":"%s"}\n' "$1" >&2; }
adb_bin() { "${ADB_BIN:-adb}" "$@"; }

adb_shell() {
  if [[ "$DRY_RUN" == "true" ]]; then
    printf '+ adb -s %s shell %s\n' "$CONTAINER" "$*"
  else
    adb_bin -s "$CONTAINER" shell "$@"
  fi
}

adb_push() {
  if [[ "$DRY_RUN" == "true" ]]; then
    printf '+ adb -s %s push %s %s\n' "$CONTAINER" "$1" "$2"
  else
    adb_bin -s "$CONTAINER" push "$1" "$2" >/dev/null
  fi
}

adb_run() {
  if [[ "$DRY_RUN" == "true" ]]; then
    printf '+ adb -s %s %s\n' "$CONTAINER" "$*"
  else
    adb_bin -s "$CONTAINER" "$@"
  fi
}

check_asset() {
  [[ "$DRY_RUN" == "true" ]] && return 0
  [[ -f "$1" ]] || { emit_error "asset_not_found: $2 ($1)"; exit 2; }
}

auto_detect_container() {
  local devices d
  devices=$(adb_bin devices 2>/dev/null | awk 'NR>1 && $2=="device" {print $1}')
  for d in $devices; do
    if adb_bin -s "$d" shell getprop ro.product.model 2>/dev/null | grep -qi "redroid"; then
      printf '%s' "$d"; return 0
    fi
  done
  printf '%s' "$(printf '%s\n' "$devices" | head -n1)"
}

wait_for_boot() {
  [[ "$DRY_RUN" == "true" ]] && { printf '+ wait_for_boot\n'; return 0; }
  local max=120 elapsed=0
  while ! adb_bin -s "$CONTAINER" shell getprop sys.boot_completed 2>/dev/null | grep -q 1; do
    sleep 2; elapsed=$((elapsed+2))
    [[ $elapsed -lt $max ]] || { emit_error "timeout_waiting_for_boot"; exit 4; }
  done
  sleep 5
}

push_and_install_module() {
  local zip_path="$1" name="$2" remote="/data/local/tmp/$2.zip"
  adb_push "$zip_path" "$remote" || { emit_error "push_failed: $name"; exit 4; }
  adb_shell "magisk --install-module '$remote'" || { emit_error "module_install_failed: $name"; exit 4; }
  adb_shell "rm -f '$remote'" || true
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --container)     CONTAINER="$2";     shift 2 ;;
    --magisk-zip)    MAGISK_ZIP="$2";    shift 2 ;;
    --neozygisk-zip) NEOZYGISK_ZIP="$2"; shift 2 ;;
    --vector-zip)    VECTOR_ZIP="$2";    shift 2 ;;
    --skip-assert)   SKIP_ASSERT=true;   shift   ;;
    --dry-run)       DRY_RUN=true;       shift   ;;
    *) emit_error "unknown_argument: $1"; exit 2 ;;
  esac
done

[[ -z "$CONTAINER" ]] && CONTAINER=$(auto_detect_container || true)
[[ -n "$CONTAINER" ]] || { emit_error "no_running_redroid_container"; exit 3; }

check_asset "$MAGISK_ZIP"    "magisk-zip"
check_asset "$NEOZYGISK_ZIP" "neozygisk-zip"
check_asset "$VECTOR_ZIP"    "vector-zip"

if [[ "$DRY_RUN" != "true" ]]; then
  adb_bin -s "$CONTAINER" shell true >/dev/null 2>&1 \
    || { emit_error "container_unreachable: $CONTAINER"; exit 3; }
fi

SKIPPED=()

# Step 1 — Magisk v30.7
if [[ "$DRY_RUN" == "true" ]]; then INSTALLED_MAGISK=""; else
  INSTALLED_MAGISK=$(adb_bin -s "$CONTAINER" shell "magisk --version 2>/dev/null || true" | tr -d '[:space:]')
fi
if [[ "$INSTALLED_MAGISK" =~ ^30[7-9][0-9]{2} ]] || [[ "$INSTALLED_MAGISK" =~ ^3[1-9][0-9]{3} ]]; then
  SKIPPED+=("magisk_install")
else
  adb_push "$MAGISK_ZIP" /data/local/tmp/magisk.apk
  adb_run install -r /data/local/tmp/magisk.apk
  adb_shell "magisk --install-module /data/local/tmp/magisk.apk || true"
  adb_run reboot
  wait_for_boot
fi

# Step 2 — NeoZygisk v2.3
if [[ "$DRY_RUN" == "true" ]]; then NEOZYGISK_STATUS=""; else
  NEOZYGISK_STATUS=$(adb_bin -s "$CONTAINER" shell "cmd zygisk status 2>/dev/null || true")
fi
if printf '%s' "$NEOZYGISK_STATUS" | grep -qi "NeoZygisk"; then
  SKIPPED+=("neozygisk_install")
else
  adb_shell "magisk --sqlite 'UPDATE settings SET value=0 WHERE key=\"zygisk\"' || true"
  push_and_install_module "$NEOZYGISK_ZIP" "NeoZygisk-v2.3"
  adb_run reboot
  wait_for_boot
fi

# Step 3 — Vector v2.0 (LSPosed fork)
if [[ "$DRY_RUN" == "true" ]]; then VECTOR_PRESENT=""; else
  VECTOR_PRESENT=$(adb_bin -s "$CONTAINER" shell "cmd package list packages 2>/dev/null | grep -c org.lsposed.manager || true" | tr -d '[:space:]')
fi
if [[ "$VECTOR_PRESENT" =~ ^[1-9] ]]; then
  SKIPPED+=("vector_install")
else
  push_and_install_module "$VECTOR_ZIP" "Vector-v2.0"
  adb_shell "magisk --sqlite 'INSERT OR IGNORE INTO modules(id,update,remove,disable) VALUES(\"vector\",0,0,0); UPDATE modules SET disable=0 WHERE id=\"vector\"'" \
    || { emit_error "vector_enable_failed"; exit 5; }
  adb_run reboot
  wait_for_boot
fi

# Assertions
if [[ "$SKIP_ASSERT" == "false" && "$DRY_RUN" == "false" ]]; then
  MAGISK_VER=$(adb_bin -s "$CONTAINER" shell "magisk --version 2>/dev/null" | tr -d '[:space:]')
  MAGISK_INT="${MAGISK_VER//[^0-9]/}"
  [[ -n "$MAGISK_INT" && "$MAGISK_INT" -ge 30700 ]] \
    || { emit_error "assertion_failed: magisk_version=$MAGISK_VER < 30700"; exit 1; }
  adb_bin -s "$CONTAINER" shell "cmd zygisk status 2>/dev/null" | grep -qi "running" \
    || { emit_error "assertion_failed: cmd_zygisk_status not running"; exit 1; }
  adb_bin -s "$CONTAINER" shell "cmd package list packages 2>/dev/null" | grep -q "org.lsposed.manager" \
    || { emit_error "assertion_failed: org.lsposed.manager not installed"; exit 1; }
fi

# Emit result
if [[ "$DRY_RUN" == "true" ]]; then
  printf '{"status":"dry_run","container":"%s","skipped_steps":[],"error":null}\n' "$CONTAINER"
  exit 0
fi

MAGISK_VER_FINAL=$(adb_bin -s "$CONTAINER" shell "magisk --version 2>/dev/null" | tr -d '[:space:]')
NEOZYGISK_ACTIVE=$(adb_bin -s "$CONTAINER" shell "cmd zygisk status 2>/dev/null" | grep -qi "running" && echo true || echo false)
VECTOR_EN=$(adb_bin -s "$CONTAINER" shell "cmd package list packages 2>/dev/null" | grep -qi "org.lsposed.manager" && echo true || echo false)

STATUS="done"
[[ ${#SKIPPED[@]} -eq 3 ]] && STATUS="already_primed"

SKIPPED_JSON="[]"
[[ ${#SKIPPED[@]} -gt 0 ]] && SKIPPED_JSON=$(printf '"%s",' "${SKIPPED[@]}" | sed 's/,$//' | awk '{print "["$0"]"}')

printf '{"status":"%s","magisk_version":"%s","neozygisk_active":%s,"vector_enabled":%s,"skipped_steps":%s,"error":null}\n' \
  "$STATUS" "$MAGISK_VER_FINAL" "$NEOZYGISK_ACTIVE" "$VECTOR_EN" "$SKIPPED_JSON"
