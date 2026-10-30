class_name ActivityObjects
extends RefCounted

# Grid-built working objects. They use the characters' flat edges and a small
# material palette, so an activity can add detail without changing art style.
const INK := Color8(32, 35, 42)
const WOOD := Color8(130, 94, 65)
const EDGE := Color8(185, 145, 96)
const METAL := Color8(125, 145, 150)
const PALE := Color8(226, 222, 199)
const GREEN := Color8(76, 116, 76)
const RED := Color8(164, 70, 59)
const BLUE := Color8(69, 112, 135)
const GOLD := Color8(211, 174, 80)
const CAT := preload("res://scenes/world/CatArt.gd")
const MATERIALS := preload("res://scenes/world/PropMaterials.gd")
const ITEM_ART := preload("res://scenes/world/ItemArt.gd")
static var _profiles: Dictionary = {}

static func profile(city: String, region: String) -> Dictionary:
	if _profiles.is_empty():
		_profiles = JSON.parse_string(FileAccess.get_file_as_string(
			"res://art/environments/activity-direction.json"))
	return _profiles.get(city + ":" + region, {})

static func rect(ci: CanvasItem, x: float, y: float, w: float, h: float, color: Color) -> void:
	MATERIALS.surface(ci, Rect2(roundf(x), roundf(y), w, h), color)

static func table(ci: CanvasItem, width: float = 32.0) -> void:
	rect(ci, -width / 2, -13, width, 4, EDGE)
	rect(ci, -width / 2, -9, width, 2, WOOD.darkened(0.2))
	for x in [-width / 2 + 2, width / 2 - 4]:
		rect(ci, x, -7, 3, 7, WOOD)
		rect(ci, x, -7, 1, 6, EDGE)
		rect(ci, x, -2, 3, 1, WOOD.darkened(.3))
	rect(ci,-width/2+4,-5,width-8,1,WOOD.darkened(.18))
	for x in range(int(-width/2)+3,int(width/2)-5,9):
		rect(ci,x,-12,5,1,WOOD)
	for x in [-width/2+1,width/2-2]:rect(ci,x,-10,1,1,METAL.darkened(.4))

static func seat(ci: CanvasItem, feet: Vector2, unit: float, city: String) -> void:
	ci.draw_set_transform(feet, 0.0, Vector2(unit, unit))
	var color: Color = BLUE if city in ["hanoi", "seoul", "tokyo"] else WOOD
	rect(ci, -8, -2, 16, 2, color.lightened(0.16))
	rect(ci, -7, 0, 3, 3, color)
	rect(ci, 4, 0, 3, 3, color.darkened(0.12))
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

static func draw(ci: CanvasItem, kind: String, at: Vector2, unit: float,
		t: float, city: String) -> void:
	ci.draw_set_transform(at.round(), 0.0, Vector2(unit, unit))
	match kind:
		"sleeping_cat":
			CAT.draw_cat(ci,0,0,0,0,t)
		"sleeping_dog":
			rect(ci,-14,-3,30,4,Color(0,0,0,.18))
			rect(ci,-12,-9,25,8,INK)
			rect(ci,-11,-8,22,6,WOOD)
			rect(ci,-15,-7,10,7,INK)
			rect(ci,-14,-6,8,5,WOOD)
			rect(ci,-14,-7,3,4,WOOD.darkened(.3))
			rect(ci,-11,-3,3,1,INK)
			rect(ci,11,-6,6,2,WOOD)
		"fabric_unroll", "fabric_folded":
			# A full-height cutting table, with cloth at the merchant's hands.
			# The generic coffee table put this long work surface at shin level.
			rect(ci,-47,-20,94,3,EDGE)
			rect(ci,-47,-17,94,2,WOOD.darkened(.2))
			for x in [-45,42]:
				rect(ci,x,-15,3,15,WOOD)
			rect(ci,-43,-5,86,2,WOOD.darkened(.12))
			var spread: float = 1.0 if kind == "fabric_folded" else smoothstep(.3,2.5,t)
			var width: float = 17.0 if kind == "fabric_folded" else roundf(17.0+spread*65.0)
			rect(ci,-43,-23,width,3,Color8(132,58,70))
			rect(ci,-43,-23,width,1,GOLD)
			for x in range(-39,int(-43+width),6): rect(ci,x,-22,2,1,PALE)
			rect(ci,-45+width,-28,6,6,RED)
			rect(ci,-44+width,-27,2,4,GOLD)
		"doorstep":
			rect(ci, -125, -7, 250, 7, Color8(122, 128, 131))
			rect(ci, -125, -7, 250, 2, Color8(180, 179, 163))
			for x in range(-125, 125, 25):
				rect(ci, x, -5, 1, 5, Color8(84, 91, 98))
		"cats":
			# Share the street cats' breathing and tail animation.
			CAT.draw_cat(ci, -60, -12, 0, 2, t)
			CAT.draw_cat(ci, 45, 0, 1, 0, t)
			rect(ci, 1, -4, 17, 4, METAL)
			rect(ci, 3, -4, 13, 1, BLUE)
		"apple_crate", "fish_stall", "card_machine", "bottle_ledge", "market_stall", "simit_cart":
			_encounter_object(ci, kind, t)
		"keg":
			_keg(ci, t)
		"tea", "bottles", "trays", "bread", "cheese", "fruit", "jewellery", "badges", "souvenirs", "chess":
			_tabletop(ci, kind, t, city)
		"griddle", "mill", "copperpot", "incense":
			_kitchen(ci, kind, t)
		"sewing", "lathe", "workbench", "shoeshine", "organ", "amp":
			_workshop(ci, kind, t)
		"produce", "crate", "salvage", "books", "kiosk":
			_goods(ci, kind)
		"flowers", "memorial", "candles", "tablet", "museum", "map":
			_display(ci, kind, t)
		"fabric", "clothes", "laundry", "scarves", "curtain":
			_cloth(ci, kind, t)
		"fountain", "bath", "watertank", "watersteps":
			_water(ci, kind, t)
		"ladder", "paint", "easel":
			_paint(ci, kind, t)
		"surfboard", "flags", "rope", "dogs", "pigeons", "basket", "shoes", "bicycle":
			_outdoors(ci, kind, t)
		"queue", "gate", "turnstile", "railing", "steps", "bench", "bins":
			_street(ci, kind, t)
		"tram", "train", "ferry", "cablecar", "handcart":
			_transport(ci, kind, t, city)
	_finish_object(ci,kind)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func _finish_object(ci: CanvasItem, kind: String) -> void:
	# Hardware and wear are placed deliberately, inside the existing outline.
	# These are shared by live locations and staged activity shots.
	if kind in ["market_stall","fish_stall","simit_cart"]:
		for x in [-27,25]:
			rect(ci,x,-50,1,38,EDGE)
			for y in [-46,-17]:rect(ci,x,y,2,2,METAL.darkened(.35))
		for x in range(-29,30,6):
			rect(ci,x,-55,4,1,PALE.darkened(.2))
			rect(ci,x,-48,5,1,INK.lightened(.1))
		rect(ci,-25,-10,50,1,WOOD)
		for x in range(-23,24,9):rect(ci,x,-12,5,1,WOOD.darkened(.2))
	elif kind == "card_machine":
		for x in [-12,11]:
			for y in [-42,-3]:rect(ci,x,y,1,1,METAL)
		rect(ci,-7,-34,4,1,PALE)
		rect(ci,2,-34,5,1,BLUE.lightened(.25))
		for x in [-8,-5,-2,1]:rect(ci,x,-13,2,1,METAL)
		rect(ci,-8,-6,14,1,METAL.darkened(.3))
		rect(ci,7,-14,2,1,RED)
	elif kind in ["crate","produce","books","kiosk","salvage"]:
		for row in range(2 if kind == "crate" else 3):
			for col in range(3):
				var x := -23+col*16
				var y := -3-row*11
				for dx in [0,14]:
					rect(ci,x+dx,y-7,1,8,EDGE)
					rect(ci,x+dx,y-7,1,1,METAL.darkened(.3))
				if kind == "books":
					for dx in [2,5,8,11]:
						rect(ci,x+dx,y-5,1,1,GOLD)
						rect(ci,x+dx,y-2,1,1,PALE.darkened(.12))
				elif kind == "crate":
					rect(ci,x+6,y-5,3,1,INK)
					rect(ci,x+3,y+1,8,1,WOOD.darkened(.24))
	elif kind == "sewing":
		rect(ci,-12,-26,19,1,METAL.darkened(.35))
		ci.draw_arc(Vector2(-10,-23),3,0,TAU,12,METAL,1,false)
		rect(ci,6,-28,1,11,PALE)
		rect(ci,5,-30,3,3,RED)
		rect(ci,-8,-26,3,1,GOLD)
		rect(ci,-10,-14,22,1,BLUE.lightened(.2))
		for x in range(-7,11,3):rect(ci,x,-15,1,1,PALE)
	elif kind in ["lathe","workbench"]:
		for x in [-12,11]:rect(ci,x,-20,1,1,METAL.lightened(.3))
		if kind == "lathe":
			for y in [-25,-22]:rect(ci,-13,y,6,1,INK)
			rect(ci,10,-23,4,1,GOLD)
		else:
			for x in [-10,0,10]:rect(ci,x,-25,1,3,PALE)
			rect(ci,-14,-16,5,1,RED)
	elif kind == "bench":
		for x in [-24,21]:
			rect(ci,x,-20,2,16,METAL.darkened(.5))
			for y in [-19,-16,-13,-10]:rect(ci,x,y,1,1,METAL)
		for y in [-19,-16,-13,-10]:
			rect(ci,-19,y,13,1,WOOD.lightened(.16))
			rect(ci,7,y,9,1,WOOD.darkened(.15))
	elif kind == "bicycle":
		for x in [-17,17]:
			ci.draw_arc(Vector2(x,-9),7,0,TAU,16,METAL.darkened(.28),.5,false)
			for spoke in range(6):
				var v := Vector2.from_angle(spoke*TAU/6)*6
				ci.draw_line(Vector2(x,-9),Vector2(x,-9)+v,METAL.darkened(.48),.5,false)
			rect(ci,x-1,-10,2,2,METAL)
		rect(ci,11,-27,1,5,METAL)
		rect(ci,-9,-24,6,1,WOOD)
		rect(ci,3,-10,3,2,METAL)
		rect(ci,5,-8,3,1,INK)
	elif kind == "map":
		ITEM_ART.draw_fitted(ci,Rect2(-12,-35,24,21),"karte")
	elif kind == "flowers":
		for x in [-13,0,13]:
			ITEM_ART.draw_fitted(ci,Rect2(x-5,-27,11,14),"kermel_flowers")
	elif kind == "griddle":
		for x in [-12,-6,0,6,12]:rect(ci,x,-17,2,2,METAL.darkened(.3))
		for x in [-8,7]:
			ITEM_ART.draw_fitted(ci,Rect2(x-3,-26,7,5),"pastel")
	elif kind == "copperpot":
		for y in [-24,-20,-16]:
			rect(ci,5,y,3,1,EDGE)
			rect(ci,-8,y+1,2,1,WOOD)
		rect(ci,-14,-26,2,2,GOLD)
	elif kind == "bins":
		for i in range(3):
			var x := -28+i*20
			rect(ci,x+5,-27,5,1,INK)
			for dx in [2,5,8,11]:rect(ci,x+dx,-16,1,10,GREEN.darkened(.1))
	elif kind in ["fabric_folded","fabric_unroll"]:
		for x in [-44,43]:
			rect(ci,x,-18,1,1,METAL.darkened(.2))
			rect(ci,x,-14,1,13,EDGE)
		for x in range(-37,43,9):rect(ci,x,-19,5,1,WOOD)
	elif kind == "handcart":
		for x in [-18,10]:rect(ci,x+2,-4,2,2,METAL)
		for y in [-19,-29]:
			for x in [-19,10]:
				rect(ci,x,y+1,2,7,WOOD)
				rect(ci,x,y+2,1,1,METAL)

static func carried(ci: CanvasItem, kind: String, feet: Vector2, unit: float, t: float, movement: float = 1.0) -> void:
	if kind == "wood_staves":
		ci.draw_set_transform(feet.round(),0,Vector2(unit,unit))
		for i in range(3):
			rect(ci,6+i*3,-31+i,2,29,WOOD)
			rect(ci,6+i*3,-31+i,1,29,EDGE)
		ci.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
		return
	if kind == "guitar":
		handheld(ci,kind,feet+Vector2(3,-9)*unit,unit,t)
		return
	if kind in ["market_cart", "market_cart_empty"]:
		ci.draw_set_transform(feet.round(),0,Vector2(unit,unit))
		# The cart and its load share the porter's actual movement.
		rect(ci,8,-17,2,16,METAL)
		rect(ci,8,-18,5,2,INK)
		rect(ci,9,-2,21,2,METAL)
		for x: int in [12,26]:
			rect(ci,x,-1,4,4,INK)
			rect(ci,x+1,0,2,2,METAL)
		if kind == "market_cart":
			for i in range(3):
				var y: int = -10-i*9
				rect(ci,12,y,17,8,WOOD.darkened(.2))
				rect(ci,12,y,17,1,EDGE)
				rect(ci,13,y+2,15,2,WOOD)
				rect(ci,13,y+5,15,2,WOOD)
				rect(ci,15,y+2,3,2,INK)
				rect(ci,23,y+2,3,2,INK)
			for x: int in [14,18,22,26]: rect(ci,x,-30,3,3,GREEN)
		ci.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
		return
	if kind in ["dog_pack", "dog_pack_look"]:
		ci.draw_set_transform(feet.round(),0,Vector2(unit,unit))
		# Nine dogs travel with their walker and settle together; only two
		# turn toward the alien in the failed-whistle branch.
		for i in range(9):
			var x: float = 17+(i%3)*15
			var y: float = -10+(i/3)*9
			var color: Color = [WOOD,INK,PALE,Color8(118,113,108)][i%4]
			var step: float = roundf(sin(t*9.0+i)*movement)
			rect(ci,x-1,y+3,14,1,Color(0,0,0,.18))
			rect(ci,x-1,y-6,12,6,INK)
			rect(ci,x,y-5,10,4,color)
			rect(ci,x+1,y-5,7,1,color.lightened(.16))
			rect(ci,x+1,y-1,2,3+step,color)
			rect(ci,x+7,y-1,2,3-step,color)
			rect(ci,x-2,y-7,3,2,color)
			var looking: bool = kind == "dog_pack_look" and i < 2
			rect(ci,x+6,y-10,7,7,INK)
			rect(ci,x+7,y-9,5,5,color)
			rect(ci,x+7,y-11,2,3,color.darkened(.3))
			rect(ci,x+(7 if looking else 10),y-8,1,1,INK if color != INK else PALE)
			rect(ci,x+(6 if looking else 11),y-6,3,2,color)
		ci.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
		return
	if kind == "organ_collection_cap":
		handheld(ci,"cap",feet+Vector2(4,-8)*unit,unit,t)
		return
	if kind == "organ_cap":
		ci.draw_set_transform(feet.round(),0,Vector2(unit,unit))
		rect(ci,-6,-25,12,4,Color8(176,154,111))
		rect(ci,-8,-22,16,2,Color8(124,105,73))
		ci.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
		return
	if kind == "shoe_customer":
		# A seated customer's extended leg meets the measured shoe rest.
		# Opt-in staging keeps ordinary bench poses unchanged.
		ci.draw_set_transform(feet.round(),0,Vector2(unit,unit))
		rect(ci,-4,0,3,10,Color8(53,52,62))
		rect(ci,-5,9,5,2,INK)
		rect(ci,2,0,5,3,Color8(66,65,76))
		rect(ci,4,3,3,4,Color8(66,65,76))
		rect(ci,4,7,5,2,INK)
		rect(ci,5,7,3,1,METAL.darkened(.55))
		ci.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
		return
	if kind == "shoe_brush":
		ci.draw_set_transform(feet.round(),0,Vector2(unit,unit))
		# A brief brushing action settles while the player reads.
		var stroke: float = roundf(sin(minf(t,2.8)*10.0)*.8) if t < 2.8 else 0.0
		rect(ci,-9+stroke,-9,4,2,WOOD)
		rect(ci,-9+stroke,-7,4,1,INK)
		rect(ci,-6+stroke,-11,3,2,Color8(175,125,84))
		ci.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
		return
	if kind == "lei_worn":
		ci.draw_set_transform(feet.round(),0,Vector2(unit,unit))
		for dot in [Vector2(-5,-10),Vector2(-4,-8),Vector2(-2,-7),Vector2(0,-6),Vector2(2,-7),Vector2(4,-8),Vector2(5,-10)]:
			rect(ci,dot.x,dot.y,2,2,PALE)
			rect(ci,dot.x,dot.y,1,1,GOLD)
		ci.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
		return
	if kind == "board_carry":
		ci.draw_set_transform(feet.round(),0,Vector2(unit,unit))
		rect(ci,6,-20,6,19,PALE)
		rect(ci,7,-23,4,3,PALE)
		rect(ci,8,-24,2,1,PALE)
		rect(ci,7,-1,4,2,PALE)
		rect(ci,8,-20,1,20,RED)
		ci.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
		return
	if kind in ["surfboard", "paddle_board"]:
		var board_at: Vector2 = feet-Vector2(0,8*unit) if kind == "paddle_board" else feet
		ci.draw_set_transform(board_at.round(),0,Vector2(unit,unit))
		rect(ci,-12,1,24,2,BLUE.darkened(.3))
		rect(ci,-10,0,21,2,PALE)
		rect(ci,-7,0,16,1,RED)
		rect(ci,-16,4,9,1,PALE)
		rect(ci,-11,6,6,1,PALE)
		ci.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
		return
	if kind == "graduation":
		ci.draw_set_transform(feet.round(),0,Vector2(unit,unit))
		# A stepped mortarboard and a narrow stole sit on the existing game
		# character; the gown uses the ordinary coat silhouette and palette.
		for row in range(4):
			var width: int = 4+row*4
			rect(ci,-width*.5,-28+row,width,1,INK)
		rect(ci,-5,-24,10,3,INK)
		rect(ci,6,-25,1,7,GOLD)
		rect(ci,5,-19,3,2,GOLD)
		rect(ci,-4,-10,2,7,GOLD)
		rect(ci,3,-10,2,7,GOLD)
		ci.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
		return
	if kind in ["camera", "microphone"]:
		# The equipment follows its operator's hand/shoulder without moving
		# the pavement or producing a separate, floating prop between cuts.
		var offset := Vector2(-6, -15) if kind == "camera" else Vector2(6, -10)
		handheld(ci, kind, feet + offset * unit, unit)
		return
	if kind == "tea_tray":
		ci.draw_set_transform(feet,0,Vector2(unit,unit))
		var sway: float = sin(t*3.0)*0.6
		# Three chains meet at the hand; the tray stays level below it.
		var hand := Vector2(7,-10)
		for x in [1.0,7.0,13.0]:
			ci.draw_line(hand,Vector2(x+sway,-2),METAL,.45)
		rect(ci,0+sway,-2,15,1,METAL)
		for i in range(6):
			var x: float = 1+sway+i*2
			rect(ci,x,-5,1.5,3,RED)
			rect(ci,x,-5,1.5,.5,PALE)
		ci.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
		return
	if kind != "shoulder_pole": return
	ci.draw_set_transform(feet,0,Vector2(unit,unit))
	var bounce: float = sin(t*5.0)*0.4*movement
	# A flexible bamboo yoke rests across the shoulders; two baskets swing
	# from its ends, so the weight and the worker's gait read together.
	var pole := PackedVector2Array([Vector2(-17,-8+bounce),Vector2(-8,-10),Vector2(0,-10),Vector2(8,-10),Vector2(17,-8-bounce)])
	ci.draw_polyline(pole,WOOD.darkened(.25),1.3)
	ci.draw_polyline(pole,EDGE,.6)
	for side in [-1,1]:
		var x: float = side*17+sin(t*5.0+side)*.8*movement
		var y: float = -5+side*bounce
		ci.draw_line(Vector2(side*17,-8-side*bounce),Vector2(x-4,y),WOOD,.5)
		ci.draw_line(Vector2(side*17,-8-side*bounce),Vector2(x+4,y),WOOD,.5)
		ci.draw_colored_polygon(PackedVector2Array([Vector2(x-5,y),Vector2(x+5,y),Vector2(x+4,y+4),Vector2(x-4,y+4)]),WOOD)
		for row in range(3): rect(ci,x-4,y+row+1,8,0.4,EDGE)
		for i in range(4):
			rect(ci,x-4+i*2,y-1-float(i%2),2,2,GREEN.lightened(float(i%2)*.2))
	ci.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)

static func handheld(ci: CanvasItem, kind: String, point: Vector2, unit: float, t: float = 0.0) -> void:
	ci.draw_set_transform(point.round(),0,Vector2(unit,unit))
	match kind:
		"bec", "mortadela", "banh_mi", "arepa":
			var wide: int = 15 if kind == "banh_mi" else 11
			var tall: int = 9 if kind == "mortadela" else 5
			rect(ci,-wide/2-1,-tall-3,wide+2,tall+7,INK)
			rect(ci,-wide/2,-tall-2,wide,3,GOLD)
			rect(ci,-wide/2+2,-tall-3,wide-4,1,PALE)
			rect(ci,-wide/2,-tall+1,wide,tall-1,Color8(176,111,89))
			if kind == "mortadela":
				for y in [-6,-3]: rect(ci,-wide/2,y,wide,1,Color8(220,156,144))
			elif kind == "bec":
				rect(ci,-5,-3,10,2,Color8(233,207,125))
			elif kind == "banh_mi":
				for x in [-5,-1,3]: rect(ci,x,-3,3,2,GREEN)
			else:
				rect(ci,-4,-3,8,2,PALE)
			rect(ci,-wide/2,0,wide,3,GOLD)
			rect(ci,-wide/2+1,3,wide-2,1,Color8(222,218,207))
		"pastel":
			rect(ci,-8,-8,16,11,Color8(129,82,40))
			rect(ci,-7,-7,14,9,GOLD)
			for x in [-6,-2,2,6]: rect(ci,x,-6,1,1,PALE)
			for x in [-5,0,4]: rect(ci,x,-2,1,1,Color8(159,101,44))
			rect(ci,-5,2,9,2,PALE)
		"fruit_slice":
			rect(ci,-4,-4,9,5,GREEN)
			rect(ci,-3,-4,7,4,Color8(228,167,79))
			rect(ci,0,-3,1,2,INK)
		"fabric_roll":
			rect(ci,-7,-4,15,7,INK)
			rect(ci,-6,-3,13,5,RED)
			rect(ci,-4,-3,2,5,GOLD)
			rect(ci,4,-2,3,3,PALE)
			rect(ci,5,-1,1,1,RED)
		"cider":
			rect(ci,-3,-6,7,9,INK)
			rect(ci,-2,-5,5,7,PALE)
			rect(ci,-2,-5,5,1,Color8(163,105,43))
			rect(ci,-1,-3,3,3,RED)
		"cap":
			rect(ci,-5,-3,9,4,Color8(176,154,111))
			rect(ci,-7,0,14,2,Color8(124,105,73))
			rect(ci,-3,-2,5,2,INK)
		"tostada", "tostada_small":
			rect(ci,-7,3,14,2,PALE)
			rect(ci,-6,1,12,2,GOLD)
			rect(ci,-5,0,10,1,WOOD)
			var layers: int = 4 if kind == "tostada" else 1
			for i in range(layers):
				rect(ci,-5+i%2,-2-i*2,10-i,2,[GREEN,RED,PALE,GREEN.lightened(.15)][i])
				rect(ci,-3+i%2,-2-i*2,2,1,PALE)
		"wax_cloth":
			rect(ci,-5,-4,10,8,BLUE.darkened(.3))
			rect(ci,-5,-4,10,1,GOLD)
			rect(ci,-5,2,10,1,GOLD)
			for x in [-3,1]:
				rect(ci,x,-2,2,2,RED)
				rect(ci,x+1,-1,2,2,GOLD)
		"lei":
			for dot in [Vector2(-4,-4),Vector2(-5,-2),Vector2(-5,0),Vector2(-4,2),Vector2(-2,3),Vector2(0,3),Vector2(2,2),Vector2(3,0),Vector2(3,-2),Vector2(2,-4),Vector2(0,-5),Vector2(-2,-5)]:
				rect(ci,dot.x,dot.y,2,2,PALE)
				rect(ci,dot.x,dot.y,1,1,GOLD)
		"spray_can":
			rect(ci,-2,-5,4,8,METAL)
			rect(ci,-2,-2,4,3,BLUE)
			rect(ci,-1,-6,2,1,INK)
			rect(ci,-1,-4,1,2,PALE)
		"shave_ice":
			rect(ci,-3,-1,7,4,PALE)
			rect(ci,-2,3,5,2,BLUE)
			rect(ci,-2,-4,5,3,RED)
			rect(ci,0,-5,2,4,GOLD)
			rect(ci,2,-3,2,3,GREEN.lightened(.2))
			rect(ci,4,-5,1,6,WOOD)
		"wood_crate":
			rect(ci,-6,-4,12,8,WOOD.darkened(.25))
			rect(ci,-6,-4,12,1,EDGE)
			for y in [-1,2]:rect(ci,-5,y,10,1,WOOD)
			rect(ci,-5,-3,1,6,EDGE)
			rect(ci,4,-3,1,6,EDGE)
		"bouquet":
			rect(ci,-1,-2,2,7,GREEN)
			rect(ci,-3,0,5,2,PALE)
			for dot in [Vector2(-3,-4),Vector2(0,-6),Vector2(3,-3)]:
				rect(ci,dot.x-1,dot.y-1,3,3,RED)
				rect(ci,dot.x,dot.y,1,1,GOLD)
		"wrapped_fish":
			rect(ci,-6,-2,12,5,PALE)
			rect(ci,-4,-3,9,1,EDGE)
			rect(ci,-2,-2,1,5,METAL)
			rect(ci,3,-1,2,2,METAL)
			rect(ci,6,-2,2,4,BLUE)
		"brass_thing":
			rect(ci,-4,-2,8,4,GOLD.darkened(.25))
			rect(ci,-3,-3,6,2,GOLD)
			rect(ci,-1,-5,3,3,GOLD)
			rect(ci,-3,-6,7,2,EDGE)
			rect(ci,2,-4,2,3,GOLD.darkened(.35))
		"wax_leg":
			rect(ci,-1,-5,3,7,PALE)
			rect(ci,-1,1,5,2,PALE)
			rect(ci,-1,-5,1,7,EDGE)
			rect(ci,1,-4,1,5,Color8(255,249,221))
		"wax_candle":
			rect(ci,-1,-5,3,8,PALE)
			rect(ci,-1,-5,1,8,EDGE)
			rect(ci,0,-6,1,1,INK)
		"grain_cup":
			rect(ci,-2,-1,4,4,GOLD.darkened(.25))
			rect(ci,-2,-2,4,1,GOLD)
			rect(ci,-1,-2,2,1,PALE)
			rect(ci,-2,-1,1,3,GOLD)
			rect(ci,2,0,1,2,GOLD)
		"shrimp_fritter", "shrimp_wrap":
			if kind == "shrimp_wrap":
				rect(ci,-5,-3,10,6,GREEN.darkened(.2))
				rect(ci,-4,-4,8,8,GREEN)
				rect(ci,-2,-3,1,5,GREEN.lightened(.25))
			rect(ci,-3,-2,7,4,Color8(186,111,35))
			rect(ci,-2,-3,5,4,Color8(233,178,65))
			rect(ci,-1,-2,4,1,Color8(226,115,53))
			rect(ci,2,-1,1,2,Color8(226,115,53))
			rect(ci,0,0,2,1,Color8(248,174,105))
		"fruit_crate":
			rect(ci,-8,-3,16,9,WOOD.darkened(.2))
			rect(ci,-8,-3,16,1,EDGE)
			for yy in [0,3]:rect(ci,-7,yy,14,1,EDGE)
			rect(ci,-7,-2,2,7,WOOD)
			rect(ci,5,-2,2,7,WOOD)
			for x in [-5,-1,3]:
				rect(ci,x,-6,4,4,GOLD)
				rect(ci,x+1,-7,2,1,GREEN)
				rect(ci,x+1,-5,1,1,PALE)
		"menchi":
			rect(ci,-4,-4,8,5,Color8(146,85,33))
			rect(ci,-3,-5,6,5,Color8(209,153,58))
			for spot in [Vector2(-2,-4),Vector2(1,-3),Vector2(2,-5)]:
				rect(ci,spot.x,spot.y,1,1,Color8(243,197,99))
			rect(ci,-4,0,8,4,PALE)
			rect(ci,-3,3,6,1,Color8(183,174,146))
		"book":
			rect(ci,-5,-5,10,10,BLUE.darkened(.3))
			rect(ci,-3,-5,8,10,BLUE)
			rect(ci,-3,3,8,1,PALE)
			rect(ci,-1,-3,4,2,PALE)
			rect(ci,-2,0,6,1,GOLD)
		"fortune_good", "fortune_bad":
			rect(ci,-3,-6,7,13,PALE)
			# Tiny, explicit 吉 / 凶 marks; no generated glyph texture.
			if kind == "fortune_good":
				rect(ci,0,-5,1,3,INK)
				rect(ci,-2,-4,5,1,INK)
				rect(ci,-1,-2,3,1,INK)
				rect(ci,-1,0,3,3,INK)
				rect(ci,0,1,1,1,PALE)
			else:
				for dot in [Vector2(-1,-4),Vector2(1,-4),Vector2(0,-3),Vector2(-1,-2),Vector2(1,-2)]:
					rect(ci,dot.x,dot.y,1,1,INK)
				rect(ci,-2,-4,1,5,INK)
				rect(ci,2,-4,1,5,INK)
				rect(ci,-2,0,5,1,INK)
			rect(ci,-1,5,3,1,RED)
		"camera":
			rect(ci,-7,-3,13,6,INK)
			rect(ci,-5,-5,7,2,INK)
			rect(ci,-8,-2,3,4,METAL.darkened(.4))
			rect(ci,-5,-2,7,3,Color8(68,80,85))
			rect(ci,2,-2,3,2,BLUE)
			rect(ci,3,-2,1,1,RED)
		"microphone":
			rect(ci,-1,-1,2,6,INK)
			rect(ci,-2,-4,4,4,METAL.darkened(.45))
			rect(ci,-1,-5,2,1,METAL)
			rect(ci,-2,1,4,2,BLUE)
		"jeon":
			rect(ci,-6,0,12,2,PALE)
			rect(ci,-5,-2,10,2,Color8(166,107,49))
			rect(ci,-4,-3,8,2,Color8(227,176,71))
			for x in [-3,0,3]:rect(ci,x,-3,1,2,Color8(68,118,56))
			rect(ci,2,-2,1,1,RED)
		"metal_part":
			rect(ci,-4,-2,8,4,INK)
			rect(ci,-5,-1,10,2,METAL)
			rect(ci,-3,-2,6,1,PALE)
			for x in [-2,0,2]:rect(ci,x,-1,1,3,METAL.darkened(.35))
		"shoe":
			rect(ci,-5,0,11,2,INK)
			rect(ci,-5,-3,4,3,WOOD)
			rect(ci,-1,-2,6,2,WOOD)
			rect(ci,-4,-4,3,2,EDGE)
			rect(ci,-1,-2,2,1,PALE)
		"badge":
			rect(ci,-2,-3,4,6,GOLD)
			rect(ci,-3,-2,6,4,GOLD)
			rect(ci,-2,-2,4,4,RED)
			rect(ci,-1,-1,2,2,PALE)
		"scarf":
			rect(ci,-5,-3,9,4,RED)
			rect(ci,-5,1,3,5,RED)
			rect(ci,1,1,3,6,RED)
			for x in [-4,-1,2]:rect(ci,x,-2,1,2,PALE)
			for x in [-5,-3,1,3]:rect(ci,x,6,1,2,GOLD)
		"food_tray":
			rect(ci,-8,1,16,2,METAL.darkened(.25))
			rect(ci,-9,0,18,1,METAL)
			rect(ci,-6,-2,7,2,PALE)
			rect(ci,-5,-3,5,2,RED)
			rect(ci,3,-2,4,2,GOLD)
			rect(ci,4,-3,2,1,GREEN)
		"guitar":
			rect(ci,-6,-3,9,7,WOOD.darkened(.3))
			rect(ci,-5,-4,6,9,EDGE)
			rect(ci,-7,-1,11,3,EDGE)
			rect(ci,1,-4,3,3,WOOD)
			rect(ci,3,-7,2,4,WOOD)
			rect(ci,4,-10,3,4,INK)
			rect(ci,-3,-1,3,3,INK)
			rect(ci,-3,3,3,1,WOOD)
		"falafel":
			rect(ci,-3,-3,6,6,Color8(182,123,62))
			rect(ci,-2,-4,4,2,Color8(231,188,113))
			rect(ci,-2,-3,4,2,Color8(67,111,49))
			rect(ci,0,-3,1,1,Color8(180,62,44))
			rect(ci,-2,0,4,4,Color8(235,228,203))
		"kebab":
			rect(ci,-2,-5,4,9,Color8(230,190,120))
			rect(ci,-2,-5,4,2,Color8(78,114,48))
			rect(ci,-1,-5,2,1,Color8(176,72,47))
			rect(ci,-2,-2,4,6,Color8(230,226,207))
			rect(ci,-2,0,1,4,Color8(162,169,170))
		"cheese":
			rect(ci,-3,-2,6,4,Color8(236,224,177))
			rect(ci,-2,-3,4,1,Color8(254,246,211))
			rect(ci,1,-1,1,1,Color8(186,166,110))
			rect(ci,-2,1,1,1,Color8(196,177,123))
		"churchkhela":
			rect(ci,0,-8,1,3,Color8(195,166,114))
			for bead in range(5):
				rect(ci,-2,-5+bead*2,4,2,Color8(115,54,48))
				rect(ci,-1,-5+bead*2,2,1,Color8(167,92,70))
			rect(ci,-1,5,2,2,Color8(91,40,40))
		"parcel":
			rect(ci,-5,-3,10,6,Color8(222,210,175))
			rect(ci,-4,-4,8,2,Color8(244,232,196))
			rect(ci,-4,2,8,1,Color8(159,141,104))
			rect(ci,-1,-3,1,6,Color8(151,116,72))
			rect(ci,-5,0,10,1,Color8(151,116,72))
		"spice_cone":
			rect(ci,-3,-4,6,3,Color8(220,204,165))
			rect(ci,-2,-1,4,3,Color8(205,184,140))
			rect(ci,-1,2,2,2,Color8(180,154,110))
			rect(ci,-2,-5,4,2,Color8(184,99,41))
			rect(ci,-2,-5,1,1,Color8(233,172,66))
		"tower_charm":
			for step in range(7):
				var half: float=1.0 if step<3 else float(step-2)
				rect(ci,-half,-7+step,half*2,1,Color8(171,130,65))
			rect(ci,-1,-2,2,3,Color8(37,40,47))
			rect(ci,-4,0,3,1,Color8(218,181,102))
			rect(ci,1,0,3,1,Color8(218,181,102))
		"portrait":
			rect(ci,-4,-5,8,10,Color8(229,218,187))
			rect(ci,-2,-3,4,4,Color8(75,65,63))
			rect(ci,-1,-2,2,2,Color8(229,218,187))
			rect(ci,-3,2,6,1,Color8(75,65,63))
		"loaf":
			rect(ci,-5,-1,10,3,Color8(157,94,48))
			rect(ci,-4,-3,8,4,Color8(199,140,70))
			rect(ci,-3,-4,6,2,Color8(224,175,100))
			for x in [-2,1]:
				rect(ci,x,-3,1,2,Color8(247,214,155))
			rect(ci,-4,1,8,1,Color8(132,77,43))
		"apple", "tomato":
			rect(ci,-2,-2,4,4,RED)
			rect(ci,-1,-3,2,1,RED.lightened(.18))
			rect(ci,0,-4,.7,2,WOOD)
			rect(ci,.5,-4,1.5,1,GREEN)
		"bottle":
			rect(ci,-1,-4,2,6,GREEN.darkened(.35))
			rect(ci,-.5,-6,1,2,GREEN)
			rect(ci,-1,-1,2,1.5,PALE)
		"simit":
			ci.draw_arc(Vector2.ZERO,2.5,0,TAU,12,EDGE,1.6,false)
			for i in range(8):
				var p := Vector2.from_angle(i*TAU/8)*2.5
				rect(ci,p.x,p.y,.6,.6,PALE)
		"card":
			rect(ci,-2,-1.5,4,2.5,BLUE)
			rect(ci,-1.5,-1,1.5,.6,GOLD)
		"bag":
			rect(ci,-3,-2,6,6,EDGE)
			ci.draw_arc(Vector2(0,-2),1.5,PI,TAU,8,WOOD,.6,false)
		"potato_bag":
			rect(ci,-5,-3,10,8,Color8(176,137,83))
			rect(ci,-4,3,8,2,Color8(137,99,60))
			for p in [Vector2(-3,-3),Vector2(0,-4),Vector2(3,-2)]:
				rect(ci,p.x-1,p.y-1,3,3,Color8(214,179,114))
				rect(ci,p.x,p.y,1,1,Color8(128,89,55))
			rect(ci,-4,-5,1,3,EDGE)
			rect(ci,3,-5,1,3,EDGE)
			rect(ci,-4,-6,8,1,EDGE)
		"api":
			rect(ci,-3,-5,6,9,Color8(155,184,192))
			rect(ci,-2,-4,4,7,Color8(95,49,91))
			rect(ci,-2,-4,4,1,Color8(151,88,124))
			rect(ci,-2,3,4,1,PALE)
			rect(ci,-3,-4,1,6,Color8(213,223,218))
			for i in range(2):
				var rise: float = fposmod(t*3+float(i)*4,8)
				rect(ci,-1+i*2,-6-rise,1,2,Color(.85,.84,.78,(1-rise/8)*.5))
	ci.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)

static func _encounter_object(ci: CanvasItem, kind: String, t: float) -> void:
	match kind:
		"apple_crate":
			ci.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			ci.draw_texture_rect(ITEM_ART.apple_crate(),Rect2(-17,-19,34,20),false)
			rect(ci,-11,-8,23,5,PALE)
			ci.draw_string(ThemeDB.fallback_font,Vector2(-10,-4),"ZU VERSCHENKEN",HORIZONTAL_ALIGNMENT_LEFT,21,3,INK)
		"card_machine":
			rect(ci,-15,-47,30,47,BLUE.darkened(.15))
			rect(ci,-13,-45,26,4,BLUE)
			rect(ci,-10,-37,20,17,INK)
			rect(ci,-8,-35,16,13,METAL.lightened(.5))
			rect(ci,-5,-31,10,6,BLUE)
			rect(ci,-3,-30,3,2,GOLD)
			rect(ci,5,-15,6,2,INK)
			rect(ci,-10,-17,10,3,GOLD)
			rect(ci,-9,-7,18,4,INK)
		"bottle_ledge":
			rect(ci,-20,-12,40,12,METAL.darkened(.4))
			rect(ci,-22,-15,44,3,METAL)
			for i in range(9):
				rect(ci,-19+i*4,-23,2.5,8,GREEN.darkened(.35))
				rect(ci,-18.4+i*4,-26,1.3,3,GREEN)
		"market_stall", "fish_stall", "simit_cart":
			table(ci,54)
			for x in [-27,25]:rect(ci,x,-54,2,43,WOOD)
			rect(ci,-30,-57,60,5,RED if kind=="simit_cart" else GREEN)
			for i in range(10):rect(ci,-30+i*6,-52,6,5,PALE if i%2 else (RED if kind=="simit_cart" else GREEN))
			if kind=="fish_stall":
				rect(ci,-25,-17,50,4,PALE)
				for i in range(5):
					var x: float = -21+i*9
					ITEM_ART.draw_fitted(ci,Rect2(x-2,-22,9,6),"yoff_fish")
			elif kind=="simit_cart":
				for i in range(6): ITEM_ART.draw_fitted(ci,Rect2(-24+i*8,-21,7,7),"simit")
				for x in [-20,15]:rect(ci,x,-1,5,4,INK)
			else:
				for i in range(12):
					ITEM_ART.draw_fitted(ci,Rect2(-24+(i%6)*8,-21-(i/6)*4,6,7),"apple" if i%2 else "tomatoes")

static func _keg(ci: CanvasItem, t: float) -> void:
	# Bia hoi is a thick straight-sided glass, not a Turkish tea glass.
	rect(ci, 20, -25, 17, 25, METAL.darkened(0.20))
	rect(ci, 23, -27, 11, 2, METAL)
	rect(ci, 23, -23, 3, 22, METAL.lightened(0.3))
	for y in [-20,-6]:rect(ci,20,y,17,2,INK)
	rect(ci, 18, -20, 6, 2, INK)
	rect(ci, 18, -18, 2, 4, METAL)
	table(ci, 26)
	for x in [-8,0,8]:
		rect(ci,x,-20,5,7,Color8(146,180,145))
		rect(ci,x+1,-18,3,4,GOLD)
		rect(ci,x+1,-20,3,1,PALE)
	for i in range(3):
		rect(ci,-31,-4-i*3,13,2,BLUE)
		rect(ci,-30,-2-i*3,2,3,BLUE.darkened(0.2))
		rect(ci,-21,-2-i*3,2,3,BLUE.darkened(0.2))

static func _tabletop(ci: CanvasItem, kind: String, t: float, city: String) -> void:
	table(ci, 36)
	match kind:
		"tea":
			rect(ci,-13,-16,27,2,METAL)
			for x in [-10,-2,6]:
				rect(ci,x,-22,5,6,RED)
				rect(ci,x+1,-20,3,2,GOLD)
				rect(ci,x-1,-16,7,1,PALE)
		"bottles":
			for x in [-12,-3,6]:
				rect(ci,x,-27,5,14,GREEN.darkened(0.3))
				rect(ci,x+1,-31,3,4,GREEN)
				rect(ci,x,-21,5,4,PALE)
		"bread":
			for x in [-13,-3,7]:
				ITEM_ART.draw_fitted(ci,Rect2(x,-21,9,8),"bread")
		"cheese":
			for x in [-13,0]:
				ITEM_ART.draw_fitted(ci,Rect2(x,-23,13,10),"cheese")
		"fruit":
			for i in range(7):
				ITEM_ART.draw_fitted(ci,Rect2(-14+i*4,-20-(i%2)*3,6,7),"apple")
		"trays":
			for x in [-15,-4,7]:
				rect(ci,x,-17,10,4,METAL)
				rect(ci,x+1,-18,8,2,RED if x<0 else GOLD)
			for i in range(3):rect(ci,21,-13-i*2,10,1,PALE)
		"chess":
			for y in range(4):
				for x in range(8):rect(ci,-12+x*3,-17+y,3,1,PALE if (x+y)%2 else INK)
			for x in [-9,-3,6]:
				rect(ci,x,-21,2,4,INK)
				rect(ci,x+2,-19,2,3,PALE)
		_:
			rect(ci,-15,-16,30,3,INK)
			for i in range(9):
				var x: int = -13 + (i % 5) * 6
				var y: int = -19 - (i / 5) * 5
				rect(ci,x,y,3,3,GOLD if kind=="jewellery" else RED if i%2 else METAL)
				if kind=="souvenirs":rect(ci,x+1,y-5,1,5,METAL)

static func _kitchen(ci: CanvasItem, kind: String, t: float) -> void:
	table(ci,36)
	if kind=="mill":
		rect(ci,-10,-23,21,10,METAL.darkened(0.22))
		rect(ci,-8,-27,17,5,METAL)
		rect(ci,-1,-31,3,5,WOOD)
		rect(ci,roundf(sin(t*1.4)*8),-27,2,5,INK)
		rect(ci,13,-18,7,5,PALE)
	elif kind=="copperpot":
		rect(ci,-11,-28,23,15,Color8(161,102,59))
		rect(ci,-8,-26,4,11,Color8(218,161,91))
		rect(ci,-13,-29,27,3,GOLD)
		rect(ci,-16,-25,4,7,WOOD)
	else:
		rect(ci,-15,-22,30,9,INK)
		rect(ci,-13,-21,26,2,METAL)
		for i in range(5):
			rect(ci,-11+i*5,-24,4,3,GOLD if kind=="griddle" else WOOD)
		if kind=="griddle":
			rect(ci,17,-20,10,2,PALE)
			rect(ci,17,-17,10,2,PALE)
		else:
			for i in range(5):rect(ci,-10+i*5,-36,1,15,RED)
	for i in range(4):
		var rise: float = fposmod(t*5.0+i*6,22)
		rect(ci,-9+i*6+roundf(sin(rise*.3)), -26-rise,2,4,Color(0.86,0.87,0.80,(1.0-rise/22)*0.5))

static func _workshop(ci: CanvasItem, kind: String, t: float) -> void:
	if kind=="amp":
		rect(ci,-15,-24,22,24,INK)
		rect(ci,-12,-17,16,13,METAL.darkened(.5))
		for i in range(6):rect(ci,-11,-16+i*2,14,1,INK)
		for x in [-10,-5,0]:rect(ci,x,-22,2,2,GOLD)
		rect(ci,17,-31,2,31,METAL)
		rect(ci,15,-33,7,3,INK)
		rect(ci,10,-1,17,1,METAL)
		return
	if kind=="shoeshine":
		rect(ci,-15,-12,30,12,WOOD)
		rect(ci,-11,-15,8,3,EDGE)
		rect(ci,5,-15,8,3,EDGE)
		for i in range(4):rect(ci,-11+i*7,-8,4,3,INK)
		return
	table(ci,38)
	match kind:
		"sewing":
			rect(ci,-13,-27,22,4,INK)
			rect(ci,-13,-23,5,10,INK)
			rect(ci,4,-23,5,8,INK)
			rect(ci,-11,-17,27,4,BLUE)
			rect(ci,5,-15,2,2+int(t*8)%2,METAL)
			rect(ci,-14,-29,4,2,GOLD)
			rect(ci,-6,-3,16,2,INK)
		"lathe":
			rect(ci,-15,-21,30,7,GREEN)
			rect(ci,-15,-28,10,8,GREEN.darkened(.2))
			rect(ci,8,-26,7,6,GREEN.darkened(.2))
			rect(ci,-6,-25,15,3,METAL)
			rect(ci,-2+int(t*8)%4,-25,1,3,PALE)
		"organ":
			rect(ci,-16,-35,32,22,WOOD)
			rect(ci,-13,-32,26,15,EDGE)
			for x in range(7):rect(ci,-11+x*4,-30,2,11,WOOD)
			rect(ci,16,-26,6,2,METAL)
			rect(ci,20,-27+roundf(sin(t*2)*3),3,5,INK)
		_:
			rect(ci,-15,-27,30,12,WOOD.darkened(.15))
			for i in range(6):
				rect(ci,-12+i*5,-25,1,7,METAL)
				rect(ci,-13+i*5,-26,3,2,GOLD if i%2 else METAL)
			rect(ci,8,-17,8,3,INK)
			rect(ci,-7,-15,8,2,PALE)

static func _goods(ci: CanvasItem, kind: String) -> void:
	if kind=="kiosk":
		rect(ci,-23,-43,46,43,BLUE.darkened(.3))
		rect(ci,-25,-46,50,4,BLUE)
	for row in range(2 if kind=="crate" else 3):
		for col in range(3):
			var x: int = -23+col*16
			var y: int = -3-row*11
			rect(ci,x,y-8,15,10,WOOD)
			rect(ci,x+1,y-7,13,6,INK)
			rect(ci,x,y,15,2,EDGE)
			if kind in ["produce","kiosk"]:
				for j in range(3): ITEM_ART.draw_fitted(ci,Rect2(x+1+j*4,y-7,5,6),"apple" if (row+col)%2 else "tomatoes")
			elif kind=="books":
				for j in range(4):rect(ci,x+1+j*3,y-6,2,6,[RED,BLUE,PALE,GREEN][(col+j)%4])
			elif kind=="salvage":
				rect(ci,x+3,y-6,8,5,METAL)
				rect(ci,x+5,y-5,4,3,INK)
			else:
				rect(ci,x+4,y-6,7,6,PALE if row else BLUE)

static func _display(ci: CanvasItem, kind: String, t: float) -> void:
	if kind in ["tablet","museum","memorial","map"]:
		rect(ci,-20,-6,40,6,METAL.darkened(.15))
		rect(ci,-16,-39,32,33,METAL)
		rect(ci,-13,-36,26,22,PALE if kind=="map" else INK.lightened(.12))
		for i in range(6):rect(ci,-10,-33+i*3,20-(i%3)*3,1,BLUE if kind=="map" else METAL)
		if kind=="tablet":
			rect(ci,-23,-7,46,5,GREEN.darkened(.3))
			rect(ci,21,-8,6,3,GREEN)
		if kind!="memorial":
			return
	else:
		table(ci)
	for i in range(7):
		var x: int = -19+i*6
		var y: int = -2 if kind=="memorial" else -15
		if kind=="candles":
			rect(ci,x,y-13,3,13,PALE)
			rect(ci,x+1,y-15,1,2,GOLD.lightened(.3))
		else:
			rect(ci,x,y-7,1,7,GREEN)
			rect(ci,x-2,y-10,5,4,[PALE,RED,GOLD][i%3])
			rect(ci,x-1,y-11,3,6,[RED,GOLD,PALE][i%3])

static func _cloth(ci: CanvasItem, kind: String, t: float) -> void:
	if kind in ["fabric","scarves"]:
		table(ci,40)
		for i in range(5):
			rect(ci,-17+i*7,-29+(i%2)*3,8,16,[RED,BLUE,GOLD,GREEN,PALE][i])
			for j in range(3):rect(ci,-15+i*7,-26+j*4+(i%2)*3,4,1,PALE)
		return
	var top: float = -43.0
	if kind=="curtain":
		rect(ci,-21,-48,42,48,INK)
	else:
		rect(ci,-26,top,2,43,WOOD)
		rect(ci,24,top,2,43,WOOD)
	rect(ci,-26,top,52,2,WOOD)
	for i in range(5):
		var x: float = -23+i*10
		var shift: float = roundf(sin(t*1.5+i*.7))
		var color: Color = [PALE,BLUE,RED,PALE,GREEN][i]
		if kind=="curtain":color=BLUE
		rect(ci,x,top+2,9,24, color)
		rect(ci,x+shift,top+26,9,4,color.darkened(.12))
		rect(ci,x+2,top+4,2,22,color.lightened(.12))

static func _water(ci: CanvasItem, kind: String, t: float) -> void:
	if kind=="watertank":
		rect(ci,-19,-52,38,38,WOOD)
		for i in range(8):rect(ci,-18+i*5,-50,1,34,EDGE)
		for y in [-47,-23]:rect(ci,-20,y,40,2,INK)
		rect(ci,-22,-56,44,4,INK)
		rect(ci,-16,-14,3,14,INK)
		rect(ci,13,-14,3,14,INK)
	elif kind=="bath":
		for i in range(7):rect(ci,-26+i*3,-3-i*4,52-i*6,4,WOOD)
		for i in range(5):
			var y: float = fposmod(t*4+i*6,25)
			rect(ci,roundf(sin(y*.2)*3),-32-y,4,5,Color(.85,.87,.83,(1-y/25)*.35))
		return
	elif kind=="watersteps":
		for i in range(5):rect(ci,-21+i*3,-5-i*3,42-i*6,3,WOOD)
		rect(ci,-15,-29,2,22,METAL)
		rect(ci,13,-29,2,22,METAL)
	else:
		rect(ci,-22,-10,44,10,METAL.darkened(.2))
		rect(ci,-19,-13,38,4,METAL)
		rect(ci,-17,-10,34,3,BLUE)
		rect(ci,-4,-34,8,24,GREEN.darkened(.25))
		rect(ci,-7,-36,14,4,GREEN)
		rect(ci,3,-26,9,3,METAL)
	for i in range(5):
		var y: float = fposmod(t*10+i*4,18)
		rect(ci,10,-24+y,1,3,PALE)
		rect(ci,-13+i*6,-8,3+int(sin(t+i)*2),1,PALE)

static func _paint(ci: CanvasItem, kind: String, t: float) -> void:
	if kind=="paint":
		rect(ci,-31,-45,62,45,METAL.darkened(.3))
		for i in range(8):rect(ci,-27+i*7,-40+(i%3)*10,6,20,[BLUE,RED,GOLD][i%3])
	else:
		for x in [-16,14]:rect(ci,x,-47,3,47,WOOD)
		for i in range(6):rect(ci,-13,-8-i*7,28,2,EDGE)
		if kind=="easel":
			rect(ci,-22,-44,44,29,WOOD)
			rect(ci,-19,-41,38,23,PALE)
			rect(ci,-7,-37,11,10,BLUE)
			rect(ci,-11,-27,20,6,GREEN)
	for i in range(4):
		rect(ci,21+i*6,-6,5,6,METAL)
		rect(ci,21+i*6,-7,5,2,[RED,GOLD,BLUE,GREEN][i])

static func _outdoors(ci: CanvasItem, kind: String, t: float) -> void:
	match kind:
		"surfboard":
			for i in range(2):
				var x: int = -15+i*20
				rect(ci,x,-38,9,34,PALE if i else BLUE)
				rect(ci,x+2,-44,5,6,PALE if i else BLUE)
				rect(ci,x+2,-4,5,4,PALE if i else BLUE)
				rect(ci,x+4,-38,1,34,GOLD)
		"flags":
			for x in [-70,70]:
				rect(ci,x,-48,2,48,WOOD)
				rect(ci,x+2,-47,16,7,RED)
				rect(ci,x+2,-40,16,7,GOLD)
				rect(ci,x+18,-46+roundf(sin(t*2)),2,14,GOLD)
		"rope":
			for i in range(24):rect(ci,-43+i*4,-5+roundf(sin(i*.22+t*.8)*2),4,2,EDGE)
		"pigeons", "dogs":
			for i in range(5):
				var x: float = -28+i*12+roundf(sin(t*.7+i)*2)
				var color: Color = METAL if kind=="pigeons" else [WOOD,INK,PALE][i%3]
				rect(ci,x,-5-i%2*4,8,4,color)
				rect(ci,x+6,-8-i%2*4,4,5,color)
				rect(ci,x+2,-1-i%2*4,1,2,INK)
				rect(ci,x+6,-1-i%2*4,1,2,INK)
		"bicycle":
			for x in [-17,17]:
				ci.draw_arc(Vector2(x,-9),9,0,TAU,16,INK,2,false)
			ci.draw_polyline(PackedVector2Array([Vector2(-17,-9),Vector2(-5,-22),Vector2(8,-9),Vector2(-17,-9),Vector2(-5,-22),Vector2(12,-22),Vector2(17,-9)]),BLUE,2,false)
			rect(ci,-9,-25,9,2,INK)
			rect(ci,10,-28,8,2,INK)
		"shoes":
			for i in range(8):rect(ci,-24+(i%4)*13,-3-(i/4)*5,8,3,WOOD if i%2 else INK)
		_:
			rect(ci,-15,-17,30,17,WOOD)
			for i in range(5):rect(ci,-13,-15+i*3,26,1,EDGE)

static func _street(ci: CanvasItem, kind: String, t: float) -> void:
	match kind:
		"bins":
			for i in range(3):
				var x: int = -28+i*20
				rect(ci,x,-25,15,22,GREEN.darkened(.35))
				rect(ci,x-1,-28,17,3,BLUE if i==1 else GREEN)
				rect(ci,x+3,-21,9,2,PALE)
				rect(ci,x+2,-3,3,3,INK)
				rect(ci,x+10,-3,3,3,INK)
		"bench":
			for i in range(4):rect(ci,-28,-20+i*3,56,2,WOOD)
			rect(ci,-28,-7,56,3,EDGE)
			rect(ci,-24,-4,3,4,INK)
			rect(ci,21,-4,3,4,INK)
		"steps":
			for i in range(5):rect(ci,-28+i*3,-4-i*4,56-i*6,4,METAL.lightened(i*.03))
		"turnstile":
			for x in [-24,0,24]:
				rect(ci,x,-28,9,28,METAL)
				rect(ci,x+2,-25,5,4,GOLD)
				var opening: float = clampf((t-0.55)/1.2,0.0,1.0)
				rect(ci,x+9,-14,maxf(2,12-opening*10),2,INK)
				rect(ci,x+10,-14,2,opening*10,INK)
		"gate":
			for x in [-30,26]:rect(ci,x,-55,4,55,WOOD)
			rect(ci,-30,-58,60,4,WOOD)
			rect(ci,-25,-52,20,52,GREEN.darkened(.2))
			rect(ci,7,-52,17,52,GREEN)
			rect(ci,8,-25,2,3,GOLD)
		_:
			for x in [-30,-10,10,30]:rect(ci,x,-28,3,28,METAL)
			rect(ci,-30,-26,63,2,RED if kind=="queue" else METAL)
			if kind=="railing":rect(ci,-30,-14,63,2,METAL)

static func _istanbul_tram(ci: CanvasItem, t: float) -> void:
	# A separate moving carriage; the street artwork leaves its track empty.
	var red := Color8(161, 48, 43)
	var cream := Color8(234, 220, 183)
	var shadow := Color8(87, 38, 36)
	# Stepped roof, underframe and steel wheel hubs share a one-unit grid.
	rect(ci,-42,-43,84,37,INK)
	rect(ci,-45,-39,90,30,shadow)
	rect(ci,-43,-40,86,31,red)
	rect(ci,-40,-45,80,3,Color8(102,105,96))
	rect(ci,-36,-47,72,2,Color8(148,151,132))
	rect(ci,-41,-42,82,3,cream)
	rect(ci,-43,-13,86,2,cream)
	rect(ci,-43,-9,86,2,Color8(190,161,113))
	rect(ci,-39,-6,78,3,INK)
	for x in [-29,24]:
		rect(ci,x,-5,8,5,INK)
		rect(ci,x+1,-4,6,4,Color8(76,85,89))
		rect(ci,x+3,-3,2,2,METAL)
		var spoke: float = fmod(floorf(t*8),2)
		rect(ci,x+2+spoke,-4,1,3,Color8(158,165,157))
	# Recessed oak window frames, restrained reflections, window-seat backs.
	for x in [-31,-18,-5,8,21]:
		rect(ci,x,-37,11,20,shadow)
		rect(ci,x+1,-36,9,17,Color8(172,122,73))
		rect(ci,x+2,-35,7,14,Color8(44,63,73))
		rect(ci,x+2,-35,2,12,Color8(90,130,139))
		rect(ci,x+5,-34,3,4,Color8(111,148,150))
		rect(ci,x+2,-25,7,1,Color8(155,168,157))
		rect(ci,x+3,-23,5,2,Color8(93,67,46))
		rect(ci,x,-18,11,1,cream)
	# Cab vestibule and folding door, handrail and small working lamps.
	rect(ci,-42,-37,9,29,shadow)
	rect(ci,-40,-35,5,15,Color8(70,104,115))
	rect(ci,-38,-35,1,26,cream)
	rect(ci,-43,-8,11,2,Color8(97,106,106))
	for y in [-29,-21]:rect(ci,-44,y,1,7,cream)
	rect(ci,35,-36,7,14,Color8(41,58,64))
	rect(ci,36,-35,2,11,Color8(108,149,152))
	rect(ci,39,-18,3,3,Color8(245,211,140))
	rect(ci,-43,-17,2,2,Color8(242,185,102))
	for x in range(-26,31,10):
		rect(ci,x,-14,1,1,Color8(231,166,108))
	rect(ci,-4,-12,10,4,shadow)
	rect(ci,-2,-11,6,2,cream)
	# Diamond collector: articulated metal, no unconnected floating triangle.
	ci.draw_polyline(PackedVector2Array([Vector2(-10,-47),Vector2(2,-59),Vector2(16,-47),Vector2(3,-41),Vector2(-10,-47)]),INK,1,false)
	rect(ci,-4,-60,14,1,Color8(66,69,65))

static func _transport(ci: CanvasItem, kind: String, t: float, city: String) -> void:
	if kind == "tram" and city == "istanbul":
		_istanbul_tram(ci, t)
		return
	if kind=="handcart":
		rect(ci,-22,-10,39,4,WOOD)
		rect(ci,16,-33,3,28,METAL)
		for x in [-18,10]:rect(ci,x,-5,6,6,INK)
		for y in [-19,-29]:
			rect(ci,-20,y,34,9,EDGE)
			rect(ci,-17,y+3,28,1,WOOD)
		return
	if kind=="cablecar":
		rect(ci,-26,-48,52,2,INK)
		rect(ci,-1,-46,2,10,METAL)
		rect(ci,-17,-35,34,32,RED)
		rect(ci,-14,-31,28,18,BLUE.darkened(.5))
		rect(ci,-1,-31,2,27,METAL)
		rect(ci,-17,-4,34,4,INK)
		return
	var color: Color = GOLD if city=="berlin" else GREEN if kind=="ferry" else RED
	if kind=="ferry":
		rect(ci,-37,-13,74,8,color)
		rect(ci,-33,-5,66,5,INK)
		rect(ci,-25,-32,50,19,PALE)
		rect(ci,-14,-38,28,6,PALE)
	else:
		rect(ci,-38,-36,76,33,color)
		rect(ci,-38,-13,76,2,color.lightened(.25))
		rect(ci,-38,-8,76,3,PALE)
		rect(ci,-38,-39,76,4,PALE)
		rect(ci,-33,-3,10,3,INK)
		rect(ci,23,-3,10,3,INK)
	for i in range(6):
		rect(ci,-31+i*11,-29,8,13,INK)
		rect(ci,-30+i*11,-28,6,10,BLUE.darkened(.35))
		rect(ci,-30+i*11,-28,2,10,BLUE)
		rect(ci,-30+i*11,-17,6,1,PALE)
	if kind=="tram":
		ci.draw_polyline(PackedVector2Array([Vector2(-6,-39),Vector2(8,-50),Vector2(22,-39)]),INK,1,false)
		rect(ci,0,-51,17,1,INK)
	if kind=="ferry":
		rect(ci,-18,-43,5,11,INK)
		rect(ci,-19,-45,7,2,RED)
		for i in range(5):rect(ci,-26+i*12,-4,7,1,METAL)
	if kind!="ferry":
		rect(ci,-4,-29,8,25,PALE)
		rect(ci,-1,-28,1,24,INK)
