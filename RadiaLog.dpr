program RadiaLog;

uses
  // Mad Collection units
  madExcept, madLinkDisAsm, madListHardware, madListProcesses, madListModules,
  // VLC units
  Vcl.Forms, Vcl.Themes, Vcl.Styles,
  // Custom units
  Main in 'src\Main.pas' {mainForm},
  About in 'src\About.pas' {aboutForm},
  Defaults in 'src\Defaults.pas',
  ThimoUtils in 'src\common\ThimoUtils.pas';

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
