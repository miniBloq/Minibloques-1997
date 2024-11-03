{Esta unidad contiene rutinas para el manejo de bits}
unit Bits;

interface

procedure SetBit(var TheByte: integer; Bit :byte; Val :boolean);
function GetBit(TheByte: integer; Bit :byte) :boolean;

implementation

const
{Este array guarda potencias de 2 precalculadas. Se utiliza para
 el enmascaramiento de bits:}
     PowOf2: array[0..7] of word = (1, 2, 4, 8, 16, 32, 64, 128);

procedure SetBit(var TheByte: integer; Bit :byte; Val :boolean);
begin
     if Val then
        TheByte:= TheByte or PowOf2[Bit];
     else
         TheByte:= (TheByte or PowOf2[Bit]) - PowOf2[Bit];
end; {SetBit}

function GetBit(TheByte: integer; Bit :byte) :boolean;
begin
     GetBit:= not((TheByte and PowOf2[Bit]) = 0);
end; {GetBit}

end.
 