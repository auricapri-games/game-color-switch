"""Generate sprites required by ASSET_BRIEF.md.

The agent (you) must implement this — see ASSET_BRIEF.md for the list.
Use PIL with on-theme colors derived from lib/ds/app_colors.dart.

Output: assets/sprites/*.png
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

OUT = Path(__file__).resolve().parent.parent / "assets" / "sprites"
OUT.mkdir(parents=True, exist_ok=True)


def example():
    """Delete this and implement your sprites."""
    img = Image.new("RGBA", (200, 200), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([20, 20, 180, 180], fill=(255, 100, 100, 255))
    img.save(OUT / "example.png")
    print(f"Wrote {OUT/'example.png'}")


if __name__ == "__main__":
    example()
