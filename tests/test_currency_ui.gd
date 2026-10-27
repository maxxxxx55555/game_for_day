extends SceneTree
var failed := false
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	if not ok:
		failed = true
		print("FAIL: ", label)
func run() -> void:
	await process_frame
	var game: Node = root.get_node("GameManager")
	game.reset_full_dynasty()
	var screen: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(screen)
	current_scene = screen
	for i in 3: screen.btn_1.pressed.emit()
	game.cash = 1000
	var turns: int = game.total_turns
	var event: Dictionary = screen.active_event.duplicate(true)
	screen.market_btn.pressed.emit()
	screen.currency_button.pressed.emit()
	check(screen.currency_panel.visible, "The exchange opens through the real market button")
	var quotes: Dictionary = game.fx.rates.duplicate()
	screen.currency_panel.rows.EUR.buy.pressed.emit()
	check(game.cash == 750 and game.fx.holdings.EUR > 0, "Real exchange controls purchase a real wallet position")
	var saved: Dictionary = game.load_current_life()
	check(int(saved.get("mode", -1)) == screen.ScreenMode.CURRENCY, "Trading saves the exchange screen as well as the wallet")
	screen.currency_panel.closed.emit()
	screen.market_back.pressed.emit()
	check(game.total_turns == turns and screen.active_event == event and game.fx.rates == quotes, "Menu navigation neither spends time nor rerolls events or exchange quotes")
	check(game.fx.holdings.EUR > 0, "Returning to life keeps foreign holdings")
	screen.market_btn.pressed.emit()
	screen.currency_button.pressed.emit()
	screen.currency_panel.rows.EUR.sell.pressed.emit()
	check(game.cash > 990 and game.cash < 1000 and game.fx.holdings.EUR == 0, "The sell control liquidates the position with the displayed spread")
	await process_frame
	check(screen.currency_panel.get_global_rect().size == root.get_visible_rect().size, "The exchange covers the portrait viewport")
	print("CURRENCY UI RESULT: ", "FAIL" if failed else "PASS")
	if not await root.get_node("SoundManager").shutdown():
		quit(1)
		return
	quit(1 if failed else 0)
