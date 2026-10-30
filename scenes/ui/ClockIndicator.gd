extends Control

var _time: Label
var _phase: Label


func _ready() -> void:
	custom_minimum_size = Vector2(174, 56)
	mouse_filter = Control.MOUSE_FILTER_PASS
	_time = Label.new()
	_time.position = Vector2(48, 3)
	_time.add_theme_font_size_override("font_size", 24)
	_time.add_theme_color_override("font_color", Color("f4eedb"))
	_time.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_time)
	_phase = Label.new()
	_phase.position = Vector2(49, 33)
	_phase.add_theme_font_size_override("font_size", 11)
	_phase.add_theme_color_override("font_color", Color("c5c7cd"))
	_phase.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_phase)
	_process(0.0)


func _process(_delta: float) -> void:
	_time.text = GameState.clock_text()
	_phase.text = GameState.CLOCK.phase(GameState.clock_minutes, GameState.city).to_upper()
	tooltip_text = GameState.city_name() + " / local time"
	queue_redraw()


func _draw() -> void:
	var phase: String = GameState.CLOCK.phase(GameState.clock_minutes, GameState.city)
	var ink := Color("e5c478")
	var pixels: Array[String] = ["...##...", "...##...", "..####..", "########", "########", "..####..", "...##...", "...##..."]
	if phase == "night":
		ink = Color("c6d4dc")
		pixels = ["..###...", ".###....", "###.....", "###.....", "###...##", "########", ".######.", "..####.."]
	elif phase in ["dawn", "sunset"]:
		ink = Color("efb087") if phase == "sunset" else Color("e9c594")
		pixels = ["...##...", "........", ".#....#.", "...##...", "..####..", ".######.", "........", "########"]
	for y in range(8):
		for x in range(8):
			if pixels[y][x] == "#": draw_rect(Rect2(12 + x * 3, 16 + y * 3, 3, 3), ink)
