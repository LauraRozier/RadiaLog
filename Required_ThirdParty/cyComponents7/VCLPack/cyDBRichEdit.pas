{   Component(s):
    tcyDBRichEdit

    Description:
    Same as TDBRichEdit but without "Dataset not in edit or insert mode" on exit if ReadOnly is true ...

    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    $  €€€ Accept any PAYPAL DONATION $$$  €
    $      to: mauricio_box@yahoo.com      €
    €€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

    * ***** BEGIN LICENSE BLOCK *****
    *
    * Version: MPL 1.1
    *
    * The contents of this file are subject to the Mozilla Public License Version
    * 1.1 (the "License"); you may not use this file except in compliance with the
    * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
    *
    * Software distributed under the License is distributed on an "AS IS" basis,
    * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
    * the specific language governing rights and limitations under the License.
    *
    * The Initial Developer of the Original Code is Mauricio
    * (https://sourceforge.net/projects/tcycomponents/).
    *
    * Donations: see Donation section on Description.txt
    *
    * Alternatively, the contents of this file may be used under the terms of
    * either the GNU General Public License Version 2 or later (the "GPL"), or the
    * GNU Lesser General Public License Version 2.1 or later (the "LGPL"), in which
    * case the provisions of the GPL or the LGPL are applicable instead of those
    * above. If you wish to allow use of your version of this file only under the
    * terms of either the GPL or the LGPL, and not to allow others to use your
    * version of this file under the terms of the MPL, indicate your decision by
    * deleting the provisions above and replace them with the notice and other
    * provisions required by the LGPL or the GPL. If you do not delete the
    * provisions above, a recipient may use your version of this file under the
    * terms of any one of the MPL, the GPL or the LGPL.
    *
    * ***** END LICENSE BLOCK *****}

unit cyDBRichEdit;

{$I ..\Core\cyCompilerDefines.inc}

interface

uses Classes, Types, Graphics, StdCtrls, Forms, Windows, Messages, SysUtils, Controls, DB, DBCtrls;

type
  tcyDBRichEdit = class(TDBRichEdit)
  private
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
  protected
  public
  published
  end;

implementation

{ tcyDBRichEdit }
procedure tcyDBRichEdit.CMExit(var Message: TCMExit);
var
  ModifyField: Boolean;
begin
  ModifyField := false;

  if not ReadOnly then
    if Assigned(Field) then       // Control that Datasource and DataField assigned and dataset is active ...
      ModifyField := Field.CanModify; // also work: and (not Field.ReadOnly) and (DataSource.DataSet.CanModify);

  if ModifyField
  then Inherited
  else DoExit;    // We can' t call TDBRichEdit.CMExit !!!
end;

end.
