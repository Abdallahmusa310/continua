# AI-Use Disclosure

## Tools used

Claude — used throughout development as a coding assistant in a conversational workflow (not an autonomous agent; every file was reviewed and applied manually).

## What it was used for

* **Boilerplate generation**: Cubit/State classes, the `get_it` dependency injection container, the Hive `TypeAdapter` for `CourseProgressModel`.

* **UI implementation**: the course list screen (floating/frosted app bar), the course card redesign, the splash screen animation, the course detail/player screen (including the Hero transition between the list and the player).

* **Debugging**: several real bugs were diagnosed and fixed with AI assistance during the session, including:

  * A `StateError: Cannot emit new states after calling close` race condition in `CoursePlayerCubit` (fixed with `isClosed` guards around `emit()` calls after `await` points).
  * A `ProviderNotFoundException` caused by wrapping a `BlocBuilder` *inside* a `Hero` widget instead of alongside it (Hero flights temporarily detach their child from the normal widget tree, breaking `Provider`/`BlocProvider` lookups).
  * A video progress bar that appeared to "race" to 100% almost instantly — root-caused to some CDN-hosted video files not reporting real duration metadata to `video_player`, addressed with a fallback-duration mechanism using the mock JSON's `durationSeconds`.

* **Test writing**: the unit tests for `CourseProgressEntity` and `CourseRepositoryImpl` (mocked with `mocktail`), and the widget tests for `CoursesCard`.

* **This documentation**: README, this disclosure, and the rationale note were drafted with AI assistance and edited for accuracy against the actual final code.

## How the output was verified

* Every generated file was run on a real Android emulator after each meaningful change, not just assumed to work from the code alone.

* Bugs surfaced during actual testing (e.g. the resume-position race condition, the Hero/Provider crash, the zero-duration video issue) were reproduced first, then diagnosed with AI help, then re-tested on-device to confirm the fix before moving on.

* `flutter test` was run locally after the test files were added; all 14 tests pass. Test expectations were adjusted by hand where the AI-generated assertions didn't match the actual widget text (e.g. `"Start Learning"` vs. an initially assumed `"Start course"` label).

* Architectural decisions (Cubit vs. other state management, Clean Architecture layering, the local-only Hive persistence trade-off) were discussed and consciously chosen, not accepted as unexamined defaults — the reasoning for each is in `RATIONALE.md`.
