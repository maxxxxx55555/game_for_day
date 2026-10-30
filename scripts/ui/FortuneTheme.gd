extends RefCounted
## Builds the Theme for whichever skin is active. Every colour resolves through
## Palette, so switching skins only needs apply() to run again.
const Palette=preload("res://scripts/ui/Palette.gd")
static var surfaces:Dictionary= {}
static var display_fonts:Dictionary= {}

static func panel(color: Color, edge: Color = Color.TRANSPARENT, radius: int = 6) -> StyleBoxFlat:
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

static func display_font(weight: int = 600) -> FontVariation:
	if display_fonts.has(weight):
		return display_fonts[weight]
	var font:FontVariation= FontVariation.new()
	font.base_font = load("res://assets/fonts/Unbounded.ttf")
	font.variation_opentype = {0x77676874: float(weight)}
	display_fonts[weight] = font
	return font

static func surface(state: String) -> StyleBoxTexture:
	var key:String= state + Palette.button_variant()
	if surfaces.has(key): return surfaces[key]
	var box:StyleBoxTexture= StyleBoxTexture.new()
	box.texture = load("res://assets/ui/button-"+state+Palette.button_variant()+".svg")
	box.set_texture_margin_all(12)
	box.content_margin_left = 24
	box.content_margin_right = 24
	box.content_margin_top = 12
	box.content_margin_bottom = 12
	surfaces[key] = box
	return box

static func create() -> Theme:
	var theme:Theme= Theme.new()
	theme.default_font_size = 19
	var body:FontVariation= FontVariation.new()
	body.base_font = load("res://assets/fonts/Onest.ttf")
	body.variation_opentype = {0x77676874:400.0}
	theme.default_font = body
	for type:String in ["Label","RichTextLabel"]: theme.set_color("font_color",type,Palette.text())
	for type:String in ["PanelContainer","Panel"]: theme.set_stylebox("panel",type,panel(Palette.surface(),Palette.rule()))
	for type:String in ["Button","OptionButton","CheckBox"]:
		theme.set_font_size("font_size",type,20)
		for state:String in ["normal","hover","pressed","disabled"]: theme.set_stylebox(state,type,surface(state))
		var focus:StyleBoxFlat= panel(Color.TRANSPARENT,Palette.accent())
		focus.set_border_width_all(2)
		theme.set_stylebox("focus",type,focus)
		theme.set_color("font_color",type,Palette.text())
		theme.set_color("font_hover_color",type,Palette.text())
		theme.set_color("font_pressed_color",type,Palette.accent())
		theme.set_color("font_disabled_color",type,Palette.muted())
		theme.set_color("icon_normal_color",type,Palette.accent())
		theme.set_color("icon_hover_color",type,Palette.accent())
		theme.set_color("icon_pressed_color",type,Palette.accent_deep())
		theme.set_color("icon_disabled_color",type,Palette.muted())
	for type:String in ["ItemList","Tree","PopupMenu","TabContainer"]:
		theme.set_stylebox("panel",type,panel(Palette.raised(),Palette.rule()))
		theme.set_color("font_color",type,Palette.text())
	# Thin bronze sliders instead of the engine's heavy default groove.
	var groove:StyleBoxFlat= panel(Palette.track())
	groove.set_corner_radius_all(3)
	groove.content_margin_top = 2
	groove.content_margin_bottom = 2
	groove.content_margin_left = 0
	groove.content_margin_right = 0
	var filled:StyleBoxFlat= panel(Palette.accent())
	filled.set_corner_radius_all(3)
	filled.content_margin_top = 2
	filled.content_margin_bottom = 2
	filled.content_margin_left = 0
	filled.content_margin_right = 0
	for type:String in ["HSlider","VSlider"]:
		theme.set_stylebox("slider",type,groove)
		theme.set_stylebox("grabber_area",type,filled)
		theme.set_stylebox("grabber_area_highlight",type,filled)
	var suffix:String= Palette.button_variant()
	theme.set_icon("checked","CheckBox",load("res://assets/ui/check-on"+suffix+".svg") as Texture2D)
	theme.set_icon("unchecked","CheckBox",load("res://assets/ui/check-off"+suffix+".svg") as Texture2D)
	theme.set_icon("checked","CheckButton",load("res://assets/ui/check-on"+suffix+".svg") as Texture2D)
	theme.set_icon("unchecked","CheckButton",load("res://assets/ui/check-off"+suffix+".svg") as Texture2D)
	theme.set_stylebox("background","ProgressBar",panel(Palette.deep()))
	theme.set_stylebox("fill","ProgressBar",panel(Palette.accent_deep(),Palette.accent()))
	theme.set_color("font_color","ProgressBar",Palette.text())
	return theme

static func apply(root: Control) -> void:
	root.theme = create()
	for button:Button in root.find_children("*","Button",true,false):
		# Font sizes stay with the screen that chose them: the bottom bar and the choice
		# cards depend on their overrides, and clearing them here widens the layout past
		# narrow viewports and prints the raw choice text over the card.
		for state:String in ["normal","hover","pressed","disabled","focus"]: button.remove_theme_stylebox_override(state)
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	(root.get_node("Background") as Control).add_theme_stylebox_override("panel",style(Palette.ink()))
	(root.get_node("MarginContainer/VBoxContainer/StatsPanel") as Control).add_theme_stylebox_override("panel",style(Palette.surface(),Palette.rule()))
	(root.get_node("MarginContainer/VBoxContainer/MarketPanel") as Control).add_theme_stylebox_override("panel",style(Palette.surface(),Palette.rule_soft()))
	(root.get_node("MarginContainer/VBoxContainer/EventPanel") as Control).add_theme_stylebox_override("panel",style(Palette.deep(),Palette.rule()))
	(root.get_node("MarginContainer/VBoxContainer/MarketPanel/MarketLabel") as Control).add_theme_color_override("font_color",Palette.muted())
