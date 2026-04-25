# Color Switch — sprite brief

**Strategy**: generated
**Palette**: doce_candy

## Sprites required

- ball.png 40x40 colored ball (will tint at runtime)
- ring_segmented_4colors.png 240x240 4-segment ring transparent inside
- color_switch.png 30x30 small cross-shaped switch with 4 colors

## How to generate

1. Implement `scripts/gen_sprites.py` to draw each sprite via PIL.
2. Use AppColors.primary / secondary / accent / background / text — derive
   the actual hex by reading `lib/ds/app_colors.dart` (already generated
   from palette `doce_candy`).
3. Output PNGs to `assets/sprites/` matching the names above.
4. Run `python3 scripts/gen_sprites.py` from the repo root.

## Composition rules

- Every sprite must be ON-THEME (`doce_candy`). No alien colors.
- Use gradients + soft shadows where appropriate (not flat fill).
- Transparent background (RGBA) on every PNG.
- Anti-aliased edges (PIL's `draw.ellipse` etc handle this).
- Keep filesizes small (each sprite < 30KB).
