unit home;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, CWSFluentColorsMulti, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Imaging.pngimage, SVGIconImage,
  CWSLabelColumn, CWSLabelTrend;

type
  TfrmHome = class(TForm)
    lblDescription: TLabel;
    imgLogo: TImage;
    CWSLabelColumn1: TCWSLabelColumn;
    lblTrendTitle: TLabel;
    CWSLabelTrend1: TCWSLabelTrend;
    CWSLabelTrend2: TCWSLabelTrend;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure ApplyTheme;
  public
    { Public declarations }
  end;

var
  frmHome: TfrmHome;

implementation

{$R *.dfm}

procedure TfrmHome.ApplyTheme;
begin
  self.Color:= flNeutralBackground2;
  lblDescription.Font.Color:= flNeutralForeground1;
  CWSLabelColumn1.LeftFont.Color:= flNeutralForeground1;
  CWSLabelColumn1.RightFont.Color:= flNeutralForeground1;

  lblTrendTitle.Font.Color := flNeutralForeground1;

  CWSLabelTrend1.Color := flNeutralBackground3;
  CWSLabelTrend1.BorderColor := flNeutralStroke1;
  CWSLabelTrend1.Font.Color := flNeutralForeground1;
  CWSLabelTrend1.IconColor := flPaletteLightGreenForeground1;

  CWSLabelTrend2.Color := flNeutralBackground3;
  CWSLabelTrend2.BorderColor := flNeutralStroke1;
  CWSLabelTrend2.Font.Color := flNeutralForeground1;
  CWSLabelTrend2.IconColor := clRed;
end;

procedure TfrmHome.FormCreate(Sender: TObject);
begin
  RegisterThemeChange(Self.ApplyTheme);
  FluentApplySystemTheme;
end;

procedure TfrmHome.FormDestroy(Sender: TObject);
begin
  UnregisterThemeChange(Self.ApplyTheme);
end;

procedure TfrmHome.FormShow(Sender: TObject);
begin
 ScaleForPPI(CurrentPPI);
end;

end.

