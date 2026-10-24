extends Control
## A vector dashboard driven entirely by the current simulation state.

const INK := Color("e8eddb")
const MUTED := Color("8fa99e")
const GOLD := Color("dec58d")

func _ready() -> void:
	custom_minimum_size.y = 294
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func caption(at: Vector2, text: String, font_size: int, color: Color = INK) -> void:
	draw_string(ThemeDB.fallback_font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _draw() -> void:
	var s := size.x / 644.0
	draw_set_transform(Vector2.ZERO, 0, Vector2(s, s))
	caption(Vector2(0, 22), "HEIRS OF FORTUNE", 20, GOLD)
	caption(Vector2(0, 48), "Поколение %d   /   %d лет   /   Квартал %d" % [GameManager.generation, GameManager.age, GameManager.quarter], 16, MUTED)
	# The skyline is original vector art, with a clear contour at every size.
	for i in 11:
		var h := float([24, 46, 35, 64, 85, 53, 96, 70, 43, 58, 28][i])
		var x := 439.0 + i * 18
		draw_rect(Rect2(x, 116 - h, 14, h), Color("284b42"))
		for floor_index in int(h / 10) - 1:
			if (i + floor_index) % 3 == 0: draw_rect(Rect2(x + 4, 108 - floor_index * 10, 3, 3), GOLD.darkened(0.35))
	caption(Vector2(0, 82), "СОСТОЯНИЕ", 14, MUTED)
	var wealth := "$" + GameManager.format_num(GameManager.get_net_worth())
	caption(Vector2(0, 131), wealth, 43 if wealth.length() < 16 else 34)
	var rank_text := str(GameManager.rank)
	if GameManager.rank >= 1000000: rank_text = "%.1f млн" % (GameManager.rank / 1000000.0)
	if GameManager.rank >= 1000000000: rank_text = "%.2f млрд" % (GameManager.rank / 1000000000.0)
	caption(Vector2(0, 158), "Мировой рейтинг  #" + rank_text, 16, GOLD)
	draw_line(Vector2(0, 177), Vector2(644, 177), Color("35564a"), 1)
	var values := ["$" + GameManager.format_num(GameManager.cash), "+$" + GameManager.format_num(GameManager.get_passive_quarterly_income()), "−$" + GameManager.format_num(GameManager.get_quarterly_living_cost())]
	var titles := ["ДОСТУПНО", "ДОХОД / КВ", "РАСХОДЫ / КВ"]
	for i in 3:
		caption(Vector2(i * 219, 203), titles[i], 12, MUTED)
		caption(Vector2(i * 219, 229), values[i], 20, INK if i == 0 else GOLD)
	var meters := [GameManager.health, GameManager.energy, GameManager.happiness, 100 - GameManager.stress]
	var names := ["Здоровье", "Энергия", "Счастье", "Спокойствие"]
	for i in 4:
		var x := i * 165.0
		caption(Vector2(x, 258), names[i] + " " + str(meters[i]), 13, MUTED)
		draw_style_box(bar(Color("25483d")), Rect2(x, 269, 146, 5))
		draw_style_box(bar(Color("d58d72") if meters[i] < 30 else Color("9cbb8b")), Rect2(x, 269, maxf(2, 146 * meters[i] / 100.0), 5))

func bar(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(3)
	return style
