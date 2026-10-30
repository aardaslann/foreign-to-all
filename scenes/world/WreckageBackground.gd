extends Node2D

# Wreck site (Kiez) — pixel-art plate from design_handoff_world.
# The plate bakes sky, skyline, ground, burn scar, road, stalls and lamps;
# only the things that move live as separate sprites: the pod's fissure-glow
# pulse and the smoke drifting off it. Dawn/morning picks the matching plate.

const VW  := 1152.0
const VH  := 648.0
const EXT := 4000.0
const C_VOID := Color(0.043, 0.039, 0.110)

const SMOKE_SPAWN_1X := Vector2(88, 76)

var _smoke: Array = []   # [{ "s": Sprite2D, "vel": Vector2, "life": float, "max": float }]
var _spawn_t: float = 0.0


func _ready() -> void:
	_add_void()
	var m := WorldArt.mode()
	WorldArt.sprite(self, WorldArt.tex("scenes/wreck_%s.png" % m), Vector2.ZERO, -10)
	# Pod: 2 frames — fissure glow pulses, embers shift
	WorldArt.strip_sprite(self, WorldArt.tex("props/pod.png"), 2, 2.0, Vector2(36, 108), -9)


func _add_void() -> void:
	# Backing far behind everything, so the camera never sees past the plate
	var p := Polygon2D.new()
	p.polygon = PackedVector2Array([
		Vector2(-EXT, -EXT), Vector2(VW + EXT, -EXT),
		Vector2(VW + EXT, VH + EXT), Vector2(-EXT, VH + EXT),
	])
	p.color = C_VOID
	p.z_index = -20
	add_child(p)


func _process(delta: float) -> void:
	_spawn_t -= delta
	if _spawn_t <= 0.0 and _smoke.size() < 7:
		_spawn_t = 0.9
		_spawn_puff()

	for i in range(_smoke.size() - 1, -1, -1):
		var p: Dictionary = _smoke[i]
		p["life"] = float(p["life"]) + delta
		var s: Sprite2D = p["s"]
		s.position += (p["vel"] as Vector2) * delta
		var f: float = float(p["life"]) / float(p["max"])
		s.modulate.a = 0.55 * (1.0 - f)
		if f >= 1.0:
			s.queue_free()
			_smoke.remove_at(i)


func _spawn_puff() -> void:
	# smoke.png holds 3 puff sizes in 22px cells; pick by a rolling counter
	var tex := WorldArt.tex("props/smoke.png")
	var at := AtlasTexture.new()
	at.atlas = tex
	at.region = Rect2((_smoke.size() % 3) * 22, 0, 22, 22)
	var s := Sprite2D.new()
	s.texture = at
	s.centered = true
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.scale = Vector2(2, 2)
	s.z_index = -8
	s.position = SMOKE_SPAWN_1X * 2.0 + Vector2(randf_range(-8.0, 8.0), 0)
	s.modulate.a = 0.0
	add_child(s)
	_smoke.append({
		"s": s,
		"vel": Vector2(randf_range(-4.0, 10.0), randf_range(-26.0, -18.0)),
		"life": 0.0,
		"max": randf_range(3.2, 4.6),
	})


# ── Collision ────────────────────────────────────────────────────────────────
#
# Kiez's plate is a baked PNG rather than procedural drawing, so unlike every
# other street in the game there was nothing for Solids to read and NOTHING on
# it was solid: you could walk straight through Lukas's counter, through his
# crates and through the bench. It is also why Lukas floated - a person is put
# behind the counter they work at by finding that counter in solids(), and
# there was no counter to find.
#
# Measured off tools/collide.gd's render of the plate, which is the only place
# these numbers can come from when the art is a picture.
func solids() -> Array:
	return [
		Rect2(612.0, 332.0, 172.0, 32.0),   # Lukas's counter
		Rect2(797.0, 337.0, 66.0, 56.0),    # the crates, and the crate job
		Rect2(953.0, 307.0, 148.0, 48.0),   # the bench against the wall
	]
