//////////////////////////////////////////////////////////////////////////
//
//   CWStudio Component Library
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
  unit CWSDatePicker;

  {
    TCWSDatePicker — Windows 11 / WinUI3 style date picker component.
    Based on the CWSComboBox architecture.
    Includes a built-in TCWSBufferedEdit and a GDI+ popup with a calendar.
    Weekday and month names are taken dynamically from the system locale.
  }

  interface

  uses
    Winapi.Windows, Winapi.Messages, Winapi.GDIPAPI, Winapi.GDIPOBJ,
    Winapi.MultiMon,
    System.SysUtils, System.Classes, System.Types, System.Math, System.DateUtils,
    Vcl.Controls, Vcl.Graphics, Vcl.StdCtrls, Vcl.Forms, Vcl.Mask,
    CWSEdit;

  const
    WM_CWS_CLOSEDROPDOWN = WM_USER + 201;
    CM_PPICHANGED = $B080 + 13;

  type
    TCWSDatePicker = class;

    { TMaskEdit with WM_ERASEBKGND suppressed — background consistent with CWSDatePicker }
    TCWSBufferedMaskEdit = class(TMaskEdit)
    protected
      procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    public
      function GetCleanText: string;
    end;

    { ════════════════════════════════════════════════════════════════════════
        Popup Kalendarza (WinUI 3 Style)
      ════════════════════════════════════════════════════════════════════════ }
    TCWSCalendarDropdown = class(TCustomControl)
    private
      FDatePicker: TCWSDatePicker;
      FBuffer: TBitmap;

      FViewYear: Word;
      FViewMonth: Word;

      // 0 = days view, 1 = months view, 2 = years view
      FViewMode: Integer;
      FYearRangeStart: Integer; // first year in the current year grid
      FHoveredYearIdx: Integer;  // -1 = none
      FHoveredMonthIdx: Integer; // -1 = none

      FHoveredDayIdx: Integer;
      FHoveredBtn: Integer; // -1: none, 0: prev, 1: next, 2: label (month/year)

      { Geometria okna warstwowego (per-pixel alpha) }
      FScale: Single;
      FDpi: Integer;
      FBlur, FShadowOffset, FShadow: Integer;
      FMarginTop, FMarginBottom, FMarginSide: Integer;
      FBodyW, FBodyH, FWinW, FWinH: Integer;
      FWinLeft, FWinTop: Integer;
      FBodyScreen: TRect;         { screen rect of the list BODY (without shadow) }
      FOpenedUp: Boolean;         { list opened upwards (above the DatePicker)    }
      FShadowBits: TBytes;
      FHasShadow: Boolean;
      { Range (in pixels, local to the left edge of the BODY) of the actual
        contact of the top/bottom list edge with the component. Only this segment
        is "glued" — outside it the corners are rounded, with border and shadow. }
      FContactL, FContactR: Integer;

      { Control rect for erasing the shadow beneath it (in window coordinates)
        and the screen one (for passing clicks through). }
      FCtrlLocal: TRect;
      FCtrlScreen: TRect;

      { Returns which BODY corners should be rounded. The contact edge with the
        control has straight corners only within the actual contact
        (FContactL..FContactR); the "free" corners (protruding past the component) are rounded. }
      procedure CornerRoundFlags(out aTL, aTR, aBR, aBL: Boolean);

      function ScalePx(V: Integer): Integer;
      function BodyLeft: Integer;
      function BodyTop: Integer;
      function CornerRadiusPx: Single;
      function MakeGPColor(C: TColor; A: Byte = 255): Cardinal;
      function CreateRRPath(X, Y, W, H, R: Single): TGPGraphicsPath;

      procedure ComputeScale;
      procedure BuildShadow;
      procedure Render;
      procedure EnsureBuffer;
      procedure PaintToBuffer;
      procedure PaintCalendarView;
      procedure PaintMonthView;
      procedure PaintYearView;
      procedure PaintTodayBar(G: TGPGraphics; GPFont: TGPFont);

      // Grid calculations — calendar view
      function GetHeaderRect: TRect;
      function GetYearLabelRect: TRect;
      function GetMonthLabelRect: TRect;
      function GetMonthLabelHitRect: TRect;
      function GetYearLabelHitRect: TRect;
      function MeasureTitleText(const S: string): Integer;
      function GetPrevBtnRect: TRect;
      function GetNextBtnRect: TRect;
      function GetDaysHeaderRect: TRect;
      function GetGridRect: TRect;
      function GetTodayBarRect: TRect;
      function GetDayCellRect(Index: Integer): TRect;
      function GetDateForCell(Index: Integer): TDate;

      // Grid calculations — months view (4 columns × 3 rows)
      function GetMonthGridRect: TRect;
      function GetMonthCellRect(Index: Integer): TRect;

      // Grid calculations — years view (4 columns)
      function GetYearGridRect: TRect;
      function GetYearCellRect(Index: Integer): TRect;
      function GetYearForCell(Index: Integer): Integer;

      procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
      procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
      procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
      procedure WMMouseWheel(var Msg: TWMMouseWheel); message WM_MOUSEWHEEL;
      procedure WMLButtonDown(var Msg: TWMLButtonDown); message WM_LBUTTONDOWN;
      procedure WMMouseMove(var Msg: TWMMouseMove); message WM_MOUSEMOVE;
      procedure WMCWSClose(var Msg: TMessage); message WM_CWS_CLOSEDROPDOWN;
      procedure WMActivateApp(var Msg: TMessage); message WM_ACTIVATEAPP;
      procedure WMMouseActivate(var Msg: TWMMouseActivate); message WM_MOUSEACTIVATE;
      procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    protected
      procedure CreateParams(var Params: TCreateParams); override;
    public
      constructor Create(ADatePicker: TCWSDatePicker); reintroduce;
      destructor Destroy; override;
      procedure Invalidate; override;
      procedure ShowPopup(X, Y: Integer);
      procedure HidePopup;
      procedure ChangeMonth(Delta: Integer);
    end;

    TCWSDayShape = (dsRoundRect, dsCircle, dsRectangle);

    { ════════════════════════════════════════════════════════════════════════
        Main Component
      ════════════════════════════════════════════════════════════════════════ }
    TCWSDatePicker = class(TCustomControl)
    private
      FDate: TDate;
      FDateFormat: string;
      FDroppedDown: Boolean;
      FDropUp: Boolean;          { list opened upwards (above the DatePicker) }
      FDropdown: TCWSCalendarDropdown;
      FBuffer: TBitmap;
      FHovered: Boolean;
      FFocused: Boolean;

      FInternalEdit: TCWSBufferedMaskEdit;
      FEditInternalMarginL: Integer;
      FEditMask: string;

      { Appearance }
      FCornerRadius: Single;
      FBorderColor: TColor;
      FBackgroundColor: TColor;
      FBackgroundHoverColor: TColor;
      FDisabledColor: TColor;
      FDisabledBorderColor: TColor;
      FAccentColor: TColor;
      FTextColor: TColor;
      FDisabledTextColor: TColor;
      FDropdownBackColor: TColor;
      FDropdownCornerRadius: Single;
      FDropdownShadowEnabled: Boolean;
      FDropdownShadowSize: Integer;

      FAutoSizeHeight: Boolean;
      FTextHint: string;

      { Calendar appearance - day cells }
      FTodayBorderColor: TColor;
      FSelectedDayColor: TColor;
      FSelectedDayBorderColor: TColor;
      FSelectedDayTextColor: TColor;
      FHoverColor: TColor;
      FHoverTextColor: TColor;
      FOtherMonthTextColor: TColor;
      FOtherMonthHoverTextColor: TColor;
      FTodayTextColor: TColor;
      FTodayHoverTextColor: TColor;
      FLinkTextColor: TColor;
      FLinkHoverTextColor: TColor;
      FDayShape: TCWSDayShape;

      FOnChange: TNotifyEvent;
      FOnDropDown: TNotifyEvent;
      FOnCloseUp: TNotifyEvent;

      procedure SetDate(const Value: TDate);
      procedure SetDateFormat(const Value: string);

      // Appearance setters
      procedure SetCornerRadius(const Value: Single);
      procedure SetAccentColor(const Value: TColor);
      procedure SetBackgroundColor(const Value: TColor);
      procedure SetBackgroundHoverColor(const Value: TColor);
      procedure SetBorderColor(const Value: TColor);
      procedure SetDisabledColor(const Value: TColor);
      procedure SetDisabledBorderColor(const Value: TColor);
      procedure SetTextColor(const Value: TColor);
      procedure SetDisabledTextColor(const Value: TColor);
      procedure SetDropdownBackColor(const Value: TColor);
      procedure SetDropdownCornerRadius(const Value: Single);
      procedure SetDropdownShadowEnabled(const Value: Boolean);
      procedure SetDropdownShadowSize(const Value: Integer);
      procedure SetAutoSizeHeight(const Value: Boolean);
      procedure SetTextHint(const Value: string);
      procedure SetTodayBorderColor(const Value: TColor);
      procedure SetSelectedDayColor(const Value: TColor);
      procedure SetSelectedDayBorderColor(const Value: TColor);
      procedure SetSelectedDayTextColor(const Value: TColor);
      procedure SetHoverColor(const Value: TColor);
      procedure SetHoverTextColor(const Value: TColor);
      procedure SetOtherMonthTextColor(const Value: TColor);
      procedure SetOtherMonthHoverTextColor(const Value: TColor);
      procedure SetTodayTextColor(const Value: TColor);
      procedure SetTodayHoverTextColor(const Value: TColor);
      procedure SetLinkTextColor(const Value: TColor);
      procedure SetLinkHoverTextColor(const Value: TColor);
      procedure SetDayShape(const Value: TCWSDayShape);

      function GetCurrentBgColor: TColor;
      function GetCurrentBorderColor: TColor;
      function GetParentBgColor: TColor;
      function MakeGPColor(AColor: TColor; Alpha: Byte = 255): Cardinal;
      function CreateRoundRectPath(X, Y, W, H, R: Single): TGPGraphicsPath;
      function Scale(Value: Integer): Integer;
      function ScaleF(Value: Single): Single;
      function GetTextMarginL: Integer;

      procedure AdjustHeight;
      procedure EnsureBuffer;
      procedure PaintToBuffer;
      procedure ApplyStateChange;

      procedure OpenDropdown;
      procedure CloseDropdown;
      procedure CreateEdit;
      procedure DestroyEdit;
      procedure UpdateEditPosition;
      procedure SyncEditAppearance;
      procedure UpdateEditFromDate;
      procedure UpdateDateFromEdit;

      procedure SetEditMask(const Value: string);
      function DateFormatToMask(const ADateFormat: string): string;

      procedure EditChange(Sender: TObject);
      procedure EditEnter(Sender: TObject);
      procedure EditExit(Sender: TObject);
      procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
      procedure EditMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

      procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
      procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
      procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;
      procedure CMFontChanged(var Msg: TMessage); message CM_FONTCHANGED;
      procedure CMParentFontChanged(var Msg: TMessage); message CM_PARENTFONTCHANGED;
      procedure CMPPIChanged(var Msg: TMessage); message CM_PPICHANGED;
      procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
      procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
      procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
      procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;

    protected
      procedure CreateParams(var Params: TCreateParams); override;
      procedure Paint; override;
      procedure Resize; override;
      procedure Loaded; override;
      procedure SetEnabled(Value: Boolean); override;
      procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
      procedure ChangeScale(M, D: Integer); override;

    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      procedure CloseUp;
      procedure DropDown;
      function Focused: Boolean; override;

    published
      property EditMask: string read FEditMask write SetEditMask;
      property Date: TDate read FDate write SetDate;
      property DateFormat: string read FDateFormat write SetDateFormat;
      property AutoSizeHeight: Boolean read FAutoSizeHeight write SetAutoSizeHeight default True;

      property CornerRadius: Single read FCornerRadius write SetCornerRadius;
      property AccentColor: TColor read FAccentColor write SetAccentColor default $D47800;
      property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor default clWhite;
      property BackgroundHoverColor: TColor read FBackgroundHoverColor write SetBackgroundHoverColor default $F9F9F9;
      property BorderColor: TColor read FBorderColor write SetBorderColor default $D6D6D6;
      property DisabledColor: TColor read FDisabledColor write SetDisabledColor default $F7F7F7;
      property DisabledBorderColor: TColor read FDisabledBorderColor write SetDisabledBorderColor default $E0E0E0;
      property TextColor: TColor read FTextColor write SetTextColor default $202020;
      property DisabledTextColor: TColor read FDisabledTextColor write SetDisabledTextColor default $A0A0A0;
      property DropdownBackColor: TColor read FDropdownBackColor write SetDropdownBackColor default clWhite;
      property DropdownCornerRadius: Single read FDropdownCornerRadius write SetDropdownCornerRadius;
      property DropdownShadowEnabled: Boolean read FDropdownShadowEnabled write SetDropdownShadowEnabled default True;
      property DropdownShadowSize: Integer read FDropdownShadowSize write SetDropdownShadowSize default 18;
      property TextHint: string read FTextHint write SetTextHint;

      { Calendar cell appearance }
      property TodayBorderColor: TColor read FTodayBorderColor write SetTodayBorderColor default $D47800;
      property SelectedDayColor: TColor read FSelectedDayColor write SetSelectedDayColor default $D47800;
      property SelectedDayBorderColor: TColor read FSelectedDayBorderColor write SetSelectedDayBorderColor default $D47800;
      property SelectedDayTextColor: TColor read FSelectedDayTextColor write SetSelectedDayTextColor default clWhite;
      property HoverColor: TColor read FHoverColor write SetHoverColor default $E8E8E8;
      property HoverTextColor: TColor read FHoverTextColor write SetHoverTextColor default $202020;
      property OtherMonthTextColor: TColor read FOtherMonthTextColor write SetOtherMonthTextColor default $A0A0A0;
      property OtherMonthHoverTextColor: TColor read FOtherMonthHoverTextColor write SetOtherMonthHoverTextColor default $A0A0A0;
      property TodayTextColor: TColor read FTodayTextColor write SetTodayTextColor default $D47800;
      property TodayHoverTextColor: TColor read FTodayHoverTextColor write SetTodayHoverTextColor default $D47800;
      property LinkTextColor: TColor read FLinkTextColor write SetLinkTextColor default $202020;
      property LinkHoverTextColor: TColor read FLinkHoverTextColor write SetLinkHoverTextColor default $D47800;
      property DayShape: TCWSDayShape read FDayShape write SetDayShape default dsRoundRect;

      property Align;
      property Anchors;
      property Constraints;
      property Cursor;
      property Enabled;
      property Font;
      property ParentFont;
      property ParentShowHint;
      property ShowHint;
      property TabOrder;
      property TabStop;
      property Visible;
      property OnChange: TNotifyEvent read FOnChange write FOnChange;
      property OnDropDown: TNotifyEvent read FOnDropDown write FOnDropDown;
      property OnCloseUp: TNotifyEvent read FOnCloseUp write FOnCloseUp;
    end;

  implementation

  type
    TControlAccess = class(TControl);

  const
    ULW_ALPHA = $00000002;
    { Peak shadow opacity (0..255) — like in CWSPopupMenu / CWSComboBox. }
    DROPDOWN_SHADOW_ALPHA = 86;
    { List width = component width, but not less than this value
      (logical px) — below it the calendar layout stops fitting
      (header, 7-column grid, the "Today" bar). }
    DROPDOWN_MIN_WIDTH = 260;
    EVENT_SYSTEM_FOREGROUND_ = $0003;
    WINEVENT_OUTOFCONTEXT_   = $0000;

  { Silhouette (0/255) of a rounded rectangle — used as the shadow base. }
  procedure RasterRoundRectAlpha(P: PByte; W, H, SX, SY, BW, BH, RR: Integer);
  var
    X, Y, DY, Inset, X0, X1, CyTop, CyBot: Integer;
    Row: PByte;
  begin
    if (BW <= 0) or (BH <= 0) then Exit;
    if RR < 0 then RR := 0;
    if RR > BW div 2 then RR := BW div 2;
    if RR > BH div 2 then RR := BH div 2;
    CyTop := SY + RR;
    CyBot := SY + BH - 1 - RR;
    for Y := SY to SY + BH - 1 do
    begin
      if (Y < 0) or (Y >= H) then Continue;
      if Y < CyTop then DY := CyTop - Y
      else if Y > CyBot then DY := Y - CyBot
      else DY := 0;
      if DY = 0 then Inset := 0
      else Inset := RR - Trunc(Sqrt(RR * RR - DY * DY) + 0.5);
      X0 := SX + Inset;
      X1 := SX + BW - 1 - Inset;
      if X0 < 0 then X0 := 0;
      if X1 > W - 1 then X1 := W - 1;
      if X1 < X0 then Continue;
      Row := P; Inc(Row, Y * W + X0);
      for X := X0 to X1 do begin Row^ := 255; Inc(Row); end;
    end;
  end;

  { As above, but each corner can have a different radius (rTL, rTR, rBL, rBR).
    Lets us round only the "free" corners of the list while leaving the corners
    that touch the control straight — so the shadow wraps around the free corner
    and stays flat at the contact. }
  procedure RasterRoundRectAlpha4(P: PByte; W, H, SX, SY, BW, BH,
    rTL, rTR, rBL, rBR: Integer);

    function ClampR(R: Integer): Integer;
    begin
      if R < 0 then R := 0;
      if R > BW div 2 then R := BW div 2;
      if R > BH div 2 then R := BH div 2;
      Result := R;
    end;

    function LeftInset(Y: Integer): Integer;
    var D: Integer;
    begin
      Result := 0;
      if (rTL > 0) and (Y < SY + rTL) then
      begin
        D := (SY + rTL) - Y;
        Result := rTL - Trunc(Sqrt(rTL * rTL - D * D) + 0.5);
      end
      else if (rBL > 0) and (Y > SY + BH - 1 - rBL) then
      begin
        D := Y - (SY + BH - 1 - rBL);
        Result := rBL - Trunc(Sqrt(rBL * rBL - D * D) + 0.5);
      end;
    end;

    function RightInset(Y: Integer): Integer;
    var D: Integer;
    begin
      Result := 0;
      if (rTR > 0) and (Y < SY + rTR) then
      begin
        D := (SY + rTR) - Y;
        Result := rTR - Trunc(Sqrt(rTR * rTR - D * D) + 0.5);
      end
      else if (rBR > 0) and (Y > SY + BH - 1 - rBR) then
      begin
        D := Y - (SY + BH - 1 - rBR);
        Result := rBR - Trunc(Sqrt(rBR * rBR - D * D) + 0.5);
      end;
    end;

  var
    X, Y, X0, X1: Integer;
    Row: PByte;
  begin
    if (BW <= 0) or (BH <= 0) then Exit;
    rTL := ClampR(rTL); rTR := ClampR(rTR);
    rBL := ClampR(rBL); rBR := ClampR(rBR);
    for Y := SY to SY + BH - 1 do
    begin
      if (Y < 0) or (Y >= H) then Continue;
      X0 := SX + LeftInset(Y);
      X1 := SX + BW - 1 - RightInset(Y);
      if X0 < 0 then X0 := 0;
      if X1 > W - 1 then X1 := W - 1;
      if X1 < X0 then Continue;
      Row := P; Inc(Row, Y * W + X0);
      for X := X0 to X1 do begin Row^ := 255; Inc(Row); end;
    end;
  end;

  { Box blur of the alpha channel (separable, Iter passes ≈ Gaussian). }
  procedure BoxBlurAlpha(P: PByte; W, H, R, Iter: Integer);
  var
    Tmp: TBytes;
    Pref: array of Integer;
    It, X, Y, L, R2, Cnt, Base: Integer;
    PB: PByte;
  begin
    if (R < 1) or (W < 1) or (H < 1) then Exit;
    SetLength(Tmp, W * H);
    SetLength(Pref, Max(W, H) + 1);
    for It := 1 to Iter do
    begin
      for Y := 0 to H - 1 do
      begin
        Base := Y * W;
        Pref[0] := 0;
        PB := P; Inc(PB, Base);
        for X := 0 to W - 1 do begin Pref[X + 1] := Pref[X] + PB^; Inc(PB); end;
        for X := 0 to W - 1 do
        begin
          L := X - R; if L < 0 then L := 0;
          R2 := X + R; if R2 > W - 1 then R2 := W - 1;
          Cnt := R2 - L + 1;
          Tmp[Base + X] := (Pref[R2 + 1] - Pref[L]) div Cnt;
        end;
      end;
      for X := 0 to W - 1 do
      begin
        Pref[0] := 0;
        for Y := 0 to H - 1 do Pref[Y + 1] := Pref[Y] + Tmp[Y * W + X];
        for Y := 0 to H - 1 do
        begin
          L := Y - R; if L < 0 then L := 0;
          R2 := Y + R; if R2 > H - 1 then R2 := H - 1;
          Cnt := R2 - L + 1;
          PB := P; Inc(PB, Y * W + X);
          PB^ := (Pref[R2 + 1] - Pref[L]) div Cnt;
        end;
      end;
    end;
  end;

  { Body path with selectively rounded corners — the corner at the junction is straight. }
  function CreateBodyPath(X, Y, W, H, R: Single;
    RoundTop, RoundBottom: Boolean): TGPGraphicsPath;
  var
    D, rTL, rTR, rBR, rBL: Single;
  begin
    Result := TGPGraphicsPath.Create;
    D := R;
    if D * 2 > W then D := W / 2;
    if D * 2 > H then D := H / 2;
    if D < 0 then D := 0;
    if D = 0 then
    begin
      Result.AddRectangle(MakeRect(X, Y, W, H));
      Exit;
    end;
    if RoundTop then begin rTL := D; rTR := D; end else begin rTL := 0; rTR := 0; end;
    if RoundBottom then begin rBR := D; rBL := D; end else begin rBR := 0; rBL := 0; end;
    Result.StartFigure;
    if rTL > 0 then Result.AddArc(X, Y, 2 * rTL, 2 * rTL, 180, 90);
    Result.AddLine(X + rTL, Y, X + W - rTR, Y);
    if rTR > 0 then Result.AddArc(X + W - 2 * rTR, Y, 2 * rTR, 2 * rTR, 270, 90);
    Result.AddLine(X + W, Y + rTR, X + W, Y + H - rBR);
    if rBR > 0 then Result.AddArc(X + W - 2 * rBR, Y + H - 2 * rBR, 2 * rBR, 2 * rBR, 0, 90);
    Result.AddLine(X + W - rBR, Y + H, X + rBL, Y + H);
    if rBL > 0 then Result.AddArc(X, Y + H - 2 * rBL, 2 * rBL, 2 * rBL, 90, 90);
    Result.AddLine(X, Y + H - rBL, X, Y + rTL);
    Result.CloseFigure;
  end;

  { Open border path — omits the edge adjacent to the DatePicker. }
  function CreateBorderPath(X, Y, W, H, R: Single; OmitTop: Boolean): TGPGraphicsPath;
  var
    D: Single;
  begin
    Result := TGPGraphicsPath.Create;
    D := R;
    if D * 2 > W then D := W / 2;
    if D * 2 > H then D := H / 2;
    if D < 0 then D := 0;
    Result.StartFigure;
    if OmitTop then
    begin
      Result.AddLine(X + W, Y, X + W, Y + H - D);
      if D > 0 then Result.AddArc(X + W - 2 * D, Y + H - 2 * D, 2 * D, 2 * D, 0, 90);
      Result.AddLine(X + W - D, Y + H, X + D, Y + H);
      if D > 0 then Result.AddArc(X, Y + H - 2 * D, 2 * D, 2 * D, 90, 90);
      Result.AddLine(X, Y + H - D, X, Y);
    end
    else
    begin
      Result.AddLine(X, Y + H, X, Y + D);
      if D > 0 then Result.AddArc(X, Y, 2 * D, 2 * D, 180, 90);
      Result.AddLine(X + D, Y, X + W - D, Y);
      if D > 0 then Result.AddArc(X + W - 2 * D, Y, 2 * D, 2 * D, 270, 90);
      Result.AddLine(X + W, Y + D, X + W, Y + H);
    end;
  end;

  { Body path with an independent radius for each corner. }
  function CreateBodyPath4(X, Y, W, H, rTL, rTR, rBR, rBL: Single): TGPGraphicsPath;

    function Clamp(R: Single): Single;
    begin
      if R < 0 then R := 0;
      if R * 2 > W then R := W / 2;
      if R * 2 > H then R := H / 2;
      Result := R;
    end;

  begin
    Result := TGPGraphicsPath.Create;
    rTL := Clamp(rTL); rTR := Clamp(rTR); rBR := Clamp(rBR); rBL := Clamp(rBL);
    Result.StartFigure;
    if rTL > 0 then Result.AddArc(X, Y, 2 * rTL, 2 * rTL, 180, 90);
    Result.AddLine(X + rTL, Y, X + W - rTR, Y);
    if rTR > 0 then Result.AddArc(X + W - 2 * rTR, Y, 2 * rTR, 2 * rTR, 270, 90);
    Result.AddLine(X + W, Y + rTR, X + W, Y + H - rBR);
    if rBR > 0 then Result.AddArc(X + W - 2 * rBR, Y + H - 2 * rBR, 2 * rBR, 2 * rBR, 0, 90);
    Result.AddLine(X + W - rBR, Y + H, X + rBL, Y + H);
    if rBL > 0 then Result.AddArc(X, Y + H - 2 * rBL, 2 * rBL, 2 * rBL, 90, 90);
    Result.AddLine(X, Y + H - rBL, X, Y + rTL);
    Result.CloseFigure;
  end;

  { Open border path with independent corner radii and a GAP on the contact edge
    (top when GapTop = True; bottom otherwise). The gap covers only the actual
    contact with the control [GapL..GapR] (in path X coordinates), so the border
    is drawn on the protruding part of the edge while the free corner is rounded. }
  function CreateBorderPathGap(X, Y, W, H, rTL, rTR, rBR, rBL,
    GapL, GapR: Single; GapTop: Boolean): TGPGraphicsPath;
  var
    gs, ge: Single;
  begin
    Result := TGPGraphicsPath.Create;
    Result.StartFigure;
    if GapTop then
    begin
      gs := GapL; if gs < X + rTL then gs := X + rTL;
      ge := GapR; if ge > X + W - rTR then ge := X + W - rTR;
      if ge <= gs then
      begin
        { the whole contact covers the top → skip the entire top edge }
        Result.AddLine(X + W, Y, X + W, Y + H - rBR);
        if rBR > 0 then Result.AddArc(X + W - 2 * rBR, Y + H - 2 * rBR, 2 * rBR, 2 * rBR, 0, 90);
        Result.AddLine(X + W - rBR, Y + H, X + rBL, Y + H);
        if rBL > 0 then Result.AddArc(X, Y + H - 2 * rBL, 2 * rBL, 2 * rBL, 90, 90);
        Result.AddLine(X, Y + H - rBL, X, Y);
        Exit;
      end;
      Result.AddLine(ge, Y, X + W - rTR, Y);
      if rTR > 0 then Result.AddArc(X + W - 2 * rTR, Y, 2 * rTR, 2 * rTR, 270, 90);
      Result.AddLine(X + W, Y + rTR, X + W, Y + H - rBR);
      if rBR > 0 then Result.AddArc(X + W - 2 * rBR, Y + H - 2 * rBR, 2 * rBR, 2 * rBR, 0, 90);
      Result.AddLine(X + W - rBR, Y + H, X + rBL, Y + H);
      if rBL > 0 then Result.AddArc(X, Y + H - 2 * rBL, 2 * rBL, 2 * rBL, 90, 90);
      Result.AddLine(X, Y + H - rBL, X, Y + rTL);
      if rTL > 0 then Result.AddArc(X, Y, 2 * rTL, 2 * rTL, 180, 90);
      Result.AddLine(X + rTL, Y, gs, Y);
    end
    else
    begin
      gs := GapL; if gs < X + rBL then gs := X + rBL;
      ge := GapR; if ge > X + W - rBR then ge := X + W - rBR;
      if ge <= gs then
      begin
        { the whole contact covers the bottom → skip the entire bottom edge }
        Result.AddLine(X, Y + H, X, Y + rTL);
        if rTL > 0 then Result.AddArc(X, Y, 2 * rTL, 2 * rTL, 180, 90);
        Result.AddLine(X + rTL, Y, X + W - rTR, Y);
        if rTR > 0 then Result.AddArc(X + W - 2 * rTR, Y, 2 * rTR, 2 * rTR, 270, 90);
        Result.AddLine(X + W, Y + rTR, X + W, Y + H);
        Exit;
      end;
      Result.AddLine(gs, Y + H, X + rBL, Y + H);
      if rBL > 0 then Result.AddArc(X, Y + H - 2 * rBL, 2 * rBL, 2 * rBL, 90, 90);
      Result.AddLine(X, Y + H - rBL, X, Y + rTL);
      if rTL > 0 then Result.AddArc(X, Y, 2 * rTL, 2 * rTL, 180, 90);
      Result.AddLine(X + rTL, Y, X + W - rTR, Y);
      if rTR > 0 then Result.AddArc(X + W - 2 * rTR, Y, 2 * rTR, 2 * rTR, 270, 90);
      Result.AddLine(X + W, Y + rTR, X + W, Y + H - rBR);
      if rBR > 0 then Result.AddArc(X + W - 2 * rBR, Y + H - 2 * rBR, 2 * rBR, 2 * rBR, 0, 90);
      Result.AddLine(X + W - rBR, Y + H, ge, Y + H);
    end;
  end;

  { TCWSBufferedMaskEdit }

  procedure TCWSBufferedMaskEdit.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
  begin
    Msg.Result := 1;
  end;

  function TCWSBufferedMaskEdit.GetCleanText: string;
  begin
    // The placeholder in our mask is always '_' (third part: ';1;_')
    // Just strip '_' to get the clean text with separators
    Result := StringReplace(Text, '_', '', [rfReplaceAll]);
  end;

    { ════════════════════════════════════════════════════════════════════════════
        Mouse hook
      ════════════════════════════════════════════════════════════════════════════ }

  var
    GMouseHook: HHOOK = 0;
    GFgEventHook: THandle = 0;
    GActiveDropdown: TCWSCalendarDropdown = nil;

  function MouseHookProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
  var
    pMHS: ^TMouseHookStruct;
    RDrop, RCombo: TRect;
  begin
    Result := CallNextHookEx(GMouseHook, nCode, wParam, lParam);
    if (nCode >= HC_ACTION) and (GActiveDropdown <> nil) and GActiveDropdown.HandleAllocated then
    begin
      if (wParam = WM_LBUTTONDOWN) or (wParam = WM_RBUTTONDOWN) or
        (wParam = WM_NCLBUTTONDOWN) or (wParam = WM_NCRBUTTONDOWN) or (wParam = WM_MBUTTONDOWN) then
      begin
        pMHS := Pointer(lParam);
        { The list BODY rect (without the shadow margin) — a click on the shadow also closes. }
        RDrop := GActiveDropdown.FBodyScreen;
        if not PtInRect(RDrop, pMHS^.pt) then
        begin
          if (GActiveDropdown.FDatePicker <> nil) and GActiveDropdown.FDatePicker.HandleAllocated then
          begin
            GetWindowRect(GActiveDropdown.FDatePicker.Handle, RCombo);
            if PtInRect(RCombo, pMHS^.pt) then
              Exit;
          end;
          PostMessage(GActiveDropdown.Handle, WM_CWS_CLOSEDROPDOWN, 0, 0);
        end;
      end;
    end;
  end;

  { App deactivation (Alt+Tab, clicking another app) — close the list.
    The WH_MOUSE hook is thread-local and does not "see" clicks in other apps. }
  procedure DropdownWinEventProc(hHook: THandle; dwEvent: DWORD; hwnd: HWND;
    idObject, idChild: LongInt; idThread, dwmsTime: DWORD); stdcall;
  begin
    if (dwEvent = EVENT_SYSTEM_FOREGROUND_) and (GActiveDropdown <> nil) and
       GActiveDropdown.HandleAllocated then
      PostMessage(GActiveDropdown.Handle, WM_CWS_CLOSEDROPDOWN, 0, 0);
  end;

  procedure InstallHook(ADropdown: TCWSCalendarDropdown);
  begin
    GActiveDropdown := ADropdown;
    if GMouseHook = 0 then
      GMouseHook := SetWindowsHookEx(WH_MOUSE, @MouseHookProc, 0, GetCurrentThreadId);
    if GFgEventHook = 0 then
      GFgEventHook := SetWinEventHook(EVENT_SYSTEM_FOREGROUND_, EVENT_SYSTEM_FOREGROUND_,
        0, @DropdownWinEventProc, 0, 0, WINEVENT_OUTOFCONTEXT_);
  end;

  procedure UninstallHook;
  begin
    GActiveDropdown := nil;
    if GMouseHook <> 0 then
    begin
      UnhookWindowsHookEx(GMouseHook);
      GMouseHook := 0;
    end;
    if GFgEventHook <> 0 then
    begin
      UnhookWinEvent(GFgEventHook);
      GFgEventHook := 0;
    end;
  end;

  { ════════════════════════════════════════════════════════════════════════════
      TCWSCalendarDropdown
    ════════════════════════════════════════════════════════════════════════════ }

  constructor TCWSCalendarDropdown.Create(ADatePicker: TCWSDatePicker);
  begin
    inherited Create(nil);
    FDatePicker := ADatePicker;
    FHoveredDayIdx   := -1;
    FHoveredBtn      := -1;
    FViewMode        := 0;
    FHoveredYearIdx  := -1;
    FHoveredMonthIdx := -1;
    FYearRangeStart  := 0;
    FScale := 1;
    FDpi := 96;
    Visible := False;
    { 24-bit body buffer (opaque) — later composited onto the layered window. }
    FBuffer := TBitmap.Create;
    FBuffer.PixelFormat := pf24bit;
  end;

  destructor TCWSCalendarDropdown.Destroy;
  begin
    if GActiveDropdown = Self then
      UninstallHook;
    FBuffer.Free;
    inherited;
  end;

  procedure TCWSCalendarDropdown.CreateParams(var Params: TCreateParams);
  begin
    inherited CreateParams(Params);
    Params.Style := WS_POPUP;
    Params.ExStyle := WS_EX_TOOLWINDOW or WS_EX_TOPMOST or WS_EX_NOACTIVATE or
      WS_EX_LAYERED;
    Params.WndParent := GetDesktopWindow;
  end;

  procedure TCWSCalendarDropdown.ComputeScale;
  begin
    FDpi := FDatePicker.CurrentPPI;
    if FDpi <= 0 then FDpi := 96;
    FScale := FDpi / 96;
  end;

  function TCWSCalendarDropdown.BodyLeft: Integer;
  begin
    Result := FMarginSide;
  end;

  function TCWSCalendarDropdown.BodyTop: Integer;
  begin
    Result := FMarginTop;
  end;

  procedure TCWSCalendarDropdown.CornerRoundFlags(out aTL, aTR, aBR, aBL: Boolean);
  var
    FreeL, FreeR: Boolean;
  begin
    { Free left corner of the contact edge when the component does not reach the
      left edge of the list; likewise the right. Outside the contact segment the corners are rounded. }
    FreeL := FContactL > 0;
    FreeR := FContactR < FBodyW;
    if FOpenedUp then
    begin
      { contact at the bottom }
      aTL := True; aTR := True;
      aBL := FreeL; aBR := FreeR;
    end
    else
    begin
      { contact at the top }
      aBL := True; aBR := True;
      aTL := FreeL; aTR := FreeR;
    end;
  end;

  function TCWSCalendarDropdown.CornerRadiusPx: Single;
  begin
    Result := FDatePicker.FDropdownCornerRadius * FScale;
  end;

  function TCWSCalendarDropdown.ScalePx(V: Integer): Integer;
  begin
    Result := MulDiv(V, FDatePicker.CurrentPPI, 96);
  end;

  function TCWSCalendarDropdown.MakeGPColor(C: TColor; A: Byte): Cardinal;
  var
    RGB: TColor;
  begin
    RGB := ColorToRGB(C);
    Result := Winapi.GDIPAPI.MakeColor(A, GetRValue(RGB), GetGValue(RGB), GetBValue(RGB));
  end;

  function TCWSCalendarDropdown.CreateRRPath(X, Y, W, H, R: Single): TGPGraphicsPath;
  var
    D: Single;
  begin
    Result := TGPGraphicsPath.Create;
    if R <= 0 then
    begin
      Result.AddRectangle(MakeRect(X, Y, W, H));
      Exit;
    end;
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

  function TCWSCalendarDropdown.GetHeaderRect: TRect;
  begin
    Result := Rect(ScalePx(12), ScalePx(10), FBodyW - ScalePx(12), ScalePx(40));
  end;

  function TCWSCalendarDropdown.GetPrevBtnRect: TRect;
  var
    R: TRect;
  begin
    R := GetHeaderRect;
    Result := Rect(R.Right - ScalePx(64), R.Top, R.Right - ScalePx(34), R.Bottom);
  end;

  function TCWSCalendarDropdown.GetNextBtnRect: TRect;
  var
    R: TRect;
  begin
    R := GetHeaderRect;
    Result := Rect(R.Right - ScalePx(30), R.Top, R.Right, R.Bottom);
  end;

  function TCWSCalendarDropdown.GetDaysHeaderRect: TRect;
  var
    HR: TRect;
  begin
    HR := GetHeaderRect;
    Result := Rect(ScalePx(12), HR.Bottom + ScalePx(4), FBodyW - ScalePx(12), HR.Bottom + ScalePx(34));
  end;

  function TCWSCalendarDropdown.GetGridRect: TRect;
  var
    DHR: TRect;
  begin
    DHR := GetDaysHeaderRect;
    Result := Rect(ScalePx(12), DHR.Bottom, FBodyW - ScalePx(12), FBodyH - ScalePx(32));
  end;

  function TCWSCalendarDropdown.GetTodayBarRect: TRect;
  begin
    Result := Rect(0, FBodyH - ScalePx(28), FBodyW, FBodyH);
  end;

  function TCWSCalendarDropdown.GetDayCellRect(Index: Integer): TRect;
  var
    Col, Row: Integer;
    GR: TRect;
    CellW, CellH: Single;
  begin
    Col := Index mod 7;
    Row := Index div 7;
    GR := GetGridRect;
    CellW := (GR.Right - GR.Left) / 7.0;
    CellH := (GR.Bottom - GR.Top) / 6.0;

    Result.Left := GR.Left + Trunc(Col * CellW);
    Result.Top := GR.Top + Trunc(Row * CellH);
    Result.Right := GR.Left + Trunc((Col + 1) * CellW);
    Result.Bottom := GR.Top + Trunc((Row + 1) * CellH);
  end;

  function TCWSCalendarDropdown.GetDateForCell(Index: Integer): TDate;
  var
    FirstDayOfMonth, StartGridDate: TDate;
    DayOfWeek: Integer;
  begin
    FirstDayOfMonth := EncodeDate(FViewYear, FViewMonth, 1);
    DayOfWeek := DayOfTheWeek(FirstDayOfMonth); // 1 = Monday, 7 = Sunday
    StartGridDate := IncDay(FirstDayOfMonth, -(DayOfWeek - 1));
    Result := IncDay(StartGridDate, Index);
  end;

  // Year grid: 4 columns × 5 rows = 20 years per page
  const
    YEAR_COLS = 4;
    YEAR_ROWS = 5;
    YEAR_COUNT = YEAR_COLS * YEAR_ROWS;

  function TCWSCalendarDropdown.GetYearGridRect: TRect;
  var
    HR: TRect;
  begin
    HR := GetHeaderRect;
    { Bottom must stop above the "Today" bar (FBodyH - 28), otherwise the last
      row of years is drawn overlapping the bar and gets clipped. Match the
      month/day grids which end at FBodyH - 32. }
    Result := Rect(ScalePx(8), HR.Bottom + ScalePx(4),
      FBodyW - ScalePx(8), FBodyH - ScalePx(32));
  end;

  function TCWSCalendarDropdown.GetYearCellRect(Index: Integer): TRect;
  var
    Col, Row: Integer;
    GR: TRect;
    CellW, CellH: Single;
  begin
    Col := Index mod YEAR_COLS;
    Row := Index div YEAR_COLS;
    GR := GetYearGridRect;
    CellW := (GR.Right - GR.Left) / YEAR_COLS;
    CellH := (GR.Bottom - GR.Top) / YEAR_ROWS;
    Result.Left   := GR.Left + Trunc(Col * CellW);
    Result.Top    := GR.Top  + Trunc(Row * CellH);
    Result.Right  := GR.Left + Trunc((Col + 1) * CellW);
    Result.Bottom := GR.Top  + Trunc((Row + 1) * CellH);
  end;

  function TCWSCalendarDropdown.GetYearForCell(Index: Integer): Integer;
  begin
    Result := FYearRangeStart + Index;
  end;

  // Returns the rect of the year displayed in the header (clickable)
  function TCWSCalendarDropdown.GetYearLabelRect: TRect;
  var
    HR, BtnPrev: TRect;
    MidX: Integer;
  begin
    HR      := GetHeaderRect;
    BtnPrev := GetPrevBtnRect;
    MidX    := HR.Left + (BtnPrev.Left - HR.Left - ScalePx(4)) div 2;
    // Year = right half of the label area
    Result := Rect(MidX, HR.Top, BtnPrev.Left - ScalePx(4), HR.Bottom);
  end;

  function TCWSCalendarDropdown.GetMonthLabelRect: TRect;
  var
    HR, BtnPrev: TRect;
    MidX: Integer;
  begin
    HR      := GetHeaderRect;
    BtnPrev := GetPrevBtnRect;
    MidX    := HR.Left + (BtnPrev.Left - HR.Left - ScalePx(4)) div 2;
    // Month = left half of the label area
    Result := Rect(HR.Left, HR.Top, MidX, HR.Bottom);
  end;

  { Header text width (title font: bold, Font.Size + 1)
    in device pixels — for the "only over the text" hit-test. }
  function TCWSCalendarDropdown.MeasureTitleText(const S: string): Integer;
  begin
    FBuffer.Canvas.Font.Name   := FDatePicker.Font.Name;
    FBuffer.Canvas.Font.Height := -Round(Abs(FDatePicker.Font.Size + 1) *
      FDatePicker.CurrentPPI / 72);
    FBuffer.Canvas.Font.Style  := [fsBold];
    Result := FBuffer.Canvas.TextWidth(S);
  end;

  { Hit zone of the month label — narrow, covers only the text (not the whole
    stretched half of the header). }
  function TCWSCalendarDropdown.GetMonthLabelHitRect: TRect;
  var
    R: TRect;
    Fmt: TFormatSettings;
    W: Integer;
  begin
    R   := GetMonthLabelRect;
    Fmt := TFormatSettings.Create;
    W   := MeasureTitleText(Fmt.LongMonthNames[FViewMonth]) + ScalePx(2);
    Result := Rect(R.Left, R.Top, Min(R.Left + W, R.Right), R.Bottom);
  end;

  { Hit zone of the year label — narrow, covers only the text. The left edge
    depends on the view: in the day view the year is in the right half (MidX), in the
    month view — at the left edge of the header. }
  function TCWSCalendarDropdown.GetYearLabelHitRect: TRect;
  var
    HR, BtnPrev: TRect;
    L, W: Integer;
  begin
    HR      := GetHeaderRect;
    BtnPrev := GetPrevBtnRect;
    if FViewMode = 1 then
      L := HR.Left
    else
      L := HR.Left + (BtnPrev.Left - HR.Left - ScalePx(4)) div 2;
    W := MeasureTitleText(IntToStr(FViewYear)) + ScalePx(2);
    Result := Rect(L, HR.Top, Min(L + W, BtnPrev.Left - ScalePx(4)), HR.Bottom);
  end;

  // Month grid: 4 columns × 3 rows
  function TCWSCalendarDropdown.GetMonthGridRect: TRect;
  var
    HR: TRect;
  begin
    HR := GetHeaderRect;
    Result := Rect(ScalePx(8), HR.Bottom + ScalePx(4),
      FBodyW - ScalePx(8), FBodyH - ScalePx(32));
  end;

  function TCWSCalendarDropdown.GetMonthCellRect(Index: Integer): TRect;
  const
    MONTH_COLS = 4;
    MONTH_ROWS = 3;
  var
    Col, Row: Integer;
    GR: TRect;
    CellW, CellH: Single;
  begin
    Col   := Index mod MONTH_COLS;
    Row   := Index div MONTH_COLS;
    GR    := GetMonthGridRect;
    CellW := (GR.Right - GR.Left) / MONTH_COLS;
    CellH := (GR.Bottom - GR.Top) / MONTH_ROWS;
    Result.Left   := GR.Left + Trunc(Col * CellW);
    Result.Top    := GR.Top  + Trunc(Row * CellH);
    Result.Right  := GR.Left + Trunc((Col + 1) * CellW);
    Result.Bottom := GR.Top  + Trunc((Row + 1) * CellH);
  end;

  procedure TCWSCalendarDropdown.EnsureBuffer;
  begin
    if (FBuffer.Width <> FBodyW) or (FBuffer.Height <> FBodyH) then
      FBuffer.SetSize(Max(1, FBodyW), Max(1, FBodyH));
  end;

  procedure TCWSCalendarDropdown.PaintToBuffer;
  var
    G: TGPGraphics;
    FF: TGPFontFamily;
    GPFont: TGPFont;
  begin
    EnsureBuffer;

    FBuffer.Canvas.Brush.Color := FDatePicker.FDropdownBackColor;
    FBuffer.Canvas.FillRect(Rect(0, 0, FBuffer.Width, FBuffer.Height));

    G := TGPGraphics.Create(FBuffer.Canvas.Handle);
    try
      G.SetSmoothingMode(SmoothingModeAntiAlias);
      G.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);

      FF := TGPFontFamily.Create(FDatePicker.Font.Name);
      GPFont := TGPFont.Create(FF, Single(Abs(FDatePicker.Font.Size) * FDatePicker.CurrentPPI / 72.0), FontStyleRegular, UnitPixel);
      try
        case FViewMode of
          1: PaintMonthView;
          2: PaintYearView;
        else
          PaintCalendarView;
        end;
        PaintTodayBar(G, GPFont);
      finally
        GPFont.Free;
        FF.Free;
      end;
    finally G.Free;
    end;
  end;

  procedure TCWSCalendarDropdown.BuildShadow;
  var
    Cov: TBytes;
    N, i, YOff, ShTop, R: Integer;
    rTL, rTR, rBL, rBR: Integer;
    aTL, aTR, aBR, aBL: Boolean;
    cx0, cy0, cx1, cy1, X, Y: Integer;
  begin
    FHasShadow := FDatePicker.FDropdownShadowEnabled and (FShadow > 0) and (FBlur > 0);
    SetLength(FShadowBits, 0);
    if not FHasShadow then Exit;
    N := FWinW * FWinH;
    SetLength(Cov, N);

    R := Round(CornerRadiusPx);
    { Shadow corners consistent with the body: "free" ones rounded, straight within the contact. }
    CornerRoundFlags(aTL, aTR, aBR, aBL);
    if aTL then rTL := R else rTL := 0;
    if aTR then rTR := R else rTR := 0;
    if aBL then rBL := R else rBL := 0;
    if aBR then rBR := R else rBR := 0;

    { Full, soft shadow around the whole body (the margin is now on all
      sides). The shadow falls slightly downward (consistent light direction). }
    YOff  := FShadowOffset;
    ShTop := BodyTop + YOff;
    RasterRoundRectAlpha4(@Cov[0], FWinW, FWinH,
      BodyLeft, ShTop, FBodyW, FBodyH, rTL, rTR, rBL, rBR);
    BoxBlurAlpha(@Cov[0], FWinW, FWinH, Max(1, FBlur div 3), 3);

    { Erase the shadow exactly over the control rect, so it does not darken it.
      This way the shadow softly surrounds the list and its free corners, but does not fall on the field. }
    cx0 := Max(0, FCtrlLocal.Left);
    cy0 := Max(0, FCtrlLocal.Top);
    cx1 := Min(FWinW, FCtrlLocal.Right);
    cy1 := Min(FWinH, FCtrlLocal.Bottom);
    for Y := cy0 to cy1 - 1 do
      for X := cx0 to cx1 - 1 do
        Cov[Y * FWinW + X] := 0;

    SetLength(FShadowBits, N * 4);
    for i := 0 to N - 1 do
      FShadowBits[i * 4 + 3] := Cov[i] * DROPDOWN_SHADOW_ALPHA div 255;
  end;

  procedure TCWSCalendarDropdown.Render;
  var
    BI: TBitmapInfo;
    Bits: Pointer;
    HBmp, OldBmp: HBITMAP;
    MemDC, ScreenDC: HDC;
    GBmp, ShImg, BodyImg: TGPBitmap;
    G: TGPGraphics;
    Tex: TGPTextureBrush;
    Path: TGPGraphicsPath;
    Pen: TGPPen;
    Blend: TBlendFunction;
    PtSrc: TPoint;
    Sz: TSize;
    W, H, R: Single;
    Border: Integer;
    aTL, aTR, aBR, aBL: Boolean;
    bTL, bTR, bBR, bBL: Single;   { body corner radii }
    eTL, eTR, eBR, eBL: Single;   { border corner radii (with inset) }
  begin
    if not HandleAllocated then Exit;
    if (FWinW < 1) or (FWinH < 1) then Exit;

    PaintToBuffer;   { calendar content → FBuffer (24-bit, opaque) }

    FillChar(BI, SizeOf(BI), 0);
    BI.bmiHeader.biSize := SizeOf(TBitmapInfoHeader);
    BI.bmiHeader.biWidth := FWinW;
    BI.bmiHeader.biHeight := -FWinH;
    BI.bmiHeader.biPlanes := 1;
    BI.bmiHeader.biBitCount := 32;
    BI.bmiHeader.biCompression := BI_RGB;

    HBmp := CreateDIBSection(0, BI, DIB_RGB_COLORS, Bits, 0, 0);
    if HBmp = 0 then Exit;
    MemDC := CreateCompatibleDC(0);
    OldBmp := SelectObject(MemDC, HBmp);
    try
      GBmp := TGPBitmap.Create(FWinW, FWinH, FWinW * 4, PixelFormat32bppPARGB, Bits);
      G := TGPGraphics.Create(GBmp);
      try
        G.SetSmoothingMode(SmoothingModeAntiAlias);
        G.SetPixelOffsetMode(PixelOffsetModeHighQuality);
        G.Clear(MakeColor(0, 0, 0, 0));

        W := FBodyW; H := FBodyH; R := CornerRadiusPx;
        Border := Max(1, Round(FScale));

        { shadow }
        if FHasShadow and (Length(FShadowBits) = FWinW * FWinH * 4) then
        begin
          ShImg := TGPBitmap.Create(FWinW, FWinH, FWinW * 4,
            PixelFormat32bppPARGB, @FShadowBits[0]);
          try G.DrawImage(ShImg, 0, 0, FWinW, FWinH); finally ShImg.Free; end;
        end;

        { corner radii: free list corners rounded, corners within the contact
          with the component straight — consistently for body, border and shadow }
        CornerRoundFlags(aTL, aTR, aBR, aBL);
        if aTL then bTL := R else bTL := 0;
        if aTR then bTR := R else bTR := 0;
        if aBR then bBR := R else bBR := 0;
        if aBL then bBL := R else bBL := 0;

        { body — the calendar (FBuffer) poured into the shape with the right corners }
        BodyImg := TGPBitmap.Create(FBuffer.Handle, 0);
        try
          Tex := TGPTextureBrush.Create(BodyImg, WrapModeTile);
          try
            Tex.TranslateTransform(BodyLeft, BodyTop);
            Path := CreateBodyPath4(BodyLeft, BodyTop, W, H, bTL, bTR, bBR, bBL);
            try G.FillPath(Tex, Path); finally Path.Free; end;
          finally Tex.Free; end;
        finally BodyImg.Free; end;

        { Border with a GAP on the contact edge — no double line at the junction
          (the list merges with the DatePicker into one whole); the border remains
          on the part of the edge protruding past the component. }
        if Border > 0 then
        begin
          if aTL then eTL := R - Border / 2 else eTL := 0;
          if aTR then eTR := R - Border / 2 else eTR := 0;
          if aBR then eBR := R - Border / 2 else eBR := 0;
          if aBL then eBL := R - Border / 2 else eBL := 0;
          Path := CreateBorderPathGap(
            BodyLeft + Border / 2, BodyTop + Border / 2, W - Border, H - Border,
            eTL, eTR, eBR, eBL,
            BodyLeft + FContactL, BodyLeft + FContactR, not FOpenedUp);
          Pen := TGPPen.Create(MakeGPColor(FDatePicker.FBorderColor), Border);
          try G.DrawPath(Pen, Path); finally Pen.Free; Path.Free; end;
        end;

        { The list overlaps the DatePicker by 1 px, so the field edge under the list
          is covered. On the actual contact segment [FContactL..FContactR] we restore
          it, so there is no "step":
            • list down → the accent "carries over" from the field onto the top of the list (orange),
            • list up   → the accent stays at the bottom of the field; at the contact (bottom of the list)
              we draw a GRAY border line — as in CWSComboBox. }
        if (FContactR > FContactL) and FDatePicker.Enabled then
        begin
          G.SetSmoothingMode(SmoothingModeNone);
          if FOpenedUp then
          begin
            var LineH: Single := Border;
            var BrdBrush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FBorderColor));
            try
              G.FillRectangle(BrdBrush, MakeRect(Single(BodyLeft + FContactL),
                BodyTop + H - LineH, Single(FContactR - FContactL), LineH));
            finally BrdBrush.Free; end;
          end
          else
          begin
            var AccentH: Single := Max(1, Round(2 * FScale));
            var AccBrush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FAccentColor));
            try
              G.FillRectangle(AccBrush, MakeRect(Single(BodyLeft + FContactL),
                Single(BodyTop), Single(FContactR - FContactL), AccentH));
            finally AccBrush.Free; end;
          end;
          G.SetSmoothingMode(SmoothingModeAntiAlias);
        end;

        G.Flush(FlushIntentionSync);
      finally
        G.Free; GBmp.Free;
      end;

      ScreenDC := GetDC(0);
      try
        Blend.BlendOp := AC_SRC_OVER;
        Blend.BlendFlags := 0;
        Blend.SourceConstantAlpha := 255;
        Blend.AlphaFormat := AC_SRC_ALPHA;
        Sz.cx := FWinW; Sz.cy := FWinH;
        PtSrc := Point(0, 0);
        UpdateLayeredWindow(Handle, ScreenDC, nil, @Sz, MemDC, @PtSrc, 0, @Blend, ULW_ALPHA);
      finally
        ReleaseDC(0, ScreenDC);
      end;
    finally
      SelectObject(MemDC, OldBmp);
      DeleteDC(MemDC);
      DeleteObject(HBmp);
    end;
  end;

  procedure TCWSCalendarDropdown.PaintCalendarView;
  var
    G: TGPGraphics;
    Path: TGPGraphicsPath;
    Brush: TGPSolidBrush;
    Pen: TGPPen;
    FF: TGPFontFamily;
    GPFontTitle, GPFontDays: TGPFont;
    FmtCenter, FmtLeft: TGPStringFormat;
    HR, DHR, CellR: TRect;
    i, SysDayIdx: Integer;
    CellDate: TDate;
    IsToday, IsSelected, IsCurrentMonth: Boolean;
    DayStr, MonthStr, YearStr: string;
    RRect: TGPRectF;
    BtnPrev, BtnNext, MonthR, YearR: TRect;
    FmtSettings: TFormatSettings;
    ArrowColor, MonthColor, YearColor: TColor;
  begin
    FmtSettings := TFormatSettings.Create;

    G := TGPGraphics.Create(FBuffer.Canvas.Handle);
    try
      G.SetSmoothingMode(SmoothingModeAntiAlias);
      G.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);

      FF       := TGPFontFamily.Create(FDatePicker.Font.Name);
      GPFontTitle := TGPFont.Create(FF, Single(Abs(FDatePicker.Font.Size + 1) * FDatePicker.CurrentPPI / 72.0), FontStyleBold, UnitPixel);
      GPFontDays  := TGPFont.Create(FF, Single(Abs(FDatePicker.Font.Size) * FDatePicker.CurrentPPI / 72.0), FontStyleRegular, UnitPixel);

      FmtCenter := TGPStringFormat.Create;
      FmtCenter.SetLineAlignment(StringAlignmentCenter);
      FmtCenter.SetAlignment(StringAlignmentCenter);

      FmtLeft := TGPStringFormat.Create;
      FmtLeft.SetLineAlignment(StringAlignmentCenter);
      FmtLeft.SetAlignment(StringAlignmentNear);

      try
        HR      := GetHeaderRect;
        BtnPrev := GetPrevBtnRect;
        BtnNext := GetNextBtnRect;
        MonthR  := GetMonthLabelRect;
        YearR   := GetYearLabelRect;

        MonthStr := FmtSettings.LongMonthNames[FViewMonth];
        YearStr  := IntToStr(FViewYear);

        // Hover colors — change text color, no background
        if FHoveredBtn = 3 then
          MonthColor := FDatePicker.FLinkHoverTextColor
        else
          MonthColor := FDatePicker.FLinkTextColor;

        if FHoveredBtn = 2 then
          YearColor := FDatePicker.FLinkHoverTextColor
        else
          YearColor := FDatePicker.FLinkTextColor;

        // Prev arrow
        if FHoveredBtn = 0 then
          ArrowColor := FDatePicker.FLinkHoverTextColor
        else
          ArrowColor := FDatePicker.FTextColor;
        Pen := TGPPen.Create(MakeGPColor(ArrowColor), ScalePx(2));
        Pen.SetLineCap(LineCapRound, LineCapRound, DashCapRound);
        G.DrawLine(Pen, MakePoint(Single(BtnPrev.Left + ScalePx(10)), Single(BtnPrev.Bottom - ScalePx(12))),
          MakePoint(Single(BtnPrev.Left + ScalePx(15)), Single(BtnPrev.Top + ScalePx(12))));
        G.DrawLine(Pen, MakePoint(Single(BtnPrev.Left + ScalePx(15)), Single(BtnPrev.Top + ScalePx(12))),
          MakePoint(Single(BtnPrev.Left + ScalePx(20)), Single(BtnPrev.Bottom - ScalePx(12))));
        Pen.Free;

        // Next arrow
        if FHoveredBtn = 1 then
          ArrowColor := FDatePicker.FLinkHoverTextColor
        else
          ArrowColor := FDatePicker.FTextColor;
        Pen := TGPPen.Create(MakeGPColor(ArrowColor), ScalePx(2));
        Pen.SetLineCap(LineCapRound, LineCapRound, DashCapRound);
        G.DrawLine(Pen, MakePoint(Single(BtnNext.Left + ScalePx(10)), Single(BtnNext.Top + ScalePx(12))),
          MakePoint(Single(BtnNext.Left + ScalePx(15)), Single(BtnNext.Bottom - ScalePx(12))));
        G.DrawLine(Pen, MakePoint(Single(BtnNext.Left + ScalePx(15)), Single(BtnNext.Bottom - ScalePx(12))),
          MakePoint(Single(BtnNext.Left + ScalePx(20)), Single(BtnNext.Top + ScalePx(12))));
        Pen.Free;

        // Month label
        Brush := TGPSolidBrush.Create(MakeGPColor(MonthColor));
        try
          G.DrawString(MonthStr, -1, GPFontTitle,
            MakeRect(Single(MonthR.Left), Single(MonthR.Top),
              Single(MonthR.Right - MonthR.Left), Single(MonthR.Bottom - MonthR.Top)),
            FmtLeft, Brush);
        finally Brush.Free;
        end;

        // Year label
        Brush := TGPSolidBrush.Create(MakeGPColor(YearColor));
        try
          G.DrawString(YearStr, -1, GPFontTitle,
            MakeRect(Single(YearR.Left), Single(YearR.Top),
              Single(YearR.Right - YearR.Left), Single(YearR.Bottom - YearR.Top)),
            FmtLeft, Brush);
        finally Brush.Free;
        end;

        // --- WEEKDAYS ---
        DHR := GetDaysHeaderRect;
        Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FTextColor));
        try
          for i := 0 to 6 do
          begin
            CellR.Left   := DHR.Left + Trunc(i * (DHR.Right - DHR.Left) / 7.0);
            CellR.Top    := DHR.Top;
            CellR.Right  := DHR.Left + Trunc((i + 1) * (DHR.Right - DHR.Left) / 7.0);
            CellR.Bottom := DHR.Bottom;
            SysDayIdx := (i + 1) mod 7 + 1;
            DayStr := Copy(FmtSettings.ShortDayNames[SysDayIdx], 1, 2);
            if Length(DayStr) > 0 then DayStr[1] := UpCase(DayStr[1]);
            G.DrawString(DayStr, -1, GPFontDays,
              MakeRect(Single(CellR.Left), Single(CellR.Top), Single(CellR.Right - CellR.Left), Single(CellR.Bottom - CellR.Top)),
              FmtCenter, Brush);
          end;
        finally Brush.Free;
        end;

        // --- DAYS GRID ---
        for i := 0 to 41 do
        begin
          CellDate := GetDateForCell(i);
          CellR := GetDayCellRect(i);
          InflateRect(CellR, -ScalePx(2), -ScalePx(2));

          IsToday := DateToStr(CellDate) = DateToStr(Date);
          IsSelected := (FDatePicker.Date <> 0) and (DateToStr(CellDate) = DateToStr(FDatePicker.Date));
          IsCurrentMonth := MonthOf(CellDate) = FViewMonth;

          RRect := MakeRect(Single(CellR.Left), Single(CellR.Top),
            Single(CellR.Right - CellR.Left), Single(CellR.Bottom - CellR.Top));

          case FDatePicker.FDayShape of
            dsCircle:
            begin
              var Sz: Single := Min(RRect.Width, RRect.Height);
              var CX: Single := RRect.X + RRect.Width / 2;
              var CY: Single := RRect.Y + RRect.Height / 2;
              Path := TGPGraphicsPath.Create;
              Path.AddEllipse(CX - Sz / 2, CY - Sz / 2, Sz, Sz);
            end;
            dsRectangle:
            begin
              Path := TGPGraphicsPath.Create;
              Path.AddRectangle(MakeRect(RRect.X, RRect.Y, RRect.Width, RRect.Height));
            end;
          else
            Path := CreateRRPath(RRect.X, RRect.Y, RRect.Width, RRect.Height, FDatePicker.ScaleF(FDatePicker.FCornerRadius));
          end;

          try
            if IsSelected then
              Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FSelectedDayColor))
            else if i = FHoveredDayIdx then
              Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FHoverColor))
            else
              Brush := nil;

            if Brush <> nil then begin G.FillPath(Brush, Path); Brush.Free; end;

            { Today ring has priority so TodayBorderColor stays visible even when
              today is also the selected day (drawn on top of the selected fill). }
            if IsToday then
            begin
              Pen := TGPPen.Create(MakeGPColor(FDatePicker.FTodayBorderColor), ScalePx(1));
              try G.DrawPath(Pen, Path); finally Pen.Free; end;
            end
            else if IsSelected then
            begin
              Pen := TGPPen.Create(MakeGPColor(FDatePicker.FSelectedDayBorderColor), ScalePx(1));
              try G.DrawPath(Pen, Path); finally Pen.Free; end;
            end;
          finally Path.Free;
          end;

          if IsSelected then
            Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FSelectedDayTextColor))
          else if not IsCurrentMonth then
          begin
            if i = FHoveredDayIdx then
              Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FOtherMonthHoverTextColor))
            else
              Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FOtherMonthTextColor));
          end
          else if IsToday then
          begin
            if i = FHoveredDayIdx then
              Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FTodayHoverTextColor))
            else
              Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FTodayTextColor));
          end
          else if i = FHoveredDayIdx then
            Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FHoverTextColor))
          else
            Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FTextColor));

          try
            G.DrawString(IntToStr(DayOf(CellDate)), -1, GPFontDays, RRect, FmtCenter, Brush);
          finally Brush.Free;
          end;
        end;

      finally
        GPFontTitle.Free;
        GPFontDays.Free;
        FF.Free;
        FmtCenter.Free;
        FmtLeft.Free;
      end;
    finally G.Free;
    end;
  end;

  procedure TCWSCalendarDropdown.PaintMonthView;
  const
    MONTH_COLS = 4;
    MONTH_ROWS = 3;
  var
    G: TGPGraphics;
    Path: TGPGraphicsPath;
    Brush: TGPSolidBrush;
    Pen: TGPPen;
    FF: TGPFontFamily;
    GPFontTitle, GPFontMonth: TGPFont;
    FmtCenter, FmtLeft: TGPStringFormat;
    HR, CellR, BtnPrev, BtnNext: TRect;
    i: Integer;
    IsCurrentMonth, IsSelectedMonth: Boolean;
    RRect: TGPRectF;
    FmtSettings: TFormatSettings;
    ArrowColor, YearColor: TColor;
    MonthStr: string;
  begin
    FmtSettings := TFormatSettings.Create;

    G := TGPGraphics.Create(FBuffer.Canvas.Handle);
    try
      G.SetSmoothingMode(SmoothingModeAntiAlias);
      G.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);

      FF          := TGPFontFamily.Create(FDatePicker.Font.Name);
      GPFontTitle := TGPFont.Create(FF, Single(Abs(FDatePicker.Font.Size + 1) * FDatePicker.CurrentPPI / 72.0), FontStyleBold, UnitPixel);
      GPFontMonth := TGPFont.Create(FF, Single(Abs(FDatePicker.Font.Size) * FDatePicker.CurrentPPI / 72.0), FontStyleRegular, UnitPixel);

      FmtCenter := TGPStringFormat.Create;
      FmtCenter.SetLineAlignment(StringAlignmentCenter);
      FmtCenter.SetAlignment(StringAlignmentCenter);

      FmtLeft := TGPStringFormat.Create;
      FmtLeft.SetLineAlignment(StringAlignmentCenter);
      FmtLeft.SetAlignment(StringAlignmentNear);

      try
        HR      := GetHeaderRect;
        BtnPrev := GetPrevBtnRect;
        BtnNext := GetNextBtnRect;

        // Year clickable in the header (switches to years view), hover = 2
        if FHoveredBtn = 2 then
          YearColor := FDatePicker.FLinkHoverTextColor
        else
          YearColor := FDatePicker.FLinkTextColor;

        Brush := TGPSolidBrush.Create(MakeGPColor(YearColor));
        try
          G.DrawString(IntToStr(FViewYear), -1, GPFontTitle,
            MakeRect(Single(HR.Left), Single(HR.Top), Single(BtnPrev.Left - HR.Left - ScalePx(4)), Single(HR.Bottom - HR.Top)),
            FmtLeft, Brush);
        finally Brush.Free;
        end;

        // Year navigation arrows
        if FHoveredBtn = 0 then ArrowColor := FDatePicker.FLinkHoverTextColor else ArrowColor := FDatePicker.FTextColor;
        Pen := TGPPen.Create(MakeGPColor(ArrowColor), ScalePx(2));
        Pen.SetLineCap(LineCapRound, LineCapRound, DashCapRound);
        G.DrawLine(Pen, MakePoint(Single(BtnPrev.Left + ScalePx(10)), Single(BtnPrev.Bottom - ScalePx(12))),
          MakePoint(Single(BtnPrev.Left + ScalePx(15)), Single(BtnPrev.Top + ScalePx(12))));
        G.DrawLine(Pen, MakePoint(Single(BtnPrev.Left + ScalePx(15)), Single(BtnPrev.Top + ScalePx(12))),
          MakePoint(Single(BtnPrev.Left + ScalePx(20)), Single(BtnPrev.Bottom - ScalePx(12))));
        Pen.Free;

        if FHoveredBtn = 1 then ArrowColor := FDatePicker.FLinkHoverTextColor else ArrowColor := FDatePicker.FTextColor;
        Pen := TGPPen.Create(MakeGPColor(ArrowColor), ScalePx(2));
        Pen.SetLineCap(LineCapRound, LineCapRound, DashCapRound);
        G.DrawLine(Pen, MakePoint(Single(BtnNext.Left + ScalePx(10)), Single(BtnNext.Top + ScalePx(12))),
          MakePoint(Single(BtnNext.Left + ScalePx(15)), Single(BtnNext.Bottom - ScalePx(12))));
        G.DrawLine(Pen, MakePoint(Single(BtnNext.Left + ScalePx(15)), Single(BtnNext.Bottom - ScalePx(12))),
          MakePoint(Single(BtnNext.Left + ScalePx(20)), Single(BtnNext.Top + ScalePx(12))));
        Pen.Free;

        // --- MONTHS GRID ---
        for i := 0 to 11 do
        begin
          CellR := GetMonthCellRect(i);
          InflateRect(CellR, -ScalePx(3), -ScalePx(3));

          IsCurrentMonth  := (i + 1 = MonthOf(Now)) and (FViewYear = YearOf(Now));
          IsSelectedMonth := (FDatePicker.Date <> 0) and
                             (i + 1 = MonthOf(FDatePicker.Date)) and
                             (FViewYear = YearOf(FDatePicker.Date));

          RRect := MakeRect(Single(CellR.Left), Single(CellR.Top),
            Single(CellR.Right - CellR.Left), Single(CellR.Bottom - CellR.Top));

          Path := CreateRRPath(RRect.X, RRect.Y, RRect.Width, RRect.Height, FDatePicker.ScaleF(FDatePicker.FCornerRadius));
          try
            if IsSelectedMonth then
              Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FSelectedDayColor))
            else if i = FHoveredMonthIdx then
              Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FHoverColor))
            else
              Brush := nil;

            if Brush <> nil then begin G.FillPath(Brush, Path); Brush.Free; end;

            { Current-month ring has priority so TodayBorderColor stays visible
              even when the current month is also the selected one. }
            if IsCurrentMonth then
            begin
              Pen := TGPPen.Create(MakeGPColor(FDatePicker.FTodayBorderColor), ScalePx(1));
              try G.DrawPath(Pen, Path); finally Pen.Free; end;
            end
            else if IsSelectedMonth then
            begin
              Pen := TGPPen.Create(MakeGPColor(FDatePicker.FSelectedDayBorderColor), ScalePx(1));
              try G.DrawPath(Pen, Path); finally Pen.Free; end;
            end;
          finally Path.Free;
          end;

          MonthStr := Copy(FmtSettings.LongMonthNames[i + 1], 1, 3);
          if Length(MonthStr) > 0 then MonthStr[1] := UpCase(MonthStr[1]);

          if IsSelectedMonth then
            Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FSelectedDayTextColor))
          else if IsCurrentMonth then
          begin
            if i = FHoveredMonthIdx then
              Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FTodayHoverTextColor))
            else
              Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FTodayTextColor));
          end
          else if i = FHoveredMonthIdx then
            Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FHoverTextColor))
          else
            Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FTextColor));

          try
            G.DrawString(MonthStr, -1, GPFontMonth, RRect, FmtCenter, Brush);
          finally Brush.Free;
          end;
        end;

      finally
        GPFontTitle.Free;
        GPFontMonth.Free;
        FF.Free;
        FmtCenter.Free;
        FmtLeft.Free;
      end;
    finally G.Free;
    end;
  end;

  procedure TCWSCalendarDropdown.PaintTodayBar(G: TGPGraphics; GPFont: TGPFont);
  var
    TR: TRect;
    Pen: TGPPen;
    Brush: TGPSolidBrush;
    FmtCenter: TGPStringFormat;
    TodayStr: string;
    SquarePath: TGPGraphicsPath;
    TextColor: TColor;
    SqSz, SqY, Gap: Single;
    GroupW, GroupX, SqX: Single;
    BarH, BarCY: Single;
  begin
    TR := GetTodayBarRect;
    BarH  := TR.Bottom - TR.Top;
    BarCY := TR.Top + BarH / 2;

    // Separator
    Pen := TGPPen.Create(MakeGPColor(FDatePicker.FBorderColor), 1.0);
    try
      G.SetSmoothingMode(SmoothingModeNone);
      G.DrawLine(Pen, MakePoint(Single(TR.Left), Single(TR.Top)),
        MakePoint(Single(TR.Right), Single(TR.Top)));
      G.SetSmoothingMode(SmoothingModeAntiAlias);
    finally Pen.Free;
    end;

    TodayStr := 'Today: ' + FormatDateTime(FDatePicker.FDateFormat, Now);
    SqSz := ScalePx(10);
    Gap  := ScalePx(6);

    // Measure text width via Canvas — no MeasureString needed
    FBuffer.Canvas.Font.Assign(FDatePicker.Font);
    var TextW: Single := FBuffer.Canvas.TextWidth(TodayStr);
    GroupW := SqSz + Gap + TextW;
    GroupX := TR.Left + (TR.Right - TR.Left - GroupW) / 2;
    SqX    := GroupX;
    SqY    := BarCY - SqSz / 2;

    // Color square
    SquarePath := CreateRRPath(SqX, SqY, SqSz, SqSz, ScalePx(2));
    try
      Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FTodayBorderColor));
      try G.FillPath(Brush, SquarePath); finally Brush.Free; end;
    finally SquarePath.Free;
    end;

    // Text
    if FHoveredBtn = 4 then
      TextColor := FDatePicker.FLinkHoverTextColor
    else
      TextColor := FDatePicker.FLinkTextColor;

    FmtCenter := TGPStringFormat.Create;
    FmtCenter.SetLineAlignment(StringAlignmentCenter);
    FmtCenter.SetAlignment(StringAlignmentNear);
    FmtCenter.SetFormatFlags(StringFormatFlagsNoWrap);
    try
      Brush := TGPSolidBrush.Create(MakeGPColor(TextColor));
      try
        G.DrawString(TodayStr, -1, GPFont,
          MakeRect(SqX + SqSz + Gap, Single(TR.Top),
            Single(TR.Right) - (SqX + SqSz + Gap), BarH),
          FmtCenter, Brush);
      finally Brush.Free;
      end;
    finally FmtCenter.Free;
    end;
  end;

  procedure TCWSCalendarDropdown.PaintYearView;
  var
    G: TGPGraphics;
    Path: TGPGraphicsPath;
    Brush: TGPSolidBrush;
    Pen: TGPPen;
    FF: TGPFontFamily;
    GPFontTitle, GPFontYear: TGPFont;
    FmtCenter, FmtLeft: TGPStringFormat;
    HR, CellR: TRect;
    i, Yr, CurYear, SelYear: Integer;
    IsCurrentYear, IsSelectedYear: Boolean;
    RRect: TGPRectF;
    BtnPrev, BtnNext: TRect;
    HeaderStr: string;
  begin
    CurYear := YearOf(Now);
    SelYear := YearOf(FDatePicker.Date);

    G := TGPGraphics.Create(FBuffer.Canvas.Handle);
    try
      G.SetSmoothingMode(SmoothingModeAntiAlias);
      G.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);

      FF := TGPFontFamily.Create(FDatePicker.Font.Name);
      GPFontTitle := TGPFont.Create(FF, Single(Abs(FDatePicker.Font.Size + 1) * FDatePicker.CurrentPPI / 72.0), FontStyleBold, UnitPixel);
      GPFontYear  := TGPFont.Create(FF, Single(Abs(FDatePicker.Font.Size) * FDatePicker.CurrentPPI / 72.0), FontStyleRegular, UnitPixel);

      FmtCenter := TGPStringFormat.Create;
      FmtCenter.SetLineAlignment(StringAlignmentCenter);
      FmtCenter.SetAlignment(StringAlignmentCenter);

      FmtLeft := TGPStringFormat.Create;
      FmtLeft.SetLineAlignment(StringAlignmentCenter);
      FmtLeft.SetAlignment(StringAlignmentNear);

      try
        // --- HEADER: year range ---
        HR := GetHeaderRect;
        HeaderStr := IntToStr(FYearRangeStart) + ' – ' + IntToStr(FYearRangeStart + YEAR_COUNT - 1);

        Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FTextColor));
        try
          G.DrawString(HeaderStr, -1, GPFontTitle,
            MakeRect(Single(HR.Left), Single(HR.Top), Single(HR.Right - HR.Left), Single(HR.Bottom - HR.Top)),
            FmtLeft, Brush);
        finally Brush.Free;
        end;

        // --- Decade navigation buttons ---
        BtnPrev := GetPrevBtnRect;
        BtnNext := GetNextBtnRect;

        var ArrColor: TColor;
        if FHoveredBtn = 0 then ArrColor := FDatePicker.FLinkHoverTextColor else ArrColor := FDatePicker.FTextColor;
        Pen := TGPPen.Create(MakeGPColor(ArrColor), ScalePx(2));
        Pen.SetLineCap(LineCapRound, LineCapRound, DashCapRound);
        G.DrawLine(Pen, MakePoint(Single(BtnPrev.Left + ScalePx(10)), Single(BtnPrev.Bottom - ScalePx(12))),
          MakePoint(Single(BtnPrev.Left + ScalePx(15)), Single(BtnPrev.Top + ScalePx(12))));
        G.DrawLine(Pen, MakePoint(Single(BtnPrev.Left + ScalePx(15)), Single(BtnPrev.Top + ScalePx(12))),
          MakePoint(Single(BtnPrev.Left + ScalePx(20)), Single(BtnPrev.Bottom - ScalePx(12))));
        Pen.Free;

        if FHoveredBtn = 1 then ArrColor := FDatePicker.FLinkHoverTextColor else ArrColor := FDatePicker.FTextColor;
        Pen := TGPPen.Create(MakeGPColor(ArrColor), ScalePx(2));
        Pen.SetLineCap(LineCapRound, LineCapRound, DashCapRound);
        G.DrawLine(Pen, MakePoint(Single(BtnNext.Left + ScalePx(10)), Single(BtnNext.Top + ScalePx(12))),
          MakePoint(Single(BtnNext.Left + ScalePx(15)), Single(BtnNext.Bottom - ScalePx(12))));
        G.DrawLine(Pen, MakePoint(Single(BtnNext.Left + ScalePx(15)), Single(BtnNext.Bottom - ScalePx(12))),
          MakePoint(Single(BtnNext.Left + ScalePx(20)), Single(BtnNext.Top + ScalePx(12))));
        Pen.Free;

        // --- YEAR GRID ---
        for i := 0 to YEAR_COUNT - 1 do
        begin
          Yr := GetYearForCell(i);
          CellR := GetYearCellRect(i);
          InflateRect(CellR, -ScalePx(3), -ScalePx(3));

          IsCurrentYear  := Yr = CurYear;
          IsSelectedYear := (FDatePicker.Date <> 0) and (Yr = SelYear);

          RRect := MakeRect(Single(CellR.Left), Single(CellR.Top),
            Single(CellR.Right - CellR.Left), Single(CellR.Bottom - CellR.Top));

          Path := CreateRRPath(RRect.X, RRect.Y, RRect.Width, RRect.Height, FDatePicker.ScaleF(FDatePicker.FCornerRadius));
          try
            if IsSelectedYear then
              Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FSelectedDayColor))
            else if i = FHoveredYearIdx then
              Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FHoverColor))
            else
              Brush := nil;

            if Brush <> nil then begin G.FillPath(Brush, Path); Brush.Free; end;

            { Current-year ring has priority so TodayBorderColor stays visible
              even when the current year is also the selected one. }
            if IsCurrentYear then
            begin
              Pen := TGPPen.Create(MakeGPColor(FDatePicker.FTodayBorderColor), ScalePx(1));
              try G.DrawPath(Pen, Path); finally Pen.Free; end;
            end
            else if IsSelectedYear then
            begin
              Pen := TGPPen.Create(MakeGPColor(FDatePicker.FSelectedDayBorderColor), ScalePx(1));
              try G.DrawPath(Pen, Path); finally Pen.Free; end;
            end;
          finally Path.Free;
          end;

          if IsSelectedYear then
            Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FSelectedDayTextColor))
          else if IsCurrentYear then
          begin
            if i = FHoveredYearIdx then
              Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FTodayHoverTextColor))
            else
              Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FTodayTextColor));
          end
          else if i = FHoveredYearIdx then
            Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FHoverTextColor))
          else
            Brush := TGPSolidBrush.Create(MakeGPColor(FDatePicker.FTextColor));

          try
            G.DrawString(IntToStr(Yr), -1, GPFontYear, RRect, FmtCenter, Brush);
          finally Brush.Free;
          end;
        end;

      finally
        GPFontTitle.Free;
        GPFontYear.Free;
        FF.Free;
        FmtCenter.Free;
        FmtLeft.Free;
      end;
    finally G.Free;
    end;
  end;

  procedure TCWSCalendarDropdown.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
  begin
    Msg.Result := 1;
  end;

  procedure TCWSCalendarDropdown.WMNCHitTest(var Msg: TWMNCHitTest);
  var
    P: TPoint;
  begin
    { The window is larger than the list (shadow margin + overlay above the field).
      Clicks over the field itself are passed "underneath" (the field stays clickable);
      clicks in the shadow/margin area hit the list window, so the existing hook
      closes the list. The list interior is handled normally. }
    P := Point(Msg.XPos, Msg.YPos);
    if PtInRect(FBodyScreen, P) then
      Msg.Result := HTCLIENT
    else if PtInRect(FCtrlScreen, P) then
      Msg.Result := HTTRANSPARENT
    else
      Msg.Result := HTCLIENT;
  end;

  procedure TCWSCalendarDropdown.Invalidate;
  begin
    { The layered window (UpdateLayeredWindow) does not refresh via a normal WM_PAINT,
      so every Invalidate is redrawn immediately (view change, hover, navigation). }
    Render;
  end;

  procedure TCWSCalendarDropdown.WMPaint(var Msg: TWMPaint);
  var
    PS: TPaintStruct;
  begin
    BeginPaint(Handle, PS);
    Render;
    EndPaint(Handle, PS);
    Msg.Result := 0;
  end;

  procedure TCWSCalendarDropdown.WMMouseWheel(var Msg: TWMMouseWheel);
  begin
    case FViewMode of
      2: // Years
      begin
        if Msg.WheelDelta > 0 then Dec(FYearRangeStart, YEAR_COUNT)
        else Inc(FYearRangeStart, YEAR_COUNT);
        Invalidate;
      end;
      1: // Months
      begin
        if Msg.WheelDelta > 0 then Dec(FViewYear) else Inc(FViewYear);
        Invalidate;
      end;
    else // Days
      if Msg.WheelDelta > 0 then ChangeMonth(-1) else ChangeMonth(1);
    end;
    Msg.Result := 1;
  end;

  procedure TCWSCalendarDropdown.WMLButtonDown(var Msg: TWMLButtonDown);
  var
    Pt: TPoint;
    i, Yr: Integer;
  begin
    Pt := Point(Msg.XPos - BodyLeft, Msg.YPos - BodyTop);

    // Click on the "Today" bar — in all views
    if PtInRect(GetTodayBarRect, Pt) then
    begin
      FDatePicker.Date := Trunc(Now);
      FDatePicker.CloseDropdown;
      Exit;
    end;

    case FViewMode of
      2: // Years view
      begin
        if PtInRect(GetPrevBtnRect, Pt) then
        begin
          Dec(FYearRangeStart, YEAR_COUNT);
          FHoveredYearIdx := -1;
          Invalidate;
        end
        else if PtInRect(GetNextBtnRect, Pt) then
        begin
          Inc(FYearRangeStart, YEAR_COUNT);
          FHoveredYearIdx := -1;
          Invalidate;
        end
        else
          for i := 0 to YEAR_COUNT - 1 do
            if PtInRect(GetYearCellRect(i), Pt) then
            begin
              Yr := GetYearForCell(i);
              FViewYear := Yr;
              FViewMode := 1; // back to months view
              FHoveredYearIdx := -1;
              FHoveredBtn := -1;
              Invalidate;
              Break;
            end;
      end;

      1: // Months view
      begin
        if PtInRect(GetPrevBtnRect, Pt) then
        begin
          Dec(FViewYear);
          FHoveredMonthIdx := -1;
          Invalidate;
        end
        else if PtInRect(GetNextBtnRect, Pt) then
        begin
          Inc(FViewYear);
          FHoveredMonthIdx := -1;
          Invalidate;
        end
        else if PtInRect(GetYearLabelHitRect, Pt) then
        begin
          FYearRangeStart := (FViewYear div YEAR_COUNT) * YEAR_COUNT;
          FViewMode := 2;
          FHoveredBtn := -1;
          FHoveredMonthIdx := -1;
          Invalidate;
        end
        else
          for i := 0 to 11 do
            if PtInRect(GetMonthCellRect(i), Pt) then
            begin
              FViewMonth := i + 1;
              FViewMode := 0; // back to days view
              FHoveredMonthIdx := -1;
              FHoveredBtn := -1;
              Invalidate;
              Break;
            end;
      end;

    else // Days view (0)
      if PtInRect(GetPrevBtnRect, Pt) then
        ChangeMonth(-1)
      else if PtInRect(GetNextBtnRect, Pt) then
        ChangeMonth(1)
      else if PtInRect(GetMonthLabelHitRect, Pt) then
      begin
        // Click on month → months view
        FViewMode := 1;
        FHoveredBtn := -1;
        Invalidate;
      end
      else if PtInRect(GetYearLabelHitRect, Pt) then
      begin
        // Click on year → years view (via months, keeps consistency)
        FYearRangeStart := (FViewYear div YEAR_COUNT) * YEAR_COUNT;
        FViewMode := 2;
        FHoveredBtn := -1;
        Invalidate;
      end
      else if FHoveredDayIdx >= 0 then
      begin
        FDatePicker.Date := GetDateForCell(FHoveredDayIdx);
        FDatePicker.CloseDropdown;
      end;
    end;
  end;

  procedure TCWSCalendarDropdown.WMMouseMove(var Msg: TWMMouseMove);
  var
    Pt: TPoint;
    i, OldDay, OldBtn, OldYear, OldMonth: Integer;
  begin
    Pt := Point(Msg.XPos - BodyLeft, Msg.YPos - BodyTop);
    OldDay   := FHoveredDayIdx;
    OldBtn   := FHoveredBtn;
    OldYear  := FHoveredYearIdx;
    OldMonth := FHoveredMonthIdx;

    FHoveredDayIdx   := -1;
    FHoveredBtn      := -1;
    FHoveredYearIdx  := -1;
    FHoveredMonthIdx := -1;

    // Today bar — in all views
    if PtInRect(GetTodayBarRect, Pt) then
    begin
      FHoveredBtn := 4;
    end
    else
    case FViewMode of
      2: // Years
      begin
        if PtInRect(GetPrevBtnRect, Pt) then
          FHoveredBtn := 0
        else if PtInRect(GetNextBtnRect, Pt) then
          FHoveredBtn := 1
        else
          for i := 0 to YEAR_COUNT - 1 do
            if PtInRect(GetYearCellRect(i), Pt) then
            begin
              FHoveredYearIdx := i;
              Break;
            end;
      end;

      1: // Months
      begin
        if PtInRect(GetPrevBtnRect, Pt) then
          FHoveredBtn := 0
        else if PtInRect(GetNextBtnRect, Pt) then
          FHoveredBtn := 1
        else if PtInRect(GetYearLabelHitRect, Pt) then
          FHoveredBtn := 2
        else
          for i := 0 to 11 do
            if PtInRect(GetMonthCellRect(i), Pt) then
            begin
              FHoveredMonthIdx := i;
              Break;
            end;
      end;

    else // Days
      if PtInRect(GetPrevBtnRect, Pt) then
        FHoveredBtn := 0
      else if PtInRect(GetNextBtnRect, Pt) then
        FHoveredBtn := 1
      else if PtInRect(GetMonthLabelHitRect, Pt) then
        FHoveredBtn := 3
      else if PtInRect(GetYearLabelHitRect, Pt) then
        FHoveredBtn := 2
      else
        for i := 0 to 41 do
          if PtInRect(GetDayCellRect(i), Pt) then
          begin
            FHoveredDayIdx := i;
            Break;
          end;
    end;

    if (OldDay <> FHoveredDayIdx) or (OldBtn <> FHoveredBtn) or
       (OldYear <> FHoveredYearIdx) or (OldMonth <> FHoveredMonthIdx) then
      Invalidate;
  end;

  procedure TCWSCalendarDropdown.WMCWSClose(var Msg: TMessage);
  begin
    FDatePicker.CloseDropdown;
  end;

  procedure TCWSCalendarDropdown.WMActivateApp(var Msg: TMessage);
  begin
    inherited;
    // wParam = 0 means the application is losing focus
    if Msg.WParam = 0 then
      PostMessage(Handle, WM_CWS_CLOSEDROPDOWN, 0, 0);
  end;

  procedure TCWSCalendarDropdown.WMMouseActivate(var Msg: TWMMouseActivate);
  begin
    { Do not activate the list window on click — otherwise a foreground window change
      triggers the EVENT_SYSTEM_FOREGROUND hook and closes the list when clicking month/year. }
    Msg.Result := MA_NOACTIVATE;
  end;

  procedure TCWSCalendarDropdown.CMMouseLeave(var Msg: TMessage);
  begin
    inherited;
    FHoveredDayIdx   := -1;
    FHoveredBtn      := -1;
    FHoveredYearIdx  := -1;
    FHoveredMonthIdx := -1;
    Invalidate;
  end;

  procedure TCWSCalendarDropdown.ChangeMonth(Delta: Integer);
  var
    D: TDate;
  begin
    D := EncodeDate(FViewYear, FViewMonth, 1);
    D := IncMonth(D, Delta);
    FViewYear := YearOf(D);
    FViewMonth := MonthOf(D);
    Invalidate;
  end;

  procedure TCWSCalendarDropdown.ShowPopup(X, Y: Integer);
  var
    MonR, WR: TRect;
    Mon: HMONITOR;
    MonInfo: TMonitorInfo;
    BodyTopScreen, BodyLeftScreen: Integer;
  begin
    HandleNeeded;
    ComputeScale;

    { The list adapts to the component width, but does not go below
      DROPDOWN_MIN_WIDTH, so the calendar layout stays readable. With a list
      wider than the field, the side edges do not form a single line, so we remove
      the "step" at the junction by sliding the list 1 px onto the field (see below)
      and painting the accent over the contact segment. }
    FBodyW := Max(FDatePicker.Width, ScalePx(DROPDOWN_MIN_WIDTH));
    FBodyH := ScalePx(340);

    { shadow margin (like in CWSPopupMenu / CWSComboBox) }
    if FDatePicker.FDropdownShadowEnabled then
    begin
      FBlur         := Max(2, Round(FDatePicker.FDropdownShadowSize * FScale));
      FShadowOffset := Round(5 * FScale);
      FShadow       := FBlur + FShadowOffset + Round(4 * FScale);
    end
    else begin FBlur := 0; FShadowOffset := 0; FShadow := 0; end;
    FMarginSide := FShadow;

    Mon := MonitorFromPoint(Point(X, Y), MONITOR_DEFAULTTONEAREST);
    MonInfo.cbSize := SizeOf(MonInfo);
    GetMonitorInfo(Mon, @MonInfo);
    MonR := MonInfo.rcWork;

    { Direction + symmetric shadow margin on all sides. The list sits against
      the field edge (without overlapping it). }
    if Y + FBodyH > MonR.Bottom then
    begin
      FOpenedUp     := True;
      GetWindowRect(FDatePicker.Handle, WR);
      { Opening up: slide the list 1 px down, so its bottom edge overlaps the
        top edge of the field — the "step" at the junction disappears. }
      BodyTopScreen := WR.Top - FBodyH + ScalePx(1);
      if BodyTopScreen < MonR.Top then BodyTopScreen := MonR.Top;
      FMarginTop    := FShadow;
      FMarginBottom := FShadow;
    end
    else
    begin
      FOpenedUp     := False;
      { Opening down: slide the list 1 px up, so its top edge overlaps the
        bottom edge of the field — the "step" at the junction disappears. }
      BodyTopScreen := Y - ScalePx(1);
      FMarginTop    := FShadow;
      FMarginBottom := FShadow;
    end;

    { When the list is wider than the component (component narrower than DROPDOWN_MIN_WIDTH),
      center it against the component — the "wings" protrude symmetrically on both
      sides, while the contact (accent/border) stays under the component. }
    BodyLeftScreen := X;
    if FBodyW > FDatePicker.Width then
      BodyLeftScreen := X - (FBodyW - FDatePicker.Width) div 2;
    if BodyLeftScreen + FBodyW > MonR.Right then BodyLeftScreen := MonR.Right - FBodyW;
    if BodyLeftScreen < MonR.Left then BodyLeftScreen := MonR.Left;

    { Actual contact range with the component on the junction edge (the intersection
      of the horizontal projection of the control and the list body) — in pixels relative to the left
      edge of the body. The list is sometimes wider than the field (FBodyW = max(field width, 300)),
      so the contact covers only part of the edge; the rest is "free". }
    GetWindowRect(FDatePicker.Handle, WR);
    FContactL := WR.Left  - BodyLeftScreen;
    FContactR := WR.Right - BodyLeftScreen;
    if FContactL < 0 then FContactL := 0;
    if FContactR > FBodyW then FContactR := FBodyW;
    if FContactR < FContactL then FContactR := FContactL;

    FWinW    := FBodyW + FMarginSide * 2;
    FWinH    := FBodyH + FMarginTop + FMarginBottom;
    FWinLeft := BodyLeftScreen - FMarginSide;
    FWinTop  := BodyTopScreen - FMarginTop;
    FBodyScreen := Rect(BodyLeftScreen, BodyTopScreen,
      BodyLeftScreen + FBodyW, BodyTopScreen + FBodyH);

    { Control rect relative to the top-left corner of the window — in this area the shadow
      is erased (it must not darken the field), and clicks are passed through. }
    FCtrlLocal := Rect(WR.Left - FWinLeft, WR.Top - FWinTop,
      WR.Right - FWinLeft, WR.Bottom - FWinTop);
    FCtrlScreen := WR;

    FHoveredDayIdx   := -1;
    FHoveredBtn      := -1;
    FHoveredYearIdx  := -1;
    FHoveredMonthIdx := -1;
    FViewMode        := 0;

    if FDatePicker.Date <> 0 then
    begin
      FViewYear := YearOf(FDatePicker.Date);
      FViewMonth := MonthOf(FDatePicker.Date);
    end
    else
    begin
      FViewYear := YearOf(Now);
      FViewMonth := MonthOf(Now);
    end;

    BuildShadow;

    SetWindowPos(Handle, HWND_TOPMOST, FWinLeft, FWinTop, FWinW, FWinH,
      SWP_NOACTIVATE or SWP_HIDEWINDOW);
    Render;
    ShowWindow(Handle, SW_SHOWNOACTIVATE);
    SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0,
      SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);
    InstallHook(Self);
  end;

  procedure TCWSCalendarDropdown.HidePopup;
  begin
    UninstallHook;
    if HandleAllocated then
      ShowWindow(Handle, SW_HIDE);
  end;

  { ════════════════════════════════════════════════════════════════════════════
      TCWSDatePicker
    ════════════════════════════════════════════════════════════════════════════ }

  constructor TCWSDatePicker.Create(AOwner: TComponent);
  begin
    inherited Create(AOwner);
    ControlStyle := ControlStyle + [csOpaque];
    Width := 120;
    Height := 35;
    TabStop := True;
    Cursor := crDefault;

    FBuffer := TBitmap.Create;
    FBuffer.PixelFormat := pf32bit;

    FCornerRadius := 4;
    FAccentColor := $D47800;
    FBackgroundColor := clWhite;
    FBackgroundHoverColor := $F9F9F9;
    FBorderColor := $D6D6D6;
    FDisabledColor := $F7F7F7;
    FDisabledBorderColor := $E0E0E0;
    FTextColor := $202020;
    FDisabledTextColor := $A0A0A0;
    FDropdownBackColor := clWhite;
    FDropdownCornerRadius  := 8;     { list rounding — like in CWSComboBox }
    FDropdownShadowEnabled := True;
    FDropdownShadowSize    := 18;

    FAutoSizeHeight := True;
    FDateFormat := 'yyyy-MM-dd';
    FDate := 0;

    FTodayBorderColor := $D47800;
    FSelectedDayColor := $D47800;
    FSelectedDayBorderColor := $D47800;
    FSelectedDayTextColor := clWhite;
    FHoverColor := $E8E8E8;
    FHoverTextColor := $202020;
    FOtherMonthTextColor := $A0A0A0;
    FOtherMonthHoverTextColor := $A0A0A0;
    FTodayTextColor := $D47800;
    FTodayHoverTextColor := $D47800;
    FLinkTextColor := $202020;
    FLinkHoverTextColor := $D47800;
    FDayShape := dsRoundRect;

    FEditInternalMarginL := 1;

    FDropdown := TCWSCalendarDropdown.Create(Self);
    CreateEdit;
  end;

  destructor TCWSDatePicker.Destroy;
  begin
    if FDroppedDown then
      CloseDropdown;
    FDropdown.Free;
    DestroyEdit;
    FBuffer.Free;
    inherited;
  end;

  procedure TCWSDatePicker.CreateEdit;
  begin
    if FInternalEdit <> nil then
      Exit;
    FInternalEdit := TCWSBufferedMaskEdit.Create(Self);
    FInternalEdit.Parent := Self;
    FInternalEdit.BorderStyle := bsNone;
    FInternalEdit.ParentFont := False;
    FInternalEdit.Font.Assign(Font);
    FInternalEdit.Color := GetCurrentBgColor;
    FInternalEdit.AutoSelect := True;

    FInternalEdit.OnChange := EditChange;
    FInternalEdit.OnEnter := EditEnter;
    FInternalEdit.OnExit := EditExit;
    FInternalEdit.OnKeyDown := EditKeyDown;
    FInternalEdit.OnMouseDown := EditMouseDown;

    // UpdateEditFromDate sets the mask and text in the correct order
    UpdateEditFromDate;
    UpdateEditPosition;
  end;

  procedure TCWSDatePicker.DestroyEdit;
  begin
    FreeAndNil(FInternalEdit);
  end;

  procedure TCWSDatePicker.UpdateEditPosition;
  var
    L, T, EditH, BtnW, TextMarginL: Integer;
    DC: HDC;
    TM: TTextMetric;
  begin
    if FInternalEdit = nil then
      Exit;
    DC := GetDC(0);
    try
      SelectObject(DC, Font.Handle);
      GetTextMetrics(DC, TM);
      EditH := TM.tmHeight;
    finally ReleaseDC(0, DC);
    end;

    BtnW := Scale(36);
    TextMarginL := GetTextMarginL;
    L := TextMarginL - FEditInternalMarginL;
    if L < 0 then
      L := 0;
    T := (Height - EditH) div 2;
    if T < 0 then
      T := 0;

    FInternalEdit.SetBounds(L, T, Width - BtnW - TextMarginL, EditH);
  end;

  procedure TCWSDatePicker.SyncEditAppearance;
  begin
    if FInternalEdit = nil then
      Exit;
    FInternalEdit.Color := GetCurrentBgColor;
    if Enabled then
      FInternalEdit.Font.Color := FTextColor
    else
      FInternalEdit.Font.Color := FDisabledTextColor;
    // Force the inner edit to repaint so a focused control adopts the new
    // theme colors immediately, without waiting for a mouse-over.
    if FInternalEdit.HandleAllocated then
      FInternalEdit.Invalidate;
  end;

  procedure TCWSDatePicker.CMFontChanged(var Msg: TMessage);
  begin
    inherited;
    if FInternalEdit <> nil then
    begin
      FInternalEdit.Font.Assign(Font);
      // Font.Assign nadpisuje Font.Color kolorem VCL-owego Font (domyslnie
      // ciemny clWindowText). Przywracamy wlasciwy TextColor.
      SyncEditAppearance;
    end;
    AdjustHeight;
    Invalidate;
  end;

  procedure TCWSDatePicker.CMParentFontChanged(var Msg: TMessage);
  begin
    inherited;
    if FInternalEdit <> nil then
    begin
      FInternalEdit.Font.Assign(Font);
      SyncEditAppearance;
    end;
    AdjustHeight;
    Invalidate;
  end;

  procedure TCWSDatePicker.CMPPIChanged(var Msg: TMessage);
  begin
    inherited;
    FBuffer.SetSize(0, 0);
    AdjustHeight;
    UpdateEditPosition;
    SyncEditAppearance;
    Invalidate;
  end;

  procedure TCWSDatePicker.Loaded;
  begin
    inherited;
    if FInternalEdit <> nil then
    begin
      FInternalEdit.Font.Assign(Font);
      SyncEditAppearance;
    end;
    AdjustHeight;
  end;

  function TCWSDatePicker.GetTextMarginL: Integer;
  begin
    Result := Scale(10) + Round(ScaleF(FCornerRadius) / 2);
  end;

  procedure TCWSDatePicker.AdjustHeight;
  var
    TextH, Padding, NewH: Integer;
    DC: HDC;
    TM: TTextMetric;
  begin
    if not FAutoSizeHeight then
      Exit;
    DC := GetDC(0);
    try
      SelectObject(DC, Font.Handle);
      GetTextMetrics(DC, TM);
      TextH := TM.tmHeight;
    finally ReleaseDC(0, DC);
    end;
    Padding := Scale(6);
    NewH := TextH + Padding * 2;
    if NewH < Scale(28) then
      NewH := Scale(28);
    if Height <> NewH then
    begin
      Height := NewH;
      UpdateEditPosition;
    end;
  end;

  procedure TCWSDatePicker.SetAutoSizeHeight(const Value: Boolean);
  begin
    if FAutoSizeHeight <> Value then
    begin
      FAutoSizeHeight := Value;
      if FAutoSizeHeight then
        AdjustHeight;
    end;
  end;

  function TCWSDatePicker.MakeGPColor(AColor: TColor; Alpha: Byte): Cardinal;
  var
    C: TColor;
  begin
    C := ColorToRGB(AColor);
    Result := Winapi.GDIPAPI.MakeColor(Alpha, GetRValue(C), GetGValue(C), GetBValue(C));
  end;

  function TCWSDatePicker.CreateRoundRectPath(X, Y, W, H, R: Single): TGPGraphicsPath;
  var
    D: Single;
  begin
    Result := TGPGraphicsPath.Create;
    if R <= 0 then
    begin
      Result.AddRectangle(MakeRect(X, Y, W, H));
      Exit;
    end;
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

  function TCWSDatePicker.Scale(Value: Integer): Integer;
  begin
    Result := MulDiv(Value, CurrentPPI, 96);
  end;

  function TCWSDatePicker.ScaleF(Value: Single): Single;
  begin
    Result := Value * CurrentPPI / 96;
  end;

  function TCWSDatePicker.GetCurrentBgColor: TColor;
  begin
    if not Enabled then
      Result := FDisabledColor
    else if FHovered then
      Result := FBackgroundHoverColor
    else
      Result := FBackgroundColor;
  end;

  function TCWSDatePicker.GetCurrentBorderColor: TColor;
  begin
    if not Enabled then
      Result := FDisabledBorderColor
    else
      Result := FBorderColor;
  end;

  function TCWSDatePicker.GetParentBgColor: TColor;
  begin
    if Parent <> nil then
      Result := TControlAccess(Parent).Color
    else
      Result := clBtnFace;
  end;

  function TCWSDatePicker.Focused: Boolean;
  begin
    Result := inherited Focused or ((FInternalEdit <> nil) and FInternalEdit.Focused);
  end;

  procedure TCWSDatePicker.ApplyStateChange;
  begin
    SyncEditAppearance;
    if HandleAllocated then
      Invalidate;
  end;

  { Converts a date format (e.g. 'yyyy-MM-dd', 'dd.MM.yyyy') to a TMaskEdit mask.
    Year/month/day digits map to '9' (optional digit) or '0' (required).
    Separators are copied as literals. }
  function TCWSDatePicker.DateFormatToMask(const ADateFormat: string): string;
  var
    i: Integer;
    C: Char;
    MaskBuf: string;
  begin
    MaskBuf := '';
    i := 1;
    while i <= Length(ADateFormat) do
    begin
      C := ADateFormat[i];
      case C of
        'y', 'Y': begin MaskBuf := MaskBuf + '0'; Inc(i); end;
        'M', 'm': begin MaskBuf := MaskBuf + '0'; Inc(i); end;
        'd', 'D': begin MaskBuf := MaskBuf + '0'; Inc(i); end;
      else
        // Separator or other char — literal (prefixed with '\' for TMaskEdit)
        MaskBuf := MaskBuf + '\' + C;
        Inc(i);
      end;
    end;
    // TMaskEdit mask format: <mask>;_; (space as placeholder)
    Result := MaskBuf + ';1;_';
  end;

  procedure TCWSDatePicker.SetEditMask(const Value: string);
  begin
    FEditMask := Value;
    if FInternalEdit <> nil then
    begin
      if FEditMask <> '' then
        FInternalEdit.EditMask := FEditMask
      else
        FInternalEdit.EditMask := DateFormatToMask(FDateFormat);
      UpdateEditFromDate;
    end;
  end;

  procedure TCWSDatePicker.SetDate(const Value: TDate);
  begin
    if FDate <> Value then
    begin
      FDate := Value;
      UpdateEditFromDate;
      if Assigned(FOnChange) then
        FOnChange(Self);
    end;
  end;

  procedure TCWSDatePicker.SetDateFormat(const Value: string);
  begin
    if Value = '' then
      FDateFormat := 'yyyy-MM-dd'
    else
      FDateFormat := Value;
    // Refresh the mask only when none was set manually
    if (FInternalEdit <> nil) and (FEditMask = '') then
      FInternalEdit.EditMask := DateFormatToMask(FDateFormat);
    UpdateEditFromDate;
  end;

  procedure TCWSDatePicker.UpdateEditFromDate;
  var
    OldChange: TNotifyEvent;
  begin
    if FInternalEdit = nil then
      Exit;
    OldChange := FInternalEdit.OnChange;
    FInternalEdit.OnChange := nil;
    try
      if FDate = 0 then
      begin
        // For an empty date drop the mask to avoid validation errors
        FInternalEdit.EditMask := '';
        FInternalEdit.Text := '';
        // Restore the mask
        if FEditMask <> '' then
          FInternalEdit.EditMask := FEditMask
        else
          FInternalEdit.EditMask := DateFormatToMask(FDateFormat);
      end
      else
        FInternalEdit.Text := FormatDateTime(FDateFormat, FDate);
    finally
      FInternalEdit.OnChange := OldChange;
    end;
  end;

  procedure TCWSDatePicker.UpdateDateFromEdit;
  var
    TryDate: TDateTime;
    RawText: string;
  begin
    if FInternalEdit = nil then
      Exit;
    // GetCleanText returns text without mask chars (placeholders '_')
    RawText := FInternalEdit.GetCleanText;
    // Remove any remaining placeholders
    RawText := StringReplace(RawText, '_', '', [rfReplaceAll]);
    if TryStrToDate(RawText, TryDate) then
    begin
      if FDate <> TryDate then
      begin
        FDate := TryDate;
        if Assigned(FOnChange) then
          FOnChange(Self);
      end;
    end;
  end;

  procedure TCWSDatePicker.OpenDropdown;
  var
    WR: TRect;
  begin
    if FDroppedDown or not Enabled then
      Exit;
    UpdateDateFromEdit;
    FDroppedDown := True;
    HandleNeeded;
    GetWindowRect(Handle, WR);
    FDropdown.ShowPopup(WR.Left, WR.Bottom);
    FDropUp := FDropdown.FOpenedUp;   { align the border corners to the list }
    if Assigned(FOnDropDown) then
      FOnDropDown(Self);
    Invalidate;
  end;

  procedure TCWSDatePicker.CloseDropdown;
  begin
    if not FDroppedDown then
      Exit;
    FDroppedDown := False;
    FDropUp      := False;
    FDropdown.HidePopup;
    if Assigned(FOnCloseUp) then
      FOnCloseUp(Self);
    if (FInternalEdit <> nil) and FInternalEdit.CanFocus then
      FInternalEdit.SetFocus;
    Invalidate;
  end;

  procedure TCWSDatePicker.DropDown;
  begin
    OpenDropdown;
  end;

  procedure TCWSDatePicker.CloseUp;
  begin
    CloseDropdown;
  end;

  procedure TCWSDatePicker.EditChange(Sender: TObject);
  begin
    UpdateDateFromEdit;
  end;

  procedure TCWSDatePicker.EditEnter(Sender: TObject);
  begin
    FFocused := True;
    Invalidate;
  end;

  procedure TCWSDatePicker.EditExit(Sender: TObject);
  begin
    FFocused := False;
    if FDroppedDown then
      CloseDropdown;
    Invalidate;
  end;

  procedure TCWSDatePicker.EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  begin
    if Key = VK_DOWN then
    begin
      OpenDropdown;
      Key := 0;
    end
    else if Key = VK_ESCAPE then
    begin
      CloseDropdown;
      Key := 0;
    end;
  end;

  procedure TCWSDatePicker.EditMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
    if (Button = mbLeft) and FDroppedDown then
      CloseDropdown;
  end;

  procedure TCWSDatePicker.EnsureBuffer;
  begin
    if (FBuffer.Width <> Width) or (FBuffer.Height <> Height) then
      FBuffer.SetSize(Width, Height);
  end;

  procedure TCWSDatePicker.PaintToBuffer;
  var
    G: TGPGraphics;
    W, H, R: Single;
    Path: TGPGraphicsPath;
    Brush: TGPSolidBrush;
    Pen: TGPPen;
    BtnW, IconCX, IconCY: Single;
    AccentH: Integer;
    IconColor: TColor;
    RoundTop, RoundBottom: Boolean;
  begin
    EnsureBuffer;
    W := Width;
    H := Height;
    R := ScaleF(FCornerRadius);
    FBuffer.Canvas.Brush.Color := GetParentBgColor;
    FBuffer.Canvas.FillRect(Rect(0, 0, Width, Height));

    { On the side joining the list, the corners are straight — the side lines of the DatePicker and
      the list form one straight edge: list down → straight bottom, list up → straight top. }
    RoundTop    := not (FDroppedDown and FDropUp);
    RoundBottom := not (FDroppedDown and not FDropUp);

    G := TGPGraphics.Create(FBuffer.Canvas.Handle);
    try
      G.SetSmoothingMode(SmoothingModeAntiAlias);
      G.SetPixelOffsetMode(PixelOffsetModeHalf);

      Path := CreateBodyPath(0.5, 0.5, W - 1, H - 1, R, RoundTop, RoundBottom);
      Brush := TGPSolidBrush.Create(MakeGPColor(GetCurrentBgColor));
      G.FillPath(Brush, Path);
      Brush.Free;
      Pen := TGPPen.Create(MakeGPColor(GetCurrentBorderColor), 1.0);
      G.DrawPath(Pen, Path);
      Pen.Free;
      Path.Free;

      if (FFocused or FDroppedDown) and Enabled then
      begin
        AccentH := Scale(2);
        G.SetSmoothingMode(SmoothingModeNone);
        if FDroppedDown then
        begin
          { The accent line is always at the bottom of the DatePicker (as in CWSComboBox) — even when
            the list opens upwards. }
          Brush := TGPSolidBrush.Create(MakeGPColor(FAccentColor));
          G.FillRectangle(Brush, MakeRect(0.0, H - AccentH, W, Single(AccentH)));
          Brush.Free;
        end
        else
        begin
          Path := CreateRoundRectPath(0.0, 0.0, W, H, R);
          G.SetClip(Path);
          Path.Free;
          Brush := TGPSolidBrush.Create(MakeGPColor(FAccentColor));
          G.FillRectangle(Brush, MakeRect(0.0, H - AccentH, W, Single(AccentH)));
          Brush.Free;
          G.ResetClip;
        end;
        G.SetSmoothingMode(SmoothingModeAntiAlias);
      end;

      BtnW := Scale(36);
      Pen := TGPPen.Create(MakeGPColor(GetCurrentBorderColor), 1.0);
      // FIX: Explicit MakePoint avoids type-matching issues in older GDI+
      G.DrawLine(Pen, MakePoint(W - BtnW, Single(H * 0.2)), MakePoint(W - BtnW, Single(H * 0.8)));
      Pen.Free;

      // Calendar icon
      IconCX := W - BtnW / 2;
      IconCY := H / 2;

      // FIX: Safe color fetch to avoid System.Math.IfThen issues with TColor
      if Enabled then
        IconColor := FTextColor
      else
        IconColor := FDisabledTextColor;
      Pen := TGPPen.Create(MakeGPColor(IconColor), ScaleF(1.2));

      try
        Path := CreateRoundRectPath(IconCX - ScaleF(6), IconCY - ScaleF(6), ScaleF(12), ScaleF(12), ScaleF(2));
        G.DrawPath(Pen, Path);
        Path.Free;

        G.DrawLine(Pen, MakePoint(IconCX - ScaleF(6), IconCY - ScaleF(2)),
          MakePoint(IconCX + ScaleF(6), IconCY - ScaleF(2)));

        Brush := TGPSolidBrush.Create(MakeGPColor(IconColor));
        G.FillRectangle(Brush, MakeRect(IconCX - ScaleF(2), IconCY + ScaleF(2), ScaleF(2), ScaleF(2)));
        Brush.Free;

        G.DrawLine(Pen, MakePoint(IconCX - ScaleF(3), IconCY - ScaleF(8)),
          MakePoint(IconCX - ScaleF(3), IconCY - ScaleF(4)));

        G.DrawLine(Pen, MakePoint(IconCX + ScaleF(3), IconCY - ScaleF(8)),
          MakePoint(IconCX + ScaleF(3), IconCY - ScaleF(4)));
      finally Pen.Free;
      end;

    finally G.Free;
    end;
  end;

  procedure TCWSDatePicker.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
  begin
    Msg.Result := 1;
  end;

  procedure TCWSDatePicker.WMPaint(var Msg: TWMPaint);
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
    PaintToBuffer;
    BitBlt(DC, 0, 0, Width, Height, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
    EndPaint(Handle, PS);
  end;

  procedure TCWSDatePicker.Paint;
  begin
    PaintToBuffer;
    BitBlt(Canvas.Handle, 0, 0, Width, Height, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  end;

  procedure TCWSDatePicker.WMSetFocus(var Msg: TWMSetFocus);
  begin
    inherited;
    FFocused := True;
    if (FInternalEdit <> nil) and FInternalEdit.CanFocus then
      FInternalEdit.SetFocus
    else
      Invalidate;
  end;

  procedure TCWSDatePicker.WMKillFocus(var Msg: TWMKillFocus);
  begin
    inherited;
    if (FInternalEdit <> nil) and FInternalEdit.HandleAllocated and (Msg.FocusedWnd = FInternalEdit.Handle) then
      Exit;
    FFocused := False;
    if FDroppedDown then
      CloseDropdown;
    Invalidate;
  end;

  procedure TCWSDatePicker.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
    inherited;
    if Button = mbLeft then
    begin
      if (FInternalEdit = nil) or not PtInRect(FInternalEdit.BoundsRect, Point(X, Y)) then
      begin
        if not Focused and CanFocus then
          SetFocus;
        if FDroppedDown then
          CloseDropdown
        else
          OpenDropdown;
      end;
    end;
  end;

  procedure TCWSDatePicker.CMMouseEnter(var Msg: TMessage);
  begin
    inherited;
    if not FHovered then
    begin
      FHovered := True;
      ApplyStateChange;
    end;
  end;

  procedure TCWSDatePicker.CMMouseLeave(var Msg: TMessage);
  begin
    inherited;
    if FHovered then
    begin
      FHovered := False;
      ApplyStateChange;
    end;
  end;

  procedure TCWSDatePicker.CMEnabledChanged(var Msg: TMessage);
  begin
    inherited;
    if not Enabled and FDroppedDown then
      CloseDropdown;
    if FInternalEdit <> nil then
      FInternalEdit.Enabled := Enabled;
    ApplyStateChange;
  end;

  procedure TCWSDatePicker.CreateParams(var Params: TCreateParams);
  begin
    inherited;
    Params.Style := Params.Style or WS_CLIPCHILDREN;
  end;

  procedure TCWSDatePicker.Resize;
  begin
    inherited;
    UpdateEditPosition;
    Invalidate;
  end;

  procedure TCWSDatePicker.ChangeScale(M, D: Integer);
  begin
    inherited;
    AdjustHeight;
    UpdateEditPosition;
    SyncEditAppearance;
    Invalidate;
  end;

  procedure TCWSDatePicker.SetEnabled(Value: Boolean);
  begin
    inherited;
    if FInternalEdit <> nil then
      FInternalEdit.Enabled := Value;
    ApplyStateChange;
  end;

  procedure TCWSDatePicker.SetCornerRadius(const Value: Single);
  begin
    FCornerRadius := Max(0, Min(Value, 20));
    UpdateEditPosition;
    Invalidate;
  end;

  procedure TCWSDatePicker.SetAccentColor(const Value: TColor);
  begin
    FAccentColor := Value;
    Invalidate;
  end;

  procedure TCWSDatePicker.SetBackgroundColor(const Value: TColor);
  begin
    FBackgroundColor := Value;
    SyncEditAppearance;
    Invalidate;
  end;

  procedure TCWSDatePicker.SetBackgroundHoverColor(const Value: TColor);
  begin
    if FBackgroundHoverColor = Value then Exit;
    FBackgroundHoverColor := Value;
    SyncEditAppearance;
    Invalidate;
  end;

  procedure TCWSDatePicker.SetBorderColor(const Value: TColor);
  begin
    if FBorderColor = Value then Exit;
    FBorderColor := Value;
    Invalidate;
  end;

  procedure TCWSDatePicker.SetDisabledColor(const Value: TColor);
  begin
    if FDisabledColor = Value then Exit;
    FDisabledColor := Value;
    SyncEditAppearance;
    Invalidate;
  end;

  procedure TCWSDatePicker.SetDisabledBorderColor(const Value: TColor);
  begin
    if FDisabledBorderColor = Value then Exit;
    FDisabledBorderColor := Value;
    Invalidate;
  end;

  procedure TCWSDatePicker.SetTextColor(const Value: TColor);
  begin
    if FTextColor = Value then Exit;
    FTextColor := Value;
    SyncEditAppearance;
    if FDroppedDown and Assigned(FDropdown) then
      FDropdown.Invalidate;
    Invalidate;
  end;

  procedure TCWSDatePicker.SetDisabledTextColor(const Value: TColor);
  begin
    if FDisabledTextColor = Value then Exit;
    FDisabledTextColor := Value;
    SyncEditAppearance;
    Invalidate;
  end;

  procedure TCWSDatePicker.SetDropdownBackColor(const Value: TColor);
  begin
    FDropdownBackColor := Value;
    if FDroppedDown then
      FDropdown.Invalidate;
  end;

  procedure TCWSDatePicker.SetDropdownCornerRadius(const Value: Single);
  begin
    if FDropdownCornerRadius <> Value then
    begin
      FDropdownCornerRadius := Max(0, Min(Value, 24));
      if FDroppedDown then CloseDropdown;
    end;
  end;

  procedure TCWSDatePicker.SetDropdownShadowEnabled(const Value: Boolean);
  begin
    if FDropdownShadowEnabled <> Value then
    begin
      FDropdownShadowEnabled := Value;
      if FDroppedDown then CloseDropdown;
    end;
  end;

  procedure TCWSDatePicker.SetDropdownShadowSize(const Value: Integer);
  begin
    if FDropdownShadowSize <> Value then
    begin
      FDropdownShadowSize := Max(0, Value);
      if FDroppedDown then CloseDropdown;
    end;
  end;

  procedure TCWSDatePicker.SetTodayBorderColor(const Value: TColor);
  begin
    FTodayBorderColor := Value;
    if FDroppedDown then FDropdown.Invalidate;
  end;

  procedure TCWSDatePicker.SetSelectedDayColor(const Value: TColor);
  begin
    FSelectedDayColor := Value;
    if FDroppedDown then FDropdown.Invalidate;
  end;

  procedure TCWSDatePicker.SetSelectedDayTextColor(const Value: TColor);
  begin
    FSelectedDayTextColor := Value;
    if FDroppedDown then FDropdown.Invalidate;
  end;

  procedure TCWSDatePicker.SetHoverColor(const Value: TColor);
  begin
    FHoverColor := Value;
    if FDroppedDown then FDropdown.Invalidate;
  end;

  procedure TCWSDatePicker.SetSelectedDayBorderColor(const Value: TColor);
  begin
    FSelectedDayBorderColor := Value;
    if FDroppedDown then FDropdown.Invalidate;
  end;

  procedure TCWSDatePicker.SetHoverTextColor(const Value: TColor);
  begin
    FHoverTextColor := Value;
    if FDroppedDown then FDropdown.Invalidate;
  end;

  procedure TCWSDatePicker.SetOtherMonthTextColor(const Value: TColor);
  begin
    FOtherMonthTextColor := Value;
    if FDroppedDown then FDropdown.Invalidate;
  end;

  procedure TCWSDatePicker.SetOtherMonthHoverTextColor(const Value: TColor);
  begin
    FOtherMonthHoverTextColor := Value;
    if FDroppedDown then FDropdown.Invalidate;
  end;

  procedure TCWSDatePicker.SetTodayTextColor(const Value: TColor);
  begin
    FTodayTextColor := Value;
    if FDroppedDown then FDropdown.Invalidate;
  end;

  procedure TCWSDatePicker.SetTodayHoverTextColor(const Value: TColor);
  begin
    FTodayHoverTextColor := Value;
    if FDroppedDown then FDropdown.Invalidate;
  end;

  procedure TCWSDatePicker.SetLinkTextColor(const Value: TColor);
  begin
    FLinkTextColor := Value;
    if FDroppedDown then FDropdown.Invalidate;
  end;

  procedure TCWSDatePicker.SetLinkHoverTextColor(const Value: TColor);
  begin
    FLinkHoverTextColor := Value;
    if FDroppedDown then FDropdown.Invalidate;
  end;

  procedure TCWSDatePicker.SetDayShape(const Value: TCWSDayShape);
  begin
    FDayShape := Value;
    if FDroppedDown then FDropdown.Invalidate;
  end;

  procedure TCWSDatePicker.SetTextHint(const Value: string);
  begin
    FTextHint := Value;
    if FInternalEdit <> nil then
      FInternalEdit.TextHint := Value;
  end;

  end.
