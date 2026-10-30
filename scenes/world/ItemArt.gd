extends RefCounted

# Hand-authored pixel objects. One cached 32px sprite follows each item from
# pavement to pickup card; the separate prop mappings also serve held loads.
const IDS := ["bread", "cheese", "karte", "ticket_ubahn", "zimmerkarte",
	"lost_parcel", "police_bag", "hospital_dish", "money", "charm_eye",
	"ameyoko_box", "api", "apple", "arepa", "banh_mi", "bec", "brass_thing",
	"brixton_bag", "causeway_thing", "churchkhela", "cider", "cloth", "coat",
	"falafel", "fruit_crate", "kebab", "kermel_flowers", "lei", "market_bag",
	"menchi_katsu", "mortadela", "old_book", "omikuji_bad", "omikuji_good",
	"pastel", "portrait", "potatoes", "quinto_quarto", "shave_ice", "simit",
	"soviet_badge", "spice_cone", "spray_can", "sulguni", "tomatoes", "tostada",
	"tower_charm", "transit_card", "wax_cloth", "wax_votive", "yoff_fish"]
const PROPS := {"tray":"tray", "flowers":"kermel_flowers", "broom":"broom",
	"broomup":"broom", "crate":"crate", "box":"lost_parcel", "papers":"papers",
	"bag":"police_bag", "glass":"api", "book":"old_book", "phone":"phone",
	"loaf":"bread", "fish":"yoff_fish", "cloth":"cloth", "record":"record",
	"brass":"brass_thing", "basket":"basket"}
const INK := Color("292932")
const PAPER := Color("e9dcc0")
const GOLD := Color("d9aa50")
const GREEN := Color("668a50")
const RED := Color("b34846")
static var _textures: Dictionary = {}
static var _regions: Dictionary = {}


class Pixels:
	extends RefCounted
	var image: Image

	func _init(width: int = 32, height: int = 32) -> void:
		image = Image.create(width, height, false, Image.FORMAT_RGBA8)
		image.fill(Color.TRANSPARENT)

	func dot(x: int, y: int, color: Color) -> void:
		if x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
			image.set_pixel(x, y, color)

	func box(x: int, y: int, w: int, h: int, color: Color) -> void:
		image.fill_rect(Rect2i(x, y, w, h).intersection(Rect2i(0,0,image.get_width(),image.get_height())), color)

	func oval(x: int, y: int, w: int, h: int, color: Color) -> void:
		for py in range(y, y + h):
			for px in range(x, x + w):
				var d := Vector2((px-x+0.5)/float(w)*2.0-1.0, (py-y+0.5)/float(h)*2.0-1.0)
				if d.length_squared() <= 1.0: dot(px, py, color)

	func poly(points: Array, color: Color) -> void:
		var polygon := PackedVector2Array()
		for point: Array in points: polygon.append(Vector2(point[0], point[1]))
		for y in range(image.get_height()):
			for x in range(image.get_width()):
				if Geometry2D.is_point_in_polygon(Vector2(x+0.5, y+0.5), polygon): dot(x,y,color)

	func line(x: int, y: int, ex: int, ey: int, color: Color) -> void:
		var steps := maxi(absi(ex-x), absi(ey-y))
		for i in range(steps + 1):
			var f := float(i) / maxi(1, steps)
			dot(roundi(lerpf(x,ex,f)), roundi(lerpf(y,ey,f)), color)

	func outline() -> void:
		var source := image.duplicate() as Image
		for y in range(1, image.get_height()-1):
			for x in range(1, image.get_width()-1):
				if source.get_pixel(x,y).a > 0: continue
				for direction: Vector2i in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
					if source.get_pixel(x+direction.x,y+direction.y).a > 0:
						dot(x,y,Color("292932"))
						break


static func has_icon(id: String) -> bool:
	return id in IDS


static func texture(id: String) -> Texture2D:
	if not _textures.has(id):
		var p := Pixels.new()
		_paint(p, id)
		p.outline()
		_textures[id] = ImageTexture.create_from_image(p.image)
		_regions[id] = Rect2(p.image.get_used_rect())
	return _textures[id]


static func draw_fitted(ci: CanvasItem, rect: Rect2, id: String) -> void:
	var sprite := texture(id)
	ci.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ci.draw_texture_rect_region(sprite, rect, _regions[id])


static func draw(ci: CanvasItem, at: Vector2, unit: float, id: String) -> void:
	ci.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var size := Vector2.ONE * 24.0 * unit
	ci.draw_texture_rect(texture(id), Rect2((at-size*0.5).round(), size), false)


static func _fruit(p: Pixels, x: int, y: int, color: Color, apple: bool = true) -> void:
	p.oval(x,y,12,13,color.darkened(.26))
	p.oval(x,y,10,10,color)
	p.box(x+2,y+2,3,2,color.lightened(.38))
	p.dot(x+1,y+4,color.lightened(.24))
	p.line(x+6,y+1,x+7,y-3,Color("705339"))
	p.line(x+7,y-2,x+10,y-3,GREEN)
	p.box(x+8,y-2,3,1,GREEN.lightened(.2))
	if not apple:
		p.line(x+3,y+1,x+8,y+2,GREEN)
		p.line(x+6,y-1,x+4,y+3,GREEN)


static func apple_crate() -> Texture2D:
	if _textures.has("apple_crate"): return _textures["apple_crate"]
	var p := Pixels.new(64,44)
	p.poly([[2,17],[12,9],[57,10],[61,18],[59,41],[4,41]],Color("514335"))
	p.poly([[3,18],[12,11],[56,12],[58,18]],Color("806145"))
	p.box(7,18,50,21,Color("4c4030"))
	for row: Array in [[10,6,0],[24,5,1],[38,6,0],[5,14,1],[18,13,0],[32,14,0],[45,13,1]]:
		_fruit(p,row[0],row[1],RED if row[2] == 0 else Color("b9aa52"))
	for y in [24,31,38]:
		p.box(3,y,57,5,Color("967047"))
		p.box(3,y,57,1,Color("c9a575"))
		p.box(4,y+4,54,1,Color("684f3b"))
		for x in [10,29,45]:
			p.box(x,y+2,7,1,Color("805b3e"))
			p.dot(x+5,y+1,Color("b58e5b"))
	for x in [3,56]:
		p.box(x,20,4,23,Color("a98050"))
		p.box(x,20,1,22,Color("d1ad78"))
		for y in [25,39]: p.dot(x+2,y,Color("48413a"))
	p.box(18,25,29,10,PAPER)
	p.box(20,24,3,3,Color("b9ae84"))
	p.box(42,33,3,3,Color("b9ae84"))
	p.outline()
	_textures["apple_crate"] = ImageTexture.create_from_image(p.image)
	return _textures["apple_crate"]


static func _loaf(p: Pixels, x: int, y: int, w: int, h: int) -> void:
	p.oval(x,y,w,h,Color("8f5739"))
	p.oval(x,y,w-1,h-3,Color("c48a49"))
	p.oval(x+2,y+1,w-5,h-5,Color("dfb471"))
	for i in range(3):
		var sx := x+4+i*maxi(3,(w-7)/3)
		p.line(sx,y+3,sx-2,y+6,Color("f5d799"))
		p.line(sx+1,y+3,sx-1,y+6,Color("a76d40"))


# A split white-corn cake, griddled in patches, stuffed with avocado chicken
# (reina pepiada) and a line of soft white cheese.
static func _arepa(p: Pixels) -> void:
	p.oval(4,17,24,11,Color("a87a40"))
	p.oval(5,17,22,9,Color("e3c47f"))
	p.box(3,15,26,3,Color("7fa94f"))
	p.box(4,15,24,1,Color("a3c46b"))
	for x in [6,12,19,24]: p.box(x,16,3,1,Color("f1e6c8"))
	p.box(6,18,20,1,Color("f6f3e6"))
	p.oval(4,4,24,11,Color("a87a40"))
	p.oval(5,4,22,9,Color("e8cb88"))
	p.box(9,6,7,1,Color("f6e2ad"))
	for at: Vector2i in [Vector2i(8,9),Vector2i(17,7),Vector2i(21,10),Vector2i(13,11),Vector2i(24,8)]:
		p.box(at.x,at.y,2,1,Color("9a6634"))


# A long crackly baguette, scored on top, split along its length and spilling
# pickled carrot and daikon, cilantro and chilli out of the open end.
static func _banh_mi(p: Pixels) -> void:
	p.oval(1,16,30,9,Color("a8682f"))
	p.oval(2,16,28,7,Color("d79a4c"))
	p.box(3,15,25,2,Color("c97a68"))
	for x in [5,11,17,22]:
		p.box(x,14,4,1,Color("efe9d8"))
		p.box(x+2,13,3,1,Color("e98a3a"))
	p.oval(1,6,30,10,Color("a8682f"))
	p.oval(2,6,28,8,Color("de9f4d"))
	p.box(5,7,17,1,Color("f0c27a"))
	for x in [7,12,17,22]: p.line(x,8,x+2,11,Color("9b5a28"))
	p.line(26,13,30,10,Color("e98a3a"))
	p.line(27,15,30,14,Color("efe9d8"))
	for at: Vector2i in [Vector2i(26,11),Vector2i(28,12),Vector2i(29,9),Vector2i(27,9)]:
		p.dot(at.x,at.y,Color("5f9a3f"))
	p.dot(28,10,Color("7fbf5a"))
	p.dot(29,13,Color("c43b2f"))


# The bodega breakfast: bacon, egg and melting cheese on a kaiser roll, the
# bottom half still in its foil.
static func _bec(p: Pixels) -> void:
	p.poly([[3,19],[29,17],[27,29],[6,29]],Color("98a5a8"))
	p.poly([[4,19],[27,18],[25,28],[7,28]],Color("c5ced0"))
	p.line(8,22,15,27,Color("eef2ef"))
	p.line(18,20,23,26,Color("eef2ef"))
	p.box(5,16,22,3,Color("f4f1e2"))
	p.oval(11,15,8,4,Color("f2c23b"))
	p.line(5,15,26,14,Color("a3443a"))
	p.line(6,16,25,15,Color("d77a63"))
	p.box(5,18,22,1,Color("f0a63a"))
	for at: Vector2i in [Vector2i(8,19),Vector2i(8,20),Vector2i(20,19),Vector2i(20,20),Vector2i(20,21)]:
		p.dot(at.x,at.y,Color("f0a63a"))
	p.oval(4,3,24,13,Color("a76a33"))
	p.oval(5,3,22,11,Color("d39a52"))
	for end: Vector2i in [Vector2i(10,5),Vector2i(22,5),Vector2i(9,11),Vector2i(23,11),Vector2i(16,4)]:
		p.line(16,8,end.x,end.y,Color("a76a33"))
	for at: Vector2i in [Vector2i(8,7),Vector2i(13,5),Vector2i(19,6),Vector2i(24,8),Vector2i(12,12),Vector2i(20,12)]:
		p.dot(at.x,at.y,Color("3a3436"))


# São Paulo's market sandwich: a small French roll that cannot close over the
# towering stack of mortadella, with melted cheese on top.
static func _mortadela(p: Pixels) -> void:
	p.oval(6,24,20,7,Color("b47a3e"))
	p.oval(7,24,18,5,Color("e0ac63"))
	for i in range(6):
		var y := 22 - i * 2
		var shift := 1 if i % 2 == 0 else -1
		p.box(3 + shift,y,26,2,Color("d98890"))
		p.box(4 + shift,y,24,1,Color("f2b3b6"))
		p.dot(8 + i * 3,y,Color("fbe3df"))
		p.dot(22 - i * 2,y + 1,Color("fbe3df"))
	p.dot(12,15,Color("8da45a"))
	p.dot(19,19,Color("8da45a"))
	p.box(5,10,22,2,Color("f2d27a"))
	for x in [7,15,23]: p.box(x,12,1,2,Color("f2d27a"))
	p.oval(7,2,18,9,Color("b47a3e"))
	p.oval(8,2,16,7,Color("e4b06a"))
	p.line(10,5,21,5,Color("f6d48f"))
	p.line(11,6,20,6,Color("c8914c"))


# Ameyoko street food: a minced-meat cutlet in a coarse panko crust, broken
# open in its paper sleeve to show it is meat, not a bun.
static func _menchi_katsu(p: Pixels) -> void:
	p.oval(5,4,22,19,Color("8a5326"))
	p.oval(6,5,20,16,Color("c98a39"))
	var crumbs := [[8,8],[11,6],[14,9],[9,12],[13,14],[7,16],[16,6],[18,11],[11,18],[15,17],[20,15],[22,9]]
	for i in range(crumbs.size()):
		var c: Array = crumbs[i]
		p.box(c[0],c[1],2 if i % 3 == 0 else 1,1,Color("ebb862") if i % 2 == 0 else Color("9c5f28"))
	for at: Vector2i in [Vector2i(5,9),Vector2i(26,12),Vector2i(9,4),Vector2i(23,6),Vector2i(4,14)]:
		p.dot(at.x,at.y,Color("8a5326"))
	# The bite: a notch out of the top edge, its rim the juicy minced meat.
	p.oval(16,1,13,13,Color("7a4a37"))
	for at: Vector2i in [Vector2i(17,9),Vector2i(20,11),Vector2i(24,12),Vector2i(18,6)]:
		p.dot(at.x,at.y,Color("b07a5c"))
	p.oval(18,0,12,10,Color.TRANSPARENT)
	p.poly([[4,18],[28,16],[26,29],[7,29]],PAPER)
	p.line(8,22,25,20,Color("cfc5a6"))
	p.line(9,26,24,25,Color("bcb391"))


# A good fortune is kept: the open slip, red shrine seal at its head.
static func _omikuji_good(p: Pixels) -> void:
	_paper(p,PAPER,10,3,12,26)
	p.box(11,4,9,5,Color("b8352c"))
	p.box(13,5,5,3,GOLD)
	p.box(14,6,3,1,Color("b8352c"))
	for x in [12,16]:
		for y in range(11,26,3):
			p.box(x,y,2,1,INK)
	for at: Vector2i in [Vector2i(25,4),Vector2i(24,5),Vector2i(26,5),Vector2i(25,6),Vector2i(25,3)]:
		p.dot(at.x,at.y,GOLD)


static func _omikuji_bad(p: Pixels) -> void:
	p.line(1,12,30,11,Color("b9a06a"))
	p.line(1,13,30,12,Color("8c7748"))
	p.box(14,4,4,8,Color("e9dcc0"))
	p.box(14,4,1,8,Color("c9bb9c"))
	p.oval(11,9,10,7,Color("d8c9a8"))
	p.oval(12,10,8,4,Color("efe4cc"))
	p.line(15,11,17,13,Color("b9ab8a"))
	p.poly([[14,15],[18,15],[20,27],[16,27]],Color("e9dcc0"))
	p.line(15,16,17,26,Color("c9bb9c"))
	for y in [18,21,24]: p.box(17,y,1,1,INK)


static func _paper(p: Pixels, color: Color, x: int = 5, y: int = 8, w: int = 22, h: int = 17) -> void:
	p.box(x,y,w,h,color.darkened(.28))
	p.box(x,y,w-2,h-2,color)
	p.box(x+1,y+1,w-4,1,color.lightened(.16))


static func _bag(p: Pixels, color: Color, plastic: bool = false) -> void:
	p.box(10,5,12,8,color.darkened(.25))
	p.box(12,7,8,6,Color.TRANSPARENT)
	p.poly([[8,12],[24,12],[27,27],[6,27]], color.darkened(.25))
	p.poly([[8,12],[21,12],[23,26],[7,26]],color)
	p.line(9,14,8,24,color.lightened(.25))
	p.line(22,15,24,25,color.darkened(.4))
	if plastic:
		p.box(10,15,11,4,PAPER)
		p.box(12,16,7,1,INK)
		p.line(14,21,19,24,color.lightened(.35))
	else:
		p.box(10,18,10,5,color.lightened(.15))
		p.box(12,20,6,1,color.darkened(.28))


static func _crate(p: Pixels, fruit: bool) -> void:
	p.poly([[4,12],[10,7],[27,9],[27,25],[5,26]],Color("604632"))
	p.box(7,10,18,12,Color("423b31"))
	if fruit:
		_fruit(p,7,10,RED)
		_fruit(p,15,9,Color("d3ac48"))
	for y in [15,20,25]:
		p.box(5,y,22,3,Color("a5784e"))
		p.box(5,y,22,1,Color("d0aa71"))
		p.line(9,y+2,18,y+2,Color("805a3f"))
	for x in [5,24]:
		p.box(x,12,3,15,Color("bd925d"))
		for y in [15,23]: p.dot(x+1,y,INK)
	if not fruit:
		p.box(12,16,8,2,Color("423b31"))


static func _cup(p: Pixels, color: Color, contents: Color) -> void:
	p.oval(22,11,7,12,color.darkened(.2))
	p.oval(23,13,4,7,Color.TRANSPARENT)
	p.poly([[7,9],[24,9],[22,26],[10,26]],color.darkened(.24))
	p.poly([[8,10],[21,10],[20,25],[10,25]],color)
	p.box(10,13,2,9,color.lightened(.25))
	p.oval(7,7,17,6,PAPER)
	p.oval(9,8,13,4,contents)
	p.box(13,9,6,1,contents.lightened(.2))


static func _flowers(p: Pixels, wreath: bool) -> void:
	if wreath:
		p.oval(5,4,22,25,GREEN.darkened(.2))
		p.oval(9,7,14,18,Color.TRANSPARENT)
	else:
		p.poly([[9,15],[25,13],[18,28]],Color("bf9d70"))
		p.line(16,11,17,25,GREEN)
		p.line(21,8,16,26,GREEN)
	var centers: Array = [[8,8],[16,6],[24,10],[12,14],[21,16]]
	if wreath: centers = [[8,7],[15,5],[24,8],[25,16],[23,24],[15,27],[7,23],[6,16]]
	for i in range(centers.size()):
		var x: int = centers[i][0]
		var y: int = centers[i][1]
		var color: Color = [Color("d2778d"),Color("e4b353"),Color("d8b8c0")][i%3]
		p.box(x-2,y-3,4,7,color.darkened(.15))
		p.box(x-3,y-2,6,4,color)
		p.box(x-1,y-1,2,2,GOLD.lightened(.2))
	if not wreath: p.line(13,22,19,22,RED)


static func _paint(p: Pixels, id: String) -> void:
	match id:
		"water":
			p.box(12,3,8,4,Color("628d9d"))
			p.box(13,7,6,3,Color("b7dae0"))
			p.poly([[10,10],[13,8],[19,8],[22,10],[23,25],[21,28],[11,28],[9,25]],Color("779da6"))
			p.box(11,13,10,9,Color("d6e5df"))
			p.box(12,15,8,3,Color("527c98"))
			p.box(11,23,3,3,Color("bce1e4"))
		"cay":
			p.oval(4,24,24,5,Color("b5afa4"))
			p.oval(7,24,18,3,Color("e4dbca"))
			p.poly([[9,5],[23,5],[22,10],[20,15],[21,22],[19,25],[13,25],[11,22],[12,15],[10,10]],Color("d5c9b7"))
			p.poly([[11,9],[21,9],[18,15],[19,22],[17,23],[14,22],[14,15]],Color("974e31"))
			p.box(12,10,2,4,Color("d29348"))
			p.box(17,18,1,4,Color("6b392c"))
			p.box(12,5,9,1,Color("eee3cf"))
		# Word-use near misses: German glues words together, so the juice
		# carries the fruit's name; the visitors' apple tea carries the tea's.
		"apfelsaft":
			p.box(13,2,6,3,Color("b8a46a"))
			p.box(14,5,4,5,Color("d6c79a"))
			p.poly([[10,11],[14,8],[18,8],[22,11],[22,28],[10,28]],Color("b9802f"))
			p.box(11,12,10,15,Color("e2a94a"))
			p.box(12,13,2,13,Color("f0c878"))
			p.box(10,16,12,8,PAPER)
			_fruit(p,13,17,RED)
			p.box(19,22,2,1,INK)
		"elma_cayi":
			p.poly([[7,6],[25,5],[26,27],[6,28]],Color("8f2f2b"))
			p.poly([[8,7],[24,6],[25,26],[7,26]],Color("c2453a"))
			p.box(8,6,17,4,Color("4f8a46"))
			p.oval(10,12,13,12,PAPER)
			_fruit(p,11,13,RED)
			for x in [9,13,17,21]: p.box(x,24,2,1,PAPER)
		"apple": _fruit(p,10,12,RED)
		"tomatoes":
			_fruit(p,4,13,Color("b84437"),false)
			_fruit(p,15,10,Color("ce593e"),false)
		"bread": _loaf(p,4,9,24,17)
		"cheese":
			p.poly([[5,21],[24,8],[27,24],[7,27]],Color("b78942"))
			p.poly([[5,19],[24,6],[26,17],[7,23]],Color("f2d17f"))
			p.poly([[7,23],[26,17],[26,24],[7,27]],Color("d6ad57"))
			for v: Vector2i in [Vector2i(17,12),Vector2i(21,20),Vector2i(12,20)]:
				p.oval(v.x,v.y,3,3,Color("b28543"))
		"karte":
			p.poly([[3,9],[11,6],[20,9],[28,6],[28,23],[20,26],[11,23],[3,26]],PAPER)
			p.poly([[11,6],[20,9],[20,26],[11,23]],Color("c6bf94"))
			p.line(11,7,11,22,Color("a89e7b"))
			p.line(21,10,26,8,Color("f7edcd"))
			p.line(5,22,24,11,Color("a26553"))
			p.line(5,14,26,22,Color("6d939c"))
			p.box(8,11,3,4,GREEN)
			p.box(21,20,3,3,GREEN)
			p.box(17,14,2,3,RED)
		"ticket_ubahn", "transit_card", "zimmerkarte":
			var color: Color = {"ticket_ubahn":Color("abc4aa"),"transit_card":Color("527f9c"),"zimmerkarte":Color("b39bc5")}[id]
			_paper(p,color,4,9,24,15)
			p.box(5,11,21,3,color.darkened(.38))
			if id == "ticket_ubahn":
				for x in range(7,19,2): p.box(x,18,1,3,INK)
				for y in range(11,24,3): p.dot(23,y,PAPER)
			elif id == "transit_card":
				p.box(7,17,5,4,GOLD)
				p.line(16,19,22,19,PAPER)
				p.line(20,17,23,19,PAPER)
			else:
				p.box(7,16,4,4,GOLD)
				p.box(13,17,10,1,PAPER)
		"lost_parcel", "ameyoko_box":
			p.poly([[5,11],[13,6],[27,10],[27,25],[5,25]],Color("a57953"))
			p.poly([[5,11],[13,6],[27,10],[20,15]],Color("dab47f"))
			p.box(5,12,15,13,Color("c49464"))
			p.line(20,15,20,25,Color("795438"))
			p.box(12,10,3,15,PAPER if id == "lost_parcel" else RED)
			p.box(5,18,22,2,PAPER if id == "lost_parcel" else RED)
			p.box(6,13,5,3,Color("f3e3bd"))
			p.box(7,14,3,1,INK)
		"police_bag": _bag(p,Color("879b9e"),true)
		"brixton_bag": _bag(p,Color("b95661"))
		"market_bag": _bag(p,Color("8da36d"))
		"hospital_dish":
			p.oval(4,7,24,20,Color("7e949c"))
			p.oval(5,7,22,17,Color("d9e0d7"))
			p.oval(7,9,18,13,Color("a2b7b7"))
			p.oval(11,4,9,9,Color.TRANSPARENT)
			p.line(8,19,12,21,Color("edf0dd"))
			p.line(17,22,22,19,Color("566d79"))
		"money":
			for row: Array in [[5,17],[16,19],[13,7]]:
				var x: int = row[0]
				var y: int = row[1]
				p.oval(x,y+2,12,9,Color("927144"))
				p.oval(x,y,12,9,GOLD)
				p.oval(x+2,y+1,8,6,Color("f3d384"))
				p.oval(x+3,y+2,6,4,Color("c39448"))
				p.line(x+6,y+2,x+6,y+5,PAPER)
		"charm_eye":
			p.box(15,3,3,5,GOLD)
			p.oval(5,8,22,21,Color("375780"))
			p.oval(7,9,18,17,Color("4c81af"))
			p.oval(9,13,14,10,PAPER)
			p.oval(12,14,8,8,Color("65a9bc"))
			p.oval(14,16,4,4,INK)
			p.box(9,11,3,2,Color("a7d4d3"))
		"money_pouch":
			p.poly([[10,7],[20,7],[18,13],[23,19],[22,26],[8,26],[6,20],[11,13]],Color("795744"))
			p.poly([[11,8],[16,8],[15,14],[10,21],[11,25],[8,24],[7,20],[12,13]],Color("ac8158"))
			p.line(17,15,19,24,Color("533f36"))
			p.box(10,12,9,2,GOLD)
			p.line(18,13,23,17,GOLD)
			for at: Vector2i in [Vector2i(23,23),Vector2i(4,26)]:
				p.oval(at.x,at.y,6,4,Color("9b7540"))
				p.oval(at.x,at.y,6,3,GOLD)
				p.box(at.x+2,at.y,2,1,PAPER)
		"api": _cup(p,Color("bd9770"),Color("753f6d"))
		"cider": _cup(p,Color("7d9b91"),Color("cb9a4c"))
		# Four cities' sandwiches, each drawn as itself rather than one roll
		# with a different stripe: what the bread is, is the point.
		"arepa": _arepa(p)
		"banh_mi": _banh_mi(p)
		"bec": _bec(p)
		"mortadela": _mortadela(p)
		"brass_thing":
			p.box(13,5,6,3,GOLD)
			p.box(15,7,2,7,Color("a7793e"))
			p.oval(7,13,19,10,GOLD)
			p.oval(9,13,15,5,Color("efd084"))
			p.box(14,21,4,4,Color("ad8040"))
			p.box(9,25,15,2,GOLD)
		"causeway_thing":
			p.poly([[10,27],[11,14],[8,10],[12,6],[21,7],[23,12],[21,18],[23,27]],Color("a76651"))
			p.poly([[13,26],[13,15],[11,10],[14,8],[19,9],[19,24]],Color("d29b70"))
			p.box(9,26,16,2,GOLD)
			p.box(14,12,5,2,Color("714939"))
		"churchkhela":
			p.line(16,3,16,8,PAPER)
			for y in [7,11,15,19,23]:
				p.oval(12,y,8,6,Color("783e51"))
				p.oval(12,y,6,4,Color("a5656c"))
				p.dot(14,y+1,Color("c98a80"))
		"cloth", "wax_cloth":
			_paper(p,Color("ad677b") if id == "cloth" else Color("518f96"),5,9,22,17)
			p.poly([[7,9],[12,5],[27,8],[25,12]],Color("d799a5") if id == "cloth" else Color("83b3a6"))
			p.line(9,21,25,21,Color("583f5b"))
			p.line(8,23,23,23,PAPER)
			for x in range(8,25,5):
				if id == "wax_cloth":
					p.line(x,13,x+2,16,GOLD)
					p.line(x+2,16,x,19,GOLD)
				else: p.box(x,12,1,8,Color("bb8090"))
		"coat":
			p.poly([[11,6],[21,6],[27,14],[23,19],[21,16],[23,28],[9,28],[11,16],[8,20],[4,15]],Color("4b5d70"))
			p.poly([[12,7],[15,9],[13,15],[11,10]],Color("8595a0"))
			p.poly([[20,7],[17,9],[19,15],[21,10]],Color("8595a0"))
			p.line(16,10,16,27,Color("303c50"))
			for y in [16,20,24]: p.dot(17,y,GOLD)
			p.box(10,21,4,2,Color("303c50"))
			p.box(19,21,3,2,Color("303c50"))
		"falafel":
			p.poly([[4,18],[26,16],[25,28],[9,27]],PAPER)
			p.line(10,24,23,26,Color("bcb391"))
			for at: Vector2i in [Vector2i(7,13),Vector2i(16,13),Vector2i(11,7)]:
				p.oval(at.x,at.y,9,10,Color("847846"))
				p.oval(at.x,at.y,7,7,Color("b19b57"))
				p.box(at.x+2,at.y+2,2,2,Color("d3be79"))
		"menchi_katsu": _menchi_katsu(p)
		"fruit_crate": _crate(p,true)
		"crate": _crate(p,false)
		"kebab":
			p.poly([[7,7],[25,9],[21,28],[12,28]],Color("c6ab80"))
			p.poly([[8,7],[24,9],[22,17],[10,17]],Color("8b6345"))
			for x in [9,13,17,21]:
				p.box(x,8+x%3,3,3,GREEN)
				p.box(x,12+x%2,2,2,RED)
			p.poly([[9,18],[23,15],[21,28],[12,28]],PAPER)
			p.line(13,19,19,25,Color("b2ac95"))
		"kermel_flowers": _flowers(p,false)
		"lei": _flowers(p,true)
		"old_book":
			p.poly([[6,7],[22,4],[26,8],[26,26],[9,28],[6,25]],Color("72514b"))
			p.box(9,8,16,17,Color("4f7776"))
			p.line(9,7,22,5,GOLD)
			p.box(10,25,15,2,PAPER)
			p.line(11,26,24,26,Color("aaa58b"))
			p.box(12,11,10,1,GOLD)
			p.box(14,14,6,5,Color("87a094"))
		"omikuji_good": _omikuji_good(p)
		# A bad fortune is not kept: it is folded and knotted to the shrine's
		# cord so the misfortune stays there. The knot is what tells them apart.
		"omikuji_bad": _omikuji_bad(p)
		"pastel":
			p.poly([[5,10],[26,10],[26,22],[23,26],[7,25],[4,21]],Color("a77342"))
			p.box(6,10,19,13,Color("dbac60"))
			p.box(8,12,15,9,Color("eec984"))
			for x in range(7,25,3): p.box(x,23,1,2,Color("edc77d"))
			p.box(11,15,2,2,Color("c5944b"))
		"portrait":
			_paper(p,PAPER,6,4,20,25)
			p.oval(11,11,10,9,Color("a6bba6"))
			p.line(12,12,11,8,INK)
			p.line(19,12,20,8,INK)
			p.box(13,14,2,2,INK)
			p.box(18,14,2,2,INK)
			p.poly([[12,19],[20,19],[23,25],[9,25]],Color("888179"))
			p.line(20,26,24,25,Color("856950"))
		"potatoes":
			for row: Array in [[4,14,13,12],[14,16,14,10],[10,6,12,13]]:
				p.oval(row[0],row[1],row[2],row[3],Color("9a784f"))
				p.oval(row[0]+1,row[1],row[2]-3,row[3]-3,Color("c2a373"))
				p.dot(row[0]+4,row[1]+3,Color("776347"))
				p.dot(row[0]+7,row[1]+7,Color("776347"))
		"quinto_quarto":
			p.oval(3,16,26,12,Color("849b9d"))
			p.oval(4,15,24,10,PAPER)
			for row: Array in [[7,12],[14,9],[18,15]]:
				p.oval(row[0],row[1],9,9,Color("925c46"))
				p.oval(row[0]+1,row[1],6,6,Color("bb8257"))
			p.line(10,14,21,18,GREEN)
		"shave_ice":
			p.poly([[8,17],[25,17],[20,28],[13,28]],Color("799fad"))
			p.poly([[9,18],[21,18],[18,27],[14,27]],Color("aed0c9"))
			p.oval(7,5,20,16,Color("d7e9de"))
			p.oval(8,7,7,11,Color("cd8196"))
			p.oval(15,6,7,12,Color("dcba68"))
			p.line(22,10,26,3,Color("aacaad"))
		"simit":
			p.oval(4,6,24,22,Color("925c3c"))
			p.oval(4,6,23,19,Color("c59351"))
			p.oval(11,12,10,9,Color.TRANSPARENT)
			for v: Vector2i in [Vector2i(8,10),Vector2i(14,8),Vector2i(20,9),Vector2i(24,14),Vector2i(7,17),Vector2i(10,23),Vector2i(19,23),Vector2i(24,21)]:
				p.box(v.x,v.y,2,1,Color("efd7a0"))
		"soviet_badge":
			p.poly([[16,4],[20,11],[28,12],[22,18],[23,27],[16,23],[8,27],[10,18],[4,12],[12,11]],GOLD)
			p.poly([[16,8],[19,14],[25,14],[20,18],[21,23],[16,20],[11,23],[12,17],[8,14],[14,14]],RED)
			p.box(14,14,4,5,Color("e4bf6c"))
		"spice_cone":
			p.poly([[6,10],[26,10],[18,29]],PAPER)
			p.poly([[7,12],[17,28],[16,13]],Color("b9a081"))
			p.oval(6,7,20,9,Color("b8793f"))
			p.poly([[8,10],[15,4],[24,10]],Color("d09b4f"))
			p.box(13,7,3,1,Color("e8b96b"))
		"spray_can":
			p.box(10,10,12,17,Color("567e88"))
			p.box(11,10,3,15,Color("91b3b0"))
			p.oval(10,7,12,6,Color("bfc7be"))
			p.box(14,4,5,5,Color("596975"))
			p.dot(18,5,INK)
			p.box(14,15,7,6,RED)
			p.box(15,16,5,2,PAPER)
		"sulguni":
			for y in range(5,24,4):
				p.oval(9+(y%3),y,12,7,Color("c6b98d"))
				p.line(11,y+1,20,y+4,PAPER)
				p.line(20,y+1,12,y+5,Color("e2d7b5"))
			p.box(13,26,7,2,PAPER)
		"tostada":
			p.oval(3,9,26,18,Color("a97943"))
			p.oval(4,9,24,15,Color("dfb868"))
			p.oval(7,10,18,12,Color("77653e"))
			for x in range(8,23,4):
				p.box(x,12+x%3,3,4,GREEN)
				p.box(x,16+x%2,3,2,RED)
			p.line(8,12,23,19,PAPER)
			p.line(10,19,22,13,PAPER)
		"tower_charm":
			p.oval(11,3,10,8,Color("bec6bb"))
			p.oval(13,4,6,5,Color.TRANSPARENT)
			p.line(16,10,16,14,GOLD)
			p.poly([[15,12],[18,12],[19,21],[25,28],[20,28],[16,24],[12,28],[7,28],[13,21]],Color("a58d65"))
			p.line(16,14,10,26,PAPER)
			p.box(12,20,9,2,Color("d1b17b"))
		"wax_votive":
			p.oval(7,22,19,6,Color("9b754c"))
			p.box(11,13,11,12,Color("c9b784"))
			p.box(12,13,7,11,PAPER)
			p.oval(11,11,11,4,Color("f3e4be"))
			p.box(15,11,2,4,INK)
			p.poly([[16,3],[19,8],[17,12],[14,9]],GOLD)
			p.box(16,7,1,4,PAPER)
		"yoff_fish":
			p.poly([[5,13],[3,7],[10,11],[22,10],[29,16],[22,23],[10,21],[3,26],[5,18]],Color("71959d"))
			p.oval(8,11,20,10,Color("adbfb9"))
			p.poly([[11,11],[16,6],[19,11]],Color("527987"))
			p.line(10,18,22,19,PAPER)
			p.box(24,14,2,2,INK)
			p.line(22,13,21,18,Color("527987"))
			for x in [11,15,18]: p.line(x,13,x+1,15,Color("769da0"))
		"tray":
			p.oval(3,14,26,10,Color("7a9095"))
			p.oval(4,13,24,8,Color("c5cec5"))
			p.oval(6,15,20,4,Color("8aa3a5"))
		"broom":
			p.line(17,3,15,20,Color("a67f53"))
			p.line(18,3,16,20,Color("d5b47b"))
			p.poly([[12,18],[20,18],[23,28],[8,28]],Color("b69560"))
			for x in [11,14,17,20]: p.line(15+(x-14)/2,21,x,27,PAPER)
			p.box(12,19,8,2,RED)
		"papers":
			_paper(p,Color("a5aea2"),5,7,22,21)
			_paper(p,PAPER,7,4,18,22)
			p.box(10,8,12,2,Color("737a76"))
			for y in [13,16,19,22]: p.box(10,y,9+(y%2)*3,1,Color("a9aa93"))
		"phone":
			_paper(p,Color("48505d"),9,3,14,26)
			p.box(11,6,10,17,Color("648e9d"))
			p.box(12,7,3,12,Color("8ab2b1"))
			p.box(15,25,3,1,PAPER)
		"record":
			p.oval(3,3,26,26,Color("3d414b"))
			p.oval(6,6,20,20,Color("555661"))
			p.oval(8,8,16,16,Color("353841"))
			p.oval(12,12,8,8,RED)
			p.box(15,15,2,2,PAPER)
			p.line(7,9,12,6,Color("858383"))
		"basket":
			p.oval(7,3,18,22,Color("b18a57"))
			p.oval(10,6,12,15,Color.TRANSPARENT)
			p.poly([[5,15],[27,15],[24,28],[8,28]],Color("a07a51"))
			for y in range(16,27,3):
				p.box(7,y,18,1,Color("d2b17b"))
				for x in range(8,24,4): p.box(x+(y%2),y+1,1,2,Color("765b43"))
		_:
			_paper(p,Color("b6ada0"),8,8,16,18)
			p.box(11,11,9,2,INK)
			p.box(17,13,3,4,INK)
			p.box(14,16,4,2,INK)
			p.box(14,21,2,2,INK)
