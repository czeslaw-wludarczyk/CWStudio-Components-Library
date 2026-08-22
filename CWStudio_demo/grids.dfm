object frmGrids: TfrmGrids
  Left = 0
  Top = 0
  Align = alClient
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'frmGrids'
  ClientHeight = 562
  ClientWidth = 640
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 15
  object CWSScrollBox1: TCWSScrollBox
    Left = 0
    Top = 0
    Width = 640
    Height = 562
    ShowBorder = False
    ScrollbarRenderMode = srmBlended
    Align = alClient
    TabOrder = 0
    DesignSize = (
      640
      562)
    object lblTitle1: TLabel
      Left = 24
      Top = 24
      Width = 396
      Height = 25
      Caption = 'CWSStrinGrid - StringGrid with WinUI3 look'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object CWSEdit1: TCWSEdit
      Left = 488
      Top = 64
      Width = 123
      Height = 45
      Cursor = crIBeam
      Text = ''
      LabelText = 'Corner radius'
      CornerRadius = 4.000000000000000000
      OnKeyPress = CWSEdit1KeyPress
      Anchors = [akTop, akRight]
      TabOrder = 3
      TabStop = True
    end
    object CWSStringGrid1: TCWSStringGrid
      Left = 24
      Top = 64
      Width = 433
      Height = 475
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goFixedRowDefAlign]
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 5
      CornerRadiusF = 6.000000000000000000
    end
    object lblListBox: TLabel
      Left = 488
      Top = 128
      Width = 90
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'CWSListBox'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object CWSListBox1: TCWSListBox
      Left = 488
      Top = 160
      Width = 123
      Height = 379
      Items.Strings = (
        'Alpha'
        'Bravo'
        'Charlie'
        'Delta'
        'Echo'
        'Foxtrot'
        'Golf'
        'Hotel'
        'India'
        'Juliet')
      LabelText = 'Items'
      IntegralHeight = False
      ItemHeight = 15
      Anchors = [akTop, akRight, akBottom]
      TabOrder = 4
      CornerRadiusF = 4.000000000000000000
    end
  end
end
