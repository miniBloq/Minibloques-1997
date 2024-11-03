unit frmPrueb;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, Buttons, StdCtrls,
  {Propios:}
  i723_v20,
  frmAbt1;

type
  TfrmPrueba = class(TForm)
    spdRele1Si: TSpeedButton;
    spdRele1No: TSpeedButton;
    pnlPort: TPanel;
    optLpt1: TRadioButton;
    optLpt2: TRadioButton;
    optLpt3: TRadioButton;
    lblPort: TLabel;
    spdRele2Si: TSpeedButton;
    spdRele2No: TSpeedButton;
    lblRele1: TLabel;
    bvlControl: TBevel;
    spdMotor1IZ: TSpeedButton;
    lblRele2: TLabel;
    spdMotor1ALTO: TSpeedButton;
    spdMotor1DA: TSpeedButton;
    spdMotor2IZ: TSpeedButton;
    spdMotor2ALTO: TSpeedButton;
    spdMotor2DA: TSpeedButton;
    spdMotor3IZ: TSpeedButton;
    spdMotor3ALTO: TSpeedButton;
    spdMotor3DA: TSpeedButton;
    lblMotor1: TLabel;
    lblMotor2: TLabel;
    lblMotor3: TLabel;
    spdReset: TSpeedButton;
    tmrSensores: TTimer;
    imgI723: TImage;
    bvli723: TBevel;
    spdSalir: TSpeedButton;
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
    spdAbout: TSpeedButton;
    procedure optLpt1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure spdRele1SiClick(Sender: TObject);
    procedure optLpt2Click(Sender: TObject);
    procedure optLpt3Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure spdRele1NoClick(Sender: TObject);
    procedure spdRele2NoClick(Sender: TObject);
    procedure spdRele2SiClick(Sender: TObject);
    procedure spdMotor1IZClick(Sender: TObject);
    procedure spdMotor1ALTOClick(Sender: TObject);
    procedure spdMotor1DAClick(Sender: TObject);
    procedure spdMotor2IZClick(Sender: TObject);
    procedure spdMotor2ALTOClick(Sender: TObject);
    procedure spdMotor2DAClick(Sender: TObject);
    procedure spdMotor3IZClick(Sender: TObject);
    procedure spdMotor3ALTOClick(Sender: TObject);
    procedure spdMotor3DAClick(Sender: TObject);
    procedure spdResetClick(Sender: TObject);
    procedure tmrSensoresTimer(Sender: TObject);
    procedure Reset;
    procedure spdSalirClick(Sender: TObject);
    procedure spdAboutClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrueba: TfrmPrueba;

implementation

{$R *.DFM}

procedure TfrmPrueba.Reset;
begin
     ApagaTodo;
     shpMotor1.visible:= true;
     shpMotor2.visible:= true;
     shpMotor3.visible:= true;
     shpRele1.visible:= true;
     shpRele2.visible:= true;
     imgMotor1.visible:= false;
     imgMotor2.visible:= false;
     imgMotor3.visible:= false;
end;

procedure TfrmPrueba.optLpt1Click(Sender: TObject);
begin
     ApagaTodo;
     Inicializar(1);
     Reset;
end;

procedure TfrmPrueba.FormCreate(Sender: TObject);
begin
     Inicializar(1);
     ApagaTodo;
     {Acomoda los controles:}
end;

procedure TfrmPrueba.spdRele1SiClick(Sender: TObject);
begin
     EscribeSalida(1, SI);
     shpRele1.visible:= false;
end;


procedure TfrmPrueba.optLpt2Click(Sender: TObject);
begin
     ApagaTodo;
     Inicializar(2);
     Reset;
end;

procedure TfrmPrueba.optLpt3Click(Sender: TObject);
begin
     ApagaTodo;
     Inicializar(3);
     Reset;
end;

procedure TfrmPrueba.FormDestroy(Sender: TObject);
begin
     ApagaTodo;
end;

procedure TfrmPrueba.spdRele1NoClick(Sender: TObject);
begin
     EscribeSalida(1, NO);
     shpRele1.visible:= true;
end;

procedure TfrmPrueba.spdRele2NoClick(Sender: TObject);
begin
     EscribeSalida(2,NO);
     shpRele2.visible:= true;
end;

procedure TfrmPrueba.spdRele2SiClick(Sender: TObject);
begin
     EscribeSalida(2,SI);
     shpRele2.visible:= false;
end;

procedure TfrmPrueba.spdMotor1IZClick(Sender: TObject);
begin
     EscribeMotor(1,IZ);
     shpMotor1.visible:= false;
     imgMotor1.visible:= true; {led verde}
end;

procedure TfrmPrueba.spdMotor1ALTOClick(Sender: TObject);
begin
     EscribeMotor(1,ALTO);
     shpMotor1.visible:= true;
     imgMotor1.visible:= false; {led verde}
end;

procedure TfrmPrueba.spdMotor1DAClick(Sender: TObject);
begin
     EscribeMotor(1,DA);
     shpMotor1.visible:= false;
     imgMotor1.visible:= false; {led verde}
end;

procedure TfrmPrueba.spdMotor2IZClick(Sender: TObject);
begin
     EscribeMotor(2,IZ);
     shpMotor2.visible:= false;
     imgMotor2.visible:= true; {led verde}
end;

procedure TfrmPrueba.spdMotor2ALTOClick(Sender: TObject);
begin
     EscribeMotor(2,ALTO);
     shpMotor2.visible:= true;
     imgMotor2.visible:= false; {led verde}
end;

procedure TfrmPrueba.spdMotor2DAClick(Sender: TObject);
begin
     EscribeMotor(2,DA);
     shpMotor2.visible:= false;
     imgMotor2.visible:= false; {led verde}
end;

procedure TfrmPrueba.spdMotor3IZClick(Sender: TObject);
begin
     EscribeMotor(3,IZ);
     shpMotor3.visible:= false;
     imgMotor3.visible:= true; {led verde}
end;

procedure TfrmPrueba.spdMotor3ALTOClick(Sender: TObject);
begin
     EscribeMotor(3,ALTO);
     shpMotor3.visible:= true;
     imgMotor3.visible:= false; {led verde}
end;

procedure TfrmPrueba.spdMotor3DAClick(Sender: TObject);
begin
     EscribeMotor(3,DA);
     shpMotor3.visible:= false;
     imgMotor3.visible:= false; {led verde}
end;

procedure TfrmPrueba.spdResetClick(Sender: TObject);
begin
     Reset;
end;

procedure TfrmPrueba.tmrSensoresTimer(Sender: TObject);
begin
     shpSensor1.visible:= not LeeSensor(1);
     shpSensor2.visible:= not LeeSensor(2);
     shpSensor3.visible:= not LeeSensor(3);
     shpSensor4.visible:= not LeeSensor(4);
end;

procedure TfrmPrueba.spdSalirClick(Sender: TObject);
begin
     close;
end;

procedure TfrmPrueba.spdAboutClick(Sender: TObject);
begin
     frmAbt.ShowModal;
end;

end.
