extends RefCounted

static func style(color: Color, border: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = border
	box.set_border_width_all(1)
	box.set_corner_radius_all(7)
	box.content_margin_left = 18
	box.content_margin_right = 18
	box.content_margin_top = 13
	box.content_margin_bottom = 13
	return box

static func apply(root: Control) -> void:
	var theme := Theme.new()
	theme.default_font_size = 18
	var body := FontVariation.new()
	body.base_font = load("res://assets/fonts/Manrope.ttf")
	body.variation_opentype = {0x77676874: 550.0}
	theme.default_font = body
	theme.set_color("font_color", "Label", Color("ede9df"))
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var color: Color = {"normal": Color("243e4b"), "hover": Color("365765"), "pressed": Color("496b73"), "disabled": Color("1a2d37"), "focus": Color.TRANSPARENT}[state]
		theme.set_stylebox(state, "Button", style(color, Color("c6ad7a") if state == "focus" else Color("48616c")))
	theme.set_color("font_color", "Button", Color("f0ecd9"))
	theme.set_color("font_disabled_color", "Button", Color("74877a"))
	root.theme = theme
	for button in root.find_children("*", "Button", true, false):
		button.remove_theme_stylebox_override("normal")
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	root.get_node("Background").add_theme_stylebox_override("panel", style(Color("182735")))
	root.get_node("MarginContainer/VBoxContainer/StatsPanel").add_theme_stylebox_override("panel", style(Color("203542"), Color("3d535f")))
	root.get_node("MarginContainer/VBoxContainer/MarketPanel").add_theme_stylebox_override("panel", style(Color("152f28"), Color("304d3d")))
	root.get_node("MarginContainer/VBoxContainer/EventPanel").add_theme_stylebox_override("panel", style(Color("f0eee5"), Color("bfa16a")))
	root.get_node("MarginContainer/VBoxContainer/MarketPanel/MarketLabel").add_theme_color_override("font_color", Color("d4c49a"))
