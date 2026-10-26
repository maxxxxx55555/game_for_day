extends SceneTree
var failures:int=0
var game:Node
var screen:Control
func _initialize()->void:call_deferred("run")
func check(ok:bool,label:String)->void:
    if not ok:failures+=1;print("FAIL: ",label)
func model()->Dictionary:
    var snapshot:Dictionary={}
    for field:String in game.RUN_FIELDS:snapshot[field]=game.get(field)
    return snapshot
func digest(value:Variant)->String:return JSON.stringify(value,"",true,true).sha256_text()
func narrative(event:Dictionary)->Dictionary:
    var fields:Dictionary={}
    for key:String in event:
        if not event[key] is Callable:fields[key]=event[key]
    return fields
func run()->void:
    await process_frame
    game=root.get_node("GameManager")
    game.reset_full_dynasty()
    screen=load("res://scenes/Main.tscn").instantiate();root.add_child(screen);current_scene=screen
    screen.show_intro_screen()
    for index:int in 3:screen.btn_1.pressed.emit()
    game.cash=50000
    check(game.buy_stocks(1000) and game.buy_crypto(500) and game.buy_currency("EUR",400),"Complete profile includes three real investment positions")
    check(game.upgrade_or_scale_business().get("ok",false),"Complete profile includes a paid business upgrade")
    game.advance_quarter_and_markets()
    check(game.claim_grant()>0,"Complete profile includes a monotonic grant and inflation tick")
    var before:Dictionary=model()
    var before_hash:String=digest(before)
    var event:Dictionary=screen.active_event.duplicate(true)
    var rng_state:int=screen.rng.state
    screen._notification(MainLoop.NOTIFICATION_APPLICATION_PAUSED)
    check(digest(model())==before_hash,"Background notification cannot advance any saved life mechanic")
    for language:String in ["en","ru"]:
        root.get_node("LocalizationManager").set_language(language)
        for attempt:int in 5:
            for method:String in ["open_market_menu","open_currency_menu","open_business_menu","open_settings_menu"]:
                screen.call(method)
                screen._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
                check(digest(model())==before_hash and screen.active_event==event and screen.rng.state==rng_state,"Rapid menu and Back traversal preserves the complete model and pending choice: "+language+" "+method)
    check(screen.save_session(),"Save the complete model through the actual UI")
    screen.queue_free();await process_frame
    game.cash=1;game.stock_units=0;game.crypto_units=0;game.business_tier=0
    screen=load("res://scenes/Main.tscn").instantiate();root.add_child(screen);current_scene=screen
    await process_frame
    var after:Dictionary=model()
    for field:String in game.RUN_FIELDS:
        check(digest(before[field])==digest(after[field]),"Profile state hash round trip: "+field)
    check(digest(narrative(screen.active_event))==digest(narrative(event)) and screen.rng.state==rng_state,"Restart preserves the exact pending narrative and RNG")
    for action:String in ["r1","r2","r3"]:
        var callback:Callable=screen.active_event.get(action,Callable())
        check(callback.is_valid(),"Restored event owns a live choice callback: "+action)
    screen.queue_free();await process_frame
    var audio:Node=root.get_node("SoundManager")
    if audio.crossfade!=null:audio.crossfade.kill()
    for voice:Node in audio.effect_players+audio.music_players:voice.stop();voice.stream=null
    if is_instance_valid(audio.finale_player):audio.finale_player.stop();audio.finale_player.stream=null
    audio.current_music="";audio.music_index=-1;audio.streams.clear()
    await create_timer(0.3).timeout
    for frame:int in 10:await process_frame
    print("PROFILE CONTRACT RESULT: ","PASS" if failures==0 else "FAIL")
    quit(0 if failures==0 else 1)
