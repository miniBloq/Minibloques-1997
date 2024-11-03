unit Frmdlg;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, StdCtrls, FileCtrl, Buttons, ExtCtrls, frmMsg;

type
  TfrmDialog = class(TForm)
    lstFile: TFileListBox;
    lstDir: TDirectoryListBox;
    cboDrive: TDriveComboBox;
    cboFilter: TFilterComboBox;
    LblPath: TLabel;
    edtFile: TEdit;
    pnlOk: TPanel;
    pnlCancel: TPanel;
    procedure pnlOkMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlCancelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlOkMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlCancelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlOkClick(Sender: TObject);
    procedure pnlCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmDialog: TfrmDialog;

implementation

{$R *.DFM}

procedure TfrmDialog.pnlOkMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     pnlOk.BevelInner:= bvLowered;
     pnlOk.BevelOuter:= bvLowered;
end;

procedure TfrmDialog.pnlCancelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     pnlCancel.BevelInner:= bvLowered;
     pnlCancel.BevelOuter:= bvLowered;
end;

procedure TfrmDialog.pnlOkMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     pnlOk.BevelInner:= bvRaised;
     pnlOk.BevelOuter:= bvNone;
end;

procedure TfrmDialog.pnlCancelMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     pnlCancel.BevelInner:= bvRaised;
     pnlCancel.BevelOuter:= bvNone;
end;

procedure TfrmDialog.pnlOkClick(Sender: TObject);
begin
(*     {Este while valida la existencia del archivo de salida:}
     while not FileExists(ExtractFilePath(lstFile.FileName) + edtFile.Text) do
     begin
          {Sólo botón de OK:}
          frmMessage.pnlOk.visible:= true;
          frmMessage.pnlCancel.visible:= false;
          {Título:}
          frmMessage.Caption:= 'Atención:';
          {Mensaje:}
          frmMessage.lblMsg1.Caption:= 'El archivo no existe.';
          frmMessage.ShowModal;
     end; {while}*)
     ModalResult := mrOK;
end;

procedure TfrmDialog.pnlCancelClick(Sender: TObject);
begin
     ModalResult := mrCancel;
end;

procedure TfrmDialog.FormShow(Sender: TObject);
begin
     lstFile.Update;
     lstDir.Update;
end;

procedure TfrmDialog.FormKeyPress(Sender: TObject; var Key: Char);
begin
     if Key = chr(13) then
        ModalResult:= mrOk;
end;

end.
