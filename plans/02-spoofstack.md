# Track B — SpoofStack

Modular zuschaltbarer Mitigation-Stack auf Basis ReDroid 12 ARM64. **Subject Under Test**, nicht Produktions-Tool. Jeder Layer wird einzeln gegen DetectorLab vermessen.

## Plattform-Entscheidung (aus Recherche-Tabelle)

| Kriterium | Entscheidung | Begruendung |
|---|---|---|
| Container | ReDroid 12.0.0_64only-latest | Stabilster Stack laut Community-Reports |
| Host | ARM64 (Ampere oder Apple Silicon Mac mini) | Vermeidet x86-Translation-Artefakte (Probe #27) |
| Magisk | v27+ | Kompatibilitaet mit ReZygisk |
| Zygisk | ReZygisk | Built-in Zygisk + LSPosed instabil (Konflikt-Tabelle) |
| LSPosed | JingMatrix v1.10.1 | A12-A15 kompatibel |

## Layer-Definition

| Layer | Name | Modul / Komponente | Adressiert Probes |
|---|---|---|---|
| L0 | Container Baseline | ReDroid 12 ARM64 + Magisk + ReZygisk + LSPosed | (none — Baseline-Messung) |
| L1 | Build Properties | DeviceSpoofLab-Magisk + DeviceSpoofLab-Hooks | #1, #7, #9, #13, #27, #28 |
| L2 | Identity Spoofing | Android Faker | #11, #12, #15, #16, #17, #21, #22, #29, #31, #32 |
| L3 | Integrity & Attestation | PlayIntegrityFork v15 + TrickyStore v1.3.0 + Keybox | #2, #6 |
| L4 | Runtime Hiding | Shamiko + HideMyAppList | #3, #8, #10, #14, #19, #50 |
| L5 | Sensor Emulation | VirtualSensor + Realgeraet-Trace-Player (Eigenentwicklung) | #24, #42, #43, #44, #45 |
| L6 | Network Egress | Lab-LTE-Modem als NAT-Gateway | #5, #18, #20, #37 |

## Snapshot-Strategie

Jede Layer-Kombination als immutable Container-Image:

```
spoofstack-images/
|-- L0-baseline.img.xz
|-- L0-L1.img.xz
|-- L0-L1-L2.img.xz
|-- L0-L1-L2-L3.img.xz
|-- L0-L1-L2-L3-L4.img.xz
|-- L0-L1-L2-L3-L4-L5.img.xz
`-- L0-L1-L2-L3-L4-L5-L6.img.xz   # full-stack
```

Versioniert via `manifest.yml`:

```yaml
image: L0-L1-L2-L3-L4
created: 2026-05-20
modules:
  redroid: 12.0.0_64only-2026-05-15
  magisk: v27.2
  rezygisk: v1.3.4
  lsposed: jingmatrix-v1.10.1
  device-spoof-lab-magisk: v2.1.0
  device-spoof-lab-hooks: v2.1.0
  android-faker: v8.7
  play-integrity-fork: v15
  tricky-store: v1.3.0
  shamiko: v1.1.1
  hide-my-applist: v3.5
spoof-target:
  brand: google
  model: Pixel 7
  fingerprint: google/panther/panther:14/...
```

## Konflikt-Vermeidung (aus Recherche-Tabelle)

| Konflikt | Loesung in Stack |
|---|---|
| Zygisk + LSPosed | Built-in Zygisk AUS, ReZygisk EIN |
| Shamiko + Enforce DenyList | Enforce DenyList in Magisk DEAKTIVIEREN |
| PIF + ROM-Spoofing | Keine Custom-ROM-Spoofs, nur PIF |
| TrickyStore ohne PIF | Reihenfolge: PIF zuerst, dann TrickyStore |
| DeviceSpoofLab-Magisk + MagiskHidePropsConf | Nur DeviceSpoofLab-Magisk verwenden |

## Aufbau-Sprints

### Sprint A (Woche 3) — Baseline
- [ ] Host-Server provisionieren (ARM64, mind. 16 GB RAM)
- [ ] ReDroid 12 docker-compose lauffaehig
- [ ] Magisk + ReZygisk + LSPosed installiert
- [ ] DetectorLab APK installierbar
- [ ] Baseline-Run dokumentiert

### Sprint B (Woche 4) — L1 + L2
- [ ] DeviceSpoofLab-Magisk + Hooks konfiguriert (Pixel 7 Target)
- [ ] Android Faker konfiguriert
- [ ] Re-Run + Delta dokumentieren

### Sprint C (Woche 5) — L3 + L4
- [ ] PIF + TrickyStore installiert
- [ ] Keybox aus oeffentlich dokumentierter Quelle (akademisch zitiert)
- [ ] Shamiko + HideMyAppList konfiguriert
- [ ] Re-Run + Delta

### Sprint D (Woche 6) — L5 + L6
- [ ] Sensor-Trace von Pixel 7 aufzeichnen (eigenes Geraet, 10 Min Acceleration + Gyro)
- [ ] Trace-Player als VirtualSensor-Backend
- [ ] Lab-LTE-Modem als NAT-Gateway konfiguriert
- [ ] Vollstack-Run

## Risiken

| Risiko | Mitigation |
|---|---|
| Keybox wird von Google revoked | Mehrere Keyboxen testen, Datum jedes Tests im Manifest |
| ReDroid 12 neue Build-Version aendert Verhalten | Image-Hash pinnen |
| LTE-Modem rotiert IP haeufig | Sticky-IP-Provider oder eigener APN |
