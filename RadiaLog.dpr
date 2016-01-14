program RadiaLog;

uses
  Vcl.Forms,
  Main in 'src\Main.pas' {mainForm},
  Defaults in 'src\Defaults.pas',
  About in 'src\About.pas' {aboutForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TmainForm, mainForm);
  Application.CreateForm(TaboutForm, aboutForm);
  Application.Run;
end.
