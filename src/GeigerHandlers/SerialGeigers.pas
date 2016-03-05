unit SerialGeigers;

{
  This is the serial port handeling unit file of RadiaLog.
  File GUID: [FC0C0E40-CEDE-4ADF-A4FD-AE304D0B3AB6]

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
  Windows, Classes, SysUtils,
  // VCL units
  VCL.StdCtrls, VCL.ComCtrls, VCL.ExtCtrls, VCL.Graphics,
  // TeeChart units
  VCLTee.Chart,
  // Asynch Pro units
  AdPort, OoMisc,
  // Cindy units
  cySimpleGauge,
  // Custom units
  Defaults, NetworkMethods;

type
  TSerialBase = class(TObject)
    protected
      fBufferString:      AnsiString;
      fBuffer:            array of AnsiChar;
      fSumCPM:            Integer;
      fNetworkHandler:    TNetworkController;
      fPortAddress:       Integer;
      fPortBaud:          Integer;
      fPortParity:        TParity;
      fPortDataBits:      Word;
      fPortStopBits:      Word;
      fComPort:           TApdComPort;
      fBufferTimer:       TTimer;
      fConvertFactor:     Double;
      fConvertmR:         Boolean;
      fUploadRM:          Boolean;
      fCPMBar:            TcySimpleGauge;
      fLblCPM, fLblDosi:  TLabel;
      fCPMChart:          TChart;
      fCPMLog, fErrorLog: TRichEdit;
      procedure triggerAvail(CP: TObject; Count: Word);
      procedure updateCPMBar(aCPM: Integer);
      procedure updatePlot(aCPM: Integer);
      procedure updateDosiLbl(aCPM: Integer);
    public
      constructor Create(aPort, aBaud: Integer;
                         aParity: TParity;
                         aDataBits, aStopBits: Word);
      destructor Destroy; override;
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

  TMyGeiger = class(TSerialBase)
    private
      procedure TimerTick(Sender: TObject);
    public
      constructor Create(aPort, aBaud: Integer; aParity: TParity;
                         aDataBits, aStopBits: Word); overload;
      property ConvertFactor;
      property ConvertmR;
      property UploadRM;
      property CPMBar;
      property LblCPM;
      property LblDosi;
      property CPMChart;
      property CPMLog;
      property ErrorLog;
  end;

  TGMC = class(TSerialBase)
    private
      procedure TimerTick(Sender: TObject);
    public
      constructor Create(aPort, aBaud: Integer; aParity: TParity;
                         aDataBits, aStopBits: Word); overload;
      property ConvertFactor;
      property ConvertmR;
      property UploadRM;
      property CPMBar;
      property LblCPM;
      property LblDosi;
      property CPMChart;
      property CPMLog;
      property ErrorLog;
  end;

  TNetIO = class(TSerialBase)
    private
      procedure TimerTick(Sender: TObject);
    public
      constructor Create(aPort, aBaud: Integer; aParity: TParity;
                         aDataBits, aStopBits: Word); overload;
      property ConvertFactor;
      property ConvertmR;
      property UploadRM;
      property CPMBar;
      property LblCPM;
      property LblDosi;
      property CPMChart;
      property CPMLog;
      property ErrorLog;
  end;

implementation
{ TSerialBase }
constructor TSerialBase.Create(aPort, aBaud: Integer;
                               aParity: TParity;
                               aDataBits, aStopBits: Word);
begin
  inherited Create;
  fNetworkHandler      := TNetworkController.Create;
  fComPort             := TApdComPort.Create(nil);
  fPortAddress         := aPort;
  fPortBaud            := aBaud;
  fPortParity          := aParity;
  fPortDataBits        := aDataBits;
  fPortStopBits        := aStopBits;
  fBufferTimer         := TTimer.Create(nil);
  fBufferTimer.Enabled := False;
  Set8087CW($133F);
end;


destructor TSerialBase.Destroy;
begin
  inherited;
  fComPort.Open := False;
  fComPort.DonePort;
  FreeAndNil(fComPort);
  FreeAndNil(fNetworkHandler);
end;


procedure TSerialBase.triggerAvail(CP: TObject; Count: Word);
begin
  if not fBufferTimer.Enabled then
  begin
    fBufferTimer.Interval := 300;
    fBufferTimer.Enabled  := True;
  end;

  SetLength(fBuffer, Length(fBuffer) + 1);
  fBuffer[High(fBuffer)] := fComPort.GetChar;
end;


procedure TSerialBase.updateCPMBar(aCPM: Integer);
begin
  if aCPM < 200 then // Safe
  begin
    fCPMBar.Max               := 200;
    fCPMBar.ItemOnBrush.Color := clLime;
    fCPMBar.ItemOnPen.Color   := clGreen;
  end else
    if aCPM < 500 then // Attention
    begin
      fCPMBar.Max               := 500;
      fCPMBar.ItemOnBrush.Color := clYellow;
      fCPMBar.ItemOnPen.Color   := clOlive;
    end else
      if aCPM < 1000 then // Warning
      begin
        fCPMBar.Max               := 1000;
        fCPMBar.ItemOnBrush.Color := $0000A5FF; // clWebOrange
        fCPMBar.ItemOnPen.Color   := $000045FF; // clWebOrangeRed
      end else // Danger
      begin
        fCPMBar.Max               := 15000;
        fCPMBar.ItemOnBrush.Color := clRed;
        fCPMBar.ItemOnPen.Color   := clMaroon;
      end;

  fCPMBar.Position := aCPM;
  fLblCPM.Caption   := IntToStr(aCPM);
end;


procedure TSerialBase.updatePlot(aCPM: Integer);
var
  I: Integer;
  plotData: TChartData;
begin
  plotData.value    := aCPM;
  plotData.dateTime := Now;

  if fPlotPointList.Count - 1 = PLOTCAP then // Make space for new plot point
    fPlotPointList.Delete(0);

  fPlotPointList.Add(plotData);
  fCPMChart.Series[0].Clear;

  for I := 0 to PLOTCAP do
  begin
    if I <= fPlotPointList.Count - 1 then
    begin
      if fPlotPointList[I].value >= fCPMChart.LeftAxis.Maximum then
        fCPMChart.LeftAxis.Maximum := fPlotPointList[I].value + 10;

      fCPMChart.Series[0].Add(fPlotPointList[I].value, FormatDateTime('HH:MM:SS', fPlotPointList[I].dateTime));
    end else
      fCPMChart.Series[0].Add(0, 'Empty');
  end;

  fCPMChart.Update;
end;


procedure TSerialBase.updateDosiLbl(aCPM: Integer);
var
  DosiValue: Double;
begin
  DosiValue := aCPM * fConvertFactor;

  if fConvertmR then
    fLblDosi.Caption := FormatFloat(',0.000000', DosiValue / SVTOR) + ' µR/h'
  else
    fLblDosi.Caption := FormatFloat(',0.000000', DosiValue) + ' µSv/h';
end;


{ TMyGeiger class }
constructor TMyGeiger.Create(aPort, aBaud: Integer; aParity: TParity;
                             aDataBits, aStopBits: Word);
begin
  inherited Create(aPort, aBaud, aParity, aDataBits, aStopBits);
  fComPort.OnTriggerAvail := triggerAvail;
  fComPort.Open           := False;
  fComPort.DeviceLayer    := dlWin32;
  fComPort.RS485Mode      := False;
  fComPort.ComNumber      := fPortAddress;
  fComPort.Baud           := fPortBaud;
  fComPort.Parity         := fPortParity;
  fComPort.DataBits       := fPortDataBits;
  fComPort.StopBits       := fPortStopBits;
  fComPort.InitPort;
  fComPort.Open           := True;
  fBufferTimer.OnTimer    := TimerTick;
end;


procedure TMyGeiger.TimerTick(Sender: TObject);
var
  I: Integer;
  DateTime: string;
begin
  fBufferTimer.Enabled := False;
  fSumCPM              := 0;
  fBufferString        := '';

  for I := 0 to Length(fBuffer) - 1 do
  begin
    if fBuffer[I] = #7 then
    begin
      MessageBeep(0);
      Exit;
    end;

    if fBuffer[I] in [#32..#126] then // Only accept alpha-numeric Ansi values
      fBufferString := fBufferString + fBuffer[I];

    if fBuffer[I] in [#48..#57] then
      fSumCPM := (fSumCPM * 10) + (Ord(fBuffer[I]) - 48);
  end;

  SetLength(fBuffer, 0);
  DateTime := FormatDateTime('DD-MM-YYYY HH:MM:SS', Now);
  fCPMLog.Lines.Add(DateTime);
  fCPMLog.Lines.Add(#9 + 'Raw buffer: '  + String(fBufferString));
  fCPMLog.Lines.Add(#9 + 'Current CPM: ' + IntToStr(fSumCPM) + sLineBreak);
  updatePlot(fSumCPM);
  updateCPMBar(fSumCPM);
  updateDosiLbl(fSumCPM);

  if fUploadRM then
      fNetworkHandler.UploadData(fSumCPM, fErrorLog);
end;


{ TGMC class }
constructor TGMC.Create(aPort, aBaud: Integer; aParity: TParity;
                        aDataBits, aStopBits: Word);
begin
  inherited Create(aPort, aBaud, aParity, aDataBits, aStopBits);
  fComPort.OnTriggerAvail := triggerAvail;
  fComPort.Open           := False;
  fComPort.DeviceLayer    := dlWin32;
  fComPort.RS485Mode      := False;
  fComPort.ComNumber      := fPortAddress;
  fComPort.Baud           := fPortBaud;
  fComPort.Parity         := fPortParity;
  fComPort.DataBits       := fPortDataBits;
  fComPort.StopBits       := fPortStopBits;
  fComPort.InitPort;
  fComPort.Open           := True;
  fBufferTimer.OnTimer    := TimerTick;
end;


procedure TGMC.TimerTick(Sender: TObject);
var
  I: Integer;
  DateTime: string;
begin
  fBufferTimer.Enabled := False;
  fSumCPM              := 0;
  fBufferString        := '';

  for I := 0 to Length(fBuffer) - 1 do
  begin
    if fBuffer[I] = #7 then
    begin
      MessageBeep(0);
      Exit;
    end;

    if fBuffer[I] in [#32..#126] then // Only accept alpha-numeric Ansi values
      fBufferString := fBufferString + fBuffer[I];

    if fBuffer[I] in [#48..#57] then
      fSumCPM := (fSumCPM * 10) + (Ord(fBuffer[I]) - 48);
  end;

  SetLength(fBuffer, 0);
  DateTime := FormatDateTime('DD-MM-YYYY HH:MM:SS', Now);
  fCPMLog.Lines.Add(DateTime);
  fCPMLog.Lines.Add(#9 + 'Raw buffer: '  + String(fBufferString));
  fCPMLog.Lines.Add(#9 + 'Current CPM: ' + IntToStr(fSumCPM) + sLineBreak);
  updatePlot(fSumCPM);
  updateCPMBar(fSumCPM);
  updateDosiLbl(fSumCPM);

  if fUploadRM then
      fNetworkHandler.UploadData(fSumCPM, fErrorLog);
end;


{ TNetIO class }
constructor TNetIO.Create(aPort, aBaud: Integer; aParity: TParity;
                          aDataBits, aStopBits: Word);
begin
  inherited Create(aPort, aBaud, aParity, aDataBits, aStopBits);
  fComPort.OnTriggerAvail := triggerAvail;
  fComPort.Open           := False;
  fComPort.DeviceLayer    := dlWin32;
  fComPort.RS485Mode      := False;
  fComPort.ComNumber      := fPortAddress;
  fComPort.Baud           := fPortBaud;
  fComPort.Parity         := fPortParity;
  fComPort.DataBits       := fPortDataBits;
  fComPort.StopBits       := fPortStopBits;
  fComPort.InitPort;
  fComPort.Open           := True;
  fBufferTimer.OnTimer    := TimerTick;
end;


procedure TNetIO.TimerTick(Sender: TObject);
var
  I: Integer;
  DateTime: string;
begin
  fBufferTimer.Enabled := False;
  fSumCPM              := 0;
  fBufferString        := '';

  for I := 0 to Length(fBuffer) - 1 do
  begin
    if fBuffer[I] = #7 then
    begin
      MessageBeep(0);
      Exit;
    end;

    if fBuffer[I] in [#32..#126] then // Only accept alpha-numeric Ansi values
      fBufferString := fBufferString + fBuffer[I];

    if fBuffer[I] in [#48..#57] then
      fSumCPM := (fSumCPM * 10) + (Ord(fBuffer[I]) - 48);
  end;

  SetLength(fBuffer, 0);
  DateTime := FormatDateTime('DD-MM-YYYY HH:MM:SS', Now);
  fCPMLog.Lines.Add(DateTime);
  fCPMLog.Lines.Add(#9 + 'Raw buffer: '  + String(fBufferString));
  fCPMLog.Lines.Add(#9 + 'Current CPM: ' + IntToStr(fSumCPM) + sLineBreak);
  updatePlot(fSumCPM);
  updateCPMBar(fSumCPM);
  updateDosiLbl(fSumCPM);

  if fUploadRM then
      fNetworkHandler.UploadData(fSumCPM, fErrorLog);
end;

end.
