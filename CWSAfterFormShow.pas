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
    FOwnerForm  : TForm;
    FOldWndProc : TWndMethod;
    FOnAfterShow: TNotifyEvent;
    procedure HookWndProc(var Msg: TMessage);
    procedure DoAfterShow;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Fires on every Show/ShowModal (normal or maximized) after the form
      is fully painted, but NOT on un-minimize }
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
  WaitForInputIdle(GetCurrentProcess, 10000);
  if IsWindow(FFormHandle) then
    PostMessage(FFormHandle, WM_USER_AFTERSHOW, 0, 0);
end;

{ TCWSAfterFormShow }

constructor TCWSAfterFormShow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
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

    CM_SHOWINGCHANGED:
    begin
      // VCL actually shows/hides the window here (also SW_SHOWMAXIMIZED)
      FOldWndProc(Msg);
      if Assigned(FOwnerForm) and FOwnerForm.Showing then
        TAfterShowThread.Create(FOwnerForm.Handle);
    end;

    WM_USER_AFTERSHOW:
      DoAfterShow;

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
