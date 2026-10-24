extends Control
## Compact actual balances and decision-relevant condition meters.
const INK := Color("eeeadd")
const MUTED := Color("a7b7bb")
const GOLD := Color("c6ad7a")
func _ready() -> void:
    custom_minimum_size.y = 170
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    resized.connect(queue_redraw)
func caption(at: Vector2, text: String, font_size: int, color: Color = INK) -> void:
    draw_string(get_theme_default_font(), at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
func _draw() -> void:
    var s := size.x / 644.0
    draw_set_transform(Vector2.ZERO, 0, Vector2(s,s))
    caption(Vector2(0,20), "%d лет · квартал %d · поколение %d" % [GameManager.age,GameManager.quarter,GameManager.generation],15,MUTED)
    caption(Vector2(0,48), "Капитал",13,MUTED)
    caption(Vector2(420,48), "Доступно",13,MUTED)
    caption(Vector2(0,87), "$"+GameManager.format_num(GameManager.get_net_worth()),36)
    caption(Vector2(420,84), "$"+GameManager.format_num(GameManager.cash),26,GOLD)
    var meters := [GameManager.health,GameManager.energy,GameManager.happiness,100-GameManager.stress]
    var names := ["Здоровье","Энергия","Счастье","Спокойствие"]
    for i in 4:
        var x := i*165.0
        caption(Vector2(x,124),names[i]+" "+str(meters[i]),13,MUTED)
        draw_style_box(bar(Color("344c56")),Rect2(x,137,146,4))
        draw_style_box(bar(Color("bd8b72") if meters[i]<30 else GOLD),Rect2(x,137,maxf(2,146*meters[i]/100.0),4))
func bar(color: Color) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color=color
    style.set_corner_radius_all(2)
    return style
