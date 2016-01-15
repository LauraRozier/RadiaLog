unit ThimoUtils;

{$I ../../RadiaLog.inc}

interface
uses
  Forms,
  {$IFDEF MSWindows} Windows, {$ENDIF}
  {$IFDEF Unix} LCLType, {$ENDIF}
  {$IFDEF WDC} ShellApi {$ENDIF}
  {$IFDEF FPC} LCLIntf, UTF8Process, LazHelpHTML {$ENDIF};

function BrowseURL(const URL: string = 'http://www.thibmoprograms.com/'): Boolean;
procedure MailTo(Subject, Body: string; Address: string = 'thibmorozier@gmail.com');

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

  {$IFDEF WDC}
    // ShellExecute returns > 32 if successful, or an error value <= 32
    if ShellExecute(Application.Handle, 'open', PChar(URL), nil, nil, SW_SHOWNORMAL) > 32 then
      Result := True;
  {$ENDIF}

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
  {$ENDIF}
end;


{ Original by Krom }
procedure MailTo(Subject, Body: string; Address: string = 'thibmorozier@gmail.com');
begin
  BrowseURL('mailto:' + Address + '?subject=' + Subject + '&body=' + Body);
end;

end.
