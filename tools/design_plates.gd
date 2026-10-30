extends SceneTree

# Render the exact approved in-game framing as a reference for production art.
# A single scene reference prevents neighbouring contact-sheet panels leaking
# into a replacement background. Gameplay objects are intentionally absent.
var _vp: SubViewport
var _canvas: Node2D
var _jobs: Array
var _rows: Dictionary
var _out: String
var _current: String
var _wait: int
var _texture: Texture2D
var _source: Rect2

func _initialize() -> void:
	_out = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(_out)
	_rows = JSON.parse_string(FileAccess.get_file_as_string("res://art/environments/layouts.json"))
	_jobs = _rows.keys()
	_vp = SubViewport.new()
	_vp.size = Vector2i(1152,648)
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_vp)
	_canvas = Node2D.new()
	_canvas.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_vp.add_child(_canvas)
	_canvas.draw.connect(_draw_plate)
	_next.call_deferred()

func _next() -> void:
	if _jobs.is_empty():
		print("All approved scene references rendered")
		quit()
		return
	_current = _jobs.pop_front()
	var row: Dictionary = _rows[_current]
	_texture = load(row["texture"])
	var s: Array = row["source"]
	_source = Rect2(s[0],s[1],s[2],s[3])
	_canvas.queue_redraw()
	_wait = 3

func _draw_plate() -> void:
	if _texture != null:
		_canvas.draw_texture_rect_region(_texture,Rect2(0,0,1152,648),_source)

func _process(_delta: float) -> bool:
	if _wait <= 0: return false
	_wait -= 1
	if _wait == 0:
		_vp.get_texture().get_image().save_png(_out.path_join(_current+".png"))
		_next.call_deferred()
	return false
