object frmButtons: TfrmButtons
  Left = 0
  Top = 0
  Align = alClient
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'BUTTONS'
  ClientHeight = 695
  ClientWidth = 951
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
  object scrbEdits: TCWSScrollBox
    Left = 0
    Top = 0
    Width = 951
    Height = 695
    ShowBorder = False
    ScrollbarRenderMode = srmBlended
    Align = alClient
    TabOrder = 0
    DesignSize = (
      951
      695)
    object pnlEdits1: TCWSSettingsPanel
      Left = 40
      Top = 40
      Width = 815
      Height = 274
      Anchors = [akLeft, akTop, akRight]
      DoubleBuffered = True
      object lblTitle1: TLabel
        Left = 16
        Top = 16
        Width = 160
        Height = 25
        Caption = 'CWSStoreButtons'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label1: TLabel
        Left = 16
        Top = 47
        Width = 76
        Height = 17
        Caption = 'GroupInddex'
      end
      object Label2: TLabel
        Left = 340
        Top = 47
        Width = 125
        Height = 17
        Caption = 'Without GroupInddex'
      end
      object CWSStoreButton1: TCWSStoreButton
        Left = 23
        Top = 70
        Width = 63
        Height = 57
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -9
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        IconFontName = 'Segoe MDL2 Assets'
        BckNormalColor = clBtnFace
        BckHoverColor = clSilver
        BckPressedColor = clWhite
        CursorColor = clGray
        IconGlyph = #59407
        IconGlyphPressed = #60042
        DescriptionText = 'Home'
        Pressed = False
        GroupIndex = 1
        IconColorNormal = clGray
        IconColorHover = clBlack
        IconColorPressed = clGray
        DescriptionColorNormal = clGray
        DescriptionColorHover = clBlack
        DescriptionColorPressed = clGray
      end
      object CWSStoreButton2: TCWSStoreButton
        Left = 23
        Top = 135
        Width = 63
        Height = 57
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -9
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        IconFontName = 'Segoe MDL2 Assets'
        BckNormalColor = clBtnFace
        BckHoverColor = clSilver
        BckPressedColor = clWhite
        CursorColor = clGray
        IconGlyph = #59259
        IconGlyphPressed = #59259
        DescriptionText = 'User'
        Pressed = False
        GroupIndex = 1
        IconColorNormal = clGray
        IconColorHover = clBlack
        IconColorPressed = clGray
        DescriptionColorNormal = clGray
        DescriptionColorHover = clBlack
        DescriptionColorPressed = clGray
      end
      object CWSStoreButton3: TCWSStoreButton
        Left = 23
        Top = 198
        Width = 63
        Height = 57
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -9
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        IconFontName = 'Segoe MDL2 Assets'
        BckNormalColor = clBtnFace
        BckHoverColor = clSilver
        BckPressedColor = clWhite
        CursorColor = clGray
        IconGlyph = #59897
        IconGlyphPressed = #59897
        DescriptionText = 'Report'
        Pressed = False
        GroupIndex = 1
        IconColorNormal = clGray
        IconColorHover = clBlack
        IconColorPressed = clGray
        DescriptionColorNormal = clGray
        DescriptionColorHover = clBlack
        DescriptionColorPressed = clGray
      end
      object CWSStoreButton4: TCWSStoreButton
        Left = 328
        Top = 72
        Width = 63
        Height = 57
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -9
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        IconFontName = 'Segoe MDL2 Assets'
        BckNormalColor = clBtnFace
        BckHoverColor = clSilver
        BckPressedColor = clWhite
        CursorColor = clGray
        IconGlyph = #59407
        IconGlyphPressed = #60042
        DescriptionText = 'Home'
        Pressed = False
        IconColorNormal = clGray
        IconColorHover = clBlack
        IconColorPressed = clGray
        DescriptionColorNormal = clGray
        DescriptionColorHover = clBlack
        DescriptionColorPressed = clGray
        OnClick = CWSStoreButton4Click
      end
      object CWSStoreButton5: TCWSStoreButton
        Left = 408
        Top = 72
        Width = 63
        Height = 57
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -9
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        IconFontName = 'Segoe MDL2 Assets'
        BckNormalColor = clBtnFace
        BckHoverColor = clSilver
        BckPressedColor = clWhite
        CursorColor = clGray
        IconGlyph = #59259
        IconGlyphPressed = #59259
        DescriptionText = 'User'
        Pressed = False
        IconColorNormal = clGray
        IconColorHover = clBlack
        IconColorPressed = clGray
        DescriptionColorNormal = clGray
        DescriptionColorHover = clBlack
        DescriptionColorPressed = clGray
        OnClick = CWSStoreButton5Click
      end
      object CWSStoreButton6: TCWSStoreButton
        Left = 328
        Top = 152
        Width = 97
        Height = 89
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -9
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        IconFontName = 'Segoe MDL2 Assets'
        BckNormalColor = clBtnFace
        BckHoverColor = clSilver
        BckPressedColor = clWhite
        CursorColor = clGray
        CursorHeight = 45
        IconGlyph = #59407
        IconGlyphPressed = #60042
        DescriptionText = 'Home'
        Pressed = False
        IconColorNormal = clGray
        IconColorHover = clBlack
        IconColorPressed = clGray
        DescriptionColorNormal = clGray
        DescriptionColorHover = clBlack
        DescriptionColorPressed = clGray
        OnClick = CWSStoreButton6Click
      end
      object CWSStoreButton7: TCWSStoreButton
        Left = 447
        Top = 152
        Width = 98
        Height = 89
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -9
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        IconFontName = 'Segoe MDL2 Assets'
        BckNormalColor = clBtnFace
        BckHoverColor = clSilver
        BckPressedColor = clWhite
        CursorColor = clGray
        CursorHeight = 45
        IconGlyph = #59259
        IconGlyphPressed = #59259
        DescriptionText = 'User'
        Pressed = False
        IconColorNormal = clGray
        IconColorHover = clBlack
        IconColorPressed = clGray
        DescriptionColorNormal = clGray
        DescriptionColorHover = clBlack
        DescriptionColorPressed = clGray
        OnClick = CWSStoreButton7Click
      end
    end
    object pnlEdits2: TCWSSettingsPanel
      Left = 40
      Top = 338
      Width = 815
      Height = 207
      Anchors = [akLeft, akTop, akRight]
      DoubleBuffered = True
      object lblTitle2: TLabel
        Left = 16
        Top = 16
        Width = 164
        Height = 25
        Caption = 'CWSMenuButtons'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label3: TLabel
        Left = 16
        Top = 49
        Width = 76
        Height = 17
        Caption = 'GroupInddex'
      end
      object CWSMenuButton1: TCWSMenuButton
        Left = 16
        Top = 72
        Width = 300
        Height = 35
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        IconFontName = 'Segoe MDL2 Assets'
        BckNormalColor = clBtnFace
        BckHoverColor = clSilver
        BckPressedColor = clWhite
        CursorColor = clGray
        IconGlyph = #59407
        IconGlyphPressed = #60042
        MenuText = 'Home'
        Pressed = False
        GroupIndex = 1
        IconColorNormal = clGray
        IconColorHover = clBlack
        IconColorPressed = clGray
        MenuColorTextNormal = clGray
        MenuColorTextHover = clBlack
        MenuColorTextPressed = clGray
      end
      object CWSMenuButton2: TCWSMenuButton
        Left = 16
        Top = 113
        Width = 300
        Height = 35
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        IconFontName = 'Segoe MDL2 Assets'
        BckNormalColor = clBtnFace
        BckHoverColor = clSilver
        BckPressedColor = clWhite
        CursorColor = clGray
        IconGlyph = #59259
        IconGlyphPressed = #59259
        MenuText = 'User'
        Pressed = False
        GroupIndex = 1
        IconColorNormal = clGray
        IconColorHover = clBlack
        IconColorPressed = clGray
        MenuColorTextNormal = clGray
        MenuColorTextHover = clBlack
        MenuColorTextPressed = clGray
      end
      object CWSMenuButton3: TCWSMenuButton
        Left = 16
        Top = 154
        Width = 300
        Height = 35
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        IconFontName = 'Segoe MDL2 Assets'
        BckNormalColor = clBtnFace
        BckHoverColor = clSilver
        BckPressedColor = clWhite
        CursorColor = clGray
        IconGlyph = #59897
        IconGlyphPressed = #59897
        MenuText = 'Report'
        Pressed = False
        GroupIndex = 1
        IconColorNormal = clGray
        IconColorHover = clBlack
        IconColorPressed = clGray
        MenuColorTextNormal = clGray
        MenuColorTextHover = clBlack
        MenuColorTextPressed = clGray
      end
    end
    object pnlEdits3: TCWSSettingsPanel
      Left = 40
      Top = 576
      Width = 815
      Height = 215
      Anchors = [akLeft, akTop, akRight]
      DoubleBuffered = True
      object lblTitle3: TLabel
        Left = 16
        Top = 16
        Width = 112
        Height = 25
        Caption = 'CWSButtons'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object CWSButton1: TCWSButton
        Left = 16
        Top = 71
        Width = 150
        Height = 35
        Color = clBtnFace
        TabOrder = 0
        IconFontName = 'Segoe MDL2 Assets'
        BckNormalColor = clWhite
        BckHoverColor = clWhitesmoke
        BckPressedColor = 14737632
        BorderColorNormal = 13750737
        BorderColorHover = 13092807
        BorderColorPressed = 11776947
        Caption = 'Button'
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
      end
      object CWSButton2: TCWSButton
        Left = 194
        Top = 71
        Width = 150
        Height = 35
        Color = clBtnFace
        Enabled = False
        TabOrder = 1
        IconFontName = 'Segoe MDL2 Assets'
        BckNormalColor = clWhite
        BckHoverColor = clWhitesmoke
        BckPressedColor = 14737632
        BorderColorNormal = 13750737
        BorderColorHover = 13092807
        BorderColorPressed = 11776947
        Caption = 'Disabled'
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
      end
      object CWSButton3: TCWSButton
        Left = 373
        Top = 71
        Width = 150
        Height = 35
        Color = clBtnFace
        TabOrder = 2
        ButtonStyle = bsCustom
        IconFontName = 'Segoe MDL2 Assets'
        BckNormalColor = 12413967
        BckHoverColor = 10706449
        BckPressedColor = 6175500
        BorderColorNormal = 12413967
        BorderColorHover = 10706449
        BorderColorPressed = 6175500
        Caption = 'Primary'
        IconColorNormal = clWhite
        IconColorHover = clWhite
        IconColorPressed = clWhite
        CaptionColorNormal = clWhite
        CaptionColorHover = clWhite
        CaptionColorPressed = clWhite
        BckDisabledColor = 15790320
        BorderColorDisabled = 14737632
        CaptionColorDisabled = 12434877
        IconColorDisabled = 12434877
      end
      object CWSButton4: TCWSButton
        Left = 552
        Top = 71
        Width = 150
        Height = 35
        Color = clBtnFace
        TabOrder = 3
        IconFontName = 'Segoe MDL2 Assets'
        BckNormalColor = clWhite
        BckHoverColor = clWhitesmoke
        BckPressedColor = 14737632
        BorderColorNormal = 13750737
        BorderColorHover = 13092807
        BorderColorPressed = 11776947
        IconGlyph = #59188
        IconGlyphPressed = #59189
        Caption = 'Favorite'
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
      end
      object CWSButton5: TCWSButton
        Left = 552
        Top = 128
        Width = 150
        Height = 73
        Color = clBtnFace
        TabOrder = 4
        IconFontName = 'Segoe MDL2 Assets'
        BckNormalColor = clWhite
        BckHoverColor = clWhitesmoke
        BckPressedColor = 14737632
        BorderColorNormal = 13750737
        BorderColorHover = 13092807
        BorderColorPressed = 11776947
        IconGlyph = #59188
        IconGlyphPressed = #59662
        Caption = 'Favorite'
        IconColorNormal = 2368548
        IconColorHover = 2368548
        IconColorPressed = 2368548
        CaptionColorNormal = 2368548
        CaptionColorHover = 2368548
        CaptionColorPressed = 2368548
        IconPosition = ipTop
        BckDisabledColor = 15790320
        BorderColorDisabled = 14737632
        CaptionColorDisabled = 12434877
        IconColorDisabled = 12434877
      end
      object CWSButton6: TCWSButton
        Left = 373
        Top = 128
        Width = 150
        Height = 73
        Color = clBtnFace
        TabOrder = 5
        IconFontName = 'Segoe MDL2 Assets'
        BckNormalColor = clWhite
        BckHoverColor = clWhitesmoke
        BckPressedColor = 14737632
        BorderColorNormal = 13750737
        BorderColorHover = 13092807
        BorderColorPressed = 11776947
        IconGlyph = #59662
        IconGlyphPressed = #59662
        Caption = 'Favorite'
        IconColorNormal = 2368548
        IconColorHover = 2368548
        IconColorPressed = 2368548
        CaptionColorNormal = 2368548
        CaptionColorHover = 2368548
        CaptionColorPressed = 2368548
        IconPosition = ipBottom
        BckDisabledColor = 15790320
        BorderColorDisabled = 14737632
        CaptionColorDisabled = 12434877
        IconColorDisabled = 12434877
      end
      object CWSButton7: TCWSButton
        Left = 194
        Top = 128
        Width = 150
        Height = 73
        Color = clBtnFace
        TabOrder = 6
        IconFontName = 'Segoe MDL2 Assets'
        BckNormalColor = clWhite
        BckHoverColor = clWhitesmoke
        BckPressedColor = 14737632
        BorderColorNormal = 13750737
        BorderColorHover = 13092807
        BorderColorPressed = 11776947
        IconGlyph = #59232
        IconGlyphPressed = #59232
        Caption = 'Favorite'
        IconColorNormal = 2368548
        IconColorHover = 2368548
        IconColorPressed = 2368548
        CaptionColorNormal = 2368548
        CaptionColorHover = 2368548
        CaptionColorPressed = 2368548
        IconPosition = ipRight
        BckDisabledColor = 15790320
        BorderColorDisabled = 14737632
        CaptionColorDisabled = 12434877
        IconColorDisabled = 12434877
      end
      object CWSButton8: TCWSButton
        Left = 16
        Top = 128
        Width = 150
        Height = 73
        Color = clBtnFace
        TabOrder = 7
        IconFontName = 'Segoe MDL2 Assets'
        BckNormalColor = clWhite
        BckHoverColor = clWhitesmoke
        BckPressedColor = 14737632
        BorderColorNormal = 13750737
        BorderColorHover = 13092807
        BorderColorPressed = 11776947
        IconGlyph = #59232
        IconGlyphPressed = #59232
        Caption = 'Favorite'
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
      end
      object CWSButton9: TCWSButton
        Left = 720
        Top = 87
        Width = 90
        Height = 90
        Color = clBtnFace
        TabOrder = 8
        IconFontName = 'Segoe MDL2 Assets'
        BckNormalColor = clWhite
        BckHoverColor = clWhitesmoke
        BckPressedColor = 14737632
        BorderColorNormal = 13750737
        BorderColorHover = 13092807
        BorderColorPressed = 11776947
        IconGlyph = #59188
        IconGlyphPressed = #59189
        Caption = 'Custom'
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
        IconMode = icmImageList
        Images = SVGIconImageList1
        ImageIndex = 0
        ImageIndexPressed = 0
      end
    end
    object pnlEdits4: TCWSSettingsPanel
      Left = 40
      Top = 811
      Width = 815
      Height = 220
      Anchors = [akLeft, akTop, akRight]
      DoubleBuffered = True
      object lblTitle4: TLabel
        Left = 16
        Top = 16
        Width = 441
        Height = 25
        Caption = 'CWSCheckBox  /  CWSRadioButton  /  CWSSwitch'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label4: TLabel
        Left = 24
        Top = 52
        Width = 68
        Height = 17
        Caption = 'CheckBoxes'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object Label5: TLabel
        Left = 264
        Top = 52
        Width = 77
        Height = 17
        Caption = 'RadioButtons'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object Label6: TLabel
        Left = 504
        Top = 52
        Width = 49
        Height = 17
        Caption = 'Switches'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object CWSCheckBox1: TCWSCheckBox
        Left = 24
        Top = 80
        Width = 110
        Height = 18
        Caption = 'Enable feature'
        Checked = True
        BoxColorNormal = 9079434
        BoxColorChecked = 12413967
        BoxColorDisabled = 13092807
        FillColorNormal = clWhite
        FillColorDisabled = 15790320
        CheckColor = clWhite
        FontColorNormal = 2368548
        FontColorChecked = 2368548
        FontColorDisabled = 12434877
        TabOrder = 0
      end
      object CWSCheckBox2: TCWSCheckBox
        Left = 24
        Top = 116
        Width = 98
        Height = 18
        Caption = 'Auto update'
        BoxColorNormal = 9079434
        BoxColorChecked = 12413967
        BoxColorDisabled = 13092807
        FillColorNormal = clWhite
        FillColorDisabled = 15790320
        CheckColor = clWhite
        FontColorNormal = 2368548
        FontColorChecked = 2368548
        FontColorDisabled = 12434877
        TabOrder = 1
      end
      object CWSRadioButton1: TCWSRadioButton
        Left = 264
        Top = 80
        Width = 76
        Height = 18
        Caption = 'Option A'
        Checked = True
        GroupIndex = 1
        RadioSize = 18
        TextSpacing = 6
        RadioColorNormal = 9079434
        RadioColorChecked = 12413967
        RadioColorDisabled = 13092807
        FillColorNormal = clWhite
        FillColorDisabled = 15790320
        DotColor = clWhite
        FontColorNormal = 2368548
        FontColorChecked = 2368548
        FontColorDisabled = 12434877
        TabOrder = 2
      end
      object CWSRadioButton2: TCWSRadioButton
        Left = 264
        Top = 116
        Width = 75
        Height = 18
        Caption = 'Option B'
        GroupIndex = 1
        RadioSize = 18
        TextSpacing = 6
        RadioColorNormal = 9079434
        RadioColorChecked = 12413967
        RadioColorDisabled = 13092807
        FillColorNormal = clWhite
        FillColorDisabled = 15790320
        DotColor = clWhite
        FontColorNormal = 2368548
        FontColorChecked = 2368548
        FontColorDisabled = 12434877
        TabOrder = 3
      end
      object CWSSwitch1: TCWSSwitch
        Left = 504
        Top = 80
        Width = 77
        Height = 20
        Caption = 'Wi-Fi'
        Checked = True
        TrackColorChecked = 12413967
        TrackColorNormal = clWhite
        BorderColorNormal = 9079434
        TrackColorDisabled = 14737632
        KnobColorChecked = clWhite
        KnobColorNormal = 9079434
        KnobColorDisabled = 13092807
        FontColorNormal = 2368548
        FontColorChecked = 2368548
        FontColorDisabled = 12434877
        TabOrder = 4
      end
      object CWSSwitch2: TCWSSwitch
        Left = 504
        Top = 116
        Width = 103
        Height = 20
        Caption = 'Bluetooth'
        TrackColorChecked = 12413967
        TrackColorNormal = clWhite
        BorderColorNormal = 9079434
        TrackColorDisabled = 14737632
        KnobColorChecked = clWhite
        KnobColorNormal = 9079434
        KnobColorDisabled = 13092807
        FontColorNormal = 2368548
        FontColorChecked = 2368548
        FontColorDisabled = 12434877
        TabOrder = 5
      end
      object btnPopup: TCWSButton
        Left = 656
        Top = 80
        Width = 140
        Height = 40
        Color = clBtnFace
        TabOrder = 6
        IconFontName = 'Segoe MDL2 Assets'
        BckNormalColor = clWhite
        BckHoverColor = clWhitesmoke
        BckPressedColor = 14737632
        BorderColorNormal = 13750737
        BorderColorHover = 13092807
        BorderColorPressed = 11776947
        Caption = 'Show menu'
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
        OnClick = btnPopupClick
      end
    end
  end
  object SVGIconImageList1: TSVGIconImageList
    Size = 24
    SVGIconItems = <
      item
        IconName = 'delphi'
        SVGText = 
          '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em"' +
          ' viewBox="0 0 24 24"><path fill="currentColor" d="M23.922 10.66a' +
          '11.9 11.9 0 0 0-1.93-5.299a12 12 0 0 0-1.362-1.692A12 12 0 0 0 1' +
          '5.271.455a12 12 0 0 0-2.88-.444c-.237-.005-.474-.015-.71-.004c-.' +
          '345.016-.69.036-1.033.077q-.579.07-1.15.182a11.95 11.95 0 0 0-4.' +
          '906 2.297A12 12 0 0 0 .394 8.94a12 12 0 0 0-.393 2.883q-.013.765' +
          '.073 1.526a11.95 11.95 0 0 0 3.103 6.79a11.98 11.98 0 0 0 8.442 ' +
          '3.858c.013 0 .818-.002.868-.004q.777-.032 1.543-.162a11.95 11.95' +
          ' 0 0 0 6.173-3.072a11.98 11.98 0 0 0 3.667-7.028c.053-.406.087-.' +
          '815.113-1.224c.038-.617.006-1.234-.062-1.848zM4.5 11.777c-.052.3' +
          '-.094.601-.097.906c-.003.253-.005.506.004.76c.005.148.031.297.05' +
          '1.445c.033.252-.067.455-.297.56a.5.5 0 0 1-.227.035c-.217-.019-.' +
          '433-.05-.65-.077c-.073-.01-.147-.017-.22-.03c-.017-.003-.04-.025' +
          '-.042-.041c-.041-.249-.086-.497-.115-.747c-.024-.206-.03-.413-.0' +
          '43-.62c-.006-.118-.014-.236-.013-.355c.002-.197.005-.394.017-.59' +
          'q.021-.327.06-.653q.028-.267.083-.529c.062-.29.134-.579.207-.867' +
          'q.106-.412.273-.804c.08-.187.15-.377.235-.56q.135-.293.295-.573c' +
          '.12-.21.251-.414.382-.619q.125-.196.26-.384c.074-.102.155-.197.2' +
          '34-.295q.106-.134.217-.263a8 8 0 0 1 .25-.274q.184-.192.373-.378' +
          'q.13-.13.27-.248c.173-.145.346-.293.528-.427q.341-.252.697-.483c' +
          '.186-.12.375-.235.572-.336c.253-.129.513-.244.773-.359q.239-.105' +
          '.486-.19a11 11 0 0 1 1.312-.359c.279-.05.56-.086.841-.12c.194-.0' +
          '23.39-.042.586-.044c.312-.003.625-.004.936.019c.342.024.683.07 1' +
          '.023.118c.182.026.362.071.54.117c.288.075.578.146.86.24c.246.08.' +
          '487.182.724.288c.26.116.513.245.767.374c.107.054.21.118.311.183c' +
          '.195.124.392.246.58.38c.189.135.368.282.55.424q.022.017.05.045c-' +
          '.165.109-.325.211-.481.318q-.252.175-.5.353l-.315.219l-.387.28l-' +
          '.45.321q-.164.12-.327.243q-.195.143-.387.288c-.217.167-.443.138-' +
          '.643.003a6.5 6.5 0 0 0-1.757-.83a6 6 0 0 0-1.33-.246c-.19-.013-.' +
          '381-.018-.572-.025a4.4 4.4 0 0 0-.792.047a24 24 0 0 0-.62.105a5 ' +
          '5 0 0 0-.795.225a6 6 0 0 0-.527.218a7 7 0 0 0-.574.294c-.178.103' +
          '-.347.222-.516.339q-.163.109-.313.233q-.222.188-.435.385c-.26.23' +
          '5-.486.5-.697.778c-.132.174-.25.36-.368.545a6 6 0 0 0-.489.967a6' +
          '.3 6.3 0 0 0-.368 1.271m13.278 5.496q-.264-.181-.527-.366a.5.5 0' +
          ' 0 1-.154-.237l-.222-.55l-.21-.532q-.106-.255-.21-.512c-.071-.17' +
          '6-.137-.355-.213-.53c-.088-.204-.14-.427-.28-.606a5 5 0 0 0-.288' +
          '-.337a2.6 2.6 0 0 0-.498-.413c-.14-.09-.298-.12-.457-.148q-.673-' +
          '.123-1.345-.248l-1.368-.246c-.39-.07-.78-.137-1.166-.218c-.258-.' +
          '054-.494.162-.518.407c-.023.246.167.456.375.508c.56.141 1.118.29' +
          '3 1.677.442c.662.175 1.324.347 1.984.527c.22.06.416.173.597.313c' +
          '.22.17.4.375.53.62c.084.163.151.336.22.506q.108.266.202.534q.139' +
          '.402.27.806q.084.246.16.492l.22.712q.075.245.147.49l.184.638q.07' +
          '3.245.144.492q.107.363.204.729c.033.126-.065.268-.2.287q-.41.055' +
          '-.821.104q-.273.034-.546.063l-.66.07q-.42.044-.837.09c-.118.012-' +
          '.236.03-.355.028a1.03 1.03 0 0 1-.688-.261c-.144-.126-.223-.292-' +
          '.316-.451c-.078-.135-.152-.272-.235-.403a13 13 0 0 0-.398-.602c-' +
          '.134-.187-.28-.365-.423-.544a6 6 0 0 0-.229-.265a7 7 0 0 0-.757-' +
          '.737a9 9 0 0 0-.641-.488a5.6 5.6 0 0 0-1.755-.803c-.436-.112-.87' +
          '8-.195-1.333-.187a3.5 3.5 0 0 0-.678.07c-.16.034-.309.022-.441-.' +
          '089c-.073-.06-.104-.144-.146-.223c-.017-.032-.027-.068-.044-.109' +
          'c.072-.02.143-.042.216-.058a2 2 0 0 1 .227-.042c.195-.023.39-.05' +
          '3.584-.058c.281-.007.564-.01.844.012a8 8 0 0 1 1.592.321c.24.076' +
          '.473.175.704.274c.387.166.727.407 1.051.673c.214.175.419.36.603.' +
          '567c.225.252.449.506.66.77c.15.186.282.389.419.587c.228.332.43.6' +
          '81.62 1.037q.072.134.133.272c.064.153.199.2.341.183l.572-.07l.7-' +
          '.08q.405-.04.81-.084q.312-.036.624-.08c.117-.018.202-.132.208-.2' +
          '54c.006-.108-.045-.2-.077-.296c-.089-.272-.184-.542-.276-.813l-.' +
          '266-.787q-.137-.414-.277-.826q-.097-.282-.196-.563c-.054-.156-.1' +
          '04-.312-.16-.467q-.101-.278-.208-.555c-.037-.096-.074-.192-.12-.' +
          '284a1.2 1.2 0 0 0-.482-.514c-.2-.12-.424-.159-.641-.22q-.96-.269' +
          '-1.92-.533l-.825-.23c-.218-.06-.435-.129-.657-.177c-.259-.057-.4' +
          '33-.212-.57-.427a1.3 1.3 0 0 1-.202-.583a.87.87 0 0 1 .12-.546a.' +
          '92.92 0 0 1 .44-.382a.7.7 0 0 1 .411-.041c.322.06.645.112.968.16' +
          '8c.227.04.454.083.681.121l.803.13l.579.1q.336.054.671.11c.195.03' +
          '4.389.073.584.103c.126.019.249.042.362.102c.054.029.11.06.156.1q' +
          '.246.219.484.447q.212.204.413.42a.95.95 0 0 1 .217.392c.033.115.' +
          '077.227.117.34l.167.471l.212.595l.185.534l.176.497l.188.544l.093' +
          '.268l-.013.01zm.708.363a3 3 0 0 1-.37-.169c-.03-.016-.039-.076-.' +
          '054-.117q-.105-.296-.206-.592l-.23-.664l-.23-.653l-.279-.8l-.2-.' +
          '565q-.054-.152-.113-.304c-.063-.161-.179-.285-.296-.407c-.1-.104' +
          '-.199-.209-.304-.306a18 18 0 0 0-.605-.537c-.149-.125-.334-.167-' +
          '.522-.197l-.603-.098q-.37-.061-.739-.125l-.665-.113l-1.026-.172l' +
          '-.836-.145c-.197-.033-.393-.075-.591-.089c-.11-.007-.226.026-.33' +
          '5.056a.94.94 0 0 0-.395.235q-.178.17-.272.402c-.12.306-.101.606.' +
          '007.909c.071.197.173.376.317.528c.142.15.307.258.513.306c.248.05' +
          '8.493.129.74.196l1.322.362l.842.233l.841.235c.266.074.48.224.621' +
          '.46c.07.118.117.252.168.382q.092.235.175.474q.118.337.233.675l.1' +
          '94.567l.163.489l.167.477l.19.562l.278.816q.016.044.028.088c.01.0' +
          '42-.015.066-.052.07c-.167.02-.335.035-.503.054l-.253.032l-.532.0' +
          '58l-.566.068l-.726.082a.5.5 0 0 1-.122.005a.1.1 0 0 1-.057-.037c' +
          '-.068-.127-.129-.257-.198-.382a12 12 0 0 0-.733-1.196a11 11 0 0 ' +
          '0-.99-1.204a7 7 0 0 0-.595-.552a5.5 5.5 0 0 0-.628-.452a3.3 3.3 ' +
          '0 0 0-.704-.345c-.288-.093-.568-.21-.859-.29c-.288-.077-.586-.11' +
          '6-.879-.177c-.277-.057-.558-.056-.838-.072c-.125-.007-.251.003-.' +
          '377.01q-.215.011-.428.031a3 3 0 0 0-.247.04c-.16.03-.318.062-.49' +
          '1.096c-.051-.16-.107-.319-.154-.481a5.5 5.5 0 0 1-.2-1.027a5.2 5' +
          '.2 0 0 1-.021-1.028c.033-.479.113-.951.258-1.41c.095-.3.2-.599.3' +
          '44-.88c.096-.187.191-.374.298-.554c.08-.137.178-.265.271-.394q.1' +
          '08-.151.225-.297q.106-.126.223-.243q.19-.197.392-.383c.09-.084.1' +
          '9-.159.288-.234c.105-.08.21-.16.32-.232q.223-.143.45-.275c.135-.' +
          '078.27-.157.411-.22q.318-.138.643-.257a3 3 0 0 1 .383-.12c.247-.' +
          '054.495-.104.744-.14c.21-.03.423-.052.634-.052q.406 0 .81.042q.6' +
          '99.07 1.354.323a6 6 0 0 1 1.819 1.068c.207.175.409.356.583.564q.' +
          '295.346.57.708c.056.074.081.174.112.266q.108.32.208.643c.086.274' +
          '.167.55.252.824c.064.208.133.414.198.622l.211.696l.15.477l.165.5' +
          '34l.153.489l.117.39l.114.355l.291.928l.275.865l.035.105c.02.065-' +
          '.015.113-.076.09m.157-12.752a.48.48 0 0 1-.272.408a.06.06 0 0 1-' +
          '.054-.005c-.077-.06-.148-.127-.227-.184c-.237-.173-.471-.35-.716' +
          '-.512a9 9 0 0 0-.706-.428c-.246-.132-.502-.244-.756-.358a6 6 0 0' +
          ' 0-.501-.201q-.42-.144-.848-.267a8 8 0 0 0-1.091-.215c-.3-.042-.' +
          '6-.076-.903-.081c-.176-.003-.352-.015-.528-.009q-.42.014-.84.047' +
          'c-.209.017-.416.05-.623.08q-.434.06-.852.183q-.354.103-.705.217a' +
          '5 5 0 0 0-.422.16a10.6 10.6 0 0 0-1.438.718c-.18.107-.352.232-.5' +
          '25.354a8 8 0 0 0-.394.296a12 12 0 0 0-.962.865c-.114.115-.219.24' +
          '-.325.363c-.11.128-.223.254-.327.387a9 9 0 0 0-.653.956c-.098.16' +
          '4-.187.334-.276.503a9 9 0 0 0-.253.51c-.08.177-.147.358-.216.54a' +
          '8 8 0 0 0-.311.986c-.074.335-.149.67-.2 1.01a10 10 0 0 0-.047 2.' +
          '328c.028.268.073.534.11.805c-.215 0-.4-.063-.512-.256a.8.8 0 0 1' +
          '-.08-.242a8 8 0 0 1-.083-.53a13 13 0 0 1-.07-.702a9 9 0 0 1-.021' +
          '-.723a10.5 10.5 0 0 1 .282-2.28c.092-.394.216-.778.363-1.153c.07' +
          '8-.198.151-.398.242-.59q.195-.41.414-.81q.159-.289.346-.561c.145' +
          '-.214.3-.42.455-.627q.152-.203.317-.396q.16-.18.328-.353a9 9 0 0' +
          ' 1 .578-.56c.18-.155.359-.31.545-.456c.145-.114.299-.216.45-.32c' +
          '.13-.09.258-.18.392-.26a13 13 0 0 1 .975-.531q.22-.103.447-.196c' +
          '.116-.05.231-.101.35-.142q.372-.125.747-.24c.137-.043.275-.084.4' +
          '16-.112c.299-.062.598-.123.9-.17a7 7 0 0 1 .743-.078q.487-.022.9' +
          '76-.015c.216.003.433.022.648.045a9.7 9.7 0 0 1 2.377.532c.432.16' +
          '.86.332 1.264.56q.42.234.829.49c.206.13.405.276.6.424q.267.2.514' +
          '.423a.43.43 0 0 1 .13.373z"/></svg>'
      end
      item
        IconName = 'new-file'
        SVGText = 
          '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em"' +
          ' viewBox="0 0 24 24"><g fill="none" stroke="currentColor" stroke' +
          '-width="1.5"><path d="M16 2H3v20h18V7z"/><path d="M15 2v6h6"/></' +
          'g></svg>'
      end
      item
        IconName = 'emergency-exit-flat'
        SVGText = 
          '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em"' +
          ' viewBox="0 0 14 14"><g fill="none" fill-rule="evenodd" clip-rul' +
          'e="evenodd"><path fill="#2859c5" d="M6.133.066a1.42 1.42 0 0 0-1' +
          '.419 1.419v2.644a3 3 0 0 1 .812.217a2.881 2.881 0 1 1 4.713 2.96' +
          '6a2 2 0 0 1-.56 3.92H8.307q-.27 0-.531-.047q.01.123.01.247v1.818' +
          'c0 .24-.043.47-.12.684h4.902a1.42 1.42 0 0 0 1.419-1.419V1.485a1' +
          '.42 1.42 0 0 0-1.42-1.42z"/><path fill="#8fbffa" d="M6.645 5.207' +
          'a1.63 1.63 0 1 1 3.259 0a1.63 1.63 0 0 1-3.26 0m.082 1.62L8.22 8' +
          '.322a.13.13 0 0 0 .088.036h1.371a.875.875 0 0 1 0 1.75H8.308c-.4' +
          '97 0-.974-.197-1.326-.549l-.874-.874l-.71.71l.714.712c.351.352.5' +
          '49.829.549 1.326V13a.875.875 0 0 1-1.75 0v-1.568a.13.13 0 0 0-.0' +
          '37-.088l-.725-.725A1.88 1.88 0 0 1 3.015 11H1a.875.875 0 0 1 0-1' +
          '.75h2.015a.13.13 0 0 0 .089-.037L4.87 7.446l-.428-.427a.13.13 0 ' +
          '0 0-.088-.037H2.536a.875.875 0 1 1 0-1.75h1.819c.497 0 .974.198 ' +
          '1.325.55z"/></g></svg>'
      end>
    DisabledGrayScale = False
    Scaled = True
    Left = 776
    Top = 264
  end
  object CWSPopupMenu1: TCWSPopupMenu
    Images = SVGIconImageList1
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ItemHeight = 32
    Left = 776
    Top = 344
    object miNew: TMenuItem
      Caption = 'New'
      ImageIndex = 1
      ImageName = 'new-file'
    end
    object miOpen: TMenuItem
      Caption = 'Open...'
    end
    object miSave: TMenuItem
      Caption = 'Save'
    end
    object miSep1: TMenuItem
      Caption = '-'
    end
    object miExit: TMenuItem
      Caption = 'Exit'
      ImageIndex = 2
      ImageName = 'emergency-exit-flat'
    end
  end
end
