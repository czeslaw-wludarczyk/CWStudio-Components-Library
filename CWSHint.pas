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
unit CWSHint;

{
  TCWSHint - replaces the standard VCL hint (tooltip) of the whole application
  with a Windows 11 style bubble: rounded corners, a soft shadow, custom
  colours and font. Drawn the same way as TCWSPopupMenu.

  Usage:
    Drop one TCWSHint on the main form (or a data module). While Active is True
    every control that has ShowHint / Hint set shows its hint through
    TCWSHintWindow - no change to the controls themselves is needed.
    Nothing is replaced at design time, so the IDE keeps its own hints.

  Properties:
    Active             - True = the hint of the whole application is replaced
                         (default True). False restores the previous hint class.
    Color              - bubble background
    BorderColor        - bubble border
    BorderThickness    - border width, 0 = no border
    CornerRadius       - corner rounding radius, 0 = square
    Font               - hint text font (name, size, colour, style)
    Shadow             - soft shadow under the bubble
    ShadowSize         - shadow blur size
    PaddingHorizontal  - left / right space around the text
    PaddingVertical    - top / bottom space around the text
    MaxWidth           - maximum bubble width before the text wraps
                         (0 = only the VCL limit)
    HintPause          - delay before the hint appears, ms (default 500)
    HintHidePause      - how long the hint stays visible, ms (default 2500)
    HintShortPause     - delay when moving to another control while a hint
                         is up, ms (default 0)
    HintShortCuts      - append the shortcut of a control's action to its
                         hint, e.g. "Save (Ctrl+S)" (default True)
    OnShowHint         - fired before every hint, same as
                         Application.OnShowHint: change HintStr, cancel with
                         CanShow := False, or adjust HintInfo (position, max
                         width, HideTimeout, CursorRect ...). Setting
                         HintInfo.HintColor changes the bubble background of
                         that one hint (any colour other than
                         Application.HintColor).
                         A handler already assigned to Application.OnShowHint
                         keeps working - it is called first.
    The three pauses are written to Application.HintPause / HintHidePause /
    HintShortPause while the component is the active one; the previous
    values are restored when the last TCWSHint is deactivated.
    All sizes are in 96 DPI pixels and are scaled to the monitor the hint
    appears on.

  How it is drawn:
    The hint is a layered window (WS_EX_LAYERED) filled with a single
    UpdateLayeredWindow call: shadow, anti-aliased rounded body and border in
    GDI+, text in GDI with ClearType. The complete per-pixel-alpha bitmap is
    handed to the window before it is shown, so there is no frame in which the
    window background shows through - a normal window with DWM corners and
    shadow briefly flashes its lighter background there.

  When several TCWSHint instances are active at once, the most recently
  activated one supplies the look; destroying it hands over to the previous one.
}

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes, System.Math,
  System.Generics.Collections,
  Winapi.Windows, Winapi.Messages, Winapi.MultiMon, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  Vcl.Controls, Vcl.Forms, Vcl.Graphics;

type
  { Hint window installed as Vcl.Forms.HintWindowClass by TCWSHint. It reads
    its look from the active TCWSHint (or built-in defaults when none is). }
  TCWSHintWindow = class(THintWindow)
  private
    FDpi: Integer;
    FScale: Single;
    FBlur: Integer;
    FShadowOffset: Integer;
    FShadow: Integer;          { transparent margin around the body for the shadow }
    FBodyW: Integer;
    FBodyH: Integer;
    FWinLeft: Integer;
    FWinTop: Integer;
    FWinW: Integer;
    FWinH: Integer;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure ComputeScale(const P: TPoint);
    procedure UpdateShadowMetrics;
    function MakeGdiFont: HFONT;
    procedure Render;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure NCPaint(DC: HDC); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ActivateHint(Rect: TRect; const AHint: string); override;
    function CalcHintRect(MaxWidth: Integer; const AHint: string;
      AData: TCustomData): TRect; override;
  end;

  TCWSHint = class(TComponent)
  private
    FActive: Boolean;
    FColor: TColor;
    FBorderColor: TColor;
    FBorderThickness: Integer;
    FCornerRadius: Integer;
    FFont: TFont;
    FShadow: Boolean;
    FShadowSize: Integer;
    FPaddingHorizontal: Integer;
    FPaddingVertical: Integer;
    FMaxWidth: Integer;
    FHintPause: Integer;
    FHintHidePause: Integer;
    FHintShortPause: Integer;
    FHintShortCuts: Boolean;
    FOnShowHint: TShowHintEvent;
    procedure SetActive(Value: Boolean);
    procedure SetHintPause(Value: Integer);
    procedure SetHintHidePause(Value: Integer);
    procedure SetHintShortPause(Value: Integer);
    procedure SetHintShortCuts(Value: Boolean);
    procedure ApplyApplicationSettings;
    procedure SetFont(Value: TFont);
    procedure SetBorderThickness(Value: Integer);
    procedure SetCornerRadius(Value: Integer);
    procedure SetShadowSize(Value: Integer);
    procedure SetPaddingHorizontal(Value: Integer);
    procedure SetPaddingVertical(Value: Integer);
    procedure SetMaxWidth(Value: Integer);
    procedure Install;
    procedure Uninstall;
  protected
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { The instance that currently supplies the look, or nil }
    class function ActiveHint: TCWSHint;
  published
    property Active: Boolean read FActive write SetActive default True;
    property Color: TColor read FColor write FColor default $00F9F9F9;
    property BorderColor: TColor read FBorderColor write FBorderColor default $00E0E0E0;
    property BorderThickness: Integer read FBorderThickness
      write SetBorderThickness default 1;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 8;
    property Font: TFont read FFont write SetFont;
    property Shadow: Boolean read FShadow write FShadow default True;
    property ShadowSize: Integer read FShadowSize write SetShadowSize default 10;
    property PaddingHorizontal: Integer read FPaddingHorizontal
      write SetPaddingHorizontal default 8;
    property PaddingVertical: Integer read FPaddingVertical
      write SetPaddingVertical default 5;
    property MaxWidth: Integer read FMaxWidth write SetMaxWidth default 400;
    property HintPause: Integer read FHintPause write SetHintPause default 500;
    property HintHidePause: Integer read FHintHidePause write SetHintHidePause default 2500;
    property HintShortPause: Integer read FHintShortPause write SetHintShortPause default 0;
    property HintShortCuts: Boolean read FHintShortCuts write SetHintShortCuts default True;
    property OnShowHint: TShowHintEvent read FOnShowHint write FOnShowHint;
  end;

implementation

const
  HINT_SHADOW_ALPHA = 70;

var
  GInstances: TList<TCWSHint> = nil;   { installed instances, last = active }
  GOriginalHintClass: THintWindowClass = nil;
  { Application hint timings from before the first install }
  GOriginalHintPause: Integer;
  GOriginalHintHidePause: Integer;
  GOriginalHintShortPause: Integer;
  GOriginalHintShortCuts: Boolean;
  { Application.OnShowHint from before the first install - still called }
  GPrevOnShowHint: TShowHintEvent;

type
  { Application.OnShowHint needs a method pointer that outlives any single
    TCWSHint; a class method has no instance, so it always stays valid }
  TCWSHintDispatcher = class
  public
    class procedure DoShowHint(var HintStr: string; var CanShow: Boolean;
      var HintInfo: Vcl.Controls.THintInfo);
  end;

class procedure TCWSHintDispatcher.DoShowHint(var HintStr: string;
  var CanShow: Boolean; var HintInfo: Vcl.Controls.THintInfo);
var
  H: TCWSHint;
begin
  if Assigned(GPrevOnShowHint) then
    GPrevOnShowHint(HintStr, CanShow, HintInfo);
  H := TCWSHint.ActiveHint;
  if CanShow and (H <> nil) and Assigned(H.OnShowHint) then
    H.OnShowHint(HintStr, CanShow, HintInfo);
end;

function IsDispatcherInstalled: Boolean;
var
  M: TShowHintEvent;
begin
  M := TCWSHintDispatcher.DoShowHint;
  Result := (Application <> nil) and
    (TMethod(Application.OnShowHint).Code = TMethod(M).Code);
end;

{ ============================================================================ }
{  Look snapshot - the active component or the defaults                        }
{ ============================================================================ }

type
  TCWSHintLook = record
    Color: TColor;
    BorderColor: TColor;
    BorderThickness: Integer;
    CornerRadius: Integer;
    Font: TFont;
    Shadow: Boolean;
    ShadowSize: Integer;
    PaddingHorizontal: Integer;
    PaddingVertical: Integer;
    MaxWidth: Integer;
  end;

function CurrentLook: TCWSHintLook;
var
  H: TCWSHint;
begin
  H := TCWSHint.ActiveHint;
  if H <> nil then
  begin
    Result.Color             := H.Color;
    Result.BorderColor       := H.BorderColor;
    Result.BorderThickness   := H.BorderThickness;
    Result.CornerRadius      := H.CornerRadius;
    Result.Font              := H.Font;
    Result.Shadow            := H.Shadow;
    Result.ShadowSize        := H.ShadowSize;
    Result.PaddingHorizontal := H.PaddingHorizontal;
    Result.PaddingVertical   := H.PaddingVertical;
    Result.MaxWidth          := H.MaxWidth;
  end
  else
  begin
    Result.Color             := $00F9F9F9;
    Result.BorderColor       := $00E0E0E0;
    Result.BorderThickness   := 1;
    Result.CornerRadius      := 8;
    Result.Font              := Screen.HintFont;
    Result.Shadow            := True;
    Result.ShadowSize        := 10;
    Result.PaddingHorizontal := 8;
    Result.PaddingVertical   := 5;
    Result.MaxWidth          := 400;
  end;
end;

{ ============================================================================ }
{  GDI+ helpers (same drawing as TCWSPopupMenu)                                }
{ ============================================================================ }

function GPColor(C: TColor; A: Byte = 255): ARGB;
var
  RGB: COLORREF;
begin
  RGB := ColorToRGB(C);
  Result := MakeColor(A, GetRValue(RGB), GetGValue(RGB), GetBValue(RGB));
end;

function CreateRRPath(X, Y, W, H, R: Single): TGPGraphicsPath;
var
  D: Single;
begin
  Result := TGPGraphicsPath.Create;
  if R <= 0 then
  begin
    Result.AddRectangle(MakeRect(X, Y, W, H));
    Exit;
  end;
  D := R * 2;
  if D > W then D := W;
  if D > H then D := H;
  Result.StartFigure;
  Result.AddArc(X, Y, D, D, 180, 90);
  Result.AddArc(X + W - D, Y, D, D, 270, 90);
  Result.AddArc(X + W - D, Y + H - D, D, D, 0, 90);
  Result.AddArc(X, Y + H - D, D, D, 90, 90);
  Result.CloseFigure;
end;

{ Silhouette (0/255) of a rounded rectangle — used as the shadow base. }
procedure RasterRoundRectAlpha(P: PByte; W, H, SX, SY, BW, BH, RR: Integer);
var
  X, Y, DY, Inset, X0, X1, CyTop, CyBot: Integer;
  Row: PByte;
begin
  if (BW <= 0) or (BH <= 0) then Exit;
  if RR < 0 then RR := 0;
  if RR > BW div 2 then RR := BW div 2;
  if RR > BH div 2 then RR := BH div 2;
  CyTop := SY + RR;
  CyBot := SY + BH - 1 - RR;
  for Y := SY to SY + BH - 1 do
  begin
    if (Y < 0) or (Y >= H) then Continue;
    if Y < CyTop then DY := CyTop - Y
    else if Y > CyBot then DY := Y - CyBot
    else DY := 0;
    if DY = 0 then Inset := 0
    else Inset := RR - Trunc(Sqrt(RR * RR - DY * DY) + 0.5);
    X0 := SX + Inset;
    X1 := SX + BW - 1 - Inset;
    if X0 < 0 then X0 := 0;
    if X1 > W - 1 then X1 := W - 1;
    if X1 < X0 then Continue;
    Row := P; Inc(Row, Y * W + X0);
    for X := X0 to X1 do begin Row^ := 255; Inc(Row); end;
  end;
end;

{ Box blur of the alpha channel (separable, Iter passes ≈ Gaussian). }
procedure BoxBlurAlpha(P: PByte; W, H, R, Iter: Integer);
var
  Tmp: TBytes;
  Pref: array of Integer;
  It, X, Y, L, R2, Cnt, Base: Integer;
  PB: PByte;
begin
  if (R < 1) or (W < 1) or (H < 1) then Exit;
  SetLength(Tmp, W * H);
  SetLength(Pref, Max(W, H) + 1);
  for It := 1 to Iter do
  begin
    for Y := 0 to H - 1 do
    begin
      Base := Y * W;
      Pref[0] := 0;
      PB := P; Inc(PB, Base);
      for X := 0 to W - 1 do begin Pref[X + 1] := Pref[X] + PB^; Inc(PB); end;
      for X := 0 to W - 1 do
      begin
        L := X - R; if L < 0 then L := 0;
        R2 := X + R; if R2 > W - 1 then R2 := W - 1;
        Cnt := R2 - L + 1;
        Tmp[Base + X] := (Pref[R2 + 1] - Pref[L]) div Cnt;
      end;
    end;
    for X := 0 to W - 1 do
    begin
      Pref[0] := 0;
      for Y := 0 to H - 1 do Pref[Y + 1] := Pref[Y] + Tmp[Y * W + X];
      for Y := 0 to H - 1 do
      begin
        L := Y - R; if L < 0 then L := 0;
        R2 := Y + R; if R2 > H - 1 then R2 := H - 1;
        Cnt := R2 - L + 1;
        PB := P; Inc(PB, Y * W + X);
        PB^ := (Pref[R2 + 1] - Pref[L]) div Cnt;
      end;
    end;
  end;
end;

{ ============================================================================ }
{  TCWSHintWindow                                                              }
{ ============================================================================ }

constructor TCWSHintWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  StyleElements := [];
  { THintWindow starts yellow; match Application.HintColor so a window shown
    without TApplication (ActivateHint called directly) uses the TCWSHint look }
  if Application <> nil then
    Color := Application.HintColor;
  FDpi := 96;
  FScale := 1;
end;

procedure TCWSHintWindow.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  { no WS_BORDER / CS_DROPSHADOW - border and shadow are part of the bitmap;
    WS_EX_TRANSPARENT lets the mouse through the transparent shadow margin }
  Params.Style := WS_POPUP;
  Params.WindowClass.Style := Params.WindowClass.Style and not CS_DROPSHADOW;
  Params.ExStyle := WS_EX_TOOLWINDOW or WS_EX_TOPMOST or WS_EX_NOACTIVATE or
    WS_EX_LAYERED or WS_EX_TRANSPARENT;
end;

procedure TCWSHintWindow.ComputeScale(const P: TPoint);
var
  Mon: TMonitor;
begin
  Mon := Screen.MonitorFromPoint(P);
  if Mon <> nil then FDpi := Mon.PixelsPerInch else FDpi := Screen.PixelsPerInch;
  if FDpi <= 0 then FDpi := 96;
  FScale := FDpi / 96;
end;

procedure TCWSHintWindow.UpdateShadowMetrics;
var
  Look: TCWSHintLook;
begin
  Look := CurrentLook;
  if Look.Shadow and (Look.ShadowSize > 0) then
  begin
    FBlur := Max(2, Round(Look.ShadowSize * FScale));
    FShadowOffset := Round(2 * FScale);
    FShadow := FBlur + FShadowOffset + Round(2 * FScale);
  end
  else
  begin
    FBlur := 0;
    FShadowOffset := 0;
    FShadow := 0;
  end;
end;

function TCWSHintWindow.MakeGdiFont: HFONT;
var
  Look: TCWSHintLook;
  LF: TLogFont;
begin
  Look := CurrentLook;
  FillChar(LF, SizeOf(LF), 0);
  { integral size in pixels - hinting works better than a fractional em size }
  if Look.Font.Size > 0 then
    LF.lfHeight := -Max(8, Round(Look.Font.Size * FDpi / 72))
  else
    LF.lfHeight := -Max(8, Round(Abs(Look.Font.Height) * FScale));
  if fsBold in Look.Font.Style then LF.lfWeight := FW_BOLD
  else LF.lfWeight := FW_NORMAL;
  LF.lfItalic := Byte(fsItalic in Look.Font.Style);
  LF.lfUnderline := Byte(fsUnderline in Look.Font.Style);
  LF.lfStrikeOut := Byte(fsStrikeOut in Look.Font.Style);
  LF.lfCharSet := DEFAULT_CHARSET;
  LF.lfOutPrecision := OUT_TT_PRECIS;
  LF.lfClipPrecision := CLIP_DEFAULT_PRECIS;
  LF.lfQuality := CLEARTYPE_QUALITY;
  LF.lfPitchAndFamily := DEFAULT_PITCH or FF_DONTCARE;
  StrPLCopy(LF.lfFaceName, Look.Font.Name, Length(LF.lfFaceName) - 1);
  Result := CreateFontIndirect(LF);
end;

{ Returns the size of the BODY (text + padding). The shadow margin is added
  around it in ActivateHint, so the body lands where TApplication puts it. }
function TCWSHintWindow.CalcHintRect(MaxWidth: Integer; const AHint: string;
  AData: TCustomData): TRect;
var
  Look: TCWSHintLook;
  PadH, PadV, TextMax: Integer;
  Cursor: TPoint;
  DC: HDC;
  Fnt, OldFnt: HFONT;
  TR: TRect;
begin
  Look := CurrentLook;
  if not GetCursorPos(Cursor) then
    Cursor := Point(0, 0);
  ComputeScale(Cursor);

  PadH := Round(Look.PaddingHorizontal * FScale);
  PadV := Round(Look.PaddingVertical * FScale);

  TextMax := MaxWidth;
  if Look.MaxWidth > 0 then
    TextMax := Min(TextMax, Round(Look.MaxWidth * FScale));
  Dec(TextMax, 2 * PadH);
  TextMax := Max(TextMax, Round(16 * FScale));

  TR := System.Types.Rect(0, 0, TextMax, 0);
  DC := GetDC(0);
  Fnt := MakeGdiFont;
  try
    OldFnt := SelectObject(DC, Fnt);
    Winapi.Windows.DrawText(DC, PChar(AHint), -1, TR, DT_CALCRECT or DT_LEFT or
      DT_WORDBREAK or DT_NOPREFIX or DrawTextBiDiModeFlagsReadingOnly);
    SelectObject(DC, OldFnt);
  finally
    DeleteObject(Fnt);
    ReleaseDC(0, DC);
  end;

  Result := System.Types.Rect(0, 0, TR.Width + 2 * PadH, TR.Height + 2 * PadV);
end;

procedure TCWSHintWindow.ActivateHint(Rect: TRect; const AHint: string);
var
  Mon: HMONITOR;
  MI: TMonitorInfo;
  WR: TRect;
  BodyLeft, BodyTop: Integer;
begin
  Caption := AHint;
  ComputeScale(Rect.TopLeft);
  UpdateShadowMetrics;

  FBodyW := Max(1, Rect.Width);
  FBodyH := Max(1, Rect.Height);
  BodyLeft := Rect.Left;
  BodyTop := Rect.Top;

  { keep the body on the work area of its monitor }
  Mon := MonitorFromPoint(Rect.TopLeft, MONITOR_DEFAULTTONEAREST);
  MI.cbSize := SizeOf(MI);
  if GetMonitorInfo(Mon, @MI) then
  begin
    WR := MI.rcWork;
    FBodyW := Min(FBodyW, WR.Width);
    FBodyH := Min(FBodyH, WR.Height);
    if BodyLeft + FBodyW > WR.Right then BodyLeft := WR.Right - FBodyW;
    if BodyTop + FBodyH > WR.Bottom then BodyTop := WR.Bottom - FBodyH;
    if BodyLeft < WR.Left then BodyLeft := WR.Left;
    if BodyTop < WR.Top then BodyTop := WR.Top;
  end;

  FWinLeft := BodyLeft - FShadow;
  FWinTop := BodyTop - FShadow;
  FWinW := FBodyW + FShadow * 2;
  FWinH := FBodyH + FShadow * 2;

  UpdateBoundsRect(System.Types.Rect(FWinLeft, FWinTop,
    FWinLeft + FWinW, FWinTop + FWinH));
  ParentWindow := Application.Handle;
  HandleNeeded;

  { UpdateLayeredWindow moves, resizes and fills the window in one step, so
    the window is never visible without its final content }
  Render;
  if not IsWindowVisible(Handle) then
    ShowWindow(Handle, SW_SHOWNOACTIVATE);
  SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0,
    SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_NOOWNERZORDER);
end;

procedure TCWSHintWindow.Render;
var
  Look: TCWSHintLook;
  BodyColor: TColor;
  BI: TBitmapInfo;
  Bits: Pointer;
  HBmp, OldBmp: HBITMAP;
  MemDC, ScreenDC: HDC;
  GBmp, ShImg: TGPBitmap;
  G: TGPGraphics;
  Path: TGPGraphicsPath;
  Brush: TGPSolidBrush;
  Pen: TGPPen;
  i, N, Border: Integer;
  Radius: Single;
  CovA, ShBits, SavedA: TBytes;
  PB: PByte;
  Fnt: HFONT;
  TR: TRect;
  Blend: TBlendFunction;
  PtSrc, PtDst: TPoint;
  Sz: TSize;
begin
  if not HandleAllocated then Exit;
  if (FWinW < 1) or (FWinH < 1) then Exit;
  Look := CurrentLook;
  { TApplication copies HintInfo.HintColor into Color before every hint -
    a value other than Application.HintColor was set for this one hint in
    OnShowHint / CM_HINTSHOW }
  if (Application <> nil) and (Color <> Application.HintColor) then
    BodyColor := Color
  else
    BodyColor := Look.Color;

  FillChar(BI, SizeOf(BI), 0);
  BI.bmiHeader.biSize := SizeOf(TBitmapInfoHeader);
  BI.bmiHeader.biWidth := FWinW;
  BI.bmiHeader.biHeight := -FWinH;
  BI.bmiHeader.biPlanes := 1;
  BI.bmiHeader.biBitCount := 32;
  BI.bmiHeader.biCompression := BI_RGB;

  HBmp := CreateDIBSection(0, BI, DIB_RGB_COLORS, Bits, 0, 0);
  if HBmp = 0 then Exit;
  MemDC := CreateCompatibleDC(0);
  OldBmp := SelectObject(MemDC, HBmp);
  try
    Radius := Look.CornerRadius * FScale;
    if Look.BorderThickness > 0 then
      Border := Max(1, Round(Look.BorderThickness * FScale))
    else
      Border := 0;

    { ══ layer 1: shadow, body, border - GDI+ ═══════════════════════════════ }
    GBmp := TGPBitmap.Create(FWinW, FWinH, FWinW * 4, PixelFormat32bppPARGB, Bits);
    try
      G := TGPGraphics.Create(GBmp);
      try
        G.SetSmoothingMode(SmoothingModeAntiAlias);
        G.SetPixelOffsetMode(PixelOffsetModeHighQuality);
        G.Clear(MakeColor(0, 0, 0, 0));

        if (FShadow > 0) and (FBlur > 0) then
        begin
          N := FWinW * FWinH;
          SetLength(CovA, N);
          RasterRoundRectAlpha(@CovA[0], FWinW, FWinH,
            FShadow, FShadow + FShadowOffset, FBodyW, FBodyH, Round(Radius));
          BoxBlurAlpha(@CovA[0], FWinW, FWinH, Max(1, FBlur div 3), 3);
          SetLength(ShBits, N * 4);
          for i := 0 to N - 1 do
            ShBits[i * 4 + 3] := CovA[i] * HINT_SHADOW_ALPHA div 255;
          ShImg := TGPBitmap.Create(FWinW, FWinH, FWinW * 4, PixelFormat32bppPARGB, @ShBits[0]);
          try G.DrawImage(ShImg, 0, 0, FWinW, FWinH); finally ShImg.Free; end;
        end;

        Path := CreateRRPath(FShadow, FShadow, FBodyW, FBodyH, Radius);
        Brush := TGPSolidBrush.Create(GPColor(BodyColor));
        try G.FillPath(Brush, Path); finally Brush.Free; Path.Free; end;

        if Border > 0 then
        begin
          Path := CreateRRPath(FShadow + Border / 2, FShadow + Border / 2,
            FBodyW - Border, FBodyH - Border, Radius - Border / 2);
          Pen := TGPPen.Create(GPColor(Look.BorderColor), Border);
          try G.DrawPath(Pen, Path); finally Pen.Free; Path.Free; end;
        end;
      finally
        G.Free;
      end;
    finally
      GBmp.Free;
    end;

    { ══ layer 2: text - GDI with ClearType ═════════════════════════════════
      GDI+ falls back to grayscale on a bitmap with alpha, so the text goes
      through GDI. GDI zeroes alpha in the glyph pixels, so alpha is saved and
      restored; the body under the text is opaque, so ClearType blends right. }
    N := FWinW * FWinH;
    SetLength(SavedA, N);
    PB := Bits; Inc(PB, 3);
    for i := 0 to N - 1 do
    begin
      SavedA[i] := PB^;
      Inc(PB, 4);
    end;

    Fnt := MakeGdiFont;
    SaveDC(MemDC);
    try
      SelectObject(MemDC, Fnt);
      SetBkMode(MemDC, TRANSPARENT);
      SetTextColor(MemDC, ColorToRGB(Look.Font.Color));
      TR := System.Types.Rect(FShadow, FShadow, FShadow + FBodyW, FShadow + FBodyH);
      InflateRect(TR, -Round(Look.PaddingHorizontal * FScale),
        -Round(Look.PaddingVertical * FScale));
      IntersectClipRect(MemDC, FShadow + Border, FShadow + Border,
        FShadow + FBodyW - Border, FShadow + FBodyH - Border);
      Winapi.Windows.DrawText(MemDC, PChar(Caption), -1, TR, DT_LEFT or
        DT_WORDBREAK or DT_NOPREFIX or DrawTextBiDiModeFlagsReadingOnly);
    finally
      RestoreDC(MemDC, -1);
      DeleteObject(Fnt);
    end;
    GdiFlush;

    PB := Bits; Inc(PB, 3);
    for i := 0 to N - 1 do
    begin
      PB^ := SavedA[i];
      Inc(PB, 4);
    end;

    ScreenDC := GetDC(0);
    try
      Blend.BlendOp := AC_SRC_OVER;
      Blend.BlendFlags := 0;
      Blend.SourceConstantAlpha := 255;
      Blend.AlphaFormat := AC_SRC_ALPHA;
      PtDst := Point(FWinLeft, FWinTop);
      PtSrc := Point(0, 0);
      Sz.cx := FWinW;
      Sz.cy := FWinH;
      UpdateLayeredWindow(Handle, ScreenDC, @PtDst, @Sz, MemDC, @PtSrc, 0,
        @Blend, ULW_ALPHA);
    finally
      ReleaseDC(0, ScreenDC);
    end;
  finally
    SelectObject(MemDC, OldBmp);
    DeleteDC(MemDC);
    DeleteObject(HBmp);
  end;
end;

procedure TCWSHintWindow.CMTextChanged(var Message: TMessage);
begin
  { THintWindow resizes itself to the bare text here; the size is set by
    ActivateHint, and the content by Render }
end;

procedure TCWSHintWindow.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TCWSHintWindow.NCPaint(DC: HDC);
begin
  { no non-client frame }
end;

procedure TCWSHintWindow.Paint;
begin
  { layered window - the content comes from UpdateLayeredWindow in Render }
end;

{ ============================================================================ }
{  TCWSHint                                                                    }
{ ============================================================================ }

constructor TCWSHint.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FActive            := True;
  FColor             := $00F9F9F9;
  FBorderColor       := $00E0E0E0;
  FBorderThickness   := 1;
  FCornerRadius      := 8;
  FShadow            := True;
  FShadowSize        := 10;
  FPaddingHorizontal := 8;
  FPaddingVertical   := 5;
  FMaxWidth          := 400;
  FHintPause         := 500;
  FHintHidePause     := 2500;
  FHintShortPause    := 0;
  FHintShortCuts     := True;

  FFont := TFont.Create;
  FFont.Name  := 'Segoe UI';
  FFont.Size  := 9;
  FFont.Color := $001A1A1A;

  { created in code: take over right away. When read from a DFM, Loaded does
    it once the streamed Active value is known (Install is idempotent). }
  if not (csDesigning in ComponentState) and
     ((AOwner = nil) or not (csLoading in AOwner.ComponentState)) then
    Install;
end;

destructor TCWSHint.Destroy;
begin
  Uninstall;
  FFont.Free;
  inherited Destroy;
end;

procedure TCWSHint.Loaded;
begin
  inherited Loaded;
  if csDesigning in ComponentState then
    Exit;
  if FActive then
    Install
  else
    Uninstall;
end;

class function TCWSHint.ActiveHint: TCWSHint;
begin
  if (GInstances <> nil) and (GInstances.Count > 0) then
    Result := GInstances.Last
  else
    Result := nil;
end;

procedure TCWSHint.Install;
begin
  if csDesigning in ComponentState then
    Exit;
  if GInstances = nil then
    GInstances := TList<TCWSHint>.Create;
  if GInstances.Contains(Self) then
    Exit;

  if GInstances.Count = 0 then
  begin
    GOriginalHintClass := Vcl.Forms.HintWindowClass;
    if Application <> nil then
    begin
      GOriginalHintPause      := Application.HintPause;
      GOriginalHintHidePause  := Application.HintHidePause;
      GOriginalHintShortPause := Application.HintShortPause;
      GOriginalHintShortCuts  := Application.HintShortCuts;
      GPrevOnShowHint := Application.OnShowHint;
      Application.OnShowHint := TCWSHintDispatcher.DoShowHint;
    end;
  end;
  GInstances.Add(Self);
  ApplyApplicationSettings;
  { TApplication recreates its hint window on the next hint, because the
    class no longer matches (TApplication.ActivateHint / ValidateHintWindow) }
  Vcl.Forms.HintWindowClass := TCWSHintWindow;
  if Application <> nil then
    Application.CancelHint;
end;

procedure TCWSHint.Uninstall;
begin
  if (GInstances = nil) or not GInstances.Contains(Self) then
    Exit;
  GInstances.Remove(Self);
  if GInstances.Count = 0 then
  begin
    if Vcl.Forms.HintWindowClass = TCWSHintWindow then
      Vcl.Forms.HintWindowClass := GOriginalHintClass;
    GOriginalHintClass := nil;
    if Application <> nil then
    begin
      Application.HintPause      := GOriginalHintPause;
      Application.HintHidePause  := GOriginalHintHidePause;
      Application.HintShortPause := GOriginalHintShortPause;
      Application.HintShortCuts  := GOriginalHintShortCuts;
      { only if nobody replaced the handler in the meantime }
      if IsDispatcherInstalled then
        Application.OnShowHint := GPrevOnShowHint;
    end;
    GPrevOnShowHint := nil;
  end
  else
    GInstances.Last.ApplyApplicationSettings;   { hand over to the previous one }
  if (Application <> nil) and not Application.Terminated then
    Application.CancelHint;
end;

procedure TCWSHint.SetActive(Value: Boolean);
begin
  if FActive = Value then
    Exit;
  FActive := Value;
  if (csDesigning in ComponentState) or (csLoading in ComponentState) then
    Exit;
  if FActive then
    Install
  else
    Uninstall;
end;

procedure TCWSHint.SetFont(Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TCWSHint.SetBorderThickness(Value: Integer);
begin
  FBorderThickness := Max(0, Value);
end;

procedure TCWSHint.SetCornerRadius(Value: Integer);
begin
  FCornerRadius := Max(0, Value);
end;

procedure TCWSHint.SetShadowSize(Value: Integer);
begin
  FShadowSize := Max(0, Value);
end;

procedure TCWSHint.SetPaddingHorizontal(Value: Integer);
begin
  FPaddingHorizontal := Max(0, Value);
end;

procedure TCWSHint.SetPaddingVertical(Value: Integer);
begin
  FPaddingVertical := Max(0, Value);
end;

procedure TCWSHint.SetMaxWidth(Value: Integer);
begin
  FMaxWidth := Max(0, Value);
end;

{ Writes the pauses and HintShortCuts to Application - only for the instance
  supplying the look }
procedure TCWSHint.ApplyApplicationSettings;
begin
  if (Application = nil) or (ActiveHint <> Self) then
    Exit;
  Application.HintPause      := FHintPause;
  Application.HintHidePause  := FHintHidePause;
  Application.HintShortPause := FHintShortPause;
  Application.HintShortCuts  := FHintShortCuts;
end;

procedure TCWSHint.SetHintShortCuts(Value: Boolean);
begin
  FHintShortCuts := Value;
  ApplyApplicationSettings;
end;

procedure TCWSHint.SetHintPause(Value: Integer);
begin
  FHintPause := Max(0, Value);
  ApplyApplicationSettings;
end;

procedure TCWSHint.SetHintHidePause(Value: Integer);
begin
  FHintHidePause := Max(0, Value);
  ApplyApplicationSettings;
end;

procedure TCWSHint.SetHintShortPause(Value: Integer);
begin
  FHintShortPause := Max(0, Value);
  ApplyApplicationSettings;
end;

initialization

finalization
  if (GOriginalHintClass <> nil) and (Vcl.Forms.HintWindowClass = TCWSHintWindow) then
    Vcl.Forms.HintWindowClass := GOriginalHintClass;
  if IsDispatcherInstalled then
    Application.OnShowHint := GPrevOnShowHint;
  FreeAndNil(GInstances);

end.
