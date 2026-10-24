extends Control
## Outcome presentation delegates all game rules to Main.
signal choice_requested(option: int)
var primary: Button
var secondary: Button
var painting: TextureRect
var heading: Label
var overline: Label
var story: Label
var wealth: Label
var legacy: Label
var victorious := false
var elapsed := 0.0
var entrance: Tween

func label(parent: Node, font_size: int, color: Color = Color("eeeadd")) -> Label:
	var text := Label.new()
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
	var shade := TextureRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0,0.32,0.58,1])
	gradient.colors = PackedColorArray([Color(0.04,0.09,0.15,0.4),Color(0.04,0.09,0.15,0),Color(0.04,0.09,0.15,0.6),Color(0.04,0.09,0.15,0.99)])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 8
	texture.height = 256
	texture.fill_from = Vector2(0,0)
	texture.fill_to = Vector2(0,1)
	shade.texture = texture
	add_child(shade)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right"]: margin.add_theme_constant_override("margin_"+side,34)
	for side in ["top","bottom"]: margin.add_theme_constant_override("margin_"+side,28)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",14)
	margin.add_child(column)
	var brand := label(column,18,Color("d4bd90"))
	brand.text = "HEIRS OF FORTUNE"
	brand.add_theme_font_override("font",load("res://assets/fonts/Prata-Regular.ttf"))
	var space := Control.new()
	space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	space.custom_minimum_size.y = 200
	column.add_child(space)
	overline = label(column,17,Color("d4bd90"))
	heading = label(column,38)
	heading.add_theme_font_override("font",load("res://assets/fonts/Prata-Regular.ttf"))
	story = label(column,21,Color("c8d1d3"))
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel",preload("res://scripts/ui/FortuneTheme.gd").style(Color(0.07,0.14,0.20,0.86),Color(0.72,0.62,0.43,0.4)))
	column.add_child(card)
	var metrics := VBoxContainer.new()
	card.add_child(metrics)
	wealth = label(metrics,34,Color("dfc692"))
	legacy = label(metrics,17,Color("c2cdd0"))
	primary = Button.new()
	primary.name = "FinalePrimary"
	primary.custom_minimum_size.y = 64
	primary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(primary)
	primary.pressed.connect(func(): choice_requested.emit(1))
	secondary = Button.new()
	secondary.name = "FinaleSecondary"
	secondary.custom_minimum_size.y = 60
	secondary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(secondary)
	secondary.pressed.connect(func(): choice_requested.emit(2))
	resized.connect(queue_redraw)
	hide()

func present(data: Dictionary) -> void:
	victorious = data.victory
	painting.texture = load("res://assets/art/ending_victory.png" if victorious else "res://assets/art/ending_defeat.png")
	overline.text = "ПОБЕДА · ВАША ИСТОРИЯ ОСТАНЕТСЯ" if victorious else "КОНЕЦ ГЛАВЫ · НАЧАЛО НАСЛЕДИЯ"
	heading.text = "Вы создали наследие" if victorious else "У каждой истории есть продолжение"
	story.text = "За цифрами — прожитая жизнь. Теперь ваше состояние и опыт станут началом новой истории." if victorious else data.reason
	wealth.text = "$" + data.wealth
	legacy.text = "Поколение %d · %d лет · место #%s" % [data.generation,data.age,data.rank]
	primary.text = "Принять наследие · следующее поколение"
	secondary.visible = data.revive
	if data.revive:
		primary.text = "Второй шанс · экстренная помощь"
		secondary.text = "Передать историю следующему поколению"
	show()
	elapsed = 0
	if entrance and entrance.is_valid(): entrance.kill()
	modulate.a = 0
	entrance = create_tween()
	entrance.tween_property(self,"modulate:a",1.0,0.65).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	primary.grab_focus()

func _process(delta: float) -> void:
	if not visible: return
	elapsed = fmod(elapsed+delta,1000.0)
	queue_redraw()

func _draw() -> void:
	if not visible: return
	for i in 18:
		var x := fmod(i*137.0+sin(elapsed*0.12+i)*12,size.x)
		var y := fmod(i*103.0+elapsed*(5 if victorious else 22),size.y*0.58)
		if victorious: draw_circle(Vector2(x,y),1.5,Color(0.95,0.8,0.48,0.15))
		else: draw_line(Vector2(x,y),Vector2(x-3,y+18),Color(0.6,0.74,0.83,0.08),1,true)
