# W7 — ARM64-Host Preference & x86_64 Translation Trap

> **CLO-14** · Stability Agent · Layer L0a

## ARM64-Host Mandatory for ReDroid L0a

Per [BEST-STACK §II](../../../BEST-STACK.md#ii-the-spoofstack-stability-agent--defense-per-android-version),
the recommended L0a baseline is:

| Layer | Image | Constraint |
|-------|-------|------------|
| L0a | `redroid/redroid:12.0.0_64only-latest` | **ARM64 host mandatory** |

Running ReDroid on an x86_64 host forces the kernel to use `libhoudini`
(or `libndk_translation`) to translate ARM64 guest instructions. This
translation layer is **Tier-3 detectable** (see §Libhoudini Leak below).

**Preference order:**

1. ARM64 host (Graviton, Apple M-series, Ampere) — full-speed native, no leak
2. x86_64 host with ARM64 emulation disabled — container fails to start (correct behaviour: surfaces the constraint early)
3. x86_64 host with libhoudini enabled — dev-parity mode only; severity rating downgraded; CI gate will fail

---

## libhoudini Tier-3 Leak (CLO-14 documentation)

### What leaks

When ReDroid runs on an x86_64 host the Android guest uses
`libhoudini` / `libndk_translation` to run ARM64 user-space code.
The translation layer exposes host x86 capability bits through
`/proc/cpuinfo` fields that are not part of any ReDroid spoofing layer:

| Leaked field | ARM64 expected value | x86_64 actual value |
|---|---|---|
| `CPU implementer` | `0x41` (ARM Ltd) | `0x00` or absent |
| `CPU architecture` | `8` | `6` (or `Houdini` string) |
| `BogoMIPS` | ≥ 38 (Cortex-A55 class) | ≥ 3000 (x86 RDTSC-scaled) |
| `Features` flags | `aes,pmull,sha1,sha2,…` | translated / absent |
| `Hardware` | Board name | `x86_64` or blank |

**Probe this via**: `Reveny Emulator Detection v1.5.0` (libhoudini detection
path), or read `/proc/cpuinfo` directly and compare `CPU implementer` against
`0x41`.

### Why it matters

This is a **Hard ceiling #9** — ReDroid's cpuinfo overlay (`L1 props`) does
not rewrite `/proc/cpuinfo` implementer/architecture lines when libhoudini is
active because the translation layer re-injects host values after the overlay.
No FOSS module counters this in 2026.

### Severity rating

| Host arch | Tier-3 leak | Ceiling # | Severity |
|-----------|-------------|-----------|----------|
| ARM64     | None        | N/A       | None     |
| x86_64    | libhoudini  | 9         | **HIGH** → downgraded to **INFO** in dev-parity mode |

---

## CI Gate — Fail on x86_64 Host

The shell script `agents/stability/stack/ci-arch-gate.sh` enforces this constraint
in CI. It exits non-zero when the host machine is x86_64, blocking any stability
run that would silently produce misleading results.

See [ci-arch-gate.sh](../../../agents/stability/stack/ci-arch-gate.sh).

---

## Bootstrap Behaviour on x86_64

When `bootstrap.sh` detects an x86_64 host it:

1. Prints a **WARNING** banner to stderr (yellow).
2. Downgrades the severity label of Tier-3 libhoudini findings to `INFO` in
   the stability report (field `arch_penalty: true`).
3. **Proceeds** — the run completes for dev-parity purposes.
4. Sets `host_arch_warning: true` in `reports/stability/{run_id}.json`.

This means local x86_64 developer runs still produce a stability report and
a container_id, but any downstream CI job that gates on the arch check will
fail independently.
