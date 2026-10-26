extends SceneTree
var failures:=0
func _initialize() -> void: call_deferred("run")
func check(ok:bool,message:String) -> void:
	if not ok:
		failures+=1
		print("FAIL: ",message)
func run() -> void:
	await process_frame
	var locale:Node=root.get_node_or_null("LocalizationManager")
	check(locale!=null,"Bilingual catalog is available in the real game")
	if locale==null:
		quit(1)
		return
	for key in locale.translations:
		var row:Dictionary=locale.translations[key]
		check(not str(row.get("ru","")).is_empty() and not str(row.get("en","")).is_empty(),"Both languages contain "+key)
	var screen:Control=load("res://scenes/Main.tscn").instantiate()
	root.add_child(screen)
	current_scene=screen
	var game:Node=root.get_node("GameManager")
	game.reset_full_dynasty()
	screen.show_intro_screen()
	for i in 3: screen.on_choice_pressed(1)
	var before:Dictionary=game.fx.capture()
	var turn:int=game.total_turns
	var money:float=game.cash
	var rng_state:int=screen.rng.state
	var event:Dictionary=screen.active_event.duplicate()
	locale.set_language("en")
	await process_frame
	check(locale.display("Рынки")=="Markets","English interface is fully translated")
	check("Quarter" in locale.display("22 лет · квартал 4 · поколение 1"),"Formatted dashboard templates translate")
	check(locale.display(screen.active_event.title)!=screen.active_event.title,"Current event translates without changing its identity")
	check(screen.active_event==event and game.total_turns==turn and game.cash==money and screen.rng.state==rng_state and game.fx.capture()==before,"Language switch preserves live event, balances, turn and both RNG states")
	locale.set_language("ru")
	check(locale.display("Рынки")=="Рынки","Russian display returns without changing canonical source")
	locale.set_language("en")
	var qa_language:=OS.get_environment("GAME_LANGUAGE")
	OS.set_environment("GAME_LANGUAGE","")
	locale.load_settings()
	check(locale.current_language=="en","Explicit language survives a settings reload")
	OS.set_environment("GAME_LANGUAGE",qa_language)
	for field in ["master_volume","music_volume","sfx_volume","ui_volume"]:
		check(field in game,"Four sound levels exist: "+field)
	var font:Font=load("res://assets/fonts/Onest.ttf")
	for letter in "ёЁ«»—·×$€£¥":check(font.has_char(letter.unicode_at(0)),"Body font covers "+letter)

	var heading_font:Font=load("res://assets/fonts/Prata-Regular.ttf")
	for letter in "ёЁ«»—·×$€£¥":check(heading_font.has_char(letter.unicode_at(0)),"Heading font covers "+letter)
	print("LOCALIZATION RESULT: ","PASS" if failures==0 else "FAIL"," keys=",locale.translations.size())
	quit(0 if failures==0 else 1)
