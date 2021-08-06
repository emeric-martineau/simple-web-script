unit UnitMiscellaneous;
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
 * This unit containt string function :
 *   header
 *   getGet
 *   getGetNumber
 *   getCookie
 *   getCookieNumber
 *   getEnv
 *   setCookie
 *   swsinfo
 ******************************************************************************}
interface

{$I config.inc}

uses Classes, Functions, UnitMessages, InternalFunction, UnitHtml, MD5Api ;

procedure MiscellaneousFunctionsInit ;
procedure headerCommande(arguments : TStringList) ;
procedure getGetCommande(arguments : TStringList) ;
procedure getCookieCommande(arguments : TStringList) ;
procedure getCookieNumberCommande(arguments : TStringList) ;
procedure getGetNumberCommande(arguments : TStringList) ;
procedure getEnvCommande(arguments : TStringList) ;
procedure setCookieCommande(arguments : TStringList) ;
procedure swsinfoCommande(arguments : TStringList) ;
procedure getPostCommande(arguments : TStringList) ;
procedure getPostNumberCommande(arguments : TStringList) ;
procedure getCfgVarsCommande(arguments : TStringList) ;
procedure getFileCommande(arguments : TStringList) ;
procedure SetLocalCommande(arguments : TStringList) ;
procedure OutputBufferStartCommande(arguments : TStringList) ;
procedure OutputBufferWriteCommande(arguments : TStringList) ;
procedure OutputBufferClearCommande(arguments : TStringList) ;
procedure OutputBufferStopCommande(arguments : TStringList) ;
procedure OutputBufferGetCommande(arguments : TStringList) ;
procedure ShellExecCommande(arguments : TStringList) ;
procedure Crc32Commande(arguments : TStringList) ;
procedure SleepCommande(arguments : TStringList) ;
procedure RolCommande(arguments : TStringList) ;
procedure RorCommande(arguments : TStringList) ;
procedure Md5Commande(arguments : TStringList) ;
//
function Rol(octet : byte; decalage : integer) : byte ;
function Ror(octet : byte; decalage : integer) : byte ;

implementation

uses Code, SysUtils, UnitOs, Variable, UserFunction, DateUtils ;

procedure headerCommande(arguments : TStringList) ;
var FileName, LineNumber : String ;
begin
    ResultFunction := falseValue ;

    if arguments.count = 1
    then begin
        if isHeaderSend
        then begin
            if LineToFile.count > 0
            then
                FileName := AddSlashes(ListOfFile[MyStrToInt(LineToFile[CurrentLineNumber])])
            else
                FileName := sGeneralError ;

            if (CurrentFunctionName.Count > 0) and (LineToFileLine.Count >0)
            then
                LineNumber := LineToFileLine[CurrentLineNumber]
            else
                LineNumber := '0' ;

            WarningMsg(Format('Cannot modify header information - headers already sent by (output started at %s:%s)', [FileName, LineNumber])) ;
        end
        else begin
            if not isOriginalHeaderClear
            then
                Header.Clear ;

            isOriginalHeaderClear := True ;
            
            AddHeader(arguments[0]) ;
            
            ResultFunction := trueValue ;    
        end ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 1
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure getGetCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := VarGetPostCookieFileData.getGet(arguments[0]) ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 1
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure getCookieCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := VarGetPostCookieFileData.getCookie(arguments[0]) ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 1
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure getCookieNumberCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := IntToStr(VarGetPostCookieFileData.GetData.Count) ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 1
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure getGetNumberCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := IntToStr(VarGetPostCookieFileData.CookieData.Count) ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 1
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure getEnvCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := AddSlashes(GetEnvironmentVariable(arguments[0])) ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 1
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure getPostCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := VarGetPostCookieFileData.getPost(arguments[0]) ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 1
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure getPostNumberCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := IntToStr(VarGetPostCookieFileData.PostData.Count) ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 1
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure setCookieCommande(arguments : TStringList) ;
var Name : string ;
    value : string ;
    Expire : Integer ;
    Path : string ;
    domain : string ;
    secure : string ;
    httponly : string ;
    tmp : String ;
begin
    // Set-Cookie: emeric=coucou; expires=Thu, 29-Nov-2007 14:52:21 GMT; path=path; domain=domaine; secure; httponly
    if (arguments.count > 0) and (arguments.count < 8)
    then begin
        tmp := 'Set-Cookie: ' ;

        Name := UrlEncode(arguments[0]) ;

        tmp := tmp + Name + '=' ;

        if arguments.count > 1
        then
            value := arguments[1]
        else
            value := '' ;

        tmp := tmp + value ;

        if arguments.count > 2
        then
            expire := MyStrToInt(arguments[2])
        else
            expire := 0 ;

        if expire <> 0
        then begin
            { restaure les dates/mois en anglais }
            setShortDayName ;
            setShortMonthName ;

            tmp := tmp + '; ' + FormatDateTime('ddd, dd-mmm-yyyy hh:nn:ss', UnixToDateTime(expire)) + ' GMT' ;

            { restaure les dates/mois définit par l'utilisateur }
            InitDayName(ShortDayNames, UserShortDayNames) ;
            InitMonthName(ShortMonthNames, UserShortMonthNames) ;
        end ;

        if arguments.count > 3
        then
            path := '; path=' + UrlEncode(arguments[3])
        else
            path := '' ;

        tmp := tmp + path ;

        if arguments.count > 4
        then
            domain := '; damain=' + UrlEncode(arguments[4])
        else
            domain := '' ;

        tmp := tmp + domain ;

        if arguments.count > 5
        then
            if arguments[5]  <> falseValue
            then
                secure := '; secure'
        else
            secure := '' ;

        tmp := tmp + secure ;

        if arguments.count > 6
        then
            if arguments[6]  <> falseValue
            then
                httponly := '; httponly'
        else
            httponly := '' ;

        tmp := tmp + httponly ;

        AddHeader(tmp) ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 7
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure swsinfoCommande(arguments : TStringList) ;
var Liste : TStrings ;
    i : Integer ;
    name, value : String ;
  procedure putCol(name, value : string) ;
  begin
        OutPutString('  <tr>', false) ;
        OutPutString('\n', True) ;
        OutPutString('    <td class="nom">' + name + '</td>', false) ;
        OutPutString('\n', True) ;
        OutPutString('    <td class="valeur">' + value + '</td>', false) ;
        OutPutString('\n', True) ;
        OutPutString('  </tr>', false) ;
        OutPutString('\n', True) ;        
  end ;
begin
    if arguments.count = 0
    then begin
        Liste := TStringList.Create ;

        OutPutString('<?xml version="1.0" encoding="iso-8859-1"?>', false) ;
        OutPutString('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">', false) ;
        OutPutString('<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr">', false) ;
        OutPutString('\n', true) ;
        OutPutString('<head>', false) ;
        OutPutString('\n', true) ;
        OutPutString('<title>swsinfo()</title>', false) ;
        OutPutString('<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />', false) ;
        OutPutString('<style type="text/css">', false) ;
        OutPutString('body {background-color: #ffffff; color: #000000;}', false) ;
        OutPutString('body, td, th, h1, h2 {font-family: sans-serif;}', false) ;
        OutPutString('table {border-collapse: collapse;}', false) ;
        OutPutString('tr, table, td { border: 1px solid Black; }', false) ;
        OutPutString('.nom { font-weight: bold; background-color: dddddd; }', false) ;
        OutPutString('.valeur { background-color: Silver; }', false) ;        
        OutPutString('</style>', false) ;
        OutPutString('</head>', false) ;
        OutPutString('\n', true) ;
        OutPutString('<body>', false) ;
        OutPutString('\n', true) ;
        OutPutString('<h1>Simple Web Script ' + version + ' Information </h1>', false) ;
        OutPutString('<h2>Simple Web Scrip configuration (sws.ini)</h2>', false) ;
        OutPutString('<table width="0" border="0" cellspacing="0" cellpadding="3">', false) ;

        putCol('Time maximum of execution in second', IntToStr(ElapseTime)) ;
        putCol('Maximum memory can be used in Mb', IntToStr(MaxMemorySize)) ;
        putCol('Maximum size of post data in Mb', IntToStr(MaxPostSize)) ;
        putCol('Maximum size of file to post in Mb', IntToStr(uploadMaxFilesize)) ;
        putCol('Disabled functions', DisabledFunctions) ;

        if not hideCfg
        then begin
            putCol('Tempory directory', tmpDir) ;
            putCol('Extention directory', ExtDir) ;
            putCol('Root of document', doc_root) ;
        end ;
        
        OutPutString('</table>', false) ;
        OutPutString('<h2>Serveur environement</h2>', false) ;

        OSgetAllEnvVar(Liste) ;

        if Liste.Count > 0
        then begin
            OutPutString('<table width="0" border="0" cellspacing="0" cellpadding="3">', false) ;

            for i := 0 to Liste.Count - 1 do
            begin
                putCol(Liste[i], htmlspecialcharencode(GetEnvironmentVariable(Liste[i]), DefaultCharset, 2, false)) ;
            end ;

            OutPutString('</table>', false) ;
        end ;

        OutPutString('<h2>Get variables</h2>', false) ;

        if VarGetPostCookieFileData.GetData.Count > 0
        then begin
            OutPutString('<table width="0" border="0" cellspacing="0" cellpadding="3">', false) ;

            for i := 0 to VarGetPostCookieFileData.GetData.Count - 1 do
            begin
                name := VarGetPostCookieFileData.GetData.GiveVarNameByIndex(i) ;
                value := VarGetPostCookieFileData.GetData.Give(Name) ;
                value := showData(value, '', 0) ;
                ReplaceOneOccurence('\n', value, '<br />', true) ;
                putCol(name, htmlspecialcharencode(value, DefaultCharset, 2, false)) ;
            end ;

            OutPutString('</table>', false) ;
        end ;

        OutPutString('<h2>Post variables</h2>', false) ;

        if VarGetPostCookieFileData.PostData.Count > 0
        then begin
            OutPutString('<table width="0" border="0" cellspacing="0" cellpadding="3">', false) ;

            for i := 0 to VarGetPostCookieFileData.PostData.Count - 1 do
            begin
                name := VarGetPostCookieFileData.PostData.GiveVarNameByIndex(i) ;
                value := VarGetPostCookieFileData.PostData.Give(Name) ;
                value := showData(value, '', 0) ;
                ReplaceOneOccurence('\n', value, '<br />', true) ;
                putCol(name, htmlspecialcharencode(value, 'iso-8859-1', 2, false)) ;
            end ;

            OutPutString('</table>', false) ;
        end ;

        OutPutString('<h2>Cookie variables</h2>', false) ;

        if VarGetPostCookieFileData.CookieData.Count > 0
        then begin
            OutPutString('<table width="0" border="0" cellspacing="0" cellpadding="3">', false) ;

            for i := 0 to VarGetPostCookieFileData.CookieData.Count - 1 do
            begin
                name := VarGetPostCookieFileData.CookieData.GiveVarNameByIndex(i) ;
                value := VarGetPostCookieFileData.CookieData.Give(Name) ;
                value := showData(value, '', 0) ;
                ReplaceOneOccurence('\n', value, '<br />', true) ;
                putCol(name, htmlspecialcharencode(value, DefaultCharset, 2, false)) ;
            end ;

            OutPutString('</table>', false) ;
        end ;

        OutPutString('<h2>File variables</h2>', false) ;

        if VarGetPostCookieFileData.FileData.Count > 0
        then begin
            OutPutString('<table width="0" border="0" cellspacing="0" cellpadding="3">', false) ;

            for i := 0 to VarGetPostCookieFileData.FileData.Count - 1 do
            begin
                name := VarGetPostCookieFileData.FileData.GiveVarNameByIndex(i) ;
                value := VarGetPostCookieFileData.FileData.Give(Name) ;
                value := showData(value, '', 0) ;
                ReplaceOneOccurence('\n', value, '<br />', true) ;
                putCol(name, htmlspecialcharencode(value, DefaultCharset, 2, false)) ;
            end ;

            OutPutString('</table>', false) ;
        end ;

        OutPutString('</body>', false) ;
        OutPutString('</html>', false) ;

        Liste.Free ;
    end
    else if arguments.count < 0
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 0
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure getCfgVarsCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := '' ;
            
        if arguments[0] = 'max_execution_time'
        then
            ResultFunction := IntToStr(ElapseTime)
        else if arguments[0] = 'memory_limit'
        then
            ResultFunction := IntToStr(MaxMemorySize)
        else if arguments[0] = 'disabled_function'
        then
            ResultFunction := DisabledFunctions
        else if arguments[0] = 'upload_max_filesize'
        then
            ResultFunction := IntToStr(uploadMaxFilesize)
        else if arguments[0] = 'file_uploads'
        then
            if (fileUpload = True)
            then
                ResultFunction := TrueValue
            else
                ResultFunction := FalseValue ;

    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 1
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure getFileCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := VarGetPostCookieFileData.getFile(arguments[0]) ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 1
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure SetLocalCommande(arguments : TStringList) ;
var Liste : TStringList ;
    i : Integer ;
    len : Integer ;
begin
    if arguments.count = 2
    then begin
        Liste := TStringList.Create ;
        arguments[0] := LowerCase(arguments[0]) ;

        if arguments[0] = 'shortdayname'
        then begin
            if Variables.InternalIsArray(arguments[1])
            then begin
                Variables.Explode(Liste, arguments[1]) ;

                if Liste.Count > 7
                then
                    len := 7
                else
                    len := Liste.Count ;

                for i := 0 to len - 1 do
                begin
                    UserShortDayNames[i + 1] := Liste[i] ;
                    ShortDayNames[i + 1] := Liste[i] ;
                end ;
            end
            else
                WarningMsg(sMustBeAnArray) ;
        end
        else if arguments[0] = 'longdayname'
        then begin
            if Variables.InternalIsArray(arguments[1])
            then begin
                Variables.Explode(Liste, arguments[1]) ;

                if Liste.Count > 7
                then
                    len := 7
                else
                    len := Liste.Count ;

                for i := 0 to len - 1 do
                begin
                    LongDayNames[i + 1] := Liste[i] ;
                end ;
            end
            else
                WarningMsg(sMustBeAnArray) ;
        end
        else if arguments[0] = 'shortmonthname'
        then begin
            if Variables.InternalIsArray(arguments[1])
            then begin
                Variables.Explode(Liste, arguments[1]) ;

                if Liste.Count > 12
                then
                    len := 12
                else
                    len := Liste.Count ;

                for i := 0 to len - 1 do
                begin
                    UserShortMonthNames[i + 1] := Liste[i] ;
                    ShortMonthNames[i + 1] := Liste[i] ;
                end ;
            end
            else
                WarningMsg(sMustBeAnArray) ;
        end
        else if arguments[0] = 'longmonthname'
        then begin
            if Variables.InternalIsArray(arguments[1])
            then begin
                Variables.Explode(Liste, arguments[1]) ;

                if Liste.Count > 12
                then
                    len := 12
                else
                    len := Liste.Count ;

                for i := 0 to len - 1 do
                begin
                    LongMonthNames[i + 1] := Liste[i] ;
                end ;
            end
            else
                WarningMsg(sMustBeAnArray) ;
        end
        else if arguments[0] = 'floatseparator'
        then begin
            FloatSeparator := arguments[1] ;
        end
        else if arguments[0] = 'millierseparator'
        then begin
            MillierSeparator := arguments[1] ;
        end
        else if arguments[0] = 'charset'
        then begin
            DefaultCharset := LowerCase(arguments[1]) ;
        end ;

        Liste.Free ;
    end
    else if arguments.count < 2
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 2
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure OutputBufferStartCommande(arguments : TStringList) ;
Var ListArguments : TStringList ;
begin
    if (arguments.count = 0) or (arguments.count = 1)
    then begin
        ResultFunction := FalseValue ;

        if ListProcedure.Give(arguments[0]) <> - 1
        then begin
            ListArguments := TStringList.Create ;
            ListArguments.Text := ListProcedure.GiveArguments(arguments[0]) ;

            if ListArguments.Count = 1
            then begin
                isOutPuBuffered := True ;

                if arguments.Count > 0
                then
                    OutPutFunction := arguments[0]
                else
                    OutPutFunction := '' ;

                ResultFunction := TrueValue ;
                ListArguments.Free ;
            end ;
        end ;
    end
    else if arguments.count > 1
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure OutputBufferWriteCommande(arguments : TStringList) ;
begin
    if arguments.count = 0
    then begin
        if (not isHeaderSend)
        then
            SendHeader ;

        write(OutPutContent) ;
        OutPutContent := '' ;
    end
    else if arguments.count > 0
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure OutputBufferClearCommande(arguments : TStringList) ;
begin
    if arguments.count = 0
    then begin
        OutPutContent := '' ;
    end
    else if arguments.count > 0
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure OutputBufferStopCommande(arguments : TStringList) ;
begin
    if arguments.count = 0
    then begin
        isOutPuBuffered := False ;
    end
    else if arguments.count > 0
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure OutputBufferGetCommande(arguments : TStringList) ;
begin
    if arguments.count = 0
    then begin
        ResultFunction := OutPutContent ;
    end
    else if arguments.count > 0
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure ShellExecCommande(arguments : TStringList) ;
var delay : integer ;
begin
    if arguments.count = 1
    then begin
        Delay := FloatToInt(SecondSpan(Now, now + (ElapseTime  div (24*3600)))) * 1000 ;

        ResultFunction := OsShellExec(arguments[0], Delay) ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 1
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure Crc32Commande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := IntToStr(CRC32(arguments[0])) ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 1
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure SleepCommande(arguments : TStringList) ;
var delay : Integer ;
begin
    if arguments.count = 1
    then begin
        delay := MyStrToInt(arguments[0]) ;

        if delay >= 0
        then
            Sleep(delay)
        else
            WarningMsg(sNotAcceptNegativeValue) ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 1
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end  ;

procedure bintohexCommande(arguments : TStringList) ;
var i : Integer ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := '' ;

        for i := 1 to Length(arguments[0]) do
        begin
            ResultFunction := ResultFunction + DecToHex(Byte(arguments[0][i])) ;
        end ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 1
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end  ;

function Rol(octet : byte; decalage : integer) : byte ;
var i : Integer ;
begin
    Result := octet ;
    for i := 1 to decalage do
    begin
        Result := (Result shl 1) or ((Result and 128) shr 7) ;
    end ;
end ;

function Ror(octet : byte; decalage : integer) : byte ;
var i : Integer ;
begin
    Result := octet ;
    for i := 1 to decalage do
    begin
        Result := ((Result and 1) shl 7) or (Result shr 1) ;
    end ;
end ;

procedure RolCommande(arguments : TStringList) ;
var
    val : Integer ;
    decalage : Integer ;
begin
    if (arguments.count = 1) or (arguments.count = 2)
    then begin
        if IsInteger(arguments[0])
        then begin
            val := MyStrToInt(arguments[0]) ;
            decalage := 1 ;

            if arguments.count = 2
            then begin
                if IsInteger(arguments[0])
                then begin
                    decalage := MyStrToInt(arguments[1]) ;
                end
                else begin
                    ErrorMsg(sDecalgeMustBeInteger) ;
                end ;
            end ;

            if val < 256
            then begin
                ResultFunction := IntToStr(Rol(Byte(val), decalage))
            end
            else begin
                ErrorMsg(sMustBeAByte) ;
            end ;
        end
        else begin
            ErrorMsg(sMustBeAByte) ;
        end ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 2
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end  ;

procedure RorCommande(arguments : TStringList) ;
var
    val : Integer ;
    decalage : Integer ;
begin
    if (arguments.count = 1) or (arguments.count = 2)
    then begin
        if IsInteger(arguments[0])
        then begin
            val := MyStrToInt(arguments[0]) ;
            decalage := 1 ;

            if arguments.count = 2
            then begin
                if IsInteger(arguments[0])
                then begin
                    decalage := MyStrToInt(arguments[1]) ;
                end
                else begin
                    ErrorMsg(sDecalgeMustBeInteger) ;
                end ;
            end ;

            if val < 256
            then begin
                ResultFunction := IntToStr(Ror(Byte(val), decalage))
            end
            else begin
                ErrorMsg(sMustBeAByte) ;
            end ;
        end
        else begin
            ErrorMsg(sMustBeAByte) ;
        end ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 2
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end  ;

procedure Md5Commande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := MD5(arguments[0]) ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 1
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end  ;

procedure MiscellaneousFunctionsInit ;
begin
    ListFunction.Add('header', @headerCommande, true) ;
    ListFunction.Add('getget', @getGetCommande, true) ;
    ListFunction.Add('getcookie', @getCookieCommande, true) ;
    ListFunction.Add('getgetnumber', @getGetNumberCommande, true) ;
    ListFunction.Add('getcookienumber', @getCookieCommande, true) ;
    ListFunction.Add('getenv', @getenvCommande, true) ;
    ListFunction.Add('setcookie', @setCookieCommande, true) ;
    ListFunction.Add('swsinfo', @swsinfoCommande, true) ;
    ListFunction.Add('getpost', @getpostCommande, true) ;
    ListFunction.Add('getpostnumber', @getPostNumberCommande, true) ;
    ListFunction.Add('getcfgvars', @getCfgVarsCommande, true) ;
    ListFunction.Add('getfile', @getFileCommande, true) ;
    ListFunction.Add('setlocal', @setLocalCommande, true) ;
    ListFunction.Add('outputbufferstart', @OutputBufferStartCommande, true) ;
    ListFunction.Add('outputbufferwrite', @OutputBufferWriteCommande, true) ;
    ListFunction.Add('outputbufferclear', @OutputBufferClearCommande, true) ;
    ListFunction.Add('outputbufferstop', @OutputBufferStopCommande, true) ;
    ListFunction.Add('outputbufferget', @OutputBufferGetCommande, true) ;
    ListFunction.Add('shellexec', @ShellExecCommande, true) ;
    ListFunction.Add('crc32', @Crc32Commande, true) ;
    ListFunction.Add('sleep', @SleepCommande, true) ;
    ListFunction.Add('rol', @RolCommande, true) ;
    ListFunction.Add('ror', @RorCommande, true) ;
    ListFunction.Add('md5', @Md5Commande, true) ;    
end ;

end.
