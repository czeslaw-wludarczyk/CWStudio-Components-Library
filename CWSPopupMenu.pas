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
unit CWSPopupMenu;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.MultiMon,
  System.SysUtils, System.Classes, System.UITypes, System.Math,
  System.Generics.Collections, Vcl.Controls, Vcl.Graphics, Vcl.Menus,
  Vcl.ImgList, Vcl.Forms, Winapi.GDIPAPI, Winapi.GDIPOBJ, System.Types;

type
  TCWSPopupMenu = class;

  { Internal description of a visible item in one menu window }
  TCWSVisEntry = record
    Item: TMenuItem;
    Top: Integer;     { Y position in content space (before scrolling) }
    Height: Integer;
    Separator: Boolean;
  end;

  { ── Layered window rendering a single menu level ───────────────────────── }
  TCWSMenuWindow = class(TCustomControl)
  private
    FMenu: TCWSPopupMenu;
    FRoot: TMenuItem;            { parent item whose children we display }
    FParentWin: TCWSMenuWindow;  { parent window (nil for the root) }
    FChildWin: TCWSMenuWindow;   { open submenu }
    FScale: Single;
    FDpi: Integer;
    FShadow, FBlur, FShadowOffset: Integer;
    FBodyW, FBodyH, FWinW, FWinH: Integer;
    FWinLeft, FWinTop: Integer;
    FBodyScreen: TRect;
    FEntries: TArray<TCWSVisEntry>;
    FContentH: Integer;
    FViewH: Integer;
    FScrolling: Boolean;
    FScrollPos: Integer;
    FMaxScroll: Integer;
    FArrowH: Integer;
    FVPad: Integer;
    FHotIndex: Integer;          { index in FEntries or -1 }
    FHotArrow: Integer;          { 0 none, 1 up, 2 down }
    FScrollTimer: UINT_PTR;

    procedure ComputeScale(const X, Y: Integer);
    function FontEmSize: Single;
    function MakeGdiFont: HFONT;
    function MeasureTextW(ADC: HDC; const S: string): Integer;
    function ShortCutOf(AItem: TMenuItem): string;
    procedure BuildEntries;
    procedure Measure;
    procedure Render;
    procedure DrawIcon(G: TGPGraphics; AItem: TMenuItem; const ADest: TRect;
      AEnabled: Boolean);
    function ContentTop: Integer;
    function EntryClientTop(AIdx: Integer): Integer;
    function IndexAt(const P: TPoint): Integer;
    function ArrowAt(const P: TPoint): Integer;
    function Selectable(AIdx: Integer): Boolean;
    procedure SetHot(AIdx: Integer);
    procedure StartScrollTimer;
    procedure StopScrollTimer;
    procedure ScrollBy(ADelta: Integer);
    procedure EnsureVisible(AIdx: Integer);
    procedure OpenSubmenu(AIdx: Integer);
    procedure CloseChild;
    function Deepest: TCWSMenuWindow;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMTimer(var Msg: TWMTimer); message WM_TIMER;
    procedure WMMouseWheel(var Msg: TWMMouseWheel); message WM_MOUSEWHEEL;
    procedure WMMouseActivate(var Msg: TWMMouseActivate); message WM_MOUSEACTIVATE;
  public
    constructor CreateForMenu(AMenu: TCWSPopupMenu; ARoot: TMenuItem;
      AParent: TCWSMenuWindow); reintroduce;
    destructor Destroy; override;
    procedure ShowAt(X, Y: Integer);
    procedure CloseChain;          { closes this window together with its submenus }
    procedure ActivateItem(AIdx: Integer);
    procedure KeyAction(AKey: Word);
    property BodyScreen: TRect read FBodyScreen;
  end;

  { ── Komponent ──────────────────────────────────────────────────────────── }
  TCWSPopupMenu = class(TPopupMenu)
  private
    FRootWin: TCWSMenuWindow;
    FFont: TFont;
    FBackgroundColor: TColor;
    FBorderColor: TColor;
    FTextColor: TColor;
    FDisabledTextColor: TColor;
    FHighlightColor: TColor;
    FHighlightTextColor: TColor;
    FSeparatorColor: TColor;
    FShortCutColor: TColor;
    FCornerRadius: Integer;
    FItemHeight: Integer;
    FBorderThickness: Integer;
    FShadowEnabled: Boolean;
    FShadowSize: Integer;
    FMaxVisibleItems: Integer;
    FOnClose: TNotifyEvent;
    procedure SetFont(const Value: TFont);
  protected
    procedure DoClose; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Popup(X, Y: Integer); override;
    procedure CloseMenu;
  published
    property Font: TFont read FFont write SetFont;
    property BackgroundColor: TColor read FBackgroundColor write FBackgroundColor default $00F9F9F9;
    property BorderColor: TColor read FBorderColor write FBorderColor default $00E5E5E5;
    property TextColor: TColor read FTextColor write FTextColor default $001A1A1A;
    property DisabledTextColor: TColor read FDisabledTextColor write FDisabledTextColor default $00A0A0A0;
    property HighlightColor: TColor read FHighlightColor write FHighlightColor default $00EFEFEF;
    property HighlightTextColor: TColor read FHighlightTextColor write FHighlightTextColor default $001A1A1A;
    property SeparatorColor: TColor read FSeparatorColor write FSeparatorColor default $00E5E5E5;
    property ShortCutColor: TColor read FShortCutColor write FShortCutColor default $008A8A8A;
    property CornerRadius: Integer read FCornerRadius write FCornerRadius default 8;
    property ItemHeight: Integer read FItemHeight write FItemHeight default 34;
    property BorderThickness: Integer read FBorderThickness write FBorderThickness default 1;
    property ShadowEnabled: Boolean read FShadowEnabled write FShadowEnabled default True;
    property ShadowSize: Integer read FShadowSize write FShadowSize default 18;
    { 0 = no limit (constrained only by the screen height) }
    property MaxVisibleItems: Integer read FMaxVisibleItems write FMaxVisibleItems default 0;
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
  end;

implementation

const
  ULW_ALPHA = $00000002;
  { Peak shadow opacity (0..255) — low, soft like in WinUI 3. }
  MENU_SHADOW_ALPHA = 86;
  EVENT_SYSTEM_FOREGROUND_ = $0003;
  WINEVENT_OUTOFCONTEXT_   = $0000;

var
  GMenuMouseHook: HHOOK = 0;
  GMenuKeyHook: HHOOK = 0;
  GFgEventHook: THandle = 0;
  GOpenMenus: TList<TCWSMenuWindow> = nil;
  GRootWin: TCWSMenuWindow = nil;

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

function CreateRRPath(X, Y, W, H, R: Single): TGPGraphicsPath;
var
  D: Single;
begin
  Result := TGPGraphicsPath.Create;
  if R <= 0 then
  begin
    Result.AddRectangle(MakeRect(X, Y, W, H));
    Exit;
  end;
  D := R * 2;
  if D > W then D := W;
  if D > H then D := H;
  Result.StartFigure;
  Result.AddArc(X, Y, D, D, 180, 90);
  Result.AddArc(X + W - D, Y, D, D, 270, 90);
  Result.AddArc(X + W - D, Y + H - D, D, D, 0, 90);
  Result.AddArc(X, Y + H - D, D, D, 90, 90);
  Result.CloseFigure;
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

{ ════════════════════════════════════════════════════════════════════════════
    Sesja menu (lista otwartych okien) + hooki
  ════════════════════════════════════════════════════════════════════════════ }

function PointInAnyMenu(const Pt: TPoint): Boolean;
var
  i: Integer;
begin
  Result := False;
  if GOpenMenus = nil then Exit;
  for i := 0 to GOpenMenus.Count - 1 do
    if PtInRect(GOpenMenus[i].BodyScreen, Pt) then Exit(True);
end;

function MenuMouseHookProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  MHS: ^TMouseHookStruct;
begin
  Result := CallNextHookEx(GMenuMouseHook, nCode, wParam, lParam);
  if (nCode >= HC_ACTION) and (GRootWin <> nil) then
  begin
    case wParam of
      WM_LBUTTONDOWN, WM_RBUTTONDOWN, WM_MBUTTONDOWN,
      WM_NCLBUTTONDOWN, WM_NCRBUTTONDOWN, WM_NCMBUTTONDOWN:
      begin
        MHS := Pointer(lParam);
        if not PointInAnyMenu(MHS^.pt) then
          GRootWin.CloseChain;
      end;
    end;
  end;
end;

function MenuKeyHookProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  Result := CallNextHookEx(GMenuKeyHook, nCode, wParam, lParam);
  if (nCode = HC_ACTION) and (GRootWin <> nil) and
     ((lParam and (1 shl 31)) = 0) then
  begin
    case wParam of
      VK_ESCAPE, VK_DOWN, VK_UP, VK_RETURN, VK_LEFT, VK_RIGHT,
      VK_HOME, VK_END:
      begin
        GRootWin.KeyAction(wParam);
        Result := 1;
      end;
    end;
  end;
end;

{ App deactivation (Alt+Tab, clicking another app) — close the menu.
  While the menu is open, the foreground window should not change. }
procedure MenuWinEventProc(hHook: THandle; dwEvent: DWORD; hwnd: HWND;
  idObject, idChild: LongInt; idThread, dwmsTime: DWORD); stdcall;
begin
  if (dwEvent = EVENT_SYSTEM_FOREGROUND_) and (GRootWin <> nil) then
    GRootWin.CloseChain;
end;

procedure InstallMenuHooks(ARoot: TCWSMenuWindow);
begin
  GRootWin := ARoot;
  if GMenuMouseHook = 0 then
    GMenuMouseHook := SetWindowsHookEx(WH_MOUSE, @MenuMouseHookProc, 0, GetCurrentThreadId);
  if GMenuKeyHook = 0 then
    GMenuKeyHook := SetWindowsHookEx(WH_KEYBOARD, @MenuKeyHookProc, 0, GetCurrentThreadId);
  if GFgEventHook = 0 then
    GFgEventHook := SetWinEventHook(EVENT_SYSTEM_FOREGROUND_, EVENT_SYSTEM_FOREGROUND_,
      0, @MenuWinEventProc, 0, 0, WINEVENT_OUTOFCONTEXT_);
end;

procedure UninstallMenuHooks;
begin
  GRootWin := nil;
  if GMenuMouseHook <> 0 then begin UnhookWindowsHookEx(GMenuMouseHook); GMenuMouseHook := 0; end;
  if GMenuKeyHook <> 0 then begin UnhookWindowsHookEx(GMenuKeyHook); GMenuKeyHook := 0; end;
  if GFgEventHook <> 0 then begin UnhookWinEvent(GFgEventHook); GFgEventHook := 0; end;
end;

{ ════════════════════════════════════════════════════════════════════════════
    TCWSMenuWindow
  ════════════════════════════════════════════════════════════════════════════ }

constructor TCWSMenuWindow.CreateForMenu(AMenu: TCWSPopupMenu; ARoot: TMenuItem;
  AParent: TCWSMenuWindow);
begin
  inherited Create(AMenu);
  FMenu := AMenu;
  FRoot := ARoot;
  FParentWin := AParent;
  FHotIndex := -1;
  FScale := 1;
  FDpi := 96;
end;

destructor TCWSMenuWindow.Destroy;
begin
  StopScrollTimer;
  inherited;
end;

procedure TCWSMenuWindow.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := WS_POPUP;
  Params.ExStyle := WS_EX_TOOLWINDOW or WS_EX_TOPMOST or WS_EX_NOACTIVATE or
    WS_EX_LAYERED;
  Params.WndParent := GetDesktopWindow;
end;

procedure TCWSMenuWindow.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

procedure TCWSMenuWindow.WMPaint(var Msg: TWMPaint);
var
  PS: TPaintStruct;
begin
  BeginPaint(Handle, PS);
  EndPaint(Handle, PS);
  Msg.Result := 0;
end;

procedure TCWSMenuWindow.WMMouseActivate(var Msg: TWMMouseActivate);
begin
  Msg.Result := MA_NOACTIVATE;
end;

procedure TCWSMenuWindow.ComputeScale(const X, Y: Integer);
var
  Mon: TMonitor;
begin
  Mon := Screen.MonitorFromPoint(Point(X, Y));
  if Mon <> nil then FDpi := Mon.PixelsPerInch else FDpi := Screen.PixelsPerInch;
  if FDpi <= 0 then FDpi := 96;
  FScale := FDpi / 96;
end;

function TCWSMenuWindow.FontEmSize: Single;
begin
  { calkowity rozmiar w pikselach - hinting dziala skuteczniej niz przy
    ulamkowym ppem (np. przy skalowaniu 110%) }
  if FMenu.Font.Size > 0 then Result := Round(FMenu.Font.Size * FDpi / 72)
  else Result := Round(Abs(FMenu.Font.Height) * FScale);
  if Result < 8 then Result := 8;
end;

function TCWSMenuWindow.MakeGdiFont: HFONT;
var
  LF: TLogFont;
begin
  FillChar(LF, SizeOf(LF), 0);
  LF.lfHeight := -Round(FontEmSize);
  if fsBold in FMenu.Font.Style then LF.lfWeight := FW_BOLD
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

{ Pomiar tym samym silnikiem, ktorym pozniej rysujemy (GDI), inaczej szerokosci
  sie rozjezdzaja i najdluzsza pozycja dostaje wielokropek.
  DT_CALCRECT uwzglednia '&' jako prefiks akceleratora, tak jak rysowanie. }
function TCWSMenuWindow.MeasureTextW(ADC: HDC; const S: string): Integer;
var
  R: TRect;
begin
  if S = '' then Exit(0);
  R := Rect(0, 0, 0, 0);
  Winapi.Windows.DrawText(ADC, PChar(S), -1, R,
    DT_SINGLELINE or DT_CALCRECT or DT_NOCLIP);
  Result := (R.Right - R.Left) + Round(2 * FScale);
end;

function TCWSMenuWindow.ShortCutOf(AItem: TMenuItem): string;
begin
  if AItem.ShortCut <> 0 then Result := ShortCutToText(AItem.ShortCut)
  else Result := '';
end;

procedure TCWSMenuWindow.BuildEntries;
var
  i, n, ItemH, SepH, CurTop: Integer;
  It: TMenuItem;
begin
  SetLength(FEntries, 0);
  n := 0;
  ItemH := Round(FMenu.ItemHeight * FScale);
  SepH := Round(9 * FScale);
  CurTop := 0;
  for i := 0 to FRoot.Count - 1 do
  begin
    It := FRoot.Items[i];
    if not It.Visible then Continue;
    SetLength(FEntries, n + 1);
    FEntries[n].Item := It;
    FEntries[n].Separator := It.IsLine;
    FEntries[n].Top := CurTop;
    if FEntries[n].Separator then FEntries[n].Height := SepH
    else FEntries[n].Height := ItemH;
    Inc(CurTop, FEntries[n].Height);
    Inc(n);
  end;
  FContentH := CurTop;
end;

procedure TCWSMenuWindow.Measure;
var
  ScreenDC, MemDC: HDC;
  GdiFont: HFONT;
  i, IconArea, RightPad, MinW, MaxH: Integer;
  MaxCap, MaxSc, W: Single;
  HasSub, HasSc: Boolean;
  ShortcutAreaW, SubArrowW: Integer;
  It: TMenuItem;
  Mon: HMONITOR;
  MI: TMonitorInfo;
begin
  IconArea := Round(40 * FScale);
  RightPad := Round(14 * FScale);
  MinW     := Round(150 * FScale);
  FVPad    := Round(4 * FScale);
  FArrowH  := Round(20 * FScale);

  if FMenu.ShadowEnabled then
  begin
    FBlur := Max(2, Round(FMenu.ShadowSize * FScale));
    FShadowOffset := Round(5 * FScale);
    FShadow := FBlur + FShadowOffset + Round(4 * FScale);
  end
  else begin FBlur := 0; FShadowOffset := 0; FShadow := 0; end;

  BuildEntries;

  MaxCap := 0; MaxSc := 0; HasSub := False; HasSc := False;
  ScreenDC := GetDC(0);
  MemDC := CreateCompatibleDC(ScreenDC);
  GdiFont := MakeGdiFont;
  SaveDC(MemDC);
  try
    SelectObject(MemDC, GdiFont);
    for i := 0 to High(FEntries) do
    begin
      It := FEntries[i].Item;
      if FEntries[i].Separator then Continue;
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
    DeleteDC(MemDC);
    ReleaseDC(0, ScreenDC);
  end;

  SubArrowW := IfThen(HasSub, Round(20 * FScale), 0);
  ShortcutAreaW := IfThen(HasSc, Round(24 * FScale) + Ceil(MaxSc), 0);

  FBodyW := IconArea + Ceil(MaxCap) + ShortcutAreaW + SubArrowW + RightPad;
  if FBodyW < MinW then FBodyW := MinW;

  { available height — screen (and the optional item limit) }
  Mon := MonitorFromWindow(Handle, MONITOR_DEFAULTTONEAREST);
  MI.cbSize := SizeOf(MI);
  GetMonitorInfo(Mon, @MI);
  MaxH := (MI.rcWork.Bottom - MI.rcWork.Top) - Round(8 * FScale);
  if FMenu.MaxVisibleItems > 0 then
    MaxH := Min(MaxH, FMenu.MaxVisibleItems * Round(FMenu.ItemHeight * FScale) + FVPad * 2);

  if FContentH + FVPad * 2 <= MaxH then
  begin
    FScrolling := False;
    FBodyH := FContentH + FVPad * 2;
    FViewH := FContentH;
    FMaxScroll := 0;
  end
  else
  begin
    FScrolling := True;
    FBodyH := MaxH;
    FViewH := MaxH - FVPad * 2 - FArrowH * 2;
    if FViewH < Round(FMenu.ItemHeight * FScale) then
      FViewH := Round(FMenu.ItemHeight * FScale);
    FMaxScroll := Max(0, FContentH - FViewH);
  end;
  FScrollPos := EnsureRange(FScrollPos, 0, FMaxScroll);

  FWinW := FBodyW + FShadow * 2;
  FWinH := FBodyH + FShadow * 2;
end;

function TCWSMenuWindow.ContentTop: Integer;
begin
  Result := FShadow + FVPad;
  if FScrolling then Inc(Result, FArrowH);
end;

function TCWSMenuWindow.EntryClientTop(AIdx: Integer): Integer;
begin
  Result := ContentTop + FEntries[AIdx].Top - FScrollPos;
end;

type
  { Renders a glyph onto a prepared 32bpp canvas. }
  TGlyphDrawProc = reference to procedure (ACanvas: TCanvas);

{ Draws a glyph into a 32bpp premultiplied DIB that GDI+ can alpha-blend.

  GDI+ cannot build a usable bitmap straight from an image list: neither
  Bitmap.FromHICON (ImageList_GetIcon) nor Bitmap.FromHBITMAP keeps the alpha
  channel, so glyphs coming from an alpha image list — TVirtualImageList,
  TImageCollection, SVG lists — end up drawn as black squares.

  The glyph is first drawn over a transparent (zeroed) surface. Alpha-aware
  image lists blend with AlphaBlend and leave a correct alpha channel behind.
  A classic masked TImageList writes no alpha at all; in that case the shape is
  recovered by drawing a second time over a different background — pixels that
  came out the same on both are opaque, the rest are transparent. }
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

procedure TCWSMenuWindow.DrawIcon(G: TGPGraphics; AItem: TMenuItem;
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

procedure TCWSMenuWindow.Render;
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
  i, N, A: Integer;
  Radius, BodyX, BodyY: Single;
  Border, IconSize, IconArea, SepInset, HlInsetX, HlInsetY: Integer;
  It: TMenuItem;
  ItemTop, ItemH: Integer;
  R, TR: TRect;
  IconRect: TRect;
  TxtColor, ShCol: TColor;
  Sc: string;
  Blend: TBlendFunction;
  PtSrc: TPoint;
  Sz: TSize;
  CovA, ShBits, SavedA: TBytes;
  ShImg: TGPBitmap;
  CY, ChevX, ChevSz: Single;
  GdiFont: HFONT;
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
    SepInset := Round(12 * FScale);
    HlInsetX := Round(4 * FScale);
    HlInsetY := Round(2 * FScale);
    Radius := FMenu.CornerRadius * FScale;
    Border := Max(1, Round(FMenu.BorderThickness * FScale));
    BodyX := FShadow; BodyY := FShadow;

    { ══ warstwa 1: tlo, obramowanie, ikony, strzalki - GDI+ ═══════════════ }
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

      { ── korpus + border ──────────────────────────────────────────────────── }
      Path := CreateRRPath(BodyX, BodyY, FBodyW, FBodyH, Radius);
      Brush := TGPSolidBrush.Create(GPColor(FMenu.BackgroundColor));
      try G.FillPath(Brush, Path); finally Brush.Free; Path.Free; end;

      if Border > 0 then
      begin
        Path := CreateRRPath(BodyX + Border / 2, BodyY + Border / 2,
          FBodyW - Border, FBodyH - Border, Radius - Border / 2);
        Pen := TGPPen.Create(GPColor(FMenu.BorderColor), Border);
        try G.DrawPath(Pen, Path); finally Pen.Free; Path.Free; end;
      end;

      { przytnij rysowanie pozycji do obszaru widoku }
      G.SetClip(MakeRect(Single(BodyX), Single(ContentTop),
        Single(FBodyW), Single(FViewH)));

      for i := 0 to High(FEntries) do
      begin
        It := FEntries[i].Item;
        ItemTop := EntryClientTop(i);
        ItemH := FEntries[i].Height;
        if (ItemTop + ItemH < ContentTop) or (ItemTop > ContentTop + FViewH) then
          Continue;
        R := Rect(Round(BodyX), ItemTop, Round(BodyX) + FBodyW, ItemTop + ItemH);

        if FEntries[i].Separator then
        begin
          Pen := TGPPen.Create(GPColor(FMenu.SeparatorColor), 1);
          try
            G.DrawLine(Pen, Single(BodyX + SepInset), Single((R.Top + R.Bottom) / 2),
              Single(BodyX + FBodyW - SepInset), Single((R.Top + R.Bottom) / 2));
          finally Pen.Free; end;
          Continue;
        end;

        if (i = FHotIndex) and It.Enabled then
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

      { ── scroll arrows ───────────────────────────────────────────────────── }
      if FScrolling then
      begin
        ChevX := BodyX + FBodyW / 2;
        ChevSz := 5 * FScale;
        { top }
        if FScrollPos > 0 then ShCol := FMenu.TextColor else ShCol := FMenu.DisabledTextColor;
        CY := BodyY + FVPad + FArrowH / 2;
        Pen := TGPPen.Create(GPColor(ShCol), 1.4 * FScale);
        try
          G.DrawLine(Pen, ChevX - ChevSz, CY + ChevSz / 2, ChevX, CY - ChevSz / 2);
          G.DrawLine(Pen, ChevX, CY - ChevSz / 2, ChevX + ChevSz, CY + ChevSz / 2);
        finally Pen.Free; end;
        { bottom }
        if FScrollPos < FMaxScroll then ShCol := FMenu.TextColor else ShCol := FMenu.DisabledTextColor;
        CY := BodyY + FBodyH - FVPad - FArrowH / 2;
        Pen := TGPPen.Create(GPColor(ShCol), 1.4 * FScale);
        try
          G.DrawLine(Pen, ChevX - ChevSz, CY - ChevSz / 2, ChevX, CY + ChevSz / 2);
          G.DrawLine(Pen, ChevX, CY + ChevSz / 2, ChevX + ChevSz, CY - ChevSz / 2);
        finally Pen.Free; end;
      end;

      G.Flush(FlushIntentionSync);
    finally
      G.Free; GBmp.Free;
    end;

    { ══ warstwa 2: podpisy - GDI z ClearType ══════════════════════════════
      GDI+ nie renderuje ClearType na bitmapie z kanalem alfa - cicho schodzi
      do skali szarosci, przez co tekst menu wygladal miekko obok reszty
      aplikacji rysowanej przez GDI. Napisy idą wiec zwyklym GDI wprost do
      DIB-a. GDI nie zna alfy i zeruje ja w pikselach glifow, dlatego kanal
      alfa zapamietujemy przed rysowaniem i odtwarzamy po nim. Tlo pod
      tekstem jest w pelni nieprzezroczyste, wiec ClearType blenduje sie
      poprawnie. }
    N := FWinW * FWinH;
    SetLength(SavedA, N);
    PB := Bits; Inc(PB, 3);
    for i := 0 to N - 1 do
    begin
      SavedA[i] := PB^;
      Inc(PB, 4);
    end;

    GdiFont := MakeGdiFont;
    SaveDC(MemDC);
    try
      SelectObject(MemDC, GdiFont);
      SetBkMode(MemDC, TRANSPARENT);
      IntersectClipRect(MemDC, Round(BodyX), ContentTop,
        Round(BodyX) + FBodyW, ContentTop + FViewH);

      for i := 0 to High(FEntries) do
      begin
        if FEntries[i].Separator then Continue;
        It := FEntries[i].Item;
        ItemTop := EntryClientTop(i);
        ItemH := FEntries[i].Height;
        if (ItemTop + ItemH < ContentTop) or (ItemTop > ContentTop + FViewH) then
          Continue;
        R := Rect(Round(BodyX), ItemTop, Round(BodyX) + FBodyW, ItemTop + ItemH);

        if It.Enabled then
        begin
          if i = FHotIndex then TxtColor := FMenu.HighlightTextColor
          else TxtColor := FMenu.TextColor;
        end
        else TxtColor := FMenu.DisabledTextColor;

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
          SetTextColor(MemDC, ColorToRGB(ShCol));
          TR := Rect(R.Left + IconArea, R.Top,
                     R.Right - Round(14 * FScale), R.Bottom);
          Winapi.Windows.DrawText(MemDC, PChar(Sc), -1, TR,
            DT_SINGLELINE or DT_VCENTER or DT_RIGHT or DT_NOPREFIX);
        end;
      end;
    finally
      RestoreDC(MemDC, -1);
      DeleteObject(GdiFont);
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

procedure TCWSMenuWindow.ShowAt(X, Y: Integer);
var
  Mon: HMONITOR;
  MI: TMonitorInfo;
  WR: TRect;
  BodyLeft, BodyTop: Integer;
begin
  HandleNeeded;
  FHotIndex := -1;
  FScrollPos := 0;
  ComputeScale(X, Y);
  Measure;
  if Length(FEntries) = 0 then Exit;

  Mon := MonitorFromPoint(Point(X, Y), MONITOR_DEFAULTTONEAREST);
  MI.cbSize := SizeOf(MI);
  GetMonitorInfo(Mon, @MI);
  WR := MI.rcWork;

  BodyLeft := X; BodyTop := Y;
  if BodyLeft + FBodyW > WR.Right then
  begin
    if FParentWin <> nil then
      BodyLeft := FParentWin.FBodyScreen.Left - FBodyW + Round(4 * FScale)
    else
      BodyLeft := WR.Right - FBodyW;
  end;
  if BodyLeft < WR.Left then BodyLeft := WR.Left;
  if BodyTop + FBodyH > WR.Bottom then BodyTop := WR.Bottom - FBodyH;
  if BodyTop < WR.Top then BodyTop := WR.Top;

  FWinLeft := BodyLeft - FShadow;
  FWinTop := BodyTop - FShadow;
  FBodyScreen := Rect(BodyLeft, BodyTop, BodyLeft + FBodyW, BodyTop + FBodyH);

  SetWindowPos(Handle, HWND_TOPMOST, FWinLeft, FWinTop, FWinW, FWinH,
    SWP_NOACTIVATE or SWP_HIDEWINDOW);
  Render;
  ShowWindow(Handle, SW_SHOWNOACTIVATE);
  SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0,
    SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);

  if GOpenMenus <> nil then GOpenMenus.Add(Self);
end;

procedure TCWSMenuWindow.CloseChild;
begin
  if FChildWin <> nil then
  begin
    FChildWin.CloseChain;
    FChildWin := nil;
  end;
end;

procedure TCWSMenuWindow.CloseChain;
var
  IsRoot: Boolean;
begin
  IsRoot := (FParentWin = nil);
  CloseChild;
  StopScrollTimer;
  if GOpenMenus <> nil then GOpenMenus.Remove(Self);
  if HandleAllocated then ShowWindow(Handle, SW_HIDE);
  FHotIndex := -1;
  if FParentWin <> nil then
    FParentWin.FChildWin := nil;

  if IsRoot then
  begin
    UninstallMenuHooks;
    FMenu.DoClose;
  end
  else
    Free;   { submenu windows are created dynamically }
end;

function TCWSMenuWindow.Deepest: TCWSMenuWindow;
begin
  Result := Self;
  while Result.FChildWin <> nil do
    Result := Result.FChildWin;
end;

function TCWSMenuWindow.Selectable(AIdx: Integer): Boolean;
begin
  Result := (AIdx >= 0) and (AIdx <= High(FEntries)) and
    not FEntries[AIdx].Separator and FEntries[AIdx].Item.Enabled;
end;

function TCWSMenuWindow.ArrowAt(const P: TPoint): Integer;
begin
  Result := 0;
  if not FScrolling then Exit;
  if (P.X < FShadow) or (P.X > FShadow + FBodyW) then Exit;
  if (P.Y >= FShadow + FVPad) and (P.Y < FShadow + FVPad + FArrowH) then Result := 1
  else if (P.Y > FShadow + FBodyH - FVPad - FArrowH) and (P.Y <= FShadow + FBodyH - FVPad) then Result := 2;
end;

function TCWSMenuWindow.IndexAt(const P: TPoint): Integer;
var
  i, CT: Integer;
begin
  Result := -1;
  if FScrolling then
    if (P.Y < ContentTop) or (P.Y > ContentTop + FViewH) then Exit;
  CT := ContentTop;
  for i := 0 to High(FEntries) do
  begin
    if (P.Y >= CT + FEntries[i].Top - FScrollPos) and
       (P.Y < CT + FEntries[i].Top + FEntries[i].Height - FScrollPos) then
      Exit(i);
  end;
end;

procedure TCWSMenuWindow.SetHot(AIdx: Integer);
begin
  if AIdx <> FHotIndex then
  begin
    FHotIndex := AIdx;
    Render;
  end;
end;

procedure TCWSMenuWindow.EnsureVisible(AIdx: Integer);
var
  ETop, EBot: Integer;
begin
  if not FScrolling or (AIdx < 0) then Exit;
  ETop := FEntries[AIdx].Top;
  EBot := ETop + FEntries[AIdx].Height;
  if ETop < FScrollPos then FScrollPos := ETop
  else if EBot > FScrollPos + FViewH then FScrollPos := EBot - FViewH;
  FScrollPos := EnsureRange(FScrollPos, 0, FMaxScroll);
end;

procedure TCWSMenuWindow.ScrollBy(ADelta: Integer);
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

procedure TCWSMenuWindow.StartScrollTimer;
begin
  if FScrollTimer = 0 then
    FScrollTimer := SetTimer(Handle, 1, 60, nil);
end;

procedure TCWSMenuWindow.StopScrollTimer;
begin
  if FScrollTimer <> 0 then
  begin
    KillTimer(Handle, FScrollTimer);
    FScrollTimer := 0;
  end;
end;

procedure TCWSMenuWindow.WMTimer(var Msg: TWMTimer);
begin
  if FHotArrow = 1 then ScrollBy(-1)
  else if FHotArrow = 2 then ScrollBy(1)
  else StopScrollTimer;
end;

procedure TCWSMenuWindow.WMMouseWheel(var Msg: TWMMouseWheel);
begin
  if Msg.WheelDelta > 0 then ScrollBy(-1) else ScrollBy(1);
  Msg.Result := 1;
end;

procedure TCWSMenuWindow.OpenSubmenu(AIdx: Integer);
var
  Sub: TCWSMenuWindow;
  AnchorX, AnchorY: Integer;
begin
  CloseChild;
  if not Selectable(AIdx) then Exit;
  if FEntries[AIdx].Item.Count = 0 then Exit;

  Sub := TCWSMenuWindow.CreateForMenu(FMenu, FEntries[AIdx].Item, Self);
  FChildWin := Sub;
  AnchorX := FBodyScreen.Right - Round(4 * FScale);
  AnchorY := FWinTop + EntryClientTop(AIdx) - FShadow - FVPad;
  Sub.ShowAt(AnchorX, AnchorY);
end;

procedure TCWSMenuWindow.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Arrow, Idx: Integer;
begin
  inherited;
  Arrow := ArrowAt(Point(X, Y));
  if Arrow <> FHotArrow then
  begin
    FHotArrow := Arrow;
    if FHotArrow <> 0 then StartScrollTimer else StopScrollTimer;
  end;
  if Arrow <> 0 then begin SetHot(-1); Exit; end;

  Idx := IndexAt(Point(X, Y));
  if not Selectable(Idx) then Idx := -1;
  if Idx <> FHotIndex then
  begin
    SetHot(Idx);
    { open / close the submenu depending on the item }
    if (Idx >= 0) and (FEntries[Idx].Item.Count > 0) then
      OpenSubmenu(Idx)
    else
      CloseChild;
  end;
end;

procedure TCWSMenuWindow.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  Idx: Integer;
begin
  inherited;
  if Button <> mbLeft then Exit;
  Idx := IndexAt(Point(X, Y));
  if not Selectable(Idx) then Exit;
  if FEntries[Idx].Item.Count > 0 then
    OpenSubmenu(Idx)
  else
    ActivateItem(Idx);
end;

procedure TCWSMenuWindow.CMMouseLeave(var Msg: TMessage);
begin
  inherited;
  FHotArrow := 0;
  StopScrollTimer;
  { do not clear the highlight if the cursor entered an open submenu }
  if FChildWin = nil then SetHot(-1);
end;

procedure TCWSMenuWindow.ActivateItem(AIdx: Integer);
var
  It: TMenuItem;
begin
  if not Selectable(AIdx) then Exit;
  It := FEntries[AIdx].Item;
  if GRootWin <> nil then GRootWin.CloseChain;
  It.Click;
end;

procedure TCWSMenuWindow.KeyAction(AKey: Word);
var
  D: TCWSMenuWindow;
  i, Cur, n, Step: Integer;
begin
  D := Deepest;   { keys go to the deepest window }
  n := Length(D.FEntries);

  case AKey of
    VK_ESCAPE:
      D.CloseChain;

    VK_LEFT:
      if D.FParentWin <> nil then D.CloseChain;

    VK_RIGHT:
      if (D.FHotIndex >= 0) and (D.FHotIndex <= High(D.FEntries)) and
         (D.FEntries[D.FHotIndex].Item.Count > 0) then
      begin
        D.OpenSubmenu(D.FHotIndex);
        if (D.FChildWin <> nil) then
          with D.FChildWin do
            for i := 0 to High(FEntries) do
              if Selectable(i) then begin SetHot(i); EnsureVisible(i); Render; Break; end;
      end;

    VK_RETURN:
      if (D.FHotIndex >= 0) and (D.FHotIndex <= High(D.FEntries)) then
      begin
        if D.FEntries[D.FHotIndex].Item.Count > 0 then KeyAction(VK_RIGHT)
        else D.ActivateItem(D.FHotIndex);
      end;

    VK_HOME, VK_END, VK_DOWN, VK_UP:
      begin
        if n = 0 then Exit;
        if AKey = VK_HOME then
        begin
          for i := 0 to n - 1 do if D.Selectable(i) then begin D.SetHot(i); D.EnsureVisible(i); D.Render; Break; end;
          Exit;
        end;
        if AKey = VK_END then
        begin
          for i := n - 1 downto 0 do if D.Selectable(i) then begin D.SetHot(i); D.EnsureVisible(i); D.Render; Break; end;
          Exit;
        end;
        Step := IfThen(AKey = VK_DOWN, 1, -1);
        Cur := D.FHotIndex;
        if Cur < 0 then if Step > 0 then Cur := -1 else Cur := n;
        i := Cur;
        repeat
          i := i + Step;
          if i < 0 then i := n - 1;
          if i > n - 1 then i := 0;
          if D.Selectable(i) then
          begin
            D.SetHot(i);
            D.EnsureVisible(i);
            D.Render;
            Exit;
          end;
        until i = Cur;
      end;
  end;
end;

{ ════════════════════════════════════════════════════════════════════════════
    TCWSPopupMenu
  ════════════════════════════════════════════════════════════════════════════ }

constructor TCWSPopupMenu.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFont := TFont.Create;
  FFont.Name := 'Segoe UI';
  FFont.Size := 9;
  FBackgroundColor    := $00F9F9F9;
  FBorderColor        := $00E5E5E5;
  FTextColor          := $001A1A1A;
  FDisabledTextColor  := $00A0A0A0;
  FHighlightColor     := $00EFEFEF;
  FHighlightTextColor := $001A1A1A;
  FSeparatorColor     := $00E5E5E5;
  FShortCutColor      := $008A8A8A;
  FCornerRadius       := 8;
  FItemHeight         := 34;
  FBorderThickness    := 1;
  FShadowEnabled      := True;
  FShadowSize         := 18;
  FMaxVisibleItems    := 0;
end;

destructor TCWSPopupMenu.Destroy;
begin
  CloseMenu;
  FRootWin.Free;
  FFont.Free;
  inherited;
end;

procedure TCWSPopupMenu.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TCWSPopupMenu.DoClose;
begin
  inherited;
  if Assigned(FOnClose) then FOnClose(Self);
end;

procedure TCWSPopupMenu.Popup(X, Y: Integer);
begin
  if csDesigning in ComponentState then Exit;
  CloseMenu;
  if Assigned(OnPopup) then OnPopup(Self);
  if Items.Count = 0 then Exit;

  if GOpenMenus = nil then GOpenMenus := TList<TCWSMenuWindow>.Create;
  if FRootWin = nil then
    FRootWin := TCWSMenuWindow.CreateForMenu(Self, Items, nil);

  FRootWin.ShowAt(X, Y);
  if GOpenMenus.Count > 0 then
    InstallMenuHooks(FRootWin);
end;

procedure TCWSPopupMenu.CloseMenu;
begin
  if (FRootWin <> nil) and FRootWin.HandleAllocated and
     IsWindowVisible(FRootWin.Handle) then
    FRootWin.CloseChain;
end;

initialization

finalization
  FreeAndNil(GOpenMenus);

end.
