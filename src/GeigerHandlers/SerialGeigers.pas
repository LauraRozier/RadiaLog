unit SerialGeigers;

interface
uses
  // System units
  Windows, SysUtils,
  // Asynch Pro units
  AdPort, OoMisc,
  // Custom units
  Defaults, GeigerMethods;

type
  TMyGeiger = class(TMethodSerial)
    private
      fBufferString: AnsiString;
      fBuffer: array of AnsiChar;
      procedure TimerTick(Sender: TObject);
    protected
      procedure triggerAvail(CP: TObject; Count: Word);
    public
      constructor Create(aPort, aBaud: Integer; aParity: TParity;
                         aDataBits, aStopBits: Word;
                         CreateSuspended: Boolean = False); overload;
  end;
implementation
constructor TMyGeiger.Create(aPort, aBaud: Integer; aParity: TParity;
                             aDataBits, aStopBits: Word;
                             CreateSuspended: Boolean = False);
begin
  inherited Create(aPort, aBaud, aParity, aDataBits, aStopBits, CreateSuspended);
  fComPort.OnTriggerAvail := triggerAvail;
  fComPort.Open           := False;
  fComPort.DeviceLayer    := dlWin32;
  fComPort.RS485Mode      := False;
  fComPort.ComNumber      := fPortAddress;
  fComPort.Baud           := fPortBaud;
  fComPort.Parity         := fPortParity;
  fComPort.DataBits       := fPortDataBits;
  fComPort.StopBits       := fPortStopBits;
  fComPort.InitPort;
  fComPort.Open           := True;
  fBufferTimer.OnTimer    := TimerTick;
end;


procedure TMyGeiger.triggerAvail(CP: TObject; Count: Word);
begin
  if not fBufferTimer.Enabled then
  begin
    fBufferTimer.Interval := 300;
    fBufferTimer.Enabled  := True;
  end;

  SetLength(fBuffer, Length(fBuffer) + 1);
  fBuffer[High(fBuffer)] := fComPort.GetChar;
end;


procedure TMyGeiger.TimerTick(Sender: TObject);
var
  I: Integer;
  DateTime: string;
begin
  fBufferTimer.Enabled := False;
  fSumCPM              := 0;
  fBufferString        := '';

  for I := 0 to Length(fBuffer) - 1 do
  begin
    if fBuffer[I] = #7 then
    begin
      MessageBeep(0);
      Exit;
    end;

    if fBuffer[I] in [#32..#126] then // Only accept alpha-numeric Ansi values
      fBufferString := fBufferString + fBuffer[I];

    if fBuffer[I] in [#48..#57] then
      fSumCPM := (fSumCPM * 10) + (Ord(fBuffer[I]) - 48);
  end;

  SetLength(fBuffer, 0);
  DateTime := FormatDateTime('DD-MM-YYYY HH:MM:SS', Now);
  fCPMLog.Lines.Add(DateTime);
  fCPMLog.Lines.Add(#9 + 'Raw buffer: '  + String(fBufferString));
  fCPMLog.Lines.Add(#9 + 'Current CPM: ' + IntToStr(fSumCPM) + sLineBreak);
  updatePlot(fSumCPM);
  updateCPMBar(fSumCPM);
  updateDosiLbl(fSumCPM);
  fNetworkHandler.UploadData(fSumCPM, fErrorLog);
end;

end.
