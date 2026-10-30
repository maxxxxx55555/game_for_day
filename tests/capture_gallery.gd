extends SceneTree

var capture_viewport: Viewport

func _initialize() -> void: call_deferred("run")

func shot(screen: Control, suffix: String) -> void:
	await create_timer(0.26).timeout
	await process_frame
	await RenderingServer.frame_post_draw
	capture_viewport.get_texture().get_image().save_png(OS.get_environment("GAME_SCREENSHOT").replace(".png", "-" + suffix + ".png"))
	if screen.dashboard.get_global_rect().position.y < 0:
		push_error("The financial dashboard must remain inside the viewport: " + suffix)
	var viewport_height: float = capture_viewport.get_visible_rect().size.y
	for button in [screen.btn_1, screen.btn_2, screen.btn_3, screen.market_btn]:
		if button.visible and button.get_global_rect().end.y > viewport_height + 1:
			push_error("Portrait choice extends outside the viewport: " + button.text)

func dismiss_pending_milestone(screen: Control) -> void:
	await create_timer(0.4).timeout
	if screen.milestone_card.visible:
		screen.milestone_card.dismiss()
		await process_frame

func seed_dynasty(game: Node) -> void:
	var loc: Node = root.get_node("LocalizationManager")
	game.legacy_points = 26
	game.unlocked_perks.assign(["warm_start", "business_savvy"])
	game.generation = 3
	game.lives_completed = 2
	game.momentum = 7
	game.ascension_level = 1
	game.run_ascension = 1
	game.dynasty_records = [
		{"generation": 1, "age": 68, "wealth_cents": 25000000000000, "rank": 1, "victory": true,
			"ambition": "meteor", "ascension": 0, "chains": 2, "milestones": 5},
		{"generation": 2, "age": 61, "wealth_cents": 4500000000000, "rank": 2400, "victory": false,
			"ambition": "heir", "ascension": 1, "chains": 1, "milestones": 3},
	]
	game.milestone_log = [
		{"age": 18, "wealth_cents": 55300, "rank": 6233850000, "stage": "survival", "chains": 0, "seen": true},
		{"age": 25, "wealth_cents": 200000000, "rank": 3500000000, "stage": "career", "chains": 1, "seen": true},
		{"age": 35, "wealth_cents": 5000000000, "rank": 60000000, "stage": "millionaire", "chains": 2, "seen": true},
	]
	game.chain_records = [
		{"id": "library_workshop", "stage": "survival", "flag": "taught",
			"label": loc.source("chain.library_workshop.codex"),
			"due_tick": 0, "completed": true, "outcome": "completed"},
		{"id": "night_courier", "stage": "survival", "flag": "paid",
			"label": loc.source("chain.night_courier.codex"),
			"due_tick": game.simulation_ticks + 6, "completed": false, "outcome": ""},
	]

func run() -> void:
	await process_frame
	var requested: String = OS.get_environment("GAME_GALLERY_VIEWPORT")
	var host: Node = root
	if requested.is_empty():
		root.get_node("FortuneArrival").show_splash()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OS.get_environment("GAME_SCREENSHOT").replace(".png","-loading.png"))
		root.get_node("FortuneArrival").hide_splash()
	else:
		var parts: PackedStringArray = requested.split("x")
		var viewport: SubViewport = SubViewport.new()
		viewport.size = Vector2i(int(parts[0]), int(parts[1]))
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		host = viewport
	capture_viewport = host as Viewport
	var screen: Control = load("res://scenes/Main.tscn").instantiate()
	host.add_child(screen)
	if host == root:
		current_scene = screen
	root.get_node("GameManager").reset_full_dynasty()
	var skin: String = OS.get_environment("GAME_GALLERY_THEME")
	if skin in ["dark", "light"] and root.get_node("GameManager").has_method("set_theme_mode"):
		root.get_node("GameManager").set_theme_mode(skin)
	screen.show_intro_screen()
	await shot(screen, "intro")
	screen.open_credits()
	await shot(screen,"credits")
	screen.credits_panel.close()
	await process_frame
	screen.btn_1.pressed.emit()
	await shot(screen,"birth")
	screen.btn_1.pressed.emit()
	await shot(screen,"perk")
	screen.btn_1.pressed.emit()
	await shot(screen, "life")
	screen.btn_1.pressed.emit()
	await dismiss_pending_milestone(screen)
	await shot(screen, "outcome")
	screen.market_btn.pressed.emit()
	await shot(screen, "market")
	screen.currency_button.pressed.emit()
	await shot(screen, "currencies")
	screen.currency_panel.closed.emit()
	screen.biz_btn.pressed.emit()
	await shot(screen, "business")
	var game: Node = root.get_node("GameManager")
	seed_dynasty(game)
	screen.dynasty_button.pressed.emit()
	for section: String in ["journal", "legacy", "threads", "hall", "ascension"]:
		screen.dynasty_panel.set_section(section)
		await shot(screen, "dynasty-" + section)
	screen.dynasty_panel.close_button.pressed.emit()
	await process_frame
	game.age = 50
	game.check_milestones()
	screen.present_milestone_if_pending()
	await shot(screen, "milestone")
	screen.milestone_card.dismiss()
	await process_frame
	screen.open_settings_menu()
	await shot(screen,"settings")
	print("PORTRAIT GALLERY: PASS")
	if not await root.get_node("SoundManager").shutdown():
		quit(1)
		return
	quit(0)
