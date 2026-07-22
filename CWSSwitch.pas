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
unit CWSSwitch;

{$SCOPEDENUMS OFF}

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.UITypes, System.Math,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Graphics, Vcl.ExtCtrls,
  CWSShape;

type
  TCWSSwitch = class(TCustomControl)
  private
    FTrack: TCWSShape;        { pill-shaped track (border + fill)             }
    FKnob: TCWSShape;         { sliding / stretching knob                     }
    FLabelCaption: TLabel;    { caption text                                  }
    FMouseLayer: TLabel;      { transparent top-most layer for mouse events   }

    FCaption: string;
    FChecked: Boolean;

    FAnimated: Boolean;
    FAnimTimer: TTimer;
    FAnimPos: Single;         { 0 = Off (left) … 1 = On (right)               }

    FTrackWidth: Integer;
    FTrackHeight: Integer;
    FTextSpacing: Integer;
    FTextPosition: TCWSTextPosition;

    FTrackColorChecked: TColor;   { On track fill + border (accent)           }
    FTrackColorNormal: TColor;    { Off track fill                            }
    FBorderColorNormal: TColor;   { Off track border                          }
    FTrackColorDisabled: TColor;  { disabled track                            }
    FKnobColorChecked: TColor;    { knob colour when On (white)               }
    FKnobColorNormal: TColor;     { knob colour when Off (gray)               }
    FKnobColorDisabled: TColor;

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
    procedure SetTrackWidth(const Value: Integer);
    procedure SetTrackHeight(const Value: Integer);
    procedure SetTextSpacing(const Value: Integer);
    procedure SetTextPosition(const Value: TCWSTextPosition);
    procedure SetTrackColorChecked(const Value: TColor);
    procedure SetTrackColorNormal(const Value: TColor);
    procedure SetBorderColorNormal(const Value: TColor);
    procedure SetTrackColorDisabled(const Value: TColor);
    procedure SetKnobColorChecked(const Value: TColor);
    procedure SetKnobColorNormal(const Value: TColor);
    procedure SetKnobColorDisabled(const Value: TColor);
    procedure SetFontColorNormal(const Value: TColor);
    procedure SetFontColorChecked(const Value: TColor);
    procedure SetFontColorDisabled(const Value: TColor);

    function  SourceFont: TFont;
    procedure ApplyFontToLabel;
    procedure LayoutKnob(P: Single);
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

    property TrackWidth: Integer read FTrackWidth write SetTrackWidth default 40;
    property TrackHeight: Integer read FTrackHeight write SetTrackHeight default 20;
    property TextSpacing: Integer read FTextSpacing write SetTextSpacing default 8;
    property TextPosition: TCWSTextPosition read FTextPosition write SetTextPosition default TCWSTextPosition.tpRight;

    property TrackColorChecked: TColor read FTrackColorChecked write SetTrackColorChecked stored True;
    property TrackColorNormal: TColor read FTrackColorNormal write SetTrackColorNormal stored True;
    property BorderColorNormal: TColor read FBorderColorNormal write SetBorderColorNormal stored True;
    property TrackColorDisabled: TColor read FTrackColorDisabled write SetTrackColorDisabled stored True;
    property KnobColorChecked: TColor read FKnobColorChecked write SetKnobColorChecked stored True;
    property KnobColorNormal: TColor read FKnobColorNormal write SetKnobColorNormal stored True;
    property KnobColorDisabled: TColor read FKnobColorDisabled write SetKnobColorDisabled stored True;

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

{ TCWSSwitch }

constructor TCWSSwitch.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ParentColor := True;
  DoubleBuffered := True;
  TabStop := True;
  AutoSize := True;

  FCaption      := 'Switch';
  FChecked      := False;
  FAnimated     := True;
  FAnimPos      := 0.0;
  FTrackWidth   := 40;
  FTrackHeight  := 20;
  FTextSpacing  := 8;
  FTextPosition := TCWSTextPosition.tpRight;
  FUpdatingSize := False;

  { Fluent / Windows 11 light palette }
  FTrackColorChecked  := $00BD6C0F;   { accent (same as CWSButton primary)   }
  FTrackColorNormal   := $00FFFFFF;   { Off track interior                   }
  FBorderColorNormal  := $008A8A8A;   { Off track border                     }
  FTrackColorDisabled := $00E0E0E0;
  FKnobColorChecked   := $00FFFFFF;   { white knob when On                   }
  FKnobColorNormal    := $008A8A8A;   { gray knob when Off                   }
  FKnobColorDisabled  := $00C7C7C7;

  FFontColorNormal    := $00242424;
  FFontColorChecked   := $00242424;
  FFontColorDisabled  := $00BDBDBD;

  Width  := MulDiv(120, CurrentPPI, 96);
  Height := MulDiv(24,  CurrentPPI, 96);

  { 1. Track }
  FTrack := TCWSShape.Create(Self);
  FTrack.Parent := Self;
  FTrack.Shape := TShapeKind.RoundRectangle;

  { 2. Knob (drawn on top of the track) }
  FKnob := TCWSShape.Create(Self);
  FKnob.Parent := Self;
  FKnob.Shape := TShapeKind.RoundRectangle;
  FKnob.Pen.Style := TShapePenStyle.Clear;

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

  { Animation driver for the Windows 11 style knob slide + stretch }
  FAnimTimer := TTimer.Create(Self);
  FAnimTimer.Enabled := False;
  FAnimTimer.Interval := 15;
  FAnimTimer.OnTimer := AnimTimerTick;

  ApplyFontToLabel;
  UpdateColors;
end;

destructor TCWSSwitch.Destroy;
begin
  inherited;
end;

function TCWSSwitch.SourceFont: TFont;
begin
  { ParentFont = True → take the font directly from the parent (skip Self.Font),
    mirroring the TCWSButton behaviour. }
  if ParentFont and (Parent <> nil) then
    Result := TControlFontAccess(Parent).Font
  else
    Result := Self.Font;
end;

procedure TCWSSwitch.ApplyFontToLabel;
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

procedure TCWSSwitch.LayoutKnob(P: Single);
var
  tw, th, baseX, baseY, pad, knobD, amp, kw, kx, ky: Integer;
  cOff, cOn, centerX: Single;
begin
  if not (Assigned(FTrack) and Assigned(FKnob)) then
    Exit;
  { Reading a window handle here would fail before the control is parented;
    defer until one exists — Recalc re-runs this once parented. The knob is
    positioned relative to the track's actual bounds, so it follows whatever
    TextPosition layout Recalc chose. }
  if not HandleAllocated then
    Exit;

  baseX := FTrack.Left;
  baseY := FTrack.Top;
  tw := FTrack.Width;
  th := FTrack.Height;

  { Resting knob is a circle ~62% of the track height, centred vertically. }
  knobD := Round(th * 0.62);
  if knobD < 2 then knobD := 2;
  pad := (th - knobD) div 2;
  ky := baseY + pad;

  { Mid-travel the knob stretches into a pill (peaks at P = 0.5). }
  amp := Round(knobD * 0.55);

  cOff := pad + knobD / 2;
  cOn  := tw - pad - knobD / 2;
  centerX := cOff + (cOn - cOff) * P;

  kw := knobD + Round(amp * Sin(Pi * P));
  kx := Round(centerX - kw / 2);
  if kx < pad then kx := pad;
  if kx + kw > tw - pad then kx := tw - pad - kw;

  FUpdatingSize := True;
  try
    FKnob.SetBounds(baseX + kx, ky, kw, knobD);
    FKnob.CornerRadius := knobD;   { fully rounded → pill when stretched }
  finally
    FUpdatingSize := False;
  end;
end;

procedure TCWSSwitch.UpdateColors;
begin
  if (FTrack = nil) or (FKnob = nil) or (FLabelCaption = nil) or
     (csDestroying in ComponentState) then
    Exit;

  if not Enabled then
  begin
    FTrack.Brush.Color := FTrackColorDisabled;
    FTrack.Pen.Color   := FTrackColorDisabled;
    FKnob.Brush.Color  := FKnobColorDisabled;
    FLabelCaption.Font.Color := FFontColorDisabled;
  end
  else if FChecked then
  begin
    FTrack.Brush.Color := FTrackColorChecked;
    FTrack.Pen.Color   := FTrackColorChecked;
    FKnob.Brush.Color  := FKnobColorChecked;
    FLabelCaption.Font.Color := FFontColorChecked;
  end
  else
  begin
    FTrack.Brush.Color := FTrackColorNormal;
    FTrack.Pen.Color   := FBorderColorNormal;
    FKnob.Brush.Color  := FKnobColorNormal;
    FLabelCaption.Font.Color := FFontColorNormal;
  end;

  { Discrete (non-animated) state — snap the slide to the end position. }
  if FChecked then
    FAnimPos := 1.0
  else
    FAnimPos := 0.0;
  LayoutKnob(FAnimPos);

  FTrack.Invalidate;
  FKnob.Invalidate;
end;

procedure TCWSSwitch.ApplyAnimFrame(P: Single);
begin
  if (FTrack = nil) or (FKnob = nil) or (FLabelCaption = nil) or
     (csDestroying in ComponentState) then
    Exit;

  { Track fades Off → accent, border gray → accent, knob gray → white,
    in step with the knob sliding + stretching across. }
  FTrack.Brush.Color := LerpColor(FTrackColorNormal,  FTrackColorChecked, P);
  FTrack.Pen.Color   := LerpColor(FBorderColorNormal, FTrackColorChecked, P);
  FKnob.Brush.Color  := LerpColor(FKnobColorNormal,   FKnobColorChecked,  P);
  FLabelCaption.Font.Color := LerpColor(FFontColorNormal, FFontColorChecked, P);

  LayoutKnob(P);

  FTrack.Invalidate;
  FKnob.Invalidate;
end;

procedure TCWSSwitch.StartAnim;
begin
  if Assigned(FAnimTimer) then
    FAnimTimer.Enabled := True;
end;

procedure TCWSSwitch.StopAnim;
begin
  if Assigned(FAnimTimer) then
    FAnimTimer.Enabled := False;
end;

procedure TCWSSwitch.AnimTimerTick(Sender: TObject);
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

function TCWSSwitch.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
var
  tw, th, sp, lw, lh: Integer;
  Bmp: Vcl.Graphics.TBitmap;
  Src: TFont;
begin
  Result := True;
  tw := MulDiv(FTrackWidth, CurrentPPI, 96);
  th := MulDiv(FTrackHeight, CurrentPPI, 96);
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
    NewWidth  := tw;
    NewHeight := th;
    Exit;
  end;

  case FTextPosition of
    TCWSTextPosition.tpRight, TCWSTextPosition.tpLeft:
      begin
        NewWidth  := tw + sp + lw;
        NewHeight := Max(th, lh);
      end;
    TCWSTextPosition.tpTop, TCWSTextPosition.tpBottom:
      begin
        NewWidth  := Max(tw, lw);
        NewHeight := th + sp + lh;
      end;
  end;
end;

procedure TCWSSwitch.Recalc;
var
  tw, th, sp, trackLeft, trackTop, capLeft, capTop, lw, lh, cw, ch: Integer;
  HasText: Boolean;
begin
  if FUpdatingSize then
    Exit;
  if not (Assigned(FTrack) and Assigned(FKnob) and Assigned(FLabelCaption)) then
    Exit;
  { Avoid forcing a handle (via ClientHeight) before the control is parented. }
  if not HandleAllocated then
    Exit;

  ApplyFontToLabel;
  FLabelCaption.Caption := FCaption;

  tw := MulDiv(FTrackWidth, CurrentPPI, 96);
  th := MulDiv(FTrackHeight, CurrentPPI, 96);
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

  { Position the track and the caption according to TextPosition. }
  if not HasText then
  begin
    trackLeft := (cw - tw) div 2;
    trackTop  := (ch - th) div 2;
    capLeft   := 0;
    capTop    := 0;
  end
  else
    case FTextPosition of
      TCWSTextPosition.tpRight:
        begin
          trackLeft := 0;
          trackTop  := (ch - th) div 2;
          capLeft   := tw + sp;
          capTop    := (ch - lh) div 2;
        end;
      TCWSTextPosition.tpLeft:
        begin
          capLeft   := 0;
          capTop    := (ch - lh) div 2;
          trackLeft := lw + sp;
          trackTop  := (ch - th) div 2;
        end;
      TCWSTextPosition.tpTop:
        begin
          capLeft   := (cw - lw) div 2;
          capTop    := 0;
          trackLeft := (cw - tw) div 2;
          trackTop  := lh + sp;
        end;
      TCWSTextPosition.tpBottom:
        begin
          trackLeft := (cw - tw) div 2;
          trackTop  := 0;
          capLeft   := (cw - lw) div 2;
          capTop    := th + sp;
        end;
    else
      trackLeft := 0; trackTop := 0; capLeft := 0; capTop := 0;
    end;

  if trackLeft < 0 then trackLeft := 0;
  if trackTop  < 0 then trackTop  := 0;
  if capLeft   < 0 then capLeft   := 0;
  if capTop    < 0 then capTop    := 0;

  FUpdatingSize := True;
  try
    FTrack.SetBounds(trackLeft, trackTop, tw, th);
    FTrack.Pen.Width := Max(1, MulDiv(1, CurrentPPI, 96));
    FTrack.CornerRadius := th;   { fully rounded pill }

    FLabelCaption.Left := capLeft;
    FLabelCaption.Top  := capTop;
  finally
    FUpdatingSize := False;
  end;

  LayoutKnob(FAnimPos);
end;

procedure TCWSSwitch.Resize;
begin
  inherited;
  Recalc;
end;

procedure TCWSSwitch.Loaded;
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

procedure TCWSSwitch.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited;
  ApplyFontToLabel;
  if AutoSize then
    AdjustSize;
  Recalc;
  UpdateColors;
end;

procedure TCWSSwitch.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  StopAnim;
  UpdateColors;
end;

procedure TCWSSwitch.CMFontChanged(var Message: TMessage);
begin
  inherited;
  ApplyFontToLabel;
  if AutoSize then
    AdjustSize;
  Recalc;
  UpdateColors;
end;

procedure TCWSSwitch.CMParentFontChanged(var Message: TMessage);
begin
  inherited;
  ApplyFontToLabel;
  if AutoSize then
    AdjustSize;
  Recalc;
  UpdateColors;
end;

procedure TCWSSwitch.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  { Receive Space for keyboard activation, like a VCL toggle. }
  Message.Result := Message.Result or DLGC_WANTCHARS;
end;

procedure TCWSSwitch.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if (Key = VK_SPACE) and Enabled then
    Toggle;
end;

procedure TCWSSwitch.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TCWSSwitch.Click;
begin
  if Assigned(FOnClick) then
    FOnClick(Self);
end;

procedure TCWSSwitch.Toggle;
begin
  Checked := not FChecked;
end;

procedure TCWSSwitch.MouseClick(Sender: TObject);
begin
  if not Enabled then
    Exit;
  if CanFocus then
    SetFocus;
  Toggle;
  Click;
end;

procedure TCWSSwitch.ChildMouseEnter(Sender: TObject);
begin
  if Assigned(FOnMouseEnter) then FOnMouseEnter(Self);
end;

procedure TCWSSwitch.ChildMouseLeave(Sender: TObject);
begin
  if Assigned(FOnMouseLeave) then FOnMouseLeave(Self);
end;

procedure TCWSSwitch.ChildMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseDown) then FOnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TCWSSwitch.ChildMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseUp) then FOnMouseUp(Self, Button, Shift, X, Y);
end;

procedure TCWSSwitch.ChildMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if Assigned(FOnMouseMove) then FOnMouseMove(Self, Shift, X, Y);
end;

{ --- Setters --- }

procedure TCWSSwitch.SetCaption(const Value: string);
begin
  if FCaption = Value then Exit;
  FCaption := Value;
  if Assigned(FLabelCaption) then
    FLabelCaption.Caption := FCaption;
  if AutoSize and not (csLoading in ComponentState) then
    AdjustSize;
  Recalc;
end;

procedure TCWSSwitch.SetChecked(const Value: Boolean);
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
    StartAnim
  else
  begin
    StopAnim;
    UpdateColors;
  end;

  if not (csLoading in ComponentState) then
    DoChange;
end;

procedure TCWSSwitch.SetAnimated(const Value: Boolean);
begin
  if FAnimated = Value then Exit;
  FAnimated := Value;
  if not FAnimated then
  begin
    StopAnim;
    UpdateColors;
  end;
end;

procedure TCWSSwitch.SetTrackWidth(const Value: Integer);
begin
  if (FTrackWidth = Value) or (Value < 8) then Exit;
  FTrackWidth := Value;
  if AutoSize and not (csLoading in ComponentState) then
    AdjustSize;
  Recalc;
end;

procedure TCWSSwitch.SetTrackHeight(const Value: Integer);
begin
  if (FTrackHeight = Value) or (Value < 6) then Exit;
  FTrackHeight := Value;
  if AutoSize and not (csLoading in ComponentState) then
    AdjustSize;
  Recalc;
end;

procedure TCWSSwitch.SetTextSpacing(const Value: Integer);
begin
  if (FTextSpacing = Value) or (Value < 0) then Exit;
  FTextSpacing := Value;
  if AutoSize and not (csLoading in ComponentState) then
    AdjustSize;
  Recalc;
end;

procedure TCWSSwitch.SetTextPosition(const Value: TCWSTextPosition);
begin
  if FTextPosition = Value then Exit;
  FTextPosition := Value;
  if AutoSize and not (csLoading in ComponentState) then
    AdjustSize;
  Recalc;
end;

procedure TCWSSwitch.SetTrackColorChecked(const Value: TColor);
begin
  if FTrackColorChecked <> Value then
  begin
    FTrackColorChecked := Value;
    UpdateColors;
  end;
end;

procedure TCWSSwitch.SetTrackColorNormal(const Value: TColor);
begin
  if FTrackColorNormal <> Value then
  begin
    FTrackColorNormal := Value;
    UpdateColors;
  end;
end;

procedure TCWSSwitch.SetBorderColorNormal(const Value: TColor);
begin
  if FBorderColorNormal <> Value then
  begin
    FBorderColorNormal := Value;
    UpdateColors;
  end;
end;

procedure TCWSSwitch.SetTrackColorDisabled(const Value: TColor);
begin
  if FTrackColorDisabled <> Value then
  begin
    FTrackColorDisabled := Value;
    UpdateColors;
  end;
end;

procedure TCWSSwitch.SetKnobColorChecked(const Value: TColor);
begin
  if FKnobColorChecked <> Value then
  begin
    FKnobColorChecked := Value;
    UpdateColors;
  end;
end;

procedure TCWSSwitch.SetKnobColorNormal(const Value: TColor);
begin
  if FKnobColorNormal <> Value then
  begin
    FKnobColorNormal := Value;
    UpdateColors;
  end;
end;

procedure TCWSSwitch.SetKnobColorDisabled(const Value: TColor);
begin
  if FKnobColorDisabled <> Value then
  begin
    FKnobColorDisabled := Value;
    UpdateColors;
  end;
end;

procedure TCWSSwitch.SetFontColorNormal(const Value: TColor);
begin
  if FFontColorNormal <> Value then
  begin
    FFontColorNormal := Value;
    UpdateColors;
  end;
end;

procedure TCWSSwitch.SetFontColorChecked(const Value: TColor);
begin
  if FFontColorChecked <> Value then
  begin
    FFontColorChecked := Value;
    UpdateColors;
  end;
end;

procedure TCWSSwitch.SetFontColorDisabled(const Value: TColor);
begin
  if FFontColorDisabled <> Value then
  begin
    FFontColorDisabled := Value;
    UpdateColors;
  end;
end;

end.
