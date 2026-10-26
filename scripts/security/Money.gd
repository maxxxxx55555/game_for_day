extends RefCounted
## All ledger balances are signed int64 cents, bounded below 2^53 for exact UI conversion.
const MAX_CENTS:int=900000000000000
const INVALID:int=-9223372036854775807
static func valid(cents:int) -> bool:return cents>=-MAX_CENTS and cents<=MAX_CENTS
static func from_dollars(dollars:float) -> int:
    if not is_finite(dollars) or absf(dollars)>float(MAX_CENTS)/100.0:return INVALID
    return roundi(dollars*100.0)
static func dollars(cents:int) -> float:return float(cents)/100.0
static func add(a:int,b:int) -> int:
    if not valid(a) or not valid(b):return INVALID
    if b>0 and a>MAX_CENTS-b or b<0 and a< -MAX_CENTS-b:return INVALID
    return a+b
static func multiply(cents:int,count:int) -> int:
    if not valid(cents) or count<0:return INVALID
    if cents!=0 and float(count)>float(MAX_CENTS)/absf(float(cents)):return INVALID
    return cents*count
@warning_ignore("integer_division")
static func ratio(cents:int,numerator:int,denominator:int) -> int:
    if not valid(cents) or numerator<0 or numerator>1000 or denominator<=0 or denominator>1000000:return INVALID
    var whole:int=cents/denominator
    var remainder:int=cents%denominator
    return add(multiply(whole,numerator),remainder*numerator/denominator)
static func scale(cents:int,factor:float,down:bool=false) -> int:
    if not valid(cents) or not is_finite(factor) or factor<0:return INVALID
    var result:float=float(cents)*factor
    if not is_finite(result) or absf(result)>float(MAX_CENTS):return INVALID
    return floori(result) if down else roundi(result)
static func market(units:float,price_cents:int) -> int:
    if not is_finite(units) or units<0 or price_cents<=0 or not valid(price_cents):return INVALID
    return scale(price_cents,units,true)
