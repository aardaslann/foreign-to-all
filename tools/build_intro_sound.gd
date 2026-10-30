extends SceneTree

# Original non-musical sound design, rendered once as a resource, not generated
# on the player's loading path. All samples are synthesised here; no libraries.
const RATE := 22050
const LENGTH := 28.0


func _initialize() -> void:
	var data := PackedByteArray()
	data.resize(int(LENGTH * RATE) * 4)
	var rng := RandomNumberGenerator.new()
	rng.seed = 412
	var air := 0.0
	var low := 0.0
	var phase := 0.0
	for i in range(int(LENGTH * RATE)):
		var t := float(i) / RATE
		var noise := rng.randf_range(-1.0, 1.0)
		air = lerpf(air, noise, 0.085)
		low = lerpf(low, noise, 0.007)
		var entry := smoothstep(3.8, 10.9, t) * (1.0 - smoothstep(11.10, 11.45, t))
		var ship := smoothstep(0.2, 1.5, t) * (1.0 - smoothstep(6.1, 7.1, t))
		phase += TAU * lerpf(92.0, 49.0, smoothstep(0.0, 7.0, t)) / RATE
		var sample := sin(phase) * 0.035 * ship + sin(phase * 2.003) * 0.012 * ship
		# No wind. The descent's roaring noise band and the hiss left under the
		# whole ground scene were the loudest, harshest thing in the opening,
		# and the synthesised footsteps did not sound like feet; all removed
		# (2026-10-01, user). The crash, the hum and the cooling hull stay.
		var landing := t - 11.15
		if landing >= 0.0 and landing < 1.9:
			var envelope := minf(landing * 35.0, 1.0) * exp(-landing * 3.5)
			sample += (sin(TAU * (58 * landing - 8 * landing * landing)) * 0.30 + air * 0.75) * envelope
		# Cooling metal in the hull, sparse and quiet.
		for start: float in [13.1, 15.5, 20.2]:
			var ring := t - start
			if ring >= 0.0 and ring < 1.8:
				sample += (sin(ring * TAU * 731) + sin(ring * TAU * 1174) * 0.4) * 0.012 * exp(-ring * 4) * minf(ring * 90, 1.0)
		var fade := 1.0 - smoothstep(27.2, 28.0, t)
		var pan := lerpf(0.25, -0.25, smoothstep(7.6, 11.1, t)) * entry
		data.encode_s16(i * 4, int(clampf(sample * fade * (1.0 - pan), -0.9, 0.9) * 32767))
		data.encode_s16(i * 4 + 2, int(clampf(sample * fade * (1.0 + pan), -0.9, 0.9) * 32767))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.stereo = true
	stream.data = data
	DirAccess.make_dir_recursive_absolute("res://audio/intro")
	var error := stream.save_to_wav("res://audio/intro/arrival.wav")
	print("INTRO SOUND: ", error_string(error), " (", LENGTH, " seconds)")
	quit(0 if error == OK else 1)
