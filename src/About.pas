unit About;

interface

uses
  // System units
  Controls, Classes,
  // VCL units
  Vcl.Forms, Vcl.StdCtrls,
  // Custom units
  Defaults, ThimoUtils;

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
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    procedure websiteLinkClick(Sender: TObject);
    procedure Label7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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
  MailTo('RadiaLog ' + VERSION + VERSION_SUFFIX, '');
end;

procedure TaboutForm.websiteLinkClick(Sender: TObject);
begin
  BrowseURL('http://www.thibmoprograms.com/');
end;

end.
