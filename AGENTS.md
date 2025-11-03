# Repository Guidelines

## Project Structure & Module Organization
The entry point remains `lib/main.dart`, while all application code now lives under `lib/src/`. UI scaffolding is grouped in `lib/src/app/` (`app.dart`, `router.dart`), feature screens in `lib/src/features/`, and shared services in `lib/src/core/`. Domain DTOs and their generated serializers sit in `lib/src/core/domain/`. Storage, BLE orchestration, foreground stubs, and notification helpers reside under `lib/src/core/*`. Keep generated files (`*.g.dart`) adjacent to their sources and leave platform shells in `android/` and `windows/`.

## Build, Test, and Development Commands
Run `flutter pub get` whenever dependencies change. Use `flutter run` for hot-reload development on a simulator or device. Lint with `flutter analyze` (uses `analysis_options.yaml`) and format via `flutter format .` before committing. Execute the full suite with `flutter test`; add `--coverage` when validating larger efforts. Regenerate JSON serializers after DTO updates using `dart run build_runner build`.

## Coding Style & Naming Conventions
Follow Flutter lints: two-space indentation, trailing commas in multiline widget trees, and descriptive `// TODO(username):` markers. Prefer `UpperCamelCase` for types, `lowerCamelCase` for members, and `snake_case.dart` filenames matching the primary symbol. Import local code with `package:monorepo/src/...` to avoid brittle relative paths. Keep providers and services in dedicated subdirectories (`core/ble`, `core/storage`) for discoverability.

## Testing Guidelines
Place widget and unit tests in `test/`, mirroring the source module names (`test/features/chat/chat_page_test.dart`, etc.). Name cases after expected behavior (`scan emits devices when controller runs`). Mock async flows with fakes or stub providers; avoid time-dependent sleeps. Ensure DTO contract tests cover both serialization and runtime behavior after changes to `core/domain`.

## Commit & Pull Request Guidelines
History favors concise, imperative subject lines (`Refactor BLE storage layout`). Keep subjects under 72 characters, elaborate in the body when rationale or follow-up steps matter, and reference issues (`#123`) when relevant. Pull requests should summarize the impact, list verification commands (`flutter test`, `flutter analyze`), and include screenshots or recordings whenever UI changes occur. Highlight cross-module implications, especially when touching `lib/src/core/` to alert feature owners.
