# Rationale Note

## Why BLoC/Cubit + Clean Architecture + get_it

I went with Cubit over plain `setState`/Provider because the app has genuinely distinct states to model explicitly (initial, loading, loaded, error) on both the course list and the player, and Cubit keeps that transition logic out of the widget tree and easy to unit test in isolation — which mattered given the assessment explicitly asks for tests around the trickiest logic.

Clean Architecture (data / domain / presentation per feature) was chosen mainly for one concrete reason: the mock JSON datasource needs to be swappable for a real API later without touching the Cubit or the UI. The `CourseRepository` interface lives in the domain layer and is implemented in the data layer against two datasources (a local JSON reader for courses, a Hive reader/writer for progress) — the domain and presentation layers never know where the data actually comes from.

`get_it` was used as a simple service locator for dependency injection instead of `Provider`-based DI, mainly because it keeps constructor wiring in one place (`injection_container.dart`) and plays cleanly with `flutter_bloc`'s `BlocProvider(create: (_) => getIt<SomeCubit>())` pattern.

## How resume playback was implemented, and trade-offs

Progress is modeled as `CourseProgressEntity` (courseId, positionSeconds, percent, updatedAt), persisted in a Hive box keyed by `courseId` (not auto-incremented keys), so each course always has exactly one progress record that gets overwritten, not duplicated.

The save happens at three points, deliberately overlapping for safety rather than relying on a single trigger:
1. **Every 3 seconds** while playing, via a `Timer.periodic` in `CoursePlayerCubit` — frequent enough to feel accurate, infrequent enough not to hammer Hive.
2. **On pause** — immediately, so a deliberate stop is never lost even if the 3-second timer hasn't fired yet.
3. **On screen exit** (`Cubit.close()`) — a final save as a safety net for cases the first two don't cover (e.g. the user backs out mid-second).

On resume, if saved progress exists and the course isn't considered "completed" (`percent >= 95`), the video seeks to the saved position once, right after `VideoPlayerController.initialize()`. If it's already completed, playback intentionally restarts from zero rather than seeking to the very end.

**Trade-offs I'm aware of:**
- Progress is device-local only (Hive), not synced to any account/cloud — closing the app on one device and opening on another loses progress. Fine for this assessment's scope, not fine for a real product.
- The 3-second save interval means in the worst case (app killed by the OS mid-interval, no pause event) up to ~3 seconds of progress can be lost. I considered saving on every position tick instead, but that's dozens of Hive writes per second for no real accuracy gain.
- The original Pixabay video files were replaced with a different video format due to compatibility issues with the `video_player` package. Although the videos played correctly, the package was unable to retrieve their actual duration reliably. After replacing the video format with one fully supported by `video_player`, the application can correctly read the video duration, ensuring that the progress bar and playback timer display accurate information.

## What I'd do differently with more time

* Sync progress to a backend/account instead of only local Hive storage, so progress follows the user across devices.

* Support multi-lesson courses properly. The current mock data has one video per course; a real course entity would need a lessons list, and the progress indicator on the list screen would need to calculate the overall progress based on all lessons instead of mirroring a single video's progress.

* Improve the UI design further to provide a more polished and user-friendly experience.

* Add user authentication to support personalized experiences and better account management.

* Add application localization to support multiple languages.

* Add both dark and light themes to improve accessibility and allow users to choose their preferred appearance.

* Provide more detailed course descriptions explaining what each course offers and what users can expect to learn.

* Add a rating system so users can rate courses and help improve course discovery.
