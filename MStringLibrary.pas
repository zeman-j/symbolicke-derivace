unit MStringLibrary;
{modul obsahuje typy morf�m a �et�zec morf�m� (MString) a funkce pro pr�ci
s nimi k vyu�it� v programu Derivace}

interface
type tMorfem = String[8];
     MString = array[0..255] of tMorfem; {do [0][0] se bude ukl�dat d�lka MStringu}

function MLength(m: MString): Byte;
procedure append(var m: MString; s: tMorfem);
function MCopy(m: MString; start: Byte; pocet: Byte): MString;
function StrToMString(s:String): MString;
function MStringToStr(m: MString): String;
function isWord(s: String): Boolean;
function isNumber(s: String): Boolean;
function MStringIsLog(m: MString): Boolean;

implementation

function MLength(m: MString):Byte;
{funkce vrac� d�lku MStringu m}
var  delka: Byte;
begin
  delka := Ord(m[0][0]);
  MLength := delka;
end; {function MLength()}

procedure append(var m: MString; s: tMorfem);
{p�id� nov� morf�m s na konec MStringu m, zv�t� d�lku m o 1}
begin
   m[MLength(m) + 1] := s;
   m[0][0] := Chr(Ord(m[0][0]) + 1);
end; {procedure append()}

function MCopy(m: MString; start: Byte; pocet: Byte): MString;
{zkop�ruje z MStringu m od pozice <start> <pocet> morf�m�}
var n: MString; {n�vratov� hodnota}
    i: Integer;
begin
    n[1] := '';
    n[0][0] := Chr(0);
  for i := start to start + pocet - 1 do begin
        n[i - start + 1] := m[i];
        n[0][0] := Chr(i - start + 1);
    end;
    MCopy := n;
end; {function MCopy()}

function StrToMString(s:String): MString;
{rozlo�� String s na morf�my a vr�t� je jako v�raz typu MString}
{s del� ne� 248 m��e skon�it range check error vzhledem k pou�it� funkce Copy()}
var j, k: Word;
    m: MString; {n�vratov� hodnota t�to funkce}
    morfem: tMorfem;
    nalezenaTecka: boolean; {intern� prom�nn� pro v�tev 0..9}
begin
    s := UpCase(s); {nen� nutn� rozli�ovat velikost p�smen}
    m[0][0] := Chr(0); {d�lku MStringu nastavit na 0}
    j:=1;
    {proch�zet �et�zec s po znac�ch}
  while j <= Length(s) do begin
        morfem := s[j]; {morfem bude morf�m konstruovan� v j-t�m kroku}
        if s[j] in ['0'..'9'] then {na��tat znaky do prom�nn� morf�m, dokud jsou to ��slice} begin
                     k := j + 1;
                     nalezenaTecka := FALSE;
                     while (s[k] in ['0'..'9', '.']) and not nalezenaTecka do begin
                           morfem := morfem + s[k];
                           if s[k] = '.' then nalezenaTecka := TRUE; {nalezena te�ka}
                           k := k + 1;
                     end;
                     {pokud byla nalezenaTe�ka, ��slo m� i desetinnou ��st, tu
                     je t�eba tak� na��st}
                     if nalezenaTecka then while s[k] in ['0'..'9'] do begin
                            morfem := morfem + s[k];
                            k := k + 1;
                     end;
                     j := k; {posunout iter�tor}
                    end
        else if (s[j] = 'X') and (s[j+1] = '^') and (s[j+2] in ['0'..'9']) then begin
                   {X^��slo}
                    morfem := morfem + s[j+1] + s[j+2];
                    k:=j+3;
                    nalezenaTecka := FALSE;
                    while (s[k] in ['0'..'9', '.']) and not nalezenaTecka do begin
                           morfem := morfem + s[k];
                           if s[k] = '.' then nalezenaTecka := TRUE; {nalezena te�ka}
                           k := k + 1;
                     end;
                     {pokud byla nalezenaTe�ka, ��slo m� i desetinnou ��st, tu
                     je t�eba tak� na��st}
                     if nalezenaTecka then while s[k] in ['0'..'9'] do begin
                            morfem := morfem + s[k];
                            k := k + 1;
                     end;
                     j := k;
                    end
        else if (s[j] = 'X') and (s[j+1] = '^') and (s[j+2] = '-') and (s[j+3] in ['0'..'9']) then begin
                   {X na z�porn� exponent}
                    morfem := morfem + s[j+1] + s[j+2] + s[j+3];
                    k:=j+4;
                    nalezenaTecka := FALSE;
                    while (s[k] in ['0'..'9', '.']) and not nalezenaTecka do begin
                           morfem := morfem + s[k];
                           if s[k] = '.' then nalezenaTecka := TRUE; {nalezena te�ka}
                           k := k + 1;
                     end;
                     {pokud byla nalezenaTe�ka, ��slo m� i desetinnou ��st, tu
                     je t�eba tak� na��st}
                     if nalezenaTecka then while s[k] in ['0'..'9'] do begin
                            morfem := morfem + s[k];
                            k := k + 1;
                     end;
                     j := k;
                    end
        else if (Copy(s, j, 4) = 'SIN(') or (Copy(s, j, 4) = 'COS(') or (Copy(s, j, 4) = 'LOG(') then begin
            morfem := Copy(s, j, 4);
            j := j + 4;
            end
        else if (Copy(s, j, 3) = 'LN(') or (Copy(s, j, 3) = 'TG(') then begin
            morfem := Copy(s, j, 3);
            j := j + 3;
            end
        else if Copy(s, j, 5) = 'COTG(' then begin
            morfem := Copy(s, j, 5);
            j := j + 5;
            end
        else if copy(s, j, 6) = 'ARCTG(' then begin
            morfem := Copy(s, j, 6);
            j := j + 6;
            end
        else if (Copy(s, j, 7) = 'ARCSIN(') or (Copy(s, j, 7) = 'ARCCOS(') then begin
            morfem := Copy(s, j, 7);
            j := j + 7;
            end
        else if Copy(s, j, 8) = 'ARCCOTG(' then begin
            morfem := Copy(s, j, 8);
            j := j + 8;
            end
        else if Copy(s, j, 2) = ', ' then begin {��rka odd�luje argumenty logaritmu, odebrat mezeru}
            morfem := ',';
            j := j + 2;
        end
        else if s[j] in ['A'..'Z'] then begin
            {�et�zec d�lky nejv��e 8 pova�ovat za konstantu}
            k := j + 1;
            {p�id�vat p�smena m� smysl, jen pokud s[j] nen� poslen� znak �et�zce}
            while (k <= Length(s)) and (s[k] in ['A'..'Z']) and (k-j < 8) do begin
                   morfem := morfem + s[k];
                   k := k + 1;
                end;
            j := k;
        end
        else j := j + 1;
        append(m, morfem);
  end;
  StrToMString := m;
end; {function StrToMString()}

function MStringToStr(m: MString): String;
{funkce z�et�z� MString m v jednu prom�nnou typu String}
   var s: String;
       i: Integer;
begin
    s := '';
    for i := 1 to MLength(m) do
    s := s + m[i];
    MStringToStr := s;
end; {function MString()}

function isWord(s: String): Boolean;
  {vrac� true, jestli�e �et�zec s obsahuje jen p�smena a ��dn� jin� znaky}
  {x se nepova�uje za slovo, proto�e jde o nez�visle prom�nnou, podle kter�
  se derivuje. Je nutn�, aby derivace x^x nevych�zela x*x^(x-1)}
  var i: Integer;
begin
   s := UpCase(s);
   if (s = 'X') or (s = '') then isWord := FALSE
   else if s[1] = '-' then isWord := isWord(Copy(s, 2, Length(s)-1)) {z�porn� konstanta}
   else begin
      isWord := TRUE;
      for i := 1 to Length(s) do
         if not (s[i] in ['A'..'Z']) then begin
            isWord := FALSE;
            break;
         end;
      end;
end; {function isWord()}

function isNumber(s: String): Boolean;
     {vrac� true, jestli�e �et�zec obsahuje ��sla a mezi nimi max. 1 desetinnou te�ku}
  var i: Integer;
    nalezenaTecka: Boolean;
begin
    if (s = '') or (s[1] = '.') then isNumber := FALSE
    else if s[1] = '-' then isNumber := isNumber(Copy(s, 2, Length(s)-1))
    else begin
       nalezenaTecka := FALSE;
       isNumber := TRUE;
       i := 1;
       while (i <= Length(s)) and (not nalezenaTecka) do begin
            if not (s[i] in ['0'..'9', '.']) then begin
               isNumber := FALSE;
               exit;
            end;
            if s[i] = '.' then nalezenaTecka := TRUE;
            i := i + 1;
       end;
       if nalezenaTecka then while i <=  Length(s) do begin
           if not (s[i] in ['0'..'9']) then begin
                      isNumber := FALSE;
                      break;
                   end;
                   i := i + 1;
       end;
    end;
end; {function isNumber()}

function MStringIsLog(m: MString): Boolean;
{vr�t� TRUE, pokud m� MString m tvar log(<��seln� v�raz>,x)}
var indexCarky, i: Byte;
    errCode: Integer;
    zaklad: Real; {z�klad logaritmu}
    zakladStr: String;        {z�klad logaritmu, ale ve Stringu}
begin
  MStringIsLog := FALSE;
  if MLength(m) >= 5 then
  if (m[1] = 'LOG(') and (m[MLength(m)] = ')') and (m[MLength(m) - 1] = 'X') then begin
       zakladStr := '';
       indexCarky := 0;
       i := 1;
       while (i < MLength(m)) and not (m[i] = ',') do begin
        {hledat ��rku a ulo�it jej� pozici do indexCarky}
        i := i + 1;
        if m[i] = ',' then begin
                indexCarky := i;
                break;
          end;
        if i >= MLength(m) then break;
        zakladStr := zakladStr + m[i]; {v�echno mezi LOG( a ��rkou pova�ovat za z�klad logaritmu}
        end;
        Val(zakladStr, zaklad, errCode); {nebo by se tu volala funkce vyhodnocuj�c� aritm. v�raz}
       if (errCode = 0) and (m[indexCarky+1] + m[indexCarky+2] = 'X)') then
            MStringIsLog := TRUE;
     end;
end; {function MStringIsLog()}

begin

end.
