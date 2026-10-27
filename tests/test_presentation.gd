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
	game.reset_full_dynasty()
	var audio:Node=root.get_node("SoundManager")
	for stage in [[18,200.0,"study"],[35,200.0,"career"],[60,200.0,"welcome"],[35,60000000.0,"tycoon"]]:
		game.age = stage[0]
		game.cash = stage[1]
		screen.update_soundtrack_by_stage()
		screen.update_ui()
		var expected:String=audio.catalog.music[stage[2]].title
		if audio.current_music!=stage[2] or game.current_track!=expected or expected not in screen.music_label.text:
			push_error("The visible track title must identify the current composition")
			failed = true
	if OS.get_environment("GAME_AUDIO_MUTED") == "1" and "ВЫКЛ" not in screen.music_label.text:
		push_error("The audio indicator must show the effective muted state")
		failed = true
	print("PRESENTATION RESULT: ", "FAIL" if failed else "PASS")
	if not await root.get_node("SoundManager").shutdown():
		quit(1)
		return
	quit(1 if failed else 0)
