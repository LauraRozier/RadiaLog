unit GeigerMethods;

interface
uses
  // System units
  Windows, Math, Classes, SysUtils,
  // Asynch Pro units
  // AdPort, OoMisc,
  // OpenAL unit
  OpenAL,
  // VCL units
  VCL.ComCtrls,
  // Custom units
  NetworkMethods;

type
  TParity = (pNone, pOdd, pEven, pMark, pSpace);

  TBaseGeigerMethod = class(TThread)
    protected
      fSumCPM: Integer;
      fCPMLog, fErrorLog: TRichEdit;
      fNetworkHandler: TNetworkController;
      procedure Execute; override;
    public
      constructor Create(CreateSuspended: Boolean = False);
      destructor Destroy; override;
  end;

  TMethodSerial = class(TBaseGeigerMethod)
    protected
	    fPortAddress: Integer;
	    fPortBaud: Integer;
	    fPortParity: TParity;
	    fPortDataBits: Word;
	    fPortStopBits: Word;
      fComHandle: THandle;
	    // fComPort: TApdComPort;
    public
      constructor Create(aPort, aBaud: Integer; aParity: TParity;
                         aDataBits, aStopBits: Word;
                         CreateSuspended: Boolean = False);
      destructor Destroy; override;
      function OpenCOMPort: Boolean;
      function SetupCOMPort: Boolean;
      procedure SendText(aText: string);
      procedure ReadText(var aArray; aCount: DWORD);
      procedure CloseCOMPort;
  end;

  TMethodAudio = class(TBaseGeigerMethod)
    private
      fIsSoundInitialized: Boolean;
    public
      constructor Create(CreateSuspended: Boolean = False);
      destructor Destroy; override;
      property Initialized: Boolean Read fIsSoundInitialized;
  end;

implementation
constructor TBaseGeigerMethod.Create(CreateSuspended: Boolean = False);
begin
  inherited Create(CreateSuspended);
  fNetworkHandler := TNetworkController.Create;
end;


destructor TBaseGeigerMethod.Destroy;
begin
  inherited;
  FreeAndNil(fNetworkHandler);
end;


procedure TBaseGeigerMethod.Execute;
begin
  FreeOnTerminate := True;
end;


constructor TMethodSerial.Create(aPort, aBaud: Integer; aParity: TParity;
                                 aDataBits, aStopBits: Word;
                                 CreateSuspended: Boolean = False);
begin
  inherited Create(CreateSuspended);
  // fComPort      := TApdComPort.Create(nil);
  fPortAddress  := aPort;
  fPortBaud     := aBaud;
  fPortParity   := aParity;
  fPortDataBits := aDataBits;
  fPortStopBits := aStopBits;
end;


destructor TMethodSerial.Destroy;
begin
  inherited;
  // fComPort.DonePort;
  // fComPort.Open := False;
  // FreeAndNil(fComPort);
  CloseCOMPort;
end;


function TMethodSerial.OpenCOMPort: Boolean;
begin
  fComHandle := CreateFile(PChar('COM' + IntToStr(fPortAddress)),
                           GENERIC_READ or GENERIC_WRITE,
                           0,
                           nil,
                           OPEN_EXISTING,
                           FILE_ATTRIBUTE_NORMAL,
                           0);

  if fComHandle = INVALID_HANDLE_VALUE then
    Result := False
  else
    Result := True;
end;


function TMethodSerial.SetupCOMPort: Boolean;
const
  RxBufferSize = 256;
  TxBufferSize = 256;
var
  DCB: TDCB;
  Config: string;
  TimeoutBuffer: PCOMMTIMEOUTS;
  ParityStr: string;
begin
  Result := True;

  if not SetupComm(fComHandle, RxBufferSize, TxBufferSize) then
    raise Exception.Create('Could not setup serial port!');

  if not GetCommState(fComHandle, DCB) then
    raise Exception.Create('Could not get port state!');

  case fPortParity of
    pMark:  ParityStr := 'm';
    pOdd:   ParityStr := 'o';
    pEven:  ParityStr := 'e';
    pNone:  ParityStr := 'n';
    pSpace: ParityStr := 's';
  end;

  Config := 'baud='    + IntToStr(fPortBaud) +
            ' parity=' + ParityStr +
            ' data='   + IntToStr(fPortDataBits) +
            ' stop='   + IntToStr(fPortStopBits);

  //if not BuildCommDCB(PChar(Config), DCB) then
    //raise Exception.Create('Could not build port config!');

  //if not SetCommState(fComHandle, DCB) then
    //raise Exception.Create('Could not set port state!');

  GetMem(TimeoutBuffer, sizeof(COMMTIMEOUTS));

  if not GetCommTimeouts(fComHandle, TimeoutBuffer^) then
    raise Exception.Create('Could not get timeouts!');

  TimeoutBuffer.ReadIntervalTimeout := 300;
  TimeoutBuffer.ReadTotalTimeoutMultiplier := 300;
  TimeoutBuffer.ReadTotalTimeoutConstant := 300;

  if not SetCommTimeouts(fComHandle, TimeoutBuffer^) then
    raise Exception.Create('Could not set timeouts!');

  FreeMem(TimeoutBuffer, sizeof(COMMTIMEOUTS));

  //if not GetCommTimeouts(fComHandle, CommTimeouts) then
    //Result := False;

  //if not SetCommTimeouts(fComHandle, CommTimeouts) then
    //Result := False;
end;


procedure TMethodSerial.SendText(aText: string);
var
  BytesWritten: DWORD;
begin
  aText := aText + #13 + #10;
  WriteFile(fComHandle, PChar(aText)^, Length(aText), BytesWritten, nil);
end;


procedure TMethodSerial.ReadText(var aArray; aCount: DWORD);
begin
  if not ReadFile(fComHandle, PChar(aArray)^, SizeOf(aArray), aCount, nil) then
    raise Exception.Create('Could not read from port!');
end;


procedure TMethodSerial.CloseCOMPort;
begin
  CloseHandle(fComHandle);
  FreeAndNil(fComHandle);
end;


constructor TMethodAudio.Create(CreateSuspended: Boolean = False);
begin
  inherited Create(CreateSuspended);
  fIsSoundInitialized := InitOpenAL;
  // Disable 3D spatialization for speed up
  alDistanceModel(AL_NONE);
  Set8087CW($133F);
end;


destructor TMethodAudio.Destroy;
begin
  inherited;
end;

end.
