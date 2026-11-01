extends SceneTree
const Palette=preload("res://scripts/ui/Palette.gd")
var failures:int=0
var game:Node
var screen:Control
func _initialize()->void:call_deferred("run")
func check(ok:bool,label:String)->void:
    if not ok:failures+=1;print("FAIL: ",label)
func txt(key:String)->String:return root.get_node("LocalizationManager").source(key)
func emoji_free(text:String)->bool:
    for index:int in text.length():
        var code:int=text.unicode_at(index)
        if code>=0x1f000 and code<=0x1faff:return false
        if code>=0x2600 and code<=0x27ff:return false
        if code in [0xfe0f,0x200d]:return false
    return true
func scan_copy(node:Node,label:String)->void:
    for child:Node in node.find_children("*","Control",true,false):
        if not child.is_visible_in_tree():continue
        if child is OptionButton:
            var picker:OptionButton=child
            for item:int in picker.item_count:
                check(emoji_free(picker.get_item_text(item)),"Option copy avoids emoji: "+label+" item "+str(item))
        elif child is Label:
            var tag:Label=child
            check(emoji_free(tag.text),"Label copy avoids emoji: "+label+" "+tag.text)
        elif child is Button:
            var action:Button=child
            check(emoji_free(action.text),"Button copy avoids emoji: "+label+" "+action.text)
        elif child is RichTextLabel:
            var rich:RichTextLabel=child
            check(emoji_free(rich.text),"Rich copy avoids emoji: "+label)
func chip_text(index:int)->String:
    var box:Node=screen.delta_chips.get_child(index)
    var label:Label=box.get_child(0)
    return label.text
func chip_color(index:int)->Color:
    var box:Node=screen.delta_chips.get_child(index)
    var label:Label=box.get_child(0)
    return label.get_theme_color("font_color")
func chip_index(text:String)->int:
    for index:int in screen.delta_chips.get_child_count():
        if chip_text(index)==text:return index
    return -1
func run()->void:
    await process_frame
    game=root.get_node("GameManager")
    game.reset_full_dynasty()
    screen=load("res://scenes/Main.tscn").instantiate()
    root.add_child(screen);current_scene=screen
    await process_frame
    var origin:Vector2=Vector2(480,161)
    var box:Vector2=Vector2(164,21)
    check(screen.dashboard!=null,"The dashboard owns the pulse painter")
    check(screen.dashboard.pulse_points(origin,box).is_empty(),"A single market reading draws no sparkline")
    screen.open_chain_thread("library_workshop")
    await process_frame
    var panel:Control=screen.get_node("MarginContainer/VBoxContainer/EventPanel")
    game.reduced_motion=true
    screen.animate_story()
    check(panel.scale==Vector2.ONE and is_equal_approx(panel.modulate.a,1.0),"Reduced motion skips the card reveal")
    game.reduced_motion=false
    screen.animate_story()
    check(panel.scale.x<1.0 and panel.modulate.a<1.0,"The normal card reveal starts compressed")
    await create_timer(0.35).timeout
    check(panel.scale.distance_to(Vector2.ONE)<0.01 and is_equal_approx(panel.modulate.a,1.0),"The card reveal settles at full scale and opacity")
    screen.btn_1.pressed.emit()
    await process_frame
    var chips:Node=screen.delta_chips
    check(chips.visible,"Delta chips appear after a choice")
    check(chips.get_child_count()==6,"Every changed stat owns a chip")
    var cash_text:String=txt("delta.cash")+" +$"+game.format_num(600.0)
    var health_text:String=txt("delta.health")+" -1"
    var intellect_text:String=txt("delta.intellect")+" +2"
    var stress_text:String=txt("delta.stress")+" +1"
    var happiness_text:String=txt("delta.happiness")+" +3"
    var energy_text:String=txt("delta.energy")+" -8"
    check(chip_index(cash_text)>=0,"The cash chip shows a signed dollar delta")
    check(chip_index(health_text)>=0 and chip_index(intellect_text)>=0,"Stat chips use signed values")
    check(chip_index(stress_text)>=0 and chip_index(happiness_text)>=0 and chip_index(energy_text)>=0,"All six real deltas are echoed")
    check(chip_color(chip_index(cash_text))==Palette.color_for("accent"),"Gained cash uses the accent tone of the active skin")
    check(chip_color(chip_index(health_text))==Palette.color_for("alert"),"Lost health uses the alert tone of the active skin")
    check(chip_color(chip_index(intellect_text))==Palette.color_for("green"),"Gained intellect uses the positive tone of the active skin")
    check(chip_color(chip_index(stress_text))==Palette.color_for("alert"),"Rising stress uses the alert tone of the active skin")
    check(chip_color(chip_index(energy_text))==Palette.color_for("alert"),"Lost energy uses the alert tone of the active skin")
    check(screen.outcome.get_meta("palette_token")=="alert" and screen.outcome.get_theme_color("font_color")==Palette.color_for("alert"),"A mixed card tints its outcome line with the alert tone")
    var history:Array=game.market_history
    var points:PackedVector2Array=screen.dashboard.pulse_points(origin,box)
    check(points.size()==history.size() and points.size()>=2,"The sparkline covers the full market history")
    if points.size()>=2:
        check(is_equal_approx(points[0].x,origin.x) and is_equal_approx(points[points.size()-1].x,origin.x+box.x),"The sparkline spans its full width")
        for point:Vector2 in points:
            check(point.y>=origin.y-0.01 and point.y<=origin.y+box.y+0.01,"The sparkline stays inside its frame")
    chips.present({})
    check(not chips.visible and chips.get_child_count()==0,"An empty delta hides every chip")
    var saved_delta:Dictionary=game.last_delta
    var saved_skin:String=str(game.theme_mode)
    game.last_delta={"cash":10.0,"health":0,"stress":0}
    check(screen.outcome_tone()=="green","Positive cash without harm reads the green tone")
    game.last_delta={"cash":10.0,"health":-1,"stress":0}
    check(screen.outcome_tone()=="alert","Any health loss overrides a cash gain")
    game.last_delta={"cash":-5.0,"health":2,"stress":-1}
    check(screen.outcome_tone()=="alert","Lost cash reads the alert tone")
    game.last_delta={"cash":0.0,"health":0,"stress":1}
    check(screen.outcome_tone()=="alert","Rising stress reads the alert tone")
    game.last_delta={"cash":0.0,"health":0,"stress":0}
    check(screen.outcome_tone()=="accent","A neutral delta keeps the accent tone")
    # The tone reaches the player only through the painted line and the chips, so both
    # are driven for real and then re-checked across a skin switch.
    game.last_delta={"cash":10.0,"health":0,"stress":0}
    screen.load_next_life_event("QA tone probe")
    await process_frame
    check(screen.outcome.get_meta("palette_token")=="green","The outcome line records the token it paints")
    check(screen.outcome.get_theme_color("font_color")==Palette.green(),"The outcome line draws the active green")
    chips.present({"cash":10.0,"health":1,"stress":0})
    await process_frame
    check(chips.get_child_count()>=2,"A mixed delta surfaces one chip per changed stat")
    var first_chip:Label=chips.get_child(0).get_child(0) as Label
    var accent_on_ink:Color=first_chip.get_theme_color("font_color") if first_chip!=null else Color.TRANSPARENT
    check(first_chip!=null and str(first_chip.get_meta("palette_token",""))=="accent","A cash gain chip records the accent token it paints")
    game.set_theme_mode("light")
    await process_frame
    await process_frame
    check(chips.get_child_count()>=2,"A skin switch does not drop the visible chips")
    var repainted:Label=chips.get_child(0).get_child(0) as Label
    var accent_on_paper:Color=repainted.get_theme_color("font_color") if repainted!=null else Color.TRANSPARENT
    check(repainted!=null and accent_on_paper!=accent_on_ink and accent_on_paper==Palette.color_for("accent"),
          "The same chip changes to the paper accent, so it is not a frozen hex")
    check(screen.outcome.get_theme_color("font_color")==Palette.color_for("green"),"The outcome tone follows the skin switch")
    game.set_theme_mode(saved_skin)
    await process_frame
    game.last_delta=saved_delta
    scan_copy(screen,"life")
    screen.open_dynasty_menu()
    await process_frame
    for section:String in screen.dynasty_panel.SECTIONS:
        screen.dynasty_panel.set_section(section)
        await process_frame
        scan_copy(screen.dynasty_panel,"dynasty "+section)
    screen.close_dynasty_menu()
    await process_frame
    game.check_milestones()
    screen.present_milestone_if_pending()
    await process_frame
    check(screen.milestone_card.visible,"The retrospective is visible for the copy scan")
    scan_copy(screen.milestone_card,"milestone")
    screen.milestone_card.dismiss()
    game.cash=300000000000.0
    game.age=60
    game.recalculate_forbes_rank()
    screen.trigger_game_over(txt("copy.35118a151aa7"),true)
    await process_frame
    check(screen.finale_overlay.visible and screen.finale_overlay.tertiary.visible,"The ascension finale is visible for the copy scan")
    scan_copy(screen.finale_overlay,"finale")
    print("CARD FEEL RESULT: ","PASS" if failures==0 else "FAIL")
    if not await root.get_node("SoundManager").shutdown():
        quit(1)
        return
    quit(0 if failures==0 else 1)
