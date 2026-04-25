"""Generate Color Switch sprites — doce_candy palette.

Sprites:
  - ball.png (40x40, near-white base for runtime tinting + soft shadow)
  - ring_segmented_4colors.png (240x240, 4 colored arcs on transparent BG)
  - color_switch.png (30x30, small cross with 4 candy colors)
  - mascot.png (200x200, candy ball mascot for splash/home hero)
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

OUT = Path(__file__).resolve().parent.parent / "assets" / "sprites"
OUT.mkdir(parents=True, exist_ok=True)

# doce_candy palette (matches lib/ds/app_colors.dart + extra mint)
PINK = (255, 112, 166, 255)
YELLOW = (255, 214, 112, 255)
BLUE = (112, 214, 255, 255)
MINT = (180, 240, 200, 255)
DEEP_PINK = (197, 60, 120, 255)


def _radial_gradient(size, inner, outer):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    cx = cy = size / 2
    max_r = size / 2
    px = img.load()
    for y in range(size):
        for x in range(size):
            dx = x - cx
            dy = y - cy
            d = (dx * dx + dy * dy) ** 0.5 / max_r
            if d > 1.0:
                continue
            t = d
            r = int(inner[0] * (1 - t) + outer[0] * t)
            g = int(inner[1] * (1 - t) + outer[1] * t)
            b = int(inner[2] * (1 - t) + outer[2] * t)
            a = int(inner[3] * (1 - t) + outer[3] * t)
            px[x, y] = (r, g, b, a)
    return img


def make_ball():
    s = 80
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    shadow_layer = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow_layer)
    sd.ellipse([10, s - 18, s - 10, s - 4], fill=(20, 0, 30, 110))
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(3))
    img = Image.alpha_composite(img, shadow_layer)
    grad = _radial_gradient(s - 8, (255, 255, 255, 255), (255, 220, 235, 255))
    img.paste(grad, (4, 2), grad)
    d = ImageDraw.Draw(img)
    d.ellipse([18, 12, 36, 28], fill=(255, 255, 255, 180))
    img = img.resize((40, 40), Image.LANCZOS)
    img.save(OUT / "ball.png")
    print(f"Wrote {OUT/'ball.png'}")


def make_ring():
    s = 480
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    shadow = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.ellipse([10, 10, s - 10, s - 10], fill=(40, 10, 60, 70))
    shadow = shadow.filter(ImageFilter.GaussianBlur(10))
    img = Image.alpha_composite(img, shadow)

    d = ImageDraw.Draw(img)
    pad = 16
    bbox = [pad, pad, s - pad, s - pad]
    colors = [PINK, YELLOW, BLUE, MINT]
    width = 56
    for i, c in enumerate(colors):
        start = -90 + i * 90
        end = start + 90
        d.arc(bbox, start=start, end=end, fill=c, width=width)
    inner_pad = pad + width + 4
    d.ellipse(
        [inner_pad, inner_pad, s - inner_pad, s - inner_pad],
        outline=(255, 255, 255, 120),
        width=4,
    )
    d.ellipse(bbox, outline=(255, 255, 255, 80), width=3)
    img = img.resize((240, 240), Image.LANCZOS)
    img.save(OUT / "ring_segmented_4colors.png")
    print(f"Wrote {OUT/'ring_segmented_4colors.png'}")


def make_color_switch():
    s = 120
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    shadow = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.ellipse([s // 2 - 30, s - 28, s // 2 + 30, s - 6],
               fill=(20, 0, 30, 90))
    shadow = shadow.filter(ImageFilter.GaussianBlur(5))
    img = Image.alpha_composite(img, shadow)

    d = ImageDraw.Draw(img)
    cx = cy = s // 2
    arm_l = 40
    arm_w = 22
    d.rounded_rectangle(
        [cx - arm_w // 2, cy - arm_l, cx + arm_w // 2, cy], radius=8, fill=PINK,
    )
    d.rounded_rectangle(
        [cx, cy - arm_w // 2, cx + arm_l, cy + arm_w // 2], radius=8, fill=YELLOW,
    )
    d.rounded_rectangle(
        [cx - arm_w // 2, cy, cx + arm_w // 2, cy + arm_l], radius=8, fill=BLUE,
    )
    d.rounded_rectangle(
        [cx - arm_l, cy - arm_w // 2, cx, cy + arm_w // 2], radius=8, fill=MINT,
    )
    d.ellipse([cx - 14, cy - 14, cx + 14, cy + 14], fill=(255, 255, 255, 240))
    d.ellipse([cx - 8, cy - 8, cx + 8, cy + 8], fill=DEEP_PINK)
    img = img.resize((30, 30), Image.LANCZOS)
    img.save(OUT / "color_switch.png")
    print(f"Wrote {OUT/'color_switch.png'}")


def make_mascot():
    s = 400
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    shadow = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.ellipse([60, s - 80, s - 60, s - 30], fill=(20, 0, 30, 110))
    shadow = shadow.filter(ImageFilter.GaussianBlur(12))
    img = Image.alpha_composite(img, shadow)

    body = _radial_gradient(s - 40, (255, 200, 220, 255), PINK)
    img.paste(body, (20, 10), body)

    d = ImageDraw.Draw(img)
    d.ellipse([110, 70, 220, 160], fill=(255, 255, 255, 160))
    d.ellipse([130, 180, 175, 235], fill=(255, 255, 255, 255))
    d.ellipse([225, 180, 270, 235], fill=(255, 255, 255, 255))
    d.ellipse([146, 195, 168, 225], fill=(40, 10, 50, 255))
    d.ellipse([241, 195, 263, 225], fill=(40, 10, 50, 255))
    d.ellipse([152, 200, 161, 211], fill=(255, 255, 255, 255))
    d.ellipse([247, 200, 256, 211], fill=(255, 255, 255, 255))
    d.arc([160, 240, 240, 300], start=10, end=170, fill=(40, 10, 50, 255), width=8)
    d.ellipse([100, 240, 140, 270], fill=(255, 150, 180, 180))
    d.ellipse([260, 240, 300, 270], fill=(255, 150, 180, 180))
    for cx, cy, c in [(50, 200, BLUE), (350, 200, YELLOW),
                      (200, 50, MINT), (200, 350, PINK)]:
        dot_layer = Image.new("RGBA", (s, s), (0, 0, 0, 0))
        dd = ImageDraw.Draw(dot_layer)
        dd.ellipse([cx - 18, cy - 18, cx + 18, cy + 18], fill=c)
        dot_layer = dot_layer.filter(ImageFilter.GaussianBlur(2))
        img = Image.alpha_composite(img, dot_layer)
    img = img.resize((200, 200), Image.LANCZOS)
    img.save(OUT / "mascot.png")
    print(f"Wrote {OUT/'mascot.png'}")


def _solid_ring(name, color, glow):
    """240x240 thick ring of a single color with shadow + inner bevel."""
    s = 480
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    # outer drop shadow
    shadow = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.ellipse([14, 18, s - 14, s - 10], fill=(20, 0, 30, 110))
    shadow = shadow.filter(ImageFilter.GaussianBlur(11))
    img = Image.alpha_composite(img, shadow)

    # outer halo (color glow)
    halo = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    hd = ImageDraw.Draw(halo)
    hd.ellipse([6, 6, s - 6, s - 6],
               outline=glow + (200,), width=44)
    halo = halo.filter(ImageFilter.GaussianBlur(14))
    img = Image.alpha_composite(img, halo)

    # main color ring
    d = ImageDraw.Draw(img)
    pad = 22
    bbox = [pad, pad, s - pad, s - pad]
    d.ellipse(bbox, outline=color + (255,), width=58)
    # bright inner bevel
    inner_pad = pad + 50
    d.ellipse(
        [inner_pad, inner_pad, s - inner_pad, s - inner_pad],
        outline=(255, 255, 255, 200),
        width=4,
    )
    # outer ring border
    d.ellipse(bbox, outline=(255, 255, 255, 90), width=3)
    img = img.resize((240, 240), Image.LANCZOS)
    img.save(OUT / name)
    print(f"Wrote {OUT/name}")


def make_per_color_rings():
    rings = {
        "ring_red.png":    ((255, 112, 166), (255, 200, 220)),    # pink
        "ring_blue.png":   ((112, 214, 255), (200, 235, 255)),    # blue
        "ring_yellow.png": ((255, 214, 112), (255, 235, 180)),    # yellow
        "ring_green.png":  ((136, 224, 161), (200, 240, 215)),    # mint
    }
    for name, (color, glow) in rings.items():
        _solid_ring(name, color, glow)


if __name__ == "__main__":
    make_ball()
    make_ring()
    make_color_switch()
    make_mascot()
    make_per_color_rings()
    print("done.")
