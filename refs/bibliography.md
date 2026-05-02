# Bibliography & Reference Sources

## Akademisch / Forschung

| Quelle | Typ | Relevanz |
|---|---|---|
| Cryptomathic (2025): "Securing Mobile Banking Apps in 2025: Stay Ahead of Emulator Attacks" | Industry Whitepaper | Threat model baseline |
| Forbes Doffman (2025): Google device tracking | News | Attestation context |
| Multilogin: "Cloud Phones vs Mobile Emulators" | Industry Blog | Comparative baseline |
| VMOS Cloud: "Advanced Anti-Fingerprint Tactics" | Industry Blog | Mitigation taxonomy |

## OSS-Detection-Baselines

| Repo | Beschreibung |
|---|---|
| github.com/trustdecision/trustdevice-android | Kommerzielle Android Device Fingerprinting OSS |
| github.com/happylishang/AntiFakerAndroidChecker | Emulator detection patterns library |
| github.com/m0mosenpai/instadamn | Instagram-spezifische decompiled probe analysis |

## OSS-Mitigation-Module (referenziert, nicht in DetectorLab integriert)

| Repo | Layer |
|---|---|
| github.com/yubunus/DeviceSpoofLab-Hooks | L1 |
| github.com/yubunus/DeviceSpoofLab-Magisk | L1 |
| github.com/Android1500/AndroidFaker | L2 |
| github.com/osm0sis/PlayIntegrityFork | L3 |
| github.com/EricInacio01/PlayIntegrityFix-NEXT | L3 alt |
| github.com/5ec1cff/TrickyStore | L3 |
| github.com/LSPosed/LSPosed.github.io (Shamiko) | L4 |
| github.com/Dr-TSNG/Hide-My-Applist | L4 |
| github.com/Frazew/VirtualSensor | L5 |
| github.com/Xposed-Modules-Repo/eu.faircode.xlua (XPrivacyLua) | L4-fallback |
| github.com/ThePieMonster/HideMockLocation | L4 |
| github.com/noobexon1/XposedFakeLocation | L4 |
| github.com/JingMatrix/LSPosed | L0 |
| github.com/LSPosed/CorePatch | L4 |

## Plattform-Dokumentation

| Quelle | Inhalt |
|---|---|
| developer.android.com/google/play/integrity | Play Integrity API |
| source.android.com/docs/security/features/keystore/attestation | Keystore Attestation |
| developer.android.com/training/articles/user-data-ids | Android User Data IDs |

## Citation-Format (BibTeX)

```bibtex
@misc{trustdecision_trustdevice,
  title  = {trustdevice-android: An Open-Source Device Fingerprinting Library},
  author = {Trustdecision},
  year   = {2024},
  url    = {https://github.com/trustdecision/trustdevice-android}
}

@misc{lsposed_jingmatrix,
  title  = {LSPosed Framework Maintenance Fork},
  author = {{JingMatrix}},
  year   = {2025},
  url    = {https://github.com/JingMatrix/LSPosed}
}
```

## Zu ergaenzen waehrend des Projekts

- Konferenz-Papers zu Android Anti-Fraud (USENIX, CCS, NDSS Suchen)
- Google Play Protect Whitepapers
- ARM TrustZone Whitepapers
