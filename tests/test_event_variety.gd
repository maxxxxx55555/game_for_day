extends SceneTree
# Events must not repeat dozens of times per life: the picker prefers
# unseen events from the stage pool and only restarts the rotation once
# the pool is exhausted. The seen list survives a session save/restore.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	await process_frame
	var failures:=0
	var screen:Control=load("res://scenes/Main.tscn").instantiate()
	root.add_child(screen)
	current_scene=screen
	var game:Node=root.get_node("GameManager")
	game.reset_full_dynasty()
	screen.show_intro_screen()
	await process_frame
	# Hold the net worth inside the survival stage ($200 starting cash).
	game.cash_cents=20000
	# The intro may already have picked one event; start the count clean.
	screen.used_event_titles.clear()
	screen.last_event_title=""
	var pool:Array=screen.get_survival_events()
	var pool_size:int=pool.size()
	if pool_size < 3:
		failures+=1
		print("FAIL: survival pool too small to test variety: ",pool_size)
	var seen:Dictionary={}
	var picks:int=0
	for i in pool_size:
		var event:Dictionary=screen.pick_modular_event()
		picks+=1
		var title:String=str(event.get("title",""))
		if title.is_empty():
			failures+=1
			print("FAIL: picked an event without a title")
		if seen.has(title):
			failures+=1
			print("FAIL: event repeated before the pool was exhausted: ",title," at pick ",picks)
		seen[title]=true
	if screen.used_event_titles.size()!=pool_size:
		failures+=1
		print("FAIL: used list has ",screen.used_event_titles.size()," entries after ",pool_size," picks")
	# The next pick must restart the rotation: it repeats a seen title,
	# and the used list restarts from one entry.
	var again:Dictionary=screen.pick_modular_event()
	if not seen.has(str(again.get("title",""))):
		failures+=1
		print("FAIL: pool exhaustion did not restart the rotation with a seen title")
	if screen.used_event_titles.size()!=1:
		failures+=1
		print("FAIL: used list did not restart after exhaustion: ",screen.used_event_titles.size())
	# The seen list survives a session save/restore within the same life.
	screen.active_event=again
	if not screen.save_session():
		failures+=1
		print("FAIL: save_session failed")
	# load_current_life returns the ui dict itself, not a wrapper.
	var saved:Dictionary=game.load_current_life()
	var restored:Variant=saved.get("used_event_titles",[])
	if not (restored is Array and restored.size()==1):
		failures+=1
		print("FAIL: used list did not survive the session save: ",restored)
	screen.used_event_titles.clear()
	screen.restore_session(saved)
	if screen.used_event_titles.size()!=1:
		failures+=1
		print("FAIL: used list did not survive restore_session: ",screen.used_event_titles)
	print("EVENT VARIETY RESULT: ","PASS" if failures==0 else "FAIL"," pool=",pool_size)
	if not await root.get_node("SoundManager").shutdown():
		quit(1)
		return
	quit(0 if failures==0 else 1)
