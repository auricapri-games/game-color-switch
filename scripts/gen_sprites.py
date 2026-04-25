"""Generate sprites for Color Switch.

Outputs to assets/sprites/:
  ball.png        40x40   white-pearl ball with soft shadow
  ring_red.png    200x200 pink (doce_candy primary)
  ring_blue.png   200x200 sky-blue (accent)
  ring_green.png  200x200 mint
  ring_yellow.png 200x200 candy-yellow (secondary)
  mascot.png      256x256 cute candy ball with face

Colours derived from lib/ds/app_colors.dart (palette: doce_candy).
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

OUT = Path(__file__).resolve().parent.parent / "assets" / "sprites"
OUT.mkdir(parents=True, exist_ok=True)

# doce_candy palette
PRIMARY = (255, 112, 166)        # pink
SECONDARY = (255, 214, 112)      # candy yellow
ACCENT = (112, 214, 255)         # sky blue
MINT = (124, 217, 146)           # custom green for ring_green
TEXT = (95, 15, 64)              # deep maroon (eyes / outlines)
WHITE = (255, 255, 255)


def _radial_disc(size: int, center_color, edge_color):
    """A radial gradient disc: brighter at center, darker at edge."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    cx = cy = size / 2
    max_r = size / 2
    px = img.load()
    for y in range(size):
        for x in range(size):
            dx = x - cx
            dy = y - cy
            r = (dx * dx + dy * dy) ** 0.5
            if r > max_r:
                continue
            t = r / max_r
            cr = int(center_color[0] * (1 - t) + edge_color[0] * t)
            cg = int(center_color[1] * (1 - t) + edge_color[1] * t)
            cb = int(center_color[2] * (1 - t) + edge_color[2] * t)
            # specular highlight in upper-left
            hx = (x - cx + size * 0.18) / max_r
            hy = (y - cy + size * 0.22) / max_r
            hr = (hx * hx + hy * hy) ** 0.5
            if hr < 0.45:
                hk = (1 - hr / 0.45) * 0.55
                cr = min(255, int(cr + (255 - cr) * hk))
                cg = min(255, int(cg + (255 - cg) * hk))
                cb = min(255, int(cb + (255 - cb) * hk))
            # soft alpha at the edge
            a = 255 if t < 0.92 else int(255 * (1 - (t - 0.92) / 0.08))
            px[x, y] = (cr, cg, cb, max(0, min(255, a)))
    return img


def _darker(rgb, factor=0.55):
    return tuple(int(c * factor) for c in rgb)


def _lighter(rgb, factor=0.4):
    return tuple(int(c + (255 - c) * factor) for c in rgb)


def make_ball(path: Path):
    size = 40
    # canvas with shadow space
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    # drop shadow
    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.ellipse([6, 9, size - 4, size - 2], fill=(95, 15, 64, 90))
    shadow = shadow.filter(ImageFilter.GaussianBlur(2.0))
    canvas.alpha_composite(shadow)
    # pearl body (whitish with subtle pink rim)
    body = _radial_disc(size, _lighter(WHITE, 0.0), _lighter(PRIMARY, 0.55))
    canvas.alpha_composite(body)
    # white highlight dot
    hl = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    hd = ImageDraw.Draw(hl)
    hd.ellipse([10, 8, 18, 14], fill=(255, 255, 255, 220))
    hl = hl.filter(ImageFilter.GaussianBlur(0.7))
    canvas.alpha_composite(hl)
    canvas.save(path)


def make_ring(path: Path, color):
    size = 200
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    # outer glow halo
    halo = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    hd = ImageDraw.Draw(halo)
    hd.ellipse([4, 4, size - 4, size - 4], fill=(*color, 80))
    halo = halo.filter(ImageFilter.GaussianBlur(8))
    canvas.alpha_composite(halo)

    # outer ring (gradient body)
    body = _radial_disc(size, _lighter(color, 0.35), _darker(color, 0.7))
    canvas.alpha_composite(body)

    # cut inner hole for ring (donut)
    inner = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    idr = ImageDraw.Draw(inner)
    inner_r = int(size * 0.34)
    cx = cy = size // 2
    idr.ellipse(
        [cx - inner_r, cy - inner_r, cx + inner_r, cy + inner_r],
        fill=(0, 0, 0, 0),
    )
    # mask: keep only outside inner_r
    mask = Image.new("L", (size, size), 255)
    md = ImageDraw.Draw(mask)
    md.ellipse(
        [cx - inner_r, cy - inner_r, cx + inner_r, cy + inner_r], fill=0
    )
    canvas.putalpha(
        Image.eval(canvas.split()[-1], lambda v: v).point(lambda v: v)
    )
    # Multiply current alpha by mask:
    src_a = canvas.split()[-1]
    new_a = Image.eval(src_a, lambda v: v)
    new_a = Image.eval(
        Image.merge("L", [src_a]).point(lambda v: v), lambda v: v
    )
    # combine using mask via composite
    composite_alpha = Image.new("L", (size, size), 0)
    composite_alpha.paste(src_a, (0, 0), mask)
    canvas.putalpha(composite_alpha)

    # subtle highlight arc on top of donut (small white ellipse, blurred)
    hl = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    hld = ImageDraw.Draw(hl)
    hld.ellipse(
        [size * 0.22, size * 0.10, size * 0.78, size * 0.34],
        fill=(255, 255, 255, 130),
    )
    hl = hl.filter(ImageFilter.GaussianBlur(4))
    # restrict highlight to ring band only
    band_mask = Image.new("L", (size, size), 0)
    bdm = ImageDraw.Draw(band_mask)
    bdm.ellipse([4, 4, size - 4, size - 4], fill=255)
    bdm.ellipse(
        [cx - inner_r, cy - inner_r, cx + inner_r, cy + inner_r], fill=0
    )
    hl_alpha = hl.split()[-1]
    new_hl_alpha = Image.new("L", (size, size), 0)
    new_hl_alpha.paste(hl_alpha, (0, 0), band_mask)
    hl.putalpha(new_hl_alpha)
    canvas.alpha_composite(hl)

    canvas.save(path)


def make_mascot(path: Path):
    size = 256
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    # halo
    halo = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    hd = ImageDraw.Draw(halo)
    hd.ellipse([8, 12, size - 8, size - 4], fill=(*PRIMARY, 80))
    halo = halo.filter(ImageFilter.GaussianBlur(14))
    canvas.alpha_composite(halo)

    # body (pink candy ball)
    body = _radial_disc(size, _lighter(PRIMARY, 0.55), _darker(PRIMARY, 0.6))
    canvas.alpha_composite(body)

    # cheeks
    cheeks = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    cd = ImageDraw.Draw(cheeks)
    cd.ellipse([62, 150, 102, 178], fill=(*SECONDARY, 200))
    cd.ellipse([154, 150, 194, 178], fill=(*SECONDARY, 200))
    cheeks = cheeks.filter(ImageFilter.GaussianBlur(3))
    canvas.alpha_composite(cheeks)

    # eyes (whites)
    d = ImageDraw.Draw(canvas)
    d.ellipse([78, 100, 122, 144], fill=(255, 255, 255, 255))
    d.ellipse([134, 100, 178, 144], fill=(255, 255, 255, 255))
    # pupils
    d.ellipse([93, 114, 113, 134], fill=TEXT + (255,))
    d.ellipse([149, 114, 169, 134], fill=TEXT + (255,))
    # eye sparkles
    d.ellipse([97, 116, 104, 123], fill=(255, 255, 255, 255))
    d.ellipse([153, 116, 160, 123], fill=(255, 255, 255, 255))

    # smile
    d.arc([108, 158, 148, 188], start=10, end=170, fill=TEXT + (255,), width=5)

    # antenna with little candy ball on top
    d.line([(128, 32), (128, 60)], fill=TEXT + (255,), width=4)
    d.ellipse([116, 12, 140, 36], fill=ACCENT + (255,))
    d.ellipse([121, 16, 132, 27], fill=(255, 255, 255, 200))

    canvas.save(path)


def main():
    make_ball(OUT / "ball.png")
    print(f"Wrote {OUT / 'ball.png'}")
    make_ring(OUT / "ring_red.png", PRIMARY)
    print(f"Wrote {OUT / 'ring_red.png'}")
    make_ring(OUT / "ring_blue.png", ACCENT)
    print(f"Wrote {OUT / 'ring_blue.png'}")
    make_ring(OUT / "ring_green.png", MINT)
    print(f"Wrote {OUT / 'ring_green.png'}")
    make_ring(OUT / "ring_yellow.png", SECONDARY)
    print(f"Wrote {OUT / 'ring_yellow.png'}")
    make_mascot(OUT / "mascot.png")
    print(f"Wrote {OUT / 'mascot.png'}")


if __name__ == "__main__":
    main()
