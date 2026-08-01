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
unit CWSOptionsPanel;

{ Windows 11 / WinUI 3 style "Expander" (Settings-page card).

  TCWSOptionsPanel  — a collapsible card with a header (icon + title + subtitle
                      + chevron). Collapsed it is a single rounded rectangle
                      (all four corners rounded). Expanded, the header keeps its
                      rounded top corners but the bottom corners go square, and
                      one or more TCWSOptionsSection sub-panels stack underneath.

  TCWSOptionsSection — a plain, square-cornered panel that hosts arbitrary child
                      controls (checkboxes, buttons, …). Sections are added
                      dynamically at runtime (AddSection) or in the IDE via the
                      component editor's "Add section" verb, and can be laid out
                      with any child controls just like a TPanel. }

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  System.Classes, System.SysUtils, System.UITypes,
  Vcl.Controls, Vcl.Graphics, Vcl.ImgList;

type
  TCWSOptionsPanel = class;

  { Shape of the header glyph on the right:
      csVertical — a chevron that points down when collapsed and up when expanded
                   (classic WinUI expander).
      csRight    — a ">" arrow that points right when collapsed and rotates to
                   point down when expanded (navigation / Settings-row style). }
  TCWSChevronStyle = (csVertical, csRight);

  { How the header icon is supplied:
      icmImageList — draw glyph FImageIndex from the assigned Images list.
      icmGlyph     — draw the IconGlyph text with an icon font (Segoe MDL2 /
                     Fluent Icons), exactly like TCWSButton. }
  TCWSIconMode = (icmImageList, icmGlyph);

  { ─────────────────────────────────────────────────────────────────────────
      TCWSOptionsSection — a square-cornered sub-panel that accepts controls.
    ───────────────────────────────────────────────────────────────────────── }
  TCWSOptionsSection = class(TCustomControl)
  private
    FDividerColor: TColor;
    FShowTopDivider: Boolean;
    procedure SetDividerColor(const Value: TColor);
    procedure SetShowTopDivider(const Value: Boolean);
    function OwnerPanel: TCWSOptionsPanel;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure Paint; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    { Any bounds change (size OR position) must reflow the whole card. Resize
      alone is not enough: the VCL only fires Resize when the size changes, so
      dragging a section to a new Top in the designer would leave it overlapping
      its siblings. }
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
  published
    property Align;
    property Anchors;
    property Color;
    property Cursor;
    property DoubleBuffered;
    property Enabled;
    property Font;
    property Height;
    property ParentColor;
    property ParentFont;
    property Visible;

    { Colour of the 1-px separator line drawn along the top edge — this is what
      splits one section from the next (and from the header). }
    property DividerColor: TColor read FDividerColor write SetDividerColor default $00E5E5E5;
    property ShowTopDivider: Boolean read FShowTopDivider write SetShowTopDivider default True;

    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseEnter;
    property OnMouseLeave;
  end;

  { ─────────────────────────────────────────────────────────────────────────
      TCWSOptionsPanel — the collapsible card.
    ───────────────────────────────────────────────────────────────────────── }
  TCWSOptionsPanel = class(TCustomControl)
  private
    FExpanded: Boolean;
    FExpandable: Boolean;
    FHeaderHeight: Integer;
    FCornerRadius: Integer;
    FTitle: string;
    FSubtitle: string;
    FFillColor: TColor;
    FBorderColor: TColor;
    FBorderTop: Boolean;
    FBorderBottom: Boolean;
    FBorderLeft: Boolean;
    FBorderRight: Boolean;
    FTitleFont: TFont;
    FSubtitleFont: TFont;
    FChevronColor: TColor;
    FChevronStyle: TCWSChevronStyle;
    FShowChevron: Boolean;
    FShowTitle: Boolean;
    FShowSubtitle: Boolean;
    FHover: Boolean;
    FHoverColor: TColor;
    FImages: TCustomImageList;
    FImageIndex: Integer;
    FIconMode: TCWSIconMode;
    FIconGlyph: string;
    FIconFontName: string;
    FIconFontSize: Integer;
    FIconColor: TColor;
    FTitleSpacing: Integer;
    FHeaderHovered: Boolean;
    FLayouting: Boolean;
    FRoundTopLeft: Boolean;
    FRoundTopRight: Boolean;
    FRoundBottomLeft: Boolean;
    FRoundBottomRight: Boolean;
    FRoundLastSection: Boolean;
    FOnExpandedChanged: TNotifyEvent;

    procedure SetExpanded(const Value: Boolean);
    procedure SetExpandable(const Value: Boolean);
    procedure SetHeaderHeight(const Value: Integer);
    procedure SetCornerRadius(const Value: Integer);
    procedure SetTitle(const Value: string);
    procedure SetSubtitle(const Value: string);
    procedure SetFillColor(const Value: TColor);
    procedure SetBorderColor(const Value: TColor);
    procedure SetBorderTop(const Value: Boolean);
    procedure SetBorderBottom(const Value: Boolean);
    procedure SetBorderLeft(const Value: Boolean);
    procedure SetBorderRight(const Value: Boolean);
    procedure SetTitleFont(const Value: TFont);
    procedure SetSubtitleFont(const Value: TFont);
    function GetTitleColor: TColor;
    procedure SetTitleColor(const Value: TColor);
    function GetSubtitleColor: TColor;
    procedure SetSubtitleColor(const Value: TColor);
    procedure SetChevronColor(const Value: TColor);
    procedure SetChevronStyle(const Value: TCWSChevronStyle);
    procedure SetShowChevron(const Value: Boolean);
    procedure SetShowTitle(const Value: Boolean);
    procedure SetShowSubtitle(const Value: Boolean);
    procedure SetHover(const Value: Boolean);
    procedure SetHoverColor(const Value: TColor);
    procedure SetImages(const Value: TCustomImageList);
    procedure SetImageIndex(const Value: Integer);
    procedure SetIconMode(const Value: TCWSIconMode);
    procedure SetIconGlyph(const Value: string);
    procedure SetIconFontName(const Value: string);
    procedure SetIconFontSize(const Value: Integer);
    procedure SetIconColor(const Value: TColor);
    procedure SetTitleSpacing(const Value: Integer);
    procedure SetRoundTopLeft(const Value: Boolean);
    procedure SetRoundTopRight(const Value: Boolean);
    procedure SetRoundBottomLeft(const Value: Boolean);
    procedure SetRoundBottomRight(const Value: Boolean);
    procedure SetRoundLastSection(const Value: Boolean);
    procedure HeaderFontChanged(Sender: TObject);

    function Scale(V: Integer): Integer;
    function Unscale(V: Integer): Integer;
    function BorderPx: Integer;
    { All hosted sections in visual (top-to-bottom) order — sorted by Top, not
      by Controls[] index, so a section dragged between two others at design
      time is re-stacked at its new place. Stable for equal Tops. }
    function SortedSections: TArray<TCWSOptionsSection>;
    { Height the card should have according to the current layout state. }
    function LayoutHeight: Integer;
    { Design time only: the user dragged the panel's edge in the form designer.
      Translate the manual Height change into component state — a new
      HeaderHeight when collapsed, a new height of the last section when
      expanded — so Relayout keeps the change instead of snapping it back. }
    procedure ApplyDesignHeight;
    function GetParentBgColor: TColor;
    { Paints what is really behind the card into DC, outside the rounded outline.
      (ADX, ADY) is where this panel's client origin sits in DC's device space —
      (0, 0) when the panel paints itself, (-Left, -Top) of a hosted section when
      that section paints the card's rounded bottom in its own coordinates. }
    procedure DrawParentBackground(DC: HDC; ARadius: Single;
      ADX: Integer = 0; ADY: Integer = 0);
    function PointInHeader(X, Y: Integer): Boolean;
    procedure DrawHeader;
    { Invalidate the whole card — the header AND every hosted section. Shape/border
      properties (CornerRadius, BorderColor, the RoundBottom* flags, …) affect the
      rounded bottom the LAST section paints itself, so that child window must be
      repainted too; invalidating only the panel leaves the section stale until the
      designer forces a full redraw (e.g. on click). }
    procedure InvalidateCard;

    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure CMControlListChange(var Message: TMessage); message CM_CONTROLLISTCHANGE;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;
    procedure Resize; override;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { Creates a new section, parents it to this panel and returns it. At design
      time pass the form as AOwner (the component editor does this) so the
      section streams to the DFM; at runtime AOwner may be the form or nil. }
    function AddSection(AOwner: TComponent = nil): TCWSOptionsSection;
    { Number of TCWSOptionsSection children currently hosted. }
    function SectionCount: Integer;
    { Indexed access to the hosted sections, in visual (top-to-bottom) order. }
    function Sections(Index: Integer): TCWSOptionsSection;

    { Re-stacks the sections under the header and recomputes the panel height.
      Called automatically on expand/collapse, resize and section add/remove. }
    procedure Relayout;
  published
    property Align;
    property Anchors;
    property DoubleBuffered;
    property Enabled;
    property Font;
    property PopupMenu;
    property Visible;

    property Title: string read FTitle write SetTitle;
    property Subtitle: string read FSubtitle write SetSubtitle;
    { Hide the title / subtitle text without clearing the string. When off (or
      the string is empty) the text is not drawn and reserves no vertical space,
      so the remaining line stays centred in the header. }
    property ShowTitle: Boolean read FShowTitle write SetShowTitle default True;
    property ShowSubtitle: Boolean read FShowSubtitle write SetShowSubtitle default True;
    property Expanded: Boolean read FExpanded write SetExpanded default False;
    { When False the header is a plain (non-collapsible) row: clicking it never
      toggles — only OnClick fires. Handy with ChevronStyle = csRight for a
      Settings-style navigation row. Note the header also refuses to expand on
      click while there are no sections to reveal, regardless of this flag. }
    property Expandable: Boolean read FExpandable write SetExpandable default True;
    property HeaderHeight: Integer read FHeaderHeight write SetHeaderHeight default 60;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 8;

    property FillColor: TColor read FFillColor write SetFillColor default $00FBFBFB;
    property BorderColor: TColor read FBorderColor write SetBorderColor default $00E5E5E5;

    { Show/hide each border edge independently. Turning one off removes just that
      side of the card outline (the fill is unaffected); a rounded corner is only
      drawn where its two adjacent edges are both present. }
    property BorderTop: Boolean read FBorderTop write SetBorderTop default True;
    property BorderBottom: Boolean read FBorderBottom write SetBorderBottom default True;
    property BorderLeft: Boolean read FBorderLeft write SetBorderLeft default True;
    property BorderRight: Boolean read FBorderRight write SetBorderRight default True;

    { Fonts for the header texts. Each carries its own family, size, style AND
      colour, so title and subtitle can be styled fully independently. }
    property TitleFont: TFont read FTitleFont write SetTitleFont;
    property SubtitleFont: TFont read FSubtitleFont write SetSubtitleFont;

    { Kept for backward compatibility — they are now thin shortcuts to the
      respective font's Color. Not streamed (stored False): the fonts carry the
      colour, these just let old DFMs / code keep working. }
    property TitleColor: TColor read GetTitleColor write SetTitleColor stored False;
    property SubtitleColor: TColor read GetSubtitleColor write SetSubtitleColor stored False;

    property ChevronColor: TColor read FChevronColor write SetChevronColor default $005B5B5B;
    property ChevronStyle: TCWSChevronStyle read FChevronStyle write SetChevronStyle default csVertical;
    { Hide the header glyph entirely (icon + title/subtitle only). The header can
      still toggle on click when Expandable. }
    property ShowChevron: Boolean read FShowChevron write SetShowChevron default True;
    { Turn the header hover highlight on or off. }
    property Hover: Boolean read FHover write SetHover default True;
    property HoverColor: TColor read FHoverColor write SetHoverColor default $00F0F0F0;

    { Icon source. icmImageList draws Images[ImageIndex]; icmGlyph draws the
      IconGlyph text with an icon font (see IconFontName/IconFontSize/IconColor),
      exactly like TCWSButton. }
    property IconMode: TCWSIconMode read FIconMode write SetIconMode default icmImageList;
    property Images: TCustomImageList read FImages write SetImages;
    property ImageIndex: Integer read FImageIndex write SetImageIndex default -1;

    { Glyph icon (used when IconMode = icmGlyph). IconGlyph is a single character
      from the icon font — e.g. #$E713 in 'Segoe MDL2 Assets'. }
    property IconGlyph: string read FIconGlyph write SetIconGlyph;
    property IconFontName: string read FIconFontName write SetIconFontName;
    property IconFontSize: Integer read FIconFontSize write SetIconFontSize default 14;
    property IconColor: TColor read FIconColor write SetIconColor default $001B1B1B;

    { Vertical gap (in 96-dpi px, scaled) between the title and the subtitle when
      both are shown. }
    property TitleSpacing: Integer read FTitleSpacing write SetTitleSpacing default 2;

    { Round each corner of the card independently. On the header's own bottom edge
      the two bottom corners only round while the card is collapsed — expanded, the
      sections sit flush underneath so the header bottom is square. When expanded
      and RoundLastSection is on, the bottom rounding is instead applied to the
      last section (see RoundLastSection), still honouring these two flags. }
    property RoundTopLeft: Boolean read FRoundTopLeft write SetRoundTopLeft default True;
    property RoundTopRight: Boolean read FRoundTopRight write SetRoundTopRight default True;
    property RoundBottomLeft: Boolean read FRoundBottomLeft write SetRoundBottomLeft default True;
    property RoundBottomRight: Boolean read FRoundBottomRight write SetRoundBottomRight default True;

    { When expanded, round the bottom corners of the LAST section (radius =
      CornerRadius) so the whole card keeps rounded bottom corners instead of a
      square edge. Honours RoundBottomLeft / RoundBottomRight for which corners
      round. Has no effect while collapsed (the header rounds its own bottom). }
    property RoundLastSection: Boolean read FRoundLastSection write SetRoundLastSection default False;

    property OnExpandedChanged: TNotifyEvent read FOnExpandedChanged write FOnExpandedChanged;
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

function MakeGPColor(AColor: TColor): Cardinal;
var
  C: TColor;
begin
  C := ColorToRGB(AColor);
  Result := Winapi.GDIPAPI.MakeColor(255, GetRValue(C), GetGValue(C), GetBValue(C));
end;

{ 50/50 blend of two colours — used to mute the design-time placeholder text
  halfway toward the card fill so it reads as a hint on any theme. }
function BlendColor(A, B: TColor): TColor;
begin
  A := ColorToRGB(A);
  B := ColorToRGB(B);
  Result := RGB(
    (GetRValue(A) + GetRValue(B)) div 2,
    (GetGValue(A) + GetGValue(B)) div 2,
    (GetBValue(A) + GetBValue(B)) div 2);
end;

{ Adds a rounded rectangle to APath where each corner can independently be
  rounded (radius R) or square. Used so the header can round its top corners
  yet keep the bottom ones square when the card is expanded. }
procedure AddRoundRectPathEx(APath: TGPGraphicsPath; X, Y, W, H, R: Single;
  TL, TR, BR, BL: Boolean);
var
  D: Single;
begin
  D := R * 2;
  if D > W then D := W;
  if D > H then D := H;
  if D < 0 then D := 0;

  APath.StartFigure;

  // Top-left
  if TL and (D > 0) then
    APath.AddArc(X, Y, D, D, 180, 90)
  else
    APath.AddLine(X, Y, X, Y);

  // Top-right
  if TR and (D > 0) then
    APath.AddArc(X + W - D, Y, D, D, 270, 90)
  else
    APath.AddLine(X + W, Y, X + W, Y);

  // Bottom-right
  if BR and (D > 0) then
    APath.AddArc(X + W - D, Y + H - D, D, D, 0, 90)
  else
    APath.AddLine(X + W, Y + H, X + W, Y + H);

  // Bottom-left
  if BL and (D > 0) then
    APath.AddArc(X, Y + H - D, D, D, 90, 90)
  else
    APath.AddLine(X, Y + H, X, Y + H);

  APath.CloseFigure;
end;

{ Collects the outline segments belonging to *visible* border edges, so only
  those get stroked. The card keeps its full size and crisp corners — a hidden
  edge simply blends into the interior instead of leaving a gap that shows the
  parent background through.

  This must not be done the other way round (stroke the whole outline, then
  re-stroke the hidden parts in the fill colour). On a straight edge the second
  stroke lands on full-coverage pixels and replaces the first one exactly, but on
  a corner arc the antialiased coverage is fractional, so the two strokes blend
  instead of cancelling and the arc keeps a visible ghost of BorderColor — the
  corners read as a third colour that is neither the fill nor the background.

  A straight edge is added when it is visible; a corner arc is added when it is
  rounded and BOTH of its adjacent edges are visible. Geometry mirrors
  AddRoundRectPathEx exactly so the stroke sits on the card outline.
  ET/ER/EB/EL are the edge-ENABLED flags. Each segment is its own figure. }
procedure AddBorderVisiblePathEx(APath: TGPGraphicsPath; X, Y, W, H, R: Single;
  TL, TR, BR, BL: Boolean; ET, ER, EB, EL: Boolean);
var
  D: Single;
  function Ret(Rounded: Boolean): Single;
  begin
    if Rounded then Result := R else Result := 0;
  end;
begin
  D := R * 2;
  if D > W then D := W;
  if D > H then D := H;
  if D < 0 then D := 0;
  R := D / 2;

  { Corner arcs — a corner is drawn in the border colour only when both of its
    edges show. }
  if TL and EL and ET then
  begin APath.StartFigure; APath.AddArc(X, Y, D, D, 180, 90); end;
  if TR and ET and ER then
  begin APath.StartFigure; APath.AddArc(X + W - D, Y, D, D, 270, 90); end;
  if BR and ER and EB then
  begin APath.StartFigure; APath.AddArc(X + W - D, Y + H - D, D, D, 0, 90); end;
  if BL and EB and EL then
  begin APath.StartFigure; APath.AddArc(X, Y + H - D, D, D, 90, 90); end;

  { Visible straight edges. }
  if ET then
  begin
    APath.StartFigure;
    APath.AddLine(X + Ret(TL), Y, X + W - Ret(TR), Y);
  end;
  if ER then
  begin
    APath.StartFigure;
    APath.AddLine(X + W, Y + Ret(TR), X + W, Y + H - Ret(BR));
  end;
  if EB then
  begin
    APath.StartFigure;
    APath.AddLine(X + W - Ret(BR), Y + H, X + Ret(BL), Y + H);
  end;
  if EL then
  begin
    APath.StartFigure;
    APath.AddLine(X, Y + H - Ret(BL), X, Y + Ret(TL));
  end;
end;

{ ─────────────────────────────────────────────────────────────────────────
    TCWSOptionsSection
  ───────────────────────────────────────────────────────────────────────── }

constructor TCWSOptionsSection.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle + [csAcceptsControls, csOpaque, csReplicatable];
  DoubleBuffered := True;
  FDividerColor := $00E5E5E5;
  FShowTopDivider := True;
  Color := $00FBFBFB;
  Width := 348;
  Height := 48;
end;

function TCWSOptionsSection.OwnerPanel: TCWSOptionsPanel;
begin
  if Parent is TCWSOptionsPanel then
    Result := TCWSOptionsPanel(Parent)
  else
    Result := nil;
end;

procedure TCWSOptionsSection.Paint;
var
  P: TCWSOptionsPanel;
  Secs: TArray<TCWSOptionsSection>;
  R: Single;
  X0, Y0, RectW, RectH: Single;
  RBL, RBR, RoundedLast: Boolean;
  G: TGPGraphics;
  Path: TGPGraphicsPath;
  Brush: TGPSolidBrush;
  Pen: TGPPen;
begin
  P := OwnerPanel;

  { Rounded bottom corners are only applied to the LAST section, and only when the
    owning panel is expanded with RoundLastSection on. Which corners round follows
    the panel's RoundBottomLeft / RoundBottomRight flags. }
  RBL := False;
  RBR := False;
  RoundedLast := False;
  if (P <> nil) and P.FRoundLastSection and P.FExpanded and (P.Scale(P.FCornerRadius) > 0) then
  begin
    Secs := P.SortedSections;
    if (Length(Secs) > 0) and (Secs[High(Secs)] = Self) then
    begin
      RBL := P.FRoundBottomLeft;
      RBR := P.FRoundBottomRight;
      RoundedLast := RBL or RBR;
    end;
  end;

  if RoundedLast then
  begin
    R := P.Scale(P.FCornerRadius);
    { Reproduce, in THIS section's local coordinates, the exact bottom-rounded
      outline the panel painted for the whole card — same outer rect, same radius —
      so the fill and border overpaint the panel's pixels seamlessly. Only the two
      bottom corner shoulders actually fall inside this window; the sides, top and
      straight bottom edge sit in the 1-px margins the panel owns and are clipped
      away here, so there is no doubled or misaligned border. }
    X0 := 0.5 - Left;
    Y0 := 0.5 - Top;
    RectW := P.Width - 1;
    RectH := P.Height - 1;

    { Corner triangles (outside the arc) must read against whatever is behind the
      card, exactly as the panel drew them. }
    Canvas.Brush.Color := P.GetParentBgColor;
    Canvas.Brush.Style := bsSolid;
    Canvas.FillRect(ClientRect);
    { Same outline the panel used, so hand it this DC with our offset — it knows
      what is really behind the card. }
    P.DrawParentBackground(Canvas.Handle, R, -Left, -Top);

    G := TGPGraphics.Create(Canvas.Handle);
    try
      G.SetSmoothingMode(SmoothingModeAntiAlias);
      G.SetPixelOffsetMode(PixelOffsetModeHalf);
      Path := TGPGraphicsPath.Create;
      try
        AddRoundRectPathEx(Path, X0, Y0, RectW, RectH, R, False, False, RBR, RBL);
        Brush := TGPSolidBrush.Create(MakeGPColor(Color));
        try
          G.FillPath(Brush, Path);
        finally
          Brush.Free;
        end;
        { Restore the card border along the rounded bottom (the panel's stroke here
          was over-painted by the corner-triangle fill above). }
        if P.FBorderBottom then
        begin
          Pen := TGPPen.Create(MakeGPColor(P.FBorderColor));
          try
            G.DrawPath(Pen, Path);
          finally
            Pen.Free;
          end;
        end;
      finally
        Path.Free;
      end;
    finally
      G.Free;
    end;
  end
  else
  begin
    Canvas.Brush.Color := Color;
    Canvas.Brush.Style := bsSolid;
    Canvas.FillRect(ClientRect);
  end;

  if FShowTopDivider then
  begin
    Canvas.Pen.Color := FDividerColor;
    Canvas.Pen.Width := 1;
    Canvas.MoveTo(0, 0);
    Canvas.LineTo(Width, 0);
  end;
end;

procedure TCWSOptionsSection.Resize;
var
  P: TCWSOptionsPanel;
begin
  inherited;
  { A height change here must reflow the whole card. The panel guards against the
    re-entrancy this causes (Relayout sets our bounds, which re-enters Resize). }
  P := OwnerPanel;
  if P <> nil then
    P.Relayout;
end;

procedure TCWSOptionsSection.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  Changed: Boolean;
  P: TCWSOptionsPanel;
begin
  Changed := (ALeft <> Left) or (ATop <> Top) or
    (AWidth <> Width) or (AHeight <> Height);
  inherited;
  P := OwnerPanel;
  if Changed and (P <> nil) then
    P.Relayout;
end;

procedure TCWSOptionsSection.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1; { painted fully in Paint — skip erase to avoid flicker }
end;

procedure TCWSOptionsSection.SetDividerColor(const Value: TColor);
begin
  if FDividerColor <> Value then
  begin
    FDividerColor := Value;
    Invalidate;
  end;
end;

procedure TCWSOptionsSection.SetShowTopDivider(const Value: Boolean);
begin
  if FShowTopDivider <> Value then
  begin
    FShowTopDivider := Value;
    Invalidate;
  end;
end;

{ ─────────────────────────────────────────────────────────────────────────
    TCWSOptionsPanel
  ───────────────────────────────────────────────────────────────────────── }

constructor TCWSOptionsPanel.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle + [csAcceptsControls, csOpaque];
  DoubleBuffered := True;

  FExpanded := False;
  FExpandable := True;
  FHeaderHeight := 60;
  FCornerRadius := 8;
  { Start empty. A non-empty default here would never round-trip a later
    "clear": the VCL streamer treats '' as the default for a string property with
    no default directive, so an emptied Title/Subtitle is not written to the DFM
    and the constructor's text would reappear at runtime. Empty default => empty
    streams (and stays empty) everywhere. }
  FTitle := '';
  FSubtitle := '';
  FFillColor := $00FBFBFB;
  FBorderColor := $00E5E5E5;
  FBorderTop := True;
  FBorderBottom := True;
  FBorderLeft := True;
  FBorderRight := True;

  FTitleFont := TFont.Create;
  FTitleFont.Name := 'Segoe UI';
  FTitleFont.Size := 10;
  FTitleFont.Style := [fsBold];
  FTitleFont.Color := $001B1B1B;
  FTitleFont.OnChange := HeaderFontChanged;

  FSubtitleFont := TFont.Create;
  FSubtitleFont.Name := 'Segoe UI';
  FSubtitleFont.Size := 8;
  FSubtitleFont.Style := [];
  FSubtitleFont.Color := $00606060;
  FSubtitleFont.OnChange := HeaderFontChanged;

  FChevronColor := $005B5B5B;
  FChevronStyle := csVertical;
  FShowChevron := True;
  FShowTitle := True;
  FShowSubtitle := True;
  FHover := True;
  FHoverColor := $00F0F0F0;
  FImageIndex := -1;
  FIconMode := icmImageList;
  FIconGlyph := '';
  FIconFontName := 'Segoe MDL2 Assets';
  FIconFontSize := 14;
  FIconColor := $001B1B1B;
  FTitleSpacing := 2;

  FRoundTopLeft := True;
  FRoundTopRight := True;
  FRoundBottomLeft := True;
  FRoundBottomRight := True;
  FRoundLastSection := False;

  Width := 350;
  Height := FHeaderHeight;
end;

destructor TCWSOptionsPanel.Destroy;
begin
  FTitleFont.Free;
  FSubtitleFont.Free;
  inherited;
end;

procedure TCWSOptionsPanel.CreateParams(var Params: TCreateParams);
begin
  inherited;
  { Keep the custom-painted header/border out of the hosted section children. }
  Params.Style := Params.Style or WS_CLIPCHILDREN;
end;

function TCWSOptionsPanel.Scale(V: Integer): Integer;
begin
  Result := MulDiv(V, CurrentPPI, 96);
end;

function TCWSOptionsPanel.Unscale(V: Integer): Integer;
begin
  Result := MulDiv(V, 96, CurrentPPI);
end;

function TCWSOptionsPanel.BorderPx: Integer;
begin
  Result := 1;
end;

procedure TCWSOptionsPanel.InvalidateCard;
var
  I: Integer;
begin
  Invalidate;
  for I := 0 to ControlCount - 1 do
    if Controls[I] is TCWSOptionsSection then
      TCWSOptionsSection(Controls[I]).Invalidate;
end;

function TCWSOptionsPanel.GetParentBgColor: TColor;
begin
  if Parent <> nil then
    Result := TControlAccess(Parent).Color
  else
    Result := clBtnFace;
end;

procedure TCWSOptionsPanel.DrawParentBackground(DC: HDC; ARadius: Single;
  ADX: Integer = 0; ADY: Integer = 0);
var
  SaveIdx: Integer;
  Rgn: HRGN;
  D: Integer;
begin
  { The GetParentBgColor fill done by the caller is only a correct guess when the
    parent paints itself as a flat fill of that very color. A container drawing a
    gradient/card background, a VCL-styled form, or a parent whose Color is out
    of sync with what it actually paints all leave visible wrong-colored
    triangles outside the card's rounded corners — so let the parent render its
    real background here instead.
    Skipped at design time: a form's PaintWindow draws the designer dot grid,
    which would then bleed into the corners. }
  if (Parent = nil) or (csDesigning in ComponentState) then
    Exit;
  SaveIdx := SaveDC(DC);
  try
    { Clip to the sliver outside the card outline (inset by 1 px so the
      antialiased edge blends against real parent pixels). Region coordinates
      are device units, so this must happen before MoveWindowOrg — hence the
      explicit (ADX, ADY) rather than relying on the origin shift. }
    D := Round(ARadius) * 2;
    Rgn := CreateRoundRectRgn(ADX + 1, ADY + 1, ADX + Width, ADY + Height, D, D);
    try
      ExtSelectClipRgn(DC, Rgn, RGN_DIFF);
    finally
      DeleteObject(Rgn);
    end;
    { Shift the origin so our parent paints in its own coordinate system. }
    MoveWindowOrg(DC, ADX - Left, ADY - Top);
    Parent.Perform(WM_ERASEBKGND, WPARAM(DC), 0);
    { Parents that swallow WM_ERASEBKGND and paint in WM_PAINT (all the CWStudio
      containers do) only respond to this one. }
    Parent.Perform(WM_PRINTCLIENT, WPARAM(DC), PRF_CLIENT);
  finally
    RestoreDC(DC, SaveIdx);
  end;
end;

function TCWSOptionsPanel.PointInHeader(X, Y: Integer): Boolean;
begin
  Result := (Y >= 0) and (Y < Scale(FHeaderHeight));
end;

procedure TCWSOptionsPanel.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FImages) then
    FImages := nil;
end;

procedure TCWSOptionsPanel.Loaded;
begin
  inherited;
  Relayout;
end;

function TCWSOptionsPanel.SectionCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to ControlCount - 1 do
    if Controls[I] is TCWSOptionsSection then
      Inc(Result);
end;

function TCWSOptionsPanel.Sections(Index: Integer): TCWSOptionsSection;
var
  Secs: TArray<TCWSOptionsSection>;
begin
  Secs := SortedSections;
  if (Index >= 0) and (Index <= High(Secs)) then
    Result := Secs[Index]
  else
    Result := nil;
end;

function TCWSOptionsPanel.SortedSections: TArray<TCWSOptionsSection>;
var
  I, J, N: Integer;
  Sec: TCWSOptionsSection;
begin
  SetLength(Result, ControlCount);
  N := 0;
  for I := 0 to ControlCount - 1 do
    if Controls[I] is TCWSOptionsSection then
    begin
      Result[N] := TCWSOptionsSection(Controls[I]);
      Inc(N);
    end;
  SetLength(Result, N);

  { Stable insertion sort by Top (ties keep Controls[] order). }
  for I := 1 to N - 1 do
  begin
    Sec := Result[I];
    J := I - 1;
    while (J >= 0) and (Result[J].Top > Sec.Top) do
    begin
      Result[J + 1] := Result[J];
      Dec(J);
    end;
    Result[J + 1] := Sec;
  end;
end;

function TCWSOptionsPanel.LayoutHeight: Integer;
var
  I: Integer;
begin
  Result := Scale(FHeaderHeight);
  if FExpanded then
  begin
    for I := 0 to ControlCount - 1 do
      if Controls[I] is TCWSOptionsSection then
        Inc(Result, TCWSOptionsSection(Controls[I]).Height);
    Inc(Result, BorderPx);
  end;
end;

procedure TCWSOptionsPanel.ApplyDesignHeight;
var
  Delta, NewH: Integer;
  Secs: TArray<TCWSOptionsSection>;
  LastSec: TCWSOptionsSection;
begin
  Delta := Height - LayoutHeight;
  if Delta = 0 then
    Exit;

  Secs := SortedSections;
  if FExpanded and (Length(Secs) > 0) then
  begin
    { Expanded card: the dragged bottom edge grows/shrinks the last section. }
    LastSec := Secs[High(Secs)];
    NewH := LastSec.Height + Delta;
    if NewH < Scale(8) then
      NewH := Scale(8);
    LastSec.Height := NewH;
  end
  else
  begin
    { Collapsed card (or no sections): the panel IS the header, so the dragged
      height becomes the new HeaderHeight (stored in 96-dpi units). }
    NewH := Unscale(Height);
    if NewH < 24 then
      NewH := 24;
    FHeaderHeight := NewH;
  end;
end;

function TCWSOptionsPanel.AddSection(AOwner: TComponent): TCWSOptionsSection;
begin
  if AOwner = nil then
    AOwner := Owner;
  Result := TCWSOptionsSection.Create(AOwner);
  { Sections are stacked in Top order — park the new one far below everything
    so it lands as the LAST section; Relayout assigns the real Top. Kept within
    the 16-bit window-coordinate range. }
  Result.Top := 30000;
  Result.Parent := Self;
  if not FExpanded then
    Expanded := True
  else
    Relayout;
end;

procedure TCWSOptionsPanel.Relayout;
var
  I, Y, BW, AvailW: Integer;
  Secs: TArray<TCWSOptionsSection>;
begin
  if FLayouting then
    Exit;
  if csDestroying in ComponentState then
    Exit;
  if csReading in ComponentState then
    Exit; { DFM is still streaming in — Loaded will do the first layout }

  FLayouting := True;
  try
    BW := BorderPx;
    AvailW := ClientWidth - 2 * BW;
    if AvailW < 0 then
      AvailW := 0;

    Secs := SortedSections;
    if FExpanded then
    begin
      Y := Scale(FHeaderHeight);
      for I := 0 to High(Secs) do
      begin
        Secs[I].Visible := True;
        Secs[I].SetBounds(BW, Y, AvailW, Secs[I].Height);
        { With rounded-last-section on, which section is last may have changed —
          repaint them all so the corners land on the right one only. }
        if FRoundLastSection then
          Secs[I].Invalidate;
        Inc(Y, Secs[I].Height);
      end;
      Height := Y + BW;
    end
    else
    begin
      { Collapsed: the panel is just the header. Sections are hidden at runtime,
        but the form designer paints controls even when Visible is False, so we
        must also KEEP THEM STACKED right below the header. Otherwise they stay
        at their expanded Top and, once the header is dragged taller, the panel
        grows down over them and the header paints under the still-shown
        sections. Positioned flush under the header they are clipped away by the
        panel window at design time and never overlap it. }
      Y := Scale(FHeaderHeight);
      for I := 0 to High(Secs) do
      begin
        Secs[I].Visible := False;
        Secs[I].SetBounds(BW, Y, AvailW, Secs[I].Height);
        Inc(Y, Secs[I].Height);
      end;
      Height := Scale(FHeaderHeight);
    end;
  finally
    FLayouting := False;
  end;
  Invalidate;
end;

procedure TCWSOptionsPanel.Resize;
begin
  inherited;
  if FLayouting then
    Exit;
  { A manual height change in the form designer would otherwise be snapped
    straight back by Relayout — fold it into the component state first. }
  if (csDesigning in ComponentState) and not (csLoading in ComponentState) then
    ApplyDesignHeight;
  Relayout;
end;

procedure TCWSOptionsPanel.CMControlListChange(var Message: TMessage);
begin
  inherited;
  { A section was inserted or removed — reflow. LParam <> 0 means "inserting". }
  if not (csLoading in ComponentState) then
    Relayout;
end;

procedure TCWSOptionsPanel.DrawHeader;
var
  G: TGPGraphics;
  Path: TGPGraphicsPath;
  BorderPath: TGPGraphicsPath;
  HoverPath: TGPGraphicsPath;
  Brush: TGPSolidBrush;
  Pen: TGPPen;
  W, H, R, HH: Single;
  Pad, IconSz, TextX, ChX, ChY, ChW: Integer;
  GlyphW, GlyphH: Integer;
  TitleH, SubH, BlockH, TopY: Integer;
  RTL, RTR, RBR, RBL: Boolean;
  CardRBR, CardRBL: Boolean;
  ShowT, ShowS, Designing: Boolean;
  TitlePlaceholder, SubPlaceholder: Boolean;
  TitleText, SubText: string;
begin
  W := Width;
  HH := Scale(FHeaderHeight);
  H := Height;
  R := Scale(FCornerRadius);
  { Per-corner rounding. The two bottom corners can only round while collapsed —
    expanded, the sections sit flush under the header so its bottom edge must be
    square whatever the flags say. }
  RTL := FRoundTopLeft;
  RTR := FRoundTopRight;
  { Header band's own bottom corners round only while collapsed. }
  RBR := FRoundBottomRight and not FExpanded;
  RBL := FRoundBottomLeft and not FExpanded;
  { The whole card outline: its bottom corners also round while expanded when
    RoundLastSection is on — the last section paints the matching rounded fill. }
  CardRBR := FRoundBottomRight and ((not FExpanded) or FRoundLastSection);
  CardRBL := FRoundBottomLeft and ((not FExpanded) or FRoundLastSection);

  Pad := Scale(14);
  IconSz := Scale(24);
  ChW := Scale(6);

  G := TGPGraphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    G.SetPixelOffsetMode(PixelOffsetModeHalf);

    // Card fill — the whole outer shape, each corner rounded per its flag.
    Path := TGPGraphicsPath.Create;
    try
      AddRoundRectPathEx(Path, 0.5, 0.5, W - 1, H - 1, R, RTL, RTR, CardRBR, CardRBL);
      Brush := TGPSolidBrush.Create(MakeGPColor(FFillColor));
      try
        G.FillPath(Brush, Path);
      finally
        Brush.Free;
      end;

      { Subtle hover highlight over the header band only. It is painted BEFORE
        the outline: its path runs down the middle of the border pixels (the same
        0.5-offset geometry the stroke uses), so an antialiased fill on top would
        blend half the hover colour into them and the border would visibly change
        colour while hovered. Stroking after keeps BorderColor exact. }
      if FHover and FHeaderHovered and (not (csDesigning in ComponentState)) then
      begin
        HoverPath := TGPGraphicsPath.Create;
        try
          AddRoundRectPathEx(HoverPath, 0.5, 0.5, W - 1, HH - 1, R, RTL, RTR, RBR, RBL);
          Brush := TGPSolidBrush.Create(MakeGPColor(FHoverColor));
          try
            G.FillPath(Brush, HoverPath);
          finally
            Brush.Free;
          end;
        finally
          HoverPath.Free;
        end;
      end;

      { Stroke only what should show. A hidden edge is simply not drawn — never
        drawn and then painted over, which leaves a BorderColor ghost on the
        antialiased corner arcs (see AddBorderVisiblePathEx). }
      Pen := TGPPen.Create(MakeGPColor(FBorderColor));
      try
        if FBorderTop and FBorderRight and FBorderBottom and FBorderLeft then
          G.DrawPath(Pen, Path)
        else
        begin
          BorderPath := TGPGraphicsPath.Create;
          try
            AddBorderVisiblePathEx(BorderPath, 0.5, 0.5, W - 1, H - 1, R,
              RTL, RTR, CardRBR, CardRBL,
              FBorderTop, FBorderRight, FBorderBottom, FBorderLeft);
            G.DrawPath(Pen, BorderPath);
          finally
            BorderPath.Free;
          end;
        end;
      finally
        Pen.Free;
      end;
    finally
      Path.Free;
    end;

  finally
    G.Free;
  end;

  // Icon (optional) — either an image-list glyph or an icon-font glyph.
  TextX := Pad;
  case FIconMode of
    icmImageList:
      if Assigned(FImages) and (FImageIndex >= 0) and (FImageIndex < FImages.Count) then
      begin
        FImages.Draw(Canvas, Pad, (Round(HH) - IconSz) div 2, FImageIndex);
        TextX := Pad + IconSz + Scale(12);
      end;
    icmGlyph:
      if FIconGlyph <> '' then
      begin
        { Icon font sized like TCWSButton: drive the size through PixelsPerInch so
          the glyph scales with the monitor DPI. }
        Canvas.Font.PixelsPerInch := CurrentPPI;
        Canvas.Font.Name := FIconFontName;
        Canvas.Font.Size := FIconFontSize;
        Canvas.Font.Style := [];
        Canvas.Font.Color := FIconColor;
        Canvas.Brush.Style := bsClear;
        GlyphW := Canvas.TextWidth(FIconGlyph);
        GlyphH := Canvas.TextHeight(FIconGlyph);
        Canvas.TextOut(Pad, (Round(HH) - GlyphH) div 2, FIconGlyph);
        TextX := Pad + GlyphW + Scale(12);
      end;
  end;

  // Title + subtitle — each drawn with its own independent font. A line that is
  // switched off (ShowTitle/ShowSubtitle) or empty is not drawn and takes up no
  // vertical space, so the remaining line stays vertically centred.
  Canvas.Brush.Style := bsClear;

  { Runtime safeguard: a zero-length title/subtitle is never drawn.
    Design-time nicety: when the string is empty we still paint a faint
    'Title'/'Subtitle' placeholder so the dropped component is not blank. The
    placeholder is not a real value (FTitle/FSubtitle stay empty), so it is never
    streamed and never appears at run time. }
  Designing := csDesigning in ComponentState;

  TitleText := FTitle;
  TitlePlaceholder := FShowTitle and (Length(FTitle) = 0) and Designing;
  if TitlePlaceholder then
    TitleText := 'Title';
  ShowT := FShowTitle and (Length(TitleText) > 0);

  SubText := FSubtitle;
  SubPlaceholder := FShowSubtitle and (Length(FSubtitle) = 0) and Designing;
  if SubPlaceholder then
    SubText := 'Subtitle';
  ShowS := FShowSubtitle and (Length(SubText) > 0);

  TitleH := 0;
  if ShowT then
  begin
    Canvas.Font := FTitleFont;
    TitleH := Canvas.TextHeight('Ag');
  end;

  SubH := 0;
  if ShowS then
  begin
    Canvas.Font := FSubtitleFont;
    SubH := Canvas.TextHeight('Ag');
  end;

  if ShowT and ShowS then
    BlockH := TitleH + Scale(FTitleSpacing) + SubH
  else
    BlockH := TitleH + SubH; { at most one is non-zero }
  TopY := (Round(HH) - BlockH) div 2;

  // Title
  if ShowT then
  begin
    Canvas.Font := FTitleFont;
    if TitlePlaceholder then
      Canvas.Font.Color := BlendColor(FTitleFont.Color, FFillColor);
    Canvas.TextOut(TextX, TopY, TitleText);
  end;

  // Subtitle — sits under the title when both show, otherwise on the centre line.
  if ShowS then
  begin
    Canvas.Font := FSubtitleFont;
    if SubPlaceholder then
      Canvas.Font.Color := BlendColor(FSubtitleFont.Color, FFillColor);
    if ShowT then
      Canvas.TextOut(TextX, TopY + TitleH + Scale(FTitleSpacing), SubText)
    else
      Canvas.TextOut(TextX, TopY, SubText);
  end;

  // Header glyph on the right (optional).
  if not FShowChevron then
    Exit;
  ChX := Round(W) - Pad - ChW;
  ChY := Round(HH) div 2;
  G := TGPGraphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    Pen := TGPPen.Create(MakeGPColor(FChevronColor), 1.6);
    try
      if (FChevronStyle = csRight) and (not FExpanded) then
      begin
        // >  (points right) — navigation / Settings-row style
        G.DrawLine(Pen, ChX - ChW div 2, ChY - ChW, ChX + ChW div 2, ChY);
        G.DrawLine(Pen, ChX + ChW div 2, ChY, ChX - ChW div 2, ChY + ChW);
      end
      else if FExpanded and (FChevronStyle = csVertical) then
      begin
        // ^  (up)
        G.DrawLine(Pen, ChX - ChW, ChY + ChW div 2, ChX, ChY - ChW div 2);
        G.DrawLine(Pen, ChX, ChY - ChW div 2, ChX + ChW, ChY + ChW div 2);
      end
      else
      begin
        // v  (down) — collapsed csVertical, or expanded csRight (rotated arrow)
        G.DrawLine(Pen, ChX - ChW, ChY - ChW div 2, ChX, ChY + ChW div 2);
        G.DrawLine(Pen, ChX, ChY + ChW div 2, ChX + ChW, ChY - ChW div 2);
      end;
    finally
      Pen.Free;
    end;
  finally
    G.Free;
  end;
end;

procedure TCWSOptionsPanel.Paint;
begin
  { Corners outside the rounding show the parent background. }
  Canvas.Brush.Color := GetParentBgColor;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(ClientRect);
  DrawParentBackground(Canvas.Handle, Scale(FCornerRadius));
  DrawHeader;
end;

procedure TCWSOptionsPanel.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  { Toggle only for a real user click on the header, and only when there is
    something to reveal (Expandable and at least one section). Otherwise the
    header behaves as a plain row and just fires OnClick. }
  if (Button = mbLeft) and (not (csDesigning in ComponentState)) and
     PointInHeader(X, Y) and FExpandable and
     (FExpanded or (SectionCount > 0)) then
    Expanded := not Expanded;
end;

procedure TCWSOptionsPanel.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  InHeader: Boolean;
begin
  inherited;
  InHeader := FHover and PointInHeader(X, Y);
  if InHeader <> FHeaderHovered then
  begin
    FHeaderHovered := InHeader;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if Assigned(OnMouseEnter) then
    OnMouseEnter(Self);
end;

procedure TCWSOptionsPanel.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FHeaderHovered then
  begin
    FHeaderHovered := False;
    Invalidate;
  end;
  if Assigned(OnMouseLeave) then
    OnMouseLeave(Self);
end;

procedure TCWSOptionsPanel.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1; { fully repainted in Paint — skip erase to avoid flicker }
end;

procedure TCWSOptionsPanel.SetExpanded(const Value: Boolean);
begin
  if FExpanded <> Value then
  begin
    FExpanded := Value;
    Relayout;
    if Assigned(FOnExpandedChanged) then
      FOnExpandedChanged(Self);
  end;
end;

procedure TCWSOptionsPanel.SetExpandable(const Value: Boolean);
begin
  if FExpandable <> Value then
  begin
    FExpandable := Value;
    { A row turned non-expandable should not stay stuck open. }
    if (not FExpandable) and FExpanded then
      Expanded := False;
  end;
end;

procedure TCWSOptionsPanel.SetHeaderHeight(const Value: Integer);
begin
  if (FHeaderHeight <> Value) and (Value > 0) then
  begin
    FHeaderHeight := Value;
    Relayout;
  end;
end;

procedure TCWSOptionsPanel.SetCornerRadius(const Value: Integer);
begin
  if (FCornerRadius <> Value) and (Value >= 0) then
  begin
    FCornerRadius := Value;
    InvalidateCard;
  end;
end;

procedure TCWSOptionsPanel.SetTitle(const Value: string);
begin
  if FTitle <> Value then
  begin
    FTitle := Value;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetSubtitle(const Value: string);
begin
  if FSubtitle <> Value then
  begin
    FSubtitle := Value;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetFillColor(const Value: TColor);
begin
  if FFillColor <> Value then
  begin
    FFillColor := Value;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetBorderColor(const Value: TColor);
begin
  if FBorderColor <> Value then
  begin
    FBorderColor := Value;
    InvalidateCard;
  end;
end;

procedure TCWSOptionsPanel.SetBorderTop(const Value: Boolean);
begin
  if FBorderTop <> Value then
  begin
    FBorderTop := Value;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetBorderBottom(const Value: Boolean);
begin
  if FBorderBottom <> Value then
  begin
    FBorderBottom := Value;
    InvalidateCard;
  end;
end;

procedure TCWSOptionsPanel.SetBorderLeft(const Value: Boolean);
begin
  if FBorderLeft <> Value then
  begin
    FBorderLeft := Value;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetBorderRight(const Value: Boolean);
begin
  if FBorderRight <> Value then
  begin
    FBorderRight := Value;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetTitleFont(const Value: TFont);
begin
  FTitleFont.Assign(Value); { OnChange fires -> repaint }
end;

procedure TCWSOptionsPanel.SetSubtitleFont(const Value: TFont);
begin
  FSubtitleFont.Assign(Value); { OnChange fires -> repaint }
end;

function TCWSOptionsPanel.GetTitleColor: TColor;
begin
  Result := FTitleFont.Color;
end;

procedure TCWSOptionsPanel.SetTitleColor(const Value: TColor);
begin
  FTitleFont.Color := Value; { OnChange fires -> repaint }
end;

function TCWSOptionsPanel.GetSubtitleColor: TColor;
begin
  Result := FSubtitleFont.Color;
end;

procedure TCWSOptionsPanel.SetSubtitleColor(const Value: TColor);
begin
  FSubtitleFont.Color := Value; { OnChange fires -> repaint }
end;

procedure TCWSOptionsPanel.HeaderFontChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TCWSOptionsPanel.SetChevronColor(const Value: TColor);
begin
  if FChevronColor <> Value then
  begin
    FChevronColor := Value;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetChevronStyle(const Value: TCWSChevronStyle);
begin
  if FChevronStyle <> Value then
  begin
    FChevronStyle := Value;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetShowChevron(const Value: Boolean);
begin
  if FShowChevron <> Value then
  begin
    FShowChevron := Value;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetShowTitle(const Value: Boolean);
begin
  if FShowTitle <> Value then
  begin
    FShowTitle := Value;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetShowSubtitle(const Value: Boolean);
begin
  if FShowSubtitle <> Value then
  begin
    FShowSubtitle := Value;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetHover(const Value: Boolean);
begin
  if FHover <> Value then
  begin
    FHover := Value;
    { Turning hover off mid-hover must drop any highlight already shown. }
    if (not FHover) and FHeaderHovered then
      FHeaderHovered := False;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetHoverColor(const Value: TColor);
begin
  if FHoverColor <> Value then
  begin
    FHoverColor := Value;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetRoundTopLeft(const Value: Boolean);
begin
  if FRoundTopLeft <> Value then
  begin
    FRoundTopLeft := Value;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetRoundTopRight(const Value: Boolean);
begin
  if FRoundTopRight <> Value then
  begin
    FRoundTopRight := Value;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetRoundBottomLeft(const Value: Boolean);
begin
  if FRoundBottomLeft <> Value then
  begin
    FRoundBottomLeft := Value;
    InvalidateCard;
  end;
end;

procedure TCWSOptionsPanel.SetRoundBottomRight(const Value: Boolean);
begin
  if FRoundBottomRight <> Value then
  begin
    FRoundBottomRight := Value;
    InvalidateCard;
  end;
end;

procedure TCWSOptionsPanel.SetImages(const Value: TCustomImageList);
begin
  if FImages <> Value then
  begin
    if FImages <> nil then
      FImages.RemoveFreeNotification(Self);
    FImages := Value;
    if FImages <> nil then
      FImages.FreeNotification(Self);
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetImageIndex(const Value: Integer);
begin
  if FImageIndex <> Value then
  begin
    FImageIndex := Value;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetIconMode(const Value: TCWSIconMode);
begin
  if FIconMode <> Value then
  begin
    FIconMode := Value;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetIconGlyph(const Value: string);
begin
  if FIconGlyph <> Value then
  begin
    FIconGlyph := Value;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetIconFontName(const Value: string);
begin
  if FIconFontName <> Value then
  begin
    if Value = '' then
      FIconFontName := 'Segoe MDL2 Assets'
    else
      FIconFontName := Value;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetIconFontSize(const Value: Integer);
begin
  if (FIconFontSize <> Value) and (Value > 0) then
  begin
    FIconFontSize := Value;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetIconColor(const Value: TColor);
begin
  if FIconColor <> Value then
  begin
    FIconColor := Value;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetTitleSpacing(const Value: Integer);
begin
  if (FTitleSpacing <> Value) and (Value >= 0) then
  begin
    FTitleSpacing := Value;
    Invalidate;
  end;
end;

procedure TCWSOptionsPanel.SetRoundLastSection(const Value: Boolean);
begin
  if FRoundLastSection <> Value then
  begin
    FRoundLastSection := Value;
    { The last section must repaint its bottom corners (rounded or square) and the
      card outline must switch its bottom rounding to match. }
    InvalidateCard;
  end;
end;

initialization
  { Register both classes with the streaming system so the DFM reader can resolve
    them everywhere — at runtime AND for IDE copy/paste (which round-trips the
    component through DFM text and looks the class up via GetClass). Without this
    pasting a panel that hosts sections fails with "Class TCWSOptionsSection not
    found". RegisterNoIcon in the design package alone does not cover paste. }
  RegisterClasses([TCWSOptionsPanel, TCWSOptionsSection]);

end.
