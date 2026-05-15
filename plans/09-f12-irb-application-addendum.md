# Addendum 09 - F12 Technical Ethics / Scope Gate

Date: 2026-05-03
Author: Codex GPT-5
Triggered by: Finding F12 from `plans/05-validation-feedback.md`
Status: DRAFT - awaiting human review

## Summary

Finding F12 requires the ethics step to become an explicit Phase-0 gate.
This addendum scopes that gate as a purely technical university-lab review:
no people, no accounts, no user profiles, no production-service
traffic, and no people-derived traces.

The draft keeps the security-relevant gates that are still necessary for this
project: IT lab isolation, Legal-Gate F21/F22/F23, OSF pre-registration, and
the public/private reproducibility split.

## Research Conducted

- Local repo review -> `README.md`, `AGENTS.md`,
  `plans/05-validation-feedback.md`, project skill, OSF draft, and
  `docs/ethics-and-scope.md` -> F12 is AI-progressable, not F21/F22/F23.
- Local scope review -> no change to immutable `plans/00-04`.
- User clarification -> the university setup is a technical security project
  with no people or user-data component; the F12 package was narrowed
  accordingly.

## Proposed Change

- Files patched:
  - `registration/irb-application.md`
  - `registration/approval-log.md`
  - `docs/ethics-and-scope.md`
- Change type: new technical scope files plus scope-language correction.

Diff sketch:

```markdown
# Technical Ethics / Scope Application Skeleton

Scope:
- technical Android container-detection experiment
- isolated university lab
- DetectorLab only as measurement target
- no people, accounts, user profiles, or live third-party platforms

Phase-0 gates:
- ethics / technical scope review
- IT security lab-isolation memo
- Legal-Gate F21/F22/F23
- OSF pre-registration
- DetectorLab schema lock
```

## Open Questions for Human Partner

1. Which university body should sign the technical-only scope note?
2. Who owns the IT-security lab-isolation memo?
3. Who records the F21/F22/F23 legal decisions?
4. Should H3 use only synthetic / lab-device traces, or should sensor-trace
   work be deferred until a separate scope document exists?

## Reviewer Feedback

Prior reviewer rounds on the broader review version are superseded by
the user's clarification that this is a technical-only university lab project.
The new draft should receive a fresh reviewer pass before commit / push.

## Approval Gate

- [ ] Fresh multi-reviewer round completed on technical-only scope.
- [x] Legal-Gate check passed for this addendum: F12 itself is not F21/F22/F23;
      the draft preserves F21/F22/F23 as separate human-only gates.
- [x] Pre-registration impact assessed: no changes to H1-H4.
- [ ] Human partner approved.
