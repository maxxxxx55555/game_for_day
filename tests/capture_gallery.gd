extends SceneTree

func _initialize() -> void: call_deferred("run")

func shot(screen: Control, suffix: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OS.get_environment("GAME_SCREENSHOT").replace(".png", "-" + suffix + ".png"))
	if screen.dashboard.get_global_rect().position.y < 0:
		push_error("The financial dashboard must remain inside the viewport: " + suffix)
	for button in [screen.btn_1, screen.btn_2, screen.btn_3, screen.market_btn]:
		if button.visible and button.get_global_rect().end.y > root.get_visible_rect().size.y + 1:
			push_error("Portrait choice extends outside the viewport: " + button.text)

func run() -> void:
	await process_frame
	var screen: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(screen)
	current_scene = screen
	root.get_node("GameManager").reset_full_dynasty()
	screen.show_intro_screen()
	await shot(screen, "intro")
	for i in 3: screen.btn_1.pressed.emit()
	await shot(screen, "life")
	screen.market_btn.pressed.emit()
	await shot(screen, "market")
	screen.biz_btn.pressed.emit()
	await shot(screen, "business")
	print("PORTRAIT GALLERY: PASS")
	quit(0)
