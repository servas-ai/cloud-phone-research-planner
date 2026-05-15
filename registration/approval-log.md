# Approval Log

**Project:** Empirical Layer-by-Layer Evaluation of Android Container Detection Resistance
**Status:** DRAFT - all gates pending; Phase 0 is blocked
**Owner:** TODO
**Purpose:** Auditable Phase-0 gate evidence for F12.

> Store approval letters, exports, and legal opinions in the institutional
> repository. This public file records only non-sensitive metadata and pointers.

## Gate Table

| Gate | Required before | Decision | Date | Evidence pointer | Owner | Notes |
|---|---|---|---|---|---|---|
| Ethics / scope review | First hypothesis-test run | PENDING - BLOCKS_PHASE0 | TODO | TODO: institutional path / ticket ID | TODO: PI | Use approval, waiver, or technical-only scope note. |
| IT security | Any networked lab run | PENDING - BLOCKS_PHASE0 | TODO | TODO | TODO: IT security | Must include egress policy and incident contact. |
| F21 legal | Privileged or host-sensitive deployment | PENDING - BLOCKS_PHASE0 | TODO | TODO | TODO: legal + IT security | Human-only Legal-Gate. |
| F22 legal | Any key-material handling | PENDING - BLOCKS_PHASE0 | TODO | TODO | TODO: legal | Human-only Legal-Gate. |
| F23 legal | Public or institutional reproducibility release | PENDING - BLOCKS_PHASE0 | TODO | TODO | TODO: legal | Human-only Legal-Gate. |
| OSF pre-registration | First hypothesis-test run | PENDING - BLOCKS_PHASE0 | TODO | TODO: OSF URL | TODO: PI | Must precede all pre-registered analyses. |

## Run Boundary

A hypothesis-test run means storing or analysing a DetectorLab report for
research results.

Allowed before approval:

- Synthetic fixture validation that does not touch restricted containers.
- Documentation edits and review rounds.
- Schema linting and static checks.

Not allowed before approval:

- Real-device baseline runs for research results.
- Sensor-trace recording from people.
- Container or networked lab runs intended for analysis.
- Any run artifact preserved as research results.

## Change Log

| Date | Change | Author |
|---|---|---|
| 2026-05-03 | Initial approval-log skeleton for F12. | Codex GPT-5 |

