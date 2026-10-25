extends SceneTree
var failures:=0
func _initialize() -> void:call_deferred("run")
func check(ok:bool,message:String) -> void:
	if not ok:failures+=1;print("FAIL: ",message)
func run() -> void:
	await process_frame
	var arrival:=root.get_node_or_null("FortuneArrival")
	check(arrival!=null,"A real branded boot/loading flow exists")
	check(ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/Boot.tscn","Boot is the public entry scene")
	var screen:Control=load("res://scenes/Main.tscn").instantiate()
	root.add_child(screen);current_scene=screen
	await process_frame
	var saved:Variant=screen.save_session()
	check(saved is bool and saved,"The UI receives the actual persistence result")
	if arrival:
		arrival.show_splash()
		check(arrival.hint.text.length()>12,"Boot has an authored localized hint")
		arrival.hide_splash()
		var attempts:=[0]
		arrival.confirm_unsaved(func():attempts[0]+=1;return false,func():attempts[0]+=100)
		var dialog:ConfirmationDialog=arrival.unsaved_dialog
		dialog.confirmed.emit()
		check(attempts[0]==1,"A failed save retry cannot silently quit")
		dialog.canceled.emit()
		check(attempts[0]==1,"Stay keeps the life intact")
	print("RELEASE DETAILS RESULT: ","PASS" if failures==0 else "FAIL")
	quit(0 if failures==0 else 1)
