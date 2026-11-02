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
- **Workflow diagnosis:** The first APK workflow failure was caused by replacing the checked-in Android host with a newer Flutter-generated AGP 9 host while retaining an older app Gradle script. The workflow was changed to generate only the missing wrapper JAR, preserving checked-in Android configuration.
- **Wrapper compatibility diagnosis:** The subsequent APK run reached `assembleRelease` but failed because Flutter 3.47.9 requires Gradle 8.14.0 or newer while the checked-in wrapper still used Gradle 8.13. The failure was isolated to the Gradle wrapper version; the analysis/test workflow passed.
- **Android toolchain:** Use AGP 8.11.1, Kotlin Gradle Plugin 2.2.20, and Gradle 8.14.3. Android's compatibility table lists Gradle 8.13 as the minimum for AGP 8.11; Kotlin 2.2.20 supports Gradle through 8.14 and AGP through 8.11.1. Gradle 8.14.3 satisfies Flutter's 8.14 minimum while remaining within the Kotlin/AGP compatibility range.
- **Wrapper bootstrap:** The build workflow creates a temporary Flutter Android template only to obtain the Gradle wrapper JAR missing from this repository; it copies that JAR only and preserves all checked-in Gradle configuration.
