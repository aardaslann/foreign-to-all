extends Area2D

# The bed. Resting fades the world out, holds a quiet beat, and completes
# the "A place to power down" quest.

@export var require_booking: bool = false
@export var sign_text: String = ""
@export_multiline var sleep_text: String = ""

var player_nearby := false
var _resting := false

var _fade_layer: CanvasLayer
var _fade_rect:  ColorRect
var _fade_text:  Label


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_build_fade()


func _build_fade() -> void:
	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 60
	_fade_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_fade_layer)

	# Oversized rect — no anchor games, it simply covers everything
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0.01, 0.01, 0.03, 0.0)
	_fade_rect.position = Vector2(-2000, -2000)
	_fade_rect.size = Vector2(6000, 6000)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_layer.add_child(_fade_rect)

	_fade_text = Label.new()
	_fade_text.text = "you sleep.\n\nfor the first time on this world — deeply,\nand without one eye open.\n\n\n…when you wake, the light has changed."
	_fade_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_fade_text.add_theme_font_size_override("font_size", 17)
	_fade_text.add_theme_color_override("font_color", Color(0.84, 0.82, 1.00, 0.0))
	_fade_layer.add_child(_fade_text)


func _unhandled_input(event: InputEvent) -> void:
	if player_nearby and not _resting and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_choose_rest()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		$Prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		$Prompt.visible = false


func _booking_ok() -> bool:
	if require_booking and not GameState.room_booked_here():
		var thought := get_tree().get_first_node_in_group("thought_box")
		if thought != null:
			thought.show_thought("The door upstairs needs a key.\n\nThe person at the desk is still holding it.")
		return false
	return true


func _choose_rest() -> void:
	if _resting or not _booking_ok(): return
	var choice := get_tree().get_first_node_in_group("choice_panel")
	if choice == null:
		_rest()
		return
	_resting = true
	choice.open("A little rest", GameState.clock_text() + "  /  " + GameState.city_name(), [
		{"id": "morning", "label": "Sleep until morning", "sub": "08:00"},
		{"id": "evening", "label": "Rest until evening", "sub": "18:00"},
		{"id": "", "label": "Stay awake"},
	])
	var picked: String = await choice.chosen
	_resting = false
	if picked == "morning": _rest(8)
	elif picked == "evening": _rest(18)


func _rest(wake_hour: int = 8) -> void:
	if _resting or not _booking_ok(): return
	if not sleep_text.is_empty():
		_fade_text.text = sleep_text
	elif GameState.rested_here():
		_fade_text.text = "you sleep.\n\nthe room is familiar now.\n\n…when you wake, the light has changed."
	if wake_hour == 18:
		_fade_text.text = "you let the city carry on without you.\n\nwhen you wake, the light is warmer.\n\n18:00"
	_resting = true
	$Prompt.visible = false
	get_tree().paused = true

	# Center the text on the viewport
	var vp := get_viewport().get_visible_rect().size
	_fade_text.size = Vector2(vp.x, 120)
	_fade_text.position = Vector2(0, vp.y * 0.44)

	var tw := _fade_layer.create_tween()
	tw.tween_property(_fade_rect, "color:a", 1.0, 1.4) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_callback(func():
		if GameState.city == "berlin":
			GameState.world_flags["rested"] = true
		# Per city as well: the airport desk wants to know you have slept
		# HERE, and a night in Berlin does not make you rested in London.
		GameState.world_flags["rested_" + GameState.city] = true
		GameState.rest_until(wake_hour)
		# Retain the old sleep counter for old saves and legacy story tools.
		# An afternoon nap is not automatically "tomorrow".
		if wake_hour == 8:
			GameState.world_flags["nights"] = int(GameState.world_flags.get("nights", 0)) + 1
		Story.guide()
		if GameState.city == "berlin":
			GameState.complete_quest_step("find_bed", 3)
		# The room's _process is paused during the sequence, so force a
		# redraw NOW, while the screen is black — when the fade lifts,
		# it is already morning
		var bg := get_node_or_null("../HotelRoomBackground")
		if bg is CanvasItem:
			(bg as CanvasItem).queue_redraw()
	)
	tw.tween_property(_fade_text, "theme_override_colors/font_color:a", 0.95, 1.0)
	tw.tween_interval(3.0)
	tw.tween_property(_fade_text, "theme_override_colors/font_color:a", 0.0, 0.8)
	tw.tween_property(_fade_rect, "color:a", 0.0, 1.2) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func():
		get_tree().paused = false
		_resting = false
		$Prompt.visible = player_nearby
		SaveManager.checkpoint()
	)
