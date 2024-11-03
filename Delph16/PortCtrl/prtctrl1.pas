unit Prtctrl1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls,
  PrtCtrl2,
  frmAbt1;

type
  TfrmPortCtrl = class(TForm)
    tmr1: TTimer;
    lblDir1: TLabel;
    lblDir2: TLabel;
    cboPort: TComboBox;
    edtDir: TEdit;
    pnlControl: TGroupBox;
    chkControl1: TCheckBox;
    chkControl2: TCheckBox;
    chkControl3: TCheckBox;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    chkControl0: TCheckBox;
    pnlStatus: TGroupBox;
    chkStatus3: TCheckBox;
    chkStatus4: TCheckBox;
    chkStatus5: TCheckBox;
    chkStatus6: TCheckBox;
    chkStatus7: TCheckBox;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    pnlDatos: TGroupBox;
    chkDatos0: TCheckBox;
    chkDatos1: TCheckBox;
    chkDatos2: TCheckBox;
    chkDatos3: TCheckBox;
    chkDatos4: TCheckBox;
    chkDatos5: TCheckBox;
    chkDatos6: TCheckBox;
    chkDatos7: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    edtDatos: TEdit;
    Label18: TLabel;
    Label19: TLabel;
    edtStatus: TEdit;
    Label20: TLabel;
    edtControl: TEdit;
    btnReset: TButton;
    btnFreeze: TButton;
    Panel1: TPanel;
    imgFreeze: TImage;
    btnAbout: TButton;
    procedure chkBit1_1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cboPortChange(Sender: TObject);
    procedure edtDirKeyPress(Sender: TObject; var Key: Char);
    procedure edtDirChange(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure chkControl3Click(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnFreezeClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPortCtrl :TfrmPortCtrl;
  gIODir      :word;
  {VirtualPort :byte;{}

implementation

{$R *.DFM}

procedure TfrmPortCtrl.chkBit1_1Click(Sender: TObject);
var
   TempByte, TempByte2 :byte;
begin
     try
        gIODir:= StrToInt(edtDir.Text);
        TempByte:= port[gIODir];
        with (Sender as TCheckBox) do
             SetBit(TempByte, byte(tag), checked);
        if not imgFreeze.visible then
           port[gIODir]:= TempByte
        else
        begin
             TempByte2:= 0;
             if chkDatos0.checked then TempByte2:= TempByte2 or 1
             else TempByte2:= (TempByte2 or 1) - 1;
             if chkDatos1.checked then TempByte2:= TempByte2 or 2
             else TempByte2:= (TempByte2 or 2) - 2;
             if chkDatos2.checked then TempByte2:= TempByte2 or 4
             else TempByte2:= (TempByte2 or 4) - 4;
             if chkDatos3.checked then TempByte2:= TempByte2 or 8
             else TempByte2:= (TempByte2 or 8) - 8;
             if chkDatos4.checked then TempByte2:= TempByte2 or 16
             else TempByte2:= (TempByte2 or 16) - 16;
             if chkDatos5.checked then TempByte2:= TempByte2 or 32
             else TempByte2:= (TempByte2 or 32) - 32;
             if chkDatos6.checked then TempByte2:= TempByte2 or 64
             else TempByte2:= (TempByte2 or 64) - 64;
             if chkDatos7.checked then TempByte2:= TempByte2 or 128
             else TempByte2:= (TempByte2 or 128) - 128;
             edtDatos.Text:= IntToStr(TempByte2);
        end; {else}
     except
     end; {try-except}
end;

procedure TfrmPortCtrl.FormCreate(Sender: TObject);
begin
     cboPort.ItemIndex:= 0;
     edtDir.Text:= '888';
     gIODir:= 888;
end;

procedure TfrmPortCtrl.cboPortChange(Sender: TObject);
begin
     if cboPort.ItemIndex = 0 then {Lpt1 (Datos)}
     begin
          edtDir.Text:= '888';
          pnlControl.visible:= true;
     end; {if-then}
     if cboPort.ItemIndex = 1 then {Lpt2 (Datos)}
     begin
          edtDir.Text:= '956';
          pnlControl.visible:= true;
     end; {if-then}
     if cboPort.ItemIndex = 2 then {Lpt3 (Datos)}
     begin
          edtDir.Text:= '632';
          pnlControl.visible:= true;
     end; {if-then}
     if cboPort.ItemIndex = 3 then {Com 1}
     begin
          edtDir.Text:= '1016';
          pnlControl.visible:= false;
     end; {if-then}
     if cboPort.ItemIndex = 4 then {Com 2}
     begin
          edtDir.Text:= '760';
          pnlControl.visible:= false;
     end; {if-then}
     if cboPort.ItemIndex = (cboPort.Items.Count - 1) then {Otra Dirección}
     begin
          pnlControl.visible:= false;
          edtDir.Text:= '';
          edtDir.SetFocus;
     end; {if-then}
     if edtDir.text <> '' then
     begin
          gIODir:= StrToInt(edtDir.Text);
     end; {if-then}
end;

procedure TfrmPortCtrl.edtDirKeyPress(Sender: TObject; var Key: Char);
begin
     if not((Key in ['0'..'9']) or (Key = chr(8))) then
        Key:= chr(0);
end;

procedure TfrmPortCtrl.edtDirChange(Sender: TObject);
begin
     if edtDir.Text <> '' then
     begin
          cboPort.ItemIndex:= cboPort.Items.Count - 1; {Otra dirección}
          if StrToInt(edtDir.Text) = 888 then {Datos Lpt 1}
          begin
               cboPort.ItemIndex:= 0;
               pnlControl.visible:= true;
               pnlStatus.visible:= true;
               gioDir:= StrToInt(edtDir.Text);
          end;
          if StrToInt(edtDir.Text) = 956 then {Datos Lpt 1}
          begin
               cboPort.ItemIndex:= 1;
               pnlControl.visible:= true;
               pnlStatus.visible:= true;
               gioDir:= StrToInt(edtDir.Text);
          end;
          if StrToInt(edtDir.Text) = 632 then {Datos Lpt 1}
          begin
               cboPort.ItemIndex:= 2;
               pnlControl.visible:= true;
               pnlStatus.visible:= true;
               gioDir:= StrToInt(edtDir.Text);
          end;
          if StrToInt(edtDir.Text) = 1016 then {Com 1}
          begin
               cboPort.ItemIndex:= 3;
               pnlControl.visible:= false;
               pnlStatus.visible:= false;
               gioDir:= StrToInt(edtDir.Text);
          end;
          if StrToInt(edtDir.Text) = 760 then {Com 2}
          begin
               cboPort.ItemIndex:= 4;
               pnlControl.visible:= false;
               pnlStatus.visible:= false;
               gIODir:= StrToInt(edtDir.Text);
          end;
          if (StrToInt(edtDir.Text) <> 888) and
             (StrToInt(edtDir.Text) <>632) and
             (StrToInt(edtDir.Text) <> 956) then {Otra Dirección}
          begin
               gIODir:= StrToInt(edtDir.Text);
               pnlControl.visible:= false;
               pnlStatus.visible:= false;
          end; {if-then}
     end; {if-then}
end;

procedure TfrmPortCtrl.tmr1Timer(Sender: TObject);
begin
     try
        chkDatos0.checked:= GetBit(Port[gIODir], 0);
        chkDatos1.checked:= GetBit(Port[gIODir], 1);
        chkDatos2.checked:= GetBit(Port[gIODir], 2);
        chkDatos3.checked:= GetBit(Port[gIODir], 3);
        chkDatos4.checked:= GetBit(Port[gIODir], 4);
        chkDatos5.checked:= GetBit(Port[gIODir], 5);
        chkDatos6.checked:= GetBit(Port[gIODir], 6);
        chkDatos7.checked:= GetBit(Port[gIODir], 7);
        edtDatos.text:= IntToStr(Port[gIODir]);

        if pnlStatus.visible then
        begin
             chkStatus3.checked:= GetBit(Port[gIODir + 1], 3);
             chkStatus4.checked:= GetBit(Port[gIODir + 1], 4);
             chkStatus5.checked:= GetBit(Port[gIODir + 1], 5);
             chkStatus6.checked:= GetBit(Port[gIODir + 1], 6);
             chkStatus7.checked:= GetBit(Port[gIODir + 1], 7);
             chkControl0.checked:= GetBit(Port[gIODir + 2], 0);
             chkControl1.checked:= GetBit(Port[gIODir + 2], 1);
             chkControl2.checked:= GetBit(Port[gIODir + 2], 2);
             chkControl3.checked:= GetBit(Port[gIODir + 2], 3);
             edtStatus.text:= IntToStr(Port[gIODir + 1]);
             edtControl.text:= IntToStr(Port[gIODir + 2]);
        end; {if-then}

     except
     end; {try-except}
end;

procedure TfrmPortCtrl.chkControl3Click(Sender: TObject);
var
   TempByte, TempByte2 :byte;
begin
     try
        gIODir:= StrToInt(edtDir.Text);
        TempByte:= port[gIODir];
        with (Sender as TCheckBox) do
             SetBit(TempByte, byte(tag), checked);
        if not imgFreeze.visible then
           port[gIODir + 2]:= TempByte
        else
        begin
             TempByte2:= 0;
             if chkControl0.checked then TempByte2:= TempByte2 or 1
             else TempByte2:= (TempByte2 or 1) - 1;
             if chkControl1.checked then TempByte2:= TempByte2 or 2
             else TempByte2:= (TempByte2 or 2) - 2;
             if chkControl2.checked then TempByte2:= TempByte2 or 4
             else TempByte2:= (TempByte2 or 4) - 4;
             if chkControl3.checked then TempByte2:= TempByte2 or 8
             else TempByte2:= (TempByte2 or 8) - 8;
             edtControl.Text:= IntToStr(TempByte2);
        end; {else}
     except
     end; {try-except}
end;

procedure TfrmPortCtrl.btnResetClick(Sender: TObject);
begin
     if not(imgFreeze.visible) then
        Port[gIODir]:= 0
     else
     begin
          chkDatos0.checked:= false;
          chkDatos1.checked:= false;
          chkDatos2.checked:= false;
          chkDatos3.checked:= false;
          chkDatos4.checked:= false;
          chkDatos5.checked:= false;
          chkDatos6.checked:= false;
          chkDatos7.checked:= false;
          chkControl0.checked:= false;
          chkControl1.checked:= false;
          chkControl2.checked:= false;
          chkControl3.checked:= false;
          edtDatos.Text:= '0';
          edtControl.Text:= '0';
     end; {else}
end;

procedure TfrmPortCtrl.btnFreezeClick(Sender: TObject);
begin
     if btnFreeze.Caption = 'Congelar &Valores' then
     begin
          btnFreeze.Caption:= 'Aplicar &Valores';
          btnReset.Caption:= '&Resetear Valores';
          imgFreeze.visible:= true;
          tmr1.enabled:= false;
     end {if-then}
     else
     begin
          btnFreeze.Caption:= 'Congelar &Valores';
          btnReset.Caption:= '&Resetear Puerto';
          imgFreeze.visible:= false;
          port[gIODir]:= byte(StrToInt(edtDatos.text));
          if pnlStatus.visible then
             port[gIODir + 2]:= byte(StrToInt(edtControl.text));
          tmr1.enabled:= true;
     end; {else}

end;

procedure TfrmPortCtrl.btnAboutClick(Sender: TObject);
begin
     frmAbt.ShowModal;
end;

end.
