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
  TShapeKind = (Rectangle, RoundRectangle, Circle);
  TShapeBrushStyle = (Solid, Clear);
  TShapePenStyle = (Solid, Clear);

  { Caption placement relative to the indicator — shared by the CWStudio
    radio / check box / switch components. }
  TCWSTextPosition = (tpRight, tpLeft, tpTop, tpBottom);

  { Fill description.

    Streaming note — why these properties use "stored" functions instead of
    the usual "default" directive: a fixed "default Something" is only
    correct as long as every owning component leaves the sub-object at the
    values set in its constructor. TCWSAvatar, for instance, deliberately
    starts with a grey Brush and a Clear Pen. With a fixed default the
    designer would then refuse to save the very values that happen to match
    that default (e.g. Pen.Style = Solid), the DFM would come out empty for
    them, and the owner's constructor would silently win at run time — the
    control looks right in the designer and wrong in the running program.

    Instead, each instance remembers the values it was left with (see
    SetDefaults) and stores a property only when it actually differs from
    them. Owners that change Brush/Pen in their constructor must call
    SetDefaults at the end of it. }
  TCWSShapeBrush = class(TPersistent)
  private
    FColor: TColor;
    FStyle: TShapeBrushStyle;
    FDefColor: TColor;
    FDefStyle: TShapeBrushStyle;
    FOnChange: TNotifyEvent;
    procedure SetColor(const Value: TColor);
    procedure SetStyle(const Value: TShapeBrushStyle);
    function IsColorStored: Boolean;
    function IsStyleStored: Boolean;
  protected
    procedure Changed;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    { Takes the current values as this instance's defaults: from now on a
      property is written to the DFM only if it differs from them. Call it
      at the end of the owning component's constructor, after any
      customisation of the brush. }
    procedure SetDefaults;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property Color: TColor read FColor write SetColor stored IsColorStored;
    property Style: TShapeBrushStyle read FStyle write SetStyle stored IsStyleStored;
  end;

  { Border description. Same streaming scheme as TCWSShapeBrush — see the
    comment there. }
  TCWSShapePen = class(TPersistent)
  private
    FColor: TColor;
    FWidth: Integer;
    FStyle: TShapePenStyle;
    FDefColor: TColor;
    FDefWidth: Integer;
    FDefStyle: TShapePenStyle;
    FOnChange: TNotifyEvent;
    procedure SetColor(const Value: TColor);
    procedure SetWidth(const Value: Integer);
    procedure SetStyle(const Value: TShapePenStyle);
    function IsColorStored: Boolean;
    function IsWidthStored: Boolean;
    function IsStyleStored: Boolean;
  protected
    procedure Changed;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    { See TCWSShapeBrush.SetDefaults. }
    procedure SetDefaults;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property Color: TColor read FColor write SetColor stored IsColorStored;
    property Width: Integer read FWidth write SetWidth stored IsWidthStored;
    property Style: TShapePenStyle read FStyle write SetStyle stored IsStyleStored;
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
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { Shared with other CWStudio graphic controls (e.g. TCWSAvatar) so every
      component that draws a rectangle / rounded rectangle / circle builds the
      exact same anti-aliased GDI+ outline instead of duplicating the geometry. }
    class function MakeGPColor(AColor: TColor): Cardinal;
    class function BuildShapePath(Shape: TShapeKind; X, Y, W, H, R: Single): TGPGraphicsPath;
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
  SetDefaults;
end;

procedure TCWSShapeBrush.SetDefaults;
begin
  FDefColor := FColor;
  FDefStyle := FStyle;
end;

function TCWSShapeBrush.IsColorStored: Boolean;
begin
  Result := FColor <> FDefColor;
end;

function TCWSShapeBrush.IsStyleStored: Boolean;
begin
  Result := FStyle <> FDefStyle;
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
  SetDefaults;
end;

procedure TCWSShapePen.SetDefaults;
begin
  FDefColor := FColor;
  FDefWidth := FWidth;
  FDefStyle := FStyle;
end;

function TCWSShapePen.IsColorStored: Boolean;
begin
  Result := FColor <> FDefColor;
end;

function TCWSShapePen.IsWidthStored: Boolean;
begin
  Result := FWidth <> FDefWidth;
end;

function TCWSShapePen.IsStyleStored: Boolean;
begin
  Result := FStyle <> FDefStyle;
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
var
  NewWidth: Integer;
begin
  { A negative pen width has no meaning and would make GDI+ fail silently. }
  if Value < 0 then
    NewWidth := 0
  else
    NewWidth := Value;

  if FWidth <> NewWidth then
  begin
    FWidth := NewWidth;
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

  { This control keeps the brush/pen values as created, but the call is made
    anyway so the pattern is obvious to anyone deriving from it: whatever the
    constructor leaves in Brush/Pen becomes the "not stored" baseline. }
  FBrush.SetDefaults;
  FPen.SetDefaults;

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

class function TCWSShape.MakeGPColor(AColor: TColor): Cardinal;
var
  C: TColor;
begin
  C := ColorToRGB(AColor);
  Result := Winapi.GDIPAPI.MakeColor(255, GetRValue(C), GetGValue(C), GetBValue(C));
end;

class function TCWSShape.BuildShapePath(Shape: TShapeKind; X, Y, W, H, R: Single): TGPGraphicsPath;
var
  D: Single;
begin
  Result := TGPGraphicsPath.Create;
  case Shape of
    TShapeKind.Circle:
      Result.AddEllipse(MakeRect(X, Y, W, H));

    TShapeKind.RoundRectangle:
      begin
        D := R * 2;
        if D > H then D := H;
        if D > W then D := W;
        if D < 0 then D := 0;
        if D = 0 then
          Result.AddRectangle(MakeRect(X, Y, W, H))
        else
        begin
          Result.AddArc(X,         Y,         D, D, 180, 90);
          Result.AddArc(X + W - D, Y,         D, D, 270, 90);
          Result.AddArc(X + W - D, Y + H - D, D, D,   0, 90);
          Result.AddArc(X,         Y + H - D, D, D,  90, 90);
          Result.CloseFigure;
        end;
      end;
  else
    Result.AddRectangle(MakeRect(X, Y, W, H));
  end;
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

    Path := BuildShapePath(FShape, X, Y, W, H, FCornerRadius);
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
