extends SceneTree

var failures := 0

func check(value: bool, label: String) -> void:
	if not value:
		failures += 1
		print("FAIL: ", label)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	await process_frame
	var screen: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(screen)
	current_scene = screen
	await process_frame
	var game: Node = root.get_node("GameManager")
	game.reset_full_dynasty()
	screen.show_intro_screen()
	screen.ambition_buttons[2].pressed.emit()
	check(game.ambition == "heir", "The ambition control writes the model before the first card")
	game.set_theme_mode("light")
	for choice in 3: screen.on_choice_pressed(1)
	game.cash = 31415
	screen._notification(MainLoop.NOTIFICATION_APPLICATION_PAUSED)
	game.cash = 0
	game.ambition = "steady"
	var saved: Dictionary = game.load_current_life()
	check(game.cash == 31415 and not saved.is_empty(), "Android backgrounding persists the current life before the OS can evict it")
	check(game.ambition == "heir", "Backgrounding keeps the ambition the player chose")
	# A value no save could contain, so restoring "light" can only come from the settings file.
	game.theme_mode = "unwritten by any save"
	game.load_dynasty()
	check(str(game.theme_mode) == "light", "Backgrounding keeps the skin the player picked with the other settings")
	var event: Dictionary = screen.active_event.duplicate()
	var turns: int = game.total_turns
	screen.open_business_menu()
	screen._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	check(screen.current_mode == screen.ScreenMode.LIFE and screen.active_event == event and game.total_turns == turns, "Android Back closes a business menu without rerolling or spending a quarter")
	game.set_theme_mode("dark")
	print("MOBILE LIFECYCLE RESULT: ", "PASS" if failures == 0 else "FAIL")
	if not await root.get_node("SoundManager").shutdown():
		quit(1)
		return
	quit(0 if failures == 0 else 1)
