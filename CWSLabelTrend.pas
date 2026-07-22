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
unit CWSLabelTrend;

{
  TCWSLabelTrend - a "pill" / badge label (like the coloured status tags
  Lead / Prospects / POC / Closed ...).

  - Capsule-shaped, anti-aliased (GDI+), with a solid fill (Color) and an
    optional border (BorderColor / BorderWidth).
  - Auto-sizes to its content (icon + text) with light margins; set
    AutoSize := False to size it manually.
  - An icon can be placed on the LEFT and/or the RIGHT of the text. Each side
    can be a glyph (an icon-font character, e.g. Segoe MDL2 Assets) or an image
    taken from an ImageList - same idea as TCWSMenuButton.
  - Exposes the same events as a normal label (OnClick, OnDblClick, mouse
    events, OnMouseEnter / OnMouseLeave, OnContextPopup).
}

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  System.SysUtils, System.Classes, System.Types, System.Math,
  Vcl.Controls, Vcl.Graphics, Vcl.ImgList;

type
  // What an icon slot (left / right) shows.
  TCWSTrendIcon = (tiNone, tiGlyph, tiImage);

  TCWSLabelTrend = class(TGraphicControl)
  private
    FCaption: string;
    FBorderColor: TColor;
    FBorderWidth: Integer;
    FCornerRadius: Integer;     // 0 = capsule (radius = height / 2)
    FPaddingHorz: Integer;
    FPaddingVert: Integer;
    FIconSpacing: Integer;

    FIconFontName: string;
    FIconFontSize: Integer;
    FIconColor: TColor;

    FLeftIcon: TCWSTrendIcon;
    FRightIcon: TCWSTrendIcon;
    FLeftGlyph: string;
    FRightGlyph: string;
    FLeftImageIndex: Integer;
    FRightImageIndex: Integer;
    FImages: TCustomImageList;

    FMeasureBmp: TBitmap;

    procedure SetCaption(const Value: string);
    procedure SetBorderColor(Value: TColor);
    procedure SetBorderWidth(Value: Integer);
    procedure SetCornerRadius(Value: Integer);
    procedure SetPaddingHorz(Value: Integer);
    procedure SetPaddingVert(Value: Integer);
    procedure SetIconSpacing(Value: Integer);
    procedure SetIconFontName(const Value: string);
    procedure SetIconFontSize(Value: Integer);
    procedure SetIconColor(Value: TColor);
    procedure SetLeftIcon(Value: TCWSTrendIcon);
    procedure SetRightIcon(Value: TCWSTrendIcon);
    procedure SetLeftGlyph(const Value: string);
    procedure SetRightGlyph(const Value: string);
    procedure SetLeftImageIndex(Value: Integer);
    procedure SetRightImageIndex(Value: Integer);
    procedure SetImages(Value: TCustomImageList);

    function Scaled(Value: Integer): Integer;
    procedure MeasureIcon(AKind: TCWSTrendIcon; const AGlyph: string;
      AImageIndex: Integer; out AW, AH: Integer);
    function MeasureContent: TSize;
    procedure DrawIcon(ACanvas: TCanvas; AKind: TCWSTrendIcon; const AGlyph: string;
      AImageIndex: Integer; AX, AAreaTop, AAreaHeight: Integer);
    procedure ContentChanged;

    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
  protected
    procedure Paint; override;
    procedure Loaded; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Caption: string read FCaption write SetCaption;
    property Color default $00B57341;
    property BorderColor: TColor read FBorderColor write SetBorderColor default clGray;
    property BorderWidth: Integer read FBorderWidth write SetBorderWidth default 0;
    // 0 = full capsule (corner radius follows the height); > 0 = fixed radius
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 12;
    property PaddingHorz: Integer read FPaddingHorz write SetPaddingHorz default 14;
    property PaddingVert: Integer read FPaddingVert write SetPaddingVert default 5;
    property IconSpacing: Integer read FIconSpacing write SetIconSpacing default 6;

    property IconFontName: string read FIconFontName write SetIconFontName;
    property IconFontSize: Integer read FIconFontSize write SetIconFontSize default 11;
    property IconColor: TColor read FIconColor write SetIconColor default clWhite;

    property LeftIcon: TCWSTrendIcon read FLeftIcon write SetLeftIcon default tiNone;
    property RightIcon: TCWSTrendIcon read FRightIcon write SetRightIcon default tiNone;
    property LeftGlyph: string read FLeftGlyph write SetLeftGlyph;
    property RightGlyph: string read FRightGlyph write SetRightGlyph;
    property LeftImageIndex: Integer read FLeftImageIndex write SetLeftImageIndex default -1;
    property RightImageIndex: Integer read FRightImageIndex write SetRightImageIndex default -1;
    property Images: TCustomImageList read FImages write SetImages;

    property Align;
    property Anchors;
    property AutoSize default True;
    property Constraints;
    property Cursor;
    property Enabled;
    property Font;
    property ParentFont;
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

{ TCWSLabelTrend }

constructor TCWSLabelTrend.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCaption       := 'Label';
  Color          := $00B57341;
  FBorderColor   := clGray;
  FBorderWidth   := 0;
  FCornerRadius  := 12;
  FPaddingHorz   := 14;
  FPaddingVert   := 5;
  FIconSpacing   := 6;

  FIconFontName  := 'Segoe MDL2 Assets';
  FIconFontSize  := 11;
  FIconColor     := clWhite;

  FLeftIcon        := tiNone;
  FRightIcon       := tiNone;
  FLeftImageIndex  := -1;
  FRightImageIndex := -1;

  FMeasureBmp := TBitmap.Create;
  FMeasureBmp.SetSize(1, 1);

  Font.Name  := 'Segoe UI';
  Font.Size  := 9;
  Font.Color := clWhite;

  AutoSize := True;
  Width  := 80;
  Height := 24;
end;

destructor TCWSLabelTrend.Destroy;
begin
  FMeasureBmp.Free;
  inherited Destroy;
end;

procedure TCWSLabelTrend.Loaded;
begin
  inherited Loaded;
  AdjustSize;
end;

procedure TCWSLabelTrend.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FImages) then
  begin
    FImages := nil;
    ContentChanged;
  end;
end;

function TCWSLabelTrend.Scaled(Value: Integer): Integer;
var
  PPI: Integer;
begin
  PPI := CurrentPPI;
  if PPI <= 0 then
    PPI := 96;
  Result := MulDiv(Value, PPI, 96);
end;

{ Recompute size (when AutoSize) and repaint after a content/metric change. }
procedure TCWSLabelTrend.ContentChanged;
begin
  if csLoading in ComponentState then
    Exit;
  if AutoSize then
    AdjustSize;
  Invalidate;
end;

procedure TCWSLabelTrend.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited ChangeScale(M, D, isDpiChange);
  // Paddings / border / radius / icon size are stored in logical (96 dpi) units
  // and scaled at use time via Scaled(), so only a re-measure is needed here.
  ContentChanged;
end;

{ --- Measurement --- }

procedure TCWSLabelTrend.MeasureIcon(AKind: TCWSTrendIcon; const AGlyph: string;
  AImageIndex: Integer; out AW, AH: Integer);
begin
  AW := 0;
  AH := 0;
  case AKind of
    tiGlyph:
      if AGlyph <> '' then
      begin
        FMeasureBmp.Canvas.Font.Name          := FIconFontName;
        FMeasureBmp.Canvas.Font.PixelsPerInch := CurrentPPI;
        FMeasureBmp.Canvas.Font.Size          := FIconFontSize;
        AW := FMeasureBmp.Canvas.TextWidth(AGlyph);
        AH := FMeasureBmp.Canvas.TextHeight(AGlyph);
      end;
    tiImage:
      if Assigned(FImages) and (AImageIndex >= 0) and (AImageIndex < FImages.Count) then
      begin
        AW := FImages.Width;
        AH := FImages.Height;
      end;
  end;
end;

function TCWSLabelTrend.MeasureContent: TSize;
var
  TW, TH, LW, LH, RW, RH, IH, Pad, VPad, Gap, Count: Integer;
begin
  FMeasureBmp.Canvas.Font.Assign(Font);
  TH := FMeasureBmp.Canvas.TextHeight('Ag');
  if FCaption <> '' then
    TW := FMeasureBmp.Canvas.TextWidth(FCaption)
  else
    TW := 0;

  MeasureIcon(FLeftIcon,  FLeftGlyph,  FLeftImageIndex,  LW, LH);
  MeasureIcon(FRightIcon, FRightGlyph, FRightImageIndex, RW, RH);

  Pad  := Scaled(FPaddingHorz);
  VPad := Scaled(FPaddingVert);
  Gap  := Scaled(FIconSpacing);

  IH := Max(TH, Max(LH, RH));

  Count := 0;
  Result.cx := 2 * Pad;
  if LW > 0 then begin Inc(Result.cx, LW); Inc(Count); end;
  if TW > 0 then begin Inc(Result.cx, TW); Inc(Count); end;
  if RW > 0 then begin Inc(Result.cx, RW); Inc(Count); end;
  if Count > 1 then
    Inc(Result.cx, Gap * (Count - 1));

  Result.cy := IH + 2 * VPad;
  if Result.cy < Scaled(8) then
    Result.cy := Scaled(8);
end;

function TCWSLabelTrend.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
var
  Sz: TSize;
begin
  Result := True;
  if csLoading in ComponentState then
    Exit;
  Sz := MeasureContent;
  NewWidth  := Sz.cx;
  NewHeight := Sz.cy;
end;

{ --- Drawing --- }

procedure TCWSLabelTrend.DrawIcon(ACanvas: TCanvas; AKind: TCWSTrendIcon;
  const AGlyph: string; AImageIndex: Integer; AX, AAreaTop, AAreaHeight: Integer);
var
  W, H, Y: Integer;
  R: TRect;
begin
  MeasureIcon(AKind, AGlyph, AImageIndex, W, H);
  if W <= 0 then
    Exit;
  Y := AAreaTop + (AAreaHeight - H) div 2;

  case AKind of
    tiGlyph:
      begin
        ACanvas.Font.Name          := FIconFontName;
        ACanvas.Font.PixelsPerInch := CurrentPPI;
        ACanvas.Font.Size          := FIconFontSize;
        ACanvas.Font.Color         := FIconColor;
        ACanvas.Brush.Style        := bsClear;
        R := Rect(AX, Y, AX + W, Y + H);
        Winapi.Windows.DrawText(ACanvas.Handle, PChar(AGlyph), Length(AGlyph), R,
          DT_LEFT or DT_TOP or DT_SINGLELINE or DT_NOPREFIX);
      end;
    tiImage:
      if Assigned(FImages) then
        FImages.Draw(ACanvas, AX, Y, AImageIndex);
  end;
end;

procedure TCWSLabelTrend.Paint;
var
  G: TGPGraphics;
  Path: TGPGraphicsPath;
  GBrush: TGPSolidBrush;
  GPen: TGPPen;
  cr: LongInt;
  PW, X, Y, W, H, Rad, D: Single;
  HasBorder: Boolean;
  Pad, Gap, TW, TH, LW, LH, RW, RH, IH, AreaTop, AreaH, PosX: Integer;
  First: Boolean;

  procedure AddArc(L, T, AD, A1, A2: Single);
  begin
    Path.AddArc(L, T, AD, AD, A1, A2);
  end;

begin
  if (Width <= 0) or (Height <= 0) then
    Exit;

  HasBorder := (FBorderWidth > 0) and (FBorderColor <> clNone);
  if HasBorder then
    PW := Scaled(FBorderWidth)
  else
    PW := 0;

  // inset by half the pen width so the stroke stays inside the bounds
  X := PW / 2;
  Y := PW / 2;
  W := Width - PW;
  H := Height - PW;
  if W < 0 then W := 0;
  if H < 0 then H := 0;

  if FCornerRadius > 0 then
    Rad := Scaled(FCornerRadius)
  else
    Rad := H / 2;                       // capsule
  if Rad > W / 2 then Rad := W / 2;
  if Rad > H / 2 then Rad := H / 2;
  if Rad < 0 then Rad := 0;

  G := TGPGraphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    G.SetPixelOffsetMode(PixelOffsetModeHalf);

    Path := TGPGraphicsPath.Create;
    try
      D := Rad * 2;
      if D <= 0 then
        Path.AddRectangle(MakeRect(X, Y, W, H))
      else
      begin
        AddArc(X,         Y,         D, 180, 90);
        AddArc(X + W - D, Y,         D, 270, 90);
        AddArc(X + W - D, Y + H - D, D,   0, 90);
        AddArc(X,         Y + H - D, D,  90, 90);
        Path.CloseFigure;
      end;

      if Color <> clNone then
      begin
        cr := ColorToRGB(Color);
        GBrush := TGPSolidBrush.Create(
          MakeColor(255, GetRValue(cr), GetGValue(cr), GetBValue(cr)));
        try
          G.FillPath(GBrush, Path);
        finally
          GBrush.Free;
        end;
      end;

      if HasBorder then
      begin
        cr := ColorToRGB(FBorderColor);
        GPen := TGPPen.Create(
          MakeColor(255, GetRValue(cr), GetGValue(cr), GetBValue(cr)), PW);
        try
          G.DrawPath(GPen, Path);
        finally
          GPen.Free;
        end;
      end;
    finally
      Path.Free;
    end;
  finally
    G.Free;
  end;

  // --- content (left icon, text, right icon), vertically centred ---
  Pad := Scaled(FPaddingHorz);
  Gap := Scaled(FIconSpacing);

  Canvas.Font.Assign(Font);
  TH := Canvas.TextHeight('Ag');
  if FCaption <> '' then
    TW := Canvas.TextWidth(FCaption)
  else
    TW := 0;

  MeasureIcon(FLeftIcon,  FLeftGlyph,  FLeftImageIndex,  LW, LH);
  MeasureIcon(FRightIcon, FRightGlyph, FRightImageIndex, RW, RH);

  IH := Max(TH, Max(LH, RH));
  AreaH := IH;
  AreaTop := (Height - AreaH) div 2;

  PosX := Pad;
  First := True;

  if LW > 0 then
  begin
    DrawIcon(Canvas, FLeftIcon, FLeftGlyph, FLeftImageIndex, PosX, AreaTop, AreaH);
    Inc(PosX, LW);
    First := False;
  end;

  if TW > 0 then
  begin
    if not First then Inc(PosX, Gap);
    Canvas.Font.Assign(Font);
    Canvas.Brush.Style := bsClear;
    Canvas.TextOut(PosX, (Height - TH) div 2, FCaption);
    Inc(PosX, TW);
    First := False;
  end;

  if RW > 0 then
  begin
    if not First then Inc(PosX, Gap);
    DrawIcon(Canvas, FRightIcon, FRightGlyph, FRightImageIndex, PosX, AreaTop, AreaH);
  end;
end;

{ --- Notifications --- }

procedure TCWSLabelTrend.CMColorChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TCWSLabelTrend.CMFontChanged(var Message: TMessage);
begin
  inherited;
  ContentChanged;
end;

{ --- Property setters --- }

procedure TCWSLabelTrend.SetCaption(const Value: string);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    ContentChanged;
  end;
end;

procedure TCWSLabelTrend.SetBorderColor(Value: TColor);
begin
  if FBorderColor <> Value then
  begin
    FBorderColor := Value;
    Invalidate;
  end;
end;

procedure TCWSLabelTrend.SetBorderWidth(Value: Integer);
begin
  if Value < 0 then
    Value := 0;
  if FBorderWidth <> Value then
  begin
    FBorderWidth := Value;
    Invalidate;
  end;
end;

procedure TCWSLabelTrend.SetCornerRadius(Value: Integer);
begin
  if Value < 0 then
    Value := 0;
  if FCornerRadius <> Value then
  begin
    FCornerRadius := Value;
    Invalidate;
  end;
end;

procedure TCWSLabelTrend.SetPaddingHorz(Value: Integer);
begin
  if Value < 0 then
    Value := 0;
  if FPaddingHorz <> Value then
  begin
    FPaddingHorz := Value;
    ContentChanged;
  end;
end;

procedure TCWSLabelTrend.SetPaddingVert(Value: Integer);
begin
  if Value < 0 then
    Value := 0;
  if FPaddingVert <> Value then
  begin
    FPaddingVert := Value;
    ContentChanged;
  end;
end;

procedure TCWSLabelTrend.SetIconSpacing(Value: Integer);
begin
  if Value < 0 then
    Value := 0;
  if FIconSpacing <> Value then
  begin
    FIconSpacing := Value;
    ContentChanged;
  end;
end;

procedure TCWSLabelTrend.SetIconFontName(const Value: string);
begin
  if FIconFontName <> Value then
  begin
    FIconFontName := Value;
    ContentChanged;
  end;
end;

procedure TCWSLabelTrend.SetIconFontSize(Value: Integer);
begin
  if Value < 1 then
    Value := 1;
  if FIconFontSize <> Value then
  begin
    FIconFontSize := Value;
    ContentChanged;
  end;
end;

procedure TCWSLabelTrend.SetIconColor(Value: TColor);
begin
  if FIconColor <> Value then
  begin
    FIconColor := Value;
    Invalidate;
  end;
end;

procedure TCWSLabelTrend.SetLeftIcon(Value: TCWSTrendIcon);
begin
  if FLeftIcon <> Value then
  begin
    FLeftIcon := Value;
    ContentChanged;
  end;
end;

procedure TCWSLabelTrend.SetRightIcon(Value: TCWSTrendIcon);
begin
  if FRightIcon <> Value then
  begin
    FRightIcon := Value;
    ContentChanged;
  end;
end;

procedure TCWSLabelTrend.SetLeftGlyph(const Value: string);
begin
  if FLeftGlyph <> Value then
  begin
    FLeftGlyph := Value;
    ContentChanged;
  end;
end;

procedure TCWSLabelTrend.SetRightGlyph(const Value: string);
begin
  if FRightGlyph <> Value then
  begin
    FRightGlyph := Value;
    ContentChanged;
  end;
end;

procedure TCWSLabelTrend.SetLeftImageIndex(Value: Integer);
begin
  if FLeftImageIndex <> Value then
  begin
    FLeftImageIndex := Value;
    ContentChanged;
  end;
end;

procedure TCWSLabelTrend.SetRightImageIndex(Value: Integer);
begin
  if FRightImageIndex <> Value then
  begin
    FRightImageIndex := Value;
    ContentChanged;
  end;
end;

procedure TCWSLabelTrend.SetImages(Value: TCustomImageList);
begin
  if FImages <> Value then
  begin
    if FImages <> nil then
      FImages.RemoveFreeNotification(Self);
    FImages := Value;
    if FImages <> nil then
      FImages.FreeNotification(Self);
    ContentChanged;
  end;
end;

end.
