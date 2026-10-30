extends Node2D

# A thing in a scene that is being staged in the street: a crate of empties, a
# folding chair, a paper bag with bread rolls in it, a bench.
#
# Drawn from rectangles on the same grid as the people (CharacterArt), so the
# crate on the pavement, the crate in Kerstin's arms and the crate in his are
# one object at one size. A story prop that could not be picked up would be
# scenery; most of these can, because in this game helping somebody is a thing
# you do with your hands before it is a thing you can say.

signal picked(id: String)
signal pointed(id: String)

const CHAR := preload("res://scenes/npc/CharacterArt.gd")
const MATERIALS := preload("res://scenes/world/PropMaterials.gd")
# The ground line, in the node's own space - the same one the people stand on.
const FEET := Vector2(0.0, 22.0)
const REACH := 44.0

const INK := Color(0.05, 0.04, 0.09, 0.85)

var id: String = ""
var kind: String = "crate"
# Written on it, in the street's own hand: PFAND on a crate, DER NEUE on tape.
var label: String = ""
var carryable: bool = false
var pointable: bool = false
var _near: bool = false
var _prompt: Label
var _body: StaticBody2D
var _shape: CollisionShape2D
var _footprint_key: String = ""


func _ready() -> void:
	add_to_group("story_prop")
	_prompt = Label.new()
	_prompt.text = "[%s] Pick up" % _key()
	_prompt.position = Vector2(-34.0, -44.0)
	_prompt.add_theme_font_size_override("font_size", 12)
	_prompt.visible = false
	_prompt.z_index = 10
	add_child(_prompt)
	_body = StaticBody2D.new()
	_shape = CollisionShape2D.new()
	_body.add_child(_shape)
	add_child(_body)
	visibility_changed.connect(func():
		_body.set_collision_layer_value(1, visible))
	_update_footprint()


func _update_footprint() -> void:
	var unit: float = CHAR.world_unit(self)
	var key: String = kind + ":" + str(unit)
	if key == _footprint_key:
		return
	_footprint_key = key
	var width: float = 21.0 if kind == "bench" else 7.0
	if kind == "bag":
		width = 4.4
	elif kind == "tea_tray":
		width = 12.0
	elif kind == "parcel":
		width = 10.0
	elif kind == "notice":
		width = 12.0
	elif kind == "bread_basket":
		width = 11.0
	elif kind == "meal_table":
		width = 24.0
	elif kind in ["brooch_old", "brooch_new", "blini_plain", "blini_jam", "phone_stand", "stage_sketch"]:
		width = 12.0
	elif kind in ["cup_slim", "cup_wide", "wish_papers"]:
		width = 12.0
	elif kind == "wish_branch":
		width = 10.0
	elif kind == "ofrenda":
		width = 30.0
	elif kind == "memory_cup":
		width = 12.0
	var depth: float = 12.0 if kind == "bench" else 8.0
	if kind in ["meal_table", "ofrenda"]:
		depth = 12.0
	var footprint := RectangleShape2D.new()
	footprint.size = Vector2(width * unit, depth)
	_shape.shape = footprint
	_shape.position = FEET - Vector2(0, depth * 0.5)


func _key() -> String:
	var controls := get_node_or_null("/root/Controls")
	if controls != null and controls.has_method("label_for"):
		return String(controls.label_for("interact"))
	return "E"


func near_player() -> bool:
	return _near


func _process(_delta: float) -> void:
	_update_footprint()
	if kind == "wish_branch":
		queue_redraw()
	var player := get_tree().get_first_node_in_group("player") as Node2D
	_near = (carryable or pointable) and visible and player != null \
		and player.global_position.distance_to(global_position) <= REACH
	_prompt.text = "[%s] %s" % [_key(), "Point" if pointable else "Pick up"]
	_prompt.visible = _near and (pointable or GameState.carrying.is_empty()) and not get_tree().paused


func _unhandled_input(event: InputEvent) -> void:
	if not _near or (not pointable and not GameState.carrying.is_empty()) or get_tree().paused:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		if pointable:
			pointed.emit(id)
			return
		GameState.carry_load("story_" + kind)
		carryable = false
		visible = false
		picked.emit(id)


func _draw() -> void:
	draw_kind(self, FEET, kind, CHAR.world_unit(self), label)


# ── Drawing ───────────────────────────────────────────────────────────────────
#
# Static, because the same drawing is needed in three places: on the ground, in
# an actor's hands, and in his (CarriedLoad). One drawing, three holders.

const KINDS := ["crate", "chair", "bag", "bench", "tea_tray", "parcel", "notice", "bread_basket", "meal_table", "brooch_old", "brooch_new", "blini_plain", "blini_jam", "phone_stand", "stage_sketch", "cup_slim", "cup_wide", "wish_papers", "wish_branch", "marigolds", "memory_cup", "ofrenda"]


static func draw_kind(ci: CanvasItem, at: Vector2, kind: String, unit: float,
		label: String = "") -> void:
	match kind:
		"crate":
			_crate(ci, at, unit, label)
		"chair":
			_chair(ci, at, unit, label)
		"bag":
			_bag(ci, at, unit)
		"bench":
			_bench(ci, at, unit)
		"bread_basket":
			_bread_basket(ci, at, unit)
		"meal_table":
			_meal_table(ci, at, unit)
		"brooch_old", "brooch_new":
			_brooch_tray(ci, at, unit, kind == "brooch_old", label)
		"blini_plain", "blini_jam":
			_blini_plate(ci, at, unit, kind == "blini_jam")
		"phone_stand", "stage_sketch":
			_work_stand(ci, at, unit, kind == "stage_sketch")
		"cup_slim", "cup_wide":
			_cup_stand(ci, at, unit, kind == "cup_wide")
		"wish_papers":
			_paper_stand(ci, at, unit)
		"wish_branch":
			_bamboo(ci, at, unit, label)
		"marigolds":
			_marigolds(ci, at, unit)
		"memory_cup":
			for x in [-4,3]:
				_box(ci,Rect2(at.x+x*unit,at.y-5*unit,unit,5*unit),Color8(113,78,57))
			_box(ci,Rect2(at.x-6*unit,at.y-7*unit,12*unit,2*unit),Color8(170,126,76))
			_memory_cup(ci,at-Vector2(0,7*unit),unit)
		"ofrenda":
			_ofrenda(ci, at, unit, label == "flowers")
		"tea_tray":
			_box(ci, Rect2(at.x - 6 * unit, at.y - 2 * unit, 12 * unit, 2 * unit), Color8(176, 127, 62))
			for i in range(2):
				var x: float = at.x + float(i * 6 - 5) * unit
				_box(ci, Rect2(x, at.y - 6 * unit, 3 * unit, 4 * unit), Color8(206, 213, 209))
				ci.draw_rect(Rect2(x + unit * 0.5, at.y - 5 * unit, 2 * unit, 3 * unit), Color8(116, 38, 26) if i == 0 else Color8(209, 130, 40))
		"parcel":
			_box(ci, Rect2(at.x - 5 * unit, at.y - 7 * unit, 10 * unit, 7 * unit), Color8(175, 128, 75))
			ci.draw_rect(Rect2(at.x - unit * 0.5, at.y - 7 * unit, unit, 7 * unit), Color8(237, 206, 146))
		"notice":
			var cream := Color8(240, 222, 173)
			_box(ci, Rect2(at.x - 6 * unit, at.y - 10 * unit, 12 * unit, 7 * unit), Color8(40, 71, 77))
			ci.draw_rect(Rect2(at.x - 4 * unit, at.y - 3 * unit, unit, 3 * unit), Color8(122, 91, 65))
			ci.draw_rect(Rect2(at.x + 3 * unit, at.y - 3 * unit, unit, 3 * unit), Color8(122, 91, 65))
			# A stepped arrow stays legible even when the sign is being carried.
			for i in range(3):
				ci.draw_rect(Rect2(at.x + (-4 + i) * unit, at.y + (-6 - i) * unit, unit, (1 + i * 2) * unit), cream)
			ci.draw_rect(Rect2(at.x - unit, at.y - 6 * unit, 5 * unit, unit), cream)


static func _marigolds(ci: CanvasItem, at: Vector2, u: float) -> void:
	_box(ci,Rect2(at.x-2*u,at.y-5*u,4*u,5*u),Color8(183,136,80))
	for i in range(3):
		var x: float = at.x+(i-1)*3*u
		var y: float = at.y-(10+(1 if i == 1 else 0))*u
		ci.draw_rect(Rect2(x,y+u,u,6*u),Color8(57,109,65))
		ci.draw_rect(Rect2(x-2*u,y-u,5*u,3*u),Color8(191,90,39))
		ci.draw_rect(Rect2(x-u,y-2*u,3*u,5*u),Color8(230,132,36))
		ci.draw_rect(Rect2(x,y-u,u,3*u),Color8(244,176,58))

static func _memory_cup(ci: CanvasItem, at: Vector2, u: float) -> void:
	_box(ci,Rect2(at.x-3*u,at.y-6*u,5*u,6*u),Color8(67,121,156))
	ci.draw_rect(Rect2(at.x-2*u,at.y-6*u,3*u,u),Color8(27,54,78))
	ci.draw_rect(Rect2(at.x-2*u,at.y-2*u,u,u),Color8(213,206,173))
	# Distinct crooked handle; the same silhouette in the first tray and ending.
	for xy in [[2,-5],[3,-5],[4,-4],[4,-3],[3,-2],[2,-2]]:
		_box(ci,Rect2(at.x+xy[0]*u,at.y+xy[1]*u,u,u),Color8(100,156,181))

static func _ofrenda(ci: CanvasItem, at: Vector2, u: float, full: bool) -> void:
	for x in [-13,12]:
		_box(ci,Rect2(at.x+x*u,at.y-9*u,u,9*u),Color8(114,71,47))
	_box(ci,Rect2(at.x-15*u,at.y-11*u,30*u,3*u),Color8(208,189,155))
	ci.draw_rect(Rect2(at.x-15*u,at.y-9*u,30*u,4*u),Color8(118,72,114))
	for x in range(-13,14,4):
		ci.draw_rect(Rect2(at.x+x*u,at.y-8*u,2*u,u),Color8(219,192,159))
	# Family photograph: an authored tiny portrait, no text baked into the art.
	_box(ci,Rect2(at.x+u,at.y-25*u,10*u,14*u),Color8(128,83,51))
	ci.draw_rect(Rect2(at.x+2*u,at.y-24*u,8*u,12*u),Color8(221,210,180))
	ci.draw_rect(Rect2(at.x+4*u,at.y-22*u,4*u,5*u),Color8(70,52,52))
	ci.draw_rect(Rect2(at.x+5*u,at.y-21*u,2*u,3*u),Color8(183,131,90))
	ci.draw_rect(Rect2(at.x+3*u,at.y-17*u,6*u,5*u),Color8(94,132,109))
	_memory_cup(ci,at+Vector2(-3*u,-11*u),u)
	if full:
		_marigolds(ci,at+Vector2(-10*u,-11*u),u*0.85)
	for x in [-13,13]:
		ci.draw_rect(Rect2(at.x+x*u,at.y-16*u,u,5*u),Color8(226,211,171))
		ci.draw_rect(Rect2(at.x+x*u,at.y-18*u,u,2*u),Color8(244,183,68))

static func _cup_stand(ci: CanvasItem, at: Vector2, u: float, wide: bool) -> void:
	for x in [-4, 3]:
		_box(ci, Rect2(at.x + x * u, at.y - 5 * u, u, 5 * u), Color8(111, 83, 62))
	_box(ci, Rect2(at.x - 6 * u, at.y - 7 * u, 12 * u, 2 * u), Color8(151, 122, 85))
	var h: int = 7 if wide else 9
	var w: int = 5 if wide else 3
	var ceramic := Color8(118, 158, 157) if wide else Color8(239, 222, 188)
	_box(ci, Rect2(at.x - 3 * u, at.y - (7 + h) * u, w * u, h * u), ceramic)
	ci.draw_rect(Rect2(at.x - 2 * u, at.y - (7 + h) * u, (w - 2) * u, u), Color8(66, 77, 84))
	var handle := Rect2(at.x + (w - 3) * u, at.y - (6 + h) * u, (3 if wide else 2) * u, (5 if wide else 3) * u)
	ci.draw_rect(handle, INK)
	ci.draw_rect(Rect2(handle.position + Vector2(u,0), Vector2(handle.size.x - u, u)), ceramic)
	ci.draw_rect(Rect2(handle.end - Vector2(u,handle.size.y), Vector2(u,handle.size.y)), ceramic)
	ci.draw_rect(Rect2(handle.position + Vector2(0,handle.size.y-u), Vector2(handle.size.x,u)), ceramic)

static func _paper_stand(ci: CanvasItem, at: Vector2, u: float) -> void:
	for x in [-4,3]:
		_box(ci, Rect2(at.x + x*u, at.y - 5*u, u,5*u),Color8(118,86,63))
	_box(ci, Rect2(at.x - 6*u,at.y-7*u,12*u,2*u),Color8(168,128,83))
	_box(ci, Rect2(at.x - 4*u,at.y-15*u,3*u,8*u),Color8(226,193,91))
	for y in [-14,-12,-10]:
		ci.draw_rect(Rect2(at.x-3*u,at.y+y*u,u,u),Color8(94,75,80))
	_box(ci, Rect2(at.x+u,at.y-11*u,3*u,4*u),Color8(198,118,140))
	ci.draw_rect(Rect2(at.x+u,at.y-9*u,3*u,u*0.5),Color8(141,69,104))

static func _bamboo(ci: CanvasItem, at: Vector2, u: float, label: String) -> void:
	_box(ci, Rect2(at.x-5*u,at.y-5*u,10*u,5*u),Color8(86,108,125))
	_box(ci, Rect2(at.x-u,at.y-38*u,2*u,33*u),Color8(111,151,72))
	for y in [-33,-26,-19,-12]:
		ci.draw_rect(Rect2(at.x-u,at.y+y*u,2*u,u),Color8(176,185,92))
	# Whole branch depth belongs to its pot. Leaf/paper movement is discrete,
	# without sliding the trunk or making the object boundaries drift.
	var sway: float = (int(Time.get_ticks_msec()/650)%2)*u if SaveManager.motion() > 0 else 0.0
	for side in [-1,1]:
		for i in range(7):
			ci.draw_rect(Rect2(at.x+side*i*u,at.y+(-23-i)*u,2*u,u),Color8(112,145,71))
		for i in range(4):
			ci.draw_rect(Rect2(at.x+side*(3+i)*u+sway,at.y+(-28+i)*u,3*u,u),Color8(50,111,77))
	var py: float = at.y - (17 if not label.is_empty() else 28)*u
	ci.draw_rect(Rect2(at.x+3*u,py, u,3*u),Color8(188,178,130))
	_box(ci,Rect2(at.x+2*u+sway,py+3*u,3*u,4*u),Color8(199,124,144))
	ci.draw_rect(Rect2(at.x-5*u,at.y-28*u,u,2*u),Color8(188,178,130))
	_box(ci,Rect2(at.x-6*u+sway,at.y-26*u,3*u,7*u),Color8(226,193,91))
	if label == "own":
		_box(ci,Rect2(at.x-4*u+sway,at.y-16*u,3*u,6*u),Color8(119,172,177))

static func _work_stand(ci: CanvasItem, at: Vector2, u: float, sketch: bool) -> void:
	for x in [-4, 3]:
		_box(ci, Rect2(at.x + x * u, at.y - 5 * u, u, 5 * u), Color8(119, 77, 53))
	_box(ci, Rect2(at.x - 6 * u, at.y - 7 * u, 12 * u, 2 * u), Color8(155, 103, 63))
	if sketch:
		_box(ci, Rect2(at.x - 5 * u, at.y - 15 * u, 10 * u, 8 * u), Color8(234, 219, 171))
		ci.draw_rect(Rect2(at.x - 0.5 * u, at.y - 15 * u, u, 8 * u), Color8(171, 136, 102))
		# A stage, overhead lights, then the open central route on the plan.
		ci.draw_rect(Rect2(at.x - 4 * u, at.y - 14 * u, 8 * u, u), Color8(75, 79, 105))
		for x in [-3, 2]:
			ci.draw_rect(Rect2(at.x + x * u, at.y - 13 * u, u, 2 * u), Color8(204, 135, 62))
			ci.draw_rect(Rect2(at.x + x * u, at.y - 10 * u, u, 2 * u), Color8(58, 112, 113))
		ci.draw_rect(Rect2(at.x - 4 * u, at.y - 11 * u, 8 * u, u), Color8(75, 79, 105))
	else:
		_box(ci, Rect2(at.x - 2 * u, at.y - 15 * u, 4 * u, 8 * u), Color8(47, 53, 67))
		ci.draw_rect(Rect2(at.x - u, at.y - 14 * u, 2 * u, 5 * u), Color8(81, 139, 151))
		ci.draw_rect(Rect2(at.x - u, at.y - 8 * u, 2 * u, u * 0.5), Color8(186, 193, 184))
		ci.draw_rect(Rect2(at.x + 4 * u, at.y - 12 * u, u, 5 * u), Color8(177, 187, 183))
		ci.draw_rect(Rect2(at.x + 4 * u, at.y - 12 * u, u, 2 * u), Color8(184, 79, 53))


static func _brooch_tray(ci: CanvasItem, at: Vector2, u: float, old: bool, repair: String) -> void:
	# A padded tray on a low stand; visible at street scale without smooth edges.
	for x in [-4, 3]:
		_box(ci, Rect2(at.x + x * u, at.y - 5 * u, u, 5 * u), Color8(111, 78, 58))
	_box(ci, Rect2(at.x - 6 * u, at.y - 8 * u, 12 * u, 4 * u), Color8(57, 58, 70))
	ci.draw_rect(Rect2(at.x - 5 * u, at.y - 8 * u, 10 * u, 2 * u), Color8(106, 70, 86))
	var metal := Color8(163, 131, 73) if old else Color8(219, 225, 213)
	for row in range(5):
		var width: int = 6 - absi(row - 2) * 2
		ci.draw_rect(Rect2(at.x - width * u * 0.5, at.y + (row - 13) * u, width * u, u), INK)
		ci.draw_rect(Rect2(at.x - width * u * 0.5 + u * 0.5, at.y + (row - 13) * u, (width - 1) * u, u), metal)
	ci.draw_rect(Rect2(at.x - u, at.y - 12 * u, 2 * u, 3 * u), Color8(79, 137, 128) if old else Color8(73, 142, 191))
	if old:
		ci.draw_rect(Rect2(at.x - 2 * u, at.y - 11 * u, 3 * u, u * 0.5), Color8(89, 78, 71))
	else:
		ci.draw_rect(Rect2(at.x, at.y - 12 * u, u, u), Color8(234, 247, 237))
	if repair == "new_clasp":
		ci.draw_rect(Rect2(at.x - 2 * u, at.y - 8 * u, 4 * u, u), Color8(211, 218, 222))
	elif repair == "loop":
		ci.draw_rect(Rect2(at.x - 2 * u, at.y - 8 * u, 2 * u, 2 * u), Color8(163, 131, 73))
		ci.draw_rect(Rect2(at.x - 1.5 * u, at.y - 7.5 * u, u, u), Color8(106, 70, 86))


static func _blini_plate(ci: CanvasItem, at: Vector2, u: float, jam: bool) -> void:
	for x in [-4, 3]:
		_box(ci, Rect2(at.x + x * u, at.y - 5 * u, u, 5 * u), Color8(111, 78, 58))
	_box(ci, Rect2(at.x - 6 * u, at.y - 7 * u, 12 * u, 2 * u), Color8(204, 219, 212))
	for row in range(3):
		var y: float = at.y - (8 + row) * u
		ci.draw_rect(Rect2(at.x - 4 * u, y, 7 * u, u), Color8(224, 177, 94) if row % 2 else Color8(168, 111, 63))
	ci.draw_rect(Rect2(at.x - 3 * u, at.y - 11 * u, 5 * u, u), Color8(239, 198, 115))
	if jam:
		ci.draw_rect(Rect2(at.x - 2 * u, at.y - 11 * u, 3 * u, u), Color8(166, 48, 63))
		ci.draw_rect(Rect2(at.x - u, at.y - 10 * u, u, 2 * u), Color8(122, 40, 60))
	else:
		_box(ci, Rect2(at.x + 3 * u, at.y - 9 * u, 2 * u, 2 * u), Color8(108, 150, 167))
		ci.draw_rect(Rect2(at.x + 3 * u, at.y - 9 * u, 2 * u, u), Color8(242, 231, 210))


static func _bread_basket(ci: CanvasItem, at: Vector2, u: float) -> void:
	var crust := Color8(193, 129, 60)
	var light := Color8(234, 184, 99)
	# Stepped loaves, cloth and a woven rim. No smooth silhouette or baked text.
	for i in range(3):
		var x: float = at.x + (-4.0 + 3.0 * i) * u
		_box(ci, Rect2(x, at.y - 7 * u, 2 * u, 5 * u), crust)
		ci.draw_rect(Rect2(x + u * 0.5, at.y - 8 * u, u, 6 * u), light)
		for score in range(2):
			ci.draw_rect(Rect2(x, at.y - (6 - score * 2) * u, u, u), Color8(242, 208, 145))
	_box(ci, Rect2(at.x - 5.5 * u, at.y - 4 * u, 11 * u, 4 * u), Color8(146, 98, 60))
	ci.draw_rect(Rect2(at.x - 5.5 * u, at.y - 4 * u, 11 * u, u), Color8(218, 182, 120))
	for i in range(5):
		ci.draw_rect(Rect2(at.x + (-4.5 + 2 * i) * u, at.y - 2 * u, u, u), Color8(189, 146, 86))
	ci.draw_rect(Rect2(at.x + u, at.y - 4 * u, 3 * u, 3 * u), Color8(228, 221, 196))
	ci.draw_rect(Rect2(at.x + 2 * u, at.y - 4 * u, u, 3 * u), Color8(83, 117, 133))


static func _meal_table(ci: CanvasItem, at: Vector2, u: float) -> void:
	for x in [-10, 9]:
		_box(ci, Rect2(at.x + x * u, at.y - 8 * u, u, 8 * u), Color8(117, 80, 59))
	_box(ci, Rect2(at.x - 12 * u, at.y - 10 * u, 24 * u, 4 * u), Color8(128, 86, 61))
	_box(ci, Rect2(at.x - 12 * u, at.y - 11 * u, 24 * u, 2 * u), Color8(232, 222, 194))
	for x in [-8, 0, 8]:
		ci.draw_rect(Rect2(at.x + (x - 2) * u, at.y - 12 * u, 4 * u, 2 * u), Color8(125, 166, 170))
		ci.draw_rect(Rect2(at.x + (x - 1) * u, at.y - 12 * u, 2 * u, u), Color8(231, 232, 211))
	# Small paper flags on the front of this particular neighbours' table.
	for i in range(3):
		var x: float = at.x + (-7 + 6 * i) * u
		for stripe in range(3):
			ci.draw_rect(Rect2(x + stripe * u, at.y - 8 * u, u, 2 * u),
				[Color8(51, 77, 116), Color8(233, 223, 196), Color8(169, 66, 61)][stripe])


static func _box(ci: CanvasItem, r: Rect2, fill: Color) -> void:
	ci.draw_rect(Rect2(r.position - Vector2.ONE, r.size + Vector2(2, 2)), INK)
	MATERIALS.surface(ci, r, fill)


static func _crate(ci: CanvasItem, at: Vector2, u: float, label: String) -> void:
	# A beverage crate: dark green plastic, two rows of necks showing, the
	# handle slot cut into the end. Every Späti in the city has a stack of them.
	var w: float = 7.0 * u
	var h: float = 5.0 * u
	var x: float = at.x - w * 0.5
	var y: float = at.y - h
	# Necks first, so the crate's rim sits over them.
	var glass := [Color8(92, 64, 38), Color8(64, 112, 74), Color8(92, 64, 38),
		Color8(64, 112, 74), Color8(118, 84, 50), Color8(64, 112, 74)]
	for i in range(6):
		var nx: float = x + u * 0.5 + float(i) * u * 1.05
		ci.draw_rect(Rect2(nx, y - 2.0 * u, u * 0.7, 2.2 * u), INK)
		ci.draw_rect(Rect2(nx + 1.0, y - 2.0 * u + 1.0, u * 0.7 - 2.0, 2.2 * u), glass[i])
	_box(ci, Rect2(x, y, w, h), Color8(38, 86, 66))
	ci.draw_rect(Rect2(x, y, w, u), Color8(56, 116, 90))
	ci.draw_rect(Rect2(x + w * 0.5 - 1.2 * u, y + 1.3 * u, 2.4 * u, 0.8 * u), Color8(20, 44, 34))
	for i in range(3):
		ci.draw_rect(Rect2(x + u * (1.0 + float(i) * 2.2), y + 2.6 * u, u * 1.2, 1.8 * u),
			Color8(30, 70, 54))
	if not label.is_empty():
		_stamp(ci, Vector2(at.x, y + h - 0.6 * u), label, u, Color8(226, 232, 214))


static func _chair(ci: CanvasItem, at: Vector2, u: float, label: String) -> void:
	# A folding chair: a metal frame, a slatted seat and back. The kind that
	# lives folded behind a counter and comes out for a regular.
	var frame := Color8(96, 102, 114)
	var wood := Color8(176, 132, 84)
	var wood_top := Color8(208, 164, 110)
	var seat_y: float = at.y - 7.0 * u
	# Legs, crossed.
	for side in [-1.0, 1.0]:
		ci.draw_line(Vector2(at.x - 3.0 * u * side, at.y), Vector2(at.x + 2.6 * u * side, seat_y),
			INK, u * 1.1)
		ci.draw_line(Vector2(at.x - 3.0 * u * side, at.y), Vector2(at.x + 2.6 * u * side, seat_y),
			frame, u * 0.6)
	# Back uprights.
	for sx in [-2.6, 2.2]:
		_box(ci, Rect2(at.x + sx * u, at.y - 14.0 * u, 0.6 * u, 7.5 * u), frame)
	# Back slats and seat.
	_box(ci, Rect2(at.x - 2.8 * u, at.y - 13.4 * u, 5.8 * u, 1.6 * u), wood)
	_box(ci, Rect2(at.x - 2.8 * u, at.y - 10.8 * u, 5.8 * u, 1.3 * u), wood)
	_box(ci, Rect2(at.x - 3.4 * u, seat_y - 0.4 * u, 6.8 * u, 1.4 * u), wood)
	ci.draw_rect(Rect2(at.x - 3.4 * u, seat_y - 0.4 * u, 6.8 * u, 0.5 * u), wood_top)
	if not label.is_empty():
		# A strip of parcel tape across the back, written on in marker.
		var tape := Rect2(at.x - 3.2 * u, at.y - 13.6 * u, 6.6 * u, 2.0 * u)
		ci.draw_rect(tape, Color8(226, 206, 152))
		_stamp(ci, Vector2(at.x, tape.position.y + tape.size.y - 0.35 * u), label, u,
			Color8(24, 20, 30))


static func _bag(ci: CanvasItem, at: Vector2, u: float) -> void:
	# A paper bag of Schrippen with a folded newspaper stuck in the top.
	var w: float = 4.4 * u
	var h: float = 5.2 * u
	var x: float = at.x - w * 0.5
	var y: float = at.y - h
	_box(ci, Rect2(x + 0.6 * u, y - 1.6 * u, 2.2 * u, 2.6 * u), Color8(214, 212, 204))
	ci.draw_rect(Rect2(x + 0.9 * u, y - 1.2 * u, 1.6 * u, 0.3 * u), Color8(120, 120, 128))
	ci.draw_rect(Rect2(x + 0.9 * u, y - 0.6 * u, 1.6 * u, 0.3 * u), Color8(120, 120, 128))
	_box(ci, Rect2(x + 2.4 * u, y - 0.9 * u, 1.6 * u, 1.3 * u), Color8(214, 160, 86))
	_box(ci, Rect2(x, y, w, h), Color8(196, 160, 112))
	ci.draw_rect(Rect2(x, y, w, 0.8 * u), Color8(222, 190, 140))


static func _bench(ci: CanvasItem, at: Vector2, u: float) -> void:
	# A park bench, green slats on a black iron frame.
	var slat := Color8(58, 104, 72)
	var slat_top := Color8(84, 134, 96)
	var iron := Color8(36, 38, 46)
	for sx in [-9.0, 8.0]:
		_box(ci, Rect2(at.x + sx * u, at.y - 7.0 * u, 1.0 * u, 7.0 * u), iron)
		_box(ci, Rect2(at.x + sx * u, at.y - 13.0 * u, 1.0 * u, 6.0 * u), iron)
	for row in range(2):
		_box(ci, Rect2(at.x - 10.0 * u, at.y - (13.0 - float(row) * 2.4) * u, 20.0 * u, 1.4 * u), slat)
	_box(ci, Rect2(at.x - 10.5 * u, at.y - 7.6 * u, 21.0 * u, 1.6 * u), slat)
	ci.draw_rect(Rect2(at.x - 10.5 * u, at.y - 7.6 * u, 21.0 * u, 0.6 * u), slat_top)


static func _stamp(ci: CanvasItem, baseline: Vector2, text: String, u: float,
		col: Color) -> void:
	var font: Font = ThemeDB.fallback_font
	var size: int = maxi(7, roundi(u * 1.7))
	var w: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	ci.draw_string(font, Vector2(baseline.x - w * 0.5, baseline.y), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)
