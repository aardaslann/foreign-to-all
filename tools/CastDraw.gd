extends Node2D

# The named cast, drawn big, on a neutral ground.
#
# Every serious fault in this project's art was invisible to reasoning and
# obvious in a render. A palette that reads beautifully as twelve hex triples
# can still come out as a brown smudge with two dots in it, and the only way
# to find that out is to look.
#
# One person per cell; along the cell is time, so somebody with an idle loop
# is shown at several points around their own cycle and somebody without one
# is shown identically several times - which is itself the thing worth seeing.
#
# The cell decides the unit rather than the other way round. The first version
# of this file fixed the unit at five and let the cells fall where they might,
# and produced eight people standing on top of each other in a strip along the
# bottom edge: exactly the class of fault this tool exists to catch.

const CH := preload("res://scenes/npc/CharacterArt.gd")
const CAST := preload("res://scenes/npc/Cast.gd")
const ROSTER := preload("res://scenes/npc/CastRoster.gd")

# "eight" | "roster" | a city id
var which: String = "eight"
var page: int = 0

const PER_PAGE := 16
const BG := Color8(36, 32, 48)
const CELL := Color8(45, 40, 60)
const INK := Color8(228, 222, 244)
const DIM := Color8(146, 138, 184)
const GOLD := Color8(226, 180, 92)

# A figure is 16 wide and 26 tall on the grid, plus a unit of air each side.
const FIG_W := 18.0
const FIG_H := 28.0


func _draw() -> void:
	var vp: Vector2 = Vector2(get_viewport_rect().size)
	draw_rect(Rect2(Vector2.ZERO, vp), BG)
	var font: Font = ThemeDB.fallback_font
	var all: Array = _people()
	var pages: int = maxi(1, int(ceil(float(all.size()) / float(PER_PAGE))))
	var from: int = page * PER_PAGE
	var people: Array = all.slice(from, mini(from + PER_PAGE, all.size()))
	if people.is_empty():
		draw_string(font, Vector2(40.0, 60.0),
			"nobody for '" + which + "' page " + str(page),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 28, INK)
		return

	draw_string(font, Vector2(36.0, 46.0),
		"Foreign to All  -  cast sheet  -  " + which + "  -  page "
		+ str(page + 1) + " of " + str(pages) + "  -  " + str(all.size())
		+ " designed", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, DIM)

	# Square-ish grid, then a unit that guarantees everybody fits their cell.
	var cols: int = maxi(1, int(ceil(sqrt(float(people.size())))))
	var rows: int = int(ceil(float(people.size()) / float(cols)))
	var top: float = 70.0
	var cw: float = vp.x / float(cols)
	var rh: float = (vp.y - top) / float(rows)
	var steps: int = 4 if people.size() > 4 else 6
	var unit: float = minf((cw - 24.0) / (FIG_W * float(steps)),
		(rh - 64.0) / FIG_H)

	for i in range(people.size()):
		var p: Dictionary = people[i]
		var col: int = i % cols
		var row: int = i / cols
		var x0: float = float(col) * cw
		var y0: float = top + float(row) * rh
		draw_rect(Rect2(x0 + 6.0, y0 + 4.0, cw - 12.0, rh - 10.0), CELL)
		draw_string(font, Vector2(x0 + 18.0, y0 + 26.0), String(p["label"]),
			HORIZONTAL_ALIGNMENT_LEFT, cw - 36.0, 19, INK)
		var feet: float = y0 + rh - 30.0
		var span: float = FIG_W * unit
		var left: float = x0 + (cw - span * float(steps)) * 0.5
		for s in range(steps):
			CH.draw_figure(self, Vector2(left + span * (float(s) + 0.5), feet),
				unit, Dictionary(p["who"]), "stand", float(s) * 1.15,
				int(p["seed"]))
		draw_string(font, Vector2(x0 + 18.0, y0 + rh - 14.0), String(p["note"]),
			HORIZONTAL_ALIGNMENT_LEFT, cw - 36.0, 13, GOLD)


func _people() -> Array:
	var out: Array = []
	if which == "eight":
		for city: String in CAST.DESIGNS.keys():
			var d: Dictionary = CAST.DESIGNS[city]
			out.append({
				"label": _key_name(city),
				"note": _kit(d), "who": CAST.look(city),
				"seed": absi(city.hash()),
			})
		return out
	for id: String in ROSTER.PEOPLE.keys():
		var e: Dictionary = ROSTER.PEOPLE[id]
		if which != "roster" and String(e.get("city", "")) != which:
			continue
		out.append({
			"label": id + "  -  " + String(e.get("city", "?")),
			"note": _kit(e), "who": ROSTER.look(id),
			"seed": absi(id.hash()),
		})
	return out


# What they are wearing, said out loud under the drawing, so a design that
# reads wrong can be traced to the line that produced it without guessing.
func _kit(d: Dictionary) -> String:
	var bits: PackedStringArray = [
		String(d.get("build", "adult")), String(d.get("cut", "crop")),
		String(d.get("wear", "coat")),
	]
	for k: String in ["drape", "mark", "face", "shoes", "idle", "prop"]:
		var v: String = String(d.get(k, ""))
		if not v.is_empty():
			bits.append(v)
	return " / ".join(bits)


# Read off Story rather than kept here.
#
# This was a hardcoded table of eight names and ages - a second copy of what
# Story.PEOPLE already says - so the first character added after it was written
# appeared on the sheet as "zurich". A tool that keeps its own list of the cast
# will eventually disagree with the game about who is in it, and the
# disagreeing version is the one somebody is looking at when they decide the
# art is finished.
func _key_name(city: String) -> String:
	var p: Dictionary = Story.person(city)
	if p.is_empty():
		return city
	var where: String = String(GameState.CITIES.get(city, {}).get("name", city))
	return "%s, %d, %s" % [String(p.get("name", city)),
		int(p.get("age", 0)), where]
