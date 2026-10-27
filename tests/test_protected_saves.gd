extends SceneTree
const Guard = preload("res://scripts/security/SaveGuard.gd")
const Policy = preload("res://scripts/security/FortuneSavePolicy.gd")
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		print("FAIL: ",label)
func write(path: String, text: String) -> void:
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_string(text)
	file.close()
func run() -> void:
	await process_frame
	var game: Node = root.get_node("GameManager")
	game.reset_full_dynasty()
	game.cash = 1000
	check(game.save_current_life({"mode":3}),"Valid session is authenticated and saved")
	game.cash = 2000
	check(game.save_current_life({"mode":3}),"Second save preserves a known-good backup")
	var cfg := Guard.config_candidate(game.SESSION_PATH,"fortune/session")
	check(cfg != null,"Signed configuration authenticates with its install key")
	var body := Guard.bounded_text(game.SESSION_PATH)
	write(game.SESSION_PATH,body.replace("cash=2000","cash=999999"))
	game.cash = 5
	check(not game.load_current_life().is_empty() and game.cash==1000,"Edited cash is rejected and last valid backup is restored")
	var purpose := "test/legacy-fortune"
	DirAccess.remove_absolute(Guard.lock_path(purpose))
	write("user://legacy-fixture.cfg",cfg.encode_to_text())
	check(Guard.read_config("user://legacy-fixture.cfg",purpose,Policy.session)!=null and Guard.locked(purpose),"Valid old configuration migrates once to authenticated storage")
	write("user://legacy-fixture.cfg",cfg.encode_to_text())
	DirAccess.remove_absolute("user://legacy-fixture.cfg.bak")
	check(Guard.read_config("user://legacy-fixture.cfg",purpose,Policy.session)==null,"Stripping the signature cannot re-enable legacy loading")
	cfg.set_value("run","business_tier",99)
	check(not Policy.session(cfg),"Out-of-range business tier is rejected before array indexing")
	cfg.set_value("run","business_tier",0)
	cfg.set_value("run","health","broken")
	check(not Policy.session(cfg),"Wrongly typed saved state is rejected before assignment")
	check(not Guard.safe_text('[run]\ncash=Object(Resource,"script":null)') and not Guard.pure(RefCounted.new()),"Native objects are never accepted as save data")
	check(not Guard.safe_text("[".repeat(40)+"]".repeat(40)),"Excessive nesting is rejected before parsing")
	check(not Guard.atomic_text("user://too-large.cfg","x".repeat(Guard.MAX_BYTES+1)),"Oversized writes are rejected")
	print("PROTECTED FORTUNE SAVES: ","PASS" if failures==0 else "FAIL")
	if not await root.get_node("SoundManager").shutdown():
		quit(1)
		return
	quit(0 if failures==0 else 1)
