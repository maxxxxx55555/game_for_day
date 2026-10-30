extends Control
const Palette=preload("res://scripts/ui/Palette.gd")
const SkinTheme=preload("res://scripts/ui/FortuneTheme.gd")
signal closed
var backdrop_panel:Panel
var title_label:Label
var body:Label
var close_button:Button
func _ready() -> void:
	name="CreditsPanel"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index=200
	mouse_filter=Control.MOUSE_FILTER_STOP
	var backdrop:Panel=Panel.new()
	backdrop_panel=backdrop
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.add_theme_stylebox_override("panel",SkinTheme.style(Palette.surface(),Palette.rule()))
	add_child(backdrop)
	var margin:MarginContainer=MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge:String in ["left","right"]:margin.add_theme_constant_override("margin_"+edge,32)
	for edge:String in ["top","bottom"]:margin.add_theme_constant_override("margin_"+edge,32)
	add_child(margin)
	var column:VBoxContainer=VBoxContainer.new()
	column.add_theme_constant_override("separation",24)
	margin.add_child(column)
	var title:Label=Label.new()
	title.text="HEIRS OF FORTUNE"
	title.add_theme_font_override("font",load("res://assets/fonts/Prata-Regular.ttf") as Font)
	title.add_theme_font_size_override("font_size",32)
	title.add_theme_color_override("font_color",Palette.accent())
	title_label=title
	column.add_child(title)
	var scroll:ScrollContainer=ScrollContainer.new()
	scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	body=Label.new()
	body.name="CreditsBody"
	body.text=LocalizationManager.source("ui.credits_body")
	body.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	body.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	body.add_theme_font_size_override("font_size",22)
	scroll.add_child(body)
	close_button=Button.new()
	close_button.name="CloseCredits"
	close_button.text=LocalizationManager.source("ui.close")
	close_button.custom_minimum_size.y=64
	column.add_child(close_button)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	close_button.pressed.connect(close)
	close_button.grab_focus()
func close() -> void:
	closed.emit()
	queue_free()
func _unhandled_key_input(event:InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
