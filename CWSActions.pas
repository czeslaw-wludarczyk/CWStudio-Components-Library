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
unit CWSActions;

{ ────────────────────────────────────────────────────────────────────────────
  Shared TAction / TActionList support for CWStudio controls.

  The CWStudio controls descend from TCustomControl but expose their visible
  text, checked state and click handler through their OWN published properties
  (Caption / MenuText / DescriptionText, Checked / Pressed, OnClick) instead of
  the hidden TControl.Text / TControl.OnClick. The stock VCL action linking
  therefore cannot reach them: TControlActionLink pushes Caption into
  TControl.Text and OnExecute into TControl.OnClick, neither of which our
  controls display.

  This unit bridges the gap the same way the VCL does internally, but redirected
  to the control's real properties:

    * ICWSActionClient — implemented by each control, abstracting its
      action-target properties (caption, checked, image index, OnClick).
    * TCWSControlActionLink — a TControlActionLink that redirects Caption /
      Checked / ImageIndex / OnExecute through ICWSActionClient. Enabled /
      Visible / Hint stay with the inherited link (they are ordinary TControl
      properties every CWStudio control already inherits).
    * CWSActionChange — the CWStudio counterpart of TControl.ActionChange:
      copies the action's standard properties into the control on link/refresh.
    * CWSDispatchClick — VCL-identical click dispatch: run the user's OnClick
      when it was overridden, otherwise execute the linked action.

  A control opts in with four small hooks (see any of the CWS* button units):
    - declare that it implements ICWSActionClient and provide the getters/setters
    - override GetActionLinkClass to return TCWSControlActionLink
    - override ActionChange to call CWSActionChange(Self, Self, ...)
    - route its Click through CWSDispatchClick(Self, Self, Action, ActionLink)
    - publish the Action property
  ──────────────────────────────────────────────────────────────────────────── }

interface

uses
  System.Classes, System.SysUtils, Vcl.Controls, Vcl.ActnList;

type
  { Abstracts the "action target" properties of a CWStudio control so a single
    action-link class can drive any of them. A CWStudio control implements this
    over its own published Caption/Checked/ImageIndex/OnClick.

    Because the implementors are TComponent descendants (reference counting is
    disabled by TComponent), it is safe to hold and pass these as plain
    interface references without affecting the control's lifetime. }
  ICWSActionClient = interface
    ['{6B2C9F14-3A7E-4D5B-9C1F-8E2A0D6F4B71}']
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
  end;

  { Action link that pushes an action's Caption / Checked / ImageIndex /
    OnExecute into the client through ICWSActionClient, mirroring the value-sync
    semantics of the stock TControlActionLink (a property stays "linked" only
    while the control's value still matches the action's — the moment the user
    diverges it, the action stops overwriting it). }
  TCWSControlActionLink = class(TControlActionLink)
  protected
    function  ClientIntf: ICWSActionClient;
    function  IsCaptionLinked: Boolean; override;
    function  IsCheckedLinked: Boolean; override;
    function  IsImageIndexLinked: Boolean; override;
    function  IsOnExecuteLinked: Boolean; override;
    procedure SetCaption(const Value: string); override;
    procedure SetChecked(Value: Boolean); override;
    procedure SetImageIndex(Value: Integer); override;
    procedure SetOnExecute(Value: TNotifyEvent); override;
  end;

{ CWStudio counterpart of TControl.ActionChange: copies the action's standard
  properties into the control on initial link and on full refresh. AClient and
  AControl are normally the same object (the control), passed twice so the
  helper can reach both the abstracted action-target properties and the plain
  TControl ones (Enabled / Visible / Hint). }
procedure CWSActionChange(const AClient: ICWSActionClient; AControl: TControl;
  Sender: TObject; CheckDefaults: Boolean);

{ VCL-identical click dispatch (see TControl.Click): call OnClick if the user
  assigned a handler distinct from the action's OnExecute; otherwise execute the
  linked action; otherwise call OnClick if present. }
procedure CWSDispatchClick(AControl: TControl; const AClient: ICWSActionClient;
  AAction: TBasicAction; AActionLink: TControlActionLink);

implementation

{ TCWSControlActionLink }

function TCWSControlActionLink.ClientIntf: ICWSActionClient;
begin
  if not Supports(FClient, ICWSActionClient, Result) then
    Result := nil;
end;

function TCWSControlActionLink.IsCaptionLinked: Boolean;
var
  Intf: ICWSActionClient;
begin
  Intf := ClientIntf;
  Result := (Intf <> nil) and (Action is TCustomAction) and
    (Intf.CWSActionCaption = TCustomAction(Action).Caption);
end;

function TCWSControlActionLink.IsCheckedLinked: Boolean;
var
  Intf: ICWSActionClient;
begin
  Intf := ClientIntf;
  Result := (Intf <> nil) and Intf.CWSActionCheckedSupported and
    (Action is TCustomAction) and
    (Intf.CWSActionChecked = TCustomAction(Action).Checked);
end;

function TCWSControlActionLink.IsImageIndexLinked: Boolean;
var
  Intf: ICWSActionClient;
begin
  Intf := ClientIntf;
  Result := (Intf <> nil) and Intf.CWSActionImageIndexSupported and
    (Action is TCustomAction) and
    (Intf.CWSActionImageIndex = TCustomAction(Action).ImageIndex);
end;

function TCWSControlActionLink.IsOnExecuteLinked: Boolean;
var
  Intf: ICWSActionClient;
  OnClk: TNotifyEvent;
begin
  Intf := ClientIntf;
  if (Intf = nil) or (Action = nil) then
    Exit(False);
  OnClk := Intf.CWSActionOnClick;
  Result := (TMethod(OnClk).Code = TMethod(Action.OnExecute).Code) and
            (TMethod(OnClk).Data = TMethod(Action.OnExecute).Data);
end;

procedure TCWSControlActionLink.SetCaption(const Value: string);
begin
  if IsCaptionLinked then
    ClientIntf.CWSSetActionCaption(Value);
end;

procedure TCWSControlActionLink.SetChecked(Value: Boolean);
begin
  if IsCheckedLinked then
    ClientIntf.CWSSetActionChecked(Value);
end;

procedure TCWSControlActionLink.SetImageIndex(Value: Integer);
begin
  if IsImageIndexLinked then
    ClientIntf.CWSSetActionImageIndex(Value);
end;

procedure TCWSControlActionLink.SetOnExecute(Value: TNotifyEvent);
begin
  if IsOnExecuteLinked then
    ClientIntf.CWSSetActionOnClick(Value);
end;

{ Helpers }

procedure CWSActionChange(const AClient: ICWSActionClient; AControl: TControl;
  Sender: TObject; CheckDefaults: Boolean);
begin
  if (AClient = nil) or not (Sender is TCustomAction) then
    Exit;

  with TCustomAction(Sender) do
  begin
    if not CheckDefaults or (AClient.CWSActionCaption = '') or
       (AClient.CWSActionCaption = AControl.Name) then
      AClient.CWSSetActionCaption(Caption);

    if not CheckDefaults or AControl.Enabled then
      AControl.Enabled := Enabled;

    if not CheckDefaults or (AControl.Hint = '') then
      AControl.Hint := Hint;

    if not CheckDefaults or AControl.Visible then
      AControl.Visible := Visible;

    if AClient.CWSActionCheckedSupported and
       (not CheckDefaults or not AClient.CWSActionChecked) then
      AClient.CWSSetActionChecked(Checked);

    if AClient.CWSActionImageIndexSupported and
       (not CheckDefaults or (AClient.CWSActionImageIndex = -1)) then
      AClient.CWSSetActionImageIndex(ImageIndex);

    if not CheckDefaults or (not Assigned(AClient.CWSActionOnClick)) then
      AClient.CWSSetActionOnClick(OnExecute);
  end;
end;

procedure CWSDispatchClick(AControl: TControl; const AClient: ICWSActionClient;
  AAction: TBasicAction; AActionLink: TControlActionLink);
var
  OnClk: TNotifyEvent;
  Diverged: Boolean;
begin
  OnClk := nil;
  if AClient <> nil then
    OnClk := AClient.CWSActionOnClick;

  { The user's own handler wins only when it differs from the action's OnExecute
    (i.e. it was assigned independently of the action). }
  Diverged := Assigned(OnClk) and (AAction <> nil) and
    ((TMethod(OnClk).Code <> TMethod(AAction.OnExecute).Code) or
     (TMethod(OnClk).Data <> TMethod(AAction.OnExecute).Data));

  if Diverged then
    OnClk(AControl)
  else if not (csDesigning in AControl.ComponentState) and (AActionLink <> nil) then
    AActionLink.Execute(AControl)
  else if Assigned(OnClk) then
    OnClk(AControl);
end;

end.
