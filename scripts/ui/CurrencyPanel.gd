extends PanelContainer

signal closed
signal traded
var rows: Dictionary = {}
var cash_label: Label
var notice: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_theme_stylebox_override("panel", preload("res://scripts/ui/FortuneTheme.gd").style(Color("142735")))
	var margin := MarginContainer.new()
	for edge in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + edge, 24)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	margin.add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	var back := Button.new()
	back.text = "‹ Назад"
	back.custom_minimum_size = Vector2(110, 54)
	header.add_child(back)
	back.pressed.connect(func(): closed.emit())
	var title := Label.new()
	title.text = "Валюты"
	title.add_theme_font_size_override("font_size", 30)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	cash_label = Label.new()
	cash_label.add_theme_font_size_override("font_size", 22)
	cash_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(cash_label)
	var scrolling := ScrollContainer.new()
	scrolling.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scrolling.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scrolling)
	var cards := VBoxContainer.new()
	cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards.add_theme_constant_override("separation", 16)
	scrolling.add_child(cards)
	for code in ["EUR", "GBP", "JPY"]:
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", preload("res://scripts/ui/FortuneTheme.gd").style(Color("203c47"), Color("47616a")))
		cards.add_child(panel)
		var card := VBoxContainer.new()
		card.add_theme_constant_override("separation", 10)
		panel.add_child(card)
		var quote := Label.new()
		quote.add_theme_font_size_override("font_size", 24)
		card.add_child(quote)
		var wallet := Label.new()
		wallet.add_theme_color_override("font_color", Color("a8bcbf"))
		card.add_child(wallet)
		var chart := preload("res://scripts/ui/CurrencySparkline.gd").new()
		chart.code = code
		card.add_child(chart)
		var actions := HBoxContainer.new()
		actions.add_theme_constant_override("separation", 12)
		card.add_child(actions)
		var buy := action(actions, "Купить на 25%", func():
			var amount: float = maxf(0, GameManager.cash * 0.25)
			if GameManager.buy_currency(code, amount):
				notice.text = "Куплено " + code + " на $" + GameManager.format_num(amount)
				SoundManager.play_sfx("purchase")
				traded.emit()
			refresh()
		)
		var sell := action(actions, "Продать всё", func():
			var received := GameManager.sell_currency(code, GameManager.fx.holdings[code])
			if received > 0:
				notice.text = "Продано " + code + " · +$" + GameManager.format_num(received)
				SoundManager.play_sfx("sale")
				traded.emit()
			refresh()
		)
		buy.set_meta("currency", code)
		buy.set_meta("action", "buy")
		sell.set_meta("currency", code)
		sell.set_meta("action", "sell")
		rows[code] = {"quote": quote, "wallet": wallet, "chart": chart, "buy": buy, "sell": sell}
	notice = Label.new()
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notice.add_theme_color_override("font_color", Color("c4d3ba"))
	column.add_child(notice)
	var detail := Label.new()
	detail.text = "Игровые курсы · спред 0,35% с каждой стороны\nОбмен не тратит ход. Новый курс — после хода."
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_theme_font_size_override("font_size", 15)
	detail.add_theme_color_override("font_color", Color("a0b4b9"))
	column.add_child(detail)
	refresh()

func action(parent: Node, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 58
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(button)
	button.pressed.connect(callback)
	return button

func refresh() -> void:
	if not is_node_ready(): return
	cash_label.text = "$%s доступно  ·  Инфляция %.1f%%/год" % [GameManager.format_num(GameManager.cash), GameManager.get_annual_inflation() * 100]
	for code in rows:
		var row: Dictionary = rows[code]
		var rate: float = GameManager.fx.rates[code]
		var history: Array = GameManager.fx.history[code]
		var change: float = (rate / history[-2] - 1) * 100 if history.size() > 1 else 0
		row.quote.text = "%s   $%.4f   %+.1f%%" % [code, rate, change]
		row.wallet.text = "На счёте: %.2f %s  ·  $%s" % [GameManager.fx.holdings[code], code, GameManager.format_num(GameManager.fx.holdings[code] * rate)]
		row.buy.disabled = GameManager.cash <= 0
		row.sell.disabled = GameManager.fx.holdings[code] <= 0
		row.buy.tooltip_text = "Потратить $" + GameManager.format_num(maxf(0, GameManager.cash * 0.25))
		row.chart.queue_redraw()
