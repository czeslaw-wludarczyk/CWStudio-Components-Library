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
unit CWSDBGrid;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  System.SysUtils, System.Classes, System.Types, System.Math,
  Vcl.Controls, Vcl.Graphics, Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, Vcl.Forms,
  Vcl.ExtCtrls, Data.DB, System.UITypes;

const
  CM_PPICHANGED_DBGRID = $B080 + 13;
  CM_DBGRID_REFRESH    = $B080 + 14;

type
  { Re-export so consumers don't need Vcl.Grids / Vcl.DBGrids / Data.DB in their
    uses clause. The names must match the ones the IDE writes into generated
    event handlers (e.g. State: TGridDrawState, Field: TField) — otherwise a unit
    that only uses CWSDBGrid can't resolve those parameter types. }
  TGridDrawState      = Vcl.Grids.TGridDrawState;
  TCWSGridDrawState   = Vcl.Grids.TGridDrawState;   { back-compat alias }
  TGridRect           = Vcl.Grids.TGridRect;
  TMovedEvent         = Vcl.Grids.TMovedEvent;
  TField              = Data.DB.TField;

  TColumn             = Vcl.DBGrids.TColumn;
  TDBGridColumns      = Vcl.DBGrids.TDBGridColumns;
  TDBGridOption       = Vcl.DBGrids.TDBGridOption;
  TDBGridOptions      = Vcl.DBGrids.TDBGridOptions;
  TBookmarkList       = Vcl.DBGrids.TBookmarkList;
  TDrawColumnCellEvent = Vcl.DBGrids.TDrawColumnCellEvent;
  TDrawDataCellEvent  = Vcl.DBGrids.TDrawDataCellEvent;
  TDBGridClickEvent   = Vcl.DBGrids.TDBGridClickEvent;

const
  gdSelected = Vcl.Grids.gdSelected;
  gdFocused  = Vcl.Grids.gdFocused;
  gdFixed    = Vcl.Grids.gdFixed;

  { TDBGridOptions members re-exported for convenience }
  dgEditing               = Vcl.DBGrids.dgEditing;
  dgAlwaysShowEditor      = Vcl.DBGrids.dgAlwaysShowEditor;
  dgTitles                = Vcl.DBGrids.dgTitles;
  dgIndicator             = Vcl.DBGrids.dgIndicator;
  dgColumnResize          = Vcl.DBGrids.dgColumnResize;
  dgColLines              = Vcl.DBGrids.dgColLines;
  dgRowLines              = Vcl.DBGrids.dgRowLines;
  dgTabs                  = Vcl.DBGrids.dgTabs;
  dgRowSelect             = Vcl.DBGrids.dgRowSelect;
  dgAlwaysShowSelection   = Vcl.DBGrids.dgAlwaysShowSelection;
  dgConfirmDelete         = Vcl.DBGrids.dgConfirmDelete;
  dgCancelOnExit          = Vcl.DBGrids.dgCancelOnExit;
  dgMultiSelect           = Vcl.DBGrids.dgMultiSelect;
  dgTitleClick            = Vcl.DBGrids.dgTitleClick;
  dgTitleHotTrack         = Vcl.DBGrids.dgTitleHotTrack;
  dgThumbTracking         = Vcl.DBGrids.dgThumbTracking;

type
  TCWSDBGrid = class;

  { Internal native DB grid — fully owner-drawn, flat (no 3D) }
  TCWSInternalDBGrid = class(TDBGrid)
  private
    FOwner: TCWSDBGrid;
    FDrawRow: Integer;        { grid row currently being painted (see DrawCell) }
    function DataRowNumber: Integer;
  protected
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect;
      AState: TGridDrawState); override;
    procedure DrawColumnCell(const Rect: TRect; DataCol: Integer;
      Column: TColumn; State: TGridDrawState); override;
    procedure UpdateScrollBar; override;
    procedure Paint; override;
    procedure TopLeftChanged; override;
    procedure LayoutChanged; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    function CreateEditor: TInplaceEdit; override;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure Click; override;
    procedure DblClick; override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    { Use a Columns collection that reports per-item edits back to the owner so
      single-column tweaks (Title.Caption, Width, Alignment, …) repaint live. }
    function CreateColumns: TDBGridColumns; override;
  public
    constructor Create(AOwner: TComponent); override;

    { Pushes the current theme colors onto the live in-cell editor (if any),
      so a cell being edited repaints immediately on a theme change. }
    procedure RefreshEditorColors;

    { Called by the custom columns collection on every Update — including the
      per-item edits that the stock DBGrid only resolves with a partial column
      invalidate and therefore never reach the owner's LayoutChanged hook. }
    procedure OwnerColumnsChanged;

    { Protected TCustomGrid metrics surfaced for the owner's scrollbar math }
    function VisibleDataRows: Integer;
    function VisibleDataCols: Integer;
    function TotalCols: Integer;
    function FixedColCount: Integer;
    function LeftColumn: Integer;
    procedure SetLeftColumn(Value: Integer);
    function ColWidthPx(Index: Integer): Integer;
    function GridClientWidth: Integer;
  end;

  { Columns collection that forwards every change (whole-collection AND
    per-item) to the owning grid, so editing a single column property updates
    the Fluent surface immediately, the way a stock TDBGrid repaints itself. }
  TCWSDBGridColumns = class(TDBGridColumns)
  protected
    procedure Update(Item: TCollectionItem); override;
  end;

  TCWSDBGrid = class(TCustomControl)
  private
    FGrid: TCWSInternalDBGrid;
    FBuffer: TBitmap;
    FFocused: Boolean;
    FRefreshPosted: Boolean;
    FUpdatingLayout: Boolean;
    FAutoFitColumns: Boolean;
    FFittingColumns: Boolean;

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
    FDefaultRowHeight: Integer;
    FTitleHeight: Integer;
    FCenterTextVertically: Boolean;
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
    FVDragPos: Integer;       { pending position while a non-thumb-tracking drag is held }
    FVThumbRect: TRect;
    FVTrackRect: TRect;

    { Horizontal scrollbar state }
    FHScrollVisible: Boolean;
    FHAreaHovered: Boolean;
    FHDragging: Boolean;
    FHDragStartCol: Integer;
    FHDragStartX: Integer;
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
    FOnDrawColumnCell: TDrawColumnCellEvent;
    FOnDrawDataCell: TDrawDataCellEvent;
    FOnCellClick: TDBGridClickEvent;
    FOnTitleClick: TDBGridClickEvent;
    FOnColEnter: TNotifyEvent;
    FOnColExit: TNotifyEvent;
    FOnColumnMoved: TMovedEvent;
    FOnEditButtonClick: TNotifyEvent;
    FOnKeyDown: TKeyEvent;
    FOnKeyUp: TKeyEvent;
    FOnKeyPress: TKeyPressEvent;
    FOnTopLeftChanged: TNotifyEvent;
    FOnEnter: TNotifyEvent;
    FOnExit: TNotifyEvent;
    FOnMouseDown: TMouseEvent;
    FOnMouseUp: TMouseEvent;
    FOnMouseMove: TMouseMoveEvent;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;
    FMouseInside: Boolean;
    FOnMouseWheel: TMouseWheelEvent;
    FOnMouseWheelDown: TMouseWheelUpDownEvent;
    FOnMouseWheelUp: TMouseWheelUpDownEvent;

    { Forwarded property access }
    function GetDataSource: TDataSource;
    procedure SetDataSource(const Value: TDataSource);
    function GetColumns: TDBGridColumns;
    procedure SetColumns(const Value: TDBGridColumns);
    function StoreColumns: Boolean;
    function GetOptions: TDBGridOptions;
    procedure SetOptions(const Value: TDBGridOptions);
    function GetReadOnly: Boolean;
    procedure SetReadOnly(const Value: Boolean);
    function GetTitleFont: TFont;
    procedure SetTitleFont(const Value: TFont);
    function GetDefaultDrawing: Boolean;
    procedure SetDefaultDrawing(const Value: Boolean);
    procedure SetGridLineWidth(const Value: Integer);
    procedure SetDefaultRowHeight(const Value: Integer);
    procedure SetTitleHeight(const Value: Integer);
    procedure SetCenterTextVertically(const Value: Boolean);
    procedure DrawColumnCellCentered(const Rect: TRect; Column: TColumn);

    function GetSelectedField: TField;
    procedure SetSelectedField(const Value: TField);
    function GetSelectedIndex: Integer;
    procedure SetSelectedIndex(const Value: Integer);
    function GetSelectedRows: TBookmarkList;
    function GetFields(Index: Integer): TField;
    function GetFieldCount: Integer;
    function GetEditorMode: Boolean;
    procedure SetEditorMode(const Value: Boolean);
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
    function RowBackColor(ARowNumber: Integer): TColor;
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
    procedure SetAutoFitColumns(const Value: Boolean);

    { Geometry / scrolling }
    function GetDataSet: TDataSet;
    function VOverflow: Boolean;
    function HOverflow: Boolean;
    function ScrollableTotalWidth: Integer;
    function FixedWidth: Integer;
    function ScrolledOffWidth: Integer;
    function ColIndexForOffset(TargetPx: Integer): Integer;
    function Scale(Value: Integer): Integer;
    function ScaleF(Value: Single): Single;
    function GridInset: Integer;
    procedure UpdateGridPosition;
    procedure UpdateGridRegion;
    procedure UpdateScrollbarMetrics;
    procedure GetVMetrics(out Total, Visible, First: Integer);
    procedure GetHMetrics(out Total, Visible, First: Integer);
    function HScrollMax: Integer;
    procedure ScrollVToRec(RecIndex: Integer);
    procedure ScrollVBy(Delta: Integer);
    procedure ScrollHTo(FirstPx: Integer);
    procedure ScrollHByPage(Dir: Integer);
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
    procedure GridDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure GridDrawDataCell(Sender: TObject; const Rect: TRect; Field: TField;
      State: TGridDrawState);
    procedure GridCellClick(Column: TColumn);
    procedure GridTitleClick(Column: TColumn);
    procedure GridColEnter(Sender: TObject);
    procedure GridColExit(Sender: TObject);
    procedure GridColumnMoved(Sender: TObject; FromIndex, ToIndex: Longint);
    procedure GridEditButtonClick(Sender: TObject);
    procedure GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridKeyPress(Sender: TObject; var Key: Char);

    procedure CMFontChanged(var Msg: TMessage); message CM_FONTCHANGED;
    procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure CMPPIChanged(var Msg: TMessage); message CM_PPICHANGED_DBGRID;
    procedure CMRefreshLayout(var Msg: TMessage); message CM_DBGRID_REFRESH;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    { When a scrollbar is visible the inner grid is inset, so the scrollbar strip
      belongs to this outer window. Forward the wheel to the inner grid so
      hovering the scrollbar still scrolls the data. }
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;

    { Hooks called from the internal grid }
    procedure GridScrolled;
    procedure GridContentChanged;
    procedure GridLayoutChanged;
    procedure ApplyRowHeights;
    procedure DrawGridLine(C: TCanvas; const R: TRect);
    procedure GridClicked;
    procedure GridDblClicked;
    procedure GridEnter;
    procedure GridExit;
    procedure GridMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure GridMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure GridMouseMove(Shift: TShiftState; X, Y: Integer);
    procedure GridMouseWheelDown(Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure GridMouseWheelUp(Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure CompositeMouseEnter;
    procedure CompositeMouseCheckLeave;
    procedure UpdateFocusState;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetFocus; override;

    { Pass-through of the most useful TDBGrid methods }
    procedure DefaultDrawColumnCell(const Rect: TRect; DataCol: Integer;
      Column: TColumn; State: TGridDrawState);

    { Distribute the data area evenly across the visible columns (the fixed
      indicator column keeps its width). One-shot; see also AutoFitColumns. }
    procedure FitColumnsToWidth;

    property Grid: TCWSInternalDBGrid read FGrid;
    { The drawing surface used by the OnDrawColumnCell / OnDrawDataCell events.
      It maps to the inner grid's canvas, so handlers can paint with
      CWSDBGrid.Canvas directly (no need for CWSDBGrid.Grid.Canvas).
      CellCanvas is kept as a backwards-compatible alias. }
    property Canvas: TCanvas read GetCellCanvas;
    property CellCanvas: TCanvas read GetCellCanvas;

    property SelectedField: TField read GetSelectedField write SetSelectedField;
    property SelectedIndex: Integer read GetSelectedIndex write SetSelectedIndex;
    property SelectedRows: TBookmarkList read GetSelectedRows;
    property Fields[Index: Integer]: TField read GetFields;
    property FieldCount: Integer read GetFieldCount;
    property EditorMode: Boolean read GetEditorMode write SetEditorMode;
  published
    { Data binding }
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property Columns: TDBGridColumns read GetColumns write SetColumns stored StoreColumns;
    property Options: TDBGridOptions read GetOptions write SetOptions;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property TitleFont: TFont read GetTitleFont write SetTitleFont;
    property DefaultDrawing: Boolean read GetDefaultDrawing write SetDefaultDrawing default True;
    { Keep the visible columns stretched to the full grid width — re-applied on
      resize, dataset open and column changes. Runtime only (see
      FitColumnsToWidth for why design time is skipped). }
    property AutoFitColumns: Boolean read FAutoFitColumns write SetAutoFitColumns default False;

    { Colors }
    property BorderColor: TColor read FBorderColor write SetBorderColor default $D6D6D6;
    property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor default clWhite;
    property CellColor: TColor read FCellColor write SetCellColor default clWhite;
    property CellTextColor: TColor read FCellTextColor write SetCellTextColor default $202020;
    property GridLineColor: TColor read FGridLineColor write SetGridLineColor default $E0E0E0;
    property GridLineWidth: Integer read FGridLineWidth write SetGridLineWidth default 1;
    { Row heights in logical (96 DPI) pixels, scaled to the current PPI on apply.
      0 = automatic: DBGrid measures data rows from Font and the title (fixed)
      row from TitleFont, so the two can be sized completely independently.
      DefaultRowHeight overrides only the data rows; TitleHeight overrides only
      the fixed title row. }
    property DefaultRowHeight: Integer read FDefaultRowHeight write SetDefaultRowHeight default 0;
    property TitleHeight: Integer read FTitleHeight write SetTitleHeight default 0;
    { When True (default) data-cell text is centred vertically in the row — the
      look the title row already uses — so taller rows keep the text mid-cell.
      False restores the stock DBGrid behaviour (text pinned near the top). }
    property CenterTextVertically: Boolean read FCenterTextVertically write SetCenterTextVertically default True;
    property FixedColor: TColor read FFixedColor write SetFixedColor default $F3F3F3;
    property FixedTextColor: TColor read FFixedTextColor write SetFixedTextColor default $202020;
    property CellHighlightColor: TColor read FCellHighlightColor write SetCellHighlightColor default $F0D9BE;
    property HighlightTextColor: TColor read FHighlightTextColor write SetHighlightTextColor default $202020;

    { Zebra striping. Off by default — every data cell then uses CellColor.
      Rows are numbered by record, from 1, so the first record is the odd one
      and the banding stays with the data while the grid scrolls. The title row,
      the indicator column and the selected row keep their own colors.

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
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;

    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnDrawColumnCell: TDrawColumnCellEvent read FOnDrawColumnCell write FOnDrawColumnCell;
    property OnDrawDataCell: TDrawDataCellEvent read FOnDrawDataCell write FOnDrawDataCell;
    property OnCellClick: TDBGridClickEvent read FOnCellClick write FOnCellClick;
    property OnTitleClick: TDBGridClickEvent read FOnTitleClick write FOnTitleClick;
    property OnColEnter: TNotifyEvent read FOnColEnter write FOnColEnter;
    property OnColExit: TNotifyEvent read FOnColExit write FOnColExit;
    property OnColumnMoved: TMovedEvent read FOnColumnMoved write FOnColumnMoved;
    property OnEditButtonClick: TNotifyEvent read FOnEditButtonClick write FOnEditButtonClick;
    property OnEnter: TNotifyEvent read FOnEnter write FOnEnter;
    property OnExit: TNotifyEvent read FOnExit write FOnExit;
    property OnKeyDown: TKeyEvent read FOnKeyDown write FOnKeyDown;
    property OnKeyUp: TKeyEvent read FOnKeyUp write FOnKeyUp;
    property OnKeyPress: TKeyPressEvent read FOnKeyPress write FOnKeyPress;
    property OnTopLeftChanged: TNotifyEvent read FOnTopLeftChanged write FOnTopLeftChanged;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseWheel: TMouseWheelEvent read FOnMouseWheel write FOnMouseWheel;
    property OnMouseWheelDown: TMouseWheelUpDownEvent read FOnMouseWheelDown write FOnMouseWheelDown;
    property OnMouseWheelUp: TMouseWheelUpDownEvent read FOnMouseWheelUp write FOnMouseWheelUp;
  end;

implementation

type
  { Cracker that exposes the parent's protected Color property. }
  TControlAccess = class(TControl);

{ TCWSInternalDBGrid }

constructor TCWSInternalDBGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOwner := TCWSDBGrid(AOwner);
  BorderStyle := bsNone;
  { Disable native scrollbars — the owner draws its own thin Fluent thumbs }
  ScrollBars := ssNone;
  DefaultDrawing := True;    // grid formats field text; we recolor + flatten
  DoubleBuffered := True;
  { Keep Ctl3D permanently off. Without ParentCtl3D := False, assigning the
    grid's Parent re-syncs Ctl3D from the (3D) parent control. Fixed cells are
    already kept flat by the DrawCell override (which bypasses the classic
    raised bevels in Vcl.DBGrids), but pin Ctl3D off too — consistent with
    TCWSStringGrid and a safety net if DefaultDrawing is ever changed. }
  ParentCtl3D := False;
  Ctl3D := False;
  DrawingStyle := gdsClassic;
  { Suppress the native (hardcoded silver/gray) grid lines and the classic
    raised fixed-cell bevel — the owner draws its own flat lines in
    GridLineColor, so the title row and indicator column stay perfectly flat,
    exactly like TCWSStringGrid. }
  GridLineWidth := 0;
end;

type
  { In-cell editor that mirrors the theme background/text colors. The stock
    TDBGridInplaceEdit keeps the color it had when first shown, so a cell being
    edited would keep the old light/dark color after a theme switch until the
    next mouse-over. Pulling the colors on show + on demand fixes that, while
    inheriting all the picklist / ellipsis-button behavior. }
  TCWSDBGridInplaceEdit = class(TDBGridInplaceEdit)
  protected
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
  public
    procedure RefreshColors;
  end;

procedure TCWSDBGridInplaceEdit.RefreshColors;
var
  Host: TCWSDBGrid;
begin
  if not (Grid is TCWSInternalDBGrid) then
    Exit;
  Host := TCWSInternalDBGrid(Grid).FOwner;
  if Host = nil then
    Exit;
  Color := Host.FCellColor;
  Font.Color := Host.FCellTextColor;
  if HandleAllocated then
    Invalidate;
end;

procedure TCWSDBGridInplaceEdit.CMShowingChanged(var Message: TMessage);
begin
  inherited;
  if Showing then
    RefreshColors;
end;

function TCWSInternalDBGrid.CreateEditor: TInplaceEdit;
begin
  Result := TCWSDBGridInplaceEdit.Create(Self);
end;

procedure TCWSInternalDBGrid.RefreshEditorColors;
begin
  if InplaceEditor is TCWSDBGridInplaceEdit then
    TCWSDBGridInplaceEdit(InplaceEditor).RefreshColors;
end;

function TCWSInternalDBGrid.CreateColumns: TDBGridColumns;
begin
  { Stock TCustomDBGrid builds a plain TDBGridColumns here. Swap in the
    notifying subclass so per-item edits reach the owner. }
  Result := TCWSDBGridColumns.Create(Self, TColumn);
end;

procedure TCWSInternalDBGrid.OwnerColumnsChanged;
begin
  if FOwner <> nil then
    FOwner.GridLayoutChanged;
end;

{ TCWSDBGridColumns }

procedure TCWSDBGridColumns.Update(Item: TCollectionItem);
begin
  { Let the grid do its normal work first (LayoutChanged for structural changes
    when Item = nil; a targeted column invalidate otherwise), then tell the
    owner to repaint — covering the per-item case the base class would handle
    too quietly for the owner-drawn Fluent surface to notice. }
  inherited Update(Item);
  if Grid is TCWSInternalDBGrid then
    TCWSInternalDBGrid(Grid).OwnerColumnsChanged;
end;

procedure TCWSInternalDBGrid.CreateParams(var Params: TCreateParams);
begin
  inherited;
  { No native scrollbars and no client edge — the owner draws the frame }
  Params.Style := Params.Style and not (WS_HSCROLL or WS_VSCROLL or WS_BORDER);
  Params.ExStyle := Params.ExStyle and not WS_EX_CLIENTEDGE;
end;

procedure TCWSInternalDBGrid.CreateWnd;
begin
  inherited;
  if FOwner <> nil then
    FOwner.UpdateGridRegion;
end;

procedure TCWSInternalDBGrid.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

procedure TCWSInternalDBGrid.DrawCell(ACol, ARow: Longint; ARect: TRect;
  AState: TGridDrawState);
var
  DataCol: Integer;
  Cap: string;
  Flags: Cardinal;
  R: TRect;
  Col: TColumn;
begin
  if FOwner = nil then
  begin
    inherited;
    Exit;
  end;

  if gdFixed in AState then
  begin
    { Flat title / indicator cell — never the 3D classic frame }
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := FOwner.FFixedColor;
    Canvas.FillRect(ARect);

    if (dgTitles in Options) and (ARow = 0) then
    begin
      DataCol := RawToDataColumn(ACol);
      if (DataCol >= 0) and (DataCol < Columns.Count) then
      begin
        Col := Columns[DataCol];
        Cap := Col.Title.Caption;
        if Cap <> '' then
        begin
          Canvas.Font := TitleFont;
          Canvas.Font.Color := FOwner.FFixedTextColor;
          SetBkMode(Canvas.Handle, TRANSPARENT);
          R := ARect;
          Inc(R.Left, FOwner.Scale(4));
          Dec(R.Right, FOwner.Scale(2));
          case Col.Title.Alignment of
            taRightJustify: Flags := DT_RIGHT;
            taCenter:       Flags := DT_CENTER;
          else
            Flags := DT_LEFT;
          end;
          DrawText(Canvas.Handle, PChar(Cap), -1, R,
            Flags or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX or DT_END_ELLIPSIS);
        end;
      end;
    end;

    FOwner.DrawGridLine(Canvas, ARect);
  end
  else
  begin
    { Data cell — let the grid map the record/field, then overlay our line.
      Remember the row: the base DrawCell routes into DrawColumnCell, which is
      not told which row it is painting but needs it for the zebra striping. }
    FDrawRow := ARow;
    inherited DrawCell(ACol, ARow, ARect, AState);
    FOwner.DrawGridLine(Canvas, ARect);
  end;
end;

function TCWSInternalDBGrid.DataRowNumber: Integer;
var
  DS: TDataSet;
begin
  { 1-based number of the data row being painted. The on-screen row is the
    fallback; when striping is on we prefer the record number, because the base
    DrawCell points the data link at the row's record before handing it to
    DrawColumnCell (that is how the column reads its field value). Numbering by
    record keeps the stripes glued to the data instead of to the window, so they
    don't flip every time the grid scrolls by one record. }
  Result := FDrawRow - FixedRows + 1;
  if (FOwner = nil) or not FOwner.FAlternatingRowColors then
    Exit;
  if DataSource = nil then
    Exit;
  DS := DataSource.DataSet;
  if (DS = nil) or not DS.Active or not DS.IsSequenced then
    Exit;
  if DS.RecNo > 0 then
    Result := DS.RecNo;
end;

procedure TCWSInternalDBGrid.DrawColumnCell(const Rect: TRect; DataCol: Integer;
  Column: TColumn; State: TGridDrawState);
var
  Bg, Tx: TColor;
begin
  if FOwner <> nil then
  begin
    if gdSelected in State then
    begin
      Bg := FOwner.FCellHighlightColor;
      Tx := FOwner.FHighlightTextColor;
    end
    else
    begin
      Bg := FOwner.RowBackColor(DataRowNumber);
      Tx := FOwner.FCellTextColor;
    end;
    { The default field painter fills + writes using the current canvas state }
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := Bg;
    Canvas.Font.Color := Tx;
  end;
  { Fires the owner's OnDrawColumnCell (or DefaultDrawColumnCell) — see Create }
  inherited DrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TCWSInternalDBGrid.UpdateScrollBar;
begin
  { The stock TDBGrid forces a native vertical scrollbar here via
    ShowScrollBar(SB_VERT, True). Suppress every native bar and let the owner
    paint its thin Fluent thumb instead — do NOT call inherited. }
  if HandleAllocated then
    ShowScrollBar(Handle, SB_BOTH, False);
  if FOwner <> nil then
    FOwner.GridContentChanged;
end;

procedure TCWSInternalDBGrid.Paint;
begin
  inherited;
  if FOwner <> nil then
    FOwner.GridContentChanged;
end;

procedure TCWSInternalDBGrid.TopLeftChanged;
begin
  inherited;
  if FOwner <> nil then
    FOwner.GridScrolled;
end;

procedure TCWSInternalDBGrid.LayoutChanged;
begin
  { DBGrid re-measures DefaultRowHeight (data rows, from Font) and RowHeights[0]
    (the title/fixed row, from TitleFont) on every layout pass. Let it finish,
    then re-impose any explicit override the owner has configured. }
  inherited;
  if FOwner <> nil then
  begin
    FOwner.ApplyRowHeights;
    { LayoutChanged fires whenever the column structure changes — columns added,
      removed, moved, resized, or rebuilt from the dataset's fields (e.g. after
      a query is opened). Tell the owner so it re-flows exactly like a stock
      DBGrid would, instead of waiting for the next paint or a scrollbar to
      appear/disappear. }
    FOwner.GridLayoutChanged;
  end;
end;

procedure TCWSInternalDBGrid.Click;
begin
  { Kept as a fallback for any programmatic / accessibility-driven Click. A DBGrid
    never reaches here on a mouse click: GridStyle lacks csClickEvents (so TControl
    won't auto-fire Click) and, unlike TCustomGrid, TCustomDBGrid overrides the
    mouse handlers without ever calling Click — it only raises CellClick/TitleClick.
    The owner's OnClick is therefore driven from MouseUp below. }
  inherited;
  if FOwner <> nil then
    FOwner.GridClicked;
end;

procedure TCWSInternalDBGrid.DblClick;
begin
  inherited;
  if FOwner <> nil then
    FOwner.GridDblClicked;
end;

procedure TCWSInternalDBGrid.DoEnter;
begin
  inherited;
  if FOwner <> nil then
    FOwner.GridEnter;
end;

procedure TCWSInternalDBGrid.DoExit;
begin
  inherited;
  if FOwner <> nil then
    FOwner.GridExit;
end;

procedure TCWSInternalDBGrid.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if FOwner <> nil then
  begin
    FOwner.UpdateFocusState;
    FOwner.GridMouseDown(Button, Shift, X, Y);
  end;
end;

procedure TCWSInternalDBGrid.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if FOwner <> nil then
  begin
    FOwner.UpdateScrollbarMetrics;
    { TCustomDBGrid never calls Click, so the owner's OnClick is driven here —
      the same place the grid itself raises CellClick/TitleClick. Left button
      only, mirroring a normal control's click. }
    if Button = mbLeft then
      FOwner.GridClicked;
    FOwner.GridMouseUp(Button, Shift, X, Y);
  end;
end;

procedure TCWSInternalDBGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if FOwner <> nil then
    FOwner.GridMouseMove(Shift, X, Y);
end;

procedure TCWSInternalDBGrid.CMMouseEnter(var Msg: TMessage);
begin
  inherited;
  if FOwner <> nil then
    FOwner.CompositeMouseEnter;
end;

procedure TCWSInternalDBGrid.CMMouseLeave(var Msg: TMessage);
begin
  inherited;
  if FOwner <> nil then
    FOwner.CompositeMouseCheckLeave;
end;

function TCWSInternalDBGrid.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
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

function TCWSInternalDBGrid.DoMouseWheelDown(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  Result := False;
  if FOwner <> nil then
    FOwner.GridMouseWheelDown(Shift, MousePos, Result);
  if not Result then
    Result := inherited DoMouseWheelDown(Shift, MousePos);
end;

function TCWSInternalDBGrid.DoMouseWheelUp(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  Result := False;
  if FOwner <> nil then
    FOwner.GridMouseWheelUp(Shift, MousePos, Result);
  if not Result then
    Result := inherited DoMouseWheelUp(Shift, MousePos);
end;

function TCWSInternalDBGrid.VisibleDataRows: Integer;
begin Result := VisibleRowCount; end;

function TCWSInternalDBGrid.VisibleDataCols: Integer;
begin Result := VisibleColCount; end;

function TCWSInternalDBGrid.TotalCols: Integer;
begin Result := ColCount; end;

function TCWSInternalDBGrid.FixedColCount: Integer;
begin Result := FixedCols; end;

function TCWSInternalDBGrid.LeftColumn: Integer;
begin Result := LeftCol; end;

procedure TCWSInternalDBGrid.SetLeftColumn(Value: Integer);
begin LeftCol := Value; end;

function TCWSInternalDBGrid.ColWidthPx(Index: Integer): Integer;
begin
  if (Index >= 0) and (Index < ColCount) then
    Result := ColWidths[Index]
  else
    Result := 0;
end;

function TCWSInternalDBGrid.GridClientWidth: Integer;
begin Result := ClientWidth; end;

{ TCWSDBGrid }

constructor TCWSDBGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csCaptureMouse, csClickEvents,
    csDoubleClicks, csOpaque];
  Width := 360;
  Height := 220;
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
  FDefaultRowHeight := 0;   // 0 = auto (data rows sized from Font)
  FTitleHeight := 0;        // 0 = auto (title row sized from TitleFont)
  FCenterTextVertically := True;
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

  FGrid := TCWSInternalDBGrid.Create(Self);
  FGrid.Parent := Self;
  FGrid.OnDrawColumnCell := GridDrawColumnCell;
  FGrid.OnDrawDataCell := GridDrawDataCell;
  FGrid.OnCellClick := GridCellClick;
  FGrid.OnTitleClick := GridTitleClick;
  FGrid.OnColEnter := GridColEnter;
  FGrid.OnColExit := GridColExit;
  FGrid.OnColumnMoved := GridColumnMoved;
  FGrid.OnEditButtonClick := GridEditButtonClick;
  FGrid.OnKeyDown := GridKeyDown;
  FGrid.OnKeyUp := GridKeyUp;
  FGrid.OnKeyPress := GridKeyPress;

  FRepeatTimer := TTimer.Create(Self);
  FRepeatTimer.Enabled := False;
  FRepeatTimer.OnTimer := RepeatTimerTick;

  ApplyColors;
end;

destructor TCWSDBGrid.Destroy;
begin
  if FRepeatTimer <> nil then
    FRepeatTimer.Enabled := False;
  { Sever every callback path from the internal grid before it (and our buffer)
    are torn down — the grid repaints / updates its scrollbar during teardown
    and must not reach back into a half-destroyed owner. }
  if FGrid <> nil then
  begin
    FGrid.FOwner := nil;
    FGrid.OnDrawColumnCell := nil;
    FGrid.OnDrawDataCell := nil;
    FGrid.OnCellClick := nil;
    FGrid.OnTitleClick := nil;
    FGrid.OnColEnter := nil;
    FGrid.OnColExit := nil;
    FGrid.OnColumnMoved := nil;
    FGrid.OnEditButtonClick := nil;
    FGrid.OnKeyDown := nil;
    FGrid.OnKeyUp := nil;
    FGrid.OnKeyPress := nil;
    FGrid.DataSource := nil;
  end;
  FreeAndNil(FBuffer);
  inherited;
end;

procedure TCWSDBGrid.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (FGrid <> nil) and
     not (csDestroying in ComponentState) and
     (AComponent = FGrid.DataSource) then
    { DataSource is going away — the grid clears itself; refresh our chrome }
    if HandleAllocated then
      PostMessage(Handle, CM_DBGRID_REFRESH, 0, 0);
end;

{ *** Scaling *** }

function TCWSDBGrid.Scale(Value: Integer): Integer;
begin
  Result := MulDiv(Value, CurrentPPI, 96);
end;

function TCWSDBGrid.ScaleF(Value: Single): Single;
begin
  Result := Value * CurrentPPI / 96;
end;

function TCWSDBGrid.GridInset: Integer;
begin
  Result := Scale(2);
end;

{ *** Data helpers *** }

function TCWSDBGrid.GetDataSet: TDataSet;
begin
  Result := nil;
  if (FGrid <> nil) and (FGrid.DataSource <> nil) then
    Result := FGrid.DataSource.DataSet;
end;

function TCWSDBGrid.VOverflow: Boolean;
var
  DS: TDataSet;
begin
  Result := False;
  if FGrid = nil then
    Exit;
  DS := GetDataSet;
  if (DS <> nil) and DS.Active and DS.IsSequenced then
    Result := DS.RecordCount > FGrid.VisibleDataRows;
end;

function TCWSDBGrid.HOverflow: Boolean;
begin
  { Pixel-based: the columns overflow when their total width exceeds the space
    left for them after the fixed columns. Counting columns is wrong here
    because DBGrid columns have independent widths. }
  Result := (FGrid <> nil) and
    (ScrollableTotalWidth > Max(1, FGrid.GridClientWidth - FixedWidth));
end;

function TCWSDBGrid.ScrollableTotalWidth: Integer;
var
  I: Integer;
begin
  Result := 0;
  if FGrid = nil then
    Exit;
  for I := FGrid.FixedColCount to FGrid.TotalCols - 1 do
    Inc(Result, FGrid.ColWidthPx(I));
end;

function TCWSDBGrid.FixedWidth: Integer;
var
  I: Integer;
begin
  Result := 0;
  if FGrid = nil then
    Exit;
  for I := 0 to FGrid.FixedColCount - 1 do
    Inc(Result, FGrid.ColWidthPx(I));
end;

function TCWSDBGrid.ScrolledOffWidth: Integer;
var
  I: Integer;
begin
  Result := 0;
  if FGrid = nil then
    Exit;
  { Total width of the scrollable columns currently scrolled off to the left }
  for I := FGrid.FixedColCount to FGrid.LeftColumn - 1 do
    Inc(Result, FGrid.ColWidthPx(I));
end;

procedure TCWSDBGrid.FitColumnsToWidth;
var
  I, Pass: Integer;
  AvailableWidth, ColWidth, Target: Integer;
  FlexCount, LastVisible: Integer;
  Changed: Boolean;
begin
  { Distribute the data area evenly across the visible columns. The fixed
    (indicator) columns keep their width. The native GridLineWidth is 0 — the
    flat lines are painted inside the cells by DrawGridLine — so the visible
    column widths sum exactly to the grid's client width and no per-line
    correction is needed. The last visible column absorbs the remainder of the
    integer division.

    Skipped at design time: assigning Width would promote auto-generated
    (csDefault) columns to customised ones, which StoreColumns would then
    stream to the DFM — suppressing the automatic field-based columns (see the
    StoreColumns comment). }
  if (FGrid = nil) or FFittingColumns or
     (csDesigning in ComponentState) or (csDestroying in ComponentState) then
    Exit;
  if FGrid.Columns.Count = 0 then
    Exit;

  FFittingColumns := True;
  try
    { Re-flow the chrome BEFORE measuring, then fit to the grid's real client
      width — the same value HOverflow compares against. This is what makes the
      fit account for the vertical scrollbar: once UpdateGridPosition has carved
      out the vertical strip, GridClientWidth is already the width left of the
      thumb, so the columns stop short of it instead of sliding under it and
      spawning a needless horizontal scrollbar.

      Looped because the fit and the chrome are mutually dependent: narrowing the
      columns can clear the horizontal overflow (removing the bottom strip, which
      frees vertical space) and a vertical strip appearing/leaving changes the
      width again. Each pass re-settles the chrome first, so a stale (not-yet-
      narrowed) client width can never leak into the column math. Converges in
      two passes; the third is a safety margin. }
    for Pass := 1 to 3 do
    begin
      UpdateGridPosition;

      FlexCount := 0;
      LastVisible := -1;
      for I := 0 to FGrid.Columns.Count - 1 do
        if FGrid.Columns[I].Visible then
        begin
          Inc(FlexCount);
          LastVisible := I;
        end;
      if FlexCount = 0 then
        Exit;

      AvailableWidth := FGrid.GridClientWidth - FixedWidth;
      if AvailableWidth < FlexCount then
        Exit;

      ColWidth := AvailableWidth div FlexCount;

      { Assign only what actually changes — every TColumn.Width write fires
        Columns.Update, and an idle re-fit (e.g. from CMRefreshLayout with
        AutoFitColumns on) must produce no Update at all, or the posted
        CM_DBGRID_REFRESH would ping-pong forever. }
      Changed := False;
      for I := 0 to FGrid.Columns.Count - 1 do
        if FGrid.Columns[I].Visible then
        begin
          if I = LastVisible then
            Target := AvailableWidth - ColWidth * (FlexCount - 1)
          else
            Target := ColWidth;
          if FGrid.Columns[I].Width <> Target then
          begin
            FGrid.Columns[I].Width := Target;
            Changed := True;
          end;
        end;

      { Stable once a pass changes nothing — the columns already fill the client
        width left of the (now reserved) vertical strip. }
      if not Changed then
        Break;
    end;

    { Final settle so the chrome reflects the last column write. }
    UpdateGridPosition;
  finally
    FFittingColumns := False;
  end;
end;

function TCWSDBGrid.ColIndexForOffset(TargetPx: Integer): Integer;
var
  I, Acc, FixedC, ColC, W: Integer;
begin
  { Map a pixel offset (width scrolled off the left) to the scrollable column
    whose left edge is nearest — so the thumb snaps to whole columns the way
    DBGrid actually scrolls. }
  FixedC := FGrid.FixedColCount;
  ColC := FGrid.TotalCols;
  Acc := 0;
  Result := FixedC;
  for I := FixedC to ColC - 1 do
  begin
    W := FGrid.ColWidthPx(I);
    if TargetPx < Acc + (W div 2) then
    begin
      Result := I;
      Exit;
    end;
    Inc(Acc, W);
    Result := I + 1;
  end;
  if Result > ColC - 1 then Result := ColC - 1;
  if Result < FixedC then Result := FixedC;
end;

{ *** Color application *** }

procedure TCWSDBGrid.ApplyColors;
begin
  if FGrid = nil then
    Exit;
  { Color fills only the area beyond the last row/column — acts as the grid
    background, the same role it plays in TCWSStringGrid. }
  FGrid.Color := FBackgroundColor;
  { Keep a cell currently being edited in sync with the new theme colors. }
  FGrid.RefreshEditorColors;
  FGrid.Invalidate;
  Invalidate;
end;

function TCWSDBGrid.AlternateShade(ABase: TColor): TColor;
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

function TCWSDBGrid.RowBackColor(ARowNumber: Integer): TColor;
begin
  { Background of a data row: plain CellColor unless zebra striping is on, in
    which case the 1-based row number decides — so the first row is the odd one.
    clNone on either band means "follow CellColor" (see the property comment). }
  if not FAlternatingRowColors then
    Exit(FCellColor);
  if Odd(ARowNumber) then
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

procedure TCWSDBGrid.DrawGridLine(C: TCanvas; const R: TRect);
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

procedure TCWSDBGrid.GetVMetrics(out Total, Visible, First: Integer);
var
  DS: TDataSet;
begin
  Total := 0;
  Visible := 1;
  First := 0;
  DS := GetDataSet;
  if (DS <> nil) and DS.Active and DS.IsSequenced then
  begin
    Total := DS.RecordCount;
    Visible := FGrid.VisibleDataRows;
    { A DBGrid is a live window onto its dataset and has no independent "top row"
      to set — it only tracks the active record. So, exactly like the stock
      Vcl.DBGrid scrollbar (nPos := RecNo), the vertical position is the active
      record's index. This keeps the thumb, the mouse wheel (MoveBy ±1) and the
      thumb drag (RecNo := track position) all driven by the same value and thus
      perfectly consistent. First therefore ranges 0 .. Total - 1. }
    First := DS.RecNo - 1;
  end;
  if First < 0 then First := 0;
  if Total < 0 then Total := 0;
  if Visible < 1 then Visible := 1;
end;

procedure TCWSDBGrid.GetHMetrics(out Total, Visible, First: Integer);
begin
  { Pixel units: Total = sum of scrollable column widths, Visible = pixels
    available for them, First = pixels currently scrolled off the left. This
    keeps the thumb a constant size regardless of which (differently sized)
    columns happen to be on screen. }
  Total := ScrollableTotalWidth;
  Visible := Max(1, FGrid.GridClientWidth - FixedWidth);
  First := ScrolledOffWidth;
  if First < 0 then First := 0;
  if Total < 0 then Total := 0;
  if Visible < 1 then Visible := 1;
end;

function TCWSDBGrid.HScrollMax: Integer;
var
  Total, Visible, Last, Fixed, I, J, Tail, MaxLeft: Integer;
begin
  { Largest scroll offset (in pixels, snapped to a column boundary) that the
    grid can actually reach. DBGrid scrolls by whole columns via LeftCol and
    clamps it so the rightmost columns sit flush against the right edge; it
    will not scroll past LeftCol = last column. So the reachable maximum is the
    width scrolled off when LeftCol sits at that stop — NOT Total - Visible.

    When the last column is wider than the visible area, that stop is reached
    with LeftCol = last column, i.e. MaxOff = Total - LastColWidth, which is
    smaller than Total - Visible. Using Total - Visible as the range left the
    thumb unable to travel to the right rail — this returns the true maximum so
    the thumb reaches the end exactly when the grid is scrolled as far right as
    a DBGrid allows. }
  Result := 0;
  if FGrid = nil then
    Exit;
  Total := ScrollableTotalWidth;
  Visible := Max(1, FGrid.GridClientWidth - FixedWidth);
  if Total <= Visible then
    Exit;

  Fixed := FGrid.FixedColCount;
  Last := FGrid.TotalCols - 1;
  if Last < Fixed then
    Exit;

  { Leftmost scrollable column whose tail (that column .. last) fits in Visible;
    that is the flush-right stop. If none fits — an oversized trailing column —
    fall back to LeftCol = last column. }
  MaxLeft := Last;
  for I := Fixed to Last do
  begin
    Tail := 0;
    for J := I to Last do
      Inc(Tail, FGrid.ColWidthPx(J));
    if Tail <= Visible then
    begin
      MaxLeft := I;
      Break;
    end;
  end;

  for I := Fixed to MaxLeft - 1 do
    Inc(Result, FGrid.ColWidthPx(I));
end;

procedure TCWSDBGrid.ScrollVToRec(RecIndex: Integer);
var
  Total: Integer;
  DS: TDataSet;
begin
  { Absolute positioning for the scrollbar thumb — mirrors the stock Vcl.DBGrid
    WMVScroll thumb handler exactly:

        if nTrackPos <= 1        then First
        else if nTrackPos >= RecordCount then Last
        else RecNo := nTrackPos

    Setting RecNo (rather than MoveBy) triggers the dataset's Resync, which
    re-fills the link buffer around the new record. That buffer fill is what
    parks the active (highlighted) record near the TOP of the page when the
    thumb is up high, in the MIDDLE when it is mid-track and at the BOTTOM when
    it is down low — the three-position selection scheme of a real DBGrid. The
    edge cases (First / Last) pin the selection flush to the first / last row. }
  DS := GetDataSet;
  if (DS = nil) or not DS.Active or not DS.IsSequenced then
    Exit;
  Total := DS.RecordCount;
  try
    if RecIndex + 1 <= 1 then
      DS.First
    else if RecIndex + 1 >= Total then
      DS.Last
    else
      DS.RecNo := RecIndex + 1;
  except
    { datasets that misreport IsSequenced — ignore the navigation request }
  end;
end;

procedure TCWSDBGrid.ScrollVBy(Delta: Integer);
var
  DS: TDataSet;
begin
  { Relative step for line / page scrolling — mirrors the stock DBGrid line and
    page codes (MoveBy ±1 / ±VisibleRowCount). Unlike the thumb, this keeps the
    active record and lets it ride with the content, pinning to the edge it
    leaves, exactly like wheeling or arrowing. }
  DS := GetDataSet;
  if (DS = nil) or not DS.Active or not DS.IsSequenced then
    Exit;
  if Delta <> 0 then
    try
      DS.MoveBy(Delta);
    except
      { datasets that misreport IsSequenced — ignore the navigation request }
    end;
end;

procedure TCWSDBGrid.ScrollHTo(FirstPx: Integer);
begin
  { FirstPx is a desired pixel offset (width scrolled off the left). Clamp it to
    the reachable range (HScrollMax, snapped to a column boundary), then snap to
    the nearest column. DBGrid scrolls by whole columns and won't move past the
    last-column stop, so clamping to HScrollMax (not Total - Visible) lets the
    thumb's far-right position map onto that final column. }
  FGrid.SetLeftColumn(ColIndexForOffset(Max(0, Min(HScrollMax, FirstPx))));
end;

procedure TCWSDBGrid.ScrollHByPage(Dir: Integer);
var
  Total, Visible, First: Integer;
begin
  { Page horizontally by one visible width, toward Dir (-1 left, +1 right). }
  GetHMetrics(Total, Visible, First);
  ScrollHTo(First + Dir * Visible);
end;

{ *** Track-click auto-repeat *** }

procedure TCWSDBGrid.DoTrackPage;
var
  Total, Visible, First: Integer;
begin
  { One page step in the stored repeat direction. }
  if FRepeatVert then
  begin
    GetVMetrics(Total, Visible, First);
    ScrollVBy(FRepeatDir * Max(1, Visible));
  end
  else
    ScrollHByPage(FRepeatDir);
end;

procedure TCWSDBGrid.StartTrackRepeat(Vert: Boolean; Dir: Integer);
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

procedure TCWSDBGrid.StopTrackRepeat;
begin
  FRepeatActive := False;
  if FRepeatTimer <> nil then
    FRepeatTimer.Enabled := False;
end;

procedure TCWSDBGrid.RepeatTimerTick(Sender: TObject);
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

procedure TCWSDBGrid.UpdateGridPosition;
var
  Inset, L, T, SBW, GridRight, GridBottom: Integer;
  WantV, WantH, NeedV, NeedH: Boolean;
begin
  if (FGrid = nil) or FUpdatingLayout then
    Exit;
  FUpdatingLayout := True;
  try
    Inset := GridInset;
    L := Inset;
    T := Inset;
    SBW := Scale(FScrollbarAreaWidth);

    WantV := FScrollBars in [ssVertical, ssBoth];
    WantH := FScrollBars in [ssHorizontal, ssBoth];

    { Provisional full-area bounds so the grid can report visible row/col counts }
    FGrid.SetBounds(L, T, Max(10, Width - 2 * Inset), Max(10, Height - 2 * Inset));

    NeedV := WantV and VOverflow;
    NeedH := WantH and HOverflow;

    if NeedV then
      GridRight := Width - Inset - SBW
    else
      GridRight := Width - Inset;
    if NeedH then
      GridBottom := Height - Inset - SBW
    else
      GridBottom := Height - Inset;

    FGrid.SetBounds(L, T, Max(10, GridRight - L), Max(10, GridBottom - T));

    { Re-check after the shrink — fewer rows/cols may now fit }
    NeedV := WantV and VOverflow;
    NeedH := WantH and HOverflow;

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
  finally
    FUpdatingLayout := False;
  end;
end;

procedure TCWSDBGrid.UpdateGridRegion;
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
    SetWindowRgn(FGrid.Handle, 0, True);
    Exit;
  end;

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
        SetWindowRgn(FGrid.Handle, Rgn, True);
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

procedure TCWSDBGrid.UpdateScrollbarMetrics;
var
  Total, Visible, First, TrackTop, TrackBottom, TrackH, ThumbH, ThumbP,
  ThumbW, CenterX: Integer;
  TrackLeft, TrackRight, TrackW, HThumbW, HThumbP, HThumbH, CenterY: Integer;
  HMax: Integer;
  WantV, WantH: Boolean;
begin
  if (FGrid = nil) or not FGrid.HandleAllocated then
    Exit;

  WantV := FVTrackRect.Width > 0;
  WantH := FHTrackRect.Height > 0;

  { Vertical }
  if WantV then
  begin
    GetVMetrics(Total, Visible, First);
    FVScrollVisible := Total > Visible;
    if FVScrollVisible then
    begin
      { While a non-thumb-tracking drag is held the thumb floats at the cursor
        (FVDragPos) without moving the dataset — the dataset only catches up on
        release, exactly like the native scrollbar with dgThumbTracking off. }
      if FVDragging and not (dgThumbTracking in FGrid.Options) then
        First := FVDragPos;
      TrackTop := FVTrackRect.Top + Scale(4);
      TrackBottom := FVTrackRect.Bottom - Scale(4);
      TrackH := TrackBottom - TrackTop;
      ThumbH := Max(Scale(20), Round(TrackH * (Visible / Total)));
      { Position tracks the active record (First = RecNo - 1, range 0..Total-1),
        so the thumb reaches the bottom rail exactly when the last record is
        current — matching Vcl.DBGrid (nPos := RecNo). }
      if Total > 1 then
        ThumbP := TrackTop + Round((First / (Total - 1)) * (TrackH - ThumbH))
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
      TrackLeft := FHTrackRect.Left + Scale(4);
      TrackRight := FHTrackRect.Right - Scale(4);
      TrackW := TrackRight - TrackLeft;
      HThumbW := Max(Scale(20), Round(TrackW * (Visible / Total)));
      { Position is relative to the *reachable* maximum offset (HScrollMax), not
        Total - Visible. With a column wider than the view that maximum is
        smaller, so dividing by it lets the thumb reach the right rail when the
        grid is scrolled as far as DBGrid permits. }
      HMax := HScrollMax;
      if HMax > 0 then
        HThumbP := TrackLeft + Round((Min(First, HMax) / HMax) * (TrackW - HThumbW))
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

procedure TCWSDBGrid.GridScrolled;
begin
  UpdateScrollbarMetrics;
  Invalidate;
  if Assigned(FOnTopLeftChanged) then
    FOnTopLeftChanged(Self);
end;

procedure TCWSDBGrid.GridContentChanged;
var
  NeedV, NeedH: Boolean;
begin
  if (csDestroying in ComponentState) or not HandleAllocated then
    Exit;
  { Called very often — from the internal grid's Paint and UpdateScrollBar.
    Refresh the thin thumb cheaply every time, but only schedule a full
    re-layout (which calls SetBounds + SetWindowRgn and would otherwise tear
    down an open inplace editor) when a scrollbar actually has to appear or
    disappear. }
  UpdateScrollbarMetrics;
  Invalidate;

  NeedV := (FScrollBars in [ssVertical, ssBoth]) and VOverflow;
  NeedH := (FScrollBars in [ssHorizontal, ssBoth]) and HOverflow;
  if ((NeedV <> (FVTrackRect.Width > 0)) or (NeedH <> (FHTrackRect.Height > 0)))
     and not FRefreshPosted then
  begin
    FRefreshPosted := True;
    PostMessage(Handle, CM_DBGRID_REFRESH, 0, 0);
  end;
end;

procedure TCWSDBGrid.CMRefreshLayout(var Msg: TMessage);
begin
  FRefreshPosted := False;
  UpdateGridPosition;
  if FAutoFitColumns then
    FitColumnsToWidth;
  if FGrid <> nil then
    FGrid.Invalidate;
  Invalidate;
end;

procedure TCWSDBGrid.GridLayoutChanged;
begin
  { A structural change in the grid: columns added, removed, moved, resized, or
    rebuilt from the dataset's fields. Mirror a stock DBGrid — re-flow the whole
    control (scrollbar geometry + visible row/col counts) and repaint both the
    data surface and the Fluent chrome, so edits in the Columns editor and the
    columns generated when a query is opened show up immediately.

    Done deferred + coalesced through CM_DBGRID_REFRESH: a burst of column edits
    collapses into a single relayout, and the FUpdatingLayout guard stops the
    SetBounds calls inside UpdateGridPosition (which themselves fire
    LayoutChanged) from recursing back in here. }
  if (csDestroying in ComponentState) or not HandleAllocated then
    Exit;
  if FUpdatingLayout then
    Exit;
  if FGrid <> nil then
    FGrid.Invalidate;
  if not FRefreshPosted then
  begin
    FRefreshPosted := True;
    PostMessage(Handle, CM_DBGRID_REFRESH, 0, 0);
  end;
end;

procedure TCWSDBGrid.ApplyRowHeights;
var
  AutoTitle: Integer;
begin
  { Re-impose the owner's explicit row heights after DBGrid's auto sizing.
    Data rows share DefaultRowHeight; the fixed title row keeps its own
    RowHeights[0], so the two are independent. Heights are stored in logical
    pixels and scaled to the current PPI here. Same-unit visibility lets us
    reach the grid's protected DefaultRowHeight / FixedRows. }
  if (FGrid = nil) or (csDestroying in ComponentState) then
    Exit;
  if (FDefaultRowHeight <= 0) and (FTitleHeight <= 0) then
    Exit;

  if FDefaultRowHeight > 0 then
  begin
    { Assigning DefaultRowHeight clears every per-row height, so capture the
      auto-measured title first and restore it unless the user overrode it. }
    if FGrid.FixedRows > 0 then
      AutoTitle := FGrid.RowHeights[0]
    else
      AutoTitle := 0;
    if FGrid.DefaultRowHeight <> Scale(FDefaultRowHeight) then
      FGrid.DefaultRowHeight := Scale(FDefaultRowHeight);
    if (FTitleHeight <= 0) and (FGrid.FixedRows > 0) and (AutoTitle > 0) and
       (FGrid.RowHeights[0] <> AutoTitle) then
      FGrid.RowHeights[0] := AutoTitle;
  end;

  if (FTitleHeight > 0) and (FGrid.FixedRows > 0) and
     (FGrid.RowHeights[0] <> Scale(FTitleHeight)) then
    FGrid.RowHeights[0] := Scale(FTitleHeight);
end;

{ *** Buffer / painting *** }

procedure TCWSDBGrid.EnsureBuffer;
begin
  if (FBuffer.Width <> Width) or (FBuffer.Height <> Height) then
    FBuffer.SetSize(Width, Height);
end;

function TCWSDBGrid.GetParentBgColor: TColor;
begin
  if Parent <> nil then
    Result := TControlAccess(Parent).Color
  else
    Result := clBtnFace;
end;

procedure TCWSDBGrid.DrawParentBackground(DC: HDC; ARadius: Single);
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

function TCWSDBGrid.MakeGPColor(AColor: TColor; Alpha: Byte): Cardinal;
var
  C: TColor;
begin
  C := ColorToRGB(AColor);
  Result := Winapi.GDIPAPI.MakeColor(Alpha, GetRValue(C), GetGValue(C), GetBValue(C));
end;

function TCWSDBGrid.CreateBorderPath(X, Y, W, H, R: Single;
  TL, TR, BR, BL: Boolean): TGPGraphicsPath;
var
  D: Single;
begin
  Result := TGPGraphicsPath.Create;
  D := R * 2;
  if D > H then D := H;
  if D > W then D := W;
  if D < 0 then D := 0;

  if TL and (D > 0) then
    Result.AddArc(X, Y, D, D, 180, 90)
  else
    Result.AddLine(X, Y, X, Y);
  if TR and (D > 0) then
    Result.AddArc(X + W - D, Y, D, D, 270, 90)
  else
    Result.AddLine(X + W, Y, X + W, Y);
  if BR and (D > 0) then
    Result.AddArc(X + W - D, Y + H - D, D, D, 0, 90)
  else
    Result.AddLine(X + W, Y + H, X + W, Y + H);
  if BL and (D > 0) then
    Result.AddArc(X, Y + H - D, D, D, 90, 90)
  else
    Result.AddLine(X, Y + H, X, Y + H);

  Result.CloseFigure;
end;

function TCWSDBGrid.CreateRoundRectPath(X, Y, W, H, R: Single): TGPGraphicsPath;
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

procedure TCWSDBGrid.PaintToBuffer;
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
  if (FBuffer = nil) or (csDestroying in ComponentState) then
    Exit;
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

procedure TCWSDBGrid.WMPaint(var Msg: TWMPaint);
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
    if FBuffer <> nil then
      BitBlt(DC, 0, 0, Width, Height, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  finally
    EndPaint(Handle, PS);
  end;
end;

procedure TCWSDBGrid.Paint;
begin
  PaintToBuffer;
  if FBuffer <> nil then
    { Our public Canvas now points at the inner grid's canvas, so blit the
      composed buffer onto this control's OWN canvas (TCustomControl.Canvas). }
    inherited Canvas.Draw(0, 0, FBuffer);
end;

procedure TCWSDBGrid.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

{ *** Mouse — scrollbars *** }

procedure TCWSDBGrid.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  P: TPoint;
  Total, Visible, First: Integer;
begin
  inherited;
  { Mouse events over the grid body reach the inner grid; those over our own
    chrome (border / custom scrollbars) reach here. Surface both as OnMouseDown. }
  if Assigned(FOnMouseDown) then
    FOnMouseDown(Self, Button, Shift, X, Y);
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
      begin
        { Clicking the track pages toward the click — MoveBy(±VisibleRowCount),
          exactly like the stock Vcl.DBGrid (SB_PAGEUP / SB_PAGEDOWN) — and holding
          the button keeps paging until the thumb reaches the cursor. }
        if P.Y < FVThumbRect.Top then
          StartTrackRepeat(True, -1)
        else
          StartTrackRepeat(True, 1);
      end;
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
      end
      else
        { Page toward the click and keep paging while the button is held. }
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

procedure TCWSDBGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
  Total, Visible, First, TrackTop, TrackBottom, TrackH, ThumbH, MaxScroll: Integer;
  TrackLeft, TrackRight, TrackW, ThumbW: Integer;
  WasV, WasH: Boolean;
begin
  inherited;
  { A move over our own chrome also primes composite-enter (e.g. the cursor
    appears directly over the border without crossing the grid first). }
  CompositeMouseEnter;
  if Assigned(FOnMouseMove) then
    FOnMouseMove(Self, Shift, X, Y);
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
    { Vertical thumb travel spans the whole record range (0 .. Total - 1) because
      the position tracks the active record, just like Vcl.DBGrid. }
    MaxScroll := Max(0, Total - 1);
    TrackTop := FVTrackRect.Top + Scale(4);
    TrackBottom := FVTrackRect.Bottom - Scale(4);
    TrackH := TrackBottom - TrackTop;
    ThumbH := FVThumbRect.Height;
    if (TrackH - ThumbH) > 0 then
    begin
      First := FVDragStartRow + Round(((Y - FVDragStartY) / (TrackH - ThumbH)) * MaxScroll);
      First := Max(0, Min(MaxScroll, First));
      if dgThumbTracking in FGrid.Options then
        ScrollVToRec(First)         { live — the dataset follows the thumb }
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
    MaxScroll := HScrollMax;
    TrackLeft := FHTrackRect.Left + Scale(4);
    TrackRight := FHTrackRect.Right - Scale(4);
    TrackW := TrackRight - TrackLeft;
    ThumbW := FHThumbRect.Width;
    if (TrackW - ThumbW) > 0 then
      ScrollHTo(FHDragStartCol + Round(((X - FHDragStartX) / (TrackW - ThumbW)) * MaxScroll));
  end;
end;

procedure TCWSDBGrid.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if Assigned(FOnMouseUp) then
    FOnMouseUp(Self, Button, Shift, X, Y);
  { End any track-click auto-repeat the moment the button is released. }
  StopTrackRepeat;
  if FVDragging then
  begin
    { With dgThumbTracking off the dataset hasn't moved during the drag — catch
      it up to where the thumb was released, mirroring SB_THUMBPOSITION. }
    if not (dgThumbTracking in FGrid.Options) then
      ScrollVToRec(FVDragPos);
    FVDragging := False;
    FVAreaHovered := FVTrackRect.Contains(Point(X, Y));
    UpdateScrollbarMetrics;
  end;
  if FHDragging then
  begin
    FHDragging := False;
    FHAreaHovered := FHTrackRect.Contains(Point(X, Y));
    UpdateScrollbarMetrics;
  end;
  Invalidate;
end;

function TCWSDBGrid.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  { The scrollbar strip is part of this outer window (the inner grid is inset),
    so the wheel is dispatched here when the cursor is over it. Delegate to the
    inner grid, which scrolls the data and fires OnMouseWheel exactly as it does
    when hovered directly. }
  if (FGrid <> nil) and FGrid.HandleAllocated then
    Result := FGrid.DoMouseWheel(Shift, WheelDelta, MousePos)
  else
    Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);
end;

{ *** Lifecycle *** }

procedure TCWSDBGrid.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_CLIPCHILDREN;
end;

procedure TCWSDBGrid.CreateWnd;
begin
  inherited;
  UpdateGridPosition;
  SyncGridFont;
end;

procedure TCWSDBGrid.Loaded;
begin
  inherited;
  ApplyColors;
  UpdateGridPosition;
  SyncGridFont;
end;

procedure TCWSDBGrid.Resize;
begin
  inherited;
  UpdateGridPosition;
  { UpdateGridPosition holds FUpdatingLayout, so the LayoutChanged fired by its
    SetBounds never reaches GridLayoutChanged — re-fit explicitly here. }
  if FAutoFitColumns then
    FitColumnsToWidth;
end;

procedure TCWSDBGrid.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited;
  if FBuffer <> nil then
    FBuffer.SetSize(0, 0);
  SyncGridFont;
  UpdateGridPosition;
end;

procedure TCWSDBGrid.CMPPIChanged(var Msg: TMessage);
begin
  inherited;
  if FBuffer <> nil then
    FBuffer.SetSize(0, 0);
  SyncGridFont;
  UpdateGridPosition;
  Invalidate;
end;

procedure TCWSDBGrid.SetFocus;
begin
  if (FGrid <> nil) and FGrid.CanFocus then
    FGrid.SetFocus
  else
    inherited;
end;

procedure TCWSDBGrid.WMSetFocus(var Msg: TWMSetFocus);
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

procedure TCWSDBGrid.SyncGridFont;
begin
  if FGrid <> nil then
  begin
    FGrid.Font := Font;
    FGrid.Invalidate;
  end;
end;

procedure TCWSDBGrid.UpdateFocusState;
begin
  FFocused := True;
  Invalidate;
end;

procedure TCWSDBGrid.GridClicked;
begin
  UpdateScrollbarMetrics;
  Invalidate;
  if Assigned(FOnClick) then
    FOnClick(Self);
end;

procedure TCWSDBGrid.GridDblClicked;
begin
  if Assigned(FOnDblClick) then
    FOnDblClick(Self);
end;

procedure TCWSDBGrid.GridEnter;
begin
  { The internal grid is the control that actually receives focus (SetFocus
    redirects to it), so surface its focus transitions as the owner's. }
  FFocused := True;
  Invalidate;
  if Assigned(FOnEnter) then
    FOnEnter(Self);
end;

procedure TCWSDBGrid.GridExit;
begin
  FFocused := False;
  Invalidate;
  if Assigned(FOnExit) then
    FOnExit(Self);
end;

procedure TCWSDBGrid.GridMouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  { Coordinates arrive relative to the inner grid; translate to the owner so the
    handler sees positions in the composite control's own client space. }
  if Assigned(FOnMouseDown) then
    FOnMouseDown(Self, Button, Shift, X + FGrid.Left, Y + FGrid.Top);
end;

procedure TCWSDBGrid.GridMouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if Assigned(FOnMouseUp) then
    FOnMouseUp(Self, Button, Shift, X + FGrid.Left, Y + FGrid.Top);
end;

procedure TCWSDBGrid.GridMouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseMove) then
    FOnMouseMove(Self, Shift, X + FGrid.Left, Y + FGrid.Top);
end;

procedure TCWSDBGrid.GridMouseWheelDown(Shift: TShiftState; MousePos: TPoint;
  var Handled: Boolean);
begin
  if Assigned(FOnMouseWheelDown) then
    FOnMouseWheelDown(Self, Shift, MousePos, Handled);
end;

procedure TCWSDBGrid.GridMouseWheelUp(Shift: TShiftState; MousePos: TPoint;
  var Handled: Boolean);
begin
  if Assigned(FOnMouseWheelUp) then
    FOnMouseWheelUp(Self, Shift, MousePos, Handled);
end;

procedure TCWSDBGrid.CompositeMouseEnter;
begin
  { The owner and the inner grid are distinct windows, so VCL fires its own
    enter/leave for each as the cursor crosses between them. Collapse both into
    a single MouseEnter/MouseLeave for the whole composite via FMouseInside. }
  if not FMouseInside then
  begin
    FMouseInside := True;
    if Assigned(FOnMouseEnter) then
      FOnMouseEnter(Self);
  end;
end;

procedure TCWSDBGrid.CompositeMouseCheckLeave;
var
  P: TPoint;
begin
  if not FMouseInside then
    Exit;
  { Only a real exit from the whole control counts — moving from the chrome onto
    the grid (or vice-versa) keeps the cursor inside our client rect. }
  P := ScreenToClient(Mouse.CursorPos);
  if not ClientRect.Contains(P) then
  begin
    FMouseInside := False;
    if Assigned(FOnMouseLeave) then
      FOnMouseLeave(Self);
  end;
end;

{ *** Grid event handlers *** }

procedure TCWSDBGrid.GridDrawDataCell(Sender: TObject; const Rect: TRect;
  Field: TField; State: TGridDrawState);
begin
  { Legacy per-field draw event — the grid only raises it when Columns.State is
    csDefault. Forward it unchanged for code that still uses the old style. }
  if Assigned(FOnDrawDataCell) then
    FOnDrawDataCell(Self, Rect, Field, State);
end;

procedure TCWSDBGrid.GridDrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  { Because we always assign this handler, the grid never auto-calls
    DefaultDrawColumnCell — do it ourselves unless the user took over. }
  if Assigned(FOnDrawColumnCell) then
    FOnDrawColumnCell(Self, Rect, DataCol, Column, State)
  else if FCenterTextVertically then
    DrawColumnCellCentered(Rect, Column)
  else
    FGrid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TCWSDBGrid.DrawColumnCellCentered(const Rect: TRect; Column: TColumn);
var
  Cv: TCanvas;
  S: string;
  R: TRect;
  Flags: Cardinal;
begin
  { Brush + font colours were already set by the internal grid's DrawColumnCell.
    Fill the whole cell (this also covers the grid's own top-aligned default
    text drawn underneath when DefaultDrawing is on), then draw the field text
    vertically centred — matching the title row's DT_VCENTER look. }
  Cv := FGrid.Canvas;
  Cv.Brush.Style := bsSolid;
  Cv.FillRect(Rect);

  S := '';
  if Assigned(Column.Field) then
    S := Column.Field.DisplayText;
  if S = '' then
    Exit;

  R := Rect;
  Inc(R.Left, Scale(3));
  Dec(R.Right, Scale(3));
  case Column.Alignment of
    taRightJustify: Flags := DT_RIGHT;
    taCenter:       Flags := DT_CENTER;
  else
    Flags := DT_LEFT;
  end;
  SetBkMode(Cv.Handle, TRANSPARENT);
  DrawText(Cv.Handle, PChar(S), -1, R,
    Flags or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX or DT_END_ELLIPSIS);
end;

procedure TCWSDBGrid.SetCenterTextVertically(const Value: Boolean);
begin
  if FCenterTextVertically <> Value then
  begin
    FCenterTextVertically := Value;
    if FGrid <> nil then
      FGrid.Invalidate;
    Invalidate;
  end;
end;

procedure TCWSDBGrid.GridCellClick(Column: TColumn);
begin
  if Assigned(FOnCellClick) then
    FOnCellClick(Column);
end;

procedure TCWSDBGrid.GridTitleClick(Column: TColumn);
begin
  if Assigned(FOnTitleClick) then
    FOnTitleClick(Column);
end;

procedure TCWSDBGrid.GridColEnter(Sender: TObject);
begin
  if Assigned(FOnColEnter) then
    FOnColEnter(Self);
end;

procedure TCWSDBGrid.GridColExit(Sender: TObject);
begin
  if Assigned(FOnColExit) then
    FOnColExit(Self);
end;

procedure TCWSDBGrid.GridColumnMoved(Sender: TObject; FromIndex, ToIndex: Longint);
begin
  if Assigned(FOnColumnMoved) then
    FOnColumnMoved(Self, FromIndex, ToIndex);
end;

procedure TCWSDBGrid.GridEditButtonClick(Sender: TObject);
begin
  if Assigned(FOnEditButtonClick) then
    FOnEditButtonClick(Self);
end;

procedure TCWSDBGrid.GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnKeyDown) then
    FOnKeyDown(Self, Key, Shift);
  UpdateScrollbarMetrics;
  Invalidate;
end;

procedure TCWSDBGrid.GridKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnKeyUp) then
    FOnKeyUp(Self, Key, Shift);
end;

procedure TCWSDBGrid.GridKeyPress(Sender: TObject; var Key: Char);
begin
  if Assigned(FOnKeyPress) then
    FOnKeyPress(Self, Key);
end;

procedure TCWSDBGrid.CMFontChanged(var Msg: TMessage);
begin
  inherited;
  SyncGridFont;
  Invalidate;
end;

procedure TCWSDBGrid.CMEnabledChanged(var Msg: TMessage);
begin
  inherited;
  if FGrid <> nil then
    FGrid.Enabled := Enabled;
  Invalidate;
end;

procedure TCWSDBGrid.CMMouseEnter(var Msg: TMessage);
begin
  inherited;
  CompositeMouseEnter;
end;

procedure TCWSDBGrid.CMMouseLeave(var Msg: TMessage);
begin
  inherited;
  CompositeMouseCheckLeave;
  if not (FVDragging or FHDragging) and (FVAreaHovered or FHAreaHovered) then
  begin
    FVAreaHovered := False;
    FHAreaHovered := False;
    UpdateScrollbarMetrics;
    Invalidate;
  end;
end;

{ *** Pass-through methods *** }

procedure TCWSDBGrid.DefaultDrawColumnCell(const Rect: TRect; DataCol: Integer;
  Column: TColumn; State: TGridDrawState);
begin
  FGrid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

{ *** Forwarded properties *** }

function TCWSDBGrid.GetDataSource: TDataSource;
begin Result := FGrid.DataSource; end;

procedure TCWSDBGrid.SetDataSource(const Value: TDataSource);
begin
  FGrid.DataSource := Value;
  UpdateGridPosition;
  Invalidate;
end;

function TCWSDBGrid.GetColumns: TDBGridColumns;
begin Result := FGrid.Columns; end;

procedure TCWSDBGrid.SetColumns(const Value: TDBGridColumns);
begin
  FGrid.Columns := Value;
  UpdateGridPosition;
  Invalidate;
end;

function TCWSDBGrid.StoreColumns: Boolean;
begin
  { Persist Columns only when the user actually customised them (csCustomized),
    mirroring TCustomDBGrid.WriteColumns. The wrapper re-publishes Columns as a
    plain property, so without this the single dynamic (csDefault) column gets
    streamed to the DFM and is promoted to a blank persistent column on reload —
    which then suppresses automatic field-based columns. }
  Result := (FGrid <> nil) and (FGrid.Columns.State = csCustomized);
end;

function TCWSDBGrid.GetOptions: TDBGridOptions;
begin Result := FGrid.Options; end;

procedure TCWSDBGrid.SetOptions(const Value: TDBGridOptions);
begin
  FGrid.Options := Value;
  UpdateGridPosition;
  Invalidate;
end;

function TCWSDBGrid.GetReadOnly: Boolean;
begin Result := FGrid.ReadOnly; end;

procedure TCWSDBGrid.SetReadOnly(const Value: Boolean);
begin FGrid.ReadOnly := Value; end;

function TCWSDBGrid.GetTitleFont: TFont;
begin Result := FGrid.TitleFont; end;

procedure TCWSDBGrid.SetTitleFont(const Value: TFont);
begin FGrid.TitleFont := Value; Invalidate; end;

function TCWSDBGrid.GetDefaultDrawing: Boolean;
begin Result := FGrid.DefaultDrawing; end;

procedure TCWSDBGrid.SetDefaultDrawing(const Value: Boolean);
begin FGrid.DefaultDrawing := Value; FGrid.Invalidate; Invalidate; end;

procedure TCWSDBGrid.SetGridLineWidth(const Value: Integer);
begin
  if FGridLineWidth <> Value then
  begin
    FGridLineWidth := Max(0, Value);
    if FGrid <> nil then FGrid.Invalidate;
    Invalidate;
  end;
end;

procedure TCWSDBGrid.SetDefaultRowHeight(const Value: Integer);
var
  V: Integer;
begin
  V := Max(0, Value);
  if FDefaultRowHeight <> V then
  begin
    FDefaultRowHeight := V;
    { Force a re-measure (LayoutChanged re-applies our heights), then re-flow the
      chrome — the visible row count, and therefore the scrollbar, has changed. }
    if FGrid <> nil then
      FGrid.LayoutChanged;
    UpdateGridPosition;
    Invalidate;
  end;
end;

procedure TCWSDBGrid.SetTitleHeight(const Value: Integer);
var
  V: Integer;
begin
  V := Max(0, Value);
  if FTitleHeight <> V then
  begin
    FTitleHeight := V;
    if FGrid <> nil then
      FGrid.LayoutChanged;
    UpdateGridPosition;
    Invalidate;
  end;
end;

function TCWSDBGrid.GetSelectedField: TField;
begin Result := FGrid.SelectedField; end;

procedure TCWSDBGrid.SetSelectedField(const Value: TField);
begin FGrid.SelectedField := Value; end;

function TCWSDBGrid.GetSelectedIndex: Integer;
begin Result := FGrid.SelectedIndex; end;

procedure TCWSDBGrid.SetSelectedIndex(const Value: Integer);
begin FGrid.SelectedIndex := Value; end;

function TCWSDBGrid.GetSelectedRows: TBookmarkList;
begin Result := FGrid.SelectedRows; end;

function TCWSDBGrid.GetFields(Index: Integer): TField;
begin Result := FGrid.Fields[Index]; end;

function TCWSDBGrid.GetFieldCount: Integer;
begin Result := FGrid.FieldCount; end;

function TCWSDBGrid.GetEditorMode: Boolean;
begin Result := FGrid.EditorMode; end;

procedure TCWSDBGrid.SetEditorMode(const Value: Boolean);
begin FGrid.EditorMode := Value; end;

function TCWSDBGrid.GetCellCanvas: TCanvas;
begin Result := FGrid.Canvas; end;

{ *** Color setters *** }

procedure TCWSDBGrid.SetBorderColor(const Value: TColor);
begin if FBorderColor <> Value then begin FBorderColor := Value; Invalidate; end; end;

procedure TCWSDBGrid.SetBackgroundColor(const Value: TColor);
begin if FBackgroundColor <> Value then begin FBackgroundColor := Value; ApplyColors; end; end;

procedure TCWSDBGrid.SetCellColor(const Value: TColor);
begin if FCellColor <> Value then begin FCellColor := Value; ApplyColors; end; end;

procedure TCWSDBGrid.SetCellTextColor(const Value: TColor);
begin if FCellTextColor <> Value then begin FCellTextColor := Value; ApplyColors; end; end;

procedure TCWSDBGrid.SetGridLineColor(const Value: TColor);
begin if FGridLineColor <> Value then begin FGridLineColor := Value; ApplyColors; end; end;

procedure TCWSDBGrid.SetFixedColor(const Value: TColor);
begin if FFixedColor <> Value then begin FFixedColor := Value; ApplyColors; end; end;

procedure TCWSDBGrid.SetFixedTextColor(const Value: TColor);
begin if FFixedTextColor <> Value then begin FFixedTextColor := Value; ApplyColors; end; end;

procedure TCWSDBGrid.SetCellHighlightColor(const Value: TColor);
begin if FCellHighlightColor <> Value then begin FCellHighlightColor := Value; ApplyColors; end; end;

procedure TCWSDBGrid.SetHighlightTextColor(const Value: TColor);
begin if FHighlightTextColor <> Value then begin FHighlightTextColor := Value; ApplyColors; end; end;

procedure TCWSDBGrid.SetAlternatingRowColors(const Value: Boolean);
begin if FAlternatingRowColors <> Value then begin FAlternatingRowColors := Value; ApplyColors; end; end;

procedure TCWSDBGrid.SetOddRowColor(const Value: TColor);
begin if FOddRowColor <> Value then begin FOddRowColor := Value; ApplyColors; end; end;

procedure TCWSDBGrid.SetEvenRowColor(const Value: TColor);
begin if FEvenRowColor <> Value then begin FEvenRowColor := Value; ApplyColors; end; end;

procedure TCWSDBGrid.SetCornerRadius(const Value: Single);
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

procedure TCWSDBGrid.ReadCornerRadius(Reader: TReader);
begin
  { Read straight into the field — the region is rebuilt in Loaded anyway. }
  FCornerRadius := Reader.ReadFloat;
end;

procedure TCWSDBGrid.WriteCornerRadius(Writer: TWriter);
begin
  Writer.WriteFloat(FCornerRadius);
end;

procedure TCWSDBGrid.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  { Floating-point properties with value 0 are skipped by the standard DFM
    streamer (0 = default for float). Thanks to this entry CornerRadius is always
    saved, even when set to 0 — so a design-time 0 stays 0 at run time. }
  Filer.DefineProperty('CornerRadiusF', ReadCornerRadius, WriteCornerRadius, True);
end;

procedure TCWSDBGrid.SetShowBorder(const Value: Boolean);
begin
  if FShowBorder <> Value then
  begin
    FShowBorder := Value;
    Invalidate;
  end;
end;

procedure TCWSDBGrid.SetRoundTopLeft(const Value: Boolean);
begin if FRoundTopLeft <> Value then begin FRoundTopLeft := Value; UpdateGridRegion; Invalidate; end; end;

procedure TCWSDBGrid.SetRoundTopRight(const Value: Boolean);
begin if FRoundTopRight <> Value then begin FRoundTopRight := Value; UpdateGridRegion; Invalidate; end; end;

procedure TCWSDBGrid.SetRoundBottomLeft(const Value: Boolean);
begin if FRoundBottomLeft <> Value then begin FRoundBottomLeft := Value; UpdateGridRegion; Invalidate; end; end;

procedure TCWSDBGrid.SetRoundBottomRight(const Value: Boolean);
begin if FRoundBottomRight <> Value then begin FRoundBottomRight := Value; UpdateGridRegion; Invalidate; end; end;

procedure TCWSDBGrid.SetScrollThumbColor(const Value: TColor);
begin if FScrollThumbColor <> Value then begin FScrollThumbColor := Value; Invalidate; end; end;

procedure TCWSDBGrid.SetScrollThumbHoverColor(const Value: TColor);
begin if FScrollThumbHoverColor <> Value then begin FScrollThumbHoverColor := Value; Invalidate; end; end;

procedure TCWSDBGrid.SetScrollbarAreaWidth(const Value: Integer);
begin
  if FScrollbarAreaWidth <> Value then
  begin
    FScrollbarAreaWidth := Max(6, Value);
    UpdateGridPosition;
    Invalidate;
  end;
end;

procedure TCWSDBGrid.SetScrollbarThumbWidth(const Value: Integer);
begin
  if FScrollbarThumbWidth <> Value then
  begin
    FScrollbarThumbWidth := Max(2, Value);
    UpdateScrollbarMetrics;
    Invalidate;
  end;
end;

procedure TCWSDBGrid.SetScrollbarThumbHoverWidth(const Value: Integer);
begin
  if FScrollbarThumbHoverWidth <> Value then
  begin
    FScrollbarThumbHoverWidth := Max(2, Value);
    UpdateScrollbarMetrics;
    Invalidate;
  end;
end;

procedure TCWSDBGrid.SetScrollBars(const Value: TScrollStyle);
begin
  if FScrollBars <> Value then
  begin
    FScrollBars := Value;
    UpdateGridPosition;
    Invalidate;
  end;
end;

procedure TCWSDBGrid.SetAutoFitColumns(const Value: Boolean);
begin
  if FAutoFitColumns <> Value then
  begin
    FAutoFitColumns := Value;
    if FAutoFitColumns then
      FitColumnsToWidth;   { no-op at design time — applied on first runtime layout }
  end;
end;

end.
