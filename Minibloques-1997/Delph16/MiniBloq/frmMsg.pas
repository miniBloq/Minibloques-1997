unit FrmMsg;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, StdCtrls, FileCtrl, Buttons, ExtCtrls;

type
  TfrmMessage = class(TForm)
    pnlOk: TPanel;
    pnlCancel: TPanel;
    lblMsg1: TLabel;
    lblMsg2: TLabel;
    procedure pnlOkMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlCancelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlOkMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlCancelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlOkClick(Sender: TObject);
    procedure pnlCancelClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMessage: TfrmMessage;

procedure ShowMsg(const Title, Msg1, Msg2 :string; const Ok, Cancel :boolean);

implementation

{$R *.DFM}

{Esta rutina es la que llama directamente al frmMessage:}
procedure ShowMsg(const Title, Msg1, Msg2 :string; const Ok, Cancel :boolean);
begin
     frmMessage.Visible:= false; {<-Para que me deje hacer el ShowModal siempre.}
     frmMessage.Caption:= Title;
     frmMessage.lblMsg1.Caption:= Msg1;
     frmMessage.lblMsg2.Caption:= Msg2;
     frmMessage.pnlOk.Visible:= Ok;
     frmMessage.pnlCancel.Visible:= Cancel;
     frmMessage.ShowModal;
end; {ShowMsg}

procedure TfrmMessage.pnlOkMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     pnlOk.BevelInner:= bvLowered;
     pnlOk.BevelOuter:= bvLowered;
end;

procedure TfrmMessage.pnlCancelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     pnlCancel.BevelInner:= bvLowered;
     pnlCancel.BevelOuter:= bvLowered;
end;

procedure TfrmMessage.pnlOkMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     pnlOk.BevelInner:= bvRaised;
     pnlOk.BevelOuter:= bvNone;
end;

procedure TfrmMessage.pnlCancelMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     pnlCancel.BevelInner:= bvRaised;
     pnlCancel.BevelOuter:= bvNone;
end;

procedure TfrmMessage.pnlOkClick(Sender: TObject);
begin
     ModalResult := mrOK;
end;

procedure TfrmMessage.pnlCancelClick(Sender: TObject);
begin
     ModalResult := mrCancel;
end;

procedure TfrmMessage.FormKeyPress(Sender: TObject; var Key: Char);
begin
     if Key = chr(13) then
        Close;
end;

end.
