# TODO List

- [x] Review `flutter前端设计.md` requirements and confirm sandbox + data storage scope.
- [x] Design sandbox directory management (db/files/config/secure) within Flutter app lifecycle.
- [x] Introduce local persistence stack (e.g., `sqflite`) and create `health_asset` schema/migrations.
- [x] Create Dart models/services for `health_asset`, including file metadata + tagging helpers.
- [x] Implement repository APIs for CRUD, file import, and sandbox path resolution.
- [x] Integrate UI flows (upload, tagging, preview) with new local data layer.
- [ ] Write tests / diagnostics for storage + DB interactions and document usage.
