# Glossar

| Begriff | Erklaerung |
|---|---|
| **ARM-native Container** | Container, der auf ARM64-Host laeuft, ohne x86-Translation. Vermeidet Probe #27. |
| **Attestation** | Kryptographischer Nachweis von Geraete-Eigenschaften durch eine Trust Authority. |
| **CTS Profile** | Compatibility Test Suite — Googles Geraete-Profil zur Play Integrity. |
| **DenyList** | Magisks Liste von Apps, vor denen Root versteckt werden soll. |
| **Detection-Score** | DetectorLab-Wert 0.0–1.0, wo 0 = echt und 1 = sicher detektiert. |
| **Fingerprint** | `ro.build.fingerprint` — eindeutige String-Identitaet eines Builds. |
| **Heatmap** | 2D-Matrix-Plot, hier Probes x Konfigurationen, eingefaerbt nach Score. |
| **Hookable** | Per LSPosed/Frida abfangbarer Funktionsaufruf. |
| **Keybox** | XML-Datei mit Hardware-Attestation-Cert-Chain, die TrickyStore zur StrongBox-Spoof nutzt. |
| **L0–L6** | Mitigation-Layer im SpoofStack, additive Konfigurationen. |
| **MobileRun AI / ReadRun** | Cloud-Phone-Plattformen, die ReDroid als Backend nutzen. |
| **Probe** | Ein einzelner Detection-Test in DetectorLab. 60 Stueck nach Recherche-Liste. |
| **ReDroid** | Open-Source Android-in-Container-Projekt. Hauptplattform dieses Forschungsprojekts. |
| **Residential Proxy** | Egress-IP einer privaten Wohnung. Hier nicht verwendet — Lab nutzt eigenes LTE. |
| **Sensor FFT** | Fast-Fourier-Transformation der Sensor-Zeitreihe. Detektiert kuenstliche Signale. |
| **SpoofStack** | Hier definierter Mitigation-Stack (L0–L6). |
| **STRIDE** | Threat-Modeling-Framework: Spoofing/Tampering/Repudiation/Info-Disclosure/DoS/Elevation. |
| **TEE** | Trusted Execution Environment, Hardware-Sicherheitsbereich (z.B. ARM TrustZone). |
| **Trace-Player** | Eigenentwicklung: spielt aufgenommene Sensor-Zeitreihen eines Realgeraets ab. |
| **Verdict** | Antwort der Play Integrity API: BASIC / DEVICE / STRONG. |
| **Zygisk / ReZygisk** | Magisk-Modus zur Code-Injektion in den Zygote-Prozess. |
