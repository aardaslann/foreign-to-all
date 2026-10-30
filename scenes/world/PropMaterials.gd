extends RefCounted

# Details stay inside the original surface, so authored silhouettes, depth
# anchors, moving parts and ground polygons remain authoritative.
static func surface(ci: CanvasItem, r: Rect2, color: Color) -> void:
	ci.draw_rect(r, color)
	if r.size.x < 4 or r.size.y < 3 or color.a < 0.95 or color.v < 0.19:
		return
	var pixel := minf(1.0, r.size.y / 4.0)
	ci.draw_rect(Rect2(r.position, Vector2(r.size.x, pixel)), color.lightened(.14))
	ci.draw_rect(Rect2(r.position + Vector2(0,r.size.y-pixel), Vector2(r.size.x,pixel)), color.darkened(.24))
	ci.draw_rect(Rect2(r.position + Vector2(r.size.x-pixel,pixel), Vector2(pixel,r.size.y-pixel*2)), color.darkened(.12))
	# Warm wood gets short grain; cool metal gets a narrow reflected edge;
	# dyed cloth and paper keep quiet seams instead of random noise.
	var wood: bool = color.r > color.g * 1.13 and color.g > color.b * 1.14
	if wood and r.size.x >= 9 and r.size.y >= 5:
		for y in range(2, int(r.size.y)-1, 4):
			for x in range(2+(y%3), int(r.size.x)-3, 11):
				ci.draw_rect(Rect2(r.position+Vector2(x,y),Vector2(minf(5,r.size.x-x-1),pixel)),color.darkened(.1))
	elif color.s < 0.28 and r.size.y >= 7:
		ci.draw_rect(Rect2(r.position+Vector2(1,2),Vector2(pixel,r.size.y-4)),color.lightened(.16))
	elif r.size.x >= 12 and r.size.y >= 8:
		ci.draw_rect(Rect2(r.position+Vector2(2,2),Vector2(r.size.x-4,pixel)),color.lightened(.08))
