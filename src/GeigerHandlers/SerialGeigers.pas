unit SerialGeigers;

interface
uses
  // System units
  SysUtils, Classes,
  // Custom units
  GeigerMethods;

type
  TMyGeiger = class(TMethodSerial)
    private
      // Private stuff
    protected
      // Protected stuff
    public
      constructor Create(CreateSuspended: Boolean = False); overload;
    published
      // Published stuff
  end;
implementation
constructor TMyGeiger.Create(CreateSuspended: Boolean = False);
begin
  inherited Create(CreateSuspended);
end;

end.
