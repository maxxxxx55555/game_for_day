extends Node

const SAVE_PATH := "user://dynasty_save.cfg"
const ACTIVE_SAVE_PATH := "user://active_game.cfg"

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
var business_scale: int = 1 # Масштабирование топового бизнеса
var marketing_boost: float = 1.0 # Временный мультипликатор маркетинга
var manager_hired: bool = false # Нанят ли топ-менеджер
var business_risk_factor: float = 1.0 # Рисковый модификатор дохода от внешних угроз

const BUSINESS_TIERS := [
	{"name": "Нет бизнеса", "cost": 0.0, "income": 0.0, "valuation": 0.0},
	{"name": "Кофейня / Фриланс-студия", "cost": 5000.0, "income": 650.0, "valuation": 4500.0},
	{"name": "Сеть точек / Веб-агентство", "cost": 50000.0, "income": 6800.0, "valuation": 48000.0},
	{"name": "IT-Продукт / Производство", "cost": 500000.0, "income": 72000.0, "valuation": 520000.0},
	{"name": "Национальная Корпорация", "cost": 10000000.0, "income": 1500000.0, "valuation": 12000000.0},
	{"name": "Глобальный Техно-Холдинг (IPO)", "cost": 250000000.0, "income": 45000000.0, "valuation": 320000000.0}
]

# Достижения (Ачивки)
var unlocked_achievements: Dictionary = {
	"first_million": false,
	"first_billion": false,
	"crypto_king": false,
	"forbes_top10": false,
	"dynasty_3": false,
	"biz_mogul": false
}

const ACHIEVEMENT_DESCS := {
	"first_million": {"title": "🥇 Первый миллионер", "desc": "Заработайте свой первый $1,000,000 капитала."},
	"first_billion": {"title": "💎 Доллар в миллиард", "desc": "Достигните $1,000,000,000 общего капитала."},
	"crypto_king": {"title": "🪙 Крипто-Король", "desc": "Держите криптовалюту объемом более $100,000."},
	"forbes_top10": {"title": "👑 Топ-10 Forbes", "desc": "Войдите в десятку самых богатых людей планеты."},
	"dynasty_3": {"title": "🏛️ Вековая Династия", "desc": "Достигните 3-го поколения вашей финансовой империи."},
	"biz_mogul": {"title": "🏢 Техно-Магнат", "desc": "Создайте Глобальный Холдинг масштаба x4 и выше."}
}

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
var current_track: String = "Soft Lo-Fi Study (CC0 Procedural)"
var audio_enabled: bool = true

var has_seen_intro: bool = false
var has_rolled_birth: bool = false
var ad_cooldown: int = 0
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

	for ach_id in unlocked_achievements.keys():
		cfg.set_value("achievements", ach_id, unlocked_achievements[ach_id])

	cfg.save(SAVE_PATH)

func load_dynasty() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		generation = cfg.get_value("dynasty", "generation", 1)
		legacy_points = cfg.get_value("dynasty", "legacy_points", 0)
		inherited_capital = cfg.get_value("dynasty", "inherited_capital", 0.0)
		time_speed = cfg.get_value("settings", "time_speed", 1.0)
		audio_enabled = cfg.get_value("settings", "audio_enabled", true)

		for ach_id in unlocked_achievements.keys():
			unlocked_achievements[ach_id] = cfg.get_value("achievements", ach_id, false)

func save_active_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game", "age", age)
	cfg.set_value("game", "quarter", quarter)
	cfg.set_value("game", "total_turns", total_turns)
	cfg.set_value("game", "real_world_week", real_world_week)
	cfg.set_value("game", "cash", cash)
	cfg.set_value("game", "stock_units", stock_units)
	cfg.set_value("game", "crypto_units", crypto_units)
	cfg.set_value("game", "stock_index", stock_index)
	cfg.set_value("game", "crypto_rate", crypto_rate)
	cfg.set_value("game", "inflation_multiplier", inflation_multiplier)
	cfg.set_value("game", "difficulty_multiplier", difficulty_multiplier)
	cfg.set_value("game", "business_tier", business_tier)
	cfg.set_value("game", "business_scale", business_scale)
	cfg.set_value("game", "marketing_boost", marketing_boost)
	cfg.set_value("game", "manager_hired", manager_hired)
	cfg.set_value("game", "business_risk_factor", business_risk_factor)
	cfg.set_value("game", "health", health)
	cfg.set_value("game", "intellect", intellect)
	cfg.set_value("game", "stress", stress)
	cfg.set_value("game", "happiness", happiness)
	cfg.set_value("game", "energy", energy)
	cfg.set_value("game", "birth_origin", birth_origin)
	cfg.set_value("game", "birth_cost_modifier", birth_cost_modifier)
	cfg.set_value("game", "player_perk", player_perk)
	cfg.set_value("game", "has_rolled_birth", has_rolled_birth)
	cfg.set_value("game", "ad_cooldown", ad_cooldown)
	cfg.set_value("game", "revive_used", revive_used)
	cfg.save(ACTIVE_SAVE_PATH)

func has_active_save() -> bool:
	var cfg := ConfigFile.new()
	return cfg.load(ACTIVE_SAVE_PATH) == OK and cfg.get_value("game", "has_rolled_birth", false)

func load_active_game() -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(ACTIVE_SAVE_PATH) == OK:
		age = cfg.get_value("game", "age", 18)
		quarter = cfg.get_value("game", "quarter", 1)
		total_turns = cfg.get_value("game", "total_turns", 0)
		real_world_week = cfg.get_value("game", "real_world_week", 1)
		cash = cfg.get_value("game", "cash", 200.0)
		stock_units = cfg.get_value("game", "stock_units", 0.0)
		crypto_units = cfg.get_value("game", "crypto_units", 0.0)
		stock_index = cfg.get_value("game", "stock_index", 1000.0)
		crypto_rate = cfg.get_value("game", "crypto_rate", 100.0)
		inflation_multiplier = cfg.get_value("game", "inflation_multiplier", 1.0)
		difficulty_multiplier = cfg.get_value("game", "difficulty_multiplier", 1.0)
		business_tier = cfg.get_value("game", "business_tier", 0)
		business_scale = cfg.get_value("game", "business_scale", 1)
		marketing_boost = cfg.get_value("game", "marketing_boost", 1.0)
		manager_hired = cfg.get_value("game", "manager_hired", false)
		business_risk_factor = cfg.get_value("game", "business_risk_factor", 1.0)
		health = cfg.get_value("game", "health", 100)
		intellect = cfg.get_value("game", "intellect", 15)
		stress = cfg.get_value("game", "stress", 10)
		happiness = cfg.get_value("game", "happiness", 60)
		energy = cfg.get_value("game", "energy", 100)
		birth_origin = cfg.get_value("game", "birth_origin", "")
		birth_cost_modifier = cfg.get_value("game", "birth_cost_modifier", 1.0)
		player_perk = cfg.get_value("game", "player_perk", "none")
		has_rolled_birth = cfg.get_value("game", "has_rolled_birth", false)
		ad_cooldown = cfg.get_value("game", "ad_cooldown", 0)
		revive_used = cfg.get_value("game", "revive_used", false)
		recalculate_forbes_rank()
		check_achievements()
		return true
	return false

func clear_active_save() -> void:
	var dir := DirAccess.open("user://")
	if dir and dir.file_exists("active_game.cfg"):
		dir.remove("active_game.cfg")

func check_achievements() -> void:
	var nw := get_net_worth()
	if nw >= 1000000.0 and not unlocked_achievements["first_million"]:
		unlocked_achievements["first_million"] = true
	if nw >= 1000000000.0 and not unlocked_achievements["first_billion"]:
		unlocked_achievements["first_billion"] = true
	if (crypto_units * crypto_rate) >= 100000.0 and not unlocked_achievements["crypto_king"]:
		unlocked_achievements["crypto_king"] = true
	if rank <= 10 and rank > 0 and not unlocked_achievements["forbes_top10"]:
		unlocked_achievements["forbes_top10"] = true
	if generation >= 3 and not unlocked_achievements["dynasty_3"]:
		unlocked_achievements["dynasty_3"] = true
	if business_tier >= 5 and business_scale >= 4 and not unlocked_achievements["biz_mogul"]:
		unlocked_achievements["biz_mogul"] = true
	save_dynasty()

func reset_full_dynasty() -> void:
	generation = 1
	legacy_points = 0
	inherited_capital = 0.0
	for ach_id in unlocked_achievements.keys():
		unlocked_achievements[ach_id] = false
	save_dynasty()
	clear_active_save()
	reset_game()

func reset_game() -> void:
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
	marketing_boost = 1.0
	manager_hired = false
	business_risk_factor = 1.0
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
	save_active_game()
	recalculate_forbes_rank()
	return result

func get_portfolio_value() -> float:
	return (stock_units * stock_index) + (crypto_units * crypto_rate)

func get_business_valuation() -> float:
	if business_tier == 0:
		return 0.0
	var base_val: float = BUSINESS_TIERS[business_tier]["valuation"]
	return base_val * float(business_scale) * business_risk_factor

func get_passive_quarterly_income() -> float:
	var biz_inc: float = 0.0
	if business_tier > 0:
		biz_inc = BUSINESS_TIERS[business_tier]["income"] * float(business_scale) * marketing_boost * business_risk_factor
		if player_perk == "real_estate_mogul":
			biz_inc *= 1.2
	var div_inc: float = (stock_units * stock_index) * 0.012 # 1.2% дивидендов в квартал
	if player_perk == "wall_street":
		div_inc *= 1.5
	return biz_inc + div_inc

func get_quarterly_living_cost() -> float:
	var base_cost := (280.0 + float(age - 18) * 18.0) * birth_cost_modifier * inflation_multiplier
	if player_perk == "real_estate_mogul":
		base_cost *= 0.8
	# Обслуживание высокого уровня жизни и бизнеса
	if business_tier >= 3:
		base_cost += BUSINESS_TIERS[business_tier]["income"] * 0.15 * float(business_scale)
	if manager_hired and business_tier > 0:
		base_cost += BUSINESS_TIERS[business_tier]["income"] * 0.10 * float(business_scale)
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
		var t := clamp((nw - 1000000000.0) / 249000000000.0, 0.0, 1.0)
		rank = max(1, int(lerp(2800.0, 1.0, pow(t, 0.35))))
	else:
		rank = 1

func advance_quarter_and_markets() -> Dictionary:
	total_turns += 1
	real_world_week += int(max(1.0, 13.0 * time_speed))
	if ad_cooldown > 0:
		ad_cooldown -= 1

	if marketing_boost > 1.0:
		marketing_boost = maxf(1.0, marketing_boost - 0.05 * time_speed)

	# Постепенное восстановление рискового фактора бизнеса к 1.0
	if business_risk_factor < 1.0:
		business_risk_factor = minf(1.0, business_risk_factor + 0.05 * time_speed)

	# Уменьшение стресса, если нанят менеджер
	if manager_hired:
		stress = max(0, stress - int(3 * time_speed))

	# Продвижение кварталов и возраста с учетом настройки скорости времени
	quarter_progress_accum += time_speed
	while quarter_progress_accum >= 1.0:
		quarter_progress_accum -= 1.0
		quarter += 1
		if quarter > 4:
			quarter = 1
			age += 1

	# Инфляция и мировая сложность
	inflation_multiplier *= (1.0 + 0.007 * time_speed)
	difficulty_multiplier += 0.008 * time_speed

	# Колебания фондового индекса и криптовалюты
	var stock_delta := randf_range(-0.045, 0.065)
	if player_perk == "wall_street":
		stock_delta += 0.01
	stock_index = max(100.0, snappedf(stock_index * (1.0 + stock_delta), 0.01))

	var crypto_delta := randf_range(-0.22, 0.26)
	crypto_rate = max(5.0, snappedf(crypto_rate * (1.0 + crypto_delta), 0.01))

	# Начисление пассивного дохода и списание стоимости жизни
	var passive_inc := get_passive_quarterly_income()
	var living_cost := get_quarterly_living_cost()
	var net_quarter_cash := passive_inc - living_cost
	cash += net_quarter_cash

	recalculate_forbes_rank()
	check_achievements()
	save_active_game()
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
	if player_perk == "venture_catalyst" and d_money > 0.0:
		d_money *= 1.25

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
	check_achievements()
	save_active_game()
	return true

func sell_stocks_percent(pct: float) -> float:
	pct = clampf(pct, 0.0, 1.0)
	var units_to_sell := stock_units * pct
	var val := units_to_sell * stock_index
	stock_units -= units_to_sell
	cash += val
	recalculate_forbes_rank()
	check_achievements()
	save_active_game()
	return val

func sell_all_stocks() -> float:
	return sell_stocks_percent(1.0)

func buy_crypto(amount_usd: float) -> bool:
	if cash < amount_usd or amount_usd <= 0.0:
		return false
	cash -= amount_usd
	crypto_units += amount_usd / crypto_rate
	recalculate_forbes_rank()
	check_achievements()
	save_active_game()
	return true

func sell_crypto_percent(pct: float) -> float:
	pct = clampf(pct, 0.0, 1.0)
	var units_to_sell := crypto_units * pct
	var val := units_to_sell * crypto_rate
	crypto_units -= units_to_sell
	cash += val
	recalculate_forbes_rank()
	check_achievements()
	save_active_game()
	return val

func sell_all_crypto() -> float:
	return sell_crypto_percent(1.0)

# Покупка и масштабирование бизнеса
func upgrade_or_scale_business() -> Dictionary:
	if business_tier < BUSINESS_TIERS.size() - 1:
		var next_tier := business_tier + 1
		var cost: float = BUSINESS_TIERS[next_tier]["cost"]
		if cash >= cost:
			cash -= cost
			business_tier = next_tier
			business_scale = 1
			business_risk_factor = 1.0
			recalculate_forbes_rank()
			check_achievements()
			save_active_game()
			return {"ok": true, "msg": "Открыт новый уровень бизнеса: " + BUSINESS_TIERS[business_tier]["name"]}
		else:
			return {"ok": false, "msg": "Недостаточно кэша! Требуется $" + format_num(cost)}
	else:
		# Масштабирование глобального техно-холдинга
		var scale_cost := 250000000.0 * float(business_scale)
		if cash >= scale_cost:
			cash -= scale_cost
			business_scale *= 2
			recalculate_forbes_rank()
			check_achievements()
			save_active_game()
			return {"ok": true, "msg": "Глобальное поглощение завершено! Масштаб империи удвоен (x%d)!" % business_scale}
		else:
			return {"ok": false, "msg": "Для поглощения конкурента нужно $" + format_num(scale_cost)}

func launch_marketing_campaign() -> Dictionary:
	if business_tier == 0:
		return {"ok": false, "msg": "Сначала создайте или купите бизнес!"}
	var cost := BUSINESS_TIERS[business_tier]["valuation"] * 0.1 * float(business_scale)
	if cash < cost:
		return {"ok": false, "msg": "Маркетинг стоит $" + format_num(cost) + "! Недостаточно кэша."}
	cash -= cost
	marketing_boost = 1.35 # +35% дохода
	recalculate_forbes_rank()
	save_active_game()
	return {"ok": true, "msg": "Масштабная PR-кампания запущена! Доходы бизнеса увеличены на +35%!"}

func hire_executive_manager() -> Dictionary:
	if business_tier == 0:
		return {"ok": false, "msg": "Сначала создайте или купите бизнес!"}
	if manager_hired:
		return {"ok": false, "msg": "У вас уже нанят генеральный директор."}
	var cost := BUSINESS_TIERS[business_tier]["cost"] * 0.2 * float(business_scale)
	if cash < cost:
		return {"ok": false, "msg": "Нанайм ТОП-менеджера стоит $" + format_num(cost) + "!"}
	cash -= cost
	manager_hired = true
	recalculate_forbes_rank()
	save_active_game()
	return {"ok": true, "msg": "Генеральный директор нанят! Стресс снижается каждый квартал."}

func sell_business() -> Dictionary:
	if business_tier == 0:
		return {"ok": false, "msg": "У вас нет активного бизнеса для продажи."}
	var val := get_business_valuation() * 0.80 # 80% рыночной оценки
	cash += val
	var b_name := BUSINESS_TIERS[business_tier]["name"]
	business_tier = 0
	business_scale = 1
	marketing_boost = 1.0
	manager_hired = false
	business_risk_factor = 1.0
	recalculate_forbes_rank()
	save_active_game()
	return {"ok": true, "msg": "Компания %s успешно продана за $%s!" % [b_name, format_num(val)]}

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
	clear_active_save()
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
