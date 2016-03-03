unit GeigerMethods;

interface
uses
  // System units
  Classes, SysUtils,
  // Asynch Pro units
  AdPort, OoMisc,
  // OpenAL unit
  OpenAL,
  // VCL units
  VCL.ExtCtrls, VCL.Graphics,
  // Custom units
  Defaults, NetworkMethods;


procedure updateCPMBar(aCPM: Integer);
procedure updatePlot(aCPM: Integer);
procedure updateDosiLbl(aCPM: Integer);

type
  TMethodSerial = class(TObject)
    protected
      fSumCPM:         Integer;
      fNetworkHandler: TNetworkController;
      fBufferTimer:    TTimer;
	    fPortAddress:    Integer;
	    fPortBaud:       Integer;
	    fPortParity:     TParity;
	    fPortDataBits:   Word;
	    fPortStopBits:   Word;
	    fComPort:        TApdComPort;
    public
      constructor Create(aPort, aBaud: Integer; aParity: TParity;
                         aDataBits, aStopBits: Word;
                         CreateSuspended: Boolean = False);
      destructor Destroy; override;
  end;

  TMethodAudio = class(TThread)
    protected
      fSumCPM: Integer;
      fNetworkHandler: TNetworkController;
      fIsSoundInitialized: Boolean;
      procedure Execute; override;
    public
      constructor Create(CreateSuspended: Boolean = False);
      destructor Destroy; override;
      property Initialized: Boolean Read fIsSoundInitialized;
  end;

implementation
constructor TMethodSerial.Create(aPort, aBaud: Integer; aParity: TParity;
                                 aDataBits, aStopBits: Word;
                                 CreateSuspended: Boolean = False);
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


destructor TMethodSerial.Destroy;
begin
  inherited;
  fComPort.Open := False;
  fComPort.DonePort;
  FreeAndNil(fComPort);
  FreeAndNil(fNetworkHandler);
end;


constructor TMethodAudio.Create(CreateSuspended: Boolean = False);
begin
  inherited Create(CreateSuspended);
  fNetworkHandler     := TNetworkController.Create;
  fIsSoundInitialized := InitOpenAL;
  // Disable 3D spatialization for speed up
  alDistanceModel(AL_NONE);
  Set8087CW($133F);
end;


destructor TMethodAudio.Destroy;
begin
  inherited;
  FreeAndNil(fNetworkHandler);
end;


procedure TMethodAudio.Execute;
begin
  FreeOnTerminate := True;
end;


procedure updateCPMBar(aCPM: Integer);
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


procedure updatePlot(aCPM: Integer);
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


procedure updateDosiLbl(aCPM: Integer);
var
  DosiValue: Double;
begin
  DosiValue := aCPM * fConvertFactor;

  if fConvertmR then
    fLblDosi.Caption := FormatFloat(',0.000000', DosiValue / SVTOR) + ' µR/h'
  else
    fLblDosi.Caption := FormatFloat(',0.000000', DosiValue) + ' µSv/h';
end;

end.
