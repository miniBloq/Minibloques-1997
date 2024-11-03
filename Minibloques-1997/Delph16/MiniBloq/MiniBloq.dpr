program Minibloq;

uses
  Forms,
  Frmmain1 in 'FRMMAIN1.PAS' {frmEditor},
  Frmtool1 in 'FRMTOOL1.PAS' {frmTools},
  Miniobjs in 'MINIOBJS.PAS',
  Math11 in 'MATH11.PAS',
  i723_v20 in 'I723_V20.PAS',
  Frmabt1 in 'FRMABT1.PAS' {frmAbout},
  Frmdlg in 'FRMDLG.PAS' {frmDialog},
  Frmmsg in 'FRMMSG.PAS' {frmMessage},
  Frmhelp1 in 'FRMHELP1.PAS' {frmHelp};

{$R *.RES}

begin
  Application.Title := 'Minibloques';
{Fonts:}
  {La idea acá es copiar ARIAL.TTF en el directorio FONTS de Windows para
   que el programa lo pueda usar.  Esto debería ser hecho por el programa
   de instalación.
   NOTAS: 1) Averiaguar si en Windows 3.1x el directorio también se llama
             FONTS, o si los fonts val directamente al SYSTEM.
          2) Averiguar si es legal la distribución de fonts junto con un
             programa.
          3) En el directorio RES de MINIBLOQ está el archivo ARIAL.TTF.
          4) Averiguar si es posible incluir FONTS TRUE TYPE con los
             recursos del .EXE.}
{Forms:}
  Application.CreateForm(TfrmEditor, frmEditor);
  Application.CreateForm(TfrmTools, frmTools);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmDialog, frmDialog);
  Application.CreateForm(TfrmMessage, frmMessage);
  Application.CreateForm(TfrmHelp, frmHelp);
  frmAbout.ShowModal;
  Application.HintPause:= 800;
  Application.Run;
end.
