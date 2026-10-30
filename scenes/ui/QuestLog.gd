extends CanvasLayer

# Quest ("Intentions") system UI:
#  - an overlay page (Q key / HUD button) listing every quest and its steps
#  - a compact tracker panel top-left showing the current quest live;
#    steps flip to ✓ the moment they complete, and the panel lingers a few
#    seconds after the quest finishes, then fades out.

const BG_COLOR := Color(0.055, 0.048, 0.118, 0.98)
const BDR_CLR  := Color(0.30, 0.28, 0.50, 0.55)

const CLR_TITLE := Color(0.92, 0.90, 1.00)
const CLR_DONE  := Color(0.30, 0.86, 0.64)
const CLR_PEND  := Color(0.66, 0.63, 0.90, 0.85)

const LINGER      := 6.0   # seconds the tracker stays after a quest completes
const BANNER_LIFE := 3.2   # seconds the "new intention" banner is on screen

var _ui_root:     Control
var _panel_root:  Control
var _quest_list:  VBoxContainer
var _tracker:     PanelContainer
var _tracker_box: VBoxContainer
var _arrow_hint: Label
var _active_intention := false

var _banner:       PanelContainer
var _banner_title: Label
var _banner_t:     float = -1.0   # -1 = inactive

var _fade_t:         float      = -1.0   # >0 while lingering after completion
var _last_completed: String     = ""
var _has_content:    bool       = false
var _tracker_hold:   float      = 0.0    # tracker hidden while the banner plays
var _seen:           Dictionary = {}     # quest ids already announced


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("quest_log")
	_ui_root = $UIRoot
	_build_overlay()
	_build_tracker()
	_build_banner()
	# Quests loaded from a save were announced long ago — no banner for those
	for qid: String in GameState.quests:
		_seen[qid] = true
	GameState.quest_updated.connect(_on_quest_updated)
	# The day arrives as a banner, the same one a new intention uses, because
	# it IS one: somebody has invited you to something and you now have
	# somewhere to be.
	Story.holiday_opened.connect(_on_holiday)
	_refresh_tracker()


func _process(delta: float) -> void:
	_tracker.position = Vector2(14, 80)
	if _fade_t > 0.0:
		_fade_t -= delta
		_tracker.modulate.a = clampf(_fade_t / 0.7, 0.0, 1.0)
		if _fade_t <= 0.0:
			_has_content = false
	if _tracker_hold > 0.0:
		_tracker_hold -= delta
	_tracker.visible = _has_content and _tracker_hold <= 0.0 and not get_tree().paused
	_arrow_hint.visible = _tracker.visible and _active_intention and GameState.clock_can_run()
	if _arrow_hint.visible:
		_arrow_hint.position = Vector2(_tracker.position.x + 4.0, _tracker.get_rect().end.y + 6.0)
		_arrow_hint.size.x = _tracker.size.x - 8.0
		_arrow_hint.text = _arrow_hint_text()

	if _banner_t >= 0.0:
		var dialogue := get_tree().get_first_node_in_group("dialogue_box")
		var director := get_tree().get_first_node_in_group("story_director")
		if get_tree().paused or (dialogue != null and dialogue.visible) or (director != null and director.running()):
			_banner.hide()
			return
		_banner.show()
		_banner_t += delta
		var a := 1.0
		if _banner_t < 0.35:
			a = _banner_t / 0.35
		elif _banner_t > BANNER_LIFE - 0.5:
			a = maxf(0.0, (BANNER_LIFE - _banner_t) / 0.5)
		_banner.modulate.a = a
		var rise := 1.0 - minf(1.0, _banner_t / 0.35)
		_banner.position = Vector2(
			(_ui_root.size.x - _banner.size.x) * 0.5, 84.0 + rise * 14.0)
		if _banner_t >= BANNER_LIFE:
			_banner_t = -1.0
			_banner.hide()


func open_from_hud() -> void:
	if not _panel_root.visible and not get_tree().paused:
		_open()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("quest_log"):
		get_viewport().set_input_as_handled()
		if _panel_root.visible:
			_close()
		elif not get_tree().paused:
			_open()
	elif event.is_action_pressed("back") and _panel_root.visible:
		get_viewport().set_input_as_handled()
		_close()


func _open() -> void:
	_populate()
	_panel_root.show()
	get_tree().paused = true


func _close() -> void:
	_panel_root.hide()
	get_tree().paused = false


func _on_quest_updated(id: String) -> void:
	var q: Dictionary = GameState.quests.get(id, {})
	if q.is_empty():
		return
	# Announce quests we haven't seen before, and hold the tracker back
	# until the banner has had its moment
	if not _seen.has(id):
		_seen[id] = true
		if not bool(q["completed"]):
			_show_banner(String(q["title"]))
			_tracker_hold = BANNER_LIFE - 0.4
	if bool(q["completed"]):
		_last_completed = id
		_fade_t = LINGER
	_refresh_tracker()


# Which day it is, and its name. The player should never have to work out
# that the city looks different because of something they did last week.
func _on_holiday(city: String) -> void:
	var p: Dictionary = Story.person(city)
	if p.is_empty():
		return
	# The quest itself belongs to the thread in Story, which knows where
	# everybody stands; this only has to put it on screen.
	Story.guide()
	_show_banner("%s — %s" % [String(p.get("holiday", "")),
		String(p.get("when", ""))])




func _show_banner(quest_title: String) -> void:
	_banner_title.text = quest_title
	_banner.modulate.a = 0.0
	_banner.show()
	_banner_t = 0.0


func _build_banner() -> void:
	_banner = PanelContainer.new()
	_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color     = Color(0.060, 0.052, 0.130, 0.94)
	sb.border_color = Color(0.55, 0.50, 0.88, 0.60)
	sb.border_width_left = 1; sb.border_width_right  = 1
	sb.border_width_top  = 1; sb.border_width_bottom = 1
	sb.set_corner_radius_all(12)
	sb.shadow_color = Color(0, 0, 0, 0.50)
	sb.shadow_size  = 14
	sb.content_margin_left  = 34.0
	sb.content_margin_right = 34.0
	sb.content_margin_top    = 14.0
	sb.content_margin_bottom = 14.0
	_banner.add_theme_stylebox_override("panel", sb)

	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override("separation", 4)
	_banner.add_child(col)

	var head := Label.new()
	head.text = "✦   n e w   i n t e n t i o n   ✦"
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.add_theme_font_size_override("font_size", 12)
	head.add_theme_color_override("font_color", Color(0.58, 0.54, 0.90, 0.85))
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(head)

	_banner_title = Label.new()
	_banner_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner_title.add_theme_font_size_override("font_size", 19)
	_banner_title.add_theme_color_override("font_color", Color(0.96, 0.94, 1.00))
	_banner_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_banner_title)

	_banner.hide()
	_ui_root.add_child(_banner)


# ── Tracker (top-left, always on) ─────────────────────────────────────────────

func _build_tracker() -> void:
	_tracker = PanelContainer.new()
	_tracker.add_to_group("quest_tracker")
	_tracker.custom_minimum_size = Vector2(292, 0)
	_tracker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color     = Color(0.050, 0.044, 0.110, 0.86)
	sb.border_color = Color(0.32, 0.30, 0.54, 0.40)
	sb.border_width_left = 1; sb.border_width_right  = 1
	sb.border_width_top  = 1; sb.border_width_bottom = 1
	sb.set_corner_radius_all(10)
	sb.content_margin_left  = 14.0
	sb.content_margin_right = 14.0
	sb.content_margin_top    = 10.0
	sb.content_margin_bottom = 10.0
	_tracker.add_theme_stylebox_override("panel", sb)

	_tracker_box = VBoxContainer.new()
	_tracker_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tracker_box.add_theme_constant_override("separation", 4)
	_tracker.add_child(_tracker_box)

	_tracker.hide()
	_ui_root.add_child(_tracker)
	_arrow_hint = Label.new()
	_arrow_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_arrow_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_arrow_hint.add_theme_font_size_override("font_size", 14)
	_arrow_hint.add_theme_color_override("font_color", Color(0.94, 0.90, 0.96))
	_arrow_hint.add_theme_color_override("font_outline_color", Color(0.08, 0.05, 0.11))
	_arrow_hint.add_theme_constant_override("outline_size", 4)
	_arrow_hint.hide()
	_ui_root.add_child(_arrow_hint)


func _arrow_hint_text() -> String:
	var binding := Controls.label_for("quest_arrow")
	if not Input.get_connected_joypads().is_empty():
		binding = "Right stick" if binding == "unbound" else binding + " / Right stick"
	var state := "OFF"
	if bool(SaveManager.settings.get("quest_arrow", false)):
		state = "ON"
		var target := GameState.quest_target()
		var current := get_tree().current_scene
		if target.is_empty(): state += " (no route)"
		elif current != null and current.scene_file_path == target: state += " (here)"
	return "%s - Quest arrow: %s" % [binding, state]


func _refresh_tracker() -> void:
	# Detach immediately — queue_free alone leaves the old rows in the layout
	# until end of frame, which balloons the panel's size (and containers
	# never shrink back on their own)
	for child in _tracker_box.get_children():
		_tracker_box.remove_child(child)
		child.queue_free()

	# Show the first unfinished quest; if none, linger on the last completed one
	var show_id: String = GameState.tracked_quest_id()
	var q: Dictionary = Services.arrival_guidance()
	if show_id == "" and q.is_empty():
		if _fade_t > 0.0 and GameState.quests.has(_last_completed):
			show_id = _last_completed
		else:
			_has_content = false
			return

	if q.is_empty(): q = GameState.quests[show_id]
	var done: bool = q["completed"]
	_active_intention = not done
	if not done:
		_fade_t = -1.0
		_tracker.modulate.a = 1.0

	var title := Label.new()
	title.text = ("◈  " + String(q["title"]).to_upper()) + ("   —  done" if done else "")
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.custom_minimum_size.x = 262
	title.add_theme_font_size_override("font_size", 13)
	title.add_theme_color_override("font_color", CLR_DONE if done else CLR_TITLE)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tracker_box.add_child(title)

	# The corner carries the next intention, not a six-step checklist. The
	# full sequence and earlier steps remain on the Q page.
	var current_steps: Array = []
	for step: Dictionary in q["steps"]:
		if not step["done"]:
			current_steps.append(step)
			break
	if done and not q["steps"].is_empty(): current_steps.append(q["steps"].back())
	for s: Dictionary in current_steps:
		var step_done: bool = s["done"]
		var lbl := Label.new()
		lbl.text = ("✓  " if step_done else "○  ") + String(s["text"])
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.custom_minimum_size = Vector2(262, 0)
		lbl.add_theme_font_size_override("font_size", [14, 16, 18][clampi(int(SaveManager.settings.get("text_size", 1)), 0, 2)])
		lbl.add_theme_color_override("font_color", CLR_DONE if step_done else CLR_PEND)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_tracker_box.add_child(lbl)

	_has_content = true
	# Snap the panel back down to fit its new content
	_tracker.call_deferred("reset_size")


# ── Overlay page ──────────────────────────────────────────────────────────────

func _build_overlay() -> void:
	_panel_root = Control.new()
	_panel_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_root.add_child(_panel_root)

	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.52)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel_root.add_child(overlay)

	var panel := Panel.new()
	panel.anchor_left = 0.20; panel.anchor_right  = 0.80
	panel.anchor_top  = 0.10; panel.anchor_bottom = 0.90
	var sb := StyleBoxFlat.new()
	sb.bg_color     = BG_COLOR
	sb.border_color = BDR_CLR
	sb.border_width_left = 1; sb.border_width_right  = 1
	sb.border_width_top  = 1; sb.border_width_bottom = 1
	sb.set_corner_radius_all(16)
	sb.shadow_color = Color(0, 0, 0, 0.50)
	sb.shadow_size  = 20
	panel.add_theme_stylebox_override("panel", sb)
	_panel_root.add_child(panel)

	var outer := MarginContainer.new()
	outer.set_anchors_preset(Control.PRESET_FULL_RECT)
	var margins := {"left": 42, "right": 42, "top": 32, "bottom": 28}
	for k: String in margins:
		outer.add_theme_constant_override("margin_" + k, margins[k])
	panel.add_child(outer)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	outer.add_child(vbox)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	var title := Label.new()
	title.text = tr("q.title")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(0.96, 0.94, 1.00))
	header.add_child(title)
	var close_btn := Button.new()
	close_btn.text = "×  close"
	close_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	UIStyles.style_menu_btn(close_btn)
	close_btn.pressed.connect(_close)
	header.add_child(close_btn)
	vbox.add_child(header)

	var sub := Label.new()
	sub.text = tr("q.sub")
	sub.add_theme_font_size_override("font_size", 14)
	sub.add_theme_color_override("font_color", Color(0.44, 0.42, 0.68, 0.78))
	vbox.add_child(sub)

	var div_margin := MarginContainer.new()
	div_margin.add_theme_constant_override("margin_top", 8)
	div_margin.add_theme_constant_override("margin_bottom", 6)
	var line := ColorRect.new()
	line.color = Color(0.28, 0.26, 0.46, 0.40)
	line.custom_minimum_size = Vector2(0, 1)
	div_margin.add_child(line)
	vbox.add_child(div_margin)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_quest_list = VBoxContainer.new()
	_quest_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_quest_list.add_theme_constant_override("separation", 8)
	scroll.add_child(_quest_list)
	vbox.add_child(scroll)

	var foot_margin := MarginContainer.new()
	foot_margin.add_theme_constant_override("margin_top", 8)
	var foot := Label.new()
	foot.text = "Q  ·  Esc — " + tr("q.close")
	foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	foot.add_theme_font_size_override("font_size", 12)
	foot.add_theme_color_override("font_color", Color(0.36, 0.34, 0.58, 0.55))
	foot_margin.add_child(foot)
	vbox.add_child(foot_margin)

	_panel_root.hide()


func _populate() -> void:
	for child in _quest_list.get_children():
		child.queue_free()

	var arrival: Dictionary = Services.arrival_guidance()
	if not arrival.is_empty(): _quest_list.add_child(_quest_row(arrival))
	if GameState.quests.is_empty() and arrival.is_empty():
		var lbl := Label.new()
		lbl.text = tr("q.empty")
		lbl.add_theme_font_size_override("font_size", 15)
		lbl.add_theme_color_override("font_color", Color(0.44, 0.42, 0.68, 0.65))
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_quest_list.add_child(lbl)
		return

	# Active quests first, completed after
	for pass_done in [false, true]:
		for qid: String in GameState.quests:
			var q: Dictionary = GameState.quests[qid]
			if bool(q["completed"]) == pass_done:
				_quest_list.add_child(_quest_row(q))


func _quest_row(q: Dictionary) -> Control:
	var done: bool = q["completed"]
	var tc := CLR_DONE if done else Color(0.55, 0.52, 0.88)

	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color     = Color(tc.r * 0.13, tc.g * 0.13, tc.b * 0.13, 0.82)
	sb.border_color = Color(tc.r, tc.g, tc.b, 0.22)
	sb.border_width_left = 1; sb.border_width_right  = 1
	sb.border_width_top  = 1; sb.border_width_bottom = 1
	sb.set_corner_radius_all(8)
	sb.content_margin_left  = 18.0
	sb.content_margin_right = 18.0
	sb.content_margin_top    = 12.0
	sb.content_margin_bottom = 12.0
	panel.add_theme_stylebox_override("panel", sb)
	if done:
		panel.modulate.a = 0.65

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	panel.add_child(col)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	var title := Label.new()
	title.text = q["title"]
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", CLR_TITLE)
	head.add_child(title)
	if done:
		var tag := Label.new()
		tag.text = "✓ done"
		tag.add_theme_font_size_override("font_size", 13)
		tag.add_theme_color_override("font_color", CLR_DONE)
		head.add_child(tag)
	col.add_child(head)

	for s: Dictionary in q["steps"]:
		var step_done: bool = s["done"]
		var lbl := Label.new()
		lbl.text = ("✓  " if step_done else "○  ") + String(s["text"])
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.add_theme_font_size_override("font_size", [18, 22, 26][clampi(int(SaveManager.settings.get("text_size", 1)), 0, 2)])
		lbl.add_theme_color_override("font_color", CLR_DONE if step_done else CLR_PEND)
		col.add_child(lbl)

	return panel
