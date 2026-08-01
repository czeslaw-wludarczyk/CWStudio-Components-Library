object frmPanels: TfrmPanels
  Left = 0
  Top = 0
  Align = alClient
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'PANELS'
  ClientHeight = 554
  ClientWidth = 801
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 17
  object scrbPanels: TCWSScrollBox
    Left = 0
    Top = 0
    Width = 801
    Height = 554
    ShowBorder = False
    Align = alClient
    TabOrder = 0
    DesignSize = (
      801
      554)
    object pnl1: TCWSCornerPanel
      Left = 16
      Top = 16
      Width = 761
      Height = 73
      Anchors = [akLeft, akTop, akRight]
      BevelOuter = bvNone
      Color = clBlack
      ParentBackground = False
      ShowCaption = False
      TabOrder = 3
      CornerColor = clYellow
      CornerSize = 2
      CornerLineWidth = 2
      object lblPanel1: TLabel
        Left = 0
        Top = 0
        Width = 761
        Height = 73
        Align = alClient
        Alignment = taCenter
        Caption = 'CWSCornerPanel'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
        ExplicitWidth = 144
        ExplicitHeight = 25
      end
    end
    object pnl2: TCWSSettingsPanel
      Left = 15
      Top = 104
      Width = 761
      Height = 80
      Anchors = [akLeft, akTop, akRight]
      DoubleBuffered = True
    end
    object pnlCard1: TCWSSettingsPanel
      Left = 16
      Top = 198
      Width = 224
      Height = 80
      DoubleBuffered = True
      OnMouseEnter = pnlCard1MouseEnter
      OnMouseLeave = pnlCard1MouseLeave
      object lblIcon1: TLabel
        Left = 16
        Top = 16
        Width = 32
        Height = 32
        Caption = #59155
        Font.Charset = ANSI_CHARSET
        Font.Color = clGreen
        Font.Height = -32
        Font.Name = 'Segoe MDL2 Assets'
        Font.Style = []
        ParentFont = False
      end
      object Label3: TLabel
        Left = 54
        Top = 12
        Width = 69
        Height = 20
        Caption = 'Advenced'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label4: TLabel
        Left = 54
        Top = 32
        Width = 96
        Height = 15
        Caption = 'Developer options'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
    end
    object pnlCard2: TCWSSettingsPanel
      Left = 263
      Top = 198
      Width = 225
      Height = 80
      DoubleBuffered = True
      OnMouseEnter = pnlCard2MouseEnter
      OnMouseLeave = pnlCard2MouseLeave
      object lblIcon2: TLabel
        Left = 16
        Top = 16
        Width = 27
        Height = 27
        Caption = #59252
        Font.Charset = ANSI_CHARSET
        Font.Color = clOrange
        Font.Height = -27
        Font.Name = 'Segoe MDL2 Assets'
        Font.Style = []
        ParentFont = False
      end
      object Label5: TLabel
        Left = 49
        Top = 12
        Width = 45
        Height = 20
        Caption = 'Global'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label6: TLabel
        Left = 49
        Top = 32
        Width = 135
        Height = 15
        Caption = 'Region, language options'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
    end
    object pnlOptions: TCWSOptionsPanel
      Left = 16
      Top = 300
      Width = 761
      Height = 181
      Anchors = [akLeft, akTop, akRight]
      DoubleBuffered = True
      Title = 'CWSOptionsPanel'
      Subtitle = 'Collapsible options card with stacked sections'
      Expanded = True
      CornerRadius = 4
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = 1776411
      TitleFont.Height = -13
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = [fsBold]
      SubtitleFont.Charset = DEFAULT_CHARSET
      SubtitleFont.Color = 6316128
      SubtitleFont.Height = -11
      SubtitleFont.Name = 'Segoe UI'
      SubtitleFont.Style = []
      ImageIndex = 0
      IconFontName = 'Segoe MDL2 Assets'
      RoundLastSection = True
      object sectOpt1: TCWSOptionsSection
        Left = 1
        Top = 60
        Width = 759
        Height = 60
        Color = clWhite
        DoubleBuffered = True
        ParentColor = False
        object lblOpt1: TLabel
          Left = 16
          Top = 20
          Width = 173
          Height = 17
          Caption = 'General - first options section'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
      end
      object sectOpt2: TCWSOptionsSection
        Left = 1
        Top = 120
        Width = 759
        Height = 60
        Color = clWhite
        DoubleBuffered = True
        ParentColor = False
        object lblOpt2: TLabel
          Left = 16
          Top = 20
          Width = 205
          Height = 17
          Caption = 'Advanced - second options section'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
      end
    end
  end
end
