extends Control
## Compact actual balances, birthplace and decision-relevant condition meters.
## The portrait is gone on purpose: a random-country run has no single face.
## Colours resolve through Palette, so both skins share one drawing routine.
const BirthLottery=preload("res://scripts/BirthLottery.gd")
const Palette=preload("res://scripts/ui/Palette.gd")
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
	return BirthLottery.country_name(GameManager.birth_country_code)

func birthplace_region() -> String:
	if GameManager.birth_country_code.is_empty():
		return ""
	var row:Array= BirthLottery.by_code(GameManager.birth_country_code)
	if row.is_empty():
		return ""
	return BirthLottery.region_name(str(row[1]))

## Share of the country's influence that still applies to income and costs.
func origin_note() -> String:
	var influence:int= roundi(GameManager.origin_influence() * 100.0)
	return LocalizationManager.source("dashboard.grip") % influence

func _ready() -> void:
	custom_minimum_size.y = 178
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	resized.connect(queue_redraw)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	LocalizationManager.language_changed.connect(func(_language:Variant)->void:queue_redraw())
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	GameManager.theme_changed.connect(func(_mode:String)->void:queue_redraw())
	set_process(false)
	refresh_values(true)

func caption(at: Vector2, text: String, font_size: int, color: Color) -> void:
	draw_string(get_theme_default_font(), at, LocalizationManager.display(text), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func caption_right(right_edge: float, top: float, text: String, font_size: int, color: Color) -> void:
	draw_string(get_theme_default_font(), Vector2(0, top), LocalizationManager.display(text), HORIZONTAL_ALIGNMENT_RIGHT, right_edge, font_size, color)

func _draw() -> void:
	var s:float= size.x / 644.0
	draw_set_transform(Vector2.ZERO, 0, Vector2(s,s))
	var country:String= birthplace()
	var region:String= birthplace_region()
	var meta:String= LocalizationManager.source("copy.d0e02c3cc5dc") % [GameManager.age,GameManager.quarter,GameManager.generation]
	var top_line:String= country.to_upper() if region.is_empty() else "%s · %s" % [country.to_upper(), region.to_upper()]
	caption(Vector2(0,12), top_line, 12, Palette.accent())
	caption_right(644.0, 12, meta, 12, Palette.muted())
	draw_line(Vector2(0,24), Vector2(644,24), Palette.rule(), 1.0)
	caption(Vector2(0,46), LocalizationManager.source("copy.5405c11ba0de"), 11, Palette.muted())
	caption(Vector2(430,46), LocalizationManager.source("copy.f925cafd86d7"), 11, Palette.muted())
	caption(Vector2(0,88), "$"+GameManager.format_num(display_worth), 38, Palette.text())
	caption(Vector2(430,84), "$"+GameManager.format_num(display_cash), 26, Palette.accent())
	var meters:Array[int]= [GameManager.health,GameManager.energy,GameManager.happiness,100-GameManager.stress]
	var names:Array[String]= [LocalizationManager.source("copy.08930838ebae"),LocalizationManager.source("copy.f561c6b678d4"),LocalizationManager.source("copy.c642a5769b74"),LocalizationManager.source("copy.e197da26d73a")]
	for i:int in 4:
		var x:float= i*164.0
		caption(Vector2(x,132), names[i], 10, Palette.muted())
		caption_right(x+150.0, 132, str(meters[i]), 10, Palette.text() if meters[i]>=30 else Palette.alert())
		draw_style_box(bar(Palette.track()),Rect2(x,138,150,3))
		draw_style_box(bar(Palette.alert() if meters[i]<30 else Palette.accent()),Rect2(x,138,maxf(3,150*float(meters[i])/100.0),3))
	caption_right(644.0, 168, origin_note(), 10, Palette.accent_deep())

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
