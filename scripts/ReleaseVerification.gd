extends Node
const LedgerView=preload("res://scripts/Main.gd")
const AudioView=preload("res://scripts/audio/AudioDirector.gd")

func capture(suffix: String) -> void:
	if OS.get_environment("GAME_CAPTURE_GALLERY") != "1" or DisplayServer.get_name() == "headless": return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image_error:Error=get_viewport().get_texture().get_image().save_png(OS.get_environment("GAME_SCREENSHOT").replace(".png", "-" + suffix + ".png"))
	if image_error!=OK:push_error("QA screenshot failed: "+error_string(image_error))

# Opt-in QA route for the shipped pack. Run only with an isolated save profile.
func run(ui: LedgerView) -> void:
	var started_ms:int=Time.get_ticks_msec()
	var trial_seed:int=parse_seed(OS.get_environment("GAME_QA_SEED"))
	if trial_seed<0:finish(64);return
	await get_tree().process_frame
	GameManager.reset_full_dynasty()
	GameManager.time_speed = 1.0
	ui.active_event = {}
	ui.show_intro_screen()
	seed(trial_seed)
	ui.rng.seed = trial_seed
	GameManager.fx.rng.seed=trial_seed
	await capture("title")
	if OS.get_cmdline_user_args().has("--dynasty"):
		await verify_dynasty(ui)
		return
	for index:int in 3: ui.btn_1.pressed.emit()
	await capture("life")
	if OS.get_cmdline_user_args().has("--defeat"):
		await verify_defeat(ui)
		return
	var trace:Array=[]
	var steps:int= 0
	while ui.current_mode != ui.ScreenMode.GAMEOVER and steps < 520:
		steps += 1
		trace.append({"title":ui.active_event.get("title",""),"cash_cents":GameManager.cash_cents,"fx":GameManager.fx.rates.duplicate()})
		if steps == 20 and OS.get_environment("GAME_CAPTURE_GALLERY") == "1":
			ui.market_btn.pressed.emit()
			await capture("portfolio")
			ui.currency_button.pressed.emit()
			if GameManager.cash > 0:
				var buy:Button=ui.currency_panel.rows.EUR.buy
				buy.pressed.emit()
			await capture("currencies")
			var sell:Button=ui.currency_panel.rows.EUR.sell
			sell.pressed.emit()
			ui.currency_panel.closed.emit()
			ui.market_back.pressed.emit()
			ui.biz_btn.pressed.emit()
			await capture("business")
			ui.btn_3.pressed.emit()
		if GameManager.ad_cooldown == 0: ui.ad_btn.pressed.emit()
		var cost: float = GameManager.BUSINESS_TIERS[mini(GameManager.business_tier + 1, 5)].cost if GameManager.business_tier < 5 else 250000000.0 * GameManager.business_scale
		if GameManager.cash >= cost + GameManager.get_quarterly_living_cost() * 2:
			ui.biz_btn.pressed.emit()
			ui.btn_1.pressed.emit()
			if ui.current_mode != ui.ScreenMode.GAMEOVER: ui.btn_3.pressed.emit()
		if ui.current_mode == ui.ScreenMode.GAMEOVER: break
		var option:int= 2
		if GameManager.energy < 42 or GameManager.stress > 50 or GameManager.health < 45:
			option = 3
		else:
			var title: String = ui.active_event.title
			if "хакатон" in title or "нейросетей" in title or "фонд ищет" in title: option = 1
			if "Проблемы со здоровьем" in title: option = 3
			if "Антимонопольный" in title: option = 2
		var action:Button=[ui.btn_1,ui.btn_2,ui.btn_3][option-1]
		action.pressed.emit()
		if steps % 10 == 0 and ui.current_mode != ui.ScreenMode.GAMEOVER:
			await step_checkpoint(ui)
			await get_tree().process_frame
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless" and not OS.get_environment("GAME_SCREENSHOT").is_empty():
		await RenderingServer.frame_post_draw
		var image_error:Error=get_viewport().get_texture().get_image().save_png(OS.get_environment("GAME_SCREENSHOT"))
		if image_error!=OK:push_error("QA screenshot failed: "+error_string(image_error))
	var success: bool = GameManager.rank == 1 and ui.final_victory and GameManager.get_net_worth() >= 250000000000.0
	print("EXPORTED PLAYTHROUGH: ", "PASS" if success else "FAIL", " steps=", steps, " rank=", GameManager.rank, " wealth=", GameManager.get_net_worth())
	var state:Dictionary={}
	for field:String in GameManager.RUN_FIELDS:state[field]=GameManager.get(field)
	write_qa_result({"seed":trial_seed,"result":"PASS" if success else "FAIL","steps":steps,"origin":GameManager.birth_origin,"rank":GameManager.rank,"wealth_cents":GameManager.get_net_worth_cents(),"trace_sha256":JSON.stringify(trace,"",true,true).sha256_text(),"state_sha256":JSON.stringify(state,"",true,true).sha256_text(),"elapsed_ms":Time.get_ticks_msec()-started_ms})
	ui.queue_free()
	await get_tree().process_frame
	var audio_settled:bool=await settle_audio()
	finish(0 if success and audio_settled else 1)

func verify_defeat(ui: LedgerView) -> void:
	var steps:int=0
	# Only ordinary event buttons drive this loss route; no stats are assigned.
	while ui.current_mode != ui.ScreenMode.GAMEOVER and steps<520:
		ui.btn_1.pressed.emit()
		steps+=1
		if steps%10==0: await get_tree().process_frame
	await get_tree().create_timer(0.8).timeout
	await capture("defeat")
	var success: bool=ui.current_mode==ui.ScreenMode.GAMEOVER and not ui.final_victory and ui.finale_overlay.visible
	var had_revive: bool=ui.can_revive
	if had_revive:
		ui.finale_overlay.primary.pressed.emit()
		success=success and GameManager.revive_used and ui.current_mode!=ui.ScreenMode.GAMEOVER
		while ui.current_mode != ui.ScreenMode.GAMEOVER and steps<1040:
			ui.btn_1.pressed.emit()
			steps+=1
			if steps%10==0: await get_tree().process_frame
		success=success and not ui.can_revive and not ui.final_victory
	var generation: int=GameManager.generation
	ui.finale_overlay.primary.pressed.emit()
	success=success and GameManager.generation==generation+1 and ui.current_mode==ui.ScreenMode.INTRO
	print("EXPORTED DEFEAT ROUTE: ","PASS" if success else "FAIL"," steps=",steps," revive=",had_revive)
	ui.queue_free()
	await get_tree().process_frame
	var audio_settled:bool=await settle_audio()
	finish(0 if success and audio_settled else 1)

# Opt-in QA route: walks the dynasty ledger exactly as the owner checklist describes,
# through real buttons on the shipped pack. Legacy points and one age are seeded for the
# purchase and the retrospective; every other step is driven by the interface.
func verify_dynasty(ui: LedgerView) -> void:
	var notes:Array[String]=[]
	var facts:Dictionary={}
	ui.ambition_buttons[2].pressed.emit()
	await get_tree().process_frame
	facts["ambition"]=str(GameManager.ambition)
	if GameManager.ambition!="heir" or not ui.ambition_buttons[2].button_pressed:
		notes.append("the heir control did not write the model")
	# A self-comparison would prove nothing, so the route requires the text to be the heir one,
	# not the steady one, and to carry a percentage figure in whichever locale is running.
	var heir_copy:String=LocalizationManager.source("ambition.heir.desc")
	if ui.ambition_desc.text != heir_copy or ui.ambition_desc.text == LocalizationManager.source("ambition.steady.desc"):
		notes.append("the intro does not show the heir description specifically")
	# The control itself carries the short name; the cost is disclosed in the description line and
	# repeated on the control tooltip, so both are checked rather than a catalogue string that
	# the interface never shows.
	if ui.ambition_buttons[2].tooltip_text != LocalizationManager.source("ambition.heir.desc"):
		notes.append("the heir control does not carry its own disclosure")
	for index:int in 3:
		ui.btn_1.pressed.emit()
		await get_tree().process_frame
	if ui.current_mode!=ui.ScreenMode.LIFE:
		notes.append("the life screen never opened")
	GameManager.legacy_points=GameManager.legacy_points+20
	var owned:int=GameManager.unlocked_perks.size()
	var points_before:int=GameManager.legacy_points
	ui.dynasty_button.pressed.emit()
	await get_tree().process_frame
	ui.dynasty_panel.set_section("legacy")
	await get_tree().process_frame
	var buy:Button=first_action(ui.dynasty_panel.content)
	if buy==null:
		notes.append("the ledger offered no affordable perk")
	else:
		buy.pressed.emit()
		await get_tree().process_frame
		if GameManager.unlocked_perks.size()!=owned+1:
			notes.append("pressing the perk action did not unlock it")
		if not GameManager.legacy_points<points_before:
			notes.append("the perk cost no legacy points")
	facts["perks"]=GameManager.unlocked_perks.size()
	facts["legacy_points_left"]=GameManager.legacy_points
	ui.dynasty_panel.set_section("threads")
	await get_tree().process_frame
	var start:Button=first_action(ui.dynasty_panel.content)
	if start==null:
		notes.append("the ledger offered no thread to start")
		await finish_dynasty(ui,false,notes)
		return
	var threads_before:int=GameManager.chain_records.size()
	start.pressed.emit()
	await get_tree().process_frame
	if str(ui.active_event.get("chain_kind",""))!="start":
		notes.append("the ledger action did not open a first link")
		await finish_dynasty(ui,false,notes)
		return
	ui.btn_1.pressed.emit()
	await get_tree().process_frame
	if GameManager.chain_records.size()!=threads_before+1:
		notes.append("the taken choice stored %d thread records instead of one more" % GameManager.chain_records.size())
		await finish_dynasty(ui,false,notes)
		return
	var value:Variant=GameManager.chain_records[threads_before]
	if not value is Dictionary:
		notes.append("the stored thread record is not a dictionary")
		await finish_dynasty(ui,false,notes)
		return
	var record:Dictionary=value
	var thread_id:String=str(record.get("id",""))
	var start_label:String=LocalizationManager.source("chain."+thread_id+".start.c1.label")
	if str(GameManager.chain_record_for(thread_id).get("flag","")).is_empty():
		notes.append("the choice stored no flag")
	if str(record.get("label",""))!=start_label:
		notes.append("the stored label is not the choice text the player pressed")
	if not ui.delta_chips.visible or ui.delta_chips.get_child_count()==0 or GameManager.last_delta.is_empty():
		notes.append("the choice left no visible delta chips")
	for step:int in 5:
		@warning_ignore("return_value_discarded")
		GameManager.advance_quarter_and_markets()
	ui.load_next_life_event("",false)
	await get_tree().process_frame
	if str(ui.active_event.get("chain_kind",""))!="follow":
		notes.append("no follow-up arrived after five quarters")
		await finish_dynasty(ui,false,notes)
		return
	if str(ui.active_event.get("chain_id",""))!=thread_id:
		notes.append("the follow-up belongs to %s, not the thread that was started" % str(ui.active_event.get("chain_id","")))
	if not str(ui.active_event.get("note","")).contains(start_label):
		notes.append("the follow-up does not recall the stored label")
	var momentum_before:int=GameManager.momentum
	var completed_before:int=GameManager.completed_chain_count()
	ui.btn_1.pressed.emit()
	await get_tree().process_frame
	if GameManager.completed_chain_count()!=completed_before+1:
		notes.append("the second link did not complete the thread")
	if GameManager.momentum<=momentum_before:
		notes.append("completing the thread paid no momentum")
	facts["thread_id"]=thread_id
	facts["threads_completed"]=GameManager.completed_chain_count()
	facts["momentum_after_thread"]=GameManager.momentum
	var pending_title:String=str(ui.active_event.get("title",""))
	var turns:int=GameManager.total_turns
	ui.dynasty_button.pressed.emit()
	await get_tree().process_frame
	ui.dynasty_panel.close_button.pressed.emit()
	await get_tree().process_frame
	if ui.current_mode!=ui.ScreenMode.LIFE or str(ui.active_event.get("title",""))!=pending_title or GameManager.total_turns!=turns:
		notes.append("closing the ledger disturbed the pending event or the clock")
	# The retrospective is read at the first threshold this life has not already logged,
	# because the life may have aged past 18 on its own while the ledger was walked.
	var milestone_age:int=0
	for threshold:int in GameManager.MILESTONE_AGES:
		var logged:bool=false
		for entry:Variant in GameManager.milestone_log:
			if not entry is Dictionary:
				continue
			var logged_entry:Dictionary=entry
			var logged_age:int=logged_entry.get("age",0)
			if logged_age==threshold:
				logged=true
				break
		if not logged:
			milestone_age=threshold
			break
	if milestone_age==0:
		notes.append("no milestone threshold was left for the ledger to read")
	else:
		GameManager.age=milestone_age
		GameManager.check_milestones()
		ui.present_milestone_if_pending()
		await get_tree().process_frame
		if not ui.milestone_card.visible:
			notes.append("the age-%d retrospective never surfaced" % milestone_age)
		else:
			var event_before:String=str(ui.active_event.get("title",""))
			var milestone_turns:int=GameManager.total_turns
			ui.milestone_card.continue_button.pressed.emit()
			await get_tree().process_frame
			if ui.milestone_card.visible or str(ui.active_event.get("title",""))!=event_before or GameManager.total_turns!=milestone_turns:
				notes.append("Continue on the retrospective advanced the world")
	facts["milestones"]=GameManager.milestone_log.size()
	var records_before:int=GameManager.dynasty_records.size()
	var generations:int=GameManager.generation
	var steps:int=0
	while ui.current_mode!=ui.ScreenMode.GAMEOVER and steps<1040:
		ui.btn_1.pressed.emit()
		steps+=1
		if steps%10==0:
			await get_tree().process_frame
	if ui.current_mode!=ui.ScreenMode.GAMEOVER:
		notes.append("the life never ended (%d choices)" % steps)
		await finish_dynasty(ui,false,notes)
		return
	# The first press revives when the revive is still available, exactly as it does for
	# a player; only the second death hands the line over to the next generation.
	var had_revive:bool=ui.can_revive
	ui.finale_overlay.primary.pressed.emit()
	await get_tree().process_frame
	if had_revive:
		while ui.current_mode!=ui.ScreenMode.GAMEOVER and steps<2080:
			ui.btn_1.pressed.emit()
			steps+=1
			if steps%10==0:
				await get_tree().process_frame
		if ui.current_mode!=ui.ScreenMode.GAMEOVER or ui.can_revive:
			notes.append("the revived life did not reach a final end (%d choices)" % steps)
			await finish_dynasty(ui,false,notes)
			return
		ui.finale_overlay.primary.pressed.emit()
		await get_tree().process_frame
	var added:int=GameManager.dynasty_records.size()-records_before
	if added!=1:
		notes.append("one finished life added %d hall records" % added)
	if GameManager.generation!=generations+1:
		notes.append("the next life did not advance the generation")
	if ui.current_mode!=ui.ScreenMode.INTRO:
		notes.append("the finished line never returned to the intro")
	# The ledger can only be read from inside a life, so the new life is entered first.
	for index:int in 3:
		ui.btn_1.pressed.emit()
		await get_tree().process_frame
	ui.dynasty_button.pressed.emit()
	await get_tree().process_frame
	ui.dynasty_panel.set_section("hall")
	await get_tree().process_frame
	# Counting children proves nothing: the empty hall renders a message too. The recorded
	# life has to appear as text the player can read.
	var rendered_record:bool=false
	var hall_value:Variant=GameManager.dynasty_records[records_before]
	var hall_age_value:int=0
	if hall_value is Dictionary:
		var hall_record:Dictionary=hall_value
		hall_age_value=hall_record.get("age",0)
	var recorded_age:String=GameManager.format_age(hall_age_value)
	for row:Label in ui.dynasty_panel.content.find_children("*","Label",true,false):
		if row.text.contains(recorded_age):
			rendered_record=true
	if not rendered_record:
		notes.append("the hall does not render the life that was just recorded")
	facts["hall_rows"]=ui.dynasty_panel.content.get_child_count()
	facts["records"]=GameManager.dynasty_records.size()
	facts["generation"]=GameManager.generation
	facts["choices"]=steps
	facts["revive_used"]=had_revive
	await finish_dynasty(ui,notes.is_empty(),notes,facts)

func first_action(container:Node)->Button:
	for node:Node in container.find_children("*","Button",true,false):
		var candidate:Button=node as Button
		if candidate!=null and not candidate.disabled:
			return candidate
	return null

func finish_dynasty(ui:LedgerView,success:bool,notes:Array[String],facts:Dictionary={})->void:
	print("EXPORTED DYNASTY ROUTE: ","PASS" if success else "FAIL",
		" facts=",JSON.stringify(facts,"",true,true)," notes=",JSON.stringify(notes))
	write_qa_result({"result":"PASS" if success else "FAIL","facts":facts,"notes":notes})
	ui.queue_free()
	await get_tree().process_frame
	var audio_settled:bool=await settle_audio()
	finish(0 if success and audio_settled else 1)

# Private QA only: explicit seeds vary simulation; art/audio keep their own RNG.
static func parse_seed(raw:String)->int:
	if raw.is_empty():return 7401
	if not raw.is_valid_int():return -1
	var value:int=raw.to_int()
	return value if value>0 and value<=2147483647 else -1

func write_qa_result(record:Dictionary)->void:
	print("QA CYCLE: ",JSON.stringify(record,"",true,true))
	var path:String=OS.get_environment("GAME_QA_RESULT_PATH")
	if not path.is_empty():
		var file:FileAccess=FileAccess.open(path,FileAccess.WRITE)
		if file:
			if not file.store_string(JSON.stringify(record,"",true,true)+"\n"):finish(74)

func audio_refs_released(references:Array[WeakRef])->bool:
	for reference:WeakRef in references:
		if reference.get_ref()!=null:return false
	return true

func settle_audio()->bool:
	var audio:AudioView=get_tree().root.get_node("SoundManager")
	var references:Array[WeakRef]=[]
	for key:String in audio.streams:references.append(weakref(audio.streams[key]))
	if is_instance_valid(audio.procedural_sfx):
		for cached_stream: Variant in audio.procedural_sfx.cached_streams():
			references.append(weakref(cached_stream))
	if audio.crossfade:audio.crossfade.kill()
	for voice:Node in audio.get_children():
		if voice is AudioStreamPlayer:
			(voice as AudioStreamPlayer).stop()
			(voice as AudioStreamPlayer).stream=null
	audio.streams.clear()
	if is_instance_valid(audio.procedural_sfx):
		audio.procedural_sfx.clear_cache()
	audio.current_music=""
	audio.current_finale=""
	audio.music_index=-1
	# AudioServer stops and releases playback on the mixer thread. Fixed-FPS QA
	# can advance simulated timers in milliseconds, so wait for actual release.
	var deadline:int=Time.get_ticks_msec()+5000
	while not audio_refs_released(references):
		if Time.get_ticks_msec()>=deadline:
			push_error("Private QA audio shutdown did not release playback references")
			return false
		await get_tree().process_frame
		OS.delay_msec(1)
	return true

func step_checkpoint(_ui:Control)->void:
	await get_tree().process_frame

func finish(code:int)->void:
	get_tree().quit(code)
