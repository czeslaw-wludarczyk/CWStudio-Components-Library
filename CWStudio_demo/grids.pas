unit grids;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, CWSFluentColorsMulti, Vcl.StdCtrls, CWSScrollBox, CWSStringGrid, CWSRadioButton,
  VCL.Grids, CWSEdit, Vcl.WinXCtrls, ES.BaseControls, ES.Switch, CWSListBox;

type
  TfrmGrids = class(TForm)
    CWSScrollBox1: TCWSScrollBox;
    lblTitle1: TLabel;
    CWSEdit1: TCWSEdit;
    lblListBox: TLabel;
    CWSListBox1: TCWSListBox;
    CWSStringGrid1: TCWSStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CWSEdit1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    procedure ApplyTheme;
  public
    { Public declarations }
  end;

var
  frmGrids: TfrmGrids;

implementation

{$R *.dfm}

procedure TfrmGrids.ApplyTheme;
begin
  self.Color := flNeutralBackground2;
  CWSScrollBox1.BackgroundColor := flNeutralBackground2;

  lblTitle1.Font.Color := flNeutralForeground1;


  CWSStringGrid1.BackgroundColor := flNeutralBackground2;
  CWSStringGrid1.BorderColor := flNeutralStroke1;
  CWSStringGrid1.CellTextColor := flNeutralForeground1;
  CWSStringGrid1.CellColor := flNeutralBackground2;
  CWSStringGrid1.FixedColor := flNeutralBackground1;
  CWSStringGrid1.CellHighlightColor := flBrandBackgroundSelected;
  CWSStringGrid1.GridLineColor := flNeutralStroke1;
  CWSStringGrid1.CellTextColor := flNeutralForeground1;
  CWSStringGrid1.Font.Color:= flNeutralForeground1;
  CWSStringGrid1.AlternatingRowColors := True;
  CWSStringGrid1.EvenRowColor:= flNeutralBackground3;

  CWSEdit1.BackgroundColor := flNeutralBackground2;
  CWSEdit1.BackgroundHoverColor := flNeutralBackground4;
  CWSEdit1.BackgroundFocusColor := flNeutralBackground1;
  CWSEdit1.BorderColor := flNeutralStroke1;
  CWSEdit1.Font.Color := flNeutralForeground1;

  lblListBox.Font.Color := flNeutralForeground1;

  CWSListBox1.BackgroundColor := flNeutralBackground2;
  CWSListBox1.BackgroundHoverColor := flNeutralBackground1Hover;
  CWSListBox1.BackgroundFocusColor := flNeutralBackground2;
  CWSListBox1.BorderColor := flNeutralStroke1;
  CWSListBox1.LabelColor := flNeutralForeground2;
  CWSListBox1.AccentColor := flNeutralForeground2BrandPressed;
  CWSListBox1.ScrollThumbColor := flNeutralStroke1;
  CWSListBox1.ScrollThumbHoverColor := flNeutralForeground3;
  CWSListBox1.DisabledColor := flNeutralBackgroundDisabled;
  CWSListBox1.DisabledBorderColor := flNeutralStrokeDisabled;
  CWSListBox1.Font.Color := flNeutralForeground1;

  if FluentThemeMode = ftmDark then
    CWSStringGrid1.HighlightTextColor := clBlack
  else
    CWSStringGrid1.HighlightTextColor := clWhite;

  CWSStringGrid1.FixedTextColor := flNeutralForeground2;
end;

procedure TfrmGrids.CWSEdit1KeyPress(Sender: TObject; var Key: Char);
begin

  if not (Key in ['0'..'9', #8, #13]) then
  begin
    Key := #0; // #0 oznacza "pusty znak", co blokuje wpisanie znaku
  end;

  if Key = #13 then
  begin
    Key := #0;
    if StrToInt(CWSEdit1.Text) > 50 then
      CWSEdit1.Text := '50';
    CWSStringGrid1.CornerRadius := StrToInt(CWSEdit1.Text);
  end;

end;

procedure TfrmGrids.FormCreate(Sender: TObject);
begin
  RegisterThemeChange(Self.ApplyTheme);
  FluentApplySystemTheme;
end;

procedure TfrmGrids.FormDestroy(Sender: TObject);
begin
  unRegisterThemeChange(Self.ApplyTheme);
end;

procedure TfrmGrids.FormShow(Sender: TObject);
var
  i, j: integer;
begin

ScaleForPPI(CurrentPPI);

  CWSStringGrid1.ColCount := 100;
  CWSStringGrid1.RowCount := 10000;

  for i := 0 to 100 do
  begin
    CWSStringGrid1.Cols[i].BeginUpdate;
    try
      for j := 0 to 10000 do
      begin
        if j = 0 then
          CWSStringGrid1.Cells[i, 0] := i.ToString
        else
          CWSStringGrid1.Cells[i, j] := j.ToString;

      end;
    finally
      CWSStringGrid1.Cols[i].EndUpdate;
    end;
  end;
  CWSEdit1.Text := CWSStringGrid1.CornerRadius.ToString;
end;

end.

