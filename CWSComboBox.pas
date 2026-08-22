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
unit CWSComboBox;

{
  TCWSComboBox — Windows 11 / WinUI3 style ComboBox
  - Style: csDropDown (editable) / csDropDownList (list only, like VCL)
  - csDropDownList: text rendered with GDI+, focus on combo, default cursor
  - csDropDown: embedded TCWSBufferedEdit from CWSEdit
  - Dropdown with its own scrollbar
  - AutoSizeHeight
  - Keyboard navigation
}

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  Winapi.MultiMon, System.SysUtils, System.StrUtils, System.Classes,
  System.Types, System.Math, Vcl.Controls, Vcl.Graphics, Vcl.StdCtrls,
  Vcl.Forms, Vcl.ExtCtrls, CWSEdit, System.UITypes;

const
  WM_CWS_CLOSEDROPDOWN = WM_USER + 201;
  CM_PPICHANGED = $B080 + 13;

type
  TCWSComboBox = class;

  TCWSComboStyle = (csDropDown, csDropDownList);

  { ════════════════════════════════════════════════════════════════════════
      Popup dropdown
    ════════════════════════════════════════════════════════════════════════ }
  TCWSDropdownWindow = class(TCustomControl)
  private
    FCombo: TCWSComboBox;
    FHoveredIndex: Integer;
    FScrollPos: Integer;
    FScrollDragging: Boolean;
    FScrollDragStartY: Integer;
    FScrollDragStartPos: Integer;
    FScrollAreaHovered: Boolean;

    { Track-click auto-repeat (holding the button on the track keeps paging
      toward the cursor until the thumb reaches it — the native scrollbar feel) }
    FRepeatTimer: TTimer;
    FRepeatActive: Boolean;
    FRepeatDir: Integer;
    FRepeatStarted: Boolean;

    { Geometria okna warstwowego (per-pixel alpha) }
    FScale: Single;
    FDpi: Integer;
    FBlur, FShadowOffset, FShadow: Integer;
    FMarginTop, FMarginBottom, FMarginSide: Integer;
    FBodyW, FBodyH, FWinW, FWinH: Integer;
    FWinLeft, FWinTop: Integer;
    FBodyScreen: TRect;            { screen rect of the list BODY (without shadow) }
    FOpenedUp: Boolean;           { list opened upwards (no room below)            }
    FShadowBits: TBytes;          { buffered ARGB shadow channel (alpha)           }
    FHasShadow: Boolean;
    FCtrlLocal: TRect;            { ComboBox rect in window coordinates             }
    FCtrlScreen: TRect;          { ComboBox screen rect (click pass-through)        }

    function ScalePx(V: Integer): Integer;
    function BodyLeft: Integer;
    function BodyTop: Integer;
    function CornerRadiusPx: Single;
    function GetItemH: Integer;
    function GetPaddH: Integer;
    function GetPaddV: Integer;
    function GetScrollAreaW: Integer;
    function GetScrollThumbW: Integer;
    function GetContentH: Integer;
    function GetVisibleH: Integer;
    function GetMaxScroll: Integer;
    function GetThumbH: Integer;
    function GetThumbY: Integer;
    function GetThumbRect: TRect;                 { coordinates relative to the body }
    function GetItemRect(Index: Integer): TRect;  { coordinates relative to the body }
    function IndexAtBodyY(BY: Integer): Integer;  { BY = Y relative to the body }
    function IsInScrollArea(BX: Integer): Boolean;{ BX = X relative to the body }
    function MakeGPColor(C: TColor; A: Byte = 255): Cardinal;
    function CreateRRPath(X, Y, W, H, R: Single): TGPGraphicsPath;
    procedure ComputeScale;
    function CalcBodyHeight(MaxItems: Integer): Integer;
    procedure BuildShadow;
    procedure ClampScroll;
    procedure ScrollByDelta(Delta: Integer);
    procedure StartTrackRepeat(Dir: Integer);
    procedure StopTrackRepeat;
    procedure RepeatTimerTick(Sender: TObject);
    procedure Render;

    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMMouseWheel(var Msg: TWMMouseWheel); message WM_MOUSEWHEEL;
    procedure WMLButtonDown(var Msg: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Msg: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMMouseMove(var Msg: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMCaptureChanged(var Msg: TMessage); message WM_CAPTURECHANGED;
    procedure WMMouseActivate(var Msg: TWMMouseActivate); message WM_MOUSEACTIVATE;
    procedure WMCWSClose(var Msg: TMessage); message WM_CWS_CLOSEDROPDOWN;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(ACombo: TCWSComboBox); reintroduce;
    destructor Destroy; override;
    procedure ShowPopup(X, Y, W, MaxItems: Integer);
    procedure HidePopup;
    procedure ScrollToItem(Index: Integer);
    procedure MoveHover(Delta: Integer);
    function HoveredIndex: Integer;
  end;

  { ════════════════════════════════════════════════════════════════════════
      ComboBox
    ════════════════════════════════════════════════════════════════════════ }
  TCWSComboBox = class(TCustomControl)
  private
    FItems: TStringList;
    FItemIndex: Integer;
    FDroppedDown: Boolean;
    FDropUp: Boolean;          { list opened upwards (above the ComboBox) }
    FDropdown: TCWSDropdownWindow;
    FBuffer: TBitmap;
    FHovered: Boolean;
    FFocused: Boolean;

    { Mode }
    FStyle: TCWSComboStyle;
    FInternalEdit: TCWSBufferedEdit;
    FEditWndProc: TWndMethod; { saved WindowProc of FInternalEdit (ESC hook) }
    FEditInternalMarginL: Integer; { internal left margin of TEdit (EM_GETMARGINS) }

    { Main field appearance }
    FCornerRadius: Single;
    FBorderColor: TColor;
    FBackgroundColor: TColor;
    FBackgroundHoverColor: TColor;
    FDisabledColor: TColor;
    FDisabledBorderColor: TColor;
    FAccentColor: TColor;
    FTextColor: TColor;
    FDisabledTextColor: TColor;

    { AutoSizeHeight }
    FAutoSizeHeight: Boolean;

    { Dropdown appearance }
    FDropdownBackColor: TColor;
    FDropdownBorderColor: TColor;
    FDropDownMaxItem: Integer;
    FItemHeight: Integer;
    FDropdownCornerRadius: Single;
    FDropdownShadowEnabled: Boolean;
    FDropdownShadowSize: Integer;

    { Item appearance }
    FItemHighlightColor: TColor;
    FItemHighlightPressedColor: TColor;
    FItemHighlightTextColor: TColor;
    FItemNormalTextColor: TColor;
    FItemHighlightCornerRadius: Single;

    { Scrollbar }
    FScrollbarThumbColor: TColor;
    FScrollbarThumbHoverColor: TColor;
    FScrollbarAreaWidth: Integer;
    FScrollbarThumbWidth: Integer;
    FScrollbarThumbHoverWidth: Integer;

    { Standard }
    FTextHint: string;
    FSorted: Boolean;

    { VCL-compatible edit behaviour }
    FAutoComplete: Boolean;
    FAutoCompleteDelay: Cardinal;
    FAutoCloseUp: Boolean;
    FAutoDropDown: Boolean;
    FCharCase: TEditCharCase;
    FMaxLength: Integer;
    FReadOnly: Boolean;
    FAllowAutoComplete: Boolean;   { armed on KeyPress — only typed chars complete }
    FInternalTextChange: Boolean;  { guard: our own edit updates are not user input }
    FSearchText: string;           { incremental search buffer (csDropDownList)     }
    FSearchTick: Cardinal;
    FPreviewIndex: Integer;        { item previewed in the field while dropped down }
    FDropStartText: string;        { field text when the list opened — ESC restores }

    { Events }
    FOnChange: TNotifyEvent;
    FOnDropDown: TNotifyEvent;
    FOnCloseUp: TNotifyEvent;
    FOnSelect: TNotifyEvent;
    FOnKeyPress: TKeyPressEvent;
    FOnKeyDown: TKeyEvent;
    FOnKeyUp: TKeyEvent;

    { Getters / Setters }
    function GetItems: TStrings;
    function GetText: string;
    function GetDisplayText: string;
    procedure SetPreviewIndex(Value: Integer);
    procedure SetText(const Value: string);
    function GetItemCount: Integer;
    procedure SetItemIndex(Value: Integer);
    procedure SetItems(Value: TStrings);
    procedure SetSorted(Value: Boolean);
    procedure SetDroppedDown(Value: Boolean);
    procedure SetStyle(const Value: TCWSComboStyle);
    procedure SetCornerRadius(const Value: Single);
    procedure SetAccentColor(const Value: TColor);
    procedure SetBackgroundColor(const Value: TColor);
    procedure SetBackgroundHoverColor(const Value: TColor);
    procedure SetBorderColor(const Value: TColor);
    procedure SetDisabledColor(const Value: TColor);
    procedure SetDisabledBorderColor(const Value: TColor);
    procedure SetTextColor(const Value: TColor);
    procedure SetDisabledTextColor(const Value: TColor);
    procedure SetDropdownBackColor(const Value: TColor);
    procedure SetDropdownBorderColor(const Value: TColor);
    procedure SetDropDownMaxItem(const Value: Integer);
    procedure SetItemHeight(const Value: Integer);
    procedure SetDropdownCornerRadius(const Value: Single);
    procedure SetDropdownShadowEnabled(const Value: Boolean);
    procedure SetDropdownShadowSize(const Value: Integer);
    procedure SetItemHighlightColor(const Value: TColor);
    procedure SetItemHighlightPressedColor(const Value: TColor);
    procedure SetItemHighlightTextColor(const Value: TColor);
    procedure SetItemNormalTextColor(const Value: TColor);
    procedure SetItemHighlightCornerRadius(const Value: Single);
    procedure SetScrollbarThumbColor(const Value: TColor);
    procedure SetScrollbarThumbHoverColor(const Value: TColor);
    procedure SetScrollbarAreaWidth(const Value: Integer);
    procedure SetScrollbarThumbWidth(const Value: Integer);
    procedure SetScrollbarThumbHoverWidth(const Value: Integer);
    procedure SetTextHint(const Value: string);
    procedure SetAutoSizeHeight(const Value: Boolean);
    procedure SetCharCase(const Value: TEditCharCase);
    procedure SetMaxLength(const Value: Integer);
    procedure SetReadOnly(const Value: Boolean);
    function  GetDropDownCount: Integer;
    procedure SetDropDownCount(const Value: Integer);
    function  GetSelStart: Integer;
    procedure SetSelStart(const Value: Integer);
    function  GetSelLength: Integer;
    procedure SetSelLength(const Value: Integer);
    function  GetSelText: string;
    procedure SetSelText(const Value: string);

    { Pomocnicze }
    function GetCurrentBgColor: TColor;
    function GetCurrentBorderColor: TColor;
    function GetParentBgColor: TColor;
    procedure DrawParentBackground(DC: HDC; ARadius: Single);
    function MakeGPColor(AColor: TColor; Alpha: Byte = 255): Cardinal;
    function CreateRoundRectPath(X, Y, W, H, R: Single): TGPGraphicsPath;
    function Scale(Value: Integer): Integer;
    function ScaleF(Value: Single): Single;
    function GetTextMarginL: Integer;

    procedure AdjustHeight;
    procedure EnsureBuffer;
    procedure PaintToBuffer;
    procedure ApplyStateChange;
    procedure ItemsChanged(Sender: TObject);
    procedure OpenDropdown;
    procedure CloseDropdown(Cancel: Boolean = False);
    procedure CreateEdit;
    procedure DestroyEdit;
    procedure UpdateEditPosition;
    procedure SyncEditAppearance;
    procedure SyncEditProperties;
    procedure SetEditTextSilent(const S: string; ASelectAll: Boolean = False);

    { Auto-complete / incremental search }
    function  FindItemByPrefix(const Prefix: string; StartIdx: Integer = 0): Integer;
    function  DoAutoComplete: Boolean;
    procedure UpdateItemIndexFromText;
    procedure SyncDropdownHover;

    { Edit handlers — csDropDown only }
    procedure EditChange(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure EditMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure EditSubclassProc(var Message: TMessage);

    { Messages }
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Msg: TMessage); message CM_FONTCHANGED;
    procedure CMParentFontChanged(var Msg: TMessage); message CM_PARENTFONTCHANGED;
    procedure CMPPIChanged(var Msg: TMessage); message CM_PPICHANGED;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
    procedure WMGetDlgCode(var Msg: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure CNKeyDown(var Msg: TWMKeyDown); message CN_KEYDOWN;
    procedure WMKeyDown(var Msg: TWMKeyDown); message WM_KEYDOWN;
    procedure WMKeyUp(var Msg: TWMKeyUp); message WM_KEYUP;
    procedure WMChar(var Msg: TWMChar); message WM_CHAR;

  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;
    procedure Resize; override;
    procedure Loaded; override;
    procedure SetEnabled(Value: Boolean); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure ChangeScale(M, D: Integer); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddItem(const S: string; AObject: TObject = nil);
    procedure Clear;
    procedure CloseUp;
    procedure DropDown;
    function Focused: Boolean; override;
    procedure SelectItem(Index: Integer);

    { Edit operations — csDropDown only, no-ops in csDropDownList }
    procedure SelectAll;
    procedure ClearSelection;
    procedure CopyToClipboard;
    procedure CutToClipboard;
    procedure PasteFromClipboard;

    property ItemCount: Integer read GetItemCount;
    property DroppedDown: Boolean read FDroppedDown write SetDroppedDown;
    property SelStart: Integer read GetSelStart write SetSelStart;
    property SelLength: Integer read GetSelLength write SetSelLength;
    property SelText: string read GetSelText write SetSelText;

  published
    property Style: TCWSComboStyle read FStyle write SetStyle default csDropDownList;
    property AutoSizeHeight: Boolean read FAutoSizeHeight write SetAutoSizeHeight default True;

    { Main field appearance }
    property CornerRadius: Single read FCornerRadius write SetCornerRadius;
    property AccentColor: TColor read FAccentColor write SetAccentColor default $D47800;
    property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor default clWhite;
    property BackgroundHoverColor: TColor read FBackgroundHoverColor write SetBackgroundHoverColor default $F9F9F9;
    property BorderColor: TColor read FBorderColor write SetBorderColor default $D6D6D6;
    property DisabledColor: TColor read FDisabledColor write SetDisabledColor default $F7F7F7;
    property DisabledBorderColor: TColor read FDisabledBorderColor write SetDisabledBorderColor default $E0E0E0;
    property TextColor: TColor read FTextColor write SetTextColor default $202020;
    property DisabledTextColor: TColor read FDisabledTextColor write SetDisabledTextColor default $A0A0A0;

    { Dropdown appearance }
    property DropdownBackColor: TColor read FDropdownBackColor write SetDropdownBackColor default clWhite;
    property DropdownBorderColor: TColor read FDropdownBorderColor write SetDropdownBorderColor default $D6D6D6;
    property DropDownMaxItem: Integer read FDropDownMaxItem write SetDropDownMaxItem default 8;
    property ItemHeight: Integer read FItemHeight write SetItemHeight default 36;
    property DropdownCornerRadius: Single read FDropdownCornerRadius write SetDropdownCornerRadius;
    property DropdownShadowEnabled: Boolean read FDropdownShadowEnabled write SetDropdownShadowEnabled default True;
    property DropdownShadowSize: Integer read FDropdownShadowSize write SetDropdownShadowSize default 18;

    { Item appearance }
    property ItemHighlightColor: TColor read FItemHighlightColor write SetItemHighlightColor default $E8E8E8;
    property ItemHighlightPressedColor: TColor read FItemHighlightPressedColor write SetItemHighlightPressedColor default $DADADA;
    property ItemHighlightTextColor: TColor read FItemHighlightTextColor write SetItemHighlightTextColor default $0D0D0D;
    property ItemNormalTextColor: TColor read FItemNormalTextColor write SetItemNormalTextColor default $202020;
    property ItemHighlightCornerRadius: Single read FItemHighlightCornerRadius write SetItemHighlightCornerRadius;

    { Scrollbar }
    property ScrollbarThumbColor: TColor read FScrollbarThumbColor write SetScrollbarThumbColor default $C0C0C0;
    property ScrollbarThumbHoverColor: TColor read FScrollbarThumbHoverColor write SetScrollbarThumbHoverColor default $909090;
    property ScrollbarAreaWidth: Integer read FScrollbarAreaWidth write SetScrollbarAreaWidth default 14;
    property ScrollbarThumbWidth: Integer read FScrollbarThumbWidth write SetScrollbarThumbWidth default 4;
    property ScrollbarThumbHoverWidth: Integer read FScrollbarThumbHoverWidth write SetScrollbarThumbHoverWidth default 6;

    { Standard }
    property Items: TStrings read GetItems write SetItems;
    property Text: string read GetText write SetText;
    property TextHint: string read FTextHint write SetTextHint;
    property Sorted: Boolean read FSorted write SetSorted default False;

    { VCL TComboBox compatible behaviour }
    property AutoComplete: Boolean read FAutoComplete write FAutoComplete default True;
    property AutoCompleteDelay: Cardinal read FAutoCompleteDelay write FAutoCompleteDelay default 500;
    property AutoCloseUp: Boolean read FAutoCloseUp write FAutoCloseUp default False;
    property AutoDropDown: Boolean read FAutoDropDown write FAutoDropDown default False;
    property CharCase: TEditCharCase read FCharCase write SetCharCase default ecNormal;
    property MaxLength: Integer read FMaxLength write SetMaxLength default 0;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    { VCL-named alias of DropDownMaxItem — not streamed, DropDownMaxItem is }
    property DropDownCount: Integer read GetDropDownCount write SetDropDownCount stored False default 8;

    { Standard VCL }
    property Action;
    property Align;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property Cursor;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property Hint;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Touch;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGesture;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnStartDock;
    property OnStartDrag;
    property ItemIndex: Integer read FItemIndex write SetItemIndex;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnDropDown: TNotifyEvent read FOnDropDown write FOnDropDown;
    property OnCloseUp: TNotifyEvent read FOnCloseUp write FOnCloseUp;
    property OnSelect: TNotifyEvent read FOnSelect write FOnSelect;
    property OnKeyDown: TKeyEvent read FOnKeyDown write FOnKeyDown;
    property OnKeyUp: TKeyEvent read FOnKeyUp write FOnKeyUp;
    property OnKeyPress: TKeyPressEvent read FOnKeyPress write FOnKeyPress;
  end;

implementation

type
  TControlAccess = class(TControl);

const
  ULW_ALPHA = $00000002;
  { Peak shadow opacity (0..255) — soft, like in WinUI 3 / CWSPopupMenu. }
  DROPDOWN_SHADOW_ALPHA = 86;
  EVENT_SYSTEM_FOREGROUND_ = $0003;
  WINEVENT_OUTOFCONTEXT_   = $0000;

{ List body path with selectively rounded corners — the edge adjacent to the
  ComboBox accent line stays straight (RoundTop/RoundBottom = False). }
function CreateBodyPath(X, Y, W, H, R: Single;
  RoundTop, RoundBottom: Boolean): TGPGraphicsPath;
var
  D, rTL, rTR, rBR, rBL: Single;
begin
  Result := TGPGraphicsPath.Create;
  D := R;
  if D * 2 > W then D := W / 2;
  if D * 2 > H then D := H / 2;
  if D < 0 then D := 0;
  if D = 0 then
  begin
    Result.AddRectangle(MakeRect(X, Y, W, H));
    Exit;
  end;
  if RoundTop then begin rTL := D; rTR := D; end else begin rTL := 0; rTR := 0; end;
  if RoundBottom then begin rBR := D; rBL := D; end else begin rBR := 0; rBL := 0; end;

  Result.StartFigure;
  { top-left corner }
  if rTL > 0 then Result.AddArc(X, Y, 2 * rTL, 2 * rTL, 180, 90);
  { top edge }
  Result.AddLine(X + rTL, Y, X + W - rTR, Y);
  { top-right corner }
  if rTR > 0 then Result.AddArc(X + W - 2 * rTR, Y, 2 * rTR, 2 * rTR, 270, 90);
  { right edge }
  Result.AddLine(X + W, Y + rTR, X + W, Y + H - rBR);
  { bottom-right corner }
  if rBR > 0 then Result.AddArc(X + W - 2 * rBR, Y + H - 2 * rBR, 2 * rBR, 2 * rBR, 0, 90);
  { bottom edge }
  Result.AddLine(X + W - rBR, Y + H, X + rBL, Y + H);
  { bottom-left corner }
  if rBL > 0 then Result.AddArc(X, Y + H - 2 * rBL, 2 * rBL, 2 * rBL, 90, 90);
  { left edge }
  Result.AddLine(X, Y + H - rBL, X, Y + rTL);
  Result.CloseFigure;
end;

{ Open border path — omits the edge adjacent to the ComboBox accent line.
  OmitTop = True: no top edge (list opened downwards),
  OmitTop = False: no bottom edge (list opened upwards). }
function CreateBorderPath(X, Y, W, H, R: Single; OmitTop: Boolean): TGPGraphicsPath;
var
  D: Single;
begin
  Result := TGPGraphicsPath.Create;
  D := R;
  if D * 2 > W then D := W / 2;
  if D * 2 > H then D := H / 2;
  if D < 0 then D := 0;
  Result.StartFigure;
  if OmitTop then
  begin
    { top corners straight, top edge NOT drawn }
    Result.AddLine(X + W, Y, X + W, Y + H - D);                 { right edge }
    if D > 0 then Result.AddArc(X + W - 2 * D, Y + H - 2 * D, 2 * D, 2 * D, 0, 90);
    Result.AddLine(X + W - D, Y + H, X + D, Y + H);             { bottom edge }
    if D > 0 then Result.AddArc(X, Y + H - 2 * D, 2 * D, 2 * D, 90, 90);
    Result.AddLine(X, Y + H - D, X, Y);                         { left edge }
  end
  else
  begin
    { bottom corners straight, bottom edge NOT drawn }
    Result.AddLine(X, Y + H, X, Y + D);                         { left edge }
    if D > 0 then Result.AddArc(X, Y, 2 * D, 2 * D, 180, 90);
    Result.AddLine(X + D, Y, X + W - D, Y);                     { top edge }
    if D > 0 then Result.AddArc(X + W - 2 * D, Y, 2 * D, 2 * D, 270, 90);
    Result.AddLine(X + W, Y + D, X + W, Y + H);                 { right edge }
  end;
end;

{ Body path with an independent radius for each corner. }
function CreateBodyPath4(X, Y, W, H, rTL, rTR, rBR, rBL: Single): TGPGraphicsPath;

  function Clamp(R: Single): Single;
  begin
    if R < 0 then R := 0;
    if R * 2 > W then R := W / 2;
    if R * 2 > H then R := H / 2;
    Result := R;
  end;

begin
  Result := TGPGraphicsPath.Create;
  rTL := Clamp(rTL); rTR := Clamp(rTR); rBR := Clamp(rBR); rBL := Clamp(rBL);
  Result.StartFigure;
  if rTL > 0 then Result.AddArc(X, Y, 2 * rTL, 2 * rTL, 180, 90);
  Result.AddLine(X + rTL, Y, X + W - rTR, Y);
  if rTR > 0 then Result.AddArc(X + W - 2 * rTR, Y, 2 * rTR, 2 * rTR, 270, 90);
  Result.AddLine(X + W, Y + rTR, X + W, Y + H - rBR);
  if rBR > 0 then Result.AddArc(X + W - 2 * rBR, Y + H - 2 * rBR, 2 * rBR, 2 * rBR, 0, 90);
  Result.AddLine(X + W - rBR, Y + H, X + rBL, Y + H);
  if rBL > 0 then Result.AddArc(X, Y + H - 2 * rBL, 2 * rBL, 2 * rBL, 90, 90);
  Result.AddLine(X, Y + H - rBL, X, Y + rTL);
  Result.CloseFigure;
end;

{ Open border path with independent corner radii and a GAP on the contact edge
  (top when GapTop = True; bottom otherwise). The gap covers only the actual
  contact with the ComboBox [GapL..GapR] (in path X coordinates), so the border
  is drawn on any protruding part of the edge while the free corner is rounded —
  the ComboBox side and the list form one continuous line. }
function CreateBorderPathGap(X, Y, W, H, rTL, rTR, rBR, rBL,
  GapL, GapR: Single; GapTop: Boolean): TGPGraphicsPath;
var
  gs, ge: Single;
begin
  Result := TGPGraphicsPath.Create;
  Result.StartFigure;
  if GapTop then
  begin
    gs := GapL; if gs < X + rTL then gs := X + rTL;
    ge := GapR; if ge > X + W - rTR then ge := X + W - rTR;
    if ge <= gs then
    begin
      { the whole contact covers the top → skip the entire top edge }
      Result.AddLine(X + W, Y, X + W, Y + H - rBR);
      if rBR > 0 then Result.AddArc(X + W - 2 * rBR, Y + H - 2 * rBR, 2 * rBR, 2 * rBR, 0, 90);
      Result.AddLine(X + W - rBR, Y + H, X + rBL, Y + H);
      if rBL > 0 then Result.AddArc(X, Y + H - 2 * rBL, 2 * rBL, 2 * rBL, 90, 90);
      Result.AddLine(X, Y + H - rBL, X, Y);
      Exit;
    end;
    Result.AddLine(ge, Y, X + W - rTR, Y);
    if rTR > 0 then Result.AddArc(X + W - 2 * rTR, Y, 2 * rTR, 2 * rTR, 270, 90);
    Result.AddLine(X + W, Y + rTR, X + W, Y + H - rBR);
    if rBR > 0 then Result.AddArc(X + W - 2 * rBR, Y + H - 2 * rBR, 2 * rBR, 2 * rBR, 0, 90);
    Result.AddLine(X + W - rBR, Y + H, X + rBL, Y + H);
    if rBL > 0 then Result.AddArc(X, Y + H - 2 * rBL, 2 * rBL, 2 * rBL, 90, 90);
    Result.AddLine(X, Y + H - rBL, X, Y + rTL);
    if rTL > 0 then Result.AddArc(X, Y, 2 * rTL, 2 * rTL, 180, 90);
    Result.AddLine(X + rTL, Y, gs, Y);
  end
  else
  begin
    gs := GapL; if gs < X + rBL then gs := X + rBL;
    ge := GapR; if ge > X + W - rBR then ge := X + W - rBR;
    if ge <= gs then
    begin
      { the whole contact covers the bottom → skip the entire bottom edge }
      Result.AddLine(X, Y + H, X, Y + rTL);
      if rTL > 0 then Result.AddArc(X, Y, 2 * rTL, 2 * rTL, 180, 90);
      Result.AddLine(X + rTL, Y, X + W - rTR, Y);
      if rTR > 0 then Result.AddArc(X + W - 2 * rTR, Y, 2 * rTR, 2 * rTR, 270, 90);
      Result.AddLine(X + W, Y + rTR, X + W, Y + H);
      Exit;
    end;
    Result.AddLine(gs, Y + H, X + rBL, Y + H);
    if rBL > 0 then Result.AddArc(X, Y + H - 2 * rBL, 2 * rBL, 2 * rBL, 90, 90);
    Result.AddLine(X, Y + H - rBL, X, Y + rTL);
    if rTL > 0 then Result.AddArc(X, Y, 2 * rTL, 2 * rTL, 180, 90);
    Result.AddLine(X + rTL, Y, X + W - rTR, Y);
    if rTR > 0 then Result.AddArc(X + W - 2 * rTR, Y, 2 * rTR, 2 * rTR, 270, 90);
    Result.AddLine(X + W, Y + rTR, X + W, Y + H - rBR);
    if rBR > 0 then Result.AddArc(X + W - 2 * rBR, Y + H - 2 * rBR, 2 * rBR, 2 * rBR, 0, 90);
    Result.AddLine(X + W - rBR, Y + H, ge, Y + H);
  end;
end;

{ ════════════════════════════════════════════════════════════════════════════
    Fluent shadow — rounded-rectangle silhouette + alpha-channel blur.
    (the same algorithms as in CWSPopupMenu)
  ════════════════════════════════════════════════════════════════════════════ }

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

{ As above, but each corner can have a different radius (rTL, rTR, rBL, rBR). }
procedure RasterRoundRectAlpha4(P: PByte; W, H, SX, SY, BW, BH,
  rTL, rTR, rBL, rBR: Integer);

  function ClampR(R: Integer): Integer;
  begin
    if R < 0 then R := 0;
    if R > BW div 2 then R := BW div 2;
    if R > BH div 2 then R := BH div 2;
    Result := R;
  end;

  function LeftInset(Y: Integer): Integer;
  var D: Integer;
  begin
    Result := 0;
    if (rTL > 0) and (Y < SY + rTL) then
    begin
      D := (SY + rTL) - Y;
      Result := rTL - Trunc(Sqrt(rTL * rTL - D * D) + 0.5);
    end
    else if (rBL > 0) and (Y > SY + BH - 1 - rBL) then
    begin
      D := Y - (SY + BH - 1 - rBL);
      Result := rBL - Trunc(Sqrt(rBL * rBL - D * D) + 0.5);
    end;
  end;

  function RightInset(Y: Integer): Integer;
  var D: Integer;
  begin
    Result := 0;
    if (rTR > 0) and (Y < SY + rTR) then
    begin
      D := (SY + rTR) - Y;
      Result := rTR - Trunc(Sqrt(rTR * rTR - D * D) + 0.5);
    end
    else if (rBR > 0) and (Y > SY + BH - 1 - rBR) then
    begin
      D := Y - (SY + BH - 1 - rBR);
      Result := rBR - Trunc(Sqrt(rBR * rBR - D * D) + 0.5);
    end;
  end;

var
  X, Y, X0, X1: Integer;
  Row: PByte;
begin
  if (BW <= 0) or (BH <= 0) then Exit;
  rTL := ClampR(rTL); rTR := ClampR(rTR);
  rBL := ClampR(rBL); rBR := ClampR(rBR);
  for Y := SY to SY + BH - 1 do
  begin
    if (Y < 0) or (Y >= H) then Continue;
    X0 := SX + LeftInset(Y);
    X1 := SX + BW - 1 - RightInset(Y);
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
    Mouse hook
  ════════════════════════════════════════════════════════════════════════════ }

var
  GMouseHook: HHOOK = 0;
  GFgEventHook: THandle = 0;
  GActiveDropdown: TCWSDropdownWindow = nil;

function MouseHookProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  pMHS: ^TMouseHookStruct;
  RDrop, RCombo: TRect;
begin
  Result := CallNextHookEx(GMouseHook, nCode, wParam, lParam);
  if (nCode >= HC_ACTION) and (GActiveDropdown <> nil) and
     GActiveDropdown.HandleAllocated then
  begin
    if (wParam = WM_LBUTTONDOWN) or (wParam = WM_RBUTTONDOWN) or
       (wParam = WM_NCLBUTTONDOWN) or (wParam = WM_NCRBUTTONDOWN) or
       (wParam = WM_MBUTTONDOWN) then
    begin
      pMHS := Pointer(lParam);
      { Compare against the list BODY rect (without the shadow margin), so that a
        click on the semi-transparent shadow also closes the list — as in CWSPopupMenu. }
      RDrop := GActiveDropdown.FBodyScreen;
      if not PtInRect(RDrop, pMHS^.pt) then
      begin
        { Don't close if the click is on the combo — the combo's MouseDown handles toggle }
        if (GActiveDropdown.FCombo <> nil) and
           GActiveDropdown.FCombo.HandleAllocated then
        begin
          GetWindowRect(GActiveDropdown.FCombo.Handle, RCombo);
          if PtInRect(RCombo, pMHS^.pt) then
            Exit;
        end;
        PostMessage(GActiveDropdown.Handle, WM_CWS_CLOSEDROPDOWN, 0, 0);
      end;
    end;
  end;
end;

{ App deactivation (Alt+Tab, clicking another app, minimizing)
  — close the list. The WH_MOUSE hook is thread-local and does not "see" clicks
  in other apps; only a foreground window change catches that. }
procedure DropdownWinEventProc(hHook: THandle; dwEvent: DWORD; hwnd: HWND;
  idObject, idChild: LongInt; idThread, dwmsTime: DWORD); stdcall;
begin
  if (dwEvent = EVENT_SYSTEM_FOREGROUND_) and (GActiveDropdown <> nil) and
     GActiveDropdown.HandleAllocated then
    PostMessage(GActiveDropdown.Handle, WM_CWS_CLOSEDROPDOWN, 0, 0);
end;

procedure InstallHook(ADropdown: TCWSDropdownWindow);
begin
  GActiveDropdown := ADropdown;
  if GMouseHook = 0 then
    GMouseHook := SetWindowsHookEx(WH_MOUSE, @MouseHookProc, 0, GetCurrentThreadId);
  if GFgEventHook = 0 then
    GFgEventHook := SetWinEventHook(EVENT_SYSTEM_FOREGROUND_, EVENT_SYSTEM_FOREGROUND_,
      0, @DropdownWinEventProc, 0, 0, WINEVENT_OUTOFCONTEXT_);
end;

procedure UninstallHook;
begin
  GActiveDropdown := nil;
  if GMouseHook <> 0 then
  begin
    UnhookWindowsHookEx(GMouseHook);
    GMouseHook := 0;
  end;
  if GFgEventHook <> 0 then
  begin
    UnhookWinEvent(GFgEventHook);
    GFgEventHook := 0;
  end;
end;

{ ════════════════════════════════════════════════════════════════════════════
    TCWSDropdownWindow
  ════════════════════════════════════════════════════════════════════════════ }

constructor TCWSDropdownWindow.Create(ACombo: TCWSComboBox);
begin
  inherited Create(nil);
  FCombo := ACombo;
  FHoveredIndex := -1;
  FScrollPos := 0;
  FScale := 1;
  FDpi := 96;
  Visible := False;

  FRepeatTimer := TTimer.Create(Self);
  FRepeatTimer.Enabled := False;
  FRepeatTimer.OnTimer := RepeatTimerTick;
end;

destructor TCWSDropdownWindow.Destroy;
begin
  if FRepeatTimer <> nil then
    FRepeatTimer.Enabled := False;
  if GActiveDropdown = Self then
    UninstallHook;
  inherited;
end;

procedure TCWSDropdownWindow.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := WS_POPUP;
  { WS_EX_LAYERED — per-pixel alpha window (rounded corners + soft shadow). }
  Params.ExStyle := WS_EX_TOOLWINDOW or WS_EX_TOPMOST or WS_EX_NOACTIVATE or
    WS_EX_LAYERED;
  Params.WndParent := GetDesktopWindow;
end;

procedure TCWSDropdownWindow.ComputeScale;
begin
  FDpi := FCombo.CurrentPPI;
  if FDpi <= 0 then FDpi := 96;
  FScale := FDpi / 96;
end;

function TCWSDropdownWindow.BodyLeft: Integer;
begin
  Result := FMarginSide;
end;

function TCWSDropdownWindow.BodyTop: Integer;
begin
  Result := FMarginTop;
end;

function TCWSDropdownWindow.CornerRadiusPx: Single;
begin
  Result := FCombo.FDropdownCornerRadius * FScale;
end;

function TCWSDropdownWindow.ScalePx(V: Integer): Integer;
begin
  Result := MulDiv(V, FCombo.CurrentPPI, 96);
end;

function TCWSDropdownWindow.GetItemH: Integer;
begin
  Result := FCombo.Scale(FCombo.FItemHeight);
end;

function TCWSDropdownWindow.GetPaddH: Integer;
begin
  Result := ScalePx(4);
end;

function TCWSDropdownWindow.GetPaddV: Integer;
begin
  Result := ScalePx(4);
end;

function TCWSDropdownWindow.GetScrollAreaW: Integer;
begin
  Result := ScalePx(FCombo.FScrollbarAreaWidth);
end;

function TCWSDropdownWindow.GetScrollThumbW: Integer;
begin
  if FScrollAreaHovered or FScrollDragging then
    Result := ScalePx(FCombo.FScrollbarThumbHoverWidth)
  else
    Result := ScalePx(FCombo.FScrollbarThumbWidth);
end;

function TCWSDropdownWindow.GetContentH: Integer;
begin
  Result := FCombo.FItems.Count * GetItemH;
end;

function TCWSDropdownWindow.GetVisibleH: Integer;
begin
  Result := FBodyH - GetPaddV * 2;
end;

function TCWSDropdownWindow.GetMaxScroll: Integer;
begin
  Result := Max(0, GetContentH - GetVisibleH);
end;

function TCWSDropdownWindow.GetThumbH: Integer;
var
  ContentH, VisibleH: Integer;
begin
  ContentH := GetContentH;
  VisibleH := GetVisibleH;
  if ContentH <= 0 then Exit(ScalePx(20));
  Result := Max(ScalePx(20), MulDiv(VisibleH, VisibleH, ContentH));
end;

function TCWSDropdownWindow.GetThumbY: Integer;
var
  MaxScroll, TrackH, ThumbH, MaxThumbY: Integer;
begin
  MaxScroll := GetMaxScroll;
  TrackH    := GetVisibleH;
  ThumbH    := GetThumbH;
  MaxThumbY := TrackH - ThumbH;
  if MaxScroll <= 0 then
    Result := GetPaddV
  else
    Result := GetPaddV + MulDiv(FScrollPos, MaxThumbY, MaxScroll);
end;

function TCWSDropdownWindow.GetThumbRect: TRect;
var
  ThumbW, ThumbH, ThumbY, ScrollW, OffX: Integer;
begin
  ScrollW := GetScrollAreaW;
  ThumbW  := GetScrollThumbW;
  ThumbH  := GetThumbH;
  ThumbY  := GetThumbY;
  OffX    := (ScrollW - ThumbW) div 2;
  Result  := Rect(
    FBodyW - ScrollW + OffX,
    ThumbY,
    FBodyW - ScrollW + OffX + ThumbW,
    ThumbY + ThumbH
  );
end;

function TCWSDropdownWindow.GetItemRect(Index: Integer): TRect;
var
  PaddH, PaddV, ItemH, Y: Integer;
begin
  PaddH := GetPaddH;
  PaddV := GetPaddV;
  ItemH := GetItemH;
  Y     := PaddV + Index * ItemH - FScrollPos;
  Result := Rect(PaddH, Y, FBodyW - PaddH, Y + ItemH);
  if GetMaxScroll > 0 then
    Result.Right := FBodyW - GetScrollAreaW;
end;

function TCWSDropdownWindow.IndexAtBodyY(BY: Integer): Integer;
var
  PaddV, ItemH, ContentH, Adjusted: Integer;
begin
  PaddV    := GetPaddV;
  ItemH    := GetItemH;
  ContentH := GetContentH;
  if ItemH <= 0 then Exit(-1);
  Adjusted := BY - PaddV + FScrollPos;
  if (Adjusted < 0) or (Adjusted >= ContentH) then Exit(-1);
  Result := Adjusted div ItemH;
  if (Result < 0) or (Result >= FCombo.FItems.Count) then
    Result := -1;
end;

function TCWSDropdownWindow.IsInScrollArea(BX: Integer): Boolean;
begin
  { Upper-bound to the body's right edge so the scroll column isn't detected out
    in the drop-shadow margin beyond the body (BX can run up to FBodyW + margin). }
  Result := (GetMaxScroll > 0) and (BX >= FBodyW - GetScrollAreaW) and (BX < FBodyW);
end;

function TCWSDropdownWindow.MakeGPColor(C: TColor; A: Byte): Cardinal;
var RGB: TColor;
begin
  RGB    := ColorToRGB(C);
  Result := Winapi.GDIPAPI.MakeColor(A, GetRValue(RGB), GetGValue(RGB), GetBValue(RGB));
end;

function TCWSDropdownWindow.CreateRRPath(X, Y, W, H, R: Single): TGPGraphicsPath;
var D: Single;
begin
  Result := TGPGraphicsPath.Create;
  if R <= 0 then begin Result.AddRectangle(MakeRect(X, Y, W, H)); Exit; end;
  D := R * 2;
  if D > H then D := H;
  if D > W then D := W;
  Result.AddArc(X,         Y,         D, D, 180, 90);
  Result.AddArc(X + W - D, Y,         D, D, 270, 90);
  Result.AddArc(X + W - D, Y + H - D, D, D,   0, 90);
  Result.AddArc(X,         Y + H - D, D, D,  90, 90);
  Result.CloseFigure;
end;

procedure TCWSDropdownWindow.ClampScroll;
begin
  if FScrollPos < 0 then FScrollPos := 0;
  if FScrollPos > GetMaxScroll then FScrollPos := GetMaxScroll;
end;

procedure TCWSDropdownWindow.ScrollByDelta(Delta: Integer);
var OldPos: Integer;
begin
  OldPos := FScrollPos;
  Inc(FScrollPos, Delta);
  ClampScroll;
  if FScrollPos <> OldPos then Render;
end;

{ *** Track-click auto-repeat *** }

procedure TCWSDropdownWindow.StartTrackRepeat(Dir: Integer);
begin
  { First page happens immediately on the click; the timer then keeps paging,
    after a short initial delay, until the thumb catches up with the cursor or
    the button is released. Capture so we always get the button-up. }
  FRepeatDir := Dir;
  FRepeatActive := True;
  FRepeatStarted := False;
  SetCapture(Handle);
  ScrollByDelta(Dir * GetVisibleH);   { one page }
  if FRepeatTimer <> nil then
  begin
    FRepeatTimer.Interval := 350;   { initial delay before auto-repeat kicks in }
    FRepeatTimer.Enabled := True;
  end;
end;

procedure TCWSDropdownWindow.StopTrackRepeat;
begin
  if not FRepeatActive then Exit;
  FRepeatActive := False;
  if FRepeatTimer <> nil then
    FRepeatTimer.Enabled := False;
  if GetCapture = Handle then
    ReleaseCapture;
end;

procedure TCWSDropdownWindow.RepeatTimerTick(Sender: TObject);
var
  Pt: TPoint;
  BY: Integer;
  ThumbR: TRect;
  CursorPast: Boolean;
begin
  if not FRepeatActive or (GetMaxScroll <= 0) then
  begin
    StopTrackRepeat;
    Exit;
  end;
  { Switch from the initial delay to the faster repeat cadence after the first tick. }
  if not FRepeatStarted then
  begin
    FRepeatStarted := True;
    FRepeatTimer.Interval := 60;
  end;

  { Keep paging only while the cursor is still beyond the thumb in the locked
    direction; stop once the thumb has reached or passed it. }
  GetCursorPos(Pt);
  Pt := ScreenToClient(Pt);
  BY := Pt.Y - BodyTop;
  ThumbR := GetThumbRect;
  if FRepeatDir < 0 then
    CursorPast := BY < ThumbR.Top
  else
    CursorPast := BY > ThumbR.Bottom;

  if CursorPast then
    ScrollByDelta(FRepeatDir * GetVisibleH)
  else
    StopTrackRepeat;
end;

procedure TCWSDropdownWindow.ScrollToItem(Index: Integer);
var
  ItemH, PaddV, ItemTop, ItemBot: Integer;
begin
  if (Index < 0) or (Index >= FCombo.FItems.Count) then Exit;
  ItemH   := GetItemH;
  PaddV   := GetPaddV;
  ItemTop := PaddV + Index * ItemH - FScrollPos;
  ItemBot := ItemTop + ItemH;
  if ItemTop < PaddV then
    Dec(FScrollPos, PaddV - ItemTop)
  else if ItemBot > FBodyH - PaddV then
    Inc(FScrollPos, ItemBot - (FBodyH - PaddV));
  ClampScroll;
end;

function TCWSDropdownWindow.CalcBodyHeight(MaxItems: Integer): Integer;
var
  PaddV, ItemH, ContentH, CapH: Integer;
begin
  PaddV    := GetPaddV;
  ItemH    := GetItemH;
  ContentH := GetContentH;
  if MaxItems < 1 then MaxItems := 1;
  Result := ContentH + PaddV * 2;
  CapH   := MaxItems * ItemH + PaddV * 2;
  if Result > CapH then Result := CapH;
  if Result < ItemH + PaddV * 2 then Result := ItemH + PaddV * 2;
end;

procedure TCWSDropdownWindow.BuildShadow;
var
  Cov: TBytes;
  N, i, YOff, ShTop, R: Integer;
  rTL, rTR, rBL, rBR: Integer;
  cx0, cy0, cx1, cy1, X, Y: Integer;
begin
  FHasShadow := FCombo.FDropdownShadowEnabled and (FShadow > 0) and (FBlur > 0);
  SetLength(FShadowBits, 0);
  if not FHasShadow then Exit;
  N := FWinW * FWinH;
  SetLength(Cov, N);

  R := Round(CornerRadiusPx);
  { Corners on the ComboBox contact side are straight (they sit flat), the
    opposite ones are rounded — the shadow softly wraps the list on three sides. }
  if FOpenedUp then
  begin
    rTL := R; rTR := R; rBL := 0; rBR := 0;
  end
  else
  begin
    rTL := 0; rTR := 0; rBL := R; rBR := R;
  end;

  { Full, soft shadow around the whole body (the margin is now on all sides).
    The shadow falls slightly downward (consistent light direction). }
  YOff  := FShadowOffset;
  ShTop := BodyTop + YOff;
  RasterRoundRectAlpha4(@Cov[0], FWinW, FWinH,
    BodyLeft, ShTop, FBodyW, FBodyH, rTL, rTR, rBL, rBR);
  BoxBlurAlpha(@Cov[0], FWinW, FWinH, Max(1, FBlur div 3), 3);

  { Erase the shadow over the ComboBox rect, so it does not darken it. }
  cx0 := Max(0, FCtrlLocal.Left);
  cy0 := Max(0, FCtrlLocal.Top);
  cx1 := Min(FWinW, FCtrlLocal.Right);
  cy1 := Min(FWinH, FCtrlLocal.Bottom);
  for Y := cy0 to cy1 - 1 do
    for X := cx0 to cx1 - 1 do
      Cov[Y * FWinW + X] := 0;

  SetLength(FShadowBits, N * 4);
  for i := 0 to N - 1 do
    FShadowBits[i * 4 + 3] := Cov[i] * DROPDOWN_SHADOW_ALPHA div 255;
end;

procedure TCWSDropdownWindow.Render;
var
  BI: TBitmapInfo;
  Bits: Pointer;
  HBmp, OldBmp: HBITMAP;
  MemDC, ScreenDC: HDC;
  GBmp, ShImg: TGPBitmap;
  G: TGPGraphics;
  Path: TGPGraphicsPath;
  Brush, TextBrushNormal, TextBrushHover: TGPSolidBrush;
  Pen: TGPPen;
  FF: TGPFontFamily;
  GPFont: TGPFont;
  GPFontStyle: Integer;
  Fmt: TGPStringFormat;
  Blend: TBlendFunction;
  PtSrc: TPoint;
  Sz: TSize;
  W, H, R, HlRadius: Single;
  bTL, bTR, bBR, bBL, eTL, eTR, eBR, eBL: Single;
  Border, ItemH, PaddH, PaddV, TextMarginL, i, ItemY: Integer;
  ContactL, ContactR: Integer;
  ItemR, ThumbR: TRect;
  HlR, TextR, ThumbGP: TGPRectF;
  ThumbAlpha: Byte;
  FreeL, FreeR, aTL, aTR, aBR, aBL: Boolean;
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
    GBmp := TGPBitmap.Create(FWinW, FWinH, FWinW * 4, PixelFormat32bppPARGB, Bits);
    G := TGPGraphics.Create(GBmp);
    try
      G.SetSmoothingMode(SmoothingModeAntiAlias);
      G.SetPixelOffsetMode(PixelOffsetModeHighQuality);
      G.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
      G.Clear(MakeColor(0, 0, 0, 0));

      W := FBodyW; H := FBodyH;
      R := CornerRadiusPx;
      Border := Max(1, Round(FScale));

      { ── shadow (from buffer) ── }
      if FHasShadow and (Length(FShadowBits) = FWinW * FWinH * 4) then
      begin
        ShImg := TGPBitmap.Create(FWinW, FWinH, FWinW * 4,
          PixelFormat32bppPARGB, @FShadowBits[0]);
        try G.DrawImage(ShImg, 0, 0, FWinW, FWinH); finally ShImg.Free; end;
      end;

      { ── from here we draw in BODY coordinates ── }
      G.TranslateTransform(BodyLeft, BodyTop);

      { ComboBox contact zone (body coordinates). The list is aligned to the left
        edge of the ComboBox and not narrower than it — the contact usually starts at 0. }
      ContactL := FCtrlLocal.Left - BodyLeft;
      ContactR := FCtrlLocal.Right - BodyLeft;
      if ContactL < 0 then ContactL := 0;
      if ContactR > FBodyW then ContactR := FBodyW;
      if ContactR < ContactL then ContactR := ContactL;

      { Body corners: rounded where the edge is free; straight within the
        ComboBox contact, so the side lines of the ComboBox and the list form one
        continuous edge:
          • opening down → contact at the top (top corners over the ComboBox straight),
          • opening up   → contact at the bottom (bottom corners straight). }
      FreeL := ContactL > 0;
      FreeR := ContactR < FBodyW;
      if FOpenedUp then
      begin
        aTL := True; aTR := True; aBL := FreeL; aBR := FreeR;
      end
      else
      begin
        aBL := True; aBR := True; aTL := FreeL; aTR := FreeR;
      end;
      if aTL then bTL := R else bTL := 0;
      if aTR then bTR := R else bTR := 0;
      if aBR then bBR := R else bBR := 0;
      if aBL then bBL := R else bBL := 0;

      Path := CreateBodyPath4(0, 0, W, H, bTL, bTR, bBR, bBL);
      try
        Brush := TGPSolidBrush.Create(MakeGPColor(FCombo.FDropdownBackColor));
        try G.FillPath(Brush, Path); finally Brush.Free; end;
      finally Path.Free; end;
      if Border > 0 then
      begin
        { Border with a GAP on the contact edge — no double line at the junction
          (the list merges with the ComboBox into one whole); the border remains on
          any protruding part of the edge. }
        if aTL then eTL := R - Border / 2 else eTL := 0;
        if aTR then eTR := R - Border / 2 else eTR := 0;
        if aBR then eBR := R - Border / 2 else eBR := 0;
        if aBL then eBL := R - Border / 2 else eBL := 0;
        Path := CreateBorderPathGap(Border / 2, Border / 2, W - Border, H - Border,
          eTL, eTR, eBR, eBL, ContactL, ContactR, not FOpenedUp);
        Pen := TGPPen.Create(MakeGPColor(FCombo.FDropdownBorderColor), Border);
        try G.DrawPath(Pen, Path); finally Pen.Free; Path.Free; end;

        { The border skips the ComboBox contact edge, so its open ends (side
          lines) do not reach the corner itself — 1 px of border is missing there.
          We draw the missing segment of the side edges on the contact side, for
          corners meeting flat (list the same width as the field). }
        if (ContactL <= 0) or (ContactR >= FBodyW) then
        begin
          Pen := TGPPen.Create(MakeGPColor(FCombo.FDropdownBorderColor), Border);
          try
            if FOpenedUp then
            begin
              if ContactL <= 0 then
                G.DrawLine(Pen, Border / 2, H - R, Border / 2, H);
              if ContactR >= FBodyW then
                G.DrawLine(Pen, W - Border / 2, H - R, W - Border / 2, H);
            end
            else
            begin
              if ContactL <= 0 then
                G.DrawLine(Pen, Border / 2, 0.0, Border / 2, R);
              if ContactR >= FBodyW then
                G.DrawLine(Pen, W - Border / 2, 0.0, W - Border / 2, R);
            end;
          finally Pen.Free; end;
        end;
      end;

      ItemH       := GetItemH;
      PaddH       := GetPaddH;
      PaddV       := GetPaddV;
      HlRadius    := FCombo.ScaleF(FCombo.FItemHighlightCornerRadius);
      TextMarginL := FCombo.GetTextMarginL;

      { clip item drawing to the inside of the border }
      G.SetClip(MakeRect(1.0, PaddV + 0.0, W - 2.0, H - PaddV * 2.0));

      GPFontStyle := FontStyleRegular;
      if fsBold in FCombo.Font.Style then GPFontStyle := GPFontStyle or FontStyleBold;
      if fsItalic in FCombo.Font.Style then GPFontStyle := GPFontStyle or FontStyleItalic;
      if fsUnderline in FCombo.Font.Style then GPFontStyle := GPFontStyle or FontStyleUnderline;
      if fsStrikeOut in FCombo.Font.Style then GPFontStyle := GPFontStyle or FontStyleStrikeout;

      FF := TGPFontFamily.Create(FCombo.Font.Name);
      try
        GPFont := TGPFont.Create(FF, Abs(FCombo.Font.Height), GPFontStyle, UnitPixel);
        try
          Fmt := TGPStringFormat.Create;
          try
            Fmt.SetLineAlignment(StringAlignmentCenter);
            Fmt.SetAlignment(StringAlignmentNear);
            Fmt.SetTrimming(StringTrimmingEllipsisCharacter);
            Fmt.SetFormatFlags(StringFormatFlagsNoWrap);

            TextBrushNormal := TGPSolidBrush.Create(MakeGPColor(FCombo.FItemNormalTextColor));
            TextBrushHover  := TGPSolidBrush.Create(MakeGPColor(FCombo.FItemHighlightTextColor));
            try
              for i := 0 to FCombo.FItems.Count - 1 do
              begin
                ItemY := PaddV + i * ItemH - FScrollPos;
                if ItemY + ItemH < 0 then Continue;
                if ItemY > FBodyH then Break;

                ItemR := GetItemRect(i);

                if i = FHoveredIndex then
                begin
                  HlR := MakeRect(ItemR.Left + 0.0, ItemY + ScalePx(2) + 0.0,
                    (ItemR.Right - ItemR.Left) + 0.0, (ItemH - ScalePx(4)) + 0.0);
                  Brush := TGPSolidBrush.Create(MakeGPColor(FCombo.FItemHighlightColor));
                  try
                    if HlRadius > 0.5 then
                    begin
                      Path := CreateRRPath(HlR.X, HlR.Y, HlR.Width, HlR.Height, HlRadius);
                      try G.FillPath(Brush, Path); finally Path.Free; end;
                    end
                    else
                      G.FillRectangle(Brush, HlR);
                  finally Brush.Free; end;
                end;

                TextR := MakeRect(TextMarginL + 0.0, ItemY + 0.0,
                  Max(0, ItemR.Right - PaddH - TextMarginL) + 0.0, ItemH + 0.0);

                if i = FHoveredIndex then
                  G.DrawString(FCombo.FItems[i], -1, GPFont, TextR, Fmt, TextBrushHover)
                else
                  G.DrawString(FCombo.FItems[i], -1, GPFont, TextR, Fmt, TextBrushNormal);
              end;
            finally
              TextBrushNormal.Free; TextBrushHover.Free;
            end;
          finally Fmt.Free; end;
        finally GPFont.Free; end;
      finally FF.Free; end;

      G.ResetClip;

      { pasek przewijania }
      if GetMaxScroll > 0 then
      begin
        ThumbR := GetThumbRect;
        if FScrollAreaHovered or FScrollDragging then ThumbAlpha := 220 else ThumbAlpha := 140;
        ThumbGP := MakeRect(ThumbR.Left + 0.0, ThumbR.Top + 0.0,
          (ThumbR.Right - ThumbR.Left) + 0.0, (ThumbR.Bottom - ThumbR.Top) + 0.0);
        if FScrollAreaHovered or FScrollDragging then
          Brush := TGPSolidBrush.Create(MakeGPColor(FCombo.FScrollbarThumbHoverColor, ThumbAlpha))
        else
          Brush := TGPSolidBrush.Create(MakeGPColor(FCombo.FScrollbarThumbColor, ThumbAlpha));
        try
          Path := CreateRRPath(ThumbGP.X, ThumbGP.Y, ThumbGP.Width, ThumbGP.Height,
            (ThumbR.Right - ThumbR.Left) / 2.0);
          try G.FillPath(Brush, Path); finally Path.Free; end;
        finally Brush.Free; end;
      end;

      G.ResetTransform;
      G.Flush(FlushIntentionSync);
    finally
      G.Free; GBmp.Free;
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

procedure TCWSDropdownWindow.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

procedure TCWSDropdownWindow.WMNCHitTest(var Msg: TWMNCHitTest);
var
  P: TPoint;
begin
  { A click over the ComboBox itself is passed "underneath" (the control stays
    clickable); a click in the shadow/margin area hits the list window → the hook closes the list. }
  P := Point(Msg.XPos, Msg.YPos);
  if PtInRect(FBodyScreen, P) then
    Msg.Result := HTCLIENT
  else if PtInRect(FCtrlScreen, P) then
    Msg.Result := HTTRANSPARENT
  else
    Msg.Result := HTCLIENT;
end;

procedure TCWSDropdownWindow.WMPaint(var Msg: TWMPaint);
var PS: TPaintStruct;
begin
  BeginPaint(Handle, PS);
  Render;
  EndPaint(Handle, PS);
  Msg.Result := 0;
end;

procedure TCWSDropdownWindow.WMMouseActivate(var Msg: TWMMouseActivate);
begin
  Msg.Result := MA_NOACTIVATE;
end;

procedure TCWSDropdownWindow.WMMouseWheel(var Msg: TWMMouseWheel);
begin
  ScrollByDelta(-MulDiv(Msg.WheelDelta, GetItemH, 120));
  Msg.Result := 1;
end;

procedure TCWSDropdownWindow.WMLButtonDown(var Msg: TWMLButtonDown);
var
  BX, BY, Idx: Integer;
  ThumbR: TRect;
begin
  BX := Msg.XPos - BodyLeft;
  BY := Msg.YPos - BodyTop;
  if IsInScrollArea(BX) and (GetMaxScroll > 0) then
  begin
    ThumbR := GetThumbRect;
    { The thumb is narrower than the scroll area and centred in it, so test only
      the scroll axis: anywhere across the column width within the thumb's
      vertical span grabs the thumb (the cursor is already in the scroll area). }
    if (BY >= ThumbR.Top) and (BY < ThumbR.Bottom) then
    begin
      FScrollDragging    := True;
      FScrollDragStartY  := BY;
      FScrollDragStartPos := FScrollPos;
      SetCapture(Handle);
    end else
      { Page toward the click and keep paging while the button is held until
        the thumb reaches the cursor. }
      if BY < ThumbR.Top then
        StartTrackRepeat(-1)
      else
        StartTrackRepeat(1);
  end else
  begin
    Idx := IndexAtBodyY(BY);
    if (Idx >= 0) and (Idx < FCombo.FItems.Count) then
    begin
      FCombo.SelectItem(Idx);
      FCombo.CloseDropdown;
    end;
  end;
end;

procedure TCWSDropdownWindow.WMLButtonUp(var Msg: TWMLButtonUp);
begin
  { End any track-click auto-repeat the moment the button is released. }
  if FRepeatActive then
    StopTrackRepeat;
  if FScrollDragging then
  begin
    FScrollDragging := False;
    ReleaseCapture;
    Render;
  end;
end;

procedure TCWSDropdownWindow.WMMouseMove(var Msg: TWMMouseMove);
var
  BX, BY, OldHovered: Integer;
  WasScrollArea: Boolean;
  MaxScroll, TrackH: Integer;
begin
  BX := Msg.XPos - BodyLeft;
  BY := Msg.YPos - BodyTop;
  if FScrollDragging then
  begin
    MaxScroll := GetMaxScroll;
    TrackH    := GetVisibleH - GetThumbH;
    if TrackH > 0 then
      FScrollPos := FScrollDragStartPos + MulDiv(BY - FScrollDragStartY, MaxScroll, TrackH);
    ClampScroll;
    Render;
    Exit;
  end;
  WasScrollArea      := FScrollAreaHovered;
  FScrollAreaHovered := IsInScrollArea(BX) and (GetMaxScroll > 0);
  if FScrollAreaHovered <> WasScrollArea then Render;
  if not FScrollAreaHovered then
  begin
    OldHovered    := FHoveredIndex;
    FHoveredIndex := IndexAtBodyY(BY);
    if FHoveredIndex <> OldHovered then Render;
  end;
end;

procedure TCWSDropdownWindow.WMCaptureChanged(var Msg: TMessage);
begin
  { Capture was taken away (e.g. another window grabbed it) — abandon any
    in-progress thumb drag or track-click auto-repeat. }
  if FRepeatActive then
  begin
    FRepeatActive := False;
    if FRepeatTimer <> nil then
      FRepeatTimer.Enabled := False;
  end;
  if FScrollDragging then begin FScrollDragging := False; Render; end;
  inherited;
end;

procedure TCWSDropdownWindow.WMCWSClose(var Msg: TMessage);
begin
  FCombo.CloseDropdown;
end;

procedure TCWSDropdownWindow.CMMouseLeave(var Msg: TMessage);
begin
  inherited;
  FHoveredIndex      := -1;
  FScrollAreaHovered := False;
  Render;
end;

procedure TCWSDropdownWindow.ShowPopup(X, Y, W, MaxItems: Integer);
var
  MonR: TRect;
  Mon: HMONITOR;
  MonInfo: TMonitorInfo;
  ComboTop, BodyTopScreen, BodyLeftScreen: Integer;
  ComboRect: TRect;
begin
  HandleNeeded;
  ComputeScale;

  FBodyW := W;
  FBodyH := CalcBodyHeight(MaxItems);

  { shadow margin (like in CWSPopupMenu) }
  if FCombo.FDropdownShadowEnabled then
  begin
    FBlur         := Max(2, Round(FCombo.FDropdownShadowSize * FScale));
    FShadowOffset := Round(5 * FScale);
    FShadow       := FBlur + FShadowOffset + Round(4 * FScale);
  end
  else begin FBlur := 0; FShadowOffset := 0; FShadow := 0; end;
  FMarginSide := FShadow;

  Mon            := MonitorFromPoint(Point(X, Y), MONITOR_DEFAULTTONEAREST);
  MonInfo.cbSize := SizeOf(MonInfo);
  GetMonitorInfo(Mon, @MonInfo);
  MonR := MonInfo.rcWork;

  { Opening direction + full, symmetric shadow margin on all sides.
    The list sits against the ComboBox edge (without overlapping it). }
  if Y + FBodyH > MonR.Bottom then
  begin
    FOpenedUp     := True;
    ComboTop      := FCombo.ClientToScreen(Point(0, 0)).Y;
    BodyTopScreen := ComboTop - FBodyH;
    if BodyTopScreen < MonR.Top then BodyTopScreen := MonR.Top;
    FMarginTop    := FShadow;
    FMarginBottom := FShadow;
  end
  else
  begin
    FOpenedUp     := False;
    BodyTopScreen := Y;
    FMarginTop    := FShadow;
    FMarginBottom := FShadow;
  end;

  BodyLeftScreen := X;
  if BodyLeftScreen + FBodyW > MonR.Right then BodyLeftScreen := MonR.Right - FBodyW;
  if BodyLeftScreen < MonR.Left then BodyLeftScreen := MonR.Left;

  FWinW    := FBodyW + FMarginSide * 2;
  FWinH    := FBodyH + FMarginTop + FMarginBottom;
  FWinLeft := BodyLeftScreen - FMarginSide;
  FWinTop  := BodyTopScreen - FMarginTop;
  FBodyScreen := Rect(BodyLeftScreen, BodyTopScreen,
    BodyLeftScreen + FBodyW, BodyTopScreen + FBodyH);

  { ComboBox rect relative to the window — there the shadow is erased and clicks
    are passed "underneath". }
  GetWindowRect(FCombo.Handle, ComboRect);
  FCtrlLocal := Rect(ComboRect.Left - FWinLeft, ComboRect.Top - FWinTop,
    ComboRect.Right - FWinLeft, ComboRect.Bottom - FWinTop);
  FCtrlScreen := ComboRect;

  FScrollPos         := 0;
  { The list opens on the current selection: it is highlighted and the arrow
    keys carry on from it, rather than from the top of the list. }
  FHoveredIndex      := FCombo.FItemIndex;
  FScrollAreaHovered := False;
  if FCombo.FItemIndex >= 0 then
    ScrollToItem(FCombo.FItemIndex);

  BuildShadow;

  SetWindowPos(Handle, HWND_TOPMOST, FWinLeft, FWinTop, FWinW, FWinH,
    SWP_NOACTIVATE or SWP_HIDEWINDOW);
  Render;
  ShowWindow(Handle, SW_SHOWNOACTIVATE);
  SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0,
    SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);

  InstallHook(Self);
end;

procedure TCWSDropdownWindow.HidePopup;
begin
  UninstallHook;
  if HandleAllocated then ShowWindow(Handle, SW_HIDE);
  FHoveredIndex      := -1;
  FScrollAreaHovered := False;
  FScrollDragging    := False;
end;

procedure TCWSDropdownWindow.MoveHover(Delta: Integer);
var NewIdx: Integer;
begin
  NewIdx := FHoveredIndex + Delta;
  if NewIdx < 0 then NewIdx := 0;
  if NewIdx >= FCombo.FItems.Count then NewIdx := FCombo.FItems.Count - 1;
  if NewIdx <> FHoveredIndex then
  begin
    FHoveredIndex := NewIdx;
    ScrollToItem(FHoveredIndex);
    Render;
  end;
end;

function TCWSDropdownWindow.HoveredIndex: Integer;
begin
  Result := FHoveredIndex;
end;

{ ════════════════════════════════════════════════════════════════════════════
    TCWSComboBox
  ════════════════════════════════════════════════════════════════════════════ }

constructor TCWSComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width    := 120;
  Height   := 35;
  TabStop  := True;
  Cursor   := crDefault;

  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf32bit;

  FCornerRadius        := 4;
  FAccentColor         := $D47800;
  FBackgroundColor     := clWhite;
  FBackgroundHoverColor := $F9F9F9;
  FBorderColor         := $D6D6D6;
  FDisabledColor       := $F7F7F7;
  FDisabledBorderColor := $E0E0E0;
  FTextColor           := $202020;
  FDisabledTextColor   := $A0A0A0;

  FDropdownBackColor   := clWhite;
  FDropdownBorderColor := $D6D6D6;
  FDropDownMaxItem   := 8;   { number of visible items }
  FItemHeight          := 36;
  FDropdownCornerRadius  := 8;     { list rounding — like in CWSPopupMenu }
  FDropdownShadowEnabled := True;
  FDropdownShadowSize    := 18;

  FItemHighlightColor        := $E8E8E8;
  FItemHighlightPressedColor := $DADADA;
  FItemHighlightTextColor    := $0D0D0D;
  FItemNormalTextColor       := $202020;
  FItemHighlightCornerRadius := 4;

  FScrollbarThumbColor      := $C0C0C0;
  FScrollbarThumbHoverColor := $909090;
  FScrollbarAreaWidth       := 14;
  FScrollbarThumbWidth      := 4;
  FScrollbarThumbHoverWidth := 6;

  FItemIndex      := -1;
  FPreviewIndex   := -1;
  FAutoSizeHeight := True;
  FStyle          := csDropDownList;
  FInternalEdit   := nil;

  FAutoComplete      := True;
  FAutoCompleteDelay := 500;
  FAutoCloseUp       := False;
  FAutoDropDown      := False;
  FCharCase          := ecNormal;
  FMaxLength         := 0;
  FReadOnly          := False;

  FItems := TStringList.Create;
  FItems.OnChange := ItemsChanged;

  { Internal left margin of TEdit with bsNone — Windows constant }
  FEditInternalMarginL := 1;

  FDropdown := TCWSDropdownWindow.Create(Self);
  FDropdown.Canvas.Font.Assign(Font);
end;

destructor TCWSComboBox.Destroy;
begin
  if FDroppedDown then CloseDropdown;
  FDropdown.Free;
  FItems.Free;
  FBuffer.Free;
  inherited;
end;

{ ─── Edit (csDropDown only) ──────────────────────────────────────────────── }

procedure TCWSComboBox.CreateEdit;
begin
  if FInternalEdit <> nil then Exit;
  FInternalEdit := TCWSBufferedEdit.Create(Self);
  FInternalEdit.Parent      := Self;
  FInternalEdit.BorderStyle := bsNone;
  FInternalEdit.ParentFont  := False;
  FInternalEdit.Font.Assign(Font);
  FInternalEdit.Color       := GetCurrentBgColor;
  FInternalEdit.AutoSelect  := True;
  FInternalEdit.OnChange    := EditChange;
  FInternalEdit.OnEnter     := EditEnter;
  FInternalEdit.OnExit      := EditExit;
  FInternalEdit.OnKeyDown   := EditKeyDown;
  FInternalEdit.OnKeyUp     := EditKeyUp;
  FInternalEdit.OnKeyPress  := EditKeyPress;
  FInternalEdit.OnMouseDown := EditMouseDown;
  { Hook WindowProc so ESC can close the dropdown *before* the parent form's
    KeyPreview sees it (otherwise an ESC=Close form would fire first). }
  FEditWndProc := FInternalEdit.WindowProc;
  FInternalEdit.WindowProc := EditSubclassProc;
  SyncEditProperties;
  UpdateEditPosition;
end;

procedure TCWSComboBox.DestroyEdit;
begin
  if FInternalEdit = nil then Exit;
  FInternalEdit.WindowProc := FEditWndProc;
  FEditWndProc := nil;
  FreeAndNil(FInternalEdit);
end;

procedure TCWSComboBox.UpdateEditPosition;
var
  L, T, EditH, BtnW, TextMarginL: Integer;
  DC: HDC;
  TM: TTextMetric;
begin
  if FInternalEdit = nil then Exit;
  { Compute text height safely — without Canvas.Handle }
  DC := GetDC(0);
  try
    SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, TM);
    EditH := TM.tmHeight;
  finally
    ReleaseDC(0, DC);
  end;
  BtnW        := Scale(32);
  TextMarginL := GetTextMarginL;
  L := TextMarginL - FEditInternalMarginL;
  if L < 0 then L := 0;
  T := (Height - EditH) div 2;
  if T < 0 then T := 0;
  FInternalEdit.SetBounds(L, T, Width - BtnW - TextMarginL - Scale(4), EditH);
end;

procedure TCWSComboBox.SyncEditAppearance;
begin
  if FInternalEdit = nil then Exit;
  FInternalEdit.Color := GetCurrentBgColor;
  if Enabled then
    FInternalEdit.Font.Color := FTextColor
  else
    FInternalEdit.Font.Color := FDisabledTextColor;
  // Force the inner edit to repaint so a focused control adopts the new
  // theme colors immediately, without waiting for a mouse-over.
  if FInternalEdit.HandleAllocated then
    FInternalEdit.Invalidate;
end;

{ Push the VCL-compatible edit properties down to the inner TEdit. }
procedure TCWSComboBox.SyncEditProperties;
begin
  if FInternalEdit = nil then Exit;
  FInternalEdit.CharCase  := FCharCase;
  FInternalEdit.MaxLength := FMaxLength;
  FInternalEdit.ReadOnly  := FReadOnly;
  FInternalEdit.TextHint  := FTextHint;
end;

{ Write the field text ourselves. Marked as internal, so EditChange knows this
  is not user input: no auto-complete, and no OnChange from the edit — the
  caller reports the change (or deliberately does not, for a preview). }
procedure TCWSComboBox.SetEditTextSilent(const S: string; ASelectAll: Boolean);
begin
  if FInternalEdit = nil then Exit;
  FInternalTextChange := True;
  try
    FInternalEdit.Text := S;
    if ASelectAll then
    begin
      FInternalEdit.SelStart  := 0;
      FInternalEdit.SelLength := Length(S);
    end
    else
      FInternalEdit.SelStart := Length(S);
  finally
    FInternalTextChange := False;
  end;
end;

{ ─── Style ──────────────────────────────────────────────────────────────── }

procedure TCWSComboBox.SetStyle(const Value: TCWSComboStyle);
begin
  if FStyle = Value then Exit;
  if FDroppedDown then CloseDropdown;
  FStyle := Value;
  if FStyle = csDropDown then
  begin
    CreateEdit;
    if (FItemIndex >= 0) and (FItemIndex < FItems.Count) then
      SetEditTextSilent(FItems[FItemIndex])
    else
      SetEditTextSilent('');
    Cursor := crDefault;
  end else
  begin
    DestroyEdit;
    Cursor := crDefault;
  end;
  Invalidate;
end;

{ ─── Font ────────────────────────────────────────────────────────────────── }

procedure TCWSComboBox.CMFontChanged(var Msg: TMessage);
begin
  inherited;
  if FDropdown <> nil then FDropdown.Canvas.Font.Assign(Font);
  if FInternalEdit <> nil then FInternalEdit.Font.Assign(Font);
  AdjustHeight;
  Invalidate;
end;

procedure TCWSComboBox.CMParentFontChanged(var Msg: TMessage);
begin
  inherited;
  if FDropdown <> nil then FDropdown.Canvas.Font.Assign(Font);
  if FInternalEdit <> nil then FInternalEdit.Font.Assign(Font);
  AdjustHeight;
  Invalidate;
end;

procedure TCWSComboBox.CMPPIChanged(var Msg: TMessage);
begin
  inherited;
  if FBuffer <> nil then
    FBuffer.SetSize(0, 0);
  AdjustHeight;
  UpdateEditPosition;
  Invalidate;
end;

procedure TCWSComboBox.Loaded;
begin
  inherited;
  if FDropdown <> nil then FDropdown.Canvas.Font.Assign(Font);
  if FInternalEdit <> nil then FInternalEdit.Font.Assign(Font);
  AdjustHeight;
end;

{ ─── AutoSizeHeight ──────────────────────────────────────────────────────── }

function TCWSComboBox.GetTextMarginL: Integer;
begin
  Result := Scale(10) + Round(ScaleF(FCornerRadius) / 2);
end;


procedure TCWSComboBox.AdjustHeight;
var
  TextH, Padding, NewH: Integer;
  DC: HDC;
  TM: TTextMetric;
begin
  if not FAutoSizeHeight then Exit;
  DC := GetDC(0);
  try
    SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, TM);
    TextH := TM.tmHeight;
  finally
    ReleaseDC(0, DC);
  end;
  Padding := Scale(6);
  NewH    := TextH + Padding * 2;
  if NewH < Scale(28) then NewH := Scale(28);
  if Height <> NewH then
  begin
    Height := NewH;
    UpdateEditPosition;
  end;
end;

procedure TCWSComboBox.SetAutoSizeHeight(const Value: Boolean);
begin
  if FAutoSizeHeight <> Value then
  begin
    FAutoSizeHeight := Value;
    if FAutoSizeHeight then AdjustHeight;
  end;
end;

{ ─── GDI+ helpers ─────────────────────────────────────────────────────────── }

function TCWSComboBox.MakeGPColor(AColor: TColor; Alpha: Byte): Cardinal;
var C: TColor;
begin
  C      := ColorToRGB(AColor);
  Result := Winapi.GDIPAPI.MakeColor(Alpha, GetRValue(C), GetGValue(C), GetBValue(C));
end;

function TCWSComboBox.CreateRoundRectPath(X, Y, W, H, R: Single): TGPGraphicsPath;
var D: Single;
begin
  Result := TGPGraphicsPath.Create;
  if R <= 0 then begin Result.AddRectangle(MakeRect(X, Y, W, H)); Exit; end;
  D := R * 2;
  if D > H then D := H;
  if D > W then D := W;
  Result.AddArc(X,         Y,         D, D, 180, 90);
  Result.AddArc(X + W - D, Y,         D, D, 270, 90);
  Result.AddArc(X + W - D, Y + H - D, D, D,   0, 90);
  Result.AddArc(X,         Y + H - D, D, D,  90, 90);
  Result.CloseFigure;
end;

function TCWSComboBox.Scale(Value: Integer): Integer;
begin
  Result := MulDiv(Value, CurrentPPI, 96);
end;

function TCWSComboBox.ScaleF(Value: Single): Single;
begin
  Result := Value * CurrentPPI / 96;
end;

{ ─── Stan ─────────────────────────────────────────────────────────────────── }

function TCWSComboBox.GetCurrentBgColor: TColor;
begin
  if not Enabled then Result := FDisabledColor
  else if FHovered then Result := FBackgroundHoverColor
  else Result := FBackgroundColor;
end;

function TCWSComboBox.GetCurrentBorderColor: TColor;
begin
  if not Enabled then Result := FDisabledBorderColor
  else Result := FBorderColor;
end;

function TCWSComboBox.GetParentBgColor: TColor;
begin
  if Parent <> nil then Result := TControlAccess(Parent).Color
  else Result := clBtnFace;
end;

procedure TCWSComboBox.DrawParentBackground(DC: HDC; ARadius: Single);
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
      antialiased edge blends against real parent pixels). Keeps the parent's
      paint cheap — it is repeated on every hover/focus repaint. Region
      coordinates are device units, so this must happen before MoveWindowOrg. }
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

function TCWSComboBox.Focused: Boolean;
begin
  Result := inherited Focused or
    ((FInternalEdit <> nil) and FInternalEdit.Focused);
end;

procedure TCWSComboBox.ApplyStateChange;
begin
  SyncEditAppearance;
  if HandleAllocated then Invalidate;
end;

{ ─── Items ───────────────────────────────────────────────────────────────── }

procedure TCWSComboBox.ItemsChanged(Sender: TObject);
begin
  if FSorted then FItems.Sort;
  if FItemIndex >= FItems.Count then FItemIndex := FItems.Count - 1;
  Invalidate;
  if FDroppedDown then FDropdown.Invalidate;
end;

function TCWSComboBox.GetItemCount: Integer;
begin
  Result := FItems.Count;
end;

function TCWSComboBox.GetItems: TStrings;
begin
  Result := FItems;
end;

function TCWSComboBox.GetText: string;
begin
  if FStyle = csDropDown then
  begin
    if FInternalEdit <> nil then Result := FInternalEdit.Text
    else Result := '';
  end else
  begin
    if (FItemIndex >= 0) and (FItemIndex < FItems.Count) then
      Result := FItems[FItemIndex]
    else
      Result := '';
  end;
end;

{ Text drawn in the field. While the list is dropped down, keyboard navigation
  — arrows and the incremental search — previews the item it lands on, exactly
  as the VCL csDropDownList does; ESC closes the list and the field falls back
  to ItemIndex. Mouse hovering does not preview: it leaves the field showing
  the current selection, which is the Win32 behaviour. }
function TCWSComboBox.GetDisplayText: string;
var
  Idx: Integer;
begin
  Idx := -1;
  if FDroppedDown then Idx := FPreviewIndex;
  if Idx < 0 then Idx := FItemIndex;
  if (Idx >= 0) and (Idx < FItems.Count) then Result := FItems[Idx]
  else Result := '';
end;

procedure TCWSComboBox.SetPreviewIndex(Value: Integer);
begin
  if FPreviewIndex = Value then Exit;
  FPreviewIndex := Value;
  { csDropDown: the field is a real edit, so the preview has to be written into
    it — fully selected, the way the VCL leaves it when the list selection
    moves. csDropDownList draws the field itself and only needs a repaint. }
  if (FStyle = csDropDown) and (FInternalEdit <> nil) and
     (Value >= 0) and (Value < FItems.Count) then
    SetEditTextSilent(FItems[Value], True);
  Invalidate;
end;

procedure TCWSComboBox.SetText(const Value: string);
var Idx: Integer;
begin
  if FStyle = csDropDown then
  begin
    if FInternalEdit <> nil then FInternalEdit.Text := Value;
    Idx := FItems.IndexOf(Value);
    FItemIndex := Idx;
    Invalidate;
  end else
  begin
    Idx := FItems.IndexOf(Value);
    if Idx >= 0 then SelectItem(Idx);
  end;
end;

procedure TCWSComboBox.SelectItem(Index: Integer);
var OldIdx: Integer;
begin
  OldIdx := FItemIndex;
  if (Index < 0) or (Index >= FItems.Count) then FItemIndex := -1
  else FItemIndex := Index;

  { A real selection supersedes whatever the keyboard was previewing. }
  FPreviewIndex := -1;

  if (FStyle = csDropDown) and (FInternalEdit <> nil) then
  begin
    if FItemIndex >= 0 then
      SetEditTextSilent(FItems[FItemIndex])
    else
      SetEditTextSilent('');
  end;

  if FItemIndex <> OldIdx then
  begin
    Invalidate;
    if Assigned(FOnChange) then FOnChange(Self);
    if Assigned(FOnSelect) then FOnSelect(Self);
  end;
end;

procedure TCWSComboBox.AddItem(const S: string; AObject: TObject);
begin
  FItems.AddObject(S, AObject);
end;

procedure TCWSComboBox.Clear;
begin
  FItems.Clear;
  FItemIndex    := -1;
  FPreviewIndex := -1;
  FSearchText   := '';
  SetEditTextSilent('');
  Invalidate;
end;

{ ─── Auto-complete / incremental search ─────────────────────────────────── }

{ First item whose text starts with Prefix (case-insensitive). The scan wraps
  around, beginning at StartIdx — that is what makes repeated presses of the
  same letter cycle through the matching items. }
function TCWSComboBox.FindItemByPrefix(const Prefix: string;
  StartIdx: Integer): Integer;
var
  I, N, Idx: Integer;
begin
  Result := -1;
  N := FItems.Count;
  if (N = 0) or (Prefix = '') then Exit;
  if StartIdx < 0 then StartIdx := 0;
  for I := 0 to N - 1 do
  begin
    Idx := (StartIdx + I) mod N;
    if StartsText(Prefix, FItems[Idx]) then Exit(Idx);
  end;
end;

{ csDropDown: extend what the user typed with the tail of the first matching
  item and select that tail, so the next keystroke overwrites it — the VCL
  TComboBox / Win32 CBS_DROPDOWN auto-completion behaviour.
  Returns True when a match was applied. }
function TCWSComboBox.DoAutoComplete: Boolean;
var
  Typed, Match: string;
  Idx: Integer;
begin
  Result := False;
  if (FStyle <> csDropDown) or (FInternalEdit = nil) or FReadOnly then Exit;
  Typed := FInternalEdit.Text;
  if Typed = '' then Exit;
  { Complete only while typing at the end of the text — never mid-word. }
  if FInternalEdit.SelStart < Length(Typed) then Exit;
  Idx := FindItemByPrefix(Typed);
  if Idx < 0 then Exit;
  Match := FItems[Idx];
  { MaxLength would silently truncate the completion — leave the text alone. }
  if (FMaxLength > 0) and (Length(Match) > FMaxLength) then Exit;

  FInternalTextChange := True;
  try
    FInternalEdit.Text      := Match;   { adopts the item's own letter case }
    FInternalEdit.SelStart  := Length(Typed);
    FInternalEdit.SelLength := Length(Match) - Length(Typed);
  finally
    FInternalTextChange := False;
  end;
  Result := True;
end;

{ csDropDown: ItemIndex mirrors the edit text — the index of the item equal to
  it, or -1 for free text. Does not fire OnChange / OnSelect. }
procedure TCWSComboBox.UpdateItemIndexFromText;
var
  Idx: Integer;
begin
  if FStyle <> csDropDown then Exit;
  if FInternalEdit = nil then Idx := -1
  else Idx := FItems.IndexOf(FInternalEdit.Text);
  if FItemIndex <> Idx then
  begin
    FItemIndex := Idx;
    Invalidate;
  end;
end;

{ Keep the open list in sync with the current selection. }
procedure TCWSComboBox.SyncDropdownHover;
begin
  if not FDroppedDown or (FDropdown = nil) or (FItemIndex < 0) then Exit;
  if FDropdown.FHoveredIndex = FItemIndex then Exit;
  FDropdown.FHoveredIndex := FItemIndex;
  FDropdown.ScrollToItem(FItemIndex);
  FDropdown.Render;
end;

{ ─── Dropdown ────────────────────────────────────────────────────────────── }

procedure TCWSComboBox.OpenDropdown;
var
  Pt: TPoint;
  PopupW: Integer;
begin
  if FDroppedDown or not Enabled or (FItems.Count = 0) then Exit;
  FDroppedDown   := True;
  FPreviewIndex  := -1;
  FSearchText    := '';
  FDropStartText := GetText;   { what ESC has to restore }
  Pt     := ClientToScreen(Point(0, Height));
  { The list is exactly the ComboBox width — the side edges of the field and the
    list form one continuous line (unified, no "step"); as in the Windows 11 ComboBox. }
  PopupW := Width;
  FDropdown.ShowPopup(Pt.X, Pt.Y, PopupW, FDropDownMaxItem);
  FDropUp := FDropdown.FOpenedUp;   { align the border corners to the list }
  if Assigned(FOnDropDown) then FOnDropDown(Self);
  Invalidate;
end;

procedure TCWSComboBox.CloseDropdown(Cancel: Boolean);
var
  Pending: Integer;
begin
  if not FDroppedDown then Exit;
  Pending       := FPreviewIndex;
  FDroppedDown  := False;
  FDropUp       := False;
  FPreviewIndex := -1;   { field falls back to ItemIndex from here on }
  FSearchText   := '';
  FDropdown.HidePopup;

  if csDestroying in ComponentState then
    Pending := -1;

  if Cancel then
  begin
    { ESC — the preview is discarded and the field goes back to what was in it
      when the list opened, as in the VCL. csDropDownList needs nothing: it
      draws from ItemIndex, which the preview never touched. }
    if (FStyle = csDropDown) and (FInternalEdit <> nil) and
       (FInternalEdit.Text <> FDropStartText) then
    begin
      SetEditTextSilent(FDropStartText);
      UpdateItemIndexFromText;   { the restore bypassed EditChange }
    end;
  end
  else if (Pending >= 0) and (Pending <> FItemIndex) then
    { Closed without cancelling — commit what the keyboard had highlighted.
      Enter and a click on an item have already gone through SelectItem, which
      clears the preview, so this is the click-outside / lost-focus path. }
    SelectItem(Pending);

  if Assigned(FOnCloseUp) then FOnCloseUp(Self);
  if (FStyle = csDropDown) and (FInternalEdit <> nil) and FInternalEdit.CanFocus then
    FInternalEdit.SetFocus;
  Invalidate;
end;

procedure TCWSComboBox.DropDown;  begin OpenDropdown;  end;
procedure TCWSComboBox.CloseUp;   begin CloseDropdown; end;

{ ─── Edit handlers ──────────────────────────────────────────────────────── }

procedure TCWSComboBox.EditChange(Sender: TObject);
var
  Completed: Boolean;
begin
  { Text we pushed into the edit ourselves — the caller reports the change. }
  if FInternalTextChange then Exit;

  Completed := False;
  if FAutoComplete and FAllowAutoComplete then
    Completed := DoAutoComplete;
  FAllowAutoComplete := False;

  UpdateItemIndexFromText;
  SyncDropdownHover;

  if Assigned(FOnChange) then FOnChange(Self);

  if Completed and FAutoCloseUp and FDroppedDown then
    CloseDropdown;
end;

procedure TCWSComboBox.EditEnter(Sender: TObject);
begin
  FFocused := True;
  Invalidate;
  if Assigned(OnEnter) then OnEnter(Self);
end;

procedure TCWSComboBox.EditExit(Sender: TObject);
begin
  FFocused := False;
  if FDroppedDown then CloseDropdown;
  Invalidate;
  if Assigned(OnExit) then OnExit(Self);
end;

procedure TCWSComboBox.EditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var NewIdx, RetIdx: Integer;
begin
  { Cleared on every key; only EditKeyPress re-arms it for printable chars. }
  FAllowAutoComplete := False;
  if Assigned(FOnKeyDown) then FOnKeyDown(Self, Key, Shift);
  case Key of
    VK_DOWN:
    begin
      if FDroppedDown then FDropdown.MoveHover(1)
      else if ssAlt in Shift then OpenDropdown
      else begin
        NewIdx := FItemIndex + 1;
        if NewIdx >= FItems.Count then NewIdx := FItems.Count - 1;
        SelectItem(NewIdx);
      end;
      Key := 0;
    end;
    VK_UP:
    begin
      if FDroppedDown then FDropdown.MoveHover(-1)
      else begin
        NewIdx := FItemIndex - 1;
        if NewIdx < 0 then NewIdx := 0;
        SelectItem(NewIdx);
      end;
      Key := 0;
    end;
    VK_RETURN:
    begin
      Key := 0;  { swallow before TEdit → no WM_CHAR #13 → no beep }
      if FDroppedDown then
      begin
        RetIdx := FDropdown.HoveredIndex;
        if RetIdx >= 0 then SelectItem(RetIdx);
        CloseDropdown;
      end;
      { List closed: Enter does nothing — same as VCL TComboBox }
    end;
    VK_ESCAPE:
    begin
      Key := 0;  { swallow → no WM_CHAR #27 → no beep }
      if FDroppedDown then CloseDropdown(True);
    end;
    VK_F4:
    begin
      if FDroppedDown then CloseDropdown else OpenDropdown;
      Key := 0;
    end;
  end;

  { Navigating an open list previews the highlighted item in the edit. }
  if FDroppedDown then SetPreviewIndex(FDropdown.HoveredIndex);
end;

procedure TCWSComboBox.EditKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Assigned(FOnKeyUp) then FOnKeyUp(Self, Key, Shift);
end;

{ csDropDown: focus is on FInternalEdit, so CN_KEYDOWN is delivered to the edit,
  not the combo. Intercept ESC here — before the form's KeyPreview — so a
  dropped-down list closes first instead of the form (e.g. ESC = Close form). }
procedure TCWSComboBox.EditSubclassProc(var Message: TMessage);
begin
  if (Message.Msg = CN_KEYDOWN) and FDroppedDown and
     (TWMKeyDown(Message).CharCode = VK_ESCAPE) then
  begin
    CloseDropdown(True);
    Message.Result := 1;   { handled — stop propagation to form KeyPreview }
    Exit;
  end;
  if Assigned(FEditWndProc) then FEditWndProc(Message);
end;

procedure TCWSComboBox.EditKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    #13, #27: Key := #0;
  end;
  if Assigned(FOnKeyPress) then FOnKeyPress(Self, Key);
  if Key = #0 then Exit;

  { Arm auto-complete for the OnChange that this character will trigger.
    Only printable, typed characters complete — Backspace/Delete, Ctrl
    shortcuts and programmatic text changes must leave the text as-is,
    otherwise the deleted tail would be put straight back. }
  if Key < #32 then Exit;
  if FAutoComplete and not FReadOnly then
    FAllowAutoComplete := True;
  if FAutoDropDown and not FDroppedDown then
    OpenDropdown;
end;

procedure TCWSComboBox.EditMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and FDroppedDown then CloseDropdown;
end;

{ ─── Paint ────────────────────────────────────────────────────────────────── }

procedure TCWSComboBox.EnsureBuffer;
begin
  if (FBuffer.Width <> Width) or (FBuffer.Height <> Height) then
    FBuffer.SetSize(Width, Height);
end;

procedure TCWSComboBox.PaintToBuffer;
var
  G: TGPGraphics;
  W, H, R: Single;
  BgColor, BrdColor, TxtColor: Cardinal;
  Path: TGPGraphicsPath;
  Brush: TGPSolidBrush;
  Pen: TGPPen;
  ArrowCx, ArrowCy, ArrowSize: Single;
  ArrowPts: array[0..2] of TGPPointF;
  AccentH: Integer;
  TxtR: TGPRectF;
  DisplayText: string;
  FF: TGPFontFamily;
  GPFont: TGPFont;
  GPFontStyle: Integer;
  Fmt: TGPStringFormat;
  BtnW: Single;
  TextMarginL: Integer;
  RoundTop, RoundBottom: Boolean;
begin
  EnsureBuffer;
  W := Width; H := Height;
  R := ScaleF(FCornerRadius);

  { On the side joining the list, the corners are straight, so the side lines of the
    ComboBox and the list form one straight edge: list down → straight bottom, list up → straight top. }
  RoundTop    := not (FDroppedDown and FDropUp);
  RoundBottom := not (FDroppedDown and not FDropUp);

  FBuffer.Canvas.Brush.Color := GetParentBgColor;
  FBuffer.Canvas.FillRect(Rect(0, 0, Width, Height));
  DrawParentBackground(FBuffer.Canvas.Handle, R);

  BgColor  := MakeGPColor(GetCurrentBgColor);
  BrdColor := MakeGPColor(GetCurrentBorderColor);
  if Enabled then TxtColor := MakeGPColor(FTextColor)
  else            TxtColor := MakeGPColor(FDisabledTextColor);

  G := TGPGraphics.Create(FBuffer.Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    G.SetPixelOffsetMode(PixelOffsetModeHalf);

    { Background and frame }
    Path := CreateBodyPath(0.5, 0.5, W - 1, H - 1, R, RoundTop, RoundBottom);
    try
      Brush := TGPSolidBrush.Create(BgColor);
      try G.FillPath(Brush, Path); finally Brush.Free; end;
      Pen := TGPPen.Create(BrdColor, 1.0);
      try G.DrawPath(Pen, Path); finally Pen.Free; end;
    finally Path.Free; end;

    { Accent bar }
    if (FFocused or FDroppedDown) and Enabled then
    begin
      AccentH := Scale(2);
      G.SetSmoothingMode(SmoothingModeNone);
      G.SetPixelOffsetMode(PixelOffsetModeNone);
      if FDroppedDown then
      begin
        Brush := TGPSolidBrush.Create(MakeGPColor(FAccentColor));
        try G.FillRectangle(Brush, 0.0, H - AccentH, W, AccentH + 0.0);
        finally Brush.Free; end;
      end else
      begin
        Path := CreateRoundRectPath(0.0, 0.0, W, H, R);
        try G.SetClip(Path); finally Path.Free; end;
        Brush := TGPSolidBrush.Create(MakeGPColor(FAccentColor));
        try G.FillRectangle(Brush, 0.0, H - AccentH, W, AccentH + 0.0);
        finally Brush.Free; end;
        G.ResetClip;
      end;
      G.SetSmoothingMode(SmoothingModeAntiAlias);
      G.SetPixelOffsetMode(PixelOffsetModeHalf);
    end;

    { Separator }
    BtnW := Scale(32);
    Pen  := TGPPen.Create(MakeGPColor(GetCurrentBorderColor), 1.0);
    try G.DrawLine(Pen, W - BtnW, H * 0.2, W - BtnW, H * 0.8);
    finally Pen.Free; end;

    { Arrow }
    ArrowCx   := W - BtnW / 2;
    ArrowCy   := H / 2;
    ArrowSize := ScaleF(4.5);
    if FDroppedDown then
    begin
      ArrowPts[0] := MakePoint(ArrowCx - ArrowSize, ArrowCy + ArrowSize * 0.5);
      ArrowPts[1] := MakePoint(ArrowCx,             ArrowCy - ArrowSize * 0.5);
      ArrowPts[2] := MakePoint(ArrowCx + ArrowSize, ArrowCy + ArrowSize * 0.5);
    end else
    begin
      ArrowPts[0] := MakePoint(ArrowCx - ArrowSize, ArrowCy - ArrowSize * 0.5);
      ArrowPts[1] := MakePoint(ArrowCx,             ArrowCy + ArrowSize * 0.5);
      ArrowPts[2] := MakePoint(ArrowCx + ArrowSize, ArrowCy - ArrowSize * 0.5);
    end;
    if Enabled then Pen := TGPPen.Create(MakeGPColor(FTextColor), ScaleF(1.5))
    else            Pen := TGPPen.Create(MakeGPColor(FDisabledTextColor), ScaleF(1.5));
    Pen.SetLineJoin(LineJoinRound);
    Pen.SetStartCap(LineCapRound);
    Pen.SetEndCap(LineCapRound);
    try
      G.SetSmoothingMode(SmoothingModeAntiAlias);
      G.DrawLines(Pen, PGPPointF(@ArrowPts[0]), 3);
    finally Pen.Free; end;

    { Text — only for csDropDownList; in csDropDown FInternalEdit draws it }
    if FStyle = csDropDownList then
    begin
      G.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
      DisplayText := GetDisplayText;
      if (DisplayText = '') and (FTextHint <> '') and not FFocused then
        DisplayText := FTextHint;

      if DisplayText <> '' then
      begin
        TextMarginL := GetTextMarginL;
        TxtR := MakeRect(
          TextMarginL + 0.0, 0.0,
          W - BtnW - TextMarginL - ScaleF(4), H
        );
        FF := TGPFontFamily.Create(Font.Name);
        try
          GPFontStyle := FontStyleRegular;
          if fsBold in Font.Style then
            GPFontStyle := GPFontStyle or FontStyleBold;
          if fsItalic in Font.Style then
            GPFontStyle := GPFontStyle or FontStyleItalic;
          if fsUnderline in Font.Style then
            GPFontStyle := GPFontStyle or FontStyleUnderline;
          if fsStrikeOut in Font.Style then
            GPFontStyle := GPFontStyle or FontStyleStrikeout;
          GPFont := TGPFont.Create(FF, Abs(Font.Height), GPFontStyle, UnitPixel);
          try
            Fmt := TGPStringFormat.Create;
            try
              Fmt.SetLineAlignment(StringAlignmentCenter);
              Fmt.SetAlignment(StringAlignmentNear);
              Fmt.SetTrimming(StringTrimmingEllipsisCharacter);
              Fmt.SetFormatFlags(StringFormatFlagsNoWrap);
              if (GetDisplayText = '') and (FTextHint <> '') then
                Brush := TGPSolidBrush.Create(MakeGPColor(FDisabledTextColor))
              else
                Brush := TGPSolidBrush.Create(TxtColor);
              try G.DrawString(DisplayText, -1, GPFont, TxtR, Fmt, Brush);
              finally Brush.Free; end;
            finally Fmt.Free; end;
          finally GPFont.Free; end;
        finally FF.Free; end;
      end;
    end;

  finally G.Free; end;
end;

procedure TCWSComboBox.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

procedure TCWSComboBox.WMPaint(var Msg: TWMPaint);
var PS: TPaintStruct; DC: HDC;
begin
  if Msg.DC <> 0 then begin inherited; Exit; end;
  DC := BeginPaint(Handle, PS);
  try
    PaintToBuffer;
    BitBlt(DC, 0, 0, Width, Height, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  finally EndPaint(Handle, PS); end;
end;

procedure TCWSComboBox.Paint;
begin
  PaintToBuffer;
  BitBlt(Canvas.Handle, 0, 0, Width, Height, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
end;

{ ─── Focus ────────────────────────────────────────────────────────────────── }

procedure TCWSComboBox.WMSetFocus(var Msg: TWMSetFocus);
begin
  inherited;
  FFocused := True;
  if (FStyle = csDropDown) and (FInternalEdit <> nil) and FInternalEdit.CanFocus then
    FInternalEdit.SetFocus
  else
    Invalidate;
  if Assigned(OnEnter) then OnEnter(Self);
end;

procedure TCWSComboBox.WMKillFocus(var Msg: TWMKillFocus);
begin
  inherited;
  { Focus goes to the inner edit — ignore }
  if (FInternalEdit <> nil) and FInternalEdit.HandleAllocated and
     (Msg.FocusedWnd = FInternalEdit.Handle) then
    Exit;
  FFocused := False;
  if FDroppedDown then CloseDropdown;
  Invalidate;
  if Assigned(OnExit) then OnExit(Self);
end;

{ ─── Keyboard (csDropDownList — focus on combo) ─────────────────────────── }

{ Tell the dialog manager we want the arrow / nav keys; otherwise Windows uses
  them to move focus between controls and WM_KEYDOWN never reaches us. Only the
  combo itself is focused in csDropDownList — in csDropDown the inner edit has
  focus and answers WM_GETDLGCODE on its own. }
procedure TCWSComboBox.WMGetDlgCode(var Msg: TWMGetDlgCode);
begin
  inherited;
  if FStyle = csDropDownList then
    Msg.Result := Msg.Result or DLGC_WANTARROWS;
end;

{ CN_KEYDOWN runs *before* the parent form's KeyPreview (TWinControl.DoKeyDown
  calls the form's DoKeyDown first). When the list is dropped down we close it
  here and swallow ESC so it never reaches the form (e.g. ESC = Close form).
  A second ESC — list already closed — falls through to the form as usual. }
procedure TCWSComboBox.CNKeyDown(var Msg: TWMKeyDown);
begin
  if (Msg.CharCode = VK_ESCAPE) and FDroppedDown then
  begin
    CloseDropdown(True);
    Msg.Result := 1;   { handled — stop propagation to form KeyPreview }
    Exit;
  end;
  inherited;
end;

procedure TCWSComboBox.WMKeyDown(var Msg: TWMKeyDown);
var
  Key: Word;
  Shift: TShiftState;
  NewIdx, RetIdx: Integer;
begin
  if FStyle = csDropDown then begin inherited; Exit; end;

  Key   := Msg.CharCode;
  Shift := KeyDataToShiftState(Msg.KeyData);
  if Assigned(FOnKeyDown) then FOnKeyDown(Self, Key, Shift);
  if Key = 0 then Exit;

  case Key of
    VK_DOWN:
    begin
      if FDroppedDown then FDropdown.MoveHover(1)
      else if ssAlt in Shift then OpenDropdown
      else begin
        NewIdx := FItemIndex + 1;
        if NewIdx >= FItems.Count then NewIdx := FItems.Count - 1;
        SelectItem(NewIdx);
      end;
      Msg.Result := 0;
    end;
    VK_UP:
    begin
      if FDroppedDown then FDropdown.MoveHover(-1)
      else begin
        NewIdx := FItemIndex - 1;
        if NewIdx < 0 then NewIdx := 0;
        SelectItem(NewIdx);
      end;
      Msg.Result := 0;
    end;
    VK_RETURN:
    begin
      if FDroppedDown then begin
        RetIdx := FDropdown.HoveredIndex;
        if RetIdx >= 0 then SelectItem(RetIdx);
        CloseDropdown;
      end;
      Msg.Result := 0;
    end;
    VK_ESCAPE:
      if FDroppedDown then
      begin
        CloseDropdown(True);    { list open → close it, swallow ESC }
        Msg.Result := 0;
      end
      else
        { list closed → don't swallow; let the form handle ESC
          (KeyPreview OnKeyDown / Cancel button / default close) }
        begin inherited; Exit; end;
    VK_F4:     begin if FDroppedDown then CloseDropdown else OpenDropdown; Msg.Result := 0; end;
    VK_HOME:
    begin
      if FDroppedDown then FDropdown.MoveHover(-9999) else SelectItem(0);
      Msg.Result := 0;
    end;
    VK_END:
    begin
      if FDroppedDown then FDropdown.MoveHover(9999) else SelectItem(FItems.Count - 1);
      Msg.Result := 0;
    end;
    VK_PRIOR:
    begin
      if FDroppedDown then FDropdown.MoveHover(-5) else SelectItem(Max(0, FItemIndex - 5));
      Msg.Result := 0;
    end;
    VK_NEXT:
    begin
      if FDroppedDown then FDropdown.MoveHover(5)
      else SelectItem(Min(FItems.Count - 1, FItemIndex + 5));
      Msg.Result := 0;
    end;
  else
    begin inherited; Exit; end;
  end;

  { Navigating an open list previews the highlighted item in the field. }
  if FDroppedDown then SetPreviewIndex(FDropdown.HoveredIndex);
end;

procedure TCWSComboBox.WMKeyUp(var Msg: TWMKeyUp);
var Key: Word; Shift: TShiftState;
begin
  if FStyle = csDropDown then begin inherited; Exit; end;
  Key   := Msg.CharCode;
  Shift := KeyDataToShiftState(Msg.KeyData);
  if Assigned(FOnKeyUp) then FOnKeyUp(Self, Key, Shift);
  inherited;
end;

{ csDropDownList incremental search. Characters typed within AutoCompleteDelay
  of each other build up a prefix and jump to the first item matching it — the
  VCL / Win32 list behaviour. Repeating one and the same character instead
  cycles through all items starting with it. }
procedure TCWSComboBox.WMChar(var Msg: TWMChar);
var
  Ch: Char;
  Idx, CurIdx: Integer;
  Tick: Cardinal;
  Repeated: Boolean;
begin
  if FStyle = csDropDown then begin inherited; Exit; end;
  Ch := Chr(Msg.CharCode);
  if Assigned(FOnKeyPress) then FOnKeyPress(Self, Ch);
  if (Ch = #0) or (Ch < ' ') or not FAutoComplete or (FItems.Count = 0) then
  begin
    inherited;
    Exit;
  end;

  Tick := GetTickCount;
  if (FSearchText <> '') and (Tick - FSearchTick <= FAutoCompleteDelay) then
    FSearchText := FSearchText + Ch
  else
    FSearchText := Ch;
  FSearchTick := Tick;

  if FAutoDropDown and not FDroppedDown then
  begin
    OpenDropdown;
    if FDroppedDown then FDropdown.FHoveredIndex := FItemIndex;
  end;

  if FDroppedDown then CurIdx := FDropdown.HoveredIndex else CurIdx := FItemIndex;

  { All characters identical → treat it as "next item with this letter". }
  Repeated := (Length(FSearchText) > 1) and
    (FSearchText = StringOfChar(FSearchText[1], Length(FSearchText)));
  if Repeated then
    Idx := FindItemByPrefix(Ch, CurIdx + 1)
  else
  begin
    Idx := FindItemByPrefix(FSearchText);
    { Prefix leads nowhere — fall back to a fresh single-character search. }
    if (Idx < 0) and (Length(FSearchText) > 1) then
    begin
      FSearchText := Ch;
      Idx := FindItemByPrefix(Ch, CurIdx + 1);
    end;
  end;

  if Idx >= 0 then
  begin
    if FDroppedDown then
    begin
      FDropdown.FHoveredIndex := Idx;
      FDropdown.ScrollToItem(Idx);
      FDropdown.Render;
      SetPreviewIndex(Idx);   { show the item the search landed on in the field }
    end else
      SelectItem(Idx);
  end;
  inherited;
end;

{ ─── Mouse ────────────────────────────────────────────────────────────────── }

procedure TCWSComboBox.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
  begin
    if FStyle = csDropDownList then
    begin
      if not Focused and CanFocus then SetFocus;
      if FDroppedDown then CloseDropdown else OpenDropdown;
    end else
    begin
      { csDropDown: klik poza editem otwiera/zamyka dropdown }
      if (FInternalEdit = nil) or
         not PtInRect(FInternalEdit.BoundsRect, Point(X, Y)) then
      begin
        if not Focused and CanFocus then SetFocus;
        if FDroppedDown then CloseDropdown else OpenDropdown;
      end;
    end;
  end;
end;

procedure TCWSComboBox.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
end;

procedure TCWSComboBox.CMMouseEnter(var Msg: TMessage);
begin
  inherited;
  if not FHovered then begin FHovered := True; ApplyStateChange; end;
  if Assigned(OnMouseEnter) then OnMouseEnter(Self);
end;

procedure TCWSComboBox.CMMouseLeave(var Msg: TMessage);
begin
  inherited;
  if FHovered then begin FHovered := False; ApplyStateChange; end;
  if Assigned(OnMouseLeave) then OnMouseLeave(Self);
end;

procedure TCWSComboBox.CMEnabledChanged(var Msg: TMessage);
begin
  inherited;
  if not Enabled and FDroppedDown then CloseDropdown;
  if (FStyle = csDropDown) and (FInternalEdit <> nil) then
    FInternalEdit.Enabled := Enabled;
  ApplyStateChange;
end;

{ ─── Layout ───────────────────────────────────────────────────────────────── }

procedure TCWSComboBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or WS_CLIPCHILDREN;
end;

procedure TCWSComboBox.Resize;
begin
  inherited;
  UpdateEditPosition;
  Invalidate;
end;

procedure TCWSComboBox.ChangeScale(M, D: Integer);
begin
  inherited ChangeScale(M, D);
  AdjustHeight;
  UpdateEditPosition;
  Invalidate;
end;

procedure TCWSComboBox.SetEnabled(Value: Boolean);
begin
  inherited;
  if (FStyle = csDropDown) and (FInternalEdit <> nil) then
    FInternalEdit.Enabled := Value;
  ApplyStateChange;
end;

{ ─── Settery ─────────────────────────────────────────────────────────────── }

procedure TCWSComboBox.SetItemIndex(Value: Integer);  begin SelectItem(Value); end;
procedure TCWSComboBox.SetItems(Value: TStrings);     begin FItems.Assign(Value); end;
procedure TCWSComboBox.SetDroppedDown(Value: Boolean);
begin
  if Value then OpenDropdown else CloseDropdown;
end;

procedure TCWSComboBox.SetSorted(Value: Boolean);
begin
  if FSorted <> Value then begin FSorted := Value; if FSorted then FItems.Sort; end;
end;

procedure TCWSComboBox.SetCornerRadius(const Value: Single);
begin
  if FCornerRadius <> Value then
  begin
    FCornerRadius := Max(0, Min(Value, 20));
    UpdateEditPosition;
    Invalidate;
  end;
end;

procedure TCWSComboBox.SetAccentColor(const Value: TColor);
begin if FAccentColor <> Value then begin FAccentColor := Value; Invalidate; end; end;

procedure TCWSComboBox.SetBackgroundColor(const Value: TColor);
begin
  if FBackgroundColor <> Value then begin FBackgroundColor := Value; SyncEditAppearance; Invalidate; end;
end;

procedure TCWSComboBox.SetBackgroundHoverColor(const Value: TColor);
begin
  if FBackgroundHoverColor <> Value then
  begin FBackgroundHoverColor := Value; SyncEditAppearance; Invalidate; end;
end;

procedure TCWSComboBox.SetBorderColor(const Value: TColor);
begin
  if FBorderColor <> Value then begin FBorderColor := Value; Invalidate; end;
end;

procedure TCWSComboBox.SetDisabledColor(const Value: TColor);
begin
  if FDisabledColor <> Value then
  begin FDisabledColor := Value; SyncEditAppearance; Invalidate; end;
end;

procedure TCWSComboBox.SetDisabledBorderColor(const Value: TColor);
begin
  if FDisabledBorderColor <> Value then
  begin FDisabledBorderColor := Value; Invalidate; end;
end;

procedure TCWSComboBox.SetTextColor(const Value: TColor);
begin
  if FTextColor <> Value then
  begin
    FTextColor := Value;
    SyncEditAppearance;
    if FDroppedDown and Assigned(FDropdown) then
      FDropdown.Invalidate;
    Invalidate;
  end;
end;

procedure TCWSComboBox.SetDisabledTextColor(const Value: TColor);
begin
  if FDisabledTextColor <> Value then
  begin FDisabledTextColor := Value; SyncEditAppearance; Invalidate; end;
end;

procedure TCWSComboBox.SetDropdownBackColor(const Value: TColor);
begin
  if FDropdownBackColor <> Value then
  begin FDropdownBackColor := Value; if FDroppedDown then FDropdown.Invalidate; end;
end;

procedure TCWSComboBox.SetDropdownBorderColor(const Value: TColor);
begin
  if FDropdownBorderColor <> Value then
  begin FDropdownBorderColor := Value; if FDroppedDown then FDropdown.Invalidate; end;
end;

procedure TCWSComboBox.SetDropDownMaxItem(const Value: Integer);
begin
  if FDropDownMaxItem <> Value then
  begin FDropDownMaxItem := Max(1, Value); if FDroppedDown then CloseDropdown; end;
end;

procedure TCWSComboBox.SetItemHeight(const Value: Integer);
begin
  if FItemHeight <> Value then
  begin FItemHeight := Max(20, Value); if FDroppedDown then CloseDropdown; end;
end;

procedure TCWSComboBox.SetDropdownCornerRadius(const Value: Single);
begin
  if FDropdownCornerRadius <> Value then
  begin
    FDropdownCornerRadius := Max(0, Min(Value, 24));
    if FDroppedDown then CloseDropdown;
  end;
end;

procedure TCWSComboBox.SetDropdownShadowEnabled(const Value: Boolean);
begin
  if FDropdownShadowEnabled <> Value then
  begin
    FDropdownShadowEnabled := Value;
    if FDroppedDown then CloseDropdown;
  end;
end;

procedure TCWSComboBox.SetDropdownShadowSize(const Value: Integer);
begin
  if FDropdownShadowSize <> Value then
  begin
    FDropdownShadowSize := Max(0, Value);
    if FDroppedDown then CloseDropdown;
  end;
end;

procedure TCWSComboBox.SetItemHighlightColor(const Value: TColor);
begin
  if FItemHighlightColor <> Value then
  begin FItemHighlightColor := Value; if FDroppedDown then FDropdown.Invalidate; end;
end;

procedure TCWSComboBox.SetItemHighlightPressedColor(const Value: TColor);
begin
  if FItemHighlightPressedColor <> Value then
  begin FItemHighlightPressedColor := Value; if FDroppedDown then FDropdown.Invalidate; end;
end;

procedure TCWSComboBox.SetItemHighlightTextColor(const Value: TColor);
begin
  if FItemHighlightTextColor <> Value then
  begin FItemHighlightTextColor := Value; if FDroppedDown then FDropdown.Invalidate; end;
end;

procedure TCWSComboBox.SetItemNormalTextColor(const Value: TColor);
begin
  if FItemNormalTextColor <> Value then
  begin FItemNormalTextColor := Value; if FDroppedDown then FDropdown.Invalidate; end;
end;

procedure TCWSComboBox.SetItemHighlightCornerRadius(const Value: Single);
begin
  if FItemHighlightCornerRadius <> Value then
  begin
    FItemHighlightCornerRadius := Max(0, Min(Value, 20));
    if FDroppedDown then FDropdown.Invalidate;
  end;
end;

procedure TCWSComboBox.SetScrollbarThumbColor(const Value: TColor);
begin
  if FScrollbarThumbColor <> Value then
  begin FScrollbarThumbColor := Value; if FDroppedDown then FDropdown.Invalidate; end;
end;

procedure TCWSComboBox.SetScrollbarThumbHoverColor(const Value: TColor);
begin
  if FScrollbarThumbHoverColor <> Value then
  begin FScrollbarThumbHoverColor := Value; if FDroppedDown then FDropdown.Invalidate; end;
end;

procedure TCWSComboBox.SetScrollbarAreaWidth(const Value: Integer);
begin
  if FScrollbarAreaWidth <> Value then
  begin
    FScrollbarAreaWidth := Max(6, Value);
    if FDroppedDown then CloseDropdown;
  end;
end;

procedure TCWSComboBox.SetScrollbarThumbWidth(const Value: Integer);
begin
  if FScrollbarThumbWidth <> Value then
  begin
    FScrollbarThumbWidth := Max(2, Value);
    if FDroppedDown then FDropdown.Invalidate;
  end;
end;

procedure TCWSComboBox.SetScrollbarThumbHoverWidth(const Value: Integer);
begin
  if FScrollbarThumbHoverWidth <> Value then
  begin
    FScrollbarThumbHoverWidth := Max(2, Value);
    if FDroppedDown then FDropdown.Invalidate;
  end;
end;

procedure TCWSComboBox.SetTextHint(const Value: string);
begin
  if FTextHint <> Value then
  begin
    FTextHint := Value;
    if (FStyle = csDropDown) and (FInternalEdit <> nil) then
      FInternalEdit.TextHint := Value;
    Invalidate;
  end;
end;

{ ─── VCL-compatible edit properties ─────────────────────────────────────── }

procedure TCWSComboBox.SetCharCase(const Value: TEditCharCase);
begin
  if FCharCase <> Value then
  begin
    FCharCase := Value;
    if FInternalEdit <> nil then FInternalEdit.CharCase := Value;
  end;
end;

procedure TCWSComboBox.SetMaxLength(const Value: Integer);
begin
  if FMaxLength <> Value then
  begin
    FMaxLength := Max(0, Value);
    if FInternalEdit <> nil then FInternalEdit.MaxLength := FMaxLength;
  end;
end;

procedure TCWSComboBox.SetReadOnly(const Value: Boolean);
begin
  if FReadOnly <> Value then
  begin
    FReadOnly := Value;
    if FInternalEdit <> nil then FInternalEdit.ReadOnly := Value;
  end;
end;

function TCWSComboBox.GetDropDownCount: Integer;
begin
  Result := FDropDownMaxItem;
end;

procedure TCWSComboBox.SetDropDownCount(const Value: Integer);
begin
  SetDropDownMaxItem(Value);
end;

{ ─── Selection (csDropDown) ─────────────────────────────────────────────── }

function TCWSComboBox.GetSelStart: Integer;
begin
  if (FStyle = csDropDown) and (FInternalEdit <> nil) then
    Result := FInternalEdit.SelStart
  else
    Result := 0;
end;

procedure TCWSComboBox.SetSelStart(const Value: Integer);
begin
  if (FStyle = csDropDown) and (FInternalEdit <> nil) then
    FInternalEdit.SelStart := Value;
end;

function TCWSComboBox.GetSelLength: Integer;
begin
  if (FStyle = csDropDown) and (FInternalEdit <> nil) then
    Result := FInternalEdit.SelLength
  else
    Result := 0;
end;

procedure TCWSComboBox.SetSelLength(const Value: Integer);
begin
  if (FStyle = csDropDown) and (FInternalEdit <> nil) then
    FInternalEdit.SelLength := Value;
end;

function TCWSComboBox.GetSelText: string;
begin
  if (FStyle = csDropDown) and (FInternalEdit <> nil) then
    Result := FInternalEdit.SelText
  else
    Result := '';
end;

procedure TCWSComboBox.SetSelText(const Value: string);
begin
  if (FStyle = csDropDown) and (FInternalEdit <> nil) then
    FInternalEdit.SelText := Value;
end;

procedure TCWSComboBox.SelectAll;
begin
  if (FStyle = csDropDown) and (FInternalEdit <> nil) then
    FInternalEdit.SelectAll;
end;

procedure TCWSComboBox.ClearSelection;
begin
  if (FStyle = csDropDown) and (FInternalEdit <> nil) then
    FInternalEdit.ClearSelection;
end;

procedure TCWSComboBox.CopyToClipboard;
begin
  if (FStyle = csDropDown) and (FInternalEdit <> nil) then
    FInternalEdit.CopyToClipboard;
end;

procedure TCWSComboBox.CutToClipboard;
begin
  if (FStyle = csDropDown) and (FInternalEdit <> nil) then
    FInternalEdit.CutToClipboard;
end;

procedure TCWSComboBox.PasteFromClipboard;
begin
  if (FStyle = csDropDown) and (FInternalEdit <> nil) then
    FInternalEdit.PasteFromClipboard;
end;

end.
