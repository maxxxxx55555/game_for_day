extends SceneTree
const Guard=preload("res://scripts/security/SaveGuard.gd")
var failures:=0
func _initialize() -> void:call_deferred("run")
func check(ok:bool,message:String) -> void:
    if not ok:failures+=1;print("FAIL: ",message)
func put(path:String,text:String) -> void:
    var f:=FileAccess.open(path,FileAccess.WRITE);f.store_string(text);f.close()
func run() -> void:
    await process_frame
    var game:Node=root.get_node("GameManager")
    var boundary:Node=root.get_node("BuildIntegrity")
    game.cash=1234.56
    check(game.save_current_life({"mode":3}),"Save legitimate state")
    var before:=Guard.bounded_text(game.SESSION_PATH)
    check(not game.load_current_life().is_empty(),"Load legitimate state")
    check(game.save_current_life({"mode":3}),"Save loaded state again")
    check(before==Guard.bounded_text(game.SESSION_PATH),"Save-load-save hash remains byte stable")
    game.cash=2000
    check(game.save_current_life({"mode":3}),"Next state preserves known-good backup")
    put(game.SESSION_PATH,Guard.bounded_text(game.SESSION_PATH).replace("mac=", "bad_mac="))
    check(not game.load_current_life().is_empty() and game.cash==1234.56,"Tamper falls back to known-good save")
    check("integrity.save_recovered" in boundary.pending_notices,"Backup recovery has localized feedback")
    check("integrity.save_recovered" in Guard.bounded_text(boundary.LOG_PATH),"Backup recovery logged without signature material")
    before=Guard.bounded_text(game.SESSION_PATH)
    var backup:=Guard.bounded_text(game.SESSION_PATH+".bak")
    boundary.read_only=true
    check(not game.load_current_life().is_empty(),"Safe mode can read authentic progress")
    check(not game.save_current_life({"mode":3}),"Safe mode rejects progress writes")
    game.clear_current_life()
    check(before==Guard.bounded_text(game.SESSION_PATH) and backup==Guard.bounded_text(game.SESSION_PATH+".bak"),"Safe mode cannot mutate or delete primary or backup")
    boundary.read_only=false
    print("SAVE RECOVERY RESULT: ","PASS" if failures==0 else "FAIL")
    if not await root.get_node("SoundManager").shutdown():
        quit(1)
        return
    quit(0 if failures==0 else 1)
