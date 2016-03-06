{   Unit VCL.cyWinUtils

    Description:
    Unit with windows functions.

    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    $  €€€ Accept any PAYPAL DONATION $$$  €
    $      to: mauricio_box@yahoo.com      €
    €€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

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

unit VCL.cyWinUtils;

{$I cyCompilerDefines.inc}

interface

uses Windows, Forms, Messages, WinSpool, Winsock, classes, SysUtils, ShellAPI, ShlObj, ComObj, ActiveX, cyStrUtils, VCL.cySysUtils;

type
  TWindowsVersion = (wvUnknown, wvWin31, wvWin95, wvWin98, wvWinMe, wvWinNt3, wvWinNt4, wvWin2000, wvWinXP, wvWinVista,wvWin7, wvWin8, wvWin8_Or_Upper);
  TMacAddress = Array[0..5] of Byte;

  // WesternString = type AnsiString(1252);

  function ShellGetExtensionName(FileName: String): String;
  // Get file extension description

  function ShellGetIconIndex(FileName: String): Integer;
  // Volta o indexo do icon do ficheiro que se vê no Windows Explorer ...

  function ShellGetIconHandle(FileName: String): HIcon;
  // Get file icon handle

  procedure ShellThreadCopy(App_Handle: THandle; fromFile: string; toFile: string);
  // Copy file using Windows Explorer dialog

  procedure ShellThreadMove(App_Handle: THandle; fromFile: string; toFile: string);
  // Move file using Windows Explorer dialog

  function ShellRenameDir(DirFrom, DirTo: string): Boolean;
  // Rename directory using Windows Explorer API

  function ShellDelDir(Dir: String): Boolean;
  // Delete directory and its contents

  function ShellExecute(Operation, FileName, Parameters, Directory: String; ShowCmd: Integer): Cardinal; overload;
  // Like ShellExecute but without PCHar()

  procedure ShellExecute(ExeFilename, Parameters, ApplicationName, ApplicationClass: String; Restore: Boolean); overload;
  // Run exe with restore option

  procedure ShellExecuteAsModal(ExeFilename, ApplicationName, Directory: String);
  // ShellExecute and wait until exe closed

  procedure ShellExecuteExAsAdmin(hWnd: HWND; Filename: string; Parameters: string);
  // ShellExecute with Admin rights (Windows dialog with confirmation appears) ...

  function ShellExecuteEx(aFileName: string; const Parameters: string = ''; const Directory: string = ''; const WaitCloseCompletion: boolean = false): Boolean;

  procedure RestoreAndSetForegroundWindow(Hnd: Integer);
  // Restaura o programa especificado.

  function RemoveDuplicatedPathDelimiter(Str: String): String;

  function FileTimeToDateTime(_FT: TFileTime): TDateTime;

  function GetModificationDate(Filename: String): TDateTime;

  function GetCreationDate(Filename: String): TDateTime;

  function GetLastAccessDate(Filename: String): TDateTime;

  function FileDelete(Filename: String): Boolean;
  // Delete any file (ReadOnly or not)

  function FileIsOpen(Filename: string): boolean;

  procedure FilesDelete(FromDirectory: String; Filter: ShortString);

  function DirectoryDelete(Directory: String): Boolean;

  function GetPrinters(PrintersList: TStrings): Integer;

  procedure SetDefaultPrinter(PrinterName: String);

  procedure ShowDefaultPrinterWindowProperties(FormParent_Handle: Integer);

  function WinToDosPath(WinPathName: String): String;

  function DosToWinPath(DosPathName: String) : String;

  function GetWindowsVersion: TWindowsVersion;

  function NTSetPrivilege(sPrivilege: string; bEnabled: Boolean): Boolean;

  procedure WindowsShutDown(Restart: boolean);

  procedure CreateShortCut(FileSrc, Parametres, FileLnk, Description, DossierDeTravail, FileIcon: string; NumIcone: integer);

  procedure GetWindowsFonts(FontsList: TStrings);

  function GetNextSameFilename(fromFileName: String): String;

  function GetAvailableFilename(DesiredFileName: String): String;

  function ShellUnzipFile(zipfile, targetfolder: string; const filter: string = ''): Boolean;

  function ChangeSystemDate(NewDate: TDate): Boolean;

  procedure SleepMicroS(MicroS: int64);

  function FindWindowsComputer(WindowsComputerName: string): Boolean;

  function GetWindowsComputerName: String;

  function GetWindowsComputerIP(WindowsComputerName: string): string;

  function MacAddressToString(const MacAddress: TMacAddress; const Delimiter: char = '-') : string;

  function StrToMacAddress(var MacAddress: TMacAddress; const MacStr: string; const Delimiter: char = '-'): Boolean;

  function IPToMacAddress(AdresseIP: string): string;

  function ExtractFileSubDirs(const fromFile: String; const SubDirsCount: Integer): String;

  function ChangeFileName(const aFile: string; const NewFilename: String; const NewExtension: Boolean = true): String;

implementation

function ShellGetExtensionName(FileName: String): String;
var
  {$IFDEF DELPHI2009_OR_ABOVE}
  FileInfo: _SHFileInfoW;
  {$ELSE}
  FileInfo: _SHFileInfoA;
  {$ENDIF}
  ImageListHandle: THandle;
begin
  ImageListHandle := SHGetFileInfo(PChar(FileName),   // Path: PChar
                                   0,                 // dwFileAttibutes: Cardinal
                                   FileInfo,          // Var Psfi: _SHFileInfoA
                                   SizeOf(FileInfo),  // cbFileInfo: Cardinal
                                   SHGFI_TYPENAME);   // uFlags: Cardinal

  RESULT := FileInfo.szTypeName;
end;

function ShellGetIconIndex(FileName: String): Integer;
var
  {$IFDEF DELPHI2009_OR_ABOVE}
  FileInfo: _SHFileInfoW;
  {$ELSE}
  FileInfo: _SHFileInfoA;
  {$ENDIF}
  ImageListHandle: THandle;
begin
  ImageListHandle := SHGetFileInfo(PChar(FileName),         // Path: PChar
                                   0,                       // dwFileAttibutes: Cardinal
                                   FileInfo,                // Var Psfi: _SHFileInfoA
                                   SizeOf(FileInfo),        // cbFileInfo: Cardinal
                                   SHGFI_SYSICONINDEX	);  // uFlags: Cardinal

  RESULT := FileInfo.iIcon;
end;

function ShellGetIconHandle(FileName: String): HIcon;
var
  {$IFDEF DELPHI2009_OR_ABOVE}
  FileInfo: _SHFileInfoW;
  {$ELSE}
  FileInfo: _SHFileInfoA;
  {$ENDIF}
  ImageListHandle: THandle;
begin
  ImageListHandle := SHGetFileInfo(PChar(FileName),   // Path: PChar
                                   0,                         // dwFileAttibutes: Cardinal
                                   FileInfo,                  // Var Psfi: _SHFileInfoA
                                   SizeOf(FileInfo),          // cbFileInfo: Cardinal
                                   SHGFI_ICON);    // uFlags: Cardinal

  RESULT := FileInfo.hIcon;
end;

procedure ShellThreadCopy(App_Handle: THandle; fromFile: string; toFile: string);
var
  {$IFDEF DELPHI2009_OR_ABOVE}
  shellinfo: TSHFileOpStructW;
  {$ELSE}
  shellinfo: TSHFileOpStructA;
  {$ENDIF}
begin
  with shellinfo do
  begin
    wnd   := App_Handle;
    wFunc := FO_COPY;
    pFrom := PChar(fromFile);
    pTo   := PChar(toFile);
  end;

  SHFileOperation(shellinfo);
end;

procedure ShellThreadMove(App_Handle: THandle; fromFile: string; toFile: string);
var 
  {$IFDEF DELPHI2009_OR_ABOVE}
  shellinfo: TSHFileOpStructW;
  {$ELSE}
  shellinfo: TSHFileOpStructA;
  {$ENDIF}
begin
  with shellinfo do
  begin
    wnd   := App_Handle;
    wFunc := FO_MOVE;
    pFrom := PChar(fromFile);
    pTo   := PChar(toFile);
  end;

  SHFileOperation(shellinfo);
end;

function ShellRenameDir(DirFrom, DirTo: string): Boolean;
var
  shellinfo: TSHFileOpStruct;
begin
  with shellinfo do
  begin
    Wnd    := 0;
    wFunc  := FO_RENAME;
    pFrom  := PChar(DirFrom);
    pTo    := PChar(DirTo);
    fFlags := FOF_FILESONLY or FOF_ALLOWUNDO or
              FOF_SILENT or FOF_NOCONFIRMATION;
  end;

  Result := SHFileOperation(shellinfo) = 0;
end;

function ShellDelDir(Dir: String): Boolean;
var fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do begin
    wFunc := FO_DELETE;
    fFlags := FOF_SILENT or FOF_NOCONFIRMATION;
    pFrom := PChar(Dir + #0);
  end;
  Result := (0=ShFileOperation(fos));
end;

function ShellExecute(Operation, FileName, Parameters, Directory: String; ShowCmd: Integer): Cardinal;
var POperation, PFilename, PParameters, PDirectory: PChar;
begin
  POperation := PChar(Operation);
  PFilename := PChar(FileName);
  PParameters := PChar(Parameters);
  PDirectory := PChar(Directory);
  RESULT := ShellAPI.ShellExecute(0, POperation, PFilename, PParameters, PDirectory, ShowCmd);
end;

procedure ShellExecute(ExeFilename, Parameters, ApplicationName, ApplicationClass: String; Restore: Boolean);
var
  HInstancia: Integer;
  PApplicationName, PApplicationClass: PChar;
begin
  if Restore then
  begin
    if Length(ApplicationName) = 0
    then PApplicationName := nil
    else PApplicationName := PChar(ApplicationName);

    PApplicationClass := PChar(ApplicationClass);
    HInstancia := FindWindow(PApplicationClass, PApplicationName);
  end
  else
    HInstancia := 0;

  if HInstancia <> 0
  then RestoreAndSetForegroundWindow(HInstancia)
  else ShellExecute('Open', ExeFilename, Parameters, '', SW_RESTORE);
end;

procedure ShellExecuteAsModal(ExeFilename, ApplicationName, Directory: String);
var
 StartupInfo: Tstartupinfo;
 ProcessInfo: TprocessInformation;
 PExeFilename, PApplicationName, PDirectory: PChar;
begin
  PExeFilename := PChar(ExeFilename);

  if ApplicationName <> ''
  then PApplicationName := PChar(ApplicationName)
  else PApplicationName := Nil;

  PDirectory := PChar(Directory);

  FillChar(startupinfo,sizeof(Tstartupinfo),0);
  StartupInfo.cb:=sizeof(Tstartupinfo);

  if CreateProcess(PApplicationName, PExeFilename, nil, nil, false, normal_priority_class, nil, PDirectory, Startupinfo, Processinfo) then
    WaitForSingleObject(ProcessInfo.hprocess, infinite);

  Closehandle(ProcessInfo.hprocess);
end;

procedure ShellExecuteExAsAdmin(hWnd: HWND; Filename: string; Parameters: string);
var
  sei: TShellExecuteInfo;
begin
  FillChar(sei, SizeOf(sei), 0);
  sei.cbSize := sizeof(sei);
  sei.Wnd := hWnd;
  sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
  sei.lpVerb := 'runas';
  sei.lpFile := PChar(Filename);
  sei.lpParameters := PChar(Parameters);
  sei.nShow := SW_SHOWNORMAL;
  if not ShellAPI.ShellExecuteEx(@sei) then
    RaiseLastOSError;
end;

function ShellExecuteEx(aFileName: string; const Parameters: string = ''; const Directory: string = ''; const WaitCloseCompletion: boolean = false): Boolean;
 var
   SEInfo: TShellExecuteInfo;
   ExitCode: DWORD;
   Wait: Boolean;
begin
   FillChar(SEInfo, SizeOf(SEInfo), 0) ;
   SEInfo.cbSize := SizeOf(TShellExecuteInfo) ;
   with SEInfo do
   begin
     fMask := SEE_MASK_NOCLOSEPROCESS;
     Wnd := Application.Handle;
     lpFile := PChar(aFileName);
     lpParameters := PChar(Parameters);
     lpDirectory := PChar(Directory);
     nShow := SW_SHOWNORMAL;
   end;

   Result := ShellAPI.ShellExecuteEx(@SEInfo);

   if Result and WaitCloseCompletion then
     repeat
       Application.ProcessMessages;
       GetExitCodeProcess(SEInfo.hProcess, ExitCode);
       Wait := WaitForSingleObject(SEInfo.hProcess, 10000) <> ExitCode;   // Wait max. 10 seconds
     until not Wait;
end;

procedure RestoreAndSetForegroundWindow(Hnd: Integer);
begin
  if IsIconic(Hnd) then
    ShowWindow(Hnd, Sw_Restore);

  SetForegroundWindow(Hnd);
end;

function RemoveDuplicatedPathDelimiter(Str: String): String;
var i   : Integer;
begin
  // Prefix :
  if Copy(Str, 1, 2) = '\\'         // Network path ...
  then Result := '\'
  else Result := '';

  i := Pos('\\', Str);

  while i > 0 do
  begin
    Delete(Str, i, 1);
    i := Pos('\\', Str);
  end;

  Result := Result + Str;
end;

function FileTimeToDateTime(_FT: TFileTime): TDateTime;
var _ST: SYSTEMTIME;
begin
  FileTimeToSystemTime(_FT, _ST);
  Result := SystemTimeToDateTime(_ST);
end;

function GetModificationDate(Filename: String): TDateTime;
var
  SRec: TSearchRec;
begin
  if FindFirst(Filename, FaAnyFile, SRec) = 0
  then Result := FileTimeToDateTime(SRec.FindData.ftLastWriteTime)
  else Result := 0;

  FindClose(SRec);
end;

function GetCreationDate(Filename: String): TDateTime;
var SRec: TSearchRec;
begin
  if FindFirst(Filename, FaAnyFile, SRec) = 0
  then Result := FileTimeToDateTime(SRec.FindData.ftCreationTime)
  else Result := 0;

  FindClose(SRec);
end;

function GetLastAccessDate(Filename: String): TDateTime;
var SRec: TSearchRec;
begin
  if FindFirst(Filename, FaAnyFile, SRec) = 0
  then Result := FileTimeToDateTime(SRec.FindData.ftLastAccessTime)
  else Result := 0;

  FindClose(SRec);
end;

function FileDelete(Filename: String): Boolean;
var
  TryCount: Integer;
begin
  Result := false;
  TryCount := 0;

  if FileExists(Filename) then
    repeat
      SetFileAttributes(PChar(Filename), 0); // Remove ReadOnly ...
      Result := DeleteFile(Filename);

      if not Result then
      begin
        Inc(TryCount);
        Sleep(100);
      end;
    until Result or (TryCount = 100);  // In some cases, the file is locked by some thread and we need to wait some time ...
end;

// IMPORTANT: If file is ReadOnly, FileIsOpen returns True !
function FileIsOpen(Filename: string): boolean;
var
  Attrs: Integer;
  HFileRes: HFILE;
begin
  Result := false;
  if not FileExists(Filename) then
    Exit;

  // Check if file is ReadOnly :
  Attrs := FileGetAttr(fileName);

  if attrs and faReadOnly > 0 then
    Exit;

  HFileRes := CreateFile(PChar(Filename)
    ,GENERIC_READ or GENERIC_WRITE
    ,0
    ,nil
    ,OPEN_EXISTING
    ,FILE_ATTRIBUTE_NORMAL
    ,0);

  Result := (HFileRes = INVALID_HANDLE_VALUE);

  if not(Result) then
    CloseHandle(HFileRes);
end;

procedure FilesDelete(FromDirectory: String; Filter: ShortString);
var SRec: TSearchRec;
begin
  if FromDirectory <> '' then
    if FromDirectory[length(FromDirectory)] <> '\' then
      FromDirectory := FromDirectory + '\';

  if FindFirst(FromDirectory + Filter, faAnyFile, SRec) = 0
  then
    repeat
       if not IsFolder(SRec) then
         FileDelete(FromDirectory + SRec.Name);
    until FindNext(SRec) <> 0;

  FindClose(SRec);
end;

function DirectoryDelete(Directory: String): Boolean;
var
  SR: TSearchRec;
begin
  if Directory <> '' then
    if Directory[length(Directory)] <> '\' then
      Directory := Directory + '\';

  // Remover pastas e ficheiros da pasta :
  if FindFirst(Directory + '*', faAnyFile, SR) = 0
  then
    repeat
       if IsFolder(SR)
       then begin
         if (SR.Name + '.')[1] <> '.' then          // Hidden System folder !
           DirectoryDelete(Directory + SR.Name);
       end
       else
         FileDelete(Directory + SR.Name);
    until FindNext(SR) <> 0;

  FindClose(SR);
  Result := RemoveDir(Directory);
end;

function GetPrinters(PrintersList: TStrings): Integer;
var
  I: Integer;
  ByteCnt : DWORD; //Nb d'octets à réserver pour récupérer le tableau de structures
  StructCnt: DWORD; //Nb de structures récupérees = nb imprimantes
  p : pointer; //pointe sur le tableau de structures retourné par EnumPrinters
  PrinterInfo: PPrinterInfo2; //Pointeur de structures de type _Printer_Info_2
  szCurrentPrinter: PChar;
begin
  Result := -1;
  PrintersList.Clear;
  //initialisation des paramètres
  ByteCnt := 0;
  StructCnt := 0;
  PrinterInfo:=nil;
  p:=nil;

  GetMem(szCurrentPrinter, SizeOf(Char) * 256);                            // Reserver espace memoire ...
  GetProfileString('Windows', 'DEVICE', '', szCurrentPrinter, 254);       // Nome+Info de l' imprimante actuelle ...

  //Cette fonction retourne un pointeur sur les structures des imprimantes
  //Le While permet d'effectuer une réservation suffisante pour le tableau de structures
  while not EnumPrinters(PRINTER_ENUM_LOCAL, nil, 2, p, ByteCnt, ByteCnt,StructCnt) do
    if (GetLastError = ERROR_INSUFFICIENT_BUFFER) then
      p := AllocMem(ByteCnt);

  //Maintenant il ne reste plus qu'à lire le contenu des structures du tableau
  for I := 0 to StructCnt-1 do //On lit chaques structures propre à chaque imprimante
  begin
    //On se déplace dans le tableau de structures
    PrinterInfo := PPrinterInfo2(LongInt(P)+I*sizeof(_Printer_Info_2));
    PrintersList.Add(PrinterInfo.pPrinterName);

    if PrinterInfo.pPrinterName = String_copy(szCurrentPrinter, srFromLeft, ',', False) then
      Result := i;
//    Memo1.lines.add(#9+'Port          ->   '+PrinterInfo.pPortName);
//    Memo1.lines.add(#9+'Pilote        ->   '+PrinterInfo.pDriverName);
//    Memo1.lines.add(#9+'Commentaire   ->   '+PrinterInfo.pComment);
  end;

  FreeMem(szCurrentPrinter, SizeOf(Char) * 256);                         // Libérer espace mémoire ...
end;

procedure SetDefaultPrinter(PrinterName: String);
var szPrinterName, szIniInfo, szSection: PChar;
    Arr_Tmp: Array[0..64] of Char;
begin
  try
    GetMem(szPrinterName,SizeOf(Char) * 256);                            // Reserver espace memoire ...
    GetMem(szIniInfo,SizeOf(Char) * 256);
    GetMem(szSection,10) ;

    StrPCopy(szPrinterName, PrinterName);
    GetProfileString('DEVICES', szPrinterName, nil, szIniInfo, 254) ;    // Recuperer info sur l' imprimante ...

    if szIniInfo^ <> #0 then                                                 // Si info trouvée ...
    begin
      StrCat(szPrinterName,',') ;
      StrCat(szPrinterName,szIniInfo) ;
      WriteProfileString('Windows','DEVICE',szPrinterName) ;             // Changer l' imprimante ...

      // Informer les applications du changement :
      StrCopy(Arr_Tmp, 'windows');
      SendMessage(HWND_BROADCAST, WM_WININICHANGE, 0, LongInt(@Arr_Tmp));

      // StrCopy(szSection,'Windows') ;
      // Ne fonctionne pas avec Win98/ Me : PostMessage(HWND_BROADCAST,WM_WININICHANGE,0,LongInt(szSection)) ;
    end;

    FreeMem(szPrinterName,SizeOf(Char) * 256) ;                          // Libérer espace mémoire ...
    FreeMem(szIniInfo,SizeOf(Char) * 256) ;
    FreeMem(szSection,10) ;
  except
//    on E: EOutOfMemory do ShowMessage(E.Message) ;                       // Pas d' espace mémoire ...
//    on E: EInvalidPointer do ShowMessage(E.Message) ;                    // Erreur de pointeur ...
  end;
end;

procedure ShowDefaultPrinterWindowProperties(FormParent_Handle: Integer);
var szCurrentPrinter: PChar;
    Impressora: String;
    {$IFDEF DCC} // Delphi XE2/XE3 Win 32/64
    HPrt: NativeUInt;
    {$ELSE}
    HPrt: Cardinal;
    {$ENDIF}
begin
  GetMem(szCurrentPrinter,SizeOf(Char) * 256);                            // Reserver espace memoire ...
  GetProfileString('Windows', 'DEVICE', '', szCurrentPrinter, 254);       // Nome+Info de l' imprimante actuelle ...

  Impressora := String_copy(szCurrentPrinter, srFromLeft, ',', False);
  FreeMem(szCurrentPrinter, SizeOf(Char) * 256) ;                         // Libérer espace mémoire ...

  OpenPrinter(PChar(Impressora), HPrt, Nil);   // Handle da impressora
  PrinterProperties(FormParent_Handle, HPrt); // Mostrar janela de config
end;

function WinToDosPath(WinPathName: String): String;
var aTmp: array[0..MAX_PATH] of char;    // MAX_PATH = 260 ...
begin
  if GetShortPathName(PChar(WinPathName),aTmp,Sizeof(aTmp)-1)=0
  then Result := ''
  else Result := StrPas(aTmp);
end;

function DosToWinPath(DosPathName: String) : String;
var aInfo: TSHFileInfo;
    FileDrive: ShortString;
begin
  RESULT := '';

  if DosPathName <> '' then
  begin
    FileDrive := ExtractFileDrive(DosPathName) + '\';

    // Retirer la barre à la fin :
    if DosPathName[length(DosPathName)] = '\'
    then DosPathName := Copy(DosPathName, 1, length(DosPathName) - 1);

    while (Length(DosPathName) > Length(FileDrive))
      and (SHGetFileInfo(PChar(DosPathName),0,aInfo,Sizeof(aInfo),SHGFI_DISPLAYNAME)<>0) do
    begin
      if RESULT = ''
      then Result := String(aInfo.szDisplayName)
      else Result := String(aInfo.szDisplayName) + '\' + RESULT;

      DosPathName := ExtractFileDir(DosPathName);    // Rechercher le nom long du repertoire contenant le fichier/repertoire actuel ...
    end;

    RESULT := FileDrive + RESULT;
  end;
end;

function GetWindowsVersion: TWindowsVersion;
var
  VersionInfo: TOSVersionInfo;
begin
  RESULT := wvUnknown;

  // charger info
  VersionInfo.dwOSVersionInfoSize := SizeOf(VersionInfo);
  GetVersionEx(VersionInfo);

  // en fonction de la version
  case VersionInfo.dwPlatformId of
      // win 3.1
      VER_PLATFORM_WIN32S:
        RESULT := wvWin31;

      // win 95 / 98 / me
      VER_PLATFORM_WIN32_WINDOWS:
        begin
          case VersionInfo.dwMinorVersion of
             // win 95
              0: RESULT := wvWin95;
             // win 98
             10: RESULT := wvWin98;
             // win millenium
             90: RESULT := wvWinMe;
          end;
        end;

      // win nt, 2000, XP ...
      VER_PLATFORM_WIN32_NT :
          case VersionInfo.dwMajorVersion of
             // win nt 3
             3: RESULT := wvWinNt3;
             // win nt4
             4: RESULT := wvWinNt4;
             // win 2000 et xp
             5: begin
                  case VersionInfo.dwMinorVersion of
                       // win 2000
                       0: RESULT := wvWin2000;
                       // win xp
                       1: RESULT := wvWinXP;
                  end;
                end;
             // win Vista
             6: RESULT := wvWinVista;
             7: RESULT := wvWin7;
             8: RESULT := wvWin8;
             else
                RESULT := wvWin8_Or_Upper;
          end;
  end;
end;

function NTSetPrivilege(sPrivilege: string; bEnabled: Boolean): Boolean;
var
  hToken: THandle;
  TokenPriv: TOKEN_PRIVILEGES;
  PrevTokenPriv: TOKEN_PRIVILEGES;
  ReturnLength: Cardinal;
begin
  Result := True;
  // Only for Windows NT/2000/XP and later.
  if not (Win32Platform = VER_PLATFORM_WIN32_NT) then Exit;
  Result := False;

  // obtain the processes token
  if OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken)
  then begin
    try
      // Get the locally unique identifier (LUID) .
      if LookupPrivilegeValue(nil, PChar(sPrivilege), TokenPriv.Privileges[0].Luid)
      then begin
        TokenPriv.PrivilegeCount := 1; // one privilege to set

        case bEnabled of
          True: TokenPriv.Privileges[0].Attributes  := SE_PRIVILEGE_ENABLED;
          False: TokenPriv.Privileges[0].Attributes := 0;
        end;

        ReturnLength := 0; // replaces a var parameter
        PrevTokenPriv := TokenPriv;

        // enable or disable the privilege
        AdjustTokenPrivileges(hToken, False, TokenPriv, SizeOf(PrevTokenPriv),
          PrevTokenPriv, ReturnLength);
      end;
    finally
      CloseHandle(hToken);
    end;
  end;
  // test the return value of AdjustTokenPrivileges.
  Result := GetLastError = ERROR_SUCCESS;
//  if not Result then
//    raise Exception.Create(SysErrorMessage(GetLastError));
end;

procedure WindowsShutDown(Restart: boolean);
var
  osVer: OSVERSIONINFO;
begin
  try
    NTSetPrivilege(SE_SHUTDOWN_NAME, true);
  finally
     Application.ProcessMessages;

     if Restart
     then ExitWindowsEx(EWX_REBOOT or EWX_FORCEIFHUNG, 0)
     else begin
       osVer.dwOSVersionInfoSize := Sizeof(osVer);
       GetVersionEx(osVer);
       if osVer.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS
       then ExitWindowsEx(EWX_SHUTDOWN or EWX_FORCEIFHUNG , 0)
       else ExitWindowsEx(EWX_POWEROFF or EWX_FORCEIFHUNG , 0);
     end;
  end;
end;

procedure CreateShortCut(FileSrc, Parametres, FileLnk, Description, DossierDeTravail, FileIcon: string; NumIcone: integer);
var ShellLink: IShellLink;
begin
  if AnsiUpperCase(extractFileExt(FileLnk)) <> '.LNK'
  then FileLnk := FileLnk + '.lnk';

  ShellLink := CreateComObject(CLSID_ShellLink) as IShellLink;
  ShellLink.SetDescription(PChar(Description));
  ShellLink.SetPath(PChar(FileSrc));
  ShellLink.SetArguments(PChar(Parametres));
  ShellLink.SetWorkingDirectory(PChar(DossierDeTravail));
  ShellLink.SetShowCmd(SW_SHOW);

  if FileIcon <> '' then    ShellLink.SetIconLocation(PChar(FileIcon), NumIcone);  (ShellLink as IpersistFile).Save(StringToOleStr(FileLnk), true);
end;

procedure GetWindowsFonts(FontsList: TStrings);
var
  DC: HDC;

    function EnumFontsProc(var LogFont: TLogFont; var TextMetric: TTextMetric;
        FontType: Integer; Data: Pointer): Integer; stdcall;
    begin
      TStrings(Data).Add(LogFont.lfFaceName);
      Result := 1;
    end;

begin
  FontsList.Clear;
  DC := GetDC(0);
  EnumFonts(DC, nil, @EnumFontsProc, Pointer(FontsList));
  ReleaseDC(0, DC);
end;

function GetNextSameFilename(fromFileName: String): String;
var
  StrExt, StrInc, StrNumber: String;
  i, LengthBaseName, lengthFilname, lengthStrExt: Integer;
begin
  Result := '';
  lengthFilname := length(fromFileName);
  StrExt := ExtractFileExt(fromFileName);
  lengthStrExt := length(StrExt);
  LengthBaseName := lengthFilname - lengthStrExt;

  StrInc := '';
  StrNumber := '';
  for i := lengthFilname - lengthStrExt downto 1 do
  begin
    Dec(LengthBaseName);

    if StrInc = '' then
    begin
      if fromFileName[i] = ')'
      then StrInc := ')'
      else Break;
    end
    else
      case fromFileName[i] of
        '(':
          begin
            StrInc := '()';
            Break;
          end;
        '0'..'9':
          StrNumber := fromFileName[i] + StrNumber;
        else
          Break;
      end;
  end;

  if (StrInc = '()') and (StrNumber <> '') then
  begin
    StrInc := '(' + IntToStr(StrToInt(StrNumber)+1) + ')';
    Result := Copy(fromFileName, 1, LengthBaseName) + StrInc + StrExt;
  end
  else begin
    StrInc := '(1)';
    Result := Copy(fromFileName, 1, lengthFilname - lengthStrExt) + StrInc + StrExt;
  end;
end;

function GetAvailableFilename(DesiredFileName: String): String;
begin
  while FileExists(DesiredFileName) do
    DesiredFileName := GetNextSameFilename(DesiredFileName);

  Result := DesiredFileName;
end;

function ShellUnzipFile(zipfile, targetfolder: string; const filter: string = ''): Boolean;
var
  shellobj: variant;
  srcfldr, destfldr: variant;
  shellfldritems: variant;

const
  SHCONTCH_NOPROGRESSBOX = 4;
  SHCONTCH_AUTORENAME = 8;
  SHCONTCH_RESPONDYESTOALL = 16;
  SHCONTF_INCLUDEHIDDEN = 128;
  SHCONTF_FOLDERS = 32;
  SHCONTF_NONFOLDERS = 64;
begin
  shellobj := CreateOleObject('Shell.Application');

  srcfldr := shellobj.NameSpace(zipfile);
  destfldr := shellobj.NameSpace(targetfolder);

  shellfldritems := srcfldr.Items;
  if (filter <> '') then
    shellfldritems.Filter(SHCONTF_INCLUDEHIDDEN or SHCONTF_NONFOLDERS or SHCONTF_FOLDERS,filter);

  destfldr.CopyHere(shellfldritems, SHCONTCH_NOPROGRESSBOX or SHCONTCH_RESPONDYESTOALL);
end;

function ChangeSystemDate(NewDate: TDate): Boolean;
var SysTime: TSystemTime;
begin
  with SysTime do
  begin
    DecodeDate(SysUtils.Time + NewDate, wYear, wMonth, wDay);
    DecodeTime(SysUtils.Time + Date, wHour, wMinute, wsecond, wMilliseconds);
  end;

  RESULT := SetlocalTime(SysTime);
end;

procedure SleepMicroS(MicroS: int64);
var Frq_Base, Limite, Time_memo, Time_now, dif: Int64;
begin
  {SleepMicroS(1);         = 1 µS
   SleepMicroS(100);           = 100 µS
   SleepMicroS(100000);        = 100 mS
   SleepMicroS(1000000);       = 1 S  }

  if QueryPerformanceFrequency(Frq_Base) then
  begin
    QueryPerformanceCounter(Time_memo); // Repère temps
    Limite := Time_Memo + round(MicroS * Frq_Base / 1000000); // calcul fait une seule fois
    repeat
      QueryPerformanceCounter(Time_now);
    until Time_now >= Limite;
  end;
end;

function FindWindowsComputer(WindowsComputerName: string): Boolean;
var
  WSAData: TWSAData;
  Buffer: AnsiString;
  POrdi: PhostEnt;
begin
  RESULT := false;
  try
    if WSAStartup(2,WSAData) = 0
    then begin
      // Buffer := WesternString(GetComputerName);
      Buffer := AnsiString(WindowsComputerName);
      POrdi := GetHostByName(PAnsiChar(Buffer));
      RESULT := POrdi <> nil;
    end;
  finally
    WSACleanup;
  end;
end;

function GetWindowsComputerName: String;
var
  _Buffer : array[0..255] of widechar;
  _BufferSize : DWORD;
begin
  _BufferSize := SizeOf(_Buffer);
  GetComputerNameW(@_Buffer, _BufferSize);
  RESULT := _buffer;
end;

function GetWindowsComputerIP(WindowsComputerName: string): string;
var
   WSAData : TWSAData;
   Buffer: AnsiString;
   StrIP : String;
   Phe : PHostEnt;
begin
  Result := '';

  // Demarrage du gestionnaire de socket
  if WSAStartup(2,WSAData) = 0 then
    try
      Buffer := AnsiString(WindowsComputerName);
      // Buffer := WesternString(WindowsComputerName);   //
      Phe := GetHostByName(PAnsiChar(Buffer));
      with Phe^ do
      // formatage du resultat en string
      StrIP := Format ('%d.%d.%d.%d' , [Byte(h_addr^[0]),Byte(h_addr^[1]),
                                         Byte(h_addr^[2]),Byte(h_addr^[3])]);
      RESULT := StrIP;
    finally
      // fermeture du gestionnaire de socket
      WSACleanup;
    end;
end;

function MacAddressToString(const MacAddress: TMacAddress; const Delimiter: char = '-'): string;
var
  PResult : PChar;
  i       : integer;
const
  Digits : array[0..15] of Char = '0123456789abcdef';
begin
  // une adresse MAC fait 17 caracteres de long
  SetLength( Result, 17 );
  PResult := PChar(Result);

  for I := 0 to 5 do
  begin
    // on convertis l'octet en texte
    PResult[0] := Digits[MacAddress[I] shr 4];
    PResult[1] := Digits[MacAddress[I] and $F];
    // on ajoute un delimiteur ou non
    if ( i < 5 ) then
    begin
       PResult[2] := Delimiter;
       Inc( PResult, 3 );
    end else
       Inc( PResult, 2 );
  end;
  // Também dá mas em maiusculas:
  // RESULT := format('%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x', [MacAddress[0], MacAddress[1], MacAddress[2], MacAddress[3], MacAddress[4], MacAddress[5]]);
end;

function StrToMacAddress(var MacAddress: TMacAddress; const MacStr : string; const Delimiter : char = '-'): Boolean;
var
  i : integer;
  S : string;
  b1 : Byte;
  b2 : Byte;
begin
  // on supprime le delimiteur
  S := StringReplace(MacStr, Delimiter, '',  [rfReplaceAll]);

  // si la longeur est differente de 12 c'est qu'il y a un probleme
  if Length(S) <> 12 then
    Result := False
  else
  begin
    for i := 0 to 5 do
    begin
      // on recupère la valeur ordinal du caractere et on decremente pour obtenir une valeur entre 0 et 15
      // shl 1 = *2 , un decalage est plus rapide qu'une multiplication
      b1 := Ord( s[(i shl 1) + 1] ) - 48;
      b2 := Ord( s[(i shl 1) + 2] ) - 48;
      if b1 > 15 then dec( b1, 39 );
      if b2 > 15 then dec( b2, 39 );

      MacAddress[i] := ( b1 shl 4 ) + ( b2 and $F );
    end;
    Result := True;
  end;
end;

function IPToMacAddress(AdresseIP: string): string;
var
  ip: DWORD;
  mac: TMacAddress;
  maclen: Cardinal;
  AnsiAdresseIP: AnsiString;
  // Utilizado para chamar a função na dll:
  CardDll: Cardinal;
  FxDll: function(Destip, scrip: DWORD; pmacaddr: PDWORD; var phyAddrlen: DWORD): DWORD; stdCall;
  PMac: PDWORD;
  Pmaclen: DWORD;
begin
  RESULT := '';
  AnsiAdresseIP := AdresseIP;
  ip      := inet_addr( PAnsiChar(AnsiAdresseIP) );
  maclen  := SizeOf(TMacAddress);
  CardDLL := LoadLibrary('iphlpapi.dll');

  if CardDLL <> 0
  then begin
    @FxDll := GetProcAddress(CardDLL, 'SendARP');
    PMac := @MAC;
    Pmaclen := maclen;
    FxDll(ip, 0, PMac, Pmaclen);
    RESULT := MacAddressToString(MAC);
    FreeLibrary(CardDLL);
  end;
end;

function ExtractFileSubDirs(const fromFile: String; const SubDirsCount: Integer): String;
var
  aDir, aSubDir: String;
  i: Integer;
begin
  Result := '';
  aDir := ExtractFileDir(fromFile);

  for i := 1 to SubDirsCount do
  begin
    aSubDir := ExtractFileName(aDir);

    if aSubDir <> '' then
    begin
      if i <> 1 then
        Result := '\' + Result;
      Result := aSubDir + Result;
      aDir := ExtractFileDir(aDir);
    end
    else
      Break;
  end;
end;

function ChangeFileName(const aFile: string; const NewFilename: String; const NewExtension: Boolean = true): String;
var
  CurFileName: String;
begin
  CurFileName := ExtractFilename(aFile);
  Result := RemoveDuplicatedPathDelimiter( ExtractFileDir(aFile) + '\' + NewFilename );

  if not NewExtension then
    Result := Result + ExtractFileExt(aFile);
end;

end.
