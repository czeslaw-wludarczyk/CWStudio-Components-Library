object frmProgressBars: TfrmProgressBars
  Left = 0
  Top = 0
  Align = alClient
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'PROGRESS BARS'
  ClientHeight = 833
  ClientWidth = 963
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
  object scrbProgressBars: TCWSScrollBox
    Left = 0
    Top = 0
    Width = 963
    Height = 833
    ShowBorder = False
    ScrollStyle = cssVertical
    ScrollbarRenderMode = srmBlended
    Align = alClient
    TabOrder = 0
    DesignSize = (
      963
      833)
    object Label1: TLabel
      Left = 32
      Top = 24
      Width = 468
      Height = 25
      Caption = 'TCWSProgressCircle '#8212' animated GDI+ progress ring'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object CWSProgressCircle1: TCWSProgressCircle
      Left = 32
      Top = 104
      Width = 241
      Height = 201
      Value = 65.000000000000000000
      MaxValue = 100.000000000000000000
      TrackColor = 15658734
      ProgressColor = 680148
      TextColor = clBlack
    end
    object CWSProgressCircle2: TCWSProgressCircle
      Left = 304
      Top = 104
      Width = 153
      Height = 137
      Value = 75.000000000000000000
      MaxValue = 100.000000000000000000
      TrackColor = 14850132
      ProgressColor = clSkyBlue
      TextColor = 16744448
    end
    object CWSProgressCircle4: TCWSProgressCircle
      Left = 463
      Top = 104
      Width = 153
      Height = 137
      Value = 34.000000000000000000
      MaxValue = 100.000000000000000000
      TrackColor = clDarkgreen
      ProgressColor = clLime
      TextColor = clMoneyGreen
    end
    object CWSProgressCircle5: TCWSProgressCircle
      Left = 622
      Top = 104
      Width = 153
      Height = 137
      Value = 65.000000000000000000
      MaxValue = 100.000000000000000000
      TrackColor = clPurple
      ProgressColor = clFuchsia
      TextColor = clBlack
      ShowText = False
    end
    object CWSProgressCircle3: TCWSProgressCircle
      Left = 304
      Top = 247
      Width = 153
      Height = 137
      Value = 100.000000000000000000
      MaxValue = 100.000000000000000000
      TrackColor = 15658734
      ProgressColor = clYellow
      TextColor = clBlack
      CustomText = 'DONE'
      StartAngle = 50.000000000000000000
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object CWSProgressCircle6: TCWSProgressCircle
      Left = 463
      Top = 247
      Width = 153
      Height = 137
      Value = 50.000000000000000000
      MaxValue = 100.000000000000000000
      TrackColor = clBlack
      ProgressColor = clOlive
      TextColor = clOlive
      RoundCaps = False
      StartAngle = 45.000000000000000000
    end
    object CWSProgressCircle7: TCWSProgressCircle
      Left = 622
      Top = 247
      Width = 153
      Height = 137
      Value = 60.000000000000000000
      MaxValue = 100.000000000000000000
      TrackColor = clGrayText
      ProgressColor = clActiveBorder
      TextColor = clBlack
      ShowText = False
      RoundCaps = False
    end
    object Label2: TLabel
      Left = 32
      Top = 424
      Width = 540
      Height = 25
      Caption = 'TCWSProgressBar - colorful, rounded and rectangular edges'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object CWSProgressBar1: TCWSProgressBar
      Left = 53
      Top = 488
      Width = 220
      Height = 17
      Value = 57.000000000000000000
      MaxValue = 100.000000000000000000
    end
    object CWSProgressBar5: TCWSProgressBar
      Left = 317
      Top = 488
      Width = 220
      Height = 17
      Value = 57.000000000000000000
      MaxValue = 100.000000000000000000
      RoundCaps = False
    end
    object CWSProgressBar2: TCWSProgressBar
      Left = 53
      Top = 528
      Width = 220
      Height = 17
      Value = 82.000000000000000000
      MaxValue = 100.000000000000000000
      BackgroundColor = clGray
      TextColor = clWhite
      ShowText = True
    end
    object CWSProgressBar6: TCWSProgressBar
      Left = 317
      Top = 528
      Width = 220
      Height = 17
      Value = 82.000000000000000000
      MaxValue = 100.000000000000000000
      BackgroundColor = clSkyBlue
      TextColor = clWhite
      ShowText = True
      RoundCaps = False
    end
    object CWSProgressBar3: TCWSProgressBar
      Left = 53
      Top = 568
      Width = 484
      Height = 17
      Value = 23.000000000000000000
      MaxValue = 100.000000000000000000
      BackgroundColor = clMaroon
      ProgressColor = clRed
      TextColor = clWhite
      ShowText = True
      ShowPercent = False
    end
    object CWSProgressBar4: TCWSProgressBar
      Left = 53
      Top = 600
      Width = 484
      Height = 9
      Value = 93.000000000000000000
      MaxValue = 100.000000000000000000
      ProgressColor = clGreen
      ShowPercent = False
    end
    object Label3: TLabel
      Left = 32
      Top = 664
      Width = 619
      Height = 25
      Caption = 
        'TCWSIndicatorLoading - 4 style, colorful, resizable, speed anima' +
        'tion...'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object CWSIndicatorLoading5: TCWSIndicatorLoading
      Left = 374
      Top = 695
      Width = 83
      Height = 82
      IndicatorStyle = cilSegmented
      ActiveColor = clGreen
      SegmentCount = 10
      Speed = 100
    end
    object CWSIndicatorLoading6: TCWSIndicatorLoading
      Left = 481
      Top = 695
      Width = 104
      Height = 82
      IndicatorStyle = cilArrows
      ActiveColor = clLightsalmon
      Gap = 3
      Speed = 500
    end
    object CWSIndicatorLoading1: TCWSIndicatorLoading
      Left = 32
      Top = 711
      Width = 48
      Height = 48
      ActiveColor = clBlack
      Speed = 350
    end
    object CWSIndicatorLoading2: TCWSIndicatorLoading
      Left = 104
      Top = 711
      Width = 48
      Height = 48
      IndicatorStyle = cilArrows
      ActiveColor = clMediumpurple
      SegmentCount = 8
      Gap = 3
      Speed = 200
    end
    object CWSIndicatorLoading3: TCWSIndicatorLoading
      Left = 190
      Top = 711
      Width = 48
      Height = 48
      IndicatorStyle = cilRing
      ActiveColor = clLime
      Speed = 250
    end
    object CWSIndicatorLoading4: TCWSIndicatorLoading
      Left = 270
      Top = 711
      Width = 48
      Height = 48
      IndicatorStyle = cilSegmented
      ActiveColor = clSkyBlue
      SegmentCount = 8
      Speed = 50
    end
    object Label4: TLabel
      Left = 0
      Top = 783
      Width = 945
      Height = 25
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = ' '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object Timer1: TTimer
    Interval = 20
    OnTimer = Timer1Timer
    Left = 776
    Top = 376
  end
end
