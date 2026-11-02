#!/usr/bin/env python3
"""Synchronize source pet PNGs into Android drawable-nodpi resources."""
from __future__ import annotations

import argparse
import re
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets" / "pets"
DESTINATION = ROOT / "android" / "app" / "src" / "main" / "res" / "drawable-nodpi"
EXPECTED_PETS = ("cat", "dog", "bunny")
EXPECTED_STATES = ("idle", "tap_happy", "tap_spin", "sleep_start", "sleeping", "wake_up")
FRAME_COUNT = 5
NAME = re.compile(r"^[a-z][a-z0-9_]*$")


def expected_files() -> dict[Path, Path]:
    mapping: dict[Path, Path] = {}
    for pet_id in EXPECTED_PETS:
        for state in EXPECTED_STATES:
            for frame in range(1, FRAME_COUNT + 1):
                source = SOURCE / pet_id / f"{state}_{frame:02d}.png"
                target = DESTINATION / f"pet_{pet_id}_{state}_{frame:02d}.png"
                if not NAME.fullmatch(target.stem):
                    raise ValueError(f"Invalid Android resource name: {target.name}")
                mapping[source] = target
    return mapping


def sync(check: bool) -> int:
    mapping = expected_files()
    missing = [str(path.relative_to(ROOT)) for path in mapping if not path.is_file()]
    if missing:
        print("Missing source sprites:")
        print("\n".join(missing))
        return 1

    expected_targets = {target for target in mapping.values()}
    existing_targets = set(DESTINATION.glob("pet_*.png")) if DESTINATION.exists() else set()
    stale = sorted(existing_targets - expected_targets)
    mismatched = [str(target.relative_to(ROOT)) for source, target in mapping.items()
                  if not target.is_file() or source.read_bytes() != target.read_bytes()]

    if check:
        if stale or mismatched:
            print("Android pet resources are out of sync.")
            for path in stale:
                print(f"Stale: {path.relative_to(ROOT)}")
            for path in mismatched:
                print(f"Missing or different: {path}")
            return 1
        print(f"Android pet resources are synchronized ({len(mapping)} PNGs).")
        return 0

    DESTINATION.mkdir(parents=True, exist_ok=True)
    for source, target in mapping.items():
        shutil.copy2(source, target)
    for path in stale:
        path.unlink()
    print(f"Copied {len(mapping)} pet frames to {DESTINATION.relative_to(ROOT)}.")
    return 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="fail instead of copying if resources drift")
    args = parser.parse_args()
    sys.exit(sync(args.check))
