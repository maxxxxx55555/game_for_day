extends SceneTree
var failures:=0
func _initialize() -> void: call_deferred("run")
func check(ok:bool,message:String) -> void:
	if not ok:
		failures+=1
		print("FAIL: ",message)
func run() -> void:
	await process_frame
	var screen:Control=load("res://scenes/Main.tscn").instantiate()
	root.add_child(screen)
	current_scene=screen
	var game:Node=root.get_node("GameManager")
	game.reset_full_dynasty()
	screen.show_intro_screen()
	for i in 3: screen.on_choice_pressed(1)
	screen.active_event=screen.get_survival_events()[1]
	screen.load_next_life_event("Предыдущий результат: работа принесла доход.",true)
	for i in 3: await process_frame
	check(screen.event_label.text==screen.active_event.title,"Current decision is not buried under the previous outcome")
	var title:=screen.btn_1.find_child("ActionTitle",true,false) as Label
	var detail:=screen.btn_1.find_child("ActionDetail",true,false) as Label
	check(title!=null and detail!=null,"A real choice separates its action from the consequence line")
	if title and detail:
		check(title.text.length()<45,"Risk decision has a short readable action label")
		check("65%" in detail.text and "2,800" in detail.text,"Compacting never hides the actual chance or payout")
		check(root.get_visible_rect().encloses(title.get_global_rect()) and root.get_visible_rect().encloses(detail.get_global_rect()),"Action and consequence both remain within the viewport")
		check(screen.btn_1.get_global_rect().encloses(detail.get_global_rect()),"Effects stay inside their native button hit target")
	check("800" in screen.btn_1.text and "65%" in screen.btn_1.text,"Full native accessible choice text is preserved")
	var turn:int=game.total_turns
	screen.btn_2.grab_focus()
	screen.btn_2.pressed.emit()
	check(game.total_turns==turn+1,"The original visible action still consumes exactly one normal quarter")
	for i in 3: await process_frame
	for button in [screen.btn_1,screen.btn_2,screen.btn_3,screen.market_btn,screen.settings_btn]:
		check(root.get_visible_rect().encloses(button.get_global_rect()),"Choice/navigation remains in portrait bounds: "+button.name)
	if DisplayServer.get_name()!="headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OS.get_environment("GAME_SCREENSHOT").replace(".png","-clear-play.png"))
	print("CLEAR PLAY RESULT: ","PASS" if failures==0 else "FAIL")
	if not await root.get_node("SoundManager").shutdown():
		quit(1)
		return
	quit(0 if failures==0 else 1)
