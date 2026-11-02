# Project progress

## Foundation

- [x] Create Android-only Flutter project structure in the repository root.
- [x] Set package identity to `com.squiraldot.qippet_pets` and minSdk 24.
- [x] Add repository working agreements, README, and ignore rules.
- [x] Add GitHub Actions quality checks and Android APK build.
- [x] Add pet catalog models, local schedule logic, and HomeWidget-backed preference storage.
- [x] Build the animated pet picker, pet selection grid, sleep/wake settings, and native Add to Home screen flow.
- [x] Add model, repository, and picker/settings widget tests.
- [x] Add deterministic Pillow sprite generation and Android drawable synchronization tools.
- [x] Document the 256px sprite contract, frame naming, frame counts, and playback rates.
- [x] Verify `flutter analyze`, `flutter test`, and Android pet drawable synchronization in GitHub Actions.
- [ ] Verify Android release APK build after applying Java and Kotlin JVM 17 targets after all Android plugin modules have evaluated.

- [x] Implement native Android PetWidgetProvider with a resizable 2 × 2 XML home-screen widget.
- [x] Read selectedPetId, sleepTime, and wakeTime from home_widget SharedPreferences and render the matching idle/sleeping drawable resource.
- [x] Add pure Kotlin schedule resolver and overnight, same-day, and boundary unit tests.
- [x] Refresh the native widget immediately after Flutter pet and schedule changes.
- [x] Add Kotlin unit tests to the main-branch CI workflow.\n- [x] Add immutable widget tap PendingIntents and a non-exported asynchronous animation receiver.\n- [x] Play data-discovered tap animation frames at 120 ms intervals, ignore overlapping taps, and restore the schedule-derived idle frame.\n- [x] Preserve sleeping state on taps without waking or replacing the sleeping sprite.\n- [x] Add Kotlin tests for animation selection, automatic frame discovery, ordering, and duration limits.

## Current behavior and known scope

- Pet choices are cat (`cat`), dog (`dog`), and bunny (`bunny`).
- Five 256 × 256 transparent frames are generated for each pet and each of six animation states.
- Tapping the selected preview alternates happy and spin animations.
- The selected pet, sleep time, and wake time are persisted through `home_widget` shared preferences.
- The selected pet preview observes the configured local-device sleep window, including overnight schedules, and plays sleep-start/sleeping/wake-up states.
- The Add to Home screen action requests the native Android pet widget pin flow.
- Placeholder geometric artwork is not final production art.
