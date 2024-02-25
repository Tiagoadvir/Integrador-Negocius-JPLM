unit Biblioteca;

interface

uses SysUtils, Classes,{ QGraphics, QControls,} Math;

const
  C1 = 52845;
  C2 = 22719;

var u: integer;

function TiraAcentos(s: string): string;
function Padr(Texto: string; Tam: Integer; Caractere: char = ' '): string;
function Padl(Texto: string; Tam: Integer): string;
function Padc(Texto: string; Tam: Integer): string;
function zeros(s: longint; larg: byte): string;
function zerosC(s: string; larg: byte): string;
function FormataCPF(s: string): string;
function FormataCEP(s: string): string;
function FormataFone(s: string): string;
function FormataPlaca(s: string): string;
function CalculaDV(numero: string): byte;
function VerificaDV(numero: string): boolean;
function CalculaDVCPF(CPF: string): string;
function VerificaCPF(CPF: string): boolean;
function CalculaDVCGC(CGC: string): string;
function VerificaCGC(CGC: string): boolean;
//function VerificaCGF (CGF : string) : boolean;
function Arredonda(n: Double): Double;
function UltimoDia(Data: TDateTime): TDateTime;
function Encrypt(const S: string; Key: Word): string;
function Decrypt(const S: string; Key: Word): string;
procedure EncryptFile(INFName, OutFName: string; Key: Word);
procedure DecryptFile(INFName, OutFName: string; Key: Word);
function troca(var s: string; a, b: string; sep: boolean): integer;
function Extenso(pValor: Real): string;
function JstParagrafo(Paragrafo: string; Largura: word): string;
function se(cond: boolean; v1, v2: string): string;
function seNum(cond: boolean; v1, v2: real): real;
function Estado(uf: string): boolean;
function RTrim(s: string): string;
function PosBranco(s: string): integer;
function UltBranco(s: string): integer;
function Mes(m: byte): string;
function MesDia(m: string): string;
function DataExtenso(d: TDateTime): string;
function HoraExtenso(hora: string): string;
function Romano(n: byte): string;
function Maiusc(s: string): string;
function fExtenso(nValor: Real): string;
function BinToDec(s: string): byte;
function DecToBin(d: byte): string;
function BinToHex(s: string): string;
function HexToDec(h: string): byte;
function BXOR(b1, b2: string): string;
function Crip(senha, chave: string): string;
function DeCrip(senha, chave: string): string;
function ArqTemp: string;
function VerificaCGF(CgfP, Estado: string): boolean;
function Valor_CGF(CgfP: string): string;
function LimpaNumero(s: string): real;
function EstaNoArray(varValor: string; arrProcura: array of string): boolean;
function MidTrim(s: string): string;
function DataSql(dtData: TDateTime): string;
function ValidaMes(strMes: string): boolean;
function PontoVirg(s: string): string;

implementation

function TiraAcentos(s: string): string;
var i: byte;
begin
  for i := 1 to length(s) do
    case s[i] of

      'á': s[i] := 'a';
      'à': s[i] := 'a';
      'ã': s[i] := 'a';
      'â': s[i] := 'a';
      'ä': s[i] := 'a';
      'Á': s[i] := 'A';
      'À': s[i] := 'A';
      'Ã': s[i] := 'A';
      'Â': s[i] := 'A';
      'Ä': s[i] := 'A';
      'è': s[i] := 'e';
      'é': s[i] := 'e';
      'ê': s[i] := 'e';
      'ë': s[i] := 'e';
      'É': s[i] := 'E';
      'È': s[i] := 'E';
      'Ê': s[i] := 'E';
      'Ë': s[i] := 'E';
      'í': s[i] := 'i';
      'ì': s[i] := 'i';
      'î': s[i] := 'i';
      'ï': s[i] := 'i';
      'Í': s[i] := 'I';
      'Ì': s[i] := 'I';
      'Î': s[i] := 'I';
      'Ï': s[i] := 'I';
      'ó': s[i] := 'o';
      'ò': s[i] := 'o';
      'õ': s[i] := 'o';
      'ô': s[i] := 'o';
      'Ó': s[i] := 'O';
      'Ò': s[i] := 'O';
      'Õ': s[i] := 'O';
      'Ô': s[i] := 'O';
      'ú': s[i] := 'u';
      'ù': s[i] := 'u';
      'û': s[i] := 'u';
      'ü': s[i] := 'u';
      'Ú': s[i] := 'U';
      'Ù': s[i] := 'U';
      'Û': s[i] := 'U';
      'Ü': s[i] := 'U';
      'ç': s[i] := 'c';
      'Ç': s[i] := 'C';
      'ñ': s[i] := 'n';
      'Ñ': s[i] := 'N';
      '!': s[i] := ' ';
      '}': s[i] := ' ';
      '{': s[i] := ' ';
      ']': s[i] := ' ';
      '[': s[i] := ' ';
      '(': s[i] := ' ';
      ')': s[i] := ' ';
      '&': s[i] := ' ';
      '§': s[i] := ' ';
      '@': s[i] := ' ';
      '£': s[i] := ' ';
      '¹': s[i] := ' ';
      '²': s[i] := ' ';
      '³': s[i] := ' ';
      '¢': s[i] := ' ';
      '¬': s[i] := ' ';
      'º': s[i] := ' ';
      '°': s[i] := ' ';
      'ª': s[i] := ' ';
      '|': s[i] := ' ';
      '"': s[i] := ' ';
      '<': s[i] := ' ';
      '>': s[i] := ' ';
      '%': s[i] := ' ';
      '$': s[i] := ' ';
      '#': s[i] := ' ';
      '*': s[i] := ' ';
      '_': s[i] := ' ';

    end;
  TiraAcentos := s;
end;

function Padr(Texto: string; Tam: Integer; Caractere: char = ' '): string;
var tamtex, n: integer;
begin
  tamtex := Length(Texto);
  Result := Texto;
  if tamtex > tam then
    Result := Copy(Texto, 1, tam);
  if tamtex < tam then
    for n := tamtex to tam - 1 do
      Result := Result + caractere;
end;

function zeros(s: longint; larg: byte): string;
var x: byte;
  r: string;
begin
  r := IntToStr(s);
  for x := length(r) to larg - 1 do
    r := '0' + r;
  zeros := r;
end;

function zerosC(s: string; larg: byte): string;
var x: byte;
begin
  for x := length(s) to larg - 1 do
    s := '0' + s;
  zerosC := s;
end;

function FormataCPF(s: string): string;
begin
  if length(s) <= 11 then
    s := Copy(s, 1, 3) + '.' + Copy(s, 4, 3) + '.' + Copy(s, 7, 3) + '-' + Copy(s, 10, 2)
  else
    s := Copy(s, 1, 2) + '.' + Copy(s, 3, 3) + '.' + Copy(s, 6, 3) + '/' + Copy(s, 9, 4) + '-' + Copy(s, 13, 2);
  FormataCPF := s;
end;

function FormataCEP(s: string): string;
begin
  FormataCEP := Copy(s, 1, 2) + '.' + Copy(s, 3, 3) + '-' + Copy(s, 6, 3);
end;

function FormataFone(s: string): string;
begin
  FormataFone := '(' + Copy(s, 1, 3) + ')' + Copy(s, 4, 4) + '.' + Copy(s, 8, 4);
end;

function CalculaDV(numero: string): byte;
var i, soma: integer;
begin
  soma := 0;

  for i := 1 to length(numero) do
    soma := soma + StrToInt(Copy(numero, length(numero) - i + 1, 1)) * (i + 1);

  i := 11 - (soma mod 11);

  if i > 9 then i := 0;

  CalculaDV := i;
end;

function VerificaDV(numero: string): boolean;
var i: byte;
  saida: string;
begin
  saida := '';

  for i := 1 to length(numero) do
    if (numero[i] <> '.') and (numero[i] <> '-') and (numero[i] <> '/') then
      saida := saida + numero[i];

  VerificaDV := (Copy(saida, Length(saida), 1) =
    IntToStr(CalculaDV(Copy(saida, 1, Length(saida) - 1))));
end;

function CalculaDVCPF(CPF: string): string;
var d1, d2: byte;
begin

  d1 := CalculaDV(CPF);
  CPF := CPF + IntToStr(d1);
  d2 := CalculaDV(CPF);

  CalculaDVCPF := IntToStr(d1) + IntToStr(d2);
end;

function VerificaCPF(CPF: string): boolean;
var i: byte;
  saida: string;
begin
  saida := '';

  for i := 1 to length(CPF) do
    if (CPF[i] <> '.') and (CPF[i] <> '-') and (CPF[i] <> '/') then
      saida := saida + CPF[i];

  VerificaCPF := (CalculaDVCPF(Copy(saida, 1, 9)) = Copy(saida, 10, 2));
end;

function CalculaDVCGC(CGC: string): string;
var soma: integer;
  ii: byte;
  d1, d2: byte;
begin
  soma := 0;
  for ii := 1 to 12 do
    begin
      if ii < 5 then
        Inc(soma, StrToInt(Copy(CGC, ii, 1)) * (6 - ii))
      else
        Inc(soma, StrToInt(Copy(CGC, ii, 1)) * (14 - ii))
    end;
  d1 := 11 - (soma mod 11);

  if d1 > 9 then d1 := 0;

  CGC := CGC + IntToStr(d1);

  {2° digito}
  soma := 0;
  for ii := 1 to 13 do
    begin
      if ii < 6 then
        Inc(soma, StrToInt(Copy(CGC, ii, 1)) * (7 - ii))
      else
        Inc(soma, StrToInt(Copy(CGC, ii, 1)) * (15 - ii))
    end;
  d2 := 11 - (soma mod 11);
  if d2 > 9 then d2 := 0;

  CalculaDVCGC := IntToStr(d1) + IntToStr(d2);
end;

function VerificaCGC(CGC: string): boolean;
var i: byte;
  saida: string;
begin
  saida := '';
  if length(trim(CGC)) = 14 then
    begin
      for i := 1 to length(CGC) do
        if (CGC[i] <> '.') and (CGC[i] <> '-') and (CGC[i] <> '/') then
          saida := saida + CGC[i];
      VerificaCGC := (CalculaDVCGC(Copy(saida, 1, 12)) = Copy(saida, 13, 2));
    end
  else
    VerificaCGC := false;
end;

function Arredonda(n: Double): Double;
var s: string;
  a: Double;
  p: byte;
begin
  Str(n: 20: 2, s);
  s := Trim(s);

  p := Pos('.', s);
  Delete(s, p, 1);
  Insert(',', s, p);

  a := StrToFloat(s);
  Arredonda := a;
end;

function UltimoDia(Data: TDateTime): TDateTime;
var mes: byte;
  d, c: string;
begin
  d := DateToStr(Data);
  mes := StrToInt(Copy(d, 4, 2));

  case mes of
    01: c := '31';
    02: c := '28';
    03: c := '31';
    04: c := '30';
    05: c := '31';
    06: c := '30';
    07: c := '31';
    08: c := '30';
    09: c := '30';
    10: c := '31';
    11: c := '30';
    12: c := '31';
  end;

  d[1] := c[1];
  d[2] := c[2];
  UltimoDia := StrToDate(d);
end;

function Encrypt(const S: string; Key: Word): string;
var
  I: Integer;
begin
  Result := S;
  for I := 1 to Length(S) do
    begin
      Result[I] := char(byte(S[I]) xor (Key shr 8));
      Key := (byte(Result[I]) + Key) * C1 + C2;
    end;
end;

function Decrypt(const S: string; Key: Word): string;
var
  I: Integer;
begin
  Result := S;
  for I := 1 to Length(S) do
    begin
      Result[I] := char(byte(S[I]) xor (Key shr 8));
      Key := (byte(S[I]) + Key) * C1 + C2;
    end;
end;

procedure EncryptFile(INFName, OutFName: string; Key: Word);
var
  MS, SS: TMemoryStream;
  X: Integer;
  C: Byte;
begin
  MS := TMemoryStream.Create;
  SS := TMemoryStream.Create;
  try
    MS.LoadFromFile(INFName);
    MS.Position := 0;
    for X := 0 to MS.Size - 1 do
      begin
        MS.Read(C, 1);
        C := (C xor (Key shr 8));
        Key := (C + Key) * C1 + C2;
        SS.Write(C, 1);
      end;
    SS.SaveToFile(OutFName);
  finally
    SS.Free;
    MS.Free;
  end;
end;

procedure DecryptFile(INFName, OutFName: string; Key: Word);
var
  MS, SS: TMemoryStream;
  X: Integer;
  C, O: Byte;
begin
  MS := TMemoryStream.Create;
  SS := TMemoryStream.Create;
  try
    MS.LoadFromFile(INFName);
    MS.Position := 0;
    for X := 0 to MS.Size - 1 do
      begin
        MS.Read(C, 1);
        O := C;
        C := (C xor (Key shr 8));
        Key := (O + Key) * C1 + C2;
        SS.Write(C, 1);
      end;
    SS.SaveToFile(OutFName);
  finally
    SS.Free;
    MS.Free;
  end;
end;

function Padl(Texto: string; Tam: Integer): string;
var tamtex, n: integer;
begin
  tamtex := Length(Texto);
  Result := Texto;
  if tamtex > tam then
    Result := Copy(Texto, tamtex - tam + 1, tam);
  if tamtex < tam then
    for n := tamtex to tam - 1 do Result := ' ' + Result;
end;

function LenNum(Numero: Real): Integer;

var cNumero: string;
begin
  cNumero := FormatFloat('0.000E+00', Numero);
  Result := StrToInt(Copy(cNumero, Length(cNumero) - 1, 2)) + 1

  {FloatToStrF(Numero; ffExponent; 14,2)}
end;

function Padlzero(Texto: string; Tam: Integer): string;

var tamtex, n: integer;
begin
  tamtex := Length(Texto);
  Result := Texto;
  if tamtex > tam then Result := Copy(Texto, tamtex - tam + 1, tam);
  if tamtex < tam then for n := (tamtex + 1) to tam do Result := '0' + Result;
end;

function ExtensoMil(cVlr: string): string;

const

  // Os Acentos foram retirados em função de não serem impressos na Epson LX
  aExp: array[1..37] of string = (
    'um', 'dois', 'tres', 'quatro', 'cinco', 'seis', 'sete', 'oito', 'nove', 'dez',
    'onze', 'doze', 'treze', 'quatorze', 'quinze', 'dezesseis', 'dezessete',
    'dezoito', 'dezenove', 'vinte', 'trinta', 'quarenta', 'cinquenta', 'sessenta',
    'setenta', 'oitenta', 'noventa', 'cem', 'duzentos', 'trezentos', 'quatrocentos',
    'quinhentos', 'seiscentos', 'setecentos', 'oitocentos', 'novecentos', 'cento'
    );

var
  c1, c2, c3: string;
  e1, e2, e3, cJuncao1, cJuncao2: string;
  n1, n2, n3, n23: Integer;

begin
  c1 := Copy(cVlr, 1, 1); c2 := Copy(cVlr, 2, 1); c3 := Copy(cVlr, 3, 1);
  n1 := StrToInt(c1); n2 := StrToInt(c2); n3 := StrToInt(c3);
  e1 := ''; e2 := ''; e3 := '';
  n23 := StrToInt(c2 + c3);
  if n1 > 0
    then
    if ((n1 = 1) and ((n2 + n3) > 0))
      then e1 := aExP[37]
    else e1 := aExp[27 + n1];
  if n2 > 1
    then begin
      e2 := aExp[18 + n2];
      if n3 > 0
        then e3 := aExp[n3];
    end
  else begin
      e2 := '';
      if n23 > 0
        then e3 := aExp[n23];
    end;
  if ((n1 = 0) or (n23 = 0))
    then cJuncao1 := ''
  else cJuncao1 := ' e ';
  if ((Length(e2) = 0) or (Length(e3) = 0))
    then cJuncao2 := ''
  else cJuncao2 := ' e ';

  Result := e1 + cJuncao1 + e2 + cJuncao2 + e3;

end;

function fExtenso(nValor: Real): string;

const
  aexsp: array[1..8] of string = ('', ' mil', ' milhões', ' bilhões', ' trilhões',
    'quadrilhões', ' quinqualhões', ' sextalhões');
  aexss: array[1..8] of string = ('', ' mil', ' milhão ', ' bilhão ', ' trilhão ',
    ' quadrilhão ', ' quinqualhão ', ' sextalhão');
var

  NumGrupos, n, nn: Integer;
  cValor, tExtenso, xExtenso, cGrupo: string;

begin
  NumGrupos := ((LenNum(nValor) + 2) div 3);
  cValor := PadlZero(FloattoStr(nValor), NumGrupos * 3);
  tExtenso := '';
  xExtenso := '';

  for n := 1 to NumGrupos do
    begin
      cGrupo := Copy(cValor, n * 3 - 2, 3);
      xExtenso := ExtensoMil(cGrupo);
      nn := NumGrupos - n + 1;
      if Length(xExtenso) > 0
        then
        begin
          if cGrupo = '001'
            then xExtenso := xExtenso + aExSS[nn]
          else xExtenso := xExtenso + aExSP[nn];
          if Length(tExtenso) > 0
            then tExtenso := tExtenso + ' e ';
          tExtenso := tExtenso + xExtenso;
        end;

    end;

  Result := tExtenso;
end;

function Extenso(pValor: Real): string;

var
  nParte1, nParte2: Comp;
  xExt1, xExt2, xJuncao: string;

begin
  nParte1 := Int(pValor);
  nParte2 := Round((pValor - nParte1) * 100);
  xExt1 := fExtenso(nParte1);
  xExt2 := fExtenso(nParte2);
  if ((Length(xExt1) = 0) and (Length(xExt2) = 0))
    then xExt1 := 'ZERO';

  if xExt1 = 'UM'
    then xExt1 := xExt1 + ' real'
  else if xExt1 <> '' then xExt1 := xExt1 + ' reais';


  if Length(xExt2) > 0
    then
    if xExt2 = 'UM'
      then xExt2 := xExt2 + ' centavo'
    else xExt2 := xExt2 + ' centavos';

  if ((Length(xExt1) = 0) or (Length(xExt2) = 0))
    then xJuncao := ''
  else xJuncao := ' e ';

  Result := xExt1 + xJuncao + xExt2;
end;


function troca(var s: string; a, b: string; sep: boolean): integer;
// Substitui por b todas as ocorrencias de a em s]
// Retorna o numero de trocas realizadas
// Nao diferencia maisculas e minusculas
// Se sep=true, procura os separadores para trocar apenas palavras exatas
var conta: integer;
  x: integer;
  separadores: string;
begin
  separadores := ' (),+-/*;.';
  conta := 0; //Quantas ocorrencias foram trocadas
  //     posicao := 0;    //posicao em que a subcadeia foi encontrada
  //     y := 1;          //contador da cadeia a ser procurada
  x := 1;

  while x <= length(s) do
    begin
      if sep then
        begin
          if (copy(s, x, length(a)) = a)
            and ((pos(copy(s, x + length(a), 1), separadores) > 0)
            or (x + length(a) > length(s))) then
            begin
              Insert(b, s, x + length(a));
              Delete(s, x, length(a));
              conta := conta + 1;
            end;
          x := x + 1;
        end
      else
        begin
          if (copy(s, x, length(a)) = a) then
            begin
              Insert(b, s, x + length(a));
              Delete(s, x, length(a));
              conta := conta + 1;
            end;
          x := x + 1;
        end;
    end;

  troca := conta;
end;


function SubstituiCaractere(vString, vStr1, vStr2: string): string;
begin
  while Pos(vStr1, vString) <> 0 do
    vString := Copy(vString, 1, Pos(vStr1, vString) - 1) + vStr2 +
      Copy(vString, Pos(vStr1, vString) + Length(vStr1), Length(vString) - (Pos(vStr1, vString) + Length(vStr1) - 1));
  Result := vString
end; { SubstituiCaractere }
//

function PreencheD(Cadeia: string; Tamanho: integer; Caractere: string): string;
begin
  while Length(Cadeia) < Tamanho do
    Cadeia := Cadeia + Caractere;
  Result := Copy(Cadeia, 1, Tamanho)
end; { PadR }
//

function Alltrim(Cadeia: string): string;
var Inicio, Fim: integer;
begin
  Inicio := 1;
  while (Copy(Cadeia, Inicio, 1) = ' ') and (Inicio < Length(Cadeia)) do
    Inc(Inicio);
  Fim := Length(Cadeia);
  while (Copy(Cadeia, Fim, 1) = ' ') and (Fim > Inicio) do
    Dec(Fim);
  Result := Copy(Cadeia, Inicio, Fim - Inicio + 1)
end; { Alltrim }



function JstString(StringInicial: string; TamanhoFinal: byte): string;
var
  AUXString: string;
  TamanhoAUXString,
    i: byte;
begin
  AUXString := Alltrim(StringInicial);
  AUXString := SubstituiCaractere(AUXString, '  ', ' ');
  TamanhoAUXString := Length(AUXString);
  i := TamanhoAUXString;
  while (TamanhoAUXString < TamanhoFinal) and (Pos(' ', AUXString) <> 0) do
    begin
      while (Copy(AUXString, i, 1) <> ' ') and (i > 0) do
        Dec(i);
      if i > 0 then
        begin
          AUXString := Copy(AUXString, 1, i - 1) + ' ' + Copy(AUXString, i, TamanhoAUXString + 1);
          Inc(TamanhoAUXString)
        end; { if }
      while (Copy(AUXString, i, 1) = ' ') and (i > 0) do
        Dec(i);
      if i = 0 then
        i := TamanhoAUXString
    end; { while }
  Result := AUXString
end; { JstString }
//

function JstParagrafo(Paragrafo: string; Largura: word): string;
var Inicio, Fim: word;
begin
  if Largura = 0 then
    Largura := 1;
  Paragrafo := Alltrim(Paragrafo);
  Paragrafo := SubstituiCaractere(Paragrafo, #10, '');
  Paragrafo := SubstituiCaractere(Paragrafo, #13, '');
  Paragrafo := SubstituiCaractere(Paragrafo, '  ', ' ');
  Inicio := 1;
  Result := '';
  while Inicio <= Length(Paragrafo) do begin
      while (Inicio <= Length(Paragrafo)) and (Copy(Paragrafo, Inicio, 1) = ' ') do
        Inc(Inicio);
      Fim := Inicio + Largura; // -1;
      if Fim <= Length(Paragrafo) then
        begin
          while (Fim > Inicio) and (Copy(Paragrafo, Fim, 1) <> ' ') do
            Dec(Fim);
          while (Fim > Inicio) and (Copy(Paragrafo, Fim, 1) = ' ') do
            Dec(Fim);
          if Fim = Inicio then
            Fim := Inicio + Largura - 1
        end; { if }
      if Fim >= Length(Paragrafo) then
        Result := Result + PreencheD(Alltrim(Copy(Paragrafo, Inicio, Fim - Inicio + 1)), Largura, ' ')
      else
        Result := Result + Alltrim(JstString(Copy(Paragrafo, Inicio, Fim - Inicio + 1), Largura)) + #13 + #10;
      Inicio := Fim + 1
    end { while }
end; { JstParagrafo }

function se(cond: boolean; v1, v2: string): string;
begin
  if cond then
    se := v1
  else
    se := v2;
end;

function seNum(cond: boolean; v1, v2: real): real;
begin
  if cond then
    seNum := v1
  else
    seNum := v2;
end;

function Estado(uf: string): boolean;
begin
  Estado := pos(uf, 'AP AM RR RO AC PA MT MS MA TO GO RS SC PR SP RJ ES BA SE AL PE PB RN PI CE DF MG') > 0;
end;

function PosBranco(s: string): integer;
var i: integer;
begin
  i := u;
  while i <= length(s) do
    begin
      if s[i] = ' ' then
        begin
          u := i;
          break;
        end;
      inc(i);
    end;
  PosBranco := u;
end;

function UltBranco(s: string): integer;
var i: integer;
begin
  i := length(s);
  while i >= 1 do
    begin
      if s[i] = ' ' then
        break;
      dec(i);
    end;
  UltBranco := i;
end;

function RTrim(s: string): string;
var i: integer;
begin
  if s <> '' then
    begin
      i := length(s);
      while (s[i] = ' ') and (i > 0) do
        begin
          s := copy(s, 1, length(s) - 1);
          i := length(s);
        end;
      RTrim := s;
    end;
end;

function MesDia(m: string): string;
var r: string;
  N: byte;
begin
  try
    n := StrToInt(Copy(m, 1, 2));
  except
    n := 0;
  end;
  r := mes(n);
  r := Copy(m, 3, 2) + ' de ' + r;
  MesDia := r;
end;

function Mes(m: byte): string;
var r: string;
  N: byte;
begin
  n := m;
  case n of
    0: r := '';
    1: r := 'Janeiro';
    2: r := 'Fevereiro';
    3: r := 'Março';
    4: r := 'Abril';
    5: r := 'Maio';
    6: r := 'Junho';
    7: r := 'Julho';
    8: r := 'Agosto';
    9: r := 'Setembro';
    10: r := 'Outubro';
    11: r := 'Novembro';
    12: r := 'Dezembro';
  end;
  Mes := r;
end;

function DataExtenso(d: TDateTime): string;
var data: string;
  dia, m, a: string;
begin
  data := DateToStr(d);
  dia := Copy(data, 1, 2);
  m := Copy(data, 4, 2);
  a := Copy(data, 7, 4);
  DataExtenso := dia + ' (' + fExtenso(StrToFloat(dia)) + ') dias do mês de ' +
    mes(StrToInt(m)) + ' de ' + a + ' (' + fExtenso(StrToFloat(a)) + ')';
end;

function HoraExtenso(hora: string): string;
var h, m: string;
begin
  h := copy(hora, 1, 2);
  m := copy(hora, 4, 2);

  h := h + ':' + m + ' (' + fExtenso(StrToFloat(h)) + ') horas';
  if StrToInt(m) <> 0 then
    h := h + ' e ' + m + '(' + fExtenso(StrToFloat(m)) + ') minutos';

  HoraExtenso := h;
end;


function Romano(n: byte): string;
var num: array[1..30] of string;
begin
  num[1] := 'I';
  num[2] := 'II';
  num[3] := 'III';
  num[4] := 'IV';
  num[5] := 'V';
  num[6] := 'VI';
  num[7] := 'VII';
  num[7] := 'VIII';
  num[8] := 'IX';
  num[10] := 'X';
  num[11] := 'XI';
  num[12] := 'XII';
  num[13] := 'XIII';
  num[14] := 'XIV';
  num[15] := 'XV';
  num[16] := 'XVI';
  num[17] := 'XVII';
  num[18] := 'XVIII';
  num[19] := 'XIX';
  num[20] := 'XX';
  num[21] := 'XXI';
  num[22] := 'XXII';
  num[23] := 'XXIII';
  num[24] := 'XXIV';
  num[25] := 'XXV';
  num[26] := 'XXVI';
  num[27] := 'XXVII';
  num[27] := 'XXVIII';
  num[28] := 'XXIX';
  num[30] := 'XXX';
  romano := num[n];
end;

//Converter para maiúsculas, porém com acentos

function Maiusc(s: string): string;
var i: byte;
begin
  for i := 1 to length(s) do
    case s[i] of
      'á': s[i] := 'Á';
      'é': s[i] := 'É';
      'í': s[i] := 'Í';
      'ó': s[i] := 'Ó';
      'ú': s[i] := 'Ú';
      'ã': s[i] := 'Ã';
      'õ': s[i] := 'Õ';
      'ç': s[i] := 'Ç';
      'à': s[i] := 'À';
      'â': s[i] := 'Â';
      'ê': s[i] := 'Ê';
      'ô': s[i] := 'Ô';
      'î': s[i] := 'Î';
      'û': s[i] := 'Û';
    else
      s[i] := UpCase(s[i]);
    end;
  Maiusc := s;
end;

function DecToBin(d: byte): string;
var s: string;
begin
  s := '';
  while d >= 2 do
    begin
      s := IntToStr((d mod 2)) + s;
      d := d div 2;
    end;
  s := trim(inttostr(d) + s);
  DecToBin := s;
end;

function BinToDec(s: string): byte;
var i: byte;
  r: byte;
begin
  r := 0;
  for i := length(s) downto 1 do
    r := r + Trunc(StrToInt(copy(s, i, 1)) * Power(2, length(s) - i));
  BinToDec := r;
end;

function BinToHex(s: string): string;
var b1, b2: string;
  d1, d2: byte;
begin
  s := ZerosC(s, 8);
  b1 := copy(s, 1, 4);
  b2 := copy(s, 5, 4);
  d1 := BinToDec(b1);
  d2 := BinToDec(b2);
  if d1 > 9 then
    b1 := Chr(55 + d1)
  else
    b1 := IntToStr(d1);

  if d2 > 9 then
    b2 := Chr(55 + d2)
  else
    b2 := IntToStr(d2);

  BinToHex := b1 + b2;
end;

function HexToDec(h: string): byte;
var b1, b2: byte;
begin
  if h[1] > '9' then
    b1 := Ord(h[1]) - 55
  else
    b1 := StrToInt(h[1]);

  if h[2] > '9' then
    b2 := Ord(h[2]) - 55
  else
    b2 := StrToInt(h[2]);

  HexToDec := b1 * 16 + b2;
end;

function BXOR(b1, b2: string): string;
var i: byte;
  r: string;
begin
  b1 := ZerosC(b1, 8);
  b2 := ZerosC(b2, 8);
  r := '';
  for i := 1 to 8 do
    if b1[i] = b2[i] then
      r := r + '0'
    else
      r := r + '1';

  BXOR := r;
end;

function Crip(senha, chave: string): string;
var i, j: integer;
  b1, b2: string;
  r: string;
begin
  j := 1;
  r := '';
  for i := 1 to length(senha) do
    begin
      b1 := DecToBin(Ord(senha[i]));
      b2 := DecToBin(Ord(chave[j]));
      b1 := BXOR(b1, b2);
      b1 := BinToHex(b1);
      r := r + b1;
      j := j + 1;
      if j > length(chave) then
        j := 1;
    end;
  Crip := r;
end;

function DeCrip(senha, chave: string): string;
var i, j: integer;
  b1, b2: string;
  d1: byte;
  r: string;
begin
  j := 1;
  r := '';
  i := 1;
  while i < length(senha) do
    begin
      d1 := HexToDec(senha[i] + senha[i + 1]);
      b1 := DecToBin(d1);
      b2 := DecToBin(Ord(chave[j]));
      b1 := BXOR(b1, b2);
      d1 := BinToDec(b1);
      r := r + Chr(d1);
      j := j + 1;
      if j > length(chave) then
        j := 1;
      i := i + 2;
    end;
  DeCrip := r;
end;

function Padc(Texto: string; Tam: Integer): string;
var tamtex, n: integer;
begin
  tamtex := Length(Texto);
  n := (Tam - TamTex) div 2;
  Result := StringOfChar(' ', n) + Texto;
end;

//Acha um nome de arquivo temporário que não exista

function ArqTemp: string;
var carq: string[8];
  n: longint;
begin
  randomize;
  repeat
    n := random(100000000);
    cArq := Zeros(n, 8);
  until not FileExists(cArq + '.TMP');
  result := cArq + '.tmp';
end;

//Verificar dígito da inscrição estadual

function VerificaCGF(CgfP, Estado: string): boolean;
var lRet: boolean;
  strDig,strDig2, strCGF,strCGF2,strAux: string;
  intMult, p, d,nSoma : Integer;
  nDig,nDig2, nX: integer;
begin

     strAux:=CgfP;
     strCGF:= '';

     while (Length(strAux) < 8) do
          strAux := '0' + strAux;

     for nX := 1 to Length(strAux) do
        if strAux[nX] in ['0'..'9'] then
          strCGF := strCGF + strAux[nX];


    if (Estado = 'AC') then //Acre
    begin
        lRet:= length(strCGF) = 13;
        if (lRet)then
        Begin
              strDig := copy(strCGF, 12, 2);
              strCGF2 := copy(strCGF, 1, 11);

              intMult:=4;nSoma := 0;
              For nX := 1 To 11 Do
              begin
                nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
                intMult := intMult - 1 ;
                If intMult = 1 Then
                  intMult := 9;
              end;

              nDig := nSoma mod 11;
              nDig := 11 - nDig;

              if nDig > 9 then
                nDig := 0;

              intMult:=5; nSoma:=0;
              strCGF2:=strCGF2+inttostr(nDig);
              For nX := 1 To 12 Do
              begin
                nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
                intMult := intMult - 1 ;
                If intMult = 1 Then
                  intMult := 9;
              end;
              nDig2 := nSoma mod 11;
              nDig2 := 11 - nDig2;

              if nDig2 > 9 then
                nDig2 := 0;
              strDig2:= inttostr(nDig)+inttostr(nDig2);
        End;
        if (strDig = strDig2) and (lRet)then
          lRet := True
        else
          lRet := False;
    End
    else
    if (Estado = 'AL')then  //Alagoas
    begin
        lRet:= length(strCGF) = 9;
        if (lRet)then
        Begin
            if (copy(strCGF, 1,2) <> '24') then
               lRet:=False;
            //if (pos(copy(strCGF, 3,1),'0,3,5,7,8')=0) then
            //   lRet:=False;

            strDig := copy(strCGF, 9, 1);
            strCGF2 := copy(strCGF, 1, 8);

            intMult:=9;nSoma := 0;
            For nX := 1 To 8 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1 ;
              If intMult = 1 Then
                intMult := 9;
            end;

            nDig := nSoma * 10;
            nDig := StrToInt(FloatToStr((nDig -Int(nDig/11)*11)));


            if nDig > 9 then
              nDig := 0;

            strDig2:= inttostr(nDig);
        End;
        if (strDig = strDig2) and (lRet) then
          lRet := True
        else
          lRet := False;
    end
    else
    if (Estado = 'AP') then   //Amapá
    begin
        lRet:= length(strCGF) = 9;
        if (lRet)then
        Begin
            if (copy(strCGF, 1,2) <> '03') then
               lRet:=False;

            strDig := copy(strCGF, 9, 1);
            strCGF2 := copy(strCGF, 1, 8);

            if (strtoint(strCGF2)>=03000001)  and (strtoint(strCGF2)<= 03017000)Then
            Begin
                p:= 5; d:= 0;
            End
            else
              if (strtoint(strCGF2)>=03017001)  and (strtoint(strCGF2)<=03019022)Then
              Begin
                  p:= 9; d:= 1;
              End
              else
              Begin
                  p:= 0; d:= 0;
              End;

            intMult:=9;nSoma := 0;
            for nX := 1 to 8 do
              nSoma := nSoma + StrToInt(copy(strCGF2, nX, 1)) * intMult;

            nDig := (p+nSoma) mod 11;
            nDig := 11 - nDig;
            nDig := StrToInt(FloatToStr((nDig -Int(nDig/11)*11)));


            if nDig = 10 then
              nDig := 0;
            if nDig = 11 then
              nDig:= d;

            strDig2:= inttostr(nDig);
        End;
        if (strDig = strDig2) and (lRet) then
          lRet := True
        else
          lRet := False;
    end
    else
    if (Estado = 'AM') then  //Amazonas
    begin
        lRet:= length(strCGF) = 9;
        if (lRet)then
        Begin
            strDig := copy(strCGF, 9, 1);
            strCGF2 := copy(strCGF, 1, 8);

            intMult:=9;nSoma := 0;
            For nX := 1 To 8 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1 ;
              If intMult = 1 Then
                intMult := 9;
            end;

            if nSoma< 11 then
                 nDig := 11- nSoma
            else
            Begin
                 nDig :=  nSoma mod 11;
                 if nDig<=1 then
                   nDig := 0
                 else
                    nDig := 11-nDig;
            End;

            strDig2:= inttostr(nDig);
        End;
        if (strDig = strDig2) and (lRet) then
          lRet := True
        else
          lRet := False;
    end
    else
    if (Estado = 'BA') then //Bahia
    begin
        lRet:= length(strCGF) = 8;
        if (lRet)then
        Begin
            strDig := copy(strCGF, 7, 2);
            strCGF2 := copy(strCGF, 1, 6);

            if (pos(copy(strCGF2,1,1),'0,1,2,3,4,5,8,')>0) then
            Begin
                intMult:=7;nSoma := 0;
                For nX := 1 To 6 Do
                begin
                  nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
                  intMult := intMult - 1 ;
                end;


                nDig2 := nSoma mod 10;
                if (nDig2 <> 0)then
                     nDig2 := 10 - nDig2;

                strCGF2:=strCGF2+ inttostr(nDig2);
                intMult:=8;nSoma := 0;
                For nX := 1 To 7 Do
                begin
                  nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
                  intMult := intMult - 1 ;
                end;

                nDig := nSoma mod 10;
                if (nDig <> 0)then
                     nDig := 10 - nDig;

                strDig2:= IntToStr(nDig)+ IntToStr(nDig2);
            end
            else
            Begin
                intMult:=7;nSoma := 0;
                For nX := 1 To 6 Do
                begin
                  nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
                  intMult := intMult - 1 ;
                end;

                nDig2 := nSoma mod 11;
                If (nDig2 <> 0) and (nDig2 <> 1)then
                     nDig2 := 11 - nDig2
                Else
                     nDig2 :=0;

                strCGF2:=strCGF2+ inttostr(nDig2);
                intMult:=8;nSoma := 0;
                For nX := 1 To 7 Do
                begin
                  nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
                  intMult := intMult - 1 ;
                end;

                nDig := nSoma mod 11;
                If (nDig <> 0) And (nDig <> 1)then
                     nDig := 11 - nDig
                Else
                     nDig :=0;

                strDig2:= IntToStr(nDig)+ IntToStr(nDig2);
            end;
        End
        else
        begin
          lRet:= length(strCGF) = 9;
          if lRet then
            strDig:=strDig2;
        end;
        if (strDig = strDig2) and (lRet) then
          lRet := True
        else
          lRet := False;
    end
    else
    if (Estado = 'CE') then //Ceará
    begin
        lRet:= length(strCGF) = 9;
        if (lRet)then
        Begin
            strDig := copy(strCGF, 9, 1);
            strCGF2 := copy(strCGF, 1, 8);

            intMult:=9;nSoma := 0;
            For nX := 1 To 8 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1 ;
            end;
            nDig := nSoma mod 11;
            nDig := 11 - nDig;

            if nDig > 9 then
              nDig := 0;
            strDig2:= IntToStr(nDig);
        End;
        if (strDig = strDig2) and (lRet) then
          lRet := True
        else
          lRet := False;
    end
    else
    if (Estado = 'DF')then //Distrito Federal
    begin
        lRet:= length(strCGF) = 13;
        if (lRet)then
        Begin
            if (copy(strCGF, 1,2) <> '07') then
               lRet:=False;

            strDig := copy(strCGF,12,2);
            strCGF2 := copy(strCGF,1,11);

            intMult:=4;nSoma := 0;
            For nX := 1 To 11 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1 ;
              If intMult = 1 Then
                intMult := 9;
            end;
            nDig := nSoma mod 11;
            nDig := 11 - nDig;

            if nDig > 9 then
              nDig := 0;


            strCGF2:=strCGF2+inttostr(nDig);
            intMult:=5; nSoma:=0;
            For nX := 1 To 12 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1 ;
              If intMult = 1 Then
                intMult := 9;
            end;
            nDig2 := nSoma mod 11;
            nDig2 := 11 - nDig2;

            if nDig2 > 9 then
              nDig2 := 0;
           strDig2:= inttostr(nDig)+inttostr(nDig2);
        End;
        if (strDig = strDig2) and (lRet) then
          lRet := True
        else
          lRet := False;
    End
    else
    if (Estado = 'ES') then //Espírito Santo
    begin
        lRet:= length(strCGF) = 9;
        if (lRet)then
        Begin
            strDig := copy(strCGF, 9, 1);
            strCGF2 := copy(strCGF, 1, 8);

            intMult:=9;nSoma := 0;
            For nX := 1 To 8 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1 ;
            end;
            nDig := nSoma mod 11;
            if (nDig < 2) then
               nDig := 0
            else
               nDig := 11 - nDig;

            strDig2:= IntToStr(nDig);
        End;
        if (strDig = strDig2) and (lRet) then
          lRet := True
        else
          lRet := False;
    End
    else
    if (Estado = 'GO') then //Goiás
    begin
        lRet:= length(strCGF) = 9;
        if (lRet)then
        Begin
            if (pos(copy(strCGF, 1,2),'10,11,15')=0) then
               lRet:=False;

            strDig := copy(strCGF, 9, 1);
            strCGF2 := copy(strCGF, 1, 8);

            intMult:=9;nSoma := 0;
            For nX := 1 To 8 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1 ;
            end;
            nDig := nSoma mod 11;
            if (nDig = 0)then
                 nDig := 0
            else
              if (nDig = 1) and(strtoint(strCGF2)>=10103105)  and (strtoint(strCGF2)<= 10119997)Then
              Begin
                   if strDig <> '1' then
                      lRet:=False;
              End
              else
                   if (nDig = 1) then
                      nDig := 0
                   else
                      nDig := 11 - nDig;

            strDig2:= IntToStr(nDig);
        End;
        if (strDig = strDig2) and (lRet) then
          lRet := True
        else
          lRet := False;
    End
    else
    if (Estado = 'MA') then //Maranhão
    begin
        lRet:= length(strCGF) = 9;
        if (lRet)then
        Begin
            if (pos(copy(strCGF, 1,2),'12')=0) then
               lRet:=False;

            strDig := copy(strCGF, 9, 1);
            strCGF2 := copy(strCGF, 1, 8);

            intMult:=9;nSoma := 0;
            For nX := 1 To 8 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1 ;
            end;
            nDig := nSoma mod 11;
            if (nDig = 0) or (nDig = 1) then
               nDig :=0
            else
               nDig := 11 - nDig;

            strDig2:= IntToStr(nDig);
        End;
        if (strDig = strDig2) and (lRet) then
          lRet := True
        else
          lRet := False;
    End
    else
    if (Estado = 'MT') then //Mato Grosso
    begin
        strCGF := ZerosC(strCGF,11);
        lRet:= length(strCGF) = 11;
        if (lRet)then
        Begin
            strDig := copy(strCGF,11,1);
            strCGF2 := copy(strCGF,1,10);

            intMult:=3;nSoma := 0;
            For nX := 1 To 10 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1 ;
              If intMult = 1 Then
                intMult := 9;
            end;
            nDig := nSoma mod 11;
            if (nDig = 0) or (nDig = 1) then
               nDig :=0
            else
               nDig := 11 - nDig;

           strDig2:= inttostr(nDig);
        End;
        if (strDig = strDig2) and (lRet)then
          lRet := True
        else
          lRet := False;
    End
    else
    if (Estado = 'MS') then //Mato Grosso do Sul
    begin
        lRet:= length(strCGF) = 9;
        if (lRet)then
        Begin
            if (pos(copy(strCGF, 1,2),'28')=0) then
               lRet:=False;

            strDig := copy(strCGF,9,1);
            strCGF2 := copy(strCGF,1,8);

            intMult:=9;nSoma := 0;
            For nX := 1 To 8 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1 ;
            end;
            nDig := nSoma mod 11;
            if (nDig > 0) then
               nDig := 11 - nDig;
            if (nDig >9) then
               nDig :=0;

           strDig2:= inttostr(nDig);
        End;
        if (strDig = strDig2) and (lRet)then
          lRet := True
        else
          lRet := False;
    End
    else
    if (Estado = 'MG') then //Minas Gerais
    begin
        lRet:= length(strCGF) = 13;
        if (lRet)then
        Begin

            strDig := copy(strCGF,12,2);
            strCGF2 := copy(strCGF,1,3)+'0'+copy(strCGF,4,8);

            intMult:=1;nSoma := 0;
            For nX := 1 To 12 Do
            begin
              p:= (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              if p >9 then
                 nSoma := nSoma + StrToInt(Copy(inttostr(p),1,1))+StrToInt(Copy(inttostr(p),2,1))
              else
                 nSoma := nSoma + p;
              intMult := intMult + 1 ;
              If intMult = 3 Then
                intMult := 1;
            end;
            p:= nSoma;
            while (p mod 10 <> 0) do
               p:=p+1;
            nDig:=p-nSoma;

            strCGF2 := copy(strCGF,1,11)+inttostr(nDig);
            intMult:=3; nSoma:=0;
            For nX := 1 To 12 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1 ;
              If intMult = 1 Then
                intMult := 11;
            end;
            nDig2 := nSoma mod 11;
            if (nDig2 = 0) or (nDig2 = 1)then
               nDig2 := 0
            else
               nDig2 := 11 - nDig2;

           strDig2:= inttostr(nDig)+inttostr(nDig2);
        End;
        if (strDig = strDig2) and (lRet) then
          lRet := True
        else
          lRet := False;
    End
    else
    if (Estado = 'PA') then //Pará
    Begin
        lRet:= length(strCGF) = 9;
        if (lRet)then
        Begin
            if (pos(copy(strCGF, 1,2),'15')=0) then
               lRet:=False;

            strDig := copy(strCGF,9,1);
            strCGF2 := copy(strCGF,1,8);

            intMult:=9;nSoma := 0;
            For nX := 1 To 8 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1 ;
            end;
            nDig := nSoma mod 11;
            if (nDig = 0) or (nDig = 1)then
               nDig := 0
            else
               nDig := 11 - nDig;

           strDig2:= inttostr(nDig);
        End;
        if (strDig = strDig2) and (lRet)then
          lRet := True
        else
          lRet := False;
    End
    else
    if (Estado = 'PB') then //Paraíba
    begin
        lRet:= length(strCGF) = 9;
        if (lRet)then
        Begin
            strDig := copy(strCGF,9,1);
            strCGF2 := copy(strCGF,1,8);

            intMult:=9;nSoma := 0;
            For nX := 1 To 8 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1 ;
            end;
            nDig := nSoma mod 11;
            nDig := 11 - nDig;
            if (nDig >9) then
               nDig :=0;

           strDig2:= inttostr(nDig);
        End;
        if (strDig = strDig2) and (lRet)then
          lRet := True
        else
          lRet := False;
    End
    else
    if (Estado = 'PR') then //Paraná
    begin
        lRet:= length(strCGF) = 10;
        if (lRet)then
        Begin
            strDig := copy(strCGF,9,2);
            strCGF2 := copy(strCGF,1,8);

            intMult:=3;nSoma := 0;
            For nX := 1 To 8 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1 ;
              if (intMult = 1)then
                   intMult := 7;
            end;
            nDig := nSoma mod 11;
            nDig := 11 - nDig;
            if (nDig >9) then
               nDig :=0;

            strCGF2 := strCGF2+inttostr(nDig);
            intMult:=4;nSoma := 0;
            For nX := 1 To 9 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1 ;
              if (intMult = 1)then
                   intMult := 7;
            end;
            nDig2 := nSoma mod 11;
            nDig2 := 11 - nDig2;
            if (nDig2 >9) then
               nDig2 :=0;

           strDig2:= inttostr(nDig)+inttostr(nDig2);
        End;
        if (strDig = strDig2) and (lRet)then
          lRet := True
        else
          lRet := False;
    End
    Else
    if (Estado = 'PE') then //Pernambuco
    begin
        lRet:= length(strCGF) = 9;
        if (lRet)then
        Begin
            strDig := copy(strCGF,8,2);
            strCGF2 := copy(strCGF,1,7);

            intMult:=8;nSoma := 0;
            For nX := 1 To 7 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1 ;
            end;
            nDig := nSoma mod 11;
            if (nDig =0) or (nDig =1)then
               nDig :=0
            else
               nDig := 11 - nDig;

            strCGF2 := strCGF2+inttostr(nDig);
            intMult:=9;nSoma := 0;
            For nX := 1 To 8 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1 ;
            end;
            nDig2 := nSoma mod 11;
            if (nDig2 =0) or (nDig2 =1)then
               nDig2 :=0
            else
               nDig2 := 11 - nDig2;

           strDig2:= inttostr(nDig)+inttostr(nDig2);
        End;
        if (strDig = strDig2) and (lRet)then
          lRet := True
        else
          lRet := False;
    End
    Else
    if (Estado = 'PI') then //Piauí
    begin
        lRet:= length(strCGF) = 9;
        if (lRet)then
        Begin
            strDig := copy(strCGF,9,1);
            strCGF2 := copy(strCGF,1,8);

            intMult:=9;nSoma := 0;
            For nX := 1 To 8 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1 ;
            end;
            nDig := nSoma mod 11;
            nDig := 11 - nDig;
            if (nDig >9) then
               nDig :=0;

           strDig2:= inttostr(nDig);
        End;
        if (strDig = strDig2) and (lRet)then
          lRet := True
        else
          lRet := False;
    end
    else
    if (Estado = 'RJ') then //Rio de Janeiro
    begin
        lRet:= length(strCGF) = 8;
        if (lRet)then
        Begin
            strDig := copy(strCGF,8,1);
            strCGF2 := copy(strCGF,1,7);

            intMult:=2;nSoma := 0;
            For nX := 1 To 7 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1;
              if (intMult = 1)then
                   intMult := 7;
            end;
            nDig := nSoma mod 11;
            if (nDig <2) then
               nDig :=0
            else
               nDig := 11 - nDig;

            strDig2:= inttostr(nDig);
        End;
        if (strDig = strDig2) and (lRet)then
          lRet := True
        else
          lRet := False;
    End
    Else
    if Estado = 'RN' then  //Rio Grande do Norte
    Begin
        lRet:= ((length(strCGF) = 9)or (length(strCGF) = 10));
        if (pos(copy(strCGF, 1,2),'20')=0) then
           lRet:=False;
        if (lRet)then
        Begin
            if (length(strCGF) = 9) Then
            Begin
                strDig := copy(strCGF,9,1);
                strCGF2 := copy(strCGF,1,8);

                intMult:=9;nSoma := 0;
                For nX := 1 To 8 Do
                begin
                  nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
                  intMult := intMult - 1;
                end;
                nSoma:=nSoma*10;
                nDig := nSoma mod 11;
                if (nDig >9) then
                  nDig := 0;
                strDig2:= inttostr(nDig);
            End
            Else
            Begin
                strDig := copy(strCGF,10,1);
                strCGF2 := copy(strCGF,1,9);

                intMult:=10;nSoma := 0;
                For nX := 1 To 9 Do
                begin
                  nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
                  intMult := intMult - 1;
                end;
                nSoma:=nSoma*10;
                nDig := nSoma mod 11;
                if (nDig >9) then
                  nDig := 0;
                strDig2:= inttostr(nDig);
            End;
        End;
        if (strDig = strDig2) and (lRet)then
          lRet := True
        else
          lRet := False;
    End
    Else
    if Estado = 'RS' then  //Rio Grande do Sul
    Begin
        lRet:= length(strCGF) = 10;
        if (lRet)then
        Begin
            strDig := copy(strCGF,10,1);
            strCGF2 := copy(strCGF,1,9);

            intMult:=2;nSoma := 0;
            For nX := 1 To 9 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1;
              if (intMult = 1)then
                   intMult := 9;
            end;
            nDig := nSoma mod 11;
            nDig := 11 - nDig;
            if (nDig >9) then
               nDig :=0;

            strDig2:= inttostr(nDig);
        End;
        if (strDig = strDig2) and (lRet)then
          lRet := True
        else
          lRet := False;
    End
    Else
    if Estado = 'RO' then  //Rondônia
    Begin
        lRet:= ((length(strCGF) = 9)or (length(strCGF) = 14));
        if (lRet)then
        Begin
            if (length(strCGF) = 9) Then
            Begin
                strDig := copy(strCGF,9,1);
                strCGF2 := copy(strCGF,4,5);

                intMult:=6;nSoma := 0;
                For nX := 1 To 5 Do
                begin
                  nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
                  intMult := intMult - 1;
                end;
                nDig := nSoma mod 11;
                nDig := 11 - nDig;
                if (nDig >9) then
                  nDig := nDig-10;
                strDig2:= inttostr(nDig);
            End
            Else
            Begin
                strDig := copy(strCGF,14,1);
                strCGF2 := copy(strCGF,1,13);

                intMult:=6;nSoma := 0;
                For nX := 1 To 13 Do
                begin
                  nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
                  intMult := intMult - 1;
                  if (intMult = 1)then
                    intMult := 9;
                end;
                nDig := nSoma mod 11;
                nDig := 11 - nDig;
                if (nDig >9) then
                  nDig := nDig-10;
                strDig2:= inttostr(nDig);
            End;
        End;
        if (strDig = strDig2) and (lRet)then
          lRet := True
        else
          lRet := False;
    End
    Else
    if Estado = 'RR' then  //Roraima
    Begin
        lRet:= length(strCGF) = 9;
        if (pos(copy(strCGF, 1,2),'24')=0) then
           lRet:=False;
        if (lRet)then
        Begin
            strDig := copy(strCGF, 9, 1);
            strCGF2 := copy(strCGF, 1, 8);

            intMult:=1;nSoma := 0;
            For nX := 1 To 8 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult + 1 ;
            end;
            nDig := nSoma mod 9;

            strDig2:= IntToStr(nDig);
        End;
        if (strDig = strDig2) and (lRet) then
          lRet := True
        else
          lRet := False;
    End
    Else
    if Estado = 'SC' then  //Santa Catarina
    Begin
        lRet:= length(strCGF) = 9;
        if (lRet)then
        Begin
            strDig := copy(strCGF, 9, 1);
            strCGF2 := copy(strCGF, 1, 8);

            intMult:=9;nSoma := 0;
            For nX := 1 To 8 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1 ;
            end;
            nDig := nSoma mod 11;
            if (nDig =0) or (nDig =1)then
               nDig := 0
            else
               nDig := 11 - nDig;

            strDig2:= IntToStr(nDig);
        End;
        if (strDig = strDig2) and (lRet) then
          lRet := True
        else
          lRet := False;
    End
    Else
    if Estado = 'SP' then  //São Paulo
    Begin
        lRet:= length(strCGF) = 12;
        if (lRet)then
        Begin
            strDig := copy(strCGF,9,1)+copy(strCGF,12,1);
            strCGF2 := copy(strCGF,1,8);

            intMult:=1;nSoma := 0;
            For nX := 1 To 8 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult + 1 ;
              if (intMult = 2)or (intMult = 9)then
                   intMult := intMult + 1 ;
            end;
            nDig := nSoma mod 11;
            if (nDig >9) then
               nDig :=StrToInt(Copy(inttostr(nDig),2,1));

            strCGF2 := copy(strCGF,1,11);
            intMult:=3;nSoma := 0;
            For nX := 1 To 11 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1 ;
              if (intMult = 1)then
                   intMult := 10 ;
            end;
            nDig2 := nSoma mod 11;
            if (nDig2 >9) then
               nDig2 :=StrToInt(Copy(inttostr(nDig2),2,1));


           strDig2:= inttostr(nDig)+inttostr(nDig2);
        End;
        if (strDig = strDig2) and (lRet)then
          lRet := True
        else
          lRet := False;
    end
    Else
    if Estado = 'SE' then  //Sergipe
    Begin
        lRet:= length(strCGF) = 9;
        if (lRet)then
        Begin
            strDig := copy(strCGF, 9, 1);
            strCGF2 := copy(strCGF, 1, 8);

            intMult:=9;nSoma := 0;
            For nX := 1 To 8 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1 ;
            end;
            nDig := nSoma mod 11;
            nDig := 11 - nDig;
            if (nDig>9) then
               nDig := 0;

            strDig2:= IntToStr(nDig);
        End;
        if (strDig = strDig2) and (lRet) then
          lRet := True
        else
          lRet := False;
    End
    Else
    if Estado = 'TO' then  //Tocantins
    Begin
        {lRet:= length(strCGF) = 11;
        //if (pos(copy(strCGF, 3,2),'01,02,03,99')=0) then
        //   lRet:=False;
        if (lRet)then
        Begin
            strDig := copy(strCGF, 11, 1);
            strCGF2 := copy(strCGF,1,2)+copy(strCGF,5,6);

            intMult:=9;nSoma := 0;
            For nX := 1 To 8 Do
            begin
              nSoma := nSoma + (StrToInt(Copy(strCGF2,nX,1)) * intMult);
              intMult := intMult - 1 ;
            end;
            nDig := nSoma mod 11;
            if (nDig<2) then
               nDig := 0
            else
               nDig := 11 - nDig;

            strDig2:= IntToStr(nDig);
        End;
        if (strDig = strDig2) and (lRet) then
          lRet := True
        else
          lRet := False;}
          lRet := True
    End
    Else
    if Estado = '' then
        lRet := True
    Else
        lRet := False;
  VerificaCgf := lRet;
end;

function Valor_CGF(CgfP: string): string;
var strCGF: string;
  i: Integer;
  fltCGF: double;
begin
  strCGF := '';
  // Verifica se tem '-' ou '.' e retira
  for i := 1 to Length(CgfP) do
    if (Copy(CgfP, i, 1) <> '-') and (Copy(CgfP, i, 1) <> '.') then
      strCGF := strCGF + Copy(CgfP, i, 1);
  fltCGF := StrToFloat(strCGF);
  CgfP := floattostr(fltCGF);
  // Atribui zeros á esquerda
  if Length(CgfP) < 9 then
    begin
      for i := Length(CgfP) + 1 to 9 do
        CgfP := '0' + CgfP;
    end;
  // Coloca '.' e '-' no s locais corretos
  Valor_CGF := Copy(CgfP, 1, 2) + '.' + Copy(CgfP, 3, 3) + '.' + Copy(CgfP, 6, 3) + '-' + Copy(CgfP, 9, 1);
end;

function LimpaNumero(s: string): real;
var i: byte;
  fltRet: real;
  strRet: string;
begin
  strRet := '';
  for i := 1 to length(s) do
    if s[i] in ['0'..'9', ','] then
      strRet := strRet + s[i];

  if strRet = '' then
    strRet := '0';

  try
    fltRet := StrToFloat(strRet)
  except
    fltRet := 0
  end;
  LimpaNumero := fltRet;
end;

function EstaNoArray(varValor: string; arrProcura: array of string): boolean;
var intI: integer;
  blnRet: boolean;
begin
  intI := 0;
  blnRet := False;
  while (intI <= High(arrProcura)) and (not blnRet) do
    begin
      if arrProcura[intI] = varValor then
        blnRet := True;
      inc(intI);
    end;
  EstaNoArray := blnRet;
end;

//Remover espaços em branco duplicados em uma cadeia,
//fazendo com que a separação entre suas partes seja
//feita somente por UM espaço em branco

function MidTrim(s: string): string;
var strResp: string;
  intX: integer;
begin
  s := trim(s);
  strResp := '';
  intX := 1;
  while intX <= Length(s) do
    begin
      strResp := strResp + s[intX];
      repeat
        inc(intX);
      until s[intX] <> ' ';
      if s[intX - 1] = ' ' then
        begin
          dec(intX);
          strResp := strResp + s[intX];
          inc(intX);
        end;
    end;
  MidTrim := strResp;
end;

function DataSql(dtData: TDateTime): string;
begin
  DataSql := QuotedStr(FormatDateTime('mm/dd/yyyy hh:mm:ss', dtData));
end;

//Validar uma string do tipo mm/aaaa
//Pode vir com ou sem barra

function ValidaMes(strMes: string): boolean;
var strResp: string;
  intI: byte;
  dtData: TDateTime;
  blnRet: boolean;
begin
  strResp := '';
  for intI := 1 to length(strMes) do
    if strMes[intI] in ['0'..'9'] then
      strResp := strResp + strMes[intI];
  blnRet := True;
  strResp := '01/' + Copy(strResp, 1, 2) + '/' + Copy(strResp, 3, 4);
  try
    dtData := StrToDate(strResp);
  except
    blnRet := False;
  end;
  ValidaMes := blnRet;
end;

function PontoVirg(s: string): string;
begin
  troca(s, ',', '.', false);
  PontoVirg := s;
end;

function FormataPlaca(s: string): string;
begin
  FormataPlaca := Copy(s, 1, 3) + '-' + Copy(s, 4, 4)
end;


end.

