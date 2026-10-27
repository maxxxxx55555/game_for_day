extends SceneTree
var failures:int=0
func _initialize()->void:call_deferred("run")
func check(ok:bool,label:String)->void:
    if not ok:failures+=1;print("FAIL: ",label)
func run()->void:
    await process_frame
    var guard:GDScript=load("res://scripts/security/SaveGuard.gd")
    var cfg:ConfigFile=ConfigFile.new()
    var values:Dictionary={"rate":1.2953734149885179,"small":0.006434679023626447,"adjacent":1.0000000000000002,"rng":4982362058550442692,"nested":{"EUR":[1.08]},"copy":"Кавычки \" · newline\nEnglish"}
    values["rate"]="80bc5779d9b9f43f".hex_decode().decode_double(0)
    values["small"]="d0bc77ff3f5b7a3f".hex_decode().decode_double(0)
    values["adjacent"]="010000000000f03f".hex_decode().decode_double(0)
    for field:String in values:cfg.set_value("precision",field,values[field])
    cfg.set_value("quoted section","quoted=key",values)
    values.nested.EUR.append(values.rate)
    var encoded:String=guard.config_text(cfg,"precision/regression")
    check(not encoded.is_empty() and guard.atomic_text("user://precision-regression.cfg",encoded),"Authenticated exact-float checkpoint writes")
    var loaded:ConfigFile=guard.config_candidate("user://precision-regression.cfg","precision/regression")
    check(loaded!=null,"Native ConfigFile parser reads the signed checkpoint")
    if loaded:
        for field:String in values:check(JSON.stringify(loaded.get_value("precision",field),"",true,true)==JSON.stringify(values[field],"",true,true),"Native value remains bit exact across save/load: "+field)
        check(JSON.stringify(loaded.get_value("quoted section","quoted=key"),"",true,true)==JSON.stringify(values,"",true,true),"Native section and field quoting survive exact serialization")
    print("CONFIG FLOAT PRECISION RESULT: ","PASS" if failures==0 else "FAIL")
    if not await root.get_node("SoundManager").shutdown():
        quit(1)
        return
    quit(0 if failures==0 else 1)
