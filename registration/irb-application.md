# Technical Ethics / Scope Application Skeleton

**Project title:** Empirical Layer-by-Layer Evaluation of Android Container Detection Resistance
**Repository:** https://github.com/servas-ai/cloud-phone-research-planner
**Version:** 0.3 draft
**Date drafted:** 2026-05-03
**Status:** DRAFT - for university ethics board, IT security, and legal review
**Finding trigger:** F12 from `plans/05-validation-feedback.md`

> This document scopes the project as a purely technical university lab
> evaluation. It assumes no people, no user accounts, no user
> profiles, and no live third-party platform interaction. If that assumption
> changes, this document must be replaced before any affected work starts.

---

## 1. Administrative Information

| Field | Entry |
|---|---|
| Principal investigator | TODO: name, institute, university email |
| Supervisor / chair | TODO |
| Research group | TODO |
| Faculty / department | TODO |
| Ethics board / scope review ID | TODO |
| IT security contact | TODO |
| Legal contact for F21/F22/F23 | TODO |
| Gate owner | TODO: person responsible for `registration/approval-log.md` |
| Planned study start | Not before Phase-0 gates clear |
| Planned study end | TODO |
| Funding / conflicts of interest | TODO |

## 2. Plain-Language Project Summary

The project studies which Android-side detection signals remain robust when
an Android container stack is evaluated in an isolated university lab. The
measurement target is the project's own DetectorLab application.

The study does not contact third-party production services, does not create
accounts on external platforms, does not process user profiles, and does not
distribute operational misuse tooling.

The intended contribution is a reproducible measurement methodology, an open
DetectorLab measurement instrument, and an academic paper or thesis chapter.
Public release material is limited to methodology, DetectorLab code, aggregate
results, and non-sensitive reproducibility artifacts.

## 3. Study Classification

| Question | Proposed answer |
|---|---|
| Human-subjects study? | No. The core experiment is a technical system evaluation. |
| Human participation? | No. |
| User accounts or user profiles? | No. |
| Live third-party platform traffic? | No. |
| Biomedical / clinical intervention? | No. |
| Vulnerable populations involved? | No. |
| Misuse relevance? | Yes. The project concerns security methodology and therefore uses a public/private reproducibility split. |

Out-of-scope by design:

- Real user accounts or profile data.
- Production-service interaction.
- Account automation.
- Raw traces from people.
- Public release of key material or reconstruction-ready sensitive manifests.

## 4. Research Question and Hypotheses

**Research question:** Which Android detection methods remain robust against
container-based virtualization with ARM-native cloud-phone stacks, and which
signals can be reduced layer by layer?

Hypotheses H1-H4 are frozen in `plans/00-master-plan.md` and mirrored in
`registration/osf-preregistration.md`. This skeleton does not modify them.

| Hypothesis | Scope relevance |
|---|---|
| H1 build and identity probes | Technical telemetry from lab devices and containers. |
| H2 hardware attestation | Legal-Gate dependent; no key material is handled without written clearance. |
| H3 sensor signatures | Only synthetic or lab-device traces unless a new approved scope is created. |
| H4 network egress | Lab-network metadata only; no third-party production-service traffic. |
| H5 coherence metric | Offline analysis of approved DetectorLab run reports if accepted in OSF registration. |

## 5. Phase-0 Gating

Technical study work may begin only after all applicable exit criteria are met:

- Ethics board or institutional scope review recorded in
  `registration/approval-log.md`.
- IT security review for lab isolation completed.
- Legal-Gate F21/F22/F23 resolved in writing where applicable.
- OSF pre-registration uploaded before the first hypothesis-test run.
- DetectorLab probe schema locked for the first collection wave.

The approval evidence packet must include, at minimum:

| Gate | Evidence required | Owner | Phase-0 exit effect |
|---|---|---|---|
| Ethics / scope review | Approval, waiver, or "technical-only" scope note with date | PI | Blocks hypothesis-test runs. |
| IT security | Lab-isolation memo, allowed egress list, incident contact | IT security | Blocks networked lab runs. |
| F21 legal | Written decision on container privileges and host-risk controls | Legal + IT security | Blocks privileged or equivalent host-sensitive deployment. |
| F22 legal | Written decision on key material provenance | Legal | Blocks key-material handling. |
| F23 legal | Written decision on public vs. institutional reproducibility split | Legal | Blocks public reproducibility release. |
| OSF | Timestamped pre-registration URL | PI | Blocks hypothesis-test runs. |

For this study, a hypothesis-test run means storing or analysing a DetectorLab
run report for research results. Pure tooling dry-runs are allowed before the
gate only if they use synthetic fixtures, do not touch restricted containers,
do not preserve run artifacts as research results, and are recorded as
non-research dry-runs.

## 6. Technical Runs

The experiment runner starts a clean lab configuration, installs DetectorLab,
executes the approved probe set, exports a JSON report, validates the report
schema, and tears down the lab state. Runs are repeated according to the
pre-registered design.

No live third-party platform is contacted. Network egress is restricted to lab
infrastructure and explicitly approved endpoints needed for system operation,
if any.

## 7. Technical Artifacts

| Artifact | Examples | Purpose | Public release |
|---|---|---|---|
| Probe report JSON | Probe ID, score, confidence, evidence class | Hypothesis testing and reproducibility | Aggregate or schema-valid example only |
| Lab device metadata | Model family, OS version, build fingerprint class | Baseline comparison | Generalized where possible |
| Container metadata | Layer ID, manifest hash class, run ID | Reproducibility and drift detection | Non-reconstructive summary only |
| Synthetic / lab sensor traces | Accelerometer / gyroscope / magnetometer series | H3 feasibility and classifier evaluation | No raw traces in public repo |
| Lab network metadata | Lab egress class, local test endpoint results | H4 evaluation | Aggregate only |
| Operator notes | Run notes, incident notes | Quality control | No personal names in public artifacts |

## 8. Technical Risk Assessment

| Risk | Severity | Likelihood | Mitigation |
|---|---:|---:|---|
| Misuse of reproducibility artifacts | High | Medium | Public/private split; no keyboxes, exact sensitive manifests, or reconstruction-ready image hashes in public. |
| Lab traffic reaches third-party production services | Medium | Low | Isolated VLAN, egress allowlisting, pre-run network checks. |
| Hypothesis drift after runs | Medium | Low | OSF pre-registration and amendment log before analysis. |
| Host or container security incident | High | Low | IT security review, no privileged deployment before F21 clearance, incident stop rule. |
| Scope creep into people or user data | High | Low | Stop rule: replace this scope document before any such work starts. |

## 9. Access Control and Artifact Handling

- Raw lab artifacts stored on university-managed or encrypted lab storage.
- Access limited to named project members.
- No personal cloud sync for raw lab artifacts or sensitive manifests.
- Public GitHub repository receives only approved documents, code, aggregate
  results, and non-sensitive examples.
- Sensitive manifests and exact reconstruction material remain institutional.
- Public-release candidates are checked against the reproducibility split.

## 10. Publication and Reproducibility Plan

Public release may include:

- DetectorLab measurement code.
- Probe schema and non-sensitive examples.
- Pre-registration, methodology, analysis scripts, and aggregate results.
- Detection-resistance heatmaps without sensitive reconstruction details.

Public release must not include:

- Keyboxes or key material.
- Exact sensitive module-version manifests where they enable full reconstruction.
- Container image hashes that enable reconstruction of restricted stacks.
- Raw traces that were not explicitly cleared for publication.

## 11. Stop and Escalation Rules

The study pauses and escalates to the human partner, ethics board, IT security,
or legal contact if:

- The technical-only scope is unclear or exceeded.
- User accounts, user profiles, or people-derived traces become necessary.
- Third-party production-service contact is observed.
- F21/F22/F23 clearance is needed but missing.
- A real-product vulnerability is discovered during research.
- The approved pre-registration requires amendment.
- Any approval evidence row in `registration/approval-log.md` is missing,
  expired, or narrower than the planned activity.

## 12. Attachments to Prepare

- [ ] OSF pre-registration draft: `registration/osf-preregistration.md`
- [ ] Ethics and scope statement: `docs/ethics-and-scope.md`
- [ ] Approval log: `registration/approval-log.md`
- [ ] Probe schema: `docs/probe-schema.md`
- [ ] Threat model: `docs/threat-model.md`
- [ ] Runner specification: `experiments/runner/SPEC.md`
- [ ] IT security lab-isolation memo
- [ ] Legal-Gate written decisions for F21/F22/F23, where applicable

## 13. Approval Checklist

- [ ] Ethics board or institutional scope review recorded.
- [ ] IT security review completed.
- [ ] Legal-Gate decisions recorded.
- [ ] OSF pre-registration uploaded.
- [ ] Technical-only scope confirmed.
- [ ] No hypothesis-test runs occurred before approval.
