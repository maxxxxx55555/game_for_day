# Appearance

Two complete skins, one drawing routine. Everything visual resolves through
`scripts/ui/Palette.gd`, so switching themes is a redraw rather than a second
stylesheet.

## Skins

| Token | Dark | Light |
| --- | --- | --- |
| `ink` page | `#0a0f16` | `#f3eee2` |
| `surface` panel | `#111a25` | `#fbf7ee` |
| `raised` popup | `#16212e` | `#ffffff` |
| `deep` event panel | `#0d151f` | `#ebe4d4` |
| `rule` hairline | `#26313f` | `#d8cdb6` |
| `rule_soft` hairline | `#1d2733` | `#e4dbc8` |
| `text` | `#ede7da` | `#1b2027` |
| `muted` | `#8a97a6` | `#6f6a5e` |
| `accent` | gold `#c9a227` | bronze `#8a6a2f` |
| `accent_deep` | `#a9871f` | `#6d5324` |
| `green` | `#7fb069` | `#4f7a3a` |
| `alert` | `#c4614f` | `#a8443c` |
| `track` unfilled meter | `#1e2a38` | `#ddd4c1` |

Dark is ink and gold; light is warm paper and bronze. Neither uses more
than one accent — gold marks value, never decoration.

## Switching

`GameManager.theme_mode` persists in `dynasty_save.cfg` under `settings`, so the
choice survives restarts and never touches the run. `set_theme_mode()` emits
`theme_changed`; `Main.apply_skin()` rebuilds the Theme, re-applies explicit
colour overrides, repaints the custom-drawn cards and re-tints the icons. Every
`_draw`-based control also listens to the signal on its own.

Two entry points: the sun/moon button next to the language picker on the intro
screen, and `Оформление` in Settings.

## Surfaces and icons

- `assets/ui/button-{normal,hover,pressed,disabled}.svg` — dark set.
- `assets/ui/button-*-light.svg` — light set, selected by `Palette.button_variant()`.
- `assets/ui/check-{on,off}[-light].svg` — checkboxes for both skins.
- `assets/ui/icons/*.svg` — 24×24 line icons, drawn white and tinted through the
  Button `icon_*_color` overrides, so one file serves both skins. Wired in
  `Main.apply_icons()` for the bottom bar (Рынки, Бизнес, Грант, Настройки) and
  the intro theme toggle.

Sliders are styled as a 4px groove with a bronze filled area instead of the
engine default.

## Country plate

`scripts/ui/CountryPlate.gd` replaces the single shared city painting with a
per-country banner. It paints a wash from the three dominant flag colours
(`BirthCountries.gd` column 6), an oversized ISO monogram watermark, the country
name in Prata, the region in tracked capitals, and the birth share — plus a
three-bar emblem on the right that reduces the flag to rhythm. Content is
anchored to the bottom so it reads as a caption for the event text underneath.

The plate expands to fill the event panel; `Main` keeps the scroll column at
viewport height so the illustration can take the slack. A gradient scrim
(modulated by the panel colour) sits between the flag wash and the typography so
the name reads over any national palette.

## Chrome, cover and print cues

Three details carry most of the "expensive" impression, and all of them are one
draw call:

- `scripts/ui/Chrome.gd` — a hairline frame inset 9px with 20px corner ticks,
  drawn over the whole screen at `z_index = 90`. One rule, four ticks, no
  ornament.
- `scripts/ui/IntroCover.gd` — the opening painting becomes a book jacket: a
  gradient scrim that stays dark in both skins, a tracked overline
  (`intro.overline`), the title in Prata (`intro.title`) and a 64px gold rule.
- `scripts/ui/ChoiceCard.gd` — a Roman numeral in the left gutter of every
  decision, the way a numbered menu is set in print. The card's left margin
  moved from 20 to 46 to make room.

The event card also carries a chapter overline (`stage.survival` …
`stage.billionaire`) derived from the same net-worth thresholds the event pools
use, so the label never disagrees with the events on screen.

## Проверка по-русски

Три детали дают основное ощущение «дорого», и каждая — один вызов отрисовки:
тонкая рамка с уголками поверх всего экрана; стартовый экран как обложка книги
(затемнение, надзаголовок в разрядку, название шрифтом Prata, золотая линейка);
римские цифры в жёлобах вариантов ответа. В карточке события появилась строка
этапа — «ВЫЖИВАНИЕ», «КАРЬЕРА», «КАПИТАЛ», «ИМПЕРИЯ».



## Проверка по-русски

Две темы: тёмная (чернила и золото) и светлая (тёплая бумага и бронза).
Переключатель — солнце на стартовом экране и пункт «Оформление» в настройках;
выбор сохраняется между запусками и не влияет на игру. Все цвета идут через
`Palette.gd`, поэтому смена темы — это перерисовка, а не второй набор стилей.
Иконки нижней панели и чекбоксы перекрашиваются автоматически. Картинка в
карточке события теперь своя для каждой страны: замес из трёх цветов флага,
монограмма ISO, название шрифтом Prata и доля новорождённых.
