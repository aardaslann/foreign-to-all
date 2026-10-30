extends RefCounted

const OBJECTS := preload("res://scenes/ui/ActivityObjects.gd")
const INK := Color8(43, 48, 51)
const WOOD := Color8(108, 80, 59)
const PAPER := Color8(226, 222, 204)
const WALLS := {
	"berlin": Color8(185,198,181), "london": Color8(188,182,163),
	"istanbul": Color8(200,194,161), "paris": Color8(201,195,181),
	"moscow": Color8(187,194,189), "mumbai": Color8(179,198,184),
	"tokyo": Color8(202,196,172), "hanoi": Color8(199,185,139),
	"seoul": Color8(189,200,198), "mexico": Color8(207,172,142),
	"dakar": Color8(210,192,156), "tbilisi": Color8(181,193,179),
	"lapaz": Color8(194,179,161), "honolulu": Color8(200,203,171),
}

# A compact pixel grid keeps joinery, stock, switches and lamps at the same
# level of detail as the new streets. The window contains the actual city.
static func room(ci: CanvasItem, w: float, h: float, city: String,
		object: String, street: Texture2D, t: float, morning: bool) -> void:
	var wall: Color = WALLS.get(city, Color8(193,196,183))
	var shade: Color = Color.WHITE if morning else Color8(166,171,194)
	var unit: float = maxf(2,roundf(h/150.0))
	ci.draw_set_transform(Vector2.ZERO,0,Vector2(unit,unit))
	var width: float = w/unit
	var height: float = h/unit
	var floor_y: float = height*0.72
	ci.draw_rect(Rect2(0,0,width,height),wall*shade)
	ci.draw_rect(Rect2(0,0,width,5),WOOD*shade)
	ci.draw_rect(Rect2(0,5,width,2),wall.darkened(0.15)*shade)
	ci.draw_rect(Rect2(0,floor_y,width,height-floor_y),Color8(129,130,117)*shade)
	for y in range(int(floor_y)+8,int(height),9):
		ci.draw_rect(Rect2(0,y,width,1),Color(0.2,0.24,0.22,0.19))
		for x in range(-15,int(width),24):
			ci.draw_rect(Rect2(x+(12 if (y/9)%2 else 0),y,1,9),Color(0.2,0.24,0.22,0.14))
	ci.draw_rect(Rect2(0,floor_y-4,width,4),WOOD*shade)
	# Cabinet on the left, with dark recesses behind the stock.
	var shelf_w: float = width*0.46
	ci.draw_rect(Rect2(9,19,shelf_w,floor_y-22),WOOD.darkened(0.28)*shade)
	for level in range(3):
		var y: float = 36+float(level)*20
		ci.draw_rect(Rect2(12,y,shelf_w-6,3),WOOD.lightened(0.12)*shade)
		ci.draw_rect(Rect2(12,y+3,shelf_w-6,1),INK*shade)
		for i in range(int(shelf_w/12)-1):
			var x: float = 16+i*12
			var color: Color = [Color8(112,136,113),Color8(158,106,86),Color8(189,164,106),Color8(105,122,135)][(i+level)%4]*shade
			if object in ["bread", "griddle", "trays", "cheese", "fruit"]:
				ci.draw_rect(Rect2(x,y-5,9,4),Color8(203,164,101)*shade)
				ci.draw_rect(Rect2(x+2,y-6,5,1),PAPER*shade)
			elif object in ["lathe", "sewing", "workbench", "salvage"]:
				ci.draw_rect(Rect2(x+3,y-14,2,12),Color8(141,152,153)*shade)
				ci.draw_rect(Rect2(x,y-14,8,3),color)
			elif object in ["clothes", "fabric", "scarves"]:
				ci.draw_rect(Rect2(x,y-12,9,11),color)
				ci.draw_rect(Rect2(x+4,y-13,1,13),color.lightened(0.22))
			else:
				ci.draw_rect(Rect2(x,y-11-(i%3),8,11+(i%3)),color)
				ci.draw_rect(Rect2(x+1,y-8,6,3),PAPER*shade)
				ci.draw_rect(Rect2(x+2,y-13-(i%3),4,2),INK*shade)
	# Full-height window, deep sill, glazed upper pane and opening latch.
	var win := Rect2(width*0.68,17,width*0.24,floor_y-26)
	ci.draw_rect(win.grow(4),WOOD*shade)
	if street != null:
		var detail_scale := Vector2(street.get_size()) / Vector2(1152,648)
		ci.draw_texture_rect_region(street,win,Rect2(Vector2(200,120)*detail_scale,Vector2(550,380)*detail_scale),shade)
		ci.draw_rect(win,Color(0.40,0.58,0.57,0.16))
	for x in [win.position.x-1,win.get_center().x,win.end.x-2]:
		ci.draw_rect(Rect2(x,win.position.y,2,win.size.y),PAPER.darkened(0.12)*shade)
	ci.draw_rect(Rect2(win.position.x,win.position.y+win.size.y*0.43,win.size.x,2),PAPER*shade)
	ci.draw_rect(Rect2(win.position.x-5,win.end.y+2,win.size.x+10,4),WOOD.lightened(0.22)*shade)
	# Receipt board and switch are practical objects, not ornamental symbols.
	ci.draw_rect(Rect2(width*0.54,35,25,33),WOOD*shade)
	ci.draw_rect(Rect2(width*0.54+2,37,21,29),INK*shade)
	for i in range(5):
		ci.draw_rect(Rect2(width*0.54+5,41+i*4,12-(i%2)*4,1),PAPER*shade)
	ci.draw_rect(Rect2(width*0.60,floor_y-13,5,7),PAPER*shade)
	ci.draw_rect(Rect2(width*0.60+2,floor_y-11,1,3),INK*shade)
	for x in [width*0.23,width*0.58]:
		ci.draw_rect(Rect2(x,6,1,9),INK*shade)
		ci.draw_rect(Rect2(x-6,15,13,3),INK*shade)
		ci.draw_rect(Rect2(x-4,18,9,2),Color8(245,216,147))
	# Plant at the sill; leaves move by a single pixel, stem stays attached.
	var px: float = win.end.x-8
	ci.draw_rect(Rect2(px-5,win.end.y-8,10,10),Color8(147,97,69)*shade)
	ci.draw_rect(Rect2(px-1,win.end.y-21,2,14),Color8(58,92,65)*shade)
	for i in range(4):
		var shift: float = roundf(sin(t*0.8+i)*0.65)
		ci.draw_rect(Rect2(px-8+shift+(i%2)*8,win.end.y-23+i*3,8,4),Color8(84,120,75)*shade)
	ci.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)

static func gate(ci: CanvasItem, w: float, h: float, city: String, region: String) -> void:
	# Gateways are openings with real jambs and lintels, not an opaque arch
	# painted over half the street. Keep the architecture visible through them.
	var brick: Color = Color8(163,103,82) if city in ["hanoi","tokyo"] else Color8(166,163,142)
	var iron: Color = Color8(55,77,71)
	var top: float = h*0.12
	var bottom: float = h*0.76
	for x in [w*0.36,w*0.67]:
		ci.draw_rect(Rect2(x,top,w*0.035,bottom-top),brick)
		ci.draw_rect(Rect2(x-w*0.008,top-6,w*0.051,9),brick.lightened(0.15))
		ci.draw_rect(Rect2(x-w*0.008,bottom-9,w*0.051,9),brick.darkened(0.15))
	ci.draw_rect(Rect2(w*0.35,top+9,w*0.37,10),iron)
	if city == "tokyo" and region == "asakusa":
		ci.draw_colored_polygon(PackedVector2Array([Vector2(w*.30,top+5),Vector2(w*.39,top-32),Vector2(w*.67,top-32),Vector2(w*.76,top+5)]),Color8(62,69,65))
		var lantern := Rect2(w*.505,top+24,w*.065,h*.17)
		ci.draw_rect(lantern,Color8(168,62,48))
		for i in range(5):ci.draw_rect(Rect2(lantern.position+Vector2(0,i*lantern.size.y/5),Vector2(lantern.size.x,2)),Color8(128,45,41))
		ci.draw_string(ThemeDB.fallback_font,lantern.position+Vector2(8,lantern.size.y*.6),"雷門",HORIZONTAL_ALIGNMENT_LEFT,-1,16,PAPER)
	else:
		for i in range(9):
			var x: float = w*.40+i*w*.028
			ci.draw_rect(Rect2(x,top+19,3,(bottom-top)*.55),iron)
