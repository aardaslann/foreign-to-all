extends CanvasLayer

const FADE_OUT := 0.30
const FADE_IN  := 0.35

var _overlay: ColorRect
var _busy := false


func _ready() -> void:
	layer = 128
	_overlay = ColorRect.new()
	_overlay.color = Color(0.05, 0.04, 0.10, 1.0)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)
	# Fade from black on every scene entry
	_fade_in()


func go(path: String) -> void:
	if _busy:
		return
	_busy = true
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var t := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	t.tween_property(_overlay, "color:a", 1.0, FADE_OUT)
	t.tween_callback(func():
		get_tree().change_scene_to_file(path)
		call_deferred("_after_change")
	)


func _after_change() -> void:
	_busy = false
	_fade_in()


func _fade_in() -> void:
	_overlay.color.a = 1.0
	# A destination's arrival thought can pause gameplay during _ready.
	# Finish revealing it instead of leaving the thought hidden under black.
	var t := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(_overlay, "color:a", 0.0, FADE_IN)
	t.tween_callback(func(): _overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE)
