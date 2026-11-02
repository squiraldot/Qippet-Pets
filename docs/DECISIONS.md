# Architecture decisions

## 2026-11-03 — Android-only Flutter foundation

- **Decision:** Use Flutter for the app UI and native Android/Kotlin integration for the home-screen widget.
- **Package:** `com.squiraldot.qippet_pets`; Flutter project name: `qippet_pets`.
- **Platform scope:** Android only, minimum SDK 24. No iOS, web, desktop, or other platform scaffolding.
- **Initial milestone:** Establish a clean Flutter application, Android host project, tests, and automated APK delivery before implementing pet selection, animations, schedules, and widget interactions.
- **Release signing:** Use a configured release keystore only when all four signing secrets are present; otherwise use the default debug signing configuration so CI still emits an installable APK.
- **Release channel:** Maintain one rolling GitHub prerelease tagged `latest`, plus a per-run workflow artifact.
