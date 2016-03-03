program RadiaLog;

{
  This is the main project file of RadiaLog.
  File GUID: [E75C3601-8EAA-45FB-A3BE-77D8E3650A96]

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

uses
  // Mad except
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  // VCL
  VCL.Forms,
  VCL.Themes,
  VCL.Styles,
  // Forms
  Main in 'src\Main.pas' {mainForm},
  About in 'src\About.pas' {aboutForm},
  // Open AL
  openal in 'src\common\openal.pas',
  // Generic
  Defaults in 'src\Defaults.pas',
  ThimoUtils in 'src\common\ThimoUtils.pas',
  // Networking
  NetworkMethods in 'src\NetworkHandlers\NetworkMethods.pas',
  // Counters
  GeigerMethods in 'src\GeigerHandlers\GeigerMethods.pas',
  AudioGeigers in 'src\GeigerHandlers\AudioGeigers.pas',
  SerialGeigers in 'src\GeigerHandlers\SerialGeigers.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title             := 'RadiaLog';
  TStyleManager.TrySetStyle('Carbon');
  Application.CreateForm(TmainForm, mainForm);
  Application.CreateForm(TaboutForm, aboutForm);
  Application.Run;
end.