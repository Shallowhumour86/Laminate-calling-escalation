# Laminate calling escalation

A Godot 4 isometric point-and-click adventure prototype.

## Play

Open `project.godot` in Godot 4.3 or newer (validated with 4.6.3), then press **F6** on `room.tscn` or **F5** to run the project. No plugins or external dependencies are required. Alternatively run `godot --path .` from this directory.

Left-click the metallic floor to move. Movement speed is 75 pixels/second. Clicking again redirects the character immediately. Clicks outside the floor or inside the bed footprint are ignored without interrupting the current route. The floor retains its original 768 × 384 pixel diamond. A 4-pixel navigation grid with no diagonal corner cutting and line-of-sight smoothing with exact obstacle-edge checks routes around the bed, including 12 pixels of foot clearance. The room and separate bed artwork are adapted from the supplied concepts. The bed sits beneath the left-wall control panel at the marked location. Its headboard base is anchored flush to the left wall and rotated 3.95 degrees counterclockwise to match the wall slope. Artwork, footprint and depth boundary share that transform. The bed is 280 pixels wide against the 128-pixel character; its visible base defines the solid footprint. Its two front edges determine whether the character is drawn behind or in front, with the transparent artwork providing natural overlap.

The character uses the supplied 128 × 128 sprites, all at 8 fps. Movement selects eight screen directions and mirrors the three right-facing animations for left-facing movement. Idle uses IA; up uses the archive's WAu filename spelling.

## Validate

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tests/smoke.gd
```

The smoke test checks left/right mouse input, rejected wall/bed clicks, travel and stopping, frame playback/rates, all eight directions, mirroring, redirection, a route crossing behind the bed, clearance along every movement segment, front/back depth ordering, and bed visibility above the floor in both depth orders.

For visual testing, walk to both sides of the bed and click the opposite side. The character should route around either end, never across the mattress. Walk behind the headboard and back in front of the footboard to check sprite overlap.
