# Qippet Pets

Qippet Pets is an Android-only Flutter virtual pet companion.

## Current app

- Choose a cat, dog, or bunny from an animated picker.
- Tap the selected preview to play happy and spin animations.
- Set a local-device sleep and wake schedule.
- Persist the selected pet and schedule with the `home_widget` SharedPreferences integration.
- Placeholder geometric sprite artwork is generated until final art is ready.

The **Add to Home screen** button is currently a placeholder. A native Android widget provider and launcher integration are not implemented yet.

## Sprite assets

See [docs/ASSETS.md](docs/ASSETS.md) for the exact source asset contract.

```bash
python -m pip install Pillow
python tool/generate_placeholder_pets.py
python tool/sync_pet_assets.py
python tool/sync_pet_assets.py --check
```

The canonical art lives in `assets/pets/<petId>/<state>_<nn>.png`. Android drawable resources are generated copies; do not edit them manually.

## Development

Requirements: Flutter stable, Java 17, Android SDK API 24 or newer, Python 3.12+ and Pillow for sprite generation.

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

GitHub Actions generates and syncs the placeholder frames, verifies that Android resources match the source sprites, runs analysis and tests, and builds a release APK on pushes to `main`.
