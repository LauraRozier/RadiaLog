unit SerialGeigers;

interface
uses
  // System units
  SysUtils, Classes,
  // Asynch Pro units
  AdPort, OoMisc,
  // VCL units
  VCL.ComCtrls,
  // Custom units
  GeigerMethods;

type
  TMyGeiger = class(TMethodSerial)
    private
      // Private stuff
    protected
      procedure triggerAvail(CP: TObject; Count: Word); override;
    public
      constructor Create(aPort, aBaud: Integer; aParity: TParity;
                         aDataBits, aStopBits: Word;
                         aCPMLog, aErrorLog: TRichEdit;
                         CreateSuspended: Boolean = False); overload;
    published
      // Published stuff
  end;
implementation
constructor TMyGeiger.Create(aPort, aBaud: Integer; aParity: TParity;
                             aDataBits, aStopBits: Word;
                             aCPMLog, aErrorLog: TRichEdit;
                             CreateSuspended: Boolean = False);
begin
  inherited Create(aPort, aBaud, aParity, aDataBits, aStopBits, CreateSuspended);
  fComPort.OnTriggerAvail := triggerAvail;
  fCPMLog                 := aCPMLog;
  fErrorLog               := aErrorLog;
end;


procedure TMyGeiger.triggerAvail(CP: TObject; Count: Word);
var
  I: Word;
  C: AnsiChar;
begin
  if fTimeToWait = -1 then
    fTimeToWait := 1;

  for I := 1 to Count do
  begin
    C := fComPort.GetChar;

    if C = #7 then // COM port asks for system to "bell"
      MessageBeep(0)
    else
      if C in [#32..#126] then // Only accept alpha-numeric Ansi values
        fBuffer := fBuffer + C;
  end;
end;

end.
