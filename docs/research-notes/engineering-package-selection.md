# Engineering Package Selection and Project Approach

Date: 2026-05-03
Author: Codex GPT-5
Status: DRAFT - package research note for human review
Scope: DetectorLab and isolated university lab environment only

## Summary

This note translates the current research plan into an engineering package
matrix. The project should be built as a two-track measurement system:

- Track A, `DetectorLab`: an Android measurement app that collects probe
  values and emits deterministic JSON reports.
- Track B, lab stack under test: controlled ReDroid-based configurations that
  are measured only by `DetectorLab` inside the university lab.

The goal is not a "perfect Android emulator". The engineering target is a
reproducible experiment harness that shows which Android detection surfaces
remain observable after each controlled lab configuration change.

## Hard Scope Boundaries

| Boundary | Engineering consequence |
|---|---|
| DetectorLab-only measurement | No external production-service clients are dependencies. |
| Isolated university lab | Network probes use local lab endpoints or passive host-side observation. |
| Legal-Gate F21/F22/F23 remains closed | No implementation or package selection for keybox handling, privileged container manifests, or sensitive reproducibility packs. |
| Public repo must stay publishable | Track B stays manifest/spec-level until human gates approve concrete implementation. |
| Plan immutability | This file is a research note; `plans/00-04` are not modified. |

## Confidence Table

| Area | Recommendation | Confidence | Why |
|---|---:|---|---|
| Android app language | Kotlin | High | Existing skeleton is Kotlin, Android docs treat Kotlin as the primary Android path. |
| Android build | Android Gradle Plugin plus Gradle version catalog | High | AGP 9.0 is current as of Jan 2026, but the first implementation should pin a known-good AGP/Gradle/JDK tuple in `libs.versions.toml`. |
| Probe concurrency | `kotlinx-coroutines-android` plus `kotlinx-coroutines-test` | High | Probe timeouts and non-blocking execution map cleanly to coroutines. |
| Report serialization | `kotlinx-serialization-json` | High | Reflectionless JSON serialization fits deterministic probe reports. |
| On-device JSON Schema validation | Avoid for MVP | High | The APK should emit typed JSON; host-side `jsonschema` should validate against the canonical schema. This avoids heavy Android runtime schema dependencies. |
| Android test stack | `kotlin.test`, JUnit, AndroidX Test; Robolectric only where Android framework shadows are needed | High | Keep most probe logic testable with fake `ProbeContext`; add Robolectric selectively. |
| Runner language | Python 3.12+ | High | Existing runner SPEC and downstream stats stack are Python-native. |
| Runner CLI | `typer` plus `rich` | High | Type-hint-driven CLI with readable operator progress. |
| Manifest models | `pydantic` v2 | High | Strong typed config validation before any run starts. |
| Canonical report/schema validation | `jsonschema` with Draft 2020-12 | High | Matches existing SPEC and supports modern JSON Schema. |
| Docker lifecycle | Prefer `python-on-whales` for Compose v2; use Docker SDK only for low-level inspect gaps | Medium | `python-on-whales` maps to Docker Compose v2; Docker SDK is official but lower-level for Compose workflows. |
| ADB control | Start with subprocess wrapper around pinned Android SDK `adb` | Medium | Avoids fragile ADB wrapper dependency; can be replaced later if runner code becomes noisy. |
| Journaling | Python stdlib `sqlite3` | High | No dependency needed; enough for resumable runs. |
| Structured logs | `structlog` | High | Fits JSONL logs in the runner SPEC. |
| Metrics | `prometheus-client` textfile collector | High | Good fit for batch/cron-style runner status without a persistent exporter. |
| Analysis tables | `pandas`, `numpy`, `scipy` | High | Standard data/scientific stack for aggregation, vectors, and statistical tests. |
| Multiple-testing correction | `statsmodels` | High | Has built-in Benjamini-Hochberg style p-value correction via `multipletests`. |
| ML adversary baseline | `scikit-learn`; `xgboost` optional | Medium | `scikit-learn` is enough for RandomForest/logistic/SVM baselines; XGBoost is useful for L_AdvB but should remain optional until analysis design is locked. |
| Plotting | `matplotlib` plus optional `seaborn` | Medium | Enough for heatmaps and paper figures; keep output reproducible by pinning versions. |
| Package locking | `pyproject.toml` plus lockfile; Gradle `libs.versions.toml` | High | Reproducibility requires exact version pins before data collection. |

## Recommended Architecture by Package Boundary

| Layer | Repository path | Main packages | Output |
|---|---|---|---|
| Detector core | `detectorlab-skeleton/app/src/main/kotlin/.../core` | Kotlin, coroutines, kotlinx.serialization | `Probe`, `ProbeResult`, `Report`, `ProbeRunner` |
| Detector probes | `detectorlab-skeleton/app/src/main/kotlin/.../probes` | Android SDK APIs, small local helpers | 60+ probe results with evidence and confidence |
| Android tests | `detectorlab-skeleton/app/src/test` and `androidTest` | kotlin.test, JUnit, AndroidX Test, selective Robolectric | Contract tests and golden JSON report fixtures |
| Runner CLI | `experiments/runner` | Typer, Rich, Pydantic | `runner run`, `verify`, `aggregate`, `journal` |
| Container lifecycle | `experiments/runner/container_lifecycle.py` | python-on-whales, PyYAML or ruamel.yaml | Safe Compose up/down with policy preflight |
| Report validation | `experiments/runner/report_validator.py` | jsonschema Draft 2020-12 | Accept/quarantine decision per report |
| Persistence | `experiments/runs` | sqlite3, pathlib, atomic writes | Run JSON plus journal state |
| Observability | `experiments/runner/observability.py` | structlog, prometheus-client | JSONL logs and `.prom` textfile metrics |
| Analysis | `experiments/analysis` | pandas, numpy, scipy, statsmodels, scikit-learn | CSV/Parquet aggregates, p-values, heatmaps, ML baseline |

## Two-Track Engineering Plan

| Phase | Track A: DetectorLab | Track B: lab stack under test | Shared outputs |
|---|---|---|---|
| 0. Gates and version lock | Freeze probe schema and package pins. | Keep implementation paused where F21/F22/F23 apply. | Approval log, OSF preregistration, version catalog, lockfile. |
| 1. Minimal detector | Build Gradle Android app around existing Kotlin skeleton. Implement BuildFingerprint probe end-to-end. | Use only known-safe L0a-style baseline description or mock target. | Golden JSON report, host-side schema validation. |
| 2. Probe expansion | Add probe categories in priority order: buildprop, root, emulator, identity, runtime, sensors, network. | Do not add mitigation modules in public repo unless explicitly cleared. | Probe coverage table and fixtures. |
| 3. Runner MVP | Package Typer runner with manifest validation, ADB wrapper, report pull, JSON Schema validation, and atomic persistence. | Runner refuses unsafe Compose policy such as `privileged:true`. | Repeatable N-run execution against mock target. |
| 4. Controlled lab configs | DetectorLab stays unchanged and acts as measuring instrument. | Human-cleared configs are introduced one layer at a time. | Detection matrix: probes x config x run. |
| 5. Analysis | Export stable probe vectors. | Treat each config as the subject under test, not as production tooling. | Heatmap, BH-FDR corrected statistics, effect sizes, ML baseline. |
| 6. Paper/release | Publish DetectorLab app and methodology. | Public artifact remains filtered by the reproducibility split. | Paper figures, thesis chapter, publishable OSS. |

## Package Decisions I Would Treat as Stable Now

1. Use Kotlin plus coroutines for DetectorLab.
2. Use `kotlinx.serialization` for report JSON; validate schema on the host, not inside the app.
3. Use Python for the runner and analysis pipeline.
4. Use `pydantic` for runner manifest models and `jsonschema` for canonical report validation.
5. Use `sqlite3` journaling for resumability rather than inventing a custom state file format.
6. Use `pandas`/`numpy`/`scipy`/`statsmodels` as the statistics baseline.
7. Use `scikit-learn` first for ML baselines; add `xgboost` only when L_AdvB is actually implemented.

## Package Decisions Still Needing Human/Reviewer Sign-Off

| Decision | Current leaning | Reason to review |
|---|---|---|
| AGP exact version | Pin a known-good AGP 9.x/Gradle/JDK combination before implementation | AGP 9.0 is a major release and may create migration friction; pinning should follow a small build spike. |
| `python-on-whales` vs Docker SDK | `python-on-whales` for Compose v2 lifecycle, Docker SDK only if needed | Official Docker SDK is better documented, but Compose orchestration is more direct through `python-on-whales`. |
| ADB wrapper dependency | Start with subprocess calls to pinned `adb` | Lower dependency risk; wrapper package can be introduced later if repeated parsing becomes brittle. |
| Robolectric | Optional and narrow | Android docs recommend testable architecture first; use Robolectric only for framework-dependent probe tests. |
| XGBoost | Optional analysis extra | Useful for adversarial ML realism, but not needed for the first reproducible stats pipeline. |

## Dependencies to Avoid in This Repo

| Avoid | Why |
|---|---|
| External production-service SDKs or automation clients | Violates Scope-Lock and would change the project from measurement research into production-service testing. |
| Keybox download/source packages | Legal-Gate F22 is human-only. |
| Runtime spoofing module dependencies in public code | Legal-Gate and reproducibility-split risk. |
| Heavy Android DI/UI frameworks for MVP | DetectorLab is a measurement instrument; every extra framework adds failure surface without improving probes. |
| On-device general JSON Schema engines | Host-side validation is simpler, auditable, and reproducible. |

## Source Notes

- Android coroutines: Android Developers,
  [Kotlin coroutines on Android](https://developer.android.com/kotlin/coroutines).
- Android Gradle Plugin: Android Developers,
  [AGP release notes](https://developer.android.com/build/releases/gradle-plugin)
  and [AGP roadmap](https://developer.android.com/build/releases/gradle-plugin-roadmap).
- Kotlin serialization: Kotlin documentation,
  [Serialization](https://kotlinlang.org/docs/serialization.html) and
  [`kotlinx.serialization.json`](https://kotlinlang.org/api/kotlinx.serialization/kotlinx-serialization-json/kotlinx.serialization.json/).
- Gradle dependency pinning: Gradle,
  [Version Catalogs](https://docs.gradle.org/current/userguide/version_catalogs.html).
- Python CLI/config: [Typer](https://typer.tiangolo.com/) and
  [Pydantic](https://docs.pydantic.dev/).
- JSON Schema validation: Python
  [`jsonschema`](https://python-jsonschema.readthedocs.io/) and Draft 2020-12 support.
- Docker lifecycle: Docker,
  [Engine SDKs](https://docs.docker.com/reference/api/engine/sdk/),
  [Docker SDK for Python](https://docker-py.readthedocs.io/), and
  [`python-on-whales` Compose v2](https://gabrieldemarmiesse.github.io/python-on-whales/sub-commands/compose/).
- Testing: [pytest](https://docs.pytest.org/en/stable/contents.html),
  AndroidX Test, and
  [Robolectric](https://developer.android.com/training/testing/local-tests/robolectric).
- Observability: [structlog](https://www.structlog.org/en/stable/) and
  Prometheus Python client
  [textfile collector](https://prometheus.github.io/client_python/exporting/textfile/).
- Analysis: [pandas](https://pandas.pydata.org/pandas-docs/stable/),
  [NumPy](https://numpy.org/doc/), [SciPy](https://docs.scipy.org/),
  [statsmodels](https://www.statsmodels.org/stable/),
  [scikit-learn](https://scikit-learn.org/stable/model_selection.html), and
  [XGBoost](https://xgboost.readthedocs.io/en/stable/).

## Immediate Next Implementation Slice

The smallest useful engineering slice is:

1. Add Android Gradle project files around `detectorlab-skeleton`.
2. Pin Kotlin, AGP, coroutines, serialization, and test dependencies in `gradle/libs.versions.toml`.
3. Make the existing BuildFingerprint probe compile and emit one schema-shaped report.
4. Add host-side Python schema validation with `jsonschema`.
5. Add a runner dry-run mode that validates manifests and fake reports without starting ReDroid.

This gets the project from "plan plus skeleton" to "compilable measurement instrument plus reproducible host validation" without entering any Legal-Gated Track B implementation.
