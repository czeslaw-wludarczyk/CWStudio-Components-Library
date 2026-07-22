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
unit CWSCheckBox;

{$SCOPEDENUMS OFF}

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  System.SysUtils, System.Classes, System.UITypes, System.Math,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Graphics, Vcl.ExtCtrls,
  CWSShape;

type
  { Anti-aliased check-mark glyph, drawn with GDI+ inside its own bounds.
    Used internally by TCWSCheckBox; visible only when the box is checked.
    Progress (0..1) drives the Windows 11 style fade-in: opacity + scale. }
  TCWSCheckGlyph = class(TGraphicControl)
  private
    FColor: TColor;
    FProgress: Single;
    procedure SetColor(const Value: TColor);
    procedure SetProgress(const Value: Single);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    property Color: TColor read FColor write SetColor;
    property Progress: Single read FProgress write SetProgress;
  end;

  TCWSCheckBox = class(TCustomControl)
  private
    FBox: TCWSShape;          { rounded square indicator (border + fill)      }
    FCheck: TCWSCheckGlyph;   { check mark, visible only when Checked         }
    FLabelCaption: TLabel;    { caption text                                  }
    FMouseLayer: TLabel;      { transparent top-most layer for mouse events   }

    FCaption: string;
    FChecked: Boolean;

    FAnimated: Boolean;
    FAnimTimer: TTimer;
    FAnimPos: Single;         { 0 = unchecked look … 1 = checked look         }

    FBoxSize: Integer;
    FCornerRadius: Integer;
    FTextSpacing: Integer;
    FTextPosition: TCWSTextPosition;

    FBoxColorNormal: TColor;      { unchecked box border                     }
    FBoxColorChecked: TColor;     { checked box fill + border (accent)        }
    FBoxColorDisabled: TColor;    { disabled box                             }
    FFillColorNormal: TColor;     { unchecked box interior                    }
    FFillColorDisabled: TColor;   { box interior when disabled                }
    FCheckColor: TColor;          { check mark colour when checked            }

    FFontColorNormal: TColor;
    FFontColorChecked: TColor;
    FFontColorDisabled: TColor;

    FUpdatingSize: Boolean;

    FOnClick: TNotifyEvent;
    FOnChange: TNotifyEvent;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;
    FOnMouseDown: TMouseEvent;
    FOnMouseUp: TMouseEvent;
    FOnMouseMove: TMouseMoveEvent;

    procedure SetCaption(const Value: string);
    procedure SetChecked(const Value: Boolean);
    procedure SetAnimated(const Value: Boolean);
    procedure SetBoxSize(const Value: Integer);
    procedure SetCornerRadius(const Value: Integer);
    procedure SetTextSpacing(const Value: Integer);
    procedure SetTextPosition(const Value: TCWSTextPosition);
    procedure SetBoxColorNormal(const Value: TColor);
    procedure SetBoxColorChecked(const Value: TColor);
    procedure SetBoxColorDisabled(const Value: TColor);
    procedure SetFillColorNormal(const Value: TColor);
    procedure SetFillColorDisabled(const Value: TColor);
    procedure SetCheckColor(const Value: TColor);
    procedure SetFontColorNormal(const Value: TColor);
    procedure SetFontColorChecked(const Value: TColor);
    procedure SetFontColorDisabled(const Value: TColor);

    function  SourceFont: TFont;
    procedure ApplyFontToLabel;
    procedure UpdateColors;
    procedure ApplyAnimFrame(P: Single);
    procedure StartAnim;
    procedure StopAnim;
    procedure AnimTimerTick(Sender: TObject);
    procedure Recalc;
    procedure DoChange;

    procedure MouseClick(Sender: TObject);
    procedure ChildMouseEnter(Sender: TObject);
    procedure ChildMouseLeave(Sender: TObject);
    procedure ChildMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ChildMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ChildMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  protected
    function  CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure Resize; override;
    procedure Loaded; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMParentFontChanged(var Message: TMessage); message CM_PARENTFONTCHANGED;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Click; reintroduce;
    procedure Toggle;
  published
    property Caption: string read FCaption write SetCaption;
    property Checked: Boolean read FChecked write SetChecked default False;
    property Animated: Boolean read FAnimated write SetAnimated default True;

    property BoxSize: Integer read FBoxSize write SetBoxSize default 18;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 4;
    property TextSpacing: Integer read FTextSpacing write SetTextSpacing default 8;
    property TextPosition: TCWSTextPosition read FTextPosition write SetTextPosition default TCWSTextPosition.tpRight;

    property BoxColorNormal: TColor read FBoxColorNormal write SetBoxColorNormal stored True;
    property BoxColorChecked: TColor read FBoxColorChecked write SetBoxColorChecked stored True;
    property BoxColorDisabled: TColor read FBoxColorDisabled write SetBoxColorDisabled stored True;
    property FillColorNormal: TColor read FFillColorNormal write SetFillColorNormal stored True;
    property FillColorDisabled: TColor read FFillColorDisabled write SetFillColorDisabled stored True;
    property CheckColor: TColor read FCheckColor write SetCheckColor stored True;

    property FontColorNormal: TColor read FFontColorNormal write SetFontColorNormal stored True;
    property FontColorChecked: TColor read FFontColorChecked write SetFontColorChecked stored True;
    property FontColorDisabled: TColor read FFontColorDisabled write SetFontColorDisabled stored True;

    property AutoSize default True;
    property Align;
    property Anchors;
    property Constraints;
    property Color;
    property ParentColor default True;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property Hint;
    property Visible;
    property TabOrder;
    property TabStop default True;

    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
  end;

implementation

type
  TControlFontAccess = class(TControl);

{ TCWSCheckGlyph }

constructor TCWSCheckGlyph.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FColor := clWhite;
  FProgress := 1.0;
end;

procedure TCWSCheckGlyph.SetColor(const Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    Invalidate;
  end;
end;

procedure TCWSCheckGlyph.SetProgress(const Value: Single);
var
  V: Single;
begin
  V := Value;
  if V < 0 then V := 0;
  if V > 1 then V := 1;
  if FProgress <> V then
  begin
    FProgress := V;
    Invalidate;
  end;
end;

procedure TCWSCheckGlyph.Paint;
var
  G: TGPGraphics;
  Pen: TGPPen;
  C: TColor;
  S, PW, Sc, Cx, Cy, Alpha: Single;
  I: Integer;
  Pts: array[0..2] of TGPPointF;
begin
  if (Width <= 0) or (Height <= 0) or (FProgress <= 0) then
    Exit;

  S := Min(Width, Height);
  PW := S * 0.085;
  if PW < 1.2 then PW := 1.2;

  { Classic check mark, expressed as fractions of the indicator side so it
    scales with BoxSize / DPI. A single, centred polyline. }
  Pts[0] := MakePoint(Width * 0.28, Height * 0.51);
  Pts[1] := MakePoint(Width * 0.43, Height * 0.66);
  Pts[2] := MakePoint(Width * 0.72, Height * 0.34);

  { Windows 11 fade-in: the mark grows from ~70% to 100% while fading in. }
  Sc := 0.70 + 0.30 * FProgress;
  if Sc <> 1.0 then
  begin
    Cx := Width / 2;
    Cy := Height / 2;
    for I := 0 to High(Pts) do
    begin
      Pts[I].X := Cx + (Pts[I].X - Cx) * Sc;
      Pts[I].Y := Cy + (Pts[I].Y - Cy) * Sc;
    end;
  end;

  Alpha := 255 * FProgress;
  C := ColorToRGB(FColor);
  G := TGPGraphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeHighQuality);
    G.SetPixelOffsetMode(PixelOffsetModeHalf);
    Pen := TGPPen.Create(
      Winapi.GDIPAPI.MakeColor(Round(Alpha), GetRValue(C), GetGValue(C), GetBValue(C)), PW);
    try
      Pen.SetStartCap(LineCapRound);
      Pen.SetEndCap(LineCapRound);
      Pen.SetLineJoin(LineJoinRound);
      G.DrawLines(Pen, PGPPointF(@Pts[0]), Length(Pts));
    finally
      Pen.Free;
    end;
  finally
    G.Free;
  end;
end;

{ TCWSCheckBox }

constructor TCWSCheckBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ParentColor := True;
  DoubleBuffered := True;
  TabStop := True;
  AutoSize := True;

  FCaption      := 'CheckBox';
  FChecked      := False;
  FAnimated     := True;
  FAnimPos      := 0.0;
  FBoxSize      := 18;
  FCornerRadius := 4;
  FTextSpacing  := 8;
  FTextPosition := TCWSTextPosition.tpRight;
  FUpdatingSize := False;

  { Fluent / Windows 11 light palette }
  FBoxColorNormal   := $008A8A8A;   { gray border (unchecked)            }
  FBoxColorChecked  := $00BD6C0F;   { accent (same as CWSButton primary) }
  FBoxColorDisabled := $00C7C7C7;
  FFillColorNormal  := $00FFFFFF;   { white interior                     }
  FFillColorDisabled := $00F0F0F0;  { light gray interior when disabled  }
  FCheckColor       := $00FFFFFF;   { white check mark on accent box     }

  FFontColorNormal   := $00242424;
  FFontColorChecked  := $00242424;
  FFontColorDisabled := $00BDBDBD;

  Width  := MulDiv(120, CurrentPPI, 96);
  Height := MulDiv(24,  CurrentPPI, 96);

  { 1. Box }
  FBox := TCWSShape.Create(Self);
  FBox.Parent := Self;
  FBox.Shape := TShapeKind.RoundRectangle;

  { 2. Check mark }
  FCheck := TCWSCheckGlyph.Create(Self);
  FCheck.Parent := Self;
  FCheck.Visible := False;
  { Respect Visible=False at design time — otherwise TWinControl.PaintControls
    paints graphic-control children regardless of Visible when csDesigning. }
  TControlFontAccess(FCheck).ControlStyle :=
    TControlFontAccess(FCheck).ControlStyle + [csNoDesignVisible];

  { 3. Caption }
  FLabelCaption := TLabel.Create(Self);
  FLabelCaption.Parent := Self;
  FLabelCaption.Transparent := True;
  FLabelCaption.AutoSize := True;
  FLabelCaption.Caption := FCaption;

  { 4. Mouse layer (top-most, transparent) }
  FMouseLayer := TLabel.Create(Self);
  FMouseLayer.Parent := Self;
  FMouseLayer.Align := alClient;
  FMouseLayer.Caption := '';
  FMouseLayer.Transparent := True;
  FMouseLayer.OnClick := MouseClick;
  FMouseLayer.OnMouseEnter := ChildMouseEnter;
  FMouseLayer.OnMouseLeave := ChildMouseLeave;
  FMouseLayer.OnMouseDown := ChildMouseDown;
  FMouseLayer.OnMouseUp := ChildMouseUp;
  FMouseLayer.OnMouseMove := ChildMouseMove;

  { Animation driver for the Windows 11 style fade-in }
  FAnimTimer := TTimer.Create(Self);
  FAnimTimer.Enabled := False;
  FAnimTimer.Interval := 15;
  FAnimTimer.OnTimer := AnimTimerTick;

  ApplyFontToLabel;
  UpdateColors;
end;

destructor TCWSCheckBox.Destroy;
begin
  inherited;
end;

function TCWSCheckBox.SourceFont: TFont;
begin
  { ParentFont = True → take the font directly from the parent (skip Self.Font),
    mirroring the TCWSButton behaviour. }
  if ParentFont and (Parent <> nil) then
    Result := TControlFontAccess(Parent).Font
  else
    Result := Self.Font;
end;

procedure TCWSCheckBox.ApplyFontToLabel;
var
  Src: TFont;
begin
  if not Assigned(FLabelCaption) then
    Exit;
  Src := SourceFont;
  FLabelCaption.Font.Name    := Src.Name;
  FLabelCaption.Font.Size    := Src.Size;
  FLabelCaption.Font.Style   := Src.Style;
  FLabelCaption.Font.Charset := Src.Charset;
  FLabelCaption.Font.Quality := Src.Quality;
end;

procedure TCWSCheckBox.UpdateColors;
begin
  if (FBox = nil) or (FCheck = nil) or (FLabelCaption = nil) or
     (csDestroying in ComponentState) then
    Exit;

  FCheck.Visible := FChecked;

  if not Enabled then
  begin
    if FChecked then
    begin
      FBox.Brush.Color := FBoxColorDisabled;
      FBox.Pen.Color   := FBoxColorDisabled;
    end
    else
    begin
      FBox.Brush.Color := FFillColorDisabled;
      FBox.Pen.Color   := FBoxColorDisabled;
    end;
    FCheck.Color := FFillColorDisabled;
    FLabelCaption.Font.Color := FFontColorDisabled;
  end
  else
  begin
    if FChecked then
    begin
      FBox.Brush.Color := FBoxColorChecked;
      FBox.Pen.Color   := FBoxColorChecked;
      FLabelCaption.Font.Color := FFontColorChecked;
    end
    else
    begin
      FBox.Brush.Color := FFillColorNormal;
      FBox.Pen.Color   := FBoxColorNormal;
      FLabelCaption.Font.Color := FFontColorNormal;
    end;
    FCheck.Color := FCheckColor;
  end;

  { Discrete (non-animated) state — snap the fade progress to the end value. }
  if FChecked then
    FAnimPos := 1.0
  else
    FAnimPos := 0.0;
  FCheck.Progress := FAnimPos;

  FBox.Invalidate;
  FCheck.Invalidate;
end;

function LerpColor(C1, C2: TColor; T: Single): TColor;
var
  R1, G1, B1, R2, G2, B2: Integer;
begin
  if T <= 0 then Exit(C1);
  if T >= 1 then Exit(C2);
  C1 := ColorToRGB(C1);
  C2 := ColorToRGB(C2);
  R1 := GetRValue(C1); G1 := GetGValue(C1); B1 := GetBValue(C1);
  R2 := GetRValue(C2); G2 := GetGValue(C2); B2 := GetBValue(C2);
  Result := RGB(
    R1 + Round((R2 - R1) * T),
    G1 + Round((G2 - G1) * T),
    B1 + Round((B2 - B1) * T));
end;

procedure TCWSCheckBox.ApplyAnimFrame(P: Single);
begin
  if (FBox = nil) or (FCheck = nil) or (FLabelCaption = nil) or
     (csDestroying in ComponentState) then
    Exit;

  { Background fades white → accent, border gray → accent, in step with the
    check mark fading + scaling in — the Windows 11 "fill + check" reveal. }
  FBox.Brush.Color := LerpColor(FFillColorNormal, FBoxColorChecked, P);
  FBox.Pen.Color   := LerpColor(FBoxColorNormal,  FBoxColorChecked, P);
  FLabelCaption.Font.Color := LerpColor(FFontColorNormal, FFontColorChecked, P);

  FCheck.Color := FCheckColor;
  FCheck.Visible := P > 0;
  FCheck.Progress := P;

  FBox.Invalidate;
end;

procedure TCWSCheckBox.StartAnim;
begin
  if not Assigned(FAnimTimer) then
    Exit;
  FCheck.Visible := True;   { keep glyph shown for the whole transition }
  FAnimTimer.Enabled := True;
end;

procedure TCWSCheckBox.StopAnim;
begin
  if Assigned(FAnimTimer) then
    FAnimTimer.Enabled := False;
end;

procedure TCWSCheckBox.AnimTimerTick(Sender: TObject);
const
  { ~150 ms total at a 15 ms tick }
  Step = 0.10;
begin
  if FChecked then
    FAnimPos := FAnimPos + Step
  else
    FAnimPos := FAnimPos - Step;

  if FAnimPos >= 1.0 then
  begin
    FAnimPos := 1.0;
    StopAnim;
  end
  else if FAnimPos <= 0.0 then
  begin
    FAnimPos := 0.0;
    StopAnim;
  end;

  ApplyAnimFrame(FAnimPos);
end;

function TCWSCheckBox.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
var
  bs, sp, lw, lh: Integer;
  Bmp: Vcl.Graphics.TBitmap;
  Src: TFont;
begin
  Result := True;
  bs := MulDiv(FBoxSize, CurrentPPI, 96);
  sp := MulDiv(FTextSpacing, CurrentPPI, 96);

  Bmp := Vcl.Graphics.TBitmap.Create;
  try
    Src := SourceFont;
    Bmp.Canvas.Font.Name          := Src.Name;
    Bmp.Canvas.Font.Style         := Src.Style;
    Bmp.Canvas.Font.PixelsPerInch := CurrentPPI;
    Bmp.Canvas.Font.Size          := Src.Size;
    lh := Bmp.Canvas.TextHeight('Wg');
    if FCaption = '' then
      lw := 0
    else
      lw := Bmp.Canvas.TextWidth(FCaption);
  finally
    Bmp.Free;
  end;

  if lw = 0 then
  begin
    NewWidth  := bs;
    NewHeight := bs;
    Exit;
  end;

  case FTextPosition of
    TCWSTextPosition.tpRight, TCWSTextPosition.tpLeft:
      begin
        NewWidth  := bs + sp + lw;
        NewHeight := Max(bs, lh);
      end;
    TCWSTextPosition.tpTop, TCWSTextPosition.tpBottom:
      begin
        NewWidth  := Max(bs, lw);
        NewHeight := bs + sp + lh;
      end;
  end;
end;

procedure TCWSCheckBox.Recalc;
var
  bs, sp, boxLeft, boxTop, capLeft, capTop, lw, lh, cw, ch: Integer;
  HasText: Boolean;
begin
  if FUpdatingSize then
    Exit;
  if not (Assigned(FBox) and Assigned(FCheck) and Assigned(FLabelCaption)) then
    Exit;

  ApplyFontToLabel;
  FLabelCaption.Caption := FCaption;

  bs := MulDiv(FBoxSize, CurrentPPI, 96);
  sp := MulDiv(FTextSpacing, CurrentPPI, 96);

  HasText := FCaption <> '';
  lw := FLabelCaption.Width;
  lh := FLabelCaption.Height;
  cw := ClientWidth;
  ch := ClientHeight;
  if not HasText then
  begin
    lw := 0;
    sp := 0;
  end;

  { Position the box and the caption according to TextPosition. }
  if not HasText then
  begin
    boxLeft := (cw - bs) div 2;
    boxTop  := (ch - bs) div 2;
    capLeft := 0;
    capTop  := 0;
  end
  else
    case FTextPosition of
      TCWSTextPosition.tpRight:
        begin
          boxLeft := 0;
          boxTop  := (ch - bs) div 2;
          capLeft := bs + sp;
          capTop  := (ch - lh) div 2;
        end;
      TCWSTextPosition.tpLeft:
        begin
          capLeft := 0;
          capTop  := (ch - lh) div 2;
          boxLeft := lw + sp;
          boxTop  := (ch - bs) div 2;
        end;
      TCWSTextPosition.tpTop:
        begin
          capLeft := (cw - lw) div 2;
          capTop  := 0;
          boxLeft := (cw - bs) div 2;
          boxTop  := lh + sp;
        end;
      TCWSTextPosition.tpBottom:
        begin
          boxLeft := (cw - bs) div 2;
          boxTop  := 0;
          capLeft := (cw - lw) div 2;
          capTop  := bs + sp;
        end;
    else
      boxLeft := 0; boxTop := 0; capLeft := 0; capTop := 0;
    end;

  if boxLeft < 0 then boxLeft := 0;
  if boxTop  < 0 then boxTop  := 0;
  if capLeft < 0 then capLeft := 0;
  if capTop  < 0 then capTop  := 0;

  FUpdatingSize := True;
  try
    { Square indicator }
    FBox.SetBounds(boxLeft, boxTop, bs, bs);
    FBox.Pen.Width := Max(1, MulDiv(1, CurrentPPI, 96));
    FBox.CornerRadius := MulDiv(FCornerRadius, CurrentPPI, 96);

    { Check mark fills the same square; the glyph insets itself when drawing }
    FCheck.SetBounds(boxLeft, boxTop, bs, bs);

    FLabelCaption.Left := capLeft;
    FLabelCaption.Top  := capTop;
  finally
    FUpdatingSize := False;
  end;
end;

procedure TCWSCheckBox.Resize;
begin
  inherited;
  Recalc;
end;

procedure TCWSCheckBox.Loaded;
begin
  inherited;
  if HandleAllocated then
    FMouseLayer.BringToFront;
  ApplyFontToLabel;
  UpdateColors;
  if AutoSize then
    AdjustSize;
  Recalc;
end;

procedure TCWSCheckBox.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited;
  ApplyFontToLabel;
  if AutoSize then
    AdjustSize;
  Recalc;
  UpdateColors;
end;

procedure TCWSCheckBox.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  UpdateColors;
end;

procedure TCWSCheckBox.CMFontChanged(var Message: TMessage);
begin
  inherited;
  ApplyFontToLabel;
  if AutoSize then
    AdjustSize;
  Recalc;
  UpdateColors;
end;

procedure TCWSCheckBox.CMParentFontChanged(var Message: TMessage);
begin
  inherited;
  ApplyFontToLabel;
  if AutoSize then
    AdjustSize;
  Recalc;
  UpdateColors;
end;

procedure TCWSCheckBox.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  { Receive Space for keyboard activation, like a VCL check box. }
  Message.Result := Message.Result or DLGC_WANTCHARS;
end;

procedure TCWSCheckBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if (Key = VK_SPACE) and Enabled then
    Toggle;
end;

procedure TCWSCheckBox.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TCWSCheckBox.Click;
begin
  if Assigned(FOnClick) then
    FOnClick(Self);
end;

procedure TCWSCheckBox.Toggle;
begin
  Checked := not FChecked;
end;

procedure TCWSCheckBox.MouseClick(Sender: TObject);
begin
  if not Enabled then
    Exit;
  if CanFocus then
    SetFocus;
  Toggle;
  Click;
end;

procedure TCWSCheckBox.ChildMouseEnter(Sender: TObject);
begin
  if Assigned(FOnMouseEnter) then FOnMouseEnter(Self);
end;

procedure TCWSCheckBox.ChildMouseLeave(Sender: TObject);
begin
  if Assigned(FOnMouseLeave) then FOnMouseLeave(Self);
end;

procedure TCWSCheckBox.ChildMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseDown) then FOnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TCWSCheckBox.ChildMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseUp) then FOnMouseUp(Self, Button, Shift, X, Y);
end;

procedure TCWSCheckBox.ChildMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if Assigned(FOnMouseMove) then FOnMouseMove(Self, Shift, X, Y);
end;

{ --- Setters --- }

procedure TCWSCheckBox.SetCaption(const Value: string);
begin
  if FCaption = Value then Exit;
  FCaption := Value;
  if Assigned(FLabelCaption) then
    FLabelCaption.Caption := FCaption;
  if AutoSize and not (csLoading in ComponentState) then
    AdjustSize;
  Recalc;
end;

procedure TCWSCheckBox.SetChecked(const Value: Boolean);
var
  CanAnimate: Boolean;
begin
  if FChecked = Value then Exit;
  FChecked := Value;

  CanAnimate := FAnimated and Enabled and HandleAllocated and
    not (csLoading in ComponentState) and
    not (csDesigning in ComponentState) and
    not (csDestroying in ComponentState);

  if CanAnimate then
  begin
    { Keep the discrete colours (Color/Visible) consistent first, then run the
      fade from the current FAnimPos toward the new state. }
    FCheck.Color := FCheckColor;
    StartAnim;
  end
  else
  begin
    StopAnim;
    UpdateColors;
  end;

  if not (csLoading in ComponentState) then
    DoChange;
end;

procedure TCWSCheckBox.SetAnimated(const Value: Boolean);
begin
  if FAnimated = Value then Exit;
  FAnimated := Value;
  if not FAnimated then
  begin
    StopAnim;
    UpdateColors;
  end;
end;

procedure TCWSCheckBox.SetBoxSize(const Value: Integer);
begin
  if (FBoxSize = Value) or (Value < 4) then Exit;
  FBoxSize := Value;
  if AutoSize and not (csLoading in ComponentState) then
    AdjustSize;
  Recalc;
end;

procedure TCWSCheckBox.SetCornerRadius(const Value: Integer);
begin
  if (FCornerRadius = Value) or (Value < 0) then Exit;
  FCornerRadius := Value;
  Recalc;
end;

procedure TCWSCheckBox.SetTextSpacing(const Value: Integer);
begin
  if (FTextSpacing = Value) or (Value < 0) then Exit;
  FTextSpacing := Value;
  if AutoSize and not (csLoading in ComponentState) then
    AdjustSize;
  Recalc;
end;

procedure TCWSCheckBox.SetTextPosition(const Value: TCWSTextPosition);
begin
  if FTextPosition = Value then Exit;
  FTextPosition := Value;
  if AutoSize and not (csLoading in ComponentState) then
    AdjustSize;
  Recalc;
end;

procedure TCWSCheckBox.SetBoxColorNormal(const Value: TColor);
begin
  if FBoxColorNormal <> Value then
  begin
    FBoxColorNormal := Value;
    UpdateColors;
  end;
end;

procedure TCWSCheckBox.SetBoxColorChecked(const Value: TColor);
begin
  if FBoxColorChecked <> Value then
  begin
    FBoxColorChecked := Value;
    UpdateColors;
  end;
end;

procedure TCWSCheckBox.SetBoxColorDisabled(const Value: TColor);
begin
  if FBoxColorDisabled <> Value then
  begin
    FBoxColorDisabled := Value;
    UpdateColors;
  end;
end;

procedure TCWSCheckBox.SetFillColorNormal(const Value: TColor);
begin
  if FFillColorNormal <> Value then
  begin
    FFillColorNormal := Value;
    UpdateColors;
  end;
end;

procedure TCWSCheckBox.SetFillColorDisabled(const Value: TColor);
begin
  if FFillColorDisabled <> Value then
  begin
    FFillColorDisabled := Value;
    UpdateColors;
  end;
end;

procedure TCWSCheckBox.SetCheckColor(const Value: TColor);
begin
  if FCheckColor <> Value then
  begin
    FCheckColor := Value;
    UpdateColors;
  end;
end;

procedure TCWSCheckBox.SetFontColorNormal(const Value: TColor);
begin
  if FFontColorNormal <> Value then
  begin
    FFontColorNormal := Value;
    UpdateColors;
  end;
end;

procedure TCWSCheckBox.SetFontColorChecked(const Value: TColor);
begin
  if FFontColorChecked <> Value then
  begin
    FFontColorChecked := Value;
    UpdateColors;
  end;
end;

procedure TCWSCheckBox.SetFontColorDisabled(const Value: TColor);
begin
  if FFontColorDisabled <> Value then
  begin
    FFontColorDisabled := Value;
    UpdateColors;
  end;
end;

end.
