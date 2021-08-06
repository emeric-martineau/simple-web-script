unit UnitWindows;
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
 * Containt specific code of Windows plateform
 ******************************************************************************}

interface

{$I config.inc}

uses Code, Windows, SysUtils, Extension, Classes
     {$IFNDEF FPC}
     , psApi
     {$ELSE}
     , jwapsapi
     {$ENDIF}
     ;

{$IFDEF FPC}
function ConProc(CtrlType : DWord) : Bool; stdcall;
{$ELSE}
function ConProc(CtrlType : DWord) : Bool; stdcall; far;
{$ENDIF}
procedure InstallTrapOfCtrlC ;
function SwsPathToOsPath(path : string) : string ;
procedure MyLoadExtension(NameOfExt : String; var HandleProc : Integer; var proc : TProcExt; var procresult : TProcResult; var procinit : TProcInit) ;
procedure MyUnLoadExtension(NameOfExt : String) ;
procedure MygetAllEnvVar(var Liste : Tstrings);
function AddFinalDirSeparator(Text : String) : String ;
function MyUsageMemory : Integer ;
function MyEOL : String ;
function MyGetTmpName : String ;
function MyIsRootDirectory(Chemin : String) : boolean ;
function MyOsPathToSwsPath(path : string) : string ;
function MyRootDirectory : string ;
function MyShellExec(cmd:String; Delay : Integer) : string ;

implementation

{*******************************************************************************
 * Fonction qui gère le ctrl+c
 ******************************************************************************}
{$IFDEF FPC}
function ConProc(CtrlType : DWord) : Bool; stdcall;
{$ELSE}
function ConProc(CtrlType : DWord) : Bool; stdcall; far;
{$ENDIF}
begin
    GlobalError := True ;

    Result := False;
end;

{*******************************************************************************
 * Fonction qui install le gestionnaire de ctrl+c
 ******************************************************************************}
procedure InstallTrapOfCtrlC ;
begin
    SetConsoleCtrlHandler(@ConProc, True);
end ;

{*******************************************************************************
 * Convertit les chemin passer dans Sws vers un chemin lisible par l'os
 ******************************************************************************}
function SwsPathToOsPath(path : string) : string ;
var i : Integer ;
begin
    Result := '' ;

    for i := 1 to Length(path) do
    begin
        if path[i] = '/'
        then
            Result := Result + '\'
        else
            Result := Result + path[i] ;
    end ;
end ;

{*******************************************************************************
 * Charge une DLL
 ******************************************************************************}
procedure MyLoadExtension(NameOfExt : String; var HandleProc : Integer; var proc : TProcExt; var procresult : TProcResult; var procinit : TProcInit) ;
var nb : Integer ;
    tmp : String ;
    tmpPchar  : array of Char ;
begin
    nb := Length(NameOfExt) ;

    if nb > 0
    then begin
        tmp := AddFinalDirSeparator(ExtDir) ;

        tmp := tmp + NameOfExt + '.dll' ;

        nb := Length(tmp) ;

        { + 1 pour le \0 }
        SetLength(tmpPChar, nb + 1) ;

        tmpPChar[0] := #0 ;

        StrPCopy(PCHar(tmpPChar), tmp) ;

        HandleProc := LoadLibrary(PChar(tmpPChar));

        if HandleProc <> 0
        then begin
            {$IFDEF FPC}
            pointer(proc) := GetProcAddress(HandleProc, 'Execute') ;
            pointer(procresult) := GetProcAddress(HandleProc, 'GetResult');
            pointer(procinit) := GetProcAddress(HandleProc, 'Init') ;
            {$ELSE}
            @proc := GetProcAddress(HandleProc, 'Execute') ;
            @procresult := GetProcAddress(HandleProc, 'GetResult') ;
            @procinit := GetProcAddress(HandleProc, 'Init') ;
            {$ENDIF}
        end
        else begin
            {$IFDEF FPC}
            pointer(proc) := nil ;
            pointer(procresult) := nil ;
            pointer(procinit) := nil
            {$ELSE}
            @proc := nil ;
            @procresult := nil ;
            @procinit := nil ;
            {$ENDIF}
        end ;
    end ;
end ;

{*******************************************************************************
 * Décharge une DLL
 ******************************************************************************}
procedure MyUnLoadExtension(NameOfExt : String) ;
var HandleOfExt : Integer;
    proc : TProcExt ;
begin
    HandleOfExt := -1 ;
    proc := nil ;

    ListOfExtension.Give(NameOfExt, HandleOfExt, proc) ;

    if HandleOfExt > -1
    then
        FreeLibrary(HandleOfExt);

    ListOfExtension.DeleteByName(NameOfExt) ;
end ;

{*******************************************************************************
 * Liste toutes les variables d'environnement
 ******************************************************************************}
procedure MygetAllEnvVar(var Liste : Tstrings);
var
  Env: PChar;
  tmp : String ;
  i : Integer ;
begin
  Env := GetEnvironmentStrings;

  while Env^ <> #0 do
  begin
    tmp := StrPas(Env) ;
    i := pos('=', tmp) - 1 ;
    tmp := copy(tmp, 1, i) ;

    Liste.Add(tmp);

    Inc(Env, StrLen(Env) + 1);
  end;

  FreeEnvironmentStrings(Env);
end ;

{*******************************************************************************
 * Ajout un slash final
 ******************************************************************************}
function AddFinalDirSeparator(Text : String) : String ;
var len : Integer ;
begin
    Result := Text ;

    len := Length(Text) ;

    if len > 0
    then begin
        if (Text[len] <> '\')
        then
            Result := Result + '\' ;
    end
    else
        Result := '\' ;
end ;

{*******************************************************************************
 * Retourne la taille en octet de la mémoire utilisée
 ******************************************************************************}
function MyUsageMemory : Integer ;
var
    process_memory_counter : PROCESS_MEMORY_COUNTERS ;
    size : Integer ;
begin
    Result := 0 ;

    size := SizeOf(_PROCESS_MEMORY_COUNTERS);

    process_memory_counter.cb := size;

    {$IFDEF FPC}
    if GetProcessMemoryInfo(GetCurrentProcess(), process_memory_counter, size)
    {$ELSE}
    if GetProcessMemoryInfo(GetCurrentProcess(), @process_memory_counter, size)
    {$ENDIF}
    then
        Result := process_memory_counter.WorkingSetSize ;

end ;

{*******************************************************************************
 * Retourne la fin de ligne propre à chaque plateforme
 ******************************************************************************}
function MyEOL : String ;
begin
    Result := #13 + #10 ;
end ;

{*******************************************************************************
 * Retourne un nom de fichier temporaire
 ******************************************************************************}
function MyGetTmpName : String ;
var Name : Array[0..MAX_PATH] Of Char ;
begin
     if (GetTempFileName(PChar(tmpDir), 'tmp', 0, @Name) = 0)
     then
         Result := ''
     else
         Result := String(Name) ;
end;

{*******************************************************************************
 * Retourne true si le chemin représente la racine
 ******************************************************************************}
function MyIsRootDirectory(Chemin : String) : boolean ;
begin
    Result := False ;

    if Length(Chemin) > 1
    then begin
        if Chemin[2] = ':'
        then
            Result := True ;
    end ;
end ;

{*******************************************************************************
 * Convertit les chemin passer par l'os en chemin sws
 ******************************************************************************}
function MyOsPathToSwsPath(path : string) : string ;
var i : Integer ;
begin
    Result := '' ;

    for i := 1 to Length(path) do
    begin
        if path[i] = '\'
        then
            Result := Result + '/'
        else
            Result := Result + path[i] ;
    end ;
end ;

{*******************************************************************************
 * Renvoie la racine. Si Unix renvoie /
 ******************************************************************************}
function MyRootDirectory : string ;
begin
    Result := '' ;
end ;

{*******************************************************************************
 * Execute une commande
 ******************************************************************************}
function MyShellExec(cmd:String; Delay : Integer) : string ;
const
     ReadBuffer = 512;
var
    Security : TSecurityAttributes;
    ReadPipe,WritePipe : THandle;
    start : TStartUpInfo;
    ProcessInfo : TProcessInformation;
    Buffer : Pchar;
    BytesRead : DWord;
    i : Integer ;
begin
    Result := '' ;

    Security.nlength := SizeOf(TSecurityAttributes) ;
    Security.binherithandle := true;
    Security.lpsecuritydescriptor := nil;

    ReadPipe := 0 ;
    WritePipe := 0 ;

    if Createpipe(ReadPipe, WritePipe, @Security, 0)
    then begin
        Buffer := AllocMem(ReadBuffer) ;
        FillChar(Start, Sizeof(Start), #0) ;
        FillChar(ProcessInfo, SizeOf(ProcessInfo), #0) ;

        start.cb := SizeOf(start) ;
        start.hStdOutput := WritePipe;
        start.hStdInput := ReadPipe;
        // Indique que les membres input et output sont renseigné et que
        // le paramètre showwindows aussi
        start.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
        start.wShowWindow := SW_HIDE;

        if CreateProcess(
           // Application premier élément de DosApp
           nil,
           // Ligne de commande de DosApp
           PChar(cmd),
           // Attribut de sécurité du processus
           @Security,
           // Attribut de sécurité des threads
           @Security,
           // Hérite des handle
           true,
           // flag de création : Priorité
           NORMAL_PRIORITY_CLASS,
           // Environnement
           nil,
           // Répertoire courant
           nil,
           // info de démarrage
           start,
           // info du processus
           ProcessInfo)
        then begin
            WaitForSingleObject(ProcessInfo.hProcess,Delay) ;
            
            TerminateProcess(ProcessInfo.hProcess, 0) ;

            Repeat
                BytesRead := 0;
                ReadFile(ReadPipe, Buffer[0], ReadBuffer, BytesRead, nil) ;

                // ajouter un #0 à la fin pour que ça fonctionne
                //OemToChar(Buffer, Buffer)

                for i := 0 to BytesRead - 1 do
                begin
                    Result := Result + Buffer[i] ;
                end ;
            until (BytesRead < ReadBuffer) ;
        end;

        FreeMem(Buffer) ;

        CloseHandle(ProcessInfo.hProcess) ;
        CloseHandle(ProcessInfo.hThread) ;
        CloseHandle(ReadPipe) ;
        CloseHandle(WritePipe) ;
    end;
end;
end.
