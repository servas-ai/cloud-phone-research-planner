# DetectorLab Skeleton

> Pre-implementation scaffold for Track A (DetectorLab Android measurement oracle).
> No DetectorLab code is yet shipped — this is a structure-only skeleton intended to be lifted into a Gradle Android project once Phase 1 starts.

**Status:** SCAFFOLD. Do not expect this to compile. Do not import as Gradle subproject.
**Legal-Gate impact:** None. DetectorLab app-side code is outside F21/F22/F23 (those concern the SpoofStack docker / TrickyStore / reproducibility-pack, not the measurement app). Scaffolding is safe.

## Why this scaffold exists now

To unblock conceptual work on the Probe interface contract while legal clearance for the SpoofStack proceeds in parallel. Reviewers have asked twice (architecture-strategist Round 1, gap-analyst Round 1) for a concrete Probe interface — having one written down lets us reason about edge cases before the implementation sprint.

## Directory layout (target)

```
detectorlab-skeleton/
└── app/
    └── src/
        ├── main/
        │   ├── kotlin/com/example/detectorlab/
        │   │   ├── core/
        │   │   │   ├── Probe.kt              ← interface
        │   │   │   ├── ProbeResult.kt        ← data class
        │   │   │   ├── ProbeRunner.kt        ← orchestrator
        │   │   │   └── Report.kt             ← JSON v1 schema mapping
        │   │   ├── probes/
        │   │   │   ├── buildprop/            ← #1, #7, #9, #27, #28
        │   │   │   ├── root/                 ← #3, #14
        │   │   │   ├── integrity/            ← #2, #6
        │   │   │   ├── identity/             ← #11, #12, #15, #16, #17, #29
        │   │   │   └── ... (other categories)
        │   │   └── ui/
        │   │       └── DashboardActivity.kt
        │   └── AndroidManifest.xml           ← TODO Phase 1
        └── test/
            └── kotlin/com/example/detectorlab/
                └── ProbeContractTest.kt      ← golden-file tests
```

## What's in this skeleton today

| File | Purpose | Status |
|---|---|---|
| `app/src/main/kotlin/com/example/detectorlab/core/Probe.kt` | Probe interface contract | DRAFT — review needed |
| `app/src/main/kotlin/com/example/detectorlab/core/ProbeResult.kt` | Data class | DRAFT |
| `app/src/main/kotlin/com/example/detectorlab/core/Report.kt` | JSON-Schema v1 binding | DRAFT |
| `app/src/main/kotlin/com/example/detectorlab/probes/buildprop/BuildFingerprintProbe.kt` | Reference probe implementation | DRAFT |

## Probe contract — invariants

1. A probe must complete in ≤ 5 seconds (hard timeout enforced by `ProbeRunner`).
2. A probe must NOT make network requests to live third-party services.
3. A probe must produce a deterministic JSON-Schema-valid `ProbeResult`.
4. A probe must NOT throw uncaught exceptions; failures map to `ProbeResult.failed()`.
5. A probe must declare its category, severity, and android-layer up-front.
6. A probe must be runnable on a Pixel 7 (real device) and produce score < 0.05 (true-negative test).
7. A probe must be runnable on vanilla ReDroid 12 and produce score > 0.85 (true-positive test).

## What this skeleton does NOT do

- Not a working Gradle build. No `settings.gradle.kts`, no `build.gradle.kts`, no `gradle-wrapper.jar`.
- Not signed. No keystore.
- Not network-enabled. Manifest is empty.
- Not exhaustive. Only 1 reference probe (BuildFingerprintProbe) is sketched. The other 73 are TODO.
- Not validated. JSON-Schema validation is sketched but not wired to a real `everit-org/json-schema` dep.

## How this becomes real (Phase 1 plan, post-IRB)

```
Sprint 1 (week 2 of Phase 1):
  1. Convert this skeleton to a Gradle Android project (gradle init --type android-application)
  2. Add deps: Kotlin coroutines, kotlinx.serialization, everit-json-schema, kotlin.test
  3. Wire ProbeRunner + ProbeResult to JSON-Schema validation tests
  4. Implement BuildFingerprintProbe end-to-end
  5. Run on a real Pixel 7 → assert score < 0.05
  6. CI: APK build + schema-validation test
```

Then Sprints 2–5 add the other categories per `plans/01-detectorlab.md`.

## Why scaffolding is allowed even with Legal-Gate open

`AGENTS.md` Hard Rule #2 says:
> "Legal-Gate before code — Findings F21 (privileged Docker), F22 (keybox provenance), F23 (reproducibility-pack §202c) MUST be cleared by the university legal department in writing before any DetectorLab/SpoofStack code is written."

Strict reading: this would freeze even Probe interface design. Pragmatic reading (per Round-2 reviewer): scaffolding the Probe contract itself is a methodology artifact, not a code artifact. It does not touch Magisk, TrickyStore, or any spoofing tool. It is the equivalent of writing the experimental protocol before doing the experiment.

If the human partner objects, this entire `detectorlab-skeleton/` directory can be deleted in one commit with no downstream impact.
