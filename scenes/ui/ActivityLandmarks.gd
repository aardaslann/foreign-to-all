extends RefCounted

# Separate places visited within activities. Characters and ambience stay live.
static var _catalog: Dictionary = {}
static var _textures: Dictionary = {}

static func record(key: String, set_name: String) -> Dictionary:
	if _catalog.is_empty():
		_catalog = JSON.parse_string(FileAccess.get_file_as_string(
			"res://art/environments/activity-sets.json"))
	var id: String = key.replace(":", "-")
	if key == "hanoi:badinh" and set_name == "pagoda":
		id = "hanoi-pagoda"
	elif key == "tbilisi:avlabari" and set_name == "interior":
		id = "tbilisi-bath"
	return _catalog.get(id, {})

static func draw(ci: CanvasItem, key: String, set_name: String,
		w: float, h: float, t: float, morning: bool) -> bool:
	var data: Dictionary = record(key, set_name)
	if data.is_empty(): return false
	var path: String = data["texture"]
	if not _textures.has(path):
		_textures[path] = load(path)
	var tex: Texture2D = _textures[path]
	if tex == null: return false
	var source: Array = data["source"]
	var src := Rect2(source[0],source[1],source[2],source[3])
	var aspect: float = w / h
	if src.size.x / src.size.y > aspect:
		var width: float = src.size.y * aspect
		src.position.x += (src.size.x-width)*.5
		src.size.x = width
	else:
		var height: float = src.size.x/aspect
		src.position.y += (src.size.y-height)*.5
		src.size.y = height
	var tint := Color.WHITE if morning else Color(.56,.64,.80)
	ci.draw_texture_rect_region(tex,Rect2(0,0,w,h),src,tint)
	if key == "tbilisi:avlabari" and set_name == "interior":
		_ripples(ci,Rect2(w*.12,h*.70,w*.44,h*.09),t,18,morning)
	elif key == "tbilisi:avlabari":
		for x in [.232,.507,.804]:
			for i in range(5):
				var rise: float = fposmod(t*.022+i*.017,.086)
				var alpha: float = (1.0-rise/.086)*.25
				var xx: float = x+sin(rise*42+i)*.003
				ci.draw_rect(Rect2(w*xx,h*(.44-rise),w*.003,h*.012),
					Color(.92,.94,.92,alpha))
	elif key == "zurich:oerlikon":
		_ripples(ci,Rect2(w*.435,h*.706,w*.17,h*.016),t,9,morning)
	elif key == "hanoi:badinh" and set_name == "pagoda":
		_ripples(ci,Rect2(w*.60,h*.651,w*.075,h*.025),t,7,morning)
	return true

static func _ripples(ci: CanvasItem, area: Rect2, t: float, count: int, morning: bool) -> void:
	for i in range(count):
		var x: float = area.position.x+fposmod(i*17.0+t*2.4,area.size.x)
		var y: float = area.position.y+fposmod(i*7.0,area.size.y)
		var alpha: float = (.13+.08*sin(t*1.4+i))*(1.0 if morning else .5)
		ci.draw_line(Vector2(x,y),Vector2(minf(x+5,area.end.x),y),
			Color(.8,.96,.94,alpha),1.0)
