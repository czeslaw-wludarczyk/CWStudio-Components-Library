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
    procedure FadeEdgesToBackground(ABuf, ABg: TBitmap; AFadeLeft, AFadeRight: Boolean);
    procedure ComposeColumn(var Col: TCWSScrollCol; AW, AH: Integer;
      const AText: string; AFont: TFont);
    procedure PaintScrollingColumn(var Col: TCWSScrollCol; const ARect: TRect;
      const AText: string; AFont: TFont);

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
    // background instead of being hard-clipped. The fade target is the real
    // background under the column (the parent's pixels when Transparent, Color
    // otherwise), so it works on dark, gradient or card backgrounds alike.
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
  FLeft.Bg.Free;
  FRight.Bg.Free;
  FLeftFont.Free;
  FRightFont.Free;
  inherited Destroy;
end;

{ Soft fade on a scrolling column's edges: the composed frame ABuf (background +
  shifted text) is blended back into the clean background ABg, fully at the
  outer edge and not at all EdgeFadeWidth pixels inward — the same linear ramp
  the old flat-colour strips had. Blending into the real background instead of
  a constant Color is what makes the ends vanish into a dark, gradient or card
  background alike: with Transparent the snapshot IS the parent's pixels, so a
  fade towards Color (whatever it happened to be — often still the light
  default) drew pale smudges at both ends of the marquee on a dark form.
  The left edge only fades once text has scrolled off the left and the right
  edge only while there is still text to reveal, so a fully visible end never
  gets dimmed. Both bitmaps are pf32bit and the same size. }
procedure TCWSLabelColumn.FadeEdgesToBackground(ABuf, ABg: TBitmap;
  AFadeLeft, AFadeRight: Boolean);

  procedure Mix(Dst, Src: PByte; A: Integer); inline;
  var
    I: Integer;
  begin
    for I := 0 to 2 do
      PByte(Dst + I)^ := (PByte(Dst + I)^ * (255 - A) + PByte(Src + I)^ * A + 127) div 255;
  end;

var
  W, H, FadeW, X, Y, A: Integer;
  RowBuf, RowBg: PByte;
begin
  W := ABuf.Width;
  H := ABuf.Height;
  if (W <= 0) or (H <= 0) or not (AFadeLeft or AFadeRight) or
     (ABg.Width <> W) or (ABg.Height <> H) then
    Exit;
  FadeW := Min(FEdgeFadeWidth, W div 2);
  if FadeW <= 0 then
    Exit;
  { the text went in through GDI — make sure it is in the DIB before reading it }
  GdiFlush;
  for Y := 0 to H - 1 do
  begin
    RowBuf := ABuf.ScanLine[Y];
    RowBg := ABg.ScanLine[Y];
    for X := 0 to FadeW - 1 do
    begin
      { background weight: 255 at the outer edge, falling to 0 inward }
      A := 255 - MulDiv(X, 255, FadeW);
      if AFadeLeft then
        Mix(RowBuf + X * 4, RowBg + X * 4, A);
      if AFadeRight then
        Mix(RowBuf + (W - 1 - X) * 4, RowBg + (W - 1 - X) * 4, A);
    end;
  end;
end;

{ One column frame, composed off-screen in FScrollBuf: the clean background
  snapshot, the text shifted by the marquee offset, and the edge fade. Used by
  both Paint and the timer, so the first paint and every scroll step are the
  same picture. }
procedure TCWSLabelColumn.ComposeColumn(var Col: TCWSScrollCol; AW, AH: Integer;
  const AText: string; AFont: TFont);
begin
  if (FScrollBuf.Width <> AW) or (FScrollBuf.Height <> AH) then
    FScrollBuf.SetSize(AW, AH);
  BitBlt(FScrollBuf.Canvas.Handle, 0, 0, AW, AH, Col.Bg.Canvas.Handle, 0, 0, SRCCOPY);
  DrawColumn(FScrollBuf.Canvas, Rect(0, 0, AW, AH), AText, AFont, taLeftJustify,
    True, Col.Offset, False);
  if FEdgeFade then
    FadeEdgesToBackground(FScrollBuf, Col.Bg, Col.Offset > 0, Col.Offset < Col.MaxOffset);
end;

{ A scrolling column inside a full Paint. The background snapshot was taken just
  before (CaptureColBackground), so the frame can be composed and put on in one
  blit; without one the text is drawn plainly, unfaded. }
procedure TCWSLabelColumn.PaintScrollingColumn(var Col: TCWSScrollCol;
  const ARect: TRect; const AText: string; AFont: TFont);
var
  W, H: Integer;
begin
  W := ARect.Right - ARect.Left;
  H := ARect.Bottom - ARect.Top;
  if Col.BgValid and (Col.Bg.Width = W) and (Col.Bg.Height = H) then
  begin
    ComposeColumn(Col, W, H, AText, AFont);
    BitBlt(Canvas.Handle, ARect.Left, ARect.Top, W, H, FScrollBuf.Canvas.Handle, 0, 0, SRCCOPY);
  end
  else
    DrawColumn(Canvas, ARect, AText, AFont, taLeftJustify, True, Col.Offset, False);
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

    ComposeColumn(Col, W, H, AText, AFont);

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
    PaintScrollingColumn(FLeft, LeftR, FLeftText, FLeftFont)
  else
    DrawColumn(Canvas, LeftR, FLeftText, FLeftFont, FLeftAlignment, False, 0, True);

  // Right column.
  if FRight.Active then
    PaintScrollingColumn(FRight, RightR, FRightText, FRightFont)
  else
    DrawColumn(Canvas, RightR, FRightText, FRightFont, FRightAlignment, False, 0, True);
end;

end.
