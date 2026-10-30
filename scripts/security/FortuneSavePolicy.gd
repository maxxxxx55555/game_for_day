extends RefCounted
const Guard = preload("res://scripts/security/SaveGuard.gd")
const Money=preload("res://scripts/security/Money.gd")
const BirthData=preload("res://scripts/BirthCountries.gd")
const RANGES:Dictionary[String,Array]= {
	"age":[18,130],"quarter":[1,4],"total_turns":[0,10000],"real_world_week":[1,100000],
	"business_tier":[0,5],"business_scale":[1,16384],"health":[0,100],"intellect":[1,1000000],
	"stress":[0,100],"happiness":[0,100],"energy":[0,100]
}
const LEGACY_PERK_IDS:Array[String]=["warm_start","business_savvy","market_instinct","calm_blood","healthy_habits","networker","fast_learner","safety_net"]
const AMBITIONS:Array[String]=["steady","meteor","heir"]
const STAGES:Array[String]=["survival","career","millionaire","billionaire"]
const CHAIN_IDS:Array[String]=["library_workshop","night_courier","hackathon_team","mentor_coffee","family_loan","city_tender","media_profile","quiet_estate"]
const MILESTONE_AGES:Array[int]=[18,25,35,50,65]
static func dynasty(cfg: ConfigFile) -> bool:
	if not Guard.numeric(cfg.get_value("dynasty","generation",1),1,1000000,true): return false
	if not Guard.numeric(cfg.get_value("dynasty","legacy_points",0),0,10000000,true): return false
	if not Guard.numeric(cfg.get_value("dynasty","inherited_capital",0),0,Money.dollars(Money.MAX_CENTS)): return false
	if cfg.get_value("settings","time_speed",1.0) not in [0.5,1.0,2.0]: return false
	if not cfg.get_value("settings","audio_enabled",true) is bool: return false
	if not cfg.get_value("settings","reduced_motion",false) is bool: return false
	for name:String in ["master_volume","music_volume","sfx_volume","ui_volume"]:
		if not Guard.numeric(cfg.get_value("settings",name,0.3),0,1): return false
	if cfg.has_section_key("dynasty","inherited_capital_cents") and not cents_pair(cfg,"dynasty","inherited_capital","inherited_capital_cents",false):return false
	# Fields introduced by 2.1.0 are optional so 1.4.0 and 2.0.x profiles stay valid.
	if cfg.has_section_key("dynasty","unlocked_perks") and not perk_list(cfg.get_value("dynasty","unlocked_perks",[])):return false
	if cfg.has_section_key("dynasty","records") and not dynasty_records(cfg.get_value("dynasty","records",[])):return false
	if cfg.has_section_key("dynasty","ascension_level") and not Guard.numeric(cfg.get_value("dynasty","ascension_level",0),0,5,true):return false
	if cfg.has_section_key("dynasty","lives_completed") and not Guard.numeric(cfg.get_value("dynasty","lives_completed",0),0,1000000,true):return false
	if cfg.has_section_key("dynasty","lifetime_best_cents"):
		var best:Variant=cfg.get_value("dynasty","lifetime_best_cents",0)
		if not best is int:return false
		var best_cents:int=best
		if not Money.valid(best_cents):return false
	if cfg.has_section_key("dynasty","total_legacy_earned") and not Guard.numeric(cfg.get_value("dynasty","total_legacy_earned",0),0,10000000000,true):return false
	return cfg.has_section("dynasty")

static func session(cfg: ConfigFile) -> bool:
	if not Guard.numeric(cfg.get_value("session","generation",0),1,1000000,true): return false
	var ui_value:Variant=cfg.get_value("session","ui",null)
	if not ui_value is Dictionary or not Guard.pure(ui_value,0,[0]):return false
	var ui:Dictionary=ui_value
	if not Guard.numeric(ui.get("mode",-1),0,9,true):return false
	if not ui.get("final_victory",false) is bool: return false
	# RNG state is a signed 64-bit integer, not a floating point game statistic.
	if ui.has("rng_state") and not ui.rng_state is int: return false
	if ui.has("event_net_worth") and not Guard.numeric(ui.event_net_worth,-1.0e12,1.0e20): return false
	for name:String in ["event_title","last_event_title","final_reason","event_text"]:
		if ui.has(name) and not ui[name] is String: return false
	for field:String in RANGES:
		var limits:Array[int]=Array(RANGES[field],TYPE_INT,"",null)
		if not Guard.numeric(cfg.get_value("run",field,null),limits[0],limits[1],true):return false
	for field:String in ["cash","stock_units","crypto_units","inherited_capital"]:
		if not Guard.numeric(cfg.get_value("run",field,null),-Money.dollars(Money.MAX_CENTS) if field=="cash" else 0.0,Money.dollars(Money.MAX_CENTS) if field in ["cash","inherited_capital"] else 1.0e12): return false
	for field:String in ["stock_index","crypto_rate","inflation_multiplier","difficulty_multiplier","birth_cost_modifier"]:
		if not Guard.numeric(cfg.get_value("run",field,null),0.00001,1.0e12): return false
	if cfg.get_value("run","time_speed",0) not in [0.5,1.0,2.0]: return false
	if not Guard.numeric(cfg.get_value("run","quarter_progress_accum",-1),0,0.9999999): return false
	if not Guard.numeric(cfg.get_value("run","ad_cooldown",-1),0,100): return false
	for field:String in ["has_rolled_birth","revive_used","audio_enabled"]:
		if not cfg.get_value("run",field,null) is bool: return false
	if not cfg.get_value("run","birth_origin",null) is String: return false
	var birth_fields:int=0
	for field:String in ["birth_country_code","birth_opportunity","death_age"]:
		if cfg.has_section_key("run",field):birth_fields+=1
	# Older saves omit all three fields. A partial new schema is corruption.
	if birth_fields not in [0,3]:return false
	if birth_fields==3:
		var country_value:Variant=cfg.get_value("run","birth_country_code",null)
		if not country_value is String:return false
		var country:String=country_value
		if not country.is_empty() and not known_country(country):return false
		if not Guard.numeric(cfg.get_value("run","birth_opportunity",null),0.62,1.55):return false
		if not Guard.numeric(cfg.get_value("run","death_age",null),70,88,true):return false
	if cfg.get_value("run","player_perk","") not in ["none","tech_genius","iron_health","workaholic","wall_street","biohacker","crisis_mgr"]: return false
	var fx_value:Variant=cfg.get_value("run","fx_state",{})
	if not fx_value is Dictionary or not Guard.pure(fx_value,0,[0]):return false
	var fx:Dictionary=fx_value
	if not fx.is_empty():
		if fx.has("rng") and not fx.rng is int: return false
		for name:String in ["rates","holdings","history"]:
			if not fx.get(name) is Dictionary: return false
		var saved_rates:Dictionary=fx.rates
		var saved_holdings:Dictionary=fx.holdings
		var saved_history:Dictionary=fx.history
		for code:String in ["EUR","GBP","JPY"]:
			if not Guard.numeric(saved_rates.get(code),0.000001,1000000):return false
			if not Guard.numeric(saved_holdings.get(code),0,1.0e20):return false
			var points_value:Variant=saved_history.get(code)
			if not points_value is Array:return false
			var points:Array=points_value
			if points.is_empty() or points.size()>24:return false
			for point:Variant in points:
				if not Guard.numeric(point,0.000001,1000000): return false
	if cfg.has_section_key("run","cash_cents"):
		for pair:Array in [["cash","cash_cents"],["inherited_capital","inherited_capital_cents"],["stock_index","stock_price_cents"],["crypto_rate","crypto_price_cents"]]:
			var field_name:String=pair[0]
			var cents_field:String=pair[1]
			if not cents_pair(cfg,"run",field_name,cents_field,field_name=="cash"):return false
		for field:String in ["simulation_ticks","grant_ready_tick","last_grant_tick"]:
			var counter:Variant=cfg.get_value("run",field,null)
			if not counter is int or counter<(-1 if field=="last_grant_tick" else 0) or counter>1000000:return false
		var tick:int=cfg.get_value("run","simulation_ticks",0)
		var ready:int=cfg.get_value("run","grant_ready_tick",0)
		if cfg.get_value("run","last_grant_tick",-1)>tick or ready>tick+200:return false
		var cooldown:float=cfg.get_value("run","ad_cooldown",0)
		if absf(float(maxi(0,ready-tick))/2.0-cooldown)>0.00001:return false
	if fx.has("holding_milli"):
		if not fx.holding_milli is Dictionary:return false
		var exact_holdings:Dictionary=fx.holding_milli
		var displayed_holdings:Dictionary=fx.holdings
		for code:String in ["EUR","GBP","JPY"]:
			var exact:Variant=exact_holdings.get(code,null)
			if not exact is int or exact<0 or exact>9000000000000000:return false
			var milli:int=exact
			var displayed:float=displayed_holdings[code]
			if float(milli)/1000.0!=displayed:return false
	if cfg.has_section_key("run","ambition"):
		var ambition:Variant=cfg.get_value("run","ambition","steady")
		if not ambition is String or not AMBITIONS.has(ambition):return false
	if cfg.has_section_key("run","run_ascension") and not Guard.numeric(cfg.get_value("run","run_ascension",0),0,5,true):return false
	if cfg.has_section_key("run","momentum") and not Guard.numeric(cfg.get_value("run","momentum",0),0,10000,true):return false
	if cfg.has_section_key("run","dynasty_committed") and not cfg.get_value("run","dynasty_committed",false) is bool:return false
	if cfg.has_section_key("run","chain_records") and not chain_records(cfg.get_value("run","chain_records",[])):return false
	if cfg.has_section_key("run","milestone_log") and not milestone_entries(cfg.get_value("run","milestone_log",[])):return false
	if cfg.has_section_key("run","market_history") and not market_points(cfg.get_value("run","market_history",[])):return false
	return true

static func perk_list(value:Variant)->bool:
	if not value is Array:return false
	var perks:Array=value
	if perks.size()>LEGACY_PERK_IDS.size():return false
	var seen:Dictionary={}
	for perk:Variant in perks:
		if not perk is String or not LEGACY_PERK_IDS.has(perk) or seen.has(perk):return false
		seen[perk]=true
	return true

static func dynasty_records(value:Variant)->bool:
	if not value is Array:return false
	var records:Array=value
	if records.size()>12:return false
	for record:Variant in records:
		if not record is Dictionary:return false
		var entry:Dictionary=record
		if not Guard.numeric(entry.get("generation",0),1,1000000,true):return false
		if not Guard.numeric(entry.get("age",0),18,130,true):return false
		var wealth:Variant=entry.get("wealth_cents",null)
		if not wealth is int:return false
		var wealth_cents:int=wealth
		if not Money.valid(wealth_cents):return false
		if not Guard.numeric(entry.get("rank",0),1,8000000000,true):return false
		if not entry.get("victory",false) is bool:return false
		var ambition:Variant=entry.get("ambition","")
		if not ambition is String or not AMBITIONS.has(ambition):return false
		if not Guard.numeric(entry.get("ascension",0),0,5,true):return false
		if not Guard.numeric(entry.get("chains",0),0,8,true):return false
		if not Guard.numeric(entry.get("milestones",0),0,5,true):return false
	return true

static func chain_records(value:Variant)->bool:
	if not value is Array:return false
	var records:Array=value
	if records.size()>CHAIN_IDS.size():return false
	var seen:Dictionary={}
	for record:Variant in records:
		if not record is Dictionary:return false
		var entry:Dictionary=record
		var id:Variant=entry.get("id","")
		if not id is String or not CHAIN_IDS.has(id) or seen.has(id):return false
		seen[id]=true
		var stage:Variant=entry.get("stage","")
		if not stage is String or not STAGES.has(stage):return false
		for name:String in ["flag","label"]:
			var text:Variant=entry.get(name,"")
			if not text is String:return false
			var text_value:String=text
			if text_value.length()>256:return false
		if not Guard.numeric(entry.get("due_tick",-1),0,1000000,true):return false
		if not entry.get("completed",false) is bool:return false
		var outcome:Variant=entry.get("outcome","")
		if not outcome is String:return false
		var outcome_text:String=outcome
		if outcome_text.length()>64:return false
	return true

static func milestone_entries(value:Variant)->bool:
	if not value is Array:return false
	var entries:Array=value
	if entries.size()>MILESTONE_AGES.size():return false
	var seen:Dictionary={}
	for entry:Variant in entries:
		if not entry is Dictionary:return false
		var row:Dictionary=entry
		var age:Variant=row.get("age",0)
		if not age is int or not MILESTONE_AGES.has(age) or seen.has(age):return false
		seen[age]=true
		var wealth:Variant=row.get("wealth_cents",null)
		if not wealth is int:return false
		var wealth_cents:int=wealth
		if not Money.valid(wealth_cents):return false
		if not Guard.numeric(row.get("rank",0),1,8000000000,true):return false
		var stage:Variant=row.get("stage","")
		if not stage is String or not STAGES.has(stage):return false
		if not Guard.numeric(row.get("chains",0),0,8,true):return false
		if not row.get("seen",false) is bool:return false
	return true

static func market_points(value:Variant)->bool:
	if not value is Array:return false
	var points:Array=value
	if points.size()>24:return false
	for point:Variant in points:
		if not Guard.numeric(point,0.000001,1.0e12):return false
	return true

static func known_country(code:String)->bool:
	for row:Array in BirthData.COUNTRIES:
		if str(row[0])==code:return true
	return false

static func cents_pair(cfg:ConfigFile,section:String,dollars_key:String,cents_key:String,signed:bool) -> bool:
	var exact:Variant=cfg.get_value(section,cents_key,null)
	if not exact is int:return false
	var cents:int=exact
	if not Money.valid(cents) or not signed and cents<0:return false
	var dollars:float=cfg.get_value(section,dollars_key,0)
	return Money.from_dollars(dollars)==cents
