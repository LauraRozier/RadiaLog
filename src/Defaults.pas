unit Defaults;

{
  This is the defaults unit file of RadiaLog.
  File GUID: [59CB718E-B0E2-4A4D-B723-FE164D7D9023]

  Contributor(s):
    Thimo Braker (thibmorozier@gmail.com)

  Copyright (C) 2016 Thimo Braker thibmorozier@gmail.com

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  MA 02111-1307, USA.
}

interface
uses
  // System units
  Generics.Collections;

const
  VERSION = '0.5';
  VERSION_PREFIX = '- Version: ';
  VERSION_SUFFIX = ' Alpha';
  RADMON_HOST = 'www.radmon.org';
  PLOTCAP = 100;
  SVTOR = 0.0100718499998148;
  SAMPLES_PER_SECOND = 10; // 10 seems to be the safe max.
  TIMESPAN_SECONDS = 30;
  THRESHOLD_DIV = 100000;
  GEIGER_RUN_TIME = TIMESPAN_SECONDS * SAMPLES_PER_SECOND;
  THREAD_WAIT_TIME = 1000 Div SAMPLES_PER_SECOND; // 1 second divided by samples per second
  GEIGER_SAMPLE_RATE = 22050;
  GEIGER_CHANNELS = 2;
  // Frequency * Channels (Per full second) + Slack-space
  GEIGER_BUFFER_SIZE = ((GEIGER_SAMPLE_RATE * GEIGER_CHANNELS) Div SAMPLES_PER_SECOND) + 50;
  DEBUG_AUDIO = True;

type
  TChartData = record
    value:    Integer;
    dateTime: TDateTime;
  end;

var
  exeDir:               UnicodeString;
  fUsername, fPassword: string;
  fPlotPointList:       TList<TChartData>;

implementation

end.
