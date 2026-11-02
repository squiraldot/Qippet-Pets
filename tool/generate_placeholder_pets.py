#!/usr/bin/env python3
"""Generate deterministic 256x256 transparent placeholder pet animation frames."""
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "pets"
SIZE = 256
FRAMES = 5
PETS = {
    "cat": {"body": "#F4A261", "dark": "#A85D2A", "ear": "#E9898B", "accent": "#FFE0B2"},
    "dog": {"body": "#C99565", "dark": "#795238", "ear": "#8A5B42", "accent": "#F7D7A8"},
    "bunny": {"body": "#E9E6F2", "dark": "#A9A2BD", "ear": "#F2A7B7", "accent": "#FFFFFF"},
}
STATES = ("idle", "tap_happy", "tap_spin", "sleep_start", "sleeping", "wake_up")


def draw_pet(pet_id: str, state: str, frame: int) -> Image.Image:
    colors = PETS[pet_id]
    image = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(image)
    phase = frame / FRAMES * math.tau
    bob = round(math.sin(phase) * (5 if state in ("idle", "tap_happy", "wake_up") else 2))
    tilt = math.sin(phase) * (0.10 if state == "tap_spin" else 0.025)
    cx, cy = 128, 142 + bob
    if state == "sleeping":
        cx, cy = 128, 164
    if state == "sleep_start":
        cy += frame * 2
    if state == "wake_up":
        cy -= (FRAMES - frame) * 2

    # Bunny ears; dog floppy ears; cat pointed ears.
    if pet_id == "bunny":
        for x, angle in ((94, -1), (162, 1)):
            d.rounded_rectangle((x - 15, 28 + bob, x + 15, 111 + bob), radius=15, fill=colors["body"], outline=colors["dark"], width=4)
            d.rounded_rectangle((x - 7, 39 + bob, x + 7, 99 + bob), radius=8, fill=colors["ear"])
    elif pet_id == "cat":
        d.polygon([(83, 110 + bob), (89, 51 + bob), (128, 91 + bob)], fill=colors["body"], outline=colors["dark"])
        d.polygon([(173, 110 + bob), (167, 51 + bob), (128, 91 + bob)], fill=colors["body"], outline=colors["dark"])
        d.polygon([(91, 94 + bob), (94, 67 + bob), (115, 91 + bob)], fill=colors["ear"])
        d.polygon([(165, 94 + bob), (162, 67 + bob), (141, 91 + bob)], fill=colors["ear"])
    else:
        d.ellipse((57, 94 + bob, 112, 174 + bob), fill=colors["body"], outline=colors["dark"], width=4)
        d.ellipse((144, 94 + bob, 199, 174 + bob), fill=colors["body"], outline=colors["dark"], width=4)

    # Body and paws.
    d.ellipse((65, 177 + bob, 191, 235 + bob), fill=colors["body"], outline=colors["dark"], width=4)
    d.ellipse((85, 206 + bob, 119, 239 + bob), fill=colors["accent"], outline=colors["dark"], width=3)
    d.ellipse((137, 206 + bob, 171, 239 + bob), fill=colors["accent"], outline=colors["dark"], width=3)
    d.ellipse((76, 78 + bob, 180, 184 + bob), fill=colors["body"], outline=colors["dark"], width=4)

    sleeping = state in ("sleep_start", "sleeping") and (state == "sleeping" or frame >= 2)
    if sleeping:
        for x in (105, 151):
            d.arc((x - 10, 124 + bob, x + 10, 142 + bob), 15, 165, fill=colors["dark"], width=4)
        d.ellipse((122, 151 + bob, 134, 158 + bob), fill=colors["ear"])
    else:
        eye_y = 124 + bob
        eye_h = 6 if state == "tap_happy" else 10
        d.ellipse((101, eye_y - eye_h, 111, eye_y + eye_h), fill="#352D35")
        d.ellipse((145, eye_y - eye_h, 155, eye_y + eye_h), fill="#352D35")
        d.ellipse((104, eye_y - 4, 107, eye_y), fill="#FFFFFF")
        d.ellipse((148, eye_y - 4, 151, eye_y), fill="#FFFFFF")
        d.ellipse((121, 145 + bob, 135, 155 + bob), fill=colors["ear"])
        d.arc((110, 148 + bob, 146, 171 + bob), 10, 170, fill="#684B4B", width=3)

    # Blush and state-specific sparkle marks.
    d.ellipse((79, 145 + bob, 98, 154 + bob), fill="#F3A3A6")
    d.ellipse((158, 145 + bob, 177, 154 + bob), fill="#F3A3A6")
    if state == "tap_happy":
        for x, y in ((48, 94), (204, 100), (52, 176), (204, 176)):
            d.line((x - 5, y, x + 5, y), fill="#F2C14E", width=4)
            d.line((x, y - 5, x, y + 5), fill="#F2C14E", width=4)
    if state in ("sleep_start", "sleeping"):
        d.text((177, 55), "z", fill="#7B86A8", stroke_width=1)
        if frame % 2:
            d.text((197, 38), "z", fill="#7B86A8")
    if state == "tap_spin":
        d.arc((36, 68, 220, 232), int(frame * 60), int(frame * 60 + 210), fill="#9ACD72", width=5)
    if state == "wake_up":
        d.ellipse((190, 65, 201, 76), fill="#F2C14E")
    return image


def main() -> None:
    for pet_id in PETS:
        for state in STATES:
            folder = OUT / pet_id
            folder.mkdir(parents=True, exist_ok=True)
            for frame in range(1, FRAMES + 1):
                image = draw_pet(pet_id, state, frame - 1)
                image.save(folder / f"{state}_{frame:02d}.png", optimize=True)


if __name__ == "__main__":
    main()
