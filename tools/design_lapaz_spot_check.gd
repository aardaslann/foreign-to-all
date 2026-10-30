extends "res://tools/design_whole_object_depth.gd"

# Representative integration/contact checks; exhaustive walking is deferred.
func feet(x: float,y: float) -> Vector2:
	return Vector2(x*1152.0/1672.0,y*648.0/941.0)-Vector2(0,22)

func _run() -> void:
	await load_world("LaPazTransit")
	await create_timer(.4).timeout
	still()
	await capture("seats-behind",feet(260,674))
	await capture("seats-front",feet(260,807))
	await sweep("seats stop crossing at their feet",feet(260,807),feet(260,674),true)
	# The rear machinery platform is outside the walkable station floor.
	# Inspect the glass from its public approach, not by placing an actor there.
	await capture("glass-approach",feet(665,737))
	await sweep("entire glass fare gate is solid",feet(645,764),feet(645,650),true)
	await walk_route("fare-reader-approach",[feet(652,829),feet(652,737)])
	await walk_route("ticket-machine-approach",[feet(1146,829),feet(1146,742)])
	await load_world("LaPazSopocachi")
	still()
	await walk_route("stair-mouth",[feet(1068,823),feet(1068,720)])
	await load_world("LaPazIrpavi")
	still()
	await capture("complete-tree-side",feet(625,701))
	await capture("tree-front",feet(469,779))
	await sweep("tree planter has ground contact",feet(469,779),feet(469,677),true)
	await load_world("LaPazExchange")
	still()
	await walk_route("queue-opening-to-service",[feet(646,738),feet(646,648)])
	await capture("clerk-through-glass",feet(646,648))
	await load_world("LaPazHotel")
	still()
	await capture("coffee-table-behind",feet(386,705))
	await capture("coffee-table-front",feet(386,756))
	await capture("hotel-clerk",feet(824,648))
	await load_world("LaPazAirport")
	still()
	await sweep("carousel has a solid plinth",feet(975,861),feet(975,752),true)
	await capture("carousel-left-edge",feet(575,799))
	print("LAPAZ_SPOT_CHECK ",failures.size()," failures")
	quit(0 if failures.is_empty() else 1)
