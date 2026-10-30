extends Node2D

# How many people are on this street.
#
# Every district held exactly one person, everywhere, which made Ameyoko and a
# Zurich suburb the same place with different shopfronts. A city's texture is
# mostly its density, and getting that wrong flattens twenty cities into one.
#
# ── The scale ────────────────────────────────────────────────────────────────
#
# Anchored on the two the numbers are actually published for, and scaled from
# there by what each district is:
#
#   Grand Bazaar, Istanbul   ~400,000 a day, 700-800k at a weekend   -> 16
#   Times Square, New York   ~330,000 a day, 460k at its busiest     -> 14
#
# Everything else is placed against those two by what the district is FOR: a
# wholesale market that a city buys its food from is not a residential terrace
# and should never look like one. A quiet number is a real answer - Yanaka is
# quiet, Coyoacan is quiet on a weekday, and drawing a crowd into them would
# be the same mistake in the other direction.
const DENSITY := {
# ── the crush ────────────────────────────────────────────────────────────────
"istanbul:carsi": 16, "newyork:midtown": 14, "tokyo:ueno": 13,
"mumbai:bhuleshwar": 13, "mexico:merced": 12, "london:soho": 12,
"seoul:jongno": 12, "hanoi:phoco": 11, "tokyo:asakusa": 11,
"mumbai:colaba": 11, "istanbul:beyoglu": 11, "paris:montmartre": 10,
"saopaulo:paulista": 10, "dakar:sandaga": 10, "rome:monti": 9,
"mexico:centro": 9, "moscow:kitaygorod": 9, "seoul:hongdae": 9,
"mumbai:chorbazaar": 9, "saopaulo:mercadao": 9, "lapaz:elalto": 9,
# ── busy, and working ────────────────────────────────────────────────────────
"istanbul:kadikoy": 8, "london:brixton": 8, "paris:marais": 8,
"tbilisi:dezerter": 8, "rome:esquilino": 8, "mexico:juarez": 7,
"newyork:jacksonheights": 8, "toronto:kensington": 7, "hanoi:longbien": 7,
"tokyo:jinbocho": 6, "seoul:euljiro": 7, "dakar:medina": 8,
"mumbai:byculla": 7, "moscow:izmaylovo": 7, "lapaz:rodriguez": 8,
"saopaulo:liberdade": 7, "berlin:mitte": 7, "sydney:cbd": 7,
"honolulu:waikiki": 7, "toronto:downtown": 7, "zurich:niederdorf": 6,
"paris:ladefense": 7, "london:highstreet": 6, "newyork:lowereast": 6,
# ── ordinary ─────────────────────────────────────────────────────────────────
"berlin:kreuzberg": 6, "istanbul:karakoy": 6, "rome:trastevere": 6,
"moscow:arbat": 6, "paris:belleville": 6, "seoul:mangwon": 5,
"tbilisi:sololaki": 5, "mexico:roma": 5, "saopaulo:bixiga": 5,
"hanoi:dongda": 5, "sydney:newtown": 5, "toronto:gerrard": 5,
"newyork:williamsburg": 5, "honolulu:chinatown": 5, "zurich:langstrasse": 5,
"london:terrace": 4, "berlin:prenzlberg": 4, "tokyo:yanaka": 4,
"moscow:basmanny": 4, "istanbul:han": 5, "mumbai:bandra": 5,
"mexico:condesa": 4, "paris:champdemars": 6, "rome:testaccio": 5,
"seoul:seongsu": 5, "tbilisi:avlabari": 4, "lapaz:sanpedro": 5,
"saopaulo:vilamadalena": 4, "dakar:plateau": 5, "hanoi:badinh": 4,
"sydney:circularquay": 6, "toronto:distillery": 4, "newyork:harlem": 5,
"honolulu:kakaako": 4, "zurich:zurichwest": 4, "berlin:ost": 4,
# ── quiet, and that is the answer ────────────────────────────────────────────
"tokyo:shinbashi": 5, "london:docklands": 3, "mexico:coyoacan": 4,
"moscow:zamoskvorechye": 3, "istanbul:carsi_han": 3, "rome:garbatella": 3,
"paris:opera": 3, "tbilisi:saburtalo": 3, "tbilisi:chugureti": 3,
"lapaz:sopocachi": 3, "lapaz:irpavi": 2, "saopaulo:higienopolis": 3,
"dakar:ouakam": 3, "dakar:yoff": 4, "hanoi:tayho": 3,
"sydney:bondi": 4, "sydney:cabramatta": 4, "toronto:scarborough": 3,
"newyork:queens": 3, "honolulu:manoa": 2, "honolulu:northshore": 2,
"zurich:seefeld": 2, "zurich:oerlikon": 3, "berlin:kiez": 1,
"seoul:mangwon2": 3, "mumbai:worli": 3, "tokyo:nakameguro": 4,
}

# What a district nobody measured gets. Four is an ordinary street with a few
# people on it, which is the safest thing to be wrong about.
const DEFAULT := 4


const CHAR := preload("res://scenes/npc/CharacterArt.gd")
const NOTEBOOK := preload("res://scenes/ui/Notebook.gd")
# What a street says, per language and per hour. It used to be three
# fragments per language in this file, one of them a greeting nailed to
# "morning", so a crowd said good morning to each other at midnight in
# twenty cities and taught about eight words in each.
const CHATTER := preload("res://scenes/npc/Chatter.gd")

# The band people actually walk on, in plate coordinates.
#
# CityArt lays a street out as: sky to 292, pavement 292-372, road 372-516,
# far pavement 516-648. This band is inside the ROAD, which sounds wrong and
# is not: almost every street in this game is a lane, a bazaar, a market row
# or a han courtyard rather than a carriageway, the player spawns at 430 in
# nearly all of them, and the WorldBorder lets him walk 300-640. The crowd
# shares the player's lane on purpose. The comment here used to say
# "pavement", which is the one thing it is not.
const WALK_TOP := 402.0
const WALK_BOT := 462.0
# How far a walker will shove sideways to get round something, and how fast
# they drift back to the line they were walking once it is behind them.
const DODGE := 34.0
const SETTLE := 26.0
const LEFT := -40.0
const RIGHT := 1192.0

# Which district this is, handed over when the crowd is attached. NOT read
# from GameState: current_region is set by the scene root's _ready, which has
# not run yet when the crowd is built, and does not run at all in a render
# tool - so the Grand Bazaar came out with three people in it.
var district: String = ""

var _folk: Array = []
# What this street has standing in it, so nobody walks through it.
var _solids: Array = []
var _t: float = 0.0
# Words already heard on this street, so standing next to one person for five
# minutes does not teach you their whole vocabulary. The street teaches; it
# cannot be farmed.
var _heard: Dictionary = {}
var _walk_top: float = WALK_TOP
var _walk_bot: float = WALK_BOT
var _visuals: Array[Node2D] = []
var _authored := false
var _navigation: AStarGrid2D
const GRID := 8


func _ready() -> void:
	z_index = 0
	y_sort_enabled = true
	_authored = bool(get_parent().get_meta("object_silhouettes",false))
	var bg := get_parent().get_node_or_null("Background")
	if bg == null:
		for child in get_parent().get_children():
			if child.has_method("floor_y"):
				bg = child
				break
	if bg != null and bg.has_method("floor_y"):
		_walk_top = float(bg.call("floor_y")) + 24.0
		_walk_bot = minf(_walk_top + 62.0, 615.0)
	_gather_solids()
	if _authored: _build_navigation(bg)
	_populate()
	for i in range(_folk.size()):
		var person := Node2D.new()
		person.name = "Walker" + str(i)
		add_child(person)
		person.draw.connect(_draw_walker.bind(person, i))
		_visuals.append(person)
	_update_visuals()


# What this street has standing in it, read off the collision the scene
# already declares rather than a second list that would drift away from it.
# Solids.gd builds these in its own _ready, and the crowd is attached by
# Interactables after the scene is in the tree, so they are there by now.
func _gather_solids() -> void:
	_solids.clear()
	var host := get_parent()
	if host == null:
		return
	for child in host.get_children():
		if not (child is StaticBody2D) or String(child.name) == "WorldBorder":
			continue
		# A person is not furniture. You may walk in front of Frau Amsler.
		if child.get("npc_id") != null or child.get("city") != null:
			continue
		for c in child.get_children():
			if c is CollisionShape2D and (c as CollisionShape2D).shape is RectangleShape2D:
				var cs: CollisionShape2D = c
				var sz: Vector2 = (cs.shape as RectangleShape2D).size
				_solids.append(Rect2(cs.global_position - sz * 0.5, sz))


func how_many() -> int:
	var r: String = district if not district.is_empty() else GameState.current_region
	return int(DENSITY.get(GameState.city + ":" + r, DEFAULT))


func _populate() -> void:
	var n: int = how_many()
	var city: String = GameState.city
	# Seeded off the district, so the same street has the same crowd in it
	# every time you walk down it rather than reshuffling behind your back.
	var rng := RandomNumberGenerator.new()
	rng.seed = int(abs(hash(city + district)))
	_folk.clear()
	for i in range(n):
		var standing: bool = rng.randf() < 0.28
		_folk.append({
			"chat_in": rng.randf_range(3.0, 22.0),
			"snip": -1,
			"chat_t": 0.0,
			"x": rng.randf_range(LEFT + 40.0, RIGHT - 40.0),
			"y": rng.randf_range(_walk_top, _walk_bot),
			"home_y": 0.0,
			"dir": 1.0 if rng.randf() < 0.5 else -1.0,
			"speed": rng.randf_range(15.0, 30.0),
			"seed": rng.randi() % 9973,
			"stand": standing,
			"look": CHAR.look(rng.randi() % 9973, city),
		})
	# Nobody starts inside the furniture. A walker who spawned in the Han's
	# fountain would spend the first second of the scene climbing out of it,
	# and a STANDING one would simply be in it for good.
	for f: Dictionary in _folk:
		if _authored:
			var cell := _nearest_cell(Vector2(float(f["x"]),float(f["y"])))
			f["x"]=float(cell.x*GRID)
			f["y"]=float(cell.y*GRID)
			f["home_y"]=f["y"]
			f["route"]=PackedVector2Array()
			continue
		for _try in range(6):
			var inside: bool = false
			for r: Rect2 in _solids:
				if r.has_point(Vector2(float(f["x"]), float(f["y"]))):
					f["y"] = r.end.y + 2.0 if float(f["y"]) > r.get_center().y 						else r.position.y - 2.0
					inside = true
					break
			if not inside:
				break
		f["y"] = clampf(float(f["y"]), _walk_top - DODGE, _walk_bot + DODGE)
		# The line this one is walking, and drifts back to after a dodge.
		f["home_y"] = float(f["y"])
	# Nearest last, so the ones down the street are behind the ones in front.
	_folk.sort_custom(func(a, b): return float(a["y"]) < float(b["y"]))


# How close you have to be to make out what somebody said in passing.
const EARSHOT := 210.0
# How long a fragment stays up. Long enough to read, short enough that a
# street is not a wall of speech bubbles.
const SAID_FOR := 3.4


func _process(delta: float) -> void:
	_t += delta
	var lang: String = GameState.local_language()
	var lines: Array = CHATTER.lines(lang, GameState.day_part())
	var player := get_tree().get_first_node_in_group("player") as Node2D
	for f: Dictionary in _folk:
		# Speech first: a person standing still talks as much as one walking.
		if int(f["snip"]) >= 0:
			f["chat_t"] = float(f["chat_t"]) + delta
			if float(f["chat_t"]) > SAID_FOR:
				f["snip"] = -1
				f["chat_in"] = randf_range(14.0, 40.0)
		elif not lines.is_empty():
			f["chat_in"] = float(f["chat_in"]) - delta * (0.55 if GameState.day_part() == "night" else 1.0)
			if float(f["chat_in"]) <= 0.0:
				f["snip"] = randi() % lines.size()
				f["spoken"] = lines[int(f["snip"])]
				f["chat_t"] = 0.0
				_overhear(f, lines, lang, player)
		if bool(f["stand"]):
			continue
		if _authored:
			_walk_clear_route(f,delta)
			continue
		f["x"] = float(f["x"]) + float(f["dir"]) * float(f["speed"]) * delta
		if float(f["x"]) > RIGHT:
			f["x"] = LEFT
		elif float(f["x"]) < LEFT:
			f["x"] = RIGHT
		_go_round(f, delta)
	_update_visuals()

func _build_navigation(bg: Node) -> void:
	_navigation=AStarGrid2D.new()
	var top := int(bg.call("floor_y"))+8
	_navigation.region=Rect2i(3,ceili(float(top)/GRID),138,(632-top)/GRID)
	_navigation.cell_size=Vector2(GRID,GRID)
	_navigation.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER
	_navigation.update()
	for y in range(_navigation.region.position.y,_navigation.region.end.y):
		for x in range(_navigation.region.position.x,_navigation.region.end.x):
			var at := Vector2(x*GRID,y*GRID)
			var feet := Rect2(at-Vector2(18,5),Vector2(36,10))
			for r: Rect2 in _solids:
				if r.intersects(feet):
					_navigation.set_point_solid(Vector2i(x,y),true)
					break

func _nearest_cell(at: Vector2) -> Vector2i:
	var best := Vector2i.ZERO
	var distance := INF
	for y in range(_navigation.region.position.y,_navigation.region.end.y):
		for x in range(_navigation.region.position.x,_navigation.region.end.x):
			var cell := Vector2i(x,y)
			if _navigation.is_point_solid(cell): continue
			var d := Vector2(cell*GRID).distance_squared_to(at)
			if d<distance:
				distance=d
				best=cell
	return best

func _walk_clear_route(f: Dictionary, delta: float) -> void:
	var route: PackedVector2Array=f["route"]
	var at := Vector2(float(f["x"]),float(f["y"]))
	if route.is_empty():
		var start := _nearest_cell(at)
		var target := _nearest_cell(Vector2(1110 if float(f["dir"])>0 else 24,float(f["home_y"])))
		route=_navigation.get_point_path(start,target)
		if route.size()<2:
			f["dir"]=-float(f["dir"])
			return
	# Advance along a prevalidated route. Never enter furniture then nudge out.
	var remaining := float(f["speed"])*delta
	while remaining>0 and not route.is_empty():
		var distance := at.distance_to(route[0])
		if distance<=remaining:
			at=route[0]
			route.remove_at(0)
			remaining-=distance
		else:
			at=at.move_toward(route[0],remaining)
			remaining=0
	f["x"]=at.x
	f["y"]=at.y
	f["route"]=route
	if route.is_empty(): f["dir"]=-float(f["dir"])


# Walk round the furniture instead of through it.
#
# This whole node draws itself and moves people by adding to x. It consulted
# nothing - no collision, no solids, no scene - so anybody whose lane crossed
# something solid went straight through it. barriers.gd says where that
# actually happens, and after the named people were excluded from it the
# answer was two places, both in the Han: the fountain in the middle of the
# courtyard and the tree's planter. Which is the busiest courtyard in the
# game, and the one Arda runs tea across all day.
#
# Deliberately not physics. A walker is nudged off their line while something
# is in front of them and drifts back to it once it is behind, which is what
# somebody crossing a courtyard actually does and costs one rect test each.
func _go_round(f: Dictionary, delta: float) -> void:
	if _solids.is_empty():
		return
	var at := Vector2(float(f["x"]), float(f["y"]))
	var home: float = float(f["home_y"])
	for r: Rect2 in _solids:
		if not r.has_point(at):
			continue
		# Out by the nearer edge, but never further than a stride, so
		# nobody teleports round a wide thing - they skirt it.
		var up: float = at.y - r.position.y
		var down: float = r.end.y - at.y
		var push: float = -1.0 if up < down else 1.0
		f["y"] = clampf(float(f["y"]) + push * DODGE * delta,
			home - DODGE, home + DODGE)
		return
	# Nothing in the way any more: come back to the line you were walking.
	if absf(float(f["y"]) - home) > 0.5:
		f["y"] = move_toward(float(f["y"]), home, SETTLE * delta)


# Each word counts once, and only if you were near enough to catch it.
func _overhear(f: Dictionary, lines: Array, lang: String,
		player: Node2D) -> void:
	if player == null:
		return
	var here := Vector2(float(f["x"]), float(f["y"]))
	if (to_global(here)).distance_to(player.global_position) > EARSHOT:
		return
	# Out loud, from where they are standing - a street is heard before it is
	# read, and a passer-by's "Tach." is the first German most people ever get.
	var said: PackedStringArray = []
	for part: Array in Array(lines[int(f["snip"])]):
		said.append(String(part[0]))
	AudioManager.murmur(lang, " ".join(said), to_global(here))
	# A stranger saying a word he found out somewhere else is the best kind of
	# second meeting: nobody arranged it.
	var journal := get_tree().get_first_node_in_group("journal")
	for part2: Array in Array(lines[int(f["snip"])]):
		if NOTEBOOK.recall(lang, String(part2[1]), "street|" + " ".join(said)) and journal != null:
			journal.toast_recognised(lang, String(part2[1]))
	for pair: Array in Array(lines[int(f["snip"])]):
		var word: String = String(pair[1])
		var key: String = lang + ":" + word
		if _heard.has(key):
			continue
		_heard[key] = true
		GameState.expose(lang, word, "hear")


func _update_visuals() -> void:
	for i in range(_visuals.size()):
		_visuals[i].position = Vector2(float(_folk[i]["x"]), float(_folk[i]["y"])-(22.0 if _authored else 0.0))
		_visuals[i].queue_redraw()

func _draw_walker(person: Node2D, index: int) -> void:
	var f: Dictionary = _folk[index]
	var lang: String = GameState.local_language()
	var act: String = "stand" if bool(f["stand"]) else "walk"
	var unit: float = CHAR.world_unit(self)
	var origin := Vector2(0,22) if _authored else Vector2.ZERO
	CHAR.draw_figure(person, origin, unit, f["look"], act, _t, int(f["seed"]))
	var si: int = int(f["snip"])
	if si >= 0 and f.has("spoken"):
		var left: float = SAID_FOR - float(f["chat_t"])
		CHAR.speech(person, origin+Vector2(0.0, -27.0 * unit),
			CHAR.snippet_text(f["spoken"], lang),clampf(left / 0.6, 0.0, 1.0))
