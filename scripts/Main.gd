extends Control

@onready var stats_label: Label = $MarginContainer/VBoxContainer/StatsPanel/StatsLabel
@onready var market_label: Label = $MarginContainer/VBoxContainer/MarketPanel/MarketLabel
@onready var event_label: Label = $MarginContainer/VBoxContainer/EventPanel/EventLabel
@onready var music_label: Label = $MarginContainer/VBoxContainer/MusicLabel
@onready var btn_1: Button = $MarginContainer/VBoxContainer/ChoicesBox/Button1
@onready var btn_2: Button = $MarginContainer/VBoxContainer/ChoicesBox/Button2
@onready var btn_3: Button = $MarginContainer/VBoxContainer/ChoicesBox/Button3
@onready var market_btn: Button = $MarginContainer/VBoxContainer/BottomBar/MarketButton
@onready var biz_btn: Button = $MarginContainer/VBoxContainer/BottomBar/BizButton
@onready var ad_btn: Button = $MarginContainer/VBoxContainer/BottomBar/AdButton
@onready var settings_btn: Button = $MarginContainer/VBoxContainer/BottomBar/SettingsButton
var audio_settings: VBoxContainer

enum ScreenMode { INTRO, BIRTH, PERK, LIFE, MARKET, BUSINESS, SETTINGS, GAMEOVER }
var current_mode: ScreenMode = ScreenMode.INTRO
var active_event: Dictionary = {}
var last_event_title: String = ""
var can_revive: bool = false
var final_reason: String = ""
var final_victory: bool = false
var active_event_net_worth: float = 0.0
var restoring_session: bool = false
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	SoundManager.apply_gains()
	audio_settings = preload("res://scripts/audio/AudioSettings.gd").new()
	$MarginContainer/VBoxContainer/ChoicesBox.add_child(audio_settings)
	$MarginContainer/VBoxContainer/ChoicesBox.move_child(audio_settings, 0)
	audio_settings.hide()
	
	btn_1.pressed.connect(func(): on_choice_pressed(1))
	btn_2.pressed.connect(func(): on_choice_pressed(2))
	btn_3.pressed.connect(func(): on_choice_pressed(3))
	
	market_btn.pressed.connect(open_market_menu)
	biz_btn.pressed.connect(open_business_menu)
	ad_btn.pressed.connect(watch_ad_for_bonus)
	settings_btn.pressed.connect(open_settings_menu)
	
	var saved := GameManager.load_current_life()
	if saved.is_empty():
		GameManager.reset_game()
		show_intro_screen()
	else:
		restore_session(saved)
	if OS.get_cmdline_user_args().has("--verify-build"):
		var verification := preload("res://scripts/ReleaseVerification.gd").new()
		add_child(verification)
		verification.call_deferred("run", self)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_session()

func save_session() -> void:
	if restoring_session:
		return
	GameManager.save_current_life({
		"mode": int(current_mode), "event_title": active_event.get("title", ""),
		"event_net_worth": active_event_net_worth, "rng_state": rng.state,
		"last_event_title": last_event_title, "final_reason": final_reason,
		"final_victory": final_victory, "event_text": event_label.text
	})

func restore_session(saved: Dictionary) -> void:
	restoring_session = true
	var saved_mode: int = saved.get("mode", ScreenMode.INTRO)
	set_bottom_bar_enabled(saved_mode in [ScreenMode.LIFE, ScreenMode.MARKET, ScreenMode.BUSINESS, ScreenMode.SETTINGS])
	rng.state = saved.get("rng_state", rng.state)
	last_event_title = saved.get("last_event_title", "")
	active_event_net_worth = saved.get("event_net_worth", GameManager.get_net_worth())
	var pools: Array = get_survival_events() + get_career_events() + get_millionaire_events() + get_billionaire_events(active_event_net_worth)
	for event in pools:
		if event.title == saved.get("event_title", ""):
			active_event = event
			break
	match saved_mode:
		ScreenMode.BIRTH:
			current_mode = ScreenMode.BIRTH
			set_bottom_bar_enabled(false)
			update_ui()
			event_label.text = saved.get("event_text", "")
			btn_1.text = "➡️ Выбрать черту характера (18 лет)"
			btn_2.hide()
			btn_3.hide()
		ScreenMode.PERK:
			show_perk_screen()
		ScreenMode.LIFE:
			load_next_life_event("Продолжение сохранённой жизни.", true)
		ScreenMode.MARKET:
			open_market_menu()
		ScreenMode.BUSINESS:
			open_business_menu()
		ScreenMode.SETTINGS:
			open_settings_menu()
		ScreenMode.GAMEOVER:
			trigger_game_over(saved.get("final_reason", ""), saved.get("final_victory", false))
		_:
			show_intro_screen()
	restoring_session = false

func update_ui() -> void:
	if audio_settings:
		audio_settings.visible = current_mode == ScreenMode.SETTINGS
	SoundManager.apply_gains()
	var nw := GameManager.get_net_worth()
	var pass_inc := GameManager.get_passive_quarterly_income()
	var liv_cost := GameManager.get_quarterly_living_cost()
	
	stats_label.text = "Поколение #%d | Возраст: %d л. (Кв. %d) | Неделя #%d
Капитал (Net Worth): $%s | Кэш: $%s
Пассив: +$%s/кв | Расходы жизни: -$%s/кв
Здоровье: %d%% | Энергия: %d%% | Стресс: %d%% | Счастье: %d%%
Интеллект: %d | Место в Forbes: #%s" % [
		GameManager.generation, GameManager.age, GameManager.quarter, GameManager.real_world_week,
		GameManager.format_num(nw), GameManager.format_num(GameManager.cash),
		GameManager.format_num(pass_inc), GameManager.format_num(liv_cost),
		GameManager.health, GameManager.energy, GameManager.stress, GameManager.happiness,
		GameManager.intellect, format_rank(GameManager.rank)
	]
	
	var port_val := GameManager.get_portfolio_value()
	var biz_name: String = GameManager.BUSINESS_TIERS[GameManager.business_tier]["name"]
	market_label.text = "📈 Индекс S&P: $%.1f | Крипта: $%.1f | Портфель: $%s
🏢 Бизнес: %s (x%d)" % [
		GameManager.stock_index, GameManager.crypto_rate,
		GameManager.format_num(port_val), biz_name, GameManager.business_scale
	]
	
	var sound_state := "ВКЛ" if GameManager.audio_enabled else "ВЫКЛ"
	music_label.text = "🎵 Аудио [%s]: %s" % [sound_state, GameManager.current_track]
	
	if GameManager.ad_cooldown > 0:
		ad_btn.text = "📺 Бонус (%s кв)" % str(GameManager.ad_cooldown)
	else:
		ad_btn.text = "🎁 Грант"

func format_rank(r: int) -> String:
	if r >= 1000000000:
		return "%.2f млрд" % (float(r) / 1000000000.0)
	elif r >= 1000000:
		return "%.2f млн" % (float(r) / 1000000.0)
	else:
		return str(r)

func set_bottom_bar_enabled(enabled: bool) -> void:
	market_btn.disabled = not enabled
	biz_btn.disabled = not enabled
	ad_btn.disabled = not enabled
	settings_btn.disabled = not enabled

# --- ЭКРАНЫ СТАРТА (ИНТРО, ЛОТЕРЕЯ РОЖДЕНИЯ, ПЕРКИ) ---

func show_intro_screen() -> void:
	current_mode = ScreenMode.INTRO
	set_bottom_bar_enabled(false)
	GameManager.current_track = "Mosaic — спокойное начало"
	SoundManager.play_music("welcome")
	update_ui()
	
	var legacy_info := ""
	if GameManager.generation > 1:
		legacy_info = "
🧬 ДИНАСТИЯ: Поколение #%d | Наследство: $%s | Очки опыта рода: %d" % [
			GameManager.generation, GameManager.format_num(GameManager.cash - 200.0), GameManager.legacy_points
		]
	
	event_label.text = "📖 ДОБРО ПОЖАЛОВАТЬ В FORBES LADDER v2

Ваша цель — пройти путь от рождения по реальной мировой статистике до #1 в списке Forbes ($250 млрд).
• 1 ход = 1 квартал (3 месяца). Каждые 4 квартала вы стареете на 1 год.
• Каждый квартал списываются расходы на жизнь (растут с инфляцией) и начисляется доход от бизнеса и дивидендов.
• Используйте вкладки «Биржа» и «Бизнес» внизу экрана для масштабирования капитала." + legacy_info
	btn_1.text = "🎲 Испытать судьбу (Лотерея рождения)"
	btn_2.visible = false
	btn_3.visible = false

func show_birth_screen() -> void:
	current_mode = ScreenMode.BIRTH
	var info := GameManager.roll_birth_lottery()
	update_ui()
	event_label.text = "🌍 %s

%s

Регион: %s
Стартовый баланс: $%s" % [
		info["title"], info["desc"], GameManager.birth_origin, GameManager.format_num(GameManager.cash)
	]
	btn_1.text = "➡️ Выбрать черту характера (18 лет)"
	btn_2.visible = false
	btn_3.visible = false

func show_perk_screen() -> void:
	current_mode = ScreenMode.PERK
	btn_2.visible = true
	btn_3.visible = true
	update_ui()
	
	event_label.text = "🧠 ВЫБЕРИТЕ СТАРТОВУЮ ОСОБЕННОСТЬ:

Очки династии (%d) открывают продвинутые перки в следующих поколениях:" % GameManager.legacy_points
	if GameManager.legacy_points >= 3:
		btn_1.text = "🏛️ Инсайдер Уолл-Стрит (+50% дивидендов, бонус к акциям)"
		btn_2.text = "🧬 Биохакер (-50% урона здоровью, +20 Здоровья)"
		btn_3.text = "🛡️ Антикризисный менеджер (-35% стресса, +$2,500)"
	else:
		btn_1.text = "💻 Гений алгоритмов (+20 Интеллекта, бонус к учебе)"
		btn_2.text = "💪 Железный организм (-35% урона здоровью)"
		btn_3.text = "⚡ Трудоголик (-30% расхода энергии на проектах)"

# --- ОСНОВНОЙ ЦИКЛ ЖИЗНИ ---

func load_next_life_event(status_note: String = "", preserve_event: bool = false) -> void:
	if check_game_over():
		return
	current_mode = ScreenMode.LIFE
	set_bottom_bar_enabled(true)
	btn_2.visible = true
	btn_3.visible = true
	
	update_soundtrack_by_stage()
	update_ui()
	
	if not preserve_event or active_event.is_empty():
		active_event_net_worth = GameManager.get_net_worth()
		active_event = pick_modular_event()
	var prefix := ""
	if status_note != "":
		prefix = status_note + "

"
	
	event_label.text = "%s📅 Возраст: %d л. (Квартал %d)

%s" % [
		prefix, GameManager.age, GameManager.quarter, active_event["title"]
	]
	btn_1.text = active_event["o1"]
	btn_2.text = active_event["o2"]
	btn_3.text = active_event["o3"]

func update_soundtrack_by_stage() -> void:
	var nw := GameManager.get_net_worth()
	if nw >= 50000000.0:
		GameManager.current_track = "Horizon — бизнес-империя"
		SoundManager.play_music("tycoon")
	elif GameManager.age < 26:
		GameManager.current_track = "First Steps — молодость"
		SoundManager.play_music("study")
	elif GameManager.age < 50:
		GameManager.current_track = "Momentum — карьера"
		SoundManager.play_music("career")
	else:
		GameManager.current_track = "Mosaic — зрелость"
		SoundManager.play_music("welcome")

# --- ВКЛАДКИ: БИРЖА, БИЗНЕС, РЕКЛАМА, НАСТРОЙКИ ---

func open_market_menu() -> void:
	if current_mode == ScreenMode.GAMEOVER:
		return
	current_mode = ScreenMode.MARKET
	btn_2.visible = true
	btn_3.visible = true
	update_ui()
	
	var stock_val := GameManager.stock_units * GameManager.stock_index
	var crypto_val := GameManager.crypto_units * GameManager.crypto_rate
	event_label.text = "📈 ИНВЕСТИЦИОННЫЙ ПОРТФЕЛЬ:

• Ваши акции (S&P 500): $%s (Дивиденды 1.2%%/кв)
• Ваша криптовалюта: $%s (Высокая волатильность)
• Свободный кэш: $%s

Выберите операцию (не тратит квартал):" % [
		GameManager.format_num(stock_val), GameManager.format_num(crypto_val), GameManager.format_num(GameManager.cash)
	]
	btn_1.text = "📊 Купить акции S&P на 50% кэша ($%s)" % GameManager.format_num(max(0.0, GameManager.cash * 0.5))
	btn_2.text = "🪙 Купить крипту на 25% кэша ($%s)" % GameManager.format_num(max(0.0, GameManager.cash * 0.25))
	btn_3.text = "💵 Продать все активы в кэш / Назад к жизни"

func open_business_menu() -> void:
	if current_mode == ScreenMode.GAMEOVER:
		return
	current_mode = ScreenMode.BUSINESS
	btn_2.visible = true
	btn_3.visible = true
	update_ui()
	
	var cur_b: Dictionary = GameManager.BUSINESS_TIERS[GameManager.business_tier]
	var next_info := ""
	if GameManager.business_tier < GameManager.BUSINESS_TIERS.size() - 1:
		var nxt: Dictionary = GameManager.BUSINESS_TIERS[GameManager.business_tier + 1]
		next_info = "Следующий уровень: %s
Стоимость запуска: $%s | Доход: +$%s/кв" % [
			nxt["name"], GameManager.format_num(nxt["cost"]), GameManager.format_num(nxt["income"])
		]
	else:
		var sc_cost := 250000000.0 * float(GameManager.business_scale)
		next_info = "Глобальное масштабирование (x%d -> x%d)
Стоимость поглощения конкурентов: $%s" % [
			GameManager.business_scale, GameManager.business_scale * 2, GameManager.format_num(sc_cost)
		]
	
	event_label.text = "🏢 УПРАВЛЕНИЕ БИЗНЕС-ИМПЕРИЕЙ:

Текущий актив: %s (Масштаб x%d)
Чистый пассивный доход: +$%s в квартал
Оценка компании: $%s

%s" % [
		cur_b["name"], GameManager.business_scale,
		GameManager.format_num(cur_b["income"] * float(GameManager.business_scale)),
		GameManager.format_num(GameManager.get_business_valuation()),
		next_info
	]
	btn_1.text = "🚀 Открыть / Масштабировать бизнес"
	btn_2.text = "⚡ Оптимизация (+15% дохода бизнеса, Энергия -15, 1 ход)"
	btn_3.text = "🔙 Вернуться к событиям квартала"

func watch_ad_for_bonus() -> void:
	if current_mode == ScreenMode.GAMEOVER:
		return
	if GameManager.ad_cooldown > 0:
		event_label.text = "⏳ Бонус перезаряжается! Осталось кварталов: %s.

Продолжайте принимать решения." % str(GameManager.ad_cooldown)
		return
	
	var nw := maxf(2500.0, absf(GameManager.get_net_worth()))
	var grant := snappedf(maxf(1500.0, nw * 0.08), 10.0)
	GameManager.cash += grant
	SoundManager.play_sfx("pickup")
	GameManager.stress = max(0, GameManager.stress - 25)
	GameManager.energy = min(100, GameManager.energy + 35)
	GameManager.ad_cooldown = 4
	GameManager.recalculate_forbes_rank()
	if check_game_over():
		return
	update_ui()
	event_label.text = "🎁 СПОНСОРСКИЙ ГРАНТ ПОЛУЧЕН!

• +$%s на счет (масштабируется от капитала)
• Стресс снижен на 25%%, Энергия +35%%
• Перезарядка бонуса: 4 квартала." % GameManager.format_num(grant)
	save_session()

func open_settings_menu() -> void:
	if current_mode == ScreenMode.GAMEOVER:
		return
	current_mode = ScreenMode.SETTINGS
	btn_2.visible = true
	btn_3.visible = true
	update_ui()
	
	var snd := "Включен" if GameManager.audio_enabled else "Выключен"
	event_label.text = "⚙️ НАСТРОЙКИ СИМУЛЯЦИИ:

• Скорость течения времени: %.1fx (кварталов за ход)
• Музыка и звуковые эффекты: %s
• Поколение династии: #%d (Очки рода: %d)" % [
		GameManager.time_speed, snd, GameManager.generation, GameManager.legacy_points
	]
	btn_1.text = "⏳ Изменить скорость времени (Сейчас: %.1fx)" % GameManager.time_speed
	btn_2.text = "🔊 Переключить звук (Сейчас: %s)" % snd
	btn_3.text = "🔙 Вернуться к игре"

# --- ОБРАБОТКА НАЖАТИЙ КНОПОК ---

func on_choice_pressed(option: int) -> void:
	SoundManager.play_sfx("ui_click")
	match current_mode:
		ScreenMode.INTRO:
			show_birth_screen()
		ScreenMode.BIRTH:
			show_perk_screen()
		ScreenMode.PERK:
			apply_selected_perk(option)
			load_next_life_event("✨ Самостоятельная жизнь началась!")
		ScreenMode.MARKET:
			handle_market_action(option)
		ScreenMode.BUSINESS:
			handle_business_action(option)
		ScreenMode.SETTINGS:
			handle_settings_action(option)
		ScreenMode.LIFE:
			var fn: Callable = active_event["r%d" % option]
			var msg: String = fn.call()
			load_next_life_event(msg)
		ScreenMode.GAMEOVER:
			if option == 1 and can_revive:
				# Однократная экстренная помощь в офлайн-игре.
				GameManager.revive_used = true
				GameManager.health = max(55, GameManager.health)
				GameManager.stress = min(50, GameManager.stress)
				GameManager.energy = max(60, GameManager.energy)
				if GameManager.cash < 0.0:
					GameManager.cash = 1000.0
				load_next_life_event("🚑 ВТОРОЙ ШАНС! Врачи и кризис-менеджеры спасли вас!")
			else:
				GameManager.register_inheritance_on_end()
				GameManager.reset_game()
				active_event = {}
				show_intro_screen()
	save_session()

func apply_selected_perk(option: int) -> void:
	if GameManager.legacy_points >= 3:
		if option == 1:
			GameManager.player_perk = "wall_street"
			GameManager.intellect += 15
		elif option == 2:
			GameManager.player_perk = "biohacker"
			GameManager.health = 100
		else:
			GameManager.player_perk = "crisis_mgr"
			GameManager.cash += 2500.0
	else:
		if option == 1:
			GameManager.player_perk = "tech_genius"
			GameManager.intellect += 20
		elif option == 2:
			GameManager.player_perk = "iron_health"
			GameManager.health = min(100, GameManager.health + 15)
		else:
			GameManager.player_perk = "workaholic"
			GameManager.energy = 100
	GameManager.recalculate_forbes_rank()

func handle_market_action(option: int) -> void:
	if option == 1:
		var amt := GameManager.cash * 0.5
		if GameManager.buy_stocks(amt):
			SoundManager.play_sfx("purchase")
			open_market_menu()
			event_label.text = "✅ Куплены акции S&P 500 на $%s!

" % GameManager.format_num(amt) + event_label.text
		else:
			event_label.text = "❌ Недостаточно свободного кэша для покупки акций!

" + event_label.text
	elif option == 2:
		var amt := GameManager.cash * 0.25
		if GameManager.buy_crypto(amt):
			SoundManager.play_sfx("purchase")
			open_market_menu()
			event_label.text = "✅ Куплена криптовалюта на $%s!

" % GameManager.format_num(amt) + event_label.text
		else:
			event_label.text = "❌ Недостаточно свободного кэша для покупки крипты!

" + event_label.text
	else:
		var sold_s := GameManager.sell_all_stocks()
		var sold_c := GameManager.sell_all_crypto()
		var note := "💼 Возврат к событиям."
		if sold_s + sold_c > 0.0:
			SoundManager.play_sfx("sale")
			note = "💵 Активы проданы на сумму $%s!" % GameManager.format_num(sold_s + sold_c)
		load_next_life_event(note, true)

func handle_business_action(option: int) -> void:
	if option == 1:
		var res := GameManager.upgrade_or_scale_business()
		if res["ok"]:
			SoundManager.play_sfx("upgrade")
		if check_game_over():
			return
		open_business_menu()
		event_label.text = ("✅ " if res["ok"] else "❌ ") + res["msg"] + "

" + event_label.text
	elif option == 2:
		if GameManager.business_tier > 0 and GameManager.energy >= 15:
			var bonus: float = GameManager.BUSINESS_TIERS[GameManager.business_tier]["income"] * float(GameManager.business_scale) * 0.15
			GameManager.apply_delta(bonus, 0, 0, 0, 0, -15)
			load_next_life_event("⚡ Оптимизация принесла +$%s! Прошёл один ход." % GameManager.format_num(bonus))
		else:
			event_label.text = "❌ Нужен открытый бизнес и минимум 15% Энергии!

" + event_label.text
	else:
		load_next_life_event("🏢 Вы вернулись из офиса.", true)

func handle_settings_action(option: int) -> void:
	if option == 1:
		if GameManager.time_speed == 1.0:
			GameManager.time_speed = 0.5
		elif GameManager.time_speed == 0.5:
			GameManager.time_speed = 2.0
		else:
			GameManager.time_speed = 1.0
		GameManager.save_dynasty()
		open_settings_menu()
	elif option == 2:
		GameManager.audio_enabled = not GameManager.audio_enabled
		GameManager.save_dynasty()
		open_settings_menu()
	else:
		load_next_life_event("", true)

# --- ПРОВЕРКА УСЛОВИЙ ПОБЕДЫ И СМЕРТИ ---

func check_game_over() -> bool:
	if GameManager.rank == 1 and GameManager.get_net_worth() >= 250000000000.0:
		trigger_game_over("🏆 АБСОЛЮТНЫЙ ТРИУМФ!
Вы достигли состояния $250+ млрд и официально заняли #1 строчку мирового рейтинга Forbes!", true)
		return true
	if GameManager.health <= 0:
		trigger_game_over("💔 Остановка сердца на фоне износа организма. Врачи оказались бессильны.", false)
		return true
	if GameManager.stress >= 100:
		trigger_game_over("🧠 Острый нервный срыв и клиническое выгорание. Вы отошли от всех дел.", false)
		return true
	if GameManager.energy <= 0:
		trigger_game_over("⚡ Критическое физическое истощение прямо на рабочем месте.", false)
		return true
	if GameManager.get_net_worth() <= -30000.0:
		trigger_game_over("⚖️ Принудительное банкротство и арест имущества за неподъемные долги.", false)
		return true
	if GameManager.age >= 82:
		if GameManager.rank <= 10:
			trigger_game_over("👑 Вы прожили легендарную жизнь и вошли в Топ-10 богатейших людей планеты (Место #%d)!" % GameManager.rank, true)
		else:
			trigger_game_over("⏳ Жизненный путь подошел к концу в возрасте %d лет. Вы остановились на #%s месте в мире." % [GameManager.age, format_rank(GameManager.rank)], false)
		return true
	return false

func trigger_game_over(reason: String, is_victory: bool) -> void:
	final_reason = reason
	final_victory = is_victory
	current_mode = ScreenMode.GAMEOVER
	set_bottom_bar_enabled(false)
	GameManager.current_track = "Mosaic — итоги жизни"
	SoundManager.play_music("welcome")
	SoundManager.play_sfx("victory" if is_victory else "defeat")
	can_revive = not is_victory and not GameManager.revive_used and GameManager.age < 80
	var dynasty_msg := "Итоги династии будут сохранены при начале следующего поколения."
	update_ui()
	
	event_label.text = "🏁 ИТОГ ЖИЗНИ (Поколение #%d)

%s

Итоговый капитал: $%s
Финальная позиция Forbes: #%s

🧬 %s" % [
		GameManager.generation, reason,
		GameManager.format_num(GameManager.get_net_worth()),
		format_rank(GameManager.rank), dynasty_msg
	]
	
	if can_revive:
		btn_1.text = "🚑 Экстренная помощь (один раз за жизнь)"
		btn_2.visible = true
		btn_2.text = "🔄 Начать новое поколение династии"
		btn_3.visible = false
	else:
		btn_1.text = "🔄 Начать новое поколение династии"
		btn_2.visible = false
		btn_3.visible = false
	save_session()

# --- 32+ МОДУЛЬНЫХ СОБЫТИЯ ПО 4 ЭКОНОМИЧЕСКИМ ЭТАПАМ ---

func pick_modular_event() -> Dictionary:
	var nw := GameManager.get_net_worth()
	var pool: Array = []
	if nw < 25000.0:
		pool = get_survival_events()
	elif nw < 500000.0:
		pool = get_career_events()
	elif nw < 50000000.0:
		pool = get_millionaire_events()
	else:
		pool = get_billionaire_events()
	
	var candidate: Dictionary = pool[rng.randi() % pool.size()]
	var guard := 0
	while candidate["title"] == last_event_title and guard < 10:
		candidate = pool[rng.randi() % pool.size()]
		guard += 1
	last_event_title = candidate["title"]
	return candidate

func get_survival_events() -> Array:
	return [
		{
			"title": "Счета за аренду и продукты растут. Как проведете этот квартал?",
			"o1": "Взять подработку и ночные смены (+$1,400, Энергия -25, Стресс +10)",
			"r1": func(): GameManager.apply_delta(1400, -4, 1, 10, -5, -25); return "💼 Вы отработали тяжелые смены (+$1,400).",
			"o2": "Проходить интенсив по IT и финансам (-$200, Интеллект +8, Энергия -15)",
			"r2": func(): GameManager.apply_delta(-200, 0, 8, 5, 5, -15); return "📚 Ваш уровень интеллекта вырос (+8)!",
			"o3": "Отдохнуть, выспаться и заняться спортом (Здоровье +10, Стресс -20, Энергия +35)",
			"r3": func(): GameManager.apply_delta(200, 10, 0, -20, 12, 35); return "🌿 Вы восстановили силы и здоровье."
		},
		{
			"title": "Знакомый предлагает перепродавать дефицитную электронику с маркетплейсов.",
			"o1": "Вложить $800 и заняться продажами (Шанс 65% заработать +$2,800)",
			"r1": func():
				if rng.randf() < 0.65:
					GameManager.apply_delta(2800, -2, 3, 10, 10, -20)
					return "📦 Партия разлетелась за неделю! Прибыль +$2,800."
				else:
					GameManager.apply_delta(-800, -2, 1, 18, -10, -20)
					return "📉 Товар завис на складе. Убыток -$800.",
			"o2": "Работать курьером/фрилансером без риска (+$950, Энергия -15)",
			"r2": func(): GameManager.apply_delta(950, -2, 1, 5, 0, -15); return "🚲 Стабильный заработок +$950.",
			"o3": "Посвятить квартал нетворкингу и поиску ментора (Интеллект +5, Стресс -10)",
			"r3": func(): GameManager.apply_delta(300, 2, 5, -10, 8, 10); return "🤝 Вы завели полезные знакомства."
		},
		{
			"title": "Локальный хакатон стартапов с денежным призом.",
			"o1": "Выступить с собственным прототипом (Требуется Интеллект 25+)",
			"r1": func():
				if GameManager.intellect >= 25:
					GameManager.apply_delta(4500, -3, 6, 12, 20, -25)
					return "🏆 Вы заняли призовое место на хакатоне! Грант +$4,500."
				else:
					GameManager.apply_delta(300, -2, 4, 15, -5, -20)
					return "💻 Не хватило навыков для победы, но вы получили опыт (+4 Интеллекта).",
			"o2": "Помочь организаторам за фиксированную оплату (+$1,100)",
			"r2": func(): GameManager.apply_delta(1100, 0, 2, 4, 5, -12); return "🎫 Вы заработали $1,100 на организации.",
			"o3": "Пропустить мероприятие и отдохнуть дома (Энергия +30, Стресс -15)",
			"r3": func(): GameManager.apply_delta(150, 5, 0, -15, 10, 30); return "🛌 Отличный отдых дома."
		},
		{
			"title": "Проблемы со здоровьем из-за дешевой еды и перегрузок.",
			"o1": "Пройти полное обследование и лечение (-$600, Здоровье +22, Стресс -15)",
			"r1": func(): GameManager.apply_delta(-600, 22, 0, -15, 10, 20); return "🏥 Здоровье полностью укреплено (+22%).",
			"o2": "Продолжать работать через силу (+$1,200, Здоровье -12, Стресс +15)",
			"r2": func(): GameManager.apply_delta(1200, -12, 1, 15, -10, -20); return "💊 Вы заработали +$1,200, но здоровье ухудшилось.",
			"o3": "Взять недельный отпуск и перейти на домашнюю еду (Здоровье +8, Энергия +25)",
			"r3": func(): GameManager.apply_delta(200, 8, 0, -10, 8, 25); return "🥗 Самочувствие заметно улучшилось."
		},
		{
			"title": "На работе открылась вакансия младшего руководителя проекта.",
			"o1": "Взять на себя ответственность (+$2,200, Интеллект +4, Стресс +12)",
			"r1": func(): GameManager.apply_delta(2200, -3, 4, 12, 8, -20); return "📈 Вас повысили! Доход квартала +$2,200.",
			"o2": "Остаться на спокойной должности (+$1,000, Стресс -5, Энергия +10)",
			"r2": func(): GameManager.apply_delta(1000, 2, 1, -5, 5, 10); return "☕ Спокойный рабочий квартал (+$1,000).",
			"o3": "Уйти на удаленный фриланс (+$1,500, Интеллект +3, Энергия -10)",
			"r3": func(): GameManager.apply_delta(1500, 0, 3, 4, 6, -10); return "💻 Удаленные заказы принесли +$1,500."
		},
		{
			"title": "Бум нейросетей: компании ищут специалистов по автоматизации.",
			"o1": "Разработать бота под заказ бизнеса (+$3,200 при Интеллекте 30+, иначе +$900)",
			"r1": func():
				var gain := 3200.0 if GameManager.intellect >= 30 else 900.0
				GameManager.apply_delta(gain, -2, 5, 8, 10, -18)
				return "🤖 Заказ по автоматизации принес +$%s!" % GameManager.format_num(gain),
			"o2": "Изучать архитектуру ИИ и алгоритмы (Интеллект +10, Энергия -15)",
			"r2": func(): GameManager.apply_delta(100, 0, 10, 5, 5, -15); return "🧠 Интеллект вырос на +10!",
			"o3": "Восстановить баланс сна и психики (Стресс -25, Энергия +35)",
			"r3": func(): GameManager.apply_delta(200, 6, 0, -25, 15, 35); return "🧘 Полная перезагрузка нервной системы."
		}
	] + EventLibrary.events_for("survival")

func get_career_events() -> Array:
	return [
		{
			"title": "Крупный корпоративный клиент предлагает сложный контракт с жестким дедлайном.",
			"o1": "Подписать контракт и работать без выходных (+$18,000, Стресс +22, Энергия -30)",
			"r1": func(): GameManager.apply_delta(18000, -8, 4, 22, 5, -30); return "💰 Контракт закрыт! Вы получили +$18,000.",
			"o2": "Нанять подрядчиков и разделить прибыль (+$8,500, Стресс +5, Энергия -10)",
			"r2": func(): GameManager.apply_delta(8500, 0, 3, 5, 10, -10); return "🤝 Делегирование сработало отлично (+$8,500).",
			"o3": "Отказаться и уехать в оздоровительный отпуск (-$1,500, Здоровье +15, Стресс -30)",
			"r3": func(): GameManager.apply_delta(-1500, 15, 0, -30, 25, 40); return "🏖️ Отпуск вернул вам здоровье и бодрость!"
		},
		{
			"title": "На рынке коммерческой недвижимости просадка цен из-за высоких ставок.",
			"o1": "Выкупить проблемный объект и сдать в субаренду (-$15,000, шанс 70% на +$38,000)",
			"r1": func():
				if rng.randf() < 0.70:
					GameManager.apply_delta(23000, 0, 4, 12, 15, -15)
					return "🏢 Сделка с недвижимостью принесла чистыми +$23,000!"
				else:
					GameManager.apply_delta(-12000, -4, 2, 20, -10, -15)
					return "📉 Арендаторы съехали раньше срока. Убыток -$12,000.",
			"o2": "Сфокусироваться на основной карьере и консалтинге (+$9,500)",
			"r2": func(): GameManager.apply_delta(9500, -2, 3, 8, 5, -15); return "💼 Консалтинг принес стабильные +$9,500.",
			"o3": "Пройти программу MBA и обрасти связями (-$4,000, Интеллект +14, Энергия +10)",
			"r3": func(): GameManager.apply_delta(-4000, 2, 14, -5, 12, 10); return "🎓 Диплом MBA укрепил ваш интеллект (+14)."
		},
		{
			"title": "Налоговая проверка и аудит вашей финансовой деятельности.",
			"o1": "Нанять топовых юристов и закрыть все вопросы легально (-$5,000, Стресс -10)",
			"r1": func(): GameManager.apply_delta(-5000, 0, 2, -10, 5, -5); return "⚖️ Юристы блестяще защитили ваши активы.",
			"o2": "Разбираться с документами самостоятельно (+$4,000 экономии, Стресс +25, Энергия -25)",
			"r2": func(): GameManager.apply_delta(4000, -5, 3, 25, -10, -25); return "📑 Вы отбились от штрафов сами, но сильно устали.",
			"o3": "Провести реструктуризацию и отдохнуть (Здоровье +10, Стресс -20, Энергия +30)",
			"r3": func(): GameManager.apply_delta(2000, 10, 1, -20, 12, 30); return "🌿 Дела приведены в порядок без лишней спешки."
		},
		{
			"title": "Венчурный фонд ищет соинвесторов для запуска облачной платформы.",
			"o1": "Войти в раунд А (Требуется Интеллект 45+ для отбора проекта, +$32,000)",
			"r1": func():
				if GameManager.intellect >= 45:
					GameManager.apply_delta(32000, -2, 5, 10, 20, -15)
					return "🚀 Ваш аналитический расчет оправдался! +$32,000."
				else:
					GameManager.apply_delta(-8000, -2, 4, 18, -10, -15)
					return "📉 Без глубокой экспертизы стартап оказался пустышкой (-$8,000).",
			"o2": "Выступить платным техническим экспертом (+$11,000, Энергия -15)",
			"r2": func(): GameManager.apply_delta(11000, -2, 3, 6, 8, -15); return "🔍 Экспертиза принесла +$11,000.",
			"o3": "Заняться чекапом организма и спортом (Здоровье +15, Стресс -20, Энергия +30)",
			"r3": func(): GameManager.apply_delta(1000, 15, 0, -20, 15, 30); return "💪 Отличная физическая форма!"
		}
	] + EventLibrary.events_for("career")

func get_millionaire_events() -> Array:
	return [
		{
			"title": "Крупный конкурент испытывает кассовый разрыв и ищет покупателя на долю.",
			"o1": "Провести жесткое поглощение активов (+$450,000 при Интеллекте 60+, иначе -$120,000)",
			"r1": func():
				if GameManager.intellect >= 60:
					GameManager.apply_delta(450000, -5, 6, 18, 20, -25)
					return "🦈 Блестящая сделка M&A! Капитал вырос на +$450,000."
				else:
					GameManager.apply_delta(-120000, -5, 4, 25, -15, -25)
					return "⚠️ В отчетности конкурента обнаружились скрытые долги (-$120,000).",
			"o2": "Выдать обеспеченный залогом кредит (+$160,000 без риска)",
			"r2": func(): GameManager.apply_delta(160000, 0, 2, 5, 10, -10); return "🏦 Проценты по сделке принесли +$160,000.",
			"o3": "Устроить семейный круиз по океану (-$25,000, Здоровье +20, Стресс -35, Энергия +45)",
			"r3": func(): GameManager.apply_delta(-25000, 20, 0, -35, 30, 45); return "🛥️ Роскошный отдых полностью восстановил ваши силы."
		},
		{
			"title": "Глобальный сбой цепочек поставок угрожает маржинальности рынков.",
			"o1": "Профинансировать собственные логистические хабы (+$320,000, Энергия -25)",
			"r1": func(): GameManager.apply_delta(320000, -4, 4, 15, 12, -25); return "🚢 Своя логистика позволила обойти кризис (+$320,000).",
			"o2": "Захеджировать валютные риски через опционы (+$140,000, Стресс -5)",
			"r2": func(): GameManager.apply_delta(140000, 0, 3, -5, 8, -10); return "🛡️ Хеджирование сохранило и приумножило капитал (+$140,000).",
			"o3": "Передать операционку совету директоров и отдохнуть (Стресс -25, Энергия +35)",
			"r3": func(): GameManager.apply_delta(60000, 12, 1, -25, 20, 35); return "⛳ Совет директоров справился, пока вы отдыхали."
		},
		{
			"title": "Международный технологический форум в Давосе.",
			"o1": "Презентовать стратегию экспансии инвесторам (+$600,000, Стресс +20, Энергия -25)",
			"r1": func(): GameManager.apply_delta(600000, -4, 5, 20, 25, -25); return "🌍 Инвесторы выстроились в очередь! Приток +$600,000.",
			"o2": "Провести закрытые кулуарные переговоры (+$240,000, Интеллект +6)",
			"r2": func(): GameManager.apply_delta(240000, 0, 6, 5, 12, -10); return "🥂 Кулуарные контракты принесли +$240,000.",
			"o3": "Остаться в альпийском спа-отеле (Здоровье +18, Стресс -30, Энергия +40)",
			"r3": func(): GameManager.apply_delta(0, 18, 0, -30, 25, 40); return "🏔️ Чистый горный воздух вернул вам молодость."
		}
	] + EventLibrary.events_for("millionaire")

func get_billionaire_events(event_net_worth: float = -1.0) -> Array:
	var scale_mult := maxf(1.0, (GameManager.get_net_worth() if event_net_worth < 0 else event_net_worth) * 0.08)
	return [
		{
			"title": "Глобальная гонка искусственного интеллекта и квантовых дата-центров.",
			"o1": "Инвестировать в постройку мега-кластера (Шанс 75%% на +$%s)" % GameManager.format_num(scale_mult * 2.2),
			"r1": func():
				if rng.randf() < 0.75:
					var win := scale_mult * 2.2
					GameManager.apply_delta(win, -5, 8, 18, 25, -25)
					return "🌌 Ваш ИИ-кластер стал мировым стандартом! Капитал +$%s." % GameManager.format_num(win)
				else:
					var loss := scale_mult * 0.6
					GameManager.apply_delta(-loss, -5, 4, 25, -15, -25)
					return "⚡ Задержка поставок чипов привела к убыткам -$%s." % GameManager.format_num(loss),
			"o2": "Лицензировать патенты конкурентам (+$%s гарантированно)" % GameManager.format_num(scale_mult * 0.9),
			"r2": func():
				var gain := scale_mult * 0.9
				GameManager.apply_delta(gain, 0, 4, 5, 15, -10)
				return "📜 Патентные роялти принесли +$%s." % GameManager.format_num(gain),
			"o3": "Провести курс омоложения и биохакинга (Здоровье +25, Стресс -35, Энергия +45)",
			"r3": func():
				GameManager.apply_delta(scale_mult * 0.15, 25, 2, -35, 30, 45)
				return "🧬 Передовая медицина восстановила ваше здоровье (+25%).",
		},
		{
			"title": "Антимонопольный комитет рассматривает влияние вашей империи на мировую экономику.",
			"o1": "Вывести дочерние бренды на биржу через громкое IPO (+$%s, Стресс +20)" % GameManager.format_num(scale_mult * 1.8),
			"r1": func():
				var gain := scale_mult * 1.8
				GameManager.apply_delta(gain, -4, 5, 20, 20, -20)
				return "🔔 Триумфальное IPO дочерних компаний принесло +$%s!" % GameManager.format_num(gain),
			"o2": "Учредить глобальный благотворительный научный фонд (+Счастье, -Стресс, +$%s)" % GameManager.format_num(scale_mult * 0.6),
			"r2": func():
				var gain := scale_mult * 0.6
				GameManager.apply_delta(gain, 10, 4, -25, 35, 25)
				return "🕊️ Благотворительный фонд укрепил вашу репутацию и капитализацию (+$%s)." % GameManager.format_num(gain),
			"o3": "Уединиться на частном острове на весь квартал (Здоровье +20, Стресс -40, Энергия +50)",
			"r3": func():
				GameManager.apply_delta(scale_mult * 0.25, 20, 0, -40, 35, 50)
				return "🏝️ Абсолютный покой на частном острове.",
		}
	] + EventLibrary.events_for("billionaire")
