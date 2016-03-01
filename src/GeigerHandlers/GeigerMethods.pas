unit GeigerMethods;

interface
uses
  // System units
  Math, Classes, SysUtils,
  // OpenAL unit
  OpenAL,
  // Custom units
  NetworkMethods;

const
  REC_Seconds    = 0.05;                                    //- We'll record for 30 seconds
  REC_Frequency  = 44100;                                   //- Recording a frequency of 44100
  REC_Format     = AL_FORMAT_MONO16;                        //- Recording 16-bit mono
  REC_BufferSize = 92610;//ShortInt((REC_Frequency * 2) * (REC_Seconds + 1)); //- (frequency * 2bytes(16-bit)) * seconds   92610

type
  TBaseGeigerMethod = class(TThread)
    //private
      // Private stuff
    protected
      fNetworkHandler: TNetworkController;
      procedure Execute; override;
    public
      constructor Create(CreateSuspended: Boolean = False);
      destructor Destroy; override;
    //published
      // Published stuff
  end;

  TMethodSerial = class(TBaseGeigerMethod)
    //private
      // Private stuff
    //protected
      // Protected stuff
    public
      constructor Create(CreateSuspended: Boolean = False);
      destructor Destroy; override;
    //published
      // Published stuff
  end;

  TMethodAudio = class(TBaseGeigerMethod)
    private
      fIsSoundInitialized: Boolean;
   // protected
      // Protected stuff
    public
      constructor Create(CreateSuspended: Boolean = False);
      destructor Destroy; override;
      // function GetRMS(aBlock: array of TALbyte): Extended;
      function GetRMS(aBlock: array of TALbyte): Double;
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


constructor TMethodSerial.Create(CreateSuspended: Boolean = False);
begin
  inherited Create(CreateSuspended);
end;


destructor TMethodSerial.Destroy;
begin
  inherited;
end;


constructor TMethodAudio.Create(CreateSuspended: Boolean = False);
begin
  inherited Create(CreateSuspended);
  fIsSoundInitialized := InitOpenAL;
  Set8087CW($133F);
end;


destructor TMethodAudio.Destroy;
begin
  inherited;
  //alcCloseDevice(fALCaptureDevice);
  //alcCloseDevice(fALDevice);
  AlutExit;
end;


{
  RMS amplitude is the square root of the mean over time of the square of the amplitude.
  Therefor we need to convert this string of bytes (1024 bits length) into a string of 16-bit samples.
  We get one short out of each two chars in the string.
}
{function TMethodAudio.GetRMS(aBlock: array of TALbyte): SmallInt;
var
  I: Integer;
  Sample, SumSquares: Double;
  Count: Word;
begin
  SumSquares := 0.0;
  Count := Length(aBlock) div 2;

  for I := 0 to Count - 1 do
  begin
    // Sample is a signed short in +/- 32768. Normalize it to 1.0
    Sample := PSmallInt(SmallInt(@aBlock[0]) + I * 2)^;// * (1.0 / 32768.0);
    SumSquares := SumSquares + (Sample * Sample);
  end;

  result := Sqrt((SumSquares / Count));
end; }
function TMethodAudio.GetRMS(aBlock: array of TALbyte): Double;
var
  singleValue: Double;
  //I: Integer;
 // Sample, SumSquares: Double;
  Count: Word;
begin
  Result := 0;
  Count  := Length(aBlock) div 2;

  for singleValue in aBlock do
    Result := Result + (singleValue * singleValue);
  if Result > 0 then
    Result := Sqrt(Result / Count);//Length(aBlock));

  {SumSquares := 0.0;

  for I := 0 to Count - 1 do
  begin
    // Sample is a signed short in +/- 32768. Normalize it to 1.0
    Sample := ntohs(PWord(@data[offset])^);
    //Double(ShortInt(@aBlock[0]) + I * 2)^;// * (1.0 / 32768.0);
    SumSquares := SumSquares + (Sample * Sample);
  end;

  result := Sqrt((SumSquares / Count));   }
end;

end.
