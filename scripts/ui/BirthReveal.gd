extends Control
## Hero card for the birth lottery: the country, how rare that draw was, and what
## it means for the first years. Deliberately plain - one accent, thin rules.
const INK:Color= Color("ede7da")
const MUTED:Color= Color("8a97a6")
const GOLD:Color= Color("c8a96a")
const GOLD_DIM:Color= Color("8c7442")
const RULE:Color= Color("2a3646")
const display_font:Font= preload("res://assets/fonts/Prata-Regular.ttf")
const BirthLottery=preload("res://scripts/BirthLottery.gd")
var country:String=""
var region:String=""
var share_text:String=""
var life_text:String=""
var cash_text:String=""
var has_result:bool=false

func _ready() -> void:
	custom_minimum_size.y = 236
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	resized.connect(queue_redraw)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	LocalizationManager.language_changed.connect(func(_language:Variant)->void:queue_redraw())

func present(info:Dictionary) -> void:
	country=str(info.get("title",""))
	region=str(info.get("region",GameManager.birth_origin))
	var percent:float=BirthLottery.value_number(info,"share")*100.0
	share_text=GameManager.origin_percent_text(percent)+"%"
	life_text=LocalizationManager.source("birth.life_years") % BirthLottery.value_int(info,"life")
	cash_text="$"+GameManager.format_num(GameManager.cash)
	has_result=true
	queue_redraw()

func clear() -> void:
	has_result=false
	queue_redraw()

## Rebuilds the card from saved run state after a session restore.
func present_from_state() -> void:
	var row:Array= BirthLottery.by_code(GameManager.birth_country_code)
	if row.is_empty():
		clear()
		return
	var code:String=GameManager.birth_country_code
	present({
		"title": BirthLottery.country_name(code),
		"region": BirthLottery.region_name(str(row[1])),
		"share": BirthLottery.share(row),
		"life": BirthLottery.row_int(row,3)
	})

func tracked(text:String) -> String:
	var letters:String=""
	for i:int in text.length():
		if i > 0:
			letters += " "
		letters += text.substr(i,1)
	return letters

func caption(at: Vector2, text: String, font_size: int, color: Color = INK) -> void:
	draw_string(get_theme_default_font(), at, LocalizationManager.display(text), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func stat(x: float, value: String, label: String) -> void:
	draw_string(get_theme_default_font(), Vector2(x,132), LocalizationManager.display(value), HORIZONTAL_ALIGNMENT_LEFT, 190, 30, INK)
	draw_string(get_theme_default_font(), Vector2(x,156), LocalizationManager.display(label), HORIZONTAL_ALIGNMENT_LEFT, 190, 11, MUTED)

func _draw() -> void:
	if not has_result: return
	var s:float= size.x / 620.0
	# Sit the card in the optical middle of whatever height the panel grants.
	var spare:float= maxf(0.0, size.y - 236.0 * s)
	draw_set_transform(Vector2(0, spare * 0.42), 0, Vector2(s,s))
	draw_string(get_theme_default_font(), Vector2(0,12), tracked(LocalizationManager.source("birth.overline")), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, GOLD)
	draw_line(Vector2(0,24), Vector2(620,24), RULE, 1.0)
	draw_string(display_font, Vector2(0,74), country, HORIZONTAL_ALIGNMENT_LEFT, 620, 42, INK)
	draw_string(get_theme_default_font(), Vector2(0,100), LocalizationManager.display(region.to_upper()), HORIZONTAL_ALIGNMENT_LEFT, 620, 12, MUTED)
	draw_line(Vector2(0,116), Vector2(620,116), RULE, 1.0)
	stat(0.0,share_text,LocalizationManager.source("birth.share"))
	stat(215.0,life_text,LocalizationManager.source("birth.life"))
	stat(430.0,cash_text,LocalizationManager.source("birth.capital"))
	draw_line(Vector2(0,176), Vector2(620,176), RULE, 1.0)
	caption(Vector2(0,200), LocalizationManager.source("birth.note.one"), 13, INK)
	caption(Vector2(0,220), LocalizationManager.source("birth.note.two"), 13, GOLD_DIM)
