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
unit CWSLabelColumn;

{
  TCWSLabelColumn - a two-column label.

  Draws two independent texts side by side: a LEFT column and a RIGHT column,
  each with its own full font (LeftFont / RightFont), alignment and width.

  Marquee:
    When a column's text is wider than its column width (so it would run into
    the other column) it is auto-scrolled: after a pause showing the beginning,
    it scrolls to the end of the text, pauses, scrolls back to the beginning,
    pauses, and repeats. The two columns never overlap.

    ScrollColumns chooses which columns may scroll (left / right / both); each
    column has its own independent speed (LeftScrollStep / RightScrollStep) and
    its own soft fade-out on the edges (EdgeFade). The scroll repaints itself
    directly (no Invalidate), so neither the static column nor the parent
    background flicker.

  Column geometry:
    LeftColumnWidth / RightColumnWidth - the base widths in pixels.
    ColumnSpacing                      - gap kept between the two columns.
    StretchColumn                      - which column absorbs the extra width
                                         when the control is wider than
                                         Left + Spacing + Right:
                                           lcNone  - neither (trailing space
                                                     stays empty)
                                           lcLeft  - the left column grows
                                           lcRight - the right column grows
    The left column is anchored to the left edge, the right column to the
    right edge.
}

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  System.SysUtils, System.Classes, System.Math,
  Vcl.Controls, Vcl.Graphics, Vcl.ExtCtrls;

type
  // Which column absorbs the extra horizontal space (the "anchor" of the
  // stretch behaviour).
  TCWSStretchColumn = (lcNone, lcLeft, lcRight);

  // Which columns are allowed to scroll when their text overflows.
  TCWSScrollColumns = (sclLeft, sclRight, sclBoth);

  // Internal marquee state machine (per column).
  TCWSScrollState = (ssStartPause, ssForward, ssEndPause, ssBackward);

  // Per-column scroll animation state + its clean-background snapshot.
  TCWSScrollCol = record
    Active: Boolean;
    Offset: Integer;
    MaxOffset: Integer;
    State: TCWSScrollState;
    PauseElapsed: Integer;
    BgValid: Boolean;
    Bg: TBitmap;          // clean parent background behind this column
  end;

  TCWSLabelColumn = class(TGraphicControl)
  private
    FLeftText: string;
    FRightText: string;
    FLeftFont: TFont;
    FRightFont: TFont;
    FLeftColumnWidth: Integer;
    FRightColumnWidth: Integer;
    FColumnSpacing: Integer;
    FStretchColumn: TCWSStretchColumn;
    FLeftAlignment: TAlignment;
    FRightAlignment: TAlignment;
    FTransparent: Boolean;

    FScrollEnabled: Boolean;
    FScrollColumns: TCWSScrollColumns;
    FScrollInterval: Integer;
    FLeftScrollStep: Integer;
    FRightScrollStep: Integer;
    FScrollPause: Integer;
    FEdgeFade: Boolean;
    FEdgeFadeWidth: Integer;

    FTimer: TTimer;
    FMeasureBmp: TBitmap;
    FScrollBuf: TBitmap;          // shared off-screen compose buffer
    FLeft: TCWSScrollCol;
    FRight: TCWSScrollCol;

    // The two edge-fade strips, pre-rendered once as premultiplied 32-bit
    // bitmaps and alpha-blended per frame. The fade does not depend on the
    // marquee offset — only on its width, the column height and Color — so
    // building it per frame (a TGPGraphics plus a TGPLinearGradientBrush, in
    // GDI+, twice a column) was rebuilding an identical picture 33 times a
    // second. FFadeKeyW/H/Color is what the cached pair was built for.
    FFadeL, FFadeR: TBitmap;
    FFadeKeyW, FFadeKeyH: Integer;
    FFadeKeyColor: TColor;
    procedure EnsureFadeStrips(AW, AH: Integer);

    procedure SetLeftText(const Value: string);
    procedure SetRightText(const Value: string);
    procedure SetLeftFont(Value: TFont);
    procedure SetRightFont(Value: TFont);
    procedure SetLeftColumnWidth(Value: Integer);
    procedure SetRightColumnWidth(Value: Integer);
    procedure SetColumnSpacing(Value: Integer);
    procedure SetStretchColumn(Value: TCWSStretchColumn);
    procedure SetLeftAlignment(Value: TAlignment);
    procedure SetRightAlignment(Value: TAlignment);
    procedure SetTransparent(Value: Boolean);
    procedure SetScrollEnabled(Value: Boolean);
    procedure SetScrollColumns(Value: TCWSScrollColumns);
    procedure SetScrollInterval(Value: Integer);
    procedure SetLeftScrollStep(Value: Integer);
    procedure SetRightScrollStep(Value: Integer);
    procedure SetScrollPause(Value: Integer);
    procedure SetEdgeFade(Value: Boolean);
    procedure SetEdgeFadeWidth(Value: Integer);

    procedure FontChanged(Sender: TObject);
    procedure TimerTick(Sender: TObject);
    procedure CalcColumns(out ALeft, ARight: TRect);
    function MeasureTextWidth(AFont: TFont; const AText: string): Integer;
    function ScaledPadding: Integer;
    procedure UpdateScrollState;
    function AdvanceCol(var Col: TCWSScrollCol; AStep: Integer): Boolean;
    procedure CaptureColBackground(var Col: TCWSScrollCol; const ARect: TRect);
    procedure DrawColumnFrame(var Col: TCWSScrollCol; const ARect: TRect;
      const AText: string; AFont: TFont);
    procedure DrawColumn(ACanvas: TCanvas; const ARect: TRect; const AText: string;
      AFont: TFont; AAlignment: TAlignment; AScrolling: Boolean; AOffset: Integer;
      AEllipsis: Boolean);
    procedure DrawEdgeFade(ACanvas: TCanvas; const ARect: TRect;
      AFadeLeft, AFadeRight: Boolean);

    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure Loaded; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property LeftText: string read FLeftText write SetLeftText;
    property RightText: string read FRightText write SetRightText;
    property LeftFont: TFont read FLeftFont write SetLeftFont;
    property RightFont: TFont read FRightFont write SetRightFont;
    property LeftColumnWidth: Integer read FLeftColumnWidth write SetLeftColumnWidth default 100;
    property RightColumnWidth: Integer read FRightColumnWidth write SetRightColumnWidth default 80;
    property ColumnSpacing: Integer read FColumnSpacing write SetColumnSpacing default 8;
    property StretchColumn: TCWSStretchColumn read FStretchColumn write SetStretchColumn default lcLeft;
    property LeftAlignment: TAlignment read FLeftAlignment write SetLeftAlignment default taLeftJustify;
    property RightAlignment: TAlignment read FRightAlignment write SetRightAlignment default taRightJustify;
    property Transparent: Boolean read FTransparent write SetTransparent default True;

    // Marquee: master switch, which columns scroll, and per-column speed.
    property ScrollEnabled: Boolean read FScrollEnabled write SetScrollEnabled default True;
    property ScrollColumns: TCWSScrollColumns read FScrollColumns write SetScrollColumns default sclLeft;
    property ScrollInterval: Integer read FScrollInterval write SetScrollInterval default 30;
    property LeftScrollStep: Integer read FLeftScrollStep write SetLeftScrollStep default 1;
    property RightScrollStep: Integer read FRightScrollStep write SetRightScrollStep default 1;
    property ScrollPause: Integer read FScrollPause write SetScrollPause default 1500;
    // Soft fade-out on a scrolling column's edges so the text blends into the
    // background instead of being hard-clipped. The fade target is Color, so for
    // a transparent label set ParentColor := True (or match Color to the parent).
    property EdgeFade: Boolean read FEdgeFade write SetEdgeFade default True;
    property EdgeFadeWidth: Integer read FEdgeFadeWidth write SetEdgeFadeWidth default 18;

    property Align;
    property Anchors;
    property Color;
    property Constraints;
    property Cursor;
    property Enabled;
    property ParentColor;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

const
  TEXT_PADDING = 2;  // small inner padding so text does not touch the edges

{ TCWSLabelColumn }

constructor TCWSLabelColumn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width  := 188;   // 100 + 8 + 80 by default
  Height := 21;

  FLeftFont := TFont.Create;
  FLeftFont.OnChange := FontChanged;
  FRightFont := TFont.Create;
  FRightFont.OnChange := FontChanged;

  FLeftColumnWidth  := 100;
  FRightColumnWidth := 80;
  FColumnSpacing    := 8;
  FStretchColumn    := lcLeft;
  FLeftAlignment    := taLeftJustify;
  FRightAlignment   := taRightJustify;
  FTransparent      := True;

  FScrollEnabled   := True;
  FScrollColumns   := sclLeft;
  FScrollInterval  := 30;
  FLeftScrollStep  := 1;
  FRightScrollStep := 1;
  FScrollPause     := 1500;
  FEdgeFade        := True;
  FEdgeFadeWidth   := 18;

  FMeasureBmp := TBitmap.Create;
  FMeasureBmp.SetSize(1, 1);

  FScrollBuf := TBitmap.Create;
  FScrollBuf.PixelFormat := pf32bit;

  FLeft.Bg := TBitmap.Create;
  FLeft.Bg.PixelFormat := pf32bit;
  FRight.Bg := TBitmap.Create;
  FRight.Bg.PixelFormat := pf32bit;

  FFadeL := TBitmap.Create;
  FFadeR := TBitmap.Create;

  FTimer := TTimer.Create(nil);
  FTimer.Enabled  := False;
  FTimer.Interval := FScrollInterval;
  FTimer.OnTimer  := TimerTick;
end;

destructor TCWSLabelColumn.Destroy;
begin
  FTimer.Free;
  FMeasureBmp.Free;
  FScrollBuf.Free;
  FFadeL.Free;
  FFadeR.Free;
  FLeft.Bg.Free;
  FRight.Bg.Free;
  FLeftFont.Free;
  FRightFont.Free;
  inherited Destroy;
end;

{ (Re)build the two edge-fade strips for a column AW wide and AH tall.
  The ramp is the one TGPLinearGradientBrush produced: a linear interpolation of
  ALPHA from fully opaque at the outer edge to fully transparent inward, over a
  constant Color. Written straight into a premultiplied 32-bit DIB, it is then
  put on by TCanvas.Draw, which for afPremultiplied goes to AlphaBlend — the same
  picture as before, minus a GDI+ rendering context and two gradient brushes
  constructed and destroyed on every frame. }
procedure TCWSLabelColumn.EnsureFadeStrips(AW, AH: Integer);
var
  cr: LongInt;
  R, G, B: Byte;
  X, Y, A: Integer;
  RowL, RowR: PCardinal;
begin
  if (AW <= 0) or (AH <= 0) then
    Exit;
  if (FFadeKeyW = AW) and (FFadeKeyH = AH) and (FFadeKeyColor = Color) and
     (FFadeL.Width = AW) and (FFadeL.Height = AH) then
    Exit;

  cr := ColorToRGB(Color);
  R := GetRValue(cr);
  G := GetGValue(cr);
  B := GetBValue(cr);

  FFadeL.PixelFormat := pf32bit;
  FFadeR.PixelFormat := pf32bit;
  FFadeL.SetSize(AW, AH);
  FFadeR.SetSize(AW, AH);
  { SetSize resets the format on some paths — pin it, and only then declare the
    channel premultiplied, or TBitmap will try to convert what we are about to
    write instead of taking it as given. }
  FFadeL.PixelFormat := pf32bit;
  FFadeR.PixelFormat := pf32bit;

  for Y := 0 to AH - 1 do
  begin
    RowL := FFadeL.ScanLine[Y];
    RowR := FFadeR.ScanLine[Y];
    for X := 0 to AW - 1 do
    begin
      { Opaque at the outer edge, clear inward — mirrored for the right strip. }
      A := 255 - MulDiv(X, 255, AW);
      { Premultiplied: the colour channels carry the coverage already. }
      PCardinal(PByte(RowL) + X * 4)^ :=
        (Cardinal(A) shl 24) or (Cardinal(R * A div 255) shl 16) or
        (Cardinal(G * A div 255) shl 8) or Cardinal(B * A div 255);
      PCardinal(PByte(RowR) + (AW - 1 - X) * 4)^ :=
        (Cardinal(A) shl 24) or (Cardinal(R * A div 255) shl 16) or
        (Cardinal(G * A div 255) shl 8) or Cardinal(B * A div 255);
    end;
  end;

  FFadeL.AlphaFormat := afPremultiplied;
  FFadeR.AlphaFormat := afPremultiplied;
  FFadeKeyW := AW;
  FFadeKeyH := AH;
  FFadeKeyColor := Color;
end;

procedure TCWSLabelColumn.Loaded;
begin
  inherited Loaded;
  UpdateScrollState;
end;

{ High-DPI scaling. The inherited call scales the control bounds and its own
  Font; the column widths, spacing, fade width, scroll steps and the two custom
  fonts (LeftFont / RightFont) are independent and must be scaled by hand. }
procedure TCWSLabelColumn.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited ChangeScale(M, D, isDpiChange);
  if M = D then
    Exit;

  FLeftColumnWidth  := MulDiv(FLeftColumnWidth, M, D);
  FRightColumnWidth := MulDiv(FRightColumnWidth, M, D);
  FColumnSpacing    := MulDiv(FColumnSpacing, M, D);
  FEdgeFadeWidth    := MulDiv(FEdgeFadeWidth, M, D);
  FLeftScrollStep   := Max(1, MulDiv(FLeftScrollStep, M, D));
  FRightScrollStep  := Max(1, MulDiv(FRightScrollStep, M, D));

  FLeftFont.Height  := MulDiv(FLeftFont.Height, M, D);
  FRightFont.Height := MulDiv(FRightFont.Height, M, D);

  UpdateScrollState;
  Invalidate;
end;

procedure TCWSLabelColumn.CMColorChanged(var Message: TMessage);
begin
  inherited;
  FLeft.BgValid := False;
  FRight.BgValid := False;
  Invalidate;
end;

{ --- Property setters --- }

procedure TCWSLabelColumn.SetLeftText(const Value: string);
begin
  if FLeftText <> Value then
  begin
    FLeftText := Value;
    UpdateScrollState;
    Invalidate;
  end;
end;

procedure TCWSLabelColumn.SetRightText(const Value: string);
begin
  if FRightText <> Value then
  begin
    FRightText := Value;
    UpdateScrollState;
    Invalidate;
  end;
end;

procedure TCWSLabelColumn.SetLeftFont(Value: TFont);
begin
  FLeftFont.Assign(Value);
end;

procedure TCWSLabelColumn.SetRightFont(Value: TFont);
begin
  FRightFont.Assign(Value);
end;

procedure TCWSLabelColumn.SetLeftColumnWidth(Value: Integer);
begin
  if Value < 0 then
    Value := 0;
  if FLeftColumnWidth <> Value then
  begin
    FLeftColumnWidth := Value;
    UpdateScrollState;
    Invalidate;
  end;
end;

procedure TCWSLabelColumn.SetRightColumnWidth(Value: Integer);
begin
  if Value < 0 then
    Value := 0;
  if FRightColumnWidth <> Value then
  begin
    FRightColumnWidth := Value;
    UpdateScrollState;
    Invalidate;
  end;
end;

procedure TCWSLabelColumn.SetColumnSpacing(Value: Integer);
begin
  if Value < 0 then
    Value := 0;
  if FColumnSpacing <> Value then
  begin
    FColumnSpacing := Value;
    UpdateScrollState;
    Invalidate;
  end;
end;

procedure TCWSLabelColumn.SetStretchColumn(Value: TCWSStretchColumn);
begin
  if FStretchColumn <> Value then
  begin
    FStretchColumn := Value;
    UpdateScrollState;
    Invalidate;
  end;
end;

procedure TCWSLabelColumn.SetLeftAlignment(Value: TAlignment);
begin
  if FLeftAlignment <> Value then
  begin
    FLeftAlignment := Value;
    Invalidate;
  end;
end;

procedure TCWSLabelColumn.SetRightAlignment(Value: TAlignment);
begin
  if FRightAlignment <> Value then
  begin
    FRightAlignment := Value;
    Invalidate;
  end;
end;

procedure TCWSLabelColumn.SetTransparent(Value: Boolean);
begin
  if FTransparent <> Value then
  begin
    FTransparent := Value;
    FLeft.BgValid := False;
    FRight.BgValid := False;
    Invalidate;
  end;
end;

procedure TCWSLabelColumn.SetScrollEnabled(Value: Boolean);
begin
  if FScrollEnabled <> Value then
  begin
    FScrollEnabled := Value;
    UpdateScrollState;
    Invalidate;
  end;
end;

procedure TCWSLabelColumn.SetScrollColumns(Value: TCWSScrollColumns);
begin
  if FScrollColumns <> Value then
  begin
    FScrollColumns := Value;
    UpdateScrollState;
    Invalidate;
  end;
end;

procedure TCWSLabelColumn.SetScrollInterval(Value: Integer);
begin
  if Value < 10 then
    Value := 10;
  if FScrollInterval <> Value then
  begin
    FScrollInterval := Value;
    FTimer.Interval := Value;
  end;
end;

procedure TCWSLabelColumn.SetLeftScrollStep(Value: Integer);
begin
  if Value < 1 then
    Value := 1;
  FLeftScrollStep := Value;
end;

procedure TCWSLabelColumn.SetRightScrollStep(Value: Integer);
begin
  if Value < 1 then
    Value := 1;
  FRightScrollStep := Value;
end;

procedure TCWSLabelColumn.SetScrollPause(Value: Integer);
begin
  if Value < 0 then
    Value := 0;
  FScrollPause := Value;
end;

procedure TCWSLabelColumn.SetEdgeFade(Value: Boolean);
begin
  if FEdgeFade <> Value then
  begin
    FEdgeFade := Value;
    Invalidate;
  end;
end;

procedure TCWSLabelColumn.SetEdgeFadeWidth(Value: Integer);
begin
  if Value < 0 then
    Value := 0;
  if FEdgeFadeWidth <> Value then
  begin
    FEdgeFadeWidth := Value;
    Invalidate;
  end;
end;

{ --- Notifications --- }

procedure TCWSLabelColumn.FontChanged(Sender: TObject);
begin
  UpdateScrollState;
  Invalidate;
end;

procedure TCWSLabelColumn.Resize;
begin
  inherited Resize;
  UpdateScrollState;
end;

{ --- Geometry --- }

procedure TCWSLabelColumn.CalcColumns(out ALeft, ARight: TRect);
var
  W, LW, RW, Extra: Integer;
begin
  W  := Width;
  LW := FLeftColumnWidth;
  RW := FRightColumnWidth;

  Extra := W - (LW + FColumnSpacing + RW);
  if Extra > 0 then
    case FStretchColumn of
      lcLeft:  Inc(LW, Extra);
      lcRight: Inc(RW, Extra);
    end;

  if LW < 0 then LW := 0;
  if RW < 0 then RW := 0;

  // left column anchored to the left edge, right column to the right edge
  ALeft  := Rect(0, 0, LW, Height);
  ARight := Rect(W - RW, 0, W, Height);

  // never let the left column run into the right one
  if ALeft.Right > ARight.Left - FColumnSpacing then
    ALeft.Right := Max(ALeft.Left, ARight.Left - FColumnSpacing);
end;

function TCWSLabelColumn.MeasureTextWidth(AFont: TFont; const AText: string): Integer;
begin
  if AText = '' then
    Exit(0);
  FMeasureBmp.Canvas.Font := AFont;
  Result := FMeasureBmp.Canvas.TextWidth(AText);
end;

function TCWSLabelColumn.ScaledPadding: Integer;
var
  PPI: Integer;
begin
  PPI := CurrentPPI;
  if PPI <= 0 then
    PPI := 96;
  Result := MulDiv(TEXT_PADDING, PPI, 96);
end;

procedure TCWSLabelColumn.UpdateScrollState;
var
  LeftR, RightR: TRect;

  procedure ComputeCol(var Col: TCWSScrollCol; const ARect: TRect; AFont: TFont;
    const AText: string; AAllowed: Boolean);
  var
    Avail, TextW: Integer;
    Need: Boolean;
  begin
    Avail := (ARect.Right - ARect.Left) - 2 * ScaledPadding;
    TextW := MeasureTextWidth(AFont, AText);
    Col.MaxOffset := TextW - Avail;
    if Col.MaxOffset < 0 then
      Col.MaxOffset := 0;

    Need := AAllowed and (Col.MaxOffset > 0) and not (csDesigning in ComponentState);
    if Need then
    begin
      if not Col.Active then
      begin
        Col.Active := True;
        Col.Offset := 0;
        Col.State := ssStartPause;
        Col.PauseElapsed := 0;
      end
      else if Col.Offset > Col.MaxOffset then
        Col.Offset := Col.MaxOffset;
    end
    else
    begin
      Col.Active := False;
      Col.Offset := 0;
    end;
    Col.BgValid := False;   // geometry/text changed -> snapshot no longer lines up
  end;

begin
  if (csDestroying in ComponentState) or (FMeasureBmp = nil) then
    Exit;

  CalcColumns(LeftR, RightR);
  ComputeCol(FLeft,  LeftR,  FLeftFont,  FLeftText,
    FScrollEnabled and (FScrollColumns in [sclLeft, sclBoth]));
  ComputeCol(FRight, RightR, FRightFont, FRightText,
    FScrollEnabled and (FScrollColumns in [sclRight, sclBoth]));

  if FLeft.Active or FRight.Active then
  begin
    FTimer.Interval := FScrollInterval;
    FTimer.Enabled  := True;
  end
  else
    FTimer.Enabled := False;
end;

{ --- Marquee animation --- }

{ Advance one column's state machine by AStep pixels; returns True if the
  visible offset changed (i.e. the column needs to be repainted this frame). }
function TCWSLabelColumn.AdvanceCol(var Col: TCWSScrollCol; AStep: Integer): Boolean;
begin
  Result := False;
  case Col.State of
    ssStartPause:
      begin
        Inc(Col.PauseElapsed, FTimer.Interval);
        if Col.PauseElapsed >= FScrollPause then
        begin
          Col.State := ssForward;
          Col.PauseElapsed := 0;
        end;
      end;

    ssForward:
      begin
        Inc(Col.Offset, AStep);
        if Col.Offset >= Col.MaxOffset then
        begin
          Col.Offset := Col.MaxOffset;
          Col.State := ssEndPause;
          Col.PauseElapsed := 0;
        end;
        Result := True;
      end;

    ssEndPause:
      begin
        Inc(Col.PauseElapsed, FTimer.Interval);
        if Col.PauseElapsed >= FScrollPause then
        begin
          Col.State := ssBackward;
          Col.PauseElapsed := 0;
        end;
      end;

    ssBackward:
      begin
        Dec(Col.Offset, AStep);
        if Col.Offset <= 0 then
        begin
          Col.Offset := 0;
          Col.State := ssStartPause;
          Col.PauseElapsed := 0;
        end;
        Result := True;
      end;
  end;
end;

procedure TCWSLabelColumn.TimerTick(Sender: TObject);
var
  LeftR, RightR: TRect;
  DrawL, DrawR: Boolean;
begin
  DrawL := FLeft.Active  and AdvanceCol(FLeft,  FLeftScrollStep);
  DrawR := FRight.Active and AdvanceCol(FRight, FRightScrollStep);
  if not (DrawL or DrawR) then
    Exit;

  CalcColumns(LeftR, RightR);
  if DrawL then
    DrawColumnFrame(FLeft, LeftR, FLeftText, FLeftFont);
  if DrawR then
    DrawColumnFrame(FRight, RightR, FRightText, FRightFont);
end;

{ --- Painting --- }

procedure TCWSLabelColumn.DrawColumn(ACanvas: TCanvas; const ARect: TRect;
  const AText: string; AFont: TFont; AAlignment: TAlignment; AScrolling: Boolean;
  AOffset: Integer; AEllipsis: Boolean);
var
  Flags: Cardinal;
  R: TRect;
  SavedDC: Integer;
  X, Y, Pad: Integer;
begin
  if (AText = '') or (ARect.Right <= ARect.Left) then
    Exit;

  Pad := ScaledPadding;
  ACanvas.Font := AFont;
  ACanvas.Brush.Style := bsClear;

  if AScrolling then
  begin
    // Marquee: draw manually, clipped to the column, shifted left by AOffset.
    // Always left-aligned + no ellipsis (the alignment only applies at rest).
    SavedDC := SaveDC(ACanvas.Handle);
    try
      IntersectClipRect(ACanvas.Handle, ARect.Left, ARect.Top,
        ARect.Right, ARect.Bottom);
      X := ARect.Left + Pad - AOffset;
      { TextHeight('Wg'), not TextHeight(AText): GetTextExtentPoint32 returns the
        selected FONT's height whatever the string, so the two agree exactly — but
        the second one walks the entire marquee text to find that out, and this
        runs on every frame. }
      Y := ARect.Top + (ARect.Bottom - ARect.Top - ACanvas.TextHeight('Wg')) div 2;
      ACanvas.TextOut(X, Y, AText);
    finally
      RestoreDC(ACanvas.Handle, SavedDC);
    end;
    Exit;
  end;

  // Static: let DrawText handle alignment, vertical centering and ellipsis.
  R := ARect;
  Inc(R.Left, Pad);
  Dec(R.Right, Pad);

  Flags := DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX;
  case AAlignment of
    taRightJustify: Flags := Flags or DT_RIGHT;
    taCenter:       Flags := Flags or DT_CENTER;
  else
    Flags := Flags or DT_LEFT;
  end;
  if AEllipsis then
    Flags := Flags or DT_END_ELLIPSIS;

  Winapi.Windows.DrawText(ACanvas.Handle, PChar(AText), Length(AText), R, Flags);
end;

{ Soft alpha fade on a scrolling column's edges. Drawn over the text with GDI+,
  blending into the background color (Color). The left edge only fades once text
  has scrolled off the left (offset > 0) and the right edge only while there is
  still text to reveal (offset < MaxOffset), so a fully visible end never gets
  dimmed. }
procedure TCWSLabelColumn.DrawEdgeFade(ACanvas: TCanvas; const ARect: TRect;
  AFadeLeft, AFadeRight: Boolean);
var
  FadeW, H: Integer;
begin
  H := ARect.Bottom - ARect.Top;
  if (H <= 0) or not (AFadeLeft or AFadeRight) then
    Exit;

  FadeW := FEdgeFadeWidth;
  if FadeW > (ARect.Right - ARect.Left) div 2 then
    FadeW := (ARect.Right - ARect.Left) div 2;
  if FadeW <= 0 then
    Exit;

  { Both strips are built once for this width/height/colour and then simply
    blended on — see EnsureFadeStrips. This is the marquee's per-frame path and
    it used to construct a GDI+ rendering context and up to two gradient brushes
    every time through it, per column, ~33 times a second, for a picture that
    never changed. }
  EnsureFadeStrips(FadeW, H);
  if (FFadeL.Width <> FadeW) or (FFadeL.Height <> H) then
    Exit;

  if AFadeLeft then
    ACanvas.Draw(ARect.Left, ARect.Top, FFadeL);
  if AFadeRight then
    ACanvas.Draw(ARect.Right - FadeW, ARect.Top, FFadeR);
end;

{ Snapshot the clean background of a column (no text yet) so that the per-frame
  scroll can repaint over it without going through the parent. Called from Paint,
  right after the background is present on the Canvas and before the text. }
procedure TCWSLabelColumn.CaptureColBackground(var Col: TCWSScrollCol; const ARect: TRect);
var
  W, H: Integer;
begin
  W := ARect.Right - ARect.Left;
  H := ARect.Bottom - ARect.Top;
  if (W <= 0) or (H <= 0) then
  begin
    Col.BgValid := False;
    Exit;
  end;
  if (Col.Bg.Width <> W) or (Col.Bg.Height <> H) then
    Col.Bg.SetSize(W, H);
  // Canvas origin is the control's top-left, so ARect is the source position.
  BitBlt(Col.Bg.Canvas.Handle, 0, 0, W, H, Canvas.Handle, ARect.Left, ARect.Top, SRCCOPY);
  Col.BgValid := True;
end;

{ One marquee frame for a column, drawn straight to the control's Canvas (no
  Invalidate, so the parent is never asked to repaint and nothing flickers). The
  frame is composed off-screen from the cached clean background plus the shifted
  text and the edge fade, then blitted in a single operation. The other column
  is never touched. }
procedure TCWSLabelColumn.DrawColumnFrame(var Col: TCWSScrollCol; const ARect: TRect;
  const AText: string; AFont: TFont);
var
  W, H: Integer;
  LocalR: TRect;
begin
  if (Parent = nil) or not Parent.HandleAllocated or not Visible or
     not Parent.Showing then
  begin
    Invalidate;
    Exit;
  end;

  W := ARect.Right - ARect.Left;
  H := ARect.Bottom - ARect.Top;
  if (W <= 0) or (H <= 0) then
    Exit;

  // The Canvas of a TGraphicControl is a TControlCanvas borrowing the PARENT's
  // DC, and once it has been touched outside Paint it KEEPS that DC open. A
  // retained DC carries the visible region it was created with; it never learns
  // that the parent window has moved since — which is exactly what a scrolling
  // host does on every step (TCWSScrollBox scrolls by moving its content
  // window). So the marquee was blitting through a clip that described where the
  // control used to be. Taking a fresh DC per frame is what makes the visibility
  // test below true, and it hands the DC back between frames instead of holding
  // one open for the lifetime of the control.
  TControlCanvas(Canvas).FreeHandle;
  try
    // Visible and Parent.Showing say nothing about being ON SCREEN. Inside a
    // scrollbox the parent is as tall as the CONTENT, so a label scrolled
    // thousands of pixels out of view is still Visible, its parent is still
    // Showing, and it went on composing and blitting a frame nobody can see —
    // two BitBlts, a TextOut and a GDI+ gradient per column — 33 times a second,
    // for as long as the form was open. Every such label was paying that, all of
    // them at once, and WM_TIMER is a low-priority message: while a drag keeps
    // the queue busy the ticks pile up and are then delivered in a burst the
    // moment it drains, which is what made the scrolling hitch.
    // The DC's visible region answers "is any of this on screen" exactly, and
    // costs one call.
    if not RectVisible(Canvas.Handle, ARect) then
      Exit;

    // Without a fresh background snapshot we cannot compose; ask for a full paint
    // (which captures it) and let the next tick draw directly.
    if not Col.BgValid or (Col.Bg.Width <> W) or (Col.Bg.Height <> H) then
    begin
      Invalidate;
      Exit;
    end;

    if (FScrollBuf.Width <> W) or (FScrollBuf.Height <> H) then
      FScrollBuf.SetSize(W, H);

    LocalR := Rect(0, 0, W, H);
    BitBlt(FScrollBuf.Canvas.Handle, 0, 0, W, H, Col.Bg.Canvas.Handle, 0, 0, SRCCOPY);
    DrawColumn(FScrollBuf.Canvas, LocalR, AText, AFont, taLeftJustify, True, Col.Offset, False);
    if FEdgeFade then
      DrawEdgeFade(FScrollBuf.Canvas, LocalR, Col.Offset > 0, Col.Offset < Col.MaxOffset);

    Canvas.Lock;
    try
      BitBlt(Canvas.Handle, ARect.Left, ARect.Top, W, H, FScrollBuf.Canvas.Handle, 0, 0, SRCCOPY);
    finally
      Canvas.Unlock;
    end;
  finally
    TControlCanvas(Canvas).FreeHandle;
  end;
end;

procedure TCWSLabelColumn.Paint;
var
  LeftR, RightR: TRect;
begin
  if (Width <= 0) or (Height <= 0) then
    Exit;

  // As a TGraphicControl the parent has already painted the background under us
  // (that is what makes the transparent mode work); when opaque we fill it with
  // our own Color. A full Paint always reflects the current parent background,
  // so it also refreshes the cached strips used by the (Invalidate-free) marquee.
  if not FTransparent then
  begin
    Canvas.Brush.Color := Color;
    Canvas.Brush.Style := bsSolid;
    Canvas.FillRect(ClientRect);
  end;

  CalcColumns(LeftR, RightR);

  // Snapshot the clean background of any scrolling column before drawing text.
  if FLeft.Active then
    CaptureColBackground(FLeft, LeftR);
  if FRight.Active then
    CaptureColBackground(FRight, RightR);

  // Left column.
  if FLeft.Active then
  begin
    DrawColumn(Canvas, LeftR, FLeftText, FLeftFont, FLeftAlignment, True, FLeft.Offset, False);
    if FEdgeFade then
      DrawEdgeFade(Canvas, LeftR, FLeft.Offset > 0, FLeft.Offset < FLeft.MaxOffset);
  end
  else
    DrawColumn(Canvas, LeftR, FLeftText, FLeftFont, FLeftAlignment, False, 0, True);

  // Right column.
  if FRight.Active then
  begin
    DrawColumn(Canvas, RightR, FRightText, FRightFont, FRightAlignment, True, FRight.Offset, False);
    if FEdgeFade then
      DrawEdgeFade(Canvas, RightR, FRight.Offset > 0, FRight.Offset < FRight.MaxOffset);
  end
  else
    DrawColumn(Canvas, RightR, FRightText, FRightFont, FRightAlignment, False, 0, True);
end;

end.
