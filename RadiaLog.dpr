program RadiaLog;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Vcl.Forms,
  Main in 'src\Main.pas' {mainForm},
  Defaults in 'src\Defaults.pas',
  About in 'src\About.pas' {aboutForm},
  ThimoControls in 'src\controls\ThimoControls.pas',
  ThimoUtils in 'src\common\ThimoUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TmainForm, mainForm);
  Application.CreateForm(TaboutForm, aboutForm);
  Application.Run;
end.
