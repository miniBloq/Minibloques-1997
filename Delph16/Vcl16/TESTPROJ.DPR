program TESTPROJ;

uses
  Forms,
  asmtest1 in '\SRC\Delphi20\Simple\asm_test\asmtest1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
