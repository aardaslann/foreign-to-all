extends Node2D

# Hotel lobby — pixel plate (lobby_dawn) from design_handoff_world.
# Everything static is baked in; the living details are separate sprites:
# sconce + chandelier flicker, the elevator's wandering indicator, the desk
# lamp glow, and the front-door glass that swaps dawn → morning.

const VW  := 1152.0
const VH  := 648.0
const EXT := 4000.0
const C_VOID := Color(0.043, 0.039, 0.110)


func _ready() -> void:
	WorldArt.sprite(self, WorldArt.tex("scenes/lobby_dawn.png"), Vector2.ZERO, 1)
	# Morning shows through the glass; the room itself stays lamp-lit
	WorldArt.sprite(self, WorldArt.mode_tex("props/front_doors"), Vector2(33, 66), 2)
	WorldArt.strip_sprite(self, WorldArt.tex("props/sconce.png"), 2, 4.0, Vector2(135, 62), 2)
	WorldArt.strip_sprite(self, WorldArt.tex("props/sconce.png"), 2, 5.0, Vector2(288, 62), 2)
	WorldArt.strip_sprite(self, WorldArt.tex("props/chandelier.png"), 2, 2.0, Vector2(196, 0), 2)
	WorldArt.strip_sprite(self, WorldArt.tex("props/elevator.png"), 3, 1.0, Vector2(470, 74), 2)
	WorldArt.strip_sprite(self, WorldArt.tex("props/desk.png"), 2, 2.0, Vector2(316, 146), 3)


func _draw() -> void:
	draw_rect(Rect2(-EXT, -EXT, VW + EXT * 2, VH + EXT * 2), C_VOID)
