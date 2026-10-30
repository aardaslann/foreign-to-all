extends Camera2D

# The screen is always full of the game.
#
# Every plate in this project is authored at 1152 x 648 - exactly 16:9, and
# exactly 1920 divided by 1.667 - and WorldBorder confines the player to that
# same rectangle. The camera, though, sat at zoom 1.0, so on a 1920x1080
# screen it showed 1920x1080 WORLD units: the plate in the middle and a very
# large amount of nothing around it, which is the empty border the game has
# been cutting off into.
#
# So the camera is fitted to the plate instead of the plate being asked to
# cover the camera. Zoom is COVER, not contain: the plate fills both axes and
# whatever does not fit is cropped, so a window that is not 16:9 still shows
# no void. Limits pin the view to the plate's edges, so it can never travel
# past the art in either direction.
#
# The alternative was drawing four thousand pixels of invented city around
# every one of thirty-three plates, which is a great deal of work to produce
# scenery no player is meant to be able to reach.

const PLATE := Vector2(1152.0, 648.0)


func _ready() -> void:
	position_smoothing_enabled = false
	ignore_rotation = true
	_fit()
	get_viewport().size_changed.connect(_fit)


func _fit() -> void:
	var vp: Vector2 = get_viewport_rect().size
	if vp.x < 1.0 or vp.y < 1.0:
		return
	# Cover: whichever axis is tighter decides, so neither ever falls short.
	var z: float = maxf(vp.x / PLATE.x, vp.y / PLATE.y)
	zoom = Vector2(z, z)
	limit_left = 0
	limit_top = 0
	limit_right = int(PLATE.x)
	limit_bottom = int(PLATE.y)
	limit_smoothed = false
