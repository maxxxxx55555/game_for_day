extends SceneTree
var failures:int=0
func _initialize()->void:call_deferred("run")
func check(ok:bool,label:String)->void:
    if not ok:failures+=1;print("FAIL: ",label)
func run()->void:
    await process_frame
    var game:Node=root.get_node("GameManager")
    game.reset_full_dynasty();game.cash=100000
    for market:String in ["stocks","crypto"]:
        var purchase:String="buy_"+market
        var sell:String="sell_all_"+market
        var before:int=game.cash_cents
        for click:int in 20:check(game.call(purchase,1.0),"Twenty real one-dollar purchases: "+market)
        check(game.cash_cents==before-2000,"Each accepted purchase debits exactly once: "+market)
        check(game.call(sell)>0,"Actual holdings can be liquidated: "+market)
        before=game.cash_cents
        for click:int in 20:check(game.call(sell)==0,"Repeated empty liquidation cannot duplicate payment: "+market)
        check(game.cash_cents==before,"Empty liquidation leaves the ledger unchanged: "+market)
    game.reset_game();game.cash=100000
    var steps:int=0
    for click:int in 20:
        var prior:int=game.cash_cents
        var tier:int=game.business_tier
        var result:Dictionary=game.upgrade_or_scale_business()
        if result.ok:steps+=1;check(game.cash_cents<prior,"Every accepted business upgrade is paid")
        else:check(game.cash_cents==prior and game.business_tier==tier,"Rejected business upgrades are atomic")
    check(steps>0 and game.business_tier>0,"Rapid business input advances through genuine affordable tiers")
    game.business_tier=5;game.business_scale=16384;game.cash=9000000000000.0
    var before:int=game.cash_cents
    for click:int in 20:check(not game.upgrade_or_scale_business().ok,"Business scale cap cannot overflow on repeat input")
    check(game.cash_cents==before and game.business_scale==16384,"Scale cap rejection preserves cash and company")
    game.reset_game();game.cash=10000
    for speed:float in [0.5,1.0,2.0]:
        game.time_speed=speed
        var tick:int=game.simulation_ticks
        var inflation:float=game.inflation_multiplier
        for click:int in 5:game.advance_quarter_and_markets()
        check(game.simulation_ticks==tick+roundi(speed*2.0)*5,"Separate quarter actions advance exact monotonic ticks")
        check(game.inflation_multiplier>inflation and game.get_real_cash()<game.cash,"Inflation persists through repeated calendar actions")
    game.reset_game();game.cash=50000
    var grants:int=0
    for click:int in 20:if game.claim_grant()>0:grants+=1
    check(grants==1 and game.ad_cooldown==4,"Rapid bonus input gives exactly one grant before cooldown")
    var screen:Control=load("res://scenes/Main.tscn").instantiate();root.add_child(screen);current_scene=screen
    screen.show_intro_screen()
    for choice:int in 3:screen.on_choice_pressed(1)
    game.health=0;game.cash=25000;game.age=55
    screen.check_game_over()
    var generation:int=game.generation
    check(screen.current_mode==screen.ScreenMode.GAMEOVER,"Loss reaches its terminal screen")
    screen.on_choice_pressed(1)
    check(game.generation==generation and game.revive_used,"First legal revive retains the current dynasty")
    game.health=0;screen.check_game_over()
    screen.on_choice_pressed(1)
    check(game.generation==generation+1,"Final death commits exactly one inheritance")
    var legacy:int=game.legacy_points
    for click:int in 20:screen.check_game_over()
    check(game.generation==generation+1 and game.legacy_points==legacy,"Repeated terminal checks cannot award extra generations or legacy")
    screen.queue_free();await process_frame
    print("MECHANICS INPUTS RESULT: ","PASS" if failures==0 else "FAIL")
    if not await root.get_node("SoundManager").shutdown():
        quit(1)
        return
    quit(0 if failures==0 else 1)
