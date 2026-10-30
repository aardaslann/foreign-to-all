extends Node

# Central audio: music for every place (looped files, see the Music section),
# recorded voices, and light ambience (synthesised at runtime, no asset files).
#
# Two attempts at a synthesised voice - square-wave blips, then a formant
# synthesiser - both read as a machine rather than a person, and were removed.
# Every person who speaks now has a voice of their own, designed in ElevenLabs
# from who they are (tools/voice_cast.json) and recorded line by line
# (tools/eleven_voices.py), pending native review. The crowd speaks too:
# German, Turkish, English, French and Mexican Spanish street fragments, in two
# passers-by's voices each. audio/voice/manifest.json is the index this reads;
# a line is found by who says it and exactly what they say.
# Everything keeps playing through pauses; volumes follow the settings menu.

const MIX_RATE := 22050.0
const VOICE_MANIFEST := "res://audio/voice/manifest.json"
# A passer-by is quieter than somebody talking to you, and only one or two of
# them at once, or a street turns into a wall of noise.
const MURMUR_DB := -9.0
const MURMUR_VOICES := 2
const MURMUR_REACH := 260.0

# Music: two decks so one track can fade out while the next fades in.
const MUSIC_DIR := "res://audio/music/"
const MUSIC_DB := -5.0            # under play: background, not a soundtrack album
const TITLE_DB := -1.0            # nothing to talk over on the title screen
const DUCK_DB := -8.0             # while somebody is speaking
const INDOOR_DB := -3.0
const FADE_OUT := 1.2
const FADE_IN := 1.8
const INDOOR_CUTOFF := 1400.0
const OUTDOOR_CUTOFF := 20000.0
var _decks: Array[AudioStreamPlayer] = []
var _gain: Array[float] = [0.0, 0.0]     # each deck's crossfade position, 0..1
var _aim: Array[float] = [0.0, 0.0]
var _deck: int = 0
var _music_path: String = ""
var _music_db: float = MUSIC_DB
var _duck: float = 1.0
var _indoors: bool = false
var _room_db: float = 0.0
var _cutoff: float = OUTDOOR_CUTOFF
var _lowpass: AudioEffectLowPassFilter
var _resume: String = ""                 # what a festival reel interrupted
var _resume_indoors: bool = false
var _fallback_db: float = 0.0            # only when the project has no Music bus

var _voice: AudioStreamPlayer
var _murmurs: Array[AudioStreamPlayer2D] = []
var _manifest: Dictionary = {}
var _last_line: Array = []          # [voice, text] of the last thing said to him


var _amb: AudioStreamPlayer
var _amb_pb: AudioStreamGeneratorPlayback
var _amb_kind: String = "none"
var _amb_level: float = 0.0      # smoothed target volume
var _brown: float = 0.0          # brown-noise integrator
var _gust_t: float = 0.0

var _vol_timer: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	for _i in range(2):
		var deck := AudioStreamPlayer.new()
		deck.bus = _bus("Music")
		deck.volume_db = -80.0
		add_child(deck)
		_decks.append(deck)
	_add_lowpass()

	var amb_stream := AudioStreamGenerator.new()
	amb_stream.mix_rate = MIX_RATE
	amb_stream.buffer_length = 0.25
	_amb = AudioStreamPlayer.new()
	_amb.stream = amb_stream
	_amb.bus = _bus("SFX")
	add_child(_amb)
	_amb.play()
	_amb_pb = _amb.get_stream_playback()

	_voice = AudioStreamPlayer.new()
	_voice.bus = _bus("Speech")
	add_child(_voice)
	for _i in range(MURMUR_VOICES):
		var m := AudioStreamPlayer2D.new()
		m.bus = _bus("Speech")
		m.volume_db = MURMUR_DB
		m.max_distance = MURMUR_REACH * 1.6
		m.attenuation = 1.4
		add_child(m)
		_murmurs.append(m)
	_load_manifest()

	_apply_volumes()


func _bus(bus_name: String) -> String:
	return bus_name if AudioServer.get_bus_index(bus_name) >= 0 else "Master"


func _process(delta: float) -> void:
	_vol_timer += delta
	if _vol_timer >= 0.5:
		_vol_timer = 0.0
		_apply_volumes()
	_fill_ambience(delta)
	_mix_music(delta)


func _apply_volumes() -> void:
	# If the named buses exist, SaveManager drives them; otherwise scale here
	if AudioServer.get_bus_index("Music") < 0:
		_fallback_db = linear_to_db(maxf(0.0001,
			float(SaveManager.settings.get("music_volume", 0.8)) * 0.9))
		_amb.volume_db = linear_to_db(maxf(0.0001,
			float(SaveManager.settings.get("sfx_volume", 0.8)) * 0.5))


# ── Music ─────────────────────────────────────────────────────────────────────
#
# One track per place, from audio/music/ (Suno generations cut into seamless
# loops by tools/music_loop.py): the title, every city, the airports, and each
# core city's festival for its holiday reel. Walking between scenes of the same
# city does not restart the music; arriving somewhere new crossfades. Indoors,
# the city carries on muffled through the walls, and whenever somebody speaks
# the music steps back so the words are never fighting it.

static func music_path(key: String) -> String:
	return MUSIC_DIR + key + ".ogg"


func has_music(key: String) -> bool:
	return not key.is_empty() and ResourceLoader.exists(music_path(key))


func play_music(path: String, level_db: float = MUSIC_DB) -> void:
	_music_db = level_db
	if path == _music_path and _decks[_deck].playing and _aim[_deck] > 0.0:
		return
	_music_path = path
	_aim[_deck] = 0.0                       # the old track leaves
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	var stream := load(path) as AudioStream
	if stream == null:
		return
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	elif stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	_deck = 1 - _deck
	var deck := _decks[_deck]
	deck.stream = stream
	deck.play()
	_gain[_deck] = 0.0
	_aim[_deck] = 1.0


func stop_music() -> void:
	play_music("")


func title_music() -> void:
	set_indoors(false)
	play_music(music_path("title"), TITLE_DB)


# What a scene should sound like, from where it is: the airports have the
# departures theme, anywhere else in a city has that city's. Called by every
# world scene's _ready with the scene itself (current_scene is not set yet).
func scene_music(scene: Node, indoors: bool = false) -> void:
	var file := scene.scene_file_path.get_file().to_lower() if scene != null else ""
	var key: String = GameState.city
	if file.contains("airport") or file.contains("havalimani") or not has_music(key):
		key = "travel"
		indoors = false
	set_indoors(indoors)
	play_music(music_path(key))


# The holiday reel: the city's festival for as long as it runs, then back to
# wherever it was playing. Returns false for a city without a festival track.
func festival(city: String) -> bool:
	if not has_music("festival_" + city):
		return false
	if not in_festival():
		_resume = _music_path
		_resume_indoors = _indoors
	set_indoors(false)
	play_music(music_path("festival_" + city), MUSIC_DB + 2.0)
	return true


# Back to what was playing before, muffled again if it was; a reel that began
# in silence ends in silence.
func end_festival() -> void:
	if not in_festival():
		return
	set_indoors(_resume_indoors)
	play_music(_resume)
	_resume = ""


func in_festival() -> bool:
	return _music_path.get_file().begins_with("festival_")


func set_indoors(on: bool) -> void:
	_indoors = on


# The door filter is added at run time, so it is taken off again on the way out
# rather than left for the audio server to hold past shutdown.
func _exit_tree() -> void:
	for deck in _decks:
		deck.stop()
		deck.stream = null
	var bus := AudioServer.get_bus_index("Music")
	if bus < 0 or _lowpass == null:
		return
	for i in range(AudioServer.get_bus_effect_count(bus) - 1, -1, -1):
		if AudioServer.get_bus_effect(bus, i) == _lowpass:
			AudioServer.remove_bus_effect(bus, i)
	_lowpass = null


func _add_lowpass() -> void:
	var bus := AudioServer.get_bus_index("Music")
	if bus < 0:
		return
	for i in range(AudioServer.get_bus_effect_count(bus)):
		if AudioServer.get_bus_effect(bus, i) is AudioEffectLowPassFilter:
			_lowpass = AudioServer.get_bus_effect(bus, i)
			return
	_lowpass = AudioEffectLowPassFilter.new()
	_lowpass.cutoff_hz = OUTDOOR_CUTOFF
	AudioServer.add_bus_effect(bus, _lowpass)


func _mix_music(delta: float) -> void:
	_duck = move_toward(_duck, db_to_linear(DUCK_DB) if voice_playing() else 1.0, delta * 1.6)
	_room_db = move_toward(_room_db, INDOOR_DB if _indoors else 0.0, delta * 4.0)
	for i in range(_decks.size()):
		var rate: float = delta / (FADE_IN if _aim[i] > _gain[i] else FADE_OUT)
		_gain[i] = move_toward(_gain[i], _aim[i], rate)
		var deck := _decks[i]
		if _gain[i] <= 0.0 and _aim[i] <= 0.0:
			if deck.playing:
				deck.stop()
			continue
		deck.volume_db = _music_db + _room_db + _fallback_db \
			+ linear_to_db(maxf(_gain[i] * _duck, 0.0001))
	if _lowpass != null:
		# Glide in log frequency, so stepping through a door sounds like a door.
		var aim: float = INDOOR_CUTOFF if _indoors else OUTDOOR_CUTOFF
		_cutoff = exp(lerpf(log(_cutoff), log(aim), minf(1.0, delta * 5.0)))
		_lowpass.cutoff_hz = _cutoff


# ── Voices ────────────────────────────────────────────────────────────────────
#
# A line is found by who says it and exactly what they say, so the same words
# said by two people are two recordings, and editing a line in the script
# without rebuilding the voices falls back to silence rather than to the old
# sentence. Silence is the honest failure here: a voice saying something other
# than what is on screen would be the one lie a language game cannot tell.

static func voice_key(voice: String, text: String) -> String:
	return voice + "|" + " ".join(text.strip_edges().split(" ", false))


func _load_manifest() -> void:
	if not FileAccess.file_exists(VOICE_MANIFEST):
		return
	var data = JSON.parse_string(FileAccess.get_file_as_string(VOICE_MANIFEST))
	if data is Dictionary:
		_manifest = data


func has_voice(voice: String, text: String) -> bool:
	var path := _line_path(voice, text)
	return not path.is_empty() and ResourceLoader.exists(path)


func _line_path(voice: String, text: String) -> String:
	# A time-sensitive street greeting can reuse its exact existing recording.
	# Opt-in only; an unrecorded story line must never get a different speaker.
	if voice.begins_with("chatter:"):
		var paths: Array = Dictionary(_manifest.get("chatter", {})).get(voice_key(voice.trim_prefix("chatter:"), text), [])
		return String(paths[0]) if not paths.is_empty() else ""
	return String(Dictionary(_manifest.get("lines", {})).get(voice_key(voice, text), ""))


func _stream(path: String) -> AudioStream:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as AudioStream


# Somebody says something to him. Returns how long it lasts, or 0.0 when this
# line has not been recorded, so a caller pacing a speech bubble can fall back
# to reading time.
func say(voice: String, text: String) -> float:
	stop_voice()
	var path := _line_path(voice, text)
	var stream: AudioStream = _stream(path)
	_last_line = [voice, text]
	if stream == null:
		return 0.0
	_voice.stream = stream
	_voice.play()
	return stream.get_length()


func voice_seconds(voice: String, text: String) -> float:
	var path := _line_path(voice, text)
	var stream: AudioStream = _stream(path)
	return stream.get_length() if stream != null else 0.0


# "Say that again." The most useful sentence in any language, and the one the
# game lets him have for free.
func replay() -> float:
	if _last_line.size() < 2:
		return 0.0
	return say(String(_last_line[0]), String(_last_line[1]))


func stop_voice() -> void:
	if _voice != null:
		_voice.stop()


func voice_playing() -> bool:
	return _voice != null and _voice.playing


# One word on its own, from the notebook: the sound of a word he has noticed,
# said slowly and clearly by somebody who is nobody in particular. Recorded by
# tools/build_voices.py --words from tools/export_key_words.gd.
func has_word(language: String, word: String) -> bool:
	var path: String = String(Dictionary(_manifest.get("words", {})).get(
		voice_key(language, word.to_lower()), ""))
	return not path.is_empty() and ResourceLoader.exists(path)


func say_word(language: String, word: String) -> void:
	var stream: AudioStream = _stream(String(Dictionary(_manifest.get("words", {})).get(
		voice_key(language, word.to_lower()), "")))
	if stream == null:
		return
	_voice.stream = stream
	_voice.play()


# A fragment from the crowd, from where the person who said it is standing.
# Quiet, positional, and dropped rather than queued when two people are
# already talking - a street does not wait its turn.
func murmur(language: String, text: String, at: Vector2) -> void:
	var options: Array = Dictionary(_manifest.get("chatter", {})).get(
		voice_key(language, text), [])
	# Nobody in the crowd talks over the person who is talking to him.
	if options.is_empty() or voice_playing():
		return
	for m: AudioStreamPlayer2D in _murmurs:
		if m.playing:
			continue
		var stream: AudioStream = _stream(String(options.pick_random()))
		if stream == null:
			return
		m.stream = stream
		m.global_position = at
		m.pitch_scale = randf_range(0.97, 1.03)
		m.play()
		return


# ── Ambience ──────────────────────────────────────────────────────────────────

# "field": airy wind with slow gusts · "street": low city rumble
# "interior": faint room tone · "none": silence
func set_ambience(kind: String) -> void:
	_amb_kind = kind


func _fill_ambience(delta: float) -> void:
	if _amb_pb == null:
		return
	_gust_t += delta
	var target := 0.0
	# Silent. The ambience bed was a constant hiss under every scene in the
	# game and it was louder than anything it was under - reported as "too
	# loud and annoying", which it was. The generator stays so a real recorded
	# bed can be dropped in later; it just plays nothing now.
	match _amb_kind:
		"field", "street", "interior": target = 0.0
	_amb_level = lerpf(_amb_level, target, minf(1.0, delta * 1.5))

	var frames := _amb_pb.get_frames_available()
	while frames > 0:
		# Brown noise: integrate white noise, keep it leashed
		_brown += (randf() * 2.0 - 1.0) * 0.02
		_brown = clampf(_brown, -1.0, 1.0) * 0.998
		var s := _brown * _amb_level
		_amb_pb.push_frame(Vector2(s, s))
		frames -= 1
