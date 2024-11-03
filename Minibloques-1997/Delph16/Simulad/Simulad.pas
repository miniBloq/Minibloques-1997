unit Simulad;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, i723_v20, ExtCtrls, Menus,
  frmAbt1;

type
  TfrmSimulador = class(TForm)
    Mot1Da: TCheckBox;
    Mot2DA: TCheckBox;
    Sal2: TCheckBox;
    Sal1: TCheckBox;
    tmrStatus: TTimer;
    Mot2Iz: TCheckBox;
    Mot1Iz: TCheckBox;
    Mot3Da: TCheckBox;
    Mot3IZ: TCheckBox;
    lblSalidas: TLabel;
    lblMotor1: TLabel;
    lblMotor2: TLabel;
    lblMotor3: TLabel;
    imgI723: TImage;
    imgMotor1: TImage;
    imgMotor2: TImage;
    imgMotor3: TImage;
    shpRele1: TPanel;
    shpRele2: TPanel;
    shpMotor1: TPanel;
    shpMotor2: TPanel;
    shpMotor3: TPanel;
    shpSensor1: TPanel;
    shpSensor2: TPanel;
    shpSensor3: TPanel;
    shpSensor4: TPanel;
    MainMenu1: TMainMenu;
    mnuPuerto: TMenuItem;
    mnuEsquema: TMenuItem;
    mnuLpt1: TMenuItem;
    mnuLpt2: TMenuItem;
    mnuLpt3: TMenuItem;
    mnuAcercaDe: TMenuItem;
    lblSal1: TLabel;
    lblSal2: TLabel;
    lblSensores: TLabel;
    chkSen2: TCheckBox;
    chkSen1: TCheckBox;
    lblSen1: TLabel;
    lblSen2: TLabel;
    chkSen4: TCheckBox;
    chkSen3: TCheckBox;
    lblSen3: TLabel;
    lblSen4: TLabel;
    procedure tmrStatusTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mnuLpt1Click(Sender: TObject);
    procedure mnuLpt2Click(Sender: TObject);
    procedure mnuLpt3Click(Sender: TObject);
    procedure mnuEsquemaClick(Sender: TObject);
    procedure mnuAcercaDeClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSimulador :TfrmSimulador;
  OrigHeight   :integer;

implementation

{$R *.DFM}

procedure TfrmSimulador.tmrStatusTimer(Sender: TObject);
begin
     if LeeSalida(1) then
     begin
         Sal1.state:=cbChecked;
         shpRele1.visible:=false;
     end
     else
     begin
         Sal1.state:=cbUnchecked;
         shpRele1.visible:=true;
     end;

     if LeeSalida(2) then
     begin
         Sal2.state:=cbChecked;
         shpRele2.visible:=false;
     end
     else
     begin
         Sal2.state:=cbUnchecked;
         shpRele2.visible:=true;
     end;

     if LeeMotor(1)=DA then
     begin
        Mot1DA.state:=cbChecked;
        Mot1iZ.state:=cbunChecked;
        shpMotor1.visible:=false;
        imgMotor1.visible:=false;
     end
     else
         if LeeMotor(1)=IZ then
         begin
              Mot1IZ.state:=cbChecked;
              Mot1DA.state:=cbunChecked;
              shpMotor1.visible:=false;
              imgMotor1.visible:=true;
         end
         else
         begin
              Mot1IZ.state:= cbunChecked;
              Mot1DA.state:= cbunChecked;
              shpMotor1.visible:= true;
              imgMotor1.visible:= false;
         end;

     if LeeMotor(2)=DA then
     begin
        Mot2DA.state:= cbChecked;
        Mot2iZ.state:= cbunChecked;
        shpMotor2.visible:= false;
        imgMotor2.visible:= false; {led verde}
     end
     else
         if LeeMotor(2)= IZ then
         begin
              Mot2IZ.state:= cbChecked;
              Mot2DA.state:= cbunChecked;
              shpMotor2.visible:= false;
              imgMotor2.visible:= true; {led verde}
         end
         else
         begin
              Mot2IZ.state:= cbunChecked;
              Mot2DA.state:= cbunChecked;
              shpMotor2.visible:= true;
              imgMotor2.visible:= false; {led verde}
         end;

     if LeeMotor(3)=DA then
     begin
        Mot3DA.state:= cbChecked;
        Mot3iZ.state:= cbunChecked;
        shpMotor3.visible:= false;
        imgMotor3.visible:= false; {led verde}
     end
     else
         if LeeMotor(3)=IZ then
         begin
              Mot3IZ.state:= cbChecked;
              Mot3DA.state:= cbunChecked;
              shpMotor3.visible:= false;
              imgMotor3.visible:= true; {led verde}
         end
         else
         begin
              Mot3IZ.state:= cbunChecked;
              Mot3DA.state:= cbunChecked;
              shpMotor3.visible:= true;
              imgMotor3.visible:= false; {led verde}
         end;
         shpSensor1.visible:= not LeeSensor(1);
         shpSensor2.visible:= not LeeSensor(2);
         shpSensor3.visible:= not LeeSensor(3);
         shpSensor4.visible:= not LeeSensor(4);
         chkSen1.Checked:= not shpSensor1.visible;
         chkSen2.Checked:= not shpSensor2.visible;
         chkSen3.Checked:= not shpSensor3.visible;
         chkSen4.Checked:= not shpSensor4.visible;
end;

procedure TfrmSimulador.FormCreate(Sender: TObject);
begin
     Inicializar(1);
     OrigHeight:= frmSimulador.ClientHeight;
end;

procedure TfrmSimulador.mnuLpt1Click(Sender: TObject);
begin
     Inicializar(1);
     mnuLpt1.checked:= true;
     mnuLpt2.checked:= false;
     mnuLpt3.checked:= false;
end;

procedure TfrmSimulador.mnuLpt2Click(Sender: TObject);
begin
     Inicializar(2);
     mnuLpt1.checked:= false;
     mnuLpt2.checked:= true;
     mnuLpt3.checked:= false;
end;

procedure TfrmSimulador.mnuLpt3Click(Sender: TObject);
begin
     Inicializar(3);
     mnuLpt1.checked:= false;
     mnuLpt2.checked:= false;
     mnuLpt3.checked:= true;
end;

procedure TfrmSimulador.mnuEsquemaClick(Sender: TObject);
begin
     if frmSimulador.ClientHeight <> imgI723.top then
     begin
          frmSimulador.ClientHeight:= imgI723.top;
          mnuEsquema.Caption:= 'Ver &Esquema';
     end {if-then}
     else
     begin
         frmSimulador.ClientHeight:= OrigHeight;
         mnuEsquema.Caption:= 'Ocultar &Esquema';
     end; {else}
end;

procedure TfrmSimulador.mnuAcercaDeClick(Sender: TObject);
begin
     frmAbt.ShowModal;
end;

end.
