program RadiaLog;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  Main in 'src\Main.pas' {mainForm},
  About in 'src\About.pas' {aboutForm},
  Defaults in 'src\Defaults.pas',
  ThimoUtils in 'src\common\ThimoUtils.pas',
  GeigerMethods in 'src\GeigerHandlers\GeigerMethods.pas',
  AudioGeigers in 'src\GeigerHandlers\AudioGeigers.pas',
  openal in 'src\common\openal.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'RadiaLog';
  TStyleManager.TrySetStyle('Carbon');
  Application.CreateForm(TmainForm, mainForm);
  Application.CreateForm(TaboutForm, aboutForm);
  Application.Run;
end.
