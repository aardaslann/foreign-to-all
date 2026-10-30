extends SceneTree

# Like shoot.gd but keeps the Player, so the alien and the crowd can be
# measured against each other in one frame.

var _vp: SubViewport = null
var _inst: Node = null
var _wait: int = 0
var _out: String = ""


func _process(_delta: float) -> bool:
	if _vp == null:
		var args: PackedStringArray = OS.get_cmdline_user_args()
		var gs = root.get_node_or_null("GameState")
		if gs != null:
			for a in args:
				if String(a) == "--morning":
					gs.set("time_of_day", "morning")
				elif String(a).begins_with("--city="):
					gs.set("city", String(a).substr(7))
		_out = String(args[1])
		_vp = SubViewport.new()
		_vp.size = Vector2i(1152, 648)
		_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(_vp)
		var packed: PackedScene = load(String(args[0]))
		_inst = packed.instantiate()
		for child in _inst.get_children():
			if child.name == "UILayer":
				_inst.remove_child(child)
				child.queue_free()
		_vp.add_child(_inst)
		_wait = 8
		return false
	_wait -= 1
	if _wait > 0:
		return false
	_vp.get_texture().get_image().save_png(_out)
	print("shot ", _out)
	quit(0)
	return true
