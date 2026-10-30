extends SceneTree

var CH
var CAST
var ROSTER
var WARD
var done = false

func _process(_delta: float) -> bool:
	if done: return false
	done = true
	CH = load("res://scenes/npc/CharacterArt.gd")
	CAST = load("res://scenes/npc/Cast.gd")
	ROSTER = load("res://scenes/npc/CastRoster.gd")
	WARD = load("res://scenes/npc/Wardrobe.gd")
	var all: Dictionary = {}
	all["alien"] = CH.alien_look()
	for city: String in CAST.DESIGNS.keys():
		all[city] = CAST.look(city)
	if ROSTER.PEOPLE.has("lukas"):
		all["lukas"] = ROSTER.look("lukas")
	for i in range(5):
		all["crowd" + str(i)] = CH.look(30 + i * 19, "berlin")
	var output: Dictionary = {}
	for id: String in all.keys():
		var who: Dictionary = all[id]
		var rows: Array = (CH.ALIEN if bool(who.get("alien", false)) else CH.HUMAN).duplicate()
		if id != "alien":
			WARD.dress(rows, who, CH.CUTS, CH.FACE_ROWS)
		var colours: Dictionary = {}
		for letter: String in who["pal"].keys():
			colours[letter] = "#" + Color(who["pal"][letter]).to_html(false)
		var acts: Dictionary = {}
		for act: String in ["stand", "talk", "watch", "look", "read", "point", "pour", "eat", "drink", "sit", "walk", "take", "offer", "bow", "recoil", "wave", "carry", "interact"]:
			var a: Array = rows.duplicate()
			var gaze: int = int(CH.GAZE.get(act, 0))
			if gaze != 0:
				for r in range(CH.ROW_EYES, CH.ROW_EYES + 2):
					a[r] = CH._shift_eyes(String(a[r]), gaze)
			acts[act] = a
		output[id] = {"rows":rows,"acts":acts,"pal":colours,"build":who.get("build","adult"),"idle":who.get("idle",""),"prop":who.get("prop",""),"prop_side":who.get("prop_side",1)}
	var props: Dictionary = {}
	for id: String in CH.PROPS.keys():
		var p: Array = CH.PROPS[id]
		props[id] = [p[0],p[1],p[2],"#"+Color(p[3]).to_html(false),"#"+Color(p[4]).to_html(false)]
	var file = FileAccess.open("res://trailer/public/connection/cast.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"people":output,"dip":CH.DIP,"lean":CH.LEAN,"idle":CH.IDLE,"build":CH.BUILD_H,"props":props}, "  "))
	file.close()
	print("Exported authentic character grids: ", output.keys())
	quit()
	return true
