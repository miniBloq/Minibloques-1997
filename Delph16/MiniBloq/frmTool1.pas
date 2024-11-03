unit Frmtool1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, StdCtrls, Buttons,
  MiniObjs,
  i723_v20,
  frmConf1,
  frmAbt1,
  frmDlg,
  frmMsg,
  frmEval1,
  frmHelp1;

type
  TfrmTools = class(TForm)
    bbtnHelp: TBitBtn;
    bbtnOpen: TBitBtn;
    bbtnNewProgram: TBitBtn;
    bbtnClose: TBitBtn;
    bbtnSave: TBitBtn;
    bbtnStop: TBitBtn;
    spdIfThen: TSpeedButton;
    spdTimer: TSpeedButton;
    spdVariable: TSpeedButton;
    spdMotor: TSpeedButton;
    spdLoop: TSpeedButton;
    bbtnConfig: TBitBtn;
    spdRelay: TSpeedButton;
    bbtnRun: TBitBtn;
    bbtnStep: TBitBtn;
    spdSelector: TSpeedButton;
    spdMove: TSpeedButton;
    spdTrash: TSpeedButton;
    spdExitLoop: TSpeedButton;
    bbtnControl: TBitBtn;
    lblSimple: TLabel;
    bbtnEval: TBitBtn;
    procedure bbtnCloseClick(Sender: TObject);
    procedure bbtnRunClick(Sender: TObject);
    procedure bbtnStopClick(Sender: TObject);
    procedure spdMotorClick(Sender: TObject);
    procedure spdRelayClick(Sender: TObject);
    procedure spdIfThenClick(Sender: TObject);
    procedure spdLoopClick(Sender: TObject);
    procedure spdVariableClick(Sender: TObject);
    procedure spdTimerClick(Sender: TObject);
    procedure bbtnStepClick(Sender: TObject);
    procedure spdSelectorClick(Sender: TObject);
    procedure spdTrashClick(Sender: TObject);
    procedure spdMoveClick(Sender: TObject);
    procedure bbtnConfigClick(Sender: TObject);
    procedure spdExitLoopClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure bbtnNewProgramClick(Sender: TObject);
    procedure bbtnHelpClick(Sender: TObject);
    procedure bbtnSaveClick(Sender: TObject);
    procedure bbtnOpenClick(Sender: TObject);
    procedure bbtnControlClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTools: TfrmTools;

implementation
uses
    frmMain1; {<-Se lo agrega aquí en IMPLEMETATION para evitar la
                 referencia circular.}
{$R *.DFM}

procedure MakeToolsVisible;
begin
     
end; {MakeToolsVisible}

procedure TfrmTools.bbtnCloseClick(Sender: TObject);
(*var
   iObj :TScriptObj;
   i, j :word;
begin
        if RunTime then
           exit; {<-Por las dudas: No se puede salir en RunTime.}
        frmMessage.pnlOk.Caption:= 'Sí';
        frmMessage.pnlCancel.Caption:= 'No';
        ShowMsg('Atención', '¿Deseas grabar el programa antes de salir?', '',
                True, True);
        if frmMessage.ModalResult = mrOk then
           bbtnSave.OnClick(bbtnSave);
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
             spdTrashClick(spdTrash);
        end; {for j}

        ActualObj:= FirstObj;
        ActualObj.Next:= nil;
        VarList.Free;
        ApagaTodo; {<-Resetea la interface i723.}
        Screen.Cursor:= crDefault;
        {Close;{}*)
begin
        frmEditor.Close;
end;

procedure TfrmTools.bbtnRunClick(Sender: TObject);
var
   iObj    :TScriptObj;
   boolRet :boolean;
begin
     Screen.Cursor:= crHourGlass;
     frmTools.bbtnStep.enabled:= false;
     frmTools.bbtnClose.enabled:= false;
     {frmTools.ClientWidth:= bbtnRun.Width;{aca}
     RunTime:= true;
     spdTrash.Enabled:= false; {<-No se pueden borrar objetos en RuntIme.}
     spdTrash.Refresh;
     ActualObj.Color:= clSilver;
     ActualObj.Refresh;
     iObj:= FirstObj;
     while iObj <> nil do {<-Deshabilita todos los objetos.}
     begin
          iObj.Color:= clSilver;
          iObj.Refresh;
          iObj.enabled:= false;
          iObj:= iObj.Next;
     end; {while}
     Screen.Cursor:= crDefault;

   {Ejecusión del Script:}
     RunTimeObj:= FirstObj.Next;
     while RunTimeObj <> nil do {<-Ciclo de ejecusión del script.}
     begin
          Application.ProcessMessages;
          if not RunTime then break;
          RunTimeObj:= ExecuteObj(RunTimeObj);
     end; {while}

     Screen.Cursor:= crHourGlass;
     spdTrash.Enabled:= true;
     frmTools.bbtnStep.enabled:= true;
     frmTools.bbtnClose.enabled:= true;
     RunTime:= false;
     iObj:= FirstObj;
     while iObj <> nil do {<-Reestablece las condiciones anteriores a la ejecusión.}
     begin
          iObj.enabled:= true;
          iObj:= iObj.Next;
     end; {while}
     ActualObj.Color:= clAqua;
     Screen.Cursor:= crDefault;
end;

procedure TfrmTools.bbtnStopClick(Sender: TObject);
var
   iObj :TScriptObj;
begin
     Screen.Cursor:= crHourGlass;
     RunTime:= false;
     ActualObj.Color:= clAqua;
     iObj:= FirstObj;
     while iObj <> nil do
     begin
          iObj.Color:= clSilver;
          iObj.enabled:= true;
          iObj:= iObj.Next;
     end; {while}
     frmTools.bbtnStep.enabled:= true;
     frmTools.bbtnClose.enabled:= true;
     spdTrash.Enabled:= true;
     Screen.Cursor:= crDefault;
end;

procedure TfrmTools.spdMotorClick(Sender: TObject);
begin
     ActualTool:= Motor;
     frmEditor.PlaceObj;
end;

procedure TfrmTools.spdRelayClick(Sender: TObject);
begin
     ActualTool:= Relay;
     frmEditor.PlaceObj;
end;

procedure TfrmTools.spdIfThenClick(Sender: TObject);
begin
     ActualTool:= IfThen;
     frmEditor.PlaceObj;
end;

procedure TfrmTools.spdLoopClick(Sender: TObject);
begin
     ActualTool:= Loop;
     frmEditor.PlaceObj;
end;

procedure TfrmTools.spdVariableClick(Sender: TObject);
begin
     ActualTool:= Variable;
     frmEditor.PlaceObj;
end;

procedure TfrmTools.spdTimerClick(Sender: TObject);
begin
     ActualTool:= Timer;
     frmEditor.PlaceObj;
end;

procedure TfrmTools.bbtnStepClick(Sender: TObject);
var
   iObj :TScriptObj;
begin
  try
     Screen.Cursor:= crHourGlass;
     spdTrash.Enabled:= false; {<-No se pueden borrar objetos en RuntIme.}
     bbtnClose.Enabled:= false;
     spdTrash.Refresh;
     iObj:= FirstObj;
     if not RunTime then {El ciclo debe ser ejecutado sólo al principio.}
     begin
          RunTimeObj:= FirstObj.Next;
          ActualObj.Color:= clSilver;
          ActualObj.Refresh;
          while iObj <> nil do
          begin
               iObj.enabled:= false;
               iObj:= iObj.Next;
          end; {while}
     end; {if-then}

     if RunTimeObj = nil then {<- Aquí entra si el script finalizó, ya que el Next es nil.}
     begin
          spdTrash.Enabled:= true;
          bbtnClose.enabled:= true;{}
          RunTime:= false;
          iObj:= FirstObj;
          while iObj <> nil do
          begin
               iObj.Enabled:= true;
               iObj.Color:= clSilver;
               iObj:= iObj.Next;
          end; {while}
     end {if-then}
     else {Ejecusión paso a paso propiamente dicha:}
     begin
          RunTime:= true;
          spdTrash.Enabled:= false;
          bbtnClose.enabled:= false;
          {Ejecuta de a una sola instrucción por vez:}
          if RunTimeObj.Color <> clLime then
             RunTimeObj.Color:= clLime {<-Marca la ejecusión actual.}
          else
              RunTimeObj.Color:= clYellow; {Esto es para marcar los ciclos.}
          RunTimeObj:= ExecuteObj(RunTimeObj);
        {Esto es para ir "scrolando" la pantalla:}
          if RunTimeObj <> nil then
          begin
               RunTimeObj.Enabled:= true;
               RunTimeObj.SetFocus;
               RunTimeObj.Enabled:= false;
          end; {if-then}
     end; {else}
  finally
         Screen.Cursor:= crDefault;
  end; {try-finally}
end;

procedure TfrmTools.spdSelectorClick(Sender: TObject);
begin
     ActualTool:= Selector;
     frmEditor.ScrollBox.Cursor:= crDefault;
end;

procedure TfrmTools.spdTrashClick(Sender: TObject);
var
   TempObj, TempObj2, TempObj3, iObj :TScriptObj;
begin
     if RunTime then exit; {<-No se pueden borrar objetos en tiempo de ejecusión.}

     ActualTool:= Selector;
     frmEditor.ScrollBox.Cursor:= crDefault;
     spdSelector.Down:= true;

{Borra el objeto actual:}
     if ActualObj = FirstObj then exit;{<-"Comienzo" no puede ser borrado.}

     if ActualObj is TBeginLoop then
     begin
          ActualObj.Prev.Next:= (ActualObj as TBeginLoop).EndLoop.Next;
          if (ActualObj as TBeginLoop).EndLoop.Next <> nil then
             (ActualObj as TBeginLoop).EndLoop.Next.Prev:= ActualObj.Prev;
         {Borrado del ciclo y sus objetos interiores:}
          TempObj3:= ActualObj.Prev;
          iObj:= ActualObj;
          TempObj:= (ActualObj as TBeginLoop).EndLoop;
          while iObj <> TempObj do {<-Borra todo el ciclo incluído el interior.}
          begin
               iObj:= iObj.Next;
               TempObj2:= iObj.Prev;
               TempObj2.Free;
          end; {while}
        {El nuevo actual es el que seguía al EndLoop, a menos que éste sea nil:}
          if TempObj.Next <> nil then
          begin
               TempObj.Next.Color:= clAqua;
               ActualObj:= TempObj.Next;
          end {if-then}
          else
          begin
               TempObj3.Color:= clAqua;
               ActualObj:= TempObj3;
          end; {else}
        {Borra el EndLoop:}
          TempObj.Free;
        {Reacomoda todo en pantalla:}
          iObj:= FirstObj.Next; {<-No es óptimo recorrer toda la lista, pero es seguro.}
          while iObj <> nil do {<-Reposiciona en pantalla.}
          begin
               iObj.Top:= iObj.Prev.Top + iObj.Prev.Height;
               iObj:= iObj.Next;
          end {while}
     end {if-then}
     else if ActualObj is TEndLoop then
     begin
          {Si el usuario borra un EndLoop, el objeto actual cambia al
           EndLoop.BeginLoop y borra el ciclo llamando a este mismo
           procedimiento una vez más:}
           ActualObj:= (ActualObj as TEndLoop).BeginLoop;
           spdTrashClick(Sender);
     end {else if-then}
     else if ActualObj is TBeginIfThen then
     begin
          ActualObj.Prev.Next:= (ActualObj as TBeginIfThen).EndIfThen.Next;
          if (ActualObj as TBeginIfThen).EndIfThen.Next <> nil then
             (ActualObj as TBeginIfThen).EndIfThen.Next.Prev:= ActualObj.Prev;
         {Borrado del ciclo y sus objetos interiores:}
          TempObj3:= ActualObj.Prev;
          iObj:= ActualObj;
          TempObj:= (ActualObj as TBeginIfThen).EndIfThen;
          while iObj <> TempObj do {<-Borra todo el ciclo incluído el interior.}
          begin
               iObj:= iObj.Next;
               TempObj2:= iObj.Prev;
               TempObj2.Free;
          end; {while}
        {El nuevo actual es el que seguía al EndLoop, a menos que éste sea nil:}
          if TempObj.Next <> nil then
          begin
               TempObj.Next.Color:= clAqua;
               ActualObj:= TempObj.Next;
          end {if-then}
          else
          begin
               TempObj3.Color:= clAqua;
               ActualObj:= TempObj3;
          end; {else}
        {Borra el EndLoop:}
          TempObj.Free;
        {Reacomoda todo en pantalla:}
          iObj:= FirstObj.Next; {<-No es óptimo recorrer toda la lista, pero es seguro.}
          while iObj <> nil do {<-Reposiciona en pantalla.}
          begin
               iObj.Top:= iObj.Prev.Top + iObj.Prev.Height;
               iObj:= iObj.Next;
          end {while}
     end {else if-then}
     else if ActualObj is TEndIfThen then
     begin
          {Si el usuario borra un EndLoop, el objeto actual cambia al
           EndLoop.BeginLoop y borra el ciclo llamando a este mismo
           procedimiento una vez más:}
           ActualObj:= (ActualObj as TEndIfThen).BeginIfThen;
           spdTrashClick(Sender);
     end {esle if-then}
     else {Cualquier otro tipo de objeto:}
     begin
          ActualObj.Prev.Next:= ActualObj.Next; {<-No importa la posición del objeto.}
          if ActualObj.Next <> nil then
          begin
               ActualObj.Next.Prev:= ActualObj.Prev;
               TempObj:= ActualObj;
               ChangeActual(ActualObj.Next);
               TempObj.Free;
             {Reacomoda todo en pantalla subiendo los objetos de abjo "un lugar":}
               iObj:= ActualObj; {<-Saltea al EndLoop.}
               while iObj <> nil do {<-Reposiciona en pantalla.}
               begin
                    iObj.Top:= iObj.Top - NORMAL_HEIGHT;
                    iObj:= iObj.Next;
               end {while}(**)
          end {if-then}
          else
          begin {<- Si entra aquí, es porque está borrando el último elemnto de la lista.}
               TempObj:= ActualObj;
               ChangeActual(ActualObj.Prev);
               TempObj.Free;
          end; {else}
     end; {else}
end;

procedure TfrmTools.spdMoveClick(Sender: TObject);
begin
     ActualTool:= MoveObj;
     frmEditor.ScrollBox.Cursor:= crDefault;
end;

procedure TfrmTools.bbtnConfigClick(Sender: TObject);
begin
     frmConfig.ShowModal;
end;

procedure TfrmTools.spdExitLoopClick(Sender: TObject);
begin
     ActualTool:= ExitLoop;
     frmEditor.PlaceObj;
end;

procedure TfrmTools.FormKeyPress(Sender: TObject; var Key: Char);
begin
     {if key = chr(13) then bbtnStopClick(bbtnStop); {<-Detiene la ejecusión.}
end;

procedure TfrmTools.bbtnNewProgramClick(Sender: TObject);
var
   iObj :TScriptObj;
   i, j :word;
begin
        if RunTime then
           exit; {<-Por las dudas: No se puede salir en RunTime.}

        Screen.Cursor:= crDefault;
        frmMessage.pnlOk.Caption:= 'Sí';
        frmMessage.pnlCancel.Caption:= 'No';
        ShowMsg('Atención', '¿Deseas grabar el programa actual?', '',
                True, True);
        if frmMessage.ModalResult = mrOk then
           bbtnSave.OnClick(bbtnSave);
        frmMessage.pnlOk.Caption:= 'Aceptar';
        frmMessage.pnlCancel.Caption:= 'Cancelar';

        Screen.Cursor:= crHourGlass;
{Liberación de la memoria y destrucción de objetos y tabla de variables:}
        ActualObj:= FirstObj.Next; {<-Esto es para que al hacer luego en el FOR spdTrashClick(spdTrash)
                                      el procedimiento de borrado funcione, pues el FirstObj no se puede
                                      borrar.}
        iObj:= FirstObj.Next;
        i:= 0;
     {Cuenta la cantidad de objetos a borrar. Esto es así porque es más
      fácil que ir borrando a medida que se circula por la lista del script:}
        while iObj <> nil do
        begin
             inc(i);
             iObj:= iObj.next;
        end; {while}
     {Borra todos los objetos:}
        for j:= 1 to i do
        begin
             spdTrashClick(spdTrash);
        end; {for j}

        ActualObj:= FirstObj;
        ActualObj.Next:= nil;
        VarList.Clear;
        ApagaTodo; {<-Resetea la interface i723.}
        Screen.Cursor:= crDefault;
end;

procedure TfrmTools.bbtnHelpClick(Sender: TObject);
begin
     frmHelp.Show;{}
     {frmAbout.ShowModal;{}
end;

procedure TfrmTools.bbtnSaveClick(Sender: TObject);
var
   iObj      :TScriptObj;
   ActualRec :TScriptRec;
   OutFile   :File of TScriptRec;
begin
     if RunTime then
        exit; {<-Por las dudas: No se puede guardar un archivo salir en RunTime.}
     {Asignación del archivo de salida:}
     frmDialog.Caption:= 'Guardar el programa...';
     {frmTools.visible:= false;{}
     frmDialog.visible:= false;
     frmDialog.FormStyle:= fsStayOnTop;
     frmDialog.ShowModal;
     {frmTools.visible:= true;{}
     if frmDialog.ModalResult <> mrOk then exit; {<-Si el usuario cancela sale del proc. sin grabar.}
     {Este if-then valida la existencia del archivo de salida:}
     if FileExists(ExtractFilePath(frmDialog.lstFile.FileName) + frmDialog.edtFile.Text) then
     begin
          frmMessage.pnlOk.visible:= true;
          frmMessage.pnlCancel.visible:= true;
          {Título:}
          frmMessage.Caption:= 'Atención:';
          {Mensaje:}
          frmMessage.lblMsg1.Caption:= 'El archivo ya existe.';
          frmMessage.lblMsg2.Caption:= '¿Deseas reemplazarlo?';
          frmMessage.ShowModal;
          if frmMessage.ModalResult <> mrOk then exit; {<-Si el usuario cancela sale del proc. sin grabar.}
     end; {if-then}
     if frmDialog.ModalResult <> mrOk then exit; {<-Si el usuario cancela sale del proc. sin grabar.}
     AssignFile(OutFile, ExtractFilePath(frmDialog.lstFile.FileName) + frmDialog.edtFile.Text);
     Rewrite(OutFile);
     Screen.Cursor:= crHourGlass;
     {La grabación se hace objeto por objeto:}
     iObj:= FirstObj.Next;
     while iObj <> nil do
     begin
          if (iObj is TMotor) then
          begin
               ActualRec.ScriptObj:= CMOTOR;
               {Motores seleccionados en el bloque:}
               ActualRec.Objs:= '';
               if (iObj as TMotor).Out1.checked then
                  ActualRec.Objs:= ActualRec.Objs + '1';
               if (iObj as TMotor).Out2.checked then
                  ActualRec.Objs:= ActualRec.Objs + '2';
               if (iObj as TMotor).Out3.checked then
                  ActualRec.Objs:= ActualRec.Objs + '3';
               ActualRec.Op:= '';
               {Acción que realizarán los motores:}
               ActualRec.Action:= (iObj as TMotor).lblAction.Caption;
          end {if-then}
          else if (iObj is TRelay) then
          begin
               ActualRec.ScriptObj:= CRELAY;
               {Salidas de relé seleccionados en el bloque:}
               ActualRec.Objs:= '';
               if (iObj as TRelay).Out1.checked then
                  ActualRec.Objs:= ActualRec.Objs + '1';
               if (iObj as TRelay).Out2.checked then
                  ActualRec.Objs:= ActualRec.Objs + '2';
               ActualRec.Op:= '';
               {Acción que realizarán las salidas de relé:}
               ActualRec.Action:= (iObj as TRelay).lblAction.Caption;
          end {else if-then}
          else if (iObj is TBeginIfThen) then
          begin
               ActualRec.ScriptObj:= CBEGIN_IF;
               {Objeto al que se está comparando:}
               ActualRec.Objs:= (iObj as TBeginIfThen).cboObj.Text;
               {Operador:}
               ActualRec.Op:= (iObj as TBeginIfThen).cboOp.Text;
               {Expresión de la comparación:}
               ActualRec.Action:= (iObj as TBeginIfThen).cboVal.Text;
          end {else if-then}
          else if (iObj is TEndIfThen) then
          begin
               ActualRec.ScriptObj:= CEND_IF;
               ActualRec.Objs:= '';
               ActualRec.Op:= '';
               ActualRec.Action:= '';
          end {else if-then}
          else if (iObj is TBeginLoop) then
          begin
               ActualRec.ScriptObj:= CBEGIN_LOOP;
               ActualRec.Objs:= '';
               ActualRec.Op:= '';
               ActualRec.Action:= '';
          end {else if-then}
          else if (iObj is TEndLoop) then
          begin
               ActualRec.ScriptObj:= CEND_LOOP;
               ActualRec.Objs:= '';
               ActualRec.Op:= '';
               ActualRec.Action:= '';
          end {else if-then}
          else if (iObj is TExitLoop) then
          begin
               ActualRec.ScriptObj:= CEXIT_LOOP;
               ActualRec.Objs:= '';
               ActualRec.Op:= '';
               ActualRec.Action:= '';
          end {else if-then}
          else if (iObj is TVariable) then
          begin
               ActualRec.ScriptObj:= CVARIABLE;
               ActualRec.Objs:= (iObj as TVariable).edtName.Text;
               ActualRec.Op:= '';
               {Expresión de la asignación:}
               ActualRec.Action:= (iObj as TVariable).edtExpr.Text;
          end {if-then}
          else if (iObj is TMiniTimer) then
          begin
               ActualRec.ScriptObj:= CTIMER;
               ActualRec.Objs:= '';
               ActualRec.Op:= '';
               {Intervalo de tiempo:}
               ActualRec.Action:= IntToStr((iObj as TMiniTimer).spinInterval.Value);
          end; {if-then}
          write(OutFile, ActualRec);
          iObj:= iObj.next;
     end; {while}
     {Cierra el archivo de salida:}
     CloseFile(OutFile);
     {Restaura el cursor de pantalla:}
     Screen.Cursor:= crDefault;
end;

procedure TfrmTools.bbtnOpenClick(Sender: TObject);
var
   iObj      :TScriptObj;
   ActualRec :TScriptRec;
   InpFile   :File of TScriptRec;
begin
     if RunTime then
        exit; {<-Por las dudas: No se puede abrir un archivo salir en RunTime.}
     {Asignación del archivo de salida:}
     frmDialog.Caption:= 'Abrir un programa...';
     {El diálogo de apertura no da opción a escribir nombres incorrectos:}
     frmDialog.edtFile.visible:= false;
     {frmTools.visible:= false;{}
     frmDialog.visible:= false;
     frmDialog.ShowModal;
     {frmTools.visible:= true;{}
     frmDialog.edtFile.visible:= true;
     if frmDialog.ModalResult <> mrOk then exit; {<-Si el usuario cancela sale del proc. sin grabar.}
     {Este if-then valida la existencia del archivo de entrada:}
     if not FileExists(frmDialog.lstFile.FileName) then
     begin
          {Sólo botón Ok:}
          frmMessage.pnlOk.visible:= true;
          frmMessage.pnlCancel.visible:= false;
          {Título:}
          frmMessage.Caption:= 'Atención:';
          {Mensaje:}
          frmMessage.lblMsg1.Caption:= 'No hay ningún archivo seleccionado.';
          frmMessage.lblMsg2.Caption:= '';
          frmMessage.ShowModal;
          exit; {Sale pues hubo algún error...}
     end; {if-then}
     if frmDialog.ModalResult <> mrOk then exit; {<-Si el usuario cancela sale del proc. sin grabar.}
     AssignFile(InpFile, ExtractFilePath(frmDialog.lstFile.FileName) + frmDialog.edtFile.Text);

     Screen.Cursor:= crHourGlass;
     {Borra los objetos actuales:} {aca: ¿No sería mejor que de la oportunidad de
     insertar el nuevo programa a partir del lugar actual? Sí: pero mediante
     un cuadro de diálogo:}
     bbtnNewProgramClick(bbtnNewProgram);
     Reset(InpFile);
     {La grabación se hace objeto por objeto:}
        iObj:= FirstObj.Next;
        while not EOF(InpFile) do
        begin
          {Lee un registro del arcivo de entrada:}
             read(InpFile, ActualRec);
          {Se fija de qué tipo es el objeto a crear y procede:}
             if (ActualRec.ScriptObj = CMOTOR) then
             begin
                {Crea el objeto:}
                  ActualTool:= Motor;
                  frmEditor.PlaceObj;
                {Establece sus propidedades:}
                  {Motores seleccionados:}
                  if Pos('1', ActualRec.Objs) <> 0 then
                     (ActualObj as TMotor).Out1.checked:= true;
                  if Pos('2', ActualRec.Objs) <> 0 then
                     (ActualObj as TMotor).Out2.checked:= true;
                  if Pos('3', ActualRec.Objs) <> 0 then
                     (ActualObj as TMotor).Out3.checked:= true;
                  {Acción que realizarán los motores:}
                  (ActualObj as TMotor).lblAction.Caption:= ActualRec.Action;
             end {if-then}
             else if (ActualRec.ScriptObj = CRELAY) then
             begin
                {Crea el objeto:}
                  ActualTool:= Relay;
                  frmEditor.PlaceObj;
                {Establece sus propidedades:}
                  {Salidas de Relé seleccionadas:}
                  if Pos('1', ActualRec.Objs) <> 0 then
                     (ActualObj as TRelay).Out1.checked:= true;
                  if Pos('2', ActualRec.Objs) <> 0 then
                     (ActualObj as TRelay).Out2.checked:= true;
                  {Acción que realizarán las Salidas de Relé:}
                  (ActualObj as TRelay).lblAction.Caption:= ActualRec.Action;
             end {else if-then}
             else if (ActualRec.ScriptObj = CTIMER) then
             begin
                {Crea el objeto:}
                  ActualTool:= Timer;
                  frmEditor.PlaceObj;
                {Establece sus propidedades:}
                  {Intervalo de tiempo:}
                  (ActualObj as TMiniTimer).spinInterval.Value:= StrToInt(ActualRec.Action);
             end {else if-then}
             else if (ActualRec.ScriptObj = CVARIABLE) then
             begin
                {Crea el objeto:}
                  ActualTool:= Variable;
                  frmEditor.PlaceObj;
                {Establece sus propidedades:}
                  {Nombre de la variable:}
                  (ActualObj as TVariable).edtName.Text:= ActualRec.Objs;
                  {Expresión de la asignación:}
                  (ActualObj as TVariable).edtExpr.Text:= ActualRec.Action;
             end {else if-then}
             else if (ActualRec.ScriptObj = CBEGIN_IF) then
             begin
                {Crea el objeto:}
                  ActualTool:= IfThen;
                  frmEditor.PlaceObj;
                {Establece sus propidedades:}
                  {Nombre de la variable:}
                  (ActualObj as TBeginIfThen).cboObj.ItemIndex:=
                             (ActualObj as TBeginIfThen).cboObj.Items.IndexOf(ActualRec.Objs);
                  {Dispara el click del cboOp para llenar los comboBoxes cboOp y cboVal:}
                  (ActualObj as TBeginIfThen).TheEnterString:= '';{<-Es para engañar al proc OncLick (Ver cboObj.OnClick).}
                  (ActualObj as TBeginIfThen).cboObj.OnClick((ActualObj as TBeginIfThen).cboObj);
                  {Operador:}
                  (ActualObj as TBeginIfThen).cboOp.ItemIndex:=
                             (ActualObj as TBeginIfThen).cboOp.Items.IndexOf(ActualRec.Op);
                  {Expresión de la comparación:}
                  {Este if-then distingue si se trata de una expersión matemática o de un valor predeterminado:}
                  if (ActualObj as TBeginIfThen).cboVal.style = csDropDownList then
                  begin
                  (ActualObj as TBeginIfThen).cboVal.ItemIndex:=
                             (ActualObj as TBeginIfThen).cboVal.Items.IndexOf(ActualRec.Action);
                  end {if-then}
                  else
                  begin
                       (ActualObj as TBeginIfThen).cboVal.Text:= ActualRec.Action;
                  end; {else}
             end {else if-then}
             else if (ActualRec.ScriptObj = CEND_IF) then
             begin
                {El objeto ya fue creado, por lo que se lo saltea:}
                  ActualObj.Color:= clSilver;
                  ActualObj:= ActualObj.Next;
             end {else if-then}
             else if (ActualRec.ScriptObj = CBEGIN_LOOP) then
             begin
                {Crea el objeto:}
                  ActualTool:= Loop;
                  frmEditor.PlaceObj;
             end {else if-then}
             else if (ActualRec.ScriptObj = CEND_LOOP) then
             begin
                {El objeto ya fue creado, por lo que se lo saltea:}
                  ActualObj.Color:= clSilver;
                  ActualObj:= ActualObj.Next;
             end {else if-then}
             else if (ActualRec.ScriptObj = CEXIT_LOOP) then
             begin
                {Crea el objeto:}
                  ActualTool:= ExitLoop;
                  frmEditor.PlaceObj;
             end {else if-then}
        end; {while}
     {Para cómo se verá en pantalla:}
        ActualObj.Color:= clSilver;
        ActualObj.Refresh;
        ActualObj:= FirstObj;
        ActualObj.Color:= clAqua;
        ActualObj.SetFocus;
     {Cierra el archivo de salida:}
        CloseFile(InpFile);
     {Restaura el cursor de pantalla:}
        Screen.Cursor:= crDefault;
end;

procedure TfrmTools.bbtnControlClick(Sender: TObject);
begin
     frmEditor.pnlEvaluator.Visible:= not frmEditor.pnlEvaluator.Visible;
end;

procedure TfrmTools.FormClose(Sender: TObject; var Action: TCloseAction);
(*var
   iObj :TScriptObj;
   i, j :word;*)
begin
(*        if RunTime then
           exit; {<-Por las dudas: No se puede salir en RunTime.}
        frmMessage.pnlOk.Caption:= 'Sí';
        frmMessage.pnlCancel.Caption:= 'No';
        ShowMsg('Atención', '¿Deseas grabar el programa antes de salir?', '',
                True, True);
        if frmMessage.ModalResult = mrOk then
           bbtnSave.OnClick(bbtnSave);
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
             spdTrashClick(spdTrash);
        end; {for j}

        ActualObj:= FirstObj;
        ActualObj.Next:= nil;
        VarList.Free;
        ApagaTodo; {<-Resetea la interface i723.}
        Screen.Cursor:= crDefault;*)
        {Close;{}
        frmEditor.Close;
        Application.Terminate;
end;

procedure TfrmTools.FormCreate(Sender: TObject);
begin
   {Acomoda al form contra el borde derecho de la pantalla:}
     Left:= Screen.Width - Width;
end;

end.
