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
  System.SysUtils, System.Classes, System.Types, System.UITypes,
  Vcl.Controls, Vcl.Graphics, Vcl.ExtCtrls, Vcl.ImgList,
  System.Skia, Vcl.Skia, Windows, Messages;

type
  TCWSIconMode = (icmGlyph, icmImageList);

  { The whole button is rendered by Skia in a single Draw pass: background,
    the animated selection cursor, the icon (glyph or image list) and the
    description text. No child controls are involved. }
  TCWSStoreButton = class(TSkCustomWinControl)
  private
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

    FAnimTimer: TTimer;
    FAnimCurrentH: Single;
    FAnimTop: Single;
    FAnimTargetH: Single;
    FAnimShowing: Boolean;
    FAnimFromTop: Boolean;

    FIconMode: TCWSIconMode;
    FImages: TCustomImageList;
    FImageIndex: Integer;
    FImageIndexPressed: Integer;

    FIconOffsetX: Integer;
    FIconOffsetY: Integer;

    { Skia resources are cached because Draw runs on every repaint and on
      every animation frame. }
    FIconTypeface: ISkTypeface;
    FTextTypeface: ISkTypeface;
    FIconImage: ISkImage;
    FIconImageKey: string;

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

    procedure UpdateGroup;
    procedure DoAnimTimer(Sender: TObject);
    procedure UpdateCursorGeometry;

    function  CurrentIconColor: TColor;
    function  CurrentBackColor: TColor;
    function  CurrentDescriptionColor: TColor;
    function  ScaledCursorHeight: Single;
    function  Scaled(const AValue: Single): Single;

    function  IconFont: ISkFont;
    function  DescriptionFont: ISkFont;
    function  IconImage: ISkImage;

    procedure DrawContent(const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
    procedure DrawIcon(const ACanvas: ISkCanvas; const ACenter: TPointF; const AOpacity: Single);
    procedure DrawDescription(const ACanvas: ISkCanvas; const ACenter: TPointF; const AOpacity: Single);

  protected
    procedure Draw(const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single); override;
    procedure Resize; override;
    procedure Loaded; override;
    procedure Click; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;

  public
    constructor Create(AOwner: TComponent); override;

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

    property OnClick;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseDown;
    property OnMouseUp;
  end;

implementation

uses
  System.TypInfo;

const
  { design-time (96 dpi) metrics }
  cCornerRadius   = 4;
  cCursorRadius   = 2;
  cCursorWidth    = 4;
  cDescriptionH   = 12;
  cDescriptionPad = 4;
  cDefaultIconSize = 24;

function ToAlphaColor(const AColor: TColor; const AOpacity: Single): TAlphaColor;
var
  LRGB: Cardinal;
  LAlpha: Cardinal;
begin
  LRGB := ColorToRGB(AColor);
  LAlpha := Round(255 * AOpacity);
  if LAlpha > 255 then LAlpha := 255;
  Result := TAlphaColor((LAlpha shl 24) or ((LRGB and $FF) shl 16) or
                        (LRGB and $FF00) or ((LRGB shr 16) and $FF));
end;

{ TCWSStoreButton }

constructor TCWSStoreButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ParentColor := False;

  { The rounded corners have to blend with whatever sits behind the button, so
    the surface must start out transparent (the base class defaults it to
    opaque white) and the parent has to be painted underneath it. }
  BackgroundColor := TAlphaColors.Null;
  AllowDrawParentInBackground := True;
  DrawCacheKind := TSkDrawCacheKind.Raster;

  FIconGlyphNormal  := '';
  FIconGlyphPressed := '';
  FdescriptionText  := 'Home';

  FPressed    := False;
  FHovering   := False;
  FGroupIndex := 0;

  FNormalColor             := clBtnFace;
  FbckHoverColor           := clSilver;
  FbckPressedColor         := clWhite;
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
  Self.Color      := clBtnFace;

  FAnimTimer          := TTimer.Create(Self);
  FAnimTimer.Interval := 16;
  FAnimTimer.Enabled  := False;
  FAnimTimer.OnTimer  := DoAnimTimer;
  FAnimCurrentH       := 0;
  FAnimShowing        := False;

  Width  := MulDiv(63, CurrentPPI, 96);
  Height := MulDiv(57, CurrentPPI, 96);
end;

function TCWSStoreButton.Scaled(const AValue: Single): Single;
begin
  Result := AValue * CurrentPPI / 96;
end;

function TCWSStoreButton.ScaledCursorHeight: Single;
begin
  Result := Scaled(FCursorHeight);
end;

function TCWSStoreButton.CurrentBackColor: TColor;
begin
  if FPressed then Result := FbckPressedColor
  else if FHovering then Result := FbckHoverColor
  else Result := FNormalColor;
end;

function TCWSStoreButton.CurrentIconColor: TColor;
begin
  if FPressed then Result := FIconColorPressed
  else if FHovering then Result := FIconColorHover
  else Result := FIconColorNormal;
end;

function TCWSStoreButton.CurrentDescriptionColor: TColor;
begin
  if FPressed then Result := FDescriptionColorPressed
  else if FHovering then Result := FDescriptionColorHover
  else Result := FDescriptionColorNormal;
end;

{ ---------------------------------------------------------------- Skia fonts }

function TCWSStoreButton.IconFont: ISkFont;
var
  LSize: Single;
begin
  if FIconTypeface = nil then
    FIconTypeface := TSkTypeface.MakeFromName(FIconFontName, TSkFontStyle.Normal);

  LSize := FIconFontSize * CurrentPPI / 72;
  if LSize <= 0 then
    LSize := Scaled(cDefaultIconSize);

  Result := TSkFont.Create(FIconTypeface, LSize, 1, 0);
  Result.Edging := TSkFontEdging.AntiAlias;
  Result.Subpixel := True;
end;

function TCWSStoreButton.DescriptionFont: ISkFont;
var
  LWeight: TSkFontWeight;
  LSlant: TSkFontSlant;
  LSize: Single;
begin
  if FTextTypeface = nil then
  begin
    if fsBold in Font.Style then LWeight := TSkFontWeight.Bold
    else LWeight := TSkFontWeight.Normal;
    if fsItalic in Font.Style then LSlant := TSkFontSlant.Italic
    else LSlant := TSkFontSlant.Upright;
    FTextTypeface := TSkTypeface.MakeFromName(Font.Name,
      TSkFontStyle.Create(LWeight, TSkFontWidth.Normal, LSlant));
  end;

  LSize := Font.Size * CurrentPPI / 72;
  if LSize <= 0 then
    LSize := Scaled(7 * 96 / 72);

  Result := TSkFont.Create(FTextTypeface, LSize, 1, 0);
  Result.Edging := TSkFontEdging.SubpixelAntiAlias;
  Result.Subpixel := True;
end;

function TCWSStoreButton.IconImage: ISkImage;
var
  LIndex: Integer;
  LColor: TColor;
  LKey: string;
  LBitmap: Vcl.Graphics.TBitmap;
  LSavedColor: Integer;
begin
  Result := nil;
  if (FImages = nil) or (FImages.Width <= 0) or (FImages.Height <= 0) then
    Exit;

  if FPressed and (FImageIndexPressed >= 0) then LIndex := FImageIndexPressed
  else LIndex := FImageIndex;
  if (LIndex < 0) or (LIndex >= FImages.Count) then
    Exit;

  LColor := CurrentIconColor;
  LKey := Format('%d|%d|%dx%d', [LIndex, Integer(LColor), FImages.Width, FImages.Height]);
  if (FIconImage <> nil) and (FIconImageKey = LKey) then
    Exit(FIconImage);

  LBitmap := Vcl.Graphics.TBitmap.Create;
  try
    LBitmap.PixelFormat := pf32bit;
    LBitmap.SetSize(FImages.Width, FImages.Height);
    { A freshly created DIB section is zero filled, so switching the alpha
      format here premultiplies nothing - it only tells TBitmap (and in turn
      BitmapToSkImage) that the bits the image list writes carry alpha. }
    LBitmap.AlphaFormat := afDefined;

    { Tint monochrome SVG icons to the current state colour without a
      compile-time dependency on SVGIconImageList: if the assigned image list
      publishes a FixedColor property (TSVGIconImageList does), drive it via
      RTTI. Any other image list just draws as-is. }
    if IsPublishedProp(FImages, 'FixedColor') then
    begin
      LSavedColor := GetOrdProp(FImages, 'FixedColor');
      SetOrdProp(FImages, 'FixedColor', LColor);
      try
        FImages.Draw(LBitmap.Canvas, 0, 0, LIndex);
      finally
        SetOrdProp(FImages, 'FixedColor', LSavedColor);
      end;
    end
    else
      FImages.Draw(LBitmap.Canvas, 0, 0, LIndex);

    FIconImage    := BitmapToSkImage(LBitmap);
    FIconImageKey := LKey;
    Result        := FIconImage;
  finally
    LBitmap.Free;
  end;
end;

{ -------------------------------------------------------------------- Drawing }

procedure TCWSStoreButton.Draw(const ACanvas: ISkCanvas; const ADest: TRectF;
  const AOpacity: Single);
var
  LScale: Single;
begin
  if (Width <= 0) or (Height <= 0) or ADest.IsEmpty then
    Exit;

  { Everything below is laid out in the control's own pixel space, so map
    ADest onto it once instead of scaling every single metric. }
  LScale := ADest.Height / Height;

  ACanvas.Save;
  try
    ACanvas.Translate(ADest.Left, ADest.Top);
    if LScale <> 1 then
      ACanvas.Scale(LScale, LScale);
    DrawContent(ACanvas, RectF(0, 0, Width, Height), AOpacity);
  finally
    ACanvas.Restore;
  end;
end;

procedure TCWSStoreButton.DrawContent(const ACanvas: ISkCanvas; const ADest: TRectF;
  const AOpacity: Single);
var
  LPaint: ISkPaint;
  LRadius: Single;
  LDescHeight: Single;
  LCenter: TPointF;
begin
  LPaint := TSkPaint.Create(TSkPaintStyle.Fill);
  LPaint.AntiAlias := True;

  { background }
  LRadius := Scaled(cCornerRadius);
  LPaint.Color := ToAlphaColor(CurrentBackColor, AOpacity);
  ACanvas.DrawRoundRect(ADest, LRadius, LRadius, LPaint);

  { selection cursor on the left edge }
  if FAnimCurrentH > 0 then
  begin
    LRadius := Scaled(cCursorRadius);
    LPaint.Color := ToAlphaColor(FCursorColor, AOpacity);
    ACanvas.DrawRoundRect(
      RectF(ADest.Left, ADest.Top + FAnimTop,
            ADest.Left + Scaled(cCursorWidth), ADest.Top + FAnimTop + FAnimCurrentH),
      LRadius, LRadius, LPaint);
  end;

  LDescHeight := Scaled(cDescriptionH);

  { icon - vertically centred over the whole button when pressed (the
    description is hidden then), otherwise over the area above it }
  LCenter.X := ADest.Left + ADest.Width / 2 + Scaled(FIconOffsetX);
  if FPressed then
    LCenter.Y := ADest.Top + ADest.Height / 2 + Scaled(FIconOffsetY)
  else
    LCenter.Y := ADest.Top + (ADest.Height - LDescHeight) / 2 + Scaled(FIconOffsetY);
  DrawIcon(ACanvas, LCenter, AOpacity);

  { description }
  if not FPressed then
    DrawDescription(ACanvas,
      PointF(ADest.Left + ADest.Width / 2,
             ADest.Bottom - Scaled(cDescriptionPad) - LDescHeight / 2),
      AOpacity);
end;

procedure TCWSStoreButton.DrawIcon(const ACanvas: ISkCanvas; const ACenter: TPointF;
  const AOpacity: Single);
var
  LGlyph: string;
  LFont: ISkFont;
  LPaint: ISkPaint;
  LMetrics: TSkFontMetrics;
  LImage: ISkImage;
  LHalfW, LHalfH: Single;
begin
  case FIconMode of
    icmGlyph:
      begin
        if FPressed then LGlyph := FIconGlyphPressed
        else LGlyph := FIconGlyphNormal;
        if LGlyph = '' then
          Exit;

        LFont := IconFont;
        LFont.GetMetrics(LMetrics);

        LPaint := TSkPaint.Create(TSkPaintStyle.Fill);
        LPaint.AntiAlias := True;
        LPaint.Color := ToAlphaColor(CurrentIconColor, AOpacity);

        ACanvas.DrawSimpleText(LGlyph,
          ACenter.X - LFont.MeasureText(LGlyph) / 2,
          ACenter.Y - (LMetrics.Ascent + LMetrics.Descent) / 2,
          LFont, LPaint);
      end;

    icmImageList:
      begin
        LImage := IconImage;
        if LImage = nil then
          Exit;

        LPaint := TSkPaint.Create;
        LPaint.AntiAlias := True;
        LPaint.AlphaF := AOpacity;

        LHalfW := LImage.Width / 2;
        LHalfH := LImage.Height / 2;
        ACanvas.DrawImageRect(LImage,
          RectF(ACenter.X - LHalfW, ACenter.Y - LHalfH,
                ACenter.X + LHalfW, ACenter.Y + LHalfH),
          TSkSamplingOptions.High, LPaint);
      end;
  end;
end;

procedure TCWSStoreButton.DrawDescription(const ACanvas: ISkCanvas; const ACenter: TPointF;
  const AOpacity: Single);
var
  LFont: ISkFont;
  LPaint: ISkPaint;
  LMetrics: TSkFontMetrics;
begin
  if FdescriptionText = '' then
    Exit;

  LFont := DescriptionFont;
  LFont.GetMetrics(LMetrics);

  LPaint := TSkPaint.Create(TSkPaintStyle.Fill);
  LPaint.AntiAlias := True;
  LPaint.Color := ToAlphaColor(CurrentDescriptionColor, AOpacity);

  ACanvas.DrawSimpleText(FdescriptionText,
    ACenter.X - LFont.MeasureText(FdescriptionText) / 2,
    ACenter.Y - (LMetrics.Ascent + LMetrics.Descent) / 2,
    LFont, LPaint);
end;

{ ------------------------------------------------------------------- Lifecycle }

procedure TCWSStoreButton.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FImages) then
  begin
    FImages       := nil;
    FIconImage    := nil;
    FIconImageKey := '';
    Redraw;
  end;
end;

procedure TCWSStoreButton.CMFontChanged(var Message: TMessage);
begin
  inherited;
  FTextTypeface := nil;
  Redraw;
end;

procedure TCWSStoreButton.CMColorChanged(var Message: TMessage);
begin
  inherited;
  Redraw;
end;

procedure TCWSStoreButton.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited;
  UpdateCursorGeometry;
  Redraw;
end;

procedure TCWSStoreButton.Resize;
begin
  inherited;
  if (FAnimTimer = nil) or not FAnimTimer.Enabled then
    UpdateCursorGeometry;
  Redraw;
end;

procedure TCWSStoreButton.Loaded;
begin
  inherited;
  UpdateCursorGeometry;
  Redraw;
end;

{ ----------------------------------------------------------------------- Mouse }

procedure TCWSStoreButton.CMMouseEnter(var Message: TMessage);
begin
  FHovering := True;
  Redraw;
  inherited;
end;

procedure TCWSStoreButton.CMMouseLeave(var Message: TMessage);
begin
  FHovering := False;
  Redraw;
  inherited;
end;

procedure TCWSStoreButton.Click;
begin
  if not FPressed then
    Pressed := True;
  inherited;
end;

{ ------------------------------------------------------------------- Animation }

procedure TCWSStoreButton.UpdateCursorGeometry;
begin
  if FPressed then FAnimCurrentH := ScaledCursorHeight
  else FAnimCurrentH := 0;
  FAnimTop := (Height - FAnimCurrentH) / 2;
end;

procedure TCWSStoreButton.DoAnimTimer(Sender: TObject);
var
  LStep, LFinalTop, LFinalBottom: Single;
begin
  if csDestroying in ComponentState then
  begin
    FAnimTimer.Enabled := False;
    Exit;
  end;

  LFinalTop    := (Height - FAnimTargetH) / 2;
  LFinalBottom := LFinalTop + FAnimTargetH;

  if FAnimShowing then
  begin
    LStep := (FAnimCurrentH - FAnimTargetH) / 3;
    if LStep < 2 then LStep := 2;
    FAnimCurrentH := FAnimCurrentH - LStep;
    if FAnimCurrentH <= FAnimTargetH then
    begin
      FAnimCurrentH      := FAnimTargetH;
      FAnimTimer.Enabled := False;
    end;
    if FAnimFromTop then FAnimTop := LFinalBottom - FAnimCurrentH
    else FAnimTop := LFinalTop;
  end
  else
  begin
    LStep := FAnimCurrentH / 3;
    if LStep < 2 then LStep := 2;
    FAnimCurrentH := FAnimCurrentH - LStep;
    if FAnimCurrentH <= 0 then
    begin
      FAnimCurrentH      := 0;
      FAnimTimer.Enabled := False;
    end;
    FAnimTop := (Height - FAnimCurrentH) / 2;
  end;

  Redraw;
end;

{ ----------------------------------------------------------------------- State }

procedure TCWSStoreButton.SetPressed(const Value: Boolean);
var
  i: Integer;
  c: TComponent;
  LFinalTop, LFinalBottom, LStartH: Single;
  LTargetH: Single;
begin
  if FPressed = Value then Exit;
  FPressed := Value;

  { the icon may differ between the normal and the pressed state }
  FIconImage    := nil;
  FIconImageKey := '';

  if not (csLoading in ComponentState) and not (csDesigning in ComponentState) then
  begin
    LTargetH     := ScaledCursorHeight;
    FAnimTargetH := LTargetH;
    FAnimShowing := FPressed;

    if FPressed then
    begin
      { grow towards the previously selected sibling so the bar always
        travels in the direction the selection moved }
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

      LFinalTop    := (Height - LTargetH) / 2;
      LFinalBottom := LFinalTop + LTargetH;
      if FAnimFromTop then LStartH := LFinalBottom
      else LStartH := Height - LFinalTop;

      FAnimCurrentH := LStartH;
      if FAnimFromTop then FAnimTop := 0
      else FAnimTop := LFinalTop;
    end;

    FAnimTimer.Enabled := True;
  end
  else
    UpdateCursorGeometry;

  Redraw;

  if FPressed and (FGroupIndex <> 0) and not (csLoading in ComponentState) then
    UpdateGroup;
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
        TCWSStoreButton(c).Pressed := False;
  end;
end;

{ ------------------------------------------------------------------- Setters }

procedure TCWSStoreButton.SetIconMode(const Value: TCWSIconMode);
begin
  if FIconMode = Value then Exit;
  FIconMode := Value;
  Redraw;
end;

procedure TCWSStoreButton.SetImages(const Value: TCustomImageList);
begin
  if FImages = Value then Exit;
  if FImages <> nil then FImages.RemoveFreeNotification(Self);
  FImages := Value;
  if FImages <> nil then FImages.FreeNotification(Self);
  FIconImage    := nil;
  FIconImageKey := '';
  Redraw;
end;

procedure TCWSStoreButton.SetImageIndex(const Value: Integer);
begin
  if FImageIndex = Value then Exit;
  FImageIndex := Value;
  if FIconMode = icmImageList then Redraw;
end;

procedure TCWSStoreButton.SetImageIndexPressed(const Value: Integer);
begin
  if FImageIndexPressed = Value then Exit;
  FImageIndexPressed := Value;
  if (FIconMode = icmImageList) and FPressed then Redraw;
end;

procedure TCWSStoreButton.SetIconOffsetX(const Value: Integer);
begin
  if FIconOffsetX = Value then Exit;
  FIconOffsetX := Value;
  Redraw;
end;

procedure TCWSStoreButton.SetIconOffsetY(const Value: Integer);
begin
  if FIconOffsetY = Value then Exit;
  FIconOffsetY := Value;
  Redraw;
end;

procedure TCWSStoreButton.SetIconFontName(const Value: string);
begin
  if FIconFontName = Value then Exit;
  if Value = '' then FIconFontName := 'Segoe Fluent Icons'
  else FIconFontName := Value;
  FIconTypeface := nil;
  Redraw;
end;

procedure TCWSStoreButton.SetIconFontSize(const Value: Integer);
begin
  if FIconFontSize = Value then Exit;
  FIconFontSize := Value;
  Redraw;
end;

procedure TCWSStoreButton.SetCursorHeight(const Value: Integer);
begin
  if FCursorHeight = Value then Exit;
  FCursorHeight := Value;
  if (FAnimTimer = nil) or not FAnimTimer.Enabled then
    UpdateCursorGeometry;
  Redraw;
end;

procedure TCWSStoreButton.SetBckColor(const Value: TColor);
begin
  if FbckHoverColor = Value then Exit;
  FbckHoverColor := Value;
  Redraw;
end;

procedure TCWSStoreButton.SetBckPressedColor(const Value: TColor);
begin
  if FbckPressedColor = Value then Exit;
  FbckPressedColor := Value;
  Redraw;
end;

procedure TCWSStoreButton.SetNormalColor(const Value: TColor);
begin
  if FNormalColor = Value then Exit;
  FNormalColor := Value;
  Redraw;
end;

procedure TCWSStoreButton.SetCursorColor(const Value: TColor);
begin
  if FCursorColor = Value then Exit;
  FCursorColor := Value;
  Redraw;
end;

procedure TCWSStoreButton.SetGroupIndex(const Value: Integer);
begin
  FGroupIndex := Value;
end;

procedure TCWSStoreButton.SetDescriptionColorHover(const Value: TColor);
begin
  if FDescriptionColorHover = Value then Exit;
  FDescriptionColorHover := Value;
  Redraw;
end;

procedure TCWSStoreButton.SetDescriptionColorNormal(const Value: TColor);
begin
  if FDescriptionColorNormal = Value then Exit;
  FDescriptionColorNormal := Value;
  Redraw;
end;

procedure TCWSStoreButton.SetDescriptionColorPressed(const Value: TColor);
begin
  if FDescriptionColorPressed = Value then Exit;
  FDescriptionColorPressed := Value;
  Redraw;
end;

procedure TCWSStoreButton.SetDescriptionText(const Value: string);
begin
  if FdescriptionText = Value then Exit;
  FdescriptionText := Value;
  Redraw;
end;

procedure TCWSStoreButton.SetIconColorHover(const Value: TColor);
begin
  if FIconColorHover = Value then Exit;
  FIconColorHover := Value;
  Redraw;
end;

procedure TCWSStoreButton.SetIconColorNormal(const Value: TColor);
begin
  if FIconColorNormal = Value then Exit;
  FIconColorNormal := Value;
  Redraw;
end;

procedure TCWSStoreButton.SetIconColorPressed(const Value: TColor);
begin
  if FIconColorPressed = Value then Exit;
  FIconColorPressed := Value;
  Redraw;
end;

procedure TCWSStoreButton.SetIconGlyph(const Value: string);
begin
  if FIconGlyphNormal = Value then Exit;
  FIconGlyphNormal := Value;
  Redraw;
end;

procedure TCWSStoreButton.SetIconGlyphPressed(const Value: string);
begin
  if FIconGlyphPressed = Value then Exit;
  FIconGlyphPressed := Value;
  Redraw;
end;

end.
