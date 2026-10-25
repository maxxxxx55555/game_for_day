extends RefCounted
const Guard = preload("res://scripts/security/SaveGuard.gd")
const RANGES := {
	"age":[18,130],"quarter":[1,4],"total_turns":[0,10000],"real_world_week":[1,100000],
	"business_tier":[0,5],"business_scale":[1,10000000],"health":[0,100],"intellect":[1,1000000],
	"stress":[0,100],"happiness":[0,100],"energy":[0,100]
}
static func dynasty(cfg: ConfigFile) -> bool:
	if not Guard.numeric(cfg.get_value("dynasty","generation",1),1,1000000,true): return false
	if not Guard.numeric(cfg.get_value("dynasty","legacy_points",0),0,10000000,true): return false
	if not Guard.numeric(cfg.get_value("dynasty","inherited_capital",0),0,1.0e17): return false
	if cfg.get_value("settings","time_speed",1.0) not in [0.5,1.0,2.0]: return false
	if not cfg.get_value("settings","audio_enabled",true) is bool: return false
	for name in ["master_volume","music_volume","sfx_volume","ui_volume"]:
		if not Guard.numeric(cfg.get_value("settings",name,0.3),0,1): return false
	return cfg.has_section("dynasty")

static func session(cfg: ConfigFile) -> bool:
	if not Guard.numeric(cfg.get_value("session","generation",0),1,1000000,true): return false
	var ui: Variant = cfg.get_value("session","ui",null)
	if not ui is Dictionary or not Guard.pure(ui,0,[0]) or not Guard.numeric(ui.get("mode",-1),0,8,true): return false
	if not ui.get("final_victory",false) is bool: return false
	# RNG state is a signed 64-bit integer, not a floating point game statistic.
	if ui.has("rng_state") and not ui.rng_state is int: return false
	if ui.has("event_net_worth") and not Guard.numeric(ui.event_net_worth,-1.0e12,1.0e20): return false
	for name in ["event_title","last_event_title","final_reason","event_text"]:
		if ui.has(name) and not ui[name] is String: return false
	for field in RANGES:
		if not Guard.numeric(cfg.get_value("run",field,null),RANGES[field][0],RANGES[field][1],true): return false
	for field in ["cash","stock_units","crypto_units","inherited_capital"]:
		if not Guard.numeric(cfg.get_value("run",field,null),-1.0e12 if field=="cash" else 0,1.0e17): return false
	for field in ["stock_index","crypto_rate","inflation_multiplier","difficulty_multiplier","birth_cost_modifier"]:
		if not Guard.numeric(cfg.get_value("run",field,null),0.00001,1.0e12): return false
	if cfg.get_value("run","time_speed",0) not in [0.5,1.0,2.0]: return false
	if not Guard.numeric(cfg.get_value("run","quarter_progress_accum",-1),0,0.9999999): return false
	if not Guard.numeric(cfg.get_value("run","ad_cooldown",-1),0,100): return false
	for field in ["has_rolled_birth","revive_used","audio_enabled"]:
		if not cfg.get_value("run",field,null) is bool: return false
	if not cfg.get_value("run","birth_origin",null) is String: return false
	if cfg.get_value("run","player_perk","") not in ["none","tech_genius","iron_health","workaholic","wall_street","biohacker","crisis_mgr"]: return false
	var fx: Variant = cfg.get_value("run","fx_state",{})
	if not fx is Dictionary or not Guard.pure(fx,0,[0]): return false
	if not fx.is_empty():
		if fx.has("rng") and not fx.rng is int: return false
		for name in ["rates","holdings","history"]:
			if not fx.get(name) is Dictionary: return false
		for code in ["EUR","GBP","JPY"]:
			if not Guard.numeric(fx.rates.get(code),0.000001,1000000): return false
			if not Guard.numeric(fx.holdings.get(code),0,1.0e20): return false
			var points: Variant = fx.history.get(code)
			if not points is Array or points.is_empty() or points.size()>24: return false
			for point in points:
				if not Guard.numeric(point,0.000001,1000000): return false
	return true
