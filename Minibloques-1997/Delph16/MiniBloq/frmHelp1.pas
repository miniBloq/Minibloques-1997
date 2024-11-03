unit Frmhelp1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls,
  frmAbt1;

const
     crHand = 5;

type
  TfrmHelp = class(TForm)
    pnlControls: TPanel;
    pnlContenido: TPanel;
    Panel4: TPanel;
    Image3: TImage;
    Panel3: TPanel;
    Image2: TImage;
    Panel2: TPanel;
    Image1: TImage;
    Panel1: TPanel;
    imgCursor: TImage;
    Panel5: TPanel;
    pnlTitle: TPanel;
    pnlElementos: TPanel;
    btnContents: TPanel;
    btnSearch: TPanel;
    pnlComenzando: TPanel;
    scrComenzando: TScrollBox;
    Image4: TImage;
    Image5: TImage;
    memo1: TMemo;
    Memo2: TMemo;
    pnlStartTitle: TPanel;
    Memo3: TMemo;
    Panel7: TPanel;
    scrElementos: TScrollBox;
    pnlElemTitle: TPanel;
    Memo6: TMemo;
    Image8: TImage;
    Image9: TImage;
    Image10: TImage;
    Image11: TImage;
    Image12: TImage;
    Image13: TImage;
    Image14: TImage;
    Memo7: TMemo;
    Memo8: TMemo;
    Memo9: TMemo;
    Memo10: TMemo;
    Panel10: TPanel;
    Image15: TImage;
    Panel11: TPanel;
    pnlMath: TPanel;
    scrMath: TScrollBox;
    Image17: TImage;
    pnlMathTitle: TPanel;
    Memo11: TMemo;
    Memo12: TMemo;
    Memo13: TMemo;
    Image16: TImage;
    Panel6: TPanel;
    Memo14: TMemo;
    Memo15: TMemo;
    Memo16: TMemo;
    Panel8: TPanel;
    Image18: TImage;
    pnlConfig: TPanel;
    ScrollBox1: TScrollBox;
    Image6: TImage;
    Image7: TImage;
    Memo4: TMemo;
    Memo5: TMemo;
    pnlConfigTitle: TPanel;
    Memo17: TMemo;
    pnlExec: TPanel;
    ScrollBox2: TScrollBox;
    Image19: TImage;
    Image20: TImage;
    Memo18: TMemo;
    Memo19: TMemo;
    pnlExecTitle: TPanel;
    pnlSave: TPanel;
    ScrollBox3: TScrollBox;
    Image22: TImage;
    Memo20: TMemo;
    pnlSaveTitle: TPanel;
    Image23: TImage;
    Memo22: TMemo;
    Image21: TImage;
    Memo21: TMemo;
    Image24: TImage;
    Memo23: TMemo;
    Image25: TImage;
    Memo24: TMemo;
    Image26: TImage;
    Memo25: TMemo;
    Panel9: TPanel;
    Image27: TImage;
    procedure FormCreate(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure Panel2Click(Sender: TObject);
    procedure Panel3Click(Sender: TObject);
    procedure Panel4Click(Sender: TObject);
    procedure btnContentsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnContentsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnContentsClick(Sender: TObject);
    procedure Panel7Click(Sender: TObject);
    procedure Panel11Click(Sender: TObject);
    procedure Panel10Click(Sender: TObject);
    procedure Panel8Click(Sender: TObject);
    procedure Panel9Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmHelp: TfrmHelp;
  TempCursor :tcURSOR; {aca}

implementation

{$R *.DFM}
{$R MINIB.RES}

procedure TfrmHelp.FormCreate(Sender: TObject);
var
   TempPChar :array[0..8] of char;
   {TempCursor :TCursor;{}
begin
     StrPCopy(TempPChar, 'HAND');
     TempCursor:= LoadCursor(HInstance, TempPChar);
     Screen.Cursors[crHand]:= TempCursor;

     Panel1.Cursor:= crHand;
     Panel2.Cursor:= crHand;
     Panel3.Cursor:= crHand;
     Panel4.Cursor:= crHand;
     panel6.Cursor:= crHand;
     panel7.Cursor:= crHand;
     panel8.Cursor:= crHand;
     panel9.Cursor:= crHand;
     panel10.Cursor:= crHand;
     panel11.Cursor:= crHand;
end;

procedure TfrmHelp.Panel1Click(Sender: TObject);
begin
     pnlComenzando.BringToFront;
     panel10.SetFocus;
     pnlStartTitle.SetFocus; {<-Hace que la barra de scroll esté en "0".}
end;

procedure TfrmHelp.Panel2Click(Sender: TObject);
begin
     pnlElementos.BringToFront;
     panel10.SetFocus;
     pnlElemTitle.SetFocus; {<-Hace que la barra de scroll esté en "0".}
end;

procedure TfrmHelp.Panel3Click(Sender: TObject);
begin
     pnlConfig.BringToFront;
     panel10.SetFocus;
     pnlConfigTitle.SetFocus; {<-Hace que la barra de scroll esté en "0".}
end;

procedure TfrmHelp.Panel4Click(Sender: TObject);
begin
     frmAbout.ShowModal;
end;

procedure TfrmHelp.btnContentsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     (Sender as TPanel).BevelInner:= bvLowered;
     (Sender as TPanel).BevelOuter:= bvLowered;
end;

procedure TfrmHelp.btnContentsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     (Sender as TPanel).BevelInner:= bvRaised;
     (Sender as TPanel).BevelOuter:= bvNone;
end;

procedure TfrmHelp.btnContentsClick(Sender: TObject);
begin
     pnlContenido.BringToFront;
end;

procedure TfrmHelp.Panel7Click(Sender: TObject);
begin
     pnlElementos.BringToFront;
     panel10.SetFocus;
     pnlElemTitle.SetFocus; {<-Hace que la barra de scroll esté en "0".}
end;

procedure TfrmHelp.Panel11Click(Sender: TObject);
begin
     pnlMath.BringToFront;
     panel10.SetFocus; {<-Engaña a Windows para que funcione el scroll a 0.}
                       {aca: Si la línea anterior no estuviera, cuando se va a
                        otroa página del help y se vuelve inmediatamente, el scroll
                        queda donde estaba. Probar para ver, cualquier cosa.}
     pnlMathTitle.SetFocus; {<-Hace que la barra de scroll esté en "0".}
end;

procedure TfrmHelp.Panel10Click(Sender: TObject);
begin
     pnlMath.BringToFront;
     panel10.SetFocus; {<-Engaña a Windows para que funcione el scroll a 0.}
     pnlMathTitle.SetFocus; {<-Hace que la barra de scroll esté en "0".}
end;

procedure TfrmHelp.Panel8Click(Sender: TObject);
begin
     pnlExec.BringToFront;
     panel10.SetFocus;
     pnlExecTitle.SetFocus; {<-Hace que la barra de scroll esté en "0".}
end;

procedure TfrmHelp.Panel9Click(Sender: TObject);
begin
     pnlSave.BringToFront;
     panel10.SetFocus;
     pnlSaveTitle.SetFocus; {<-Hace que la barra de scroll esté en "0".}
end;

end.
