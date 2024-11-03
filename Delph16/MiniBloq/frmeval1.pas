unit Frmeval1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls,
  frmMsg,
  Math11;

type
  TfrmEval = class(TForm)
    pnlEval: TPanel;
    edtExpression: TEdit;
    edtResult: TEdit;
    procedure pnlEvalMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlEvalMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmEval: TfrmEval;

implementation

{$R *.DFM}

procedure EvalExpr;
begin
   with frmEval do
   begin
     if (edtExpression.text <> '') then
     begin
          try
             expression:= edtExpression.Text;
             ErrorParser:= false;
             ErrorCodeParser:= NO_ERROR;
             edtResult.Text:= FloatToStr(Parser(1));
             if (ErrorParser or (ErrorCodeParser <> NO_ERROR)) then
             begin
                  {ShowMsg('Error en la expresión:', strErrorCode,
                          'Revisa la expresión para encontrar el error.', True, false);{aca}
                  edtResult.Text:= 'ERROR';
             end; {if-then}
             edtExpression.SetFocus;
             exit;
          except
                {ShowMsg('Error en la expresión:', strErrorCode,
                        'Revisa la expresión para encontrar el error.', True, false);{aca}
                edtResult.Text:= 'ERROR';
                edtExpression.SetFocus;
          end; {try-except}
     end {if-then}
     else
     begin
          {ShowMsg('Error en la expresión:', 'No hay expresión para ser evaluada.',
                  '', True, false);
          edtExpression.Text:= ''; }
          edtExpression.SetFocus;
     end; {else}
   end; {with}
end; {EvalExpr}

procedure TfrmEval.pnlEvalMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   {Apariencia del botón:}
     pnlEval.BevelInner:= bvRaised;
     pnlEval.BevelOuter:= bvNone;
   {Evaluación de la expresión:}
     EvalExpr
end;

procedure TfrmEval.pnlEvalMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     pnlEval.BevelInner:= bvLowered;
     pnlEval.BevelOuter:= bvLowered;
end;

procedure TfrmEval.FormKeyPress(Sender: TObject; var Key: Char);
begin
     if Key = chr(13) then
        EvalExpr;
end;

end.
