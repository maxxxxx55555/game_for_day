extends SceneTree

func _initialize() -> void: call_deferred("run")

func run() -> void:
	await process_frame
	var screen: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(screen)
	current_scene = screen
	var game: Node = root.get_node("GameManager")
	game.reset_full_dynasty()
	screen.show_intro_screen()
	for i in 3: screen.btn_1.pressed.emit()
	game.stock_units = 7
	game.crypto_units = 2
	var turns: int = game.total_turns
	var event: Dictionary = screen.active_event.duplicate()
	screen.open_market_menu()
	var back := screen.find_child("MarketBack", true, false) as Button
	if back == null:
		print("FAIL: Portfolio needs an explicit exit that keeps investments")
		quit(1)
		return
	back.pressed.emit()
	var ok: bool = game.stock_units == 7 and game.crypto_units == 2 and game.total_turns == turns and screen.active_event == event and screen.current_mode == screen.ScreenMode.LIFE
	print("MARKET EXIT RESULT: ", "PASS" if ok else "FAIL")
	quit(0 if ok else 1)
