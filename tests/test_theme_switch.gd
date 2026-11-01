extends SceneTree
# The skin switch is the owner's fifth check; this case drives it for real and
# grades the result on measurements instead of a screenshot.
const Palette=preload("res://scripts/ui/Palette.gd")
const SkinTheme=preload("res://scripts/ui/FortuneTheme.gd")
const TOKENS:Array[String]=["ink","surface","raised","deep","rule","rule_soft","text","muted","accent","accent_deep","green","alert","track","shadow"]
var failures:int=0
var game:Node
var screen:Control
var emissions:Array[String]=[]
func _initialize()->void:call_deferred("run")
func check(ok:bool,label:String)->void:
	if not ok:failures+=1;print("FAIL: ",label)
func set_skin(mode:String)->void:
	game.set_theme_mode(mode)
	await process_frame
	await process_frame
func palette_now()->Dictionary:
	return {
		"ink":Palette.ink(),"surface":Palette.surface(),"raised":Palette.raised(),
		"deep":Palette.deep(),"rule":Palette.rule(),"rule_soft":Palette.rule_soft(),
		"text":Palette.text(),"muted":Palette.muted(),"accent":Palette.accent(),
		"accent_deep":Palette.accent_deep(),"green":Palette.green(),"alert":Palette.alert(),
		"track":Palette.track(),"shadow":Palette.shadow()
	}
func linearize(value:float)->float:
	return value/12.92 if value<=0.03928 else pow((value+0.055)/1.055,2.4)
func luminance(color:Color)->float:
	return 0.2126*linearize(color.r)+0.7152*linearize(color.g)+0.0722*linearize(color.b)
func contrast(one:Color,other:Color)->float:
	var high:float=maxf(luminance(one),luminance(other))
	var low:float=minf(luminance(one),luminance(other))
	return (high+0.05)/(low+0.05)
func under_finale(node:Node)->bool:
	var parent:Node=node.get_parent()
	while parent!=null:
		if parent==screen.finale_overlay: return true
		parent=parent.get_parent()
	return false
func finale_sheet()->Array:
	var seen:Array=[]
	for label:Label in screen.finale_overlay.find_children("*","Label",true,false):
		seen.append(label.get_theme_color("font_color").to_html(true))
	return seen
func finale_marked()->int:
	var marked:int=0
	for label:Label in screen.finale_overlay.find_children("*","Label",true,false):
		if label.has_meta("palette_token"): marked+=1
	return marked
func run()->void:
	await process_frame
	game=root.get_node("GameManager")
	game.theme_changed.connect(func(mode:String)->void:emissions.append(mode))
	set_skin("dark")
	var dark:Dictionary=palette_now()
	set_skin("light")
	var light:Dictionary=palette_now()
	check(Palette.mode()=="light","Every palette call follows the manager, not a cached sheet")
	for token:String in TOKENS:
		check(dark[token]!=light[token],"The two skins disagree on %s (%s versus %s)" % [token,dark[token],light[token]])
	# Readability floors measured on the shipped numbers, not asserted as a brand claim.
	var floors:Array=[["text","surface",7.0],["text","raised",7.0],["text","deep",7.0],
		["muted","surface",4.5],["muted","raised",4.5],
		["accent","surface",3.0],["accent","deep",3.0],
		["green","surface",3.0],["alert","surface",3.0]]
	for skin_pair:Array in [[dark,"ink"],[light,"paper"]]:
		var values:Dictionary=skin_pair[0]
		for floor:Array in floors:
			var ratio:float=contrast(values[floor[0]],values[floor[1]])
			check(ratio>=float(floor[2]),"%s on %s holds at least %.1f:1 in the %s skin (measured %.2f)" % [floor[0],floor[1],floor[2],skin_pair[1],ratio])
	screen=load("res://scenes/Main.tscn").instantiate()
	root.add_child(screen)
	current_scene=screen
	await process_frame
	check(screen.theme!=null,"The screen installs a theme before any skin can be graded")
	set_skin("light")
	var theme_light:Color=screen.theme.get_color("font_color","Label")
	check(theme_light==light.text,"The rebuilt theme paints labels with the paper skin")
	set_skin("dark")
	check(screen.theme.get_color("font_color","Label")==dark.text,"Switching back rebuilds the ink theme")
	set_skin("light")
	check(screen.event_label.get_theme_color("font_color")==light.text,"The event copy repaints to the active skin")
	check(screen.stage_label.get_theme_color("font_color")==light.accent,"The chapter overline repaints to the active accent")
	check(screen.theme_button!=null and screen.theme_button.get_theme_color("icon_normal_color")==light.accent,"The skin toggle's own icon follows the skin")
	var backdrop:StyleBoxFlat=screen.dynasty_panel.backdrop.get_theme_stylebox("panel") as StyleBoxFlat
	check(backdrop!=null and backdrop.bg_color==light.ink,"The dynasty ledger backdrop repaints, not just refreshes")
	var milestone:StyleBoxFlat=screen.milestone_card.card.get_theme_stylebox("panel") as StyleBoxFlat
	check(milestone!=null and milestone.bg_color==light.surface,"The milestone card repaints its panel")
	var stale:Array[String]=[]
	for label:Label in screen.find_children("*","Label",true,false):
		if under_finale(label): continue
		var painted:Color=label.get_theme_color("font_color")
		for token:String in TOKENS:
			if painted==dark[token] and painted!=light[token]:
				stale.append(str(label.get_path())+" keeps "+token)
	check(stale.is_empty(),"No label keeps an ink token while the paper skin is active: "+", ".join(stale.slice(0,10)))
	set_skin("dark")
	var kept:Array[String]=[]
	for label:Label in screen.find_children("*","Label",true,false):
		if under_finale(label): continue
		var painted:Color=label.get_theme_color("font_color")
		for token:String in TOKENS:
			if painted==light[token] and painted!=dark[token]:
				kept.append(str(label.get_path())+" keeps "+token)
	check(kept.is_empty(),"Switching back leaves no paper token behind: "+", ".join(kept.slice(0,10)))
	# The finale is a staged sheet with its own scrim (LifeFinale's STAGE_* values), so
	# its type has to be provably identical in both skins rather than excused from the scan.
	set_skin("light")
	var paper_sheet:Array=finale_sheet()
	set_skin("dark")
	var ink_sheet:Array=finale_sheet()
	check(paper_sheet.size()>=6,"The staged finale offers its type for measurement (%d labels)" % paper_sheet.size())
	check(paper_sheet==ink_sheet,"The finale keeps one staged sheet in either skin (%s versus %s)" % [str(paper_sheet.slice(0,3)),str(ink_sheet.slice(0,3))])
	check(finale_marked()==0,"The staged sheet opts out of the skin system on purpose, not by accident")
	var turns:int=game.total_turns
	var rng_before:int=screen.rng.state
	set_skin("light")
	check(game.total_turns==turns and screen.rng.state==rng_before,"Changing the skin spends no quarter and no event RNG")
	var before:int=emissions.size()
	set_skin("light")
	check(emissions.size()==before,"Re-applying the active skin emits nothing")
	set_skin("dark")
	check(emissions.size()==before+1 and emissions[before]=="dark","Switching emits exactly one theme_changed")
	var dark_button:Texture2D=(SkinTheme.surface("normal") as StyleBoxTexture).texture
	set_skin("light")
	var light_button:Texture2D=(SkinTheme.surface("normal") as StyleBoxTexture).texture
	check(dark_button!=null and light_button!=null and dark_button!=light_button,"Button art is selected per skin, and both sets load")
	check(Palette.button_variant()=="-light","The paper skin asks for the light button set")
	set_skin("light")
	var before_reload:String=str(game.theme_mode)
	game.load_dynasty()
	check(game.theme_mode==before_reload,"The chosen skin survives a settings reload")
	set_skin("dark")
	var intro_switches:int=emissions.size()
	screen.theme_button.pressed.emit()
	check(game.theme_mode=="light" and emissions.size()==intro_switches+1,"The intro toggle button drives the real switch")
	screen.theme_button.pressed.emit()
	check(game.theme_mode=="dark","The intro toggle returns to ink")
	var panel:Control=load("res://scripts/audio/AudioSettings.gd").new()
	root.add_child(panel)
	await process_frame
	var picker:OptionButton=null
	for candidate:OptionButton in panel.find_children("*","OptionButton",true,false):
		if candidate.name=="SettingsTheme":picker=candidate
	check(picker!=null and picker.selected==0,"The settings picker opens on the stored skin")
	if picker!=null:
		picker.select(1)
		picker.item_selected.emit(1)
		check(game.theme_mode=="light","The settings picker writes the choice through the same setter")
		picker.select(0)
		picker.item_selected.emit(0)
		check(game.theme_mode=="dark","The settings picker switches back")
	panel.queue_free()
	await process_frame
	set_skin("dark")
	print("THEME SWITCH RESULT: ","PASS" if failures==0 else "FAIL")
	if not await root.get_node("SoundManager").shutdown():
		quit(1)
		return
	quit(0 if failures==0 else 1)
