{   Unit cyJDB

    Description:
    Unit with functions to use for Database.

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

unit cyDB;

interface

uses Classes, Forms, DB, DBClient, DBGrids, cyModalContainer, Dialogs;

type
  TFilterArgumentMode = (faAnd, faOr);

procedure Save(aDataset: TDataSet);
procedure Cancel(aDataset: TDataSet);
function IsEmpty(aDataset: TDataSet): Boolean;
function Edit(aDataset: TDataset; ErrorMsg: String): Boolean;
function Delete(aDataset: TDataSet; ErrorMsg: String): Boolean;
function DeleteCurrentRecords(aDataset: TDataSet): Boolean;
procedure DuplicateRecord(aDataset: TDataSet);
procedure SaveAsNewRecord(aDataset: TDataSet);
function CloneFieldValues(DatasetSrc, DatasetDest: TDataSet; const Src_FieldTag: Integer = 0; const Only_FieldTag: Boolean = false): Boolean;
function FindKey(aClientDataset: TClientDataset; Value: String): Boolean;
procedure FindNearest(aClientDataset: TClientDataset; Value: String);
procedure ShowModalRecords(aDataSet: TDataSet; DBGridWidth, DBGridHeight: Word);
procedure AddToFilter(var CurrentFilter: String; AddArgument: String; const ArgumentMode: TFilterArgumentMode = faAnd);

implementation

procedure Save(aDataset: TDataSet);
begin
  if aDataset.State in [DsEdit, DsInsert] then
    aDataset.Post;
end;

procedure Cancel(aDataset: TDataSet);
begin
  if aDataset.State in [DsEdit, DsInsert] then
    aDataset.Cancel;
end;

function IsEmpty(aDataset: TDataSet): Boolean;
begin
  if aDataset.State = dsInsert
  then Result := false
  else Result := aDataset.EOF and aDataset.BOF;
end;

function Edit(aDataset: TDataset; ErrorMsg: String): Boolean;
begin
  Result := true;

  if (aDataset.State <> dsInsert) and (aDataset.State <> dsEdit) then
    try
      aDataset.Edit;
    except
      Result := false;

      if ErrorMsg <> '' then
        MessageDlg(ErrorMsg, mtError, [mbOk], 0);
    end;
end;

function Delete(aDataset: TDataSet; ErrorMsg: String): Boolean;
begin
  Result := False;
  if IsEmpty(aDataset) then Exit;

  try
    if aDataset.State = dsInsert
    then aDataset.Cancel
    else aDataset.Delete;

    Result := True;
  except
    if ErrorMsg <> '' then
      MessageDlg(ErrorMsg, mtError, [mbOk], 0);
  end;
end;

function DeleteCurrentRecords(aDataset: TDataSet): Boolean;
var
  Cont: Boolean;
begin
  Result := True;
  Cont   := (not IsEmpty(aDataset));

  while Cont do
    if not Delete(aDataset, '') then
    begin
      Cont   := False;
      Result := False;
    end
    else
      Cont := not IsEmpty(aDataset);
end;

procedure DuplicateRecord(aDataset: TDataSet);
var
  Variants: array Of Variant;
  i : Integer;
begin
  SetLength(Variants, aDataset.Fields.Count);

  for i := 0 to aDataset.Fields.Count-1 do
    Variants[i] := aDataset.Fields[i].Value;

  aDataset.Append;

  for i:= 0 to aDataset.Fields.Count-1 do
    aDataset.Fields[i].Value := Variants[i];
end;

procedure SaveAsNewRecord(aDataset: TDataSet);
var
  Variants : array Of Variant;
  i : Integer;
begin
  SetLength(Variants, aDataset.Fields.Count);

  for i := 0 to aDataset.Fields.Count-1 do
    Variants[i] := aDataset.Fields[i].Value;

  Cancel(aDataset);
  aDataset.Append;

  for i:= 0 to aDataset.Fields.Count-1 do
    aDataset.Fields[i].Value := Variants[i];
end;

function CloneFieldValues(DatasetSrc, DatasetDest: TDataSet; const Src_FieldTag: Integer = 0; const Only_FieldTag: Boolean = false): Boolean;
var
  i :Integer;
  DestField: TField;
begin
  Result := True;

  for i := 0 to DatasetSrc.Fields.Count-1 do
    if (not Only_FieldTag) or (DatasetSrc.Fields[i].Tag = Src_FieldTag) then
      try
        DestField := DatasetDest.FindField(DatasetSrc.Fields[i].FieldName);

        if DestField <> nil then
          if DestField.FieldKind = fkData then
            case DestField.DataType of
              ftBoolean :
                DestField.AsBoolean := DatasetSrc.Fields[i].AsBoolean;
              else
                DestField.AsString := DatasetSrc.Fields[i].AsString;
            end;
      except
        Result := False;
      end;
end;

function FindKey(aClientDataset: TClientDataset; Value: String): Boolean;
begin
  try
    Result := aClientDataset.FindKey([Value]);
  except
    Result := false;
  end;
end;

procedure FindNearest(aClientDataset: TClientDataset; Value: String);
begin
  try
    aClientDataset.FindNearest([Value]);
  except
  end;
end;

procedure ShowModalRecords(aDataSet: TDataSet; DBGridWidth, DBGridHeight: Word);
var
  aDBGrid: TDBGrid;
  aDataSource: TDataSource;
begin
  aDBGrid := TDBGrid.Create(Nil);
  aDBGrid.Width := DBGridWidth;
  aDBGrid.Height := DBGridHeight;
  aDataSource := TDataSource.Create(nil);
  aDataSource.DataSet := aDataSet;
  aDBGrid.DataSource := aDataSource;
  ShowModalControl(aDBGrid, bsSingle, [biSystemMenu], wsNormal, $00D2D2D2, 1, 'ShowModalRecords()', Nil);
  aDBGrid.DataSource := Nil;
  aDataSource.Free;
  aDBGrid.Free;
end;

procedure AddToFilter(var CurrentFilter: String; AddArgument: String; const ArgumentMode: TFilterArgumentMode = faAnd);
begin
  if AddArgument = '' then Exit;

  if CurrentFilter <> '' then
  begin
    if AddArgument[1] <> '(' then
      AddArgument := '(' + AddArgument + ')';

    if CurrentFilter[1] <> '(' then
      CurrentFilter := '(' + CurrentFilter + ')';

    if ArgumentMode = faAnd
    then CurrentFilter := CurrentFilter + ' AND ' + AddArgument
    else CurrentFilter := CurrentFilter + ' OR ' + AddArgument;
  end
  else
    CurrentFilter := AddArgument;
end;

end.
