//////////////////////////////////////////////////////////////////////////
//
//   CWStudio Component Library
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
unit CWSMemo;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  System.SysUtils, System.Classes, System.Types, System.Math,
  Vcl.Controls, Vcl.Graphics, Vcl.StdCtrls, Vcl.Forms, Vcl.ExtCtrls, System.UITypes;

const
  CM_PPICHANGED = $B080 + 13;

type
  TCWSMemo = class;

  { TCWSInternalMemo - Hidden native TMemo inside the component }
  TCWSInternalMemo = class(TMemo)
  private
    FOwner: TCWSMemo;
    procedure NewWindowProc(var Message: TMessage);
  protected
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMNCPaint(var Msg: TMessage); message WM_NCPAINT;
    procedure Change; override;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
    function GetLineHeight: Integer;
    function GetVisibleLines: Integer;
    procedure MouseWheelHandler(var Message: TMessage); override;
  end;

  { TCWSMemo - Main component with Fluent scrollbar }
  TCWSMemo = class(TCustomControl)
  private
    FMemo: TCWSInternalMemo;
    FBuffer: TBitmap;
    FLabel: string;
    FFocused: Boolean;
    FHovered: Boolean;
    FCornerRadius: Single;

    { Colors }
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

    { Scrollbar state }
    FScrollVisible: Boolean;
    FScrollAreaHovered: Boolean;

    { Drag and scroll logic }
    FIsDragging: Boolean;
    FDragStartLine: Integer;
    FDragStartY: Integer;
    FScrollThumbRect: TRect;
    FScrollTrackRect: TRect;

    { Horizontal scrollbar state }
    FScrollBars: TScrollStyle;
    FHScrollVisible: Boolean;
    FHScrollAreaHovered: Boolean;
    FHIsDragging: Boolean;
    FHDragStartX: Integer;
    FHDragStartOffset: Integer;
    FHScrollThumbRect: TRect;
    FHScrollTrackRect: TRect;

    { Track-click auto-repeat (holding the button on the track keeps paging
      toward the cursor until the thumb reaches it — the native scrollbar feel) }
    FRepeatTimer: TTimer;
    FRepeatActive: Boolean;
    FRepeatVert: Boolean;
    FRepeatDir: Integer;
    FRepeatStarted: Boolean;
    FContentWidth: Integer;
    FContentDirty: Boolean;

    { Events }
    FOnChange: TNotifyEvent;
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

    procedure SetLabel(const Value: string);
    procedure SyncMemoFont;
    procedure UpdateMemoPosition;
    procedure UpdateScrollbarMetrics;
    procedure StartTrackRepeat(Vert: Boolean; Dir: Integer);
    procedure StopTrackRepeat;
    procedure DoTrackPage;
    procedure RepeatTimerTick(Sender: TObject);
    procedure EnsureBuffer;
    function GetText: string;
    procedure SetText(const Value: string);
    function GetLines: TStrings;
    procedure SetLines(const Value: TStrings);
    function GetCurrentBgColor: TColor;
    function GetParentBgColor: TColor;
    procedure ApplyStateChange;

    { Property getters/setters }
    function GetMaxLength: Integer;
    procedure SetMaxLength(const Value: Integer);
    function GetReadOnly: Boolean;
    procedure SetReadOnly(const Value: Boolean);
    function GetWordWrap: Boolean;
    procedure SetWordWrap(const Value: Boolean);
    function GetWantReturns: Boolean;
    procedure SetWantReturns(const Value: Boolean);
    function GetWantTabs: Boolean;
    procedure SetWantTabs(const Value: Boolean);

    { New getters/setters }
    function GetSelStart: Integer;
    procedure SetSelStart(const Value: Integer);
    function GetSelLength: Integer;
    procedure SetSelLength(const Value: Integer);
    function GetSelText: string;
    procedure SetSelText(const Value: string);
    function GetModified: Boolean;
    procedure SetModified(const Value: Boolean);
    function GetCanUndo: Boolean;
    function GetAlignment: TAlignment;
    procedure SetAlignment(const Value: TAlignment);
    function GetHideSelection: Boolean;
    procedure SetHideSelection(const Value: Boolean);
    function GetCaretPos: TPoint;
    procedure SetCaretPos(const Value: TPoint);

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
    procedure SetScrollBars(const Value: TScrollStyle);

    procedure RecalcContentWidth;
    function GetContentWidth: Integer;
    function GetMemoHOffset: Integer;
    function GetAvgCharWidth: Integer;
    procedure ScrollMemoToOffset(TargetOffset: Integer);

    function Scale(Value: Integer): Integer;
    function ScaleF(Value: Single): Single;

    function MakeGPColor(AColor: TColor; Alpha: Byte = 255): Cardinal;
    function CreateRoundRectPath(X, Y, W, H, R: Single): TGPGraphicsPath;
    procedure PaintToBuffer;

    { Internal handlers }
    procedure MemoEnter(Sender: TObject);
    procedure MemoExit(Sender: TObject);
    procedure MemoClick(Sender: TObject);
    procedure MemoDblClick(Sender: TObject);
    procedure MemoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MemoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MemoKeyPress(Sender: TObject; var Key: Char);
    procedure MemoMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MemoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MemoMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MemoContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);

    procedure CMFontChanged(var Msg: TMessage); message CM_FONTCHANGED;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;
    procedure CMPPIChanged(var Msg: TMessage); message CM_PPICHANGED;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    { When the scrollbar is visible the inner memo is narrower, so the scrollbar
      strip belongs to this outer window. Forward the wheel to the inner memo so
      hovering the scrollbar still scrolls the text. }
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure ChangeScale(M, D: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetFocus; override;
    property Memo: TCWSInternalMemo read FMemo;

    { Public methods — equivalents of TMemo methods }
    procedure Clear;
    procedure ClearSelection;
    procedure CopyToClipboard;
    procedure CutToClipboard;
    procedure PasteFromClipboard;
    procedure SelectAll;
    procedure Undo;
    procedure ClearUndo;

    { Navigation and text info }
    function GetLineText(LineIndex: Integer): string;
    function GetLineCount: Integer;
    function GetFirstVisibleLine: Integer;
    function LineFromChar(CharIndex: Integer): Integer;
    function LineIndex(LineNum: Integer): Integer;
    function LineLength(LineNum: Integer): Integer;
    procedure ScrollToCaret;
    procedure Append(const S: string);

    { Public properties (runtime-only) }
    property SelStart: Integer read GetSelStart write SetSelStart;
    property SelLength: Integer read GetSelLength write SetSelLength;
    property SelText: string read GetSelText write SetSelText;
    property Modified: Boolean read GetModified write SetModified;
    property CanUndo: Boolean read GetCanUndo;
    property CaretPos: TPoint read GetCaretPos write SetCaretPos;
  published
    property Text: string read GetText write SetText;
    property Lines: TStrings read GetLines write SetLines;
    property LabelText: string read FLabel write SetLabel;
    property MaxLength: Integer read GetMaxLength write SetMaxLength default 0;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property WordWrap: Boolean read GetWordWrap write SetWordWrap default True;
    property WantReturns: Boolean read GetWantReturns write SetWantReturns default True;
    property WantTabs: Boolean read GetWantTabs write SetWantTabs default False;
    property Alignment: TAlignment read GetAlignment write SetAlignment default taLeftJustify;
    property HideSelection: Boolean read GetHideSelection write SetHideSelection default True;
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
    property ScrollBars: TScrollStyle read FScrollBars write SetScrollBars default ssVertical;
    property CornerRadius: Single read FCornerRadius write FCornerRadius;
    property Align;
    property Anchors;
    property Font;
    property ParentFont;
    property Enabled;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
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
  end;

implementation

uses
  Vcl.Clipbrd;

type
  { Cracker that exposes the parent's protected Color property. }
  TControlAccess = class(TControl);

{ TCWSInternalMemo }

constructor TCWSInternalMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOwner := TCWSMemo(AOwner);
  BorderStyle := bsNone;
  ScrollBars := ssNone;
  Self.WindowProc := NewWindowProc;
end;

procedure TCWSInternalMemo.CreateWnd;
begin
  inherited;
  { The native control restores its text here without necessarily firing
    Change, so force a content-width re-measure for the horizontal scrollbar.
    The handle is often created after the owner's first paint, so request a
    repaint as well — important at design time where few events fire. }
  if FOwner <> nil then
  begin
    FOwner.FContentDirty := True;
    FOwner.UpdateScrollbarMetrics;
    FOwner.Invalidate;
  end;
end;

procedure TCWSInternalMemo.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style  := Params.Style or ES_AUTOVSCROLL;
  { WS_EX_COMPOSITED — Windows buffers all painting of the control before
    showing it on screen. Eliminates flicker while typing
    and scrolling (same solution as in TCWSBufferedEdit from CWSEdit). }
  Params.ExStyle := Params.ExStyle or WS_EX_COMPOSITED;
end;

function TCWSInternalMemo.GetLineHeight: Integer;
var
  DC: HDC;
  TM: TTextMetric;
begin
  if not HandleAllocated then
  begin
    Result := Max(1, Abs(Font.Height) + 2);
    Exit;
  end;
  DC := GetDC(Handle);
  try
    SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, TM);
    Result := TM.tmHeight + TM.tmExternalLeading;
  finally
    ReleaseDC(Handle, DC);
  end;
  if Result <= 0 then
    Result := Max(1, Abs(Font.Height) + 2);
end;

function TCWSInternalMemo.GetVisibleLines: Integer;
var
  LH: Integer;
begin
  LH := GetLineHeight;
  if LH > 0 then
    Result := Max(1, ClientHeight div LH)
  else
    Result := 1;
end;

procedure TCWSInternalMemo.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  FOwner.CMMouseEnter(Message);
end;

procedure TCWSInternalMemo.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FOwner.CMMouseLeave(Message);
end;

procedure TCWSInternalMemo.NewWindowProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_VSCROLL, WM_HSCROLL, EM_LINESCROLL, WM_MOUSEWHEEL, WM_KEYDOWN, WM_KEYUP, WM_CHAR, WM_PASTE:
      begin
        inherited WndProc(Message);
        FOwner.UpdateScrollbarMetrics;
        FOwner.Invalidate;
      end;
    WM_NCPAINT:
      Exit;
  else
    inherited WndProc(Message);
  end;
end;

procedure TCWSInternalMemo.Change;
begin
  inherited;
  FOwner.FContentDirty := True;
  FOwner.UpdateScrollbarMetrics;
  FOwner.Invalidate;
  if Assigned(FOwner.FOnChange) then
    FOwner.FOnChange(FOwner);
end;

procedure TCWSInternalMemo.CMTextChanged(var Message: TMessage);
begin
  inherited;
  FOwner.FContentDirty := True;
  FOwner.UpdateScrollbarMetrics;
  FOwner.Invalidate;
end;

procedure TCWSInternalMemo.WMNCPaint(var Msg: TMessage);
begin
  { Suppress default NC frame painting }
end;

procedure TCWSInternalMemo.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  { Suppress background erase — together with WS_EX_COMPOSITED this
    completely eliminates flicker while typing and scrolling }
  Msg.Result := 1;
end;

procedure TCWSInternalMemo.MouseWheelHandler(var Message: TMessage);
begin
  if TWMMouseWheel(Message).WheelDelta > 0 then
    Perform(EM_LINESCROLL, 0, -3)
  else
    Perform(EM_LINESCROLL, 0, 3);
  FOwner.UpdateScrollbarMetrics;
  FOwner.Invalidate;
  { Forward the mouse-wheel event to the owner }
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

{ TCWSMemo }

constructor TCWSMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 300;
  Height := 150;
  DoubleBuffered := True;
  FCornerRadius := 4;
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
  FScrollBars := ssVertical;
  FContentDirty := True;
  FLabelColor := $606060;

  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf32bit;

  FMemo := TCWSInternalMemo.Create(Self);
  FMemo.Parent := Self;
  FMemo.OnEnter        := MemoEnter;
  FMemo.OnExit         := MemoExit;
  FMemo.OnClick        := MemoClick;
  FMemo.OnDblClick     := MemoDblClick;
  FMemo.OnKeyDown      := MemoKeyDown;
  FMemo.OnKeyUp        := MemoKeyUp;
  FMemo.OnKeyPress     := MemoKeyPress;
  FMemo.OnMouseDown    := MemoMouseDown;
  FMemo.OnMouseMove    := MemoMouseMove;
  FMemo.OnMouseUp      := MemoMouseUp;
  FMemo.OnContextPopup := MemoContextPopup;

  FRepeatTimer := TTimer.Create(Self);
  FRepeatTimer.Enabled := False;
  FRepeatTimer.OnTimer := RepeatTimerTick;
end;

destructor TCWSMemo.Destroy;
begin
  if FRepeatTimer <> nil then
    FRepeatTimer.Enabled := False;
  FBuffer.Free;
  inherited;
end;

{ *** Properties *** }

function TCWSMemo.GetMaxLength: Integer;
begin
  Result := FMemo.MaxLength;
end;

procedure TCWSMemo.SetMaxLength(const Value: Integer);
begin
  FMemo.MaxLength := Value;
end;

function TCWSMemo.GetReadOnly: Boolean;
begin
  Result := FMemo.ReadOnly;
end;

procedure TCWSMemo.SetReadOnly(const Value: Boolean);
begin
  FMemo.ReadOnly := Value;
  Invalidate;
end;

function TCWSMemo.GetWordWrap: Boolean;
begin
  Result := FMemo.WordWrap;
end;

procedure TCWSMemo.SetWordWrap(const Value: Boolean);
begin
  FMemo.WordWrap := Value;
  UpdateMemoPosition;
  Invalidate;
end;

function TCWSMemo.GetWantReturns: Boolean;
begin
  Result := FMemo.WantReturns;
end;

procedure TCWSMemo.SetWantReturns(const Value: Boolean);
begin
  FMemo.WantReturns := Value;
end;

function TCWSMemo.GetWantTabs: Boolean;
begin
  Result := FMemo.WantTabs;
end;

procedure TCWSMemo.SetWantTabs(const Value: Boolean);
begin
  FMemo.WantTabs := Value;
end;

{ *** Nowe gettery/settery *** }

function TCWSMemo.GetSelStart: Integer;
begin
  Result := FMemo.SelStart;
end;

procedure TCWSMemo.SetSelStart(const Value: Integer);
begin
  FMemo.SelStart := Value;
end;

function TCWSMemo.GetSelLength: Integer;
begin
  Result := FMemo.SelLength;
end;

procedure TCWSMemo.SetSelLength(const Value: Integer);
begin
  FMemo.SelLength := Value;
end;

function TCWSMemo.GetSelText: string;
begin
  Result := FMemo.SelText;
end;

procedure TCWSMemo.SetSelText(const Value: string);
begin
  FMemo.SelText := Value;
  UpdateScrollbarMetrics;
  Invalidate;
end;

function TCWSMemo.GetModified: Boolean;
begin
  Result := FMemo.Modified;
end;

procedure TCWSMemo.SetModified(const Value: Boolean);
begin
  FMemo.Modified := Value;
end;

function TCWSMemo.GetCanUndo: Boolean;
begin
  Result := FMemo.HandleAllocated and
    (FMemo.Perform(EM_CANUNDO, 0, 0) <> 0);
end;

function TCWSMemo.GetAlignment: TAlignment;
begin
  Result := FMemo.Alignment;
end;

procedure TCWSMemo.SetAlignment(const Value: TAlignment);
begin
  FMemo.Alignment := Value;
  Invalidate;
end;

function TCWSMemo.GetHideSelection: Boolean;
begin
  Result := FMemo.HideSelection;
end;

procedure TCWSMemo.SetHideSelection(const Value: Boolean);
begin
  FMemo.HideSelection := Value;
end;

function TCWSMemo.GetCaretPos: TPoint;
begin
  Result := FMemo.CaretPos;
end;

procedure TCWSMemo.SetCaretPos(const Value: TPoint);
begin
  FMemo.CaretPos := Value;
end;

{ *** Metody publiczne *** }

procedure TCWSMemo.Clear;
begin
  FMemo.Clear;
  UpdateScrollbarMetrics;
  Invalidate;
end;

procedure TCWSMemo.ClearSelection;
begin
  { Replace the selected text with an empty string — same behavior
    as TMemo.ClearSelection }
  if FMemo.SelLength > 0 then
    FMemo.SelText := '';
end;

procedure TCWSMemo.CopyToClipboard;
begin
  FMemo.CopyToClipboard;
end;

procedure TCWSMemo.CutToClipboard;
begin
  FMemo.CutToClipboard;
  UpdateScrollbarMetrics;
  Invalidate;
end;

procedure TCWSMemo.PasteFromClipboard;
begin
  FMemo.PasteFromClipboard;
  UpdateScrollbarMetrics;
  Invalidate;
end;

procedure TCWSMemo.SelectAll;
begin
  FMemo.SelectAll;
end;

procedure TCWSMemo.Undo;
begin
  if FMemo.HandleAllocated then
  begin
    FMemo.Perform(EM_UNDO, 0, 0);
    UpdateScrollbarMetrics;
    Invalidate;
  end;
end;

procedure TCWSMemo.ClearUndo;
begin
  if FMemo.HandleAllocated then
    FMemo.Perform(EM_EMPTYUNDOBUFFER, 0, 0);
end;

{ *** Navigation and text info *** }

function TCWSMemo.GetLineText(LineIndex: Integer): string;
begin
  if (LineIndex >= 0) and (LineIndex < FMemo.Lines.Count) then
    Result := FMemo.Lines[LineIndex]
  else
    Result := '';
end;

function TCWSMemo.GetLineCount: Integer;
begin
  if FMemo.HandleAllocated then
    Result := FMemo.Perform(EM_GETLINECOUNT, 0, 0)
  else
    Result := FMemo.Lines.Count;
end;

function TCWSMemo.GetFirstVisibleLine: Integer;
begin
  if FMemo.HandleAllocated then
    Result := FMemo.Perform(EM_GETFIRSTVISIBLELINE, 0, 0)
  else
    Result := 0;
end;

function TCWSMemo.LineFromChar(CharIndex: Integer): Integer;
begin
  if FMemo.HandleAllocated then
    Result := FMemo.Perform(EM_LINEFROMCHAR, CharIndex, 0)
  else
    Result := 0;
end;

function TCWSMemo.LineIndex(LineNum: Integer): Integer;
begin
  { EM_LINEINDEX returns the character position at the start of the given line;
    -1 means the current cursor line }
  if FMemo.HandleAllocated then
    Result := FMemo.Perform(EM_LINEINDEX, LineNum, 0)
  else
    Result := 0;
end;

function TCWSMemo.LineLength(LineNum: Integer): Integer;
var
  CharIdx: Integer;
begin
  { EM_LINELENGTH takes a character index within the line, not a line number }
  if FMemo.HandleAllocated then
  begin
    CharIdx := LineIndex(LineNum);
    Result := FMemo.Perform(EM_LINELENGTH, CharIdx, 0);
  end
  else
    Result := 0;
end;

procedure TCWSMemo.ScrollToCaret;
begin
  if FMemo.HandleAllocated then
  begin
    FMemo.Perform(EM_SCROLLCARET, 0, 0);
    UpdateScrollbarMetrics;
    Invalidate;
  end;
end;

procedure TCWSMemo.Append(const S: string);
begin
  { Append text at the end without clearing the content }
  FMemo.Lines.Add(S);
  UpdateScrollbarMetrics;
  Invalidate;
end;

{ *** Scaling *** }

function TCWSMemo.Scale(Value: Integer): Integer;
begin
  Result := MulDiv(Value, CurrentPPI, 96);
end;

function TCWSMemo.ScaleF(Value: Single): Single;
begin
  Result := Value * CurrentPPI / 96;
end;

{ *** DPI *** }

procedure TCWSMemo.CMPPIChanged(var Msg: TMessage);
begin
  inherited;
  if FBuffer <> nil then
    FBuffer.SetSize(0, 0);
  SyncMemoFont;
  UpdateMemoPosition;
  Invalidate;
end;

procedure TCWSMemo.ChangeScale(M, D: Integer);
begin
  inherited ChangeScale(M, D);
  if FBuffer <> nil then
    FBuffer.SetSize(0, 0);
  SyncMemoFont;
  UpdateMemoPosition;
end;

{ *** Color setters *** }

procedure TCWSMemo.SetAccentColor(const Value: TColor);
begin
  FAccentColor := Value;
  Invalidate;
end;

procedure TCWSMemo.SetBackgroundColor(const Value: TColor);
begin
  FBackgroundColor := Value;
  ApplyStateChange;
end;

procedure TCWSMemo.SetBackgroundHoverColor(const Value: TColor);
begin
  FBackgroundHoverColor := Value;
  ApplyStateChange;
end;

procedure TCWSMemo.SetBackgroundFocusColor(const Value: TColor);
begin
  FBackgroundFocusColor := Value;
  ApplyStateChange;
end;

procedure TCWSMemo.SetBorderColor(const Value: TColor);
begin
  FBorderColor := Value;
  Invalidate;
end;

procedure TCWSMemo.SetLabelColor(const Value: TColor);
begin
  FLabelColor := Value;
  Invalidate;
end;

procedure TCWSMemo.SetScrollThumbColor(const Value: TColor);
begin
  FScrollThumbColor := Value;
  Invalidate;
end;

procedure TCWSMemo.SetScrollThumbHoverColor(const Value: TColor);
begin
  FScrollThumbHoverColor := Value;
  ApplyStateChange;
end;

procedure TCWSMemo.SetDisabledColor(const Value: TColor);
begin
  FDisabledColor := Value;
  ApplyStateChange;
end;

procedure TCWSMemo.SetDisabledBorderColor(const Value: TColor);
begin
  FDisabledBorderColor := Value;
  Invalidate;
end;

procedure TCWSMemo.SetScrollbarAreaWidth(const Value: Integer);
begin
  if FScrollbarAreaWidth <> Value then
  begin
    FScrollbarAreaWidth := Max(6, Value);
    UpdateMemoPosition;
    Invalidate;
  end;
end;

procedure TCWSMemo.SetScrollbarThumbWidth(const Value: Integer);
begin
  if FScrollbarThumbWidth <> Value then
  begin
    FScrollbarThumbWidth := Max(2, Value);
    UpdateScrollbarMetrics;
    Invalidate;
  end;
end;

procedure TCWSMemo.SetScrollbarThumbHoverWidth(const Value: Integer);
begin
  if FScrollbarThumbHoverWidth <> Value then
  begin
    FScrollbarThumbHoverWidth := Max(2, Value);
    UpdateScrollbarMetrics;
    Invalidate;
  end;
end;

procedure TCWSMemo.SetScrollBars(const Value: TScrollStyle);
begin
  if FScrollBars <> Value then
  begin
    FScrollBars := Value;
    UpdateMemoPosition;
    Invalidate;
  end;
end;

{ *** Horizontal scroll helpers *** }

{ Measure the width (in pixels) of the longest line — i.e. the total
  scrollable content width — and cache it. Only re-run when the text or font
  changes (FContentDirty), so that per-paint metric updates stay cheap. }
procedure TCWSMemo.RecalcContentWidth;
var
  DC: HDC;
  I, W: Integer;
  Sz: TSize;
  S: string;
begin
  { Without a handle we cannot measure reliably — leave the cache dirty so it
    is recomputed once the native memo is realized (and its text restored) }
  if not FMemo.HandleAllocated then
    Exit;
  W := 0;
  DC := GetDC(FMemo.Handle);
  try
    SelectObject(DC, FMemo.Font.Handle);
    for I := 0 to FMemo.Lines.Count - 1 do
    begin
      S := FMemo.Lines[I];
      if S = '' then
        Continue;
      GetTextExtentPoint32(DC, PChar(S), Length(S), Sz);
      if Sz.cx > W then
        W := Sz.cx;
    end;
  finally
    ReleaseDC(FMemo.Handle, DC);
  end;
  { Small padding so the caret at end of the longest line stays visible }
  FContentWidth := W + Scale(4);
  FContentDirty := False;
end;

function TCWSMemo.GetContentWidth: Integer;
begin
  if FContentDirty then
    RecalcContentWidth;
  Result := FContentWidth;
end;

{ Current horizontal scroll offset of the native memo, in pixels.
  Derived from the on-screen position of the first character relative to the
  memo's formatting rectangle — works without a native WS_HSCROLL bar. }
function TCWSMemo.GetMemoHOffset: Integer;
var
  R: TRect;
  Pos, X: Integer;
begin
  Result := 0;
  if not FMemo.HandleAllocated then
    Exit;
  FMemo.Perform(EM_GETRECT, 0, LPARAM(@R));
  Pos := FMemo.Perform(EM_POSFROMCHAR, 0, 0);
  if Pos = -1 then
    Exit;
  { Low word holds the (signed) x coordinate — extend the sign manually,
    a SmallInt() cast would trip range checking for values >= $8000 }
  X := Pos and $FFFF;
  if X >= $8000 then
    Dec(X, $10000);
  Result := Max(0, R.Left - X);
end;

function TCWSMemo.GetAvgCharWidth: Integer;
var
  DC: HDC;
  TM: TTextMetric;
begin
  Result := 8;
  if not FMemo.HandleAllocated then
    Exit;
  DC := GetDC(FMemo.Handle);
  try
    SelectObject(DC, FMemo.Font.Handle);
    GetTextMetrics(DC, TM);
    Result := Max(1, TM.tmAveCharWidth);
  finally
    ReleaseDC(FMemo.Handle, DC);
  end;
end;

{ Scroll the native memo horizontally so its offset approaches TargetOffset
  (pixels). EM_LINESCROLL works in character units, so we translate via the
  average character width — the thumb is then re-read from the real offset. }
procedure TCWSMemo.ScrollMemoToOffset(TargetOffset: Integer);
var
  Delta: Integer;
begin
  if not FMemo.HandleAllocated then
    Exit;
  Delta := Round((TargetOffset - GetMemoHOffset) / GetAvgCharWidth);
  if Delta <> 0 then
    { Horizontal char count goes in wParam (unsigned WPARAM); cast to keep the
      sign bits when scrolling left without tripping range checking }
    FMemo.Perform(EM_LINESCROLL, WPARAM(Delta), 0);
end;

{ *** Track-click auto-repeat *** }

procedure TCWSMemo.DoTrackPage;
var
  VisibleLines, PageW: Integer;
begin
  { One page step in the stored repeat direction. }
  if FRepeatVert then
  begin
    VisibleLines := FMemo.GetVisibleLines;
    FMemo.Perform(EM_LINESCROLL, 0, FRepeatDir * Max(1, VisibleLines));
  end
  else
  begin
    PageW := Max(1, FMemo.ClientWidth);
    ScrollMemoToOffset(GetMemoHOffset + FRepeatDir * PageW);
  end;
  UpdateScrollbarMetrics;
  Invalidate;
end;

procedure TCWSMemo.StartTrackRepeat(Vert: Boolean; Dir: Integer);
begin
  { First page happens immediately on the click; the timer then keeps paging,
    after a short initial delay, until the thumb catches up with the cursor or
    the button is released (StopTrackRepeat from MouseUp). }
  FRepeatVert := Vert;
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

procedure TCWSMemo.StopTrackRepeat;
begin
  FRepeatActive := False;
  if FRepeatTimer <> nil then
    FRepeatTimer.Enabled := False;
end;

procedure TCWSMemo.RepeatTimerTick(Sender: TObject);
var
  P: TPoint;
  CursorPast: Boolean;
begin
  if not FRepeatActive then
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
  if FRepeatVert then
  begin
    if not FScrollVisible then begin StopTrackRepeat; Exit; end;
    if FRepeatDir < 0 then
      CursorPast := P.Y < FScrollThumbRect.Top
    else
      CursorPast := P.Y > FScrollThumbRect.Bottom;
  end
  else
  begin
    if not FHScrollVisible then begin StopTrackRepeat; Exit; end;
    if FRepeatDir < 0 then
      CursorPast := P.X < FHScrollThumbRect.Left
    else
      CursorPast := P.X > FHScrollThumbRect.Right;
  end;

  if CursorPast then
    DoTrackPage
  else
    StopTrackRepeat;
end;

{ *** Handlery focus *** }

procedure TCWSMemo.MemoEnter(Sender: TObject);
begin
  FFocused := True;
  ApplyStateChange;
  if Assigned(FOnEnter) then
    FOnEnter(Self);
end;

procedure TCWSMemo.MemoExit(Sender: TObject);
begin
  FFocused := False;
  ApplyStateChange;
  if Assigned(FOnExit) then
    FOnExit(Self);
end;

{ *** Memo event handlers *** }

procedure TCWSMemo.MemoClick(Sender: TObject);
begin
  if Assigned(FOnClick) then
    FOnClick(Self);
end;

procedure TCWSMemo.MemoDblClick(Sender: TObject);
begin
  if Assigned(FOnDblClick) then
    FOnDblClick(Self);
end;

procedure TCWSMemo.MemoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnKeyDown) then
    FOnKeyDown(Self, Key, Shift);
end;

procedure TCWSMemo.MemoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnKeyUp) then
    FOnKeyUp(Self, Key, Shift);
end;

procedure TCWSMemo.MemoKeyPress(Sender: TObject; var Key: Char);
begin
  if Assigned(FOnKeyPress) then
    FOnKeyPress(Self, Key);
end;

procedure TCWSMemo.MemoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseDown) then
    FOnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TCWSMemo.MemoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseMove) then
    FOnMouseMove(Self, Shift, X, Y);
end;

procedure TCWSMemo.MemoMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseUp) then
    FOnMouseUp(Self, Button, Shift, X, Y);
end;

procedure TCWSMemo.MemoContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  if Assigned(FOnContextPopup) then
    FOnContextPopup(Self, MousePos, Handled);
end;

{ *** Stan i kolory *** }

procedure TCWSMemo.ApplyStateChange;
begin
  if FMemo <> nil then
  begin
    FMemo.Color := GetCurrentBgColor;
    if FMemo.HandleAllocated then
      FMemo.Invalidate;
  end;
  Invalidate;
end;

function TCWSMemo.GetCurrentBgColor: TColor;
begin
  if not Enabled then
    Result := FDisabledColor
  else if FMemo.ReadOnly then
    Result := $F5F5F5
  else if FFocused then
    Result := FBackgroundFocusColor
  else if FHovered then
    Result := FBackgroundHoverColor
  else
    Result := FBackgroundColor;
end;

function TCWSMemo.GetParentBgColor: TColor;
begin
  if Parent <> nil then
    Result := TControlAccess(Parent).Color
  else
    Result := clBtnFace;
end;

{ *** Pozycjonowanie *** }

procedure TCWSMemo.UpdateMemoPosition;
var
  Margin, L, T, LblH, MemoRight, MemoBottom: Integer;
  WantV, WantH: Boolean;
begin
  Margin := Scale(8);
  L := Margin + Round(ScaleF(FCornerRadius) / 2);
  LblH := IfThen(FLabel <> '', Scale(20), 0);
  T := Margin + LblH;

  WantV := FScrollBars in [ssVertical, ssBoth];
  { A horizontal scrollbar is only meaningful when word wrap is off — same
    rule as Vcl.StdCtrls.TMemo }
  WantH := (FScrollBars in [ssHorizontal, ssBoth]) and not GetWordWrap;

  if WantV then
    MemoRight := Width - Scale(FScrollbarAreaWidth)
  else
    MemoRight := Width - L;

  if WantH then
    MemoBottom := Height - Scale(FScrollbarAreaWidth)
  else
    MemoBottom := Height - Margin - Scale(2);

  FMemo.SetBounds(L, T, Max(10, MemoRight - L), Max(10, MemoBottom - T));

  if WantV then
    FScrollTrackRect := Rect(Width - Scale(FScrollbarAreaWidth), T, Width - Scale(2), MemoBottom)
  else
    FScrollTrackRect := Rect(0, 0, 0, 0);

  if WantH then
    FHScrollTrackRect := Rect(L, Height - Scale(FScrollbarAreaWidth), MemoRight, Height - Scale(2))
  else
    FHScrollTrackRect := Rect(0, 0, 0, 0);

  UpdateScrollbarMetrics;
end;

procedure TCWSMemo.UpdateScrollbarMetrics;
var
  TotalLines, VisibleLines, FirstVisible, TrackTop, TrackBottom, TrackH,
  ThumbH, ThumbP, ThumbW, CenterX: Integer;
  ContentW, PageW, CurOffset, MaxOffset, TrackLeft, TrackRight, TrackW,
  HThumbW, HThumbP, HThumbH, CenterY: Integer;
  WantV, WantH: Boolean;
begin
  if not FMemo.HandleAllocated then
    Exit;

  WantV := FScrollBars in [ssVertical, ssBoth];
  WantH := (FScrollBars in [ssHorizontal, ssBoth]) and not GetWordWrap;

  { *** Vertical *** }
  if WantV then
  begin
    TotalLines   := FMemo.Perform(EM_GETLINECOUNT, 0, 0);
    FirstVisible := FMemo.Perform(EM_GETFIRSTVISIBLELINE, 0, 0);
    VisibleLines := FMemo.GetVisibleLines;
    FScrollVisible := TotalLines > VisibleLines;
    if FScrollVisible then
    begin
      TrackTop    := FScrollTrackRect.Top + Scale(4);
      TrackBottom := FScrollTrackRect.Bottom - Scale(4);
      TrackH      := TrackBottom - TrackTop;
      ThumbH      := Max(Scale(20), Round(TrackH * (VisibleLines / TotalLines)));
      if TotalLines > VisibleLines then
        ThumbP := TrackTop + Round((FirstVisible / (TotalLines - VisibleLines)) * (TrackH - ThumbH))
      else
        ThumbP := TrackTop;
      ThumbP := Max(TrackTop, Min(TrackBottom - ThumbH, ThumbP));

      if FScrollAreaHovered or FIsDragging then
        ThumbW := Scale(FScrollbarThumbHoverWidth)
      else
        ThumbW := Scale(FScrollbarThumbWidth);

      CenterX := FScrollTrackRect.Left + (FScrollTrackRect.Width - ThumbW) div 2;
      FScrollThumbRect := Rect(CenterX, ThumbP, CenterX + ThumbW, ThumbP + ThumbH);
    end
    else
      FScrollThumbRect := Rect(0, 0, 0, 0);
  end
  else
  begin
    FScrollVisible := False;
    FScrollThumbRect := Rect(0, 0, 0, 0);
  end;

  { *** Horizontal *** }
  if WantH then
  begin
    ContentW := GetContentWidth;
    PageW    := FMemo.ClientWidth;
    FHScrollVisible := ContentW > PageW;
    if FHScrollVisible then
    begin
      MaxOffset := Max(1, ContentW - PageW);
      CurOffset := Max(0, Min(MaxOffset, GetMemoHOffset));

      TrackLeft  := FHScrollTrackRect.Left + Scale(4);
      TrackRight := FHScrollTrackRect.Right - Scale(4);
      TrackW     := TrackRight - TrackLeft;
      HThumbW    := Max(Scale(20), Round(TrackW * (PageW / ContentW)));
      HThumbP    := TrackLeft + Round((CurOffset / MaxOffset) * (TrackW - HThumbW));
      HThumbP    := Max(TrackLeft, Min(TrackRight - HThumbW, HThumbP));

      if FHScrollAreaHovered or FHIsDragging then
        HThumbH := Scale(FScrollbarThumbHoverWidth)
      else
        HThumbH := Scale(FScrollbarThumbWidth);

      CenterY := FHScrollTrackRect.Top + (FHScrollTrackRect.Height - HThumbH) div 2;
      FHScrollThumbRect := Rect(HThumbP, CenterY, HThumbP + HThumbW, CenterY + HThumbH);
    end
    else
      FHScrollThumbRect := Rect(0, 0, 0, 0);
  end
  else
  begin
    FHScrollVisible := False;
    FHScrollThumbRect := Rect(0, 0, 0, 0);
  end;
end;

{ *** Buffer *** }

procedure TCWSMemo.EnsureBuffer;
begin
  if (FBuffer.Width <> Width) or (FBuffer.Height <> Height) then
    FBuffer.SetSize(Width, Height);
end;

{ *** Malowanie *** }

procedure TCWSMemo.WMPaint(var Msg: TWMPaint);
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

procedure TCWSMemo.PaintToBuffer;
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
begin
  EnsureBuffer;
  { Refresh scrollbar metrics against the realized size/content so the bars
    are correct on the very first paint (handle and layout are final here) }
  UpdateScrollbarMetrics;
  W := Width;
  H := Height;
  R := ScaleF(FCornerRadius);

  FBuffer.Canvas.Brush.Color := GetParentBgColor;
  FBuffer.Canvas.FillRect(Rect(0, 0, Width, Height));

  G := TGPGraphics.Create(FBuffer.Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    G.SetPixelOffsetMode(PixelOffsetModeHalf);

    { Background and border }
    Path := CreateRoundRectPath(0.5, 0.5, W - 1, H - 1, R);
    try
      Brush := TGPSolidBrush.Create(MakeGPColor(GetCurrentBgColor));
      G.FillPath(Brush, Path);
      Brush.Free;

      Pen := TGPPen.Create(MakeGPColor(IfThen(Enabled, FBorderColor, FDisabledBorderColor)));
      G.DrawPath(Pen, Path);
      Pen.Free;
    finally
      Path.Free;
    end;

    { Accent bar on focus (only when editable) }
    if Enabled and FFocused and not FMemo.ReadOnly then
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

    { Scrollbar }
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
        FScrollThumbRect.Width / 2.0);
      try
        Brush := TGPSolidBrush.Create(ThumbColor);
        G.FillPath(Brush, Path);
        Brush.Free;
      finally
        Path.Free;
      end;
    end;

    { Horizontal scrollbar }
    if FHScrollVisible then
    begin
      if FHScrollAreaHovered or FHIsDragging then
        ThumbAlpha := 220
      else
        ThumbAlpha := 140;

      if FHScrollAreaHovered or FHIsDragging then
        ThumbColor := MakeGPColor(FScrollThumbHoverColor, ThumbAlpha)
      else
        ThumbColor := MakeGPColor(FScrollThumbColor, ThumbAlpha);

      ThumbGP := MakeRect(
        FHScrollThumbRect.Left + 0.0,
        FHScrollThumbRect.Top + 0.0,
        FHScrollThumbRect.Width + 0.0,
        FHScrollThumbRect.Height + 0.0);

      Path := CreateRoundRectPath(
        ThumbGP.X, ThumbGP.Y, ThumbGP.Width, ThumbGP.Height,
        FHScrollThumbRect.Height / 2.0);
      try
        Brush := TGPSolidBrush.Create(ThumbColor);
        G.FillPath(Brush, Path);
        Brush.Free;
      finally
        Path.Free;
      end;
    end;

    { Label }
    if FLabel <> '' then
    begin
      FBuffer.Canvas.Font.Height := -Scale(12);
      FBuffer.Canvas.Font.Color  := IfThen(FFocused and not FMemo.ReadOnly, FAccentColor, FLabelColor);
      SetBkMode(FBuffer.Canvas.Handle, TRANSPARENT);
      FBuffer.Canvas.TextOut(Round(R) + Scale(8), Scale(5), FLabel);
    end;
  finally
    G.Free;
  end;
end;

{ *** Mouse on the scrollbar *** }

procedure TCWSMemo.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
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
        FIsDragging    := True;
        FDragStartY    := Y;
        FDragStartLine := FMemo.Perform(EM_GETFIRSTVISIBLELINE, 0, 0);
        MouseCapture   := True;
      end
      else
        { Page toward the click and keep paging while the button is held until
          the thumb reaches the cursor. }
        if P.Y < FScrollThumbRect.Top then
          StartTrackRepeat(True, -1)
        else
          StartTrackRepeat(True, 1);
    end
    else if FHScrollVisible and FHScrollTrackRect.Contains(P) then
    begin
      { Test only the scroll axis — the thumb is thinner than the track and
        centred in it, so anywhere across the track height within the thumb's
        horizontal span grabs it. }
      if (P.X >= FHScrollThumbRect.Left) and (P.X < FHScrollThumbRect.Right) then
      begin
        FHIsDragging      := True;
        FHDragStartX      := X;
        FHDragStartOffset := GetMemoHOffset;
        MouseCapture      := True;
      end
      else
        if P.X < FHScrollThumbRect.Left then
          StartTrackRepeat(False, -1)
        else
          StartTrackRepeat(False, 1);
    end;
    if not FMemo.Focused then
      FMemo.SetFocus;
    ApplyStateChange;
  end;
end;

procedure TCWSMemo.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  DeltaY, DeltaLines, TrackH, ThumbH, MaxScroll, TotalLines, VisibleLines,
  TrackTop, TrackBottom: Integer;
  TrackLeft, TrackRight, TrackW, ThumbW, ContentW, PageW, MaxOffset,
  TargetOffset: Integer;
  WasScrollArea, WasHScrollArea: Boolean;
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
      UpdateScrollbarMetrics;
      Invalidate;
    end;
  end;

  if FHScrollVisible then
  begin
    WasHScrollArea      := FHScrollAreaHovered;
    FHScrollAreaHovered := FHScrollTrackRect.Contains(P);

    if FHIsDragging then
      FHScrollAreaHovered := True;

    if FHScrollAreaHovered <> WasHScrollArea then
    begin
      UpdateScrollbarMetrics;
      Invalidate;
    end;
  end;

  if FIsDragging and FScrollVisible then
  begin
    TotalLines   := FMemo.Perform(EM_GETLINECOUNT, 0, 0);
    VisibleLines := FMemo.GetVisibleLines;
    MaxScroll    := TotalLines - VisibleLines;
    TrackTop     := FScrollTrackRect.Top + Scale(4);
    TrackBottom  := FScrollTrackRect.Bottom - Scale(4);
    TrackH       := TrackBottom - TrackTop;
    ThumbH       := FScrollThumbRect.Height;
    if (TrackH - ThumbH) > 0 then
    begin
      DeltaY     := Y - FDragStartY;
      DeltaLines := Round((DeltaY / (TrackH - ThumbH)) * MaxScroll);
      FMemo.Perform(EM_LINESCROLL, 0,
        (FDragStartLine + DeltaLines) - FMemo.Perform(EM_GETFIRSTVISIBLELINE, 0, 0));
      UpdateScrollbarMetrics;
      Invalidate;
    end;
  end;

  if FHIsDragging and FHScrollVisible then
  begin
    ContentW   := GetContentWidth;
    PageW      := FMemo.ClientWidth;
    MaxOffset  := Max(1, ContentW - PageW);
    TrackLeft  := FHScrollTrackRect.Left + Scale(4);
    TrackRight := FHScrollTrackRect.Right - Scale(4);
    TrackW     := TrackRight - TrackLeft;
    ThumbW     := FHScrollThumbRect.Width;
    if (TrackW - ThumbW) > 0 then
    begin
      TargetOffset := FHDragStartOffset +
        Round(((X - FHDragStartX) / (TrackW - ThumbW)) * MaxOffset);
      TargetOffset := Max(0, Min(MaxOffset, TargetOffset));
      ScrollMemoToOffset(TargetOffset);
      UpdateScrollbarMetrics;
      Invalidate;
    end;
  end;
end;

procedure TCWSMemo.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
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
    UpdateScrollbarMetrics;
  end;
  if FHIsDragging then
  begin
    FHIsDragging        := False;
    MouseCapture        := False;
    FHScrollAreaHovered := FHScrollTrackRect.Contains(Point(X, Y));
    UpdateScrollbarMetrics;
  end;
  Invalidate;
end;

function TCWSMemo.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
var
  Handled: Boolean;
begin
  { Give the user's OnMouseWheel first say (mirrors the inner memo path). }
  Handled := False;
  if Assigned(FOnMouseWheel) then
    FOnMouseWheel(Self, Shift, WheelDelta, MousePos, Handled);
  if Handled then
    Exit(True);

  if FMemo.HandleAllocated then
  begin
    if WheelDelta > 0 then
      FMemo.Perform(EM_LINESCROLL, 0, -3)
    else
      FMemo.Perform(EM_LINESCROLL, 0, 3);
    UpdateScrollbarMetrics;
    Invalidate;
  end;
  Result := True;
end;

{ *** Lifecycle *** }

procedure TCWSMemo.Paint;
begin
  PaintToBuffer;
  Canvas.Draw(0, 0, FBuffer);
end;

procedure TCWSMemo.Resize;
begin
  inherited;
  UpdateMemoPosition;
end;

procedure TCWSMemo.Loaded;
begin
  inherited;
  UpdateMemoPosition;
  SyncMemoFont;
end;

procedure TCWSMemo.CreateWnd;
begin
  inherited;
  UpdateMemoPosition;
  SyncMemoFont;
end;

procedure TCWSMemo.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_CLIPCHILDREN;
end;

procedure TCWSMemo.SetFocus;
begin
  if FMemo.CanFocus then
    FMemo.SetFocus
  else
    inherited;
end;

{ *** Font i label *** }

procedure TCWSMemo.SyncMemoFont;
begin
  FMemo.Font.Assign(Font);
  FContentDirty := True;
  UpdateMemoPosition;
end;

procedure TCWSMemo.SetLabel(const Value: string);
begin
  FLabel := Value;
  UpdateMemoPosition;
  Invalidate;
end;

{ *** Text / Lines *** }

function TCWSMemo.GetText: string;
begin
  Result := FMemo.Text;
end;

procedure TCWSMemo.SetText(const Value: string);
begin
  FMemo.Text := Value;
  UpdateScrollbarMetrics;
  Invalidate;
end;

function TCWSMemo.GetLines: TStrings;
begin
  Result := FMemo.Lines;
end;

procedure TCWSMemo.SetLines(const Value: TStrings);
begin
  FMemo.Lines.Assign(Value);
  UpdateScrollbarMetrics;
  Invalidate;
end;

{ *** Message handlery *** }

procedure TCWSMemo.CMFontChanged(var Msg: TMessage);
begin
  inherited;
  SyncMemoFont;
end;

procedure TCWSMemo.CMMouseEnter(var Msg: TMessage);
begin
  FHovered := True;
  ApplyStateChange;
end;

procedure TCWSMemo.CMMouseLeave(var Msg: TMessage);
begin
  if not (FIsDragging or FHIsDragging) then
  begin
    FHovered            := False;
    FScrollAreaHovered  := False;
    FHScrollAreaHovered := False;
    UpdateScrollbarMetrics;
    ApplyStateChange;
  end;
end;

procedure TCWSMemo.CMEnabledChanged(var Msg: TMessage);
begin
  inherited;
  FMemo.Enabled := Enabled;
  ApplyStateChange;
end;

procedure TCWSMemo.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

{ *** GDI+ helpers *** }

function TCWSMemo.MakeGPColor(AColor: TColor; Alpha: Byte): Cardinal;
var
  C: TColor;
begin
  C := ColorToRGB(AColor);
  Result := Winapi.GDIPAPI.MakeColor(Alpha, GetRValue(C), GetGValue(C), GetBValue(C));
end;

function TCWSMemo.CreateRoundRectPath(X, Y, W, H, R: Single): TGPGraphicsPath;
var
  D: Single;
begin
  Result := TGPGraphicsPath.Create;
  D := R * 2;
  if D > H then D := H;
  if D > W then D := W;
  Result.AddArc(X,         Y,         D, D, 180, 90);
  Result.AddArc(X + W - D, Y,         D, D, 270, 90);
  Result.AddArc(X + W - D, Y + H - D, D, D,   0, 90);
  Result.AddArc(X,         Y + H - D, D, D,  90, 90);
  Result.CloseFigure;
end;

end.
