unit Frmconf1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, StdCtrls, ExtCtrls, i723_v20, Buttons;

type
  TfrmConfig = class(TForm)
    pnlOk: TPanel;
    pnlCancel: TPanel;
    grpPort: TGroupBox;
    chkLpt1: TCheckBox;
    chkLpt2: TCheckBox;
    chkLpt3: TCheckBox;
    procedure pnlOkMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlOkMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlCancelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlCancelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure chkLpt3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure chkLpt2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure chkLpt1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmConfig: TfrmConfig;
  Lpt1, Lpt2, Lpt3 :boolean;

implementation

{$R *.DFM}

procedure TfrmConfig.pnlOkMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     pnlOk.BevelInner:= bvLowered;
     pnlOk.BevelOuter:= bvLowered;
end;

procedure TfrmConfig.pnlOkMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     pnlOk.BevelInner:= bvRaised;
     pnlOk.BevelOuter:= bvNone;
     Close;
end;

procedure TfrmConfig.pnlCancelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     pnlCancel.BevelInner:= bvLowered;
     pnlCancel.BevelOuter:= bvLowered;
end;

procedure TfrmConfig.pnlCancelMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   {Efecto sobre el botón:}
     pnlCancel.BevelInner:= bvRaised;
     pnlCancel.BevelOuter:= bvNone;
   {Anula el cambio de port:}
     chkLpt1.Checked:= Lpt1;
     chkLpt2.Checked:= Lpt2;
     chkLpt3.Checked:= Lpt3;
     if Lpt1 then
        Inicializar(1)
     else if Lpt2 then
          Inicializar(2)
     else
         Inicializar(3);
     ApagaTodo;
   {Cierra la pantalla de configuración:}
     Close;
end;

procedure TfrmConfig.FormCreate(Sender: TObject);
begin
     Lpt1:= true; {aca:dependerá del archivo .INI.}
     Lpt2:= false;
     Lpt3:= false;
end;

procedure TfrmConfig.FormShow(Sender: TObject);
begin
     Lpt1:= chkLpt1.Checked;
     Lpt2:= chkLpt2.Checked;
     Lpt3:= chkLpt3.Checked;
end;

procedure TfrmConfig.chkLpt3MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     chkLpt1.Checked:= false;
     chkLpt2.Checked:= false;
     Inicializar(3);
     ApagaTodo;
end;

procedure TfrmConfig.chkLpt2MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     chkLpt1.Checked:= false;
     chkLpt3.Checked:= false;
     Inicializar(2);
     ApagaTodo;
end;

procedure TfrmConfig.chkLpt1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     chkLpt2.Checked:= false;
     chkLpt3.Checked:= false;
     Inicializar(1);
     ApagaTodo;
end;

end.
