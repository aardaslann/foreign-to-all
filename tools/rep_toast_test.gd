extends SceneTree

# The reputation card (scenes/ui/RepToast.gd) has to stay up long enough to
# read. It once left the moment it arrived - the exit tween ran in parallel
# with the hold - so this samples it at real time after a scored answer, both
# when the conversation ends and when it carries on.
#
# Run: godot --headless --path . --script res://tools/rep_toast_test.gd

var checks := 0
var failures := 0
var _t0 := -1


func _initialize() -> void:
	_run.call_deferred()


func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("REP TOAST: " + message)


func _run() -> void:
	root.get_node("SaveManager").use_test_storage("rep_toast")
	var gs: Node = root.get_node("GameState")
	gs.reset()
	gs.quests["find_bed"] = {"completed": true, "steps": []}
	var world: Node = load("res://scenes/world/Mitte.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	for i in range(8):
		await process_frame
	var dlg := get_first_node_in_group("dialogue_box")
	var toast := get_first_node_in_group("rep_toast")
	for ending: String in ["closes", "continues"]:
		var first := {"words": [{"text": "Hallo.", "word": "hallo", "language": "german"}],
			"responses": [{"text": "Hallo!", "rep": 3, "style": "casual"}]}
		var second := {"words": [{"text": "Na?", "word": "na", "language": "german"}],
			"responses": [{"text": "Gut.", "rep": 1}]}
		var entries: Array = [first] if ending == "closes" else [first, second]
		dlg.show_dialogue(entries, "Kerstin", "", Color(0.4, 0.4, 0.5), true, "mitte")
		await _frames(4)
		_t0 = Time.get_ticks_msec()
		dlg._on_response(first["responses"][0])
		var card: Control = toast._card
		for at: float in [1.0, 2.5, 4.0]:
			await _until(at)
			check(card.visible and card.modulate.a > 0.95,
				"%s: the card is fully readable %.1fs after the answer" % [ending, at])
		await _until(6.5)
		check(not card.visible, "%s: the card has gone by 6.5s" % ending)
		if dlg.visible:
			dlg._close()
		await process_frame

	world.queue_free()
	await process_frame
	print("REP TOAST: ", checks, " checks; ", failures, " failures")
	quit(1 if failures else 0)


# Real seconds since the answer: the card runs on wall-clock time while the
# tree is paused under the dialogue.
func _until(seconds: float) -> void:
	while Time.get_ticks_msec() - _t0 < int(seconds * 1000.0):
		await process_frame


func _frames(n: int) -> void:
	for i in range(n):
		await process_frame
