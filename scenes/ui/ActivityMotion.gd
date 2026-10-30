class_name ActivityMotion
extends RefCounted

# Actions have an anticipation, a readable action and a settled finish. The
# player still controls reading and advancement; movement never gates input.
static func phase_curve(value: float) -> float:
	var v: float = clampf(value, 0.0, 1.0)
	return v * v * (3.0 - 2.0 * v)

static func sample(act: String, elapsed: float, actor: int, reduced: bool = false) -> Dictionary:
	var t: float = maxf(elapsed - float(actor % 3) * 0.10, 0.0)
	var out: Dictionary = {"pose": act, "x": 0.0, "y": 0.0, "progress": 1.0}
	if reduced:
		return out
	var arrival: float = phase_curve((t - 0.18) / 1.65)
	var reach: float = phase_curve((t - 0.28) / 0.65)
	var settle: float = phase_curve((t - 1.30) / 0.70)
	match act:
		"nod":
			out["pose"] = "bow" if t > 0.2 and t < 0.65 else "stand"
		"climb":
			out["pose"] = "reach" if int(t*3.5)%2 == 0 else "interact"
		"unroll_cloth":
			out["pose"] = "reach" if t > 0.3 and t < 2.5 else "stand"
		"hold_ladder":
			out["pose"] = "reach"
		"turn_organ":
			# The hand and crank cycle; the musician's feet remain planted.
			out["pose"] = "interact" if int(t*2.0)%2 == 0 else "reach"
		"spray", "string_lei":
			out["pose"] = "interact" if t < 2.6 and int(t*2.2)%2 == 0 else "reach"
		"polish_shoe":
			out["pose"] = "interact" if t < 2.8 and int(t*2.5)%2 == 0 else "reach"
		"haul_rope":
			# Two shared pulls finish with planted feet while the text is read.
			var pull: float = sin(clampf(t/2.8,0.0,1.0)*TAU*2.0)
			out["x"] = pull * .006 * (1.0-phase_curve((t-2.4)/.4))
			out["pose"] = "reach" if t < 2.8 else "stand"
		"sew":
			out["pose"] = "interact" if int(t*3.0)%2==0 else "reach"
		"surf":
			out["x"] = sin(t*.5+actor)*.018
			out["y"] = sin(t*1.3+actor)*.002
			out["pose"] = "reach"
		"walk", "carry", "haul":
			out["x"] = lerpf(-0.105, 0.0, arrival)
			out["pose"] = "walk" if arrival < 0.999 else ("carry" if act == "carry" else "stand")
			out["progress"] = arrival
		"walk_away":
			# Leave the conversation mark once, then stay outside the frame.
			# Normal walking is an arrival and would jump back behind the mark.
			var departure: float = phase_curve((t - 0.3) / 2.8)
			out["x"] = 0.95 * departure
			out["pose"] = "walk" if departure < 0.999 else "stand"
			out["progress"] = departure
		"offer", "hand_over", "take", "reach", "interact", "count":
			out["x"] = (reach - settle) * (0.017 if actor == 0 else -0.017)
			out["pose"] = "stand" if t < 0.28 or t > 2.0 else act
			out["progress"] = reach
		"recoil":
			out["x"] = -0.024 * phase_curve(t / 0.32) + 0.008 * phase_curve((t - 0.65) / 0.75)
			out["pose"] = "recoil" if t < 0.7 else "watch"
		"bow", "pray", "kneel":
			out["pose"] = "stand" if t < 0.4 or t > 2.8 else act
		"point", "wave":
			out["pose"] = "stand" if t < 0.3 or t > 2.25 else act
		"drink", "eat", "pour", "cut":
			out["pose"] = "stand" if t < 0.3 else act
			out["progress"] = phase_curve((t - 0.3) / 1.0)
		"queue":
			out["x"] = lerpf(-0.032, 0.0, phase_curve((t - float(actor) * 0.35) / 1.4))
			out["pose"] = "walk" if t < 1.4 + float(actor) * 0.35 else "wait"
		"look_up":
			out["pose"] = "watch" if t < 0.4 else "look"
		"strum":
			# Hands keep the rhythm; feet and the camera stay planted.
			out["pose"] = "interact" if int(t * 1.5) % 4 == 0 else "watch"
		"push":
			out["x"] = lerpf(-0.07, 0.0, phase_curve((t - 0.4) / 2.1))
			out["pose"] = "reach" if t < 2.5 else "stand"
		"scrub", "write":
			out["pose"] = "reach" if int(t * 2.4) % 2 == 0 else "interact"
			out["x"] = sin(t * 4.2) * 0.005 * (1.0 - phase_curve((t - 2.6) / 0.8))
		"swim":
			out["pose"] = "sit"
			out["x"] = lerpf(-0.025, 0.018, phase_curve(t / 3.4))
			out["y"] = 0.035 + sin(t * 2.2) * 0.006
	return out

static func prop_at(shot: Dictionary, elapsed: float) -> float:
	var at: float = float(shot.get("prop_at", 0.5))
	var cast: Array = shot.get("cast", [])
	var giver: float = -1.0
	var taker: float = -1.0
	for person: Dictionary in cast:
		var act: String = String(person.get("act", "stand"))
		if act in ["offer", "hand_over"]:
			giver = float(person.get("at", at))
		elif act in ["take", "reach"]:
			taker = float(person.get("at", at))
	if giver >= 0.0 and taker >= 0.0:
		return lerpf(lerpf(0.12, 0.88, giver), lerpf(0.12, 0.88, taker), phase_curve((elapsed - 0.55) / 1.05))
	return at

