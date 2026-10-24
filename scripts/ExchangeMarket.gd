extends RefCounted
## Fictional USD quotes; isolated RNG keeps navigation/audio out of economics.

const SPREAD := 0.0035
const INITIAL := {"EUR": 1.08, "GBP": 1.26, "JPY": 0.0067}
const FOREIGN_QUARTERLY_INFLATION := {"EUR": 0.0055, "GBP": 0.0075, "JPY": 0.003}
var rates: Dictionary = {}
var holdings: Dictionary = {}
var history: Dictionary = {}
var rng := RandomNumberGenerator.new()

func _init() -> void: reset()

func reset() -> void:
	rates = INITIAL.duplicate()
	holdings = {"EUR": 0.0, "GBP": 0.0, "JPY": 0.0}
	history = {"EUR": [rates.EUR], "GBP": [rates.GBP], "JPY": [rates.JPY]}
	rng.randomize()

func value() -> float:
	var total := 0.0
	for code in INITIAL: total += holdings[code] * rates[code]
	return total

func buy(code: String, dollars: float) -> bool:
	if not rates.has(code) or not is_finite(dollars) or dollars <= 0: return false
	holdings[code] += dollars / (rates[code] * (1.0 + SPREAD))
	return true

func sell(code: String, units: float) -> float:
	if not rates.has(code) or not is_finite(units) or units <= 0 or units > holdings[code]: return 0
	var dollars: float = units * rates[code] * (1.0 - SPREAD)
	holdings[code] = maxf(0, holdings[code] - units)
	return dollars

func advance(quarters: float, domestic_inflation: float) -> void:
	for code in INITIAL:
		var drift: float = (domestic_inflation - FOREIGN_QUARTERLY_INFLATION[code]) * quarters
		var change := rng.randf_range(-0.055, 0.055) * sqrt(quarters) + drift
		rates[code] = clampf(rates[code] * (1.0 + change), INITIAL[code] * 0.25, INITIAL[code] * 4.0)
		history[code].append(rates[code])
		if history[code].size() > 24: history[code].pop_front()

func capture() -> Dictionary:
	return {"rates": rates.duplicate(true), "holdings": holdings.duplicate(true), "history": history.duplicate(true), "rng": rng.state}

func restore(data: Dictionary) -> void:
	reset()
	for code in INITIAL:
		var rate: float = data.get("rates", {}).get(code, INITIAL[code])
		var units: float = data.get("holdings", {}).get(code, 0.0)
		if is_finite(rate) and rate > 0: rates[code] = rate
		if is_finite(units) and units >= 0: holdings[code] = units
		var points: Array = data.get("history", {}).get(code, [rates[code]])
		var valid: Array = points.filter(func(p): return (p is float or p is int) and is_finite(float(p)) and p > 0)
		history[code] = valid.slice(maxi(0, valid.size() - 24)) if not valid.is_empty() else [rates[code]]
	if data.has("rng"): rng.state = int(data.rng)
