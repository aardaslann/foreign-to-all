class_name WorldArt
extends Object

# Static helpers for the pixel-art world (design_handoff_world).
# Everything is authored at 1× (16px tiles, 32px characters, 576×324 plates)
# and displayed at 2× with Nearest filtering. Positions in the handoff README
# are 1× plate coordinates — multiply by 2 for world space (these helpers do).

const ROOT := "res://art/world/"

# tiles/tileset_<mode>.png — single row of 16×16 cells, in this order
const TILE_SIDEWALK   := 0
const TILE_SIDEWALK_B := 1
const TILE_KERB       := 2
const TILE_ASPHALT    := 3
const TILE_ASPHALT_D  := 4
const TILE_CROSSWALK  := 5
const TILE_COBBLE     := 6
const TILE_GRASS      := 7
const TILE_GRASS_B    := 8
const TILE_DIRT       := 9
const TILE_BURN       := 10
const TILE_CARPET     := 11
const TILE_WOOD       := 12
const TILE_RUNNER     := 13

# ui/icons.png — 16px cells
const ICON_COIN    := 0
const ICON_BROT    := 1
const ICON_KARTE   := 2
const ICON_KEYCARD := 3
const ICON_JOURNAL := 4
const ICON_QUEST   := 5
const ICON_QUEST_OK:= 6
const ICON_EKEY    := 7


static func mode() -> String:
	return "morning" if GameState.is_morning() else "dawn"


# Solid fallback colours, used when a tile atlas is unavailable so a floor is
# never left unpainted (an unpainted floor shows the window clear colour).
# Indexed by the TILE_* ids above, in the same order as the atlas
const TILE_FALLBACK := [
	Color(0.118, 0.120, 0.140),   # sidewalk
	Color(0.104, 0.106, 0.126),   # sidewalk_b
	Color(0.150, 0.152, 0.174),   # kerb
	Color(0.088, 0.090, 0.110),   # asphalt
	Color(0.098, 0.100, 0.120),   # asphalt_dash
	Color(0.130, 0.132, 0.152),   # crosswalk
	Color(0.105, 0.115, 0.105),   # cobble
	Color(0.092, 0.162, 0.116),   # grass
	Color(0.078, 0.142, 0.100),   # grass_b
	Color(0.140, 0.105, 0.075),   # dirt
	Color(0.048, 0.042, 0.052),   # burn
	Color(0.195, 0.095, 0.092),   # carpet
	Color(0.185, 0.120, 0.080),   # wood
	Color(0.240, 0.125, 0.105),   # runner
]


static func tex(rel: String) -> Texture2D:
	var path := ROOT + rel
	if not ResourceLoader.exists(path):
		push_warning("WorldArt: missing texture " + path)
		return null
	return load(path) as Texture2D


# "props/lamp" -> props/lamp_dawn.png or props/lamp_morning.png
static func mode_tex(rel_base: String) -> Texture2D:
	return tex(rel_base + "_" + mode() + ".png")


# Static sprite at 1× coordinates, drawn at 2× with Nearest
static func sprite(parent: Node, texture: Texture2D, pos_1x: Vector2, z: int = 0) -> Sprite2D:
	if texture == null:
		return null
	var s := Sprite2D.new()
	s.texture = texture
	s.centered = false
	s.position = pos_1x * 2.0
	s.scale = Vector2(2, 2)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.z_index = z
	parent.add_child(s)
	return s


# Animated sprite from a horizontal strip (uniform cells, full height)
static func strip_sprite(parent: Node, texture: Texture2D, frames: int, fps: float,
		pos_1x: Vector2, z: int = 0, loops: bool = true) -> AnimatedSprite2D:
	if texture == null or frames <= 0:
		return null
	var cell_w := int(texture.get_width() / float(frames))
	var sf := SpriteFrames.new()
	sf.set_animation_speed("default", fps)
	sf.set_animation_loop("default", loops)
	for i in range(frames):
		var at := AtlasTexture.new()
		at.atlas = texture
		at.region = Rect2(i * cell_w, 0, cell_w, texture.get_height())
		sf.add_frame("default", at)
	var s := AnimatedSprite2D.new()
	s.sprite_frames = sf
	s.centered = false
	s.position = pos_1x * 2.0
	s.scale = Vector2(2, 2)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.z_index = z
	s.play("default")
	parent.add_child(s)
	return s


# ── NPC sheets: 192×128, 32px cells, rows down/up/right/left, cols idle×2 walk×4

static func npc_frames(npc: String) -> SpriteFrames:
	var sheet := tex("npcs/" + npc + "_sheet.png")
	var sf := SpriteFrames.new()
	var dirs := ["down", "up", "right", "left"]
	for row in range(4):
		var d: String = dirs[row]
		_grid_anim(sf, sheet, "idle_" + d, row, 0, 2, 2.0, true)
		_grid_anim(sf, sheet, "walk_" + d, row, 2, 4, 8.0, true)
	sf.remove_animation("default")
	return sf


static func _grid_anim(sf: SpriteFrames, sheet: Texture2D, anim: String,
		row: int, first_col: int, count: int, fps: float, loops: bool) -> void:
	sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, loops)
	for i in range(count):
		var at := AtlasTexture.new()
		at.atlas = sheet
		at.region = Rect2((first_col + i) * 32, row * 32, 32, 32)
		sf.add_frame(anim, at)


# Standing NPC sprite: same rig as the player — feet on the node's origin line
static func npc_sprite(parent: Node2D, npc: String, anim: String = "idle_down") -> AnimatedSprite2D:
	var s := AnimatedSprite2D.new()
	s.sprite_frames = npc_frames(npc)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.scale = Vector2(2, 2)
	s.offset = Vector2(0, -1.5)
	s.play(anim)
	parent.add_child(s)
	return s


# Dialogue portrait: the head (top 18px) of the idle-down frame
static func avatar(npc: String) -> Texture2D:
	var at := AtlasTexture.new()
	at.atlas = tex("npcs/" + npc + "_sheet.png")
	at.region = Rect2(0, 0, 32, 18)
	return at


# UI icon from ui/icons.png (16px cells)
static func icon(idx: int) -> Texture2D:
	var at := AtlasTexture.new()
	at.atlas = tex("ui/icons.png")
	at.region = Rect2(idx * 16, 0, 16, 16)
	return at


# Familiarity pip (tier 0-3) from ui/familiarity_pips.png (8px cells)
static func pip(tier: int) -> Texture2D:
	var at := AtlasTexture.new()
	at.atlas = tex("ui/familiarity_pips.png")
	at.region = Rect2(clampi(tier, 0, 3) * 8, 0, 8, 8)
	return at


# Ground colours, sampled from the actual handoff tileset PNGs so nothing about
# Berlin's look changes. [dawn, morning] per TILE_* id, in the same order.
#
# These used to be blitted from tiles/tileset_<mode>.png. The atlas is still
# there and its pixels are correct — every tile measured opaque and correctly
# coloured, with no white and no transparency — but every floor drawn through
# draw_texture_rect_region() came out white in game, with nothing in the Godot
# output log to say why. Rather than ship a floor that depends on a blit I
# could not explain, the ground is now drawn outright. draw_rect() with an
# explicit opaque colour cannot come out white.
const GROUND := [
	[Color(0.133, 0.137, 0.192), Color(0.298, 0.302, 0.369)],   # sidewalk
	[Color(0.133, 0.137, 0.192), Color(0.298, 0.302, 0.365)],   # sidewalk_b
	[Color(0.137, 0.141, 0.196), Color(0.302, 0.306, 0.369)],   # kerb
	[Color(0.086, 0.090, 0.122), Color(0.227, 0.231, 0.282)],   # asphalt
	[Color(0.102, 0.106, 0.141), Color(0.247, 0.251, 0.302)],   # asphalt_dash
	[Color(0.188, 0.192, 0.251), Color(0.349, 0.353, 0.416)],   # crosswalk
	[Color(0.125, 0.129, 0.180), Color(0.286, 0.290, 0.345)],   # cobble
	[Color(0.110, 0.227, 0.149), Color(0.180, 0.361, 0.220)],   # grass
	[Color(0.110, 0.227, 0.149), Color(0.180, 0.365, 0.220)],   # grass_b
	[Color(0.200, 0.165, 0.149), Color(0.353, 0.298, 0.251)],   # dirt
	[Color(0.082, 0.071, 0.094), Color(0.165, 0.149, 0.188)],   # burn
	[Color(0.271, 0.133, 0.173), Color(0.271, 0.133, 0.173)],   # carpet
	[Color(0.388, 0.267, 0.161), Color(0.388, 0.267, 0.161)],   # wood
	[Color(0.365, 0.188, 0.216), Color(0.365, 0.188, 0.216)],   # runner
]


# Fill a WORLD-space rect with one ground type, inside a CanvasItem's _draw().
# Pattern lands on a 32px grid anchored at rect.position.
static func draw_tiles(ci: CanvasItem, tile: int, rect: Rect2) -> void:
	var idx: int = clampi(tile, 0, GROUND.size() - 1)
	var pair: Array = GROUND[idx]
	var base: Color = pair[1] if mode() == "morning" else pair[0]
	ci.draw_rect(rect, base)
	_ground_pattern(ci, idx, rect, base)


# The grain on top of the base. Each ground type gets the pattern it should
# have — planks run, carpet mottles, cobbles course, asphalt just dirties —
# so a floor still reads as a material and not as a flat colour swatch.
static func _ground_pattern(ci: CanvasItem, idx: int, rect: Rect2, base: Color) -> void:
	var dark: Color = Color(0, 0, 0, 0.16)
	var lite: Color = Color(1, 1, 1, 0.045)
	var cols: int = int(ceil(rect.size.x / 32.0))
	var rows: int = int(ceil(rect.size.y / 32.0))

	if idx == TILE_WOOD or idx == TILE_RUNNER:
		# Boards run the length of the room, staggered end joints
		var bh: float = 22.0
		var n: int = int(ceil(rect.size.y / bh))
		for r in range(n):
			var y: float = rect.position.y + float(r) * bh
			ci.draw_rect(Rect2(rect.position.x, y, rect.size.x, 1.0), dark)
			if r % 2 == 0:
				ci.draw_rect(Rect2(rect.position.x, y + 1.0, rect.size.x, 2.0), lite)
			var joint: float = rect.position.x + float((r * 137) % 7) * 74.0
			ci.draw_rect(Rect2(joint, y, 1.5, bh), dark)
		if idx == TILE_RUNNER:
			ci.draw_rect(Rect2(rect.position.x, rect.position.y, rect.size.x, 3.0),
				Color(base.r, base.g, base.b, 0.0))
		return

	if idx == TILE_CARPET:
		# Mottle, not a grid — carpet has no seams, it has wear
		for r in range(rows * 2):
			for c in range(cols * 2):
				if (r * 7 + c * 13) % 5 != 0:
					continue
				ci.draw_rect(Rect2(rect.position.x + float(c) * 16.0,
					rect.position.y + float(r) * 16.0, 16, 16),
					Color(0, 0, 0, 0.05))
		return

	if idx == TILE_GRASS or idx == TILE_GRASS_B or idx == TILE_DIRT or idx == TILE_BURN:
		# Broken ground: speckle, no straight lines anywhere
		for r in range(rows * 2):
			for c in range(cols * 2):
				var s: int = (r * 31 + c * 17) % 9
				if s > 2:
					continue
				var px: float = rect.position.x + float(c) * 16.0 + float(s) * 3.0
				var py: float = rect.position.y + float(r) * 16.0 + float((s * 5) % 11)
				ci.draw_rect(Rect2(px, py, 5.0 + float(s), 3.0),
					dark if s % 2 == 0 else lite)
		return

	# Paving, kerb, asphalt, cobble: a course grid, offset row to row
	for r in range(rows):
		var y: float = rect.position.y + float(r) * 32.0
		ci.draw_rect(Rect2(rect.position.x, y, rect.size.x, 1.0), dark)
		var off: float = 16.0 if r % 2 == 1 else 0.0
		for c in range(cols + 1):
			var x: float = rect.position.x + off + float(c) * 32.0
			if x < rect.position.x or x > rect.end.x:
				continue
			ci.draw_rect(Rect2(x, y, 1.0, minf(32.0, rect.end.y - y)), dark)
		if r % 3 == 0:
			ci.draw_rect(Rect2(rect.position.x, y + 1.0, rect.size.x, 1.0), lite)
