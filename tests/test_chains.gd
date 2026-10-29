extends SceneTree
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
func run()->void:
    await process_frame
    game=root.get_node("GameManager")
    var chains:Node=root.get_node("ChainLibrary")
    game.reset_full_dynasty()
    screen=load("res://scenes/Main.tscn").instantiate()
    root.add_child(screen);current_scene=screen
    await process_frame
    check(chains.catalog.size()>=8,"The thread catalog ships at least eight player-started chains")
    for definition:Dictionary in chains.catalog:
        var id:String=str(definition.get("id",""))
        check(not chains.start_event(id).is_empty(),"Every chain has a complete start event: "+id)
    var start_label:String=txt("chain.library_workshop.start.c1.label")
    var start_title:String=txt("chain.library_workshop.start.title")
    var rng_before:int=screen.rng.state
    screen.open_chain_thread("library_workshop")
    await process_frame
    check(screen.current_mode==screen.ScreenMode.LIFE,"Opening a thread enters the life screen")
    check(str(screen.active_event.get("chain_id",""))=="library_workshop","The chosen thread owns the active event")
    check(str(screen.active_event.get("chain_kind",""))=="start","The first link is a start event")
    check(str(screen.active_event.get("title",""))==start_title,"The start event uses its catalog title")
    check(not str(screen.active_event.get("overline","")).is_empty(),"Threads carry their own overline")
    check(screen.rng.state==rng_before,"Opening a thread consumes no event RNG")
    for action:String in ["r1","r2","r3"]:
        var callback:Callable=screen.active_event.get(action,Callable())
        check(callback.is_valid(),"The start event binds a live choice: "+action)
    clear_milestones()
    screen.btn_1.pressed.emit()
    await process_frame
    var record:Dictionary=game.chain_record_for("library_workshop")
    check(not record.is_empty(),"A taken thread enters the run record")
    check(str(record.get("flag",""))=="taught","The chosen flag is stored for later recall")
    check(str(record.get("stage",""))=="survival","The thread keeps its stage identity")
    check(not bool(record.get("completed",true)),"A fresh thread is not completed")
    check(str(record.get("label",""))==start_label,"The record keeps the exact chosen label")
    check(game.chain_flag("library_workshop")=="taught","The flag reads back through the model")
    check(game.chain_quarters_left("library_workshop")==5,"A five-quarter thread reports five quarters left")
    check(game.completed_chain_count()==0,"Starting a thread does not complete it")
    check(is_equal_approx(float(game.last_delta.get("cash",0.0)),600.0),"The start choice applies its real model delta")
    game.begin_chain("library_workshop","survival","duplicate","",5)
    check(game.chain_records.size()==1,"A thread cannot be recorded twice")
    for step:int in 5:
        game.advance_quarter_and_markets()
    check(str(game.chain_due().get("id",""))=="library_workshop","A thread becomes due after its delay")
    check(game.chain_quarters_left("library_workshop")==0,"A due thread reports zero quarters left")
    clear_milestones()
    var rng_due:int=screen.rng.state
    screen.load_next_life_event("",false)
    await process_frame
    check(str(screen.active_event.get("chain_kind",""))=="follow","A due thread is served as a follow-up")
    check(str(screen.active_event.get("chain_id",""))=="library_workshop","The follow-up keeps the thread identity")
    check(str(screen.active_event.get("title",""))==txt("chain.library_workshop.follow.title"),"The follow-up uses its catalog title")
    check(str(screen.active_event.get("note","")).contains(start_label),"The follow-up recalls the exact start choice")
    check(screen.rng.state==rng_due,"A due follow-up does not consume event RNG")
    for action:String in ["r1","r2","r3"]:
        var callback:Callable=screen.active_event.get(action,Callable())
        check(callback.is_valid(),"The follow-up binds a live choice: "+action)
    var momentum_before:int=game.momentum
    var completed_before:int=game.completed_chain_count()
    screen.btn_1.pressed.emit()
    await process_frame
    var finished:Dictionary=game.chain_record_for("library_workshop")
    check(bool(finished.get("completed",false)),"The second link completes the thread")
    check(str(finished.get("outcome",""))=="completed","Completion records its outcome")
    check(game.completed_chain_count()==completed_before+1,"The completed thread counts once")
    check(game.momentum==momentum_before+1,"Completing a thread grants momentum")
    check(is_equal_approx(float(game.last_delta.get("cash",0.0)),1400.0),"The taught flag selects the variant reward")
    check(screen.outcome.text==txt("chain.library_workshop.follow.c1.v.taught.result"),"The variant result owns the outcome line")
    clear_milestones()
    screen.open_chain_thread("night_courier")
    await process_frame
    check(str(screen.active_event.get("chain_id",""))=="night_courier","A second thread can start after the first")
    screen.btn_2.pressed.emit()
    await process_frame
    var night:Dictionary=game.chain_record_for("night_courier")
    check(str(night.get("flag",""))=="steady","The second thread stores its own flag")
    clear_milestones()
    for step:int in 5:
        game.advance_quarter_and_markets()
    screen.load_next_life_event("",false)
    await process_frame
    check(str(screen.active_event.get("chain_id",""))=="night_courier" and str(screen.active_event.get("chain_kind",""))=="follow","The second thread serves its own follow-up")
    var follow_title:String=str(screen.active_event.get("title",""))
    var saved_rng:int=screen.rng.state
    check(screen.save_session(),"An active thread saves through the live session")
    screen.queue_free();await process_frame
    screen=load("res://scenes/Main.tscn").instantiate()
    root.add_child(screen);current_scene=screen
    await process_frame
    check(screen.current_mode==screen.ScreenMode.LIFE,"A restart restores the active life screen")
    check(str(screen.active_event.get("title",""))==follow_title,"A restart restores the pending thread event")
    check(str(screen.active_event.get("chain_id",""))=="night_courier","The restored event keeps its thread identity")
    check(screen.rng.state==saved_rng,"A restart preserves the event RNG")
    check(game.chain_flag("night_courier")=="steady","The saved flag survives the restart")
    check(game.chain_flag("library_workshop")=="taught","Completed thread flags survive the restart")
    for action:String in ["r1","r2","r3"]:
        var callback:Callable=screen.active_event.get(action,Callable())
        check(callback.is_valid(),"A restored follow-up owns a live callback: "+action)
    var before_restore_complete:int=game.completed_chain_count()
    screen.btn_2.pressed.emit()
    await process_frame
    check(game.completed_chain_count()==before_restore_complete+1,"A restored callback still completes its thread")
    check(game.completed_chain_count()==2,"Both threads are recorded exactly once")
    print("CHAINS RESULT: ","PASS" if failures==0 else "FAIL")
    if not await root.get_node("SoundManager").shutdown():
        quit(1)
        return
    quit(0 if failures==0 else 1)
