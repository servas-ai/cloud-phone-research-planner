#!/usr/bin/env bash
# ci-arch-gate.sh — CLO-14
# Fails CI when the host machine is x86_64.
# ReDroid L0a requires an ARM64 host; running on x86_64 enables libhoudini,
# which leaks host x86 capability bits (Tier-3 / Hard-ceiling #9).
# This gate prevents silently misleading detection results in CI.
#
# Exit codes:
#   0  — host is ARM64 (or aarch64); gate passes
#   1  — host is x86_64; gate fails (CI must not proceed)
#   2  — host arch unknown; gate fails conservatively

umask 077

HOST_ARCH=$(uname -m)

case "$HOST_ARCH" in
  aarch64|arm64)
    echo "[ci-arch-gate] PASS: host is ${HOST_ARCH} (ARM64 native — libhoudini inactive)"
    exit 0
    ;;
  x86_64|amd64)
    echo "[ci-arch-gate] FAIL: host is ${HOST_ARCH}" >&2
    echo "" >&2
    echo "  ReDroid L0a (redroid:12.0.0_64only) requires an ARM64 host." >&2
    echo "  On x86_64, libhoudini translates ARM64 guest instructions and" >&2
    echo "  leaks host x86 capability bits through /proc/cpuinfo:" >&2
    echo "    - CPU implementer  : 0x00 (not 0x41 / ARM Ltd)" >&2
    echo "    - CPU architecture : mis-reported or absent" >&2
    echo "    - BogoMIPS         : x86 RDTSC-scaled (~3000+, not ~38)" >&2
    echo "" >&2
    echo "  This is Hard-ceiling #9 (CLO-14). No FOSS module counters it." >&2
    echo "  Use an ARM64 CI runner (Graviton, Ampere, Apple M-series)." >&2
    echo "" >&2
    echo "  To run in dev-parity mode on x86_64 locally, use bootstrap.sh" >&2
    echo "  directly (it warns but proceeds with severity downgraded to INFO)." >&2
    exit 1
    ;;
  *)
    echo "[ci-arch-gate] FAIL: unknown host arch '${HOST_ARCH}' — failing conservatively" >&2
    exit 2
    ;;
esac
