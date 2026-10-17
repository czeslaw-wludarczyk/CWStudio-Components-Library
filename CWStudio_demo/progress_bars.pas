unit progress_bars;

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
  CWSFluentColorsMulti,
  CWSScrollBox,
  CWSProgressCircle,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  CWSProgressBar,
  CWSIndicatorLoading;

type
  TfrmProgressBars = class(TForm)
    scrbProgressBars: TCWSScrollBox;
    CWSProgressCircle1: TCWSProgressCircle;
    CWSProgressCircle2: TCWSProgressCircle;
    CWSProgressCircle3: TCWSProgressCircle;
    CWSProgressCircle4: TCWSProgressCircle;
    CWSProgressCircle5: TCWSProgressCircle;
    CWSProgressCircle6: TCWSProgressCircle;
    CWSProgressCircle7: TCWSProgressCircle;
    Timer1: TTimer;
    Label1: TLabel;
    CWSProgressBar1: TCWSProgressBar;
    CWSProgressBar2: TCWSProgressBar;
    CWSProgressBar3: TCWSProgressBar;
    CWSProgressBar4: TCWSProgressBar;
    Label2: TLabel;
    CWSProgressBar5: TCWSProgressBar;
    CWSProgressBar6: TCWSProgressBar;
    CWSIndicatorLoading1: TCWSIndicatorLoading;
    CWSIndicatorLoading2: TCWSIndicatorLoading;
    CWSIndicatorLoading3: TCWSIndicatorLoading;
    Label3: TLabel;
    CWSIndicatorLoading4: TCWSIndicatorLoading;
    CWSIndicatorLoading5: TCWSIndicatorLoading;
    CWSIndicatorLoading6: TCWSIndicatorLoading;
    Label4: TLabel;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FProgressDir: Integer;
    procedure ApplyTheme;
  public
    { Public declarations }
  end;

var
  frmProgressBars: TfrmProgressBars;

implementation

{$R *.dfm}

procedure TfrmProgressBars.ApplyTheme;
var
  I: Integer;
  Comp: TComponent;
begin
  self.Color := flNeutralBackground2;
  scrbProgressBars.BackgroundColor := flNeutralBackground2;

  CWSProgressCircle1.TextColor := flNeutralForeground1;
  Label1.Font.Color := flNeutralForeground1;
  Label2.Font.Color := flNeutralForeground1;
  Label3.Font.Color := flNeutralForeground1;

  Invalidate;
end;

procedure TfrmProgressBars.FormCreate(Sender: TObject);
begin
  RegisterThemeChange(Self.ApplyTheme);
  FluentApplySystemTheme;
  FProgressDir := 1;
end;

procedure TfrmProgressBars.FormDestroy(Sender: TObject);
begin
  unRegisterThemeChange(Self.ApplyTheme);
end;

procedure TfrmProgressBars.FormShow(Sender: TObject);
begin
  ScaleForPPI(CurrentPPI);
end;

procedure TfrmProgressBars.Timer1Timer(Sender: TObject);
var
  V: Double;
begin
  if not Assigned(CWSProgressCircle1) then
    Exit;
  V := CWSProgressCircle1.Value + (FProgressDir * 1);
  V := CWSProgressBar2.Value + (FProgressDir * 1);
  if V >= 100 then
  begin
    V := 100;
    FProgressDir := -1;
  end else
    if V <= 0 then
    begin
      V := 0;
      FProgressDir := 1;
    end;
  CWSProgressCircle1.Value := V;
  CWSProgressBar2.Value := V;
end;

end.

