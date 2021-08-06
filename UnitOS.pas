unit UnitOS;
{*******************************************************************************
 * Copyright (C) 2007 MARTINEAU Emeric (php4php@free.fr)
 *
 * Simple Web Script
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation; either version 2 of the License, or (at your option) any later
 * version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
 * Place, Suite 330, Boston, MA 02111-1307 USA
 *
 *******************************************************************************
 * Abstract OS Layer
 ******************************************************************************}

interface

{$I config.inc}

uses Extension, Classes ;

function OsSwsPathToOsPath(path : string) : string ;
procedure OsLoadExtension(NameOfExt : String; var HandleProc : Integer; var proc : TProcExt; var procresult : TProcResult; var procinit : TProcInit) ;
procedure OsUnLoadExtension(NameOfExt : String) ;
procedure OsInstallTrapOfCtrlC ;
procedure OsgetAllEnvVar(var Liste : TStrings) ;
function OSAddFinalDirSeparator(Text : String) : String ;
function OSUsageMemory : Integer ;
function OsEOL : String ;
function OsGetTmpFileName : String ;
function OsIsRootDirectory(Chemin : String) : boolean ;
function OSOsPathToSwsPath(path : string) : string ;
function OsRootDirectory : string ;
function OsShellExec(cmd : String; Delay : Integer) : String ;

implementation

uses
  Code,
  {$IFDEF WINDOWS}
  UnitWindows
  {$ENDIF}
  ;

procedure OsInstallTrapOfCtrlC ;
begin
    InstallTrapOfCtrlC
end ;

function OSSwsPathToOsPath(path : string) : string ;
begin
    Result := SwsPathToOsPath(path) ;
end ;

procedure OsLoadExtension(NameOfExt : String; var HandleProc : Integer; var proc : TProcExt; var procresult : TProcResult; var procinit : TProcInit) ;
begin
    MyLoadExtension(NameOfExt, HandleProc, proc, procresult, procinit) ;
end ;

procedure OsUnLoadExtension(NameOfExt : String) ;
begin
    MyUnLoadExtension(NameOfExt) ;
end ;

procedure OSgetAllEnvVar(var Liste : TStrings) ;
begin
    Liste.Clear ;
    MygetAllEnvVar(Liste) ;
end ;

function OSAddFinalDirSeparator(Text : String) : String ;
begin
    Result := AddFinalDirSeparator(Text) ;
end ;

function OSUsageMemory : Integer ;
begin
    Result := MyUsageMemory ;
end ;

function OsEOL : String ;
begin
    Result := MyEOL ;
end ;

function OsGetTmpFileName : String ;
begin
    Result := MyGetTmpName ;
end ;

function OsIsRootDirectory(Chemin : String) : boolean ;
begin
    Result := MyIsRootDirectory(Chemin) ;
end ;

function OSOsPathToSwsPath(path : string) : string ;
begin
    Result := MyOsPathToSwsPath(path) ;
end ;

function OsRootDirectory : string ;
begin
    Result := MyRootDirectory ;
end ;

function OsShellExec(cmd : String; Delay : Integer) : String ;
begin
    Result := MyShellExec(cmd, Delay) ;
end ;

end.
