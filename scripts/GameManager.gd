extends Node

const SAVE_PATH := "user://dynasty_save.cfg"
const SESSION_PATH := "user://current_life.cfg"
const RUN_FIELDS := ["age", "quarter", "total_turns", "real_world_week", "time_speed", "quarter_progress_accum", "cash", "stock_units", "crypto_units", "stock_index", "crypto_rate", "inflation_multiplier", "difficulty_multiplier", "business_tier", "business_scale", "health", "intellect", "stress", "happiness", "energy", "birth_origin", "birth_cost_modifier", "player_perk", "has_rolled_birth", "ad_cooldown", "revive_used", "inherited_capital", "audio_enabled", "fx_state"]
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
var cash: float = 200.0
var stock_units: float = 0.0
var crypto_units: float = 0.0
var stock_index: float = 1000.0
var crypto_rate: float = 100.0
var inflation_multiplier: float = 1.0
var difficulty_multiplier: float = 1.0

# Бизнес-империя
var business_tier: int = 0
var business_scale: int = 1 # Масштабирование топового бизнеса (филиалы/поглощения)
const BUSINESS_TIERS := [
	{"name": "Нет бизнеса", "cost": 0.0, "income": 0.0, "valuation": 0.0},
	{"name": "Кофейня / Фриланс-студия", "cost": 5000.0, "income": 650.0, "valuation": 4500.0},
	{"name": "Сеть точек / Веб-агентство", "cost": 50000.0, "income": 6800.0, "valuation": 48000.0},
	{"name": "IT-Продукт / Производство", "cost": 500000.0, "income": 72000.0, "valuation": 520000.0},
	{"name": "Национальная Корпорация", "cost": 10000000.0, "income": 1500000.0, "valuation": 12000000.0},
	{"name": "Глобальный Техно-Холдинг (IPO)", "cost": 250000000.0, "income": 45000000.0, "valuation": 320000000.0}
]

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
var inherited_capital: float = 0.0
var birth_origin: String = ""
var birth_cost_modifier: float = 1.0
var player_perk: String = "none"
var current_track: String = "Last Call at Three"
var audio_enabled: bool = true
var music_volume: float = 0.3
var sfx_volume: float = 0.8

var has_seen_intro: bool = false
var has_rolled_birth: bool = false
var ad_cooldown: float = 0.0
var revive_used: bool = false

func _ready() -> void:
	load_dynasty()

func save_dynasty() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("dynasty", "generation", generation)
	cfg.set_value("dynasty", "legacy_points", legacy_points)
	cfg.set_value("dynasty", "inherited_capital", inherited_capital)
	cfg.set_value("settings", "time_speed", time_speed)
	cfg.set_value("settings", "audio_enabled", audio_enabled)
	cfg.set_value("settings", "music_volume", music_volume)
	cfg.set_value("settings", "sfx_volume", sfx_volume)
	cfg.save(SAVE_PATH)

func load_dynasty() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		generation = cfg.get_value("dynasty", "generation", 1)
		legacy_points = cfg.get_value("dynasty", "legacy_points", 0)
		inherited_capital = cfg.get_value("dynasty", "inherited_capital", 0.0)
		time_speed = cfg.get_value("settings", "time_speed", 1.0)
		audio_enabled = cfg.get_value("settings", "audio_enabled", true)
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
	return cfg.save(SESSION_PATH) == OK

func load_current_life() -> Dictionary:
	var cfg := ConfigFile.new()
	if cfg.load(SESSION_PATH) != OK or cfg.get_value("session", "generation", -1) != generation:
		return {}
	var ui_state: Dictionary = cfg.get_value("session", "ui", {})
	if ui_state.is_empty():
		return {}
	for field in RUN_FIELDS:
		set(field, cfg.get_value("run", field, {} if field == "fx_state" else get(field)))
	recalculate_forbes_rank()
	return ui_state

func clear_current_life() -> void:
	if FileAccess.file_exists(SESSION_PATH):
		DirAccess.remove_absolute(SESSION_PATH)

func reset_game() -> void:
	fx.reset()
	age = 18
	quarter = 1
	total_turns = 0
	real_world_week = 1
	quarter_progress_accum = 0.0
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
		birth_origin = "Развивающийся бедный регион (Шанс 50%)"
		cash = -1500.0 + inherited_capital
		health = 80
		intellect = 12
		stress = 15
		birth_cost_modifier = 0.6
		result = {
			"title": "Лотерея рождения: Бедный регион (50% населения Земли)",
			"desc": "Вы родились в семье с долгами (-$1,500) и слабой медициной, но низкими расходами на жизнь и высокой закалкой."
		}
	elif roll < 85.0:
		birth_origin = "Индустриальная страна (Шанс 35%)"
		cash = 250.0 + inherited_capital
		health = 90
		intellect = 18
		stress = 10
		birth_cost_modifier = 1.0
		result = {
			"title": "Лотерея рождения: Рабочий класс (35% населения Земли)",
			"desc": "Обычная семья, базовая школа и $250 в кармане на совершеннолетие. Все зависит от ваших решений."
		}
	elif roll < 99.0:
		birth_origin = "Средний класс развитой страны (Шанс 14%)"
		cash = 5000.0 + inherited_capital
		health = 95
		intellect = 30
		stress = 10
		birth_cost_modifier = 1.6
		result = {
			"title": "Лотерея рождения: Развитая экономика (14% населения Земли)",
			"desc": "Отличное базовое образование (Интеллект 30) и $5,000 на старте, но высокая стоимость жизни и налогов."
		}
	else:
		birth_origin = "Мировая финансовая элита (Шанс 1%)"
		cash = 100000.0 + inherited_capital
		health = 100
		intellect = 35
		stress = 5
		birth_cost_modifier = 3.0
		result = {
			"title": "Лотерея рождения: Золотой 1% планеты!",
			"desc": "Вы родились в богатой династии! Стартовый трастовый фонд $100,000 и лучшие репетиторы, но огромные расходы на статус."
		}
	has_rolled_birth = true
	inherited_capital = 0.0
	save_dynasty()
	recalculate_forbes_rank()
	return result

func get_portfolio_value() -> float:
	return (stock_units * stock_index) + (crypto_units * crypto_rate) + fx.value()

func get_annual_inflation() -> float:
	return pow(1.0 + QUARTERLY_INFLATION, 4) - 1.0

func get_real_cash() -> float:
	return cash / maxf(1.0, inflation_multiplier)

func buy_currency(code: String, dollars: float) -> bool:
	if not is_finite(dollars) or dollars <= 0 or dollars > cash: return false
	if not fx.buy(code, dollars): return false
	cash -= dollars
	recalculate_forbes_rank()
	return true

func sell_currency(code: String, units: float) -> float:
	var received: float = fx.sell(code, units)
	cash += received
	recalculate_forbes_rank()
	return received

func get_business_valuation() -> float:
	if business_tier == 0:
		return 0.0
	var base_val: float = BUSINESS_TIERS[business_tier]["valuation"]
	return base_val * float(business_scale)

func get_passive_quarterly_income() -> float:
	var biz_inc: float = 0.0
	if business_tier > 0:
		biz_inc = BUSINESS_TIERS[business_tier]["income"] * float(business_scale)
	var div_inc: float = (stock_units * stock_index) * 0.012 # 1.2% дивидендов в квартал
	if player_perk == "wall_street":
		div_inc *= 1.5
	return biz_inc + div_inc

func get_quarterly_living_cost() -> float:
	var base_cost := (280.0 + float(age - 18) * 18.0) * birth_cost_modifier * inflation_multiplier
	# Обслуживание высокого уровня жизни и бизнеса
	if business_tier >= 3:
		base_cost += BUSINESS_TIERS[business_tier]["income"] * 0.15 * float(business_scale)
	return snappedf(base_cost, 1.0)

func get_net_worth() -> float:
	return cash + get_portfolio_value() + get_business_valuation()

# Честная формула позиции в Forbes строго от Net Worth
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
	var passive_inc := get_passive_quarterly_income() * time_speed
	var living_cost := get_quarterly_living_cost() * time_speed
	total_turns += 1
	if ad_cooldown > 0:
		ad_cooldown = maxf(0.0, ad_cooldown - time_speed)

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
	cash += net_quarter_cash

	recalculate_forbes_rank()
	return {
		"passive_inc": passive_inc,
		"living_cost": living_cost,
		"net_cash": net_quarter_cash
	}

func apply_delta(d_money: float, d_health: int, d_intellect: int, d_stress: int, d_happiness: int, d_energy: int) -> void:
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

	cash += d_money
	health = clamp(health + adj_health, 0, 100)
	intellect = max(1, intellect + adj_intellect)
	stress = clamp(stress + adj_stress, 0, 100)
	happiness = clamp(happiness + d_happiness, 0, 100)
	energy = clamp(energy + adj_energy, 0, 100)

	advance_quarter_and_markets()
	recalculate_forbes_rank()

# Операции с инвестиционным портфелем
func buy_stocks(amount_usd: float) -> bool:
	if cash < amount_usd or amount_usd <= 0.0:
		return false
	cash -= amount_usd
	stock_units += amount_usd / stock_index
	recalculate_forbes_rank()
	return true

func sell_all_stocks() -> float:
	var val := stock_units * stock_index
	cash += val
	stock_units = 0.0
	recalculate_forbes_rank()
	return val

func buy_crypto(amount_usd: float) -> bool:
	if cash < amount_usd or amount_usd <= 0.0:
		return false
	cash -= amount_usd
	crypto_units += amount_usd / crypto_rate
	recalculate_forbes_rank()
	return true

func sell_all_crypto() -> float:
	var val := crypto_units * crypto_rate
	cash += val
	crypto_units = 0.0
	recalculate_forbes_rank()
	return val

# Покупка и масштабирование бизнеса
func upgrade_or_scale_business() -> Dictionary:
	if business_tier < BUSINESS_TIERS.size() - 1:
		var next_tier := business_tier + 1
		var cost: float = BUSINESS_TIERS[next_tier]["cost"]
		if cash >= cost:
			cash -= cost
			business_tier = next_tier
			business_scale = 1
			recalculate_forbes_rank()
			return {"ok": true, "msg": "Открыт новый уровень бизнеса: " + BUSINESS_TIERS[business_tier]["name"]}
		else:
			return {"ok": false, "msg": "Недостаточно кэша! Требуется $" + format_num(cost)}
	else:
		# Масштабирование глобального техно-холдинга (поглощение корпораций на пути к $250 млрд)
		var scale_cost := 250000000.0 * float(business_scale)
		if cash >= scale_cost:
			cash -= scale_cost
			business_scale *= 2
			recalculate_forbes_rank()
			return {"ok": true, "msg": "Глобальное поглощение завершено! Масштаб империи удвоен (x%d)!" % business_scale}
		else:
			return {"ok": false, "msg": "Для поглощения конкурента нужно $" + format_num(scale_cost)}

func register_inheritance_on_end() -> String:
	var nw := get_net_worth()
	legacy_points += 1 + int(max(0, age - 30) / 15)
	var msg := ""
	if age >= 50 and nw > 1000.0:
		inherited_capital = snappedf(nw * 0.20, 1.0)
		generation += 1
		msg = "По завещанию потомку (Поколение #%d) передано 20%% состояния: $%s. Очки династии: %d." % [
			generation, format_num(inherited_capital), legacy_points
		]
	else:
		inherited_capital = 0.0
		generation += 1
		msg = "Наследство не оставлено (требуется возраст 50+ и положительный капитал). Очки династии: %d." % legacy_points
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
