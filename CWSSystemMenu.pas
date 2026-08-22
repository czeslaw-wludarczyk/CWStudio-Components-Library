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
unit CWSSystemMenu;

{ Replaces the native window system menu — the one shown by Alt+Space, by
  clicking the title-bar icon and by right-clicking the caption — with a
  TCWSPopupMenu rendered in the CWStudio style.

  Drop the component on a form. It hooks the form's WindowProc, swallows the
  messages that would make Windows draw its own menu, and shows the CWS popup
  instead. Item captions, accelerators, order and any entries the application
  appended with AppendMenu(GetSystemMenu(...)) are read straight from the real
  system menu, so the menu stays localised and complete. Enabled/disabled state
  is recomputed from the window styles, because Windows only refreshes the
  system menu's own state while it is tracking it.

  Choosing an item posts WM_SYSCOMMAND to the form, exactly like the native
  menu — including SC_MOVE / SC_SIZE, which enter the keyboard drag loop.

  What this component does NOT change: the caption bar itself and its buttons
  (still drawn by Windows), and the taskbar thumbnail menu (drawn by the shell
  in its own process). }

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.Types,
  { System.UITypes last: Vcl.ImgList carries a deprecated TImageIndex alias }
  Vcl.Controls, Vcl.Graphics, Vcl.Menus, Vcl.Forms, Vcl.ImgList, System.UITypes,
  CWSPopupMenu;

type
  TCWSSystemMenu = class;

  { Which standard system command an item stands for. sckCustom covers entries
    the application appended to the system menu itself and items taken from
    ExtraMenu. }
  TCWSSysCommandKind = (sckCustom, sckRestore, sckMove, sckSize, sckMinimize,
    sckMaximize, sckClose);

  { smtIcon                — left click on the title-bar icon
    smtCaptionRightClick   — right click on the caption / caption buttons
    smtAltSpace            — Alt+Space (and Alt+minus on an MDI child)
    smtIconDblClickCloses  — double click on the icon closes the form, as in
                             classic Windows (kept because smtIcon swallows the
                             first click) }
  TCWSSysMenuTrigger = (smtIcon, smtCaptionRightClick, smtAltSpace,
    smtIconDblClickCloses);
  TCWSSysMenuTriggers = set of TCWSSysMenuTrigger;

  { Fires before WM_SYSCOMMAND is posted. Set AHandled to True to take over. }
  TCWSSysCommandEvent = procedure(Sender: TObject; ACommand: UINT;
    AKind: TCWSSysCommandKind; var AHandled: Boolean) of object;

  { Item of the generated menu. Carries either a WM_SYSCOMMAND id or a
    reference to the ExtraMenu item it proxies. }
  TCWSSysMenuItem = class(TMenuItem)
  private
    FCommand: UINT;
    FKind: TCWSSysCommandKind;
    FSource: TMenuItem;
  public
    property Command: UINT read FCommand;
    property Kind: TCWSSysCommandKind read FKind;
    property Source: TMenuItem read FSource;
  end;

  TCWSSystemMenu = class(TComponent)
  strict private
    FPopup: TCWSPopupMenu;
    FForm: TCustomForm;
    FOldWndProc: TWndMethod;
    FHooked: Boolean;
    FShowing: Boolean;
    FClosedTick: Cardinal;
    FMsgWnd: HWND;
    FPendingCommand: UINT;
    FExecTicks: Integer;
    FExecTimerOn: Boolean;

    FActive: Boolean;
    FTriggers: TCWSSysMenuTriggers;
    FUseSystemCaptions: Boolean;
    FCaptions: array[TCWSSysCommandKind] of string;
    FImageIndexes: array[TCWSSysCommandKind] of TImageIndex;
    FExtraMenu: TPopupMenu;

    FOnPopup: TNotifyEvent;
    FOnClose: TNotifyEvent;
    FOnCommand: TCWSSysCommandEvent;

    procedure HookForm;
    procedure UnhookForm;
    procedure HookWndProc(var Msg: TMessage);

    procedure ClearItems;
    procedure BuildItems;
    procedure AppendFromHMenu(AMenu: HMENU; AParent: TMenuItem);
    procedure AppendDefaultItems(AParent: TMenuItem);
    procedure AppendExtraItems;
    procedure CloneItems(ASrc, ADst: TMenuItem);
    procedure ApplyStates(AParent: TMenuItem);

    procedure ShowMenu(const APoint: TPoint; AGuarded: Boolean);
    procedure DoPopupClose(Sender: TObject);
    procedure SysItemClick(Sender: TObject);
    procedure QueueCommand(ACommand: UINT);
    procedure MsgWndProc(var Msg: TMessage);
    function MenuAnchorPoint: TPoint;

    { pass-through accessors for the visual properties of the inner popup }
    function GetFont: TFont;
    procedure SetFont(const Value: TFont);
    function GetImages: TCustomImageList;
    procedure SetImages(const Value: TCustomImageList);
    function GetColorProp(AIndex: Integer): TColor;
    procedure SetColorProp(AIndex: Integer; const Value: TColor);
    function GetIntProp(AIndex: Integer): Integer;
    procedure SetIntProp(AIndex: Integer; const Value: Integer);
    function GetShadowEnabled: Boolean;
    procedure SetShadowEnabled(const Value: Boolean);

    function GetCaption(AIndex: Integer): string;
    procedure SetCaption(AIndex: Integer; const Value: string);
    function GetImageIndex(AIndex: Integer): TImageIndex;
    procedure SetImageIndex(AIndex: Integer; const Value: TImageIndex);

    procedure SetActive(const Value: Boolean);
    procedure SetExtraMenu(const Value: TPopupMenu);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    { called from the module-level keyboard hook }
    function HandleAcceleratorKey(AKey: Word): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { Attaches to a form other than the Owner — for components created at
      runtime. Detaches from the previous one. }
    procedure Attach(AForm: TCustomForm);
    { Shows the menu under the caption, as Alt+Space would. }
    procedure Popup;
    { Shows the menu at a screen point. }
    procedure PopupAt(const APoint: TPoint);
    procedure CloseMenu;

    property Showing: Boolean read FShowing;
    { The menu doing the drawing — for anything not surfaced as a property. }
    property Menu: TCWSPopupMenu read FPopup;
  published
    property Active: Boolean read FActive write SetActive default True;
    property Triggers: TCWSSysMenuTriggers read FTriggers write FTriggers
      default [smtIcon, smtCaptionRightClick, smtAltSpace, smtIconDblClickCloses];
    { True  — captions, accelerators and order come from the real system menu
              (localised, includes AppendMenu entries)
      False — the six Caption* properties below are used }
    property UseSystemCaptions: Boolean read FUseSystemCaptions
      write FUseSystemCaptions default True;
    { Items appended under a separator. Design them in an ordinary popup menu;
      clicking a copy fires the original item's OnClick. Use the same image
      list as Images, otherwise ImageIndex values will not match. }
    property ExtraMenu: TPopupMenu read FExtraMenu write SetExtraMenu;

    property CaptionRestore: string index Ord(sckRestore)
      read GetCaption write SetCaption;
    property CaptionMove: string index Ord(sckMove)
      read GetCaption write SetCaption;
    property CaptionSize: string index Ord(sckSize)
      read GetCaption write SetCaption;
    property CaptionMinimize: string index Ord(sckMinimize)
      read GetCaption write SetCaption;
    property CaptionMaximize: string index Ord(sckMaximize)
      read GetCaption write SetCaption;
    property CaptionClose: string index Ord(sckClose)
      read GetCaption write SetCaption;

    { The six ImageIndex properties are TImageIndex, so the Object Inspector
      offers the CWStudio icon picker instead of a bare number: the drop-down
      lists every image of Images with its glyph, its index and — for lists that
      expose names, e.g. TVirtualImageList — its name. }
    property Images: TCustomImageList read GetImages write SetImages;
    property ImageIndexRestore: TImageIndex index Ord(sckRestore)
      read GetImageIndex write SetImageIndex default -1;
    property ImageIndexMove: TImageIndex index Ord(sckMove)
      read GetImageIndex write SetImageIndex default -1;
    property ImageIndexSize: TImageIndex index Ord(sckSize)
      read GetImageIndex write SetImageIndex default -1;
    property ImageIndexMinimize: TImageIndex index Ord(sckMinimize)
      read GetImageIndex write SetImageIndex default -1;
    property ImageIndexMaximize: TImageIndex index Ord(sckMaximize)
      read GetImageIndex write SetImageIndex default -1;
    property ImageIndexClose: TImageIndex index Ord(sckClose)
      read GetImageIndex write SetImageIndex default -1;

    { ── look of the popup — forwarded to the inner TCWSPopupMenu ─────────── }
    property Font: TFont read GetFont write SetFont;
    property BackgroundColor: TColor index 0 read GetColorProp write SetColorProp default $00F9F9F9;
    property BorderColor: TColor index 1 read GetColorProp write SetColorProp default $00E5E5E5;
    property TextColor: TColor index 2 read GetColorProp write SetColorProp default $001A1A1A;
    property DisabledTextColor: TColor index 3 read GetColorProp write SetColorProp default $00A0A0A0;
    property HighlightColor: TColor index 4 read GetColorProp write SetColorProp default $00EFEFEF;
    property HighlightTextColor: TColor index 5 read GetColorProp write SetColorProp default $001A1A1A;
    property SeparatorColor: TColor index 6 read GetColorProp write SetColorProp default $00E5E5E5;
    property ShortCutColor: TColor index 7 read GetColorProp write SetColorProp default $008A8A8A;
    property CornerRadius: Integer index 0 read GetIntProp write SetIntProp default 8;
    property ItemHeight: Integer index 1 read GetIntProp write SetIntProp default 34;
    property BorderThickness: Integer index 2 read GetIntProp write SetIntProp default 1;
    property ShadowSize: Integer index 3 read GetIntProp write SetIntProp default 18;
    property MaxVisibleItems: Integer index 4 read GetIntProp write SetIntProp default 0;
    property ShadowEnabled: Boolean read GetShadowEnabled write SetShadowEnabled default True;

    property OnPopup: TNotifyEvent read FOnPopup write FOnPopup;
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
    property OnCommand: TCWSSysCommandEvent read FOnCommand write FOnCommand;
  end;

implementation

const
  { Winapi.Windows does not declare this one in every RAD Studio version. }
  MAPVK_VK_TO_CHAR_ = 2;
  { toggle guard: a click on the icon that closed an open menu must not
    reopen it — the WH_MOUSE hook of CWSPopupMenu closes the menu before the
    NC message reaches the form }
  REOPEN_GUARD_MS = 250;
  { deferred dispatch of WM_SYSCOMMAND — see QueueCommand }
  EXEC_TIMER_ID = 1;
  EXEC_TIMER_MS = 15;
  EXEC_TIMER_MAX_TICKS = 200;   { ~3 s cap, so a held button cannot wedge us }

type
  TGetDpiForWindowFunc = function(AWnd: HWND): UINT; stdcall;
  TAdjustWindowRectExForDpiFunc = function(var ARect: TRect; AStyle: DWORD;
    AMenu: BOOL; AExStyle: DWORD; ADpi: UINT): BOOL; stdcall;

var
  GGetDpiForWindow: TGetDpiForWindowFunc = nil;
  GAdjustWindowRectExForDpi: TAdjustWindowRectExForDpiFunc = nil;
  { the single menu that is open right now, plus its accelerator hook }
  GActiveSysMenu: TCWSSystemMenu = nil;
  GSysKeyHook: HHOOK = 0;

{ ════════════════════════════════════════════════════════════════════════════
    Helpers
  ════════════════════════════════════════════════════════════════════════════ }

function KindOfCommand(ACommand: UINT): TCWSSysCommandKind;
begin
  case ACommand and $FFF0 of
    SC_RESTORE:  Result := sckRestore;
    SC_MOVE:     Result := sckMove;
    SC_SIZE:     Result := sckSize;
    SC_MINIMIZE: Result := sckMinimize;
    SC_MAXIMIZE: Result := sckMaximize;
    SC_CLOSE:    Result := sckClose;
  else
    Result := sckCustom;
  end;
end;

{ Letter marked with '&' in a caption; '&&' is a literal ampersand. }
function AccelCharOf(const ACaption: string): Char;
var
  i: Integer;
begin
  Result := #0;
  i := 1;
  while i < Length(ACaption) do
  begin
    if ACaption[i] = '&' then
    begin
      if ACaption[i + 1] = '&' then
        Inc(i, 2)
      else
        Exit(ACaption[i + 1]);
    end
    else
      Inc(i);
  end;
end;

function VKeyToChar(AKey: Word): Char;
var
  C: Cardinal;
begin
  C := MapVirtualKey(AKey, MAPVK_VK_TO_CHAR_) and $7FFF;
  if C = 0 then
    Result := #0
  else
    Result := Char(Word(C));
end;

function SameChar(A, B: Char): Boolean;
begin
  Result := (A <> #0) and (B <> #0) and SameText(A, B);
end;

function IsCaptionHitTest(AHitTest: Integer): Boolean;
begin
  case AHitTest of
    HTCAPTION, HTSYSMENU, HTMINBUTTON, HTMAXBUTTON, HTCLOSE, HTHELP:
      Result := True;
  else
    Result := False;
  end;
end;

{ Accelerator keys while the menu is open. Installed after TCWSPopupMenu's own
  hook, so this one sits at the head of the chain; its CallNextHookEx still
  reaches the navigation hook underneath (that hook also calls the chain first,
  so the order is not critical). Everything else is swallowed — the menu window
  is WS_EX_NOACTIVATE, so unhandled keys would otherwise land in the form. }
function SysMenuKeyHookProc(nCode: Integer; wParam: WPARAM;
  lParam: LPARAM): LRESULT; stdcall;
begin
  Result := CallNextHookEx(GSysKeyHook, nCode, wParam, lParam);
  if (nCode <> HC_ACTION) or (GActiveSysMenu = nil) then
    Exit;

  { Modifiers are never touched, neither down nor up: swallowing a modifier
    key-up leaves the application believing the key is still held. }
  case Word(wParam) of
    VK_SHIFT, VK_CONTROL, VK_MENU, VK_LWIN, VK_RWIN:
      Exit;
  end;

  { Key-up is swallowed but never acted on. This has to be tested before the
    ALT check below, otherwise releasing Space after Alt+Space — which still
    reports ALT as held — would close the menu the instant it opened. }
  if (lParam and (1 shl 31)) <> 0 then
  begin
    Result := 1;
    Exit;
  end;

  { bit 29 = ALT held on a key-down: Alt+F4, Alt+Tab, Alt+Space again — close
    and let it through, exactly like a real menu }
  if (lParam and (1 shl 29)) <> 0 then
  begin
    GActiveSysMenu.CloseMenu;
    Exit;
  end;

  case Word(wParam) of
    VK_ESCAPE, VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT, VK_RETURN, VK_HOME, VK_END:
      { navigation — handled by the hook inside CWSPopupMenu };
  else
    begin
      GActiveSysMenu.HandleAcceleratorKey(Word(wParam));
      Result := 1;
    end;
  end;
end;

{ ════════════════════════════════════════════════════════════════════════════
    TCWSSystemMenu
  ════════════════════════════════════════════════════════════════════════════ }

constructor TCWSSystemMenu.Create(AOwner: TComponent);
var
  K: TCWSSysCommandKind;
begin
  inherited Create(AOwner);
  FActive := True;
  FTriggers := [smtIcon, smtCaptionRightClick, smtAltSpace,
    smtIconDblClickCloses];
  FUseSystemCaptions := True;

  for K := Low(TCWSSysCommandKind) to High(TCWSSysCommandKind) do
    FImageIndexes[K] := -1;
  FCaptions[sckRestore]  := '&Restore';
  FCaptions[sckMove]     := '&Move';
  FCaptions[sckSize]     := '&Size';
  FCaptions[sckMinimize] := 'Mi&nimize';
  FCaptions[sckMaximize] := 'Ma&ximize';
  FCaptions[sckClose]    := '&Close';

  FPopup := TCWSPopupMenu.Create(Self);
  FPopup.SetSubComponent(True);
  FPopup.OnClose := DoPopupClose;

  if not (csDesigning in ComponentState) then
    FMsgWnd := AllocateHWnd(MsgWndProc);   { carries the dispatch timer }

  if (AOwner is TCustomForm) and not (csDesigning in ComponentState) then
    Attach(TCustomForm(AOwner));
end;

destructor TCWSSystemMenu.Destroy;
begin
  if FShowing then
    FPopup.CloseMenu;
  if GActiveSysMenu = Self then
  begin
    GActiveSysMenu := nil;
    if GSysKeyHook <> 0 then
    begin
      UnhookWindowsHookEx(GSysKeyHook);
      GSysKeyHook := 0;
    end;
  end;
  UnhookForm;
  if FMsgWnd <> 0 then
  begin
    if FExecTimerOn then
    begin
      KillTimer(FMsgWnd, EXEC_TIMER_ID);
      FExecTimerOn := False;
    end;
    DeallocateHWnd(FMsgWnd);
    FMsgWnd := 0;
  end;
  inherited Destroy;
end;

procedure TCWSSystemMenu.Attach(AForm: TCustomForm);
begin
  if FForm = AForm then
    Exit;
  UnhookForm;
  FForm := AForm;
  if FForm <> nil then
  begin
    FForm.FreeNotification(Self);
    if not (csDesigning in ComponentState) then
      HookForm;
  end;
end;

procedure TCWSSystemMenu.HookForm;
begin
  if FHooked or (FForm = nil) then
    Exit;
  FOldWndProc := FForm.WindowProc;
  FForm.WindowProc := HookWndProc;
  FHooked := True;
end;

procedure TCWSSystemMenu.UnhookForm;
begin
  if not FHooked then
  begin
    FForm := nil;
    Exit;
  end;
  { If something else hooked after us, restoring would drop that hook — but
    leaving ours in place would call into a freed object, which is worse. }
  if FForm <> nil then
    FForm.WindowProc := FOldWndProc;
  FOldWndProc := nil;
  FHooked := False;
  FForm := nil;
end;

procedure TCWSSystemMenu.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  { during our own teardown FPopup may already be gone }
  if csDestroying in ComponentState then
    Exit;
  if Operation = opRemove then
  begin
    if AComponent = FForm then
    begin
      { the form is going away — drop the hook without touching it }
      FOldWndProc := nil;
      FHooked := False;
      FForm := nil;
    end;
    if AComponent = FExtraMenu then
      FExtraMenu := nil;
    if AComponent = FPopup.Images then
      FPopup.Images := nil;
  end;
end;

{ ── message hook ─────────────────────────────────────────────────────────── }

procedure TCWSSystemMenu.HookWndProc(var Msg: TMessage);
var
  Handled: Boolean;
  Pt: TPoint;
begin
  Handled := False;

  if FActive and (FForm <> nil) then
    case Msg.Msg of

      WM_NCLBUTTONDOWN:
        if (smtIcon in FTriggers) and (NativeInt(Msg.WParam) = HTSYSMENU) then
        begin
          ShowMenu(MenuAnchorPoint, True);
          Handled := True;
        end;

      WM_NCLBUTTONDBLCLK:
        { the system still generates the double click even though we swallowed
          the first button-down, so the classic "double click the icon to
          close" has to be reproduced here }
        if (smtIcon in FTriggers) and (NativeInt(Msg.WParam) = HTSYSMENU) then
        begin
          if (smtIconDblClickCloses in FTriggers) and FForm.HandleAllocated and
             ((GetClassLong(FForm.Handle, GCL_STYLE) and CS_NOCLOSE) = 0) then
          begin
            CloseMenu;
            PostMessage(FForm.Handle, WM_SYSCOMMAND, SC_CLOSE, 0);
          end;
          Handled := True;
        end;

      WM_NCRBUTTONDOWN:
        { swallowed so DefWindowProc does not start tracking its own menu }
        if (smtCaptionRightClick in FTriggers) and
           IsCaptionHitTest(Integer(Msg.WParam)) then
          Handled := True;

      WM_NCRBUTTONUP:
        if (smtCaptionRightClick in FTriggers) and
           IsCaptionHitTest(Integer(Msg.WParam)) then
        begin
          Pt := Point(SmallInt(LoWord(Cardinal(Msg.LParam))),
                      SmallInt(HiWord(Cardinal(Msg.LParam))));
          ShowMenu(Pt, True);
          Handled := True;
        end;

      WM_SYSCOMMAND:
        case Cardinal(Msg.WParam) and $FFF0 of
          SC_KEYMENU:
            { lParam carries the character: space, or minus on an MDI child.
              lParam = 0 is plain Alt/F10 opening the main menu — leave it,
              unless our menu is up, in which case releasing Alt must not drop
              into the main menu bar behind the popup. }
            if FShowing then
              Handled := True
            else if (smtAltSpace in FTriggers) and
               ((Msg.LParam = VK_SPACE) or (Msg.LParam = Ord('-'))) then
            begin
              ShowMenu(MenuAnchorPoint, True);
              Handled := True;
            end;
          SC_MOUSEMENU:
            if smtIcon in FTriggers then
            begin
              ShowMenu(MenuAnchorPoint, True);
              Handled := True;
            end;
        end;

      WM_SIZE, WM_MOVE, WM_ACTIVATEAPP, WM_KILLFOCUS, WM_DESTROY:
        { not handled — only closed, then passed on }
        if FShowing then
          CloseMenu;
    end;

  if Handled then
    Msg.Result := 0
  else if Assigned(FOldWndProc) then
    FOldWndProc(Msg);
end;

{ ── building the items ───────────────────────────────────────────────────── }

procedure TCWSSystemMenu.ClearItems;
var
  i: Integer;
begin
  { freeing a TMenuItem unregisters it from its parent and its owner }
  for i := FPopup.Items.Count - 1 downto 0 do
    FPopup.Items.Items[i].Free;
end;

procedure TCWSSystemMenu.BuildItems;
var
  H: HMENU;
begin
  ClearItems;
  H := 0;
  if FUseSystemCaptions and (FForm <> nil) and FForm.HandleAllocated then
    { False = do not reset; this is the application's own copy of the menu,
      including anything appended with AppendMenu }
    H := GetSystemMenu(FForm.Handle, False);

  if (H <> 0) and (GetMenuItemCount(H) > 0) then
    AppendFromHMenu(H, FPopup.Items)
  else
    AppendDefaultItems(FPopup.Items);

  ApplyStates(FPopup.Items);
  AppendExtraItems;
end;

procedure TCWSSystemMenu.AppendFromHMenu(AMenu: HMENU; AParent: TMenuItem);
var
  i, Cnt, TabPos: Integer;
  MII: TMenuItemInfo;
  Buf: array[0..511] of Char;
  Item: TCWSSysMenuItem;
  Cap, ShortText: string;
begin
  Cnt := GetMenuItemCount(AMenu);
  for i := 0 to Cnt - 1 do
  begin
    FillChar(MII, SizeOf(MII), 0);
    MII.cbSize := SizeOf(MII);
    MII.fMask := MIIM_FTYPE or MIIM_STATE or MIIM_ID or MIIM_SUBMENU or
      MIIM_STRING;
    Buf[0] := #0;
    MII.dwTypeData := PChar(@Buf[0]);
    MII.cch := Length(Buf);
    if not GetMenuItemInfo(AMenu, i, True, MII) then
      Continue;

    Item := TCWSSysMenuItem.Create(FPopup);
    Item.FCommand := MII.wID;
    Item.FKind := KindOfCommand(MII.wID);

    if (MII.fType and MFT_SEPARATOR) <> 0 then
      Item.Caption := '-'
    else
    begin
      { the buffer is null-terminated — take it as PChar, not as a fixed array }
      Cap := PChar(@Buf[0]);
      ShortText := '';
      TabPos := Pos(#9, Cap);
      if TabPos > 0 then
      begin
        ShortText := Trim(Copy(Cap, TabPos + 1, MaxInt));
        Cap := Copy(Cap, 1, TabPos - 1);
      end;
      Item.Caption := Cap;

      if ShortText <> '' then
      begin
        { TextToShortCut only understands VCL's own key names; when the system
          spells them differently the one shortcut that matters is rebuilt. }
        Item.ShortCut := TextToShortCut(ShortText);
        if (Item.ShortCut = 0) and (Item.FKind = sckClose) then
          Item.ShortCut := Vcl.Menus.ShortCut(VK_F4, [ssAlt]);
      end;

      Item.Enabled := (MII.fState and MFS_GRAYED) = 0;
      Item.Checked := (MII.fState and MFS_CHECKED) <> 0;
      Item.Default := (MII.fState and MFS_DEFAULT) <> 0;

      if MII.hSubMenu <> 0 then
      begin
        Item.FCommand := 0;
        AppendFromHMenu(MII.hSubMenu, Item);
      end
      else
        Item.OnClick := SysItemClick;
    end;

    AParent.Add(Item);
  end;
end;

procedure TCWSSystemMenu.AppendDefaultItems(AParent: TMenuItem);

  procedure AddOne(AKind: TCWSSysCommandKind; ACommand: UINT);
  var
    Item: TCWSSysMenuItem;
  begin
    Item := TCWSSysMenuItem.Create(FPopup);
    Item.FCommand := ACommand;
    Item.FKind := AKind;
    Item.Caption := FCaptions[AKind];
    Item.OnClick := SysItemClick;
    if AKind = sckClose then
      Item.ShortCut := Vcl.Menus.ShortCut(VK_F4, [ssAlt]);
    AParent.Add(Item);
  end;

  procedure AddSeparator;
  var
    Item: TCWSSysMenuItem;
  begin
    Item := TCWSSysMenuItem.Create(FPopup);
    Item.Caption := '-';
    AParent.Add(Item);
  end;

begin
  AddOne(sckRestore, SC_RESTORE);
  AddOne(sckMove, SC_MOVE);
  AddOne(sckSize, SC_SIZE);
  AddOne(sckMinimize, SC_MINIMIZE);
  AddOne(sckMaximize, SC_MAXIMIZE);
  AddSeparator;
  AddOne(sckClose, SC_CLOSE);
end;

{ Windows only refreshes the state of the system menu while it is tracking it,
  so reading MFS_GRAYED back would give stale values. The six standard entries
  therefore follow the window styles directly; anything else keeps whatever the
  application set on the HMENU. }
procedure TCWSSystemMenu.ApplyStates(AParent: TMenuItem);
var
  i: Integer;
  It: TCWSSysMenuItem;
  H: HWND;
  Style: DWORD;
  Zoomed, Minimized, CanSize, CanMin, CanMax, CanClose: Boolean;
begin
  if (FForm = nil) or not FForm.HandleAllocated then
    Exit;
  H := FForm.Handle;
  Style := GetWindowLong(H, GWL_STYLE);
  Zoomed := IsZoomed(H);
  Minimized := IsIconic(H);
  CanSize := (Style and WS_THICKFRAME) <> 0;
  CanMin := (Style and WS_MINIMIZEBOX) <> 0;
  CanMax := (Style and WS_MAXIMIZEBOX) <> 0;
  CanClose := (GetClassLong(H, GCL_STYLE) and CS_NOCLOSE) = 0;

  for i := 0 to AParent.Count - 1 do
  begin
    if not (AParent.Items[i] is TCWSSysMenuItem) then
      Continue;
    It := TCWSSysMenuItem(AParent.Items[i]);
    if It.IsLine then
      Continue;

    case It.FKind of
      sckRestore:  It.Enabled := Zoomed or Minimized;
      sckMove:     It.Enabled := not Zoomed;
      sckSize:     It.Enabled := CanSize and not Zoomed and not Minimized;
      sckMinimize: It.Enabled := CanMin and not Minimized;
      sckMaximize: It.Enabled := CanMax and not Zoomed;
      sckClose:    It.Enabled := CanClose;
    end;

    if It.FKind <> sckCustom then
      It.ImageIndex := FImageIndexes[It.FKind];
  end;
end;

procedure TCWSSystemMenu.AppendExtraItems;
var
  Sep: TCWSSysMenuItem;
begin
  if (FExtraMenu = nil) or (FExtraMenu.Items.Count = 0) then
    Exit;
  { ImageIndex values in the cloned items refer to ExtraMenu's own list. If no
    list was given to this component, borrow that one — otherwise the indexes
    would silently point into a different list. }
  if (FPopup.Images = nil) and (FExtraMenu.Images <> nil) then
    FPopup.Images := FExtraMenu.Images;
  if FPopup.Items.Count > 0 then
  begin
    Sep := TCWSSysMenuItem.Create(FPopup);
    Sep.Caption := '-';
    FPopup.Items.Add(Sep);
  end;
  CloneItems(FExtraMenu.Items, FPopup.Items);
end;

{ ExtraMenu items cannot be re-parented into the popup, so proxies are created
  and their clicks forwarded to the originals. }
procedure TCWSSystemMenu.CloneItems(ASrc, ADst: TMenuItem);
var
  i: Integer;
  S: TMenuItem;
  D: TCWSSysMenuItem;
begin
  for i := 0 to ASrc.Count - 1 do
  begin
    S := ASrc.Items[i];
    if Assigned(S.Action) then
      S.InitiateAction;
    if not S.Visible then
      Continue;

    D := TCWSSysMenuItem.Create(FPopup);
    D.FKind := sckCustom;
    D.FSource := S;
    D.Caption := S.Caption;
    D.ShortCut := S.ShortCut;
    D.Enabled := S.Enabled;
    D.Checked := S.Checked;
    D.RadioItem := S.RadioItem;
    D.ImageIndex := S.ImageIndex;
    ADst.Add(D);

    if S.Count > 0 then
      CloneItems(S, D)
    else
      D.OnClick := SysItemClick;
  end;
end;

{ ── showing / dismissing ─────────────────────────────────────────────────── }

{ Top-left corner of the client area in screen coordinates: the frame metrics
  come from the window's own styles, so caption height, border width and DPI
  are all accounted for without hard-coded numbers. bMenu is deliberately False
  — we want the point just under the caption, above any menu bar. }
function TCWSSystemMenu.MenuAnchorPoint: TPoint;
var
  H: HWND;
  WR, FR: TRect;
  Style, ExStyle: DWORD;
  Dpi: UINT;
  Ok: Boolean;
begin
  Result := Mouse.CursorPos;
  if (FForm = nil) or not FForm.HandleAllocated then
    Exit;
  H := FForm.Handle;
  if IsIconic(H) then
    Exit;
  if not GetWindowRect(H, WR) then
    Exit;

  Style := GetWindowLong(H, GWL_STYLE) and not DWORD(WS_HSCROLL or WS_VSCROLL);
  ExStyle := GetWindowLong(H, GWL_EXSTYLE);
  FR := Rect(0, 0, 0, 0);

  Ok := False;
  if Assigned(GAdjustWindowRectExForDpi) and Assigned(GGetDpiForWindow) then
  begin
    Dpi := GGetDpiForWindow(H);
    if Dpi = 0 then
      Dpi := 96;
    Ok := GAdjustWindowRectExForDpi(FR, Style, False, ExStyle, Dpi);
  end;
  if not Ok then
  begin
    FR := Rect(0, 0, 0, 0);
    if not AdjustWindowRectEx(FR, Style, False, ExStyle) then
      Exit;
  end;

  Result := Point(WR.Left - FR.Left, WR.Top - FR.Top);
end;

procedure TCWSSystemMenu.ShowMenu(const APoint: TPoint; AGuarded: Boolean);
begin
  if FShowing or not FActive then
    Exit;
  if (FForm = nil) or not FForm.HandleAllocated then
    Exit;
  { The input that just dismissed the menu must not reopen it: the click that
    closes it still travels on to the caption, and Alt+Space toggles. Only the
    programmatic Popup/PopupAt bypass this. }
  if AGuarded and (GetTickCount - FClosedTick < REOPEN_GUARD_MS) then
    Exit;
  if GActiveSysMenu <> nil then
    GActiveSysMenu.CloseMenu;

  BuildItems;
  if FPopup.Items.Count = 0 then
    Exit;
  if Assigned(FOnPopup) then
    FOnPopup(Self);

  { Popup closes any previous menu first, which would fire DoPopupClose — so
    the showing flag is raised only once the window is really up. }
  FPopup.Popup(APoint.X, APoint.Y);
  FShowing := True;
  GActiveSysMenu := Self;

  if GSysKeyHook = 0 then
    GSysKeyHook := SetWindowsHookEx(WH_KEYBOARD, @SysMenuKeyHookProc, 0,
      GetCurrentThreadId);
end;

procedure TCWSSystemMenu.DoPopupClose(Sender: TObject);
begin
  if not FShowing then
    Exit;
  FShowing := False;
  FClosedTick := GetTickCount;
  if GActiveSysMenu = Self then
  begin
    GActiveSysMenu := nil;
    if GSysKeyHook <> 0 then
    begin
      UnhookWindowsHookEx(GSysKeyHook);
      GSysKeyHook := 0;
    end;
  end;
  if Assigned(FOnClose) then
    FOnClose(Self);
end;

procedure TCWSSystemMenu.Popup;
begin
  ShowMenu(MenuAnchorPoint, False);
end;

procedure TCWSSystemMenu.PopupAt(const APoint: TPoint);
begin
  ShowMenu(APoint, False);
end;

procedure TCWSSystemMenu.CloseMenu;
begin
  if FShowing then
    FPopup.CloseMenu;
end;

function TCWSSystemMenu.HandleAcceleratorKey(AKey: Word): Boolean;
var
  i, Found: Integer;
  Ch: Char;
  It: TMenuItem;
begin
  Result := False;
  Ch := VKeyToChar(AKey);
  if Ch = #0 then
    Exit;

  Found := -1;
  for i := 0 to FPopup.Items.Count - 1 do
  begin
    It := FPopup.Items.Items[i];
    if It.IsLine or not It.Visible or not It.Enabled then
      Continue;
    if SameChar(AccelCharOf(It.Caption), Ch) then
    begin
      Found := i;
      Break;
    end;
  end;
  if Found < 0 then
    Exit;

  It := FPopup.Items.Items[Found];
  CloseMenu;
  It.Click;
  Result := True;
end;

procedure TCWSSystemMenu.SysItemClick(Sender: TObject);
var
  It: TCWSSysMenuItem;
  Handled: Boolean;
begin
  if not (Sender is TCWSSysMenuItem) then
    Exit;
  It := TCWSSysMenuItem(Sender);
  if not It.Enabled then
    Exit;

  { TCWSMenuWindow is a TCustomControl, so csCaptureMouse makes VCL call
    SetCapture on button-down — and DefWindowProc silently drops every SC_*
    command while any window of this thread holds the mouse capture. Without
    this release, clicking an item did nothing while Enter worked fine. User
    handlers get a clean state too: a ShowModal under a live capture misbehaves. }
  if GetCapture <> 0 then
    ReleaseCapture;

  Handled := False;
  if Assigned(FOnCommand) then
    FOnCommand(Self, It.FCommand, It.FKind, Handled);
  if Handled then
    Exit;

  if It.FSource <> nil then
    It.FSource.Click
  else if It.FCommand <> 0 then
  begin
    { Only the two commands that spin a modal loop need the deferral — see
      QueueCommand. Everything else is a plain state change and goes out now,
      so callers do not have to wait a message cycle for it to take effect. }
    case It.FCommand and $FFF0 of
      SC_MOVE, SC_SIZE:
        QueueCommand(It.FCommand);
    else
      if (FForm <> nil) and FForm.HandleAllocated then
        PostMessage(FForm.Handle, WM_SYSCOMMAND, It.FCommand, 0);
    end;
  end;
end;

{ SC_MOVE / SC_SIZE cannot be dispatched straight from the click.

  TCWSMenuWindow activates an item on button-DOWN, so the matching button-UP is
  still on its way. Both commands start a modal drag loop that pumps its own
  messages, sees that stray button-up and instantly treats it as "drag
  finished" — the mode switched on and off again in the same breath. The native
  menu never hits this because it commits on button-up.

  So the command waits for a WM_TIMER. Windows only delivers WM_TIMER once the
  queue has run dry, which guarantees the pending input has been dispatched;
  on top of that we hold off until no mouse button is physically down. }
procedure TCWSSystemMenu.QueueCommand(ACommand: UINT);
begin
  FPendingCommand := ACommand;
  FExecTicks := 0;

  if FMsgWnd <> 0 then
  begin
    if not FExecTimerOn then
      FExecTimerOn := SetTimer(FMsgWnd, EXEC_TIMER_ID, EXEC_TIMER_MS, nil) <> 0;
    if FExecTimerOn then
      Exit;
  end;

  { no private window or SetTimer refused — dispatch straight away }
  FPendingCommand := 0;
  if (FForm <> nil) and FForm.HandleAllocated then
    PostMessage(FForm.Handle, WM_SYSCOMMAND, ACommand, 0);
end;

procedure TCWSSystemMenu.MsgWndProc(var Msg: TMessage);
var
  Cmd: UINT;
begin
  if (Msg.Msg = WM_TIMER) and (Msg.WParam = EXEC_TIMER_ID) then
  begin
    Inc(FExecTicks);
    if (FExecTicks < EXEC_TIMER_MAX_TICKS) and
       (((GetAsyncKeyState(VK_LBUTTON) and $8000) <> 0) or
        ((GetAsyncKeyState(VK_RBUTTON) and $8000) <> 0)) then
    begin
      Msg.Result := 0;
      Exit;
    end;

    KillTimer(FMsgWnd, EXEC_TIMER_ID);
    FExecTimerOn := False;
    Cmd := FPendingCommand;
    FPendingCommand := 0;
    { lParam = 0 selects the keyboard variant of SC_MOVE / SC_SIZE, exactly as
      the native menu does }
    if (Cmd <> 0) and (FForm <> nil) and FForm.HandleAllocated then
      PostMessage(FForm.Handle, WM_SYSCOMMAND, Cmd, 0);
    Msg.Result := 0;
    Exit;
  end;
  Msg.Result := DefWindowProc(FMsgWnd, Msg.Msg, Msg.WParam, Msg.LParam);
end;

{ ── property plumbing ────────────────────────────────────────────────────── }

procedure TCWSSystemMenu.SetActive(const Value: Boolean);
begin
  if FActive = Value then
    Exit;
  FActive := Value;
  if not FActive then
    CloseMenu;
end;

procedure TCWSSystemMenu.SetExtraMenu(const Value: TPopupMenu);
begin
  if FExtraMenu = Value then
    Exit;
  if FExtraMenu <> nil then
    FExtraMenu.RemoveFreeNotification(Self);
  FExtraMenu := Value;
  if FExtraMenu <> nil then
    FExtraMenu.FreeNotification(Self);
end;

function TCWSSystemMenu.GetCaption(AIndex: Integer): string;
begin
  Result := FCaptions[TCWSSysCommandKind(AIndex)];
end;

procedure TCWSSystemMenu.SetCaption(AIndex: Integer; const Value: string);
begin
  FCaptions[TCWSSysCommandKind(AIndex)] := Value;
end;

function TCWSSystemMenu.GetImageIndex(AIndex: Integer): TImageIndex;
begin
  Result := FImageIndexes[TCWSSysCommandKind(AIndex)];
end;

procedure TCWSSystemMenu.SetImageIndex(AIndex: Integer; const Value: TImageIndex);
begin
  FImageIndexes[TCWSSysCommandKind(AIndex)] := Value;
end;

function TCWSSystemMenu.GetFont: TFont;
begin
  Result := FPopup.Font;
end;

procedure TCWSSystemMenu.SetFont(const Value: TFont);
begin
  FPopup.Font := Value;
end;

function TCWSSystemMenu.GetImages: TCustomImageList;
begin
  Result := FPopup.Images;
end;

procedure TCWSSystemMenu.SetImages(const Value: TCustomImageList);
begin
  if FPopup.Images = Value then
    Exit;
  if FPopup.Images <> nil then
    FPopup.Images.RemoveFreeNotification(Self);
  FPopup.Images := Value;
  if Value <> nil then
    Value.FreeNotification(Self);
end;

function TCWSSystemMenu.GetColorProp(AIndex: Integer): TColor;
begin
  case AIndex of
    0: Result := FPopup.BackgroundColor;
    1: Result := FPopup.BorderColor;
    2: Result := FPopup.TextColor;
    3: Result := FPopup.DisabledTextColor;
    4: Result := FPopup.HighlightColor;
    5: Result := FPopup.HighlightTextColor;
    6: Result := FPopup.SeparatorColor;
    7: Result := FPopup.ShortCutColor;
  else
    Result := clNone;
  end;
end;

procedure TCWSSystemMenu.SetColorProp(AIndex: Integer; const Value: TColor);
begin
  case AIndex of
    0: FPopup.BackgroundColor := Value;
    1: FPopup.BorderColor := Value;
    2: FPopup.TextColor := Value;
    3: FPopup.DisabledTextColor := Value;
    4: FPopup.HighlightColor := Value;
    5: FPopup.HighlightTextColor := Value;
    6: FPopup.SeparatorColor := Value;
    7: FPopup.ShortCutColor := Value;
  end;
end;

function TCWSSystemMenu.GetIntProp(AIndex: Integer): Integer;
begin
  case AIndex of
    0: Result := FPopup.CornerRadius;
    1: Result := FPopup.ItemHeight;
    2: Result := FPopup.BorderThickness;
    3: Result := FPopup.ShadowSize;
    4: Result := FPopup.MaxVisibleItems;
  else
    Result := 0;
  end;
end;

procedure TCWSSystemMenu.SetIntProp(AIndex: Integer; const Value: Integer);
begin
  case AIndex of
    0: FPopup.CornerRadius := Value;
    1: FPopup.ItemHeight := Value;
    2: FPopup.BorderThickness := Value;
    3: FPopup.ShadowSize := Value;
    4: FPopup.MaxVisibleItems := Value;
  end;
end;

function TCWSSystemMenu.GetShadowEnabled: Boolean;
begin
  Result := FPopup.ShadowEnabled;
end;

procedure TCWSSystemMenu.SetShadowEnabled(const Value: Boolean);
begin
  FPopup.ShadowEnabled := Value;
end;

{ ════════════════════════════════════════════════════════════════════════════ }

procedure LoadDpiApi;
var
  Lib: HMODULE;
begin
  Lib := GetModuleHandle(user32);
  if Lib = 0 then
    Exit;
  @GGetDpiForWindow := GetProcAddress(Lib, 'GetDpiForWindow');
  @GAdjustWindowRectExForDpi := GetProcAddress(Lib, 'AdjustWindowRectExForDpi');
end;

initialization
  LoadDpiApi;

finalization
  if GSysKeyHook <> 0 then
  begin
    UnhookWindowsHookEx(GSysKeyHook);
    GSysKeyHook := 0;
  end;

end.
