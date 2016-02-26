unit AudioGeigers;

interface
uses
  GeigerMethods;

type
  tAudioGeiger = class(tMethodAudio)
    private
      constructor Create; override overload;
      constructor Create(aPort: String); override overload;
    protected
      // Protected stuff
    public
      // Public stuff
    published
      // Published stuff
  end;

implementation

end.
