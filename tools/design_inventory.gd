extends SceneTree
const STREETS := preload("res://scenes/world/Streetside.gd")

func _initialize() -> void:
	var data: Dictionary = {}
	for key: String in STREETS.keys():
		var bits: PackedStringArray = key.split(":")
		data[key] = STREETS.spot(bits[0], bits[1])
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var file := FileAccess.open(args[0], FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "  "))
	file.close()
	print("ACTIVITY_INVENTORY ", data.size())
	quit()
