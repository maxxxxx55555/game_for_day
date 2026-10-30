extends PanelContainer
const QuoteChart=preload("res://scripts/ui/CurrencySparkline.gd")
const TypeRefCurrencySparkline=preload("res://scripts/ui/CurrencySparkline.gd")
const Palette=preload("res://scripts/ui/Palette.gd")
const SkinTheme=preload("res://scripts/ui/FortuneTheme.gd")

signal closed
signal traded
var rows: Dictionary = {}
var cash_label: Label
var notice: Label
var detail_label: Label
var card_panels: Array[PanelContainer] = []
var card_wallets: Array[Label] = []

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_theme_stylebox_override("panel", SkinTheme.style(Palette.surface(),Palette.rule()))
	var margin:MarginContainer= MarginContainer.new()
	for edge:String in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + edge, 24)
	add_child(margin)
	var column:VBoxContainer= VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	margin.add_child(column)
	var header:HBoxContainer= HBoxContainer.new()
	column.add_child(header)
	var back:Button= Button.new()
	back.text = LocalizationManager.source("copy.b80940a8a747")
	back.custom_minimum_size = Vector2(110, 54)
	header.add_child(back)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	back.pressed.connect(func()->void: closed.emit())
	var title:Label= Label.new()
	title.text = LocalizationManager.source("copy.66f4033be75d")
	title.add_theme_font_size_override("font_size", 30)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	cash_label = Label.new()
	cash_label.add_theme_font_size_override("font_size", 22)
	cash_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(cash_label)
	var scrolling:ScrollContainer= ScrollContainer.new()
	scrolling.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scrolling.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scrolling)
	var cards:VBoxContainer= VBoxContainer.new()
	cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards.add_theme_constant_override("separation", 16)
	scrolling.add_child(cards)
	for code:String in ["EUR", "GBP", "JPY"]:
		var panel:PanelContainer= PanelContainer.new()
		panel.add_theme_stylebox_override("panel", SkinTheme.style(Palette.raised(),Palette.rule_soft()))
		card_panels.append(panel)
		cards.add_child(panel)
		var card:VBoxContainer= VBoxContainer.new()
		card.add_theme_constant_override("separation", 8)
		panel.add_child(card)
		var quote:Label= Label.new()
		quote.add_theme_font_size_override("font_size", 24)
		card.add_child(quote)
		var wallet:Label= Label.new()
		wallet.add_theme_color_override("font_color", Palette.muted())
		card_wallets.append(wallet)
		card.add_child(wallet)
		var chart:TypeRefCurrencySparkline= preload("res://scripts/ui/CurrencySparkline.gd").new()
		chart.code = code
		card.add_child(chart)
		var actions:HBoxContainer= HBoxContainer.new()
		actions.add_theme_constant_override("separation", 12)
		card.add_child(actions)
		var buy:Button= action(actions, LocalizationManager.source("copy.4b9f68c9ecf8"), func()->void:
			var amount: float = maxf(0, GameManager.cash * 0.25)
			if GameManager.buy_currency(code, amount):
				notice.text = LocalizationManager.source("copy.66b4772fc5e4") + code + LocalizationManager.source("copy.f6e8b6c3c34f") + GameManager.format_num(amount)
				# The director owns the voice; action feedback serial records the acknowledgment.
				@warning_ignore("return_value_discarded")
				SoundManager.play_sfx("purchase")
				traded.emit()
			refresh()
		)
		var sell:Button= action(actions, LocalizationManager.source("copy.4145482dc87c"), func()->void:
			var received:float= GameManager.sell_currency(code, GameManager.fx.holdings[code])
			if received > 0:
				notice.text = LocalizationManager.source("copy.3ab9100bd052") + code + " · +$" + GameManager.format_num(received)
				# The director owns the voice; action feedback serial records the acknowledgment.
				@warning_ignore("return_value_discarded")
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
	notice.add_theme_color_override("font_color", Palette.accent_deep())
	column.add_child(notice)
	var detail:Label= Label.new()
	detail.text = LocalizationManager.source("copy.a5f2a71c789f")
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_theme_font_size_override("font_size", 15)
	detail.add_theme_color_override("font_color", Palette.muted())
	detail_label = detail
	column.add_child(detail)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	GameManager.theme_changed.connect(func(_mode:String)->void:apply_skin())
	refresh()

## Re-skins the surfaces this panel overrides outside the global Theme.
func apply_skin() -> void:
	add_theme_stylebox_override("panel", SkinTheme.style(Palette.surface(),Palette.rule()))
	for panel:PanelContainer in card_panels:
		panel.add_theme_stylebox_override("panel", SkinTheme.style(Palette.raised(),Palette.rule_soft()))
	for wallet:Label in card_wallets:
		wallet.add_theme_color_override("font_color", Palette.muted())
	if notice: notice.add_theme_color_override("font_color", Palette.accent_deep())
	if detail_label: detail_label.add_theme_color_override("font_color", Palette.muted())

func action(parent: Node, text: String, callback: Callable) -> Button:
	var button:Button= Button.new()
	button.text = text
	button.custom_minimum_size.y = 58
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(button)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	button.pressed.connect(callback)
	return button

func refresh() -> void:
	if not is_node_ready(): return
	cash_label.text = LocalizationManager.source("copy.d32075b866b9") % [GameManager.format_num(GameManager.cash), GameManager.get_annual_inflation() * 100]
	for code:Variant in rows:
		var row: Dictionary = rows[code]
		var rate: float = GameManager.fx.rates[code]
		var history: Array = GameManager.fx.history[code]
		var change: float = (rate / history[-2] - 1) * 100 if history.size() > 1 else 0
		row.quote.text = "%s   $%.4f   %+.1f%%" % [code, rate, change]
		row.wallet.text = LocalizationManager.source("copy.6b6d01a65284") % [GameManager.fx.holdings[code], code, GameManager.format_num(GameManager.fx.holdings[code] * rate)]
		row.buy.disabled = GameManager.cash <= 0
		row.sell.disabled = GameManager.fx.holdings[code] <= 0
		row.sell.tooltip_text=(LocalizationManager.source("ui.no_currency") % code) if row.sell.disabled else ""
		row.buy.tooltip_text = LocalizationManager.source("copy.778a48fdd09e") + GameManager.format_num(maxf(0, GameManager.cash * 0.25))
		var chart:QuoteChart=row.chart
		chart.refresh_labels()

func _process(_delta:float) -> void:
	if not visible:return
	for code:Variant in rows:
		var row:Dictionary=rows[code]
		row.sell.tooltip_text=(LocalizationManager.source("ui.no_currency") % code) if row.sell.disabled else ""
		row.buy.tooltip_text=LocalizationManager.source("ui.no_cash") if row.buy.disabled else LocalizationManager.source("copy.778a48fdd09e")+GameManager.format_num(maxf(0,GameManager.cash*0.25))
