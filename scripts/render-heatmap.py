#!/usr/bin/env python3
"""Weekly baseline-matrix heatmap renderer.

Invoked by the Paperclip routine 'Weekly heatmap cell-sweep + render' (Mon 07:00 UTC).
Reads probe results from docs/super-action/Wn/heatmap/cells.json (produced by the
cell-sweep agent in CLO-13), then writes:
  docs/super-action/Wn+1/heatmap/<iso-week>/heatmap.svg
  docs/super-action/Wn+1/heatmap/<iso-week>/heatmap.json

Usage:
  python3 scripts/render-heatmap.py [--dry-run] [--week-dir W12] [--iso-week 21]
"""

import argparse
import datetime
import json
import os
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent

DEVICES = ["Pixel 8", "Pixel 9", "Pixel 9 Pro"]
OS_VERSIONS = ["Android 14", "Android 15", "Android 16"]

# Score thresholds
GREEN_THRESH = 0.3   # detection score <= 0.3 → green (low detectability)
AMBER_THRESH = 0.65  # <= 0.65 → amber

COLORS = {
    "green":  "#22c55e",
    "amber":  "#f59e0b",
    "red":    "#ef4444",
    "none":   "#d1d5db",
}


def latest_week_dir(super_action: Path) -> tuple[int, Path]:
    """Return (n, path) for the highest Wn directory present."""
    dirs = [(int(m.group(1)), d) for d in super_action.iterdir()
            if d.is_dir() and (m := re.match(r'^W(\d+)$', d.name))]
    if not dirs:
        raise RuntimeError(f"No W-numbered directories found in {super_action}")
    return max(dirs, key=lambda x: x[0])


def load_cells(week_dir: Path) -> dict:
    """Load probe results from week_dir/heatmap/cells.json if present."""
    cells_path = week_dir / "heatmap" / "cells.json"
    if cells_path.exists():
        with open(cells_path) as f:
            return json.load(f)
    return {}


def cell_color(score: float | None) -> str:
    if score is None:
        return COLORS["none"]
    if score <= GREEN_THRESH:
        return COLORS["green"]
    if score <= AMBER_THRESH:
        return COLORS["amber"]
    return COLORS["red"]


def cell_label(score: float | None) -> str:
    if score is None:
        return "n/a"
    return f"{score:.2f}"


def render_svg(cells: dict, iso_week: int, rendered_at: str) -> str:
    cell_w, cell_h = 140, 60
    pad = 10
    header_w = 100
    header_h = 40
    cols = len(OS_VERSIONS)
    rows = len(DEVICES)

    total_w = header_w + cols * cell_w + pad * 2
    total_h = header_h + rows * cell_h + pad * 2 + 30  # 30 for footer

    lines = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{total_w}" height="{total_h}"'
        f' viewBox="0 0 {total_w} {total_h}" font-family="monospace" font-size="12">',
        f'<rect width="{total_w}" height="{total_h}" fill="#f8fafc"/>',
        # Title
        f'<text x="{pad}" y="{pad + 14}" font-size="14" font-weight="bold" fill="#1e293b">'
        f'Baseline Heatmap — ISO W{iso_week}</text>',
    ]

    # Column headers
    for ci, os_ver in enumerate(OS_VERSIONS):
        x = pad + header_w + ci * cell_w + cell_w // 2
        y = pad + header_h - 6
        lines.append(
            f'<text x="{x}" y="{y}" text-anchor="middle" fill="#475569">{os_ver}</text>'
        )

    # Rows
    for ri, device in enumerate(DEVICES):
        y0 = pad + header_h + ri * cell_h
        # Row label
        lines.append(
            f'<text x="{pad + header_w - 6}" y="{y0 + cell_h // 2 + 5}"'
            f' text-anchor="end" fill="#475569">{device}</text>'
        )
        for ci, os_ver in enumerate(OS_VERSIONS):
            x0 = pad + header_w + ci * cell_w
            key = f"{device}|{os_ver}"
            score = cells.get(key)
            color = cell_color(score)
            label = cell_label(score)
            lines += [
                f'<rect x="{x0 + 2}" y="{y0 + 2}" width="{cell_w - 4}" height="{cell_h - 4}"'
                f' rx="4" fill="{color}" stroke="#e2e8f0" stroke-width="1"/>',
                f'<text x="{x0 + cell_w // 2}" y="{y0 + cell_h // 2 + 5}"'
                f' text-anchor="middle" fill="#1e293b" font-size="13">{label}</text>',
            ]

    # Footer
    fy = total_h - 8
    lines.append(
        f'<text x="{pad}" y="{fy}" font-size="10" fill="#94a3b8">'
        f'rendered {rendered_at} · green ≤{GREEN_THRESH} · amber ≤{AMBER_THRESH} · red >{AMBER_THRESH}</text>'
    )
    lines.append('</svg>')
    return '\n'.join(lines)


def render_json(cells: dict, iso_week: int, rendered_at: str, week_dir_name: str) -> dict:
    matrix = []
    for device in DEVICES:
        for os_ver in OS_VERSIONS:
            key = f"{device}|{os_ver}"
            score = cells.get(key)
            matrix.append({
                "device": device,
                "os": os_ver,
                "score": score,
                "verdict": (
                    "green" if score is not None and score <= GREEN_THRESH else
                    "amber" if score is not None and score <= AMBER_THRESH else
                    "red" if score is not None else
                    "no_data"
                ),
            })
    return {
        "schema_version": 1,
        "iso_week": iso_week,
        "week_dir": week_dir_name,
        "rendered_at": rendered_at,
        "thresholds": {"green": GREEN_THRESH, "amber": AMBER_THRESH},
        "matrix": matrix,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true",
                        help="Print what would be written without writing files")
    parser.add_argument("--week-dir", metavar="Wn",
                        help="Override output week dir name (e.g. W12)")
    parser.add_argument("--iso-week", type=int,
                        help="Override ISO week number")
    args = parser.parse_args()

    super_action = REPO_ROOT / "docs" / "super-action"

    # Determine current Wn and input cells
    n, current_dir = latest_week_dir(super_action)
    input_cells = load_cells(current_dir)

    # Output goes into Wn+1
    out_week_name = args.week_dir or f"W{n + 1}"
    now = datetime.datetime.utcnow()
    iso_week = args.iso_week or now.isocalendar()[1]
    rendered_at = now.strftime("%Y-%m-%dT%H:%M:%SZ")

    out_dir = super_action / out_week_name / "heatmap" / str(iso_week)

    svg_content = render_svg(input_cells, iso_week, rendered_at)
    json_content = render_json(input_cells, iso_week, rendered_at, out_week_name)

    if args.dry_run:
        print(f"[dry-run] Would write to: {out_dir}/")
        print(f"[dry-run]   heatmap.svg  ({len(svg_content)} bytes)")
        print(f"[dry-run]   heatmap.json ({len(json.dumps(json_content))} bytes)")
        print(f"[dry-run] Source cells loaded: {len(input_cells)} entries from {current_dir}")
        print(f"[dry-run] Input cells: {json.dumps(input_cells, indent=2) or '{}'}")
        return 0

    out_dir.mkdir(parents=True, exist_ok=True)

    svg_path = out_dir / "heatmap.svg"
    json_path = out_dir / "heatmap.json"

    svg_path.write_text(svg_content)
    json_path.write_text(json.dumps(json_content, indent=2))

    print(f"Wrote {svg_path}")
    print(f"Wrote {json_path}")
    print(f"Cells loaded: {len(input_cells)} entries")
    return 0


if __name__ == "__main__":
    sys.exit(main())
