#!/usr/bin/env bash
# test-redroid-bootstrap.sh
#
# Unit test for redroid-bootstrap.sh --dry-run path.
# Uses a mock `adb` shim in /tmp/mock-redroid so no real container is needed.
#
# Exit 0 on success, 1 on any assertion failure.

set -euo pipefail
umask 077

HERE="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="$HERE/redroid-bootstrap.sh"
MOCK_DIR="/tmp/mock-redroid"
FIXTURE_DIR="$MOCK_DIR/assets"

# --- setup --------------------------------------------------------------------
rm -rf "$MOCK_DIR"
mkdir -p "$MOCK_DIR/bin" "$FIXTURE_DIR"

# Mock adb: prints fake-but-consistent responses so the script's dry-run path
# never has to talk to real hardware.
cat >"$MOCK_DIR/bin/adb" <<'MOCKADB'
#!/usr/bin/env bash
# Mock adb for redroid-bootstrap.sh tests.
case "$*" in
  devices)
    printf 'List of devices attached\nemulator-5554\tdevice\n'
    ;;
  "-s emulator-5554 shell getprop ro.product.model")
    printf 'redroid\n'
    ;;
  *) printf '' ;;
esac
MOCKADB
chmod +x "$MOCK_DIR/bin/adb"

# Fake asset files so check_asset (real-mode) wouldn't trip if we run that path.
: >"$FIXTURE_DIR/magisk-v30.7.apk"
: >"$FIXTURE_DIR/NeoZygisk-v2.3.zip"
: >"$FIXTURE_DIR/Vector-v2.0.zip"

# --- assertions ---------------------------------------------------------------
PASS=0; FAIL=0
assert() {
  local desc="$1"; shift
  if "$@"; then PASS=$((PASS+1)); printf '  PASS  %s\n' "$desc"
  else FAIL=$((FAIL+1)); printf '  FAIL  %s\n' "$desc"
  fi
}

# Test 1: --dry-run with explicit container produces dry_run JSON and exit 0.
OUT=$(ADB_BIN="$MOCK_DIR/bin/adb" "$SCRIPT" --dry-run --container emulator-5554 \
  --magisk-zip "$FIXTURE_DIR/magisk-v30.7.apk" \
  --neozygisk-zip "$FIXTURE_DIR/NeoZygisk-v2.3.zip" \
  --vector-zip "$FIXTURE_DIR/Vector-v2.0.zip" 2>&1)
RC=$?
assert "dry-run exits 0" test "$RC" -eq 0
assert "dry-run emits status:dry_run" bash -c "printf '%s' \"\$1\" | grep -q '\"status\":\"dry_run\"'" _ "$OUT"
assert "dry-run prints adb push for magisk" bash -c "printf '%s' \"\$1\" | grep -q 'adb -s emulator-5554 push.*magisk'" _ "$OUT"
assert "dry-run prints adb push for NeoZygisk" bash -c "printf '%s' \"\$1\" | grep -q 'NeoZygisk-v2.3'" _ "$OUT"
assert "dry-run prints adb push for Vector" bash -c "printf '%s' \"\$1\" | grep -q 'Vector-v2.0'" _ "$OUT"
assert "dry-run mentions magisk --install-module" bash -c "printf '%s' \"\$1\" | grep -q 'magisk --install-module'" _ "$OUT"
assert "dry-run does NOT contain TrickyStore" bash -c "! printf '%s' \"\$1\" | grep -qi 'trickystore'" _ "$OUT"
assert "dry-run does NOT contain TEESimulator" bash -c "! printf '%s' \"\$1\" | grep -qi 'teesimulator'" _ "$OUT"

# Test 2: --dry-run auto-detects container via mock adb devices.
OUT2=$(ADB_BIN="$MOCK_DIR/bin/adb" "$SCRIPT" --dry-run \
  --magisk-zip "$FIXTURE_DIR/magisk-v30.7.apk" \
  --neozygisk-zip "$FIXTURE_DIR/NeoZygisk-v2.3.zip" \
  --vector-zip "$FIXTURE_DIR/Vector-v2.0.zip" 2>&1) || true
assert "auto-detect picks emulator-5554" bash -c "printf '%s' \"\$1\" | grep -q '\"container\":\"emulator-5554\"'" _ "$OUT2"

# Test 3: unknown argument fails with exit 2.
set +e
"$SCRIPT" --dry-run --container x --bogus-flag 2>/dev/null
RC3=$?
set -e
assert "unknown arg exits 2" test "$RC3" -eq 2

# Test 4: missing asset (non-dry-run) — should fail with exit 2 BEFORE adb call.
set +e
ADB_BIN="$MOCK_DIR/bin/adb" "$SCRIPT" --container emulator-5554 \
  --magisk-zip "$FIXTURE_DIR/does-not-exist.apk" 2>/dev/null
RC4=$?
set -e
assert "missing asset exits 2" test "$RC4" -eq 2

# Test 5: script has umask 077.
assert "umask 077 declared" grep -q "^umask 077" "$SCRIPT"

# Test 6: script ≤200 lines.
LINES=$(wc -l <"$SCRIPT")
assert "script ≤200 lines (actual: $LINES)" test "$LINES" -le 200

# Test 7: bash -n passes.
assert "bash -n passes" bash -n "$SCRIPT"

# --- summary ------------------------------------------------------------------
printf '\n  %d passed, %d failed\n' "$PASS" "$FAIL"
[[ "$FAIL" -eq 0 ]] || exit 1
exit 0
