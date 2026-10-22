extends RefCounted
## Small deterministic navigation grid. Diagonal corner cutting is disabled.
const CELL := 4.0
var grid := AStarGrid2D.new()
var floor_polygon: PackedVector2Array
var obstacle: PackedVector2Array

func configure(floor_points: PackedVector2Array, blocked_points: PackedVector2Array) -> void:
	floor_polygon = floor_points
	# Foot clearance also absorbs grid rounding at the collision boundary.
	obstacle = Geometry2D.offset_polygon(blocked_points, 12.0)[0]
	grid.region = Rect2i(0, 0, 257, 161)
	grid.cell_size = Vector2(CELL, CELL)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	grid.update()
	for x in range(grid.region.size.x):
		for y in range(grid.region.size.y):
			var point := Vector2(x, y) * CELL
			var safe := is_walkable(point)
			for corner in [Vector2(-2, -2), Vector2(2, -2), Vector2(2, 2), Vector2(-2, 2)]:
				safe = safe and is_walkable(point + corner)
			grid.set_point_solid(Vector2i(x, y), not safe)

func is_walkable(point: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(point, floor_polygon) and not Geometry2D.is_point_in_polygon(point, obstacle)

func cell(point: Vector2) -> Vector2i:
	return Vector2i((point / CELL).round())

func path_between(from: Vector2, target: Vector2) -> PackedVector2Array:
	if not is_walkable(target):
		return PackedVector2Array()
	var start := cell(from)
	var end := cell(target)
	if not grid.is_in_boundsv(start) or not grid.is_in_boundsv(end):
		return PackedVector2Array()
	if grid.is_point_solid(start) or grid.is_point_solid(end):
		return PackedVector2Array()
	var raw := grid.get_point_path(start, end)
	if raw.is_empty():
		return raw
	raw[0] = from
	raw[raw.size() - 1] = target
	# Greedy line-of-sight smoothing removes grid zigzags while retaining clearance.
	var result := PackedVector2Array()
	var anchor := from
	var index := 1
	while index < raw.size():
		var furthest := index
		while furthest + 1 < raw.size() and segment_clear(anchor, raw[furthest + 1]):
			furthest += 1
		if not segment_clear(anchor, raw[furthest]):
			return PackedVector2Array()
		result.append(raw[furthest])
		anchor = raw[furthest]
		index = furthest + 1
	if result.is_empty():
		result.append(target)
	return result

func segment_clear(a: Vector2, b: Vector2) -> bool:
	if not is_walkable(a) or not is_walkable(b):
		return false
	# Exact edge intersections also catch tiny corner crossings after rotation.
	for index in range(obstacle.size()):
		if Geometry2D.segment_intersects_segment(a, b, obstacle[index], obstacle[(index + 1) % obstacle.size()]) != null:
			return false
	return true
