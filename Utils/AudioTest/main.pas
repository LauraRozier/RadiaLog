unit Main;

{$mode objfpc}{$H+}

interface

uses
  Windows, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, OpenAL, Math;

const
  SAMPLES_PER_SECOND = 10;
  TIMESPAN_SECONDS = 10;
  THRESHOLD_DIV = 100000;
  GEIGER_RUN_TIME = TIMESPAN_SECONDS * SAMPLES_PER_SECOND;
  GEIGER_SAMPLE_RATE = 22050;
  GEIGER_ALPHA_NUM = 0.4;
  GEIGER_CHANNELS = 2;
  GEIGER_BUFFER_SIZE = (GEIGER_SAMPLE_RATE * GEIGER_CHANNELS) Div SAMPLES_PER_SECOND;

type
  { TAudioThread }
  TAudioThread = class(TThread)
    private
      fSumCPM: Integer;
      fCaptureDevice: PALCDevice;
      fData: array [0..GEIGER_BUFFER_SIZE] of SmallInt;
      fLogMemo: TMemo;
      procedure SetMemo(aMemo: TMemo);
      function GetMemo: TMemo;
    protected
      procedure Execute; override;
    public
      constructor Create(CreateSuspended: Boolean = False);
      destructor Destroy; override;
      property LogMemo: TMemo read GetMemo write SetMemo;
  end;

  { TForm1 }
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    private
      fAudioThread: TAudioThread;
    public
      { public declarations }
  end;

var
  Form1: TForm1;

implementation
{$R *.lfm}
{ TForm1 }
procedure TForm1.Button1Click(Sender: TObject);
begin
  fAudioThread := TAudioThread.Create(True);
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


constructor TAudioThread.Create(CreateSuspended: Boolean = False);
begin
  inherited Create(CreateSuspended);
  InitOpenAL;
  // Disable 3D spatialization for speed up
  alDistanceModel(AL_NONE);
  // Prepare audio source

  if GEIGER_CHANNELS = 2 then
    fCaptureDevice := alcCaptureOpenDevice(nil,
                                           GEIGER_SAMPLE_RATE, // Only “Ticks”
                                           AL_FORMAT_STEREO16,
                                           Trunc(Length(fData) Div GEIGER_CHANNELS))
  else
    fCaptureDevice := alcCaptureOpenDevice(nil,
                                           GEIGER_SAMPLE_RATE, // Only “Ticks”
                                           AL_FORMAT_MONO16,
                                           Trunc(Length(fData) Div GEIGER_CHANNELS));
end;

destructor TAudioThread.Destroy;
begin
  inherited;
  try
    alcCaptureStop(fCaptureDevice);
    alcCaptureCloseDevice(fCaptureDevice);
    fCaptureDevice := nil;
  finally
    AlutExit;
    // ExitThread(1);
  end;
end;

procedure TAudioThread.Execute;
var
  I, J: Integer;
  CurRMS, rmsSmooth, CurDB: Double;
  numSamples: Integer;
begin
  if fCaptureDevice = nil then
    raise exception.create('Capture device is nil!');

  alcCaptureStart(fCaptureDevice);

  while not Terminated do
  begin
    for I := 0 to GEIGER_RUN_TIME - 1 do
    begin
      for J := 0 to 100 do
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
        rmsSmooth := 0;
        rmsSmooth := rmsSmooth * GEIGER_ALPHA_NUM + (1 - GEIGER_ALPHA_NUM) * CurRMS;
        CurDB := 20.0 * log10(rmsSmooth / (1 << 15));
        fLogMemo.Lines.Add('Tick at I=' + IntToStr(I) + ' with: ' + FloatToStr(CurDB) + ' dB');
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

