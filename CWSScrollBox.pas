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
  Vcl.Controls, Vcl.Graphics, System.UITypes;

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

  { TCWSScrollContent — internal content host. All user
    controls land here. Scrolling = moving this window. }
  TCWSScrollContent = class(TCustomControl)
  private
    FScrollBox: TCWSScrollBox;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure Paint; override;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  { TCWSScrollOverlay — overlay scrollbar (layered child window). }
  TCWSScrollOverlay = class(TCustomControl)
  private
    FScrollBox: TCWSScrollBox;
    FKind: TCWSScrollKind;
    FHot: Boolean;
    FDragging: Boolean;
    FDragStart: Integer;
    FDragStartOffset: Integer;
    FThumbRect: TRect;
    FLastDesignThumb: TRect;        { last design-time thumb rect (region cache) }
    FHasDesignRgn: Boolean;         { a design region has already been applied }
    procedure SetHot(Value: Boolean);
    procedure ApplyLayered;
    procedure JumpToPoint(X, Y: Integer);
    function OnThumb(X, Y: Integer): Boolean;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
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
    procedure RecalcThumb;
    { Design time only: clip the (always-visible, brought-to-front) overlay window
      to the rounded thumb shape — so the thumb floats ON TOP of inner controls,
      no opaque track covers content, and the window never hides/moves (no IDE
      "ghost"). Empty region when no scrollbar is needed. }
    procedure ApplyDesignRegion;
    property Hot: Boolean read FHot write SetHot;
  end;

  { TCWSScrollBox — main component. }
  TCWSScrollBox = class(TCustomControl)
  private
    FContent: TCWSScrollContent;
    FVScroll: TCWSScrollOverlay;
    FHScroll: TCWSScrollOverlay;

    FOffsetX, FOffsetY: Integer;
    FContentW, FContentH: Integer;
    FBoundW, FBoundH: Integer;
    FUpdatingLayout: Boolean;
    FRelayoutPending: Boolean;                  { a deferred (posted) relayout is queued }
    FDesignOffsetX, FDesignOffsetY: Integer;   { design-time scroll position }
    FInDesignScroll: Boolean;                   { reentrancy guard for design scroll }
    FDsgnNeedV, FDsgnNeedH: Boolean;            { last design-time scrollbar need state }
    FDsgnLayoutInit: Boolean;                   { design overlay layout ran at least once }

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

    FOnScroll: TNotifyEvent;

    procedure RecalcBounding;
    procedure UpdateLayout;
    procedure QueueRelayout;
    procedure UpdateThumbs;
    procedure ApplyOffsets;
    procedure InvalidateOverlays;
    procedure UpdateContentClip;
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
      scrolled with real OS scrollbars. Runtime uses the layered overlays. }
    procedure UpdateDesignScrollInfo;
    procedure DesignScrollTo(NewX, NewY: Integer);
  protected
    function GetChildParent: TComponent; override;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
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
  cColorKey = clFuchsia;          { color-key for track transparency }
  cThumbMinLen = 24;              { minimum thumb length (px @96 dpi) }
  cTrackMargin = 2;               { track end margin (px @96 dpi) }

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
  DoubleBuffered := True;
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
  Canvas.FillRect(ClientRect);
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
  DoubleBuffered := True;
  Width := 14;
  Height := 14;
end;

procedure TCWSScrollOverlay.CreateParams(var Params: TCreateParams);
begin
  inherited;
  { WS_EX_LAYERED only at runtime. At design-time the IDE does not trigger a full
    DWM recomposition after hiding/moving a layered child window,
    so the old scrollbar pixels stay visible even when
    FVScroll/FHScroll.Visible := False (e.g. after removing/moving
    inner controls to the left). At design-time we paint opaquely. }
  if not (csDesigning in ComponentState) then
    Params.ExStyle := Params.ExStyle or WS_EX_LAYERED;
end;

procedure TCWSScrollOverlay.CreateWnd;
begin
  inherited;
  ApplyLayered;
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
begin
  if not (csDesigning in ComponentState) or not HandleAllocated then
    Exit;
  { Skip the SetWindowRgn churn when the thumb shape is unchanged — a per-keystroke
    relayout (e.g. editing Label.Caption) would otherwise re-clip the window on
    every character for no visual change. }
  if FHasDesignRgn and EqualRect(FThumbRect, FLastDesignThumb) then
    Exit;
  if FThumbRect.IsEmpty then
    Rgn := CreateRectRgn(0, 0, 0, 0)            { nothing visible — content shows through }
  else
  begin
    if FKind = skVertical then Dia := FThumbRect.Width else Dia := FThumbRect.Height;
    if Dia < 2 then Dia := 2;
    Rgn := CreateRoundRectRgn(FThumbRect.Left, FThumbRect.Top,
      FThumbRect.Right + 1, FThumbRect.Bottom + 1, Dia, Dia);
  end;
  if SetWindowRgn(Handle, Rgn, True) = 0 then
    DeleteObject(Rgn);
  FLastDesignThumb := FThumbRect;
  FHasDesignRgn := True;
end;

procedure TCWSScrollOverlay.ApplyLayered;
var
  A: Byte;
begin
  if not HandleAllocated then
    Exit;
  { In the designer the window has no WS_EX_LAYERED — SetLayeredWindowAttributes
    would return an error. }
  if csDesigning in ComponentState then
    Exit;
  if FHot or FDragging then
    A := FScrollBox.ScrollThumbHoverAlpha
  else
    A := FScrollBox.ScrollThumbAlpha;
  { LWA_COLORKEY — pixels in color cColorKey become fully transparent
    (the scrollbox content shows through).
    LWA_ALPHA   — remaining pixels (the thumb) are dimmed to opacity A. }
  SetLayeredWindowAttributes(Handle, ColorToRGB(cColorKey), A,
    LWA_COLORKEY or LWA_ALPHA);
end;

procedure TCWSScrollOverlay.SetHot(Value: Boolean);
begin
  if FHot = Value then
    Exit;
  FHot := Value;
  ApplyLayered;          { opacity change }
  RecalcThumb;           { thumb thickness changed }
  Invalidate;
end;

procedure TCWSScrollOverlay.RecalcThumb;
var
  M, TrackLen, ThumbLen, ThumbThick, MaxOff, Off, Pos, Cross: Integer;
  ViewLen, ContentLen, CrossDim: Integer;
begin
  M := MulDiv(cTrackMargin, CurrentPPI, 96);
  if FKind = skVertical then
  begin
    ViewLen    := FScrollBox.ViewHeight;
    ContentLen := FScrollBox.ContentHeight;
    TrackLen   := Height - 2 * M;
    MaxOff     := FScrollBox.MaxOffsetY;
  end
  else
  begin
    ViewLen    := FScrollBox.ViewWidth;
    ContentLen := FScrollBox.ContentWidth;
    TrackLen   := Width - 2 * M;
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

  { Centre the thumb exactly: (CrossDim - ThumbThick) div 2 truncates, so when
    that difference is odd the thumb is biased toward the left/top and the spare
    pixel lands on the right/bottom. After DPI scaling the normal (4) and hover
    (6) widths can land on different parities than the track, so the thumb grows
    unevenly — ~2 px on the right/bottom, ~0-1 px on the other side, and the
    off-centre edge feels like it reacts late. Snapping the thickness to the
    track's cross parity makes the division exact and the hover-grow symmetric. }
  if FKind = skVertical then CrossDim := Width else CrossDim := Height;
  if Odd(CrossDim - ThumbThick) then
    Inc(ThumbThick);

  if FKind = skVertical then
  begin
    Cross := (Width - ThumbThick) div 2;
    FThumbRect := Rect(Cross, Pos, Cross + ThumbThick, Pos + ThumbLen);
  end
  else
  begin
    Cross := (Height - ThumbThick) div 2;
    FThumbRect := Rect(Pos, Cross, Pos + ThumbLen, Cross + ThumbThick);
  end;
end;

procedure TCWSScrollOverlay.Paint;
var
  R: TRect;
  Dia: Integer;
  TrackColor: TColor;
begin
  if csDesigning in ComponentState then
  begin
    { The window is region-clipped to the rounded thumb shape (ApplyDesignRegion),
      so just fill it solidly with the thumb color — the region gives the rounded
      shape and lets content show through everywhere else. }
    if FThumbRect.IsEmpty then
      Exit;
    if FHot or FDragging then
      Canvas.Brush.Color := FScrollBox.ScrollThumbHoverColor
    else
      Canvas.Brush.Color := FScrollBox.ScrollThumbColor;
    Canvas.Brush.Style := bsSolid;
    Canvas.FillRect(ClientRect);
    Exit;
  end;
  { Runtime: color-key (track fully transparent under the layer). }
  TrackColor := cColorKey;
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := TrackColor;
  Canvas.Pen.Style := psClear;
  Canvas.FillRect(ClientRect);

  if FThumbRect.IsEmpty then
    Exit;

  R := FThumbRect;
  if FKind = skVertical then
    Dia := R.Width
  else
    Dia := R.Height;
  if Dia < 2 then
    Dia := 2;

  { GDI RoundRect (no antialiasing) — no colored halo border
    that would appear from blending AA edges with the color key. }
  if FHot or FDragging then
    Canvas.Brush.Color := FScrollBox.ScrollThumbHoverColor
  else
    Canvas.Brush.Color := FScrollBox.ScrollThumbColor;
  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Color := Canvas.Brush.Color;
  Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, Dia, Dia);
end;

procedure TCWSScrollOverlay.JumpToPoint(X, Y: Integer);
var
  M, TrackLen, ThumbLen, MaxOff, Coord, Target: Integer;
begin
  M := MulDiv(cTrackMargin, CurrentPPI, 96);
  if FKind = skVertical then
  begin
    Coord    := Y;
    TrackLen := Height - 2 * M;
    ThumbLen := FThumbRect.Height;
    MaxOff   := FScrollBox.MaxOffsetY;
  end
  else
  begin
    Coord    := X;
    TrackLen := Width - 2 * M;
    ThumbLen := FThumbRect.Width;
    MaxOff   := FScrollBox.MaxOffsetX;
  end;
  if (TrackLen - ThumbLen) <= 0 then
    Exit;
  { move so the thumb center lands under the cursor }
  Target := Round(((Coord - M - ThumbLen / 2) / (TrackLen - ThumbLen)) * MaxOff);
  FScrollBox.ScrollAxisTo(FKind, Target);
end;

function TCWSScrollOverlay.OnThumb(X, Y: Integer): Boolean;
begin
  { Hit-test only the scroll axis — the thumb is thinner than the track and
    centred across it, so the cross-axis position is irrelevant once the cursor
    is inside the overlay window (which spans the whole track). }
  if FThumbRect.IsEmpty then
    Exit(False);
  if FKind = skVertical then
    Result := (Y >= FThumbRect.Top) and (Y < FThumbRect.Bottom)
  else
    Result := (X >= FThumbRect.Left) and (X < FThumbRect.Right);
end;

procedure TCWSScrollOverlay.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if (Button <> mbLeft) or FThumbRect.IsEmpty then
    Exit;
  if OnThumb(X, Y) then
  begin
    FDragging := True;
    if FKind = skVertical then
      FDragStart := Y
    else
      FDragStart := X;
    FDragStartOffset := FScrollBox.AxisOffset(FKind);
    ApplyLayered;
    Invalidate;
  end
  else
    JumpToPoint(X, Y);   { click on the track — jump }
end;

procedure TCWSScrollOverlay.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  M, TrackLen, ThumbLen, MaxOff, Coord, Delta, NewOff: Integer;
begin
  inherited;
  if not FDragging then
    Exit;
  M := MulDiv(cTrackMargin, CurrentPPI, 96);
  if FKind = skVertical then
  begin
    Coord    := Y;
    TrackLen := Height - 2 * M;
    ThumbLen := FThumbRect.Height;
    MaxOff   := FScrollBox.MaxOffsetY;
  end
  else
  begin
    Coord    := X;
    TrackLen := Width - 2 * M;
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
  if FDragging then
  begin
    FDragging := False;
    FHot := PtInRect(ClientRect, Point(X, Y));
    ApplyLayered;
    RecalcThumb;
    Invalidate;
  end;
end;

procedure TCWSScrollOverlay.CMMouseEnter(var Msg: TMessage);
begin
  inherited;
  Hot := True;
end;

procedure TCWSScrollOverlay.CMMouseLeave(var Msg: TMessage);
begin
  inherited;
  if not FDragging then
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
  UpdateLayout;
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
  VW, VH, AreaW: Integer;
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
      { clamp offsets to the new bounds }
      FOffsetX := Max(0, Min(FOffsetX, Max(0, FContentW - VW)));
      FOffsetY := Max(0, Min(FOffsetY, Max(0, FContentH - VH)));
      { FContent has the content size (may be larger than the view); clipping
        to the area inside the border is done by UpdateContentClip — without it
        FContent would overlap the border and hide it. }
      FContent.Visible := True;
      FContent.SetBounds(-FOffsetX, -FOffsetY, FContentW, FContentH);
      UpdateContentClip;
    end;

    NeedV := AllowV and (FContentH > VH);
    NeedH := AllowH and (FContentW > VW);
    AreaW := Scale(FScrollbarAreaWidth);

    if Designing then
    begin
      { DESIGN TIME: the overlay child windows ARE used so the thumb floats ON TOP
        of inner controls (BringToFront). They are kept ALWAYS visible and fixed
        over the full edge strip — only their window REGION changes (clipped to
        the rounded thumb, empty when not needed; see ApplyDesignRegion). Because
        they never hide or move, the IDE form designer leaves no "ghost", and the
        clipped-away track never covers content. No WS_EX_LAYERED at design time. }
      FVScroll.SetBounds(ClientWidth - AreaW, 0, AreaW,
        VH - IfThen(NeedH, AreaW, 0));
      FHScroll.SetBounds(0, ClientHeight - AreaW,
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
      { RUNTIME: float the layered overlay scrollbars ABOVE the content (they
        reserve no client space), so the designer layout matches runtime. }
      WasVVisible := FVScroll.Visible;
      WasHVisible := FHScroll.Visible;
      VOldRect := FVScroll.BoundsRect;
      HOldRect := FHScroll.BoundsRect;

      FVScroll.Visible := NeedV;
      if NeedV then
        FVScroll.SetBounds(ClientWidth - AreaW, 0, AreaW,
          VH - IfThen(NeedH, AreaW, 0));

      FHScroll.Visible := NeedH;
      if NeedH then
        FHScroll.SetBounds(0, ClientHeight - AreaW,
          VW - IfThen(NeedV, AreaW, 0), AreaW);

      FVScroll.BringToFront;
      FHScroll.BringToFront;

      { Belt-and-suspenders: if an overlay just disappeared, force an immediate
        repaint of the area it occupied and of FContent. Windows usually does
        this for plain child windows, but for WS_EX_LAYERED it was inconsistent. }
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
  if (FVScroll <> nil) and FVScroll.Visible then
  begin
    FVScroll.RecalcThumb;
    if FVScroll.HandleAllocated then
      InvalidateRect(FVScroll.Handle, nil, True);
  end;
  if (FHScroll <> nil) and FHScroll.Visible then
  begin
    FHScroll.RecalcThumb;
    if FHScroll.HandleAllocated then
      InvalidateRect(FHScroll.Handle, nil, True);
  end;
end;

procedure TCWSScrollBox.InvalidateOverlays;
begin
  { After moving content we force a refresh of the layered overlays
    so the transparent track shows the newly-shifted content. }
  if (FVScroll <> nil) and FVScroll.Visible and FVScroll.HandleAllocated then
    InvalidateRect(FVScroll.Handle, nil, True);
  if (FHScroll <> nil) and FHScroll.Visible and FHScroll.HandleAllocated then
    InvalidateRect(FHScroll.Handle, nil, True);
end;

procedure TCWSScrollBox.ApplyOffsets;
begin
  if FContent = nil then
    Exit;
  { We change ONLY FContent's position (size unchanged) — a single
    SetWindowPos moves all content atomically: no flicker. }
  FContent.SetBounds(-FOffsetX, -FOffsetY, FContentW, FContentH);
  { The clip region (in FContent's local coords) shifts
    along with FOffsetX/Y so the visible rect always lines up
    with the area inside the border. }
  UpdateContentClip;
  UpdateThumbs;
  InvalidateOverlays;
  if Assigned(FOnScroll) then
    FOnScroll(Self);
end;

{ --- scrolling ------------------------------------------------------------- }

procedure TCWSScrollBox.SetOffsetX(Value: Integer);
begin
  Value := Max(0, Min(MaxOffsetX, Value));
  if Value <> FOffsetX then
  begin
    FOffsetX := Value;
    ApplyOffsets;
  end;
end;

procedure TCWSScrollBox.SetOffsetY(Value: Integer);
begin
  Value := Max(0, Min(MaxOffsetY, Value));
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
    (see UpdateLayout / TCWSScrollOverlay), so they float above inner controls. }
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := FBackgroundColor;
  Canvas.FillRect(ClientRect);
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

procedure TCWSScrollBox.CMCwsRelayout(var Msg: TMessage);
begin
  FRelayoutPending := False;
  if (csDestroying in ComponentState) or (FContent = nil) then
    Exit;
  UpdateDesignScrollInfo;
end;

procedure TCWSScrollBox.UpdateContentClip;
var
  Rgn: HRGN;
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
    Rgn := CreateRectRgn(0, 0, 0, 0)
  else
    Rgn := CreateRectRgn(FOffsetX, FOffsetY,
      FOffsetX + ClipW, FOffsetY + ClipH);
  if SetWindowRgn(FContent.Handle, Rgn, True) = 0 then
    DeleteObject(Rgn);
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
    if FVScroll <> nil then FVScroll.ApplyLayered;
    if FHScroll <> nil then FHScroll.ApplyLayered;
    InvalidateOverlays;
  end;
end;

procedure TCWSScrollBox.SetScrollThumbHoverAlpha(const Value: Byte);
begin
  if FScrollThumbHoverAlpha <> Value then
  begin
    FScrollThumbHoverAlpha := Value;
    if FVScroll <> nil then FVScroll.ApplyLayered;
    if FHScroll <> nil then FHScroll.ApplyLayered;
    InvalidateOverlays;
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
  if not (FScrollStyle in [cssHorizontal, cssBoth]) then
    FOffsetX := 0;
  if not (FScrollStyle in [cssVertical, cssBoth]) then
    FOffsetY := 0;
  UpdateLayout;
end;

end.
