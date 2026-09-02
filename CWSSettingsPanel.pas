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
unit CWSSettingsPanel;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  System.Classes, Vcl.Controls, Vcl.Graphics, System.UITypes;

type
  { Which edges of the outer 1px border are painted. Dropping an edge only hides
    that line; the panel fill and the child-clipping shape are unaffected. }
  TCWSBorderEdge = (beTop, beLeft, beRight, beBottom);
  TCWSBorderEdges = set of TCWSBorderEdge;

  { Which corners are rounded. Each corner is independent: a corner not in the
    set is drawn square in the body fill, the border and the child-clip region,
    regardless of CornerRadius / InnerCornerRadius (those values are kept). }
  TCWSCorner = (coTopLeft, coTopRight, coBottomRight, coBottomLeft);
  TCWSCorners = set of TCWSCorner;

  TCWSSettingsPanel = class(TCustomControl)
  private
    FFillColor: TColor;
    FBorderColor: TColor;
    FCornerRadius: Integer;
    FInnerCornerRadius: Integer;
    FRoundedCorners: TCWSCorners;
    FBorderEdges: TCWSBorderEdges;
    procedure SetFillColor(const Value: TColor);
    procedure SetBorderColor(const Value: TColor);
    procedure SetCornerRadius(const Value: Integer);
    procedure SetInnerCornerRadius(const Value: Integer);
    procedure SetRoundedCorners(const Value: TCWSCorners);
    procedure SetBorderEdges(const Value: TCWSBorderEdges);
    function GetParentBgColor: TColor;
    procedure DrawParentBackground(DC: HDC; ARadius: Single);
    { Strokes the enabled BorderEdges of the panel outline. Same geometry as
      AddRoundRectPath: a corner arc is emitted only where both of its adjacent
      edges are enabled AND that corner is in RoundedCorners. }
    procedure DrawBorder(G: TGPGraphics; X, Y, RW, RH, D: Single;
      Corners: TCWSCorners);
    function MakeGPColor(AColor: TColor): Cardinal;
    { Builds the inner-border clip shape (the 1px-inset rounded rectangle) in the
      coordinate system whose origin is offset by (OffsetX, OffsetY). Pass a child
      control's (Left, Top) to get the region in that child's local coords. }
    function CreateInnerRgn(OffsetX, OffsetY: Integer): HRGN;
    { Clips every hosted windowed child (TControl / TWinControl) to the inner
      rounded border via SetWindowRgn. }
    procedure UpdateChildrenClip;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure CMControlListChange(var Message: TMessage); message CM_CONTROLLISTCHANGE;
    procedure WMParentNotify(var Message: TWMParentNotify); message WM_PARENTNOTIFY;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure Paint; override;
    procedure Click; override;
    procedure DblClick; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property Constraints;
    property Color;
    property Top;
    property Left;
    property Width;
    property Height;
    property Visible;
    property Enabled;
    property ParentColor;
    property DoubleBuffered;

    property FillColor: TColor read FFillColor write SetFillColor default clWhite;
    property BorderColor: TColor read FBorderColor write SetBorderColor default clSilver;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 8;

    { Rounding of the inner clip (the 1px inner border) that hosted controls are
      clipped to. Adjustable just like CornerRadius; set to 0 for square inner
      corners. Defaults to CornerRadius - 1 so it nests neatly inside the border. }
    property InnerCornerRadius: Integer read FInnerCornerRadius write SetInnerCornerRadius default 7;

    { Which corners are rounded — each one independently. A corner removed from
      the set is drawn square in the body fill, the border and the child-clip
      region; CornerRadius / InnerCornerRadius still apply to the corners that
      remain. Clear the whole set for a fully square panel. }
    property RoundedCorners: TCWSCorners read FRoundedCorners write SetRoundedCorners
      default [coTopLeft, coTopRight, coBottomRight, coBottomLeft];

    { Which of the four border edges are painted. Drop an edge to leave that side
      of the panel open; the fill and the child clipping are not affected. A
      corner arc is drawn only where both of its edges remain and that corner is
      in RoundedCorners. }
    property BorderEdges: TCWSBorderEdges read FBorderEdges write SetBorderEdges
      default [beTop, beLeft, beRight, beBottom];

    // Events in the Object Inspector
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseEnter;
    property OnMouseLeave;
  end;

implementation

type
  { Cracker that exposes the parent's protected Color property. }
  TControlAccess = class(TControl);

{ Adds a rectangle (top-left at X,Y, size RW x RH, corner diameter D) to the GDI+
  path, rounding only the corners listed in Corners. Shared by the panel fill and
  the border stroke so both use the exact same outline. Built edge-by-edge from
  explicit endpoints (no zero-length segments) so a square corner is a true 90°
  angle, not a chamfer. }
procedure AddRoundRectPath(APath: TGPGraphicsPath; X, Y, RW, RH, D: Single;
  Corners: TCWSCorners);
var
  HR: Single;
  x1, x2, y1, y2: Single;
begin
  if D > RH then D := RH;
  if D > RW then D := RW;
  if D < 0 then D := 0;

  if (D = 0) or (Corners = []) then
  begin
    APath.AddRectangle(MakeRect(X, Y, RW, RH));
    Exit;
  end;

  HR := D / 2;

  { Where each edge meets its corners: inset by HR at a rounded corner, flush to
    the corner point at a square one. }
  if coTopLeft     in Corners then x1 := X + HR       else x1 := X;
  if coTopRight    in Corners then x2 := X + RW - HR  else x2 := X + RW;
  APath.AddLine(x1, Y, x2, Y);                                { top edge }
  if coTopRight in Corners then
    APath.AddArc(X + RW - D, Y, D, D, 270, 90);

  if coTopRight    in Corners then y1 := Y + HR       else y1 := Y;
  if coBottomRight in Corners then y2 := Y + RH - HR  else y2 := Y + RH;
  APath.AddLine(X + RW, y1, X + RW, y2);                      { right edge }
  if coBottomRight in Corners then
    APath.AddArc(X + RW - D, Y + RH - D, D, D, 0, 90);

  if coBottomRight in Corners then x1 := X + RW - HR  else x1 := X + RW;
  if coBottomLeft  in Corners then x2 := X + HR       else x2 := X;
  APath.AddLine(x1, Y + RH, x2, Y + RH);                      { bottom edge }
  if coBottomLeft in Corners then
    APath.AddArc(X, Y + RH - D, D, D, 90, 90);

  if coBottomLeft  in Corners then y1 := Y + RH - HR  else y1 := Y + RH;
  if coTopLeft     in Corners then y2 := Y + HR       else y2 := Y;
  APath.AddLine(X, y1, X, y2);                                { left edge }
  if coTopLeft in Corners then
    APath.AddArc(X, Y, D, D, 180, 90);

  APath.CloseFigure;
end;

{ TCWSSettingsPanel }

constructor TCWSSettingsPanel.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle + [csAcceptsControls, csOpaque];
  DoubleBuffered := True;

  FFillColor := clWhite;
  FBorderColor := clSilver;
  FCornerRadius := 8;
  FInnerCornerRadius := 7;
  FRoundedCorners := [coTopLeft, coTopRight, coBottomRight, coBottomLeft];
  FBorderEdges := [beTop, beLeft, beRight, beBottom];

  { Plain default size — the VCL scales it for the active DPI automatically. }
  Width := 350;
  Height := 80;
end;

procedure TCWSSettingsPanel.CreateParams(var Params: TCreateParams);
begin
  inherited;
  { Clip child controls so the custom-painted background/border is never drawn
    over hosted controls. Without this an all-sides-anchored child flush to the
    panel edge fights the panel's full-ClientRect repaint on every resize, which
    looks like the panel growing / the child getting the wrong size. }
  Params.Style := Params.Style or WS_CLIPCHILDREN;
end;

function TCWSSettingsPanel.CreateInnerRgn(OffsetX, OffsetY: Integer): HRGN;
const
  BW = 1; { the 1px inner border that content is clipped inside of }
var
  Ri, L, T, Rr, B: Integer;

  { OR a square patch over one corner quadrant so that corner is not clipped
    round. Called for every corner absent from RoundedCorners. }
  procedure SquareOff(PatchL, PatchT, PatchR, PatchB: Integer);
  var
    Patch: HRGN;
  begin
    Patch := CreateRectRgn(PatchL, PatchT, PatchR, PatchB);
    CombineRgn(Result, Result, Patch, RGN_OR);
    DeleteObject(Patch);
  end;

begin
  { Inner radius scales with DPI exactly like the outer CornerRadius; squared off
    entirely when no corner is rounded. }
  if FRoundedCorners = [] then
    Ri := 0
  else
    Ri := MulDiv(FInnerCornerRadius, CurrentPPI, 96);

  { Inner rect in client coords, inset by BW on every side. The +1 on right/bottom
    matches every other CreateRoundRectRgn / CreateRectRgn call in this library:
    those APIs treat right/bottom as exclusive AND under-fill the bottom-right
    rounded corner by one pixel, so without the +1 the content stops one pixel
    short of the bottom/right border — the visible gap reported there, while the
    inclusive top/left edges sit correctly flush under the border. }
  L  := BW - OffsetX;
  T  := BW - OffsetY;
  Rr := Width  - BW - OffsetX + 1;
  B  := Height - BW - OffsetY + 1;

  if Ri <= 0 then
    Exit(CreateRectRgn(L, T, Rr, B));

  { Start fully rounded, then square off the corners that are not in the set. }
  Result := CreateRoundRectRgn(L, T, Rr, B, Ri * 2, Ri * 2);
  if not (coTopLeft     in FRoundedCorners) then SquareOff(L,       T,       L + Ri,  T + Ri);
  if not (coTopRight    in FRoundedCorners) then SquareOff(Rr - Ri, T,       Rr,      T + Ri);
  if not (coBottomRight in FRoundedCorners) then SquareOff(Rr - Ri, B - Ri,  Rr,      B);
  if not (coBottomLeft  in FRoundedCorners) then SquareOff(L,       B - Ri,  L + Ri,  B);
end;

procedure TCWSSettingsPanel.UpdateChildrenClip;
var
  I: Integer;
  Child: TControl;
  Rgn: HRGN;
begin
  if csDestroying in ComponentState then
    Exit;

  for I := 0 to ControlCount - 1 do
  begin
    Child := Controls[I];
    { Only windowed children own a HWND that can carry a window region; graphic
      controls are handled by the canvas clip in Paint. }
    if (Child is TWinControl) and TWinControl(Child).HandleAllocated then
    begin
      { The region is shifted into the child's local coords so the rounded inner
        border lands at the same place regardless of where the child sits. A child
        well inside the panel simply gets a region that fully contains it (no
        visible clipping); only children reaching a rounded corner get trimmed. }
      Rgn := CreateInnerRgn(Child.Left, Child.Top);
      if SetWindowRgn(TWinControl(Child).Handle, Rgn, True) = 0 then
        DeleteObject(Rgn);
    end;
  end;
end;

procedure TCWSSettingsPanel.CreateWnd;
begin
  inherited CreateWnd;
  { The panel's own handle was just (re)created; re-clip any children that already
    own a handle. }
  UpdateChildrenClip;
end;

procedure TCWSSettingsPanel.AlignControls(AControl: TControl; var Rect: TRect);
begin
  inherited AlignControls(AControl, Rect);
  { Runs after every layout pass — panel resize, child move/resize, anchor/align
    changes — so the per-child clip always tracks the current geometry. }
  UpdateChildrenClip;
end;

procedure TCWSSettingsPanel.WMParentNotify(var Message: TWMParentNotify);
begin
  inherited;
  { A hosted windowed child has just created (or re-created) its HWND. This is the
    crucial runtime hook: controls such as TDBGrid / TPanel allocate their handle
    lazily — after the layout pass that first tried to clip them — and a window
    region is bound to a specific HWND, so it is lost on every handle recreation.
    Re-applying here is what makes plain TWinControl children clip at runtime, not
    just at design time. }
  if Message.Event = WM_CREATE then
    UpdateChildrenClip;
end;

procedure TCWSSettingsPanel.CMControlListChange(var Message: TMessage);
var
  Ctl: TControl;
  Inserting: Boolean;
begin
  inherited;
  { WParam = the control, LParam <> 0 when it is being inserted. }
  Ctl := TControl(Pointer(Message.WParam));
  Inserting := Message.LParam <> 0;

  { A control leaving the panel must drop the clip we put on it, otherwise it would
    keep the rounded shape after being re-parented elsewhere. }
  if (not Inserting) and (Ctl is TWinControl) and TWinControl(Ctl).HandleAllocated then
    SetWindowRgn(TWinControl(Ctl).Handle, 0, True);

  { Re-clip so newly hosted controls pick up the rounded inner border immediately. }
  UpdateChildrenClip;
end;

function TCWSSettingsPanel.GetParentBgColor: TColor;
begin
  if Parent <> nil then
    Result := TControlAccess(Parent).Color
  else
    Result := clBtnFace;
end;

procedure TCWSSettingsPanel.DrawParentBackground(DC: HDC; ARadius: Single);
var
  SaveIdx: Integer;
  Rgn: HRGN;
  D: Integer;
begin
  { The GetParentBgColor fill done by the caller is only a correct guess when the
    parent paints itself as a flat fill of that very color. A container drawing a
    gradient/card background, a VCL-styled form, or a parent whose Color is out
    of sync with what it actually paints all leave visible wrong-colored
    triangles outside our rounded corners — so let the parent render its real
    background here instead.
    Skipped at design time: a form's PaintWindow draws the designer dot grid,
    which would then bleed into the corners. }
  if (Parent = nil) or (csDesigning in ComponentState) then
    Exit;
  SaveIdx := SaveDC(DC);
  try
    { Clip to the sliver outside the rounded body (inset by 1 px so the
      antialiased edge blends against real parent pixels). Region coordinates
      are device units, so this must happen before MoveWindowOrg. }
    D := Round(ARadius) * 2;
    Rgn := CreateRoundRectRgn(1, 1, Width, Height, D, D);
    try
      ExtSelectClipRgn(DC, Rgn, RGN_DIFF);
    finally
      DeleteObject(Rgn);
    end;
    { Shift the origin so the parent paints in its own coordinate system. }
    MoveWindowOrg(DC, -Left, -Top);
    Parent.Perform(WM_ERASEBKGND, WPARAM(DC), 0);
    { Parents that swallow WM_ERASEBKGND and paint in WM_PAINT (all the CWStudio
      containers do) only respond to this one. }
    Parent.Perform(WM_PRINTCLIENT, WPARAM(DC), PRF_CLIENT);
  finally
    RestoreDC(DC, SaveIdx);
  end;
end;

procedure TCWSSettingsPanel.DrawBorder(G: TGPGraphics; X, Y, RW, RH, D: Single;
  Corners: TCWSCorners);
var
  Pen: TGPPen;
  HR: Single;
  T, L, Rt, B: Boolean;
  { per-corner inset: half the diameter at a rounded corner, 0 at a square one }
  iTL, iTR, iBR, iBL: Single;
begin
  if FBorderEdges = [] then
    Exit;

  { Clamp the diameter exactly like AddRoundRectPath so the straight parts of the
    stroke line up with the filled body. }
  if D > RH then D := RH;
  if D > RW then D := RW;
  if D < 0  then D := 0;
  HR := D / 2;

  T  := beTop    in FBorderEdges;
  L  := beLeft   in FBorderEdges;
  Rt := beRight  in FBorderEdges;
  B  := beBottom in FBorderEdges;

  if coTopLeft     in Corners then iTL := HR else iTL := 0;
  if coTopRight    in Corners then iTR := HR else iTR := 0;
  if coBottomRight in Corners then iBR := HR else iBR := 0;
  if coBottomLeft  in Corners then iBL := HR else iBL := 0;

  Pen := TGPPen.Create(MakeGPColor(FBorderColor));
  try
    { Straight segments — from one corner (inset if rounded) to the next. }
    if T then
      G.DrawLine(Pen, X + iTL,   Y,            X + RW - iTR, Y);
    if B then
      G.DrawLine(Pen, X + iBL,   Y + RH,       X + RW - iBR, Y + RH);
    if L then
      G.DrawLine(Pen, X,         Y + iTL,      X,            Y + RH - iBL);
    if Rt then
      G.DrawLine(Pen, X + RW,    Y + iTR,      X + RW,       Y + RH - iBR);

    { Corner arcs — only where the corner is rounded and both its edges are drawn. }
    if D > 0 then
    begin
      if (coTopLeft     in Corners) and T and L then
        G.DrawArc(Pen, X,           Y,           D, D, 180, 90);
      if (coTopRight    in Corners) and T and Rt then
        G.DrawArc(Pen, X + RW - D,  Y,           D, D, 270, 90);
      if (coBottomRight in Corners) and B and Rt then
        G.DrawArc(Pen, X + RW - D,  Y + RH - D,  D, D,   0, 90);
      if (coBottomLeft  in Corners) and B and L then
        G.DrawArc(Pen, X,           Y + RH - D,  D, D,  90, 90);
    end;
  finally
    Pen.Free;
  end;
end;

function TCWSSettingsPanel.MakeGPColor(AColor: TColor): Cardinal;
var
  C: TColor;
begin
  C := ColorToRGB(AColor);
  Result := Winapi.GDIPAPI.MakeColor(255, GetRValue(C), GetGValue(C), GetBValue(C));
end;

procedure TCWSSettingsPanel.Paint;
var
  G: TGPGraphics;
  Path: TGPGraphicsPath;
  Brush: TGPSolidBrush;
  W, H, R, D: Single;
begin
  { Corners (outside the rounding) show the parent background }
  Canvas.Brush.Color := GetParentBgColor;
  Canvas.FillRect(ClientRect);

  W := Width;
  H := Height;
  if FRoundedCorners <> [] then
    R := MulDiv(FCornerRadius, CurrentPPI, 96)
  else
    R := 0;
  DrawParentBackground(Canvas.Handle, R);

  G := TGPGraphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    G.SetPixelOffsetMode(PixelOffsetModeHalf);

    D := R * 2;

    Path := TGPGraphicsPath.Create;
    try
      AddRoundRectPath(Path, 0.5, 0.5, W - 1, H - 1, D, FRoundedCorners);

      Brush := TGPSolidBrush.Create(MakeGPColor(FFillColor));
      try
        G.FillPath(Brush, Path);
      finally
        Brush.Free;
      end;

      DrawBorder(G, 0.5, 0.5, W - 1, H - 1, D, FRoundedCorners);
    finally
      Path.Free;
    end;
  finally
    G.Free;
  end;
end;

procedure TCWSSettingsPanel.Click;
begin
  { Fires OnClick assigned in the Object Inspector }
  inherited Click;
end;

procedure TCWSSettingsPanel.DblClick;
begin
  inherited DblClick;
end;

procedure TCWSSettingsPanel.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if Assigned(OnMouseEnter) then OnMouseEnter(Self);
end;

procedure TCWSSettingsPanel.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if Assigned(OnMouseLeave) then OnMouseLeave(Self);
end;

procedure TCWSSettingsPanel.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  { Background is fully repainted in Paint; skip the default erase to avoid flicker. }
  Message.Result := 1;
end;

procedure TCWSSettingsPanel.SetFillColor(const Value: TColor);
begin
  if FFillColor <> Value then
  begin
    FFillColor := Value;
    Invalidate;
  end;
end;

procedure TCWSSettingsPanel.SetBorderColor(const Value: TColor);
begin
  if FBorderColor <> Value then
  begin
    FBorderColor := Value;
    Invalidate;
  end;
end;

procedure TCWSSettingsPanel.SetCornerRadius(const Value: Integer);
begin
  if FCornerRadius <> Value then
  begin
    FCornerRadius := Value;
    Invalidate;
  end;
end;

procedure TCWSSettingsPanel.SetInnerCornerRadius(const Value: Integer);
var
  V: Integer;
begin
  V := Value;
  if V < 0 then
    V := 0;
  if FInnerCornerRadius <> V then
  begin
    FInnerCornerRadius := V;
    UpdateChildrenClip; { re-clip windowed children to the new inner rounding }
    Invalidate;         { repaint so graphic children re-clip too }
  end;
end;

procedure TCWSSettingsPanel.SetRoundedCorners(const Value: TCWSCorners);
begin
  if FRoundedCorners <> Value then
  begin
    FRoundedCorners := Value;
    UpdateChildrenClip; { square / round the windowed children's clip region }
    Invalidate;         { repaint the body, border and graphic-child clip }
  end;
end;

procedure TCWSSettingsPanel.SetBorderEdges(const Value: TCWSBorderEdges);
begin
  if FBorderEdges <> Value then
  begin
    FBorderEdges := Value;
    Invalidate;
  end;
end;

end.
