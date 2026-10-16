# KB Workout

A personal kettlebell workout coach for iPhone, in the style of Apple Fitness. Built with SwiftUI, never published to the App Store.

- **26 workouts, about 30 minutes each:** the Beginner Programme (Sessions A, B and C), plus strength, conditioning, complexes and recovery days.
- **Strength sets:** the big rep target and coaching note are on screen. Tap **Done** and the rest timer starts.
- **Timed work:** intervals, EMOMs, Tabatas and AMRAPs, with a round counter.
- **Voice coaching:** exercises are announced with a 3-2-1 countdown, and music keeps playing (quieter) under it.
- **The screen stays on** during a workout.
- **History:** a weekly minutes goal, your streak, how hard each workout felt, your bell weight and notes.
- **Variety:** "Up Next" rotates your programme sessions, and "Something Different" suggests workouts you haven't done lately.

## How it gets onto the iPhone (no Mac, no paid account)

1. Every push to `main` runs **.github/workflows/build.yml** on a free GitHub macOS runner.
2. That builds an unsigned `KBWorkout.ipa` and publishes it as a GitHub release, together with a `source.json` that SideStore can read.
3. **SideStore** on the iPhone installs the app and signs it with your free Apple ID.

See [docs/INSTALL.md](docs/INSTALL.md) for the iPhone steps.

## Testing

Every push runs unit tests (library, steps, workout engine) and UI tests that drive the app in the iPhone simulator and screenshot every screen. Results go to the `qa-results` branch:

- `summary.md`: passed and failed tests, compile errors, and warnings
- `screenshots/`: one PNG per screen (home, detail, rep set, rest, interval, summary, history…)
- `xcodebuild.log.gz`: the full log

`tools/qa.sh` waits for the latest run and pulls those results locally. The release is only published if the tests pass.

The UI tests launch the app with `-uiTesting` (temporary in-memory history), `-seedHistory` (sample history) and `-timeScale 20` (fast timers).

## Changing workouts

The exercises and workouts are defined in `tools/build_library.py`. Edit it, then run:

```sh
python3 tools/build_library.py   # regenerates KBWorkout/Resources/library.json and prints each workout's length
```

Commit both files. The build fails if `library.json` is out of date.

## Project layout

```
KBWorkout/App         App entry, theme
KBWorkout/Models      Library (exercises/workouts), steps, saved history
KBWorkout/Engine      WorkoutSession: timers, rep sets, rest, cues
KBWorkout/Services    Voice and haptics
KBWorkout/Views       Screens
tools/                Library generator, icon generator, SideStore source writer
project.yml           XcodeGen project spec
```
