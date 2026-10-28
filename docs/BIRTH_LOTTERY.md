# Birth lottery

Every run starts with a real birthplace. Instead of four abstract origins, the
game now draws one of 192 countries weighted by how many children are actually
born there each year, then translates that draw into starting conditions.

## Data

`scripts/BirthCountries.gd` holds one row per country:

```
[iso3, region_code, births_per_year, life_expectancy, gdp_per_capita_usd]
```

Source: World Bank 2023 indicators. Births are derived as
`population (SP.POP.TOTL) x crude birth rate (SP.DYN.CBRT.IN) / 1000`.
Life expectancy is `SP.DYN.LE00.IN`, income is `NY.GDP.PCAP.CD`. Six countries
missing from the 2023 pull (Cuba, Eritrea, North Korea, South Sudan, Syria,
Yemen) carry their latest published values. The table totals 131.1 million
births a year, so a draw reproduces the real distribution closely: India 17.7%,
China 6.9%, Nigeria 5.7%, Pakistan 5.2%.

Country and region names are not stored in the script. They live in the
bilingual catalog as `country.<iso3>.name` and `region.<code>`, because the
copy contract rejects display strings inside `scripts/**`.

## What a draw sets

| Term | Formula | Range |
| --- | --- | --- |
| Starting capital | `70 x (gdp/1000)^1.15`, clamped | $150 – $14,000 |
| Health | `46 + (life - 50) x 1.5` | 55 – 100 |
| Intellect | `10 + 9.5 x log10(gdp/600)` | 8 – 36 |
| Background stress | `18 - (health - 55) x 0.18` | 6 – 18 |
| Living-cost term | `(gdp/9000)^0.34` | 0.45 – 3.2 |
| Opportunity term | `(gdp/12000)^0.22` | 0.62 – 1.55 |
| Lifespan | `life + 2` | 70 – 88 |

## Why the country cannot become a prison

Two of those terms are temporary by construction.

`origin_weight(age)` falls linearly from 1.0 at 18 to 0.0 at 52. The income
modifier is `1 + (opportunity - 1) x origin_weight`, so a poor start costs up to
38% of early business and dividend income and nothing at all after 52. Living
costs keep a shrinking share of the country term (`45%` at full convergence), so
prices stay plausible while the ceiling lifts.

Everything else is a starting position, not a cap. Capital buys the first
business or does not; health and intellect decide how comfortably the first
decades run; the lifespan bounds how many quarters a single generation gets.
None of them gates progression, and the dynasty loop carries capital forward
when a generation ends early.

The player can therefore read the draw as a difficulty setting for the first
half of a life, not as a verdict.

## Regenerating

The data module and the catalog rows are produced by a generator kept outside
the repository (`.ref/gen_catalog.py` in the workspace) from cached World Bank
responses. Re-running it rewrites `scripts/BirthCountries.gd`, appends any
missing `country.*` / `region.*` rows to both CSVs, and leaves existing bytes
untouched. Afterwards run, in order:

```
python tools/compile_localization.py
python tools/build_manifest.py
```

`localization.json` must stay LF on Windows; `compile_localization.py` writes
with platform line endings, so convert the file back to LF before rebuilding the
trust anchor or `tests/test_default_checkout.py` will report a stale anchor.

## Проверка по-русски

Каждый забег начинается с реальной страны: 192 государства, взвешенные по
числу рождений в год. Страна задаёт стартовый капитал, здоровье, образование,
уровень цен, ожидаемую продолжительность жизни и фору или отставание по
доходу. Влияние на доход линейно тает с 18 до 52 лет, доля влияния на цены
снижается до 45% — дальше исход зависит только от решений игрока. Родиться в
бедной стране означает тяжёлый старт, а не приговор.
