unit ThimoUtils;

{$I ../../RadiaLog.inc}

interface
{$IFDEF CPUX86}
  {$DEFINE X86ASM}
{$ELSE !CPUX86}
  {$DEFINE PUREPASCAL}
{$ENDIF !CPUX86}

uses
  Forms,
  {$IFDEF MSWindows} Windows, {$ENDIF}
  {$IFDEF Unix} LCLType, {$ENDIF}
  {$IFDEF WDC} ShellApi {$ENDIF}
  {$IFDEF FPC} LCLIntf, UTF8Process, LazHelpHTML {$ENDIF};

function BrowseURL(const URL: string = 'http://www.thibmoprograms.com/'): Boolean;
procedure MailTo(Subject, Body: string; Address: string = 'thibmorozier@gmail.com');
function OldStrCopy(Dest: PAnsiChar; const Source: PAnsiChar): PAnsiChar;

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


{ To get rid of depricated message. }
{$IFNDEF NEXTGEN}
function OldStrCopy(Dest: PAnsiChar; const Source: PAnsiChar): PAnsiChar;
{$IFDEF PUREPASCAL}
begin
  Move(Source^, Dest^, (StrLen(Source) + 1) * SizeOf(AnsiChar));
  Result := Dest;
end;
{$ELSE !PUREPASCAL}
{$IFDEF X86ASM}
(* ***** BEGIN LICENSE BLOCK *****
 *
 * The function StrCopy is licensed under the CodeGear license terms.
 *
 * The initial developer of the original code is Fastcode
 *
 * Portions created by the initial developer are Copyright (C) 2002-2004
 * the initial developer. All Rights Reserved.
 *
 * Contributor(s): Aleksandr Sharahov
 *
 * ***** END LICENSE BLOCK ***** *)
asm //StackAlignSafe
        SUB   EDX, EAX
        TEST  EAX, 1
        PUSH  EAX
        JZ    @loop
        MOVZX ECX, BYTE PTR[EAX+EDX]
        MOV   [EAX], CL
        TEST  ECX, ECX
        JZ    @RET
        INC   EAX
@loop:
        MOVZX ECX, BYTE PTR[EAX+EDX]
        TEST  ECX, ECX
        JZ    @move0
        MOVZX ECX, WORD PTR[EAX+EDX]
        MOV   [EAX], CX
        ADD   EAX, 2
        CMP   ECX, 255
        JA    @loop
@ret:
        POP   EAX
        RET
@move0:
        MOV   [EAX], CL
        POP   EAX
end;
{$ENDIF X86ASM}
{$ENDIF !PUREPASCAL}
{$ENDIF !NEXTGEN}

end.
