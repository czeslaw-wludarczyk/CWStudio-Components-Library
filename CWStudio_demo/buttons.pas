unit buttons;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.Types, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus, CWSSettingsPanel, CWSScrollBox, CWSStoreButton,
  CWSFluentColorsMulti, CWSMenuButton, CWSButton, CWSCheckBox, CWSRadioButton, CWSSwitch, CWSPopupMenu, System.ImageList,
  Vcl.ImgList, SVGIconImageListBase, SVGIconImageList;

type
  TfrmButtons = class(TForm)
    scrbEdits: TCWSScrollBox;
    pnlEdits1: TCWSSettingsPanel;
    lblTitle1: TLabel;
    pnlEdits2: TCWSSettingsPanel;
    lblTitle2: TLabel;
    pnlEdits3: TCWSSettingsPanel;
    lblTitle3: TLabel;
    CWSStoreButton1: TCWSStoreButton;
    CWSStoreButton2: TCWSStoreButton;
    CWSStoreButton3: TCWSStoreButton;
    CWSStoreButton4: TCWSStoreButton;
    CWSStoreButton5: TCWSStoreButton;
    Label1: TLabel;
    Label2: TLabel;
    CWSMenuButton1: TCWSMenuButton;
    Label3: TLabel;
    CWSMenuButton2: TCWSMenuButton;
    CWSMenuButton3: TCWSMenuButton;
    CWSStoreButton6: TCWSStoreButton;
    CWSStoreButton7: TCWSStoreButton;
    CWSButton1: TCWSButton;
    CWSButton2: TCWSButton;
    CWSButton3: TCWSButton;
    CWSButton4: TCWSButton;
    CWSButton5: TCWSButton;
    CWSButton6: TCWSButton;
    CWSButton7: TCWSButton;
    CWSButton8: TCWSButton;
    CWSButton9: TCWSButton;
    SVGIconImageList1: TSVGIconImageList;
    pnlEdits4: TCWSSettingsPanel;
    lblTitle4: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    CWSCheckBox1: TCWSCheckBox;
    CWSCheckBox2: TCWSCheckBox;
    CWSRadioButton1: TCWSRadioButton;
    CWSRadioButton2: TCWSRadioButton;
    CWSSwitch1: TCWSSwitch;
    CWSSwitch2: TCWSSwitch;
    btnPopup: TCWSButton;
    CWSPopupMenu1: TCWSPopupMenu;
    miNew: TMenuItem;
    miOpen: TMenuItem;
    miSave: TMenuItem;
    miSep1: TMenuItem;
    miExit: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CWSStoreButton4Click(Sender: TObject);
    procedure CWSStoreButton5Click(Sender: TObject);
    procedure CWSStoreButton6Click(Sender: TObject);
    procedure CWSStoreButton7Click(Sender: TObject);
    procedure btnPopupClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FPressed1, FPressed2, FPressed3, FPressed4: Boolean;

    procedure ApplyTheme;
  public
    { Public declarations }
  end;

var
  frmButtons: TfrmButtons;

implementation

{$R *.dfm}

procedure TfrmButtons.ApplyTheme;
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

  lblTitle1.Font.Color := flNeutralForeground1;
  lblTitle2.Font.Color := flNeutralForeground1;
  lblTitle3.Font.Color := flNeutralForeground1;
  lblTitle4.Font.Color := flNeutralForeground1;

  SVGIconImageList1.SVGIconItems.Items[1].FixedColor:= flNeutralForeground1;

  CWSPopupMenu1.BackgroundColor := flNeutralBackground1;
  CWSPopupMenu1.BorderColor := flNeutralStroke1;
  CWSPopupMenu1.TextColor := flNeutralForeground1;
  CWSPopupMenu1.DisabledTextColor := flNeutralForegroundDisabled;
  CWSPopupMenu1.HighlightColor := flNeutralBackground1Hover;
  CWSPopupMenu1.HighlightTextColor := flNeutralForeground1;
  CWSPopupMenu1.SeparatorColor := flNeutralStroke1;
  CWSPopupMenu1.ShortCutColor := flNeutralForeground3;

  for I := 0 to ComponentCount - 1 do
  begin
    Comp := Components[I];
    if Comp is TCWSStoreButton then
    begin
      TCWSStoreButton(Comp).Color := flNeutralBackground3;
      TCWSStoreButton(Comp).BckNormalColor := flNeutralBackground3;
      TCWSStoreButton(Comp).BckHoverColor := flNeutralBackground3Hover;
      TCWSStoreButton(Comp).BckPressedColor := flNeutralBackground1Pressed;

      TCWSStoreButton(Comp).DescriptionColorHover := flNeutralForeground1Hover;
      TCWSStoreButton(Comp).DescriptionColorNormal := flNeutralForeground3;
      TCWSStoreButton(Comp).DescriptionColorPressed := flNeutralForeground2BrandPressed;

      TCWSStoreButton(Comp).IconColorHover := flNeutralForeground1Hover;
      TCWSStoreButton(Comp).IconColorNormal := flNeutralForeground3;
      TCWSStoreButton(Comp).IconColorPressed := flNeutralForeground2BrandPressed;

      TCWSStoreButton(Comp).CursorColor := flNeutralForeground2BrandPressed;
    end;

    if Comp is TCWSMenuButton then
    begin
      TCWSMenuButton(Comp).Color := flNeutralBackground3;
      TCWSMenuButton(Comp).BckNormalColor := flNeutralBackground3;
      TCWSMenuButton(Comp).BckHoverColor := flNeutralBackground3Hover;
      TCWSMenuButton(Comp).BckPressedColor := flNeutralBackground1Pressed;

      TCWSMenuButton(Comp).MenuColorTextHover := flNeutralForeground1Hover;
      TCWSMenuButton(Comp).MenuColorTextNormal := flNeutralForeground3;
      TCWSMenuButton(Comp).MenuColorTextPressed := flNeutralForeground2BrandPressed;

      TCWSMenuButton(Comp).IconColorHover := flNeutralForeground1Hover;
      TCWSMenuButton(Comp).IconColorNormal := flNeutralForeground3;
      TCWSMenuButton(Comp).IconColorPressed := flNeutralForeground2BrandPressed;

      TCWSMenuButton(Comp).CursorColor := flNeutralForeground2BrandPressed;
    end;

    if Comp is TCWSCheckBox then
    begin
      TCWSCheckBox(Comp).BoxColorNormal := flNeutralForeground3;
      TCWSCheckBox(Comp).BoxColorChecked := flBrandBackground;
      TCWSCheckBox(Comp).BoxColorDisabled := flNeutralStrokeDisabled;
      TCWSCheckBox(Comp).FillColorNormal := flNeutralBackground3;
      TCWSCheckBox(Comp).FillColorDisabled := flNeutralBackgroundDisabled;
      TCWSCheckBox(Comp).CheckColor := clWhite;
      TCWSCheckBox(Comp).FontColorNormal := flNeutralForeground1;
      TCWSCheckBox(Comp).FontColorChecked := flNeutralForeground1;
      TCWSCheckBox(Comp).FontColorDisabled := flNeutralForegroundDisabled;
    end;

    if Comp is TCWSRadioButton then
    begin
      TCWSRadioButton(Comp).RadioColorNormal := flNeutralForeground3;
      TCWSRadioButton(Comp).RadioColorChecked := flBrandBackground;
      TCWSRadioButton(Comp).RadioColorDisabled := flNeutralStrokeDisabled;
      TCWSRadioButton(Comp).FillColorNormal := flNeutralBackground3;
      TCWSRadioButton(Comp).FillColorDisabled := flNeutralBackgroundDisabled;
      TCWSRadioButton(Comp).DotColor := clWhite;
      TCWSRadioButton(Comp).FontColorNormal := flNeutralForeground1;
      TCWSRadioButton(Comp).FontColorChecked := flNeutralForeground1;
      TCWSRadioButton(Comp).FontColorDisabled := flNeutralForegroundDisabled;
    end;

    if Comp is TCWSSwitch then
    begin
      TCWSSwitch(Comp).TrackColorNormal := flNeutralBackground3;
      TCWSSwitch(Comp).TrackColorChecked := flBrandBackground;
      TCWSSwitch(Comp).TrackColorDisabled := flNeutralBackgroundDisabled;
      TCWSSwitch(Comp).BorderColorNormal := flNeutralForeground3;
      TCWSSwitch(Comp).KnobColorNormal := flNeutralForeground3;
      TCWSSwitch(Comp).KnobColorChecked := clWhite;
      TCWSSwitch(Comp).KnobColorDisabled := flNeutralForegroundDisabled;
      TCWSSwitch(Comp).FontColorNormal := flNeutralForeground1;
      TCWSSwitch(Comp).FontColorChecked := flNeutralForeground1;
      TCWSSwitch(Comp).FontColorDisabled := flNeutralForegroundDisabled;
    end;

    if Comp is TCWSButton then
    begin

      if Comp.Name = 'CWSButton3' then
        continue;

      TCWSButton(Comp).Color := flNeutralBackground3;
      TCWSButton(Comp).BckNormalColor := flNeutralBackground3;
      TCWSButton(Comp).BckHoverColor := flNeutralBackground3Hover;
      TCWSButton(Comp).BckPressedColor := flNeutralBackground1Pressed;
      TCWSButton(Comp).BckDisabledColor := flNeutralBackgroundDisabled;

      TCWSButton(Comp).BorderColorNormal := flNeutralStroke1;
      TCWSButton(Comp).BorderColorHover := flNeutralStroke1;
      TCWSButton(Comp).BorderColorPressed := flNeutralStroke1;
      TCWSButton(Comp).BorderColorDisabled := flNeutralStrokeDisabled;

      TCWSButton(Comp).CaptionColorHover := flNeutralForeground1Hover;
      TCWSButton(Comp).CaptionColorNormal := flNeutralForeground3;
      TCWSButton(Comp).CaptionColorPressed := flNeutralForeground3;
      TCWSButton(Comp).CaptionColorDisabled := flNeutralForegroundDisabled;

      TCWSButton(Comp).IconColorHover := flNeutralForeground1Hover;
      TCWSButton(Comp).IconColorNormal := flNeutralForeground3;
      TCWSButton(Comp).IconColorPressed := flNeutralForeground2BrandPressed;
    end;

    CWSButton3.Color := flNeutralBackground3;

    if Comp is TLabel then
    begin
      TLabel(Comp).Font.Color := flNeutralForeground1;
    end;
  end;

  Invalidate;
end;

procedure TfrmButtons.CWSStoreButton4Click(Sender: TObject);
begin
  if FPressed1 then
  begin
    CWSStoreButton4.Pressed := False;
    FPressed1 := False;
    Exit;
  end
  else
  begin
    CWSStoreButton4.Pressed := True;
    FPressed1 := True;
  end;
end;

procedure TfrmButtons.CWSStoreButton5Click(Sender: TObject);
begin
  if FPressed2 then
  begin
    CWSStoreButton5.Pressed := False;
    FPressed2 := False;
    Exit;
  end
  else
  begin
    CWSStoreButton5.Pressed := True;
    FPressed2 := True;
  end;
end;

procedure TfrmButtons.CWSStoreButton6Click(Sender: TObject);
begin
  if FPressed3 then
  begin
    CWSStoreButton6.Pressed := False;
    FPressed3 := False;
    Exit;
  end
  else
  begin
    CWSStoreButton6.Pressed := True;
    FPressed3 := True;
  end;
end;

procedure TfrmButtons.CWSStoreButton7Click(Sender: TObject);
begin
  if FPressed4 then
  begin
    CWSStoreButton7.Pressed := False;
    FPressed4 := False;
    Exit;
  end
  else
  begin
    CWSStoreButton7.Pressed := True;
    FPressed4 := True;
  end;
end;

procedure TfrmButtons.btnPopupClick(Sender: TObject);
var
  P: TPoint;
begin
  P := btnPopup.ClientToScreen(Point(0, btnPopup.Height));
  CWSPopupMenu1.Popup(P.X, P.Y);
end;

procedure TfrmButtons.FormCreate(Sender: TObject);
begin
  RegisterThemeChange(Self.ApplyTheme);
  FluentApplySystemTheme;
end;

procedure TfrmButtons.FormDestroy(Sender: TObject);
begin
  unRegisterThemeChange(Self.ApplyTheme);
end;

procedure TfrmButtons.FormShow(Sender: TObject);
begin
  ScaleForPPI(CurrentPPI);
end;

end.

