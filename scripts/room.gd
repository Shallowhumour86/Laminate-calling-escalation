extends Node2D

const Navigator = preload("res://scripts/navigation.gd")
const Bed = preload("res://scripts/bed.gd")
const Character = preload("res://scripts/character.gd")
# Exact floor bounds: 768 x 384 pixels, with a 2:1 isometric projection.
const FLOOR := [
	Vector2(512, 192), Vector2(896, 384),
	Vector2(512, 576), Vector2(128, 384)
]
const WALL_HEIGHT := Vector2(0, 160)
var character: Node2D
var bed: Node2D
var navigation := Navigator.new()
var actors := Node2D.new()

func _ready() -> void:
	build_room_art()
	add_child(actors)
	bed = Bed.new()
	actors.add_child(bed)
	navigation.configure(PackedVector2Array(FLOOR), bed.footprint_in_room())
	character = Character.new()
	character.position = Vector2(512, 475)
	actors.add_child(character)
	bed.sort_against(character.position)
	var hint := Label.new()
	hint.text = "Left-click the floor to walk • Walk around the bed"
	hint.position = Vector2(24, 606)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hint)

func build_room_art() -> void:
	# Project the concept's floor and walls onto the original room geometry.
	# These three textured quads make the visual floor match navigation exactly.
	var back := Vector2(627, 505)
	var left := Vector2(60, 807)
	var right := Vector2(1190, 815)
	var front := Vector2(627, 1180)
	add_art(PackedVector2Array([FLOOR[3], FLOOR[3] - WALL_HEIGHT, FLOOR[0] - WALL_HEIGHT, FLOOR[0]]),
		PackedVector2Array([left, Vector2(60, 420), Vector2(627, 120), back]))
	add_art(PackedVector2Array([FLOOR[0], FLOOR[0] - WALL_HEIGHT, FLOOR[1] - WALL_HEIGHT, FLOOR[1]]),
		PackedVector2Array([back, Vector2(627, 120), Vector2(1190, 420), right]))
	add_art(PackedVector2Array(FLOOR), PackedVector2Array([back, right, front, left]))

func add_art(points: PackedVector2Array, texture_points: PackedVector2Array) -> void:
	var surface := Polygon2D.new()
	# Keep every room surface behind both actor depth orders (-1 and +1).
	surface.z_index = -10
	surface.polygon = points
	surface.uv = texture_points
	surface.texture = preload("res://assets/room/hotel.png")
	add_child(surface)

func _process(_delta: float) -> void:
	bed.sort_against(character.position)

func try_move_to(point: Vector2) -> bool:
	var path := navigation.path_between(character.position, point)
	if path.is_empty():
		return false
	character.follow_path(path)
	return true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		try_move_to(get_global_transform_with_canvas().affine_inverse() * event.position)
