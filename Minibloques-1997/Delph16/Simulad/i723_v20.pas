{Simple Informática.
 AUTOR: Julián Ulises da Silva Gillig.
 ULTIMA MODIFICACION: 4/7/1997.
 DESCRIPCION :Esta unit contiene todas las rutinas necesarias para
 controlar la inerfaz i-723, más dos rutinas de bjo nivel para agregar
 control de E/S a lenguajes que no lo tienen si esta unit formara parte
 de una DLL.
 COMPILACION: Para compilar en 32 bits, debe estar definido el identificador
 OS32. Si éste no se encuentra definido, se compilará en 16 bits.}

unit I723_v20;

interface

const
{Direcciones de E/S de los puertos paralelos:}
     LPT1 = 888;
     LPT2 = 956;
     LPT3 = 632;
{Cosntantes para las acciones de la interfaz:}
     ALTO = 0;
     DA   = 1;
     IZ   = 2;
     SI   = 1;
     NO   = 0;
{acaOS32}
var
{Variables para las funciones de la interfaz:}
   EstadoInicial :SmallInt; {Estado inicial del port de entrada para los sensores.}
   PortOut       :SmallInt; {Dirección del port de salida.}
   PortIn        :SmallInt; {Dirección del port de entrada para los sensores.}

{Rutinas para controlar la interfaz:}
   procedure Inicializar(PortID :SmallInt); export;
   procedure ApagaTodo; export;
   procedure EscribeMotor(MotorID :SmallInt; Accion :SmallInt); export;
   procedure EscribeSalida(ReleID, Accion :SmallInt); export;
   function LeeMotor(MotorID :SmallInt) :SmallInt; export;
   function LeeSalida(ReleID :SmallInt) :WordBool; export;
   function LeeSensor(SenID :SmallInt) :WordBool; export;

{Rutinas de bajo nivel:}
   procedure out(ID, Val: SmallInt); export;
   function inp(ID: SmallInt): SmallInt; export;

implementation

{************************************************************************}
{* Rutinas para controlar de la interfaz (16 y 32 bits):                               *}
{************************************************************************}

procedure ApagaTodo;
begin
     out(PortOut, 0);
end; {ApagaTodo}

procedure Inicializar(PortID :SmallInt);
begin
     case PortID of
     1: begin
             PortOut:= LPT1;
             PortIn:= (LPT1 + 1);
        end;
     2: begin
             PortOut:= LPT2;
             PortIn:= (LPT2 + 1);
        end;
     3: begin
             PortOut:= LPT3;
             PortIn:= (LPT3 + 1);
        end;
     end {case}
end; {Inicializar}

procedure EscribeMotor(MotorID :SmallInt; Accion :SmallInt);
var
   EstadoSalida :byte;
   EstadoTemp   :byte;
begin
     EstadoTemp:= inp(PortOut);
     EstadoSalida:= inp(PortOut);
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
               DA: EstadoSalida:= ((EstadoSalida or 252) - 168);
               IZ: EstadoSalida:= ((EstadoSalida or 252) - 84);
               ALTO: EstadoSalida:= ((EstadoTemp or 252) - 252);
          else
              EstadoSalida:=EstadoTemp;
          end; {case}
     end; {if-then}
     if (MotorID = 12) or (MotorID = 21) then
     begin
          case Accion of
               DA: EstadoSalida:= ((EstadoSalida or 60) - 40);
               IZ: EstadoSalida:= ((EstadoSalida or 60) - 20);
               ALTO: EstadoSalida:= ((EstadoSalida or 60) - 60);
          else
              EstadoSalida:=EstadoTemp;
          end; {case}
     end; {if-then}
     if (MotorID = 13) or (MotorID = 31) then
     begin
          case Accion of
               DA: EstadoSalida:=((EstadoSalida or 204) - 136);
               IZ: EstadoSalida:=((EstadoSalida or 204) - 68);
               ALTO: EstadoSalida:=(EstadoSalida or 204) - 204;
          else
              EstadoSalida:=EstadoTemp;
          end; {case}
     end; {if-then}
     if (MotorID = 23) or (MotorID = 32) then
     begin
          case Accion of
               DA: EstadoSalida:=((EstadoSalida or 240) - 160);
               IZ: EstadoSalida:=((EstadoSalida or 240) - 80);
               ALTO: EstadoSalida:=(EstadoSalida or 240) - 240;
          else
              EstadoSalida:=EstadoTemp;
          end; {case}
     end; {if-then}

     out(PortOut, EstadoSalida);
end; {EscribeMotor}

function LeeMotor(MotorID :SmallInt) :SmallInt;
var
   EstadoTemp :byte;
begin
     EstadoTemp:= inp(PortOut);
     case MotorID of
     1: begin
             EstadoTemp:= (EstadoTemp or 243);
             if ((EstadoTemp = 255) or (EstadoTemp = 243)) then
                LeeMotor:= ALTO;
             if (EstadoTemp = 247) then
                LeeMotor:= DA;
             if (EstadoTemp = 251) then
                LeeMotor:= IZ;
        end;
     2: begin
             EstadoTemp:= (EstadoTemp or 207);
             if ((EstadoTemp = 255) or (EstadoTemp = 207)) then
                LeeMotor:= ALTO;
             if (EstadoTemp = 223) then
                LeeMotor:= DA;
             if (EstadoTemp = 239) then
                LeeMotor:= IZ;
        end;
     3: begin
             EstadoTemp:= (EstadoTemp or 63);
             if ((EstadoTemp = 255) or (EstadoTemp = 63)) then
                LeeMotor:= ALTO;
             if (EstadoTemp = 127) then
                LeeMotor:= DA;
             if (EstadoTemp = 191) then
                LeeMotor:= IZ;
        end;
     end; {case}
end; {LeeMotor}

procedure EscribeSalida(ReleID, Accion :SmallInt);
var
   EstadoSalida :byte;
   EstadoTemp   :byte;
begin
     EstadoSalida:= inp(PortOut);
     EstadoTemp:= inp(PortOut);

     if ReleID = 1 then
     begin
          case Accion of
          SI: EstadoSalida:= (EstadoSalida or 1);
          NO: EstadoSalida:= ((EstadoSalida or 1) - 1);
          else
              EstadoSalida:= EstadoTemp;
          end; {case}
     end; {if-then}

     if ReleID = 2 then
     begin
          case Accion of
          SI: EstadoSalida:= (EstadoSalida or 2);
          NO: EstadoSalida:= ((EstadoSalida or 2) - 2);
          else
              EstadoSalida:= EstadoTemp;
          end; {case}
     end; {if-then}

     if (ReleID = 12) or (ReleID = 21) then
     begin
          case Accion of
          SI: EstadoSalida:= (EstadoSalida or 3);
          NO: EstadoSalida:= ((EstadoSalida or 3) - 3);
          else
              EstadoSalida:= EstadoTemp;
          end; {case}
     end; {if-then}

     out(PortOut, EstadoSalida);
end; {EscribeSalida}

function LeeSalida(ReleID :SmallInt) :WordBool;
var
   EstadoTemp :byte;
begin
     EstadoTemp:= inp(PortOut);

     case ReleID of
     1: if (EstadoTemp and 1) = 1 then
           LeeSalida:= true
        else
            LeeSalida:= false;
     2: if (EstadoTemp and 2) = 2 then
           LeeSalida:= true
        else
            LeeSalida:= false;
     end; {Case}
end; {LeeSalida}

function LeeSensor(SenID :SmallInt) :WordBool;
begin
     if inp(PortIn) = EstadoInicial then
        LeeSensor:= false;
     case SenID of
     1: begin
             LeeSensor:= not((inp(PortIn) and 64) = 64);
        end;
     2: begin
             LeeSensor:= not((inp(PortIn) and 32) = 32);
        end;
     3: begin
             LeeSensor:= not((inp(PortIn) and 16) = 16);
        end;
     4: begin
             LeeSensor:= not((inp(PortIn) and 8) = 8);
        end;
     else LeeSensor:= false;
     end; {Case}
end; {LeeSensor}


{$IFDEF OS32}
{************************************************************************}
{* Rutinas de bajo nivel (32 bits):                                     *}
{************************************************************************}

procedure out(ID, Val: SmallInt);
var
   dir  :word;
   dato :byte;
begin
   try
     dir:= word(ID);
     dato:= byte(Val);
     asm
          Mov  AL,dato
          Mov  DX,dir
          Out  DX,AL
     end; {asm}
   except
   end; {try-except}
end; {out para 32 bits}

function inp(ID: SmallInt): SmallInt;
var
   dir  :word;
   dato :byte;
begin
   try
     dir:= word(ID);
     asm
        Mov   DX,dir              {Carga en DX la dirección de I/O}
        In    AL,DX               {Lee la dirección}
        Xor   AH,AH               {Limpia el byte alto de AX}
        Mov   dato, AL
     end; {asm}
     inp:= dato;
   except
   end; {try-except}
end; {inp para 32 bits}

{$ELSE}
{************************************************************************}
{* Rutinas de bajo nivel (16 bits):                                     *}
{************************************************************************}

procedure out(ID, Val: SmallInt);
begin
     port[ID]:= Val;
end; {out para 16 bits}

function inp(ID: SmallInt): SmallInt;
begin
   inp:= port[ID];
end; {inp para 16 bits}
{$ENDIF}

begin
end.
