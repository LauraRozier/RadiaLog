unit AudioGeigers;

interface
uses
  // System units
  SysUtils, Classes,
  // Custom units
  GeigerMethods, OpenAL;

type
  tAudioGeiger = class(tMethodAudio)
    private
      fDefaultDevice, fDeviceList: PALCubyte;
      fDefDeviceStr: string;
    protected
      // Protected stuff
    public
      constructor Create; overload;
      constructor Create(aPort: string); overload;
      destructor Destroy;
      property DefaultDevice: string Read fDefDeviceStr;
    published
      property Initialized;
      procedure GetAudioEnum(aDeviceList: TStringList);
  end;

implementation
constructor tAudioGeiger.Create;
begin
  Create('');
end;


constructor tAudioGeiger.Create(aPort: String);
begin
  inherited Create(aPort);
end;


destructor tAudioGeiger.Destroy;
begin
  inherited Destroy;
end;


procedure tAudioGeiger.GetAudioEnum(aDeviceList: TStringList);
var
  I: Integer;
begin
  if not Initialized then Exit;

  //enumerate devices
  fDefaultDevice := '';
  fDeviceList    := '';

  if alcIsExtensionPresent(nil,'ALC_ENUMERATION_EXT') then
  begin
   fDefaultDevice := alcGetString(nil, ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER);
   fDefDeviceStr  := string(fDefaultDevice);
   fDeviceList    := alcGetString(nil, ALC_CAPTURE_DEVICE_SPECIFIER);
  end;

  //make devices tstringlist
  aDeviceList.Add(string(fDeviceList));
  for I := 0 to 12 do
  begin
    StrCopy(fDeviceList, @fDeviceList[strlen(pChar(aDeviceList.text)) - (I + 1)]);
    if length(fDeviceList) <= 0 then break; //exit loop if no more devices are found
    aDeviceList.Add(string(fDeviceList));
  end;
  aDeviceList[0] := 'Default ('+ aDeviceList[0] +')';
end;

end.
