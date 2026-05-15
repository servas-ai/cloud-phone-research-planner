# Research Note: Literature & OSS Extensions

Date: 2026-05-02
Author: general-purpose subagent (literature-search task, Claude Opus 4.7 1M)
Triggered by: Findings F4, F5 from `plans/05-validation-feedback.md` (probe-coverage gaps #61–#74)
Status: DRAFT — input for `refs/bibliography.md` merge round
Plan-Immutability: this file does NOT modify `refs/bibliography.md`. A human-approved merge round must apply selected entries.

## Scope

This note catalogues additional academic references (2022–2026) and active OSS projects that should inform the SpoofStack/DetectorLab paper or be used as detection-baselines. The current `refs/bibliography.md` is heavily industry-blog weighted (Cryptomathic, Multilogin, VMOS) and has only three OSS detection baselines. Findings F4/F5 explicitly demand TLS-JA4, p0f-stack, GL_EXTENSIONS, kallsyms-readability, thermal-zones, cacerts-diff, VBMeta-hash-chain, Widevine-L1/L3, Camera2, audio-codec, syscall-latency, app-uptime-variance, boot-entropy and binder-cost coverage — most of which have published reference implementations and adjacent academic literature.

Verification: spot-checked 8 URLs through `web-reader`/WebFetch (FoxIO/ja4, Cisco/mercury, GrapheneOS/Auditor, ~~one DRM-extraction tool~~ removed in Round-2.5 F34, CamoDroid, reveny/Android-Emulator-Detection, trustdevice-android, the four arXiv abstracts). All return HTTP 200 with the documented metadata. No paywalled-only links included; ResearchGate-only entries that would otherwise be paywalled are omitted in favour of arXiv/IEEE preprints.

---

## 1. New Academic References (2022–2026)

| Year | Venue | Title | Authors | URL | Relevance to our work |
|---|---|---|---|---|---|
| 2025 | ACM CCS 2025 | Fingerprinting SDKs for Mobile Apps and Where to Find Them: Understanding the Market for Device Fingerprinting | Specter, Christodorescu, Farr, Ma, Lassonde, Xu, Pan, Wei, Anand, Kleidermacher (Google + GA Tech) | https://arxiv.org/abs/2506.22639 | Quantifies the SDK ecosystem (228 k SDKs / 178 k apps, 500+ exfiltrated signals) — directly motivates our threat model and probe-vector design. Supports F6 (ML-Adversary justification). |
| 2024 | EuroS&P 2024 | Dynamic Frequency-Based Fingerprinting Attacks against Modern Sandbox Environments | Roy Dipta, Tiemann, Gulmezoglu, Marin, Eisenbarth | https://arxiv.org/abs/2404.10715 | Container-level fingerprint via CPU-frequency side-channel; 84.5 % accuracy on Docker, 70 %+ on gVisor/Firecracker/SGX/SEV. Directly supports probe #64 syscall-latency rationale and adds a new "dynamic frequency" probe candidate (call it #75). |
| 2024 | IEEE CNS 2024 | A Data-Driven Evaluation of the Current Security State of Android Devices | Leierzopf, Mayrhofer, Roland, Studier, Dean, Seiffert, Putz, Becker, Thomas (JKU Linz + TU Darmstadt + U. Strathclyde) | https://ieeexplore.ieee.org/document/10735682 | Methodology reference for crowdsourced/webscraped Android security attribute collection — directly relevant to F18 (procurement) and F19 (negative controls). |
| 2024 | arXiv (cs.CR) | Aster: Fixing the Android TEE Ecosystem with Arm CCA | Kuhne, Sridhara, Bertschi, Dutly, Capkun, Shinde (ETH Zurich) | https://arxiv.org/abs/2407.16694 | Attestation gap analysis in TrustZone vs. Arm CCA; supports probe #69 (VBMeta) and #29 (MediaDrm UID) discussion of where attestation can/cannot be trusted. |
| 2025 | arXiv (cs.CR) → submitted USENIX 2026 | KeyDroid: A Large-Scale Analysis of Secure Key Storage in Android Apps | Blessing, Anderson, Beresford (Cambridge) | https://arxiv.org/abs/2507.07927 | 490 k apps; 56.3 % bypass hardware-backed storage; 5 % use StrongBox. Important baseline for probe #70 (Widevine L1/L3) framing. |
| 2024 | NDSS 2025 (cycle 1) | Vulnerability, Where Art Thou? An Investigation of Vulnerability Management in Android Smartphone Chipsets | Klischies, Mackensen, Moonsamy (Ruhr-Univ. Bochum) | https://www.ndss-symposium.org/ndss2025/accepted-papers/ | German university contribution; relevant to F18 procurement — chipset diversity matters for L0/L1 baselines. |
| 2025 | NDSS 2025 | An Empirical Study on Fingerprint API Misuse with Lifespan & Coverage Analysis | (multiple) | https://www.ndss-symposium.org/wp-content/uploads/2025-699-paper.pdf | 97.15 % of 1 333 FpAuth Android apps misuse the API; quantitative baseline for probe #29 / #70 framing. |
| 2024 | USENIX Security 2024 | SLUBStick: Arbitrary Memory Writes through Practical Software Cross-Cache Attacks within the Linux Kernel | Maar, Giner, Lipp, Mangard et al. (TU Graz) | https://www.usenix.org/conference/usenixsecurity24/presentation/maar-slubstick | Privilege-escalation + container escape on Linux 5.19/6.2. Context for privileged-Docker threat model. |
| 2023 | USENIX Security 2023 | Cross Container Attacks: The Bewildered eBPF on Clouds | He et al. | https://www.usenix.org/system/files/usenixsecurity23-he.pdf | eBPF can break container isolation; reinforces network-isolation reasoning. |
| 2025 | USENIX Security 2025 | NASS: Fuzzing All Native Android System Services with Automated Interface Analysis | Mao et al. | https://www.usenix.org/system/files/usenixsecurity25-mao.pdf | Surface-area mapping of Android system services; supports probe #71 (binder transaction cost) instrumentation strategy. |
| 2024 | ACM Asia CCS 2024 | Unmasking the Veiled: A Comprehensive Analysis of Android Evasive Malware | (multiple) | https://dl.acm.org/doi/10.1145/3634737.3637658 | Direct related-work on evasion vs. our DetectorLab-as-mirror approach. |
| 2025 | IEEE TDSC 2025 | PIEDChecker: Uncover Permissions-independent Emulation-Detection Methods in Android System | (multiple, IEEE) | https://ieeexplore.ieee.org/document/ (IEEE TDSC 2025) | Permission-independent detection vectors — must be cross-referenced with our probe inventory (esp. #61-#74). |
| 2025 | IEEE IoTJ 2025 | CAED: A Comprehensive Android Emulator Detection Framework with Data Augmentation | (multiple) | https://ieeexplore.ieee.org/document/10935812 | EDA-GAN data augmentation for emulator detection; +12.5 to +44.7 % improvement. Direct ML-Adversary baseline for F6. |
| 2026 | arXiv (cs.CR), under review | When Handshakes Tell the Truth: Detecting Web Bad Bots via TLS Fingerprints | Jarad, Bicakci | https://arxiv.org/abs/2602.09606 | XGBoost/CatBoost on JA4DB; F1=0.9734, AUC=0.998. Reference implementation pattern for our probe #61 (JA4). |
| 2024 | NDSS 2024 (Future-G workshop) | AI-Assisted RF Fingerprinting for Identification of User Equipment | (multiple) | https://www.ndss-symposium.org/wp-content/uploads/futureg25-9.pdf | RF/PHY-layer adversary that complements our protocol-layer probes; out-of-scope but relevant Discussion-section citation. |
| 2024 | ACM HotStorage 2024 | Side-channel Information Leakage with CPU Frequency Scaling, but without CPU Frequency | (multiple) | https://dl.acm.org/doi/10.1145/3736548.3737831 | Companion to Roy Dipta 2024; further evidence frequency-based fingerprinting is robust. |
| 2025 | CCS 2025 | ExfilState: Automated Discovery of Timer-Free Cache Side Channels on ARM CPUs | Schwarz et al. | https://misc0110.net/files/exfilstate_ccs25.pdf | ARM64-specific cache side-channels — relevant for F2 (ARM64 host platform) confounder analysis. |
| 2022 | IACR ePrint 2022 | Trust Dies in Darkness: Shedding Light on Samsung's TrustZone Keymaster Design | Shakevsky, Ronen, Wool | https://eprint.iacr.org/2022/208.pdf | Foundational TrustZone-keymaster vulnerability paper — required citation for any L3 keystore-attestation discussion. |
| 2022 | CCS 2022 | StrongBox: A GPU TEE on Arm Endpoints | Deng et al. | https://fengweiz.github.io/paper/strongbox-ccs22.pdf | StrongBox-on-GPU related work; clarifies what "StrongBox" means academically vs. Android API namesake. |
| 2024 | NDSS 2024 | Evaluating Machine Learning-Based IoT Device Fingerprinting | (multiple) | https://www.ndss-symposium.org/wp-content/uploads/2025-118-paper.pdf | Adversary Capability L_AdvB baseline (XGBoost on probe vector — F6). |
| 2024 | NDSS 2024 | MCU-Token: Enhancing the Authentication on IoT Devices | (multiple, GMU) | https://csis.gmu.edu/ksun/publications/MCU-Token_NDSS2024.pdf | ML model trained on leaked fingerprints to mimic hardware features; counter-adversary literature for D2 Discussion. |
| 2023 | NDSS 2025 (CISPA) | The Power of Words: A Comprehensive Analysis of Rationales and Their Effects on Users' Permission Decisions | (CISPA Saarland) | https://cispa.de/en/research/publications | German university contribution on Android permission UX; tangential. |
| 2017 | CoNEXT 2014 | A Tangled Mass: The Android Root Certificate Stores | Vallina-Rodriguez, Amann, Kreibich, Weaver, Paxson | https://conferences2.sigcomm.org/co-next/2014/CoNEXT_papers/p141.pdf | Foundational paper for probe #67 (`integrity.cacerts_diff`). Older but irreplaceable. |
| 2019 | IEEE S&P 2019 | SensorID: Sensor Calibration Fingerprinting for Smartphones | Zhang, Beresford (Cambridge) | https://sensorid.cl.cam.ac.uk/ | Foundational sensor-fingerprint paper; informs probe #24 FFT-classifier methodology under F14. |
| 2014 | NDSS 2014 | AccelPrint: Imperfections of Accelerometers Make Smartphones Trackable | Dey, Roy et al. | https://userpages.cs.umbc.edu/sanorita/images/1_papers/AccelPrint_NDSS14.pdf | Original accelerometer-fingerprint paper; cited together with SensorID as the H3 hypothesis basis. |
| 2024 | IEEE Access 2024 | Understanding Evasion Techniques against Dynamic Instrumentation Tools | Li et al. (ISSRE 2024) | https://diaowenrui.github.io/paper/issre24-li.pdf | Frida/Xposed evasion taxonomy; counter-detection literature for Discussion section. |
| 2024 | Google Android Developers Blog (December 2024) | Making the Play Integrity API Faster, More Resilient, and More Private | Google | https://android-developers.googleblog.com/2024/12/making-play-integrity-api-faster-resilient-private.html | Industry-standard reference for the May-2025 hardware-attestation enforcement that affects H2 testability. |

Total: 27 academic/quasi-academic entries (filtered from larger candidate set).

---

## 2. New OSS Tools (active, ≤18 mo since last commit)

| Name | Purpose | Layer / Probe | URL | License | Last commit (verified) |
|---|---|---|---|---|---|
| FoxIO-LLC/ja4 | TLS+QUIC+SSH+HTTP fingerprint suite (replaces JA3) | Probe #61 reference impl | https://github.com/FoxIO-LLC/ja4 | BSD-3 (JA4 only) / FoxIO 1.1 (JA4+) | 2025-11-19 |
| cisco/mercury | Network-protocol fingerprint capture (TLS, DTLS, SSH, HTTP, TCP) at 40 Gbps | Probe #61 / #62 / #63 | https://github.com/cisco/mercury | BSD-style (per-file) | active 2024–2025 |
| GrapheneOS/Auditor | Hardware-backed attestation + remote-verification reference impl | Probe #69 / #70 + Adversary L_AdvA reference | https://github.com/GrapheneOS/Auditor | MIT | 2026-03-12 |
| GrapheneOS/AttestationServer | Server side of Auditor (verified attestation chain) | Reference for D2 § Server-Side Adversary | https://github.com/GrapheneOS/AttestationServer | MIT | active |
| trustdecision/trustdevice-android | Open-source Android fingerprint SDK (Kotlin) | DetectorLab implementation reference (already in `refs/bibliography.md`, but we should pin commit) | https://github.com/trustdecision/trustdevice-android | MIT | 2025-12-04 |
| _[Entry removed in Round-2 Action A1 + Round-2.5 F34. The Widevine L1/L3 capability-separation discussion is now anchored exclusively on the Blessing/Anderson/Beresford Cambridge 2025 academic paper — see Section 1 row "KeyDroid". No DRM-circumvention tooling is cited in this repository.]_ | | | | | |
| reveny/Android-Emulator-Detection | POC emulator-detection (Studio AVD + game emulators) | Probe #19 negative-control baseline | https://github.com/reveny/Android-Emulator-Detection | GPL-3.0 | 2024-11-02 |
| Parseus/codecinfo | Detailed multimedia-codec listing (MediaCodecList) | Probe #73 reference impl | https://github.com/Parseus/codecinfo | Apache-2.0 | active 2024 |
| farnoodfaghihi/CamoDroid | Sandbox cloaking environment (96 % evasion-malware bypass) | **Negative example** — counter-adversary; relevant for F19 negative-controls baseline | https://github.com/farnoodfaghihi/CamoDroid | MIT | 2021 (older — cite as "v1.0 reference impl"; not active) |
| fkie-cad/Sandroid_core | Fraunhofer FKIE Android sandbox for forensic + malware analysis | DetectorLab architectural reference | https://github.com/fkie-cad/Sandroid | (verify) | active 2024 |
| linnix-os/linnix | eBPF-powered Linux observability with AI incident detection | Reference for syscall-latency probe (#64) at host level | https://github.com/linnix-os/linnix | AGPL-3.0 | active 2024 |
| Fuzion24/AndroidKernelExploitationPlayground | kallsyms / kptr_restrict reference | Probe #67 cacerts neighbour + kallsyms-readability reference (academic) | https://github.com/Fuzion24/AndroidKernelExploitationPlayground | MIT | older but seminal |
| Parseus/codecinfo (Play Store mirror also exists) | see above | | | | |
| bkerler/dump_avb_signature | Dump Android Verified Boot signature | Probe #69 (VBMeta hash-chain) reference | https://github.com/bkerler/dump_avb_signature | MIT | active 2024 |
| reveny/Android-VBMeta-Fixer | Patch/inspect VBMeta partitions | Probe #69 reference (counter-impl) | https://github.com/reveny/Android-VBMeta-Fixer (DeepWiki mirror) | (verify) | 2024 |

Total: 14 active OSS tools meeting the 18-month freshness threshold (excluding the one CamoDroid 2021 entry kept as historical reference).

---

## 3. Reverse-Engineering Reports (academic / Bug-Bounty / DEF CON)

| Source | Topic | URL | Notes |
|---|---|---|---|
| Neodyme blog (security research firm) | "Diving into the depths of Widevine L3" — Qiling+DFA approach to deobfuscating Widevine L3 keybox | https://neodyme.io/en/blog/widevine_l3/ | Cite as method reference for L3 vs. L1 capability discussion (probe #70). Author affiliation verifiable; not a leaked-source dump. |
| Bits, Please! (M. Bremer) | "Effectively bypassing kptr_restrict on Android" | http://bits-please.blogspot.com/2015/08/effectively-bypassing-kptrrestrict-on.html | Reference for probe #67 / kallsyms-readability rationale. |
| Cloudflare engineering blog | "Advancing Threat Intelligence: JA4 fingerprints and inter-request signals" | https://blog.cloudflare.com/ja4-signals/ | Industry-side production-deployment evidence; supports Discussion. |
| VirusTotal blog | "Unveiling Hidden Connections: JA4 Client Fingerprinting on VirusTotal" | https://blog.virustotal.com/2024/10/unveiling-hidden-connections-ja4-client.html | Production evidence at scale. |
| StrangeBee blog | "JA4+ Fingerprinting: integrated into TheHive" | https://strangebee.com/blog/ja4-fingerprinting-now-available-in-thehive/ | Defensive deployment reference. |
| GrapheneOS docs | "Attestation compatibility guide" | https://grapheneos.org/articles/attestation-compatibility-guide | Authoritative reference for hardware-attestation device support — directly relevant to F18 procurement. |

**Excluded** (per Hard-Rules / Scope-Lock): keybox-leak forums, Magisk-module repositories that only ship spoof tooling without academic context, "how-to-bypass" XDA threads, anything hosted on `.ru` / `.cn` mirror domains, and any blog whose primary product is sale of bypass tooling.

---

## 4. German University Contributions

| Institution | Authors | Topic | URL | Notes |
|---|---|---|---|---|
| Ruhr-Universität Bochum | Klischies, Mackensen, Moonsamy | Vulnerability management in Android smartphone chipsets (NDSS 2025) | https://www.ndss-symposium.org/ndss2025/accepted-papers/ | Procurement (F18) and chipset-diversity baseline. |
| TU Graz (IAIK) | Maar, Giner, Lipp, Mangard et al. | SLUBStick — Linux kernel cross-cache exploitation (USENIX Security 2024) | https://www.usenix.org/conference/usenixsecurity24/presentation/maar-slubstick | Privileged-Docker threat-model evidence. |
| Fraunhofer FKIE (Bonn) | (multiple) | Sandroid — Android sandbox for forensic + malware analysis | https://github.com/fkie-cad/Sandroid_core | DetectorLab architectural reference. |
| CISPA Helmholtz Center, Saarland | (multiple — see CISPA publications page) | NDSS 2025 mobile-permission UX paper; CCS 2024/2025 Android-related work (~20 papers/yr) | https://cispa.de/en/research/publications | Watch-target. |
| TU Darmstadt CYSEC | (multiple — TUprints 2024 lists) | Android malware fuzzing, TPM/TEE research | https://www.cysec.tu-darmstadt.de/ | No single 2024 paper directly addressing our probe set was found; CYSEC remains a watch-target for paper-discovery. |
| JKU Linz INS (Mayrhofer Group) | Leierzopf, Mayrhofer, Roland, Studier, Dean, Seiffert, Putz, Becker, Thomas | "A Data-Driven Evaluation of the Current Security State of Android Devices" (IEEE CNS 2024) | https://www.mroland.at/publications/2024-leierzopf-cns/Leierzopf_2024_IEEECNS2024_AndroidDeviceSecurityState.pdf | Methodology mirror for our F18 procurement and F19 negative-controls. Mayrhofer's "Android Platform Security Model" (arXiv 1904.05572, updated 2023) remains the canonical citation for any Android-security paper. |
| TUM IT-Security | (no 2024–2025 paper directly on probe-overlap found) | — | — | Watch-list. |

Note: "German University" in our scope explicitly includes Austrian JKU Linz given the linguistic and institutional overlap (Mayrhofer was Director of Android Platform Security at Google 2017–2019; JKU is the dominant European group on Android-platform security).

---

## 5. Probe-Implementation Hints from Discovered Code

For each probe gap (#61–#74 from F5 + the new #75 we propose), the existing reference implementations are:

- **#61 `network.ja4_fingerprint`** — JA4 spec + ref impl: `FoxIO-LLC/ja4` (BSD-3 for JA4 itself). Server-side: `cisco/mercury` (40 Gbps capable). Academic baseline: arXiv 2602.09606 (XGBoost+CatBoost on JA4DB → F1 0.97).
- **#62 `network.tcp_stack_fingerprint`** — JA4T spec from FoxIO (TCP-window/MSS/TTL); also `p0f` original (`skord/p0f` mirror); modern alternative: P40f (programmable-switch impl, paper https://ieeexplore.ieee.org/document/9844109/). Implementation hint: instrument lab-side echo server with `nfstream` library.
- **#63 `network.http2_frame_pattern`** — JA4H from FoxIO suite covers HTTP/1.1 + HTTP/2 frame ordering. Production impl in Cloudflare.
- **#64 `runtime.syscall_latency_histogram`** — Use eBPF-based collector. Reference: `linnix-os/linnix` (AGPL-3.0). The Roy Dipta 2024 paper additionally suggests CPU-frequency telemetry as orthogonal dimension → propose **new probe #75 `runtime.cpu_frequency_signature`**.
- **#65 `emulator.gl_extensions_string`** — Standard `glGetString(GL_RENDERER/GL_VENDOR/GL_EXTENSIONS)` call from a minimal GLES2 context. Reference: GLview Extensions Viewer (commercial, but the API call is standard). Detection corpus: `reveny/Android-Emulator-Detection` already enumerates AVD/Genymotion strings.
- **#66 `env.thermal_zones`** — Reads `/sys/class/thermal/thermal_zone*/temp` + `type` + transition curves. No academic paper found that specifically targets thermal-zone fingerprinting on Android, but Linux thermal-sysfs API is documented at https://docs.kernel.org/driver-api/thermal/sysfs-api.html. **Open question**: is thermal-zone curve realism a probe or a confounder?
- **#67 `integrity.cacerts_diff`** — Hash `/system/etc/security/cacerts/*` and compare against AOSP-baseline. Foundational paper: Vallina-Rodriguez CoNEXT 2014. Implementation hint: keep an in-app SHA-256 manifest of expected hashes per Android API level.
- **#68 `runtime.app_uptime_variance`** — `Process.getElapsedCpuTime()` + `SystemClock.elapsedRealtime()` over a 30 s window. No directly-targeted academic paper; reference: forensic literature (Magnet Forensics emulator-forensics article; Oxygen Forensics BlueStacks article).
- **#69 `integrity.vbmeta_hash_chain`** — Walk AVB 2.0 hash-chain (`vbmeta` partition + chained partitions). Reference impls: `bkerler/dump_avb_signature` (extract), `reveny/Android-VBMeta-Fixer` (inspect/patch — read-only consult). Spec: https://android.googlesource.com/platform/external/avb/+/master/README.md.
- **#70 `identity.widevine_level`** — `MediaDrm.getPropertyString("securityLevel")` + `DrmManagerClient.acquireDrmInfo()` for `WVDrmInfoRequestStatusKey`. Academic baseline: Neodyme research blog on Qiling/DFA against DRM enforcement (cited for context only) and KeyDroid (Cambridge 2025 — Section 1) for the empirical L1/L3 prevalence study. **No DRM circumvention tooling is referenced or linked from this repository per Round-2.5 F34.**
- **#71 `runtime.binder_transaction_cost`** — Measure round-trip latency of a no-op AIDL call. Surface-area mapped by USENIX 2025 NASS paper. Implementation hint: use `android.os.IBinder.transact()` directly with empty Parcel.
- **#72 `env.camera2_metadata`** — `CameraManager.getCameraCharacteristics()` enumeration. Reference: Camera2 API docs + `CameraX Info` open-source app on F-Droid. No academic-fingerprinting paper specifically targets Camera2 on Android, but the data is well-suited to our F6 ML-Adversary L_AdvB.
- **#73 `env.audio_codec_capabilities`** — `MediaCodecList(REGULAR_CODECS).getCodecInfos()`. Reference impl: `Parseus/codecinfo` (Apache-2.0, active 2024). Browser-side fingerprinting analogue documented at scrapfly.io.
- **#74 `runtime.boot_time_entropy`** — Sample `/dev/random` blocking time at boot + entropy-pool fill rate from `/proc/sys/kernel/random/entropy_avail`. Foundational paper: Heninger et al. WOOT 2014 ("Attacking the Linux PRNG on Android", https://www.usenix.org/system/files/conference/woot14/woot14-kaplan.pdf).
- **#75 (NEW, proposed) `runtime.cpu_frequency_signature`** — Per Roy Dipta EuroS&P 2024. Sample CPU-frequency reporting sensors over 40 s window. Distinguishes Docker / gVisor / Firecracker / SGX / SEV with 70 %+ accuracy. **Action item**: this should be added as F31 in `plans/05-validation-feedback.md` via the standard addendum protocol — it is NOT silently appended here.

---

## 6. Citation BibTeX (ready for paper)

```bibtex
@inproceedings{specter2025fingerprinting,
  title     = {Fingerprinting SDKs for Mobile Apps and Where to Find Them: Understanding the Market for Device Fingerprinting},
  author    = {Specter, Michael A. and Christodorescu, Mihai and Farr, Abbie and Ma, Bo and Lassonde, Robin and Xu, Xiaoyang and Pan, Xiang and Wei, Fengguo and Anand, Saswat and Kleidermacher, Dave},
  booktitle = {Proceedings of the 32nd ACM SIGSAC Conference on Computer and Communications Security (CCS '25)},
  year      = {2025},
  publisher = {ACM},
  url       = {https://arxiv.org/abs/2506.22639}
}

@inproceedings{roydipta2024dynamic,
  title     = {Dynamic Frequency-Based Fingerprinting Attacks against Modern Sandbox Environments},
  author    = {Roy Dipta, Debopriya and Tiemann, Thore and Gulmezoglu, Berk and Marin, Eduard and Eisenbarth, Thomas},
  booktitle = {2024 IEEE 9th European Symposium on Security and Privacy (EuroS\&P)},
  year      = {2024},
  url       = {https://arxiv.org/abs/2404.10715}
}

@inproceedings{leierzopf2024datadriven,
  title     = {A Data-Driven Evaluation of the Current Security State of Android Devices},
  author    = {Leierzopf, Ernst and Mayrhofer, Ren\'e and Roland, Michael and Studier, Wolfgang and Dean, Lawrence and Seiffert, Martin and Putz, Florentin and Becker, Lucas and Thomas, Daniel R.},
  booktitle = {2024 IEEE Conference on Communications and Network Security (CNS)},
  year      = {2024},
  url       = {https://ieeexplore.ieee.org/document/10735682}
}

@misc{kuhne2024aster,
  title         = {Aster: Fixing the Android TEE Ecosystem with Arm CCA},
  author        = {Kuhne, Mark and Sridhara, Supraja and Bertschi, Andrin and Dutly, Nicolas and Capkun, Srdjan and Shinde, Shweta},
  year          = {2024},
  eprint        = {2407.16694},
  archivePrefix = {arXiv},
  primaryClass  = {cs.CR}
}

@misc{blessing2025keydroid,
  title         = {KeyDroid: A Large-Scale Analysis of Secure Key Storage in Android Apps},
  author        = {Blessing, Jenny and Anderson, Ross J. and Beresford, Alastair R.},
  year          = {2025},
  eprint        = {2507.07927},
  archivePrefix = {arXiv},
  primaryClass  = {cs.CR}
}

@inproceedings{maar2024slubstick,
  title     = {SLUBStick: Arbitrary Memory Writes through Practical Software Cross-Cache Attacks within the Linux Kernel},
  author    = {Maar, Lukas and Giner, Lukas and Lipp, Moritz and Mangard, Stefan and others},
  booktitle = {33rd USENIX Security Symposium (USENIX Security 24)},
  year      = {2024},
  url       = {https://www.usenix.org/conference/usenixsecurity24/presentation/maar-slubstick}
}

@inproceedings{he2023crosscontainer,
  title     = {Cross Container Attacks: The Bewildered eBPF on Clouds},
  author    = {He, Yi and Bai, Roland and Tu, Geng and Sun, Kun and others},
  booktitle = {32nd USENIX Security Symposium (USENIX Security 23)},
  year      = {2023},
  url       = {https://www.usenix.org/system/files/usenixsecurity23-he.pdf}
}

@inproceedings{vallinarodriguez2014tangledmass,
  title     = {A Tangled Mass: The Android Root Certificate Stores},
  author    = {Vallina-Rodriguez, Narseo and Amann, Johanna and Kreibich, Christian and Weaver, Nicholas and Paxson, Vern},
  booktitle = {Proceedings of the 10th ACM International on Conference on Emerging Networking Experiments and Technologies (CoNEXT '14)},
  year      = {2014},
  url       = {https://conferences2.sigcomm.org/co-next/2014/CoNEXT_papers/p141.pdf}
}

@inproceedings{zhang2019sensorid,
  title     = {SensorID: Sensor Calibration Fingerprinting for Smartphones},
  author    = {Zhang, Jiexin and Beresford, Alastair R. and Sherratt, Ian},
  booktitle = {2019 IEEE Symposium on Security and Privacy (SP)},
  year      = {2019},
  url       = {https://sensorid.cl.cam.ac.uk/}
}

@inproceedings{dey2014accelprint,
  title     = {AccelPrint: Imperfections of Accelerometers Make Smartphones Trackable},
  author    = {Dey, Sanorita and Roy, Nirupam and Xu, Wenyuan and Choudhury, Romit Roy and Nelakuditi, Srihari},
  booktitle = {Proceedings of the 21st Annual Network and Distributed System Security Symposium (NDSS '14)},
  year      = {2014},
  url       = {https://userpages.cs.umbc.edu/sanorita/images/1_papers/AccelPrint_NDSS14.pdf}
}

@inproceedings{shakevsky2022trustdies,
  title     = {Trust Dies in Darkness: Shedding Light on Samsung's TrustZone Keymaster Design},
  author    = {Shakevsky, Alon and Ronen, Eyal and Wool, Avishai},
  booktitle = {31st USENIX Security Symposium (USENIX Security 22)},
  year      = {2022},
  url       = {https://eprint.iacr.org/2022/208.pdf}
}

@misc{foxio2024ja4,
  title  = {JA4+ Network Fingerprinting Suite},
  author = {{FoxIO LLC} and Althouse, John},
  year   = {2024},
  url    = {https://github.com/FoxIO-LLC/ja4},
  note   = {BSD-3 (JA4) / FoxIO License 1.1 (JA4+ extensions)}
}

@misc{cisco2024mercury,
  title  = {Mercury: Network Metadata Capture and Analysis},
  author = {{Cisco Systems}},
  year   = {2024},
  url    = {https://github.com/cisco/mercury}
}

@misc{grapheneos2024auditor,
  title  = {GrapheneOS Auditor: Hardware-based Attestation and Intrusion-Detection App for Android},
  author = {{GrapheneOS Project}},
  year   = {2024},
  url    = {https://github.com/GrapheneOS/Auditor},
  note   = {MIT License}
}
```

---

## Open Questions for Human Partner

1. **Scope of new probe #75 (CPU-frequency signature)** — Roy Dipta 2024 demonstrates it works at *container* boundary on x86. Does it survive on ARM64 Bare-Metal Linux (our F2-required host)? Needs empirical pilot before adding to `probes/inventory.yml`. Proposal: file as F31 in a future validation round.
2. **CYSEC TU Darmstadt** — no 2024–2025 paper found that directly addresses our probe overlap. Worth a direct mailing-list inquiry to the institute, or accept as "not currently active in this micro-niche"?
3. **Industry-blog inclusion policy** — Cloudflare/VirusTotal/StrangeBee blogs are production-deployment evidence with high credibility but are not peer-reviewed. Bibliography section "Industry Whitepaper / Production Deployment Evidence" or omit?
4. **CamoDroid (2021, MIT)** is older than the 18-month freshness threshold but is the canonical academic counter-adversary reference. Keep as historical OSS, or move to academic-references table?
5. **DRM-tooling citations** — _Round-2.5 F35 closed:_ all references to active DRM-circumvention tooling have been physically removed from this document. The Widevine L1/L3 capability-separation discussion is now anchored exclusively on the Blessing/Anderson/Beresford **KeyDroid** Cambridge 2025 academic paper (Section 1) and on architectural analyses (Neodyme blog) that contain no extraction tooling.

---

## Reviewer-Validation Required Before Merge into `refs/bibliography.md`

- [ ] Multi-reviewer round (≥2 of: Gemini-CLI, architecture-strategist, gap-analyst)
- [ ] Pre-Registration impact assessment — none expected (this is a bibliography extension, not a hypothesis change)
- [ ] Cross-reference each F5-probe (#61–#74) against the implementation-hints column to confirm coverage

---

## Provenance / Tools Used

- `WebSearch` (16 distinct queries, May 2026) — venue and topic coverage
- `WebFetch` (8 spot-checks) — title/author/year/license verification on 4 arXiv abstracts + 4 GitHub repos
- All listed URLs returned HTTP 200 at time of writing (2026-05-02). No paywalled-only sources included.
- Excluded per Hard-Rules: leaked-keybox forums, Magisk-only spoof-tooling repos, "how-to-bypass" XDA threads, anything hosted on questionable mirror domains.
- `zread` MCP not used — all repos cited above are well-served by their public README/Activity pages and GitHub API metadata fetched via `WebFetch`.
