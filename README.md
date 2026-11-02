# Qippet Pets

Qippet Pets is an Android-only Flutter companion app for choosing a virtual pet and hosting it in a native Android home-screen widget.

## Project status

This repository contains the Flutter application foundation and automated quality-check and APK-release workflows. The interactive pet experience and native widget are planned follow-on milestones; see [docs/PROGRESS.md](docs/PROGRESS.md) and [docs/DECISIONS.md](docs/DECISIONS.md).

## Requirements

- Flutter stable
- Java 17
- Android SDK API 24 or newer
- Application ID: `com.squiraldot.qippet_pets`
- Minimum Android SDK: 24

## Development

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Only Android is targeted. Two independent GitHub Actions workflows are used:

- **Analyze and test** runs `flutter analyze` and `flutter test` on pushes to `main` and pull requests.
- **Build and publish Android APK** builds on pushes to `main` (or manual dispatch), uploads the APK as a workflow artifact, and updates the rolling prerelease tagged `latest`.

The APK workflow uses the checked-in Android Gradle configuration (AGP 8.11.1 + Gradle 8.13). It generates only the missing Gradle wrapper JAR at runtime; it does not replace project Gradle files with whatever versions happen to ship in the latest Flutter template.

## Release signing

To sign releases with your own key, configure all four GitHub Actions repository secrets: `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, and `KEY_PASSWORD`. If any secret is missing, CI uses the default debug signing configuration so an installable APK is still produced.

Never commit keystores, signing credentials, or other secrets.
