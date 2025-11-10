# Flame Game

A new Flutter project using Flame.

## Getting Started

Follow these steps to set up and run the project:

1. Install the required dependencies:

   ```bash
   flutter pub get
   ```

2. Generate l10n:

   ```bash
   flutter gen-l10n
   ```

3. Generate pubspec

   ```bash
   fluttergen -c pubspec.yaml
   ```

4. Watch for changes and automatically rebuild:

   ```bash
   flutter pub run build_runner watch
   ```

## Project Structure

- `lib/`: Contains the main application code.
- `protos/`: Contains the protocol buffer definitions.

## Local Sandbox Architecture

The app now provisions an `AppSandbox` directory using `SandboxService` on startup. It mirrors the design in `flutter前端设计.md`:

- `db/app_data.db`: primary SQLite database for all business data.
- `files/`: user-generated content, split into `images/`, `audio/`, and `doc/` (with `pdf/`, `word/`, `excel/`, and `manual/`).
- `config/settings.json`: local preferences (language, theme, etc.).
- `secure/key_store/`: reserved for secrets and encryption material.

All helper methods (text exports, file moves) resolve to sandbox-relative paths, so nothing escapes the app's container.

## Health Asset Storage

Manual data imports and file uploads are persisted to the `health_asset` table in `app_data.db`:

| Column | Description |
| --- | --- |
| `id` | Auto-increment primary key |
| `filename` | Original or user-provided name |
| `path` | Relative sandbox path |
| `mime` | MIME type (image/png, text/plain, etc.) |
| `size_bytes` | File size for quick validation |
| `hash_sha256` | File hash for dedupe/integrity |
| `data_source` | camera/upload/manual/device/voice |
| `data_type` | bloodPressure, checkup, other... |
| `note` | User memo/description |
| `tags` | Comma-separated tags for querying |
| `metadata_json` | Extra JSON payload (recordedAt, method, paths) |
| `created_at` / `updated_at` | ISO timestamps |

`HealthAssetRepository` handles writing note files into `files/doc/manual`, copying uploads into the proper sub-folder, hashing, and syncing Riverpod state (`healthAssetsProvider`). The Health Data page now reads from this table instead of mock data, supports filtering/searching, and exposes a richer manual-import dialog.

## Running the App

To run the app on an emulator or a physical device, use the following command:

```bash
flutter run
```

## License

This project is licensed under the MIT License
