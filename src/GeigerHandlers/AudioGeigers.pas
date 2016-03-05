unit AudioGeigers;

{
  This is the audio handeling unit file of RadiaLog.
  File GUID: [BA9DDA90-B79E-4199-88B9-87BFFC4B5FF4]

  Contributor(s):
    Thimo Braker (thibmorozier@gmail.com)

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
  Windows, Classes, SysUtils, Math, Generics.Collections,
  // VCL units
  VCL.StdCtrls, VCL.ComCtrls, VCL.ExtCtrls, VCL.Graphics,
  // TeeChart units
  VCLTee.Chart,
  // Cindy units
  cySimpleGauge,
  // OpenAL unit
  OpenAL,
  // Custom units
  NetworkMethods, Defaults, ThimoUtils;

type
  TAudioEnum = Class(TObject)
    private
      fInitSuccess: Boolean;
    public
      constructor Create;
      destructor Destroy; override;
      procedure GetAudioEnum(aDeviceList: TStringList);
  end;

  
  TAudioGeiger = class(TThread)
    private
      fSumCPM:             Integer;
      fNetworkHandler:     TNetworkController;
      fIsSoundInitialized: Boolean;
      fConvertFactor:      Double;
      fConvertmR:          Boolean;
      fUploadRM:           Boolean;
      fCPMBar:             TcySimpleGauge;
      fLblCPM, fLblDosi:   TLabel;
      fCPMChart:           TChart;
      fCPMLog, fErrorLog:  TRichEdit;
      fCaptureDevice:      PALCDevice;
      fTreshold:           Double;
      // Frequency * Channels (Per full second) + Slack-space
      fData:               array[0..GEIGER_BUFFER_SIZE] of SmallInt;
      function GetDevStr: string;
    protected
      procedure Execute; override;
    public
      constructor Create(aThreshold: Double; aDevice: PALCchar; CreateSuspended: Boolean = False);
      destructor Destroy; override;
      procedure updateCPMBar(aCPM: Integer);
      procedure updatePlot(aCPM: Integer);
      procedure updateDosiLbl(aCPM: Integer);
      property Initialized:   Boolean        read fIsSoundInitialized;
      property ConvertFactor: Double         read fConvertFactor write fConvertFactor;
      property ConvertmR:     Boolean        read fConvertmR     write fConvertmR;
      property UploadRM:      Boolean        read fUploadRM      write fUploadRM;
      property CPMBar:        TcySimpleGauge read fCPMBar        write fCPMBar;
      property LblCPM:        TLabel         read fLblCPM        write fLblCPM;
      property LblDosi:       TLabel         read fLblDosi       write fLblDosi;
      property CPMChart:      TChart         read fCPMChart      write fCPMChart;
      property CPMLog:        TRichEdit      read fCPMLog        write fCPMLog;
      property ErrorLog:      TRichEdit      read fErrorLog      write fErrorLog;
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
  defaultDevice: PAnsiChar;
  deviceList: PAnsiChar;
  I: Integer;
begin
  // Enumerate devices
  defaultDevice := '';
  deviceList := '';
  
  if fInitSuccess then
  begin
    Set8087CW($133F);
    
    if alcIsExtensionPresent(nil, 'ALC_ENUMERATION_EXT') then
    begin
      defaultDevice := alcGetString(nil, ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER);
      deviceList := alcGetString(nil, ALC_CAPTURE_DEVICE_SPECIFIER);
    end;

    //make devices tstringlist
    aDeviceList.Add(string(devicelist));

    for I := 0 to 12 do
    begin
      ThibStrCopy(Devicelist, @Devicelist[strlen(PChar(aDeviceList.text)) - (I + 1)]);

      if length(DeviceList) <= 0 then break; //exit loop if no more devices are found

      aDeviceList.Add(string(Devicelist));
    end;

    aDeviceList[0] := 'Default ('+ aDeviceList[0] +')';
  end;
end;


constructor TAudioGeiger.Create(aThreshold: Double; aDevice: PALCchar; CreateSuspended: Boolean = False);
begin
  inherited Create(CreateSuspended);
  fSumCPM       := 0;
  fTreshold     := aThreshold;

  if not fIsSoundInitialized then
    raise exception.create('Could not initialize OpenAL!');

  // Prepare audio source
  fCaptureDevice := alcCaptureOpenDevice(aDevice, // Device name pointer
                                         GEIGER_SAMPLE_RATE, // Frequency
                                         IfThen(GEIGER_CHANNELS = 2, AL_FORMAT_STEREO16, AL_FORMAT_MONO16), // Format
                                         Trunc(Length(fData) Div GEIGER_CHANNELS)); // Buffer size
end;


procedure TAudioGeiger.Execute;
var
  I, J: Integer;
  DateTime: string;
  CurRMS: Double;
  numSamples: Integer;
begin
  inherited;
  if fCaptureDevice = nil then
    raise exception.create('Capture device is nil!');

  alcCaptureStart(fCaptureDevice);
  
  while not Terminated do
  begin
    fSumCPM := 0;

    for I := 0 to GEIGER_RUN_TIME - 1 do
    begin
      for J := 0 to THREAD_WAIT_TIME - 1 do
      begin
        if Terminated then Exit;
        Sleep(1);
      end;

      // Get number of frames captuered
      alcGetIntegerv(fCaptureDevice, ALC_CAPTURE_SAMPLES, 1, @numSamples);
      alcCaptureSamples(fCaptureDevice, @fData, numSamples); 
      // Calculate RMS
      CurRMS := 0.0;
      if Terminated then Exit;
	  
      for J := 0 to (numSamples - 1) do
        CurRMS := CurRMS + Sqr(fData[J]);

      CurRMS := Sqrt(CurRMS / numSamples);
      if Terminated then Exit;

      if DEBUG_AUDIO then
      begin
        if (CurRMS / THRESHOLD_DIV) >= fTreshold then
        begin
          Inc(fSumCPM);
          fErrorLog.Lines.Add('Tick at I=' + IntToStr(I) + ' with RMS: ' + FloatToStr(CurRMS));
          fErrorLog.Lines.Add('Tick at I=' + IntToStr(I) + ' with  RMS(Clean): ' + FloatToStr(CurRMS / THRESHOLD_DIV));
        end else
          fErrorLog.Lines.Add('No tick at I=' + IntToStr(I) + ' with  RMS(Clean): ' + FloatToStr(CurRMS / THRESHOLD_DIV));
      end else
        if (CurRMS / THRESHOLD_DIV) >= fTreshold then
          Inc(fSumCPM)
        else
          fErrorLog.Lines.Add('No tick at I=' + IntToStr(I) + ' with  RMS(Clean): ' + FloatToStr(CurRMS / THRESHOLD_DIV));
    end;

    if Terminated then Exit;

    DateTime := FormatDateTime('DD-MM-YYYY HH:MM:SS', Now);
    fCPMLog.Lines.Add(DateTime);
    fCPMLog.Lines.Add(#9 + 'Current CPM: ' + IntToStr(fSumCPM) + sLineBreak);
    if Terminated then Exit;
    updatePlot(fSumCPM);
    updateCPMBar(fSumCPM);
    if Terminated then Exit;
    updateDosiLbl(fSumCPM);

    if fUploadRM then
      fNetworkHandler.UploadData(fSumCPM, fErrorLog);

    if Terminated then Exit;
  end;
end;


destructor TAudioGeiger.Destroy;
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

end.
