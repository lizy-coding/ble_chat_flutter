# Codex Operations Log

This log captures local restructuring performed by the Codex agent to align the app with Flutter conventions.

- Reorganized `lib/` into `lib/src/` with `app/`, `core/`, and `features/` submodules so shared code is centralized inside the app package.
- Consolidated former path packages into internal modules:
  - Domain DTOs and generated serializers now under `lib/src/core/domain/`.
  - Storage, BLE controller, foreground, and notification helpers moved to `lib/src/core/`.
- Removed the legacy `packages/` workspace and updated imports to use `package:monorepo/src/...`.
- Updated `pubspec.yaml` to depend directly on `flutter_riverpod`, `go_router`, `json_annotation`, and `riverpod`, plus dev tooling (`build_runner`, `json_serializable`).
- Refreshed contributor guidance in `AGENTS.md` to reflect the new hierarchy.
- Updated `ref.listen` usage in `DevicesPage` and `ChatPage` to register during build, resolving the Riverpod assertion triggered by listening during `initState`.

Follow-up actions:
- Run `flutter pub get` (or `dart pub get` inside the Flutter shell) to refresh `pubspec.lock`.
- Regenerate JSON code after DTO edits with `dart run build_runner build`.
- Execute `flutter analyze` and `flutter test` to validate after dependency sync.
