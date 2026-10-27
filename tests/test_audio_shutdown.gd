extends SceneTree
var failures:int=0
func _initialize()->void:call_deferred("run")
func check(ok:bool,label:String)->void:
 if not ok:failures+=1;print("FAIL: ",label)
func audio_refs(audio:Node)->Array[WeakRef]:
 var result:Array[WeakRef]=[]
 for key:String in audio.streams:result.append(weakref(audio.streams[key]))
 return result
func run()->void:
 await process_frame
 var audio:Node=root.get_node("SoundManager")
 audio.play_music("welcome",0.0)
 @warning_ignore("return_value_discarded")
 audio.play_sfx("ui_click")
 audio.play_finale(true)
 await process_frame
 var references:Array[WeakRef]=audio_refs(audio)
 check(references.size()>=3,"Exercise real music, effect and finale streams")
 check(await audio.shutdown(),"Terminal audio cleanup finishes within its bounded deadline")
 for reference:WeakRef in references:check(reference.get_ref()==null,"Shutdown releases every mixer-owned stream")
 var serial:int=audio.feedback_serial
 audio.play_music("study",0.0)
 audio.play_finale(false)
 check(audio.play_sfx("ui_click")==null,"Late UI callbacks cannot restart effects while quitting")
 check(audio.streams.is_empty() and audio.feedback_serial==serial,"Terminal guard prevents new streams and feedback")
 check(await audio.shutdown(),"Repeated terminal shutdown is safe and idempotent")
 print("AUDIO SHUTDOWN RESULT: ","PASS" if failures==0 else "FAIL")
 quit(0 if failures==0 else 1)
