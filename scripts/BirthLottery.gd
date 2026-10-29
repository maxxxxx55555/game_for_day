extends RefCounted
## Weighted birth lottery over 192 real countries.
##
## A country fixes the starting position - capital, health, schooling, living
## costs and an early income handicap or head start - and then lets go. Every
## country term fades toward neutral as the player ages, so a poor start costs
## time and comfort but never locks the run: by the late game the outcome is
## whatever the player built.

const Data = preload("res://scripts/BirthCountries.gd")

## Income and cost terms converge over this many in-game years, starting at 18.
const CONVERGENCE_YEARS:float = 34.0
## How much of the country cost term survives full convergence (1.0 = none).
const RESIDUAL_COST_SHARE:float = 0.45

const CASH_SCALE:float = 70.0
const CASH_EXPONENT:float = 1.15
const CASH_MIN:float = 150.0
const CASH_MAX:float = 14000.0

const OPPORTUNITY_MIN:float = 0.62
const OPPORTUNITY_MAX:float = 1.55
const COST_MIN:float = 0.45
const COST_MAX:float = 3.2

const DEATH_AGE_MIN:int = 70
const DEATH_AGE_MAX:int = 88

# Country rows are untyped const arrays and roll results are dictionary values.
# Narrowing a Variant is the only unsafe step in this module, so it happens here.
@warning_ignore_start("unsafe_call_argument", "unsafe_cast")
static func row_number(row:Array, index:int) -> float:
	return float(row[index])

static func row_int(row:Array, index:int) -> int:
	return int(row[index])

static func value_number(info:Dictionary, key:String) -> float:
	return float(info[key])

static func value_int(info:Dictionary, key:String) -> int:
	return int(info[key])
@warning_ignore_restore("unsafe_call_argument", "unsafe_cast")

static func count() -> int:
	return Data.COUNTRIES.size()

static func total_births() -> int:
	return Data.TOTAL_BIRTHS

static func code_of(row:Array) -> String:
	return str(row[0])

## Resolves a uniform roll in [0,1) to one country row, weighted by births.
static func pick(position:float) -> Array:
	var rows:Array = Data.COUNTRIES
	var target:float = clampf(position, 0.0, 0.999999) * float(Data.TOTAL_BIRTHS)
	var running:float = 0.0
	for row:Array in rows:
		running += row_number(row, 2)
		if target < running:
			return row
	return rows[rows.size() - 1]

static func by_code(code:String) -> Array:
	for row:Array in Data.COUNTRIES:
		if str(row[0]) == code:
			return row
	return []

static func country_name(code:String) -> String:
	return LocalizationManager.source("country.%s.name" % code.to_lower())

## Three dominant flag colours, used to paint the country art plate.
static func flag_colors(code:String) -> Array[Color]:
	var colors:Array[Color] = []
	var row:Array = by_code(code)
	if row.is_empty():
		return [Color("6b7280"), Color("9ca3af"), Color("ffffff")]
	var parts:PackedStringArray = str(row[5]).split(",")
	for part:String in parts:
		colors.append(Color("#" + part.strip_edges()))
	while colors.size() < 3:
		colors.append(colors[colors.size() - 1])
	return colors

static func region_name(region_code:String) -> String:
	return LocalizationManager.source("region.%s" % region_code)

## Share of all births, 0..1. The reciprocal reads as "one in N newborns".
static func share(row:Array) -> float:
	return row_number(row, 2) / float(Data.TOTAL_BIRTHS)

static func starting_cash(row:Array) -> float:
	var gdp:float = maxf(1.0, row_number(row, 4))
	var scaled:float = CASH_SCALE * pow(gdp / 1000.0, CASH_EXPONENT)
	return clampf(snappedf(scaled, 1.0), CASH_MIN, CASH_MAX)

static func starting_health(row:Array) -> int:
	return clampi(roundi(46.0 + (row_number(row, 3) - 50.0) * 1.5), 55, 100)

static func starting_intellect(row:Array) -> int:
	var gdp:float = maxf(1.0, row_number(row, 4))
	var scaled:float = 10.0 + 9.5 * (log(gdp / 600.0) / log(10.0))
	return clampi(roundi(scaled), 8, 36)

static func cost_term(row:Array) -> float:
	var gdp:float = maxf(1.0, row_number(row, 4))
	return clampf(pow(gdp / 9000.0, 0.34), COST_MIN, COST_MAX)

static func opportunity_term(row:Array) -> float:
	var gdp:float = maxf(1.0, row_number(row, 4))
	return clampf(pow(gdp / 12000.0, 0.22), OPPORTUNITY_MIN, OPPORTUNITY_MAX)

static func death_age(row:Array) -> int:
	return clampi(roundi(row_number(row, 3) + 2.0), DEATH_AGE_MIN, DEATH_AGE_MAX)

## A fragile start carries more background stress than a sheltered one.
static func starting_stress(row:Array) -> int:
	return clampi(roundi(18.0 - (float(starting_health(row)) - 55.0) * 0.18), 6, 18)

## 1.0 right after birth, 0.0 once the player has outgrown the birthplace.
static func origin_weight(age:int) -> float:
	return clampf(1.0 - float(maxi(0, age - 18)) / CONVERGENCE_YEARS, 0.0, 1.0)

## Income multiplier from the birthplace. Neutral once the origin fades.
static func income_modifier(opportunity:float, age:int) -> float:
	var weight:float = origin_weight(age)
	return clampf(1.0 + (opportunity - 1.0) * weight, 0.5, 2.0)

## Living-cost multiplier. Keeps a shrinking share of the country term forever.
static func cost_modifier(cost:float, age:int) -> float:
	var weight:float = origin_weight(age)
	var retention:float = RESIDUAL_COST_SHARE + (1.0 - RESIDUAL_COST_SHARE) * weight
	return clampf(1.0 + (cost - 1.0) * retention, 0.4, 3.5)

## Full roll result: one country plus every derived starting term.
static func roll(roll_value:float) -> Dictionary:
	var row:Array = pick(roll_value)
	var opportunity:float = opportunity_term(row)
	var code:String = code_of(row)
	return {
		"code": code,
		"name": country_name(code),
		"region": region_name(str(row[1])),
		"births": row_int(row, 2),
		"share": share(row),
		"life": row_number(row, 3),
		"gdp": row_int(row, 4),
		"cash": starting_cash(row),
		"health": starting_health(row),
		"intellect": starting_intellect(row),
		"stress": starting_stress(row),
		"cost": cost_term(row),
		"opportunity": opportunity,
		"death_age": death_age(row),
		"income_modifier": income_modifier(opportunity, 18),
		"cost_modifier": cost_modifier(cost_term(row), 18)
	}
