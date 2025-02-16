unit Translator;

interface

uses SysUtils;

type
   TText = Array of String;
   SNumber = Record
     S : WideString;
     N : Word;
     D : Boolean; //���� ��������.
   End;
   VInteger = Record
     S : WideString;
     N : Integer;
   End;
   TElement = Object
     Picture : WideString;
     Height,Width,Top,Left,Smode,Color : Integer;
     procedure Init;
   End;
   TBlock = object
     //Init : Boolean;
     Image,Title : String;
     Sound : String;
     Text : TText;
     Format : Byte;  //1- ���������� ���� 2-����� 3-����� ����  4- ������� ����.  5- �������� ����� ����.
     Next : Array of SNumber;
     BattleScore : SmallInt;
     procedure SetImage(S:String);
     procedure AddTitle(S:String);
     procedure AddText(S:String;M:Boolean=True);
     procedure AddNext(S:String;Number:Integer;Dis:Boolean=False);
     procedure Init(N:Integer=7);
     procedure Logic; //���������� ��������
     procedure Battle(S:String);
     procedure SetBattleScore(A:SmallInt);
     procedure Map;
     procedure Code;
     procedure Game;
     procedure Disable(i:Integer);
   end;
var
  Blocks    : Array of TBlock;
  Operators : TText;//array [0..30] of string; //������ ����������
  Story     : TText;
  CodBattle : TText;
  OutPut,Errlog  : TText;
  f         : System.text;
  //� ����������
  CurrentBlock : Integer = 0;
  //Level        : Integer = 0; //Easy
  ScoreMan     : Integer = 0;
  ScoreBot     : Integer = 0;
  Variables    : Array of VInteger; // ����������� � ���� �����������.  CurrentBlock - 0 , Level - 1;
  FLImages     : Array [0..10] of TElement; //0- Form 1..5- Label 6..9 -Images
  CurrSound    : String = '';
  CurrImage    : String = '';

Procedure FileToText(S:String; var Dump:TText);
//Procedure UFileToText(S:String; var Dump:TText);
function FindStrWithOperator(var Dump : TText; Number : Integer) : Integer;
function FindOperator(S:String; Number:Integer; pos:Integer=1; LowerCaseFlag:Boolean=False) :Integer;
function FindLastOperator(S:String; Number:Integer; pos:Integer=-1) :Integer;
Function CheckVariable(i,j:Integer):Integer; overload;
Function CheckVariable(S:String;j:Integer):Integer; overload;
procedure BLoad(S:String);
procedure BSave(S:String);
function GetStringWithOperator(var S:String;Number:Integer;P:Integer=1):String;
Procedure AddTText(var T:TText; S:String);
function DeleteSpaceBars(S:String; Mode:Integer):String;
function FindVariable(S:String):Integer;
function Substitute(const S:String;N,M:Integer):String;
function ToCycle(var S:String;N:Integer):Integer;
function DowntoCycle(var S:String;N:Integer):Integer;
function FindSpaceBar(var S:String; Pos :Integer; Invert:Boolean=False):Integer;

implementation
Function CheckVariable(i,j:Integer):Integer;
begin
   Operators[37] := Variables[j].S;  //�������� �������� Level
   result := FindOperator(Blocks[CurrentBlock].Text[i],37); //�������� ����� ����������
end;

Function CheckVariable(S:String;j:Integer):Integer;
begin
  Operators[37] := Variables[j].S;
  result := FindOperator(S,37);
end;

function FindOperator;
var i,High:Integer;
begin
  if LowerCaseFlag then S:=LowerCase(S);
  High := Length(s)-Length(Operators[Number])+1; //����� �� +1?
  if Length(S)<2 then
    begin
      Result := -1;
      exit;
    end;
  for I := pos to High do
    if (s[i]=Operators[Number,1]) and (Copy(S,i,Length(Operators[Number]))=Operators[Number]) then
      begin
        Result := i;
        Break;
      end;
  if i>High then  Result := -1;
end;

function FindSpaceBar;
  begin
    if not Invert then result := ToCycle(S,Pos)
              else result := DownToCycle(S,Pos);
    if (result>Length(S))then result := -1;
  end;

function FindLastOperator;
var i,High:Integer;
begin
  High := Length(s)-Length(Operators[Number])+1;
  if Length(S)<2 then
    begin
      Result := -1;
      exit;
    end;
  if pos>High then pos := High;
  if pos<0 then pos := High;

  for I := pos downto 0 do
    if (s[i]=Operators[Number,1]) and (Copy(S,i,Length(Operators[Number]))=Operators[Number]) then
      begin
        Result := i;
        Break;
      end;
  if i<0 then  Result := -1;
end;

function FindStrWithOperator;
var i,a:Integer;
begin
  result := -1;
  for i := 0 to High(Dump) do
    begin
      a:=FindOperator(Dump[i],Number);
      if a>-1 then
        begin
          result := i;
          exit;
        end;
    end;
end;

function GetStringWithOperator;
var
Buf : String;
Pos : Integer;
begin
   Pos := FindOperator(S,Number,P);
   if Pos=-1 then result := ''
   else
     begin
       Buf := Copy(S,Pos+1,Length(S)-Pos);
       Pos := FindOperator(Buf,Number);
       if Pos=-1 then result := Buf
       else result:= Copy(Buf,1,Pos-1);
     end;
end;



Procedure FileToText(S:String;var Dump:TText);
var s1:Ansistring;
begin
  Assignfile(f,s); //������ ����������
  Reset(f);
  SetLength(Dump,0);
  while not eof(f) do
    begin
      readln(f,s1);
      SetLength(Dump,Length(Dump)+1);
      Dump[Length(Dump)-1] := UTF8ToWideString(s1);
    end;
 if Dump[0,1]=#$FEFF then Dump[0] := Copy(Dump[0],2,Length(Dump[0])-1);
 closeFile(f);
end;

 {
Procedure UFileToText(S:String;var Dump:TText);
var s1:Widestring;
begin
  Assignfile(f,s); //������ ����������
  Reset(f);
  while not eof(f) do
    begin
      readln(f,s1);
      SetLength(Dump,Length(Dump)+1);
      Dump[Length(Dump)-1] := UTF8ToWideString(s1);
    end;
    if Dump[0,1]=#$FEFF then Dump[0] := Copy(Dump[0],2,Length(Dump[0])-1);
closeFile(f);
end;
}

procedure TBlock.SetImage;
begin
  Image := S;
end;

procedure TBlock.AddTitle(S: string);
begin
   Title := S;
end;

procedure TBlock.AddText;
var i,l,f: Integer;
begin
  L:=Length(Text);
  if M then
    begin
      F:=FindOperator(S,20);
      if f>0 then
        begin
          for I := 1 to 3 do  S[i]:=' ';
          SetLength(Text,l+1);
          Text[l] :='';
          inc(l);
        end;
    end;
  SetLength(Text,l+1);
  Text[l] := S;
end;

procedure TBlock.Init;
begin
  Image := '';
  Title := '';
  Sound := '';
  SetLength(Text,0);
  Format := 0; //������������� ����
  SetLength(Next,0);
  BattleScore := N;
end;

procedure TBlock.AddNext;
begin
  if Length(Next)>4 then  exit;
  SetLength(Next,Length(Next)+1);
  Next[High(Next)].S := S;
  Next[High(Next)].N := Number;
  Next[High(Next)].D := Dis;
end;

procedure TBlock.Logic;
begin
   Format := 1;
end;

procedure TBlock.Battle(S: string);
begin
  Format := 2;
  Title := S;
end;

procedure TBlock.SetBattleScore(A: SmallInt);
begin
  BattleScore := A;
end;

Procedure TBlock.Map;
begin
  Format := 3;
end;

Procedure TBlock.Code;
begin
  Format := 4;
end;

Procedure TBlock.Game;
begin
  Format := 5;
end;

Procedure TBlock.Disable;
begin
  if i<Length(Next) then Next[i].D := True;
end;

Procedure TElement.Init;
begin
  Picture := '';
  Height  := -1;
  Width   := -1;
  Left    := -1;
  Top     := -1;
  Smode   := 0;
  Color   := -1;
end;


Procedure BLoad;
var a,b,i : Integer;
Buf:String;
begin
  AssignFile(F,S);
  Reset(F);
  Readln(F,CurrentBlock);
  Readln(F,Variables[1].N);
  Readln(F,Scoreman);
  Readln(F,Scorebot);
  Readln(F,CurrImage);
  Readln(F,CurrSound);
  while not Eof(F) do
    begin
     Readln(F,Buf);
      a := FindOperator(Buf,0);
      if a>-1 then
        begin
          for i := 0 to High(Variables) do
            begin
              b := CheckVariable(Buf,i);
              if b>-1 then
                begin
                  b := FindOperator(Buf,5);
                  Buf := Copy(Buf,a+2,b-a-2);
                  Variables[i].N := StrToInt(Buf);
                  break;
                end;
            end;
        end;
    end;
 CloseFile(F);
end;

Procedure BSave;
var i:Integer;
begin
  AssignFile(F,S);
  Rewrite(F);
  Writeln(F,CurrentBlock);
  Writeln(F,Variables[1].N);
  Writeln(F,Scoreman);
  Writeln(F,Scorebot);
  Writeln(F,CurrImage);
  Writeln(F,CurrSound);
  for i := 2 to High(Variables) do
    if Variables[i].N<>0 then Writeln(F,Variables[i].S+':='+IntToStr(Variables[i].N)+';');
  CloseFile(F);
end;

Procedure AddTText;
begin
  SetLength(T,Length(T)+1);
  T[High(T)] := S;
end;

function ToCycle(var S:String;N:Integer):Integer;
var i:Integer;
begin
   if N=-1 then
     begin
       result := -1;
       N      :=  1;
     end
   else result := Length(S)+1;
   for I := N to Length(S) do
     if (S[i]<>' ') and (S[i]<>#9) xor (result>0) then
      begin
        result:=i;
        break;
      end;
end;

function DowntoCycle(var S:String;N:Integer):Integer;
var i:Integer;
begin
   result := -1;
   if N<0 then N:= Length(S)
          else result := 1;
   for I := N downto 1 do
     if (S[i]<>' ') and (S[i]<>#9) xor (result=1) then
      begin
        result:=i; // ���� i+1 ,����� ������ �� �������.
        break;
      end;
end;


function DeleteSpaceBars(S:String; Mode:Integer):String;// ������� ��������
var a,b:Integer;
begin

   case Mode of
     0:      // ___Vasa_123__  ---->Vasa_123
       begin
         a := ToCycle(S,-1);
         b := DowntoCycle(S,-1);
       end;
     1:    // ___Vasa_123__  ---->Vasa
        begin
         a := ToCycle(S,-1);
         b := ToCycle(S,a)-1;
        end;
     2:      // ___Vasa_123__  ---->_123
       begin
         b := DownToCycle(S,-1);
         a := DownToCycle(S,b);
        end;
     else
       begin
         a := -1;
         b := -1;
       end;
   end;

 if (a<0) or (b<0) or (a>b) then result := ''
 else result := Copy(S,a,b-a+1);
end;

Function FindVariable;      //����� ���������� �� ������
var i:Integer;
begin
  result := -1;
  for I := 0 to High(Variables) do
      if S = Variables[i].S then
         begin
           result := i;
           exit;
         end;
end;

function Substitute;
var
a : Integer;
begin
  a := FindOperator(S,N);
  if a>-1 then  result := Copy(S,1,a-1)+Operators[M]+Copy(S,a+1,Length(S)-a)
  else result := S;
end;


end.
