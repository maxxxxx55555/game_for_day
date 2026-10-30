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
			var audio_keys:Array=["ui.master","copy.19ecb2b49349","copy.05321a5231ca","ui.interface"]
			var translated:int=0
			for control:Label in panel.find_children("*","Label",true,false):
				var key:String=str(control.get_meta("locale_key",""))
				if audio_keys.has(key) and control.text==locale.source(key):translated+=1
			check(translated==audio_keys.size(),"Every audio row label translates immediately")
			var theme_picker:OptionButton=panel.get_node("SettingsTheme")
			check(theme_picker.get_item_text(0)==locale.source("ui.theme.dark") and theme_picker.get_item_text(1)==locale.source("ui.theme.light"),"Theme picker items translate immediately")
		panel.queue_free()
		await process_frame
		check(locale.language_changed.get_connections().size()==baseline,"Freed settings panel leaves no persistent locale callback")
		locale.set_language("en" if cycle%2 else "ru")
	print("SETTINGS LIFETIME RESULT: ","PASS" if failures==0 else "FAIL")
	if not await root.get_node("SoundManager").shutdown():
		quit(1)
		return
	quit(0 if failures==0 else 1)
