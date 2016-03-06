unit ThimoUtils;
{
  This is the utilities unit file of RadiaLog.
  File GUID: [46A1BCA6-2B57-4456-A868-5EC8FDFD95EB]

  Contributor(s):
    Thimo Braker (thibmorozier@gmail.com)

  Copyright (C) 2016 Thimo Braker thibmorozier@gmail.com

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  MA 02111-1307, USA.
}

{$I ThimoUtilsH.inc}

implementation

{ Original by Krom }
function BrowseURL(const URL: string = 'http://www.thibmoprograms.com/'): Boolean;
{$IFDEF FPC}
var
  BHelpViewer: THTMLBrowserHelpViewer;
  BrowserPath, BrowserParams: string;
  ParamPos: LongInt;
  BrowserProcess: TProcessUTF8;
{$ENDIF}
begin
  Result := False;
  {$IFDEF FPC}
  BHelpViewer := THTMLBrowserHelpViewer.Create(nil);

  try
    BHelpViewer.FindDefaultBrowser(BrowserPath, BrowserParams);
    ParamPos := System.Pos('%s', BrowserParams);
    System.Delete(BrowserParams, ParamPos, 2);
    System.Insert(URL, BrowserParams, ParamPos);
    // Start browser
    BrowserProcess := TProcessUTF8.Create(nil);

    try
      BrowserProcess.CommandLine := BrowserPath + ' ' + BrowserParams;
      BrowserProcess.Execute;
      Result := True;
    finally
      BrowserProcess.Free;
    end;
  finally
    BHelpViewer.Free;
  end;
  {$ELSE}
  // ShellExecute returns > 32 if successful, or an error value <= 32
  if ShellExecute(Application.Handle, 'open', PChar(URL), nil, nil, SW_SHOWNORMAL) > 32 then
    Result := True;
  {$ENDIF}
end;


{ Original by Krom }
procedure MailTo(Subject, Body: string; Address: string = 'thibmorozier@gmail.com');
begin
  BrowseURL('mailto:' + Address + '?subject=' + Subject + '&body=' + Body);
end;


{ Seems Sqr() is missing in XE8? }
{$IFDEF VER290}
function Sqr(aValue: Single): Single;
begin
  FClearExcept;
  Result := aValue * aValue;
  if aValue < 0.0 then FRaiseExcept(feeINVALID);
  FCheckExcept;
end;


function Sqr(aValue: Double): Double;
begin
  FClearExcept;
  Result := aValue * aValue;
  if aValue < 0.0 then FRaiseExcept(feeINVALID);
  FCheckExcept;
end;


function Sqr(aValue: Extended): Extended;
begin
  FClearExcept;
  Result := aValue * aValue;
  if aValue < 0.0 then FRaiseExcept(feeINVALID);
  FCheckExcept;
end;


function Sqr(aValue: Byte): Byte;
begin
  FClearExcept;
  Result := aValue * aValue;
  FCheckExcept;
end;


function Sqr(aValue: Word): Word;
begin
  FClearExcept;
  Result := aValue * aValue;
  FCheckExcept;
end;


function Sqr(aValue: Cardinal): Cardinal;
begin
  FClearExcept;
  Result := aValue * aValue;
  FCheckExcept;
end;


function Sqr(aValue: Integer): Integer;
begin
  FClearExcept;
  Result := aValue * aValue;
  if aValue < 0 then FRaiseExcept(feeINVALID);
  FCheckExcept;
end;


function Sqr(aValue: Int64): Int64;
begin
  FClearExcept;
  Result := aValue * aValue;
  if aValue < 0 then FRaiseExcept(feeINVALID);
  FCheckExcept;
end;
{$ENDIF}

end.
