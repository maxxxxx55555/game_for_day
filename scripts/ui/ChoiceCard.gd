extends MarginContainer
const Palette=preload("res://scripts/ui/Palette.gd")
const NUMERALS:Array[String]= ["I","II","III","IV"]
var index:int=0
var button:Button
var title:Label
var detail:Label
var previous:String=""
var measured_width:float=-1.0
var previous_language:String=""
func _ready() -> void:
	button=get_parent() as Button
	name="ChoiceCard"
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_theme_constant_override("margin_left",46)
	add_theme_constant_override("margin_right",20)
	for edge:String in ["top","bottom"]: add_theme_constant_override("margin_"+edge,12)
	button.add_theme_font_size_override("font_size",1)
	button.add_theme_constant_override("outline_size",0)
	button.custom_minimum_size.y=92
	for state:String in ["font_color","font_hover_color","font_pressed_color","font_hover_pressed_color","font_focus_color","font_disabled_color","font_outline_color"]:
		button.add_theme_color_override(state,Color.TRANSPARENT)
	var column:VBoxContainer=VBoxContainer.new()
	column.alignment=BoxContainer.ALIGNMENT_CENTER
	column.mouse_filter=Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation",5)
	add_child(column)
	title=Label.new()
	title.name="ActionTitle"
	title.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size",24)
	title.mouse_filter=Control.MOUSE_FILTER_IGNORE
	column.add_child(title)
	detail=Label.new()
	detail.name="ActionDetail"
	detail.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	detail.add_theme_font_size_override("font_size",20)
	detail.mouse_filter=Control.MOUSE_FILTER_IGNORE
	column.add_child(detail)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	GameManager.theme_changed.connect(func(_mode:String)->void:queue_redraw())
	refresh()

## Roman index drawn in the gutter, the way a numbered menu is set in print.
func numeral() -> String:
	return NUMERALS[clampi(index-1,0,NUMERALS.size()-1)]

func _draw() -> void:
	if index <= 0: return
	var color:Color= Palette.muted() if (button and button.disabled) else Palette.accent()
	draw_string(get_theme_default_font(),Vector2(20.0,size.y*0.5+5.0),numeral(),HORIZONTAL_ALIGNMENT_LEFT,-1,14,color)

func refresh() -> void:
	if not is_instance_valid(button): return
	modulate.a=0.5 if button.disabled else 1.0
	title.add_theme_color_override("font_color",Palette.text())
	detail.add_theme_color_override("font_color",Palette.muted())
	var available:float=button.size.x-40
	if button.text==previous and previous_language==LocalizationManager.current_language and is_equal_approx(available,measured_width): return
	previous_language=LocalizationManager.current_language
	previous=button.text
	measured_width=available
	var copy:Dictionary=preload("res://scripts/ui/ChoiceCopy.gd").parts(button.text)
	title.text=copy.title
	detail.text=copy.detail
	detail.visible=not detail.text.is_empty()
	button.tooltip_text=button.text
	if available>80:
		button.custom_minimum_size.y=maxf(92,32+text_height(title,available)+(text_height(detail,available)+5 if detail.visible else 0.0))

func text_height(label:Label,width:float) -> float:
	var paragraph:TextParagraph=TextParagraph.new()
	paragraph.width=width
	paragraph.break_flags=TextServer.BREAK_MANDATORY|TextServer.BREAK_WORD_BOUND|TextServer.BREAK_ADAPTIVE
	if not paragraph.add_string(LocalizationManager.display(label.text),label.get_theme_font("font"),label.get_theme_font_size("font_size")):
		return label.get_combined_minimum_size().y
	return paragraph.get_size().y
