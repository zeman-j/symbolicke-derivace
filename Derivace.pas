program Derivace;
{program Symbolick� derivace, derivuje v�raz na standardn�m vstupu a vyp��e
v�sledek}
{Ji�� Zeman, 1. ro�., kruh 53}
{zimn� semestr 2014/15}
{Programov�n� 1 NMIN101}

uses MStringLibrary;

var vstup: String;
    vyraz: MString;
    i: Integer;
    jeCoOdstranovat: Boolean; {p��znak toho, �e v�raz obsahuje p�ebyte�n� z�vorky}

procedure Chyba;
{procedura by mohla p�eb�rat parametr typu String s popisem chyby}
begin
  writeLn('Chyba');
  halt;
end;  {procedure Chyba}

function DerivujVnejsi(v: MString): MString;
{vstupem je funkce tvaru f(v�raz), v�stupem derivace f podle v�razu}
var u, vStr: String; {u..."uvnit�", v�raz, podle kter�ho se derivuje,
                     vStr...parametr v p�eveden� na String}
    zaklad: String; {p��padn� z�klad logaritmu}
    dnf: Byte; {d�lka n�zvu funkce i se z�vorkou ( }
    i: Integer;
begin
    {v�tven� podle druhu vn�j� funkce}
  dnf := Length(v[1]);
  vStr := MStringToStr(v);
  u := Copy(vStr, dnf + 1, Length(vStr) - dnf);
  if v[1] = 'LN(' then vStr := '1/('+ u {vStr se z�rove� vyu�ije jako n�vratov� hodnota}
  else if v[1] = 'SIN(' then vStr := 'cos(' + u
  else if v[1] = 'COS(' then vStr := '-sin(' + u
  else if v[1] = 'TG(' then vStr := '1/(sin(' + u + ')^2'
  else if v[1] = 'COTG(' then vStr := '-1/(cos(' + u + ')^2'
  else if v[1] = 'ARCSIN(' then vStr := '1/(1-(' + u + '^2)^(1/2)'
  else if v[1] = 'ARCCOS(' then vStr := '-1/(1-(' + u + '^2)^(1/2)'
  else if v[1] = 'ARCTG(' then vStr := '1/(1+(' + u + '^2)'
  else if v[1] = 'ARCCOTG(' then vStr := '-1/(1+(' + u + '^2)'
  else if v[1] = 'LOG(' then begin
               i := 2;
               zaklad := '';
               vStr := '';
               while (i < MLength(v)) and (v[i] <> ',') do begin
                    {na��st z�klad logaritmu}
                   zaklad := zaklad + v[i];
                   i := i + 1;
                   end;
               i := i + 1;
               while (i < MLength(v)) do begin
                    {na��st argument logaritmu}
                    vStr := vStr + v[i];
                    i := i + 1;
                   end;
               vStr := '1/((' + vStr + ')*ln(' + zaklad + '))';
            end
  else ;
  DerivujVnejsi := StrToMString(vStr);
end; {function DerivujVnejsi()}

function Derivuj(v: MString): MString;
   var s, d: String;
        errCode: Integer;
        koeficient: Real;
        strKoeficient: String;
        poslPlus: Byte; {index posledn�ho + nebo - mimo z�vorky}
        poslKrat: Byte; {index posledn�ho * nebo / mimo z�vorky}
        poslStriska: Byte; {index posledn� ^ mimo z�vorky}
        ploz: Byte; {Po�et Lev�ch Otev�en�ch Z�vorek, otev�en�ch ve smyslu
                        nesp�rovan�ch}
        lCast, pCast: MString; {��st nalevo, napravo od znam�nka}
        dLCast, dPCast: MString; {derivace ��st� nalevo, napravo od znam�nka}
        i: Integer;
begin
  {kontrola  t e r m i n � l n � h o  s t a v u}
  s := MStringToStr(v); {derivovan� v�raz ulo�it do s}
  d := '';
  if s = 'X' then d := '1'
  else if s = 'E^X' then d := 'e^x'
  else if s = 'LN(X)' then d := '1/x'
  else if s = 'SIN(X)' then d := 'cos(x)'
  else if s = 'COS(X)' then d := '-sin(x)'
  else if s = 'TG(X)' then d := '1/(sin(x))^2'
  else if s = 'COTG(X)' then d := '-1/(cos(x))^2'
  else if s = 'ARCSIN(X)' then d := '1/(1-x^2)^(1/2)'
  else if s = 'ARCCOS(X)' then d := '-1/(1-x^2)^(1/2)'
  else if s = 'ARCTG(X)' then d := '1/(1+x^2)'
  else if s = 'ARCCOTG(X)' then d:= '-1/(1+x^2)'
  else if isWord(s) or isNumber(s) then d := '0' {�et�zec p�smen pova�ovat za konstantu}
  else if (MLength(v) = 1) and (Copy(v[1], 1, 1) = 'X') and (Copy(v[1], 2, 1) = '^') and isNumber(Copy(v[1], 3, Length(v[1]) - 2)) then begin
       {X^��slo}  Val(Copy(v[1], 3, Length(v[1]) - 2), koeficient, errCode);
         Str(koeficient - 1:1:2, strKoeficient);
         Str(koeficient:1:2, d);
         d := '(' + d + '*X^(' + strKoeficient + '))';
        end
  else if (MLength(v) = 3) and (v[1] = 'X') and (v[2] = '^') and isWord(v[3]) then
      {X^konstanta}   d := v[3] + '*X^(' + v[3] + '-1)'
  else if MStringIsLog(v) then begin
      {log o 'nep�irozen�m' z�kladu}
            i := 2;
            while not (v[i] = ',') do begin
                d := d + v[i];
                i := i + 1;
            end;
            Val(d, koeficient, errCode); {vyu�iji prom�nnou koeficient pro ulo�en� z�kladu logaritmu}
            Str(koeficient:1:2, strKoeficient);
            d := '1/(x*ln(' + strKoeficient + '))';
        end
  else begin {termin�ln� stav nenastal,  tak�e r e k u r z i v n � derivovat po ��stech}
       ploz := 0;
       poslPlus := 0;
       poslKrat := 0;
       poslStriska := 0;
       for i := 1 to MLength(v) do begin
          if Copy(v[i], Length(v[i]), 1) = '('  then ploz := ploz + 1 {nap�. pokud v[i] je '(' nebo 'sin('}
          else if v[i] = ')' then begin
            if ploz > 0 then
                ploz := ploz - 1
            else Chyba; {nesp�rovan� z�vorky}
                end
          else if ((v[i] = '+') or (v[i] = '-')) and (ploz = 0) then poslPlus := i
          else if ((v[i] = '*') or (v[i] = '/')) and (ploz = 0) then poslKrat := i
          else if (v[i] = '^') and (ploz = 0) then poslStriska := i;
       end;
       if poslPlus > 0 then begin  {derivace sou�tu}
                        lCast := MCopy(v, 1, poslPlus-1);
                        PCast := MCopy(v, poslPlus + 1, MLength(v) - poslPlus);
                        lCast := Derivuj(lCast);
                        PCast := Derivuj(pCast);
                        if MLength(pCast) > 0 then begin
                           append(lCast, v[poslPlus]);
                           if v[poslPlus] = '+' then d := MStringToStr(lCast) + MStringToStr(pCast)
                           else {vlo�it v�raz za '-' do z�vorek} d := MStringToStr(lCast) + '(' + MStringToStr(pCast) + ')';
                          end
                        else Chyba; {prav� s��tanec nesm� b�t pr�zdn�}
                         end
       else if poslKrat > 0 then begin  {derivace sou�inu}
             lCast := MCopy(v, 1, poslKrat-1);
             PCast := MCopy(v, poslKrat + 1, MLength(v) - poslKrat);
             if v[poslKrat] = '*' then begin
                if isNumber(MStringToStr(lCast)) or isWord(MStringToStr(lCast)) then begin {n�soben� konstantou}
                     d := '(' + MStringToStr(lCast) + '*' + MStringToStr(Derivuj(pCast)) + ')';
                end
                else begin
                    dLCast := Derivuj(lCast);
                    dPCast := Derivuj(pCast);
                    if (MLength(dLCast) > 0) and (MLength(dPCast) > 0) then
                        d := '(' + MStringToStr(dLCast) + ')*' + '(' + MStringToStr(pCast) + ')+(' + MStringToStr(lCast) + ')*(' + MStringToStr(dPCast) + ')'
                    else Chyba; {�initel� nesm� b�t pr�zdn�}
                 end;
                end
             else {v[poslKrat] = '/'} begin
                    dLCast := Derivuj(lCast);
                    dPCast := Derivuj(pCast);
                    if (MLength(dLCast) > 0) and (MLength(dPCast) > 0) then
                        d := '((' + MStringToStr(dLCast) + ')*(' + MStringToStr(pCast) + ')-((' + MStringToStr(lCast) + ')*(' + MStringToStr(dPCast) + ')))/(' + MStringToStr(pCast) + ')^2'
                    else Chyba; {d�lenec ani d�litel nesm� b�t pr�zdn�}
                         end;
                        end
       else if poslStriska > 0 then begin {derivace mocniny}
             lCast := MCopy(v, 1, poslStriska-1);
             PCast := MCopy(v, poslStriska + 1, MLength(v) - poslStriska);
             if MStringToStr(lCast) = 'E' then {e^v�raz} begin
                        dPCast := Derivuj(pCast);
                        if MLength(dPCast) > 0 then
                         d := s + '*(' + MStringToStr(dPCast) + ')'
                        else Chyba; {exponent nesm� b�t pr�zdn�}
                    end
             else {jinak p�ev�st na e^v�raz a rekurzivn� zavolat sebe sama}begin
                if (MLength(lCast)>0) and (MLength(pCast) > 0) then begin
                    d := 'E^(' + MStringToStr(pCast) + '*LN(' + MStringToStr(lCast) + '))';
                    v := StrToMString(d);
                    d := MStringToStr(Derivuj(v));
                                    end
                else Chyba; {z�klad mocniny i exponent mus� b�t nepr�zdn� MString}
                                end;
                        end
       else if (Length(v[1]) > 1) and (Copy(v[1], Length(v[1]), 1) = '(') and (v[MLength(v)] = ')') then begin
               { derivace slo�en� funkce }
               if v[1] <> 'LOG(' then begin
                 pCast := MCopy(v, 2, MLength(v)-2); {do pCast ulo�it argument funkce}
                 dPCast := Derivuj(pCast);
                 if MLength(dPCast) > 0 then
                     d := MStringToStr(DerivujVnejsi(v)) + '*(' + MStringToStr(dPCast) + ')'
                 else Chyba; {argument derivovan� funkce nesm� b�t pr�zdn�}
                end
               else begin
                    i  := 2;
                    while (i < MLength(v)) and (v[i] <> ',') do
                     i := i + 1;
                     i := i + 1;  {nastavit i na pozici za ','}
                     {na��st argument logaritmu, vyu�iji prom�nnou pCast}
                     pCast[0][0] := Chr(0); {nastavit d�lku}
                     while (i < MLength(v)) do begin
                          append(pCast, v[i]);
                          i := i + 1;
                         end;
                         dPCast := Derivuj(pCast);
                         if MLength(dPCast) > 0 then
                            d := MStringToStr(DerivujVnejsi(v)) + '*(' + MStringToStr(dPCast) + ')'
                         else Chyba; {argument logaritmu nesm� b�t pr�zdn�}
                    end;
            end
       else if (v[1] = '(') and (v[MLength(v)] = ')') then begin {odstranit p�ebyte�n� vn�j� z�vorky}
                   v := Derivuj(MCopy(v, 2, MLength(v)-2));
                   d := MStringToStr(v);
            end
       else if MLength(v) = 0 then d := ''
       else Chyba; {jinak u� se jedn� o nepodporovan� v�raz}
    end;
  Derivuj := StrToMString(d);
end; {function Derivuj}

function Zjednodus(w: MString): MString;
{funkce v dan�m v�razu w nahrad� v�echna x^1 pouh�m x, odstran� nuly za des. te�kami
a v�echna +- zam�n� za -}
{funkce by mohla b�t mocn�j�, ale d�lkou by pak vydala na samostatn� program}
var zW: MString; {zjednodu�en� w, n�vratov� hodnota}
    i, j: Word;
begin
   i:=1;
   zW[0][0] := Chr(0);
   while i <= MLength(w) do begin
      j := MLength(zW);
      if (w[i] = 'X^1') or (w[i] = 'X^1.00') then begin
         zW[j+1] := 'X';
         zW[0][0] := Chr(j+1);
         i := i + 1;
       end
      else if (isNumber(w[i]) and (Copy(w[i], Length(w[i]) - 2, 3) = '.00')) or ((Copy(w[i], 1, 2) = 'X^') and (Copy(w[i], Length(w[i]) - 2, 3) = '.00')) then begin
         zW[j+1] := Copy(w[i], 1, Length(w[i]) - 3);
         zW[0][0] := Chr(j+1);
         i := i + 1;
       end
      else if (w[i] = '+') and (i < MLength(w)) then
         if w[i+1] = '-' then begin
               zW[j+1] := '-';
               zW[0][0] := Chr(j+1);
               i := i + 2;
            end
         else begin
               zW[j+1] := w[i];
               zW[0][0] := Chr(j+1);
               i := i + 1;
            end
      else begin
           zW[j+1] := w[i];
           zW[0][0] := Chr(j+1);
           i := i + 1;
       end;
    end;
   Zjednodus := zW;
end; {function Zjednodus()}

function OdstrZbytZav(w: MString; var provedenaZmena: Boolean): MString;
{z MStringu odstran� zbyte�n� z�vorky (z�vorky okolo d�le ned�liteln�ch v�raz�,
dvojit� z�vorky)}
{do provedenaZmena  se ukl�d� informace o tom, zda bylo pot�eba n�kde odstranit z�vorky}
var zWStr: String;
    i, k: Word;
    iPZ: Word; {index prav� z�vorky vzhledem k t� na pozici i}
    iPZF: Word; {index prav� z�vorky funkce, pokud je n�jak� funkce uzav�ena t�sn�
            mezi z�vorkami na pozic�ch i a iPZ v r�mci w, za funkci se v tomto
            p��pad� pova�uje i v�raz v z�vork�ch => umo�n� odstran�n� dvojit�ch z�vorek}
    ploz: Byte; {po�et lev�ch otev�en�ch z�vorek}
begin
   i:=1;
   zWStr := '';
   provedenaZmena := FALSE;
   while i <= MLength(w) do begin
      if w[i] = '(' then begin
         {naj�t pravou z�vorku, kter� pat�� ke ( na pozici i ve w}
           k := i + 1;
           ploz := 1;
           if Copy(w[i+1], Length(w[i+1]), 1) = '(' then begin
                iPZF := i; {signalizovat, �e se bude hledat taky prav� z�vorka k v�razu mezi i a iPZ}
                ploz := 2;
                k := k + 1;
            end
           else iPZF := 0;
           while k <= MLength(w) do begin
               if (w[k] = '(') or (Copy(w[k], Length(w[k]), 1) = '(') then ploz := ploz + 1
               else if w[k] = ')'then ploz := ploz - 1;
               if (ploz = 1) and (iPZF = i) then iPZF := k; {nalezena prav� z�vorka k funkci mezi i a iPZ, ploz kleslo na 1}
               if ploz = 0 then begin
                    iPZ := k; {byl nalezen index prav� z�vorky vzhledem k t� na pozici i}
                    break;
                 end;
               k := k + 1;
            end;
           if iPZ = i + 2 then {v z�vork�ch je jedin� morf�m} begin
                if (Copy(w[i+1], 1, 1) <> '-') and (isNumber(w[i+1]) or isWord(w[i+1])) then begin
                       zWStr := zWStr + w[i+1];
                       i := i + 3; {posunu index za z�vorku}
                       provedenaZmena := TRUE;
                    end
                else if Copy(w[i+1], 1, 1) = 'X' then begin
                      zWStr := zWStr + w[i+1];
                      i := i + 3; {posunu index za z�vorku}
                      provedenaZmena := TRUE;
                    end
                else begin
                      zWStr := zWStr + w[i];
                      i := i + 1;
                    end;
            end
            else {mezi z�vorkami i a iPZ je v�ce morf�m�} begin
                if (iPZ = i + 4) and (w[i+1] = 'X') and (w[i+2] = '^') and isWord(w[i+3]) and (w[i+5] <> '^') then begin
                      zWStr := zWStr + 'X^' + w[i+3];
                      i := i + 5;
                      provedenaZmena := TRUE;
                    end
                else if (iPZF > i) and (iPZF = iPZ -1) then begin
                      {z�vorkami na pozic�ch i a iPZ je obalena funkce nebo v�raz v z�vork�ch,
                      jeden p�r z�vorek nav�c se tak jev� zbyte�n�m a odstran� se}
                      zWStr := zWStr + MStringToStr(MCopy(w, i+1, iPZ - i - 1));
                      i := iPZ + 1; {posunu index za z�vorku}
                      provedenaZmena := TRUE;
                    end
                else begin
                    zWStr := zWStr + w[i];
                    i := i + 1;
                 end;
                end;
        end
      else begin {jinak w[i] nen� z�vorka a jen to p�ihod�m do zWStr}
           zWStr := zWStr + w[i];
           i := i + 1;
       end;
    end;
    OdstrZbytZav := StrToMString(zWStr);
end; {function OdstrZbytZav()}

begin
 readLn(vstup);
 vyraz := StrToMString(vstup);
 vyraz := Derivuj(vyraz);
 repeat
  vyraz := OdstrZbytZav(vyraz, jeCoOdstranovat);
  until not jeCoOdstranovat;
 vyraz := Zjednodus(vyraz);
 for i:=1 to MLength(vyraz) do
    write(lowerCase(vyraz[i]));
    writeLn;
end.