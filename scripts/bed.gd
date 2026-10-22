extends Node2D
## The visible base's diamond defines both collision and the depth boundary.
const FOOTPRINT := [Vector2(400, 325), Vector2(532, 270), Vector2(675, 345), Vector2(542, 400)]
var sprite := Sprite2D.new()

func _ready() -> void:
	var texture := preload("res://assets/room/bed.png")
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(300, 0, 1260, 887)
	sprite.texture = atlas
	sprite.scale = Vector2.ONE * (280.0 / atlas.region.size.x)
	sprite.position = Vector2(537, 400 - atlas.region.size.y * sprite.scale.y / 2.0)
	add_child(sprite)

func front_depth(x: float) -> float:
	# Match the two front edges rather than one arbitrary centre-Y cutoff.
	if x <= 542.0:
		return 325.0 + clampf((x - 400.0) / 142.0, 0.0, 1.0) * 75.0
	return 400.0 - clampf((x - 542.0) / 133.0, 0.0, 1.0) * 55.0

func sort_against(feet: Vector2) -> void:
	z_index = 1 if feet.y < front_depth(feet.x) else -1
