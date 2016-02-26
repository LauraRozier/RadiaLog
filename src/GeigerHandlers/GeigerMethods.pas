unit GeigerMethods;

interface
uses
  OpenAL;

type
  tMethodSerial = class
    private
      // Private stuff
    protected
      // Protected stuff
    public
      // Public stuff
    published
      // Published stuff
  end;

  tMethodAudio = class(TObject)
    private
      fALDevice, fALCaptureDevice: PALCdevice;
      fIsSoundInitialized: Boolean;
    protected
      // Protected stuff
    public
      constructor Create(aPort: String);
      destructor Destroy;
    published
      property Initialized: Boolean Read fIsSoundInitialized;
  end;

implementation
constructor tMethodAudio.Create(aPort: String);
begin
  fIsSoundInitialized := InitOpenAL;
  Set8087CW($133F);
end;


destructor tMethodAudio.Destroy;
begin
  //alcCloseDevice(fALCaptureDevice);
  //alcCloseDevice(fALDevice);
  AlutExit;
end;

end.
