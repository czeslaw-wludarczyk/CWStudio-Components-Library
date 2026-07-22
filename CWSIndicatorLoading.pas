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
unit CWSIndicatorLoading;

interface

uses
  System.SysUtils, System.Classes, System.Math,
  Winapi.Windows, Winapi.Messages,
  Vcl.Controls, Vcl.Graphics, Vcl.ExtCtrls,
  Winapi.GDIPAPI, Winapi.GDIPOBJ;

type
  // Visual style of the loading indicator (same set as TCWSDimOverlay)
  TCWSLoadingStyle = (cilLines, cilRing, cilSegmented, cilArrows);

  TCWSIndicatorLoading = class(TGraphicControl)
  private
    FActive: Boolean;
    FStyle: TCWSLoadingStyle;
    FActiveColor: TColor;
    FTrackColor: TColor;
    FSegmentCount: Integer;
    FGap: Integer;
    FMargin: Integer;
    FSpeed: Integer;
    FPhase: Single;
    FTimer: TTimer;
    // Int64 (not UInt64): the tick delta is converted to Double for the
    // time-based phase. The Win32 compiler mis-converts UInt64 -> floating point
    // (the delta comes out 0 in optimized/Release builds), which froze the
    // spinner on Win32 while Win64 was fine. GetTickCount64 values fit in Int64,
    // so the signed path (FILD) is both correct and identical on 32/64-bit.
    FLastTick: Int64;
    FAccumDeg: Double;
    // scaled gap (device px) for the current Paint pass; the style drawers read
    // it so the gap keeps a constant pixel width independent of DPI
    FGapScaled: Single;

    procedure SetActive(const Value: Boolean);
    procedure SetStyle(const Value: TCWSLoadingStyle);
    procedure SetActiveColor(const Value: TColor);
    procedure SetTrackColor(const Value: TColor);
    procedure SetSegmentCount(const Value: Integer);
    procedure SetGap(const Value: Integer);
    procedure SetMargin(const Value: Integer);
    procedure SetSpeed(const Value: Integer);

    procedure UpdateAnimationState;
    procedure AnimTick(Sender: TObject);

    procedure DrawSpinner(G: TGPGraphics; ACenterX, ACenterY, ASize: Single);
    procedure DrawIndicatorLines(G: TGPGraphics; CX, CY, ASize, T: Single);
    procedure DrawIndicatorRing(G: TGPGraphics; CX, CY, ASize, T: Single);
    procedure DrawIndicatorSegmented(G: TGPGraphics; CX, CY, ASize, T: Single);
    procedure DrawIndicatorArrows(G: TGPGraphics; CX, CY, ASize, T: Single);

    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
  protected
    procedure Paint; override;
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    // convenience aliases for Active := True / False
    procedure Start;
    procedure Stop;
  published
    // True = the indicator rotates; False = it stops on a static frame
    property Active: Boolean read FActive write SetActive default True;
    property IndicatorStyle: TCWSLoadingStyle read FStyle write SetStyle default cilLines;
    // active / leading colour (the rotating "head")
    property ActiveColor: TColor read FActiveColor write SetActiveColor default $000A60D4;
    // inactive / trailing (track) colour the spinner fades toward (the "tail")
    property TrackColor: TColor read FTrackColor write SetTrackColor default $00DDDDDD;
    // number of elements (lines / blocks / arrows); ignored by cilRing
    property SegmentCount: Integer read FSegmentCount write SetSegmentCount default 12;
    // gap between elements, in logical (96 DPI) pixels; ignored by cilRing
    property Gap: Integer read FGap write SetGap default 4;
    // inset around the spinner, in logical (96 DPI) pixels
    property Margin: Integer read FMargin write SetMargin default 2;
    // rotation speed in degrees per second (300 = one full turn every 1.2 s)
    property Speed: Integer read FSpeed write SetSpeed default 300;

    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property Height;
    property Hint;
    property ParentShowHint;
    property ShowHint;
    property Visible;
    property Width;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

implementation

{ ── Colour helpers (same maths as the TCWSDimOverlay indicator) ───────────── }

{ Blend between the track colour (AFrac = 0) and the active colour (AFrac = 1),
  always fully opaque. Gives the spinner its two-tone "comet" look. }
function BlendColor(ATrack, AActive: LongInt; AFrac: Single): Cardinal;
var
  R, G, B: Byte;
begin
  if AFrac < 0 then
    AFrac := 0
  else if AFrac > 1 then
    AFrac := 1;
  R := Byte(Round(Integer(GetRValue(ATrack)) +
        (Integer(GetRValue(AActive)) - Integer(GetRValue(ATrack))) * AFrac));
  G := Byte(Round(Integer(GetGValue(ATrack)) +
        (Integer(GetGValue(AActive)) - Integer(GetGValue(ATrack))) * AFrac));
  B := Byte(Round(Integer(GetBValue(ATrack)) +
        (Integer(GetBValue(AActive)) - Integer(GetBValue(ATrack))) * AFrac));
  Result := MakeColor(255, R, G, B);
end;

{ Continuous "comet tail" brightness for element I out of N, given a fractional
  head position (0..N). Returns 1 at the head (ActiveColor), fading to ~0
  (TrackColor) along the tail that trails BEHIND the head in the direction of
  rotation. The fractional head makes the brightness change smoothly so the
  rotation is fluid rather than stepping one element per frame. }
function TrailFrac(I, N: Integer; AHeadPos: Single): Single;
var
  RelF: Single;
begin
  RelF := AHeadPos - I;                 // tail trails behind the head
  RelF := RelF - Floor(RelF / N) * N;   // wrap into [0, N)
  Result := 1 - RelF / N;
end;

{ ── TCWSIndicatorLoading ──────────────────────────────────────────────────── }

constructor TCWSIndicatorLoading.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width  := 48;
  Height := 48;

  FActive       := True;
  FStyle        := cilLines;
  FActiveColor  := $000A60D4;
  FTrackColor   := $00DDDDDD;
  FSegmentCount := 12;
  FGap          := 4;
  FMargin       := 2;
  FSpeed        := 300;
  FPhase        := 0;

  FTimer := TTimer.Create(Self);
  FTimer.Enabled  := False;
  FTimer.Interval := 16;   // ~60 fps
  FTimer.OnTimer  := AnimTick;

  UpdateAnimationState;
end;

destructor TCWSIndicatorLoading.Destroy;
begin
  FTimer.Enabled := False;
  inherited Destroy;
end;

procedure TCWSIndicatorLoading.Start;
begin
  Active := True;
end;

procedure TCWSIndicatorLoading.Stop;
begin
  Active := False;
end;

{ Run the timer only when actually rotating, visible and at run time. At design
  time the indicator is drawn as a static frame so it does not spin in the IDE. }
procedure TCWSIndicatorLoading.UpdateAnimationState;
var
  Run: Boolean;
begin
  Run := FActive and Visible and not (csDesigning in ComponentState);
  if Run = FTimer.Enabled then
    Exit;

  if Run then
  begin
    FLastTick := Int64(GetTickCount64);
    FAccumDeg := FPhase * 360.0;   // continue from the current frame
  end;
  FTimer.Enabled := Run;
end;

procedure TCWSIndicatorLoading.AnimTick(Sender: TObject);
var
  NowTick: Int64;
  DeltaMs: Double;
begin
  // Time-based phase: accumulate degrees from the elapsed time and the current
  // speed. Accumulating (instead of recomputing from a start time) keeps the
  // motion continuous even if Speed changes mid-spin.
  NowTick := Int64(GetTickCount64);
  DeltaMs := NowTick - FLastTick;
  FLastTick := NowTick;
  FAccumDeg := FAccumDeg + DeltaMs / 1000.0 * FSpeed;
  FPhase := Frac(FAccumDeg / 360.0);   // 0..1, one unit per turn
  Invalidate;
end;

{ ── Painting ──────────────────────────────────────────────────────────────── }

procedure TCWSIndicatorLoading.Paint;
var
  W, H: Integer;
  Buf: Vcl.Graphics.TBitmap;
  G: TGPGraphics;
  Scale, MarginPx, Size: Single;
begin
  W := Width;
  H := Height;
  if (W < 2) or (H < 2) then
    Exit;

  Scale := Self.CurrentPPI / 96;
  FGapScaled := FGap * Scale;

  // Off-screen buffer composited over a copy of the parent background.
  // As a TGraphicControl we are painted right after the parent, so our Canvas
  // already holds whatever the parent drew behind us. Grab those pixels, draw
  // the anti-aliased spinner on top, then blit the result back in one pass —
  // genuinely transparent and flicker-free (on a double-buffered parent).
  Buf := Vcl.Graphics.TBitmap.Create;
  try
    Buf.PixelFormat := pf24bit;
    Buf.SetSize(W, H);
    BitBlt(Buf.Canvas.Handle, 0, 0, W, H, Canvas.Handle, 0, 0, SRCCOPY);

    MarginPx := FMargin * Scale;
    Size := Min(W, H) - 2 * MarginPx;
    if Size >= 4 then
    begin
      G := TGPGraphics.Create(Buf.Canvas.Handle);
      try
        G.SetSmoothingMode(SmoothingModeAntiAlias);
        DrawSpinner(G, W / 2, H / 2, Size);
      finally
        G.Free;
      end;
    end;

    BitBlt(Canvas.Handle, 0, 0, W, H, Buf.Canvas.Handle, 0, 0, SRCCOPY);
  finally
    Buf.Free;
  end;
end;

{ Force the host to double-buffer so the ~60 fps repaint does not flicker: as a
  TGraphicControl every frame makes the parent erase our rect and then re-draw,
  which on a non-buffered parent shows a visible erase/paint flash. Done only at
  run time so it never marks the form modified in the IDE. }
procedure TCWSIndicatorLoading.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if (AParent <> nil) and not (csDesigning in ComponentState) then
    AParent.DoubleBuffered := True;
end;

procedure TCWSIndicatorLoading.DrawSpinner(G: TGPGraphics; ACenterX, ACenterY, ASize: Single);
var
  T: Single;
begin
  T := FPhase;
  case FStyle of
    cilRing:      DrawIndicatorRing(G, ACenterX, ACenterY, ASize, T);
    cilSegmented: DrawIndicatorSegmented(G, ACenterX, ACenterY, ASize, T);
    cilArrows:    DrawIndicatorArrows(G, ACenterX, ACenterY, ASize, T);
  else
    DrawIndicatorLines(G, ACenterX, ACenterY, ASize, T);
  end;
end;

{ Style: radial lines, active colour fading to track colour. The line thickness
  is derived from the slot width and the requested gap, so the gap between
  neighbouring lines stays constant. }
procedure TCWSIndicatorLoading.DrawIndicatorLines(G: TGPGraphics; CX, CY, ASize, T: Single);
var
  N, I: Integer;
  Inner, Outer, PenW, SlotOuter, Ang, X1, Y1, X2, Y2, Frac, HeadPos: Single;
  ActiveCr, TrackCr: LongInt;
  Pen: TGPPen;
begin
  N        := FSegmentCount;
  Outer    := ASize * 0.50;
  Inner    := ASize * 0.24;
  ActiveCr := ColorToRGB(FActiveColor);
  TrackCr  := ColorToRGB(FTrackColor);

  SlotOuter := 2 * Pi * Outer / N;        // tangential space per line at outer
  PenW := SlotOuter - FGapScaled;         // keep a constant gap between lines
  if PenW < 1.5 then
    PenW := 1.5;
  if PenW > ASize * 0.075 then            // keep them thin / line-like
    PenW := ASize * 0.075;

  // round caps reach beyond the endpoints, so pull the ends in by half a width
  Outer   := Outer - PenW / 2;
  Inner   := Inner + PenW / 2;
  HeadPos := T * N;

  for I := 0 to N - 1 do
  begin
    Frac := TrailFrac(I, N, HeadPos);     // 1 at head, fading around the ring
    Ang  := (I / N) * 2 * Pi - Pi / 2;
    X1 := CX + Inner * Cos(Ang);
    Y1 := CY + Inner * Sin(Ang);
    X2 := CX + Outer * Cos(Ang);
    Y2 := CY + Outer * Sin(Ang);

    Pen := TGPPen.Create(BlendColor(TrackCr, ActiveCr, Frac), PenW);
    try
      Pen.SetStartCap(LineCapRound);
      Pen.SetEndCap(LineCapRound);
      G.DrawLine(Pen, X1, Y1, X2, Y2);
    finally
      Pen.Free;
    end;
  end;
end;

{ Style: donut ring with a rotating active arc over a full track ring }
procedure TCWSIndicatorLoading.DrawIndicatorRing(G: TGPGraphics; CX, CY, ASize, T: Single);
const
  SWEEP = 270.0;
var
  PenW, R, StartAngle: Single;
  Pen: TGPPen;
  ActiveCr, TrackCr: LongInt;
begin
  ActiveCr := ColorToRGB(FActiveColor);
  TrackCr  := ColorToRGB(FTrackColor);
  PenW := Max(3.0, ASize * 0.12);
  R    := ASize * 0.5 - PenW / 2;

  // background track ring
  Pen := TGPPen.Create(
    MakeColor(255, GetRValue(TrackCr), GetGValue(TrackCr), GetBValue(TrackCr)), PenW);
  try
    G.DrawEllipse(Pen, CX - R, CY - R, 2 * R, 2 * R);
  finally
    Pen.Free;
  end;

  // rotating foreground arc
  StartAngle := T * 360 - 90;
  Pen := TGPPen.Create(
    MakeColor(255, GetRValue(ActiveCr), GetGValue(ActiveCr), GetBValue(ActiveCr)), PenW);
  try
    Pen.SetStartCap(LineCapRound);
    Pen.SetEndCap(LineCapRound);
    G.DrawArc(Pen, CX - R, CY - R, 2 * R, 2 * R, StartAngle, SWEEP);
  finally
    Pen.Free;
  end;
end;

{ Style: thick donut segments (blocks), active colour fading to track colour.
  Each block is an annular sector whose radial sides are inset by a constant
  pixel distance (Gap / 2), so the gap stays equal in width at every radius. }
procedure TCWSIndicatorLoading.DrawIndicatorSegmented(G: TGPGraphics; CX, CY, ASize, T: Single);
const
  RAD2DEG = 180 / Pi;
var
  N, I: Integer;
  Outer, Inner, Thick, SegAngle, GapO, GapI, Base, Frac, HeadPos: Single;
  ActiveCr, TrackCr: LongInt;
  Brush: TGPSolidBrush;
  Path: TGPGraphicsPath;
begin
  N        := FSegmentCount;
  ActiveCr := ColorToRGB(FActiveColor);
  TrackCr  := ColorToRGB(FTrackColor);
  Outer    := ASize * 0.50;
  Thick    := ASize * 0.20;
  Inner    := Outer - Thick;
  SegAngle := 360 / N;

  // constant-width gap -> angular inset differs at inner vs. outer radius
  GapO := (FGapScaled / 2) / Outer * RAD2DEG;
  GapI := (FGapScaled / 2) / Inner * RAD2DEG;
  if GapO > SegAngle * 0.45 then GapO := SegAngle * 0.45;
  if GapI > SegAngle * 0.45 then GapI := SegAngle * 0.45;

  HeadPos := T * N;

  for I := 0 to N - 1 do
  begin
    Frac := TrailFrac(I, N, HeadPos);
    Base := I * SegAngle - 90;

    Path := TGPGraphicsPath.Create;
    try
      // outer edge: left -> right
      Path.AddArc(CX - Outer, CY - Outer, 2 * Outer, 2 * Outer,
        Base + GapO, SegAngle - 2 * GapO);
      // inner edge: right -> left (reverse) - the connecting lines form the
      // slanted radial sides that keep the gap a constant width
      Path.AddArc(CX - Inner, CY - Inner, 2 * Inner, 2 * Inner,
        Base + SegAngle - GapI, -(SegAngle - 2 * GapI));
      Path.CloseFigure;

      Brush := TGPSolidBrush.Create(BlendColor(TrackCr, ActiveCr, Frac));
      try
        G.FillPath(Brush, Path);
      finally
        Brush.Free;
      end;
    finally
      Path.Free;
    end;
  end;
end;

{ Style: arrows (chevrons) chasing clockwise around the ring. Each arrow is a
  constant-thickness ">" chevron with a blunt tip; the tip of one arrow nests
  into the concave back of the next. }
procedure TCWSIndicatorLoading.DrawIndicatorArrows(G: TGPGraphics; CX, CY, ASize, T: Single);
const
  RAD2DEG = 180 / Pi;
var
  N, I: Integer;
  Outer, Inner, Mid, Thick, SegAngle, Tip, Frac, Center, ArmO, ArmM, ArmI, HeadPos: Single;
  Pts: array[0..5] of TGPPointF;
  Brush: TGPSolidBrush;
  ActiveCr, TrackCr: LongInt;

  function Polar(ADeg, ARad: Single): TGPPointF;
  var
    Rad: Single;
  begin
    Rad := ADeg * (Pi / 180);
    Result := MakePoint(CX + ARad * Cos(Rad), CY + ARad * Sin(Rad));
  end;

begin
  N        := FSegmentCount;
  ActiveCr := ColorToRGB(FActiveColor);
  TrackCr  := ColorToRGB(FTrackColor);
  Outer    := ASize * 0.50;
  Thick    := ASize * 0.20;
  Inner    := Outer - Thick;
  Mid      := (Outer + Inner) / 2;
  SegAngle := 360 / N;

  // Keep the gap a constant pixel width at every radius: the angular half-width
  // of the chevron is larger at the outer radius and smaller at the inner one.
  ArmO := (SegAngle - FGapScaled / Outer * RAD2DEG) / 2;
  ArmM := (SegAngle - FGapScaled / Mid   * RAD2DEG) / 2;
  ArmI := (SegAngle - FGapScaled / Inner * RAD2DEG) / 2;
  if ArmO < SegAngle * 0.04 then ArmO := SegAngle * 0.04;
  if ArmM < SegAngle * 0.04 then ArmM := SegAngle * 0.04;
  if ArmI < SegAngle * 0.04 then ArmI := SegAngle * 0.04;
  Tip := SegAngle * 0.28;             // forward reach of the tip (blunt point)

  HeadPos := T * N;

  for I := 0 to N - 1 do
  begin
    Frac := TrailFrac(I, N, HeadPos);

    Center := I * SegAngle - 90 + SegAngle / 2;

    Pts[0] := Polar(Center + ArmO, Outer);        // leading outer
    Pts[1] := Polar(Center + ArmM + Tip, Mid);    // leading tip (blunt point)
    Pts[2] := Polar(Center + ArmI, Inner);        // leading inner
    Pts[3] := Polar(Center - ArmI, Inner);        // trailing inner
    Pts[4] := Polar(Center - ArmM + Tip, Mid);    // trailing notch tip
    Pts[5] := Polar(Center - ArmO, Outer);        // trailing outer

    Brush := TGPSolidBrush.Create(BlendColor(TrackCr, ActiveCr, Frac));
    try
      G.FillPolygon(Brush, PGPPointF(@Pts[0]), 6);
    finally
      Brush.Free;
    end;
  end;
end;

{ ── Property setters ──────────────────────────────────────────────────────── }

procedure TCWSIndicatorLoading.SetActive(const Value: Boolean);
begin
  if FActive <> Value then
  begin
    FActive := Value;
    UpdateAnimationState;
    Invalidate;
  end;
end;

procedure TCWSIndicatorLoading.SetStyle(const Value: TCWSLoadingStyle);
begin
  if FStyle <> Value then
  begin
    FStyle := Value;
    Invalidate;
  end;
end;

procedure TCWSIndicatorLoading.SetActiveColor(const Value: TColor);
begin
  if FActiveColor <> Value then
  begin
    FActiveColor := Value;
    Invalidate;
  end;
end;

procedure TCWSIndicatorLoading.SetTrackColor(const Value: TColor);
begin
  if FTrackColor <> Value then
  begin
    FTrackColor := Value;
    Invalidate;
  end;
end;

procedure TCWSIndicatorLoading.SetSegmentCount(const Value: Integer);
var
  Clamped: Integer;
begin
  Clamped := EnsureRange(Value, 3, 60);
  if FSegmentCount <> Clamped then
  begin
    FSegmentCount := Clamped;
    Invalidate;
  end;
end;

procedure TCWSIndicatorLoading.SetGap(const Value: Integer);
var
  Clamped: Integer;
begin
  Clamped := Max(0, Value);
  if FGap <> Clamped then
  begin
    FGap := Clamped;
    Invalidate;
  end;
end;

procedure TCWSIndicatorLoading.SetMargin(const Value: Integer);
var
  Clamped: Integer;
begin
  Clamped := Max(0, Value);
  if FMargin <> Clamped then
  begin
    FMargin := Clamped;
    Invalidate;
  end;
end;

procedure TCWSIndicatorLoading.SetSpeed(const Value: Integer);
begin
  // clamp to a sane range: 10..3600 deg/s (~0.03..10 turns per second)
  FSpeed := EnsureRange(Value, 10, 3600);
  // no Invalidate needed: the timer picks up the new speed on its next frame
end;

procedure TCWSIndicatorLoading.CMVisibleChanged(var Message: TMessage);
begin
  inherited;
  UpdateAnimationState;
end;

end.
