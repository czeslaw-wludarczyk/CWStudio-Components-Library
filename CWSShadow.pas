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
unit CWSShadow;

{ TCWSShadow — a soft, alpha-blended drop shadow for ANY VCL control.

  Drop it on a form and point Control at the control that should cast the
  shadow (a CWStudio card or button, TPanel, TEdit, TImage, TShape, …). The
  shadow puts itself on the same parent, right under that control, and follows
  its position, size and visibility on its own.

  It is a TGraphicControl, so it paints straight onto the parent's canvas and is
  AlphaBlend-ed over whatever the parent drew underneath: background, images,
  other graphic controls. The CWStudio controls with rounded corners paint the
  parent's real background under those corners, so the shadow shows there too.

    Mode = smBox    shadow of the control's rectangle (rounded by CornerRadius),
                    like CSS box-shadow — analytic, cheap, perfectly smooth;
    Mode = smShape  shadow of the control's actual pixels (alpha taken from
                    what it paints: text, shapes, a transparent image), like CSS
                    drop-shadow() or the FMX TShadowEffect.

  Size works like the CSS spread, Softness is the blur (Gaussian in smShape).

  VCL limitation: graphic controls always lie below windowed ones, so a shadow
  never covers a neighbouring TWinControl (an edit, a panel) — only the parent's
  own surface and graphic controls. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types,
  System.Math, System.Generics.Collections, Vcl.Graphics, Vcl.Controls, Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
  { smBox   — shadow of the control's rounded rectangle (CSS box-shadow);
    smShape — shadow of the control's painted pixels (CSS drop-shadow). }
  TCWSShadowMode = (smBox, smShape);

  TCWSShadow = class(TGraphicControl)
  private
    FControl: TControl;
    FControlWndProc: TWndMethod;
    FDirection: Integer;
    FDistance: Integer;
    FSize: Integer;
    FSoftness: Integer;
    FOpacity: Byte;
    FCornerRadius: Integer;
    FMode: TCWSShadowMode;
    FIgnoreChildLabels: Boolean;
    FLayer: TBitmap;
    FLayerValid: Boolean;
    FLayerShape: TRectF;
    { FLayer is drawn nine-sliced: corner slices 1:1, the middle band stretched
      to the current size (see DrawLayer) }
    FNineSlice: Boolean;
    FSliceL, FSliceT, FSliceR, FSliceB: Integer;
    { FLayer expanded to the current size (row copies, no resampling) — what is
      actually blended when FNineSlice }
    FExpanded: TBitmap;
    FExpandedValid: Boolean;
    { smShape: the target is being resized — the old layer is shown stretched
      until the size settles, then rebuilt once }
    FResizeTimer: TTimer;
    { the last captured smShape source mask (control-sized) }
    FSourceMask: TBytes;
    FSourceWidth: Integer;
    FSourceHeight: Integer;
    FPainting: Boolean;
    FUpdatingPlacement: Boolean;
    { opaque TLabel in smShape: the label area composed as label background +
      shadow + text, painted over the label (see UsesLabelOverlay) }
    FOverlay: TBitmap;
    FOverlayValid: Boolean;
    { smShape + windowed target: re-checks the shape after the target
      invalidates itself (see ScheduleShapeCheck) }
    FShapeCheckTimer: TTimer;
    FShapeCheckWnd: HWND;
    FShapeCheckPosted: Boolean;
    FLastShapeCheck: Cardinal;
    procedure ResizeTimer(Sender: TObject);
    procedure DrawLayer(DC: HDC; const AClip: TRect);
    procedure ScheduleShapeCheck;
    procedure ShapeCheckTimer(Sender: TObject);
    procedure ShapeCheckWndProc(var Message: TMessage);
    procedure RunShapeCheck;
    function UsesLabelOverlay: Boolean;
    procedure BuildLabelOverlay;
    procedure SetControl(const Value: TControl);
    procedure SetDirection(const Value: Integer);
    procedure SetDistance(const Value: Integer);
    procedure SetSize(const Value: Integer);
    procedure SetSoftness(const Value: Integer);
    procedure SetOpacity(const Value: Byte);
    procedure SetCornerRadius(const Value: Integer);
    procedure SetMode(const Value: TCWSShadowMode);
    procedure SetIgnoreChildLabels(const Value: Boolean);
    procedure HookControl;
    procedure UnhookControl;
    procedure ControlWndProc(var Message: TMessage);
    function GetShadowShape: TRectF;
    function GetShapeOffset: TPoint;
    function GetShapePad: Integer;
    procedure ShadowChanged;
    procedure UpdatePlacementCore;
    procedure UpdateLayer;
    procedure UpdateBoxLayer;
    procedure UpdateShapeLayer;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMHitTest(var Message: TCMHitTest); message CM_HITTEST;
  protected
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
    { Repaints the windowed controls on the same parent that overlap ARect.
      Controls that paint the parent's background under their rounded corners
      show the shadow there, and the parent (WS_CLIPCHILDREN) does not refresh
      their windows by itself. }
    procedure InvalidateOverlappingControls(const ARect: TRect);
    procedure InvalidateOverlappingControlsRgn(ARgn: HRGN);
    procedure MoveFollowingTarget(const ANewBounds: TRect);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Invalidate; override;
    { Matches parent, position and z-order to the target control. Called
      automatically; call it by hand only after unusual changes. }
    procedure UpdatePlacement;
    { Puts the shadow right under the target control in the z-order. }
    procedure UpdateZOrder;
  published
    { The control that casts the shadow. }
    property Control: TControl read FControl write SetControl;
    { Direction in degrees, clockwise: 0 = right, 90 = down, 180 = left, 270 = up. }
    property Direction: Integer read FDirection write SetDirection default 45;
    { Offset of the shadow in pixels, along Direction. }
    property Distance: Integer read FDistance write SetDistance default 4;
    { Spread: how many pixels the shadow is larger than the control on each side. }
    property Size: Integer read FSize write SetSize default 2;
    { Width of the fade-out in pixels (0 = hard edge). }
    property Softness: Integer read FSoftness write SetSoftness default 16;
    { Opacity 0..255 at the darkest point. }
    property Opacity: Byte read FOpacity write SetOpacity default 110;
    { smBox: corner radius of the shadow shape; >= half the side gives a pill/circle. }
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 0;
    { Source of the shadow shape — see TCWSShadowMode. }
    property Mode: TCWSShadowMode read FMode write SetMode default smShape;
    { smShape: labels (TLabel) inside the control cast no shadow — e.g. a switch
      or a check box shadows just its indicator, not its caption. }
    property IgnoreChildLabels: Boolean read FIgnoreChildLabels write SetIgnoreChildLabels default True;
    property Color default clBlack;
    property Visible;
  end;

implementation

type
  TWinControlAccess = class(TWinControl);

{ ===================== Shadow geometry (smBox) ============================== }

{ Signed distance from (PX, PY) to a rounded rectangle centred at (CX, CY) with
  half extents HW, HH and corner radius R; negative inside. }
function RoundRectDistance(PX, PY, CX, CY, HW, HH, R: Single): Single;
var
  QX, QY: Single;
begin
  R := Min(R, Min(HW, HH));
  QX := Abs(PX - CX) - (HW - R);
  QY := Abs(PY - CY) - (HH - R);
  Result := Sqrt(Sqr(Max(QX, 0)) + Sqr(Max(QY, 0))) + Min(Max(QX, QY), 0) - R;
end;

{ Coverage of a pixel by a 1 px edge — antialiasing. }
function EdgeCoverage(Distance: Single): Single; inline;
begin
  Result := EnsureRange(0.5 - Distance, 0, 1);
end;

{ 1 deep inside, 0 outside, a smooth fade of width Softness centred on the edge. }
function ShadowFalloff(Distance, Softness: Single): Single;
var
  T: Single;
begin
  if Softness < 1 then
    Exit(EdgeCoverage(Distance));
  T := EnsureRange((Distance + Softness / 2) / Softness, 0, 1);
  { 1 - smootherstep: a softer tail than a linear ramp }
  Result := 1 - T * T * T * (T * (T * 6 - 15) + 10);
end;

function ShadowOffset(Direction, Distance: Integer): TPointF;
var
  Angle: Single;
begin
  Angle := DegToRad(Direction);
  Result := TPointF.Create(Distance * Cos(Angle), Distance * Sin(Angle));
end;

{ Renders the box shadow into ALayer (pf32bit, premultiplied alpha). AShape is
  in layer pixels. }
procedure RenderBoxLayer(ALayer: TBitmap; const AShape: TRectF;
  ARadius, ASoftness: Single; AColor: TColor; AOpacity: Byte);
var
  X, Y: Integer;
  CX, CY, HW, HH, Alpha, Opacity: Single;
  RGB: TColorRef;
  Line: PRGBQuad;
begin
  CX := (AShape.Left + AShape.Right) / 2;
  CY := (AShape.Top + AShape.Bottom) / 2;
  HW := AShape.Width / 2;
  HH := AShape.Height / 2;
  RGB := ColorToRGB(AColor);
  Opacity := AOpacity / 255;
  for Y := 0 to ALayer.Height - 1 do
  begin
    Line := ALayer.ScanLine[Y];
    for X := 0 to ALayer.Width - 1 do
    begin
      Alpha := Opacity * ShadowFalloff(
        RoundRectDistance(X + 0.5, Y + 0.5, CX, CY, HW, HH, ARadius), ASoftness);
      Line.rgbRed := Round(GetRValue(RGB) * Alpha);
      Line.rgbGreen := Round(GetGValue(RGB) * Alpha);
      Line.rgbBlue := Round(GetBValue(RGB) * Alpha);
      Line.rgbReserved := Round(255 * Alpha);
      Inc(Line);
    end;
  end;
end;

{ AlphaBlends only the ASource part of the layer (layer coordinates) — usually
  the invalid area, a thin strip while a control is being dragged. }
procedure BlendLayer(DestDC: HDC; ALayer: TBitmap; ASource: TRect);
var
  Blend: TBlendFunction;
begin
  ASource.Intersect(Rect(0, 0, ALayer.Width, ALayer.Height));
  if ASource.IsEmpty then
    Exit;
  Blend.BlendOp := AC_SRC_OVER;
  Blend.BlendFlags := 0;
  Blend.SourceConstantAlpha := 255;
  Blend.AlphaFormat := AC_SRC_ALPHA;
  Winapi.Windows.AlphaBlend(DestDC, ASource.Left, ASource.Top,
    ASource.Width, ASource.Height, ALayer.Canvas.Handle,
    ASource.Left, ASource.Top, ASource.Width, ASource.Height, Blend);
end;

{ Expands ALayer to ADestW x ADestH into ADest by nine slices: the corner
  slices (AL/AT/AR/AB wide) are copied 1:1, and the single row/column right
  after the left/top slice is repeated over the middle (the shadow is constant
  along a straight edge). Plain row copies — no resampling: a stretched
  AlphaBlend was both the slow part and, on a window DC, brightened the
  stretched pixels. Works for growing and shrinking alike, as long as
  AL + AR < ADestW and AL + 1 + AR <= ALayer.Width (same vertically). }
procedure ExpandNineSlice(ALayer, ADest: TBitmap; AL, AT, AR, AB, ADestW, ADestH: Integer);
var
  X, Y, SrcY, MidW: Integer;
  Src, Dst, MidRow: PRGBQuad;
  Fill: TRGBQuad;
begin
  ADest.PixelFormat := pf32bit;
  ADest.SetSize(ADestW, ADestH);
  MidW := ADestW - AL - AR;
  MidRow := nil;
  for Y := 0 to ADestH - 1 do
  begin
    if Y < AT then
      SrcY := Y
    else if Y >= ADestH - AB then
      SrcY := Y - (ADestH - ALayer.Height)
    else
      SrcY := AT;
    Dst := ADest.ScanLine[Y];
    { every middle row is the same — copy the first one built }
    if (SrcY = AT) and (MidRow <> nil) then
    begin
      Move(MidRow^, Dst^, ADestW * SizeOf(TRGBQuad));
      Continue;
    end;
    Src := ALayer.ScanLine[SrcY];
    Move(Src^, Dst^, AL * SizeOf(TRGBQuad));
    Fill := PRGBQuad(PByte(Src) + AL * SizeOf(TRGBQuad))^;
    Inc(Dst, AL);
    for X := 0 to MidW - 1 do
    begin
      Dst^ := Fill;
      Inc(Dst);
    end;
    Move(PRGBQuad(PByte(Src) + (ALayer.Width - AR) * SizeOf(TRGBQuad))^, Dst^,
      AR * SizeOf(TRGBQuad));
    if SrcY = AT then
      MidRow := ADest.ScanLine[Y];
  end;
end;

{ ===================== Alpha mask (smShape) ================================= }

type
  { 8-bit coverage mask (0 = transparent, 255 = opaque). }
  TAlphaMask = record
    Width: Integer;
    Height: Integer;
    Data: TBytes;
    procedure SetSize(AWidth, AHeight: Integer);
    function IsEmpty: Boolean;
    function Padded(APad: Integer): TAlphaMask;
    procedure Dilate(ARadius: Integer);
    procedure GaussianBlur(ASigma: Single);
    procedure ToLayer(ALayer: TBitmap; AColor: TColor; AOpacity: Byte);
  end;

  { For the duration of a capture, answers the parent's background messages
    with a flat colour. Controls with rounded corners or ParentBackground (themed
    TButton / TPanel, the CWStudio GDI+ controls) paint the parent's background
    under their corners through WM_ERASEBKGND + WM_PRINTCLIENT (also via
    DrawThemeParentBackground). Without this the corners would come out opaque,
    and the parent would paint its graphic controls along the way — the shadow
    itself included (recursion). }
  TSolidParentBackground = class
  private
    FParent: TWinControl;
    FOldWndProc: TWndMethod;
    FColor: TColorRef;
    procedure WndProc(var Message: TMessage);
  public
    constructor Create(AParent: TWinControl; AColor: TColor);
    destructor Destroy; override;
  end;

  { For the duration of a capture, keeps a label from painting. A control paints
    its graphic children through Perform(WM_PAINT) (TWinControl.PaintControls),
    so taking over the label's WindowProc for a moment is enough — no change of
    Visible or Font, which would re-run the layout. }
  TLabelPaintBlocker = class
  private
    FLabel: TControl;
    FOldWndProc: TWndMethod;
    procedure WndProc(var Message: TMessage);
  public
    constructor Create(ALabel: TControl);
    destructor Destroy; override;
  end;

constructor TSolidParentBackground.Create(AParent: TWinControl; AColor: TColor);
begin
  inherited Create;
  FParent := AParent;
  FColor := ColorToRGB(AColor);
  FOldWndProc := FParent.WindowProc;
  FParent.WindowProc := WndProc;
end;

destructor TSolidParentBackground.Destroy;
begin
  FParent.WindowProc := FOldWndProc;
  inherited Destroy;
end;

procedure TSolidParentBackground.WndProc(var Message: TMessage);
var
  DC: HDC;
  ClipBox: TRect;
  Brush: HBRUSH;
begin
  case Message.Msg of
    WM_ERASEBKGND, WM_PRINTCLIENT:
      begin
        DC := HDC(Message.WParam);
        if GetClipBox(DC, ClipBox) <> ERROR then
        begin
          Brush := CreateSolidBrush(FColor);
          FillRect(DC, ClipBox, Brush);
          DeleteObject(Brush);
        end;
        Message.Result := 1;
      end;
  else
    FOldWndProc(Message);
  end;
end;

constructor TLabelPaintBlocker.Create(ALabel: TControl);
begin
  inherited Create;
  FLabel := ALabel;
  FOldWndProc := FLabel.WindowProc;
  FLabel.WindowProc := WndProc;
end;

destructor TLabelPaintBlocker.Destroy;
begin
  FLabel.WindowProc := FOldWndProc;
  inherited Destroy;
end;

procedure TLabelPaintBlocker.WndProc(var Message: TMessage);
begin
  if Message.Msg <> WM_PAINT then
    FOldWndProc(Message);
end;

type
  { For the duration of a capture, clips a windowed control's painting to its
    window region. PaintTo paints every windowed control over its whole
    rectangle and ignores SetWindowRgn, so an inner control that its host clips
    to rounded corners (the grid inside TCWSStringGrid / TCWSDBGrid, the list
    inside TCWSListBox) came out with square corners in the mask — and the
    shadow with dark square patches, the larger the radius the larger. }
  TRegionClipper = class
  private
    FControl: TWinControl;
    FOldWndProc: TWndMethod;
    procedure WndProc(var Message: TMessage);
  public
    constructor Create(AControl: TWinControl);
    destructor Destroy; override;
  end;

constructor TRegionClipper.Create(AControl: TWinControl);
begin
  inherited Create;
  FControl := AControl;
  FOldWndProc := FControl.WindowProc;
  FControl.WindowProc := WndProc;
end;

destructor TRegionClipper.Destroy;
begin
  FControl.WindowProc := FOldWndProc;
  inherited Destroy;
end;

procedure TRegionClipper.WndProc(var Message: TMessage);
var
  DC: HDC;
  Rgn: HRGN;
  SaveIdx: Integer;
  WinRect: TRect;
  ClientOrg, Origin: TPoint;
begin
  if ((Message.Msg = WM_ERASEBKGND) or (Message.Msg = WM_PAINT) or
    (Message.Msg = WM_PRINTCLIENT)) and (Message.WParam <> 0) and
    FControl.HandleAllocated then
  begin
    DC := HDC(Message.WParam);
    Rgn := CreateRectRgn(0, 0, 0, 0);
    try
      if GetWindowRgn(FControl.Handle, Rgn) in [SIMPLEREGION, COMPLEXREGION] then
      begin
        { The region is relative to the window rectangle, the DC origin is the
          client origin (PaintTo moves past a client edge) — find where the
          window's top-left lies in device units. }
        GetWindowRect(FControl.Handle, WinRect);
        ClientOrg := Point(0, 0);
        Winapi.Windows.ClientToScreen(FControl.Handle, ClientOrg);
        Origin := Point(WinRect.Left - ClientOrg.X, WinRect.Top - ClientOrg.Y);
        LPtoDP(DC, Origin, 1);
        OffsetRgn(Rgn, Origin.X, Origin.Y);
        SaveIdx := SaveDC(DC);
        try
          ExtSelectClipRgn(DC, Rgn, RGN_AND);
          FOldWndProc(Message);
        finally
          RestoreDC(DC, SaveIdx);
        end;
        Exit;
      end;
    finally
      DeleteObject(Rgn);
    end;
  end;
  FOldWndProc(Message);
end;

{ Hooks AControl and every windowed control inside it that carries a window
  region. }
procedure ClipToWindowRegions(AControl: TWinControl; AClippers: TObjectList<TRegionClipper>);
var
  I: Integer;
  Rgn: HRGN;
begin
  if not AControl.HandleAllocated then
    Exit;
  Rgn := CreateRectRgn(0, 0, 0, 0);
  try
    if GetWindowRgn(AControl.Handle, Rgn) in [SIMPLEREGION, COMPLEXREGION] then
      AClippers.Add(TRegionClipper.Create(AControl));
  finally
    DeleteObject(Rgn);
  end;
  for I := 0 to AControl.ControlCount - 1 do
    if AControl.Controls[I] is TWinControl then
      ClipToWindowRegions(TWinControl(AControl.Controls[I]), AClippers);
end;

procedure BlockChildLabels(AParent: TWinControl; ABlockers: TObjectList<TLabelPaintBlocker>);
var
  I: Integer;
  Child: TControl;
begin
  for I := 0 to AParent.ControlCount - 1 do
  begin
    Child := AParent.Controls[I];
    if Child is TCustomLabel then
      ABlockers.Add(TLabelPaintBlocker.Create(Child))
    else if Child is TWinControl then
      BlockChildLabels(TWinControl(Child), ABlockers);
  end;
end;

procedure RenderControl(AControl: TControl; ABitmap: TBitmap; ABackground: TColor;
  AIgnoreChildLabels: Boolean);
var
  ParentOverride: TSolidParentBackground;
  LabelBlockers: TObjectList<TLabelPaintBlocker>;
  Clippers: TObjectList<TRegionClipper>;
begin
  ABitmap.Canvas.Brush.Color := ABackground;
  ABitmap.Canvas.FillRect(Rect(0, 0, ABitmap.Width, ABitmap.Height));
  if AControl is TWinControl then
  begin
    if TWinControl(AControl).HandleAllocated then
    begin
      ParentOverride := nil;
      LabelBlockers := TObjectList<TLabelPaintBlocker>.Create;
      Clippers := TObjectList<TRegionClipper>.Create;
      try
        if AControl.Parent <> nil then
          ParentOverride := TSolidParentBackground.Create(AControl.Parent, ABackground);
        if AIgnoreChildLabels then
          BlockChildLabels(TWinControl(AControl), LabelBlockers);
        ClipToWindowRegions(TWinControl(AControl), Clippers);
        TWinControl(AControl).PaintTo(ABitmap.Canvas.Handle, 0, 0);
      finally
        Clippers.Free;
        LabelBlockers.Free;
        ParentOverride.Free;
      end;
    end
    else
    begin
      { no window yet — take the full rectangle }
      ABitmap.Canvas.Brush.Color := clBlack;
      ABitmap.Canvas.FillRect(Rect(0, 0, ABitmap.Width, ABitmap.Height));
    end;
  end
  else
    { TGraphicControl.WMPaint paints on the DC passed in wParam }
    AControl.Perform(WM_PAINT, WPARAM(ABitmap.Canvas.Handle), 0);
end;

type
  TLabelAccess = class(TCustomLabel);

{ An opaque label (Transparent = False, the TLabel default) fills its whole
  rectangle with Color before drawing the text, so rendering it on black and on
  white sees nothing but an opaque box — the shadow came out as a rectangle
  instead of following the letters. Its background is a known flat colour,
  though, and so is its text, so the coverage of each pixel is where it lies on
  the segment between the two: a = (P - Bg)·(Text - Bg) / |Text - Bg|². That is
  exact for antialiased text and close for ClearType, and it needs no change of
  Transparent / Color on the label, which would only re-invalidate it. }
function CaptureOpaqueLabelMask(ALabel: TCustomLabel): TAlphaMask;
var
  Bmp: TBitmap;
  X, Y, BR, BG, BB, DR, DG, DB, Dot, Len2: Integer;
  Back, Text: TColorRef;
  P: PRGBQuad;
  Dest: PByte;
begin
  Result.SetSize(ALabel.Width, ALabel.Height);
  if Result.IsEmpty then
    Exit;
  Back := ColorToRGB(TLabelAccess(ALabel).Color);
  Text := ColorToRGB(TLabelAccess(ALabel).Font.Color);
  BR := GetRValue(Back); BG := GetGValue(Back); BB := GetBValue(Back);
  DR := GetRValue(Text) - BR; DG := GetGValue(Text) - BG; DB := GetBValue(Text) - BB;
  Len2 := DR * DR + DG * DG + DB * DB;
  if Len2 = 0 then
    Exit;                          { text in the background colour — nothing to shade }
  Bmp := TBitmap.Create;
  try
    Bmp.PixelFormat := pf32bit;
    Bmp.SetSize(Result.Width, Result.Height);
    ALabel.Perform(WM_PAINT, WPARAM(Bmp.Canvas.Handle), 0);
    GdiFlush;
    Dest := @Result.Data[0];
    for Y := 0 to Result.Height - 1 do
    begin
      P := Bmp.ScanLine[Y];
      for X := 0 to Result.Width - 1 do
      begin
        Dot := (P.rgbRed - BR) * DR + (P.rgbGreen - BG) * DG + (P.rgbBlue - BB) * DB;
        Dest^ := EnsureRange(MulDiv(Dot, 255, Len2), 0, 255);
        Inc(P);
        Inc(Dest);
      end;
    end;
  finally
    Bmp.Free;
  end;
end;

{ GDI has no alpha channel, so the control is rendered twice — on black and on
  white. For a pixel of colour C and coverage a:
    on black: B = a*C,   on white: W = a*C + (1-a)*255   =>   a = 1 - (W-B)/255
  which holds for antialiasing and ClearType text as well. }
function CaptureControlMask(AControl: TControl; AIgnoreChildLabels: Boolean): TAlphaMask;
var
  OnBlack, OnWhite: TBitmap;
  X, Y, Diff: Integer;
  B, W: PRGBQuad;
  Dest: PByte;
begin
  if (AControl is TCustomLabel) and not TLabelAccess(AControl).Transparent then
    Exit(CaptureOpaqueLabelMask(TCustomLabel(AControl)));
  Result.SetSize(AControl.Width, AControl.Height);
  if Result.IsEmpty then
    Exit;
  OnBlack := TBitmap.Create;
  OnWhite := TBitmap.Create;
  try
    OnBlack.PixelFormat := pf32bit;
    OnBlack.SetSize(Result.Width, Result.Height);
    OnWhite.PixelFormat := pf32bit;
    OnWhite.SetSize(Result.Width, Result.Height);
    RenderControl(AControl, OnBlack, clBlack, AIgnoreChildLabels);
    RenderControl(AControl, OnWhite, clWhite, AIgnoreChildLabels);
    Dest := @Result.Data[0];
    for Y := 0 to Result.Height - 1 do
    begin
      B := OnBlack.ScanLine[Y];
      W := OnWhite.ScanLine[Y];
      for X := 0 to Result.Width - 1 do
      begin
        Diff := (W.rgbRed - B.rgbRed) + (W.rgbGreen - B.rgbGreen) + (W.rgbBlue - B.rgbBlue);
        Dest^ := EnsureRange(255 - Diff div 3, 0, 255);
        Inc(B);
        Inc(W);
        Inc(Dest);
      end;
    end;
  finally
    OnWhite.Free;
    OnBlack.Free;
  end;
end;

{ Box blur with zeros outside the mask. AStride = 1 for rows, Width for columns. }
procedure BoxBlurPass(const Src: TBytes; var Dst: TBytes;
  ALineCount, ALineLength, ALineStep, AStride, ARadius: Integer);
var
  Line, I, Start, Sum, Size: Integer;
begin
  Size := 2 * ARadius + 1;
  for Line := 0 to ALineCount - 1 do
  begin
    Start := Line * ALineStep;
    Sum := 0;
    for I := 0 to Min(ARadius, ALineLength - 1) do
      Inc(Sum, Src[Start + I * AStride]);
    for I := 0 to ALineLength - 1 do
    begin
      Dst[Start + I * AStride] := (Sum + Size div 2) div Size;
      if I + ARadius + 1 < ALineLength then
        Inc(Sum, Src[Start + (I + ARadius + 1) * AStride]);
      if I - ARadius >= 0 then
        Dec(Sum, Src[Start + (I - ARadius) * AStride]);
    end;
  end;
end;

{ Horizontal max over the pixel and its left/right neighbour — grows every row
  by one pixel on each side. }
procedure WidenRowsByOne(const Src: TBytes; var Dst: TBytes; AWidth, AHeight: Integer);
var
  X, Y, Start: Integer;
  Value: Byte;
begin
  for Y := 0 to AHeight - 1 do
  begin
    Start := Y * AWidth;
    for X := 0 to AWidth - 1 do
    begin
      Value := Src[Start + X];
      if (X > 0) and (Src[Start + X - 1] > Value) then
        Value := Src[Start + X - 1];
      if (X < AWidth - 1) and (Src[Start + X + 1] > Value) then
        Value := Src[Start + X + 1];
      Dst[Start + X] := Value;
    end;
  end;
end;

procedure TAlphaMask.SetSize(AWidth, AHeight: Integer);
begin
  Width := Max(0, AWidth);
  Height := Max(0, AHeight);
  Data := nil;
  SetLength(Data, Width * Height);
end;

function TAlphaMask.IsEmpty: Boolean;
begin
  Result := (Width = 0) or (Height = 0);
end;

function TAlphaMask.Padded(APad: Integer): TAlphaMask;
var
  Y: Integer;
begin
  Result.SetSize(Width + 2 * APad, Height + 2 * APad);
  if IsEmpty then
    Exit;
  for Y := 0 to Height - 1 do
    Move(Data[Y * Width], Result.Data[(Y + APad) * Result.Width + APad], Width);
end;

{ Grows the shape by ARadius pixels — the CSS spread. The structuring element
  is a disc, not a square: a square (separable row + column max) grows the
  shape by ARadius·√2 along the diagonals and only shifts a rounded corner
  outwards, so the shadow kept the control's radius instead of radius + spread
  and, from a spread of about a third of the radius up, filled the square
  corner behind the rounded one.
  The disc is split into rows: the row at vertical offset DY has the half-width
  Round(√(R² - DY²)). Rows[K] = the mask widened horizontally by K pixels is
  built incrementally (one pixel per step), and every DY whose half-width is K
  takes the max of Rows[K] shifted by DY — O(pixels · R), three buffers. }
procedure TAlphaMask.Dilate(ARadius: Integer);
var
  Cur, Prev, Tmp, Res: TBytes;
  HalfWidth: array of Integer;
  K, DY, Y, SY, X, Dst, Src: Integer;
begin
  if (ARadius <= 0) or IsEmpty then
    Exit;
  SetLength(HalfWidth, ARadius + 1);
  for DY := 0 to ARadius do
    HalfWidth[DY] := Round(Sqrt(ARadius * ARadius - DY * DY));
  SetLength(Res, Length(Data));      { zero-filled }
  SetLength(Prev, Length(Data));
  Cur := Copy(Data);
  for K := 0 to ARadius do
  begin
    if K > 0 then
    begin
      { widen by one more pixel, then swap the two buffers }
      WidenRowsByOne(Cur, Prev, Width, Height);
      Tmp := Cur;
      Cur := Prev;
      Prev := Tmp;
    end;
    for DY := -ARadius to ARadius do
    begin
      if HalfWidth[Abs(DY)] <> K then
        Continue;
      for Y := 0 to Height - 1 do
      begin
        SY := Y + DY;
        if (SY < 0) or (SY >= Height) then
          Continue;
        Dst := Y * Width;
        Src := SY * Width;
        for X := 0 to Width - 1 do
          if Cur[Src + X] > Res[Dst + X] then
            Res[Dst + X] := Cur[Src + X];
      end;
    end;
  end;
  Data := Res;
end;

{ Gaussian blur of deviation ASigma, approximated by three box blurs. }
procedure TAlphaMask.GaussianBlur(ASigma: Single);
const
  Passes = 3;
var
  Temp: TBytes;
  IdealWidth: Single;
  Lower, Upper, LowerCount, Pass, Radius: Integer;
begin
  if (ASigma < 0.5) or IsEmpty then
    Exit;
  IdealWidth := Sqrt(12 * ASigma * ASigma / Passes + 1);
  Lower := Floor(IdealWidth);
  if not Odd(Lower) then
    Dec(Lower);
  Upper := Lower + 2;
  LowerCount := Round((12 * ASigma * ASigma - Passes * Lower * Lower - 4 * Passes * Lower -
    3 * Passes) / (-4 * Lower - 4));
  SetLength(Temp, Length(Data));
  for Pass := 0 to Passes - 1 do
  begin
    if Pass < LowerCount then
      Radius := (Lower - 1) div 2
    else
      Radius := (Upper - 1) div 2;
    BoxBlurPass(Data, Temp, Height, Width, Width, 1, Radius);
    BoxBlurPass(Temp, Data, Width, Height, 1, Width, Radius);
  end;
end;

{ Writes the mask to ALayer (pf32bit, premultiplied alpha) in AColor. }
procedure TAlphaMask.ToLayer(ALayer: TBitmap; AColor: TColor; AOpacity: Byte);
var
  X, Y, Alpha: Integer;
  RGB: TColorRef;
  Src: PByte;
  Line: PRGBQuad;
begin
  ALayer.PixelFormat := pf32bit;
  ALayer.SetSize(Width, Height);
  if IsEmpty then
    Exit;
  RGB := ColorToRGB(AColor);
  Src := @Data[0];
  for Y := 0 to Height - 1 do
  begin
    Line := ALayer.ScanLine[Y];
    for X := 0 to Width - 1 do
    begin
      Alpha := (Src^ * AOpacity + 127) div 255;
      Line.rgbRed := (GetRValue(RGB) * Alpha + 127) div 255;
      Line.rgbGreen := (GetGValue(RGB) * Alpha + 127) div 255;
      Line.rgbBlue := (GetBValue(RGB) * Alpha + 127) div 255;
      Line.rgbReserved := Alpha;
      Inc(Src);
      Inc(Line);
    end;
  end;
end;

{ ===================== TCWSShadow ========================================== }

constructor TCWSShadow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [];
  FDirection := 45;
  FDistance := 4;
  FSize := 2;
  FSoftness := 16;
  FOpacity := 110;
  FMode := smShape;   { must match the "default smShape" of the Mode property }
  FIgnoreChildLabels := True;
  Color := clBlack;
  Width := 60;
  Height := 60;
  FLayer := TBitmap.Create;
  FLayer.PixelFormat := pf32bit;
  FOverlay := TBitmap.Create;
  FOverlay.PixelFormat := pf32bit;
end;

destructor TCWSShadow.Destroy;
begin
  UnhookControl;
  if FShapeCheckWnd <> 0 then
    DeallocateHWnd(FShapeCheckWnd);
  FOverlay.Free;
  FExpanded.Free;
  FLayer.Free;
  inherited Destroy;
end;

{ An opaque label (Transparent = False) paints its whole rectangle with Color, so
  a shadow lying UNDER it would be covered wherever it falls inside the label —
  which for a text shadow is almost everywhere. In smShape at run time the
  shadow therefore goes ABOVE such a label and paints the label area itself:
  label background, then the shadow, then the text again (from the captured
  coverage and Font.Color). At design time it stays below, so the label can
  still be selected with the mouse. }
function TCWSShadow.UsesLabelOverlay: Boolean;
begin
  Result := (FMode = smShape) and not (csDesigning in ComponentState) and
    (FControl is TCustomLabel) and not TLabelAccess(FControl).Transparent;
end;

{ Composes the label area from the label's flat background, the shadow layer
  under it and the text coverage (FSourceMask) in Font.Color — opaque, so it is
  simply blitted over the label. The text keeps its greyscale antialiasing; the
  label's own ClearType rendering is what gets covered. }
procedure TCWSShadow.BuildLabelOverlay;
var
  W, H, OX, OY, X, Y, SA, A: Integer;
  Back, Text: TColorRef;
  Dst, Src: PRGBQuad;
  Cov: PByte;

  function Mix(ABack, AShadow, AText, AShadowAlpha, ACoverage: Integer): Byte; inline;
  var
    Base: Integer;
  begin
    { shadow over the flat label background (the shadow is premultiplied), then
      the text over that }
    Base := (ABack * (255 - AShadowAlpha) + 127) div 255 + AShadow;
    Result := (Base * (255 - ACoverage) + AText * ACoverage + 127) div 255;
  end;

begin
  FOverlayValid := False;
  W := FSourceWidth;
  H := FSourceHeight;
  if (W <= 0) or (H <= 0) or (Length(FSourceMask) < W * H) then
    Exit;
  OX := FControl.Left - Left;
  OY := FControl.Top - Top;
  if (OX < 0) or (OY < 0) or (OX + W > FLayer.Width) or (OY + H > FLayer.Height) then
    Exit;
  Back := ColorToRGB(TLabelAccess(FControl).Color);
  Text := ColorToRGB(TLabelAccess(FControl).Font.Color);
  FOverlay.PixelFormat := pf32bit;
  FOverlay.SetSize(W, H);
  Cov := @FSourceMask[0];
  for Y := 0 to H - 1 do
  begin
    Dst := FOverlay.ScanLine[Y];
    Src := FLayer.ScanLine[OY + Y];
    Inc(Src, OX);
    for X := 0 to W - 1 do
    begin
      SA := Src.rgbReserved;
      A := Cov^;
      Dst.rgbRed := Mix(GetRValue(Back), Src.rgbRed, GetRValue(Text), SA, A);
      Dst.rgbGreen := Mix(GetGValue(Back), Src.rgbGreen, GetGValue(Text), SA, A);
      Dst.rgbBlue := Mix(GetBValue(Back), Src.rgbBlue, GetBValue(Text), SA, A);
      Dst.rgbReserved := 255;
      Inc(Dst);
      Inc(Src);
      Inc(Cov);
    end;
  end;
  FOverlayValid := True;
end;

procedure TCWSShadow.SetControl(const Value: TControl);
begin
  if (Value = FControl) or (Value = Self) then
    Exit;
  UnhookControl;
  if FControl <> nil then
    FControl.RemoveFreeNotification(Self);
  FControl := Value;
  if FControl <> nil then
  begin
    FControl.FreeNotification(Self);
    HookControl;
    if not (csLoading in ComponentState) then
    begin
      UpdatePlacement;
      UpdateZOrder;
    end;
  end;
  Invalidate;
end;

procedure TCWSShadow.HookControl;
begin
  if FControl = nil then
    Exit;
  FControlWndProc := FControl.WindowProc;
  FControl.WindowProc := ControlWndProc;
end;

procedure TCWSShadow.UnhookControl;
var
  Current, Own: TWndMethod;
begin
  if (FControl = nil) or not Assigned(FControlWndProc) then
    Exit;
  { restore only if nobody else has hooked in after us }
  Current := FControl.WindowProc;
  Own := ControlWndProc;
  if TMethod(Current) = TMethod(Own) then
    FControl.WindowProc := FControlWndProc;
  FControlWndProc := nil;
end;

procedure TCWSShadow.ControlWndProc(var Message: TMessage);
begin
  FControlWndProc(Message);
  case Message.Msg of
    WM_WINDOWPOSCHANGED:
      UpdatePlacement;
    CM_VISIBLECHANGED, CM_SHOWINGCHANGED:
      Invalidate;
    CM_TEXTCHANGED, CM_FONTCHANGED, CM_COLORCHANGED, CM_ENABLEDCHANGED:
      { a change of look may change the shape (smShape) }
      if FMode = smShape then
      begin
        FLayerValid := False;
        Invalidate;
      end;
    CM_INVALIDATE:
      { TWinControl.Invalidate — the target may have changed its shape through a
        property no message tells about (CornerRadius, rounded corners, ...).
        Ignored while we capture it ourselves: a control that invalidates
        itself while painting would otherwise re-arm the check forever. }
      if (FMode = smShape) and not FPainting then
        ScheduleShapeCheck;
  end;
end;

const
  CM_CWSSHADOW_SHAPECHECK = WM_USER + $0C57;
  { minimum spacing of shape checks while the target keeps invalidating itself }
  ShapeCheckThrottleMs = 100;

{ A single change (a property set at run time) is checked right away: the
  check is POSTED, and posted messages are handled before WM_PAINT, so the new
  shadow is ready when the target repaints — target and shadow change in the
  same frame, just like smBox with a matching CornerRadius. (A timer-only check
  showed the new corners over the old shadow for a moment.)
  A burst of invalidations (hover, animation) is throttled: within
  ShapeCheckThrottleMs of the last check the timer takes over and runs the
  check once the burst has settled. }
procedure TCWSShadow.ScheduleShapeCheck;
begin
  if (csDestroying in ComponentState) or not (FControl is TWinControl) or
    FShapeCheckPosted then
    Exit;
  if GetTickCount - FLastShapeCheck >= ShapeCheckThrottleMs then
  begin
    if FShapeCheckWnd = 0 then
      FShapeCheckWnd := AllocateHWnd(ShapeCheckWndProc);
    FShapeCheckPosted := PostMessage(FShapeCheckWnd, CM_CWSSHADOW_SHAPECHECK, 0, 0);
    if FShapeCheckPosted then
      Exit;
  end;
  if FShapeCheckTimer = nil then
  begin
    FShapeCheckTimer := TTimer.Create(Self);
    FShapeCheckTimer.Enabled := False;
    FShapeCheckTimer.Interval := ShapeCheckThrottleMs;
    FShapeCheckTimer.OnTimer := ShapeCheckTimer;
  end;
  FShapeCheckTimer.Enabled := False;
  FShapeCheckTimer.Enabled := True;
end;

procedure TCWSShadow.ShapeCheckWndProc(var Message: TMessage);
begin
  if Message.Msg = CM_CWSSHADOW_SHAPECHECK then
  begin
    FShapeCheckPosted := False;
    RunShapeCheck;
  end
  else
    Message.Result := DefWindowProc(FShapeCheckWnd, Message.Msg, Message.WParam, Message.LParam);
end;

procedure TCWSShadow.ShapeCheckTimer(Sender: TObject);
begin
  FShapeCheckTimer.Enabled := False;
  RunShapeCheck;
end;

{ Captures the target again and compares it with the mask the layer was built
  from. Only a real change of shape costs the blur and a repaint — a plain
  repaint of unchanged content (a hover) ends here. }
procedure TCWSShadow.RunShapeCheck;
var
  Source: TAlphaMask;
begin
  FLastShapeCheck := GetTickCount;
  if (csDestroying in ComponentState) or (FControl = nil) or (FMode <> smShape) or not FLayerValid or FPainting or
    not FControl.Visible or not (FControl is TWinControl) or
    not TWinControl(FControl).HandleAllocated then
    Exit;
  { a size change is the resize path's job (stretched layer, one rebuild when
    the size settles) — capturing here on every resize step is what it avoids }
  if (FControl.Width <> FSourceWidth) or (FControl.Height <> FSourceHeight) then
    Exit;
  FPainting := True;
  try
    Source := CaptureControlMask(FControl, FIgnoreChildLabels);
  finally
    FPainting := False;
  end;
  if (Source.Width = FSourceWidth) and (Source.Height = FSourceHeight) and
    ((Length(Source.Data) = 0) or
     CompareMem(@Source.Data[0], @FSourceMask[0], Length(Source.Data))) then
    Exit;
  FLayerValid := False;
  Invalidate;
end;

procedure TCWSShadow.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FControl) then
  begin
    UnhookControl;
    FControl := nil;
    Invalidate;
  end;
end;

procedure TCWSShadow.Loaded;
begin
  inherited Loaded;
  UpdatePlacement;
  UpdateZOrder;
end;

{ The shadow shape (smBox) in the parent's coordinates. }
function TCWSShadow.GetShadowShape: TRectF;
var
  Offset: TPointF;
begin
  Result := TRectF.Create(FControl.BoundsRect);
  Offset := ShadowOffset(FDirection, FDistance);
  Result.Offset(Offset.X, Offset.Y);
  Result.Inflate(FSize, FSize);
end;

function TCWSShadow.GetShapeOffset: TPoint;
var
  Offset: TPointF;
begin
  Offset := ShadowOffset(FDirection, FDistance);
  Result := Point(Round(Offset.X), Round(Offset.Y));
end;

{ smShape layer margin: spread + reach of the blur (3 sigma, sigma = Softness / 4). }
function TCWSShadow.GetShapePad: Integer;
begin
  Result := FSize + Ceil(FSoftness * 0.75) + 1;
end;

procedure TCWSShadow.UpdatePlacement;
begin
  if (FControl = nil) or (FControl.Parent = nil) or (csLoading in ComponentState) or
    (csDestroying in ComponentState) or FUpdatingPlacement then
    Exit;
  { Re-entrancy guard: the VCL sends CM_CONTROLLISTCHANGE to the parent BEFORE
    the shadow is put on its control list. If the parent moves the target in
    reaction (TCWSSettingsPanel re-clips its children with SetWindowRgn, which
    arrives as WM_WINDOWPOSCHANGED), a nested call would still see Parent = nil
    and insert the shadow a second time — and free it twice on shutdown. }
  FUpdatingPlacement := True;
  try
    UpdatePlacementCore;
  finally
    FUpdatingPlacement := False;
  end;
end;

procedure TCWSShadow.UpdatePlacementCore;
var
  Shape: TRectF;
  Extent: Single;
  NewBounds: TRect;
begin
  if Parent <> FControl.Parent then
  begin
    Parent := FControl.Parent;
    UpdateZOrder;
  end;
  if FMode = smBox then
  begin
    Shape := GetShadowShape;
    Extent := FSoftness / 2 + 1;
    NewBounds := Rect(Floor(Shape.Left - Extent), Floor(Shape.Top - Extent),
      Ceil(Shape.Right + Extent), Ceil(Shape.Bottom + Extent));
  end
  else
  begin
    NewBounds := FControl.BoundsRect;
    NewBounds.Offset(GetShapeOffset);
    NewBounds.Inflate(GetShapePad, GetShapePad);
  end;
  if NewBounds <> BoundsRect then
  begin
    if (FControl is TWinControl) and Visible and (Parent <> nil) and
      Parent.HandleAllocated and not (csLoading in ComponentState) then
      MoveFollowingTarget(NewBounds)
    else
    begin
      { the old area — the new one is refreshed by the Invalidate in SetBounds }
      InvalidateOverlappingControls(BoundsRect);
      BoundsRect := NewBounds;
    end;
  end;
end;

{ The target moved or was resized, and the shadow follows it. SetBounds would
  invalidate the old and the new shadow rectangle on the parent in full; a VCL
  form has no WS_CLIPCHILDREN, so Windows then invalidates every child window
  under them as well — the target and its neighbours were erased and repainted
  whole on every step of a form resize (that alone more than doubled the time
  of a resize step with a few shadows). The target repaints itself after a move
  or resize anyway, so only the ring around it — old and new shadow area minus
  the target — is invalidated, and the bounds are set without SetBounds (no
  RequestAlign either: the shadow takes no part in the parent's alignment). }
procedure TCWSShadow.MoveFollowingTarget(const ANewBounds: TRect);
var
  Ring, Tmp: HRGN;
begin
  Ring := CreateRectRgnIndirect(BoundsRect);
  try
    Tmp := CreateRectRgnIndirect(ANewBounds);
    CombineRgn(Ring, Ring, Tmp, RGN_OR);
    DeleteObject(Tmp);
    Tmp := CreateRectRgnIndirect(FControl.BoundsRect);
    CombineRgn(Ring, Ring, Tmp, RGN_DIFF);
    DeleteObject(Tmp);
    UpdateBoundsRect(ANewBounds);
    InvalidateRgn(Parent.Handle, Ring, True);
    InvalidateOverlappingControlsRgn(Ring);
  finally
    DeleteObject(Ring);
  end;
end;

{ Like InvalidateOverlappingControls, but only the part of each sibling that
  ARgn (parent coordinates) covers, and never the target itself. }
procedure TCWSShadow.InvalidateOverlappingControlsRgn(ARgn: HRGN);
var
  I: Integer;
  Sibling: TControl;
  Part: HRGN;
  Box: TRect;
begin
  if (Parent = nil) or not Parent.HandleAllocated or (csDestroying in ComponentState) then
    Exit;
  GetRgnBox(ARgn, Box);
  for I := 0 to Parent.ControlCount - 1 do
  begin
    Sibling := Parent.Controls[I];
    if (Sibling = FControl) or not (Sibling is TWinControl) or not Sibling.Visible or
      not TWinControl(Sibling).HandleAllocated or not Sibling.BoundsRect.IntersectsWith(Box) then
      Continue;
    Part := CreateRectRgnIndirect(Sibling.BoundsRect);
    try
      if CombineRgn(Part, Part, ARgn, RGN_AND) > NULLREGION then
      begin
        OffsetRgn(Part, -Sibling.Left, -Sibling.Top);
        RedrawWindow(TWinControl(Sibling).Handle, nil, Part, RDW_INVALIDATE or RDW_ERASE);
      end;
    finally
      DeleteObject(Part);
    end;
  end;
end;

procedure TCWSShadow.UpdateZOrder;
var
  I, Index, TargetIndex: Integer;
begin
  if (FControl = nil) or (Parent = nil) or (FControl.Parent <> Parent) then
    Exit;
  if FControl is TWinControl then
    { windowed controls lie above graphic ones anyway — top of the graphic layer }
    BringToFront
  else
  begin
    { Controls[] lists the graphic controls first, so the index is their z-order }
    Index := -1;
    TargetIndex := -1;
    for I := 0 to Parent.ControlCount - 1 do
      if Parent.Controls[I] = Self then
        Index := I
      else if Parent.Controls[I] = FControl then
        TargetIndex := I;
    if UsesLabelOverlay then
    begin
      { right ABOVE the opaque label — see UsesLabelOverlay }
      if Index < TargetIndex then
        TWinControlAccess(Parent).SetChildOrder(Self, TargetIndex)
      else if Index > TargetIndex + 1 then
        TWinControlAccess(Parent).SetChildOrder(Self, TargetIndex + 1);
    end
    else if Index > TargetIndex then
      TWinControlAccess(Parent).SetChildOrder(Self, TargetIndex);
  end;
end;

procedure TCWSShadow.ShadowChanged;
begin
  FLayerValid := False;
  UpdatePlacement;
  Invalidate;
end;

procedure TCWSShadow.UpdateLayer;
begin
  if FMode = smBox then
    UpdateBoxLayer
  else
    UpdateShapeLayer;
end;

{ The shadow of a rounded rectangle is exactly nine-sliceable: past the corner
  zones every row (and column) is the same along the edge. So only a small
  layer is rendered — the four corner zones plus a 1 px middle — and DrawLayer
  stretches it to the real size. A resize then costs nothing: the small layer
  depends on the corner radius, the softness and the sub-pixel position of the
  shape, not on its size (the per-pixel render used to take ~13 ms per shadow
  on every resize step). }
procedure TCWSShadow.UpdateBoxLayer;
var
  Shape, Canon: TRectF;
  R, GapR, GapB: Single;
  SL, ST, SR, SB, W0, H0: Integer;
begin
  Shape := GetShadowShape;
  Shape.Offset(-Left, -Top);
  R := IfThen(FCornerRadius > 0, FCornerRadius + FSize, 0);
  R := Min(R, Min(Shape.Width, Shape.Height) / 2);
  GapR := Width - Shape.Right;
  GapB := Height - Shape.Bottom;
  { corner slices reach past the rounding, so the middle row/column is straight }
  SL := Ceil(Shape.Left + R) + 1;
  ST := Ceil(Shape.Top + R) + 1;
  SR := Ceil(GapR + R) + 1;
  SB := Ceil(GapB + R) + 1;
  W0 := SL + 1 + SR;
  H0 := ST + 1 + SB;
  if (Width > W0) and (Height > H0) then
  begin
    { the same shape in the small layer: same distances to every layer edge }
    Canon := TRectF.Create(Shape.Left, Shape.Top, W0 - GapR, H0 - GapB);
    if FLayerValid and FNineSlice and (FLayer.Width = W0) and (FLayer.Height = H0) and
      (Canon = FLayerShape) then
      Exit;
    FLayer.SetSize(W0, H0);
    RenderBoxLayer(FLayer, Canon, R, FSoftness, Color, FOpacity);
    FLayerShape := Canon;
    FNineSlice := True;
    FExpandedValid := False;
    FSliceL := SL;
    FSliceT := ST;
    FSliceR := SR;
    FSliceB := SB;
  end
  else
  begin
    { too small to slice — render it whole }
    if FLayerValid and not FNineSlice and (FLayer.Width = Width) and
      (FLayer.Height = Height) and (Shape = FLayerShape) then
      Exit;
    FLayer.SetSize(Width, Height);
    RenderBoxLayer(FLayer, Shape, R, FSoftness, Color, FOpacity);
    FLayerShape := Shape;
    FNineSlice := False;
  end;
  FLayerValid := True;
end;

{ Paints the layer: 1:1 normally, nine-sliced when it is a smBox slice layer or
  an smShape layer shown stretched during a resize. }
procedure TCWSShadow.DrawLayer(DC: HDC; const AClip: TRect);
begin
  if FNineSlice then
  begin
    if FExpanded = nil then
      FExpanded := TBitmap.Create;
    if not FExpandedValid or (FExpanded.Width <> Width) or (FExpanded.Height <> Height) then
    begin
      ExpandNineSlice(FLayer, FExpanded, FSliceL, FSliceT, FSliceR, FSliceB, Width, Height);
      FExpandedValid := True;
    end;
    BlendLayer(DC, FExpanded, AClip);
  end
  else
    BlendLayer(DC, FLayer, AClip);
end;

procedure TCWSShadow.ResizeTimer(Sender: TObject);
begin
  FResizeTimer.Enabled := False;
  FLayerValid := False;
  Invalidate;
end;

procedure TCWSShadow.UpdateShapeLayer;
var
  Source, Mask: TAlphaMask;
  Slice: Integer;
begin
  { A TWinControl changes shape rarely — capture only after an invalidation.
    A TGraphicControl (TImage, TShape, TLabel) may change its picture without
    any message, so it is captured on every paint and compared with the last one;
    the blur only runs when the shape really changed. }
  if FLayerValid and (FControl is TWinControl) then
  begin
    if (FSourceWidth = FControl.Width) and (FSourceHeight = FControl.Height) then
    begin
      FNineSlice := False;
      Exit;
    end;
    { Being resized: capturing + blurring on every step made resizing a form
      crawl. Show the old layer nine-sliced to the new size (exact for the
      usual rectangular / rounded card) and rebuild once the size has been
      stable for a moment. }
    Slice := GetShapePad + 24;
    Slice := Min(Slice, (Min(FLayer.Width, Width) - 1) div 2);
    Slice := Min(Slice, (Min(FLayer.Height, Height) - 1) div 2);
    if Slice > 0 then
    begin
      if not FNineSlice or (FSliceL <> Slice) then
        FExpandedValid := False;
      FNineSlice := True;
      FSliceL := Slice;
      FSliceT := Slice;
      FSliceR := Slice;
      FSliceB := Slice;
      if FResizeTimer = nil then
      begin
        FResizeTimer := TTimer.Create(Self);
        FResizeTimer.Enabled := False;
        FResizeTimer.Interval := 150;
        FResizeTimer.OnTimer := ResizeTimer;
      end;
      FResizeTimer.Enabled := False;
      FResizeTimer.Enabled := True;
      Exit;
    end;
  end;
  FNineSlice := False;
  Source := CaptureControlMask(FControl, FIgnoreChildLabels);
  if FLayerValid and (Source.Width = FSourceWidth) and (Source.Height = FSourceHeight) and
    ((Length(Source.Data) = 0) or
     CompareMem(@Source.Data[0], @FSourceMask[0], Length(Source.Data))) then
    Exit;
  FSourceMask := Source.Data;
  FSourceWidth := Source.Width;
  FSourceHeight := Source.Height;
  Mask := Source.Padded(GetShapePad);
  Mask.Dilate(FSize);
  Mask.GaussianBlur(FSoftness / 4);
  Mask.ToLayer(FLayer, Color, FOpacity);
  FLayerValid := True;
  if UsesLabelOverlay then
    BuildLabelOverlay
  else
    FOverlayValid := False;
end;

procedure TCWSShadow.Paint;
var
  DC: HDC;
  ClipRect: TRect;
begin
  if FControl = nil then
  begin
    if csDesigning in ComponentState then
    begin
      Canvas.Pen.Style := psDot;
      Canvas.Brush.Style := bsClear;
      Canvas.Rectangle(ClientRect);
      Canvas.TextOut(4, 4, Name);
    end;
    Exit;
  end;
  if not FControl.Visible or (Width = 0) or (Height = 0) or FPainting then
    Exit;
  { DC and clip taken BEFORE capturing the shape: the target may ask the parent
    for its background while painting, and a nested TGraphicControl paint resets
    Canvas.Handle. }
  DC := Canvas.Handle;
  ClipRect := Canvas.ClipRect;
  FPainting := True;
  try
    UpdateLayer;
  finally
    FPainting := False;
  end;
  DrawLayer(DC, ClipRect);
  { opaque label: its area is repainted as background + shadow + text }
  if FOverlayValid and UsesLabelOverlay then
    BitBlt(DC, FControl.Left - Left, FControl.Top - Top, FOverlay.Width, FOverlay.Height,
      FOverlay.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure TCWSShadow.Invalidate;
begin
  inherited Invalidate;
  InvalidateOverlappingControls(BoundsRect);
end;

procedure TCWSShadow.InvalidateOverlappingControls(const ARect: TRect);
var
  I: Integer;
  Sibling: TControl;
begin
  if (Parent = nil) or not Parent.HandleAllocated or (csDestroying in ComponentState) or
    ARect.IsEmpty then
    Exit;
  for I := 0 to Parent.ControlCount - 1 do
  begin
    Sibling := Parent.Controls[I];
    if (Sibling is TWinControl) and Sibling.Visible and
      TWinControl(Sibling).HandleAllocated and Sibling.BoundsRect.IntersectsWith(ARect) then
      RedrawWindow(TWinControl(Sibling).Handle, nil, 0, RDW_INVALIDATE or RDW_ERASE);
  end;
end;

procedure TCWSShadow.CMHitTest(var Message: TCMHitTest);
begin
  { at run time the shadow never takes the mouse — clicks reach what lies under it }
  if csDesigning in ComponentState then
    inherited
  else
    Message.Result := HTNOWHERE;
end;

procedure TCWSShadow.CMColorChanged(var Message: TMessage);
begin
  inherited;
  FLayerValid := False;
  Invalidate;
end;

procedure TCWSShadow.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  FDistance := MulDiv(FDistance, M, D);
  FSize := MulDiv(FSize, M, D);
  FSoftness := MulDiv(FSoftness, M, D);
  FCornerRadius := MulDiv(FCornerRadius, M, D);
  FLayerValid := False;
  inherited ChangeScale(M, D, isDpiChange);
end;

procedure TCWSShadow.SetDirection(const Value: Integer);
var
  NewValue: Integer;
begin
  NewValue := ((Value mod 360) + 360) mod 360;
  if FDirection <> NewValue then
  begin
    FDirection := NewValue;
    ShadowChanged;
  end;
end;

procedure TCWSShadow.SetDistance(const Value: Integer);
begin
  if FDistance <> Max(0, Value) then
  begin
    FDistance := Max(0, Value);
    ShadowChanged;
  end;
end;

procedure TCWSShadow.SetSize(const Value: Integer);
begin
  if FSize <> Max(0, Value) then
  begin
    FSize := Max(0, Value);
    ShadowChanged;
  end;
end;

procedure TCWSShadow.SetSoftness(const Value: Integer);
begin
  if FSoftness <> Max(0, Value) then
  begin
    FSoftness := Max(0, Value);
    ShadowChanged;
  end;
end;

procedure TCWSShadow.SetOpacity(const Value: Byte);
begin
  if FOpacity <> Value then
  begin
    FOpacity := Value;
    ShadowChanged;
  end;
end;

procedure TCWSShadow.SetCornerRadius(const Value: Integer);
begin
  if FCornerRadius <> Max(0, Value) then
  begin
    FCornerRadius := Max(0, Value);
    ShadowChanged;
  end;
end;

procedure TCWSShadow.SetMode(const Value: TCWSShadowMode);
begin
  if FMode <> Value then
  begin
    FMode := Value;
    UpdateZOrder;    { an opaque label is shaded from above in smShape only }
    ShadowChanged;
  end;
end;

procedure TCWSShadow.SetIgnoreChildLabels(const Value: Boolean);
begin
  if FIgnoreChildLabels <> Value then
  begin
    FIgnoreChildLabels := Value;
    ShadowChanged;
  end;
end;

end.
