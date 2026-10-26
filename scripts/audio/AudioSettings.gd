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
	language_picker.item_selected.connect(func(index):LocalizationManager.set_language("ru" if index==0 else "en"))
	LocalizationManager.language_changed.connect(_on_language_changed)
	for entry in [["ui.master","master_volume"],["copy.19ecb2b49349","music_volume"],["copy.05321a5231ca","sfx_volume"],["ui.interface","ui_volume"]]:
		var row:=HBoxContainer.new()
		add_child(row)
		var label:=Label.new()
		label.text=LocalizationManager.source(entry[0])
		label.set_meta("locale_key",entry[0])
		label.custom_minimum_size.x=125
		row.add_child(label)
		var slider:=HSlider.new()
		slider.name=entry[1]
		slider.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		slider.min_value=0
		slider.max_value=1
		slider.step=0.05
		slider.value=GameManager.get(entry[1])
		row.add_child(slider)
		slider.value_changed.connect(func(value):
			GameManager.set(entry[1],clampf(value,0,1))
			SoundManager.apply_gains()
			GameManager.save_dynasty()
		)

	var motion:=CheckBox.new()
	motion.name="ReducedMotion"
	motion.text=LocalizationManager.source("ui.reduced_motion")
	motion.set_meta("locale_key","ui.reduced_motion")
	motion.button_pressed=GameManager.reduced_motion
	add_child(motion)
	motion.toggled.connect(func(enabled):
		GameManager.reduced_motion=enabled
		GameManager.save_dynasty()
	)

func _on_language_changed(locale:String)->void:
	language_picker.select(0 if locale=="ru" else 1)
	for control in find_children("*","Control",true,false):
		if control.has_meta("locale_key"):
			control.text=LocalizationManager.source(control.get_meta("locale_key"))
