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
unit CWSAvatar;

interface

uses
  Winapi.Windows, Winapi.ActiveX, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  System.SysUtils, System.Classes, System.Types, System.Math,
  Vcl.Controls, Vcl.Graphics, Vcl.Imaging.pngimage, Vcl.Imaging.jpeg,
  Vcl.Imaging.GIFImg, CWSShape;

type
  { How the picture is resized to fit the (Shape/ImageMargin-derived) image
    area — the same idea as CSS object-fit / the classic VCL TImage
    Stretch+Proportional+Center combination:
      ifCover   — scaled and center-cropped so it fills the area completely,
                   nothing distorted, parts of the picture may be cut off
                   (the default).
      ifContain — scaled down/up, preserving aspect ratio, to fit entirely
                   inside the area; the Brush background shows as letterboxing.
      ifStretch — stretched to exactly fill the area on both axes, ignoring
                   the picture's own aspect ratio (may distort it).
      ifCenter  — drawn at its natural pixel size, centered; cropped only if
                   it is larger than the area. }
  TCWSImageFit = (ifCover, ifContain, ifStretch, ifCenter);

  { TCWSAvatar — a circular / rectangular / rounded-rectangle avatar.
    Shows either a picture (fitted per ImageFit, edges anti-aliased so they
    blend smoothly into whatever sits behind the control) or, when no picture
    is assigned, centered text (e.g. initials) in the given Font. }
  TCWSAvatar = class(TGraphicControl)
  private
    FBrush: TCWSShapeBrush;
    FPen: TCWSShapePen;
    FShape: TShapeKind;
    FCornerRadius: Integer;
    FPicture: TPicture;
    FImageMargin: Integer;
    FImageFit: TCWSImageFit;
    FCaption: string;
    FFont: TFont;
    procedure SetBrush(const Value: TCWSShapeBrush);
    procedure SetPen(const Value: TCWSShapePen);
    procedure SetShape(const Value: TShapeKind);
    procedure SetCornerRadius(const Value: Integer);
    procedure SetPicture(const Value: TPicture);
    procedure SetImageMargin(const Value: Integer);
    procedure SetImageFit(const Value: TCWSImageFit);
    procedure SetCaption(const Value: string);
    procedure SetFont(const Value: TFont);
    procedure StyleChanged(Sender: TObject);
    procedure PictureChanged(Sender: TObject);
    procedure FontChanged(Sender: TObject);
    function  InsideDistance(X, Y, W, H, R, PX, PY: Single): Single;
    procedure DrawImage(G: TGPGraphics; X, Y, W, H: Single);
    procedure DrawCaption(const R: TRect);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Shape: TShapeKind read FShape write SetShape default TShapeKind.Circle;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 12;

    property Brush: TCWSShapeBrush read FBrush write SetBrush;
    property Pen: TCWSShapePen read FPen write SetPen;

    { The image; how it is resized/cropped into its area is controlled by
      ImageFit. It never spills past the Shape/CornerRadius outline: within
      ImageMargin pixels of that outline its opacity fades out towards the
      Brush background, so the edge blends smoothly into it instead of
      showing a hard cut — see ImageMargin. }
    property Picture: TPicture read FPicture write SetPicture;
    { Width, in pixels, of the soft fade at the image's edge — the picture's
      opacity ramps from fully opaque down to fully transparent (letting the
      Brush background show through) over this many pixels measured inward
      from the Shape/CornerRadius outline, so the image blends smoothly into
      the background instead of being cut off there. A value of 0 still gets
      a minimal ~1px anti-aliased edge; raise it for a visible soft
      vignette-like blend. }
    property ImageMargin: Integer read FImageMargin write SetImageMargin default 0;
    { How the image is resized to fit its area — cover / contain / stretch /
      center. See TCWSImageFit. }
    property ImageFit: TCWSImageFit read FImageFit write SetImageFit default ifCover;

    { Shown centered (both axes) only while no Picture is assigned — typically
      initials such as 'JD'. }
    property Caption: string read FCaption write SetCaption;
    property Font: TFont read FFont write SetFont;

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
    property OnContextPopup;
  end;

implementation

{ TCWSAvatar }

constructor TCWSAvatar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FBrush := TCWSShapeBrush.Create;
  FBrush.OnChange := StyleChanged;
  FBrush.Color := $00E6E6E6;

  FPen := TCWSShapePen.Create;
  FPen.OnChange := StyleChanged;
  FPen.Style := TShapePenStyle.Clear;

  FShape := TShapeKind.Circle;
  FCornerRadius := 12;
  FImageMargin := 0;
  FImageFit := ifCover;

  FPicture := TPicture.Create;
  FPicture.OnChange := PictureChanged;

  FCaption := '';
  FFont := TFont.Create;
  FFont.Name := 'Segoe UI';
  FFont.Size := 14;
  FFont.Color := $00404040;
  FFont.OnChange := FontChanged;

  Width  := 64;
  Height := 64;
end;

destructor TCWSAvatar.Destroy;
begin
  FBrush.Free;
  FPen.Free;
  FPicture.Free;
  FFont.Free;
  inherited;
end;

procedure TCWSAvatar.SetBrush(const Value: TCWSShapeBrush);
begin
  FBrush.Assign(Value);
end;

procedure TCWSAvatar.SetPen(const Value: TCWSShapePen);
begin
  FPen.Assign(Value);
end;

procedure TCWSAvatar.SetShape(const Value: TShapeKind);
begin
  if FShape <> Value then
  begin
    FShape := Value;
    Invalidate;
  end;
end;

procedure TCWSAvatar.SetCornerRadius(const Value: Integer);
begin
  if FCornerRadius <> Value then
  begin
    FCornerRadius := Value;
    if FShape = TShapeKind.RoundRectangle then
      Invalidate;
  end;
end;

procedure TCWSAvatar.SetPicture(const Value: TPicture);
begin
  FPicture.Assign(Value);
end;

procedure TCWSAvatar.SetImageMargin(const Value: Integer);
begin
  if FImageMargin <> Value then
  begin
    FImageMargin := Value;
    Invalidate;
  end;
end;

procedure TCWSAvatar.SetImageFit(const Value: TCWSImageFit);
begin
  if FImageFit <> Value then
  begin
    FImageFit := Value;
    Invalidate;
  end;
end;

procedure TCWSAvatar.SetCaption(const Value: string);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    Invalidate;
  end;
end;

procedure TCWSAvatar.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TCWSAvatar.StyleChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TCWSAvatar.PictureChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TCWSAvatar.FontChanged(Sender: TObject);
begin
  Invalidate;
end;

{ Signed "how far inside the shape" distance, in pixels, of point (PX, PY)
  from the Shape/CornerRadius outline of the (X, Y, W, H) box — positive and
  growing inward, zero on the outline, negative outside it. Closed-form
  distance fields for the three shapes (the RoundRectangle formula also
  covers plain Rectangle, at R = 0); used to feather the image's edge — see
  DrawImage. }
function TCWSAvatar.InsideDistance(X, Y, W, H, R, PX, PY: Single): Single;
var
  cx, cy, halfW, halfH, rad, qx, qy, outsideDist, insideDist: Single;
begin
  cx := X + W / 2;
  cy := Y + H / 2;
  if FShape = TShapeKind.Circle then
    Result := Min(W, H) / 2 - Sqrt(Sqr(PX - cx) + Sqr(PY - cy))
  else
  begin
    halfW := W / 2;
    halfH := H / 2;
    if FShape = TShapeKind.RoundRectangle then
      rad := Min(R, Min(halfW, halfH))
    else
      rad := 0;
    qx := Abs(PX - cx) - (halfW - rad);
    qy := Abs(PY - cy) - (halfH - rad);
    outsideDist := Sqrt(Sqr(Max(qx, 0)) + Sqr(Max(qy, 0)));
    insideDist := Min(Max(qx, qy), 0);
    Result := rad - (outsideDist + insideDist);
  end;
end;

{ Draws FPicture into the (X, Y, W, H) image area, resized per FImageFit, by
  picking a source sub-rectangle (CropX/Y/W/H) and a destination rectangle
  (DstX/Y/W/H) — the same idea for all four modes, only the two rectangles
  differ:

    ifCover   — crop to the area's aspect ratio (full source otherwise),
                 destination = the whole area.
    ifStretch — full source, destination = the whole area (so it maps onto
                 it without preserving the source's aspect ratio).
    ifContain — full source, destination scaled down/up to fit inside the
                 area preserving aspect ratio, centered.
    ifCenter  — full source, destination = its own natural pixel size,
                 centered (may exceed the area).

  Rather than draw straight onto the control, the fit is first rendered into
  an offscreen (W, H) ARGB buffer, whose alpha channel is then multiplied,
  pixel by pixel, by InsideDistance(...)/ImageMargin clamped to [0, 1] — a
  soft ramp from fully opaque (ImageMargin px or more inside the shape) to
  fully transparent (on or outside its outline). That buffer is then drawn
  onto the real canvas, where it blends against the already-painted Brush
  background through ordinary alpha compositing. A GDI+ region clip (as used
  elsewhere in this unit) cannot do this: it is a hard, all-or-nothing mask,
  not a gradient. ImageMargin = 0 still gets a 1px ramp, for basic AA. }
procedure TCWSAvatar.DrawImage(G: TGPGraphics; X, Y, W, H: Single);
var
  MS: TMemoryStream;
  StreamAdapter: IStream;
  SrcImg, Buf: TGPBitmap;
  G2: TGPGraphics;
  BmpData: TBitmapData;
  SrcW, SrcH, TargetAspect, SrcAspect: Single;
  CropX, CropY, CropW, CropH: Single;
  Scale, DstW, DstH, DstX, DstY: Single;
  IW, IH, Row, Col: Integer;
  RowPtr: PByte;
  Feather, Factor: Single;
begin
  if (W <= 0) or (H <= 0) then Exit;

  MS := TMemoryStream.Create;
  try
    FPicture.Graphic.SaveToStream(MS);
    MS.Position := 0;
    StreamAdapter := TStreamAdapter.Create(MS, soReference) as IStream;
    SrcImg := TGPBitmap.Create(StreamAdapter);
    try
      SrcW := SrcImg.GetWidth;
      SrcH := SrcImg.GetHeight;
      if (SrcW <= 0) or (SrcH <= 0) then Exit;

      CropX := 0; CropY := 0; CropW := SrcW; CropH := SrcH;
      DstX := 0; DstY := 0; DstW := W; DstH := H;

      case FImageFit of
        ifCover:
          begin
            TargetAspect := W / H;
            SrcAspect := SrcW / SrcH;
            if SrcAspect > TargetAspect then
            begin
              CropH := SrcH;
              CropW := SrcH * TargetAspect;
              CropX := (SrcW - CropW) / 2;
            end
            else
            begin
              CropW := SrcW;
              CropH := SrcW / TargetAspect;
              CropY := (SrcH - CropH) / 2;
            end;
          end;

        { ifStretch needs no adjustment: full source onto the whole area. }
        ifStretch: ;

        ifContain:
          begin
            Scale := Min(W / SrcW, H / SrcH);
            DstW := SrcW * Scale;
            DstH := SrcH * Scale;
            DstX := (W - DstW) / 2;
            DstY := (H - DstH) / 2;
          end;

        ifCenter:
          begin
            DstW := SrcW;
            DstH := SrcH;
            DstX := (W - DstW) / 2;
            DstY := (H - DstH) / 2;
          end;
      end;

      IW := Max(1, Round(W));
      IH := Max(1, Round(H));

      Buf := TGPBitmap.Create(IW, IH, PixelFormat32bppARGB);
      try
        G2 := TGPGraphics.Create(Buf);
        try
          G2.SetSmoothingMode(SmoothingModeAntiAlias);
          G2.SetInterpolationMode(InterpolationModeHighQualityBicubic);
          { Overwrite Buf's pixels outright (RGB and alpha) instead of
            alpha-blending onto its initial fully-transparent black, which
            would otherwise darken the image's own semi-transparent pixels. }
          G2.SetCompositingMode(CompositingModeSourceCopy);
          G2.DrawImage(SrcImg, MakeRect(DstX, DstY, DstW, DstH),
            CropX, CropY, CropW, CropH, UnitPixel);
        finally
          G2.Free;
        end;

        Feather := Max(1, FImageMargin);

        Buf.LockBits(MakeRect(0, 0, IW, IH), ImageLockModeRead or ImageLockModeWrite,
          PixelFormat32bppARGB, BmpData);
        try
          for Row := 0 to IH - 1 do
          begin
            RowPtr := PByte(BmpData.Scan0) + Row * BmpData.Stride;
            for Col := 0 to IW - 1 do
            begin
              Factor := InsideDistance(X, Y, W, H, FCornerRadius,
                X + Col + 0.5, Y + Row + 0.5) / Feather;
              if Factor < 0 then Factor := 0
              else if Factor > 1 then Factor := 1;
              { PixelFormat32bppARGB byte order in memory is B, G, R, A. }
              RowPtr[Col * 4 + 3] := Round(RowPtr[Col * 4 + 3] * Factor);
            end;
          end;
        finally
          Buf.UnlockBits(BmpData);
        end;

        G.DrawImage(Buf, MakeRect(X, Y, W, H), 0, 0, IW, IH, UnitPixel);
      finally
        Buf.Free;
      end;
    finally
      SrcImg.Free;
    end;
  finally
    MS.Free;
  end;
end;

procedure TCWSAvatar.DrawCaption(const R: TRect);
var
  CalcR, DrawR: TRect;
  TextH, OffsetY: Integer;
begin
  if FCaption = '' then Exit;

  Canvas.Brush.Style := bsClear;
  Canvas.Font.Assign(FFont);

  { Vertically center a (possibly multi-line) caption: measure it first with
    DT_CALCRECT, then draw it offset into the middle of R. }
  CalcR := R;
  Winapi.Windows.DrawText(Canvas.Handle, PChar(FCaption), -1, CalcR,
    DT_CENTER or DT_WORDBREAK or DT_CALCRECT);
  TextH := CalcR.Bottom - CalcR.Top;
  OffsetY := ((R.Bottom - R.Top) - TextH) div 2;

  DrawR := Rect(R.Left, R.Top + OffsetY, R.Right, R.Top + OffsetY + TextH);
  Winapi.Windows.DrawText(Canvas.Handle, PChar(FCaption), -1, DrawR,
    DT_CENTER or DT_WORDBREAK);
end;

procedure TCWSAvatar.Paint;
var
  G: TGPGraphics;
  OuterPath: TGPGraphicsPath;
  GBrush: TGPSolidBrush;
  GPen: TGPPen;
  PW, X, Y, W, H: Single;
  HasBorder, HasImage: Boolean;
  R: TRect;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  HasBorder := (FPen.Style = TShapePenStyle.Solid) and (FPen.Width > 0);
  if HasBorder then PW := FPen.Width else PW := 0;

  { Inset by half the pen width so the stroke stays fully inside the bounds —
    the same convention TCWSShape uses. }
  X := PW / 2;
  Y := PW / 2;
  W := Width - PW;
  H := Height - PW;
  if W < 0 then W := 0;
  if H < 0 then H := 0;

  HasImage := Assigned(FPicture.Graphic) and not FPicture.Graphic.Empty;

  G := TGPGraphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    G.SetPixelOffsetMode(PixelOffsetModeHalf);
    G.SetInterpolationMode(InterpolationModeHighQualityBicubic);

    OuterPath := TCWSShape.BuildShapePath(FShape, X, Y, W, H, FCornerRadius);
    try
      { Background — always painted first: it is what the caption sits on,
        and (when ImageMargin > 0) what the image's edge fades into. }
      if (FBrush.Style = TShapeBrushStyle.Solid) and (FBrush.Color <> clNone) then
      begin
        GBrush := TGPSolidBrush.Create(TCWSShape.MakeGPColor(FBrush.Color));
        try
          G.FillPath(GBrush, OuterPath);
        finally
          GBrush.Free;
        end;
      end;

      if HasImage then
        DrawImage(G, X, Y, W, H);

      if HasBorder then
      begin
        GPen := TGPPen.Create(TCWSShape.MakeGPColor(FPen.Color), PW);
        try
          G.DrawPath(GPen, OuterPath);
        finally
          GPen.Free;
        end;
      end;
    finally
      OuterPath.Free;
    end;
  finally
    G.Free;
  end;

  if not HasImage then
  begin
    R := Rect(Round(X), Round(Y), Round(X + W), Round(Y + H));
    DrawCaption(R);
  end;
end;

end.
