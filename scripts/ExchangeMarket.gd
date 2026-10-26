extends RefCounted
## Fictional USD ratios; cash uses cents, foreign holdings use exact thousandths.
const Money=preload("res://scripts/security/Money.gd")
const SPREAD:=0.0035
const MAX_MILLI:int=9000000000000000
const INITIAL:={"EUR":1.08,"GBP":1.26,"JPY":0.0067}
const FOREIGN_QUARTERLY_INFLATION:={"EUR":0.0055,"GBP":0.0075,"JPY":0.003}
var rates:Dictionary={}
var holding_milli:Dictionary={}
var holdings:Dictionary:
    get:
        var view:Dictionary={}
        for code in INITIAL:view[code]=float(holding_milli.get(code,0))/1000.0
        return view
var history:Dictionary={}
var rng:=RandomNumberGenerator.new()
func _init() -> void:reset()
func reset() -> void:
    rates=INITIAL.duplicate()
    holding_milli={"EUR":0,"GBP":0,"JPY":0}
    history={"EUR":[rates.EUR],"GBP":[rates.GBP],"JPY":[rates.JPY]}
    rng.randomize()
func value_cents() -> int:
    var total:int=0
    for code in INITIAL:
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
    for code in INITIAL:
        var drift:float=(domestic_inflation-FOREIGN_QUARTERLY_INFLATION[code])*quarters
        var change:float=rng.randf_range(-0.055,0.055)*sqrt(quarters)+drift
        rates[code]=clampf(rates[code]*(1.0+change),INITIAL[code]*0.25,INITIAL[code]*4.0)
        history[code].append(rates[code])
        if history[code].size()>24:history[code].pop_front()
func capture() -> Dictionary:
    return {"rates":rates.duplicate(true),"holdings":holdings,"holding_milli":holding_milli.duplicate(),"history":history.duplicate(true),"rng":rng.state}
func restore(data:Dictionary) -> void:
    reset()
    for code in INITIAL:
        var rate:float=data.get("rates",{}).get(code,INITIAL[code])
        if is_finite(rate) and rate>0:rates[code]=rate
        var units:float=data.get("holdings",{}).get(code,0.0)
        var exact:Variant=data.get("holding_milli",{}).get(code,null)
        if exact is int and exact>=0 and exact<=MAX_MILLI:holding_milli[code]=exact
        elif is_finite(units) and units>=0 and units<=float(MAX_MILLI)/1000.0:holding_milli[code]=roundi(units*1000.0)
        var points:Array=data.get("history",{}).get(code,[rates[code]])
        var valid:Array=points.filter(func(p):return (p is float or p is int) and is_finite(float(p)) and p>0)
        history[code]=valid.slice(maxi(0,valid.size()-24)) if not valid.is_empty() else [rates[code]]
    if data.has("rng"):rng.state=int(data.rng)
