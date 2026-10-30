extends Node

# Gives every interactable in the game its glow, once, from one place.
#
# The alternative was a line in each of a dozen _ready() bodies, which is
# twelve chances to forget one and no chance at all for something spawned at
# runtime - which the dropped shopping in Phase 2 is.
#
# The hook is the Prompt node. Every interactable in this project already has
# one, because every interactable has to tell you what E does; twelve scenes
# have one and no UI scene does. So a Prompt is exactly the signature of
# something you can walk up to and use.

const GLOW := preload("res://scenes/world/Glow.gd")
const DRESS := preload("res://scenes/world/HolidayDressing.gd")
const CROWD := preload("res://scenes/npc/Crowd.gd")
const STREET_CAT := preload("res://scenes/world/StreetCat.tscn")


# Connected in _enter_tree, not _ready, and followed by a sweep of whatever is
# already standing.
#
# A tool that runs as its own SceneTree builds its scene inside _initialize(),
# which happens before this autoload's _ready() would have run - so nothing was
# listening when those Prompts were added and every render came out with the
# lights off. The glow had been correct for hours; the only thing wrong was
# that nothing had attached it in the path being looked at.
func _enter_tree() -> void:
	get_tree().node_added.connect(_on_node_added)


func _ready() -> void:
	_sweep(get_tree().root)


# Anything that entered the tree before we were listening.
func _sweep(n: Node) -> void:
	if n.name == &"Prompt":
		var host: Node = n.get_parent()
		if host is Node2D:
			_attach(host)
	elif n.name == &"Background" and n.get_parent() is Node2D:
		_dress(n, n.get_parent())
	for c in n.get_children():
		_sweep(c)


func _on_node_added(n: Node) -> void:
	# Every street draws its plate from a node called Background. If the city
	# is keeping a holiday, that is where the bunting goes: above the plate,
	# below everybody standing on it.
	if n.name == &"Background" and n.get_parent() is Node2D:
		_dress.call_deferred(n, n.get_parent())
		return
	if n.name != &"Prompt":
		return
	var host: Node = n.get_parent()
	if host == null or not (host is Node2D):
		return
	# Deferred: this fires while the tree is still being built, and adding a
	# child to a node mid-signal is how you get a node added twice.
	_attach.call_deferred(host)


# The cats a plate declares, turned into things you can sit down next to.
#
# Fifteen cities had cats and every one of them was paint. They are the only
# creature in this game that wants nothing from the alien and cannot be
# misunderstood, which makes them worth being able to reach.
func _cats(bg: Node, host: Node2D) -> void:
	if not is_instance_valid(host) or not is_instance_valid(bg):
		return
	if not bg.has_method("cats") or host.has_node("StreetCat"):
		return
	var first: bool = true
	for row in bg.call("cats"):
		if not (row is Array) or (row as Array).size() < 3:
			continue
		var c: Node2D = STREET_CAT.instantiate()
		c.position = (row as Array)[0]
		c.set("pose", int((row as Array)[1]))
		c.set("coat", int((row as Array)[2]))
		# The first keeps the node name the guard above looks for.
		if not first:
			c.name = "StreetCat_" + str(int(c.position.x))
		first = false
		host.add_child(c)


func _dress(bg: Node, host: Node2D) -> void:
	if not is_instance_valid(host) or not is_instance_valid(bg):
		return
	_cats(bg, host)
	if host.has_node("HolidayDressing"):
		return
	# A street's background carries `district`; an interior's carries `room`.
	# The scene ROOT was the obvious place to ask, and is the wrong one: the
	# three original cities have bespoke root scripts with no region on them
	# at all, so Berlin would never have been dressed for its own holiday.
	if not ("district" in bg):
		return
	# And the crowd, sized to what this district actually is. Same test, same
	# moment: a street is a street for both.
	if not host.has_node("Crowd"):
		var c := Node2D.new()
		c.name = "Crowd"
		c.set_script(CROWD)
		c.set("district", String(bg.get("district")))
		host.add_child(c)
	var d := Node2D.new()
	d.name = "HolidayDressing"
	d.set_script(DRESS)
	d.z_index = -1
	host.add_child(d)


func _attach(host: Node2D) -> void:
	if not is_instance_valid(host) or host.has_node("Glow"):
		return
	var g := Node2D.new()
	g.name = "Glow"
	g.set_script(GLOW)
	host.add_child(g)
	var area := host.get_node_or_null("InteractionArea") as Node2D
	if area != null:
		g.position = area.position


# A district activity must never consume the talk key at a named character.
# Counter talk areas can be offset from the person, so use their actual
# proximity flag rather than the distance to their sprite behind the counter.
func dialogue_in_range() -> bool:
	var scene := get_tree().current_scene
	if scene == null:
		return false
	for n in scene.get_children():
		if not (n is Node2D) or not n.is_visible_in_tree():
			continue
		if n.get("player_nearby") != true or n.get("_busy") == true:
			continue
		if n.has_method("_start_dialogue") or n.has_method("_talk"):
			var rounds: Variant = n.get("_rounds")
			if rounds is Array and rounds.is_empty():
				continue
			return true
	return false
