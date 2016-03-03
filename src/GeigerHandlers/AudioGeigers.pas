unit AudioGeigers;

{
  This is the audio handeling unit file of RadiaLog.
  File GUID: [BA9DDA90-B79E-4199-88B9-87BFFC4B5FF4]

  Copyright (C) 2016 Thimo Braker thibmorozier@gmail.com

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  MA 02111-1307, USA.
}

interface
uses
  // System units
  SysUtils, Classes, Math,
  // OpenAL unit
  OpenAL,
  // Custom units
  GeigerMethods, Defaults, ThimoUtils;

var
  fDefaultDevice, fDeviceList: PAnsiChar;
  fDefDeviceStr: PAnsiChar;

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
      constructor Create(aThreshold: Double; CreateSuspended: Boolean = False); overload;
      constructor Create(aThreshold: Double; aPort: string; CreateSuspended: Boolean = False); overload;
      destructor Destroy; override;
      property DefaultDevice: string read GetDevStr;
      property ChosenDevice:  string read fChosenDevice write fChosenDevice;
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
     fDefDeviceStr  := fDefaultDevice;
     fDeviceList    := alcGetString(nil, ALC_CAPTURE_DEVICE_SPECIFIER);
    end;

    //make devices tstringlist
    aDeviceList.Add(string(fDeviceList));

    for I := 0 to 12 do
    begin
      OldStrCopy(fDeviceList, @fDeviceList[strlen(PChar(aDeviceList.text)) - (I + 1)]);
      if length(fDeviceList) <= 0 then break; //exit loop if no more devices are found
      aDeviceList.Add(string(fDeviceList));
    end;

    aDeviceList[0] := 'Default ('+ aDeviceList[0] +')';
  end;
end;


constructor TAudioGeiger.Create(aThreshold: Double; CreateSuspended: Boolean = False);
begin
  Create(aThreshold, '', CreateSuspended);
end;


constructor TAudioGeiger.Create(aThreshold: Double; aPort: string; CreateSuspended: Boolean = False);
begin
  inherited Create(CreateSuspended);
  fSumCPM       := 0;
  fChosenDevice := aPort;
  fTreshold     := aThreshold;
end;


procedure TAudioGeiger.Execute;
var
  I, J: Integer;
  DateTime: string;
  CurRMS: Double;
  numSamples: Integer;
begin
  inherited;
  // Prepare audio source
  if not fIsSoundInitialized then
    raise exception.create('Could not initialize OpenAL!');

  if fChosenDevice = '' then
    fCaptureDevice := alcCaptureOpenDevice(nil, // Device name pointer
                                           GEIGER_SAMPLE_RATE, // Frequency
                                           IfThen(GEIGER_CHANNELS = 2, AL_FORMAT_STEREO16, AL_FORMAT_MONO16), // Format
                                           Trunc(Length(fData) Div GEIGER_CHANNELS)) // Buffer size
  else
    fCaptureDevice := alcCaptureOpenDevice(PChar(fChosenDevice), // Device name pointer
                                           GEIGER_SAMPLE_RATE, // Frequency
                                           IfThen(GEIGER_CHANNELS = 2, AL_FORMAT_STEREO16, AL_FORMAT_MONO16), // Format
                                           Trunc(Length(fData) Div GEIGER_CHANNELS)); // Buffer size

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
    updatePlot(fSumCPM);
    updateCPMBar(fSumCPM);
    updateDosiLbl(fSumCPM);
    fNetworkHandler.UploadData(fSumCPM, fErrorLog);
  end;
end;


destructor TAudioGeiger.Destroy;
begin
  inherited;
  alcCaptureStop(fCaptureDevice);
  alcCaptureCloseDevice(fCaptureDevice);
  fCaptureDevice := nil;
  AlutExit;
end;


function TAudioGeiger.GetDevStr: AnsiString;
begin
  result := fDefDeviceStr;
end;

end.
