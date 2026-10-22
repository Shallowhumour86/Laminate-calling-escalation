extends Node2D
## Position represents the character's feet, in room coordinates.

const SPEED := 150.0
const ANIMATIONS := {
	"idle": "IA", "right": "WAs", "up_right": "WAdu",
	"down_right": "WAdd", "down": "WAd", "up": "WAu"
}
var destination := Vector2.ZERO
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
	destination = point

func _physics_process(delta: float) -> void:
	var offset := destination - position
	if offset.length_squared() < 0.01:
		position = destination
		sprite.play("idle")
		return
	update_walk_animation(offset)
	position = position.move_toward(destination, SPEED * delta)

func update_walk_animation(direction: Vector2) -> void:
	# Eight equal screen-space sectors; mirror only the three left-facing walks.
	var sector := posmod(int(round(direction.angle() / (PI / 4.0))), 8)
	var names := ["right", "down_right", "down", "down_right", "right", "up_right", "up", "up_right"]
	sprite.flip_h = sector in [3, 4, 5]
	sprite.play(names[sector])
