unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, CWSFluentColorsMulti, Vcl.TitleBarCtrls, Vcl.ExtCtrls, CWSScrollBox, ES.BaseControls,
  ES.Shapes, CWSStoreButton, home, Vcl.StdCtrls, CWSButton, CWSDimOverlay, CWSSystemMenu, Vcl.Menus, CWSPopupMenu;

type
  TfrmMain = class(TForm)
    brTitle: TTitleBarPanel;
    scrbMenu: TCWSScrollBox;
    pnlMenu: TPanel;
    pnlContent: TPanel;
    pnlMenuTitle: TPanel;
    shpContent: TEsShape;
    pnlTitle: TPanel;
    CWSStoreButton1: TCWSStoreButton;
    CWSStoreButton2: TCWSStoreButton;
    CWSStoreButton3: TCWSStoreButton;
    CWSStoreButton4: TCWSStoreButton;
    CWSStoreButton5: TCWSStoreButton;
    CWSStoreButton6: TCWSStoreButton;
    CWSStoreButton7: TCWSStoreButton;
    pnlContentForm: TPanel;
    lblTitle: TLabel;
    btnTheme: TCWSButton;
    CWSDimOverlay1: TCWSDimOverlay;
    CWSStoreButton8: TCWSStoreButton;
    shpLineMenu: TShape;
    CWSStoreButton9: TCWSStoreButton;
    CWSSystemMenu1: TCWSSystemMenu;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnThemeClick(Sender: TObject);
    procedure CWSStoreButton1Click(Sender: TObject);
    procedure CWSStoreButton6Click(Sender: TObject);
    procedure CWSStoreButton2Click(Sender: TObject);
    procedure CWSStoreButton5Click(Sender: TObject);
    procedure CWSStoreButton3Click(Sender: TObject);
    procedure CWSStoreButton4Click(Sender: TObject);
    procedure CWSStoreButton7Click(Sender: TObject);
    procedure CWSStoreButton8Click(Sender: TObject);
    procedure CWSStoreButton9Click(Sender: TObject);
  private
    { Private declarations }
    isDark: Boolean;
    FActiveForm: TForm;
    procedure ApplyTheme;
    procedure ShowChildForm(AForm: TForm);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses edits, panels, forms, buttons, progress_bars, scrollboxes, info, grids;

procedure TfrmMain.ApplyTheme;
var
  I: integer;
  Comp: TComponent;
begin

  //Set colors to form and title bar
  Self.Color := flNeutralBackground1;
  self.CustomTitleBar.BackgroundColor := flNeutralBackground1;
  self.CustomTitleBar.ButtonBackgroundColor := flNeutralBackground1;
  self.CustomTitleBar.ButtonForegroundColor := flNeutralForeground1;
  self.CustomTitleBar.ButtonHoverBackgroundColor := flNeutralBackground1Hover;
  self.CustomTitleBar.ButtonHoverForegroundColor := flNeutralForeground1Hover;
  self.CustomTitleBar.ButtonInactiveBackgroundColor := flNeutralBackground1;
  self.CustomTitleBar.ButtonInactiveForegroundColor := flNeutralForegroundDisabled;
  self.CustomTitleBar.ButtonPressedBackgroundColor := flNeutralBackground1Pressed;
  self.CustomTitleBar.ButtonPressedForegroundColor := flNeutralForeground1Pressed;
  self.CustomTitleBar.ForegroundColor := flNeutralForeground1;
  self.CustomTitleBar.InactiveBackgroundColor := flNeutralBackground1;
  self.CustomTitleBar.InactiveForegroundColor := flNeutralForegroundDisabled;

  //Set colors for labels
  lblTitle.Font.Color := flNeutralForeground1;

  CWSDimOverlay1.IndicatorColor:= flBrandBackground;
  CWSDimOverlay1.IndicatorTrackColor:= flNeutralBackground1;

  //Set colors for panels
  pnlMenu.Color := flNeutralBackground1;
  pnlTitle.Color := flNeutralBackground1;
  pnlContent.Color := flNeutralBackground1;
  pnlContentForm.Color := flNeutralBackground2;
  shpContent.Brush.Color := flNeutralBackground2;
  shpContent.Pen.Color := flNeutralStroke1;
  shpLineMenu.Pen.Color:= flNeutralStroke1;
  pnlMenuTitle.Color := flNeutralBackground1;
  pnlMenuTitle.Font.Color := flNeutralForeground1;
  scrbMenu.BackgroundColor := flNeutralBackground1;

  CWSSystemMenu1.BackgroundColor:= flNeutralBackground1;
  CWSSystemMenu1.TextColor:= flNeutralForeground1;
  CWSSystemMenu1.HighlightColor:= flNeutralBackground1Selected;
  CWSSystemMenu1.BorderColor:= flNeutralStroke1;
  CWSSystemMenu1.DisabledTextColor:= flNeutralForegroundDisabled;
  CWSSystemMenu1.HighlightTextColor:= flNeutralForeground1;
  CWSSystemMenu1.SeparatorColor:= flNeutralStroke1;

  //Set colors for buttons

  btnTheme.Color := flNeutralBackground1;
  btnTheme.BckNormalColor := flNeutralBackground1;
  btnTheme.BckHoverColor := flNeutralBackground1Hover;
  btnTheme.BckPressedColor := flNeutralBackground1Pressed;

  btnTheme.BorderColorNormal := flNeutralStroke1;
  btnTheme.BorderColorHover := flNeutralStroke1;
  btnTheme.BorderColorPressed := flNeutralStroke1;

  btnTheme.IconColorNormal := flNeutralForeground3;
  btnTheme.IconColorHover := flNeutralForeground1Hover;
  btnTheme.IconColorPressed := flNeutralForeground2BrandPressed;

  for i := 0 to ComponentCount - 1 do
  begin
    Comp := Components[i];
    if Comp is TCWSStoreButton then
    begin
      TCWSStoreButton(Comp).Color := flNeutralBackground1;
      TCWSStoreButton(Comp).BckNormalColor := flNeutralBackground1;
      TCWSStoreButton(Comp).BckHoverColor := flNeutralBackground1Hover;
      TCWSStoreButton(Comp).BckPressedColor := flNeutralBackground1Pressed;

      TCWSStoreButton(Comp).DescriptionColorHover := flNeutralForeground1Hover;
      TCWSStoreButton(Comp).DescriptionColorNormal := flNeutralForeground3;
      TCWSStoreButton(Comp).DescriptionColorPressed := flNeutralForeground2BrandPressed;

      TCWSStoreButton(Comp).IconColorHover := flNeutralForeground1Hover;
      TCWSStoreButton(Comp).IconColorNormal := flNeutralForeground3;
      TCWSStoreButton(Comp).IconColorPressed := flNeutralForeground2BrandPressed;

      TCWSStoreButton(Comp).CursorColor := flNeutralForeground2BrandPressed;

    end;

  end;

  Invalidate;

end;

procedure TfrmMain.btnThemeClick(Sender: TObject);
begin
  if isdark then
  begin
    isDark := False;
    FluentApplyTheme(ftmLight);
    btnTheme.IconGlyph := '';
    btnTheme.IconGlyphPressed := '';
    btnTheme.IconOffsetX := 3;
    btnTheme.IconOffsetY := 0;
  end
  else
  begin
    isDark := True;
    FluentApplyTheme(ftmDark);

    btnTheme.IconGlyph := '';
    btnTheme.IconGlyphPressed := '';
    btnTheme.IconOffsetX := 3;
    btnTheme.IconOffsetY := 1;
  end;

end;

procedure TfrmMain.CWSStoreButton1Click(Sender: TObject);
begin
ShowChildForm(frmHome);
end;

procedure TfrmMain.CWSStoreButton2Click(Sender: TObject);
begin
ShowChildForm(frmPanels);
end;

procedure TfrmMain.CWSStoreButton3Click(Sender: TObject);
begin
ShowChildForm(frmButtons);
end;

procedure TfrmMain.CWSStoreButton4Click(Sender: TObject);
begin
ShowChildForm(frmProgressBars);
end;

procedure TfrmMain.CWSStoreButton5Click(Sender: TObject);
begin
ShowChildForm(frmForms);
end;

procedure TfrmMain.CWSStoreButton6Click(Sender: TObject);
begin
  ShowChildForm(frmEdits);
end;

procedure TfrmMain.CWSStoreButton7Click(Sender: TObject);
begin
ShowChildForm(frmScrollBoxes);
end;

procedure TfrmMain.CWSStoreButton8Click(Sender: TObject);
begin
ShowChildForm(frmInfo);
end;

procedure TfrmMain.CWSStoreButton9Click(Sender: TObject);
begin
ShowChildForm(frmGrids);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  RegisterThemeChange(Self.ApplyTheme);
  FluentApplySystemTheme;
  if FluentIsWindowsDarkMode then
  begin
    isDark := True;
    btnTheme.IconGlyph := '';
    btnTheme.IconGlyphPressed := '';
    btnTheme.IconOffsetX := 3;
    btnTheme.IconOffsetY := 1;
  end
  else
  begin
    btnTheme.IconGlyph := '';
    btnTheme.IconGlyphPressed := '';

    btnTheme.IconOffsetX := 3;
    btnTheme.IconOffsetY := 0;
  end;

end;

procedure TfrmMAin.ShowChildForm(AForm: TForm);
begin
if FActiveForm = AForm then
    Exit;

  if Assigned(FActiveForm) then
  begin
    FActiveForm.Close;
    FActiveForm := nil;
  end;

  AForm.Parent := pnlContentForm;
  AForm.Show;
  lblTitle.Caption := AForm.Caption;
  FActiveForm := AForm;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  UnregisterThemeChange(Self.ApplyTheme);
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  ShowChildForm(frmHome);
end;

end.

