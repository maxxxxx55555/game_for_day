extends SceneTree
var failures:int=0
var screens:int=0
func _initialize()->void:call_deferred("run")
func check(ok:bool,label:String)->void:
	if not ok:failures+=1;print("FAIL: ",label)

func key(code:Key)->void:
	var event:InputEventKey=InputEventKey.new()
	event.keycode=code;event.physical_keycode=code;event.pressed=true
	Input.parse_input_event(event)
	await process_frame
	event=InputEventKey.new();event.keycode=code;event.physical_keycode=code;event.pressed=false
	Input.parse_input_event(event)
	await process_frame
func visit(panel:Control,label:String)->void:
	await process_frame;await process_frame
	var controls:Array=panel.find_children("*","BaseButton",true,false).filter(func(c:BaseButton)->bool:return c.is_visible_in_tree() and not c.disabled and c.focus_mode!=Control.FOCUS_NONE)
	check(not controls.is_empty(),label+" has a keyboard action")
	if controls.is_empty():return
	controls[0].grab_focus()
	for index:int in mini(controls.size()+2,30):
		await key(KEY_TAB)
		var owner:Control=root.gui_get_focus_owner()
		check(owner!=null and owner.is_visible_in_tree(),label+" Tab retains a visible focus target")
		if owner:check(root.get_visible_rect().encloses(owner.get_global_rect()),label+" focused control stays inside viewport: "+str(owner.name))
	for control:BaseButton in panel.find_children("*","BaseButton",true,false):
		if control.is_visible_in_tree() and control.disabled:check(not control.tooltip_text.is_empty(),label+" disabled action explains its requirement")

func run()->void:
	await process_frame
	var game:Node=root.get_node("GameManager")
	var ui:Control=load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui);current_scene=ui
	game.reset_full_dynasty();ui.show_intro_screen()
	await visit(ui,"Intro")
	ui.btn_1.pressed.emit();await visit(ui,"Birth")
	ui.btn_1.pressed.emit();await visit(ui,"Perk")
	ui.btn_1.pressed.emit()
	var event:Dictionary=ui.active_event.duplicate(true)
	var turn:int=game.total_turns
	for language:String in ["en","ru"]:
		root.get_node("LocalizationManager").set_language(language)
		await visit(ui,"Life "+language)
		for method:String in ["open_market_menu","open_business_menu","open_settings_menu"]:
			ui.call(method)
			await visit(ui,method+" "+language)
			await key(KEY_ESCAPE)
			check(ui.current_mode==ui.ScreenMode.LIFE,method+" Escape returns to life")
			check(ui.active_event==event and game.total_turns==turn,method+" preserves pending event and time")
			screens+=1
		ui.open_market_menu();ui.currency_button.pressed.emit()
		await visit(ui.currency_panel,"Currency "+language)
		await key(KEY_ESCAPE)
		check(ui.current_mode==ui.ScreenMode.LIFE,"Currency Escape returns to life")
		ui.open_credits()
		await visit(ui.credits_panel,"Credits "+language)
		await key(KEY_ESCAPE)
		check(not is_instance_valid(ui.credits_panel),"Credits Escape returns to current screen")
		screens+=2
		if DisplayServer.get_name()!="headless":
			DisplayServer.window_set_size(Vector2i(720,1280))
			await process_frame;await process_frame
			DisplayServer.window_set_size(Vector2i(540,960))
			await process_frame;await process_frame
	ui.queue_free();await process_frame
	print("NAVIGATION MATRIX RESULT: ","PASS" if failures==0 else "FAIL"," screens=",screens)
	if not await root.get_node("SoundManager").shutdown():
		quit(1)
		return
	quit(0 if failures==0 else 1)
