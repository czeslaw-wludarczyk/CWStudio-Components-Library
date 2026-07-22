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
  TCWSSettingsPanel = class(TCustomControl)
  private
    FFillColor: TColor;
    FBorderColor: TColor;
    FCornerRadius: Integer;
    FInnerCornerRadius: Integer;
    procedure SetFillColor(const Value: TColor);
    procedure SetBorderColor(const Value: TColor);
    procedure SetCornerRadius(const Value: Integer);
    procedure SetInnerCornerRadius(const Value: Integer);
    function GetParentBgColor: TColor;
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

{ Adds a rounded rectangle (top-left at X,Y, size RW x RH, corner diameter D) to
  the GDI+ path. Shared by the panel fill/border and the antialiased corner
  overlay so both use the exact same curve. }
procedure AddRoundRectPath(APath: TGPGraphicsPath; X, Y, RW, RH, D: Single);
begin
  if D > RH then D := RH;
  if D > RW then D := RW;
  if D < 0 then D := 0;
  if D > 0 then
  begin
    APath.AddArc(X,              Y,              D, D, 180, 90);
    APath.AddArc(X + RW - D,     Y,              D, D, 270, 90);
    APath.AddArc(X + RW - D,     Y + RH - D,     D, D,   0, 90);
    APath.AddArc(X,              Y + RH - D,     D, D,  90, 90);
    APath.CloseFigure;
  end
  else
    APath.AddRectangle(MakeRect(X, Y, RW, RH));
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
begin
  { Inner radius scales with DPI exactly like the outer CornerRadius. }
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

  if Ri > 0 then
    Result := CreateRoundRectRgn(L, T, Rr, B, Ri * 2, Ri * 2)
  else
    Result := CreateRectRgn(L, T, Rr, B);
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
  Pen: TGPPen;
  W, H, R, D: Single;
begin
  { Corners (outside the rounding) show the parent background }
  Canvas.Brush.Color := GetParentBgColor;
  Canvas.FillRect(ClientRect);

  W := Width;
  H := Height;
  R := MulDiv(FCornerRadius, CurrentPPI, 96);

  G := TGPGraphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    G.SetPixelOffsetMode(PixelOffsetModeHalf);

    D := R * 2;

    Path := TGPGraphicsPath.Create;
    try
      AddRoundRectPath(Path, 0.5, 0.5, W - 1, H - 1, D);

      Brush := TGPSolidBrush.Create(MakeGPColor(FFillColor));
      try
        G.FillPath(Brush, Path);
      finally
        Brush.Free;
      end;

      Pen := TGPPen.Create(MakeGPColor(FBorderColor));
      try
        G.DrawPath(Pen, Path);
      finally
        Pen.Free;
      end;
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

end.
