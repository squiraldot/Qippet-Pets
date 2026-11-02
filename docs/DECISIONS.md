# Architecture decisions

## 2026-11-03 — Android-only Flutter foundation

- **Decision:** Use Flutter for the app UI and native Android/Kotlin integration for the home-screen widget.
- **Package:** `com.squiraldot.qippet_pets`; Flutter project name: `qippet_pets`.
- **Platform scope:** Android only, minimum SDK 24.
- **Release signing:** Use a configured release keystore only when all signing secrets are present; otherwise use debug signing for CI builds.
- **Release channel:** Maintain a rolling GitHub prerelease tagged `latest`, plus a per-run workflow artifact.

## 2026-11-03 — Pet catalog, animation, and persistence

- **Catalog:** Start with `cat`, `dog`, and `bunny`; stable IDs are persisted rather than display names.
- **Sprite source of truth:** Keep the six state sequences under `assets/pets/<petId>/`; Android `drawable-nodpi` files are generated copies. Flutter reads source assets directly.
- **Placeholder art:** Use deterministic Pillow geometry so the UI can be developed before commissioned artwork exists. Final artwork must preserve the exact 256 × 256 transparent PNG contract and filenames.
- **Frame contract:** Five frames per state; idle 6 FPS, tap-happy 10 FPS, tap-spin 12 FPS, sleep-start 8 FPS, sleeping 3 FPS, and wake-up 8 FPS.
- **Persistence:** Use `home_widget` data APIs for `selectedPetId`, `sleepTime`, and `wakeTime`, backed by Android SharedPreferences. Keep app state in a small `ChangeNotifier` controller rather than adding a state-management framework.
- **Schedule semantics:** Interpret schedule values in the device's local time zone. A sleep interval crossing midnight is supported; identical sleep and wake times mean the pet stays awake.
- **Widget scope:** The app button remains a clear placeholder until a native Android widget provider and launcher flow are implemented.
- **CI asset generation:** Pillow-generated source sprites and synchronized Android copies are committed by the main-branch CI job when generated files change. Pull-request runs generate and verify them without writing to the branch.
