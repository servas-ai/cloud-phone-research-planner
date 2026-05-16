#!/usr/bin/env bash
# CI gate: validate every JSON in apps/detector-lab/out/ against probe-result.schema.json
# Usage: ./tools/validate-probe-results.sh [--out-dir PATH]
# Exit 0 = all valid, 1 = validation failure, 2 = setup error
set -euo pipefail
umask 077

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCHEMA="$REPO_ROOT/shared/probes/probe-result.schema.json"
OUT_DIR="${1:-$REPO_ROOT/apps/detector-lab/out}"

if [[ ! -f "$SCHEMA" ]]; then
  echo "error: schema not found: $SCHEMA" >&2
  exit 2
fi

if ! command -v ajv &>/dev/null; then
  echo "error: ajv not found. Install with: npm install -g ajv-cli" >&2
  exit 2
fi

shopt -s nullglob
json_files=("$OUT_DIR"/*.json)
shopt -u nullglob

if [[ ${#json_files[@]} -eq 0 ]]; then
  echo "info: no JSON files in $OUT_DIR — nothing to validate"
  exit 0
fi

fail=0
for f in "${json_files[@]}"; do
  if ajv validate -s "$SCHEMA" -d "$f" --spec=draft2020 2>&1; then
    echo "PASS: $f"
  else
    echo "FAIL: $f" >&2
    fail=1
  fi
done

exit $fail
