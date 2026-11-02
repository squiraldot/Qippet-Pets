# Qippet Pets

Qippet Pets is an Android-only Flutter companion app for choosing a virtual pet and hosting it in a native Android home-screen widget.

## Project status

This repository contains the Flutter application foundation and automated CI/release pipeline. The interactive pet experience and native widget are planned follow-on milestones; see [docs/PROGRESS.md](docs/PROGRESS.md) and [docs/DECISIONS.md](docs/DECISIONS.md).

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

Only Android is targeted. GitHub Actions runs analysis and tests on pushes to `main` and pull requests. Every push to `main` also builds a release APK, uploads it as a workflow artifact, and updates the prerelease named **latest**.

## Release signing

To sign releases with your own key, configure all four GitHub Actions repository secrets: `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, and `KEY_PASSWORD`. If any secret is missing, CI leaves the Flutter-generated debug signature in place so an installable APK is still produced.

Never commit keystores, signing credentials, or other secrets.
