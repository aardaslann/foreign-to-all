extends SceneTree

# The background music (autoload/AudioManager.gd, audio/music/): every city,
# the title and the airports have a seamless loop; a scene picks its city's
# track; walking within a city never restarts it; a new place crossfades;
# speech ducks it; indoors muffles it; a holiday reel swaps in the city's
# festival and hands the street back when it ends.
#
# Run: godot --headless --path . --script res://tools/music_test.gd

const CORE := ["berlin", "london", "paris", "moscow", "istanbul", "mumbai", "tokyo", "mexico"]
const MIN_LOOP_S := 40.0
const MIN_SEAM := 0.85

var checks := 0
var failures := 0
var am: Node
var gs: Node


func _initialize() -> void:
	_run.call_deferred()


func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("MUSIC: " + message)


func _run() -> void:
	root.get_node("SaveManager").use_test_storage("music")
	am = root.get_node("AudioManager")
	gs = root.get_node("GameState")
	gs.reset()
	_check_library()
	_check_scene_choice()
	_check_mix()
	await _check_reel()
	am.stop_music()
	print("MUSIC: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)


# Every place has a track, and every track is a real loop, not a song.
func _check_library() -> void:
	var report: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string("res://audio/music/music.json"))
	var keys: Array = gs.CITIES.keys() + ["title", "travel"]
	for c: String in CORE:
		keys.append("festival_" + c)
	for key: String in keys:
		check(am.has_music(key), "%s has a track" % key)
		if not am.has_music(key):
			continue
		var stream := load(am.music_path(key)) as AudioStreamOggVorbis
		check(stream != null, "%s is Ogg Vorbis, which loops without a gap" % key)
		if stream != null:
			check(stream.get_length() >= MIN_LOOP_S,
				"%s loops after %.0fs, not sooner" % [key, stream.get_length()])
		var entry: Dictionary = report.get(key, {})
		check(not entry.is_empty(), "%s is described in music.json" % key)
		check(float(entry.get("seam_likeness", 0.0)) >= MIN_SEAM,
			"%s joins where both sides sound alike" % key)


# A stand-in for a world scene: scene_music only reads where it was loaded from.
func _scene(path: String) -> Node:
	var n := Node.new()
	n.scene_file_path = path
	return n


func _settle(seconds: float) -> void:
	for i in range(int(seconds / 0.05)):
		am._mix_music(0.05)


func _check_scene_choice() -> void:
	am.title_music()
	check(am._music_path == am.music_path("title"), "the title screen plays the title theme")
	check((am._decks[am._deck].stream as AudioStreamOggVorbis).loop, "the playing track is set to loop")

	gs.city = "berlin"
	var scenes: Array[Node] = [_scene("res://scenes/world/Mitte.tscn"), _scene("res://scenes/world/Kiez.tscn"),
		_scene("res://scenes/world/Room01.tscn"), _scene("res://scenes/world/Airport.tscn")]
	am.scene_music(scenes[0])
	check(am._music_path == am.music_path("berlin"), "a Berlin street plays Berlin's theme")
	var deck: int = am._deck
	var player: AudioStreamPlayer = am._decks[deck]
	am.scene_music(scenes[1])
	check(am._deck == deck and player.playing, "walking to another Berlin district carries the same track on")
	am.scene_music(scenes[2], true)
	check(am._deck == deck and am._indoors, "stepping indoors keeps the track and muffles it")
	am.scene_music(scenes[3], true)
	check(am._music_path == am.music_path("travel"), "the airport plays the departures theme")
	check(not am._indoors, "the departures theme is never muffled")
	for n: Node in scenes:
		n.free()


func _check_mix() -> void:
	_settle(3.0)                    # the airport's track, at full level
	gs.city = "istanbul"
	var carsi := _scene("res://scenes/world/IstanbulCarsi.tscn")
	am.scene_music(carsi)
	carsi.free()
	var incoming: int = am._deck
	var outgoing: int = 1 - incoming
	_settle(0.6)
	check(am._gain[incoming] > 0.1 and am._gain[outgoing] > 0.1,
		"arriving in a new city crossfades: both tracks sound for a moment")
	_settle(2.5)
	check(is_equal_approx(am._gain[incoming], 1.0), "the new city's track reaches full level")
	check(not am._decks[outgoing].playing, "the old track stops once it has faded out")
	var full_db: float = am._decks[incoming].volume_db

	am._voice.stream = load(am.music_path("title"))
	am._voice.play()
	_settle(2.0)
	check(am._decks[incoming].volume_db < full_db - 6.0, "the music steps back while somebody speaks")
	am._voice.stop()
	_settle(2.0)
	check(absf(am._decks[incoming].volume_db - full_db) < 0.5, "the music comes back when they stop")

	am.set_indoors(true)
	_settle(1.5)
	check(am._lowpass != null, "the Music bus has its door filter")
	if am._lowpass != null:
		check(am._lowpass.cutoff_hz < 2000.0, "indoors the city is heard through the walls")
	check(am._decks[incoming].volume_db < full_db - 2.0, "indoors the music is a little quieter")
	am.set_indoors(false)
	_settle(1.5)
	if am._lowpass != null:
		check(am._lowpass.cutoff_hz > 15000.0, "outdoors the music is clear again")


# A holiday reel, through the real cutscene: the festival under it, then the
# street's music back, muffled again if the reel started indoors.
func _check_reel() -> void:
	var cs: CanvasLayer = load("res://scenes/ui/Cutscene.gd").new()
	root.add_child(cs)
	await process_frame
	gs.city = "berlin"
	var room := _scene("res://scenes/world/Room01.tscn")
	am.scene_music(room, true)
	room.free()
	var street: String = am._music_path
	cs.play("berlin", root.get_node("Journey").holiday_reel("berlin"), true)
	check(am.in_festival() and am._music_path == am.music_path("festival_berlin"),
		"Berlin's holiday reel plays Berlin's festival")
	check(not am._indoors, "the festival is never muffled")
	cs._close()
	check(am._music_path == street and am._indoors, "after the reel the street's music returns, as it was")
	check(not am.in_festival(), "the festival has ended")
	cs.play("berlin", [{"say": "An ordinary cutscene.", "cast": []}])
	check(am._music_path == street, "an ordinary cutscene leaves the music alone")
	cs._close()
	am.end_festival()
	check(am._music_path == street, "ending a festival that is not playing changes nothing")
	cs.queue_free()
	await process_frame
