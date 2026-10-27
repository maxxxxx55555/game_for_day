extends SceneTree
var failures:=0
var seen:Dictionary={}
func _initialize() -> void:call_deferred("run")
func inspect(node:Node) -> void:
	if node is Label or node is Button:
		if (node as Control).is_visible_in_tree() and not node is OptionButton:
			var raw:String=node.text
			if not seen.has(raw):
				seen[raw]=true
				var rendered:String=root.get_node("LocalizationManager").display(raw)
				var regex:=RegEx.new()
				regex.compile("[А-Яа-яЁё]")
				if regex.search(rendered):
					failures+=1
					print("FAIL: Untranslated visible copy: ",JSON.stringify(raw)," => ",JSON.stringify(rendered))
	for child in node.get_children():inspect(child)
func run() -> void:
	await process_frame
	root.get_node("LocalizationManager").set_language("en",false)
	var ui:Control=load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	current_scene=ui
	var game:Node=root.get_node("GameManager")
	game.reset_full_dynasty()
	ui.show_intro_screen()
	await process_frame
	inspect(ui)
	ui.show_birth_screen()
	await process_frame
	inspect(ui)
	ui.show_perk_screen()
	await process_frame
	inspect(ui)
	for event in ui.get_survival_events()+ui.get_career_events()+ui.get_millionaire_events()+ui.get_billionaire_events(1000000000):
		ui.active_event=event
		ui.load_next_life_event("",true)
		await process_frame
		inspect(ui)
	for tier in 6:
		game.business_tier=tier
		ui.open_business_menu()
		await process_frame
		inspect(ui)
	ui.open_market_menu()
	await process_frame
	inspect(ui)
	ui.open_currency_menu()
	await process_frame
	inspect(ui)
	ui.open_settings_menu()
	await process_frame
	inspect(ui)
	ui.trigger_game_over("",true)
	await process_frame
	inspect(ui)
	print("TRANSLATION COVERAGE RESULT: ","PASS" if failures==0 else "FAIL"," visible strings=",seen.size())
	if not await root.get_node("SoundManager").shutdown():
		quit(1)
		return
	quit(0 if failures==0 else 1)
