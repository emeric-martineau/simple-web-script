program SimpleWebScript;
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
 ******************************************************************************
 *
 * Variables names :
 *  xyZZZZZ :
 *            x : l : local variable
 *                g : global variable/public variable
 *                p : private/protected variable
 *                a : argument variable
 *
 *            y : s : string
 *                i : integer
 *                f : fload
 *                d : double
 *                a : array
 *                l : list<>
 *                o : object
 *                b : bool
 *                c : char
 *                l : long
 *
 *           ZZZZ : name of variable
 *******************************************************************************
 * Main program. It check argument and lauch execute of code
 ******************************************************************************}

{$IFNDEF FPC}
    {$APPTYPE CONSOLE}
{$ELSE}
    {$mode objfpc}{$H+}
{$ENDIF}

uses
  SysUtils,
  Classes,
  Windows,
  DoubleStrings,
  Functions,
  Code,
  Variable,
  UserFunction,
  UserLabel,
  UnitCore,
  InternalFunction,
  ListPointerOfTVariables,
  Extension,
  UnitMessages,
  UnitStr,
  UnitUrl,
  UnitMath,
  UnitMiscellaneous,
  GetPostCookieFileData,
  UnitOS,
  IniFiles,
  UnitHtml,
  Constantes;

{$I config.inc}

{$I path_ini.inc}

var
    lsFileName : string ;
    loEndCondition : TStringList ;
    lsCheminIni : String ;
    {$IFNDEF COMMANDLINE}
    loFichierIni : TIniFile ;
    {$ENDIF}
    lsDefaultType : String ;
    loListDisabledFunctions : TStringList ;
    liIndex : Integer ;
    {$IFDEF COMMANDLINE}
    liArguments : Integer ;
    {$ENDIF}
begin
//    FileMode := fmOpenWrite ;
//    AssignFile(OutPut, 'debug.log') ;
//    Rewrite(OutPut) ;

    lsFileName := '' ;
    gbIsHeaderSend := False ;
    gbIsOriginalHeaderClear := False ;
    gbWarning := True ;
    Header := TStringList.Create ;
    giLineWhereHeaderSend := 0 ;
    gbIsOutPuBuffered := False ;

    { Force les date en anglais }
    setShortDayName ;
    setLongDayName ;
    setShortMonthName ;
    setLongMonthName ;

    { D�finit les dates/mois du script par d�faut }
    gaUserShortDayNames[1] := 'Sun' ;
    gaUserShortDayNames[2] := 'Mon' ;
    gaUserShortDayNames[3] := 'Tue' ;
    gaUserShortDayNames[4] := 'Wed' ;
    gaUserShortDayNames[5] := 'Thu' ;
    gaUserShortDayNames[6] := 'Fri' ;
    gaUserShortDayNames[7] := 'Sat' ;

    gaUserShortMonthNames[1] := 'Jan' ;
    gaUserShortMonthNames[2] := 'Feb' ;
    gaUserShortMonthNames[3] := 'Mar' ;
    gaUserShortMonthNames[4] := 'Apr' ;
    gaUserShortMonthNames[5] := 'May' ;
    gaUserShortMonthNames[6] := 'Jun' ;
    gaUserShortMonthNames[7] := 'Jul' ;
    gaUserShortMonthNames[8] := 'Aug' ;
    gaUserShortMonthNames[9] := 'Sep' ;
    gaUserShortMonthNames[10] := 'Oct' ;
    gaUserShortMonthNames[11] := 'Nov' ;
    gaUserShortMonthNames[12] := 'Dec' ;

    DateSeparator := '/' ;
    TimeSeparator := ':' ;

    gsFloatSeparator := '.' ;
    gsMillierSeparator := ',' ;

    gsDefaultCharset := 'iso-8859-1' ;

    {$IFNDEF COMMANDLINE}
    if (IniPath = '')
    then begin
        lsCheminIni := ExtractFileDir(ParamStr(0)) ;
    end
    else begin
        lsCheminIni := IniPath ;
    end ;
    {$ELSE}
    lsCheminIni := ExtractFileDir(ParamStr(0)) ;
    {$ENDIF}

    {$IFDEF COMMANDLINE}
    gsDocRoot := GetCurrentDir ;
    
    giMaxMemorySize :=  -1;

    lsDefaultType := 'text/html' ;

    gsDisabledFunctions := '' ;

    giMaxPostSize := 2 ;

    gsExtDir := OSAddFinalDirSeparator('ext') ;

    gsTmpDir := '' ;

    gbHideCfg := true ;

    gbFileUpload := true ;

    giUploadMaxFilesize := 2 ;

    gbSafeMode := false ;
    
    giElapseTime := -1 ;
    {$ELSE}
    lsCheminIni := OsAddFinalDirSeparator(lsCheminIni)  ;

    loFichierIni := TIniFile.Create(lsCheminIni + 'sws.ini') ;

    gsDocRoot := OsAddFinalDirSeparator(RealPath(loFichierIni.ReadString('general', 'doc_root', ''))) ;

    if gsDocRoot = ''
    then begin
        gsDocRoot := GetCurrentDir ;
    end ;

    giElapseTime := loFichierIni.ReadInteger('general', 'max_execution_time', 30) ;

    { On ajoute la taille avant lecture du script pour allou� exactement la taille souhait�e au script }
    giMaxMemorySize := (loFichierIni.ReadInteger('general', 'memory_limit', 8) * 1024 * 1024) + OSUsageMemory;

    lsDefaultType := loFichierIni.ReadString('general', 'default_type', 'text/html') ;

    gsDisabledFunctions := loFichierIni.ReadString('general', 'disabled_function', '') ;

    giMaxPostSize := loFichierIni.ReadInteger('general', 'post_max_size', 2) ;

    gsExtDir := OSAddFinalDirSeparator(RealPath(loFichierIni.ReadString('general', 'ext_path', ''))) ;

    gsTmpDir := OSAddFinalDirSeparator(RealPath(loFichierIni.ReadString('general', 'tmp_dir', ''))) ;

    gbHideCfg := (loFichierIni.ReadString('general', 'hide_cfg', 'true') = 'true') ;

    gbFileUpload := (loFichierIni.ReadString('general', 'file_uploads', 'true') = 'true') ;

    giUploadMaxFilesize := loFichierIni.ReadInteger('general', 'upload_max_filesize', 2) ;

    gbSafeMode := (loFichierIni.ReadString('general', 'safe_mode', 'true') = 'true') ;

    loFichierIni.Free ;
    {$ENDIF}
    
    {$IFDEF COMMANDLINE}
    gbDebug := False ;
    liArguments := ParamCount ;

    if ParamCount > 0
    then begin
        liIndex := 1 ;

        while liIndex <= ParamCount do
        begin
            if ParamStr(liIndex) = '-debug'
            then begin
                gbDebug := True ;
            end
            else if ParamStr(liIndex) = '-params'
            then begin
                liArguments := liIndex ;
                break ;
            end
            else if ParamStr(liIndex) = '-file'
            then begin
                lsFileName := ParamStr(liIndex + 1) ;
                Inc(liIndex) ;
            end ;

            Inc(liIndex) ;
        end ;
    end ;
    {$ELSE}
    Header.Add('Content-Type: ' + lsDefaultType) ;
    Header.Add('') ;
    {$ENDIF}

    goVariables := TVariables.Create ;

    {$IFNDEF COMMANDLINE}
    goVarGetPostCookieFileData := TGetPostCookieFileData.Create(giMaxPostSize * 1024 * 1024, giUploadMaxFilesize * 1024 * 1024, gbFileUpload) ;
    {$ELSE}
    goVarGetPostCookieFileData := TGetPostCookieFileData.Create() ;
    {$ENDIF}

    {$IFNDEF COMMANDLINE}
    lsFileName := goVarGetPostCookieFileData.getFileNameOfScript ;
    {$ENDIF}

    if lsFileName = ''
    then begin
        {$IFDEF COMMANDLINE}
        Writeln(ExtractFileName(ParamStr(0)) + ' name_of_file') ;
        {$ELSE}
        OutPutString(csNoFileInput, false) ;
        {$ENDIF}
    end
    else begin
        OsInstallTrapOfCtrlC ;

        goCodeList := TStringList.Create ;

        goListOfFile := TStringList.Create ;
        goLineToFileLine := TStringList.Create ;
        goLineToFile := TStringList.Create ;
        goInternalFunction := TInternalFunction.Create ;
        goPointerOfVariables := TPointerOfTVariable.Create ;
        goListOfExtension := TExtension.Create ;
        goCurrentRootOfFile := TStringList.Create ;
        goConstantes := TDoubleStrings.Create;
        
        goConstantes.Add('#_version', csVersion) ;

        goCurrentFunctionName := TStringList.Create ;
        goCurrentFunctionName.Add('main script') ;

        goFirstVariables := goVariables ;

        goListLabel := TUserLabel.Create ;
        goListProcedure := TUserFunction.Create ;

        CoreFunctionsInit ;
        StrFunctionsInit ;
        UrlFunctionsInit ;
        MathFunctionsInit ;
        MiscellaneousFunctionsInit ;
        HtmlFunctionsInit ;

        if gsDisabledFunctions <> ''
        then begin
            loListDisabledFunctions := TStringList.Create ;

            Explode(gsDisabledFunctions, loListDisabledFunctions, ',') ;

            for liIndex := 0 to loListDisabledFunctions.count - 1 do
            begin
                {$IFNDEF FPC}
                goInternalFunction.Change(loListDisabledFunctions[liIndex], FunctionDisabled, false);
                {$ELSE}
                goInternalFunction.Change(loListDisabledFunctions[liIndex], @FunctionDisabled, false);
                {$ENDIF}
            end ;

            loListDisabledFunctions.Free ;
        end ;

        { Initialise l'heure de d�but du script }
        goStartTime := Now ;

        gbLabelReading := False ;

        if LoadCode(lsFileName, 0)
        then begin
            gbError := False ;
            gbQuit := False ;

            goVariables.Add('$true', csTrueValue);
            goVariables.Add('$false', csFalseValue);
            goVariables.Add('$_version', csVersion);

            {$IFDEF COMMANDLINE}
            if ParamCount > liArguments
            then begin
                goVariables.Add('$argcount', IntToStr(ParamCount - liArguments)) ;

                for liIndex := liArguments + 1 to ParamCount do
                begin
                    goVariables.Add('$args[' + IntToStr(liIndex - liArguments) + ']', ParamStr(liIndex)) ;
                end ;
            end ;
            {$ENDIF}

            loEndCondition := TStringList.Create ;
            loEndCondition.Add('exit') ;

            { On commence par du code HTML et pas du code ex�cutable }
            gbIsExecutableCode := False ;

            { Ex�cute le code }
            ReadCode(0, loEndCondition, goCodeList) ;
            
            loEndCondition.Free ;
        end ;
    end ;
    
    FinishProgram ;

    if gbError = true
    then begin
        Exitcode := -1 ;
    end ;
end.
