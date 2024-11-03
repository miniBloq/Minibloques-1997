unit Quine;

interface
    uses
        classes;
    const
         MaxVars = 16; {Cantidad  máxima de variables booleanas.}
    type
        TMini = class(TObject) {<- Debe ser un objeto para poder ser utilizado en TList.}
              val :word;
        end; {TMini}

        TWord = record
              val :word;
        end;
    var
       Terms :array[0..MaxVars] of TList; {Terms es un array de listas. La
                                          cantidad de elementos depende de
                                          MaxVars, ya que la lista i-ésima
                                          contiene todos los elementos con i
                                          "unos" si se lo representa en binario:}

       IFile, OFile :file of TWord;

    function MaxElem :word;

implementation

{MaxElem devuelve el máximo entero del archivo:}
function MaxElem :word;
var
   temp :TWord;
   max :word;
   i         :longint;
begin
     max:= 0;

     Reset(IFile);
     {for i:= 1 to FileSize(IFile) do}
     while not EOF(IFile) do
     begin
          read(IFile, temp);
          if temp.val > max then max:= temp.val;
     end;

     MaxElem:= max;
end; {MaxElem}

end.
