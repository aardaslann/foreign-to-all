extends SceneTree

# Render several world scenes into ONE contact sheet, so a whole city can be
# reviewed in a single look instead of one plate at a time.
#
#   cp tools/contact.gd contact.gd
#   <godot> --path . --script res://contact.gd -- <out.png> <cols> <scene...>
#   rm contact.gd

const CELL_W := 576
const CELL_H := 324

var _jobs: Array = []
var _out: String = ""
var _cols: int = 2
var _sheet: Image = null
var _vp: SubViewport = null
var _inst: Node = null
var _wait: int = 0
var _done: int = 0
var _ready_done: bool = false


func _process(_delta: float) -> bool:
	if not _ready_done:
		_ready_done = true
		var args: PackedStringArray = OS.get_cmdline_user_args()
		# --morning shoots the plates in daylight; without it they come out
		# in the state a fresh GameState is in, which is after dark.
		var gs = root.get_node_or_null("GameState")
		if gs != null and args.has("--morning"):
			gs.set("time_of_day", "morning")
		# --city=<name> so interiors, which colour themselves from
		# GameState rather than from the scene, render as the right city.
		for a in args:
			if gs != null and String(a).begins_with("--city="):
				gs.set("city", String(a).substr(7))
		_out = args[0]
		_cols = int(args[1])
		for i in range(2, args.size()):
			_jobs.append(args[i])
		var rows: int = int(ceil(float(_jobs.size()) / float(_cols)))
		_sheet = Image.create(CELL_W * _cols, CELL_H * rows, false,
			Image.FORMAT_RGBA8)
		_sheet.fill(Color(0.02, 0.02, 0.04))
		_vp = SubViewport.new()
		_vp.size = Vector2i(1152, 648)
		_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(_vp)
		_next()
		return false
	if _inst == null:
		return false
	_wait -= 1
	if _wait > 0:
		return false
	var img: Image = _vp.get_texture().get_image()
	img.resize(CELL_W, CELL_H, Image.INTERPOLATE_BILINEAR)
	var col: int = _done % _cols
	var row: int = _done / _cols
	_sheet.blit_rect(img, Rect2i(0, 0, CELL_W, CELL_H),
		Vector2i(col * CELL_W, row * CELL_H))
	_done += 1
	_next()
	return false


func _next() -> void:
	if _inst != null:
		_inst.queue_free()
		_inst = null
	if _jobs.is_empty():
		_sheet.save_png(_out)
		print("sheet -> ", _out, "  (", _done, " plates)")
		quit(0)
		return
	var path: String = String(_jobs.pop_front())
	var packed: PackedScene = load(path)
	if packed == null:
		print("FAILED ", path)
		_done += 1
		_next()
		return
	_inst = packed.instantiate()
	for child in _inst.get_children():
		if child.name in ["Player", "UILayer"]:
			_inst.remove_child(child)
			child.queue_free()
	_vp.add_child(_inst)
	_wait = 5
