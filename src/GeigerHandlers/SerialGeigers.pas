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
  Windows, SysUtils,
  // Asynch Pro units
  AdPort, OoMisc,
  // Custom units
  Defaults, GeigerMethods;

type
  TMyGeiger = class(TMethodSerial)
    private
      procedure TimerTick(Sender: TObject);
    public
      constructor Create(aPort, aBaud: Integer; aParity: TParity;
                         aDataBits, aStopBits: Word;
                         CreateSuspended: Boolean = False); overload;
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

  TGMC = class(TMethodSerial)
    private
      procedure TimerTick(Sender: TObject);
    public
      constructor Create(aPort, aBaud: Integer; aParity: TParity;
                         aDataBits, aStopBits: Word;
                         CreateSuspended: Boolean = False); overload;
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

  TNetIO = class(TMethodSerial)
    private
      procedure TimerTick(Sender: TObject);
    public
      constructor Create(aPort, aBaud: Integer; aParity: TParity;
                         aDataBits, aStopBits: Word;
                         CreateSuspended: Boolean = False); overload;
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
{ TMyGeiger class }
constructor TMyGeiger.Create(aPort, aBaud: Integer; aParity: TParity;
                             aDataBits, aStopBits: Word;
                             CreateSuspended: Boolean = False);
begin
  inherited Create(aPort, aBaud, aParity, aDataBits, aStopBits, CreateSuspended);
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
                        aDataBits, aStopBits: Word;
                        CreateSuspended: Boolean = False);
begin
  inherited Create(aPort, aBaud, aParity, aDataBits, aStopBits, CreateSuspended);
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
                          aDataBits, aStopBits: Word;
                          CreateSuspended: Boolean = False);
begin
  inherited Create(aPort, aBaud, aParity, aDataBits, aStopBits, CreateSuspended);
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
