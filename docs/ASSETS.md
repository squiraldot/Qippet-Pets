# Pet sprite asset specification

## Source of truth

All animation artwork lives under `assets/pets/<petId>/`. Android resources are generated copies in `android/app/src/main/res/drawable-nodpi/`; never edit those copies by hand.

- Pet IDs: `cat`, `dog`, `bunny`.
- State IDs: `idle`, `tap_happy`, `tap_spin`, `sleep_start`, `sleeping`, `wake_up`.
- Filename: `<state>_<nn>.png`, where `nn` is a 1-based, zero-padded frame number (for example, `tap_happy_01.png`).
- Canvas: exactly 256 × 256 pixels.
- Color: RGBA PNG with transparent background.
- Frame count: 5 frames for every pet/state pair (90 source PNGs total).

## Playback rates

| State | Frames | FPS | Playback |
|---|---:|---:|---|
| idle | 5 | 6 | Loop |
| tap_happy | 5 | 10 | Once, then idle |
| tap_spin | 5 | 12 | Once, then idle |
| sleep_start | 5 | 8 | Once, then sleeping |
| sleeping | 5 | 3 | Loop |
| wake_up | 5 | 8 | Once, then idle |

## Replacing placeholder art

Run `python tool/generate_placeholder_pets.py` to regenerate the geometric placeholders. Replace source PNGs in place when final art is ready; keep canvas, alpha channel, names, and frame counts unchanged. Run `python tool/sync_pet_assets.py` after replacing art to update Android copies. CI runs `python tool/sync_pet_assets.py --check` and fails if any source or destination frame is missing or differs.

## Android naming

The sync tool maps each source frame to `pet_<petId>_<state>_<nn>.png` in `drawable-nodpi`. Names are lowercase and contain only Android-safe letters, digits, and underscores. The Android copy is for native widget integration; Flutter loads the source files directly from `assets/pets/`.
