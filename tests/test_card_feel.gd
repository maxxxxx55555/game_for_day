extends SceneTree
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
    check(chip_color(chip_index(cash_text))==Color("c9a227"),"Gained cash uses the gold tone")
    check(chip_color(chip_index(health_text))==Color("c4614f"),"Lost health uses the alert tone")
    check(chip_color(chip_index(intellect_text))==Color("7fb069"),"Gained intellect uses the positive tone")
    check(chip_color(chip_index(stress_text))==Color("c4614f"),"Rising stress uses the alert tone")
    check(chip_color(chip_index(energy_text))==Color("c4614f"),"Lost energy uses the alert tone")
    check(screen.outcome.get_theme_color("font_color")==Color("c4614f"),"A mixed card tints its outcome line with the bad tone")
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
    game.last_delta={"cash":10.0,"health":0,"stress":0}
    check(screen.outcome_tone()==Color("7fb069"),"Positive cash without harm reads as a good outcome")
    game.last_delta={"cash":10.0,"health":-1,"stress":0}
    check(screen.outcome_tone()==Color("c4614f"),"Any health loss overrides a cash gain")
    game.last_delta={"cash":-5.0,"health":2,"stress":-1}
    check(screen.outcome_tone()==Color("c4614f"),"Lost cash reads as a bad outcome")
    game.last_delta={"cash":0.0,"health":0,"stress":1}
    check(screen.outcome_tone()==Color("c4614f"),"Rising stress reads as a bad outcome")
    game.last_delta={"cash":0.0,"health":0,"stress":0}
    check(screen.outcome_tone()==Color("c9a227"),"A neutral delta keeps the gold tone")
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
