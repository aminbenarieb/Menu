program Menu;

{$APPTYPE CONSOLE}

uses
  SysUtils, StrUtils, Windows;

const
  Alphabet = ['а'..'я', 'А'..'Я'];
  Rome     = ['I','V','X', 'L', 'C', 'D', 'M'];
  Signs    = ['?', '.', '!'];
  N = 5;

type
  TText = array [1..N] of String;

var
  BText: TText =
 (('За свою карьеру я пропустил более MMXVII бросков. Проиграл почти CCCXDVII игр.'),
 ('XXVI раз мне доверяли сделать финальный победный бросок. И я промахивался.'),
 ('Я терпел поражения снова, и снова, и снова. (Майкал Джордан).'),
 ('Они спрашивают: Как ты можешь управиться со всеми делами за XV?'),
 ('Я отвечаю: Это просто. Надо не терять ни I секунды. (Ричард Бренсон)."'));

// Функция возвращает кол-во повторений заданного слова в тексте
function getWordFrequencyOfWord(W : String):Integer;
var
  Q, I,J,L,K : Integer;
  Word : String;
begin
  Q := 1;       
  K := 0;
  for Q := 1 to N do
  begin
    L := Length(bText[Q]);
    J := 1;
    I := 1;
    while I <= L do
    begin
      Word := '';
      for J := I to L do
        if bText[Q][J] in Alphabet then
          Word := Word + bText[Q][J]
        else
          break;
      if Word = W then Inc(K);
      I := J+1;
    end;
  end;
    Result := K;
end;
// Функция переводит римское число к десятичному виду и возращает строку
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
// Функция возвращает запись содержащую координаты X и Y
function Coord(X, Y: SmallInt): TCoord;
begin
  Result.X := X;
  Result.Y := Y;
end;
// Процедура печати текста
procedure printText(Text : TText);
var I : Integer;
begin
  for I := 1 to N  do
    Writeln(Text[I]);
end;
// Процедура преобразования римских цифр в арабские (десятичные)
procedure ProccessRome(cText:TText);
var
  Q, I, J, L, P: Integer;
  RomeWord : String;
begin
  for Q := 1 to N do
  begin
    L := Length(cText[Q]);
    J := 1;
    I := 1;
    while I <= L do
    begin
      RomeWord := '';
      for J := I to L do
        if cText[Q][J] in Rome then
          RomeWord := RomeWord + cText[Q][J]
        else
          break;
      if RomeWord <> '' then
      begin
        P := Pos(RomeWord, cText[Q]);
        Delete(cText[Q], P, Length(RomeWord));
        Insert(fromRomanToDecimal(RomeWord), cText[Q], P);
        J := J -2;
      end;
      I := J+1;
    end;
  end;
  printText(bText);
  Writeln;
  printText(cText);
end;
// Процедура поиска наиболее встечающегося слова в тексте
procedure ProccessFrequency;
var
  Q,I, J, L, Count, Max: Integer;
  MaxWord, Word : String;
begin
  for Q := 1 to N do
  begin
    L := Length(bText[Q]);
    J := 1;
    I := 1;
    Max := 0;
    while I <= L do
    begin
      Word := '';
      for J := I to L do
        if bText[Q][J] in Alphabet then
          Word := Word + bText[Q][J]
        else
          break;

      if (Word <> '') then
      begin
        Count :=  getWordFrequencyOfWord(Word);
        if ((Max = 0) or (Count > Max)) then
        begin
          Max := Count;
          MaxWord := Word;
        end;
      end;
      I := J+1;
    end;
  end;
  printText(bText);
  Writeln('Наиболее часто встречающиеся слово: "', MaxWord,'". Аж ',Max,' раз!');
  Writeln;
end;
// Процедура поиска предложения с наибольшим количеством палендромов
procedure ProccessPalandrom;
var
  Q, P, K, I, J, L, Count, Max: Integer;
  MaxSentence, Sentence, Word : String;
begin    
  Max := 0;
  for Q := 1 to N do
  begin
    L := Length(bText[Q]);
    P := 1;
    K := 1;
    while P <= L do
    begin
      Sentence := '';
      Count := 0;
      J := 1;
      I := 1;
      for K := P to L do
        if not (bText[Q][K] in Signs) then
          Sentence := Sentence + bText[Q][K]
        else
          break;
      if Sentence <> '' then
        while I <= Length(Sentence) do
        begin
          Word := '';
          for J := I to Length(Sentence) do
            if Sentence[J] in Alphabet then
              Word := Word + Sentence[J]
            else
              break;
          if (Word <> '') and (Word = ReverseString(Word)) then
            Inc(Count);
          I := J+1;
        end;
      Writeln(Sentence);
      if Count > Max then
      begin
        Max := Count;
        MaxSentence := Sentence;
      end;
      P := K+1;
    end;
  end;
  printText(bText);
  Writeln;
  Writeln('Предложение с наибольшем количеством слов палендромов:', #10,
           '"',Trim(MaxSentence),'"');
  Writeln;
end;
// Процедура очистки экрана консоли
procedure CleanScreen;
var
//  I: integer;
  ConsoleOutput: THandle;
  ConsoleScreenBufferInfo: TConsoleScreenBufferInfo;
  NumberOfCharsWritten: DWORD;
begin
//  for I := 1 to ScreenLines do
//    Writeln;
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
// Процедура показы меню
procedure ShowMenu;
var
  Input : Char;
begin
   while Input <> '5' do
   begin
     Writeln('Введите: ');
     Writeln(' 1 - чтобы найти наиболее встречающееся слово');
     Writeln(' 2 - чтобы заменить римские цифры на арабские');  
     Writeln(' 3 - чтобы найти предложение с наибольшем количеством'+
               ' слов палендромов');
     Writeln(' 4 - очистить экран');
     Writeln(' 5 - выйти');
     Readln(Input);
     case Input of
       '1' : ProccessFrequency;
       '2' : ProccessRome(BText);
       '3' : ProccessPalandrom;
       '4' : CleanScreen;
      end;
   end;
end;

begin
  ShowMenu;
end.
