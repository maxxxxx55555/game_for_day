extends SceneTree
const Countries=preload("res://scripts/BirthCountries.gd")
var failures:int=0
func _initialize()->void:call_deferred("run")
func check(ok:bool,message:String)->void:
    if not ok:failures+=1;print("FAIL: ",message)
func run()->void:
    await process_frame
    var game:Node=root.get_node("GameManager")
    var locale:Node=root.get_node("LocalizationManager")
    game.reset_full_dynasty()
    var screen:Control=load("res://scenes/Main.tscn").instantiate()
    root.add_child(screen);current_scene=screen
    screen.show_birth_screen()
    var card:Control=screen.birth_reveal
    for language:String in ["en","ru","en"]:
        locale.set_language(language,false)
        game.birth_country_code="IND"
        card.country=locale.source("country.ind.name")
        var expected:String="India" if language=="en" else "Индия"
        check(card.country_label()==expected and screen.dashboard.birthplace()==expected,"Live country name follows display locale in both card and dashboard: "+language)
        for row:Array in Countries.COUNTRIES:
            card.country=locale.source("country.%s.name"%str(row[0]).to_lower())
            var width:float=card.display_font.get_string_size(card.country_label(),HORIZONTAL_ALIGNMENT_LEFT,-1,card.country_font_size()).x
            check(width<=620.0,"Full country title fits the birth card: "+str(row[0])+" "+language)
    screen.queue_free();await process_frame
    print("BIRTH LOCALE RESULT: ","PASS" if failures==0 else "FAIL")
    if not await root.get_node("SoundManager").shutdown():quit(1);return
    quit(0 if failures==0 else 1)
