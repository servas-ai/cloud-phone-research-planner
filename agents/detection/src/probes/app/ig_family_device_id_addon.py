"""
mitmproxy addon — app.ig_family_device_id_header (CLO-18)

Passively captures the ``x-ig-family-device-id`` header sent by
Instagram / Threads / Facebook / WhatsApp on any outbound HTTP/S request,
then writes a JSON evidence file that the companion Kotlin probe reads.

Ethics block
------------
The addon MUST be run with ``--set sandbox_marker=<token>`` where
``<token>`` matches the value written to ``SANDBOX_MARKER_PATH`` on the
device under test.  If no marker is supplied, the addon exits without
writing any capture file, preventing accidental analysis of production
accounts.

Usage (sandbox only)
--------------------
    mitmdump \
        -s ig_family_device_id_addon.py \
        --set sandbox_marker=SANDBOX_2026_CLO18_TEST \
        --set capture_path=/tmp/detectorlab/ig_fam_device_id.json

The capture file is consumed by IgFamilyDeviceIdHeaderProbe.kt.
"""

from __future__ import annotations

import json
import math
import os
import time
import uuid
from collections import defaultdict
from pathlib import Path
from typing import Optional

from mitmproxy import ctx, http

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

HEADER_NAME = "x-ig-family-device-id"

# Meta-family host suffixes whose traffic is in scope
_INSCOPE_SUFFIXES = (
    "instagram.com",
    "cdninstagram.com",
    "threads.net",
    "facebook.com",
    "fbcdn.net",
    "whatsapp.com",
    "whatsapp.net",
)

_DEFAULT_CAPTURE_PATH = "/tmp/detectorlab/ig_fam_device_id.json"


# ---------------------------------------------------------------------------
# Helper: Shannon entropy of a UUID string (bits)
# ---------------------------------------------------------------------------

def _uuid_entropy_bits(value: str) -> float:
    """Estimate Shannon entropy of ``value`` treating each char as a symbol."""
    if not value:
        return 0.0
    freq: dict[str, int] = {}
    for ch in value:
        freq[ch] = freq.get(ch, 0) + 1
    n = len(value)
    h = -sum((c / n) * math.log2(c / n) for c in freq.values() if c > 0)
    return round(h * n, 2)


def _is_valid_uuid(value: str) -> bool:
    try:
        uuid.UUID(value)
        return True
    except ValueError:
        return False


# ---------------------------------------------------------------------------
# Addon
# ---------------------------------------------------------------------------

class IgFamilyDeviceIdAddon:
    """
    Passive mitmproxy addon.  Never modifies traffic — read-only observation.

    Capture file schema (JSON):
    {
        "sandbox_marker":   str,          # echoed from --set sandbox_marker=
        "capture_ts_utc":   float,        # unix timestamp of last update
        "header_present":   bool,         # any in-scope request carried the header
        "value":            str | null,   # most-recently-seen header value
        "is_valid_uuid":    bool,         # value parses as RFC 4122 UUID
        "entropy_bits":     float,        # Shannon entropy of value string
        "capture_count":    int,          # total in-scope requests observed
        "header_count":     int,          # subset that contained the header
        "apps_seen":        [str],        # distinct host-suffixes that sent header
        "unique_values":    [str]         # distinct header values seen
    }
    """

    def load(self, loader):
        loader.add_option(
            "sandbox_marker", str, "",
            "Sandbox account marker token (REQUIRED).  Addon is inert without it.",
        )
        loader.add_option(
            "capture_path", str, _DEFAULT_CAPTURE_PATH,
            "Absolute path where the JSON evidence file is written.",
        )

    def running(self):
        marker = ctx.options.sandbox_marker
        if not marker:
            ctx.log.warn(
                "[CLO-18] No --set sandbox_marker supplied. "
                "Addon is INERT — no data will be captured."
            )
            return
        ctx.log.info(f"[CLO-18] IgFamilyDeviceIdAddon active. "
                     f"sandbox_marker={marker!r}  capture_path={ctx.options.capture_path!r}")

        # Initialise / reset the evidence file
        self._state: dict = {
            "sandbox_marker": marker,
            "capture_ts_utc": time.time(),
            "header_present": False,
            "value": None,
            "is_valid_uuid": False,
            "entropy_bits": 0.0,
            "capture_count": 0,
            "header_count": 0,
            "apps_seen": [],
            "unique_values": [],
        }
        self._apps_seen: set[str] = set()
        self._unique_values: set[str] = set()
        self._flush()

    def request(self, flow: http.HTTPFlow) -> None:
        marker = ctx.options.sandbox_marker
        if not marker:
            return  # ethics block: inert without sandbox marker

        host = flow.request.pretty_host.lower()
        if not any(host.endswith(s) for s in _INSCOPE_SUFFIXES):
            return  # out-of-scope traffic — skip

        self._state["capture_count"] += 1

        raw = flow.request.headers.get(HEADER_NAME)
        if raw is None:
            self._flush()
            return

        value = raw.strip()
        self._state["header_present"] = True
        self._state["value"] = value
        self._state["is_valid_uuid"] = _is_valid_uuid(value)
        self._state["entropy_bits"] = _uuid_entropy_bits(value)
        self._state["header_count"] += 1
        self._unique_values.add(value)
        self._state["unique_values"] = sorted(self._unique_values)

        # Tag which Meta app/host sent the header
        for suffix in _INSCOPE_SUFFIXES:
            if host.endswith(suffix):
                self._apps_seen.add(suffix)
                break
        self._state["apps_seen"] = sorted(self._apps_seen)

        self._flush()

    # ------------------------------------------------------------------

    def _flush(self) -> None:
        self._state["capture_ts_utc"] = time.time()
        path = Path(ctx.options.capture_path)
        path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
        tmp = path.with_suffix(".tmp")
        tmp.write_text(json.dumps(self._state, indent=2), encoding="utf-8")
        tmp.replace(path)  # atomic rename


addons = [IgFamilyDeviceIdAddon()]
