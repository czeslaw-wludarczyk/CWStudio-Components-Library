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
unit CWSShape;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Graphics;

type
  TShapeKind = (Rectangle, RoundRectangle);
  TShapeBrushStyle = (Solid, Clear);
  TShapePenStyle = (Solid, Clear);

  { Caption placement relative to the indicator — shared by the CWStudio
    radio / check box / switch components. }
  TCWSTextPosition = (tpRight, tpLeft, tpTop, tpBottom);

  { Fill description }
  TCWSShapeBrush = class(TPersistent)
  private
    FColor: TColor;
    FStyle: TShapeBrushStyle;
    FOnChange: TNotifyEvent;
    procedure SetColor(const Value: TColor);
    procedure SetStyle(const Value: TShapeBrushStyle);
  protected
    procedure Changed;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property Color: TColor read FColor write SetColor default clWhite;
    property Style: TShapeBrushStyle read FStyle write SetStyle default TShapeBrushStyle.Solid;
  end;

  { Border description }
  TCWSShapePen = class(TPersistent)
  private
    FColor: TColor;
    FWidth: Integer;
    FStyle: TShapePenStyle;
    FOnChange: TNotifyEvent;
    procedure SetColor(const Value: TColor);
    procedure SetWidth(const Value: Integer);
    procedure SetStyle(const Value: TShapePenStyle);
  protected
    procedure Changed;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property Color: TColor read FColor write SetColor default clBlack;
    property Width: Integer read FWidth write SetWidth default 1;
    property Style: TShapePenStyle read FStyle write SetStyle default TShapePenStyle.Solid;
  end;

  { Graphic shape control }
  TCWSShape = class(TGraphicControl)
  private
    FBrush: TCWSShapeBrush;
    FPen: TCWSShapePen;
    FShape: TShapeKind;
    FCornerRadius: Integer;
    procedure SetBrush(const Value: TCWSShapeBrush);
    procedure SetPen(const Value: TCWSShapePen);
    procedure SetShape(const Value: TShapeKind);
    procedure SetCornerRadius(const Value: Integer);
    procedure StyleChanged(Sender: TObject);
    function MakeGPColor(AColor: TColor): Cardinal;
    function BuildPath(X, Y, W, H, R: Single): TGPGraphicsPath;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Brush: TCWSShapeBrush read FBrush write SetBrush;
    property Pen: TCWSShapePen read FPen write SetPen;
    property Shape: TShapeKind read FShape write SetShape default TShapeKind.Rectangle;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 8;

    property Align;
    property Anchors;
    property Constraints;
    property Visible;
    property ParentShowHint;
    property ShowHint;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

{ TCWSShapeBrush }

constructor TCWSShapeBrush.Create;
begin
  inherited Create;
  FColor := clWhite;
  FStyle := TShapeBrushStyle.Solid;
end;

procedure TCWSShapeBrush.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TCWSShapeBrush.Assign(Source: TPersistent);
begin
  if Source is TCWSShapeBrush then
  begin
    FColor := TCWSShapeBrush(Source).FColor;
    FStyle := TCWSShapeBrush(Source).FStyle;
    Changed;
  end
  else
    inherited Assign(Source);
end;

procedure TCWSShapeBrush.SetColor(const Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    Changed;
  end;
end;

procedure TCWSShapeBrush.SetStyle(const Value: TShapeBrushStyle);
begin
  if FStyle <> Value then
  begin
    FStyle := Value;
    Changed;
  end;
end;

{ TCWSShapePen }

constructor TCWSShapePen.Create;
begin
  inherited Create;
  FColor := clBlack;
  FWidth := 1;
  FStyle := TShapePenStyle.Solid;
end;

procedure TCWSShapePen.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TCWSShapePen.Assign(Source: TPersistent);
begin
  if Source is TCWSShapePen then
  begin
    FColor := TCWSShapePen(Source).FColor;
    FWidth := TCWSShapePen(Source).FWidth;
    FStyle := TCWSShapePen(Source).FStyle;
    Changed;
  end
  else
    inherited Assign(Source);
end;

procedure TCWSShapePen.SetColor(const Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    Changed;
  end;
end;

procedure TCWSShapePen.SetWidth(const Value: Integer);
begin
  if FWidth <> Value then
  begin
    FWidth := Value;
    Changed;
  end;
end;

procedure TCWSShapePen.SetStyle(const Value: TShapePenStyle);
begin
  if FStyle <> Value then
  begin
    FStyle := Value;
    Changed;
  end;
end;

{ TCWSShape }

constructor TCWSShape.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBrush := TCWSShapeBrush.Create;
  FBrush.OnChange := StyleChanged;
  FPen := TCWSShapePen.Create;
  FPen.OnChange := StyleChanged;
  FShape := TShapeKind.Rectangle;
  FCornerRadius := 8;
  Width := 65;
  Height := 65;
end;

destructor TCWSShape.Destroy;
begin
  FBrush.Free;
  FPen.Free;
  inherited;
end;

procedure TCWSShape.SetBrush(const Value: TCWSShapeBrush);
begin
  FBrush.Assign(Value);
end;

procedure TCWSShape.SetPen(const Value: TCWSShapePen);
begin
  FPen.Assign(Value);
end;

procedure TCWSShape.SetShape(const Value: TShapeKind);
begin
  if FShape <> Value then
  begin
    FShape := Value;
    Invalidate;
  end;
end;

procedure TCWSShape.SetCornerRadius(const Value: Integer);
begin
  if FCornerRadius <> Value then
  begin
    FCornerRadius := Value;
    if FShape = TShapeKind.RoundRectangle then
      Invalidate;
  end;
end;

procedure TCWSShape.StyleChanged(Sender: TObject);
begin
  Invalidate;
end;

function TCWSShape.MakeGPColor(AColor: TColor): Cardinal;
var
  C: TColor;
begin
  C := ColorToRGB(AColor);
  Result := Winapi.GDIPAPI.MakeColor(255, GetRValue(C), GetGValue(C), GetBValue(C));
end;

function TCWSShape.BuildPath(X, Y, W, H, R: Single): TGPGraphicsPath;
var
  D: Single;
begin
  Result := TGPGraphicsPath.Create;
  if (FShape = TShapeKind.RoundRectangle) and (R > 0) then
  begin
    D := R * 2;
    if D > H then D := H;
    if D > W then D := W;
    if D < 0 then D := 0;
    if D = 0 then
    begin
      Result.AddRectangle(MakeRect(X, Y, W, H));
    end
    else
    begin
      Result.AddArc(X,         Y,         D, D, 180, 90);
      Result.AddArc(X + W - D, Y,         D, D, 270, 90);
      Result.AddArc(X + W - D, Y + H - D, D, D,   0, 90);
      Result.AddArc(X,         Y + H - D, D, D,  90, 90);
      Result.CloseFigure;
    end;
  end
  else
    Result.AddRectangle(MakeRect(X, Y, W, H));
end;

procedure TCWSShape.Paint;
var
  G: TGPGraphics;
  Path: TGPGraphicsPath;
  GBrush: TGPSolidBrush;
  GPen: TGPPen;
  PW, X, Y, W, H: Single;
  HasBorder: Boolean;
begin
  if (Width <= 0) or (Height <= 0) then
    Exit;

  HasBorder := (FPen.Style = TShapePenStyle.Solid) and (FPen.Width > 0);
  if HasBorder then
    PW := FPen.Width
  else
    PW := 0;

  { Inset by half the pen width so the stroke stays fully inside the bounds }
  X := PW / 2;
  Y := PW / 2;
  W := Width - PW;
  H := Height - PW;
  if W < 0 then W := 0;
  if H < 0 then H := 0;

  G := TGPGraphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    G.SetPixelOffsetMode(PixelOffsetModeHalf);

    Path := BuildPath(X, Y, W, H, FCornerRadius);
    try
      { Fill — clNone is treated as "no fill" (transparent) }
      if (FBrush.Style = TShapeBrushStyle.Solid) and (FBrush.Color <> clNone) then
      begin
        GBrush := TGPSolidBrush.Create(MakeGPColor(FBrush.Color));
        try
          G.FillPath(GBrush, Path);
        finally
          GBrush.Free;
        end;
      end;

      { Border }
      if HasBorder then
      begin
        GPen := TGPPen.Create(MakeGPColor(FPen.Color), PW);
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
end;

end.
