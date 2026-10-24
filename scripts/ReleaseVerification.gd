extends Node

func capture(suffix: String) -> void:
	if OS.get_environment("GAME_CAPTURE_GALLERY") != "1" or DisplayServer.get_name() == "headless": return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(OS.get_environment("GAME_SCREENSHOT").replace(".png", "-" + suffix + ".png"))

# Opt-in QA route for the shipped pack. Run only with an isolated save profile.
func run(ui: Control) -> void:
	await get_tree().process_frame
	GameManager.reset_full_dynasty()
	GameManager.time_speed = 1.0
	ui.active_event = {}
	ui.show_intro_screen()
	seed(7401)
	ui.rng.seed = 7401
	await capture("title")
	for index in 3: ui.btn_1.pressed.emit()
	await capture("life")
	if OS.get_cmdline_user_args().has("--defeat"):
		await verify_defeat(ui)
		return
	var steps := 0
	while ui.current_mode != ui.ScreenMode.GAMEOVER and steps < 520:
		steps += 1
		if steps == 20 and OS.get_environment("GAME_CAPTURE_GALLERY") == "1":
			ui.market_btn.pressed.emit()
			await capture("portfolio")
			ui.currency_button.pressed.emit()
			if GameManager.cash > 0:
				ui.currency_panel.rows.EUR.buy.pressed.emit()
			await capture("currencies")
			ui.currency_panel.rows.EUR.sell.pressed.emit()
			ui.currency_panel.closed.emit()
			ui.market_back.pressed.emit()
			ui.biz_btn.pressed.emit()
			await capture("business")
			ui.btn_3.pressed.emit()
		if GameManager.ad_cooldown == 0: ui.ad_btn.pressed.emit()
		var cost: float = GameManager.BUSINESS_TIERS[mini(GameManager.business_tier + 1, 5)].cost if GameManager.business_tier < 5 else 250000000.0 * GameManager.business_scale
		if GameManager.cash >= cost + GameManager.get_quarterly_living_cost() * 2:
			ui.biz_btn.pressed.emit()
			ui.btn_1.pressed.emit()
			if ui.current_mode != ui.ScreenMode.GAMEOVER: ui.btn_3.pressed.emit()
		if ui.current_mode == ui.ScreenMode.GAMEOVER: break
		var option := 2
		if GameManager.energy < 42 or GameManager.stress > 50 or GameManager.health < 45:
			option = 3
		else:
			var title: String = ui.active_event.title
			if "хакатон" in title or "нейросетей" in title or "фонд ищет" in title: option = 1
			if "Проблемы со здоровьем" in title: option = 3
			if "Антимонопольный" in title: option = 2
		[ui.btn_1, ui.btn_2, ui.btn_3][option - 1].pressed.emit()
		if steps % 10 == 0: await get_tree().process_frame
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless" and not OS.get_environment("GAME_SCREENSHOT").is_empty():
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(OS.get_environment("GAME_SCREENSHOT"))
	var success: bool = GameManager.rank == 1 and ui.final_victory and GameManager.get_net_worth() >= 250000000000.0
	print("EXPORTED PLAYTHROUGH: ", "PASS" if success else "FAIL", " steps=", steps, " rank=", GameManager.rank, " wealth=", GameManager.get_net_worth())
	get_tree().quit(0 if success else 1)

func verify_defeat(ui: Control) -> void:
	var steps:=0
	# Only ordinary event buttons drive this loss route; no stats are assigned.
	while ui.current_mode != ui.ScreenMode.GAMEOVER and steps<520:
		ui.btn_1.pressed.emit()
		steps+=1
		if steps%10==0: await get_tree().process_frame
	await get_tree().create_timer(0.8).timeout
	await capture("defeat")
	var success: bool=ui.current_mode==ui.ScreenMode.GAMEOVER and not ui.final_victory and ui.finale_overlay.visible
	var had_revive: bool=ui.can_revive
	if had_revive:
		ui.finale_overlay.primary.pressed.emit()
		success=success and GameManager.revive_used and ui.current_mode!=ui.ScreenMode.GAMEOVER
		while ui.current_mode != ui.ScreenMode.GAMEOVER and steps<1040:
			ui.btn_1.pressed.emit()
			steps+=1
			if steps%10==0: await get_tree().process_frame
		success=success and not ui.can_revive and not ui.final_victory
	var generation: int=GameManager.generation
	ui.finale_overlay.primary.pressed.emit()
	success=success and GameManager.generation==generation+1 and ui.current_mode==ui.ScreenMode.INTRO
	print("EXPORTED DEFEAT ROUTE: ","PASS" if success else "FAIL"," steps=",steps," revive=",had_revive)
	get_tree().quit(0 if success else 1)
