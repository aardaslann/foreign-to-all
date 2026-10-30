extends SceneTree

# Recover the existing cats from the original background scripts, retaining
# each coat and pose while moving their feet onto the new playable pavement.
func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var inventory: Array = JSON.parse_string(FileAccess.get_file_as_string(args[0]))
	var rows: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/environments/layouts.json"))
	var count: int = 0
	for entry: Dictionary in inventory:
		var id: String = entry["id"]
		if not rows.has(id): continue
		var row: Dictionary = rows[id]
		row["cats"] = []
		for bg: Dictionary in entry.get("background", []):
			if not bg.get("resource") is String: continue
			var source_path: String = bg["resource"]
			var script: Script = load(source_path)
			var old: Node = script.new()
			if row.has("district") and old.get("district") != null:
				old.set("district", row["district"])
			if old.has_method("cats"):
				for c: Array in old.call("cats"):
					var original: Vector2 = c[0]
					var point := Vector2(clampf(original.x,36,1116),clampf(float(row["floor"])+36+fposmod(original.y,40),float(row["floor"])+22,608))
					for box: Array in row.get("solids",[]):
						var r := Rect2(box[0],box[1],box[2],box[3]).grow(22)
						if r.has_point(point): point.x = clampf(r.end.x+12,36,1116)
					row["cats"].append([point.x,point.y,int(c[1]),int(c[2])])
					count += 1
			old.free()
	var file := FileAccess.open("res://art/environments/layouts.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(rows,"  "))
	print("Restored ",count," interactive cats")
	quit()
