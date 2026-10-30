extends CanvasLayer

# Developer console. NOT shipped to players.
#
# The gate is OS.is_debug_build(), which is true when you run from the Godot
# editor or export with "Export With Debug" ticked, and FALSE in a normal
# release export. On the first line of _ready() a release build frees this node
# outright — it is not hidden, not disabled, not password-protected: it does
# not exist in the tree, so there is no key to press and no command to type.
#
# Open it with the ` (backtick/tilde) key, or F1. Escape or ` closes it.
#
# Type `help` for the command list.

const KEY_TOGGLE_A := KEY_QUOTELEFT
const KEY_TOGGLE_B := KEY_F1
const MAX_HISTORY := 40

var _root:    Control
var _output:  RichTextLabel
var _input:   LineEdit
var _open:    bool = false
var _was_paused: bool = false
var _history: Array[String] = []
var _hist_i:  int = 0


func _ready() -> void:
	# The whole point. A player's build never gets past this line.
	if not OS.is_debug_build():
		queue_free()
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 200          # above TransitionManager (128) so it survives fades
	_build_ui()
	_print_line("[color=#8ea2c8]Foreign to All — dev console. Debug build only.[/color]")
	_print_line("[color=#66748f]`  or  F1 to toggle  ·  type 'help'[/color]")


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	var panel := ColorRect.new()
	panel.color = Color(0.04, 0.045, 0.07, 0.94)
	panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	panel.offset_bottom = 300.0
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(panel)

	var rule := ColorRect.new()
	rule.color = Color(0.30, 0.86, 0.72, 0.55)
	rule.set_anchors_preset(Control.PRESET_TOP_WIDE)
	rule.offset_top = 300.0
	rule.offset_bottom = 302.0
	_root.add_child(rule)

	_output = RichTextLabel.new()
	_output.bbcode_enabled = true
	_output.scroll_following = true
	_output.set_anchors_preset(Control.PRESET_FULL_RECT)
	_output.offset_left = 12.0
	_output.offset_right = -12.0
	_output.offset_top = 8.0
	_output.offset_bottom = -34.0
	_output.add_theme_font_size_override("normal_font_size", 13)
	panel.add_child(_output)

	_input = LineEdit.new()
	_input.placeholder_text = "money 500   ·   city istanbul   ·   help"
	_input.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_input.offset_left = 8.0
	_input.offset_right = -8.0
	_input.offset_top = -30.0
	_input.offset_bottom = -4.0
	_input.add_theme_font_size_override("font_size", 13)
	_input.text_submitted.connect(_on_submit)
	panel.add_child(_input)

	_root.hide()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var k := event as InputEventKey
	if k.keycode == KEY_TOGGLE_A or k.keycode == KEY_TOGGLE_B:
		_toggle()
		get_viewport().set_input_as_handled()
	elif _open and k.keycode == KEY_ESCAPE:
		_toggle()
		get_viewport().set_input_as_handled()
	elif _open and (k.keycode == KEY_UP or k.keycode == KEY_DOWN):
		_recall(-1 if k.keycode == KEY_UP else 1)
		get_viewport().set_input_as_handled()


func _toggle() -> void:
	_open = not _open
	_root.visible = _open
	if _open:
		# Pause, or the player walks off while you are typing. Remember the
		# previous state — ChoicePanel pauses too, and blindly unpausing on
		# close would resume the game underneath an open choice panel.
		_was_paused = get_tree().paused
		get_tree().paused = true
		_input.clear()
		_input.grab_focus()
	else:
		get_tree().paused = _was_paused
		_input.release_focus()


func _recall(dir: int) -> void:
	if _history.is_empty():
		return
	_hist_i = clampi(_hist_i + dir, 0, _history.size() - 1)
	_input.text = _history[_hist_i]
	_input.caret_column = _input.text.length()


func _print_line(text: String) -> void:
	_output.append_text(text + "\n")


func _ok(text: String) -> void:
	_print_line("[color=#4fd8a8]" + text + "[/color]")


func _err(text: String) -> void:
	_print_line("[color=#f08a80]" + text + "[/color]")


func _on_submit(line: String) -> void:
	_input.clear()
	var raw := line.strip_edges()
	if raw.is_empty():
		return
	_history.append(raw)
	if _history.size() > MAX_HISTORY:
		_history.remove_at(0)
	_hist_i = _history.size()
	_print_line("[color=#8ea2c8]> " + raw + "[/color]")
	var parts := raw.split(" ", false)
	var cmd: String = String(parts[0]).to_lower()
	var args: Array = []
	for i in range(1, parts.size()):
		args.append(String(parts[i]))
	_run(cmd, args)


func _run(cmd: String, args: Array) -> void:
	match cmd:
		"help":   _cmd_help()
		"money":  _cmd_money(args)
		"city":   _cmd_city(args)
		"goto":   _cmd_goto(args)
		"item":   _cmd_item(args)
		"rep":    _cmd_rep(args)
		"flag":   _cmd_flag(args)
		"word":   _cmd_word(args)
		"time":   _cmd_time(args)
		"state":  _cmd_state()
		"clear":  _output.clear()
		_:        _err("unknown command: " + cmd + "   (try 'help')")


func _cmd_help() -> void:
	_print_line("""[color=#c8d2e8]
money <n>              add n to the CURRENT city's wallet
money <CUR> <n>        set a currency outright (EUR GBP TRY)
city <name>            berlin · london · istanbul — switches and flies you there
goto <SceneName>       load any scene in scenes/world (e.g. goto IstanbulHan)
item <id> [n]          add an inventory item
rep <region> <n>       change reputation (kiez mitte terrace highstreet carsi han)
flag <key> [on|off]    set a world flag — 'flag' alone lists the set ones
word <lang> <w> <n>    set word familiarity 0-100 (german english turkish)
time <dawn|morning>    set time of day
state                  dump money, city, flags
clear                  clear this output[/color]""")


func _cmd_money(args: Array) -> void:
	if args.is_empty():
		_err("money <n>   or   money <CUR> <n>")
		return
	if args.size() == 1:
		var n: int = int(String(args[0]))
		GameState.money += n
		GameState.money_changed.emit(GameState.money)
		_ok("%s%d added — wallet now %s%d" % [GameState.symbol(), n,
			GameState.symbol(), GameState.money])
		return
	var cur: String = String(args[0]).to_upper()
	if not GameState.wallet.has(cur):
		_err("no such currency: " + cur + "   (EUR GBP TRY)")
		return
	GameState.wallet[cur] = int(String(args[1]))
	GameState.money_changed.emit(GameState.money)
	_ok("%s set to %d" % [cur, int(String(args[1]))])


func _cmd_city(args: Array) -> void:
	if args.is_empty():
		_err("city <berlin|london|istanbul>")
		return
	var dest: String = String(args[0]).to_lower()
	if not GameState.CITIES.has(dest):
		_err("no such city: " + dest)
		return
	var scene: String = String(GameState.CITY_ENTRIES.get(dest, ""))
	if scene.is_empty() or not ResourceLoader.exists(scene):
		_err("no arrival scene built for " + dest + " yet (" + scene + ")")
		return
	# Bypasses fare, ticket and story gates on purpose — that is the point
	GameState.city = dest
	GameState.world_flags["visited_" + dest] = true
	GameState.money_changed.emit(GameState.money)
	_ok("→ " + GameState.city_name() + "  (" + GameState.currency() + ")")
	_toggle()
	TransitionManager.go(scene)


func _cmd_goto(args: Array) -> void:
	if args.is_empty():
		_err("goto <SceneName>")
		return
	var path := "res://scenes/world/%s.tscn" % String(args[0])
	if not ResourceLoader.exists(path):
		_err("no such scene: " + path)
		return
	_ok("→ " + path)
	_toggle()
	TransitionManager.go(path)


func _cmd_item(args: Array) -> void:
	if args.is_empty():
		_err("item <id> [n]")
		return
	var n: int = 1 if args.size() < 2 else int(String(args[1]))
	GameState.add_item(String(args[0]), n)
	_ok("added %d × %s" % [n, String(args[0])])


func _cmd_rep(args: Array) -> void:
	if args.size() < 2:
		_err("rep <region> <n>")
		return
	GameState.change_reputation(String(args[0]), int(String(args[1])))
	_ok("%s reputation now %d" % [String(args[0]),
		int(GameState.reputation.get(String(args[0]), 0))])


func _cmd_flag(args: Array) -> void:
	if args.is_empty():
		var set_flags: Array = []
		for k in GameState.world_flags.keys():
			if GameState.world_flags[k]:
				set_flags.append(String(k))
		_print_line("flags set: " + (", ".join(set_flags) if set_flags else "(none)"))
		return
	var key: String = String(args[0])
	var val: bool = true
	if args.size() > 1:
		var v: String = String(args[1]).to_lower()
		val = not (v == "off" or v == "false" or v == "0")
	GameState.world_flags[key] = val
	_ok("%s = %s" % [key, str(val)])


func _cmd_word(args: Array) -> void:
	if args.size() < 3:
		_err("word <lang> <word> <0-100>")
		return
	var lang: String = String(args[0]).to_lower()
	var w: String = String(args[1]).to_lower()
	var n: int = clampi(int(String(args[2])), 0, 100)
	if not GameState.familiarity.has(lang):
		GameState.familiarity[lang] = {}
	GameState.familiarity[lang][w] = n
	GameState.word_tier_changed.emit(lang, w, GameState.get_tier(lang, w))
	_ok("%s '%s' = %d (tier %d)" % [lang, w, n, GameState.get_tier(lang, w)])


func _cmd_time(args: Array) -> void:
	if args.is_empty():
		_err("time <dawn|morning>")
		return
	var t: String = String(args[0]).to_lower()
	if t != "dawn" and t != "morning":
		_err("time must be dawn or morning")
		return
	GameState.time_of_day = t
	_ok("time_of_day = " + t + "   (re-enter the scene to redraw)")


func _cmd_state() -> void:
	_print_line("[color=#c8d2e8]city      %s (%s)\nwallet    %s\nregion    %s\nitems     %s[/color]" % [
		GameState.city_name(), GameState.currency(),
		str(GameState.wallet),
		GameState.current_region,
		str(GameState.inventory),
	])
