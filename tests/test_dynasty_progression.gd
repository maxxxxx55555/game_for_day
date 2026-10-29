extends SceneTree
const Guard=preload("res://scripts/security/SaveGuard.gd")
const Policy=preload("res://scripts/security/FortuneSavePolicy.gd")
var failures:int=0
var game:Node
var screen:Control
func _initialize()->void:call_deferred("run")
func check(ok:bool,label:String)->void:
    if not ok:failures+=1;print("FAIL: ",label)
func txt(key:String)->String:return root.get_node("LocalizationManager").source(key)
func clear_milestones()->void:
    var pending:Dictionary=game.milestone_pending()
    while not pending.is_empty():
        game.acknowledge_milestone(int(pending.get("age",0)))
        pending=game.milestone_pending()
func scan_disabled(root_node:Node,label:String)->void:
    for node:Node in root_node.find_children("*","BaseButton",true,false):
        if node.disabled:
            check(not node.tooltip_text.strip_edges().is_empty(),"Disabled action explains its requirement: "+label+" "+str(node.get_path()))
func run()->void:
    await process_frame
    game=root.get_node("GameManager")
    game.reset_full_dynasty()
    screen=load("res://scenes/Main.tscn").instantiate()
    root.add_child(screen);current_scene=screen
    await process_frame
    check(game.select_ambition("meteor"),"Meteor ambition is selectable")
    check(not game.select_ambition("bogus"),"Unknown ambition modes are rejected")
    game.reset_game()
    game.select_ambition("meteor")
    game.stress=10
    game.apply_delta(0,0,0,10,0,0)
    check(game.stress==23,"Meteor raises positive stress by its 1.3 multiplier")
    clear_milestones()
    game.reset_game()
    game.inherited_capital=1000.0
    game.reset_game()
    check(game.select_ambition("heir"),"Heir ambition is selectable")
    check(is_equal_approx(game.inheritance_multiplier(),1.25),"Heir carries the 1.25 inheritance multiplier")
    check(is_equal_approx(game.cash,1450.0),"Heir scales the starting inheritance before the first event")
    game.business_tier=1
    game.business_scale=1
    game.select_ambition("steady")
    var steady_income:int=game.get_passive_quarterly_income_cents()
    game.select_ambition("heir")
    var heir_income:int=game.get_passive_quarterly_income_cents()
    check(steady_income>0,"A tier-one business pays a quarterly income")
    check(heir_income<steady_income and float(heir_income)>=float(steady_income)*0.88,"Heir trades about a tenth of quarterly income for the dynasty")
    var heir_desc:String=txt("ambition.heir.desc")
    check(heir_desc.contains("ниже") or heir_desc.contains("lower"),"The Heir description discloses the income cost")
    check(txt("ambition.heir.button").count("%")>=2,"The Heir label carries both its percentage figures")
    screen.update_ambition_controls()
    check(screen.ambition_buttons.size()==3 and screen.ambition_buttons[0].button_group!=null,"Ambition is a single-choice control group")
    for button:Button in screen.ambition_buttons:
        check(not button.tooltip_text.strip_edges().is_empty(),"Every ambition describes its trade-off")
    screen.apply_ambition("meteor")
    check(game.ambition=="meteor" and screen.ambition_buttons[1].button_pressed,"The ambition control writes the real model")
    check(not screen.ambition_desc.text.strip_edges().is_empty(),"The active ambition explains itself")
    game.reset_full_dynasty()
    game.legacy_points=20
    check(game.unlock_legacy_perk("warm_start"),"A legacy perk can be bought with earned points")
    check(game.legacy_points==16 and game.legacy_perk_owned("warm_start"),"Buying a perk deducts its cost and records ownership")
    check(not game.unlock_legacy_perk("warm_start"),"An owned perk cannot be bought twice")
    check(not game.unlock_legacy_perk("unknown_perk"),"Unknown perks are rejected")
    game.legacy_points=0
    check(not game.unlock_legacy_perk("safety_net"),"A perk is blocked when legacy points are short")
    check(is_equal_approx(game.legacy_start_bonus(),2000.0),"Warm start carries its real starting bonus")
    game.legacy_points=16
    game.reset_game()
    check(is_equal_approx(game.cash,2200.0),"Warm start raises the first-life balance")
    check(game.save_dynasty(),"The dynasty saves through its protected file")
    game.unlocked_perks.clear();game.legacy_points=0
    game.load_dynasty()
    check(game.legacy_perk_owned("warm_start") and game.legacy_points==16,"Purchased perks survive a save and load")
    check(game.save_dynasty(),"The restored dynasty re-saves cleanly")
    game.reset_game()
    screen.load_next_life_event("",false)
    await process_frame
    clear_milestones()
    var event_title:String=str(screen.active_event.get("title",""))
    var event_rng:int=screen.rng.state
    screen.open_dynasty_menu()
    await process_frame
    check(screen.current_mode==screen.ScreenMode.DYNASTY and screen.dynasty_panel.visible,"The dynasty ledger opens over a live life")
    var sections:Array=screen.dynasty_panel.SECTIONS
    for section:String in sections:
        screen.dynasty_panel.set_section(section)
        await process_frame
        check(screen.dynasty_panel.active_section==section,"Dynasty section builds: "+section)
        check(screen.dynasty_panel.content.get_child_count()>0,"Dynasty section carries real content: "+section)
        scan_disabled(screen.dynasty_panel,section)
    screen._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
    await process_frame
    check(screen.current_mode==screen.ScreenMode.LIFE and not screen.dynasty_panel.visible,"Back closes the ledger and returns to the life")
    check(str(screen.active_event.get("title",""))==event_title and screen.rng.state==event_rng,"Closing the ledger preserves the pending event and RNG")
    game.reset_full_dynasty()
    game.age=60
    game.cash=300000000000.0
    game.recalculate_forbes_rank()
    check(game.rank==1,"The hall setup reaches the first rank")
    var generation_before:int=game.generation
    var points_before:int=game.legacy_points
    var message:String=game.register_inheritance_on_end()
    check(not message.strip_edges().is_empty(),"Ending a life reports its inheritance")
    check(game.dynasty_records.size()==1,"A finished life enters the hall of fame once")
    var record:Dictionary=game.dynasty_records[0]
    check(int(record.get("generation",0))==generation_before,"The hall record carries its generation")
    check(int(record.get("age",0))==60,"The hall record carries the final age")
    check(bool(record.get("victory",false)),"A 250B life is recorded as a victory")
    check(str(record.get("ambition",""))=="steady","The hall record carries the ambition")
    check(int(record.get("chains",-1))==0 and int(record.get("milestones",-1))==0,"The hall record counts threads and milestones")
    check(game.generation==generation_before+1,"Ending a life advances the generation")
    check(game.inherited_capital>0.0,"A late wealthy life leaves real inherited capital")
    check(game.legacy_points>points_before,"Ending a life earns legacy points")
    check(game.dynasty_committed and game.lives_completed==1,"The committed life is counted once")
    check(game.lifetime_best_cents==game.get_net_worth_cents(),"The lifetime best tracks the final net worth")
    game.register_inheritance_on_end()
    check(game.dynasty_records.size()==1,"Inheritance is idempotent inside one life")
    screen.dynasty_panel.set_section("hall")
    screen.dynasty_panel.refresh()
    check(screen.dynasty_panel.content.get_child_count()>1,"The hall renders the recorded life")
    game.reset_full_dynasty()
    game.check_milestones()
    check(game.momentum==2,"Reaching a milestone grants momentum")
    check(game.milestone_log.size()==1,"Each milestone age is logged once")
    game.check_milestones()
    check(game.momentum==2 and game.milestone_log.size()==1,"Re-checking the same age adds nothing")
    var pending:Dictionary=game.milestone_pending()
    check(int(pending.get("age",0))==18 and not bool(pending.get("seen",true)),"A fresh milestone awaits its retrospective")
    screen.load_next_life_event("",false)
    await process_frame
    check(screen.milestone_card.visible,"A fresh event surfaces the pending milestone")
    check(screen.milestone_card.heading.text==txt("milestone.title") % 18,"The retrospective names the age")
    check(not screen.milestone_card.body.text.strip_edges().is_empty(),"The retrospective carries real figures")
    var milestone_event:String=str(screen.active_event.get("title",""))
    screen.milestone_card.continue_button.pressed.emit()
    await process_frame
    check(not screen.milestone_card.visible,"Continue dismisses the retrospective")
    check(str(screen.active_event.get("title",""))==milestone_event,"Continue never advances the world")
    var seen:bool=false
    for entry:Variant in game.milestone_log:
        if entry is Dictionary:
            var row:Dictionary=entry
            if int(row.get("age",0))==18:
                seen=bool(row.get("seen",false))
    check(seen,"Acknowledging records that the milestone was read")
    check(game.momentum==2,"Acknowledging a milestone does not spend momentum")
    game.reset_full_dynasty()
    check(not game.begin_ascension(),"Ascension requires a won life")
    game.age=60
    game.cash=300000000000.0
    game.recalculate_forbes_rank()
    screen.trigger_game_over(txt("copy.35118a151aa7"),true)
    check(screen.current_mode==screen.ScreenMode.GAMEOVER and screen.finale_overlay.visible,"A 250B victory opens the finale")
    check(screen.finale_overlay.tertiary.visible,"A victorious finale offers ascension")
    var generation_at_ascension:int=game.generation
    screen._apply_choice(3)
    await process_frame
    check(game.ascension_level==1,"Ascension increments the meta level")
    check(game.run_ascension==1,"The new run carries its ascension level")
    check(game.generation==generation_at_ascension+1,"Ascension still advances the generation once")
    check(game.dynasty_records.size()==1,"Ascension commits the finished life to the hall")
    check(screen.current_mode==screen.ScreenMode.INTRO,"Ascension returns to the intro")
    check(screen.intro_notice==txt("ascension.started") % game.ascension_level,"The intro announces the ascension level")
    check(game.age==18 and is_equal_approx(game.difficulty_multiplier,1.08),"Ascension raises the next run difficulty")
    check(not game.begin_ascension(),"A fresh ascension run cannot chain another victory")
    game.reset_full_dynasty()
    game.save_current_life({"mode":3,"rng_state":123})
    game.save_dynasty()
    var session_cfg=Guard.config_candidate(game.SESSION_PATH,"fortune/session")
    check(session_cfg!=null,"A 2.1 session authenticates")
    if session_cfg!=null:
        for field:String in ["ambition","run_ascension","chain_records","milestone_log","momentum","market_history","dynasty_committed"]:
            check(session_cfg.has_section_key("run",field),"The session persists 2.1 run field: "+field)
        check(Policy.session(session_cfg),"A current session passes the save policy")
        for field:String in ["ambition","run_ascension","chain_records","milestone_log","momentum","market_history","dynasty_committed"]:
            session_cfg.erase_section_key("run",field)
        check(Policy.session(session_cfg),"A 2.0.x session without 2.1 fields still loads")
        session_cfg.set_value("run","ambition","bogus")
        check(not Policy.session(session_cfg),"An unknown saved ambition is rejected")
        session_cfg.set_value("run","ambition","steady")
        session_cfg.set_value("run","momentum",-1)
        check(not Policy.session(session_cfg),"Negative momentum is rejected")
        session_cfg.set_value("run","momentum",0)
        session_cfg.set_value("run","run_ascension",6)
        check(not Policy.session(session_cfg),"Ascension above the cap is rejected")
        session_cfg.set_value("run","run_ascension",0)
        session_cfg.set_value("run","chain_records",[{"id":"unknown"}])
        check(not Policy.session(session_cfg),"An unknown thread record is rejected")
        session_cfg.set_value("run","chain_records",[])
        session_cfg.set_value("run","milestone_log",[{"age":18,"wealth_cents":0,"rank":1,"stage":"survival","chains":0,"seen":false}])
        check(Policy.session(session_cfg),"A well-formed milestone entry is accepted")
        session_cfg.set_value("run","milestone_log",[{"age":77}])
        check(not Policy.session(session_cfg),"A malformed milestone entry is rejected")
        session_cfg.set_value("run","milestone_log",[])
        var ui_value:Variant=session_cfg.get_value("session","ui",{})
        if ui_value is Dictionary:
            var ui:Dictionary=ui_value
            ui["rng_state"]=1.5
            session_cfg.set_value("session","ui",ui)
        check(not Policy.session(session_cfg),"A non-integer RNG state is rejected")
    var dynasty_cfg=Guard.config_candidate(game.SAVE_PATH,"fortune/dynasty")
    check(dynasty_cfg!=null,"A 2.1 dynasty authenticates")
    if dynasty_cfg!=null:
        for field:String in ["unlocked_perks","records","ascension_level","lives_completed","lifetime_best_cents","total_legacy_earned"]:
            check(dynasty_cfg.has_section_key("dynasty",field),"The dynasty persists 2.1 field: "+field)
        check(Policy.dynasty(dynasty_cfg),"A current dynasty passes the save policy")
        for field:String in ["unlocked_perks","records","ascension_level","lives_completed","lifetime_best_cents","total_legacy_earned"]:
            dynasty_cfg.erase_section_key("dynasty",field)
        check(Policy.dynasty(dynasty_cfg),"A 2.0.x dynasty without 2.1 fields still loads")
        dynasty_cfg.set_value("dynasty","ascension_level",6)
        check(not Policy.dynasty(dynasty_cfg),"Dynasty ascension above the cap is rejected")
        dynasty_cfg.set_value("dynasty","ascension_level",0)
        dynasty_cfg.set_value("dynasty","unlocked_perks",["bogus"])
        check(not Policy.dynasty(dynasty_cfg),"An unknown saved perk is rejected")
        dynasty_cfg.set_value("dynasty","unlocked_perks",["warm_start"])
        check(Policy.dynasty(dynasty_cfg),"A known saved perk is accepted")
        dynasty_cfg.set_value("dynasty","records",[{"generation":1,"age":60,"wealth_cents":100,"rank":1,"victory":true,"ambition":"steady","ascension":0,"chains":0,"milestones":0}])
        check(Policy.dynasty(dynasty_cfg),"A well-formed hall record is accepted")
        dynasty_cfg.set_value("dynasty","records",[{"generation":1,"age":60,"wealth_cents":100,"rank":1,"victory":"yes","ambition":"steady","ascension":0,"chains":0,"milestones":0}])
        check(not Policy.dynasty(dynasty_cfg),"A malformed hall record is rejected")
    print("DYNASTY PROGRESSION RESULT: ","PASS" if failures==0 else "FAIL")
    if not await root.get_node("SoundManager").shutdown():
        quit(1)
        return
    quit(0 if failures==0 else 1)
