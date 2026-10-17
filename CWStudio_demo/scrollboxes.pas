unit scrollboxes;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  CWSScrollBox,
  CWSFluentColorsMulti,
  Vcl.Imaging.jpeg,
  Vcl.ExtCtrls,
  Vcl.StdCtrls;

type
  TfrmScrollBoxes = class(TForm)
    scrb1: TCWSScrollBox;
    CWSScrollBox1: TCWSScrollBox;
    Image1: TImage;
    CWSScrollBox2: TCWSScrollBox;
    Label1: TLabel;
    Label2: TLabel;
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
  frmScrollBoxes: TfrmScrollBoxes;

implementation

{$R *.dfm}

{ TfrmScrollBoxes }

procedure TfrmScrollBoxes.ApplyTheme;
begin
  self.Color := flNeutralBackground2;
  scrb1.BackgroundColor := flNeutralBackground2;
  CWSScrollBox1.BackgroundColor := flNeutralBackground2;
  CWSScrollBox1.ScrollThumbColor := flPaletteLightGreenForeground1;
  CWSScrollBox1.ScrollThumbHoverColor := flPaletteLightGreenForeground2;

  CWSScrollBox2.BackgroundColor := flNeutralBackground2;
  Label1.Font.Color := flNeutralForeground1;
  Label2.Font.Color := flNeutralForeground1;
end;

procedure TfrmScrollBoxes.FormCreate(Sender: TObject);
begin
  RegisterThemeChange(Self.ApplyTheme);
  FluentApplySystemTheme;
end;

procedure TfrmScrollBoxes.FormDestroy(Sender: TObject);
begin
  unRegisterThemeChange(Self.ApplyTheme);
end;

procedure TfrmScrollBoxes.FormShow(Sender: TObject);
const
  PanelCount = 500;
  VirtualWidth = 10000;
  VirtualHeight = 10000;
var
  i: Integer;
  P: TPanel;
begin
  ScaleForPPI(CurrentPPI);

  for I := 1 to PanelCount do
  begin
    P := TPanel.Create(CWSScrollBox2);
    P.Parent := CWSScrollBox2;

    P.Width := 150 + Random(100);
    P.Height := 150 + Random(100);

    P.Left := Random(VirtualWidth - P.Width);
    P.Top := Random(VirtualHeight - P.Height);

    P.Caption := IntToStr(I);

    P.Color := RGB(
      Random(256),
      Random(256),
      Random(256)
    );

    P.ParentBackground := False;
  end;
end;

end.

