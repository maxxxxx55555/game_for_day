extends SceneTree
var failures:int=0
func _initialize()->void:call_deferred("run")
func check(ok:bool,label:String)->void:
    if not ok:failures+=1;print("FAIL: ",label)
func run()->void:
    await process_frame
    if DisplayServer.get_name()=="headless":
        check(false,"Chart path regression needs a real rendering device");quit(1);return
    var game:Node=root.get_node("GameManager")
    game.fx.history["EUR"]=[1.0,1.25,1.1]
    var viewport:SubViewport=SubViewport.new()
    viewport.size=Vector2i(440,140)
    viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var chart:Control=load("res://scripts/ui/CurrencySparkline.gd").new()
    chart.code="EUR";chart.size=Vector2(440,140);viewport.add_child(chart)
    await process_frame;await process_frame;await RenderingServer.frame_post_draw
    var image:Image=viewport.get_texture().get_image()
    var accent:Color=Color("c6ad7a")
    var pixels:int=0
    for y:int in range(32,108):
        for x:int in range(80,432):
            var color:Color=image.get_pixel(x,y)
            if absf(color.r-accent.r)<0.05 and absf(color.g-accent.g)<0.05 and absf(color.b-accent.b)<0.05:pixels+=1
    check(pixels>250,"Historical quote path remains visibly drawn after a successful packed-array append; pixels="+str(pixels))
    viewport.queue_free();await process_frame
    print("CHART PATH REGRESSION RESULT: ","PASS" if failures==0 else "FAIL")
    if not await root.get_node("SoundManager").shutdown():
        quit(1)
        return
    quit(0 if failures==0 else 1)
