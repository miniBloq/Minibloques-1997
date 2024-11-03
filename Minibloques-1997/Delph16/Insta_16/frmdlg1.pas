unit Frmdlg1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons;

type
  TfrmDlg = class(TForm)
    btnAceptar: TBitBtn;
    btnCancelar: TBitBtn;
    Msg: TLabel;
    Msg2: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmDlg: TfrmDlg;

implementation

{$R *.DFM}

end.
