object dlgInfo: TdlgInfo
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'dlgInfo'
  ClientHeight = 198
  ClientWidth = 440
  Color = clBtnFace
  CustomTitleBar.Control = brTitle
  CustomTitleBar.Enabled = True
  CustomTitleBar.SystemHeight = False
  CustomTitleBar.ShowCaption = False
  CustomTitleBar.ShowIcon = False
  CustomTitleBar.SystemColors = False
  CustomTitleBar.SystemButtons = False
  CustomTitleBar.BackgroundColor = 13924352
  CustomTitleBar.ForegroundColor = clWhite
  CustomTitleBar.InactiveBackgroundColor = clWhite
  CustomTitleBar.InactiveForegroundColor = 10066329
  CustomTitleBar.ButtonForegroundColor = clWhite
  CustomTitleBar.ButtonBackgroundColor = 13924352
  CustomTitleBar.ButtonHoverForegroundColor = clWhite
  CustomTitleBar.ButtonHoverBackgroundColor = 11166464
  CustomTitleBar.ButtonPressedForegroundColor = clWhite
  CustomTitleBar.ButtonPressedBackgroundColor = 7028224
  CustomTitleBar.ButtonInactiveForegroundColor = 10066329
  CustomTitleBar.ButtonInactiveBackgroundColor = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  GlassFrame.Enabled = True
  GlassFrame.Top = 1
  Position = poDefault
  StyleElements = [seFont, seClient]
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 17
  object lblTitle: TLabel
    AlignWithMargins = True
    Left = 10
    Top = 10
    Width = 420
    Height = 25
    Margins.Left = 10
    Margins.Top = 10
    Margins.Right = 10
    Align = alTop
    Caption = 'Info!!!'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    ExplicitWidth = 55
  end
  object lblDescription: TLabel
    AlignWithMargins = True
    Left = 10
    Top = 48
    Width = 420
    Height = 83
    Margins.Left = 10
    Margins.Top = 10
    Margins.Right = 10
    Align = alClient
    Caption = 
      'The main window behind this dialog is dimmed by a TCWSDimOverlay' +
      ' component.Close this dialog to fade the overlay back out.'
    WordWrap = True
    ExplicitTop = 47
    ExplicitWidth = 412
    ExplicitHeight = 34
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 134
    Width = 440
    Height = 64
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      440
      64)
    object shpLineBottom: TShape
      Left = 0
      Top = 0
      Width = 440
      Height = 1
      Align = alTop
      ExplicitWidth = 497
    end
    object btnOK: TCWSButton
      Left = 280
      Top = 16
      Width = 150
      Height = 35
      Anchors = [akRight, akBottom]
      TabOrder = 0
      IconFontName = 'Segoe MDL2 Assets'
      BckNormalColor = clWhite
      BckHoverColor = clWhitesmoke
      BckPressedColor = 14737632
      BorderColorNormal = 13750737
      BorderColorHover = 13092807
      BorderColorPressed = 11776947
      Caption = 'OK'
      IconColorNormal = 2368548
      IconColorHover = 2368548
      IconColorPressed = 2368548
      CaptionColorNormal = 2368548
      CaptionColorHover = 2368548
      CaptionColorPressed = 2368548
      BckDisabledColor = 15790320
      BorderColorDisabled = 14737632
      CaptionColorDisabled = 12434877
      IconColorDisabled = 12434877
      OnClick = btnOKClick
    end
  end
  object brTitle: TTitleBarPanel
    Left = 0
    Top = 38
    Width = 440
    Height = 0
    CustomButtons = <>
  end
end
