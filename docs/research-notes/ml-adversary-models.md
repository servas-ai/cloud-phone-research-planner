# Research Note: ML-Based Fraud-Detection Adversary Models

Date: 2026-05-03
Author: autoresearch subagent (Claude Opus 4.7, 1M ctx)
Triggered by: Finding F6 (plans/05-validation-feedback.md)
Status: DRAFT — input for Round-2 threat-model addendum

## 1. SDK Landscape (2024–2026)

| SDK / Vendor | ML Architecture (public claims) | Signal Classes | Public References |
|---|---|---|---|
| **SHIELD** | "Feature AI Engine" — proprietary; 20+ tunable signals + real-time session monitoring; tabular classifier (per Forrester TEI 2023) | device-id persistence, tampering, session behavior, "good user turns bad" delta | shield.com/products/feature-ai-engine |
| **Fingerprint.com Pro** | "Suspect Score" = weighted ensemble of Smart Signals; per-tenant weight optimization on customer-uploaded labels | 35+ raw attrs, VPN, IP geo, incognito, Frida, factory-reset, emulator, cloned-app, MitM, tampered-request, velocity (3 windows) | fingerprint.com/products/smart-signals |
| **Castle** | Risk-score per session; multi-signal scoring + downstream "delayed enforcement"; tabular ML + edge SDK | velocity, email-domain risk, device fp, behavior anomalies | blog.castle.io (2026 research posts) |
| **TrustDecision / TrustDevice** | OSS lib + Pro SaaS; `device_risk_label` boolean ensemble → Pro: risk score + "Behavioral Activity Capturing" | 70+ attrs incl. MediaDRM ID, vbMetaDigest, sensorsInfo, batteryTotalCapacity, kernelVersion, appList | github.com/trustdecision/trustdevice-android |
| **Sift** | Global model + tenant-specific gradient boosting; cross-customer signal sharing | device + behavior + network + identity graph; 16k+ signals claimed | Sift product pages, G2 |
| **Appdome** | "ThreatScope™" + "Threat-Events" classifier; on-device RASP rules + cloud ML | root, jailbreak, Frida, modding, MitM, deepfake, geo-fraud, trojans | appdome.com (Mobile Defense, 2025) |
| **ThreatMetrix (LexisNexis)** | "Digital Identity Network": rules + supervised ML on cross-customer device graph; >70 attrs | device, IP, identity-link, velocity | LexisNexis whitepapers; US Pat 11,392,927 family |
| **BehavioSec (LexisNexis)** | Continuous behavioral biometrics — per-user anomaly + global classifier | touch dynamics, tap-pressure, scroll, accelerometer micro-tremor | LexisNexis acquisition 2022; keystroke patents |
| **Iovation FraudForce (TransUnion)** | Reputation-graph + supervised ML on device-association graph | device fp, association graph, evidence-of-fraud labels | TransUnion product page |
| **Cleafy / Castle behavioral overlay** | LSTM/Transformer on session-event sequences | session timing, micro-pattern sequences | Castle 2026 research, Cleafy threat-intel |

**Common architecture:** on-device SDK collects probe-vector → encrypted "blackbox" payload → server scoring stack (2-tier: GBT on tabular + GNN/sequence on graph/temporal). TrustDevice's `getBlackbox()` JSON is the most concrete public probe-vector format.

## 2. Signal Cross-Correlation Patterns

Single-probe spoofing is defeated by **consistency checks across orthogonal signals**:

| # | Pair / Triple | Defeats single-probe spoof because |
|---|---|---|
| C1 | `Build.MODEL` ↔ `MediaDrm widevine UID prefix` ↔ `Build.HARDWARE` | Widevine UID encodes SoC vendor; mismatch flags spoof |
| C2 | `Sensor FFT spectrum` ↔ model-specific accelerometer profile DB | Each model has characteristic noise floor; synthetic traces lack it |
| C3 | `Battery temperature` × `CPU time-series` × `screenBrightness` | Real device thermo-electrical coupling; emulator is flat |
| C4 | `IP-ASN geo` ↔ `SIM MCC/MNC` ↔ `SystemTimeZone` ↔ `WiFi BSSID OUI` | Geo consistency across stack; VPN trips ≥1 axis |
| C5 | `kernelVersion` ↔ `vbMetaDigest` ↔ `Build.FINGERPRINT` ↔ Play Integrity | Custom ROM mismatches integrity manifest |
| C6 | `installed-app-list hash` ↔ cross-tenant device-graph | Same app-list across "distinct" devices = farm |
| C7 | `Touch jitter (X/Y,dt)` ↔ `Accelerometer co-variance` | Real fingers couple hand-tremor into IMU; bots don't |
| C8 | `ro.kernel.qemu*` × `BogoMIPS` × `GPU renderer string` | Classic emulator triple |
| C9 | `Factory-reset ts` ↔ `MediaDRM ID stability` ↔ `gsfId age` | Reset+new IDs+new gsfId = farm-rotation pattern |
| C10 | `Login velocity` × `device-graph degree` × `account-age` | Server-side; out-of-scope for L_AdvB |

C1–C9 typically feed feature-engineered inputs to a tabular GBT (XGBoost/LightGBM); not learned end-to-end.

## 3. Academic Papers 2023–2026

| Cite | Venue | Relevance |
|---|---|---|
| Cai et al. (2024) "FAMOS: Privacy-Preserving Auth on Payment Apps via Federated Multi-Modal Contrastive Learning" | USENIX Sec '24 | **HIGH** — federated multi-modal sensor fusion (Ant Group production). F1=0.91 / AUC=0.97. Evidence of deployed L_AdvC. |
| "Power-Related Side-Channel Attacks using the Android Sensor Framework" | NDSS 2025 | **HIGH** — sensor-API side-channel; ML adversary could use it defensively to detect virtualization. |
| Lievonen et al. (2024) arXiv:2403.03832 — "Your device may know you better than you know yourself" | arXiv 2024 | **MED** — RF/KNN/SVC on touch + sensor; benchmark for L_AdvB. |
| ATLAS (2025) arXiv:2509.20339 — Spatio-Temporal Directed Graph Learning for ATO Fraud Detection | arXiv 2025 | **HIGH** — XGBoost baseline vs. ST-GNN on session graph; production banking ATO. |
| Mohamed et al. arXiv:2001.08578 "Sensor-based Continuous Auth: Survey" | arXiv 2020 | **MED** — taxonomy for L_AdvC. |
| FP-Fed (2024) "Privacy-Preserving Federated Detection of Browser Fingerprinting" | NDSS 2024 | **MED** — defender-side federated learning. |
| Truman (2025) "Constructing Device Behavior Models from OS Drivers to Fuzz Virtual Devices" | NDSS 2025 | **MED** — virtual-device fingerprinting from driver state. |
| Salem et al. arXiv:1709.00875 "EMULATOR vs REAL PHONE: ML Detection" | arXiv 2017 | **LOW (dated)** — foundational; simple-feature ML separates emulator vs real. |
| Cleafy / Group-IB threat-intel (2024–2025) | industry | **MED** — Brokewell, BingoMod, GodFather reports describe vendor RASP+ML stacks they bypass. |

## 4. Server-Side Layer (out-of-scope — acknowledged)

Vendors run a **second-stage server model** that on-device probes cannot influence:

- **Account-graph clustering** (Iovation, ThreatMetrix, Sift): cross-customer device→account edges.
- **Login-velocity & geo-impossible-travel** (all): session-sequence anomaly.
- **Cross-tenant signal sharing** (Sift global model, LexisNexis Digital ID Network): fp seen on competitor's fraud-list.
- **Spatio-temporal GNNs on session graphs** (ATLAS): production banking ATO.

These require real-target deployment (out of scope for measurement-only DetectorLab). Treat as adversary that **strictly dominates** on-device-only spoofing.

## 5. Proposed Threat-Model Addition

Add to `docs/threat-model.md` after §"Akteure":

```markdown
## Adversary Capability Axis

| Level | Adversary Type | Detection Mechanism | Spoofable by SpoofStack? |
|---|---|---|---|
| L_AdvA | Static Rule-Based | If/else on probe values (e.g. `Build.FINGERPRINT contains "generic"`) | Yes — L1 (Build-Spoof) suffices |
| L_AdvB | ML Classifier on Probe-Vector | XGBoost/LightGBM on 50–200 tabular features incl. cross-correlations C1–C9 | Partial — requires L1+L2+L3+L4 coherently |
| L_AdvC | Deep ML on Sensor Traces | CNN/RNN/Transformer on raw 30s windows (accelerometer, gyro, touch, timing) | Mostly no — requires L5 trace-replay AND C7-style coupling |

## STRIDE × Adversary-Level Matrix

| Vektor | L_AdvA defeated by | L_AdvB defeated by | L_AdvC defeated by |
|---|---|---|---|
| Build Fingerprint | L1 | L1 + C5 coherence | L1+L5 |
| Play Integrity | L3 (Keybox) | L3 + L4 GMS coherence | L3+L4+L5 |
| Sensor FFT | L5 stub | L5 + C2 model-DB | L5 high-fidelity trace + behavior |
| IP/ASN | L6 mobile-egress | L6 + C4 timezone+SIM | + per-account session-graph (out-of-scope) |
```

Plus add to §"Vertrauensanker":
```
| On-Device ML Ensemble | partial — feature-engineered, requires multi-layer coherence | break C1–C9 simultaneously |
| Server-Side Behavioral Analytics | nein (out-of-scope) | nicht adressierbar — methodological boundary |
```

## 6. Implications for SpoofStack L1–L6

| Layer | vs L_AdvA | vs L_AdvB | vs L_AdvC |
|---|:-:|:-:|:-:|
| L1 Build/Property Spoof | ✓ | partial (needs C1,C5 coherence) | ✗ |
| L2 File-System Spoof | ✓ | partial | ✗ |
| L3 Keybox + Play Integrity | ✓ | ✓ (if Strong + valid keybox) | ✓ |
| L4 GMS / Account Coherence | n/a | ✓ | ✓ |
| L5 Sensor-Trace Replay | ✓ | partial (needs C2,C7) | ✗ unless coupled multi-modal trace |
| L6 Network Egress (Mobile) | ✓ | ✓ (if C4 holds) | ✓ |

**Key finding:** L1, L2, L5 alone fail under L_AdvB because they probe single signals without enforcing cross-correlations C1–C9. The paper's contribution must therefore include a **coherence metric** measuring how tightly probes co-vary, not just per-probe pass/fail. This implies an additional measurement axis in `plans/03-experiment-matrix.md` (probe-vector export for offline ML eval, as F6's Korrektur already requested).

## 7. Open Questions for Human Partner

1. Should H1–H4 be extended with H5: "SpoofStack L1–L6 detection-rate against L_AdvB ML classifier is monotonically lower than against L_AdvA"? (Re-registration cost: medium.)
2. For L_AdvC evaluation, can we collect a small real-device sensor-trace baseline (e.g. n=5 lab phones)? Without this we cannot train a representative L_AdvC adversary.
3. Should we acknowledge server-side adversaries (§4) explicitly in `threat-model.md` as a "deliberate research boundary"?
4. Is the 3-level axis (A/B/C) sufficient, or do we want a fourth `L_AdvD` for federated-cross-tenant ML (Sift / LexisNexis network effect)?
5. Will the lab build a reference "mini-classifier" (XGBoost on probe-vector) inside DetectorLab as a *measurement instrument* — or only export probe-vectors for offline analysis (safer scope-wise)?

---

ready for Round-2-feedback consolidation? Y/N
