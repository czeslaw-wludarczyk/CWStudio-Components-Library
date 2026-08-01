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
unit CWSListBox;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  Winapi.UxTheme,
  System.SysUtils, System.Classes, System.Types, System.Math,
  Vcl.Controls, Vcl.Graphics, Vcl.StdCtrls, Vcl.Forms, Vcl.ExtCtrls;

const
  CM_PPICHANGED = $B080 + 13;

type
  TCWSListBox = class;

  { TCWSInternalListBox - Hidden native TListBox inside the component }
  TCWSInternalListBox = class(TListBox)
  private
    FOwner: TCWSListBox;
    { Temporarily disables auto-drag when the click does not land on a selected
      item (or the list is empty) — restored in MouseUp }
    FDragSuppressed: Boolean;
    FSavedDragMode: TDragMode;
    procedure NewWindowProc(var Message: TMessage);
  protected
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMNCPaint(var Msg: TMessage); message WM_NCPAINT;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    { Auto-drag only when the cursor is over a selected item }
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    { Drag & Drop: przekierowanie na FOwner (TCWSListBox) }
    procedure DoStartDrag(var DragObject: TDragObject); override;
    procedure DoEndDrag(Target: TObject; X, Y: Integer); override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    function GetItemHeight: Integer;
    function GetVisibleItems: Integer;
    function GetTotalItems: Integer;
    function GetTopIndex: Integer;
    procedure SetTopIndex(Value: Integer);
    procedure MouseWheelHandler(var Message: TMessage); override;
  end;

  { TCWSListBox - Main component with Fluent scrollbar }
  TCWSListBox = class(TCustomControl)
  private
    FListBox: TCWSInternalListBox;
    FBuffer: TBitmap;
    FLabel: string;
    FFocused: Boolean;
    FHovered: Boolean;
    FCornerRadius: Single;

    { Corner selection flags }
    FCornerTopLeft: Boolean;
    FCornerTopRight: Boolean;
    FCornerBottomLeft: Boolean;
    FCornerBottomRight: Boolean;

    { Colors & Display features }
    FAccentColor: TColor;
    FBackgroundColor: TColor;
    FBackgroundHoverColor: TColor;
    FBackgroundFocusColor: TColor;
    FBorderColor: TColor;
    FLabelColor: TColor;
    FScrollThumbColor: TColor;
    FScrollThumbHoverColor: TColor;
    FDisabledColor: TColor;
    FDisabledBorderColor: TColor;
    FScrollbarAreaWidth: Integer;
    FScrollbarThumbWidth: Integer;
    FScrollbarThumbHoverWidth: Integer;
    FShowBorder: Boolean;
    FShowAccentBar: Boolean;
    FCornerColor: TColor;

    { Scrollbar state }
    FScrollVisible: Boolean;
    FScrollAreaHovered: Boolean;

    { Drag and scroll logic }
    FIsDragging: Boolean;
    FDragStartTopIndex: Integer;
    FDragStartY: Integer;
    FScrollThumbRect: TRect;
    FScrollTrackRect: TRect;

    { Track-click auto-repeat (holding the button on the track keeps paging
      toward the cursor until the thumb reaches it — the native scrollbar feel) }
    FRepeatTimer: TTimer;
    FRepeatActive: Boolean;
    FRepeatDir: Integer;
    FRepeatStarted: Boolean;

    { Events }
    FOnClick: TNotifyEvent;
    FOnDblClick: TNotifyEvent;
    FOnKeyDown: TKeyEvent;
    FOnKeyUp: TKeyEvent;
    FOnKeyPress: TKeyPressEvent;
    FOnEnter: TNotifyEvent;
    FOnExit: TNotifyEvent;
    FOnMouseDown: TMouseEvent;
    FOnMouseMove: TMouseMoveEvent;
    FOnMouseUp: TMouseEvent;
    FOnMouseWheel: TMouseWheelEvent;
    FOnContextPopup: TContextPopupEvent;
    FOnDrawItem: TDrawItemEvent;
    FOnMeasureItem: TMeasureItemEvent;
    FOnData: TLBGetDataEvent;
    FOnDataFind: TLBFindDataEvent;
    FOnDataObject: TLBGetDataObjectEvent;

    procedure SetLabel(const Value: string);
    procedure SyncListBoxFont;
    procedure UpdateListBoxPosition;
    procedure UpdateScrollbarMetrics;
    procedure StartTrackRepeat(Dir: Integer);
    procedure StopTrackRepeat;
    procedure DoTrackPage;
    procedure RepeatTimerTick(Sender: TObject);
    procedure EnsureBuffer;
    function GetCurrentBgColor: TColor;
    function GetParentBgColor: TColor;
    procedure DrawParentBackground(DC: HDC; ARadius: Single);
    procedure ApplyStateChange;

    { Property getters/setters for TListBox properties }
    function GetItems: TStrings;
    procedure SetItems(const Value: TStrings);
    function GetItemIndex: Integer;
    procedure SetItemIndex(const Value: Integer);
    function GetMultiSelect: Boolean;
    procedure SetMultiSelect(const Value: Boolean);
    function GetExtendedSelect: Boolean;
    procedure SetExtendedSelect(const Value: Boolean);
    function GetSorted: Boolean;
    procedure SetSorted(const Value: Boolean);
    function GetStyle: TListBoxStyle;
    procedure SetStyle(const Value: TListBoxStyle);
    function GetColumns: Integer;
    procedure SetColumns(const Value: Integer);
    function GetIntegralHeight: Boolean;
    procedure SetIntegralHeight(const Value: Boolean);
    function GetItemHeight: Integer;
    procedure SetItemHeight(const Value: Integer);
    function GetTabWidth: Integer;
    procedure SetTabWidth(const Value: Integer);
    function GetAutoComplete: Boolean;
    procedure SetAutoComplete(const Value: Boolean);
    function GetAutoCompleteDelay: Cardinal;
    procedure SetAutoCompleteDelay(const Value: Cardinal);
    function GetCount: Integer;
    function GetTopIndex: Integer;
    procedure SetTopIndex(const Value: Integer);
    function GetSelCount: Integer;
    function GetSelected(Index: Integer): Boolean;
    procedure SetSelected(Index: Integer; const Value: Boolean);

    { ADDED: Accessors for DragMode from the inner ListBox }
    function GetDragMode: TDragMode;
    procedure SetDragMode(const Value: TDragMode);

    { Color and behavior setters }
    procedure SetAccentColor(const Value: TColor);
    procedure SetBackgroundColor(const Value: TColor);
    procedure SetBackgroundHoverColor(const Value: TColor);
    procedure SetBackgroundFocusColor(const Value: TColor);
    procedure SetBorderColor(const Value: TColor);
    procedure SetLabelColor(const Value: TColor);
    procedure SetScrollThumbColor(const Value: TColor);
    procedure SetScrollThumbHoverColor(const Value: TColor);
    procedure SetDisabledColor(const Value: TColor);
    procedure SetDisabledBorderColor(const Value: TColor);
    procedure SetScrollbarAreaWidth(const Value: Integer);
    procedure SetScrollbarThumbWidth(const Value: Integer);
    procedure SetScrollbarThumbHoverWidth(const Value: Integer);
    procedure SetShowBorder(const Value: Boolean);
    procedure SetShowAccentBar(const Value: Boolean);
    procedure SetCornerColor(const Value: TColor);
    function GetEffectiveCornerColor: TColor;
    procedure SetCornerRadius(const Value: Single);
    procedure ReadCornerRadius(Reader: TReader);
    procedure WriteCornerRadius(Writer: TWriter);

    { Corner selection setters }
    procedure SetCornerTopLeft(const Value: Boolean);
    procedure SetCornerTopRight(const Value: Boolean);
    procedure SetCornerBottomLeft(const Value: Boolean);
    procedure SetCornerBottomRight(const Value: Boolean);

    function Scale(Value: Integer): Integer;
    function ScaleF(Value: Single): Single;

    function MakeGPColor(AColor: TColor; Alpha: Byte = 255): Cardinal;
    function CreateRoundRectPath(X, Y, W, H, R: Single; AForceAllCorners: Boolean = False): TGPGraphicsPath;
    procedure PaintToBuffer;

    { Internal handlers }
    procedure ListBoxEnter(Sender: TObject);
    procedure ListBoxExit(Sender: TObject);
    procedure ListBoxClick(Sender: TObject);
    procedure ListBoxDblClick(Sender: TObject);
    procedure ListBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ListBoxKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ListBoxKeyPress(Sender: TObject; var Key: Char);
    procedure ListBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ListBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ListBoxMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ListBoxContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure ListBoxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure ListBoxMeasureItem(Control: TWinControl; Index: Integer; var Height: Integer);
    procedure ListBoxData(Control: TWinControl; Index: Integer; var Data: string);
    function ListBoxDataFind(Control: TWinControl; FindString: string): Integer;
    procedure ListBoxDataObject(Control: TWinControl; Index: Integer; var DataObject: TObject);

    procedure CMFontChanged(var Msg: TMessage); message CM_FONTCHANGED;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;
    procedure CMColorChanged(var Msg: TMessage); message CM_COLORCHANGED;
    procedure CMPPIChanged(var Msg: TMessage); message CM_PPICHANGED;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
    function GetListCanvas: TCanvas;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    { When the scrollbar is visible the inner list box is narrower, so the
      scrollbar strip belongs to this outer window. Forward the wheel to the
      inner list so hovering the scrollbar still scrolls the list. }
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure ChangeScale(M, D: Integer); override;

    { ADDED: Intercepting system drag-drop messages }
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetFocus; override;
    procedure BeginDrag(Immediate: Boolean; Threshold: Integer = -1); reintroduce;
    property ListBox: TCWSInternalListBox read FListBox;
    { Drawing surface used by the OnDrawItem event — maps to the inner list
      box's canvas, so handlers can paint with CWSListBox.Canvas directly
      (no need for CWSListBox.ListBox.Canvas). CellCanvas is a back-compat alias. }
    property Canvas: TCanvas read GetListCanvas;
    property CellCanvas: TCanvas read GetListCanvas;

    { Public methods — equivalents of TListBox methods }
    procedure Clear;
    procedure ClearSelection;
    procedure DeleteSelected;
    procedure SelectAll;
    procedure AddItem(const Item: string; AObject: TObject);
    function ItemAtPos(Pos: TPoint; Existing: Boolean): Integer;
    function ItemRect(Index: Integer): TRect;
    property Selected[Index: Integer]: Boolean read GetSelected write SetSelected;

    { Public properties (runtime-only) }
    property Count: Integer read GetCount;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex;
    property TopIndex: Integer read GetTopIndex write SetTopIndex;
    property SelCount: Integer read GetSelCount;
  published
    property Items: TStrings read GetItems write SetItems;
    property LabelText: string read FLabel write SetLabel;
    property MultiSelect: Boolean read GetMultiSelect write SetMultiSelect default False;
    property ExtendedSelect: Boolean read GetExtendedSelect write SetExtendedSelect default True;
    property Sorted: Boolean read GetSorted write SetSorted default False;
    property Style: TListBoxStyle read GetStyle write SetStyle default lbStandard;
    property Columns: Integer read GetColumns write SetColumns default 0;
    property IntegralHeight: Boolean read GetIntegralHeight write SetIntegralHeight default True;
    property ItemHeight: Integer read GetItemHeight write SetItemHeight default 16;
    property TabWidth: Integer read GetTabWidth write SetTabWidth default 0;
    property AutoComplete: Boolean read GetAutoComplete write SetAutoComplete default True;
    property AutoCompleteDelay: Cardinal read GetAutoCompleteDelay write SetAutoCompleteDelay default 500;

    { ADDED: Publishing Drag & Drop related properties }
    property DragMode: TDragMode read GetDragMode write SetDragMode default dmManual;
    property DragKind;
    property DragCursor;

    property AccentColor: TColor read FAccentColor write SetAccentColor default $D47800;
    property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor default clWhite;
    property BackgroundHoverColor: TColor read FBackgroundHoverColor write SetBackgroundHoverColor default $F9F9F9;
    property BackgroundFocusColor: TColor read FBackgroundFocusColor write SetBackgroundFocusColor default clWhite;
    property BorderColor: TColor read FBorderColor write SetBorderColor default $D6D6D6;
    property LabelColor: TColor read FLabelColor write SetLabelColor default $606060;
    property ScrollThumbColor: TColor read FScrollThumbColor write SetScrollThumbColor default $C0C0C0;
    property ScrollThumbHoverColor: TColor read FScrollThumbHoverColor write SetScrollThumbHoverColor default $909090;
    property DisabledColor: TColor read FDisabledColor write SetDisabledColor default $F7F7F7;
    property DisabledBorderColor: TColor read FDisabledBorderColor write SetDisabledBorderColor default $E0E0E0;
    property ScrollbarAreaWidth: Integer read FScrollbarAreaWidth write SetScrollbarAreaWidth default 14;
    property ScrollbarThumbWidth: Integer read FScrollbarThumbWidth write SetScrollbarThumbWidth default 4;
    property ScrollbarThumbHoverWidth: Integer read FScrollbarThumbHoverWidth write SetScrollbarThumbHoverWidth default 6;
    property CornerRadius: Single read FCornerRadius write SetCornerRadius stored False;
    property ShowBorder: Boolean read FShowBorder write SetShowBorder default True;
    property ShowAccentBar: Boolean read FShowAccentBar write SetShowAccentBar default True;
    property CornerColor: TColor read FCornerColor write SetCornerColor default clNone;

    { Selective Corners }
    property CornerTopLeft: Boolean read FCornerTopLeft write SetCornerTopLeft default True;
    property CornerTopRight: Boolean read FCornerTopRight write SetCornerTopRight default True;
    property CornerBottomLeft: Boolean read FCornerBottomLeft write SetCornerBottomLeft default True;
    property CornerBottomRight: Boolean read FCornerBottomRight write SetCornerBottomRight default True;

    { Background of the WHOLE component rectangle (incl. the area outside the
      rounded corners). With ParentColor = True it blends with the parent;
      set Color explicitly to paint the whole component in a fixed color. }
    property Color;
    property ParentColor;
    property Align;
    property Anchors;
    property Font;
    property ParentFont;
    property Enabled;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnKeyDown: TKeyEvent read FOnKeyDown write FOnKeyDown;
    property OnKeyUp: TKeyEvent read FOnKeyUp write FOnKeyUp;
    property OnKeyPress: TKeyPressEvent read FOnKeyPress write FOnKeyPress;
    property OnEnter: TNotifyEvent read FOnEnter write FOnEnter;
    property OnExit: TNotifyEvent read FOnExit write FOnExit;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
    property OnMouseWheel: TMouseWheelEvent read FOnMouseWheel write FOnMouseWheel;
    property OnContextPopup: TContextPopupEvent read FOnContextPopup write FOnContextPopup;
    property OnDrawItem: TDrawItemEvent read FOnDrawItem write FOnDrawItem;
    property OnMeasureItem: TMeasureItemEvent read FOnMeasureItem write FOnMeasureItem;
    property OnData: TLBGetDataEvent read FOnData write FOnData;
    property OnDataFind: TLBFindDataEvent read FOnDataFind write FOnDataFind;
    property OnDataObject: TLBGetDataObjectEvent read FOnDataObject write FOnDataObject;

    { ADDED: Publishing Drag & Drop events }
    property OnDragOver;
    property OnDragDrop;
    property OnEndDrag;
    property OnStartDrag;
  end;

implementation

type
  { Cracker that exposes the parent's protected Color property. }
  TControlAccess = class(TControl);

{ Unwraps the Source passed by the VCL to the actual source control.
  - TDragControlObject -> its .Control
  - TCWSInternalListBox -> its owner (TCWSListBox)
  This makes "Source is TCWSListBox" always work in user code. }
function UnwrapDragSource(Source: TObject): TObject;
begin
  Result := Source;
  if Result is TDragControlObject then
    Result := TDragControlObject(Result).Control;
  if Result is TCWSInternalListBox then
    Result := TCWSInternalListBox(Result).FOwner;
end;

{ ======================================================================== }
{ TCWSInternalListBox                                                      }
{ ======================================================================== }

constructor TCWSInternalListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOwner := TCWSListBox(AOwner);
  BorderStyle := bsNone;
  Self.WindowProc := NewWindowProc;
end;

procedure TCWSInternalListBox.CreateParams(var Params: TCreateParams);
begin
  inherited;
  { Remove the native vertical scrollbar — we draw our own }
  Params.Style := Params.Style and (not WS_VSCROLL);
  Params.ExStyle := Params.ExStyle or WS_EX_COMPOSITED;
end;

procedure TCWSInternalListBox.CreateWnd;
begin
  inherited;
  { Windows 11 draws the native LISTBOX selection with rounded corners
    (common controls theme). That rounding does not depend on CornerRadius nor
    on the window region. Disabling the theme restores the classic rectangular
    selection, so the control's shape is fully governed by the component
    (region/outline), not by the system theme. }
  SetWindowTheme(Handle, '', '');
end;

function TCWSInternalListBox.GetItemHeight: Integer;
begin
  if HandleAllocated and (Perform(LB_GETCOUNT, 0, 0) > 0) then
    Result := Perform(LB_GETITEMHEIGHT, 0, 0)
  else
  begin
    { Fallback — estimate from font }
    Result := Abs(Font.Height) + 4;
    if Result <= 0 then
      Result := 16;
  end;
end;

function TCWSInternalListBox.GetVisibleItems: Integer;
var
  IH: Integer;
begin
  IH := GetItemHeight;
  if IH > 0 then
    Result := Max(1, ClientHeight div IH)
  else
    Result := 1;
end;

function TCWSInternalListBox.GetTotalItems: Integer;
begin
  if HandleAllocated then
    Result := Perform(LB_GETCOUNT, 0, 0)
  else
    Result := Items.Count;
end;

function TCWSInternalListBox.GetTopIndex: Integer;
begin
  if HandleAllocated then
    Result := Perform(LB_GETTOPINDEX, 0, 0)
  else
    Result := 0;
end;

procedure TCWSInternalListBox.SetTopIndex(Value: Integer);
begin
  if HandleAllocated then
    Perform(LB_SETTOPINDEX, Value, 0);
end;

procedure TCWSInternalListBox.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  FOwner.CMMouseEnter(Message);
end;

procedure TCWSInternalListBox.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FOwner.CMMouseLeave(Message);
end;

procedure TCWSInternalListBox.NewWindowProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_VSCROLL, WM_MOUSEWHEEL, WM_KEYDOWN, WM_KEYUP,
    LB_ADDSTRING, LB_INSERTSTRING, LB_DELETESTRING, LB_RESETCONTENT,
    LB_SETTOPINDEX:
      begin
        inherited WndProc(Message);
        { Trigger recalculation of position and region in the main component }
        FOwner.UpdateListBoxPosition;
        FOwner.Invalidate;
      end;
    WM_NCPAINT:
      Exit;
  else
    inherited WndProc(Message);
  end;
end;

procedure TCWSInternalListBox.WMNCPaint(var Msg: TMessage);
begin
  { Suppress default NC frame painting }
end;

procedure TCWSInternalListBox.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

procedure TCWSInternalListBox.MouseWheelHandler(var Message: TMessage);
var
  NewTop, Total, Visible: Integer;
begin
  Total := GetTotalItems;
  Visible := GetVisibleItems;
  NewTop := GetTopIndex;

  if TWMMouseWheel(Message).WheelDelta > 0 then
    NewTop := Max(0, NewTop - 3)
  else
    NewTop := Min(Max(0, Total - Visible), NewTop + 3);

  SetTopIndex(NewTop);
  FOwner.UpdateListBoxPosition;
  FOwner.Invalidate;

  if Assigned(FOwner.FOnMouseWheel) then
  begin
    var Handled := False;
    FOwner.FOnMouseWheel(
      FOwner,
      KeysToShiftState(TWMMouseWheel(Message).Keys),
      TWMMouseWheel(Message).WheelDelta,
      SmallPointToPoint(TWMMouseWheel(Message).Pos),
      Handled
    );
  end;
  Message.Result := 0;
end;

{ *** Auto-drag only over a selected item *** }

procedure TCWSInternalListBox.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Idx: Integer;
  AllowDrag: Boolean;
begin
  { When DragMode = dmAutomatic, the VCL starts dragging on every
    press + move — even over an empty area (the "no-drop circle" cursor).
    We allow drag only when the click lands on a selected item (also works in
    MultiSelect mode). Otherwise we temporarily switch to dmManual, so auto-drag
    does not start and the cursor does not change to crNoDrop. }
  if (Button = mbLeft) and (DragMode = dmAutomatic) then
  begin
    Idx := ItemAtPos(Point(X, Y), True);   // -1 when outside items / empty list
    AllowDrag := (Idx >= 0) and Selected[Idx];
    if not AllowDrag then
    begin
      FSavedDragMode  := DragMode;
      DragMode        := dmManual;
      FDragSuppressed := True;
    end;
  end;
  inherited;
end;

procedure TCWSInternalListBox.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if FDragSuppressed then
  begin
    DragMode        := FSavedDragMode;
    FDragSuppressed := False;
  end;
end;

{ *** Drag & Drop — przekierowanie na FOwner (TCWSListBox) *** }

procedure TCWSInternalListBox.DoStartDrag(var DragObject: TDragObject);
begin
  { SOURCE FIX: We create a TDragControlObject pointing at FOwner.
    This makes the Source parameter in OnDragOver/OnDragDrop on any target
    control = TCWSListBox, not TCWSInternalListBox. }
  DragObject := TDragControlObject.Create(FOwner);
end;

procedure TCWSInternalListBox.DoEndDrag(Target: TObject; X, Y: Integer);
begin
  if Assigned(FOwner.OnEndDrag) then
    FOwner.OnEndDrag(FOwner, Target, X, Y);
end;

procedure TCWSInternalListBox.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  { TARGET FIX: the VCL sends CM_DRAG to FListBox (since it fills the interior).
    We unwrap Source to the proper control and redirect to FOwner, so that the
    OnDragOver assigned to TCWSListBox fires. }
  Source := UnwrapDragSource(Source);
  FOwner.DragOver(Source, X, Y, State, Accept);
end;

procedure TCWSInternalListBox.DragDrop(Source: TObject; X, Y: Integer);
begin
  Source := UnwrapDragSource(Source);
  FOwner.DragDrop(Source, X, Y);
end;

{ ======================================================================== }
{ TCWSListBox                                                              }
{ ======================================================================== }

constructor TCWSListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 200;
  Height := 200;
  DoubleBuffered := True;
  { Default: the whole-component background follows the parent. Setting Color
    in the Object Inspector flips ParentColor to False and uses Color instead. }
  ParentColor := True;

  FCornerRadius := 4;
  FCornerTopLeft := True;
  FCornerTopRight := True;
  FCornerBottomLeft := True;
  FCornerBottomRight := True;

  FBackgroundColor := clWhite;
  FBackgroundHoverColor := $F9F9F9;
  FBackgroundFocusColor := clWhite;
  FBorderColor := $D6D6D6;
  FAccentColor := $D47800;
  FScrollThumbColor := $C0C0C0;
  FScrollThumbHoverColor := $909090;
  FDisabledColor := $F7F7F7;
  FDisabledBorderColor := $E0E0E0;
  FScrollbarAreaWidth := 14;
  FScrollbarThumbWidth := 4;
  FScrollbarThumbHoverWidth := 6;
  FLabelColor := $606060;
  FShowBorder := True;
  FShowAccentBar := True;
  FCornerColor := clNone;

  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf32bit;

  FListBox := TCWSInternalListBox.Create(Self);
  FListBox.Parent := Self;
  FListBox.OnEnter        := ListBoxEnter;
  FListBox.OnExit         := ListBoxExit;
  FListBox.OnClick        := ListBoxClick;
  FListBox.OnDblClick     := ListBoxDblClick;
  FListBox.OnKeyDown      := ListBoxKeyDown;
  FListBox.OnKeyUp        := ListBoxKeyUp;
  FListBox.OnKeyPress     := ListBoxKeyPress;
  FListBox.OnMouseDown    := ListBoxMouseDown;
  FListBox.OnMouseMove    := ListBoxMouseMove;
  FListBox.OnMouseUp      := ListBoxMouseUp;
  FListBox.OnContextPopup := ListBoxContextPopup;
  FListBox.OnDrawItem     := ListBoxDrawItem;
  FListBox.OnMeasureItem  := ListBoxMeasureItem;
  FListBox.OnData         := ListBoxData;
  FListBox.OnDataFind     := ListBoxDataFind;
  FListBox.OnDataObject   := ListBoxDataObject;

  FRepeatTimer := TTimer.Create(Self);
  FRepeatTimer.Enabled := False;
  FRepeatTimer.OnTimer := RepeatTimerTick;
end;

destructor TCWSListBox.Destroy;
begin
  if FRepeatTimer <> nil then
    FRepeatTimer.Enabled := False;
  if (FListBox <> nil) and FListBox.HandleAllocated then
    SetWindowRgn(FListBox.Handle, 0, False);
  FBuffer.Free;
  inherited;
end;

{ *** Property getters/setters — ListBox properties *** }

function TCWSListBox.GetItems: TStrings;
begin
  Result := FListBox.Items;
end;

procedure TCWSListBox.SetItems(const Value: TStrings);
begin
  FListBox.Items.Assign(Value);
  UpdateListBoxPosition;
  Invalidate;
end;

function TCWSListBox.GetItemIndex: Integer;
begin
  Result := FListBox.ItemIndex;
end;

procedure TCWSListBox.SetItemIndex(const Value: Integer);
begin
  FListBox.ItemIndex := Value;
  UpdateListBoxPosition;
  Invalidate;
end;

function TCWSListBox.GetMultiSelect: Boolean;
begin
  Result := FListBox.MultiSelect;
end;

procedure TCWSListBox.SetMultiSelect(const Value: Boolean);
begin
  FListBox.MultiSelect := Value;
end;

function TCWSListBox.GetExtendedSelect: Boolean;
begin
  Result := FListBox.ExtendedSelect;
end;

procedure TCWSListBox.SetExtendedSelect(const Value: Boolean);
begin
  FListBox.ExtendedSelect := Value;
end;

function TCWSListBox.GetSorted: Boolean;
begin
  Result := FListBox.Sorted;
end;

procedure TCWSListBox.SetSorted(const Value: Boolean);
begin
  FListBox.Sorted := Value;
  UpdateListBoxPosition;
  Invalidate;
end;

function TCWSListBox.GetStyle: TListBoxStyle;
begin
  Result := FListBox.Style;
end;

procedure TCWSListBox.SetStyle(const Value: TListBoxStyle);
begin
  FListBox.Style := Value;
  UpdateListBoxPosition;
  Invalidate;
end;

function TCWSListBox.GetColumns: Integer;
begin
  Result := FListBox.Columns;
end;

procedure TCWSListBox.SetColumns(const Value: Integer);
begin
  FListBox.Columns := Value;
  Invalidate;
end;

function TCWSListBox.GetIntegralHeight: Boolean;
begin
  Result := FListBox.IntegralHeight;
end;

procedure TCWSListBox.SetIntegralHeight(const Value: Boolean);
begin
  FListBox.IntegralHeight := Value;
  UpdateListBoxPosition;
  Invalidate;
end;

function TCWSListBox.GetItemHeight: Integer;
begin
  Result := FListBox.ItemHeight;
end;

procedure TCWSListBox.SetItemHeight(const Value: Integer);
begin
  FListBox.ItemHeight := Value;
  UpdateListBoxPosition;
  Invalidate;
end;

function TCWSListBox.GetTabWidth: Integer;
begin
  Result := FListBox.TabWidth;
end;

procedure TCWSListBox.SetTabWidth(const Value: Integer);
begin
  FListBox.TabWidth := Value;
  Invalidate;
end;

function TCWSListBox.GetAutoComplete: Boolean;
begin
  Result := FListBox.AutoComplete;
end;

procedure TCWSListBox.SetAutoComplete(const Value: Boolean);
begin
  FListBox.AutoComplete := Value;
end;

function TCWSListBox.GetAutoCompleteDelay: Cardinal;
begin
  Result := FListBox.AutoCompleteDelay;
end;

procedure TCWSListBox.SetAutoCompleteDelay(const Value: Cardinal);
begin
  FListBox.AutoCompleteDelay := Value;
end;

function TCWSListBox.GetCount: Integer;
begin
  Result := FListBox.Count;
end;

function TCWSListBox.GetTopIndex: Integer;
begin
  Result := FListBox.GetTopIndex;
end;

procedure TCWSListBox.SetTopIndex(const Value: Integer);
begin
  FListBox.SetTopIndex(Value);
  UpdateListBoxPosition;
  Invalidate;
end;

function TCWSListBox.GetSelCount: Integer;
begin
  Result := FListBox.SelCount;
end;

function TCWSListBox.GetSelected(Index: Integer): Boolean;
begin
  Result := FListBox.Selected[Index];
end;

procedure TCWSListBox.SetSelected(Index: Integer; const Value: Boolean);
begin
  FListBox.Selected[Index] := Value;
end;

{ ADDED: getter/setter implementation for DragMode }
function TCWSListBox.GetDragMode: TDragMode;
begin
  Result := FListBox.DragMode;
end;

procedure TCWSListBox.SetDragMode(const Value: TDragMode);
begin
  FListBox.DragMode := Value;
end;

{ *** Public methods *** }

procedure TCWSListBox.Clear;
begin
  FListBox.Clear;
  UpdateListBoxPosition;
  Invalidate;
end;

procedure TCWSListBox.ClearSelection;
var
  I: Integer;
begin
  if FListBox.MultiSelect then
  begin
    for I := 0 to FListBox.Count - 1 do
      FListBox.Selected[I] := False;
  end
  else
    FListBox.ItemIndex := -1;
end;

procedure TCWSListBox.DeleteSelected;
begin
  FListBox.DeleteSelected;
  UpdateListBoxPosition;
  Invalidate;
end;

procedure TCWSListBox.SelectAll;
begin
  FListBox.SelectAll;
end;

procedure TCWSListBox.AddItem(const Item: string; AObject: TObject);
begin
  FListBox.AddItem(Item, AObject);
  UpdateListBoxPosition;
  Invalidate;
end;

function TCWSListBox.ItemAtPos(Pos: TPoint; Existing: Boolean): Integer;
begin
  Result := FListBox.ItemAtPos(Pos, Existing);
end;

function TCWSListBox.ItemRect(Index: Integer): TRect;
begin
  Result := FListBox.ItemRect(Index);
end;

{ *** Scaling *** }

function TCWSListBox.Scale(Value: Integer): Integer;
begin
  Result := MulDiv(Value, CurrentPPI, 96);
end;

function TCWSListBox.ScaleF(Value: Single): Single;
begin
  Result := Value * CurrentPPI / 96;
end;

{ *** DPI *** }

procedure TCWSListBox.CMPPIChanged(var Msg: TMessage);
begin
  inherited;
  if FBuffer <> nil then
    FBuffer.SetSize(0, 0);
  SyncListBoxFont;
  UpdateListBoxPosition;
  Invalidate;
end;

procedure TCWSListBox.ChangeScale(M, D: Integer);
begin
  inherited ChangeScale(M, D);
  if FBuffer <> nil then
    FBuffer.SetSize(0, 0);
  SyncListBoxFont;
  UpdateListBoxPosition;
end;

{ *** Color and feature setters *** }

procedure TCWSListBox.SetAccentColor(const Value: TColor);
begin
  FAccentColor := Value;
  Invalidate;
end;

procedure TCWSListBox.SetBackgroundColor(const Value: TColor);
begin
  FBackgroundColor := Value;
  ApplyStateChange;
end;

procedure TCWSListBox.SetBackgroundHoverColor(const Value: TColor);
begin
  FBackgroundHoverColor := Value;
  ApplyStateChange;
end;

procedure TCWSListBox.SetBackgroundFocusColor(const Value: TColor);
begin
  FBackgroundFocusColor := Value;
  ApplyStateChange;
end;

procedure TCWSListBox.SetBorderColor(const Value: TColor);
begin
  FBorderColor := Value;
  Invalidate;
end;

procedure TCWSListBox.SetLabelColor(const Value: TColor);
begin
  FLabelColor := Value;
  Invalidate;
end;

procedure TCWSListBox.SetScrollThumbColor(const Value: TColor);
begin
  FScrollThumbColor := Value;
  Invalidate;
end;

procedure TCWSListBox.SetScrollThumbHoverColor(const Value: TColor);
begin
  FScrollThumbHoverColor := Value;
  ApplyStateChange;
end;

procedure TCWSListBox.SetDisabledColor(const Value: TColor);
begin
  FDisabledColor := Value;
  ApplyStateChange;
end;

procedure TCWSListBox.SetDisabledBorderColor(const Value: TColor);
begin
  FDisabledBorderColor := Value;
  Invalidate;
end;

procedure TCWSListBox.SetScrollbarAreaWidth(const Value: Integer);
begin
  if FScrollbarAreaWidth <> Value then
  begin
    FScrollbarAreaWidth := Max(6, Value);
    UpdateListBoxPosition;
    Invalidate;
  end;
end;

procedure TCWSListBox.SetScrollbarThumbWidth(const Value: Integer);
begin
  if FScrollbarThumbWidth <> Value then
  begin
    FScrollbarThumbWidth := Max(2, Value);
    UpdateListBoxPosition;
    Invalidate;
  end;
end;

procedure TCWSListBox.SetScrollbarThumbHoverWidth(const Value: Integer);
begin
  if FScrollbarThumbHoverWidth <> Value then
  begin
    FScrollbarThumbHoverWidth := Max(2, Value);
    UpdateListBoxPosition;
    Invalidate;
  end;
end;

procedure TCWSListBox.SetShowBorder(const Value: Boolean);
begin
  if FShowBorder <> Value then
  begin
    FShowBorder := Value;
    Invalidate;
  end;
end;

procedure TCWSListBox.SetShowAccentBar(const Value: Boolean);
begin
  if FShowAccentBar <> Value then
  begin
    FShowAccentBar := Value;
    UpdateListBoxPosition;
    Invalidate;
  end;
end;

{ *** Selective Corners Setters *** }

procedure TCWSListBox.SetCornerRadius(const Value: Single);
var
  NewValue: Single;
begin
  NewValue := Value;
  if NewValue < 0 then
    NewValue := 0;
  if FCornerRadius <> NewValue then
  begin
    FCornerRadius := NewValue;
    { Rebuild the inner ListBox region — without this the old rounded region
      stays applied and the selection is still clipped to the corners. }
    UpdateListBoxPosition;
    Invalidate;
  end;
end;

procedure TCWSListBox.ReadCornerRadius(Reader: TReader);
begin
  { Read straight into the field — the region will be rebuilt in Loaded anyway. }
  FCornerRadius := Reader.ReadFloat;
end;

procedure TCWSListBox.WriteCornerRadius(Writer: TWriter);
begin
  Writer.WriteFloat(FCornerRadius);
end;

procedure TCWSListBox.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  { Floating-point properties with value 0 are skipped by the standard DFM
    streamer (0 = default for float). Thanks to this entry CornerRadius is always
    saved, even when set to 0. }
  Filer.DefineProperty('CornerRadiusF', ReadCornerRadius, WriteCornerRadius, True);
end;

procedure TCWSListBox.SetCornerTopLeft(const Value: Boolean);
begin
  if FCornerTopLeft <> Value then
  begin
    FCornerTopLeft := Value;
    UpdateListBoxPosition;
    Invalidate;
  end;
end;

procedure TCWSListBox.SetCornerTopRight(const Value: Boolean);
begin
  if FCornerTopRight <> Value then
  begin
    FCornerTopRight := Value;
    UpdateListBoxPosition;
    Invalidate;
  end;
end;

procedure TCWSListBox.SetCornerBottomLeft(const Value: Boolean);
begin
  if FCornerBottomLeft <> Value then
  begin
    FCornerBottomLeft := Value;
    UpdateListBoxPosition;
    Invalidate;
  end;
end;

procedure TCWSListBox.SetCornerBottomRight(const Value: Boolean);
begin
  if FCornerBottomRight <> Value then
  begin
    FCornerBottomRight := Value;
    UpdateListBoxPosition;
    Invalidate;
  end;
end;

{ *** Focus handlers *** }

procedure TCWSListBox.ListBoxEnter(Sender: TObject);
begin
  FFocused := True;
  UpdateListBoxPosition;
  ApplyStateChange;
  if Assigned(FOnEnter) then
    FOnEnter(Self);
end;

procedure TCWSListBox.ListBoxExit(Sender: TObject);
begin
  FFocused := False;
  UpdateListBoxPosition;
  ApplyStateChange;
  if Assigned(FOnExit) then
    FOnExit(Self);
end;

{ *** ListBox event handlers *** }

procedure TCWSListBox.ListBoxClick(Sender: TObject);
begin
  UpdateListBoxPosition;
  Invalidate;
  if Assigned(FOnClick) then
    FOnClick(Self);
end;

procedure TCWSListBox.ListBoxDblClick(Sender: TObject);
begin
  if Assigned(FOnDblClick) then
    FOnDblClick(Self);
end;

procedure TCWSListBox.ListBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnKeyDown) then
    FOnKeyDown(Self, Key, Shift);
end;

procedure TCWSListBox.ListBoxKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnKeyUp) then
    FOnKeyUp(Self, Key, Shift);
end;

procedure TCWSListBox.ListBoxKeyPress(Sender: TObject; var Key: Char);
begin
  if Assigned(FOnKeyPress) then
    FOnKeyPress(Self, Key);
end;

procedure TCWSListBox.ListBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  { The VCL handles BeginDrag automatically for FListBox.DragMode = dmAutomatic.
    DoStartDrag creates TDragControlObject(Self) — Source is correct. }
  if Assigned(FOnMouseDown) then
    FOnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TCWSListBox.ListBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseMove) then
    FOnMouseMove(Self, Shift, X, Y);
end;

procedure TCWSListBox.ListBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseUp) then
    FOnMouseUp(Self, Button, Shift, X, Y);
end;

procedure TCWSListBox.ListBoxContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  if Assigned(FOnContextPopup) then
    FOnContextPopup(Self, MousePos, Handled);
end;

procedure TCWSListBox.ListBoxDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  LTextRect: TRect;
begin
  { Focus is focus: the state background (focus / hover / normal — or the
    selection highlight) must cover the WHOLE item row, exactly like the empty
    area of the list, no matter whether the default text drawing runs or a user
    OnDrawItem handler does, and for both lbOwnerDrawFixed and lbOwnerDrawVariable.
    Owner-draw does not pre-fill item rects, so we paint the state background here
    FIRST and only then let the handler draw on top. Without this, a handler that
    only draws text (or draws a transparent background) would leave the focus
    colour showing only in the empty space below the items. }
  with FListBox.Canvas do
  begin
    if odSelected in State then
    begin
      Brush.Color := clHighlight;
      Font.Color  := clHighlightText;
    end
    else
    begin
      Brush.Color := GetCurrentBgColor;
      Font.Color  := FListBox.Font.Color;
    end;
    FillRect(Rect);
  end;

  if Assigned(FOnDrawItem) then
    FOnDrawItem(FListBox, Index, Rect, State)
  else
  begin
    if (Index >= 0) and (Index < FListBox.Items.Count) then
    begin
      { Inner text margins: 10px on the left and right }
      LTextRect := Rect;
      LTextRect.Left := LTextRect.Left + 10;
      LTextRect.Right := LTextRect.Right - 10;

      { Use the safe DrawText for nice text alignment and trimming }
      Winapi.Windows.DrawText(FListBox.Canvas.Handle, FListBox.Items[Index], -1,
        LTextRect, DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX);
    end;
    if odFocused in State then
      DrawFocusRect(FListBox.Canvas.Handle, Rect);
  end;
end;

procedure TCWSListBox.ListBoxMeasureItem(Control: TWinControl; Index: Integer;
  var Height: Integer);
begin
  if Assigned(FOnMeasureItem) then
    FOnMeasureItem(FListBox, Index, Height);
end;

procedure TCWSListBox.ListBoxData(Control: TWinControl; Index: Integer;
  var Data: string);
begin
  if Assigned(FOnData) then
    FOnData(FListBox, Index, Data);
end;

function TCWSListBox.ListBoxDataFind(Control: TWinControl;
  FindString: string): Integer;
begin
  if Assigned(FOnDataFind) then
    Result := FOnDataFind(FListBox, FindString)
  else
    Result := -1;
end;

procedure TCWSListBox.ListBoxDataObject(Control: TWinControl; Index: Integer;
  var DataObject: TObject);
begin
  if Assigned(FOnDataObject) then
    FOnDataObject(FListBox, Index, DataObject);
end;

{ *** State and colors *** }

procedure TCWSListBox.ApplyStateChange;
begin
  if FListBox <> nil then
  begin
    FListBox.Color := GetCurrentBgColor;
    if FListBox.HandleAllocated then
      FListBox.Invalidate;
  end;
  Invalidate;
end;

function TCWSListBox.GetCurrentBgColor: TColor;
begin
  if not Enabled then
    Result := FDisabledColor
  else if FFocused then
    Result := FBackgroundFocusColor
  else if FHovered then
    Result := FBackgroundHoverColor
  else
    Result := FBackgroundColor;
end;

function TCWSListBox.GetParentBgColor: TColor;
begin
  if Parent <> nil then
    Result := TControlAccess(Parent).Color
  else
    Result := clBtnFace;
end;

procedure TCWSListBox.DrawParentBackground(DC: HDC; ARadius: Single);
var
  SaveIdx: Integer;
  Rgn: HRGN;
  D: Integer;
begin
  { Only when the corners are meant to blend with the parent — an explicit
    CornerColor or a user-set Color is a deliberate choice and must stand. }
  if (FCornerColor <> clNone) or not ParentColor then
    Exit;
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

{ *** Positioning *** }

procedure TCWSListBox.UpdateListBoxPosition;
var
  L, T, H, LblH, RgnRadius, Dia, AccentH, BottomMargin, ItemH: Integer;
  Rgn, TempRgn: HRGN;
  HasAnyCorner: Boolean;
  ClipTopLeft, ClipTopRight, ClipBottomLeft, ClipBottomRight: Boolean;
begin
  L := 1;
  LblH := IfThen(FLabel <> '', Scale(20), 0);
  T := Scale(1) + LblH;

  { If the accent bar is enabled and we have focus, reserve a bottom margin for it }
  if Enabled and FFocused and FShowAccentBar then
  begin
    AccentH := Scale(2);
    BottomMargin := AccentH + Scale(1);
  end
  else
    BottomMargin := Scale(1);

  H := Height - T - BottomMargin;

  FScrollTrackRect := Rect(
    Width - Scale(FScrollbarAreaWidth), T,
    Width - Scale(2), T + Max(10, H));

  { Decide scrollbar visibility from the HEIGHT we are about to apply, not from
    the inner list box's current ClientHeight — that still reflects the previous
    size until the SetBounds below runs. A single-step resize (maximize/restore
    via a title-bar double click) otherwise computes visibility from the stale
    height, so the scrollbar wrongly stays/disappears until the next repaint
    (e.g. on mouse-enter). A drag-resize hid this because it fires many steps and
    self-corrects on the following one. The inner list box has no border
    (bsNone), so its ClientHeight equals the height passed here. }
  ItemH := Max(1, FListBox.GetItemHeight);
  FScrollVisible := FListBox.GetTotalItems > Max(1, Max(10, H) div ItemH);

  { FIX: If the scrollbar is not visible, stretch the inner ListBox to full width }
  if FScrollVisible then
    FListBox.SetBounds(L, T, Max(10, FScrollTrackRect.Left - L), Max(10, H))
  else
    FListBox.SetBounds(L, T, Max(10, Width - (L * 2)), Max(10, H));

  { Now the inner list box has its final size, so compute the thumb geometry
    (and confirm FScrollVisible consistently) from the real, current metrics. }
  UpdateScrollbarMetrics;

  if FListBox.HandleAllocated then
  begin
    RgnRadius := Round(ScaleF(FCornerRadius));

    { Decide which corners of the inner ListBox to round }
    ClipTopLeft     := FCornerTopLeft;
    ClipBottomLeft  := FCornerBottomLeft;

    { FIX: If the scrollbar is visible, do NOT round the right corners of the inner ListBox }
    if FScrollVisible then
    begin
      ClipTopRight    := False;
      ClipBottomRight := False;
    end
    else
    begin
      ClipTopRight    := FCornerTopRight;
      ClipBottomRight := FCornerBottomRight;
    end;

    HasAnyCorner := ClipTopLeft or ClipTopRight or ClipBottomLeft or ClipBottomRight;

    { If the radius is 0 or all corners are disabled for the inner control, remove the region }
    if (RgnRadius <= 0) or not HasAnyCorner then
    begin
      SetWindowRgn(FListBox.Handle, 0, True);
    end
    else
    begin
      { CreateRoundRectRgn takes the corner ellipse DIMENSIONS, so the corner
        radius = dimension/2. To match the outline (GDI+ uses R as the radius),
        przekazujemy 2*RgnRadius. }
      Dia := RgnRadius * 2;
      if ClipTopLeft and ClipTopRight and ClipBottomLeft and ClipBottomRight then
      begin
        Rgn := CreateRoundRectRgn(0, 0, FListBox.Width + 1, FListBox.Height + 1, Dia, Dia);
      end
      else
      begin
        Rgn := CreateRectRgn(0, 0, FListBox.Width + 1, FListBox.Height + 1);
        TempRgn := CreateRoundRectRgn(0, 0, FListBox.Width + 1, FListBox.Height + 1, Dia, Dia);
        CombineRgn(Rgn, Rgn, TempRgn, RGN_AND);
        DeleteObject(TempRgn);

        if not ClipTopLeft then begin
          TempRgn := CreateRectRgn(0, 0, RgnRadius, RgnRadius); CombineRgn(Rgn, Rgn, TempRgn, RGN_OR); DeleteObject(TempRgn); end;
        if not ClipTopRight then begin
          TempRgn := CreateRectRgn(FListBox.Width - RgnRadius, 0, FListBox.Width + 1, RgnRadius); CombineRgn(Rgn, Rgn, TempRgn, RGN_OR); DeleteObject(TempRgn); end;
        if not ClipBottomLeft then begin
          TempRgn := CreateRectRgn(0, FListBox.Height - RgnRadius, RgnRadius, FListBox.Height + 1); CombineRgn(Rgn, Rgn, TempRgn, RGN_OR); DeleteObject(TempRgn); end;
        if not ClipBottomRight then begin
          TempRgn := CreateRectRgn(FListBox.Width - RgnRadius, FListBox.Height - RgnRadius, FListBox.Width + 1, FListBox.Height + 1); CombineRgn(Rgn, Rgn, TempRgn, RGN_OR); DeleteObject(TempRgn); end;
      end;

      if SetWindowRgn(FListBox.Handle, Rgn, True) = 0 then
        DeleteObject(Rgn);
    end;
  end;
end;

procedure TCWSListBox.UpdateScrollbarMetrics;
var
  TotalItems, VisibleItems, FirstVisible, TrackTop, TrackBottom, TrackH,
  ThumbH, ThumbP, ThumbW, CenterX, MaxScroll: Integer;
begin
  if not FListBox.HandleAllocated then
    Exit;

  TotalItems   := FListBox.GetTotalItems;
  FirstVisible := FListBox.GetTopIndex;
  VisibleItems := FListBox.GetVisibleItems;
  FScrollVisible := TotalItems > VisibleItems;

  if not FScrollVisible then
  begin
    FScrollThumbRect := Rect(0, 0, 0, 0);
    Exit;
  end;

  MaxScroll   := TotalItems - VisibleItems;
  TrackTop    := FScrollTrackRect.Top + Scale(4);
  TrackBottom := FScrollTrackRect.Bottom - Scale(4);
  TrackH      := TrackBottom - TrackTop;
  ThumbH      := Max(Scale(20), Round(TrackH * (VisibleItems / TotalItems)));

  if MaxScroll > 0 then
    ThumbP := TrackTop + Round((FirstVisible / MaxScroll) * (TrackH - ThumbH))
  else
    ThumbP := TrackTop;
  ThumbP := Max(TrackTop, Min(TrackBottom - ThumbH, ThumbP));

  if FScrollAreaHovered or FIsDragging then
    ThumbW := Scale(FScrollbarThumbHoverWidth)
  else
    ThumbW := Scale(FScrollbarThumbWidth);

  CenterX := FScrollTrackRect.Left + (FScrollTrackRect.Width - ThumbW) div 2;
  FScrollThumbRect := Rect(CenterX, ThumbP, CenterX + ThumbW, ThumbP + ThumbH);
end;

{ *** Buffer *** }

procedure TCWSListBox.EnsureBuffer;
begin
  if (FBuffer.Width <> Width) or (FBuffer.Height <> Height) then
    FBuffer.SetSize(Width, Height);
end;

{ *** Painting *** }

procedure TCWSListBox.WMPaint(var Msg: TWMPaint);
var
  PS: TPaintStruct;
  DC: HDC;
begin
  if Msg.DC <> 0 then
  begin
    inherited;
    Exit;
  end;
  DC := BeginPaint(Handle, PS);
  try
    PaintToBuffer;
    BitBlt(DC, 0, 0, Width, Height, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  finally
    EndPaint(Handle, PS);
  end;
end;

procedure TCWSListBox.SetCornerColor(const Value: TColor);
begin
  if FCornerColor <> Value then
  begin
    FCornerColor := Value;
    Invalidate;
  end;
end;

function TCWSListBox.GetEffectiveCornerColor: TColor;
begin
  if FCornerColor <> clNone then
    Result := FCornerColor          { explicit corner override wins }
  else if not ParentColor then
    Result := Color                 { whole-component Color set by the user }
  else
    Result := GetParentBgColor;     { default: blend with the parent }
end;

procedure TCWSListBox.PaintToBuffer;
var
  G: TGPGraphics;
  Path: TGPGraphicsPath;
  Brush: TGPSolidBrush;
  Pen: TGPPen;
  W, H, R: Single;
  AccentH: Integer;
  ThumbColor: Cardinal;
  ThumbAlpha: Byte;
  ThumbGP: TGPRectF;
  BorderColorToDraw: TColor;
begin
  EnsureBuffer;
  W := Width;
  H := Height;
  R := ScaleF(FCornerRadius);

  FBuffer.Canvas.Brush.Color := GetEffectiveCornerColor;
  FBuffer.Canvas.FillRect(Rect(0, 0, Width, Height));
  DrawParentBackground(FBuffer.Canvas.Handle, R);

  G := TGPGraphics.Create(FBuffer.Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    G.SetPixelOffsetMode(PixelOffsetModeHalf);

    Path := CreateRoundRectPath(0.5, 0.5, W - 1, H - 1, R);
    try
      Brush := TGPSolidBrush.Create(MakeGPColor(GetCurrentBgColor));
      G.FillPath(Brush, Path);
      Brush.Free;

      if FShowBorder then
      begin
        if not Enabled then
          BorderColorToDraw := FDisabledBorderColor
        else
          BorderColorToDraw := FBorderColor;

        Pen := TGPPen.Create(MakeGPColor(BorderColorToDraw));
        G.DrawPath(Pen, Path);
        Pen.Free;
      end
      else
      begin
        Pen := TGPPen.Create(MakeGPColor(GetEffectiveCornerColor));
        G.DrawPath(Pen, Path);
        Pen.Free;
      end;
    finally
      Path.Free;
    end;

    { Rysowanie dolnego niebieskiego paska akcentu }
    if Enabled and FFocused and FShowAccentBar then
    begin
      AccentH := Scale(2);
      Path := CreateRoundRectPath(0.0, 0.0, W, H, R);
      try
        G.SetClip(Path);
        G.SetSmoothingMode(SmoothingModeNone);
        G.SetPixelOffsetMode(PixelOffsetModeNone);
        Brush := TGPSolidBrush.Create(MakeGPColor(FAccentColor));
        G.FillRectangle(Brush, 0, Height - AccentH, Width, AccentH);
        Brush.Free;
        G.ResetClip;
      finally
        Path.Free;
      end;
      G.SetSmoothingMode(SmoothingModeAntiAlias);
      G.SetPixelOffsetMode(PixelOffsetModeHalf);
    end;

    if FScrollVisible then
    begin
      if FScrollAreaHovered or FIsDragging then
        ThumbAlpha := 220
      else
        ThumbAlpha := 140;

      if FScrollAreaHovered or FIsDragging then
        ThumbColor := MakeGPColor(FScrollThumbHoverColor, ThumbAlpha)
      else
        ThumbColor := MakeGPColor(FScrollThumbColor, ThumbAlpha);

      ThumbGP := MakeRect(
        FScrollThumbRect.Left + 0.0,
        FScrollThumbRect.Top + 0.0,
        FScrollThumbRect.Width + 0.0,
        FScrollThumbRect.Height + 0.0);

      Path := CreateRoundRectPath(
        ThumbGP.X, ThumbGP.Y, ThumbGP.Width, ThumbGP.Height,
        FScrollThumbRect.Width / 2.0, True);
      try
        Brush := TGPSolidBrush.Create(ThumbColor);
        G.FillPath(Brush, Path);
        Brush.Free;
      finally
        Path.Free;
      end;
    end;

    if FLabel <> '' then
    begin
      FBuffer.Canvas.Font.Height := -Scale(12);
      FBuffer.Canvas.Font.Color := IfThen(FFocused, FAccentColor, FLabelColor);
      SetBkMode(FBuffer.Canvas.Handle, TRANSPARENT);
      FBuffer.Canvas.TextOut(Round(R) + Scale(8), Scale(5), FLabel);
    end;
  finally
    G.Free;
  end;
end;

{ *** Mouse on the scrollbar *** }

procedure TCWSListBox.DoTrackPage;
var
  TotalItems, VisibleItems, MaxScroll, Target: Integer;
begin
  { One page step (a visible page of items) in the stored repeat direction. }
  TotalItems   := FListBox.GetTotalItems;
  VisibleItems := FListBox.GetVisibleItems;
  MaxScroll    := Max(0, TotalItems - VisibleItems);
  Target := FListBox.GetTopIndex + FRepeatDir * Max(1, VisibleItems);
  Target := Max(0, Min(MaxScroll, Target));
  FListBox.SetTopIndex(Target);
  UpdateListBoxPosition;
  Invalidate;
end;

procedure TCWSListBox.StartTrackRepeat(Dir: Integer);
begin
  { First page happens immediately on the click; the timer then keeps paging,
    after a short initial delay, until the thumb catches up with the cursor or
    the button is released (StopTrackRepeat from MouseUp). }
  FRepeatDir := Dir;
  FRepeatActive := True;
  FRepeatStarted := False;
  MouseCapture := True;   { so MouseUp reaches us to stop the repeat }
  DoTrackPage;
  if FRepeatTimer <> nil then
  begin
    FRepeatTimer.Interval := 350;   { initial delay before auto-repeat kicks in }
    FRepeatTimer.Enabled := True;
  end;
end;

procedure TCWSListBox.StopTrackRepeat;
begin
  FRepeatActive := False;
  if FRepeatTimer <> nil then
    FRepeatTimer.Enabled := False;
end;

procedure TCWSListBox.RepeatTimerTick(Sender: TObject);
var
  P: TPoint;
  CursorPast: Boolean;
begin
  if not FRepeatActive or not FScrollVisible then
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
  P := ScreenToClient(Mouse.CursorPos);
  if FRepeatDir < 0 then
    CursorPast := P.Y < FScrollThumbRect.Top
  else
    CursorPast := P.Y > FScrollThumbRect.Bottom;

  if CursorPast then
    DoTrackPage
  else
    StopTrackRepeat;
end;

procedure TCWSListBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
begin
  inherited;
  P := Point(X, Y);
  if (Button = mbLeft) and Enabled then
  begin
    if FScrollVisible and FScrollTrackRect.Contains(P) then
    begin
      { The thumb is narrower than the track and centred in it, so test only the
        scroll axis: anywhere across the track width within the thumb's vertical
        span grabs the thumb (the cursor is already inside the track here). }
      if (P.Y >= FScrollThumbRect.Top) and (P.Y < FScrollThumbRect.Bottom) then
      begin
        FIsDragging       := True;
        FDragStartY       := Y;
        FDragStartTopIndex := FListBox.GetTopIndex;
        MouseCapture      := True;
      end
      else
        { Page toward the click and keep paging while the button is held until
          the thumb reaches the cursor. }
        if P.Y < FScrollThumbRect.Top then
          StartTrackRepeat(-1)
        else
          StartTrackRepeat(1);
    end;
    if not FListBox.Focused then
      FListBox.SetFocus;
    { Focusing the inner list box can release the mouse capture we just grabbed
      for the thumb drag / track auto-repeat. Without capture the matching
      MouseUp is delivered to the list box instead of here, leaving FIsDragging
      (or the repeat) stuck True - and then a later plain mouse-move phantom-
      drags the list to the end. Re-assert the capture so MouseUp comes back. }
    if FIsDragging or FRepeatActive then
      MouseCapture := True;
    ApplyStateChange;
  end;
end;

procedure TCWSListBox.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  DeltaY, DeltaItems, TrackH, ThumbH, MaxScroll, TotalItems, VisibleItems,
  TrackTop, TrackBottom: Integer;
  WasScrollArea: Boolean;
  P: TPoint;
begin
  inherited;
  P := Point(X, Y);
  if FScrollVisible then
  begin
    WasScrollArea      := FScrollAreaHovered;
    FScrollAreaHovered := FScrollTrackRect.Contains(P);

    if FIsDragging then
      FScrollAreaHovered := True;

    if FScrollAreaHovered <> WasScrollArea then
    begin
      UpdateListBoxPosition;
      Invalidate;
    end;
  end;

  if FIsDragging and FScrollVisible then
  begin
    if not (ssLeft in Shift) then
    begin
      { The left button is no longer down, yet we still think we are dragging:
        the MouseUp never reached us (capture was lost). End the drag here so
        this move does not scroll the list from a stale anchor. }
      FIsDragging := False;
      if MouseCapture then
        MouseCapture := False;
    end
    else
    begin
      TotalItems   := FListBox.GetTotalItems;
      VisibleItems := FListBox.GetVisibleItems;
      MaxScroll    := TotalItems - VisibleItems;
      TrackTop     := FScrollTrackRect.Top + Scale(4);
      TrackBottom  := FScrollTrackRect.Bottom - Scale(4);
      TrackH       := TrackBottom - TrackTop;
      ThumbH       := FScrollThumbRect.Height;
      if (TrackH - ThumbH) > 0 then
      begin
        DeltaY     := Y - FDragStartY;
        DeltaItems := Round((DeltaY / (TrackH - ThumbH)) * MaxScroll);
        FListBox.SetTopIndex(Max(0, Min(MaxScroll, FDragStartTopIndex + DeltaItems)));
        UpdateListBoxPosition;
        Invalidate;
      end;
    end;
  end;
end;

procedure TCWSListBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  { End any track-click auto-repeat the moment the button is released. }
  if FRepeatActive then
  begin
    StopTrackRepeat;
    MouseCapture := False;
  end;
  if FIsDragging then
  begin
    FIsDragging        := False;
    MouseCapture       := False;
    FScrollAreaHovered := FScrollTrackRect.Contains(Point(X, Y));
    UpdateListBoxPosition;
  end;
  Invalidate;
end;

function TCWSListBox.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
var
  NewTop, Total, Visible: Integer;
  Handled: Boolean;
begin
  { Give the user's OnMouseWheel first say (mirrors the inner list box path). }
  Handled := False;
  if Assigned(FOnMouseWheel) then
    FOnMouseWheel(Self, Shift, WheelDelta, MousePos, Handled);
  if Handled then
    Exit(True);

  if FListBox.HandleAllocated then
  begin
    Total   := FListBox.GetTotalItems;
    Visible := FListBox.GetVisibleItems;
    NewTop  := FListBox.GetTopIndex;
    if WheelDelta > 0 then
      NewTop := Max(0, NewTop - 3)
    else
      NewTop := Min(Max(0, Total - Visible), NewTop + 3);
    FListBox.SetTopIndex(NewTop);
    UpdateListBoxPosition;
    Invalidate;
  end;
  Result := True;
end;

{ ADDED: Forwarding the drag acceptance from the inner control }
procedure TCWSListBox.DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  inherited DragOver(Source, X, Y, State, Accept);
end;

{ *** Lifecycle *** }

procedure TCWSListBox.Paint;
begin
  PaintToBuffer;
  { Our public Canvas now points at the inner list box's canvas, so blit the
    composed buffer onto this control's OWN canvas (TCustomControl.Canvas). }
  inherited Canvas.Draw(0, 0, FBuffer);
end;

procedure TCWSListBox.Resize;
begin
  inherited;
  UpdateListBoxPosition;
  { UpdateListBoxPosition recomputes the scrollbar geometry (FScrollVisible /
    FScrollThumbRect), but the scrollbar is drawn on THIS control's buffer.
    During an interactive title-bar resize (drag or maximize/restore double
    click) Windows only invalidates the newly exposed area, so the still-visible
    interior keeps the stale scrollbar until something else repaints it — which
    is why it "fixes itself" only after the mouse enters the list. Force a
    repaint here so the scrollbar always follows the new size. Every other place
    that calls UpdateListBoxPosition already pairs it with Invalidate; Resize was
    the one that didn't. }
  Invalidate;
end;

procedure TCWSListBox.Loaded;
begin
  inherited;
  UpdateListBoxPosition;
  SyncListBoxFont;
end;

procedure TCWSListBox.CreateWnd;
begin
  inherited;
  UpdateListBoxPosition;
  SyncListBoxFont;
end;

procedure TCWSListBox.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_CLIPCHILDREN;
end;

procedure TCWSListBox.SetFocus;
begin
  if FListBox.CanFocus then
    FListBox.SetFocus
  else
    inherited;
end;

procedure TCWSListBox.WMSetFocus(var Msg: TWMSetFocus);
begin
  inherited;
  { The wrapper is a focusable TWinControl with its own window, so VCL/Windows
    can hand it the focus directly — clicking the chrome, tab navigation through
    SetActiveControl, or ActiveControl := ListBox — all of which bypass the
    virtual SetFocus above. Forward to the inner list box so the composite always
    behaves as a single focusable control and keystrokes reach the list. }
  if (FListBox <> nil) and FListBox.CanFocus and not (csDestroying in ComponentState) then
    FListBox.SetFocus;
end;

function TCWSListBox.GetListCanvas: TCanvas;
begin
  Result := FListBox.Canvas;
end;

procedure TCWSListBox.BeginDrag(Immediate: Boolean; Threshold: Integer);
begin
  { For dmManual — we delegate to FListBox, since it has the mouse events
    captured. DoStartDrag ensures a correct Source. }
  FListBox.BeginDrag(Immediate, Threshold);
end;

{ *** Font and label *** }

procedure TCWSListBox.SyncListBoxFont;
begin
  FListBox.Font.Assign(Font);
  UpdateListBoxPosition;
end;

procedure TCWSListBox.SetLabel(const Value: string);
begin
  FLabel := Value;
  UpdateListBoxPosition;
  Invalidate;
end;

{ *** Message handlers *** }

procedure TCWSListBox.CMFontChanged(var Msg: TMessage);
begin
  inherited;
  SyncListBoxFont;
end;

procedure TCWSListBox.CMMouseEnter(var Msg: TMessage);
begin
  FHovered := True;
  ApplyStateChange;
end;

procedure TCWSListBox.CMMouseLeave(var Msg: TMessage);
begin
  if not FIsDragging then
  begin
    FHovered           := False;
    FScrollAreaHovered := False;
    UpdateListBoxPosition;
    ApplyStateChange;
  end;
end;

procedure TCWSListBox.CMEnabledChanged(var Msg: TMessage);
begin
  inherited;
  FListBox.Enabled := Enabled;
  ApplyStateChange;
end;

procedure TCWSListBox.CMColorChanged(var Msg: TMessage);
begin
  inherited;
  { Color is the whole-component background — rebuild the buffer and repaint. }
  if FBuffer <> nil then
    FBuffer.SetSize(0, 0);
  Invalidate;
end;

procedure TCWSListBox.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

{ *** GDI+ helpers *** }

function TCWSListBox.MakeGPColor(AColor: TColor; Alpha: Byte): Cardinal;
var
  C: TColor;
begin
  C := ColorToRGB(AColor);
  Result := Winapi.GDIPAPI.MakeColor(Alpha, GetRValue(C), GetGValue(C), GetBValue(C));
end;

function TCWSListBox.CreateRoundRectPath(X, Y, W, H, R: Single; AForceAllCorners: Boolean = False): TGPGraphicsPath;
var
  D: Single;
  TL, TR, BR, BL: Boolean;
begin
  Result := TGPGraphicsPath.Create;
  D := R * 2;
  if D > H then D := H;
  if D > W then D := W;

  { When AForceAllCorners = True (e.g. the scrollbar thumb) we always round
    all four corners, regardless of the component's corner flags. }
  if AForceAllCorners then
  begin
    TL := True; TR := True; BR := True; BL := True;
  end
  else
  begin
    TL := FCornerTopLeft;
    TR := FCornerTopRight;
    BR := FCornerBottomRight;
    BL := FCornerBottomLeft;
  end;

  if (R <= 0) or (not (TL or TR or BR or BL)) then
  begin
    Result.AddRectangle(MakeRect(X, Y, W, H));
    Exit;
  end;

  // Top-Left
  if TL then
    Result.AddArc(X, Y, D, D, 180, 90)
  else
    Result.AddLine(X, Y, X + (D / 2), Y);

  // Top-Right
  if TR then
    Result.AddArc(X + W - D, Y, D, D, 270, 90)
  else
  begin
    Result.AddLine(X + W - (D / 2), Y, X + W, Y);
    Result.AddLine(X + W, Y, X + W, Y + (D / 2));
  end;

  // Bottom-Right
  if BR then
    Result.AddArc(X + W - D, Y + H - D, D, D, 0, 90)
  else
  begin
    Result.AddLine(X + W, Y + H - (D / 2), X + W, Y + H);
    Result.AddLine(X + W, Y + H, X + W - (D / 2), Y + H);
  end;

  // Bottom-Left
  if BL then
    Result.AddArc(X, Y + H - D, D, D, 90, 90)
  else
  begin
    Result.AddLine(X + (D / 2), Y + H, X, Y + H);
    Result.AddLine(X, Y + H, X, Y + H - (D / 2));
  end;

  Result.CloseFigure;
end;

end.
