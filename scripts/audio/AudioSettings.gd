extends VBoxContainer
var language_picker:OptionButton
func _ready() -> void:
	add_theme_constant_override("separation",8)
	language_picker=OptionButton.new()
	language_picker.name="SettingsLanguage"
	language_picker.auto_translate_mode=Node.AUTO_TRANSLATE_MODE_DISABLED
	language_picker.add_item("Русский")
	language_picker.add_item("English")
	language_picker.selected=0 if LocalizationManager.current_language=="ru" else 1
	add_child(language_picker)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	language_picker.item_selected.connect(func(index:int)->void:LocalizationManager.set_language("ru" if index==0 else "en"))
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	LocalizationManager.language_changed.connect(_on_language_changed)
	for entry:Array in [["ui.master","master_volume"],["copy.19ecb2b49349","music_volume"],["copy.05321a5231ca","sfx_volume"],["ui.interface","ui_volume"]]:
		var row:HBoxContainer=HBoxContainer.new()
		add_child(row)
		var label:Label=Label.new()
		label.text=LocalizationManager.source(str(entry[0]))
		label.set_meta("locale_key",entry[0])
		label.custom_minimum_size.x=125
		row.add_child(label)
		var slider:HSlider=HSlider.new()
		slider.name=entry[1]
		slider.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		slider.min_value=0
		slider.max_value=1
		slider.step=0.05
		slider.value=GameManager.get(str(entry[1]))
		row.add_child(slider)
		# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
		@warning_ignore("return_value_discarded")
		slider.value_changed.connect(func(value:float)->void:
			GameManager.set(str(entry[1]),clampf(value,0,1))
			SoundManager.apply_gains()
			# save_dynasty reports persistence failure to the visible save-status path.
			@warning_ignore("return_value_discarded")
			GameManager.save_dynasty()
		)

	var motion:CheckBox=CheckBox.new()
	motion.name="ReducedMotion"
	motion.text=LocalizationManager.source("ui.reduced_motion")
	motion.set_meta("locale_key","ui.reduced_motion")
	motion.button_pressed=GameManager.reduced_motion
	add_child(motion)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	motion.toggled.connect(func(enabled:bool)->void:
		GameManager.reduced_motion=enabled
		# save_dynasty reports persistence failure to the visible save-status path.
		@warning_ignore("return_value_discarded")
		GameManager.save_dynasty()
	)

func _on_language_changed(locale:String)->void:
	language_picker.select(0 if locale=="ru" else 1)
	for control:Node in find_children("*","Control",true,false):
		if control.has_meta("locale_key"):
			if control is Label:(control as Label).text=LocalizationManager.source(str(control.get_meta("locale_key")))
		elif control is CheckBox:(control as CheckBox).text=LocalizationManager.source(str(control.get_meta("locale_key")))
