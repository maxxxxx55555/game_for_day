extends Control
## Compact actual balances and decision-relevant condition meters.
const INK := Color("eeeadd")
const MUTED := Color("a7b7bb")
const GOLD := Color("c6ad7a")
var portraits: Texture2D = preload("res://assets/art/life-portraits.png")
func portrait_stage(age: int) -> int:
    return 0 if age < 30 else 1 if age < 48 else 2 if age < 68 else 3
func _ready() -> void:
    custom_minimum_size.y = 170
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    resized.connect(queue_redraw)
    LocalizationManager.language_changed.connect(func(_language):queue_redraw())
func caption(at: Vector2, text: String, font_size: int, color: Color = INK) -> void:
    draw_string(get_theme_default_font(), at, LocalizationManager.display(text), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
func _draw() -> void:
    var s := size.x / 644.0
    draw_set_transform(Vector2.ZERO, 0, Vector2(s,s))
    caption(Vector2(0,20), LocalizationManager.source("copy.d0e02c3cc5dc") % [GameManager.age,GameManager.quarter,GameManager.generation],15,MUTED)
    var tile := Vector2(portraits.get_width()/2.0,portraits.get_height()/2.0)
    var stage := portrait_stage(GameManager.age)
    draw_texture_rect_region(portraits,Rect2(0,34,70,84),Rect2(Vector2(stage%2,int(stage/2))*tile,tile))
    draw_rect(Rect2(0,34,70,84),Color("a5b4bf"),false,1.0)
    caption(Vector2(90,48), LocalizationManager.source("copy.5405c11ba0de"),13,MUTED)
    caption(Vector2(420,48), LocalizationManager.source("copy.f925cafd86d7"),13,MUTED)
    caption(Vector2(90,87), "$"+GameManager.format_num(GameManager.get_net_worth()),34)
    caption(Vector2(420,84), "$"+GameManager.format_num(GameManager.cash),26,GOLD)
    var meters := [GameManager.health,GameManager.energy,GameManager.happiness,100-GameManager.stress]
    var names := [LocalizationManager.source("copy.08930838ebae"),LocalizationManager.source("copy.f561c6b678d4"),LocalizationManager.source("copy.c642a5769b74"),LocalizationManager.source("copy.e197da26d73a")]
    for i in 4:
        var x := i*165.0
        caption(Vector2(x,142),names[i]+" "+str(meters[i]),13,MUTED)
        draw_style_box(bar(Color("344c56")),Rect2(x,153,146,4))
        draw_style_box(bar(Color("bd8b72") if meters[i]<30 else GOLD),Rect2(x,153,maxf(2,146*meters[i]/100.0),4))
func bar(color: Color) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color=color
    style.set_corner_radius_all(2)
    return style
