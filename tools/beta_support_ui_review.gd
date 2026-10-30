extends SceneTree

var failures := 0
var out := "C:/Users/Arda/Documents/ForeignToAll/work/beta/support-review"

func _initialize() -> void:
	_run.call_deferred()

func capture(label: String) -> void:
	for i in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out.path_join(label + ".png"))

func _run() -> void:
	var sm := root.get_node("SaveManager")
	sm.use_test_storage("beta-support-ui")
	DirAccess.make_dir_recursive_absolute(out)
	var gs := root.get_node("GameState")
	gs.reset()
	gs.city = "london"
	gs.world_flags["london_arrived"] = true
	gs.quests["find_bed"] = {"completed":true, "steps":[]}
	var world: Node = load("res://scenes/world/LondonTerrace.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	for i in range(8):
		await process_frame
	gs.misunderstand("english", "give me a hand", "She was checking what I could do")
	gs.understand("english", "give me a hand", "Val was asking for help with the notices. I could still decline.", "The box in the sentence")
	var journal := get_first_node_in_group("journal")
	journal._page = "Phrases"
	journal._open()
	await capture("discovered-phrases")
	if journal._word_list.get_child_count() == 0:
		failures += 1
	journal._close()
	var menu := world.get_node("UILayer/EscapeMenu")
	menu._open()
	menu._on_feedback()
	await process_frame
	var feedback: Control = menu._feedback
	if feedback.size.x < root.get_visible_rect().size.x * 0.9 or feedback._note.size.y < 180:
		failures += 1
	feedback._note.text = "I understood Val's request after she pointed at the parcel. I liked being able to say no."
	feedback._save()
	await capture("beta-feedback")
	if feedback._path.is_empty() or root.gui_get_focus_owner() != feedback._note:
		failures += 1
	feedback.closed.emit()
	await process_frame
	if root.gui_get_focus_owner() != menu.get_node("Panel/Margin/VBox/ResumeButton"):
		failures += 1
	menu._on_resume()
	world.queue_free()
	await process_frame
	print("BETA SUPPORT UI: ", failures, " failures; captures ", out)
	quit(1 if failures else 0)
