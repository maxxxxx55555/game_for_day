extends SceneTree
const Guard=preload("res://scripts/security/SaveGuard.gd")
var failures:int=0
var references:Array[WeakRef]=[]
var mode:String="save"
var persistence_signals:int=0
var screen:Control
var reached_exit:bool=false
var game:Node
var arrival:Node
var original_save:String=""
var boot_opened_ledger:bool=false
func _initialize()->void:call_deferred("run")
func check(ok:bool,label:String)->void:
 if not ok:failures+=1;print("FAIL: ",label)
func capture_references(audio:Node)->void:
 references.clear()
 for key:String in audio.streams:references.append(weakref(audio.streams[key]))
func block_save()->void:
 DirAccess.remove_absolute(game.SESSION_PATH+".tmp")
 check(DirAccess.make_dir_absolute(game.SESSION_PATH+".tmp")==OK,"Create real blocked-save fixture")
func unblock_save()->void:DirAccess.remove_absolute(game.SESSION_PATH+".tmp")
func on_audio_exit()->void:
 var alive:int=0
 for reference:WeakRef in references:
  if reference.get_ref()!=null:alive+=1
 check(reached_exit,"Only an accepted save/discard/boot close reaches terminal shutdown")
 check(alive==0,"Normal quit drains real cached/mixer audio references before SceneTree teardown")
 if mode in ["save","wm","retry"]:
  var saved:Dictionary=game.load_current_life()
  check(not saved.is_empty() and game.cash==31415,"Accepted quit preserves the actual saved life")
  if mode=="save":check(game.ambition=="heir","Escape from the life closes through the save that carries the chosen ambition")
 if mode in ["save","wm","retry"]:check(persistence_signals==1,"Repeated accepted close/Retry requests save once")
 if mode=="discard":check(persistence_signals==0,"Queued Retry after accepted discard cannot save")
 if mode=="discard":check(Guard.bounded_text(game.SESSION_PATH)==original_save,"Discard preserves the previous valid save")
 if mode=="boot":check(not boot_opened_ledger,"Closing boot does not open a new ledger during shutdown")
 print("QUIT AUDIO EXIT: mode=",mode," alive=",alive)
 print("QUIT AUDIO RESULT: ","PASS" if failures==0 else "FAIL")
 quit(0 if failures==0 else 1)
func run()->void:
 await process_frame
 game=root.get_node("GameManager")
 arrival=root.get_node("FortuneArrival")
 for candidate:String in ["wm","boot","retry","discard"]:
  if OS.get_cmdline_user_args().has("--"+candidate):mode=candidate
 var audio:Node=root.get_node("SoundManager")
 audio.tree_exiting.connect(on_audio_exit)
 root.child_entered_tree.connect(func(node:Node)->void:
  if mode=="boot" and node.has_method("request_exit"):boot_opened_ledger=true
 )
 if mode=="boot":
  screen=load("res://scenes/Boot.tscn").instantiate()
  root.add_child(screen);current_scene=screen
  audio.play_music("welcome",0.0)
  capture_references(audio)
  reached_exit=true
  root.propagate_notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
  return
 game.reset_full_dynasty()
 screen=load("res://scenes/Main.tscn").instantiate()
 root.add_child(screen);current_scene=screen
 screen.show_intro_screen()
 if mode=="save":
  screen.ambition_buttons[2].pressed.emit()
 for index:int in 3:screen.btn_1.pressed.emit()
 game.cash=31415
 check(screen.save_session(),"Prepare a legitimate persisted life")
 original_save=Guard.bounded_text(game.SESSION_PATH)
 await process_frame
 if mode in ["retry","discard"]:
  block_save()
  screen.request_exit()
  await process_frame
  check(is_instance_valid(arrival.unsaved_dialog) and arrival.unsaved_dialog.visible,"Failed save keeps the existing unsaved-choice dialog")
  check(not audio.streams.is_empty(),"Failed save leaves gameplay audio active")
  arrival.unsaved_dialog.confirmed.emit()
  await process_frame;await process_frame
  check(is_instance_valid(arrival.unsaved_dialog) and arrival.unsaved_dialog.visible,"A failed Retry stays in the game")
  if mode=="discard":
   arrival.unsaved_dialog.canceled.emit()
   await process_frame
   check(is_instance_valid(screen) and not is_instance_valid(arrival.unsaved_dialog),"Stay closes only the unsaved dialog")
   check(not audio.streams.is_empty(),"Stay does not enter terminal audio shutdown")
   screen.request_exit()
   await process_frame
   capture_references(audio)
   reached_exit=true
   game.persistence_changed.connect(func(_okay:bool)->void:persistence_signals+=1)
   var accepted_dialog:ConfirmationDialog=arrival.unsaved_dialog
   accepted_dialog.custom_action.emit(&"discard")
   accepted_dialog.confirmed.emit()
   accepted_dialog.custom_action.emit(&"discard")
   unblock_save()
  else:
   unblock_save()
   capture_references(audio)
   reached_exit=true
   game.persistence_changed.connect(func(_okay:bool)->void:persistence_signals+=1)
   var accepted_dialog:ConfirmationDialog=arrival.unsaved_dialog
   accepted_dialog.confirmed.emit()
   accepted_dialog.confirmed.emit()
   accepted_dialog.custom_action.emit(&"discard")
  return
 game.persistence_changed.connect(func(_okay:bool)->void:persistence_signals+=1)
 capture_references(audio)
 reached_exit=true
 if mode=="wm":
  root.propagate_notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
  screen._notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
  root.propagate_notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
 else:
  screen._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
  screen._notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
  screen.request_exit()
