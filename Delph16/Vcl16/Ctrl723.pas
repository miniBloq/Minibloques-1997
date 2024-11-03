unit Ctrl723;

interface

uses
    SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
    Forms, Dialogs, ExtCtrls;

type
  TPort = (LPT1, LPT2, LPT3);
  TEstadoMotor = (ALTO, DA, IZ);
  TControl723 = class(TComponent)
  private
         FSensor1, FSensor2, FSensor3, FSensor4 :boolean;
         FMotor1, FMotor2, FMotor3              :TEstadoMotor;
         FSalida1, FSalida2                     :boolean;
         FPort                                  :TPort;
         FOnChange                              :TNotifyEvent;
         tmrSensores                            :TTimer;
         procedure TestSensores(Sender :TObject);
         procedure SetPort(Value :TPort);
         procedure SetMotor(Index :integer; Value :TEstadoMotor);
         procedure SetSalida(Index :integer; Value :boolean);
         function GetSensor(Index :integer): boolean;
  protected
           procedure Change; dynamic;
  public
        constructor Create(AOwner :TComponent); override;
        destructor Destroy; override;
        procedure Reset;
  published
           property Port :TPort read FPort write SetPort default LPT1;
           property Motor1 :TEstadoMotor index 1 read FMotor1 write SetMotor default ALTO;
           property Motor2 :TEstadoMotor index 2 read FMotor2 write SetMotor default ALTO;
           property Motor3 :TEstadoMotor index 3 read FMotor3 write SetMotor default ALTO;
           property Salida1 :boolean index 1 read FSalida1 write SetSalida default false;
           property Salida2 :boolean index 2 read FSalida2 write SetSalida default false;
           property Sensor1 :boolean Index 1 read GetSensor;
           property Sensor2 :boolean Index 2 read GetSensor;
           property Sensor3 :boolean Index 3 read GetSensor;
           property Sensor4 :boolean Index 4 read GetSensor;
           property OnChange :TNotifyEvent read FOnChange write FOnChange;
  end;

  procedure Register;

implementation

const
     DirLPT1 = 888;
     DirLPT2 = 956;
     DirLPT3 = 632;

var
{Variables para las funciones de la i-723}
   EstadoInicial :integer; {Estado inicial del port de entrada para los sensores}
   PortOut       :integer; {Port de salida}
   PortIn        :integer; {Port de entrada para los sensores}

{***************************************************************************}
{Lo que sigue es para el el control de la i-723:}
{***************************************************************************}

procedure Inicializar(PortID:integer);
begin
     PortOut:= PortID;
     PortIn:= (PortID + 1);
end; {Inicializar}

procedure EscribeMotor(MotorID :integer; Accion :TEstadoMotor);
var
   EstadoSalida :byte;
   EstadoTemp   :byte;
begin
     EstadoTemp:= Port[PortOut];
     EstadoSalida:= Port[PortOut];
     if MotorID = 1 then
     begin
          case Accion of
               DA: EstadoSalida:=((EstadoSalida or 12)-8);
               IZ: EstadoSalida:=((EstadoSalida or 12)-4);
               ALTO: EstadoSalida:=(EstadoTemp or 12)-12;
          else
              EstadoSalida:= EstadoTemp;
          end; {case}
     end; {if-then}
    if MotorID = 2 then
     begin
          case Accion of
               DA: EstadoSalida:= ((EstadoSalida or 48) - 32);
               IZ: EstadoSalida:= ((EstadoSalida or 48) - 16);
               ALTO: EstadoSalida:= (EstadoTemp or 48) - 48;
          else
              EstadoSalida:=EstadoTemp;
          end; {case}
     end; {if-then}
     if MotorID = 3 then
     begin
          case Accion of
               DA: EstadoSalida:=((EstadoSalida or 192) - 128);
               IZ: EstadoSalida:=((EstadoSalida or 192) - 64);
               ALTO: EstadoSalida:=(EstadoTemp or 192) - 192;
          else
              EstadoSalida:=EstadoTemp;
          end; {case}
     end; {if-then}
     if (MotorID = 123) or (MotorID = 132) or (MotorID = 213) or
        (MotorID = 231) or (MotorID = 312) or (MotorID = 321) then
     begin
          case Accion of
               DA: EstadoSalida:=((EstadoSalida or 63)-42);
               IZ: EstadoSalida:=((EstadoSalida or 63)-21);
               ALTO: EstadoSalida:=(EstadoTemp or 63)-63;
          else
              EstadoSalida:=EstadoTemp;
          end; {case}
     end; {if-then}
     if (MotorID = 12) or (MotorID = 21) then
     begin
          case Accion of
               DA: EstadoSalida:=((EstadoSalida or 15)-5);
               IZ: EstadoSalida:=((EstadoSalida or 15)-10);
               ALTO: EstadoSalida:=(EstadoSalida or 15)-15;
          else
              EstadoSalida:=EstadoTemp;
          end; {case}
     end; {if-then}
     if (MotorID = 13) or (MotorID = 31) then
     begin
          case Accion of
               DA: EstadoSalida:=((EstadoSalida or 51)-17);
               IZ: EstadoSalida:=((EstadoSalida or 51)-34);
               ALTO: EstadoSalida:=(EstadoSalida or 51)-51;
          else
              EstadoSalida:=EstadoTemp;
          end; {case}
     end; {if-then}
     if (MotorID = 23) or (MotorID = 32) then
     begin
          case Accion of
               DA: EstadoSalida:=((EstadoSalida or 60)-20);
               IZ: EstadoSalida:=((EstadoSalida or 60)-40);
               ALTO: EstadoSalida:=(EstadoSalida or 60)-60;
          else
              EstadoSalida:=EstadoTemp;
          end; {case}
     end; {if-then}

     port[PortOut]:=EstadoSalida;
end; {EscribeMotor}

procedure EscribeSalida(ReleID: integer; Accion :boolean);
var
   EstadoSalida :byte;
   EstadoTemp   :byte;
begin
     EstadoSalida:= Port[PortOut];
     EstadoTemp:= Port[PortOut];

     if ReleID = 1 then
     begin
          case Accion of
          true: EstadoSalida:= (EstadoSalida or 1);
          false: EstadoSalida:= ((EstadoSalida or 1) - 1);
          else
              EstadoSalida:= EstadoTemp;
          end; {case}
     end; {if-then}

     if ReleID = 2 then
     begin
          case Accion of
          true: EstadoSalida:= (EstadoSalida or 2);
          false: EstadoSalida:= ((EstadoSalida or 2) - 2);
          else
              EstadoSalida:= EstadoTemp;
          end; {case}
     end; {if-then}

     if (ReleID = 12) or (ReleID = 21) then
     begin
          case Accion of
          true: EstadoSalida:= (EstadoSalida or 192);
          false: EstadoSalida:= ((EstadoSalida or 192) - 192);
          else
              EstadoSalida:= EstadoTemp;
          end; {case}
     end; {if-then}

     Port[PortOut]:= EstadoSalida;
end; {EscribeSalida}

function LeeSensor(senID :integer) :boolean;
begin
{En esta función no utilizo GetBit pues así es más óptima:}
     if port[PortIn] = EstadoInicial then
        LeeSensor:= false;
     case senID of
     1: begin
             LeeSensor:= not((port[PortIn] and 64) = 64);
        end;
     2: begin
             LeeSensor:= not((port[PortIn] and 32) = 32);
        end;
     3: begin
             LeeSensor:= not((port[PortIn] and 16) = 16);
        end;
     4: begin
             LeeSensor:= not((port[PortIn] and 8) = 8);
        end;
     else LeeSensor:= false;
     end; {Case}
end; {LeeSensor}

{***************************************************************************}
{Lo que sigue es para el componente propiamente dicho:}
{ACA***************************************************************************}
procedure Register;
begin
     RegisterComponents('Simple Informática', [TControl723]);
end; {Register}

procedure TControl723.Change;
begin
     if Assigned(FOnChange) then FOnChange(self);
end; {Change}

procedure TControl723.Reset;
begin
     Motor1:= ALTO;
     Motor2:= ALTO;
     Motor3:= ALTO;
     Salida1:= false;
     Salida2:= false;
     GetSensor(1);
     GetSensor(2);
     GetSensor(3);
     GetSensor(4);
     Change; {Dispara el evento OnChange}
end; {Reset}

procedure TControl723.TestSensores(Sender :TObject);
begin
     if FSensor1 <> LeeSensor(1) then Change;
     if FSensor2 <> LeeSensor(2) then Change;
     if FSensor3 <> LeeSensor(3) then Change;
     if FSensor4 <> LeeSensor(4) then Change;
end; {TestSensores}

constructor TControl723.Create(AOwner :TComponent);
begin
     inherited Create(AOwner);
     tmrSensores:= TTimer.Create(self);
     tmrSensores.interval:= 1;
     tmrSensores.enabled:= true;
     tmrSensores.OnTimer:= TestSensores;
     Port:= LPT1;
     Reset;
end; {Create}

destructor TControl723.Destroy;
begin
     tmrSensores.Destroy;{}
     inherited Destroy;
end; {Destroy}

procedure TControl723.SetPort(Value :TPort);
begin
     if FPort <> Value then
     begin
          FPort:= Value;
          case Value of
          LPT1: Inicializar(DirLPT1);
          LPT2: Inicializar(DirLPT2);
          LPT3: Inicializar(DirLPT3);
          end; {case}
          Reset;
     end; {if-then}
end; {SetPort}

procedure TControl723.SetMotor(Index :integer; Value :TEstadoMotor);
begin
{Este case debe ejecutarse antes de que el evento Change sea disparado:}
     EscribeMotor(Index, Value);
     Case Index of
     1: if FMotor1 <> Value then
        begin
             FMotor1:= Value;
             Change;
        end; {if-then}
     2: if FMotor2 <> Value then
        begin
             FMotor2:= Value;
             Change;
        end; {if-then}
     3: if FMotor3 <> Value then
        begin
             FMotor3:= Value;
             Change;
        end; {if-then}
     end; {case}
end; {SetMotor}

procedure TControl723.SetSalida(Index :integer; Value :boolean);
begin
     EscribeSalida(Index, Value);
     Case Index of
     1: if FSalida1 <> Value then
        begin
             FSalida1:= Value;
             Change;
        end; {if-then}
     2: if FSalida2 <> Value then
        begin
             FSalida2:= Value;
             Change;
        end; {if-then}
     end; {case}
end; {SetSalida}

function TControl723.GetSensor(Index :integer): boolean;
begin
     case Index of
     1: FSensor1:= LeeSensor(Index);
     2: FSensor2:= LeeSensor(Index);
     3: FSensor3:= LeeSensor(Index);
     4: FSensor4:= LeeSensor(Index);
     end; {case}
     Result:= LeeSensor(Index);
end; {GetSensor}

end.
