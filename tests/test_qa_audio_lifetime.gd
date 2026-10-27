extends SceneTree
var failures:int=0
func _initialize()->void:call_deferred("run")
func check(ok:bool,label:String)->void:
 if not ok:failures+=1;print("FAIL: ",label)
func warm_audio(audio:Node)->void:
 for mood:String in ["welcome","study","career","tycoon"]:
  @warning_ignore("return_value_discarded")
  audio._stream(mood,true)
 for cue:String in ["ui_click","ui_focus","ui_error","grant","upgrade","victory"]:
  @warning_ignore("return_value_discarded")
  audio._stream(cue)
func start_audio(audio:Node)->void:
 for mood:String in ["welcome","study","career","tycoon"]:audio.play_music(mood,0.0)
 for index:int in 32:
  @warning_ignore("return_value_discarded")
  audio.play_sfx(["ui_click","ui_focus","ui_error","grant","upgrade"][index%5])
 audio.play_finale(true)
func audio_refs(audio:Node)->Array[WeakRef]:
 var refs:Array[WeakRef]=[]
 for stream:Variant in audio.streams.values():refs.append(weakref(stream))
 return refs
func run()->void:
 await process_frame
 var audio:Node=root.get_node("SoundManager")
 var route:Node=load("res://scripts/ReleaseVerification.gd").new()
 root.add_child(route)
 warm_audio(audio)
 start_audio(audio)
 await process_frame
 var refs:Array[WeakRef]=audio_refs(audio)
 check(refs.size()>=8,"Regression exercises multiple real cached audio streams")
 var started:int=Time.get_ticks_msec()
 var settled:bool=await route.settle_audio()
 check(settled,"Private QA confirms bounded mixer cleanup succeeded")
 var alive:int=0
 for reference:WeakRef in refs:
  if reference.get_ref()!=null:alive+=1
 check(alive==0,"Private QA shutdown releases mixer-owned audio references before quit")
 check(audio.streams.is_empty(),"Private QA leaves no cached streams")
 for voice:Node in audio.get_children():
  if voice is AudioStreamPlayer:check((voice as AudioStreamPlayer).stream==null,"Stopped players release their stream")
 print("QA AUDIO SETTLE: alive=",alive," elapsed_wall_ms=",Time.get_ticks_msec()-started)
 print("QA AUDIO LIFETIME RESULT: ","PASS" if failures==0 else "FAIL")
 route.queue_free()
 await process_frame
 quit(0 if failures==0 else 1)
