extends "res://tools/design_playability.gd"

func _run() -> void:
	catalog=load("res://scenes/world/EnvironmentDesign.gd").catalog()
	await _load_scene("LondonTerrace")
	for stage: String in ["initial","idle","physics","timer"]:
		if stage=="idle": await process_frame
		if stage=="physics": await physics_frame
		if stage=="timer": await create_timer(.2).timeout
		var npc: CharacterBody2D=scene.get_node("Encounter")
		var col: CollisionShape2D=npc.get_node("CollisionShape2D")
		print(stage," NPC node=",npc.global_transform," physics=",PhysicsServer2D.body_get_state(npc.get_rid(),PhysicsServer2D.BODY_STATE_TRANSFORM)," shape=",col.shape.get_rect()," at=",col.position," player=",player.get_node("CollisionShape2D").shape.get_rect()," clear=",_position_clear(Vector2(808,520)))
	var targets := _targets()
	var reachable := _flood("LondonTerrace",targets)
	print("end clear=",_position_clear(Vector2(808,520))," flood808=",reachable.has(Vector2i(101,65)))
	await _walk_route(Vector2(1123.06,543.3),reachable)
	quit()
