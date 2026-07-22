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
unit CWSCornerPanel;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.ExtCtrls, System.UITypes;

type
  TCWSCornerPanel = class(TPanel)
  private
    { Private declarations }
    GetCorColor: TColor;
    GetLinSize: Integer;
    GetLineWidth: Integer;
    procedure SetCorColor(const value: TColor);
    procedure SetlineSize(const value: Integer);
    procedure SetLineWidth(const value: Integer);
    function GetLineSize: Integer;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
  published
    { Published declarations }
    property CornerColor: TColor read GetCorColor write SetCorColor;
    property CornerSize: Integer read GetLineSize write SetLineSize;
    property CornerLineWidth: Integer read GetLineWidth write SetLineWidth;
    property Color;
    property Caption stored False;
  end;

implementation

uses
  Vcl.Graphics, System.Types;

{ TPanel1 }

constructor TCWSCornerPanel.Create(AOwner: TComponent);
begin
  inherited;
  GetCorColor := clYellow;
  GetLinSize := 2;
  CornerLineWidth:= 2;
  BevelOuter := bvNone;
  Caption := '';
  ShowCaption := False;
  Color := clBlack;
end;

function TCWSCornerPanel.GetLineSize: Integer;
begin
  Result := GetLinSize;
end;

procedure TCWSCornerPanel.Paint;
var
  D: TRect;
  factor: Integer;
begin
  // Fill Background
  Canvas.Brush.Color := Color;
  Canvas.FillRect(ClientRect);

  // Set Corner Drawing Styles
  Canvas.Pen.Color := GetCorColor;
  Canvas.Brush.Color := GetCorColor;
  Canvas.Brush.Style := bsSolid;

  // Use the property intended for line thickness
  Canvas.Pen.Width := GetLineWidth;

  // Determine the length of the corner "arms"
  if GetLinSize < 3 then
    factor := 5
  else
    factor := 6;

  // Top Left (R1)
  D := Rect(0, 0, GetLinSize + factor, CornerLineWidth);
  Canvas.FillRect(D);
  D := Rect(0, 0, CornerLineWidth, GetLinSize + factor);
  Canvas.FillRect(D);

  // Top Right (R2)
  D := Rect(Width - CornerLineWidth, 0, Width, GetLinSize + factor);
  Canvas.FillRect(D);
  D := Rect(Width - GetLinSize - factor, 0, Width, CornerLineWidth);
  Canvas.FillRect(D);

  // Bottom Right (R3)
  D := Rect(Width - CornerLineWidth, Height, Width, Height - GetLinSize - factor);
  Canvas.FillRect(D);
  D := Rect(Width - GetLinSize - factor, Height - CornerLineWidth, Width, Height);
  Canvas.FillRect(D);

  // Bottom Left (R4)
  D := Rect(0, Height - GetLinSize - factor, CornerLineWidth, Height);
  Canvas.FillRect(D);
  D := Rect(0, Height - CornerLineWidth, GetLinSize + factor, Height);
  Canvas.FillRect(D);
end;

procedure TCWSCornerPanel.SetCorColor(const value: TColor);
begin
  GetCorColor := value;
  Invalidate;
end;

procedure TCWSCornerPanel.SetlineSize(const value: Integer);
begin
  GetLinSize := value;
  if GetLinSize = 0 then
    GetLinSize := 1;
  Invalidate;
end;

procedure TCWSCornerPanel.SetLineWidth(const value: Integer);
begin
  GetLineWidth := value;
  if GetLineWidth = 0 then
    GetLineWidth := 1;
  Invalidate;
end;

end.

