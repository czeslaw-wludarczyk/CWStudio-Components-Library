unit edits;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, CWSFluentColorsMulti, CWSSettingsPanel, CWSScrollBox, Vcl.StdCtrls, System.ImageList,
  Vcl.ImgList, SVGIconImageListBase, SVGIconImageList, CWSEdit, CWSMemo, CWSDatePicker, CWSComboBox, CWSEditMask;

type
  TfrmEdits = class(TForm)
    SVGIconImageList1: TSVGIconImageList;
    scrbEdits: TCWSScrollBox;
    pnlEdits1: TCWSSettingsPanel;
    lblTitle1: TLabel;
    CWSEdit1: TCWSEdit;
    CWSEdit2: TCWSEdit;
    CWSEdit3: TCWSEdit;
    CWSEdit4: TCWSEdit;
    CWSEdit5: TCWSEdit;
    CWSEdit11: TCWSEdit;
    pnlEdits2: TCWSSettingsPanel;
    lblTitle2: TLabel;
    CWSEdit6: TCWSEdit;
    CWSEdit7: TCWSEdit;
    CWSEdit8: TCWSEdit;
    CWSEdit9: TCWSEdit;
    CWSEdit10: TCWSEdit;
    CWSEdit12: TCWSEdit;
    pnlEdits3: TCWSSettingsPanel;
    lblTitle3: TLabel;
    CWSMemo1: TCWSMemo;
    CWSMemo2: TCWSMemo;
    CWSMemo3: TCWSMemo;
    pnlEdits4: TCWSSettingsPanel;
    lblTitle4: TLabel;
    CWSComboBox1: TCWSComboBox;
    CWSComboBox2: TCWSComboBox;
    CWSComboBox3: TCWSComboBox;
    CWSDatePicker2: TCWSDatePicker;
    CWSDatePicker3: TCWSDatePicker;
    CWSDatePicker1: TCWSDatePicker;
    pnlEdits5: TCWSSettingsPanel;
    lblTitle5: TLabel;
    CWSEditMask1: TCWSEditMask;
    CWSEditMask2: TCWSEditMask;
    CWSEditMask3: TCWSEditMask;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CWSEdit8ButtonClick(Sender: TObject);
    procedure CWSEdit3ButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure ApplyTheme;
  public
    { Public declarations }
  end;

var
  frmEdits: TfrmEdits;

implementation

{$R *.dfm}

uses
  dlg_info, main;

procedure TfrmEdits.ApplyTheme;
var
  I: integer;
  Comp: TComponent;
begin
  self.Color := flNeutralBackground2;
  scrbEdits.BackgroundColor := flNeutralBackground2;

  pnlEdits1.Color := flNeutralBackground2;
  pnlEdits1.FillColor := flNeutralBackground3;
  pnlEdits1.BorderColor := flNeutralStroke1;
  pnlEdits2.Color := flNeutralBackground2;
  pnlEdits2.FillColor := flNeutralBackground3;
  pnlEdits2.BorderColor := flNeutralStroke1;
  pnlEdits3.Color := flNeutralBackground2;
  pnlEdits3.FillColor := flNeutralBackground3;
  pnlEdits3.BorderColor := flNeutralStroke1;
  pnlEdits4.Color := flNeutralBackground2;
  pnlEdits4.FillColor := flNeutralBackground3;
  pnlEdits4.BorderColor := flNeutralStroke1;
  pnlEdits5.Color := flNeutralBackground2;
  pnlEdits5.FillColor := flNeutralBackground3;
  pnlEdits5.BorderColor := flNeutralStroke1;

  lblTitle1.Font.Color := flNeutralForeground1;
  lblTitle2.Font.Color := flNeutralForeground1;
  lblTitle3.Font.Color := flNeutralForeground1;
  lblTitle4.Font.Color := flNeutralForeground1;
  lblTitle5.Font.Color := flNeutralForeground1;

  for I := 0 to ComponentCount - 1 do
  begin
    Comp := Components[I];
    if Comp is TCWSEdit then
    begin
      TCWSEdit(Comp).BackgroundColor := flNeutralBackground2;
      TCWSEdit(Comp).BackgroundFocusColor := flNeutralBackground2;
      TCWSEdit(Comp).BackgroundHoverColor := flNeutralBackground1Hover;
      TCWSEdit(Comp).BorderColor := flNeutralStroke1;
      TCWSEdit(Comp).ButtonHoverColor := flNeutralBackground2Hover;
      TCWSEdit(Comp).ButtonPressedColor := flNeutralBackground2Selected;

      TCWSEdit(Comp).ButtonIconColor := flNeutralForeground1;
      TCWSEdit(Comp).DisabledColor := flNeutralBackgroundDisabled;
      TCWSEdit(Comp).DisabledBorderColor := flNeutralStrokeDisabled;

      TCWSEdit(Comp).LabelColor := flNeutralForeground2;

      TCWSEdit(Comp).AccentColor := flNeutralForeground2BrandPressed;

      TCWSEdit(Comp).Font.Color := flNeutralForeground1;

      SVGIconImageList1.FixedColor := flNeutralForeground1;
    end;

    if Comp is TCWSEditMask then
    begin
      TCWSEditMask(Comp).BackgroundColor := flNeutralBackground2;
      TCWSEditMask(Comp).BackgroundFocusColor := flNeutralBackground2;
      TCWSEditMask(Comp).BackgroundHoverColor := flNeutralBackground1Hover;
      TCWSEditMask(Comp).BorderColor := flNeutralStroke1;
      TCWSEditMask(Comp).ButtonHoverColor := flNeutralBackground2Hover;
      TCWSEditMask(Comp).ButtonPressedColor := flNeutralBackground2Selected;
      TCWSEditMask(Comp).ButtonIconColor := flNeutralForeground1;
      TCWSEditMask(Comp).DisabledColor := flNeutralBackgroundDisabled;
      TCWSEditMask(Comp).DisabledBorderColor := flNeutralStrokeDisabled;
      TCWSEditMask(Comp).LabelColor := flNeutralForeground2;
      TCWSEditMask(Comp).AccentColor := flNeutralForeground2BrandPressed;
      TCWSEditMask(Comp).Font.Color := flNeutralForeground1;
    end;

    if Comp is TCWSMemo then
    begin
      TCWSMemo(Comp).BackgroundColor := flNeutralBackground2;
      TCWSMemo(Comp).BackgroundFocusColor := flNeutralBackground2;
      TCWSMemo(Comp).BackgroundHoverColor := flNeutralBackground1Hover;
      TCWSMemo(Comp).BorderColor := flNeutralStroke1;

      TCWSMemo(Comp).DisabledColor := flNeutralBackgroundDisabled;
      TCWSMemo(Comp).DisabledBorderColor := flNeutralStrokeDisabled;

      TCWSMemo(Comp).LabelColor := flNeutralForeground2;

      TCWSMemo(Comp).AccentColor := flNeutralForeground2BrandPressed;

      TCWSMemo(Comp).Font.Color := flNeutralForeground1;
    end;

    if Comp is TCWSComboBox then
    begin
      TCWSComboBox(Comp).BackgroundColor := flNeutralBackground2;
      TCWSComboBox(Comp).DropdownBackColor := flNeutralBackground2;
      TCWSComboBox(Comp).BackgroundHoverColor := flNeutralBackground1Hover;
      TCWSComboBox(Comp).BorderColor := flNeutralStroke1;
      TCWSComboBox(Comp).DropdownBorderColor := flNeutralStroke1;

      TCWSComboBox(Comp).DisabledColor := flNeutralBackgroundDisabled;
      TCWSComboBox(Comp).DisabledBorderColor := flNeutralStrokeDisabled;

      TCWSComboBox(Comp).AccentColor := flNeutralForeground2BrandPressed;

      TCWSComboBox(Comp).Font.Color := flNeutralForeground1;
      TCWSComboBox(Comp).ItemHighlightColor := flNeutralBackground1Selected;
      TCWSComboBox(Comp).ItemHighlightPressedColor := flNeutralBackground1Selected;
      TCWSComboBox(Comp).ItemHighlightTextColor := flNeutralForeground2;
      TCWSComboBox(Comp).ItemNormalTextColor := flNeutralForeground1;
      TCWSComboBox(Comp).TextColor := flNeutralForeground1;
    end;

    if Comp is TCWSDatePicker then
    begin
      TCWSDatePicker(Comp).BackgroundColor := flNeutralBackground2;
      TCWSDatePicker(Comp).DropdownBackColor := flNeutralBackground2;
      TCWSDatePicker(Comp).BackgroundHoverColor := flNeutralBackground1Hover;
      TCWSDatePicker(Comp).HoverColor := flNeutralBackground3Hover;
      TCWSDatePicker(Comp).HoverTextColor := flNeutralForeground1;
      TCWSDatePicker(Comp).BorderColor := flNeutralStroke1;
      TCWSDatePicker(Comp).SelectedDayColor := flNeutralForeground2BrandPressed;

      TCWSDatePicker(Comp).DisabledColor := flNeutralBackgroundDisabled;
      TCWSDatePicker(Comp).DisabledBorderColor := flNeutralStrokeDisabled;

      TCWSDatePicker(Comp).AccentColor := flNeutralForeground2BrandPressed;
      TCWSDatePicker(Comp).TodayBorderColor := flNeutralForeground2BrandPressed;
      TCWSDatePicker(Comp).TodayHoverTextColor := flNeutralForeground1;
      TCWSDatePicker(Comp).TodayTextColor := flNeutralForeground1;
      TCWSDatePicker(Comp).LinkTextColor := flNeutralForeground1;

      TCWSDatePicker(Comp).Font.Color := flNeutralForeground1;
      TCWSDatePicker(Comp).TextColor := flNeutralForeground1;
      TCWSDatePicker(Comp).SelectedDayTextColor := flNeutralForeground1;
    end;
  end;

  Invalidate;
end;

procedure TfrmEdits.CWSEdit3ButtonClick(Sender: TObject);
begin
  if Trim(CWSEdit3.Text) <> '' then
  begin
    frmMain.CWSDimOverlay1.Visible := True;
    dlgInfo.PDescription := '';
    dlgInfo.PDescription := 'You search:' + CWSEdit3.Text;
    dlgInfo.ShowModal;
    frmMain.CWSDimOverlay1.Visible := False;
  end;
end;

procedure TfrmEdits.CWSEdit8ButtonClick(Sender: TObject);
begin
  if Trim(CWSEdit8.Text) <> '' then
  begin
    frmMain.CWSDimOverlay1.Visible := True;
    dlgInfo.PDescription := '';
    dlgInfo.PDescription := 'You search:' + CWSEdit8.Text;
    dlgInfo.ShowModal;
    frmMain.CWSDimOverlay1.Visible := False;
  end;
end;

procedure TfrmEdits.FormCreate(Sender: TObject);
begin
  RegisterThemeChange(Self.ApplyTheme);
  FluentApplySystemTheme;
end;

procedure TfrmEdits.FormDestroy(Sender: TObject);
begin
  unRegisterThemeChange(Self.ApplyTheme);
end;

procedure TfrmEdits.FormShow(Sender: TObject);
begin
  ScaleForPPI(CurrentPPI);
end;

end.

