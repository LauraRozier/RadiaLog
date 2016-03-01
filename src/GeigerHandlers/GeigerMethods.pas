unit GeigerMethods;

interface
uses
  // System units
  Windows, Math, Classes, SysUtils,
  // Asynch Pro units
  AdPort, OoMisc,
  // OpenAL unit
  OpenAL,
  // VCL units
  VCL.ComCtrls,
  // Custom units
  NetworkMethods;

type
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
	  fComPort: TApdComPort;
	  procedure triggerAvail(CP: TObject; Count: Word); virtual;
    public
      constructor Create(aPort, aBaud: Integer; aParity: TParity;
                         aDataBits, aStopBits: Word;
                         CreateSuspended: Boolean = False);
      destructor Destroy; override;
  end;

  TMethodAudio = class(TBaseGeigerMethod)
    private
      fIsSoundInitialized: Boolean;
    public
      constructor Create(CreateSuspended: Boolean = False);
      destructor Destroy; override;
    published
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
  FreeOnTerminate := False;
end;


constructor TMethodSerial.Create(aPort, aBaud: Integer; aParity: TParity;
                                 aDataBits, aStopBits: Word;
                                 CreateSuspended: Boolean = False);
begin
  inherited Create(CreateSuspended);
  fComPort      := TApdComPort.Create;
  fPortAddress  := aPort;
  fPortBaud     := aBaud;
  fPortParity   := aParity;
  fPortDataBits := aDataBits;
  fPortStopBits := aStopBits;
  
  fComPort.Open        := False;
  fComPort.DeviceLayer := dlWin32;
  fComPort.RS485Mode   := False;
  fComPort.ComNumber   := fPortAddress;
  fComPort.Baud        := fPortBaud;
  fComPort.Parity      := fPortParity;
  fComPort.DataBits    := fPortDataBits;
  fComPort.StopBits    := fPortStopBits;
  fComPort.Open        := True;
end;


destructor TMethodSerial.Destroy;
begin
  inherited;
  fComPort.Open := False;
  fComPort.DonePort;
  FreeAndNil(fComPort);
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
  AlutExit;
end;

end.
