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
unit CWSEditMask;

// Disable Range Check and Overflow Check
// to protect the app from cast errors inside VCL code with taCenter text.
{$R-}
{$Q-}

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  System.SysUtils, System.Classes, System.Types, System.Math,
  Vcl.Controls, Vcl.Graphics, Vcl.StdCtrls, Vcl.Mask, Vcl.Forms, Vcl.Menus,
  Vcl.ImgList, System.UITypes;

type
  // Button style for the masked edit. A self-contained type with its own "embs"
  // prefix so it never collides with TCWSEdit's ebs… style constants when both
  // units are used together — no shared unit, no extra uses to remember.
  TCWSEditMaskButtonStyle = (embsNone, embsClear, embsSearch, embsPassword, embsCustom);

  TCWSMaskBufferedEdit = class(TMaskEdit)
  private
    FSelectionColor: TColor;
    FSelectionTextColor: TColor;
    FUseCustomSelection: Boolean;
    FInnerLeftMargin: Integer;
    FEnforceOnExit: Boolean;          // block leaving while the mask is unmet
    FOnMaskInvalid: TNotifyEvent;     // wrapper hook fired on invalid exit
    FOnInputInvalid: TNotifyEvent;    // wrapper hook fired on invalid Enter
    procedure PaintCustomSelection;
    procedure ApplyInnerMargins;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure CMFontChanged(var Msg: TMessage); message CM_FONTCHANGED;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure WndProc(var Message: TMessage); override;
  public
    // Side-effect-free check whether the current input satisfies the mask.
    // Unlike the native ValidateEdit it neither beeps, raises, nor steals focus.
    function InputMatchesMask: Boolean;
  end;

  TCWSEditMask = class(TCustomControl)
  private
    FEdit: TCWSMaskBufferedEdit;
    FBuffer: TBitmap;
    FLabel: string;
    FText: string;
    FFocused: Boolean;
    FCornerRadius: Single;
    FBorderColor: TColor;
    FBackgroundColor: TColor;
    FBackgroundHoverColor: TColor;
    FBackgroundFocusColor: TColor;
    FDisabledColor: TColor;
    FDisabledBorderColor: TColor;
    FLabelColor: TColor;
    FAccentColor: TColor;
    FHovered: Boolean;
    FAutoSizeHeight: Boolean;
    FAutoSelect: Boolean;
    FReadOnly: Boolean;
    FPasswordChar: Char;
    FMaxLength: Integer;
    FTextHint: string;
    FNumbersOnly: Boolean;
    FCharCase: TEditCharCase;
    FHideSelection: Boolean;
    FSelectionColor: TColor;
    FSelectionTextColor: TColor;
    FAlignment: TAlignment;
    FEditMask: string;
    FValidateOnExit: Boolean;
    FButtonStyle: TCWSEditMaskButtonStyle;
    FButtonIconColor: TColor;
    FButtonHoverColor: TColor;
    FButtonPressedColor: TColor;
    FButtonHovered: Boolean;
    FButtonPressed: Boolean;
    FButtonIcon: TPicture;
    FButtonIconSize: Integer;
    FImages: TCustomImageList;
    FImageIndex: TImageIndex;
    FOnSearchClick: TNotifyEvent;
    FOnButtonClick: TNotifyEvent;
    FOnChange: TNotifyEvent;
    FOnKeyPress: TKeyPressEvent;
    FOnKeyDown: TKeyEvent;
    FOnKeyUp: TKeyEvent;
    FOnClick: TNotifyEvent;
    FOnDblClick: TNotifyEvent;
    FOnEnter: TNotifyEvent;
    FOnExit: TNotifyEvent;
    FOnMouseDown: TMouseEvent;
    FOnMouseUp: TMouseEvent;
    FOnMouseMove: TMouseMoveEvent;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;
    FOnContextPopup: TContextPopupEvent;
    FOnValidationError: TNotifyEvent;
    FOnInputInvalid: TNotifyEvent;

    procedure SetLabel(const Value: string);
    procedure SetText(const Value: string);
    procedure SetCornerRadius(const Value: Single);
    procedure SetAccentColor(const Value: TColor);
    procedure SetBackgroundColor(const Value: TColor);
    procedure SetDisabledColor(const Value: TColor);
    procedure SetDisabledBorderColor(const Value: TColor);
    procedure SetReadOnly(const Value: Boolean);
    procedure SetPasswordChar(const Value: Char);
    procedure SetMaxLength(const Value: Integer);
    procedure SetAutoSelect(const Value: Boolean);
    procedure SetAutoSizeHeight(const Value: Boolean);
    procedure SetTextHint(const Value: string);
    procedure SetNumbersOnly(const Value: Boolean);
    procedure SetCharCase(const Value: TEditCharCase);
    procedure SetHideSelection(const Value: Boolean);
    procedure SetSelectionColor(const Value: TColor);
    procedure SetSelectionTextColor(const Value: TColor);
    procedure SetAlignment(const Value: TAlignment);
    function GetEditMask: string;
    procedure SetEditMask(const Value: string);
    function GetEditText: string;
    procedure SetEditText(const Value: string);
    procedure SetValidateOnExit(const Value: Boolean);
    procedure DoMaskInvalid(Sender: TObject);
    procedure DoInputInvalid(Sender: TObject);
    procedure SetButtonStyle(const Value: TCWSEditMaskButtonStyle);
    procedure SetButtonIconColor(const Value: TColor);
    procedure SetButtonHoverColor(const Value: TColor);
    procedure SetButtonPressedColor(const Value: TColor);
    procedure SetButtonIcon(const Value: TPicture);
    procedure SetButtonIconSize(const Value: Integer);
    procedure SetImages(const Value: TCustomImageList);
    procedure SetImageIndex(const Value: TImageIndex);
    procedure ButtonIconChanged(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditClick(Sender: TObject);
    procedure EditDblClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure EditMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure EditMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure EditMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure EditContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure CMFontChanged(var Msg: TMessage); message CM_FONTCHANGED;
    procedure CMParentFontChanged(var Msg: TMessage); message CM_PARENTFONTCHANGED;
    procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;
    procedure WMContextMenu(var Msg: TWMContextMenu); message WM_CONTEXTMENU;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMLButtonDown(var Msg: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMCancelMode(var Msg: TMessage); message WM_CANCELMODE;
    procedure SyncEditFont;
    procedure ApplyDefaultFont;
    procedure UpdateEditPosition;
    function GetCurrentBgColor: TColor;
    function GetCurrentBorderColor: TColor;
    procedure ApplyStateChange;
    procedure SetBackgroundFocusColor(const Value: TColor);
    procedure SetBackgroundHoverColor(const Value: TColor);
    procedure SetBorderColor(const Value: TColor);
    procedure EnsureBuffer;
    function GetText: string;
    function GetParentBgColor: TColor;
    procedure DrawParentBackground(DC: HDC; ARadius: Single);
    procedure AdjustHeight;
    function GetSelStart: Integer;
    procedure SetSelStart(const Value: Integer);
    function GetSelLength: Integer;
    procedure SetSelLength(const Value: Integer);
    function GetSelText: string;
    procedure SetSelText(const Value: string);
    function GetButtonRect: TRect;
    procedure HandleButtonClick;
    procedure SetPasswordReveal(Reveal: Boolean);
    { Give the inner edit the focus WITHOUT any select-all: TCustomMaskEdit's
      CMEnter calls SelectAll and our EditEnter posts EM_SETSEL(0, -1). Both would
      select the whole password when the reveal button hands the focus back,
      instead of keeping the caret where the user left it. Tab-in keeps the normal
      AutoSelect behaviour — the flags are only muted for our own SetFocus. }
    procedure FocusEditKeepCaret;
    function Scale(Value: Integer): Integer;
    function ScaleF(Value: Single): Single;
    function MakeGPColor(AColor: TColor; Alpha: Byte = 255): Cardinal;
    function CreateRoundRectPath(X, Y, W, H, R: Single): TGPGraphicsPath;
    procedure PaintToBuffer;
    procedure DrawIcon(G: TGPGraphics; Rect: TGPRectF; Style: TCWSEditMaskButtonStyle);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;
    procedure Resize; override;
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetEnabled(Value: Boolean); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure ChangeScale(M, D: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetFocus; override;
    function Focused: Boolean; override;
    procedure Clear;
    procedure ClearSelection;
    procedure CopyToClipboard;
    procedure CutToClipboard;
    procedure PasteFromClipboard;
    procedure SelectAll;
    procedure Undo;
    { Mask validation }
    function IsValid: Boolean;
    procedure ValidateEdit;
    property EditText: string read GetEditText write SetEditText;
    property SelStart: Integer read GetSelStart write SetSelStart;
    property SelLength: Integer read GetSelLength write SetSelLength;
    property SelText: string read GetSelText write SetSelText;
  published
    property EditMask: string read GetEditMask write SetEditMask;
    property ValidateOnExit: Boolean read FValidateOnExit write SetValidateOnExit default False;
    property ButtonStyle: TCWSEditMaskButtonStyle read FButtonStyle write SetButtonStyle default embsNone;
    property ButtonIconColor: TColor read FButtonIconColor write SetButtonIconColor default $606060;
    property ButtonHoverColor: TColor read FButtonHoverColor write SetButtonHoverColor default $E5E5E5;
    property ButtonPressedColor: TColor read FButtonPressedColor write SetButtonPressedColor default $D9D9D9;
    property ButtonIcon: TPicture read FButtonIcon write SetButtonIcon;
    property ButtonIconSize: Integer read FButtonIconSize write SetButtonIconSize default 0;
    property Images: TCustomImageList read FImages write SetImages;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex default -1;
    property OnSearchClick: TNotifyEvent read FOnSearchClick write FOnSearchClick;
    property OnButtonClick: TNotifyEvent read FOnButtonClick write FOnButtonClick;
    property Text: string read GetText write SetText;
    property LabelText: string read FLabel write SetLabel;
    property CornerRadius: Single read FCornerRadius write SetCornerRadius;
    property AccentColor: TColor read FAccentColor write SetAccentColor default $D47800;
    property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor default clWhite;
    property BackgroundHoverColor: TColor read FBackgroundHoverColor write SetBackgroundHoverColor default $F9F9F9;
    property BackgroundFocusColor: TColor read FBackgroundFocusColor write SetBackgroundFocusColor default clWhite;
    property DisabledColor: TColor read FDisabledColor write SetDisabledColor default $F7F7F7;
    property DisabledBorderColor: TColor read FDisabledBorderColor write SetDisabledBorderColor default $E0E0E0;
    property BorderColor: TColor read FBorderColor write SetBorderColor default $D6D6D6;
    property LabelColor: TColor read FLabelColor write FLabelColor default $606060;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property PasswordChar: Char read FPasswordChar write SetPasswordChar default #0;
    property MaxLength: Integer read FMaxLength write SetMaxLength default 0;
    property AutoSizeHeight: Boolean read FAutoSizeHeight write SetAutoSizeHeight default True;
    property AutoSelect: Boolean read FAutoSelect write SetAutoSelect default True;
    property TextHint: string read FTextHint write SetTextHint;
    property NumbersOnly: Boolean read FNumbersOnly write SetNumbersOnly default False;
    property CharCase: TEditCharCase read FCharCase write SetCharCase default ecNormal;
    property HideSelection: Boolean read FHideSelection write SetHideSelection default True;
    property SelectionColor: TColor read FSelectionColor write SetSelectionColor default clNone;
    property SelectionTextColor: TColor read FSelectionTextColor write SetSelectionTextColor default clNone;
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnKeyPress: TKeyPressEvent read FOnKeyPress write FOnKeyPress;
    property OnKeyDown: TKeyEvent read FOnKeyDown write FOnKeyDown;
    property OnKeyUp: TKeyEvent read FOnKeyUp write FOnKeyUp;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnEnter: TNotifyEvent read FOnEnter write FOnEnter;
    property OnExit: TNotifyEvent read FOnExit write FOnExit;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnContextPopup: TContextPopupEvent read FOnContextPopup write FOnContextPopup;
    property OnValidationError: TNotifyEvent read FOnValidationError write FOnValidationError;
    property OnInputInvalid: TNotifyEvent read FOnInputInvalid write FOnInputInvalid;
    property Align;
    property Anchors;
    property Constraints;
    property Cursor;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
  end;

implementation

type
  TControlAccess = class(TControl);

  { TCWSMaskBufferedEdit }

procedure TCWSMaskBufferedEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_COMPOSITED;
end;

procedure TCWSMaskBufferedEdit.ApplyInnerMargins;
begin
  // Reapply the inner edit margins. On font change, size change,
  // or handle recreate VCL may reset EM_SETMARGINS — therefore
  // we call this from WM_SIZE, CM_FONTCHANGED and CreateWnd.
  if HandleAllocated then
    SendMessage(Handle, EM_SETMARGINS,
      EC_LEFTMARGIN or EC_RIGHTMARGIN,
      MakeLong(Word(FInnerLeftMargin), 0));
end;

procedure TCWSMaskBufferedEdit.CreateWnd;
begin
  inherited;
  ApplyInnerMargins;
end;

procedure TCWSMaskBufferedEdit.WMSize(var Msg: TWMSize);
begin
  inherited;
  ApplyInnerMargins;
end;

procedure TCWSMaskBufferedEdit.CMFontChanged(var Msg: TMessage);
begin
  inherited;
  ApplyInnerMargins;
end;

procedure TCWSMaskBufferedEdit.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

procedure TCWSMaskBufferedEdit.CMExit(var Message: TCMExit);
begin
  // Replaces TCustomMaskEdit.CMExit (which beeps, refocuses and raises the
  // "Invalid input value" message box). On modified-but-incomplete input we
  // notify the wrapper (-> OnValidationError); if FEnforceOnExit is set we keep
  // focus in the field, otherwise we let the user leave. No message box ever.
  if Modified and not InputMatchesMask then
  begin
    if Assigned(FOnMaskInvalid) then
      FOnMaskInvalid(Self);
    if FEnforceOnExit and not (csDesigning in ComponentState) and
       not (csDestroying in ComponentState) and CanFocus then
    begin
      SetFocus;
      Exit;   // stay in the field — do not fire OnExit
    end;
  end;
  DoExit;     // plain TWinControl exit behaviour (fires OnExit)
end;

function TCWSMaskBufferedEdit.InputMatchesMask: Boolean;
var
  Str: string;
  Pos: Integer;
begin
  if not IsMasked then
    Exit(True);
  Str := EditText;
  Pos := 0;
  // Validate() is a pure check (no focus change, no exception).
  Result := Validate(Str, Pos);
end;

procedure TCWSMaskBufferedEdit.WndProc(var Message: TMessage);
var
  StartPos, EndPos: DWORD;
begin
  // Pressing Enter on incomplete/invalid masked input makes the native
  // TCustomMaskEdit raise the "Invalid input value" message box. Intercept the
  // keystroke here, before it reaches the inherited handler: notify the wrapper
  // (-> OnInputInvalid) and swallow it, so no system message ever shows. Valid
  // input is passed through untouched (default button / Tab still work).
  if ((Message.Msg = WM_KEYDOWN) or (Message.Msg = WM_CHAR)) and
     (Message.WParam = VK_RETURN) and IsMasked and not InputMatchesMask then
  begin
    if Assigned(FOnInputInvalid) then
      FOnInputInvalid(Self);
    Message.Result := 0;
    Exit;
  end;

  inherited WndProc(Message);

  if (Message.Msg = WM_PAINT) and FUseCustomSelection and Focused then
  begin
    // Get selection start and end safely (DWORD)
    SendMessage(Handle, EM_GETSEL, UIntPtr(@StartPos), UIntPtr(@EndPos));
    if EndPos > StartPos then // Odpowiednik (SelLength > 0)
      PaintCustomSelection;
  end;
end;

procedure TCWSMaskBufferedEdit.PaintCustomSelection;
var
  DC: HDC;
  StartPos, EndPos: DWORD;
  SelS, SelL: Integer;
  Pos: LRESULT;
  X1, X2, Y: Integer;
  SelRect: TRect;
  BgBrush: HBRUSH;
  OldFont, HFontToUse: HFONT;
  TextSize, SelSize: TSize;
  SelStr: string;
  ActualPwdChar: Char;
  ResX: LongInt;
  TextLen: Integer;
  Buffer: array of Char;
begin
  // 1. Safe selection-range fetch via WinAPI
  SendMessage(Handle, EM_GETSEL, UIntPtr(@StartPos), UIntPtr(@EndPos));
  SelS := StartPos;
  SelL := EndPos - StartPos;

  if SelL <= 0 then
    Exit;

  // Hide the system caret during our own drawing. Otherwise FillRect
  // could cover the caret that was just visible (Windows doesn't know
  // we are painting outside its WM_PAINT cycle) — with taCenter the caret lands
  // in the middle of the selection, so the problem is most visible. After
  // painting is done ShowCaret restores the correct blinking.
  HideCaret(Handle);

  DC := GetDC(Handle);
  try
    HFontToUse := SendMessage(Handle, WM_GETFONT, 0, 0);
    if HFontToUse = 0 then
      HFontToUse := Font.Handle;
    OldFont := SelectObject(DC, HFontToUse);

    ActualPwdChar := Char(SendMessage(Handle, EM_GETPASSWORDCHAR, 0, 0));

    // 2. Safe X1 position fetch
    Pos := SendMessage(Handle, EM_POSFROMCHAR, SelS, 0);
    if NativeInt(Pos) = -1 then // Removed: or (Pos = $FFFFFFFF)
      Exit;

    ResX := Pos and $FFFF;
    if ResX >= $8000 then
      X1 := ResX - $10000
    else
      X1 := ResX;

    // 3. SAFE TEXT FETCH VIA WINAPI (instead of S := Text)
    TextLen := SendMessage(Handle, WM_GETTEXTLENGTH, 0, 0);
    if TextLen > 0 then
    begin
      SetLength(Buffer, TextLen + 1);
      SendMessage(Handle, WM_GETTEXT, TextLen + 1, LPARAM(@Buffer[0]));
    end;

    // 4. Build the selected text string
    if ActualPwdChar <> #0 then
      SelStr := StringOfChar(ActualPwdChar, SelL)
    else
    begin
      if (TextLen > 0) and (SelS < TextLen) then
      begin
        if SelS + SelL > TextLen then
          SelL := TextLen - SelS;
        SetString(SelStr, PChar(@Buffer[SelS]), SelL);
      end
      else
        SelStr := '';
    end;

    // 5. X2 position - precisely computed by measuring the width
    //    of the selected fragment (TextOut/Windows uses the same metric).
    //    The previous use of EM_POSFROMCHAR for the char AFTER the selection
    //    gave a result slightly narrower than the selection drawn natively by
    //    Windows — as a result a thin blue strip remained visible on the right
    //    strip of the original system selection.
    if Length(SelStr) > 0 then
    begin
      GetTextExtentPoint32(DC, PChar(SelStr), Length(SelStr), SelSize);
      X2 := X1 + SelSize.cx;
    end
    else
      X2 := X1;

    // 6. Draw the background and the text
    //    SelRect expanded vertically to the full client height — Windows
    //    natively paints the selection over the full edit height, so
    //    we cover it fully (eliminates "sticking out" pixels at top/bottom).
    //    +1 px margin on the right cancels any subpixel differences
    //    (ClearType / italic / kerning ostatniego znaku).
    GetTextExtentPoint32(DC, PChar('Ag'), 2, TextSize);
    Y := (ClientHeight - TextSize.cy) div 2;
    SelRect := Rect(X1, 0, X2 + 1, ClientHeight);

    if FSelectionColor <> clNone then
      BgBrush := CreateSolidBrush(ColorToRGB(FSelectionColor))
    else
      BgBrush := CreateSolidBrush(ColorToRGB(clHighlight));

    Winapi.Windows.FillRect(DC, SelRect, BgBrush);
    DeleteObject(BgBrush);

    SetBkMode(DC, TRANSPARENT);

    if FSelectionTextColor <> clNone then
      Winapi.Windows.SetTextColor(DC, ColorToRGB(FSelectionTextColor))
    else
      Winapi.Windows.SetTextColor(DC, ColorToRGB(clHighlightText));

    if Length(SelStr) > 0 then
      Winapi.Windows.TextOut(DC, X1, Y, PChar(SelStr), Length(SelStr));

    SelectObject(DC, OldFont);
  finally
    ReleaseDC(Handle, DC);
    ShowCaret(Handle);
  end;
end;

{ TCWSEditMask }

constructor TCWSEditMask.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 120;
  Height := 35;
  TabStop := True;
  Cursor := crIBeam;
  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf32bit;
  FCornerRadius := 4;
  FAccentColor := $D47800;
  FBackgroundColor := clWhite;
  FBackgroundHoverColor := $F9F9F9;
  FBackgroundFocusColor := clWhite;
  FDisabledColor := $F7F7F7;
  FDisabledBorderColor := $E0E0E0;
  FBorderColor := $D6D6D6;
  FLabelColor := $606060;
  FButtonStyle := embsNone;
  FButtonIconColor := $606060;
  FButtonHoverColor := $E5E5E5;
  FButtonPressedColor := $D9D9D9;
  FButtonIconSize := 0; // 0 = auto (default behavior before this property was added)
  FAutoSizeHeight := True;
  FAutoSelect := True;
  FHideSelection := True;
  FSelectionColor := clNone;
  FSelectionTextColor := clNone;
  FAlignment := taLeftJustify;
  FCharCase := ecNormal;
  FValidateOnExit := False;
  FImageIndex := -1;
  FButtonIcon := TPicture.Create;
  FButtonIcon.OnChange := ButtonIconChanged;
  FEdit := TCWSMaskBufferedEdit.Create(Self);
  FEdit.Parent := Self;
  FEdit.BorderStyle := bsNone;
  FEdit.ParentFont := False;
  FEdit.Font.Assign(Font);
  FEdit.Color := FBackgroundColor;
  FEdit.Alignment := FAlignment;
  FEdit.OnEnter := EditEnter;
  FEdit.OnExit := EditExit;
  FEdit.OnChange := EditChange;
  FEdit.OnKeyPress := EditKeyPress;
  FEdit.OnKeyDown := EditKeyDown;
  FEdit.OnKeyUp := EditKeyUp;
  FEdit.OnClick := EditClick;
  FEdit.OnDblClick := EditDblClick;
  FEdit.OnMouseDown := EditMouseDown;
  FEdit.OnMouseUp := EditMouseUp;
  FEdit.OnMouseMove := EditMouseMove;
  FEdit.OnContextPopup := EditContextPopup;
  FEdit.FEnforceOnExit := FValidateOnExit;
  FEdit.FOnMaskInvalid := DoMaskInvalid;
  FEdit.FOnInputInvalid := DoInputInvalid;
end;

destructor TCWSEditMask.Destroy;
begin
  FButtonIcon.Free;
  FBuffer.Free;
  inherited;
end;

function TCWSEditMask.GetButtonRect: TRect;
var
  BtnSize, Pad: Integer;
begin
  if FButtonStyle = embsNone then
    Exit(Rect(0, 0, 0, 0));
  Pad := Scale(2);
  BtnSize := Height - (Pad * 2);
  Result := Rect(Width - BtnSize - Pad, Pad, Width - Pad, Height - Pad);
end;

procedure TCWSEditMask.FocusEditKeepCaret;
var
  OldSelStart, OldSelLength: Integer;
  OldAutoSelect, OldEditAutoSelect: Boolean;
begin
  if (FEdit = nil) or not FEdit.CanFocus then
    Exit;
  OldSelStart := FEdit.SelStart;
  OldSelLength := FEdit.SelLength;
  { Self.FAutoSelect drives our EditEnter, which POSTS EM_SETSEL(0, -1) — being
    posted it would arrive after the caret restore below and win. }
  OldAutoSelect := FAutoSelect;
  OldEditAutoSelect := FEdit.AutoSelect;
  FAutoSelect := False;
  FEdit.AutoSelect := False;
  try
    FEdit.SetFocus;
  finally
    FEdit.AutoSelect := OldEditAutoSelect;
    FAutoSelect := OldAutoSelect;
  end;
  FEdit.SelStart := OldSelStart;
  FEdit.SelLength := OldSelLength;
end;

procedure TCWSEditMask.SetPasswordReveal(Reveal: Boolean);
var
  NewChar: Char;
  OldSelStart, OldSelLength: Integer;
  OldAutoSelect, OldEditAutoSelect: Boolean;
begin
  { Reveal/mask the text for the embsPassword button. Nothing to do when no
    PasswordChar is configured — the text is plain anyway. }
  if (FEdit = nil) or (FButtonStyle <> embsPassword) or (FPasswordChar = #0) then
    Exit;
  if Reveal then
    NewChar := #0
  else
    NewChar := FPasswordChar;
  if FEdit.PasswordChar = NewChar then
    Exit;

  // Setting PasswordChar does a RecreateWnd, which drops the edit's font and
  // its caret/selection — restore both, exactly like SetPasswordChar does.
  OldSelStart := FEdit.SelStart;
  OldSelLength := FEdit.SelLength;
  { RecreateWnd re-focuses the edit when it was focused (TWinControl.CMRecreateWnd),
    which runs the whole enter-focus path: CMEnter -> SelectAll and our EditEnter ->
    PostMessage(EM_SETSEL, 0, -1). The posted one lands after the restore below, so
    revealing the password left it fully selected instead of keeping the caret. }
  OldAutoSelect := FAutoSelect;
  OldEditAutoSelect := FEdit.AutoSelect;
  FAutoSelect := False;
  FEdit.AutoSelect := False;
  try
    FEdit.PasswordChar := NewChar;
    FEdit.Font.Assign(Font);
    FEdit.SelStart := OldSelStart;
    FEdit.SelLength := OldSelLength;
  finally
    FEdit.AutoSelect := OldEditAutoSelect;
    FAutoSelect := OldAutoSelect;
  end;
  UpdateEditPosition;
  Invalidate; // the eye icon draws the slash based on PasswordChar
end;

procedure TCWSEditMask.HandleButtonClick;
begin
  case FButtonStyle of
    embsClear:
      begin
        FEdit.Text := '';
        FocusEditKeepCaret;
      end;
    embsSearch: if Assigned(FOnSearchClick) then
        FOnSearchClick(Self);
    embsPassword:
      { Reveal/mask is driven by MouseDown/MouseUp (hold-to-reveal), so here
        we only return the caret to the edit — at the position the user left it
        and WITHOUT selecting the password (see FocusEditKeepCaret). }
      FocusEditKeepCaret;
  end;
  if Assigned(FOnButtonClick) then
    FOnButtonClick(Self);
end;

procedure TCWSEditMask.DrawIcon(G: TGPGraphics; Rect: TGPRectF; Style: TCWSEditMaskButtonStyle);
var
  Pen: TGPPen;
  Brush: TGPSolidBrush;
  IconR: TGPRectF;
  GPBmp: TGPBitmap;
  FinalMargin: Single;
  TempBmp: TBitmap;
  TargetSize: Single;
begin
  Pen := TGPPen.Create(MakeGPColor(FButtonIconColor), ScaleF(1.2));
  Brush := TGPSolidBrush.Create(MakeGPColor(FButtonIconColor));
  try
    if FButtonIconSize > 0 then
    begin
      // Fixed icon size mode — value given in px at design-time,
      // scaled with DPI, icon centered inside the button area.
      // Clamping to the button size prevents the icon from "sticking out"
      // even for very large values.
      TargetSize := Scale(FButtonIconSize);
      if TargetSize > Rect.Width then
        TargetSize := Rect.Width;
      if TargetSize > Rect.Height then
        TargetSize := Rect.Height;

      IconR.X := Rect.X + (Rect.Width - TargetSize) / 2;
      IconR.Y := Rect.Y + (Rect.Height - TargetSize) / 2;
      IconR.Width := TargetSize;
      IconR.Height := TargetSize;
    end
    else
    begin
      // Default mode (behavior from before ButtonIconSize was added) —
      // icon fills the button minus margin. Round prevents
      // the icon from "floating" between pixels and looking blurry.
      FinalMargin := Round(ScaleF(7.0));
      if Style = embsClear then
        FinalMargin := FinalMargin + ScaleF(0.5);

      IconR := Rect;
      IconR.X := IconR.X + FinalMargin;
      IconR.Y := IconR.Y + FinalMargin;
      IconR.Width := IconR.Width - (FinalMargin * 2);
      IconR.Height := IconR.Height - (FinalMargin * 2);
    end;

    G.SetSmoothingMode(SmoothingModeAntiAlias);
    G.SetInterpolationMode(InterpolationModeHighQualityBicubic);

    case Style of
      embsClear:
        begin
          G.DrawLine(Pen, IconR.X, IconR.Y, IconR.X + IconR.Width, IconR.Y + IconR.Height);
          G.DrawLine(Pen, IconR.X + IconR.Width, IconR.Y, IconR.X, IconR.Y + IconR.Height);
        end;

      embsSearch:
        begin
          G.DrawEllipse(Pen, IconR.X, IconR.Y, IconR.Width * 0.7, IconR.Height * 0.7);
          G.DrawLine(Pen, IconR.X + IconR.Width * 0.6, IconR.Y + IconR.Height * 0.6,
            IconR.X + IconR.Width, IconR.Y + IconR.Height);
        end;

      embsPassword:
        begin
          G.DrawEllipse(Pen, IconR.X, IconR.Y + IconR.Height * 0.2, IconR.Width, IconR.Height * 0.6);
          G.FillEllipse(Brush, IconR.X + IconR.Width * 0.35, IconR.Y + IconR.Height * 0.35,
            IconR.Width * 0.3, IconR.Height * 0.3);
          if (FEdit <> nil) and (FEdit.PasswordChar <> #0) then
            G.DrawLine(Pen, IconR.X + IconR.Width, IconR.Y + IconR.Height * 0.2,
              IconR.X, IconR.Y + IconR.Height * 0.8);
        end;

      embsCustom:
        begin
          if Assigned(FImages) and (FImageIndex >= 0) and (FImageIndex < FImages.Count) then
          begin
            TempBmp := TBitmap.Create;
            try
              TempBmp.PixelFormat := pf32bit;
              TempBmp.AlphaFormat := afPremultiplied;
              TempBmp.SetSize(FImages.Width, FImages.Height);
              ZeroMemory(TempBmp.ScanLine[TempBmp.Height - 1],
                TempBmp.Width * TempBmp.Height * 4);
              FImages.Draw(TempBmp.Canvas, 0, 0, FImageIndex);
              GPBmp := TGPBitmap.Create(TempBmp.Width, TempBmp.Height,
                -TempBmp.Width * 4, PixelFormat32bppPARGB,
                TempBmp.ScanLine[0]);
              try
                if GPBmp.GetLastStatus = Ok then
                  G.DrawImage(GPBmp, IconR.X, IconR.Y, IconR.Width, IconR.Height);
              finally
                GPBmp.Free;
              end;
            finally
              TempBmp.Free;
            end;
          end
          else if Assigned(FButtonIcon) and Assigned(FButtonIcon.Graphic)
            and (not FButtonIcon.Graphic.Empty) then
          begin
            GPBmp := TGPBitmap.Create(FButtonIcon.Bitmap.Handle, 0);
            try
              if GPBmp.GetLastStatus = Ok then
                G.DrawImage(GPBmp, IconR.X, IconR.Y, IconR.Width, IconR.Height);
            finally
              GPBmp.Free;
            end;
          end;
        end;
    end;
  finally
    Pen.Free;
    Brush.Free;
  end;
end;

procedure TCWSEditMask.PaintToBuffer;
var
  G: TGPGraphics;
  Path: TGPGraphicsPath;
  Brush: TGPSolidBrush;
  Pen: TGPPen;
  W, H, R: Single;
  FontFamily: TGPFontFamily;
  GPFont: TGPFont;
  TextBrush: TGPSolidBrush;
  LblColor: TColor;
  BtnR: TRect;
  BtnPath: TGPGraphicsPath;
begin
  EnsureBuffer;
  W := Width;
  H := Height;
  R := ScaleF(FCornerRadius);
  FBuffer.Canvas.Brush.Color := GetParentBgColor;
  FBuffer.Canvas.FillRect(Rect(0, 0, Width, Height));
  DrawParentBackground(FBuffer.Canvas.Handle, R);
  G := TGPGraphics.Create(FBuffer.Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);
    G.SetPixelOffsetMode(PixelOffsetModeHalf);
    Path := CreateRoundRectPath(0.5, 0.5, W - 1, H - 1, R);
    try
      Brush := TGPSolidBrush.Create(MakeGPColor(GetCurrentBgColor));
      try
        G.FillPath(Brush, Path);
      finally Brush.Free;
      end;
      Pen := TGPPen.Create(MakeGPColor(GetCurrentBorderColor), 1.0);
      try
        G.DrawPath(Pen, Path);
      finally Pen.Free;
      end;
    finally Path.Free;
    end;

    if FButtonStyle <> embsNone then
    begin
      BtnR := GetButtonRect;
      if FButtonPressed and FButtonHovered then
      begin
        BtnPath := CreateRoundRectPath(BtnR.Left, BtnR.Top, BtnR.Width, BtnR.Height, R);
        Brush := TGPSolidBrush.Create(MakeGPColor(FButtonPressedColor));
        try
          G.FillPath(Brush, BtnPath);
        finally Brush.Free;
          BtnPath.Free;
        end;
      end
      else if FButtonHovered then
      begin
        BtnPath := CreateRoundRectPath(BtnR.Left, BtnR.Top, BtnR.Width, BtnR.Height, R);
        Brush := TGPSolidBrush.Create(MakeGPColor(FButtonHoverColor));
        try
          G.FillPath(Brush, BtnPath);
        finally Brush.Free;
          BtnPath.Free;
        end;
      end;
      // First draw the GDI+ button background, then call DrawIcon
      DrawIcon(G, MakeRect(Single(BtnR.Left), Single(BtnR.Top), Single(BtnR.Width), Single(BtnR.Height)), FButtonStyle);
    end;

    if FFocused and Enabled then
    begin
      Path := CreateRoundRectPath(0.0, 0.0, W, H, R);
      try
        G.SetClip(Path);
      finally Path.Free;
      end;
      G.SetSmoothingMode(SmoothingModeNone);
      Brush := TGPSolidBrush.Create(MakeGPColor(FAccentColor));
      try
        G.FillRectangle(Brush, 0, Height - Scale(2), Width, Scale(2));
      finally Brush.Free;
      end;
      G.ResetClip;
    end;

    if FLabel <> '' then
    begin
      G.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
      FontFamily := TGPFontFamily.Create('Segoe UI');
      try
        GPFont := TGPFont.Create(FontFamily, ScaleF(9), FontStyleRegular, UnitPixel);
        try
          if FFocused then
            LblColor := FAccentColor
          else
            LblColor := FLabelColor;
          TextBrush := TGPSolidBrush.Create(MakeGPColor(LblColor));
          try
            G.DrawString(FLabel, -1, GPFont, MakePoint(R + ScaleF(8), ScaleF(5)), TextBrush);
          finally
            TextBrush.Free;
          end;
        finally
          GPFont.Free;
        end;
      finally
        FontFamily.Free;
      end;
    end;
  finally
    G.Free;
  end;
end;

procedure TCWSEditMask.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FImages) then
    FImages := nil;
end;

procedure TCWSEditMask.UpdateEditPosition;
var
  L, T, R, B, Margin, RightMargin: Integer;
  InnerLeftMargin: Integer;
begin
  if (FEdit = nil) or (FEdit.Font = nil) then
    Exit;
  Margin := Scale(8) + Round(ScaleF(FCornerRadius));
  L := Margin;
  if FButtonStyle <> embsNone then
    RightMargin := Width - GetButtonRect.Left + Scale(2)
  else
    RightMargin := Margin;
  R := Width - RightMargin;

  // With taCenter and a visible button: FEdit stays in its original
  // geometry (from the left edge to the button), but we shift the text
  // centering point to the right by the inner LEFT margin of the edit.
  // Value = RightMargin - Margin (~ button width) makes
  // Windows center the text exactly in the middle of the WHOLE component.
  // Without the button: InnerLeftMargin = 0 (RightMargin = Margin).
  InnerLeftMargin := 0;
  if (FAlignment = taCenter) and (FButtonStyle <> embsNone) then
    InnerLeftMargin := RightMargin - Margin;

  // Save the margin BEFORE SetBounds, so that WMSize (triggered by
  // SetBounds) applies the correct value immediately. The second
  // ApplyInnerMargins at the end is for safety (belt-and-suspenders).
  FEdit.FInnerLeftMargin := InnerLeftMargin;

  Canvas.Font.Assign(Font);
  if FLabel <> '' then
    T := Scale(18) + Scale(6)
  else
    T := (Height - Canvas.TextHeight('Ag')) div 2;
  B := T + Canvas.TextHeight('Ag');
  if R <= L then
    R := L + 1;
  if B <= T then
    B := T + 1;
  FEdit.SetBounds(L, T, R - L, B - T);
  FEdit.ApplyInnerMargins;
end;

procedure TCWSEditMask.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  IsOverBtn: Boolean;
begin
  inherited;
  if FButtonStyle <> embsNone then
  begin
    IsOverBtn := PtInRect(GetButtonRect, Point(X, Y));
    if FButtonHovered <> IsOverBtn then
    begin
      FButtonHovered := IsOverBtn;
      Invalidate;
      if FButtonHovered then
        Cursor := crArrow
      else
        Cursor := crIBeam;
    end;
  end;
end;

procedure TCWSEditMask.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and FButtonHovered then
  begin
    { Show the pressed state now and fire the action on release (the usual
      button behaviour), so ButtonPressedColor is actually visible. Capture the
      mouse so we still receive MouseUp if the cursor drifts off the button. }
    FButtonPressed := True;
    MouseCapture := True;
    { embsPassword works like the WinUI 3 reveal button: the text is visible only
      while the button is held down and gets masked again on release. }
    SetPasswordReveal(True);
    Invalidate;
    Exit;
  end;
  inherited;
  // Pass focus to the inner edit after a click anywhere on the component
  if (Button = mbLeft) and (FEdit <> nil) and FEdit.CanFocus then
    FocusEditKeepCaret;
end;

procedure TCWSEditMask.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  WasPressed: Boolean;
begin
  WasPressed := FButtonPressed;
  if FButtonPressed then
  begin
    FButtonPressed := False;
    MouseCapture := False;
    { Mask again on release — also when the release lands outside the button }
    SetPasswordReveal(False);
    { Keep the hover state in sync now that capture is released }
    FButtonHovered := PtInRect(GetButtonRect, Point(X, Y));
    Invalidate;
  end;
  inherited;
  { Fire only on a release that lands back on the button — a release dragged
    off the button cancels the click, like a standard push button. }
  if WasPressed and (Button = mbLeft) and PtInRect(GetButtonRect, Point(X, Y)) then
    HandleButtonClick;
  Invalidate;
end;

// WM_LBUTTONDOWN handling as backup — when the click lands directly on the window
// (e.g. padding, label, border area) and isn't intercepted by MouseDown
procedure TCWSEditMask.WMLButtonDown(var Msg: TWMLButtonDown);
begin
  inherited;
  { NOT for a click on the button: MouseDown (dispatched by the inherited call
    above) has already started the embsPassword reveal, and focusing the edit from
    here would run the select-all paths and select the whole password — exactly
    what the reveal button must not do. The button returns the focus itself,
    caret-preserving, in HandleButtonClick. }
  if (FButtonStyle <> embsNone) and
     PtInRect(GetButtonRect, Point(Msg.XPos, Msg.YPos)) then
    Exit;
  if (FEdit <> nil) and FEdit.CanFocus and not FEdit.Focused then
    FocusEditKeepCaret;
end;

// Capture can be cancelled without a MouseUp (modal dialog, Alt+Tab, ESC).
// Without this the revealed password would stay visible.
procedure TCWSEditMask.WMCancelMode(var Msg: TMessage);
begin
  inherited;
  if FButtonPressed then
  begin
    FButtonPressed := False;
    SetPasswordReveal(False);
    Invalidate;
  end;
end;

procedure TCWSEditMask.SetButtonStyle(const Value: TCWSEditMaskButtonStyle);
begin
  if FButtonStyle <> Value then
  begin
    FButtonStyle := Value;
    UpdateEditPosition;
    Invalidate;
  end;
end;

procedure TCWSEditMask.SetButtonIconColor(const Value: TColor);
begin
  if FButtonIconColor <> Value then
  begin
    FButtonIconColor := Value;
    Invalidate;
  end;
end;

procedure TCWSEditMask.SetButtonHoverColor(const Value: TColor);
begin
  if FButtonHoverColor <> Value then
  begin
    FButtonHoverColor := Value;
    Invalidate;
  end;
end;

procedure TCWSEditMask.SetButtonPressedColor(const Value: TColor);
begin
  if FButtonPressedColor <> Value then
  begin
    FButtonPressedColor := Value;
    Invalidate;
  end;
end;

procedure TCWSEditMask.SetButtonIcon(const Value: TPicture);
begin
  FButtonIcon.Assign(Value);
end;

procedure TCWSEditMask.SetButtonIconSize(const Value: Integer);
var
  NewVal: Integer;
begin
  // Negative values make no sense - clamp to 0 (= auto mode).
  NewVal := Value;
  if NewVal < 0 then
    NewVal := 0;
  if FButtonIconSize <> NewVal then
  begin
    FButtonIconSize := NewVal;
    if FButtonStyle <> embsNone then
      Invalidate;
  end;
end;

procedure TCWSEditMask.SetImages(const Value: TCustomImageList);
begin
  if FImages <> Value then
  begin
    FImages := Value;
    if FImages <> nil then
      FImages.FreeNotification(Self);
    Invalidate;
  end;
end;

procedure TCWSEditMask.SetImageIndex(const Value: TImageIndex);
begin
  if FImageIndex <> Value then
  begin
    FImageIndex := Value;
    Invalidate;
  end;
end;

procedure TCWSEditMask.ButtonIconChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TCWSEditMask.ApplyDefaultFont;
begin
  if (Self.Font.Name = 'Tahoma') and (Self.Font.Size = 8) then
  begin
    Self.Font.Name := 'Segoe UI';
    Self.Font.Size := 10;
  end;
end;

procedure TCWSEditMask.SyncEditFont;
begin
  if FEdit = nil then
    Exit;
  FEdit.Font.Assign(Font);
  AdjustHeight;
  UpdateEditPosition;
  Invalidate;
end;

procedure TCWSEditMask.Loaded;
begin
  inherited;
  if not ParentFont then
    ApplyDefaultFont;
  SyncEditFont;
end;

procedure TCWSEditMask.EditEnter(Sender: TObject);
begin
  FFocused := True;
  ApplyStateChange;
  if FAutoSelect and not FReadOnly then
    PostMessage(FEdit.Handle, EM_SETSEL, 0, -1);
  if Assigned(FOnEnter) then
    FOnEnter(Self);
end;

procedure TCWSEditMask.EditExit(Sender: TObject);
begin
  FFocused := False;
  ApplyStateChange;
  // Mask validation is handled in TCWSMaskBufferedEdit.CMExit (it fires
  // OnValidationError via DoMaskInvalid and, when ValidateOnExit is set, keeps
  // focus here). By the time OnExit runs the input is either valid or the user
  // chose to leave, so nothing to do here but forward the event.
  if Assigned(FOnExit) then
    FOnExit(Self);
end;

procedure TCWSEditMask.EditChange(Sender: TObject);
begin
  FText := FEdit.Text;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TCWSEditMask.EditKeyPress(Sender: TObject; var Key: Char);
begin
  if Assigned(FOnKeyPress) then
    FOnKeyPress(Self, Key);
end;

procedure TCWSEditMask.EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnKeyDown) then
    FOnKeyDown(Self, Key, Shift);
end;

procedure TCWSEditMask.EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnKeyUp) then
    FOnKeyUp(Self, Key, Shift);
end;

procedure TCWSEditMask.EditClick(Sender: TObject);
begin
  if Assigned(FOnClick) then
    FOnClick(Self);
end;

procedure TCWSEditMask.EditDblClick(Sender: TObject);
begin
  if Assigned(FOnDblClick) then
    FOnDblClick(Self);
end;

procedure TCWSEditMask.EditMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseDown) then
    FOnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TCWSEditMask.EditMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseUp) then
    FOnMouseUp(Self, Button, Shift, X, Y);
end;

procedure TCWSEditMask.EditMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseMove) then
    FOnMouseMove(Self, Shift, X, Y);
end;

procedure TCWSEditMask.EditContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
var
  ScreenPos: TPoint;
begin
  if Assigned(FOnContextPopup) then
    FOnContextPopup(Self, MousePos, Handled);
  if not Handled and Assigned(PopupMenu) then
  begin
    ScreenPos := FEdit.ClientToScreen(MousePos);
    PopupMenu.Popup(ScreenPos.X, ScreenPos.Y);
    Handled := True;
  end;
end;

function TCWSEditMask.Scale(Value: Integer): Integer;
begin
  Result := MulDiv(Value, CurrentPPI, 96);
end;

function TCWSEditMask.ScaleF(Value: Single): Single;
begin
  Result := Value * CurrentPPI / 96;
end;

function TCWSEditMask.MakeGPColor(AColor: TColor; Alpha: Byte): Cardinal;
var
  C: TColor;
begin
  C := ColorToRGB(AColor);
  Result := Winapi.GDIPAPI.MakeColor(Alpha, GetRValue(C), GetGValue(C), GetBValue(C));
end;

function TCWSEditMask.CreateRoundRectPath(X, Y, W, H, R: Single): TGPGraphicsPath;
var
  D: Single;
begin
  Result := TGPGraphicsPath.Create;
  D := R * 2;
  if D > H then
    D := H;
  if D > W then
    D := W;
  Result.AddArc(X, Y, D, D, 180, 90);
  Result.AddArc(X + W - D, Y, D, D, 270, 90);
  Result.AddArc(X + W - D, Y + H - D, D, D, 0, 90);
  Result.AddArc(X, Y + H - D, D, D, 90, 90);
  Result.CloseFigure;
end;

function TCWSEditMask.GetParentBgColor: TColor;
begin
  if Parent <> nil then
    Result := TControlAccess(Parent).Color
  else
    Result := clBtnFace;
end;

procedure TCWSEditMask.DrawParentBackground(DC: HDC; ARadius: Single);
var
  SaveIdx: Integer;
  Rgn: HRGN;
  D: Integer;
begin
  { The GetParentBgColor fill done by the caller is only a correct guess when the
    parent paints itself as a flat fill of that very color. A container drawing a
    gradient/card background, a VCL-styled form, or a parent whose Color is out
    of sync with what it actually paints all leave visible wrong-colored
    triangles outside our rounded corners — so let the parent render its real
    background here instead.
    Skipped at design time: a form's PaintWindow draws the designer dot grid,
    which would then bleed into the corners. }
  if (Parent = nil) or (csDesigning in ComponentState) then
    Exit;
  SaveIdx := SaveDC(DC);
  try
    { Clip to the sliver outside the rounded body (inset by 1 px so the
      antialiased edge blends against real parent pixels). Keeps the parent's
      paint cheap — it is repeated on every hover/focus repaint. Region
      coordinates are device units, so this must happen before MoveWindowOrg. }
    D := Round(ARadius) * 2;
    Rgn := CreateRoundRectRgn(1, 1, Width, Height, D, D);
    try
      ExtSelectClipRgn(DC, Rgn, RGN_DIFF);
    finally
      DeleteObject(Rgn);
    end;
    { Shift the origin so the parent paints in its own coordinate system. }
    MoveWindowOrg(DC, -Left, -Top);
    Parent.Perform(WM_ERASEBKGND, WPARAM(DC), 0);
    { Parents that swallow WM_ERASEBKGND and paint in WM_PAINT (all the CWStudio
      containers do) only respond to this one. }
    Parent.Perform(WM_PRINTCLIENT, WPARAM(DC), PRF_CLIENT);
  finally
    RestoreDC(DC, SaveIdx);
  end;
end;

procedure TCWSEditMask.EnsureBuffer;
begin
  if (FBuffer.Width <> Width) or (FBuffer.Height <> Height) then
    FBuffer.SetSize(Width, Height);
end;

procedure TCWSEditMask.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

function TCWSEditMask.GetCurrentBgColor: TColor;
begin
  if not Enabled then
    Result := FDisabledColor
  else if FFocused then
    Result := FBackgroundFocusColor
  else if FHovered then
    Result := FBackgroundHoverColor
  else
    Result := FBackgroundColor;
end;

function TCWSEditMask.GetCurrentBorderColor: TColor;
begin
  if not Enabled then
    Result := FDisabledBorderColor
  else
    Result := FBorderColor;
end;

function TCWSEditMask.Focused: Boolean;
begin
  Result := inherited Focused or ((FEdit <> nil) and FEdit.Focused);
end;

procedure TCWSEditMask.ApplyStateChange;
var
  C: TColor;
  FullRgn, EditRgn: HRGN;
begin
  if FEdit = nil then
    Exit;
  C := GetCurrentBgColor;
  if FEdit.Color <> C then
  begin
    FEdit.Color := C;
    if FEdit.HandleAllocated then
      FEdit.Invalidate;
  end;
  if HandleAllocated then
  begin
    FullRgn := CreateRectRgn(0, 0, Width, Height);
    EditRgn := CreateRectRgn(FEdit.Left, FEdit.Top, FEdit.Left + FEdit.Width, FEdit.Top + FEdit.Height);
    CombineRgn(FullRgn, FullRgn, EditRgn, RGN_DIFF);
    InvalidateRgn(Handle, FullRgn, False);
    DeleteObject(EditRgn);
    DeleteObject(FullRgn);
  end
  else
    Invalidate;
end;

procedure TCWSEditMask.AdjustHeight;
var
  NewH: Integer;
begin
  if not FAutoSizeHeight or (FEdit = nil) then
    Exit;
  Canvas.Font.Assign(Font);
  if FLabel <> '' then
    NewH := Scale(18) + Canvas.TextHeight('Ag') + Scale(12)
  else
    NewH := Canvas.TextHeight('Ag') + Scale(12);
  if NewH < Scale(28) then
    NewH := Scale(28);
  if Height <> NewH then
    Height := NewH;
end;

procedure TCWSEditMask.SetAutoSizeHeight(const Value: Boolean);
begin
  if FAutoSizeHeight <> Value then
  begin
    FAutoSizeHeight := Value;
    if FAutoSizeHeight then
      AdjustHeight;
  end;
end;

procedure TCWSEditMask.CMFontChanged(var Msg: TMessage);
begin
  inherited;
  SyncEditFont;
end;

procedure TCWSEditMask.CMParentFontChanged(var Msg: TMessage);
begin
  inherited;
  SyncEditFont;
end;

procedure TCWSEditMask.WMPaint(var Msg: TWMPaint);
var
  PS: TPaintStruct;
  DC: HDC;
begin
  if Msg.DC <> 0 then
  begin
    inherited;
    Exit;
  end;
  DC := BeginPaint(Handle, PS);
  try
    PaintToBuffer;
    BitBlt(DC, 0, 0, Width, Height, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  finally EndPaint(Handle, PS);
  end;
end;

procedure TCWSEditMask.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or WS_CLIPCHILDREN;
end;

procedure TCWSEditMask.Paint;
begin
  PaintToBuffer;
  BitBlt(Canvas.Handle, 0, 0, Width, Height, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure TCWSEditMask.Resize;
begin
  inherited;
  UpdateEditPosition;
  Invalidate;
end;

procedure TCWSEditMask.CreateWnd;
begin
  inherited;
  if FEdit <> nil then
  begin
    FEdit.Font.Assign(Font);
    AdjustHeight;
    UpdateEditPosition;
  end;
end;

procedure TCWSEditMask.ChangeScale(M, D: Integer);
begin
  inherited ChangeScale(M, D);
  SyncEditFont;
end;

procedure TCWSEditMask.SetFocus;
begin
  if FEdit.CanFocus then
    FEdit.SetFocus
  else
    inherited;
end;

procedure TCWSEditMask.CMMouseEnter(var Msg: TMessage);
begin
  inherited;
  if not FHovered then
  begin
    FHovered := True;
    ApplyStateChange;
  end;
  if Assigned(FOnMouseEnter) then
    FOnMouseEnter(Self);
end;

procedure TCWSEditMask.CMMouseLeave(var Msg: TMessage);
begin
  inherited;
  if FHovered then
  begin
    FHovered := False;
    ApplyStateChange;
  end;
  FButtonHovered := False;
  Invalidate;
  if Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TCWSEditMask.CMEnabledChanged(var Msg: TMessage);
begin
  inherited;
  ApplyStateChange;
end;

procedure TCWSEditMask.WMContextMenu(var Msg: TWMContextMenu);
var
  MousePos: TPoint;
  Handled: Boolean;
begin
  if Msg.XPos = -1 then
    MousePos := Point(-1, -1)
  else
    MousePos := ScreenToClient(Point(Msg.XPos, Msg.YPos));
  Handled := False;
  if Assigned(FOnContextPopup) then
    FOnContextPopup(Self, MousePos, Handled);
  if not Handled and Assigned(PopupMenu) then
  begin
    if Msg.XPos = -1 then
    begin
      MousePos := ClientToScreen(Point(0, 0));
      PopupMenu.Popup(MousePos.X, MousePos.Y);
    end
    else
      PopupMenu.Popup(Msg.XPos, Msg.YPos);
  end
  else if not Handled and (FEdit <> nil) and FEdit.HandleAllocated then
    FEdit.Perform(WM_CONTEXTMENU, FEdit.Handle, MakeLParam(Word(Msg.XPos), Word(Msg.YPos)));
end;

function TCWSEditMask.GetText: string;
begin
  if FEdit <> nil then
    Result := FEdit.Text
  else
    Result := FText;
end;

procedure TCWSEditMask.SetText(const Value: string);
begin
  FText := Value;
  if FEdit <> nil then
    try
      FEdit.Text := Value;
    except
      // The value does not fit the current mask — keep the field unchanged
      // instead of letting the mask validator raise.
    end;
end;

function TCWSEditMask.GetEditMask: string;
begin
  if FEdit <> nil then
    Result := FEdit.EditMask
  else
    Result := FEditMask;
end;

procedure TCWSEditMask.SetEditMask(const Value: string);
begin
  if FEditMask <> Value then
  begin
    FEditMask := Value;
    if FEdit <> nil then
    begin
      FEdit.EditMask := Value;
      FEdit.Font.Assign(Font);
      UpdateEditPosition;
      Invalidate;
    end;
  end;
end;

function TCWSEditMask.GetEditText: string;
begin
  if FEdit <> nil then
    Result := FEdit.EditText
  else
    Result := '';
end;

procedure TCWSEditMask.SetEditText(const Value: string);
begin
  if FEdit <> nil then
    FEdit.EditText := Value;
end;

procedure TCWSEditMask.SetValidateOnExit(const Value: Boolean);
begin
  FValidateOnExit := Value;
  if FEdit <> nil then
    FEdit.FEnforceOnExit := Value;
end;

procedure TCWSEditMask.DoMaskInvalid(Sender: TObject);
begin
  // Called by the inner edit when focus leaves with modified, incomplete input.
  if Assigned(FOnValidationError) then
    FOnValidationError(Self);
end;

procedure TCWSEditMask.DoInputInvalid(Sender: TObject);
begin
  // Called by the inner edit when Enter is pressed with input that does not
  // satisfy the mask. Replaces the native "Invalid input value" message box —
  // handle the bad input here (show your own hint, beep, etc.).
  if Assigned(FOnInputInvalid) then
    FOnInputInvalid(Self);
end;

function TCWSEditMask.IsValid: Boolean;
begin
  // Side-effect-free: no message box, no focus stealing. With no mask the
  // field is always considered valid.
  Result := (FEdit = nil) or FEdit.InputMatchesMask;
end;

procedure TCWSEditMask.ValidateEdit;
begin
  // Opt-in strict validation: raises (so callers can wrap it in try/except),
  // but without the native beep / focus-trap side effects.
  if (FEdit <> nil) and not FEdit.InputMatchesMask then
    raise EDBEditError.CreateFmt('Invalid input value for mask "%s".',
      [FEdit.EditMask]);
end;

procedure TCWSEditMask.SetLabel(const Value: string);
begin
  if FLabel <> Value then
  begin
    FLabel := Value;
    AdjustHeight;
    UpdateEditPosition;
    Invalidate;
  end;
end;

procedure TCWSEditMask.SetCornerRadius(const Value: Single);
begin
  if FCornerRadius <> Value then
  begin
    FCornerRadius := Max(0, Min(Value, 20));
    UpdateEditPosition;
    Invalidate;
  end;
end;

procedure TCWSEditMask.SetAccentColor(const Value: TColor);
begin
  if FAccentColor <> Value then
  begin
    FAccentColor := Value;
    Invalidate;
  end;
end;

procedure TCWSEditMask.SetBackgroundColor(const Value: TColor);
begin
  if FBackgroundColor <> Value then
  begin
    FBackgroundColor := Value;
    ApplyStateChange;
  end;
end;

procedure TCWSEditMask.SetBackgroundFocusColor(const Value: TColor);
begin
  if FBackgroundFocusColor <> Value then
  begin
    FBackgroundFocusColor := Value;
    // Refresh now so a focused control adopts the new theme color
    // immediately, without waiting for a mouse-over to repaint.
    if FFocused then
      ApplyStateChange;
  end;
end;

procedure TCWSEditMask.SetBackgroundHoverColor(const Value: TColor);
begin
  if FBackgroundHoverColor <> Value then
  begin
    FBackgroundHoverColor := Value;
    if FHovered and not FFocused then
      ApplyStateChange;
  end;
end;

procedure TCWSEditMask.SetBorderColor(const Value: TColor);
begin
  if FBorderColor <> Value then
  begin
    FBorderColor := Value;
    Invalidate;
  end;
end;

procedure TCWSEditMask.SetDisabledColor(const Value: TColor);
begin
  if FDisabledColor <> Value then
  begin
    FDisabledColor := Value;
    if not Enabled then
      ApplyStateChange;
  end;
end;

procedure TCWSEditMask.SetDisabledBorderColor(const Value: TColor);
begin
  if FDisabledBorderColor <> Value then
  begin
    FDisabledBorderColor := Value;
    if not Enabled then
      Invalidate;
  end;
end;

procedure TCWSEditMask.SetReadOnly(const Value: Boolean);
begin
  FReadOnly := Value;
  if FEdit <> nil then
    FEdit.ReadOnly := Value;
end;

procedure TCWSEditMask.SetPasswordChar(const Value: Char);
begin
  FPasswordChar := Value;
  if FEdit <> nil then
  begin
    FEdit.PasswordChar := Value;
    FEdit.Font.Assign(Font);
    UpdateEditPosition;
    Invalidate;
  end;
end;

procedure TCWSEditMask.SetMaxLength(const Value: Integer);
begin
  FMaxLength := Value;
  if FEdit <> nil then
    FEdit.MaxLength := Value;
end;

procedure TCWSEditMask.SetAutoSelect(const Value: Boolean);
begin
  FAutoSelect := Value;
  if FEdit <> nil then
    FEdit.AutoSelect := Value;
end;

procedure TCWSEditMask.SetTextHint(const Value: string);
begin
  FTextHint := Value;
  if FEdit <> nil then
    FEdit.TextHint := Value;
end;

procedure TCWSEditMask.SetNumbersOnly(const Value: Boolean);
begin
  FNumbersOnly := Value;
  if FEdit <> nil then
  begin
    FEdit.NumbersOnly := Value;
    FEdit.Font.Assign(Font);
    UpdateEditPosition;
    Invalidate;
  end;
end;

procedure TCWSEditMask.SetCharCase(const Value: TEditCharCase);
begin
  FCharCase := Value;
  if FEdit <> nil then
  begin
    FEdit.CharCase := Value;
    FEdit.Font.Assign(Font);
    UpdateEditPosition;
    Invalidate;
  end;
end;

procedure TCWSEditMask.SetHideSelection(const Value: Boolean);
begin
  FHideSelection := Value;
  if FEdit <> nil then
    FEdit.HideSelection := Value;
end;

procedure TCWSEditMask.SetSelectionColor(const Value: TColor);
begin
  if FSelectionColor <> Value then
  begin
    FSelectionColor := Value;
    if FEdit <> nil then
    begin
      FEdit.FSelectionColor := Value;
      FEdit.FUseCustomSelection := (FSelectionColor <> clNone) or (FSelectionTextColor <> clNone);
      FEdit.Invalidate;
    end;
  end;
end;

procedure TCWSEditMask.SetSelectionTextColor(const Value: TColor);
begin
  if FSelectionTextColor <> Value then
  begin
    FSelectionTextColor := Value;
    if FEdit <> nil then
    begin
      FEdit.FSelectionTextColor := Value;
      FEdit.FUseCustomSelection := (FSelectionColor <> clNone) or (FSelectionTextColor <> clNone);
      FEdit.Invalidate;
    end;
  end;
end;

procedure TCWSEditMask.SetAlignment(const Value: TAlignment);
begin
  if FAlignment <> Value then
  begin
    FAlignment := Value;
    if FEdit <> nil then
      FEdit.Alignment := Value;
    UpdateEditPosition;
    Invalidate;
  end;
end;

procedure TCWSEditMask.SetEnabled(Value: Boolean);
begin
  inherited SetEnabled(Value);
  if FEdit <> nil then
    FEdit.Enabled := Value;
  ApplyStateChange;
end;

function TCWSEditMask.GetSelStart: Integer;
begin
  if FEdit <> nil then
    Result := FEdit.SelStart
  else
    Result := 0;
end;

procedure TCWSEditMask.SetSelStart(const Value: Integer);
begin
  if FEdit <> nil then
    FEdit.SelStart := Value;
end;

function TCWSEditMask.GetSelLength: Integer;
begin
  if FEdit <> nil then
    Result := FEdit.SelLength
  else
    Result := 0;
end;

procedure TCWSEditMask.SetSelLength(const Value: Integer);
begin
  if FEdit <> nil then
    FEdit.SelLength := Value;
end;

function TCWSEditMask.GetSelText: string;
begin
  if FEdit <> nil then
    Result := FEdit.SelText
  else
    Result := '';
end;

procedure TCWSEditMask.SetSelText(const Value: string);
begin
  if FEdit <> nil then
    FEdit.SelText := Value;
end;

procedure TCWSEditMask.Clear;
begin
  if FEdit <> nil then
    FEdit.Clear;
end;

procedure TCWSEditMask.ClearSelection;
begin
  if FEdit <> nil then
    FEdit.ClearSelection;
end;

procedure TCWSEditMask.CopyToClipboard;
begin
  if FEdit <> nil then
    FEdit.CopyToClipboard;
end;

procedure TCWSEditMask.CutToClipboard;
begin
  if FEdit <> nil then
    FEdit.CutToClipboard;
end;

procedure TCWSEditMask.PasteFromClipboard;
begin
  if FEdit <> nil then
    FEdit.PasteFromClipboard;
end;

procedure TCWSEditMask.SelectAll;
begin
  if FEdit <> nil then
    FEdit.SelectAll;
end;

procedure TCWSEditMask.Undo;
begin
  if FEdit <> nil then
    FEdit.Undo;
end;

end.
