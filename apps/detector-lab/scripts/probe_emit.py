#!/usr/bin/env python3
"""probe_emit.py — schema-v2 record builder for droidrun-cell.sh.

Reads one probe's raw output on stdin (or via --raw-file), wraps it into the
shared/probe-schema.v2.json envelope, validates against the JSON-Schema if
jsonschema is importable, and prints a single JSON record to stdout (one
record per invocation). The driver script (droidrun-cell.sh) concatenates
multiple invocations into an NDJSON / array file under
apps/detector-lab/out/matrix/<cell>.json.

Why a helper: schema-v2 has nine REQUIRED fields plus the strict
additionalProperties=false envelope; expressing that in pure bash is fragile
and CI's ajv gate (CLO-21) will fail any record that drifts. Centralising
record construction here keeps droidrun-cell.sh small and lets unit tests
target the normaliser directly.
"""

from __future__ import annotations

import argparse
import json
import pathlib
import sys
import time
from typing import Any

_SCHEMA_PATH_REL = "shared/probe-schema.v2.json"
_ALLOWED_CATEGORIES = {
    "buildprop", "integrity", "root", "emulator", "network",
    "identity", "runtime", "sensors", "ui", "env",
}
_ALLOWED_LAYERS = {"L0a", "L0b", "L0c", "L0", "L1", "L2", "L3", "L4", "L5", "L6"}


def _repo_root(start: pathlib.Path) -> pathlib.Path:
    cur = start.resolve()
    for parent in (cur, *cur.parents):
        if (parent / _SCHEMA_PATH_REL).exists():
            return parent
    raise SystemExit(
        f"probe_emit: could not locate {_SCHEMA_PATH_REL} from {start}"
    )


def _load_schema(schema_path: pathlib.Path) -> dict[str, Any]:
    with schema_path.open("r", encoding="utf-8") as fh:
        return json.load(fh)


def _parse_raw(raw_text: str) -> dict[str, Any]:
    raw_text = raw_text.strip()
    if not raw_text:
        return {}
    try:
        parsed = json.loads(raw_text)
    except json.JSONDecodeError:
        return {"stdout": raw_text}
    if isinstance(parsed, dict):
        return parsed
    return {"value": parsed}


def _parse_evidence(values: list[str]) -> list[dict[str, Any]]:
    out: list[dict[str, Any]] = []
    for spec in values:
        path, _, rhs = spec.partition("=")
        if not path:
            raise SystemExit(f"probe_emit: invalid --evidence spec: {spec!r}")
        ev: dict[str, Any] = {"path": path}
        if rhs:
            try:
                ev["value"] = json.loads(rhs)
            except json.JSONDecodeError:
                ev["value"] = rhs
        out.append(ev)
    return out


def build_record(args: argparse.Namespace, raw_obj: dict[str, Any]) -> dict[str, Any]:
    if args.category not in _ALLOWED_CATEGORIES:
        raise SystemExit(
            f"probe_emit: category {args.category!r} not in "
            f"{sorted(_ALLOWED_CATEGORIES)}"
        )
    if args.layer not in _ALLOWED_LAYERS:
        raise SystemExit(
            f"probe_emit: layer {args.layer!r} not in {sorted(_ALLOWED_LAYERS)}"
        )

    record: dict[str, Any] = {
        "schema_version": "2.0",
        "probe_id": args.probe_id,
        "probe_name": args.probe_name,
        "category": args.category,
        "layer": args.layer,
        "score": float(args.score),
        "runtime_ms": int(args.runtime_ms),
        "sample_count": int(args.sample_count),
        "seed_ms": int(args.seed_ms if args.seed_ms is not None else time.time() * 1000),
        "raw": raw_obj,
    }
    if args.confidence is not None:
        record["confidence"] = float(args.confidence)
    if args.evidence:
        record["evidence"] = _parse_evidence(args.evidence)
    if args.repro:
        try:
            record["repro"] = json.loads(args.repro)
        except json.JSONDecodeError as exc:
            raise SystemExit(f"probe_emit: --repro is not valid JSON: {exc}")
    if args.notes:
        record["notes"] = args.notes
    return record


def validate(record: dict[str, Any], schema: dict[str, Any]) -> None:
    try:
        import jsonschema
    except ImportError:
        sys.stderr.write(
            "probe_emit: jsonschema not installed; skipping schema validation\n"
        )
        return
    try:
        jsonschema.validate(instance=record, schema=schema)
    except jsonschema.ValidationError as exc:
        sys.stderr.write(f"probe_emit: schema-v2 validation FAILED: {exc.message}\n")
        sys.exit(2)


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--probe-id", required=True, help="dotted id, e.g. runtime.installed_apps")
    p.add_argument("--probe-name", required=True, help="human probe class name")
    p.add_argument("--category", required=True)
    p.add_argument("--layer", required=True)
    p.add_argument("--score", required=True, type=float)
    p.add_argument("--runtime-ms", required=True, type=int)
    p.add_argument("--sample-count", default=1, type=int)
    p.add_argument("--seed-ms", default=None, type=int)
    p.add_argument("--confidence", default=None, type=float)
    p.add_argument(
        "--evidence", action="append", default=[],
        help="repeatable; path[=value]. value parsed as JSON when valid.",
    )
    p.add_argument("--repro", default=None, help="raw JSON object for the repro block")
    p.add_argument("--notes", default=None)
    p.add_argument(
        "--raw-file", default=None,
        help="read raw probe output from path instead of stdin",
    )
    p.add_argument(
        "--no-validate", action="store_true",
        help="skip jsonschema validation (use only for fixture generation)",
    )
    p.add_argument(
        "--schema",
        default=None,
        help=f"override path to {_SCHEMA_PATH_REL}",
    )
    args = p.parse_args(argv)

    raw_text = (
        pathlib.Path(args.raw_file).read_text(encoding="utf-8")
        if args.raw_file
        else sys.stdin.read()
    )
    raw_obj = _parse_raw(raw_text)
    record = build_record(args, raw_obj)

    if not args.no_validate:
        schema_path = (
            pathlib.Path(args.schema)
            if args.schema
            else _repo_root(pathlib.Path(__file__).parent) / _SCHEMA_PATH_REL
        )
        validate(record, _load_schema(schema_path))

    json.dump(record, sys.stdout, ensure_ascii=False, separators=(",", ":"))
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
