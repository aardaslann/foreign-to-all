extends SceneTree

# A character sheet: the cutscene cast, big, on a neutral ground, in every
# pose the films use. Redesigning a figure by rendering whole cutscenes is
# forty seconds a look; this is four.
#
#   <godot> --path . --script res://tools/charsheet.gd -- <out.png> [--night]

const CA := "res://scenes/ui/CutsceneArt.gd"
const W := 1920
const H := 1080

var _done: bool = false
var _vp: SubViewport = null
var _wait: int = 0
var _out: String = ""


func _process(_d: float) -> bool:
	if _vp == null:
		var args: PackedStringArray = OS.get_cmdline_user_args()
		_out = args[0]
		var gs = root.get_node_or_null("GameState")
		if gs != null and not args.has("--night"):
			gs.set("time_of_day", "morning")
		_vp = SubViewport.new()
		_vp.size = Vector2i(W, H)
		_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(_vp)
		var node := Node2D.new()
		node.set_script(load("res://tools/CharSheetDraw.gd"))
		node.set("strip", args.has("--strip"))
		_vp.add_child(node)
		_wait = 8
		return false
	_wait -= 1
	if _wait > 0:
		return false
	_vp.get_texture().get_image().save_png(_out)
	print("wrote ", _out)
	quit(0)
	return true
