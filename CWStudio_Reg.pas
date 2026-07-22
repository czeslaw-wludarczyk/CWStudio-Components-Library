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
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.DBGrids,
  ToolsAPI,
  DesignIntf,
  DesignEditors,
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

{ ──────────────────────────────────────────────────────────────────────────
    Register components on the palette
  ────────────────────────────────────────────────────────────────────────── }
procedure Register;
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
    [TCWSPopupMenu]);
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
