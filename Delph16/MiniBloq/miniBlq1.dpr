program Miniblq1;

uses
  Forms,
  Delp723 in 'DELP723.PAS',
  Frmmain1 in 'FRMMAIN1.PAS' {frmEditor},
  Frmtool1 in 'FRMTOOL1.PAS' {frmTools},
  MiniObjs in 'MINIOBJS.PAS';

{$R *.RES}

begin
  Application.Title := 'Minibloq';
  Application.CreateForm(TfrmTools, frmTools);
  Application.CreateForm(TfrmEditor, frmEditor);
  frmEditor.Show;
  Application.HintPause:= 800;
  Application.Run;
end.

