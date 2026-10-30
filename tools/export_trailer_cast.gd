extends SceneTree

# Renders the trailer's people with the game's own CharacterArt, so the film
# shows exactly the characters the player meets: one transparent PNG strip per
# act, FRAMES frames at 12 fps, feet at FEET in every frame. Items come out of
# ItemArt the same way. Output: trailer/public/v6/cast and trailer/public/v6/items.
#
# Run (graphical, not headless - a viewport has to actually render):
#   godot --path . --script res://tools/export_trailer_cast.gd [-- --out res://trailer/public/v6/]
#
# Also renders a few people from behind (cast/<id>/back_<act>.png) for shots
# where they face away from the camera. The game has no rear view, so it is
# made the way revision 5 made it: the face takes the hair's colour (the
# alien's head its own skin), and the clasp on the alien's coat goes.

# Loaded at run time, not preloaded: these reach autoloads (SaveManager) that
# do not exist yet when a --script entry point is compiled.
var CH: GDScript
var CAST: GDScript
var ROSTER: GDScript
var ITEMS: GDScript
const FRAME := Vector2i(40, 40)
const FEET := Vector2(20, 37)
const FRAMES := 24
const FPS := 12.0
const DEFAULT_OUT := "res://trailer/public/v7/"
const BACK_ACTS := {"alien": ["sit", "stand", "walk"], "nadia": ["sit", "stand", "walk"]}
const FACE := ["S", "W", "E", "M", "L", "H"]
var OUT := DEFAULT_OUT
const ALIEN_ACTS := ["stand", "walk", "look", "watch", "talk", "offer", "take", "drink", "eat",
	"sit", "wave", "point", "recoil", "read", "bow", "nod", "interact"]
const LEAD_ACTS := ["stand", "talk", "wave", "watch", "sit", "walk", "offer", "point", "nod", "bow",
	"look", "pour", "drink", "take"]
const CROWD_ACTS := ["stand", "talk", "walk", "watch", "look"]
const LEADS := {"kerstin": "berlin", "nadia": "london", "odile": "paris", "viktor": "moscow",
	"arda": "istanbul", "omkar": "mumbai", "setsuko": "tokyo", "rocio": "mexico"}
const ITEM_IDS := ["bread", "cay", "apple", "water", "old_book", "money", "kermel_flowers"]


class Strip:
	extends Node2D
	var art: GDScript
	var who: Dictionary
	var act := "stand"
	var seed_i := 0

	func _draw() -> void:
		for i in range(FRAMES):
			art.draw_figure(self, FEET + Vector2(i * FRAME.x, 0), 1.0, who, act, i / FPS, seed_i)


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var at := args.find("--out")
	if at >= 0 and at + 1 < args.size():
		OUT = String(args[at + 1]).trim_suffix("/") + "/"
	CH = load("res://scenes/npc/CharacterArt.gd")
	CAST = load("res://scenes/npc/Cast.gd")
	ROSTER = load("res://scenes/npc/CastRoster.gd")
	ITEMS = load("res://scenes/world/ItemArt.gd")
	var people := {"alien": [CH.alien_look(), ALIEN_ACTS],
		"lukas": [ROSTER.look("lukas", "berlin"), LEAD_ACTS]}
	for id: String in LEADS:
		people[id] = [CAST.look(LEADS[id]), LEAD_ACTS]
	for i in range(4):
		people["crowd%d" % i] = [CH.look(30 + i * 19, "berlin"), CROWD_ACTS]
	var viewport := SubViewport.new()
	viewport.size = Vector2i(FRAME.x * FRAMES, FRAME.y)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	root.add_child(viewport)
	var strip := Strip.new()
	strip.art = CH
	viewport.add_child(strip)
	var manifest := {"frame": [FRAME.x, FRAME.y], "feet": [FEET.x, FEET.y], "frames": FRAMES,
		"fps": FPS, "people": {}}
	for id: String in people:
		DirAccess.make_dir_recursive_absolute(OUT + "cast/" + id)
		strip.who = people[id][0]
		strip.seed_i = 0
		var acts: Array = people[id][1]
		for act: String in acts:
			strip.act = act
			strip.queue_redraw()
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			var image := viewport.get_texture().get_image()
			image.save_png(OUT + "cast/%s/%s.png" % [id, act])
		manifest.people[id] = acts
		if BACK_ACTS.has(id):
			var front: Dictionary = people[id][0]
			strip.who = _from_behind(front)
			for act: String in BACK_ACTS[id]:
				strip.act = act
				strip.queue_redraw()
				await process_frame
				await process_frame
				await RenderingServer.frame_post_draw
				var image := viewport.get_texture().get_image()
				if bool(front.get("alien", false)):
					_drop_clasp(image, front.get("pal", CH.A_PAL))
				image.save_png(OUT + "cast/%s/back_%s.png" % [id, act])
	manifest["back"] = BACK_ACTS
	DirAccess.make_dir_recursive_absolute(OUT + "items")
	for id: String in ITEM_IDS:
		var pixels: Variant = ITEMS.Pixels.new()
		ITEMS._paint(pixels, id)
		pixels.outline()
		pixels.image.save_png(OUT + "items/%s.png" % id)
	manifest["items"] = ITEM_IDS
	var file := FileAccess.open(OUT + "cast.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest, "\t"))
	file.close()
	print("TRAILER CAST: %d people, %d items -> %s" % [people.size(), ITEM_IDS.size(), OUT])
	quit()


# The same person seen from behind: every face letter takes the colour of the
# back of the head, and nothing worn on the front shows.
func _from_behind(who: Dictionary) -> Dictionary:
	var alien := bool(who.get("alien", false))
	var pal: Dictionary = (who.get("pal", CH.A_PAL) as Dictionary).duplicate()
	var crown: Color = pal.get("S" if alien else "R", Color.BLACK)
	for letter: String in FACE:
		if pal.has(letter):
			pal[letter] = crown
	if not alien and pal.has("C"):
		pal["g"] = pal["C"]
	var back := who.duplicate()
	back["pal"] = pal
	back.erase("prop")
	return back


# The alien's gold clasp shares its letter with the antenna tips, so it is
# painted out of the image below the head instead of out of the palette.
func _drop_clasp(image: Image, pal: Dictionary) -> void:
	var clasp: Color = pal.get("g", Color.TRANSPARENT)
	var coat: Color = pal.get("C", Color.TRANSPARENT)
	for y in range(22, image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).is_equal_approx(clasp):
				image.set_pixel(x, y, coat)
