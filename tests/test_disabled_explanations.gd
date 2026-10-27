extends SceneTree
var failures:=0
func _initialize() -> void:call_deferred("run")
func check(ok:bool,message:String) -> void:
	if not ok:failures+=1;print("FAIL: ",message)
func scan(screen:Node) -> void:
	for node in screen.find_children("*","BaseButton",true,false):
		if node.disabled:check(not node.tooltip_text.strip_edges().is_empty(),"Disabled action explains its requirement: "+str(node.get_path()))
func run() -> void:
	await process_frame
	var screen:Node=load("res://scenes/Main.tscn").instantiate()
	root.add_child(screen);current_scene=screen
	await process_frame
	scan(screen)
	screen.open_currency_menu()
	root.get_node("GameManager").cash=400
	screen.currency_panel.refresh()
	screen.currency_panel._process(0)
	for row in screen.currency_panel.rows.values():
		check(not row.buy.tooltip_text.is_empty(),"Enabled currency purchase keeps its cost tooltip")
	print("DISABLED EXPLANATIONS RESULT: ","PASS" if failures==0 else "FAIL")
	paused=false
	if not await root.get_node("SoundManager").shutdown():
		quit(1)
		return
	quit(0 if failures==0 else 1)
