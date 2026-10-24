extends SceneTree

var failed := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	if not ok:
		failed += 1
		print("FAIL: ", label)

func run() -> void:
	await process_frame
	var game: Node = root.get_node("GameManager")
	check(game.has_method("buy_currency") and game.has_method("sell_currency"), "Currency holdings must support real buy/sell operations")
	if failed:
		quit(1)
		return
	game.reset_full_dynasty()
	game.cash = 1000
	var turns: int = game.total_turns
	check(not game.buy_currency("XYZ", 100) and not game.buy_currency("EUR", -5) and not game.buy_currency("EUR", INF) and not game.buy_currency("EUR", NAN), "Unknown, negative and nonfinite currency orders are rejected")
	check(game.cash == 1000, "Rejected orders cannot consume cash")
	check(game.buy_currency("EUR", 100), "A real EUR purchase consumes available USD")
	var units: float = game.fx.holdings.EUR
	check(game.cash == 900 and units > 0, "Purchased foreign currency exists in the wallet")
	check(is_equal_approx(game.get_net_worth(), game.cash + units * game.fx.rates.EUR), "Foreign holdings count toward actual net worth")
	check(game.sell_currency("EUR", units) > 0 and game.cash < 1000, "An immediate round trip loses the disclosed spread instead of printing free money")
	check(game.total_turns == turns, "Currency trades cannot spend a quarter")
	game.cash = 1000
	game.fx.reset()
	game.buy_currency("GBP", 500)
	game.fx.rates.GBP *= 1.2
	game.sell_currency("GBP", game.fx.holdings.GBP)
	check(game.cash > 1090, "Selling a genuinely appreciated currency can earn money")
	game.buy_currency("JPY", 100)
	game.save_current_life({"mode": 3})
	var saved: Dictionary = game.fx.capture()
	game.advance_quarter_and_markets()
	var next_rates: Dictionary = game.fx.rates.duplicate()
	game.load_current_life()
	check(game.fx.capture() == saved, "Quotes, inventories, history and FX RNG survive save/load exactly")
	game.advance_quarter_and_markets()
	check(game.fx.rates == next_rates, "Reloading cannot reroll the next currency quotes")
	game.reset_game()
	check(game.fx.value() == 0, "A new life clears the previous currency wallet")
	game.cash = 1000
	var cost_before: float = game.get_quarterly_living_cost()
	var power_before: float = game.get_real_cash()
	game.inflation_multiplier *= 1.1
	check(game.get_quarterly_living_cost() > cost_before and game.get_real_cash() < power_before, "Inflation raises real living costs and reduces idle cash purchasing power")
	check(game.get_annual_inflation() > 0, "The interface can show an actual annualized inflation rate")
	game.reset_game()
	game.age = 55
	game.cash = 5000
	game.buy_currency("EUR", 2000)
	var inheritance: float = snappedf(game.get_net_worth() * 0.2, 1)
	game.register_inheritance_on_end()
	check(game.inherited_capital == inheritance, "Foreign currency value is included in the dynasty inheritance")
	print("CURRENCY AND INFLATION RESULT: ", "PASS" if failed == 0 else "FAIL")
	quit(0 if failed == 0 else 1)
