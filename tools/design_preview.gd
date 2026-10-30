extends SceneTree

var _viewport: Viewport
var _scene: Node
var _jobs: Array = []
var _frames: int = 0
var _out: String = ""
var _id: String = ""
var _city: String = ""
var _contacts: Dictionary = {}
var _batch_dir: String = ""
var _phase: float = 1.0
var _night: bool = false

func _initialize() -> void:
	var gs = root.get_node("GameState")
	gs.city = "hanoi"
	gs.time_of_day = "morning"
	gs.world_flags["arrived_hanoi"] = true
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.has("--prepared"):
		load("res://tools/PreparedCityPreview.gd").install()
		args.remove_at(args.find("--prepared"))
	var only_city: String = ""
	if args.has("--phase"):
		var at: int = args.find("--phase")
		_phase = float(args[at+1])
		args.remove_at(at+1)
		args.remove_at(at)
	if args.has("--city"):
		var at: int = args.find("--city")
		only_city = args[at+1]
		args.remove_at(at+1)
		args.remove_at(at)
	if args.has("--night"):
		_night = true
		args.remove_at(args.find("--night"))
	if args.has("--moving"):
		_phase = 20.0
		args.remove_at(args.find("--moving"))
	if args.size() > 1 and args[0] == "--catalog":
		_batch_dir = String(args[1])
		DirAccess.make_dir_recursive_absolute(_batch_dir)
		var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/environments/layouts.json"))
		for id: String in catalog:
			if not only_city.is_empty() and catalog[id]["city"] != only_city: continue
			_jobs.append([id, _batch_dir.path_join(id + ".png")])
	else:
		for i in range(0, args.size() - 1, 2):
			_jobs.append([args[i], args[i + 1]])
	root.size = Vector2i(1152, 648)
	root.content_scale_size = Vector2i(1152, 648)
	_viewport = root
	_next.call_deferred()

func _next() -> void:
	if _scene != null:
		_viewport.remove_child(_scene)
		_scene.free()
	if _jobs.is_empty():
		_write_contacts()
		quit()
		return
	var job: Array = _jobs.pop_front()
	_out = String(job[1])
	_id = String(job[0])
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/environments/layouts.json"))
	var design: Dictionary = catalog.get(String(job[0]), {})
	var gs = root.get_node("GameState")
	gs.city = String(design.get("city", "berlin"))
	gs.time_of_day = "night" if _night else "morning"
	_city = gs.city
	gs.world_flags["arrived_" + gs.city] = true
	var packed: PackedScene = load("res://scenes/world/" + String(job[0]) + ".tscn")
	_scene = packed.instantiate()
	var ui := _scene.get_node_or_null("UILayer")
	if ui != null:
		_scene.remove_child(ui)
		ui.queue_free()
	var camera := _scene.get_node_or_null("Player/Camera2D")
	if camera != null:
		camera.set("enabled", false)
	_viewport.add_child(_scene)
	current_scene = _scene
	_frames = 45

func _process(_delta: float) -> bool:
	if _frames <= 0:
		return false
	_frames -= 1
	if _frames == 6:
		for node in _scene.get_children():
			if node.get("scene_id") != null:
				node.set("_clock", _phase)
	if _frames == 0:
		var picture: Image = _viewport.get_texture().get_image()
		picture.save_png(_out)
		if not _batch_dir.is_empty():
			picture.resize(384, 216, Image.INTERPOLATE_NEAREST)
			if not _contacts.has(_city):
				_contacts[_city] = []
			_contacts[_city].append({"id": _id, "image": picture})
		print("DESIGN_PREVIEW ", _out)
		_next.call_deferred()
	return false

func _write_contacts() -> void:
	for city: String in _contacts:
		var scenes: Array = _contacts[city]
		var sheet: Image = Image.create(1152, int(ceil(scenes.size() / 3.0)) * 216, false, Image.FORMAT_RGBA8)
		for i in range(scenes.size()):
			sheet.blit_rect(scenes[i]["image"], Rect2i(0, 0, 384, 216), Vector2i((i % 3) * 384, (i / 3) * 216))
		sheet.save_png(_batch_dir.path_join("contact-" + city + ".png"))
	var report: Dictionary = {}
	for city: String in _contacts:
		report[city] = []
		for scene: Dictionary in _contacts[city]:
			report[city].append(scene["id"])
	if not _batch_dir.is_empty():
		var file := FileAccess.open(_batch_dir.path_join("render-index.json"), FileAccess.WRITE)
		file.store_string(JSON.stringify(report, "\t"))
