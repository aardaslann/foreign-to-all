extends "res://tools/design_whole_object_depth.gd"

# Representative depth/contact checks only; full city walking QA is deferred.
func feet(x: float,y: float) -> Vector2:
	return Vector2(x*1152.0/1672.0,y*648.0/941.0)-Vector2(0,22)

func _run() -> void:
	await load_world("MumbaiTransit")
	await create_timer(.5).timeout
	still()
	await capture("transit-seats-behind",feet(880,735))
	await capture("transit-seats-front",feet(880,831))
	await sweep("station seats block at their base",feet(880,831),feet(880,720),true)
	await load_world("MumbaiAirport")
	still()
	await capture("airport-belt-behind",feet(1040,752))
	await capture("airport-belt-front",feet(995,918))
	await sweep("belt footprint stops the player",feet(1040,752),feet(1040,875),true)
	await load_world("MumbaiBandra")
	still()
	await capture("flowering-tree-edge",feet(1114,668))
	await capture("flowering-tree-front",feet(1076,716))
	await load_world("MumbaiColaba")
	still()
	await capture("bus-shelter-front",feet(1360,716))
	await sweep("bus panel blocks passage through glass",feet(1360,716),feet(1360,649),true)
	print("MUMBAI_SPOT_CHECK ",failures.size()," failures")
	quit(0 if failures.is_empty() else 1)
