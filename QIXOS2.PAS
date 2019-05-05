Program QixOS2;

uses DOS,CRT,FREDOS2;

Const
  Version         = '1.0';
  Max_Len_snake   = 40;
  Max_Buff_len    = 200;
  Blank           = ' ';
  xch             = #$b3;
  qch             = #$c4;
  lch             = #$da;
  mch             = #$c0;
  nch             = #$c5;
  kch             = #$bf;
  jch             = #$d9;
  vch             = #$c1;
  wch             = #$c2;
  uch             = #$b4;
  tch             = #$c3;

Type
  Buff_String     = Array [1..Max_Buff_Len] Of Char;
  string40        = string[40];
  rng             = 1..20;
  Wall_Types      = (Inside,Outside,Created,Other,Snake,Tmp,TmpN,TmpN2,TmpCreat);
  Char_On_Screen  = Record
      Sym          : Char;
      Wall         : Wall_Types;
                    end;
  Direction  = ( Clockwise , AntiClockwise );
  Screen_type = Array[0..24,0..81] Of Char_On_Screen;

Var
  Screen                  : Screen_Type;
  PLAY_AGAIN              ,
  qix_head                ,
  you                     ,
  esc                     : char;
  Buff                    : Buff_String;
  Buff_Len                ,
  mark_x_clock_greeb      ,
  mark_y_clock_greeb      ,
  mark_x_anti_greeb       ,
  mark_y_anti_greeb       ,
  num_mar_clock_greeb     ,
  Num_mar_anti_greeb      ,
  last_x_clock_greeb      ,
  last_y_clock_greeb      ,
  last_x_anti_greeb       ,
  last_y_anti_greeb       ,
  clock_x_greeb           ,
  clock_y_greeb           ,
  anti_x_greeb            ,
  anti_y_greeb            ,
  extra_x_greeb           ,
  extra_y_greeb           ,
  l_extra_x_greeb         ,
  l_extra_y_greeb         ,
  You_X                   ,
  You_Y                   ,
  lst_you_X               ,
  lst_you_Y               ,
  Move_X                  ,
  Level                   ,
  Move_y                  ,
  start_x_creat           ,
  start_y_creat           ,
  l_start_x_creat         ,
  l_start_y_creat         ,
  snake_x_after           ,
  snake_y_after           ,
  snake_x_head            ,
  snake_y_head            ,
  snake_x_move            ,
  snake_y_move            ,
  snake_x_tail            ,
  Lives                   ,
  Score                   ,
  Amt_Filled_In           ,
  Len_Snake               ,
  lgth_snake_when_stuck   ,
  Num_Snake_Searched      ,
  Num_Moves_After_This_Pt ,
  Moves_since_stuck       ,
  act_x                   ,
  act_y                   ,
  snake_y_tail            ,
  Game_Speed              ,
  Default_Speed           ,
  Seed                    : integer;
  percent                 : integer;
  NEXTPLAY                ,               (* SET TO ZERO AT 1ST START *)
  Can_Create_wall         ,
  Moving_Extra_Greebly    ,
  Marked_Clock_Greeb      ,
  Marked_Anti_Greeb       ,
  Snake_got_stuck         ,
  Died                    ,
  Creating_wall           : boolean;
  HelpString              : String40;
  Dir_You                 ,                       { Direction You Are moving In }
  Dir_When_Start_Creat    : direction;            { Direction You Were In Before Starting To Create }
  reg                     : registers;
  Datum                   : byte;
  Count                   : byte;
  YearW,MonthW,DayW,DoW   : integer;
  HourW,MinW,SecW,HundW   : integer;

function sqrint(X:integer): longint;

begin
    sqrint:=X*X;
end;

procedure Nope;

begin
end;

function tt_1_char_now : byte;

var KBDC : char;

begin
    KBDC:=chr(0);
    if keypressed then
    begin
        KBDC:=readkey;
        if ord(KBDC)=0 then KBDC:=readkey;
    end;
    tt_1_char_now:=ord(KBDC);
end;


Procedure Sleep_Start;

Begin
Repeat Until tt_1_char_now = 0;
Repeat Until KeyPressed;
End;


Procedure sound_bell;

Begin
    if paramcount=0 then begin
        beep (330,150);
    end
    else begin
        gotoxy(75,24);
        textcolor(lightred);
        write('BEEP!');
        textcolor(lightgray);
        delay (150);
        gotoxy(75,24);
        write('     ');
    end;
End;

Function Rand( X : Integer):Integer;
  begin
  rand := random(x);
  end;

Procedure Write_Buff( C : Char);

Begin
    act_y := act_y + 1;
    gotoxy(act_y,act_x);
    write(c);
end;


Procedure posxy(X,Y : Integer; Ch : Char);

Begin
    act_x := x;
    act_y := y;
    gotoxy(Y,X);
    write(ch)
End;


Procedure Draw_Screen;

Var X,Y,Dummy : Integer;

   Begin
   clrscr;
   For Y := 1 to 80 do
      posxy(1, Y, Screen[1,Y].Sym);
   For X := 2 to 22 do
      begin
      posxy(x, 1,Screen[x, 1].sym);
      posxy(x,80,Screen[x,80].sym);
      end;
   For Y := 1 to 80 do
      posxy(23,Y, Screen[23,Y].Sym);
   posxy(24,1,'C'); Write ('overed ');
   percent:=((amt_filled_in*100) div 1638);
   Str (percent:4, HelpString);
   textcolor(white);
   Write (HelpString+'%');
   textcolor(lightgray);
   Write ('  Score ');
   textcolor(white);
   Str (score:5,HelpString);
   Write (HelpString);
   textcolor(lightgray);
   Write('  Lives ');
   textcolor(lightcyan);
   For Dummy := 1 to Lives Do Write (' '+chr(1));
   textcolor(lightgray);
   posxy(24,43,'S'); Write ('peed ');
   Write (Chr(Ord('5')-Game_Speed));
   textcolor(rand(16));
   write('  QIX for OS/2 (32bit)');
   textcolor(LightGray);
   posxy(snake_x_head,snake_y_head,Qix_Head);
   posxy(You_X,You_Y,You);
   end;

Procedure QixStat (QixScore: Integer);

Type string20 =String[20];

Type statistic = RECORD
                   score:  longint;
                   name:   String20;
                   date:   String20;
                 END;

Var StatFile:    text;
    StatRecord:  statistic;
    TopTen:      Array [1..10] of statistic;
    loop,
    loop_1:      Integer;
    player:      string20;
    year:        string[4];
    month,
    day,
    hour,act_hour,
    minute,act_min,
    second:      string[2];
    top_file:    String[11];
    name_ok:     Boolean;
    StatLine,
    DummyS:    String;
    RetCod:    integer;
    DummYL:    Longint;

Begin {QixStat}

top_file := 'QIX'+Chr(Game_Speed+ord('0'))+'.TOP';

Assign (StatFile, top_file );
{$I-}
Reset (StatFile);
{$I+}
If (IOresult <> 0)
Then begin
    For loop := 1 to 10 do begin
        TopTen[loop].score := (1500*(Game_Speed+1)-100*(loop-1)*(Game_Speed+1));
        TopTen[loop].name  := '--------------------';
        TopTen[loop].date  := '----/--/--  --:--:--';
    End;
end
Else Begin
    For loop := 1 to 10 Do begin
        Readln(StatFile,Statline);
        Val(left(Statline,5),TopTen[loop].score,RetCod);
        TopTen[loop].name :=mid(statline,6,20);
        TopTen[loop].date :=right(statline,20);
    end;
    Close (StatFile);
End;

StatRecord.score := QixScore;
StatRecord.date  := ' ';
StatRecord.name  := '                    ';

If (QixScore > TopTen[10].score)
Then Begin
    if paramcount=0 then begin
        beep (055,500);
        beep (110,500);
        beep (220,500);
        beep (440,500);
    end
    else begin
        textcolor(lightred);
        gotoxy(75,24);write('BEEP!');gotoxy(75,24);write('     ');delay(500);
        gotoxy(75,24);write('BEEP!');gotoxy(75,24);write('     ');delay(500);
        textcolor(lightgray);
    end;
    ClrScr;       NormVideo;
    REPEAT
       GoToXY(20,12);
       Write ('Please enter your name: ');
       {$I-}
       Readln (player);
       {$I+}
       WHILE (NOT (player[1] IN ['A'..'Z','a'..'z'])) AND (length(player) > 0)
       DO Delete (player, 1, 1);
     UNTIL length(player) > 0;
     StatRecord.name := Concat (player,copy(StatRecord.name,
                                            length(player), 20));
     GetDate(YearW,MonthW,DayW,DoW);
     Str (DayW, day);
     day:=right('0'+day,2);
     Str (MonthW, month);
     Month:=right('0'+Month,2);
     Str (YearW, year);
     GetTime(HourW,MinW,SecW,HundW);
     Str (HourW, hour);
     Hour:=right('0'+Hour,2);
     Str (MinW, minute);
     minute:=right('0'+minute,2);
     Str (SecW, second);
     second:=right('0'+second,2);

     StatRecord.date := Concat (year,'/',month,'/',day,'  ',
                                hour,':',minute,':',second);
     ClrScr;
     End
ELSE BEGIN
    if paramcount=0 then begin
        beep (440,500);
        beep (220,500);
        beep (110,500);
        beep ( 55,500);
    end
    else begin
        textcolor(lightred);
        gotoxy(75,24);write('BEEP!');gotoxy(75,24);write('     ');delay(500);
        gotoxy(75,24);write('BEEP!');gotoxy(75,24);write('     ');delay(500);
        textcolor(lightgray);
    end;

     ClrScr;NormVideo;
     END;

If (QixScore > TopTen[10].score)
THEN BEGIN
     Assign (StatFile, top_file);
     Rewrite (StatFile);
     END;

GetTime(HourW,MinW,SecW,HundW);
str(HourW,act_hour);
str(MinW,act_min);
Act_hour:=right('0'+act_hour,2);
Act_min :=right('0'+act_min ,2);
textcolor(yellow);
GoToXY(25,2);Writeln('QIX Top Ten of Level ',5-Game_Speed:1,' at ',Act_Hour,':',Act_Min);
GoToXY(25,3);Writeln('ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ');
GoToXY(12,6);Writeln('Rank  Score          Name             Date       Time');
GoToXY(12,7);Writeln('ƒƒƒƒ  ƒƒƒƒƒ  ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ  ƒƒƒƒƒƒƒƒƒƒ  ƒƒƒƒƒƒƒƒ');
textcolor(lightgray);
LowVideo;
loop := 0;

Repeat
  loop := loop + 1;
  If (QixScore <= TopTen[loop].score)
  Then Begin
       If (QixScore > TopTen[10].score) THEN begin
           Str(TopTen[loop].score:5,Statline);
           Statline:=Statline+TopTen[loop].name+TopTen[loop].date;
           Writeln(StatFile, Statline);
       end;
       If loop<=3 then textcolor(White);
       GoToXY(13,loop+8); Writeln (loop,'.   ');
       GoToXY(18,loop+8); Writeln (TopTen[loop].score:5,'  ');
       GoToXY(25,loop+8); Writeln (TopTen[loop].name:20,'  ');
       GoToXY(47,loop+8); Writeln (TopTen[loop].date:20);
       If loop=3 then textcolor(lightGray);
       End
  Else Begin
       If (QixScore > TopTen[10].score) Then begin
           Str(Statrecord.score:5,Statline);
           Statline:=Statline+StatRecord.name+StatRecord.date;
           Writeln(StatFile, Statline);
       end;
       NormVideo;
       textcolor(lightred);
       GoToXY(13,loop+8); Writeln (loop,'.   ');
       GoToXY(18,loop+8); Writeln (StatRecord.score:5,'  ');
       GoToXY(25,loop+8); Writeln (StatRecord.name:20,'  ');
       GoToXY(47,loop+8); Writeln (StatRecord.date:20);
       textcolor(lightgray);
       LowVideo;
       For loop_1 := loop to 9
       Do Begin
          If (QixScore > TopTen[10].score) Then begin
              Str(TopTen[loop_1].score:5,Statline);
              Statline:=Statline+TopTen[loop_1].name+TopTen[loop_1].date;
              Writeln(StatFile, Statline);
          end;
          If loop_1+1<=3 then textcolor(White);
          GoToXY(13,loop_1+9); Writeln (loop_1+1,'.   ');
          GoToXY(18,loop_1+9); Writeln (TopTen[loop_1].score:5,'  ');
          GoToXY(25,loop_1+9); Writeln (TopTen[loop_1].name:20,'  ');
          GoToXY(47,loop_1+9); Writeln (TopTen[loop_1].date:20);
          If loop_1+1=3 then textcolor(Lightgray);
          End;
       loop := 10;
       End;

Until (loop = 10);

If (QixScore <= TopTen[10].score)
Then Begin
     GotoXY (12,20);
     Write ('Sorry, but your score (',QixScore,') is too little, try harder !');
     End;

If (QixScore > TopTen[10].score) Then Close (StatFile);

End;  {QixStat}


Function Correct_Sym(X,Y,Compare_X,Compare_Y:Integer):Char;


Var Count : Integer;

      Begin
      Count := 0;
      If Screen[X-1,y].Sym In [lch,wch,kch,tch,nch,uch,xch]
      Then Count := Count + 1
      Else If ( X - 1 = Compare_X ) And ( Y = Compare_Y )
            Then Count := Count + 1;
      If Screen[x,Y-1].Sym In [lch,wch,tch,nch,mch,vch,qch]
      Then Count := Count + 2
      Else If ( X = Compare_X ) And ( Y - 1 = Compare_Y )
           Then Count := Count + 2;
      If Screen[X,Y+1].Sym In [wch,nch,vch,kch,uch,jch,qch]
      Then Count := Count + 4
      Else If ( X = Compare_X ) And ( Y + 1 = Compare_Y )
           Then Count := Count + 4;
      If Screen[X+1,Y].Sym In [tch,nch,uch,mch,vch,jch,xch]
      Then Count := Count + 8
      Else If ( X + 1 = Compare_X ) And ( Y = Compare_Y )
           Then Count := Count + 8;
      Case Count Of
         0      : { nothing };
         1,8,9  : Correct_Sym := xch;
         2,4,6  : Correct_Sym := qch;
         3      : Correct_Sym := jch;
         5      : Correct_Sym := mch;
         7      : Correct_Sym := vch;
         10     : Correct_Sym := kch;
         11     : Correct_Sym := uch;
         12     : Correct_Sym := lch;
         13     : Correct_Sym := tch;
         14     : Correct_Sym := wch;
         15     : Correct_Sym := nch
         end { case };
     end;

Procedure Ini_screen;

Var X,Y,Dummy,snake_x_move,snake_y_move,Cnt : Integer;
    Save_ch : Char;

   begin
   Died := False;
   Level := Level + 1;
   (* Sleep_set(7,17-Level); *)
   For X := 0 To 24 Do
      For Y := 0 To 81 Do
         Begin
         Screen[X,Y].Sym := Blank;
         Screen[X,Y].Wall := Other;
         End;
   For Y := 0 To 81 Do
      Begin
      Screen[0,Y].Sym := '.';
      Screen[0,Y].Wall := Outside;
      Screen[24,Y].Sym := '.';
      Screen[24,Y].Wall := Outside;
      End { For };
   For X := 0 To 24 Do
      Begin
      Screen[X,0].Sym := '.';
      Screen[X,0].Wall:= Outside;
      Screen[X,81].Sym := '.';
      Screen[X,81].Wall := Outside;
      end;
   For Y := 1 To 80 Do
      Begin
      Screen[1,Y].Sym  := qch;
      Screen[1,Y].Wall  := Inside;
      Screen[23,Y].Sym := qch;
      Screen[23,Y].Wall := Inside;
      end;
   For X := 1 to 23 Do
      Begin
      Screen[X,1].Sym := xch;
      Screen[X,1].Wall := Inside;
      Screen[X,80].Sym := xch;
      Screen[X,80].Wall := Inside;
      end;
   Screen[1,1].Sym := lch;
   Screen[1,1].wall := Inside;
   Screen[1,80].Sym := kch;
   Screen[1,80].wall := Inside;
   Screen[23,1].Sym := mch;
   Screen[23,1].wall := Inside;
   Screen[23,80].Sym := jch;
   Screen[23,80].wall := Inside;
   You_X := 1;
   You_Y := 1;
   Move_X := 0;
   Move_Y := 1;
   lst_you_X := 2;
   lst_you_Y := 1;
   Dir_You := Clockwise;
   snake_x_head := 11;
   snake_y_head := 40;
   snake_x_tail := snake_x_head;
   snake_y_tail := snake_y_head;
   Moves_since_stuck := 0;
   Screen[snake_x_head,snake_y_head].Sym  :=  Qix_Head;
   Screen[snake_x_head,snake_y_head].Wall := Snake;
   Len_Snake := 0;
   Amt_Filled_In := 0;
   Moving_extra_Greebly := False;
   Snake_got_stuck := False;
   snake_x_move := 0;
   snake_y_move := -1;
   Can_Create_wall := False;
   CREATING_WALL := FALSE;
   clock_x_greeb := 23;
   clock_y_greeb := 40;
   last_x_clock_greeb := clock_x_greeb;
   last_y_clock_greeb := clock_y_greeb + 1;
   anti_x_greeb := 12;
   anti_y_greeb := 80;
   last_x_anti_greeb := anti_x_greeb + 1;
   last_y_anti_greeb := anti_y_greeb;
   Marked_Anti_Greeb := False;
   Marked_Clock_Greeb := False;
   mark_x_anti_greeb := 0;
   mark_y_anti_greeb := 0;
   mark_x_clock_greeb := 0;
   mark_y_clock_greeb := 0;
   Num_Moves_After_This_pt := 9999;
   Draw_Screen;
   end;





Procedure Initalise;

Var Rep : Char;


   Begin
   esc := chr(27);
   You := chr(1);
   qix_head := char(4);
   (* TT_Init(1); *)
   Seed := 411;  (* Clock; *)
   IF   NOT NEXTPLAY
   THEN BEGIN
        (* Help_Screen('qixhlp.Scn'); *)
        NEXTPLAY := TRUE;
        END;
   Level := 0;
   Lives := 3;
   Score := 0;
   Buff_Len := 0;
   Ini_Screen;
   end { Initalise };


Function Valid_Move(X,Y:Integer):Boolean;

   begin
   If Screen[X,Y].Sym = '.'
   Then Valid_Move := False
   Else If Screen[X,Y].Wall = Created
        Then Valid_Move := False
        Else Valid_Move := True;
   end;

Procedure Move_Anti_Clockwise(Var X,Y,Last_X,Last_Y:integer);

Var Tmp_X,Tmp_Y : Integer;

   Begin
   Tmp_X := X;
   Tmp_Y := Y;
   Case ( Last_Y-Y) Of
      1 : Case  Screen[X,Y].Sym Of
            lch : X := X + 1;
            wch : X := X + 1;
            tch : X := X + 1;
            nch : X := X + 1;
            mch : X := X - 1;
            vch : Y := Y - 1;
            qch : Y := Y - 1;
             end;
      0 : Case (Last_X-X) Of
            1 : Case Screen[X,y].Sym Of
                  lch : Y := Y + 1;
                  wch : Y := Y - 1;
                  kch : Y := Y - 1;
                  tch : X := X - 1;
                  nch : Y := Y - 1;
                  uch : Y := Y - 1;
                  xch : X := X - 1;
                   end;
            0 : ;
           -1 : Case Screen[X,y].Sym Of
                  tch : Y := Y + 1;
                  nch : Y := Y + 1;
                  uch : X := X + 1;
                  mch : Y := Y + 1;
                  vch : Y := Y + 1;
                  jch : Y := Y - 1;
                  xch : X := X + 1;
                   end;
           end;
     -1 : Case Screen[X,Y].Sym Of
            wch : Y := Y + 1;
            kch : X := X + 1;
            nch : X := X - 1;
            uch : X := X - 1;
            vch : X := X - 1;
            jch : X := X - 1;
            qch : Y := Y + 1;
             end;
      End { case };
   last_X := Tmp_X;
   last_Y := Tmp_Y;
   end { Move_Anti_Clockwise};




Procedure Move_Clockwise(Var X,Y,Last_X,Last_Y:Integer);

Var Tmp_X,Tmp_Y : Integer;

   Begin
   Tmp_X := X;
   Tmp_Y := Y;
   Case ( Last_Y-Y) Of
      1 : Case  Screen[X,Y].Sym Of
            lch : X := X + 1;
            wch : Y := Y - 1;
            tch : X := X - 1;
            nch : X := X - 1;
            mch : X := X - 1;
            vch : X := X - 1;
            qch : Y := Y - 1;
             end;
      0 : Case (Last_X-X) Of
            1 : Case Screen[X,y].Sym Of
                  lch : Y := Y + 1;
                  wch : Y := Y + 1;
                  kch : Y := Y - 1;
                  tch : Y := Y + 1;
                  nch : Y := Y + 1;
                  uch : X := X - 1;
                  xch : X := X - 1;
                   end;
            0 : ;
           -1 : Case Screen[X,y].Sym Of
                  tch : X := X + 1;
                  nch : Y := Y - 1;
                  uch : Y := Y - 1;
                  mch : Y := Y + 1;
                  vch : Y := Y - 1;
                  jch : Y := Y - 1;
                  xch : X := X + 1;
                   end;
           end;
     -1 : Case Screen[X,Y].Sym Of
            wch : X := X + 1;
            kch : X := X + 1;
            nch : X := X + 1;
            uch : X := X + 1;
            vch : Y := Y + 1;
            jch : X := X - 1;
            qch : Y := Y + 1;
             end;
      End { case };
   Last_X := Tmp_X;
   Last_Y := Tmp_Y;
   end { Move_Clockwise};

Procedure mov_opp_Anti_Clockwise(Var X,Y,Last_X,Last_Y : Integer);

Var Tmp_X,Tmp_Y : Integer;

   Begin
   If Screen[X,y].Sym = nch
   Then Begin
        Tmp_X := X;
        Tmp_Y := Y;
        Y  := Y + (Y-Last_Y);
        X  := X + (X-Last_X);
        Last_X := Tmp_X;
        Last_Y := Tmp_Y;
        end
   else Move_Clockwise(X,Y,Last_X,Last_Y);
   end;

Procedure mov_opp_Clockwise(Var X,Y,Last_X,Last_Y : Integer);

Var Tmp_X,Tmp_Y : Integer;

   Begin
   If Screen[X,y].Sym = nch
   Then Begin
        Tmp_X := X;
        Tmp_Y := Y;
        Y  := Y + (Y-Last_Y);
        X  := X + (X-Last_X);
        Last_X := Tmp_X;
        Last_Y := Tmp_Y;
        end
   Else Move_anti_Clockwise(X,Y,Last_X,Last_Y);
   end;








Procedure Move_Greeblys;

Var Tmp : Integer;

   Procedure Jump_Greeb(Var Sudo_X,Sudo_Y,LSudo_X,LSudo_Y : Integer);



      Begin
      Sudo_X := snake_x_head;
      Sudo_Y := snake_y_head;
      While Not ( Screen[Sudo_X,Sudo_Y].Wall In [Created,Inside])
      Do Sudo_X := Sudo_X - 1;
      If Screen[Sudo_X,Sudo_Y].Wall =  Created
      Then Begin
           LSudo_X := Sudo_X;
           LSudo_Y := Sudo_Y;
           Case Screen[Sudo_X,Sudo_Y].Sym Of
               mch ,
               vch ,
               qch : Sudo_Y := Sudo_Y + 1;
               jch : Sudo_X := Sudo_X - 1;
               ELSE Begin
                    LSudo_X := Sudo_X + 1;
                    LSudo_Y := Sudo_Y;
                    end
               End { CAse };
           While Screen[Sudo_X,Sudo_Y].Wall = Created
           Do Move_Clockwise(Sudo_X,Sudo_Y,LSudo_X,LSudo_Y);
           end
      Else begin
           LSudo_X := Sudo_X;
           LSudo_Y := Sudo_Y;
           Case Screen[Sudo_X,Sudo_Y].Sym Of
              mch ,
              vch ,
              qch : Sudo_Y := Sudo_Y + 1;
              jch : Sudo_X := Sudo_X - 1;
              ELSE Begin
                   LSudo_X := Sudo_X + 1;
                   LSudo_Y := Sudo_Y;
                   end
              End { CAse };
           end;
      end;



   Begin
   {Move_Clockwise_wise_one}
   posxy(clock_x_greeb,clock_y_greeb,Screen[clock_x_greeb,clock_y_greeb].Sym);
   If Screen[clock_x_greeb,clock_y_greeb].Wall = Inside
   Then  Begin
         If Screen[last_x_clock_greeb,last_y_clock_greeb].Wall = Outside
         Then Begin
              Marked_Clock_Greeb := False;
              mov_opp_Clockwise(clock_x_greeb,clock_y_greeb,last_x_clock_greeb,last_y_clock_greeb)
              end
         Else Begin
              If Marked_Clock_Greeb
              Then Begin
                   If num_mar_clock_greeb > 80
                   Then begin
                        Marked_Clock_Greeb := False;
                        Move_Clockwise(clock_x_greeb,clock_y_greeb,last_x_clock_greeb,last_y_clock_greeb);
                        end
                   else begin
                        num_mar_clock_greeb := num_mar_clock_greeb + 1;
                        If ( clock_x_greeb = mark_x_clock_greeb ) and ( clock_y_greeb = mark_y_clock_greeb )
                        Then Begin
                             Marked_Clock_Greeb := False;
                             Jump_Greeb(clock_x_greeb,clock_y_greeb,last_x_clock_greeb,last_y_clock_greeb)
                             end
                        else Move_Clockwise(clock_x_greeb,clock_y_greeb,last_x_clock_greeb,last_y_clock_greeb);
                        end
                   end
              else Move_Clockwise(clock_x_greeb,clock_y_greeb,last_x_clock_greeb,last_y_clock_greeb);
              end
         end
   else  If Screen[clock_x_greeb,clock_y_greeb].Wall = Created
         Then mov_opp_Clockwise(clock_x_greeb,clock_y_greeb,last_x_clock_greeb,last_y_clock_greeb)
         Else Begin
              If Marked_Clock_Greeb
              Then Begin
                   If ( clock_x_greeb = mark_x_clock_greeb ) And ( clock_y_greeb = mark_y_clock_greeb)
                   Then Begin
                        Marked_Clock_Greeb := False;
                        Jump_Greeb(clock_x_greeb,clock_y_greeb,last_x_clock_greeb,last_y_clock_greeb)
                        end
                   else Move_Clockwise(clock_x_greeb,clock_y_greeb,last_x_clock_greeb,last_y_clock_greeb)
                   End
              Else Move_Clockwise(clock_x_greeb,clock_y_greeb,last_x_clock_greeb,last_y_clock_greeb);
              end;
   textcolor(lightGreen);
   posxy(clock_x_greeb,clock_y_greeb,chr($0f));
   textcolor(lightgray);
   If (You_X=clock_x_greeb) and (You_Y=clock_y_greeb)
   Then Died := True;
{Move AntiClockwise One }
   posxy(anti_x_greeb,anti_y_greeb,Screen[anti_x_greeb,anti_y_greeb].Sym);
   If Screen[anti_x_greeb,anti_y_greeb].Wall = Inside
   Then  Begin
         If Screen[last_x_anti_greeb,last_y_anti_greeb].Wall = Outside
         Then Begin
              Marked_Anti_Greeb := False;
              mov_opp_Anti_Clockwise(anti_x_greeb,anti_y_greeb,last_x_anti_greeb,last_y_anti_greeb)
              End
         Else If Marked_Anti_Greeb
              Then Begin
                   If Num_mar_anti_greeb > 80
                   Then begin
                        Marked_Anti_Greeb := False;
                        Move_Anti_Clockwise(anti_x_greeb,anti_y_greeb,last_x_anti_greeb,last_y_anti_greeb)
                        end
                   else begin
                        Num_mar_anti_greeb := Num_mar_anti_greeb + 1;
                        If ( anti_x_greeb = mark_x_anti_greeb ) and ( anti_y_greeb = mark_y_anti_greeb )
                        Then Begin
                             Marked_Anti_Greeb := False;
                             Jump_Greeb(anti_x_greeb,anti_y_greeb,last_x_anti_greeb,last_y_anti_greeb);
                             Tmp := anti_x_greeb;
                             anti_x_greeb := last_x_anti_greeb;
                             last_x_anti_greeb := Tmp;
                             Tmp := anti_y_greeb;
                             anti_y_greeb := last_y_anti_greeb;
                             last_y_anti_greeb := Tmp;
                             end
                        else Move_Anti_Clockwise(anti_x_greeb,anti_y_greeb,last_x_anti_greeb,last_y_anti_greeb)
                        end
                   end
              else Move_Anti_Clockwise(anti_x_greeb,anti_y_greeb,last_x_anti_greeb,last_y_anti_greeb)
         end
    else if screen[anti_x_greeb,anti_y_greeb].wall = created
         then mov_opp_Anti_Clockwise(anti_x_greeb,anti_y_greeb,last_x_anti_greeb,last_y_anti_greeb)
         Else Begin
              If Marked_Anti_Greeb
              Then Begin
                   if ( anti_x_greeb = mark_x_anti_greeb ) And ( anti_y_greeb = mark_y_anti_greeb)
                   Then Begin
                        Marked_Anti_Greeb := False;
                        Jump_Greeb(anti_x_greeb,anti_y_greeb,last_x_anti_greeb,last_y_anti_greeb);
                        Tmp := anti_x_greeb;
                        anti_x_greeb := last_x_anti_greeb;
                        last_x_anti_greeb := Tmp;
                        Tmp := anti_y_greeb;
                        anti_y_greeb := last_y_anti_greeb;
                        last_y_anti_greeb := Tmp;
                        end
                   else Move_Anti_Clockwise(anti_x_greeb,anti_y_greeb,last_x_anti_greeb,last_y_anti_greeb);
                   End
              Else Move_Anti_Clockwise(anti_x_greeb,anti_y_greeb,last_x_anti_greeb,last_y_anti_greeb);
              end;
   textcolor(LightRed);
   posxy(anti_x_greeb,anti_y_greeb,chr($0f));
   Textcolor(LightGray);
   If (You_X=anti_x_greeb) and (You_Y=anti_y_greeb)
   Then Died := True;
   If Moving_Extra_Greebly
   Then Begin
        textcolor(LightMagenta);
        posxy(extra_x_greeb,extra_y_greeb,Screen[extra_x_greeb,extra_y_greeb].Sym);
        Textcolor(LightGray);
        If Dir_When_Start_Creat = Clockwise
        Then Move_ClockWise(extra_x_greeb,extra_y_greeb,l_extra_x_greeb,l_extra_y_greeb)
        Else Move_Anti_ClockWise(extra_x_greeb,extra_y_greeb,l_extra_x_greeb,l_extra_y_greeb);
        posxy(extra_x_greeb,extra_y_greeb,chr($0f));
        If (You_X=extra_x_greeb) And (You_Y =extra_y_greeb)
        Then Died := True
        Else begin
             posxy(extra_x_greeb,extra_y_greeb,Screen[extra_x_greeb,extra_y_greeb].Sym);
             If Dir_When_Start_Creat = Clockwise
             Then Move_ClockWise(extra_x_greeb,extra_y_greeb,l_extra_x_greeb,l_extra_y_greeb)
             Else Move_Anti_ClockWise(extra_x_greeb,extra_y_greeb,l_extra_x_greeb,l_extra_y_greeb);
             posxy(extra_x_greeb,extra_y_greeb,chr($0f));
             If (You_X=extra_x_greeb) And (You_Y =extra_y_greeb)
             Then Died := True;
             end;
        end;
   end;






Procedure Move_Snake;

Var tmp,cnt: Integer;
    Save_ch : Char;
    Swaped_head : Boolean;
    dist_to_head,
    dist_to_tail : Integer;

    procedure Get_Move_For_Snake ;


        Procedure Swap_snake_head_and_Tail;

        Var Tmp_Tail_X,Tmp_Tail_Y : Integer;

            begin
            Swaped_Head := True;
            Moves_since_stuck := 0;
            Snake_Got_stuck := False;
            Tmp_Tail_X := snake_x_tail;
            Tmp_Tail_Y := snake_y_tail;
            Screen[snake_x_head,snake_y_head].Wall := Other;
            Screen[snake_x_head,snake_y_head].Sym  := Blank;
            posxy(snake_x_head,snake_y_head,Blank);
            If ( Screen[snake_x_head,snake_y_head+1].Wall = Snake )
            and ( Screen[snake_x_head,snake_y_head+1].Sym in [qch,kch,jch] )
            Then begin
                 snake_x_tail := snake_x_head;
                 snake_y_tail := snake_y_head+1;
                 end
            else If ( Screen[snake_x_head,snake_y_head-1].Wall = Snake )
                 and ( Screen[snake_x_head,snake_y_head-1].Sym in [qch,lch,mch] )
                 Then begin
                      snake_x_tail := snake_x_head;
                      snake_y_tail := snake_y_head-1;
                      end
                 else If ( Screen[snake_x_head+1,snake_y_head].Wall = Snake )
                      and ( Screen[snake_x_head+1,snake_y_head].Sym in [xch,mch,jch] )
                      Then begin
                           snake_x_tail := snake_x_head+1;
                           snake_y_tail := snake_y_head;
                           end
                      else If ( Screen[snake_x_head-1,snake_y_head].Wall = Snake )
                           and ( Screen[snake_x_head-1,snake_y_head].Sym in [xch,lch,kch] )
                           Then  begin
                                 snake_x_tail := snake_x_head-1;
                                 snake_y_tail := snake_y_head;
                                 end;
            snake_x_head := Tmp_Tail_X;
            snake_y_head := Tmp_Tail_Y;
            Screen[snake_x_head,snake_y_head].Sym := Blank;
            Screen[snake_x_head,snake_y_head].Wall := Snake;
            textcolor(lightmagenta);
            posxy(snake_x_head,snake_y_head,Qix_Head);
            textcolor(lightgray);
            Len_Snake := Len_Snake - 1;
            end;


         Function Sgn(X:Integer):Integer;

            Begin
            If X > 0
            Then Sgn := 1
            else If X < 0
                 Then Sgn := -1
                 Else Sgn := 0;
            end;


         Procedure Search_For_Move;

         Var X,Y,XX,YY,Dist,Closest : Integer;

             begin
             Num_Snake_Searched := Num_Snake_Searched  + 1;
             snake_x_move := 0;
             snake_y_move := 0;
             X := 0;
             Y := 0;

             Closest := 32000;
             For Xx := 1 To 4
             do begin
                Case Xx of
                   1 : Y := 1;
                   2 : Y := -1;
                   3 : Begin
                       Y := 0;
                       X := 1;
                       end;
                   4 : X := -1 ;
                   end;
                Dist :=sqrint( ((snake_x_head + X ) - snake_x_after) )
                     + sqrint( ((snake_y_head + Y ) - snake_y_after) );
                If Dist < Closest
                Then If (( X + Y ) <> 0 )
                     and
            ( Screen[snake_x_head+X,snake_y_head+Y].wall in [Created,Other] )
                     and
            ( Not (( snake_x_head+X = start_x_creat )
                     and ( snake_y_head+Y = start_y_creat)))
                     Then Begin
                          snake_x_move := X;
                          snake_y_move := Y;
                          Closest := Dist;
                          end;
                end;
             end;





          Begin
          If Creating_wall
          Then begin
               If  ( Num_Snake_Searched  > ( 10 + Rand(10)))
               And ( Moves_Since_stuck > 15 )
               Then Begin
                    Num_Snake_Searched := 0;
                    Swap_Snake_Head_and_Tail;
                    snake_x_after := You_X;
                    snake_y_after := You_Y;
                    end
               else begin
                    dist_to_tail :=sqrint( snake_x_tail - snake_x_after )
                                   + sqrint( snake_y_head - snake_y_after );
                    If (sqrint( snake_x_head - snake_x_after ) +
                        sqrint( snake_y_head - snake_y_after ) ) > ( dist_to_tail*2 )
                    Then If ( Moves_since_Stuck > 10 )
                         and ( Len_snake > 10 )
                         and ( dist_to_tail > 10 )
                         Then Swap_Snake_Head_and_Tail;
                    If (sqrint( You_X - snake_x_head )
                      + sqrint( You_Y - snake_y_head) ) <
                       (sqrint( snake_x_head - snake_x_after )
                      + sqrint( snake_y_head - snake_y_after ) )
                    Then Begin
                         Num_Snake_Searched := 0;
                         snake_x_after := You_X;
                         snake_y_after := You_Y;
                         end;
                    end;
               end
          Else begin
               Num_Snake_Searched := 0;
               If Num_Moves_After_This_Pt > ( 10 + Rand(10))
               Then Begin
                    snake_x_after :=  Rand(21);
                    snake_y_after :=  Rand(78);
                    Num_Moves_After_This_Pt := 0;
                    end
               else Num_Moves_After_This_Pt := Num_Moves_After_This_Pt  + 1;
               end;
          If Not Snake_Got_Stuck
          Then Begin
               snake_x_move := 0;
               snake_y_move := 0;
               If Rand(4) = 1
               then Begin
                    snake_x_move := Sgn(snake_x_after - snake_x_head);
                    If snake_x_move = 0
                    Then snake_y_move := Sgn(snake_y_after - snake_y_head);
                    end
               else begin
                    snake_y_move := Sgn(snake_y_after - snake_y_head);
                    If snake_y_move = 0
                    Then snake_x_move := Sgn(snake_x_after - snake_x_head);
                    end;
               If (( snake_x_move + snake_y_move ) = 0 )
               or
         ( Not ( Screen[snake_x_head+snake_x_move,snake_y_head+snake_y_move].wall in [Created,Other] ))
               or
         (( snake_x_head+snake_x_move = start_x_creat ) and ( snake_y_head+snake_y_move = start_y_creat))
               Then Search_For_Move;
               end
          else search_for_move;
          If ( snake_x_move = 0 ) And ( snake_y_move = 0 )
          Then  Begin
                If Not Snake_got_stuck
                Then Begin
                     If ( Moves_since_stuck > 10 ) and ( Len_snake > 10 )
                     Then begin
                          Swap_snake_Head_and_Tail
                          end
                     else begin
                          lgth_snake_when_stuck  := Len_snake;
                          Snake_got_stuck := true;
                          end;
                     end
                Else If ( Len_Snake < ( lgth_snake_when_stuck  - 10 )) and ( Len_snake > 10 )

                     Then begin
                          Swap_Snake_Head_and_Tail;
                          Moves_since_stuck := 0;
                          Snake_Got_stuck := False;
                          end;
                end
          Else Snake_got_stuck := False;
          Moves_Since_stuck := Moves_since_stuck + 1;
          If  ( Screen[snake_x_head+snake_x_move,snake_y_head+snake_y_move].Wall = Created )
             or
       (( snake_x_head+snake_x_move = You_X ) And ( snake_y_head+snake_y_move = You_Y ) )
          Then begin
               Died := True;
               end;

          end;





       Procedure Remove_tail;

          Begin
          If ( Len_Snake >= Max_Len_Snake ) Or Snake_got_stuck
          Then Begin
               If ( snake_x_tail <> snake_x_head )
               or (snake_y_tail <> snake_y_head)
               Then Begin
                    posxy(snake_x_tail,snake_y_tail,Blank);
                    Save_ch := Screen[snake_x_tail,snake_y_tail].Sym;
                    Screen[snake_x_tail,snake_y_tail].Sym := Blank;
                    Screen[snake_x_tail,snake_y_tail].wall := Other;
                    end;
               If Len_Snake <= 1
               Then Begin
                    Len_Snake  := 1;
                    snake_x_tail := snake_x_head;
                    snake_y_tail := snake_y_head;
                    end
               else begin
                    Case Save_ch  of
                      lch : If Screen[snake_x_tail,snake_y_tail+1].Sym In [kch,jch,qch]
                            Then snake_y_tail := snake_y_tail + 1
                            Else snake_x_tail := snake_x_tail + 1;
                      kch : If Screen [snake_x_tail,snake_y_tail-1].Sym In [lch,mch,qch]
                            Then snake_y_tail := snake_y_tail - 1
                            Else snake_x_tail := snake_x_tail +1 ;
                      mch : If Screen[snake_x_tail,snake_y_tail+1].Sym In [kch,jch,qch]
                            Then snake_y_tail := snake_y_tail + 1
                            Else snake_x_tail := snake_x_tail - 1 ;
                      jch : If Screen[snake_x_tail,snake_y_tail-1].Sym In [mch,lch,qch]
                            Then snake_y_tail := snake_y_tail - 1
                            Else snake_x_tail := snake_x_tail - 1;
                      xch : If Screen[snake_x_tail-1,snake_y_tail].Sym In [lch,kch,xch]
                            Then snake_x_tail := snake_x_tail - 1
                            Else snake_x_tail := snake_x_tail + 1;
                      qch : If Screen[snake_x_tail,snake_y_tail - 1 ].Sym In [ lch,mch,qch]
                            Then snake_y_tail := snake_y_tail - 1
                            Else snake_y_tail := snake_y_tail + 1;
                      Blank,'0' : { Nothing };
                         end { CAse };
                    end;
               Len_Snake := Len_Snake - 1;
               end
          Else posxy(snake_x_tail,snake_y_tail,Screen[snake_x_tail,snake_y_tail].Sym);
          end { remove_Tail};



       Begin
       Swaped_head := False;
       Get_Move_For_Snake;
       If Snake_Got_Stuck
       Then begin
            Remove_tail;
            Get_Move_For_Snake;
            If Snake_Got_Stuck
            Then begin
                 Remove_tail;
                 Get_Move_For_Snake;
                 end;
            end;
       If ( Not Snake_Got_Stuck ) and ( Not Swaped_head )
       Then Begin
            Save_ch := Screen[snake_x_tail,snake_y_tail].Sym;
            If Len_Snake > 2
            Then Screen[snake_x_tail,snake_y_tail].Sym := '%';
            Screen[snake_x_head,snake_y_head].Wall := Snake;
            Screen[snake_x_head,snake_y_head].Sym :=
               Correct_Sym(snake_x_head,snake_y_head,snake_x_head+snake_x_move,snake_y_head+snake_y_move);
            If (( snake_x_head<>snake_x_tail ) or ( snake_y_head<>snake_y_tail ) )
               and
            (Len_Snake > 2)
            Then Screen[snake_x_tail,snake_y_tail].Sym := Save_ch ;
            posxy(snake_x_head,snake_y_head,Screen[snake_x_head,snake_y_head].Sym);
            Len_snake := Len_Snake+1;
            snake_x_head := snake_x_head + snake_x_move;
            snake_y_head := snake_y_head + snake_y_move;
            textcolor(lightmagenta);
            posxy(snake_x_head,snake_y_head,Qix_Head);
            textcolor(lightgray);
            Remove_tail;
            end;
       end; (**** of move_snake ****)




Procedure Move_You;

Var Count,X,Y,Tmp_X,Tmp_Y,LTmp_X,LTmp_Y: Integer;
    ch,save_ch : char;
    Inside_Box,Created_Box : Boolean;

    Procedure Cal_Inside;

    Var X,Y,Last_Y,Sudo_X,Sudo_Y,Lsudo_X,LSudo_Y,Max_X,Min_X,Max_Y,Min_Y: Integer;
        Inside_Box,Written_something : Boolean;

       Procedure Max_Or_Min(X,Y:Integer);

          Begin
          If X > Max_X
          Then Max_X := X
          else If X < Min_X
               Then Min_X := X;
          If Y > Max_Y
          Then Max_Y := Y
          else If Y < Min_Y
               Then Min_Y := Y;
          end;

       procedure minix_maxix;
          (* Diese Prozedur scheint etwas unmotiviert zusammengestellt
             worden zu sein. Der MT+Compiler verlangte aber nach einer
             Kuerzung der aufrufenden Prozedur...   Deshalb!!!!    *)

       var y:integer;

          begin
          Inside_box := False;
          For Y := Min_Y To Max_Y
          Do begin
             If Not ( Screen[X,Y].Wall IN   [Inside,Outside,Snake,Other])
             Then Begin
                  If Screen[X,Y].Sym In [xch,tch]
                  Then If Inside_Box
                       Then Begin
                            Written_something := False;
                            Inside_box := False
                            End
                       else Inside_Box := True
                  else If Screen[X,y].Sym in [kch,jch,uch]
                       Then Begin
                            If Not ( Screen[X,Y].Wall In [TmpN,TmpN2] )
                            Then begin
                                 Written_Something := False;
                                 Inside_Box := False
                                 end
                            else Inside_Box := True;
                            end
                       else begin
                            If Written_Something
                            Then begin
                                 Written_Something := False;
                                 Inside_Box := False
                                 end
                            Else Inside_box := True;
                            end;
                  end
             Else Begin
                  If INside_Box and ( Screen[X,y].wall = Other )
                  Then Begin
                       Amt_Filled_In := Amt_Filled_In + 1;
                       textcolor(yellow);
                       If Not Written_Something
                       Then begin
                            posxy(X,Y,chr($b0));
                            Written_Something := True;
                            end
                       Else Write_Buff(chr($b0));
                       textcolor(lightgray);
                       Screen[X,Y].Wall := Outside;
                       end
                  Else Begin
                       Inside_Box := False;
                       Written_something := False
                       end;
                  end;
             End;
          end;  (* of minix_maxix *)

       procedure teil1;
         (*ebenfalls einigermassen unmotiviert, deshalb auch in der
           Formatierung nicht konsequent, gell?                  *)
       begin


       Sudo_X := snake_x_head;
       Sudo_Y := snake_y_head;
       While Not ( Screen[Sudo_X,Sudo_Y].Wall In [Created,Inside]) Do
         Sudo_X := Sudo_X - 1;
       If Screen[Sudo_X,Sudo_Y].Wall =  Created
       Then Begin
            LSudo_X := Sudo_X;
            LSudo_Y := Sudo_Y;
            Case Screen[Sudo_X,Sudo_Y].Sym Of
              mch ,
              vch ,
              qch : Sudo_Y := Sudo_Y + 1;
              jch : Sudo_X := Sudo_X - 1;
               End { CAse };
            While Screen[Sudo_X,Sudo_Y].Wall = Created
            Do Begin
               Move_Clockwise(Sudo_X,Sudo_Y,LSudo_X,LSudo_Y);
               end;
            end
       Else begin
            LSudo_X := Sudo_X;
            LSudo_Y := Sudo_Y;
            Case Screen[Sudo_X,Sudo_Y].Sym Of
              mch ,
              vch ,
              qch : Sudo_Y := Sudo_Y + 1;
              jch : Sudo_X := Sudo_X - 1;
               End { CAse };
            end;
       While Screen[Sudo_X,Sudo_Y].Wall <> Created
       Do Begin
          Move_Clockwise(Sudo_X,Sudo_Y,LSudo_X,LSudo_Y);
          end;
       (*=Sleep(0,25);=*)


       If ( Sudo_X = start_x_creat ) And ( Sudo_Y = start_y_creat )
       Then Dir_You := Clockwise
       Else Dir_You := AntiClockwise;

       mov_opp_Clockwise(Sudo_X,Sudo_Y,LSudo_X,LSudo_Y);

       Min_X := 9999;
       Min_Y := 9999;
       Max_X := -9999;
       Max_Y := -9999;
       While Screen[Sudo_X,Sudo_Y].Wall <> Created
       Do Begin
          Screen[Sudo_X,Sudo_Y].Wall := Tmp;
          If Screen[Sudo_X,Sudo_Y].Sym = kch
          Then IF ( LSudo_X = Sudo_X + 1)
               Then Screen[Sudo_X,Sudo_Y].wall := TmpN
               else Nope
          else If Screen[Sudo_X,Sudo_Y].Sym = jch
               Then If (LSudo_Y = Sudo_Y - 1)
                    Then Screen[Sudo_X,Sudo_Y].Wall := TmpN
                    else Nope
               else If Screen[Sudo_X,Sudo_Y].Sym = uch
                    Then If (Lsudo_X = Sudo_X + 1 )
                         Then Screen[Sudo_X,Sudo_Y].Wall := TmpN;
          Move_Clockwise(Sudo_X,Sudo_Y,LSudo_X,LSudo_Y);
          Max_Or_Min(Sudo_X,Sudo_Y);
          end;
       (*=Sleep(0,25);=*)
       While ( Screen[Sudo_X,Sudo_Y].Wall = Created )
       Do Begin
          Screen[Sudo_X,Sudo_Y].Wall := TmpCreat;
          If Screen[Sudo_X,Sudo_Y].Sym = kch
          Then IF ( LSudo_X= Sudo_X + 1)
               Then Screen[Sudo_X,Sudo_Y].wall := TmpN2
               else Nope
          else If Screen[Sudo_X,Sudo_Y].Sym = jch
               Then If (LSudo_Y = Sudo_Y - 1)
                    Then Screen[Sudo_X,Sudo_Y].Wall := TmpN2
                    else Nope
               else If Screen[Sudo_X,Sudo_Y].Sym = uch
                    Then If (Lsudo_X = Sudo_X + 1 )
                         Then Screen[Sudo_X,Sudo_Y].Wall := TmpN2;
          Max_Or_Min(Sudo_X,Sudo_Y);
          Move_Clockwise(Sudo_X,Sudo_Y,LSudo_X,LSudo_Y);
          end;
       (*=Sleep(0,25);=*)
       end; (*of Teil1 *)



       Begin
       teil1;
       For X := Min_X To Max_X
       Do begin
          minix_maxix;
          end;
       While Screen[Sudo_X,Sudo_Y].Wall in [Tmp,TmpN]
       Do Begin
          Screen[Sudo_X,Sudo_Y].Wall := Outside;
          Max_Or_Min(Sudo_X,Sudo_Y);
          Move_Clockwise(Sudo_X,Sudo_Y,LSudo_X,LSudo_Y);
          end;
       Amt_Filled_In := Amt_Filled_In - 2;
       While Screen[Sudo_X,Sudo_Y].Wall in [TmpCreat,Created,TmpN2]
       Do Begin
          Amt_Filled_In := Amt_Filled_In + 1;
          Screen[Sudo_X,Sudo_Y].Wall := INside;
          Max_Or_Min(Sudo_X,Sudo_Y);
          Move_Clockwise(Sudo_X,Sudo_Y,LSudo_X,LSudo_Y);
          end;
       If ( Not Marked_Clock_Greeb )
        or
         ( num_mar_clock_greeb > 0 )
       Then Begin   { > 0 If Marked When Inside }
            Marked_Clock_Greeb := True;
            mark_x_clock_greeb := last_x_clock_greeb;
            mark_y_clock_greeb := last_y_clock_greeb;
            num_mar_clock_greeb := 0;
            end;
       If ( Not Marked_Anti_Greeb )
        or
         ( Num_mar_anti_greeb > 0 )
       Then Begin
            Marked_Anti_Greeb := True;
            mark_x_anti_greeb := last_x_anti_greeb;
            mark_y_anti_greeb := last_y_anti_greeb;
            Num_mar_anti_greeb := 0;
            end;
       end;





     Function Val_Mo:Boolean;

       Function Val_Mo_Clockwise(X,Y,LX,LY,NX,NY:Integer):Boolean;

          Begin
          Move_Clockwise(X,Y,LX,LY);
          If ( X = NX ) And ( Y = NY )
          Then Val_MO_Clockwise := True
          Else Val_Mo_Clockwise := False;
          end;

       Function VAl_MO_Anti_Clockwise(X,Y,LX,LY,NX,NY:Integer):Boolean;

          Begin
          Move_Anti_Clockwise(X,Y,LX,LY);
          If ( X = NX ) And ( Y = NY )
          Then Val_MO_Anti_Clockwise := True
          Else Val_Mo_Anti_Clockwise := False;
          end;


       Begin
       If ( You_X = lst_you_X ) And ( You_Y = lst_you_Y )
       Then Begin
            Val_Mo := True;
            If Dir_You = Clockwise
            Then Dir_You := AntiClockwise
            Else Dir_You := Clockwise;
            end
       Else begin
            If Dir_You = Clockwise
            Then begin
                 If Val_Mo_Clockwise(X,Y,lst_you_X,lst_you_Y,You_X,You_Y)
                 Then Val_Mo := True
                 Else Val_Mo := False;
                 End
            Else begin
                 If Val_Mo_Anti_Clockwise(X,Y,lst_you_X,lst_you_Y,You_X,You_Y)
                 Then Val_Mo := True
                 Else Val_Mo := False;
                 end;
            end;

       end;

    procedure esac;

    begin

    Case Screen[You_X ,You_Y].Wall Of
        Other   : Begin
                  If Can_Create_Wall
                  Then Begin
                       If Not Creating_wall
                       Then begin
                            Moves_since_stuck := 999;
                            snake_x_after := 9999;
                            snake_y_after := 9999;
                            start_x_creat := X;
                            start_y_creat := Y;
                            l_start_x_creat := lst_you_X;
                            l_start_y_creat := lst_you_Y;
                            Dir_When_Start_Creat := Dir_You;
                            end;
                       Screen[X,y].Sym  := Correct_Sym(X,Y,You_X,You_Y);
                       Screen[X,Y].wall := Created;
                       Creating_wall    := True;
                       lst_you_X := X;
                       lst_you_Y := Y;
                       end
                  else begin
                       You_X := X;
                       You_Y := Y;
                       end;
                  end;
        Snake   : Begin
                  If ( Can_Create_wall )
                  Then Begin
                       Died := True;
                       If Not Creating_wall
                       Then begin
                            snake_x_after := 9999;
                            snake_y_after := 9999;
                            start_x_creat := X;
                            start_y_creat := Y;
                            l_start_x_creat := lst_you_X;
                            l_start_y_creat := lst_you_Y;
                            Dir_When_Start_Creat := Dir_You;
                            end;
                       Screen[X,y].Sym  := Correct_Sym(X,Y,You_X,You_Y);
                       Screen[X,Y].wall := Created;
                       Creating_wall := True;
                       lst_you_X := X;
                       lst_you_Y := Y;
                       end
                  else begin
                       You_X := X;
                       You_Y := Y;
                       end;
                  end;
        Inside  : Begin
                  If Creating_wall
                  Then begin
                 { Have Created A Box }
                       Creating_wall    := False;
                       Can_Create_wall  := False;
                       Screen[X,Y].Sym  := Correct_Sym(X,Y,You_X,You_Y);
                       Screen[X,Y].Wall := Created;
                       posxy(X,Y,Screen[X,Y].Sym);
                       posxy(You_X,You_Y,You);
                       Screen[You_X,You_Y].Sym  := Correct_Sym(You_X,You_Y,You_X,You_Y);
                       Screen[You_X,You_Y].Wall := Created;
                       Cal_Inside;
                       If Moving_Extra_Greebly
                       Then posxy(extra_x_greeb,extra_y_greeb,Screen[extra_x_greeb,extra_y_greeb].sym);
                       Moving_Extra_Greebly := False;
                       If Amt_Filled_In  > 1228
                       Then  Begin
                             textcolor(white);
                             Score := Score + Amt_Filled_In + ( Amt_Filled_In - 1228);
                             percent:=((amt_filled_in*100) div 1638);
                             posxy(24,8,' '); Str (percent:4,HelpString);
                             Write (HelpString+'%');
                             posxy(24,21,' '); Str (Score:5,HelpString);
                             Write (HelpString);
                             textcolor(lightgray);
                             delay(1500);
                             Ini_Screen;
                             Sleep_Start;
                             end
                       else  begin
                             textcolor(white);
                             percent:=((amt_filled_in * 100) div 1638);
                             posxy(24,8,' '); Str (percent:4,HelpString);
                             Write (HelpString+'%');
                             posxy(24,21,' ');
                             Str ((Score+amt_filled_in):5,HelpString);
                             Write (HelpString);
                             textcolor(lightgray);
                             lst_you_X := X;
                             lst_you_Y := Y;
                             end;
                       end
                  else If Not Val_Mo
                       Then begin
                            You_X := X;
                            You_Y := Y;
                            end
                       Else begin
                            lst_you_X := X;
                            lst_you_Y := Y;
                            end;

                  END;
        Created : Begin
                  If Not Moving_Extra_Greebly
                  Then Begin
                       Moving_Extra_Greebly := True;
                       extra_x_greeb := start_x_creat;
                       extra_y_greeb := start_y_creat;
                       l_extra_x_greeb := l_start_x_creat;
                       l_extra_y_greeb := l_start_y_creat;
                       posxy(extra_x_greeb,extra_y_greeb,chr($0f));
                       end;
                  You_X := X;
                  You_Y := Y;
                  end;
        OutSide : Begin
                  You_X := X;
                  You_Y := Y;
                  end;
             end { Case };
    end;         (* esac *)

    Begin
    Save_ch := Screen[snake_x_tail,snake_y_tail].Sym;
    If Len_Snake > 2
    Then Screen[snake_x_tail,snake_y_tail].Sym := '%';
    X := You_X;
    Y := You_Y;
    You_X := You_X + Move_X;
    You_Y := You_Y + Move_Y;
    esac;
    If ((You_X=snake_x_head) and (You_Y=snake_y_head)) or
     ((You_X=clock_x_greeb) and (You_Y=clock_y_greeb)) or
     ((You_X=anti_x_greeb) and (You_Y=anti_y_greeb))
    Then Died := True;
    If Len_Snake > 2
    Then Screen[snake_x_tail,snake_y_tail].Sym := Save_ch;
    posxy(X,Y,Screen[X,Y].Sym);
    textcolor(LightCyan);
    posxy(You_X,You_Y,You);
    textcolor(Lightgray);
    end;

procedure abort;

   begin
   ClrScr;
   halt(0);
   end;



Procedure Get_move;

var ch,ch_last : integer;

    Begin
    ch := tt_1_char_now;
    IF ch <> 0
    THEN case ch Of
    {' '}  32,13  : Can_Create_Wall := True;
    {'4'}  52,75  : Begin
                    Move_X := 0;
                    Move_Y := -1;
                    end;
    {'6'}  54,77  : Begin
                    Move_X := 0;
                    Move_Y := 1;
                    end;
     {'8'}  56,72 : begin
                    Move_Y :=0;
                    Move_X :=-1;
                    end;
     {'2'}  50,80 : Begin
                    Move_Y := 0;
                    Move_X := 1;
                    end;
     {'h','H'} 27 : begin
                        clrscr;
                        halt(0);
                        end;
                Else Nope{ Nothing } end;

     end;




Procedure Have_Died;

Var Dummy,LSudo_X,LSudo_Y,Sudo_X,Sudo_Y : Integer;
    Save_Sym : Char;

    Begin
    Died := False;
    Lives := Lives - 1;
    If Lives > 0
    Then Begin
         If Creating_wall
         Then Begin
              If Moving_Extra_Greebly
              Then posxy(extra_x_greeb,extra_y_greeb,Screen[extra_x_greeb,extra_y_greeb].Sym);
              Moving_Extra_Greebly := False;
              Save_sym := Screen[snake_x_tail,snake_y_tail].Sym;
              Sudo_X := lst_you_X;
              Sudo_Y := lst_you_Y;
              LSudo_X := You_X;
              LSudo_Y := You_Y;
              posxy(LSudo_X,LSudo_Y,Screen[You_X,You_Y].Sym);
              Move_Clockwise(Sudo_X,Sudo_Y,Lsudo_X,LSudo_Y);
              While Screen[Sudo_X,Sudo_Y].Wall <> Inside
              do begin
                 posxy(LSudo_X,LSudo_Y,Blank);
                 Screen[LSudo_X,LSudo_Y].Sym := Blank;
                 Screen[LSudo_X,LSudo_Y].Wall := Other;
                 Move_Clockwise(Sudo_X,Sudo_Y,Lsudo_X,LSudo_Y);
                 end;
              Creating_wall := False;
              If ( snake_x_head <> snake_x_tail )
               or
                ( snake_y_head <> snake_y_tail )
              Then Screen[snake_x_tail,snake_y_tail].Sym := '%';
              Screen[LSudo_X,LSudo_Y].Sym := Correct_sym(LSudo_X,LSudo_Y,LSudo_X,LSudo_Y);
              If ( snake_x_head <> snake_x_tail ) or ( snake_y_head <> snake_y_tail )
              Then Screen[snake_x_tail,snake_y_tail].Sym := Save_sym;
              Screen[LSudo_X,LSudo_Y].Wall := Inside;
              posxy(LSudo_X,LSudo_Y,Screen[LSudo_X,LSudo_Y].Sym);
              You_X := start_x_creat;
              You_Y := start_y_creat;
              lst_you_X := l_start_x_creat;
              lst_you_Y := l_start_y_creat;
              Dir_You := Dir_When_Start_Creat;
              end;
        sound_bell;
        posxy(snake_x_head,snake_y_head,Qix_Head);
        posxy(You_X,You_Y,You);
        posxy(clock_x_greeb,clock_y_greeb,Screen[clock_x_greeb,clock_y_greeb].Sym);
        posxy(anti_x_greeb,anti_y_greeb,Screen[anti_x_greeb,anti_y_greeb].Sym);
        posxy(24,34,' ');
        Write('       ');
        posxy(24,34,' ');
        textcolor(lightcyan);
        For Dummy := 1 to Lives Do Write(' '+chr(1));
        textcolor(lightgray);
        Can_Create_wall := False;
        For Dummy := 1 to 4 do
          Move_Greeblys;
        end;
    end;


(**********MAIN PROGRAM*******************************************)
Begin

randomize;
ClrScr;
LowVideo;
Default_speed := $FF;
gotoxy(1,9);
writeln('      ‹‹‹‹‹    ‹‹‹‹‹  ‹     ‹               ‹‹‹‹‹    ‹‹‹‹‹     €  ‹‹‹‹‹ ');
writeln('     €     €     €     €   €               €     €  €     €   €  €     €');
writeln('     €     €     €      ﬂ‹ﬂ                €     €  ﬂ‹‹‹      €       ‹ﬂ');
writeln('     €     €     €      ‹ﬂ‹                €     €      ﬂﬂ‹  €    ‹ﬂﬂﬂ  ');
writeln('     €   ﬂ‹€     €     €   €    '+Version+' for    €     €  €     €  €   €      ');
writeln('      ﬂﬂﬂﬂﬂ €  ﬂﬂﬂﬂﬂ  ﬂ     ﬂ               ﬂﬂﬂﬂﬂ    ﬂﬂﬂﬂﬂ  €    ﬂﬂﬂﬂﬂﬂﬂ');

    REPEAT
    IF Play_Again <> chr(13)
    THEN BEGIN
         gotoxy(50,1);
         textcolor(rand(16));
         write('QIX for OS/2 (32bit) Ver. '+Version);
         textcolor(Yellow);
         posxy(23,19,'D');
         Write ('ifficulty level (1..5, 1=Slow, 5=Fast) ? ');
         textcolor(LightGray);
         REPEAT
           Play_Again := Chr (tt_1_char_now);
           IF play_again = chr(27) THEN begin abort end;
         UNTIL (Play_Again IN ['1'..'5']) OR
               ((Play_Again = Chr($0d)) AND (Default_Speed < 6));
         END;

    IF Play_Again = Chr($0d)
    THEN Game_Speed := Default_Speed
    ELSE BEGIN
         Game_Speed := ord('5') - ord(Play_Again);
         Default_Speed := Game_Speed;
         END;

    Initalise;
    Sleep_Start;

    Repeat
      Delay (Game_Speed*20+1);
      Get_move;
      Move_You;
      If Not Died
      Then Begin
           Move_snake;
           Move_Greeblys;
           If ( Rand(Level) >= 4 ) and ( Not Died )
           Then Begin
                Move_Greeblys;
                If ( rand(Level) >= 5 ) and ( Not Died )
                Then Begin
                     Move_Snake;
                     If ( rand(Level) >= 6 ) and ( Not Died )
                     Then Begin
                          Move_Greeblys;
                          If ( rand(Level) >= 7 ) and ( Not Died )
                          Then Begin
                               Move_snake;
                               If ( rand(Level) >= 8 ) and ( Not Died )
                               Then Begin
                                    Move_Greeblys;
                                    If ( rand(Level) >= 9 ) and ( Not Died )
                                    Then Begin
                                         Move_Snake;
                                         end;
                                    end;
                               end;
                          end;
                     end;
                end;
           end;
      (*Sleep_wait;********)
      If Died
      Then Have_Died;
    until Lives <= 0;
(*
    sleep(3,0);
*)
    Score := Score + Amt_Filled_In;

    QixStat(Score);
    gotoxy(50,24);
    textcolor(rand(16));
    write('QIX for OS/2 (32bit) Ver. '+Version);
    textcolor(LightGray);
    posxy(22,30,'P'); Write ('lay again ? (Y/N) ');
    REPEAT
        PLAY_AGAIN := CHR(TT_1_CHAR_NOW);
        IF play_again = chr(27) THEN abort;
    UNTIL   PLAY_AGAIN IN ['Y','y','n','N',chr(13)];
    clrscr;
    count := count +1;
UNTIL (PLAY_AGAIN IN ['N','n']) or (Count>=50);
writeln;
writeln('Bye, bye, from QIX '+Version+' for OS/2 (32bit).');
writeln;
writeln('... and keep on WARPing!');
end.
