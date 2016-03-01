unit AudioGeigers;

interface
uses
  // System units
  SysUtils, Classes,
  // VCL units
  VCL.ComCtrls,
  // OpenAL unit
  OpenAL,
  // Custom units
  GeigerMethods, Defaults;

var
  fDefaultDevice, fDeviceList: PALCubyte;
  fDefDeviceStr: string;

type
  TAudioEnum = Class(TObject)
    private
      fInitSuccess: Boolean;
    public
      constructor Create;
      destructor Destroy; override;
      procedure GetAudioEnum(aDeviceList: TStringList);
  end;

  
  TAudioGeiger = class(TMethodAudio)
    private
      fCaptureDevice: pALCDevice;                          //- Device used to capture audio
      fCaptureBuffer: array[0..REC_BufferSize] of TALbyte; //- Capture buffer external from openAL, sized as calculated above for 30 second recording
      fSamples: TALInt;                                    //- count of the number of samples recorded
      fChosenDevice: string;
      fSumCPM: Integer;
      fCPMLog, fErrorLog: TRichEdit;
      fStopWork: Boolean;
      fTreshold: Double;
      procedure MeasureAudio;
      function GetDevStr: string;
    protected
      procedure Execute; override;
    public
      constructor Create(aThreshold: Double; aCPMLog, aErrorLog: TRichEdit;
                         CreateSuspended: Boolean = False); overload;
      constructor Create(aThreshold: Double; aPort: string;
                         aCPMLog, aErrorLog: TRichEdit;
                         CreateSuspended: Boolean = False); overload;
      destructor Destroy; override;
      property DefaultDevice: string read GetDevStr;
      property ChosenDevice: string read fChosenDevice write fChosenDevice;
      property StopWork: Boolean read fStopWork write fStopWork;
    published
      property Initialized;
  end;

implementation
constructor TAudioEnum.Create;
begin
  inherited;
  fInitSuccess := InitOpenAL;
end;


destructor TAudioEnum.Destroy;
begin
  inherited;
  AlutExit;
end;


procedure TAudioEnum.GetAudioEnum(aDeviceList: TStringList);
var
  I: Integer;
begin
  //enumerate devices
  fDefaultDevice := '';
  fDeviceList    := '';
  
  if fInitSuccess then
  begin
    Set8087CW($133F);
    
    if alcIsExtensionPresent(nil, 'ALC_ENUMERATION_EXT') then
    begin
     fDefaultDevice := alcGetString(nil, ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER);
     fDefDeviceStr  := string(fDefaultDevice);
     fDeviceList    := alcGetString(nil, ALC_CAPTURE_DEVICE_SPECIFIER);
    end;

    //make devices tstringlist
    aDeviceList.Add(string(fDeviceList));

    for I := 0 to 12 do
    begin
      StrCopy(fDeviceList, @fDeviceList[strlen(PChar(aDeviceList.text)) - (I + 1)]);
      if length(fDeviceList) <= 0 then break; //exit loop if no more devices are found
      aDeviceList.Add(string(fDeviceList));
    end;

    aDeviceList[0] := 'Default ('+ aDeviceList[0] +')';
  end;
end;


constructor TAudioGeiger.Create(aThreshold: Double; aCPMLog, aErrorLog: TRichEdit;
                                CreateSuspended: Boolean = False);
begin
  Create(aThreshold, '', aCPMLog, aErrorLog, CreateSuspended);
end;


constructor TAudioGeiger.Create(aThreshold: Double; aPort: String;
                                aCPMLog, aErrorLog: TRichEdit;
                                CreateSuspended: Boolean = False);
begin
  inherited Create(CreateSuspended);
  fSumCPM       := 0;
  fChosenDevice := aPort;
  fCPMLog       := aCPMLog;
  fErrorLog     := aErrorLog;
  fTreshold     := aThreshold;
end;


procedure TAudioGeiger.Execute;
var
  I: Integer;
  DateTime: string;
begin
  inherited;

  if fChosenDevice = '' then
    fCaptureDevice := alcCaptureOpenDevice(nil,
                                           REC_Frequency, REC_Format,
                                           REC_BufferSize)
  else
    fCaptureDevice := alcCaptureOpenDevice(PChar(fChosenDevice),
                                           REC_Frequency, REC_Format,
                                           REC_BufferSize);

  if fCaptureDevice = nil then
  begin
    raise exception.create('Capture device is nil!');
    exit;
  end;

  while not Terminated do
  begin
    for I := 0 to Trunc(30 / REC_Seconds) do
    begin
      if Terminated then Exit;

      MeasureAudio;
    end;

    if Terminated then Exit;
    DateTime := FormatDateTime('DD-MM-YYYY HH:MM:SS', Now);
    fCPMLog.Lines.Add(DateTime);
    fCPMLog.Lines.Add(#9 + 'Current CPM: ' + IntToStr(fSumCPM) + sLineBreak);
    fNetworkHandler.UploadData(fSumCPM, fErrorLog);
  end;
end;


destructor TAudioGeiger.Destroy;
begin
  inherited;
  fStopWork := True;
  alcCaptureStop(fCaptureDevice);
  fCaptureDevice := nil;
end;


procedure TAudioGeiger.MeasureAudio;
var
  CurRMS: Double;
begin
  alcCaptureStart(fCaptureDevice);

  repeat
    if Terminated then Exit;
    alcGetIntegerv(fCaptureDevice, ALC_CAPTURE_SAMPLES, TALsizei(sizeof(TALint)), @fSamples);
  until fSamples >= REC_Seconds * REC_Frequency;

  //- Capture the samples into our capture buffer
  alcCaptureSamples(fCaptureDevice, @fCaptureBuffer, fSamples);
  alcCaptureStop(fCaptureDevice);
  CurRMS := GetRMS(fCaptureBuffer);

  if CurRMS >= fTreshold then
    Inc(fSumCPM);
end;


function TAudioGeiger.GetDevStr;
begin
  result := fDefDeviceStr;
end;

end.
