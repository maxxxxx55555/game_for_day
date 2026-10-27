extends SceneTree
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func check(ok:bool, message:String) -> void:
	if not ok:
		failures+=1
		print("FAIL: ",message)
func run() -> void:
	await process_frame
	var director:Node=root.get_node("SoundManager")
	for child in director.get_children():
		check(not child is Node3D,"Finance audio must only allocate 2D players")
	check(AudioServer.get_bus_send(AudioServer.get_bus_index("UI"))=="Master","UI gain is independent from effects")
	check(not director.has_method("play_footstep"),"Finance has no spatial-footstep API")
	for obsolete in ["pickup","potion","inventory_open"]:
		check(not director.catalog.sfx.has(obsolete),"Catalog only contains contextual finance effects: "+obsolete)
	check(director.catalog.sfx.has("grant"),"Award feedback is named for its actual finance action")
	var effect=director.play_sfx("ui_click")
	check(effect.bus=="UI","Interface cues use their own bus")
	print("AUDIO SCOPE RESULT: ","PASS" if failures==0 else "FAIL")
	if not await root.get_node("SoundManager").shutdown():
		quit(1)
		return
	quit(0 if failures==0 else 1)
