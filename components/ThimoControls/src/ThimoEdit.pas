unit ThimoEdit;

interface

uses
  {$IFDEF MSWindows} Winapi.Messages, Winapi.Windows, {$ENDIF}
  {$IFDEF Unix} WinUtils, LCLType, {$ENDIF}
  System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Menus, Vcl.Graphics, Winapi.CommCtrl, Vcl.ImgList,
  Vcl.Themes, Vcl.StdCtrls,
  ThimoControlUtils;

const
  DigitChars = ['0'..'9'];
  DEFAULTDS = ',0.####';

type
  TThimoCustomEdit = class(TCustomEdit)
  private
    class constructor Create;
    class destructor Destroy;
  private
    fDecimals: Byte;
    fDecimalSeparator: Char;
    fDisplayFormat: string;
    fChanging, fIsNegative: Boolean;
    fOldValue: Extended;
    function IsFormatStored: Boolean;
    function IsValueStored: Boolean;
    procedure SetDecimals(NewValue: Byte);
    procedure SetDisplayFormat(const Value: string);
  protected
    function IsValidChar(Key: Char): Boolean; virtual;
    procedure DataChanged; virtual;
    function DefaultDisplayFormat: string; virtual;
    function GetValue: Extended; virtual; abstract;
    procedure SetValue(aValue: Extended); virtual; abstract;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure Change; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Decimals: Byte read fDecimals write SetDecimals default 4;
    property DecimalSeparator: Char read fDecimalSeparator write fDecimalSeparator;
    property DisplayFormat: string read fDisplayFormat write SetDisplayFormat stored IsFormatStored;
    property Value: Extended read GetValue write SetValue stored IsValueStored;
  end;

  TThimoFloatEdit = class(TThimoCustomEdit)
  strict private
    class constructor Create;
    class destructor Destroy;
  protected
    function GetValue: Extended; override;
    procedure SetValue(aValue: Extended); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Alignment;
    property Anchors;
    property AutoSelect;
    property AutoSize;
    property BevelEdges;
    property BevelInner;
    property BevelKind default bkNone;
    property BevelOuter;
    property BevelWidth;
    property BiDiMode;
    property BorderStyle;
    property CharCase;
    property Color;
    property Constraints;
    property Ctl3D;
    property DoubleBuffered;
    property Decimals;
    property DecimalSeparator;
    property DisplayFormat;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property OEMConvert;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentDoubleBuffered;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property TextHint;
    property Touch;
    property Value;
    property Visible;
    property StyleElements;
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGesture;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

procedure Register;

implementation

class constructor TThimoCustomEdit.Create;
begin
  TCustomStyleEngine.RegisterStyleHook(TThimoCustomEdit, TEditStyleHook);
end;


constructor TThimoCustomEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csSetCaption];
  fDecimals         := 4;
  fDecimalSeparator := DSep;
  DisplayFormat     := DEFAULTDS;
  Value             := 0.0;
end;



class destructor TThimoCustomEdit.Destroy;
begin
  TCustomStyleEngine.UnRegisterStyleHook(TThimoCustomEdit, TEditStyleHook);
end;


procedure TThimoCustomEdit.DataChanged;
var
  EditFormat: string;
  WasModified: Boolean;
begin
  if fDisplayFormat <> '' then
  begin
    EditFormat := ',0';
    if fDecimals > 0 then
      EditFormat := EditFormat + '.' + MakeStr('0', fDecimals);
    // Changing EditText sets Modified to false
    WasModified := Modified;
    try
      Text := FormatFloat(EditFormat, Value);
    finally
      Modified := WasModified;
    end;
  end;
end;


function TThimoCustomEdit.DefaultDisplayFormat: string;
begin
  Result := DEFAULTDS;
end;


function TThimoCustomEdit.IsFormatStored: Boolean;
begin
  Result := DisplayFormat <> DEFAULTDS;
end;


function TThimoCustomEdit.IsValueStored: Boolean;
begin
  Result := GetValue <> 0;
end;


function TThimoCustomEdit.IsValidChar(Key: Char): Boolean;
var
  ValidChars: TSysCharSet;
begin
  ValidChars := DigitChars + ['+', '-'];

  if Pos(fDecimalSeparator, Text) = 0 then
    ValidChars := ValidChars + [fDecimalSeparator];

  Result := CharInSet(Key, ValidChars) or (Key < #32);
end;


procedure TThimoCustomEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if (Key = VK_UP) or (Key = VK_DOWN) then
    Key := 0;

  // Do not delete the decimal separator while typing
  if (Key = VK_DELETE) and (SelStart < Length(Text)) and (Text[SelStart + 1] = fDecimalSeparator) then
    Key := VK_RIGHT;
  if (Key = VK_BACK) and (SelStart > 0) and (Text[SelStart] = fDecimalSeparator) then
    Key := VK_LEFT;
end;


procedure TThimoCustomEdit.KeyPress(var Key: Char);
var
  I: Integer;
begin
  // Hitting '.' now behaves like hitting the decimal separator
  if (Key = '.') and (fDecimalSeparator <> '.') then
    Key := fDecimalSeparator;

  if (Key = fDecimalSeparator) then
  begin
    // If the key is the decimal separator move the caret behind it.
    I := Pos(fDecimalSeparator, Text);
    if I <> 0 then
    begin
      Key := #0;
      SelLength := 0;
      SelStart := I;
      Exit;
    end;
  end;

  if not IsValidChar(Key) then
  begin
    Key := #0;
    Beep;
  end;

  if Key <> #0 then
  begin
    inherited KeyPress(Key);
    if (Key = #13) or (Key = #27) then
    begin
      // Catch and remove this
      GetParentForm(Self).Perform(CM_DIALOGKEY, Byte(Key), 0);
      if Key = #13 then
        Key := #0;
    end;
  end;
end;


procedure TThimoCustomEdit.Change;
var
  OldText: string;
  OldSelStart: Integer;
begin
  if fChanging or not HandleAllocated then
    Exit;

  fChanging := True;
  fIsNegative := False;
  OldSelStart := SelStart;
  try
    OldText := inherited Text;
    if OldText <> '' then
      fIsNegative := Text[1] = '-';

    SetValue(Value);
  finally
    fChanging := False;
    fIsNegative := False; // reset
  end;

  SelStart := OldSelStart;

  if fOldValue <> Value then
  begin
    inherited Change;
    fOldValue := Value;
  end;
end;


procedure TThimoCustomEdit.SetDisplayFormat(const Value: string);
begin
  if DisplayFormat <> Value then
  begin
    fDisplayFormat := Value;
    Invalidate;
  end;
end;


procedure TThimoCustomEdit.SetDecimals(NewValue: Byte);
begin
  if fDecimals <> NewValue then
  begin
    fDecimals := NewValue;
    Value := GetValue;
  end;
end;


class constructor TThimoFloatEdit.Create;
begin
  TCustomStyleEngine.RegisterStyleHook(TThimoFloatEdit, TEditStyleHook);
end;


constructor TThimoFloatEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Text := '0';
end;


class destructor TThimoFloatEdit.Destroy;
begin
  TCustomStyleEngine.UnRegisterStyleHook(TThimoFloatEdit, TEditStyleHook);
end;


function TThimoFloatEdit.GetValue: Extended;
begin
  try
    if FDisplayFormat <> '' then
      try
        Result := StrToFloat(TextToValText(Text));
      except
        Result := 0.0;
    end else
      if not TextToFloat(PChar(Text), Result, fvExtended) then
        Result := 0.0;
  except
    Result := 0.0
  end;
end;


procedure TThimoFloatEdit.SetValue(aValue: Extended);
var
  FloatFormat: TFloatFormat;
  WasModified: Boolean;
begin
  FloatFormat := ffFixed;

  // Changing EditText sets Modified to false
  WasModified := Modified;
  try
    if fDisplayFormat <> '' then
      Text := FormatFloat(fDisplayFormat, aValue)
    else
      Text := FloatToStrF(aValue, FloatFormat, 15, fDecimals);

    if fIsNegative and (Text <> '') and (Text[1] <> '-') then
      Text := '-' + Text;
    DataChanged;
  finally
    Modified := WasModified;
  end;
end;


procedure Register;
begin
  RegisterComponents('Thimo', [TThimoFloatEdit]);
end;

end.
