extends SceneTree
const Policy=preload("res://scripts/security/FortuneSavePolicy.gd")
const Guard=preload("res://scripts/security/SaveGuard.gd")
var failures:int=0
func _initialize()->void:call_deferred("run")
func check(ok:bool,message:String)->void:
    if not ok:failures+=1;print("FAIL: ",message)
func run()->void:
    await process_frame
    var game:Node=root.get_node("GameManager")
    game.reset_full_dynasty()
    game.roll_birth_lottery()
    check(game.save_current_life({"mode":1}),"Current birth profile saves")
    var original:ConfigFile=Guard.config_candidate(game.SESSION_PATH,"fortune/session")
    check(original!=null and Policy.session(original),"Current birth profile validates")
    for entry:Array in [["birth_country_code",{}],["birth_country_code","ZZZ"],["birth_opportunity",{}],["birth_opportunity",-1.0],["birth_opportunity",2.0],["birth_opportunity",NAN],["death_age",{}],["death_age",0],["death_age",89],["death_age",80.5]]:
        var candidate:ConfigFile=ConfigFile.new()
        candidate.parse(original.encode_to_text())
        candidate.set_value("run",entry[0],entry[1])
        check(not Policy.session(candidate),"Reject malformed birth field before typed assignment: "+str(entry[0])+" "+str(entry[1]))
    var legacy:ConfigFile=ConfigFile.new()
    legacy.parse(original.encode_to_text())
    for field:String in ["birth_country_code","birth_opportunity","death_age"]:legacy.erase_section_key("run",field)
    check(Policy.session(legacy),"Profiles predating country fields remain valid")
    check(Guard.write_config(game.SESSION_PATH,legacy,"fortune/session",Policy.session),"Write a valid older profile through guarded persistence")
    game.birth_country_code="USA";game.birth_opportunity=1.55;game.death_age=88
    check(not game.load_current_life().is_empty(),"Older profile restores")
    check(game.birth_country_code=="" and game.birth_opportunity==1.0 and game.death_age==82,"Older profile uses neutral historical defaults, never a previous life's country")
    print("BIRTH SAVE CONTRACT RESULT: ","PASS" if failures==0 else "FAIL")
    if not await root.get_node("SoundManager").shutdown():quit(1);return
    quit(0 if failures==0 else 1)
