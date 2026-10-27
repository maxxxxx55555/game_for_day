extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,label: String) -> void:
	if not ok:
		failures+=1
		print("FAIL: ",label)
func run() -> void:
	await process_frame
	var screen: Control = load("res://scenes/Main.tscn").instantiate()
	root.add_child(screen)
	current_scene = screen
	await process_frame
	var body := screen.get_theme_default_font()
	check(body.has_char(0x042f) and body.has_char(0x0436),"Body typography supports Cyrillic without missing glyphs")
	check("Onest" in str(body.resource_path) or (body is FontVariation and "Onest" in body.base_font.resource_path),"Financial interface has its new readable type family")
	for state in ["normal","hover","pressed","disabled"]:
		check(screen.btn_1.get_theme_stylebox(state) is StyleBoxTexture,"Button has an authored scalable "+state+" surface")
	check(screen.btn_1.get_theme_stylebox("normal")!=screen.btn_1.get_theme_stylebox("pressed"),"Press has a visible distinct surface")
	screen.btn_1.grab_focus()
	await process_frame
	check(screen.btn_1.has_focus(),"Primary action remains keyboard focusable")
	var focus: StyleBox = screen.btn_1.get_theme_stylebox("focus")
	check(focus is StyleBoxFlat and focus.border_width_left>=2,"Keyboard focus remains clearly visible")
	check(screen.dashboard.has_method("portrait_stage"),"Dashboard presents a life-stage portrait")
	if screen.dashboard.has_method("portrait_stage"):
		check(screen.dashboard.portrait_stage(20)!=screen.dashboard.portrait_stage(75),"Portrait changes with age, not the game balance")
	var game: Node = root.get_node("GameManager")
	game.reset_full_dynasty()
	screen.show_intro_screen()
	for choice in 3: screen.on_choice_pressed(1)
	await process_frame
	var bounds := root.get_visible_rect()
	for button in [screen.btn_1,screen.btn_2,screen.btn_3,screen.market_btn,screen.settings_btn]:
		check(bounds.encloses(button.get_global_rect()),"Visible action stays inside the screen: "+button.name)
		check(button.get_global_rect().size.y>=40,"Touch action retains a usable hit target: "+button.name)
	if DisplayServer.get_name()!="headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OS.get_environment("GAME_SCREENSHOT").replace(".png","-premium.png"))
	print("PREMIUM UI RESULT: ","PASS" if failures==0 else "FAIL")
	if not await root.get_node("SoundManager").shutdown():
		quit(1)
		return
	quit(0 if failures==0 else 1)
