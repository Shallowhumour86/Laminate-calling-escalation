extends Node2D
## The visible base's diamond defines both collision and the depth boundary.
const HEADBOARD_ANCHOR := Vector2(272, 312)
const FOOTPRINT := [Vector2(400, 325), Vector2(532, 270), Vector2(675, 345), Vector2(542, 400)]
var sprite := Sprite2D.new()

func _ready() -> void:
	# Anchor the rear-left base corner on the wall and align the rear edge
	# with its 2:1 isometric slope (about 3.95 degrees counterclockwise).
	rotation = Vector2(2, -1).angle() - (FOOTPRINT[1] - FOOTPRINT[0]).angle()
	position = HEADBOARD_ANCHOR - FOOTPRINT[0].rotated(rotation)
	var texture := preload("res://assets/room/bed.png")
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(300, 0, 1260, 887)
	sprite.texture = atlas
	sprite.scale = Vector2.ONE * (280.0 / atlas.region.size.x)
	sprite.position = Vector2(537, 400 - atlas.region.size.y * sprite.scale.y / 2.0)
	add_child(sprite)

func footprint_in_room() -> PackedVector2Array:
	var points := PackedVector2Array()
	for point: Vector2 in FOOTPRINT:
		points.append(transform * point)
	return points

func front_depth(x: float) -> float:
	# Match the two front edges rather than one arbitrary centre-Y cutoff.
	if x <= 542.0:
		return 325.0 + clampf((x - 400.0) / 142.0, 0.0, 1.0) * 75.0
	return 400.0 - clampf((x - 542.0) / 133.0, 0.0, 1.0) * 55.0

func sort_against(feet: Vector2) -> void:
	var local_feet := to_local(feet)
	z_index = 1 if local_feet.y < front_depth(local_feet.x) else -1
