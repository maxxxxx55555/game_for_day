extends SceneTree
var failures:=0
func _initialize() -> void:call_deferred("run")
func check(ok:bool,message:String) -> void:
    if not ok:failures+=1;print("FAIL: ",message)
func quiet(audio:Node) -> void:
    for p in audio.effect_players:p.stop()
func has_error(audio:Node) -> bool:
    for p in audio.effect_players:
        if p.playing and p.stream==audio._stream("ui_error"):return true
    return false
func run() -> void:
    await process_frame
    var audio:Node=root.get_node("SoundManager")
    var game:Node=root.get_node("GameManager")
    game.reset_full_dynasty()
    var screen:Control=load("res://scenes/Main.tscn").instantiate()
    root.add_child(screen)
    current_scene=screen
    for index in 3:screen.btn_1.pressed.emit()
    game.cash=0
    screen.open_market_menu()
    quiet(audio)
    screen.handle_market_action(1)
    check(has_error(audio),"Rejected stock purchase emits unavailable feedback")
    quiet(audio)
    screen.handle_market_action(2)
    check(has_error(audio),"Rejected crypto purchase emits unavailable feedback")
    screen.open_business_menu()
    quiet(audio)
    screen.handle_business_action(1)
    check(has_error(audio),"Rejected business upgrade emits unavailable feedback")
    quiet(audio)
    screen.handle_business_action(2)
    check(has_error(audio),"Unavailable optimization emits unavailable feedback")
    game.ad_cooldown=2
    quiet(audio)
    screen.watch_ad_for_bonus()
    check(has_error(audio),"Repeated cooldown award request emits unavailable feedback")
    check(game.cash==0,"Error feedback never mutates the ledger")
    screen.queue_free()
    print("CONTEXT AUDIO RESULT: ","PASS" if failures==0 else "FAIL")
    if not await root.get_node("SoundManager").shutdown():
        quit(1)
        return
    quit(0 if failures==0 else 1)
