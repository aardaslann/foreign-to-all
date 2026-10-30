extends SceneTree

# Renders cutscene shots into one contact sheet, so I can look at what the
# player will actually see instead of reasoning about it.
#
#   <godot> --headless --path . --script res://filmshot.gd -- \
#       <out.png> <cols> <city:district:at,at:act,act:line> ...
#
# Frame-counted rather than awaited, the same way shoot.gd works: awaiting
# process_frame from _initialize never comes back in --script mode.

const CELL_W := 768
const CELL_H := 432

var _specs: Array = []
var _out: String = ""
var _cols: int = 2
var _sheet: Image = null
var _idx: int = -1
var _vp: SubViewport = null
var _cut: CanvasLayer = null
var _wait: int = 0
var _gs = null
var _cut_script: Script = null


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	_out = args[0]
	_cols = int(args[1])
	for i in range(2, args.size()):
		if String(args[i]).begins_with("--"):
			continue
		_specs.append(String(args[i]))
	_gs = root.get_node_or_null("GameState")
	# --morning shoots in daylight. Half the game is set in the morning
	# and the cutscenes had only ever been looked at after dark.
	if _gs != null and args.has("--morning"):
		_gs.set("time_of_day", "morning")
	_cut_script = load("res://scenes/ui/Cutscene.gd")
	var rows: int = int(ceil(float(_specs.size()) / float(_cols)))
	_sheet = Image.create(_cols * CELL_W, rows * CELL_H, false,
		Image.FORMAT_RGBA8)
	_sheet.fill(Color(0.02, 0.02, 0.04, 1.0))


func _next() -> void:
	if _vp != null:
		_vp.queue_free()
		_vp = null
		_cut = null
	_idx += 1
	if _idx >= _specs.size():
		_sheet.save_png(_out)
		print("wrote ", _out)
		quit(0)
		return

	var bits: PackedStringArray = String(_specs[_idx]).split(":")
	var city: String = bits[0]
	var district: String = bits[1]
	var ats: PackedStringArray = bits[2].split(",")
	var acts: PackedStringArray = bits[3].split(",")
	var line: String = bits[4] if bits.size() > 4 else ""
	# A sixth field is how many shots into the reel this one is, so I can
	# see whether consecutive shots in one reel are the same photograph.
	var idx: int = int(bits[5]) if bits.size() > 5 else 0
	# A seventh field names the set, so a shot can be checked against the
	# sentence it is meant to be illustrating.
	var set_name: String = String(bits[6]) if bits.size() > 6 else "street"
	if _gs != null:
		_gs.set("city", city)
		_gs.set("current_region", district)

	_vp = SubViewport.new()
	_vp.size = Vector2i(1920, 1080)
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_vp)

	_cut = CanvasLayer.new()
	_cut.set_script(_cut_script)
	_vp.add_child(_cut)

	var cast: Array = []
	for k in range(ats.size()):
		cast.append({
			"at": float(ats[k]),
			"act": String(acts[k]) if k < acts.size() else "stand",
		})
	var reel: Array = []
	for f in range(idx):
		reel.append({"say": "", "cast": cast, "set": set_name})
	reel.append({"say": line, "cast": cast, "set": set_name})
	_cut.call("play", city, reel)
	for f2 in range(idx):
		_cut.call("_advance")
	# play() pauses the tree; this harness IS the tree.
	paused = false
	_wait = 8


func _process(_delta: float) -> bool:
	if _vp == null:
		if _idx < 0:
			_next()
		return false
	_wait -= 1
	# Push the shot past its opening fade before the grab.
	if _wait == 4 and _cut != null:
		_cut.call("_process", 0.9)
	if _wait > 0:
		return false
	var img: Image = _vp.get_texture().get_image()
	img.resize(CELL_W, CELL_H, Image.INTERPOLATE_LANCZOS)
	var cx: int = (_idx % _cols) * CELL_W
	var cy: int = int(_idx / _cols) * CELL_H
	_sheet.blit_rect(img, Rect2i(0, 0, CELL_W, CELL_H), Vector2i(cx, cy))
	print("shot ", _specs[_idx])
	_next()
	return false
