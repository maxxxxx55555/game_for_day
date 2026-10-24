extends VBoxContainer

func _ready() -> void:
	for entry in [["Музыка", "music_volume"], ["Эффекты", "sfx_volume"]]:
		var row := HBoxContainer.new()
		add_child(row)
		var label := Label.new()
		label.text = entry[0]
		label.custom_minimum_size.x = 120
		row.add_child(label)
		var slider := HSlider.new()
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.min_value = 0
		slider.max_value = 1
		slider.step = 0.05
		slider.value = GameManager.get(entry[1])
		row.add_child(slider)
		slider.value_changed.connect(func(value):
			GameManager.set(entry[1], value)
			SoundManager.apply_gains()
			GameManager.save_dynasty()
		)
