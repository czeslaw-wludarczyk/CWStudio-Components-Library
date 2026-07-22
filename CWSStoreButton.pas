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
unit CWSStoreButton;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Graphics,
  Vcl.ExtCtrls, Vcl.ImgList, CWSShape, Windows, Messages;

type
  TCWSIconMode = (icmGlyph, icmImageList);

  TCWSStoreButton = class(TCustomControl)
  private
    FIconBox: TPaintBox;
    Fdescription: TLabel;
    FbckShape: TCWSShape;
    FCursor: TCWSShape;
    FMouseLayer: TLabel;

    FNormalColor: TColor;
    FbckHoverColor: TColor;
    FbckPressedColor: TColor;
    FCursorColor: TColor;
    FCursorHeight: Integer;

    FIconGlyphNormal: string;
    FIconGlyphPressed: string;
    FdescriptionText: string;

    FHovering: Boolean;
    FPressed: Boolean;
    FGroupIndex: Integer;

    FIconColorNormal: TColor;
    FIconColorHover: TColor;
    FIconColorPressed: TColor;
    FIconFontName: string;
    FIconFontSize: Integer;

    FDescriptionColorNormal: TColor;
    FDescriptionColorHover: TColor;
    FDescriptionColorPressed: TColor;

    FOnClick: TNotifyEvent;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;
    FOnMouseDown: TMouseEvent;
    FOnMouseUp: TMouseEvent;

    FAnimTimer: TTimer;
    FAnimCurrentH: Integer;
    FAnimTargetH: Integer;
    FAnimShowing: Boolean;
    FAnimFromTop: Boolean;

    FIconMode: TCWSIconMode;
    FImages: TCustomImageList;
    FImageIndex: Integer;
    FImageIndexPressed: Integer;

    FIconOffsetX: Integer;
    FIconOffsetY: Integer;

    procedure SetIconGlyph(const Value: string);
    procedure SetIconGlyphPressed(const Value: string);
    procedure SetIconFontName(const Value: string);
    procedure SetIconFontSize(const Value: Integer);
    procedure SetDescriptionText(const Value: string);
    procedure SetBckColor(const Value: TColor);
    procedure SetBckPressedColor(const Value: TColor);
    procedure SetPressed(const Value: Boolean);
    procedure SetGroupIndex(const Value: Integer);
    procedure SetCursorColor(const Value: TColor);
    procedure SetCursorHeight(const Value: Integer);
    procedure SetIconMode(const Value: TCWSIconMode);
    procedure SetImages(const Value: TCustomImageList);
    procedure SetImageIndex(const Value: Integer);
    procedure SetImageIndexPressed(const Value: Integer);
    procedure SetIconOffsetX(const Value: Integer);
    procedure SetIconOffsetY(const Value: Integer);
    procedure SetIconColorNormal(const Value: TColor);
    procedure SetIconColorHover(const Value: TColor);
    procedure SetIconColorPressed(const Value: TColor);
    procedure SetDescriptionColorHover(const Value: TColor);
    procedure SetDescriptionColorNormal(const Value: TColor);
    procedure SetDescriptionColorPressed(const Value: TColor);
    procedure SetNormalColor(const Value: TColor);

    procedure ChildMouseEnter(Sender: TObject);
    procedure ChildMouseLeave(Sender: TObject);
    procedure MouseClick(Sender: TObject);
    procedure ChildMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ChildMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure IconBoxPaint(Sender: TObject);
    procedure UpdateColor;
    procedure UpdateGroup;
    procedure ApplyFontToLabel;
    procedure DoAnimTimer(Sender: TObject);
    function  CurrentIconColor: TColor;
    function  CalcIconSize: Integer;
    function  ScaledCursorHeight: Integer;

  protected
    procedure Resize; override;
    procedure Loaded; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published
    property Width;
    property Height;
    property Anchors;
    property Align;
    property Constraints;
    property Color;
    property ShowHint;
    property Font;
    property ParentFont;

    property IconFontName: string read FIconFontName write SetIconFontName;
    property IconFontSize: Integer read FIconFontSize write SetIconFontSize default 16;

    property BckNormalColor: TColor read FNormalColor write SetNormalColor stored True;
    property BckHoverColor: TColor read FbckHoverColor write SetBckColor stored True;
    property BckPressedColor: TColor read FbckPressedColor write SetBckPressedColor stored True;
    property CursorColor: TColor read FCursorColor write SetCursorColor stored True;
    property CursorHeight: Integer read FCursorHeight write SetCursorHeight default 23;

    property IconGlyph: string read FIconGlyphNormal write SetIconGlyph stored True;
    property IconGlyphPressed: string read FIconGlyphPressed write SetIconGlyphPressed stored True;
    property DescriptionText: string read FdescriptionText write SetDescriptionText stored True;

    property Pressed: Boolean read FPressed write SetPressed;
    property GroupIndex: Integer read FGroupIndex write SetGroupIndex default 0;

    property IconColorNormal: TColor read FIconColorNormal write SetIconColorNormal stored True;
    property IconColorHover: TColor read FIconColorHover write SetIconColorHover stored True;
    property IconColorPressed: TColor read FIconColorPressed write SetIconColorPressed stored True;

    property DescriptionColorNormal: TColor read FDescriptionColorNormal write SetDescriptionColorNormal stored True;
    property DescriptionColorHover: TColor read FDescriptionColorHover write SetDescriptionColorHover stored True;
    property DescriptionColorPressed: TColor read FDescriptionColorPressed write SetDescriptionColorPressed stored True;

    property IconMode: TCWSIconMode read FIconMode write SetIconMode default icmGlyph;
    property Images: TCustomImageList read FImages write SetImages;
    property ImageIndex: Integer read FImageIndex write SetImageIndex default -1;
    property ImageIndexPressed: Integer read FImageIndexPressed write SetImageIndexPressed default -1;

    property IconOffsetX: Integer read FIconOffsetX write SetIconOffsetX default 0;
    property IconOffsetY: Integer read FIconOffsetY write SetIconOffsetY default 0;

    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
  end;

implementation

uses
  System.TypInfo;

{ TCWSStoreButton }

constructor TCWSStoreButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ParentColor := False;
  DoubleBuffered := True;

  FIconGlyphNormal  := '';
  FIconGlyphPressed := '';
  FdescriptionText  := 'Home';

  FPressed    := False;
  FHovering   := False;
  FGroupIndex := 0;

  FNormalColor             := clBtnFace;
  FIconColorNormal         := clGray;
  FIconColorHover          := clBlack;
  FIconColorPressed        := clGray;
  FDescriptionColorNormal  := clGray;
  FDescriptionColorHover   := clBlack;
  FDescriptionColorPressed := clGray;
  FCursorColor             := clGray;
  FCursorHeight            := 23;

  FIconMode          := icmGlyph;
  FImages            := nil;
  FImageIndex        := -1;
  FImageIndexPressed := -1;

  FIconOffsetX  := 0;
  FIconOffsetY  := 0;
  FIconFontName := 'Segoe MDL2 Assets';
  FIconFontSize := 16;

  Self.Font.Name  := 'Segoe UI';
  Self.Font.Size  := 7;
  Self.Font.Color := FDescriptionColorNormal;

  FAnimTimer          := TTimer.Create(Self);
  FAnimTimer.Interval := 16;
  FAnimTimer.Enabled  := False;
  FAnimTimer.OnTimer  := DoAnimTimer;
  FAnimCurrentH       := 0;
  FAnimShowing        := False;

  Width  := MulDiv(63, CurrentPPI, 96);
  Height := MulDiv(57, CurrentPPI, 96);

  FbckShape              := TCWSShape.Create(Self);
  FbckShape.Parent       := Self;
  FbckShape.Shape        := TShapeKind.RoundRectangle;
  FbckShape.CornerRadius := MulDiv(4, CurrentPPI, 96);
  FbckShape.Align        := alClient;

  FCursor              := TCWSShape.Create(Self);
  FCursor.Parent       := Self;
  FCursor.SetSubComponent(True);
  FCursor.Shape        := TShapeKind.RoundRectangle;
  FCursor.CornerRadius := MulDiv(2, CurrentPPI, 96);
  FCursor.Visible      := False;
  FCursor.Align        := alNone;

  FIconBox         := TPaintBox.Create(Self);
  FIconBox.Parent  := Self;
  FIconBox.OnPaint := IconBoxPaint;

  Fdescription             := TLabel.Create(Self);
  Fdescription.Parent      := Self;
  Fdescription.Transparent := True;
  Fdescription.Caption     := FdescriptionText;
  Fdescription.Font.Assign(Self.Font);
  Fdescription.Alignment   := taCenter;
  Fdescription.Layout      := tlCenter;
  Fdescription.AutoSize    := False;

  FMouseLayer              := TLabel.Create(Self);
  FMouseLayer.Parent       := Self;
  FMouseLayer.Align        := alClient;
  FMouseLayer.Caption      := '';
  FMouseLayer.Transparent  := True;
  FMouseLayer.OnMouseEnter := ChildMouseEnter;
  FMouseLayer.OnMouseLeave := ChildMouseLeave;
  FMouseLayer.OnClick      := MouseClick;
  FMouseLayer.OnMouseDown  := ChildMouseDown;
  FMouseLayer.OnMouseUp    := ChildMouseUp;

  BckHoverColor   := clSilver;
  BckPressedColor := clWhite;
  Self.Color      := clBtnFace;

  UpdateColor;
end;

destructor TCWSStoreButton.Destroy;
begin
  inherited;
end;

function TCWSStoreButton.ScaledCursorHeight: Integer;
begin
  Result := MulDiv(FCursorHeight, CurrentPPI, 96);
end;

procedure TCWSStoreButton.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FImages) then
  begin
    FImages := nil;
    if Assigned(FIconBox) then FIconBox.Invalidate;
    Invalidate;
  end;
end;

procedure TCWSStoreButton.ApplyFontToLabel;
begin
  if not Assigned(Fdescription) then Exit;
  Fdescription.Font.Assign(Self.Font);
  if FPressed then
    Fdescription.Font.Color := FDescriptionColorPressed
  else if FHovering then
    Fdescription.Font.Color := FDescriptionColorHover
  else
    Fdescription.Font.Color := FDescriptionColorNormal;
end;

procedure TCWSStoreButton.CMFontChanged(var Message: TMessage);
begin
  inherited;
  ApplyFontToLabel;
  Resize;
  Invalidate;
end;

procedure TCWSStoreButton.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited;
  if Assigned(FbckShape) then
    FbckShape.CornerRadius := MulDiv(4, CurrentPPI, 96);
  if Assigned(FCursor) then
    FCursor.CornerRadius := MulDiv(2, CurrentPPI, 96);
  if FPressed then
    FAnimCurrentH := ScaledCursorHeight
  else
    FAnimCurrentH := 0;
  ApplyFontToLabel;
  Resize;
  Invalidate;
end;

function TCWSStoreButton.CurrentIconColor: TColor;
begin
  if FPressed then Result := FIconColorPressed
  else if FHovering then Result := FIconColorHover
  else Result := FIconColorNormal;
end;

function TCWSStoreButton.CalcIconSize: Integer;
var
  Bmp: Vcl.Graphics.TBitmap;
  glyph: string;
  W, H: Integer;
begin
  case FIconMode of
    icmImageList:
    begin
      if Assigned(FImages) and (FImages.Width > 0) then
        Result := FImages.Width
      else
        Result := MulDiv(24, CurrentPPI, 96);
    end;
    icmGlyph:
    begin
      glyph := FIconGlyphNormal;
      if (glyph = '') and (FIconGlyphPressed <> '') then
        glyph := FIconGlyphPressed;
      if glyph = '' then
      begin
        Result := MulDiv(24, CurrentPPI, 96);
        Exit;
      end;

      Bmp := Vcl.Graphics.TBitmap.Create;
      try
        Bmp.Canvas.Font.Name := FIconFontName;
        Bmp.Canvas.Font.PixelsPerInch := CurrentPPI;
        Bmp.Canvas.Font.Size := FIconFontSize;
        W := Bmp.Canvas.TextWidth(glyph);
        H := Bmp.Canvas.TextHeight(glyph);
        if W > H then Result := W else Result := H;
      finally
        Bmp.Free;
      end;
    end;
  else
    Result := MulDiv(24, CurrentPPI, 96);
  end;
end;

procedure TCWSStoreButton.IconBoxPaint(Sender: TObject);
var
  idx: Integer;
  savedColor: TColor;
  R: TRect;
  glyph: string;
begin
  FIconBox.Canvas.Brush.Color := FbckShape.Brush.Color;
  FIconBox.Canvas.FillRect(FIconBox.ClientRect);

  case FIconMode of
    icmGlyph:
    begin
      if FPressed then glyph := FIconGlyphPressed
      else glyph := FIconGlyphNormal;

      if glyph = '' then Exit;

      FIconBox.Canvas.Font.Name          := FIconFontName;
      FIconBox.Canvas.Font.PixelsPerInch := CurrentPPI;
      FIconBox.Canvas.Font.Size          := FIconFontSize;
      FIconBox.Canvas.Font.Color         := CurrentIconColor;
      FIconBox.Canvas.Brush.Style        := bsClear;

      R := FIconBox.ClientRect;
      DrawText(FIconBox.Canvas.Handle,
               PChar(glyph),
               -1,
               R,
               DT_CENTER or DT_VCENTER or DT_SINGLELINE);
    end;

    icmImageList:
    begin
      if FImages = nil then Exit;

      if FPressed and (FImageIndexPressed >= 0) then
        idx := FImageIndexPressed
      else
        idx := FImageIndex;

      if (idx < 0) or (idx >= FImages.Count) then Exit;

      { Tint monochrome SVG icons to the current state colour without a
        compile-time dependency on SVGIconImageList: if the assigned image list
        publishes a FixedColor property (TSVGIconImageList does), drive it via
        RTTI. Any other image list just draws as-is. }
      if IsPublishedProp(FImages, 'FixedColor') then
      begin
        savedColor := GetOrdProp(FImages, 'FixedColor');
        SetOrdProp(FImages, 'FixedColor', CurrentIconColor);
        FImages.Draw(FIconBox.Canvas, 0, 0, idx);
        SetOrdProp(FImages, 'FixedColor', savedColor);
      end
      else
        FImages.Draw(FIconBox.Canvas, 0, 0, idx);
    end;
  end;
end;

procedure TCWSStoreButton.UpdateColor;
begin
  if (FbckShape = nil) or (FIconBox = nil) or (Fdescription = nil) or
     (FCursor = nil) or (csDestroying in ComponentState) then
    Exit;
  if csLoading in ComponentState then
    Exit;

  if FPressed then FbckShape.Brush.Color := FbckPressedColor
  else if FHovering then FbckShape.Brush.Color := FbckHoverColor
  else FbckShape.Brush.Color := FNormalColor;
  FbckShape.Pen.Color := FbckShape.Brush.Color;

  if not FAnimTimer.Enabled then
    FCursor.Visible := FPressed;
  if FPressed then
  begin
    FCursor.Brush.Color := FCursorColor;
    FCursor.Pen.Color   := FCursorColor;
    FCursor.Pen.Style   := TShapePenStyle.Solid;
  end
  else
  begin
    FCursor.Pen.Style   := TShapePenStyle.Clear;
    FCursor.Brush.Color := clNone;
  end;

  if FPressed then Fdescription.Font.Color := FDescriptionColorPressed
  else if FHovering then Fdescription.Font.Color := FDescriptionColorHover
  else Fdescription.Font.Color := FDescriptionColorNormal;

  if Fdescription.Visible <> (not FPressed) then
    Fdescription.Visible := not FPressed;

  FIconBox.Invalidate;
  Invalidate;
end;

procedure TCWSStoreButton.Resize;
var
  descHeight, vCursorWidth, vCursorHeight: Integer;
  iconSize: Integer;
  scaledOffsetX, scaledOffsetY: Integer;
begin
  inherited;
  if not Assigned(FIconBox) or not Assigned(Fdescription) or
     not Assigned(FCursor) then
    Exit;

  ApplyFontToLabel;

  scaledOffsetX := MulDiv(FIconOffsetX, CurrentPPI, 96);
  scaledOffsetY := MulDiv(FIconOffsetY, CurrentPPI, 96);

  vCursorWidth  := MulDiv(4, CurrentPPI, 96);
  vCursorHeight := ScaledCursorHeight;

  FCursor.Width := vCursorWidth;
  FCursor.Left  := 0;
  if (FAnimTimer = nil) or not FAnimTimer.Enabled then
  begin
    FCursor.Height := vCursorHeight;
    FCursor.Top    := (Height - vCursorHeight) div 2;
    if FPressed then FAnimCurrentH := vCursorHeight
    else FAnimCurrentH := 0;
  end;

  descHeight := MulDiv(12, CurrentPPI, 96);
  Fdescription.Height := descHeight;

  iconSize := CalcIconSize;

  FIconBox.Width  := iconSize;
  FIconBox.Height := iconSize;
  FIconBox.Left   := (ClientWidth - iconSize) div 2 + scaledOffsetX;
  if FPressed then
    FIconBox.Top  := (Height - iconSize) div 2 + scaledOffsetY
  else
    FIconBox.Top  := (Height - descHeight - iconSize) div 2 + scaledOffsetY;

  if not FPressed then
  begin
    Fdescription.Width   := ClientWidth;
    Fdescription.Visible := True;
    Fdescription.SetBounds(0,
      ClientHeight - descHeight - MulDiv(4, CurrentPPI, 96),
      ClientWidth, descHeight);
  end
  else
  begin
    Fdescription.SetBounds(0, 0, 0, 0);
    Fdescription.Visible := False;
  end;

  FIconBox.Invalidate;
end;

procedure TCWSStoreButton.Loaded;
begin
  inherited;
  if FPressed then
    FAnimCurrentH := ScaledCursorHeight;
  if HandleAllocated then
  begin
    FbckShape.SendToBack;
    FMouseLayer.BringToFront;
  end;
  ApplyFontToLabel;
  UpdateColor;
  Resize;
end;

procedure TCWSStoreButton.SetIconMode(const Value: TCWSIconMode);
begin
  if FIconMode = Value then Exit;
  FIconMode := Value;
  Resize;
  UpdateColor;
  Repaint;
end;

procedure TCWSStoreButton.SetImages(const Value: TCustomImageList);
begin
  if FImages = Value then Exit;
  if FImages <> nil then FImages.RemoveFreeNotification(Self);
  FImages := Value;
  if FImages <> nil then FImages.FreeNotification(Self);
  Resize;
  if Assigned(FIconBox) then FIconBox.Invalidate;
  Repaint;
end;

procedure TCWSStoreButton.SetImageIndex(const Value: Integer);
begin
  if FImageIndex = Value then Exit;
  FImageIndex := Value;
  if (FIconMode = icmImageList) and Assigned(FIconBox) then
    FIconBox.Invalidate;
end;

procedure TCWSStoreButton.SetImageIndexPressed(const Value: Integer);
begin
  if FImageIndexPressed = Value then Exit;
  FImageIndexPressed := Value;
  if (FIconMode = icmImageList) and FPressed and Assigned(FIconBox) then
    FIconBox.Invalidate;
end;

procedure TCWSStoreButton.SetIconOffsetX(const Value: Integer);
begin
  if FIconOffsetX <> Value then begin FIconOffsetX := Value; Resize; Invalidate; end;
end;

procedure TCWSStoreButton.SetIconOffsetY(const Value: Integer);
begin
  if FIconOffsetY <> Value then begin FIconOffsetY := Value; Resize; Invalidate; end;
end;

procedure TCWSStoreButton.SetIconFontName(const Value: string);
begin
  if FIconFontName = Value then Exit;
  if Value = '' then FIconFontName := 'Segoe Fluent Icons'
  else FIconFontName := Value;
  Resize;
  Invalidate;
end;

procedure TCWSStoreButton.SetIconFontSize(const Value: Integer);
begin
  if FIconFontSize = Value then Exit;
  FIconFontSize := Value;
  Resize;
  Invalidate;
end;

procedure TCWSStoreButton.ChildMouseEnter(Sender: TObject);
begin
  FHovering := True;
  UpdateColor;
  if Assigned(FOnMouseEnter) then FOnMouseEnter(Self);
end;

procedure TCWSStoreButton.ChildMouseLeave(Sender: TObject);
begin
  FHovering := False;
  UpdateColor;
  if Assigned(FOnMouseLeave) then FOnMouseLeave(Self);
end;

procedure TCWSStoreButton.MouseClick(Sender: TObject);
begin
  if not FPressed then Pressed := True;
  if Assigned(FOnClick) then FOnClick(Self);
end;

procedure TCWSStoreButton.ChildMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseDown) then FOnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TCWSStoreButton.ChildMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseUp) then FOnMouseUp(Self, Button, Shift, X, Y);
end;

procedure TCWSStoreButton.SetPressed(const Value: Boolean);
var
  i: Integer;
  c: TComponent;
  FinalTop, FinalBottom, StartH: Integer;
  sCH: Integer;
begin
  if FPressed = Value then Exit;
  FPressed := Value;

  if not (csLoading in ComponentState) and not (csDesigning in ComponentState) then
  begin
    sCH := ScaledCursorHeight;
    FAnimTargetH := sCH;
    FAnimShowing := FPressed;

    if FPressed then
    begin
      FAnimFromTop := True;
      if (FGroupIndex <> 0) and (Owner <> nil) then
        for i := 0 to Owner.ComponentCount - 1 do
        begin
          c := Owner.Components[i];
          if (c is TCWSStoreButton) and (c <> Self) and
             (TCWSStoreButton(c).GroupIndex = FGroupIndex) and
             TCWSStoreButton(c).Pressed then
          begin
            FAnimFromTop := TCWSStoreButton(c).Top <= Self.Top;
            Break;
          end;
        end;

      FinalTop    := (Height - sCH) div 2;
      FinalBottom := FinalTop + sCH;
      if FAnimFromTop then StartH := FinalBottom
      else StartH := Height - FinalTop;

      FAnimCurrentH   := StartH;
      FCursor.Visible := True;
      FCursor.Height  := StartH;
      if FAnimFromTop then FCursor.Top := 0
      else FCursor.Top := FinalTop;
    end;

    FAnimTimer.Enabled := True;
  end;

  UpdateColor;
  Resize;

  if FPressed and (FGroupIndex <> 0) and not (csLoading in ComponentState) then
    UpdateGroup;
end;

procedure TCWSStoreButton.SetCursorHeight(const Value: Integer);
begin
  if FCursorHeight = Value then Exit;
  FCursorHeight := Value;
  Resize;
  Invalidate;
end;

procedure TCWSStoreButton.UpdateGroup;
var
  i: Integer;
  c: TComponent;
begin
  if (csLoading in ComponentState) or (csReading in ComponentState) then Exit;
  if Owner = nil then Exit;
  for i := 0 to Owner.ComponentCount - 1 do
  begin
    c := Owner.Components[i];
    if (c is TCWSStoreButton) and (c <> Self) then
      if TCWSStoreButton(c).GroupIndex = FGroupIndex then
      begin
        TCWSStoreButton(c).Pressed := False;
        TCWSStoreButton(c).UpdateColor;
      end;
  end;
end;

procedure TCWSStoreButton.DoAnimTimer(Sender: TObject);
var
  Step, FinalTop, FinalBottom: Integer;
begin
  if (FCursor = nil) or (csDestroying in ComponentState) then
  begin
    FAnimTimer.Enabled := False;
    Exit;
  end;

  FinalTop    := (Height - FAnimTargetH) div 2;
  FinalBottom := FinalTop + FAnimTargetH;

  if FAnimShowing then
  begin
    Step := (FAnimCurrentH - FAnimTargetH) div 3;
    if Step < 2 then Step := 2;
    Dec(FAnimCurrentH, Step);
    if FAnimCurrentH <= FAnimTargetH then
    begin
      FAnimCurrentH      := FAnimTargetH;
      FAnimTimer.Enabled := False;
    end;
  end
  else
  begin
    Step := FAnimCurrentH div 3;
    if Step < 2 then Step := 2;
    Dec(FAnimCurrentH, Step);
    if FAnimCurrentH <= 0 then
    begin
      FAnimCurrentH      := 0;
      FCursor.Visible    := False;
      FAnimTimer.Enabled := False;
    end;
  end;

  FCursor.Height := FAnimCurrentH;
  if FAnimShowing then
  begin
    if FAnimFromTop then FCursor.Top := FinalBottom - FAnimCurrentH
    else FCursor.Top := FinalTop;
  end
  else
    FCursor.Top := (Height - FAnimCurrentH) div 2;
end;

procedure TCWSStoreButton.SetBckColor(const Value: TColor);
begin FbckHoverColor := Value; UpdateColor; end;

procedure TCWSStoreButton.SetBckPressedColor(const Value: TColor);
begin FbckPressedColor := Value; UpdateColor; end;

procedure TCWSStoreButton.SetCursorColor(const Value: TColor);
begin
  if FCursorColor <> Value then begin FCursorColor := Value; UpdateColor; end;
end;

procedure TCWSStoreButton.SetGroupIndex(const Value: Integer);
begin FGroupIndex := Value; end;

procedure TCWSStoreButton.SetDescriptionColorHover(const Value: TColor);
begin FDescriptionColorHover := Value; UpdateColor; end;

procedure TCWSStoreButton.SetDescriptionColorNormal(const Value: TColor);
begin FDescriptionColorNormal := Value; UpdateColor; end;

procedure TCWSStoreButton.SetDescriptionColorPressed(const Value: TColor);
begin FDescriptionColorPressed := Value; UpdateColor; end;

procedure TCWSStoreButton.SetDescriptionText(const Value: string);
begin
  FdescriptionText := Value;
  if Assigned(Fdescription) then Fdescription.Caption := FdescriptionText;
end;

procedure TCWSStoreButton.SetIconColorHover(const Value: TColor);
begin FIconColorHover := Value; UpdateColor; end;

procedure TCWSStoreButton.SetIconColorNormal(const Value: TColor);
begin FIconColorNormal := Value; UpdateColor; end;

procedure TCWSStoreButton.SetIconColorPressed(const Value: TColor);
begin FIconColorPressed := Value; UpdateColor; end;

procedure TCWSStoreButton.SetIconGlyph(const Value: string);
begin
  FIconGlyphNormal := Value;
  Resize;
  Invalidate;
end;

procedure TCWSStoreButton.SetIconGlyphPressed(const Value: string);
begin
  FIconGlyphPressed := Value;
  Resize;
  Invalidate;
end;

procedure TCWSStoreButton.SetNormalColor(const Value: TColor);
begin
  if FNormalColor <> Value then begin FNormalColor := Value; UpdateColor; end;
end;

end.
