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
unit CWSDimOverlay;

{
  TCWSDimOverlay - VCL component that dims a form (layered window).
  Supports Windows 11 rounded corners.

  Usage:
    1. Drop TCWSDimOverlay onto a form (shows as a design-time icon).
    2. Before showing a dialog:  DimOverlay1.Visible := True;
    3. After the dialog closes:  DimOverlay1.Visible := False;

  Properties:
    Visible                - shows/hides the overlay
    Opacity                - dimming level (0..255, default 128)
    Color                  - overlay color (default clBlack)
    Animated               - smooth fade-in / fade-out
    AnimationSteps         - number of animation steps
    CornerRadius           - corner rounding radius (0 = auto-detect from DWM)
    BlockClicks            - True = blocks mouse clicks on the form under overlay

    ShowActivityIndicator  - shows a smooth, transparent-background spinner
                             in the center of the overlay
    IndicatorStyle         - spinner look:
                               cisLines     - many thin fading radial lines
                               cisRing      - donut with a rotating arc
                               cisSegmented - thick fading donut segments
                               cisArrows    - pointed (chevron) donut segments
    IndicatorColor         - active / leading spinner color (default clWhite)
    IndicatorTrackColor    - inactive / trailing (track) color; the spinner
                             fades from IndicatorColor to this color
                             (default clGray)
    IndicatorSize          - spinner diameter in pixels (default 48)
    IndicatorSegmentCount  - number of elements (lines / blocks / arrows),
                             default 12. Ignored by cisRing.
    IndicatorGap           - gap between elements in pixels, kept the same
                             width along the whole element (default 4).
                             For cisSegmented this makes each block wider at
                             the outer edge and narrower at the inner edge so
                             the gap stays equal. Ignored by cisRing.
    IndicatorSpeed         - rotation speed in degrees per second
                             (default 300 = one full turn every 1.2 s).
                             Higher = faster. The animation is time-based, so
                             the speed is independent of the frame rate.

    Text                   - text drawn on the overlay (transparent background).
                             If empty, no text is drawn.
                             If the indicator is visible, the text is placed
                             below it; otherwise the text is centered.
    TextFont               - font used for the text (name, size, color, style)
}

interface

uses
  System.SysUtils, System.Classes, System.Math, System.SyncObjs,
  Winapi.Windows, Winapi.Messages,
  Vcl.Controls, Vcl.Forms, Vcl.Graphics, Vcl.ExtCtrls, System.Types,
  Winapi.GDIPAPI, Winapi.GDIPOBJ;

type
  // Visual style of the activity indicator
  TCWSIndicatorStyle = (cisLines, cisRing, cisSegmented, cisArrows);

  TCWSDimOverlay = class(TComponent)
  private
    FVisible: Boolean;
    FOpacity: Byte;
    FColor: TColor;
    FOverlayWnd: HWND;
    FOldParentWndProc: TWndMethod;
    FHooked: Boolean;
    // True only after PresentOverlay has shown the window at its intended
    // (faded / final) state. Until then the window exists but is still hidden,
    // so the parent's WM_ACTIVATE / WM_WINDOWPOSCHANGED handling must NOT show
    // or fully present it - doing so would flash the opaque dim for one frame
    // before the deferred PresentOverlay fades it in (the OnShow flicker).
    FPresented: Boolean;
    FAnimated: Boolean;
    FAnimationSteps: Integer;
    FCornerRadius: Integer;
    FBlockClicks: Boolean;
    FShowActivityIndicator: Boolean;
    FIndicatorStyle: TCWSIndicatorStyle;
    FIndicatorColor: TColor;
    FIndicatorTrackColor: TColor;
    FIndicatorSize: Integer;
    FIndicatorSegmentCount: Integer;
    FIndicatorGap: Integer;
    FIndicatorSpeed: Integer;
    FPhase: Single;
    FText: string;
    FTextFont: TFont;
    FAnimThread: TThread;
    FRenderLock: TCriticalSection;
    // persistent layered-window back buffer (reused across frames so the 60 fps
    // spinner loop does not reallocate / re-render the whole form-sized surface)
    FBufDC: HDC;
    FBufDIB: HBITMAP;
    FBufOldBmp: HBITMAP;
    FBufBits: Pointer;
    FBufW: Integer;
    FBufH: Integer;
    // cached spinner geometry from the last full render, so a frame can repaint
    // only the spinner's bounding box
    FSpinnerRect: TRect;
    FSpinnerCenterX: Single;
    FSpinnerCenterY: Single;
    FOnShow: TNotifyEvent;
    FOnHide: TNotifyEvent;
    procedure SetVisible(Value: Boolean);
    procedure SetOpacity(Value: Byte);
    procedure SetColor(Value: TColor);
    procedure SetCornerRadius(Value: Integer);
    procedure SetShowActivityIndicator(Value: Boolean);
    procedure SetIndicatorStyle(Value: TCWSIndicatorStyle);
    procedure SetIndicatorColor(Value: TColor);
    procedure SetIndicatorTrackColor(Value: TColor);
    procedure SetIndicatorSize(Value: Integer);
    procedure SetIndicatorSegmentCount(Value: Integer);
    procedure SetIndicatorGap(Value: Integer);
    procedure SetIndicatorSpeed(Value: Integer);
    procedure SetText(const Value: string);
    procedure SetTextFont(Value: TFont);
    procedure TextFontChanged(Sender: TObject);
    procedure UpdateTimerState;
    procedure StopSpinner;
    procedure Repaint;
    procedure CreateOverlayWindow;
    procedure PresentOverlay;
    procedure DestroyOverlayWindow;
    procedure UpdateOverlayBounds;
    procedure RepositionToForm;
    procedure EnsureBuffer(AWidth, AHeight: Integer);
    procedure FreeBuffer;
    procedure ApplyLayeredBitmap(AGlobalAlpha: Byte);
    procedure DoPresentFull(AGlobalAlpha: Byte);
    procedure ApplySpinnerFrame;
    procedure RenderToBuffer(ABits: Pointer; AWidth, AHeight: Integer);
    procedure RenderSpinnerBox(const ABox: TRect);
    procedure DrawContent(G: TGPGraphics; AWidth, AHeight: Integer);
    procedure DrawSpinner(G: TGPGraphics; ACenterX, ACenterY, ASize: Single);
    procedure DrawIndicatorLines(G: TGPGraphics; CX, CY, ASize, T: Single);
    procedure DrawIndicatorRing(G: TGPGraphics; CX, CY, ASize, T: Single);
    procedure DrawIndicatorSegmented(G: TGPGraphics; CX, CY, ASize, T: Single);
    procedure DrawIndicatorArrows(G: TGPGraphics; CX, CY, ASize, T: Single);
    procedure ApplyWindowRegion;
    procedure ParentWndProc(var Message: TMessage);
    procedure HookParentForm;
    procedure UnhookParentForm;
    procedure DoAnimateShow;
    procedure DoAnimateHide;
    function GetParentForm: TCustomForm;
    function GetFormVisualRect(AForm: TCustomForm): TRect;
    function FormPositionPending(AForm: TCustomForm): Boolean;
    function DetectCornerRadius: Integer;
    function IsWindows11OrLater: Boolean;
  protected
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Show;
    procedure Hide;
    property OverlayHandle: HWND read FOverlayWnd;
  published
    property Visible: Boolean read FVisible write SetVisible default False;
    property Opacity: Byte read FOpacity write SetOpacity default 128;
    property Color: TColor read FColor write SetColor default clBlack;
    property Animated: Boolean read FAnimated write FAnimated default True;
    property AnimationSteps: Integer read FAnimationSteps write FAnimationSteps default 10;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 0;
    property BlockClicks: Boolean read FBlockClicks write FBlockClicks default True;
    property ShowActivityIndicator: Boolean read FShowActivityIndicator
      write SetShowActivityIndicator default False;
    property IndicatorStyle: TCWSIndicatorStyle read FIndicatorStyle
      write SetIndicatorStyle default cisLines;
    property IndicatorColor: TColor read FIndicatorColor write SetIndicatorColor default clWhite;
    property IndicatorTrackColor: TColor read FIndicatorTrackColor
      write SetIndicatorTrackColor default clGray;
    property IndicatorSize: Integer read FIndicatorSize write SetIndicatorSize default 48;
    property IndicatorSegmentCount: Integer read FIndicatorSegmentCount
      write SetIndicatorSegmentCount default 12;
    property IndicatorGap: Integer read FIndicatorGap write SetIndicatorGap default 4;
    property IndicatorSpeed: Integer read FIndicatorSpeed write SetIndicatorSpeed default 300;
    property Text: string read FText write SetText;
    property TextFont: TFont read FTextFont write SetTextFont;
    property OnShow: TNotifyEvent read FOnShow write FOnShow;
    property OnHide: TNotifyEvent read FOnHide write FOnHide;
  end;

implementation

const
  OVERLAY_CLASS_NAME = 'TCWSDimOverlayWnd';

  DWMWA_EXTENDED_FRAME_BOUNDS    = 9;
  DWMWA_WINDOW_CORNER_PREFERENCE = 33;

  DWMWCP_DEFAULT    = 0;
  DWMWCP_DONOTROUND = 1;
  DWMWCP_ROUND      = 2;
  DWMWCP_ROUNDSMALL = 3;

  W11_CORNER_RADIUS       = 8;
  W11_CORNER_RADIUS_SMALL = 4;

  FRAME_INTERVAL_MS = 16;  // ~60 fps spinner animation (smooth)
  TEXT_MARGIN       = 16;  // horizontal padding for text wrapping

type
  // exposes TCustomForm.Position (protected) so the overlay can tell whether a
  // centering position is still pending during the form's show sequence
  TFormAccess = class(TCustomForm);

  TDwmGetWindowAttribute = function(hwnd: HWND; dwAttribute: DWORD;
    pvAttribute: Pointer; cbAttribute: DWORD): HRESULT; stdcall;
  TDwmSetWindowAttribute = function(hwnd: HWND; dwAttribute: DWORD;
    pvAttribute: Pointer; cbAttribute: DWORD): HRESULT; stdcall;

  PBlendFunction = ^TBlendFunction;

  // UpdateLayeredWindowIndirect is not declared in the RTL. We declare it so we
  // can pass a prcDirty rectangle and refresh only the spinner's bounding box
  // each frame, instead of re-uploading the whole form-sized layered surface
  // (which is what makes a 4K / 8K overlay slow).
  TUpdateLayeredWindowInfo = record
    cbSize: DWORD;
    hdcDst: HDC;
    pptDst: PPoint;
    psize: PSize;
    hdcSrc: HDC;
    pptSrc: PPoint;
    crKey: COLORREF;
    pblend: PBlendFunction;
    dwFlags: DWORD;
    prcDirty: PRect;
  end;

var
  GClassRegistered: Boolean = False;
  GDwmLib: HMODULE = 0;
  GDwmGetWindowAttribute: TDwmGetWindowAttribute = nil;
  GDwmSetWindowAttribute: TDwmSetWindowAttribute = nil;

function UpdateLayeredWindowIndirect(hWnd: HWND;
  const pULWInfo: TUpdateLayeredWindowInfo): BOOL; stdcall;
  external user32 name 'UpdateLayeredWindowIndirect';

procedure LoadDwmApi;
begin
  if GDwmLib <> 0 then
    Exit;
  GDwmLib := LoadLibrary('dwmapi.dll');
  if GDwmLib <> 0 then
  begin
    @GDwmGetWindowAttribute := GetProcAddress(GDwmLib, 'DwmGetWindowAttribute');
    @GDwmSetWindowAttribute := GetProcAddress(GDwmLib, 'DwmSetWindowAttribute');
  end;
end;

{ ============================================================================ }
{  Spinner animation thread                                                   }
{                                                                             }
{  Drives the activity indicator independently of the main message loop, so   }
{  the spinner keeps rotating even while the main thread is busy with a long  }
{  synchronous task (the usual loader scenario). It only advances the phase   }
{  and repaints the layered window; UpdateLayeredWindow is safe to call from  }
{  a worker thread and the owner serialises all rendering with FRenderLock.   }
{ ============================================================================ }

type
  TCWSSpinnerThread = class(TThread)
  private
    FOwner: TCWSDimOverlay;
    FWakeUp: TEvent;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TCWSDimOverlay);
    destructor Destroy; override;
    procedure Stop;
  end;

constructor TCWSSpinnerThread.Create(AOwner: TCWSDimOverlay);
begin
  FOwner := AOwner;
  FWakeUp := TEvent.Create(nil, False, False, '');
  inherited Create(False);
end;

destructor TCWSSpinnerThread.Destroy;
begin
  inherited Destroy;
  FWakeUp.Free;
end;

procedure TCWSSpinnerThread.Stop;
begin
  Terminate;
  FWakeUp.SetEvent;   // wake immediately so WaitFor returns promptly
end;

procedure TCWSSpinnerThread.Execute;
var
  // Int64 (not UInt64): DeltaMs converts the tick delta to Double. The Win32
  // compiler mis-converts UInt64 -> floating point (the delta comes out 0 in
  // optimized/Release builds), which froze the indicator on Win32 while Win64
  // was fine. GetTickCount64 values fit in Int64, so the signed conversion path
  // (FILD) is correct and identical on 32/64-bit.
  LastTick, NowTick: Int64;
  AccumDeg, DeltaMs: Double;
begin
  LastTick := Int64(GetTickCount64);
  AccumDeg := 0;        // total degrees travelled so far
  while not Terminated do
  begin
    // wrSignaled means Stop was called -> leave the loop without repainting
    if FWakeUp.WaitFor(FRAME_INTERVAL_MS) = wrSignaled then
      Break;
    if Terminated or (FOwner.FOverlayWnd = 0) then
      Continue;

    // Time-based phase: accumulate degrees from the elapsed time and the
    // current speed. Accumulating (rather than recomputing from a start time)
    // keeps the motion continuous even if IndicatorSpeed changes mid-spin.
    NowTick := Int64(GetTickCount64);
    DeltaMs := NowTick - LastTick;
    LastTick := NowTick;
    AccumDeg := AccumDeg + DeltaMs / 1000.0 * FOwner.FIndicatorSpeed;

    FOwner.FRenderLock.Enter;
    try
      FOwner.FPhase := Frac(AccumDeg / 360.0);   // 0..1, one unit per turn
      // dirty-rect update: repaints / uploads only the spinner box, so the
      // per-frame cost does not scale with the form's (4K/8K) resolution
      FOwner.ApplySpinnerFrame;
    finally
      FOwner.FRenderLock.Leave;
    end;
  end;
end;

{ ============================================================================ }
{  WndProc of the overlay window                                              }
{ ============================================================================ }

function OverlayWndProc(Wnd: HWND; Msg: UINT; WP: WPARAM; LP: LPARAM): LRESULT; stdcall;
var
  Block: Boolean;
begin
  case Msg of
    WM_MOUSEACTIVATE:
      Result := MA_NOACTIVATE;

    WM_NCHITTEST:
      begin
        Block := (GetWindowLongPtr(Wnd, GWLP_USERDATA) and 1) = 1;
        if Block then
          Result := HTCLIENT
        else
          Result := HTTRANSPARENT;
      end;

    WM_LBUTTONDOWN, WM_RBUTTONDOWN, WM_MBUTTONDOWN:
      begin
        MessageBeep(MB_OK);
        Result := 0;
      end;
  else
    Result := DefWindowProc(Wnd, Msg, WP, LP);
  end;
end;

procedure EnsureClassRegistered;
var
  WC: TWndClass;
begin
  if GClassRegistered then
    Exit;

  FillChar(WC, SizeOf(WC), 0);
  WC.lpfnWndProc   := @OverlayWndProc;
  WC.hInstance      := HInstance;
  WC.hCursor        := LoadCursor(0, IDC_ARROW);
  WC.hbrBackground  := 0;
  WC.lpszClassName  := OVERLAY_CLASS_NAME;

  if Winapi.Windows.RegisterClass(WC) <> 0 then
    GClassRegistered := True;
end;

{ ============================================================================ }
{  TCWSDimOverlay                                                              }
{ ============================================================================ }

constructor TCWSDimOverlay.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FVisible        := False;
  FOpacity        := 128;
  FColor          := clBlack;
  FOverlayWnd     := 0;
  FHooked         := False;
  FPresented      := False;
  FAnimated       := True;
  FAnimationSteps := 10;
  FCornerRadius   := 0;
  FBlockClicks    := True;

  FShowActivityIndicator := False;
  FIndicatorStyle        := cisLines;
  FIndicatorColor        := clWhite;
  FIndicatorTrackColor   := clGray;
  FIndicatorSize         := 48;
  FIndicatorSegmentCount := 12;
  FIndicatorGap          := 4;
  FIndicatorSpeed        := 300;
  FPhase                 := 0;
  FText                  := '';

  FTextFont := TFont.Create;
  FTextFont.Color := clWhite;
  FTextFont.Size  := 10;
  FTextFont.OnChange := TextFontChanged;

  FRenderLock := TCriticalSection.Create;
  FAnimThread := nil;
end;

destructor TCWSDimOverlay.Destroy;
begin
  DestroyOverlayWindow;   // stops and waits for the spinner thread
  UnhookParentForm;
  FTextFont.Free;
  FRenderLock.Free;
  inherited Destroy;
end;

procedure TCWSDimOverlay.Loaded;
begin
  inherited Loaded;
  if csDesigning in ComponentState then
    Exit;

  HookParentForm;

  if FVisible then
    CreateOverlayWindow;
end;

function TCWSDimOverlay.GetParentForm: TCustomForm;
begin
  if Owner is TCustomForm then
    Result := TCustomForm(Owner)
  else
    Result := nil;
end;

{ --- Get the visual rect of the form (without the DWM shadow) --- }

function TCWSDimOverlay.GetFormVisualRect(AForm: TCustomForm): TRect;
var
  HR: HRESULT;
begin
  // DWMWA_EXTENDED_FRAME_BOUNDS returns the window rect WITHOUT the shadow
  LoadDwmApi;
  if Assigned(GDwmGetWindowAttribute) and AForm.HandleAllocated then
  begin
    HR := GDwmGetWindowAttribute(AForm.Handle, DWMWA_EXTENDED_FRAME_BOUNDS,
      @Result, SizeOf(Result));
    if Succeeded(HR) then
      Exit;
  end;

  // Fallback - classic GetWindowRect (includes the shadow on Win10/11)
  GetWindowRect(AForm.Handle, Result);
end;

{ --- Is the form's final position still pending? ---
  True while the form is in its first show sequence (fsShowing) AND still carries
  a centering Position. VCL applies the centering only after OnShow returns
  (TCustomForm.CMShowingChanged), resetting Position to poDesigned afterwards, so
  during OnShow the form's final on-screen position is not yet known. In that
  window the overlay must wait before becoming visible. }

function TCWSDimOverlay.FormPositionPending(AForm: TCustomForm): Boolean;
begin
  Result := (AForm <> nil) and (fsShowing in AForm.FormState) and
    (TFormAccess(AForm).Position in [poScreenCenter, poMainFormCenter,
                                     poOwnerFormCenter, poDesktopCenter]);
end;

{ --- Windows 11 detection and corner radius --- }

function TCWSDimOverlay.IsWindows11OrLater: Boolean;
var
  OSVersion: TOSVersionInfoEx;
  RtlGetVersion: function(var lpVersionInfo: TOSVersionInfoEx): LONG; stdcall;
  NtDll: HMODULE;
begin
  Result := False;
  FillChar(OSVersion, SizeOf(OSVersion), 0);
  OSVersion.dwOSVersionInfoSize := SizeOf(OSVersion);

  NtDll := GetModuleHandle('ntdll.dll');
  if NtDll <> 0 then
  begin
    @RtlGetVersion := GetProcAddress(NtDll, 'RtlGetVersion');
    if Assigned(RtlGetVersion) then
    begin
      RtlGetVersion(OSVersion);
      Result := (OSVersion.dwMajorVersion > 10) or
                ((OSVersion.dwMajorVersion = 10) and (OSVersion.dwBuildNumber >= 22000));
    end;
  end;
end;

function TCWSDimOverlay.DetectCornerRadius: Integer;
var
  Form: TCustomForm;
  CornerPref: Cardinal;
  HR: HRESULT;
begin
  if FCornerRadius > 0 then
    Exit(FCornerRadius);

  if not IsWindows11OrLater then
    Exit(0);

  LoadDwmApi;
  Form := GetParentForm;

  if Assigned(GDwmGetWindowAttribute) and (Form <> nil) and Form.HandleAllocated then
  begin
    CornerPref := 0;
    HR := GDwmGetWindowAttribute(Form.Handle, DWMWA_WINDOW_CORNER_PREFERENCE,
      @CornerPref, SizeOf(CornerPref));

    if Succeeded(HR) then
    begin
      case CornerPref of
        DWMWCP_DONOTROUND:
          Exit(0);
        DWMWCP_ROUNDSMALL:
          Exit(W11_CORNER_RADIUS_SMALL);
      end;
    end;
  end;

  Result := W11_CORNER_RADIUS;
end;

{ --- Hook into the form's WndProc --- }

procedure TCWSDimOverlay.HookParentForm;
var
  Form: TCustomForm;
begin
  if FHooked or (csDesigning in ComponentState) then
    Exit;

  Form := GetParentForm;
  if Form = nil then
    Exit;

  FOldParentWndProc := Form.WindowProc;
  Form.WindowProc   := ParentWndProc;
  FHooked := True;
end;

procedure TCWSDimOverlay.UnhookParentForm;
var
  Form: TCustomForm;
begin
  if not FHooked then
    Exit;

  Form := GetParentForm;
  if (Form <> nil) and Assigned(FOldParentWndProc) then
    Form.WindowProc := FOldParentWndProc;

  FOldParentWndProc := nil;
  FHooked := False;
end;

procedure TCWSDimOverlay.ParentWndProc(var Message: TMessage);
begin
  if Assigned(FOldParentWndProc) then
    FOldParentWndProc(Message);

  if FOverlayWnd = 0 then
    Exit;

  case Message.Msg of
    WM_SIZE, WM_MOVE, WM_WINDOWPOSCHANGED:
      UpdateOverlayBounds;

    WM_ACTIVATE:
      // Only raise / show the overlay once it has actually been presented.
      // While the present is still deferred (Visible set from the form's
      // OnShow) the window is intentionally hidden; SWP_SHOWWINDOW here would
      // flash the opaque dim before PresentOverlay fades it in.
      if FPresented and (LoWord(Message.WParam) <> WA_INACTIVE) then
        SetWindowPos(FOverlayWnd, HWND_TOP, 0, 0, 0, 0,
          SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);
  end;
end;

{ --- Create / destroy the overlay window --- }

procedure TCWSDimOverlay.CreateOverlayWindow;
var
  Form: TCustomForm;
  R: TRect;
  UserData: NativeInt;
  CornerPref: Cardinal;
begin
  if FOverlayWnd <> 0 then
    Exit;

  Form := GetParentForm;
  if (Form = nil) or not Form.HandleAllocated then
    Exit;

  EnsureClassRegistered;
  LoadDwmApi;

  // Use the visual rect (without the DWM shadow)
  R := GetFormVisualRect(Form);

  FOverlayWnd := CreateWindowEx(
    WS_EX_LAYERED or WS_EX_TOOLWINDOW or WS_EX_NOACTIVATE,
    OVERLAY_CLASS_NAME,
    nil,
    WS_POPUP,
    R.Left, R.Top,
    R.Right - R.Left, R.Bottom - R.Top,
    Form.Handle,
    0,
    HInstance,
    nil
  );

  if FOverlayWnd = 0 then
    Exit;

  // window exists but is still hidden; it must not be shown / fully presented
  // until PresentOverlay runs (possibly deferred while the form is centering)
  FPresented := False;

  UserData := Ord(FBlockClicks);
  SetWindowLongPtr(FOverlayWnd, GWLP_USERDATA, UserData);

  if Assigned(GDwmSetWindowAttribute) then
  begin
    CornerPref := DWMWCP_DONOTROUND;
    GDwmSetWindowAttribute(FOverlayWnd, DWMWA_WINDOW_CORNER_PREFERENCE,
      @CornerPref, SizeOf(CornerPref));
  end;

  ApplyWindowRegion;

  FPhase := 0;

  // When Show is triggered from the form's OnShow, VCL has not yet applied a
  // centering Position (poMainFormCenter / poScreenCenter / ...): the form is
  // centered only after OnShow returns, in TCustomForm.CMShowingChanged.
  // Presenting now would flash the overlay at the form's pre-centered (default)
  // position and only then move it over the centered form. In that case defer
  // the present to the message queue - by the time it runs the form has been
  // centered, so the overlay appears directly at its final position. When the
  // form is already shown (the typical loader case, where the caller then
  // blocks the main thread) present synchronously, so the overlay is visible
  // immediately without needing the message loop to spin.
  if FormPositionPending(Form) then
    TThread.ForceQueue(nil, PresentOverlay)
  else
    PresentOverlay;
end;

{ --- Make the overlay visible at the form's final position ---
  Separated from CreateOverlayWindow so it can be invoked either synchronously
  or (while the form is still being centered) deferred via the message queue. }

procedure TCWSDimOverlay.PresentOverlay;
begin
  if FOverlayWnd = 0 then
    Exit;

  // Sync to the form's (now final) position before becoming visible.
  RepositionToForm;

  // from here on the window may be shown and fully presented; the parent's
  // activate / move handlers are allowed to raise and refresh it
  FPresented := True;

  if FAnimated then
  begin
    ApplyLayeredBitmap(0);
    ShowWindow(FOverlayWnd, SW_SHOWNOACTIVATE);
    DoAnimateShow;
  end
  else
  begin
    ApplyLayeredBitmap(255);
    ShowWindow(FOverlayWnd, SW_SHOWNOACTIVATE);
  end;

  UpdateTimerState;
end;

procedure TCWSDimOverlay.DestroyOverlayWindow;
begin
  StopSpinner;   // thread no longer touches the buffer after this

  FPresented := False;

  if FOverlayWnd <> 0 then
  begin
    DestroyWindow(FOverlayWnd);
    FOverlayWnd := 0;
  end;

  FreeBuffer;
end;

{ --- Region with rounded corners --- }

procedure TCWSDimOverlay.ApplyWindowRegion;
var
  R: TRect;
  W, H: Integer;
  Radius: Integer;
  Rgn: HRGN;
begin
  if FOverlayWnd = 0 then
    Exit;

  Radius := DetectCornerRadius;
  if Radius <= 0 then
  begin
    SetWindowRgn(FOverlayWnd, 0, True);
    Exit;
  end;

  GetWindowRect(FOverlayWnd, R);
  W := R.Right - R.Left;
  H := R.Bottom - R.Top;

  Rgn := CreateRoundRectRgn(0, 0, W + 1, H + 1, Radius * 2, Radius * 2);
  if Rgn <> 0 then
    SetWindowRgn(FOverlayWnd, Rgn, True);
end;

{ --- Persistent back buffer ---
  A single top-down 32bpp DIB the size of the overlay window, kept alive across
  frames and reused. It is (re)created only when the window size changes, so the
  60 fps spinner loop never allocates and never re-renders the whole surface. }

procedure TCWSDimOverlay.EnsureBuffer(AWidth, AHeight: Integer);
var
  ScreenDC: HDC;
  BmpInfo: TBitmapInfo;
begin
  if (FBufDC <> 0) and (AWidth = FBufW) and (AHeight = FBufH) then
    Exit;   // already the right size

  FreeBuffer;
  if (AWidth <= 0) or (AHeight <= 0) then
    Exit;

  ScreenDC := GetDC(0);
  try
    FBufDC := CreateCompatibleDC(ScreenDC);

    FillChar(BmpInfo, SizeOf(BmpInfo), 0);
    BmpInfo.bmiHeader.biSize        := SizeOf(TBitmapInfoHeader);
    BmpInfo.bmiHeader.biWidth       := AWidth;
    BmpInfo.bmiHeader.biHeight      := -AHeight;   // top-down DIB
    BmpInfo.bmiHeader.biPlanes      := 1;
    BmpInfo.bmiHeader.biBitCount    := 32;
    BmpInfo.bmiHeader.biCompression := BI_RGB;

    FBufBits := nil;
    FBufDIB := CreateDIBSection(ScreenDC, BmpInfo, DIB_RGB_COLORS, FBufBits, 0, 0);
    if (FBufDIB <> 0) and (FBufBits <> nil) then
    begin
      FBufOldBmp := SelectObject(FBufDC, FBufDIB);
      FBufW := AWidth;
      FBufH := AHeight;
    end
    else
    begin
      if FBufDIB <> 0 then
        DeleteObject(FBufDIB);
      FBufDIB := 0;
      DeleteDC(FBufDC);
      FBufDC := 0;
      FBufBits := nil;
    end;
  finally
    ReleaseDC(0, ScreenDC);
  end;
end;

procedure TCWSDimOverlay.FreeBuffer;
begin
  if FBufDC <> 0 then
  begin
    if FBufOldBmp <> 0 then
      SelectObject(FBufDC, FBufOldBmp);
    DeleteDC(FBufDC);
    FBufDC := 0;
  end;
  if FBufDIB <> 0 then
  begin
    DeleteObject(FBufDIB);
    FBufDIB := 0;
  end;
  FBufOldBmp := 0;
  FBufBits   := nil;
  FBufW      := 0;
  FBufH      := 0;
end;

{ --- Draw the bitmap onto the layered window ---
  The dim level (FOpacity) is baked into the per-pixel alpha of the buffer,
  while AGlobalAlpha is the layered window's constant alpha used only for the
  fade-in / fade-out animation (255 = fully shown). This lets the spinner and
  the text keep their own (full) opacity on top of the semi-transparent dim.

  ApplyLayeredBitmap does a FULL render + full upload; it is used on show,
  resize and property changes. The 60 fps spinner loop uses ApplySpinnerFrame,
  which repaints and re-uploads only the spinner's bounding box. }

procedure TCWSDimOverlay.ApplyLayeredBitmap(AGlobalAlpha: Byte);
begin
  // Serialise rendering: the spinner thread and the main thread may both render
  // into the shared buffer / call UpdateLayeredWindow on the same window.
  FRenderLock.Enter;
  try
    DoPresentFull(AGlobalAlpha);
  finally
    FRenderLock.Leave;
  end;
end;

procedure TCWSDimOverlay.DoPresentFull(AGlobalAlpha: Byte);
var
  R: TRect;
  W, H: Integer;
  BF: TBlendFunction;
  Pt, SrcPt: TPoint;
  Sz: TSize;
begin
  if FOverlayWnd = 0 then
    Exit;

  GetWindowRect(FOverlayWnd, R);
  W := R.Right - R.Left;
  H := R.Bottom - R.Top;
  if (W <= 0) or (H <= 0) then
    Exit;

  EnsureBuffer(W, H);
  if FBufBits = nil then
    Exit;

  // render the whole surface (dim + spinner + text); this also refreshes the
  // cached spinner bounding box used by ApplySpinnerFrame
  RenderToBuffer(FBufBits, W, H);

  BF.BlendOp             := AC_SRC_OVER;
  BF.BlendFlags          := 0;
  BF.SourceConstantAlpha := AGlobalAlpha;
  BF.AlphaFormat         := AC_SRC_ALPHA;

  Pt := Point(R.Left, R.Top);
  SrcPt := Point(0, 0);
  Sz.cx := W;
  Sz.cy := H;

  UpdateLayeredWindow(FOverlayWnd, 0, @Pt, @Sz, FBufDC, @SrcPt, 0, @BF, ULW_ALPHA);
end;

{ --- One spinner frame ---
  Repaints only the cached spinner box into the persistent buffer and uploads
  just that rectangle (prcDirty). The dim background and text stay untouched
  from the last full render, so cost is independent of the form's resolution. }

procedure TCWSDimOverlay.ApplySpinnerFrame;
var
  R, Box: TRect;
  W, H: Integer;
  BF: TBlendFunction;
  Pt, SrcPt: TPoint;
  Sz: TSize;
  ULW: TUpdateLayeredWindowInfo;
begin
  FRenderLock.Enter;
  try
    if FOverlayWnd = 0 then
      Exit;

    GetWindowRect(FOverlayWnd, R);
    W := R.Right - R.Left;
    H := R.Bottom - R.Top;
    if (W <= 0) or (H <= 0) then
      Exit;

    // Fall back to a full present if the buffer is missing, the size changed
    // (resize in flight) or no spinner box has been cached yet (first frame).
    if (FBufBits = nil) or (W <> FBufW) or (H <> FBufH) or FSpinnerRect.IsEmpty then
    begin
      DoPresentFull(255);
      Exit;
    end;

    Box := FSpinnerRect;
    RenderSpinnerBox(Box);

    BF.BlendOp             := AC_SRC_OVER;
    BF.BlendFlags          := 0;
    BF.SourceConstantAlpha := 255;
    BF.AlphaFormat         := AC_SRC_ALPHA;

    Pt := Point(R.Left, R.Top);
    SrcPt := Point(0, 0);
    Sz.cx := W;
    Sz.cy := H;

    FillChar(ULW, SizeOf(ULW), 0);
    ULW.cbSize   := SizeOf(ULW);
    ULW.hdcDst   := 0;
    ULW.pptDst   := @Pt;
    ULW.psize    := @Sz;
    ULW.hdcSrc   := FBufDC;
    ULW.pptSrc   := @SrcPt;
    ULW.crKey    := 0;
    ULW.pblend   := @BF;
    ULW.dwFlags  := ULW_ALPHA;
    ULW.prcDirty := @Box;
    UpdateLayeredWindowIndirect(FOverlayWnd, ULW);
  finally
    FRenderLock.Leave;
  end;
end;

{ --- GDI+ rendering into the premultiplied ARGB buffer --- }

procedure TCWSDimOverlay.RenderToBuffer(ABits: Pointer; AWidth, AHeight: Integer);
var
  GpBmp: TGPBitmap;
  G: TGPGraphics;
  Data: TBitmapData;
  cr: LongInt;
  y, RowBytes: Integer;
begin
  GpBmp := TGPBitmap.Create(AWidth, AHeight, PixelFormat32bppARGB);
  try
    G := TGPGraphics.Create(GpBmp);
    try
      G.SetSmoothingMode(SmoothingModeAntiAlias);
      G.SetTextRenderingHint(TextRenderingHintAntiAlias);

      // dim background (alpha baked per pixel)
      cr := ColorToRGB(FColor);
      G.Clear(MakeColor(FOpacity, GetRValue(cr), GetGValue(cr), GetBValue(cr)));

      DrawContent(G, AWidth, AHeight);
    finally
      G.Free;
    end;

    // copy premultiplied ARGB pixels into the layered window's DIB
    RowBytes := AWidth * 4;
    if GpBmp.LockBits(MakeRect(0, 0, AWidth, AHeight), ImageLockModeRead,
         PixelFormat32bppPARGB, Data) = Ok then
    begin
      for y := 0 to AHeight - 1 do
        Move(PByte(NativeUInt(Data.Scan0) + NativeUInt(y) * NativeUInt(Data.Stride))^,
             PByte(NativeUInt(ABits) + NativeUInt(y) * NativeUInt(RowBytes))^,
             RowBytes);
      GpBmp.UnlockBits(Data);
    end;
  finally
    GpBmp.Free;
  end;
end;

{ --- Render only the spinner box into the persistent buffer ---
  Refills just ABox with the dim background and redraws the rotated spinner,
  then copies that small premultiplied region into the persistent DIB. Called
  ~60 times per second, so the work is bounded by the spinner size, not the
  form resolution. }

procedure TCWSDimOverlay.RenderSpinnerBox(const ABox: TRect);
var
  GpBmp: TGPBitmap;
  G: TGPGraphics;
  Data: TBitmapData;
  cr: LongInt;
  bw, bh, y, RowBytes, DstStride: Integer;
begin
  bw := ABox.Right - ABox.Left;
  bh := ABox.Bottom - ABox.Top;
  if (bw <= 0) or (bh <= 0) or (FBufBits = nil) then
    Exit;

  GpBmp := TGPBitmap.Create(bw, bh, PixelFormat32bppARGB);
  try
    G := TGPGraphics.Create(GpBmp);
    try
      G.SetSmoothingMode(SmoothingModeAntiAlias);

      // repaint the dim background for this box, then the rotated spinner
      // (translate the center into the box-local coordinate system)
      cr := ColorToRGB(FColor);
      G.Clear(MakeColor(FOpacity, GetRValue(cr), GetGValue(cr), GetBValue(cr)));
      DrawSpinner(G, FSpinnerCenterX - ABox.Left, FSpinnerCenterY - ABox.Top,
        FIndicatorSize);
    finally
      G.Free;
    end;

    if GpBmp.LockBits(MakeRect(0, 0, bw, bh), ImageLockModeRead,
         PixelFormat32bppPARGB, Data) = Ok then
    begin
      RowBytes  := bw * 4;
      DstStride := FBufW * 4;
      for y := 0 to bh - 1 do
        Move(PByte(NativeUInt(Data.Scan0) + NativeUInt(y) * NativeUInt(Data.Stride))^,
             PByte(NativeUInt(FBufBits) +
                   NativeUInt(ABox.Top + y) * NativeUInt(DstStride) +
                   NativeUInt(ABox.Left) * 4)^,
             RowBytes);
      GpBmp.UnlockBits(Data);
    end;
  finally
    GpBmp.Free;
  end;
end;

{ --- Lay out and draw the spinner and the text --- }

procedure TCWSDimOverlay.DrawContent(G: TGPGraphics; AWidth, AHeight: Integer);
var
  HasInd, HasText: Boolean;
  CenterX, CenterY: Single;
  IndSize, Gap, BlockTop, IndTop, TextTop, TextH, SCY, M: Single;
  Font: TGPFont;
  Fmt: TGPStringFormat;
  Brush: TGPSolidBrush;
  LayoutRect, Measured: TGPRectF;
  WS: WideString;
  ScreenDC: HDC;
  cr: LongInt;
begin
  FSpinnerRect := TRect.Empty;   // no spinner unless we draw one below

  HasInd  := FShowActivityIndicator;
  HasText := FText <> '';
  if not (HasInd or HasText) then
    Exit;

  CenterX := AWidth / 2;
  CenterY := AHeight / 2;
  IndSize := FIndicatorSize;
  Gap     := Max(8.0, FIndicatorSize * 0.25);

  Font := nil;
  Fmt  := nil;
  TextH := 0;
  try
    if HasText then
    begin
      WS := FText;
      ScreenDC := GetDC(0);
      try
        Font := TGPFont.Create(ScreenDC, FTextFont.Handle);
      finally
        ReleaseDC(0, ScreenDC);
      end;

      Fmt := TGPStringFormat.Create;
      Fmt.SetAlignment(StringAlignmentCenter);
      Fmt.SetLineAlignment(StringAlignmentNear);

      LayoutRect := MakeRect(0.0, 0.0, AWidth - 2.0 * TEXT_MARGIN, Single(AHeight));
      G.MeasureString(PWideChar(WS), -1, Font, LayoutRect, Fmt, Measured);
      TextH := Measured.Height;
    end;

    // vertical layout
    IndTop  := CenterY - IndSize / 2;
    TextTop := CenterY - TextH / 2;
    if HasInd and HasText then
    begin
      BlockTop := CenterY - (IndSize + Gap + TextH) / 2;
      IndTop   := BlockTop;
      TextTop  := BlockTop + IndSize + Gap;
    end;

    if HasInd then
    begin
      SCY := IndTop + IndSize / 2;
      FSpinnerCenterX := CenterX;
      FSpinnerCenterY := SCY;
      // cache the spinner's bounding box (+ AA / round-cap margin) so the
      // spinner thread can repaint only this region
      M := IndSize * 0.08 + 4;
      FSpinnerRect := Rect(
        Max(0, Floor(CenterX - IndSize / 2 - M)),
        Max(0, Floor(SCY - IndSize / 2 - M)),
        Min(AWidth,  Ceil(CenterX + IndSize / 2 + M)),
        Min(AHeight, Ceil(SCY + IndSize / 2 + M)));
      DrawSpinner(G, CenterX, SCY, IndSize);
    end;

    if HasText then
    begin
      cr := ColorToRGB(FTextFont.Color);
      Brush := TGPSolidBrush.Create(
        MakeColor(255, GetRValue(cr), GetGValue(cr), GetBValue(cr)));
      try
        LayoutRect := MakeRect(Single(TEXT_MARGIN), TextTop,
          AWidth - 2.0 * TEXT_MARGIN, TextH + 4);
        G.DrawString(PWideChar(WS), -1, Font, LayoutRect, Fmt, Brush);
      finally
        Brush.Free;
      end;
    end;
  finally
    Fmt.Free;
    Font.Free;
  end;
end;

{ Blend between the track color (AFrac = 0) and the active color (AFrac = 1),
  always fully opaque. Used to give the spinner its two-tone look. }
function BlendColor(ATrack, AActive: LongInt; AFrac: Single): Cardinal;
var
  R, G, B: Byte;
begin
  if AFrac < 0 then
    AFrac := 0
  else if AFrac > 1 then
    AFrac := 1;
  R := Byte(Round(Integer(GetRValue(ATrack)) +
        (Integer(GetRValue(AActive)) - Integer(GetRValue(ATrack))) * AFrac));
  G := Byte(Round(Integer(GetGValue(ATrack)) +
        (Integer(GetGValue(AActive)) - Integer(GetGValue(ATrack))) * AFrac));
  B := Byte(Round(Integer(GetBValue(ATrack)) +
        (Integer(GetBValue(AActive)) - Integer(GetBValue(ATrack))) * AFrac));
  Result := MakeColor(255, R, G, B);
end;

{ --- Activity indicator (transparent background) ---
  T is the rotation phase in 0..1 (one full turn). The discrete styles colour
  their segments from the active color at the rotating "head" down to the
  track color at the tail; the ring style sweeps an arc over a full track. }

{ Continuous "comet tail" brightness for element I out of N, given a fractional
  head position (0..N). Returns 1 at the head (IndicatorColor), fading to ~0
  (IndicatorTrackColor) along the tail that trails BEHIND the head in the
  direction of rotation. Using a fractional head (instead of a rounded integer)
  lets the brightness of each element change smoothly over time, so the rotation
  looks fluid rather than stepping one element per frame. }
function TrailFrac(I, N: Integer; AHeadPos: Single): Single;
var
  RelF: Single;
begin
  RelF := AHeadPos - I;                 // tail trails behind the head
  RelF := RelF - Floor(RelF / N) * N;   // wrap into [0, N)
  Result := 1 - RelF / N;
end;

procedure TCWSDimOverlay.DrawSpinner(G: TGPGraphics; ACenterX, ACenterY, ASize: Single);
var
  T: Single;
begin
  T := FPhase;
  case FIndicatorStyle of
    cisRing:      DrawIndicatorRing(G, ACenterX, ACenterY, ASize, T);
    cisSegmented: DrawIndicatorSegmented(G, ACenterX, ACenterY, ASize, T);
    cisArrows:    DrawIndicatorArrows(G, ACenterX, ACenterY, ASize, T);
  else
    DrawIndicatorLines(G, ACenterX, ACenterY, ASize, T);
  end;
end;

{ Style: radial lines, active color fading to track color.
  The line thickness is derived from the slot width and the requested gap,
  so the gap between neighbouring lines is constant. }
procedure TCWSDimOverlay.DrawIndicatorLines(G: TGPGraphics; CX, CY, ASize, T: Single);
var
  N, I: Integer;
  Inner, Outer, PenW, SlotOuter, Ang, X1, Y1, X2, Y2, Frac, HeadPos: Single;
  ActiveCr, TrackCr: LongInt;
  Pen: TGPPen;
begin
  N        := FIndicatorSegmentCount;
  Outer    := ASize * 0.50;
  Inner    := ASize * 0.24;
  ActiveCr := ColorToRGB(FIndicatorColor);
  TrackCr  := ColorToRGB(FIndicatorTrackColor);

  SlotOuter := 2 * Pi * Outer / N;        // tangential space per line at outer
  PenW := SlotOuter - FIndicatorGap;      // keep a constant gap between lines
  if PenW < 1.5 then
    PenW := 1.5;
  if PenW > ASize * 0.075 then            // keep them thin / line-like
    PenW := ASize * 0.075;

  // round caps reach beyond the endpoints, so pull the ends in by half a width
  Outer   := Outer - PenW / 2;
  Inner   := Inner + PenW / 2;
  HeadPos := T * N;

  for I := 0 to N - 1 do
  begin
    Frac := TrailFrac(I, N, HeadPos);     // 1 at head, fading around the ring
    Ang  := (I / N) * 2 * Pi - Pi / 2;
    X1 := CX + Inner * Cos(Ang);
    Y1 := CY + Inner * Sin(Ang);
    X2 := CX + Outer * Cos(Ang);
    Y2 := CY + Outer * Sin(Ang);

    Pen := TGPPen.Create(BlendColor(TrackCr, ActiveCr, Frac), PenW);
    try
      Pen.SetStartCap(LineCapRound);
      Pen.SetEndCap(LineCapRound);
      G.DrawLine(Pen, X1, Y1, X2, Y2);
    finally
      Pen.Free;
    end;
  end;
end;

{ Style: donut ring with a rotating active arc over a full track ring }
procedure TCWSDimOverlay.DrawIndicatorRing(G: TGPGraphics; CX, CY, ASize, T: Single);
const
  SWEEP = 270.0;
var
  PenW, R, StartAngle: Single;
  Pen: TGPPen;
  ActiveCr, TrackCr: LongInt;
begin
  ActiveCr := ColorToRGB(FIndicatorColor);
  TrackCr  := ColorToRGB(FIndicatorTrackColor);
  PenW := Max(3.0, ASize * 0.12);
  R    := ASize * 0.5 - PenW / 2;

  // background track ring
  Pen := TGPPen.Create(
    MakeColor(255, GetRValue(TrackCr), GetGValue(TrackCr), GetBValue(TrackCr)), PenW);
  try
    G.DrawEllipse(Pen, CX - R, CY - R, 2 * R, 2 * R);
  finally
    Pen.Free;
  end;

  // rotating foreground arc
  StartAngle := T * 360 - 90;
  Pen := TGPPen.Create(
    MakeColor(255, GetRValue(ActiveCr), GetGValue(ActiveCr), GetBValue(ActiveCr)), PenW);
  try
    Pen.SetStartCap(LineCapRound);
    Pen.SetEndCap(LineCapRound);
    G.DrawArc(Pen, CX - R, CY - R, 2 * R, 2 * R, StartAngle, SWEEP);
  finally
    Pen.Free;
  end;
end;

{ Style: thick donut segments (blocks), active color fading to track color.
  Each block is an annular sector whose radial sides are inset by a constant
  pixel distance (IndicatorGap / 2). Because the same linear inset is a larger
  angle near the inner radius, the block is wider at the outer edge and
  narrower at the inner edge - which keeps the gap exactly equal in width. }
procedure TCWSDimOverlay.DrawIndicatorSegmented(G: TGPGraphics; CX, CY, ASize, T: Single);
const
  RAD2DEG = 180 / Pi;
var
  N, I: Integer;
  Outer, Inner, Thick, SegAngle, GapO, GapI, Base, Frac, HeadPos: Single;
  ActiveCr, TrackCr: LongInt;
  Brush: TGPSolidBrush;
  Path: TGPGraphicsPath;
begin
  N        := FIndicatorSegmentCount;
  ActiveCr := ColorToRGB(FIndicatorColor);
  TrackCr  := ColorToRGB(FIndicatorTrackColor);
  Outer    := ASize * 0.50;
  Thick    := ASize * 0.20;
  Inner    := Outer - Thick;
  SegAngle := 360 / N;

  // constant-width gap -> angular inset differs at inner vs. outer radius
  GapO := (FIndicatorGap / 2) / Outer * RAD2DEG;
  GapI := (FIndicatorGap / 2) / Inner * RAD2DEG;
  if GapO > SegAngle * 0.45 then GapO := SegAngle * 0.45;
  if GapI > SegAngle * 0.45 then GapI := SegAngle * 0.45;

  HeadPos := T * N;

  for I := 0 to N - 1 do
  begin
    Frac := TrailFrac(I, N, HeadPos);
    Base := I * SegAngle - 90;

    Path := TGPGraphicsPath.Create;
    try
      // outer edge: left -> right
      Path.AddArc(CX - Outer, CY - Outer, 2 * Outer, 2 * Outer,
        Base + GapO, SegAngle - 2 * GapO);
      // inner edge: right -> left (reverse) - the connecting lines form the
      // slanted radial sides that keep the gap a constant width
      Path.AddArc(CX - Inner, CY - Inner, 2 * Inner, 2 * Inner,
        Base + SegAngle - GapI, -(SegAngle - 2 * GapI));
      Path.CloseFigure;

      Brush := TGPSolidBrush.Create(BlendColor(TrackCr, ActiveCr, Frac));
      try
        G.FillPath(Brush, Path);
      finally
        Brush.Free;
      end;
    finally
      Path.Free;
    end;
  end;
end;

{ Style: arrows (chevrons) chasing clockwise around the ring.
  Each arrow is a constant-thickness ">" chevron with a blunt tip. The leading
  and trailing edges are both ">"-shaped and parallel, offset by the gap, so
  the tip of one arrow nests into the concave back of the next. The Tip value
  controls how far the point reaches forward (smaller = blunter). }
procedure TCWSDimOverlay.DrawIndicatorArrows(G: TGPGraphics; CX, CY, ASize, T: Single);
const
  RAD2DEG = 180 / Pi;
var
  N, I: Integer;
  Outer, Inner, Mid, Thick, SegAngle, Tip, Frac, Center, ArmO, ArmM, ArmI, HeadPos: Single;
  Pts: array[0..5] of TGPPointF;
  Brush: TGPSolidBrush;
  ActiveCr, TrackCr: LongInt;

  function Polar(ADeg, ARad: Single): TGPPointF;
  var
    Rad: Single;
  begin
    Rad := ADeg * (Pi / 180);
    Result := MakePoint(CX + ARad * Cos(Rad), CY + ARad * Sin(Rad));
  end;

begin
  N        := FIndicatorSegmentCount;
  ActiveCr := ColorToRGB(FIndicatorColor);
  TrackCr  := ColorToRGB(FIndicatorTrackColor);
  Outer    := ASize * 0.50;
  Thick    := ASize * 0.20;
  Inner    := Outer - Thick;
  Mid      := (Outer + Inner) / 2;
  SegAngle := 360 / N;

  // Keep the gap a constant pixel width at every radius: the angular half-width
  // of the chevron is larger at the outer radius and smaller at the inner one,
  // so the gap between neighbouring arrows stays equal (not wider on the
  // outside). Same trick as the segmented blocks.
  ArmO := (SegAngle - FIndicatorGap / Outer * RAD2DEG) / 2;
  ArmM := (SegAngle - FIndicatorGap / Mid   * RAD2DEG) / 2;
  ArmI := (SegAngle - FIndicatorGap / Inner * RAD2DEG) / 2;
  if ArmO < SegAngle * 0.04 then ArmO := SegAngle * 0.04;
  if ArmM < SegAngle * 0.04 then ArmM := SegAngle * 0.04;
  if ArmI < SegAngle * 0.04 then ArmI := SegAngle * 0.04;
  Tip := SegAngle * 0.28;             // forward reach of the tip (blunt point)

  HeadPos := T * N;

  for I := 0 to N - 1 do
  begin
    Frac := TrailFrac(I, N, HeadPos);

    Center := I * SegAngle - 90 + SegAngle / 2;

    Pts[0] := Polar(Center + ArmO, Outer);        // leading outer
    Pts[1] := Polar(Center + ArmM + Tip, Mid);    // leading tip (blunt point)
    Pts[2] := Polar(Center + ArmI, Inner);        // leading inner
    Pts[3] := Polar(Center - ArmI, Inner);        // trailing inner
    Pts[4] := Polar(Center - ArmM + Tip, Mid);    // trailing notch tip
    Pts[5] := Polar(Center - ArmO, Outer);        // trailing outer

    Brush := TGPSolidBrush.Create(BlendColor(TrackCr, ActiveCr, Frac));
    try
      G.FillPolygon(Brush, PGPPointF(@Pts[0]), 6);
    finally
      Brush.Free;
    end;
  end;
end;

procedure TCWSDimOverlay.UpdateOverlayBounds;
var
  Form: TCustomForm;
  R: TRect;
begin
  if FOverlayWnd = 0 then
    Exit;

  Form := GetParentForm;
  if Form = nil then
    Exit;

  // Visual rect without the shadow
  R := GetFormVisualRect(Form);
  MoveWindow(FOverlayWnd, R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top, False);

  ApplyWindowRegion;

  // Keep the position/region synced while the form is still being centered
  // (present deferred), but do NOT render the opaque dim yet - PresentOverlay
  // will set the correct (faded) content when it runs. Presenting at full
  // opacity here is what made the overlay flash once on show.
  if FPresented then
    ApplyLayeredBitmap(255);
end;

{ --- Lightweight reposition (no repaint) ---
  Used during the fade-in to keep the overlay glued to the form while VCL is
  still moving the form to its final position (poScreenCenter / poMainFormCenter).
  Only moves the window and re-applies the rounded region; the caller paints the
  current animation frame afterwards. }

procedure TCWSDimOverlay.RepositionToForm;
var
  Form: TCustomForm;
  R: TRect;
begin
  if FOverlayWnd = 0 then
    Exit;

  Form := GetParentForm;
  if Form = nil then
    Exit;

  R := GetFormVisualRect(Form);
  MoveWindow(FOverlayWnd, R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top, False);
  ApplyWindowRegion;
end;

{ --- Animation --- }

procedure TCWSDimOverlay.DoAnimateShow;
var
  I, Steps: Integer;
  Alpha: Byte;
begin
  Steps := FAnimationSteps;
  if Steps <= 0 then
    Steps := 1;

  for I := 1 to Steps do
  begin
    Alpha := Byte(MulDiv(255, I, Steps));
    // Keep the overlay glued to the form: when Show is triggered from the
    // form's OnShow, VCL may still be centering the form during these steps.
    RepositionToForm;
    ApplyLayeredBitmap(Alpha);
    Sleep(12);
    Application.ProcessMessages;
  end;

  RepositionToForm;
  ApplyLayeredBitmap(255);
end;

procedure TCWSDimOverlay.DoAnimateHide;
var
  I, Steps: Integer;
  Alpha: Byte;
begin
  Steps := FAnimationSteps;
  if Steps <= 0 then
    Steps := 1;

  for I := Steps - 1 downto 0 do
  begin
    Alpha := Byte(MulDiv(255, I, Steps));
    ApplyLayeredBitmap(Alpha);
    Sleep(12);
    Application.ProcessMessages;
  end;
end;

{ --- Activity indicator timer --- }

procedure TCWSDimOverlay.UpdateTimerState;
begin
  if csDesigning in ComponentState then
    Exit;

  if (FOverlayWnd <> 0) and FShowActivityIndicator then
  begin
    if not Assigned(FAnimThread) then
      FAnimThread := TCWSSpinnerThread.Create(Self);
  end
  else
    StopSpinner;
end;

procedure TCWSDimOverlay.StopSpinner;
begin
  if Assigned(FAnimThread) then
  begin
    TCWSSpinnerThread(FAnimThread).Stop;
    FAnimThread.WaitFor;     // ensure the thread is no longer rendering
    FAnimThread.Free;
    FAnimThread := nil;
  end;
end;

procedure TCWSDimOverlay.Repaint;
begin
  if FOverlayWnd <> 0 then
    ApplyLayeredBitmap(255);
end;

{ --- Public interface --- }

procedure TCWSDimOverlay.Show;
begin
  FVisible := True;
  if csDesigning in ComponentState then
    Exit;

  HookParentForm;
  CreateOverlayWindow;

  if Assigned(FOnShow) then
    FOnShow(Self);
end;

procedure TCWSDimOverlay.Hide;
begin
  if csDesigning in ComponentState then
  begin
    FVisible := False;
    Exit;
  end;

  StopSpinner;

  if FAnimated and (FOverlayWnd <> 0) then
    DoAnimateHide;

  DestroyOverlayWindow;
  FVisible := False;

  if Assigned(FOnHide) then
    FOnHide(Self);
end;

procedure TCWSDimOverlay.SetVisible(Value: Boolean);
begin
  if FVisible = Value then
    Exit;

  if csLoading in ComponentState then
  begin
    FVisible := Value;
    Exit;
  end;

  if Value then
    Show
  else
    Hide;
end;

procedure TCWSDimOverlay.SetOpacity(Value: Byte);
begin
  if FOpacity <> Value then
  begin
    FOpacity := Value;
    Repaint;
  end;
end;

procedure TCWSDimOverlay.SetColor(Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    Repaint;
  end;
end;

procedure TCWSDimOverlay.SetCornerRadius(Value: Integer);
begin
  if Value < 0 then
    Value := 0;
  if FCornerRadius <> Value then
  begin
    FCornerRadius := Value;
    if FOverlayWnd <> 0 then
    begin
      ApplyWindowRegion;
      ApplyLayeredBitmap(255);
    end;
  end;
end;

procedure TCWSDimOverlay.SetShowActivityIndicator(Value: Boolean);
begin
  if FShowActivityIndicator <> Value then
  begin
    FShowActivityIndicator := Value;
    FPhase := 0;
    UpdateTimerState;
    Repaint;
  end;
end;

procedure TCWSDimOverlay.SetIndicatorStyle(Value: TCWSIndicatorStyle);
begin
  if FIndicatorStyle <> Value then
  begin
    FIndicatorStyle := Value;
    Repaint;
  end;
end;

procedure TCWSDimOverlay.SetIndicatorColor(Value: TColor);
begin
  if FIndicatorColor <> Value then
  begin
    FIndicatorColor := Value;
    Repaint;
  end;
end;

procedure TCWSDimOverlay.SetIndicatorTrackColor(Value: TColor);
begin
  if FIndicatorTrackColor <> Value then
  begin
    FIndicatorTrackColor := Value;
    Repaint;
  end;
end;

procedure TCWSDimOverlay.SetIndicatorSize(Value: Integer);
begin
  if Value < 8 then
    Value := 8;
  if FIndicatorSize <> Value then
  begin
    FIndicatorSize := Value;
    Repaint;
  end;
end;

procedure TCWSDimOverlay.SetIndicatorSegmentCount(Value: Integer);
begin
  if Value < 3 then
    Value := 3
  else if Value > 60 then
    Value := 60;
  if FIndicatorSegmentCount <> Value then
  begin
    FIndicatorSegmentCount := Value;
    Repaint;
  end;
end;

procedure TCWSDimOverlay.SetIndicatorGap(Value: Integer);
begin
  if Value < 0 then
    Value := 0;
  if FIndicatorGap <> Value then
  begin
    FIndicatorGap := Value;
    Repaint;
  end;
end;

procedure TCWSDimOverlay.SetIndicatorSpeed(Value: Integer);
begin
  // clamp to a sane range: 10..3600 deg/s (~0.03..10 turns per second)
  if Value < 10 then
    Value := 10
  else if Value > 3600 then
    Value := 3600;
  // no Repaint needed: the spinner thread picks up the new speed on its next
  // frame; when stopped the speed has no visible effect anyway.
  FIndicatorSpeed := Value;
end;

procedure TCWSDimOverlay.SetText(const Value: string);
begin
  if FText <> Value then
  begin
    // guard against the spinner thread reading FText mid-assignment
    FRenderLock.Enter;
    try
      FText := Value;
    finally
      FRenderLock.Leave;
    end;
    Repaint;
  end;
end;

procedure TCWSDimOverlay.SetTextFont(Value: TFont);
begin
  // guard against the spinner thread reading the font mid-assignment
  FRenderLock.Enter;
  try
    FTextFont.Assign(Value);
  finally
    FRenderLock.Leave;
  end;
end;

procedure TCWSDimOverlay.TextFontChanged(Sender: TObject);
begin
  Repaint;
end;

initialization

finalization
  if GDwmLib <> 0 then
    FreeLibrary(GDwmLib);

end.
