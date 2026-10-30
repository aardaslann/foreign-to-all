extends SceneTree

var jobs = [
	["wreck", "berlin", "Kiez", "dawn"],
	["berlin", "berlin", "BerlinPrenzlberg", "morning"],
	["kiez", "berlin", "Mitte", "morning"],
	["london", "london", "LondonTerrace", "morning"],
	["london-night", "london", "LondonTerrace", "dawn"],
	["istanbul", "istanbul", "IstanbulHan", "morning"],
	["tokyo", "tokyo", "TokyoUeno", "dawn"]
]
var vp: SubViewport
var inst: Node
var wait_frames = 0
var out = ""
var started = false

func _process(_delta: float) -> bool:
	if not started:
		started = true
		vp = SubViewport.new()
		vp.size = Vector2i(1152,648)
		vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(vp)
		_next()
		return false
	wait_frames -= 1
	if wait_frames > 0: return false
	var im = vp.get_texture().get_image()
	if im == null:
		push_error("No rendered image")
		quit(2)
		return true
	im.save_png(out)
	print("Captured ",out)
	_next()
	return false

func _next() -> void:
	if inst != null:
		vp.remove_child(inst)
		inst.queue_free()
	if jobs.is_empty():
		quit()
		return
	var j = jobs.pop_front()
	var gs = root.get_node("GameState")
	gs.set("city",j[1])
	gs.set("time_of_day",j[3])
	var scene = load("res://scenes/world/"+j[2]+".tscn").instantiate()
	inst = scene.get_node_or_null("Background")
	if inst == null:
		for c in scene.get_children():
			if "Background" in String(c.name):
				inst = c
				break
	if inst == null:
		push_error("Missing background: "+j[2])
		quit(3)
		return
	scene.remove_child(inst)
	scene.free()
	vp.add_child(inst)
	inst.set_process(false)
	out = "res://trailer/public/connection/"+j[0]+".png"
	wait_frames = 14
