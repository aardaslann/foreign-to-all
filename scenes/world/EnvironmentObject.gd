extends Node2D

# World-space silhouettes and ground footprints are separate. A seat back
# hides a body; the empty space above/below it must never copy the background.
var background: Node2D
var spec: Dictionary
const FOLIAGE := preload("res://scenes/world/FoliageSilhouette.gdshader")

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	position.y = float(spec["sort_y"]) - 22.0
	material = background.material
	if spec.has("foliage"):
		var leaves := Node2D.new()
		leaves.name = "Foliage"
		leaves.position = -position
		var cutout := ShaderMaterial.new()
		cutout.shader = FOLIAGE
		cutout.set_shader_parameter("painted_metal", bool(spec.get("painted_metal", false)))
		cutout.set_shader_parameter("blue_handles", bool(spec.get("blue_handles", false)))
		cutout.set_shader_parameter("wood_branches", bool(spec.get("wood_branches", false)))
		cutout.set_shader_parameter("pink_blossoms", bool(spec.get("pink_blossoms", false)))
		leaves.material = cutout
		add_child(leaves)
		leaves.draw.connect(func(): background.draw_foliage(leaves,spec))
		leaves.queue_redraw()
	queue_redraw()

func _process(_delta: float) -> void:
	if spec.has("water") or spec.has("glass") or spec.has("animation_patches"):
		queue_redraw()

func _draw() -> void:
	if not is_instance_valid(background): return
	background.draw_object(self, spec)
	# The background queues this object when the time-of-day tint changes.
	var leaves := get_node_or_null("Foliage")
	if leaves != null: leaves.queue_redraw()
