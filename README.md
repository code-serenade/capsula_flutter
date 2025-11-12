# Capsula Flutter Client

[中文文档](README_zh.md)

Flutter + Riverpod implementation of the Capsula health dashboard. It manages health assets (manual notes, uploads, device sync data) inside an isolated sandbox, exposes them through AutoRoute tabs, and relies on Drift for local persistence.

## Prerequisites

- Flutter 3.19+ (Dart 3.9 SDK)
- macOS or Linux workstation (iOS builds require Xcode)
- `fluttergen` and `build_runner` accessible via `dart run`

## Quick Start

```bash
git clone <repo>
cd capsula_flutter
cp assets/example.env assets/.env   # configure API endpoints
flutter pub get
flutter gen-l10n
fluttergen -c pubspec.yaml
dart run build_runner build --delete-conflicting-outputs
```

### Common Commands

| Purpose                                              | Command                                                    |
| ---------------------------------------------------- | ---------------------------------------------------------- |
| Install dependencies                                 | `flutter pub get`                                          |
| Generate localization files                          | `flutter gen-l10n`                                         |
| Regenerate asset bindings (`flutter_gen`)            | `fluttergen -c pubspec.yaml`                               |
| Run code generation (Riverpod/AutoRoute/json models) | `dart run build_runner build --delete-conflicting-outputs` |
| Watch for changes during development                 | `dart run build_runner watch --delete-conflicting-outputs` |

## Running

- **iOS / macOS / Android**: `flutter run -d <deviceId>`
- **Web**: Not supported (Drift storage is disabled in web builds and will throw).

## Testing & Checks

```bash
flutter analyze
flutter test
```

Unit/widget tests currently cover theming plus health-data providers and filters. Add new specs next to the feature they validate.

## Project Structure

- `lib/main.dart`: App bootstrap (env loading, sandbox + DB init, Router setup).
- `lib/providers/`: Riverpod Notifiers + generated code.
- `lib/services/`: HTTP clients, sandbox helpers, Drift setup, health-data controllers.
- `lib/pages/`: AutoRoute pages (auth, tabs, layouts).
- `lib/widgets/health_data/`: Reusable widgets (collection grid, filters, cards, dialogs).
- `lib/theme/`: Theme data, sub-theme definitions, health-data color helpers.
- `assets/`: Localization ARB files, env template, static assets.

## Local Sandbox Architecture

`SandboxService` provisions an `AppSandbox` directory per platform:

- `db/app_data.db`: Drift/SQLite store for business data.
- `files/`: user-generated content
  - `images/`, `audio/`, `doc/{pdf,word,excel,manual}`
- `config/settings.json`: cached preferences (language, theme, etc.).
- `secure/key_store/`: reserved for secrets and encryption keys.

All repository helpers resolve sandbox-relative paths, ensuring nothing leaves the container.

## Health Asset Storage

Health assets are persisted in the `health_asset` table:

| Column                      | Description                                   |
| --------------------------- | --------------------------------------------- |
| `id`                        | Auto-increment primary key                    |
| `filename`                  | Original or user-provided name                |
| `path`                      | Relative sandbox path                         |
| `mime`                      | MIME type (image/png, text/plain, etc.)       |
| `size_bytes`                | File size for quick validation                |
| `hash_sha256`               | Hash for dedupe/integrity                     |
| `data_source`               | camera / upload / manual / device / voice     |
| `data_type`                 | bloodPressure, checkup, etc.                  |
| `note`                      | User memo/description                         |
| `tags`                      | Comma-separated tags                          |
| `metadata_json`             | Additional payload (recordedAt, method, etc.) |
| `created_at` / `updated_at` | ISO timestamps                                |

`HealthAssetRepository` writes manual notes into `files/doc/manual`, moves uploads into the correct subtree, hashes content, and notifies `healthAssetsProvider`. UI clients (Health Data tab) bind to this state for filtering, search, detail dialogs, and OS-level previews.

## Troubleshooting

- **Files fail to open on desktop**: ensure `SandboxService` initialized by launching via `flutter run` and verify sandbox paths in dev tools.
- **Missing localization or assets**: rerun `flutter gen-l10n` and `fluttergen -c pubspec.yaml`.

## License

MIT License.
