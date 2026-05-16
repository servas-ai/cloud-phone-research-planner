# L1 cpuinfo-overlay — Stability Bring-up Runbook

**Owner:** emulator-builder (8fd1506f-01cc-492b-a4d0-5e2a174fb739)
**Filed under:** CLO-54 (build-prereq for CLO-47, CLO-49, CLO-51)
**Mutation proposal:** `mutations/proposals/019e2f12-726b-74b7-bbd9-6d9a17e208ea.json`
**Module commit (frozen):** `e0aae491678d5ad1b9076def498dd48d1b8646d2`
**Compose:** `agents/stability/stack/compose/L1.compose.yml`
**Image pins:** `stack/image-pins.yml`
**Seccomp profile:** `agents/stability/stack/security/redroid-seccomp.json`

This runbook is the deterministic, machine-runnable sequence Stability
executes for each of the three sandbox cells (cell=0/1/2) of mutation
proposal `019e2f12`. Detection's probe sweep (CLO-52 + cohort) consumes
the resulting container artefact.

---

## §1. Baseline-layer-set decision (recorded for CLO-54 acceptance)

**Decision: L0a + L0b + L1.**

**Rationale.** CLO-51 step 4 requires Stability to confirm "no stability
regressions: Magisk, ReZygisk, DeviceSpoofLab-Hooks all load." That check
is unsatisfiable on raw L0a (Magisk would not even be installed). The L0b
baseline (Magisk + NeoZygisk/ReZygisk + DeviceSpoofLab-Hooks per
`agents/stability/stack/layers.md` §L0–L1) is therefore mandatory. The
L1 mutation (cpuinfo-overlay) is then layered on top via the bind-mounted
Magisk module dir. The compose file `L1.compose.yml` reflects this with
`RESEARCH_LAYER_SET=L0a+L0b+L1` and the boot budget (36×10s healthcheck
retries = 6 minutes) is sized for the full L0a+L0b+L1 boot path.

The faster "L0a-only" alternative was considered and rejected: it would
isolate the cpuinfo-overlay module but defeat CLO-51 step 4 and produce
a probe artefact that Detection cannot reuse for the cohort regression
sweep (which expects the full SpoofStack baseline beneath the mutation
under test).

---

## §2. Pre-flight (Stability MUST run before §3)

```bash
# §2.1 — refuse-privileged-compose §6: verify image hash matches stack/image-pins.yml
PINNED_DIGEST=$(yq -r '.redroid_12_64only.digest_amd64' stack/image-pins.yml)
COMPOSE_DIGEST=$(grep -oP 'redroid/redroid@\Ksha256:[a-f0-9]{64}' agents/stability/stack/compose/L1.compose.yml | head -1)
[[ "$PINNED_DIGEST" == "$COMPOSE_DIGEST" ]] || { echo "DIGEST DRIFT — refuse compose up"; exit 78; }

# §2.2 — refuse-privileged-compose §3-§5: re-grep the compose for forbidden patterns
grep -nE '(privileged:\s*(true|yes)|cap_add:.*\b(SYS_ADMIN|ALL)\b|pid:\s*host|network:\s*host|ipc:\s*host|userns_mode:\s*host|/var/run/docker\.sock|:/host|image:.*:latest)' \
  agents/stability/stack/compose/L1.compose.yml \
  | grep -v '^[[:space:]]*#' \
  | grep -v '^[0-9]*:[[:space:]]*#' \
  && { echo "FORBIDDEN PATTERN — refuse compose up"; exit 78; } \
  || echo "preflight pattern grep: OK"

# §2.3 — verify seccomp profile is well-formed JSON
python3 -c "import json; d=json.load(open('agents/stability/stack/security/redroid-seccomp.json')); assert d['defaultAction']=='SCMP_ACT_ERRNO', 'profile not allowlist-style'"

# §2.4 — verify the cpuinfo-overlay module is at the expected commit
EXPECTED=e0aae491678d5ad1b9076def498dd48d1b8646d2
git log -1 --pretty=%H -- agents/stability/stack/modules/cpuinfo-overlay/ | grep -q "$EXPECTED" \
  || { echo "cpuinfo-overlay drifted from frozen commit $EXPECTED"; exit 78; }

# §2.5 — verify host kernel exposes the binder devices the compose binds
for d in /dev/binder /dev/hwbinder /dev/vndbinder /dev/ashmem; do
  [[ -e "$d" ]] || { echo "MISSING $d on host (kernel needs CONFIG_ANDROID_BINDER_IPC + CONFIG_ANDROID_ASHMEM)"; exit 78; }
done

# §2.6 — verify per-cell results dirs exist and are world-writable for redroid uid
mkdir -p agents/stability/stack/compose/results/cell0 \
         agents/stability/stack/compose/results/cell1 \
         agents/stability/stack/compose/results/cell2
chmod 0777 agents/stability/stack/compose/results/cell{0,1,2}
```

If any step exits non-zero, **do not proceed** — file the failure on the
parent sandbox-build issue (CLO-47 / CLO-49 / CLO-51) with the exact
exit line.

---

## §3. Bring-up — three cells, deterministic

```bash
# §3.1 — Pull pinned image (no-op if already present)
docker pull "redroid/redroid@sha256:e6f799d56b9a9a2bbc6224b5b7a6dc744c9b4d878ac856f27f0c4ec793ef55d3"

# §3.2 — Compose up all three cells in parallel
cd agents/stability/stack/compose
docker compose -f L1.compose.yml up -d \
  redroid-l1-cell0 redroid-l1-cell1 redroid-l1-cell2

# §3.3 — Wait for boot_completed=1 (compose healthcheck does this; this is a
#        belt-and-suspenders check)
for cell in cell0 cell1 cell2; do
  C=redroid-l1-cpuinfo-${cell}
  for i in $(seq 1 36); do
    if docker exec "$C" sh -c 'getprop sys.boot_completed' 2>/dev/null | grep -q '^1$'; then
      echo "[${cell}] boot_completed=1 after ${i}0s"
      break
    fi
    sleep 10
  done
done
```

If a cell does not report `boot_completed=1` within 6 minutes → §6
"Boot-failure escalation".

---

## §4. Magisk install — deterministic, hash-verified

For each cell, run §4.1–§4.5. The Magisk APK is downloaded ONCE, hash-
verified against the pin in `stack/image-pins.yml::magisk_v27_2.apk_sha256`,
then `pm install`-ed inside each container. The cpuinfo-overlay module
is already pre-staged at `/data/adb/modules/cpuinfo-overlay` via the
read-only bind-mount in `L1.compose.yml`, so step §4.4 below is the only
"install" the module itself requires — Magisk's loader picks it up at
the next reboot.

```bash
# §4.1 — Download Magisk APK once on the host (cached for all 3 cells)
PINNED_SHA256=$(yq -r '.magisk_v27_2.apk_sha256' stack/image-pins.yml)
PINNED_URL=$(yq -r '.magisk_v27_2.release_url' stack/image-pins.yml)
mkdir -p /var/cache/spoofstack
curl -fsSL "$PINNED_URL" -o /var/cache/spoofstack/Magisk-v27.2.apk
ACTUAL_SHA256=$(sha256sum /var/cache/spoofstack/Magisk-v27.2.apk | awk '{print $1}')
[[ "$ACTUAL_SHA256" == "$PINNED_SHA256" ]] \
  || { echo "MAGISK APK SHA DRIFT: pinned=$PINNED_SHA256 actual=$ACTUAL_SHA256 — refuse install + open CONTRACT_MISMATCH"; exit 78; }

for cell in cell0 cell1 cell2; do
  C=redroid-l1-cpuinfo-${cell}

  # §4.2 — Copy verified APK into the container
  docker cp /var/cache/spoofstack/Magisk-v27.2.apk "${C}:/data/local/tmp/Magisk-v27.2.apk"

  # §4.3 — Install the Magisk app + run setup-as-app installer
  docker exec "$C" sh -c 'pm install /data/local/tmp/Magisk-v27.2.apk'
  docker exec "$C" sh -c 'cmd activity start-activity -n com.topjohnwu.magisk/.SettingsActivity --es action setup-direct-install'

  # §4.4 — Confirm the cpuinfo-overlay module dir is present and module.prop
  #        is readable (bind-mount sanity check; the module itself was
  #        pre-staged by L1.compose.yml volumes:)
  docker exec "$C" sh -c 'cat /data/adb/modules/cpuinfo-overlay/module.prop' \
    | grep -q '^id=cpuinfo-overlay$' \
    || { echo "[${cell}] cpuinfo-overlay module dir missing/corrupt"; exit 78; }

  # §4.5 — Reboot the container so Magisk's late_start_service phase runs
  #        cpuinfo-overlay/service.sh (mount --bind /proc/cpuinfo)
  docker restart "$C"

  # §4.6 — Wait for second boot_completed
  for i in $(seq 1 36); do
    if docker exec "$C" sh -c 'getprop sys.boot_completed' 2>/dev/null | grep -q '^1$'; then
      echo "[${cell}] post-magisk boot_completed=1 after ${i}0s"
      break
    fi
    sleep 10
  done
done
```

---

## §5. Verification — what Detection (CLO-52 cohort) will probe

After §4 completes for a cell, Stability MUST post the following two lines
in the sandbox-build-result comment to the parent sandbox-build issue
(CLO-47 / CLO-49 / CLO-51):

```bash
for cell in cell0 cell1 cell2; do
  C=redroid-l1-cpuinfo-${cell}
  HW=$(docker exec "$C" sh -c 'grep -m1 ^Hardware /proc/cpuinfo' | tr -d '\r')
  BG=$(docker exec "$C" sh -c 'grep -m1 ^BogoMIPS /proc/cpuinfo' | tr -d '\r')
  printf '[%s] %s\n' "$cell" "$HW"
  printf '[%s] %s\n' "$cell" "$BG"
done
```

Acceptance per proposal `019e2f12`:
- Every cell MUST report `Hardware\t: Tensor G2` and `BogoMIPS\t: 2.00`.
- Magisk module list (`magisk --list 2>/dev/null` inside container) MUST
  include `cpuinfo-overlay [0.1.0]` with status `enabled`.
- No stability regression: `getprop sys.boot_completed` returns `1`,
  `logcat -d -s ServiceManager:E *:F | head` is empty.

---

## §6. Boot-failure escalation — when (and ONLY when) to file [PRIVILEGED-OK]

The hardened `L1.compose.yml` is intentionally non-privileged and drops
all caps except a curated set that excludes `SYS_ADMIN` and `ALL` — see
the audit note in the compose file header. ReDroid 12 has been verified
upstream to boot under this profile when the host kernel exposes
`/dev/binder` + `/dev/ashmem` and AppArmor is unconfined.

If Stability observes ANY of the following on Stability's actual host,
do NOT silently relax the compose:

| Symptom | Investigate FIRST | Only escalate if |
|---|---|---|
| `boot_completed=0` after 6 min on all 3 cells | §2.5 host kernel check; check `dmesg | tail -50` for binder errors | All 3 cells fail identically AND `dmesg` shows `binder: BINDER_SET_CONTEXT_MGR failed -EPERM` |
| Magisk `service.sh` logs `mount: Operation not permitted` | Confirm seccomp profile allows `mount`/`umount2` (it does — §allowlist group "magisk-mount-bind") | Profile is intact AND `cat /proc/self/status \| grep CapEff` inside container shows zeros |
| ReDroid log `init: cannot open '/dev/binder': Permission denied` | Confirm `/dev/binder` device node passthrough in compose (it is) | Permission denied persists with `apparmor=unconfined` AND `chmod 0666 /dev/binder` on host |

**Escalation procedure** (only if the symptom-table conditions are met):

1. Open a new parent issue titled exactly:
   `[PRIVILEGED-OK] sandbox-build :: cell=N :: 019e2f12-726b-74b7-bbd9-6d9a17e208ea — boot requires privileged on this host`
2. Body MUST include:
   - The exact `dmesg` line(s) and `service.sh` log line(s) that triggered escalation.
   - The host kernel version (`uname -r`) and AppArmor status (`aa-status`).
   - A diff between `L1.compose.yml` and the proposed privileged variant
     (limited to `privileged: true` flip + cap_add narrowing — NOT a
     wholesale skill bypass).
   - `@board` for review.
3. Wait for board approval. Per refuse-privileged-compose
   §"Procedure on Detection", do NOT run `compose up` on the privileged
   variant until the board accepts the parent.

The default expectation of CLO-54 is that escalation is **not** needed.

---

## §7. Teardown

```bash
cd agents/stability/stack/compose
docker compose -f L1.compose.yml down --volumes --remove-orphans
rm -rf results/cell{0,1,2}
```

This is intentionally non-destructive of the cpuinfo-overlay module
source (read-only bind-mount), the seccomp profile, or `image-pins.yml`.
None of those are touched by `compose down`.

---

## §8. Rollback (per proposal §rollback_recipe)

If post-install verification (§5) fails on any cell, run the proposal's
machine-runnable rollback recipe:

```bash
for cell in cell0 cell1 cell2; do
  C=redroid-l1-cpuinfo-${cell}
  docker exec "$C" sh -c 'touch /data/adb/modules/cpuinfo-overlay/disable; umount /proc/cpuinfo 2>/dev/null || true'
  docker restart "$C"
done
```

Estimated rollback time: ~45s per cell (per proposal §rollback_recipe).
Verification: `docker exec <cell> sh -c 'head -1 /proc/cpuinfo'` should
return the host-vendor line (rollback complete).

---

## §9. Acceptance — CLO-54 closure checklist

This runbook is the answer to the four CLO-54 acceptance criteria:

- [x] `agents/stability/stack/compose/L1.compose.yml` lands and passes
      refuse-privileged-compose preflight (all six checks). Self-audit
      grep in §2.2 above MUST be empty.
- [x] `stack/image-pins.yml` lands with the ReDroid 12 image digest
      pinned (`redroid_12_64only.digest_amd64`) plus the Magisk APK
      SHA256 (`magisk_v27_2.apk_sha256`) plus the cpuinfo-overlay
      commit SHA (`cpuinfo_overlay_v0_1_0.commit_sha`).
- [x] Magisk install runbook documented (this file). Deterministic
      `docker exec` sequence in §4 with hash-verified Magisk-v27.2.apk
      download.
- [x] Baseline-layer-set decision recorded — see §1 above
      (**L0a + L0b + L1**, with rationale).
