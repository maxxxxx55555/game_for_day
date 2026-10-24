extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	await process_frame
	var screen: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(screen)
	current_scene = screen
	await process_frame
	var game: Node = root.get_node("GameManager")
	var failed := false
	for age in [18, 35, 60]:
		game.age = age
		screen.update_soundtrack_by_stage()
		screen.update_ui()
		if "Last Call at Three" not in game.current_track:
			push_error("The visible track title must identify the current composition")
			failed = true
	if OS.get_environment("GAME_AUDIO_MUTED") == "1" and "ВЫКЛ" not in screen.music_label.text:
		push_error("The audio indicator must show the effective muted state")
		failed = true
	print("PRESENTATION RESULT: ", "FAIL" if failed else "PASS")
	quit(1 if failed else 0)
