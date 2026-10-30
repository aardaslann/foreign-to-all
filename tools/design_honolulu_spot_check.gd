extends "res://tools/design_whole_object_depth.gd"

# Representative integration/depth checks; exhaustive walking is deferred.
func feet(x: float,y: float) -> Vector2:
	return Vector2(x*1152.0/1672.0,y*648.0/941.0)-Vector2(0,22)

func _run() -> void:
	await load_world("HonoluluTransit")
	await create_timer(.4).timeout
	still()
	await capture("station-seats-behind",feet(257,683))
	await capture("station-seats-front",feet(257,819))
	await sweep("station seats have ground contact",feet(257,819),feet(257,683),true)
	await walk_route("train-door-approach",[feet(700,808),feet(700,657)])
	await capture("train-boarding",feet(700,657))
	await load_world("HonoluluNorthShore")
	still()
	await capture("shelter-front",feet(1490,717))
	await sweep("shelter bench stops crossing",feet(1490,717),feet(1490,656),true)
	await load_world("HonoluluWaikiki")
	still()
	await capture("tree-side-canopy",feet(612,799))
	await capture("flower-box-behind",feet(1008,830))
	await capture("flower-box-front",feet(1008,887))
	await sweep("flower box has ground contact",feet(1008,887),feet(1008,830),true)
	await load_world("HonoluluAirport")
	still()
	await capture("carousel-left-approach",feet(917,727))
	await sweep("carousel cannot be crossed",feet(1290,812),feet(1290,702),true)
	await load_world("HonoluluManoa")
	still()
	await sweep("garden wall blocks walking into facade",feet(700,746),feet(700,646),true)
	await load_world("HonoluluExchange")
	still()
	await capture("clerk-beside-monitor",feet(918,688))
	print("HONOLULU_SPOT_CHECK ",failures.size()," failures")
	quit(0 if failures.is_empty() else 1)
