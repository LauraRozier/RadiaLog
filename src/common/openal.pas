unit OpenAL;
{* Version: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is OpenAL1.0 - Headertranslation to Object Pascal.
 *
 * The Initial Developer of the Original Code is
 * Delphi OpenAL Translation Team.
 * Portions created by the Initial Developer are Copyright (C) 2001-2004
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Thimo Braker            (thibmorozier@gmail.com)
 *   Tom Nuydens             (delphi3d@gamedeveloper.org)
 *   Dean Ellis              (dean.ellis@sxmedia.co.uk)
 *   Amresh Ramachandran     (amreshr@hotmail.com)
 *   Pranav Joshi            (pranavjosh@yahoo.com)
 *   Marten van der Honing   (mvdhoning@noeska.com)
 *   Benjamin Rosseaux (BeRo)
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either the GNU General Public License Version 2 or later (the "GPL"), or
 * the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the MPL, the GPL or the LGPL.
 *}

{$I OpenALH.inc}

implementation
{$IFDEF MSWindows} uses mmsystem; {$ENDIF}

type
  // WAV file header
  TWAVHeader = record
    RIFFHeader:       array [1..4] of AnsiChar;
    FileSize:         LongInt;
    WAVEHeader:       array [1..4] of AnsiChar;
    FormatHeader:     array [1..4] of AnsiChar;
    FormatHeaderSize: LongInt;
    FormatCode:       Word;
    ChannelNumber:    Word;
    SampleRate:       LongInt;
    BytesPerSecond:   LongInt;
    BytesPerSample:   Word;
    BitsPerSample:    Word;
  end;

const
  WAV_STANDARD  = $0001;
  WAV_IMA_ADPCM = $0011;
  WAV_MP3       = $0055;

{$IFDEF FPC}
{$IFNDEF MSWindows}
// Added by bero
const
  RTLD_LAZY         = $001;
  RTLD_NOW          = $002;
  RTLD_BINDING_MASK = $003;
  LibraryLib        = {$IFDEF Linux}'dl'{$ELSE !Linux}'c'{$ENDIF !Linux};

function LoadLibraryEx(Name:   PChar;   Flags: LongInt): Pointer; cdecl; external LibraryLib name 'dlopen';
function GetProcAddressEx(Lib: Pointer; Name:  PChar):   Pointer; cdecl; external LibraryLib name 'dlsym';
function FreeLibraryEx(Lib:    Pointer): LongInt;                 cdecl; external LibraryLib name 'dlclose';


function LoadLibrary(Name: PChar): THandle;
begin
 Result := THandle(LoadLibraryEx(Name, RTLD_LAZY));
end;


function GetProcAddress(LibHandle: THandle; ProcName: PChar): Pointer;
begin
 Result := GetProcAddressEx(Pointer(LibHandle), ProcName);
end;


function FreeLibrary(LibHandle: THandle): Boolean;
begin
 if LibHandle = 0 then
   Result := False
  else
   Result := FreeLibraryEx(Pointer(LibHandle)) = 0;
end;
{$ENDIF MSWindows}
{$ENDIF FPC}


// ProcName can be case sensitive !!!
function alProcedure(ProcName: PAnsiChar): Pointer;
begin
  Result := nil;

  if Addr(alGetProcAddress) <> nil then
    Result := alGetProcAddress(ProcName);

  if result <> nil then
    exit;

  Result := GetProcAddress(LibHandle, ProcName);
end;


{$IFDEF ALUT}
function InitOpenAL(LibName, AlutLibName: String): Boolean;
{$ELSE}
function InitOpenAL(LibName: String): Boolean;
{$ENDIF}
begin
  Result := False;

  if LibHandle <> 0 then FreeLibrary(LibHandle);

  LibHandle := LoadLibrary(PChar(LibName));

{$IFDEF ALUT}
  if AlutLibHandle <> 0 then FreeLibrary(AlutLibHandle);

  AlutLibHandle := LoadLibrary(PChar(AlutLibName));

  if (AlutLibHandle <> 0) then
  begin
    alutInit          := GetProcAddress(AlutLibHandle, alutInit);
    alutExit          := GetProcAddress(AlutLibHandle, 'alutExit');
    alutLoadWAVFile   := GetProcAddress(AlutLibHandle, 'alutLoadWAVFile');
    alutLoadWAVMemory := GetProcAddress(AlutLibHandle, 'alutLoadWAVMemory');
    alutUnloadWAV     := GetProcAddress(AlutLibHandle, 'alutUnloadWAV');
  end;
{$ENDIF}

  alGetProcAddress := GetProcAddress(LibHandle, 'alGetProcAddress'  );

  if (LibHandle <> 0) then
  begin
    alEnable             := alProcedure('alEnable');
    alDisable            := alProcedure('alDisable');
    alIsEnabled          := alProcedure('alIsEnabled');
    alHint               := alProcedure('alHint');
    alGetBooleanv        := alProcedure('alGetBooleanv');
    alGetIntegerv        := alProcedure('alGetIntegerv');
    alGetFloatv          := alProcedure('alGetFloatv');
    alGetDoublev         := alProcedure('alGetDoublev');
    alGetString          := alProcedure('alGetString');
    alGetBoolean         := alProcedure('alGetBoolean');
    alGetInteger         := alProcedure('alGetInteger');
    alGetFloat           := alProcedure('alGetFloat');
    alGetDouble          := alProcedure('alGetDouble');
    alGetError           := alProcedure('alGetError');
    alIsExtensionPresent := alProcedure('alIsExtensionPresent');
    alGetEnumValue       := alProcedure('alGetEnumValue');

    alListenerf  := alProcedure('alListenerf');
    alListener3f := alProcedure('alListener3f');
    alListenerfv := alProcedure('alListenerfv');

    alListeneri  := alProcedure('alListeneri');
    alListener3i := alProcedure('alListener3i');
    alListeneriv := alProcedure('alListeneriv');

    alGetListeneriv := alProcedure('alGetListeneriv');
    alGetListenerfv := alProcedure('alGetListenerfv');

    alGenSources    := alProcedure('alGenSources');
    alDeleteSources := alProcedure('alDeleteSources');
    alIsSource      := alProcedure('alIsSource');

    alSourcei  := alProcedure('alSourcei');
    alSource3i := alProcedure('alSource3i');
    alSourceiv := alProcedure('alSourceiv');

    alSourcef  := alProcedure('alSourcef');
    alSource3f := alProcedure('alSource3f');
    alSourcefv := alProcedure('alSourcefv');

    alGetSourcei  := alProcedure('alGetSourcei');
    alGetSource3i := alProcedure('alGetSource3i');
    alGetSourceiv := alProcedure('alGetSourceiv');

    alGetSourcef  := alProcedure('alGetSourcef');
    alGetSource3f := alProcedure('alGetSource3f');
    alGetSourcefv := alProcedure('alGetSourcefv');

    alSourcePlay    := alProcedure('alSourcePlay');
    alSourcePause   :=alProcedure('alSourcePause');
    alSourceStop    := alProcedure('alSourceStop');
    alSourceRewind  := alProcedure('alSourceRewind');
    alSourcePlayv   := alProcedure('alSourcePlayv');
    alSourceStopv   := alProcedure('alSourceStopv');
    alSourceRewindv := alProcedure('alSourceRewindv');
    alSourcePausev  := alProcedure('alSourcePausev');
    alGenBuffers    := alProcedure('alGenBuffers');
    alDeleteBuffers := alProcedure('alDeleteBuffers');
    alIsBuffer      := alProcedure('alIsBuffer');
    alBufferData    := alProcedure('alBufferData');

    alBufferi  := alProcedure('alBufferi');
    alBuffer3i := alProcedure('alBuffer3i');
    alBufferiv := alProcedure('alBufferiv');

    alBufferf  := alProcedure('alBufferf');
    alBuffer3f := alProcedure('alBuffer3f');
    alBufferfv := alProcedure('alBufferfv');

    alGetBufferi  := alProcedure('alGetBufferi');
    alGetBuffer3i := alProcedure('alGetBuffer3i');
    alGetBufferiv := alProcedure('alGetBufferiv');

    alGetBufferf  := alProcedure('alGetBufferf');
    alGetBuffer3f := alProcedure('alGetBuffer3f');
    alGetBufferfv := alProcedure('alGetBufferfv');

    alSourceQueueBuffers   := alProcedure('alSourceQueueBuffers');
    alSourceUnqueueBuffers := alProcedure('alSourceUnqueueBuffers');
    alDistanceModel        := alProcedure('alDistanceModel');
    alDopplerFactor        := alProcedure('alDopplerFactor');
    alDopplerVelocity      := alProcedure('alDopplerVelocity');
    alSpeedOfSound         := alProcedure('alSpeedOfSound');

    alcCreateContext      := alProcedure('alcCreateContext');
    alcMakeContextCurrent := alProcedure('alcMakeContextCurrent');
    alcProcessContext     := alProcedure('alcProcessContext');
    alcSuspendContext     := alProcedure('alcSuspendContext');
    alcDestroyContext     := alProcedure('alcDestroyContext');
    alcGetError           := alProcedure('alcGetError');
    alcGetCurrentContext  := alProcedure('alcGetCurrentContext');
    alcOpenDevice         := alProcedure('alcOpenDevice');
    alcCloseDevice        := alProcedure('alcCloseDevice');
    alcIsExtensionPresent := alProcedure('alcIsExtensionPresent');
    alcGetProcAddress     := alProcedure('alcGetProcAddress');
    alcGetEnumValue       := alProcedure('alcGetEnumValue');
    alcGetContextsDevice  := alProcedure('alcGetContextsDevice');
    alcGetString          := alProcedure('alcGetString');
    alcGetIntegerv        := alProcedure('alcGetIntegerv');

    alcCaptureOpenDevice  := alProcedure('alcCaptureOpenDevice');
    alcCaptureCloseDevice := alProcedure('alcCaptureCloseDevice');
    alcCaptureStart       := alProcedure('alcCaptureStart');
    alcCaptureStop        := alProcedure('alcCaptureStop');
    alcCaptureSamples     := alProcedure('alcCaptureSamples');

    Result := True;
  end;
end;


procedure ReadOpenALExtensions;
begin
  if (LibHandle <> 0) then
    begin
      // EAX Extensions
      if alIsExtensionPresent('EAX2.0') then
      begin
        EAXSet := alProcedure('EAXSet');
        EAXGet := alProcedure('EAXGet');
      end;

      // EAX-RAM Extension
      if alIsExtensionPresent('EAX-RAM') then
      begin
        EAXSetBufferMode      := alGetProcAddress('EAXSetBufferMode');
    		EAXGetBufferMode      := alGetProcAddress('EAXGetBufferMode');
        AL_EAX_RAM_SIZE       := alGetEnumValue('AL_EAX_RAM_SIZE');
        AL_EAX_RAM_FREE       := alGetEnumValue('AL_EAX_RAM_FREE');
        AL_STORAGE_AUTOMATIC  := alGetEnumValue('AL_STORAGE_AUTOMATIC');
        AL_STORAGE_HARDWARE   := alGetEnumValue('AL_STORAGE_HARDWARE');
        AL_STORAGE_ACCESSIBLE := alGetEnumValue('AL_STORAGE_ACCESSIBLE');
      end;

      if alcIsExtensionPresent(alcGetContextsDevice(alcGetCurrentContext()), ALC_EXT_EFX_NAME) then
      begin
        alGenEffects                 := alGetProcAddress('alGenEffects');
		    alDeleteEffects              := alGetProcAddress('alDeleteEffects');
		    alIsEffect                   := alGetProcAddress('alIsEffect');
		    alEffecti                    := alGetProcAddress('alEffecti');
		    alEffectiv                   := alGetProcAddress('alEffectiv');
		    alEffectf                    := alGetProcAddress('alEffectf');
		    alEffectfv                   := alGetProcAddress('alEffectfv');
		    alGetEffecti                 := alGetProcAddress('alGetEffecti');
		    alGetEffectiv                := alGetProcAddress('alGetEffectiv');
		    alGetEffectf                 := alGetProcAddress('alGetEffectf');
        alGetEffectfv                := alGetProcAddress('alGetEffectfv');
        alGenFilters                 := alGetProcAddress('alGenFilters');
		    alDeleteFilters              := alGetProcAddress('alDeleteFilters');
		    alIsFilter                   := alGetProcAddress('alIsFilter');
		    alFilteri                    := alGetProcAddress('alFilteri');
		    alFilteriv                   := alGetProcAddress('alFilteriv');
		    alFilterf                    := alGetProcAddress('alFilterf');
		    alFilterfv                   := alGetProcAddress('alFilterfv');
		    alGetFilteri                 := alGetProcAddress('alGetFilteri');
		    alGetFilteriv                := alGetProcAddress('alGetFilteriv');
		    alGetFilterf                 := alGetProcAddress('alGetFilterf');
		    alGetFilterfv                := alGetProcAddress('alGetFilterfv');
		    alGenAuxiliaryEffectSlots    := alGetProcAddress('alGenAuxiliaryEffectSlots');
		    alDeleteAuxiliaryEffectSlots := alGetProcAddress('alDeleteAuxiliaryEffectSlots');
		    alIsAuxiliaryEffectSlot      := alGetProcAddress('alIsAuxiliaryEffectSlot');
		    alAuxiliaryEffectSloti       := alGetProcAddress('alAuxiliaryEffectSloti');
		    alAuxiliaryEffectSlotiv      := alGetProcAddress('alAuxiliaryEffectSlotiv');
        alAuxiliaryEffectSlotf       := alGetProcAddress('alAuxiliaryEffectSlotf');
		    alAuxiliaryEffectSlotfv      := alGetProcAddress('alAuxiliaryEffectSlotfv');
		    alGetAuxiliaryEffectSloti    := alGetProcAddress('alGetAuxiliaryEffectSloti');
		    alGetAuxiliaryEffectSlotiv   := alGetProcAddress('alGetAuxiliaryEffectSlotiv');
		    alGetAuxiliaryEffectSlotf    := alGetProcAddress('alGetAuxiliaryEffectSlotf');
		    alGetAuxiliaryEffectSlotfv   := alGetProcAddress('alGetAuxiliaryEffectSlotfv');
      end;
    end;
end;


// Internal Alut replacement procedures
procedure alutInit(argc: PALint; argv: array of PALbyte);
var
  Context: PALCcontext;
  Device:  PALCdevice;
begin
  // Open device
  Device :=  alcOpenDevice(nil); // This is supposed to select the "preferred device"
  // Create context(s)
  Context := alcCreateContext(Device, nil);
  // Set active context
  alcMakeContextCurrent(Context);
end;


procedure alutExit;
var
  Context: PALCcontext;
  Device:  PALCdevice;
begin
  // Get active context
  Context := alcGetCurrentContext;
  // Get device for active context
  Device :=  alcGetContextsDevice(Context);
  // Release context(s)
  alcDestroyContext(Context);
  // Close device
  alcCloseDevice(Device);
end;


function LoadWavStream(Stream: Tstream; var format: TALenum; var data: TALvoid; var size: TALsizei; var freq: TALsizei; var loop: TALint): Boolean;
var
  WavHeader: TWavHeader;
  readname:  PAnsiChar;
  name:      AnsiString;
  readint:   LongInt;
begin
  Result := False;
  size :=   0;
  data :=   nil;
  // Read wav header
  stream.Read(WavHeader, sizeof(TWavHeader));
  // Determine SampleRate
  freq := WavHeader.SampleRate;

  // Detemine waveformat
  if WavHeader.ChannelNumber = 1 then
    case WavHeader.BitsPerSample of
      8:  format := AL_FORMAT_MONO8;
      16: format := AL_FORMAT_MONO16;
    end;

  if WavHeader.ChannelNumber = 2 then
    case WavHeader.BitsPerSample of
      8:  format := AL_FORMAT_STEREO8;
      16: format := AL_FORMAT_STEREO16;
    end;

  // Go to end of wavheader
  stream.seek((8 - 44) + 12 + 4 + WavHeader.FormatHeaderSize + 4, soFromCurrent); //hmm crappy...
  getmem(readname, 4); //only alloc memory once, thanks to zy.

  // Loop to rest of wave file data chunks
  repeat
    // Read chunk name
    stream.Read(readname^, 4);
    name := readname[0] + readname[1] + readname[2] + readname[3];

    if name='data' then
    begin
      // Get the size of the wave data
      stream.Read(readint, 4);
      size := readint;
      // if WavHeader.BitsPerSample = 8 then size := size + 8; // fix for 8bit???
      //Read the actual wave data
      getmem(data, size);
      stream.Read(Data^, size);

      //Decode wave data if needed
      if WavHeader.FormatCode = WAV_IMA_ADPCM then
      begin
        //TODO: add code to decompress IMA ADPCM data
        raise Exception.Create('IMA ADPCM is not supported yet!');
      end;

      if WavHeader.FormatCode = WAV_MP3 then
      begin
        //TODO: add code to decompress MP3 data
        raise Exception.Create('MP3 is not supported yet!');
      end;

      Result := True;
    end else
    begin
      //Skip unknown chunk(s)
      stream.Read(readint, 4);
      stream.Position := stream.Position+readint;
    end;
  until stream.Position >= stream.size;

  freemem(readname);
  loop := 0;
end;

procedure alutLoadWAVFile(fname: string; var format: TALenum; var data: TALvoid; var size: TALsizei; var freq: TALsizei; var loop: TALint);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(fname, fmOpenRead or fmShareDenyWrite);
  LoadWavStream(Stream, format, data, size, freq, loop);
  FreeAndNil(Stream);
end;

procedure alutLoadWAVMemory(memory: PALbyte; var format: TALenum; var data: TALvoid; var size: TALsizei; var freq: TALsizei; var loop: TALint);
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  Stream.Write(memory, sizeof(memory^));
  LoadWavStream(Stream, format, data, size, freq, loop);
  FreeAndNil(Stream);
end;

procedure alutUnloadWAV(format: TALenum; data: TALvoid; size: TALsizei; freq: TALsizei);
begin
  //Clean up
  if data <> nil then freemem(data);
end;

end.
