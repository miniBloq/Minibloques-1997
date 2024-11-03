unit Prtctrl2;

interface

function IntPot(Base, Exponente :integer) :integer;
procedure SetBit(var pByte: byte; Bit :byte; Val :boolean);
function GetBit(pByte: byte; Bit :byte) :boolean;

implementation

function IntPot(Base, Exponente :integer) :integer;
begin
     try
        if Base > 0 then
           IntPot:= round(Exp(Ln(Base) * Exponente))
        else
            IntPot:= 0;
     except
     end; {try-except}
end; {IntPow}

procedure SetBit(var pByte: byte; Bit :byte; Val :boolean);
var
   TempInt :integer;
begin
     TempInt:= IntPot(2, Bit); {Hago la llamada una sola vez.}
     if Val then
        pByte:= pByte or TempInt
     else
         pByte:= (pByte or TempInt) - TempInt;
end; {SetBit}

function GetBit(pByte: byte; Bit :byte) :boolean;
begin
     GetBit:= not((pByte and IntPot(2, Bit)) = 0);
end; {GetBit}

end.
 