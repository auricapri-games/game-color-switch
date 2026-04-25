"""Generate sprites for game-color-switch (palette: doce_candy).

Outputs:
  assets/sprites/ball.png         40x40   pearl-white candy ball with shine
  assets/sprites/ring_red.png     200x200 quad ring (red sector active)
  assets/sprites/ring_blue.png    200x200 quad ring (blue sector active)
  assets/sprites/ring_green.png   200x200 quad ring (green sector active)
  assets/sprites/ring_yellow.png  200x200 quad ring (yellow sector active)

Each ring sprite has 4 colored quadrants — when paired with a ball of the
matching `_active` color, the player sees that the ring is "passable" right
now. A second helper sprite (`ring_full.png`) renders all four quadrants at
full saturation (used as the canonical neutral ring).
"""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

OUT = Path(__file__).resolve().parent.parent / "assets" / "sprites"
OUT.mkdir(parents=True, exist_ok=True)

# doce_candy palette (mirrors lib/ds/app_colors.dart)
PRIMARY = (0xFF, 0x70, 0xA6)       # pink
SECONDARY = (0xFF, 0xD6, 0x70)     # warm yellow
BACKGROUND = (0xFF, 0xE4, 0xF1)
BG_ALT = (0xFF, 0xC8, 0xDD)
TEXT = (0x5F, 0x0F, 0x40)
ACCENT = (0x70, 0xD6, 0xFF)        # sky blue
GREEN = (0x88, 0xE0, 0xA1)         # candy mint (within doce_candy spirit)

QUADRANT_COLORS = {
    "red": PRIMARY,
    "yellow": SECONDARY,
    "blue": ACCENT,
    "green": GREEN,
}


def _radial_ball(size: int, base: tuple[int, int, int]) -> Image.Image:
    """Pearl-finish candy ball with soft shadow + highlight."""
    pad = 4
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.ellipse([pad + 2, pad + 4, size - pad, size - pad + 2], fill=(0, 0, 0, 90))
    shadow = shadow.filter(ImageFilter.GaussianBlur(3))
    canvas.alpha_composite(shadow)

    body = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    bd = ImageDraw.Draw(body)
    # base disc
    bd.ellipse([pad, pad, size - pad, size - pad], fill=base + (255,))
    # gradient by stacking translucent inner circles
    for i in range(8):
        t = i / 8
        r = pad + int((size - 2 * pad) * 0.5 * (1 - t * 0.6))
        cx = size // 2
        cy = size // 2 - int(size * 0.05)
        col = (
            min(255, base[0] + 40 + i * 6),
            min(255, base[1] + 40 + i * 6),
            min(255, base[2] + 40 + i * 6),
            int(20 + 14 * t),
        )
        bd.ellipse([cx - r, cy - r, cx + r, cy + r], fill=col)
    # specular highlight
    hl = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    hd = ImageDraw.Draw(hl)
    hd.ellipse(
        [int(size * 0.28), int(size * 0.18), int(size * 0.55), int(size * 0.42)],
        fill=(255, 255, 255, 200),
    )
    hl = hl.filter(ImageFilter.GaussianBlur(2))
    body.alpha_composite(hl)

    canvas.alpha_composite(body)
    return canvas


def _ring(size: int, active: str | None) -> Image.Image:
    """Four-quadrant candy ring. `active` highlights one quadrant; if None
    every quadrant is rendered at full saturation (neutral ring)."""
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(canvas)
    cx, cy = size // 2, size // 2
    outer = size // 2 - 6
    inner = outer - 30  # ring thickness

    # arcs per quadrant — start angles (clockwise from top).
    quads = [
        (-90, 0, "red"),
        (0, 90, "yellow"),
        (90, 180, "blue"),
        (180, 270, "green"),
    ]
    for start, end, name in quads:
        col = QUADRANT_COLORS[name]
        is_active = (active is None) or (name == active)
        alpha = 255 if is_active else 90
        # outer arc band
        for w in range(30):
            r = outer - w
            shade = (
                max(0, col[0] - w * 2),
                max(0, col[1] - w * 2),
                max(0, col[2] - w * 2),
                alpha,
            )
            d.arc(
                [cx - r, cy - r, cx + r, cy + r],
                start=start,
                end=end,
                fill=shade,
                width=2,
            )

    # soft outer glow (only when one sector is active — emphasises focus)
    if active is not None:
        glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        gd = ImageDraw.Draw(glow)
        col = QUADRANT_COLORS[active]
        gd.ellipse(
            [cx - outer - 4, cy - outer - 4, cx + outer + 4, cy + outer + 4],
            outline=col + (180,),
            width=4,
        )
        glow = glow.filter(ImageFilter.GaussianBlur(6))
        canvas.alpha_composite(glow)

    # inner shadow rim — adds depth to the hole the ball passes through
    rim = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    rd = ImageDraw.Draw(rim)
    rd.ellipse(
        [cx - inner, cy - inner, cx + inner, cy + inner],
        outline=(50, 10, 40, 80),
        width=3,
    )
    rim = rim.filter(ImageFilter.GaussianBlur(2))
    canvas.alpha_composite(rim)

    return canvas


def main() -> None:
    ball = _radial_ball(40, (255, 250, 245))
    ball.save(OUT / "ball.png")
    print(f"wrote {OUT / 'ball.png'}")

    for name in ("red", "blue", "green", "yellow"):
        img = _ring(200, active=name)
        img.save(OUT / f"ring_{name}.png")
        print(f"wrote {OUT / f'ring_{name}.png'}")

    img = _ring(200, active=None)
    img.save(OUT / "ring_full.png")
    print(f"wrote {OUT / 'ring_full.png'}")

    # mascot for splash + home hero — bigger ball with star sparkle
    mascot = Image.new("RGBA", (240, 240), (0, 0, 0, 0))
    mascot.alpha_composite(_radial_ball(200, PRIMARY).resize((200, 200)), (20, 20))
    md = ImageDraw.Draw(mascot)
    # cute eyes
    md.ellipse([90, 95, 110, 125], fill=(40, 8, 36, 255))
    md.ellipse([130, 95, 150, 125], fill=(40, 8, 36, 255))
    md.ellipse([97, 100, 104, 110], fill=(255, 255, 255, 230))
    md.ellipse([137, 100, 144, 110], fill=(255, 255, 255, 230))
    # smile
    md.arc([95, 130, 145, 170], start=10, end=170, fill=(40, 8, 36, 255), width=4)
    # cheek blush
    blush = Image.new("RGBA", (240, 240), (0, 0, 0, 0))
    bd = ImageDraw.Draw(blush)
    bd.ellipse([72, 130, 92, 145], fill=(255, 120, 160, 140))
    bd.ellipse([148, 130, 168, 145], fill=(255, 120, 160, 140))
    blush = blush.filter(ImageFilter.GaussianBlur(2))
    mascot.alpha_composite(blush)
    mascot.save(OUT / "mascot.png")
    print(f"wrote {OUT / 'mascot.png'}")


if __name__ == "__main__":
    main()
