extends SceneTree

# Look at the people.
#
#   <godot> --headless --path . --script res://tools/cast.gd -- <out.png>
#          [--roster]        everybody with a name, instead of the eight
#          [--city=berlin]   only the people who live in one city
#          [--page=1]        the next sixteen, when there are more than that
#
# charsheet.gd renders the CUTSCENE cast, which is a different renderer for a
# different situation. This one renders what a person on a street actually is:
# CharacterArt.draw_figure, at the size the street draws it, six frames apart
# so an idle loop is visible as motion rather than asserted in a comment.

const W := 1920
const H := 1080

var _vp: SubViewport = null
var _wait: int = 0
var _out: String = ""


func _process(_d: float) -> bool:
	if _vp == null:
		var args: PackedStringArray = OS.get_cmdline_user_args()
		if args.is_empty():
			print("usage: cast.gd -- <out.png> [--roster] [--city=<id>]")
			quit(1)
			return true
		_out = args[0]
		var which: String = "eight"
		var page: int = 0
		if args.has("--roster"):
			which = "roster"
		for a: String in args:
			if a.begins_with("--city="):
				which = a.substr(7)
			elif a.begins_with("--page="):
				page = int(a.substr(7))
		_vp = SubViewport.new()
		_vp.size = Vector2i(W, H)
		_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(_vp)
		var node := Node2D.new()
		node.set_script(load("res://tools/CastDraw.gd"))
		node.set("which", which)
		node.set("page", page)
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
