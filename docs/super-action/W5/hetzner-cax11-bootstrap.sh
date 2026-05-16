#!/usr/bin/env bash
# =============================================================================
# hetzner-cax11-bootstrap.sh
# ARM64 smoketest sidecar bootstrap for Hetzner CAX11 (Ampere Altra, aarch64)
# =============================================================================
# PURPOSE: Provision a Hetzner CAX11 node, pull ReDroid 12 arm64, run a
#          minimal L0a baseline container, execute BuildFingerprintProbe,
#          and push results to a shared git-tracked JSON location.
#
# USAGE:   Pass as cloud-init user-data to `hcloud server create`:
#            hcloud server create \
#              --type cax11 --image ubuntu-24.04 \
#              --user-data-from-file hetzner-cax11-bootstrap.sh \
#              --name cax11-arm-smoketest
#
# HARD RULES:
#   - No credentials are stored in this file
#   - All secrets come from environment or Hetzner secrets manager
#   - set -euo pipefail is active throughout
#   - DO NOT EXECUTE without operator approval
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# 0. Configuration — no credentials here; operator sets these at runtime
# ---------------------------------------------------------------------------
REDROID_IMAGE="redroid/redroid:12.0.0_64only-240527"
REDROID_CONTAINER_NAME="redroid-smoketest"
RESULTS_DIR="/opt/redroid-smoketest/results"
LOG_FILE="/opt/redroid-smoketest/bootstrap.log"
PROBE_TIMEOUT_SECONDS=120

# Output destination: set RESULTS_GIT_REPO via Hetzner secrets/env
# or leave unset to skip the git-push step.
RESULTS_GIT_REPO="${RESULTS_GIT_REPO:-}"

# ---------------------------------------------------------------------------
# 1. Logging helper
# ---------------------------------------------------------------------------
log() {
  echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] $*" | tee -a "$LOG_FILE"
}

mkdir -p "$RESULTS_DIR"
log "Bootstrap starting on $(uname -m) kernel $(uname -r)"

# ---------------------------------------------------------------------------
# 2. Verify we are on ARM64 — fail fast if not
# ---------------------------------------------------------------------------
ARCH=$(uname -m)
if [ "$ARCH" != "aarch64" ]; then
  log "ERROR: Expected aarch64, got $ARCH. This script is ARM64-only."
  exit 1
fi
log "Architecture confirmed: aarch64"

# ---------------------------------------------------------------------------
# 3. System update and base packages
# ---------------------------------------------------------------------------
log "Updating package lists..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y --no-install-recommends \
  curl \
  git \
  ca-certificates \
  jq \
  python3 \
  python3-pip \
  gnupg \
  lsb-release \
  >> "$LOG_FILE" 2>&1
log "Base packages installed."

# ---------------------------------------------------------------------------
# 4. Kernel feature verification
# ---------------------------------------------------------------------------
log "Checking kernel features required by ReDroid..."

check_kernel_feature() {
  local feature="$1"
  if zcat /proc/config.gz 2>/dev/null | grep -q "^${feature}=y"; then
    log "  OK: $feature"
  else
    log "  WARN: $feature not found in kernel config — ReDroid may not start"
  fi
}

check_kernel_feature "CONFIG_ANDROID_BINDERFS"
check_kernel_feature "CONFIG_PSI"
check_kernel_feature "CONFIG_DMABUF_HEAPS"
check_kernel_feature "CONFIG_USER_NS"

# Load binder + ashmem kernel modules (per CLO-66 Office-Trader approval —
# "modprobe binder_linux to be baked into user-data"). Best-effort: HWE/cloud
# kernels generally ship the modules; if they are not packaged on the chosen
# image we fall through to the existence check which fails-fast as before.
log "Loading binder_linux + ashmem_linux kernel modules (idempotent)..."
modprobe binder_linux num_devices=3 >> "$LOG_FILE" 2>&1 \
  && log "  OK: binder_linux loaded" \
  || log "  WARN: binder_linux modprobe failed — relying on existence check below"
modprobe ashmem_linux >> "$LOG_FILE" 2>&1 \
  && log "  OK: ashmem_linux loaded" \
  || log "  WARN: ashmem_linux modprobe failed (often built-in or via binderfs — non-fatal)"
# Persist module-load across reboots
mkdir -p /etc/modules-load.d
cat > /etc/modules-load.d/redroid.conf <<'MODULES_EOF'
binder_linux
ashmem_linux
MODULES_EOF
log "  Persisted module-load via /etc/modules-load.d/redroid.conf"

# Check /dev/binder
if [ -e /dev/binder ]; then
  log "  OK: /dev/binder present"
elif grep -q binder /proc/filesystems 2>/dev/null; then
  log "  OK: binderfs available (mount manually if needed)"
else
  log "  ERROR: Neither /dev/binder nor binderfs found — ReDroid will not start"
  exit 1
fi

# ---------------------------------------------------------------------------
# 5. Install Docker Engine
# ---------------------------------------------------------------------------
log "Installing Docker Engine..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -qq
apt-get install -y --no-install-recommends \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin \
  >> "$LOG_FILE" 2>&1

systemctl enable --now docker >> "$LOG_FILE" 2>&1
log "Docker $(docker version --format '{{.Server.Version}}') installed."

# ---------------------------------------------------------------------------
# 6. Pull ReDroid 12 arm64 image
# ---------------------------------------------------------------------------
log "Pulling ReDroid image: $REDROID_IMAGE"
log "  Platform: linux/arm64 (explicit manifest selection)"
docker pull --platform linux/arm64 "$REDROID_IMAGE" >> "$LOG_FILE" 2>&1
log "Image pull complete."

# ---------------------------------------------------------------------------
# 7. Run minimal L0a baseline container
# ---------------------------------------------------------------------------
log "Starting ReDroid L0a baseline container..."

# Create a tmpfs overlay for /proc/cpuinfo (basic arm64 profile)
# No SpoofStack modules here — this is the bare baseline probe
docker run -d \
  --name "$REDROID_CONTAINER_NAME" \
  --privileged \
  --platform linux/arm64 \
  --device /dev/binder \
  --restart unless-stopped \
  -p 5555:5555 \
  -e "ro.product.model=Pixel 7 Pro" \
  -e "ro.product.manufacturer=Google" \
  -e "ro.build.version.release=12" \
  -e "ro.build.id=SP1A.210812.016" \
  "$REDROID_IMAGE" \
  redroid.width=1080 redroid.height=1920 redroid.fps=30 \
  >> "$LOG_FILE" 2>&1

log "Container started. Waiting for Android to boot (up to ${PROBE_TIMEOUT_SECONDS}s)..."

# Poll for Android to become responsive
BOOT_WAITED=0
BOOT_POLL_INTERVAL=5
ANDROID_BOOTED=false
while [ $BOOT_WAITED -lt $PROBE_TIMEOUT_SECONDS ]; do
  BOOT_PROP=$(docker exec "$REDROID_CONTAINER_NAME" \
    getprop sys.boot_completed 2>/dev/null || true)
  if [ "$BOOT_PROP" = "1" ]; then
    ANDROID_BOOTED=true
    log "Android boot_completed after ${BOOT_WAITED}s"
    break
  fi
  sleep $BOOT_POLL_INTERVAL
  BOOT_WAITED=$((BOOT_WAITED + BOOT_POLL_INTERVAL))
done

if [ "$ANDROID_BOOTED" != "true" ]; then
  log "ERROR: Android did not boot within ${PROBE_TIMEOUT_SECONDS}s"
  docker logs "$REDROID_CONTAINER_NAME" >> "$LOG_FILE" 2>&1
  exit 1
fi

# ---------------------------------------------------------------------------
# 8. Run BuildFingerprintProbe smoke test
# ---------------------------------------------------------------------------
log "Running BuildFingerprintProbe..."

TIMESTAMP=$(date -u '+%Y%m%dT%H%M%SZ')
RESULT_FILE="$RESULTS_DIR/baseline-${TIMESTAMP}.json"

# Collect probe data from within the container
BUILD_FINGERPRINT=$(docker exec "$REDROID_CONTAINER_NAME" \
  getprop ro.build.fingerprint 2>/dev/null || echo "UNAVAILABLE")
PRODUCT_MODEL=$(docker exec "$REDROID_CONTAINER_NAME" \
  getprop ro.product.model 2>/dev/null || echo "UNAVAILABLE")
BUILD_VERSION=$(docker exec "$REDROID_CONTAINER_NAME" \
  getprop ro.build.version.release 2>/dev/null || echo "UNAVAILABLE")
CPU_ABI=$(docker exec "$REDROID_CONTAINER_NAME" \
  getprop ro.product.cpu.abi 2>/dev/null || echo "UNAVAILABLE")
HOST_ARCH=$(uname -m)
HOST_KERNEL=$(uname -r)
LIBHOUDINI_PRESENT="false"
if docker exec "$REDROID_CONTAINER_NAME" \
    test -f /system/lib/arm64/libhoudini.so 2>/dev/null; then
  LIBHOUDINI_PRESENT="true"
fi

# Write structured JSON result
cat > "$RESULT_FILE" << EOF
{
  "probe_run": {
    "timestamp": "${TIMESTAMP}",
    "phase": "0.5-arm-smoketest",
    "host_arch": "${HOST_ARCH}",
    "host_kernel": "${HOST_KERNEL}",
    "redroid_image": "${REDROID_IMAGE}",
    "container_name": "${REDROID_CONTAINER_NAME}"
  },
  "build_fingerprint_probe": {
    "ro.build.fingerprint": "${BUILD_FINGERPRINT}",
    "ro.product.model": "${PRODUCT_MODEL}",
    "ro.build.version.release": "${BUILD_VERSION}",
    "ro.product.cpu.abi": "${CPU_ABI}"
  },
  "arch_traps": {
    "libhoudini_present": ${LIBHOUDINI_PRESENT},
    "expected_libhoudini_present_on_arm64": false,
    "trap1_cleared": $([ "${LIBHOUDINI_PRESENT}" = "false" ] && echo true || echo false)
  },
  "smoke_pass": $([ "${BUILD_FINGERPRINT}" != "UNAVAILABLE" ] && \
                  [ "${LIBHOUDINI_PRESENT}" = "false" ] && echo true || echo false)
}
EOF

log "Probe result written to: $RESULT_FILE"
log "smoke_pass=$(jq -r '.smoke_pass' "$RESULT_FILE")"

# ---------------------------------------------------------------------------
# 9. Push results to shared storage (git or S3)
# ---------------------------------------------------------------------------
if [ -n "$RESULTS_GIT_REPO" ]; then
  log "Pushing results to git repo: $RESULTS_GIT_REPO"
  WORK_DIR="/opt/redroid-smoketest/git-push"
  # Operator must pre-configure git credentials via Hetzner secrets
  # This script only stages the push — credentials injected at runtime
  git clone "$RESULTS_GIT_REPO" "$WORK_DIR" >> "$LOG_FILE" 2>&1
  cp "$RESULT_FILE" "$WORK_DIR/baselines/$(basename "$RESULT_FILE")"
  git -C "$WORK_DIR" add "baselines/$(basename "$RESULT_FILE")"
  git -C "$WORK_DIR" commit -m "chore(arm-smoketest): baseline ${TIMESTAMP} from CAX11"
  git -C "$WORK_DIR" push >> "$LOG_FILE" 2>&1
  log "Results pushed."
else
  log "RESULTS_GIT_REPO not set — results remain local at $RESULT_FILE"
  log "Retrieve manually: scp root@\$(hcloud server ip cax11-arm-smoketest):$RESULT_FILE ."
fi

# ---------------------------------------------------------------------------
# 10. Summary
# ---------------------------------------------------------------------------
log "Bootstrap complete."
log "  Container:    $REDROID_CONTAINER_NAME (running)"
log "  Result file:  $RESULT_FILE"
log "  smoke_pass:   $(jq -r '.smoke_pass' "$RESULT_FILE")"
log "  Arch traps:   trap1_libhoudini=$(jq -r '.arch_traps.trap1_cleared' "$RESULT_FILE")"
log ""
log "Next steps:"
log "  1. Compare result against amd64 baseline with scripts/baseline-diff.py"
log "  2. If smoke_pass=true and drift <5%, proceed to Phase 1 (5x CAX41)"
log "  3. Destroy this node when no longer needed: hcloud server delete cax11-arm-smoketest"
