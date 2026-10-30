extends SceneTree

# Plays a real activity reel and lays every shot of it out in order, so the
# cutscene can be watched rather than reasoned about.
#
#   <godot> --path . --script res://tools/playreel.gd -- \
#       <out.png> <city> <district> [--morning]
#
# The reel is built by the same function the game uses - Streetside.reel() -
# so what lands on the sheet is what a player gets. It walks the beat graph,
# concatenates every beat's film, gives an unfilmed beat's line a shot of its
# own, and puts the row he took between one beat and the next.

const CELL_W := 768
const CELL_H := 432
const COLS := 2

var _shots: Array = []
var _out: String = ""
var _city: String = ""
var _district: String = ""
var _sheet: Image = null
var _idx: int = -1
var _vp: SubViewport = null
var _cut: CanvasLayer = null
var _wait: int = 0
var _gs = null
var _started: bool = false
var _survey: Array = []
var _which: int = 0


func _process(_d: float) -> bool:
	if not _started:
		_started = true
		_setup()
		return false
	if _vp == null:
		return true
	_wait -= 1
	if _wait == 6 and _cut != null:
		_cut.call("_process", 1.2)
	if _wait > 0:
		return false
	var img: Image = _vp.get_texture().get_image()
	img.resize(CELL_W, CELL_H, Image.INTERPOLATE_LANCZOS)
	_sheet.blit_rect(img, Rect2i(0, 0, CELL_W, CELL_H),
		Vector2i((_idx % COLS) * CELL_W, int(_idx / COLS) * CELL_H))
	# In survey mode _idx counts cells on the sheet, not shots in a reel.
	var si: int = mini(_idx, _shots.size() - 1)
	print("  %-26s set=%-16s %s" % [_city + ":" + _district,
		String(_shots[si].get("set", "street")),
		String(_shots[si].get("say", "")).substr(0, 58)])
	_idx += 1
	if not _survey.is_empty():
		_next_survey()
		return false
	if _idx >= _shots.size():
		_sheet.save_png(_out)
		print("wrote ", _out, "  (", _shots.size(), " shots)")
		quit(0)
		return true
	_show()
	return false


func _setup() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	_out = args[0]
	# "survey" plus a list of city:district renders one shot from each,
	# which is how all seventy-five get looked at in one pass.
	if String(args[1]) == "survey":
		for i in range(2, args.size()):
			if String(args[i]).begins_with("--"):
				continue
			_survey.append(String(args[i]))
	if _survey.is_empty():
		_city = args[1]
		_district = args[2]
	_gs = root.get_node_or_null("GameState")
	if _gs != null:
		if args.has("--morning"):
			_gs.set("time_of_day", "morning")
		_gs.set("money", 400)
	if not _survey.is_empty():
		var rows2: int = int(ceil(float(_survey.size()) / float(COLS)))
		_sheet = Image.create(COLS * CELL_W, rows2 * CELL_H, false,
			Image.FORMAT_RGBA8)
		_sheet.fill(Color(0.02, 0.02, 0.04, 1.0))
		_idx = 0
		_next_survey()
		return
	if _gs != null:
		_gs.set("city", _city)
		_gs.set("current_region", _district)
	_shots = _build_reel()
	if _shots.is_empty():
		print("no reel for ", _city, ":", _district)
		quit(1)
		return
	var rows: int = int(ceil(float(_shots.size()) / float(COLS)))
	_sheet = Image.create(COLS * CELL_W, rows * CELL_H, false,
		Image.FORMAT_RGBA8)
	_sheet.fill(Color(0.02, 0.02, 0.04, 1.0))
	_idx = 0
	print("reel ", _city, ":", _district, "  ", _shots.size(), " shots")
	_show()


# One reel at a time: build it, pick a shot from the middle of it, draw
# that, move on. The middle is where a reel is doing its work.
func _next_survey() -> void:
	while _which < _survey.size():
		var bits: PackedStringArray = String(_survey[_which]).split(":")
		_which += 1
		if bits.size() != 2:
			continue
		_city = bits[0]
		_district = bits[1]
		if _gs != null:
			_gs.set("city", _city)
			_gs.set("current_region", _district)
		var reel: Array = _build_reel()
		if reel.is_empty():
			continue
		_shots = [reel[mini(1, reel.size() - 1)]]
		_show()
		return
	_sheet.save_png(_out)
	print("wrote ", _out, "  (", _idx, " reels)")
	quit(0)

func _build_reel() -> Array:
	var SS = load("res://scenes/world/Streetside.gd")
	# The same walk the game does, from the same function. This used to be
	# copied out here and had drifted from it — the copy ignored price and
	# always took the first toss — so the sheet being inspected was not the
	# reel a player would ever get, which makes inspecting it worthless.
	#
	# purse -1 because the tool has no wallet and should show every beat the
	# author wrote; pick 0 so a toss resolves the same way twice and two runs
	# of one district are comparable.
	var built: Dictionary = SS.reel(_city, _district, -1, false, 0)
	return built.get("shots", [])


func _show() -> void:
	if _vp != null:
		_vp.queue_free()
	_vp = SubViewport.new()
	_vp.size = Vector2i(1920, 1080)
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_vp)
	_cut = CanvasLayer.new()
	_cut.set_script(load("res://scenes/ui/Cutscene.gd"))
	_vp.add_child(_cut)
	# Play the whole reel and step to the shot we want, so the shot index the
	# camera keys off is the one it would really be.
	#
	# In survey mode the reel is one shot long and _idx counts cells on the
	# sheet, so stepping by _idx ran it off the end and closed the cutscene
	# - which is why every cell after the first came out blank.
	_cut.call("play", _city, _shots)
	paused = false
	if _survey.is_empty():
		for i in range(_idx):
			_cut.call("_advance")
	_wait = 10
