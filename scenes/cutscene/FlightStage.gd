extends Node2D

const SKY := preload("res://art/cutscene/flight/cloud-sea.png")
const PLANE := preload("res://art/cutscene/flight/airliner-retro.png")
const FRAME := Vector2(1152, 648)
var elapsed := 0.0
var reduced_motion := false
var departure_tint := Color.WHITE
var arrival_tint := Color.WHITE


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func plane_pose() -> Dictionary:
	if reduced_motion:
		return {"at": Vector2(590, 278), "width": 652.0, "angle": 0.0}
	var enter := 1.0 - pow(1.0 - clampf(elapsed / 2.8, 0, 1), 3.0)
	var leave := smoothstep(5.1, 7.6, elapsed)
	var at := Vector2(-380, 353).lerp(Vector2(526, 275), enter)
	at += Vector2(maxf(0, elapsed - 2.8) * 23.0, sin(elapsed * 0.85) * 3.0)
	at = at.lerp(Vector2(1390, 184), leave)
	# Keep the chunky sprite aligned to the pixel grid, without rotating its edges.
	return {"at": at.snapped(Vector2(2, 2)), "width": 684.0, "angle": 0.0}


func _draw() -> void:
	var travel := 0.45 if reduced_motion else clampf(elapsed / 7.6, 0, 1)
	# Overscan keeps the painted sky continuous throughout the slow tracking shot.
	var dimensions := FRAME * 1.12
	var offset := Vector2(lerpf(-8, -120, travel), -31)
	var daylight := departure_tint.lerp(arrival_tint, travel)
	draw_texture_rect(SKY, Rect2(offset.round(), dimensions), false, daylight)
	var pose := plane_pose()
	var at: Vector2 = pose.at
	var width: float = pose.width
	draw_set_transform(at.round(), pose.angle)
	var plane_size := Vector2(width, width * PLANE.get_height() / PLANE.get_width())
	draw_texture_rect(PLANE, Rect2(-plane_size * 0.5, plane_size), false, daylight.lerp(Color.WHITE, 0.3))
	draw_set_transform(Vector2.ZERO)
	# A small, steady cinematic matte, not a moving camera mask.
	draw_rect(Rect2(0, 0, FRAME.x, 34), Color("0b1820"))
	draw_rect(Rect2(0, 548, FRAME.x, 100), Color("0b1820"))
	draw_rect(Rect2(42, 548, FRAME.x - 84, 1), Color("526468"))
	var fade := 1.0 - smoothstep(0.0, 0.65, elapsed)
	if fade > 0: draw_rect(Rect2(Vector2.ZERO, FRAME), Color(0.04, 0.055, 0.07, fade))
