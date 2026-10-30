extends RefCounted

# Cosmetic data only. Both authored sprite strips and cutscene pixels use this
# palette, so a save never depends on a generated texture or a UI node.
const DEFAULT := {"skin": 0, "coat": 0, "accent": 0, "eyes": 0, "boots": 0, "antenna": 0, "outfit": 0}
const SKIN := [Color8(195,178,222), Color8(141,205,187), Color8(158,193,231), Color8(230,167,166), Color8(219,199,132), Color8(164,163,211), Color8(219,209,196), Color8(115,147,169)]
const COAT := [Color8(71,131,124), Color8(93,107,171), Color8(161,91,113), Color8(174,132,65), Color8(95,125,84), Color8(117,89,149), Color8(187,177,160), Color8(65,65,86)]
const ACCENT := [Color8(226,180,92), Color8(214,210,235), Color8(127,221,207), Color8(234,154,167), Color8(166,188,243), Color8(178,219,124)]
const EYES := [Color8(42,35,64), Color8(34,72,71), Color8(63,51,101), Color8(93,51,52), Color8(74,65,30), Color8(26,46,69)]
const BOOTS := [Color8(138,98,68), Color8(79,74,96), Color8(106,112,94), Color8(142,90,112), Color8(171,152,120), Color8(57,81,99)]
const COLORS := {"skin": SKIN, "coat": COAT, "accent": ACCENT, "eyes": EYES, "boots": BOOTS}
const ANTENNA := [
	["....g......g....", "...XS......SX...", "...XSS....SSX..."],
	["....gg....gg....", "...XSSX..XSSX...", "....XS....SX...."],
	["......gggg......", ".....XSSSSX.....", "....XSSSSSSX...."],
	["...g........g...", "...XS......SX...", "....XS....SX...."],
]
const BASE := {
	"X": Color8(92,76,126), "S": Color8(195,178,222), "L": Color8(222,210,240),
	"H": Color8(147,127,184), "E": Color8(42,35,64), "W": Color8(244,239,255),
	"O": Color8(36,71,68), "C": Color8(71,131,124), "D": Color8(53,100,94),
	"g": Color8(226,180,92), "B": Color8(138,98,68), "K": Color8(86,64,44),
}
static var _strips: Dictionary = {}
static var _cache_key := ""


static func sanitize(value: Variant) -> Dictionary:
	var result := DEFAULT.duplicate()
	if not value is Dictionary:
		return result
	for key: String in result:
		var raw: Variant = value.get(key, 0)
		if not (raw is int or raw is float) or not is_finite(float(raw)):
			continue
		var count: int = COLORS[key].size() if COLORS.has(key) else (ANTENNA.size() if key == "antenna" else 3)
		result[key] = clampi(int(raw), 0, count - 1)
	return result


static func current() -> Dictionary:
	var tree := Engine.get_main_loop() as SceneTree
	var state := tree.root.get_node_or_null("GameState") if tree != null else null
	return sanitize(state.alien_appearance if state != null else DEFAULT)


static func palette(appearance: Dictionary) -> Dictionary:
	var choice := sanitize(appearance)
	var pal := BASE.duplicate()
	if choice.skin != 0:
		var skin: Color = SKIN[choice.skin]
		pal.S = skin
		pal.L = skin.lightened(0.25)
		pal.H = skin.darkened(0.24)
		pal.X = skin.darkened(0.52)
	if choice.coat != 0:
		var coat: Color = COAT[choice.coat]
		pal.C = coat
		pal.D = coat.darkened(0.24)
		pal.O = coat.darkened(0.46)
	pal.g = ACCENT[choice.accent]
	pal.E = EYES[choice.eyes]
	if choice.boots != 0:
		pal.B = BOOTS[choice.boots]
		pal.K = Color(pal.B).darkened(0.36)
	return pal


static func dress(rows: Array, appearance: Dictionary) -> void:
	var choice := sanitize(appearance)
	for y in range(3):
		rows[y] = ANTENNA[choice.antenna][y]
	if choice.outfit == 0:
		return
	for y in [18, 20]:
		var row: String = rows[y]
		for x in range(row.length()):
			if row[x] in ["C", "D"] and (choice.outfit == 1 or x in [4, 5, 10, 11]):
				row = row.substr(0, x) + "g" + row.substr(x + 1)
		rows[y] = row


static func strip(animation: String, appearance: Dictionary) -> Texture2D:
	var choice := sanitize(appearance)
	var key := JSON.stringify(choice)
	if key != _cache_key:
		_strips.clear()
		_cache_key = key
	if _strips.has(animation):
		return _strips[animation]
	var original := load("res://art/player/strips/" + animation + ".png") as Texture2D
	if choice == DEFAULT:
		return original
	var source := original.get_image()
	var output := source.duplicate() as Image
	output.convert(Image.FORMAT_RGBA8)
	var pal := palette(choice)
	var lookup := {}
	for letter: String in BASE:
		lookup[Color(BASE[letter]).to_rgba32()] = pal[letter]
	for y in range(source.get_height()):
		for x in range(source.get_width()):
			var color := source.get_pixel(x, y)
			if color.a == 0.0:
				continue
			var replacement: Color = lookup.get(color.to_rgba32(), color)
			if choice.outfit != 0 and y in [20, 22] and color in [BASE.C, BASE.D]:
				if choice.outfit == 1 or x % 32 in [12, 13, 18, 19]:
					replacement = pal.g
			output.set_pixel(x, y, replacement)
	if choice.antenna != 0:
		for frame in range(source.get_width() / 32):
			var top := 32
			for y in range(8):
				for x in range(32):
					if source.get_pixel(frame * 32 + x, y).a > 0.0:
						top = mini(top, y)
			if top >= 8:
				continue
			for y in range(3):
				for x in range(32):
					output.set_pixel(frame * 32 + x, top + y, Color.TRANSPARENT)
				for x in range(16):
					var letter: String = ANTENNA[choice.antenna][y][x]
					if pal.has(letter):
						output.set_pixel(frame * 32 + 8 + x, top + y, pal[letter])
	var texture := ImageTexture.create_from_image(output)
	_strips[animation] = texture
	return texture
