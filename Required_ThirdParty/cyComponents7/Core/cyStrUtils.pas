{   Unit cyStrUtils

    Description:
    Unit with string functions.

    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    $  ��� Accept any PAYPAL DONATION $$$  �
    $      to: mauricio_box@yahoo.com      �
    ����������������������������������������

    * ***** BEGIN LICENSE BLOCK *****
    *
    * Version: MPL 1.1
    *
    * The contents of this file are subject to the Mozilla Public License Version
    * 1.1 (the "License"); you may not use this file except in compliance with the
    * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
    *
    * Software distributed under the License is distributed on an "AS IS" basis,
    * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
    * the specific language governing rights and limitations under the License.
    *
    * The Initial Developer of the Original Code is Mauricio
    * (https://sourceforge.net/projects/tcycomponents/).
    *
    * Donations: see Donation section on Description.txt
    *
    * Alternatively, the contents of this file may be used under the terms of
    * either the GNU General Public License Version 2 or later (the "GPL"), or the
    * GNU Lesser General Public License Version 2.1 or later (the "LGPL"), in which
    * case the provisions of the GPL or the LGPL are applicable instead of those
    * above. If you wish to allow use of your version of this file only under the
    * terms of either the GPL or the LGPL, and not to allow others to use your
    * version of this file under the terms of the MPL, indicate your decision by
    * deleting the provisions above and replace them with the notice and other
    * provisions required by the LGPL or the GPL. If you do not delete the
    * provisions above, a recipient may use your version of this file under the
    * terms of any one of the MPL, the GPL or the LGPL.
    *
    * ***** END LICENSE BLOCK *****}

unit cyStrUtils;

interface

uses
  {$IFDEF UNICODE}
  classes, SysUtils, Character;
  {$ELSE}
  classes, SysUtils;
  {$ENDIF}

type
  TStrLocateOption = (strloCaseInsensitive, strloPartialKey);
  TStrLocateOptions = set of TStrLocateOption;
  TStringRead = (srFromLeft, srFromRight);
  TStringReads = Set of TStringRead;
  TCaseSensitive = (csCaseSensitive, csCaseNotSensitive);
  TWordsOption = (woOnlyFirstWord, woOnlyFirstCar);
  TWordsOptions = Set of TWordsOption;
  TCarType = (ctAlphabeticUppercase, ctAlphabeticLowercase, ctNumeric, ctOther);
  TCarTypes = Set of TCarType;

{$IFDEF UNICODE}
  TUnicodeCategories = Set of TUnicodeCategory;
{$ENDIF}

  TMaskPartType = (mtUndefined, mtMaskPartStringValue, mtMaskPartCustomChars, mtAnyChars, mtAlphaNumChars, mtNumbers, mtOptionalNumbers, mtAlphaChars, mtUppLetters, mtLowLetters, mtOtherChars);



const
  CarTypeAlphabetic = [ctAlphabeticUppercase, ctAlphabeticLowercase];

  WebSiteLetters = ['/', ':', '.', '_', '-', '0'..'9', 'a'..'z', 'A'..'Z'];
  WebMailletters = ['a'..'z', '@', '.', '_', '-', '0'..'9', 'A'..'Z'];

{$IFDEF UNICODE}
  CharCategoriesNumbers = [TUnicodeCategory.ucDecimalNumber];
  CharCategoriesLetters = [TUnicodeCategory.ucLowercaseLetter, TUnicodeCategory.ucUppercaseLetter];
  CharCategoriesLetters_Space = [TUnicodeCategory.ucLowercaseLetter, TUnicodeCategory.ucUppercaseLetter, TUnicodeCategory.ucSpaceSeparator];
{$ENDIF}

  // Mask :
  cQuoteChar = '''';

  MaskBeginCustomChars = '[';
  MaskEndCustomChars   = ']';
  MaskAnyChar          = '*';
  MaskAlphaNumChar     = 'X';
  MaskNumber           = '0';
  MaskoptionalNumber   = '9';
  MaskAlphaChar        = 'A';
  MaskUppercaseChar    = 'U';
  MaskLowercaseChar    = 'L';
  MaskOtherChar        = 'S';

  MaskRulesMsg =
   '''Hello''   - string ''Hello'' (quoted) expected' + #13#10 +
   '[;,-]  - Custom chars set ";,-" expected'         + #13#10 +
   '%      - Optional char for custom chars set'      + #13#10 +
   '0      - Number expected'                         + #13#10 +
   '9      - Optional number expected'                + #13#10 +
   'A      - Alphabetic expected'                     + #13#10 +
   'U      - Uppercase letter expected'               + #13#10 +
   'L      - Lowercase letter expected'               + #13#10 +
   'X      - Alpha numeric expected'                  + #13#10 +
   'S      - Other char expected'                     + #13#10 +
   '*      - Any char';


// *** Char funtions ***//
function Char_GetType(aChar: Char): TCarType;

// *** SubString functions *** //
  { English: Substring definition:
    A string can be defined by substrings that are separated by a specified caracter.
    We admit that if a string = '', it has a single substring element with '' value.
    So, Substring count is 1 or superior.
    The first Substring element on a string has index 1, the second has index 2 and so on.

    Exemple (';' is the substring separator) :
    Exemple: Str = ''                 1 empty substring
    Exemple: Str = 'xxx'              1 substring with 'xxx' value
    Exemple: Str = ';'                2 empty substrings
    Exemple: Str = 'xxx;'             2 substrings ('xxx' and '')
    Exemple: Str = ';xxx'             2 substrings ('' and 'xxx')
    Exemple: Str = 'xxx;yyy'          2 substrings ('xxx' and 'yyy')
  }

  { Fran�ais: Definition d' une sous-chaine, appel� �l�ment:
    Une chaine de caract�res peut �tre d�finit de plusieurs �l�ments s�par�s par un caract�re d�finit.
    On admet que si une string = '', celle-ci contient un seul �l�ment appel� subString de valeur ''.
    Donc, le nombre d' �l�ments ne peut �tre inf�rieur � 1.
    Le 1er �l�ment dans une string a pour Index 1, le second a pour Index 2 etc ...

    Exemple (lorsque ';' est le s�parateurs des �l�ments) :
    Si Str = ''                 on a 1 �l�ment vide
    Si Str = 'xxx'              on a 1 �l�ment de valeur 'xxx'
    Si Str = ';'                on a 2 �l�ments vide
    Si Str = 'xxx;'             on a 2 �l�ments  de valeur 'xxx' et ''
    Si Str = ';xxx'             on a 2 �l�ments  de valeur '' et 'xxx'
    Si Str = 'xxx;yyy'          on a 2 �l�ments  de valeur 'xxx' et 'yyy'
  }

  function SubString_Count(Str: String; Separator: Char): Integer;
  // English: Retrieve the number of substring
  // Fran�ais: La fonction renvoie le nombre d' �l�ments dans Str

  function SubString_AtPos(Str: String; Separator: Char; SubStringIndex: Word): Integer;
  // English: Retrieve the substring (specified by its index) position on the string
  // Fran�ais: Renvoie la position du 1er caract�re de l' �l�ment d' indexe SubStringIndex

  function SubString_Get(Str: String; Separator: Char; SubStringIndex: Word): String;
  // English: Retrieve substring element by index
  // Fran�ais: Renvoie l' �l�ment d' indexe SubStringIndex

  function SubString_Length(Str: String; Separator: Char; SubStringIndex: Word): Integer;
  // English: Retrieve the number of caracters of the substring specified by SubStringIndex
  // Fran�ais: Renvoie le nombre de caract�res de l' �l�ment d' indexe SubStringIndex

  procedure SubString_Add(var Str: String; Separator: Char; Value: String);
  // English: Add a substring at the end. For the first substring, use str := 'Value'
  // Fran�ais: Ajoute un �l�ment � la fin de la string. Pour le 1er �l�ment, utilisez Str := 'exemple'

  procedure SubString_Insert(var Str: String; Separator: Char; SubStringIndex: Word; Value: String);
  // English: Insert a substring at SubStringIndex position
  // Fran�ais: Ins�re un �l�ment � la position SubStringIndex

  procedure SubString_Edit(Var Str: String; Separator: Char; SubStringIndex: Word; NewValue: String);
  // English: Modify/initialize the specified substring at SubStringIndex position (don' t need to already exists)
  // Fran�ais: Modifie/initialise l' �l�ment d�finit par SubStringIndex.

  function SubString_Remove(var Str: string; Separator: Char; SubStringIndex: Word): Boolean;
  // English: Delete the specified substring
  // Fran�ais: �limine l' �l�ment � l' index SubStringIndex

  function SubString_Locate(Str: string; Separator: Char; SubString: String; Options: TStrLocateOptions): Integer;
  // English: Retrieve SubString index
  // Fran�ais: Renvoie la position de l' �l�ment sp�cifi�

  function SubString_Ribbon(Str: string; Separator: Char; Current: Word; MoveBy: Integer): Integer; overload;
  // English: Retrieve substring index from a current substring and moving by MoveBy.
  // If there's no more substrings, it continues to move from the first one.
  // Fran�ais: Renvoie la position d' un �l�ment par rapport � un autre en ce d�placeant de "MoveBy" �l�ments.
  // Si on se retrouve � la fin, on revient au d�but et vice versa.

  function SubString_Ribbon(Str: string; Separator: Char; Current: String; MoveBy: Integer): String; overload;
  // English: Like prior but SubString can be specified by its value
  // Fran�ais: comme la fonction ant�rieure, si ce n' est que l' �l�ment est cette fois d�finit par sa valeur



// *** String functions *** //
  function String_Quote(Str: String): String;

  function String_GetCar(Str: String; Position: Word; ReturnCarIfNotExists: Char): Char;
  // English: Returns caracter at specified position
  // Fran�ais: Renvoie le caract�re � la position "Position"

  function String_ExtractCars(fromStr: String; CarTypes: TCarTypes; IncludeCars, ExcludeCars: String): String; {$IFDEF UNICODE} overload; {$ENDIF}

  {$IFDEF UNICODE}
  function String_ExtractCars(Str: String; CharCategories: TUnicodeCategories): String; overload;
  // English: Returns caracters of specified categories (numbers, letters etc ...)
  // Fran�ais: Renvoie les types de caract�res sp�cifi� avec CharCategories (nombres, lettres etc ...)
  {$ENDIF}

  function String_GetWord(Str: String; StringRead: TStringRead): String;
  // English: Returns a string with any word found on the string
  // Fran�ais: Renvoie une string qui peut �tre convertie en type Word si le r�sultat de la fonction n' est pas vide

  function String_GetInteger(Str: String; StringRead: TStringRead): String;
  // English: Returns a string with any integer found on the string
  // Fran�ais: Renvoie une string qui peut �tre convertie en type Integer si le r�sultat de la fonction n' est pas vide

  function String_ToInt(Str: String): Integer;
  // English: Always convert a string to an integer, returns 0 if not valid integer
  // Fran�ais: Converti une String en Integer si possible, sinon renvoie 0

  function String_Uppercase(Str: String; Options: TWordsOptions) : String;
  // English: Uppercase string by Options
  // Fran�ais: Renvoie la string en majuscule selon Options (1�re lettre de string, 1�re lettre de chaque mot ou toute la string)

  function String_Lowercase(Str: String; Options: TWordsOptions) : String;
  // English: Lowercase string by Options
  // Fran�ais: Renvoie la string en minuscule selon Options (1�re lettre de string, 1�re lettre de chaque mot ou toute la string)

  function String_Reverse(Str: String): String;
  // English: Revert a string, String_Reverse('Hello ') returns 'olleH'
  // Fran�ais: Renvoie l' ordre des carat�res invers� de la string

  function String_Pos(SubStr: String; Str: String; fromPos: Integer; CaseSensitive: TCaseSensitive): Integer; overload;
  // English: Retrieve subString position in string since fromPos position
// Fran�ais: Renvoie la position d' une substring depuis une certaine position

  function String_Pos(SubStr: String; Str: String; StringRead: TStringRead; Occurrence: Word; CaseSensitive: TCaseSensitive): Integer; overload;
  // English: Retrieve subString position
  // Fran�ais: Renvoie la position d' une substring selon son ocurrence

  function String_Copy(Str: String; fromIndex: Integer; toIndex: Integer): String; overload;
  // English: Copy caracters in a string from fromIndex to toIndex
  // Fran�ais: Renvoie la copie d' une string selon la position du 1er et dernier caract�re

  function String_Copy(Str: String; StringRead: TStringRead; UntilFind: String; _Inclusive: Boolean): String; overload;
  // English: Copy caraters in a string until UntilFind found
  // Fran�ais: Renvoie la copie d' une string tant qu' elle ne trouve pas UntilFind

  function String_Copy(Str: String; Between1: String; Between1MustExist: Boolean; Between2: String; Between2MustExist: Boolean; CaseSensitive: TCaseSensitive): String; overload;
  // English: Retrieve caracters between 2 strings
  // Fran�ais: Renvoie les caract�res d' uyne string entre 2 substrings.

  function String_Delete(Str: String; fromIndex: Integer; toIndex: Integer): String; overload;
  // English: Returns a string cutted from fromIndex to to Index
  // Fran�ais: �limine les caract�res d' une string entre la position du 1er et dernier caract�re sp�cifi�

  function String_Delete(Str: String; delStr: String; CaseSensitive: TCaseSensitive): String; overload;
  // English: Returns a string Removing substrings specified in delStr
  // Fran�ais: Renvoie la string apr�s avoir retir� toute SubString specifi�e avec delStr

  function String_BoundsCut(Str: String; CutCar: Char; Bounds: TStringReads): String;
  // English: Remove specified caracter from string bounds
  // Fran�ais: Permet de retirer un caract�re tant que la string commence ou fini para celui-ci.

  function String_BoundsAdd(Str: String; AddCar: Char; ReturnLength: Integer): String;
  // English: Add specified caracter until string length is equal to ReturnLength
  // Fran�ais: Permet d' ajouter un caract�re au d�but ou/et � la fin d' une string jusqu' � ce que la string se retrouve de la taille de "ReturnLength" caract�res

  function String_Add(Str: String; StringRead: TStringRead; aCar: Char; ReturnLength: Integer) : String;
  // English: Add specified caracter at the beginning/end until string length is equal to ReturnLength
  // Fran�ais: Permet d' ajouter un caract�re au d�but ou � la fin d' une string jusqu' � ce que la string se retrouve de la taille de "ReturnLength" caract�res

  function String_End(Str: String; Cars: Word): String;
  // English: Get last string caracters
  // Fran�ais: Renvoie les derniers caract�res d' une string

  function String_Subst(OldStr: String; NewStr: String; Str: String; CaseSensitive: TCaseSensitive = csCaseSensitive; AlwaysFindFromBeginning: Boolean = false): String; overload;
  // English: Like StringReplace() but with AlwaysFindFromBeginning parameter
  // Fran�ais: Fonction identique � StringReplace.
  // Permet cependant de toujours remplacer en recherchant depuis le d�but de la string. Utile lorsque New est contenu par OldStr

  function String_Subst(OldStr: String; NewStr: String; Str: String; fromPosition, ToPosition: Word; CaseSensitive: TCaseSensitive = csCaseSensitive; AlwaysFindFromBeginning: Boolean = false): String; overload;

  function String_SubstCar(Str: String; Old, New: Char): String;
  // English: Replace a caracter by another
  // Fran�ais: Remplace un caract�re par un autre dans une string

  function String_Count(Str:String; SubStr:String; CaseSenSitive: TCaseSensitive) : Integer;
  // English: Retrieve the number of occurrences of SubStr
  // Fran�ais: Renvoie le nombre d' occurences d' une SubString

  function String_SameCars(Str1, Str2: String; StopCount_IfDiferent: Boolean; CaseSensitive: TCaseSensitive): Integer;
  // English: Retrieve number of identical caracters at the same position
  // Fran�ais: Compte le nombre de caract�res identiques � la m�me position entre 2 strings

  function String_IsNumbers(Str: String) : Boolean;
  // English: Returns True if the string contains only numeric caracters
  // Fran�ais: Permet de savoir si la string ne poss�de que des caract�res de type chiffre.

  function SearchPos(SubStr: String; Str: String; MaxErrors: Integer): Integer;
  // English: Search a string into another if diference tolerence
  // Fran�ais: Recherche une cha�ne de caract�res � l' int�rieur d' une autre avec une tol�rence de diferences

  function StringToCsvCell(aStr: String; const SeparationChar: Char = ';'): String;

  procedure GetCsvCellsContent(const fromCsvLine: String; Values: TStrings);

  function isValidWebSiteChar(aChar: Char): Boolean;

  function isValidWebMailChar(aChar: Char): Boolean;

  function isValidwebSite(aStr: String): Boolean;

  function isValidWebMail(aStr: String): Boolean;



// *** Mask functions ***

(*

 'AB'   - Letters AB expected
 N      - Number expected
 A      - Alphabetic expected
 U      - Uppercase letter expected
 L      - Lowercase letter expected
 X      - Alpha numeric expected
 S      - Other char expected
 *      - Any char

 To be done in future :

 [0..999]/[0..999]   - Suffix that can be added to prior rules
 Exemple :
 N1/9   - Undetermined Numbers expected between 1 and 9
 A1/9   - Undetermined Letters expected between 1 and 9

*)

function GetNextMaskPart(var FromMask, RsltMaskPartParamStr: string; var RsltMaskPartType: TMaskPartType): Boolean;
function IsValidMask(const aMask: String): Boolean;
function MaskPartCount(aMask: string; var OptionalCount: Integer): Integer;
function DetectPartialMatchMask(var aMask: string; const aString: string): Boolean;
function IsMatchMask(var aMask: string; var aString: string): Boolean;
function IsMatchMask2(const aMask: string; const aString: string): Boolean;
function MergeMaskToMatchedString(var aMask: string; aString: string): String;
function MergeMaskToMatchedString2(const aMask: string; const aString: string): String;

implementation

function Char_GetType(aChar: Char): TCarType;
begin
  Result := ctOther;
  if aChar in ['a'..'z', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�'] then
    Result := ctAlphabeticLowercase
  else
    if aChar in ['A'..'Z', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�'] then
      Result := ctAlphabeticUppercase
    else
      if aChar in ['0'..'9'] then
        Result := ctNumeric;
end;

function SubString_Count(Str: String; Separator: Char): Integer;
var i, nbCars: Integer;
begin
  Result := 1;
  nbCars := length(Str);

  for i := 1 to nbCars do
    if Str[i] = Separator
    then Result := Result + 1;
end;

function SubString_AtPos(Str: String; Separator: Char; SubStringIndex: Word): Integer;
var nbCars, curSubStringIndex, i: Integer;
begin
  Result := 0;
  if SubStringIndex = 0 then raise ERangeError.Create('SubStringIndex = 0!');

  nbCars := length(Str);
  curSubStringIndex := 1;
  i := 0;

  while (curSubStringIndex <> SubStringIndex) and (i < nbCars) do
  begin
    i := i + 1;

    if Str[i] = Separator
    then curSubStringIndex := curSubStringIndex + 1;
  end;

  if curSubStringIndex = SubStringIndex
  then Result := i + 1;    // 'Sauter' le separateur ou i = 0...
end;

function SubString_Get(Str: String; Separator: Char; SubStringIndex: Word): String;
var nbCars, i: Integer;
begin
  Result := '';
  i := SubString_AtPos(Str, Separator, SubStringIndex);

  if i <> 0      // Substring exists
  then begin
    nbCars := length(Str);

    while i <= nbCars do
    begin
      if Str[i] <> Separator
      then Result := Result + Str[i]
      else i := nbCars;

      i := i + 1;
    end;
  end;
end;

function SubString_Length(Str: String; Separator: Char; SubStringIndex: Word): Integer;
begin
  Result := Length(SubString_Get(Str, Separator, SubStringIndex));
end;

procedure SubString_Add(var Str: String; Separator: Char; Value: String);
begin
  Str := Str + Separator + Value;
end;

procedure SubString_Insert(var Str: String; Separator: Char; SubStringIndex: Word; Value: String);
var i, SubStrCount: Integer;
begin
  SubStrCount := SubString_Count(Str, Separator);

  if (SubStringIndex > 0) and (SubStringIndex <= SubStrCount)
  then begin
    i := SubString_AtPos(Str, Separator, SubStringIndex);
    Insert(Value + Separator, Str, i);
  end
  else
    raise ERangeError.CreateFmt('%d is not within the valid range of %d..%d', [SubStringIndex, 1, SubStrCount]);
end;

procedure SubString_Edit(var Str: string; Separator: Char; SubStringIndex: Word; NewValue: string);
var i, SubStrCount, nbCars: Integer;
begin
  i := SubString_AtPos(Str, Separator, SubStringIndex);

  if i = 0          // Substring does not exists ...
  then begin
    SubStrCount := SubString_Count(Str, Separator);

    while SubStrCount < SubStringIndex do
    begin
      Str := Str + Separator;          // Add empty substring
      SubStrCount := SubStrCount + 1;
    end;

    Str := Str + NewValue;
  end
  else begin
    nbCars := length(Str);
    // Remove current  value :
    while i <= nbCars do
      if Str[i] <> Separator
      then begin
        Delete(Str, i, 1);
        nbCars := nbCars - 1;
      end
      else
        nbCars := 0;   // End of the substring

    // Insert new substring value :
    Insert(NewValue, Str, i);
  end;
end;

function SubString_Remove(var Str: string; Separator: Char; SubStringIndex: Word): Boolean;
var i, nbCars: Integer;
begin
  Result := false;
  i := SubString_AtPos(Str, Separator, SubStringIndex);

  if i <> 0
  then begin
    Result := True;
    nbCars := length(Str);
    // Remove current value :
    while i <= nbCars do
    begin
      if Str[i] = Separator
      then nbCars := 0             // end of the substring
      else nbCars := nbCars - 1;

      Delete(Str, i, 1);
    end;
  end;
end;

function SubString_Locate(Str: string; Separator: Char; SubString: String; Options: TStrLocateOptions): Integer;
var
  SubStrCount, CurSubStrIndex: Integer;
  FindPartialKey, FindCaseInsensitive: Boolean;
begin
  Result := 0;
  CurSubStrIndex := 1;
  SubStrCount := SubString_Count(Str, Separator);
  FindPartialKey := strloPartialKey in Options;
  FindCaseInsensitive := strloCaseInsensitive in Options;

  if FindCaseInsensitive
  then begin
    Str := AnsiUpperCase(Str);
    SubString := AnsiUpperCase(SubString);
  end;

  while (Result = 0) and (CurSubStrIndex <= SubStrCount) do
  begin
    if FindPartialKey
    then begin
      if Pos(SubString, SubString_Get(Str, Separator, CurSubStrIndex)) = 1
      then Result := CurSubStrIndex;
    end
    else
      if SubString = SubString_Get(Str, Separator, CurSubStrIndex)
      then Result := CurSubStrIndex;

    inc(CurSubStrIndex, 1);
  end;
end;

function SubString_Ribbon(Str: string; Separator: Char; Current: Word; MoveBy: Integer): Integer;
var Count: Integer;
begin
  Count := SubString_Count(Str, Separator);

  Result := Current + MoveBy;

  if Result > 0
  then begin
    while Result > Count do
      Result := Result - Count;
  end
  else begin
    while Result <= 0 do
      Result := Result + Count;
  end;
end;

function SubString_Ribbon(Str: string; Separator: Char; Current: String; MoveBy: Integer): String;
var SubStringIndex: Integer;
begin
  SubStringIndex := SUBSTRING_LOCATE(Str, Separator, Current, []);

  if SubStringIndex = 0
  then SubStringIndex := 1
  else SubStringIndex := SubString_Ribbon(Str, Separator, SubStringIndex, MoveBy);

  Result := SUBSTRING_GET(Str, Separator, SubStringIndex);
end;

function String_Quote(Str: String): String;
begin
  Result := '''' + Str + '''';
end;

function String_ExtractCars(fromStr: String; CarTypes: TCarTypes; IncludeCars, ExcludeCars: String): String;

        function IncludeCar(aCar: Char): Boolean;
        var c: Integer;
        begin
          Result := false;
          for c := 1 to length(IncludeCars) do
            if IncludeCars[c] = aCar then
            begin
              Result := true;
              Break;
            end;
        end;

        function ExcludeCar(aCar: Char): Boolean;
        var c: Integer;
        begin
          Result := false;
          for c := 1 to length(ExcludeCars) do
            if ExcludeCars[c] = aCar then
            begin
              Result := true;
              Break;
            end;
        end;


var
  i: Integer;
  AddCar: Boolean;
begin
  Result := '';

  for i := 1 to length(fromStr) do
  begin
    AddCar := false;

    if IncludeCar(fromStr[i]) then
      AddCar := true
    else
      if not ExcludeCar(fromStr[i]) then
        if Char_GetType(fromStr[i]) in CarTypes then
          AddCar := true;

    if AddCar then
      Result := Result + fromStr[i];
  end;
end;

{$IFDEF UNICODE}
function String_ExtractCars(Str: String; CharCategories: TUnicodeCategories): String;
var
  I: Integer;
  UnicodeCategory: TUnicodeCategory;
begin
  Result := '';

  for i := 1 to Length(Str) do
  begin
    UnicodeCategory := GetUnicodeCategory(Str, I);
    if UnicodeCategory in CharCategories then
      Result := Result + Str[I];
  end;
end;
{$ENDIF}

function String_GetCar(Str: String; Position: Word; ReturnCarIfNotExists: Char): Char;
begin
  if Position in [1..Length(Str)] // Returns false if Length(Str) = 0
  then Result := Str[Position]
  else Result := ReturnCarIfNotExists;
end;

function String_ToInt(Str: String): Integer;
begin
  if not TryStrToInt(Str, Result)
  then Result := 0;
end;

function String_Uppercase(Str: String; Options: TWordsOptions) : String;
var
  i: Integer;
  b: Boolean;
begin
  if Str = ''
  then
    Result := ''
  else
    if woOnlyFirstCar in Options     // Word first letter
    then begin
      Str := AnsiLowerCase(Str);

      if woOnlyFirstWord in Options
      then
        Result := AnsiUpperCase(Str[1]) + Copy(Str, 2, Length(Str) -1)
      else begin
        b := True;
        Result := '';

        for i := 1 to Length(Str) do
        begin
          if b
          then Result := Result + AnsiUpperCase(Str[i])
          else Result := Result + Str[i];

          b := Str[i] = ' ';
        end;
      end;
    end
    else begin                       // All word
      Str := AnsiLowerCase(Str);

      if not (woOnlyFirstWord in Options)
      then
        Result := AnsiUpperCase(Str)
      else begin
        b := True;
        Result := '';

        for i := 1 to Length(Str) do
        begin
          if b
          then begin
            Result := Result + AnsiUpperCase(Str[i]);
            b := Str[i] <> ' ';
          end
          else
            Result := Result + Str[i];
        end;
      end
    end;
end;

function String_Lowercase(Str : String; Options: TWordsOptions): String;
var
  i: Integer;
  b: Boolean;
begin
  if Str = ''
  then
    Result := ''
  else
    if woOnlyFirstCar in Options     // Word first letter
    then begin
      if woOnlyFirstWord in Options
      then
        Result := AnsiLowerCase(Str[1]) + Copy(Str, 2, Length(Str) -1)
      else begin
        b := True;
        Result := '';

        for i := 1 to Length(Str) do
        begin
          if b
          then Result := Result + AnsiLowerCase(Str[i])
          else Result := Result + Str[i];

          b := Str[i] = ' ';
        end;
      end;
    end
    else begin                       // All word
      if not (woOnlyFirstWord in Options)
      then
        Result := AnsiLowerCase(Str)
      else begin
        b := True;
        Result := '';

        for i := 1 to Length(Str) do
        begin
          if b
          then begin
            Result := Result + AnsiLowerCase(Str[i]);
            b := Str[i] <> ' ';
          end
          else
            Result := Result + Str[i];
        end;
      end
    end;
end;

function String_Reverse(Str: String): String;
var i: Integer;
begin
  Result := '';

  for i := 1 to Length(Str) do
    Result := Str[i] + Result;
end;

function String_Pos(SubStr: String; Str: String; fromPos: Integer; CaseSensitive: TCaseSensitive): Integer;
begin
  if fromPos < 1 then fromPos := 1;   // From first char ...

  if CaseSensitive = csCaseNotSensitive
  then begin
    SubStr := AnsiUpperCase(SubStr);
    Str := AnsiUpperCase(Str);
  end;

  // Remove the beginning :
  Delete(Str, 1, fromPos - 1);

  // Get "relative" position :
  Result := pos(SubStr, Str);

  // Get absolute position :
  if Result <> 0
  then Inc(Result, fromPos - 1);
end;

function String_Pos(SubStr: String; Str: String; StringRead: TStringRead; Occurrence: Word; CaseSensitive: TCaseSensitive): Integer;
var CurCar, LengthStr, LengthSubStr, FoundCount: Integer;
begin
  Result := 0;

  if CaseSensitive = csCaseNotSensitive
  then begin
    Str  := AnsiUpperCase(Str);
    SubStr := AnsiUpperCase(SubStr);
  end;

  if (Occurrence > 0) and (SubStr <> '')
  then begin
    if StringRead = srFromRight
    then begin
      SubStr := String_Reverse(SubStr);
      Str  := String_Reverse(Str);
    end;

    FoundCount   := 0;
    CurCar       := 1;
    LengthStr    := Length(Str);
    LengthSubStr := Length(SubStr);

    while CurCar <= LengthStr do
    begin
      if Copy(Str, CurCar, LengthSubStr) = SubStr
      then begin
        FoundCount := FoundCount + 1;

        if FoundCount = Occurrence
        then begin
          if StringRead = srFromLeft
          then Result := CurCar
          else Result := LengthStr - CurCar + (2 - LengthSubStr);   // Calc correct position because of String reverse()

          CurCar := LengthStr;
        end
        else
          CurCar := CurCar + LengthSubStr;
      end
      else
        CurCar := CurCar + 1;
    end;
  end;
end;

function String_Copy(Str: String; fromIndex: Integer; toIndex: Integer): String;
begin
  Result := Copy(Str, fromIndex, (toIndex - fromIndex + 1));
end;

function String_Copy(Str: String; StringRead: TStringRead; UntilFind: String; _Inclusive: Boolean): String;
var x: Integer;
begin
  Result := '';

  if Pos(UntilFind, Str) > 0
  then
    if StringRead = srFromLeft
    then begin
      x := Pos(UntilFind, Str);
      if _Inclusive
      then Inc(x, Length(UntilFind));
      Result := Copy(Str, 1, x - 1);
    end
    else begin
      x := String_Pos(UntilFind, Str, srFromRight, 1, csCaseSensitive);
      if not _Inclusive
      then Inc(x, Length(UntilFind));
      Result := Copy(Str, x, Length(Str));
    end;
end;

function String_Copy(Str: String; Between1: String; Between1MustExist: Boolean; Between2: String; Between2MustExist: Boolean; CaseSensitive: TCaseSensitive): String;
var
  posStr1, posStr2, StartPos, EndPos: Integer;
  WorkingStr: String;
begin
  Result := '';

  if Str <> ''
  then begin
    if CaseSensitive = csCaseNotSensitive
    then begin
      Between1 := AnsiUpperCase(Between1);
      Between2 := AnsiUpperCase(Between2);
      WorkingStr := AnsiUpperCase(Str);
    end
    else
      WorkingStr := Str;

    StartPos := 0;
    EndPos   := 0;
    posStr1  := pos(Between1, WorkingStr);

    if Between1 = Between2    // Locate the 2nd occurrence :
    then posStr2 := String_Pos(Between2, WorkingStr, srFromLeft, 2, csCaseNotSensitive)
    else posStr2 := String_Pos(Between2, WorkingStr, posStr1 + length(Between1), csCaseNotSensitive);

    if posStr1 = 0
    then begin
      if not Between1MustExist
      then StartPos := 1;
    end
    else
      StartPos := posStr1 + length(Between1);

    if posStr2 = 0
    then begin
      if not Between2MustExist
      then EndPos := Length(Str);
    end
    else
      EndPos := posStr2 - 1;

    if (StartPos <> 0) and (EndPos <> 0)
    then Result := String_Copy(Str, StartPos, EndPos);
  end;
end;

function String_BoundsCut(Str: String; CutCar: Char; Bounds: TStringReads): String;
var
  Cont: Boolean;
  NbCars: Integer;
begin
  if srFromLeft in Bounds
  then begin
    Cont := true;
    NbCars := Length(Str);
    while (Cont) and (NbCars > 0) do
      if Str[1] = CutCar
      then begin
        Delete(Str, 1, 1);
        NbCars := nbCars - 1;
      end
      else
        Cont := false;
  end;

  if srFromRight in Bounds
  then begin
    Cont := true;
    NbCars := Length(Str);
    while (Cont) and (NbCars > 0) do
      if Str[NbCars] = CutCar
      then begin
        Delete(Str, NbCars, 1);
        NbCars := nbCars - 1;
      end
      else
        Cont := false;
  end;

  Result := Str;
end;

function String_BoundsAdd(Str: String; AddCar: Char; ReturnLength: Integer): String;
var
  Orig, i, AddCarCount: Integer;
  ToTheRight: Boolean;
begin
  ToTheRight := True;
  Orig      := Length(Str);
  AddCarCount    := ReturnLength - Orig;
  Result    := Str;

  for i := 1 to AddCarCount do
  begin
    if ToTheRight
    then Result := Result + AddCar
    else Result := AddCar + Result;

    ToTheRight := not ToTheRight;
  end;
end;

function String_GetWord(Str: String; StringRead: TStringRead): String;
var
  I: Integer;
  Cont: Boolean;
begin
  Cont   := True;
  Result := '';

  if StringRead = srFromLeft
  then begin
     for i := 1 to Length(Str) do
       if (Cont) and (Str[i] in ['0'..'9'])
       then Result := Result + Str[i]
       else Cont := Result = '';
  end
  else begin
     for i := Length(Str) downto 1 do
       if (Cont) and (Str[i] in ['0'..'9'])
       then Result := Str[i] + Result
       else Cont := Result = '';
  end;
end;

function String_GetInteger(Str: String; StringRead: TStringRead): String;
var
  I: Integer;
  Cont: Boolean;
begin
  Cont   := True;
  Result := '';

  if StringRead = srFromLeft
  then begin
     for i := 1 to Length(Str) do
       if (Cont) and (Str[i] in ['-', '0'..'9'])
       then begin
         if Str[i] = '-'
         then begin
           if (Result = '') and (i < length(Str))
           then begin
             if Str[i+1] in ['0'..'9']  // Next car is a number !!!
             then Result := '-';
           end
           else
             Cont := false;
         end
         else
           Result := Result + Str[i];
       end
       else
         Cont := Result = '';
  end
  else begin
     for i := Length(Str) downto 1 do
       if (Cont) and (Str[i] in ['-', '0'..'9'])
       then begin
         if Str[i] = '-'
         then begin
           if Result <> ''
           then begin
             Result := '-' + Result;
             Cont := false;
           end;
         end
         else
           Result := Str[i] + Result;
       end
       else
         Cont := Result = '';
  end;
end;

function String_Add(Str: String; StringRead: TStringRead; aCar: Char; ReturnLength: Integer) : String;
var NbCars: Integer;
begin
  NbCars := Length(Str);

  while NbCars < ReturnLength do
  begin
    if StringRead = srFromRight
    then Str := Str + aCar
    else Str := aCar + Str;

    NbCars := NbCars + 1;
  end;

  Result := Str;
end;

function String_End(Str: String; Cars: Word): String;
begin
  Result := Copy(Str, Length(Str) - Cars + 1, Cars);
end;

function String_Delete(Str: String; fromIndex: Integer; toIndex: Integer): String;
begin
  Result := Copy(Str, 1, fromIndex - 1) + Copy(Str, toIndex + 1, Length(Str) - toIndex);
end;

function String_Delete(Str: String; delStr: String; CaseSensitive: TCaseSensitive): String;
begin
  Result := String_Subst(delStr, '', Str, CaseSensitive, false);
end;

function String_Subst(OldStr: String; NewStr: String; Str: String; CaseSensitive: TCaseSensitive = csCaseSensitive; AlwaysFindFromBeginning: Boolean = false): String;
var AnsiUpperCaseNewStr: String;
    LengthStr, LengthOldStr, lengthNewStr: Integer;
    SearchUntilCar, i, f: Integer;
    Match: Boolean;
begin
  Result := Str;
  if OldStr = '' then Exit;
  if OldStr = NewStr then Exit;

  LengthStr := Length(Str);
  LengthOldStr := Length(OldStr);
  lengthNewStr := Length(NewStr);

  if CaseSensitive = csCaseNotSensitive then
  begin
    Str := AnsiUpperCase(Str);
    OldStr := AnsiUpperCase(OldStr);

    AnsiUpperCaseNewStr := AnsiUpperCase(NewStr);

    if AlwaysFindFromBeginning then
      AlwaysFindFromBeginning := Pos(OldStr, AnsiUpperCaseNewStr) = 0;
  end
  else
    if AlwaysFindFromBeginning then
      AlwaysFindFromBeginning := Pos(OldStr, NewStr) = 0;


  i := 1;
  SearchUntilCar := (LengthStr - LengthOldStr) + 1;
  while i <= SearchUntilCar do
  begin
    if Str[i] = OldStr[1] then
    begin
      Match := true;
      for f := 2 to LengthOldStr do     // Search OldStr into Str ...
        if Str[f+i-1] <> OldStr[f] then
        begin
          Match := false;
          Break;
        end;

      if Match then
      begin
        // Replace into Result and Str :
        Delete(Result, i, LengthOldStr);
        Delete(Str, i, LengthOldStr);

        if lengthNewStr <> 0 then
        begin
          Insert(NewStr, Result, i);

          if CaseSensitive = csCaseNotSensitive
          then Insert(AnsiUpperCaseNewStr, Str, i)
          else Insert(NewStr, Str, i);
        end;

        SearchUntilCar := SearchUntilCar + lengthNewStr - LengthOldStr;

        if AlwaysFindFromBeginning
        then i := i - LengthOldStr       // Go back
        else i := i + lengthNewStr - 1;  // Need to put cursor on last replaced char

        if i < 0 then i := 0;
      end;
    end;

    inc(i);
  end;
end;

function String_Subst(OldStr: String; NewStr: String; Str: String; fromPosition, ToPosition: Word; CaseSensitive: TCaseSensitive = csCaseSensitive; AlwaysFindFromBeginning: Boolean = false): String;
var
  Length_Str: Integer;
begin
  Length_Str := Length(Str);

  if fromPosition = 0 then
    fromPosition := 1;

  if ToPosition = 0 then
    ToPosition := Length_Str;

  Result := Copy(Str, 1, fromPosition-1)
            + String_Subst( OldStr, NewStr, Copy(Str, fromPosition, ToPosition), CaseSensitive, AlwaysFindFromBeginning )
            + Copy(Str, ToPosition + 1, Length_Str);
end;

function String_SubstCar(Str: String; Old, New: Char): String;
var
  LengthStr, i: Integer;
begin
  Result := Str;
  LengthStr := length(Str);

  for i := 1 to LengthStr do
    if Result[i] = Old then
      Result[i] := New;
end;

function String_Count(Str:String; SubStr:String; CaseSensitive: TCaseSensitive) : Integer;
var i, L_Str, L_SubStr: Integer;

   function SubStr_Na_Pos(_P: Integer): Boolean;
   begin
     Result := Copy(Str, _P, L_SubStr) = SubStr;
   end;

begin
  Result := 0;

  if SubStr <> ''
  then begin
    if CaseSensitive = csCaseNotSensitive
    then begin
      Str  := AnsiUpperCase(Str);
      SubStr := AnsiUpperCase(SubStr);
    end;

    L_Str    := Length(Str);
    L_SubStr := Length(SubStr);
    i := 1;

    while i <= L_Str do
       if SubStr_Na_Pos(i)
       then begin
         Result := Result + 1;
         i := i + L_SubStr;
       end
       else
         i := i + 1;
  end;
end;

function String_SameCars(Str1, Str2: String; StopCount_IfDiferent: Boolean; CaseSensitive: TCaseSensitive): Integer;
var i, MaxCars: Integer;
begin
  Result := 0;

  if CaseSensitive = csCaseNotSensitive
  then begin
    Str1 := AnsiUpperCase(Str1);
    Str2 := AnsiUpperCase(Str2);
  end;

  if Length(Str1) > Length(Str2)
  then MaxCars := Length(Str2)
  else MaxCars := Length(Str1);

  for i := 1 to MaxCars do
    if Str1[i] = Str2[i]
    then
      Result := Result + 1
    else
      if StopCount_IfDiferent
      then Break;
end;

function String_IsNumbers(Str: String) : Boolean;
var i: Integer;
begin
  Result := true;

  if Str <> ''
  then begin
    for i := 1 to Length(Str) do
      if not (Str[i] in ['0'..'9'])
      then Result := false;
  end
  else
    Result := false;
end;

function SearchPos(SubStr: String; Str: String; MaxErrors: Integer): Integer;
var
  i, p, LengthSubStr: Integer;
  ErrorCount: Integer;
begin
  Result := 0;
  LengthSubStr := Length(SubStr);

  // Navigate on Str searching for SubStr :
  for i := 1 to (Length(Str) - LengthSubStr) + 1 do
  begin
    ErrorCount := 0;

    // Compare all SubStr chars :
    for p := 1 to LengthSubStr do
      if SubStr[p] <> Str[i + p - 1] then
      begin
        Inc(ErrorCount);
        if ErrorCount > MaxErrors then
          Break;
      end;

    if ErrorCount <= MaxErrors then
    begin
      Result := i;
      MaxErrors := ErrorCount-1; // Try to locate with less errors ...
    end;
  end;
end;

function StringToCsvCell(aStr: String; const SeparationChar: Char = ';'): String;
var
  AddQuote: Boolean;
begin
  Result := aStr;

  // Any string cell containing <"> or <;> chars must be quoted !
  AddQuote := pos(SeparationChar, aStr) <> 0;
  if not AddQuote then
    AddQuote := pos('"', aStr) <> 0;

  // Any <"> char in string must be double :
  Result := String_Subst('"', '""', Result, csCaseSensitive, false);

  // 2014-12-22 Remove enters :
  Result := String_Subst(#13#10, '', Result, csCaseSensitive, false);

  if AddQuote then
    Result := '"' + Result + '"';
end;

procedure GetCsvCellsContent(const fromCsvLine: String; Values: TStrings);
var
  NbCells, c: Integer;
  isPreviousQuoteChar, isQuoteChar, isSeparatorChar, QuotedCell, QuotedOpened: Boolean;
  CellValue: String;
begin
  NbCells := 0;
  Values.Clear;

  if fromCsvLine = '' then Exit;

  isPreviousQuoteChar := false;
  QuotedCell := false;
  QuotedOpened := false;
  CellValue := '';

  for c := 1 to length(fromCsvLine) do
  begin
    if c <> 1 then
      isPreviousQuoteChar := isQuoteChar;

    isQuoteChar := fromCsvLine[c] = '"';
    isSeparatorChar := fromCsvLine[c] = ';';

    if isSeparatorChar and (not QuotedOpened) then
    begin
      // *** New cell *** //

      // Save previous cell :
      inc(NbCells);
      Values.Add(CellValue);
      CellValue := '';
      QuotedCell := false;
      QuotedOpened := false;  // Normally, it's already = false "
    end
    else begin
      // *** Same cell *** //
      if isQuoteChar then
        QuotedOpened := not QuotedOpened;

      if QuotedCell then
      begin
        if not isQuoteChar then
          CellValue := CellValue + fromCsvLine[c];  // Add any char !!
      end
      else begin
        if isQuoteChar then
        begin
          if CellValue = '' then
          begin
            // Cell starting with quote char must be ignored ...
            QuotedCell := true;
            isQuoteChar := false;  // Avoid insert <"> char if next char is <"> ...
          end;
        end
        else
          CellValue := CellValue + fromCsvLine[c];
      end;

      // General rule : 2 quoted char must be export as one unless first one is the first cell char !
      if isPreviousQuoteChar and isQuoteChar then
      begin
        CellValue := CellValue + '"';
        isQuoteChar := false;         // Avoid insert another <"> char if next char is <"> ...
      end;
    end;
  end;

  // Last cell :
  inc(NbCells);
  Values.Add(CellValue);
end;

function isValidWebSiteChar(aChar: Char): Boolean;
begin
  Result:= aChar in WebSiteLetters;
end;

function isValidWebMailChar(aChar: Char): Boolean;
begin
  Result:= aChar in WebMailletters;
end;

// Valid webSite:
// 'http://' + domain + '.' + country       (We consider 'www.' as part of domain)
// domain + '.' + country
function isValidwebSite(aStr: String): Boolean;
var
  i: Integer;
  WasSpecialChar, FoundDomain, FoundCountry: Boolean;

        // 2014-10-28 We can have  "http://sourceforge.net/projects/tcycomponents/"
        // Country will return "net/projects/tcycomponents/".
        // So, we have to cut all after "/"
        function ValidCountry(StrCountry: String): Boolean;
        var i: Integer;
        begin
          Result := false;

          if pos('/', StrCountry) <> 0 then
            StrCountry := Copy(StrCountry, 1, pos('/', StrCountry)-1);

          if Length(StrCountry) in [2, 3]  then
          begin
            Result := True;
            for i := 1 to Length(StrCountry) do
              if not (StrCountry[i] in ['a'..'z', 'A'..'Z']) then
                Result := false;
          end;
        end;

begin
  Result := false;

  aStr := AnsiLowercase(aStr);
  if pos('http://', aStr) = 1 then
    Delete(aStr, 1, 7);

  if pos('https://', aStr) = 1 then
    Delete(aStr, 1, 7);

  if pos('www.', aStr) = 1 then
    Delete(aStr, 1, 4);

  if pos(':', aStr) > 0 then
    Exit;             // Result is false

  if (aStr + ' ')[1] in ['/', '.'] then
    Exit;             // Result is false

  WasSpecialChar := false;
  FoundDomain := false;
  FoundCountry := false;

  for i := length(aStr) downto 1 do
  begin
    if not isValidWebSiteChar(aStr[i]) then
      Exit;       // Result is false

    // Test 2 special chars besides :
    if aStr[i] in ['/', '.'] then
    begin
      if WasSpecialChar
      then Exit       // Result is false
      else WasSpecialChar := true;
    end
    else
      WasSpecialChar := false;

    case aStr[i] of
      '.' :
      begin
        if not FoundCountry then
        begin
          if (FoundDomain) or (i = length(aStr)) or (i = 1)
          then
            Exit   // Result is false
          else
            if ValidCountry( copy(aStr, i+1, length(aStr)) )
            then FoundCountry := true
            else Exit;
        end
        else
          if i=1 then
            Exit;     // Result is false
      end
    else
      begin
        if FoundCountry then
          FoundDomain := true;
      end;
    end;
  end;

  Result := FoundDomain and FoundCountry;
end;

// Valid @mail:
// Body + '@' + domain + '.' + country
function isValidWebMail(aStr: String): Boolean;
var
  i: Integer;
  WasSpecialChar, FoundBody, FoundDomain, FoundCountry: Boolean;
begin
  Result := false;

  WasSpecialChar := false;
  FoundBody := false;
  FoundDomain := false;
  FoundCountry := false;

  for i := length(aStr) downto 1 do
  begin
    // Test 2 special chars besides :
    if aStr[i] in ['@', '.'] then
    begin
      if WasSpecialChar
      then Exit       // Result is false
      else WasSpecialChar := true;
    end
    else
      WasSpecialChar := false;

    case aStr[i] of
      '@' :
      begin
        if FoundDomain
        then
          Exit        // Result is false
        else
          if not FoundCountry
          then Exit   // Result is false
          else FoundDomain := true;
      end;

      '.' :
      begin
        if not FoundCountry then
        begin
          if (FoundBody) or (FoundDomain) or (i = length(aStr)) or (i = 1)
          then Exit   // Result is false
          else FoundCountry := true;
        end
        else
          if i=1 then
            Exit;     // Result is false
      end
    else
      begin
        if not isValidWebMailChar(aStr[i]) then
          Exit;       // Result is false

        if FoundDomain and FoundCountry then
          FoundBody := true;
      end;
    end;
  end;

  Result := FoundBody and FoundDomain and FoundCountry;
end;

function IsValidMask(const aMask: String): Boolean;
var
  i: Integer;
  MaskPartStringValueStarted, MaskPartCustomCharsValueStarted: Boolean;
begin
  Result := true;
  MaskPartStringValueStarted := false;
  MaskPartCustomCharsValueStarted := false;

  for i := 1 to length(aMask) do
  begin
    if aMask[i] = cQuoteChar then
      MaskPartStringValueStarted := not MaskPartStringValueStarted
    else
      if (aMask[i] = MaskBeginCustomChars) and (not MaskPartCustomCharsValueStarted) then
        MaskPartCustomCharsValueStarted := true
      else
        if (aMask[i] = MaskEndCustomChars) and (MaskPartCustomCharsValueStarted) then
          MaskPartCustomCharsValueStarted := false
        else
          if (not MaskPartStringValueStarted) and (not MaskPartCustomCharsValueStarted) then
            if not (aMask[i] in [cQuoteChar, MaskAnyChar, MaskAlphaNumChar, MaskNumber, MaskOptionalNumber, MaskAlphaChar, MaskUppercaseChar, MaskLowercaseChar, MaskOtherChar]) then
              Result := false;

    if not Result then
      Break;
  end;

  if Result then
    Result := (not MaskPartStringValueStarted) and (not MaskPartCustomCharsValueStarted);
end;

function GetNextMaskPart(var FromMask, RsltMaskPartParamStr: string; var RsltMaskPartType: TMaskPartType): Boolean;
begin
  Result := false;
  if FromMask = '' then Exit;

  RsltMaskPartParamStr := '';
  RsltMaskPartType := mtUndefined;

  case FromMask[1] of
    cQuoteChar:           RsltMaskPartType := mtMaskPartStringValue;
    MaskBeginCustomChars: RsltMaskPartType := mtMaskPartCustomChars;
    MaskAnyChar:          RsltMaskPartType := mtAnyChars;
    MaskAlphaNumChar:     RsltMaskPartType := mtAlphaNumChars;
    MaskNumber:           RsltMaskPartType := mtNumbers;
    MaskOptionalNumber:   RsltMaskPartType := mtOptionalNumbers;
    MaskAlphaChar:        RsltMaskPartType := mtAlphaChars;
    MaskUppercaseChar:    RsltMaskPartType := mtUppLetters;
    MaskLowercaseChar:    RsltMaskPartType := mtLowLetters;
    MaskOtherChar:        RsltMaskPartType := mtOtherChars;
  end;

    if RsltMaskPartType = mtUndefined then
      RsltMaskPartParamStr := FromMask[1]
    else
      if RsltMaskPartType = mtMaskPartStringValue then
      begin
        Delete(FromMask, 1, 1);  // Remove first quote char ...

        while FromMask <> '' do
        begin
          if FromMask[1] <> cQuoteChar then
          begin
            RsltMaskPartParamStr := RsltMaskPartParamStr +  FromMask[1];
            Delete(FromMask, 1, 1);
          end
          else begin
            Delete(FromMask, 1, 1);
            Break;    // end of string value ...
          end;
        end;

        Result := RsltMaskPartParamStr <> '';
      end
      else
        if RsltMaskPartType = mtMaskPartCustomChars then
        begin
          Delete(FromMask, 1, 1);  // Remove MaskBeginCustomChars ...

          while FromMask <> '' do
          begin
            if FromMask[1] <> MaskEndCustomChars then
            begin
              RsltMaskPartParamStr := RsltMaskPartParamStr +  FromMask[1];
              Delete(FromMask, 1, 1);
            end
            else begin
              Delete(FromMask, 1, 1);
              Break;    // end of Custom chars ...
            end;
          end;

          Result := RsltMaskPartParamStr <> '';
        end
        else begin
          RsltMaskPartParamStr := FromMask[1];
          Delete(FromMask, 1, 1);
          Result := true;
        end;
end;

function MaskPartCount(aMask: string; var OptionalCount: Integer): Integer;
var
  Mask, MaskPartParamStr: string;
  MaskPartType: TMaskPartType;
begin
  Result := 0;
  OptionalCount := 0;
  Mask := amask;
  while GetNextMaskPart(Mask, MaskPartParamStr, MaskPartType) do
  begin
    Inc(Result);

    if MaskPartType = mtMaskPartCustomChars then
    begin
      if pos('%', MaskPartParamStr) <> 0 then
        Inc(OptionalCount);
    end;

    if MaskPartType = mtOptionalNumbers then
      Inc(OptionalCount);
  end;
end;

function DetectPartialMatchMask(var aMask: string; const aString: string): Boolean;
var
  RsltMaskPartParamStr: string;
  RsltMaskPartType: TMaskPartType;
  _aMask, _aString: String;
begin
  Result := false;

  while (not Result) and (aMask <> '') and (aString <> '') do
  begin
    _aMask := aMask;
    _aString := aString;

    IsMatchMask(_aMask, _aString);

    if _aString = '' then    // if aString = '', it is because all string matched partially the mask !
    begin
      if _aMask <> '' then   // if _aMask <> '', some residual mask not matched, we will cut it from aMask !
        aMask := copy(aMask, 1, Length(aMask) - Length(_aMask));

      Result := true;
    end
    else
      GetNextMaskPart(aMask, RsltMaskPartParamStr, RsltMaskPartType);  // Remove single mask part from left and try again ...
  end;
end;

function IsMatchMask(var aMask: string; var aString: string): Boolean;
var
  MaskPartParamStr: string;
  MaskPartType: TMaskPartType;
  i, MaskPartMin, MaskPartMax, OptionalNumberCount: Integer;

      function MaskOptional: Boolean;
      begin
        Result := true;
        if aMask = '' then Exit;


        while Result and GetNextMaskPart(aMask, MaskPartParamStr, MaskPartType) do
        begin
          if MaskPartType = mtOptionalNumbers then
            Inc(OptionalNumberCount)
          else
            if MaskPartType <> mtNumbers then
              OptionalNumberCount := 0;

          case MaskPartType of
            mtMaskPartCustomChars:
              if pos('%', MaskPartParamStr) = 0 then       // Optional char ?
                Result := false;

            mtNumbers, mtOptionalNumbers:
              if OptionalNumberCount > 0                   // Optional number ?
              then dec(OptionalNumberCount)
              else Result := false;
          end;
        end;

        if Result then
          Result := aMask = '';
      end;

begin
  Result := true;
  if aMask = '' then Exit;

  OptionalNumberCount := 0;
  while GetNextMaskPart(aMask, MaskPartParamStr, MaskPartType) do
  begin
    if MaskPartType = mtOptionalNumbers then
      Inc(OptionalNumberCount)
    else
      if MaskPartType <> mtNumbers then
        OptionalNumberCount := 0;

    if aString = '' then
    begin
      Result := false;
      if MaskPartType = mtMaskPartCustomChars then MaskPartParamStr := '[' + MaskPartParamStr + ']';
      if MaskPartType = mtMaskPartStringValue then MaskPartParamStr := cQuoteChar + MaskPartParamStr + cQuoteChar;
      aMask := MaskPartParamStr + aMask;
    end
    else
      case MaskPartType of
        mtUndefined:
          Result := false;

        mtMaskPartStringValue:
        begin
          Result := pos(MaskPartParamStr, aString) = 1;

          if Result
          then Delete(aString, 1, length(MaskPartParamStr))
          else aMask := MaskPartParamStr + aMask;
        end;

        mtMaskPartCustomChars:
        begin
          Result := pos(aString[1], MaskPartParamStr) <> 0;

          if Result then
            Delete(aString, 1, 1)
          else
            if pos('%', MaskPartParamStr) <> 0         // Optional char ...
            then Result := true
            else aMask := MaskPartParamStr + aMask;
        end;

        mtAnyChars:
          Delete(aString, 1, 1);

        mtAlphaNumChars:
        begin
          Result := aString[1] in ['0'..'9', 'a'..'z', 'A'..'Z'];

          if Result
          then Delete(aString, 1, 1)
          else aMask := MaskPartParamStr + aMask;
        end;

(*        mtNumbers:
        begin
          Result := aString[1] in ['0'..'9'];

          if Result
          then Delete(aString, 1, 1)
          else aMask := MaskPartParamStr + aMask;
        end;      *)

        mtNumbers, mtOptionalNumbers:
        begin
          Result := aString[1] in ['0'..'9'];

          if Result then
            Delete(aString, 1, 1)
          else
            if OptionalNumberCount > 0 then
            begin
              dec(OptionalNumberCount);
              Result := true;
            end;
        end;

        mtAlphaChars:
        begin
          Result := aString[1] in ['a'..'z', 'A'..'Z'];

          if Result
          then Delete(aString, 1, 1)
          else aMask := MaskPartParamStr + aMask;
        end;

        mtUppLetters:
        begin
          Result := aString[1] in ['A'..'Z'];

          if Result
          then Delete(aString, 1, 1)
          else aMask := MaskPartParamStr + aMask;
        end;

        mtLowLetters:
        begin
          Result := aString[1] in ['a'..'z'];

          if Result
          then Delete(aString, 1, 1)
          else aMask := MaskPartParamStr + aMask;
        end;

        else begin
          if aString[1] in ['a'..'z', 'A'..'Z'] then
            Result := false
          else
            if aString[1] in ['0'..'9'] then
              Result := false;

          if Result
          then Delete(aString, 1, 1)
          else aMask := MaskPartParamStr + aMask;
        end;
      end;

    if not Result then
      Break;
  end;

  if MaskPartType = mtUndefined then
  begin
    aMask := 'Char ' + QuotedStr(MaskPartParamStr) + ' not allowed. See below allowed chars: ' + #13#10 +
             MaskRulesMsg;

    raise Exception.Create(aMask);
  end;

  if aMask <> '' then
  begin
    if aString = '' then
      Result := MaskOptional;
  end
  else
    if Result then
      Result := (aMask = '') and (aString = '');
end;

function IsMatchMask2(const aMask: string; const aString: string): Boolean;
var
  RsltMask, RsltString: string;
begin
  RsltMask := aMask;
  RsltString := aString;
  Result := IsMatchMask(RsltMask, RsltString);
end;

function MergeMaskToMatchedString(var aMask: string; aString: string): String;
var
  MaskPartParamStr: string;
  MaskPartType: TMaskPartType;
  i, MaskPartMin, MaskPartMax, ExpectedNumbers, InsertZeroPos: Integer;
begin
  Result := '';

  InsertZeroPos := 0;
  ExpectedNumbers := 0;
  while GetNextMaskPart(aMask, MaskPartParamStr, MaskPartType) do
  begin
    if MaskPartType in [mtNumbers, mtOptionalNumbers] then
    begin
      if InsertZeroPos = 0 then
        InsertZeroPos := Length(Result) + 1;

      Inc(ExpectedNumbers);
    end
    else begin
      for i := 1 to ExpectedNumbers do
        Insert('0', Result, InsertZeroPos);

      ExpectedNumbers := 0;
      InsertZeroPos := 0;
    end;

    case MaskPartType of
      mtUndefined:
        Break;

      mtMaskPartStringValue:
      begin
        Result := Result + MaskPartParamStr;
        Delete(aString, 1, length(MaskPartParamStr));
      end;

      mtMaskPartCustomChars:
      begin
        if MaskPartParamStr[1] <> '%' then
          Result := Result + MaskPartParamStr[1];  // We consider that the first char is the goog one

        if aString <> '' then
          if pos(aString[1], MaskPartParamStr) <> 0 then
            Delete(aString, 1, 1)
          else
            if pos('%', MaskPartParamStr) = 0 then        // No optional char ...
              Delete(aString, 1, 1);
      end;

      mtNumbers, mtOptionalNumbers:
      begin
        if aString = '' then
        begin
          // Add optional numbers :
          for i := 1 to ExpectedNumbers do
            Insert('0', Result, InsertZeroPos);

          ExpectedNumbers := 0;
          Continue;
        end;

        if aString[1] in ['0'..'9'] then
        begin
          Result := Result + aString[1];
          Delete(aString, 1, 1);
          dec(ExpectedNumbers);
        end
        else begin
          // Add optional numbers :
          for i := 1 to ExpectedNumbers do
            Insert('0', Result, InsertZeroPos);

          ExpectedNumbers := 0;
          Continue;
        end;
      end;

      else begin
        if aString = '' then
          raise Exception.Create('String does not match mask !');

        Result := Result + aString[1];
        Delete(aString, 1, 1);
      end;
    end;
  end;

  if MaskPartType = mtUndefined then
  begin
    aMask := 'Char ' + QuotedStr(MaskPartParamStr) + ' not allowed. See below allowed chars: ' + #13#10 +
             MaskRulesMsg;

    raise Exception.Create(aMask);
  end;
end;

function MergeMaskToMatchedString2(const aMask: string; const aString: string): String;
var
  RsltMask, ParamString: string;
begin
  RsltMask := aMask;
  ParamString := aString;

  Result := MergeMaskToMatchedString(RsltMask, ParamString);
end;

end.
