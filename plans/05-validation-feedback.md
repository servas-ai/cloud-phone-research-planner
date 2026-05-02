# Validation Feedback — Multi-Reviewer Round

Datum: 2026-05-02
Reviewer:
- Gemini 3 Pro Preview (gemini-cli, headless)
- architecture-strategist (Claude subagent)
- gap-analyst (Claude subagent)
- security-auditor (Claude subagent) — still running, addendum follows

Codex GPT-5.5: nicht verfuegbar (Usage-Limit bis 2026-05-09).

> Plan-Immutability-Regel beachtet: Original-Plaene werden NICHT modifiziert.
> Dieses Dokument ist ein Addendum. Patch-Set folgt nach User-Approval.

---

## Reviewer-Verdicts

| Reviewer | Verdict | Kern-Kritik |
|---|---|---|
| Gemini 3 Pro | NEEDS_REVISION | Hardware-Platform-Flaw, Multiple-Testing-Luecke, Probe-Luecken |
| architecture-strategist | NEEDS_REVISION | N=30 unterpowered, ML-Adversary fehlt im Threat-Model, kein Orchestrator |
| gap-analyst | (gap-analysis, kein Verdict) | Keybox-Legalitaet ungeklaert, IRB-Approval-Gating, Pre-Registration fehlt, FFT-Classifier unspecified |
| security-auditor | NEEDS_REVISION | privileged Docker = Host-Root-Escape, Keybox-Provenienz §202c-Risiko, Reproducibility-Pack = §202c-Recipe |

---

## Konsolidierte Findings (Konsens 2+ Reviewer)

### F1 — L0 Baseline conflated (kritisch)

**Quelle:** Gemini, architecture-strategist (implizit ueber Snapshot-Kritik)

**Befund:** L0 enthaelt Magisk + ReZygisk + LSPosed -> Container-Detection-Artefakte vermischt mit Root/Hooking-Artefakten.

**Korrektur:**
- `stack/layers.md`: Split L0 in **L0a (vanilla ReDroid)** + **L0b (L0a + Magisk + ReZygisk + LSPosed)**.
- `plans/03-experiment-matrix.md`: Matrix-Achse erweitern um L0a-Spalte.

### F2 — Apple Silicon Host verboten (kritisch)

**Quelle:** Gemini

**Befund:** Docker auf macOS = Linux-VM = Hypervisor-Boundary leakt. Confound mit Container-Artefakten.

**Korrektur:**
- `stack/layers.md` Layer L0: Host nur "ARM64 Bare-Metal Linux" (Ampere Altra, Raspberry Pi 5, NVIDIA Jetson AGX Orin).
- `docs/threat-model.md`: Hypervisor-Boundary als Confounder explizit ausschliessen.

### F3 — Statistische Power und Multiple-Testing (kritisch)

**Quelle:** Gemini, architecture-strategist

**Befund:**
- N=30 unterpowered fuer McNemar (braucht ~50-60 discordant pairs pro Zelle bei alpha=0.05, power=0.8).
- 60 Probes x 7 Layer-Deltas = 420 simultane Tests ohne FWER/FDR-Kontrolle -> erwartete 21 False-Positives bei alpha=0.05.
- Probe-Korrelation ignoriert (z.B. #1, #7, #9, #28 alle aus getprop) -> weightedScore inflationiert.

**Korrektur:**
- `plans/03-experiment-matrix.md`:
  - N=60 fuer Layer-Transition-Probes
  - Benjamini-Hochberg FDR-Korrektur explizit
  - Power-Berechnung dokumentiert (effect-size + alpha + beta)
  - PCA oder Domain-Grouped-Scoring fuer korrelierte Probes
  - 2^6 fractional-factorial (Resolution IV, 16 Zellen) fuer Layer-Interaktions-Detection

### F4 — Network-Probes unvollstaendig (hoch)

**Quelle:** Gemini

**Befund:** JA3/JA4 TLS-Fingerprint und p0f-Stack-Fingerprint fehlen komplett.

**Korrektur:**
- `probes/inventory.yml`: Neue Probes (Append, keine Renumeration der 1-60):
  - #61 `network.ja4_fingerprint` (high)
  - #62 `network.tcp_stack_fingerprint` (high) — TCP Window-Size, MSS, TTL, fingerbank
  - #63 `network.http2_frame_pattern` (medium)
- DetectorLab: TLS-Probe per OkHttp-Interceptor + lokalem Echo-Server im Lab.

### F5 — Probe-Inventar Luecken Behavior/Temporal (hoch)

**Quelle:** architecture-strategist

**Befund:** Inventar deckt statische State gut ab, aber temporal/behavioral underrepresented.

**Korrektur — `probes/inventory.yml` neue Probes:**
- #64 `runtime.syscall_latency_histogram` — nanosleep/gettimeofday/futex-Verteilung
- #65 `emulator.gl_extensions_string` — vollstaendige GL_EXTENSIONS-Liste
- #66 `env.thermal_zones` — `/sys/class/thermal/thermal_zone*` realistische Curves
- #67 `integrity.cacerts_diff` — `/system/etc/security/cacerts` Hash-Diff
- #68 `runtime.app_uptime_variance` — `Process.getElapsedCpuTime` Varianz
- #69 `integrity.vbmeta_hash_chain` — AVB 2.0 Hash-Chain (#13 nur device_state)
- #70 `identity.widevine_level` — L1/L3 Capability separat von #29 MediaDrm UID
- #71 `runtime.binder_transaction_cost` — Binder-IPC-Latency
- #72 `env.camera2_metadata` — Camera2 Capabilities
- #73 `env.audio_codec_capabilities` — MediaCodec-Liste
- #74 `runtime.boot_time_entropy` — /dev/random initial entropy

### F6 — ML-Adversary fehlt im Threat-Model (kritisch)

**Quelle:** architecture-strategist

**Befund:** STRIDE deckt static-rule Adversaries ab. Modern Anti-Fraud ist ueberwiegend ML-basiert (XGBoost auf Probe-Vector, deep models auf Sensor-Traces). Ohne ML-Adversary ist der Paper-Beitrag auf Rule-Based-Detection limitiert.

**Korrektur:**
- `docs/threat-model.md`: Neue Achse "Adversary Capability" mit 3 Levels:
  - L_AdvA: static-rule (current model)
  - L_AdvB: ML-classifier auf Probe-Vector (XGBoost, RandomForest)
  - L_AdvC: deep ML auf raw Sensor-Traces (CNN/RNN auf 30s-Window)
- STRIDE-Tabelle um ML-Adversary-Zeile erweitern.
- DetectorLab: Probe-Vector-Export fuer offline ML-Eval.

### F7 — EU Dual-Use Export Control (hoch)

**Quelle:** Gemini

**Befund:** EU 2021/821 nicht erwaehnt. Cyber-Surveillance-Items koennten Anti-Detection-Toolkits umfassen.

**Korrektur:**
- `docs/ethics-and-scope.md`: Neue Sektion "EU Dual-Use Regulation 2021/821":
  - DetectorLab als defensives Werkzeug abgrenzen
  - SpoofStack: nur als wissenschaftliche Beschreibung
  - Hochschul-Forschungsprivileg (Art. 9 Abs. 2)
  - BAFA-Rueckfrage vor Publikation pruefen

### F8 — Sensor Trace Player zu naiv (mittel)

**Quelle:** Gemini

**Befund:** CSV-Playback ohne Multi-Sensor-Cross-Correlation und IRQ-Timing-Jitter.

**Korrektur:**
- `stack/layers.md` L5: Trace-Player-Spec erweitern um:
  - Multi-Sensor-Synchronous-Replay (Accel + Gyro + Mag in einem Time-Frame)
  - IRQ-Latency-Distribution aus realer Aufnahme
  - Sensor-Coalescing-Verhalten
- `plans/01-detectorlab.md` Probe #24: Multi-Sensor-Timestamp-Jitter-Analysis als Mess-Methode.

### F9 — Reproducibility-Bruch durch L3/L5 (mittel)

**Quelle:** Gemini, architecture-strategist (Snapshot-Pipeline-Gap)

**Korrektur:**
- `plans/04-deliverables.md` D3:
  - Reproducibility-Levels einfuehren: "Methodological" vs. "Bit-Exact"
  - Keybox: Methodologie zur Beschaffung dokumentiert, NICHT im Pack
  - Sensor-Traces: anonymisiert/aggregiert (Mean/StdDev/IRQ-Histogram), nicht raw
  - Container-Snapshot-Builder: Dockerfile-per-Layer, content-addressed

### F10 — Phase-Dependency-Konflikt (kritisch)

**Quelle:** gap-analyst

**Befund:** SensorFFTProbe (Sprint 4 Woche 5) braucht Pixel-7-Trace, aber Trace-Recording erst in Sprint D Woche 6. Reverse-Order.

**Korrektur:**
- `plans/01-detectorlab.md` Sprint 4 -> Sprint 1 fuer Trace-Recording-Protocol.
- `plans/02-spoofstack.md` Sprint A -> Trace-Recording als Phase-0-Aktivitaet.

### F11 — Keybox-Legalitaet ungeklaert (kritisch)

**Quelle:** gap-analyst

**Befund:** `02-spoofstack.md` Sprint C: "Keybox aus oeffentlich dokumentierter Quelle (akademisch zitiert)" — keine solche Quelle existiert. `ethics-and-scope.md`: "Keine Keyboxen aus illegitimen Quellen" — direkter Widerspruch.

**Korrektur:**
- `docs/ethics-and-scope.md`: Sektion "Keybox-Provenienz" mit drei Optionen, vor Phase 1 entscheiden:
  - Option A: Vendor-Cooperation (z.B. Google PartnerProgram, Samsung KCS) — wahrscheinlich nicht erreichbar
  - Option B: Eigene Geraete-Extraction (legal in DE bei eigenen Devices, dokumentierter Prozess)
  - Option C: L3-Experiment ausschliessen, H2 als "nicht testbar im Lab" markieren -> Paper-Contribution-Narrative anpassen
- Universitaets-Rechtsabteilung schriftlich konsultieren BEVOR L3-Phase.

### F12 — IRB als Gating-Event (kritisch)

**Quelle:** gap-analyst

**Korrektur:**
- `plans/00-master-plan.md` Phase 0: "drafted" -> "submitted + approved". `IRB_APPROVAL_DATE` als Phase-0-Exit-Kriterium. Kein Datensammeln vor Approval.

### F13 — Pre-Registration fehlt (hoch)

**Quelle:** gap-analyst

**Befund:** H1-H4 nicht pre-registered -> HARKing-Risiko bei Peer-Review.

**Korrektur:**
- Pre-Registration auf OSF / aspredicted vor Phase 1:
  - Hypothesen H1-H4
  - Score-Thresholds (0.10/0.40)
  - N pro Konfiguration
  - Power-Berechnung
  - probes/inventory.yml v1.0 lock
- `plans/00-master-plan.md`: Neue Aktivitaet "OSF Pre-Registration" in Phase 0.

### F14 — FFT-Classifier unspecified (kritisch)

**Quelle:** gap-analyst

**Befund:** H3 (Sensor FFT > 0.7 Konfidenz) ohne Mess-Instrument unfalsifizierbar.

**Korrektur:**
- `plans/01-detectorlab.md` Probe #24:
  - Statistical-Methode (z.B. Kolmogorov-Smirnov-Test auf Noise-Distribution) ODER
  - Supervised Classifier (RandomForest / SVM) mit Trainings-Corpus aus N>=10 Realgeraet-Recordings, je >=10 Min
  - Train/Test-Split 80/20, Evaluation-Metric F1
  - Versionierung als `probes/sensors/fft-model-v1`

### F15 — Schema-Versionierung Single-Version (mittel)

**Quelle:** architecture-strategist

**Korrektur:**
- `docs/probe-schema.md`: `schemaVersion` enum statt const, `probeRevision` per Probe, additive `x-extensions` Forward-Compat-Policy.

### F16 — Automation-Orchestrator fehlt (kritisch)

**Quelle:** architecture-strategist, gap-analyst

**Befund:** 7+ Konfigurationen x 30+ Runs = 210+ Runs manuell ueber ADB. Operator-Bias garantiert.

**Korrektur:**
- Neue Datei `experiments/runner/runner.py` + `README.md`:
  - Konsumiert manifest.yml
  - Container-Snapshot starten
  - APK installieren
  - DetectorLab triggern + JSON pullen
  - Schema-Validation
  - Schreiben nach `experiments/runs/{config-id}/{run-N}.json`
- Block Sprint C bis Runner steht.

### F17 — GMS / OpenGApps / MicroG fehlt (kritisch)

**Quelle:** gap-analyst

**Befund:** Probe #2 (Play Integrity) und #16 (GAID) brauchen Google Play Services im Container. `02-spoofstack.md` erwaehnt das nicht.

**Korrektur:**
- `stack/layers.md` L0: Entscheidung GMS vs OpenGApps vs MicroG dokumentieren.
- Recommendation: OpenGApps Pico-Variante (minimal, reicht fuer Play Integrity).

### F18 — Hardware-Procurement-Plan fehlt (hoch)

**Quelle:** gap-analyst

**Korrektur:**
- `plans/00-master-plan.md` Phase 0:
  - ARM64-Host (Specs, Budget, Bezugsquelle)
  - 3 Real-Devices (Pixel 7, Samsung S23, Xiaomi 13) — Eigentum + Datensauberkeit dokumentieren
  - LTE-Modem + SIM + APN
  - Procurement-Checklist als Phase-0-Exit-Kriterium

### F19 — Negative Controls fehlen (mittel)

**Quelle:** gap-analyst

**Befund:** Kein Known-Emulator-Baseline (z.B. Android Studio AVD) zur True-Positive-Validierung.

**Korrektur:**
- `plans/01-detectorlab.md` Validierung: Zusaetzlich AVD x86_64 + Genymotion als positive controls (DetectorLab muss diese erkennen).

### F20 — Container-Update-Drift (mittel)

**Quelle:** gap-analyst, architecture-strategist

**Korrektur:**
- `experiments/README.md` Run-Skript: image-hash-Verification vor jedem Run.
- Magisk Auto-Update DEAKTIVIEREN im Container.

---

### F21 — Privileged Docker = Host-Root-Escape (KRITISCH)

**Quelle:** security-auditor

**Befund:** `stack/layers.md` L0 verwendet `privileged: true` mit `/dev/binder` + `/dev/ashmem` Passthrough. Magisk-Rooted ReDroid -> privileged Docker -> Host-Root. Keine Seccomp/AppArmor/SELinux-Confinement, kein rootless Docker.

**Korrektur:**
- `stack/layers.md` L0 docker-compose ersetzen:
  ```yaml
  cap_add: [SYS_ADMIN]
  cap_drop: [ALL]
  security_opt:
    - seccomp:redroid-seccomp.json
    - no-new-privileges:true
  ```
- Docker rootless ODER dedizierte VM-Boundary
- `redroid-seccomp.json` als neue Datei in `stack/`

### F22 — Keybox-Provenienz §202c/§259 StGB Risiko (KRITISCH)

**Quelle:** security-auditor (verschaerft F11 von gap-analyst)

**Befund:** "Publicly documented source" ist kein Rechtsstandard. Leaked manufacturer keyboxes = moegliche Receipt-of-Stolen-Property (§259 StGB) oder Trade-Secret-Misappropriation.

**Korrektur:**
- `docs/ethics-and-scope.md` Mandatory Subsection:
  - Keyboxes nur aus (a) TEE-Extraction von Projektmitglieder-eigenen Geraeten (im IRB-Antrag dokumentiert) ODER (b) schriftlicher Hersteller-Erlaubnis
  - Keine Public-Repo, Forum, Leaked-Dataset
  - Encrypted-at-Rest (age, IRB-approved Project-Key)
  - Access-Logged

### F23 — Reproducibility-Pack als §202c-"Recipe" (KRITISCH)

**Quelle:** security-auditor (verschaerft F9)

**Befund:** Publication von `spoofstack-manifests/*.yml` mit Modul-Versionen + TrickyStore-Config = legal aequivalent zu Tool-Publication unter §202c.

**Korrektur:**
- `plans/04-deliverables.md` D3:
  - Public-Pack: nur `spoofstack-description.yml` (Layer-Namen, Probe-IDs, Mitigation-Scores)
  - Full-Manifests: institutional-repository, verified-academic-request only
  - Detection-Results-Reproducibility (DetectorLab-Scores) bleibt full public

### F24 — Container-Network-Isolation undokumentiert (hoch)

**Quelle:** security-auditor

**Befund:** Host hat zwei Interfaces (Uni-Backbone + LTE). Keine iptables-Policy, die Container-Egress zur Uni-Backbone droppt -> Live-Platform-Egress moeglich, Lab-Isolation gebrochen.

**Korrektur:**
- `stack/layers.md` L6: iptables-Rules-Spec dokumentieren (DROP all container-out except via LTE-NAT).
- `docs/ethics-and-scope.md`: Lab-Isolation-Verifikation als Phase-0-Exit-Kriterium.

### F25 — Sensor-Trace DSGVO-Status ungeklaert (hoch)

**Quelle:** security-auditor (verschaerft F9)

**Befund:** Sensor-Traces aus realen Nutzungskontexten (Tasche, Hand, Tisch) koennten Bewegungsmuster enthalten -> personenbezogen unter Art.4(1) DSGVO.

**Korrektur:**
- `plans/01-detectorlab.md` Trace-Recording-Protocol:
  - First-60s + Last-60s strippen (Data-Minimization)
  - Recording in kontrollierter Lab-Umgebung (kein Pendelweg, etc.)
  - DSGVO-Assessment als Anhang zum IRB-Antrag

### F26 — Keybox-at-Rest in Container-Snapshots (hoch)

**Quelle:** security-auditor

**Befund:** `.img.xz` Snapshots enthalten `/data/adb/tricky_store/keybox.xml` plaintext. Bei Versions-Control-Commit oder Shared-Storage = Keybox-Leak.

**Korrektur:**
- `.gitignore` Update: explizite Patterns fuer keybox-haltige Snapshots
- `experiments/README.md` Run-Skript: Keybox-Mount erst zur Laufzeit, nicht im Image

### F27 — Server-Side & ML-Adversary in Discussion (mittel)

**Quelle:** security-auditor (komplementaer zu F6)

**Befund:** D2 Section 7 (Implications for Anti-Fraud) nicht credible ohne Server-Side-Adversary-Acknowledge.

**Korrektur:**
- `docs/threat-model.md`: Neue Nodes:
  - "Server-Side Behavioral Analytics" — explicitly out-of-scope mit Rationale
  - "On-Device ML Ensemble" — distinct threat class, separate STRIDE-Row

### F28 — DoS-Quadrant in STRIDE leer (mittel)

**Quelle:** security-auditor

**Befund:** STRIDE-Tabelle hat D-Spalte ohne markierte Vektoren. Container-Binder-Slot-Erschoepfung waere DoS-Class-Probe.

**Korrektur:**
- `docs/threat-model.md`: Entweder D-Vektoren explizit markieren ODER D-Quadrant als "out-of-scope, see Section X" dokumentieren.

### F29 — LTE-SIM Provenienz (hoch)

**Quelle:** security-auditor

**Befund:** SIM-Eigentum, APN-Documentation, Carrier-ToS-Compliance ungeklaert.

**Korrektur:**
- `docs/ethics-and-scope.md` neue Sektion "Network Egress Provenance":
  - SIM-Eigentum: Hochschule oder Researcher
  - APN: nicht commercial-prohibits-automation
  - Connection-Documentation als IRB-Anhang

### F30 — Disclosure-Fallback fehlt (mittel)

**Quelle:** security-auditor

**Befund:** 90-Tage-Disclosure ok, aber kein Fallback fuer Plattformen ohne Bug-Bounty.

**Korrektur:**
- `docs/ethics-and-scope.md` Disclosure-Policy: Fallback ueber CERT-Bund oder BSI dokumentieren.

---

## Reviewer-Konflikte

Keine direkten Konflikte. Alle 4 Reviewer (Gemini, architecture-strategist, gap-analyst, security-auditor) verdict NEEDS_REVISION mit komplementaeren Schwerpunkten:

| Reviewer | Schwerpunkt |
|---|---|
| Gemini 3 Pro | Hardware-Platform + Statistik + Probe-Coverage (TLS) |
| architecture-strategist | Threat-Model + Reproducibility-Engineering + Orchestrator |
| gap-analyst | Operationale Voraussetzungen + Decision-Points + IRB-Gating |
| security-auditor | Legal §202c/§259 + OpSec (privileged Docker) + Network-Isolation |

**Verschaerfungen** (security-auditor verschaerft frueheres Finding):
- F11 (Keybox-Legalitaet) -> F22 (§259 StGB Receipt-of-Stolen-Property)
- F9 (Reproducibility-Bruch) -> F23 (Reproducibility-Pack als §202c-Recipe)

---

## Patch-Plan (Round 3 — nach security-auditor Eingang)

1. security-auditor-Findings einarbeiten
2. Konflikte zwischen allen 4 Reviewern explizit dokumentieren
3. User-Approval einholen vor Edit (Plan-Immutability-Regel)
4. Patch-Set erstellen: ein Edit pro Plan-Datei mit klarem Diff
5. Edits applizieren
6. CQC-Lauf als Final-Quality-Gate
7. Git-Commit "validation-round-1: peer-review patches applied"

---

## Geplante Datei-Edits (Vorschau)

| Datei | Findings adressiert |
|---|---|
| `plans/00-master-plan.md` | F12 IRB, F13 Pre-Reg, F18 Procurement |
| `plans/01-detectorlab.md` | F10 Phase-Order, F14 FFT-Classifier, F19 Neg-Controls |
| `plans/02-spoofstack.md` | F17 GMS-Decision |
| `plans/03-experiment-matrix.md` | F3 Statistik, F6 ML-Adversary-Eval |
| `plans/04-deliverables.md` | F9 Reproducibility-Levels |
| `docs/ethics-and-scope.md` | F7 EU-Dual-Use, F11 Keybox-Provenienz |
| `docs/threat-model.md` | F2 Hypervisor, F6 ML-Adversary |
| `docs/probe-schema.md` | F15 Schema-Versionierung |
| `probes/inventory.yml` | F4 Network-Probes, F5 Behavior/Temporal-Probes |
| `stack/layers.md` | F1 L0a/L0b-Split, F2 Host-Restriction, F8 Trace-Player-Spec |
| `experiments/runner/runner.py` (NEU) | F16 Orchestrator |
| `experiments/runner/README.md` (NEU) | F16 Orchestrator-Doku |
| `stack/redroid-seccomp.json` (NEU) | F21 Seccomp-Profile |
| `stack/iptables-isolation.sh` (NEU) | F24 Container-Network-Isolation |

---

## TOP-3 BLOCKING fuer Phase 0 (vor IRB-Antrag)

Aus security-auditor-Verdict, NICHT verhandelbar:

1. **F22 Keybox-Provenienz** — Schriftliche Rechtsabteilungs-Klaerung mit Beschraenkung auf eigene-Geraete-Extraction ODER Hersteller-Erlaubnis. OHNE diese keine L3-Phase, H2 unfalsifizierbar.

2. **F21 Privileged Docker** — Seccomp + capability-drop + rootless-Docker bzw. dedizierte VM. OHNE diese kein Lab-Betrieb genehmigungsfaehig.

3. **F23 Reproducibility-Pack §202c** — Pack-Struktur in (a) public detection-results und (b) institutional-only mitigation-stack splitten. OHNE diese keine Publication moeglich.

Diese drei MUESSEN vor Beginn der Implementierungsphase 1 mit Universitaets-Rechtsabteilung und Ethik-Kommission geklaert sein.
