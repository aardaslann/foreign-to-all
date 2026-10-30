extends Node

var reading_font: Font

func _ready() -> void:
	# The game's local-language phrases must render even when the UI is English.
	var font := ThemeDB.fallback_font.duplicate() as Font
	# Korean and Georgian ship too (Seoul, Tbilisi); without them here those
	# scripts depend on whatever fonts the player's system happens to have.
	font.fallbacks = [preload("res://art/fonts/NotoSansJP.ttf"),
		preload("res://art/fonts/NotoSansDevanagari.ttf"),
		preload("res://art/fonts/NotoSansKR.ttf"),
		preload("res://art/fonts/NotoSansGeorgian.ttf")]
	reading_font = font

# ── Text-only title buttons (inspired by Hollow Knight) ──────────────────────
# No box or background — just styled text that gains ornament marks on hover.

func style_title_btn(btn: Button, font_size: int = 22) -> void:
	# Transparent StyleBoxFlat gives us content padding without any visible box
	for state in ["normal", "hover", "pressed", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color          = Color(0, 0, 0, 0)
		sb.border_width_top  = 0; sb.border_width_bottom = 0
		sb.border_width_left = 0; sb.border_width_right  = 0
		sb.content_margin_left   = 28.0
		sb.content_margin_right  = 28.0
		sb.content_margin_top    = 11.0
		sb.content_margin_bottom = 11.0
		btn.add_theme_stylebox_override(state, sb)

	btn.add_theme_color_override("font_color",         Color(0.78, 0.76, 0.98, 0.76))
	btn.add_theme_color_override("font_hover_color",   Color(1.00, 1.00, 1.00, 1.00))
	btn.add_theme_color_override("font_pressed_color", Color(0.74, 0.72, 0.94, 0.95))
	btn.add_theme_color_override("font_focus_color",   Color(0.82, 0.80, 1.00, 0.85))
	btn.add_theme_font_size_override("font_size", font_size)

	# Wing ornaments that appear on hover — core of the Hollow Knight look
	var base := btn.text
	btn.mouse_entered.connect(func(): btn.text = "◈   " + base + "   ◈")
	btn.mouse_exited.connect(func():  btn.text = base)


# ── Rounded buttons (menus, dialogs) ─────────────────────────────────────────

func style_menu_btn(btn: Button) -> void:
	btn.add_theme_stylebox_override("normal",  _rounded(Color(0.17, 0.15, 0.35, 0.92), Color(0.42, 0.40, 0.65, 0.45)))
	btn.add_theme_stylebox_override("hover",   _rounded(Color(0.28, 0.26, 0.52, 0.96), Color(0.62, 0.58, 0.88, 0.75)))
	btn.add_theme_stylebox_override("pressed", _rounded(Color(0.11, 0.09, 0.24, 0.96), Color(0.36, 0.32, 0.58, 0.50)))
	btn.add_theme_stylebox_override("focus",   _rounded(Color(0.17, 0.15, 0.35, 0.92), Color(0.62, 0.58, 0.88, 0.75)))
	_font(btn, Color(0.88, 0.86, 1.00), Color(1.00, 1.00, 1.00), 16)


# ── Danger / secondary (delete, quit) ────────────────────────────────────────

func style_danger_btn(btn: Button) -> void:
	btn.add_theme_stylebox_override("normal",  _rounded(Color(0.30, 0.10, 0.14, 0.88), Color(0.65, 0.28, 0.34, 0.50)))
	btn.add_theme_stylebox_override("hover",   _rounded(Color(0.46, 0.16, 0.20, 0.96), Color(0.80, 0.36, 0.40, 0.80)))
	btn.add_theme_stylebox_override("pressed", _rounded(Color(0.22, 0.07, 0.10, 0.96), Color(0.55, 0.22, 0.28, 0.50)))
	btn.add_theme_stylebox_override("focus",   _rounded(Color(0.30, 0.10, 0.14, 0.88), Color(0.80, 0.36, 0.40, 0.75)))
	_font(btn, Color(1.00, 0.82, 0.84), Color(1.00, 0.90, 0.92), 16)


# ── Helpers ───────────────────────────────────────────────────────────────────

func _pill(bg: Color, border: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(28)
	sb.border_width_top    = 1
	sb.border_width_bottom = 1
	sb.border_width_left   = 1
	sb.border_width_right  = 1
	sb.border_color = border
	sb.shadow_color  = Color(0.06, 0.03, 0.18, 0.55)
	sb.shadow_size   = 8
	sb.shadow_offset = Vector2(0, 3)
	sb.anti_aliasing      = true
	sb.anti_aliasing_size = 1.2
	sb.content_margin_left   = 28.0
	sb.content_margin_right  = 28.0
	sb.content_margin_top    = 12.0
	sb.content_margin_bottom = 12.0
	return sb


func _rounded(bg: Color, border: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(8)
	sb.border_width_top    = 1
	sb.border_width_bottom = 1
	sb.border_width_left   = 1
	sb.border_width_right  = 1
	sb.border_color = border
	sb.shadow_color  = Color(0.04, 0.02, 0.14, 0.50)
	sb.shadow_size   = 5
	sb.shadow_offset = Vector2(0, 2)
	sb.anti_aliasing      = true
	sb.anti_aliasing_size = 1.0
	sb.content_margin_left   = 18.0
	sb.content_margin_right  = 18.0
	sb.content_margin_top    = 8.0
	sb.content_margin_bottom = 8.0
	return sb


func _font(btn: Button, normal_col: Color, hover_col: Color, size: int) -> void:
	btn.add_theme_color_override("font_color",        normal_col)
	btn.add_theme_color_override("font_hover_color",  hover_col)
	btn.add_theme_color_override("font_pressed_color", hover_col)
	btn.add_theme_color_override("font_focus_color",  normal_col)
	btn.add_theme_font_size_override("font_size", size)
