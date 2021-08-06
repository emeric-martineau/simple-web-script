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
 * Main program. It check argument and lauch execute of code
 ******************************************************************************}
program SimpleWebScript;

{$IFNDEF FPC}
    {$APPTYPE CONSOLE}
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
  CoreFunctions,
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
  UnitHtml;

{$I config.inc}

{$I path_ini.inc}

var
    FileName : string ;
    EndCondition : TStringList ;
    CheminIni : String ;
    FichierIni : TIniFile ;
    DefaultType : String ;
    ListDisabledFunctions : TStringList ;
    i : Integer ;
    {$IFDEF COMMANDLINE}
    Arguments : Integer ;
    {$ENDIF}
begin
//    FileMode := fmOpenWrite ;
//    AssignFile(OutPut, 'debug.log') ;
//    Rewrite(OutPut) ;

    FileName := '' ;
    isHeaderSend := False ;
    isOriginalHeaderClear := False ;
    Warning := True ;
    Header := TStringList.Create ;
    LineWhereHeaderSend := 0 ;
    isOutPuBuffered := False ;

    { Force les date en anglais }
    setShortDayName ;
    setLongDayName ;
    setShortMonthName ;
    setLongMonthName ;

    { Définit les dates/mois du script par défaut }
    UserShortDayNames[1] := 'Sun' ;
    UserShortDayNames[2] := 'Mon' ;
    UserShortDayNames[3] := 'Tue' ;
    UserShortDayNames[4] := 'Wed' ;
    UserShortDayNames[5] := 'Thu' ;
    UserShortDayNames[6] := 'Fri' ;
    UserShortDayNames[7] := 'Sat' ;

    UserShortMonthNames[1] := 'Jan' ;
    UserShortMonthNames[2] := 'Feb' ;
    UserShortMonthNames[3] := 'Mar' ;
    UserShortMonthNames[4] := 'Apr' ;
    UserShortMonthNames[5] := 'May' ;
    UserShortMonthNames[6] := 'Jun' ;
    UserShortMonthNames[7] := 'Jul' ;
    UserShortMonthNames[8] := 'Aug' ;
    UserShortMonthNames[9] := 'Sep' ;
    UserShortMonthNames[10] := 'Oct' ;
    UserShortMonthNames[11] := 'Nov' ;
    UserShortMonthNames[12] := 'Dec' ;

    DateSeparator := '/' ;
    TimeSeparator := ':' ;

    FloatSeparator := '.' ;
    MillierSeparator := ',' ;

    DefaultCharset := 'iso-8859-1' ;

    {$IFNDEF COMMANDLINE}
    if (IniPath = '')
    then begin
        CheminIni := ExtractFileDir(ParamStr(0)) ;
    end
    else begin
        CheminIni := IniPath ;
    end ;
    {$ELSE}
    CheminIni := ExtractFileDir(ParamStr(0)) ;
    {$ENDIF}

    CheminIni := OsAddFinalDirSeparator(CheminIni)  ;

    FichierIni := TIniFile.Create(CheminIni + 'sws.ini') ;

    {$IFDEF COMMANDLINE}
    doc_root := GetCurrentDir ;
    {$ELSE}
    doc_root := OsAddFinalDirSeparator(RealPath(FichierIni.ReadString('general', 'doc_root', ''))) ;

    if doc_root = ''
    then
        doc_root := GetCurrentDir ;
    {$ENDIF}

    ElapseTime := FichierIni.ReadInteger('general', 'max_execution_time', 30) ;

    { On ajoute la taille avant lecture du script pour alloué exactement la taille souhaitée au script }
    MaxMemorySize := (FichierIni.ReadInteger('general', 'memory_limit', 8) * 1024 * 1024) + OSUsageMemory;

    DefaultType := FichierIni.ReadString('general', 'default_type', 'text/html') ;

    DisabledFunctions := FichierIni.ReadString('general', 'disabled_function', '') ;

    MaxPostSize := FichierIni.ReadInteger('general', 'post_max_size', 2) ;

    ExtDir := OSAddFinalDirSeparator(RealPath(FichierIni.ReadString('general', 'ext_path', ''))) ;

    tmpDir := OSAddFinalDirSeparator(RealPath(FichierIni.ReadString('general', 'tmp_dir', ''))) ;

    hideCfg := (FichierIni.ReadString('general', 'hide_cfg', 'true') = 'true') ;

    fileUpload := (FichierIni.ReadString('general', 'file_uploads', 'true') = 'true') ;

    uploadMaxFilesize := FichierIni.ReadInteger('general', 'upload_max_filesize', 2) ;

    SafeMode := (FichierIni.ReadString('general', 'safe_mode', 'true') = 'true') ;

    FichierIni.Free ;

    {$IFDEF COMMANDLINE}
    Debug := False ;
    Arguments := ParamCount ;

    if ParamCount > 0
    then begin
        i := 1 ;

        while i <= ParamCount do
        begin
            if ParamStr(i) = '-debug'
            then
                Debug := True
            else if ParamStr(i) = '-params'
            then begin
                Arguments := i ;
                break ;
            end
            else if ParamStr(i) = '-file'
            then begin
                FileName := ParamStr(i + 1) ;
                Inc(i) ;
            end ;

            Inc(i) ;
        end ;
    end ;
    {$ELSE}
    Header.Add('Content-Type: ' + DefaultType) ;
    Header.Add('') ;
    {$ENDIF}

    Variables := TVariables.Create ;
    VarGetPostCookieFileData := TGetPostCookieFileData.Create(MaxPostSize * 1024 * 1024, uploadMaxFilesize * 1024 * 1024) ;

    {$IFNDEF COMMANDLINE}
    FileName := VarGetPostCookieFileData.getFileNameOfScript ;
    {$ENDIF}

    if FileName = ''
    then begin
        {$IFDEF COMMANDLINE}
        Writeln(ExtractFileName(ParamStr(0)) + ' name_of_file') ;
        {$ELSE}
        OutPutString(sNoFileInput, false) ;
        {$ENDIF}

        Variables.Free ;
        VarGetPostCookieFileData.Free ;
        Header.Free ;
    end
    else begin
        OsInstallTrapOfCtrlC ;

        CodeList := TStringList.Create ;

        ListOfFile := TStringList.Create ;
        LineToFileLine := TStringList.Create ;
        LineToFile := TStringList.Create ;
        ListFunction := TInternalFunction.Create ;
        PointerOfVariables := TPointerOfTVariable.Create ;
        ListOfExtension := TExtension.Create ;
        ListCookie := TStringList.Create ;
        CurrentRootOfFile := TStringList.Create ;

        CurrentFunctionName := TStringList.Create ;
        CurrentFunctionName.Add('main script') ;

        FirstVariables := Variables ;
        GlobalVariable := TStringList.Create ;

        ListLabel := TUserLabel.Create ;
        ListProcedure := TUserFunction.Create ;

        CoreFunctionsInit ;
        StrFunctionsInit ;
        UrlFunctionsInit ;
        MathFunctionsInit ;
        MiscellaneousFunctionsInit ;
        HtmlFunctionsInit ;

        if DisabledFunctions <> ''
        then begin
            ListDisabledFunctions := TStringList.Create ;

            Explode(DisabledFunctions, ListDisabledFunctions, ',') ;

            for i := 0 to ListDisabledFunctions.count - 1 do
            begin
                {$IFNDEF FPC}
                ListFunction.Change(ListDisabledFunctions[i], FunctionDisabled, false);
                {$ELSE}
                ListFunction.Change(ListDisabledFunctions[i], @FunctionDisabled, false);
                {$ENDIF}
            end ;

            ListDisabledFunctions.Free ;
        end ;

        { Initialise l'heure de début du script }
        StartTime := now ;

        LabelReading := False ;

        if LoadCode(FileName, 0)
        then begin
            GlobalError := False ;
            GlobalQuit := False ;

            Variables.Add('$true', trueValue);
            Variables.Add('$false', FalseValue);
            Variables.Add('$_version', version);

            {$IFDEF COMMANDLINE}
            if ParamCount > Arguments
            then begin
                Variables.Add('$argcount', IntToStr(ParamCount - Arguments)) ;

                for i := Arguments + 1 to ParamCount do
                begin
                    Variables.Add('$args[' + IntToStr(i - Arguments) + ']', ParamStr(i)) ;
                end ;
            end ;
            {$ENDIF}

            EndCondition := TStringList.Create ;
            EndCondition.Add('exit') ;

            { On commence par du code HTML et pas du code exécutable }
            isExecutableCode := False ;

            { Exécute le code }
            ReadCode(0, EndCondition, CodeList) ;
            
            EndCondition.Free ;
        end ;

        FinishProgramm ;

    end ;

    if GlobalError = true
    then
        Exitcode := -1 ;
end.
