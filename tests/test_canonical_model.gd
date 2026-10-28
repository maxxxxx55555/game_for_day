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
	var codes:Dictionary={}
	for language in ["ru","en"]:
		locale.set_language(language,false)
		for tier in 6:check(game.BUSINESS_TIERS[tier].name==fixture.entries[tier].ru,"Business read API preserves stable canonical names")
		for trial in 400:
			seed(trial);game.reset_game()
			var birth:Dictionary=game.roll_birth_lottery()
			var code:String=game.birth_country_code
			var title:String=str(birth.get("title",""))
			check(not code.is_empty(),"Every draw names a country")
			check(title!="country.%s.name"%code.to_lower(),"Birthplace name is translated, not a raw key")
			check(not title.is_empty(),"Birthplace has a display name")
			check(game.death_age>=70 and game.death_age<=88,"Lifespan stays inside the bounded range")
			codes[code]=true
		check(codes.size()>60,"The lottery spans the world instead of four buckets")
		codes.clear()
	seed(11);game.reset_game()
	var first:String=str(game.roll_birth_lottery().get("code",""))
	seed(11);game.reset_game()
	var second:String=str(game.roll_birth_lottery().get("code",""))
	check(first==second and not first.is_empty(),"The same seed reproduces the same birthplace")
	print("CANONICAL MODEL RESULT: ","PASS" if failures==0 else "FAIL")
	if not await root.get_node("SoundManager").shutdown():
		quit(1)
		return
	quit(0 if failures==0 else 1)
