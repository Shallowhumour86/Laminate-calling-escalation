extends Node2D
## Position represents the character's feet, in room coordinates.

const SPEED := 75.0
const ANIMATIONS := {
	"idle": "IA", "right": "WAs", "up_right": "WAdu",
	"down_right": "WAdd", "down": "WAd", "up": "WAu"
}
var destination := Vector2.ZERO
var waypoints := PackedVector2Array()
var sprite := AnimatedSprite2D.new()

func _ready() -> void:
	destination = position
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for animation: String in ANIMATIONS:
		frames.add_animation(animation)
		frames.set_animation_speed(animation, 8.0)
		frames.set_animation_loop(animation, true)
		for index in range(1, 9):
			frames.add_frame(animation, load("res://assets/character/%s_%d.png" % [ANIMATIONS[animation], index]))
	sprite.sprite_frames = frames
	# All frames share a 128 x 128 canvas. Keep a common foot anchor.
	sprite.position = Vector2(0, -64)
	add_child(sprite)
	sprite.play("idle")

func walk_to(point: Vector2) -> void:
	follow_path(PackedVector2Array([point]))

func follow_path(path: PackedVector2Array) -> void:
	waypoints = path.duplicate()
	if not waypoints.is_empty():
		destination = waypoints[waypoints.size() - 1]

func _physics_process(delta: float) -> void:
	var budget := SPEED * delta
	while not waypoints.is_empty():
		var target := waypoints[0]
		var offset := target - position
		if offset.length() <= budget:
			position = target
			budget -= offset.length()
			waypoints.remove_at(0)
		else:
			update_walk_animation(offset)
			position = position.move_toward(target, budget)
			return
	sprite.play("idle")

func update_walk_animation(direction: Vector2) -> void:
	# Eight equal screen-space sectors; mirror only the three left-facing walks.
	var sector := posmod(int(round(direction.angle() / (PI / 4.0))), 8)
	var names := ["right", "down_right", "down", "down_right", "right", "up_right", "up", "up_right"]
	sprite.flip_h = sector in [3, 4, 5]
	sprite.play(names[sector])
