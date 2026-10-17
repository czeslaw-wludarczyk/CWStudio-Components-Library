unit forms;

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
  CWSButton,
  Vcl.StdCtrls,
  CWSScrollBox;

type
  TfrmForms = class(TForm)
    lblTitle1: TLabel;
    btnShow: TCWSButton;
    Label1: TLabel;
    scrbForms: TCWSScrollBox;
    lblTitle2: TLabel;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnShowClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure ApplyTheme;
  public
    { Public declarations }
  end;

var
  frmForms: TfrmForms;

implementation

{$R *.dfm}

uses
  main,
  dlg_info;

procedure TfrmForms.ApplyTheme;
var
  I: Integer;
  Comp: TComponent;
begin
  self.Color := flNeutralBackground2;
  scrbForms.BackgroundColor := flNeutralBackground2;

  btnShow.Color := flNeutralBackground2;
  btnShow.BckNormalColor := flBrandBackground;
  btnShow.BckHoverColor := flBrandBackgroundHover;
  btnShow.BckPressedColor := flBrandBackgroundPressed;
  btnShow.BorderColorNormal := flBrandBackground;
  btnShow.BorderColorHover := flBrandBackgroundHover;
  btnShow.BorderColorPressed := flBrandBackgroundPressed;
  btnShow.CaptionColorNormal := clWhite;
  btnShow.CaptionColorHover := clWhite;
  btnShow.CaptionColorPressed := clWhite;
  btnShow.IconColorNormal := clWhite;
  btnShow.IconColorHover := clWhite;
  btnShow.IconColorPressed := clWhite;

  for i := 0 to ComponentCount - 1 do
  begin
    Comp := Components[i];
    if Comp is TLabel then
    begin
      TLabel(Comp).Font.Color := flNeutralForeground1;
    end;
  end;

  Invalidate;
end;

procedure TfrmForms.btnShowClick(Sender: TObject);
begin
  frmMain.CWSDimOverlay1.Visible := True;
  Sleep(2000);
  dlgInfo.PDescription := '';
  dlgInfo.PDescription :=
    'The main window behind this dialog is dimmed by a TCWSDimOverlay component.Close this dialog to fade the overlay back out.';
  dlgInfo.ShowModal;
  frmMain.CWSDimOverlay1.Visible := False;
end;

procedure TfrmForms.FormCreate(Sender: TObject);
begin
  RegisterThemeChange(Self.ApplyTheme);
  FluentApplySystemTheme;
end;

procedure TfrmForms.FormDestroy(Sender: TObject);
begin
  unRegisterThemeChange(Self.ApplyTheme);
end;

procedure TfrmForms.FormShow(Sender: TObject);
begin
  ScaleForPPI(CurrentPPI);
end;

end.

