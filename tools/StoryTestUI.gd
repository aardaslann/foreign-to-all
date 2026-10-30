extends RefCounted

# Drive the same untimed acknowledgement a player uses. Headless story runs
# skip these panels; graphical story runs must explicitly dismiss them.
static func discovery(tree: SceneTree) -> bool:
	var panel := tree.get_first_node_in_group("word_discovery")
	if panel == null or not panel._open: return false
	if not panel._revealed:
		panel.reveal()
	else:
		panel._process(0.25)
		panel._advance()
	return true
