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
unit CWSAfterFormShow;

interface

uses
  System.Classes, System.SysUtils, Vcl.Controls, Vcl.Forms,
  Winapi.Windows, Winapi.Messages;

const
  WM_USER_AFTERSHOW = WM_USER + 200;

type
  { Helper thread — waits until the application finishes painting, then wakes the form }
  TAfterShowThread = class(TThread)
  private
    FFormHandle: HWND;
  protected
    procedure Execute; override;
  public
    constructor Create(AFormHandle: HWND);
  end;

  TCWSAfterFormShow = class(TComponent)
  private
    FOwnerForm       : TForm;
    FOldWndProc      : TWndMethod;
    FOnAfterShow     : TNotifyEvent;
    FWasMinimized    : Boolean;
    FPendingAfterShow: Boolean;
    procedure HookWndProc(var Msg: TMessage);
    procedure DoAfterShow;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Fires on every Show/ShowModal after the form and controls are fully painted,
      but NOT on un-minimize }
    property OnAfterShow: TNotifyEvent read FOnAfterShow write FOnAfterShow;
  end;

implementation

{ TAfterShowThread }

constructor TAfterShowThread.Create(AFormHandle: HWND);
begin
  FFormHandle := AFormHandle;
  FreeOnTerminate := True;
  inherited Create(False);
end;

procedure TAfterShowThread.Execute;
begin
  // Wait until the main GUI thread finishes processing all messages
  // (including WM_PAINT of all controls) — max 10 seconds
  WaitForInputIdle(GetCurrentProcess, 10000);
  // Only now wake the form — from a safe thread via PostMessage
  PostMessage(FFormHandle, WM_USER_AFTERSHOW, 0, 0);
end;

{ TCWSAfterFormShow }

constructor TCWSAfterFormShow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FWasMinimized     := False;
  FPendingAfterShow := False;
  if (AOwner is TForm) and not (csDesigning in ComponentState) then
  begin
    FOwnerForm := TForm(AOwner);
    FOldWndProc := FOwnerForm.WindowProc;
    FOwnerForm.WindowProc := HookWndProc;
    FOwnerForm.FreeNotification(Self);
  end;
end;

destructor TCWSAfterFormShow.Destroy;
begin
  if Assigned(FOwnerForm) then
    FOwnerForm.WindowProc := FOldWndProc;
  inherited Destroy;
end;

procedure TCWSAfterFormShow.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FOwnerForm) then
    FOwnerForm := nil;
end;

procedure TCWSAfterFormShow.HookWndProc(var Msg: TMessage);
begin
  case Msg.Msg of

    WM_SIZE:
    begin
      if Msg.WParam = SIZE_MINIMIZED then
        FWasMinimized := True;
      FOldWndProc(Msg);
    end;

    WM_SHOWWINDOW:
    begin
      FOldWndProc(Msg);
      if Msg.WParam = 1 then
      begin
        if FWasMinimized then
          FWasMinimized := False
        else
          FPendingAfterShow := True;  // wait for the form's WM_PAINT
      end;
    end;

    WM_PAINT:
    begin
      FOldWndProc(Msg);
      if FPendingAfterShow then
      begin
        FPendingAfterShow := False;
        // Start a thread that waits for idle and posts WM_USER_AFTERSHOW
        TAfterShowThread.Create(FOwnerForm.Handle);
      end;
    end;

    WM_USER_AFTERSHOW:
    begin
      // Reached here from the helper thread via PostMessage — the GUI is idle
      DoAfterShow;
    end;

  else
    FOldWndProc(Msg);
  end;
end;

procedure TCWSAfterFormShow.DoAfterShow;
begin
  if Assigned(FOnAfterShow) then
    FOnAfterShow(Self);
end;

end.
