unit Main;

interface

uses
  // System units
  Windows, SysUtils, Classes, Math, INIFiles, Generics.Collections,
  // VCL units
  Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Graphics,
  Vcl.Forms, Vcl.Menus, Vcl.Mask,
  // Indy units
  IdHTTP, IdException, IdExceptionCore, IdStack,
  // Asynch Pro units
  AdPort, OoMisc,
  // Cindy units
  cyBaseLed, cyLed, cyBaseMeasure, cyCustomGauge, cySimpleGauge,
  // Jcl/Jvcl units
  JvComponentBase, JvCaptionButton, JvChart, JvExMask, JvSpin, JvExControls,
  JvAnimatedImage, JvGIFCtrl,
  // Own units
  Defaults, About;

type
  TmainForm = class(TForm)
    fMainTimer: TTimer;
    fPageControl: TPageControl;
    tabMain: TTabSheet;
    tabLog: TTabSheet;
    tabGraph: TTabSheet;
    fStatusBar: TStatusBar;
    fComPort: TApdComPort;
    fNetTimer: TTimer;
    ScrollBox1: TScrollBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    comPortBox: TComboBox;
    ScrollBox2: TScrollBox;
    ScrollBox3: TScrollBox;
    fCPMEdit: TRichEdit;
    Label2: TLabel;
    Label3: TLabel;
    fErrorEdit: TRichEdit;
    fCPMChart: TJvChart;
    fStatusLed: TcyLed;
    fCPMBar: TcySimpleGauge;
    Label4: TLabel;
    fBtnAbout: TJvCaptionButton;
    Label5: TLabel;
    comBaudBox: TComboBox;
    comParityBox: TComboBox;
    comDataBitsBox: TComboBox;
    comStopBitsBox: TComboBox;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    GroupBox2: TGroupBox;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    edtUsername: TEdit;
    edtPassword: TEdit;
    Label12: TLabel;
    chkBoxRadmon: TCheckBox;
    lblCPM: TLabel;
    GroupBox3: TGroupBox;
    Label13: TLabel;
    chkBoxUnitType: TCheckBox;
    Label15: TLabel;
    lblSvR: TLabel;
    edtFactor: TJvSpinEdit;
    fTopImg: TJvGIFAnimator;
    GroupBox4: TGroupBox;
    lblTubes: TLabel;
    lblFactors: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure fMainTimerTimer(Sender: TObject);
    procedure fNetTimerTimer(Sender: TObject);
    procedure fStatusLedClick(Sender: TObject);
    procedure fBtnAboutClick(Sender: TObject);
    procedure chkBoxClick(Sender: TObject);
    procedure edtChange(Sender: TObject);
  private
    { Private stuff }
    CPMList: TList<Integer>;
    PlotPointList: TList<TChartData>;
    Buffer: string[255];
    comPort, Username, Password: string;
    comBaud: Integer;
    comDataBits, comStopBits, comParity: Word;
    UploadRM, ConvertmR, safeToWrite: Boolean;
    ConvertFactor: Double;
    Settings: TINIFile;
    procedure triggerAvail(CP: TObject; Count: Word);
    procedure updateCPMBar(aCPM: Integer);
    procedure updatePlot(aCPM: Integer);
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
  fComPort.OnTriggerAvail := triggerAvail;
  fComPort.Open           := False;
  fComPort.DeviceLayer    := dlWin32;
  fComPort.RS485Mode      := False;
  CPMList                 := TList<Integer>.Create;
  PlotPointList           := TList<TChartData>.Create;
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
  safeToWrite          := False;
  Settings             := TINIFile.Create(exeDir + '/Settings.ini');

  if not FileExists(exeDir + '/Settings.ini') then
  begin
    Settings.WriteString('SERIAL',  'Port',     'COM1');
    Settings.WriteInteger('SERIAL', 'Baud',     2400);
    Settings.WriteInteger('SERIAL', 'Parity',   0);
    Settings.WriteInteger('SERIAL', 'DataBits', 8);
    Settings.WriteInteger('SERIAL', 'StopBits', 0);
    Settings.WriteString('USER',    'Username', 'TestUser');
    Settings.WriteString('USER',    'Password', 'TestPass');
    Settings.WriteBool('USER',      'Upload',   True);
    Settings.WriteFloat('CONVERT',  'Factor',   0.0057);
    Settings.WriteBool('CONVERT',   'UnitR',     False);
  end;

  comPort       := Settings.ReadString('SERIAL',  'Port',     'COM1');
  comBaud       := Settings.ReadInteger('SERIAL', 'Baud',     2400);
  comParity     := Settings.ReadInteger('SERIAL', 'Parity',   0);
  comDataBits   := Settings.ReadInteger('SERIAL', 'DataBits', 8);
  comStopBits   := Settings.ReadInteger('SERIAL', 'StopBits', 0);
  Username      := Settings.ReadString('USER',    'Username', 'TestUser');
  Password      := Settings.ReadString('USER',    'Password', 'TestPass');
  UploadRM      := Settings.ReadBool('USER',      'Upload',   True);
  ConvertFactor := Settings.ReadFloat('CONVERT',  'Factor',   0.0057);
  ConvertmR     := Settings.ReadBool('CONVERT',   'UnitR',     False);
  FreeAndNil(Settings);

  // Apply values to visual components
  comPortBox.ItemIndex     := comPortBox.Items.IndexOf(comPort);
  comBaudBox.ItemIndex     := comBaudBox.Items.IndexOf(IntToStr(comBaud));
  comParityBox.ItemIndex   := comParity;
  comDataBitsBox.ItemIndex := comDataBitsBox.Items.IndexOf(IntToStr(comDataBits));
  comStopBitsBox.ItemIndex := comStopBits;
  edtUsername.Text         := Username;
  edtPassword.Text         := Password;
  chkBoxRadmon.Checked     := UploadRM;
  edtFactor.Value          := ConvertFactor;
  chkBoxUnitType.Checked   := ConvertmR;
  safeToWrite              := True;
end;


procedure TmainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  fComPort.Open := False;
  fComPort.DonePort;
  FreeAndNil(CPMList);
  FreeAndNil(PlotPointList);
end;


procedure TmainForm.triggerAvail(CP: TObject; Count: Word);
var
  I: Word;
  C: AnsiChar;
begin
  fMainTimer.Enabled := True;

  for I := 1 to Count do
  begin
    C := fComPort.GetChar;

    if C = #7 then // COM port asks for system to "bell"
      MessageBeep(0)
    else
      if C in [#32..#126] then // Only accept alpha-numeric Ansi values
        Buffer := Buffer + C;
  end;
end;


procedure TmainForm.updateCPMBar(aCPM: Integer);
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
  lblCPM.Caption   := IntToStr(aCPM);
end;


procedure TmainForm.updatePlot(aCPM: Integer);
var
  I: Integer;
  plotData: TChartData;
begin
  plotData.value    := aCPM;
  plotData.dateTime := Now;

  if PlotPointList.Count - 1 = PLOTCAP then // Make space for new plot point
    PlotPointList.Delete(0);

  PlotPointList.Add(plotData);
  fCPMChart.Data.Clear;
  fCPMChart.Options.XLegends.Clear;

  for I := 0 to PLOTCAP do
  begin
    if I <= PlotPointList.Count - 1 then
    begin
      fCPMChart.Data.Value[0, I] := PlotPointList[I].value;

      if PlotPointList[I].value >= fCPMChart.Options.PrimaryYAxis.YMax then
        fCPMChart.Options.PrimaryYAxis.YMax := PlotPointList[I].value + 10;
      fCPMChart.Options.XLegends.Add(FormatDateTime('HH:MM:SS', PlotPointList[I].dateTime));
    end else
    begin
      fCPMChart.Data.Value[0, I] := 0;

      if I < PLOTCAP then
        fCPMChart.Options.XLegends.Add('Empty')
      else
        fCPMChart.Options.XLegends.Add('')
    end;
  end;

  fCPMChart.PlotGraph;
end;


procedure TmainForm.edtChange(Sender: TObject);
begin
  if safeToWrite then
  begin
    Settings := TINIFile.Create(exeDir + '/Settings.ini');

    if Sender = comPortBox then
    begin
      comPort := comPortBox.Items[comPortBox.ItemIndex];
      Settings.WriteString('SERIAL', 'Port', comPort);
    end;

    if Sender = comBaudBox then
    begin
      comBaud := StrToInt(comBaudBox.Items[comBaudBox.ItemIndex]);
      Settings.WriteInteger('SERIAL', 'Baud', comBaud);
    end;

    if Sender = comParityBox then
    begin
      comParity := comParityBox.ItemIndex;
      Settings.WriteInteger('SERIAL', 'Parity', comParity);
    end;

    if Sender = comDataBitsBox then
    begin
      comDataBits := StrToInt(comDataBitsBox.Items[comDataBitsBox.ItemIndex]);
      Settings.WriteInteger('SERIAL', 'DataBits', comDataBits);
    end;

    if Sender = comStopBitsBox then
    begin
      comStopBits := comStopBitsBox.ItemIndex;
      Settings.WriteInteger('SERIAL', 'StopBits', comStopBits);
    end;

    if Sender = edtUsername then
    begin
      Username := edtUsername.Text;
      Settings.WriteString('USER', 'Username', Username);
    end;

    if Sender = edtPassword then
    begin
      Password := edtPassword.Text;
      Settings.WriteString('USER', 'Password', Password);
    end;

    if Sender = edtFactor then
    begin
      ConvertFactor := edtFactor.Value;
      Settings.WriteFloat('CONVERT', 'Factor', ConvertFactor);
    end;

    FreeAndNil(Settings);
  end;
end;


procedure TmainForm.chkBoxClick(Sender: TObject);
begin
  if safeToWrite then
  begin
    Settings := TINIFile.Create(exeDir + '/Settings.ini');

    if Sender = chkBoxRadmon then
    begin
      UploadRM          := chkBoxRadmon.Checked;
      fNetTimer.Enabled := (chkBoxRadmon.Checked and fComPort.Open);
      Settings.WriteBool('USER', 'Upload', UploadRM);
    end;

    if Sender = chkBoxUnitType then
    begin
      ConvertmR := chkBoxUnitType.Checked;
      Settings.WriteBool('CONVERT', 'UnitR', ConvertmR);
    end;

    FreeAndNil(Settings);
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


procedure TmainForm.fStatusLedClick(Sender: TObject);
begin
  if fStatusLed.LedValue then
  begin
    fComPort.ComNumber := StrToInt(StringReplace(comPort, 'COM', '', [rfReplaceAll, rfIgnoreCase]));
    fComPort.Baud      := comBaud;
    fComPort.Parity    := TParity(comParity);
    fComPort.DataBits  := comDataBits;
    fComPort.StopBits  := comStopBits;
    fComPort.Open      := True;

    if UploadRM then
      fNetTimer.Enabled := True;
  end else
  begin
    fComPort.Open      := False;
    fNetTimer.Enabled  := False;
    fMainTimer.Enabled := False;
  end;
end;


procedure TmainForm.fMainTimerTimer(Sender: TObject);
var
  I, curCPM: Integer;
  radValue: Double;
  dateTime: string;
begin
  curCPM             := 0;
  fMainTimer.Enabled := False;
  dateTime           := FormatDateTime('DD-MM-YYYY HH:MM:SS', Now);

  for I := 0 to Length(Buffer) do
    if Buffer[I] in [#48..#57] then
      curCPM := (curCPM * 10) + StrToInt(string(Buffer[I]));

  fCPMEdit.Lines.Add(dateTime);
  fCPMEdit.Lines.Add(string(#9 + 'Raw string: ' + Buffer));
  fCPMEdit.Lines.Add(#9 + 'curCPM: ' + IntToStr(curCPM) + sLineBreak);
  Buffer := '';

  if UploadRM then
    CPMList.Add(curCPM);

  updatePlot(curCPM);
  updateCPMBar(curCPM);
  radValue := curCPM * ConvertFactor;

  if ConvertmR then
    lblSvR.Caption := FormatFloat('0.######', radValue / SVTOR) + ' µR/h'
  else
    lblSvR.Caption := FormatFloat('0.######', radValue) + ' µSv/h';
end;


procedure TmainForm.fNetTimerTimer(Sender: TObject);
var
  dateTime, urlString, httpReply, logText: string;
  HTTPClient: TIdHTTP;
  I, totalCPM: Integer;
  hadException: Boolean;
begin
  hadException := False;
  HTTPClient   := TIdHTTP.Create(nil);
  httpReply    := '';
  dateTime     := FormatDateTime('DD-MM-YYYY HH:MM:SS', Now);
  totalCPM     := 0;
  fErrorEdit.Lines.Add(dateTime);
  fErrorEdit.Lines.Add(#9 + 'Sending data to RadMon...');

  for I := 0 to CPMList.Count - 1 do
    totalCPM := totalCPM + CPMList[I];

  totalCPM := totalCPM Div CPMList.Count;
  fErrorEdit.Lines.Add(#9 + 'totalCPM: ' + IntToStr(totalCPM));
  dateTime  := FormatDateTime('YYYY-MM-DD%20HH:MM:SS', Now);
  urlString := 'http://'          + RADMON_HOST        + '/radmon.php' +
               '?user='           + Username           +
               '&password='       + Password           +
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
                   #9 + ' Check your username and password.' + sLineBreak
      else
        if httpReply.ToLower.Contains('error') then
          logText := #9 + 'Error sending data to RadMon.' + ' An unknown error occurred.' + sLineBreak +
                     #9 + 'Please make sure your username is correct, it is case-sensitive!' + sLineBreak
        else
        begin
          logText := #9 + 'Response: ' + StringReplace(httpReply, '<br>', '', [rfReplaceAll, rfIgnoreCase]) + sLineBreak;
          fStatusBar.Panels[0].Text := 'Last uploaded: ' + IntToStr(totalCPM) + ' CPM';
        end;

    fErrorEdit.Lines.Add(logText);
  finally
    FreeAndNil(HTTPClient);
  end;

  CPMList.Clear;
end;

end.
