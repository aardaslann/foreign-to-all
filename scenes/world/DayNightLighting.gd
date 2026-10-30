extends CanvasModulate

var indoors := false
var background: Node2D
var _last_minute := -1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_process(0.0)


func _process(_delta: float) -> void:
	# One canvas tint keeps plates, moving people and depth silhouettes in the
	# same light. HUD CanvasLayers retain their normal contrast.
	color = GameState.CLOCK.tint(GameState.clock_minutes, GameState.city, indoors)
	var minute := floori(GameState.clock_minutes)
	if minute != _last_minute and is_instance_valid(background):
		# Beds advance the clock under a paused tree. Windows must already show
		# the new light while the wake-up fade is lifting.
		background.queue_redraw()
	_last_minute = minute
