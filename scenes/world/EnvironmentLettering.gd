extends RefCounted

# Lettering is authored text rendered by the game, independent of painted art.
# Integer font sizes, a fixed baseline and consistent spacing replace warped
# generated glyphs. Repaint only the inset fascia; preserve its existing frame.
static var _font: Font
static var _script_fonts: Dictionary = {}

static func font(path: String = "") -> Font:
	if not path.is_empty():
		if not _script_fonts.has(path):
			var loaded: FontFile = load(path).duplicate()
			loaded.multichannel_signed_distance_field = false
			loaded.antialiasing = TextServer.FONT_ANTIALIASING_NONE
			var script_face := FontVariation.new()
			script_face.base_font = loaded
			if path.ends_with("NotoSansKR.ttf") or path.ends_with("NotoSansJP.ttf") or path.ends_with("NotoSansDevanagari.ttf"):
				# These variable fonts default to their thinnest master.
				var weight_tag: int = TextServerManager.get_primary_interface().name_to_tag("wght")
				script_face.variation_opentype = {weight_tag: 600.0}
			script_face.variation_embolden = 0.25
			_script_fonts[path] = script_face
		return _script_fonts[path]
	if _font == null:
		var base: Font = ThemeDB.fallback_font.duplicate()
		if base is FontFile:
			base.multichannel_signed_distance_field = false
			base.antialiasing = TextServer.FONT_ANTIALIASING_NONE
		var face := FontVariation.new()
		face.base_font = base
		face.variation_embolden = 0.25
		_font = face
	return _font

static func draw(ci: CanvasItem, sign: Dictionary, origin: Vector2, tint: Color) -> void:
	var a: Array = sign["rect"]
	var r := Rect2(Vector2(a[0],a[1])-origin,Vector2(a[2],a[3]))
	var paper := Color(String(sign.get("background","#173649"))) * tint
	var ink := Color(String(sign.get("ink","#f3ecd9"))) * tint
	ci.draw_rect(r,paper)
	if bool(sign.get("border",false)):
		ci.draw_rect(r.grow(-2),ink.darkened(0.5),false,1.0)
	var lines: PackedStringArray = String(sign["text"]).split("\n")
	var face := font(String(sign.get("font", "")))
	var size: int = int(sign.get("size",18))
	while size > 6:
		var fits: bool = float(lines.size())*face.get_height(size) <= r.size.y-4
		for line: String in lines:
			fits = fits and face.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x <= r.size.x-8
		if fits: break
		size -= 1
	var line_h: float = ceilf(face.get_height(size))
	var baseline: float = roundf(r.position.y+(r.size.y-lines.size()*line_h)*0.5+face.get_ascent(size))
	for line: String in lines:
		var width: float = face.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
		ci.draw_string(face,Vector2(roundf(r.get_center().x-width*0.5),baseline),line,
			HORIZONTAL_ALIGNMENT_LEFT,-1,size,ink)
		baseline += line_h
