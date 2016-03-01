unit Defaults;

interface
uses
  Windows, Classes, SysUtils, Variants, Vcl.Forms;

const
  VERSION = '0.5';
  VERSION_PREFIX = '- Version: ';
  VERSION_SUFFIX = ' Alpha';
  RADMON_HOST = 'www.radmon.org';
  PLOTCAP = 100;
  SVTOR = 0.0100718499998148;

var
  exeDir: UnicodeString;
  fUsername, fPassword: string;

type
  TChartData = record
    value: Integer;
    dateTime: TDateTime;
  end;

implementation

end.
