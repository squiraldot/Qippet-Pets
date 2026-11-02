# Architecture decisions

## 2026-11-03 — Android-only Flutter foundation

- **Decision:** Use Flutter for the app UI and native Android/Kotlin integration for the home-screen widget.
- **Package:** `com.squiraldot.qippet_pets`; Flutter project name: `qippet_pets`.
- **Platform scope:** Android only, minimum SDK 24. No iOS, web, desktop, or other platform scaffolding.
- **Initial milestone:** Establish a clean Flutter application, Android host project, tests, and automated APK delivery before implementing pet selection, animations, schedules, and widget interactions.
- **Release signing:** Use a configured release keystore only when all four signing secrets are present; otherwise use the default debug signing configuration so CI still emits an installable APK.
- **Release channel:** Maintain one rolling GitHub prerelease tagged `latest`, plus a per-run workflow artifact.

## 2026-11-03 — Separate CI and Android release workflows

- **Decision:** Keep analysis/tests and APK build/publishing in separate GitHub Actions workflow files. Both trigger independently on pushes to `main`; analysis/tests also run for pull requests, and APK publishing supports manual dispatch.
- **Failure diagnosis:** The failed APK run generated an Android host from the current Flutter template (AGP 9) but restored an older app Gradle script that uses the deprecated AGP DSL and Kotlin Android plugin. The mismatch failed Gradle Kotlin script compilation; analysis and tests had already passed.
- **Android toolchain:** Keep the checked-in AGP 8.11.1 + Gradle 8.13 configuration. Android's official compatibility table requires Gradle 8.13 for AGP 8.11, and Kotlin 2.2.20 supports AGP through 8.11.1. Do not silently replace this configuration with a moving Flutter template.
- **Wrapper bootstrap:** The build workflow creates a temporary Flutter Android template only to obtain the Gradle wrapper JAR missing from this repository; it copies that JAR only and preserves all checked-in Gradle configuration.
