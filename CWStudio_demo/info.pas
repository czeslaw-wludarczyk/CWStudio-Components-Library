unit info;

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
  Vcl.StdCtrls,
  Winapi.ShellAPI,
  CWSButton,
  Vcl.Imaging.pngimage,
  Vcl.ExtCtrls,
  CWSStringGrid,
  CWSListBox,
  SVGIconImage;

type
  TfrmInfo = class(TForm)
    CWSScrollBox1: TCWSScrollBox;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    CWSButton1: TCWSButton;
    imgLogo: TImage;
    procedure CWSButton1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure ApplyTheme;
  public
    { Public declarations }
  end;

var
  frmInfo: TfrmInfo;

implementation

{$R *.dfm}

{ TfrmInfo }

procedure TfrmInfo.ApplyTheme;
begin
  self.Color := flNeutralBackground2;
  CWSScrollBox1.BackgroundColor := flNeutralBackground2;
  CWSButton1.Color := flNeutralBackground2;

  Label1.Font.Color := flNeutralForeground1;
  Label3.Font.Color := flNeutralForeground1;
  Label4.Font.Color := flNeutralForeground5;

end;

procedure TfrmInfo.CWSButton1Click(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('https://paypal.me/czeslaw80'), nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmInfo.FormCreate(Sender: TObject);
begin
  RegisterThemeChange(Self.ApplyTheme);
  FluentApplySystemTheme;
end;

procedure TfrmInfo.FormDestroy(Sender: TObject);
begin
  unRegisterThemeChange(Self.ApplyTheme);
end;

procedure TfrmInfo.FormShow(Sender: TObject);
begin
  ScaleForPPI(CurrentPPI);
end;

end.

