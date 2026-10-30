extends CanvasLayer

# The cutscene player, third attempt, and the first one that looks like the
# game - because it IS the game.
#
# The two previous versions drew their own stage: first flat boxes, then a
# perspective room. Both failed the same way. A bespoke stage means twenty
# cities share one look, none of them matches the street the player just
# walked in from, and every scrap of colour and character the plates have has
# to be invented again and worse.
#
# So a cutscene is now shot INSIDE the real plate. The city's own background
# script is instantiated into a viewport, set to the district the player is
# standing in, and the camera pushes into it. Mitte's Altbau and Fernsehturm,
# Waikiki's hotel wall and crater, Carsi's awnings and Galata - the actual
# art, the actual palette. Twenty cities look like twenty cities for nothing,
# and anything I fix on a street is fixed in its cutscenes too.
#
# Over the top: the people, drawn in the same flat language the street NPCs
# use, and the alien's narration underneath. Nothing advances on a timer.

signal finished
var completed := false
var _festive := false               # a holiday reel with its festival music

const CA := preload("res://scenes/ui/CutsceneArt.gd")
const ENV := preload("res://scenes/world/EnvironmentDesign.gd")
const ENV_STREET := preload("res://scenes/world/EnvironmentStreet.gd")
const MOTION := preload("res://scenes/ui/ActivityMotion.gd")
const OBJECTS := preload("res://scenes/ui/ActivityObjects.gd")
const SETS := preload("res://scenes/ui/ActivitySets.gd")
const LANDMARKS := preload("res://scenes/ui/ActivityLandmarks.gd")
const CELEBRATIONS := preload("res://scenes/celebrations/Celebrations.gd")

const BAR_H := 88.0           # letterbox
const FADE  := 0.30

# Two kinds of line, and they should not look alike. A description is what is
# in front of him; an action line is him doing something about it. Told in one
# colour they read as an undifferentiated wall of narration and the player
# cannot see where a decision happened. The gold is the alien's own accent
# colour, out of art/player/alien.gpl.
const SUB_SEE := Color(0.941, 0.922, 0.996)
const SUB_ACT := Color(0.933, 0.808, 0.549)

# The shortest gap that stops one keypress advancing two shots. It is NOT a
# reading lock: the reel used to swallow every click for up to 2.6 seconds,
# so pressing E did nothing at all and gave no sign why.
const GUARD := 0.22

# Which script draws each city, for the cities whose plate is not simply
# <Name>Background.
const PLATE_OVERRIDE := {
	# Districts with a plate of their own come first: Karakoy is a quay,
	# Docklands is a viaduct and Kiez is the field he came down in, and
	# all three were being shot on their city's ordinary street.
	"istanbul:karakoy": "IstanbulKarakoyBackground",
	"london:docklands": "LondonDocklandsBackground",
	"berlin:kiez":      "WreckageBackground",
	"london":   "LondonStreetBackground",
	"istanbul": "IstanbulStreetBackground",
}

# Where a plate is worth looking at when a shot does not say: [across, zoom].
# `across` is a fraction of the plate's width.
# [across, how much of the plate's HEIGHT is in frame, in plate pixels].
# Framing by zoom was wrong: the frame is letterboxed to about 2.1:1 at
# the game's own resolution and the crop window's height falls out of its
# width, so the same zoom showed a third of a frame of empty road at
# 1920x1080 and a tight two-shot in a 1152 viewport.
const DEFAULT_CAM := [[0.44, 360.0], [0.62, 250.0], [0.32, 320.0], [0.68, 224.0]]

# Where the camera looks in a district that has a landmark, as a fraction of
# the plate's width. Taken from the x each plate actually draws the thing at:
# without this the camera pointed wherever DEFAULT_CAM said and shot the
# Gateway of India from a corner of frame while filling the middle with a
# blank wall. A city gets a bare entry too, used by its arrival district.
const FOCUS := {
	"paris:champdemars": 0.61, "paris:montmartre": 0.48,
	"paris:ladefense":   0.50, "paris":            0.61,
	"sydney:circularquay": 0.64, "sydney:cbd":     0.28,
	"sydney:cabramatta": 0.50, "sydney":           0.64,
	"honolulu:waikiki":  0.80, "honolulu":         0.80,
	"toronto:downtown":  0.45, "toronto":          0.45,
	"tokyo:asakusa":     0.52,
	"lapaz":             0.47,
	"berlin:mitte":      0.74, "berlin:ost":       0.28,
	"berlin:prenzlberg": 0.62, "berlin":           0.74,
	"dakar:ouakam":      0.64,
	"istanbul:beyoglu":  0.54, "istanbul:carsi":   0.42,
	"istanbul:karakoy":  0.87,
	"mexico:juarez":     0.73,
	"moscow:kitaygorod": 0.60,
	"mumbai:colaba":     0.66,
	"newyork:midtown":   0.47, "newyork":          0.47,
	"rome:monti":        0.55,
	"saopaulo:paulista": 0.49,
	"tbilisi:avlabari":  0.70,
	"zurich:niederdorf": 0.64, "zurich":           0.64,
	"london:soho":       0.77, "london:highstreet": 0.72,
	"london:terrace":    0.72,
	"london":            0.72,
	"hanoi:tayho":       0.28,
	"seoul:jongno":      0.49,
	"mumbai:bhuleshwar": 0.42, "mumbai:byculla":   0.45,
	"mumbai":            0.42,
	"moscow":            0.60, "istanbul":         0.20,
}

# So consecutive shots in one reel are not the same photograph twice.
const DRIFT := [0.0, 0.10, -0.09, 0.05]

# A landmark district gets more of the plate's height. The tight default cut
# the top off the Grossmunster's towers, Gwanghwamun's roof and Sameba's
# cone - the plate has only 292 pixels of sky above the shopfronts and a
# tight frame throws half of it away.
const LOOK_HEIGHT := [430.0, 296.0, 386.0, 258.0]

var _shots: Array = []
var _cast_appearance: Dictionary = {}
var _actor_elapsed: Dictionary = {}
var _actor_actions: Dictionary = {}
var _object_elapsed: float = 0.0
var _object_action: String = ""
var _at: int = -1
var _t: float = 0.0
var _clock: float = 0.0
var _hold: float = 0.9
var _city: String = "berlin"
var _district: String = ""
var _open: bool = false
var _cast_seed: int = 0

var _stage: SubViewport
var _plate: Node2D
var _plate_key: String = ""

var _root: Control
var _canvas: Control
var _sub: Label
var _hint: Label
var _venue: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 13
	add_to_group("cutscene")
	_build_ui()
	_venue = Label.new()
	_venue.anchor_right = 1.0
	_venue.offset_top = 5.0
	_venue.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_venue.add_theme_font_size_override("font_size", 18)
	_venue.add_theme_color_override("font_color", Color("e4cc94"))
	_venue.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_venue)
	_root.hide()


# `festive` is for the holiday reels: the city's festival music plays under
# them (AudioManager.festival) and the street's music returns when they end.
func play(city: String, shots: Array, festive: bool = false) -> void:
	completed = false
	if _root == null:
		_build_ui()
		_root.hide()
	if _open or shots.is_empty():
		finished.emit()
		return
	_festive = festive and AudioManager.festival(city)
	_city = city
	_district = GameState.current_region
	_cast_seed = int(abs(hash(city + _district))) % 97
	_shots = CELEBRATIONS.stage(city, shots) if festive else shots
	_cast_appearance.clear()
	_actor_elapsed.clear()
	_actor_actions.clear()
	_object_elapsed = 0.0
	_object_action = ""
	_clock = 0.0
	for shot: Dictionary in _shots:
		var cast: Array = shot.get("cast", [])
		for i in range(cast.size()):
			if cast[i].has("appearance") and not _cast_appearance.has(i):
				_cast_appearance[i] = cast[i]["appearance"].duplicate(true)
	_at = -1
	_open = true
	_root.show()
	get_tree().paused = true
	_advance()


# Build the plate once per encounter: the city's own background node, set to
# the district the player is actually standing in.
func _ensure_plate(scene_override: String = "") -> void:
	if scene_override.begins_with("celebration:"):
		if _plate != null and _plate_key == scene_override: return
		if _plate != null: _plate.queue_free()
		_plate = load(CELEBRATIONS.scene_path(scene_override.trim_prefix("celebration:"))).instantiate()
		_stage.add_child(_plate)
		_plate_key = scene_override
		return
	var designed: String = scene_override if not scene_override.is_empty() else ENV.district_scene(_city, _district)
	if not designed.is_empty():
		var design_key: String = "design:" + designed
		if _plate != null and _plate_key == design_key:
			return
		if _plate != null:
			_plate.queue_free()
		_plate = Node2D.new()
		_plate.set_script(ENV_STREET)
		_plate.set("scene_id", designed)
		_plate.set("district", _district)
		_plate.set("staging_only", true)
		_stage.add_child(_plate)
		_plate_key = design_key
		return
	var name: String = String(PLATE_OVERRIDE.get(_city + ":" + _district,
		PLATE_OVERRIDE.get(_city, "")))
	if name.is_empty():
		name = _city.substr(0, 1).to_upper() + _city.substr(1) + "Background"
		# saopaulo -> SaoPaulo, lapaz -> LaPaz, newyork -> NewYork.
		match _city:
			"saopaulo": name = "SaoPauloBackground"
			"lapaz":    name = "LaPazBackground"
			"newyork":  name = "NewYorkBackground"
	var key: String = name + ":" + _district
	if _plate != null and _plate_key == key:
		return
	if _plate != null:
		_plate.queue_free()
		_plate = null
	var path: String = "res://scenes/world/" + name + ".gd"
	if not ResourceLoader.exists(path):
		return
	var scr: Script = load(path)
	if scr == null:
		return
	_plate = Node2D.new()
	_plate.set_script(scr)
	if _district != "" and "district" in _plate:
		_plate.district = _district
	_stage.add_child(_plate)
	_plate_key = key


func _advance() -> void:
	_at += 1
	_t = 0.0
	if _at >= _shots.size():
		completed = true
		_close()
		return
	var shot: Dictionary = _shots[_at]
	if _venue != null: _venue.text = String(shot.get("venue", ""))
	var object_key: String = String(shot.get("object", "")) + String(shot.get("bg_scene", ""))
	if object_key != _object_action:
		_object_elapsed = 0.0
	_object_action = object_key
	var cast: Array = shot.get("cast", [])
	for actor: int in _actor_actions.keys():
		if actor >= cast.size():
			_actor_actions.erase(actor)
			_actor_elapsed.erase(actor)
	for i in range(cast.size()):
		var identity: String = JSON.stringify(cast[i].get("appearance", {}))
		var action_key: String = String(shot.get("bg_scene", "")) + ":" + String(cast[i].get("act", "stand")) + identity + JSON.stringify(cast[i].get("motion_path", {}))
		if _actor_actions.get(i, "") != action_key or bool(cast[i].get("restart_action", false)):
			_actor_elapsed[i] = 0.0
		_actor_actions[i] = action_key
	_ensure_plate(String(shot.get("bg_scene", "")))
	var line: String = String(shot.get("say", ""))
	_sub.text = line
	# A shot can carry the one sentence somebody in it actually says, in their
	# own voice: [voice, the words]. The narration stays his and stays silent.
	var voiced: Array = shot.get("voice", [])
	if voiced.size() == 2:
		AudioManager.say(String(voiced[0]), String(voiced[1]))
	# Streetside.reel() marks the shots that are him acting rather than him
	# looking. Gold and a shade smaller, so a decision is visibly a decision.
	var acted: bool = bool(shot.get("act", false))
	_sub.add_theme_color_override("font_color", SUB_ACT if acted else SUB_SEE)
	_sub.add_theme_font_size_override("font_size", 27 if acted else 30)
	_layout_caption.call_deferred()
	# A longer line waits longer before the prompt appears. This is a reading
	# estimate for the prompt only - it does not hold the player back.
	_hold = clampf(0.7 + float(line.length()) * 0.010, 0.9, 2.6)
	_canvas.queue_redraw()

func _layout_caption() -> void:
	# The caption owns the space it actually needs, including the hint below.
	# Fixed 88px bars clipped long activity lines at the native resolution.
	_sub.offset_left = 48.0
	_sub.offset_right = -48.0
	_sub.offset_bottom = -28.0
	# Reserve one caption area for the entire reel. Resizing the picture for
	# every sentence shifts the camera and the ground between otherwise still shots.
	var needed: float = 100.0
	var font: Font = _sub.get_theme_font("font")
	for shot: Dictionary in _shots:
		var size: Vector2 = font.get_multiline_string_size(String(shot.get("say", "")),
			HORIZONTAL_ALIGNMENT_CENTER,maxf(100.0,_root.size.x-96.0),30)
		needed = maxf(needed,size.y+58.0)
	_sub.offset_top = -needed
	_canvas.offset_bottom = -needed
	_canvas.offset_top = 34.0


func _close() -> void:
	if not _open:
		return
	_open = false
	_root.hide()
	get_tree().paused = false
	if _festive:
		_festive = false
		AudioManager.end_festival()
	finished.emit()


func _process(delta: float) -> void:
	if not _open:
		return
	_t += delta
	_clock += delta
	_object_elapsed += delta
	for actor: int in _actor_elapsed:
		_actor_elapsed[actor] += delta
	if _hint != null:
		_hint.modulate.a = clampf((_t - _hold) * 2.2, 0.0, 1.0)
	_canvas.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not _open:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()
		return
	var go: bool = event.is_action_pressed("ui_accept") \
		or event.is_action_pressed("interact")
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		go = go or (mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT)
	if go:
		get_viewport().set_input_as_handled()
		if _t >= GUARD:
			_advance()


# ── Drawing ───────────────────────────────────────────────────────────────────

# Where each person stands in depth when the shot does not say. Nearest first,
# because the first entry in the cast is always the alien.
const DEPTH := [0.78, 0.64, 0.42, 0.28, 0.18]


func _draw_shot() -> void:
	if _at < 0 or _at >= _shots.size():
		return
	var shot: Dictionary = _shots[_at]
	var w: float = _canvas.size.x
	var h: float = _canvas.size.y
	var full_plate: bool = bool(shot.get("full_plate",false))
	var picture_left: float = 0.0
	if full_plate:
		w = minf(w,h*1152.0/648.0)
		picture_left = (_canvas.size.x-w)*0.5
		_canvas.draw_rect(Rect2(Vector2.ZERO,_canvas.size),Color(0.02,0.02,0.05))
	var p: Array = CA.pal(_city)

	# The plate, framed. The camera crops a window out of the 1152x648 street
	# and blows it up to fill the frame, which is the whole of the "cutscene"
	# treatment - the art underneath is exactly what the player walked in from.
	var cam: Array = shot.get("cam", DEFAULT_CAM[0])
	var across: float = float(cam[0])
	var look_h: float = maxf(float(cam[1]), 120.0)
	var on_landmark: bool = false
	# What the shot is standing in. Every film in the game has always said
	# so and for a long time nothing read it, which is why a line about
	# lying on the grass played over a pavement.
	var set_name: String = String(shot.get("set", "street"))
	# The ground and the camera key off the first named set; a compound
	# like "field+stall" is grass with a trestle standing on it, and the
	# grass is what anybody is standing on.
	var set_base: String = set_name.split("+")[0].split("/")[0]
	if not shot.has("cam"):
		var look: float = float(FOCUS.get(_city + ":" + _district,
			FOCUS.get(_city, -1.0)))
		if look > 0.0:
			across = clampf(look,
				0.10, 0.90)
			look_h = maxf(look_h,
				float(LOOK_HEIGHT[0]))
			on_landmark = true
	# The actors and objects are composed in frame space. Keep this camera
	# locked; pushing only the background makes their feet slide on the set.
	# Craning up: the window has to be short enough that the pavement
	# falls out of the bottom of it, or the anchor below just clamps to
	# zero and the shot is the same shot with a taller sky.
	if set_base == "tower":
		look_h = minf(look_h, 300.0)
	# The window's width falls out of its height and the FRAME's aspect, so
	# the picture is never stretched and the framing is the same whatever
	# resolution the game is running at.
	var sh: float = minf(look_h, 648.0)
	var sw: float = sh * (w / maxf(h, 1.0))
	if sw > 1152.0:
		sw = 1152.0
		sh = sw * (h / maxf(w, 1.0))
	var sx: float = clampf(across * 1152.0 - sw * 0.5, 0.0, 1152.0 - sw)
	# Framed low: the street matters more than the sky in a shot about
	# people. A "tower" shot is the exception - it is a shot about the
	# thing not ending, so the camera goes up and the ground goes out of
	# frame the way it does when you actually crane your neck.
	var anchor: float = 1.34 if set_base == "tower" else 0.92
	var floor_line: float = 292.0
	if _plate != null and _plate.has_method("floor_y"):
		floor_line = float(_plate.call("floor_y"))
	var front_line: float = floor_line + 94.0
	var sy: float = clampf(front_line - sh * anchor, 0.0, 648.0 - sh)
	if shot.has("cam_y"):
		# A ground-level activity can sit below the normal sidewalk framing.
		sy = clampf(float(shot["cam_y"]) - sh * 0.5, 0.0, 648.0 - sh)
	if full_plate:
		sw=1152.0
		sh=648.0
		sx=0.0
		sy=0.0
	if _stage != null:
		var tex: Texture2D = _stage.get_texture()
		if tex != null:
			_canvas.draw_texture_rect_region(tex, Rect2(picture_left, 0.0, w, h),
				Rect2(sx * 2.0, sy * 2.0, sw * 2.0, sh * 2.0))

	var scale: float = (w / sw)
	# The set goes over the plate and under the people: the city keeps its
	# roofline, its landmark and its light, and the ground under the cast
	# becomes whatever the sentence says it is.
	var pave_y: float = (floor_line - sy) * scale
	var road_y: float = (front_line - sy) * scale
	var ground_far: float = (floor_line + 10.0 - sy) * scale
	var ground_near: float = (floor_line + 76.0 - sy) * scale
	match set_base:
		"interior":
			ground_far = h * 0.76
			ground_near = h * 0.96
		"shop", "counter":
			ground_far = h * 0.70
			ground_near = h * 0.90
		"tower":
			# Craning up, so they are at the very bottom of frame.
			ground_far = h * 0.90
			ground_near = h * 1.02
		"station", "platform":
			ground_far = lerpf(pave_y, h, 0.56)
			ground_near = lerpf(pave_y, h, 0.86)
		"water":
			ground_far = lerpf(pave_y, h, 0.60)
			ground_near = lerpf(pave_y, h, 0.88)
		"beach", "park", "field", "courtyard", "steps":
			ground_far = lerpf(pave_y, h, 0.34)
			ground_near = lerpf(pave_y, h, 0.80)
	# Where the camera is looking, 0 to 1 across the plate. An indoor set
	# covers the frame and so cannot be cropped by the camera - it has to
	# be told where to look, or seven shots in one shop are seven copies
	# of one drawing.
	var pan: float = sx / maxf(1152.0 - sw, 1.0)
	var direction: Dictionary = OBJECTS.profile(_city, _district)
	var object: String = String(shot.get("object", direction.get("object", "")))
	var activity_time: float = _object_elapsed if SaveManager.motion() > 0.5 else 1.2
	var landmark: bool = false
	if not bool(shot.get("authored_plate",false)) and (set_base not in ["shop","counter","interior"] or (_city == "tbilisi" and _district == "avlabari" and set_base == "interior")):
		landmark = LANDMARKS.draw(_canvas,_city+":"+_district,set_name,w,h,activity_time,GameState.is_morning())
	if landmark:
		var ground: Array = LANDMARKS.record(_city+":"+_district,set_name)["ground"]
		ground_far = h * float(ground[0])
		ground_near = h * float(ground[1])
		on_landmark = false
	var transport: bool = object in ["tram","train","ferry","cablecar"]
	var foreground_object: Dictionary = {}
	if not landmark and (set_base in ["shop", "counter"] or (set_base == "interior" and not transport)):
		SETS.room(_canvas,w,h,_city,object,_stage.get_texture(),activity_time,GameState.is_morning())
	elif set_base == "gate" and not landmark:
		SETS.gate(_canvas,w,h,_city,_district)
	elif not landmark and set_base not in ["tram","station","platform","market","stall","courtyard"]:
		CA.stage(_canvas, set_name, w, h, ground_far, ground_near, scale,
			_city, _clock, GameState.is_morning(), pan)
	var landmark_object: bool = landmark and not (_city == "hanoi" and _district == "badinh" and set_name != "pagoda")
	var authored_ground: Array = shot.get("ground", [])
	if authored_ground.size() == 2:
		ground_far = h * float(authored_ground[0])
		ground_near = h * float(authored_ground[1])
	if not object.is_empty() and not landmark_object and not (set_base == "interior" and transport):
		var object_x: float = 0.51
		if transport:
			object_x = lerpf(-0.32,0.72,MOTION.phase_curve(activity_time/3.4))
		var object_y: float = lerpf(ground_far, ground_near, 0.68)
		var object_at: Array = shot.get("object_at", [])
		if object_at.size() == 2:
			object_x = float(object_at[0])
			object_y = h * float(object_at[1])
		if _plate != null and _plate.get("design") is Dictionary:
			var floor_max: float = float(_plate.get("design").get("activity_floor_max", 9999.0))
			object_y = minf(object_y,(floor_max-sy)*scale)
		var journey: Array = shot.get("object_motion", [])
		if journey.size() == 3:
			object_x = lerpf(float(journey[0]),float(journey[1]),MOTION.phase_curve(activity_time/float(journey[2])))
		var object_unit: float = float(shot.get("object_unit", maxf(2.0, roundf(h / (64.0 if transport else 105.0)))))
		var object_position := Vector2(w * object_x, object_y)
		var object_world: Array = shot.get("object_world_at", [])
		if object_world.size() == 2:
			object_position = (Vector2(object_world[0],object_world[1])-Vector2(sx,sy))*scale+Vector2(picture_left,0)
			object_unit = float(shot.get("object_world_unit", 1.5))*scale
		if bool(shot.get("object_foreground",false)):
			foreground_object = {"at":object_position,"unit":object_unit}
		else:
			OBJECTS.draw(_canvas, object, object_position, object_unit,
				float(shot.get("object_time", activity_time)), _city)

	# Everyone in the shot, far to near so the near ones overlap.
	var cast: Array = shot.get("cast", [])
	var swimming: bool = cast.any(func(who: Dictionary): return String(who.get("act", "")) == "swim")
	var plate_swimming: bool = swimming and bool(shot.get("plate_swimming",false))
	if swimming and not plate_swimming:
		_draw_swimming_water(w,h,activity_time,false)
	var order: Array = []
	var staged: Dictionary = {}
	for i in range(cast.size()):
		var who: Dictionary = cast[i]
		order.append({
			"z": float(who.get("z", DEPTH[mini(i, DEPTH.size() - 1)])),
			"i": i, "at": float(who.get("at", 0.5)),
			"act": String(who.get("act", "stand")),
		})
	order.sort_custom(func(a, b): return float(a["z"]) < float(b["z"]))
	for it: Dictionary in order:
		var z: float = float(it["z"])
		var person: Dictionary = cast[int(it["i"])]
		# Staged in the FRAME, not in the plate. A person placed at a plate
		# fraction falls out of shot the moment the camera moves, and a person
		# scaled by the zoom shrinks when the camera pulls back - which is
		# backwards. Their feet still land on the plate's pavement.
		var at: float = float(it["at"])
		# The camera is pointed at the landmark, so the middle of frame is
		# the one place nobody should stand: the first pass put the alien
		# squarely in front of the Angel and the stupa.
		if swimming and not plate_swimming:
			# Keep a clear silhouette for each swimmer and the shore observer.
			at = lerpf(0.10, 0.90, float(it["i"]) / maxf(cast.size() - 1, 1))
		elif on_landmark and not shot.has("ground"):
			var side: float = -1.0 if at < 0.5 else 1.0
			at = 0.5 + side * clampf(absf(at - 0.5) + 0.20, 0.22, 0.44)
		var fx: float = lerp(w * 0.12, w * 0.88, at)
		var world_at: Array = person.get("world_at", [])
		if world_at.size() == 2:
			fx = (float(world_at[0])-sx)*scale
		fx += picture_left
		var actor_time: float = float(_actor_elapsed.get(int(it["i"]), _t))
		var action: Dictionary = MOTION.sample(String(it["act"]), actor_time,
			int(it["i"]), SaveManager.motion() < 0.5)
		var route: Dictionary = person.get("motion_path", {})
		if not route.is_empty() and world_at.size() == 2:
			var end: Array = route["to"]
			var progress: float = 1.0 if SaveManager.motion() < 0.5 else MOTION.phase_curve(
				(actor_time-float(route.get("delay",0.0)))/maxf(float(route.get("secs",2.8)),0.01))
			world_at = [lerpf(world_at[0],end[0],progress),lerpf(world_at[1],end[1],progress)]
			fx = (float(world_at[0])-sx)*scale+picture_left
			action["x"] = 0.0
			action["y"] = 0.0
			action["progress"] = progress
			var route_pose: String = String(route.get("pose","walk"))
			action["pose"] = ("reach" if int(actor_time*3.5)%2 == 0 else "interact") if route_pose == "climb" else route_pose
			if progress >= 1.0: action["pose"] = "stand"
		fx += float(action["x"]) * w
		# Feet on whatever is underfoot. Indoors and on a platform the
		# floor is not where the street's pavement was.
		var fy: float = lerp(ground_far, ground_near, z)
		if person.has("feet_y"):
			fy = h * float(person["feet_y"])
		if world_at.size() == 2:
			fy = (float(world_at[1])-sy)*scale
		fy += float(action["y"]) * h
		if _plate != null and _plate.get("design") is Dictionary:
			var floor_max: float = float(_plate.get("design").get("activity_floor_max", 9999.0))
			fy = minf(fy,(floor_max-sy)*scale)
		# Half of one of these figures is head, so the same height fills far
		# more of the frame than the old long-legged ones did.
		var fh: float = h * lerp(0.27, 0.47, z)
		if person.has("world_height"):
			fh = float(person["world_height"])*scale
		if String(it["act"]) == "swim" and plate_swimming:
			# This shot already has a lake. The authored world position is the
			# swimmer's waterline; only the submerged sprite rows are clipped.
			fy = (float(world_at[1])-sy)*scale + sin(activity_time*2.2+int(it["i"]))*scale
			fy += (24.0-float(person.get("clip_row",16))) * fh/22.0
		elif String(it["act"]) == "swim":
			fy = h * 0.80 + fh * 0.22 + sin(activity_time * 2.2 + int(it["i"])) * h * 0.005
		elif swimming and not plate_swimming:
			fy = h * 0.65
		var seated: bool = bool(person.get("seated", false)) or String(action["pose"]) == "sit"
		if seated and bool(person.get("seat", true)) and String(it["act"]) != "swim" and set_base != "interior":
			OBJECTS.seat(_canvas, Vector2(fx, fy), fh / 22.0, _city)
		staged[int(it["i"])] = {"feet": Vector2(fx, fy), "unit": fh / 22.0,
			"act": String(it["act"])}
		# Seeded by position in the cast and by the city, NOT by the shot
		# index: with _at in the seed the man you were buying from changed
		# clothes between handing it over and taking the money.
		# A CityNPC is 68 pixels tall on the street, and that is what a
		# scale of 1.0 means to CutsceneArt now.
		CA.person(_canvas, fx, fy, fh / 68.0,
			String(action["pose"]), p, actor_time, int(it["i"]) == 0,
			int(it["i"]) * 7 + _cast_seed, _city,
			person.get("appearance", _cast_appearance.get(int(it["i"]), {})),
			seated, int(person.get("clip_row", 99)))
		if plate_swimming and String(it["act"]) == "swim":
			var water_y: float = fy-(24.0-float(person.get("clip_row",16)))*fh/22.0
			for side in [-1.0,1.0]:
				var ripple := Vector2(fx+side*fh*.24,water_y+scale)
				_canvas.draw_rect(Rect2(ripple.round(),Vector2(fh*.15,scale)),Color(.65,.85,.86,.65))
		var kit: String = String(cast[int(it["i"])].get("kit", ""))
		if not kit.is_empty():
			var carried_motion: float = 1.0
			if kit in ["shoulder_pole", "dog_pack", "dog_pack_look"]:
				# Basket swing settles with the last step instead of continuing
				# indefinitely while the player reads a stationary conversation.
				carried_motion = clampf((1.0-float(action["progress"]))*5.0,0.0,1.0) if String(it["act"]) in ["walk","carry","haul"] else 0.0
			OBJECTS.carried(_canvas, kit, Vector2(fx,fy), fh / 22.0, activity_time, carried_motion)
		_draw_authored_occlusion(Vector2(fx,fy),fh,Vector2(sx,sy),scale,picture_left)
	if not foreground_object.is_empty():
		OBJECTS.draw(_canvas,object,foreground_object["at"],foreground_object["unit"],
			float(shot.get("object_time",activity_time)),_city)
	if swimming and not plate_swimming:
		_draw_swimming_water(w,h,activity_time,true)
	_draw_activity_prop(shot, staged, w, h, ground_far, scale, Vector2(sx,sy), picture_left)
	CA.grade(_canvas, _canvas.size.x, h, p, _clock)
	if _t < FADE:
		_canvas.draw_rect(Rect2(0.0, 0.0, _canvas.size.x, h),
			Color(0.02, 0.02, 0.05, 1.0 - _t / FADE))

func _draw_authored_occlusion(feet: Vector2, height: float, camera: Vector2,
		scale: float, picture_left: float) -> void:
	if _plate == null or not (_plate.get("design") is Dictionary): return
	var occluders: Array = _plate.get("design").get("activity_occluders",[])
	if occluders.is_empty(): return
	# Sample only the furniture's actual silhouette from the rendered plate.
	# Clipping to this actor avoids repainting unrelated cast members or floor.
	var actor_rect := Rect2(feet-Vector2(height*.75,height*1.4),Vector2(height*1.5,height*1.5))
	var bounds := PackedVector2Array([actor_rect.position,
		Vector2(actor_rect.end.x,actor_rect.position.y),actor_rect.end,
		Vector2(actor_rect.position.x,actor_rect.end.y)])
	for object: Dictionary in occluders:
		if feet.y >= (float(object["sort_y"])-camera.y)*scale: continue
		for values: Array in object.get("polygons",[]):
			var screen := PackedVector2Array()
			for xy: Array in values:
				screen.append((Vector2(xy[0],xy[1])-camera)*scale+Vector2(picture_left,0))
			for piece: PackedVector2Array in Geometry2D.intersect_polygons(screen,bounds):
				var uv := PackedVector2Array()
				for p: Vector2 in piece:
					uv.append(((p-Vector2(picture_left,0))/scale+camera)/Vector2(1152,648))
				_canvas.draw_polygon(piece,PackedColorArray([Color.WHITE]),uv,_stage.get_texture())

func _draw_swimming_water(w: float, h: float, t: float, foreground: bool) -> void:
	# A continuous shared water surface, with the cast's lower bodies beneath it.
	# Per-character blue rectangles looked like boxes sitting on the beach.
	var top: float = h * (0.80 if foreground else 0.68)
	var deep := Color8(52, 115, 131) if GameState.is_morning() else Color8(28, 57, 80)
	_canvas.draw_rect(Rect2(0,top,w,h-top),deep)
	for i in range(30):
		var y: float = top + float(i%6)*(h-top)/6.0 + sin(t*1.1+i)*2
		var x: float = fposmod(float(i)*167+t*12,w)
		_canvas.draw_rect(Rect2(x,y,w*(0.025+float(i%4)*0.01),2),Color(.64,.84,.83,.28))
	if foreground:
		for i in range(18):
			var x: float = float(i)*w/18
			_canvas.draw_rect(Rect2(x,top+sin(t*1.4+i*.8)*2,w/18+1,3),Color(.58,.79,.79,.55))


func _draw_activity_prop(shot: Dictionary, staged: Dictionary, w: float,
		h: float, ground: float, scale: float, camera_origin: Vector2, picture_left: float) -> void:
	var kind: String = String(shot.get("prop", ""))
	if kind in ["board", "door", "curtain", "flag"]:
		return # Built into the working set; a duplicate would cover the cast.
	if _city == "hanoi" and _district == "phoco" and String(shot.get("say", "")).contains("empty glasses"):
		kind = "glass"
	if kind.is_empty():
		return
	if kind in ["nail", "board", "lantern", "flag", "smoke", "rope", "door", "curtain"]:
		var prop_scale: float = scale * float(shot.get("prop_scale", 1.0))
		var prop_ground: float = ground
		if kind == "nail" and shot.has("prop_y"):
			prop_ground = h * float(shot["prop_y"]) + 118.0 * prop_scale
		CA.prop(_canvas, kind, w * float(shot.get("prop_at", 0.5)), prop_ground,
			w, h, prop_scale, GameState.is_morning(), _clock)
		return
	if staged.is_empty():
		return
	if kind == "hauling_rope":
		var origin: Array = shot.get("prop_world_from", [])
		if origin.size() != 2: return
		var points := PackedVector2Array([(Vector2(origin[0],origin[1])-camera_origin)*scale+Vector2(picture_left,0)])
		for index: int in shot.get("prop_holders", []):
			if staged.has(index):
				points.append((staged[index]["feet"]+Vector2(-4,-8)*float(staged[index]["unit"])).round())
		if points.size()>1:
			_canvas.draw_polyline(points,Color8(67,47,27),3.0*scale)
			_canvas.draw_polyline(points,Color8(197,160,89),1.0*scale)
		return
	if kind == "shared_crate":
		var holders: Array = shot.get("prop_holders", [0,1])
		if holders.size()!=2 or not staged.has(int(holders[0])) or not staged.has(int(holders[1])): return
		var left: Dictionary = staged[int(holders[0])]
		var right: Dictionary = staged[int(holders[1])]
		var u: float = minf(float(left["unit"]),float(right["unit"]))
		var a: Vector2 = left["feet"]+Vector2(6,-8)*float(left["unit"])
		var b: Vector2 = right["feet"]+Vector2(-6,-8)*float(right["unit"])
		var y: float = (a.y+b.y)*.5
		var box := Rect2(Vector2(a.x,y-2*u).round(),Vector2(maxf(b.x-a.x,3*u),8*u))
		_canvas.draw_rect(box,Color8(103,67,39))
		for row in [0,3,6]:
			_canvas.draw_rect(Rect2(box.position+Vector2(0,row*u),Vector2(box.size.x,u)),Color8(170,119,64))
		_canvas.draw_rect(Rect2(box.position,Vector2(u,box.size.y)),Color8(206,155,88))
		_canvas.draw_rect(Rect2(box.position+Vector2(box.size.x-u,0),Vector2(u,box.size.y)),Color8(206,155,88))
		return
	var holder: int = 0
	var giver: int = -1
	var taker: int = -1
	for i: int in staged:
		var act: String = String(staged[i]["act"])
		if act in ["offer", "hand_over"]:
			giver = i
		if act in ["take", "reach"]:
			taker = i
		if act in ["drink", "eat", "cut", "count", "offer", "hand_over"]:
			holder = i
	if shot.has("prop_holder"):
		holder = clampi(int(shot["prop_holder"]), 0, staged.size() - 1)
	var feet: Vector2 = staged[holder]["feet"]
	var unit: float = float(staged[holder]["unit"])
	var action_time: float = float(_actor_elapsed.get(holder, _t))
	var point: Vector2 = feet + Vector2(4, -8) * unit
	if giver >= 0 and taker >= 0 and not shot.has("prop_holder"):
		var a: Vector2 = staged[giver]["feet"] + Vector2(-4, -8) * float(staged[giver]["unit"])
		var b: Vector2 = staged[taker]["feet"] + Vector2(4, -8) * float(staged[taker]["unit"])
		var progress: float = 1.0 if SaveManager.motion() < 0.5 else MOTION.phase_curve((action_time - 0.55) / 1.05)
		point = a.lerp(b, progress)
		unit = lerpf(float(staged[giver]["unit"]), float(staged[taker]["unit"]), progress)
	elif String(staged[holder]["act"]) in ["drink", "eat"]:
		var raise: float = 1.0 if SaveManager.motion() < 0.5 else sin(clampf((action_time - 0.4) / 2.6, 0.0, 1.0) * PI)
		point.y -= raise * 4.0 * unit
	var delivery: Array = shot.get("prop_world_to", [])
	if delivery.size() == 2:
		# A tied fortune finishes on its actual rack, in world coordinates.
		# Camera changes therefore cannot leave the paper floating in midair.
		var destination := (Vector2(delivery[0],delivery[1])-camera_origin)*scale + Vector2(picture_left,0)
		var progress: float = 1.0 if SaveManager.motion() < 0.5 else MOTION.phase_curve((action_time-.65)/1.2)
		point = point.lerp(destination, progress)
		unit = lerpf(unit,float(shot.get("prop_end_unit",unit/scale))*scale,progress)
	if kind == "guitar":
		OBJECTS.handheld(_canvas,kind,point,unit,action_time)
		# A tiny pixel hand moves across the strings, not the whole body.
		var stroke: float = 0.0 if SaveManager.motion() < 0.5 else floorf(sin(action_time * 5.0) * 1.5)
		_canvas.draw_rect(Rect2((point + Vector2(-3,stroke) * unit).round(),
			Vector2(3,2) * unit),Color8(225,185,140))
		return
	# Prop dimensions use character units. Background zoom has no bearing on
	# the size of a cup, nor on where its owner's hands are.
	unit *= float(shot.get("handheld_scale",1.0))
	var k: float = unit * 0.25
	if kind in ["apple", "tomato", "bottle", "simit", "card", "bag", "loaf", "falafel", "kebab", "cheese", "churchkhela", "parcel", "spice_cone", "tower_charm", "portrait", "shoe", "badge", "scarf", "food_tray", "guitar", "jeon", "metal_part", "menchi", "book", "fortune_good", "fortune_bad", "camera", "microphone", "shrimp_fritter", "shrimp_wrap", "fruit_crate", "brass_thing", "wax_leg", "wax_candle", "grain_cup", "wax_cloth", "wood_crate", "bouquet", "wrapped_fish", "lei", "spray_can", "shave_ice", "potato_bag", "api", "cap", "tostada", "tostada_small", "bec", "arepa", "pastel", "mortadela", "banh_mi", "fruit_slice", "fabric_roll", "cider"]:
		OBJECTS.handheld(_canvas,kind,point,unit,action_time)
		return
	if kind == "glass" and _city != "istanbul":
		var glass := Rect2(point - Vector2(1.5, 0) * unit, Vector2(3, 4) * unit)
		_canvas.draw_rect(glass, Color8(142, 175, 149))
		_canvas.draw_rect(glass.grow(-unit * 0.45), Color8(191, 152, 65))
		_canvas.draw_rect(Rect2(glass.position, Vector2(glass.size.x, unit * 0.6)), Color8(225, 233, 212))
		return
	var prop_ground: float = point.y + 46.0 * k
	if kind == "coin":
		prop_ground += 12.0 * k
	CA.prop(_canvas, kind, point.x, prop_ground, w, h, k,
		GameState.is_morning(), _clock)


func _build_ui() -> void:
	_stage = SubViewport.new()
	_stage.size = Vector2i(2304, 1296)
	_stage.transparent_bg = false
	_stage.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_stage)
	_stage.canvas_transform = Transform2D(Vector2(2,0),Vector2(0,2),Vector2.ZERO)

	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	var back := ColorRect.new()
	back.color = Color(0.02, 0.02, 0.04, 1.0)
	back.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(back)

	_canvas = Control.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.offset_top = BAR_H
	_canvas.offset_bottom = -BAR_H
	_canvas.clip_contents = true
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.draw.connect(_draw_shot)
	_root.add_child(_canvas)

	_sub = Label.new()
	_sub.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_sub.offset_top = -BAR_H
	_sub.offset_left = 180.0
	_sub.offset_right = -180.0
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_sub.add_theme_color_override("font_color", Color(0.94, 0.92, 0.99))
	_sub.add_theme_font_size_override("font_size", 30)
	_sub.add_theme_constant_override("outline_size", 5)
	_sub.add_theme_color_override("font_outline_color",
		Color(0.02, 0.02, 0.05, 0.85))
	_sub.add_theme_constant_override("line_spacing", 6)
	_root.add_child(_sub)

	_hint = Label.new()
	_hint.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_hint.offset_left = -250.0
	_hint.offset_top = -24.0
	_hint.offset_right = -16.0
	_hint.offset_bottom = -6.0
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_hint.text = "E  or  click   ·   Esc  skip"
	_hint.add_theme_color_override("font_color", Color(0.54, 0.52, 0.70))
	_hint.add_theme_font_size_override("font_size", 13)
	_root.add_child(_hint)
