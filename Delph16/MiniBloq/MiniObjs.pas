unit MiniObjs;

interface
uses
    Classes, Graphics, Controls, Buttons,
    StdCtrls, ExtCtrls, Menus, Forms, WinTypes,
    WinProcs, SysUtils, Spin, {Dialogs, {aca: Dialogs see va al customizar los diálogos.}
    frmMsg,
    i723_v20,
    Math11;

const
  {Constantes para el tamaño en pantalla de los objetos:}
     NORMAL_WIDTH = 130; {<-Ancho de los objetos del script por defecto.}
     NORMAL_HEIGHT = 35; {<-Alto de los objetos del script por defecto.}
  {Constantes para el grabado en archivos:}
     CMOTOR      = 1;
     CRELAY      = 2;
     CBEGIN_LOOP = 3;
     CEND_LOOP   = 4;
     CEXIT_LOOP  = 5;
     CBEGIN_IF   = 6;
     CEND_IF     = 7;
     CVARIABLE   = 8;
     CTIMER      = 9;
type
{Herramientas posibles:}
    TTools = (Selector, MoveObj, Motor, Relay, IfThen, Loop, ExitLoop, Variable, Timer);
{Utilizado en la evaluación de variables:}
    TValue = class(TObject)
             Value :extended;
    end; {TValue}
{Utilizado para los archivos:}
    TScriptRec = record
               ScriptObj :word; {<-Es el objeto a crear.}
               Objs      :string[8]; {<-Son guardados los objetos sobre los que se actúa,
                                        como los motores, las variables (en los IfThen), etc.}
               Op        :string[2]; {<-Operador: Sólo para IfThen.}
               Action    :string; {<-En las variables y los IfThen, aquí se guardan
                                     las expresiones matemáticas. En los motores y
                                     relés la acción.}
    end; {TScriptRec}
{Objetos de los scripts ("bloques"):}
    TScriptObj = class(TPanel)
                 public
                       imgIcon, imgArrowNext :TImage;
                       Prev, Next :TScriptObj; {<-Punteros para enlazar la lista.}
                       constructor Create(AOwner: TComponent); override;
                       destructor Destroy; override;
                       {Cambios en los eventos que ya posee:}
                       procedure Click; override;
                       procedure OnExprKeyPress(Sender: TObject; var Key :char);
    end; {TScriptObj}
    TMotor = class(TScriptObj)
             public
                   Out1, Out2, Out3 :TCheckBox;
                   lblAction        :TLabel;{}
                   {lblAction        :TPanel;{}
             public
                   constructor Create(AOwner: TComponent); override;
                   destructor Destroy; override;
    end; {TMotor}
    TRelay = class(TScriptObj)
             public
                   Out1, Out2 :TCheckBox;
                   lblAction        :TLabel;{}
                   constructor Create(AOwner: TComponent); override;
                   destructor Destroy; override;
    end; {TMotor}
    TEndIfThen = class; {<-Forward declaration para usar en TBeginIfThen.}
    TBeginIfThen = class(TScriptObj)
                   protected
                            procedure OnClickCboObj(Sender: TObject);
                            procedure OnEnterCboObj(Sender: TObject);
                            {procedure OnKeyPressCboObj(Sender: TObject; var Key :char);{}
                   public
                         TheEnterString :string; {<-Va en public pues es necesario a la hora de abrir archivos.}
                         cboOp, cboObj, cboVal, cboAndOr :TComboBox;
                         chkMore :TCheckBox;
                         EndIfThen :TEndIfThen;
                         constructor Create(AOwner: TComponent); override;
                         destructor Destroy; override;
    end; {TIfThen}
    TEndIfThen = class(TScriptObj)
                 public
                       BeginIfThen :TBeginIfThen;
                       imgArrowUp :TImage;
                       constructor Create(AOwner: TComponent); override;
                       destructor Destroy; override;
    end; {TEndIfThen}
    TEndLoop = class; {<-Forward declaration para usar en TBeginObj.}
    TBeginLoop = class(TScriptObj)
                 public
                       EndLoop :TEndLoop;
                       constructor Create(AOwner: TComponent); override;
    end; {TBeginLoop}
    TExitLoop = class(TScriptObj)
                 public
                       EndLoop :TEndLoop;
                       constructor Create(AOwner: TComponent); override;
    end; {TBeginLoop}
    TEndLoop = class(TScriptObj)
               public
                     BeginLoop :TBeginLoop;
                     imgArrowUp :TImage;
                     constructor Create(AOwner: TComponent); override;
                     destructor Destroy; override;
    end; {TEndLoop}
    TVariable = class(TScriptObj)
                public
                      edtName, edtExpr :TEdit;
                      OldName          :string[8];
                      Expr             :string;
                      constructor Create(AOwner: TComponent); override;
                      destructor Destroy; override;
                      procedure OnEdtKeyPress(Sender: TObject; var Key :char);
                      procedure OnEdtExit(Sender: TObject);
    end; {TVariable}
    TMiniTimer = class(TScriptObj)
                 public
                       spinInterval :TSpinEdit;
                       constructor Create(AOwner: TComponent); override;
                       destructor Destroy; override;
    end; {TMiniTimer}

var
   IncTime    :word; {<-Utilizada para temporizar (con TMiniTimer en el proc. ExecuteObj).}
   VarCount   :word; {<-Guarda la cantidad de variables creadas.}
   VarList    :TStringList; {<-Lista de las variables de MiniBloq.}
   RunTime    :boolean; {<-Está en true si el programa está siendo ejecutado.}
   ActualTool :TTools; {<-Herramienta actualmente utilizada.}
   ActualObj  :TScriptObj; {<-Objeto al que se apunta actualmente. Utilizado en
                             tiempos de diseño y también de ejecusión.}
   FirstObj   :TScriptObj; {<-Es el puntero al primer objeto de la lista del script
                             En esta implementación, la lista está formada por este
                             objeto como primer elemento, por ActualObj como elemento
                             actual y cada elemento es del tipo TScriptObj.}
   RunTimeObj :TScriptObj; {<-Objeto actual en tiempo de ejecusión (RutnTime).}

   procedure ChangeActual(TheObj :TScriptObj);
   procedure NewClick(Sender :TObject);
 {ExecuteObj es la función que ejecuta cada "comando" (u objeto, mejor dicho) del
  script y devuelve el próximo comando a ser ejecutado.}
   function ExecuteObj(TheObj :TScriptObj) :TScriptObj;

implementation
uses
    frmMain1, {<-Form de edición de scripts de Minibloq.}
    frmTool1; {<-Form de la barra de herramientas de Minibloq.}

procedure ChangeActual(TheObj :TScriptObj);
begin
     TheObj.Color:= clAqua;
     if ActualObj <> TheObj then
        ActualObj.Color:= clSilver;
     ActualObj:= TheObj;
end; {ChangeActual}

procedure NewClick(Sender :TObject);
begin
{Cambia el foco y resalta el objeto actual (ActualObj):}
     if not RunTime then
     begin
          if ActualTool = MoveObj then {<-Movimiento de objetos.}
          begin
          end {else if-then}
          else
          begin {<-Selección de objetos.}
               ChangeActual(((Sender as TControl).Parent as TScriptObj));
          end; {else}
     end; {if-then}
end; {NewClick}

function ExecuteObj(TheObj :TScriptObj) :TScriptObj;
var
   Hour, Min, Sec, MSec1, MSec2, TimeCount, i, TempInt :word;
   intEvalType                                         :boolean;
   intEvalRes                                          :word;
   realEvalRes, TempReal                               :Extended;
   {Este procedure local a la función es el que evalúa los strings de los
   if-then, devolviendo el estado de las salidas y entradas o el resultado de
   una expresión matemática. Si la variable IntType es true entonces, se trata
   de un resultado entero, lo que indica que el string presente en el comboBox
   evaluado hace referencia a una Entrada/Salida:}
   procedure EvalString(strObj :string; var IntType: boolean;
                        var intRes :word; var realRes :Extended);
   begin
        IntType:= true; {<-Se presupone un resultado de tipo entero.}
        if strObj = 'MOTOR 1' then
        begin
             intRes:= LeeMotor(1)
        end {if-then}
        else if strObj = 'MOTOR 2' then
        begin
             intRes:= LeeMotor(2)
        end {else if-then}
        else if strObj = 'MOTOR 3' then
        begin
             intRes:= LeeMotor(3)
        end {else if-then}
        else if strObj = 'DERECHA' then
        begin
             intRes:= 1
        end {else if-then}
        else if strObj = 'IZQUIERDA' then
        begin
             intRes:= 2
        end {else if-then}
        else if strObj = 'ALTO' then
        begin
             intRes:= 0
        end {else if-then}
        else if strObj = 'SI' then
        begin
             intRes:= 1
        end {else if-then}
        else if strObj = 'NO' then
        begin
             intRes:= 0
        end {else if-then}
        else if strObj = 'RELE 1' then
        begin
             if LeeSalida(1) then {<-Le asigna el estado de la salida de relé (booleano) a un integer.}
                intRes:= 1
             else
                 intRes:= 0;
        end {else if-then}
        else if strObj = 'RELE 2' then
        begin
             if LeeSalida(2) then {<-Le asigna el estado de la salida de relé (booleano) a un integer.}
                intRes:= 1
             else
                 intRes:= 0;
        end {else if-then}
        else if strObj = 'SENSOR 1' then
        begin
             if LeeSensor(1) then {<-Le asigna el estado del sensor (booleano) a un integer.}
                intRes:= 1
             else
                 intRes:= 0;
        end {else if-then}
        else if strObj = 'SENSOR 2' then
        begin
             if LeeSensor(2) then {<-Le asigna el estado del sensor (booleano) a un integer.}
                intRes:= 1
             else
                 intRes:= 0;
        end {else if-then}
        else if strObj = 'SENSOR 3' then
        begin
             if LeeSensor(3) then {<-Le asigna el estado del sensor (booleano) a un integer.}
                intRes:= 1
             else
                 intRes:= 0;
        end {else if-then}
        else if strObj = 'SENSOR 4' then
        begin
             if LeeSensor(4) then {<-Le asigna el estado del sensor (booleano) a un integer.}
                intRes:= 1
             else
                 intRes:= 0;
        end {else if-then}
        else {Variables:}
        begin
           {Busca el valor de la variable en la tabla:}
             realRes:= (VarList.objects[VarList.IndexOf(strObj)] as TValue).Value;
           {El resultado es un número real, no un entero:}
             IntType:= false;
        end; {else}
   end; {EvalString}

begin {ExecuteObj:}
     if TheObj = nil then
     begin
          Result:= nil;
          Exit;
     end; {if-then}
     if TheObj is TMotor then
     begin
          if (TheObj as TMotor).Out1.checked then
          begin
               if (TheObj as TMotor).lblAction.caption = 'X' then
                  EscribeMotor(1, 0)
               else
               if (TheObj as TMotor).lblAction.caption = '->' then
                    EscribeMotor(1, 1)
               else
                   EscribeMotor(1, 2);
          end; {if-then}
          if (TheObj as TMotor).Out2.checked then
          begin
               if (TheObj as TMotor).lblAction.caption = 'X' then
                  EscribeMotor(2, 0)
               else
               if (TheObj as TMotor).lblAction.caption = '->' then
                    EscribeMotor(2, 1)
               else
                   EscribeMotor(2, 2);
          end; {if-then}
          if (TheObj as TMotor).Out3.checked then
          begin
               if (TheObj as TMotor).lblAction.caption = 'X' then
                  EscribeMotor(3, 0)
               else
               if (TheObj as TMotor).lblAction.caption = '->' then
                    EscribeMotor(3, 1)
               else
                   EscribeMotor(3, 2);
          end; {if-then}
          Result:= TheObj.Next;
     end {if-then}
     else if TheObj is TRelay then
     begin
          if (TheObj as TRelay).Out1.checked then
          begin
               if (TheObj as TRelay).lblAction.caption = '0' then
                  EscribeSalida(1, 0)
               else
                    EscribeSalida(1, 1);
          end; {if-then}
          if (TheObj as TRelay).Out2.checked then
          begin
               if (TheObj as TRelay).lblAction.caption = '0' then
                  EscribeSalida(2, 0)
               else
                    EscribeSalida(2, 1);
          end; {if-then}
          Result:= TheObj.Next;
     end {else if-then}
     else if (TheObj is TVariable) then
     begin
       try
          {Evaluación de la expresión:}
        if VarList.IndexOf((TheObj as TVariable).edtName.Text) > -1 then
        begin {<-Este if-then chequea si existe la variable en la tabla.}
          if ((TheObj as TVariable).edtExpr.text = '') then
          begin
               (TheObj as TVariable).edtExpr.Text:= '0';
               (VarList.Objects[VarList.IndexOf((TheObj as TVariable).edtName.Text)] as TValue).Value:= 0;
          end; {if-then}
          try
             (TheObj as TVariable).expr:= (TheObj as TVariable).edtExpr.Text;
             expression:= (TheObj as TVariable).edtExpr.text;
             ErrorParser:= false;
             ErrorCodeParser:= NO_ERROR; 
             (VarList.objects[VarList.IndexOf((TheObj as TVariable).edtName.Text)] as TValue).Value:= Parser(1);
             if (ErrorParser or (ErrorCodeParser <> NO_ERROR)) then
             begin
                  Screen.Cursor:= crDefault;
                  frmMsg.ShowMsg('Error en la expresión', strErrorCode,
                                 'Un 0 será asignado a la variable.', true, false);
                  {MessageDlg(strErrorCode + ' ' +
                             'Un 0 será asignado a la variable.', mtInformation,[mbOK] , 0);{}
                  ((VarList.objects[VarList.IndexOf((TheObj as TVariable).edtName.Text)] as TValue).Value):= 0;
             end; {if-then}
          except
                Screen.Cursor:= crDefault;
                frmMsg.ShowMsg('Error en la expresión', strErrorCode,
                               'Un 0 será asignado a la variable.', true, false);
                (VarList.objects[VarList.IndexOf((TheObj as TVariable).edtName.Text)] as TValue).Value:= 0;
                Result:= TheObj.Next;
          end; {try-except}
        end; {if-then}
       finally
          Screen.Cursor:= crDefault;
          {Str((VarList.objects[VarList.IndexOf((TheObj as TVariable).edtName.Text)] as TValue).Value, strAux);
          frmEditor.Caption:= strAux;{}
          Result:= TheObj.Next;
       end; {try-finally}
     end {else if-then}
     else if TheObj is TMiniTimer then
     begin
          DecodeTime(Now, Hour, Min, Sec, MSec2);
          TimeCount:= 0;
          i:= (TheObj as TMiniTimer).spinInterval.Value;
          TheObj.imgIcon.Visible:= false;
          frmTools.bbtnStep.enabled:= false; {<-aca:Esto depende del frmTools.}
          frmTools.bbtnClose.enabled:= false;
          while TimeCount < i do
          begin {Retardo:}
               Application.ProcessMessages;
               if not RunTime then
               begin
                    break;
               end; {if-then}
               DecodeTime(Now, Hour, Min, Sec, MSec1);
               if (MSec2 - MSec1) > 1 then
               begin
                    inc(TimeCount);
                   {Se ve el conteo en pantalla:}
                    TheObj.Caption:= IntToStr(TimeCount);
                    TheObj.Refresh;
               end; {if-then}
               DecodeTime(Now, Hour, Min, Sec, MSec2);
          end; {while}
          frmTools.bbtnStep.enabled:= true;
          TheObj.Caption:= '';
          TheObj.imgIcon.Visible:= true;
          TheObj.Refresh;
          (TheObj as TMiniTimer).spinInterval.Value:= i;
          Result:= TheObj.Next; {<-Continúa con el objeto siguiente (Next).}
     end {else if-then}
     else if TheObj is TBeginIfThen then
     begin {Cuando se trata de un BeginIfThen, hay que evaluar la condición, discriminando el tipo de objeto en cboObj:}
           {Para que no dé error (GPF) establesco la siguiente convención: Un IfThen vacío da verdadero (sigue con el Next):}
           if ((TheObj as TBeginIfThen).cboObj.text = '') or
              ((TheObj as TBeginIfThen).cboOp.text = '') or
              ((TheObj as TBeginIfThen).cboVal.text = '') then
           begin
                Result:= TheObj.Next;
                exit;
           end; {if-then}
           EvalString((TheObj as TBeginIfThen).cboObj.text, intEvalType, intEvalRes, realEvalRes);
           if intEvalType then {<-El resultado de la evaluación es entero.}
           begin
                TempInt:= intEvalRes;
                EvalString((TheObj as TBeginIfThen).cboVal.text, intEvalType, intEvalRes, realEvalRes);
                if (TheObj as TBeginIfThen).cboOp.text = '<>' then
                begin
                     if TempInt <> intEvalRes then {<-Evaluación final de la condición.}
                        Result:= TheObj.Next
                     else
                         Result:= (TheObj as TBeginIfThen).EndIfThen;
                end {if-then}
                else if (TheObj as TBeginIfThen).cboOp.text = '=' then
                begin
                     if TempInt = intEvalRes then {<-Evaluación final de la condición.}
                        Result:= TheObj.Next
                     else
                         Result:= (TheObj as TBeginIfThen).EndIfThen;
                end {else if-then}
                else
                begin
                     Screen.Cursor:= crDefault;
                     {MessageDlg('No hay condición válida para evaluar.', mtInformation,[mbOK] , 0); {}
                     frmMsg.ShowMsg('Error en la expresión', '',
                                    'No hay condición válida para evaluar.', true, false);
                     Screen.Cursor:= crHourGlass;
                end; {else}
           end {if-then}
           else {<-"if NOT(IntEvalType)" then...}
           begin
                TempReal:= RealEvalRes; {<-Aquí está contenido el valor de la variable del cboObj.}
                try  {Dentro de este bloque try-except se efectúa la evaluación de la expresión de cboVal:}
                   expression:= (TheObj as TBeginIfThen).cboVal.text;
                   ErrorParser:= false;
                   ErrorCodeParser:= NO_ERROR;
                   RealEvalRes:= Parser(1); {<-Asignación del resultado.}
                   if (ErrorParser or (ErrorCodeParser <> NO_ERROR)) then
                   begin
                        Screen.Cursor:= crDefault;
                        RealEvalRes:= 0;
                        {MessageDlg(strErrorCode, mtInformation,[mbOK] , 0); {}
                        frmMsg.ShowMsg('Error en la expresión', strErrorCode,
                                    'Un 0 será asignado a la variable.', true, false);
                   end; {if-then}
                except
                      Screen.Cursor:= crDefault;
                      RealEvalRes:= 0;
                      frmMsg.ShowMsg('Error en la expresión', strErrorCode,
                                    'Un 0 será asignado a la variable.', true, false);
                      Result:= TheObj.Next;
                end; {try-except}
              {Discrimina el operador para armar la condición del IfThen:}
                if (TheObj as TBeginIfThen).cboOp.text = '<>' then
                begin
                     if TempReal <> RealEvalRes then {<-Evaluación final de la condición.}
                        Result:= TheObj.Next
                     else
                         Result:= (TheObj as TBeginIfThen).EndIfThen;
                end {if-then}
                else if (TheObj as TBeginIfThen).cboOp.text = '=' then
                begin
                     if TempReal = RealEvalRes then {<-Evaluación final de la condición.}
                        Result:= TheObj.Next
                     else
                         Result:= (TheObj as TBeginIfThen).EndIfThen;
                end {else if-then}
                else if (TheObj as TBeginIfThen).cboOp.text = '<=' then
                begin
                     if TempReal <= RealEvalRes then {<-Evaluación final de la condición.}
                        Result:= TheObj.Next
                     else
                         Result:= (TheObj as TBeginIfThen).EndIfThen;
                end {else if-then}
                else if (TheObj as TBeginIfThen).cboOp.text = '>=' then
                begin
                     if TempReal >= RealEvalRes then {<-Evaluación final de la condición.}
                        Result:= TheObj.Next
                     else
                         Result:= (TheObj as TBeginIfThen).EndIfThen;
                end {else if-then}
                else if (TheObj as TBeginIfThen).cboOp.text = '>' then
                begin
                     if TempReal > RealEvalRes then {<-Evaluación final de la condición.}
                        Result:= TheObj.Next
                     else
                         Result:= (TheObj as TBeginIfThen).EndIfThen;
                end {else if-then}
                else if (TheObj as TBeginIfThen).cboOp.text = '<' then
                begin
                     if TempReal < RealEvalRes then {<-Evaluación final de la condición.}
                        Result:= TheObj.Next
                     else
                         Result:= (TheObj as TBeginIfThen).EndIfThen;
                end {else if-then}
                else
                begin
                     Screen.Cursor:= crDefault;
                     {MessageDlg('No hay condición válida para evaluar.', mtInformation,[mbOK] , 0); {}
                     frmMsg.ShowMsg('Error en la expresión', '',
                                    'No hay condición válida para evaluar.', true, false);
                     Screen.Cursor:= crHourGlass;
                end; {else}
           end; {else}
     end {else if-then}
     else if (TheObj is TEndIfThen) then
     begin
          Result:= TheObj.Next; {<-No hace nada, sólo pasa al próximo objeto.}
     end {else if-then}
     else if (TheObj is TBeginLoop) then
     begin
          Result:= TheObj.Next; {<-No hace nada, sólo pasa al próximo objeto.}
     end {else if-then}
     else if (TheObj is TEndLoop) then
     begin
          Result:= (TheObj as TEndLoop).BeginLoop; {<-No hace nada, sólo salta al BeginLoop.}
     end {else if-then}
     else if (TheObj is TExitLoop) then
     begin
          Result:= (TheObj as TExitLoop).EndLoop.Next; {<-No hace nada, sólo salta al BeginLoop.}
     end; {else if-then}
end; {ExcuteObj}

{************************************************************************
 * COMIENZAN LAS IMPLEMENTACIONES DE LOS OBJETOS:                       *
{************************************************************************}

constructor TScriptObj.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
{Apariencia:}
     color:= clSilver;
     width:= NORMAL_WIDTH;
     height:= NORMAL_HEIGHT;
{Icono:}
     imgIcon:= TImage.Create(self); {<-Crea el control image que contiene el "ícono".}
     imgIcon.parent:= self;
     imgIcon.AutoSize:= true;
     imgIcon.Left:= 4; {<-La imagen está un poco alejada del borde.}
     imgIcon.Top:= 4;
{Flecha Next:}
     imgArrowNext:= TImage.Create(self); {<-Image con la flecha hacia el siguiente ScriptObj.}
     imgArrowNext.parent:= self;
     imgArrowNext.AutoSize:= true;
     imgArrowNext.Picture:= frmEditor.imgArrowNext.Picture; {Ojo: Esta línea depende de otra UNIT: La del frmEditor.}
     imgArrowNext.Left:= (Width div 2) - (imgArrowNext.Width div 2); {<-La imagen contra el "bottom" y centrada.}
     imgArrowNext.Top:= Height - imgArrowNext.Height - 4;{}
{Lista:}
     Prev:= nil; {<-Prev y Next no apuntan a nada y deben ser puestos a nil.}
     Next:= nil;
end; {TScriptObj.Create}

destructor TScriptObj.Destroy;
begin
{Liberación de la memoria:}
     imgIcon.Free;
     imgArrowNext.Free;
     inherited Destroy;
end; {TScriptObj.Destroy}

procedure TScriptObj.OnExprKeyPress(Sender: TObject; var Key :char);
begin
     Key:= UpCase(Key); {<-Sólo mayúsculas.}
end; {TScriptObj.OnKeyPress}

Procedure TScriptObj.Click;
begin
     inherited Click;
{Cambia el foco (ActualObj):}
     if not RunTime then
     begin
          Color:= clAqua;
          if ActualObj <> self then
             ActualObj.Color:= clSilver;
          ActualObj:= Self;
     end; {else}
end; {TScriptObj.Click}

constructor TMotor.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
     imgIcon.Picture.Bitmap:= frmTools.spdMotor.Glyph; {<-Ojo: Depende del frmTools (unit frmTool1).}
{Checks de las Salidas:}
     Out1:= TCheckBox.Create(self); {<-Crea el control image que contiene el "ícono".}
     Out1.parent:= self;
     Out1.Caption:= ' 1';
     Out1.width:= width div 5;
     Out1.Left:= imgIcon.Left + imgIcon.width + 2; {<-La imagen está un poco alejada del borde.}
     Out1.Top:= 4;
     Out2:= TCheckBox.Create(self); {<-Crea el control image que contiene el "ícono".}
     Out2.parent:= self;
     Out2.Caption:= ' 2';
     Out2.width:= Out1.width;
     Out2.Left:= Out1.left + Out1.width; {<-La imagen está un poco alejada del borde.}
     Out2.Top:= 4;
     Out3:= TCheckBox.Create(self); {<-Crea el control image que contiene el "ícono".}
     Out3.parent:= self;
     Out3.Caption:= ' 3';
     Out3.width:= Out1.width;
     Out3.Left:= Out2.left + Out2.width; {<-La imagen está un poco alejada del borde.}
     Out3.Top:= 4;
     lblAction:= TLabel.Create(self); {<-Crea el control image que contiene el "ícono".}
     {lblAction:= TPanel.Create(self);{}
     lblAction.parent:= self;
     lblAction.Font.Color:= clRed;
     lblAction.Font.Size:= 18;
     lblAction.AutoSize:= true;{}
     lblAction.Caption:= 'X';
     lblAction.Left:= Out3.left + Out3.width + 1; {<-La imagen está un poco alejada del borde.}
     lblAction.Transparent:= true;{}
     lblAction.Top:= 4;
end; {TMotor.Create}

destructor TMotor.Destroy;
begin
{Liberación de la memoria:}
     Out1.Free;
     Out2.Free;
     Out3.Free;
     lblAction.Free;
     inherited Destroy;
end; {TMotor.Destroy}

procedure TBeginIfThen.OnEnterCboObj(Sender :TObject);
var
   strAux :string;
   i      :word;
begin
{La idea de este procedimiento es actualizar la lista de variables en el
 cboObj. De esta forma, laas listas sólo se actualizan en aquellos ifThen
 en los que se clickea.}
{Primero actualiza la lista de variables:}
     strAux:= cboObj.Items[cboObj.ItemIndex];
     cboObj.Clear;
     cboObj.Items.Add('MOTOR 1');
     cboObj.Items.Add('MOTOR 2');
     cboObj.Items.Add('MOTOR 3');
     cboObj.Items.Add('RELE 1');
     cboObj.Items.Add('RELE 2');
     cboObj.Items.Add('SENSOR 1');
     cboObj.Items.Add('SENSOR 2');
     cboObj.Items.Add('SENSOR 3');
     cboObj.Items.Add('SENSOR 4');
     if VarList.Count > 0 then
     begin
          for i:= 0 to (VarList.Count - 1) do
          begin
               cboObj.Items.Add(VarList.Strings[i]);
          end; {for i}
     end; {if-then}
     cboObj.ItemIndex:= cboObj.Items.IndexOf(strAux);
end; {TBeginIfThen.OnEnterCboObj}

procedure TBeginIfThen.OnClickCboObj(Sender :TObject);
var
   TempCbo :TComboBox;
   TempObj :TScriptObj;
begin
     if TheEnterString = (Sender as TComboBox).text then exit; {<-Si no hubo cambios sale del proc.}
{Ahora actualiza los otros ComboBoxes del "bloque""}
     TempCbo:= Sender as TComboBox;
     TempObj:= TempCbo.Parent as TScriptObj;
     cboOp.Parent:= frmEditor.ScrollBox; {<-Cambio temoporal del parent para que no dé GPF.}
     cboVal.Parent:= frmEditor.ScrollBox;
     if (TempCbo.text = 'MOTOR 1') or (TempCbo.text = 'MOTOR 2') or
        (TempCbo.text = 'MOTOR 3') then
     begin
          cboOp.Clear;
          cboOp.items.add('<>');
          cboOp.items.add('=');
          cboVal.Clear;
          cboVal.style:= csDropDownList;
          cboVal.items.add('MOTOR 1');
          cboVal.items.add('MOTOR 2');
          cboVal.items.add('MOTOR 3');
          cboVal.items.add('ALTO');
          cboVal.items.add('DERECHA');
          cboVal.items.add('IZQUIERDA');
     end
     else if (TempCbo.text = 'RELE 1') or (TempCbo.text = 'RELE 2') then
     begin
          cboOp.Clear;
          cboOp.items.add('<>');
          cboOp.items.add('=');
          cboVal.Clear;
          cboVal.style:= csDropDownList;
          cboVal.items.add('RELE 1');
          cboVal.items.add('RELE 2');
          cboVal.items.add('SI');
          cboVal.items.add('NO');
     end {else if-then}
     else if (TempCbo.text = 'SENSOR 1') or (TempCbo.text = 'SENSOR 3') or
             (TempCbo.text = 'SENSOR 2') or (TempCbo.text = 'SENSOR 4') then
     begin
          cboOp.Clear;
          cboOp.items.add('<>');
          cboOp.items.add('=');
          cboVal.Clear;
          cboVal.style:= csDropDownList;
          cboVal.items.add('SENSOR 1');
          cboVal.items.add('SENSOR 2');
          cboVal.items.add('SENSOR 3');
          cboVal.items.add('SENSOR 4');
          cboVal.items.add('SI');
          cboVal.items.add('NO');
     end {else if-then}
     else
     begin
          cboOp.Clear;
          cboOp.items.add('<>');
          cboOp.items.add('=');
          cboOp.items.add('<');
          cboOp.items.add('>');
          cboOp.items.add('<=');
          cboOp.items.add('>=');
          cboVal.Clear;
          cboVal.Style:= csSimple;
     end; {else}
     cboOp.Parent:= TempObj; {<-Reestablezco el parent original.}
     cboVal.Parent:= TempObj;
     TheEnterString:= (Sender as TComboBox).Text;
end; {TBeginIfThen.OnChangeObj}

constructor TBeginIfThen.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
{Apariencia:}
     Width:= 2 * NORMAL_WIDTH;
     imgIcon.Picture:= frmEditor.imgIfThen.Picture; {<-Ojo: Depende del frmTools (unit frmTool1).}
     imgArrowNext.Picture:= frmEditor.imgArrowYes.Picture;
     imgArrowNext.top:= Height - imgArrowNext.Height - 3;
     imgArrowNext.Left:= Width - imgArrowNext.Width - 3;
     imgArrowNext.Visible:= false; {aca.}
     imgIcon.Left:= 1;
{ComboBoxes para la condición:}
     cboObj:= TComboBox.Create(Self);
     cboOp:= TComboBox.Create(Self);
     cboVal:= TComboBox.Create(Self);
     cboAndOr:= TComboBox.Create(Self);
     cboObj.visible:= false;
     cboOp.visible:= false;
     cboVal.visible:= false;
     cboAndOr.visible:= false;
     cboObj.Parent:= AOwner as TWinControl;
     cboOp.Parent:= AOwner as TWinControl;
     cboVal.Parent:= AOwner as TWinControl;
     cboAndOr.Parent:= AOwner as TWinControl;
     cboObj.Sorted:= true; {<-Los items serán agregados ordenadamente.}
     cboOp.Sorted:= true;
     cboVal.Sorted:= true;
     cboAndOr.Sorted:= true;
     cboVal.MaxLength:= 255;
{Llenado de los comboBoxes:}
     cboObj.Items.Add('MOTOR 1');
     cboObj.Items.Add('MOTOR 2');
     cboObj.Items.Add('MOTOR 3');
     cboObj.Items.Add('RELE 1');
     cboObj.Items.Add('RELE 2');
     cboObj.Items.Add('SENSOR 1');
     cboObj.Items.Add('SENSOR 2');
     cboObj.Items.Add('SENSOR 3');
     cboObj.Items.Add('SENSOR 4');
     cboOp.Items.Add('=');
     cboOp.Items.Add('<>');
     cboAndOr.Items.Add('Y');
     cboAndOr.Items.Add('O');
     cboAndOr.Items.Add(' ');
{Ubicación y otras propiedades:}
     cboObj.Parent:= Self; {Ahora, DESPUES DE HABER LLENADO LOS COMBO RECIEN
                            se puede reasignar el parent. Si no, da GPF.}
     cboOp.Parent:= self;
     cboVal.Parent:= self;
     cboAndOr.Parent:= self;
     cboObj.visible:= true;
     cboOp.visible:= true;
     cboVal.visible:= true;
     cboAndOr.visible:= true;
     cboObj.Style:= csDropDownList; {aca}
     cboOp.Style:= csDropDownList;
     cboVal.Style:= csDropDownList;
     cboAndOr.Style:= csDropDownList;
     cboObj.Color:= clWhite;
     cboOp.Color:= clWhite;
     cboVal.Color:= clWhite;
     cboAndOr.Color:= clWhite;
     cboObj.Width:= Width div 3;
     cboOp.Width:= Width div 7;
     cboVal.Width:= Width div 3;
     cboAndOr.Width:= Width div 8;
     cboObj.Top:= imgIcon.Top;
     cboOp.Top:= imgIcon.Top;
     cboVal.Top:= imgIcon.Top;
     cboAndOr.Top:= imgIcon.Top;
     cboObj.Left:= imgIcon.Left + imgIcon.Width + 1;
     cboOp.Left:= cboObj.Left + cboObj.Width;
     cboVal.Left:= cboOp.Left + cboOp.Width;
     cboAndOr.Left:= cboVal.Left + cboVal.Width;
     cboObj.OnClick:= OnClickCboObj;
     cboVal.OnKeyPress:= OnExprKeyPress; {<-Mayúsculas.}
     OnEnter:= OnEnterCboObj;
     {cboObj.Change{}
     TheEnterString:= '';
     cboAndOr.Visible:= false;
{EndIfThen:}
     EndIfThen:= TEndIfThen.Create(AOwner);
     EndIfThen.Parent:= frmEditor.ScrollBox;{<-Fuerzo el parent pues el parent
                                             del TBeginLoop aún no está asignado.}
     EndIfThen.BeginIfThen:= Self;
end; {TBeginIfThen.Create}

destructor TBeginIfThen.Destroy;
begin
{Liberación de la memoria:}
     cboObj.Free;
     cboOp.Free;
     cboVal.Free;
     cboAndOr.Free;
     inherited Destroy;
end; {TBeginIfThen.Destroy}

constructor TEndIfThen.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
     Width:= 2 * NORMAL_WIDTH;
     imgIcon.Picture:= frmEditor.imgIfThen.Picture; {<-Ojo: Depende del frmTools (unit frmTool1).}
     imgArrowUp:= TImage.Create(self); {<-Flecha de cierre de ciclo que apunta hacia arriba.}
     imgArrowUp.parent:= self;
     imgArrowUp.AutoSize:= true;
     imgArrowUp.Picture:= frmEditor.imgArrowUp.Picture; {Ojo: Esta línea depende de otra UNIT: La del frmEditor.}
     imgArrowUp.Left:= (Width div 2) + (Width div 4) -
                       (imgArrowUp.Width div 2);
     imgArrowUp.Top:= 4; {<-La imagen contra el "top" con un pequeño margen.}
     imgArrowNext.Picture:= frmEditor.imgArrowNo2.picture;
     Caption:= 'FinDecisión';
end; {TEndIfThen.Create}

destructor TEndIfThen.Destroy;
begin
{Liberación de la memoria:}
     imgArrowUp.Free;
     inherited Destroy;
end; {TEndIfThen.Destroy}

constructor TRelay.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
     imgIcon.Picture.Bitmap:= frmTools.spdRelay.Glyph; {<-Ojo: Depende del frmTools (unit frmTool1).}
{Checks de las Salidas:}
     Out1:= TCheckBox.Create(self); {<-Crea el control image que contiene el "ícono".}
     Out1.parent:= self;
     Out1.Caption:= ' 1';
     Out1.width:= width div 5;
     Out1.Left:= imgIcon.Left + imgIcon.width + 2; {<-La imagen está un poco alejada del borde.}
     Out1.Top:= 4;
     Out2:= TCheckBox.Create(self); {<-Crea el control image que contiene el "ícono".}
     Out2.parent:= self;
     Out2.Caption:= ' 2';
     Out2.width:= Out1.width;
     Out2.Left:= Out1.left + Out1.width; {<-La imagen está un poco alejada del borde.}
     Out2.Top:= 4;
     lblAction:= TLabel.Create(self); {<-Crea el control image que contiene el "ícono".}
     {lblAction:= TPanel.Create(self);{}
     lblAction.parent:= self;
     lblAction.Font.Color:= clRed;
     lblAction.Font.Size:= 18;
     lblAction.AutoSize:= true;{}
     lblAction.Caption:= '0';
     lblAction.Left:= Out2.left + Out2.width + 1; {<-La imagen está un poco alejada del borde.}
     lblAction.Transparent:= true;{}
     {lblAction.ParentColor:= true;{}
     lblAction.Top:= 4;
end; {TRelay.Create}

destructor TRelay.Destroy;
begin
{Liberación de la memoria:}
     Out1.Free;
     Out2.Free;
     lblAction.Free;
     inherited Destroy;
end; {TRelay.Destroy}

constructor TBeginLoop.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
{Apariencia:}
     Width:= 2 * NORMAL_WIDTH;
     imgArrowNext.Left:= (Width div 2) + (Width div 4) -
                         (imgArrowNext.Width div 2);
     imgIcon.Picture:= frmEditor.imgBeginLoop.Picture; {<-Ojo: Depende del frmTools (unit frmTool1).}
     Caption:= 'PrincipioCiclo';
{EndLoop:}
     EndLoop:= TEndLoop.Create(AOwner);
     EndLoop.Parent:= frmEditor.ScrollBox;{<-Fuerzo el parent pues el parent
                                             del TBeginLoop aún no está asignado.}
     EndLoop.BeginLoop:= Self;
end; {TBeginLoop.Create}

constructor TExitLoop.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
{Apariencia:}
     Width:= NORMAL_WIDTH;
     imgArrowNext.visible:= false;
     imgIcon.Picture.Bitmap:= frmTools.spdExitLoop.Glyph; {<-Ojo: Depende del frmTools (unit frmTool1).}
     Caption:= 'SalidaCiclo';
end; {TExitLoop.Create}

constructor TEndLoop.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
     Width:= 2 * NORMAL_WIDTH;
     imgIcon.Picture:= frmEditor.imgEndLoop.Picture; {<-Ojo: Depende del frmTools (unit frmTool1).}
     imgArrowUp:= TImage.Create(self); {<-Flecha de cierre de ciclo que apunta hacia arriba.}
     imgArrowUp.parent:= self;
     imgArrowUp.AutoSize:= true;
     imgArrowUp.Picture:= frmEditor.imgArrowUp.Picture; {Ojo: Esta línea depende de otra UNIT: La del frmEditor.}
     imgArrowUp.Left:= (Width div 2) + (Width div 4) -
                       (imgArrowNext.Width div 2);
     imgArrowUp.Top:= 4; {<-La imagen contra el "top" con un pequeño margen.}
     Caption:= 'FinCiclo';
end; {TEndLoop.Create}

destructor TEndLoop.Destroy;
begin
     imgArrowUp.Free;
     inherited Destroy;
end; {TEndLoop.Destroy}

procedure TVariable.OnEdtKeyPress(Sender: TObject; var Key :char);
begin
     Key:= UpCase(Key); {<-Sólo mayúsculas.}
     if not(Key in ['A'..'Z']) and not(ord(Key) = 8) then {<-Sólo números y letras.}
        Key:= chr(0);
   (*  if ((Sender as TEdit).Text = '') {and (Key in ['0'..'9']) }then {<-El primer caracter no puede ser un número.}
        Key:= chr(0);*)
end; {TVariable.OnEdtKeyPress}

procedure TVariable.OnEdtExit(Sender: TObject);
begin
   try
     {Si el nombre ya existe en la tabla, no hay nada que hacer. Pero si
      no existe hay que crear la variable).
      Luego, al borrar un TVariable, se debe ver si existen otros TVariable
      con el mismo Name.  En ese caso no se hace nada; de lo contrario se
      borra la variable de la tabla.};
     screen.cursor:= crHourGlass;
     if (Sender as TVariable).edtName.Text = '' then {<-No hay nombre asignado a la variable: No pasa nada.}
     begin
          exit;
     end; {if-then}
     if (VarList.IndexOf((Sender as TVariable).edtName.Text) <= -1) then {<-La variable no existe: Hay que crearla.}
     begin
          VarList.addObject((Sender as TVariable).edtName.Text, TValue.Create);
          (VarList.Objects[VarList.IndexOf((Sender as TVariable).edtName.Text)] as TValue).Value:= 0; {<-Inicializo en 0.}
     end; {if-then}
   finally
          screen.cursor:= crDefault;
   end; {try-finally}
end; {TVariable.OnEdtExit}

constructor TVariable.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
{Apariencia:}
     width:= 2 * NORMAL_WIDTH;
     imgIcon.Picture.Bitmap:= frmTools.spdVariable.Glyph; {<-Ojo: Depende del frmTools (unit frmTool1).}
{"Edits" para el name y la expresión asignada:}
     edtName:= TEdit.Create(self);
     edtName.Parent:= self;
     edtName.MaxLength:= 6; {aca: Más adelante ver esto: No anda bien con variables
                             de 7 u 8 caracteres de nombre.}
     edtName.Color:= clWhite;
     edtExpr:= TEdit.Create(self);
     edtExpr.Parent:= self;
     edtExpr.MaxLength:= 255;
     edtExpr.Color:= clWhite;
     edtName.Top:= imgIcon.Top;
     edtName.Width:= Width div 4;
     edtExpr.Top:= imgIcon.Top;
     edtExpr.Text:= '0';
     (*if VarCount < High(VarCount) then
     begin
          inc(VarCount);
          edtName.Text:= 'VAR' + IntToStr(VarCount);
          OldName:= edtName.Text;
     end; {if-then}*)
     edtName.Left:= imgIcon.Left + imgIcon.Width + 2;
     edtExpr.Left:= edtName.Left + edtName.width + 2;
     edtExpr.Width:= width - 5 - (edtName.Left + edtName.width);
     OnExit:= OnEdtExit;
     edtName.OnKeyPress:= OnEdtKeyPress; {<-Validación del nombre de las variables.}
     edtExpr.OnKeyPress:= OnExprKeyPress; {<-Mayúsculas.}
     imgArrowNext.Stretch:= true;
     imgArrowNext.Height:= Height - 1 - (edtExpr.Top + edtExpr.Height);
     imgArrowNext.top:= edtExpr.Top + edtExpr.Height;
end; {TVariable.Create}

destructor TVariable.Destroy;
var
   iObj      :TScriptObj;
   VarExists :boolean;
begin
     if VarList.IndexOf(edtName.Text) > -1 then {<-La variable existe en VarList.}
     begin
          VarExists:= false; {<-Se presupone que no hay más objetos referenciando a la variable.}
          iObj:= FirstObj;
          while iObj <> nil do
          begin
             iObj:= iObj.Next;
             if (iObj <> nil) then
               if (iObj is TVariable) and (iObj <> self) then
                  if (iObj as TVariable).edtName.Text = edtName.Text then
                  begin
                       VarExists:= true; {Si esto es verdadero, es porque no se puede borrar la variable.}
                       break;
                  end; {if-then}
          end; {while}
          if not(VarExists) then
             VarList.Delete(VarList.IndexOf(edtName.Text));
     end; {if-then}
     edtExpr.Free;
     edtName.Free;
     inherited Destroy;
end; {TVariable.Destroy}

constructor TMiniTimer.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
{Editor del Intervalo:}
     spinInterval:= TSpinEdit.Create(self);
     spinInterval.Parent:= Self;
     spinInterval.Increment:= 5;
     spinInterval.MinValue:= 1;
     spinInterval.MaxValue:= 1000;
     spinInterval.MaxLength:= 5;
     spinInterval.Color:= clWhite;
     spinInterval.AutoSize:= false;
     spinInterval.Value:= 10;
{Apariencia:}
     Alignment:= taLeftJustify; {<-Para ver el conteo en pantalla. Ver procedure ExecuteObj.}
     imgIcon.Picture.Bitmap:= frmTools.spdTimer.Glyph; {<-Ojo: Depende del frmTools (unit frmTool1).}
     imgArrowNext.Left:= imgArrowNext.Left - imgArrowNext.Width;
     spinInterval.Width:= Width div 2;
     spinInterval.Left:= Width - spinInterval.Width - 4;
     spinInterval.Top:= (Height div 2) - (spinInterval.Height div 2);
end; {TMiniTimer.Create}

destructor TMiniTimer.Destroy;
begin
     spinInterval.Free;
     inherited Destroy;
end; {TMiniTimer.Destroy}

end.
