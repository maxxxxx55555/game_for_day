extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		print("FAIL: ",label)
func run() -> void:
	await process_frame
	var game: Node = root.get_node("GameManager")
	game.reset_full_dynasty()
	game.cash = 1000
	check(not game.buy_stocks(NAN) and game.cash == 1000,"Nonfinite stock orders cannot poison cash or grant holdings")
	game.reset_game()
	game.cash = 1000
	check(not game.buy_crypto(NAN) and game.cash == 1000,"Nonfinite crypto orders cannot poison cash")
	print("INTEGRITY BOUNDARY RESULT: ","PASS" if failures == 0 else "FAIL")
	quit(0 if failures == 0 else 1)
