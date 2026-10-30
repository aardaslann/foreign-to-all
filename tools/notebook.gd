extends SceneTree

# Open the journal with words in it and look at it.
#
#   <godot> --path . --script res://tools/notebook.gd -- <out.png>
#
# The panel was hard-wired to German in three separate places and none of them
# were visible from the code: the population pass read familiarity["german"],
# the toast filtered on it, and the subtitle said so in a string literal. All
# three looked completely correct in isolation. What showed it was opening the
# thing in a city that does not speak German.
#
# So this seeds a save the way a real playthrough would leave it - a language
# half learned, another behind them, a third with one word caught once - and
# screenshots the panel.

const JOURNAL := "res://scenes/ui/Journal.tscn"
const W := 1920
const H := 1080

var _vp: SubViewport = null
var _wait: int = 0
var _out: String = ""


func _process(_d: float) -> bool:
	if _vp == null:
		var args: PackedStringArray = OS.get_cmdline_user_args()
		if args.is_empty():
			print("usage: notebook.gd -- <out.png>")
			quit(1)
			return true
		_out = args[0]
		_seed()
		_vp = SubViewport.new()
		_vp.size = Vector2i(W, H)
		_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(_vp)
		var back := ColorRect.new()
		back.color = Color(0.06, 0.05, 0.10)
		back.size = Vector2(W, H)
		_vp.add_child(back)
		var j: Node = load(JOURNAL).instantiate()
		_vp.add_child(j)
		# _open() pauses the tree, which would stop this tool dead. The panel
		# is populated and shown by hand instead.
		j.call("_populate")
		var panel: Object = j.get("_panel_root")
		if panel != null:
			(panel as CanvasItem).show()
		_wait = 12
		return false
	_wait -= 1
	if _wait > 0:
		return false
	_vp.get_texture().get_image().save_png(_out)
	print("wrote ", _out)
	quit(0)
	return true


# A plausible middle of a playthrough: Berlin behind them, Istanbul in front,
# and one word caught in a city they only passed through.
func _seed() -> void:
	var gs: Node = root.get_node_or_null("GameState")
	if gs == null:
		return
	gs.set("city", "istanbul")
	var fam: Dictionary = gs.get("familiarity")
	for w: Array in [
		["turkish", "cay", 92], ["turkish", "ekmek", 74], ["turkish", "abi", 88],
		["turkish", "bir", 66], ["turkish", "yok", 55], ["turkish", "var", 31],
		["turkish", "lütfen", 27], ["turkish", "vapur", 14],
		["german", "brot", 100], ["german", "guten", 84], ["german", "morgen", 72],
		["german", "pfand", 58], ["german", "kalt", 33], ["german", "wiesn", 12],
		["japanese", "sumimasen", 18],
	]:
		var lang: String = String(w[0])
		if not fam.has(lang):
			fam[lang] = {}
		Dictionary(fam[lang])[String(w[1])] = int(w[2])
