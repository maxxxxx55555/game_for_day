extends Control
## Outcome presentation delegates all game rules to Main.
signal choice_requested(option: int)
var primary: Button
var secondary: Button
var tertiary: Button
var ascension_hint: Label
var painting: TextureRect
var heading: Label
var overline: Label
var story: Label
var wealth: Label
var legacy: Label
var spacer: Control
var victorious:bool= false
var elapsed:float= 0.0
var entrance: Tween

func label(parent: Node, font_size: int, color: Color = Color("eeeadd")) -> Label:
	var text:Label= Label.new()
	text.add_theme_font_size_override("font_size",font_size)
	text.add_theme_color_override("font_color",color)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(text)
	return text

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	painting = TextureRect.new()
	painting.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	painting.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	painting.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	painting.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(painting)
	var shade:TextureRect= TextureRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var gradient:Gradient= Gradient.new()
	gradient.offsets = PackedFloat32Array([0,0.32,0.58,1])
	gradient.colors = PackedColorArray([Color(0.04,0.09,0.15,0.4),Color(0.04,0.09,0.15,0),Color(0.04,0.09,0.15,0.6),Color(0.04,0.09,0.15,0.99)])
	var texture:GradientTexture2D= GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 8
	texture.height = 256
	texture.fill_from = Vector2(0,0)
	texture.fill_to = Vector2(0,1)
	shade.texture = texture
	add_child(shade)
	var margin:MarginContainer= MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side:String in ["left","right"]: margin.add_theme_constant_override("margin_"+side,32)
	for side:String in ["top","bottom"]: margin.add_theme_constant_override("margin_"+side,24)
	add_child(margin)
	var column:VBoxContainer= VBoxContainer.new()
	column.add_theme_constant_override("separation",16)
	margin.add_child(column)
	var brand:Label= label(column,18,Color("c9a227"))
	brand.text = "HEIRS OF FORTUNE"
	spacer= Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.custom_minimum_size.y = 200
	column.add_child(spacer)
	overline = label(column,17,Color("c9a227"))
	heading = label(column,32)
	heading.add_theme_font_override("font",preload("res://scripts/ui/FortuneTheme.gd").display_font(600))
	story = label(column,21,Color("d8dfe0"))
	var card:PanelContainer= PanelContainer.new()
	card.add_theme_stylebox_override("panel",preload("res://scripts/ui/FortuneTheme.gd").style(Color(0.18,0.25,0.34,0.9),Color(0.79,0.64,0.15,0.55)))
	column.add_child(card)
	var metrics:VBoxContainer= VBoxContainer.new()
	card.add_child(metrics)
	wealth = label(metrics,34,Color("c9a227"))
	legacy = label(metrics,17,Color("d8dfe0"))
	primary = Button.new()
	primary.name = "FinalePrimary"
	primary.custom_minimum_size.y = 64
	primary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(primary)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	primary.pressed.connect(func()->void: choice_requested.emit(1))
	secondary = Button.new()
	secondary.name = "FinaleSecondary"
	secondary.custom_minimum_size.y = 60
	secondary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(secondary)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	secondary.pressed.connect(func()->void: choice_requested.emit(2))
	tertiary = Button.new()
	tertiary.name = "FinaleAscension"
	tertiary.custom_minimum_size.y = 58
	tertiary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(tertiary)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	tertiary.pressed.connect(func()->void: choice_requested.emit(3))
	ascension_hint = label(column,14,Color("c9a227"))
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	resized.connect(queue_redraw)
	hide()

func present(data: Dictionary) -> void:
	victorious = data.victory
	painting.texture = load("res://assets/art/ending_victory.png" if victorious else "res://assets/art/ending_defeat.png")
	overline.text = LocalizationManager.source("copy.eaafe278d74d") if victorious else LocalizationManager.source("copy.d1eba7de1ca1")
	heading.text = LocalizationManager.source("copy.369eb05aca46") if victorious else LocalizationManager.source("copy.e8f666386cf2")
	story.text = LocalizationManager.source("copy.c4ef0fe2e45a") if victorious else data.reason
	wealth.text = "$" + data.wealth
	legacy.text = LocalizationManager.source("copy.377bfc5e6b3e") % [data.generation,data.age,data.rank]
	primary.text = LocalizationManager.source("copy.1644cbb54fcc")
	secondary.visible = data.revive
	if data.revive:
		primary.text = LocalizationManager.source("copy.1549f96910e3")
		secondary.text = LocalizationManager.source("copy.0bbe03537dc6")
	var ascension_available:bool=data.get("ascension_available",false)
	tertiary.visible=ascension_available
	ascension_hint.visible=ascension_available
	if ascension_available:
		var ascension_next:int=data.get("ascension_next",1)
		var ascension_bonus:int=data.get("ascension_bonus",3)
		tertiary.text=LocalizationManager.source("ascension.finale.action") % ascension_next
		ascension_hint.text=LocalizationManager.source("ascension.finale.hint") % ascension_bonus
	spacer.custom_minimum_size.y=90 if ascension_available else 200
	show()
	elapsed = 0
	if entrance and entrance.is_valid(): entrance.kill()
	modulate.a = 1.0 if GameManager.reduced_motion else 0.0
	if not GameManager.reduced_motion:
		entrance = create_tween()
		# Tween owns this fluent configuration; no reference to the builder is needed.
		@warning_ignore("return_value_discarded")
		entrance.tween_property(self,"modulate:a",1.0,0.65).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	primary.grab_focus()

func _process(delta: float) -> void:
	if not visible or GameManager.reduced_motion: return
	elapsed = fmod(elapsed+delta,1000.0)
	queue_redraw()

func _draw() -> void:
	if not visible: return
	for i:int in 18:
		var x:float= fmod(i*137.0+sin(elapsed*0.12+i)*12,size.x)
		var y:float= fmod(i*103.0+elapsed*(5 if victorious else 22),size.y*0.58)
		if victorious: draw_circle(Vector2(x,y),1.5,Color(0.95,0.8,0.48,0.15))
		else: draw_line(Vector2(x,y),Vector2(x-3,y+18),Color(0.6,0.74,0.83,0.08),1,true)
