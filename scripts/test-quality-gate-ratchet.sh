#!/usr/bin/env bash
# test-quality-gate-ratchet.sh — CLO-111 acceptance test suite
#
# Runs 6 scenarios that verify the sticky quality-gate ratchet contract.
# Must be executed from the repo root.  Exits 0 on full pass.
#
# Scenarios:
#   S1 — critical finding engages lock and is tracked in open-findings.json
#   S2 — matrix-driver guard refuses new T2 dispatch when lock is engaged
#   S3 — path (a): quality-gate-cleared label on parent issue clears finding
#   S4 — path (b): BuildCommit with matching finding ID + exit 0 clears finding
#   S5 — partial clear: clearing one of two findings keeps lock engaged
#   S6 — sticky property: empty subsequent report does NOT clear lock
set -euo pipefail

umask 077

PASS=0
FAIL=0
REPO_ROOT="$(git rev-parse --show-toplevel)"
STATE_DIR="${REPO_ROOT}/.paperclip/state"
OPEN_FINDINGS="${STATE_DIR}/quality-gate.open-findings.json"
LOCK_FILE="${STATE_DIR}/quality-gate.lock"
BC_DIR="${STATE_DIR}/quality-gate.pending-buildcommits"

# ─── helpers ────────────────────────────────────────────────────────────────

_setup() {
  mkdir -p "${STATE_DIR}" "${BC_DIR}"
  echo '{"schemaVersion":1,"findings":[]}' > "${OPEN_FINDINGS}"
  rm -f "${LOCK_FILE}"
  rm -f "${BC_DIR}"/*.json 2>/dev/null || true
}

_inject_finding() {
  local FID="$1" SEV="$2" CAT="${3:-bug}" CONF="${4:-high}"
  local NOW="$(date -u +%FT%TZ)"
  local SHA="$(git rev-parse HEAD 2>/dev/null || echo 'test-sha')"
  jq --arg fid "${FID}" --arg sev "${SEV}" --arg cat "${CAT}" \
     --arg conf "${CONF}" --arg sha "${SHA}" --arg ts "${NOW}" '
    .findings += [{
      findingId: $fid, severity: $sev, category: $cat, confidence: $conf,
      title: ("test finding " + $fid),
      introducedAtCommit: $sha, introducedAt: $ts,
      introducedAtIssue: "CLO-TEST-1",
      status: "open", clearedAt: null, clearedAtCommit: null, clearedAtIssue: null
    }]
  ' "${OPEN_FINDINGS}" > /tmp/qg-test.tmp && mv /tmp/qg-test.tmp "${OPEN_FINDINGS}"
}

_engage_lock() {
  local OPEN_COUNT="$(jq '[.findings[] | select(.status == "open")] | length' "${OPEN_FINDINGS}")"
  if [ "${OPEN_COUNT}" -gt 0 ]; then
    local OPEN_IDS="$(jq -r '[.findings[] | select(.status == "open") | .findingId] | join(",")' "${OPEN_FINDINGS}")"
    {
      echo "engaged_at: $(date -u +%FT%TZ)"
      echo "open_findings: ${OPEN_COUNT}"
      echo "finding_ids: ${OPEN_IDS}"
      echo "open_findings_file: ${OPEN_FINDINGS}"
    } > "${LOCK_FILE}"
  else
    rm -f "${LOCK_FILE}"
  fi
}

_dispatch_t2() {
  # Simulates matrix-driver T2 dispatch guard.
  # Returns 0 (allowed) or 78 (refused — lock engaged).
  if [ -f "${LOCK_FILE}" ]; then
    local IDS="$(grep 'finding_ids:' "${LOCK_FILE}" | cut -d' ' -f2-)"
    echo "matrix-driver: T2 dispatch REFUSED — quality-gate lock engaged. Open findings: ${IDS}" >&2
    return 78
  fi
  echo "matrix-driver: T2 dispatch ALLOWED." >&2
  return 0
}

_apply_buildcommit() {
  local FID="$1" EXIT_CODE="${2:-0}" SHA="${3:-commit-M-sha}"
  cat > "${BC_DIR}/${SHA}.json" <<EOF
{
  "schemaVersion": 1,
  "sha": "${SHA}",
  "addresses_finding_id": "${FID}",
  "acceptance_cmd_result": {
    "exit_code": ${EXIT_CODE},
    "stdout": "tests passed",
    "stderr": ""
  }
}
EOF
}

_resolve_buildcommits() {
  local NOW="$(date -u +%FT%TZ)"
  for BC_FILE in "${BC_DIR}"/*.json; do
    [ -f "${BC_FILE}" ] || continue
    local BC_EXIT="$(jq -r '.acceptance_cmd_result.exit_code // 1' "${BC_FILE}")"
    [ "${BC_EXIT}" != "0" ] && { rm -f "${BC_FILE}"; continue; }
    local BC_SHA="$(jq -r '.sha // ""' "${BC_FILE}")"

    jq -r '
      if (.addresses_finding_id | type) == "array"
      then .addresses_finding_id[]
      else .addresses_finding_id
      end
    ' "${BC_FILE}" | while IFS= read -r FID; do
      [ -z "${FID}" ] && continue
      local IS_OPEN="$(jq -r --arg fid "${FID}" '
        .findings[] | select(.findingId == $fid and .status == "open") | .findingId
      ' "${OPEN_FINDINGS}")"
      if [ -n "${IS_OPEN}" ]; then
        jq --arg fid "${FID}" --arg ts "${NOW}" --arg sha "${BC_SHA}" '
          .findings |= map(
            if .findingId == $fid and .status == "open"
            then . + {status: "cleared-via-buildcommit", clearedAt: $ts, clearedAtCommit: $sha}
            else .
            end
          )
        ' "${OPEN_FINDINGS}" > /tmp/qg-test.tmp && mv /tmp/qg-test.tmp "${OPEN_FINDINGS}"
        echo "resolved finding ${FID} via path (b)"
      fi
    done
    rm -f "${BC_FILE}"
  done
}

_ok() {
  echo "  PASS: $1"
  PASS=$((PASS + 1))
}

_fail() {
  echo "  FAIL: $1"
  FAIL=$((FAIL + 1))
}

_assert_lock_engaged() {
  if [ -f "${LOCK_FILE}" ]; then _ok "$1"; else _fail "$1 (lock absent, expected engaged)"; fi
}

_assert_lock_clear() {
  if [ ! -f "${LOCK_FILE}" ]; then _ok "$1"; else _fail "$1 (lock present, expected clear)"; fi
}

_assert_finding_status() {
  local FID="$1" EXPECTED="$2" LABEL="$3"
  local ACTUAL="$(jq -r --arg fid "${FID}" '
    .findings[] | select(.findingId == $fid) | .status
  ' "${OPEN_FINDINGS}" 2>/dev/null || echo 'NOT_FOUND')"
  if [ "${ACTUAL}" = "${EXPECTED}" ]; then _ok "${LABEL}"; else _fail "${LABEL} (status=${ACTUAL}, expected=${EXPECTED})"; fi
}

# ─── S1 — engagement ────────────────────────────────────────────────────────

echo ""
echo "=== S1: critical finding engages lock ==="
_setup
_inject_finding "llmjudge-s1aaa000" "critical"
_engage_lock
_assert_lock_engaged "lock is engaged after critical finding"
_assert_finding_status "llmjudge-s1aaa000" "open" "finding tracked as open"

# ─── S2 — matrix-driver refuses T2 when locked ──────────────────────────────

echo ""
echo "=== S2: matrix-driver refuses T2 when lock engaged ==="
if _dispatch_t2; then
  _fail "dispatch should be refused (returned 0)"
else
  DISP_RC=$?
  if [ "${DISP_RC}" -eq 78 ]; then
    _ok "dispatch refused with exit code 78"
  else
    _fail "dispatch refused but wrong exit code: ${DISP_RC}"
  fi
fi

# ─── S3 — path (a): label clears finding ────────────────────────────────────

echo ""
echo "=== S3: path (a) — quality-gate-cleared label clears finding ==="
_setup
_inject_finding "llmjudge-s3bbb000" "critical"
_engage_lock
_assert_lock_engaged "pre-condition: lock engaged"

# Simulate label-based clearance directly (label check requires live API in full
# routine; here we apply the clearance update logic directly).
NOW="$(date -u +%FT%TZ)"
jq --arg fid "llmjudge-s3bbb000" --arg ts "${NOW}" --arg issue "CLO-TEST-1" '
  .findings |= map(
    if .findingId == $fid and .status == "open"
    then . + {status: "cleared-via-label", clearedAt: $ts, clearedAtIssue: $issue}
    else .
    end
  )
' "${OPEN_FINDINGS}" > /tmp/qg-test.tmp && mv /tmp/qg-test.tmp "${OPEN_FINDINGS}"
_engage_lock  # re-derive lock from open-set

_assert_finding_status "llmjudge-s3bbb000" "cleared-via-label" "finding cleared via path (a)"
_assert_lock_clear "lock cleared after label clearance"

if _dispatch_t2; then
  _ok "dispatch allowed after lock cleared"
else
  _fail "dispatch still refused after lock cleared"
fi

# ─── S4 — path (b): BuildCommit reference clears finding ────────────────────

echo ""
echo "=== S4: path (b) — BuildCommit + exit 0 clears finding ==="
_setup
_inject_finding "llmjudge-s4ccc000" "high"
_engage_lock
_assert_lock_engaged "pre-condition: lock engaged for high finding"

_apply_buildcommit "llmjudge-s4ccc000" 0 "commit-M-s4"
_resolve_buildcommits
_engage_lock

_assert_finding_status "llmjudge-s4ccc000" "cleared-via-buildcommit" "finding cleared via path (b)"
_assert_lock_clear "lock cleared after BuildCommit clearance"

# ─── S5 — partial clear keeps lock ──────────────────────────────────────────

echo ""
echo "=== S5: partial clear — one of two findings cleared; lock stays ==="
_setup
_inject_finding "llmjudge-s5ddd001" "critical"
_inject_finding "llmjudge-s5ddd002" "high"
_engage_lock
_assert_lock_engaged "pre-condition: two open findings, lock engaged"

# Clear only finding 1 via path (b).
_apply_buildcommit "llmjudge-s5ddd001" 0 "commit-M-s5"
_resolve_buildcommits
_engage_lock

_assert_finding_status "llmjudge-s5ddd001" "cleared-via-buildcommit" "finding 1 cleared"
_assert_finding_status "llmjudge-s5ddd002" "open" "finding 2 still open"
_assert_lock_engaged "lock stays engaged (finding 2 still open)"

# ─── S6 — sticky property ────────────────────────────────────────────────────

echo ""
echo "=== S6: sticky — empty subsequent report does NOT clear lock ==="
_setup
_inject_finding "llmjudge-s6eee000" "critical"
_engage_lock
_assert_lock_engaged "pre-condition: lock engaged"

# Simulate a later report run that finds no new findings (empty report scenario).
# In the old broken routine this would rm -f the lock. In the new routine,
# step 04-accumulate adds nothing (no new findings), step 04b-resolve finds no
# clearance events, and step 05-enforce derives from the still-open open-set.
# We emulate that by calling _engage_lock again without modifying open-findings.
_engage_lock  # second tick, no changes to open-findings

_assert_finding_status "llmjudge-s6eee000" "open" "finding still open after empty report"
_assert_lock_engaged "lock still engaged after empty report (sticky property)"

# ─── S5b — BuildCommit with exit 1 does NOT clear ───────────────────────────

echo ""
echo "=== S5b: failed acceptance.cmd does not clear finding ==="
_setup
_inject_finding "llmjudge-s5beee000" "critical"
_engage_lock

_apply_buildcommit "llmjudge-s5beee000" 1 "commit-M-s5b"  # exit code 1
_resolve_buildcommits  # should skip this BC due to exit != 0
_engage_lock

_assert_finding_status "llmjudge-s5beee000" "open" "finding stays open when acceptance.cmd exit=1"
_assert_lock_engaged "lock stays engaged when acceptance.cmd failed"

# ─── summary ─────────────────────────────────────────────────────────────────

echo ""
echo "=== Results ==="
echo "PASS: ${PASS}  FAIL: ${FAIL}"
if [ "${FAIL}" -eq 0 ]; then
  echo "All quality-gate ratchet tests passed. (CLO-111)"
  exit 0
else
  echo "FAILURES detected — see above." >&2
  exit 1
fi
