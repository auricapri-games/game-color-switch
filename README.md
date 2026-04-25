# Color Switch

Part of [auricapri-games](https://github.com/auricapri-games) factory.

- Slug: `game-color-switch`
- Palette: `doce_candy`
- Asset strategy: `generated`

## Implementation status

Scaffolded by orchestrator. Agent in progress.

## Build

```bash
flutter pub get
python3 scripts/gen_sprites.py    # produce assets/sprites/*.png
flutter run -d web-server --web-port=8080
```

## Quality gate

```bash
bash /home/auricapri/auricapri-games-factory/scripts/quality_gate.sh $(pwd)
```
