extends Control
## A retrospective card. The world keeps running underneath; Continue only records
## that the milestone was read.
signal dismissed(age_value: int)
const Palette=preload("res://scripts/ui/Palette.gd")
const SkinTheme=preload("res://scripts/ui/FortuneTheme.gd")
const Money=preload("res://scripts/security/Money.gd")
var overline:Label
var heading:Label
var body:Label
var momentum:Label
var continue_button:Button
var card:PanelContainer
var entrance:Tween
var current_age:int=0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	var shade:ColorRect=ColorRect.new()
	shade.color=Color(0.05,0.06,0.08,0.42)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var center:CenterContainer=CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var margin:MarginContainer=MarginContainer.new()
	for side:String in ["left","right"]: margin.add_theme_constant_override("margin_"+side,26)
	margin.mouse_filter=Control.MOUSE_FILTER_IGNORE
	center.add_child(margin)
	card=PanelContainer.new()
	card.name="MilestoneCard"
	card.mouse_filter=Control.MOUSE_FILTER_STOP
	card.add_theme_stylebox_override("panel",SkinTheme.panel(Palette.surface(),Palette.accent(),8))
	margin.add_child(card)
	var column:VBoxContainer=VBoxContainer.new()
	column.add_theme_constant_override("separation",10)
	card.add_child(column)
	overline=Label.new()
	overline.text=LocalizationManager.source("milestone.overline")
	overline.add_theme_font_size_override("font_size",12)
	overline.add_theme_color_override("font_color",Palette.accent())
	column.add_child(overline)
	heading=Label.new()
	heading.add_theme_font_override("font",SkinTheme.display_font(600))
	heading.add_theme_font_size_override("font_size",22)
	heading.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	column.add_child(heading)
	body=Label.new()
	body.add_theme_font_size_override("font_size",15)
	body.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	column.add_child(body)
	momentum=Label.new()
	momentum.add_theme_font_size_override("font_size",13)
	momentum.add_theme_color_override("font_color",Palette.accent())
	column.add_child(momentum)
	continue_button=Button.new()
	continue_button.name="MilestoneContinue"
	continue_button.text=LocalizationManager.source("milestone.continue")
	continue_button.custom_minimum_size.y=48
	column.add_child(continue_button)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	continue_button.pressed.connect(dismiss)
	hide()

func thread_note(chains:int) -> String:
	if chains<=0:
		return LocalizationManager.source("milestone.none")
	return LocalizationManager.source("milestone.threads") % chains

func present(entry:Dictionary) -> void:
	current_age=entry.get("age",0)
	var stage:String=str(entry.get("stage","survival"))
	var wealth_cents:int=entry.get("wealth_cents",0)
	var rank_value:int=entry.get("rank",0)
	var chains:int=entry.get("chains",0)
	heading.text=LocalizationManager.source("milestone.title") % current_age
	body.text=LocalizationManager.source("milestone.body") % [
		GameManager.format_num(Money.dollars(wealth_cents)),
		str(rank_value),
		LocalizationManager.source("milestone.stage."+stage),
		thread_note(chains)
	]
	momentum.text=LocalizationManager.source("milestone.momentum") % 2
	show()
	if is_instance_valid(entrance):
		entrance.kill()
	modulate.a=1.0
	if GameManager.reduced_motion:
		return
	modulate.a=0.0
	entrance=create_tween()
	# Tween owns this fluent configuration; no reference to the builder is needed.
	@warning_ignore("return_value_discarded")
	entrance.tween_property(self,"modulate:a",1.0,0.24).set_trans(Tween.TRANS_SINE)

func dismiss() -> void:
	var age_value:int=current_age
	hide()
	dismissed.emit(age_value)
