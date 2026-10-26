extends SceneTree
var failures:=0
func _initialize() -> void:call_deferred("run")
func check(ok:bool,message:String) -> void:
	if not ok:failures+=1;print("FAIL: ",message)
func run() -> void:
	await process_frame
	var fixture:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/canonical-model-copy.json"))
	var locale:Node=root.get_node("LocalizationManager")
	var game:Node=root.get_node("GameManager")
	for entry in fixture.entries:check(locale.source(entry.key)==entry.ru,"Canonical model source bytes: "+entry.key)
	var origins:Dictionary={}
	for language in ["ru","en"]:
		locale.set_language(language,false)
		for tier in 6:check(game.BUSINESS_TIERS[tier].name==fixture.entries[tier].ru,"Business read API preserves stable canonical names")
		for trial in 1000:
			seed(trial);game.reset_game()
			var birth:Dictionary=game.roll_birth_lottery()
			var known:=false
			for offset in [6,9,12,15]:
				if game.birth_origin==fixture.entries[offset].ru:
					known=true;origins[game.birth_origin]=true
					check(birth.title==fixture.entries[offset+1].ru and birth.desc==fixture.entries[offset+2].ru,"Birth title/description bytes and origin identity")
			check(known,"No untranslated or changed birth identity")
			if origins.size()==4:break
		check(origins.size()==4,"All four origins retain their identity")
		origins.clear()
	print("CANONICAL MODEL RESULT: ","PASS" if failures==0 else "FAIL")
	quit(0 if failures==0 else 1)
