extends CanvasLayer
## A short editorial opening, with persisted locale and no artificial progress percentage.
var splash:Control
var hint:Label
var opening_label:Label
var unsaved_dialog:ConfirmationDialog
func _ready() -> void:
	layer=100
	process_mode=Node.PROCESS_MODE_ALWAYS
	get_tree().auto_accept_quit=false
	call_deferred("bind_locale")
func show_splash() -> void:
	if is_instance_valid(splash):refresh_copy();splash.show();return
	splash=Control.new()
	splash.name="LedgerOpening"
	splash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	splash.theme=preload("res://scripts/ui/FortuneTheme.gd").create()
	add_child(splash)
	var paper:ColorRect=ColorRect.new()
	paper.color=Color("111e2e")
	paper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	splash.add_child(paper)
	var margins:MarginContainer=MarginContainer.new()
	margins.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side:String in ["left","right"]:margins.add_theme_constant_override("margin_"+side,48)
	splash.add_child(margins)
	var center:CenterContainer=CenterContainer.new()
	margins.add_child(center)
	var column:VBoxContainer=VBoxContainer.new()
	column.add_theme_constant_override("separation",24)
	column.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	center.add_child(column)
	var emblem:TextureRect=TextureRect.new()
	emblem.texture=load("res://assets/ui/app-icon.png")
	emblem.custom_minimum_size=Vector2(96,96)
	emblem.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	emblem.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	column.add_child(emblem)
	var nameplate:Label=Label.new()
	nameplate.text="Heirs of Fortune"
	nameplate.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	nameplate.add_theme_font_override("font",load("res://assets/fonts/Prata-Regular.ttf") as Font)
	nameplate.add_theme_font_size_override("font_size",32)
	column.add_child(nameplate)
	opening_label=Label.new()
	opening_label.text=LocalizationManager.get_string("flow.loading")
	opening_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	opening_label.add_theme_color_override("font_color",Color("b6c2cc"))
	column.add_child(opening_label)
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
	var scene_error:Error=get_tree().change_scene_to_file("res://scenes/Main.tscn")
	if scene_error!=OK:
		hide_splash()
		push_error("Ledger scene could not be opened: "+error_string(scene_error))
		return
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
	# ConfirmationDialog owns this discard-action button and routes its custom_action signal.
	@warning_ignore("return_value_discarded")
	unsaved_dialog.add_button(LocalizationManager.get_string("ui.discard_exit"),true,"discard")
	add_child(unsaved_dialog)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	unsaved_dialog.confirmed.connect(func()->void:
		if retry.call():
			close_unsaved()
			leave.call()
		else:unsaved_dialog.popup_centered.call_deferred()
	)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	unsaved_dialog.custom_action.connect(func(action:StringName)->void:
		if action=="discard":
			close_unsaved()
			leave.call()
	)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
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

func bind_locale() -> void:
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	LocalizationManager.language_changed.connect(func(_language:String)->void:refresh_copy())
func refresh_copy() -> void:
	if is_instance_valid(opening_label):opening_label.text=LocalizationManager.get_string("flow.loading")
	if is_instance_valid(hint):hint.text=LocalizationManager.get_string("flow.tip."+str(Time.get_ticks_msec()%3))
