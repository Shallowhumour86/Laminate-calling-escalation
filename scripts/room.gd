extends Node2D

const Character = preload("res://scripts/character.gd")
# Exact floor bounds: 768 x 384 pixels, with a 2:1 isometric projection.
const FLOOR := [
	Vector2(512, 192), Vector2(896, 384),
	Vector2(512, 576), Vector2(128, 384)
]
const WALL_HEIGHT := Vector2(0, 128)
var character: Node2D

func _ready() -> void:
	character = Character.new()
	character.position = Vector2(512, 384)
	add_child(character)
	var hint := Label.new()
	hint.text = "Left-click the white floor to walk"
	hint.position = Vector2(24, 606)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hint)

func _draw() -> void:
	draw_colored_polygon(PackedVector2Array([FLOOR[3], FLOOR[3] - WALL_HEIGHT, FLOOR[0] - WALL_HEIGHT, FLOOR[0]]), Color("92969c"))
	draw_colored_polygon(PackedVector2Array([FLOOR[0], FLOOR[0] - WALL_HEIGHT, FLOOR[1] - WALL_HEIGHT, FLOOR[1]]), Color("777c84"))
	draw_colored_polygon(FLOOR, Color.WHITE)
	draw_polyline(PackedVector2Array([FLOOR[3], FLOOR[0], FLOOR[1]]), Color("555a62"), 2.0, true)
	draw_line(FLOOR[0], FLOOR[0] - WALL_HEIGHT, Color("555a62"), 2.0, true)

func try_move_to(point: Vector2) -> bool:
	if not Geometry2D.is_point_in_polygon(point, FLOOR):
		return false
	# The empty diamond is convex, so the straight path stays on the floor.
	character.walk_to(point)
	return true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		try_move_to(get_global_mouse_position())
