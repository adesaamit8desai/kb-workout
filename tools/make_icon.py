#!/usr/bin/env python3
"""Draws the 1024×1024 app icon: a volt-green kettlebell on black."""
import pathlib
from PIL import Image, ImageDraw

S = 1024
VOLT, BLACK = (196, 242, 58), (0, 0, 0)
out = pathlib.Path(__file__).resolve().parent.parent / "KBWorkout/Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png"

img = Image.new("RGB", (S * 2, S * 2), BLACK)  # draw at 2x, then downsample for smooth edges
d = ImageDraw.Draw(img)
k = 2
# Handle: thick ring, body covers its lower half.
d.ellipse([330 * k, 170 * k, 694 * k, 560 * k], outline=VOLT, width=86 * k)
# Body (drawn under the handle window, then again over it)
d.ellipse([232 * k, 360 * k, 792 * k, 900 * k], fill=VOLT)
# Flat base
d.rectangle([372 * k, 846 * k, 652 * k, 880 * k], fill=VOLT)
# Window between handle and body
d.ellipse([416 * k, 256 * k, 608 * k, 470 * k], fill=BLACK)
d.ellipse([232 * k, 360 * k, 792 * k, 900 * k], fill=VOLT)
img.resize((S, S), Image.LANCZOS).save(out)
print(out)
