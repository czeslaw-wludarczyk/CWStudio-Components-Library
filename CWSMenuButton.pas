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
unit CWSMenuButton;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Graphics,
  Vcl.ExtCtrls, Vcl.ImgList, CWSShape, Windows, Messages, System.UITypes;

type
  TCWSIconMode = (icmGlyph, icmImageList);

  TCWSMenuButton = class(TCustomControl)
  private
    FIconBox: TPaintBox;
    Fmenu: TLabel;
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
    FmenuText: string;

    FHovering: Boolean;
    FPressed: Boolean;
    FGroupIndex: Integer;

    FIconColorNormal: TColor;
    FIconColorHover: TColor;
    FIconColorPressed: TColor;
    FIconFontName: string;
    FIconFontSize: Integer;

    FIconOffsetX: Integer;
    FIconOffsetY: Integer;

    FmenuColorTextNormal: TColor;
    FmenuColorTextHover: TColor;
    FmenuColorTextPressed: TColor;

    FOnClick: TNotifyEvent;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;

    FAnimTimer: TTimer;
    FAnimCurrentH: Integer;
    FAnimTargetH: Integer;
    FAnimShowing: Boolean;
    FAnimFromTop: Boolean;

    FIconMode: TCWSIconMode;
    FImages: TCustomImageList;
    FImageIndex: TImageIndex;
    FImageIndexPressed: TImageIndex;

    procedure SetIconGlyph(const Value: string);
    procedure SetIconGlyphPressed(const Value: string);
    procedure SetIconFontName(const Value: string);
    procedure SetIconFontSize(const Value: Integer);
    procedure SetIconOffsetX(const Value: Integer);
    procedure SetIconOffsetY(const Value: Integer);
    procedure SetIconMode(const Value: TCWSIconMode);
    procedure SetImages(const Value: TCustomImageList);
    procedure SetImageIndex(const Value: TImageIndex);
    procedure SetImageIndexPressed(const Value: TImageIndex);
    procedure SetMenuText(const Value: string);
    procedure SetBckColor(const Value: TColor);
    procedure SetBckPressedColor(const Value: TColor);
    procedure SetPressed(const Value: Boolean);
    procedure SetGroupIndex(const Value: Integer);
    procedure SetCursorColor(const Value: TColor);
    procedure SetCursorHeight(const Value: Integer);
    procedure SetIconColorNormal(const Value: TColor);
    procedure SetIconColorHover(const Value: TColor);
    procedure SetIconColorPressed(const Value: TColor);
    procedure SetMenuColorTextHover(const Value: TColor);
    procedure SetMenuColorTextNormal(const Value: TColor);
    procedure SetMenuColorTextPressed(const Value: TColor);
    procedure SetNormalColor(const Value: TColor);

    procedure ChildMouseEnter(Sender: TObject);
    procedure ChildMouseLeave(Sender: TObject);
    procedure MouseClick(Sender: TObject);
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
    property Visible;

    property IconFontName: string read FIconFontName write SetIconFontName;
    property IconFontSize: Integer read FIconFontSize write SetIconFontSize default 11;

    property IconOffsetX: Integer read FIconOffsetX write SetIconOffsetX default 0;
    property IconOffsetY: Integer read FIconOffsetY write SetIconOffsetY default 0;

    property BckNormalColor: TColor read FNormalColor write SetNormalColor stored True;
    property BckHoverColor: TColor read FbckHoverColor write SetBckColor stored True;
    property BckPressedColor: TColor read FbckPressedColor write SetBckPressedColor stored True;
    property CursorColor: TColor read FCursorColor write SetCursorColor stored True;
    property CursorHeight: Integer read FCursorHeight write SetCursorHeight default 16;

    property IconGlyph: string read FIconGlyphNormal write SetIconGlyph stored True;
    property IconGlyphPressed: string read FIconGlyphPressed write SetIconGlyphPressed stored True;
    property MenuText: string read FmenuText write SetMenuText stored True;

    property Pressed: Boolean read FPressed write SetPressed;
    property GroupIndex: Integer read FGroupIndex write SetGroupIndex default 0;

    property IconColorNormal: TColor read FIconColorNormal write SetIconColorNormal stored True;
    property IconColorHover: TColor read FIconColorHover write SetIconColorHover stored True;
    property IconColorPressed: TColor read FIconColorPressed write SetIconColorPressed stored True;

    property MenuColorTextNormal: TColor read FmenuColorTextNormal write SetMenuColorTextNormal stored True;
    property MenuColorTextHover: TColor read FmenuColorTextHover write SetMenuColorTextHover stored True;
    property MenuColorTextPressed: TColor read FmenuColorTextPressed write SetMenuColorTextPressed stored True;

    property IconMode: TCWSIconMode read FIconMode write SetIconMode default icmGlyph;
    property Images: TCustomImageList read FImages write SetImages;
    { TImageIndex, not Integer — the Object Inspector then offers the CWStudio
      icon picker: a drop-down with the glyphs of Images instead of bare numbers. }
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex default -1;
    property ImageIndexPressed: TImageIndex read FImageIndexPressed write SetImageIndexPressed default -1;

    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
  end;

implementation

uses
  System.TypInfo;

{ TCWSMenuButton }

constructor TCWSMenuButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ParentColor := False;
  DoubleBuffered := True;

  FIconGlyphNormal  := '';
  FIconGlyphPressed := '';
  FmenuText         := 'Home';

  FPressed    := False;
  FHovering   := False;
  FGroupIndex := 0;

  FIconOffsetX := 0;
  FIconOffsetY := 0;

  FNormalColor          := clBtnFace;
  FIconColorNormal      := clGray;
  FIconColorHover       := clBlack;
  FIconColorPressed     := clGray;
  FmenuColorTextNormal  := clGray;
  FmenuColorTextHover   := clBlack;
  FmenuColorTextPressed := clGray;
  FCursorColor          := clGray;
  FCursorHeight         := 16;

  FIconMode          := icmGlyph;
  FImages            := nil;
  FImageIndex        := -1;
  FImageIndexPressed := -1;

  FIconFontName := 'Segoe MDL2 Assets';
  FIconFontSize := 11;

  Self.Font.Name  := 'Segoe UI';
  Self.Font.Size  := 10;
  Self.Font.Color := FmenuColorTextNormal;

  FAnimTimer          := TTimer.Create(Self);
  FAnimTimer.Interval := 16;
  FAnimTimer.Enabled  := False;
  FAnimTimer.OnTimer  := DoAnimTimer;
  FAnimCurrentH       := 0;
  FAnimShowing        := False;

  Width  := MulDiv(300, CurrentPPI, 96);
  Height := MulDiv(35,  CurrentPPI, 96);

  FbckShape              := TCWSShape.Create(Self);
  FbckShape.Parent       := Self;
  FbckShape.Shape        := TShapeKind.RoundRectangle;
  FbckShape.CornerRadius := MulDiv(4, CurrentPPI, 96);
  FbckShape.Align        := alNone;  // manual positioning instead of alClient

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

  Fmenu             := TLabel.Create(Self);
  Fmenu.Parent      := Self;
  Fmenu.Transparent := True;
  Fmenu.Caption     := FmenuText;
  Fmenu.Font.Assign(Self.Font);
  Fmenu.Alignment   := taLeftJustify;
  Fmenu.Layout      := tlCenter;
  Fmenu.AutoSize    := False;

  FMouseLayer              := TLabel.Create(Self);
  FMouseLayer.Parent       := Self;
  FMouseLayer.Align        := alClient;
  FMouseLayer.Caption      := '';
  FMouseLayer.Transparent  := True;
  FMouseLayer.OnMouseEnter := ChildMouseEnter;
  FMouseLayer.OnMouseLeave := ChildMouseLeave;
  FMouseLayer.OnClick      := MouseClick;

  BckHoverColor   := clSilver;
  BckPressedColor := clWhite;
  Self.Color      := clBtnFace;

  UpdateColor;
end;

destructor TCWSMenuButton.Destroy;
begin
  inherited;
end;

function TCWSMenuButton.ScaledCursorHeight: Integer;
begin
  Result := MulDiv(FCursorHeight, CurrentPPI, 96);
end;

procedure TCWSMenuButton.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FImages) then
  begin
    FImages := nil;
    if Assigned(FIconBox) then FIconBox.Invalidate;
    Invalidate;
  end;
end;

procedure TCWSMenuButton.ApplyFontToLabel;
begin
  if not Assigned(Fmenu) then Exit;
  Fmenu.Font.Assign(Self.Font);
  if FPressed then
    Fmenu.Font.Color := FmenuColorTextPressed
  else if FHovering then
    Fmenu.Font.Color := FmenuColorTextHover
  else
    Fmenu.Font.Color := FmenuColorTextNormal;
end;

procedure TCWSMenuButton.CMFontChanged(var Message: TMessage);
begin
  inherited;
  ApplyFontToLabel;
  Resize;
  Invalidate;
end;

procedure TCWSMenuButton.ChangeScale(M, D: Integer; isDpiChange: Boolean);
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

function TCWSMenuButton.CurrentIconColor: TColor;
begin
  if FPressed then Result := FIconColorPressed
  else if FHovering then Result := FIconColorHover
  else Result := FIconColorNormal;
end;

function TCWSMenuButton.CalcIconSize: Integer;
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
        Result := MulDiv(20, CurrentPPI, 96);
    end;
    icmGlyph:
    begin
      glyph := FIconGlyphNormal;
      if (glyph = '') and (FIconGlyphPressed <> '') then
        glyph := FIconGlyphPressed;
      if glyph = '' then
      begin
        Result := MulDiv(20, CurrentPPI, 96);
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
    Result := MulDiv(20, CurrentPPI, 96);
  end;
end;

procedure TCWSMenuButton.IconBoxPaint(Sender: TObject);
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

procedure TCWSMenuButton.Loaded;
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

procedure TCWSMenuButton.SetIconMode(const Value: TCWSIconMode);
begin
  if FIconMode = Value then Exit;
  FIconMode := Value;
  Resize;
  UpdateColor;
  Repaint;
end;

procedure TCWSMenuButton.SetImages(const Value: TCustomImageList);
begin
  if FImages = Value then Exit;
  if FImages <> nil then FImages.RemoveFreeNotification(Self);
  FImages := Value;
  if FImages <> nil then FImages.FreeNotification(Self);
  Resize;
  if Assigned(FIconBox) then FIconBox.Invalidate;
  Repaint;
end;

procedure TCWSMenuButton.SetImageIndex(const Value: TImageIndex);
begin
  if FImageIndex = Value then Exit;
  FImageIndex := Value;
  if (FIconMode = icmImageList) and Assigned(FIconBox) then
    FIconBox.Invalidate;
end;

procedure TCWSMenuButton.SetImageIndexPressed(const Value: TImageIndex);
begin
  if FImageIndexPressed = Value then Exit;
  FImageIndexPressed := Value;
  if (FIconMode = icmImageList) and FPressed and Assigned(FIconBox) then
    FIconBox.Invalidate;
end;

procedure TCWSMenuButton.SetIconOffsetX(const Value: Integer);
begin
  if FIconOffsetX <> Value then begin FIconOffsetX := Value; Resize; Invalidate; end;
end;

procedure TCWSMenuButton.SetIconOffsetY(const Value: Integer);
begin
  if FIconOffsetY <> Value then begin FIconOffsetY := Value; Resize; Invalidate; end;
end;

procedure TCWSMenuButton.SetIconFontName(const Value: string);
begin
  if FIconFontName = Value then Exit;
  if Value = '' then FIconFontName := 'Segoe Fluent Icons'
  else FIconFontName := Value;
  Resize;
  Invalidate;
end;

procedure TCWSMenuButton.SetIconFontSize(const Value: Integer);
begin
  if FIconFontSize = Value then Exit;
  FIconFontSize := Value;
  Resize;
  Invalidate;
end;

procedure TCWSMenuButton.ChildMouseEnter(Sender: TObject);
begin
  FHovering := True;
  UpdateColor;
  if Assigned(FOnMouseEnter) then FOnMouseEnter(Self);
end;

procedure TCWSMenuButton.ChildMouseLeave(Sender: TObject);
begin
  FHovering := False;
  UpdateColor;
  if Assigned(FOnMouseLeave) then FOnMouseLeave(Self);
end;

procedure TCWSMenuButton.MouseClick(Sender: TObject);
begin
  if not FPressed then Pressed := True;
  if Assigned(FOnClick) then FOnClick(Self);
end;

procedure TCWSMenuButton.SetPressed(const Value: Boolean);
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
          if (c is TCWSMenuButton) and (c <> Self) and
             (TCWSMenuButton(c).GroupIndex = FGroupIndex) and
             TCWSMenuButton(c).Pressed then
          begin
            FAnimFromTop := TCWSMenuButton(c).Top <= Self.Top;
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

procedure TCWSMenuButton.SetCursorHeight(const Value: Integer);
begin
  if FCursorHeight = Value then Exit;
  FCursorHeight := Value;
  Resize;
  Invalidate;
end;

procedure TCWSMenuButton.UpdateGroup;
var
  i: Integer;
  c: TComponent;
begin
  if (csLoading in ComponentState) or (csReading in ComponentState) then Exit;
  if Owner = nil then Exit;
  for i := 0 to Owner.ComponentCount - 1 do
  begin
    c := Owner.Components[i];
    if (c is TCWSMenuButton) and (c <> Self) then
      if TCWSMenuButton(c).GroupIndex = FGroupIndex then
      begin
        TCWSMenuButton(c).Pressed := False;
        TCWSMenuButton(c).UpdateColor;
      end;
  end;
end;

procedure TCWSMenuButton.DoAnimTimer(Sender: TObject);
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

procedure TCWSMenuButton.UpdateColor;
begin
  if (FbckShape = nil) or (FIconBox = nil) or (Fmenu = nil) or
     (FCursor = nil) or (csDestroying in ComponentState) then
    Exit;
  if csLoading in ComponentState then
    Exit;

  if FPressed then FbckShape.Brush.Color := FbckPressedColor
  else if FHovering then FbckShape.Brush.Color := FbckHoverColor
  else FbckShape.Brush.Color := FNormalColor;
  FbckShape.Pen.Color := FbckShape.Brush.Color;

  if not FAnimTimer.Enabled then FCursor.Visible := FPressed;
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

  if FPressed then Fmenu.Font.Color := FmenuColorTextPressed
  else if FHovering then Fmenu.Font.Color := FmenuColorTextHover
  else Fmenu.Font.Color := FmenuColorTextNormal;

  FIconBox.Invalidate;
  Invalidate;
end;

procedure TCWSMenuButton.Resize;
var
  vCursorWidth, vCursorHeight: Integer;
  IconBaseLeft: Integer;
  iSize: Integer;
begin
  inherited;
  if not Assigned(FIconBox) or not Assigned(Fmenu) or not Assigned(FCursor) then
    Exit;

  // Manual background positioning — fixes losing rounded corners with akRight
  if Assigned(FbckShape) then
  begin
    FbckShape.SetBounds(0, 0, ClientWidth, ClientHeight);
    FbckShape.Invalidate;
  end;

  ApplyFontToLabel;

  vCursorWidth  := MulDiv(3, CurrentPPI, 96);
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

  IconBaseLeft := vCursorWidth + MulDiv(9, CurrentPPI, 96);
  iSize        := CalcIconSize;

  FIconBox.Width  := iSize;
  FIconBox.Height := iSize;
  FIconBox.Left   := IconBaseLeft + MulDiv(FIconOffsetX, CurrentPPI, 96);
  FIconBox.Top    := (Height - iSize) div 2 + MulDiv(FIconOffsetY, CurrentPPI, 96);

  Fmenu.Height  := Height;
  Fmenu.Visible := True;
  Fmenu.Left    := IconBaseLeft + iSize + MulDiv(17, CurrentPPI, 96);
  Fmenu.Top     := (Height - Fmenu.Height) div 2 - MulDiv(1, CurrentPPI, 96);
  Fmenu.Width   := ClientWidth - Fmenu.Left;

  FIconBox.Invalidate;
end;

procedure TCWSMenuButton.SetBckColor(const Value: TColor);
begin FbckHoverColor := Value; UpdateColor; end;

procedure TCWSMenuButton.SetBckPressedColor(const Value: TColor);
begin FbckPressedColor := Value; UpdateColor; end;

procedure TCWSMenuButton.SetCursorColor(const Value: TColor);
begin
  if FCursorColor <> Value then begin FCursorColor := Value; UpdateColor; end;
end;

procedure TCWSMenuButton.SetGroupIndex(const Value: Integer);
begin FGroupIndex := Value; end;

procedure TCWSMenuButton.SetMenuColorTextHover(const Value: TColor);
begin FmenuColorTextHover := Value; UpdateColor; end;

procedure TCWSMenuButton.SetMenuColorTextNormal(const Value: TColor);
begin FmenuColorTextNormal := Value; UpdateColor; end;

procedure TCWSMenuButton.SetMenuColorTextPressed(const Value: TColor);
begin FmenuColorTextPressed := Value; UpdateColor; end;

procedure TCWSMenuButton.SetMenuText(const Value: string);
begin
  FmenuText := Value;
  if Assigned(Fmenu) then Fmenu.Caption := FmenuText;
end;

procedure TCWSMenuButton.SetIconColorHover(const Value: TColor);
begin FIconColorHover := Value; UpdateColor; end;

procedure TCWSMenuButton.SetIconColorNormal(const Value: TColor);
begin FIconColorNormal := Value; UpdateColor; end;

procedure TCWSMenuButton.SetIconColorPressed(const Value: TColor);
begin FIconColorPressed := Value; UpdateColor; end;

procedure TCWSMenuButton.SetIconGlyph(const Value: string);
begin
  FIconGlyphNormal := Value;
  Resize;
  Invalidate;
end;

procedure TCWSMenuButton.SetIconGlyphPressed(const Value: string);
begin
  FIconGlyphPressed := Value;
  Resize;
  Invalidate;
end;

procedure TCWSMenuButton.SetNormalColor(const Value: TColor);
begin
  if FNormalColor <> Value then begin FNormalColor := Value; UpdateColor; end;
end;

end.
