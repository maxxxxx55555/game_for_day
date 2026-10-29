extends Control
## Compact actual balances, birthplace and decision-relevant condition meters.
## The portrait is gone on purpose: a random-country run has no single face.
const INK:Color= Color("f1eee7")
const MUTED:Color= Color("b8c2c4")
const GOLD:Color= Color("c9a227")
const GOLD_DIM:Color= Color("a9871f")
const RULE:Color= Color("3e5c76")
const TRACK:Color= Color("2e4057")
const ALERT:Color= Color("c4614f")
const BirthLottery=preload("res://scripts/BirthLottery.gd")
var display_cash:float=0.0
var display_worth:float=0.0
var target_cash:float=0.0
var target_worth:float=0.0
var values_ready:bool=false
var balance_tween:Tween

## Country name for the current run, or an em dash before the lottery runs.
func birthplace() -> String:
	if GameManager.birth_country_code.is_empty():
		return "—"
	var row:Array= BirthLottery.by_code(GameManager.birth_country_code)
	if row.is_empty():
		return GameManager.birth_origin if not GameManager.birth_origin.is_empty() else "—"
	return LocalizationManager.display(BirthLottery.country_name(GameManager.birth_country_code))

func birthplace_region() -> String:
	if GameManager.birth_country_code.is_empty():
		return ""
	var row:Array= BirthLottery.by_code(GameManager.birth_country_code)
	if row.is_empty():
		return ""
	return LocalizationManager.display(BirthLottery.region_name(str(row[1])))

## Share of the country's influence that still applies to income and costs.
func origin_note() -> String:
	var influence:int= roundi(GameManager.origin_influence() * 100.0)
	return LocalizationManager.source("dashboard.grip") % influence

func _ready() -> void:
	custom_minimum_size.y = 196
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	resized.connect(queue_redraw)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	LocalizationManager.language_changed.connect(func(_language:Variant)->void:queue_redraw())
	set_process(false)
	refresh_values(true)

func caption(at: Vector2, text: String, font_size: int, color: Color = INK) -> void:
	draw_string(get_theme_default_font(), at, LocalizationManager.display(text), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func caption_right(right_edge: float, top: float, text: String, font_size: int, color: Color) -> void:
	draw_string(get_theme_default_font(), Vector2(0, top), LocalizationManager.display(text), HORIZONTAL_ALIGNMENT_RIGHT, right_edge, font_size, color)

func _draw() -> void:
	var s:float= size.x / 644.0
	draw_set_transform(Vector2.ZERO, 0, Vector2(s,s))
	var country:String= birthplace()
	var meta:String= LocalizationManager.source("copy.d0e02c3cc5dc") % [GameManager.age,GameManager.quarter,GameManager.generation]
	# Keep the metadata separate; the birth card already shows the region.
	var top_line:String= country.to_upper()
	caption(Vector2(0,12), top_line, 12, GOLD)
	caption_right(644.0, 12, meta, 12, MUTED)
	draw_line(Vector2(0,24), Vector2(644,24), RULE, 1.0)
	caption(Vector2(0,46), LocalizationManager.source("copy.5405c11ba0de"), 11, MUTED)
	caption(Vector2(430,46), LocalizationManager.source("copy.f925cafd86d7"), 11, MUTED)
	caption(Vector2(0,88), "$"+GameManager.format_num(display_worth), 38, INK)
	caption(Vector2(430,84), "$"+GameManager.format_num(display_cash), 26, GOLD)
	var meters:Array[int]= [GameManager.health,GameManager.energy,GameManager.happiness,100-GameManager.stress]
	var names:Array[String]= [LocalizationManager.source("copy.08930838ebae"),LocalizationManager.source("copy.f561c6b678d4"),LocalizationManager.source("copy.c642a5769b74"),LocalizationManager.source("copy.e197da26d73a")]
	for i:int in 4:
		var x:float= i*164.0
		caption(Vector2(x,132), names[i], 10, MUTED)
		caption_right(x+150.0, 132, str(meters[i]), 10, INK if meters[i]>=30 else ALERT)
		draw_style_box(bar(TRACK),Rect2(x,138,150,3))
		draw_style_box(bar(ALERT if meters[i]<30 else GOLD),Rect2(x,138,maxf(3,150*float(meters[i])/100.0),3))
	draw_line(Vector2(0,146), Vector2(644,146), RULE, 1.0)
	caption_right(644.0, 158, LocalizationManager.source("dashboard.pulse"), 10, MUTED)
	var pulse:PackedVector2Array= pulse_points(Vector2(480,161), Vector2(164,21))
	if pulse.size()>=2:
		draw_polyline(pulse, GOLD, 1.5, true)
		draw_circle(pulse[pulse.size()-1], 2.0, GOLD)
	caption(Vector2(0,190), LocalizationManager.source("dashboard.ambition") % LocalizationManager.source("ambition.short."+GameManager.ambition), 10, GOLD_DIM)
	var note:String= origin_note()
	if not note.is_empty():
		caption_right(460.0, 190, note, 10, GOLD_DIM)

func pulse_points(origin: Vector2, box: Vector2) -> PackedVector2Array:
	var history:Array= GameManager.market_history
	var points:PackedVector2Array= PackedVector2Array()
	if history.size()<2:
		return points
	var low:float= history[0]
	var high:float= low
	for value:Variant in history:
		var point:float= value
		low= minf(low, point)
		high= maxf(high, point)
	var span:float= maxf(high-low, 0.0001)
	var count:int= history.size()
	# Packed arrays report resize success through a return value the painter does not need.
	@warning_ignore("return_value_discarded")
	points.resize(count)
	for index:int in count:
		var sample:float= history[index]
		var t:float= float(index)/float(count-1)
		points[index]= origin+Vector2(box.x*t, box.y*(1.0-(sample-low)/span))
	return points

func bar(color: Color) -> StyleBoxFlat:
	var style:StyleBoxFlat= StyleBoxFlat.new()
	style.bg_color=color
	style.set_corner_radius_all(2)
	return style

func refresh_values(snap:bool=false) -> void:
	var cash_value:float=GameManager.cash
	var worth_value:float=GameManager.get_net_worth()
	queue_redraw()
	if values_ready and not snap and not GameManager.reduced_motion and cash_value==target_cash and worth_value==target_worth:return
	if is_instance_valid(balance_tween):balance_tween.kill()
	target_cash=cash_value
	target_worth=worth_value
	if not values_ready or snap or GameManager.reduced_motion:
		values_ready=true
		settle_values()
		return
	balance_tween=create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# Tween retains this property track until completion.
	@warning_ignore("return_value_discarded")
	balance_tween.tween_property(self,"display_cash",target_cash,0.18)
	# Tween retains this property track until completion.
	@warning_ignore("return_value_discarded")
	balance_tween.tween_property(self,"display_worth",target_worth,0.18)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	balance_tween.finished.connect(settle_values)
	set_process(true)

func settle_values() -> void:
	display_cash=target_cash
	display_worth=target_worth
	set_process(false)
	queue_redraw()

func _process(_delta:float) -> void:
	if GameManager.reduced_motion:refresh_values(true)
	else:queue_redraw()
