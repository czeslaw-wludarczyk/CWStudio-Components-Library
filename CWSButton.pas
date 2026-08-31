//////////////////////////////////////////////////////////////////////////
//
//   CWStudio Components Library
//   Created by Czesław Włudarczyk 2026 CWStudio
//
//   LICENSE: MIT
//   Free to use, modify and distribute in any project, commercial or
//   non-commercial, provided that the copyright notice and this license
//   text are preserved. See the LICENSE file for the full MIT terms.
//
//   ATTRIBUTION REQUIRED:
//   Any application built using CWStudio components MUST include
//   visible information about the author of the components inside
//   the application (e.g. in the About box, credits screen, or
//   splash screen), for example:
//
//       "Uses CWStudio components by Czesław Włudarczyk"
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
//////////////////////////////////////////////////////////////////////////
unit CWSButton;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Graphics,
  Vcl.ExtCtrls, Vcl.ImgList, CWSShape, Windows, Messages,
  Vcl.Menus, System.UITypes, CWSActions;

type
  TCWSIconMode = (icmGlyph, icmImageList);
  TCWSIconPosition = (ipLeft, ipRight, ipTop, ipBottom);
  TCWSButtonStyle = (bsNeutral, bsPrimary, bsCustom);

  TCWSButton = class(TCustomControl, ICWSActionClient)
  private
    FIconBox: TPaintBox;
    FLabelCaption: TLabel;
    FbckShape: TCWSShape;
    FMouseLayer: TLabel;

    FNormalColor: TColor;
    FbckHoverColor: TColor;
    FbckPressedColor: TColor;

    FBorderColorNormal: TColor;
    FBorderColorHover: TColor;
    FBorderColorPressed: TColor;
    FBorderWidth: Integer;

    FIconGlyphNormal: string;
    FIconGlyphPressed: string;
    FCaptionText: string;

    FHovering: Boolean;
    FPressed: Boolean;

    FIconColorNormal: TColor;
    FIconColorHover: TColor;
    FIconColorPressed: TColor;
    FIconFontName: string;
    FIconFontSize: Integer;

    FIconOffsetX: Integer;
    FIconOffsetY: Integer;

    FCaptionColorNormal: TColor;
    FCaptionColorHover: TColor;
    FCaptionColorPressed: TColor;

    FIconSpacing: Integer;
    FIconPosition: TCWSIconPosition;
    FCaptionAlignment: TAlignment;
    FCornerRadius: Integer;
    FIsDefault: Boolean;
    FIsCancel: Boolean;
    FActive: Boolean;

    FBckDisabledColor: TColor;
    FBorderColorDisabled: TColor;
    FCaptionColorDisabled: TColor;
    FIconColorDisabled: TColor;

    FOnClick: TNotifyEvent;
    FOnDblClick: TNotifyEvent;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;
    FOnMouseMove: TMouseMoveEvent;
    FOnMouseDown: TMouseEvent;
    FOnMouseUp: TMouseEvent;
    FOnKeyDown: TKeyEvent;
    FOnKeyUp: TKeyEvent;
    FOnKeyPress: TKeyPressEvent;
    FOnContextPopup: TContextPopupEvent;

    FIconMode: TCWSIconMode;
    FImages: TCustomImageList;
    FImageIndex: TImageIndex;
    FImageIndexPressed: TImageIndex;

    FButtonStyle: TCWSButtonStyle;

    procedure SetIconGlyph(const Value: string);
    procedure SetIconGlyphPressed(const Value: string);
    procedure SetIconFontName(const Value: string);
    procedure SetIconFontSize(const Value: Integer);
    procedure SetIconOffsetX(const Value: Integer);
    procedure SetIconOffsetY(const Value: Integer);
    procedure SetIconMode(const Value: TCWSIconMode);
    procedure SetImages(const Value: TCustomImageList);
    procedure SetImageIndex(const Value: TImageIndex);
    procedure SetImageIndexPressed(const Value: TImageIndex);
    procedure SetCaptionText(const Value: string);
    procedure SetBckColor(const Value: TColor);
    procedure SetBckPressedColor(const Value: TColor);
    procedure SetNormalColor(const Value: TColor);
    procedure SetBorderColorNormal(const Value: TColor);
    procedure SetBorderColorHover(const Value: TColor);
    procedure SetBorderColorPressed(const Value: TColor);
    procedure SetBorderWidth(const Value: Integer);
    procedure SetIconColorNormal(const Value: TColor);
    procedure SetIconColorHover(const Value: TColor);
    procedure SetIconColorPressed(const Value: TColor);
    procedure SetCaptionColorNormal(const Value: TColor);
    procedure SetCaptionColorHover(const Value: TColor);
    procedure SetCaptionColorPressed(const Value: TColor);
    procedure SetIconSpacing(const Value: Integer);
    procedure SetIconPosition(const Value: TCWSIconPosition);
    procedure SetCaptionAlignment(const Value: TAlignment);
    procedure SetCornerRadius(const Value: Integer);
    procedure SetIsDefault(const Value: Boolean);
    procedure SetIsCancel(const Value: Boolean);
    procedure SetBckDisabledColor(const Value: TColor);
    procedure SetBorderColorDisabled(const Value: TColor);
    procedure SetCaptionColorDisabled(const Value: TColor);
    procedure SetIconColorDisabled(const Value: TColor);
    procedure SetButtonStyle(const Value: TCWSButtonStyle);

    procedure ApplyStyleColors;
    procedure ApplyNeutralColors;
    procedure ApplyPrimaryColors;

    procedure ChildMouseEnter(Sender: TObject);
    procedure ChildMouseLeave(Sender: TObject);
    procedure ChildMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ChildMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ChildMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ChildDblClick(Sender: TObject);
    procedure ChildContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure MouseClick(Sender: TObject);
    procedure IconBoxPaint(Sender: TObject);
    procedure UpdateColor;
    procedure ApplyFontToLabel;
    function  CurrentIconColor: TColor;
    procedure CalcIconSize(out AWidth, AHeight: Integer);

    { ICWSActionClient — links Action.Caption/OnExecute/ImageIndex to the
      control's own Caption / OnClick / ImageIndex (VCL TButton has no Checked). }
    function  CWSActionCaption: string;
    procedure CWSSetActionCaption(const Value: string);
    function  CWSActionOnClick: TNotifyEvent;
    procedure CWSSetActionOnClick(Value: TNotifyEvent);
    function  CWSActionCheckedSupported: Boolean;
    function  CWSActionChecked: Boolean;
    procedure CWSSetActionChecked(Value: Boolean);
    function  CWSActionImageIndexSupported: Boolean;
    function  CWSActionImageIndex: Integer;
    procedure CWSSetActionImageIndex(Value: Integer);

  protected
    function  GetActionLinkClass: TControlActionLinkClass; override;
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
    procedure Resize; override;
    procedure Loaded; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
    procedure CMFocusChanged(var Message: TCMFocusChanged); message CM_FOCUSCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMParentFontChanged(var Message: TMessage); message CM_PARENTFONTCHANGED;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Click; reintroduce;
    procedure DblClick; override;

  published
    property Action;
    property Width;
    property Height;
    property Anchors;
    property Align;
    property Constraints;
    property Color;
    property ShowHint;
    property Hint;
    property Visible;
    property Enabled;
    property Font;
    property ParentFont;
    property TabOrder;
    property TabStop;

    property ButtonStyle: TCWSButtonStyle read FButtonStyle write SetButtonStyle default bsNeutral;

    property IconFontName: string read FIconFontName write SetIconFontName;
    property IconFontSize: Integer read FIconFontSize write SetIconFontSize default 11;

    property IconOffsetX: Integer read FIconOffsetX write SetIconOffsetX default 0;
    property IconOffsetY: Integer read FIconOffsetY write SetIconOffsetY default 0;

    property BckNormalColor: TColor read FNormalColor write SetNormalColor stored True;
    property BckHoverColor: TColor read FbckHoverColor write SetBckColor stored True;
    property BckPressedColor: TColor read FbckPressedColor write SetBckPressedColor stored True;

    property BorderColorNormal: TColor read FBorderColorNormal write SetBorderColorNormal stored True;
    property BorderColorHover: TColor read FBorderColorHover write SetBorderColorHover stored True;
    property BorderColorPressed: TColor read FBorderColorPressed write SetBorderColorPressed stored True;
    property BorderWidth: Integer read FBorderWidth write SetBorderWidth default 1;

    property IconGlyph: string read FIconGlyphNormal write SetIconGlyph stored True;
    property IconGlyphPressed: string read FIconGlyphPressed write SetIconGlyphPressed stored True;
    property Caption: string read FCaptionText write SetCaptionText stored True;

    property IconColorNormal: TColor read FIconColorNormal write SetIconColorNormal stored True;
    property IconColorHover: TColor read FIconColorHover write SetIconColorHover stored True;
    property IconColorPressed: TColor read FIconColorPressed write SetIconColorPressed stored True;

    property CaptionColorNormal: TColor read FCaptionColorNormal write SetCaptionColorNormal stored True;
    property CaptionColorHover: TColor read FCaptionColorHover write SetCaptionColorHover stored True;
    property CaptionColorPressed: TColor read FCaptionColorPressed write SetCaptionColorPressed stored True;

    property IconSpacing: Integer read FIconSpacing write SetIconSpacing default 6;
    property IconPosition: TCWSIconPosition read FIconPosition write SetIconPosition default ipLeft;

    { Horizontal alignment of the caption text. With taCenter, a multi-line
      caption (e.g. containing sLineBreak) has each line centered instead of
      left-justified — the whole text block is always centered in the button
      regardless of this setting; this only affects lines of unequal width. }
    property CaptionAlignment: TAlignment read FCaptionAlignment write SetCaptionAlignment default taLeftJustify;

    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 4;

    property IsDefault: Boolean read FIsDefault write SetIsDefault default False;
    property IsCancel: Boolean read FIsCancel write SetIsCancel default False;

    property BckDisabledColor: TColor read FBckDisabledColor write SetBckDisabledColor stored True;
    property BorderColorDisabled: TColor read FBorderColorDisabled write SetBorderColorDisabled stored True;
    property CaptionColorDisabled: TColor read FCaptionColorDisabled write SetCaptionColorDisabled stored True;
    property IconColorDisabled: TColor read FIconColorDisabled write SetIconColorDisabled stored True;

    property IconMode: TCWSIconMode read FIconMode write SetIconMode default icmGlyph;
    property Images: TCustomImageList read FImages write SetImages;
    { TImageIndex, not Integer — the Object Inspector then offers the CWStudio
      icon picker: a drop-down with the glyphs of Images instead of bare numbers. }
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex default -1;
    property ImageIndexPressed: TImageIndex read FImageIndexPressed write SetImageIndexPressed default -1;

    { Events compatible with VCL TButton }
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
    property OnKeyDown: TKeyEvent read FOnKeyDown write FOnKeyDown;
    property OnKeyUp: TKeyEvent read FOnKeyUp write FOnKeyUp;
    property OnKeyPress: TKeyPressEvent read FOnKeyPress write FOnKeyPress;
    property OnContextPopup: TContextPopupEvent read FOnContextPopup write FOnContextPopup;
  end;

implementation

uses
  Vcl.Forms, System.TypInfo;

type
  TControlFontAccess = class(TControl);

{ TCWSButton }

constructor TCWSButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  { Background follows the parent so the control's own erase colour matches its
    surroundings. This keeps the rounded corners (the area outside the shape)
    blended with the parent instead of a grey clBtnFace, and — crucially — means
    that when the control is resized (especially an interactive resize at design
    time), the briefly exposed background is the parent colour rather than a grey
    rectangle showing through around the inner shape. }
  ParentColor := True;
  DoubleBuffered := True;

  // Do NOT touch Self.Font — leave ParentFont = True (the TCustomControl default).
  // The default font (Segoe UI / 10) is set in Loaded, but ONLY when ParentFont = False.

  FIconGlyphNormal  := '';
  FIconGlyphPressed := '';
  FCaptionText      := 'Button';

  FPressed    := False;
  FHovering   := False;

  FIconOffsetX := 0;
  FIconOffsetY := 0;

  FButtonStyle := bsNeutral;

  FNormalColor          := $00FFFFFF;
  FbckHoverColor        := $00F5F5F5;
  FbckPressedColor      := $00E0E0E0;

  FIconColorNormal      := $00242424;
  FIconColorHover       := $00242424;
  FIconColorPressed     := $00242424;
  FCaptionColorNormal   := $00242424;
  FCaptionColorHover    := $00242424;
  FCaptionColorPressed  := $00242424;

  FBorderColorNormal  := $00D1D1D1;
  FBorderColorHover   := $00C7C7C7;
  FBorderColorPressed := $00B3B3B3;
  FBorderWidth        := 1;

  FIconSpacing      := 6;
  FIconPosition     := ipLeft;
  FCaptionAlignment := taLeftJustify;
  FCornerRadius     := 4;
  FIsDefault    := False;
  FIsCancel     := False;
  FActive       := False;

  FBckDisabledColor    := $00F0F0F0;
  FBorderColorDisabled := $00E0E0E0;
  FCaptionColorDisabled := $00BDBDBD;
  FIconColorDisabled    := $00BDBDBD;

  FIconMode          := icmGlyph;
  FImages            := nil;
  FImageIndex        := -1;
  FImageIndexPressed := -1;

  FIconFontName := 'Segoe MDL2 Assets';
  FIconFontSize := 11;

  Width  := MulDiv(150, CurrentPPI, 96);
  Height := MulDiv(35,  CurrentPPI, 96);

  // 1. Background
  FbckShape              := TCWSShape.Create(Self);
  FbckShape.Parent       := Self;
  FbckShape.Shape        := TShapeKind.RoundRectangle;
  FbckShape.CornerRadius := MulDiv(FCornerRadius, CurrentPPI, 96);
  FbckShape.Align        := alClient;

  // 2. Ikona
  FIconBox         := TPaintBox.Create(Self);
  FIconBox.Parent  := Self;
  FIconBox.OnPaint := IconBoxPaint;

  // 3. Caption text — we don't set the font, it gets set in Loaded/Resize
  FLabelCaption             := TLabel.Create(Self);
  FLabelCaption.Parent      := Self;
  FLabelCaption.Transparent := True;
  FLabelCaption.Caption     := FCaptionText;
  FLabelCaption.Alignment   := FCaptionAlignment;
  FLabelCaption.Layout      := tlCenter;
  FLabelCaption.AutoSize    := True;

  // 4. Warstwa myszy — rejestrujemy wszystkie eventy
  FMouseLayer              := TLabel.Create(Self);
  FMouseLayer.Parent       := Self;
  FMouseLayer.Align        := alClient;
  FMouseLayer.Caption      := '';
  FMouseLayer.Transparent  := True;
  FMouseLayer.OnMouseEnter := ChildMouseEnter;
  FMouseLayer.OnMouseLeave := ChildMouseLeave;
  FMouseLayer.OnMouseDown  := ChildMouseDown;
  FMouseLayer.OnMouseUp    := ChildMouseUp;
  FMouseLayer.OnMouseMove  := ChildMouseMove;
  FMouseLayer.OnDblClick   := ChildDblClick;
  FMouseLayer.OnClick      := MouseClick;
  FMouseLayer.OnContextPopup := ChildContextPopup;

  UpdateColor;
end;

destructor TCWSButton.Destroy;
begin
  inherited;
end;

procedure TCWSButton.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FImages) then
  begin
    FImages := nil;
    if Assigned(FIconBox) then FIconBox.Invalidate;
    Invalidate;
  end;
end;

{ --- Style: colors only, never font --- }

procedure TCWSButton.ApplyNeutralColors;
begin
  FNormalColor      := $00FFFFFF;
  FbckHoverColor    := $00F5F5F5;
  FbckPressedColor  := $00E0E0E0;

  FBorderColorNormal  := $00D1D1D1;
  FBorderColorHover   := $00C7C7C7;
  FBorderColorPressed := $00B3B3B3;
  FBorderWidth        := 1;

  FCaptionColorNormal  := $00242424;
  FCaptionColorHover   := $00242424;
  FCaptionColorPressed := $00242424;

  FIconColorNormal  := $00242424;
  FIconColorHover   := $00242424;
  FIconColorPressed := $00242424;
end;

procedure TCWSButton.ApplyPrimaryColors;
begin
  FNormalColor      := $00BD6C0F;
  FbckHoverColor    := $00A35E11;
  FbckPressedColor  := $005E3B0C;

  FBorderColorNormal  := $00BD6C0F;
  FBorderColorHover   := $00A35E11;
  FBorderColorPressed := $005E3B0C;
  FBorderWidth        := 1;

  FCaptionColorNormal  := $00FFFFFF;
  FCaptionColorHover   := $00FFFFFF;
  FCaptionColorPressed := $00FFFFFF;

  FIconColorNormal  := $00FFFFFF;
  FIconColorHover   := $00FFFFFF;
  FIconColorPressed := $00FFFFFF;
end;

procedure TCWSButton.ApplyStyleColors;
begin
  case FButtonStyle of
    bsNeutral: ApplyNeutralColors;
    bsPrimary: ApplyPrimaryColors;
    bsCustom:  ;
  end;
end;

procedure TCWSButton.SetButtonStyle(const Value: TCWSButtonStyle);
begin
  if FButtonStyle = Value then Exit;
  FButtonStyle := Value;
  if not (csLoading in ComponentState) then
  begin
    ApplyStyleColors;
    UpdateColor;
  end;
end;

{ --- Font --- }

procedure TCWSButton.ApplyFontToLabel;
var
  SrcFont: TFont;
begin
  if not Assigned(FLabelCaption) then Exit;

  // ParentFont = True → take the font directly from the parent (skip Self.Font)
  // ParentFont = False → take Self.Font
  if ParentFont and (Parent <> nil) then
    SrcFont := TControlFontAccess(Parent).Font
  else
    SrcFont := Self.Font;

  FLabelCaption.Font.Name    := SrcFont.Name;
  FLabelCaption.Font.Size    := SrcFont.Size;
  FLabelCaption.Font.Style   := SrcFont.Style;
  FLabelCaption.Font.Charset := SrcFont.Charset;
  FLabelCaption.Font.Quality := SrcFont.Quality;

  // Color by state — independent of the font source
  if not Enabled then
    FLabelCaption.Font.Color := FCaptionColorDisabled
  else if FPressed then
    FLabelCaption.Font.Color := FCaptionColorPressed
  else if FHovering then
    FLabelCaption.Font.Color := FCaptionColorHover
  else
    FLabelCaption.Font.Color := FCaptionColorNormal;
end;

function TCWSButton.CurrentIconColor: TColor;
begin
  if not Enabled then Result := FIconColorDisabled
  else if FPressed then Result := FIconColorPressed
  else if FHovering then Result := FIconColorHover
  else Result := FIconColorNormal;
end;

procedure TCWSButton.CalcIconSize(out AWidth, AHeight: Integer);
var
  glyph: string;
  Bmp: Vcl.Graphics.TBitmap;
begin
  AWidth  := 0;
  AHeight := 0;

  case FIconMode of
    icmGlyph:
    begin
      glyph := FIconGlyphNormal;
      if (glyph = '') and (FIconGlyphPressed <> '') then
        glyph := FIconGlyphPressed;
      if glyph = '' then Exit;

      Bmp := Vcl.Graphics.TBitmap.Create;
      try
        Bmp.Canvas.Font.Name := FIconFontName;
        Bmp.Canvas.Font.PixelsPerInch := CurrentPPI;
        Bmp.Canvas.Font.Size := FIconFontSize;
        AWidth  := Bmp.Canvas.TextWidth(glyph);
        AHeight := Bmp.Canvas.TextHeight(glyph);
      finally
        Bmp.Free;
      end;
    end;
    icmImageList:
    begin
      if Assigned(FImages) and (FImages.Width > 0) then
      begin
        AWidth  := FImages.Width;
        AHeight := FImages.Height;
      end;
    end;
  end;
end;

procedure TCWSButton.IconBoxPaint(Sender: TObject);
var
  idx: Integer;
  savedColor: TColor;
  R: TRect;
  glyph: string;
begin
  FIconBox.Canvas.Brush.Style := bsClear;

  case FIconMode of
    icmGlyph:
    begin
      if FPressed then glyph := FIconGlyphPressed
      else glyph := FIconGlyphNormal;

      if glyph = '' then Exit;

      FIconBox.Canvas.Font.Name          := FIconFontName;
      FIconBox.Canvas.Font.PixelsPerInch := CurrentPPI;
      FIconBox.Canvas.Font.Size          := FIconFontSize;
      FIconBox.Canvas.Font.Color         := CurrentIconColor;
      FIconBox.Canvas.Brush.Style        := bsClear;

      R := FIconBox.ClientRect;
      DrawText(FIconBox.Canvas.Handle,
               PChar(glyph),
               -1,
               R,
               DT_CENTER or DT_VCENTER or DT_SINGLELINE);
    end;

    icmImageList:
    begin
      if FImages = nil then Exit;

      if FPressed and (FImageIndexPressed >= 0) then
        idx := FImageIndexPressed
      else
        idx := FImageIndex;

      if (idx < 0) or (idx >= FImages.Count) then Exit;

      { Tint monochrome SVG icons to the current state colour without a
        compile-time dependency on SVGIconImageList: if the assigned image list
        publishes a FixedColor property (TSVGIconImageList does), drive it via
        RTTI. Any other image list just draws as-is. }
      if IsPublishedProp(FImages, 'FixedColor') then
      begin
        savedColor := GetOrdProp(FImages, 'FixedColor');
        SetOrdProp(FImages, 'FixedColor', CurrentIconColor);
        FImages.Draw(FIconBox.Canvas, 0, 0, idx);
        SetOrdProp(FImages, 'FixedColor', savedColor);
      end
      else
        FImages.Draw(FIconBox.Canvas, 0, 0, idx);
    end;
  end;
end;

procedure TCWSButton.Loaded;
begin
  inherited;

  if HandleAllocated then
  begin
    FbckShape.SendToBack;
    FMouseLayer.BringToFront;
  end;

  // Default font — ONLY when ParentFont = False and the font wasn't set from DFM
  if not ParentFont then
  begin
    // Check whether the font is the VCL default (not set from DFM)
    if (Self.Font.Name = 'Tahoma') and (Self.Font.Size = 8) then
    begin
      Self.Font.Name := 'Segoe UI';
      Self.Font.Size := 10;
    end;
  end;

  ApplyStyleColors;
  FActive := FIsDefault;

  if Assigned(FbckShape) then
    FbckShape.CornerRadius := MulDiv(FCornerRadius, CurrentPPI, 96);

  ApplyFontToLabel;
  UpdateColor;
  Resize;
end;

procedure TCWSButton.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  FHovering := False;
  FPressed  := False;
  UpdateColor;
end;

procedure TCWSButton.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited;
  if Assigned(FbckShape) then
    FbckShape.CornerRadius := MulDiv(FCornerRadius, CurrentPPI, 96);
  ApplyFontToLabel;
  UpdateColor;
  Resize;
  Invalidate;
end;

procedure TCWSButton.CMFontChanged(var Message: TMessage);
begin
  inherited;
  ApplyFontToLabel;
  Resize;
  Invalidate;
end;

procedure TCWSButton.CMParentFontChanged(var Message: TMessage);
begin
  inherited;
  ApplyFontToLabel;
  Resize;
  Invalidate;
end;

procedure TCWSButton.CMDialogKey(var Message: TCMDialogKey);
begin
  if (Message.CharCode = VK_RETURN) and Enabled and Visible and FActive then
  begin
    Click;
    Message.Result := 1;
    Exit;
  end;
  if (Message.CharCode = VK_ESCAPE) and Enabled and Visible and FIsCancel then
  begin
    Click;
    Message.Result := 1;
    Exit;
  end;
  inherited;
end;

procedure TCWSButton.CMFocusChanged(var Message: TCMFocusChanged);
var
  IsOtherDefault: Boolean;
begin
  inherited;
  if not FIsDefault then
  begin
    FActive := False;
    Exit;
  end;

  IsOtherDefault := False;
  if (Message.Sender <> nil) and (Message.Sender <> Self) then
  begin
    if (Message.Sender is TCWSButton) and TCWSButton(Message.Sender).IsDefault then
      IsOtherDefault := True;
    if (Message.Sender is TButton) and TButton(Message.Sender).Default then
      IsOtherDefault := True;
  end;

  if Message.Sender = Self then
    FActive := True
  else if IsOtherDefault then
    FActive := False
  else
    FActive := True;
end;

{ --- WM_GETDLGCODE: so TWinControl routes keys to us --- }

procedure TCWSButton.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  // The standard VCL button returns DLGC_BUTTON; we also want arrow keys
  // and Space (keyboard activation like TButton).
  Message.Result := Message.Result or DLGC_WANTARROWS or DLGC_WANTCHARS;
end;

{ --- Klawiatura --- }

procedure TCWSButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  // Space / Enter → visual press effect
  if (Key = VK_SPACE) or (Key = VK_RETURN) then
  begin
    if Enabled then
    begin
      FPressed := True;
      UpdateColor;
    end;
  end;

  if Assigned(FOnKeyDown) then
    FOnKeyDown(Self, Key, Shift);

  inherited;
end;

procedure TCWSButton.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_SPACE) or (Key = VK_RETURN) then
  begin
    if Enabled and FPressed then
    begin
      FPressed := False;
      UpdateColor;
      Click;
    end;
  end;

  if Assigned(FOnKeyUp) then
    FOnKeyUp(Self, Key, Shift);

  inherited;
end;

procedure TCWSButton.KeyPress(var Key: Char);
begin
  if Assigned(FOnKeyPress) then
    FOnKeyPress(Self, Key);

  inherited;
end;

{ --- Kontekst --- }

procedure TCWSButton.DoContextPopup(MousePos: TPoint; var Handled: Boolean);
begin
  if Assigned(FOnContextPopup) then
    FOnContextPopup(Self, MousePos, Handled);

  if not Handled then
    inherited;
end;

{ --- DblClick --- }

procedure TCWSButton.DblClick;
begin
  if Assigned(FOnDblClick) then
    FOnDblClick(Self);
  // Intentionally do NOT call inherited (TCustomControl.DblClick does nothing
  // meaningful) or OnClick — same as VCL TButton: DblClick is a separate event.
end;

{ --- Mouse-layer event handling --- }

procedure TCWSButton.Click;
begin
  { VCL-identical dispatch: user OnClick wins, otherwise the linked action runs. }
  CWSDispatchClick(Self, Self, Action, ActionLink);
end;

{ --- Action linking (see CWSActions) --- }

function TCWSButton.GetActionLinkClass: TControlActionLinkClass;
begin
  Result := TCWSControlActionLink;
end;

procedure TCWSButton.ActionChange(Sender: TObject; CheckDefaults: Boolean);
begin
  CWSActionChange(Self, Self, Sender, CheckDefaults);
end;

function TCWSButton.CWSActionCaption: string;
begin
  Result := FCaptionText;
end;

procedure TCWSButton.CWSSetActionCaption(const Value: string);
begin
  Caption := Value;
end;

function TCWSButton.CWSActionOnClick: TNotifyEvent;
begin
  Result := FOnClick;
end;

procedure TCWSButton.CWSSetActionOnClick(Value: TNotifyEvent);
begin
  FOnClick := Value;
end;

function TCWSButton.CWSActionCheckedSupported: Boolean;
begin
  Result := False;
end;

function TCWSButton.CWSActionChecked: Boolean;
begin
  Result := False;
end;

procedure TCWSButton.CWSSetActionChecked(Value: Boolean);
begin
  { A push button has no checked state. }
end;

function TCWSButton.CWSActionImageIndexSupported: Boolean;
begin
  Result := True;
end;

function TCWSButton.CWSActionImageIndex: Integer;
begin
  Result := FImageIndex;
end;

procedure TCWSButton.CWSSetActionImageIndex(Value: Integer);
begin
  { An action's image index only makes sense in image-list mode. }
  if FIconMode = icmImageList then
    ImageIndex := Value;
end;

procedure TCWSButton.ChildMouseEnter(Sender: TObject);
begin
  if not Enabled then Exit;
  FHovering := True;
  UpdateColor;
  if Assigned(FOnMouseEnter) then FOnMouseEnter(Self);
end;

procedure TCWSButton.ChildMouseLeave(Sender: TObject);
begin
  FHovering := False;
  FPressed  := False;
  UpdateColor;
  if Assigned(FOnMouseLeave) then FOnMouseLeave(Self);
end;

procedure TCWSButton.ChildMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if not Enabled then Exit;

  // Focus on click (like a standard button with TabStop)
  if CanFocus then SetFocus;

  if Button = mbLeft then
  begin
    FPressed := True;
    UpdateColor;
    FbckShape.Update;
    FIconBox.Update;
    Update;
  end;

  if Assigned(FOnMouseDown) then
    FOnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TCWSButton.ChildMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if not Enabled then Exit;
  if Button = mbLeft then
  begin
    FPressed := False;
    UpdateColor;
  end;

  if Assigned(FOnMouseUp) then
    FOnMouseUp(Self, Button, Shift, X, Y);
end;

procedure TCWSButton.ChildMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseMove) then
    FOnMouseMove(Self, Shift, X, Y);
end;

procedure TCWSButton.ChildDblClick(Sender: TObject);
begin
  // On double-click roll back the "Pressed" state — the first click
  // sets it via MouseDown, but the second click doesn't generate MouseDown
  // on every platform in the same order.
  FPressed := False;
  UpdateColor;
  DblClick;
end;

procedure TCWSButton.ChildContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  // Delegate to the virtual method (which fires FOnContextPopup).
  // Coordinates are in FMouseLayer space — convert to Self space.
  var PtSelf := FMouseLayer.ClientToParent(MousePos, Self);
  DoContextPopup(PtSelf, Handled);
end;

procedure TCWSButton.MouseClick(Sender: TObject);
begin
  if not Enabled then Exit;
  Click;
end;

procedure TCWSButton.UpdateColor;
begin
  if (FbckShape = nil) or (FIconBox = nil) or (FLabelCaption = nil) or
     (csDestroying in ComponentState) then
    Exit;
  if csLoading in ComponentState then
    Exit;

  if not Enabled then
  begin
    FbckShape.Brush.Color := FBckDisabledColor;

    FbckShape.Pen.Width := MulDiv(FBorderWidth, CurrentPPI, 96);
    if FBorderWidth > 0 then
    begin
      FbckShape.Pen.Style := TShapePenStyle.Solid;
      FbckShape.Pen.Color := FBorderColorDisabled;
    end
    else
      FbckShape.Pen.Style := TShapePenStyle.Clear;

    FLabelCaption.Font.Color := FCaptionColorDisabled;
  end
  else
  begin
    if FPressed then FbckShape.Brush.Color := FbckPressedColor
    else if FHovering then FbckShape.Brush.Color := FbckHoverColor
    else FbckShape.Brush.Color := FNormalColor;

    FbckShape.Pen.Width := FBorderWidth;
    if FBorderWidth > 0 then
    begin
      FbckShape.Pen.Style := TShapePenStyle.Solid;
      if FPressed then FbckShape.Pen.Color := FBorderColorPressed
      else if FHovering then FbckShape.Pen.Color := FBorderColorHover
      else FbckShape.Pen.Color := FBorderColorNormal;
    end
    else
      FbckShape.Pen.Style := TShapePenStyle.Clear;

    if FPressed then FLabelCaption.Font.Color := FCaptionColorPressed
    else if FHovering then FLabelCaption.Font.Color := FCaptionColorHover
    else FLabelCaption.Font.Color := FCaptionColorNormal;
  end;

  FIconBox.Invalidate;
  Invalidate;
end;

procedure TCWSButton.Resize;
var
  iW, iH: Integer;
  HasIcon: Boolean;
  TotalW, TotalH: Integer;
  Spacing: Integer;
  ContentLeft, ContentTop: Integer;
  OfsX, OfsY: Integer;
begin
  inherited;

  { Force the alClient background shape to re-fill and repaint on every resize so
    it never trails the control's new bounds and briefly exposes the background
    (visible as the container showing through during an interactive resize). }
  if Assigned(FbckShape) then
  begin
    FbckShape.BoundsRect := ClientRect;
    FbckShape.Invalidate;
  end;

  if not Assigned(FIconBox) or not Assigned(FLabelCaption) then
    Exit;

  // Refresh the label font on every Resize
  // (picks up ParentFont at runtime regardless of Loaded ordering)
  ApplyFontToLabel;
  FLabelCaption.Caption := FCaptionText;

  HasIcon := False;
  case FIconMode of
    icmGlyph:
      HasIcon := (FIconGlyphNormal <> '') or (FIconGlyphPressed <> '');
    icmImageList:
      HasIcon := Assigned(FImages) and ((FImageIndex >= 0) or (FImageIndexPressed >= 0));
  end;

  CalcIconSize(iW, iH);
  if (iW <= 0) or (iH <= 0) then
    HasIcon := False;

  Spacing := MulDiv(FIconSpacing, CurrentPPI, 96);
  OfsX := MulDiv(FIconOffsetX, CurrentPPI, 96);
  OfsY := MulDiv(FIconOffsetY, CurrentPPI, 96);

  if not HasIcon then
  begin
    FIconBox.Visible := False;
    FIconBox.Width   := 0;
    FIconBox.Height  := 0;
    FLabelCaption.Left := (ClientWidth - FLabelCaption.Width) div 2;
    FLabelCaption.Top  := (Height - FLabelCaption.Height) div 2;
    Exit;
  end;

  FIconBox.Visible := True;
  FIconBox.Width   := iW;
  FIconBox.Height  := iH;

  case FIconPosition of
    ipLeft:
    begin
      TotalW := iW + Spacing + FLabelCaption.Width;
      ContentLeft := (ClientWidth - TotalW) div 2;

      FIconBox.Left      := ContentLeft + OfsX;
      FIconBox.Top       := (Height - iH) div 2 + OfsY;
      FLabelCaption.Left := ContentLeft + iW + Spacing;
      FLabelCaption.Top  := (Height - FLabelCaption.Height) div 2;
    end;

    ipRight:
    begin
      TotalW := FLabelCaption.Width + Spacing + iW;
      ContentLeft := (ClientWidth - TotalW) div 2;

      FLabelCaption.Left := ContentLeft;
      FLabelCaption.Top  := (Height - FLabelCaption.Height) div 2;
      FIconBox.Left      := ContentLeft + FLabelCaption.Width + Spacing + OfsX;
      FIconBox.Top       := (Height - iH) div 2 + OfsY;
    end;

    ipTop:
    begin
      TotalH := iH + Spacing + FLabelCaption.Height;
      ContentTop := (Height - TotalH) div 2;

      FIconBox.Left      := (ClientWidth - iW) div 2 + OfsX;
      FIconBox.Top       := ContentTop + OfsY;
      FLabelCaption.Left := (ClientWidth - FLabelCaption.Width) div 2;
      FLabelCaption.Top  := ContentTop + iH + Spacing;
    end;

    ipBottom:
    begin
      TotalH := FLabelCaption.Height + Spacing + iH;
      ContentTop := (Height - TotalH) div 2;

      FLabelCaption.Left := (ClientWidth - FLabelCaption.Width) div 2;
      FLabelCaption.Top  := ContentTop;
      FIconBox.Left      := (ClientWidth - iW) div 2 + OfsX;
      FIconBox.Top       := ContentTop + FLabelCaption.Height + Spacing + OfsY;
    end;
  end;
end;

{ --- Color setters: switch to bsCustom --- }

procedure TCWSButton.SetBckColor(const Value: TColor);
begin
  if FbckHoverColor <> Value then
  begin
    FbckHoverColor := Value;
    if FButtonStyle <> bsCustom then FButtonStyle := bsCustom;
    UpdateColor;
  end;
end;

procedure TCWSButton.SetBckPressedColor(const Value: TColor);
begin
  if FbckPressedColor <> Value then
  begin
    FbckPressedColor := Value;
    if FButtonStyle <> bsCustom then FButtonStyle := bsCustom;
    UpdateColor;
  end;
end;

procedure TCWSButton.SetNormalColor(const Value: TColor);
begin
  if FNormalColor <> Value then
  begin
    FNormalColor := Value;
    if FButtonStyle <> bsCustom then FButtonStyle := bsCustom;
    UpdateColor;
  end;
end;

procedure TCWSButton.SetBorderColorNormal(const Value: TColor);
begin
  if FBorderColorNormal <> Value then
  begin
    FBorderColorNormal := Value;
    if FButtonStyle <> bsCustom then FButtonStyle := bsCustom;
    UpdateColor;
  end;
end;

procedure TCWSButton.SetBorderColorHover(const Value: TColor);
begin
  if FBorderColorHover <> Value then
  begin
    FBorderColorHover := Value;
    if FButtonStyle <> bsCustom then FButtonStyle := bsCustom;
    UpdateColor;
  end;
end;

procedure TCWSButton.SetBorderColorPressed(const Value: TColor);
begin
  if FBorderColorPressed <> Value then
  begin
    FBorderColorPressed := Value;
    if FButtonStyle <> bsCustom then FButtonStyle := bsCustom;
    UpdateColor;
  end;
end;

procedure TCWSButton.SetBorderWidth(const Value: Integer);
begin
  if FBorderWidth <> Value then begin FBorderWidth := Value; UpdateColor; end;
end;

procedure TCWSButton.SetCaptionColorNormal(const Value: TColor);
begin
  if FCaptionColorNormal <> Value then
  begin
    FCaptionColorNormal := Value;
    if FButtonStyle <> bsCustom then FButtonStyle := bsCustom;
    UpdateColor;
  end;
end;

procedure TCWSButton.SetCaptionColorHover(const Value: TColor);
begin
  if FCaptionColorHover <> Value then
  begin
    FCaptionColorHover := Value;
    if FButtonStyle <> bsCustom then FButtonStyle := bsCustom;
    UpdateColor;
  end;
end;

procedure TCWSButton.SetCaptionColorPressed(const Value: TColor);
begin
  if FCaptionColorPressed <> Value then
  begin
    FCaptionColorPressed := Value;
    if FButtonStyle <> bsCustom then FButtonStyle := bsCustom;
    UpdateColor;
  end;
end;

procedure TCWSButton.SetCaptionText(const Value: string);
begin
  FCaptionText := Value;
  if Assigned(FLabelCaption) then
  begin
    FLabelCaption.Caption := FCaptionText;
    Resize;
  end;
end;

procedure TCWSButton.SetIconColorHover(const Value: TColor);
begin
  if FIconColorHover <> Value then
  begin
    FIconColorHover := Value;
    if FButtonStyle <> bsCustom then FButtonStyle := bsCustom;
    UpdateColor;
  end;
end;

procedure TCWSButton.SetIconColorNormal(const Value: TColor);
begin
  if FIconColorNormal <> Value then
  begin
    FIconColorNormal := Value;
    if FButtonStyle <> bsCustom then FButtonStyle := bsCustom;
    UpdateColor;
  end;
end;

procedure TCWSButton.SetIconColorPressed(const Value: TColor);
begin
  if FIconColorPressed <> Value then
  begin
    FIconColorPressed := Value;
    if FButtonStyle <> bsCustom then FButtonStyle := bsCustom;
    UpdateColor;
  end;
end;

procedure TCWSButton.SetIconGlyph(const Value: string);
begin
  FIconGlyphNormal := Value;
  if Assigned(FIconBox) and not FPressed then FIconBox.Invalidate;
  Resize;
end;

procedure TCWSButton.SetIconGlyphPressed(const Value: string);
begin
  FIconGlyphPressed := Value;
  if Assigned(FIconBox) and FPressed then FIconBox.Invalidate;
end;

procedure TCWSButton.SetIconSpacing(const Value: Integer);
begin
  if FIconSpacing <> Value then begin FIconSpacing := Value; Resize; end;
end;

procedure TCWSButton.SetIconPosition(const Value: TCWSIconPosition);
begin
  if FIconPosition <> Value then begin FIconPosition := Value; Resize; end;
end;

procedure TCWSButton.SetCaptionAlignment(const Value: TAlignment);
begin
  if FCaptionAlignment = Value then Exit;
  FCaptionAlignment := Value;
  if Assigned(FLabelCaption) then
  begin
    FLabelCaption.Alignment := FCaptionAlignment;
    Resize;
  end;
end;

procedure TCWSButton.SetIsDefault(const Value: Boolean);
begin
  if FIsDefault = Value then Exit;
  FIsDefault := Value;
  FActive := FIsDefault;
  // IsDefault controls ONLY the Enter key behaviour
end;

procedure TCWSButton.SetIsCancel(const Value: Boolean);
begin
  FIsCancel := Value;
end;

procedure TCWSButton.SetBckDisabledColor(const Value: TColor);
begin
  if FBckDisabledColor <> Value then begin FBckDisabledColor := Value; UpdateColor; end;
end;

procedure TCWSButton.SetBorderColorDisabled(const Value: TColor);
begin
  if FBorderColorDisabled <> Value then begin FBorderColorDisabled := Value; UpdateColor; end;
end;

procedure TCWSButton.SetCaptionColorDisabled(const Value: TColor);
begin
  if FCaptionColorDisabled <> Value then begin FCaptionColorDisabled := Value; UpdateColor; end;
end;

procedure TCWSButton.SetIconColorDisabled(const Value: TColor);
begin
  if FIconColorDisabled <> Value then begin FIconColorDisabled := Value; UpdateColor; end;
end;

procedure TCWSButton.SetCornerRadius(const Value: Integer);
begin
  if FCornerRadius = Value then Exit;
  FCornerRadius := Value;
  if Assigned(FbckShape) then
    FbckShape.CornerRadius := MulDiv(FCornerRadius, CurrentPPI, 96);
  Invalidate;
end;

procedure TCWSButton.SetIconMode(const Value: TCWSIconMode);
begin
  if FIconMode = Value then Exit;
  FIconMode := Value;
  Resize;
  UpdateColor;
  Repaint;
end;

procedure TCWSButton.SetImages(const Value: TCustomImageList);
begin
  if FImages = Value then Exit;
  if FImages <> nil then FImages.RemoveFreeNotification(Self);
  FImages := Value;
  if FImages <> nil then FImages.FreeNotification(Self);
  Resize;
  if Assigned(FIconBox) then FIconBox.Invalidate;
  Repaint;
end;

procedure TCWSButton.SetImageIndex(const Value: TImageIndex);
begin
  if FImageIndex = Value then Exit;
  FImageIndex := Value;
  if (FIconMode = icmImageList) and Assigned(FIconBox) then
    FIconBox.Invalidate;
end;

procedure TCWSButton.SetImageIndexPressed(const Value: TImageIndex);
begin
  if FImageIndexPressed = Value then Exit;
  FImageIndexPressed := Value;
  if (FIconMode = icmImageList) and FPressed and Assigned(FIconBox) then
    FIconBox.Invalidate;
end;

procedure TCWSButton.SetIconOffsetX(const Value: Integer);
begin
  if FIconOffsetX <> Value then begin FIconOffsetX := Value; Resize; end;
end;

procedure TCWSButton.SetIconOffsetY(const Value: Integer);
begin
  if FIconOffsetY <> Value then begin FIconOffsetY := Value; Resize; end;
end;

procedure TCWSButton.SetIconFontName(const Value: string);
begin
  if FIconFontName = Value then Exit;
  if Value = '' then FIconFontName := 'Segoe Fluent Icons'
  else FIconFontName := Value;
  Resize;
end;

procedure TCWSButton.SetIconFontSize(const Value: Integer);
begin
  if FIconFontSize = Value then Exit;
  FIconFontSize := Value;
  Resize;
end;

end.
