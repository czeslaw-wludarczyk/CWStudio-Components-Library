# Changelog

All notable changes to the **CWStudio Components Library**.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

---

## [1.7.3] — 2026-08-10

- **Changed** `TCWSScrollBox` (`srmShaped`): the antialiased ends are now blended into **the pixels that really lie under the bar**, not into `BackgroundColor`. The bar reproduces them itself — the scrolled content host and the controls on it draw into its composing buffer (`WM_PRINTCLIENT` / `WM_PRINT`) — which is what a compositor would do for a translucent layer, without the bar ever becoming a layered window. So the rounded corners stay smooth where the thumb passes over an **image or a nested control**, instead of trailing a background-coloured crescent, and the 1 px sliver between the thumb and the edge of the box no longer paints over the content either. It also means a **light/dark theme switch needs no help**: the ends are composed against whatever the content repainted itself as, and a repaint under a bar refreshes it. Costs nothing in the normal case — while there is only flat background under the bar nothing is fetched and a scroll step remains a pure window move; only a thumb actually overlapping content is recomposed, and only over its own (tiny) rectangle. New `RefreshScrollbars` method for the rare repaint the component cannot see (a VCL style change applied behind its back).
- **Fix** `TCWSScrollBox` (`srmShaped`): **the thumb's rounded ends no longer keep the colour of a control that has since changed underneath.** Selecting and then deselecting a `TCWSStoreButton` behind the bar left the selection colour sitting in the antialiased ends: those ends carry a trace of the pixels under them, and nothing told the bar that those pixels had moved on. Nothing *could* — measured on that control, its repaint goes through `Repaint`/`UpdateWindow`, which sends `WM_PAINT` straight to the window without it ever passing through the message queue, so no message filter can observe it. The bars therefore re-read what lies under them a few times a second: only while the cursor is inside the box (the only time the staleness can be seen), only for a bar that actually overlaps content, and once more the moment the cursor arrives — so a change made while the pointer was away is already gone by the time the bar is looked at. A bar over plain background does no work at all.
- **Fix** `TCWSScrollBox` (`srmShaped`): **a control under the lane no longer lights up when the pointer is on the scrollbar.** The lane belongs to the bar, but with no window over it the content underneath still received the mouse and took its hover — so running the pointer along the bar highlighted the card or button behind it, everywhere except on the thumb itself. Mouse moves over the lane are now swallowed, and whatever was under the pointer is handed a `WM_MOUSELEAVE` so it drops the highlight it had already taken. That message rather than a direct `CM_MOUSELEAVE` on purpose: the VCL only sends an *enter* when the tracked control changes, so clearing the highlight without clearing the bookkeeping behind it would leave the control unable to light up ever again. Nothing is swallowed while any gesture holds the mouse capture, so a splitter drag or a text selection sweeping across the lane is untouched.
- **Fix** `TCWSScrollBox` (`srmShaped`): **no more smear across the scrollbar after hovering a control next to it.** Moving the pointer off a control that changes appearance under the cursor — a `TCWSStoreButton`, and any other hot-tracking control — and onto the scrollbar left a strip of the control's *previous* look behind. The bar used to widen its window over the whole lane so the lane could be clicked, and pixels a window covers are a snapshot: whatever repainted underneath (the button dropping its hover, a `TCWSIndicatorLoading` turning) kept showing its old self inside the strip. The bar no longer covers the lane at all — it is the thumb and nothing more, in every state — and lane clicks are caught before dispatch instead. Anything under the lane stays live.
- **Fix** `TCWSScrollBox`: **maximizing and restoring the window no longer sends the content back to the top left.** Most visible with `Align = alClient`, where maximizing enlarges the view the most: once the view is big enough to fit the content there is nothing left to scroll, and the offset was clamped to 0 *in place* — restoring the window brought back the room to scroll but no longer had anywhere to restore the position from. The box now remembers the position it was last **scrolled to** and re-derives the effective offset from that on every layout, so the view shrinking back brings the position with it. A partial resize still clamps to whatever is reachable, and any later scroll replaces the remembered position. Applies to both axes.
- **Changed** `TCWSScrollBox`: the thumb is **centred across its lane** — the same margin on either side of it within `ScrollbarAreaWidth` — instead of being pinned against the right edge of the box (vertical bar) or the bottom edge (horizontal). Growing on hover (`ScrollbarThumbHoverWidth`) is symmetric: the thickness is snapped to the parity of the lane so the thumb's centre line cannot shift by half a pixel as the mouse enters, which is what would make it look like it twitches sideways. At the default 14 / 4 / 6 — and every whole DPI scale of it — the parities already agree and nothing is snapped.
- **New** `TCWSScrollBox`: the scrollbar now **thickens while the cursor is anywhere in its lane**, not only when it is exactly on the thumb — so a centred thumb is as easy to reach as an edge-hugging one was, and the bar behaves the way the WinUI 3 one does. It has to be done by watching the cursor rather than with a window: in `srmShaped` the bar's window *is* the thumb, and a window covering the rest of the lane would have to paint it — which is the other render mode. Mouse moves cannot simply be listened for either, since over a child control they never reach the box. So the box arms a tracker when the cursor enters it **or anything nested in it** (`CM_MOUSEENTER` travels up the parent chain) and polls the cursor at 60 ms until it leaves — a tick being one `GetCursorPos` and two rectangle tests, and only while the cursor is inside. While the tracker is up it owns the hot state, so sliding off the thumb but along the lane no longer makes the thumb blink between its two thicknesses.
- **New** `TCWSScrollBox` (`srmShaped`): **the whole lane is clickable while the pointer is on the bar** — press beside the thumb to start dragging it, above or below it to jump. Previously only the thumb itself could be pressed, so the margin between the thumb and the edge of the box was dead: the bar thickened under the cursor but would not move. A plain window's region decides its pixels and its mouse hit area at once, and the bar's window is exactly the thumb, so the press is **caught in the message loop before it is dispatched** and handed to the bar — beside the thumb it starts the drag and takes the mouse capture, so the rest of the gesture arrives the ordinary way. Nothing is covered and no pixels are involved; the catcher exists only while the pointer is actually on a lane, and clicks on the thumb itself still travel the normal path. Pressing the lane deliberately does **not** move focus, as a scrollbar should not. *Note: a control lying under the lane no longer receives presses there — which is the point.*

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
