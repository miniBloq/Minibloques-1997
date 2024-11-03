program Prueba;

uses
  Forms,
  Frmprueb in 'FRMPRUEB.PAS' {frmPrueba},
  i723_v20 in 'I723_V20.PAS',
  Frmabt1 in 'FRMABT1.PAS' {frmAbt};

{$R *.RES}

begin
  Application.CreateForm(TfrmPrueba, frmPrueba);
  Application.CreateForm(TfrmAbt, frmAbt);
  Application.Run;
end.
