extends "res://tools/design_whole_object_depth.gd"

# A representative installation check, not the deferred exhaustive city audit.
func feet(x: float,y: float) -> Vector2:
	return Vector2(x*1152.0/1672.0,y*648.0/941.0)-Vector2(0,22)

func _run() -> void:
	await load_world("DakarTransit")
	await create_timer(.4).timeout
	still()
	await capture("station-seats-behind",feet(473,609))
	await capture("station-seats-front",feet(473,699))
	await sweep("seat base is solid",feet(473,699),feet(473,609),true)
	await walk_route("boarding-door-approach",[feet(806,745),feet(806,590)])
	await capture("boarding-door",feet(806,590))
	await capture("kiosk-glass-behind",feet(1093,598))
	await load_world("DakarAirport")
	still()
	await capture("queue-rail-behind",feet(996,655))
	await capture("queue-rail-front",feet(1081,735))
	await sweep("queue belt footprint blocks crossing",feet(1081,735),feet(1081,650),true)
	await load_world("DakarPlateau")
	still()
	await capture("tree-side-leaves",feet(799,666))
	await capture("tree-front",feet(733,718))
	await load_world("DakarYoff")
	still()
	await capture("net-at-front-approach",feet(637,683))
	await sweep("pirogue base stops walking into hull",feet(939,722),feet(939,622),true)
	print("DAKAR_SPOT_CHECK ",failures.size()," failures")
	quit(0 if failures.is_empty() else 1)
