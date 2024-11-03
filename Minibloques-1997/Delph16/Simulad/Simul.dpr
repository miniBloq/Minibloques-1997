program Simul;

uses
  Forms,
  Simulad in 'SIMULAD.PAS' {frmSimulador},
  i723_v20 in 'I723_V20.PAS',
  Frmabt1 in 'FRMABT1.PAS' {frmAbt};

{$R *.RES}

begin
  Application.CreateForm(TfrmSimulador, frmSimulador);
  Application.CreateForm(TfrmAbt, frmAbt);
  Application.Run;
end.
