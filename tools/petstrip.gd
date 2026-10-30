extends SceneTree

# Ten frames of a cat being stroked, side by side, so the reaction can be
# judged as motion rather than as one lucky frame.
#
#   <godot> --path . --script res://petstrip.gd -- <scene.tscn> <out.png>

const COLS := 10
const CELL := Vector2i(150, 150)

var _vp: SubViewport = null
var _inst: Node = null
var _cat: Node2D = null
var _sheet: Image = null
var _i: int = 0
var _wait: int = 6


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	_vp = SubViewport.new()
	_vp.size = CELL
	_vp.transparent_bg = false
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_vp)
	_inst = (load(String(args[0])) as PackedScene).instantiate()
	_vp.add_child(_inst)
	set_meta("out", String(args[1]))
	_sheet = Image.create(CELL.x * COLS, CELL.y, false, Image.FORMAT_RGBA8)


func _find(n: Node) -> Node2D:
	if n.get_script() != null and String(n.get_script().resource_path).ends_with("StreetCat.gd"):
		return n as Node2D
	for c in n.get_children():
		var f: Node2D = _find(c)
		if f != null:
			return f
	return null


func _process(delta: float) -> bool:
	_wait -= 1
	if _wait > 0:
		return false
	if _cat == null:
		_cat = _find(_inst)
		if _cat == null:
			print("no cat in that scene")
			quit(1)
			return true
		# Frame the cat: the viewport is a window onto its patch of pavement.
		var cam := Camera2D.new()
		cam.position = _cat.global_position - Vector2(0, 34)
		cam.zoom = Vector2(1.6, 1.6)
		_inst.add_child(cam)
		cam.make_current()
		_cat.call("_stroke")
		_wait = 1
		return false
	var img: Image = _vp.get_texture().get_image()
	_sheet.blit_rect(img, Rect2i(Vector2i.ZERO, CELL), Vector2i(_i * CELL.x, 0))
	_i += 1
	if _i >= COLS:
		_sheet.save_png(String(get_meta("out")))
		print("strip ", get_meta("out"))
		quit(0)
		return true
	# Advance the cat's own clock by a fixed step so the strip is even.
	_cat.set("_t", float(_cat.get("_t")) + 0.09)
	_cat.set("_pet", float(_cat.get("_pet")) + 0.24)
	_cat.call("queue_redraw")
	_wait = 2
	return false
