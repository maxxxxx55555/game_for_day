extends Control
## Compact actual balances and decision-relevant condition meters.
const INK:Color= Color("eeeadd")
const MUTED:Color= Color("a7b7bb")
const GOLD:Color= Color("c6ad7a")
var display_cash:float=0.0
var display_worth:float=0.0
var target_cash:float=0.0
var target_worth:float=0.0
var values_ready:bool=false
var balance_tween:Tween
var portraits: Texture2D = preload("res://assets/art/life-portraits.png")
func portrait_stage(age: int) -> int:
    return 0 if age < 30 else 1 if age < 48 else 2 if age < 68 else 3
func _ready() -> void:
    custom_minimum_size.y = 170
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
func _draw() -> void:
    var s:float= size.x / 644.0
    draw_set_transform(Vector2.ZERO, 0, Vector2(s,s))
    caption(Vector2(0,20), LocalizationManager.source("copy.d0e02c3cc5dc") % [GameManager.age,GameManager.quarter,GameManager.generation],15,MUTED)
    var tile:Vector2= Vector2(portraits.get_width()/2.0,portraits.get_height()/2.0)
    var stage:int= portrait_stage(GameManager.age)
    draw_texture_rect_region(portraits,Rect2(0,34,70,84),Rect2(Vector2(stage%2,floori(float(stage)/2.0))*tile,tile))
    draw_rect(Rect2(0,34,70,84),Color("a5b4bf"),false,1.0)
    caption(Vector2(90,48), LocalizationManager.source("copy.5405c11ba0de"),13,MUTED)
    caption(Vector2(420,48), LocalizationManager.source("copy.f925cafd86d7"),13,MUTED)
    caption(Vector2(90,87), "$"+GameManager.format_num(display_worth),34)
    caption(Vector2(420,84), "$"+GameManager.format_num(display_cash),26,GOLD)
    var meters:Array[int]= [GameManager.health,GameManager.energy,GameManager.happiness,100-GameManager.stress]
    var names:Array[String]= [LocalizationManager.source("copy.08930838ebae"),LocalizationManager.source("copy.f561c6b678d4"),LocalizationManager.source("copy.c642a5769b74"),LocalizationManager.source("copy.e197da26d73a")]
    for i:int in 4:
        var x:float= i*165.0
        caption(Vector2(x,142),names[i]+" "+str(meters[i]),13,MUTED)
        draw_style_box(bar(Color("344c56")),Rect2(x,153,146,4))
        draw_style_box(bar(Color("bd8b72") if meters[i]<30 else GOLD),Rect2(x,153,maxf(2,146*meters[i]/100.0),4))
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
