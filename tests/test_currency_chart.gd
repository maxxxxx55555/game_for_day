extends SceneTree
var failures:=0
func _initialize() -> void:call_deferred("run")
func check(ok:bool,label:String) -> void:
	if not ok:failures+=1;print("FAIL: ",label)
func run() -> void:
	await process_frame
	var game:Node=root.get_node("GameManager")
	game.fx.history["EUR"]=[1.0,1.25,1.1]
	var chart:Control=load("res://scripts/ui/CurrencySparkline.gd").new()
	chart.code="EUR";chart.size=Vector2(440,104);root.add_child(chart)
	await process_frame
	var labels:Array=[]
	for label in chart.find_children("*","Label",true,false):labels.append(label.text)
	check(labels.any(func(t):return "USD" in t and "EUR" in t),"Currency graph identifies its actual quote unit")
	check(labels.has("1.2500") and labels.has("1.0000"),"Currency graph shows high and low scale values from real samples")
	check(labels.any(func(t):return "2" in t),"History axis identifies the two preceding samples")
	if chart.has_method("refresh_labels"):
		game.fx.history["EUR"]=[1.125];chart.refresh_labels()
		check(chart.find_children("*","Label",true,false).any(func(t):return t.text=="1.1250"),"Single flat sample has an honest readable scale")
	chart.size=Vector2(380,112)
	await process_frame;await process_frame
	for label in chart.find_children("*","Label",true,false):check(Rect2(Vector2.ZERO,chart.size).encloses(label.get_rect()),"Chart label stays inside plot after resize: "+label.name)
	print("CURRENCY CHART RESULT: ","PASS" if failures==0 else "FAIL")
	quit(0 if failures==0 else 1)
