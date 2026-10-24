extends SceneTree
var failed := false
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	if not ok:
		failed = true
		print("FAIL: ",label)
func shot(suffix: String) -> void:
	if DisplayServer.get_name()=="headless": return
	await create_timer(0.8).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OS.get_environment("GAME_SCREENSHOT").replace(".png","-"+suffix+".png"))
func run() -> void:
	await process_frame
	var game: Node = root.get_node("GameManager")
	game.reset_full_dynasty()
	var screen: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(screen)
	current_scene = screen
	if not screen.has_method("show_finale"):
		print("FAIL: Outcomes need their own responsive finale scene")
		quit(1)
		return
	game.age = 56
	game.cash = 250000000000.0
	game.recalculate_forbes_rank()
	var generation: int = game.generation
	check(screen.check_game_over() and screen.finale_overlay.visible,"Winning opens the dedicated finale")
	check(game.generation==generation,"Showing the finale does not award inheritance twice")
	var saved: Dictionary = game.load_current_life()
	screen.restore_session(saved)
	check(screen.final_victory and screen.finale_overlay.visible and game.generation==generation,"Restarting restores the same ending without changing dynasty")
	await shot("victory-finale")
	for button in [screen.finale_overlay.primary,screen.finale_overlay.secondary]:
		if button.visible: check(button.get_global_rect().end.y<=root.get_visible_rect().size.y+1,"Finale actions remain inside the portrait viewport")
	screen.finale_overlay.primary.pressed.emit()
	check(game.generation==generation+1 and not screen.finale_overlay.visible,"Next generation delegates to existing inheritance exactly once")
	game.reset_game()
	game.age = 40
	game.health = 0
	check(screen.check_game_over() and screen.can_revive and screen.finale_overlay.visible,"Defeat has its own finale and the legitimate revive action")
	await shot("defeat-finale")
	screen.finale_overlay.primary.pressed.emit()
	check(game.revive_used and game.health>=55 and not screen.finale_overlay.visible,"Revive works from the finale without trapping the player")
	game.health = 0
	screen.check_game_over()
	check(not screen.can_revive and not screen.finale_overlay.secondary.visible,"A second defeat cannot grant another revive")
	print("FINALE SCENES RESULT: ","FAIL" if failed else "PASS")
	quit(1 if failed else 0)
