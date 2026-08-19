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
unit CWSStringGrid;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  System.SysUtils, System.Classes, System.Types, System.Math,
  Vcl.Controls, Vcl.Graphics, Vcl.Grids, Vcl.StdCtrls, Vcl.Forms, Vcl.ExtCtrls,
  System.UITypes;

const
  CM_PPICHANGED_GRID = $B080 + 13;

type
  { Re-export so consumers don't need Vcl.Grids in their uses clause }
  TCWSGridDrawState = Vcl.Grids.TGridDrawState;
  TGridRect         = Vcl.Grids.TGridRect;
  TGridOption       = Vcl.Grids.TGridOption;
  TGridOptions      = Vcl.Grids.TGridOptions;

const
  gdSelected = Vcl.Grids.gdSelected;
  gdFocused  = Vcl.Grids.gdFocused;
  gdFixed    = Vcl.Grids.gdFixed;

type
  TCWSStringGrid = class;

  { Internal native grid — fully owner-drawn, flat (no 3D) }
  TCWSInternalGrid = class(TStringGrid)
  private
    FOwner: TCWSStringGrid;
  protected
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect;
      AState: TGridDrawState); override;
    procedure Paint; override;
    procedure TopLeftChanged; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    function CreateEditor: TInplaceEdit; override;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure Click; override;
    procedure DblClick; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  public
    constructor Create(AOwner: TComponent); override;
    { Pushes the current theme colors onto the live in-cell editor (if any),
      so a cell being edited repaints immediately on a theme change. }
    procedure RefreshEditorColors;
  end;

  TCWSGridDrawCellEvent = procedure(Sender: TObject; ACol, ARow: Integer;
    Rect: TRect; State: TCWSGridDrawState) of object;

  TCWSStringGrid = class(TCustomControl)
  private
    FGrid: TCWSInternalGrid;
    FBuffer: TBitmap;
    FFocused: Boolean;

    { Geometry / appearance }
    FCornerRadius: Single;
    FRoundTopLeft: Boolean;
    FRoundTopRight: Boolean;
    FRoundBottomLeft: Boolean;
    FRoundBottomRight: Boolean;
    FShowBorder: Boolean;

    { Colors }
    FBorderColor: TColor;
    FBackgroundColor: TColor;
    FCellColor: TColor;
    FCellTextColor: TColor;
    FGridLineColor: TColor;
    FGridLineWidth: Integer;
    FFixedColor: TColor;
    FFixedTextColor: TColor;
    FCellHighlightColor: TColor;
    FHighlightTextColor: TColor;
    FAlternatingRowColors: Boolean;
    FOddRowColor: TColor;
    FEvenRowColor: TColor;

    { Scrollbar appearance }
    FScrollThumbColor: TColor;
    FScrollThumbHoverColor: TColor;
    FScrollbarAreaWidth: Integer;
    FScrollbarThumbWidth: Integer;
    FScrollbarThumbHoverWidth: Integer;
    FScrollBars: TScrollStyle;

    { Vertical scrollbar state }
    FVScrollVisible: Boolean;
    FVAreaHovered: Boolean;
    FVDragging: Boolean;
    FVDragStartRow: Integer;
    FVDragStartY: Integer;
    FVDragPos: Integer;       { pending row while a non-thumb-tracking drag is held }
    FVThumbRect: TRect;
    FVTrackRect: TRect;

    { Horizontal scrollbar state }
    FHScrollVisible: Boolean;
    FHAreaHovered: Boolean;
    FHDragging: Boolean;
    FHDragStartCol: Integer;
    FHDragStartX: Integer;
    FHDragPos: Integer;       { pending column while a non-thumb-tracking drag is held }
    FHThumbRect: TRect;
    FHTrackRect: TRect;

    { Track-click auto-repeat (holding the button on the track keeps paging
      toward the cursor until the thumb reaches it — the native scrollbar feel) }
    FRepeatTimer: TTimer;
    FRepeatActive: Boolean;
    FRepeatVert: Boolean;
    FRepeatDir: Integer;
    FRepeatStarted: Boolean;

    { Events }
    FOnClick: TNotifyEvent;
    FOnDblClick: TNotifyEvent;
    FOnSelectCell: TSelectCellEvent;
    FOnDrawCell: TCWSGridDrawCellEvent;
    FOnKeyDown: TKeyEvent;
    FOnKeyUp: TKeyEvent;
    FOnKeyPress: TKeyPressEvent;
    FOnTopLeftChanged: TNotifyEvent;
    FOnMouseWheel: TMouseWheelEvent;

    { Forwarded property access }
    function GetColCount: Integer;
    procedure SetColCount(const Value: Integer);
    function GetRowCount: Integer;
    procedure SetRowCount(const Value: Integer);
    function GetFixedCols: Integer;
    procedure SetFixedCols(const Value: Integer);
    function GetFixedRows: Integer;
    procedure SetFixedRows(const Value: Integer);
    function GetDefaultColWidth: Integer;
    procedure SetDefaultColWidth(const Value: Integer);
    function GetDefaultRowHeight: Integer;
    procedure SetDefaultRowHeight(const Value: Integer);
    procedure SetGridLineWidth(const Value: Integer);
    function GetOptions: TGridOptions;
    procedure SetOptions(const Value: TGridOptions);
    function GetCol: Integer;
    procedure SetCol(const Value: Integer);
    function GetRow: Integer;
    procedure SetRow(const Value: Integer);
    function GetCells(ACol, ARow: Integer): string;
    procedure SetCells(ACol, ARow: Integer; const Value: string);
    function GetObjects(ACol, ARow: Integer): TObject;
    procedure SetObjects(ACol, ARow: Integer; const Value: TObject);
    function GetColWidths(Index: Integer): Integer;
    procedure SetColWidths(Index: Integer; const Value: Integer);
    function GetRowHeights(Index: Integer): Integer;
    procedure SetRowHeights(Index: Integer; const Value: Integer);
    function GetSelection: TGridRect;
    procedure SetSelection(const Value: TGridRect);
    function GetColsRows(Index: Integer): TStrings;
    function GetColRow(Index: Integer): TStrings;
    function GetCellCanvas: TCanvas;

    { Color setters }
    procedure SetBorderColor(const Value: TColor);
    procedure SetBackgroundColor(const Value: TColor);
    procedure SetCellColor(const Value: TColor);
    procedure SetCellTextColor(const Value: TColor);
    procedure SetGridLineColor(const Value: TColor);
    procedure SetFixedColor(const Value: TColor);
    procedure SetFixedTextColor(const Value: TColor);
    procedure SetCellHighlightColor(const Value: TColor);
    procedure SetHighlightTextColor(const Value: TColor);
    procedure SetAlternatingRowColors(const Value: Boolean);
    procedure SetOddRowColor(const Value: TColor);
    procedure SetEvenRowColor(const Value: TColor);
    function RowBackColor(ARow: Integer): TColor;
    function AlternateShade(ABase: TColor): TColor;

    procedure SetCornerRadius(const Value: Single);
    procedure ReadCornerRadius(Reader: TReader);
    procedure WriteCornerRadius(Writer: TWriter);
    procedure SetShowBorder(const Value: Boolean);
    procedure SetRoundTopLeft(const Value: Boolean);
    procedure SetRoundTopRight(const Value: Boolean);
    procedure SetRoundBottomLeft(const Value: Boolean);
    procedure SetRoundBottomRight(const Value: Boolean);

    procedure SetScrollThumbColor(const Value: TColor);
    procedure SetScrollThumbHoverColor(const Value: TColor);
    procedure SetScrollbarAreaWidth(const Value: Integer);
    procedure SetScrollbarThumbWidth(const Value: Integer);
    procedure SetScrollbarThumbHoverWidth(const Value: Integer);
    procedure SetScrollBars(const Value: TScrollStyle);

    { Geometry / scrolling }
    function Scale(Value: Integer): Integer;
    function ScaleF(Value: Single): Single;
    function GridInset: Integer;
    procedure UpdateGridPosition;
    procedure UpdateGridRegion;
    procedure UpdateScrollbarMetrics;
    procedure GetVMetrics(out Total, Visible, First: Integer);
    procedure GetHMetrics(out Total, Visible, First: Integer);
    function SumColWidths: Integer;
    function SumRowHeights: Integer;
    procedure ScrollVTo(FirstRow: Integer);
    procedure ScrollHTo(FirstCol: Integer);
    procedure StartTrackRepeat(Vert: Boolean; Dir: Integer);
    procedure StopTrackRepeat;
    procedure DoTrackPage;
    procedure RepeatTimerTick(Sender: TObject);
    procedure SyncGridFont;
    procedure ApplyColors;
    procedure EnsureBuffer;

    function GetParentBgColor: TColor;
    procedure DrawParentBackground(DC: HDC; ARadius: Single);
    function MakeGPColor(AColor: TColor; Alpha: Byte = 255): Cardinal;
    function CreateBorderPath(X, Y, W, H, R: Single; TL, TR, BR, BL: Boolean): TGPGraphicsPath;
    function CreateRoundRectPath(X, Y, W, H, R: Single): TGPGraphicsPath;
    procedure PaintToBuffer;

    { Grid event handlers }
    procedure GridSelectCell(Sender: TObject; ACol, ARow: Longint; var CanSelect: Boolean);
    procedure GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridKeyPress(Sender: TObject; var Key: Char);

    procedure CMFontChanged(var Msg: TMessage); message CM_FONTCHANGED;
    procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure CMPPIChanged(var Msg: TMessage); message CM_PPICHANGED_GRID;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
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
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;

    { Hooks called from the internal grid }
    procedure GridScrolled;
    procedure GridPaintCell(ACol, ARow: Integer; ARect: TRect; AState: TGridDrawState);
    procedure DrawGridLine(C: TCanvas; const R: TRect);
    procedure GridClicked;
    procedure GridDblClicked;
    procedure UpdateFocusState;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetFocus; override;

    property Grid: TCWSInternalGrid read FGrid;
    { Drawing surface used by the OnDrawCell event — maps to the inner grid's
      canvas, so handlers can paint with CWSStringGrid.Canvas directly (no need
      for CWSStringGrid.Grid.Canvas). CellCanvas is a back-compat alias. }
    property Canvas: TCanvas read GetCellCanvas;
    property CellCanvas: TCanvas read GetCellCanvas;

    property Cells[ACol, ARow: Integer]: string read GetCells write SetCells;
    property Objects[ACol, ARow: Integer]: TObject read GetObjects write SetObjects;
    property Cols[Index: Integer]: TStrings read GetColsRows;
    property Rows[Index: Integer]: TStrings read GetColRow;
    property ColWidths[Index: Integer]: Integer read GetColWidths write SetColWidths;
    property RowHeights[Index: Integer]: Integer read GetRowHeights write SetRowHeights;
    property Col: Integer read GetCol write SetCol;
    property Row: Integer read GetRow write SetRow;
    property Selection: TGridRect read GetSelection write SetSelection;
  published
    { Grid structure }
    property ColCount: Integer read GetColCount write SetColCount default 5;
    property RowCount: Integer read GetRowCount write SetRowCount default 5;
    property FixedCols: Integer read GetFixedCols write SetFixedCols default 1;
    property FixedRows: Integer read GetFixedRows write SetFixedRows default 1;
    property DefaultColWidth: Integer read GetDefaultColWidth write SetDefaultColWidth default 64;
    property DefaultRowHeight: Integer read GetDefaultRowHeight write SetDefaultRowHeight default 24;
    property Options: TGridOptions read GetOptions write SetOptions;

    { Colors }
    property BorderColor: TColor read FBorderColor write SetBorderColor default $D6D6D6;
    property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor default clWhite;
    property CellColor: TColor read FCellColor write SetCellColor default clWhite;
    property CellTextColor: TColor read FCellTextColor write SetCellTextColor default $202020;
    property GridLineColor: TColor read FGridLineColor write SetGridLineColor default $E0E0E0;
    property GridLineWidth: Integer read FGridLineWidth write SetGridLineWidth default 1;
    property FixedColor: TColor read FFixedColor write SetFixedColor default $F3F3F3;
    property FixedTextColor: TColor read FFixedTextColor write SetFixedTextColor default $202020;
    property CellHighlightColor: TColor read FCellHighlightColor write SetCellHighlightColor default $F0D9BE;
    property HighlightTextColor: TColor read FHighlightTextColor write SetHighlightTextColor default $202020;

    { Zebra striping. Off by default — every data cell then uses CellColor.
      Data rows are numbered from 1 (the first row below the fixed rows is the
      odd one), so it is the odd row that starts the pattern. The fixed
      rows/columns and the highlighted (current) cell keep their own colors.

      Both colors default to clNone = "derive me from CellColor": odd rows take
      CellColor itself and even rows a slightly shaded variant of it (darker on
      a light theme, lighter on a dark one). Left that way the striping follows
      a CWSFluentColors theme switch on its own — the application only has to
      re-assign CellColor, exactly as it already does. Assign an explicit color
      to pin one (or both) bands to a fixed value instead. }
    property AlternatingRowColors: Boolean read FAlternatingRowColors write SetAlternatingRowColors default False;
    property OddRowColor: TColor read FOddRowColor write SetOddRowColor default clNone;
    property EvenRowColor: TColor read FEvenRowColor write SetEvenRowColor default clNone;

    { Border }
    property ShowBorder: Boolean read FShowBorder write SetShowBorder default True;

    { Rounded corners.
      stored False + DefineProperty('CornerRadiusF'): a Single property whose
      value is 0 is skipped by the standard DFM streamer (0 = implicit float
      default), which would make a design-time CornerRadius := 0 silently revert
      to the constructor default at run time. The manual entry always streams it. }
    property CornerRadius: Single read FCornerRadius write SetCornerRadius stored False;
    property RoundTopLeft: Boolean read FRoundTopLeft write SetRoundTopLeft default True;
    property RoundTopRight: Boolean read FRoundTopRight write SetRoundTopRight default True;
    property RoundBottomLeft: Boolean read FRoundBottomLeft write SetRoundBottomLeft default True;
    property RoundBottomRight: Boolean read FRoundBottomRight write SetRoundBottomRight default True;

    { Scrollbars }
    property ScrollBars: TScrollStyle read FScrollBars write SetScrollBars default ssBoth;
    property ScrollThumbColor: TColor read FScrollThumbColor write SetScrollThumbColor default $C0C0C0;
    property ScrollThumbHoverColor: TColor read FScrollThumbHoverColor write SetScrollThumbHoverColor default $909090;
    property ScrollbarAreaWidth: Integer read FScrollbarAreaWidth write SetScrollbarAreaWidth default 14;
    property ScrollbarThumbWidth: Integer read FScrollbarThumbWidth write SetScrollbarThumbWidth default 4;
    property ScrollbarThumbHoverWidth: Integer read FScrollbarThumbHoverWidth write SetScrollbarThumbHoverWidth default 6;

    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property PopupMenu;
    property TabOrder;
    property TabStop default True;
    property Visible;

    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnSelectCell: TSelectCellEvent read FOnSelectCell write FOnSelectCell;
    property OnDrawCell: TCWSGridDrawCellEvent read FOnDrawCell write FOnDrawCell;
    property OnKeyDown: TKeyEvent read FOnKeyDown write FOnKeyDown;
    property OnKeyUp: TKeyEvent read FOnKeyUp write FOnKeyUp;
    property OnKeyPress: TKeyPressEvent read FOnKeyPress write FOnKeyPress;
    property OnTopLeftChanged: TNotifyEvent read FOnTopLeftChanged write FOnTopLeftChanged;
    property OnMouseWheel: TMouseWheelEvent read FOnMouseWheel write FOnMouseWheel;
  end;

implementation

type
  { Cracker that exposes the parent's protected Color property. }
  TControlAccess = class(TControl);

  { In-cell editor that mirrors the theme background/text colors. The stock
    TInplaceEdit keeps the color it had when first shown, so a cell being
    edited would keep the old light/dark color after a theme switch until the
    next mouse-over. Pulling the colors on show + on demand fixes that. }
  TCWSGridInplaceEdit = class(TInplaceEdit)
  protected
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
    procedure WMWindowPosChanging(var Message: TWMWindowPosChanging);
      message WM_WINDOWPOSCHANGING;
  public
    procedure RefreshColors;
  end;

{ TCWSGridInplaceEdit }

procedure TCWSGridInplaceEdit.RefreshColors;
var
  Host: TCWSStringGrid;
begin
  if not (Grid is TCWSInternalGrid) then
    Exit;
  Host := TCWSInternalGrid(Grid).FOwner;
  if Host = nil then
    Exit;
  Color := Host.FCellColor;
  Font.Color := Host.FCellTextColor;
  if HandleAllocated then
    Invalidate;
end;

procedure TCWSGridInplaceEdit.CMShowingChanged(var Message: TMessage);
begin
  inherited;
  if Showing then
    RefreshColors;
end;

procedure TCWSGridInplaceEdit.WMWindowPosChanging(var Message: TWMWindowPosChanging);
var
  Host: TCWSStringGrid;
  LineW: Integer;
begin
  { Vcl.Grids places the editor on the *whole* cell rect (CellRect(Col, Row)),
    which includes the strip the owner paints its grid line into — so the cell's
    bottom and right line disappear under the editor while the cell is being
    edited. Trim the requested size by the line width so the editor stops at the
    line instead of covering it. Done here rather than in a Move/UpdateLoc
    override because those are not virtual, and this catches every path that
    positions the editor. }
  if ((Message.WindowPos^.flags and SWP_NOSIZE) = 0) and
     (Grid is TCWSInternalGrid) then
  begin
    Host := TCWSInternalGrid(Grid).FOwner;
    if Host <> nil then
    begin
      LineW := Max(0, Host.Scale(Host.FGridLineWidth));
      if LineW > 0 then
      begin
        { A zero size means the grid is hiding the editor (TInplaceEdit.Hide
          resizes to 0x0) — leave those alone. }
        if Message.WindowPos^.cx > LineW then
          Dec(Message.WindowPos^.cx, LineW);
        if Message.WindowPos^.cy > LineW then
          Dec(Message.WindowPos^.cy, LineW);
      end;
    end;
  end;
  inherited;
end;

{ TCWSInternalGrid }

function TCWSInternalGrid.CreateEditor: TInplaceEdit;
begin
  Result := TCWSGridInplaceEdit.Create(Self);
end;

procedure TCWSInternalGrid.RefreshEditorColors;
begin
  if InplaceEditor is TCWSGridInplaceEdit then
    TCWSGridInplaceEdit(InplaceEditor).RefreshColors;
end;

constructor TCWSInternalGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOwner := TCWSStringGrid(AOwner);
  BorderStyle := bsNone;
  ScrollBars := ssNone;
  DefaultDrawing := False;   // we paint every cell ourselves (flat, no 3D)
  DoubleBuffered := True;
  { Keep Ctl3D permanently off. Without ParentCtl3D := False, assigning the
    grid's Parent re-syncs Ctl3D from the (3D) parent control, which would
    re-arm the classic raised bevel on fixed cells (Vcl.Grids: DrawCells). }
  ParentCtl3D := False;
  Ctl3D := False;
  DrawingStyle := gdsClassic;
  { Suppress the native (hardcoded silver/gray) grid lines — the owner draws
    its own lines in GridLineColor, so fixed cells stay perfectly flat. }
  GridLineWidth := 0;
end;

procedure TCWSInternalGrid.CreateParams(var Params: TCreateParams);
begin
  inherited;
  { No native scrollbars and no client edge — the owner draws the frame }
  Params.Style := Params.Style and not (WS_HSCROLL or WS_VSCROLL or WS_BORDER);
  Params.ExStyle := Params.ExStyle and not WS_EX_CLIENTEDGE;
end;

procedure TCWSInternalGrid.CreateWnd;
begin
  inherited;
  { Apply the rounded corner clip as soon as the window handle exists }
  if FOwner <> nil then
    FOwner.UpdateGridRegion;
end;

procedure TCWSInternalGrid.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

procedure TCWSInternalGrid.DrawCell(ACol, ARow: Longint; ARect: TRect;
  AState: TGridDrawState);
begin
  if FOwner <> nil then
    FOwner.GridPaintCell(ACol, ARow, ARect, AState);
end;

procedure TCWSInternalGrid.Paint;
var
  R: TRect;
begin
  inherited;
  if FOwner = nil then
    Exit;

  { Vcl.Grids deliberately skips DrawCell for the cell that is being edited —
    the in-place editor covers it and the grid window has no WS_CLIPCHILDREN, so
    painting there would smear over the editor. Side effect: GridPaintCell never
    runs for that cell, and the row/column separators break at it. Draw just the
    two line strips here; they sit outside the editor (WMWindowPosChanging on
    TCWSGridInplaceEdit keeps it a line-width short), so this never touches the
    editor window. }
  if EditorMode and (InplaceEditor <> nil) and InplaceEditor.Visible then
  begin
    R := CellRect(Col, Row);
    if not IsRectEmpty(R) then
      FOwner.DrawGridLine(Canvas, R);
  end;
end;

procedure TCWSInternalGrid.TopLeftChanged;
begin
  inherited;
  if FOwner <> nil then
    FOwner.GridScrolled;
end;

procedure TCWSInternalGrid.Click;
begin
  inherited;
  if FOwner <> nil then
    FOwner.GridClicked;
end;

procedure TCWSInternalGrid.DblClick;
begin
  inherited;
  if FOwner <> nil then
    FOwner.GridDblClicked;
end;

procedure TCWSInternalGrid.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if FOwner <> nil then
    FOwner.UpdateFocusState;
end;

procedure TCWSInternalGrid.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if FOwner <> nil then
    FOwner.UpdateScrollbarMetrics;
end;

procedure TCWSInternalGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
end;

function TCWSInternalGrid.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);
  if FOwner <> nil then
  begin
    FOwner.UpdateScrollbarMetrics;
    FOwner.Invalidate;
    if Assigned(FOwner.FOnMouseWheel) then
    begin
      var Handled := False;
      FOwner.FOnMouseWheel(FOwner, Shift, WheelDelta, MousePos, Handled);
    end;
  end;
end;

procedure TCWSInternalGrid.CMMouseEnter(var Message: TMessage);
begin
  inherited;
end;

procedure TCWSInternalGrid.CMMouseLeave(var Message: TMessage);
begin
  inherited;
end;

{ TCWSStringGrid }

constructor TCWSStringGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csCaptureMouse, csClickEvents,
    csDoubleClicks, csOpaque];
  Width := 320;
  Height := 200;
  TabStop := True;
  DoubleBuffered := True;

  FCornerRadius := 6;
  FRoundTopLeft := True;
  FRoundTopRight := True;
  FRoundBottomLeft := True;
  FRoundBottomRight := True;
  FShowBorder := True;

  FBorderColor := $D6D6D6;
  FBackgroundColor := clWhite;
  FCellColor := clWhite;
  FCellTextColor := $202020;
  FGridLineColor := $E0E0E0;
  FGridLineWidth := 1;
  FFixedColor := $F3F3F3;
  FFixedTextColor := $202020;
  FCellHighlightColor := $F0D9BE;
  FHighlightTextColor := $202020;
  FAlternatingRowColors := False;
  FOddRowColor := clNone;
  FEvenRowColor := clNone;

  FScrollThumbColor := $C0C0C0;
  FScrollThumbHoverColor := $909090;
  FScrollbarAreaWidth := 14;
  FScrollbarThumbWidth := 4;
  FScrollbarThumbHoverWidth := 6;
  FScrollBars := ssBoth;

  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf32bit;

  FGrid := TCWSInternalGrid.Create(Self);
  FGrid.Parent := Self;
  FGrid.OnSelectCell := GridSelectCell;
  FGrid.OnKeyDown := GridKeyDown;
  FGrid.OnKeyUp := GridKeyUp;
  FGrid.OnKeyPress := GridKeyPress;

  FRepeatTimer := TTimer.Create(Self);
  FRepeatTimer.Enabled := False;
  FRepeatTimer.OnTimer := RepeatTimerTick;

  ApplyColors;
end;

destructor TCWSStringGrid.Destroy;
begin
  if FRepeatTimer <> nil then
    FRepeatTimer.Enabled := False;
  FBuffer.Free;
  inherited;
end;

{ *** Scaling *** }

function TCWSStringGrid.Scale(Value: Integer): Integer;
begin
  Result := MulDiv(Value, CurrentPPI, 96);
end;

function TCWSStringGrid.ScaleF(Value: Single): Single;
begin
  Result := Value * CurrentPPI / 96;
end;

function TCWSStringGrid.GridInset: Integer;
begin
  { Tight inset — the grid hugs the rounded border and its corners are clipped
    to the rounding by the window region, so no inner frame is visible. }
  Result := Scale(2);
end;

{ *** Color application *** }

procedure TCWSStringGrid.ApplyColors;
begin
  if FGrid = nil then
    Exit;
  { Color fills only the area beyond the last row/column (everything else is
    painted cell-by-cell), so it acts as the configurable grid background. }
  FGrid.Color := FBackgroundColor;
  { Keep a cell currently being edited in sync with the new theme colors. }
  FGrid.RefreshEditorColors;
  FGrid.Invalidate;
  Invalidate;
end;

{ *** Owner cell drawing (flat, no 3D) *** }

function TCWSStringGrid.AlternateShade(ABase: TColor): TColor;
var
  C: Longint;
  R, G, B, Delta: Integer;
begin
  { The automatic even-row color: the cell color nudged towards the opposite end
    of the scale, so the band stays visible whatever the theme — a light cell is
    darkened, a dark one lightened. Derived on every paint, which is what makes
    the striping follow a theme switch by itself. }
  C := ColorToRGB(ABase);
  R := GetRValue(C);
  G := GetGValue(C);
  B := GetBValue(C);
  if R + G + B > 384 then      { 3 * 128 — a light background }
    Delta := -10
  else
    Delta := 16;
  Result := TColor(RGB(EnsureRange(R + Delta, 0, 255),
                       EnsureRange(G + Delta, 0, 255),
                       EnsureRange(B + Delta, 0, 255)));
end;

function TCWSStringGrid.RowBackColor(ARow: Integer): TColor;
begin
  { Background of a data row: plain CellColor unless zebra striping is on, in
    which case the row number decides. Data rows are counted from 1 (the first
    row below the fixed ones), so it is the odd row that starts the pattern.
    clNone on either band means "follow CellColor" — see the property comment. }
  if not FAlternatingRowColors then
    Exit(FCellColor);
  if Odd(ARow - FGrid.FixedRows + 1) then
  begin
    Result := FOddRowColor;
    if Result = clNone then
      Result := FCellColor;
  end
  else
  begin
    Result := FEvenRowColor;
    if Result = clNone then
      Result := AlternateShade(FCellColor);
  end;
end;

procedure TCWSStringGrid.GridPaintCell(ACol, ARow: Integer; ARect: TRect;
  AState: TGridDrawState);
var
  Bg, Tx: TColor;
  S: string;
  R: TRect;
  IsFixed, IsCurrent: Boolean;
begin
  IsFixed := gdFixed in AState;
  IsCurrent := (not IsFixed) and (ACol = FGrid.Col) and (ARow = FGrid.Row);

  if IsFixed then
  begin
    Bg := FFixedColor;
    Tx := FFixedTextColor;
  end
  else if IsCurrent or (gdSelected in AState) then
  begin
    Bg := FCellHighlightColor;
    Tx := FHighlightTextColor;
  end
  else
  begin
    Bg := RowBackColor(ARow);
    Tx := FCellTextColor;
  end;

  if Assigned(FOnDrawCell) then
  begin
    { User-supplied drawing replaces default cell content }
    FOnDrawCell(Self, ACol, ARow, ARect, AState);
  end
  else
  begin
    { Default: flat fill + text }
    FGrid.Canvas.Brush.Style := bsSolid;
    FGrid.Canvas.Brush.Color := Bg;
    FGrid.Canvas.FillRect(ARect);

    S := FGrid.Cells[ACol, ARow];
    if S <> '' then
    begin
      FGrid.Canvas.Font := Font;
      FGrid.Canvas.Font.Color := Tx;
      SetBkMode(FGrid.Canvas.Handle, TRANSPARENT);
      R := ARect;
      Inc(R.Left, Scale(4));
      Dec(R.Right, Scale(2));
      DrawText(FGrid.Canvas.Handle, PChar(S), -1, R,
        DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX or DT_END_ELLIPSIS);
    end;
  end;

  { Grid lines always on top — drawn after both default and custom painting }
  DrawGridLine(FGrid.Canvas, ARect);
end;

procedure TCWSStringGrid.DrawGridLine(C: TCanvas; const R: TRect);
var
  LineW: Integer;
begin
  LineW := Max(0, Scale(FGridLineWidth));
  if LineW <= 0 then
    Exit;
  C.Brush.Style := bsSolid;
  C.Brush.Color := FGridLineColor;
  C.FillRect(Rect(R.Right - LineW, R.Top, R.Right, R.Bottom));
  C.FillRect(Rect(R.Left, R.Bottom - LineW, R.Right, R.Bottom));
end;

{ *** Scroll metrics helpers *** }

procedure TCWSStringGrid.GetVMetrics(out Total, Visible, First: Integer);
begin
  Total := FGrid.RowCount - FGrid.FixedRows;
  Visible := FGrid.VisibleRowCount;
  First := FGrid.TopRow - FGrid.FixedRows;
  if First < 0 then First := 0;
  if Total < 0 then Total := 0;
  if Visible < 1 then Visible := 1;
end;

procedure TCWSStringGrid.GetHMetrics(out Total, Visible, First: Integer);
begin
  Total := FGrid.ColCount - FGrid.FixedCols;
  Visible := FGrid.VisibleColCount;
  First := FGrid.LeftCol - FGrid.FixedCols;
  if First < 0 then First := 0;
  if Total < 0 then Total := 0;
  if Visible < 1 then Visible := 1;
end;

function TCWSStringGrid.SumColWidths: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FGrid.ColCount - 1 do
    Inc(Result, FGrid.ColWidths[I]);
end;

function TCWSStringGrid.SumRowHeights: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FGrid.RowCount - 1 do
    Inc(Result, FGrid.RowHeights[I]);
end;

procedure TCWSStringGrid.ScrollVTo(FirstRow: Integer);
var
  Total, Visible, Dummy: Integer;
begin
  GetVMetrics(Total, Visible, Dummy);
  FirstRow := Max(0, Min(Max(0, Total - Visible), FirstRow));
  FGrid.TopRow := FGrid.FixedRows + FirstRow;
end;

procedure TCWSStringGrid.ScrollHTo(FirstCol: Integer);
var
  Total, Visible, Dummy: Integer;
begin
  GetHMetrics(Total, Visible, Dummy);
  FirstCol := Max(0, Min(Max(0, Total - Visible), FirstCol));
  FGrid.LeftCol := FGrid.FixedCols + FirstCol;
end;

{ *** Track-click auto-repeat *** }

procedure TCWSStringGrid.DoTrackPage;
var
  Total, Visible, First: Integer;
begin
  { One page step in the stored repeat direction. }
  if FRepeatVert then
  begin
    GetVMetrics(Total, Visible, First);
    ScrollVTo(First + FRepeatDir * Max(1, Visible));
  end
  else
  begin
    GetHMetrics(Total, Visible, First);
    ScrollHTo(First + FRepeatDir * Max(1, Visible));
  end;
end;

procedure TCWSStringGrid.StartTrackRepeat(Vert: Boolean; Dir: Integer);
begin
  { First page happens immediately on the click; the timer then keeps paging,
    after a short initial delay, until the thumb catches up with the cursor or
    the button is released (StopTrackRepeat from MouseUp). }
  FRepeatVert := Vert;
  FRepeatDir := Dir;
  FRepeatActive := True;
  FRepeatStarted := False;
  DoTrackPage;
  if FRepeatTimer <> nil then
  begin
    FRepeatTimer.Interval := 350;   { initial delay before auto-repeat kicks in }
    FRepeatTimer.Enabled := True;
  end;
end;

procedure TCWSStringGrid.StopTrackRepeat;
begin
  FRepeatActive := False;
  if FRepeatTimer <> nil then
    FRepeatTimer.Enabled := False;
end;

procedure TCWSStringGrid.RepeatTimerTick(Sender: TObject);
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

  { Keep paging only while the cursor is still beyond the thumb in the direction
    we started in (direction is locked, so the thumb never oscillates around the
    cursor); stop as soon as the thumb has reached or passed it. }
  P := ScreenToClient(Mouse.CursorPos);
  if FRepeatVert then
  begin
    if not FVScrollVisible then begin StopTrackRepeat; Exit; end;
    if FRepeatDir < 0 then
      CursorPast := P.Y < FVThumbRect.Top
    else
      CursorPast := P.Y > FVThumbRect.Bottom;
  end
  else
  begin
    if not FHScrollVisible then begin StopTrackRepeat; Exit; end;
    if FRepeatDir < 0 then
      CursorPast := P.X < FHThumbRect.Left
    else
      CursorPast := P.X > FHThumbRect.Right;
  end;

  if CursorPast then
    DoTrackPage
  else
    StopTrackRepeat;
end;

{ *** Layout *** }

procedure TCWSStringGrid.UpdateGridPosition;
var
  Inset, L, T, SBW, AvailW, AvailH, ContentW, ContentH, GridRight, GridBottom: Integer;
  WantV, WantH, NeedV, NeedH: Boolean;
begin
  if FGrid = nil then
    Exit;
  Inset := GridInset;
  L := Inset;
  T := Inset;
  SBW := Scale(FScrollbarAreaWidth);

  WantV := FScrollBars in [ssVertical, ssBoth];
  WantH := FScrollBars in [ssHorizontal, ssBoth];

  { Decide which scrollbars are actually needed (content overflows). Space is
    reserved ONLY for a scrollbar that is shown — otherwise the cells fill it. }
  AvailW := Max(10, Width - 2 * Inset);
  AvailH := Max(10, Height - 2 * Inset);
  ContentW := SumColWidths;
  ContentH := SumRowHeights;

  NeedV := WantV and (ContentH > AvailH);
  NeedH := WantH and (ContentW > AvailW);
  { A visible scrollbar consumes space, which can force the other to appear }
  if NeedV and WantH and (ContentW > AvailW - SBW) then NeedH := True;
  if NeedH and WantV and (ContentH > AvailH - SBW) then NeedV := True;
  if NeedV and WantH and (ContentW > AvailW - SBW) then NeedH := True;

  if NeedV then
    GridRight := Width - Inset - SBW
  else
    GridRight := Width - Inset;

  if NeedH then
    GridBottom := Height - Inset - SBW
  else
    GridBottom := Height - Inset;

  FGrid.SetBounds(L, T, Max(10, GridRight - L), Max(10, GridBottom - T));

  if NeedV then
    FVTrackRect := Rect(GridRight, T, Width - Inset, GridBottom)
  else
    FVTrackRect := Rect(0, 0, 0, 0);

  if NeedH then
    FHTrackRect := Rect(L, GridBottom, GridRight, Height - Inset)
  else
    FHTrackRect := Rect(0, 0, 0, 0);

  UpdateGridRegion;
  UpdateScrollbarMetrics;
end;

procedure TCWSStringGrid.UpdateGridRegion;
var
  Inset, InnerW, InnerH: Integer;
  Rg: Single;
  Path: TGPGraphicsPath;
  GPRgn: TGPRegion;
  G: TGPGraphics;
  Rgn: HRGN;
  DC: HDC;
begin
  if (FGrid = nil) or not FGrid.HandleAllocated then
    Exit;
  if (FGrid.Width <= 0) or (FGrid.Height <= 0) then
    Exit;

  Inset := GridInset;
  Rg := ScaleF(FCornerRadius) - Inset;
  if Rg <= 0 then
  begin
    SetWindowRgn(FGrid.Handle, 0, True);   { nothing to round — remove clip }
    Exit;
  end;

  { Clip the grid to the whole rounded container shape (the inner rounded
    rectangle), expressed in grid-local coordinates — the grid's origin sits at
    (Inset, Inset) of the control, so the inner rectangle starts at grid-local
    (0, 0). SetWindowRgn then intersects this with the grid window, so the grid
    follows the border curve wherever they overlap and is square only where its
    window genuinely ends in a straight section (e.g. next to a scrollbar
    strip). This is correct for every corner and every scrollbar combination. }
  InnerW := Width - 2 * Inset;
  InnerH := Height - 2 * Inset;
  Path := CreateBorderPath(0, 0, InnerW, InnerH, Rg,
    FRoundTopLeft, FRoundTopRight, FRoundBottomRight, FRoundBottomLeft);
  DC := GetDC(FGrid.Handle);
  try
    G := TGPGraphics.Create(DC);
    try
      GPRgn := TGPRegion.Create(Path);
      try
        Rgn := GPRgn.GetHRGN(G);
        SetWindowRgn(FGrid.Handle, Rgn, True);   { the window owns Rgn now }
      finally
        GPRgn.Free;
      end;
    finally
      G.Free;
    end;
  finally
    ReleaseDC(FGrid.Handle, DC);
    Path.Free;
  end;
end;

procedure TCWSStringGrid.UpdateScrollbarMetrics;
var
  Total, Visible, First, TrackTop, TrackBottom, TrackH, ThumbH, ThumbP,
  ThumbW, CenterX: Integer;
  TrackLeft, TrackRight, TrackW, HThumbW, HThumbP, HThumbH, CenterY: Integer;
  WantV, WantH: Boolean;
begin
  if (FGrid = nil) or not FGrid.HandleAllocated then
    Exit;

  { A scrollbar can only show where its track strip was reserved by
    UpdateGridPosition (i.e. when the content actually overflows). }
  WantV := FVTrackRect.Width > 0;
  WantH := FHTrackRect.Height > 0;

  { Vertical }
  if WantV then
  begin
    GetVMetrics(Total, Visible, First);
    FVScrollVisible := Total > Visible;
    if FVScrollVisible then
    begin
      { With goThumbTracking off the thumb floats at the cursor (FVDragPos) during
        the drag and the grid only scrolls on release — matching Vcl.Grids. }
      if FVDragging and not (goThumbTracking in FGrid.Options) then
        First := FVDragPos;
      TrackTop := FVTrackRect.Top + Scale(4);
      TrackBottom := FVTrackRect.Bottom - Scale(4);
      TrackH := TrackBottom - TrackTop;
      ThumbH := Max(Scale(20), Round(TrackH * (Visible / Total)));
      if Total > Visible then
        ThumbP := TrackTop + Round((First / (Total - Visible)) * (TrackH - ThumbH))
      else
        ThumbP := TrackTop;
      ThumbP := Max(TrackTop, Min(TrackBottom - ThumbH, ThumbP));
      if FVAreaHovered or FVDragging then
        ThumbW := Scale(FScrollbarThumbHoverWidth)
      else
        ThumbW := Scale(FScrollbarThumbWidth);
      CenterX := FVTrackRect.Left + (FVTrackRect.Width - ThumbW) div 2;
      FVThumbRect := Rect(CenterX, ThumbP, CenterX + ThumbW, ThumbP + ThumbH);
    end
    else
      FVThumbRect := Rect(0, 0, 0, 0);
  end
  else
  begin
    FVScrollVisible := False;
    FVThumbRect := Rect(0, 0, 0, 0);
  end;

  { Horizontal }
  if WantH then
  begin
    GetHMetrics(Total, Visible, First);
    FHScrollVisible := Total > Visible;
    if FHScrollVisible then
    begin
      if FHDragging and not (goThumbTracking in FGrid.Options) then
        First := FHDragPos;
      TrackLeft := FHTrackRect.Left + Scale(4);
      TrackRight := FHTrackRect.Right - Scale(4);
      TrackW := TrackRight - TrackLeft;
      HThumbW := Max(Scale(20), Round(TrackW * (Visible / Total)));
      if Total > Visible then
        HThumbP := TrackLeft + Round((First / (Total - Visible)) * (TrackW - HThumbW))
      else
        HThumbP := TrackLeft;
      HThumbP := Max(TrackLeft, Min(TrackRight - HThumbW, HThumbP));
      if FHAreaHovered or FHDragging then
        HThumbH := Scale(FScrollbarThumbHoverWidth)
      else
        HThumbH := Scale(FScrollbarThumbWidth);
      CenterY := FHTrackRect.Top + (FHTrackRect.Height - HThumbH) div 2;
      FHThumbRect := Rect(HThumbP, CenterY, HThumbP + HThumbW, CenterY + HThumbH);
    end
    else
      FHThumbRect := Rect(0, 0, 0, 0);
  end
  else
  begin
    FHScrollVisible := False;
    FHThumbRect := Rect(0, 0, 0, 0);
  end;
end;

procedure TCWSStringGrid.GridScrolled;
begin
  UpdateScrollbarMetrics;
  Invalidate;
  if Assigned(FOnTopLeftChanged) then
    FOnTopLeftChanged(Self);
end;

{ *** Buffer / painting *** }

procedure TCWSStringGrid.EnsureBuffer;
begin
  if (FBuffer.Width <> Width) or (FBuffer.Height <> Height) then
    FBuffer.SetSize(Width, Height);
end;

function TCWSStringGrid.GetParentBgColor: TColor;
begin
  if Parent <> nil then
    Result := TControlAccess(Parent).Color
  else
    Result := clBtnFace;
end;

procedure TCWSStringGrid.DrawParentBackground(DC: HDC; ARadius: Single);
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

function TCWSStringGrid.MakeGPColor(AColor: TColor; Alpha: Byte): Cardinal;
var
  C: TColor;
begin
  C := ColorToRGB(AColor);
  Result := Winapi.GDIPAPI.MakeColor(Alpha, GetRValue(C), GetGValue(C), GetBValue(C));
end;

function TCWSStringGrid.CreateBorderPath(X, Y, W, H, R: Single;
  TL, TR, BR, BL: Boolean): TGPGraphicsPath;
var
  D: Single;
begin
  Result := TGPGraphicsPath.Create;
  D := R * 2;
  if D > H then D := H;
  if D > W then D := W;
  if D < 0 then D := 0;

  { Top-left }
  if TL and (D > 0) then
    Result.AddArc(X, Y, D, D, 180, 90)
  else
    Result.AddLine(X, Y, X, Y);
  { Top-right }
  if TR and (D > 0) then
    Result.AddArc(X + W - D, Y, D, D, 270, 90)
  else
    Result.AddLine(X + W, Y, X + W, Y);
  { Bottom-right }
  if BR and (D > 0) then
    Result.AddArc(X + W - D, Y + H - D, D, D, 0, 90)
  else
    Result.AddLine(X + W, Y + H, X + W, Y + H);
  { Bottom-left }
  if BL and (D > 0) then
    Result.AddArc(X, Y + H - D, D, D, 90, 90)
  else
    Result.AddLine(X, Y + H, X, Y + H);

  Result.CloseFigure;
end;

function TCWSStringGrid.CreateRoundRectPath(X, Y, W, H, R: Single): TGPGraphicsPath;
var
  D: Single;
begin
  Result := TGPGraphicsPath.Create;
  D := R * 2;
  if D > H then D := H;
  if D > W then D := W;
  if D < 0 then D := 0;
  Result.AddArc(X,         Y,         D, D, 180, 90);
  Result.AddArc(X + W - D, Y,         D, D, 270, 90);
  Result.AddArc(X + W - D, Y + H - D, D, D,   0, 90);
  Result.AddArc(X,         Y + H - D, D, D,  90, 90);
  Result.CloseFigure;
end;

procedure TCWSStringGrid.PaintToBuffer;
var
  G: TGPGraphics;
  Path: TGPGraphicsPath;
  Brush: TGPSolidBrush;
  Pen: TGPPen;
  W, H, R: Single;
  ThumbAlpha: Byte;
  ThumbColor: Cardinal;

  procedure DrawThumb(const ARect: TRect; Hovered, Dragging: Boolean; Horizontal: Boolean);
  var
    P: TGPGraphicsPath;
    B: TGPSolidBrush;
    Rad: Single;
  begin
    if (ARect.Width <= 0) or (ARect.Height <= 0) then
      Exit;
    if Hovered or Dragging then
      ThumbAlpha := 220
    else
      ThumbAlpha := 140;
    if Hovered or Dragging then
      ThumbColor := MakeGPColor(FScrollThumbHoverColor, ThumbAlpha)
    else
      ThumbColor := MakeGPColor(FScrollThumbColor, ThumbAlpha);
    if Horizontal then
      Rad := ARect.Height / 2.0
    else
      Rad := ARect.Width / 2.0;
    P := CreateRoundRectPath(ARect.Left + 0.0, ARect.Top + 0.0,
      ARect.Width + 0.0, ARect.Height + 0.0, Rad);
    try
      B := TGPSolidBrush.Create(ThumbColor);
      try
        G.FillPath(B, P);
      finally
        B.Free;
      end;
    finally
      P.Free;
    end;
  end;

begin
  EnsureBuffer;
  UpdateScrollbarMetrics;
  W := Width;
  H := Height;
  R := ScaleF(FCornerRadius);

  FBuffer.Canvas.Brush.Color := GetParentBgColor;
  FBuffer.Canvas.FillRect(Rect(0, 0, Width, Height));
  DrawParentBackground(FBuffer.Canvas.Handle, R);

  G := TGPGraphics.Create(FBuffer.Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    G.SetPixelOffsetMode(PixelOffsetModeHalf);

    { Interior fill (shows in the padding around the grid) + border. The border
      always rounds its enabled corners (it is the outer visible shape). }
    Path := CreateBorderPath(0.5, 0.5, W - 1, H - 1, R,
      FRoundTopLeft, FRoundTopRight, FRoundBottomRight, FRoundBottomLeft);
    try
      Brush := TGPSolidBrush.Create(MakeGPColor(FBackgroundColor));
      G.FillPath(Brush, Path);
      Brush.Free;

      if FShowBorder then
      begin
        Pen := TGPPen.Create(MakeGPColor(FBorderColor));
        G.DrawPath(Pen, Path);
        Pen.Free;
      end;
    finally
      Path.Free;
    end;

    { Scrollbars — clipped to the rounded interior so a thumb near a corner
      follows the rounding instead of poking past the border. }
    if FVScrollVisible or FHScrollVisible then
    begin
      Path := CreateBorderPath(1, 1, W - 2, H - 2, R,
        FRoundTopLeft, FRoundTopRight, FRoundBottomRight, FRoundBottomLeft);
      try
        G.SetClip(Path);
        if FVScrollVisible then
          DrawThumb(FVThumbRect, FVAreaHovered, FVDragging, False);
        if FHScrollVisible then
          DrawThumb(FHThumbRect, FHAreaHovered, FHDragging, True);
        G.ResetClip;
      finally
        Path.Free;
      end;
    end;
  finally
    G.Free;
  end;
end;

procedure TCWSStringGrid.WMPaint(var Msg: TWMPaint);
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

procedure TCWSStringGrid.Paint;
begin
  PaintToBuffer;
  { Our public Canvas now points at the inner grid's canvas, so blit the
    composed buffer onto this control's OWN canvas (TCustomControl.Canvas). }
  inherited Canvas.Draw(0, 0, FBuffer);
end;

procedure TCWSStringGrid.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

{ *** Mouse — scrollbars *** }

procedure TCWSStringGrid.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  P: TPoint;
  Total, Visible, First: Integer;
begin
  inherited;
  P := Point(X, Y);
  if (Button = mbLeft) and Enabled then
  begin
    if FVScrollVisible and FVTrackRect.Contains(P) then
    begin
      GetVMetrics(Total, Visible, First);
      { The thumb is narrower than the track and centred in it, so test only the
        scroll axis: anywhere across the track width within the thumb's vertical
        span grabs the thumb (the cursor is already inside the track here). }
      if (P.Y >= FVThumbRect.Top) and (P.Y < FVThumbRect.Bottom) then
      begin
        FVDragging := True;
        FVDragStartY := Y;
        FVDragStartRow := First;
        FVDragPos := First;
      end
      else
        { Clicking the track pages toward the click — by a visible page, like the
          stock Vcl.Grids scrollbar (SB_PAGEUP / SB_PAGEDOWN) — and holding the
          button keeps paging until the thumb reaches the cursor. }
        if P.Y < FVThumbRect.Top then
          StartTrackRepeat(True, -1)
        else
          StartTrackRepeat(True, 1);
      Exit;
    end;

    if FHScrollVisible and FHTrackRect.Contains(P) then
    begin
      GetHMetrics(Total, Visible, First);
      { Test only the scroll axis — the thumb is thinner than the track and
        centred in it, so anywhere across the track height within the thumb's
        horizontal span grabs it. }
      if (P.X >= FHThumbRect.Left) and (P.X < FHThumbRect.Right) then
      begin
        FHDragging := True;
        FHDragStartX := X;
        FHDragStartCol := First;
        FHDragPos := First;
      end
      else
        if P.X < FHThumbRect.Left then
          StartTrackRepeat(False, -1)
        else
          StartTrackRepeat(False, 1);
      Exit;
    end;

    if FGrid.CanFocus then
      FGrid.SetFocus;
  end;
end;

procedure TCWSStringGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
  Total, Visible, First, TrackTop, TrackBottom, TrackH, ThumbH, MaxScroll: Integer;
  TrackLeft, TrackRight, TrackW, ThumbW: Integer;
  WasV, WasH: Boolean;
begin
  inherited;
  P := Point(X, Y);

  if FVScrollVisible then
  begin
    WasV := FVAreaHovered;
    FVAreaHovered := FVTrackRect.Contains(P) or FVDragging;
    if FVAreaHovered <> WasV then
    begin
      UpdateScrollbarMetrics;
      Invalidate;
    end;
  end;
  if FHScrollVisible then
  begin
    WasH := FHAreaHovered;
    FHAreaHovered := FHTrackRect.Contains(P) or FHDragging;
    if FHAreaHovered <> WasH then
    begin
      UpdateScrollbarMetrics;
      Invalidate;
    end;
  end;

  if FVDragging and FVScrollVisible then
  begin
    GetVMetrics(Total, Visible, First);
    MaxScroll := Max(0, Total - Visible);
    TrackTop := FVTrackRect.Top + Scale(4);
    TrackBottom := FVTrackRect.Bottom - Scale(4);
    TrackH := TrackBottom - TrackTop;
    ThumbH := FVThumbRect.Height;
    if (TrackH - ThumbH) > 0 then
    begin
      First := FVDragStartRow + Round(((Y - FVDragStartY) / (TrackH - ThumbH)) * MaxScroll);
      First := Max(0, Min(MaxScroll, First));
      if goThumbTracking in FGrid.Options then
        ScrollVTo(First)            { live — the grid follows the thumb }
      else
      begin
        FVDragPos := First;         { defer — only float the thumb until release }
        UpdateScrollbarMetrics;
        Invalidate;
      end;
    end;
  end;

  if FHDragging and FHScrollVisible then
  begin
    GetHMetrics(Total, Visible, First);
    MaxScroll := Max(0, Total - Visible);
    TrackLeft := FHTrackRect.Left + Scale(4);
    TrackRight := FHTrackRect.Right - Scale(4);
    TrackW := TrackRight - TrackLeft;
    ThumbW := FHThumbRect.Width;
    if (TrackW - ThumbW) > 0 then
    begin
      First := FHDragStartCol + Round(((X - FHDragStartX) / (TrackW - ThumbW)) * MaxScroll);
      First := Max(0, Min(MaxScroll, First));
      if goThumbTracking in FGrid.Options then
        ScrollHTo(First)
      else
      begin
        FHDragPos := First;
        UpdateScrollbarMetrics;
        Invalidate;
      end;
    end;
  end;
end;

procedure TCWSStringGrid.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  { End any track-click auto-repeat the moment the button is released. }
  StopTrackRepeat;
  if FVDragging then
  begin
    { With goThumbTracking off the grid hasn't moved during the drag — catch it
      up to where the thumb was released (mirrors SB_THUMBPOSITION). }
    if not (goThumbTracking in FGrid.Options) then
      ScrollVTo(FVDragPos);
    FVDragging := False;
    FVAreaHovered := FVTrackRect.Contains(Point(X, Y));
    UpdateScrollbarMetrics;
  end;
  if FHDragging then
  begin
    if not (goThumbTracking in FGrid.Options) then
      ScrollHTo(FHDragPos);
    FHDragging := False;
    FHAreaHovered := FHTrackRect.Contains(Point(X, Y));
    UpdateScrollbarMetrics;
  end;
  Invalidate;
end;

{ *** Lifecycle *** }

procedure TCWSStringGrid.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_CLIPCHILDREN;
end;

procedure TCWSStringGrid.CreateWnd;
begin
  inherited;
  UpdateGridPosition;
  SyncGridFont;
end;

procedure TCWSStringGrid.Loaded;
begin
  inherited;
  ApplyColors;
  UpdateGridPosition;
  SyncGridFont;
end;

procedure TCWSStringGrid.Resize;
begin
  inherited;
  UpdateGridPosition;
end;

procedure TCWSStringGrid.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited;
  if FBuffer <> nil then
    FBuffer.SetSize(0, 0);
  SyncGridFont;
  UpdateGridPosition;
end;

procedure TCWSStringGrid.CMPPIChanged(var Msg: TMessage);
begin
  inherited;
  if FBuffer <> nil then
    FBuffer.SetSize(0, 0);
  SyncGridFont;
  UpdateGridPosition;
  Invalidate;
end;

procedure TCWSStringGrid.SetFocus;
begin
  if (FGrid <> nil) and FGrid.CanFocus then
    FGrid.SetFocus
  else
    inherited;
end;

procedure TCWSStringGrid.WMSetFocus(var Msg: TWMSetFocus);
begin
  inherited;
  { The wrapper is a focusable TWinControl with its own window, so VCL/Windows
    can hand it the focus directly — clicking the chrome, tab navigation through
    SetActiveControl, or ActiveControl := Grid — all of which bypass the virtual
    SetFocus above. Forward to the inner grid so the composite always behaves as
    a single focusable control and keystrokes reach the grid. }
  if (FGrid <> nil) and FGrid.CanFocus and not (csDestroying in ComponentState) then
    FGrid.SetFocus;
end;

procedure TCWSStringGrid.SyncGridFont;
begin
  if FGrid <> nil then
  begin
    FGrid.Font := Font;
    FGrid.Invalidate;
  end;
end;

procedure TCWSStringGrid.UpdateFocusState;
begin
  FFocused := True;
  Invalidate;
end;

procedure TCWSStringGrid.GridClicked;
begin
  UpdateScrollbarMetrics;
  Invalidate;
  if Assigned(FOnClick) then
    FOnClick(Self);
end;

procedure TCWSStringGrid.GridDblClicked;
begin
  if Assigned(FOnDblClick) then
    FOnDblClick(Self);
end;

{ *** Grid event handlers *** }

procedure TCWSStringGrid.GridSelectCell(Sender: TObject; ACol, ARow: Longint;
  var CanSelect: Boolean);
begin
  if Assigned(FOnSelectCell) then
    FOnSelectCell(Self, ACol, ARow, CanSelect);
  { Repaint so the row/cell highlight follows the new selection }
  FGrid.Invalidate;
  Invalidate;
end;

procedure TCWSStringGrid.GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnKeyDown) then
    FOnKeyDown(Self, Key, Shift);
  UpdateScrollbarMetrics;
  Invalidate;
end;

procedure TCWSStringGrid.GridKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnKeyUp) then
    FOnKeyUp(Self, Key, Shift);
end;

procedure TCWSStringGrid.GridKeyPress(Sender: TObject; var Key: Char);
begin
  if Assigned(FOnKeyPress) then
    FOnKeyPress(Self, Key);
end;

procedure TCWSStringGrid.CMFontChanged(var Msg: TMessage);
begin
  inherited;
  SyncGridFont;
  Invalidate;
end;

procedure TCWSStringGrid.CMEnabledChanged(var Msg: TMessage);
begin
  inherited;
  if FGrid <> nil then
    FGrid.Enabled := Enabled;
  Invalidate;
end;

procedure TCWSStringGrid.CMMouseLeave(var Msg: TMessage);
begin
  inherited;
  { The cursor left the control (or moved onto the child grid window) — drop
    the scrollbar hover state so the thumb returns to its resting size. }
  if not (FVDragging or FHDragging) and (FVAreaHovered or FHAreaHovered) then
  begin
    FVAreaHovered := False;
    FHAreaHovered := False;
    UpdateScrollbarMetrics;
    Invalidate;
  end;
end;

{ *** Forwarded properties *** }

function TCWSStringGrid.GetColCount: Integer;
begin Result := FGrid.ColCount; end;

procedure TCWSStringGrid.SetColCount(const Value: Integer);
begin FGrid.ColCount := Value; UpdateGridPosition; Invalidate; end;

function TCWSStringGrid.GetRowCount: Integer;
begin Result := FGrid.RowCount; end;

procedure TCWSStringGrid.SetRowCount(const Value: Integer);
begin FGrid.RowCount := Value; UpdateGridPosition; Invalidate; end;

function TCWSStringGrid.GetFixedCols: Integer;
begin Result := FGrid.FixedCols; end;

procedure TCWSStringGrid.SetFixedCols(const Value: Integer);
begin FGrid.FixedCols := Value; UpdateGridPosition; Invalidate; end;

function TCWSStringGrid.GetFixedRows: Integer;
begin Result := FGrid.FixedRows; end;

procedure TCWSStringGrid.SetFixedRows(const Value: Integer);
begin FGrid.FixedRows := Value; UpdateGridPosition; Invalidate; end;

function TCWSStringGrid.GetDefaultColWidth: Integer;
begin Result := FGrid.DefaultColWidth; end;

procedure TCWSStringGrid.SetDefaultColWidth(const Value: Integer);
begin FGrid.DefaultColWidth := Value; UpdateGridPosition; Invalidate; end;

function TCWSStringGrid.GetDefaultRowHeight: Integer;
begin Result := FGrid.DefaultRowHeight; end;

procedure TCWSStringGrid.SetDefaultRowHeight(const Value: Integer);
begin FGrid.DefaultRowHeight := Value; UpdateGridPosition; Invalidate; end;

procedure TCWSStringGrid.SetGridLineWidth(const Value: Integer);
begin
  if FGridLineWidth <> Value then
  begin
    FGridLineWidth := Max(0, Value);
    if FGrid <> nil then FGrid.Invalidate;
    Invalidate;
  end;
end;

function TCWSStringGrid.GetOptions: TGridOptions;
begin Result := FGrid.Options; end;

procedure TCWSStringGrid.SetOptions(const Value: TGridOptions);
begin
  { goDrawFocusSelected is dropped, not passed on. Both of the things it drives
    in Vcl.Grids — the dotted focus rectangle and the background of the focused
    cell inside a selection — live behind `DefaultDrawing`, which the inner grid
    keeps off because the component paints every cell itself. Leaving the flag
    settable would only offer a switch that changes nothing. The component
    marks the current cell with CellHighlightColor, the same as TCWSDBGrid. }
  FGrid.Options := Value - [goDrawFocusSelected];
  UpdateGridPosition;
  Invalidate;
end;

function TCWSStringGrid.GetCol: Integer;
begin Result := FGrid.Col; end;

procedure TCWSStringGrid.SetCol(const Value: Integer);
begin FGrid.Col := Value; end;

function TCWSStringGrid.GetRow: Integer;
begin Result := FGrid.Row; end;

procedure TCWSStringGrid.SetRow(const Value: Integer);
begin FGrid.Row := Value; end;

function TCWSStringGrid.GetCells(ACol, ARow: Integer): string;
begin Result := FGrid.Cells[ACol, ARow]; end;

function TCWSStringGrid.GetCellCanvas: TCanvas;
begin Result := FGrid.Canvas; end;

procedure TCWSStringGrid.SetCells(ACol, ARow: Integer; const Value: string);
begin FGrid.Cells[ACol, ARow] := Value; end;

function TCWSStringGrid.GetObjects(ACol, ARow: Integer): TObject;
begin Result := FGrid.Objects[ACol, ARow]; end;

procedure TCWSStringGrid.SetObjects(ACol, ARow: Integer; const Value: TObject);
begin FGrid.Objects[ACol, ARow] := Value; end;

function TCWSStringGrid.GetColWidths(Index: Integer): Integer;
begin Result := FGrid.ColWidths[Index]; end;

procedure TCWSStringGrid.SetColWidths(Index: Integer; const Value: Integer);
begin FGrid.ColWidths[Index] := Value; UpdateGridPosition; Invalidate; end;

function TCWSStringGrid.GetRowHeights(Index: Integer): Integer;
begin Result := FGrid.RowHeights[Index]; end;

procedure TCWSStringGrid.SetRowHeights(Index: Integer; const Value: Integer);
begin FGrid.RowHeights[Index] := Value; UpdateGridPosition; Invalidate; end;

function TCWSStringGrid.GetSelection: TGridRect;
begin Result := FGrid.Selection; end;

procedure TCWSStringGrid.SetSelection(const Value: TGridRect);
begin FGrid.Selection := Value; FGrid.Invalidate; Invalidate; end;

function TCWSStringGrid.GetColsRows(Index: Integer): TStrings;
begin Result := FGrid.Cols[Index]; end;

function TCWSStringGrid.GetColRow(Index: Integer): TStrings;
begin Result := FGrid.Rows[Index]; end;

{ *** Color setters *** }

procedure TCWSStringGrid.SetBorderColor(const Value: TColor);
begin if FBorderColor <> Value then begin FBorderColor := Value; Invalidate; end; end;

procedure TCWSStringGrid.SetBackgroundColor(const Value: TColor);
begin if FBackgroundColor <> Value then begin FBackgroundColor := Value; ApplyColors; end; end;

procedure TCWSStringGrid.SetCellColor(const Value: TColor);
begin if FCellColor <> Value then begin FCellColor := Value; ApplyColors; end; end;

procedure TCWSStringGrid.SetCellTextColor(const Value: TColor);
begin if FCellTextColor <> Value then begin FCellTextColor := Value; ApplyColors; end; end;

procedure TCWSStringGrid.SetGridLineColor(const Value: TColor);
begin if FGridLineColor <> Value then begin FGridLineColor := Value; ApplyColors; end; end;

procedure TCWSStringGrid.SetFixedColor(const Value: TColor);
begin if FFixedColor <> Value then begin FFixedColor := Value; ApplyColors; end; end;

procedure TCWSStringGrid.SetFixedTextColor(const Value: TColor);
begin if FFixedTextColor <> Value then begin FFixedTextColor := Value; ApplyColors; end; end;

procedure TCWSStringGrid.SetCellHighlightColor(const Value: TColor);
begin if FCellHighlightColor <> Value then begin FCellHighlightColor := Value; ApplyColors; end; end;

procedure TCWSStringGrid.SetHighlightTextColor(const Value: TColor);
begin if FHighlightTextColor <> Value then begin FHighlightTextColor := Value; ApplyColors; end; end;

procedure TCWSStringGrid.SetAlternatingRowColors(const Value: Boolean);
begin if FAlternatingRowColors <> Value then begin FAlternatingRowColors := Value; ApplyColors; end; end;

procedure TCWSStringGrid.SetOddRowColor(const Value: TColor);
begin if FOddRowColor <> Value then begin FOddRowColor := Value; ApplyColors; end; end;

procedure TCWSStringGrid.SetEvenRowColor(const Value: TColor);
begin if FEvenRowColor <> Value then begin FEvenRowColor := Value; ApplyColors; end; end;

procedure TCWSStringGrid.SetCornerRadius(const Value: Single);
var
  NewValue: Single;
begin
  NewValue := Value;
  if NewValue < 0 then
    NewValue := 0;
  if FCornerRadius <> NewValue then
  begin
    FCornerRadius := NewValue;
    UpdateGridRegion;
    Invalidate;
  end;
end;

procedure TCWSStringGrid.ReadCornerRadius(Reader: TReader);
begin
  { Read straight into the field — the region is rebuilt in Loaded anyway. }
  FCornerRadius := Reader.ReadFloat;
end;

procedure TCWSStringGrid.WriteCornerRadius(Writer: TWriter);
begin
  Writer.WriteFloat(FCornerRadius);
end;

procedure TCWSStringGrid.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  { Floating-point properties with value 0 are skipped by the standard DFM
    streamer (0 = default for float). Thanks to this entry CornerRadius is always
    saved, even when set to 0 — so a design-time 0 stays 0 at run time. }
  Filer.DefineProperty('CornerRadiusF', ReadCornerRadius, WriteCornerRadius, True);
end;

procedure TCWSStringGrid.SetShowBorder(const Value: Boolean);
begin
  if FShowBorder <> Value then
  begin
    FShowBorder := Value;
    Invalidate;
  end;
end;

procedure TCWSStringGrid.SetRoundTopLeft(const Value: Boolean);
begin if FRoundTopLeft <> Value then begin FRoundTopLeft := Value; UpdateGridRegion; Invalidate; end; end;

procedure TCWSStringGrid.SetRoundTopRight(const Value: Boolean);
begin if FRoundTopRight <> Value then begin FRoundTopRight := Value; UpdateGridRegion; Invalidate; end; end;

procedure TCWSStringGrid.SetRoundBottomLeft(const Value: Boolean);
begin if FRoundBottomLeft <> Value then begin FRoundBottomLeft := Value; UpdateGridRegion; Invalidate; end; end;

procedure TCWSStringGrid.SetRoundBottomRight(const Value: Boolean);
begin if FRoundBottomRight <> Value then begin FRoundBottomRight := Value; UpdateGridRegion; Invalidate; end; end;

procedure TCWSStringGrid.SetScrollThumbColor(const Value: TColor);
begin if FScrollThumbColor <> Value then begin FScrollThumbColor := Value; Invalidate; end; end;

procedure TCWSStringGrid.SetScrollThumbHoverColor(const Value: TColor);
begin if FScrollThumbHoverColor <> Value then begin FScrollThumbHoverColor := Value; Invalidate; end; end;

procedure TCWSStringGrid.SetScrollbarAreaWidth(const Value: Integer);
begin
  if FScrollbarAreaWidth <> Value then
  begin
    FScrollbarAreaWidth := Max(6, Value);
    UpdateGridPosition;
    Invalidate;
  end;
end;

procedure TCWSStringGrid.SetScrollbarThumbWidth(const Value: Integer);
begin
  if FScrollbarThumbWidth <> Value then
  begin
    FScrollbarThumbWidth := Max(2, Value);
    UpdateScrollbarMetrics;
    Invalidate;
  end;
end;

procedure TCWSStringGrid.SetScrollbarThumbHoverWidth(const Value: Integer);
begin
  if FScrollbarThumbHoverWidth <> Value then
  begin
    FScrollbarThumbHoverWidth := Max(2, Value);
    UpdateScrollbarMetrics;
    Invalidate;
  end;
end;

procedure TCWSStringGrid.SetScrollBars(const Value: TScrollStyle);
begin
  if FScrollBars <> Value then
  begin
    FScrollBars := Value;
    UpdateGridPosition;
    Invalidate;
  end;
end;

end.
