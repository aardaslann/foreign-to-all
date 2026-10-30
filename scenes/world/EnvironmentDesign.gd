class_name EnvironmentDesign
extends Node2D

const ACTIVITY_OBJECTS := preload("res://scenes/ui/ActivityObjects.gd")
const ITEM_ART := preload("res://scenes/world/ItemArt.gd")
const WORLD_OBJECT := preload("res://scenes/world/EnvironmentObject.gd")
const LETTERING := preload("res://scenes/world/EnvironmentLettering.gd")
const DAYLIGHT := preload("res://scenes/world/DayNightLighting.gd")

# A scene's approved architecture and its playable layout share one record.
# SceneExit and ServicePoint still own all behaviour; this only places them.
@export var scene_id: String = ""
var staging_only: bool = false
var design: Dictionary = {}
var _texture: Texture2D
var _source: Rect2
var _clock: float = 0.0
var _door_open: float = 0.0
var _door_hold: float = 0.0
var _foreground_layers: Array[Node2D] = []
var _vehicles: Array[Dictionary] = []
var _image: Image
var _motion_textures: Dictionary = {}
var _standing_floor: Dictionary = {}
const STANDING_STEP := 6
static var _catalog: Dictionary = {}

static func catalog() -> Dictionary:
	if _catalog.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(
			"res://art/environments/layouts.json"))
		if parsed is Dictionary:
			_catalog = parsed
		for detail_path: String in ["res://art/environments/fullsize.json", "res://art/environments/berlin-gameplay.json", "res://art/environments/istanbul-gameplay.json", "res://art/environments/city-gameplay.json", "res://art/environments/object-geometry.json", "res://art/environments/lettering.json"]:
			if not FileAccess.file_exists(detail_path):
				continue
			var detail: Variant = JSON.parse_string(FileAccess.get_file_as_string(detail_path))
			if detail is Dictionary:
				for id: String in detail:
					if _catalog.has(id):
						_catalog[id].merge(detail[id], true)
		# Activity-only rooms use the same renderer without adding world exits.
		var plates: Variant = JSON.parse_string(FileAccess.get_file_as_string(
			"res://art/environments/activity-plates.json"))
		if plates is Dictionary:
			_catalog.merge(plates, false)
		var city_plates_path := "res://art/environments/city-activity-plates.json"
		if FileAccess.file_exists(city_plates_path):
			var city_plates: Variant = JSON.parse_string(FileAccess.get_file_as_string(city_plates_path))
			if city_plates is Dictionary: _catalog.merge(city_plates,false)
	return _catalog

static func district_scene(city: String, region: String) -> String:
	for key: String in catalog():
		var row: Dictionary = catalog()[key]
		if String(row.get("city", "")) == city and String(row.get("district", "")) == region:
			return key
	return ""

func _scene_design() -> Dictionary:
	return catalog().get(scene_id, {})

func _ready() -> void:
	design = _scene_design()
	if design.is_empty():
		push_error("Missing environment design: " + scene_id)
		return
	_texture = load(String(design["texture"]))
	_image = _texture.get_image()
	# Full scene plates supply their own sky and floor. Some exported PNGs
	# carry unintended alpha there; object gaps are defined by geometry.
	if design.get("opaque_plate", false):
		_image.convert(Image.FORMAT_RGB8)
		_texture = ImageTexture.create_from_image(_image)
	var r: Array = design["source"]
	_source = Rect2(float(r[0]), float(r[1]), float(r[2]), float(r[3]))
	for layer: Dictionary in design.get("motion_layers", []):
		var path: String = String(layer.get("texture", ""))
		if not path.is_empty():
			_motion_textures[path] = load(path)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if design.get("pixel_art",false) else CanvasItem.TEXTURE_FILTER_LINEAR
	if design.has("district"):
		set("district", String(design["district"]))
	if not staging_only:
		_add_daylight.call_deferred()
		_place_gameplay()
		_add_foreground.call_deferred()
		_settle_legacy_spawn.call_deferred()

func indoors() -> bool:
	var place := preload("res://scenes/world/ActivityPlaces.gd").location(scene_id)
	if not place.is_empty(): return String(place.get("ambience", "street")) == "interior"
	return design.has("room")

func _add_daylight() -> void:
	if not is_inside_tree() or get_parent().has_node("DayNightLighting"): return
	var light := DAYLIGHT.new()
	light.name = "DayNightLighting"
	light.indoors = indoors()
	light.background = self
	get_parent().add_child(light)

func _plate_tint() -> Color:
	# Film staging has its own canvas; ordinary world scenes use one shared
	# CanvasModulate instead of tinting the foreground a second time.
	return GameState.CLOCK.tint(GameState.clock_minutes, GameState.city, indoors()) if staging_only else Color.WHITE

func _settle_legacy_spawn() -> void:
	if not is_inside_tree():
		return
	var player := get_parent().get_node_or_null("Player")
	if player == null:
		return
	var here: Vector2 = player.position
	if design.has("objects"):
		_settle_authored_spawn(player,here)
		return
	if _clear_standing(here):
		return
	var best := Vector2(float(design["spawn"][0]), float(design["spawn"][1]))
	var distance: float = INF
	for y in range(int(floor_y()) + 26, int(design.get("walk_bottom", 642)) - 33, 8):
		for x in range(36, 1125, 8):
			var candidate := Vector2(x, y)
			if _clear_standing(candidate) and candidate.distance_squared_to(here) < distance:
				distance = candidate.distance_squared_to(here)
				best = candidate
	player.position = best

func _standing_box_clear(at: Vector2, foot: Rect2, obstacles: Array) -> bool:
	var body := Rect2(at+foot.position,foot.size).grow(0.1)
	if body.position.x<12 or body.end.x>1140 or body.position.y<floor_y() or body.end.y>float(design.get("walk_bottom",642)):
		return false
	for r: Rect2 in obstacles:
		if r.intersects(body): return false
	return true

func _settle_authored_spawn(player: Node2D, here: Vector2) -> void:
	# A free rectangle can still be trapped behind a counter or between chair
	# and bin. Recover old saves onto the connected floor, without adding an
	# invisible wall or ejecting a valid position from a narrow passage.
	var cs := player.get_node("CollisionShape2D") as CollisionShape2D
	var size: Vector2=(cs.shape as RectangleShape2D).size
	var foot := Rect2(cs.position-size*.5,size)
	var obstacles := solids()
	if _standing_floor.is_empty():
		var clear: Dictionary = {}
		var start := Vector2i.ZERO
		var nearest := INF
		var spawn := Vector2(design["spawn"][0],design["spawn"][1])
		for y in range(floori((floor_y()-cs.position.y)/STANDING_STEP),ceili(float(design.get("walk_bottom",642))/STANDING_STEP)):
			for x in range(2,190):
				var cell := Vector2i(x,y)
				var at := Vector2(cell*STANDING_STEP)
				if not _standing_box_clear(at,foot,obstacles): continue
				clear[cell]=true
				if at.distance_squared_to(spawn)<nearest:
					nearest=at.distance_squared_to(spawn)
					start=cell
		if clear.is_empty(): return
		var queue: Array[Vector2i]=[start]
		_standing_floor[start]=true
		var index := 0
		while index<queue.size():
			var cell: Vector2i=queue[index]
			index+=1
			for direction: Vector2i in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
				var next := cell+direction
				if not clear.has(next) or _standing_floor.has(next): continue
				var delta := Vector2(direction*STANDING_STEP)
				var swept := Rect2(foot.position+delta.min(Vector2.ZERO),foot.size+delta.abs())
				if not _standing_box_clear(Vector2(cell*STANDING_STEP),swept,obstacles): continue
				_standing_floor[next]=true
				queue.append(next)
	var best := here
	var distance := INF
	for cell: Vector2i in _standing_floor:
		var at := Vector2(cell*STANDING_STEP)
		var d := at.distance_squared_to(here)
		if d<distance:
			distance=d
			best=at
	# Preserve the exact position if its feet can reach the neighbouring cell.
	var offset := best-here
	var swept := Rect2(foot.position+offset.min(Vector2.ZERO),foot.size+offset.abs())
	if distance<=2*STANDING_STEP*STANDING_STEP and _standing_box_clear(here,swept,obstacles): return
	player.position=best

func _clear_standing(at: Vector2) -> bool:
	# Keep valid saved positions in the narrow passages the real feet can use.
	# The former 22px expansion rejected them and moved the player on reload.
	var player := get_parent().get_node_or_null("Player")
	if design.has("objects") and player != null:
		var foot := player.get_node("CollisionShape2D") as CollisionShape2D
		var shape := foot.shape as RectangleShape2D
		if shape != null:
			return _standing_box_clear(at,Rect2(foot.position-shape.size*.5,shape.size),solids())
	if at.x < 28 or at.x > 1124 or at.y < floor_y() + 18 or at.y > float(design.get("walk_bottom", 642)) - 34:
		return false
	for r: Rect2 in solids():
		# Account for the complete foot collider and a small walking margin,
		# including above a table. The old asymmetric pad could spawn a player
		# just touching its back edge and leave them stuck on the first step.
		if r.grow(22.0).has_point(at + Vector2(0, 20)):
			return false
	return true

func floor_y() -> float:
	return float(design.get("floor", 490.0))

func _place_gameplay() -> void:
	var host := get_parent()
	if host == null:
		return
	host.set_meta("character_unit", 4.0)
	host.set_meta("object_silhouettes", design.has("objects"))
	var points: Dictionary = design.get("anchors", {})
	var street: bool = design.has("district")
	for n in host.get_children():
		if not (n is Node2D) or n == self:
			continue
		var prompt := n.get_node_or_null("Prompt") as CanvasItem
		var labels: Dictionary = design.get("prompt_overrides", {})
		if labels.has(String(n.name)) and n.get("prompt_text") != null:
			n.set("prompt_text",String(labels[String(n.name)]))
		if prompt != null:
			# Interaction text belongs above world silhouettes, including a
			# nearby gatepost when the player approaches from behind it.
			prompt.z_index = 10
		if points.has(String(n.name)):
			var xy: Array = points[String(n.name)]
			n.position = Vector2(float(xy[0]), float(xy[1]))
		elif street and (n.get("npc_id") != null or n.get("city") != null or n.get("encounter") != null or n.get("target_scene") != null or n.get("service") != null or n.name == &"Player"):
			n.position.y = remap(n.position.y, 300.0, 640.0, floor_y() + 6.0, 636.0)
		if n.get("encounter") != null and design.has("encounter_exit"):
			var route: Dictionary = design["encounter_exit"]
			n.set("leave_to", Vector2(route["to"][0],route["to"][1]))
			n.set("doorway_clearance",float(route.get("doorway_clearance",0.0)))
			var via := PackedVector2Array()
			for xy: Array in route.get("via", []): via.append(Vector2(xy[0],xy[1]))
			n.set("leave_via", via)
		if scene_id == "HotelLobby" and n.name == &"Receptionist":
			n.get_node("InteractionArea").position.y = 480.0 - n.position.y
		var offsets: Dictionary = design.get("interaction_offsets", {})
		if offsets.has(String(n.name)):
			for path: String in offsets[String(n.name)]:
				var part := n.get_node_or_null(path)
				var xy: Array = offsets[String(n.name)][path]
				if part != null:
					part.position = Vector2(float(xy[0]), float(xy[1]))
		var sizes: Dictionary = design.get("interaction_sizes", {})
		if sizes.has(String(n.name)):
			for path: String in sizes[String(n.name)]:
				var part := n.get_node_or_null(path) as CollisionShape2D
				var xy: Array = sizes[String(n.name)][path]
				if part != null:
					var shape := RectangleShape2D.new()
					shape.size = Vector2(float(xy[0]), float(xy[1]))
					part.shape = shape
		var clerks: Dictionary = design.get("clerks", {})
		if clerks.has(String(n.name)) and n.get("clerk") != null:
			var at: Array = clerks[String(n.name)]
			n.set("clerk", String(n.name) + "_" + scene_id)
			n.set("clerk_offset", Vector2(float(at[0]), float(at[1])) - n.position)
	var border := host.get_node_or_null("WorldBorder")
	if border != null:
		border.set("wall_top", floor_y())
		border.set("wall_bottom", float(design.get("walk_bottom", 642)))
		border.set("wall_left", 12.0)
		border.set("wall_right", 1140.0)
	if host.get("spawn") != null:
		var spawn: Array = design.get("spawn", [160, floor_y() + 75.0])
		host.set("spawn", Vector2(float(spawn[0]), float(spawn[1])))
	host.set("y_sort_enabled", true)

func _add_foreground() -> void:
	if not is_inside_tree():
		return
	for object: Dictionary in design.get("objects", []):
		var layer := Node2D.new()
		layer.set_script(WORLD_OBJECT)
		layer.set("background", self)
		layer.set("spec", object)
		layer.name = "Object_" + String(object["id"])
		get_parent().add_child(layer)
		_foreground_layers.append(layer)
	for a: Array in ([] if design.has("objects") else design.get("foreground", [])):
		var r := Rect2(float(a[0]), float(a[1]), float(a[2]), float(a[3]))
		var layer := Node2D.new()
		layer.name = "DesignForeground"
		layer.position.y = r.end.y - 16.0
		layer.texture_filter = texture_filter
		layer.material = material
		get_parent().add_child(layer)
		_foreground_layers.append(layer)
		layer.draw.connect(func(): _draw_foreground(layer, r))
		layer.queue_redraw()
	for a: Array in design.get("desks", []):
		var r := Rect2(float(a[0]), float(a[1]), float(a[2]), float(a[3]))
		var layer := Node2D.new()
		layer.name = "InformationDesk"
		layer.position.y = r.end.y - 16.0
		get_parent().add_child(layer)
		layer.draw.connect(func(): _draw_desk(layer, Rect2(r.position - layer.position, r.size)))
		_foreground_layers.append(layer)
		layer.queue_redraw()
	for fitting: Dictionary in design.get("fittings", []):
		if String(fitting["kind"]) != "passing_vehicle":
			var fixture := Node2D.new()
			fixture.name = "Fixture_" + String(fitting.get("object", fitting["kind"]))
			fixture.position.y = float(fitting["at"][1]) - 22.0
			fixture.texture_filter = texture_filter
			fixture.material = material
			get_parent().add_child(fixture)
			_foreground_layers.append(fixture)
			fixture.draw.connect(func(): _draw_fitting(fixture, fitting))
			fixture.queue_redraw()
			continue
		var layer := Node2D.new()
		layer.name = "PassingVehicle"
		layer.texture_filter = texture_filter
		layer.material = material
		get_parent().add_child(layer)
		_vehicles.append({"layer": layer, "fitting": fitting})
		layer.draw.connect(func(): _draw_vehicle(layer, fitting))
	_update_vehicles()

func _update_vehicles() -> void:
	for vehicle: Dictionary in _vehicles:
		var layer: Node2D = vehicle["layer"]
		if not is_instance_valid(layer):
			continue
		var fitting: Dictionary = vehicle["fitting"]
		var phase: float = fposmod(_clock * SaveManager.motion(), float(fitting.get("period", 30.0)))
		var duration: float = float(fitting.get("duration", 10.0))
		var journey: Array = fitting.get("journey", [-160.0, 1312.0])
		# Sort at the wheel contact line, using the same feet offset as the
		# static foreground layers. Sidewalk pedestrians pass behind the tram.
		layer.position = Vector2(roundf(lerpf(float(journey[0]), float(journey[1]), phase / duration)),
			float(fitting["at"][1]) - 16.0)
		layer.visible = phase <= duration
		layer.modulate = _plate_tint()
		layer.queue_redraw()

func _draw_vehicle(layer: Node2D, fitting: Dictionary) -> void:
	ACTIVITY_OBJECTS.draw(layer, String(fitting["object"]), Vector2(0, 16),
		float(fitting.get("unit", 2.4)), _clock * SaveManager.motion(), String(design.get("city", "")))

func _draw_desk(ci: CanvasItem, r: Rect2) -> void:
	var tint: Color = _plate_tint()
	ci.draw_rect(r, Color8(68, 87, 95) * tint)
	ci.draw_rect(Rect2(r.position, Vector2(r.size.x, 6)), Color8(205, 207, 193) * tint)
	ci.draw_rect(Rect2(r.position + Vector2(5, 7), r.size - Vector2(10, 14)), Color8(88, 109, 114) * tint)
	ci.draw_rect(Rect2(r.position + Vector2(0, r.size.y - 7), Vector2(r.size.x, 7)), Color8(43, 54, 64) * tint)
	var c := r.get_center()
	ci.draw_rect(Rect2(c - Vector2(14, 19), Vector2(28, 31)), Color8(36, 61, 88))
	ci.draw_string(ThemeDB.fallback_font, c + Vector2(-3, 5), "i", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color8(238, 236, 218))
	ci.draw_rect(Rect2(r.position + Vector2(20, -23), Vector2(30, 21)), Color8(40, 53, 64) * tint)
	ci.draw_rect(Rect2(r.position + Vector2(23, -20), Vector2(24, 14)), Color8(124, 164, 169) * tint)

func _draw_foreground(layer: Node2D, r: Rect2) -> void:
	var uv := Rect2(_source.position + r.position * _source.size / Vector2(1152, 648),
		r.size * _source.size / Vector2(1152, 648))
	var dst := Rect2(r.position - layer.position, r.size)
	var tint: Color = _plate_tint()
	layer.draw_texture_rect_region(_texture, dst, uv, tint)

func solids() -> Array:
	var result: Array = []
	if design.has("objects"):
		for object: Dictionary in design["objects"]:
			for r: Array in object.get("footprints", []):
				result.append(Rect2(r[0], r[1], r[2], r[3]))
		return result
	for values: Array in design.get("solids", []):
		result.append(Rect2(float(values[0]), float(values[1]), float(values[2]), float(values[3])))
	return result

func collision_footprints() -> Array:
	if design.has("objects"):
		return solids()
	# Preserve the old contract for backgrounds not yet given authored geometry.
	var result: Array = []
	for r: Rect2 in solids():
		var height: float = minf(r.size.y, 26.0)
		result.append(Rect2(r.position.x, r.end.y-height, r.size.x, height))
	return result

func draw_object(ci: Node2D, object: Dictionary) -> void:
	var tint: Color = _plate_tint()
	for points: Array in object.get("polygons", []):
		_draw_textured_polygon(ci, points, tint)
	if scene_id=="HotelRoom" and object["id"]=="wardrobe":
		# The room's double wooden door also has a foreground silhouette.
		# Paint its open leaves here as well, so that silhouette cannot cover
		# the doorway animation with a second closed copy of the source art.
		ci.draw_set_transform(-ci.position)
		_draw_exit_door_on(ci,tint)
		ci.draw_set_transform(Vector2.ZERO)
	for points: Array in object.get("glass", []):
		var polygon := PackedVector2Array()
		for xy: Array in points: polygon.append(Vector2(xy[0],xy[1])-ci.position)
		ci.draw_colored_polygon(polygon, Color(String(object["glass_tint"])) if object.has("glass_tint") else Color(0.10,0.24,0.30,0.40))
	for sign: Dictionary in design.get("lettering", []):
		if sign.get("object", "") == object["id"]:
			LETTERING.draw(ci,sign,ci.position,tint)
	if object.has("water"):
		_draw_fountain(ci, object["water"], tint)
	if object.has("animation_patches"):
		_draw_animation_patches(tint,ci,object["animation_patches"])
	_draw_object_accents(ci, object, tint)
	_draw_portals_on(ci, String(object["id"]))

func draw_foliage(ci: Node2D, object: Dictionary) -> void:
	var tint: Color = _plate_tint()
	# This child is at world origin; its parent supplies the object's sort depth.
	for points: Array in object.get("foliage", []):
		var polygon := PackedVector2Array()
		var uv := PackedVector2Array()
		for xy: Array in points:
			var p := Vector2(xy[0],xy[1])
			polygon.append(p)
			uv.append((_source.position+p*_source.size/Vector2(1152,648))/_texture.get_size())
		ci.draw_polygon(polygon,PackedColorArray([tint]),uv,_texture)

func _draw_object_accents(ci: Node2D, object: Dictionary, tint: Color) -> void:
	for stroke: Dictionary in object.get("accents",[]):
		var points := PackedVector2Array()
		for xy: Array in stroke["points"]: points.append(Vector2(xy[0],xy[1])-ci.position)
		ci.draw_polyline(points,Color(stroke["color"])*tint,float(stroke["width"]),false)

func _draw_textured_polygon(ci: Node2D, points: Array, tint: Color) -> void:
	var polygon := PackedVector2Array()
	var uv := PackedVector2Array()
	for xy: Array in points:
		var p := Vector2(xy[0],xy[1])
		polygon.append(p-ci.position)
		uv.append((_source.position+p*_source.size/Vector2(1152,648))/_texture.get_size())
	ci.draw_polygon(polygon, PackedColorArray([tint]), uv, _texture)

func _draw_fountain(ci: Node2D, water: Dictionary, tint: Color) -> void:
	var t: float = floorf(_clock*12.0)*SaveManager.motion()/12.0
	if String(water.get("kind",""))=="spouts":
		for stream: Array in water["streams"]:
			for i in range(6):
				var phase: float=fposmod(t*.9+float(i)/6.0,1.0)
				var index: int=mini(int(phase*(stream.size()-1)),stream.size()-2)
				var local_phase: float=phase*(stream.size()-1)-index
				var a:=Vector2(stream[index][0],stream[index][1])
				var b:=Vector2(stream[index+1][0],stream[index+1][1])
				ci.draw_rect(Rect2((a.lerp(b,local_phase)-ci.position).round(),Vector2(2,3)),Color8(211,249,253)*tint)
		var pool: Array=water["pool"]
		for i in range(9):
			var x: float=float(pool[0])+fposmod(float(i)*19.0+t*9.0,float(pool[2])-7.0)
			var y: float=float(pool[1])+float(i%3)*float(pool[3])/3.0
			ci.draw_rect(Rect2((Vector2(x,y)-ci.position).round(),Vector2(3+i%4,1)),Color8(194,241,247,170)*tint)
		return
	var center := Vector2(water["at"][0],water["at"][1])-ci.position
	if String(water.get("kind",""))=="drinking":
		var height: float=float(water.get("height",34.0))
		for i in range(5):
			var y: float=fposmod(t*33.0+float(i)*height/5.0,height)
			ci.draw_rect(Rect2((center-Vector2(1,height-y)).round(),Vector2(2,3)),Color8(197,238,239)*tint)
		return
	# Travelling highlights run down the jet; ripples expand from the impact.
	# No rectangular UV displacement can drag the masonry or the person behind it.
	for i in range(17):
		var y: float = fposmod(t*65.0+float(i)*7.7, 66.0)
		var x: float = float((i*7)%19)-9.0
		ci.draw_rect(Rect2((center+Vector2(x,-70+y)).round(),Vector2(2,4)),Color8(198,244,255,195)*tint)
	for i in range(4):
		var phase: float = fposmod(t*0.65+float(i)*0.25,1.0)
		var ring := PackedVector2Array()
		for j in range(25):
			var angle: float = float(j)*TAU/24.0
			ring.append((center+Vector2(cos(angle)*(8+phase*77),sin(angle)*(3+phase*18))).round())
		ci.draw_polyline(ring,Color(0.70,0.94,1.0,(1.0-phase)*0.62)*tint,1.5,false)
	for i in range(8):
		var phase: float = fposmod(t*1.15+float(i)*0.13,1.0)
		var x: float = (phase*2.0-1.0)*(19.0+float(i%3)*9.0)
		var y: float = -sin(phase*PI)*float(6+i%4*2)
		ci.draw_rect(Rect2((center+Vector2(x,y)).round(),Vector2(2,2)),Color8(212,250,255,180)*tint)

func cats() -> Array:
	var result: Array = []
	for c: Array in design.get("cats", []):
		result.append([Vector2(float(c[0]), float(c[1])), int(c[2]), int(c[3])])
	return result

func _process(delta: float) -> void:
	_clock += delta
	if design.has("exit_door") and not staging_only:
		var visitor := get_parent().get_node_or_null("Encounter")
		if visitor != null and visitor.get("_state") == "leaving":
			var to: Vector2 = visitor.get("leave_to")
			if visitor.position.distance_to(to) < 80.0:
				_door_hold = 1.0
		else:
			_door_hold = maxf(0.0,_door_hold-delta)
		_door_open = move_toward(_door_open,1.0 if _door_hold>0 else 0.0,delta*3.0)
	_update_vehicles()
	queue_redraw()
	for layer in _foreground_layers:
		if is_instance_valid(layer):
			layer.queue_redraw()

func _draw() -> void:
	if _texture == null:
		return
	var tint: Color = _plate_tint()
	draw_texture_rect_region(_texture, Rect2(0, 0, 1152, 648), _source, tint)
	preload("res://scenes/world/DaylightDetails.gd").draw(self, _texture, _source, scene_id, staging_only)
	for object: Dictionary in design.get("objects",[]):
		_draw_object_accents(self,object,tint)
	_draw_exit_door(tint)
	_draw_animation_patches(tint)
	if staging_only:
		for object: Dictionary in design.get("objects", []):
			if object.has("water"): _draw_fountain(self,object["water"],tint)
	_draw_motion_layers(tint)
	_draw_signs()
	for sign: Dictionary in design.get("lettering", []):
		LETTERING.draw(self,sign,Vector2.ZERO,tint)
	_draw_room_numbers()
	_draw_portals()
	_draw_fittings()
	_draw_motion()

func _draw_exit_door(tint: Color) -> void:
	_draw_exit_door_on(self,tint)

func _draw_exit_door_on(ci: CanvasItem,tint: Color) -> void:
	if _door_open <= 0.0 or not design.has("exit_door"): return
	var a: Array = design["exit_door"]
	var r := Rect2(a[0],a[1],a[2],a[3])
	ci.draw_rect(r,Color8(28,27,29)*tint)
	ci.draw_rect(Rect2(r.position+Vector2(4,5),r.size-Vector2(8,5)),Color8(61,51,43)*tint)
	ci.draw_rect(Rect2(r.position.x,r.end.y-18,r.size.x,18),Color8(107,79,53)*tint)
	var half: float = r.size.x*0.5
	var width: float = maxf(4.0,half*(1.0-_door_open*.91))
	# The original two wooden leaves pivot away from the center, revealing a
	# dark corridor. Their hinges stay attached to the jambs throughout.
	for pair in [[Rect2(r.position,Vector2(width,r.size.y)),Rect2(r.position,Vector2(half,r.size.y))],
		[Rect2(r.end.x-width,r.position.y,width,r.size.y),Rect2(r.position.x+half,r.position.y,half,r.size.y)]]:
		var sample: Rect2=pair[1]
		var uv := Rect2(_source.position+sample.position*_source.size/Vector2(1152,648),sample.size*_source.size/Vector2(1152,648))
		ci.draw_texture_rect_region(_texture,pair[0],uv,tint)

func _draw_animation_patches(tint: Color, target: Node2D = null, patches: Array = []) -> void:
	var ci: Node2D = self if target == null else target
	ci.draw_set_transform(-ci.position if target != null else Vector2.ZERO)
	var t: float = _clock * SaveManager.motion()
	for patch: Dictionary in design.get("animation_patches", []) if target == null else patches:
		var a: Array = patch["rect"]
		var r := Rect2(float(a[0]), float(a[1]), float(a[2]), float(a[3]))
		var kind: String = String(patch["kind"])
		if kind == "bin_lid":
			var opened: float = smoothstep(.35,1.4,t)
			var height: float = roundf(28.0*opened)
			var hinge := r.position + Vector2(0,3)
			ci.draw_rect(r,Color8(26,47,39)*tint)
			ci.draw_rect(Rect2(hinge-Vector2(0,height),Vector2(r.size.x,height+3)),Color8(38,67,45)*tint)
			ci.draw_rect(Rect2(hinge-Vector2(0,height),Vector2(r.size.x,3)),Color8(93,140,51)*tint)
			ci.draw_rect(Rect2(hinge-Vector2(-2,height-3),Vector2(2,height)),Color8(69,107,44)*tint)
			if height>18:
				var card := Rect2(hinge+Vector2(8,-height+5),Vector2(r.size.x-16,height-10))
				ci.draw_rect(card,Color8(229,225,195)*tint)
				for i in range(3):
					for j in range(4):
						ci.draw_rect(Rect2(card.position+Vector2(3+j*4,3+i*4),Vector2(2,2)),
							Color8(56,95,60)*tint if i%2==0 else Color8(44,43,41)*tint)
		elif kind == "cable_cars":
			# Only the separate cabins move on the pictured cable. Their
			# support, skyline, interior and camera stay fixed.
			for car in range(2):
				var phase: float = fposmod(t/24.0+float(car)*.5+.16,1.0)
				var p: Vector2 = Vector2(r.position.x,r.end.y).lerp(Vector2(r.end.x,r.position.y),phase).round()
				var u: float = lerpf(.45,2.8,phase)
				var green := Color8(50,117,64)*tint
				var dark := Color8(28,45,50)*tint
				ci.draw_rect(Rect2(p+Vector2(-4,-1)*u,Vector2(8,2)*u),dark)
				ci.draw_rect(Rect2(p+Vector2(-1,0)*u,Vector2(2,12)*u),dark)
				ci.draw_rect(Rect2(p+Vector2(-7,11)*u,Vector2(14,3)*u),dark)
				ci.draw_rect(Rect2(p+Vector2(-10,14)*u,Vector2(20,20)*u),green)
				ci.draw_rect(Rect2(p+Vector2(-12,18)*u,Vector2(24,12)*u),green)
				ci.draw_rect(Rect2(p+Vector2(-9,17)*u,Vector2(18,12)*u),dark)
				ci.draw_rect(Rect2(p+Vector2(-8,18)*u,Vector2(7,7)*u),Color8(67,103,126)*tint)
				ci.draw_rect(Rect2(p+Vector2(1,18)*u,Vector2(7,7)*u),Color8(52,82,108)*tint)
				ci.draw_rect(Rect2(p+Vector2(-8,33)*u,Vector2(16,2)*u),dark)
			# The near green window pillar covers cabins as they leave view.
			for cover: Array in patch.get("covers", []):
				_draw_textured_polygon(ci,cover,tint)
		elif kind == "rain":
			# Rain is confined to the open garden beyond the porch roof.
			# The camera, house, furniture and sheltered cast stay still.
			for drop in range(44):
				var x: float = r.position.x+fposmod(float(drop)*37.7,r.size.x)
				var y: float = r.position.y+fposmod(float(drop)*23.1+t*135.0,r.size.y-5.0)
				ci.draw_rect(Rect2(Vector2(x,y).round(),Vector2(1,4)),Color(.72,.83,.84,.42)*tint)
		elif kind == "sewing_wheel":
			# Only the flywheel spokes turn; the table and the whole scene
			# remain stationary while the tailor works the treadle.
			var center: Vector2 = r.get_center()
			ci.draw_rect(Rect2(center-Vector2(2,r.size.y*.33),Vector2(4,r.size.y*.66)),Color8(31,34,32)*tint)
			for spoke in range(3):
				var angle: float = t*5.0+float(spoke)*TAU/3.0
				var edge: Vector2 = center+Vector2(cos(angle)*r.size.x*.30,sin(angle)*r.size.y*.37)
				ci.draw_line(center.round(),edge.round(),Color8(174,169,145)*tint,1.0)
		elif kind == "laundry":
			# Displace only small inset cloth strips; the clothesline, outer
			# hem and wall stay fixed. No camera or furniture movement.
			for dy in range(0,int(r.size.y)-3,3):
				var weight: float=float(dy)/maxf(1.0,r.size.y)
				var dx: float=roundf(sin(t*.9+float(dy)*.14)*weight)
				var strip:=Rect2(r.position+Vector2(2,dy),Vector2(r.size.x-4,3))
				_sample_on(ci,strip,Rect2(strip.position+Vector2(dx,0),strip.size),tint)
		elif kind == "escalator_sloped":
			# Perspective treads move inside the diagonal escalator band.
			var direction: float = float(patch.get("direction",1.0))
			for i in range(20):
				var phase: float = fposmod(float(i)/20.0+t*.065*direction,1.0)
				var depth: float = phase*phase
				var p: Vector2 = r.position+Vector2(r.size.x*.4*depth,r.size.y*depth)
				var width: float = lerpf(r.size.x*.38,r.size.x*.62,depth)
				ci.draw_rect(Rect2(p.round(),Vector2(roundf(width),1)),Color8(150,161,165,155)*tint)
		elif kind == "escalator":
			# Moving tread highlights stay inset between the stationary rails.
			var direction: float = float(patch.get("direction", 1.0))
			for i in range(18):
				var phase: float = fposmod(float(i)/18.0+t*.08*direction,1.0)
				var depth: float = phase*phase
				var width: float = lerpf(r.size.x*.38,r.size.x,depth)
				var p: Vector2 = Vector2(r.get_center().x-width*.5,r.position.y+depth*r.size.y).round()
				ci.draw_rect(Rect2(p,Vector2(roundf(width),1)),Color8(160,166,161,150)*tint)
		elif kind == "pigeon_flock":
			# Game-drawn birds occupy only the measured feeding platform. A
			# one-time takeoff belongs to the grain-pouring shot, never the set.
			var count: int = int(patch.get("count", 72))
			for i in range(count):
				var u: float = fposmod(float(i)*.618034,1.0)
				var v: float = fposmod(float(i)*.381966+float(i/12)*.17,1.0)
				var p: Vector2 = r.position+Vector2(u*r.size.x,v*r.size.y)
				var lift: float = 0.0
				if bool(patch.get("takeoff", false)):
					lift = smoothstep(.65+float(i%9)*.055,2.1+float(i%9)*.055,t)
					p += Vector2((u-.5)*150.0,-120.0-float(i%7)*13.0)*lift
					# Continue out of the shot after the initial burst. Birds do
					# not freeze in mid-air while the player reads the caption.
					p += Vector2((u-.5)*24.0,-34.0)*maxf(0.0,t-2.7)
				p = p.round()
				ci.draw_set_transform(p,0.0,Vector2(1.6,1.6))
				p = Vector2.ZERO
				var grey := Color8(92+int(i%3)*12,105+int(i%3)*10,122+int(i%3)*10)
				if lift==0.0:
					ci.draw_rect(Rect2(-4,1,9,1),Color8(32,36,39,130)*tint)
				ci.draw_rect(Rect2(p+Vector2(-3,-4),Vector2(7,4)),Color8(45,55,69)*tint)
				ci.draw_rect(Rect2(p+Vector2(-2,-4),Vector2(5,3)),grey*tint)
				ci.draw_rect(Rect2(p+Vector2(-2,-4),Vector2(3,1)),Color8(165,170,177)*tint)
				var peck: float = 2.0 if fposmod(t*.45+u*4.0,1.0)>.83 and lift==0.0 else 0.0
				ci.draw_rect(Rect2(p+Vector2(2,-7+peck),Vector2(3,5)),Color8(69,85,98)*tint)
				ci.draw_rect(Rect2(p+Vector2(4,-6+peck),Vector2(2,1)),Color8(219,184,117)*tint)
				ci.draw_rect(Rect2(p+Vector2(3,-7+peck),Vector2(1,1)),Color8(25,32,40)*tint)
				if lift>.0:
					var wing: float = roundf(sin(t*14.0+float(i)) * 5.0)
					ci.draw_line(p+Vector2(-1,-3),p+Vector2(-7,wing-4),grey*tint,2.0,false)
					ci.draw_line(p+Vector2(1,-3),p+Vector2(7,-wing-4),grey*tint,2.0,false)
				else:
					ci.draw_rect(Rect2(p+Vector2(-1,0),Vector2(1,2)),Color8(154,86,75)*tint)
					ci.draw_rect(Rect2(p+Vector2(2,0),Vector2(1,2)),Color8(154,86,75)*tint)
			ci.draw_set_transform(-ci.position if target != null else Vector2.ZERO)
		elif kind == "rotor_marks":
			# Small moving marks belong to a measured chuck or millstone face.
			# The housing, countertop, characters and camera stay stationary.
			var center: Vector2 = r.get_center()
			var speed: float = float(patch.get("speed", 1.0))
			for i in range(3):
				var angle: float = t * speed + float(i) * TAU / 3.0
				var mark: Vector2 = (center + Vector2(cos(angle),sin(angle)) * r.size * 0.35).round()
				ci.draw_rect(Rect2(mark,Vector2(2,2)),Color8(76,79,75,210)*tint)
		elif kind == "washer":
			# Pixels travel around the inset drum without moving its frame.
			var center: Vector2=r.get_center()
			for i in range(5):
				var angle: float=t*.7+float(i)*TAU/5.0
				var p: Vector2=(center+Vector2(cos(angle),sin(angle))*r.size*.28).round()
				ci.draw_rect(Rect2(p,Vector2(2,3)),Color8(124,158,168,190)*tint)
		elif kind == "conveyor":
			# Only the inset belt moves. Its steel rim, luggage and ground stay
			# fixed, with the sampled rubber slats wrapping at their seam.
			var offset: float = floorf(fposmod(t*12.0,r.size.x))
			if offset>0:
				_sample_on(ci,Rect2(r.position,Vector2(r.size.x-offset,r.size.y)),
					Rect2(r.position+Vector2(offset,0),Vector2(r.size.x-offset,r.size.y)),tint)
				_sample_on(ci,Rect2(r.position+Vector2(r.size.x-offset,0),Vector2(offset,r.size.y)),
					Rect2(r.position,Vector2(offset,r.size.y)),tint)
		elif kind == "viaduct_train":
			var phase: float=fposmod(t+4.5,28.0)
			if phase<15.0:
				var x: float=roundf(lerpf(-620.0,1210.0,phase/15.0))
				for car in range(3):
					var p:=Vector2(x-float(car)*202.0,r.position.y)
					ci.draw_rect(Rect2(p+Vector2(4,3),Vector2(192,r.size.y-6)),Color8(211,210,193)*tint)
					ci.draw_rect(Rect2(p+Vector2(0,10),Vector2(200,r.size.y-21)),Color8(191,48,40)*tint)
					ci.draw_rect(Rect2(p+Vector2(0,r.size.y-21),Vector2(200,16)),Color8(213,215,206)*tint)
					ci.draw_rect(Rect2(p+Vector2(3,4),Vector2(194,3)),Color8(240,236,218)*tint)
					for w in range(4):
						var q:=p+Vector2(13+w*42,16)
						ci.draw_rect(Rect2(q,Vector2(28,21)),Color8(29,49,59)*tint)
						ci.draw_rect(Rect2(q+Vector2(3,3),Vector2(22,8)),Color8(72,104,118)*tint)
						ci.draw_rect(Rect2(q+Vector2(4,16),Vector2(20,3)),Color8(51,70,75)*tint)
					ci.draw_rect(Rect2(p+Vector2(184,15),Vector2(9,r.size.y-23)),Color8(31,46,52)*tint)
					ci.draw_rect(Rect2(p+Vector2(190,35),Vector2(2,5)),Color8(210,178,76)*tint)
					ci.draw_rect(Rect2(p+Vector2(0,r.size.y-7),Vector2(200,5)),Color8(48,50,53)*tint)
			# Catenary poles stay in front of the passing train, never slide.
			for cover: Array in patch.get("covers",[]):
				var fixed:=Rect2(cover[0],cover[1],cover[2],cover[3])
				_sample_on(ci,fixed,fixed,tint)
		elif kind == "rail_view":
			# Track sleepers approach in perspective only inside the front
			# windscreen. The carriage, skyline and camera remain stationary.
			var near_left:=Vector2(r.position.x,r.end.y)
			var near_right:=r.end
			var far_left:=Vector2(r.position.x+r.size.x*.39,r.position.y)
			var far_right:=Vector2(r.position.x+r.size.x*.61,r.position.y)
			ci.draw_colored_polygon(PackedVector2Array([far_left,far_right,near_right,near_left]),Color8(76,82,88)*tint)
			for i in range(18):
				var phase: float=fposmod(float(i)/18.0+t*.16,1.0)
				var depth: float=phase*phase
				var left: Vector2=far_left.lerp(near_left,depth)
				var right: Vector2=far_right.lerp(near_right,depth)
				var thickness: float=maxf(1.0,roundf(depth*3.0))
				ci.draw_rect(Rect2(left.round(),Vector2(roundf(right.x-left.x),thickness)),Color8(146,143,133)*tint)
			for lane: float in [.16,.84]:
				var far: Vector2=far_left.lerp(far_right,lane)
				var near: Vector2=near_left.lerp(near_right,lane)
				ci.draw_line(far.round(),near.round(),Color8(39,46,55)*tint,4.0,false)
				ci.draw_line((far+Vector2(1,0)).round(),(near+Vector2(1,0)).round(),Color8(202,205,203)*tint,1.0,false)
		elif kind == "charcoal_portrait":
			# A small charcoal study grows on the real easel canvas, without
			# a second generic easel or an unrelated printed portrait overlay.
			var strokes: Array=[
				[[.28,.24],[.28,.14],[.37,.14],[.40,.24]],
				[[.61,.24],[.64,.13],[.72,.13],[.72,.25]],
				[[.27,.24],[.22,.35],[.23,.58],[.35,.67],[.63,.67],[.76,.57],[.76,.35],[.70,.24],[.27,.24]],
				[[.34,.38],[.34,.48],[.41,.48],[.41,.38],[.34,.38]],
				[[.59,.38],[.59,.48],[.66,.48],[.66,.38],[.59,.38]],
				[[.45,.57],[.53,.57]],
				[[.35,.68],[.21,.76],[.18,.89],[.81,.89],[.77,.76],[.63,.68]],
				[[.29,.79],[.70,.84]],[[.41,.72],[.45,.85]],[[.65,.74],[.57,.86]]]
			var amount: float=clampf(t/3.5,0.0,1.0)*strokes.size()
			for i in range(strokes.size()):
				if float(i)>=amount: break
				var line:=PackedVector2Array()
				for xy: Array in strokes[i]:
					line.append((r.position+Vector2(xy[0],xy[1])*r.size).round())
				ci.draw_polyline(line,Color8(71,62,54)*tint,1.0,false)
		elif kind == "train":
			# Long station dwell, then a complete passing carriage. Sampling is
			# clipped to the rail band; platform columns stay in the foreground.
			var phase: float = fposmod(t, 24.0)
			var advance: float = clampf((phase - 14.0) / 10.0, 0.0, 1.0)
			var offset: float = floorf(advance * advance * r.size.x)
			if offset > 0 and offset < r.size.x:
				_sample_on(ci,Rect2(r.position, Vector2(r.size.x-offset, r.size.y)), Rect2(r.position+Vector2(offset,0),Vector2(r.size.x-offset,r.size.y)), tint)
				_sample_on(ci,Rect2(r.position+Vector2(r.size.x-offset,0),Vector2(offset,r.size.y)),Rect2(r.position,Vector2(offset,r.size.y)),tint)
		elif kind == "fan":
			# Only animate a separate rotor over artwork with a clean ceiling.
			# A solid rectangle cannot conceal a baked fan on a shaded wall.
			if not bool(patch.get("clean", false)):
				continue
			var c := r.get_center()
			ci.draw_rect(Rect2(c - Vector2(2,r.size.y*0.45), Vector2(4,r.size.y*0.45)),Color8(69,65,59)*tint)
			for i in range(3):
				var angle: float = t * 8.0 + float(i) * TAU / 3.0
				var end := c + Vector2(cos(angle)*r.size.x*0.43,sin(angle)*r.size.y*0.31)
				var wing := Vector2(-sin(angle)*4,cos(angle)*3)
				ci.draw_colored_polygon(PackedVector2Array([c-wing,(end-wing).round(),(end+wing).round(),c+wing]),Color8(86,73,58)*tint)
			ci.draw_rect(Rect2(c-Vector2(5,3),Vector2(10,6)),Color8(50,48,45)*tint)
		elif kind in ["water", "foliage"]:
			for y in range(0, int(r.size.y), 4):
				var shift: float = roundf(sin(t*(1.1 if kind=="water" else 0.65)+float(y)*0.17)*2.0)
				var edge: float = absf(shift) + 3.0
				var dst := Rect2(r.position+Vector2(edge,y),Vector2(r.size.x-edge*2,minf(4,r.size.y-y)))
				_sample_on(ci,dst,Rect2(dst.position+Vector2(shift,0),dst.size),tint)
	ci.draw_set_transform(Vector2.ZERO)

func _sample(dst: Rect2, sample: Rect2, tint: Color) -> void:
	_sample_on(self,dst,sample,tint)

func _sample_on(ci: Node2D, dst: Rect2, sample: Rect2, tint: Color) -> void:
	var uv := Rect2(_source.position + sample.position * _source.size / Vector2(1152,648), sample.size * _source.size / Vector2(1152,648))
	ci.draw_texture_rect_region(_texture,dst,uv,tint)

func _draw_motion_layers(tint: Color) -> void:
	var t: float = _clock * SaveManager.motion()
	for layer: Dictionary in design.get("motion_layers", []):
		var a: Array = layer["rect"]
		var r := Rect2(a[0],a[1],a[2],a[3])
		if String(layer.get("kind", "train")) == "doors":
			var phase: float = fposmod(t, 18.0)
			var opening: float = smoothstep(2.0,3.5,phase) * (1.0-smoothstep(8.0,9.5,phase))
			if opening <= 0.0: continue
			draw_rect(r,Color8(27,39,49)*tint)
			var inside: Rect2 = r.grow(-3)
			draw_rect(inside,Color8(114,132,135)*tint)
			draw_rect(Rect2(inside.position+Vector2(9,18),Vector2(inside.size.x-18,inside.size.y*.38)),Color8(40,62,75)*tint)
			draw_rect(Rect2(inside.position+Vector2(5,inside.size.y*.63),Vector2(inside.size.x-10,inside.size.y*.19)),Color8(55,95,116)*tint)
			draw_rect(Rect2(inside.position+Vector2(5,inside.size.y*.79),Vector2(inside.size.x-10,5)),Color8(86,129,145)*tint)
			draw_rect(Rect2(inside.position+Vector2(inside.size.x*.72,5),Vector2(3,inside.size.y-10)),Color8(207,184,93)*tint)
			draw_rect(Rect2(inside.position+Vector2(12,5),Vector2(inside.size.x-24,3)),Color8(216,220,198)*tint)
			var half: float = r.size.x*0.5
			var visible: float = half*(1.0-opening*0.88)
			_sample(Rect2(r.position,Vector2(visible,r.size.y)),Rect2(r.position+Vector2(half-visible,0),Vector2(visible,r.size.y)),tint)
			_sample(Rect2(r.position+Vector2(r.size.x-visible,0),Vector2(visible,r.size.y)),Rect2(r.position+Vector2(half,0),Vector2(visible,r.size.y)),tint)
			continue
		var b: Array = layer.get("sample", a)
		var sample := Rect2(b[0],b[1],b[2],b[3])
		var path: String = String(layer.get("texture", ""))
		var texture: Texture2D = _motion_textures.get(path, _texture)
		var phase: float = fposmod(t,24.0)
		var offset: float = smoothstep(14.0,24.0,phase)*sample.size.x
		var drawn: float = 0.0
		while drawn < r.size.x-0.01:
			var source_x: float = fposmod(offset+drawn,sample.size.x)
			var width: float = minf(sample.size.x-source_x,r.size.x-drawn)
			var src := Rect2(sample.position+Vector2(source_x,0),Vector2(width,sample.size.y))
			var dst := Rect2(r.position+Vector2(drawn,0),Vector2(width,r.size.y))
			if path.is_empty():
				_sample(dst,src,tint)
			else:
				var ratio: Vector2 = texture.get_size()/Vector2(1152,648)
				draw_texture_rect_region(texture,dst,Rect2(src.position*ratio,src.size*ratio),tint)
			drawn += width
		# Fixed supports come from the original plate, above the clean carriage.
		for values: Array in layer.get("occluders", []):
			var cover := Rect2(values[0],values[1],values[2],values[3])
			_sample(cover,cover,tint)

func _draw_portals() -> void:
	_draw_portals_on(self)

func _draw_portals_on(ci: Node2D, object_id: String = "") -> void:
	if staging_only:
		return
	for portal: Dictionary in design.get("portals", []):
		if not object_id.is_empty() and portal.get("object", "") != object_id:
			continue
		if bool(portal.get("baked_sign", false)):
			continue
		var node := get_parent().get_node_or_null(String(portal["node"]))
		if node == null:
			continue
		var label: String = String(node.get("sign_text"))
		if label.is_empty():
			continue
		if not portal.has("sign_rect"):
			continue
		var coords: Array = portal["sign_rect"]
		var panel := Rect2(coords[0],coords[1],coords[2],coords[3])
		if ci != self: panel.position -= ci.position
		var x: float = panel.get_center().x
		var y: float = panel.position.y
		var font: Font = ThemeDB.fallback_font
		var width: float = panel.size.x
		var dark := Color8(36, 54, 58)
		var pale := Color8(228, 225, 205)
		# A small destination plaque beside the threshold, using the live door
		# label. It remains readable even where the approved art uses a shop name.
		ci.draw_rect(panel.grow(2), dark.darkened(0.25))
		ci.draw_rect(panel, dark)
		var size: int = int(portal.get("font_size", 12))
		while size > 7 and font.get_string_size(label,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x > width-12:
			size -= 1
		var text_width: float = font.get_string_size(label,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
		ci.draw_string(font, Vector2(x-text_width*0.5,y+panel.size.y*0.5+float(size)*0.35),label,HORIZONTAL_ALIGNMENT_LEFT,-1,size,pale)
		if String(portal["type"]) == "direction":
			var ground: float = node.position.y - (ci.position.y if ci != self else 0.0)
			ci.draw_rect(Rect2(x - 2, panel.end.y, 4, maxf(0,ground-panel.end.y)), dark)

func _draw_fittings() -> void:
	# In a world, each fixture is an independent y-sorted node. A staged
	# activity has no world characters, so draw its fixtures onto the plate.
	if not staging_only: return
	for fitting: Dictionary in design.get("fittings", []):
		_draw_fitting(self, fitting)

func _draw_fitting(ci: Node2D, fitting: Dictionary) -> void:
	var a: Array = fitting["at"]
	var p := Vector2(float(a[0]), float(a[1])) - (Vector2.ZERO if ci == self else ci.position)
	if String(fitting["kind"]) == "passing_vehicle":
		# World vehicles need their own y-sort position; activity shots
		# have separate, deliberately timed movement in the director.
		return
	if String(fitting["kind"]) == "activity_object":
		if staging_only and bool(fitting.get("directed_separately", false)):
			return
		ACTIVITY_OBJECTS.draw(ci, String(fitting["object"]), p,
			float(fitting.get("unit", 1.6)), 0.0, String(design.get("city", "")))
		return
	if String(fitting["kind"]) == "wayfinding_post":
		var tint: Color = _plate_tint()
		ci.draw_rect(Rect2(p+Vector2(-2,-106),Vector2(4,103)),Color8(56,66,66)*tint)
		ci.draw_rect(Rect2(p+Vector2(-7,-3),Vector2(14,3)),Color8(40,50,52)*tint)
		var panel := {
			"rect": [p.x-31,p.y-108,62,43], "text": fitting.get("text","BUS"),
			"background": fitting.get("background","#25485c"), "ink": "#f1ebd8",
			"size": 13, "border": true, "font": fitting.get("font","")}
		LETTERING.draw(ci,panel,Vector2.ZERO,tint)
		return
	if String(fitting["kind"]) == "apple_crate":
		ci.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		ci.draw_texture(ITEM_ART.apple_crate(), p + Vector2(-32,-40))
		var font: Font = ThemeDB.fallback_font
		var size := 4
		for row in range(2):
			var label: String = ["ZU", "VERSCHENKEN"][row]
			var width := font.get_string_size(label,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
			ci.draw_string(font,p + Vector2(-width*0.5,-10+row*4),label,HORIZONTAL_ALIGNMENT_LEFT,-1,size,Color8(61,61,48))
	if String(fitting["kind"]) == "ticket":
		ci.draw_rect(Rect2(p + Vector2(-21, -75), Vector2(42, 75)), Color8(42, 57, 62))
		ci.draw_rect(Rect2(p + Vector2(-17, -70), Vector2(34, 10)), Color8(200, 199, 171))
		ci.draw_rect(Rect2(p + Vector2(-13, -52), Vector2(26, 25)), Color8(94, 150, 157))
		for i in range(3):
			ci.draw_rect(Rect2(p + Vector2(-10, -46 + i * 6), Vector2(17, 2)), Color8(215, 228, 213))
		ci.draw_rect(Rect2(p + Vector2(-12, -17), Vector2(24, 4)), Color8(20, 29, 36))
		ci.draw_rect(Rect2(p + Vector2(-18, -5), Vector2(36, 5)), Color8(74, 81, 78))

func _draw_signs() -> void:
	if staging_only:
		return
	var host := get_parent()
	if host == null:
		return
	for sign: Dictionary in design.get("signs", []):
		var door := host.get_node_or_null(String(sign["node"]))
		if door == null:
			continue
		var label: String = String(door.get("sign_text"))
		var p: Array = sign["rect"]
		var rect := Rect2(float(p[0]), float(p[1]), float(p[2]), float(p[3]))
		draw_rect(rect.grow(2), Color8(48, 48, 44))
		draw_rect(rect, Color8(217, 207, 175))
		var font: Font = ThemeDB.fallback_font
		var size: int = 14
		var width: float = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		draw_string(font, Vector2(rect.get_center().x - width * 0.5, rect.position.y + rect.size.y * 0.72),
			label, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color8(39, 53, 49))

func _draw_room_numbers() -> void:
	if staging_only:
		return
	for sign: Dictionary in design.get("room_numbers", []):
		var door := get_parent().get_node_or_null(String(sign["node"]))
		if door == null or not door.has_method("_room_number"):
			continue
		var a: Array = sign["rect"]
		var r := Rect2(a[0], a[1], a[2], a[3])
		draw_rect(r, Color8(24, 25, 26))
		draw_rect(r.grow(-2), Color8(79, 77, 66), false, 1.0)
		var label: String = door.call("_room_number")
		var font: Font = ThemeDB.fallback_font
		var size: int = 20
		var width: float = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		draw_string(font, r.get_center()+Vector2(-width/2,7), label, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color8(244,227,193))

func _draw_motion() -> void:
	var motion: float = SaveManager.motion()
	for effect: Dictionary in design.get("motion", []):
		var kind: String = String(effect["kind"])
		var a: Array = effect["rect"]
		var r := Rect2(float(a[0]), float(a[1]), float(a[2]), float(a[3]))
		match kind:
			"motes":
				for i in range(6):
					var x: float = r.position.x + fposmod(float(i*193)+_clock*3.0*motion,r.size.x)
					var y: float = r.position.y + fposmod(float(i*37)+sin(_clock*0.3+float(i))*5,r.size.y)
					draw_rect(Rect2(roundf(x),roundf(y),2,2),Color(0.92,0.85,0.66,0.20 if GameState.is_morning() else 0.11))
			"water":
				for i in range(20):
					var x: float = r.position.x + fposmod(float(i * 71) + _clock * 5.0 * motion, r.size.x)
					var y: float = r.position.y + fposmod(float(i * 29), r.size.y)
					var alpha: float = 0.12 + 0.08 * sin(_clock * 1.1 * motion + float(i))
					draw_rect(Rect2(floorf(x), floorf(y), 8 + i % 12, 2), Color(0.72, 0.85, 0.84, alpha))
			"light":
				# Old board-sized light rectangles do not align with the approved
				# full-scene lamps. Their painted light now sits under the clock tint.
				pass
			"incense":
				# Small stepped wisps rise from the sticks, below the fixed roof.
				# The burner and paving are never displaced by a smoke animation.
				for i in range(8):
					var rise: float = fposmod(_clock * 10.0 * motion + float(i * 11), r.size.y)
					var drift: float = roundf(sin(rise * .11 + i) * (2.0 + rise * .04))
					var width: float = 2.0 + floorf(rise / 12.0)
					var x: float = r.position.x + r.size.x * (.2 + float(i % 4) * .2) + drift
					var alpha: float = (1.0 - rise / r.size.y) * .36
					draw_rect(Rect2(roundf(x), roundf(r.end.y - rise), width, 3), Color(.82,.85,.83,alpha))
					draw_rect(Rect2(roundf(x+1), roundf(r.end.y-rise-3), maxf(2,width-2), 3), Color(.88,.90,.87,alpha*.7))
			"steam":
				for i in range(4):
					var rise: float = fposmod(_clock * 8.0 * motion + float(i * 9), r.size.y)
					var sway: float = roundf(sin(rise * 0.14 + float(i)) * 3.0)
					draw_rect(Rect2(r.get_center().x + sway, r.end.y - rise, 3, 6),
						Color(0.9, 0.92, 0.89, (1.0 - rise / r.size.y) * 0.22))
