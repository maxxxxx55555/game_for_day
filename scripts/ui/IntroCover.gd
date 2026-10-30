extends Control
## Cover plate for the opening screen: the painting, a smooth scrim, and a title
## lockup anchored to the lower left. Reads like a book jacket rather than a menu.
const Palette=preload("res://scripts/ui/Palette.gd")
const display_font:Font= preload("res://assets/fonts/Prata-Regular.ttf")
## The scrim stays dark in both skins: a cover is a photograph, not a panel.
const SCRIM:Color= Color("0a0f16")
const COVER_INK:Color= Color("f4efe4")
const COVER_ACCENT:Color= Color("d8b878")
var texture:Texture2D
var scrim:GradientTexture2D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size.y = 300
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	var gradient:Gradient= Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0,0.34,0.52,0.78,1.0])
	gradient.colors = PackedColorArray([
		Color(SCRIM.r,SCRIM.g,SCRIM.b,0.35),
		Color(SCRIM.r,SCRIM.g,SCRIM.b,0.0),
		Color(SCRIM.r,SCRIM.g,SCRIM.b,0.42),
		Color(SCRIM.r,SCRIM.g,SCRIM.b,0.86),
		Color(SCRIM.r,SCRIM.g,SCRIM.b,0.97)])
	scrim = GradientTexture2D.new()
	scrim.gradient = gradient
	scrim.width = 8
	scrim.height = 256
	scrim.fill_from = Vector2(0.0,0.0)
	scrim.fill_to = Vector2(0.0,1.0)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	resized.connect(queue_redraw)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	GameManager.theme_changed.connect(func(_mode:String)->void:queue_redraw())
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	LocalizationManager.language_changed.connect(func(_language:Variant)->void:queue_redraw())

func tracked(text:String) -> String:
	var letters:String=""
	for i:int in text.length():
		if i > 0:
			letters += " "
		letters += text.substr(i,1)
	return letters

func _draw() -> void:
	if texture == null: return
	var w:float = size.x
	var h:float = size.y
	var tex_size:Vector2 = texture.get_size()
	var cover:float = maxf(w / tex_size.x, h / tex_size.y)
	var drawn:Vector2 = tex_size * cover
	draw_texture_rect(texture, Rect2((size - drawn) * 0.5, drawn), false)
	draw_texture_rect(scrim, Rect2(0.0, 0.0, w, h), false)
	# Lockup.
	var left:float = maxf(20.0, w * 0.06)
	var base:float = h - 26.0
	draw_string(get_theme_default_font(), Vector2(left, base - 62.0), tracked(LocalizationManager.source("intro.overline")), HORIZONTAL_ALIGNMENT_LEFT, w - left * 2.0, 10, COVER_ACCENT)
	draw_string(display_font, Vector2(left, base - 20.0), LocalizationManager.source("intro.title"), HORIZONTAL_ALIGNMENT_LEFT, w - left * 2.0, 40, COVER_INK)
	draw_line(Vector2(left, base - 6.0), Vector2(left + 64.0, base - 6.0), COVER_ACCENT, 1.4)
