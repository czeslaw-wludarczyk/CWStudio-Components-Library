unit dlg_info;

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
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  CWSButton,
  Vcl.TitleBarCtrls,
  CWSFluentColorsMulti;

type
  TdlgInfo = class(TForm)
    lblTitle: TLabel;
    pnlBottom: TPanel;
    btnOK: TCWSButton;
    shpLineBottom: TShape;
    brTitle: TTitleBarPanel;
    lblDescription: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure ApplyTheme;
  public
    { Public declarations }
    PDescription: string;
  end;

var
  dlgInfo: TdlgInfo;

implementation

{$R *.dfm}

uses
  main;

procedure TdlgInfo.ApplyTheme;
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
  lblDescription.Font.Color := flNeutralForeground2;

  //Set colors for panels
  pnlBottom.Color := flNeutralBackground2;
  shpLineBottom.Pen.Color := flNeutralStroke2;

  btnOK.Color := flNeutralBackground2;
  btnOK.BckNormalColor := flBrandBackground;
  btnOK.BckHoverColor := flBrandBackgroundHover;
  btnOK.BckPressedColor := flBrandBackgroundPressed;
  btnOK.BorderColorNormal := flBrandBackground;
  btnOK.BorderColorHover := flBrandBackgroundHover;
  btnOK.BorderColorPressed := flBrandBackgroundPressed;
  btnOK.CaptionColorNormal := clWhite;
  btnOK.CaptionColorHover := clWhite;
  btnOK.CaptionColorPressed := clWhite;
  btnOK.IconColorNormal := clWhite;
  btnOK.IconColorHover := clWhite;
  btnOK.IconColorPressed := clWhite;

  Invalidate;

end;

procedure TdlgInfo.btnOKClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TdlgInfo.FormCreate(Sender: TObject);
begin
  RegisterThemeChange(Self.ApplyTheme);
  FluentApplySystemTheme;
end;

procedure TdlgInfo.FormDestroy(Sender: TObject);
begin
  unRegisterThemeChange(Self.ApplyTheme);
end;

procedure TdlgInfo.FormShow(Sender: TObject);
var
  TargetPPI: Integer;
begin
  TargetPPI := Screen.MonitorFromWindow(frmMain.Handle, mdNearest).PixelsPerInch;
  if TargetPPI <> CurrentPPI then
    ScaleForPPI(TargetPPI);

  self.Left := frmMain.Left + (frmMain.ClientWidth div 2 - self.ClientWidth div 2);
  self.Top := frmMain.Top + (frmMain.ClientHeight div 2 - self.ClientHeight div 2);
  lblDescription.Caption := PDescription;
end;

end.

