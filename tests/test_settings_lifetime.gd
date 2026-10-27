extends SceneTree
var failures:int=0
func _initialize()->void:call_deferred("run")
func check(ok:bool,label:String)->void:
	if not ok:failures+=1;print("FAIL: ",label)
func run()->void:
	await process_frame
	var locale:Node=root.get_node("LocalizationManager")
	var baseline:int=locale.language_changed.get_connections().size()
	for cycle:int in 3:
		var panel:Control=load("res://scripts/audio/AudioSettings.gd").new()
		root.add_child(panel)
		await process_frame
		for language:String in ["en","ru"]:
			locale.set_language(language)
			var picker:OptionButton=panel.get_node("SettingsLanguage")
			check(picker.selected==(0 if language=="ru" else 1),"Live language picker matches locale")
			var labels:Array=panel.find_children("*","Label",true,false)
			check(not labels.is_empty() and labels[0].text==locale.source("ui.master"),"Audio row labels translate immediately")
		panel.queue_free()
		await process_frame
		check(locale.language_changed.get_connections().size()==baseline,"Freed settings panel leaves no persistent locale callback")
		locale.set_language("en" if cycle%2 else "ru")
	print("SETTINGS LIFETIME RESULT: ","PASS" if failures==0 else "FAIL")
	if not await root.get_node("SoundManager").shutdown():
		quit(1)
		return
	quit(0 if failures==0 else 1)
