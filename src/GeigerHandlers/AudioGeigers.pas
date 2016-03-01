unit AudioGeigers;

interface
uses
  // System units
  SysUtils, Classes, Math,
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
      fCaptureDevice: PALCDevice;
      fChosenDevice: string;
      fTreshold: Double;
      // Frequency * Channels (Per full second) + Slack-space
      fData: array [0..GEIGER_BUFFER_SIZE] of SmallInt;
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
  I, J: Integer;
  DateTime: string;
  CurRMS: Double;
  numSamples: Integer;
  capDeviceFormat: TALCenum;
begin
  inherited;
  // Prepare audio source
  if GEIGER_CHANNELS = 2 then
    capDeviceFormat := AL_FORMAT_STEREO16
  else
    capDeviceFormat := AL_FORMAT_MONO16;

  if fChosenDevice = '' then
    fCaptureDevice := alcCaptureOpenDevice(nil,
                                           GEIGER_SAMPLE_RATE,
                                           capDeviceFormat,
                                           Trunc(Length(fData) Div GEIGER_CHANNELS))
  else
    fCaptureDevice := alcCaptureOpenDevice(PChar(fChosenDevice),
                                           GEIGER_SAMPLE_RATE,
                                           capDeviceFormat,
                                           Trunc(Length(fData) Div GEIGER_CHANNELS));

  if fCaptureDevice = nil then
    raise exception.create('Capture device is nil!');
  
  alcCaptureStart(fCaptureDevice);
  
  while not Terminated do
  begin
    for I := 0 to GEIGER_RUN_TIME - 1 do
    begin
      if Terminated then Exit;
  
      Sleep(50);
      // Get number of frames captuered
      alcGetIntegerv(fCaptureDevice, ALC_CAPTURE_SAMPLES, 1, @numSamples);
      alcCaptureSamples(fCaptureDevice, @fData, numSamples); 
      // Calculate RMS
      CurRMS := 0.0; 
	  
      for J := 0 to (numSamples - 1) do
        CurRMS := CurRMS + Sqr(fData[J]);

      CurRMS := Sqrt(CurRMS / numSamples);

      if (CurRMS / THRESHOLD_DIV) >= fTreshold then
        Inc(fSumCPM);
    end;

    if Terminated then Exit;
    DateTime := FormatDateTime('DD-MM-YYYY HH:MM:SS', Now);
    fCPMLog.Lines.Add(DateTime);
    fCPMLog.Lines.Add(#9 + 'Current CPM: ' + IntToStr(fSumCPM) + sLineBreak);
    fNetworkHandler.UploadData(fSumCPM, fErrorLog);
  end;
  
  alcCaptureStop(fCaptureDevice);
  alcCaptureCloseDevice(fCaptureDevice);
end;


destructor TAudioGeiger.Destroy;
begin
  inherited;
  alcCaptureStop(fCaptureDevice);
  alcCaptureCloseDevice(fCaptureDevice);
  fCaptureDevice := nil;
end;


function TAudioGeiger.GetDevStr;
begin
  result := fDefDeviceStr;
end;

end.
