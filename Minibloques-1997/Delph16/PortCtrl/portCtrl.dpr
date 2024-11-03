program Portctrl;

uses
  Forms,
  Prtctrl1 in 'PRTCTRL1.PAS' {frmPortCtrl},
  Prtctrl2 in 'PRTCTRL2.PAS',
  Frmabt1 in 'FRMABT1.PAS' {frmAbt};

{$R *.RES}

begin
  Application.CreateForm(TfrmPortCtrl, frmPortCtrl);
  Application.CreateForm(TfrmAbt, frmAbt);
  Application.Run;
end.
