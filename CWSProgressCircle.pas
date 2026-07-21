//////////////////////////////////////////////////////////////////////////
//
//   CWStudio Component Library
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
unit CWSProgressCircle;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Graphics, Vcl.ExtCtrls,
  Winapi.Windows, System.Math,
  Winapi.GDIPAPI, Winapi.GDIPOBJ;

type
  TCWSProgressCircle = class(TGraphicControl)
  private
    FValue: Double;
    FMinValue: Double;
    FMaxValue: Double;
    FStep: Double;
    FLineWidth: Integer;
    FTrackColor: TColor;
    FProgressColor: TColor;
    FTextColor: TColor;
    FShowText: Boolean;
    FShowPercent: Boolean;
    FCustomText: string;
    FTextSize: Integer;
    FStartAngle: Double;
    FRoundCaps: Boolean;
    FAnimTarget: Double;
    FAnimStep: Double;
    FAnimTimer: TTimer;

    procedure SetValue(const AValue: Double);
    procedure SetMinValue(const AValue: Double);
    procedure SetMaxValue(const AValue: Double);
    procedure SetStep(const AValue: Double);
    procedure SetLineWidth(const AValue: Integer);
    procedure SetTrackColor(const AValue: TColor);
    procedure SetProgressColor(const AValue: TColor);
    procedure SetTextColor(const AValue: TColor);
    procedure SetShowText(const AValue: Boolean);
    procedure SetShowPercent(const AValue: Boolean);
    procedure SetCustomText(const AValue: string);
    procedure SetTextSize(const AValue: Integer);
    procedure SetRoundCaps(const AValue: Boolean);
    procedure SetStartAngle(const AValue: Double);
    procedure StopAnimation;
    procedure AnimTick(Sender: TObject);

    function NormalizedPercent: Double;
    function SnapToStep(const AValue: Double): Double;

  protected
    procedure Paint; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AnimateTo(const ATarget: Double; AStepsPerFrame: Double = 1.5);
    procedure StepUp;
    procedure StepDown;

  published
    property Value: Double read FValue write SetValue;
    property MinValue: Double read FMinValue write SetMinValue;
    property MaxValue: Double read FMaxValue write SetMaxValue;
    property Step: Double read FStep write SetStep;
    property LineWidth: Integer read FLineWidth write SetLineWidth default 12;
    property TrackColor: TColor read FTrackColor write SetTrackColor;
    property ProgressColor: TColor read FProgressColor write SetProgressColor;
    property TextColor: TColor read FTextColor write SetTextColor;
    property ShowText: Boolean read FShowText write SetShowText default True;
    property ShowPercent: Boolean read FShowPercent write SetShowPercent default True;
    property CustomText: string read FCustomText write SetCustomText;
    // 0 = automatic size (Min(Width, Height) / 4); > 0 = fixed font size
    // in logical pixels (96 DPI), scaled to the current DPI.
    property TextSize: Integer read FTextSize write SetTextSize default 0;
    property RoundCaps: Boolean read FRoundCaps write SetRoundCaps default True;
    property StartAngle: Double read FStartAngle write SetStartAngle;
    property Align;
    property Anchors;
    property Enabled;
    property Font;
    property Height;
    property Hint;
    property ParentFont;
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

function ColorToARGB(C: TColor): ARGB;
var
  RGB: COLORREF;
begin
  RGB := ColorToRGB(C);
  Result := MakeColor(255, GetRValue(RGB), GetGValue(RGB), GetBValue(RGB));
end;

constructor TCWSProgressCircle.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 120;
  Height := 120;
  FLineWidth := 12;
  FTrackColor := $00EEEEEE;
  FProgressColor := $000A60D4;
  FTextColor := clBlack;
  FShowText := True;
  FShowPercent := True;
  FRoundCaps := True;
  FTextSize := 0;
  FMinValue := 0;
  FMaxValue := 100;
  FStep := 0;
  FValue := 0;

  FAnimTimer := TTimer.Create(Self);
  FAnimTimer.Enabled := False;
  FAnimTimer.Interval := 16;
  FAnimTimer.OnTimer := AnimTick;
end;

destructor TCWSProgressCircle.Destroy;
begin
  StopAnimation;
  inherited;
end;

function TCWSProgressCircle.NormalizedPercent: Double;
var
  Range: Double;
begin
  Range := FMaxValue - FMinValue;
  if Range <= 0 then
    Result := 0
  else
    Result := EnsureRange((FValue - FMinValue) / Range * 100, 0, 100);
end;

function TCWSProgressCircle.SnapToStep(const AValue: Double): Double;
var
  Steps: Int64;
begin
  if FStep <= 0 then
  begin
    Result := AValue;
    Exit;
  end;
  Steps := Round((AValue - FMinValue) / FStep);
  Result := FMinValue + Steps * FStep;
  Result := EnsureRange(Result, FMinValue, FMaxValue);
end;

procedure TCWSProgressCircle.SetValue(const AValue: Double);
var
  Snapped: Double;
begin
  Snapped := SnapToStep(EnsureRange(AValue, FMinValue, FMaxValue));
  if FValue <> Snapped then
  begin
    FValue := Snapped;
    Invalidate;
  end;
end;

procedure TCWSProgressCircle.SetMinValue(const AValue: Double);
begin
  if FMinValue <> AValue then
  begin
    FMinValue := AValue;
    if FMaxValue < FMinValue then
      FMaxValue := FMinValue;
    FValue := EnsureRange(FValue, FMinValue, FMaxValue);
    Invalidate;
  end;
end;

procedure TCWSProgressCircle.SetMaxValue(const AValue: Double);
begin
  if FMaxValue <> AValue then
  begin
    FMaxValue := AValue;
    if FMinValue > FMaxValue then
      FMinValue := FMaxValue;
    FValue := EnsureRange(FValue, FMinValue, FMaxValue);
    Invalidate;
  end;
end;

procedure TCWSProgressCircle.SetStep(const AValue: Double);
begin
  if FStep <> AValue then
  begin
    FStep := Max(0, AValue);
    SetValue(FValue);
  end;
end;

procedure TCWSProgressCircle.SetLineWidth(const AValue: Integer);
begin
  if FLineWidth <> AValue then
  begin
    FLineWidth := AValue;
    Invalidate;
  end;
end;

procedure TCWSProgressCircle.SetTrackColor(const AValue: TColor);
begin
  if FTrackColor <> AValue then
  begin
    FTrackColor := AValue;
    Invalidate;
  end;
end;

procedure TCWSProgressCircle.SetProgressColor(const AValue: TColor);
begin
  if FProgressColor <> AValue then
  begin
    FProgressColor := AValue;
    Invalidate;
  end;
end;

procedure TCWSProgressCircle.SetTextColor(const AValue: TColor);
begin
  if FTextColor <> AValue then
  begin
    FTextColor := AValue;
    Invalidate;
  end;
end;

procedure TCWSProgressCircle.SetShowText(const AValue: Boolean);
begin
  if FShowText <> AValue then
  begin
    FShowText := AValue;
    Invalidate;
  end;
end;

procedure TCWSProgressCircle.SetShowPercent(const AValue: Boolean);
begin
  if FShowPercent <> AValue then
  begin
    FShowPercent := AValue;
    Invalidate;
  end;
end;

procedure TCWSProgressCircle.SetCustomText(const AValue: string);
begin
  if FCustomText <> AValue then
  begin
    FCustomText := AValue;
    Invalidate;
  end;
end;

procedure TCWSProgressCircle.SetTextSize(const AValue: Integer);
var
  Clamped: Integer;
begin
  Clamped := Max(0, AValue);
  if FTextSize <> Clamped then
  begin
    FTextSize := Clamped;
    Invalidate;
  end;
end;

procedure TCWSProgressCircle.SetRoundCaps(const AValue: Boolean);
begin
  if FRoundCaps <> AValue then
  begin
    FRoundCaps := AValue;
    Invalidate;
  end;
end;

procedure TCWSProgressCircle.SetStartAngle(const AValue: Double);
begin
  if FStartAngle <> AValue then
  begin
    FStartAngle := AValue;
    Invalidate;
  end;
end;

procedure TCWSProgressCircle.StepUp;
begin
  SetValue(FValue + IfThen(FStep > 0, FStep, 1));
end;

procedure TCWSProgressCircle.StepDown;
begin
  SetValue(FValue - IfThen(FStep > 0, FStep, 1));
end;

procedure TCWSProgressCircle.AnimTick(Sender: TObject);
var
  Delta: Double;
begin
  Delta := FAnimTarget - FValue;
  if Abs(Delta) <= FAnimStep then
  begin
    FValue := FAnimTarget;
    StopAnimation;
  end
  else
    FValue := FValue + Sign(Delta) * FAnimStep;
  Invalidate;
end;

procedure TCWSProgressCircle.StopAnimation;
begin
  if Assigned(FAnimTimer) then
    FAnimTimer.Enabled := False;
end;

procedure TCWSProgressCircle.AnimateTo(const ATarget: Double; AStepsPerFrame: Double);
begin
  StopAnimation;
  FAnimTarget := EnsureRange(ATarget, FMinValue, FMaxValue);
  FAnimStep := AStepsPerFrame;
  FAnimTimer.Enabled := True;
end;

procedure TCWSProgressCircle.Paint;
var
  W, H: Integer;
  GFX: TGPGraphics;
  // Arc geometry ----------------------------------------------------------
  // FLineWidth is in logical pixels (96 DPI); CurrentPPI accounts for the
  // current Windows scaling. GDI+ anti-aliases the arcs directly against the
  // real parent background already present on the Canvas, so we do NOT copy
  // any pixels from our own Canvas (that "background theft" caused ghost
  // arcs when the control was partially clipped / scrolled).
  ActualLineW: Single;
  Diam: Single;
  RectX, RectY: Single;
  TrackPen, ProgPen: TGPPen;
  Sweep: Single;
  // Text ------------------------------------------------------------------
  GPFont: TGPFont;
  GPFamily: TGPFontFamily;
  GPFormat: TGPStringFormat;
  CentreFormat: TGPStringFormat;
  Brush: TGPSolidBrush;
  DisplayStr: string;
  NormPct: Double;
  MainFontSize: Single;
  FullRect: TGPRectF;
  MeasureRect: TGPRectF;
  NumBounds: TGPRectF;
  PctBounds: TGPRectF;
  MainRect: TGPRectF;
  PctRect: TGPRectF;
  NumPad: Single;
  PctPad: Single;
  NumVisW: Single;
  PctVisW: Single;
  PairVisW: Single;
  StartX: Single;
  StartY: Single;
begin
  W := Width;
  H := Height;
  if (W < 2) or (H < 2) then
    Exit;

  NormPct := NormalizedPercent;

  GFX := TGPGraphics.Create(Canvas.Handle);
  try
    GFX.SetSmoothingMode(SmoothingModeAntiAlias);
    GFX.SetPixelOffsetMode(PixelOffsetModeHighQuality);

    // ── Arcs (drawn straight onto the Canvas, no back-buffer) ────────────
    ActualLineW := Max(1, Round(FLineWidth * (Self.CurrentPPI / 96)));

    // Centred, circular stroke path. GDI+ strokes are centred on the path,
    // so we inset the bounding box by half the line width (plus 1px margin).
    Diam := Min(W, H) - ActualLineW - 2;
    if Diam < 1 then
      Diam := 1;
    RectX := (W - Diam) / 2;
    RectY := (H - Diam) / 2;

    // GDI+ measures angles from 3 o'clock; this control measures from 12
    // o'clock, hence the -90 offset. Sweep is clockwise in both.

    // Track: full ring.
    TrackPen := TGPPen.Create(ColorToARGB(FTrackColor), ActualLineW);
    try
      TrackPen.SetStartCap(LineCapFlat);
      TrackPen.SetEndCap(LineCapFlat);
      GFX.DrawArc(TrackPen, RectX, RectY, Diam, Diam, FStartAngle - 90, 360);
    finally
      TrackPen.Free;
    end;

    // Progress arc.
    if NormPct > 0 then
    begin
      Sweep := NormPct / 100 * 360;
      ProgPen := TGPPen.Create(ColorToARGB(FProgressColor), ActualLineW);
      try
        if FRoundCaps then
        begin
          ProgPen.SetStartCap(LineCapRound);
          ProgPen.SetEndCap(LineCapRound);
        end
        else
        begin
          ProgPen.SetStartCap(LineCapFlat);
          ProgPen.SetEndCap(LineCapFlat);
        end;
        GFX.DrawArc(ProgPen, RectX, RectY, Diam, Diam,
          FStartAngle - 90, Sweep);
      finally
        ProgPen.Free;
      end;
    end;

    if not FShowText then
      Exit;

    // ── Text via GDI+ ────────────────────────────────────────────────────
    GFX.SetTextRenderingHint(TextRenderingHintAntiAlias);

    GPFamily := TGPFontFamily.Create(Font.Name);
    // TextSize = 0 → automatic size based on the circle diameter.
    // TextSize > 0 → fixed size in logical pixels, scaled to DPI.
    if FTextSize > 0 then
      MainFontSize := FTextSize * (Self.CurrentPPI / 96)
    else
      MainFontSize := Max(8, Min(W, H) / 4);

    GPFormat := TGPStringFormat.Create;
    GPFormat.SetAlignment(StringAlignmentNear);
    GPFormat.SetLineAlignment(StringAlignmentNear);

    CentreFormat := TGPStringFormat.Create;
    CentreFormat.SetAlignment(StringAlignmentCenter);
    CentreFormat.SetLineAlignment(StringAlignmentCenter);

    try
      GPFont := TGPFont.Create(GPFamily, MainFontSize, FontStyleBold, UnitPixel);
      try

        // ── CustomText lub ShowPercent=False: prosty wycentrowany napis ─────
        if (FCustomText <> '') or (not FShowPercent) then
        begin
          if FCustomText <> '' then
            DisplayStr := FCustomText
          else
            DisplayStr := Format('%g', [FValue]);

          FullRect.X := 0;
          FullRect.Y := 0;
          FullRect.Width := W;
          FullRect.Height := H;
          Brush := TGPSolidBrush.Create(ColorToARGB(FTextColor));
          try
            GFX.DrawString(DisplayStr, -1, GPFont, FullRect, CentreFormat, Brush);
          finally
            Brush.Free;
          end;
        end

          // ── ShowPercent=True: number + % side by side, same font ───────────
        else
        begin
          DisplayStr := Format('%g', [FValue]);

          MeasureRect.X := 0;
          MeasureRect.Y := 0;
          MeasureRect.Width := W;
          MeasureRect.Height := H;

          // Measure the bounding boxes of both elements with the same font
          GFX.MeasureString(DisplayStr, -1, GPFont, MeasureRect, GPFormat, NumBounds);
          GFX.MeasureString('%', -1, GPFont, MeasureRect, GPFormat, PctBounds);

          // GDI+ adds internal padding of about 1/6 of the font size on each side.
          // We subtract it to get the actual visual glyph width.
          NumPad := MainFontSize / 6;
          PctPad := MainFontSize / 6;

          NumVisW := NumBounds.Width - NumPad * 2;
          PctVisW := PctBounds.Width - PctPad * 2;
          PairVisW := NumVisW + PctVisW;

          // Center the whole pair inside the control
          StartX := (W - PairVisW) / 2;
          StartY := (H - NumBounds.Height) / 2;

          // Number: shifted back by left padding so its visual left edge = StartX
          MainRect.X := StartX - NumPad;
          MainRect.Y := StartY;
          MainRect.Width := NumBounds.Width;
          MainRect.Height := NumBounds.Height;

          // '%': just past the number's visual right edge,
          //      shifted back by its own left padding, Y aligned with the number
          PctRect.X := StartX + NumVisW - PctPad;
          PctRect.Y := StartY;
          PctRect.Width := PctBounds.Width;
          PctRect.Height := PctBounds.Height;

          Brush := TGPSolidBrush.Create(ColorToARGB(FTextColor));
          try
            GFX.DrawString(DisplayStr, -1, GPFont, MainRect, GPFormat, Brush);
            GFX.DrawString('%', -1, GPFont, PctRect, GPFormat, Brush);
          finally
            Brush.Free;
          end;
        end;

      finally
        GPFont.Free;
      end;
    finally
      GPFormat.Free;
      CentreFormat.Free;
      GPFamily.Free;
    end;
  finally
    GFX.Free;
  end;
end;

end.
