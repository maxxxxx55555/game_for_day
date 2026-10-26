extends RefCounted
## Fictional USD ratios; cash uses cents, foreign holdings use exact thousandths.
const Money=preload("res://scripts/security/Money.gd")
const SPREAD:float=0.0035
const MAX_MILLI:int=9000000000000000
const INITIAL:Dictionary[String,float]={"EUR":1.08,"GBP":1.26,"JPY":0.0067}
const FOREIGN_QUARTERLY_INFLATION:Dictionary[String,float]={"EUR":0.0055,"GBP":0.0075,"JPY":0.003}
var rates:Dictionary[String,float]={}
var holding_milli:Dictionary[String,int]={}
var holdings:Dictionary[String,float]:
    get:
        var view:Dictionary[String,float]={}
        for code:String in INITIAL:
            var exact:int=holding_milli.get(code,0)
            view[code]=float(exact)/1000.0
        return view
var history:Dictionary={}
var rng:RandomNumberGenerator=RandomNumberGenerator.new()
func _init() -> void:reset()
func reset() -> void:
    rates.assign(INITIAL)
    holding_milli={"EUR":0,"GBP":0,"JPY":0}
    history={"EUR":[rates.EUR],"GBP":[rates.GBP],"JPY":[rates.JPY]}
    rng.randomize()
func value_cents() -> int:
    var total:int=0
    for code:String in INITIAL:
        var quoted:float=float(holding_milli[code])*rates[code]/10.0
        if not is_finite(quoted) or quoted>float(Money.MAX_CENTS):return Money.MAX_CENTS
        total=Money.add(total,floori(quoted))
        if total==Money.INVALID:return Money.MAX_CENTS
    return total
func value() -> float:return Money.dollars(value_cents())
func acquired_milli(code:String,cents:int) -> int:
    if not INITIAL.has(code) or cents<=0 or not Money.valid(cents):return 0
    var rate:float=rates.get(code,0.0)
    if not is_finite(rate) or rate<=0:return 0
    var acquired:float=float(cents)*10.0/(rate*(1.0+SPREAD))
    if not is_finite(acquired) or acquired<1 or acquired>float(MAX_MILLI):return 0
    var quantity:int=floori(acquired)
    if int(holding_milli[code])>MAX_MILLI-quantity:return 0
    return quantity
func buy_cents(code:String,cents:int) -> bool:
    var quantity:int=acquired_milli(code,cents)
    if quantity<=0:return false
    holding_milli[code]+=quantity
    return true
func buy(code:String,dollars:float) -> bool:return buy_cents(code,Money.from_dollars(dollars))
func sold_milli(code:String,units:float) -> int:
    if not INITIAL.has(code) or not is_finite(units) or units<=0:return 0
    var owned:int=holding_milli[code]
    var view:float=float(owned)/1000.0
    if units>view:return 0
    if units==view:return owned
    var quantity:int=floori(units*1000.0)
    return quantity if quantity>0 and quantity<=owned else 0
func quote_sell_cents(code:String,units:float) -> int:
    var quantity:int=sold_milli(code,units)
    if quantity<=0:return 0
    var rate:float=rates.get(code,0.0)
    var quoted:float=float(quantity)*rate*(1.0-SPREAD)/10.0
    if not is_finite(quoted) or quoted<1 or quoted>float(Money.MAX_CENTS):return 0
    return floori(quoted)
func sell_cents(code:String,units:float) -> int:
    var received:int=quote_sell_cents(code,units)
    if received<=0:return 0
    holding_milli[code]-=sold_milli(code,units)
    return received
func sell(code:String,units:float) -> float:return Money.dollars(sell_cents(code,units))
func advance(quarters:float,domestic_inflation:float) -> void:
    if not is_finite(quarters) or quarters<=0 or quarters>2 or not is_finite(domestic_inflation):return
    for code:String in INITIAL:
        var drift:float=(domestic_inflation-FOREIGN_QUARTERLY_INFLATION[code])*quarters
        var change:float=rng.randf_range(-0.055,0.055)*sqrt(quarters)+drift
        rates[code]=clampf(rates[code]*(1.0+change),INITIAL[code]*0.25,INITIAL[code]*4.0)
        var quotes:Array=history[code]
        quotes.append(rates[code])
        if quotes.size()>24:quotes.remove_at(0)
func capture() -> Dictionary:
    return {"rates":rates.duplicate(true),"holdings":holdings,"holding_milli":holding_milli.duplicate(),"history":history.duplicate(true),"rng":rng.state}
func restore(data:Dictionary) -> void:
    reset()
    var saved_rates:Dictionary=data.get("rates",{})
    var saved_holdings:Dictionary=data.get("holdings",{})
    var saved_exact:Dictionary=data.get("holding_milli",{})
    var saved_history:Dictionary=data.get("history",{})
    for code:String in INITIAL:
        var rate:float=saved_rates.get(code,INITIAL[code])
        if is_finite(rate) and rate>0:rates[code]=rate
        var units:float=saved_holdings.get(code,0.0)
        var exact:Variant=saved_exact.get(code,null)
        if exact is int and exact>=0 and exact<=MAX_MILLI:holding_milli[code]=exact
        elif is_finite(units) and units>=0 and units<=float(MAX_MILLI)/1000.0:holding_milli[code]=roundi(units*1000.0)
        var points:Array=saved_history.get(code,[rates[code]])
        var valid:Array=points.filter(valid_quote)
        history[code]=valid.slice(maxi(0,valid.size()-24)) if not valid.is_empty() else [rates[code]]
    if data.has("rng"):rng.state=data.rng

static func valid_quote(sample:Variant)->bool:
    if not (sample is float or sample is int):return false
    var quoted:float=sample
    return is_finite(quoted) and quoted>0
