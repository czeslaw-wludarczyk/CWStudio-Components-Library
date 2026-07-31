unit panels;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, CWSFluentColorsMulti, CWSSettingsPanel, Vcl.ExtCtrls, CWSCornerPanel, Vcl.StdCtrls,
  CWSScrollBox, CWSOptionsPanel;

type
  TfrmPanels = class(TForm)
    pnl1: TCWSCornerPanel;
    pnl2: TCWSSettingsPanel;
    lblPanel1: TLabel;
    pnlCard1: TCWSSettingsPanel;
    pnlCard2: TCWSSettingsPanel;
    lblIcon1: TLabel;
    lblIcon2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    scrbPanels: TCWSScrollBox;
    pnlOptions: TCWSOptionsPanel;
    sectOpt1: TCWSOptionsSection;
    lblOpt1: TLabel;
    sectOpt2: TCWSOptionsSection;
    lblOpt2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure pnlCard1MouseEnter(Sender: TObject);
    procedure pnlCard1MouseLeave(Sender: TObject);
    procedure pnlCard2MouseEnter(Sender: TObject);
    procedure pnlCard2MouseLeave(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure ApplyTheme;
  public
    { Public declarations }
  end;

var
  frmPanels: TfrmPanels;

implementation

{$R *.dfm}

procedure TfrmPanels.ApplyTheme;
var
  I: integer;
  Comp: TComponent;
begin
  self.Color := flNeutralBackground2;
  scrbPanels.BackgroundColor:= flNeutralBackground2;

  pnl1.Color := flNeutralBackground1;
  pnl1.CornerColor := flBrandBackground3Static;
  lblPanel1.Font.Color := flNeutralForeground1;
  pnl2.Color := flNeutralBackground2;
  pnl2.FillColor := flNeutralBackground3;
  pnl2.BorderColor := flNeutralStroke1;

  for i := 0 to ComponentCount - 1 do
  begin
    Comp := Components[i];
    if Comp is TCWSSettingsPanel then
    begin
      TCWSSettingsPanel(Comp).Color := flNeutralBackground2;
      TCWSSettingsPanel(Comp).FillColor := flNeutralBackground2;
      TCWSSettingsPanel(Comp).BorderColor := flNeutralStroke1;
    end;

    if Comp is TCWSOptionsSection then
    begin
      TCWSOptionsSection(Comp).Color := flNeutralBackground2;
      TCWSOptionsSection(Comp).DividerColor := flNeutralStroke1;
    end;

    if Comp is TLabel then
    begin
      TLabel(Comp).Font.Color := flNeutralForeground1;
    end;
  end;

  pnlOptions.FillColor := flNeutralBackground2;
  pnlOptions.BorderColor := flNeutralStroke1;
  pnlOptions.ChevronColor := flNeutralForeground3;
  pnlOptions.HoverColor := flNeutralBackground2Hover;
  pnlOptions.TitleColor := flNeutralForeground1;
  pnlOptions.SubtitleColor := flNeutralForeground3;

  lblIcon1.Font.Color := clGreen;
  lblIcon2.Font.Color := clWebDarkOrange;

end;

procedure TfrmPanels.FormCreate(Sender: TObject);
begin
  RegisterThemeChange(Self.ApplyTheme);
  FluentApplySystemTheme;
end;

procedure TfrmPanels.FormDestroy(Sender: TObject);
begin
  UnregisterThemeChange(Self.ApplyTheme);
end;

procedure TfrmPanels.FormShow(Sender: TObject);
begin
ScaleForPPI(CurrentPPI);
end;

procedure TfrmPanels.pnlCard1MouseEnter(Sender: TObject);
begin
  pnlCard1.FillColor := flNeutralBackground2Hover;
end;

procedure TfrmPanels.pnlCard1MouseLeave(Sender: TObject);
begin
  pnlCard1.FillColor := flNeutralBackground2;
end;

procedure TfrmPanels.pnlCard2MouseEnter(Sender: TObject);
begin
  pnlCard2.FillColor := flNeutralBackground2Hover;
end;

procedure TfrmPanels.pnlCard2MouseLeave(Sender: TObject);
begin
  pnlCard2.FillColor := flNeutralBackground2;
end;

end.

