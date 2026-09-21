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
{
  TCWSFlayoutPopupMenu — a WinUI 3 CommandBarFlyout for the VCL.

  The WinUI control has two command levels: PrimaryCommands, drawn as a
  horizontal bar of icon buttons with a caption underneath, and
  SecondaryCommands, an ordinary vertical menu shown below the bar. When
  secondary commands exist the bar ends with a "…" (See more) button that
  expands and collapses that second level:

      <CommandBarFlyout>
        <AppBarButton Label="Favorite" Icon="OutlineStar"/>   <- primary
        <AppBarButton Label="Copy"     Icon="Copy"/>          <- primary
        <CommandBarFlyout.SecondaryCommands>
          <AppBarButton Label="Rotate" Icon="Rotate"/>        <- secondary
          <AppBarButton Label="Delete" Icon="Delete"/>        <- secondary
        </CommandBarFlyout.SecondaryCommands>
      </CommandBarFlyout>

  In the VCL there is only one flat TMenuItem tree, so the split is expressed
  with a separator — everything before the first top-level separator is a
  primary command, everything after it is a secondary one:

      Items
        ├─ Favorite          ┐
        ├─ Copy              │ primary commands (the bar)
        ├─ Share             ┘
        ├─ ──────────────      <- the split
        ├─ Rotate            ┐ secondary commands (the list)
        └─ Delete            ┘

  PrimaryCount overrides that rule with an explicit count when the menu has no
  separator to spare (-1 = split on the separator, the default).

  Secondary commands behave exactly like items of TCWSPopupMenu: submenus,
  shortcuts, check marks, images, scrolling on long lists. A primary command
  with children opens its submenu underneath the button, like an AppBarButton
  with an attached Flyout.

  The styling properties are inherited from TCWSPopupMenu.
}
unit CWSFlayoutPopupMenu;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.MultiMon,
  System.SysUtils, System.Classes, System.UITypes, System.Math,
  System.Generics.Collections, Vcl.Controls, Vcl.Graphics, Vcl.Menus,
  Vcl.ImgList, Vcl.Forms, Winapi.GDIPAPI, Winapi.GDIPOBJ, System.Types,
  CWSPopupMenu;

type
  TCWSFlayoutPopupMenu = class;

  { Caption of a primary command: under the icon (WinUI default) or hidden,
    which gives the compact bar of icons only. }
  TCWSLabelPosition = (lpBottom, lpCollapsed);

  { Which way the list of secondary commands grows out of the bar. }
  TCWSExpandDirection = (edDown, edUp);

  { An element of the command bar: a button, a vertical rule (Separator), or
    the "…" (See more) button, which is the one with Item = nil. }
  TCWSPrimEntry = record
    Item: TMenuItem;
    Left: Integer;
    Width: Integer;
    More: Boolean;
    Separator: Boolean;
  end;

  { An item in the vertical part — the secondary commands or a submenu. }
  TCWSSecEntry = record
    Item: TMenuItem;
    Top: Integer;        { Y in content space, before scrolling }
    Height: Integer;
    Separator: Boolean;
  end;

  { ── Layered window: command bar + vertical list ─────────────────────────
    One class serves both levels. The root window of the flyout has FIsBar
    set and draws the bar; every submenu window is created with FIsBar False
    and is then an ordinary vertical menu. }
  TCWSFlyWindow = class(TCustomControl)
  private
    FMenu: TCWSFlayoutPopupMenu;
    FRoot: TMenuItem;            { parent item whose children we display }
    FParentWin: TCWSFlyWindow;   { parent window (nil for the root) }
    FChildWin: TCWSFlyWindow;    { open submenu }
    FIsBar: Boolean;             { root window of the flyout }
    FBarAtBottom: Boolean;       { the list opened upwards }
    FExpanded: Boolean;          { secondary commands visible }
    FScale: Single;
    FDpi: Integer;
    FShadow, FBlur, FShadowOffset: Integer;
    FBodyW, FBodyH, FWinW, FWinH: Integer;
    FWinLeft, FWinTop: Integer;
    FBodyScreen: TRect;
    FAnchor: TPoint;             { the point Popup was called with — kept for
                                   the re-layout that follows an expand }
    FBarH, FBarW: Integer;
    FIconSize, FBtnH: Integer;
    FPrim: TArray<TCWSPrimEntry>;
    FSec: TArray<TCWSSecEntry>;
    FContentH: Integer;
    FViewH: Integer;
    FScrolling: Boolean;
    FScrollPos: Integer;
    FMaxScroll: Integer;
    FArrowH: Integer;
    FVPad: Integer;
    FHotIndex: Integer;          { index in FSec or -1 }
    FHotPrim: Integer;           { index in FPrim or -1 }
    FChildPrim: Integer;         { bar button whose submenu is open, or -1 }
    FHotArrow: Integer;          { 0 none, 1 up, 2 down }
    FScrollTimer: UINT_PTR;

    { An item chosen on WM_LBUTTONDOWN is executed only on WM_LBUTTONUP —
      see the same guard in TCWSPopupMenu. }
    FPendingClose: Boolean;
    FPendingIdx: Integer;
    FPendingPrim: Integer;

    procedure ComputeScale(const X, Y: Integer);
    function FontEmSize: Single;
    function MakeGdiFont: HFONT;
    function MakeGdiFontEx(ABold: Boolean): HFONT;
    function ItemHasGlyph(AItem: TMenuItem): Boolean;
    function MeasureTextW(ADC: HDC; const S: string): Integer;
    function MeasureTextH(ADC: HDC): Integer;
    function ShortCutOf(AItem: TMenuItem): string;
    function HasSecondary: Boolean;
    procedure BuildEntries;
    procedure Measure;
    procedure Render;
    procedure DrawIcon(G: TGPGraphics; AItem: TMenuItem; const ADest: TRect;
      AEnabled: Boolean);
    function BarTop: Integer;
    function ListTop: Integer;
    function ContentTop: Integer;
    function EntryClientTop(AIdx: Integer): Integer;
    function IndexAt(const P: TPoint): Integer;
    function PrimAt(const P: TPoint): Integer;
    function PrimRect(AIdx: Integer): TRect;
    function ArrowAt(const P: TPoint): Integer;
    function Selectable(AIdx: Integer): Boolean;
    function Hoverable(AIdx: Integer): Boolean;
    function PrimSelectable(AIdx: Integer): Boolean;
    procedure SetHot(AIdx: Integer);
    procedure SetHotPrim(AIdx: Integer);
    procedure StartScrollTimer;
    procedure StopScrollTimer;
    procedure ScrollBy(ADelta: Integer);
    function CommitPending: Boolean;
    procedure EnsureVisible(AIdx: Integer);
    procedure OpenSubmenu(AIdx: Integer);
    procedure OpenPrimSubmenu(AIdx: Integer);
    procedure CloseChild;
    function Deepest: TCWSFlyWindow;
    procedure Place;
    procedure SetExpanded(AValue: Boolean);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure WMLButtonUp(var Msg: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMRButtonUp(var Msg: TWMRButtonUp); message WM_RBUTTONUP;
    procedure WMCaptureChanged(var Msg: TMessage); message WM_CAPTURECHANGED;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMTimer(var Msg: TWMTimer); message WM_TIMER;
    procedure WMMouseWheel(var Msg: TWMMouseWheel); message WM_MOUSEWHEEL;
    procedure WMMouseActivate(var Msg: TWMMouseActivate); message WM_MOUSEACTIVATE;
  public
    constructor CreateForMenu(AMenu: TCWSFlayoutPopupMenu; ARoot: TMenuItem;
      AParent: TCWSFlyWindow; AIsBar: Boolean); reintroduce;
    destructor Destroy; override;
    procedure ShowAt(X, Y: Integer);
    procedure CloseChain;          { closes this window together with its submenus }
    procedure ActivateItem(AIdx: Integer);
    procedure ActivatePrim(AIdx: Integer);
    procedure KeyAction(AKey: Word);
    property BodyScreen: TRect read FBodyScreen;
    property Expanded: Boolean read FExpanded write SetExpanded;
  end;

  { ── Komponent ──────────────────────────────────────────────────────────── }
  TCWSFlayoutPopupMenu = class(TCWSPopupMenu)
  private
    FFlyWin: TCWSFlyWindow;
    FPrimaryCount: Integer;
    FLabelPosition: TCWSLabelPosition;
    FPrimaryIconSize: Integer;
    FPrimaryButtonWidth: Integer;
    FSecondaryBackgroundColor: TColor;
    FAutoExpand: Boolean;
    FShowMoreButton: Boolean;
    FOnExpandChanged: TNotifyEvent;
    function GetExpanded: Boolean;
    procedure SetExpanded(const Value: Boolean);
  protected
    { DoClose is protected in TCWSPopupMenu, i.e. declared in another unit —
      the window class reaches it through this wrapper. }
    procedure DoCloseNotify;
    procedure DoExpandChanged; virtual;
    { The split of Items into the two command levels. Both lists hold only
      visible items; the separator that marks the split is dropped. }
    procedure SplitCommands(APrimary, ASecondary: TList<TMenuItem>);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Popup(X, Y: Integer); override;
    { Places the flyout over a control the way an AttachedFlyout does — above
      it when there is room, otherwise below, horizontally centred. }
    procedure PopupForControl(AControl: TControl);
    { Same, for an arbitrary screen rectangle (a grid cell, an image region). }
    procedure PopupForRect(const ARect: TRect);
    procedure CloseMenu; override;
    property Expanded: Boolean read GetExpanded write SetExpanded;
  published
    { -1 = the first top-level separator splits the levels (default);
      >= 0 = that many leading items are primary, the rest secondary.

      Only with an explicit count can a separator be placed *inside* the
      command bar, where it is drawn as a vertical rule between groups of
      commands (AppBarSeparator). In the default mode the first separator is
      what marks the split, so there is nothing left to tell the two meanings
      apart; set PrimaryCount and the separators before that point become
      rules. Rules do not count towards PrimaryCount. }
    property PrimaryCount: Integer read FPrimaryCount write FPrimaryCount default -1;
    property LabelPosition: TCWSLabelPosition read FLabelPosition write FLabelPosition default lpBottom;
    property PrimaryIconSize: Integer read FPrimaryIconSize write FPrimaryIconSize default 20;
    { Minimum width of a bar button; a longer caption widens it. }
    property PrimaryButtonWidth: Integer read FPrimaryButtonWidth write FPrimaryButtonWidth default 68;
    { Equal to BackgroundColor by default — the command bar and the list of
      secondary commands form one uniform surface. Set it to a different colour
      to get the two-tone look, where the second level sits on its own
      slightly deeper ground. }
    property SecondaryBackgroundColor: TColor read FSecondaryBackgroundColor write FSecondaryBackgroundColor default $00F9F9F9;
    { True = the secondary commands are shown right away (the flyout opens
      expanded), False = only the bar with the "…" button. }
    property AutoExpand: Boolean read FAutoExpand write FAutoExpand default False;
    property ShowMoreButton: Boolean read FShowMoreButton write FShowMoreButton default True;
    property OnExpandChanged: TNotifyEvent read FOnExpandChanged write FOnExpandChanged;
  end;

implementation

const
  ULW_ALPHA = $00000002;
  { Peak shadow opacity (0..255) — low, soft like in WinUI 3. }
  MENU_SHADOW_ALPHA = 86;
  EVENT_SYSTEM_FOREGROUND_ = $0003;
  WINEVENT_OUTOFCONTEXT_   = $0000;

var
  GFlyMouseHook: HHOOK = 0;
  GFlyKeyHook: HHOOK = 0;
  GFlyFgEventHook: THandle = 0;
  GFlyOpen: TList<TCWSFlyWindow> = nil;
  GFlyRootWin: TCWSFlyWindow = nil;

{ ════════════════════════════════════════════════════════════════════════════
    Pomocnicze GDI+
  ════════════════════════════════════════════════════════════════════════════ }

function GPColor(C: TColor; A: Byte = 255): ARGB;
var
  RGB: COLORREF;
begin
  RGB := ColorToRGB(C);
  Result := MakeColor(A, GetRValue(RGB), GetGValue(RGB), GetBValue(RGB));
end;

{ Rounded rectangle with separate radii for the top and the bottom edge — the
  block of secondary commands is rounded only where it meets the border of the
  flyout, and square where it meets the command bar. }
function CreateRRPath2(X, Y, W, H, RTop, RBot: Single): TGPGraphicsPath;
var
  DT, DB: Single;
begin
  Result := TGPGraphicsPath.Create;
  if (RTop <= 0) and (RBot <= 0) then
  begin
    Result.AddRectangle(MakeRect(X, Y, W, H));
    Exit;
  end;
  DT := RTop * 2;
  DB := RBot * 2;
  if DT > W then DT := W;
  if DB > W then DB := W;
  if DT > H then DT := H;
  if DB > H then DB := H;
  Result.StartFigure;
  if DT > 0 then
  begin
    Result.AddArc(X, Y, DT, DT, 180, 90);
    Result.AddArc(X + W - DT, Y, DT, DT, 270, 90);
  end
  else
  begin
    Result.AddLine(X, Y, X + W, Y);
  end;
  if DB > 0 then
  begin
    Result.AddArc(X + W - DB, Y + H - DB, DB, DB, 0, 90);
    Result.AddArc(X, Y + H - DB, DB, DB, 90, 90);
  end
  else
  begin
    Result.AddLine(X + W, Y + H, X, Y + H);
  end;
  Result.CloseFigure;
end;

function CreateRRPath(X, Y, W, H, R: Single): TGPGraphicsPath;
begin
  Result := CreateRRPath2(X, Y, W, H, R, R);
end;

{ Silhouette (0/255) of a rounded rectangle — used as the shadow base. }
procedure RasterRoundRectAlpha(P: PByte; W, H, SX, SY, BW, BH, RR: Integer);
var
  X, Y, DY, Inset, X0, X1, CyTop, CyBot: Integer;
  Row: PByte;
begin
  if (BW <= 0) or (BH <= 0) then Exit;
  if RR < 0 then RR := 0;
  if RR > BW div 2 then RR := BW div 2;
  if RR > BH div 2 then RR := BH div 2;
  CyTop := SY + RR;
  CyBot := SY + BH - 1 - RR;
  for Y := SY to SY + BH - 1 do
  begin
    if (Y < 0) or (Y >= H) then Continue;
    if Y < CyTop then DY := CyTop - Y
    else if Y > CyBot then DY := Y - CyBot
    else DY := 0;
    if DY = 0 then Inset := 0
    else Inset := RR - Trunc(Sqrt(RR * RR - DY * DY) + 0.5);
    X0 := SX + Inset;
    X1 := SX + BW - 1 - Inset;
    if X0 < 0 then X0 := 0;
    if X1 > W - 1 then X1 := W - 1;
    if X1 < X0 then Continue;
    Row := P; Inc(Row, Y * W + X0);
    for X := X0 to X1 do begin Row^ := 255; Inc(Row); end;
  end;
end;

{ Box blur of the alpha channel (separable, Iter passes ≈ Gaussian). }
procedure BoxBlurAlpha(P: PByte; W, H, R, Iter: Integer);
var
  Tmp: TBytes;
  Pref: array of Integer;
  It, X, Y, L, R2, Cnt, Base: Integer;
  PB: PByte;
begin
  if (R < 1) or (W < 1) or (H < 1) then Exit;
  SetLength(Tmp, W * H);
  SetLength(Pref, Max(W, H) + 1);
  for It := 1 to Iter do
  begin
    for Y := 0 to H - 1 do
    begin
      Base := Y * W;
      Pref[0] := 0;
      PB := P; Inc(PB, Base);
      for X := 0 to W - 1 do begin Pref[X + 1] := Pref[X] + PB^; Inc(PB); end;
      for X := 0 to W - 1 do
      begin
        L := X - R; if L < 0 then L := 0;
        R2 := X + R; if R2 > W - 1 then R2 := W - 1;
        Cnt := R2 - L + 1;
        Tmp[Base + X] := (Pref[R2 + 1] - Pref[L]) div Cnt;
      end;
    end;
    for X := 0 to W - 1 do
    begin
      Pref[0] := 0;
      for Y := 0 to H - 1 do Pref[Y + 1] := Pref[Y] + Tmp[Y * W + X];
      for Y := 0 to H - 1 do
      begin
        L := Y - R; if L < 0 then L := 0;
        R2 := Y + R; if R2 > H - 1 then R2 := H - 1;
        Cnt := R2 - L + 1;
        PB := P; Inc(PB, Y * W + X);
        PB^ := (Pref[R2 + 1] - Pref[L]) div Cnt;
      end;
    end;
  end;
end;

type
  { Renders a glyph onto a prepared 32bpp canvas. }
  TGlyphDrawProc = reference to procedure (ACanvas: TCanvas);

{ Draws a glyph into a 32bpp premultiplied DIB that GDI+ can alpha-blend.
  See the identical routine in CWSPopupMenu for why the detour is needed:
  neither Bitmap.FromHICON nor Bitmap.FromHBITMAP preserves the alpha channel
  of an image list, so glyphs would come out as black squares. }
function RenderGlyph(AWidth, AHeight: Integer;
  const ADraw: TGlyphDrawProc): TBitmap;
var
  OnWhite: TBitmap;
  X, Y: Integer;
  PA, PB: PRGBQuad;
  HasAlpha: Boolean;
begin
  Result := TBitmap.Create;
  try
    Result.PixelFormat := pf32bit;
    Result.AlphaFormat := afPremultiplied;
    Result.SetSize(AWidth, AHeight);
    ZeroMemory(Result.ScanLine[AHeight - 1], AWidth * AHeight * 4);
    ADraw(Result.Canvas);

    HasAlpha := False;
    for Y := 0 to AHeight - 1 do
    begin
      PA := PRGBQuad(Result.ScanLine[Y]);
      for X := 0 to AWidth - 1 do
      begin
        if PA^.rgbReserved <> 0 then begin HasAlpha := True; Break; end;
        Inc(PA);
      end;
      if HasAlpha then Break;
    end;
    if HasAlpha then Exit;

    OnWhite := TBitmap.Create;
    try
      OnWhite.PixelFormat := pf32bit;
      OnWhite.SetSize(AWidth, AHeight);
      OnWhite.Canvas.Brush.Color := clWhite;
      OnWhite.Canvas.FillRect(Rect(0, 0, AWidth, AHeight));
      ADraw(OnWhite.Canvas);
      for Y := 0 to AHeight - 1 do
      begin
        PA := PRGBQuad(Result.ScanLine[Y]);
        PB := PRGBQuad(OnWhite.ScanLine[Y]);
        for X := 0 to AWidth - 1 do
        begin
          if (PA^.rgbRed = PB^.rgbRed) and (PA^.rgbGreen = PB^.rgbGreen) and
             (PA^.rgbBlue = PB^.rgbBlue) then
            PA^.rgbReserved := 255
          else
            PCardinal(PA)^ := 0;
          Inc(PA); Inc(PB);
        end;
      end;
    finally
      OnWhite.Free;
    end;
  except
    Result.Free;
    raise;
  end;
end;

{ Makes every pixel matching AColor fully transparent — the classic
  transparent-colour convention of TMenuItem.Bitmap. }
procedure ColorKeyGlyph(ABmp: TBitmap; AColor: TColor);
var
  X, Y: Integer;
  P: PRGBQuad;
  Rgb: COLORREF;
  KR, KG, KB: Byte;
begin
  Rgb := ColorToRGB(AColor);
  KR := GetRValue(Rgb); KG := GetGValue(Rgb); KB := GetBValue(Rgb);
  for Y := 0 to ABmp.Height - 1 do
  begin
    P := PRGBQuad(ABmp.ScanLine[Y]);
    for X := 0 to ABmp.Width - 1 do
    begin
      if (P^.rgbRed = KR) and (P^.rgbGreen = KG) and (P^.rgbBlue = KB) then
        PCardinal(P)^ := 0;
      Inc(P);
    end;
  end;
end;

{ ════════════════════════════════════════════════════════════════════════════
    Sesja flyoutu (lista otwartych okien) + hooki
  ════════════════════════════════════════════════════════════════════════════ }

function PointInAnyFly(const Pt: TPoint): Boolean;
var
  i: Integer;
begin
  Result := False;
  if GFlyOpen = nil then Exit;
  for i := 0 to GFlyOpen.Count - 1 do
    if PtInRect(GFlyOpen[i].BodyScreen, Pt) then Exit(True);
end;

function FlyMouseHookProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  MHS: ^TMouseHookStruct;
begin
  Result := CallNextHookEx(GFlyMouseHook, nCode, wParam, lParam);
  if (nCode >= HC_ACTION) and (GFlyRootWin <> nil) then
  begin
    case wParam of
      WM_LBUTTONDOWN, WM_RBUTTONDOWN, WM_MBUTTONDOWN,
      WM_NCLBUTTONDOWN, WM_NCRBUTTONDOWN, WM_NCMBUTTONDOWN:
      begin
        MHS := Pointer(lParam);
        if not PointInAnyFly(MHS^.pt) then
          GFlyRootWin.CloseChain;
      end;
    end;
  end;
end;

function FlyKeyHookProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  Result := CallNextHookEx(GFlyKeyHook, nCode, wParam, lParam);
  if (nCode = HC_ACTION) and (GFlyRootWin <> nil) and
     ((lParam and (1 shl 31)) = 0) then
  begin
    case wParam of
      VK_ESCAPE, VK_DOWN, VK_UP, VK_RETURN, VK_LEFT, VK_RIGHT,
      VK_HOME, VK_END, VK_TAB, VK_SPACE:
      begin
        GFlyRootWin.KeyAction(wParam);
        Result := 1;
      end;
    end;
  end;
end;

{ App deactivation (Alt+Tab, clicking another app) — close the flyout. }
procedure FlyWinEventProc(hHook: THandle; dwEvent: DWORD; hwnd: HWND;
  idObject, idChild: LongInt; idThread, dwmsTime: DWORD); stdcall;
begin
  if (dwEvent = EVENT_SYSTEM_FOREGROUND_) and (GFlyRootWin <> nil) then
    GFlyRootWin.CloseChain;
end;

procedure InstallFlyHooks(ARoot: TCWSFlyWindow);
begin
  GFlyRootWin := ARoot;
  if GFlyMouseHook = 0 then
    GFlyMouseHook := SetWindowsHookEx(WH_MOUSE, @FlyMouseHookProc, 0, GetCurrentThreadId);
  if GFlyKeyHook = 0 then
    GFlyKeyHook := SetWindowsHookEx(WH_KEYBOARD, @FlyKeyHookProc, 0, GetCurrentThreadId);
  if GFlyFgEventHook = 0 then
    GFlyFgEventHook := SetWinEventHook(EVENT_SYSTEM_FOREGROUND_, EVENT_SYSTEM_FOREGROUND_,
      0, @FlyWinEventProc, 0, 0, WINEVENT_OUTOFCONTEXT_);
end;

procedure UninstallFlyHooks;
begin
  GFlyRootWin := nil;
  if GFlyMouseHook <> 0 then begin UnhookWindowsHookEx(GFlyMouseHook); GFlyMouseHook := 0; end;
  if GFlyKeyHook <> 0 then begin UnhookWindowsHookEx(GFlyKeyHook); GFlyKeyHook := 0; end;
  if GFlyFgEventHook <> 0 then begin UnhookWinEvent(GFlyFgEventHook); GFlyFgEventHook := 0; end;
end;

{ ════════════════════════════════════════════════════════════════════════════
    TCWSFlyWindow
  ════════════════════════════════════════════════════════════════════════════ }

constructor TCWSFlyWindow.CreateForMenu(AMenu: TCWSFlayoutPopupMenu;
  ARoot: TMenuItem; AParent: TCWSFlyWindow; AIsBar: Boolean);
begin
  inherited Create(AMenu);
  FMenu := AMenu;
  FRoot := ARoot;
  FParentWin := AParent;
  FIsBar := AIsBar;
  FHotIndex := -1;
  FHotPrim := -1;
  FChildPrim := -1;
  FPendingClose := False;
  FPendingIdx := -1;
  FPendingPrim := -1;
  FScale := 1;
  FDpi := 96;
  { a submenu is always a plain vertical menu, so it is "expanded" by
    definition; the bar starts collapsed unless AutoExpand says otherwise }
  FExpanded := (not AIsBar) or AMenu.AutoExpand;
end;

destructor TCWSFlyWindow.Destroy;
begin
  StopScrollTimer;
  inherited;
end;

procedure TCWSFlyWindow.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := WS_POPUP;
  Params.ExStyle := WS_EX_TOOLWINDOW or WS_EX_TOPMOST or WS_EX_NOACTIVATE or
    WS_EX_LAYERED;
  Params.WndParent := GetDesktopWindow;
end;

procedure TCWSFlyWindow.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

procedure TCWSFlyWindow.WMPaint(var Msg: TWMPaint);
var
  PS: TPaintStruct;
begin
  BeginPaint(Handle, PS);
  EndPaint(Handle, PS);
  Msg.Result := 0;
end;

procedure TCWSFlyWindow.WMMouseActivate(var Msg: TWMMouseActivate);
begin
  Msg.Result := MA_NOACTIVATE;
end;

procedure TCWSFlyWindow.ComputeScale(const X, Y: Integer);
var
  Mon: TMonitor;
begin
  Mon := Screen.MonitorFromPoint(Point(X, Y));
  if Mon <> nil then FDpi := Mon.PixelsPerInch else FDpi := Screen.PixelsPerInch;
  if FDpi <= 0 then FDpi := 96;
  FScale := FDpi / 96;
end;

function TCWSFlyWindow.FontEmSize: Single;
begin
  { integral size in pixels — hinting works better than with a fractional
    em size (e.g. at 110% scaling) }
  if FMenu.Font.Size > 0 then Result := Round(FMenu.Font.Size * FDpi / 72)
  else Result := Round(Abs(FMenu.Font.Height) * FScale);
  if Result < 8 then Result := 8;
end;

function TCWSFlyWindow.MakeGdiFont: HFONT;
begin
  Result := MakeGdiFontEx(fsBold in FMenu.Font.Style);
end;

function TCWSFlyWindow.MakeGdiFontEx(ABold: Boolean): HFONT;
var
  LF: TLogFont;
begin
  FillChar(LF, SizeOf(LF), 0);
  LF.lfHeight := -Round(FontEmSize);
  if ABold then LF.lfWeight := FW_BOLD
  else LF.lfWeight := FW_NORMAL;
  LF.lfItalic := Byte(fsItalic in FMenu.Font.Style);
  LF.lfUnderline := Byte(fsUnderline in FMenu.Font.Style);
  LF.lfStrikeOut := Byte(fsStrikeOut in FMenu.Font.Style);
  LF.lfCharSet := DEFAULT_CHARSET;
  LF.lfOutPrecision := OUT_TT_PRECIS;
  LF.lfClipPrecision := CLIP_DEFAULT_PRECIS;
  LF.lfQuality := CLEARTYPE_QUALITY;
  LF.lfPitchAndFamily := DEFAULT_PITCH or FF_DONTCARE;
  StrPLCopy(LF.lfFaceName, FMenu.Font.Name, Length(LF.lfFaceName) - 1);
  Result := CreateFontIndirect(LF);
end;

{ Measured with the same engine that later draws (GDI), otherwise the widths
  drift apart and the longest item gets an ellipsis. }
function TCWSFlyWindow.MeasureTextW(ADC: HDC; const S: string): Integer;
var
  R: TRect;
begin
  if S = '' then Exit(0);
  R := Rect(0, 0, 0, 0);
  Winapi.Windows.DrawText(ADC, PChar(S), -1, R,
    DT_SINGLELINE or DT_CALCRECT or DT_NOCLIP);
  Result := (R.Right - R.Left) + Round(2 * FScale);
end;

function TCWSFlyWindow.MeasureTextH(ADC: HDC): Integer;
var
  TM: TTextMetric;
begin
  GetTextMetrics(ADC, TM);
  Result := TM.tmHeight;
end;

function TCWSFlyWindow.ShortCutOf(AItem: TMenuItem): string;
begin
  if AItem.ShortCut <> 0 then Result := ShortCutToText(AItem.ShortCut)
  else Result := '';
end;

function TCWSFlyWindow.HasSecondary: Boolean;
begin
  Result := Length(FSec) > 0;
end;

procedure TCWSFlyWindow.BuildEntries;
var
  Prim, Sec: TList<TMenuItem>;
  i, n, ItemH, SepH, CurTop: Integer;
begin
  SetLength(FPrim, 0);
  SetLength(FSec, 0);
  Prim := TList<TMenuItem>.Create;
  Sec := TList<TMenuItem>.Create;
  try
    if FIsBar then
      FMenu.SplitCommands(Prim, Sec)
    else
      for i := 0 to FRoot.Count - 1 do
        if FRoot.Items[i].Visible then Sec.Add(FRoot.Items[i]);

    { ── command bar ────────────────────────────────────────────────────── }
    SetLength(FPrim, Prim.Count);
    for i := 0 to Prim.Count - 1 do
    begin
      FPrim[i].Item := Prim[i];
      FPrim[i].More := False;
      FPrim[i].Separator := Prim[i].IsLine;
      FPrim[i].Left := 0;
      FPrim[i].Width := 0;
    end;
    { the "…" button only makes sense when there is a second level to reveal }
    if (Prim.Count > 0) and (Sec.Count > 0) and FMenu.ShowMoreButton then
    begin
      n := Length(FPrim);
      SetLength(FPrim, n + 1);
      FPrim[n].Item := nil;
      FPrim[n].More := True;
      FPrim[n].Separator := False;
      FPrim[n].Left := 0;
      FPrim[n].Width := 0;
    end;

    { With no primary commands the flyout degenerates to a plain menu: no bar,
      nothing to expand. }
    if Length(FPrim) = 0 then FExpanded := True;

    { ── vertical list ──────────────────────────────────────────────────── }
    ItemH := Round(FMenu.ItemHeight * FScale);
    SepH := Round(9 * FScale);
    CurTop := 0;
    SetLength(FSec, Sec.Count);
    for i := 0 to Sec.Count - 1 do
    begin
      FSec[i].Item := Sec[i];
      FSec[i].Separator := Sec[i].IsLine;
      FSec[i].Top := CurTop;
      if FSec[i].Separator then FSec[i].Height := SepH
      else FSec[i].Height := ItemH;
      Inc(CurTop, FSec[i].Height);
    end;
    FContentH := CurTop;
  finally
    Sec.Free;
    Prim.Free;
  end;
end;

procedure TCWSFlyWindow.Measure;
var
  ScreenDC, MemDC: HDC;
  GdiFont, GdiFontBold: HFONT;
  i, IconArea, RightPad, MinW, MaxH, ListMaxH, ListH, ListW: Integer;
  MaxCap, MaxSc, W: Integer;
  HasSub, HasSc: Boolean;
  ShortcutAreaW, SubArrowW: Integer;
  It: TMenuItem;
  Mon: HMONITOR;
  MI: TMonitorInfo;
  TxtH, BtnPadH, BarPadH, BarPadV, GapIL, MinBtnW, MoreW, SepW, X: Integer;
begin
  IconArea := Round(40 * FScale);
  RightPad := Round(14 * FScale);
  MinW     := Round(150 * FScale);
  FVPad    := Round(4 * FScale);
  FArrowH  := Round(20 * FScale);

  BarPadH  := Round(4 * FScale);
  BarPadV  := Round(4 * FScale);
  BtnPadH  := Round(10 * FScale);
  GapIL    := Round(6 * FScale);
  MinBtnW  := Round(Max(24, FMenu.PrimaryButtonWidth) * FScale);
  MoreW    := Round(44 * FScale);
  SepW     := Round(11 * FScale);
  FIconSize := Round(Max(8, FMenu.PrimaryIconSize) * FScale);

  if FMenu.ShadowEnabled then
  begin
    FBlur := Max(2, Round(FMenu.ShadowSize * FScale));
    FShadowOffset := Round(5 * FScale);
    FShadow := FBlur + FShadowOffset + Round(4 * FScale);
  end
  else begin FBlur := 0; FShadowOffset := 0; FShadow := 0; end;

  BuildEntries;

  MaxCap := 0; MaxSc := 0; HasSub := False; HasSc := False; TxtH := 0;
  ScreenDC := GetDC(0);
  MemDC := CreateCompatibleDC(ScreenDC);
  GdiFont := MakeGdiFont;
  GdiFontBold := MakeGdiFontEx(True);
  SaveDC(MemDC);
  try
    SelectObject(MemDC, GdiFont);
    TxtH := MeasureTextH(MemDC);

    { bar buttons — width follows the caption, never below the minimum }
    for i := 0 to High(FPrim) do
    begin
      if FPrim[i].Separator then
      begin
        { the rule itself is one device pixel — the width is the air around it }
        FPrim[i].Width := SepW;
        Continue;
      end;
      if FPrim[i].More then
      begin
        FPrim[i].Width := MoreW;
        Continue;
      end;
      if FMenu.LabelPosition = lpCollapsed then
        FPrim[i].Width := Max(MinBtnW, FIconSize + BtnPadH * 2)
      else
      begin
        W := MeasureTextW(MemDC, FPrim[i].Item.Caption);
        FPrim[i].Width := Max(MinBtnW, W + BtnPadH * 2);
      end;
    end;

    { vertical list }
    for i := 0 to High(FSec) do
    begin
      It := FSec[i].Item;
      if FSec[i].Separator then Continue;
      { the default item is drawn in bold — measure it the same way }
      if It.Default then SelectObject(MemDC, GdiFontBold)
      else SelectObject(MemDC, GdiFont);
      W := MeasureTextW(MemDC, It.Caption);
      if W > MaxCap then MaxCap := W;
      if It.Count > 0 then HasSub := True;
      if ShortCutOf(It) <> '' then
      begin
        HasSc := True;
        W := MeasureTextW(MemDC, ShortCutOf(It));
        if W > MaxSc then MaxSc := W;
      end;
    end;
  finally
    RestoreDC(MemDC, -1);
    DeleteObject(GdiFont);
    DeleteObject(GdiFontBold);
    DeleteDC(MemDC);
    ReleaseDC(0, ScreenDC);
  end;

  { ── height of the bar ──────────────────────────────────────────────────── }
  if Length(FPrim) = 0 then
  begin
    FBtnH := 0;
    FBarH := 0;
  end
  else
  begin
    if FMenu.LabelPosition = lpCollapsed then
      FBtnH := FIconSize + Round(10 * FScale) * 2
    else
      FBtnH := FIconSize + GapIL + TxtH + Round(8 * FScale) * 2;
    FBarH := FBtnH + BarPadV * 2;
  end;

  { ── widths ─────────────────────────────────────────────────────────────── }
  FBarW := BarPadH * 2;
  for i := 0 to High(FPrim) do Inc(FBarW, FPrim[i].Width);

  if Length(FSec) > 0 then
  begin
    SubArrowW := IfThen(HasSub, Round(20 * FScale), 0);
    ShortcutAreaW := IfThen(HasSc, Round(24 * FScale) + MaxSc, 0);
    ListW := IconArea + MaxCap + ShortcutAreaW + SubArrowW + RightPad;
    if ListW < MinW then ListW := MinW;
  end
  else
    ListW := 0;

  if Length(FPrim) = 0 then FBodyW := ListW
  else if FExpanded then FBodyW := Max(FBarW, ListW)
  else FBodyW := FBarW;

  { Button positions. The commands stay left aligned; the "…" button is pinned
    to the right edge of the bar, as in the WinUI CommandBarFlyout. }
  X := BarPadH;
  for i := 0 to High(FPrim) do
  begin
    if FPrim[i].More then
      FPrim[i].Left := FBodyW - BarPadH - FPrim[i].Width
    else
    begin
      FPrim[i].Left := X;
      Inc(X, FPrim[i].Width);
    end;
  end;

  { ── height of the list ─────────────────────────────────────────────────── }
  Mon := MonitorFromWindow(Handle, MONITOR_DEFAULTTONEAREST);
  MI.cbSize := SizeOf(MI);
  GetMonitorInfo(Mon, @MI);
  MaxH := (MI.rcWork.Bottom - MI.rcWork.Top) - Round(8 * FScale);
  if FMenu.MaxVisibleItems > 0 then
    MaxH := Min(MaxH, FMenu.MaxVisibleItems * Round(FMenu.ItemHeight * FScale)
      + FVPad * 2 + FBarH);

  if (not FExpanded) or (Length(FSec) = 0) then
  begin
    FScrolling := False;
    FViewH := 0;
    FMaxScroll := 0;
    FScrollPos := 0;
    ListH := 0;
  end
  else
  begin
    ListMaxH := Max(Round(FMenu.ItemHeight * FScale) + FVPad * 2, MaxH - FBarH);
    if FContentH + FVPad * 2 <= ListMaxH then
    begin
      FScrolling := False;
      ListH := FContentH + FVPad * 2;
      FViewH := FContentH;
      FMaxScroll := 0;
    end
    else
    begin
      FScrolling := True;
      ListH := ListMaxH;
      FViewH := ListMaxH - FVPad * 2 - FArrowH * 2;
      if FViewH < Round(FMenu.ItemHeight * FScale) then
        FViewH := Round(FMenu.ItemHeight * FScale);
      FMaxScroll := Max(0, FContentH - FViewH);
    end;
  end;
  FScrollPos := EnsureRange(FScrollPos, 0, FMaxScroll);

  FBodyH := FBarH + ListH;
  FWinW := FBodyW + FShadow * 2;
  FWinH := FBodyH + FShadow * 2;
end;

{ Top of the command bar, in client coordinates. When the list opened upwards
  the bar sits at the bottom of the body and keeps its place on screen. }
function TCWSFlyWindow.BarTop: Integer;
begin
  if FBarH = 0 then Result := FShadow
  else if FBarAtBottom then Result := FShadow + FBodyH - FBarH
  else Result := FShadow;
end;

{ Top of the block of secondary commands, in client coordinates. }
function TCWSFlyWindow.ListTop: Integer;
begin
  if FBarAtBottom then Result := FShadow
  else Result := FShadow + FBarH;
end;

function TCWSFlyWindow.ContentTop: Integer;
begin
  Result := ListTop + FVPad;
  if FScrolling then Inc(Result, FArrowH);
end;

function TCWSFlyWindow.EntryClientTop(AIdx: Integer): Integer;
begin
  Result := ContentTop + FSec[AIdx].Top - FScrollPos;
end;

function TCWSFlyWindow.PrimRect(AIdx: Integer): TRect;
var
  T: Integer;
begin
  T := BarTop + (FBarH - FBtnH) div 2;
  Result := Rect(FShadow + FPrim[AIdx].Left, T,
                 FShadow + FPrim[AIdx].Left + FPrim[AIdx].Width, T + FBtnH);
end;

{ Whether the item has its own image (imagelist or bitmap). When it does, the
  check mark is not drawn, just like in the VCL TPopupMenu. }
function TCWSFlyWindow.ItemHasGlyph(AItem: TMenuItem): Boolean;
begin
  Result := ((FMenu.Images <> nil) and (AItem.ImageIndex >= 0) and
             (AItem.ImageIndex < FMenu.Images.Count) and
             (FMenu.Images.Width > 0) and (FMenu.Images.Height > 0)) or
            ((AItem.Bitmap <> nil) and not AItem.Bitmap.Empty and
             (AItem.Bitmap.Width > 0) and (AItem.Bitmap.Height > 0));
end;

procedure TCWSFlyWindow.DrawIcon(G: TGPGraphics; AItem: TMenuItem;
  const ADest: TRect; AEnabled: Boolean);
var
  Glyph: TBitmap;
  GpImg: TGPBitmap;
  Bmp: TBitmap;
  Idx: Integer;
begin
  Glyph := nil;
  Idx := AItem.ImageIndex;
  if (FMenu.Images <> nil) and (Idx >= 0) and (Idx < FMenu.Images.Count) and
     (FMenu.Images.Width > 0) and (FMenu.Images.Height > 0) then
    Glyph := RenderGlyph(FMenu.Images.Width, FMenu.Images.Height,
      procedure (ACanvas: TCanvas)
      begin
        FMenu.Images.Draw(ACanvas, 0, 0, Idx, AEnabled);
      end)
  else if (AItem.Bitmap <> nil) and not AItem.Bitmap.Empty and
          (AItem.Bitmap.Width > 0) and (AItem.Bitmap.Height > 0) then
  begin
    Bmp := AItem.Bitmap;
    Glyph := RenderGlyph(Bmp.Width, Bmp.Height,
      procedure (ACanvas: TCanvas)
      begin
        ACanvas.Draw(0, 0, Bmp);
      end);
    { A glyph without an alpha channel is keyed on its transparent colour. }
    if (Bmp.PixelFormat <> pf32bit) or (Bmp.AlphaFormat = afIgnored) then
      ColorKeyGlyph(Glyph, Bmp.TransparentColor);
  end;

  if Glyph = nil then Exit;
  try
    GpImg := TGPBitmap.Create(Glyph.Width, Glyph.Height, -Glyph.Width * 4,
      PixelFormat32bppPARGB, Glyph.ScanLine[0]);
    try
      if GpImg.GetLastStatus <> Ok then Exit;
      if (Glyph.Width <> ADest.Width) or (Glyph.Height <> ADest.Height) then
        G.SetInterpolationMode(InterpolationModeHighQualityBicubic)
      else
        G.SetInterpolationMode(InterpolationModeNearestNeighbor);
      try
        G.DrawImage(GpImg, ADest.Left, ADest.Top, ADest.Width, ADest.Height);
      finally
        G.SetInterpolationMode(InterpolationModeDefault);
      end;
    finally
      GpImg.Free;
    end;
  finally
    Glyph.Free;
  end;
end;

procedure TCWSFlyWindow.Render;
var
  BI: TBitmapInfo;
  Bits: Pointer;
  HBmp, OldBmp: HBITMAP;
  MemDC, ScreenDC: HDC;
  GBmp: TGPBitmap;
  G: TGPGraphics;
  Path: TGPGraphicsPath;
  Brush: TGPSolidBrush;
  Pen: TGPPen;
  i, N, A, ListH: Integer;
  Radius, BodyX, BodyY, SepY: Single;
  Border, IconSize, IconArea, HlInsetX, HlInsetY, SepThick: Integer;
  It: TMenuItem;
  ItemTop, ItemH: Integer;
  R, TR, BR: TRect;
  IconRect: TRect;
  TxtColor, ShCol: TColor;
  Sc: string;
  Blend: TBlendFunction;
  PtSrc: TPoint;
  Sz: TSize;
  CovA, ShBits, SavedA: TBytes;
  ShImg: TGPBitmap;
  CY, ChevX, ChevSz, DotSz, MarkX, DotR, DotGap, SepX: Single;
  EmSz, ArmS, ArmL, VX, VY: Single;
  Thick, GapIL, SepInset: Integer;
  GdiFont, GdiFontBold: HFONT;
  PB: PByte;
begin
  if not HandleAllocated then Exit;
  if (FWinW < 1) or (FWinH < 1) then Exit;

  FillChar(BI, SizeOf(BI), 0);
  BI.bmiHeader.biSize := SizeOf(TBitmapInfoHeader);
  BI.bmiHeader.biWidth := FWinW;
  BI.bmiHeader.biHeight := -FWinH;
  BI.bmiHeader.biPlanes := 1;
  BI.bmiHeader.biBitCount := 32;
  BI.bmiHeader.biCompression := BI_RGB;

  HBmp := CreateDIBSection(0, BI, DIB_RGB_COLORS, Bits, 0, 0);
  if HBmp = 0 then Exit;
  MemDC := CreateCompatibleDC(0);
  OldBmp := SelectObject(MemDC, HBmp);
  try
    IconSize := Round(16 * FScale);
    IconArea := Round(40 * FScale);
    HlInsetX := Round(4 * FScale);
    HlInsetY := Round(2 * FScale);
    GapIL := Round(6 * FScale);
    Radius := FMenu.CornerRadius * FScale;
    Border := Max(1, Round(FMenu.BorderThickness * FScale));
    BodyX := FShadow; BodyY := FShadow;
    ListH := FBodyH - FBarH;

    { ══ warstwa 1: tlo, obramowanie, ikony, strzalki — GDI+ ═══════════════ }
    GBmp := TGPBitmap.Create(FWinW, FWinH, FWinW * 4, PixelFormat32bppPARGB, Bits);
    G := TGPGraphics.Create(GBmp);
    try
      G.SetSmoothingMode(SmoothingModeAntiAlias);
      G.SetPixelOffsetMode(PixelOffsetModeHighQuality);
      G.Clear(MakeColor(0, 0, 0, 0));

      { ── shadow ──────────────────────────────────────────────────────────── }
      if FMenu.ShadowEnabled and (FShadow > 0) and (FBlur > 0) then
      begin
        N := FWinW * FWinH;
        SetLength(CovA, N);
        RasterRoundRectAlpha(@CovA[0], FWinW, FWinH,
          FShadow, FShadow + FShadowOffset, FBodyW, FBodyH, Round(Radius));
        BoxBlurAlpha(@CovA[0], FWinW, FWinH, Max(1, FBlur div 3), 3);
        SetLength(ShBits, N * 4);
        for i := 0 to N - 1 do
        begin
          A := CovA[i] * MENU_SHADOW_ALPHA div 255;
          ShBits[i * 4 + 3] := A;
        end;
        ShImg := TGPBitmap.Create(FWinW, FWinH, FWinW * 4, PixelFormat32bppPARGB, @ShBits[0]);
        try G.DrawImage(ShImg, 0, 0, FWinW, FWinH); finally ShImg.Free; end;
      end;

      { ── korpus ──────────────────────────────────────────────────────────── }
      Path := CreateRRPath(BodyX, BodyY, FBodyW, FBodyH, Radius);
      Brush := TGPSolidBrush.Create(GPColor(FMenu.BackgroundColor));
      try G.FillPath(Brush, Path); finally Brush.Free; Path.Free; end;

      { ── tlo poziomu drugiego ────────────────────────────────────────────
        Only painted when SecondaryBackgroundColor differs from the body
        colour; by default the two levels share one surface. The block is
        rounded along the outer edge of the flyout only — the edge that meets
        the command bar stays square. }
      if (FBarH > 0) and (ListH > 0) and
         (FMenu.SecondaryBackgroundColor <> FMenu.BackgroundColor) then
      begin
        if FBarAtBottom then
          Path := CreateRRPath2(BodyX, ListTop, FBodyW, ListH, Radius, 0)
        else
          Path := CreateRRPath2(BodyX, ListTop, FBodyW, ListH, 0, Radius);
        Brush := TGPSolidBrush.Create(GPColor(FMenu.SecondaryBackgroundColor));
        try G.FillPath(Brush, Path); finally Brush.Free; Path.Free; end;
      end;

      { ── linia miedzy paskiem a lista ────────────────────────────────────── }
      if (FBarH > 0) and (ListH > 0) then
      begin
        SepThick := Max(1, Round(FScale));
        if FBarAtBottom then SepY := BarTop - SepThick / 2
        else SepY := ListTop - SepThick / 2;
        Pen := TGPPen.Create(GPColor(FMenu.SeparatorColor), SepThick);
        try
          G.DrawLine(Pen, Single(BodyX + Border), SepY,
            Single(BodyX + FBodyW - Border), SepY);
        finally Pen.Free; end;
      end;

      { ── obramowanie ─────────────────────────────────────────────────────── }
      if Border > 0 then
      begin
        Path := CreateRRPath(BodyX + Border / 2, BodyY + Border / 2,
          FBodyW - Border, FBodyH - Border, Radius - Border / 2);
        Pen := TGPPen.Create(GPColor(FMenu.BorderColor), Border);
        try G.DrawPath(Pen, Path); finally Pen.Free; Path.Free; end;
      end;

      { ── polecenia podstawowe (pasek) ────────────────────────────────────── }
      for i := 0 to High(FPrim) do
      begin
        BR := PrimRect(i);

        { ── AppBarSeparator — a vertical rule between groups of commands ──
          Snapped to whole device pixels for the same reason as the horizontal
          one in the list: a 1 px line centred on a pixel boundary would be
          split across two columns at half intensity. It is inset top and
          bottom, so it reads as a rule between buttons rather than a full
          height division of the bar. }
        if FPrim[i].Separator then
        begin
          SepThick := Max(1, Round(FScale));
          SepX := Floor((BR.Left + BR.Right - SepThick) / 2) + SepThick / 2;
          SepInset := Max(Round(2 * FScale), FBtnH div 5);
          Pen := TGPPen.Create(GPColor(FMenu.SeparatorColor), SepThick);
          try
            G.DrawLine(Pen, SepX, Single(BR.Top + SepInset),
              SepX, Single(BR.Bottom - SepInset));
          finally Pen.Free; end;
          Continue;
        end;

        if i = FHotPrim then
        begin
          Path := CreateRRPath(BR.Left + HlInsetY, BR.Top + HlInsetY,
            BR.Width - HlInsetY * 2, BR.Height - HlInsetY * 2, Round(5 * FScale));
          Brush := TGPSolidBrush.Create(GPColor(FMenu.HighlightColor));
          try G.FillPath(Brush, Path); finally Brush.Free; Path.Free; end;
        end;

        if FPrim[i].More then
        begin
          { "See more" — three dots, drawn vectorially so they stay crisp at
            every scaling }
          ShCol := FMenu.TextColor;
          DotR := Max(1.2, 1.6 * FScale);
          DotGap := Round(6 * FScale);
          CY := (BR.Top + BR.Bottom) / 2;
          MarkX := (BR.Left + BR.Right) / 2;
          Brush := TGPSolidBrush.Create(GPColor(ShCol));
          try
            G.FillEllipse(Brush, MarkX - DotGap - DotR, CY - DotR, DotR * 2, DotR * 2);
            G.FillEllipse(Brush, MarkX - DotR, CY - DotR, DotR * 2, DotR * 2);
            G.FillEllipse(Brush, MarkX + DotGap - DotR, CY - DotR, DotR * 2, DotR * 2);
          finally Brush.Free; end;
          Continue;
        end;

        It := FPrim[i].Item;
        if FMenu.LabelPosition = lpCollapsed then
          IconRect := Rect(
            BR.Left + (BR.Width - FIconSize) div 2,
            BR.Top + (BR.Height - FIconSize) div 2,
            BR.Left + (BR.Width - FIconSize) div 2 + FIconSize,
            BR.Top + (BR.Height - FIconSize) div 2 + FIconSize)
        else
          IconRect := Rect(
            BR.Left + (BR.Width - FIconSize) div 2,
            BR.Top + Round(8 * FScale),
            BR.Left + (BR.Width - FIconSize) div 2 + FIconSize,
            BR.Top + Round(8 * FScale) + FIconSize);
        DrawIcon(G, It, IconRect, It.Enabled);

        { a bar button that carries a submenu gets the small chevron of an
          AppBarButton with an attached flyout }
        if It.Count > 0 then
        begin
          if It.Enabled then ShCol := FMenu.TextColor
          else ShCol := FMenu.DisabledTextColor;
          ChevSz := 3 * FScale;
          ChevX := BR.Right - Round(7 * FScale);
          CY := BR.Bottom - Round(6 * FScale);
          Pen := TGPPen.Create(GPColor(ShCol), 1.3 * FScale);
          try
            G.DrawLine(Pen, ChevX - ChevSz, CY - ChevSz / 2, ChevX, CY + ChevSz / 2);
            G.DrawLine(Pen, ChevX, CY + ChevSz / 2, ChevX + ChevSz, CY - ChevSz / 2);
          finally Pen.Free; end;
        end;
      end;

      { ── polecenia dodatkowe (lista) ─────────────────────────────────────── }
      if ListH > 0 then
      begin
        { przytnij rysowanie pozycji do obszaru widoku }
        G.SetClip(MakeRect(Single(BodyX), Single(ContentTop),
          Single(FBodyW), Single(FViewH)));

        for i := 0 to High(FSec) do
        begin
          It := FSec[i].Item;
          ItemTop := EntryClientTop(i);
          ItemH := FSec[i].Height;
          if (ItemTop + ItemH < ContentTop) or (ItemTop > ContentTop + FViewH) then
            Continue;
          R := Rect(Round(BodyX), ItemTop, Round(BodyX) + FBodyW, ItemTop + ItemH);

          if FSec[i].Separator then
          begin
            { snap the rule to whole device pixels — a 1 px line centred on a
              pixel boundary would be split across two rows at half intensity }
            SepThick := Max(1, Round(FScale));
            SepY := Floor((R.Top + R.Bottom - SepThick) / 2) + SepThick / 2;
            Pen := TGPPen.Create(GPColor(FMenu.SeparatorColor), SepThick);
            try
              G.DrawLine(Pen, Single(BodyX + Border), SepY,
                Single(BodyX + FBodyW - Border), SepY);
            finally Pen.Free; end;
            Continue;
          end;

          if i = FHotIndex then
          begin
            Path := CreateRRPath(R.Left + HlInsetX, R.Top + HlInsetY,
              FBodyW - HlInsetX * 2, ItemH - HlInsetY * 2, Round(5 * FScale));
            Brush := TGPSolidBrush.Create(GPColor(FMenu.HighlightColor));
            try G.FillPath(Brush, Path); finally Brush.Free; Path.Free; end;
          end;

          IconRect := Rect(
            R.Left + (IconArea - IconSize) div 2, R.Top + (ItemH - IconSize) div 2,
            R.Left + (IconArea - IconSize) div 2 + IconSize,
            R.Top + (ItemH - IconSize) div 2 + IconSize);
          DrawIcon(G, It, IconRect, It.Enabled);

          { ── check mark — vector, scales with DPI, only when the item has no
            image of its own (as in the VCL). RadioItem gets a dot. ───────── }
          if It.Checked and not ItemHasGlyph(It) then
          begin
            if not It.Enabled then ShCol := FMenu.DisabledTextColor
            else if i = FHotIndex then ShCol := FMenu.HighlightTextColor
            else ShCol := FMenu.TextColor;
            MarkX := R.Left + IconArea / 2;
            CY := (R.Top + R.Bottom) / 2;
            EmSz := FontEmSize;
            if It.RadioItem then
            begin
              DotSz := Max(3.0, 0.42 * EmSz);
              Brush := TGPSolidBrush.Create(GPColor(ShCol));
              try
                G.FillEllipse(Brush, Single(MarkX - DotSz / 2),
                  Single(CY - DotSz / 2), Single(DotSz), Single(DotSz));
              finally Brush.Free; end;
            end
            else
            begin
              { Windows 11 CheckMark glyph (U+E73E), reproduced from the native
                menu: both arms at 45°, short 0.20 em, long 0.44 em, mitered
                vertex, square ends, thickness in whole device pixels. }
              ArmS := 0.20 * EmSz;
              ArmL := 0.44 * EmSz;
              VX := MarkX - (ArmL - ArmS) / 2;
              VY := CY + ArmL / 2;
              Thick := Max(1, Round(0.085 * EmSz));
              Pen := TGPPen.Create(GPColor(ShCol), Thick);
              try
                Pen.SetStartCap(LineCapFlat);
                Pen.SetEndCap(LineCapFlat);
                Pen.SetLineJoin(LineJoinMiter);
                Path := TGPGraphicsPath.Create;
                try
                  Path.StartFigure;
                  Path.AddLine(VX - ArmS, VY - ArmS, VX, VY);
                  Path.AddLine(VX, VY, VX + ArmL, VY - ArmL);
                  G.DrawPath(Pen, Path);
                finally Path.Free; end;
              finally Pen.Free; end;
            end;
          end;

          { submenu arrow }
          if It.Count > 0 then
          begin
            if It.Enabled then ShCol := FMenu.TextColor
            else ShCol := FMenu.DisabledTextColor;
            ChevSz := 4 * FScale;
            ChevX := R.Right - Round(14 * FScale);
            CY := (R.Top + R.Bottom) / 2;
            Pen := TGPPen.Create(GPColor(ShCol), 1.4 * FScale);
            try
              G.DrawLine(Pen, ChevX - ChevSz / 2, CY - ChevSz, ChevX + ChevSz / 2, CY);
              G.DrawLine(Pen, ChevX + ChevSz / 2, CY, ChevX - ChevSz / 2, CY + ChevSz);
            finally Pen.Free; end;
          end;
        end;

        G.ResetClip;

        { ── scroll arrows ─────────────────────────────────────────────────── }
        if FScrolling then
        begin
          ChevX := BodyX + FBodyW / 2;
          ChevSz := 5 * FScale;
          { top }
          if FScrollPos > 0 then ShCol := FMenu.TextColor else ShCol := FMenu.DisabledTextColor;
          CY := ListTop + FVPad + FArrowH / 2;
          Pen := TGPPen.Create(GPColor(ShCol), 1.4 * FScale);
          try
            G.DrawLine(Pen, ChevX - ChevSz, CY + ChevSz / 2, ChevX, CY - ChevSz / 2);
            G.DrawLine(Pen, ChevX, CY - ChevSz / 2, ChevX + ChevSz, CY + ChevSz / 2);
          finally Pen.Free; end;
          { bottom }
          if FScrollPos < FMaxScroll then ShCol := FMenu.TextColor else ShCol := FMenu.DisabledTextColor;
          CY := ListTop + ListH - FVPad - FArrowH / 2;
          Pen := TGPPen.Create(GPColor(ShCol), 1.4 * FScale);
          try
            G.DrawLine(Pen, ChevX - ChevSz, CY - ChevSz / 2, ChevX, CY + ChevSz / 2);
            G.DrawLine(Pen, ChevX, CY + ChevSz / 2, ChevX + ChevSz, CY - ChevSz / 2);
          finally Pen.Free; end;
        end;
      end;

      G.Flush(FlushIntentionSync);
    finally
      G.Free; GBmp.Free;
    end;

    { ══ layer 2: captions — GDI with ClearType ════════════════════════════
      GDI+ silently drops ClearType on a bitmap with an alpha channel, so the
      text goes through plain GDI straight into the DIB. GDI zeroes the alpha
      of the glyph pixels, so the channel is saved first and restored after. }
    N := FWinW * FWinH;
    SetLength(SavedA, N);
    PB := Bits; Inc(PB, 3);
    for i := 0 to N - 1 do
    begin
      SavedA[i] := PB^;
      Inc(PB, 4);
    end;

    GdiFont := MakeGdiFont;
    GdiFontBold := MakeGdiFontEx(True);
    SaveDC(MemDC);
    try
      SelectObject(MemDC, GdiFont);
      SetBkMode(MemDC, TRANSPARENT);

      { ── podpisy przyciskow paska ─────────────────────────────────────── }
      if FMenu.LabelPosition = lpBottom then
        for i := 0 to High(FPrim) do
        begin
          if FPrim[i].More or FPrim[i].Separator then Continue;
          It := FPrim[i].Item;
          BR := PrimRect(i);
          if It.Enabled then
          begin
            if i = FHotPrim then TxtColor := FMenu.HighlightTextColor
            else TxtColor := FMenu.TextColor;
          end
          else TxtColor := FMenu.DisabledTextColor;
          SetTextColor(MemDC, ColorToRGB(TxtColor));
          TR := Rect(BR.Left + Round(2 * FScale),
                     BR.Top + Round(8 * FScale) + FIconSize + GapIL,
                     BR.Right - Round(2 * FScale), BR.Bottom);
          Winapi.Windows.DrawText(MemDC, PChar(It.Caption), -1, TR,
            DT_SINGLELINE or DT_TOP or DT_CENTER or DT_END_ELLIPSIS);
        end;

      { ── podpisy listy ────────────────────────────────────────────────── }
      if ListH > 0 then
      begin
        SaveDC(MemDC);
        try
          IntersectClipRect(MemDC, Round(BodyX), ContentTop,
            Round(BodyX) + FBodyW, ContentTop + FViewH);

          for i := 0 to High(FSec) do
          begin
            if FSec[i].Separator then Continue;
            It := FSec[i].Item;
            ItemTop := EntryClientTop(i);
            ItemH := FSec[i].Height;
            if (ItemTop + ItemH < ContentTop) or (ItemTop > ContentTop + FViewH) then
              Continue;
            R := Rect(Round(BodyX), ItemTop, Round(BodyX) + FBodyW, ItemTop + ItemH);

            if It.Enabled then
            begin
              if i = FHotIndex then TxtColor := FMenu.HighlightTextColor
              else TxtColor := FMenu.TextColor;
            end
            else TxtColor := FMenu.DisabledTextColor;

            { the default item (Default) — bold, as in the Windows menu }
            if It.Default then SelectObject(MemDC, GdiFontBold)
            else SelectObject(MemDC, GdiFont);

            TR := Rect(R.Left + IconArea, R.Top,
                       R.Right - Round(14 * FScale), R.Bottom);

            { '&' = akcelerator (podkreslenie litery), '&&' = zwykly znak & }
            SetTextColor(MemDC, ColorToRGB(TxtColor));
            Winapi.Windows.DrawText(MemDC, PChar(It.Caption), -1, TR,
              DT_SINGLELINE or DT_VCENTER or DT_LEFT or DT_END_ELLIPSIS);

            { keyboard shortcut }
            Sc := ShortCutOf(It);
            if (Sc <> '') and (It.Count = 0) then
            begin
              if It.Enabled then ShCol := FMenu.ShortCutColor
              else ShCol := FMenu.DisabledTextColor;
              SelectObject(MemDC, GdiFont);
              SetTextColor(MemDC, ColorToRGB(ShCol));
              TR := Rect(R.Left + IconArea, R.Top,
                         R.Right - Round(14 * FScale), R.Bottom);
              Winapi.Windows.DrawText(MemDC, PChar(Sc), -1, TR,
                DT_SINGLELINE or DT_VCENTER or DT_RIGHT or DT_NOPREFIX);
            end;
          end;
        finally
          RestoreDC(MemDC, -1);
        end;
      end;
    finally
      RestoreDC(MemDC, -1);
      DeleteObject(GdiFont);
      DeleteObject(GdiFontBold);
    end;
    GdiFlush;

    PB := Bits; Inc(PB, 3);
    for i := 0 to N - 1 do
    begin
      PB^ := SavedA[i];
      Inc(PB, 4);
    end;

    ScreenDC := GetDC(0);
    try
      Blend.BlendOp := AC_SRC_OVER;
      Blend.BlendFlags := 0;
      Blend.SourceConstantAlpha := 255;
      Blend.AlphaFormat := AC_SRC_ALPHA;
      Sz.cx := FWinW; Sz.cy := FWinH;
      PtSrc := Point(0, 0);
      UpdateLayeredWindow(Handle, ScreenDC, nil, @Sz, MemDC, @PtSrc, 0, @Blend, ULW_ALPHA);
    finally
      ReleaseDC(0, ScreenDC);
    end;
  finally
    SelectObject(MemDC, OldBmp);
    DeleteDC(MemDC);
    DeleteObject(HBmp);
  end;
end;

{ ── umiejscowienie okna ──────────────────────────────────────────────────── }

procedure TCWSFlyWindow.Place;
var
  Mon: HMONITOR;
  MI: TMonitorInfo;
  WR: TRect;
  BodyLeft, BodyTop: Integer;
begin
  Mon := MonitorFromPoint(FAnchor, MONITOR_DEFAULTTONEAREST);
  MI.cbSize := SizeOf(MI);
  GetMonitorInfo(Mon, @MI);
  WR := MI.rcWork;

  FBarAtBottom := False;
  BodyLeft := FAnchor.X;
  BodyTop := FAnchor.Y;

  if BodyLeft + FBodyW > WR.Right then
  begin
    if FParentWin <> nil then
      BodyLeft := FParentWin.FBodyScreen.Left - FBodyW + Round(4 * FScale)
    else
      BodyLeft := WR.Right - FBodyW;
  end;
  if BodyLeft < WR.Left then BodyLeft := WR.Left;

  if BodyTop + FBodyH > WR.Bottom then
  begin
    { The list of secondary commands does not fit below — open it upwards and
      leave the command bar exactly where it was, the way the WinUI flyout
      behaves near the bottom edge of the screen. }
    if (FBarH > 0) and (FBodyH > FBarH) and
       (FAnchor.Y + FBarH - FBodyH >= WR.Top) then
    begin
      FBarAtBottom := True;
      BodyTop := FAnchor.Y + FBarH - FBodyH;
    end
    else
      BodyTop := WR.Bottom - FBodyH;
  end;
  if BodyTop < WR.Top then BodyTop := WR.Top;

  FWinLeft := BodyLeft - FShadow;
  FWinTop := BodyTop - FShadow;
  FBodyScreen := Rect(BodyLeft, BodyTop, BodyLeft + FBodyW, BodyTop + FBodyH);
end;

procedure TCWSFlyWindow.ShowAt(X, Y: Integer);
begin
  HandleNeeded;
  FHotIndex := -1;
  FHotPrim := -1;
  FChildPrim := -1;
  FScrollPos := 0;
  FPendingClose := False;
  FPendingIdx := -1;
  FPendingPrim := -1;
  FAnchor := Point(X, Y);
  ComputeScale(X, Y);
  Measure;
  if (Length(FPrim) = 0) and (Length(FSec) = 0) then Exit;

  Place;

  SetWindowPos(Handle, HWND_TOPMOST, FWinLeft, FWinTop, FWinW, FWinH,
    SWP_NOACTIVATE or SWP_HIDEWINDOW);
  Render;
  ShowWindow(Handle, SW_SHOWNOACTIVATE);
  SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0,
    SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);

  if GFlyOpen <> nil then GFlyOpen.Add(Self);
end;

{ Shows or hides the second command level. The bar keeps its position on
  screen; only the list appears below (or above) it. }
procedure TCWSFlyWindow.SetExpanded(AValue: Boolean);
begin
  if (FExpanded = AValue) or (not FIsBar) or (Length(FPrim) = 0) then Exit;
  CloseChild;
  FExpanded := AValue;
  FHotIndex := -1;
  FScrollPos := 0;
  Measure;
  Place;
  SetWindowPos(Handle, HWND_TOPMOST, FWinLeft, FWinTop, FWinW, FWinH,
    SWP_NOACTIVATE);
  Render;
  FMenu.DoExpandChanged;
end;

procedure TCWSFlyWindow.CloseChild;
begin
  if FChildWin <> nil then
  begin
    FChildWin.CloseChain;
    FChildWin := nil;
  end;
  FChildPrim := -1;
end;

procedure TCWSFlyWindow.CloseChain;
var
  IsRoot: Boolean;
begin
  IsRoot := (FParentWin = nil);
  CloseChild;
  StopScrollTimer;
  if GFlyOpen <> nil then GFlyOpen.Remove(Self);
  if HandleAllocated then ShowWindow(Handle, SW_HIDE);
  FHotIndex := -1;
  FHotPrim := -1;
  if FParentWin <> nil then
  begin
    FParentWin.FChildWin := nil;
    FParentWin.FChildPrim := -1;
  end;

  if IsRoot then
  begin
    UninstallFlyHooks;
    FMenu.DoCloseNotify;
  end
  else
    Free;   { submenu windows are created dynamically }
end;

function TCWSFlyWindow.Deepest: TCWSFlyWindow;
begin
  Result := Self;
  while Result.FChildWin <> nil do
    Result := Result.FChildWin;
end;

{ ── trafienia i stan podswietlenia ───────────────────────────────────────── }

{ Can the item be executed? }
function TCWSFlyWindow.Selectable(AIdx: Integer): Boolean;
begin
  Result := (AIdx >= 0) and (AIdx <= High(FSec)) and
    not FSec[AIdx].Separator and FSec[AIdx].Item.Enabled;
end;

{ Can the item take the highlight? Disabled entries can — Windows menus
  highlight a greyed item just like any other, they simply do nothing when it
  is clicked. Only separators never light up. }
function TCWSFlyWindow.Hoverable(AIdx: Integer): Boolean;
begin
  Result := (AIdx >= 0) and (AIdx <= High(FSec)) and
    not FSec[AIdx].Separator;
end;

function TCWSFlyWindow.PrimSelectable(AIdx: Integer): Boolean;
begin
  Result := (AIdx >= 0) and (AIdx <= High(FPrim)) and not FPrim[AIdx].Separator and
    (FPrim[AIdx].More or FPrim[AIdx].Item.Enabled);
end;

function TCWSFlyWindow.PrimAt(const P: TPoint): Integer;
var
  i: Integer;
begin
  Result := -1;
  if FBarH = 0 then Exit;
  if (P.Y < BarTop) or (P.Y >= BarTop + FBarH) then Exit;
  for i := 0 to High(FPrim) do
    if (P.X >= FShadow + FPrim[i].Left) and
       (P.X < FShadow + FPrim[i].Left + FPrim[i].Width) then
      Exit(i);
end;

function TCWSFlyWindow.ArrowAt(const P: TPoint): Integer;
begin
  Result := 0;
  if not FScrolling then Exit;
  if (P.X < FShadow) or (P.X > FShadow + FBodyW) then Exit;
  if (P.Y >= ListTop + FVPad) and (P.Y < ListTop + FVPad + FArrowH) then Result := 1
  else if (P.Y > ListTop + (FBodyH - FBarH) - FVPad - FArrowH) and
          (P.Y <= ListTop + (FBodyH - FBarH) - FVPad) then Result := 2;
end;

function TCWSFlyWindow.IndexAt(const P: TPoint): Integer;
var
  i, CT: Integer;
begin
  Result := -1;
  if (FBodyH - FBarH) <= 0 then Exit;
  if (P.Y < ListTop) or (P.Y > ListTop + (FBodyH - FBarH)) then Exit;
  if FScrolling then
    if (P.Y < ContentTop) or (P.Y > ContentTop + FViewH) then Exit;
  CT := ContentTop;
  for i := 0 to High(FSec) do
  begin
    if (P.Y >= CT + FSec[i].Top - FScrollPos) and
       (P.Y < CT + FSec[i].Top + FSec[i].Height - FScrollPos) then
      Exit(i);
  end;
end;

procedure TCWSFlyWindow.SetHot(AIdx: Integer);
begin
  if AIdx <> FHotIndex then
  begin
    FHotIndex := AIdx;
    Render;
  end;
end;

procedure TCWSFlyWindow.SetHotPrim(AIdx: Integer);
begin
  if AIdx <> FHotPrim then
  begin
    FHotPrim := AIdx;
    Render;
  end;
end;

procedure TCWSFlyWindow.EnsureVisible(AIdx: Integer);
var
  ETop, EBot: Integer;
begin
  if not FScrolling or (AIdx < 0) then Exit;
  ETop := FSec[AIdx].Top;
  EBot := ETop + FSec[AIdx].Height;
  if ETop < FScrollPos then FScrollPos := ETop
  else if EBot > FScrollPos + FViewH then FScrollPos := EBot - FViewH;
  FScrollPos := EnsureRange(FScrollPos, 0, FMaxScroll);
end;

procedure TCWSFlyWindow.ScrollBy(ADelta: Integer);
var
  NewPos: Integer;
begin
  if not FScrolling then Exit;
  NewPos := EnsureRange(FScrollPos + ADelta * Round(FMenu.ItemHeight * FScale),
    0, FMaxScroll);
  if NewPos <> FScrollPos then
  begin
    FScrollPos := NewPos;
    CloseChild;
    Render;
  end;
end;

procedure TCWSFlyWindow.StartScrollTimer;
begin
  if FScrollTimer = 0 then
    FScrollTimer := SetTimer(Handle, 1, 60, nil);
end;

procedure TCWSFlyWindow.StopScrollTimer;
begin
  if FScrollTimer <> 0 then
  begin
    KillTimer(Handle, FScrollTimer);
    FScrollTimer := 0;
  end;
end;

procedure TCWSFlyWindow.WMTimer(var Msg: TWMTimer);
begin
  if FHotArrow = 1 then ScrollBy(-1)
  else if FHotArrow = 2 then ScrollBy(1)
  else StopScrollTimer;
end;

procedure TCWSFlyWindow.WMMouseWheel(var Msg: TWMMouseWheel);
begin
  if Msg.WheelDelta > 0 then ScrollBy(-1) else ScrollBy(1);
  Msg.Result := 1;
end;

{ ── submenu ──────────────────────────────────────────────────────────────── }

procedure TCWSFlyWindow.OpenSubmenu(AIdx: Integer);
var
  Sub: TCWSFlyWindow;
begin
  CloseChild;
  if not Selectable(AIdx) then Exit;
  if FSec[AIdx].Item.Count = 0 then Exit;

  Sub := TCWSFlyWindow.CreateForMenu(FMenu, FSec[AIdx].Item, Self, False);
  FChildWin := Sub;
  Sub.ShowAt(FBodyScreen.Right - Round(4 * FScale),
    FWinTop + EntryClientTop(AIdx) - FShadow - FVPad);
end;

{ A bar button with children behaves like an AppBarButton with an attached
  flyout: the submenu drops out of the button, aligned to its left edge. }
procedure TCWSFlyWindow.OpenPrimSubmenu(AIdx: Integer);
var
  Sub: TCWSFlyWindow;
  BR: TRect;
begin
  CloseChild;
  if not PrimSelectable(AIdx) then Exit;
  if FPrim[AIdx].More or (FPrim[AIdx].Item.Count = 0) then Exit;

  BR := PrimRect(AIdx);
  Sub := TCWSFlyWindow.CreateForMenu(FMenu, FPrim[AIdx].Item, Self, False);
  FChildWin := Sub;
  FChildPrim := AIdx;
  if FBarAtBottom then
    Sub.ShowAt(FWinLeft + BR.Left, FBodyScreen.Top + FBodyH - FBarH)
  else
    Sub.ShowAt(FWinLeft + BR.Left, FBodyScreen.Top + FBarH);
end;

{ ── mysz ─────────────────────────────────────────────────────────────────── }

procedure TCWSFlyWindow.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Arrow, Idx, PIdx: Integer;
begin
  inherited;

  { the command bar takes precedence — it occupies its own strip }
  PIdx := PrimAt(Point(X, Y));
  if PIdx >= 0 then
  begin
    SetHot(-1);
    { a vertical rule never lights up — the cursor is over the bar all the
      same, so the list below must not take the highlight either }
    if FPrim[PIdx].Separator then PIdx := -1;
    if PIdx <> FHotPrim then
    begin
      SetHotPrim(PIdx);
      { hovering never opens a bar submenu (that takes a click), but moving
        onto another button closes the one already open }
      if (FChildPrim >= 0) and (FChildPrim <> PIdx) then CloseChild;
    end;
    FHotArrow := 0;
    StopScrollTimer;
    Exit;
  end;
  SetHotPrim(-1);

  Arrow := ArrowAt(Point(X, Y));
  if Arrow <> FHotArrow then
  begin
    FHotArrow := Arrow;
    if FHotArrow <> 0 then StartScrollTimer else StopScrollTimer;
  end;
  if Arrow <> 0 then begin SetHot(-1); Exit; end;

  Idx := IndexAt(Point(X, Y));
  if not Hoverable(Idx) then Idx := -1;
  if Idx <> FHotIndex then
  begin
    SetHot(Idx);
    { Open / close the submenu depending on the item. A disabled parent only
      closes the previous submenu — OpenSubmenu re-checks Selectable. }
    if (Idx >= 0) and (FSec[Idx].Item.Count > 0) then
      OpenSubmenu(Idx)
    else
      CloseChild;
  end;
end;

procedure TCWSFlyWindow.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  Idx, PIdx: Integer;
begin
  inherited;
  { TrackButton (inherited from TPopupMenu) says which button may be used to
    pick items while the menu is up. }
  if (Button <> mbLeft) and
     not ((Button = mbRight) and (FMenu.TrackButton = tbRightButton)) then Exit;

  PIdx := PrimAt(Point(X, Y));
  if PIdx >= 0 then
  begin
    if not PrimSelectable(PIdx) then Exit;
    { "…" only folds the second level out and back — it is not a command, so
      it acts at once and the flyout stays open }
    if FPrim[PIdx].More then
    begin
      SetExpanded(not FExpanded);
      Exit;
    end;
    if FPrim[PIdx].Item.Count > 0 then
      OpenPrimSubmenu(PIdx)
    else
    begin
      FPendingPrim := PIdx;
      FPendingClose := True;
    end;
    Exit;
  end;

  Idx := IndexAt(Point(X, Y));
  if not Selectable(Idx) then Exit;
  if FSec[Idx].Item.Count > 0 then
    OpenSubmenu(Idx)
  else
  begin
    { Do not execute the item now — the window must survive until
      WM_LBUTTONUP, otherwise the stray mouse-up lands on the control
      underneath. The capture is already set by the VCL. }
    FPendingIdx := Idx;
    FPendingClose := True;
  end;
end;

{ Executes the item deferred on mouse-down. False = nothing was deferred, the
  message should travel on. After True the object's fields must not be touched —
  CloseChain frees the submenu windows and Self may no longer exist. }
function TCWSFlyWindow.CommitPending: Boolean;
var
  Idx, PIdx: Integer;
begin
  if not FPendingClose then Exit(False);
  Result := True;

  { The state is cleared BEFORE the item runs. }
  FPendingClose := False;
  Idx := FPendingIdx;
  PIdx := FPendingPrim;
  FPendingIdx := -1;
  FPendingPrim := -1;

  { Release the capture through the VCL property, so the TControl state stays
    consistent. }
  if MouseCapture then
    MouseCapture := False;

  if PIdx >= 0 then
    ActivatePrim(PIdx)        { <- past this line do not touch the fields }
  else if Idx >= 0 then
    ActivateItem(Idx);
end;

procedure TCWSFlyWindow.WMLButtonUp(var Msg: TWMLButtonUp);
begin
  if CommitPending then
    Msg.Result := 0         { message consumed — it does not travel further down }
  else
    inherited;
end;

{ With TrackButton = tbRightButton items can also be picked with the right
  button — execution likewise happens only on mouse-up. }
procedure TCWSFlyWindow.WMRButtonUp(var Msg: TWMRButtonUp);
begin
  if CommitPending then
    Msg.Result := 0
  else
    inherited;
end;

procedure TCWSFlyWindow.WMCaptureChanged(var Msg: TMessage);
begin
  { Someone else took over the capture before the button was released — drop
    the deferred choice so a later mouse-up does not execute the item. }
  FPendingClose := False;
  FPendingIdx := -1;
  FPendingPrim := -1;
  inherited;
end;

procedure TCWSFlyWindow.CMMouseLeave(var Msg: TMessage);
begin
  inherited;
  FHotArrow := 0;
  StopScrollTimer;
  { do not clear the highlight if the cursor entered an open submenu }
  if FChildWin = nil then
  begin
    SetHot(-1);
    SetHotPrim(-1);
  end;
end;

{ ── wykonanie polecenia ──────────────────────────────────────────────────── }

procedure TCWSFlyWindow.ActivateItem(AIdx: Integer);
var
  It: TMenuItem;
begin
  if not Selectable(AIdx) then Exit;
  It := FSec[AIdx].Item;
  if GFlyRootWin <> nil then GFlyRootWin.CloseChain;
  It.Click;
end;

procedure TCWSFlyWindow.ActivatePrim(AIdx: Integer);
var
  It: TMenuItem;
begin
  if not PrimSelectable(AIdx) then Exit;
  if FPrim[AIdx].More then
  begin
    SetExpanded(not FExpanded);
    Exit;
  end;
  if FPrim[AIdx].Item.Count > 0 then
  begin
    OpenPrimSubmenu(AIdx);
    Exit;
  end;
  It := FPrim[AIdx].Item;
  if GFlyRootWin <> nil then GFlyRootWin.CloseChain;
  It.Click;
end;

{ ── klawiatura ───────────────────────────────────────────────────────────────
  Keys always go to the deepest open window. Inside it the focus travels either
  along the command bar (FHotPrim) or down the list (FHotIndex); Down/Up carry
  it between the two levels, exactly like Tab-less navigation in WinUI. }
procedure TCWSFlyWindow.KeyAction(AKey: Word);
var
  D, Par: TCWSFlyWindow;
  i, Cur, n, m, Step, Prim: Integer;
  Moved: Boolean;

  { Puts the highlight on the first (ALast = False) or last selectable button
    of the command bar. }
  procedure FocusBar(ALast: Boolean);
  var
    k: Integer;
  begin
    if ALast then
    begin
      for k := High(D.FPrim) downto 0 do
        if D.PrimSelectable(k) then begin D.SetHot(-1); D.SetHotPrim(k); Exit; end;
    end
    else
      for k := 0 to High(D.FPrim) do
        if D.PrimSelectable(k) then begin D.SetHot(-1); D.SetHotPrim(k); Exit; end;
  end;

  { Puts the highlight on the first or last selectable item of the list. }
  procedure FocusList(ALast: Boolean);
  var
    k: Integer;
  begin
    if ALast then
    begin
      for k := High(D.FSec) downto 0 do
        if D.Selectable(k) then
        begin
          D.SetHotPrim(-1); D.SetHot(k); D.EnsureVisible(k); D.Render; Exit;
        end;
    end
    else
      for k := 0 to High(D.FSec) do
        if D.Selectable(k) then
        begin
          D.SetHotPrim(-1); D.SetHot(k); D.EnsureVisible(k); D.Render; Exit;
        end;
  end;

begin
  D := Deepest;
  n := Length(D.FSec);
  m := Length(D.FPrim);

  case AKey of
    VK_ESCAPE:
      { a bar folded out by "…" collapses first, the flyout closes only on the
        second Escape — the same two-step retreat as in WinUI }
      if D.FIsBar and D.FExpanded and (m > 0) and (n > 0) and
         (not D.FMenu.AutoExpand) then
        D.SetExpanded(False)
      else
        D.CloseChain;

    VK_TAB:
      KeyAction(VK_DOWN);

    VK_SPACE:
      KeyAction(VK_RETURN);

    VK_LEFT:
      { A submenu is always left first — only when none is open does Left mean
        "a step back" inside the window itself. The order matters: the test on
        FParentWin has to come before the one on FHotPrim. }
      if D.FParentWin <> nil then
      begin
        Par := D.FParentWin;
        Prim := Par.FChildPrim;   { the bar button this submenu dropped out of }
        D.CloseChain;             { <- D is freed here, do not touch it again }
        if Prim >= 0 then
        begin
          { back onto the button that owns the submenu }
          Par.FHotIndex := -1;
          Par.FHotPrim := Prim;
        end;
        Par.Render;               { the parent keeps its highlight }
      end
      else if D.FHotPrim >= 0 then
      begin
        Cur := D.FHotPrim;
        for i := 1 to m do
          if D.PrimSelectable((Cur - i + m * 2) mod m) then
          begin
            D.SetHotPrim((Cur - i + m * 2) mod m);
            Break;
          end;
      end
      else if (D.FHotIndex >= 0) and (m > 0) then
        { in the list of secondary commands Left steps back out onto the
          command bar — the mirror image of Right, which steps into a submenu }
        FocusBar(False);

    VK_RIGHT:
      if D.FHotPrim >= 0 then
      begin
        Cur := D.FHotPrim;
        for i := 1 to m do
          if D.PrimSelectable((Cur + i) mod m) then
          begin
            D.SetHotPrim((Cur + i) mod m);
            Break;
          end;
      end
      else if (D.FHotIndex >= 0) and (D.FHotIndex <= High(D.FSec)) and
              (D.FSec[D.FHotIndex].Item.Count > 0) then
      begin
        D.OpenSubmenu(D.FHotIndex);
        if D.FChildWin <> nil then
          with D.FChildWin do
            for i := 0 to High(FSec) do
              if Selectable(i) then
              begin
                SetHot(i); EnsureVisible(i); Render; Break;
              end;
      end;

    VK_RETURN:
      if D.FHotPrim >= 0 then
      begin
        Cur := D.FHotPrim;
        if D.FPrim[Cur].More or (D.FPrim[Cur].Item.Count > 0) then
        begin
          D.ActivatePrim(Cur);
          { after "…" the focus moves straight onto the list that appeared }
          if D.FPrim[Cur].More and D.FExpanded then FocusList(D.FBarAtBottom);
        end
        else
          D.ActivatePrim(Cur);
      end
      else if (D.FHotIndex >= 0) and (D.FHotIndex <= High(D.FSec)) then
      begin
        if D.FSec[D.FHotIndex].Item.Count > 0 then KeyAction(VK_RIGHT)
        else D.ActivateItem(D.FHotIndex);
      end;

    VK_HOME:
      if D.FHotPrim >= 0 then FocusBar(False)
      else if n > 0 then FocusList(False);

    VK_END:
      if D.FHotPrim >= 0 then FocusBar(True)
      else if n > 0 then FocusList(True);

    VK_DOWN, VK_UP:
      begin
        Step := IfThen(AKey = VK_DOWN, 1, -1);

        { nothing highlighted yet — enter through the bar when there is one }
        if (D.FHotPrim < 0) and (D.FHotIndex < 0) then
        begin
          if m > 0 then FocusBar(Step < 0)
          else if n > 0 then FocusList(Step < 0);
          Exit;
        end;

        { on the bar: step towards the list, which lies below it — or above it
          when the flyout opened upwards }
        if D.FHotPrim >= 0 then
        begin
          if ((Step > 0) and not D.FBarAtBottom) or
             ((Step < 0) and D.FBarAtBottom) then
          begin
            if (not D.FExpanded) and (Length(D.FSec) > 0) then
              D.SetExpanded(True);
            if D.FExpanded and (Length(D.FSec) > 0) then
              FocusList(D.FBarAtBottom);
          end;
          Exit;
        end;

        { in the list }
        if n = 0 then Exit;
        Cur := D.FHotIndex;
        i := Cur;
        Moved := False;
        repeat
          i := i + Step;
          if (i < 0) or (i > n - 1) then
          begin
            { off the end of the list — hop onto the bar if there is one,
              otherwise wrap around }
            if m > 0 then begin FocusBar(Step < 0); Exit; end;
            if i < 0 then i := n - 1 else i := 0;
          end;
          if D.Selectable(i) then
          begin
            D.SetHot(i);
            D.EnsureVisible(i);
            D.Render;
            Moved := True;
          end;
        until Moved or (i = Cur);
      end;
  end;
end;

{ ════════════════════════════════════════════════════════════════════════════
    TCWSFlayoutPopupMenu
  ════════════════════════════════════════════════════════════════════════════ }

constructor TCWSFlayoutPopupMenu.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPrimaryCount             := -1;
  FLabelPosition            := lpBottom;
  FPrimaryIconSize          := 20;
  FPrimaryButtonWidth       := 68;
  FSecondaryBackgroundColor := $00F9F9F9;
  FAutoExpand               := False;
  FShowMoreButton           := True;
end;

destructor TCWSFlayoutPopupMenu.Destroy;
begin
  CloseMenu;
  FreeAndNil(FFlyWin);
  inherited;
end;

{ Splits Items into the two command levels. Everything before the first
  top-level separator is primary, everything after it secondary; PrimaryCount
  >= 0 replaces that rule with a plain count. Separators never reach the bar —
  the one that marks the split is consumed, and so are the ones that would open
  the list. }
procedure TCWSFlayoutPopupMenu.SplitCommands(APrimary, ASecondary: TList<TMenuItem>);
var
  i, Taken: Integer;
  It: TMenuItem;
  InSecondary: Boolean;
begin
  APrimary.Clear;
  ASecondary.Clear;
  InSecondary := False;
  Taken := 0;
  for i := 0 to Items.Count - 1 do
  begin
    It := Items[i];
    if not It.Visible then Continue;

    if not InSecondary then
    begin
      if FPrimaryCount >= 0 then
      begin
        if Taken >= FPrimaryCount then
          InSecondary := True
        else if It.IsLine then
        begin
          { With the split pinned by PrimaryCount a separator inside the bar
            has no other job left, so it becomes a vertical rule between groups
            of commands — an AppBarSeparator. It is not a command, so it does
            not count towards PrimaryCount. One at the very start of the bar,
            or a second one in a row, would draw as a stray line. }
          if (APrimary.Count > 0) and not APrimary[APrimary.Count - 1].IsLine then
            APrimary.Add(It);
          Continue;
        end
        else
        begin
          APrimary.Add(It);
          Inc(Taken);
          Continue;
        end;
      end
      else if It.IsLine then
      begin
        InSecondary := True;      { the split — the separator itself is dropped }
        Continue;
      end
      else
      begin
        APrimary.Add(It);
        Continue;
      end;
    end;

    { a separator at the very top of the list would draw as a stray line }
    if It.IsLine and (ASecondary.Count = 0) then Continue;
    ASecondary.Add(It);
  end;

  { a rule left hanging at the end of the bar }
  while (APrimary.Count > 0) and APrimary[APrimary.Count - 1].IsLine do
    APrimary.Delete(APrimary.Count - 1);

  { trailing separators of the second level }
  while (ASecondary.Count > 0) and ASecondary[ASecondary.Count - 1].IsLine do
    ASecondary.Delete(ASecondary.Count - 1);
end;

procedure TCWSFlayoutPopupMenu.DoCloseNotify;
begin
  DoClose;
end;

procedure TCWSFlayoutPopupMenu.DoExpandChanged;
begin
  if Assigned(FOnExpandChanged) then FOnExpandChanged(Self);
end;

function TCWSFlayoutPopupMenu.GetExpanded: Boolean;
begin
  Result := (FFlyWin <> nil) and FFlyWin.Expanded;
end;

procedure TCWSFlayoutPopupMenu.SetExpanded(const Value: Boolean);
begin
  if FFlyWin <> nil then FFlyWin.Expanded := Value;
end;

procedure TCWSFlayoutPopupMenu.Popup(X, Y: Integer);
begin
  if csDesigning in ComponentState then Exit;
  CloseMenu;
  if Assigned(OnPopup) then OnPopup(Self);
  if Items.Count = 0 then Exit;

  if GFlyOpen = nil then GFlyOpen := TList<TCWSFlyWindow>.Create;
  if FFlyWin = nil then
    FFlyWin := TCWSFlyWindow.CreateForMenu(Self, Items, nil, True);

  FFlyWin.FExpanded := FAutoExpand;
  FFlyWin.ShowAt(X, Y);
  if GFlyOpen.Count > 0 then
    InstallFlyHooks(FFlyWin);
end;

{ The flyout is measured before it can be placed, so the position is worked out
  in two steps: pop it up off-screen to learn its size, then move it over the
  target. Placing it off-screen first also keeps the first frame from flashing
  in the wrong spot. }
procedure TCWSFlayoutPopupMenu.PopupForRect(const ARect: TRect);
var
  Mon: TMonitor;
  WR: TRect;
  X, Y, Gap: Integer;
begin
  if csDesigning in ComponentState then Exit;
  Popup(-30000, -30000);
  if (FFlyWin = nil) or not FFlyWin.HandleAllocated then Exit;

  Mon := Screen.MonitorFromRect(ARect);
  if Mon <> nil then WR := Mon.WorkareaRect else WR := Screen.WorkAreaRect;
  Gap := Round(8 * FFlyWin.FScale);

  X := (ARect.Left + ARect.Right - FFlyWin.FBodyW) div 2;
  { above the target when it fits there, below it otherwise }
  Y := ARect.Top - Gap - FFlyWin.FBodyH;
  if Y < WR.Top then Y := ARect.Bottom + Gap;

  FFlyWin.FAnchor := Point(X, Y);
  FFlyWin.ComputeScale(X, Y);
  FFlyWin.Measure;
  FFlyWin.Place;
  SetWindowPos(FFlyWin.Handle, HWND_TOPMOST, FFlyWin.FWinLeft, FFlyWin.FWinTop,
    FFlyWin.FWinW, FFlyWin.FWinH, SWP_NOACTIVATE);
  FFlyWin.Render;
end;

procedure TCWSFlayoutPopupMenu.PopupForControl(AControl: TControl);
var
  R: TRect;
  P: TPoint;
begin
  if AControl = nil then Exit;
  P := AControl.ClientToScreen(Point(0, 0));
  R := Rect(P.X, P.Y, P.X + AControl.Width, P.Y + AControl.Height);
  PopupForRect(R);
end;

procedure TCWSFlayoutPopupMenu.CloseMenu;
begin
  if (FFlyWin <> nil) and FFlyWin.HandleAllocated and
     IsWindowVisible(FFlyWin.Handle) then
    FFlyWin.CloseChain;
end;

initialization

finalization
  FreeAndNil(GFlyOpen);

end.
