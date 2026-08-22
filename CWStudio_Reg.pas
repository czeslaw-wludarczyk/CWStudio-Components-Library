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
unit CWStudio_Reg;

interface

procedure Register;

implementation

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  System.TypInfo,
  System.UITypes,
  System.Math,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ImgList,
  Vcl.DBGrids,
  ToolsAPI,
  DesignIntf,
  DesignEditors,
  VCLEditors, { ICustomPropertyListDrawing / ICustomPropertyDrawing }
  ColnEdit,
  DBColnEd,
  MaskProp,   { TMaskProperty — the VCL "Input Mask Editor" dialog (… button) }
  CWStudio_Version,
  { runtime units with components — the DT package requires CWStudio_ComponentsRT }
  CWSCornerPanel,
  CWSSettingsPanel,
  CWSOptionsPanel,
  CWSButton,
  CWSStoreButton,
  CWSMenuButton,
  CWSRadioButton,
  CWSCheckBox,
  CWSSwitch,
  CWSEdit,
  CWSEditMask,
  CWSComboBox,
  CWSMemo,
  CWSDatePicker,
  CWSProgressCircle,
  CWSProgressBar,
  CWSIndicatorLoading,
  CWSPopupMenu,
  CWSSystemMenu,
  CWSScrollBox,
  CWSDimOverlay,
  CWSAfterFormShow,
  CWSListBox,
  CWSStringGrid,
  CWSDBGrid,
  CWSLabelColumn,
  CWSLabelTrend;

{ Resource with the 24×24 splash/About bitmap — compiled from CWStudio_Splash.rc }
{$R CWStudio_Splash.res}

const
  cSplashResName = 'CWSTUDIO_SPLASH';

type
  { Columns property editor for TCWSDBGrid.

    TCWSDBGrid does not descend from TCustomDBGrid, so the IDE does not apply
    the standard DBGrid editor (registered only for TCustomDBGrid) to its
    Columns and falls back to the generic collection editor, which does not
    understand the csDefault/csCustomized state — making a freshly dropped
    component look as if it already had one column. We therefore register the
    same editor as the real DBGrid (TDBGridColumnsEditor): empty after dropping
    the component, a column appears only after "Add", plus "Add all fields" /
    "Restore defaults". }
  TCWSDBGridColumnsProperty = class(TClassProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

procedure TCWSDBGridColumnsProperty.Edit;
begin
  ShowCollectionEditorClass(Designer, TDBGridColumnsEditor,
    GetComponent(0) as TComponent, TDBGridColumns(GetOrdValue), GetName);
end;

function TCWSDBGridColumnsProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end;

type
  { Component editor for TCWSOptionsPanel. "Add section" creates a
    TCWSOptionsSection owned by the form (so it streams to the DFM), parents it
    to the panel and selects it — you can then drop controls straight onto it.
    "Expand"/"Collapse" toggles the preview at design time. }
  TCWSOptionsPanelEditor = class(TComponentEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

procedure TCWSOptionsPanelEditor.ExecuteVerb(Index: Integer);
var
  Panel: TCWSOptionsPanel;
  Sec: TCWSOptionsSection;
begin
  Panel := Component as TCWSOptionsPanel;
  case Index of
    0:
      begin
        Sec := TCWSOptionsSection.Create(Designer.Root);
        Sec.Name := Designer.UniqueName(TCWSOptionsSection.ClassName);
        Sec.Parent := Panel;
        Panel.Expanded := True;
        Designer.SelectComponent(Sec);
        Designer.Modified;
      end;
    1:
      begin
        Panel.Expanded := not Panel.Expanded;
        Designer.Modified;
      end;
  end;
end;

function TCWSOptionsPanelEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Add section';
    1: if (Component as TCWSOptionsPanel).Expanded then
         Result := 'Collapse'
       else
         Result := 'Expand';
  else
    Result := '';
  end;
end;

function TCWSOptionsPanelEditor.GetVerbCount: Integer;
begin
  Result := 2;
end;

type
  { Icon picker for TImageIndex properties.

    Without it an ImageIndex is a bare number and the icon numbering has to be
    memorised. This editor puts the glyph of the component's image list in front
    of that number, in the grid row and in every entry of the drop-down, so an
    icon can be picked by sight. Typing a number still works.

    The image list is located through the published "Images" property of the
    edited component, so the editor fits any component built that way, not just
    TCWSSystemMenu.

    Only the glyph is painted here — the number stays the plain property value
    and is rendered by the Object Inspector's own themed painter. Drawing the
    text ourselves does not survive the IDE's dark theme: the ambient brush is
    not the row background everywhere the interfaces are called, which is what
    produced the stray white blocks. For the same reason ICustomPropertyDrawing80
    is implemented — it tells the grid that only the glyph square is ours, the
    rest of the cell stays with the IDE, exactly as TColorProperty does it. }
  TCWSImageIndexProperty = class(TIntegerProperty, ICustomPropertyListDrawing,
    ICustomPropertyDrawing, ICustomPropertyDrawing80)
  private
    function ImageList: TCustomImageList;
    { fills ARect, paints the glyph at its left edge and returns what is left }
    function PaintGlyph(AIndex: Integer; ACanvas: TCanvas;
      const ARect: TRect): TRect;
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
    { ICustomPropertyListDrawing — the drop-down }
    procedure ListMeasureWidth(const Value: string; ACanvas: TCanvas;
      var AWidth: Integer);
    procedure ListMeasureHeight(const Value: string; ACanvas: TCanvas;
      var AHeight: Integer);
    procedure ListDrawValue(const Value: string; ACanvas: TCanvas;
      const ARect: TRect; ASelected: Boolean);
    { ICustomPropertyDrawing — the value cell of the Object Inspector }
    procedure PropDrawName(ACanvas: TCanvas; const ARect: TRect;
      ASelected: Boolean);
    procedure PropDrawValue(ACanvas: TCanvas; const ARect: TRect;
      ASelected: Boolean);
    { ICustomPropertyDrawing80 — how much of the cell we take over }
    function PropDrawNameRect(const ARect: TRect): TRect;
    function PropDrawValueRect(const ARect: TRect): TRect;
  end;

const
  cIconGap = 4;   { space kept around the glyph }

function TCWSImageIndexProperty.ImageList: TCustomImageList;
var
  Obj: TPersistent;
  Info: PPropInfo;
  Value: TObject;
begin
  Result := nil;
  Obj := GetComponent(0);
  if Obj = nil then
    Exit;
  { qualified — TPropertyEditor has a parameterless GetPropInfo of its own }
  Info := System.TypInfo.GetPropInfo(Obj, 'Images', [tkClass]);
  if Info = nil then
    Exit;
  Value := System.TypInfo.GetObjectProp(Obj, Info, TCustomImageList);
  if Value is TCustomImageList then
    Result := TCustomImageList(Value);
end;

{ The glyph is composed on an opaque copy of the row background before it
  reaches the grid. Blitting an image list straight onto the Object Inspector
  canvas leaves a white block behind every icon that carries an alpha channel;
  the IDE's own TCursorProperty goes through the same detour. A glyph taller
  than the row is skipped rather than clipped — grid rows have a fixed height. }
function TCWSImageIndexProperty.PaintGlyph(AIndex: Integer; ACanvas: TCanvas;
  const ARect: TRect): TRect;
var
  List: TCustomImageList;
  Bmp: TBitmap;
  W, H: Integer;
begin
  ACanvas.FillRect(ARect);
  Result := ARect;

  List := ImageList;
  if List = nil then
    Exit;
  W := List.Width;
  H := List.Height;
  if (W <= 0) or (H <= 0) or (H > ARect.Height) then
    Exit;

  { the gutter is reserved even when this entry has no icon, so the texts of
    all entries line up }
  Result := Rect(ARect.Left + W + cIconGap, ARect.Top, ARect.Right, ARect.Bottom);
  if (AIndex < 0) or (AIndex >= List.Count) then
    Exit;

  Bmp := TBitmap.Create;
  try
    Bmp.PixelFormat := pf32bit;
    Bmp.SetSize(W, H);
    Bmp.Canvas.Brush.Style := bsSolid;
    Bmp.Canvas.Brush.Color := ACanvas.Brush.Color;
    Bmp.Canvas.FillRect(Rect(0, 0, W, H));
    List.Draw(Bmp.Canvas, 0, 0, AIndex, True);
    ACanvas.Draw(ARect.Left, ARect.Top + (ARect.Height - H) div 2, Bmp);
  finally
    Bmp.Free;
  end;
end;

function TCWSImageIndexProperty.GetAttributes: TPropertyAttributes;
begin
  { no paSortList — the entries must stay in image-list order }
  Result := inherited GetAttributes + [paValueList, paRevertable];
end;

procedure TCWSImageIndexProperty.GetValues(Proc: TGetStrProc);
var
  List: TCustomImageList;
  i: Integer;
begin
  Proc('-1');
  List := ImageList;
  if List = nil then
    Exit;
  for i := 0 to List.Count - 1 do
    Proc(IntToStr(i));
end;

procedure TCWSImageIndexProperty.ListMeasureWidth(const Value: string;
  ACanvas: TCanvas; var AWidth: Integer);
var
  List: TCustomImageList;
begin
  { additive — the Object Inspector has already measured the text }
  List := ImageList;
  if List <> nil then
    Inc(AWidth, List.Width + cIconGap);
  Inc(AWidth, PropertyDrawingOffset + cIconGap);
end;

procedure TCWSImageIndexProperty.ListMeasureHeight(const Value: string;
  ACanvas: TCanvas; var AHeight: Integer);
var
  List: TCustomImageList;
begin
  List := ImageList;
  if List <> nil then
    AHeight := Max(AHeight, List.Height + cIconGap);
end;

procedure TCWSImageIndexProperty.ListDrawValue(const Value: string;
  ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);
var
  TextArea: TRect;
begin
  ACanvas.FillRect(ARect);
  TextArea := PaintGlyph(StrToIntDef(Value, -1), ACanvas,
    Rect(ARect.Left + PropertyDrawingOffset, ARect.Top, ARect.Right,
      ARect.Bottom));
  { the IDE's own painter — it knows the theme colours, we do not }
  DefaultPropertyListDrawValue(Value, ACanvas, TextArea, ASelected);
end;

procedure TCWSImageIndexProperty.PropDrawName(ACanvas: TCanvas;
  const ARect: TRect; ASelected: Boolean);
begin
  DefaultPropertyDrawName(Self, ACanvas, ARect);
end;

function TCWSImageIndexProperty.PropDrawNameRect(const ARect: TRect): TRect;
begin
  Result := ARect;
end;

procedure TCWSImageIndexProperty.PropDrawValue(ACanvas: TCanvas;
  const ARect: TRect; ASelected: Boolean);
var
  Idx: Integer;
begin
  { a multi-selection with differing values yields '' — no single glyph to show }
  if TryStrToInt(GetVisualValue, Idx) then
    PaintGlyph(Idx, ACanvas, ARect)
  else
    DefaultPropertyDrawValue(Self, ACanvas, ARect);
end;

{ Only the glyph square belongs to us; the grid paints the text of the value
  itself. An empty rect means "nothing custom here" — used when there is no
  list, or no glyph that fits, so the cell is left entirely to the IDE. }
function TCWSImageIndexProperty.PropDrawValueRect(const ARect: TRect): TRect;
var
  List: TCustomImageList;
  Idx: Integer;
begin
  Result := Rect(0, 0, 0, 0);
  List := ImageList;
  if (List = nil) or (List.Width <= 0) or (List.Height > ARect.Height) then
    Exit;
  if not TryStrToInt(GetVisualValue, Idx) then
    Exit;
  if (Idx < 0) or (Idx >= List.Count) then
    Exit;
  Result := Rect(ARect.Left, ARect.Top, ARect.Left + List.Width + cIconGap,
    ARect.Bottom);
end;

const
  { every CWStudio component that pairs an Images list with one or more
    TImageIndex properties — see the icon picker registration in Register }
  cImageIndexOwners: array[0..7] of TClass = (
    TCWSSystemMenu, TCWSButton, TCWSStoreButton, TCWSMenuButton,
    TCWSEdit, TCWSEditMask, TCWSOptionsPanel, TCWSLabelTrend);

{ ──────────────────────────────────────────────────────────────────────────
    Register components on the palette
  ────────────────────────────────────────────────────────────────────────── }
procedure Register;
var
  Cls: TClass;
begin
  RegisterComponents('CWStudio_Panels',
    [TCWSCornerPanel, TCWSSettingsPanel, TCWSOptionsPanel]);
  { Sections are created through the panel's editor / AddSection, not dropped
    from the palette, but must be registered so they stream to/from the DFM. }
  RegisterNoIcon([TCWSOptionsSection]);
  RegisterComponentEditor(TCWSOptionsPanel, TCWSOptionsPanelEditor);
  RegisterComponents('CWStudio_Buttons',
    [TCWSButton, TCWSStoreButton, TCWSMenuButton, TCWSRadioButton, TCWSCheckBox, TCWSSwitch]);
  RegisterComponents('CWStudio_Edits',
    [TCWSEdit, TCWSEditMask, TCWSComboBox, TCWSMemo, TCWSDatePicker]);
  RegisterComponents('CWStudio_ProgressBars',
    [TCWSProgressCircle, TCWSProgressBar, TCWSIndicatorLoading]);
  RegisterComponents('CWStudio_Menus',
    [TCWSPopupMenu, TCWSSystemMenu]);
  RegisterComponents('CWStudio_ScrollBoxes',
    [TCWSScrollBox]);
  RegisterComponents('CWStudio_Forms',
    [TCWSDimOverlay, TCWSAfterFormShow]);
  RegisterComponents('CWStudio_ListBoxes',
    [TCWSListBox]);
  RegisterComponents('CWStudio_Grids',
    [TCWSStringGrid, TCWSDBGrid]);
  RegisterComponents('CWStudio_Labels',
    [TCWSLabelColumn, TCWSLabelTrend]);

  { The same columns editor as in the real TDBGrid — see TCWSDBGridColumnsProperty }
  RegisterPropertyEditor(TypeInfo(TDBGridColumns), TCWSDBGrid, 'Columns',
    TCWSDBGridColumnsProperty);

  { The same "Input Mask Editor" dialog as the VCL TMaskEdit — the … button on
    the EditMask property opens the mask builder with the predefined mask list. }
  RegisterPropertyEditor(TypeInfo(string), TCWSEditMask, 'EditMask',
    TMaskProperty);

  { Icon picker for every ImageIndex property of the components listed above.
    They are all TImageIndex, so one registration per class covers each of them
    whatever they are called (ImageIndexPressed, LeftImageIndex, the six
    ImageIndex* of the system menu …). Registering per class rather than with a
    nil class keeps the IDE's own picker in place for non-CWStudio components. }
  for Cls in cImageIndexOwners do
    RegisterPropertyEditor(TypeInfo(System.UITypes.TImageIndex), Cls, '',
      TCWSImageIndexProperty);
end;

{ ──────────────────────────────────────────────────────────────────────────
    Splash screen + About Box IDE
  ────────────────────────────────────────────────────────────────────────── }
var
  AboutBoxIndex: Integer = -1;
  SplashBitmap: TBitmap = nil;   { kept alive for the About Box }

function LoadSplashBitmap: TBitmap;
begin
  Result := TBitmap.Create;
  try
    Result.LoadFromResourceName(HInstance, cSplashResName);
  except
    Result.Free;
    raise;
  end;
end;

procedure RegisterSplashScreen;
var
  Bmp: TBitmap;
begin
  if not Assigned(SplashScreenServices) then
    Exit;
  Bmp := LoadSplashBitmap;
  try
    SplashScreenServices.AddPluginBitmap(
      CWStudioCaption,        { 'CWStudio Component 1.6.2' }
      Bmp.Handle,
      False,                  { not an unregistered version }
      CWStudioVersionLabel);  { 'V1.6.2.0' — status field next to the icon }
  finally
    Bmp.Free;               { splash copy bitmap — can free }
  end;
end;

procedure RegisterAboutBox;
var
  AboutSvc: IOTAAboutBoxServices;
begin
  if not Supports(BorlandIDEServices, IOTAAboutBoxServices, AboutSvc) then
    Exit;
  SplashBitmap := LoadSplashBitmap;
  AboutBoxIndex := AboutSvc.AddPluginInfo(
    CWStudioCaption,
    'CWStudio Components Library ' + CWStudioVersionFull + sLineBreak +
    'Modern Windows 11 / WinUI 3 style VCL components for Delphi.' + sLineBreak +
    CWStudioCopyright,
    SplashBitmap.Handle,
    False,
    CWStudioVersionLabel);
end;

procedure UnregisterAboutBox;
var
  AboutSvc: IOTAAboutBoxServices;
begin
  if (AboutBoxIndex <> -1) and
     Supports(BorlandIDEServices, IOTAAboutBoxServices, AboutSvc) then
    AboutSvc.RemovePluginInfo(AboutBoxIndex);
  AboutBoxIndex := -1;
  FreeAndNil(SplashBitmap);
end;

initialization
  RegisterSplashScreen;
  RegisterAboutBox;

finalization
  UnregisterAboutBox;

end.
