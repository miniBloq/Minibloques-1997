{Simple Informática, Argentina.
 ARCHIVO: MATH1.PAS
 PROGRAMADOR: Julián da Silva Gillig
 ULTIMA REVISION: 6/7/97 (<-OJO: Sólo se le hicieron adaptaciones para MINIBLOQ, pero este
                                 archivo NO es el que se debe usar al comenzar nuevos programas.)
 CONTENIDO:
      * Funciones matemáticas agregadas al Pascal.
      * Constantes.
      * Evaluador de expresiones.
      * Conversión de coordenadas de R^2.
      * Rutinas y tipos para números complejos.
      * Rutinas para fractales.
 COMENTARIOS:
 La mayoría de las funciones utilizan el tipo EXTENDED en lugar de REAL
 para que los cálculos sean exactos (ejemplo de expresiones no exactas
 con REAL: sen(pi/2) <> 0.000).  Para mayor velocidad y menos precisión,
 hacer un REPLACE de EXTENDED por REAL.
 Todas son exportables (interface section) pues son útiles en sí mismas
 (incluso aquellas que son de apoyo a otras funciones).}
unit Math11;

interface
    uses
        Graphics, Controls, Forms, SysUtils, Classes; {Borland Units}

    const
{Constantes con los códigos de error:}
         NO_ERROR    = 0;
         NO_REAL     = -2;
         NO_INTEGER  = -3;
         DIV_BY_ZERO = -4;
         OVERFLOW    = -5;
         ILLEGAL_OP  = -6;

    type
{Tipos para números complejos:}
        TComplex = record
                 R, i :extended;
        end; {TComplex}

    var
{Variables globales del evaluador de expresiones (Parser):}
       expression, Token, TokenType, strErrorCode    :string; {OJO: DEBEN ser inicializadas a ''
                                                               -> Ver Inicialización de la Unit}
       ErrorParser                                   :boolean;
       ErrorCodeParser                               :integer; {En esta variable se puede consultar cuál fue el error.}
       VarX, VarY, VarZ,
       ParamA, ParamB, ParamC,
       ParamD, ParamM, ParamN                        :extended;
       UsesX, UsesY, UsesZ,                          {Estas booleanas sirven para determinar de}
       UsesA, UsesB, UsesC,                          {cuantas variables depende la expresión evaluada.}
       UsesD, UsesM, UsesN                           :boolean;
{Rutinas matemáticas agregadas:}
    function Pot(Base, Exponente :extended; var ErrorCode :integer) :extended;
    function Log(Base, x :extended; var ErrorCode :integer) :extended;
    function Tan(phi :extended; var ErrorCode :integer) :extended;
    function CoTan(phi :extended; var ErrorCode :integer) :extended;
    function Sec(phi :extended; var ErrorCode :integer) :extended;
    function CoSec(phi :extended; var ErrorCode :integer) :extended;
    function ACos(x :extended; var ErrorCode :integer) :extended;
    function ASen(x :extended; var ErrorCode :integer) :extended;

{Rutinas varias no matemáticas:}
    function mid(str1 :string; firstC :integer) :string;
    procedure swapR(var x, y :real);

{Rutinas del evaluador de expresiones (Parser):}
    function EvalFunction(fnc :string; x :extended; var ErrorCode :integer) :extended;
    function GetNextToken :string;
    function Parser(prec :integer) :extended;

{Rutinas para conversión de coordenadas en R^2:}
    procedure CarToPolar(x, y :extended; var r, alfa :extended;
                         var ErrorCode: integer);
    procedure PolarToCar(var x, y :extended; r, alfa :extended;
                         var ErrorCode: integer);

{Rutinas para números complejos:}
    procedure CxSum(C1, C2 :TComplex; var CRes :TComplex);
    procedure CxSubs(C1, C2 :TComplex; var CRes :TComplex);
    procedure CxProd(C1, C2 :TComplex; var CRes :TComplex);
    function CxConj(C :TComplex) :TComplex;
    function CxMod(C :TComplex) :extended;
    function CxInv(C :TComplex) :TComplex;

{Rutinas para fractales:}
    function Mandelbrot(cx, cy :double; MaxIter :integer) :integer;
    function Julia(cx, cy , x, y :double; MaxIter :integer):integer;

{Rutinas para interpolación de valores:}
    {Polinomio Interpolador de Lagrange:}
{    function PIL():;}

{Rutinas para estadísticas:}

implementation
uses
    MiniObjs{<-aca: Minibloq.}{, frmMain1{<-aca:debug};

{Rutinas matemáticas agregadas:}
    {Esta función calcula la potencia de un número extended,
     y puede resolver exponentes fraccionarios (raíces),
     negativos y bases negativas mientras el resultado
     no sea un número no extended (complejo). Para este úl-
     timo caso es que se utiliza el ErrorCode.}
    function Pot(Base, Exponente :extended; var ErrorCode :integer) :extended;
    var
       rAux1 :extended;
    begin
      try
         if (Base = 0) then
         begin
              Pot:= 0;
              ErrorCode:= NO_ERROR;
         end {if-then}
         else
             if (Base < 0) then {Base negativa}
             begin
                  if (frac(Exponente) <> 0) then {Exponente fraccionario}
                  begin
                       rAux1:= Exponente;
                       while (frac(rAux1) <> 0) do {Prepara al Exponente para evaluar si es 2*n/m}
                             rAux1:= rAux1 * 10;
                       if ((trunc(rAux1) MOD 2) = 0) then {Exponente de numerador par}
                       begin
                            Base:= -Base;
                            Pot:= Exp(Ln(Base) * Exponente);
                            ErrorCode:= NO_ERROR;
                            end {if-then}
                       else {El resultado es complejo por Base negativa y Exponente
                             fraccionario de numerador impar:}
                       begin
                            strErrorCode:= 'La potenciación (^) devolvió un número ' +
                                           'complejo, pues la base es negativa y el exponente ' +
                                           'es fraccionario de numerador impar y denominador par. ' +
                                           'EJ: (-2)^(3.3) = (-2)^(33/10), lo cual no pertenece ' +
                                           'al conjunto de los números reales.)';
                            ErrorCode:= NO_REAL;
                       end; {else}
                  end {if-then}
                  else {Base negativa y Exponente no fraccionario}
                  begin
                       Base:= -Base;
                       if ((trunc(Exponente) MOD 2) = 0) then {Eponente par}
                          Pot:= Exp(Ln(Base) * Exponente)
                       else {Exponente impar}
                            Pot:= -Exp(Ln(Base) * Exponente);
                       ErrorCode:= NO_ERROR;
                  end; {else}
             end {if-then}
             else {Base positiva}
             begin
                  Pot:= Exp(Ln(Base) * Exponente);
                  ErrorCode:= NO_ERROR;
             end; {else}
             exit;
      except
            ErrorCode:= OVERFLOW;
            strErrorCode:= 'El resultado de la potenciación (^) es un número' +
                           'es un número demasiado grande, que sobrepasa la capacidad ' +
                           'de cálculo del programa.';
      end; {try-excpet}
    end; {Pot}

    function Log(Base, x :extended; var ErrorCode :integer) :extended;
    begin
      try
         if ((x <> 0) and (Base <> 0)) then
         begin
              if (Base = 1) then
              begin
                   strErrorCode:= 'El número 1 (uno), no puede ser base de un Logaritmo ' +
                                  'pues no existe ningún número real que pueda usarse ' +
                                  'como exponente de una potendia de base 1 la cual de ' +
                                  'como resultado un número distinto de 1.';
                   ErrorCode:= DIV_BY_ZERO;
              end {if-then}
              else
              begin
                   Log:= Ln(x)/Ln(Base);
                   ErrorCode:= NO_ERROR;
              end; {else}
         end {if-then}
         else
         begin
              strErrorCode:= 'El logaritmo de 0 (cero) no está definido.';
              ErrorCode:= ILLEGAL_OP;
         end; {else}
         exit;
      except
            strErrorCode:= 'No fue posible calcular el logaritmo';
            ErrorCode:= ILLEGAL_OP;
      end; {try-except}
    end; {Log}

    function Tan(phi :extended; var ErrorCode :integer) :extended;
    begin
      try
         if (Cos(phi) <> 0) then
         begin
            Tan:= Sin(phi)/Cos(phi);
            ErrorCode:= NO_ERROR;
         end {if-then}
         else
         begin
              strErrorCode:= 'El resultado de la función Tangente (TG o TAN) ' +
                             'en el valor evaluado tiende hacia el infinito.';
              ErrorCode:= DIV_BY_ZERO;
         end; {else}
         exit;
      except
            strErrorCode:= 'No fue posible calcular la función Tangente (TG o TAN).';
            ErrorCode:= ILLEGAL_OP;
      end; {try-except}
    end; {Tan}

    function CoTan(phi :extended; var ErrorCode :integer) :extended;
    begin
      try
         if (Sin(phi) <> 0) then
         begin
            CoTan:= Cos(phi)/Sin(phi);
            ErrorCode:= NO_ERROR;
         end {if-then}
         else
         begin
              strErrorCode:= 'El resultado de la función Cotangente (COTG o COTAN) ' +
                             'en el valor evaluado tiende hacia el infinito.';

              ErrorCode:= DIV_BY_ZERO;
         end; {else}
         exit;
      except
            strErrorCode:= 'La función Cotangente (COTG o COTAN) no pudo ser calculada.';
            ErrorCode:= ILLEGAL_OP;
      end; {try-except}
    end; {CoTan}

    function Sec(phi :extended; var ErrorCode :integer) :extended;
    begin
      try
         if (Cos(phi) <> 0) then
         begin
            Sec:= 1/Cos(phi);
            ErrorCode:= NO_ERROR;
         end {if-then}
         else
         begin
              strErrorCode:= 'El resultado de la función SEC tiende al infinito';
              ErrorCode:= DIV_BY_ZERO;
         end; {else}
         exit;
      except
             strErrorCode:= 'La función SEC no pudo ser calculada.';
             ErrorCode:= ILLEGAL_OP;
      end; {try-except}
    end; {Sec}

    function CoSec(phi :extended; var ErrorCode :integer) :extended;
    begin
      try
         if (Sin(phi) <> 0) then
         begin
            CoSec:= 1/Sin(phi);
            ErrorCode:= NO_ERROR;
         end {if-then}
         else
         begin
             strErrorCode:= 'El resultado de la función COSEC tiende al infinito';
             ErrorCode:= DIV_BY_ZERO;
         end; {else}
         exit;
      except
            strErrorCode:= 'La función SEC no pudo ser calculada.';
            ErrorCode:= ILLEGAL_OP;
      end; {try-except}
    end; {CoSec}

    function ACos(x :extended; var ErrorCode :integer) :extended;
    begin
      try
         if (x <> 0) then
            if ((1 - sqr(x)) >= 0) then
            begin
                 ACos:= ArcTan(sqrt(1 - sqr(x))/x);
                 ErrorCode:= NO_ERROR;
            end {if-then}
            else
            begin
                 strErrorCode:= 'El resultado de la función ACOS no pertenece a los números reales';
                 ErrorCode:= NO_REAL {Resultado complejo}
            end {else}
         else
         begin
              strErrorCode:= 'El resultado de la función ACOS tiende al infinito';
              ErrorCode:= DIV_BY_ZERO;
         end; {else}
         exit;
      except
            strErrorCode:= 'La función COS no pudo ser calculada.';
            ErrorCode:= ILLEGAL_OP;
      end; {try-except}
    end; {ArcCos}

    function ASen(x :extended; var ErrorCode :integer) :extended;
    begin
      try
         if ((1 - sqr(x)) >= 0) then
         begin
              ASen:= ArcTan(x/sqrt(1 - sqr(x)));
              ErrorCode:= NO_ERROR;
         end {if-then}
         else
         begin
              strErrorCode:= 'El resultado de la función ASEN no pertenece a los números reales.';
              ErrorCode:= NO_REAL; {Resultado complejo}
         end; {else}
         exit;
      except
            strErrorCode:= 'La función ASEN no pudo ser calculada.';
            ErrorCode:= ILLEGAL_OP;
      end; {try-except}
    end; {ArcSen}

{Rutinas varias no matemáticas:}
    {Esta función copia strings a partir de la posición firstC inclusive:}
    function mid(str1 :string; firstC :integer) :string;
    var
       i, j    :integer;
       strAux1 :string;
    begin
         strAux1:= '';
         j:= 1;
         for i:= firstC to length(str1) do
         begin
              strAux1:= strAux1 + str1[i];
              inc(j);
         end; {for}
         mid:= strAux1;
    end; {mid}

    {Este procedimiento intercambia 2 números del tipo REAL:}
    procedure swapR(var x, y :real);
    var
       RTemp :real;
    begin
         RTemp:= x;
         x:= y;
         y:= RTemp;
    end; {swapR}

{Rutinas del evaluador de expresiones (Parser):}
{El mismo evalúa Rutinas que quepan en strings[255].}
    function EvalFunction(fnc :string; x :extended; var ErrorCode :integer) :extended;
    var
       fnc2 :string[6];
    begin
      try
         ErrorParser:= false;
         fnc2:= LowerCase(fnc);
         {Esta Construcción de "IFs" con TempMark son un
          al case para strings:}
         if (fnc2 = 'abs') then
         begin
              EvalFunction:= abs(x);
              exit;
         end; {if-then}
         if ((fnc2 = 'sen') or (fnc2 = 'sin')) then
         begin
              EvalFunction:= sin(x);
              exit;
         end; {if-then}
         if (fnc2 = 'cos') then
         begin
              EvalFunction:= cos(x);
              exit;
         end; {if-then}
         if ((fnc2 = 'tan') or (fnc2 = 'tg')) then
         begin
              EvalFunction:= Tan(x, ErrorCode);
              exit;
         end; {if-then}
         if (fnc2 = 'cosec') then
         begin
              EvalFunction:= cosec(x, ErrorCode);
              exit;
         end; {if-then}
         if (fnc2 = 'sec') then
         begin
              EvalFunction:= sec(x, ErrorCode);
              exit;
         end; {if-then}
         if ((fnc2 = 'cotan') or (fnc2 = 'cotg')) then
         begin
              EvalFunction:= coTan(x, ErrorCode);
              exit;
         end; {if-then}
         if ((fnc2 = 'asen') or (fnc2 = 'asin')) then
         begin
              EvalFunction:= ASen(x, ErrorCode);
              exit;
         end; {if-then}
         if (fnc2 = 'acos') then
         begin
              EvalFunction:= ACos(x, ErrorCode);
              exit;
         end; {if-then}
         if ((fnc2 = 'atan') or (fnc2 = 'atg')) then
         begin
              EvalFunction:= ArcTan(x);
              exit;
         end; {if-then}
         if (fnc2 = 'exp') then
         begin
              if (x < 21.487) then {Valor límite para las operaciones de
                                    punto flotante.}
                 EvalFunction:= exp(x)
              else
              begin
                   ErrorCodeParser:= OVERFLOW;
                   strErrorCode:= 'La función EXP devolvió un valor mayor ' +
                                  'de lo que el programa puede manejar. Intenta ' +
                                  'disminuir el rango de la variable para evaluar ' +
                                  'la expresión. NOTA: El valor ' +
                                  'máximo que puede ser pasado a la función EXP es 21.487.';
              end; {else}
              exit;
         end; {if-then}
         if (fnc2 = 'ln') then
         begin
              if (x > 0) then
                 EvalFunction:= ln(x)
              else
              begin
                   ErrorCodeParser:= ILLEGAL_OP;
                   strErrorCode:= 'La función LN no está definida para valores ' +
                                  'menores que 0 (cero), por lo que no devolvió ' +
                                  'un resultado válido. Intenta cambiar el rango ' +
                                  'de la variable para evaluar ' +
                                  'la expresión.';
              end; {else}
              exit;
         end; {if-then}
         if (fnc2 = 'frac') then
         begin
              EvalFunction:= frac(x);
              exit;
         end; {if-then}
         if (fnc2 = 'int') then
         begin
              EvalFunction:= int(x);
              exit;
         end; {if-then}
         if (fnc2 = 'pi') then
         begin
              EvalFunction:= pi;
              exit;
         end; {if-then}
         if VarList.IndexOf(UpperCase(fnc2)) > -1 then {<-aca: Esto es para las variables de Minibloq.}
         begin
              try
                 {frmEditor.caption:= 'hola'; {aca:debug}
                 EvalFunction:= (VarList.objects[VarList.IndexOf(UpperCase(fnc2))] as TValue).Value;
                 {EvalFunction:= (VarList.objects[VarList.IndexOf(fnc2)] as TVariable).Value;{}
                 exit;
              except
                    Screen.Cursor:= crDefault;
                    frmMsg.ShowMsg('Error en la expresión', 'Se ha encontrado un nombre de variable ',
                                   'inexistente en la expresión.', true, false);
                    RunTimeObj.Color:= clBlue;
                    exit;
              end; {try-except}
         end; {if-then}
(*         if (fnc2 = 'x') then
         begin
              UsesX:= true;
              EvalFunction:= VarX;
              exit;
         end; {if-then}
         if (fnc2 = 'y') then
         begin
              UsesY:= true;
              EvalFunction:= VarY;
              exit;
         end; {if-then}
{         if (fnc2 = 'z') then
         begin
              UsesZ:= true;
              EvalFunction:= VarZ;
              exit;
         end; {if-then}
         if (fnc2 = 'a') then
         begin
              UsesA:= true;
              EvalFunction:= ParamA;
              exit;
         end; {if-then}
         if (fnc2 = 'b') then
         begin
              UsesB:= true;
              EvalFunction:= ParamB;
              exit;
         end; {if-then}
         if (fnc2 = 'c') then
         begin
              UsesC:= true;
              EvalFunction:= ParamC;
              exit;
         end; {if-then}
         if (fnc2 = 'd') then
         begin
              UsesD:= true;
              EvalFunction:= ParamD;
              exit;
         end; {if-then}
         if (fnc2 = 'm') then
         begin
              UsesM:= true;
              EvalFunction:= ParamM;
              exit;
         end; {if-then}
         if (fnc2 = 'n') then
         begin
              UsesN:= true;
              EvalFunction:= ParamN;
              exit;
         end; {if-then}*)
         {case else -> No entró en ningún if-then:}
         ErrorParser:= true;
         exit;
      except
            ErrorParser:= true;
      end; {try-except}
    end; {EvalFunction}

    {Esta función discrimina números, operadores y funcines y los separa:}
    function GetNextToken :string;
    var
       c1   :char;
       str1 :string[1];
    begin
      try
         Token:= '';
         TokenType:= '';
         repeat {Saltea espacios en blanco}
               c1:= expression[1];
               expression:= mid(expression, 2);
         until ((c1 <> chr(32)) and (c1 <> chr(10)) and
               (c1 <> chr(13)) and (c1 <> chr(9)));
         str1[1]:= c1;
         str1:= LowerCase(str1);
         c1:= str1[1];
         case c1 of
         '0'..'9','.',',': begin {Números:}
                        TokenType:= 'num';
                        repeat
                              Token:= Token + c1;
                              if (expression <> '') then
                                 c1:= expression[1]
                              else
                                   exit;
                              expression:= mid(expression, 2);
                        until not(c1 in ['0'..'9','.',',']);
                        expression:= c1 + expression;
                   end; {case '1'..'9'}
         'a'..'z': begin {Funciones y variables:}
                        TokenType:= 'function';
                        repeat
                              Token:= Token + c1;
                              if (expression <> '') then
                                 c1:= expression[1]
                              else
                                   exit;
                              {LowereCase(c1):}
                              str1[1]:= c1;
                              str1:= LowerCase(str1);
                              c1:= str1[1];
                              expression:= mid(expression, 2);
                        until not(c1 in ['a'..'z']);
                        expression:= c1 + expression;
                   end; {case 'a'..'z'}
         else {Operadores y paréntesis:}
             begin
                  TokenType:= c1;
                  Token:= c1;
             end; {case else}
         end; {case}
      except
            exit; {Ignora los posibles errores}
      end; {try-except}
    end; {GetNextToken}

    {Evaluador de expresiones propiamente dicho:}
    function Parser(prec :integer) :extended;
    var
       FunctionName :string;
       res          :extended;
       tempMark     :boolean;
    begin
      try
         GetNextToken;
         if ErrorParser then exit;
         tempMark:= true;
         if ((TokenType = 'num') and TempMark) then
         begin
              Val(Token, Res, ErrorCodeParser);
              GetNextToken;
              tempMark:= false;
              if ErrorParser then exit;
         end; {if-then}
         if ((TokenType = '-') and TempMark) then
         begin
            res:= -Parser(5);
            tempMark:= false;
         end; {if-then}
         if ((TokenType = '(') and TempMark) then
         begin
              res:= Parser(1); 
              if (TokenType <> ')') then
              begin
                   ErrorParser:= true;
                   exit;
              end; {if-hen}
              GetNextToken;
              tempMark:= false;
         end; {if-then}
         if ((TokenType = 'function') and TempMark) then
         begin
              FunctionName:= Token;
              {if ((token <> 'x') and (token <> 'y') and (token <> 'z') and
                  (token <> 'a') and (token <> 'b') and (token <> 'c') and
                  (token <> 'd') and (token <> 'm') and (token <> 'n') and
                  (token <> 'pi')) then}
              if (VarList.IndexOf(UpperCase(token)) <= -1) and (token <> 'pi') then
              begin
                   GetNextToken;
                   if (TokenType <> '(') then
                   begin
                        strErrorCode:= 'Después de una función se debe abrir un ' +
                                       'paréntesis. EJEMPLO: sen(x).';
                        ErrorParser:= true;
                        exit;
                   end; {if-then}
                   res:= Parser(1);
                   if (TokenType <>')') then
                   begin
                        strErrorCode:= 'No ha sido cerrado un paréntesis ")".';
                        ErrorParser:= true;
                        exit;
                   end; {if-then}
              end; {if-then}
              GetNextToken;
              if ErrorParser then exit;
              ErrorCodeParser:= NO_ERROR;
              res:= EvalFunction(FunctionName, res, ErrorCodeParser);
              if (ErrorCodeParser <> NO_ERROR) then
              begin
                   ErrorParser:= true;
                   exit;
              end; {if-then}
              TempMark:= false;
         end; {if-then}
         if TempMark then {Case Else: No entró en ningún if-then}
         begin
             ErrorParser:= true; {Símbolo no esperado}
             exit;
         end; {if-then}
         while not(ErrorParser) do
         begin
              TempMark:= true;
              if (TokenType = '^') then
                 if (prec <= 5) then
                 begin
                      res:= Pot(res, Parser(6), ErrorCodeParser);
                      TempMark:= false;
                 end; {if-then}
              if (TokenType = '*') then
                 if (prec <= 4) then
                 begin
                      res:= res*Parser(5);
                      TempMark:= false;
                 end; {if-then}
              if (TokenType = '/') then
                 if (prec <= 4) then
                 begin
                      res:= res/Parser(5);
                      TempMark:= false;
                 end; {if-then}
              if (TokenType = '\') then
                 if (prec <= 3) then
                 begin
                      res:= trunc(res) DIV trunc(Parser(4));
                      TempMark:= false;
                 end; {if-then}
              if (TokenType = '%') then
                 if (prec <= 2) then
                 begin
                      res:= trunc(res) MOD trunc(Parser(3));
                      TempMark:= false;
                 end; {if-then}
              if (TokenType = '+') then
                 if (prec <= 1) then
                 begin
                      res:= res + Parser(2);
                      TempMark:= false;
                 end; {if-then}
              if (TokenType = '-') then
                 if (prec <= 1) then
                 begin
                      res:= res - Parser(2);
                      TempMark:= false;
                 end; {if-then}
              if TempMark then {Case Else: No entró en ningún if-then}
              begin
                   Parser:= res;
                   exit; {Sale del while}
              end;
         end; {while}
         Parser:= res;
         exit; {Sale de la función}
      except
            if (ErrorCodeParser > 0) then {retornado por la función VAL de Pascal}
               strErrorCode:= 'El Evaluador de Expresiones encontró un ' +
                              'número escrito en un formato no válido. ' +
                              'Algunos pautas de cómo se deben ingresar valores ' +
                              'numéricos: La coma decimal es el punto; Los números ' +
                              'grandes NO se expresan en notación científica.';
            ErrorParser:= true;
            exit;
      end; {try-except}
    end; {Parser}

{Conversión de coordenadas de R^2:}
    procedure CarToPolar(x, y :extended; var r, alfa :extended;
                         var ErrorCode: integer);
    begin
      try
         r:= sqrt(x*x + y*y);
         if (y >= 0) then
         begin
              {Primer Cuadrrante:}
              if (x > 0) then
                 alfa:= ArcTan(y/x)
              else
              begin
                   {Segundo Cuadrante:}
                   if (x <> 0) then
                      alfa:= pi - abs(ArcTan(y/x))
                   else
                       alfa:= pi/2;
              end; {else}
         end {if-then}
         else
         begin
              {Cuarto Cuadrante:}
              if (x > 0) then
                 alfa:= 2*pi - abs(ArcTan(y/x))
              else
              {Tercer Cuadrante:}
              begin
                   if (x <> 0) then
                      alfa:= pi + abs(ArcTan(y/x))
                   else
                       alfa:= 3*pi/2;
              end; {else}
         end; {else}
      except
            ErrorCode:= ILLEGAL_OP;
      end; {try-except}
    end; {CarToPolar}

    procedure PolarToCar(var x, y :extended; r, alfa :extended;
                         var ErrorCode: integer);
    begin
      try
         x:= r*cos(alfa);
         y:= r*sin(alfa);
      except
            ErrorCode:= ILLEGAL_OP;
      end; {try-except}
    end; {PolarToCar}

{Rutinas y tipos para números complejos:}
    procedure CxSum(C1, C2 :TComplex; var CRes :TComplex);
    begin
      try
         CRes.R:= C1.R + C2.R;
         CRes.i:= C1.i + C2.i;
      except
            exit;
      end; {try-except}
    end; {CxSum}

    procedure CxSubs(C1, C2 :TComplex; var CRes :TComplex);
    begin
      try
         CRes.R:= C1.R - C2.R;
         CRes.i:= C1.i - C2.i;
      except
            exit;
      end; {try-except}
    end; {CxSubs}

    procedure CxProd(C1, C2 :TComplex; var CRes :TComplex);
    begin
      try
         CRes.R:= C1.R*C2.R - C1.i*C2.i;
         CRes.i:= C1.R*C2.i + C1.i*C2.R;
      except
            exit;
      end; {try-except}
    end; {CxProd}

    function CxConj(C :TComplex) :TComplex;
    begin
         CxConj.R:= C.R;
         CxConj.i:= -C.i;
    end; {CxConj}

    function CxMod(C :TComplex) :extended;
    begin
         CxMod:= sqrt(C.R*C.R + C.i*C.i);
    end; {CxMod}

    function CxInv(C :TComplex) :TComplex;
    begin
         if (CxMod(C) <> 0) then
         begin
              CxInv.R:= CxConj(C).R/(CxMod(C)*CxMod(C));
              CxInv.i:= CxConj(C).i/(CxMod(C)*CxMod(C));
         end {if-then}
         else
         begin
              CxInv.R:= 0;
              CxInv.i:= 0;
         end; {else}
    end; {CxInv}

{Rutinas para fractales:}
    function Mandelbrot(cx, cy :double; MaxIter :integer):integer;
    var
       x, y, x1, y1, temp :double;
       iter               :integer;
    begin
      try
         x:= 0;
         y:= 0;
         x1:= 0;
         y1:= 0;
         iter :=0;
         while ((iter < MaxIter) and (abs(x1 + y1) < 100000)) do
         begin
              temp:= x1 - y1 + cx;
              y:= 2*x*y + cy;
              x:= temp;
              x1:= x*x;
              y1:= y*y;
              iter:= iter + 1;
         end; {while}
         Mandelbrot:= iter;
      except
            exit;
      end; {try-except}
    end; {Mandelbrot}

    function Julia(cx, cy , x, y :double; MaxIter :integer):integer;
    var
       x1, y1, xTemp, yTemp :double;
       iter                 :integer;
    begin
      try
         iter:= 0;
         x1:= x + cx;
         y1:= y + cy;
         while ((iter < MaxIter) and ((abs(x1) + abs(y1)) < 100000)) do
         begin
              xTemp:= x1*x1 - y1*y1 + cx;
              yTemp:= 2*x1*y1 + cy;
              x1:=xTemp;
              y1:=yTemp;
              inc(iter);
         end; {while}
         Julia:= iter;
      except
            exit;
      end; {try-except}
    end; {Julia}

initialization
              Token:= '';
              TokenType:= '';
              expression:= '';
              strErrorCode:= '';
              UsesX:= false;
              UsesY:= false;
              UsesA:= false;
              UsesB:= false;
              UsesC:= false;
              UsesD:= false;
              UsesM:= false;
              UsesN:= false;
              ParamA:= 1;
              ParamB:= 1;
              ParamC:= 1;
              ParamD:= 1;
              ParamM:= 1;
              ParamN:= 1;
end. {Unit Math1}
