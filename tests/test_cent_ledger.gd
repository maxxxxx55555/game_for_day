extends SceneTree
var failures:=0
func _initialize() -> void:call_deferred("run")
func check(ok:bool,message:String) -> void:
    if not ok:failures+=1;print("FAIL: ",message)
func run() -> void:
    await process_frame
    var game:Node=root.get_node("GameManager")
    if not game.has_method("get_net_worth_cents") or not game.has_method("claim_grant"):
        check(false,"Money ledger and monotonic model grant are required");quit(1);return
    game.reset_game();game.cash=10.125
    check(game.cash_cents==1013 and game.cash==10.13,"Legacy dollar boundary rounds to nearest cent")
    var before:int=game.cash_cents
    for value in [NAN,INF,-INF,1.0e30]:game.cash=value;check(game.cash_cents==before,"Invalid assignment leaves the ledger intact")
    for amount in [-1.0,0.0,0.001,NAN,INF,1.0e30]:
        check(not game.buy_stocks(amount) and not game.buy_crypto(amount) and not game.buy_currency("EUR",amount),"Rejected purchase has no side effects")
    check(game.cash_cents==before and game.stock_units==0 and game.crypto_units==0 and game.fx.value()==0,"No partial debit on rejection")
    game.cash=1000
    for code in ["EUR","GBP","JPY"]:
        for cycle in 100:
            before=game.cash_cents
            check(game.buy_currency(code,0.03),"Three-cent foreign purchase")
            game.sell_currency(code,game.fx.holdings[code])
            check(game.cash_cents<=before,"Same-quote currency trade cannot mint one cent")
    game.reset_game();game.cash=1000
    check(game.buy_currency("GBP",500),"Buy before genuine appreciation")
    game.fx.rates.GBP*=1.2
    check(game.sell_currency("GBP",game.fx.holdings.GBP)>590 and game.cash_cents>109000,"Real exchange gains still work")
    game.stock_units=7;game.cash_cents=900000000000000
    var units:float=game.stock_units
    check(game.sell_all_stocks()==0 and game.stock_units==units,"Overflow sale preserves holdings and cash")
    before=game.cash_cents;game.apply_delta(INF,1,1,1,1,1)
    check(game.cash_cents==before and game.total_turns==0,"Nonfinite event fails before stats or time mutate")
    game.reset_game();game.cash=20000;game.time_speed=0.5
    var grant:float=game.claim_grant()
    before=game.cash_cents
    check(grant>0 and game.ad_cooldown==4,"Grant is a model transaction with four-quarter eligibility")
    check(game.claim_grant()==0 and game.cash_cents==before,"Double claim in one tick is rejected")
    game.advance_quarter_and_markets()
    check(game.simulation_ticks==1 and game.ad_cooldown==3.5,"Half-quarter uses one exact monotonic tick")
    check(game.save_current_life({"mode":3}),"Cent ledger and grant counter persist")
    var ticks:int=game.simulation_ticks;var ready:int=game.grant_ready_tick
    game.reset_game();game.load_current_life()
    check(game.simulation_ticks==ticks and game.grant_ready_tick==ready and game.claim_grant()==0,"Reload cannot reset grant eligibility")
    for turn in 7:game.advance_quarter_and_markets()
    check(game.ad_cooldown==0 and game.claim_grant()>0,"Grant becomes available only after simulated time")
    var cfg=load("res://scripts/security/SaveGuard.gd").config_candidate(game.SESSION_PATH,"fortune/session")
    check(cfg.get_value("run","cash_cents") is int,"Authenticated save contains integer cents")
    print("CENT LEDGER RESULT: ","PASS" if failures==0 else "FAIL")
    quit(0 if failures==0 else 1)
