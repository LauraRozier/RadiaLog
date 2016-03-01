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
  SAMPLES_PER_SECOND = 20;
  TIMESPAN_SECONDS = 30;
  THRESHOLD_DIV = 100000;
  GEIGER_RUN_TIME = TIMESPAN_SECONDS * SAMPLES_PER_SECOND;
  GEIGER_SAMPLE_RATE = 22050;
  GEIGER_ALPHA_NUM = 0.4;
  GEIGER_CHANNELS = 2;
  // Frequency * Channels (Per full second) + Slack-space
  GEIGER_BUFFER_SIZE = ((GEIGER_SAMPLE_RATE * GEIGER_CHANNELS) Div SAMPLES_PER_SECOND) + 50;

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
