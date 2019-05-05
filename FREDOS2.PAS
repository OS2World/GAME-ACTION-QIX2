unit FREDOS2;

{DOS und OS/2}
{Compiler: Turbo Pascal   6.0 und 7.0  fÅr DOS
           Speed Pascal   1.5.Beta.1   fÅr OS/2
           Virtual Pascal 1.0.beta.III fÅr OS/2
}



interface
{$IFDEF DOS}
  const     fred_ver ='(17)';
{$ELSE}
  const     fred_ver ='(17)-OS/2';
{$ENDIF}
  const     LZfill : char = '0';

  Type marked = array[0..10] of boolean;

  Var       Nr     : integer;
            itemhandled : marked;
            firstunhandled : integer;
{komplett nachgebildete FRED-Funktionen}
  function  scan       (s1,
                        s2: string; n    : integer;
                        b : boolean               ) : integer;
  function  upper      (s : string)                 : string;
  function  lower      (s : string)                 : string;
  function  initcaps   (s : string)                 : string;
  function  left       (s : string; n    : integer) : string;
  function  right      (s : string; n    : integer) : string;
  function  mid        (s : string; n, m : integer) : string;
  function  ltrim      (s : string)                 : string;
  function  rtrim      (s : string)                 : string;
  function  rept       (s : string; n    : integer) : string;
  function  len        (s : string)                 : integer;
  function  itemcount                               : integer;
  function  sign       (n : longint)                : integer;

{teilweise nachgebildete FRED-Funktionen}
  function  value      (s : string)                 : longint;
  function  inputline  (s : string)                 : string;
  function  business   (n : longint; m : integer)   : string;
  function  dbusiness  (n : double;  m : integer)   : string;
  function  item       (n : integer)                : string;

{Non-FRED-Funktionen}
  procedure error      (s : string; n    : integer);
  procedure msg        (s : string; n    : integer);
  function  parse      (s : string; var Nr: integer): boolean;
  function  AllItemsHandled                         : boolean;
  function  leadingzero(n, m : integer)             : string;
  function  lz         (n, m : integer)             : string;
  function  monthname  (n : integer)                : string;
  function  dezhex     (n : longint)                : string;

{DOS-only Funktionen}
{$IFDEF DOS}
  procedure exitvdm;
  procedure capslock (b : boolean);
{$ENDIF}

implementation

var I:integer;

function  scan(s1,s2 : string; n : integer; b : boolean): integer;

var m : integer;

begin
    if b then m := pos(      s1 ,      mid(s2,n,len(s2)-n+1) )
         else m := pos(upper(s1),upper(mid(s2,n,len(s2)-n+1)));
    if m <> 0 then m:=m+n-1;
    scan := m;
end;

function upper(s:String):string;

var i : Integer;

begin
  for i := 1 to Length(s) do
    case s[i] of
    'Ñ': s[i]:='é';
    'î': s[i]:='ô';
    'Å': s[i]:='ö';
    else s[i]:=UpCase(s[i])
    end;
  upper:=s;
end;

function lower(s:String):string;
var
  i : Integer;
begin
  for i := 1 to Length(s) do
    case s[i] of
      'é': s[i]:='Ñ';
      'ô': s[i]:='Ñ';
      'ö': s[i]:='Å';
    else
      if ord(s[i]) in [65..90] then s[i]:=chr(ord(s[i])+32);
    end;
  lower:=s;
end;

function initcaps(s:string):string;

var
  i: integer;
begin
  s[1]:=upcase(s[1]);
  for i := 2 to Length(s) do
    case s[i] of
      'é': s[i]:='Ñ';
      'ô': s[i]:='Ñ';
      'ö': s[i]:='Å';
    else
      if ord(s[i]) in [65..90] then s[i]:=chr(ord(s[i])+32);
    end;
  initcaps:=s;
end;

function left    (s:string;n:integer) : string;

begin
  left:=copy(s,1,n);
end;

function right   (s:string;n:integer) : string;

begin
  right:=copy(s,length(s)-n+1,length(s));
end;

function mid     (s:string;n,m:integer) : string;

begin
  mid:=Copy(s, n, m);
end;

function ltrim    (s : string)                 : string;

var
  i: integer;
begin
  I:=0;
  repeat
    i:=i+1;
  until s[i]<>' ';
  ltrim:=right(s,length(s)-i+1);
end;


function rtrim    (s : string)                 : string;

var
  i: integer;
begin
  I:=length(s)+1;
  repeat
    i:=i-1;
  until s[i]<>' ';
  rtrim:=left(s,i);
end;

function rept (s : string; n : integer) : string;
var
  d : string;
  i : integer;

begin
  d:='';
  for i := 1 to n do d:=d+s;
  rept:=d;
end;

function len (s : String): integer;

begin
  len:=length(s);
end;

function itemcount : integer;

begin
    itemcount := paramcount;
end;

function sign( n: longint) : integer;

begin
    Sign:= n div abs(N);
end;
function value(S :String): longint;

{$IFDEF VIRTUALPASCAL}
Var RC,R  : longint;

{$ELSE}
Var RC    : integer;
    R     : longint;
{$ENDIF}

begin
    Val(S,R,RC);
    Value:=R;
end;

function  business   (n : longint; m : integer) : string;

var S,R    : string;

begin
    Str(N,S);
    R:='';
    if length(S)< 4
    then business:=right(rept(' ',132)+S,m)
    else begin
        while length(S)>=4 do begin
           R:=right(S,3)+R;
           S:=left(S,length(S)-3);
           if length(S)>0 then R:='.'+R;
        end;
        R:=S+R;
        business:=right(rept(' ',132)+R,m);
    end;
end;

function dbusiness   (n : double; m : integer) : string;

var S,R    : string;

begin
    Str(N,S);
    R:='';
    if length(S)< 4
    then dbusiness:=right(rept(' ',132)+S,m)
    else begin
        while length(S)>=4 do begin
           R:=right(S,3)+R;
           S:=left(S,length(S)-3);
           if length(S)>0 then R:='.'+R;
        end;
        R:=S+R;
        dbusiness:=right(rept(' ',132)+R,m);
    end;
end;

function item(N: integer):string;

begin
    item:=paramstr(n);
end;

procedure error(S: string; n: integer);


begin
    writeln(s+chr(07));
    halt(n)
end;

procedure msg(S: string; n: integer);

begin
    writeln(s);
    halt(n)
end;

function inputline(s:string):string;

var C:string;

begin
    c:='';
    write(s);
    readln(C);
    inputline:=C;
end;

function parse(s:string;var Nr: integer):boolean;

var
  i : integer;
  gotcha: boolean;

begin
  gotcha:=FALSE;
  i:=0;
  if paramcount > 0 then begin
    repeat
      I:=I+1;
      gotcha:=pos(upper(s),upper(paramstr(I)))>0;
    until (I=paramcount) or (gotcha);
    if gotcha then begin
        Nr:=I;
        ItemHandled[I]:=TRUE
    end else Nr:=0;
    parse:=gotcha;
  end
  else begin
    parse:=s='';
    Nr:=0;
  end;
end;

function AllItemsHandled: boolean;

var I: integer;
    FoundUnhandled: boolean;
begin
    I:=0;
    repeat
        I:=I+1;
        FoundUnhandled:=not(itemhandled[I]);
    until (I=paramcount) or (FoundUnhandled);
    if FoundUnhandled then FirstUnhandled:=I else FirstUnhandled:=0;
    AllItemsHandled:=not(FoundUnhandled);
end;

function  LeadingZero(n, m : integer)             : string;

var
  s : String;

begin
  Str(n,s);
  LeadingZero := right(rept('0',132)+s,m);
end;

function  LZ(n, m : integer)             : string;

var
  s : String;

begin
  Str(n,s);
  LZ := right(rept(LZfill,132)+s,m);
end;

function monthname(N: integer):string;

var
    s : string;

begin
    case n mod 12 of
     1 : s:='JÑnner';
     2 : s:='Feber';
     3 : s:='MÑrz';
     4 : s:='April';
     5 : s:='Mai';
     6 : s:='Juni';
     7 : s:='Juli';
     8 : s:='August';
     9 : s:='September';
    10 : s:='Oktober';
    11 : s:='November';
    12 : s:='Dezember'
    else s:='ERROR' {Nicht mîglich}
    end;
    Monthname:=s;
end;

function dezhex(n : longint) : string;

const hexZ : String[16] = '01234567890ABCDEF';

var Zahl: string;
    Z   : longint;

begin
    Z:=N;
    Zahl:='';
    if Z = 0 then Zahl:='00000000';
    while Z<>0 do begin
        Zahl:= HexZ[abs(Z mod 16)+sign(Z)]+ Zahl;
        Z:=Z div 16;
    end;
    if N<0 then Zahl:='-'+Zahl;
    dezhex:=Zahl;
end;


{$IFDEF DOS}

procedure CapsLock (B: boolean);

var ON_OFF : byte;

begin
    if B then ON_OFF:=$40 else ON_OFF:=$00;
    memw[0:$417]:= mem[0:$417] xor $40
end;

procedure exitvdm;

begin
    asm
      mov ah,4D
      int 21
      hlt
      db 2,$FD
    end;
end;
{$ENDIF}

begin
    for I:= 0 to 10 do itemhandled[I]:=FALSE;
end.
