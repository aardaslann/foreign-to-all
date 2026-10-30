extends RefCounted

const INK := Color("edf0e7")
const MUTED := Color("a5b8ae")
const GOLD := Color("e7ba76")
const MINT := Color("8ce2c7")
const CORAL := Color("ed9d91")
const PAPER := Color("182c2b")
const EDGE := Color("4c6962")
const DARK := Color("101c20")
static var _icons: Dictionary = {}
const PIXELS := {
	"close": ["...........", ".xx.....xx.", "..xx...xx..", "...xx.xx...", "....xxx....", ".....x.....", "....xxx....", "...xx.xx...", "..xx...xx..", ".xx.....xx.", "..........."],
	"plus": ["...........", "....xxx....", "....xxx....", "....xxx....", ".xxxxxxxxx.", ".xxxxxxxxx.", ".xxxxxxxxx.", "....xxx....", "....xxx....", "....xxx....", "..........."],
	"minus": ["...........", "...........", "...........", "...........", ".xxxxxxxxx.", ".xxxxxxxxx.", ".xxxxxxxxx.", "...........", "...........", "...........", "..........."],
	"here": ["....xxx....", "....xxx....", "..xxxxxxx..", "..x.....x..", "xxx.xxx.xxx", "xxx.xxx.xxx", "xxx.xxx.xxx", "..x.....x..", "..xxxxxxx..", "....xxx....", "....xxx...."],
	"door": ["..xxxxxxx..", "..x.....x..", "..x.xxx.x..", "..x.xxx.x..", "..x.....x..", "..x...x.x..", "..x.....x..", "..x.....x..", "..x.....x..", ".xxxxxxxxx.", "xxxxxxxxxxx"],
	"transit": ["..xxxxxxx..", ".xxxxxxxxx.", ".xx.....xx.", ".xx.....xx.", ".xxxxxxxxx.", ".xxxxxxxxx.", ".xx.....xx.", "..xxxxxxx..", "...x...x...", "..x.....x..", ".xxxxxxxxx."],
	"activity": [".....x.....", "....xxx....", "....xxx....", "xxxxxxxxxxx", ".xxxxxxxxx.", "..xxxxxxx..", "..xxxxxxx..", "..xxx.xxx..", ".xxx...xxx.", ".xx.....xx.", "..........."],
	"service": ["..xxxxxxx..", ".x.......x.", "x..xxxxx..x", "x....x....x", "x...xx....x", "x...x.....x", "x.........x", "x...xx....x", "x...xx....x", ".x.......x.", "..xxxxxxx.."],
}

static func icon(kind: String) -> Texture2D:
	if _icons.has(kind): return _icons[kind]
	var image := Image.create(11, 11, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var rows: Array = PIXELS.get(kind, PIXELS.door)
	for y in range(11):
		for x in range(11):
			if rows[y][x] == "x": image.set_pixel(x, y, Color.WHITE)
	var texture := ImageTexture.create_from_image(image)
	_icons[kind] = texture
	return texture

static func label(text: String, font_size := 20, color := INK) -> Label:
	var node := Label.new()
	node.text = text
	node.add_theme_font_override("font", UIStyles.reading_font)
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	return node

static func button(text: String, symbol := "") -> Button:
	var node := Button.new()
	node.text = text
	node.custom_minimum_size = Vector2(48, 46)
	node.add_theme_font_override("font", UIStyles.reading_font)
	node.add_theme_font_size_override("font_size", 20)
	node.add_theme_color_override("font_color", INK)
	if not symbol.is_empty():
		node.icon = icon(symbol)
		node.expand_icon = true
		node.add_theme_constant_override("icon_max_width", 22)
		node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for state: String in ["normal", "hover", "pressed", "hover_pressed", "focus"]:
		var box := StyleBoxFlat.new()
		box.bg_color = Color("29433b") if state in ["pressed", "hover_pressed"] else PAPER
		box.border_color = GOLD if state in ["pressed", "hover_pressed", "focus"] else EDGE
		box.set_border_width_all(2 if state == "focus" else 1)
		if state == "hover": box.bg_color = Color("344941")
		if state == "focus": box.bg_color = Color.TRANSPARENT
		box.content_margin_left = 12
		box.content_margin_right = 12
		node.add_theme_stylebox_override(state, box)
	return node
