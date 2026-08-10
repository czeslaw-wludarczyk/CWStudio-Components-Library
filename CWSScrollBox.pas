//////////////////////////////////////////////////////////////////////////
//
//   CWStudio Components Library
//   Created by Czesław Włudarczyk 2026 CWStudio
//
//   LICENSE: MIT
//   Free to use, modify and distribute in any project, commercial or
//   non-commercial, provided that the copyright notice and this license
//   text are preserved. See the LICENSE file for the full MIT terms.
//
//   ATTRIBUTION REQUIRED:
//   Any application built using CWStudio components MUST include
//   visible information about the author of the components inside
//   the application (e.g. in the About box, credits screen, or
//   splash screen), for example:
//
//       "Uses CWStudio components by Czesław Włudarczyk"
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
//////////////////////////////////////////////////////////////////////////
unit CWSScrollBox;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.Types, System.Math,
  Vcl.Controls, Vcl.Graphics, Vcl.AppEvnts, System.UITypes;

const
  { Posted (NOT sent) to defer a layout refresh out of CM_CONTROLLISTCHANGE so we
    never relayout — and never call BringToFront — while a child control is still
    mid-destruction. That synchronous relayout re-entered the IDE designer
    (BuildLocalMenu -> FreeAndNil(popup) -> Notification) and crashed the
    half-destroyed TDBGrid in TCustomDBGrid.Notification. }
  CM_CWS_RELAYOUT = $B080 + 20;

type
  TCWSScrollBox = class;

  TCWSScrollKind = (skVertical, skHorizontal);

  { TCWSScrollStyle — filter of allowed scroll directions.
    When a direction is disabled, ContentW/H on that axis is clamped to
    the view size → MaxOffset = 0 → the scrollbar never appears,
    and content sticking out of the view is clipped by the clip region. }
  TCWSScrollStyle = (cssNone, cssHorizontal, cssVertical, cssBoth);

  { TCWSScrollbarRenderMode — how the overlay scrollbar is put on screen.

    Both modes use a PLAIN child window, composed by Windows together with its
    parent, so neither can flicker nor lag behind the edge while the form is
    resized — whatever the drag does, including the worst case of dragging the
    form by its LEFT edge, where the window's screen origin and the bar's client
    position move in opposite directions.

    srmShaped  (default)
        The WinUI 3 / Windows 11 model: the bar owns NO track. Its window is
        exactly the thumb, clipped by SetWindowRgn to the rounded capsule, and
        the rest of the lane simply has no window on it, so the content there is
        untouched, exactly as if the track were transparent.
        The thumb is opaque: ScrollThumbColor is pre-mixed with BackgroundColor
        by ScrollThumbAlpha, so nothing shows through the body of the bar. Only
        the ENDS are soft: the window region merely cuts the corners, while the
        capsule itself is rendered per pixel with fractional coverage
        (RenderCapsule).
        Those fractional pixels are blended into THE PIXELS THAT REALLY LIE UNDER
        THE BAR — the bar reproduces them itself (CaptureBackdrop) by having the
        content host and the controls on it draw into its composing buffer. That
        is what a compositor would do for a translucent layer, and it is why the
        rounded ends stay smooth over an image or a nested control instead of
        trailing a background-coloured crescent, and why they follow a light/dark
        theme switch without being told what the new colours are.
        Still the cheapest mode per scroll step in the normal case: while there is
        nothing but flat background under the bar, the thumb window is simply
        MOVED and a pure move needs no repaint at all — the pixels travel with the
        window. Only a thumb that actually passes over content pays for the
        recomposition, and only over its own (tiny) rectangle.

    srmBlended
        The window is the whole lane: an opaque track in BackgroundColor with the
        capsule drawn inside it, in ScrollThumbColor mixed with that background
        according to ScrollThumbAlpha. Trade-off: content that lies under the bar
        is covered by the strip instead of showing through — with the usual setup
        (scrollbox background = content background) there is no visible
        difference.
        When both bars are up, the vertical one also owns the corner square
        between them, so the two strips join into one continuous L instead of
        leaving a hole at the bottom right.
        Per scroll step only the union of the old and the new thumb rectangle is
        repainted, not the whole lane. }
  TCWSScrollbarRenderMode = (srmBlended, srmShaped);

  { TCWSScrollContent — internal content host. All user
    controls land here. Scrolling = moving this window. }
  TCWSScrollContent = class(TCustomControl)
  private
    FScrollBox: TCWSScrollBox;
    { Set while this window is drawing itself. TCustomControl paints through ONE
      shared FCanvas whose handle is cleared when the paint unwinds, so a nested
      paint would leave the outer one drawing on a closed canvas. The scrollbars
      read this window back through WM_PRINTCLIENT (CaptureBackdrop) and skip it
      while the flag is up — they fall back to the flat background for that one
      paint rather than corrupt the content's. }
    FPainting: Boolean;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure Paint; override;
    procedure PaintWindow(DC: HDC); override;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    { Double buffering bounded by the UPDATE rectangle — see the implementation.
      This is the hot path of the whole component: FContent is as large as the
      CONTENT, not as the view, and the VCL's own DoubleBuffered would allocate
      (and blit) a bitmap that size on every single paint. }
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  { TCWSScrollOverlay — overlay scrollbar (plain child window). }
  TCWSScrollOverlay = class(TCustomControl)
  private
    FScrollBox: TCWSScrollBox;
    FKind: TCWSScrollKind;
    FHot: Boolean;
    FDragging: Boolean;
    FDragStart: Integer;
    FDragStartOffset: Integer;
    FThumbRect: TRect;              { thumb, in STRIP coordinates }
    { The strip is the logical bar lane along the edge — the rectangle the thumb
      math lives in. It is the window's own rectangle in srmBlended, but NOT in
      srmShaped, where the window is only the thumb; so the lane has to be
      remembered separately instead of being read off Width/Height. }
    FStrip: TRect;
    FShapeW, FShapeH: Integer;      { size the srmShaped region was built for }
    FLastDesignThumb: TRect;        { last design-time thumb rect (region cache) }
    FHasDesignRgn: Boolean;         { a design region has already been applied }
    { What the window currently SHOWS: the thumb it was last painted with and the
      hover state it was painted in. Together they answer "does this refresh need
      a repaint at all, and if so, of how much?" — which is what keeps a scroll
      step down to a window move (srmShaped) or to the two thumb rectangles
      (srmBlended) instead of a full redraw of the bar. }
    FPaintedThumb: TRect;
    FPaintedHot: Boolean;
    { True when the last paint had nothing but flat BackgroundColor to blend the
      capsule's fringe into. While that stays true a scroll step is still a pure
      window move; the moment real content comes under the bar (or leaves it) the
      fringe has to be recomposed, because it carries a trace of the backdrop. }
    FPaintedFlatBack: Boolean;
    { Reusable 32-bit top-down DIB the capsule is composed in, kept for the life
      of the bar instead of being created per WM_PAINT. }
    FBufDC: HDC;
    FBufBmp, FBufOldBmp: HBITMAP;
    FBufBits: PByte;
    FBufW, FBufH: Integer;
    { Pixels at the FAR end of the window that are not part of the track: the
      square where the two bars meet. srmBlended paints an opaque strip, so one
      of the bars has to own that square — otherwise the two strips leave a hole
      at the bottom right corner. The thumb must stay out of it. }
    FEndInset: Integer;
    procedure SetHot(Value: Boolean);
    { Is the box currently watching the cursor over this bar's lane? Then the box
      owns the hot state and this window must not clear it on its own. }
    function LaneTracked: Boolean;
    { The mode the bar is rendered with — the box's ScrollbarRenderMode. }
    function RenderMode: TCWSScrollbarRenderMode;
    function ThumbColorNow: TColor;
    function ThumbAlphaNow: Byte;
    { srmShaped: put the thumb window exactly on the thumb and clip it to the
      rounded capsule. This is the whole bar — there is no track window.
      AForce repaints even when only the position changed (a property that
      changes how the thumb LOOKS, not where it sits). }
    procedure ApplyShape(AForce: Boolean);
    { srmBlended: mark for repaint just the part of the lane that can have
      changed — the old thumb, the new one, and the fringe around them. }
    procedure InvalidateThumbArea(AForce: Boolean);
    { Composing buffer for PaintCapsule: (re)allocated only when the bar's client
      area changes size, so a scroll step allocates nothing. }
    procedure EnsureBuffer(AW, AH: Integer);
    procedure FreeBuffer;
    { Paint the antialiased capsule AThumb (client coordinates) over the field it
      belongs on. Both modes paint through this, so the rounded ends come out
      smooth instead of stepped. Only the canvas' clip box is composed and
      blitted — the rest of the lane keeps the pixels it already has. }
    procedure PaintCapsule(const AThumb: TRect);
    { The window whose pixels lie under the bar, plus the position of its client
      origin in the SCROLLBOX's client coordinates — at runtime the scrolled
      content host, at design time the box itself (that is where the user's
      controls are then). nil when there is nothing to read. }
    function BackdropHost(out AOrgX, AOrgY: Integer): TWinControl;
    { Is there nothing but flat BackgroundColor under ABoxArea (scrollbox client
      coordinates)? Then the fringe needs no backdrop and the whole capture below
      is skipped — which is the normal case, and what keeps a scroll step free. }
    function BackdropIsFlat(const ABoxArea: TRect): Boolean;
    { Reproduce into the composing buffer the pixels that lie UNDER AArea (bar
      client coordinates), by having the content host and the controls on it draw
      themselves into it. This is what a compositor would hand a translucent
      layer; we fetch it ourselves because a plain child window cannot see through
      its own pixels — and doing it this way keeps the bar an ordinary,
      non-layered window that composes with its parent without lag. }
    function CaptureBackdrop(const AArea: TRect): Boolean;
    { Strip geometry (see FStrip): length along the scroll axis and thickness
      across it. }
    function StripLen: Integer;
    function StripCross: Integer;
    { Usable track length along the scroll axis: the strip may be longer than
      the track when it owns the corner square between the two bars
      (FEndInset), and both ends keep a small margin. }
    function TrackLength: Integer;
    { Mouse position translated into STRIP coordinates — the frame FThumbRect and
      all the scroll math are expressed in. }
    function ToStrip(X, Y: Integer): TPoint;
    procedure JumpToPoint(X, Y: Integer);
    function OnThumb(X, Y: Integer): Boolean;
  protected
    procedure CreateWnd; override;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
  public
    constructor CreateOverlay(AScrollBox: TCWSScrollBox; AKind: TCWSScrollKind);
    destructor Destroy; override;
    procedure RecalcThumb;
    { Put the thumb where RecalcThumb says it belongs. This is the per-scroll-step
      path, so it does the LEAST the mode allows: srmShaped moves the window,
      srmBlended invalidates the two thumb rectangles. AForce = repaint no matter
      what, for a property that changed the bar's appearance. }
    procedure RefreshBar(AForce: Boolean = False);
    { Give the bar its new STRIP (the lane along the edge). What that means for
      the window itself depends on the mode:
        srmShaped  — the window is moved onto the thumb inside that lane;
        srmBlended — plain SetBounds, the window IS the lane. }
    procedure SetBarBounds(ALeft, ATop, AWidth, AHeight: Integer);
    { Design time only: clip the (always-visible, brought-to-front) overlay window
      to the rounded thumb shape — so the thumb floats ON TOP of inner controls,
      no opaque track covers content, and the window never hides/moves (no IDE
      "ghost"). Empty region when no scrollbar is needed. }
    procedure ApplyDesignRegion;
    { A press landed in this bar's LANE but not on the thumb window — there is no
      window there, so it was caught before dispatch and handed over here in
      SCREEN coordinates. Beside the thumb this starts a drag (and takes the
      mouse capture, so the rest of the gesture arrives the ordinary way);
      above or below it, it jumps. }
    procedure BeginLanePress(const AScreenPt: TPoint);
    { The content under ABoxArea (scrollbox client coordinates) was repainted. If
      any of it is under this bar, the fringe it was composed against is stale —
      this is what keeps the rounded ends correct across a light/dark theme
      switch, when every control repaints itself in new colours. }
    procedure BackdropChanged(const ABoxArea: TRect);
    property Hot: Boolean read FHot write SetHot;
  end;

  { TCWSScrollBox — main component. }
  TCWSScrollBox = class(TCustomControl)
  private
    FContent: TCWSScrollContent;
    FVScroll: TCWSScrollOverlay;
    FHScroll: TCWSScrollOverlay;

    FOffsetX, FOffsetY: Integer;
    { The position last SCROLLED TO, as opposed to the one currently in force.
      The two part company when the view grows: a bigger view means a smaller
      MaxOffset, and content that now fits pins the offset at 0. That clamp used
      to be destructive — maximizing a box (most visibly with Align = alClient)
      swallowed the scroll position, and restoring the window brought back the
      room to scroll but not the place the user had been. So the effective offset
      is DERIVED from this on every layout instead of being clamped in place: the
      view shrinks back, and the position comes back with it. A deliberate scroll
      is what writes here — the memory follows the user, never the layout. }
    FWantOffsetX, FWantOffsetY: Integer;
    FContentW, FContentH: Integer;
    FBoundW, FBoundH: Integer;
    FUpdatingLayout: Boolean;
    FRelayoutPending: Boolean;                  { a deferred (posted) relayout is queued }
    FDesignOffsetX, FDesignOffsetY: Integer;   { design-time scroll position }
    FInDesignScroll: Boolean;                   { reentrancy guard for design scroll }
    FDsgnNeedV, FDsgnNeedH: Boolean;            { last design-time scrollbar need state }
    FDsgnLayoutInit: Boolean;                   { design overlay layout ran at least once }
    FOverlayZOK: Boolean;                       { overlays are known to be on top (runtime) }
    { The lane hover tracker is armed — see StartLaneTracking. While this is up
      the BOX owns the bars' hot state; the bars stop clearing it themselves. }
    FLaneTracking: Boolean;
    { Alive while the cursor is anywhere in the box — see ArmLaneClicks. }
    FLaneEvents: TApplicationEvents;
    FLaneTick: Integer;                         { tracker ticks, for cLaneBackdropTicks }
    { The lane is currently swallowing mouse moves, so the content under it is
      not being hovered. See MuteLane. }
    FLaneMuted: Boolean;
    FContentClip: TRect;                        { clip region FContent currently carries }
    FHasContentClip: Boolean;

    FBackgroundColor: TColor;
    FBorderColor: TColor;
    FShowBorder: Boolean;
    FScrollThumbColor: TColor;
    FScrollThumbHoverColor: TColor;
    FScrollbarAreaWidth: Integer;
    FScrollbarThumbWidth: Integer;
    FScrollbarThumbHoverWidth: Integer;
    FScrollThumbAlpha: Byte;
    FScrollThumbHoverAlpha: Byte;
    FWheelStep: Integer;
    FScrollStyle: TCWSScrollStyle;
    FScrollbarRenderMode: TCWSScrollbarRenderMode;

    FOnScroll: TNotifyEvent;

    procedure RecalcBounding;
    procedure UpdateLayout;
    procedure QueueRelayout;
    procedure UpdateThumbs;
    procedure ApplyOffsets;
    procedure InvalidateOverlays;
    { FContent repainted ARect (its own client coordinates) — let the bars whose
      rounded ends were composed against those pixels know they are stale. }
    procedure NotifyContentPainted(const ARect: TRect);
    { Lane hover tracking: light the scrollbar up while the cursor is anywhere in
      its LANE, not only on the thumb itself.
      It has to be done by watching the cursor rather than by a window, because
      there IS no window over the lane: in srmShaped the bar's window is exactly
      the thumb, and a window that covered the rest of the lane would have to
      paint it — which is the other render mode. Nor can the box simply listen for
      mouse moves: over a child control they never reach it. So the tracker arms
      itself when the cursor enters the box (or anything nested in it) and polls
      the cursor until it leaves again. }
    procedure StartLaneTracking;
    procedure StopLaneTracking;
    procedure UpdateLaneHover;
    { Lane clicking. The lane has no window on it in srmShaped, so a press there
      would go to whatever content lies underneath. It is caught in the message
      loop instead — BEFORE dispatch — and handed to the bar.
      Catching it rather than covering the lane with a window is the whole point:
      a window would have to PAINT the lane, and painted-over content is a
      snapshot that goes stale the moment anything under it redraws (a button
      losing its hover, a spinner turning). Nothing is covered this way.
      The catcher exists only while the pointer is actually on a lane. }
    procedure ArmLaneClicks;
    procedure DisarmLaneClicks;
    procedure LaneAppMessage(var Msg: TMsg; var Handled: Boolean);
    { The lane belongs to the scrollbar, so nothing underneath may react to the
      pointer standing on it. The moves are swallowed for as long as the pointer
      is there, and AWnd — whatever would have received them — is handed a clean
      leave so it drops any highlight it had already taken. }
    procedure MuteLane(AWnd: HWND);
    procedure UnmuteLane;
    { Re-read the pixels a bar's antialiased ends were composed against, for bars
      that lie over content. See cLaneBackdropTicks for why this is a poll. }
    procedure RefreshLaneBackdrops;
    { The visible bar whose lane holds APt (screen coordinates), or nil. }
    function LaneAt(const AScreenPt: TPoint): TCWSScrollOverlay;
    { Keep FContent off the border. ARedraw = False on the scroll path: the clip
      rectangle follows the window's own move there, so what is visible on screen
      does not change and forcing a redraw would repaint the whole content —
      every bitmap, every child — on every wheel tick. }
    procedure UpdateContentClip(ARedraw: Boolean);
    function BorderSize: Integer;
    { Current scroll offset / scroll command for a given axis, transparently
      mapped to the design-time (FDesignOffset / DesignScrollTo) or the runtime
      (FOffset / SetOffset) model, so the overlay scrollbars work in both. }
    function AxisOffset(AKind: TCWSScrollKind): Integer;
    procedure ScrollAxisTo(AKind: TCWSScrollKind; Value: Integer);

    procedure SetBackgroundColor(const Value: TColor);
    procedure SetBorderColor(const Value: TColor);
    procedure SetShowBorder(const Value: Boolean);
    procedure SetScrollThumbColor(const Value: TColor);
    procedure SetScrollThumbHoverColor(const Value: TColor);
    procedure SetScrollbarAreaWidth(const Value: Integer);
    procedure SetScrollbarThumbWidth(const Value: Integer);
    procedure SetScrollbarThumbHoverWidth(const Value: Integer);
    procedure SetScrollThumbAlpha(const Value: Byte);
    procedure SetScrollThumbHoverAlpha(const Value: Byte);
    procedure SetScrollStyle(const Value: TCWSScrollStyle);
    procedure SetScrollbarRenderMode(const Value: TCWSScrollbarRenderMode);

    { The cursor entered this box, or ANY control nested in it — TControl walks
      the notification up the parent chain, which makes this the one signal that
      reliably means "the mouse is inside now" whatever it is standing on. }
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure WMTimer(var Msg: TWMTimer); message WM_TIMER;
    procedure CMControlChange(var Msg: TCMControlChange); message CM_CONTROLCHANGE;
    procedure CMControlListChange(var Msg: TMessage); message CM_CONTROLLISTCHANGE;
    procedure CMCwsRelayout(var Msg: TMessage); message CM_CWS_RELAYOUT;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMVScroll(var Msg: TWMVScroll); message WM_VSCROLL;
    procedure WMHScroll(var Msg: TWMHScroll); message WM_HSCROLL;
    { The border is a real NON-CLIENT frame so ClientWidth/Height exclude it in
      BOTH design time and runtime — anchored children therefore use the same
      reference rectangle in the designer and at runtime. }
    procedure WMNCCalcSize(var Msg: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMNCPaint(var Msg: TWMNCPaint); message WM_NCPAINT;
    { Design-time native scrolling. At design time user controls are direct
      children of the scrollbox (so the IDE nests them correctly); they are
      scrolled with real OS scrollbars. Runtime uses the overlay bars. }
    procedure UpdateDesignScrollInfo;
    procedure DesignScrollTo(NewX, NewY: Integer);
  protected
    { See TCWSScrollContent.FPainting — the box is the backdrop host at DESIGN
      time, where the user's controls are its own children. }
    FPainting: Boolean;
    function GetChildParent: TComponent; override;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure PaintWindow(DC: HDC); override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure Loaded; override;
    procedure Resize; override;
    procedure Paint; override;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure WriteState(Writer: TWriter); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;

    function Scale(V: Integer): Integer;
    function ViewWidth: Integer;
    function ViewHeight: Integer;
    function MaxOffsetX: Integer;
    function MaxOffsetY: Integer;
    function VScrollNeeded: Boolean;
    function HScrollNeeded: Boolean;

    procedure SetOffsetX(Value: Integer);
    procedure SetOffsetY(Value: Integer);
    procedure ScrollTo(AX, AY: Integer);
    procedure ScrollInView(AControl: TControl);
    procedure RecalcContent;
    { Recompose the overlay scrollbars. Call it after something repainted the
      content behind the component's back — a VCL style change, a manual repaint
      of a child — so the antialiased ends pick up the new pixels. BackgroundColor
      and the bar's own properties do it themselves. }
    procedure RefreshScrollbars;

    { ContentPanel — host for controls added at RUNTIME.
      Example:  Button.Parent := ScrollBox.ContentPanel; }
    property ContentPanel: TCWSScrollContent read FContent;
    property OffsetX: Integer read FOffsetX;
    property OffsetY: Integer read FOffsetY;
    property ContentWidth: Integer read FContentW;
    property ContentHeight: Integer read FContentH;
  published
    property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor default clWhite;
    property BorderColor: TColor read FBorderColor write SetBorderColor default $D6D6D6;
    property ShowBorder: Boolean read FShowBorder write SetShowBorder default True;
    property ScrollThumbColor: TColor read FScrollThumbColor write SetScrollThumbColor default $C0C0C0;
    property ScrollThumbHoverColor: TColor read FScrollThumbHoverColor write SetScrollThumbHoverColor default $909090;
    property ScrollbarAreaWidth: Integer read FScrollbarAreaWidth write SetScrollbarAreaWidth default 14;
    property ScrollbarThumbWidth: Integer read FScrollbarThumbWidth write SetScrollbarThumbWidth default 4;
    property ScrollbarThumbHoverWidth: Integer read FScrollbarThumbHoverWidth write SetScrollbarThumbHoverWidth default 6;
    property ScrollThumbAlpha: Byte read FScrollThumbAlpha write SetScrollThumbAlpha default 150;
    property ScrollThumbHoverAlpha: Byte read FScrollThumbHoverAlpha write SetScrollThumbHoverAlpha default 225;
    property WheelStep: Integer read FWheelStep write FWheelStep default 48;
    property ScrollStyle: TCWSScrollStyle read FScrollStyle write SetScrollStyle default cssBoth;
    { How the bar is composed on screen — see TCWSScrollbarRenderMode. }
    property ScrollbarRenderMode: TCWSScrollbarRenderMode read FScrollbarRenderMode
      write SetScrollbarRenderMode default srmShaped;
    property OnScroll: TNotifyEvent read FOnScroll write FOnScroll;

    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

implementation

const
  cThumbMinLen = 24;              { minimum thumb length (px @96 dpi) }
  cTrackMargin = 2;               { track end margin (px @96 dpi) }
  { The lane hover tracker (see TCWSScrollBox.StartLaneTracking). The interval is
    not set by how fast the eye needs the thumb to thicken — it is set by the
    CLICK: in srmShaped the lane only becomes clickable once the tracker has
    noticed the cursor on it (ShapeIsWide), so this is the window in which a fast
    "move and press" would land on the content instead of on the scrollbar. A
    tick is one GetCursorPos, one WindowFromPoint and two rectangle tests, and it
    only runs while the cursor is inside the box, so buying that margin costs
    nothing worth measuring. }
  cLaneTrackTimerId  = $C5B0;
  cLaneTrackInterval = 30;        { ms }
  { How often, in tracker ticks, a bar whose antialiased ends were composed
    against CONTENT re-reads that content.
    It has to be a poll. The ends carry a trace of the pixels under them, so they
    go stale when a control there redraws — and a control redrawing is not an
    event this component can be told about: measured on TCWSStoreButton, the
    repaint goes through Repaint/UpdateWindow, which sends WM_PAINT straight to
    the window without ever passing through the message queue, so no filter can
    see it. The poll only runs while the cursor is inside the box (that is the
    tracker's whole lifetime), and only bars that actually overlap content do any
    work, so the usual answer is a rectangle test and nothing else. }
  cLaneBackdropTicks = 5;         { ≈150 ms }

{ Distance from a pixel centre to the thumb's spine — the thumb is a capsule (a
  rounded rect whose radius is half its thickness), so "within radius of the
  spine" describes it exactly, and the fractional part gives the coverage that
  antialiases the rounded ends. }
function DistToSpine(PX, PY, X1, Y1, X2, Y2: Single): Single;
var
  DX, DY, T: Single;
begin
  DX := X2 - X1;
  DY := Y2 - Y1;
  if (DX = 0) and (DY = 0) then
    T := 0
  else
  begin
    T := ((PX - X1) * DX + (PY - Y1) * DY) / (DX * DX + DY * DY);
    if T < 0 then T := 0 else if T > 1 then T := 1;
  end;
  Result := Sqrt(Sqr(PX - (X1 + T * DX)) + Sqr(PY - (Y1 + T * DY)));
end;

{ Draw the antialiased thumb capsule AThumb into a top-down 32-bit buffer whose
  rows are ABufW pixels apart and which holds ABufH rows, touching no pixel
  outside AClip.

  The BODY of the thumb is OPAQUE — nothing shows through it. AAlpha does not
  make the bar see-through: it mixes AColor into ABack (the scrollbox background)
  ONCE, up front, and that single solid colour is what the capsule is filled
  with. This is the WinUI 3 bar: solid, only its ends soft.

  What is blended per pixel is COVERAGE. Along the rounded ends a pixel is only
  fractionally inside the capsule, and such a pixel is resolved against WHATEVER
  THE BUFFER ALREADY HOLDS. Hand it a buffer filled with the flat background and
  the result is bit for bit what a flat-background blend gives; hand it the pixels
  that really lie under the bar (CaptureBackdrop) and the rounded ends stay smooth
  over an image or a nested control instead of trailing a background-coloured
  crescent. Both are the same code path — only the buffer differs.

  Pixels the capsule does not touch are left as they were, so the caller decides
  what the surroundings are. }
procedure RenderCapsule(ABits: PByte; ABufW, ABufH: Integer; const AThumb: TRect;
  AVertical: Boolean; AColor: TColor; AAlpha: Byte; ABack: TColor;
  const AClip: TRect);
var
  X, Y, LoX, HiX, LoY, HiY: Integer;
  Row: PByte;
  Rad, X1, Y1, X2, Y2, Cov: Single;
  ForeCol, BackCol: Cardinal;
  CR, CG, CB, A: Single;
begin
  if AThumb.IsEmpty or (ABits = nil) or AClip.IsEmpty then
    Exit;
  ForeCol := ColorToRGB(AColor);
  BackCol := ColorToRGB(ABack);
  { The one and only place AAlpha is used: the thumb's own, fully opaque colour. }
  A := AAlpha / 255;
  CR := GetRValue(ForeCol) * A + GetRValue(BackCol) * (1 - A);
  CG := GetGValue(ForeCol) * A + GetGValue(BackCol) * (1 - A);
  CB := GetBValue(ForeCol) * A + GetBValue(BackCol) * (1 - A);
  if AVertical then
  begin
    Rad := AThumb.Width / 2;
    X1 := AThumb.Left + Rad;
    X2 := X1;
    Y1 := AThumb.Top + Rad;
    Y2 := AThumb.Bottom - Rad;
  end
  else
  begin
    Rad := AThumb.Height / 2;
    Y1 := AThumb.Top + Rad;
    Y2 := Y1;
    X1 := AThumb.Left + Rad;
    X2 := AThumb.Right - Rad;
  end;
  if Y2 < Y1 then Y2 := Y1;
  if X2 < X1 then X2 := X1;
  { One pixel of slack around the capsule: that ring is where coverage is
    fractional, and it is exactly what makes the ends look round. Everything is
    kept inside AClip as well — outside it the buffer holds pixels from an older
    paint, and blending into those would smear a stale backdrop across the bar. }
  LoX := Max(Max(0, AClip.Left), AThumb.Left - 1);
  HiX := Min(Min(ABufW - 1, AClip.Right - 1), AThumb.Right);
  LoY := Max(Max(0, AClip.Top), AThumb.Top - 1);
  HiY := Min(Min(ABufH - 1, AClip.Bottom - 1), AThumb.Bottom);
  for Y := LoY to HiY do
  begin
    Row := ABits + (Y * ABufW + LoX) * 4;
    for X := LoX to HiX do
    begin
      Cov := Rad - DistToSpine(X + 0.5, Y + 0.5, X1, Y1, X2, Y2) + 0.5;
      if Cov > 0 then
      begin
        if Cov > 1 then Cov := 1;
        { Row[] is the backdrop — the flat background or the real content. }
        Row[0] := Round(CB * Cov + Row[0] * (1 - Cov));
        Row[1] := Round(CG * Cov + Row[1] * (1 - Cov));
        Row[2] := Round(CR * Cov + Row[2] * (1 - Cov));
        Row[3] := 255;
      end;
      Inc(Row, 4);
    end;
  end;
end;

{ ===================== TCWSScrollContent ==================================== }

constructor TCWSScrollContent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csOpaque];
  { Design time: FContent is invisible and unused as a parent — remove
    csAcceptsControls so the IDE designer never drops controls onto it.
    Without this, TGraphicControls (TLabel, TShape …) land on the hidden
    FContent and become invisible / unselectable in the form designer. }
  if (AOwner <> nil) and (csDesigning in AOwner.ComponentState) then
    ControlStyle := ControlStyle - [csAcceptsControls];
  { NOT the VCL's DoubleBuffered — WMPaint below buffers the same picture, but in
    a bitmap the size of the UPDATE rectangle instead of the whole client area.
    ParentDoubleBuffered has to go too, or the scrollbox would hand its own
    setting back to us. }
  ParentDoubleBuffered := False;
  DoubleBuffered := False;
end;

procedure TCWSScrollContent.CreateParams(var Params: TCreateParams);
begin
  inherited;
  { WS_CLIPCHILDREN — the host doesn't paint under child windows, so
    the background under controls doesn't flicker while scrolling. }
  Params.Style := Params.Style or WS_CLIPCHILDREN;
end;

procedure TCWSScrollContent.AlignControls(AControl: TControl; var Rect: TRect);
begin
  inherited;
  { Change of child layout/size → recalc the scrollbox content size.
    Skipped while loading from .dfm — TCWSScrollBox.Loaded handles it. }
  if (FScrollBox <> nil) and not (csLoading in ComponentState) then
    FScrollBox.RecalcContent;
end;

procedure TCWSScrollContent.Paint;
begin
  Canvas.Brush.Style := bsSolid;
  if FScrollBox <> nil then
    Canvas.Brush.Color := FScrollBox.BackgroundColor
  else
    Canvas.Brush.Color := clWhite;
  { ClipRect, not ClientRect: this window is as tall as the CONTENT, and a scroll
    step only ever invalidates a band of it. Filling the whole thing would make
    every wheel tick cost the full content area. }
  Canvas.FillRect(Canvas.ClipRect);
end;

procedure TCWSScrollContent.PaintWindow(DC: HDC);
begin
  FPainting := True;
  try
    inherited;
  finally
    FPainting := False;
  end;
end;

procedure TCWSScrollContent.WMPaint(var Msg: TWMPaint);
var
  PS: TPaintStruct;
  DC, MemDC: HDC;
  Bmp, OldBmp: HBITMAP;
  W, H: Integer;
begin
  { Someone else's DC (a parent painting us, PrintWindow, …) — nothing to buffer. }
  if Msg.DC <> 0 then
  begin
    inherited;
    Exit;
  end;
  DC := BeginPaint(Handle, PS);
  try
    W := PS.rcPaint.Right - PS.rcPaint.Left;
    H := PS.rcPaint.Bottom - PS.rcPaint.Top;
    if (W <= 0) or (H <= 0) then
      Exit;
    MemDC := CreateCompatibleDC(DC);
    if MemDC = 0 then
      Exit;
    try
      Bmp := CreateCompatibleBitmap(DC, W, H);
      if Bmp = 0 then
        Exit;
      OldBmp := SelectObject(MemDC, Bmp);
      try
        { Drawing happens in CLIENT coordinates (Paint, and every graphic child
          the VCL renders through PaintControls), while the buffer covers only
          the update rectangle — so move the DC's origin instead of translating
          every drawing call. The clip on top of it is what makes the VCL skip
          graphic controls outside the band: PaintControls tests each one with
          RectVisible, so a scroll no longer redraws every image in the box. }
        SetWindowOrgEx(MemDC, PS.rcPaint.Left, PS.rcPaint.Top, nil);
        IntersectClipRect(MemDC, PS.rcPaint.Left, PS.rcPaint.Top,
          PS.rcPaint.Right, PS.rcPaint.Bottom);
        Msg.DC := MemDC;
        inherited;                    { paints self + graphic children }
        Msg.DC := 0;
        BitBlt(DC, PS.rcPaint.Left, PS.rcPaint.Top, W, H,
          MemDC, PS.rcPaint.Left, PS.rcPaint.Top, SRCCOPY);
      finally
        SelectObject(MemDC, OldBmp);
        DeleteObject(Bmp);
      end;
    finally
      DeleteDC(MemDC);
    end;
  finally
    EndPaint(Handle, PS);
  end;
  { The bars float above this window and their rounded ends are composed against
    the pixels underneath, so content that repaints under one of them leaves it
    showing a stale fringe. This is what carries a light/dark theme switch
    through to the scrollbars without anyone having to tell them the colours
    changed. It cannot loop: the bar reads us back through WM_PRINTCLIENT, which
    never arrives here. }
  if FScrollBox <> nil then
    FScrollBox.NotifyContentPainted(PS.rcPaint);
  Msg.Result := 0;
end;

procedure TCWSScrollContent.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;   { background painted in Paint — avoid double paint }
end;

{ ===================== TCWSScrollOverlay ==================================== }

constructor TCWSScrollOverlay.CreateOverlay(AScrollBox: TCWSScrollBox;
  AKind: TCWSScrollKind);
begin
  inherited Create(AScrollBox);
  FScrollBox := AScrollBox;
  FKind := AKind;
  ControlStyle := ControlStyle + [csOpaque];
  { PaintCapsule composes into its own DIB and blits the result in one go, so the
    VCL's buffer would only be a second copy of the same picture. }
  ParentDoubleBuffered := False;
  DoubleBuffered := False;
  Width := 14;
  Height := 14;
end;

destructor TCWSScrollOverlay.Destroy;
begin
  FreeBuffer;
  inherited;
end;

function TCWSScrollOverlay.LaneTracked: Boolean;
begin
  Result := (FScrollBox <> nil) and FScrollBox.FLaneTracking;
end;

function TCWSScrollOverlay.RenderMode: TCWSScrollbarRenderMode;
begin
  if FScrollBox <> nil then
    Result := FScrollBox.ScrollbarRenderMode
  else
    Result := srmShaped;
end;

procedure TCWSScrollOverlay.EnsureBuffer(AW, AH: Integer);
var
  Info: TBitmapInfo;
begin
  if (AW <= 0) or (AH <= 0) then
    Exit;
  if (FBufBits <> nil) and (FBufW = AW) and (FBufH = AH) then
    Exit;
  FreeBuffer;
  FBufDC := CreateCompatibleDC(0);
  if FBufDC = 0 then
    Exit;
  FillChar(Info, SizeOf(Info), 0);
  Info.bmiHeader.biSize := SizeOf(TBitmapInfoHeader);
  Info.bmiHeader.biWidth := AW;
  Info.bmiHeader.biHeight := -AH;            { top-down }
  Info.bmiHeader.biPlanes := 1;
  Info.bmiHeader.biBitCount := 32;
  Info.bmiHeader.biCompression := BI_RGB;
  FBufBits := nil;
  FBufBmp := CreateDIBSection(FBufDC, Info, DIB_RGB_COLORS, Pointer(FBufBits), 0, 0);
  if (FBufBmp = 0) or (FBufBits = nil) then
  begin
    FreeBuffer;
    Exit;
  end;
  FBufOldBmp := SelectObject(FBufDC, FBufBmp);
  FBufW := AW;
  FBufH := AH;
end;

procedure TCWSScrollOverlay.FreeBuffer;
begin
  if FBufDC <> 0 then
  begin
    if FBufOldBmp <> 0 then
      SelectObject(FBufDC, FBufOldBmp);
    DeleteDC(FBufDC);
  end;
  if FBufBmp <> 0 then
    DeleteObject(FBufBmp);
  FBufDC := 0;
  FBufBmp := 0;
  FBufOldBmp := 0;
  FBufBits := nil;
  FBufW := 0;
  FBufH := 0;
end;

function TCWSScrollOverlay.ThumbColorNow: TColor;
begin
  if FHot or FDragging then
    Result := FScrollBox.ScrollThumbHoverColor
  else
    Result := FScrollBox.ScrollThumbColor;
end;

function TCWSScrollOverlay.ThumbAlphaNow: Byte;
begin
  if FHot or FDragging then
    Result := FScrollBox.ScrollThumbHoverAlpha
  else
    Result := FScrollBox.ScrollThumbAlpha;
end;

function TCWSScrollOverlay.StripLen: Integer;
begin
  if FKind = skVertical then
    Result := FStrip.Height
  else
    Result := FStrip.Width;
end;

function TCWSScrollOverlay.StripCross: Integer;
begin
  if FKind = skVertical then
    Result := FStrip.Width
  else
    Result := FStrip.Height;
end;

function TCWSScrollOverlay.TrackLength: Integer;
var
  M: Integer;
begin
  M := MulDiv(cTrackMargin, CurrentPPI, 96);
  Result := StripLen - FEndInset - 2 * M;
end;

procedure TCWSScrollOverlay.CreateWnd;
begin
  inherited;
  FShapeW := -1;        { the fresh window carries no region yet }
  FShapeH := -1;
  FPaintedThumb := TRect.Empty;   { and no pixels either }
  FPaintedFlatBack := False;      { so the first refresh really composes }
  RecalcThumb;
  if RenderMode = srmShaped then
    ApplyShape(True);
  { The freshly (re)created window has no region yet — invalidate the cache so
    ApplyDesignRegion below actually re-applies it instead of short-circuiting. }
  FHasDesignRgn := False;
  if csDesigning in ComponentState then
    ApplyDesignRegion;
end;

procedure TCWSScrollOverlay.ApplyDesignRegion;
var
  Rgn: HRGN;
  Dia: Integer;
  Want: TRect;
  WholeStrip: Boolean;
begin
  if not (csDesigning in ComponentState) or not HandleAllocated then
    Exit;
  { What the designer must show depends on the render mode, so that switching
    ScrollbarRenderMode is visible right there in the form designer:
      srmShaped  — only the rounded thumb is opaque, the track is clipped away
                   and the content shows through it, which IS what runtime does
                   (there the window itself is clipped to the capsule);
      srmBlended — the WHOLE strip belongs to the bar (no clipping) because that
                   is what runtime paints: an opaque track in BackgroundColor,
                   including the corner square between the two bars.
    A bar that is not needed is clipped to nothing in BOTH modes — the window
    itself stays visible so the IDE never leaves a ghost behind. }
  WholeStrip := (RenderMode = srmBlended) and not FThumbRect.IsEmpty;
  if WholeStrip then
    Want := ClientRect
  else
    Want := FThumbRect;
  { Skip the SetWindowRgn churn when nothing changed — a per-keystroke relayout
    (e.g. editing Label.Caption) would otherwise re-clip the window on every
    character for no visual change. }
  if FHasDesignRgn and EqualRect(Want, FLastDesignThumb) then
    Exit;
  if WholeStrip then
    SetWindowRgn(Handle, 0, True)                 { no clipping at all }
  else
  begin
    if Want.IsEmpty then
      Rgn := CreateRectRgn(0, 0, 0, 0)            { nothing visible — content shows through }
    else
    begin
      if FKind = skVertical then Dia := Want.Width else Dia := Want.Height;
      if Dia < 2 then Dia := 2;
      { Same one pixel of slack at the ends as ApplyShape reserves at runtime, so
        the antialiased fringe of the capsule survives the clip here too. }
      Rgn := CreateRoundRectRgn(
        Want.Left   - IfThen(FKind = skHorizontal, 1, 0),
        Want.Top    - IfThen(FKind = skVertical,   1, 0),
        Want.Right  + IfThen(FKind = skHorizontal, 1, 0) + 1,
        Want.Bottom + IfThen(FKind = skVertical,   1, 0) + 1, Dia, Dia);
    end;
    if SetWindowRgn(Handle, Rgn, True) = 0 then
      DeleteObject(Rgn);
  end;
  FLastDesignThumb := Want;
  FHasDesignRgn := True;
end;

procedure TCWSScrollOverlay.SetBarBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  NewStrip: TRect;
begin
  NewStrip := Rect(ALeft, ATop, ALeft + AWidth, ATop + AHeight);
  { Design time (and the handle-less window) always take the plain path: there
    the window really is the whole lane, region-clipped to the thumb for the
    preview by ApplyDesignRegion. }
  if (csDesigning in ComponentState) or not HandleAllocated then
  begin
    FStrip := NewStrip;
    SetBounds(ALeft, ATop, AWidth, AHeight);
    Exit;
  end;
  if EqualRect(NewStrip, FStrip) then
    Exit;
  FStrip := NewStrip;
  RecalcThumb;
  if RenderMode = srmShaped then
    { The lane moved, so the thumb inside it moved too — one SetWindowPos on a
      small ordinary window, composed with the parent like every other child. }
    ApplyShape(False)
  else
  begin
    { The window IS the lane. A resize does not necessarily invalidate all of it
      (Windows blits what it can keep), which would leave the old thumb behind —
      so repaint the strip whole. Lane changes are a layout event, not a scroll
      step, so this costs nothing per frame. }
    SetBounds(ALeft, ATop, AWidth, AHeight);
    if HandleAllocated then
    begin
      FPaintedThumb := TRect.Empty;
      InvalidateRect(Handle, nil, False);
    end;
  end;
end;

procedure TCWSScrollOverlay.ApplyShape(AForce: Boolean);
var
  R: TRect;
  Dia: Integer;
  Rgn: HRGN;
  Resized: Boolean;
begin
  if (csDesigning in ComponentState) or not HandleAllocated or
     FThumbRect.IsEmpty then
    Exit;
  { FThumbRect is in strip coordinates; the window lives in the box's client
    coordinates, so shift it onto the lane. }
  R := FThumbRect;
  R.Offset(FStrip.Left, FStrip.Top);
  { One pixel of room at BOTH ENDS — and only there. That is where the capsule's
    arcs are, and the pixels the arcs cover only fractionally are what makes a
    rounded end look round instead of stepped; a region that ended exactly at the
    capsule would clip them all away (it cuts at roughly half coverage). Across
    the bar the capsule's straight sides are already pixel-aligned, so widening
    there would only draw a BackgroundColor hairline down the whole thumb.
    The thumb is centred in the lane, so the window is exactly the capsule plus
    that slack — symmetric, with nothing reaching out to the edge of the box.

    The window is NEVER grown to the whole lane, not even while the pointer is on
    it. It was, for a while, to make the lane clickable — and that is exactly how
    a plain window covers content: the pixels it hides are a SNAPSHOT, so a
    control repainting underneath (a button losing its hover, a spinner turning)
    kept showing its old self inside the strip. Lane clicks are caught before
    they are dispatched instead (TCWSScrollBox.LaneAppMessage), which needs no
    pixels at all. }
  if FKind = skVertical then
    R.Inflate(0, 1)
  else
    R.Inflate(1, 0);
  Resized := (R.Width <> Width) or (R.Height <> Height);
  SetBounds(R.Left, R.Top, R.Width, R.Height);
  { A window region is expressed in window coordinates and does NOT follow a
    resize — it has to be rebuilt whenever the size changes. It does follow a
    MOVE, though, which is why scrolling (thumb slides, size constant) costs
    nothing but the SetBounds above. }
  if (FShapeW <> R.Width) or (FShapeH <> R.Height) then
  begin
    if FKind = skVertical then Dia := R.Width else Dia := R.Height;
    if Dia < 2 then Dia := 2;
    Rgn := CreateRoundRectRgn(0, 0, R.Width + 1, R.Height + 1, Dia, Dia);
    if SetWindowRgn(Handle, Rgn, True) = 0 then
      DeleteObject(Rgn)
    else
    begin
      FShapeW := R.Width;
      FShapeH := R.Height;
    end;
  end;
  { A pure MOVE needs no repaint at all: the window's pixels travel with it and
    the capsule looks the same wherever the thumb sits. This is the scroll path,
    so that saved WM_PAINT — and the repaint of the content it uncovers — is the
    whole point of srmShaped. Only a resize (hover thickness, a shorter thumb) or
    a change of colour/opacity really needs new pixels.

    …and one more thing: the antialiased ends carry a trace of what lies UNDER
    them, so they only travel unchanged while that is flat background. A thumb
    moving onto content — or off it, still carrying the fringe it was composed
    against — has to be recomposed. Both tests are a walk over the host's direct
    children, and the usual answer (nothing under the bar, nothing under it
    before) costs one intersection each and leaves the fast path intact. }
  if AForce or Resized or (FPaintedHot <> (FHot or FDragging)) or
     (not FPaintedFlatBack) or (not BackdropIsFlat(BoundsRect)) then
    InvalidateRect(Handle, nil, False);
end;

procedure TCWSScrollOverlay.InvalidateThumbArea(AForce: Boolean);
var
  R: TRect;
begin
  if AForce or FPaintedThumb.IsEmpty or FThumbRect.IsEmpty or
     (FPaintedHot <> (FHot or FDragging)) then
  begin
    InvalidateRect(Handle, nil, False);
    Exit;
  end;
  if EqualRect(FPaintedThumb, FThumbRect) then
    Exit;                       { the lane already shows exactly this thumb }
  { Where the thumb was plus where it is going — everything else in the lane is
    flat BackgroundColor and already correct. One pixel of slack for the
    antialiased fringe around the capsule. }
  UnionRect(R, FPaintedThumb, FThumbRect);
  R.Inflate(1, 1);
  InvalidateRect(Handle, @R, False);
end;

function TCWSScrollOverlay.BackdropHost(out AOrgX, AOrgY: Integer): TWinControl;
begin
  AOrgX := 0;
  AOrgY := 0;
  Result := nil;
  if FScrollBox = nil then
    Exit;
  if csDesigning in ComponentState then
    { Design time: FContent is hidden and empty — the user's controls are direct
      children of the scrollbox, so the box itself is what lies under the bar. }
    Result := FScrollBox
  else
    Result := FScrollBox.FContent;
  if (Result = nil) or not Result.HandleAllocated then
  begin
    Result := nil;
    Exit;
  end;
  { Where the host's client origin sits in the box's client coordinates. The
    content host is the SCROLLED window, so this is exactly minus the offset —
    which is what makes the captured pixels follow the content as it moves. }
  if Result <> FScrollBox then
  begin
    AOrgX := Result.Left;
    AOrgY := Result.Top;
  end;
end;

function TCWSScrollOverlay.BackdropIsFlat(const ABoxArea: TRect): Boolean;
var
  Host: TWinControl;
  OrgX, OrgY, I: Integer;
  C: TControl;
  R, Tmp: TRect;
begin
  Result := True;
  Host := BackdropHost(OrgX, OrgY);
  if Host = nil then
    Exit;
  { Only the host's own children are tested: anything nested deeper is inside its
    parent's rectangle (and clipped to it), so a miss here is a miss there too. }
  for I := 0 to Host.ControlCount - 1 do
  begin
    C := Host.Controls[I];
    if (C = FScrollBox.FContent) or (C = FScrollBox.FVScroll) or
       (C = FScrollBox.FHScroll) then
      Continue;
    if not C.Visible then
      Continue;
    R := C.BoundsRect;
    R.Offset(OrgX, OrgY);
    if IntersectRect(Tmp, R, ABoxArea) then
      Exit(False);
  end;
end;

function TCWSScrollOverlay.CaptureBackdrop(const AArea: TRect): Boolean;
var
  Host: TWinControl;
  OrgX, OrgY, VX, VY, I, Saved: Integer;
  C: TControl;
  WC: TWinControl;
  Rgn: HRGN;
  HostArea, R, Tmp: TRect;
  SavedOrg: TPoint;
begin
  Result := False;
  if (FBufDC = 0) or AArea.IsEmpty then
    Exit;
  Host := BackdropHost(OrgX, OrgY);
  if Host = nil then
    Exit;
  { A host that is drawing itself right now must not be asked to draw again — it
    paints through a single, non-reentrant canvas, and the nested paint would
    close it under the outer one. Giving up costs this one paint its backdrop:
    the caller keeps the flat background it already filled in, which is exactly
    what the bar used to be composed against. }
  if ((Host = FScrollBox) and FScrollBox.FPainting) or
     ((Host is TCWSScrollContent) and TCWSScrollContent(Host).FPainting) then
    Exit;
  { A point of OUR client area sits at (Left + P) in the box, hence at
    (Left + P - AOrg) in the host. Drawing happens in the host's own coordinates,
    so shift the DC's origin by minus that instead of translating every call. }
  VX := OrgX - Left;
  VY := OrgY - Top;
  HostArea := AArea;
  HostArea.Offset(-VX, -VY);
  { The clip is what bounds the cost: it is set in DEVICE (buffer) coordinates,
    before the origin moves, and it is what makes the VCL skip every graphic
    control outside the strip (PaintControls tests each one with RectVisible). }
  Rgn := CreateRectRgn(AArea.Left, AArea.Top, AArea.Right, AArea.Bottom);
  try
    SelectClipRgn(FBufDC, Rgn);
  finally
    DeleteObject(Rgn);
  end;
  try
    SetViewportOrgEx(FBufDC, VX, VY, @SavedOrg);
    try
      { The host paints itself and its GRAPHIC children (images, labels, shapes)
        in one go. WM_PRINTCLIENT, not WM_PAINT: it never touches BeginPaint, so
        this cannot disturb the host's own update region — and it does not come
        back through TCWSScrollContent.WMPaint, so there is no paint loop. }
      SendMessage(Host.Handle, WM_PRINTCLIENT, WPARAM(FBufDC), PRF_CLIENT);
      { Windowed children own their pixels and have to be asked one by one. We do
        the walk ourselves instead of letting DefWindowProc recurse with
        PRF_CHILDREN: at design time the host IS the scrollbox, and its children
        include these very overlay windows — printing those would recurse into
        the bar that is painting. Skipping the ones that do not intersect keeps
        this proportional to what is actually under the thumb, not to how much
        sits in the box. }
      for I := 0 to Host.ControlCount - 1 do
      begin
        C := Host.Controls[I];
        if (C = FScrollBox.FContent) or (C = FScrollBox.FVScroll) or
           (C = FScrollBox.FHScroll) then
          Continue;
        if not (C is TWinControl) then
          Continue;                 { graphic control — already printed above }
        WC := TWinControl(C);
        if not WC.Visible or not WC.HandleAllocated then
          Continue;
        R := WC.BoundsRect;
        if not IntersectRect(Tmp, R, HostArea) then
          Continue;
        { BoundsRect is the WINDOW rectangle, so the origin goes to the window's
          top left and PRF_NONCLIENT can draw the control's frame where it
          belongs. Each child gets the DC handed back exactly as it was: this is
          third-party code drawing into our buffer, and one control that leaves a
          narrowed clip behind would silently swallow every control after it. }
        Saved := SaveDC(FBufDC);
        try
          SetViewportOrgEx(FBufDC, VX + R.Left, VY + R.Top, nil);
          SendMessage(WC.Handle, WM_PRINT, WPARAM(FBufDC),
            PRF_CLIENT or PRF_NONCLIENT or PRF_CHILDREN or PRF_ERASEBKGND);
        finally
          RestoreDC(FBufDC, Saved);
        end;
      end;
    finally
      SetViewportOrgEx(FBufDC, SavedOrg.X, SavedOrg.Y, nil);
    end;
  finally
    SelectClipRgn(FBufDC, 0);
  end;
  Result := True;
end;

procedure TCWSScrollOverlay.BeginLanePress(const AScreenPt: TPoint);
var
  P: TPoint;
begin
  if FThumbRect.IsEmpty or not HandleAllocated then
    Exit;
  P := FScrollBox.ScreenToClient(AScreenPt);
  P.Offset(-FStrip.Left, -FStrip.Top);        { → strip coordinates }
  if OnThumb(P.X, P.Y) then
  begin
    { Beside the thumb: the same drag MouseDown would have started, set up by
      hand because the press never reached a window of ours. Taking the capture
      is what makes the rest of it ordinary — the moves and the release are
      delivered here, and the VCL drops the capture on the button up. }
    FDragging := True;
    if FKind = skVertical then
      FDragStart := P.Y
    else
      FDragStart := P.X;
    FDragStartOffset := FScrollBox.AxisOffset(FKind);
    MouseCapture := True;
    RecalcThumb;
    RefreshBar;
  end
  else
    JumpToPoint(P.X, P.Y);                    { on the track — jump }
end;

procedure TCWSScrollOverlay.BackdropChanged(const ABoxArea: TRect);
var
  Mine, Tmp: TRect;
begin
  if not HandleAllocated or (csDesigning in ComponentState) or
     (RenderMode <> srmShaped) or FThumbRect.IsEmpty then
    Exit;
  Mine := BoundsRect;
  if not IntersectRect(Tmp, Mine, ABoxArea) then
    Exit;
  { A repaint of the flat background under a bar that was composed against that
    same flat background changes nothing — and content repaints are frequent
    enough that this test is worth making. }
  if FPaintedFlatBack and BackdropIsFlat(Tmp) then
    Exit;
  InvalidateRect(Handle, nil, False);
end;

procedure TCWSScrollOverlay.PaintCapsule(const AThumb: TRect);
var
  Upd, Cap, Tmp: TRect;
  W, H, X, Y: Integer;
  Px: PCardinal;
  Back, BGRBack: Cardinal;
  Flat: Boolean;
begin
  W := ClientWidth;
  H := ClientHeight;
  if (W <= 0) or (H <= 0) then
    Exit;
  { Compose the whole client area in the buffer but touch only the part that is
    actually invalid — in srmBlended a scroll step invalidates just the two thumb
    rectangles (InvalidateThumbArea), so the rest of the lane is neither refilled
    nor blitted. }
  if not IntersectRect(Upd, Canvas.ClipRect, Rect(0, 0, W, H)) then
    Exit;
  EnsureBuffer(W, H);
  if FBufBits = nil then
    Exit;
  { The base field. In srmBlended this IS the track the bar paints, and it is the
    finished picture; in srmShaped it is only a fallback for the fringe, replaced
    below by the real pixels wherever they matter. }
  Back := ColorToRGB(FScrollBox.BackgroundColor);
  BGRBack := ((Back and $FF) shl 16) or (Back and $FF00) or
             ((Back shr 16) and $FF);
  for Y := Upd.Top to Upd.Bottom - 1 do
  begin
    Px := PCardinal(FBufBits + (Y * W + Upd.Left) * 4);
    for X := Upd.Left to Upd.Right - 1 do
    begin
      Px^ := BGRBack;
      Inc(Px);
    end;
  end;

  { srmShaped owns no track: outside the capsule there must be NOTHING, so every
    pixel the capsule covers only fractionally has to be blended into what really
    lies under it. Otherwise those pixels — the rounded ends — come out in
    BackgroundColor and read as a pale crescent wherever the bar passes over an
    image or a nested control.
    Only the ring around the capsule can show the backdrop, so that ring is all
    we fetch; and while there is nothing but flat background under it, we fetch
    nothing at all and the scroll path stays a pure window move. }
  Flat := True;
  if RenderMode = srmShaped then
  begin
    Cap := AThumb;
    { Two pixels of ring is all the capsule's fringe can reach. }
    Cap.Inflate(2, 2);
    if IntersectRect(Tmp, Cap, Upd) then
    begin
      Cap := Tmp;
      Tmp.Offset(Left, Top);                { → the box's client coordinates }
      if not BackdropIsFlat(Tmp) then
        Flat := not CaptureBackdrop(Cap);   { failed capture → keep the flat base }
    end;
  end;

  RenderCapsule(FBufBits, W, H, AThumb, FKind = skVertical,
    ThumbColorNow, ThumbAlphaNow, FScrollBox.BackgroundColor, Upd);
  BitBlt(Canvas.Handle, Upd.Left, Upd.Top, Upd.Width, Upd.Height,
    FBufDC, Upd.Left, Upd.Top, SRCCOPY);
  FPaintedFlatBack := Flat;
end;

procedure TCWSScrollOverlay.RefreshBar(AForce: Boolean);
begin
  if not HandleAllocated or (csDesigning in ComponentState) then
    Exit;
  if RenderMode = srmShaped then
    ApplyShape(AForce)            { the window IS the thumb — move it }
  else
    InvalidateThumbArea(AForce);  { the window is the lane — repaint the thumb }
end;

procedure TCWSScrollOverlay.SetHot(Value: Boolean);
begin
  if FHot = Value then
    Exit;
  FHot := Value;
  RecalcThumb;           { thumb thickness and opacity changed }
  RefreshBar;
end;

procedure TCWSScrollOverlay.RecalcThumb;
var
  M, TrackLen, ThumbLen, ThumbThick, MaxOff, Off, Pos, Cross: Integer;
  ViewLen, ContentLen, CrossDim: Integer;
begin
  M := MulDiv(cTrackMargin, CurrentPPI, 96);
  TrackLen := TrackLength;
  if FKind = skVertical then
  begin
    ViewLen    := FScrollBox.ViewHeight;
    ContentLen := FScrollBox.ContentHeight;
    MaxOff     := FScrollBox.MaxOffsetY;
  end
  else
  begin
    ViewLen    := FScrollBox.ViewWidth;
    ContentLen := FScrollBox.ContentWidth;
    MaxOff     := FScrollBox.MaxOffsetX;
  end;
  Off := FScrollBox.AxisOffset(FKind);   { design or runtime offset }

  { No thumb when there is nothing to scroll (content fits the view). At runtime
    the overlay is simply not Visible then; at design time it stays visible but
    region-clipped to nothing (ApplyDesignRegion). }
  if (ContentLen <= 0) or (TrackLen <= 0) or (ContentLen <= ViewLen) then
  begin
    FThumbRect := TRect.Empty;
    Exit;
  end;

  ThumbLen := Round(TrackLen * (ViewLen / ContentLen));
  ThumbLen := Max(MulDiv(cThumbMinLen, CurrentPPI, 96), ThumbLen);
  ThumbLen := Min(ThumbLen, TrackLen);

  if MaxOff > 0 then
    Pos := M + Round((Off / MaxOff) * (TrackLen - ThumbLen))
  else
    Pos := M;
  Pos := Max(M, Min(M + TrackLen - ThumbLen, Pos));

  if FHot or FDragging then
    ThumbThick := MulDiv(FScrollBox.ScrollbarThumbHoverWidth, CurrentPPI, 96)
  else
    ThumbThick := MulDiv(FScrollBox.ScrollbarThumbWidth, CurrentPPI, 96);
  if ThumbThick < 2 then
    ThumbThick := 2;

  { The thumb is CENTRED across the lane — the same margin on both sides of it,
    whatever ScrollbarAreaWidth is — so it reads as a bar floating in its track
    rather than something pinned to the edge of the box.
    Centring exactly needs the lane and the thumb to have the SAME PARITY: with
    an odd difference between them the true centre falls half a pixel off the
    grid, and since the thumb grows on hover (ScrollbarThumbWidth →
    ScrollbarThumbHoverWidth) that half pixel would land on one side one moment
    and on the other the next — the thumb would look like it twitches sideways
    as the mouse enters. Nudging the thickness up by one when the parities
    disagree pins the centre line for BOTH thicknesses, so hover grows the thumb
    symmetrically. At the default 14/4/6 (and every whole DPI scale of it) the
    parities already agree and nothing is nudged. }
  CrossDim := StripCross;
  if ThumbThick > CrossDim then
    ThumbThick := Max(1, CrossDim);
  if Odd(CrossDim - ThumbThick) and (ThumbThick < CrossDim) then
    Inc(ThumbThick);
  Cross := Max(0, (CrossDim - ThumbThick) div 2);
  if FKind = skVertical then
    FThumbRect := Rect(Cross, Pos, Cross + ThumbThick, Pos + ThumbLen)
  else
    FThumbRect := Rect(Pos, Cross, Pos + ThumbLen, Cross + ThumbThick);
end;

procedure TCWSScrollOverlay.Paint;
var
  R: TRect;
begin
  { Both modes draw the same picture — an antialiased capsule over a
    BackgroundColor field — at a rectangle that differs per mode:

      srmShaped (runtime)   the window IS the thumb, so the capsule fills the
                            client area; the window region cuts the corners away
                            and the content stays visible around it;
      srmBlended (runtime)  the window is the whole lane: the field IS the opaque
                            track and the capsule sits at FThumbRect in it;
      design time           the window is the lane too, and ApplyDesignRegion
                            either leaves it whole (srmBlended) or clips it to
                            the capsule (srmShaped), so the same drawing previews
                            both modes.

    The one fringe pixel around the capsule is what turns a stepped rounded end
    into a smooth one; what it is blended into is decided in PaintCapsule — the
    real pixels under the bar where they matter, the flat background otherwise. }
  if FThumbRect.IsEmpty then
    Exit;                       { nothing to scroll — nothing to draw }
  { Remember what the window now shows, so the next refresh knows whether it has
    to repaint anything and, in srmBlended, how little. }
  FPaintedThumb := FThumbRect;
  FPaintedHot := FHot or FDragging;
  if not (csDesigning in ComponentState) and (RenderMode = srmShaped) then
  begin
    { The window IS the thumb, plus the one pixel ApplyShape reserved at each end
      for the antialiased fringe — so the capsule itself is the client area
      shortened by exactly that, and it spans the full thickness of the window. }
    R := ClientRect;
    if FKind = skVertical then
      R.Inflate(0, -1)
    else
      R.Inflate(-1, 0);
    PaintCapsule(R);
  end
  else
    PaintCapsule(FThumbRect);   { the window is the lane }
end;

procedure TCWSScrollOverlay.JumpToPoint(X, Y: Integer);
var
  M, TrackLen, ThumbLen, MaxOff, Coord, Target: Integer;
begin
  M := MulDiv(cTrackMargin, CurrentPPI, 96);
  TrackLen := TrackLength;
  if FKind = skVertical then
  begin
    Coord    := Y;
    ThumbLen := FThumbRect.Height;
    MaxOff   := FScrollBox.MaxOffsetY;
  end
  else
  begin
    Coord    := X;
    ThumbLen := FThumbRect.Width;
    MaxOff   := FScrollBox.MaxOffsetX;
  end;
  if (TrackLen - ThumbLen) <= 0 then
    Exit;
  { move so the thumb center lands under the cursor }
  Target := Round(((Coord - M - ThumbLen / 2) / (TrackLen - ThumbLen)) * MaxOff);
  FScrollBox.ScrollAxisTo(FKind, Target);
end;

function TCWSScrollOverlay.ToStrip(X, Y: Integer): TPoint;
begin
  { In srmBlended the window IS the strip, so this is the identity.
    In srmShaped the window is only the thumb AND a drag moves it under the
    cursor — window-local coordinates would then stand still and the drag would
    go nowhere. Going through the box's client area gives an absolute position
    that the moving window cannot skew. }
  Result := ClientToParent(Point(X, Y), FScrollBox);
  Result.Offset(-FStrip.Left, -FStrip.Top);
end;

function TCWSScrollOverlay.OnThumb(X, Y: Integer): Boolean;
begin
  { Hit-test only the scroll axis — the thumb is thinner than the track and
    centred across it, so the cross-axis position is irrelevant once the cursor
    is inside the overlay window. X/Y are strip coordinates (ToStrip). }
  if FThumbRect.IsEmpty then
    Exit(False);
  if FKind = skVertical then
    Result := (Y >= FThumbRect.Top) and (Y < FThumbRect.Bottom)
  else
    Result := (X >= FThumbRect.Left) and (X < FThumbRect.Right);
end;

procedure TCWSScrollOverlay.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  P: TPoint;
begin
  inherited;
  if (Button <> mbLeft) or FThumbRect.IsEmpty then
    Exit;
  P := ToStrip(X, Y);
  if OnThumb(P.X, P.Y) then
  begin
    FDragging := True;
    if FKind = skVertical then
      FDragStart := P.Y
    else
      FDragStart := P.X;
    FDragStartOffset := FScrollBox.AxisOffset(FKind);
    RecalcThumb;
    RefreshBar;
  end
  else
    JumpToPoint(P.X, P.Y);   { click on the track — jump }
end;

procedure TCWSScrollOverlay.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  TrackLen, ThumbLen, MaxOff, Coord, Delta, NewOff: Integer;
  P: TPoint;
begin
  inherited;
  if not FDragging then
    Exit;
  TrackLen := TrackLength;
  P := ToStrip(X, Y);
  if FKind = skVertical then
  begin
    Coord    := P.Y;
    ThumbLen := FThumbRect.Height;
    MaxOff   := FScrollBox.MaxOffsetY;
  end
  else
  begin
    Coord    := P.X;
    ThumbLen := FThumbRect.Width;
    MaxOff   := FScrollBox.MaxOffsetX;
  end;
  if (TrackLen - ThumbLen) <= 0 then
    Exit;
  Delta  := Coord - FDragStart;
  NewOff := FDragStartOffset + Round((Delta / (TrackLen - ThumbLen)) * MaxOff);
  FScrollBox.ScrollAxisTo(FKind, NewOff);
end;

procedure TCWSScrollOverlay.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if not FDragging then
    Exit;
  FDragging := False;
  { The drag is over, so the hot state goes back to being about where the cursor
    is. With the lane tracked that question is about the whole LANE, not just
    this window — reading the window instead would drop the thumb to its thin
    state for one tick and grow it again as soon as the tracker caught up.
    FHot is set directly and the refresh done unconditionally: FDragging itself
    just changed, and the thumb's thickness and colour are drawn from
    (FHot or FDragging), so the bar needs redrawing even when FHot did not move. }
  if LaneTracked then
    FHot := PtInRect(FStrip, ClientToParent(Point(X, Y), FScrollBox))
  else
    FHot := PtInRect(ClientRect, Point(X, Y));
  RecalcThumb;
  RefreshBar;
end;

procedure TCWSScrollOverlay.CMMouseEnter(var Msg: TMessage);
begin
  inherited;
  Hot := True;
end;

procedure TCWSScrollOverlay.CMMouseLeave(var Msg: TMessage);
begin
  inherited;
  { While the box tracks the lane it decides when the bar stops being hot. In
    srmShaped this window is only the THUMB, so sliding the cursor off the thumb
    while staying in the lane raises a leave here — clearing the hot state on it
    would shrink the thumb, the tracker would light it again on its next tick,
    and the bar would blink between its two thicknesses as the mouse moves. }
  if not FDragging and not LaneTracked then
    Hot := False;
end;

procedure TCWSScrollOverlay.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

{ ===================== TCWSScrollBox ======================================== }

constructor TCWSScrollBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csOpaque];
  Width  := 320;
  Height := 240;

  FBackgroundColor        := clWhite;
  { Keep the control's Color in sync with BackgroundColor so that child
    controls with ParentColor = True (and GetParentBgColor, which reads
    Parent.Brush.Color) blend with the scrollbox background instead of the
    form's color. }
  Color                   := FBackgroundColor;
  FBorderColor            := $D6D6D6;
  FShowBorder             := True;
  FScrollThumbColor       := $C0C0C0;
  FScrollThumbHoverColor  := $909090;
  FScrollbarAreaWidth     := 14;
  FScrollbarThumbWidth    := 4;
  FScrollbarThumbHoverWidth := 6;
  FScrollThumbAlpha       := 150;
  FScrollThumbHoverAlpha  := 225;
  FWheelStep              := 48;
  FScrollStyle            := cssBoth;
  FScrollbarRenderMode    := srmShaped;

  { Create FContent in the constructor (before the IDE runs hit-test on
    control drop) — it fills the area and is the topmost window,
    so dropped controls naturally land on it. }
  FContent := TCWSScrollContent.Create(Self);
  FContent.FScrollBox := Self;
  FContent.Parent := Self;
  FContent.Color := FBackgroundColor;   { children inherit the scrollbox background }
  FContent.SetBounds(0, 0, Width, Height);

  { Create overlays after FContent → they are higher in z-order (on top). }
  FVScroll := TCWSScrollOverlay.CreateOverlay(Self, skVertical);
  FVScroll.Parent := Self;
  FVScroll.Visible := False;

  FHScroll := TCWSScrollOverlay.CreateOverlay(Self, skHorizontal);
  FHScroll.Parent := Self;
  FHScroll.Visible := False;
end;

{ --- streaming: user controls belong to FContent --------------------------- }

function TCWSScrollBox.GetChildParent: TComponent;
begin
  { Children stream onto the scrollbox itself (both design and runtime) so the
    IDE nests them under TCWSScrollBox AND, at runtime, their anchor rules are
    captured against the scrollbox's real (design) client size. Loaded then
    reparents them into FContent once it has been sized to the view, so the
    anchor reference does not change and an [akLeft,akTop,akRight] control keeps
    its design width. (Previously runtime children went straight into FContent,
    whose transient constructor size 320 became the anchor reference — stretching
    such controls at runtime.) }
  Result := inherited GetChildParent;
end;

procedure TCWSScrollBox.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  I, J: Integer;
  C: TControl;
  List: array of TControl;
  Keys: array of Integer;
  TmpC: TControl;
  TmpK: Integer;

  procedure AddCtrl(AC: TControl; ALogicalTop: Integer);
  begin
    SetLength(List, Length(List) + 1);
    SetLength(Keys, Length(Keys) + 1);
    List[High(List)] := AC;
    Keys[High(Keys)] := ALogicalTop;
  end;

begin
  { For .dfm streaming we report ALL user controls — both those already on
    FContent (normal state) and those the IDE designer dropped directly on the
    scrollbox (FContent isn't a component registered on the form, so the
    designer's hit-test can pick Self instead of FContent). We skip the three
    internal controls — they must not appear in the .dfm. On load GetChildParent
    returns FContent, so runtime always has controls on the correct host.

    The controls are emitted SORTED top-to-bottom by their LOGICAL Top, not in
    the raw (drop-order, type-grouped) Controls[] order. alTop controls derive
    their on-screen stacking purely from Top; streaming them in that same visual
    order keeps the .dfm child list (and the IDE Structure pane) matching what you
    see, and makes reloads order-stable. Self children are un-scrolled by the
    design offset so the key is the logical position even when the box is
    scrolled at design time (during WriteState the offset is already 0). }
  if FContent <> nil then
    for I := 0 to FContent.ControlCount - 1 do
    begin
      C := FContent.Controls[I];
      if C.Owner = Root then
        AddCtrl(C, C.Top);
    end;
  for I := 0 to ControlCount - 1 do
  begin
    C := Controls[I];
    if (C <> FContent) and (C <> FVScroll) and (C <> FHScroll) and
       (C.Owner = Root) then
      AddCtrl(C, C.Top + FDesignOffsetY);
  end;

  { Stable insertion sort by logical Top (small N, design-time streaming only). }
  for I := 1 to High(List) do
  begin
    TmpC := List[I];
    TmpK := Keys[I];
    J := I - 1;
    while (J >= 0) and (Keys[J] > TmpK) do
    begin
      List[J + 1] := List[J];
      Keys[J + 1] := Keys[J];
      Dec(J);
    end;
    List[J + 1] := TmpC;
    Keys[J + 1] := TmpK;
  end;

  for I := 0 to High(List) do
    Proc(List[I]);
end;

procedure TCWSScrollBox.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_CLIPCHILDREN;
  { No native scrollbars — neither at runtime nor at design time. The overlay
    scrollbars float ABOVE the content in both modes and reserve no client
    width/height, so the layout arranged in the designer matches runtime
    exactly. Design-time scrolling uses the mouse wheel and the overlay thumb. }
end;

procedure TCWSScrollBox.CreateWnd;
begin
  inherited;
  FRelayoutPending := False;   { any posted relayout for the old HWND is moot now }
  FDsgnLayoutInit := False;    { force one overlay re-front on the new HWND }
  FOverlayZOK := False;        { runtime: raise the bars once on the new HWND }
  FHasContentClip := False;    { the fresh FContent window carries no region }
  UpdateLayout;
end;

procedure TCWSScrollBox.DestroyWnd;
begin
  { The timer belongs to the HWND and would die with it anyway, but the flag must
    not survive it — a stale one would keep the bars from clearing their own hot
    state and would stop the tracker from re-arming on the new handle. }
  StopLaneTracking;
  FHasContentClip := False;    { the region goes away with the handle }
  inherited;
end;

procedure TCWSScrollBox.Loaded;
var
  I, J: Integer;
  C: TControl;
  ToMove: array of TControl;
  { DESIGN geometry of each ToMove control, captured BEFORE reparenting. The
    reparent below peels the controls off Self one by one, and each RemoveControl
    re-aligns the survivors — so their live Left/Top get dragged around mid-batch.
    We restore these captured, distinct design positions after the batch so the
    final alignment re-flows every band from the correct geometry. }
  DLeft, DTop, DWidth, DHeight: array of Integer;

begin
  inherited;
  { RUNTIME: move user controls that streamed onto the scrollbox into FContent
    (the scrolled host). Children stay on Self during loading (GetChildParent +
    the csLoading guard in CMControlChange) so that the reparent below — done
    only AFTER FContent has been sized to the view — captures their anchor rules
    against the correct host width. DESIGN TIME: leave them as direct children of
    the scrollbox so the IDE keeps listing them under TCWSScrollBox. }
  if not (csDesigning in ComponentState) then
  begin
    { Size FContent to the visible view BEFORE reparenting, so the VCL captures
      each child's anchor rules (akRight / akBottom margins) against the correct
      host size. Otherwise FContent is still at its constructor default
      (320x240); an [akLeft,akTop,akRight] child then anchors against the wrong
      width and stretches at runtime. }
    FContent.SetBounds(0, 0,
      Max(0, Width - 2 * BorderSize), Max(0, Height - 2 * BorderSize));
    { Move the user controls into FContent so the runtime stack matches the
      designer. Two pitfalls are handled:
        a) reparenting one control at a time runs FContent's alignment after each
           'Parent :=', re-flowing the stack mid-batch — so we wrap the whole
           batch in DisableAlign/EnableAlign and align exactly once at the end;
        b) at runtime VCL stacks an aligned band STRICTLY BY POSITION
           (Vcl.Controls TWinControl.AlignControls -> InsertBefore: alTop by Top,
           alLeft by Left, alRight by right edge). The control-list / Z-order is
           irrelevant except to break exact ties — and BringToFront does NOT even
           reorder a windowed control in the list DoAlign walks
           (TWinControl.SetZOrderPosition reorders FWinControls, not FControls),
           which is why the windowed edits/combos/memos grouped apart from the
           graphic labels. So instead of touching Z-order we restore each child's
           captured design geometry after the batch; the single EnableAlign pass
           then re-flows each band from those correct, distinct positions, in
           exactly the design order.
      The controls are sorted ascending by their incoming (design) Top first so
      reparenting happens top-to-bottom. Result: existing forms render correctly
      without being re-saved. }
    SetLength(ToMove, 0);
    for I := 0 to ControlCount - 1 do
    begin
      C := Controls[I];
      if (C <> FContent) and (C <> FVScroll) and (C <> FHScroll) then
      begin
        SetLength(ToMove, Length(ToMove) + 1);
        ToMove[High(ToMove)] := C;
      end;
    end;
    { stable insertion sort ASCENDING by Top → intended top-to-bottom order }
    for I := 1 to High(ToMove) do
    begin
      C := ToMove[I];
      J := I - 1;
      while (J >= 0) and (ToMove[J].Top > C.Top) do
      begin
        ToMove[J + 1] := ToMove[J];
        Dec(J);
      end;
      ToMove[J + 1] := C;
    end;

    { Snapshot the DESIGN geometry now — still intact, BEFORE the reparent loop
      below starts removing controls from Self and collapsing the survivors. }
    SetLength(DLeft, Length(ToMove));
    SetLength(DTop, Length(ToMove));
    SetLength(DWidth, Length(ToMove));
    SetLength(DHeight, Length(ToMove));
    for I := 0 to High(ToMove) do
    begin
      DLeft[I]   := ToMove[I].Left;
      DTop[I]    := ToMove[I].Top;
      DWidth[I]  := ToMove[I].Width;
      DHeight[I] := ToMove[I].Height;
    end;

    FContent.DisableAlign;
    try
      for I := 0 to High(ToMove) do
        ToMove[I].Parent := FContent;
      { Restore each child's captured DESIGN geometry, undoing any collapse the
        peel-off reparent caused. This is what makes the order correct on every
        axis: the single EnableAlign re-flow below orders each aligned band purely
        by position (alTop by Top, alLeft by Left, alRight by right edge), so once
        the distinct design positions are back, the bands re-flow in exactly the
        designer order. Bands the box does NOT re-flow (alRight / alBottom are
        excluded from RecalcBounding to avoid a width/height feedback loop) simply
        keep their correct design placement — which is why we must NOT re-stamp
        them onto a synthetic left-/top-based scale (that left alRight children
        stuck at the left edge instead of flush right). }
      for I := 0 to High(ToMove) do
        ToMove[I].SetBounds(DLeft[I], DTop[I], DWidth[I], DHeight[I]);
    finally
      FContent.EnableAlign;
    end;
    FOverlayZOK := False;   { children were reparented — raise the bars once }
  end;
  UpdateLayout;
end;

{ --- metrics --------------------------------------------------------------- }

function TCWSScrollBox.Scale(V: Integer): Integer;
begin
  Result := MulDiv(V, CurrentPPI, 96);
end;

function TCWSScrollBox.BorderSize: Integer;
begin
  if FShowBorder then
    Result := Scale(1)
  else
    Result := 0;
end;

function TCWSScrollBox.AxisOffset(AKind: TCWSScrollKind): Integer;
begin
  if csDesigning in ComponentState then
  begin
    if AKind = skVertical then Result := FDesignOffsetY else Result := FDesignOffsetX;
  end
  else
  begin
    if AKind = skVertical then Result := FOffsetY else Result := FOffsetX;
  end;
end;

procedure TCWSScrollBox.ScrollAxisTo(AKind: TCWSScrollKind; Value: Integer);
begin
  if csDesigning in ComponentState then
  begin
    if AKind = skVertical then
      DesignScrollTo(FDesignOffsetX, Value)
    else
      DesignScrollTo(Value, FDesignOffsetY);
  end
  else
  begin
    if AKind = skVertical then SetOffsetY(Value) else SetOffsetX(Value);
  end;
end;

function TCWSScrollBox.ViewWidth: Integer;
begin
  { The border is non-client (WM_NCCALCSIZE), so ClientWidth already excludes it.
    BUT ClientWidth is a cached value that is only refreshed on WM_SIZE — while
    the control has no handle yet (during .dfm loading) it is stale at the
    constructor default. Using it then would size FContent to a wrong width and
    capture anchored children's reference size against it (an [akLeft,akTop,akRight]
    control would stretch once the real handle/size arrives). Fall back to the
    geometric client width (Width minus the non-client border) until the handle
    exists. }
  if HandleAllocated then
    Result := Max(0, ClientWidth)
  else
    Result := Max(0, Width - 2 * BorderSize);
end;

function TCWSScrollBox.ViewHeight: Integer;
begin
  if HandleAllocated then
    Result := Max(0, ClientHeight)
  else
    Result := Max(0, Height - 2 * BorderSize);
end;

function TCWSScrollBox.MaxOffsetX: Integer;
begin
  Result := Max(0, FContentW - ViewWidth);
end;

function TCWSScrollBox.MaxOffsetY: Integer;
begin
  Result := Max(0, FContentH - ViewHeight);
end;

function TCWSScrollBox.VScrollNeeded: Boolean;
begin
  Result := FContentH > ViewHeight;
end;

function TCWSScrollBox.HScrollNeeded: Boolean;
begin
  Result := FContentW > ViewWidth;
end;

procedure TCWSScrollBox.RecalcBounding;
var
  W, H: Integer;

  procedure MeasureHost(Host: TWinControl; AddX, AddY: Integer);
  var
    I: Integer;
    C: TControl;
  begin
    if Host = nil then
      Exit;
    for I := 0 to Host.ControlCount - 1 do
    begin
      C := Host.Controls[I];
      if (C = FContent) or (C = FVScroll) or (C = FHScroll) then
        Continue;
      if not C.Visible then
        Continue;
      { AddX/AddY recover the LOGICAL position when the design-time view is
        scrolled (child.Left/Top are physically shifted by -FDesignOffset). }
      { A feedback loop forms ONLY along the axis on which the control
        stretches with the parent:
          alClient → W = ClientWidth and H = ClientHeight → loop in BOTH dimensions
          alTop/alBottom → W = ClientWidth (loop in W),
                           H = constant set manually          (safe in H)
          alLeft/alRight → H = ClientHeight (loop in H),
                           W = constant set manually          (safe in W)
          alNone         → both dimensions constant         (safe in both)
        So we only measure the dimension independent of the
        container size — so e.g. a series of alTop panels correctly grows
        FBoundH and the vertical scrollbar appears, while FBoundW stays 0
        (alTop panels don't affect width). }
      case C.Align of
        alNone:
          begin
            { akRight → Left or Width depends on parent width → skip W.
              akBottom → Top or Height depends on parent height → skip H.
              Only measure the axis where the control has a fixed position. }
            if not (akRight in C.Anchors) then
              W := Max(W, C.Left + AddX + C.Width);
            if not (akBottom in C.Anchors) then
              H := Max(H, C.Top + AddY + C.Height);
          end;
        alLeft:
          W := Max(W, C.Left + AddX + C.Width);
        alTop:
          H := Max(H, C.Top + AddY + C.Height);
        { alRight  — Left depends on parent width  → feedback loop, skip.
          alBottom — Top depends on parent height → feedback loop, skip.
          alClient, alCustom — both axes depend on the parent, skip. }
      end;
    end;
  end;

begin
  W := 0;
  H := 0;
  { Runtime: user controls live in FContent. Design time: they are direct
    children of the scrollbox (see GetChildParent / CMControlChange), scrolled
    by FDesignOffset — add it back to measure the logical content extent. }
  MeasureHost(FContent, 0, 0);
  if csDesigning in ComponentState then
    MeasureHost(Self, FDesignOffsetX, FDesignOffsetY);
  FBoundW := W;
  FBoundH := H;
end;

{ --- layout ---------------------------------------------------------------- }

procedure TCWSScrollBox.RecalcContent;
begin
  UpdateLayout;
end;

procedure TCWSScrollBox.QueueRelayout;
begin
  { Defer a layout refresh to the next message-loop pass instead of running it
    synchronously. Synchronous relayout calls FVScroll/FHScroll.BringToFront,
    which dispatches Z-order messages right away; when this happens while a child
    control is mid-destruction (TWinControl.RemoveControl -> AlignControl, or the
    CM_CONTROLLISTCHANGE notification) it re-enters the IDE designer, frees the
    local popup menu and fires an opRemove Notification at the half-destroyed
    control -> AV in TCustomDBGrid.Notification. Posting runs the relayout only
    after the current removal/alignment has fully unwound. The pending flag
    coalesces bursts (e.g. dragging a child) into a single relayout; if the
    handle is recreated and the posted message is lost, CreateWnd clears the flag. }
  if FRelayoutPending or (csDestroying in ComponentState) or not HandleAllocated then
    Exit;
  FRelayoutPending := True;
  PostMessage(Handle, CM_CWS_RELAYOUT, 0, 0);
end;

procedure TCWSScrollBox.UpdateLayout;
const
  cFullRedraw = RDW_INVALIDATE or RDW_ERASE or RDW_ALLCHILDREN or RDW_UPDATENOW;
var
  VW, VH, AreaW, VCorner: Integer;
  NeedV, NeedH, AllowV, AllowH: Boolean;
  WasVVisible, WasHVisible: Boolean;
  VOldRect, HOldRect: TRect;
  Designing: Boolean;
begin
  if (FContent = nil) or (csDestroying in ComponentState) or FUpdatingLayout then
    Exit;
  FUpdatingLayout := True;
  try
    Designing := csDesigning in ComponentState;
    VW := ViewWidth;
    VH := ViewHeight;

    AllowV := FScrollStyle in [cssVertical, cssBoth];
    AllowH := FScrollStyle in [cssHorizontal, cssBoth];

    RecalcBounding;
    { When scrolling on a given axis is disabled, we clamp ContentSize to
      ViewSize → MaxOffset = 0, the scrollbar never appears, and content
      sticking out of the view is clipped by the clip region. }
    if AllowH then
      FContentW := Max(VW, FBoundW)
    else
      FContentW := VW;
    if AllowV then
      FContentH := Max(VH, FBoundH)
    else
      FContentH := VH;

    if Designing then
    begin
      { DESIGN TIME — child controls are direct children of Self (so the IDE
        nests/streams them correctly) and are scrolled by DesignScrollTo. The
        internal FContent host is unused — keep it hidden and zero-sized so it
        subtracts no area from the parent DC under WS_CLIPCHILDREN. The overlay
        scrollbars (below) are shown floating above the content, exactly as at
        runtime, so the design layout matches runtime. }
      if (not FInDesignScroll) and
         ((FDesignOffsetX > Max(0, FContentW - VW)) or
          (FDesignOffsetY > Max(0, FContentH - VH))) then
        DesignScrollTo(Min(FDesignOffsetX, Max(0, FContentW - VW)),
                       Min(FDesignOffsetY, Max(0, FContentH - VH)));
      FContent.Visible := False;
      FContent.SetBounds(0, 0, 0, 0);
    end
    else
    begin
      { Derive the offsets from the position the user last scrolled to — NOT from
        the one currently in force. Clamping the current offset in place loses it
        for good the moment the view is big enough to fit the content: the offset
        goes to 0 and there is nothing left to restore it from when the view
        shrinks again. See FWantOffsetX/Y. }
      FOffsetX := Max(0, Min(FWantOffsetX, Max(0, FContentW - VW)));
      FOffsetY := Max(0, Min(FWantOffsetY, Max(0, FContentH - VH)));
      { FContent has the content size (may be larger than the view); clipping
        to the area inside the border is done by UpdateContentClip — without it
        FContent would overlap the border and hide it. }
      FContent.Visible := True;
      FContent.SetBounds(-FOffsetX, -FOffsetY, FContentW, FContentH);
      UpdateContentClip(True);
    end;

    NeedV := AllowV and (FContentH > VH);
    NeedH := AllowH and (FContentW > VW);
    AreaW := Scale(FScrollbarAreaWidth);

    { The square where the two bars meet (bottom right) belongs to NOBODY when
      both are shortened by AreaW. In srmShaped that is invisible — there is no
      track window there at all, so the content simply shows through. srmBlended
      paints an opaque strip, so the same gap reads as an empty square notched
      out of the corner. There, the vertical bar is given the FULL view height
      and owns that square (its window paints it in BackgroundColor like the rest
      of the strip); FEndInset keeps the thumb out of it, so the thumb still
      stops exactly where the horizontal bar starts. Design time gets the same
      treatment, so the designer previews what runtime will draw. }
    if (FScrollbarRenderMode = srmBlended) and NeedV and NeedH then
      VCorner := AreaW
    else
      VCorner := 0;
    FVScroll.FEndInset := VCorner;
    FHScroll.FEndInset := 0;

    if Designing then
    begin
      { DESIGN TIME: the overlay child windows ARE used so the thumb floats ON TOP
        of inner controls (BringToFront). They are kept ALWAYS visible and fixed
        over the full edge strip — only their window REGION changes (clipped to
        the rounded thumb, empty when not needed; see ApplyDesignRegion). Because
        they never hide or move, the IDE form designer leaves no "ghost", and the
        clipped-away track never covers content. }
      { SetBarBounds, not SetBounds — at design time it is the plain SetBounds
        anyway, but it is also what records the STRIP the thumb math works in. }
      FVScroll.SetBarBounds(ClientWidth - AreaW, 0, AreaW,
        VH - IfThen(NeedH, AreaW, 0) + VCorner);
      FHScroll.SetBarBounds(0, ClientHeight - AreaW,
        VW - IfThen(NeedV, AreaW, 0), AreaW);
      FVScroll.Visible := True;
      FHScroll.Visible := True;
      { Only disturb Z-order / repaint the container when the scrollbar NEED state
        actually changes (or on the first layout). A child property edit in the
        Object Inspector (e.g. typing a Label.Caption with AutoSize=True) fires a
        relayout on EVERY keystroke; calling BringToFront + Invalidate each time
        made the form designer re-select THIS container, stealing focus from the
        inplace editor after a single character. A freshly DROPPED control is
        re-fronted in CMControlChange instead. }
      if (not FDsgnLayoutInit) or (NeedV <> FDsgnNeedV) or (NeedH <> FDsgnNeedH) then
      begin
        FVScroll.BringToFront;
        FHScroll.BringToFront;
        if HandleAllocated then
          Invalidate;
      end;
      FDsgnNeedV := NeedV;
      FDsgnNeedH := NeedH;
      FDsgnLayoutInit := True;
    end
    else
    begin
      { RUNTIME: float the overlay scrollbars ABOVE the content (they reserve no
        client space), so the designer layout matches runtime. }
      WasVVisible := FVScroll.Visible;
      WasHVisible := FHScroll.Visible;
      { The rectangle to repaint when a bar disappears is the LANE it occupied,
        not the window — in srmShaped the window is only the thumb. }
      VOldRect := FVScroll.FStrip;
      HOldRect := FHScroll.FStrip;

      FVScroll.Visible := NeedV;
      if NeedV then
        { SetBarBounds, not SetBounds: the lane and the window are the same
          rectangle only in srmBlended — in srmShaped the window is the thumb
          inside that lane. }
        FVScroll.SetBarBounds(ClientWidth - AreaW, 0, AreaW,
          VH - IfThen(NeedH, AreaW, 0) + VCorner);

      FHScroll.Visible := NeedH;
      if NeedH then
        FHScroll.SetBarBounds(0, ClientHeight - AreaW,
          VW - IfThen(NeedV, AreaW, 0), AreaW);

      { Z-order churn is not free either: a SetWindowPos re-clips every sibling
        it passes. Only re-raise when something could actually have pushed the
        bars down (fresh handle, control inserted, bar just shown). }
      if (not FOverlayZOK) or (NeedV <> WasVVisible) or (NeedH <> WasHVisible) then
      begin
        FVScroll.BringToFront;
        FHScroll.BringToFront;
        FOverlayZOK := True;
      end;

      { If an overlay just disappeared, repaint the area it occupied and the
        content under it — the lane it used to cover has no window on it now. }
      if (WasVVisible and not NeedV) or (WasHVisible and not NeedH) then
      begin
        if HandleAllocated then
        begin
          if WasVVisible and not NeedV then
            InvalidateRect(Handle, @VOldRect, True);
          if WasHVisible and not NeedH then
            InvalidateRect(Handle, @HOldRect, True);
          RedrawWindow(Handle, nil, 0, cFullRedraw);
        end;
        if FContent.HandleAllocated then
          RedrawWindow(FContent.Handle, nil, 0, cFullRedraw);
      end;
    end;

    UpdateThumbs;
  finally
    FUpdatingLayout := False;
  end;
end;

procedure TCWSScrollBox.UpdateThumbs;
begin
  if csDesigning in ComponentState then
  begin
    { Design time: recompute each overlay's thumb and re-clip its window region
      to that shape (empty when the axis needs no scrollbar). }
    if FVScroll <> nil then
    begin
      FVScroll.RecalcThumb;
      FVScroll.ApplyDesignRegion;
      if FVScroll.HandleAllocated then
        InvalidateRect(FVScroll.Handle, nil, True);
    end;
    if FHScroll <> nil then
    begin
      FHScroll.RecalcThumb;
      FHScroll.ApplyDesignRegion;
      if FHScroll.HandleAllocated then
        InvalidateRect(FHScroll.Handle, nil, True);
    end;
    Exit;
  end;
  { RUNTIME. This is the per-scroll-step path: RefreshBar does the minimum the
    mode allows — a window move in srmShaped, the two thumb rectangles in
    srmBlended — so a wheel tick never costs a full redraw of a bar. }
  if (FVScroll <> nil) and FVScroll.Visible then
  begin
    FVScroll.RecalcThumb;
    FVScroll.RefreshBar;
  end;
  if (FHScroll <> nil) and FHScroll.Visible then
  begin
    FHScroll.RecalcThumb;
    FHScroll.RefreshBar;
  end;
end;

procedure TCWSScrollBox.InvalidateOverlays;

  procedure Repaint(Bar: TCWSScrollOverlay);
  begin
    if (Bar = nil) or not Bar.Visible then
      Exit;
    { RefreshBar is the runtime path and returns straight away in the designer,
      where the window is the whole lane and is simply repainted. }
    if csDesigning in ComponentState then
    begin
      if Bar.HandleAllocated then
        InvalidateRect(Bar.Handle, nil, True);
    end
    else
      Bar.RefreshBar(True);
  end;

begin
  { A property that changed how the bars LOOK — repaint them whatever their
    geometry says. The per-scroll-step path is UpdateThumbs, not this one. }
  Repaint(FVScroll);
  Repaint(FHScroll);
end;

procedure TCWSScrollBox.NotifyContentPainted(const ARect: TRect);
var
  R: TRect;
begin
  if (csDesigning in ComponentState) or (csDestroying in ComponentState) or
     (FContent = nil) then
    Exit;
  { FContent is the SCROLLED window, so its own position is the whole of the
    translation into the box's client coordinates. }
  R := ARect;
  R.Offset(FContent.Left, FContent.Top);
  if (FVScroll <> nil) and FVScroll.Visible then
    FVScroll.BackdropChanged(R);
  if (FHScroll <> nil) and FHScroll.Visible then
    FHScroll.BackdropChanged(R);
end;

procedure TCWSScrollBox.RefreshScrollbars;
begin
  InvalidateOverlays;
end;

{ --- lane hover tracking ---------------------------------------------------- }

procedure TCWSScrollBox.CMMouseEnter(var Msg: TMessage);
begin
  inherited;      { keeps the notification travelling up to OUR parent }
  StartLaneTracking;
end;

procedure TCWSScrollBox.StartLaneTracking;
var
  P: TPoint;
begin
  if FLaneTracking or (csDesigning in ComponentState) or
     (csDestroying in ComponentState) or not HandleAllocated then
    Exit;
  if SetTimer(Handle, cLaneTrackTimerId, cLaneTrackInterval, nil) = 0 then
    Exit;
  FLaneTracking := True;
  FLaneTick := 0;
  { The content may well have changed while the cursor was away — nothing was
    watching it then — so let the bars re-read it as the cursor arrives, rather
    than showing a stale fringe until the first poll comes round. }
  RefreshLaneBackdrops;
  { Armed for the whole time the cursor is in the box, not just once it reaches a
    lane: the catcher is what keeps the content under the lane from lighting up,
    and it has to see the FIRST move that crosses onto the lane. Waiting for the
    poll to notice would let a highlight flash through. }
  ArmLaneClicks;
  { …and the move that armed it was dispatched before it existed. Coming into the
    box straight onto a lane, that move has already lit the control underneath,
    so put it out now instead of leaving the highlight up until the pointer moves
    again. }
  P := Mouse.CursorPos;
  if LaneAt(P) <> nil then
    MuteLane(WindowFromPoint(P));
  { Answer this very move instead of making the cursor wait for the first tick —
    entering the box straight onto the lane should light the bar at once. }
  UpdateLaneHover;
end;

procedure TCWSScrollBox.StopLaneTracking;
begin
  if not FLaneTracking then
    Exit;
  FLaneTracking := False;
  if HandleAllocated then
    KillTimer(Handle, cLaneTrackTimerId);
  DisarmLaneClicks;
  { Hand the hot state back cleanly: with the tracker down the bars go back to
    clearing it themselves, so leave neither of them stuck lit. }
  if (FVScroll <> nil) and not FVScroll.FDragging then
    FVScroll.Hot := False;
  if (FHScroll <> nil) and not FHScroll.FDragging then
    FHScroll.Hot := False;
end;

procedure TCWSScrollBox.ArmLaneClicks;
begin
  if (FLaneEvents <> nil) or (csDesigning in ComponentState) or
     (csDestroying in ComponentState) then
    Exit;
  FLaneEvents := TApplicationEvents.Create(Self);
  FLaneEvents.OnMessage := LaneAppMessage;
end;

procedure TCWSScrollBox.DisarmLaneClicks;
begin
  FreeAndNil(FLaneEvents);
  UnmuteLane;
end;

function TCWSScrollBox.LaneAt(const AScreenPt: TPoint): TCWSScrollOverlay;
var
  P: TPoint;
begin
  Result := nil;
  if not HandleAllocated then
    Exit;
  P := ScreenToClient(AScreenPt);
  { The vertical bar wins where the two lanes meet — it is the one that owns the
    corner square when both are up. }
  if (FVScroll <> nil) and FVScroll.Visible and PtInRect(FVScroll.FStrip, P) then
    Result := FVScroll
  else if (FHScroll <> nil) and FHScroll.Visible and PtInRect(FHScroll.FStrip, P) then
    Result := FHScroll;
end;

procedure TCWSScrollBox.MuteLane(AWnd: HWND);
begin
  if FLaneMuted then
    Exit;
  FLaneMuted := True;
  if AWnd = 0 then
    Exit;
  { WM_MOUSELEAVE — the Win32 one, not CM_MOUSELEAVE. TWinControl.WndProc turns
    it into a CM_MOUSELEAVE for whatever it currently believes the mouse is on,
    AND clears that belief. Performing CM_MOUSELEAVE by hand would drop the
    highlight but leave the bookkeeping insisting the mouse is still there — and
    the control would then never light up again, because the enter is only sent
    when the tracked control CHANGES. }
  SendMessage(AWnd, WM_MOUSELEAVE, 0, 0);
end;

procedure TCWSScrollBox.RefreshLaneBackdrops;

  procedure Refresh(Bar: TCWSScrollOverlay);
  begin
    if (Bar = nil) or not Bar.Visible then
      Exit;
    { BackdropChanged does the deciding: it drops out at once for a bar that is
      not composed against content, and only marks one for repaint when its ends
      really do carry a trace of pixels that may have moved on. }
    Bar.BackdropChanged(Bar.BoundsRect);
  end;

begin
  Refresh(FVScroll);
  Refresh(FHScroll);
end;

procedure TCWSScrollBox.UnmuteLane;
begin
  { Nothing to undo: with the moves flowing again the control under the pointer
    is entered by the VCL in the ordinary way. }
  FLaneMuted := False;
end;

procedure TCWSScrollBox.LaneAppMessage(var Msg: TMsg; var Handled: Boolean);
var
  Bar: TCWSScrollOverlay;
  Wnd: HWND;
begin
  if Handled or (csDestroying in ComponentState) or not HandleAllocated then
    Exit;
  case Msg.message of
    WM_MOUSEMOVE, WM_LBUTTONDOWN, WM_LBUTTONDBLCLK: { ours to consider } ;
  else
    Exit;
  end;
  { Someone is mid-gesture and the mouse is captured — our own thumb being
    dragged, or just as likely a splitter being moved or a selection being swept
    in a memo. Every message of a captured gesture belongs to whoever holds the
    capture, wherever the pointer has wandered, so none of them may be taken or
    swallowed here. }
  if GetCapture <> 0 then
    Exit;
  { Msg.pt is where the event happened, in screen coordinates. Everything is
    re-checked here rather than trusted from the last hover tick: the pointer may
    have moved, or another window may have come up, since. The cheap test first —
    off the lane this costs one coordinate mapping and two rectangle tests, and
    mouse moves are frequent. }
  Bar := LaneAt(Msg.pt);
  if Bar = nil then
  begin
    UnmuteLane;
    Exit;
  end;
  Wnd := WindowFromPoint(Msg.pt);
  if (Wnd = 0) or not ((Wnd = Handle) or IsChild(Handle, Wnd)) then
  begin
    UnmuteLane;                 { something else is on top of the lane }
    Exit;
  end;
  { On the thumb there IS a window of ours, and it gets the message the ordinary
    way — the content underneath is covered by it and hears nothing anyway. }
  if Wnd = Bar.Handle then
  begin
    UnmuteLane;
    Exit;
  end;
  if Msg.message = WM_MOUSEMOVE then
  begin
    MuteLane(Wnd);
    Handled := True;
  end
  else
  begin
    Bar.BeginLanePress(Msg.pt);
    { Swallowed: the content under the lane must not also see this press. Note
      that this deliberately skips the focus change a click normally causes —
      pressing a scrollbar should not move focus. }
    Handled := True;
  end;
end;

procedure TCWSScrollBox.UpdateLaneHover;
var
  P: TPoint;
  Wnd: HWND;
  Inside: Boolean;

  procedure Apply(Bar: TCWSScrollOverlay);
  begin
    if (Bar = nil) or not Bar.Visible then
      Exit;
    { A drag owns the hot state until the button comes up — the cursor is allowed
      to wander far outside the lane while the thumb is being dragged. }
    if Bar.FDragging then
      Exit;
    Bar.Hot := Inside and PtInRect(Bar.FStrip, P);
  end;

begin
  if not FLaneTracking then
    Exit;
  P := Mouse.CursorPos;
  { The client rectangle alone does not mean the cursor is on US: another window
    — a modal dialog, a popup, the form being sent behind another app — can be
    over it, and the bar must not light up under something else. WindowFromPoint
    settles it for the whole tree, since the content host, its controls and the
    bars themselves are all our descendants. }
  Wnd := WindowFromPoint(P);
  Inside := (Wnd = Handle) or ((Wnd <> 0) and IsChild(Handle, Wnd));
  P := ScreenToClient(P);
  if Inside then
    Inside := PtInRect(ClientRect, P);
  Apply(FVScroll);
  Apply(FHScroll);
  { Every few ticks, let the bars re-read what lies under them. }
  Inc(FLaneTick);
  if FLaneTick >= cLaneBackdropTicks then
  begin
    FLaneTick := 0;
    if Inside then
      RefreshLaneBackdrops;
  end;
  { Nothing left to watch — the poll stops, and the catcher goes with it, until
    the cursor comes back in. }
  if not Inside then
    StopLaneTracking;
end;

procedure TCWSScrollBox.ApplyOffsets;
begin
  if FContent = nil then
    Exit;
  { The clip region FIRST, then the move. The region lives in FContent's own
    coordinates, so it travels with the window: shifting it by the new offset and
    then moving the window by minus that offset leaves the visible rectangle
    exactly where it was. Doing it in this order means the single SetWindowPos
    below does all the invalidation accounting against the FINAL clip, and the
    region change itself needs no redraw of its own — which is what keeps a wheel
    tick from repainting the entire content. }
  UpdateContentClip(False);
  { We change ONLY FContent's position (size unchanged) — a single SetWindowPos
    moves all content atomically: no flicker, and Windows blits what it can keep
    and invalidates just the band that scrolled into view. }
  FContent.SetBounds(-FOffsetX, -FOffsetY, FContentW, FContentH);
  UpdateThumbs;
  if Assigned(FOnScroll) then
    FOnScroll(Self);
end;

{ --- scrolling ------------------------------------------------------------- }

procedure TCWSScrollBox.SetOffsetX(Value: Integer);
begin
  Value := Max(0, Min(MaxOffsetX, Value));
  { A deliberate scroll — this is the position to come back to when a view that
    grew enough to swallow it shrinks again. }
  FWantOffsetX := Value;
  if Value <> FOffsetX then
  begin
    FOffsetX := Value;
    ApplyOffsets;
  end;
end;

procedure TCWSScrollBox.SetOffsetY(Value: Integer);
begin
  Value := Max(0, Min(MaxOffsetY, Value));
  FWantOffsetY := Value;
  if Value <> FOffsetY then
  begin
    FOffsetY := Value;
    ApplyOffsets;
  end;
end;

procedure TCWSScrollBox.ScrollTo(AX, AY: Integer);
var
  CX, CY: Integer;
begin
  CX := Max(0, Min(MaxOffsetX, AX));
  CY := Max(0, Min(MaxOffsetY, AY));
  FWantOffsetX := CX;
  FWantOffsetY := CY;
  if (CX = FOffsetX) and (CY = FOffsetY) then
    Exit;
  FOffsetX := CX;
  FOffsetY := CY;
  ApplyOffsets;
end;

procedure TCWSScrollBox.ScrollInView(AControl: TControl);
begin
  if (AControl = nil) or (AControl.Parent <> FContent) then
    Exit;
  if AControl.Left < FOffsetX then
    SetOffsetX(AControl.Left)
  else if AControl.Left + AControl.Width > FOffsetX + ViewWidth then
    SetOffsetX(AControl.Left + AControl.Width - ViewWidth);

  if AControl.Top < FOffsetY then
    SetOffsetY(AControl.Top)
  else if AControl.Top + AControl.Height > FOffsetY + ViewHeight then
    SetOffsetY(AControl.Top + AControl.Height - ViewHeight);
end;

function TCWSScrollBox.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
var
  Step: Integer;
begin
  Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);
  if Result then
    Exit;
  Step := Round((WheelDelta / 120) * Scale(FWheelStep));
  if csDesigning in ComponentState then
  begin
    if ssShift in Shift then
      DesignScrollTo(FDesignOffsetX - Step, FDesignOffsetY)
    else
      DesignScrollTo(FDesignOffsetX, FDesignOffsetY - Step);
    Result := True;
    Exit;
  end;
  if (ssShift in Shift) or (not VScrollNeeded and HScrollNeeded) then
    SetOffsetX(FOffsetX - Step)
  else
    SetOffsetY(FOffsetY - Step);
  Result := True;
end;

procedure TCWSScrollBox.AlignControls(AControl: TControl; var Rect: TRect);
begin
  { Design time: shift the layout rect by the scroll offset so Align-based
    children (alTop / alClient / ...) are positioned relative to the scrolled
    origin and thus scroll together with the free-placed (alNone) children. }
  if csDesigning in ComponentState then
    OffsetRect(Rect, -FDesignOffsetX, -FDesignOffsetY);
  inherited AlignControls(AControl, Rect);
  { A child was moved/resized/added/removed → refresh the native scrollbar
    ranges. Deferred (posted) so we never run UpdateLayout's BringToFront while a
    child is being removed/destroyed on this same stack — that re-entered the IDE
    designer and crashed the half-destroyed control. Guarded against reentrancy
    (DesignScrollTo / UpdateLayout already do it). }
  if (csDesigning in ComponentState) and not (csLoading in ComponentState) and
     not FInDesignScroll and not FUpdatingLayout then
    QueueRelayout;
end;

procedure TCWSScrollBox.WriteState(Writer: TWriter);
var
  OX, OY: Integer;
begin
  { Persist LOGICAL child positions: temporarily unscroll so child Left/Top
    are written without the design-time scroll offset, then restore the view. }
  if (csDesigning in ComponentState) and
     ((FDesignOffsetX <> 0) or (FDesignOffsetY <> 0)) then
  begin
    OX := FDesignOffsetX;
    OY := FDesignOffsetY;
    DesignScrollTo(0, 0);
    try
      inherited WriteState(Writer);
    finally
      DesignScrollTo(OX, OY);
    end;
  end
  else
    inherited WriteState(Writer);
end;

{ --- lifecycle / painting -------------------------------------------------- }

procedure TCWSScrollBox.Resize;
begin
  inherited;
  UpdateLayout;
  if HandleAllocated then
  begin
    { The border is a custom NON-CLIENT frame (WM_NCPAINT). When the control
      grows — most visibly with Align=alClient on a form resize — Windows blits
      the old pixels and does NOT repaint the moved right/bottom border edges, so
      they disappear. RDW_FRAME forces the whole frame to repaint with the client. }
    RedrawWindow(Handle, nil, 0, RDW_INVALIDATE or RDW_FRAME);
    { Queue a repaint of FContent's children so aligned/anchored controls
      that changed size redraw correctly.  No RDW_UPDATENOW — the
      repaint coalesces with the next WM_PAINT, so this is cheap. }
    if (FContent <> nil) and FContent.HandleAllocated then
      RedrawWindow(FContent.Handle, nil, 0,
        RDW_INVALIDATE or RDW_ALLCHILDREN);
  end;
end;

procedure TCWSScrollBox.Paint;
begin
  { Background of the client area (the border is drawn in WM_NCPAINT). At runtime
    FContent covers this; at design time it is the visible backdrop. The design-
    time scrollbar thumbs are drawn by the region-clipped overlay child windows
    (see UpdateLayout / TCWSScrollOverlay), so they float above inner controls.
    ClipRect, not ClientRect — a bar that moved off a few pixels invalidates only
    those, and there is no reason to refill the whole box for them. }
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := FBackgroundColor;
  Canvas.FillRect(Canvas.ClipRect);
end;

procedure TCWSScrollBox.PaintWindow(DC: HDC);
begin
  FPainting := True;
  try
    inherited;
  finally
    FPainting := False;
  end;
end;

procedure TCWSScrollBox.WMNCCalcSize(var Msg: TWMNCCalcSize);
var
  B: Integer;
begin
  inherited;
  { Reserve the border as non-client space → ClientWidth/Height exclude it. }
  B := BorderSize;
  if B > 0 then
    InflateRect(Msg.CalcSize_Params^.rgrc[0], -B, -B);
end;

procedure TCWSScrollBox.WMNCPaint(var Msg: TWMNCPaint);
var
  DC: HDC;
  B: Integer;
  Brush: HBRUSH;
begin
  inherited;
  if not FShowBorder then
    Exit;
  B := BorderSize;
  if B <= 0 then
    Exit;
  DC := GetWindowDC(Handle);
  try
    Brush := CreateSolidBrush(ColorToRGB(FBorderColor));
    try
      FillRect(DC, Rect(0, 0, Width, B), Brush);              { top }
      FillRect(DC, Rect(0, Height - B, Width, Height), Brush);{ bottom }
      FillRect(DC, Rect(0, 0, B, Height), Brush);             { left }
      FillRect(DC, Rect(Width - B, 0, Width, Height), Brush); { right }
    finally
      DeleteObject(Brush);
    end;
  finally
    ReleaseDC(Handle, DC);
  end;
  Msg.Result := 0;
end;

procedure TCWSScrollBox.UpdateDesignScrollInfo;
begin
  { A child was added/moved/resized in the designer → re-run the layout so the
    overlay scrollbars (shown above the content at design time too) reflect the
    new content extent and the design scroll position. The clamp for "content
    shrank while scrolled" lives in UpdateLayout's design branch. }
  if not (csDesigning in ComponentState) then
    Exit;
  UpdateLayout;
end;

procedure TCWSScrollBox.DesignScrollTo(NewX, NewY: Integer);
var
  I, dx, dy, VW, VH: Integer;
  C: TControl;
begin
  if not (csDesigning in ComponentState) then
    Exit;
  VW := ViewWidth;
  VH := ViewHeight;
  NewX := Max(0, Min(NewX, Max(0, FBoundW - VW)));
  NewY := Max(0, Min(NewY, Max(0, FBoundH - VH)));
  dx := NewX - FDesignOffsetX;
  dy := NewY - FDesignOffsetY;
  if (dx = 0) and (dy = 0) then
    Exit;

  FInDesignScroll := True;
  try
    FDesignOffsetX := NewX;
    FDesignOffsetY := NewY;
    DisableAlign;
    try
      { Free-placed (alNone) children are moved physically. }
      for I := 0 to ControlCount - 1 do
      begin
        C := Controls[I];
        if (C = FContent) or (C = FVScroll) or (C = FHScroll) then
          Continue;
        if C.Align = alNone then
          C.SetBounds(C.Left - dx, C.Top - dy, C.Width, C.Height);
      end;
    finally
      EnableAlign;
    end;
    { Align-based children (alTop/alClient/...) are NOT moved above, and
      EnableAlign only realigns when a child requested it during the disable
      window — which scrolling alNone controls does not trigger. Force a
      realign so AlignControls re-lays them out relative to the new scrolled
      origin (it offsets the layout rect by FDesignOffset). }
    Realign;
    { Move the overlay thumbs to the new design scroll position and repaint. }
    UpdateThumbs;
    if HandleAllocated then
      Invalidate;
  finally
    FInDesignScroll := False;
  end;
end;

procedure TCWSScrollBox.WMVScroll(var Msg: TWMVScroll);
var
  si: TScrollInfo;
  NewPos, LineStep: Integer;
begin
  if not (csDesigning in ComponentState) then
  begin
    inherited;
    Exit;
  end;
  FillChar(si, SizeOf(si), 0);
  si.cbSize := SizeOf(si);
  si.fMask := SIF_ALL;
  GetScrollInfo(Handle, SB_VERT, si);
  LineStep := Max(1, Scale(FWheelStep) div 2);
  NewPos := si.nPos;
  case Msg.ScrollCode of
    SB_LINEUP:        Dec(NewPos, LineStep);
    SB_LINEDOWN:      Inc(NewPos, LineStep);
    SB_PAGEUP:        Dec(NewPos, Integer(si.nPage));
    SB_PAGEDOWN:      Inc(NewPos, Integer(si.nPage));
    SB_THUMBTRACK,
    SB_THUMBPOSITION: NewPos := si.nTrackPos;
    SB_TOP:           NewPos := si.nMin;
    SB_BOTTOM:        NewPos := si.nMax;
  end;
  DesignScrollTo(FDesignOffsetX, NewPos);
  Msg.Result := 0;
end;

procedure TCWSScrollBox.WMHScroll(var Msg: TWMHScroll);
var
  si: TScrollInfo;
  NewPos, LineStep: Integer;
begin
  if not (csDesigning in ComponentState) then
  begin
    inherited;
    Exit;
  end;
  FillChar(si, SizeOf(si), 0);
  si.cbSize := SizeOf(si);
  si.fMask := SIF_ALL;
  GetScrollInfo(Handle, SB_HORZ, si);
  LineStep := Max(1, Scale(FWheelStep) div 2);
  NewPos := si.nPos;
  case Msg.ScrollCode of
    SB_LINEUP:        Dec(NewPos, LineStep);
    SB_LINEDOWN:      Inc(NewPos, LineStep);
    SB_PAGEUP:        Dec(NewPos, Integer(si.nPage));
    SB_PAGEDOWN:      Inc(NewPos, Integer(si.nPage));
    SB_THUMBTRACK,
    SB_THUMBPOSITION: NewPos := si.nTrackPos;
    SB_TOP:           NewPos := si.nMin;
    SB_BOTTOM:        NewPos := si.nMax;
  end;
  DesignScrollTo(NewPos, FDesignOffsetY);
  Msg.Result := 0;
end;

procedure TCWSScrollBox.CMControlChange(var Msg: TCMControlChange);
begin
  inherited;
  if (not Msg.Inserting) or (Msg.Control = nil) or (FContent = nil) then
    Exit;
  if (Msg.Control = FContent) or (Msg.Control = FVScroll) or
     (Msg.Control = FHScroll) then
    Exit;
  if csDestroying in ComponentState then
    Exit;
  if csDesigning in ComponentState then
  begin
    { DESIGN TIME: keep the dropped control as a direct child of the scrollbox.
      Reparenting it to FContent (owned by the component, not the form) would
      make the IDE list it under the form instead of under TCWSScrollBox.
      Just refresh the layout so the design-time scrollbar preview updates. }
    if not (csLoading in ComponentState) then
    begin
      UpdateLayout;
      { A control was just dropped onto the box — keep the design-time overlay
        thumbs above it. UpdateLayout itself no longer re-orders on every
        relayout (that stole the Object Inspector focus during property edits). }
      FVScroll.BringToFront;
      FHScroll.BringToFront;
    end;
    Exit;
  end;
  { RUNTIME: a control added directly to the scrollbox is redirected into
    FContent so it scrolls with the rest of the content. During .dfm loading we
    DEFER this to Loaded — reparenting into FContent now (while it is still at
    its transient constructor size) would capture anchored children's reference
    size against the wrong width and stretch them at runtime. }
  if csLoading in ComponentState then
    Exit;
  Msg.Control.Parent := FContent;
  FOverlayZOK := False;   { a control was inserted — raise the bars once more }
end;

procedure TCWSScrollBox.CMControlListChange(var Msg: TMessage);
var
  Ctrl: TControl;
begin
  inherited;
  { CM_CONTROLLISTCHANGE fires AFTER the control list was updated, whereas
    CM_CONTROLCHANGE (handled above) fires for a REMOVAL while the control is
    still in the list. So removal must be handled HERE: at design time, once a
    control is gone we recompute the content extent, otherwise the horizontal/
    vertical overlay scrollbar that the removed control caused never hides.
    Insertion (LParam <> 0) is already covered by CMControlChange. }
  if (csDestroying in ComponentState) or (csLoading in ComponentState) then
    Exit;
  if not (csDesigning in ComponentState) then
    Exit;
  if Msg.LParam <> 0 then                 { Inserting — handled elsewhere }
    Exit;
  Ctrl := TControl(Msg.WParam);
  if (Ctrl = FContent) or (Ctrl = FVScroll) or (Ctrl = FHScroll) then
    Exit;
  { DEFER the relayout: doing it synchronously here would run UpdateLayout (and
    its FVScroll/FHScroll.BringToFront) while the removed control is still in the
    middle of Destroy. See QueueRelayout for the full rationale. }
  QueueRelayout;
end;

procedure TCWSScrollBox.WMTimer(var Msg: TWMTimer);
begin
  if Msg.TimerID = cLaneTrackTimerId then
  begin
    UpdateLaneHover;
    Msg.Result := 0;
  end
  else
    inherited;
end;

procedure TCWSScrollBox.CMCwsRelayout(var Msg: TMessage);
begin
  FRelayoutPending := False;
  if (csDestroying in ComponentState) or (FContent = nil) then
    Exit;
  UpdateDesignScrollInfo;
end;

procedure TCWSScrollBox.UpdateContentClip(ARedraw: Boolean);
var
  Rgn: HRGN;
  Clip: TRect;
  VW, VH, ClipW, ClipH, AreaW: Integer;
  AllowV, AllowH, NeedV, NeedH: Boolean;
begin
  if (FContent = nil) or not FContent.HandleAllocated then
    Exit;
  VW := ViewWidth;
  VH := ViewHeight;
  ClipW := VW;
  ClipH := VH;
  { At design-time fake thumbs are drawn by Self.Paint in the right/bottom
    edge of the view. If we left the full FContent clip region
    (the whole view), FContent (a sibling drawn AFTER Self) would overwrite the fake
    thumbs with its background. So at design-time we clip FContent by the scrollbar
    width — visually equivalent to how the runtime overlay covers
    the right edge of the content. }
  if csDesigning in ComponentState then
  begin
    AllowV := FScrollStyle in [cssVertical, cssBoth];
    AllowH := FScrollStyle in [cssHorizontal, cssBoth];
    NeedV := AllowV and (FContentH > VH);
    NeedH := AllowH and (FContentW > VW);
    AreaW := Scale(FScrollbarAreaWidth);
    if NeedV then
      ClipW := ClipW - AreaW;
    if NeedH then
      ClipH := ClipH - AreaW;
  end;
  { The region is in FContent's local coords. FContent sits at
    (BW - FOffsetX, BW - FOffsetY) with size (FContentW, FContentH);
    we want the visible rect to cover the global area inside the
    border (BW, BW, BW+ClipW, BW+ClipH) — in local coords that gives
    (FOffsetX, FOffsetY, FOffsetX+ClipW, FOffsetY+ClipH). Without this
    clip, FContent overlaps the border strip (WS_CLIPCHILDREN on Self
    prevents overwriting the border) — the border "disappears" on scroll. }
  if (ClipW <= 0) or (ClipH <= 0) then
    Clip := TRect.Empty
  else
    Clip := Rect(FOffsetX, FOffsetY, FOffsetX + ClipW, FOffsetY + ClipH);
  if FHasContentClip and EqualRect(Clip, FContentClip) then
    Exit;                       { the window already carries exactly this region }
  Rgn := CreateRectRgn(Clip.Left, Clip.Top, Clip.Right, Clip.Bottom);
  if SetWindowRgn(FContent.Handle, Rgn, ARedraw) = 0 then
    DeleteObject(Rgn)
  else
  begin
    FContentClip := Clip;
    FHasContentClip := True;
  end;
end;

procedure TCWSScrollBox.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

{ --- setters -------------------------------------------------------------- }

procedure TCWSScrollBox.SetBackgroundColor(const Value: TColor);
begin
  if FBackgroundColor <> Value then
  begin
    FBackgroundColor := Value;
    Color := Value;                    { keep Color in sync (ParentColor children) }
    Invalidate;
    if FContent <> nil then
    begin
      FContent.Color := Value;
      FContent.Invalidate;
    end;
    { The thumb's own colour is mixed against this, and so is the fringe wherever
      there is no content under the bar — switching a form between a light and a
      dark background has to reach the bars, not just the box. }
    InvalidateOverlays;
  end;
end;

procedure TCWSScrollBox.SetBorderColor(const Value: TColor);
begin
  if FBorderColor <> Value then
  begin
    FBorderColor := Value;
    if HandleAllocated then
      RedrawWindow(Handle, nil, 0, RDW_FRAME or RDW_INVALIDATE);
  end;
end;

procedure TCWSScrollBox.SetShowBorder(const Value: Boolean);
begin
  if FShowBorder <> Value then
  begin
    FShowBorder := Value;
    { Border thickness changed → recompute the non-client area (WM_NCCALCSIZE). }
    if HandleAllocated then
      SetWindowPos(Handle, 0, 0, 0, 0, 0,
        SWP_FRAMECHANGED or SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
    UpdateLayout;
    Invalidate;
  end;
end;

procedure TCWSScrollBox.SetScrollThumbColor(const Value: TColor);
begin
  if FScrollThumbColor <> Value then
  begin
    FScrollThumbColor := Value;
    InvalidateOverlays;
  end;
end;

procedure TCWSScrollBox.SetScrollThumbHoverColor(const Value: TColor);
begin
  if FScrollThumbHoverColor <> Value then
  begin
    FScrollThumbHoverColor := Value;
    InvalidateOverlays;
  end;
end;

procedure TCWSScrollBox.SetScrollbarAreaWidth(const Value: Integer);
begin
  if FScrollbarAreaWidth <> Max(6, Value) then
  begin
    FScrollbarAreaWidth := Max(6, Value);
    UpdateLayout;
  end;
end;

procedure TCWSScrollBox.SetScrollbarThumbWidth(const Value: Integer);
begin
  if FScrollbarThumbWidth <> Max(2, Value) then
  begin
    FScrollbarThumbWidth := Max(2, Value);
    UpdateThumbs;
  end;
end;

procedure TCWSScrollBox.SetScrollbarThumbHoverWidth(const Value: Integer);
begin
  if FScrollbarThumbHoverWidth <> Max(2, Value) then
  begin
    FScrollbarThumbHoverWidth := Max(2, Value);
    UpdateThumbs;
  end;
end;

procedure TCWSScrollBox.SetScrollThumbAlpha(const Value: Byte);
begin
  if FScrollThumbAlpha <> Value then
  begin
    FScrollThumbAlpha := Value;
    InvalidateOverlays;
  end;
end;

procedure TCWSScrollBox.SetScrollThumbHoverAlpha(const Value: Byte);
begin
  if FScrollThumbHoverAlpha <> Value then
  begin
    FScrollThumbHoverAlpha := Value;
    InvalidateOverlays;
  end;
end;

procedure TCWSScrollBox.SetScrollbarRenderMode(const Value: TCWSScrollbarRenderMode);

  procedure Reload(Bar: TCWSScrollOverlay);
  begin
    if Bar = nil then
      Exit;
    if csDesigning in ComponentState then
      { Only the cached region decision has to be dropped, so ApplyDesignRegion
        re-clips (thumb only for srmShaped, whole strip for srmBlended) and the
        change is visible in the form designer straight away. }
      Bar.FHasDesignRgn := False
    else if Bar.HandleAllocated then
      { Both modes are plain child windows — nothing in CreateParams differs, so
        the window survives the switch. What does NOT survive is the srmShaped
        region: leaving that mode, the window has to become the whole lane again,
        and a leftover capsule region would clip it to a thumb-shaped sliver. }
      SetWindowRgn(Bar.Handle, 0, False);
    { Forget the strip: leaving srmShaped means the window has to grow from the
      thumb back to the whole lane, and SetBarBounds skips a strip it believes is
      already applied. The UpdateLayout below re-establishes it. }
    Bar.FStrip := TRect.Empty;
    Bar.FShapeW := -1;
    Bar.FShapeH := -1;
    Bar.FPaintedThumb := TRect.Empty;
    Bar.FPaintedFlatBack := False;
    Bar.RecalcThumb;
    if Bar.HandleAllocated then
      InvalidateRect(Bar.Handle, nil, True);
  end;

begin
  if FScrollbarRenderMode = Value then
    Exit;
  FScrollbarRenderMode := Value;
  Reload(FVScroll);
  Reload(FHScroll);
  { Re-runs the bar geometry (the corner square moves between the two modes) and,
    through UpdateThumbs, re-applies the design-time region. }
  UpdateLayout;
  if HandleAllocated then
  begin
    { A strip that was opaque and is not any more (or the other way round)
      uncovers content underneath, so repaint the box together with its children
      once. This is a property change, not a per-frame path — the full redraw
      costs nothing here. }
    RedrawWindow(Handle, nil, 0,
      RDW_INVALIDATE or RDW_ERASE or RDW_ALLCHILDREN);
    if (FContent <> nil) and FContent.HandleAllocated then
      RedrawWindow(FContent.Handle, nil, 0,
        RDW_INVALIDATE or RDW_ERASE or RDW_ALLCHILDREN);
  end;
end;

procedure TCWSScrollBox.SetScrollStyle(const Value: TCWSScrollStyle);
begin
  if FScrollStyle = Value then
    Exit;
  FScrollStyle := Value;
  { Zero out offsets in the disabled direction — otherwise after switching from
    cssBoth to cssVertical the content would stay shifted horizontally with no
    way to bring it back. }
  { The remembered position goes too, or the next layout would derive the offset
    straight back from it. }
  if not (FScrollStyle in [cssHorizontal, cssBoth]) then
  begin
    FOffsetX := 0;
    FWantOffsetX := 0;
  end;
  if not (FScrollStyle in [cssVertical, cssBoth]) then
  begin
    FOffsetY := 0;
    FWantOffsetY := 0;
  end;
  UpdateLayout;
end;

end.
