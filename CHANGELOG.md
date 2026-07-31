# Changelog

All notable changes to the **CWStudio Components Library**.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

---

## [1.6.9] — 2026-07

- New on `TCWSStringGrid` and `TCWSDBGrid`: **alternating (zebra) row colors** — `AlternatingRowColors` (off by default, so existing forms are unchanged) plus `OddRowColor` / `EvenRowColor`. Rows are numbered from 1, so the first data row is the odd one; fixed rows / columns and the highlighted (current) row keep their own colors.
- Both band colors default to `clNone` = *derive from `CellColor`*: odd rows take `CellColor` itself, even rows a slightly shaded variant (darker on a light theme, lighter on a dark one). Left that way the striping follows a `CWSFluentColors` theme switch on its own — the application only re-assigns `CellColor`, as it already does. An explicit color pins a band to a fixed value.
- `TCWSDBGrid` bands by **record** (`DataSet.RecNo`), not by screen position, so the stripes stay glued to the data instead of flipping every time the grid scrolls by one record. Datasets that don't support `RecNo` (`IsSequenced` false) fall back to the on-screen row.

## [1.6.8] — 2026-07

- Fix `TCWSListBox`: the scrollbar now appears/disappears correctly after a title-bar **maximize / restore** (double-click). Visibility is recalculated from the target height *before* resizing the inner list, instead of from its stale pre-resize size — previously the scrollbar only refreshed once the mouse entered the list.
- Fix `TCWSListBox`: the focus / hover / normal background (and the selection highlight) now fills the **whole item row** in owner-draw mode (`lbOwnerDrawFixed` and `lbOwnerDrawVariable`), matching the empty area — including under a custom `OnDrawItem` that draws transparently. The state background is painted before the item content. *(Note: a handler that fills its own opaque background still wins; fill with the brush the component pre-sets, or with `Sender.Color`, to follow the focus colour.)*
- New `Constraints` property on `TCWSSettingsPanel` — set minimum / maximum width and height, exactly like the stock VCL controls.
- added Visible property to CWSStoreButton and CWSMenuButton

## [1.6.7] — 2026-07

- New on `TCWSOptionsPanel`: icon-font **glyph** support in the header — `IconMode` (`icmImageList` / `icmGlyph`) with `IconGlyph`, `IconFontName`, `IconFontSize` and `IconColor`, exactly like `TCWSButton` (image-list icons still work as before).
- New `TitleSpacing` property — configurable gap between the header title and subtitle.
- New `RoundLastSection` property — round the bottom corners of the last section when expanded (honours `RoundBottomLeft` / `RoundBottomRight`) so the whole card keeps rounded bottom corners; the section reconstructs the card border along the rounding.
- Fix: shape / border properties (`CornerRadius`, `BorderColor`, `BorderBottom`, `RoundBottom*`, `RoundLastSection`) now repaint the hosted sections too, so the rounded last section refreshes immediately at design time.
- All new metrics are DPI-scaled.

## [1.6.6] — 2026-07

- New: `Action` (`TActionList`) support on `TCWSButton`, `TCWSCheckBox`, `TCWSRadioButton` and `TCWSSwitch` — the action drives `Caption`, `Enabled`, `Visible`, `Hint` (and `Checked` on the toggle controls) and a click executes `OnExecute`, mirroring the stock VCL controls (value-linking semantics).
- New shared `CWSActions` unit (`ICWSActionClient`, `TCWSControlActionLink`, action-change / click-dispatch helpers).

## [1.6.5] — 2026-07

- Fix: mouse wheel now scrolls when the cursor is over the scrollbar strip in `TCWSListBox`, `TCWSMemo` and `TCWSDBGrid`.

## [1.6.4] — 2026-07

- Fix: hover rectangle in the years view of `TCWSDatePicker`.
- `TCWSOptionsPanel` and `TCWSButton` design-time resize fixes.

## [1.6.1 – 1.6.3] — 2026-06 – 07

- New `TCWSOptionsPanel` (Expander) and `TCWSEditMask` components.
- Separate `ButtonStyle` enums for `TCWSEdit` / `TCWSEditMask`.
- Windows theme-change listener in the Fluent color modules.

## [1.6.0] — 2026-06

- New `TCWSSwitch`, `TCWSCheckBox`, `TCWSRadioButton`, `TCWSProgressBar`, `TCWSPopupMenu`, `TCWSIndicatorLoading`.
- `NoBorder` property on grids; 32-bit animation fixes; new splash screen.

## [1.1.0] — 2026-06

- New `TCWSListBox`, `TCWSStringGrid`, `TCWSDBGrid`, `TCWSShape`, `TCWSLabelColumn`, `TCWSLabelTrend`.
- Horizontal scrollbar in `TCWSMemo`; removed SVG dependencies.

## [1.0.1] — 2026-06

- MIT license; UTF-8 sources.
- Drag & drop in `TCWSListBox`; assorted visual fixes.

## [1.0.0] — 2026-01 – 05

Initial release.

- `TCWSButton`, `TCWSMenuButton`, `TCWSStoreButton`, `TCWSCornerPanel`, `TCWSSettingsPanel`, `TCWSProgressCircle`, `TCWSDimOverlay`, `TCWSAfterFormShow`, `TCWSEdit`, `TCWSComboBox`, `TCWSMemo`, `TCWSDatePicker`, `TCWSScrollBox`.
- `CWSFluentColors` / `CWSFluentColorsMulti` modules and the HTML color swatch.
- Split into RT/DT packages.
