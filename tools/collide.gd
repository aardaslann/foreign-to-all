extends SceneTree

# Render a scene with every collision body drawn over the art.
#
# Three faults have the same cause and none of them can be found by reading
# code: a counter you can walk through, a wall where there is nothing, and a
# worker standing on top of the stall he works at. All three are a mismatch
# between what is DRAWN and what is SOLID, and the only way to see a mismatch
# between two pictures is to put them on top of each other.
#
#   red     a solid: you cannot walk here
#   green   a person's feet, with a bar showing where they are clipped
#
#   cp tools/collide.gd collide.gd
#   <godot> --path . --script res://collide.gd -- <scene.tscn> <out.png> [more]
#   rm collide.gd

var _jobs: Array = []
var _vp: SubViewport = null
var _inst: Node = null
var _wait: int = 0


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var pairs: Array = []
	for a in args:
		if not String(a).begins_with("--"):
			pairs.append(String(a))
	for i in range(0, pairs.size() - 1, 2):
		_jobs.append([pairs[i], pairs[i + 1]])
	_vp = SubViewport.new()
	_vp.size = Vector2i(1152, 648)
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_vp)
	_next()


func _next() -> void:
	if _inst != null:
		_inst.queue_free()
		_inst = null
	if _jobs.is_empty():
		quit(0)
		return
	var job: Array = _jobs.pop_front()
	var packed: PackedScene = load(String(job[0]))
	if packed == null:
		print("FAILED ", job[0])
		_next()
		return
	_inst = packed.instantiate()
	for child in _inst.get_children():
		if child.name in ["UILayer"]:
			_inst.remove_child(child)
			child.queue_free()
	_vp.add_child(_inst)
	_wait = 16
	set_meta("out", String(job[1]))


func _process(_delta: float) -> bool:
	if _inst == null:
		return false
	_wait -= 1
	if _wait > 1:
		return false
	if _wait == 1:
		var ov := Node2D.new()
		ov.z_index = 400
		ov.set_script(load("res://tools/CollideOverlay.gd"))
		ov.set("root_node", _inst)
		_inst.add_child(ov)
		return false
	var img: Image = _vp.get_texture().get_image()
	img.save_png(String(get_meta("out")))
	print("shot ", get_meta("out"))
	_next()
	return false
