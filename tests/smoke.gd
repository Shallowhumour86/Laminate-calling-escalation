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
		for tick in range(1200):
			actor._physics_process(1.0 / 60.0)
			assert(room.navigation.is_walkable(actor.position))
		assert(actor.position.is_equal_approx(target))
		assert(actor.sprite.animation == "idle")
	# Opposite sides of the bed require a multi-waypoint route.
	actor.position = Vector2(210, 370)
	assert(room.try_move_to(Vector2(720, 350)))
	assert(actor.waypoints.size() > 1)
	for tick in range(1200):
		var before: Vector2 = actor.position
		actor._physics_process(1.0 / 60.0)
		assert(room.navigation.segment_clear(before, actor.position))
	assert(actor.position.is_equal_approx(Vector2(720, 350)))
	var click := InputEventMouseButton.new()
	click.position = Vector2(720, 400)
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	room._unhandled_input(click)
	assert(actor.destination == click.position)
	click.button_index = MOUSE_BUTTON_RIGHT
	click.position = Vector2(350, 400)
	room._unhandled_input(click)
	assert(actor.destination == Vector2(720, 400))
	var old_destination: Vector2 = actor.destination
	assert(not room.try_move_to(Vector2(375, 355)))
	assert(actor.destination == old_destination)
	room.bed.sort_against(Vector2(375, 270))
	assert(room.bed.z_index > actor.z_index)
	room.bed.sort_against(Vector2(375, 470))
	assert(room.bed.z_index < actor.z_index)
	# Regression: the bed must remain above the floor in BOTH depth orders.
	for feet in [Vector2(375, 270), Vector2(375, 470), Vector2(750, 450)]:
		room.bed.sort_against(feet)
		assert(room.bed.is_visible_in_tree())
		for surface in room.get_children():
			if surface is Polygon2D:
				assert(room.bed.z_index > surface.z_index)
	# Art, collision and sorting all follow the same placement transform.
	assert(room.bed.position == Vector2(-160, 20))
	assert(room.navigation.is_walkable(Vector2(535, 335)))
	for corner in room.bed.footprint_in_room():
		assert(Geometry2D.is_point_in_polygon(corner, room.FLOOR))

	room.try_move_to(Vector2(700, 384))
	actor._physics_process(0.1)
	room.try_move_to(Vector2(560, 440))
	for tick in range(1200):
		actor._physics_process(1.0 / 60.0)
	assert(actor.position.is_equal_approx(Vector2(560, 440)))
	print("PASS: bed avoidance, rejected bed clicks, front/back depth, movement, floor containment, redirection, eight directions, mirroring and all 48 animation frames at 8 fps")
	quit()
