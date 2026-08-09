# Changelog

All notable changes to the **CWStudio Components Library**.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

---

## [1.7.2] — 2026-08

- **New** on `TCWSScrollBox`: the **`srmShaped`** render mode, now the default for `ScrollbarRenderMode`. It is the WinUI 3 / Windows 11 model — the bar owns no track at all: its window IS the rounded thumb (clipped with `SetWindowRgn`), and the rest of the lane has no window on it, so the content there is untouched exactly as if the track were transparent. Being a plain child window it is composed by Windows together with its parent, so it can neither flicker nor lag behind the edge while the form is resized. The rounded ends are still antialiased per pixel: the region only cuts the corners, while the capsule's fringe is blended into `BackgroundColor`.
- **Removed** on `TCWSScrollBox`: the **`srmLayered`** render mode. A `WS_EX_LAYERED` child is composed by the DWM on its own schedule, which is what made the bar flicker and float along the window edge during a resize — worked around until now by "parking" the layer for the duration of the drag. It also cost far more per scroll step than it was worth: moving it forced the scrolled content underneath to repaint. `srmShaped` delivers the same "the track does not cover the content" result without a layer, so the mode, the parking machinery and the form subclass that drove it are all gone. **Breaking:** a `.dfm` that stores `ScrollbarRenderMode = srmLayered` will not load — change it to `srmShaped` (closest match) or `srmBlended`, or delete the line to take the default.
- **Changed** `TCWSScrollBox`: **much faster scrolling with large bitmaps and many child controls.** Four things used to make a single wheel tick cost a repaint of the whole content, and none of them do any more. The content host is no longer `DoubleBuffered` in the VCL sense — that allocated and blitted a bitmap the size of the *content*, not of the view, on every paint, and left every graphic child to repaint with it; it now buffers into a bitmap the size of the update rectangle, with the clip set so the VCL skips each control outside the band. The clip region that keeps the content off the border is applied before the move and without a forced redraw, since the visible rectangle does not actually change. The thumb is refreshed once per step instead of twice. And a `srmShaped` thumb that only MOVED is not repainted at all — its pixels travel with the window — while `srmBlended` repaints just the old and the new thumb rectangle instead of the whole lane. The bar composes into one reused DIB rather than allocating a new one per paint.
- **Changed** `TCWSScrollBox`: the thumb now **hugs the edge its bar lives on** — 1 px from the right edge of the box for the vertical bar, 1 px from the bottom for the horizontal — instead of floating centred in the `ScrollbarAreaWidth` lane. That 1 px belongs to the bar, not to the content: it lies inside the bar's window in both render modes, so the cursor reaching the very edge of the box already counts as hovering the scrollbar. Growing on hover (`ScrollbarThumbHoverWidth`) therefore extends the thumb inward only and the edge the eye follows stays put — which also retires the parity snapping that used to keep a centred thumb from growing lopsidedly.

## [1.7.1] — 2026-08

- **New** on `TCWSScrollBox`: **`ScrollbarRenderMode`** — how the overlay scrollbar is put on screen. `srmLayered` (default, unchanged behaviour) keeps the bar as a `WS_EX_LAYERED` child window, so the scrolled content stays visible **through** the transparent track. `srmBlended` drops the layer: the bar becomes an ordinary child window, its track is filled with `BackgroundColor` and the thumb is drawn in `ScrollThumbColor` pre-mixed with that background according to `ScrollThumbAlpha`. Use `srmBlended` on forms that get resized — most visibly with `Align = alClient`, where the layered bar flickers and lags behind the window edge while the frame is dragged; that is how the DWM composes a layered child window, and it cannot be cured from inside the component. Trade-off: content lying under the bar is covered by the strip instead of showing through — with the usual setup (scrollbox background = content background) there is no visible difference.
- **Fix** `TCWSScrollBox` (`srmBlended`): the square where the two bars meet in the bottom-right corner is no longer a hole punched out of the strip. Both bars used to be shortened by the scrollbar width, so that square belonged to neither — invisible with the transparent track of `srmLayered`, but an empty notch once the track is opaque. The vertical bar now owns the corner, and its thumb still stops exactly where the horizontal bar begins.
- **Changed** `TCWSScrollBox`: the design-time preview follows the render mode, so switching `ScrollbarRenderMode` is visible in the form designer — `srmLayered` clips the bar window to the rounded thumb (content shows through the track), `srmBlended` previews the opaque strip including the corner. The thumb is also previewed in the colour it really ends up with on screen (`ScrollThumbColor` mixed with the background per `ScrollThumbAlpha`) instead of fully opaque.
- **Changed** `TCWSScrollBox`: in `srmLayered` the bar's pixels are uploaded with `UpdateLayeredWindow` — position, size and content in a single call — instead of being painted through `WM_PAINT` behind a colour key. The thumb gains real per-pixel alpha, so its rounded ends are antialiased rather than keyed out.

## [1.7.0] — 2026-08

- **Changed** — the password button on `TCWSEdit` and `TCWSEditMask` (`ebsPassword` / `embsPassword`) is now a **hold-to-reveal** button, like the WinUI 3 `PasswordBox`: the text is visible only while the button is held down and is masked again on release. Previously a click toggled it and the password stayed on screen. Masking is also restored when the release lands outside the button, and when the mouse capture is cancelled without a release (modal dialog, Alt+Tab, Esc). Reveal keeps the edit's font, caret and selection — changing `PasswordChar` recreates the edit handle, which drops all three. `OnButtonClick` still fires as before; the other button styles are unchanged.
- **Fix** — rounded corners no longer show a wrong-colored triangle when the parent does not paint itself as a flat fill of its own `Color`: a container drawing a card / gradient background, a VCL-styled form, or a parent whose `Color` is out of sync with what it actually paints. The area outside the rounding is now rendered by asking the parent for its real background (clipped to that sliver) instead of guessing from `Parent.Color`, which stays as the fallback. Applies to `TCWSEdit`, `TCWSEditMask`, `TCWSMemo`, `TCWSComboBox`, `TCWSDatePicker`, `TCWSListBox`, `TCWSStringGrid`, `TCWSDBGrid`, `TCWSSettingsPanel` and `TCWSOptionsPanel`. On `TCWSListBox` this only applies when the corners are set to blend with the parent — an explicit `CornerColor` or `Color` still wins. Design time keeps the flat fill so the designer's dot grid cannot bleed into the corners.
- **Fix** `TCWSOptionsPanel`: hovering the header no longer tints the card border. The hover wash runs along the same half-pixel geometry as the border stroke, so filling it on top blended half of `HoverColor` into every border pixel; it is now painted before the outline.
- **Fix** `TCWSOptionsPanel`: with a border edge switched off (`BorderTop` / `BorderRight` / `BorderBottom` / `BorderLeft`), the rounded corners showed a third color that was neither the fill nor the background. The outline was stroked whole and the hidden parts painted over — which cancels exactly on a straight edge, but not on an antialiased corner arc, leaving a `BorderColor` ghost. Only the visible edges are stroked now.

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
