unit Frmabt1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, ExtCtrls, StdCtrls;

type
  TfrmAbout = class(TForm)
    pnlStart: TPanel;
    lblSimple: TLabel;
    lblSimple3: TLabel;
    pnlMinibloq: TPanel;
    imgLaberint: TImage;
    lblSimple2: TLabel;
    Label1: TLabel;
    lblCopyRight: TLabel;
    pnlCursor: TPanel;
    imgCursor: TImage;
    Panel1: TPanel;
    Label2: TLabel;
    procedure pnlStartClick(Sender: TObject);
    procedure pnlStartMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlStartMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.DFM}

procedure TfrmAbout.pnlStartClick(Sender: TObject);
begin
     Close;
end;

procedure TfrmAbout.pnlStartMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     pnlStart.BevelInner:= bvLowered;
     pnlStart.BevelOuter:= bvLowered;
end;

procedure TfrmAbout.pnlStartMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     pnlStart.BevelInner:= bvRaised;
     pnlStart.BevelOuter:= bvNone;
end;

procedure TfrmAbout.FormKeyPress(Sender: TObject; var Key: Char);
begin
     if Key = chr(13) then
        Close;
end;

procedure TfrmAbout.FormShow(Sender: TObject);
begin
   {Se agranda y posiciona para ocupar toda la pantalla:}
     Top:= 0;
     Left:= 0;
     Height:= Screen.Height;
     Width:= Screen.Width;
   {Centra la imagen:}
     imgLaberint.left:= (Width div 2) - (imgLaberint.width div 2);
end;

end.
