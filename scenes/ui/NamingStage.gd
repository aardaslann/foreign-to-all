extends Control

const FIELD := preload("res://art/environments/scenes/Kiez-refined.png")
const CHAR := preload("res://scenes/npc/CharacterArt.gd")
const FRAME := Vector2(1152, 648)
var elapsed := 0.0
var friend: Dictionary = {}
var alien: Dictionary = {}


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	var zoom := maxf(size.x / FRAME.x, size.y / FRAME.y) * 1.18
	var motion: float = SaveManager.motion()
	var settle := smoothstep(0.0, 5.0, elapsed) if motion > 0.5 else 1.0
	var focus := Vector2(438, 465).lerp(Vector2(448, 460), settle)
	var centre := Vector2(size.x * 0.5, size.y * 0.33)
	var origin := centre - focus * zoom
	origin.x = clampf(origin.x, minf(0, size.x - FRAME.x * zoom), 0)
	origin.y = clampf(origin.y, minf(0, size.y * 0.68 - FRAME.y * zoom), 0)
	draw_rect(Rect2(Vector2.ZERO, size), Color("12171c"))
	draw_texture_rect(FIELD, Rect2(origin, FRAME * zoom), false, Color("bec4ce"))
	var t := elapsed if motion > 0.5 else 0.0
	var arriving := smoothstep(0.0, 1.8, elapsed) if motion > 0.5 else 1.0
	var friend_at := Vector2(363, 584).lerp(Vector2(400, 584), arriving)
	CHAR.draw_figure(self, (origin + friend_at * zoom).round(), 4.0 * zoom,
		friend, "walk" if arriving < 1.0 else "look", t, 3)
	CHAR.draw_figure(self, (origin + Vector2(537, 584) * zoom).round(), 4.0 * zoom,
		alien, "watch", t)
	# Subtitles have their own quiet band; complete figures stay above it.
	draw_rect(Rect2(0, size.y * 0.68, size.x, size.y * 0.32), Color("12171c"))
	draw_rect(Rect2(0, size.y * 0.68, size.x, 2), Color("b3a777"))
	draw_rect(Rect2(0, 0, size.x, size.y * 0.22), Color(0.04, 0.055, 0.07, 0.75))
	var fade := 1.0 - smoothstep(0.0, 0.55, elapsed)
	if fade > 0: draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.025, 0.035, fade))
