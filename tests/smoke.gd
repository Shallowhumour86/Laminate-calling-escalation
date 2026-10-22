extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var room = load("res://room.tscn").instantiate()
	root.add_child(room)
	var actor = room.character
	actor.set_physics_process(false)
	assert(actor.sprite.animation == "idle")
	var initial_frame: int = actor.sprite.frame
	await create_timer(0.3).timeout
	assert(actor.sprite.frame != initial_frame)
	for animation in actor.sprite.sprite_frames.get_animation_names():
		assert(actor.sprite.sprite_frames.get_frame_count(animation) == 8)
		assert(actor.sprite.sprite_frames.get_animation_speed(animation) == 8.0)
	var directions := [Vector2.RIGHT, Vector2(1, 1), Vector2.DOWN, Vector2(-1, 1), Vector2.LEFT, Vector2(-1, -1), Vector2.UP, Vector2(1, -1)]
	var expected := ["right", "down_right", "down", "down_right", "right", "up_right", "up", "up_right"]
	for index in range(8):
		actor.update_walk_animation(directions[index])
		assert(actor.sprite.animation == expected[index])
		assert(actor.sprite.flip_h == (index in [3, 4, 5]))
	assert(not room.try_move_to(Vector2(512, 100)))
	assert(not room.try_move_to(Vector2(20, 600)))
	for target in [Vector2(512, 200), Vector2(880, 384), Vector2(512, 568), Vector2(144, 384)]:
		assert(room.try_move_to(target))
		var previous: Vector2 = actor.position
		actor._physics_process(1.0 / 60.0)
		assert(actor.position.distance_to(previous) <= actor.SPEED / 60.0 + 0.001)
		for tick in range(400):
			actor._physics_process(1.0 / 60.0)
			assert(Geometry2D.is_point_in_polygon(actor.position, room.FLOOR))
		assert(actor.position.is_equal_approx(target))
		assert(actor.sprite.animation == "idle")
	room.try_move_to(Vector2(700, 384))
	actor._physics_process(0.1)
	room.try_move_to(Vector2(400, 384))
	for tick in range(400):
		actor._physics_process(1.0 / 60.0)
	assert(actor.position.is_equal_approx(Vector2(400, 384)))
	print("PASS: movement, floor containment, redirection, eight directions, mirroring and all 48 animation frames at 8 fps")
	quit()
