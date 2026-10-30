extends SceneTree

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 1:
		push_error("Supply the package output directory.")
		quit(1)
		return
	var credits := preload("res://scenes/title/ReleaseCredits.gd")
	for pair: Array in [["CREDITS.txt", credits.TEXT], ["THIRD-PARTY-NOTICES.txt", credits.notices()]]:
		var file := FileAccess.open(args[0].path_join(pair[0]), FileAccess.WRITE)
		if file == null:
			quit(1)
			return
		file.store_string(pair[1])
		file.close()
	quit()
