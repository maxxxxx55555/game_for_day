extends SceneTree
const Policy = preload("res://scripts/security/FortuneSavePolicy.gd")
const Guard = preload("res://scripts/security/SaveGuard.gd")
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		print("FAIL: ",label)
func theme_cfg() -> ConfigFile:
	var cfg: ConfigFile = ConfigFile.new()
	cfg.set_value("dynasty","generation",1)
	cfg.set_value("dynasty","legacy_points",0)
	cfg.set_value("dynasty","inherited_capital",0.0)
	cfg.set_value("settings","time_speed",1.0)
	cfg.set_value("settings","audio_enabled",true)
	cfg.set_value("settings","reduced_motion",false)
	for field:String in ["master_volume","music_volume","sfx_volume","ui_volume"]:
		cfg.set_value("settings",field,0.3)
	return cfg
func run() -> void:
	await process_frame
	var game: Node = root.get_node("GameManager")
	game.reset_full_dynasty()
	check(game.save_current_life({"mode":3,"rng_state":123,"event_net_worth":1000}),"Valid session fixture saved")
	var original := Guard.config_candidate(game.SESSION_PATH,"fortune/session")
	check(original!=null and Policy.session(original),"Current session remains valid")
	for entry in [["ui","rng_state",{}],["ui","event_net_worth",{}],["ui","rng_state",1.5],["fx","rng",{}]]:
		var cfg := ConfigFile.new()
		cfg.parse(original.encode_to_text())
		var data: Dictionary = cfg.get_value("session","ui") if entry[0]=="ui" else cfg.get_value("run","fx_state")
		data[entry[1]] = entry[2]
		cfg.set_value("session" if entry[0]=="ui" else "run","ui" if entry[0]=="ui" else "fx_state",data)
		check(not Policy.session(cfg),"Reject malformed " + entry[0]+"."+entry[1])
		var purpose: String = "hardening/"+str(entry[1])+str(entry[0])+str(entry[2])
		var path := "user://malformed-session.cfg"
		DirAccess.remove_absolute(Guard.lock_path(purpose))
		DirAccess.remove_absolute(path+".bak")
		check(Guard.atomic_text(path,cfg.encode_to_text()),"Write unsigned migration fixture")
		check(Guard.read_config(path,purpose,Policy.session)==null,"Malformed legacy session rejected before applying typed fields")
	check(not Guard.safe_text("(".repeat(40)+")".repeat(40)),"Constructor nesting is bounded before parsing")
	check(game.has_signal("persistence_changed"),"Failed writes have a visible status signal")
	if game.has_signal("persistence_changed"):
		var screen: Control = load("res://scenes/Main.tscn").instantiate()
		root.add_child(screen)
		await process_frame
		var results: Array = []
		game.persistence_changed.connect(func(ok): results.append(ok))
		var prior := Guard.bounded_text(game.SESSION_PATH)
		DirAccess.remove_absolute(game.SESSION_PATH+".tmp")
		DirAccess.make_dir_absolute(game.SESSION_PATH+".tmp")
		check(not game.save_current_life({"mode":3}),"Disk failure cannot report save success")
		check(not results.is_empty() and results.back()==false,"Disk failure reaches presentation")
		check(screen.save_status.visible,"Player can see that the disk write failed")
		check(Guard.bounded_text(game.SESSION_PATH)==prior,"Failed write preserves last valid main save")
		DirAccess.remove_absolute(game.SESSION_PATH+".tmp")
		check(game.save_current_life({"mode":3}) and results.back()==true,"A successful retry clears the failure")
		check(not screen.save_status.visible,"Successful retry clears the visible warning")
		screen.queue_free()
		await process_frame
	var legacy_skin: ConfigFile = theme_cfg()
	check(Policy.dynasty(legacy_skin),"Profiles without a persisted theme remain valid")
	var light_skin: ConfigFile = theme_cfg()
	light_skin.set_value("settings","theme_mode","light")
	check(Policy.dynasty(light_skin),"The paper skin is a valid persisted theme")
	var unknown_skin: ConfigFile = theme_cfg()
	unknown_skin.set_value("settings","theme_mode","sepia")
	check(not Policy.dynasty(unknown_skin),"An unknown persisted theme is rejected")
	var typed_skin: ConfigFile = theme_cfg()
	typed_skin.set_value("settings","theme_mode",7)
	check(not Policy.dynasty(typed_skin),"A non-string persisted theme is rejected")
	print("RELEASE HARDENING RESULT: ","PASS" if failures==0 else "FAIL")
	if not await root.get_node("SoundManager").shutdown():
		quit(1)
		return
	quit(0 if failures==0 else 1)
