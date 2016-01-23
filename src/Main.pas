unit Main;

interface

uses
  // System units
  Windows, SysUtils, Classes, Math, INIFiles, Generics.Collections,
  // VCL units
  Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Graphics,
  Vcl.Forms, Vcl.Menus, Vcl.Mask, VCLTee.TeEngine, VCLTee.Series,
  VCLTee.TeeProcs, VCLTee.Chart, Vcl.Imaging.pngimage, VCL.LPControl,
  // Indy units
  IdHTTP, IdException, IdExceptionCore, IdStack,
  // Asynch Pro units
  AdPort, OoMisc,
  // Cindy units
  cyBaseLed, cyLed, cyBaseMeasure, cyCustomGauge, cySimpleGauge,
  // Audio Labs (Mitov)
  Mitov.VCLTypes, Mitov.Types,
  LPControlDrawLayers,
  SLControlCollection, SLBasicDataDisplay, SLDataDisplay, SLDataChart, SLScope,
  ALCommonMeter, ALRMSMeter, ALAudioIn,
  // Own units
  Defaults, About, ThimoEdit;

type
  TmainForm = class(TForm)
    cMainTimer: TTimer;
    fStatusBar: TStatusBar;
    cComPort: TApdComPort;
    cAudioSrc: TALAudioIn;
    cRMSMeter: TALRMSMeter;
    fPageControl: TPageControl;
      tabMain: TTabSheet;
        ScrollBox1: TScrollBox;
          Label12: TLabel;
          lblCPM: TLabel;
          cStatusLed: TcyLed;
          cCPMBar: TcySimpleGauge;
          Label4: TLabel;
          lblDosi: TLabel;
          cLogoImage: TImage;
          GroupBox1: TGroupBox;
            Label1: TLabel;
            Label5: TLabel;
            Label6: TLabel;
            Label7: TLabel;
            Label8: TLabel;
            comPortBox: TComboBox;
            comBaudBox: TComboBox;
            comParityBox: TComboBox;
            comDataBitsBox: TComboBox;
            comStopBitsBox: TComboBox;
          GroupBox2: TGroupBox;
            Label9: TLabel;
            Label10: TLabel;
            Label11: TLabel;
            edtUsername: TEdit;
            edtPassword: TEdit;
            chkBoxRadmon: TCheckBox;
          GroupBox3: TGroupBox;
            Label13: TLabel;
            chkBoxUnitType: TCheckBox;
            Label15: TLabel;
            edtFactor: TThimoFloatEdit;
          GroupBox4: TGroupBox;
            lblTubes: TLabel;
            lblFactors: TLabel;
          GroupBox5: TGroupBox;
            rbSerial: TRadioButton;
            rbAudio: TRadioButton;
      tabLog: TTabSheet;
        ScrollBox3: TScrollBox;
          cCPMEdit: TRichEdit;
          cErrorEdit: TRichEdit;
          Label2: TLabel;
          Label3: TLabel;
      tabGraph: TTabSheet;
        ScrollBox2: TScrollBox;
          cCPMChart: TChart;
          Series1: TFastLineSeries;
      tabAudio: TTabSheet;
        SLScope2: TSLScope;
    GroupBox6: TGroupBox;
    edtThreshold: TThimoFloatEdit;
    edtPulseWidth: TThimoFloatEdit;
    Label14: TLabel;
    Label16: TLabel;
    cPulseTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cMainTimerTimer(Sender: TObject);
    procedure cStatusLedClick(Sender: TObject);
    procedure fBtnAboutClick(Sender: TObject);
    procedure chkBoxClick(Sender: TObject);
    procedure edtChange(Sender: TObject);
    procedure rbModeClick(Sender: TObject);
    procedure cPulseTimerTimer(Sender: TObject);
  private
    fCPMList: TList<Integer>;
    fPlotPointList: TList<TChartData>;
    fBuffer: string[255];
    fComPort, fUsername, fPassword: String;
    fComBaud, fAudioCpm, fTicks, fTimeToWait: Integer;
    fComDataBits, fComStopBits, fComParity: Word;
    fAudioMode, fSamePulse, fUploadRM, fConvertmR, fSafeToWrite: Boolean;
    fConvertFactor, fAudioThreshold, fAudioPulseWidth: Double;
    fSettings: TINIFile;
    procedure triggerAvail(CP: TObject; Count: Word);
    procedure updateCPMBar(aCPM: Integer);
    procedure updatePlot(aCPM: Integer);
    procedure updateDosiLbl(aCPM: Integer);
    procedure onAudioValChange(Sender: TObject; aChannel: Integer; aValue, aMin, aMax: Real);
  end;

var
  mainForm: TmainForm;

implementation

{$R *.dfm}

procedure TmainForm.FormCreate(Sender: TObject);
var
  i: integer;
  hComm: THandle;
begin
  // Set initial values
  mainForm.Caption        := 'RadiaLog ' + VERSION_PREFIX + VERSION + VERSION_SUFFIX;
  exeDir                  := ExtractFilePath(Application.ExeName);
  cComPort.OnTriggerAvail := triggerAvail;
  cComPort.Open           := False;
  cComPort.DeviceLayer    := dlWin32;
  cComPort.RS485Mode      := False;
  fCPMList                := TList<Integer>.Create;
  fPlotPointList          := TList<TChartData>.Create;
  chkBoxUnitType.Hint     := 'Checked: µR/h' + sLineBreak + 'Unckecked: µSv/h';
  lblTubes.Caption        := 'SBM-20' + sLineBreak + 'SBM-19' + sLineBreak +
                             'SI-29BG' + sLineBreak + 'SI-180G' + sLineBreak +
                             'LND-712' + sLineBreak + 'LND-7317' + sLineBreak +
                             'J305' + sLineBreak + 'SBT11-A' + sLineBreak +
                             'SBT-9' + sLineBreak + 'M4011' + sLineBreak;
  lblFactors.Caption      := '0.0057' + sLineBreak + '0.0021' + sLineBreak +
                             '0.0082' + sLineBreak + '0.0031' + sLineBreak +
                             '0.0081' + sLineBreak + '0.0024' + sLineBreak +
                             '0.0081' + sLineBreak + '0.0031' + sLineBreak +
                             '0.0117' + sLineBreak + '0.0066' + sLineBreak;
  cRMSMeter.OnValueChange := onAudioValChange;
  // Populate COM port select box
  comPortBox.Items.BeginUpdate;
  comPortBox.Items.Clear;

  for i := 1 to 255 do
  begin
    hComm := CreateFile(PChar('\\.\COM'+IntToStr(i)), GENERIC_READ or GENERIC_WRITE, 0, nil,
                        OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_OVERLAPPED, 0);

    if (hComm <> INVALID_HANDLE_VALUE) then
    begin
      CloseHandle(hComm);
      comPortBox.Items.AddObject('COM' + IntToStr(i), Pointer(i));
    end;
  end;

  comPortBox.Items.EndUpdate;
  comPortBox.ItemIndex := 0;
  // Read INI values
  fSafeToWrite         := False;
  fSettings            := TINIFile.Create(exeDir + '/Settings.ini');

  if not FileExists(exeDir + '/Settings.ini') then
  begin
    fSettings.WriteString('SERIAL',  'Port',       'COM1');
    fSettings.WriteInteger('SERIAL', 'Baud',       2400);
    fSettings.WriteInteger('SERIAL', 'Parity',     0);
    fSettings.WriteInteger('SERIAL', 'DataBits',   8);
    fSettings.WriteInteger('SERIAL', 'StopBits',   0);
    fSettings.WriteFloat('AUDIO',    'Threshold',  0.0300);
    fSettings.WriteFloat('AUDIO',    'PulseWidth', 0.007);
    fSettings.WriteString('USER',    'Username',   'TestUser');
    fSettings.WriteString('USER',    'Password',   'TestPass');
    fSettings.WriteBool('USER',      'Upload',     True);
    fSettings.WriteFloat('CONVERT',  'Factor',     0.0057);
    fSettings.WriteBool('CONVERT',   'UnitR',      False);
    fSettings.WriteBool('MODE',      'Audio',      False);
  end;

  fComPort         := fSettings.ReadString('SERIAL',  'Port',       'COM1');
  fComBaud         := fSettings.ReadInteger('SERIAL', 'Baud',       2400);
  fComParity       := fSettings.ReadInteger('SERIAL', 'Parity',     0);
  fComDataBits     := fSettings.ReadInteger('SERIAL', 'DataBits',   8);
  fComStopBits     := fSettings.ReadInteger('SERIAL', 'StopBits',   0);
  fAudioThreshold  := fSettings.ReadFloat('AUDIO',    'Threshold',  0.0300);
  fAudioPulseWidth := fSettings.ReadFloat('AUDIO',    'PulseWidth', 0.007);
  fUsername        := fSettings.ReadString('USER',    'Username',   'TestUser');
  fPassword        := fSettings.ReadString('USER',    'Password',   'TestPass');
  fUploadRM        := fSettings.ReadBool('USER',      'Upload',     True);
  fConvertFactor   := fSettings.ReadFloat('CONVERT',  'Factor',     0.0057);
  fConvertmR       := fSettings.ReadBool('CONVERT',   'UnitR',      False);
  fAudioMode       := fSettings.ReadBool('MODE',      'Audio',      False);
  FreeAndNil(fSettings);

  // Apply values to visual components
  comPortBox.ItemIndex     := comPortBox.Items.IndexOf(fComPort);
  comBaudBox.ItemIndex     := comBaudBox.Items.IndexOf(IntToStr(fComBaud));
  comParityBox.ItemIndex   := fComParity;
  comDataBitsBox.ItemIndex := comDataBitsBox.Items.IndexOf(IntToStr(fComDataBits));
  comStopBitsBox.ItemIndex := fComStopBits;
  edtThreshold.Value       := fAudioThreshold;
  edtPulseWidth.Value      := fAudioPulseWidth;
  edtUsername.Text         := fUsername;
  edtPassword.Text         := fPassword;
  chkBoxRadmon.Checked     := fUploadRM;
  edtFactor.Value          := fConvertFactor;
  chkBoxUnitType.Checked   := fConvertmR;
  fSafeToWrite             := True;
  tabAudio.TabVisible      := fAudioMode;
  rbSerial.Checked         := not fAudioMode;
  rbAudio.Checked          := fAudioMode;
  fTimeToWait              := -1;
  fSamePulse               := False;
end;


procedure TmainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  cComPort.Open := False;
  cComPort.DonePort;
  cAudioSrc.Stop;
  cAudioSrc.Enabled   := False;
  cMainTimer.Enabled  := False;
  cPulseTimer.Enabled := False;
  FreeAndNil(fCPMList);
  FreeAndNil(fPlotPointList);
end;


procedure TmainForm.triggerAvail(CP: TObject; Count: Word);
var
  I: Word;
  C: AnsiChar;
begin
  if fTimeToWait = -1 then
    fTimeToWait := 1;

  for I := 1 to Count do
  begin
    C := cComPort.GetChar;

    if C = #7 then // COM port asks for system to "bell"
      MessageBeep(0)
    else
      if C in [#32..#126] then // Only accept alpha-numeric Ansi values
        fBuffer := fBuffer + C;
  end;
end;


procedure TmainForm.onAudioValChange(Sender: TObject; aChannel: Integer; aValue, aMin, aMax: Real);
var
  usedValue: Double;
  Interval: Integer;
begin
  usedValue := aValue / 100000;
  Interval  := Round(fAudioPulseWidth * 1000.0);
  if (usedValue >= fAudioThreshold) and not fSamePulse then
  begin
    fSamePulse := True;
    cPulseTimer.Interval := Interval;
    cPulseTimer.Enabled  := True;
    fAudioCPM := fAudioCPM + 1;
  end;
end;


procedure TmainForm.updateCPMBar(aCPM: Integer);
begin
  if aCPM < 200 then // Safe
  begin
    cCPMBar.Max               := 200;
    cCPMBar.ItemOnBrush.Color := clLime;
    cCPMBar.ItemOnPen.Color   := clGreen;
  end else
    if aCPM < 500 then // Attention
    begin
      cCPMBar.Max               := 500;
      cCPMBar.ItemOnBrush.Color := clYellow;
      cCPMBar.ItemOnPen.Color   := clOlive;
    end else
      if aCPM < 1000 then // Warning
      begin
        cCPMBar.Max               := 1000;
        cCPMBar.ItemOnBrush.Color := $0000A5FF; // clWebOrange
        cCPMBar.ItemOnPen.Color   := $000045FF; // clWebOrangeRed
      end else // Danger
      begin
        cCPMBar.Max               := 15000;
        cCPMBar.ItemOnBrush.Color := clRed;
        cCPMBar.ItemOnPen.Color   := clMaroon;
      end;

  cCPMBar.Position := aCPM;
  lblCPM.Caption   := IntToStr(aCPM);
end;


procedure TmainForm.updatePlot(aCPM: Integer);
var
  I: Integer;
  plotData: TChartData;
begin
  plotData.value    := aCPM;
  plotData.dateTime := Now;

  if fPlotPointList.Count - 1 = PLOTCAP then // Make space for new plot point
    fPlotPointList.Delete(0);

  fPlotPointList.Add(plotData);
  cCPMChart.Series[0].Clear;

  for I := 0 to PLOTCAP do
  begin
    if I <= fPlotPointList.Count - 1 then
    begin
      if fPlotPointList[I].value >= cCPMChart.LeftAxis.Maximum then
        cCPMChart.LeftAxis.Maximum := fPlotPointList[I].value + 10;

      cCPMChart.Series[0].Add(fPlotPointList[I].value, FormatDateTime('HH:MM:SS', fPlotPointList[I].dateTime));
    end else
      cCPMChart.Series[0].Add(0, 'Empty');
  end;

  cCPMChart.Update;
end;


procedure TmainForm.updateDosiLbl(aCPM: Integer);
var
  DosiValue: Double;
begin
  DosiValue := aCPM * fConvertFactor;

  if fConvertmR then
    lblDosi.Caption := FormatFloat(',0.000000', DosiValue / SVTOR) + ' µR/h'
  else
    lblDosi.Caption := FormatFloat(',0.000000', DosiValue) + ' µSv/h';
end;


procedure TmainForm.edtChange(Sender: TObject);
begin
  if fSafeToWrite then
  begin
    fSettings := TINIFile.Create(exeDir + '/Settings.ini');

    if Sender = comPortBox then
    begin
      fComPort := comPortBox.Items[comPortBox.ItemIndex];
      fSettings.WriteString('SERIAL', 'Port', fComPort);
    end;

    if Sender = comBaudBox then
    begin
      fComBaud := StrToInt(comBaudBox.Items[comBaudBox.ItemIndex]);
      fSettings.WriteInteger('SERIAL', 'Baud', fComBaud);
    end;

    if Sender = comParityBox then
    begin
      fComParity := comParityBox.ItemIndex;
      fSettings.WriteInteger('SERIAL', 'Parity', fComParity);
    end;

    if Sender = comDataBitsBox then
    begin
      fComDataBits := StrToInt(comDataBitsBox.Items[comDataBitsBox.ItemIndex]);
      fSettings.WriteInteger('SERIAL', 'DataBits', fComDataBits);
    end;

    if Sender = comStopBitsBox then
    begin
      fComStopBits := comStopBitsBox.ItemIndex;
      fSettings.WriteInteger('SERIAL', 'StopBits', fComStopBits);
    end;

    if Sender = edtUsername then
    begin
      fUsername := edtUsername.Text;
      fSettings.WriteString('USER', 'Username', fUsername);
    end;

    if Sender = edtPassword then
    begin
      fPassword := edtPassword.Text;
      fSettings.WriteString('USER', 'Password', fPassword);
    end;

    if Sender = edtFactor then
    begin
      fConvertFactor := edtFactor.Value;
      fSettings.WriteFloat('CONVERT', 'Factor', fConvertFactor);
    end;

    if Sender = edtThreshold then
    begin
      fAudioThreshold := edtThreshold.Value;
      fSettings.WriteFloat('AUDIO', 'Threshold', fAudioThreshold);
    end;

    if Sender = edtPulseWidth then
    begin
      fAudioPulseWidth := edtPulseWidth.Value;
      fSettings.WriteFloat('AUDIO', 'PulseWidth', fAudioPulseWidth);
    end;

    FreeAndNil(fSettings);
  end;
end;


procedure TmainForm.chkBoxClick(Sender: TObject);
begin
  if fSafeToWrite then
  begin
    fSettings := TINIFile.Create(exeDir + '/Settings.ini');

    if Sender = chkBoxRadmon then
    begin
      fUploadRM := chkBoxRadmon.Checked;
      fSettings.WriteBool('USER', 'Upload', fUploadRM);
    end;

    if Sender = chkBoxUnitType then
    begin
      fConvertmR := chkBoxUnitType.Checked;
      fSettings.WriteBool('CONVERT', 'UnitR', fConvertmR);
      if fPlotPointList.Count > 0 then
        updateDosiLbl(fPlotPointList[fPlotPointList.Count - 1].value)
      else
        updateDosiLbl(0);
    end;

    FreeAndNil(fSettings);
  end;
end;


procedure TmainForm.rbModeClick(Sender: TObject);
begin
  rbSerial.Checked    := Sender = rbSerial;
  rbAudio.Checked     := Sender = rbAudio;
  fAudioMode          := rbAudio.Checked;
  tabAudio.TabVisible := fAudioMode;

  if fSafeToWrite then
  begin
    fSettings := TINIFile.Create(exeDir + '/Settings.ini');
    fSettings.WriteBool('MODE', 'Audio', fAudioMode);
    FreeAndNil(fSettings);
  end;
end;


procedure TmainForm.fBtnAboutClick(Sender: TObject);
begin
  with TaboutForm.Create(nil) do
    try
      ShowModal;
    finally
      Free;
    end;
end;


procedure TmainForm.cStatusLedClick(Sender: TObject);
begin
  if cStatusLed.LedValue then
  begin
    fTicks      := 0;
    fTimeToWait := -1;
    fAudioCpm   := 0;
    fSamePulse  := False;
    fBuffer     := '';
    fCPMList.Clear;
    fCPMList.Clear;
    fPlotPointList.Clear;
    cCPMEdit.Clear;
    cErrorEdit.Clear;

    if fAudioMode then
    begin
      cAudioSrc.Enabled := True;
      cAudioSrc.Start;
    end else
    begin
      cComPort.ComNumber := StrToInt(StringReplace(fComPort, 'COM', '', [rfReplaceAll, rfIgnoreCase]));
      cComPort.Baud      := fComBaud;
      cComPort.Parity    := TParity(fComParity);
      cComPort.DataBits  := fComDataBits;
      cComPort.StopBits  := fComStopBits;
      cComPort.Open      := True;
    end;

    cMainTimer.Enabled     := True;
    comPortBox.Enabled     := False;
    comBaudBox.Enabled     := False;
    comParityBox.Enabled   := False;
    comDataBitsBox.Enabled := False;
    comStopBitsBox.Enabled := False;
    edtThreshold.Enabled   := False;
    edtPulseWidth.Enabled  := False;
    rbSerial.Enabled       := False;
    rbAudio.Enabled        := False;
  end else
  begin
    cMainTimer.Enabled := False;

    if fAudioMode then
    begin
      cAudioSrc.Stop;
      cAudioSrc.Enabled := False;
    end else
      cComPort.Open := False;

    comPortBox.Enabled     := True;
    comBaudBox.Enabled     := True;
    comParityBox.Enabled   := True;
    comDataBitsBox.Enabled := True;
    comStopBitsBox.Enabled := True;
    edtThreshold.Enabled   := True;
    edtPulseWidth.Enabled  := True;
    rbSerial.Enabled       := True;
    rbAudio.Enabled        := True;
  end;
end;


procedure TmainForm.cMainTimerTimer(Sender: TObject);
var
  I, curCPM, totalCPM: Integer;
  dateTime, urlString, httpReply, logText: string;
  HTTPClient: TIdHTTP;
  hadException: Boolean;
begin
  fTicks   := fTicks + 1;
  dateTime := FormatDateTime('DD-MM-YYYY HH:MM:SS', Now);

  if fTimeToWait = 0 then
  begin
    curCPM   := 0;

    for I := 0 to Length(fBuffer) do
      if fBuffer[I] in [#48..#57] then
        curCPM := (curCPM * 10) + (Ord(fBuffer[I]) - 48);

    cCPMEdit.Lines.Add(dateTime);
    cCPMEdit.Lines.Add(#9 + 'Raw string: ' + string(fBuffer));
    cCPMEdit.Lines.Add(#9 + 'curCPM: ' + IntToStr(curCPM) + sLineBreak);
    fBuffer     := '';
    fTimeToWait := - 1;

    if fUploadRM then
      fCPMList.Add(curCPM);

    updatePlot(curCPM);
    updateCPMBar(curCPM);
    updateDosiLbl(curCPM);
  end else
    if fTimeToWait <> -1 then
      fTimeToWait := fTimeToWait - 1;

  if (fTicks mod 300 = 0) and fAudioMode then
  begin
    curCPM    := fAudioCpm * 2;
    fAudioCpm := 0;
    cCPMEdit.Lines.Add(dateTime);
    cCPMEdit.Lines.Add(#9 + 'curCPM: ' + IntToStr(curCPM) + sLineBreak);

    if fUploadRM then
      fCPMList.Add(curCPM);

    updatePlot(curCPM);
    updateCPMBar(curCPM);
    updateDosiLbl(curCPM);
  end;

  if (fTicks mod 600 = 0) and fUploadRM then
  begin
    hadException := False;
    HTTPClient   := TIdHTTP.Create(nil);
    httpReply    := '';
    dateTime     := FormatDateTime('DD-MM-YYYY HH:MM:SS', Now);
    totalCPM     := 0;
    cErrorEdit.Lines.Add(dateTime);
    cErrorEdit.Lines.Add(#9 + 'Sending data to RadMon...');

    for I := 0 to fCPMList.Count - 1 do
      totalCPM := totalCPM + fCPMList[I];

    totalCPM := totalCPM Div fCPMList.Count;
    cErrorEdit.Lines.Add(#9 + 'totalCPM: ' + IntToStr(totalCPM));
    dateTime  := FormatDateTime('YYYY-MM-DD%20HH:MM:SS', Now);
    urlString := 'http://'          + RADMON_HOST        + '/radmon.php' +
                 '?user='           + fUsername          +
                 '&password='       + fPassword          +
                 '&function=submit' +
                 '&datetime='       + dateTime           +
                 '&value='          + IntToStr(totalCPM) +
                 '&unit=CPM';

    try
      HTTPClient.ConnectTimeout    := 3000;
      HTTPClient.ReadTimeout       := 2000;
      HTTPClient.Request.UserAgent := 'Mozilla/5.0 (compatible; RadiaLog/' + VERSION + ')';

      try
        httpReply := HTTPClient.Get(urlString);
      except
        // Indy protocol exception
        on E:EIdHTTPProtocolException do
        begin
          logText := #9 + 'Error: Indy raised a protocol error!' + sLineBreak +
                     #9 + 'HTTP status code: ' + IntToStr(E.ErrorCode) + sLineBreak +
                     #9 + 'Error message' + E.Message + sLineBreak;
          hadException := True;
        end;
        // Indy server closed connection exception
        on E:EIdConnClosedGracefully do
        begin
          logText := #9 + 'Error: Indy reports, that connection was closed by the server!' + sLineBreak +
                     #9 + 'Exception class: ' + E.ClassName + sLineBreak +
                     #9 + 'Error message: ' + E.Message + sLineBreak;
          hadException := True;
        end;
        // Indy low-level socket exception
        on E:EIdSocketError do
        begin
          logText := #9 + 'Error: Indy raised a socket error!' + sLineBreak +
                     #9 + 'Error code: ' + IntToStr(E.LastError) + sLineBreak +
                     #9 + 'Error message' + E.Message + sLineBreak;
          hadException := True;
        end;
        // Indy read-timeout exception
        on E:EIdReadTimeout do
        begin
          logText := #9 + 'Error: Indy raised a read-timeout error!' + sLineBreak +
                     #9 + 'Exception class: ' + E.ClassName + sLineBreak +
                     #9 + 'Error message: ' + E.Message + sLineBreak;
          hadException := True;
        end;
        // All other Indy exceptions
        on E:EIdException do
        begin
          logText := #9 + 'Error: Something went wrong with Indy!' + sLineBreak +
                     #9 + 'Exception class: ' + E.ClassName + sLineBreak +
                     #9 + 'Error message: ' + E.Message + sLineBreak;
          hadException := True;
        end;
        // All other Delphi exceptions
        on E:Exception do
        begin
          logText := #9 + 'Error: Something non-Indy related raised an exception!' + sLineBreak +
                     #9 + 'Exception class: ' + E.ClassName + sLineBreak +
                     #9 + 'Error message: ' + E.Message + sLineBreak;
          hadException := True;
        end;
      end;

      if not hadException then
        if httpReply.ToLower.Contains('incorrect') then
          logText := #9 + 'Error sending data to RadMon.' + sLineBreak +
                     #9 + 'Check your username and password.' + sLineBreak
        else
          if httpReply.ToLower.Contains('error') then
            logText := #9 + 'Error sending data to RadMon.' + sLineBreak +
                       #9 + 'An unknown error occurred.' + sLineBreak +
                       #9 + 'Please make sure your username is correct, it is case-sensitive!' + sLineBreak
          else
          begin
            logText := #9 + 'Response: ' + StringReplace(httpReply, '<br>', '', [rfReplaceAll, rfIgnoreCase]) + sLineBreak;
            fStatusBar.Panels[0].Text := 'Last uploaded: ' + IntToStr(totalCPM) + ' CPM';
          end;

      cErrorEdit.Lines.Add(logText);
    finally
      FreeAndNil(HTTPClient);
    end;

    fCPMList.Clear;
  end;
end;


procedure TmainForm.cPulseTimerTimer(Sender: TObject);
begin
  fSamePulse          := False;
  cPulseTimer.Enabled := False;
end;

end.
