# SpoofStack — Layer-Spezifikationen

## L0 — Container Baseline

| Komponente | Version | Quelle |
|---|---|---|
| ReDroid | 12.0.0_64only-latest | docker.io/redroid/redroid |
| Magisk | v27.2 | github.com/topjohnwu/Magisk |
| ReZygisk | v1.3.4+ | gitlab.com/PerformanC/ReZygisk |
| LSPosed (JingMatrix) | v1.10.1 | github.com/JingMatrix/LSPosed |

**Konfiguration:**
- Built-in Zygisk: AUS (verwendet ReZygisk)
- Enforce DenyList: AUS (Shamiko uebernimmt)
- Host: ARM64 Bare-Metal oder Apple Silicon
- Binder: max 4 Container pro binder-Device

**docker-compose.yml Stub:**
```yaml
services:
  redroid:
    image: redroid/redroid:12.0.0_64only-latest
    devices:
      - /dev/binder:/dev/binder
      - /dev/ashmem:/dev/ashmem
    privileged: true
    command:
      - androidboot.redroid_gpu_mode=host
      - androidboot.redroid_width=1080
      - androidboot.redroid_height=2400
      - androidboot.redroid_dpi=420
      - androidboot.redroid_fps=60
      - ro.product.brand=google
      - ro.product.model=Pixel 7
      - ro.product.manufacturer=Google
```

## L1 — Build Properties

| Modul | Zweck | Probes |
|---|---|---|
| DeviceSpoofLab-Magisk | build.prop-Patches auf Filesystem-Ebene | #4, #7, #13, #28 |
| DeviceSpoofLab-Hooks | API-Level-Property-Hooks (126+ Props) | #1, #9, #27 |

**Target-Profil**: Pixel 7 (panther) auf Android 14, security_patch=2024-08-05.

## L2 — Identity Spoofing

| Modul | Zweck | Probes |
|---|---|---|
| Android Faker | IMEI, Android ID, MAC, BT-MAC, SSID, MediaDRM, SIM, Operator | #11, #12, #15, #16, #17, #21, #22, #29, #31, #32 |

**Konfiguration**: Pro App-Profil unique IDs, persistente Speicherung.

## L3 — Integrity & Attestation

| Modul | Zweck | Probes |
|---|---|---|
| PlayIntegrityFork v15 | BASIC + DEVICE Verdict | #2 |
| TrickyStore v1.3.0 | STRONG Verdict via Keybox | #2, #6 |

**Reihenfolge**: PIF zuerst flashen, dann TrickyStore. Keybox als XML in `/data/adb/tricky_store/keybox.xml`.

## L4 — Runtime Hiding

| Modul | Zweck | Probes |
|---|---|---|
| Shamiko | Zygisk + Magisk + Module hiding | #3, #8, #14 |
| HideMyAppList | Package-list filtering | #10, #19, #50 |

**Konfiguration**: DenyList per Whitelist-Modus, nur DetectorLab in der Liste (im Lab).

## L5 — Sensor Emulation

| Modul | Zweck | Probes |
|---|---|---|
| VirtualSensor (modifiziert) | Sensor-Daten injizieren | #24, #42-45 |
| Trace-Player (Eigenentwicklung) | Reale Sensor-Traces abspielen | #24 |

**Trace-Source**: 10-Minuten-Aufnahme von Pixel 7 in Tasche, Hand, Tisch — als CSV-Sequenz.

## L6 — Network Egress

| Komponente | Zweck | Probes |
|---|---|---|
| Lab-LTE-Modem | Mobile-Carrier-IP | #5, #25 |
| iptables-NAT-Gateway | Container-Egress -> LTE | #18, #38 |
| Lokale DNS (1.1.1.1) | Realistische DNS | #37 |

**Setup**: USB-LTE-Stick am Host mit eigenem APN, DHCP an Container reicht IP weiter.

## Validierungs-Reihenfolge

1. L0 messen -> Baseline
2. L1 hinzu -> messen -> Delta dokumentieren
3. L1+L2 -> messen -> Delta
4. L1+L2+L3 -> messen -> Delta
5. L1+L2+L3+L4 -> messen -> Delta
6. L1+L2+L3+L4+L5 -> messen -> Delta
7. Vollstack (+L6) -> messen -> Delta

Pro Schritt: 30 Runs, Image-Snapshot, manifest.yml.
