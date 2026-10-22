# Laminate calling escalation

A Godot 4 isometric point-and-click adventure prototype.

## Play

Open `project.godot` in Godot 4.3 or newer (validated with 4.6.3), then press **F6** on `room.tscn` or **F5** to run the project. No plugins or external dependencies are required. Alternatively run `godot --path .` from this directory.

Left-click the white floor to move. Clicking again redirects the character immediately. Clicks outside the floor are ignored. The empty room uses direct paths inside a convex 768 × 384 pixel diamond; obstacle navigation can be added when rooms gain obstacles.

The character uses the supplied 128 × 128 sprites, all at 8 fps. Movement selects eight screen directions and mirrors the three right-facing animations for left-facing movement. Idle uses IA; up uses the archive's WAu filename spelling.

## Validate

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tests/smoke.gd
```

The smoke test checks floor clicks, rejected wall clicks, travel and stopping, animation frames/rates, all eight directions, mirroring, and redirection.
