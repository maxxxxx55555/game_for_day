extends CanvasLayer
## A short editorial opening, with persisted locale and no artificial progress percentage.
var splash:Control
var hint:Label
var unsaved_dialog:ConfirmationDialog
func _ready() -> void:
	layer=100
	process_mode=Node.PROCESS_MODE_ALWAYS
	get_tree().auto_accept_quit=false
func show_splash() -> void:
	if is_instance_valid(splash):splash.show();return
	splash=Control.new()
	splash.name="LedgerOpening"
	splash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	splash.theme=preload("res://scripts/ui/FortuneTheme.gd").create()
	add_child(splash)
	var paper:=ColorRect.new()
	paper.color=Color("111e2e")
	paper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	splash.add_child(paper)
	var margins:=MarginContainer.new()
	margins.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right"]:margins.add_theme_constant_override("margin_"+side,48)
	splash.add_child(margins)
	var center:=CenterContainer.new()
	margins.add_child(center)
	var column:=VBoxContainer.new()
	column.add_theme_constant_override("separation",24)
	column.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	center.add_child(column)
	var emblem:=TextureRect.new()
	emblem.texture=load("res://assets/ui/app-icon.png")
	emblem.custom_minimum_size=Vector2(96,96)
	emblem.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	emblem.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	column.add_child(emblem)
	var nameplate:=Label.new()
	nameplate.text="Heirs of Fortune"
	nameplate.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	nameplate.add_theme_font_override("font",load("res://assets/fonts/Prata-Regular.ttf"))
	nameplate.add_theme_font_size_override("font_size",32)
	column.add_child(nameplate)
	var opening:=Label.new()
	opening.text=LocalizationManager.get_string("flow.loading")
	opening.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	opening.add_theme_color_override("font_color",Color("b6c2cc"))
	column.add_child(opening)
	hint=Label.new()
	hint.text=LocalizationManager.get_string("flow.tip."+str(Time.get_ticks_msec()%3))
	hint.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	hint.custom_minimum_size.x=400
	hint.add_theme_font_size_override("font_size",18)
	column.add_child(hint)
func hide_splash() -> void:
	if is_instance_valid(splash):splash.hide()
func open_ledger() -> void:
	show_splash()
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	hide_splash()
func confirm_unsaved(retry:Callable,leave:Callable) -> void:
	if is_instance_valid(unsaved_dialog):unsaved_dialog.popup_centered();return
	unsaved_dialog=ConfirmationDialog.new()
	unsaved_dialog.theme=preload("res://scripts/ui/FortuneTheme.gd").create()
	unsaved_dialog.title=LocalizationManager.get_string("ui.unsaved_title")
	unsaved_dialog.dialog_text=LocalizationManager.get_string("ui.unsaved_body")
	unsaved_dialog.ok_button_text=LocalizationManager.get_string("ui.retry_save")
	unsaved_dialog.cancel_button_text=LocalizationManager.get_string("ui.stay")
	unsaved_dialog.add_button(LocalizationManager.get_string("ui.discard_exit"),true,"discard")
	add_child(unsaved_dialog)
	unsaved_dialog.confirmed.connect(func():
		if retry.call():
			close_unsaved()
			leave.call()
		else:unsaved_dialog.popup_centered.call_deferred()
	)
	unsaved_dialog.custom_action.connect(func(action):
		if action=="discard":
			close_unsaved()
			leave.call()
	)
	unsaved_dialog.canceled.connect(close_unsaved)
	unsaved_dialog.popup_centered(Vector2i(500,260))

func close_unsaved() -> void:
	if is_instance_valid(unsaved_dialog):
		unsaved_dialog.hide()
		unsaved_dialog.queue_free()
	unsaved_dialog=null

func _notification(what:int) -> void:
	if what==NOTIFICATION_WM_CLOSE_REQUEST:
		var current:Node=get_tree().current_scene
		if current!=null and current.name=="LedgerBoot":get_tree().quit()
