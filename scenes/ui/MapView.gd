extends CanvasLayer

const ATLAS := preload("res://scenes/ui/MapAtlas.gd")
const INK := preload("res://scenes/ui/MapInk.gd")
const BOARD := preload("res://scenes/ui/MapBoard.gd")
var _panel_root: Control
var _title: Label
var _sub: Label
var _board: Control
var _scene: Node
var _here := ""
var _selected := ""
var _city := ""
var _locations: VBoxContainer
var _place_scroll: ScrollContainer
var _connections: VBoxContainer
var _route: VBoxContainer
var _search: LineEdit
var _mode_buttons: Array[Button] = []
var _close_button: Button
var _destination: Label
var _status: Label
var _count: Label
var _filter := ""
var _focus_before: Control
var _buttons: Dictionary = {}
var _margin: MarginContainer
var _bottom: HBoxContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 18
	add_to_group("map_view")
	_build_ui()
	_panel_root.resized.connect(_fit)
	_fit.call_deferred()

func _fit() -> void:
	var compact := _panel_root.size.y < 850
	_bottom.custom_minimum_size.y = 132 if compact else 202
	_board.custom_minimum_size.y = 180 if compact else 280
	for side: String in ["top", "bottom"]: _margin.add_theme_constant_override("margin_" + side, 16 if compact else 24)

func open_from_hud() -> void:
	if GameState.world_flags.get("has_map", false) and not get_tree().paused: _open()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("district_map") and not event.is_echo():
		if _panel_root.visible:
			_close()
		elif GameState.world_flags.get("has_map", false) and not get_tree().paused:
			_open()
		else: return
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("back") and _panel_root.visible:
		get_viewport().set_input_as_handled()
		_close()

func _open() -> void:
	if _panel_root.visible or get_tree().paused: return
	_scene = get_tree().current_scene
	if _scene == null or not ATLAS.catalog().has(_scene.scene_file_path): return
	_here = _scene.scene_file_path
	_city = ATLAS.record(_here).city
	_focus_before = get_viewport().gui_get_focus_owner()
	_title.text = String(GameState.CITIES[_city].name)
	_sub.text = "KARTE   /   FIELD ATLAS"
	_filter = ""
	_search.clear()
	_count.text = "%02d PLACES" % ATLAS.city_places(_city).size()
	_panel_root.show()
	get_tree().paused = true
	_board.build_city(_city)
	_set_mode(false)
	_select(_here)
	_populate_places()
	_close_button.grab_focus()

func _close() -> void:
	if not _panel_root.visible: return
	_panel_root.hide()
	get_tree().paused = false
	if is_instance_valid(_focus_before) and _focus_before.is_visible_in_tree(): _focus_before.grab_focus()

func _exit_tree() -> void:
	if is_instance_valid(_panel_root) and _panel_root.visible: get_tree().paused = false

func _set_mode(city_mode: bool) -> void:
	_board.set_city_mode(city_mode)
	_mode_buttons[0].set_pressed_no_signal(not city_mode)
	_mode_buttons[1].set_pressed_no_signal(city_mode)

func _select(path: String) -> void:
	if not ATLAS.record(path).get("city", "") == _city: return
	_selected = path
	var row := ATLAS.record(path)
	_destination.text = row.title
	var region := GameState.region_name(row.region) if not String(row.region).is_empty() else ""
	_status.text = "YOU ARE HERE" if path == _here else (region + "  /  " + _kind(row.kind))
	_status.add_theme_color_override("font_color", INK.MINT if path == _here else INK.GOLD)
	var steps := ATLAS.route(_here, path, _scene)
	_board.show_place(path, _here, _scene, steps)
	if not _board.city_mode: _board.reset_view()
	_populate_connections()
	_populate_route(steps)
	for other: String in _buttons:
		_buttons[other].set_pressed_no_signal(other == path)
	_reveal_selection.call_deferred()

func _reveal_selection() -> void:
	if _buttons.has(_selected): _place_scroll.ensure_control_visible(_buttons[_selected])

func _kind(kind: String) -> String:
	if kind == "street": return "NEIGHBOURHOOD"
	if kind == "place": return "LOCAL PLACE"
	return kind.to_upper()

func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

func _populate_places() -> void:
	_clear(_locations)
	_buttons.clear()
	var matches := 0
	for path: String in ATLAS.city_places(_city):
		var row := ATLAS.record(path)
		if not _filter.is_empty() and not (String(row.title) + " " + GameState.region_name(row.region)).to_lower().contains(_filter): continue
		matches += 1
		var button := INK.button("")
		button.custom_minimum_size.y = 78
		button.toggle_mode = true
		button.tooltip_text = row.title
		button.set_pressed_no_signal(path == _selected)
		button.pressed.connect(func(): _select(path))
		_locations.add_child(button)
		_buttons[path] = button
		var margin := MarginContainer.new()
		margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		for side: String in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 8)
		button.add_child(margin)
		var row_box := HBoxContainer.new()
		row_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row_box.add_theme_constant_override("separation", 12)
		margin.add_child(row_box)
		var picture := TextureRect.new()
		picture.texture = ATLAS.thumbnail(path)
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		picture.custom_minimum_size = Vector2(94, 60)
		picture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row_box.add_child(picture)
		var text := VBoxContainer.new()
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		text.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row_box.add_child(text)
		var name_label := INK.label(row.title, 20)
		name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		text.add_child(name_label)
		var detail := INK.label("YOU ARE HERE" if path == _here else _kind(row.kind), 13, INK.MINT if path == _here else INK.MUTED)
		detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
		text.add_child(detail)
	if matches == 0: _locations.add_child(INK.label("No places found.", 20, INK.MUTED))

func _populate_connections() -> void:
	_clear(_connections)
	var pins: Array = _board.pins
	for i in range(pins.size()):
		var pin: Dictionary = pins[i]
		var button := INK.button("%02d   %s" % [i + 1, pin.label], pin.kind)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		button.tooltip_text = pin.label
		button.mouse_entered.connect(func(): _board.highlighted = i)
		button.focus_entered.connect(func(): _board.highlighted = i)
		button.mouse_exited.connect(func(): _board.highlighted = -1)
		button.pressed.connect(func(): _choose_pin(i))
		_connections.add_child(button)
		for dest: String in pin.get("destinations", []):
			var ride := INK.button("     " + ATLAS.title(dest), "transit")
			ride.alignment = HORIZONTAL_ALIGNMENT_LEFT
			ride.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			ride.tooltip_text = "Ride to " + ATLAS.title(dest)
			ride.pressed.connect(func(): _select(dest))
			ride.mouse_entered.connect(func(): _board.highlighted = i)
			ride.focus_entered.connect(func(): _board.highlighted = i)
			ride.mouse_exited.connect(func(): _board.highlighted = -1)
			_connections.add_child(ride)
	if pins.is_empty(): _connections.add_child(INK.label("No marked entrances.", 18, INK.MUTED))

func _choose_pin(index: int) -> void:
	if index < 0 or index >= _board.pins.size(): return
	var pin: Dictionary = _board.pins[index]
	if not String(pin.target).is_empty(): _select(pin.target)
	else:
		_board.highlighted = index
		_status.text = pin.label
		_set_mode(false)

func _populate_route(steps: Array[String]) -> void:
	_clear(_route)
	_route.add_child(INK.label("FROM WHERE YOU ARE", 14, INK.GOLD))
	if steps.size() < 2:
		var text := "Standing in " + ATLAS.title(_here) if _selected == _here else "No available route from here."
		if _selected == ATLAS.WORLD + "HotelRoom.tscn" and not GameState.world_flags.get("room_booked", false): text = "A room key is needed. Ask at hotel reception."
		var label := INK.label(text, 20, INK.MUTED)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_route.add_child(label)
		return
	for i in range(1, steps.size()):
		var ride := ATLAS.GRAPH.TRANSIT.has(steps[i - 1]) and Array(ATLAS.GRAPH.TRANSIT[steps[i - 1]][1]).has(steps[i])
		var prefix := "Ride to " if ride else ""
		if steps[i] == ATLAS.WORLD + "HotelRoom.tscn": prefix = "Floor 3: "
		var button := INK.button("%02d   %s%s" % [i, prefix, ATLAS.title(steps[i])], "transit" if ride else "door")
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		button.tooltip_text = ATLAS.title(steps[i])
		var path: String = steps[i]
		button.pressed.connect(func(): _select(path))
		_route.add_child(button)

func _build_ui() -> void:
	_panel_root = Control.new()
	_panel_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$UIRoot.add_child(_panel_root)
	var background := ColorRect.new()
	background.color = INK.DARK
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_panel_root.add_child(background)
	var margin := MarginContainer.new()
	_margin = margin
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right"]: margin.add_theme_constant_override("margin_" + side, 40)
	for side: String in ["top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 24)
	_panel_root.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	margin.add_child(column)
	var mast := HBoxContainer.new()
	column.add_child(mast)
	_sub = INK.label("KARTE   /   FIELD ATLAS", 16, INK.GOLD)
	_sub.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mast.add_child(_sub)
	_count = INK.label("", 16, INK.MUTED)
	mast.add_child(_count)
	_close_button = INK.button("", "close")
	_close_button.tooltip_text = "Close map"
	_close_button.pressed.connect(_close)
	mast.add_child(_close_button)
	var top := HBoxContainer.new()
	column.add_child(top)
	_title = INK.label("", 40)
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(_title)
	for text: String in ["Place", "City routes"]:
		var button := INK.button(text)
		button.toggle_mode = true
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		button.pressed.connect(func(): _set_mode(text == "City routes"))
		top.add_child(button)
		_mode_buttons.append(button)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 24)
	column.add_child(body)
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 3.4
	left.add_theme_constant_override("separation", 12)
	body.add_child(left)
	var caption := HBoxContainer.new()
	left.add_child(caption)
	var naming := VBoxContainer.new()
	naming.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	caption.add_child(naming)
	_destination = INK.label("", 27)
	_destination.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	naming.add_child(_destination)
	_status = INK.label("", 15, INK.MINT)
	_status.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	naming.add_child(_status)
	for kind: String in ["minus", "plus", "here"]:
		var button := INK.button("", kind)
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		button.tooltip_text = {"minus": "Zoom out", "plus": "Zoom in", "here": "Your location"}[kind]
		button.pressed.connect(func():
			if kind == "here": _select(_here); _board.reset_view()
			else: _board.change_zoom(0.25 if kind == "plus" else -0.25))
		caption.add_child(button)
	_board = BOARD.new()
	_board.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_board.custom_minimum_size.y = 280
	_board.place_selected.connect(_select)
	_board.marker_selected.connect(_choose_pin)
	left.add_child(_board)
	var bottom := HBoxContainer.new()
	_bottom = bottom
	bottom.custom_minimum_size.y = 202
	bottom.add_theme_constant_override("separation", 24)
	left.add_child(bottom)
	var connections_box := VBoxContainer.new()
	connections_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(connections_box)
	connections_box.add_child(INK.label("ENTRANCES & LOCAL STOPS", 14, INK.GOLD))
	_connections = _scroll(connections_box)
	var route_box := VBoxContainer.new()
	route_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(route_box)
	_route = _scroll(route_box)
	var right := VBoxContainer.new()
	right.custom_minimum_size.x = 344
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 1
	right.add_theme_constant_override("separation", 12)
	body.add_child(right)
	right.add_child(INK.label("CITY INDEX", 16, INK.GOLD))
	_search = LineEdit.new()
	_search.placeholder_text = "Find a place"
	_search.custom_minimum_size.y = 46
	_search.add_theme_font_override("font", UIStyles.reading_font)
	_search.add_theme_font_size_override("font_size", 20)
	_search.text_changed.connect(func(value: String): _filter = value.strip_edges().to_lower(); _populate_places())
	right.add_child(_search)
	_locations = _scroll(right)
	_place_scroll = _locations.get_parent()
	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", 28)
	column.add_child(foot)
	for kind: String in ["door", "transit", "activity"]:
		var icon := TextureRect.new()
		icon.texture = INK.icon(kind)
		icon.custom_minimum_size = Vector2(18, 18)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.modulate = INK.CORAL if kind == "activity" else (INK.MINT if kind == "transit" else INK.GOLD)
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		foot.add_child(icon)
		foot.add_child(INK.label({"door": "Entrance", "transit": "Transit", "activity": "Neighbourhood activity"}[kind], 15, INK.MUTED))
	var edition := INK.label("RENATE'S MAP", 15, INK.MUTED)
	edition.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edition.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	foot.add_child(edition)
	_panel_root.hide()

func _scroll(parent: Control) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	parent.add_child(scroll)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 6)
	scroll.add_child(column)
	return column
