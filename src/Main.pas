unit Main;
{
  This is the main form unit file of RadiaLog.
  File GUID: [EA9ED897-741D-40AA-B97A-319538BA02E2]

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
  Windows, SysUtils, Classes, INIFiles, Generics.Collections,
  // VCL units
  Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Graphics,
  Vcl.Forms, Vcl.Menus, Vcl.Mask, Vcl.Imaging.pngimage,
  // TeeChart units
  VCLTee.TeEngine, VCLTee.Series, VCLTee.TeeProcs, VCLTee.Chart,
  // Asynch Pro units
  AdPort,
  // Cindy units
  cyBaseLed, cyLed, cyBaseMeasure, cyCustomGauge, cySimpleGauge, cyEdit,
  cyEditFloat,
  // OpenAL
  OpenAL,
  // Own units
  Defaults, About, AudioGeigers, SerialGeigers;

type
  TmainForm = class(TForm)
    fStatusBar: TStatusBar;
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
            edtFactor: TcyEditFloat;
            chkBoxUnitType: TCheckBox;
            Label15: TLabel;
          GroupBox4: TGroupBox;
            lblTubes: TLabel;
            lblFactors: TLabel;
          GroupBox5: TGroupBox;
            Label17: TLabel;
            rbMyGeiger: TRadioButton;
            rbGMC: TRadioButton;
            rbNetIO: TRadioButton;
            rbAudio: TRadioButton;
          GroupBox6: TGroupBox;
            Label14: TLabel;
            edtThreshold: TcyEditFloat;
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
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cStatusLedClick(Sender: TObject);
    procedure fBtnAboutClick(Sender: TObject);
    procedure chkBoxClick(Sender: TObject);
    procedure edtChange(Sender: TObject);
    procedure rbModeClick(Sender: TObject);
    procedure ReapTimerTick(Sender: TObject);
  private
    // Audio related
    fAudioThreshold: Double;
    fAudioControl:   TAudioGeiger;
    // Serial related
    fComPort:      string;
    fComBaud:      Integer;
    fComDataBits:  Word;
    fComStopBits:  Word;
    fComParity:    Word;
    fMGControl:    TMyGeiger;
    fGMCControl:   TGMC;
    fNetIOControl: TNetIO;
    // Timer related
    fThreadReapTimer: TTimer;
    // Conversion
    fConvertFactor: Double;
    fConvertmR:     Boolean;
    // Modes
    fAudioMode:    Boolean;
    fMyGeigerMode: Boolean;
    fGMCMode:      Boolean;
    fNetIOMode:    Boolean;
    // Misc
    fSettings:    TINIFile;
    fSafeToWrite: Boolean;
    fUploadRM:    Boolean;
	  Saved8087CW:  Word;
    procedure updateDosiLbl(aCPM: Integer);
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
  {$WARN SYMBOL_PLATFORM OFF}
  Saved8087CW := Default8087CW;
  {$WARN SYMBOL_PLATFORM ON}
  Set8087CW($133F);
  mainForm.Caption         := 'RadiaLog ' + VERSION_PREFIX + VERSION + VERSION_SUFFIX;
  exeDir                   := ExtractFilePath(Application.ExeName);
  fPlotPointList           := TList<TChartData>.Create;
  chkBoxUnitType.Hint      := 'Checked: µR/h' + sLineBreak + 'Unckecked: µSv/h';
  lblTubes.Caption         := 'SBM-20' + sLineBreak + 'SBM-19' + sLineBreak +
                              'SI-29BG' + sLineBreak + 'SI-180G' + sLineBreak +
                              'LND-712' + sLineBreak + 'LND-7317' + sLineBreak +
                              'J305' + sLineBreak + 'SBT11-A' + sLineBreak +
                              'SBT-9' + sLineBreak + 'M4011' + sLineBreak;
  lblFactors.Caption       := '0.0057' + sLineBreak + '0.0021' + sLineBreak +
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
  fSafeToWrite         := False;
  fSettings            := TINIFile.Create(exeDir + '/Settings.ini');

  // Write initial file if it does not exist.
  if not FileExists(exeDir + '/Settings.ini') then
  begin
    fSettings.WriteString('SERIAL',  'Port',       'COM1');
    fSettings.WriteInteger('SERIAL', 'Baud',       2400);
    fSettings.WriteInteger('SERIAL', 'Parity',     0);
    fSettings.WriteInteger('SERIAL', 'DataBits',   8);
    fSettings.WriteInteger('SERIAL', 'StopBits',   0);
    fSettings.WriteFloat('AUDIO',    'Threshold',  0.0300);
    fSettings.WriteString('USER',    'Username',   'TestUser');
    fSettings.WriteString('USER',    'Password',   'TestPass');
    fSettings.WriteBool('USER',      'Upload',     True);
    fSettings.WriteFloat('CONVERT',  'Factor',     0.0057);
    fSettings.WriteBool('CONVERT',   'UnitR',      False);
    fSettings.WriteBool('MODE',      'Audio',      False);
    fSettings.WriteBool('MODE',      'MyGeiger',   True);
    fSettings.WriteBool('MODE',      'GMC',        False);
    fSettings.WriteBool('MODE',      'NetIO',      False);
  end;

  // Read INI values
  fComPort         := fSettings.ReadString('SERIAL',  'Port',       'COM1');
  fComBaud         := fSettings.ReadInteger('SERIAL', 'Baud',       2400);
  fComParity       := fSettings.ReadInteger('SERIAL', 'Parity',     0);
  fComDataBits     := fSettings.ReadInteger('SERIAL', 'DataBits',   8);
  fComStopBits     := fSettings.ReadInteger('SERIAL', 'StopBits',   0);
  fAudioThreshold  := fSettings.ReadFloat('AUDIO',    'Threshold',  0.0300);
  fUsername        := fSettings.ReadString('USER',    'Username',   'TestUser');
  fPassword        := fSettings.ReadString('USER',    'Password',   'TestPass');
  fUploadRM        := fSettings.ReadBool('USER',      'Upload',     True);
  fConvertFactor   := fSettings.ReadFloat('CONVERT',  'Factor',     0.0057);
  fConvertmR       := fSettings.ReadBool('CONVERT',   'UnitR',      False);
  fAudioMode       := fSettings.ReadBool('MODE',      'Audio',      False);
  fMyGeigerMode    := fSettings.ReadBool('MODE',      'MyGeiger',   True);
  fGMCMode         := fSettings.ReadBool('MODE',      'GMC',        False);
  fNetIOMode       := fSettings.ReadBool('MODE',      'NetIO',      False);
  FreeAndNil(fSettings);

  // Apply values to visual components
  comPortBox.ItemIndex     := comPortBox.Items.IndexOf(fComPort);
  comBaudBox.ItemIndex     := comBaudBox.Items.IndexOf(IntToStr(fComBaud));
  comParityBox.ItemIndex   := fComParity;
  comDataBitsBox.ItemIndex := comDataBitsBox.Items.IndexOf(IntToStr(fComDataBits));
  comStopBitsBox.ItemIndex := fComStopBits;
  edtThreshold.Value       := fAudioThreshold;
  edtUsername.Text         := fUsername;
  edtPassword.Text         := fPassword;
  chkBoxRadmon.Checked     := fUploadRM;
  edtFactor.Value          := fConvertFactor;
  chkBoxUnitType.Checked   := fConvertmR;
  fSafeToWrite             := True;
  rbMyGeiger.Checked       := fMyGeigerMode;
  rbGMC.Checked            := fGMCMode;
  rbNetIO.Checked          := fNetIOMode;
  rbAudio.Checked          := fAudioMode;

  fThreadReapTimer          := TTimer.Create(nil);
  fThreadReapTimer.Enabled  := False;
  fThreadReapTimer.OnTimer  := ReapTimerTick;
  fThreadReapTimer.Interval := 300;
end;


procedure TmainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if fAudioMode and not (Pointer(TObject(fAudioControl)) = nil) then
  begin
    fAudioControl.Terminate;
    FreeAndNil(fAudioControl);
  end;

  Set8087CW(Saved8087CW); // Default value (with exceptions) is $1372.

  if fMyGeigerMode then
    FreeAndNil(fMGControl);

  if fGMCMode then
    FreeAndNil(fGMCControl);

  if fNetIOMode then
    FreeAndNil(fNetIOControl);
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
  rbAudio.Checked     := Sender = rbAudio;
  rbMyGeiger.Checked  := Sender = rbMyGeiger;
  rbGMC.Checked       := Sender = rbGMC;
  rbNetIO.Checked     := Sender = rbNetIO;
  fAudioMode          := rbAudio.Checked;
  fMyGeigerMode       := rbMyGeiger.Checked;
  fGMCMode            := rbGMC.Checked;
  fNetIOMode          := rbNetIO.Checked;

  if fSafeToWrite then
  begin
    fSettings := TINIFile.Create(exeDir + '/Settings.ini');
    fSettings.WriteBool('MODE', 'Audio',    fAudioMode);
    fSettings.WriteBool('MODE', 'MyGeiger', fMyGeigerMode);
    fSettings.WriteBool('MODE', 'GMC',      fGMCMode);
    fSettings.WriteBool('MODE', 'NetIO',    fNetIOMode);
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
    fPlotPointList.Clear;
    cCPMEdit.Clear;
    cErrorEdit.Clear;

    if fAudioMode then
    begin
      fAudioControl               := TAudioGeiger.Create(fAudioThreshold, True);
      fAudioControl.ConvertFactor := fConvertFactor;
      fAudioControl.ConvertmR     := fConvertmR;
      fAudioControl.UploadRM      := fUploadRM;
      fAudioControl.CPMBar        := cCPMBar;
      fAudioControl.LblCPM        := lblCPM;
      fAudioControl.LblDosi       := lblDosi;
      fAudioControl.CPMChart      := cCPMChart;
      fAudioControl.CPMLog        := cCPMEdit;
      fAudioControl.ErrorLog      := cErrorEdit;
      fAudioControl.Start;
    end;

    if fMyGeigerMode then
    begin
      fMGControl := TMyGeiger.Create(StrToInt(StringReplace(fComPort, 'COM', '', [rfReplaceAll, rfIgnoreCase])),
                                     fComBaud,
                                     TParity(fComParity),
                                     fComDataBits,
                                     fComStopBits);

      fMGControl.ConvertFactor := fConvertFactor;
      fMGControl.ConvertmR     := fConvertmR;
      fMGControl.UploadRM      := fUploadRM;
      fMGControl.CPMBar        := cCPMBar;
      fMGControl.LblCPM        := lblCPM;
      fMGControl.LblDosi       := lblDosi;
      fMGControl.CPMChart      := cCPMChart;
      fMGControl.CPMLog        := cCPMEdit;
      fMGControl.ErrorLog      := cErrorEdit;
    end;

    if fGMCMode then
    begin
      fGMCControl := TGMC.Create(StrToInt(StringReplace(fComPort, 'COM', '', [rfReplaceAll, rfIgnoreCase])),
                                 fComBaud,
                                 TParity(fComParity),
                                 fComDataBits,
                                 fComStopBits);

      fGMCControl.ConvertFactor := fConvertFactor;
      fGMCControl.ConvertmR     := fConvertmR;
      fGMCControl.UploadRM      := fUploadRM;
      fGMCControl.CPMBar        := cCPMBar;
      fGMCControl.LblCPM        := lblCPM;
      fGMCControl.LblDosi       := lblDosi;
      fGMCControl.CPMChart      := cCPMChart;
      fGMCControl.CPMLog        := cCPMEdit;
      fGMCControl.ErrorLog      := cErrorEdit;
    end;

    if fNetIOMode then
    begin
      fNetIOControl := TNetIO.Create(StrToInt(StringReplace(fComPort, 'COM', '', [rfReplaceAll, rfIgnoreCase])),
                                     fComBaud,
                                     TParity(fComParity),
                                     fComDataBits,
                                     fComStopBits);

      fNetIOControl.ConvertFactor := fConvertFactor;
      fNetIOControl.ConvertmR     := fConvertmR;
      fNetIOControl.UploadRM      := fUploadRM;
      fNetIOControl.CPMBar        := cCPMBar;
      fNetIOControl.LblCPM        := lblCPM;
      fNetIOControl.LblDosi       := lblDosi;
      fNetIOControl.CPMChart      := cCPMChart;
      fNetIOControl.CPMLog        := cCPMEdit;
      fNetIOControl.ErrorLog      := cErrorEdit;
    end;

    comPortBox.Enabled     := False;
    comBaudBox.Enabled     := False;
    comParityBox.Enabled   := False;
    comDataBitsBox.Enabled := False;
    comStopBitsBox.Enabled := False;
    edtThreshold.Enabled   := False;
    rbAudio.Enabled        := False;
    rbMyGeiger.Enabled     := False;
    rbGMC.Enabled          := False;
    rbNetIO.Enabled        := False;
  end else
    fThreadReapTimer.Enabled := True;
end;


{ To be sure the thread is reaped safely and not whilst it is still being created }
procedure TmainForm.ReapTimerTick(Sender: TObject);
begin
  fThreadReapTimer.Enabled := False;

  if fAudioMode then
  begin
    fAudioControl.Terminate;
    FreeAndNil(fAudioControl);
  end;
    // TerminateThread(fAudioControl.Handle, 1);

  if fMyGeigerMode then
    FreeAndNil(fMGControl);

  if fGMCMode then
    FreeAndNil(fGMCControl);

  if fNetIOMode then
    FreeAndNil(fNetIOControl);

  comPortBox.Enabled     := True;
  comBaudBox.Enabled     := True;
  comParityBox.Enabled   := True;
  comDataBitsBox.Enabled := True;
  comStopBitsBox.Enabled := True;
  edtThreshold.Enabled   := True;
  rbAudio.Enabled        := True;
  rbMyGeiger.Enabled     := True;
  rbGMC.Enabled          := True;
  rbNetIO.Enabled        := True;
end;

end.
