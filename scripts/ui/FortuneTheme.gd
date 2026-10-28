extends RefCounted
## Restrained private-bank palette: near-black ink, deep slate surfaces, a single
## champagne accent and thin rules instead of heavy fills. Gold marks value, never
## decoration.
const INK_BG:Color= Color("0a0f16")
const SURFACE:Color= Color("111a25")
const SURFACE_RAISED:Color= Color("16212e")
const SURFACE_DEEP:Color= Color("0d151f")
const RULE:Color= Color("26313f")
const RULE_SOFT:Color= Color("1d2733")
const IVORY:Color= Color("ede7da")
const MUTED:Color= Color("8a97a6")
const GOLD:Color= Color("c8a96a")
const GOLD_DEEP:Color= Color("a98b4f")
const ALERT:Color= Color("c9736a")

static var surfaces:Dictionary= {}

static func panel(color: Color, edge: Color = Color("26313f"), radius: int = 6) -> StyleBoxFlat:
	var box:StyleBoxFlat= StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = edge
	box.set_border_width_all(1)
	box.set_corner_radius_all(radius)
	box.content_margin_left = 18
	box.content_margin_right = 18
	box.content_margin_top = 10
	box.content_margin_bottom = 10
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
	body.variation_opentype = {0x77676874:400.0}
	theme.default_font = body
	for type:String in ["Label","RichTextLabel"]: theme.set_color("font_color",type,IVORY)
	for type:String in ["PanelContainer","Panel"]: theme.set_stylebox("panel",type,panel(SURFACE))
	for type:String in ["Button","OptionButton","CheckBox"]:
		theme.set_font_size("font_size",type,20)
		for state:String in ["normal","hover","pressed","disabled"]: theme.set_stylebox(state,type,surface(state))
		var focus:StyleBoxFlat= panel(Color.TRANSPARENT,GOLD)
		focus.set_border_width_all(2)
		theme.set_stylebox("focus",type,focus)
		theme.set_color("font_color",type,IVORY)
		theme.set_color("font_hover_color",type,Color.WHITE)
		theme.set_color("font_pressed_color",type,GOLD)
		theme.set_color("font_disabled_color",type,MUTED)
	for type:String in ["ItemList","Tree","PopupMenu","TabContainer"]:
		theme.set_stylebox("panel",type,panel(SURFACE_RAISED))
		theme.set_color("font_color",type,IVORY)
	theme.set_stylebox("background","ProgressBar",panel(SURFACE_DEEP))
	theme.set_stylebox("fill","ProgressBar",panel(GOLD_DEEP,GOLD))
	theme.set_color("font_color","ProgressBar",IVORY)
	return theme

static func apply(root: Control) -> void:
	root.theme = create()
	for button:Button in root.find_children("*","Button",true,false):
		button.remove_theme_font_size_override("font_size")
		for state:String in ["normal","hover","pressed","disabled","focus"]: button.remove_theme_stylebox_override(state)
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	(root.get_node("Background") as Control).add_theme_stylebox_override("panel",style(INK_BG))
	(root.get_node("MarginContainer/VBoxContainer/StatsPanel") as Control).add_theme_stylebox_override("panel",style(SURFACE,RULE))
	(root.get_node("MarginContainer/VBoxContainer/MarketPanel") as Control).add_theme_stylebox_override("panel",style(SURFACE,RULE_SOFT))
	(root.get_node("MarginContainer/VBoxContainer/EventPanel") as Control).add_theme_stylebox_override("panel",style(SURFACE_DEEP,RULE))
	(root.get_node("MarginContainer/VBoxContainer/MarketPanel/MarketLabel") as Control).add_theme_color_override("font_color",MUTED)
