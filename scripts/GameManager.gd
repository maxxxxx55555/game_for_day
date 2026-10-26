extends Node
signal persistence_changed(ok: bool)
var write_failures := {}

func report_write(path: String, ok: bool) -> void:
	if ok: write_failures.erase(path)
	else: write_failures[path] = true
	persistence_changed.emit(write_failures.is_empty())

const Guard = preload("res://scripts/security/SaveGuard.gd")
const Money=preload("res://scripts/security/Money.gd")
const SavePolicy = preload("res://scripts/security/FortuneSavePolicy.gd")
const SAVE_PATH := "user://dynasty_save.cfg"
const SESSION_PATH := "user://current_life.cfg"
const RUN_FIELDS := ["age", "quarter", "total_turns", "real_world_week", "time_speed", "quarter_progress_accum", "cash", "stock_units", "crypto_units", "stock_index", "crypto_rate", "inflation_multiplier", "difficulty_multiplier", "business_tier", "business_scale", "health", "intellect", "stress", "happiness", "energy", "birth_origin", "birth_cost_modifier", "player_perk", "has_rolled_birth", "ad_cooldown", "revive_used", "inherited_capital", "audio_enabled", "fx_state", "cash_cents", "stock_price_cents", "crypto_price_cents", "inherited_capital_cents", "simulation_ticks", "grant_ready_tick", "last_grant_tick"]
const QUARTERLY_INFLATION := 0.007
var fx := preload("res://scripts/ExchangeMarket.gd").new()
var fx_state: Dictionary:
	get: return fx.capture()
	set(value): fx.restore(value)

# Время и календарь
var age: int = 18
var quarter: int = 1 # 1..4
var total_turns: int = 0
var real_world_week: int = 1
var time_speed: float = 1.0 # 0.5x, 1.0x, 2.0x
var quarter_progress_accum: float = 0.0

# Финансы и активы
var cash_cents:int=20000:
	set(value):
		if Money.valid(value):cash_cents=value
var cash:float:
	get:return Money.dollars(cash_cents)
	set(value):
		var amount:int=Money.from_dollars(value)
		if amount!=Money.INVALID:cash_cents=amount
var stock_units:float=0.0:
	set(value):
		if is_finite(value) and value>=0 and value<=1.0e12:stock_units=value
var crypto_units:float=0.0:
	set(value):
		if is_finite(value) and value>=0 and value<=1.0e12:crypto_units=value
var stock_price_cents:int=100000:
	set(value):
		if value>0 and Money.valid(value):stock_price_cents=value
var stock_index:float:
	get:return Money.dollars(stock_price_cents)
	set(value):
		var amount:int=Money.from_dollars(value)
		if amount>0 and Money.valid(amount):stock_price_cents=amount
var crypto_price_cents:int=10000:
	set(value):
		if value>0 and Money.valid(value):crypto_price_cents=value
var crypto_rate:float:
	get:return Money.dollars(crypto_price_cents)
	set(value):
		var amount:int=Money.from_dollars(value)
		if amount>0 and Money.valid(amount):crypto_price_cents=amount
var inflation_multiplier: float = 1.0
var difficulty_multiplier: float = 1.0

# Бизнес-империя
var business_tier: int = 0
var business_scale: int = 1 # Масштабирование топового бизнеса (филиалы/поглощения)
const BUSINESS_DEFINITIONS := [
	{"name_key": "copy.415032073d05", "cost_cents": 0, "income_cents": 0, "valuation_cents": 0},
	{"name_key": "copy.4e18dfdd0b19", "cost_cents": 500000, "income_cents": 65000, "valuation_cents": 450000},
	{"name_key": "copy.9b2e303874c5", "cost_cents": 5000000, "income_cents": 680000, "valuation_cents": 4800000},
	{"name_key": "copy.0a3b9ad578c8", "cost_cents": 50000000, "income_cents": 7200000, "valuation_cents": 52000000},
	{"name_key": "copy.2b2ac29e543c", "cost_cents": 1000000000, "income_cents": 150000000, "valuation_cents": 1200000000},
	{"name_key": "copy.d1c68387ac6a", "cost_cents": 25000000000, "income_cents": 4500000000, "valuation_cents": 32000000000}
]

# Public read API retains canonical Russian names for old saved presentation copy.
var business_tier_cache:Array=[]
var BUSINESS_TIERS:Array:
	get:
		if business_tier_cache.is_empty():
			for definition in BUSINESS_DEFINITIONS:
				var entry:Dictionary=definition.duplicate()
				for field in ["cost","income","valuation"]:entry[field]=Money.dollars(definition[field+"_cents"])
				entry["name"]=LocalizationManager.source(entry.name_key)
				business_tier_cache.append(entry)
		return business_tier_cache

# Характеристики персонажа
var health: int = 100
var intellect: int = 15
var stress: int = 10
var happiness: int = 60
var energy: int = 100
var rank: int = 8000000000

# Мета-прогрессия (Династия) и состояние
var generation: int = 1
var legacy_points: int = 0
var inherited_capital_cents:int=0:
	set(value):
		if value>=0 and Money.valid(value):inherited_capital_cents=value
var inherited_capital:float:
	get:return Money.dollars(inherited_capital_cents)
	set(value):
		var amount:int=Money.from_dollars(value)
		if amount>=0 and Money.valid(amount):inherited_capital_cents=amount
var birth_origin: String = ""
var birth_cost_modifier: float = 1.0
var player_perk: String = "none"
var current_track: String = "Last Call at Three"
var audio_enabled: bool = true
var reduced_motion: bool = false
var master_volume: float = 1.0
var ui_volume: float = 0.8
var music_volume: float = 0.3
var sfx_volume: float = 0.8

var has_seen_intro: bool = false
var has_rolled_birth: bool = false
var simulation_ticks:int=0
var grant_ready_tick:int=0
var last_grant_tick:int=-1
var ad_cooldown:float:
	get:return float(maxi(0,grant_ready_tick-simulation_ticks))/2.0
	set(value):
		if is_finite(value) and value>=0 and value<=100:grant_ready_tick=simulation_ticks+ceili(value*2.0)
var revive_used: bool = false

func _ready() -> void:
	load_dynasty()

func save_dynasty() -> bool:
	var cfg := ConfigFile.new()
	cfg.set_value("dynasty", "generation", generation)
	cfg.set_value("dynasty", "legacy_points", legacy_points)
	cfg.set_value("dynasty", "inherited_capital", inherited_capital)
	cfg.set_value("dynasty","inherited_capital_cents",inherited_capital_cents)
	cfg.set_value("settings", "time_speed", time_speed)
	cfg.set_value("settings", "audio_enabled", audio_enabled)
	cfg.set_value("settings", "reduced_motion", reduced_motion)
	cfg.set_value("settings", "master_volume", master_volume)
	cfg.set_value("settings", "ui_volume", ui_volume)
	cfg.set_value("settings", "music_volume", music_volume)
	cfg.set_value("settings", "sfx_volume", sfx_volume)
	var ok := Guard.write_config(SAVE_PATH, cfg, "fortune/dynasty", SavePolicy.dynasty)
	report_write(SAVE_PATH,ok)
	return ok

func load_dynasty() -> void:
	var cfg := Guard.read_config(SAVE_PATH, "fortune/dynasty", SavePolicy.dynasty)
	if Guard.last_repair_failed: report_write(SAVE_PATH,false)
	if cfg != null:
		generation = cfg.get_value("dynasty", "generation", 1)
		legacy_points = cfg.get_value("dynasty", "legacy_points", 0)
		inherited_capital = cfg.get_value("dynasty", "inherited_capital", 0.0)
		inherited_capital_cents=cfg.get_value("dynasty","inherited_capital_cents",inherited_capital_cents)
		time_speed = cfg.get_value("settings", "time_speed", 1.0)
		audio_enabled = cfg.get_value("settings", "audio_enabled", true)
		reduced_motion = cfg.get_value("settings", "reduced_motion", false)
		master_volume = clampf(cfg.get_value("settings", "master_volume", 1.0), 0, 1)
		ui_volume = clampf(cfg.get_value("settings", "ui_volume", 0.8), 0, 1)
		music_volume = clampf(cfg.get_value("settings", "music_volume", 0.3), 0, 1)
		sfx_volume = clampf(cfg.get_value("settings", "sfx_volume", 0.8), 0, 1)

func reset_full_dynasty() -> void:
	clear_current_life()
	generation = 1
	legacy_points = 0
	inherited_capital = 0.0
	save_dynasty()
	reset_game()

func save_current_life(ui_state: Dictionary) -> bool:
	var cfg := ConfigFile.new()
	cfg.set_value("session", "generation", generation)
	cfg.set_value("session", "ui", ui_state)
	for field in RUN_FIELDS:
		cfg.set_value("run", field, get(field))
	var ok := Guard.write_config(SESSION_PATH, cfg, "fortune/session", SavePolicy.session)
	report_write(SESSION_PATH,ok)
	return ok

func load_current_life() -> Dictionary:
	var cfg := Guard.read_config(SESSION_PATH, "fortune/session", SavePolicy.session)
	if Guard.last_repair_failed: report_write(SESSION_PATH,false)
	if cfg == null or cfg.get_value("session", "generation", -1) != generation:
		return {}
	var ui_state: Dictionary = cfg.get_value("session", "ui", {})
	if ui_state.is_empty():
		return {}
	for field in RUN_FIELDS:
		set(field, cfg.get_value("run", field, {} if field == "fx_state" else get(field)))
	if not cfg.has_section_key("run","simulation_ticks"):
		var old_cooldown:float=cfg.get_value("run","ad_cooldown",0.0)
		simulation_ticks=maxi(0,((age-18)*4+quarter-1)*2+roundi(quarter_progress_accum*2.0))
		grant_ready_tick=simulation_ticks+ceili(old_cooldown*2.0)
		last_grant_tick=-1
	recalculate_forbes_rank()
	return ui_state

func clear_current_life() -> void:
	if not Guard.can_write(): return
	for path in [SESSION_PATH, SESSION_PATH + ".bak"]:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(path)

func reset_game() -> void:
	fx.reset()
	age = 18
	quarter = 1
	total_turns = 0
	real_world_week = 1
	quarter_progress_accum = 0.0
	simulation_ticks=0
	grant_ready_tick=0
	last_grant_tick=-1
	cash = 200.0 + inherited_capital
	stock_units = 0.0
	crypto_units = 0.0
	stock_index = 1000.0
	crypto_rate = 100.0
	inflation_multiplier = 1.0
	difficulty_multiplier = 1.0
	business_tier = 0
	business_scale = 1
	health = 100
	intellect = 15
	stress = 10
	happiness = 60
	energy = 100
	player_perk = "none"
	birth_origin = ""
	birth_cost_modifier = 1.0
	has_rolled_birth = false
	ad_cooldown = 0
	revive_used = false
	recalculate_forbes_rank()

# Лотерея рождения по реальной демографической статистике мира
func roll_birth_lottery() -> Dictionary:
	var roll := randf() * 100.0
	var result := {}
	if roll < 50.0:
		birth_origin = LocalizationManager.source("copy.b1a7a4e2a93b")
		cash = -1500.0 + inherited_capital
		health = 80
		intellect = 12
		stress = 15
		birth_cost_modifier = 0.6
		result = {
			"title": LocalizationManager.source("copy.63771b02969d"),
			"desc": LocalizationManager.source("copy.2330d70b76f0")
		}
	elif roll < 85.0:
		birth_origin = LocalizationManager.source("copy.0cf8277e4bff")
		cash = 250.0 + inherited_capital
		health = 90
		intellect = 18
		stress = 10
		birth_cost_modifier = 1.0
		result = {
			"title": LocalizationManager.source("copy.d4c7a635ca3f"),
			"desc": LocalizationManager.source("copy.c5181ac5cb63")
		}
	elif roll < 99.0:
		birth_origin = LocalizationManager.source("copy.495df6ec1ab0")
		cash = 5000.0 + inherited_capital
		health = 95
		intellect = 30
		stress = 10
		birth_cost_modifier = 1.6
		result = {
			"title": LocalizationManager.source("copy.f69c96f6c0cd"),
			"desc": LocalizationManager.source("copy.e7bee9cb90c8")
		}
	else:
		birth_origin = LocalizationManager.source("copy.319914340b65")
		cash = 100000.0 + inherited_capital
		health = 100
		intellect = 35
		stress = 5
		birth_cost_modifier = 3.0
		result = {
			"title": LocalizationManager.source("copy.acd73a580d1b"),
			"desc": LocalizationManager.source("copy.9860e896fe61")
		}
	has_rolled_birth = true
	inherited_capital = 0.0
	save_dynasty()
	recalculate_forbes_rank()
	return result

func get_portfolio_value_cents() -> int:
	var stock:int=Money.market(stock_units,stock_price_cents)
	var crypto:int=Money.market(crypto_units,crypto_price_cents)
	var total:int=Money.add(Money.add(stock,crypto),fx.value_cents())
	return Money.MAX_CENTS if total==Money.INVALID else total

func get_portfolio_value() -> float:
	return Money.dollars(get_portfolio_value_cents())

func get_annual_inflation() -> float:
	return pow(1.0 + QUARTERLY_INFLATION, 4) - 1.0

func get_real_cash() -> float:
	return cash / maxf(1.0, inflation_multiplier)

func buy_currency(code:String,dollars:float) -> bool:
	var amount:int=Money.from_dollars(dollars)
	if amount<=0 or not Money.valid(amount) or amount>cash_cents:return false
	if not fx.buy_cents(code,amount):return false
	cash_cents-=amount
	recalculate_forbes_rank()
	return true

func sell_currency(code:String,units:float) -> float:
	var received:int=fx.quote_sell_cents(code,units)
	var next:int=Money.add(cash_cents,received)
	if received<=0 or next==Money.INVALID:return 0
	if fx.sell_cents(code,units)!=received:return 0
	cash_cents=next
	recalculate_forbes_rank()
	return Money.dollars(received)

func get_business_valuation_cents() -> int:
	if business_tier<0 or business_tier>=BUSINESS_DEFINITIONS.size():return 0
	var result:int=Money.multiply(BUSINESS_DEFINITIONS[business_tier].valuation_cents,business_scale)
	return 0 if result==Money.INVALID else result

func get_business_valuation() -> float:return Money.dollars(get_business_valuation_cents())

func get_business_income_cents() -> int:
	if business_tier<0 or business_tier>=BUSINESS_DEFINITIONS.size():return 0
	var result:int=Money.multiply(BUSINESS_DEFINITIONS[business_tier].income_cents,business_scale)
	return 0 if result==Money.INVALID else result

func get_optimization_bonus() -> float:return Money.dollars(Money.ratio(get_business_income_cents(),15,100))

func get_passive_quarterly_income_cents() -> int:
	var stock:int=Money.market(stock_units,stock_price_cents)
	if stock==Money.INVALID:return 0
	var dividend:int=Money.ratio(stock,18 if player_perk=="wall_street" else 12,1000)
	var result:int=Money.add(get_business_income_cents(),dividend)
	return 0 if result==Money.INVALID else result

func get_passive_quarterly_income() -> float:return Money.dollars(get_passive_quarterly_income_cents())

func get_quarterly_living_cost_cents() -> int:
	var base:int=Money.scale((280+(age-18)*18)*100,birth_cost_modifier*inflation_multiplier)
	if business_tier>=3:base=Money.add(base,Money.ratio(get_business_income_cents(),15,100))
	if base==Money.INVALID:return Money.MAX_CENTS
	# Preserve the edition's nearest-whole-dollar cost policy, in the cent ledger.
	return roundi(float(base)/100.0)*100

func get_quarterly_living_cost() -> float:return Money.dollars(get_quarterly_living_cost_cents())

func get_net_worth_cents() -> int:
	var total:int=Money.add(Money.add(cash_cents,get_portfolio_value_cents()),get_business_valuation_cents())
	return Money.MAX_CENTS if total==Money.INVALID else total

func get_net_worth() -> float:return Money.dollars(get_net_worth_cents())

func recalculate_forbes_rank() -> void:
	var nw := get_net_worth()
	if nw <= -10000.0:
		rank = 8000000000
	elif nw < 0.0:
		rank = int(lerp(7000000000.0, 8000000000.0, clamp(-nw / 10000.0, 0.0, 1.0)))
	elif nw < 10000.0:
		rank = int(lerp(3500000000.0, 7000000000.0, 1.0 - (nw / 10000.0)))
	elif nw < 100000.0:
		rank = int(lerp(600000000.0, 3500000000.0, 1.0 - ((nw - 10000.0) / 90000.0)))
	elif nw < 1000000.0:
		rank = int(lerp(60000000.0, 600000000.0, 1.0 - ((nw - 100000.0) / 900000.0)))
	elif nw < 100000000.0:
		rank = int(lerp(30000.0, 60000000.0, 1.0 - ((nw - 1000000.0) / 99000000.0)))
	elif nw < 1000000000.0:
		rank = int(lerp(2800.0, 30000.0, 1.0 - ((nw - 100000000.0) / 900000000.0)))
	elif nw < 250000000000.0:
		var t: float = clampf((nw - 1000000000.0) / 249000000000.0, 0.0, 1.0)
		rank = max(1, int(lerp(2800.0, 1.0, pow(t, 0.35))))
	else:
		rank = 1

func advance_quarter_and_markets() -> Dictionary:
	var passive_cents:int=Money.scale(get_passive_quarterly_income_cents(),time_speed)
	var living_cents:int=Money.scale(get_quarterly_living_cost_cents(),time_speed)
	var next_cash:int=Money.add(cash_cents,Money.add(passive_cents,-living_cents))
	if next_cash==Money.INVALID:return {}
	var passive_inc:float=Money.dollars(passive_cents)
	var living_cost:float=Money.dollars(living_cents)
	total_turns += 1
	simulation_ticks+=roundi(time_speed*2.0)

	# Продвижение кварталов и возраста с учетом настройки скорости времени
	quarter_progress_accum += time_speed
	while quarter_progress_accum >= 1.0:
		quarter_progress_accum -= 1.0
		quarter += 1
		if quarter > 4:
			quarter = 1
			age += 1
	real_world_week = 1 + int((float((age - 18) * 4 + quarter - 1) + quarter_progress_accum) * 13.0)

	# Инфляция и мировая сложность
	inflation_multiplier *= (1.0 + QUARTERLY_INFLATION * time_speed)
	fx.advance(time_speed, QUARTERLY_INFLATION)
	difficulty_multiplier += 0.008 * time_speed

	# Колебания фондового индекса и криптовалюты
	var stock_delta := randf_range(-0.045, 0.065)
	if player_perk == "wall_street":
		stock_delta += 0.01
	stock_index = max(100.0, snappedf(stock_index * (1.0 + stock_delta), 0.01))

	var crypto_delta := randf_range(-0.22, 0.26)
	crypto_rate = max(5.0, snappedf(crypto_rate * (1.0 + crypto_delta), 0.01))

	# Начисление пассивного дохода и списание стоимости жизни
	var net_quarter_cash := passive_inc - living_cost
	cash_cents=next_cash

	recalculate_forbes_rank()
	return {
		"passive_inc": passive_inc,
		"living_cost": living_cost,
		"net_cash": net_quarter_cash
	}

func apply_delta(d_money: float, d_health: int, d_intellect: int, d_stress: int, d_happiness: int, d_energy: int) -> void:
	var delta_cents:int=Money.from_dollars(d_money)
	var next_cash:int=Money.add(cash_cents,delta_cents)
	var passive:int=Money.scale(get_passive_quarterly_income_cents(),time_speed)
	var living:int=Money.scale(get_quarterly_living_cost_cents(),time_speed)
	if next_cash==Money.INVALID or Money.add(next_cash,Money.add(passive,-living))==Money.INVALID:return
	var adj_health := d_health
	var adj_stress := int(float(d_stress) * difficulty_multiplier)
	var adj_energy := d_energy
	var adj_intellect := d_intellect

	if player_perk == "iron_health" and adj_health < 0:
		adj_health = int(float(adj_health) * 0.65)
	if player_perk == "biohacker" and adj_health < 0:
		adj_health = int(float(adj_health) * 0.5)
	if player_perk == "workaholic" and adj_energy < 0:
		adj_energy = int(float(adj_energy) * 0.7)
	if player_perk == "crisis_mgr" and adj_stress > 0:
		adj_stress = int(float(adj_stress) * 0.65)
	if player_perk == "tech_genius" and adj_intellect > 0:
		adj_intellect += 3

	cash_cents=next_cash
	health = clamp(health + adj_health, 0, 100)
	intellect = max(1, intellect + adj_intellect)
	stress = clamp(stress + adj_stress, 0, 100)
	happiness = clamp(happiness + d_happiness, 0, 100)
	energy = clamp(energy + adj_energy, 0, 100)

	advance_quarter_and_markets()
	recalculate_forbes_rank()

# Операции с инвестиционным портфелем
func buy_stocks(amount_usd:float) -> bool:
	var amount:int=Money.from_dollars(amount_usd)
	if amount<=0 or not Money.valid(amount) or cash_cents<amount:return false
	var acquired:float=float(amount)/float(stock_price_cents)
	if not is_finite(acquired) or acquired<=0 or stock_units+acquired>1.0e12:return false
	cash_cents-=amount
	stock_units+=acquired
	recalculate_forbes_rank()
	return true

func sell_all_stocks() -> float:
	var received:int=Money.market(stock_units,stock_price_cents)
	var next:int=Money.add(cash_cents,received)
	if received<=0 or next==Money.INVALID:return 0
	cash_cents=next
	stock_units=0
	recalculate_forbes_rank()
	return Money.dollars(received)

func buy_crypto(amount_usd:float) -> bool:
	var amount:int=Money.from_dollars(amount_usd)
	if amount<=0 or not Money.valid(amount) or cash_cents<amount:return false
	var acquired:float=float(amount)/float(crypto_price_cents)
	if not is_finite(acquired) or acquired<=0 or crypto_units+acquired>1.0e12:return false
	cash_cents-=amount
	crypto_units+=acquired
	recalculate_forbes_rank()
	return true

func sell_all_crypto() -> float:
	var received:int=Money.market(crypto_units,crypto_price_cents)
	var next:int=Money.add(cash_cents,received)
	if received<=0 or next==Money.INVALID:return 0
	cash_cents=next
	crypto_units=0
	recalculate_forbes_rank()
	return Money.dollars(received)

func upgrade_or_scale_business() -> Dictionary:
	if business_tier < BUSINESS_TIERS.size() - 1:
		var next_tier := business_tier + 1
		var cost_cents:int=BUSINESS_DEFINITIONS[next_tier].cost_cents
		var cost:float=Money.dollars(cost_cents)
		if cash_cents>=cost_cents:
			cash_cents-=cost_cents
			business_tier = next_tier
			business_scale = 1
			recalculate_forbes_rank()
			return {"ok": true, "msg": LocalizationManager.source("copy.a0d3e18684d0") + BUSINESS_TIERS[business_tier]["name"]}
		else:
			return {"ok": false, "msg": LocalizationManager.source("copy.18de786a617a") + format_num(cost)}
	else:
		# Масштабирование глобального техно-холдинга (поглощение корпораций на пути к $250 млрд)
		var scale_cents:int=Money.multiply(25000000000,business_scale)
		var scale_cost:float=Money.dollars(scale_cents)
		if business_scale>0 and business_scale<=8192 and scale_cents>0 and cash_cents>=scale_cents:
			cash_cents-=scale_cents
			business_scale *= 2
			recalculate_forbes_rank()
			return {"ok": true, "msg": LocalizationManager.source("copy.ef931bee4ea7") % business_scale}
		else:
			return {"ok": false, "msg": LocalizationManager.source("copy.980c1f440898") + format_num(scale_cost)}

func register_inheritance_on_end() -> String:
	var nw := get_net_worth()
	legacy_points += 1 + int(max(0, age - 30) / 15)
	var msg := ""
	if age >= 50 and nw > 1000.0:
		inherited_capital_cents=roundi(float(Money.ratio(get_net_worth_cents(),20,100))/100.0)*100
		generation += 1
		msg = LocalizationManager.source("copy.3a3f57875e5c") % [
			generation, format_num(inherited_capital), legacy_points
		]
	else:
		inherited_capital = 0.0
		generation += 1
		msg = LocalizationManager.source("copy.51f8bcaaf0c7") % legacy_points
	save_dynasty()
	return msg

func format_num(val: float) -> String:
	var abs_v := absf(val)
	var sign_s := "-" if val < 0.0 else ""
	if abs_v >= 1000000000.0:
		return "%s%.2fB" % [sign_s, abs_v / 1000000000.0]
	elif abs_v >= 1000000.0:
		return "%s%.2fM" % [sign_s, abs_v / 1000000.0]
	elif abs_v >= 1000.0:
		return "%s%.1fK" % [sign_s, abs_v / 1000.0]
	else:
		return "%s%d" % [sign_s, int(abs_v)]

func claim_grant() -> float:
	if simulation_ticks<grant_ready_tick or last_grant_tick==simulation_ticks:return 0
	var base:int=maxi(250000,absi(get_net_worth_cents()))
	var grant:int=maxi(150000,roundi(float(Money.ratio(base,8,100))/1000.0)*1000)
	var next:int=Money.add(cash_cents,grant)
	if next==Money.INVALID:return 0
	cash_cents=next
	last_grant_tick=simulation_ticks
	grant_ready_tick=simulation_ticks+8
	stress=maxi(0,stress-25)
	energy=mini(100,energy+35)
	recalculate_forbes_rank()
	return Money.dollars(grant)
