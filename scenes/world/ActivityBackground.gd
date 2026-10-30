extends EnvironmentDesign

const PLACES := preload("res://scenes/world/ActivityPlaces.gd")

func _scene_design() -> Dictionary:
	var result: Dictionary = super._scene_design().duplicate(true)
	result.merge(PLACES.location(scene_id).get("geometry", {}), true)
	# Depth silhouettes redraw part of the original plate. Keep animated birds
	# and fountain water on that same layer, otherwise the static copy erases
	# the animation as soon as this becomes a world scene.
	for object: Dictionary in result.get("objects", []):
		for patch: Dictionary in result.get("animation_patches", []):
			var a: Array = patch.get("rect", [])
			if a.size() != 4: continue
			var area := Rect2(a[0],a[1],a[2],a[3])
			for points: Array in object.get("polygons", []):
				var bounds := Rect2(Vector2(points[0][0],points[0][1]),Vector2.ZERO)
				for p: Array in points: bounds = bounds.expand(Vector2(p[0],p[1]))
				if bounds.intersects(area):
					if not object.has("animation_patches"): object["animation_patches"] = []
					if not object["animation_patches"].has(patch): object["animation_patches"].append(patch)
	return result
