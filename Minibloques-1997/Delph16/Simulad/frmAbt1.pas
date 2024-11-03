unit Frmabt1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls;

type
  TfrmAbt = class(TForm)
    lblSimple: TLabel;
    lblSimple2: TLabel;
    lblSimple3: TLabel;
    lblCopyRight: TLabel;
    pnlStart: TPanel;
    pnlMinibloq: TPanel;
    pnlProduct2: TImage;
    pnlProduct1: TPanel;
    pnlCursor: TPanel;
    imgCursor: TImage;
    Label1: TLabel;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure pnlStartMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlStartMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlStartClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAbt: TfrmAbt;

implementation

{$R *.DFM}

procedure TfrmAbt.FormKeyPress(Sender: TObject; var Key: Char);
begin
     if Key = chr(13) then
        Close;
end;

procedure TfrmAbt.pnlStartMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     pnlStart.BevelInner:= bvLowered;
     pnlStart.BevelOuter:= bvLowered;
end;

procedure TfrmAbt.pnlStartMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     pnlStart.BevelInner:= bvRaised;
     pnlStart.BevelOuter:= bvNone;
end;

procedure TfrmAbt.pnlStartClick(Sender: TObject);
begin
     Close;
end;

end.
