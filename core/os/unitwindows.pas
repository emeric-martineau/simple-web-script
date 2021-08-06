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

{$IFDEF FPC}
    {$mode objfpc}{$H+}
{$ENDIF}

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
function SwsPathToOsPath(asPath : string) : string ;
procedure MyLoadExtension(asNameOfExt : String; var aiHandleProc : Integer; var aProc : TProcExt; var aProcResult : TProcResult; var aProcInit : TProcInit) ;
procedure MyUnLoadExtension(asNameOfExt : String) ;
procedure MygetAllEnvVar(var aoListe : Tstrings);
function AddFinalDirSeparator(asPath : String) : String ;
function MyUsageMemory : Integer ;
function MyEOL : String ;
function MyGetTmpName : String ;
function MyIsRootDirectory(asPath : String) : boolean ;
function MyOsPathToSwsPath(asPath : string) : string ;
function MyRootDirectory : string ;
function MyShellExec(asCommand : String; aiDelay : Integer) : string ;

implementation

{*****************************************************************************
 * ConProc
 * MARTINEAU Emeric
 *
 * Fonction qui gère le ctrl+c
 *****************************************************************************}
{$IFDEF FPC}
function ConProc(CtrlType : DWord) : Bool; stdcall;
{$ELSE}
function ConProc(CtrlType : DWord) : Bool; stdcall; far;
{$ENDIF}
begin
    gbQuit := True ;

    Result := False;
end;

{*****************************************************************************
 * ConProc
 * MARTINEAU Emeric
 *
 * Fonction qui install le gestionnaire de ctrl+c
 *****************************************************************************}

procedure InstallTrapOfCtrlC ;
begin
    SetConsoleCtrlHandler(@ConProc, True);
end ;

{*****************************************************************************
 * SwsPathToOsPath
 * MARTINEAU Emeric
 *
 * Convertit les chemin passer dans Sws vers un chemin lisible par l'os
 *
 * Paramètres d'entrée :
 *   - asPath : chemin à convertir
 *
 * Retour : chemin script converti en chemin pour l'OS
 *****************************************************************************}
function SwsPathToOsPath(asPath : string) : string ;
var i : Integer ;
begin
    Result := '' ;

    for i := 1 to Length(asPath) do
    begin
        if asPath[i] = '/'
        then begin
            Result := Result + '\' ;
        end
        else begin
            Result := Result + asPath[i] ;
        end ;
    end ;
end ;

{*****************************************************************************
 * MyLoadExtension
 * MARTINEAU Emeric
 *
 * Charge une DLL
 *
 * Paramètres d'entrée :
 *   - asNameOfExt : nom de l'extension,
 *
 * Paramètre de sortie :
 *   - aiHandleProc : handle windows de la DLL,
 *   - aProc : pointeur sur Execute,
 *   - aProcResult : pointe sur GetResult,
 *   - aProcInit : pointe sur Init,
 *
 * Retour : chemin script converti en chemin pour l'OS
 *****************************************************************************}
procedure MyLoadExtension(asNameOfExt : String; var aiHandleProc : Integer; var aProc : TProcExt; var aProcResult : TProcResult; var aProcInit : TProcInit) ;
var
    { Taille de asNameOfExt }
    liLength : Integer ;
    { Chaine temporaire contenant le nom de la dll à charger }
    lsTmp : String ;
    { Chaine temporaire contenant le nom de la dll à charger en chaine ASCIIZ }
    lsTmpPchar  : array of Char ;
begin
    liLength := Length(asNameOfExt) ;

    if liLength > 0
    then begin
        lsTmp := AddFinalDirSeparator(gsExtDir) ;

        lsTmp := lsTmp + asNameOfExt + '.dll' ;

        liLength := Length(lsTmp) ;

        { + 1 pour le \0 }
        SetLength(lsTmpPChar, liLength + 1) ;

        lsTmpPChar[0] := #0 ;

        StrPCopy(PCHar(lsTmpPChar), lsTmp) ;

        aiHandleProc := LoadLibrary(PChar(lsTmpPChar));

        if aiHandleProc <> 0
        then begin
            {$IFDEF FPC}
            pointer(aProc) := GetProcAddress(aiHandleProc, 'Execute') ;
            pointer(aProcResult) := GetProcAddress(aiHandleProc, 'GetResult');
            pointer(aProcInit) := GetProcAddress(aiHandleProc, 'Init') ;
            {$ELSE}
            @aProc := GetProcAddress(HandleProc, 'Execute') ;
            @aProcResult := GetProcAddress(HandleProc, 'GetResult') ;
            @aProcInit := GetProcAddress(HandleProc, 'Init') ;
            {$ENDIF}
        end
        else begin
            {$IFDEF FPC}
            pointer(aProc) := nil ;
            pointer(aProcResult) := nil ;
            pointer(aProcInit) := nil
            {$ELSE}
            @aProc := nil ;
            @aProcResult := nil ;
            @aProcInit := nil ;
            {$ENDIF}
        end ;
    end ;
end ;

{*****************************************************************************
 * MyUnLoadExtension
 * MARTINEAU Emeric
 *
 * Décharge une DLL
 *
 * Paramètres d'entrée :
 *   - asNameOfExt : nom de la DLL
 *
 *****************************************************************************}
procedure MyUnLoadExtension(asNameOfExt : String) ;
var
    { Handle de la DLL windows }
    liHandleOfExt : Integer;
    { Pointeur sur Execute. Sert uniquement pour l'appel Give }
    lProc : TProcExt ;
begin
    liHandleOfExt := -1 ;
    lProc := nil ;

    goListOfExtension.Give(asNameOfExt, liHandleOfExt, lProc) ;

    if liHandleOfExt > -1
    then begin
        FreeLibrary(liHandleOfExt) ;
    end ;

    goListOfExtension.DeleteByName(asNameOfExt) ;
end ;

{*****************************************************************************
 * MyGetAllEnvVar
 * MARTINEAU Emeric
 *
 * Liste toutes les variables d'environnement
 *
 * Paramètres d'entrée :
 *   - aoListe : liste des variable disponible
 *
 *****************************************************************************}
procedure MyGetAllEnvVar(var aoListe : Tstrings);
var
    { Pointeur du une chaine contenant les chaines et leurs valeurs }
    lpEnv: PChar;
    { Variable nom=valeur }
    lsEnv : String ;
    { Nom de la variable d'environnement }
    lsEnvName : String ;
    { Position du = }
    liPosistionEgale : Integer ;
begin
    lpEnv := GetEnvironmentStrings;

    while lpEnv^ <> #0 do
    begin
        lsEnv := StrPas(lpEnv) ;
        liPosistionEgale := pos('=', lsEnv) - 1 ;
        lsEnvName := copy(lsEnv, 1, liPosistionEgale) ;

        aoListe.Add(lsEnvName);

        Inc(lpEnv, StrLen(lpEnv) + 1);
    end;

    FreeEnvironmentStrings(lpEnv);
end ;

{*****************************************************************************
 * AddFinalDirSeparator
 * MARTINEAU Emeric
 *
 * Ajout un slash final
 *
 * Paramètres d'entrée :
 *   - asText : chaine à traiter
 *
 *****************************************************************************}
function AddFinalDirSeparator(asPath : String) : String ;
var
    { Longueur de la chaine à traiter }
    liLength : Integer ;
begin
    Result := asPath ;

    liLength := Length(asPath) ;

    if liLength > 0
    then begin
        if (asPath[liLength] <> '\')
        then begin
            Result := Result + '\' ;
        end ;
    end
    else begin
        Result := '\' ;
    end ;
end ;

{*****************************************************************************
 * MyUsageMemory
 * MARTINEAU Emeric
 *
 * Retourne la taille en octet de la mémoire utilisée
 *
 *****************************************************************************}
function MyUsageMemory : Integer ;
var
    lpProcessMemoryCounter : PROCESS_MEMORY_COUNTERS ;
    liSize : Integer ;
begin
    Result := 0 ;

    liSize := SizeOf(_PROCESS_MEMORY_COUNTERS);

    lpProcessMemoryCounter.cb := liSize;

    {$IFDEF FPC}
    if GetProcessMemoryInfo(GetCurrentProcess(), lpProcessMemoryCounter, liSize)
    {$ELSE}
    if GetProcessMemoryInfo(GetCurrentProcess(), @lpProcessMemoryCounter, liSize)
    {$ENDIF}
    then begin
        Result := lpProcessMemoryCounter.WorkingSetSize ;
    end ;
end ;

{*****************************************************************************
 * MyEOL
 * MARTINEAU Emeric
 *
 * Retourne la fin de ligne propre à chaque plateforme
 *
 *****************************************************************************}
function MyEOL : String ;
begin
    Result := #13 + #10 ;
end ;

{*****************************************************************************
 * MyGetTmpName
 * MARTINEAU Emeric
 *
 * Retourne un nom de fichier temporaire
 *
 *****************************************************************************}
function MyGetTmpName : String ;
var Name : Array[0..MAX_PATH] Of Char ;
begin
    if (GetTempFileName(PChar(gsTmpDir), 'tmp', 0, @Name) = 0)
    then begin
        Result := ''
    end
    else begin
        Result := String(Name) ;
    end ;
end;

{*****************************************************************************
 * MyIsRootDirectory
 * MARTINEAU Emeric
 *
 * Retourne true si le chemin représente la racine
 *
 * Paramètres d'entrée :
 *   - asPath : chaine représentant un chemin
 *
 *****************************************************************************}
function MyIsRootDirectory(asPath : String) : boolean ;
begin
    Result := False ;

    if Length(asPath) > 1
    then begin
        if asPath[2] = ':'
        then begin
            Result := True ;
        end ;
    end ;
end ;

{*****************************************************************************
 * MyOsPathToSwsPath
 * MARTINEAU Emeric
 *
 * Convertit les chemin passer par l'os en chemin sws
 *
 * Paramètres d'entrée :
 *   - asPath : chaine représentant un chemin
 *
 *****************************************************************************}
function MyOsPathToSwsPath(asPath : string) : string ;
var i : Integer ;
begin
    Result := '' ;

    for i := 1 to Length(asPath) do
    begin
        if asPath[i] = '\'
        then begin
            Result := Result + '/' ;
        end
        else begin
            Result := Result + asPath[i] ;
        end ;
    end ;
end ;

{*****************************************************************************
 * MyRootDirectory
 * MARTINEAU Emeric
 *
 * Renvoie la racine. Si Unix renvoie /
 *
 *****************************************************************************}
function MyRootDirectory : string ;
begin
    Result := '' ;
end ;

{*****************************************************************************
 * MyShellExec
 * MARTINEAU Emeric
 *
 * Execute une commande
 *
 * Paramètres d'entrée :
 *   - asCommand : commande à exécuter,
 *   - aiDelay : temps maximal d'exécution
 *
 *****************************************************************************}
function MyShellExec(asCommand : String; aiDelay : Integer) : string ;
const
    { Taille du buffer de lecture du périphérique standard de sortie }
    ciReadBufferSize = 512 ;
var
    { Paramètre les paramètre de sécurité du programme à exécuter }
    lSecurity : TSecurityAttributes ;
    { Handle de lecture }
    lReadPipe : THandle ;
    { Handle d'écriture }
    lWritePipe : THandle ;
    { Information de démarage du programme à exécuter  }
    lStartUpInfo : TStartUpInfo ;
    { Information sur le programme à exécuter }
    lProcessInfo : TProcessInformation ;
    { Buffer de lecture }
    lpBuffer : Pchar ;
    { Nombre d'octet lu dans le périphérique standard de sortie du programme à exécuter}
    liBytesRead : DWord ;
    { Compteur pour recopie du buffer }
    liIndexBuffer : Integer ;
begin
    Result := '' ;

    lSecurity.nlength := SizeOf(TSecurityAttributes) ;
    lSecurity.binherithandle := true;
    lSecurity.lpsecuritydescriptor := nil;

    lReadPipe := 0 ;
    lWritePipe := 0 ;

    if Createpipe(lReadPipe, lWritePipe, @lSecurity, 0)
    then begin
        lpBuffer := AllocMem(ciReadBufferSize) ;
        FillChar(lStartUpInfo, Sizeof(lStartUpInfo), #0) ;
        FillChar(lProcessInfo, SizeOf(lProcessInfo), #0) ;

        lStartUpInfo.cb := SizeOf(lStartUpInfo) ;
        lStartUpInfo.hStdOutput := lWritePipe;
        lStartUpInfo.hStdInput := lReadPipe;
        // Indique que les membres input et output sont renseigné et que
        // le paramètre showwindows aussi
        lStartUpInfo.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
        lStartUpInfo.wShowWindow := SW_HIDE;

        if CreateProcess(
           // Application premier élément de DosApp
           nil,
           // Ligne de commande de DosApp
           PChar(asCommand),
           // Attribut de sécurité du processus
           @lSecurity,
           // Attribut de sécurité des threads
           @lSecurity,
           // Hérite des handle
           true,
           // flag de création : Priorité
           NORMAL_PRIORITY_CLASS,
           // Environnement
           nil,
           // Répertoire courant
           nil,
           // info de démarrage
           lStartUpInfo,
           // info du processus
           lProcessInfo)
        then begin
            WaitForSingleObject(lProcessInfo.hProcess, aiDelay) ;
            
            TerminateProcess(lProcessInfo.hProcess, 0) ;

            Repeat
                liBytesRead := 0;
                ReadFile(lReadPipe, lpBuffer[0], ciReadBufferSize, liBytesRead, nil) ;

                // ajouter un #0 à la fin pour que ça fonctionne
                //OemToChar(Buffer, Buffer)

                for liIndexBuffer := 0 to liBytesRead - 1 do
                begin
                    Result := Result + lpBuffer[liIndexBuffer] ;
                end ;
            until (liBytesRead < ciReadBufferSize) ;
        end;

        FreeMem(lpBuffer) ;

        CloseHandle(lProcessInfo.hProcess) ;
        CloseHandle(lProcessInfo.hThread) ;
        CloseHandle(lReadPipe) ;
        CloseHandle(lWritePipe) ;
    end;
end;
end.
