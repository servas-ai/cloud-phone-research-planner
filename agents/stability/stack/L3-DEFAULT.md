# L3 Integrity Backend — Default Selection (CLO-11)

> **Owner:** Stability Agent
> **Status:** DEFAULT — TEESimulator v3.2 (JingMatrix, 2026-03-07)
> **Issue:** CLO-11 (Wire TEESimulator v3.2 as default L3-integrity backend)
> **Canon:** `docs/super-action/W1/BEST-STACK-v2.md` §II, `docs/super-action/W9/SPOOFSTACK-PRESTAGE.md`

---

## 1. Decision

`TEESimulator v3.2` is the **default** L3-integrity backend for SpoofStack research cells. `TrickyStore 1.4.1 @ 72b2e84` is the **fallback** branch, kept behind a hard mutual-exclusion gate.

### Why TEESimulator first

| Property | TEESimulator v3.2 | TrickyStore 1.4.1 |
|---|---|---|
| Keybox dependency | None — virtualised TEE | Pre-2023 Pixel keybox (most revoked 2025-04, all pre-cutover keys invalidated 2026-04-10) |
| Proprietary blob | None | Keybox.xml provenance burden |
| Maintenance status | Active (JingMatrix, last commit 2026-03-07) | Stable, but keybox availability decays |
| Binder-intercept | Yes (source of mutual-exclusion conflict) | Yes (source of mutual-exclusion conflict) |
| Strategic posture | Forward-compatible — TEE substitution | Legacy — depends on a vanishing key supply |

TEESimulator is the strategic successor; TrickyStore is retained for cells that *intentionally* exercise the keybox-based path (provenance studies, keybox-revocation experiments).

---

## 2. Selection mechanism

Selection is by `config_id` token at resolver time. The Stability agent never edits compose files at runtime — it composes via:

```bash
# Default (TEESimulator):
./docs/super-action/W9/compose-matrix.sh "L0a+L0b+L1+L2+L3:tee+L4" out/cell.compose.yml

# Fallback (TrickyStore):
./docs/super-action/W9/compose-matrix.sh "L0a+L0b+L1+L2+L3:trickystore+L4" out/cell.compose.yml
```

Env-var alias for orchestrator scripts:

| `SPOOFSTACK_L3` value | Resolved `config_id` token | Compose overlay |
|---|---|---|
| `teesimulator` (default) | `L3:tee` | `redroid-compose-L3.yml` |
| `trickystore` (fallback) | `L3:trickystore` | `redroid-compose-L3-trickystore.yml` |

If `SPOOFSTACK_L3` is unset, the orchestrator MUST default to `teesimulator`.

---

## 3. Mutual-exclusion guard

The two backends both intercept Binder calls to the keystore HAL. Composing both yields an inconsistent X.509 chain (last-wins). The guard is enforced at two layers:

- **Resolver (`compose-matrix.sh`)** — emits `exit 78` if both `L3:tee` and `L3:trickystore` tokens are present in the same `config_id`. See `docs/super-action/W9/SPOOFSTACK-PRESTAGE.md` §4.
- **Compose labels** — each overlay sets `research.l3.mutual_exclusion` to the *other* backend, so post-merge inspectors can detect the violation as a structural check.

A future stack-bootstrap script SHOULD also short-circuit with a non-zero exit if both module artefacts are found staged under `/data/adb/modules-staged`.

---

## 4. Hard Ceiling #3 — STRONG_INTEGRITY uncountered

Per `BEST-STACK-v2.md` Ceiling #3:

> **STRONG_INTEGRITY** (Google Play hardware-backed key attestation chain verification) is **uncountered** by any FOSS L3 module — TEESimulator and TrickyStore both produce a chain that passes `DEVICE` but not `STRONG`. This is a documented limit, not a defect.

`INTEGRITY_TARGET_VERDICTS` in both overlays is therefore set to `"BASIC,DEVICE"`. STRONG verdict failures in cell runs are **expected** and MUST NOT be treated as a stack regression.

---

## 5. Companion modules

Both branches install the PlayIntegrityFork v16 companion (capped <A13) for property-spoof coverage of `ro.product.first_api_level` and friends that PI samples.

The TEESimulator branch additionally installs `KOWX712/PlayIntegrityFix v4.5-inject-s` for A13+ `DEVICE` verdict (injects into the Play Services process). The TrickyStore branch does not need it — its companion path is PIF v16 + the keybox.

---

## 6. Acceptance checklist (CLO-11)

- [x] TEESimulator v3.2 declared as default (this file + `redroid-compose-L3.yml` header).
- [x] Selectable via `SPOOFSTACK_L3=teesimulator|trickystore` env-var (§2).
- [x] Documentation explicitly states "DEVICE verdict only, STRONG_INTEGRITY uncountered" (§4).
- [x] Binder-intercept conflict guard — resolver `exit 78` (§3).
- [x] PlayIntegrityFix detector verdict capture seam wired via `INTEGRITY_TARGET_VERDICTS` env-var on the compose service; per-cell capture is the Stability acceptance run's responsibility (deferred, per `SPOOFSTACK-PRESTAGE.md` §8).

> **Note on issue text:** the acceptance criteria say "exit code 7" for the conflict guard; the resolver uses `exit 78` (the canonical F37 hard-block code reused from `container_lifecycle.py`). The discrepancy is documented here rather than re-coded; downstream consumers should treat any non-zero exit from `compose-matrix.sh` as an unrecoverable resolver failure.

---

## 7. Change log

| Date | Change | Author |
|---|---|---|
| 2026-05-16 | Initial decision record — TEESimulator default, TrickyStore fallback | CLO-11 super-agent |
