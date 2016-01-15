unit ThimoControlUtils;

interface
uses
  Forms, SysUtils, StrUtils
  {$IFDEF MSWindows} ,Windows {$ENDIF}
  {$IFDEF Unix} ,LCLType {$ENDIF};

procedure FillString(var Buffer: string; Count: Integer; const Value: Char); overload;
procedure FillString(var Buffer: string; StartIndex, Count: Integer; const Value: Char); overload;
procedure FillWideChar(var Buffer; Count: Integer; const Value: WideChar);
function MakeStr(C: Char; N: Integer): string;
function DelBSpace(const S: string): string;
function DelESpace(const S: string): string;
function DelRSpace(const S: string): string;
function DelChars(const S: string; Chr: Char): string;
function TextToValText(const AValue: string): string;
function TSep: Char;
function DSep: Char;

implementation

procedure FillString(var Buffer: string; Count: Integer; const Value: Char);
begin
  Buffer := StringOfChar(Value, Count);
end;


procedure FillString(var Buffer: string; StartIndex, Count: Integer; const Value: Char);
begin
  if StartIndex <= 0 then
    StartIndex := 1;
  Buffer := Copy(Buffer, 1, StartIndex - 1) + StringOfChar(Value, Count);
end;


procedure FillWideChar(var Buffer; Count: Integer; const Value: WideChar);
var
  P: PLongint;
  Value2: Cardinal;
  CopyWord: Boolean;
begin
  Value2 := (Cardinal(Value) shl 16) or Cardinal(Value);
  CopyWord := Count and $1 <> 0;
  Count := Count div 2;
  P := @Buffer;
  while Count > 0 do
  begin
    P^ := Value2;
    Inc(P);
    Dec(Count);
  end;
  if CopyWord then
    PWideChar(P)^ := Value;
end;


function MakeStr(C: Char; N: Integer): string;
begin
  if N < 1 then
    Result := ''
  else
  begin
    SetLength(Result, N);
    FillString(Result, Length(Result), C);
  end;
end;


function DelChars(const S: string; Chr: Char): string;
var
  I: Integer;
begin
  Result := S;
  for I := Length(Result) downto 1 do
  begin
    if Result[I] = Chr then
      Delete(Result, I, 1);
  end;
end;


function DelBSpace(const S: string): string;
var
  I, L: Integer;
begin
  L := Length(S);
  I := 1;
  while (I <= L) and (S[I] = ' ') do
    Inc(I);
  Result := Copy(S, I, MaxInt);
end;


function DelESpace(const S: string): string;
var
  I: Integer;
begin
  I := Length(S);
  while (I > 0) and (S[I] = ' ') do
    Dec(I);
  Result := Copy(S, 1, I);
end;


function DelRSpace(const S: string): string;
begin
  Result := DelBSpace(DelESpace(S));
end;


function TextToValText(const AValue: string): string;
var
  I, J: Integer;
  CharSet: TSysCharSet;
begin
  Result := DelRSpace(AValue);
  if AValue.Contains(TSEP) then
    Result := DelChars(Result, TSEP);

  if (DSep <> '.') and (TSep <> '.') then
    Result := ReplaceStr(Result, '.', DSEP);
  if (DSep <> ',') and (TSep <> ',') then
    Result := ReplaceStr(Result, ',', DSEP);

  J := 1;
  CharSet := ['0'..'9', '-', '+',
        DSEP,
        TSEP];
  for I := 1 to Length(Result) do
    if CharInSet(Result[I], CharSet) then
    begin
      Result[J] := Result[I];
      Inc(J);
    end;
  SetLength(Result, J);

  if Result = '' then
    Result := '0'
  else
  if Result = '-' then
    Result := '-0';
end;


function TSEP: Char;
begin
  Result := GetLocaleChar(GetThreadLocale, LOCALE_STHOUSAND, ',');
end;


function DSEP: Char;
begin
  Result := GetLocaleChar(GetThreadLocale, LOCALE_SDECIMAL, '.');
end;

end.
