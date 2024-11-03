unit Frmmain1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, IniFiles,
  frmTool1, ExtCtrls,
  StdCtrls,
  MiniObjs,
  Spin,
  i723_v20,
  frmMsg,
  Math11;

type
  TfrmEditor = class(TForm)
    ScrollBox: TScrollBox;
    imgArrowNext: TImage;
    imgArrowYes: TImage;
    imgArrowUp: TImage;
    imgIfThen: TImage;
    imgArrowNo2: TImage;
    lblMotorAct: TLabel;
    imgBeginLoop: TImage;
    imgEndLoop: TImage;
    btnScale: TButton;
    tmrTimer: TTimer;
    pnlEvaluator: TPanel;
    pnlEval: TPanel;
    edtExpression: TEdit;
    edtResult: TEdit;
    lblExpr: TLabel;
    lblPort: TLabel;
    optLpt1: TRadioButton;
    optLpt2: TRadioButton;
    optLpt3: TRadioButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imgArrowNo2Click(Sender: TObject);
    procedure lblMotorActMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnScaleClick(Sender: TObject);
    procedure btnScaleKeyPress(Sender: TObject; var Key: Char);
    procedure btnScaleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tmrTimerTimer(Sender: TObject);
    procedure pnlEvalMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlEvalMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure optLpt1Click(Sender: TObject);
    procedure optLpt2Click(Sender: TObject);
    procedure optLpt3Click(Sender: TObject);
    procedure edtExpressionKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure PlaceObj;
  end;

var
  frmEditor: TfrmEditor;

implementation

{$R *.DFM}

procedure EvalExpr;
begin
   with frmEditor do
   begin
     if (edtExpression.text <> '') then
     begin
          try
             expression:= edtExpression.Text;
             ErrorParser:= false;
             ErrorCodeParser:= NO_ERROR;
             edtResult.Text:= FloatToStr(Parser(1));
             if (ErrorParser or (ErrorCodeParser <> NO_ERROR)) then
             begin
                  {ShowMsg('Error en la expresión:', strErrorCode,
                          'Revisa la expresión para encontrar el error.', True, false);{aca}
                  edtResult.Text:= 'ERROR';
             end; {if-then}
             edtExpression.SetFocus;
             exit;
          except
                {ShowMsg('Error en la expresión:', strErrorCode,
                        'Revisa la expresión para encontrar el error.', True, false);{aca}
                edtResult.Text:= 'ERROR';
                edtExpression.SetFocus;
          end; {try-except}
     end {if-then}
     else
     begin
          {ShowMsg('Error en la expresión:', 'No hay expresión para ser evaluada.',
                  '', True, false);
          edtExpression.Text:= ''; }
          edtExpression.SetFocus;
     end; {else}
   end; {with}
end; {EvalExpr}

{Este procedimiento posiciona automáticamente un objeto del script:}
procedure SetPos(TheObj :TScriptObj);
var
   iObj   :TScriptObj;
begin
     if (ActualObj is TBeginLoop) or (ActualObj is TBeginIfThen) then
     begin {<-Objetos tras un BeginLoop o un BeginIfThen.}
          TheObj.left:= ActualObj.left + (ActualObj.Width div 2);
          TheObj.top:= ActualObj.top + ActualObj.height;
     end {if-then}
     else {Cualqier otro objeto:}
     begin
          TheObj.left:= ActualObj.left;
          TheObj.top:= ActualObj.top + ActualObj.height;
     end; {else}

     if (TheObj is TBeginLoop) then {<-Ciclos (acomoda el EndLoop con respecto al BeginLoop).}
     begin
          (TheObj as TBeginLoop).EndLoop.top:= (TheObj as TBeginLoop).top +
                                               (TheObj as TBeginLoop).height;
          (TheObj as TBeginLoop).EndLoop.left:= (TheObj as TBeginLoop).left;
     end {if-then}
     else if (TheObj is TBeginIfThen) then {<-Decisiones (acomoda el EndIfThen con respecto al BeginIfThen).}
     begin
          (TheObj as TBeginIfThen).EndIfThen.top:= (TheObj as TBeginIfThen).top +
                                                   (TheObj as TBeginIfThen).height;
          (TheObj as TBeginIfThen).EndIfThen.left:= (TheObj as TBeginIfThen).left;
     end; {else}
end; {SetPos}

procedure TfrmEditor.FormClose(Sender: TObject; var Action: TCloseAction);
var
   iObj :TScriptObj;
   i, j :word;
   MiniBloqIni :TIniFile;
begin
        if RunTime then
           exit; {<-Por las dudas: No se puede salir en RunTime.}
        frmMessage.pnlOk.Caption:= 'Sí';
        frmMessage.pnlCancel.Caption:= 'No';
        ShowMsg('Atención', '¿Deseas grabar el programa antes de salir?', '',
                True, True);
        if frmMessage.ModalResult = mrOk then
           frmTools.bbtnSave.OnClick(frmTools.bbtnSave);
        frmMessage.pnlOk.Caption:= 'Aceptar';
        frmMessage.pnlCancel.Caption:= 'Cancelar';
{Liberación de la memoria y destrucción de objetos y tabla de variables:}
        Screen.Cursor:= crHourGlass;
        ActualObj:= FirstObj.Next; {<-Esto es para que al hacer luego en el FOR spdTrashClick(spdTrash)
                                      el procedimiento de borrado funcione, pues el FirstObj no se puede
                                      borrar.}
        iObj:= FirstObj.Next;
        i:= 0;
        while iObj <> nil do
        begin
             inc(i);
             iObj:= iObj.next;
        end; {while}
        for j:= 1 to i do
        begin
             frmTools.spdTrashClick(frmTools.spdTrash);
        end; {for j}

        ActualObj:= FirstObj;
        ActualObj.Next:= nil;
        VarList.Free;
        ApagaTodo; {<-Resetea la interface i723.}
        Screen.Cursor:= crDefault;

{Actualización del IniFile:}
        MiniBloqIni:= TIniFile.Create(ExtractFilePath(Application.ExeName) + 'MINIBLOQ.INI');
        if optLpt1.Checked then
           MiniBloqIni.WriteInteger('Hardware', 'Port', 1)
        else if optLpt2.Checked then
                MiniBloqIni.WriteInteger('Hardware', 'Port', 2)
        else if optLpt3.Checked then
                MiniBloqIni.WriteInteger('Hardware', 'Port', 3);
        MiniBloqIni.Free;
end;

procedure TfrmEditor.FormResize(Sender: TObject);
begin
     {Este código es para que minimice la barra de herramientas automáticamente
      al minimizar el form de edición de scripts:}
     (*if frmEditor.WindowState = wsMinimized then
     begin
          frmTools.Hide;
     end {if-then}
     else
     begin
          {frmTools.Show;}
          {frmtools.Visible:= true;
          {frmtools.FormStyle:= fsStayOnTop;{}
     end; {else}*)
end;

procedure TfrmEditor.FormShow(Sender: TObject);
var
   TempLabel :TLabel;
begin
{Crea y muestra el panel de comienzo (primer elemento de la lista del script):}
     FirstObj:= TScriptObj.Create(self);
     FirstObj.parent:= ScrollBox;
     FirstObj.left:= FirstObj.Width; {<-Posición.}
     FirstObj.top:= 0;
     FirstObj.imgIcon.OnClick:= imgArrowNo2.OnClick;
     FirstObj.imgArrowNext.OnClick:= imgArrowNo2.OnClick;
{Creación del label para el título del panel de comienzo:}
     TempLabel:= Tlabel.Create(Self);
     TempLabel.parent:= FirstObj;
     TempLabel.Top:= 3;
     TempLabel.Font.Color:= clBlue;
     TempLabel.caption:= 'Comienzo'; {<-Apariencia.}
     TempLabel.Left:= (FirstObj.Width div 2) - (TempLabel.Width div 2);
     TempLabel.OnClick:= imgArrowNo2.OnClick;
{Variables MUY IMPORTANTES:}
     ActualObj:= FirstObj;
     ActualObj.Color:= clAqua;
     ActualTool:= Selector;
     RunTime:= false;
     VarCount:= 0;
     VarList:= TStringList.Create;
end;

procedure TfrmEditor.PlaceObj;
var
   TempObj, iObj :TScriptObj;
   LoopCount     :integer;
begin
   if not RunTime then
   begin
     if (ActualObj is TExitLoop) or {<-No se puede agregar nada después de un TExitLoop.}
        ((ActualTool = ExitLoop) and {<-No puedo agregar un ExitLoop antes de algo que no sea EndIf/EndLoop}
         (not(ActualObj.Next is TEndIfThen) and
          not(ActualObj.Next is TEndLoop))) then
     begin
          frmTools.spdSelector.down:= true;
          if ActualObj.Next = nil then
          begin
              {MessageDlg('No hay ciclo del cual salir.',
                         mtInformation,[mbOK] , 0) {}
              frmMsg.ShowMsg('Atención', 'No hay ciclo del cual salir.',
                             '', true, false);
          end {if-then}
          else
              {MessageDlg('Una salida de ciclo no puede ser seguida de ' +
                         'otro bloque que no sea un FinDecisión o FinCiclo.',
                         mtInformation,[mbOK] , 0); {}
              frmMsg.ShowMsg('Atención', 'Una salida de ciclo no puede ser seguida de',
                             'otro bloque que no sea un FinDecisión o FinCiclo.', true, false);
          exit;
     end; {if-then}
     if (ActualTool = Selector) or (ActualTool = MoveObj) then
     begin
          exit; {<-No hace nada.}
     end {if-then}
     else if ActualTool = Motor then
     begin
          TempObj:= TMotor.Create(self);
         {Asigna los eventos necesarios:}
          (TempObj as TMotor).Out1.OnClick:= imgArrowNo2.OnClick;
          (TempObj as TMotor).Out2.OnClick:= imgArrowNo2.OnClick;
          (TempObj as TMotor).Out3.OnClick:= imgArrowNo2.OnClick;
          (TempObj as TMotor).lblAction.OnMouseDown:= lblMotorAct.OnMouseDown;
     end {else if-then}
     else if ActualTool = Relay then
     begin
          TempObj:= TRelay.Create(self);
         {Asigna los eventos necesarios:}
          (TempObj as TRelay).Out1.OnClick:= imgArrowNo2.OnClick;
          (TempObj as TRelay).Out2.OnClick:= imgArrowNo2.OnClick;
          (TempObj as TRelay).lblAction.OnMouseDown:= btnScale.OnMouseDown;
     end {else if-then}
     else if ActualTool = IfThen then
     begin
          TempObj:= TBeginIfThen.Create(self);
          TempObj.imgIcon.OnClick:= imgArrowNo2.OnClick;
          (TempObj as TBeginIfThen).EndIfThen.imgIcon.OnClick:= imgArrowNo2.OnClick;
          (TempObj as TBeginIfThen).EndIfThen.imgArrowUp.OnClick:= imgArrowNo2.OnClick;
          (TempObj as TBeginIfThen).EndIfThen.imgArrowNext.OnClick:= imgArrowNo2.OnClick;
          (TempObj as TBeginIfThen).cboObj.OnEnter:= imgArrowNo2.OnClick;
          (TempObj as TBeginIfThen).cboOp.OnEnter:= imgArrowNo2.OnClick;
          (TempObj as TBeginIfThen).cboVal.OnEnter:= imgArrowNo2.OnClick;
     end {else if-then}
     else if ActualTool = Loop then
     begin
          TempObj:= TBeginLoop.Create(self);
          TempObj.imgIcon.OnClick:= imgArrowNo2.OnClick;
          (TempObj as TBeginLoop).EndLoop.imgIcon.OnClick:= imgArrowNo2.OnClick;
          (TempObj as TBeginLoop).EndLoop.imgArrowUp.OnClick:= imgArrowNo2.OnClick;
          (TempObj as TBeginLoop).EndLoop.imgArrowNext.OnClick:= imgArrowNo2.OnClick;
     end {else if-then}
     else if ActualTool = Variable then
     begin
          TempObj:= TVariable.Create(self);
          (TempObj as TVariable).edtName.OnClick:= imgArrowNo2.OnClick;
          (TempObj as TVariable).edtExpr.OnClick:= imgArrowNo2.OnClick;
     end {else if-then}
     else if ActualTool = Timer then
     begin
          TempObj:= TMiniTimer.Create(self);
          (TempObj as TMiniTimer).spinInterval.OnClick:= imgArrowNo2.OnClick;
          (TempObj as TMiniTimer).spinInterval.OnKeyPress:= btnScale.OnKeyPress;
     end {else if-then}
     else if ActualTool = ExitLoop then
     begin
          TempObj:= TExitLoop.Create(self);
     end; {else if-then}
{Para todos los objetos sin importar su tipo específico:}
     TempObj.Parent:= ScrollBox;
     TempObj.imgIcon.OnClick:= imgArrowNo2.OnClick;
     TempObj.imgArrowNext.OnClick:= imgArrowNo2.OnClick;
     SetPos(TempObj); {<-Posiciona al TempObj correctamente EN PANTALLA.}
     TempObj.Color:= clAqua; {clAqua es el color del ScripObject con el foco actualmente.}
     TempObj.SetFocus;
     ActualObj.Color:= clSilver; {<-El objeto anterior pierde el foco.}

{Actualización de la lista de script:}
     if ActualObj.Next = nil then {<-Agregado de objetos:}
     begin
          ActualObj.Next:= TempObj;
          TempObj.Prev:= ActualObj;
          ActualObj:= TempObj;
          if (TempObj is TBeginLoop) then {<-Agregado de ciclos.}
          begin
               TempObj.Next:= (TempObj as TBeginLoop).EndLoop;
               (TempObj as TBeginLoop).EndLoop.Prev:= TempObj;
          end {if-then}
          else if (TempObj is TBeginIfThen) then {<-Agregado de decisiones.}
          begin
               TempObj.Next:= (TempObj as TBeginIfThen).EndIfThen;
               (TempObj as TBeginIfThen).EndIfThen.Prev:= TempObj;
          end; {else if-then}
     end {if-then}
     else {<-Inserción de objetos: PostInserción (El objeto es insertado entre el
             actual y el actual.next):}
     begin {Inserción:}
          if (TempObj is TBeginLoop) then {<-Inserción de Loops:}
          begin
               TempObj.Next:= (TempObj as TBeginLoop).EndLoop;
               (TempObj as TBeginLoop).EndLoop.Prev:= TempObj;
               (TempObj as TBeginLoop).EndLoop.Next:= ActualObj.Next;
               TempObj.Prev:= ActualObj;
               ActualObj.Next.Prev:= (TempObj as TBeginLoop).EndLoop;
               ActualObj.Next:= TempObj;
               ActualObj:= TempObj; {<-Cambia el objeto don el foco (u objeto actual).}
          end {if-then}
          else if (TempObj is TBeginIfThen) then {<-Inserción de Decisiones:}
          begin
               TempObj.Next:= (TempObj as TBeginIfThen).EndIfThen;
               (TempObj as TBeginIfThen).EndIfThen.Prev:= TempObj;
               (TempObj as TBeginIfThen).EndIfThen.Next:= ActualObj.Next;
               TempObj.Prev:= ActualObj;
               ActualObj.Next.Prev:= (TempObj as TBeginIfThen).EndIfThen;
               ActualObj.Next:= TempObj;
               ActualObj:= TempObj; {<-Cambia el objeto con el foco (u objeto actual).}
          end {else if-then}
          else if (TempObj is TExitLoop) then
          begin
               {Busca hasta encontrar un BeginLoop y pone como next a su EndLoop:}
               iObj:= ActualObj;
               LoopCount:= 1;
               while (LoopCount > 0) and (iObj.Prev <> nil) do
               begin
                    if (iObj is TBeginLoop) then
                    begin
                         Dec(LoopCount);
                    end {if-then}
                    else if (iObj is TEndLoop) then
                    begin
                         Inc(LoopCount);
                    end; {else if-then}
                    iObj:= iObj.Prev;
               end; {while}
               if LoopCount = 0 then
               begin
                    (TempObj as TExitLoop).EndLoop:= (iObj.Next as TBeginLoop).EndLoop;
                    TempObj.Next:= ActualObj.Next;
                    TempObj.Prev:= ActualObj;
                    ActualObj.Next.Prev:= TempObj;
                    ActualObj.Next:= TempObj;
                    ActualObj:= TempObj; {<-Cambia el objeto don el foco (u objeto actual).}
               end {if-then}
               else
               begin
                    TempObj.visible:= false;
                    {MessageDlg('No hay ciclo del cual salir.', mtInformation,[mbOK] , 0); {}
                    frmMsg.ShowMsg('Atención', 'No hay ciclo del cual salir.',
                                   '', true, false);
                    frmTools.spdSelector.Down:= true;
                    TempObj.Free;
                    Exit;
               end; {else}
          end {else if-then}
          else {<-Inserción de otros objetos:}
          begin
               TempObj.Next:= ActualObj.Next;
               TempObj.Prev:= ActualObj;
               ActualObj.Next.Prev:= TempObj;
               ActualObj.Next:= TempObj; {<-Termina la inserción LOGICA en la lista.}
               ActualObj:= TempObj; {<-Cambia el objeto don el foco (u objeto actual).}
          end; {if-then}
          {Acomodamiento en pantalla (gráfico:). El  problema es que hay muchas excepciones
           a la regla general de bajar todo un nivel.}
          iObj:= ActualObj.Next;{<-Comienza la inserción física o VISUAL.}
          if (TempObj is TBeginLoop) or (TempObj is TBeginIfThen) then {<-aca:Ver si esto está
                                                                     bien (revisar la segunda condición)}
          begin
               iObj:= ActualObj.Next.Next; {<-Saltea al EndLoop.}
               while iObj <> nil do {<-Reposiciona en pantalla.}
               begin
                    iObj.Top:= iObj.Top + 2*NORMAL_HEIGHT;
                    iObj:= iObj.Next;
               end {while}
          end {if-then}
          else
          begin
               while iObj <> nil do {<-Reposiciona en pantalla.}
               begin
                    iObj.Top:= iObj.Top + NORMAL_HEIGHT;
                    iObj:= iObj.Next;
               end; {while}(**)
          end; {else}
     end; {else; <-Inserción.}
end; {if-Then (<-If RunTime...)}

{La barra de herramientas vuelve a estar en modo "Selector":}
   ActualTool:= Selector;
   frmTools.spdSelector.Down:= true;
   ScrollBox.Cursor:= crDefault;
end; {PlaceObj}

{<-Event.}

procedure TfrmEditor.imgArrowNo2Click(Sender: TObject);
begin
     NewClick(Sender);
end;

procedure TfrmEditor.lblMotorActMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     NewClick(Sender);
     if (Sender as TLabel).Caption = '<-' then
        (Sender as TLabel).Caption:= 'X'
     else if (Sender as TLabel).Caption = 'X' then
          (Sender as TLabel).Caption:= '->'
     else
         (Sender as TLabel).Caption:= '<-'
end;

procedure TfrmEditor.btnScaleClick(Sender: TObject);
begin
     ScaleBy(90, 100){}
end;

procedure TfrmEditor.btnScaleKeyPress(Sender: TObject; var Key: Char);
begin
     if (key = ',') or  (key = '.') then key:= chr(0);
end;

procedure TfrmEditor.btnScaleMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     NewClick(Sender);
     if (Sender as TLabel).Caption = '1' then
        (Sender as TLabel).Caption:= '0'
     else
         (Sender as TLabel).Caption:= '1'
end;

procedure TfrmEditor.tmrTimerTimer(Sender: TObject);
begin
     inc(IncTime);
end;

procedure TfrmEditor.pnlEvalMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     pnlEval.BevelInner:= bvLowered;
     pnlEval.BevelOuter:= bvLowered;
end;

procedure TfrmEditor.pnlEvalMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   {Apariencia del botón:}
     pnlEval.BevelInner:= bvRaised;
     pnlEval.BevelOuter:= bvNone;
   {Evaluación de la expresión:}
     EvalExpr;
end;

procedure TfrmEditor.optLpt1Click(Sender: TObject);
begin
     Inicializar(1);
     ApagaTodo;
end;

procedure TfrmEditor.optLpt2Click(Sender: TObject);
begin
     Inicializar(2);
     ApagaTodo;
end;

procedure TfrmEditor.optLpt3Click(Sender: TObject);
begin
     Inicializar(3);
     ApagaTodo;
end;

procedure TfrmEditor.edtExpressionKeyPress(Sender: TObject; var Key: Char);
begin
     Key:= UpCase(Key);
     if Key = chr(13) then
        EvalExpr;
end;

procedure TfrmEditor.FormCreate(Sender: TObject);
var
   MiniBloqIni :TIniFile;
begin
   {Si no existe aún, crea el IniFile llamado Minibloq.ini
    en el directorio de la aplicación::}
    MiniBloqIni:= TIniFile.Create(ExtractFilePath(Application.ExeName) + 'MINIBLOQ.INI');
    if not FileExists(ExtractFilePath(Application.ExeName) + 'MINIBLOQ.INI') then
    begin
         MiniBloqIni.WriteInteger('Hardware', 'Port', 1);
    end {if-then}
    else {Si el IniFile ya existe, lee de él los valores correspondientes:}
    begin
         if MiniBloqIni.ReadInteger('Hardware', 'Port', 1) = 1 then
         begin
              optLpt1.Checked:= true;
              Inicializar(1);
              ApagaTodo;
         end {if-then}
         else if MiniBloqIni.ReadInteger('Hardware', 'Port', 1) = 2 then
         begin
              optLpt2.Checked:= true;
              Inicializar(2);
              ApagaTodo;
         end {else if-then}
         else if MiniBloqIni.ReadInteger('Hardware', 'Port', 1) = 3 then
         begin
              optLpt3.Checked:= true;
              Inicializar(3);
              ApagaTodo;
         end; {else if-then}
    end; {else}

    MiniBloqIni.Free;
end;

end.
