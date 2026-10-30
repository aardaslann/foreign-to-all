extends SceneTree

func _initialize() -> void:
	var output := {}
	var ss = load("res://scenes/world/Streetside.gd")
	for table in [ss.EAST.SPOTS,ss.PACIFIC.SPOTS,ss.SOUTH.SPOTS,ss.NORTH.SPOTS,ss.AMERICA.SPOTS,ss.WEST.SPOTS,ss.NORTHWEST.SPOTS,ss.EASTTWO.SPOTS,ss.SOUTHTWO.SPOTS,ss.EUROPETWO.SPOTS]:
		for key: String in table:
			var parts := key.split(":")
			if parts[0] in ["berlin","istanbul","london","paris","moscow","mumbai","tokyo","mexico"]:
				output[key] = ss.spot(parts[0],parts[1])
	var file := FileAccess.open("C:/Users/Arda/Documents/ForeignToAll/work/beta/activity-inventory.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(output,"\t"))
	quit()
