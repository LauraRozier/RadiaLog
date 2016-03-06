interface
{
  This is the utilities header file of RadiaLog.
  File GUID: [A6635C76-0E82-4ED2-8E57-1115E574AD48]

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

uses
  Forms, OpenAL,
  {$IFDEF MSWindows} Windows, {$ENDIF}
  {$IFDEF Unix} LCLType, {$ENDIF}
  {$IFDEF FPC} LCLIntf, UTF8Process, LazHelpHTML {$ELSE} ShellApi {$ENDIF};

function BrowseURL(const URL: string = 'http://www.thibmoprograms.com/'): Boolean;
procedure MailTo(Subject, Body: string; Address: string = 'thibmorozier@gmail.com');
{ Seems Sqr() is missing in XE8? }
{$IFDEF VER290}
function Sqr(aValue: Single): Single; overload;
function Sqr(aValue: Double): Double; overload;
function Sqr(aValue: Extended): Extended; overload;
function Sqr(aValue: Byte): Byte; overload;
function Sqr(aValue: Word): Word; overload;
function Sqr(aValue: Cardinal): Cardinal; overload;
function Sqr(aValue: Integer): Integer; overload;
function Sqr(aValue: Int64): Int64; overload;
{$ENDIF}
