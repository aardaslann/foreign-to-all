extends StaticBody2D

# Invisible collision walls that keep the player inside the playable area.
# Defaults match the outdoor scenes (top wall at the horizon); interiors
# override these to sit inside their visible room walls.
@export var wall_top:    float = 305.0
@export var wall_bottom: float = 648.0
@export var wall_left:   float = 0.0
@export var wall_right:  float = 1152.0

const T := 200.0    # wall thickness


func _ready() -> void:
	var w := wall_right - wall_left
	var h := wall_bottom - wall_top
	var cx := (wall_left + wall_right) * 0.5
	var cy := (wall_top + wall_bottom) * 0.5
	_wall(cx, wall_top - T / 2,    w + T * 2, T)
	_wall(cx, wall_bottom + T / 2, w + T * 2, T)
	_wall(wall_left - T / 2,  cy,  T, h + T * 2)
	_wall(wall_right + T / 2, cy,  T, h + T * 2)


func _wall(cx: float, cy: float, w: float, h: float) -> void:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(w, h)
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2(cx, cy)
	add_child(col)
