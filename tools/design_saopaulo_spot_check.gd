extends "res://tools/design_mexico_spot_check.gd"

# Newly aligned service routes and glass/ground contacts only.
# The user has deferred exhaustive per-corner walking QA.
func _run() -> void:
	await load_world("SaoPauloPaulista")
	await create_timer(.4).timeout
	still()
	await walk_route("shelter-rear-approach",[feet(1028,816),feet(1028,709),feet(426,709)])
	await capture("shelter-glass-behind",feet(426,709))
	await capture("shelter-front",feet(426,789))
	await sweep("shelter base stops crossing",feet(426,789),feet(426,709),true)
	await walk_route("metro-opening",[feet(1350,820),feet(1350,771)])
	await capture("metro-lettering",feet(1350,771))
	await load_world("SaoPauloExchange")
	still()
	await walk_route("queue-right-opening",[feet(1010,798),feet(1010,596)])
	await capture("exchange-counter",feet(1010,596))
	await sweep("counter base stops crossing",feet(1010,596),feet(1010,490),true)
	await load_world("SaoPauloAirport")
	still()
	await walk_route("airport-information",[feet(1425,925),feet(1145,925)])
	await sweep("information base stops crossing",feet(1145,925),feet(1145,801),true)
	await capture("airport-counter",player.position)
	await walk_route("airport-gate-aisle",[feet(1468,917),feet(1468,801),feet(1468,775)])
	print("SAOPAULO_SPOT_CHECK ",failures.size()," failures")
	quit(0 if failures.is_empty() else 1)
