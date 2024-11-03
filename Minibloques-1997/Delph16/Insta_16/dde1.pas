unit Dde1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DdeMan, StdCtrls, ExtCtrls, SelMain, FileCtrl, ShellApi,
  LZEXPAND, Gauges, frmDlg1;

type
  TfrmGroup = class(TForm)
    btnGrupo: TButton;
    DDE1: TDdeClientConv;
    edtInput: TEdit;
    btnCancelar: TButton;
    bvlSep: TBevel;
    pnlImg: TPanel;
    imgShow: TImage;
    lblSteps1: TLabel;
    lblSteps3: TLabel;
    lblSteps4: TLabel;
    btnCerrar: TButton;
    btnDir: TButton;
    btnBrowse: TButton;
    tmrDelay: TTimer;
    pnlProgress: TPanel;
    ggeProgress: TGauge;
    tmrShow: TTimer;
    Label1: TLabel;
    memoComments: TMemo;
    procedure btnGrupoClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnDirClick(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure tmrDelayTimer(Sender: TObject);
    procedure tmrShowTimer(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGroup                                                        :TfrmGroup;
  ProgManItem1, ProgManItem2, ProgManItem3, ProgManItem4        :string;
  ProgManTitle1, ProgManTitle2, ProgManTitle3, ProgManTitle4    :string;
  strDefaultGrp, strDefaultDir, strUserDir                        :string;
  strZipFile1{, strZipFile2, strZipFile3, strZipFile4,}           :string;
  strSystemZip, strPassword                                       :string;
  OrigWidth, OrigHeight                                           :integer;
implementation

{$R *.DFM}
procedure MsgBox(Msg1, Msg2, Caption :string);
begin
     frmDlg.btnCancelar.visible:= false;
     frmDlg.Msg.Caption:= Msg1;
     frmDlg.Msg2.Caption:= Msg2;
     frmDlg.Caption:= Caption;
     frmDlg.ShowModal;
end; {MsgBox}

Function TestSector(drive: char; pista, sector, cabeza: byte): boolean;
var
    Resul: byte;
    i: Byte;
begin
    resul:= 0;
    drive:= UpCase(drive);
    drive:= Chr(Ord(drive) - 65);
    For i:= 1 to 2 do Begin
        asm
            MOV AH, 04H
            MOV AL, 1
            MOV CH, pista
            MOV CL, sector
            MOV DH, cabeza
            MOV DL, drive
            INT 13H
            MOV resul, 1
            JC @@1
            MOV resul, 0
            @@1:
        end; {asm}
        if Resul = 0 then Exit;
    end;
    TestSector:= (Resul = 0)
end; {TestSector}

function TestKeyDisk(const Drive: char) :boolean;
var
   strPista, strSector :string;
   pista, sector       :byte;
   ArchIn              :TextFile;
   cont                :integer;
begin
  try
     screen.Cursor:= crHourGlass;
{Inicializo variables:}
     pista:= 0;
{Abro el archivo WINCLS.OVL y obtengo los strings encriptados:}
     AssignFile(ArchIn, Drive + ':\wincls.ovl');
     Reset(ArchIn);
     Readln(ArchIn, strPista);
     Readln(ArchIn, strSector);
     CloseFile(ArchIn);
{Obtengo el número del primer sector malo desencriptando contra la clave
los strings:}
     for cont:= 1 to Length(strPista) do
     begin
          strPista[cont]:= chr(ord(strPista[cont]) xor
                               ord(strPassword[cont]));
     end; {for}
     for cont:= 1 to Length(strSector) do
     begin
          strSector[cont]:= chr(ord(strSector[cont]) xor
                                ord(strPassword[cont]));
     end; {for}
     try
        pista:= StrToInt(strPista);
        sector:= StrToInt(strSector);
     except
           TestKeyDisk:= false;
           exit;
     end; {try-except}
{Chequeo si el sector malo indicado es el primero y si está realmente malo:}
     if not(TestSector(Drive, pista, sector, 0)) then
     begin
        if TestSector(Drive, pista, sector - 1, 0) then
        begin
             TestKeyDisk:= true;
             exit;
        end {if-then}
        else
        begin
             TestKeyDisk:= false;
             exit;
        end; {else}
     end {if-then}
     else
     begin
          TestKeyDisk:= false;
          exit;
     end; {else}
     screen.Cursor:= crDefault;
  except
        TestKeyDisk:= false;
  end; {try-except}
end; {TestKeyDisk}

procedure Decompress(const SrcDir, DestDir :string);
const
     NO_MORE_FILES = -18;
var
   Dest1, Dest2, Archivo, Params, SysDir        :Array[0..255] of char;
   strSysDir, Directorio, OnlyFileName, AllPath :string;
   Size1, Size2                                 :word;
   SrcFileHand, DestFileHand                    :integer;
   nError                                       :LongInt;
   ReOpenBuf                                    :TOFStruct;
   SearchRecord                                 :TSearchRec;
begin
  try
{Descompactación de los archivos:
 Este procedimiento recorre todo el directorio pasado como parámetro y descompacta
 los archivos en el directorio de destino, que puede ser el DestDir:}
     frmGroup.ggeProgress.Progress:= 10;
     FindFirst(SrcDir + '\*.??_', faAnyFile, SearchRecord);
     repeat
{Abre el archivo a ser descompactado:}
          Directorio:= SrcDir + '\';
          StrPCopy(Archivo, Directorio + SearchRecord.Name);
          SrcFileHand:= LZOpenFile(Archivo, ReOpenBuf, OF_READ);
{Abre el archivo de destino:}
          StrPCopy(Dest2, DestDir + '\');
          nError:= GetExpandedName(Archivo, Dest1);
          AllPath:= StrPas(Dest1);
          OnlyFileName:= ExtractFileName(AllPath);
          StrPCopy(Dest1, OnlyFileName);
          StrCat(Dest2, Dest1);
          DestFileHand:= LZOpenFile(Dest2, ReOpenBuf, OF_CREATE);
{Copia y descompacta el archivo en cuestión:}
          frmGroup.ggeProgress.Progress:= frmGroup.ggeProgress.Progress + 20;
          nError:= LZCopy(SrcFileHand, DestFileHand);
{Cierra el archivo descompactado y el de destino:}
        LZClose(SrcFileHand);
        LZClose(DestFileHand);
     until FindNext(SearchRecord) = NO_MORE_FILES;
     FindClose(SearchRecord);
     frmGroup.ggeProgress.Progress:= 100;
  except
        MsgBox('Se produjo un error al descompactar los archivos. ',
               'El Asistente de Instalación se cerrará.',
               'Atención:');
        frmGroup.Refresh;
        frmGroup.Close;
  end; {try-excpept}
end; {Decompress}

procedure TfrmGroup.btnGrupoClick(Sender: TObject);
var
   i                   :integer;
   Comando             :String;

begin
{Conversación DDE con el Program Manager:}
     if edtInput.Text <> '' then
     begin
          if DDE1.OpenLink then
          begin
               Comando:= '[CreateGroup(' + edtInput.Text + ')]'#0;
               DDE1.ExecuteMacro(@Comando[1], False);

               Comando:= '[AddItem(' + strUserDir + '\' + ProgManItem1 + ', ' + ProgManTitle1 + ')]'#0;
               DDE1.ExecuteMacro(@Comando[1], False);

               Comando:= '[AddItem(' + strUserDir + '\' + ProgManItem2 + ', ' + ProgManTitle2 + ')]'#0;
               DDE1.ExecuteMacro(@Comando[1], False);

               Comando:= '[AddItem(' + strUserDir + '\' + ProgManItem3 + ', ' + ProgManTitle3 + ')]'#0;
               DDE1.ExecuteMacro(@Comando[1], False);

               Comando:= '[AddItem(' + strUserDir + '\' + ProgManItem4 + ', ' + ProgManTitle4 + ')]'#0;
               DDE1.ExecuteMacro(@Comando[1], False);

{              Comando:= '[ShowGroup(Consulta de Tarjetas, 1)]'#0;
               DDE1.ExecuteMacro(@Comando[1], False);{}
               DDE1.CloseLink;
          end {if-then}
          else
          begin
               MsgBox('Se produjo un error al crear el grupo de programa.',
                      'Intenta crearlo manualmente.',
                      'Atención:');
          end; {else}
{Finaliza la instalación}
          lblSteps1.Caption:= 'La instalación ha finalizado con éxito';
          lblSteps1.Font.Color:= clBlue;
          lblSteps1.visible:= true;
          lblSteps3.visible:= false;
          lblSteps4.visible:= false;
          edtInput.visible:= false;
          btnGrupo.visible:= false;
          btnCancelar.visible:= false;
          btnCerrar.visible:= true;
          tmrShow.enabled:= true;
     end {if-then}
     else
         edtInput.SetFocus;
end;

procedure TfrmGroup.btnCancelarClick(Sender: TObject);
begin
     Close;
end;

procedure TfrmGroup.FormCreate(Sender: TObject);
begin
{No "Resizing":}
     OrigWidth:= Width;
     OrigHeight:= Height;

{aca: Cambios en los defaults:}
     strDefaultDir:= 'c:\Simple'; {Directorio de destino por default}
     strDefaultGrp:= 'Simple Informática'; {Nombre del grupo de programa por default}

     ProgManItem1:= 'Minibloq.exe'; {Link del 1er ícono del Program MAnager}
     ProgManItem2:= 'Prueba.exe'; {Link del 2do ícono del Program Manager}
     ProgManItem3:= 'Simul.exe'; {Link del 3er ícono del Program Manager}
     ProgManItem4:= 'Portctrl.exe'; {Link del 4to ícono del Program Manager}

     ProgManTitle1:= 'Minibloques 1.02'; {Título del 1er ícono del Program Manager y del form}
     ProgManTitle2:= 'Prueba de la Interfaz i-723'; {Título del 2do ícono del Program Manager}
     ProgManTitle3:= 'Simulador de la Interfaz i-723'; {Título del 3er ícono del Program Manager}
     ProgManTitle4:= 'Controlador de Puertos'; {Título del 4to ícono del Program Manager}

     {strPassword:= 'FLIRALIS'; {El password debe estar en mayúsculas}
     {strZipFile1:= 'TANTOTAN.EX_'; {Nombre del archivo .ZIP del Disco1
     strSystemZip:= 'FILES2.ZIP';{Nombre del archivo .ZIP que contiene las cosas que van al WINDOWS/SYSTEM}

{Inicialización:}
     strUserDir:= strDefaultDir;
     frmGroup.Caption:= 'Asistente de Instalación del Sistema de Control de la Interfaz i-723';
     lblSteps3.Caption:= 'Los programas serán instalados en el directorio:';
     edtInput.Text:= strDefaultDir;
     lblSteps4.Caption:= 'Presiona "Siguiente" para continuar...';

{Verifica que el disco de origen sea llave:}
(*     if (not TestKeyDisk(ExtractFilePath(Application.ExeName)[1])) then
     begin
          Screen.Cursor:= crDefault;
          MessageDlg('El disco de origen no es un disco llave. El programa no será instalado.',
                      mtError, [mbOk], 0);
          btnCerrar.visible:= true; {Esto es para engañar al evento OnClose}
          btnDir.visible:= false; {Esto es "por las dudas..."}
          close;
          Application.Terminate;
     end {if-then}
     else
*)
     frmGroup.visible:= true;
     Screen.Cursor:= crDefault;
end;

procedure TfrmGroup.FormResize(Sender: TObject);
begin
{No "Resizing":}
     if Width <> OrigWidth then Width:= OrigWidth;
     if Height <> OrigHeight then Height:= OrigHeight;{}
end;

procedure TfrmGroup.btnCerrarClick(Sender: TObject);
begin
     Close;
end;

procedure TfrmGroup.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     if not btnCerrar.visible then
        if MessageDlg('La instalación no ha finalizado. ¿Deseas terminar de todos modos?',
                      mtCustom, [mbYes, mbNo], 0) = mrNo then
            Action:= caNone;
end;

procedure TfrmGroup.btnDirClick(Sender: TObject);
begin
     try
        if edtInput.Text <> '' then
        begin
             if DirectoryExists(edtInput.Text) then
             begin
                  if MessageDlg('El directorio ya existe. ¿Deseas instalar el programa en él?',
                                 mtCustom, [mbYes, mbNo], 0) = mrYes then
                  begin
                       strUserDir:= edtInput.Text;
                       ForceDirectories(edtInput.Text);
                       ForceDirectories(edtInput.Text + '\EJEMPLOS');
{Continúa el proceso de instalación: Descompactación y copia de archivos:}
                       screen.Cursor:= crHourGlass;
                       btnBrowse.visible:= false;
                       lblSteps1.visible:= false;
                       lblSteps4.visible:= false;
                       btnDir.visible:= false;
                       edtInput.visible:= false;
                       lblSteps3.Caption:= 'Descompactando archivos. Un momento por favor...';
{Este Timer llama a la rutina de Descompactación y contiúa la instalación:}
                       pnlProgress.visible:= true;
                       tmrDelay.interval:= 200;
                       tmrDelay.enabled:= true;
                  end {if-then}
                  else
                  begin
                       edtInput.SetFocus;
                  end; {else}
             end {if-then}
             else
             begin
                  strUserDir:= edtInput.Text;
                  ForceDirectories(edtInput.Text);
                  ForceDirectories(edtInput.Text + '\EJEMPLOS');
{Continúa el proceso de instalación: Descompactación y copia de archivos:}
                  screen.Cursor:= crHourGlass;
                  btnBrowse.visible:= false;
                  lblSteps1.visible:= false;
                  lblSteps4.visible:= false;
                  btnDir.visible:= false;
                  edtInput.visible:= false;
                  lblSteps3.Caption:= 'Descompactando archivos. Un momento por favor...';
{Este Timer llama a la rutina de Descompactación y contiúa la instalación:}
                  pnlProgress.visible:= true;
                  tmrDelay.interval:= 200;
                  tmrDelay.enabled:= true;
             end; {else}
        end
        else
        begin
             MsgBox('El nombre especificado para el directorio es inválido.',
                    'Intenta nuevamente.',
                    'Atención:');
             edtInput.SetFocus;
        end; {else}
     except
           MsgBox('El nombre especificado para el directorio es inválido.',
                  'Intenta nuevamente.',
                  'Atención:');
     end; {try-except}
end;

procedure TfrmGroup.btnBrowseClick(Sender: TObject);
begin
     frmSelMainDir.ShowModal;
     if  frmSelMainDir.ModalResult = mrOk then
     begin
          edtInput.text:= frmSelMainDir.dirLstMainDir.Directory;
     end; {if-then}
end;

procedure TfrmGroup.tmrDelayTimer(Sender: TObject);
var
   SysDir: Array[0..255] of char;
   Size1, Size2: word;
   strSysDir: string;
begin
{Más que importante!!!:}
     tmrDelay.enabled:= false;

{Obtiene el directorio de WINDOWS/SYSTEM:}
     Size1:= GetSystemDirectory(SysDir, Size2);
     strSysDir:= StrPas(SysDir);

{Descompactación:}
{aca}
     Decompress(ExtractFilePath(Application.ExeName) + 'FILES1', strUserDir);
     Decompress(ExtractFilePath(Application.ExeName) + 'FILES1\EJEMPLOS', strUserDir + '\EJEMPLOS');
     Decompress(ExtractFilePath(Application.ExeName) + 'FILES1\SYSTEM', strSysDir);
     pnlProgress.visible:= false;
     screen.Cursor:= crDefault;
{Creación del grupo:}
     btnGrupo.visible:= true;
     lblSteps3.Caption:= 'Será creado el siguiente grupo de programa:';
     lblSteps4.visible:= true;
     edtInput.visible:= true;
     edtInput.Text:= strDefaultGrp;
end;

procedure TfrmGroup.tmrShowTimer(Sender: TObject);
begin
     tmrShow.enabled:= false;
     MessageDlg('La instalación ha finalizado con éxito.',
                mtCustom, [mbOK], 0);
     Close;
end;

end.
