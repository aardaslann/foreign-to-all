extends SceneTree

# Steam screenshot capture: plays Berlin chapters 1-2 exactly as
# tools/berlin_story_test.gd does (route 0, real authored lines) and saves
# 1920x1080 frames at the moments a store page needs: the first glyph line
# and each word-discovery panel before and after its meaning is revealed.
#   <godot> --path . --script res://tools/steam_discovery_capture.gd -- <out_dir>

const STORY_PATH := "res://scenes/story/berlin/BerlinStory.gd"
const MAX_DISCOVERIES := 4
var STORY: Script
var gs: Node
var world: Node
var stage: Node
var exited := false
var out := ""
var shots := 0
var discoveries := 0
var seen_dialog: Dictionary = {}

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	out = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(out)
	STORY = load(STORY_PATH)
	root.get_node("SaveManager").use_test_storage("steam-capture")
	gs = root.get_node("GameState")
	gs.reset()
	gs.quests["find_bed"] = {"completed": true, "steps": []}
	await load_street(STORY.MITTE)
	await play("1")
	gs.world_flags["nights"] = 1
	await play("2")
	print("STEAM CAPTURE: ", shots, " frames in ", out)
	quit(0)

func load_street(path: String) -> void:
	world = load(path).instantiate()
	root.add_child(world)
	current_scene = world
	for i in range(8):
		await process_frame
	stage = get_first_node_in_group("berlin_stage")

func play(chapter: String) -> void:
	exited = false
	finish_play(chapter)
	var frames := 0
	while not exited and frames < 2200:
		frames += 1
		await process_frame
		var panel := get_first_node_in_group("word_discovery")
		if panel != null and panel._open:
			await discovery(panel, chapter)
			continue
		var dialog := get_first_node_in_group("dialogue_box")
		var thought := get_first_node_in_group("thought_box")
		var cinema := get_first_node_in_group("cutscene")
		if dialog.visible:
			var key := chapter + ":" + str(dialog._index)
			if not seen_dialog.has(key):
				seen_dialog[key] = true
				await capture("dialog-%s-%d" % [chapter, dialog._index])
			var options: Array = dialog._entries[dialog._index]["responses"]
			dialog._on_response(options[0])
		elif thought.visible:
			await capture("thought-" + chapter)
			thought.hide()
			paused = false
		elif cinema._open:
			cinema._advance()
		elif stage.busy():
			var director: Node = stage.get_child(stage.get_child_count() - 1)
			if not director.has_method("running"):
				continue
			if not director._frozen:
				var player := get_first_node_in_group("player") as Node2D
				if gs.carrying.is_empty():
					for prop in director.props.values():
						if is_instance_valid(prop) and prop.carryable and prop.visible:
							player.position = prop.position
							prop._process(0.01)
							var event := InputEventAction.new()
							event.action = "interact"
							event.pressed = true
							prop._unhandled_input(event)
							break
				else:
					for node in world.get_children():
						if node.get_script() == load("res://scenes/story/StoryZone.gd"):
							player.position = node.position
			else:
				for actor in director.actors.values():
					if is_instance_valid(actor) and actor.is_walking():
						actor._process(10.0)
				director._process(30.0)
	if not exited:
		push_error("STEAM CAPTURE: chapter " + chapter + " timed out")

func discovery(panel: Node, chapter: String) -> void:
	discoveries += 1
	if discoveries <= MAX_DISCOVERIES:
		await capture("discovery-%s-%d-context" % [chapter, discoveries])
	panel.reveal()
	if discoveries <= MAX_DISCOVERIES:
		await capture("discovery-%s-%d-meaning" % [chapter, discoveries])
	panel._process(0.25)
	panel._advance()

func finish_play(chapter: String) -> void:
	await stage.play(chapter)
	exited = true

func capture(label: String) -> void:
	for i in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out.path_join(label + ".png"))
	shots += 1
