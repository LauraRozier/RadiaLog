unit SerialGeigers;

interface
uses
  // System units
  Windows, SysUtils, Classes,
  // Asynch Pro units
  // AdPort, OoMisc,
  // VCL units
  VCL.ComCtrls,
  // Custom units
  GeigerMethods;

type
  TMyGeiger = class(TMethodSerial)
    private
      fStringBuffer: AnsiString;
    protected
      procedure Execute; override;
      procedure triggerAvail(CP: TObject; Count: Word);
    public
      constructor Create(aPort, aBaud: Integer; aParity: TParity;
                         aDataBits, aStopBits: Word;
                         aCPMLog, aErrorLog: TRichEdit;
                         CreateSuspended: Boolean = False); overload;
  end;
implementation
constructor TMyGeiger.Create(aPort, aBaud: Integer; aParity: TParity;
                             aDataBits, aStopBits: Word;
                             aCPMLog, aErrorLog: TRichEdit;
                             CreateSuspended: Boolean = False);
begin
  inherited Create(aPort, aBaud, aParity, aDataBits, aStopBits, CreateSuspended);
  fCPMLog   := aCPMLog;
  fErrorLog := aErrorLog;
end;


procedure TMyGeiger.Execute;
var
  I: Word;
  BytesRead: DWORD;
  DataBuffer: array[0..79] of Char;
  DateTime: string;
begin
  { fComPort.OnTriggerAvail := triggerAvail;
  fComPort.Open           := False;
  fComPort.DeviceLayer    := dlWin32;
  fComPort.RS485Mode      := False;
  fComPort.ComNumber      := fPortAddress;
  fComPort.Baud           := fPortBaud;
  fComPort.Parity         := fPortParity;
  fComPort.DataBits       := fPortDataBits;
  fComPort.StopBits       := fPortStopBits;

  fComPort.InitPort;
  fComPort.Open           := True; }
  if not OpenCOMPort then
    raise Exception.Create('Could not open serial port!');
  SetupCOMPort;


  while not Terminated do
  begin
    Sleep(100);

    ReadText(DataBuffer, BytesRead);

    if Length(DataBuffer) > 0 then
    begin
      for I := 0 to Length(DataBuffer) - 1 do
      begin
        if DataBuffer[I] in [#48..#57] then
          fSumCPM := (fSumCPM * 10) + (Ord(DataBuffer[I]) - 48)
        else
          if DataBuffer[I] in [#32..#126] then // Only accept alpha-numeric Ansi values
            fStringBuffer := fStringBuffer + AnsiChar(DataBuffer[I]);

        if DataBuffer[I] = #7 then
          MessageBeep(0);
      end;

      DateTime := FormatDateTime('DD-MM-YYYY HH:MM:SS', Now);
      fCPMLog.Lines.Add(DateTime);
      fCPMLog.Lines.Add(#9 + 'Raw buffer: '  + string(DataBuffer));
      fCPMLog.Lines.Add(#9 + 'Current CPM: ' + IntToStr(fSumCPM) + sLineBreak);
      fNetworkHandler.UploadData(fSumCPM, fErrorLog);
    end;
  end;

  CloseCOMPort;
end;


procedure TMyGeiger.triggerAvail(CP: TObject; Count: Word);
var
  I: Word;
  fBuffer: array of AnsiChar;
  DateTime: string;
begin
  SetLength(fBuffer, Count);
  Sleep(25);
  // fComPort.GetBlock(fBuffer, Count);

  for I := 0 to Length(fBuffer) - 1 do
  begin
    if fBuffer[I] in [#48..#57] then
      fSumCPM := (fSumCPM * 10) + (Ord(fBuffer[I]) - 48)
    else
      if fBuffer[I] in [#32..#126] then // Only accept alpha-numeric Ansi values
        fStringBuffer := fStringBuffer + fBuffer[I];

    if fBuffer[I] = #7 then
      MessageBeep(0);
  end;

  DateTime := FormatDateTime('DD-MM-YYYY HH:MM:SS', Now);
  fCPMLog.Lines.Add(DateTime);
  fCPMLog.Lines.Add(#9 + 'Raw buffer: '  + string(fBuffer));
  fCPMLog.Lines.Add(#9 + 'Current CPM: ' + IntToStr(fSumCPM) + sLineBreak);
  fNetworkHandler.UploadData(fSumCPM, fErrorLog);
  SetLength(fBuffer, 0);
end;

end.
