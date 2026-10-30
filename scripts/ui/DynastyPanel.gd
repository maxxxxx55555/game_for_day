extends Control
## Local dynasty ledger: journal, permanent perks, life threads, hall of fame and
## ascension state. Every figure comes from GameManager; the panel owns no rules.
signal closed
signal thread_requested(chain_id: String)
const Palette=preload("res://scripts/ui/Palette.gd")
const SkinTheme=preload("res://scripts/ui/FortuneTheme.gd")
const Money=preload("res://scripts/security/Money.gd")
const SECTIONS:Array[String]=["journal","legacy","threads","hall","ascension"]
var title_label:Label
var balance_label:Label
var close_button:Button
var content:VBoxContainer
var backdrop:Panel
var tabs:Dictionary={}
var tab_group:ButtonGroup
var active_section:String="journal"

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop=Panel.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.add_theme_stylebox_override("panel",SkinTheme.style(Palette.ink()))
	add_child(backdrop)
	var margin:MarginContainer=MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side:String in ["left","right"]: margin.add_theme_constant_override("margin_"+side,24)
	for side:String in ["top","bottom"]: margin.add_theme_constant_override("margin_"+side,24)
	add_child(margin)
	var column:VBoxContainer=VBoxContainer.new()
	column.add_theme_constant_override("separation",10)
	margin.add_child(column)
	var header:HBoxContainer=HBoxContainer.new()
	header.add_theme_constant_override("separation",10)
	column.add_child(header)
	title_label=Label.new()
	title_label.add_theme_font_override("font",SkinTheme.display_font(700))
	title_label.add_theme_font_size_override("font_size",24)
	title_label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	header.add_child(title_label)
	close_button=Button.new()
	close_button.name="DynastyClose"
	close_button.custom_minimum_size.y=44
	header.add_child(close_button)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	close_button.pressed.connect(func()->void: closed.emit())
	balance_label=Label.new()
	balance_label.add_theme_font_size_override("font_size",13)
	balance_label.add_theme_color_override("font_color",Palette.muted())
	balance_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	column.add_child(balance_label)
	tab_group=ButtonGroup.new()
	var grid:GridContainer=GridContainer.new()
	grid.columns=3
	grid.add_theme_constant_override("h_separation",6)
	grid.add_theme_constant_override("v_separation",6)
	column.add_child(grid)
	for section:String in SECTIONS:
		var tab:Button=Button.new()
		tab.name="Tab_"+section
		tab.toggle_mode=true
		tab.button_group=tab_group
		tab.custom_minimum_size.y=40
		tab.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		tab.add_theme_font_size_override("font_size",13)
		tab.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		grid.add_child(tab)
		tabs[section]=tab
		# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
		@warning_ignore("return_value_discarded")
		tab.pressed.connect(set_section.bind(section))
	var scroll:ScrollContainer=ScrollContainer.new()
	scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	content=VBoxContainer.new()
	content.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation",8)
	scroll.add_child(content)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	LocalizationManager.language_changed.connect(func(_language:String)->void:
		if visible: refresh()
	)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	GameManager.theme_changed.connect(func(_mode:String)->void: apply_skin())
	hide()

## The ledger paints its own backdrop and rows, so a skin change has to rebuild
## them instead of inheriting the theme like the buttons do.
func apply_skin() -> void:
	if not is_instance_valid(backdrop):
		return
	backdrop.add_theme_stylebox_override("panel",SkinTheme.style(Palette.ink()))
	if is_instance_valid(balance_label):
		balance_label.add_theme_color_override("font_color",Palette.muted())
	if visible:
		refresh()

func set_section(section:String) -> void:
	if not SECTIONS.has(section):
		return
	active_section=section
	refresh()

func add_line(text:String, font_size:int=15, color:Color=Color(0,0,0,0)) -> void:
	if color.a==0.0:
		color=Palette.muted()
	var label:Label=Label.new()
	label.text=text
	label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	content.add_child(label)

func add_heading(text:String) -> void:
	var label:Label=Label.new()
	label.text=text
	label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font",SkinTheme.display_font(600))
	label.add_theme_font_size_override("font_size",14)
	label.add_theme_color_override("font_color",Palette.accent())
	content.add_child(label)

func add_panel() -> VBoxContainer:
	var box:PanelContainer=PanelContainer.new()
	box.add_theme_stylebox_override("panel",SkinTheme.panel(Palette.surface(),Palette.rule_soft(),8))
	content.add_child(box)
	var column:VBoxContainer=VBoxContainer.new()
	column.add_theme_constant_override("separation",5)
	box.add_child(column)
	return column

func add_action(parent:Node,text:String,enabled:bool,tooltip:String,callback:Callable) -> void:
	var button:Button=Button.new()
	button.text=text
	button.disabled=not enabled
	button.tooltip_text=tooltip
	button.custom_minimum_size.y=42
	button.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	button.add_theme_font_size_override("font_size",14)
	parent.add_child(button)
	if enabled:
		# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
		@warning_ignore("return_value_discarded")
		button.pressed.connect(callback)

func clear_content() -> void:
	for child:Node in content.get_children():
		content.remove_child(child)
		child.queue_free()

func hall_stats() -> String:
	var wins:int=0
	var best_cents:int=0
	var best_rank:int=0
	var chains:int=0
	for value:Variant in GameManager.dynasty_records:
		if not value is Dictionary:
			continue
		var record:Dictionary=value
		var victory:bool=record.get("victory",false)
		if victory:
			wins+=1
		var record_cents:int=record.get("wealth_cents",0)
		best_cents=maxi(best_cents,record_cents)
		var record_rank:int=record.get("rank",0)
		if record_rank>0 and (best_rank==0 or record_rank<best_rank):
			best_rank=record_rank
		var record_chains:int=record.get("chains",0)
		chains+=record_chains
	var rank_text:String="—" if best_rank==0 else GameManager.format_rank(best_rank)
	return LocalizationManager.source("dynasty.stats") % [
		GameManager.lives_completed,wins,
		GameManager.format_num(Money.dollars(best_cents)),rank_text,chains
	]

func refresh() -> void:
	if not is_node_ready():
		return
	title_label.text=LocalizationManager.source("dynasty.title")
	close_button.text=LocalizationManager.source("ui.back")
	balance_label.text=LocalizationManager.source("dynasty.balance") % [
		GameManager.generation,GameManager.legacy_points,
		GameManager.ascension_level,GameManager.momentum
	]
	for section:String in SECTIONS:
		var tab:Button=tabs[section]
		tab.text=LocalizationManager.source("dynasty.section."+section)
		tab.set_pressed_no_signal(section==active_section)
	clear_content()
	match active_section:
		"journal": build_journal()
		"legacy": build_legacy()
		"threads": build_threads()
		"hall": build_hall()
		"ascension": build_ascension()

func build_journal() -> void:
	add_line(hall_stats(),15,Palette.text())
	if GameManager.milestone_log.is_empty():
		add_line(LocalizationManager.source("dynasty.journal.empty"))
	for value:Variant in GameManager.milestone_log:
		if not value is Dictionary:
			continue
		var entry:Dictionary=value
		var stage:String=str(entry.get("stage","survival"))
		var milestone_age:int=entry.get("age",0)
		var milestone_cents:int=entry.get("wealth_cents",0)
		var milestone_rank:int=entry.get("rank",0)
		add_line(LocalizationManager.source("dynasty.journal.milestone") % [
			GameManager.format_age(milestone_age),
			GameManager.format_num(Money.dollars(milestone_cents)),
			GameManager.format_rank(milestone_rank),
			LocalizationManager.source("milestone.stage."+stage)
		])
	for value:Variant in GameManager.chain_records:
		if not value is Dictionary:
			continue
		var record:Dictionary=value
		var completed:bool=record.get("completed",false)
		var status_key:String="dynasty.threads.done" if completed else "dynasty.threads.active.short"
		add_line(LocalizationManager.source("dynasty.journal.chain") % [
			str(record.get("label","")),LocalizationManager.source(status_key)
		])

func unlock_perk(id: String) -> void:
	if GameManager.unlock_legacy_perk(id):
		# The director owns the voice; action feedback serial records the acknowledgment.
		@warning_ignore("return_value_discarded")
		SoundManager.play_sfx("purchase")
	else:
		# The director owns the voice; action feedback serial records the acknowledgment.
		@warning_ignore("return_value_discarded")
		SoundManager.play_sfx("ui_error")
	refresh()

func build_legacy() -> void:
	add_line(LocalizationManager.source("dynasty.legacy.balance") % GameManager.legacy_points,15,Palette.text())
	add_line(LocalizationManager.source("dynasty.legacy.hint"))
	for perk:Dictionary in GameManager.LEGACY_PERKS:
		var id:String=str(perk.get("id",""))
		var cost:int=perk.get("cost",0)
		var name_key:String=str(perk.get("name_key",""))
		var desc_key:String=str(perk.get("desc_key",""))
		var column:VBoxContainer=add_panel()
		var header:HBoxContainer=HBoxContainer.new()
		header.add_theme_constant_override("separation",8)
		column.add_child(header)
		var name_label:Label=Label.new()
		name_label.text=LocalizationManager.source(name_key)
		name_label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		name_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		name_label.add_theme_font_override("font",SkinTheme.display_font(600))
		name_label.add_theme_font_size_override("font_size",13)
		header.add_child(name_label)
		var action:Button=Button.new()
		action.custom_minimum_size.y=40
		action.add_theme_font_size_override("font_size",13)
		header.add_child(action)
		var desc_label:Label=Label.new()
		desc_label.text=LocalizationManager.source(desc_key)
		desc_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		desc_label.add_theme_font_size_override("font_size",12)
		desc_label.add_theme_color_override("font_color",Palette.muted())
		column.add_child(desc_label)
		if GameManager.legacy_perk_owned(id):
			action.text=LocalizationManager.source("dynasty.legacy.owned")
			action.disabled=true
			action.tooltip_text=LocalizationManager.source("dynasty.legacy.hint")
		else:
			action.text=LocalizationManager.source("dynasty.legacy.buy") % cost
			var affordable:bool=GameManager.legacy_points>=cost
			action.disabled=not affordable
			action.tooltip_text=LocalizationManager.source(desc_key) if affordable else LocalizationManager.source("dynasty.legacy.need") % cost
			if affordable:
				# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
				@warning_ignore("return_value_discarded")
				action.pressed.connect(unlock_perk.bind(id))

func request_thread(id: String) -> void:
	thread_requested.emit(id)

func build_threads() -> void:
	add_line(LocalizationManager.source("dynasty.threads.hint"))
	var ids:Array[String]=ChainLibrary.ids_for(GameManager.stage_id())
	if ids.is_empty():
		add_line(LocalizationManager.source("dynasty.threads.empty"))
	for id:String in ids:
		var entry:Dictionary=ChainLibrary.definition(id)
		if entry.is_empty():
			continue
		var column:VBoxContainer=add_panel()
		var name_label:Label=Label.new()
		name_label.text=LocalizationManager.source("chain."+id+".codex")
		name_label.add_theme_font_override("font",SkinTheme.display_font(600))
		name_label.add_theme_font_size_override("font_size",13)
		name_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		column.add_child(name_label)
		var title_label_local:Label=Label.new()
		title_label_local.text=LocalizationManager.source("chain."+id+".start.title")
		title_label_local.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		title_label_local.add_theme_font_size_override("font_size",13)
		title_label_local.add_theme_color_override("font_color",Palette.muted())
		column.add_child(title_label_local)
		var record:Dictionary=GameManager.chain_record_for(id)
		var completed:bool=record.get("completed",false)
		if record.is_empty():
			add_action(column,LocalizationManager.source("dynasty.threads.start"),true,LocalizationManager.source("chain."+id+".start.title"),request_thread.bind(id))
		elif completed:
			var done_label:Label=Label.new()
			done_label.text=LocalizationManager.source("dynasty.threads.done")
			done_label.add_theme_font_size_override("font_size",13)
			done_label.add_theme_color_override("font_color",Palette.green())
			column.add_child(done_label)
		else:
			var left:int=GameManager.chain_quarters_left(id)
			var state_label:Label=Label.new()
			state_label.text=LocalizationManager.source("dynasty.threads.active") % left if left>0 else LocalizationManager.source("dynasty.threads.due")
			state_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
			state_label.add_theme_font_size_override("font_size",13)
			state_label.add_theme_color_override("font_color",Palette.accent())
			column.add_child(state_label)

func add_record_line(column:VBoxContainer, text:String, color:Color) -> void:
	var label:Label=Label.new()
	label.text=text
	label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",13)
	label.add_theme_color_override("font_color",color)
	column.add_child(label)

func build_hall() -> void:
	add_line(hall_stats(),15,Palette.text())
	if GameManager.dynasty_records.is_empty():
		add_line(LocalizationManager.source("dynasty.empty.hall"))
		return
	var records:Array=GameManager.dynasty_records
	for index:int in range(records.size()-1,-1,-1):
		var value:Variant=records[index]
		if not value is Dictionary:
			continue
		var record:Dictionary=value
		var victory:bool=record.get("victory",false)
		var generation:int=record.get("generation",0)
		var wealth_cents:int=record.get("wealth_cents",0)
		var rank_value:int=record.get("rank",0)
		var age_value:int=record.get("age",0)
		var status_key:String="dynasty.record.victory" if victory else "dynasty.record.defeat"
		var column:VBoxContainer=add_panel()
		add_record_line(column,LocalizationManager.source("dynasty.record") % [
			generation,
			LocalizationManager.source(status_key),
			GameManager.format_num(Money.dollars(wealth_cents)),
			GameManager.format_rank(rank_value),
			GameManager.format_age(age_value)
		],Palette.accent() if victory else Palette.text())
		var ascension:int=record.get("ascension",0)
		if ascension>0:
			add_record_line(column,LocalizationManager.source("dynasty.record.ascension.line") % ascension,Palette.muted())
		var chains:int=record.get("chains",0)
		var milestones:int=record.get("milestones",0)
		add_record_line(column,LocalizationManager.source("dynasty.record.detail") % [chains,milestones],Palette.muted())

func build_ascension() -> void:
	add_line(LocalizationManager.source("dynasty.ascension.level") % GameManager.ascension_level,16,Palette.text())
	add_line(LocalizationManager.source("dynasty.ascension.hint"))
	add_line(LocalizationManager.source("dynasty.ascension.momentum") % GameManager.momentum)
	if GameManager.ascension_level>=GameManager.MAX_ASCENSION:
		add_line(LocalizationManager.source("dynasty.ascension.max"),15,Palette.accent())
	else:
		var next_level:int=GameManager.ascension_level+1
		add_line(LocalizationManager.source("dynasty.ascension.next") % [next_level,2+next_level],15,Palette.accent())
	add_line(LocalizationManager.source("dynasty.ascension.open"))
