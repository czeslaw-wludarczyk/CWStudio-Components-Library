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
unit CWSProgressBar;

interface

uses
  System.SysUtils, System.Classes, System.UITypes, Vcl.Controls, Vcl.Graphics,
  Winapi.Windows, Winapi.Messages, System.Math,
  Winapi.GDIPAPI, Winapi.GDIPOBJ;

type
  TCWSProgressBar = class(TCustomControl)
  private
    FValue: Double;
    FMinValue: Double;
    FMaxValue: Double;
    FStep: Double;
    FBackgroundColor: TColor;
    FProgressColor: TColor;
    FTextColor: TColor;
    FShowText: Boolean;
    FShowPercent: Boolean;
    FCustomText: string;
    FRoundCaps: Boolean;
    FAnimTarget: Double;
    FAnimStep: Double;
    FAnimTimerID: UINT_PTR;

    procedure SetValue(const AValue: Double);
    procedure SetMinValue(const AValue: Double);
    procedure SetMaxValue(const AValue: Double);
    procedure SetStep(const AValue: Double);
    procedure SetBackgroundColor(const AValue: TColor);
    procedure SetProgressColor(const AValue: TColor);
    procedure SetTextColor(const AValue: TColor);
    procedure SetShowText(const AValue: Boolean);
    procedure SetShowPercent(const AValue: Boolean);
    procedure SetCustomText(const AValue: string);
    procedure SetRoundCaps(const AValue: Boolean);
    procedure StopAnimation;

    function NormalizedPercent: Double;
    function SnapToStep(const AValue: Double): Double;
    function DisplayText: string;
    function ParentBackColor: TColor;

  protected
    procedure Paint; override;
    procedure WndProc(var Message: TMessage); override;

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
    property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor default $00D8D8D8;
    property ProgressColor: TColor read FProgressColor write SetProgressColor default $00D4600A;
    property TextColor: TColor read FTextColor write SetTextColor default clBlack;
    property ShowText: Boolean read FShowText write SetShowText default False;
    property ShowPercent: Boolean read FShowPercent write SetShowPercent default True;
    property CustomText: string read FCustomText write SetCustomText;
    property RoundCaps: Boolean read FRoundCaps write SetRoundCaps default True;
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property Font;
    property Height;
    property Hint;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
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

type
  TControlAccess = class(TControl);

function ColorToARGB(C: TColor): ARGB;
var
  RGB: COLORREF;
begin
  RGB := ColorToRGB(C);
  Result := MakeColor(255, GetRValue(RGB), GetGValue(RGB), GetBValue(RGB));
end;

{ Builds a rounded-rectangle path (capsule when Radius = Height/2). }
procedure AddRoundRectPath(APath: TGPGraphicsPath; const R: TGPRectF;
  ARadius: Single);
var
  D: Single;
begin
  if ARadius <= 0 then
  begin
    APath.AddRectangle(R);
    Exit;
  end;
  D := ARadius * 2;
  if D > R.Width then D := R.Width;
  if D > R.Height then D := R.Height;

  APath.StartFigure;
  APath.AddArc(R.X, R.Y, D, D, 180, 90);
  APath.AddArc(R.X + R.Width - D, R.Y, D, D, 270, 90);
  APath.AddArc(R.X + R.Width - D, R.Y + R.Height - D, D, D, 0, 90);
  APath.AddArc(R.X, R.Y + R.Height - D, D, D, 90, 90);
  APath.CloseFigure;
end;

constructor TCWSProgressBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width  := 220;
  Height := 8;
  FBackgroundColor := $00D8D8D8;  { jasnoszary tor }
  FProgressColor   := $00D4600A;  { Windows 11 accent (niebieski) }
  FTextColor       := clBlack;
  FShowText        := False;
  FShowPercent     := True;
  FRoundCaps       := True;
  FMinValue        := 0;
  FMaxValue        := 100;
  FStep            := 0;
  FValue           := 0;
  Color            := clWhite;
  DoubleBuffered   := True;
end;

destructor TCWSProgressBar.Destroy;
begin
  StopAnimation;
  inherited;
end;

function TCWSProgressBar.NormalizedPercent: Double;
var
  Range: Double;
begin
  Range := FMaxValue - FMinValue;
  if Range <= 0 then
    Result := 0
  else
    Result := EnsureRange((FValue - FMinValue) / Range * 100, 0, 100);
end;

function TCWSProgressBar.SnapToStep(const AValue: Double): Double;
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

{ Corners outside the capsule always take the parent colour — the bar blends in. }
function TCWSProgressBar.ParentBackColor: TColor;
begin
  if Parent <> nil then
    Result := TControlAccess(Parent).Color
  else
    Result := clBtnFace;
end;

function TCWSProgressBar.DisplayText: string;
begin
  if FCustomText <> '' then
    Result := FCustomText
  else if FShowPercent then
    Result := Format('%d%%', [Round(NormalizedPercent)])
  else
    Result := Format('%g', [FValue]);
end;

procedure TCWSProgressBar.SetValue(const AValue: Double);
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

procedure TCWSProgressBar.SetMinValue(const AValue: Double);
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

procedure TCWSProgressBar.SetMaxValue(const AValue: Double);
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

procedure TCWSProgressBar.SetStep(const AValue: Double);
begin
  if FStep <> AValue then
  begin
    FStep := Max(0, AValue);
    SetValue(FValue);
  end;
end;

procedure TCWSProgressBar.SetBackgroundColor(const AValue: TColor);
begin
  if FBackgroundColor <> AValue then
  begin
    FBackgroundColor := AValue;
    Invalidate;
  end;
end;

procedure TCWSProgressBar.SetProgressColor(const AValue: TColor);
begin
  if FProgressColor <> AValue then
  begin
    FProgressColor := AValue;
    Invalidate;
  end;
end;

procedure TCWSProgressBar.SetTextColor(const AValue: TColor);
begin
  if FTextColor <> AValue then
  begin
    FTextColor := AValue;
    Invalidate;
  end;
end;

procedure TCWSProgressBar.SetShowText(const AValue: Boolean);
begin
  if FShowText <> AValue then
  begin
    FShowText := AValue;
    Invalidate;
  end;
end;

procedure TCWSProgressBar.SetShowPercent(const AValue: Boolean);
begin
  if FShowPercent <> AValue then
  begin
    FShowPercent := AValue;
    Invalidate;
  end;
end;

procedure TCWSProgressBar.SetCustomText(const AValue: string);
begin
  if FCustomText <> AValue then
  begin
    FCustomText := AValue;
    Invalidate;
  end;
end;

procedure TCWSProgressBar.SetRoundCaps(const AValue: Boolean);
begin
  if FRoundCaps <> AValue then
  begin
    FRoundCaps := AValue;
    Invalidate;
  end;
end;

procedure TCWSProgressBar.StepUp;
begin
  SetValue(FValue + IfThen(FStep > 0, FStep, 1));
end;

procedure TCWSProgressBar.StepDown;
begin
  SetValue(FValue - IfThen(FStep > 0, FStep, 1));
end;

procedure TCWSProgressBar.WndProc(var Message: TMessage);
var
  Delta: Double;
begin
  if (Message.Msg = WM_TIMER) and (UINT_PTR(Message.WParam) = FAnimTimerID) then
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
    Message.Result := 0;
  end
  else
    inherited WndProc(Message);
end;

procedure TCWSProgressBar.StopAnimation;
begin
  if FAnimTimerID <> 0 then
  begin
    KillTimer(Handle, FAnimTimerID);
    FAnimTimerID := 0;
  end;
end;

procedure TCWSProgressBar.AnimateTo(const ATarget: Double; AStepsPerFrame: Double);
begin
  StopAnimation;
  FAnimTarget := EnsureRange(ATarget, FMinValue, FMaxValue);
  FAnimStep := Max(0.01, AStepsPerFrame);
  FAnimTimerID := SetTimer(Handle, 1, 16, nil);
end;

procedure TCWSProgressBar.Paint;
var
  W, H: Integer;
  GFX: TGPGraphics;
  PathT, PathP: TGPGraphicsPath;
  BrushT, BrushP: TGPSolidBrush;
  TrackRect, ProgRect: TGPRectF;
  Radius, ProgW, NormPct: Single;
  // tekst
  Str: string;
  GPFamily: TGPFontFamily;
  GPFont: TGPFont;
  GPFormat: TGPStringFormat;
  TextBrush: TGPSolidBrush;
  FontStyle: Integer;
  FontPx: Single;
  LayoutRect: TGPRectF;
begin
  W := ClientWidth;
  H := ClientHeight;
  if (W < 2) or (H < 2) then
    Exit;

  { control background (corners outside the capsule) — always the parent colour (blend) }
  Canvas.Brush.Color := ParentBackColor;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(ClientRect);

  NormPct := NormalizedPercent;

  GFX := TGPGraphics.Create(Canvas.Handle);
  try
    GFX.SetSmoothingMode(SmoothingModeAntiAlias);
    GFX.SetPixelOffsetMode(PixelOffsetModeHighQuality);

    { the capsule fills the whole area — no inset, so no 1px background border
      appears above/below the bar (the shape touches the top and bottom edges) }
    TrackRect := MakeRect(Single(0), Single(0), Single(W), Single(H));

    if FRoundCaps then
      Radius := H / 2
    else
      Radius := 0;

    { ── track (bar background) ──────────────────────────────────────────── }
    PathT := TGPGraphicsPath.Create;
    BrushT := TGPSolidBrush.Create(ColorToARGB(FBackgroundColor));
    try
      AddRoundRectPath(PathT, TrackRect, Radius);
      GFX.FillPath(BrushT, PathT);
    finally
      BrushT.Free;
      PathT.Free;
    end;

    { ── fill (progress) ─────────────────────────────────────────────────── }
    if NormPct > 0 then
    begin
      ProgW := W * (NormPct / 100);
      { with rounded ends, show at least a capsule of width = height }
      if FRoundCaps and (ProgW < H) then
        ProgW := H;
      if ProgW > W then
        ProgW := W;

      ProgRect := MakeRect(Single(0), Single(0), ProgW, Single(H));

      PathP := TGPGraphicsPath.Create;
      BrushP := TGPSolidBrush.Create(ColorToARGB(FProgressColor));
      try
        AddRoundRectPath(PathP, ProgRect, Radius);
        GFX.FillPath(BrushP, PathP);
      finally
        BrushP.Free;
        PathP.Free;
      end;
    end;

    { ── text (percent) ──────────────────────────────────────────────────── }
    if FShowText then
    begin
      Str := DisplayText;
      if Str <> '' then
      begin
        GFX.SetTextRenderingHint(TextRenderingHintAntiAlias);

        { font size in device pixels (Font already DPI-scaled) }
        if Font.Height <> 0 then
          FontPx := Abs(Font.Height)
        else
          FontPx := Font.Size * (CurrentPPI / 72);
        FontPx := Max(Single(6), FontPx);

        FontStyle := 0;
        if fsBold in Font.Style then FontStyle := FontStyle or FontStyleBold;
        if fsItalic in Font.Style then FontStyle := FontStyle or FontStyleItalic;
        if fsUnderline in Font.Style then FontStyle := FontStyle or FontStyleUnderline;
        if fsStrikeOut in Font.Style then FontStyle := FontStyle or FontStyleStrikeout;

        GPFamily := TGPFontFamily.Create(Font.Name);
        GPFont := TGPFont.Create(GPFamily, FontPx, FontStyle, UnitPixel);
        GPFormat := TGPStringFormat.Create;
        TextBrush := TGPSolidBrush.Create(ColorToARGB(FTextColor));
        try
          GPFormat.SetAlignment(StringAlignmentCenter);
          GPFormat.SetLineAlignment(StringAlignmentCenter);
          LayoutRect := MakeRect(Single(0), Single(0), Single(W), Single(H));
          GFX.DrawString(Str, -1, GPFont, LayoutRect, GPFormat, TextBrush);
        finally
          TextBrush.Free;
          GPFormat.Free;
          GPFont.Free;
          GPFamily.Free;
        end;
      end;
    end;
  finally
    GFX.Free;
  end;
end;

end.
