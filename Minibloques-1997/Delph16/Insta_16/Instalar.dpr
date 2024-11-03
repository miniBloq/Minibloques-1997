program Instalar;

uses
  Forms,
  Dde1 in 'DDE1.PAS' {frmGroup},
  Frmdlg1 in 'FRMDLG1.PAS' {frmDlg},
  Selmain in 'SELMAIN.PAS' {frmSelMainDir};

{$R *.RES}

begin
  Application.Title := 'Asistente de Instalación';
  Application.CreateForm(TfrmGroup, frmGroup);
  Application.CreateForm(TfrmDlg, frmDlg);
  Application.CreateForm(TfrmSelMainDir, frmSelMainDir);
  Application.Run;
end.
