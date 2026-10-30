extends "res://tools/design_whole_object_depth.gd"

# Focused integration checks only; exhaustive walking is deferred.
func feet(x: float,y: float) -> Vector2:
	return Vector2(x*1152.0/1672.0,y*648.0/941.0)-Vector2(0,22)

func capture(label: String, at: Vector2, phase: float = 1.0) -> Image:
	check(clear_at(at),label+" capture stands on clear floor")
	player.position = at
	player.velocity = Vector2.ZERO
	for node in scene.get_children():
		if node.get("scene_id") != null: node.set("_clock",phase)
	for i in range(3): await process_frame
	# A hidden, entirely stationary window may stop drawing fresh frames.
	# Request the readback explicitly instead of waiting indefinitely.
	RenderingServer.force_draw()
	var picture := root.get_texture().get_image()
	picture.save_png(out.path_join(label+".png"))
	return picture

func _run() -> void:
	await load_world("MexicoMerced")
	await create_timer(.4).timeout
	still()
	await walk_route("hotel-door",[feet(184,817),feet(184,715)])
	await walk_route("exchange-door",[feet(456,817),feet(456,715)])
	await walk_route("metro-door",[feet(1225,817),feet(1225,733)])
	await capture("cart-behind",feet(1136,672))
	await capture("cart-front",feet(1136,761))
	await sweep("cart wheels stop crossing",feet(1136,761),feet(1136,672),true)
	await load_world("MexicoJuarez")
	still()
	# The bicycle is against the shop: there is no rear walking lane.
	await capture("bicycle-side",feet(904,721))
	await capture("bicycle-front",feet(995,743))
	await load_world("MexicoRoma")
	still()
	await capture("jacaranda-behind",feet(912,657))
	await capture("jacaranda-front",feet(912,755))
	await sweep("tree root has contact",feet(912,755),feet(912,657),true)
	await walk_route("metro-rail-approach",[feet(1555,834),feet(1555,761)])
	await load_world("MexicoCondesa")
	still()
	await walk_route("park-gate",[feet(1213,834),feet(1213,717)])
	await capture("cafe-chair-behind",feet(238,660))
	await capture("cafe-chair-front",feet(238,734))
	await load_world("MexicoExchange")
	still()
	await walk_route("queue-opening-to-counter",[feet(947,804),feet(947,629)])
	await capture("exchange-glass",feet(947,629))
	await load_world("MexicoTransit")
	still()
	await walk_route("train-doors",[feet(719,812),feet(719,573)])
	await walk_route("ticket-machine",[feet(1204,814),feet(1204,733)])
	await capture("seat-behind",feet(277,756))
	await capture("seat-front",feet(277,841))
	await sweep("seat feet stop crossing",feet(277,841),feet(277,756),true)
	await load_world("MexicoHotel")
	still()
	await walk_route("reception",[feet(979,817),feet(979,576),feet(1309,576)])
	await capture("reception-lettering",feet(1309,576))
	await load_world("MexicoAirport")
	still()
	await walk_route("airport-counter",[feet(673,854),feet(673,797)])
	await sweep("carousel plinth blocks feet",feet(1300,827),feet(1300,666),true)
	await capture("carousel-front-contact",player.position)
	print("MEXICO_SPOT_CHECK ",failures.size()," failures")
	quit(0 if failures.is_empty() else 1)
