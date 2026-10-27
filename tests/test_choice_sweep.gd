extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	await process_frame
	var screen:Control=load("res://scenes/Main.tscn").instantiate()
	root.add_child(screen)
	current_scene=screen
	root.get_node("GameManager").reset_full_dynasty()
	screen.show_intro_screen()
	for i in 3: screen.on_choice_pressed(1)
	var locale:Node=root.get_node("LocalizationManager")
	var choice_copy=load("res://scripts/ui/ChoiceCopy.gd")
	var count:=0
	var failures:=0
	for event in screen.get_survival_events()+screen.get_career_events()+screen.get_millionaire_events()+screen.get_billionaire_events(1000000000):
		screen.active_event=event
		screen.load_next_life_event("",true)
		for i in 4: await process_frame
		for button in [screen.btn_1,screen.btn_2,screen.btn_3]:
			count+=1
			var copy:Dictionary=choice_copy.parts(button.text)
			if str(copy.title).strip_edges().is_empty():failures+=1;print("FAIL: Empty action title")
			if locale.current_language=="en":
				var letters:=RegEx.new();letters.compile("[А-Яа-яЁё]")
				for field in ["title","detail"]:
					if letters.search(locale.display(copy[field])):
						failures+=1;print("FAIL: Untranslated choice ",field,": ",copy[field])
			var rect:Rect2=button.get_global_rect()
			if not root.get_visible_rect().encloses(rect):
				failures+=1
				print("FAIL: Offscreen choice: ",button.text," ",rect," viewport=",root.get_visible_rect())
				if DisplayServer.get_name()!="headless":
					await RenderingServer.frame_post_draw
					root.get_texture().get_image().save_png(OS.get_environment("GAME_SCREENSHOT").replace(".png","-overflow-"+str(count)+".png"))
			for name in ["ActionTitle","ActionDetail"]:
				var label:=button.find_child(name,true,false) as Label
				if label.visible and not rect.grow(1).encloses(label.get_global_rect()):
					failures+=1
					print("FAIL: Clipped choice information: ",button.text," ",rect," ",label.get_global_rect())
	print("CHOICE SWEEP RESULT: ","PASS" if failures==0 else "FAIL"," choices=",count)
	if not await root.get_node("SoundManager").shutdown():
		quit(1)
		return
	quit(0 if failures==0 else 1)
