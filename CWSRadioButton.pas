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
//////////////////////////////////////////////////////////////////////////s
unit CWSRadioButton;

{$SCOPEDENUMS OFF}

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.UITypes, System.Math,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Graphics, Vcl.ExtCtrls,
  CWSShape;

type
  TCWSRadioButton = class(TCustomControl)
  private
    FRing: TCWSShape;        { round indicator ring (border + fill)        }
    FDot: TCWSShape;         { inner bullet, visible only when Checked      }
    FLabelCaption: TLabel;   { caption text                                 }
    FMouseLayer: TLabel;     { transparent top-most layer for mouse events  }

    FCaption: string;
    FChecked: Boolean;
    FGroupIndex: Integer;

    FRadioSize: Integer;
    FTextSpacing: Integer;
    FTextPosition: TCWSTextPosition;

    FRadioColorNormal: TColor;     { unchecked ring border                  }
    FRadioColorChecked: TColor;    { checked ring fill + border (accent)    }
    FRadioColorDisabled: TColor;   { disabled ring                          }
    FFillColorNormal: TColor;      { unchecked ring interior                }
    FFillColorDisabled: TColor;    { ring interior when disabled            }
    FDotColor: TColor;             { inner bullet colour when checked       }

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
    procedure SetGroupIndex(const Value: Integer);
    procedure SetRadioSize(const Value: Integer);
    procedure SetTextSpacing(const Value: Integer);
    procedure SetTextPosition(const Value: TCWSTextPosition);
    procedure SetRadioColorNormal(const Value: TColor);
    procedure SetRadioColorChecked(const Value: TColor);
    procedure SetRadioColorDisabled(const Value: TColor);
    procedure SetFillColorNormal(const Value: TColor);
    procedure SetFillColorDisabled(const Value: TColor);
    procedure SetDotColor(const Value: TColor);
    procedure SetFontColorNormal(const Value: TColor);
    procedure SetFontColorChecked(const Value: TColor);
    procedure SetFontColorDisabled(const Value: TColor);

    function  SourceFont: TFont;
    procedure ApplyFontToLabel;
    procedure UpdateColors;
    procedure Recalc;
    procedure UncheckSiblings;
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
  published
    property Caption: string read FCaption write SetCaption;
    property Checked: Boolean read FChecked write SetChecked default False;
    property GroupIndex: Integer read FGroupIndex write SetGroupIndex default 0;

    property RadioSize: Integer read FRadioSize write SetRadioSize default 20;
    property TextSpacing: Integer read FTextSpacing write SetTextSpacing default 8;
    property TextPosition: TCWSTextPosition read FTextPosition write SetTextPosition default TCWSTextPosition.tpRight;

    property RadioColorNormal: TColor read FRadioColorNormal write SetRadioColorNormal stored True;
    property RadioColorChecked: TColor read FRadioColorChecked write SetRadioColorChecked stored True;
    property RadioColorDisabled: TColor read FRadioColorDisabled write SetRadioColorDisabled stored True;
    property FillColorNormal: TColor read FFillColorNormal write SetFillColorNormal stored True;
    property FillColorDisabled: TColor read FFillColorDisabled write SetFillColorDisabled stored True;
    property DotColor: TColor read FDotColor write SetDotColor stored True;

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

{ TCWSRadioButton }

constructor TCWSRadioButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ParentColor := True;
  DoubleBuffered := True;
  TabStop := True;
  AutoSize := True;

  FCaption     := 'RadioButton';
  FChecked     := False;
  FGroupIndex  := 0;
  FRadioSize   := 18;
  FTextSpacing := 6;
  FTextPosition := TCWSTextPosition.tpRight;
  FUpdatingSize := False;

  { Fluent / Windows 11 light palette }
  FRadioColorNormal   := $008A8A8A;   { gray ring (unchecked)             }
  FRadioColorChecked  := $00BD6C0F;   { accent (same as CWSButton primary) }
  FRadioColorDisabled := $00C7C7C7;
  FFillColorNormal    := $00FFFFFF;   { white interior                     }
  FFillColorDisabled  := $00F0F0F0;   { light gray interior when disabled  }
  FDotColor           := $00FFFFFF;   { white bullet on accent ring        }

  FFontColorNormal    := $00242424;
  FFontColorChecked   := $00242424;
  FFontColorDisabled  := $00BDBDBD;

  Width  := MulDiv(120, CurrentPPI, 96);
  Height := MulDiv(24,  CurrentPPI, 96);

  { 1. Ring }
  FRing := TCWSShape.Create(Self);
  FRing.Parent := Self;
  FRing.Shape := TShapeKind.RoundRectangle;

  { 2. Inner bullet }
  FDot := TCWSShape.Create(Self);
  FDot.Parent := Self;
  FDot.Shape := TShapeKind.RoundRectangle;
  FDot.Pen.Style := TShapePenStyle.Clear;
  FDot.Visible := False;
  { Respect Visible=False at design time — otherwise TWinControl.PaintControls
    paints graphic-control children regardless of Visible when csDesigning. }
  TControlFontAccess(FDot).ControlStyle :=
    TControlFontAccess(FDot).ControlStyle + [csNoDesignVisible];

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

  ApplyFontToLabel;
  UpdateColors;
end;

destructor TCWSRadioButton.Destroy;
begin
  inherited;
end;

function TCWSRadioButton.SourceFont: TFont;
begin
  { ParentFont = True → take the font directly from the parent (skip Self.Font),
    mirroring the TCWSButton behaviour. }
  if ParentFont and (Parent <> nil) then
    Result := TControlFontAccess(Parent).Font
  else
    Result := Self.Font;
end;

procedure TCWSRadioButton.ApplyFontToLabel;
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

procedure TCWSRadioButton.UpdateColors;
begin
  if (FRing = nil) or (FDot = nil) or (FLabelCaption = nil) or
     (csDestroying in ComponentState) then
    Exit;

  FDot.Visible := FChecked;

  if not Enabled then
  begin
    if FChecked then
    begin
      FRing.Brush.Color := FRadioColorDisabled;
      FRing.Pen.Color   := FRadioColorDisabled;
    end
    else
    begin
      FRing.Brush.Color := FFillColorDisabled;
      FRing.Pen.Color   := FRadioColorDisabled;
    end;
    FDot.Brush.Color := FFillColorDisabled;
    FLabelCaption.Font.Color := FFontColorDisabled;
  end
  else
  begin
    if FChecked then
    begin
      FRing.Brush.Color := FRadioColorChecked;
      FRing.Pen.Color   := FRadioColorChecked;
      FLabelCaption.Font.Color := FFontColorChecked;
    end
    else
    begin
      FRing.Brush.Color := FFillColorNormal;
      FRing.Pen.Color   := FRadioColorNormal;
      FLabelCaption.Font.Color := FFontColorNormal;
    end;
    FDot.Brush.Color := FDotColor;
  end;

  FRing.Invalidate;
  FDot.Invalidate;
end;

function TCWSRadioButton.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
var
  rs, sp, lw, lh: Integer;
  Bmp: Vcl.Graphics.TBitmap;
  Src: TFont;
begin
  Result := True;
  rs := MulDiv(FRadioSize, CurrentPPI, 96);
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
    NewWidth  := rs;
    NewHeight := rs;
    Exit;
  end;

  case FTextPosition of
    TCWSTextPosition.tpRight, TCWSTextPosition.tpLeft:
      begin
        NewWidth  := rs + sp + lw;
        NewHeight := Max(rs, lh);
      end;
    TCWSTextPosition.tpTop, TCWSTextPosition.tpBottom:
      begin
        NewWidth  := Max(rs, lw);
        NewHeight := rs + sp + lh;
      end;
  end;
end;

procedure TCWSRadioButton.Recalc;
var
  rs, ds, sp, dotOfs, ringLeft, ringTop, capLeft, capTop, lw, lh, cw, ch: Integer;
  HasText: Boolean;
begin
  if FUpdatingSize then
    Exit;
  if not (Assigned(FRing) and Assigned(FDot) and Assigned(FLabelCaption)) then
    Exit;

  ApplyFontToLabel;
  FLabelCaption.Caption := FCaption;

  rs := MulDiv(FRadioSize, CurrentPPI, 96);
  sp := MulDiv(FTextSpacing, CurrentPPI, 96);
  ds := Round(rs * 0.42);
  if ds < 1 then ds := 1;
  dotOfs := (rs - ds) div 2;

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

  { Position the ring and the caption according to TextPosition. }
  if not HasText then
  begin
    ringLeft := (cw - rs) div 2;
    ringTop  := (ch - rs) div 2;
    capLeft  := 0;
    capTop   := 0;
  end
  else
    case FTextPosition of
      TCWSTextPosition.tpRight:
        begin
          ringLeft := 0;
          ringTop  := (ch - rs) div 2;
          capLeft  := rs + sp;
          capTop   := (ch - lh) div 2;
        end;
      TCWSTextPosition.tpLeft:
        begin
          capLeft  := 0;
          capTop   := (ch - lh) div 2;
          ringLeft := lw + sp;
          ringTop  := (ch - rs) div 2;
        end;
      TCWSTextPosition.tpTop:
        begin
          capLeft  := (cw - lw) div 2;
          capTop   := 0;
          ringLeft := (cw - rs) div 2;
          ringTop  := lh + sp;
        end;
      TCWSTextPosition.tpBottom:
        begin
          ringLeft := (cw - rs) div 2;
          ringTop  := 0;
          capLeft  := (cw - lw) div 2;
          capTop   := rs + sp;
        end;
    else
      ringLeft := 0; ringTop := 0; capLeft := 0; capTop := 0;
    end;

  if ringLeft < 0 then ringLeft := 0;
  if ringTop  < 0 then ringTop  := 0;
  if capLeft  < 0 then capLeft  := 0;
  if capTop   < 0 then capTop   := 0;

  FUpdatingSize := True;
  try
    { Ring — a full circle: CornerRadius >= size/2 makes TCWSShape round it fully }
    FRing.SetBounds(ringLeft, ringTop, rs, rs);
    FRing.Pen.Width := Max(1, MulDiv(1, CurrentPPI, 96));
    FRing.CornerRadius := rs;

    { Inner bullet, centred inside the ring }
    FDot.SetBounds(ringLeft + dotOfs, ringTop + dotOfs, ds, ds);
    FDot.CornerRadius := ds;

    FLabelCaption.Left := capLeft;
    FLabelCaption.Top  := capTop;
  finally
    FUpdatingSize := False;
  end;
end;

procedure TCWSRadioButton.Resize;
begin
  inherited;
  Recalc;
end;

procedure TCWSRadioButton.Loaded;
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

procedure TCWSRadioButton.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited;
  ApplyFontToLabel;
  if AutoSize then
    AdjustSize;
  Recalc;
  UpdateColors;
end;

procedure TCWSRadioButton.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  UpdateColors;
end;

procedure TCWSRadioButton.CMFontChanged(var Message: TMessage);
begin
  inherited;
  ApplyFontToLabel;
  if AutoSize then
    AdjustSize;
  Recalc;
  UpdateColors;
end;

procedure TCWSRadioButton.CMParentFontChanged(var Message: TMessage);
begin
  inherited;
  ApplyFontToLabel;
  if AutoSize then
    AdjustSize;
  Recalc;
  UpdateColors;
end;

procedure TCWSRadioButton.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  { Receive arrow keys + Space for keyboard activation, like a VCL radio. }
  Message.Result := Message.Result or DLGC_WANTARROWS or DLGC_WANTCHARS;
end;

procedure TCWSRadioButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if (Key = VK_SPACE) and Enabled and not FChecked then
    Checked := True;
end;

procedure TCWSRadioButton.UncheckSiblings;
var
  I: Integer;
  Sibling: TCWSRadioButton;
begin
  if Parent = nil then
    Exit;
  for I := 0 to Parent.ControlCount - 1 do
    if Parent.Controls[I] is TCWSRadioButton then
    begin
      Sibling := TCWSRadioButton(Parent.Controls[I]);
      if (Sibling <> Self) and (Sibling.GroupIndex = FGroupIndex) and Sibling.Checked then
        Sibling.Checked := False;
    end;
end;

procedure TCWSRadioButton.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TCWSRadioButton.Click;
begin
  if Assigned(FOnClick) then
    FOnClick(Self);
end;

procedure TCWSRadioButton.MouseClick(Sender: TObject);
begin
  if not Enabled then
    Exit;
  if CanFocus then
    SetFocus;
  if not FChecked then
    Checked := True;
  Click;
end;

procedure TCWSRadioButton.ChildMouseEnter(Sender: TObject);
begin
  if Assigned(FOnMouseEnter) then FOnMouseEnter(Self);
end;

procedure TCWSRadioButton.ChildMouseLeave(Sender: TObject);
begin
  if Assigned(FOnMouseLeave) then FOnMouseLeave(Self);
end;

procedure TCWSRadioButton.ChildMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseDown) then FOnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TCWSRadioButton.ChildMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseUp) then FOnMouseUp(Self, Button, Shift, X, Y);
end;

procedure TCWSRadioButton.ChildMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if Assigned(FOnMouseMove) then FOnMouseMove(Self, Shift, X, Y);
end;

{ --- Setters --- }

procedure TCWSRadioButton.SetCaption(const Value: string);
begin
  if FCaption = Value then Exit;
  FCaption := Value;
  if Assigned(FLabelCaption) then
    FLabelCaption.Caption := FCaption;
  if AutoSize and not (csLoading in ComponentState) then
    AdjustSize;
  Recalc;
end;

procedure TCWSRadioButton.SetChecked(const Value: Boolean);
begin
  if FChecked = Value then Exit;
  FChecked := Value;
  if FChecked and not (csLoading in ComponentState) then
    UncheckSiblings;
  UpdateColors;
  if not (csLoading in ComponentState) then
    DoChange;
end;

procedure TCWSRadioButton.SetGroupIndex(const Value: Integer);
begin
  if FGroupIndex <> Value then
    FGroupIndex := Value;
end;

procedure TCWSRadioButton.SetRadioSize(const Value: Integer);
begin
  if (FRadioSize = Value) or (Value < 4) then Exit;
  FRadioSize := Value;
  if AutoSize and not (csLoading in ComponentState) then
    AdjustSize;
  Recalc;
end;

procedure TCWSRadioButton.SetTextSpacing(const Value: Integer);
begin
  if (FTextSpacing = Value) or (Value < 0) then Exit;
  FTextSpacing := Value;
  if AutoSize and not (csLoading in ComponentState) then
    AdjustSize;
  Recalc;
end;

procedure TCWSRadioButton.SetTextPosition(const Value: TCWSTextPosition);
begin
  if FTextPosition = Value then Exit;
  FTextPosition := Value;
  if AutoSize and not (csLoading in ComponentState) then
    AdjustSize;
  Recalc;
end;

procedure TCWSRadioButton.SetRadioColorNormal(const Value: TColor);
begin
  if FRadioColorNormal <> Value then
  begin
    FRadioColorNormal := Value;
    UpdateColors;
  end;
end;

procedure TCWSRadioButton.SetRadioColorChecked(const Value: TColor);
begin
  if FRadioColorChecked <> Value then
  begin
    FRadioColorChecked := Value;
    UpdateColors;
  end;
end;

procedure TCWSRadioButton.SetRadioColorDisabled(const Value: TColor);
begin
  if FRadioColorDisabled <> Value then
  begin
    FRadioColorDisabled := Value;
    UpdateColors;
  end;
end;

procedure TCWSRadioButton.SetFillColorNormal(const Value: TColor);
begin
  if FFillColorNormal <> Value then
  begin
    FFillColorNormal := Value;
    UpdateColors;
  end;
end;

procedure TCWSRadioButton.SetFillColorDisabled(const Value: TColor);
begin
  if FFillColorDisabled <> Value then
  begin
    FFillColorDisabled := Value;
    UpdateColors;
  end;
end;

procedure TCWSRadioButton.SetDotColor(const Value: TColor);
begin
  if FDotColor <> Value then
  begin
    FDotColor := Value;
    UpdateColors;
  end;
end;

procedure TCWSRadioButton.SetFontColorNormal(const Value: TColor);
begin
  if FFontColorNormal <> Value then
  begin
    FFontColorNormal := Value;
    UpdateColors;
  end;
end;

procedure TCWSRadioButton.SetFontColorChecked(const Value: TColor);
begin
  if FFontColorChecked <> Value then
  begin
    FFontColorChecked := Value;
    UpdateColors;
  end;
end;

procedure TCWSRadioButton.SetFontColorDisabled(const Value: TColor);
begin
  if FFontColorDisabled <> Value then
  begin
    FFontColorDisabled := Value;
    UpdateColors;
  end;
end;

end.
