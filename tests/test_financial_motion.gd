extends SceneTree
var failures:=0
func _initialize() -> void:call_deferred("run")
func check(ok:bool,label:String) -> void:
	if not ok:failures+=1;print("FAIL: ",label)
func run() -> void:
	await process_frame
	var game:Node=root.get_node("GameManager")
	game.reset_full_dynasty();game.cash=100.0;game.reduced_motion=false
	var dashboard:Control=load("res://scripts/ui/FortuneDashboard.gd").new()
	root.add_child(dashboard)
	await process_frame
	check(dashboard.has_method("refresh_values"),"Capital has a presentation-only animated update")
	if dashboard.has_method("refresh_values"):
		game.cash=200.0;dashboard.refresh_values()
		check(game.cash==200.0 and is_equal_approx(dashboard.display_cash,100.0),"Model settles immediately while visible capital starts at previous value")
		await create_timer(0.26).timeout
		check(is_equal_approx(dashboard.display_cash,200.0),"Visible capital reaches the exact balance after the transition")
		game.cash=300.0;dashboard.refresh_values();game.cash=400.0;dashboard.refresh_values()
		await create_timer(0.26).timeout
		check(is_equal_approx(dashboard.display_cash,400.0) and game.cash==400.0,"Burst updates settle at newest balance without changing the model")
		game.reduced_motion=true;game.cash=500.0;dashboard.refresh_values()
		check(is_equal_approx(dashboard.display_cash,500.0),"Reduced motion immediately displays exact balance")
		game.reduced_motion=false;game.cash=600.0;dashboard.refresh_values();game.reduced_motion=true
		await process_frame;await process_frame
		check(is_equal_approx(dashboard.display_cash,600.0),"Enabling reduced motion during a transition snaps the value")
	print("FINANCIAL MOTION RESULT: ","PASS" if failures==0 else "FAIL")
	quit(0 if failures==0 else 1)
