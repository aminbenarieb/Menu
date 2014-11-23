program Menu;

{$APPTYPE CONSOLE}

uses
  SysUtils, StrUtils, Math, Windows;

const
  Alphabet = ['�'..'�', '�'..'�'];
  Rome     = ['I','V','X', 'L', 'C', 'D', 'M'];
  Signs    = ['?', '.', '!'];
  N = 7;
  ScreenWidth = 70;

type
  TSet       = TSysCharSet;
  TText      = array [1..N] of String;
  MProcedure = procedure(var Str:String; Word:String);

var
  BText: TText =
  ('���������� � ���������� ����, ���������� � ������. ������ ������� X ',
   '������� MMVI ����. �� ������ �� ������ MMXIV ���� ���������� ��������� ',
   '���������� � ����� LX ��������� �������, � ����������� ����� CCCXIV ��� ',
   '�����������. ������� ���������� II �� ������������ ���� � ������, ',
   '���������� � ����������, III��� �� ���������� �������, XXIII-� � � ����. ',
   '������ �������� ���������� ����� IV ���� ������, � ������ ������� ',
   'CXXXVII ��� ������ �� ������ ���� �� MMXIII ���.');
  Max, Count : Integer;
  MaxWord, CWord : String;
  Input : Char;

// ��������� ��������� ���� � �������� ����������
procedure ProcessWords(var Str:String;  WSet:TSet; Process:MProcedure);
var
 I : Integer;
 Word : String;
begin
    for I := 1 to Length(Str) do
    begin
      if Str[I] in WSet then
         Word := Word + Str[I]
      else
      begin
        if Word <> '' then
          Process(Str,Word);
        Word := '';
      end;
    end;
end;
// ��������� ������� ������ ������� � ������ ������
procedure CleanScreen;
// ������� ���������� ������ ���������� ���������� X � Y
function Coord(X, Y: SmallInt): TCoord;
  begin
  Result.X := X;
  Result.Y := Y;
  end;
var
  ConsoleOutput: THandle;
  ConsoleScreenBufferInfo: TConsoleScreenBufferInfo;
  NumberOfCharsWritten: DWORD;
begin
  ConsoleOutput := GetStdHandle(STD_OUTPUT_HANDLE);
  
  GetConsoleScreenBufferInfo(ConsoleOutput, ConsoleScreenBufferInfo);

  FillConsoleOutputCharacter(ConsoleOutput, ' ',
    ConsoleScreenBufferInfo.dwSize.X * ConsoleScreenBufferInfo.dwSize.Y,
    Coord(ConsoleScreenBufferInfo.srWindow.Left,
          ConsoleScreenBufferInfo.srWindow.Top),
    NumberOfCharsWritten);
    
  SetConsoleCursorPosition(ConsoleOutput,
    Coord(ConsoleScreenBufferInfo.srWindow.Left,
    ConsoleScreenBufferInfo.srWindow.Top));
end;
procedure PrintText(Text : TText);
var I : Integer;
begin
  for I := 1 to N  do
    Writeln(Text[I]);
end;
procedure PrintSentence(Str:String);
var I : Integer;
begin
  for I := 1 to Length(Str) do
  begin
    Write(Str[I]);
    if (I mod ScreenWidth) and (Str[I] = ' ') then
      Writeln;
  end;
end;
//* ---------------------- ������ ���� ---------------------- *//

// ��������� �������������� ������� ���� � �������� (����������)
function fromRomanToDecimal(Rome: String): String;
var
  I, A, N, N2, Number : Integer;
  S : String;
begin
  N := 0;
  Number := 0;
  for I := 1 to Length(Rome) do
  begin
    N2 := N;
    S := UpperCase(Rome[I]);
    if S = 'I' then N := 1;
    if S = 'V' then N := 5;
    if S = 'X' then N := 10;
    if S = 'L' then N := 50;
    if S = 'C' then N := 100;
    if S = 'D' then N := 500;
    if S = 'M' then N := 1000;
    if N > N2 then
      A := -2 * N2
    else
      A := 0;
    Number := Number + A + N;
  end;
  fromRomanToDecimal := IntToStr(Number);
end;
procedure ReplaceRomeForArabic (var Str:String; Word:String);
var P : Integer;
begin
  P := Pos(Word, Str);
  Delete(Str, P, Length(Word));
  Insert(fromRomanToDecimal(Word), Str, P);
end;
procedure ProcessRome(cText:TText);
var
  Q, I, J, L, P: Integer;
  RomeWord : String;
begin
  for Q := 1 to N do
  begin
    L := Length(cText[Q]);
    J := 1;
    I := 1;
    ProcessWords(cText[Q], Rome,ReplaceRomeForArabic);
  end;
  printText(cText);
  Writeln(#10);
end;

// ��������� � ������� ��� ������ �������� ������������� ����� � ������
procedure IncIfEqualToWord(var Str:String; W:String);
begin
  if CWord = W then Inc(Count);
end;
function  getFrequencyOfWord(Str:string; W : String):Integer;
begin
  Count := 0;
  CWord := W;
  ProcessWords(Str, Alphabet, IncIfEqualToWord);
  Result := Count;
end;
procedure findMaxWord (var Str:String; Word:String);
begin
   Count :=  getFrequencyOfWord(Str, Word);
   if Count > Max then
   begin
     Max := Count;
     MaxWord := Word;
   end;
end;
procedure ProcessFrequency;
var
  Q, S: Integer;
  Sentence : String;
begin
  Writeln(#10, '������ ���������� � ����� ������������� ������ � ������: ');
  Max := 0;
  for Q := 1 to N do
    for S:=1 to Length(bText[Q]) do
      if not (bText[Q][S] in Signs)  then
        Sentence := Sentence + bText[Q][S]
      else
      begin
        if Sentence <> '' then
        begin
          ProcessWords(Sentence, Alphabet, findMaxWord);
          PrintSentence(Concat('"', Trim(Sentence),'".', ' == "',
           MaxWord,'" ', IntToStr(Max),' ���',
          IfThen((Max > 1)and(Max<5),'�',''),'.'));
        end;
        MaxWord  := '';
        Max      := 0;
        Sentence := '';
      end;
  Writeln(#10);
end;

// ��������� ������ ����������� � ���������� ����������� �����������
procedure IncIfPalandrom (var Str:String; Word:String);
begin
  if (Word = ReverseString(Word)) then
    Inc(Count);
end;
procedure ProcessPalandrom;
var
  Q, S: Integer;
  MaxSentence, Sentence : String;
begin    
  Max := 0;
  Count := 0;
  for Q := 1 to N do
  begin
    for S:=1 to Length(bText[Q]) do
    begin
      Count := 0;
      if not (bText[Q][S] in Signs)  then
        Sentence := Sentence + bText[Q][S]
      else
      begin
        if Sentence <> '' then
          ProcessWords(Sentence, Alphabet, IncIfPalandrom);
        if Count > Max then
        begin
          Max := Count;
          MaxSentence := Sentence;
        end;
        Sentence := '';
      end;
    end;
  end;
  Writeln(#10, '����������� � ���������� ����������� ���� �����������:', #10,
           '"',Trim(MaxSentence),'"', #10, #10);
end;

begin
  while Input <> '5' do
  begin
     Writeln('�������: ');
     Writeln(' 1 - ����� ����� �������� ������������� �����');
     Writeln(' 2 - ����� �������� ������� ����� �� ��������');
     Writeln(' 3 - ����� ����� ����������� � ���������� �����������'+
               ' ���� �����������');
     Writeln(' 4 - �������� �����');
     Writeln(' 5 - �����');
     Readln(Input);
     Writeln(#10);
     printText(bText);
     Writeln;
     case Input of
       '1' : ProcessFrequency;
       '2' : ProcessRome(BText);
       '3' : ProcessPalandrom;
       '4' : CleanScreen;
      end;
   end;
end.
