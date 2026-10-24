extends SceneTree

var failures: Array[String] = []
var game: Node
var ui: Control
var checks: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
		print("FAIL: ", message)

func run() -> void:
	await process_frame
	game = root.get_node_or_null("GameManager")
	if not game or not game.has_method("reset_game"):
		check(false, "GameManager must compile and load")
		finish()
		return
	var scene = load("res://scenes/Main.tscn")
	ui = scene.instantiate()
	root.add_child(ui)
	current_scene = ui
	await process_frame
	if not ui.has_method("on_choice_pressed"):
		check(false, "Main scene must compile and accept choices")
		finish()
		return
	var scenario = OS.get_cmdline_user_args()
	if scenario.has("--playthrough"):
		await playthrough()
	else:
		await regressions()
	finish()

func regressions() -> void:
	game.reset_full_dynasty()
	ui.active_event = {}
	ui.show_intro_screen()
	ui.on_choice_pressed(1)
	ui.on_choice_pressed(1)
	ui.on_choice_pressed(1)
	check(ui.current_mode == ui.ScreenMode.LIFE, "New game reaches life choices")
	var event_before: Dictionary = ui.active_event
	ui.open_settings_menu()
	ui.handle_settings_action(3)
	check(ui.active_event == event_before, "Opening settings cannot reroll the current event")
	game.age = 55
	game.cash = 100000.0
	game.health = 0
	var generation_before: int = game.generation
	var legacy_before: int = game.legacy_points
	ui.check_game_over()
	check(game.generation == generation_before, "A reversible death cannot commit inheritance")
	ui.on_choice_pressed(1)
	check(game.generation == generation_before, "Revival keeps the same generation")
	check(game.legacy_points == legacy_before, "Revival cannot award dynasty points")
	game.cash = 250000000000.0
	game.recalculate_forbes_rank()
	ui.load_next_life_event()
	check(ui.current_mode == ui.ScreenMode.GAMEOVER, "Forbes target shows victory")
	ui.on_choice_pressed(1)
	check(ui.current_mode == ui.ScreenMode.INTRO, "Victory button starts the next generation instead of reviving")
	check(game.generation == generation_before + 1, "Exactly one generation is committed")
	check(game.legacy_points > legacy_before, "Finished life awards dynasty points")
	game.reset_game()
	game.cash = 20000.0
	game.energy = 100
	game.time_speed = 1.0
	game.business_tier = 1
	var turns_before: int = game.total_turns
	ui.handle_business_action(2)
	check(game.total_turns == turns_before + 1, "Business optimization consumes its advertised quarter")
	game.reset_game()
	game.cash = 10000.0
	game.time_speed = 0.5
	game.advance_quarter_and_markets()
	check(is_equal_approx(game.cash, 9860.0), "Half-quarter charges half of its starting living cost")
	game.reset_game()
	game.cash = 10000.0
	game.time_speed = 2.0
	game.advance_quarter_and_markets()
	check(is_equal_approx(game.cash, 9440.0), "Two-quarter action charges two starting living costs")
	game.reset_game()
	game.cash = 240000000000.0
	ui.load_next_life_event()
	ui.watch_ad_for_bonus()
	check(ui.current_mode == ui.ScreenMode.GAMEOVER, "A grant reaching the target immediately shows victory")
	game.reset_game()
	game.ad_cooldown = 4
	game.time_speed = 0.5
	game.advance_quarter_and_markets()
	check(game.ad_cooldown == 3.5, "Grant cooldown measures elapsed quarters at half speed")
	game.ad_cooldown = 4
	game.time_speed = 2
	game.advance_quarter_and_markets()
	check(game.ad_cooldown == 2, "Grant cooldown measures elapsed quarters at double speed")
	check(ui.has_method("save_session"), "A running life can be saved and resumed")
	if ui.has_method("save_session"):
		game.reset_game()
		game.cash = 123456.0
		game.age = 40
		game.stock_units = 2.0
		game.business_tier = 2
		ui.load_next_life_event()
		var saved_title: String = ui.active_event.title
		ui.save_session()
		ui.queue_free()
		await process_frame
		ui = load("res://scenes/Main.tscn").instantiate()
		root.add_child(ui)
		current_scene = ui
		await process_frame
		check(game.cash == 123456.0 and game.age == 40, "Reopening the main scene resumes finances and age")
		check(game.stock_units == 2.0 and game.business_tier == 2, "Reopening preserves investments and business")
		check(ui.active_event.title == saved_title, "Resuming cannot reroll the pending life decision")
		game.reset_full_dynasty()
		ui.show_intro_screen()
		ui.btn_1.pressed.emit()
		var birth_cash: float = game.cash
		var birth_origin: String = game.birth_origin
		await reopen_ui()
		check(ui.current_mode == ui.ScreenMode.BIRTH and game.cash == birth_cash and game.birth_origin == birth_origin, "Birth resumes without rerolling origin or starting cash")
		ui.btn_1.pressed.emit()
		await reopen_ui()
		check(ui.current_mode == ui.ScreenMode.PERK and ui.market_btn.disabled, "Resumed perk selection cannot bypass the starting trait")
		ui.btn_1.pressed.emit()
		game.cash = 250000000000.0
		game.recalculate_forbes_rank()
		ui.load_next_life_event()
		await reopen_ui()
		check(ui.current_mode == ui.ScreenMode.GAMEOVER and not ui.can_revive, "Victory survives a restart and cannot offer revival")
		var before: int = game.generation
		ui.btn_1.pressed.emit()
		check(game.generation == before + 1 and ui.current_mode == ui.ScreenMode.INTRO, "Resumed victory commits one generation")

func playthrough() -> void:
	# Deterministic strategy uses only buttons/actions available in the actual game.
	game.reset_full_dynasty()
	game.time_speed = 1.0
	ui.active_event = {}
	ui.show_intro_screen()
	seed(7401)
	ui.rng.seed = 7401
	ui.on_choice_pressed(1)
	ui.on_choice_pressed(1)
	ui.on_choice_pressed(1)
	var steps := 0
	while ui.current_mode != ui.ScreenMode.GAMEOVER and steps < 520:
		steps += 1
		if game.ad_cooldown == 0:
			ui.ad_btn.pressed.emit()
		var next_cost: float = game.BUSINESS_TIERS[mini(game.business_tier + 1, 5)]["cost"] if game.business_tier < 5 else 250000000.0 * game.business_scale
		if game.cash >= next_cost + game.get_quarterly_living_cost() * 2.0:
			ui.biz_btn.pressed.emit()
			ui.btn_1.pressed.emit()
			if ui.current_mode != ui.ScreenMode.GAMEOVER:
				ui.btn_3.pressed.emit()
		if ui.current_mode == ui.ScreenMode.GAMEOVER:
			break
		var option := 2
		if game.energy < 42 or game.stress > 50 or game.health < 45:
			option = 3
		else:
			var title: String = ui.active_event["title"]
			if "хакатон" in title or "нейросетей" in title or "фонд ищет" in title:
				option = 1
			if "Проблемы со здоровьем" in title:
				option = 3
			if "Антимонопольный" in title:
				option = 2
		[ui.btn_1, ui.btn_2, ui.btn_3][option - 1].pressed.emit()
	print("PLAYTHROUGH steps=", steps, " age=", game.age, " wealth=", game.get_net_worth(), " rank=", game.rank)
	check(game.rank == 1 and game.get_net_worth() >= 250000000000.0, "Ordinary gameplay reaches the Forbes victory before old age")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OS.get_environment("GAME_SCREENSHOT"))

func reopen_ui() -> void:
	ui.queue_free()
	await process_frame
	ui = load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	current_scene = ui
	await process_frame

func finish() -> void:
	print("RESULT: ", "PASS" if failures.is_empty() else "FAIL", " (", checks, " checks, ", failures.size(), " failures)")
	quit(0 if failures.is_empty() else 1)
