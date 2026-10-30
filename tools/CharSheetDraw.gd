extends Node2D

# Draws the sheet. Separate from the SceneTree script so it can preload
# CutsceneArt, which the --script file cannot.

const CA := preload("res://scenes/ui/CutsceneArt.gd")

const POSES := ["stand", "watch", "walk", "point", "offer", "hand_over",
	"take", "carry", "sit", "queue", "bow", "recoil", "reach", "haul",
	"drink", "wave"]


@export var strip: bool = false


func _draw() -> void:
	if strip:
		draw_strip()
		return
	var morning: bool = GameState.is_morning()
	var bg: Color = Color8(214, 210, 202) if morning else Color8(38, 40, 50)
	draw_rect(Rect2(0, 0, 1920, 1080), bg)
	# A ground line to stand them on.
	for r in range(2):
		var y: float = 330.0 + float(r) * 470.0
		draw_rect(Rect2(0, y, 1920, 3), Color(0, 0, 0, 0.16))

	var p: Array = CA.pal("berlin")
	var font: Font = ThemeDB.fallback_font
	# Top row: the alien, one pose per column.
	for i in range(8):
		var x: float = 130.0 + float(i) * 232.0
		CA.person(self, x, 330.0, 3.2, POSES[i], p, 1.4, true, 0, "berlin")
		draw_string(font, Vector2(x - 50.0, 366.0), POSES[i],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 20,
			Color(0.2, 0.2, 0.2) if morning else Color(0.8, 0.8, 0.8))
	# Bottom row: locals, one build and pose per column.
	for j in range(8):
		var x2: float = 130.0 + float(j) * 232.0
		CA.person(self, x2, 800.0, 3.2, POSES[j + 8], p, 1.4, false, j * 3,
			"berlin")
		draw_string(font, Vector2(x2 - 50.0, 836.0), POSES[j + 8],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 20,
			Color(0.2, 0.2, 0.2) if morning else Color(0.8, 0.8, 0.8))


# The same two figures across a second and a half, so the walk cycle, the
# breathing, the blink and the antenna drift can be seen rather than assumed.
func draw_strip() -> void:
	var morning: bool = GameState.is_morning()
	draw_rect(Rect2(0, 0, 1920, 1080), Color8(214, 210, 202) if morning
		else Color8(38, 40, 50))
	var p: Array = CA.pal("berlin")
	for i in range(10):
		var tt: float = float(i) * 0.17
		var x: float = 120.0 + float(i) * 186.0
		CA.person(self, x, 330.0, 3.0, "walk", p, tt, true, 0, "berlin")
		CA.person(self, x, 780.0, 3.0, "walk", p, tt, false, 3, "berlin")
