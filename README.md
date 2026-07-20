# Continua — Mini Course Player

A small Flutter app built for the Almentor Mobile Engineering Intern technical assessment: browse courses and watch lessons with your progress remembered, even after closing and reopening the app.

## Features

- **Course List** — browse all courses with thumbnail, title, description, and a live progress indicator per course.
- **Course Detail / Player** — plays the course video (`video_player` + `chewie`) and resumes exactly where you left off.
- **Resume playback** — your position is saved locally (Hive) every few seconds, on pause, and on exit, so leaving a video at 40% and coming back later resumes near that point.
- **Offline handling** — a friendly retry state if the course list can't be fetched.
- **Video failure handling** — an inline error + retry state if a video fails to load, instead of a silent crash or infinite spinner.
- **Playback speed control** and **fullscreen** support.
- **Animated splash screen** with app branding.

## Tech Stack

| Layer | Tools |
|---|---|
| State management | `flutter_bloc` (Cubit) |
| Architecture | Clean Architecture (data / domain / presentation per feature) |
| Dependency injection | `get_it` |
| Local persistence | `hive`, `hive_flutter` |
| Video playback | `video_player`, `chewie` |
| Networking mock | local JSON asset (`assets/courses.json`), simulated latency |
| Error handling | `dartz` (`Either<Failure, T>`) |
| Images | `cached_network_image` |
| Connectivity check | `connectivity_plus` |
| Testing | `flutter_test`, `mocktail` |

## Getting Started

### Prerequisites
- Flutter SDK (3.x, Dart ^3.12)
- An emulator or physical device

### Setup

```bash
# 1. Clone the repo
git clone https://github.com/Abdallahmusa310/continua.git
cd continua

# 2. Install dependencies
flutter pub get

# 3. (Only needed if you modify any @HiveType model) Regenerate the Hive adapter
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run the app
flutter run
```

### Running tests

```bash
flutter test
```

### Building an APK

If you'd rather install the app directly on a physical Android device instead of running it through an emulator/`flutter run`, build a standalone APK:

```bash
# Debug APK (faster build, larger file, includes debugging info)
flutter build apk --debug

# Release APK (optimized, smaller, what you'd actually ship)
flutter build apk --release
```

The generated APK will be at:
```
build/app/outputs/flutter-apk/app-debug.apk    # for --debug
build/app/outputs/flutter-apk/app-release.apk  # for --release
```

To install it on a connected device or running emulator directly from the terminal:
```bash
flutter install
```

Or copy the APK file to a physical device and open it there to install manually (you may need to allow "install from unknown sources" in the device's settings first).

> Note: `flutter build apk --release` builds one universal APK covering all device architectures by default, which is larger than necessary. For a smaller, per-architecture build (useful for testing on a specific device, not for submission), use:
> ```bash
> flutter build apk --release --split-per-abi
> ```

## Project Structure

```
lib/
  core/
    di/                     # get_it dependency injection setup
    error/                  # Failure / Exception base classes
    presentation/splash/    # Animated splash screen
  features/
    home/
      data/                 # Models, datasources, repository implementation
      domain/                # Entities, repository contract, usecases
      presentation/          # Cubits, Home screen, widgets
    course_view/
      widgets/               # Video player section, ready player, fullscreen player
      course_detail_screen.dart
assets/
  courses.json               # Mock course data
  images/                    # Splash logo
test/
  ...                        # Unit + widget tests
```

## Mock Data

Course data is loaded from `assets/courses.json` via a local datasource that simulates a small network delay, so swapping in a real API later only requires changing the datasource implementation — the rest of the app (domain, presentation) stays untouched.

## Notes

- Video files are streamed from public URLs (Pixabay). If a video's metadata doesn't report a duration (a known limitation of some CDN-hosted files), the app falls back to the course's mock `durationSeconds` so the progress bar and timer still work correctly.
- See `RATIONALE.md` for the reasoning behind key architectural decisions and trade-offs.
- See `AI_DISCLOSURE.md` for details on AI tool usage during development.
