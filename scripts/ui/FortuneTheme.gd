extends RefCounted
static var surfaces:Dictionary= {}
static func panel(color: Color, edge: Color = Color("61717a")) -> StyleBoxFlat:
	var box:StyleBoxFlat= StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = edge
	box.set_border_width_all(1)
	box.set_corner_radius_all(8)
	box.content_margin_left = 16
	box.content_margin_right = 16
	box.content_margin_top = 8
	box.content_margin_bottom = 8
	return box

static func style(color: Color, border: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	return panel(color,border)

static func surface(state: String) -> StyleBoxTexture:
	if surfaces.has(state): return surfaces[state]
	var box:StyleBoxTexture= StyleBoxTexture.new()
	box.texture = load("res://assets/ui/button-"+state+".svg")
	box.set_texture_margin_all(12)
	box.content_margin_left = 24
	box.content_margin_right = 24
	box.content_margin_top = 12
	box.content_margin_bottom = 12
	surfaces[state] = box
	return box

static func create() -> Theme:
	var theme:Theme= Theme.new()
	theme.default_font_size = 19
	var body:FontVariation= FontVariation.new()
	body.base_font = load("res://assets/fonts/Onest.ttf")
	body.variation_opentype = {0x77676874:500.0}
	theme.default_font = body
	for type:String in ["Label","RichTextLabel"]: theme.set_color("font_color",type,Color("dce3e9"))
	for type:String in ["PanelContainer","Panel"]: theme.set_stylebox("panel",type,panel(Color("1c2932")))
	for type:String in ["Button","OptionButton","CheckBox"]:
		theme.set_font_size("font_size",type,20)
		for state:String in ["normal","hover","pressed","disabled"]: theme.set_stylebox(state,type,surface(state))
		var focus:StyleBoxFlat= panel(Color.TRANSPARENT,Color("d3b78b"))
		focus.set_border_width_all(2)
		theme.set_stylebox("focus",type,focus)
		theme.set_color("font_color",type,Color("e7e9e9"))
		theme.set_color("font_hover_color",type,Color.WHITE)
		theme.set_color("font_pressed_color",type,Color("efe1ce"))
		theme.set_color("font_disabled_color",type,Color("91a0a7"))
	for type:String in ["ItemList","Tree","PopupMenu","TabContainer"]:
		theme.set_stylebox("panel",type,panel(Color("1c2932")))
		theme.set_color("font_color",type,Color("e7e9e9"))
	theme.set_stylebox("background","ProgressBar",panel(Color("1c252d")))
	theme.set_stylebox("fill","ProgressBar",panel(Color("8d5d60"),Color("bd8a87")))
	theme.set_color("font_color","ProgressBar",Color("e7e9e9"))
	return theme

static func apply(root: Control) -> void:
	root.theme = create()
	for button:Button in root.find_children("*","Button",true,false):
		button.remove_theme_font_size_override("font_size")
		for state:String in ["normal","hover","pressed","disabled","focus"]: button.remove_theme_stylebox_override(state)
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	(root.get_node("Background") as Control).add_theme_stylebox_override("panel",style(Color("111e2e")))
	(root.get_node("MarginContainer/VBoxContainer/StatsPanel") as Control).add_theme_stylebox_override("panel",style(Color("21374c"),Color("52687c")))
	(root.get_node("MarginContainer/VBoxContainer/MarketPanel") as Control).add_theme_stylebox_override("panel",style(Color("1c3042"),Color("486175")))
	(root.get_node("MarginContainer/VBoxContainer/EventPanel") as Control).add_theme_stylebox_override("panel",style(Color("e6e9eb"),Color("a5b4bf")))
	(root.get_node("MarginContainer/VBoxContainer/MarketPanel/MarketLabel") as Control).add_theme_color_override("font_color",Color("9faebd"))
