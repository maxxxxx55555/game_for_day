extends SceneTree
var failures:int=0
func _initialize()->void:call_deferred("run")
func check(ok:bool,label:String)->void:
	if not ok:failures+=1;print("FAIL: ",label)
func run()->void:
	await process_frame
	var game:Node=root.get_node("GameManager")
	var ui:Control=load("res://scenes/Main.tscn").instantiate()
	root.add_child(ui)
	current_scene=ui
	game.reset_full_dynasty()
	ui.show_intro_screen()
	for index:int in 3:ui.btn_1.pressed.emit()
	var turn:int=game.total_turns
	var armed:Array[bool]=[true]
	var listener:Callable=func(_ok:bool)->void:
		if armed[0]:
			armed[0]=false
			ui.btn_2.pressed.emit()
	game.persistence_changed.connect(listener)
	ui.btn_2.pressed.emit()
	game.persistence_changed.disconnect(listener)
	check(game.total_turns==turn+1,"Reentrant save feedback cannot consume a second decision")
	turn=game.total_turns
	for index:int in 5:ui.btn_2.pressed.emit()
	check(game.total_turns==turn+5,"Five separate valid clicks remain five ordinary decisions")
	print("CHOICE REENTRY RESULT: ","PASS" if failures==0 else "FAIL")
	ui.queue_free()
	await process_frame
	quit(0 if failures==0 else 1)
