unit About;

interface

uses
  Winapi.Windows, System.Classes, Vcl.Forms, Vcl.ExtCtrls, Vcl.Controls,
  Vcl.StdCtrls, ShellApi, JvExControls, JvLinkLabel, Defaults;

type
  TaboutForm = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    lblVersion: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    procedure websiteLinkClick(Sender: TObject);
    procedure Label7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  aboutForm: TaboutForm;

implementation

{$R *.dfm}

procedure TaboutForm.FormCreate(Sender: TObject);
begin
  lblVersion.Caption := VERSION + VERSION_SUFFIX;
end;

procedure TaboutForm.Label7Click(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('mailto:thibmorozier@gmail.com'), nil, nil, SW_SHOWNORMAL);
end;

procedure TaboutForm.websiteLinkClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('http://www.thibmoprograms.com/'), nil, nil, SW_SHOWNORMAL);
end;

end.
