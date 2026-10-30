extends SceneTree

# Render every distinct shot from normal, repeat, unaffordable and alternate
# reels, plus authored branches. All use the game's actual Cutscene renderer.
var _jobs: Array = []
var _shots: Array = []
var _out: String
var _city: String
var _region: String
var _key: String
var _vp: SubViewport
var _cut: CanvasLayer
var _index: int = 0
var _wait: int = 0
var _sheet: Image
var _report: Dictionary = {}
var _contacts: Dictionary = {}
var _phase: float = 1.25
var _full_frames: bool = false

func _initialize() -> void:
	if OS.get_cmdline_user_args().has("--prepared"):
		load("res://tools/PreparedCityPreview.gd").install()
	_out = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(_out)
	var profiles: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/environments/activity-direction.json"))
	_jobs = profiles.keys()
	var args := OS.get_cmdline_user_args()
	if args.has("--prepared"):
		var pending: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/environments/prepared-activity-staging.json"))
		_jobs = pending.keys()
	_full_frames = args.has("--full-frames")
	if args.size() > 2: _phase = float(args[2])
	if args.size() > 1:
		_jobs = _jobs.filter(func(key): return String(key).begins_with(args[1]))
	_next.call_deferred()

func _next() -> void:
	if _vp != null:
		_vp.free()
	if _jobs.is_empty():
		for city: String in _contacts:
			var entries: Array = _contacts[city]
			var contact := Image.create(1152, entries.size() * 324, false, Image.FORMAT_RGBA8)
			for i in range(entries.size()):
				contact.blit_rect(entries[i], Rect2i(0,0,1152,324),Vector2i(0,i*324))
			contact.save_png(_out.path_join("contact-" + city + ".png"))
		var file := FileAccess.open(_out.path_join("render-index.json"), FileAccess.WRITE)
		file.store_string(JSON.stringify(_report,"\t"))
		quit()
		return
	_key = String(_jobs.pop_front())
	_city = _key.split(":")[0]
	_region = _key.split(":")[1]
	var gs = root.get_node("GameState")
	gs.city = _city
	gs.current_region = _region
	gs.time_of_day = "morning"
	gs.money = 10000
	var ss = load("res://scenes/world/Streetside.gd")
	_shots = []
	var unique: Dictionary = {}
	for params in [[-1,false,0],[-1,false,1],[-1,true,0],[0,false,0]]:
		for shot: Dictionary in ss.reel(_city,_region,params[0],params[1],params[2])["shots"]:
			var signature: String = JSON.stringify(shot)
			if not unique.has(signature):
				unique[signature]=true
				_shots.append(shot)
	var data: Dictionary = ss.spot(_city,_region)
	for beat: Dictionary in data.get("beats",{}).values():
		if beat.has("staging"):
			var directed: Dictionary = beat["staging"].duplicate(true)
			directed["say"] = beat.get("text","")
			directed["secs"] = 4.0
			var directed_signature: String = JSON.stringify(directed)
			if not unique.has(directed_signature):
				unique[directed_signature] = true
				_shots.append(directed)
		for shot: Dictionary in beat.get("film",[]):
			var signature: String = JSON.stringify(shot)
			if not unique.has(signature):
				unique[signature]=true
				_shots.append(shot)
	_report[_key] = {"shots":_shots.size(),"title":data.get("title",_key),"file":_key.replace(":","-")+".png"}
	_sheet=Image.create(1152,int(ceil(_shots.size()/2.0))*324,false,Image.FORMAT_RGBA8)
	_index=0
	_vp=SubViewport.new()
	_vp.size=Vector2i(1152,648)
	_vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(_vp)
	_cut=CanvasLayer.new()
	_cut.set_script(load("res://scenes/ui/Cutscene.gd"))
	_vp.add_child(_cut)
	_cut.call("play",_city,_shots)
	paused=false
	_wait=6

func _process(_delta: float) -> bool:
	if _wait<=0:return false
	_wait-=1
	if _wait==3:
		_cut.set("_t",_phase)
		_cut.set("_object_elapsed",_phase)
		# Freeze the environment at the same instant as the actors; six render
		# frames otherwise falsely show a just-starting lid or water animation.
		var plate: Node2D = _cut.get("_plate")
		if plate != null and plate.get("_clock") != null:
			plate.set("_clock",_phase)
		var ages: Dictionary = _cut.get("_actor_elapsed")
		for actor: int in ages: ages[actor] = _phase
	if _wait>0:return false
	var image: Image=_vp.get_texture().get_image()
	if _full_frames:
		image.save_png(_out.path_join(_key.replace(":","-")+"-%02d.png" % _index))
	image.resize(576,324,Image.INTERPOLATE_NEAREST)
	_sheet.blit_rect(image,Rect2i(0,0,576,324),Vector2i((_index%2)*576,(_index/2)*324))
	_index+=1
	if _index>=_shots.size():
		_sheet.save_png(_out.path_join(_key.replace(":","-")+".png"))
		var contact := _sheet.get_region(Rect2i(0,0,1152,324))
		if not _contacts.has(_city):_contacts[_city]=[]
		_contacts[_city].append(contact)
		print("ACTIVITY ",_key," ",_shots.size()," unique shots")
		_next.call_deferred()
	else:
		_cut.call("_advance")
		_wait=6
	return false
