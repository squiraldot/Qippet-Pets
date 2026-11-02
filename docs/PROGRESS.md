# Project progress

## Foundation

- [x] Create Android-only Flutter project structure in the repository root.
- [x] Set package identity to `com.squiraldot.qippet_pets` and minSdk 24.
- [x] Add repository working agreements, README, and ignore rules.
- [x] Add GitHub Actions quality checks and Android APK build.
- [x] Add pet catalog models, local schedule logic, and HomeWidget-backed preference storage.
- [x] Build the animated pet picker, pet selection grid, sleep/wake settings, and Add to Home screen placeholder.
- [x] Add model, repository, and picker/settings widget tests.
- [x] Add deterministic Pillow sprite generation and Android drawable synchronization tools.
- [x] Document the 256px sprite contract, frame naming, frame counts, and playback rates.
- [ ] Run CI and verify generated sprite PNGs are committed on `main`.
- [x] Verify `flutter analyze`, `flutter test`, and Android pet drawable synchronization in GitHub Actions.
- [ ] Verify Android release APK build after migrating Kotlin 2.2 compiler configuration to the typed `compilerOptions` DSL.

## Current behavior and known scope

- Pet choices are cat (`cat`), dog (`dog`), and bunny (`bunny`).
- Five 256 × 256 transparent frames are generated for each pet and each of six animation states.
- Tapping a pet preview alternates the happy and spin animations.
- The selected pet, sleep time, and wake time are persisted through `home_widget` shared preferences.
- The selected pet preview observes the configured local-device sleep window, including overnight schedules, and plays sleep-start/sleeping/wake-up states.
- The Add to Home screen action is intentionally a placeholder; the native Android widget provider and launcher integration are not implemented yet.
- Placeholder geometric artwork is not final production art.
