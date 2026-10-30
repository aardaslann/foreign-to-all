extends Node

# Every button in the game, in one place, bound at startup.
#
# ── Why this exists ──────────────────────────────────────────────────────────
#
# project.godot had no [input] section at all. The game ran on Godot's built-in
# ui_* defaults plus seventeen hardcoded `event.keycode == KEY_E` checks spread
# across twelve files, and WASD read straight off Input.is_key_pressed() inside
# _physics_process. Which meant:
#
#   * a gamepad did nothing. Not "did something odd" - interact was compared
#     against a keyboard scancode, so a controller could walk around on the
#     built-in ui_* defaults and could not open a single door
#   * nothing could be rebound, by anybody, ever. Left-handed, one-handed, or
#     simply on a keyboard where E is somewhere else - no
#   * the same key was written out in twelve places, so adding a binding meant
#     finding all twelve
#
# ── Why the table is here and not in project.godot ───────────────────────────
#
# It could be in the project file. Hand-writing serialised InputEvent objects
# into project.godot is also the easiest way to corrupt the one file the game
# will not start without, and nothing checks that format until the engine
# refuses to open.
#
# Built here instead: readable, diffable, and a wrong entry fails as one dead
# action rather than as a project that will not load - and rebinding becomes a
# matter of replacing one row rather than rewriting the file the engine is
# currently reading.

# ── The actions ──────────────────────────────────────────────────────────────
#
# Each is [keys, joypad buttons, joypad axes]. An axis entry is [axis, sign].
# Physical keycodes throughout, so a binding follows the key's POSITION and
# WASD stays under the same fingers on AZERTY or QWERTZ - which, in a game
# about arriving somewhere and finding the layout different, would be a poor
# thing to get wrong.
const ACTIONS := {
	# Walking. The built-in ui_* actions carry the arrows and the d-pad, and
	# they are also what every Godot menu uses to move focus - so the game gets
	# its own, and the menus keep theirs.
	"walk_left":  [[KEY_A, KEY_LEFT], [JOY_BUTTON_DPAD_LEFT], [[JOY_AXIS_LEFT_X, -1.0]]],
	"walk_right": [[KEY_D, KEY_RIGHT], [JOY_BUTTON_DPAD_RIGHT], [[JOY_AXIS_LEFT_X, 1.0]]],
	"walk_up":    [[KEY_W, KEY_UP], [JOY_BUTTON_DPAD_UP], [[JOY_AXIS_LEFT_Y, -1.0]]],
	"walk_down":  [[KEY_S, KEY_DOWN], [JOY_BUTTON_DPAD_DOWN], [[JOY_AXIS_LEFT_Y, 1.0]]],

	# The one the whole game is played with. Space as well as E, because half
	# the people who pick this up will try space first.
	"interact":   [[KEY_E, KEY_SPACE], [JOY_BUTTON_A], []],

	# Closing things. Separate from ui_cancel, so rebinding it cannot strand
	# somebody in a menu they can no longer leave.
	"back":       [[KEY_ESCAPE], [JOY_BUTTON_B, JOY_BUTTON_START], []],

	# The four panels.
	"journal":    [[KEY_J], [JOY_BUTTON_Y], []],
	"inventory":  [[KEY_I], [JOY_BUTTON_X], []],
	"quest_log":  [[KEY_Q], [JOY_BUTTON_LEFT_SHOULDER], []],
	"district_map": [[KEY_TAB, KEY_M], [JOY_BUTTON_RIGHT_SHOULDER], []],
	"quest_arrow": [[KEY_G], [JOY_BUTTON_RIGHT_STICK], []],

	# "Noch mal?" The last recorded line, again.
	"hear_again": [[KEY_R], [JOY_BUTTON_BACK], []],
}

# How far a stick moves before the alien does. Godot's default is 0.5, which on
# a worn thumbstick is most of its travel.
const DEADZONE := 0.25

# What a player would call each of these, for the settings screen.
const NAMES := {
	"walk_left": "Walk left", "walk_right": "Walk right",
	"walk_up": "Walk up", "walk_down": "Walk down",
	"interact": "Interact, talk, read", "back": "Close / back",
	"journal": "Notebook", "inventory": "What you are carrying",
	"quest_log": "What you are doing", "district_map": "Map of the district",
	"quest_arrow": "Toggle quest arrow",
	"hear_again": "Hear that again",
}

# The order the settings screen lists them in. Walking first, because it is
# what somebody who came to this screen is most likely here for.
const ORDER := ["walk_up", "walk_down", "walk_left", "walk_right",
	"interact", "back", "journal", "inventory", "quest_log", "district_map",
	"quest_arrow", "hear_again"]


func _ready() -> void:
	# Before anything can ask about an action, and before any scene is built.
	process_mode = Node.PROCESS_MODE_ALWAYS
	rebuild()


# Wipe and re-lay every action. Called at startup and after any rebinding, so
# there is exactly one path that decides what a button does.
func rebuild() -> void:
	var overrides: Dictionary = SaveManager.settings.get("key_binds", {})
	for action: String in ACTIONS.keys():
		if InputMap.has_action(action):
			InputMap.erase_action(action)
		InputMap.add_action(action, DEADZONE)
		var row: Array = ACTIONS[action]

		# A rebound action keeps its pad buttons and replaces only its keys:
		# somebody remapping E to F is not asking to lose the controller.
		var keys: Array = row[0]
		if overrides.has(action):
			keys = Array(overrides[action])
		for code in keys:
			var k := InputEventKey.new()
			k.physical_keycode = int(code)
			InputMap.action_add_event(action, k)

		for button in Array(row[1]):
			var b := InputEventJoypadButton.new()
			b.button_index = int(button)
			InputMap.action_add_event(action, b)

		for pair in Array(row[2]):
			var m := InputEventJoypadMotion.new()
			m.axis = int(pair[0])
			m.axis_value = float(pair[1])
			InputMap.action_add_event(action, m)


# ── Rebinding ────────────────────────────────────────────────────────────────

# What this action is bound to on a keyboard, as physical keycodes.
func keys_for(action: String) -> Array:
	var overrides: Dictionary = SaveManager.settings.get("key_binds", {})
	if overrides.has(action):
		return Array(overrides[action])
	var row: Array = ACTIONS.get(action, [[], [], []])
	return Array(row[0])


# Readable, for a button in the settings screen. Physical codes are turned back
# into whatever this particular keyboard actually prints on that key.
func label_for(action: String) -> String:
	var out: PackedStringArray = []
	for code in keys_for(action):
		out.append(OS.get_keycode_string(_printed_on_this_keyboard(int(code))))
	if out.is_empty():
		return "unbound"
	return " / ".join(out)


# What this key actually has printed on it, on this machine's layout.
#
# Bindings are stored as PHYSICAL codes so they follow the key's position, but
# a settings screen has to name the key the player is looking at - on AZERTY
# the movement keys are in the same places and are called Z Q S D.
#
# The translation is not available everywhere: the headless display server
# raises "Not supported by this display server", and a dedicated server build
# has no keyboard at all. Falling back to the physical code names the key by
# its US position, which is wrong in a way nobody will be harmed by, and is a
# great deal better than an error every time the settings screen is drawn.
func _printed_on_this_keyboard(physical: int) -> int:
	# By server name rather than by feature flag: there is no
	# FEATURE_KEYBOARD_LAYOUT in 4.7, and asking for one is a parse error that
	# takes the whole autoload down with it - which is how this was found.
	if DisplayServer.get_name() == "headless":
		return physical
	var shown: int = DisplayServer.keyboard_get_keycode_from_physical(physical)
	return shown if shown != 0 else physical


# Give one action one key. Anything else holding that key loses it, because two
# actions on one button is a fault the player cannot see and cannot diagnose.
func rebind(action: String, physical_keycode: int) -> void:
	if not ACTIONS.has(action):
		return
	var overrides: Dictionary = SaveManager.settings.get("key_binds", {})
	for other: String in ACTIONS.keys():
		if other == action:
			continue
		var theirs: Array = keys_for(other).duplicate()
		if theirs.has(physical_keycode):
			theirs.erase(physical_keycode)
			overrides[other] = theirs
	overrides[action] = [physical_keycode]
	SaveManager.settings["key_binds"] = overrides
	SaveManager.save_settings()
	rebuild()


# Back to the table above.
func reset_binds() -> void:
	SaveManager.settings["key_binds"] = {}
	SaveManager.save_settings()
	rebuild()
