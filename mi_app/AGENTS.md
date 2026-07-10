# PROJECT KNOWLEDGE BASE

**Generated:** 2026-07-10
**Commit:** c3793ec
**Branch:** main

## OVERVIEW

Small Flutter sample app with three feature demos: calculator, heroes list, and NASA APOD. App code is under `lib/`; platform folders are mostly Flutter-generated boilerplate.

## STRUCTURE

```text
mi_app/
├── lib/
│   ├── main.dart          # MaterialApp + home menu + direct Navigator.push links
│   ├── calculator/        # Calculator UI widgets
│   ├── heroes/            # Heroes form/list widgets
│   ├── apod/              # NASA APOD page, HTTP call, video/image rendering
│   └── model/             # Calculator/APOD models plus unused Tetris experiments
├── test/                  # Calculator unit tests + app widget navigation test
├── android/ ios/ macos/ linux/ web/ windows/  # generated platform shells
├── pubspec.yaml           # deps: http, video_player, flutter_lints
└── analysis_options.yaml  # package:flutter_lints/flutter.yaml only
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| App startup/menu | `lib/main.dart` | `MyApp` sets theme; `MyHomePage` pushes feature pages directly. |
| Calculator behavior | `lib/model/calculator_model.dart` | Stateful parser; tests assert display strings. |
| Calculator UI | `lib/calculator/` | Page + display + keyboard split. |
| Heroes feature | `lib/heroes/` | In-memory list in `HeroFormWidget` state. |
| APOD feature | `lib/apod/apod_page.dart` + `lib/model/apod.dart` | Fetches NASA APOD with `DEMO_KEY`; handles image, mp4, YouTube fallback. |
| Tests | `test/calculator_test.dart`, `test/widget_test.dart` | Spanish test names; widget tests exercise Calculator route. |
| Platform changes | `android/`, `ios/`, `macos/`, `linux/`, `web/`, `windows/` | Touch only for platform-specific config. |

## CODE MAP

| Symbol | Type | Location | Role |
|--------|------|----------|------|
| `main()` | function | `lib/main.dart` | Runs `MyApp`. |
| `MyApp` | widget | `lib/main.dart` | Material app, seeded red color scheme, Material 3. |
| `MyHomePage` | widget | `lib/main.dart` | Menu for Calculator, Heroes, APOD. |
| `Calculator` | model | `lib/model/calculator_model.dart` | Calculator state machine and arithmetic. |
| `CalculatorPage` | widget | `lib/calculator/calculator.dart` | Calculator route shell. |
| `KeyboardWidget` | widget | `lib/calculator/calculator_keyboard.dart` | 4x4 circular button grid. |
| `HeroesPage` | widget | `lib/heroes/heroes_page.dart` | Heroes route shell. |
| `HeroFormWidget` | widget/state | `lib/heroes/heroes_page.dart` | Owns `TextEditingController` and heroes list. |
| `Apod` | model | `lib/model/apod.dart` | NASA response model and media flags. |
| `ApodPage` / `ApodWidget` | widget/state | `lib/apod/apod_page.dart` | Fetches APOD and renders picker/info. |
| `MyVideoPlayerWidget` | widget/state | `lib/apod/apod_page.dart` | Inline mp4 player where platform supports it. |

## CONVENTIONS

- Imports use package paths (`package:mi_app/...`) for app files.
- Feature widgets are grouped by demo under `lib/<feature>/`; shared/simple models live in `lib/model/`.
- Current app uses direct `StatefulWidget` state, not Provider/BLoC/GetX.
- Tests include Spanish descriptions; keep new calculator tests near `test/calculator_test.dart`.
- `analysis_options.yaml` has only default Flutter lints; do not assume stricter local style.

## ANTI-PATTERNS (THIS PROJECT)

- Do not treat platform folders as app architecture; they are generated shells unless a spec targets platform config.
- Do not add a heavy state-management package for the current scale; use local state unless the feature grows shared state.
- Do not put new API/network logic directly in widgets if it becomes reused; APOD currently does this only because it is one small demo.
- Do not rely on the APOD `DEMO_KEY` for production or high-volume testing.
- Do not reuse the Tetris files as current app pattern; they are standalone experiments and not wired into `main.dart`.

## UNIQUE STYLES

- App is a menu of learning/demo pages, not a layered production app yet.
- Calculator tests assert exact display text like `12.0 + 3.0 = 15.0`.
- APOD media classification is stored as mutable flags on `Apod` after `fromJson`.
- Current UI has some rough formatting; prefer `dart format` before judging style.

## COMMANDS

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## NOTES

- If adding larger features, migrate toward `lib/data/`, `lib/domain/`, `lib/ui/features/` gradually; do not reshuffle the whole app for a small spec.
- `video_player` is installed and used only by APOD mp4 playback.
- `http` is installed and used only by APOD.
- No existing `AGENTS.md` or `CLAUDE.md` was present before this file.
