unit Selmain;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, FileCtrl;

type
  TfrmSelMainDir = class(TForm)
    dirLstMainDir: TDirectoryListBox;
    btnAceptar: TBitBtn;
    btnCancelar: TBitBtn;
    cboDrive: TDriveComboBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSelMainDir: TfrmSelMainDir;

implementation

{$R *.DFM}

end.
