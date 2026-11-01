extends HFlowContainer
## Presentation-only echo of the last applied model delta.
const Palette=preload("res://scripts/ui/Palette.gd")
const SkinTheme=preload("res://scripts/ui/FortuneTheme.gd")
var reveal:Tween
var shown_delta:Dictionary={}

func _ready() -> void:
	add_theme_constant_override("h_separation",6)
	add_theme_constant_override("v_separation",6)
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	# Chip borders are mixed from the raised surface, so a switch rebuilds the chips
	# rather than only re-tinting their labels.
	@warning_ignore("return_value_discarded")
	GameManager.theme_changed.connect(func(_mode:String)->void:
		if visible: present(shown_delta))
	hide()

func clear_chips() -> void:
	for child:Node in get_children():
		remove_child(child)
		child.queue_free()

func signed_money(value:float) -> String:
	var sign_text:String="+" if value>0.0 else "-"
	return sign_text+"$"+GameManager.format_num(absf(value))

func signed_stat(value:int) -> String:
	var sign_text:String="+" if value>0 else ""
	return sign_text+str(value)

func chip(text:String, token:String) -> void:
	var tint:Color=Palette.color_for(token)
	var box:PanelContainer=PanelContainer.new()
	box.mouse_filter=Control.MOUSE_FILTER_IGNORE
	box.add_theme_stylebox_override("panel",SkinTheme.panel(Color(Palette.raised(),0.55),tint,10))
	var label:Label=Label.new()
	label.text=text
	label.mouse_filter=Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size",13)
	Palette.paint(label,token)
	box.add_child(label)
	add_child(box)

func present(delta:Dictionary) -> void:
	clear_chips()
	shown_delta=delta
	if delta.is_empty():
		hide()
		return
	var shown:bool=false
	var cash:float=delta.get("cash",0.0)
	if not is_zero_approx(cash):
		chip(LocalizationManager.source("delta.cash")+" "+signed_money(cash),"accent" if cash>0.0 else "alert")
		shown=true
	var stats:Array[String]=["health","intellect","stress","happiness","energy"]
	for key:String in stats:
		var value:int=delta.get(key,0)
		if value==0:
			continue
		var positive_good:bool=key!="stress"
		var token:String="green" if (value>0)==positive_good else "alert"
		chip(LocalizationManager.source("delta."+key)+" "+signed_stat(value),token)
		shown=true
	if not shown:
		hide()
		return
	show()
	if is_instance_valid(reveal):
		reveal.kill()
	if GameManager.reduced_motion:
		modulate.a=1.0
		return
	modulate.a=0.0
	reveal=create_tween()
	# Tween owns this fluent configuration; no reference to the builder is needed.
	@warning_ignore("return_value_discarded")
	reveal.tween_property(self,"modulate:a",1.0,0.22).set_trans(Tween.TRANS_SINE)
