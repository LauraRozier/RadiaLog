unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, OpenAL, Math;

const
  SAMPLES_PER_SECOND = 10;
  TIMESPAN_SECONDS = 10;
  THRESHOLD_DIV = 100000;
  GEIGER_RUN_TIME = TIMESPAN_SECONDS * SAMPLES_PER_SECOND;
  GEIGER_SAMPLE_RATE = 22050;
  GEIGER_CHANNELS = 2;
  GEIGER_BUFFER_SIZE = (GEIGER_SAMPLE_RATE * GEIGER_CHANNELS) Div SAMPLES_PER_SECOND;
  THREAD_WAIT_TIME = 1000 Div SAMPLES_PER_SECOND; // 1 second divided by samples per second

type
  { TAudioThread }
  TAudioThread = class(TThread)
    private
      fSumCPM:        Integer;
      fCaptureDevice: PALCDevice;
      fData:          array [0..GEIGER_BUFFER_SIZE] of SmallInt;
      fLogMemo:       TMemo;
      procedure SetMemo(aMemo: TMemo);
      function GetMemo: TMemo;
    protected
      procedure Execute; override;
    public
      constructor Create(aDevice: PALCchar; CreateSuspended: Boolean = False);
      destructor Destroy; override;
      property LogMemo: TMemo read GetMemo write SetMemo;
  end;

  { TForm1 }
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    cbDevices: TComboBox;
    Label1: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    private
      fAudioThread: TAudioThread;
      procedure EnumAudioDevices;
  end;

var
  Form1: TForm1;

implementation
{$R *.lfm}
{ TForm1 }
procedure TForm1.Button1Click(Sender: TObject);
begin
  //Open (selected) device
  if cbDevices.itemindex = 0 then
    fAudioThread := TAudioThread.Create(nil, True) // This is supposed to select the "preferred device"
  else
    fAudioThread := TAudioThread.Create(PChar(cbDevices.Items[cbDevices.itemindex]), True); // Use the chosen one

  fAudioThread.LogMemo := Memo1;
  fAudioThread.Start;
end;


procedure TForm1.Button2Click(Sender: TObject);
begin
  if not (Pointer(TObject(fAudioThread)) = nil) then
  begin
    fAudioThread.Terminate;
    FreeAndNil(fAudioThread);
  end;
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
  EnumAudioDevices;
end;


procedure TForm1.EnumAudioDevices;
var
  defaultDevice: PAnsiChar;
  deviceList: PAnsiChar;
  devices: TStringList;
  I: Integer;
begin
  InitOpenAL;
  defaultDevice := '';
  deviceList := '';

  if alcIsExtensionPresent(nil,'ALC_ENUMERATION_EXT') then
  begin
   defaultDevice := alcGetString(nil, ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER);
   deviceList := alcGetString(nil, ALC_CAPTURE_DEVICE_SPECIFIER);
  end;

  devices := TStringList.Create;
  //make devices tstringlist
  devices.Add(string(devicelist));

  for I := 0 to 12 do
  begin
    StrCopy(Devicelist, @Devicelist[strlen(PChar(devices.text)) - (I + 1)]);

    if length(DeviceList) <= 0 then break; //exit loop if no more devices are found

    devices.Add(string(Devicelist));
  end;

  //fill the combobox
  cbDevices.Items.Add('Default ('+defaultDevice+')');
  cbDevices.ItemIndex:=0;
  cbDevices.Items.AddStrings(devices);
  AlutExit;
end;

{ TAudioThread }
constructor TAudioThread.Create(aDevice: PALCchar; CreateSuspended: Boolean = False);
begin
  inherited Create(CreateSuspended);
  InitOpenAL;
  // Disable 3D spatialization for speed up
  alDistanceModel(AL_NONE);
  // Prepare audio source
  fCaptureDevice := alcCaptureOpenDevice(aDevice, // nil,
                                         GEIGER_SAMPLE_RATE, // Only “Ticks”
                                         IfThen(GEIGER_CHANNELS = 2, AL_FORMAT_STEREO16, AL_FORMAT_MONO16),
                                         Trunc(Length(fData) Div GEIGER_CHANNELS));
end;


destructor TAudioThread.Destroy;
begin
  inherited;
  try
    alcCaptureStop(fCaptureDevice);
    alcCaptureCloseDevice(fCaptureDevice);
  finally
    fCaptureDevice := nil;
    AlutExit;
  end;
end;


procedure TAudioThread.Execute;
var
  I, J: Integer;
  CurRMS: Double;
  numSamples: Integer;
begin
  if fCaptureDevice = nil then
    raise exception.create('Capture device is nil!');

  alcCaptureStart(fCaptureDevice);

  while not Terminated do
  begin
    for I := 0 to GEIGER_RUN_TIME - 1 do
    begin
      for J := 0 to THREAD_WAIT_TIME do
      begin
        if Terminated then Exit;
        Sleep(1);
      end;

      // Get number of frames captured
      alcGetIntegerv(fCaptureDevice, ALC_CAPTURE_SAMPLES, 1, @numSamples);
      alcCaptureSamples(fCaptureDevice, @fData, numSamples);
      // Calculate RMS
      CurRMS := 0.0;
      if Terminated then Exit;

      for J := 0 to (numSamples - 1) do
        CurRMS := CurRMS + Sqr(fData[J]);

      CurRMS := Sqrt(CurRMS / numSamples);
      if Terminated then Exit;

      if (CurRMS / THRESHOLD_DIV) >= 0.0300 then
      begin
        Inc(fSumCPM);
        fLogMemo.Lines.Add('Tick at I=' + IntToStr(I) + ' with RMS: ' + FloatToStr(CurRMS));
        fLogMemo.Lines.Add('Tick at I=' + IntToStr(I) + ' with  RMS(Clean): ' + FloatToStr(CurRMS / THRESHOLD_DIV));
      end;
    end;

    fLogMemo.Lines.Add('Cur CPM - ' + IntToStr(fSumCPM));
    if Terminated then Exit;
  end;
end;


procedure TAudioThread.SetMemo(aMemo: TMemo);
begin
  fLogMemo := aMemo;
end;


function TAudioThread.GetMemo: TMemo;
begin
  Result := fLogMemo;
end;

end.

