library exemple;

{$IFDEF FPC}
    {$mode objfpc}{$H+}
{$ENDIF}

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
 ******************************************************************************}

uses
  SysUtils,
  Classes,
  Windows;

type
    PBoolean = ^Boolean ;

Var ResultFunction : String ;
    TmpDir : String ;
    DocRoot : String ;
    SafeMode : boolean ;
{$R *.res}

procedure GetParameters(Params : TStrings; Parameters : PChar) ;
var i : Integer ;
    tmp : String ;
begin
    i := 0 ;
    tmp := '' ;

    repeat
        if Parameters[i] <> #0
        then begin
            while Parameters[i] <> #0 do
            begin
                tmp := tmp + Parameters[i] ;
                Inc(i) ;
            end ;

            Params.Add(tmp) ;
            tmp := '' ;

            { Saute le \0 terminant la chaine }
            Inc(i) ;
        end ;
    until Parameters[i] = #0 ;
end ;

{*******************************************************************************
 * Function call when sws load extension
 ******************************************************************************}
procedure Load ; stdcall;
begin
end;

{*******************************************************************************
 * Function call when dll sws unload extension
 ******************************************************************************}
procedure UnLoad ; stdcall;
begin
    SetLength(ResultFunction, 0) ;
end;


{*******************************************************************************
 * Function call command
 *
 *     Commande : is command to execute (readonly)
 *     Parameters : is param1\0Param2\0\0 (readonly)
 *     Scriptname : is name of current script (readonly)
 *     VersionOfSws : version on simple web script (readonly)
 *     Line : line in file (readonly)
 *     ResultFunction : result of commande (writeonly)
 ******************************************************************************}
function Execute(Commande : PChar; Parameters : PChar; scriptname : PChar; versionofsws : PChar; line : Integer; GlobalError : PBoolean) : boolean ; stdcall; export;
var Params : TStrings ;
    i : Integer ;
begin
    Params := TStringList.Create ;

    GetParameters(Params, Parameters) ;

    Result := False ;
    
    if Commande = 'essai_extension'
    then begin
        writeln('Hello from library !') ;
		writeln('arguments : ') ;

		for i := 0 to Params.Count - 1 do
		begin
		    writeln(' ' + Params[i]) ;
		end ;

        writeln('') ;

        writeln('SWS version : ' + String(versionofsws)) ;
        writeln('Script name: ' + String(scriptname)) ;
        writeln('Line : ' + IntToStr(line + 1)) ;
        writeln('DocRoot : ' + DocRoot) ;
        writeln('TmpDir : ' + TmpDir) ;

        write('SafeMode ') ;

        if SafeMode
        then
            writeln('on')
        else
            writeln('off') ;

        ResultFunction := #0 + #1 + #2 + #3 ; //'Truc' ;

        Result := True ;
    end
    else if Commande = 'essai_extension_error'
    then begin
        GlobalError^ := True ;

        Result := True ;
    end ;

    Params.Free ;
end;

{*******************************************************************************
 * Get pointer of result
 ******************************************************************************}
function GetResult(Resultat : pointer) : Integer ; stdcall; export ;
var i : Integer ;
begin
    Result := Length(ResultFunction) ;

    if (Resultat <> nil)
    then begin
        writeln('Result=' + ResultFunction) ;
        writeln(Format('Pointer=%p', [Resultat])) ;
        writeln('len=' + IntToStr(Result)) ;

        for i := 0 to Result do
        begin
            PChar(Resultat)[i] := ResultFunction[i+1] ;
        end ;
    end ;
end ;

{*******************************************************************************
 * Fonction cr�ant un espace m�moire partag�
 ******************************************************************************}
procedure LibraryProc(AReason : Integer) ;
begin
    case AReason of
        DLL_PROCESS_ATTACH : Load ;
        DLL_PROCESS_DETACH : UnLoad ;
        DLL_THREAD_ATTACH : ;
        DLL_THREAD_DETACH : ;
    end;
end;

{*******************************************************************************
 * Fonction d'initialisation
 ******************************************************************************}
procedure Init(InitDocRoot : PChar; InitTmpDir : PChar; InitSafeMode : Boolean) ; stdcall ; export ;
begin
    SafeMode := InitSafeMode ;
    DocRoot := Copy(String(InitDocRoot), 1, StrLen(InitDocRoot)) ;
    TmpDir := Copy(String(InitTmpDir), 1, StrLen(InitTmpDir)) ;    
end ;

{*******************************************************************************
 * Begin of DLL
 ******************************************************************************}
exports
    Execute,
    GetResult,
    Init ;

begin
{ pour lazarus
BOOL WINAPI DllEntryPoint(

    HINSTANCE hinstDLL,      -> GetModuleHandle(0)


// handle to DLL module

    DWORD fdwReason,


// reason for calling function

    LPVOID lpvReserved


// reserved

   );
}
  DllProc := @LibraryProc ;
  LibraryProc(DLL_PROCESS_ATTACH) ;
end.
