unit About;

{
  This is the about form unit file of RadiaLog.
  File GUID: [6D6676FC-ED63-40E3-98FD-6F62F9F776FE]

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
