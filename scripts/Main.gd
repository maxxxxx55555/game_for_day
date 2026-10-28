extends Control
const DashboardView=preload("res://scripts/ui/FortuneDashboard.gd")
const CurrencyView=preload("res://scripts/ui/CurrencyPanel.gd")
const FinaleView=preload("res://scripts/ui/LifeFinale.gd")
const ChoiceView=preload("res://scripts/ui/ChoiceCard.gd")
const CreditsView=preload("res://scripts/ui/FortuneCredits.gd")
const BirthRevealView=preload("res://scripts/ui/BirthReveal.gd")

@onready var stats_label: Label = $MarginContainer/VBoxContainer/StatsPanel/StatsLabel
@onready var market_label: Label = $MarginContainer/VBoxContainer/MarketPanel/MarketLabel
@onready var event_label: Label = $MarginContainer/VBoxContainer/EventPanel/EventScroll/EventLabel
@onready var music_label: Label = $MarginContainer/VBoxContainer/MusicLabel
@onready var btn_1: Button = $MarginContainer/VBoxContainer/ChoicesBox/Button1
@onready var btn_2: Button = $MarginContainer/VBoxContainer/ChoicesBox/Button2
@onready var btn_3: Button = $MarginContainer/VBoxContainer/ChoicesBox/Button3
@onready var market_btn: Button = $MarginContainer/VBoxContainer/BottomBar/MarketButton
@onready var biz_btn: Button = $MarginContainer/VBoxContainer/BottomBar/BizButton
@onready var ad_btn: Button = $MarginContainer/VBoxContainer/BottomBar/AdButton
@onready var settings_btn: Button = $MarginContainer/VBoxContainer/BottomBar/SettingsButton
var audio_settings: VBoxContainer
var dashboard: DashboardView
var market_back: Button
var currency_button: Button
var currency_panel: CurrencyView
var story_art: TextureRect
var finale_overlay: FinaleView
var save_status: Label
var outcome: Label
var outcome_timer:float=0.0
var choice_cards:Array[ChoiceView]=[]
var language_choice:OptionButton
var intro_actions:HBoxContainer
var credits_panel:CreditsView
var story_transition:Tween
var birth_reveal:BirthRevealView
var story_content:VBoxContainer

enum ScreenMode { INTRO, BIRTH, PERK, LIFE, MARKET, BUSINESS, SETTINGS, GAMEOVER, CURRENCY }
var current_mode: ScreenMode = ScreenMode.INTRO
var active_event: Dictionary = {}
var last_event_title: String = ""
var can_revive: bool = false
var final_reason: String = ""
var final_victory: bool = false
var active_event_net_worth: float = 0.0
var restoring_session: bool = false
var rng:RandomNumberGenerator= RandomNumberGenerator.new()

func _ready() -> void:
	get_tree().quit_on_go_back = false
	save_status = Label.new()
	save_status.name = "SaveStatus"
	save_status.text = LocalizationManager.source("copy.bf448e0995f5")
	save_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	save_status.add_theme_color_override("font_color",Color("ffbf90"))
	save_status.add_theme_color_override("font_outline_color",Color("10191b"))
	save_status.add_theme_constant_override("outline_size",8)
	save_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	save_status.z_index = 100
	add_child(save_status)
	save_status.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	save_status.offset_top = -150
	save_status.offset_bottom = -95
	save_status.offset_left = 20
	save_status.offset_right = -20
	save_status.visible = not GameManager.write_failures.is_empty()
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	GameManager.persistence_changed.connect(func(ok:bool)->void: save_status.visible = not ok)
	preload("res://scripts/ui/FortuneTheme.gd").apply(self)
	for button:Button in [btn_1,btn_2,btn_3]:
		var card:ChoiceView=preload("res://scripts/ui/ChoiceCard.gd").new()
		button.add_child(card)
		choice_cards.append(card)
	dashboard = preload("res://scripts/ui/FortuneDashboard.gd").new()
	stats_label.hide()
	stats_label.get_parent().add_child(dashboard)
	var column:Node= $MarginContainer/VBoxContainer
	var brand:Label= Label.new()
	brand.text = "HEIRS OF FORTUNE"
	brand.add_theme_font_override("font", load("res://assets/fonts/Prata-Regular.ttf") as Font)
	brand.add_theme_font_size_override("font_size", 32)
	brand.add_theme_color_override("font_color", Color("d4bd90"))
	column.add_child(brand)
	column.move_child(brand,0)
	language_choice=OptionButton.new()
	language_choice.name="LanguageChoice"
	language_choice.auto_translate_mode=Node.AUTO_TRANSLATE_MODE_DISABLED
	language_choice.add_item("Русский")
	language_choice.add_item("English")
	language_choice.selected=0 if LocalizationManager.current_language=="ru" else 1
	intro_actions=HBoxContainer.new()
	column.add_child(intro_actions)
	column.move_child(intro_actions,1)
	language_choice.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	intro_actions.add_child(language_choice)
	var credits_button:Button=Button.new()
	credits_button.name="CreditsButton"
	credits_button.text=LocalizationManager.source("ui.credits")
	credits_button.custom_minimum_size.x=150
	intro_actions.add_child(credits_button)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	credits_button.pressed.connect(open_credits)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	language_choice.item_selected.connect(func(index:int)->void:LocalizationManager.set_language("ru" if index==0 else "en"))
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	LocalizationManager.language_changed.connect(func(language:String)->void:
		language_choice.select(0 if language=="ru" else 1)
		for card:ChoiceView in choice_cards:card.refresh()
		if dashboard:dashboard.refresh_values()
	)
	var content:VBoxContainer= VBoxContainer.new()
	content.name = "StoryContent"
	story_content = content
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation",18)
	$MarginContainer/VBoxContainer/EventPanel/EventScroll.add_child(content)
	event_label.reparent(content)
	story_art = TextureRect.new()
	story_art.texture = load("res://assets/art/city_folio.png")
	story_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	story_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	story_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(story_art)
	content.move_child(story_art,0)
	birth_reveal = preload("res://scripts/ui/BirthReveal.gd").new()
	birth_reveal.name = "BirthReveal"
	content.add_child(birth_reveal)
	content.move_child(birth_reveal,1)
	birth_reveal.hide()
	event_label.add_theme_color_override("font_color",Color("ede7da"))
	event_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	event_label.size_flags_vertical=Control.SIZE_SHRINK_BEGIN
	outcome=Label.new()
	outcome.name="LastOutcome"
	outcome.add_theme_font_size_override("font_size",15)
	outcome.add_theme_color_override("font_color",Color("8a97a6"))
	outcome.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
	outcome.hide()
	content.add_child(outcome)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	event_label.minimum_size_changed.connect(func()->void: ($MarginContainer/VBoxContainer/EventPanel/EventScroll as ScrollContainer).scroll_vertical = 0)
	market_back = Button.new()
	market_back.name = "MarketBack"
	market_back.text = LocalizationManager.source("copy.57ec323d704b")
	market_back.custom_minimum_size.y = 54
	market_back.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	$MarginContainer/VBoxContainer/ChoicesBox.add_child(market_back)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	market_back.pressed.connect(func()->void:
		load_next_life_event("", true)
		# save_session reports persistence failure to the visible save-status path.
		@warning_ignore("return_value_discarded")
		save_session()
	)
	currency_button = Button.new()
	currency_button.name = "CurrenciesButton"
	currency_button.text = LocalizationManager.source("copy.aa18a82d3630")
	currency_button.custom_minimum_size.y = 54
	$MarginContainer/VBoxContainer/ChoicesBox.add_child(currency_button)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	currency_button.pressed.connect(open_currency_menu)
	currency_panel = preload("res://scripts/ui/CurrencyPanel.gd").new()
	add_child(currency_panel)
	currency_panel.hide()
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	currency_panel.closed.connect(open_market_menu)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	currency_panel.traded.connect(func()->void:
		if check_game_over(): return
		update_ui()
		# save_session reports persistence failure to the visible save-status path.
		@warning_ignore("return_value_discarded")
		save_session()
	)
	finale_overlay = preload("res://scripts/ui/LifeFinale.gd").new()
	add_child(finale_overlay)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	finale_overlay.choice_requested.connect(on_choice_pressed)
	rng.randomize()
	SoundManager.apply_gains()
	audio_settings = preload("res://scripts/audio/AudioSettings.gd").new()
	$MarginContainer/VBoxContainer/ChoicesBox.add_child(audio_settings)
	$MarginContainer/VBoxContainer/ChoicesBox.move_child(audio_settings, 0)
	audio_settings.hide()
	
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	btn_1.pressed.connect(func()->void: on_choice_pressed(1))
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	btn_2.pressed.connect(func()->void: on_choice_pressed(2))
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	btn_3.pressed.connect(func()->void: on_choice_pressed(3))
	
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	market_btn.pressed.connect(open_market_menu)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	biz_btn.pressed.connect(open_business_menu)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	ad_btn.pressed.connect(watch_ad_for_bonus)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	settings_btn.pressed.connect(open_settings_menu)
	
	var saved:Dictionary= GameManager.load_current_life()
	if saved.is_empty():
		GameManager.reset_game()
		show_intro_screen()
	else:
		restore_session(saved)
	# The private QA router handles rejection/exit itself; normal startup continues when no flag is supplied.
	@warning_ignore("return_value_discarded")
	preload("res://scripts/security/QARouter.gd").request(self)

func _notification(what: int) -> void:
	if not is_node_ready(): return
	if FortuneArrival.quitting:return
	if what==NOTIFICATION_WM_CLOSE_REQUEST:
		request_exit()
	elif what in [NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT]:
		# save_session reports persistence failure to the visible save-status path.
		@warning_ignore("return_value_discarded")
		save_session()
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if is_instance_valid(credits_panel):
			credits_panel.close()
			return
		if current_mode in [ScreenMode.MARKET, ScreenMode.BUSINESS, ScreenMode.SETTINGS, ScreenMode.CURRENCY]:
			load_next_life_event("", true)
			# save_session reports persistence failure to the visible save-status path.
			@warning_ignore("return_value_discarded")
			save_session()
		else:
			request_exit()

func request_exit() -> void:
	if FortuneArrival.quitting:return
	if save_session():FortuneArrival.quit_game()
	else:FortuneArrival.confirm_unsaved(save_session,FortuneArrival.quit_game)

func save_session() -> bool:
	if restoring_session:
		return true
	return GameManager.save_current_life({
		"mode": int(current_mode), "event_title": active_event.get("title", ""),
		"event_net_worth": active_event_net_worth, "rng_state": rng.state,
		"last_event_title": last_event_title, "final_reason": final_reason,
		"final_victory": final_victory, "event_text": event_label.text
	})

func restore_session(saved: Dictionary) -> void:
	restoring_session = true
	var saved_mode: int = saved.get("mode", ScreenMode.INTRO)
	set_bottom_bar_enabled(saved_mode in [ScreenMode.LIFE, ScreenMode.MARKET, ScreenMode.BUSINESS, ScreenMode.SETTINGS, ScreenMode.CURRENCY])
	rng.state = saved.get("rng_state", rng.state)
	last_event_title = saved.get("last_event_title", "")
	active_event_net_worth = saved.get("event_net_worth", GameManager.get_net_worth())
	var pools: Array = get_survival_events() + get_career_events() + get_millionaire_events() + get_billionaire_events(active_event_net_worth)
	for event:Variant in pools:
		if event.title == saved.get("event_title", ""):
			active_event = event
			break
	match saved_mode:
		ScreenMode.BIRTH:
			current_mode = ScreenMode.BIRTH
			set_bottom_bar_enabled(false)
			update_ui()
			event_label.text = saved.get("event_text", "")
			if birth_reveal: birth_reveal.present_from_state()
			btn_1.text = LocalizationManager.source("copy.c45c411166e2")
			btn_2.hide()
			btn_3.hide()
		ScreenMode.PERK:
			show_perk_screen()
		ScreenMode.LIFE:
			load_next_life_event(LocalizationManager.source("copy.f135cbb79f60"), true)
		ScreenMode.MARKET:
			open_market_menu()
		ScreenMode.CURRENCY:
			open_currency_menu()
		ScreenMode.BUSINESS:
			open_business_menu()
		ScreenMode.SETTINGS:
			open_settings_menu()
		ScreenMode.GAMEOVER:
			var saved_reason:String=saved.get("final_reason","")
			var saved_victory:bool=saved.get("final_victory",false)
			trigger_game_over(saved_reason,saved_victory)
		_:
			show_intro_screen()
	restoring_session = false

func update_ui() -> void:
	if intro_actions:intro_actions.visible=current_mode==ScreenMode.INTRO
	if finale_overlay: finale_overlay.visible = current_mode == ScreenMode.GAMEOVER
	($MarginContainer as Control).visible = current_mode != ScreenMode.GAMEOVER
	if dashboard: dashboard.refresh_values()
	if market_back: market_back.visible = current_mode == ScreenMode.MARKET
	if currency_button: currency_button.visible = current_mode == ScreenMode.MARKET
	if currency_panel: currency_panel.visible = current_mode == ScreenMode.CURRENCY
	($MarginContainer/VBoxContainer/MarketPanel as Control).hide()
	music_label.hide()
	($MarginContainer/VBoxContainer/StatsPanel as Control).visible = current_mode != ScreenMode.INTRO
	($MarginContainer/VBoxContainer/BottomBar as Control).visible = current_mode in [ScreenMode.LIFE,ScreenMode.MARKET,ScreenMode.BUSINESS,ScreenMode.SETTINGS]
	story_art.visible = current_mode in [ScreenMode.INTRO,ScreenMode.PERK,ScreenMode.LIFE]
	story_art.custom_minimum_size.y = 260 if current_mode == ScreenMode.INTRO else 190
	if birth_reveal: birth_reveal.visible = current_mode == ScreenMode.BIRTH
	if story_content:
		story_content.alignment = BoxContainer.ALIGNMENT_CENTER if current_mode == ScreenMode.BIRTH else BoxContainer.ALIGNMENT_BEGIN
	story_art.size_flags_vertical=Control.SIZE_EXPAND_FILL
	market_btn.text = LocalizationManager.source("copy.47ff48632f92")
	biz_btn.text = LocalizationManager.source("copy.964b2df03bda")
	settings_btn.text = LocalizationManager.source("copy.7f17c7c62a7f")
	if audio_settings:
		audio_settings.visible = current_mode == ScreenMode.SETTINGS
	SoundManager.apply_gains()
	var nw:float= GameManager.get_net_worth()
	var pass_inc:float= GameManager.get_passive_quarterly_income()
	var liv_cost:float= GameManager.get_quarterly_living_cost()
	
	stats_label.text = LocalizationManager.source("copy.8e0adca0f56b") % [
		GameManager.generation, GameManager.age, GameManager.quarter, GameManager.real_world_week,
		GameManager.format_num(nw), GameManager.format_num(GameManager.cash),
		GameManager.format_num(pass_inc), GameManager.format_num(liv_cost),
		GameManager.health, GameManager.energy, GameManager.stress, GameManager.happiness,
		GameManager.intellect, format_rank(GameManager.rank)
	]
	
	var port_val:float= GameManager.get_portfolio_value()
	var biz_name: String = GameManager.BUSINESS_TIERS[GameManager.business_tier]["name"]
	market_label.text = LocalizationManager.source("copy.71c3cf0f114b") % [
		GameManager.stock_index, GameManager.crypto_rate,
		GameManager.format_num(port_val), biz_name, GameManager.business_scale
	]
	
	var sound_state:String= LocalizationManager.source("copy.5936895c8651") if GameManager.audio_enabled and not SoundManager.force_mute else LocalizationManager.source("copy.919af88107a1")
	music_label.text = LocalizationManager.source("copy.1556d74b3343") % [sound_state, GameManager.current_track]
	
	if GameManager.ad_cooldown > 0:
		# The director owns the voice; action feedback serial records the acknowledgment.
		@warning_ignore("return_value_discarded")
		SoundManager.play_sfx("ui_error")
		ad_btn.text = LocalizationManager.source("copy.c54826c2787f") % str(GameManager.ad_cooldown)
	else:
		ad_btn.text = LocalizationManager.source("copy.3bcab31e2fd9")

func _process(delta: float) -> void:
	event_label.text = clean_copy(event_label.text)
	for button:Button in [btn_1,btn_2,btn_3]: button.text = clean_copy(button.text)
	for card:ChoiceView in choice_cards: card.refresh()
	outcome_timer=maxf(0,outcome_timer-delta)
	if outcome: outcome.visible=outcome_timer>0 and current_mode==ScreenMode.LIFE

func clean_copy(text: String) -> String:
	var result:String= ""
	for i:int in text.length():
		var code:int= text.unicode_at(i)
		if code >= 0x1f000 and code <= 0x1faff: continue
		if code >= 0x2600 and code <= 0x27ff: continue
		if code in [0xfe0f,0x200d]: continue
		result += text[i]
	return result.strip_edges()

func format_rank(r: int) -> String:
	if r >= 1000000000:
		return LocalizationManager.source("copy.21a9f89a5145") % (float(r) / 1000000000.0)
	elif r >= 1000000:
		return LocalizationManager.source("copy.547cd75236ac") % (float(r) / 1000000.0)
	else:
		return str(r)

func set_bottom_bar_enabled(enabled: bool) -> void:
	market_btn.disabled = not enabled
	biz_btn.disabled = not enabled
	ad_btn.disabled = not enabled
	settings_btn.disabled = not enabled
	for button:Variant in [market_btn,biz_btn,ad_btn,settings_btn]:
		button.tooltip_text=LocalizationManager.source("ui.begin_life_first") if not enabled else ""

# --- ЭКРАНЫ СТАРТА (ИНТРО, ЛОТЕРЕЯ РОЖДЕНИЯ, ПЕРКИ) ---

func show_intro_screen() -> void:
	current_mode = ScreenMode.INTRO
	set_bottom_bar_enabled(false)
	GameManager.current_track = "Last Call at Three"
	SoundManager.play_music("welcome")
	update_ui()
	
	var legacy_info:String= ""
	if GameManager.generation > 1:
		legacy_info = LocalizationManager.source("copy.07966e7a5d32") % [
			GameManager.generation, GameManager.format_num(GameManager.cash - 200.0), GameManager.legacy_points
		]
	
	event_label.text = LocalizationManager.source("copy.fed691559450") + legacy_info
	btn_1.text = LocalizationManager.source("copy.cc92b6b195e4")
	btn_2.visible = false
	btn_3.visible = false

func show_birth_screen() -> void:
	if not LocalizationManager.language_confirmed:LocalizationManager.set_language(LocalizationManager.current_language)
	current_mode = ScreenMode.BIRTH
	var info:Dictionary= GameManager.roll_birth_lottery()
	update_ui()
	if birth_reveal: birth_reveal.present(info)
	event_label.text = LocalizationManager.source("birth.pick_trait")
	btn_1.text = LocalizationManager.source("copy.c45c411166e2")
	btn_2.visible = false
	btn_3.visible = false

func show_perk_screen() -> void:
	current_mode = ScreenMode.PERK
	btn_2.visible = true
	btn_3.visible = true
	update_ui()
	
	event_label.text = LocalizationManager.source("copy.e0209c93a0eb") % GameManager.legacy_points
	if GameManager.legacy_points >= 3:
		btn_1.text = LocalizationManager.source("copy.908965d61d75")
		btn_2.text = LocalizationManager.source("copy.f37aea39c473")
		btn_3.text = LocalizationManager.source("copy.0d5713148cdd")
	else:
		btn_1.text = LocalizationManager.source("copy.b2485dfd429c")
		btn_2.text = LocalizationManager.source("copy.2c34a6b3982b")
		btn_3.text = LocalizationManager.source("copy.728389ddd486")

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
	event_label.text = active_event["title"]
	if not status_note.is_empty():
		outcome.text=clean_copy(status_note).replace("\n"," ")
		outcome.tooltip_text=clean_copy(status_note)
		outcome_timer=7.0
	btn_1.text = active_event["o1"]
	btn_2.text = active_event["o2"]
	btn_3.text = active_event["o3"]
	animate_story()

func update_soundtrack_by_stage() -> void:
	var nw:float= GameManager.get_net_worth()
	if nw >= 50000000.0:
		GameManager.current_track = SoundManager.music_title("tycoon")
		SoundManager.play_music("tycoon")
	elif GameManager.age < 26:
		GameManager.current_track = SoundManager.music_title("study")
		SoundManager.play_music("study")
	elif GameManager.age < 50:
		GameManager.current_track = SoundManager.music_title("career")
		SoundManager.play_music("career")
	else:
		GameManager.current_track = "Last Call at Three"
		SoundManager.play_music("welcome")

# --- ВКЛАДКИ: БИРЖА, БИЗНЕС, РЕКЛАМА, НАСТРОЙКИ ---

func open_market_menu() -> void:
	if current_mode == ScreenMode.GAMEOVER:
		return
	current_mode = ScreenMode.MARKET
	btn_2.visible = true
	btn_3.visible = true
	update_ui()
	
	var stock_val:float= GameManager.stock_units * GameManager.stock_index
	var crypto_val:float= GameManager.crypto_units * GameManager.crypto_rate
	event_label.text = LocalizationManager.source("copy.9a13d56f1eb5") % [GameManager.format_num(stock_val), GameManager.format_num(crypto_val)]
	btn_1.text = LocalizationManager.source("copy.ce42724ffc48") % GameManager.format_num(maxf(0.0, GameManager.cash * 0.5))
	btn_2.text = LocalizationManager.source("copy.ed467fc2f563") % GameManager.format_num(maxf(0.0, GameManager.cash * 0.25))
	btn_3.text = LocalizationManager.source("copy.bcfb6801b5e7")

func open_currency_menu() -> void:
	if current_mode == ScreenMode.GAMEOVER: return
	current_mode = ScreenMode.CURRENCY
	update_ui()
	currency_panel.refresh()

func open_business_menu() -> void:
	if current_mode == ScreenMode.GAMEOVER:
		return
	current_mode = ScreenMode.BUSINESS
	btn_2.visible = true
	btn_3.visible = true
	update_ui()
	
	var cur_b: Dictionary = GameManager.BUSINESS_TIERS[GameManager.business_tier]
	var current_income:float=cur_b.income
	var next_info:String= ""
	if GameManager.business_tier < GameManager.BUSINESS_TIERS.size() - 1:
		var nxt: Dictionary = GameManager.BUSINESS_TIERS[GameManager.business_tier + 1]
		var next_cost:float=nxt.cost
		var next_income:float=nxt.income
		next_info = LocalizationManager.source("copy.a2be6aad5f03") % [
			nxt["name"], GameManager.format_num(next_cost), GameManager.format_num(next_income)
		]
	else:
		var sc_cost:float= 250000000.0 * float(GameManager.business_scale)
		next_info = LocalizationManager.source("copy.e1bf8275af22") % [
			GameManager.business_scale, GameManager.business_scale * 2, GameManager.format_num(sc_cost)
		]
	
	event_label.text = LocalizationManager.source("copy.1d0c6be6aad9") % [cur_b["name"], GameManager.business_scale, GameManager.format_num(current_income * float(GameManager.business_scale)), GameManager.format_num(GameManager.get_business_valuation()), next_info]
	btn_1.text = LocalizationManager.source("copy.39fd05978986")
	btn_2.text = LocalizationManager.source("copy.b509a224641b")
	btn_3.text = LocalizationManager.source("copy.57ec323d704b")

func watch_ad_for_bonus() -> void:
	if current_mode == ScreenMode.GAMEOVER:
		return
	if GameManager.ad_cooldown > 0:
		# The director owns the voice; action feedback serial records the acknowledgment.
		@warning_ignore("return_value_discarded")
		SoundManager.play_sfx("ui_error")
		event_label.text = LocalizationManager.source("copy.1d33e8d9a164") % str(GameManager.ad_cooldown)
		return
	
	var grant:float=GameManager.claim_grant()
	if grant<=0:
		# The director owns the voice; action feedback serial records the acknowledgment.
		@warning_ignore("return_value_discarded")
		SoundManager.play_sfx("ui_error")
		return
	# The director owns the voice; action feedback serial records the acknowledgment.
	@warning_ignore("return_value_discarded")
	SoundManager.play_sfx("grant")
	if check_game_over():
		return
	update_ui()
	event_label.text = LocalizationManager.source("copy.9bfe591e09c4") % GameManager.format_num(grant)
	# save_session reports persistence failure to the visible save-status path.
	@warning_ignore("return_value_discarded")
	save_session()

func open_settings_menu() -> void:
	if current_mode == ScreenMode.GAMEOVER:
		return
	current_mode = ScreenMode.SETTINGS
	btn_2.visible = true
	btn_3.visible = true
	update_ui()
	
	var snd:String= LocalizationManager.source("copy.edde94ba8823") if GameManager.audio_enabled else LocalizationManager.source("copy.6eb7540d7c53")
	event_label.text = LocalizationManager.source("copy.c9cc711f4032") % [
		GameManager.time_speed, snd, GameManager.generation, GameManager.legacy_points
	]
	btn_1.text = LocalizationManager.source("copy.709e020e05a4") % GameManager.time_speed
	btn_2.text = LocalizationManager.source("copy.2f9864a97ebc") % snd
	btn_3.text = LocalizationManager.source("copy.1feff1f51d9e")

# --- ОБРАБОТКА НАЖАТИЙ КНОПОК ---

var choice_busy:bool=false

func on_choice_pressed(option: int) -> void:
	if choice_busy:return
	choice_busy=true
	_apply_choice(option)
	choice_busy=false

func _apply_choice(option:int)->void:
	match current_mode:
		ScreenMode.INTRO:
			show_birth_screen()
		ScreenMode.BIRTH:
			show_perk_screen()
		ScreenMode.PERK:
			apply_selected_perk(option)
			load_next_life_event(LocalizationManager.source("copy.626462e893e5"))
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
				load_next_life_event(LocalizationManager.source("copy.eb39f4f8fa06"))
			else:
				# Inheritance is idempotent and persistence failure is reported by the model.
				@warning_ignore("return_value_discarded")
				GameManager.register_inheritance_on_end()
				GameManager.reset_game()
				active_event = {}
				show_intro_screen()
	# save_session reports persistence failure to the visible save-status path.
	@warning_ignore("return_value_discarded")
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
		var amt:float= GameManager.cash * 0.5
		if GameManager.buy_stocks(amt):
			# The director owns the voice; action feedback serial records the acknowledgment.
			@warning_ignore("return_value_discarded")
			SoundManager.play_sfx("purchase")
			open_market_menu()
			event_label.text = LocalizationManager.source("copy.30fe6d28992e") % GameManager.format_num(amt) + event_label.text
		else:
			# The director owns the voice; action feedback serial records the acknowledgment.
			@warning_ignore("return_value_discarded")
			SoundManager.play_sfx("ui_error")
			event_label.text = LocalizationManager.source("copy.01ceea2130e1") + event_label.text
	elif option == 2:
		var amt:float= GameManager.cash * 0.25
		if GameManager.buy_crypto(amt):
			# The director owns the voice; action feedback serial records the acknowledgment.
			@warning_ignore("return_value_discarded")
			SoundManager.play_sfx("purchase")
			open_market_menu()
			event_label.text = LocalizationManager.source("copy.67d6a0681bd8") % GameManager.format_num(amt) + event_label.text
		else:
			# The director owns the voice; action feedback serial records the acknowledgment.
			@warning_ignore("return_value_discarded")
			SoundManager.play_sfx("ui_error")
			event_label.text = LocalizationManager.source("copy.4379c0b7c8cd") + event_label.text
	else:
		var sold_s:float= GameManager.sell_all_stocks()
		var sold_c:float= GameManager.sell_all_crypto()
		var note:String= LocalizationManager.source("copy.ab4c949a31bc")
		if sold_s + sold_c > 0.0:
			# The director owns the voice; action feedback serial records the acknowledgment.
			@warning_ignore("return_value_discarded")
			SoundManager.play_sfx("sale")
			note = LocalizationManager.source("copy.35be604060f8") % GameManager.format_num(sold_s + sold_c)
		load_next_life_event(note, true)

func handle_business_action(option: int) -> void:
	if option == 1:
		var res:Dictionary= GameManager.upgrade_or_scale_business()
		# The director owns the voice; action feedback serial records the acknowledgment.
		@warning_ignore("return_value_discarded")
		SoundManager.play_sfx("upgrade" if res["ok"] else "ui_error")
		if check_game_over():
			return
		open_business_menu()
		event_label.text = ("✅ " if res["ok"] else "❌ ") + res["msg"] + "

" + event_label.text
	elif option == 2:
		if GameManager.business_tier > 0 and GameManager.energy >= 15:
			var bonus:float=GameManager.get_optimization_bonus()
			GameManager.apply_delta(bonus, 0, 0, 0, 0, -15)
			# The director owns the voice; action feedback serial records the acknowledgment.
			@warning_ignore("return_value_discarded")
			SoundManager.play_sfx("coin")
			load_next_life_event(LocalizationManager.source("copy.ed4b0b659951") % GameManager.format_num(bonus))
		else:
			# The director owns the voice; action feedback serial records the acknowledgment.
			@warning_ignore("return_value_discarded")
			SoundManager.play_sfx("ui_error")
			event_label.text = LocalizationManager.source("copy.6d0c821355a9") + event_label.text
	else:
		load_next_life_event(LocalizationManager.source("copy.87de3bb66d37"), true)

func handle_settings_action(option: int) -> void:
	if option == 1:
		if GameManager.time_speed == 1.0:
			GameManager.time_speed = 0.5
		elif GameManager.time_speed == 0.5:
			GameManager.time_speed = 2.0
		else:
			GameManager.time_speed = 1.0
		# save_dynasty reports persistence failure to the visible save-status path.
		@warning_ignore("return_value_discarded")
		GameManager.save_dynasty()
		open_settings_menu()
	elif option == 2:
		GameManager.audio_enabled = not GameManager.audio_enabled
		# save_dynasty reports persistence failure to the visible save-status path.
		@warning_ignore("return_value_discarded")
		GameManager.save_dynasty()
		open_settings_menu()
	else:
		load_next_life_event("", true)

# --- ПРОВЕРКА УСЛОВИЙ ПОБЕДЫ И СМЕРТИ ---

func check_game_over() -> bool:
	if GameManager.rank == 1 and GameManager.get_net_worth() >= 250000000000.0:
		trigger_game_over(LocalizationManager.source("copy.35118a151aa7"), true)
		return true
	if GameManager.health <= 0:
		trigger_game_over(LocalizationManager.source("copy.14b8a11ef688"), false)
		return true
	if GameManager.stress >= 100:
		trigger_game_over(LocalizationManager.source("copy.8ac4a20f459a"), false)
		return true
	if GameManager.energy <= 0:
		trigger_game_over(LocalizationManager.source("copy.8d3c88012d83"), false)
		return true
	if GameManager.get_net_worth() <= -30000.0:
		trigger_game_over(LocalizationManager.source("copy.7f4b17d5695c"), false)
		return true
	if GameManager.age >= GameManager.death_age:
		if GameManager.rank <= 10:
			trigger_game_over(LocalizationManager.source("copy.848fe0958410") % GameManager.rank, true)
		else:
			trigger_game_over(LocalizationManager.source("copy.4fd334376182") % [GameManager.age, format_rank(GameManager.rank)], false)
		return true
	return false

func show_finale() -> void:
	finale_overlay.present({"victory":final_victory,"reason":clean_copy(final_reason),"wealth":GameManager.format_num(GameManager.get_net_worth()),"rank":format_rank(GameManager.rank),"generation":GameManager.generation,"age":GameManager.age,"revive":can_revive})

func trigger_game_over(reason: String, is_victory: bool) -> void:
	final_reason = reason
	final_victory = is_victory
	current_mode = ScreenMode.GAMEOVER
	set_bottom_bar_enabled(false)
	GameManager.current_track = "Last Call at Three"
	SoundManager.play_finale(is_victory)
	can_revive = not is_victory and not GameManager.revive_used and GameManager.age < 80
	var dynasty_msg:String= LocalizationManager.source("copy.b71d63dd66c0")
	update_ui()
	
	event_label.text = LocalizationManager.source("copy.5965f40d6b39") % [
		GameManager.generation, reason,
		GameManager.format_num(GameManager.get_net_worth()),
		format_rank(GameManager.rank), dynasty_msg
	]
	
	if can_revive:
		btn_1.text = LocalizationManager.source("copy.b9a91297dde4")
		btn_2.visible = true
		btn_2.text = LocalizationManager.source("copy.13d00648f2d7")
		btn_3.visible = false
	else:
		btn_1.text = LocalizationManager.source("copy.13d00648f2d7")
		btn_2.visible = false
		btn_3.visible = false
	show_finale()
	# save_session reports persistence failure to the visible save-status path.
	@warning_ignore("return_value_discarded")
	save_session()

# --- 32+ МОДУЛЬНЫХ СОБЫТИЯ ПО 4 ЭКОНОМИЧЕСКИМ ЭТАПАМ ---

func pick_modular_event() -> Dictionary:
	var nw:float= GameManager.get_net_worth()
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
	var guard:int= 0
	while candidate["title"] == last_event_title and guard < 10:
		candidate = pool[rng.randi() % pool.size()]
		guard += 1
	last_event_title = candidate["title"]
	return candidate

func get_survival_events() -> Array:
	return [
		{
			"title": LocalizationManager.source("copy.de2a6f7ecd03"),
			"o1": LocalizationManager.source("copy.0c3022c59e3e"),
			"r1": func()->Variant: GameManager.apply_delta(1400, -4, 1, 10, -5, -25); return LocalizationManager.source("copy.040809336be4"),
			"o2": LocalizationManager.source("copy.63250eaa07ff"),
			"r2": func()->Variant: GameManager.apply_delta(-200, 0, 8, 5, 5, -15); return LocalizationManager.source("copy.ce6cf579ea2b"),
			"o3": LocalizationManager.source("copy.57b165c2f936"),
			"r3": func()->Variant: GameManager.apply_delta(200, 10, 0, -20, 12, 35); return LocalizationManager.source("copy.9f38175c8969")
		},
		{
			"title": LocalizationManager.source("copy.946b501b66a6"),
			"o1": LocalizationManager.source("copy.581db62553d7"),
			"r1": func()->Variant:
				if rng.randf() < 0.65:
					GameManager.apply_delta(2800, -2, 3, 10, 10, -20)
					return LocalizationManager.source("copy.ad218c565f88")
				else:
					GameManager.apply_delta(-800, -2, 1, 18, -10, -20)
					return LocalizationManager.source("copy.668ea0fd9c03"),
			"o2": LocalizationManager.source("copy.425ffaf6d250"),
			"r2": func()->Variant: GameManager.apply_delta(950, -2, 1, 5, 0, -15); return LocalizationManager.source("copy.56e35f27471f"),
			"o3": LocalizationManager.source("copy.1277de12e43e"),
			"r3": func()->Variant: GameManager.apply_delta(300, 2, 5, -10, 8, 10); return LocalizationManager.source("copy.c8dc61cd4524")
		},
		{
			"title": LocalizationManager.source("copy.d3483c318bd7"),
			"o1": LocalizationManager.source("copy.9b246ac48259"),
			"r1": func()->Variant:
				if GameManager.intellect >= 25:
					GameManager.apply_delta(4500, -3, 6, 12, 20, -25)
					return LocalizationManager.source("copy.f1de0c92fc74")
				else:
					GameManager.apply_delta(300, -2, 4, 15, -5, -20)
					return LocalizationManager.source("copy.d3bea7ef17de"),
			"o2": LocalizationManager.source("copy.a39b3f8d6862"),
			"r2": func()->Variant: GameManager.apply_delta(1100, 0, 2, 4, 5, -12); return LocalizationManager.source("copy.0ee48b338227"),
			"o3": LocalizationManager.source("copy.a47a5e41a30b"),
			"r3": func()->Variant: GameManager.apply_delta(150, 5, 0, -15, 10, 30); return LocalizationManager.source("copy.f3a791c2646a")
		},
		{
			"title": LocalizationManager.source("copy.89650c4a24ab"),
			"o1": LocalizationManager.source("copy.488af448b06d"),
			"r1": func()->Variant: GameManager.apply_delta(-600, 22, 0, -15, 10, 20); return LocalizationManager.source("copy.676e06f8634c"),
			"o2": LocalizationManager.source("copy.bfad3023f3ba"),
			"r2": func()->Variant: GameManager.apply_delta(1200, -12, 1, 15, -10, -20); return LocalizationManager.source("copy.d07556011189"),
			"o3": LocalizationManager.source("copy.f3cd70d26426"),
			"r3": func()->Variant: GameManager.apply_delta(200, 8, 0, -10, 8, 25); return LocalizationManager.source("copy.c376a4f0217e")
		},
		{
			"title": LocalizationManager.source("copy.c5ef2e086f8b"),
			"o1": LocalizationManager.source("copy.d8f3a6fe0af0"),
			"r1": func()->Variant: GameManager.apply_delta(2200, -3, 4, 12, 8, -20); return LocalizationManager.source("copy.af1b68768b3a"),
			"o2": LocalizationManager.source("copy.313d6c0a68d2"),
			"r2": func()->Variant: GameManager.apply_delta(1000, 2, 1, -5, 5, 10); return LocalizationManager.source("copy.59338dd850a4"),
			"o3": LocalizationManager.source("copy.276587c257d5"),
			"r3": func()->Variant: GameManager.apply_delta(1500, 0, 3, 4, 6, -10); return LocalizationManager.source("copy.c23c0d676dfa")
		},
		{
			"title": LocalizationManager.source("copy.c6971ee65bcb"),
			"o1": LocalizationManager.source("copy.d7ccaea6dc89"),
			"r1": func()->Variant:
				var gain:float= 3200.0 if GameManager.intellect >= 30 else 900.0
				GameManager.apply_delta(gain, -2, 5, 8, 10, -18)
				return LocalizationManager.source("copy.7c899eb130df") % GameManager.format_num(gain),
			"o2": LocalizationManager.source("copy.e378e8878609"),
			"r2": func()->Variant: GameManager.apply_delta(100, 0, 10, 5, 5, -15); return LocalizationManager.source("copy.6245542029c3"),
			"o3": LocalizationManager.source("copy.c28a02729595"),
			"r3": func()->Variant: GameManager.apply_delta(200, 6, 0, -25, 15, 35); return LocalizationManager.source("copy.256a39ac45f5")
		}
	] + EventLibrary.events_for("survival")

func get_career_events() -> Array:
	return [
		{
			"title": LocalizationManager.source("copy.0b6ffe72e8ed"),
			"o1": LocalizationManager.source("copy.493af682846b"),
			"r1": func()->Variant: GameManager.apply_delta(18000, -8, 4, 22, 5, -30); return LocalizationManager.source("copy.60c540913e98"),
			"o2": LocalizationManager.source("copy.8ac918f166b3"),
			"r2": func()->Variant: GameManager.apply_delta(8500, 0, 3, 5, 10, -10); return LocalizationManager.source("copy.88c763182a3a"),
			"o3": LocalizationManager.source("copy.1c8c3ff50cc8"),
			"r3": func()->Variant: GameManager.apply_delta(-1500, 15, 0, -30, 25, 40); return LocalizationManager.source("copy.e6a8d04f65c3")
		},
		{
			"title": LocalizationManager.source("copy.2f64e5f86a8a"),
			"o1": LocalizationManager.source("copy.9bd9ba917046"),
			"r1": func()->Variant:
				if rng.randf() < 0.70:
					GameManager.apply_delta(23000, 0, 4, 12, 15, -15)
					return LocalizationManager.source("copy.427336beea9c")
				else:
					GameManager.apply_delta(-12000, -4, 2, 20, -10, -15)
					return LocalizationManager.source("copy.3bdda846c354"),
			"o2": LocalizationManager.source("copy.2352880633de"),
			"r2": func()->Variant: GameManager.apply_delta(9500, -2, 3, 8, 5, -15); return LocalizationManager.source("copy.a68bf3b69447"),
			"o3": LocalizationManager.source("copy.d5a6241a4923"),
			"r3": func()->Variant: GameManager.apply_delta(-4000, 2, 14, -5, 12, 10); return LocalizationManager.source("copy.a817effb7405")
		},
		{
			"title": LocalizationManager.source("copy.153c58937472"),
			"o1": LocalizationManager.source("copy.494af8ddcb35"),
			"r1": func()->Variant: GameManager.apply_delta(-5000, 0, 2, -10, 5, -5); return LocalizationManager.source("copy.e5a599dd29c3"),
			"o2": LocalizationManager.source("copy.600c40150298"),
			"r2": func()->Variant: GameManager.apply_delta(4000, -5, 3, 25, -10, -25); return LocalizationManager.source("copy.b49dec85bba7"),
			"o3": LocalizationManager.source("copy.458a1d2a5ad2"),
			"r3": func()->Variant: GameManager.apply_delta(2000, 10, 1, -20, 12, 30); return LocalizationManager.source("copy.59fd9d43e41b")
		},
		{
			"title": LocalizationManager.source("copy.c98ac97b1cb3"),
			"o1": LocalizationManager.source("copy.a4316ea3c95b"),
			"r1": func()->Variant:
				if GameManager.intellect >= 45:
					GameManager.apply_delta(32000, -2, 5, 10, 20, -15)
					return LocalizationManager.source("copy.20536b57a9ef")
				else:
					GameManager.apply_delta(-8000, -2, 4, 18, -10, -15)
					return LocalizationManager.source("copy.828fb0804dfb"),
			"o2": LocalizationManager.source("copy.f1bb3f9ee94b"),
			"r2": func()->Variant: GameManager.apply_delta(11000, -2, 3, 6, 8, -15); return LocalizationManager.source("copy.3a1d44880892"),
			"o3": LocalizationManager.source("copy.0257df066402"),
			"r3": func()->Variant: GameManager.apply_delta(1000, 15, 0, -20, 15, 30); return LocalizationManager.source("copy.407c5f406f9a")
		}
	] + EventLibrary.events_for("career")

func get_millionaire_events() -> Array:
	return [
		{
			"title": LocalizationManager.source("copy.d88c31c1d726"),
			"o1": LocalizationManager.source("copy.9e65892b0c6e"),
			"r1": func()->Variant:
				if GameManager.intellect >= 60:
					GameManager.apply_delta(450000, -5, 6, 18, 20, -25)
					return LocalizationManager.source("copy.42f3c1de7182")
				else:
					GameManager.apply_delta(-120000, -5, 4, 25, -15, -25)
					return LocalizationManager.source("copy.68960af84db5"),
			"o2": LocalizationManager.source("copy.26cb492cda4b"),
			"r2": func()->Variant: GameManager.apply_delta(160000, 0, 2, 5, 10, -10); return LocalizationManager.source("copy.412bce5e6108"),
			"o3": LocalizationManager.source("copy.7683dbed0e78"),
			"r3": func()->Variant: GameManager.apply_delta(-25000, 20, 0, -35, 30, 45); return LocalizationManager.source("copy.c528a7b3f678")
		},
		{
			"title": LocalizationManager.source("copy.f258bd410451"),
			"o1": LocalizationManager.source("copy.0a752ba503f7"),
			"r1": func()->Variant: GameManager.apply_delta(320000, -4, 4, 15, 12, -25); return LocalizationManager.source("copy.a7d66c8d12e3"),
			"o2": LocalizationManager.source("copy.c4145a6c57e1"),
			"r2": func()->Variant: GameManager.apply_delta(140000, 0, 3, -5, 8, -10); return LocalizationManager.source("copy.b0c7aea67e84"),
			"o3": LocalizationManager.source("copy.cdd14f6c2c30"),
			"r3": func()->Variant: GameManager.apply_delta(60000, 12, 1, -25, 20, 35); return LocalizationManager.source("copy.a1aa6c89c5fa")
		},
		{
			"title": LocalizationManager.source("copy.bd5d76a53d88"),
			"o1": LocalizationManager.source("copy.09ca3d3c9fde"),
			"r1": func()->Variant: GameManager.apply_delta(600000, -4, 5, 20, 25, -25); return LocalizationManager.source("copy.06e601ea1ed0"),
			"o2": LocalizationManager.source("copy.b60ef3c4ab78"),
			"r2": func()->Variant: GameManager.apply_delta(240000, 0, 6, 5, 12, -10); return LocalizationManager.source("copy.060e13776b56"),
			"o3": LocalizationManager.source("copy.c710a81df73f"),
			"r3": func()->Variant: GameManager.apply_delta(0, 18, 0, -30, 25, 40); return LocalizationManager.source("copy.d82dd42ed897")
		}
	] + EventLibrary.events_for("millionaire")

func get_billionaire_events(event_net_worth: float = -1.0) -> Array:
	var scale_mult:float= maxf(1.0, (GameManager.get_net_worth() if event_net_worth < 0 else event_net_worth) * 0.08)
	return [
		{
			"title": LocalizationManager.source("copy.592c313ed838"),
			"o1": LocalizationManager.source("copy.abef1f22864e") % GameManager.format_num(scale_mult * 2.2),
			"r1": func()->Variant:
				if rng.randf() < 0.75:
					var win:float= scale_mult * 2.2
					GameManager.apply_delta(win, -5, 8, 18, 25, -25)
					return LocalizationManager.source("copy.f1546a30c0ad") % GameManager.format_num(win)
				else:
					var loss:float= scale_mult * 0.6
					GameManager.apply_delta(-loss, -5, 4, 25, -15, -25)
					return LocalizationManager.source("copy.391ed2771a2c") % GameManager.format_num(loss),
			"o2": LocalizationManager.source("copy.9a2eb5202848") % GameManager.format_num(scale_mult * 0.9),
			"r2": func()->Variant:
				var gain:float= scale_mult * 0.9
				GameManager.apply_delta(gain, 0, 4, 5, 15, -10)
				return LocalizationManager.source("copy.1764e101d247") % GameManager.format_num(gain),
			"o3": LocalizationManager.source("copy.33517dbfdf3a"),
			"r3": func()->Variant:
				GameManager.apply_delta(scale_mult * 0.15, 25, 2, -35, 30, 45)
				return LocalizationManager.source("copy.329fd53f192b"),
		},
		{
			"title": LocalizationManager.source("copy.21daa0f76935"),
			"o1": LocalizationManager.source("copy.be8b999f3b0a") % GameManager.format_num(scale_mult * 1.8),
			"r1": func()->Variant:
				var gain:float= scale_mult * 1.8
				GameManager.apply_delta(gain, -4, 5, 20, 20, -20)
				return LocalizationManager.source("copy.106035a32214") % GameManager.format_num(gain),
			"o2": LocalizationManager.source("copy.eda7fa63a1cd") % GameManager.format_num(scale_mult * 0.6),
			"r2": func()->Variant:
				var gain:float= scale_mult * 0.6
				GameManager.apply_delta(gain, 10, 4, -25, 35, 25)
				return LocalizationManager.source("copy.298e9d265c65") % GameManager.format_num(gain),
			"o3": LocalizationManager.source("copy.828d067a6408"),
			"r3": func()->Variant:
				GameManager.apply_delta(scale_mult * 0.25, 20, 0, -40, 35, 50)
				return LocalizationManager.source("copy.8431904301ab"),
		}
	] + EventLibrary.events_for("billionaire")

func open_credits() -> void:
	if is_instance_valid(credits_panel):return
	var previous_focus:Control=get_viewport().gui_get_focus_owner()
	credits_panel=preload("res://scripts/ui/FortuneCredits.gd").new()
	add_child(credits_panel)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	credits_panel.closed.connect(func()->void:
		credits_panel=null
		if is_instance_valid(previous_focus):previous_focus.grab_focus()
	)

func animate_story() -> void:
	var panel:Control=$MarginContainer/VBoxContainer/EventPanel
	if is_instance_valid(story_transition):story_transition.kill()
	panel.modulate.a=1.0
	if GameManager.reduced_motion:return
	panel.modulate.a=0.9
	story_transition=create_tween()
	# Tween owns this fluent configuration; no reference to the builder is needed.
	@warning_ignore("return_value_discarded")
	story_transition.tween_property(panel,"modulate:a",1.0,0.18).set_trans(Tween.TRANS_SINE)

func _unhandled_key_input(event:InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_notification(NOTIFICATION_WM_GO_BACK_REQUEST)
		get_viewport().set_input_as_handled()
