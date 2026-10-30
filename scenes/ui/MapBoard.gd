extends Control

signal place_selected(path: String)
signal marker_selected(index: int)

const ATLAS := preload("res://scenes/ui/MapAtlas.gd")
const INK := preload("res://scenes/ui/MapInk.gd")
const APPEARANCE := preload("res://scenes/player/AlienAppearance.gd")
const STREET := preload("res://scenes/world/EnvironmentStreet.gd")
const INTERIOR := preload("res://scenes/world/EnvironmentInterior.gd")
const ACTIVITY := preload("res://scenes/world/ActivityBackground.gd")
const WORLD_SIZE := Vector2(1152, 648)
const TILE_SIZE := Vector2(174, 112)
var here := ""
var selected := ""
var pins: Array[Dictionary] = []
var itinerary: Array[String] = []
var city_mode := false
var highlighted := -1:
	set(value):
		highlighted = value
		queue_redraw()
var zoom := 1.0
var pan := Vector2.ZERO
var _plate: SubViewport
var _graph: Dictionary = {}
var _bounds := Rect2()
var _textures: Dictionary = {}
var _hits: Array[Dictionary] = []
var _drag := false
var _moved := false
var _press := Vector2.ZERO
var _time := 0.0
var _alien: Texture2D
var _player_position := Vector2.ZERO
var _link_key := ""
var _links: Array[Dictionary] = []

func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	resized.connect(queue_redraw)
	gui_input.connect(_input_board)

func show_place(path: String, current: String, live: Node, steps: Array[String]) -> void:
	selected = path
	here = current
	itinerary = steps
	pins = ATLAS.markers(path, live)
	highlighted = -1
	var player := live.get_node_or_null("Player") as Node2D
	if player != null: _player_position = (live as Node2D).to_local(player.global_position) + Vector2(0, 20)
	_alien = APPEARANCE.strip("idle_down", APPEARANCE.current())
	if _plate != null:
		remove_child(_plate)
		_plate.queue_free()
	_plate = SubViewport.new()
	_plate.size = Vector2i(1152, 648)
	_plate.disable_3d = true
	_plate.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(_plate)
	var row := ATLAS.record(path)
	var renderer: Node2D
	if not ATLAS.PLACES.location(row.id).is_empty(): renderer = ACTIVITY.new()
	elif row.design.has("district"): renderer = STREET.new()
	else: renderer = INTERIOR.new()
	renderer.scene_id = row.id
	renderer.staging_only = true
	renderer.process_mode = Node.PROCESS_MODE_DISABLED
	_plate.add_child(renderer)
	queue_redraw()

func build_city(city: String) -> void:
	_graph.clear()
	_textures.clear()
	var paths := ATLAS.city_places(city)
	if paths.is_empty(): return
	var hub: String = paths[0]
	for path: String in paths:
		if ATLAS.GRAPH.TRANSIT.has(path): hub = path; break
	var parents := {hub: ""}
	var children := {}
	var queue: Array[String] = [hub]
	var i := 0
	while i < queue.size():
		var path: String = queue[i]
		i += 1
		children[path] = []
		var adjacent := ATLAS.neighbors(path)
		for other: String in paths:
			if ATLAS.neighbors(other).has(path) and not adjacent.has(other): adjacent.append(other)
		adjacent.sort_custom(func(a: String, b: String): return ATLAS.title(a) < ATLAS.title(b))
		for next: String in adjacent:
			if parents.has(next) or not paths.has(next): continue
			parents[next] = path
			children[path].append(next)
			queue.append(next)
	var ordered: Array[String] = []
	_order_branch(hub, children, ordered)
	for path: String in paths:
		if not ordered.has(path): ordered.append(path)
	var columns := ceili(sqrt(ordered.size() * 1.5))
	for index in range(ordered.size()):
		var row := index / columns
		var col := index % columns
		if row % 2 == 1: col = columns - 1 - col
		_graph[ordered[index]] = Vector2(col * 244, row * 164)
		_textures[ordered[index]] = ATLAS.thumbnail(ordered[index])
	_bounds = Rect2(Vector2.ZERO, TILE_SIZE)
	for at: Vector2 in _graph.values(): _bounds = _bounds.merge(Rect2(at, TILE_SIZE))
	_link_key = ""
	reset_view()

func _order_branch(path: String, children: Dictionary, ordered: Array[String]) -> void:
	ordered.append(path)
	for child: String in children.get(path, []): _order_branch(child, children, ordered)

func set_city_mode(value: bool) -> void:
	city_mode = value
	reset_view()

func reset_view() -> void:
	zoom = 1.0
	pan = Vector2.ZERO
	_drag = false
	queue_redraw()

func change_zoom(delta: float, focus := Vector2(-1, -1)) -> void:
	var center := size * 0.5 if focus.x < 0 else focus
	var before := zoom
	zoom = clampf(zoom + delta, 1, 3)
	pan = (pan + size * 0.5 - center) * (zoom / before) - size * 0.5 + center
	_limit_pan()
	queue_redraw()

func _limit_pan() -> void:
	var limit := size * maxf(0.0, zoom - 1.0) * 0.5
	pan = pan.clamp(-limit, limit)

func picture_rect() -> Rect2:
	var scale_factor := minf((size.x - 36) / WORLD_SIZE.x, (size.y - 36) / WORLD_SIZE.y) * zoom
	var dimensions := WORLD_SIZE * scale_factor
	return Rect2((size - dimensions) * 0.5 + pan, dimensions)

func world_point(at: Vector2) -> Vector2:
	var rect := picture_rect()
	return rect.position + at / WORLD_SIZE * rect.size

func _process(delta: float) -> void:
	if not is_visible_in_tree() or city_mode or selected != here or SaveManager.motion() == 0: return
	_time += delta * SaveManager.motion()
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), INK.DARK)
	for x in range(24, int(size.x), 48):
		draw_line(Vector2(x, 0), Vector2(x, 5), INK.EDGE)
		draw_line(Vector2(x, size.y - 5), Vector2(x, size.y), INK.EDGE)
	for y in range(24, int(size.y), 48):
		draw_line(Vector2(0, y), Vector2(5, y), INK.EDGE)
		draw_line(Vector2(size.x - 5, y), Vector2(size.x, y), INK.EDGE)
	_hits.clear()
	if city_mode: _draw_city()
	else: _draw_place()
	draw_rect(Rect2(Vector2.ONE, size - Vector2(2, 2)), INK.EDGE, false, 2)

func _draw_place() -> void:
	if _plate == null: return
	var rect := picture_rect()
	draw_texture_rect(_plate.get_texture(), rect, false)
	draw_rect(rect, Color("749188"), false, 2)
	# Flag leaders retain the exact ground position when nearby labels stack.
	var occupied: Array[Rect2] = []
	for i in range(pins.size()):
		var pin: Dictionary = pins[i]
		var ground := world_point(pin.pos)
		if not Rect2(Vector2.ZERO, size).has_point(ground): continue
		var marker := Rect2(ground + Vector2(-19, -59), Vector2(38, 36))
		marker.position.x = clampf(marker.position.x, 8, size.x - 46)
		var collided := true
		while collided:
			collided = false
			for used: Rect2 in occupied:
				if used.grow(3).intersects(marker): marker.position.y -= 42; collided = true; break
		occupied.append(marker)
		var color := INK.GOLD if pin.kind == "door" else (INK.CORAL if pin.kind == "activity" else INK.MINT)
		if pin.kind == "transit": color = INK.MINT
		if i == highlighted: color = Color.WHITE
		draw_line(marker.get_center(), ground, Color("152520"), 5)
		draw_line(marker.get_center(), ground, color, 2)
		draw_texture_rect(INK.icon("here"), Rect2(ground - Vector2(5, 5), Vector2(10, 10)), false, color)
		draw_rect(marker.grow(2), Color("111c20"))
		draw_rect(marker, color)
		_text(marker.position + Vector2(0, 26), "%02d" % (i + 1), 19, INK.DARK, marker.size.x, HORIZONTAL_ALIGNMENT_CENTER)
		_hits.append({"rect": marker.grow(4), "pin": i})
	if selected == here:
		var at := world_point(_player_position)
		var lift := 2 * sin(_time * 2)
		draw_circle(at + Vector2(0, 2), 15, Color("102922"))
		draw_arc(at + Vector2(0, 2), 16, 0, TAU, 24, INK.MINT, 2)
		draw_texture_rect_region(_alien, Rect2(at + Vector2(-36, -65 + lift), Vector2(72, 72)), Rect2(0, 0, 32, 32))
		var tag := Rect2(at + Vector2(-26, 20), Vector2(52, 24))
		draw_rect(tag, INK.MINT)
		_text(tag.position + Vector2(0, 18), "YOU", 14, INK.DARK, tag.size.x, HORIZONTAL_ALIGNMENT_CENTER)

func _graph_rect(path: String) -> Rect2:
	var factor := minf((size.x - 64) / _bounds.size.x, (size.y - 64) / _bounds.size.y) * zoom
	return Rect2((size - _bounds.size * factor) * 0.5 + pan + Vector2(_graph[path]) * factor, TILE_SIZE * factor)

func _draw_city() -> void:
	if _graph.is_empty(): return
	if _link_key.is_empty():
		_link_key = "ready"
		_build_links()
	var factor := minf((size.x - 64) / _bounds.size.x, (size.y - 64) / _bounds.size.y) * zoom
	var offset := (size - _bounds.size * factor) * 0.5 + pan
	for link: Dictionary in _links:
		var step := itinerary.find(link.from)
		var active: bool = step >= 0 and step + 1 < itinerary.size() and itinerary[step + 1] == link.to
		step = itinerary.find(link.to)
		active = active or (step >= 0 and step + 1 < itinerary.size() and itinerary[step + 1] == link.from)
		var color := INK.GOLD if active else INK.EDGE
		var points := PackedVector2Array()
		for at: Vector2 in link.points: points.append(at * factor + offset)
		draw_polyline(points, INK.DARK, 7)
		draw_polyline(points, color, 3 if active else 1.5)
	for path: String in _graph:
		var rect := _graph_rect(path)
		if not rect.intersects(Rect2(Vector2.ZERO, size)): continue
		var color := INK.GOLD if itinerary.has(path) else (INK.MINT if path == here else INK.EDGE)
		draw_rect(rect.grow(4), INK.DARK)
		draw_rect(rect.grow(2), color, false, 2)
		var art_rect := Rect2(rect.position, Vector2(rect.size.x, maxf(12, rect.size.y - 32)))
		draw_texture_rect(_textures[path], art_rect, false)
		draw_rect(Rect2(rect.position + Vector2(0, art_rect.size.y), Vector2(rect.size.x, rect.size.y - art_rect.size.y)), INK.PAPER)
		_text(rect.position + Vector2(4, rect.size.y - 9), ATLAS.title(path), 17, INK.INK, rect.size.x - 8)
		if path == here or itinerary.has(path):
			var badge := "YOU" if path == here else "%02d" % itinerary.find(path)
			var ink := INK.MINT if path == here else INK.GOLD
			draw_rect(Rect2(rect.position - Vector2(2, 8), Vector2(35, 16)), ink)
			_text(rect.position + Vector2(0, 4), badge, 11, INK.DARK, 31, HORIZONTAL_ALIGNMENT_CENTER)
		_hits.append({"rect": rect.grow(5), "path": path})

func _build_links() -> void:
	_links.clear()
	# Route the diagram's ink around its illustrations. A line through a third
	# place would falsely suggest that the player needs to pass through it.
	var grid := AStarGrid2D.new()
	var area := _bounds.grow(80)
	var first := Vector2i((area.position / 8).floor())
	grid.region = Rect2i(first, Vector2i((area.end / 8).ceil()) - first + Vector2i.ONE)
	grid.cell_size = Vector2(8, 8)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	grid.update()
	for path: String in _graph:
		var rect := Rect2(_graph[path], TILE_SIZE).grow(8)
		var start := Vector2i((rect.position / 8).floor())
		var end := Vector2i((rect.end / 8).ceil())
		grid.fill_solid_region(Rect2i(start, end - start + Vector2i.ONE))
	var done := {}
	for path: String in _graph:
		for next: String in ATLAS.neighbors(path):
			if not _graph.has(next): continue
			var key := path + "|" + next if path < next else next + "|" + path
			if done.has(key): continue
			done[key] = true
			var ra := Rect2(_graph[path], TILE_SIZE)
			var rb := Rect2(_graph[next], TILE_SIZE)
			var a := _port(ra, rb.get_center())
			var b := _port(rb, ra.get_center())
			var points := grid.get_point_path(Vector2i((a / 8).round()), Vector2i((b / 8).round()))
			if points.is_empty(): continue
			points.insert(0, ra.get_center())
			points.append(rb.get_center())
			_links.append({"from": path, "to": next, "points": points})

func _port(rect: Rect2, to: Vector2) -> Vector2:
	var direction := to - rect.get_center()
	if absf(direction.x) > absf(direction.y): return rect.get_center() + Vector2(signf(direction.x) * (rect.size.x * 0.5 + 24), 0)
	return rect.get_center() + Vector2(0, signf(direction.y) * (rect.size.y * 0.5 + 24))

func _text(at: Vector2, text: String, font_size: int, color: Color, width := -1.0, align := HORIZONTAL_ALIGNMENT_LEFT) -> void:
	var font: Font = UIStyles.reading_font
	if width > 0:
		while text.length() > 1 and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > width:
			text = text.left(-2) + "…"
	draw_string(font, at, text, align, width, font_size, color)

func _input_board(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed: change_zoom(0.25, event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed: change_zoom(-0.25, event.position)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_drag = true
				_moved = false
				_press = event.position
			else:
				_drag = false
				if not _moved:
					for hit: Dictionary in _hits:
						if hit.rect.has_point(event.position):
							if hit.has("path"): place_selected.emit(hit.path)
							else: marker_selected.emit(hit.pin)
							break
		accept_event()
	elif event is InputEventMouseMotion:
		if _drag:
			_moved = _moved or event.position.distance_to(_press) > 4
			pan += event.relative
			_limit_pan()
			queue_redraw()
		else:
			tooltip_text = ""
			for hit: Dictionary in _hits:
				if hit.rect.has_point(event.position):
					tooltip_text = ATLAS.title(hit.path) if hit.has("path") else String(pins[hit.pin].label)
		mouse_default_cursor_shape = CURSOR_DRAG if _drag else (CURSOR_POINTING_HAND if not tooltip_text.is_empty() else CURSOR_ARROW)
