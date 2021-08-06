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

{$IFDEF FPC}
    {$mode objfpc}{$H+}
{$ENDIF}

uses Classes, Functions, UnitMessages, InternalFunction, UnitHtml, MD5Api,
     GetPostCookieFileData ;

procedure MiscellaneousFunctionsInit ;
procedure headerCommande(aoArguments : TStringList) ;
procedure getGetCommande(aoArguments : TStringList) ;
procedure getCookieCommande(aoArguments : TStringList) ;
procedure getCookieNumberCommande(aoArguments : TStringList) ;
procedure getGetNumberCommande(aoArguments : TStringList) ;
procedure getEnvCommande(aoArguments : TStringList) ;
procedure setCookieCommande(aoArguments : TStringList) ;
procedure swsinfoCommande(aoArguments : TStringList) ;
procedure getPostCommande(aoArguments : TStringList) ;
procedure getPostNumberCommande(aoArguments : TStringList) ;
procedure getCfgVarsCommande(aoArguments : TStringList) ;
procedure getFileCommande(aoArguments : TStringList) ;
procedure SetLocalCommande(aoArguments : TStringList) ;
procedure OutputBufferStartCommande(aoArguments : TStringList) ;
procedure OutputBufferWriteCommande(aoArguments : TStringList) ;
procedure OutputBufferClearCommande(aoArguments : TStringList) ;
procedure OutputBufferStopCommande(aoArguments : TStringList) ;
procedure OutputBufferGetCommande(aoArguments : TStringList) ;
procedure ShellExecCommande(aoArguments : TStringList) ;
procedure Crc32Commande(aoArguments : TStringList) ;
procedure SleepCommande(aoArguments : TStringList) ;
procedure RolCommande(aoArguments : TStringList) ;
procedure RorCommande(aoArguments : TStringList) ;
procedure Md5Commande(aoArguments : TStringList) ;
procedure IsSetGetCommande(aoArguments : TStringList) ;
procedure IsSetPostCommande(aoArguments : TStringList) ;
procedure IsSetCookieCommande(aoArguments : TStringList) ;
procedure IsSetFileCommande(aoArguments : TStringList) ;
//
function Rol(abOctet : byte; aiDecalage : integer) : byte ;
function Ror(abOctet : byte; aiDecalage : integer) : byte ;
function CRC32(asText : String) : Integer ;

implementation

uses Code, SysUtils, UnitOs, Variable, UserFunction, DateUtils ;

{*****************************************************************************
 * CRC32
 * MARTINEAU Emeric
 *
 * Calcule le CRC32 d'une chaine de caractère
 *
 * Paramètres d'entrée :
 *   - asText : chaine à traiter
 *
 * Retour : entier 32 bits représentant le CRC32
 *****************************************************************************}
function CRC32(asText : String) : Integer ;
const  CRC32Table : array[0..255] of cardinal = (
                                                  $00000000, $77073096, $EE0E612C, $990951BA, $076DC419, $706AF48F, $E963A535, $9E6495A3,
                                                  $0EDB8832, $79DCB8A4, $E0D5E91E, $97D2D988, $09B64C2B, $7EB17CBD, $E7B82D07, $90BF1D91,
                                                  $1DB71064, $6AB020F2, $F3B97148, $84BE41DE, $1ADAD47D, $6DDDE4EB, $F4D4B551, $83D385C7,
                                                  $136C9856, $646BA8C0, $FD62F97A, $8A65C9EC, $14015C4F, $63066CD9, $FA0F3D63, $8D080DF5,
                                                  $3B6E20C8, $4C69105E, $D56041E4, $A2677172, $3C03E4D1, $4B04D447, $D20D85FD, $A50AB56B,
                                                  $35B5A8FA, $42B2986C, $DBBBC9D6, $ACBCF940, $32D86CE3, $45DF5C75, $DCD60DCF, $ABD13D59,
                                                  $26D930AC, $51DE003A, $C8D75180, $BFD06116, $21B4F4B5, $56B3C423, $CFBA9599, $B8BDA50F,
                                                  $2802B89E, $5F058808, $C60CD9B2, $B10BE924, $2F6F7C87, $58684C11, $C1611DAB, $B6662D3D,
                                                  $76DC4190, $01DB7106, $98D220BC, $EFD5102A, $71B18589, $06B6B51F, $9FBFE4A5, $E8B8D433,
                                                  $7807C9A2, $0F00F934, $9609A88E, $E10E9818, $7F6A0DBB, $086D3D2D, $91646C97, $E6635C01,
                                                  $6B6B51F4, $1C6C6162, $856530D8, $F262004E, $6C0695ED, $1B01A57B, $8208F4C1, $F50FC457,
                                                  $65B0D9C6, $12B7E950, $8BBEB8EA, $FCB9887C, $62DD1DDF, $15DA2D49, $8CD37CF3, $FBD44C65,
                                                  $4DB26158, $3AB551CE, $A3BC0074, $D4BB30E2, $4ADFA541, $3DD895D7, $A4D1C46D, $D3D6F4FB,
                                                  $4369E96A, $346ED9FC, $AD678846, $DA60B8D0, $44042D73, $33031DE5, $AA0A4C5F, $DD0D7CC9,
                                                  $5005713C, $270241AA, $BE0B1010, $C90C2086, $5768B525, $206F85B3, $B966D409, $CE61E49F,
                                                  $5EDEF90E, $29D9C998, $B0D09822, $C7D7A8B4, $59B33D17, $2EB40D81, $B7BD5C3B, $C0BA6CAD,
                                                  $EDB88320, $9ABFB3B6, $03B6E20C, $74B1D29A, $EAD54739, $9DD277AF, $04DB2615, $73DC1683,
                                                  $E3630B12, $94643B84, $0D6D6A3E, $7A6A5AA8, $E40ECF0B, $9309FF9D, $0A00AE27, $7D079EB1,
                                                  $F00F9344, $8708A3D2, $1E01F268, $6906C2FE, $F762575D, $806567CB, $196C3671, $6E6B06E7,
                                                  $FED41B76, $89D32BE0, $10DA7A5A, $67DD4ACC, $F9B9DF6F, $8EBEEFF9, $17B7BE43, $60B08ED5,
                                                  $D6D6A3E8, $A1D1937E, $38D8C2C4, $4FDFF252, $D1BB67F1, $A6BC5767, $3FB506DD, $48B2364B,
                                                  $D80D2BDA, $AF0A1B4C, $36034AF6, $41047A60, $DF60EFC3, $A867DF55, $316E8EEF, $4669BE79,
                                                  $CB61B38C, $BC66831A, $256FD2A0, $5268E236, $CC0C7795, $BB0B4703, $220216B9, $5505262F,
                                                  $C5BA3BBE, $B2BD0B28, $2BB45A92, $5CB36A04, $C2D7FFA7, $B5D0CF31, $2CD99E8B, $5BDEAE1D,
                                                  $9B64C2B0, $EC63F226, $756AA39C, $026D930A, $9C0906A9, $EB0E363F, $72076785, $05005713,
                                                  $95BF4A82, $E2B87A14, $7BB12BAE, $0CB61B38, $92D28E9B, $E5D5BE0D, $7CDCEFB7, $0BDBDF21,
                                                  $86D3D2D4, $F1D4E242, $68DDB3F8, $1FDA836E, $81BE16CD, $F6B9265B, $6FB077E1, $18B74777,
                                                  $88085AE6, $FF0F6A70, $66063BCA, $11010B5C, $8F659EFF, $F862AE69, $616BFFD3, $166CCF45,
                                                  $A00AE278, $D70DD2EE, $4E048354, $3903B3C2, $A7672661, $D06016F7, $4969474D, $3E6E77DB,
                                                  $AED16A4A, $D9D65ADC, $40DF0B66, $37D83BF0, $A9BCAE53, $DEBB9EC5, $47B2CF7F, $30B5FFE9,
                                                  $BDBDF21C, $CABAC28A, $53B39330, $24B4A3A6, $BAD03605, $CDD70693, $54DE5729, $23D967BF,
                                                  $B3667A2E, $C4614AB8, $5D681B02, $2A6F2B94, $B40BBE37, $C30C8EA1, $5A05DF1B, $2D02EF8D
                                                ) ;
var
    i : integer;
begin
    Result := -1 ;

    for i := 1 to Length(asText) do
    begin
        Result := (Result shr 8) xor Integer(CRC32Table[Byte(asText[i]) xor Byte(Result)]) ;
    end;

    Result := not result;
end ;

procedure headerCommande(aoArguments : TStringList) ;
var FileName, LineNumber : String ;
begin
    gsResultFunction := csFalseValue ;

    if aoArguments.count = 1
    then begin
        if gbIsHeaderSend
        then begin
            if goLineToFile.count > 0
            then begin
                FileName := AddSlashes(goListOfFile[MyStrToInt(goLineToFile[giCurrentLineNumber])]) ;
            end
            else begin
                FileName := csGeneralError ;
            end ;
            
            if (goCurrentFunctionName.Count > 0) and (goLineToFileLine.Count >0)
            then begin
                LineNumber := goLineToFileLine[giCurrentLineNumber] ;
            end
            else begin
                LineNumber := '0' ;
            end ;

            WarningMsg(Format(csCanNotModifyHeader, [FileName, LineNumber])) ;
        end
        else begin
            if not gbIsOriginalHeaderClear
            then begin
                Header.Clear ;
            end ;

            gbIsOriginalHeaderClear := True ;
            
            AddHeader(aoArguments[0]) ;
            
            gsResultFunction := csTrueValue ;
        end ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure getGetCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := goVarGetPostCookieFileData.getGet(aoArguments[0]) ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure getCookieCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := goVarGetPostCookieFileData.getCookie(aoArguments[0]) ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure getCookieNumberCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := IntToStr(goVarGetPostCookieFileData.goGetData.Count) ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure getGetNumberCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := IntToStr(goVarGetPostCookieFileData.goCookieData.Count) ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure getEnvCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := AddSlashes(GetEnvironmentVariable(aoArguments[0])) ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure getPostCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := goVarGetPostCookieFileData.getPost(aoArguments[0]) ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure getPostNumberCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := IntToStr(goVarGetPostCookieFileData.goPostData.Count) ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure setCookieCommande(aoArguments : TStringList) ;
var
    { Nom du cookie }
    lsCookieName : string ;
    { Value du cookie }
    lsCookieValue : string ;
    { Date d'expiration }
    liExpireTime : Integer ;
    { Chemin du cookie }
    lsPath : string ;
    { Domaine }
    lsDomain : string ;
    { Est-ce que le cookie est en https }
    lsSecure : string ;
    { Http seulement }
    lsHttpOnly : string ;
    { reçoit la ligne de cookie }
    lsCookieString : String ;
begin
    // Set-Cookie: emeric=coucou; expires=Thu, 29-Nov-2007 14:52:21 GMT; path=path; domain=domaine; secure; httponly
    if (aoArguments.count > 0) and (aoArguments.count < 8)
    then begin
        lsCookieString := 'Set-Cookie: ' ;

        lsCookieName := UrlEncode(aoArguments[0]) ;

        lsCookieString := lsCookieString + lsCookieName + '=' ;

        if aoArguments.count > 1
        then begin
            lsCookieValue := UrlEncode(aoArguments[1]) ;
    end
        else begin
            lsCookieValue := '' ;
    end ;

        lsCookieString := lsCookieString + lsCookieValue ;

        if aoArguments.count > 2
        then begin
            liExpireTime := MyStrToInt(aoArguments[2]) ;
        end
        else begin
            liExpireTime := 0 ;
        end ;

        if liExpireTime <> 0
        then begin
            { restaure les dates/mois en anglais }
            setShortDayName ;
            setShortMonthName ;

            lsCookieString := lsCookieString + '; ' + FormatDateTime('ddd, dd-mmm-yyyy hh:nn:ss', UnixToDateTime(liExpireTime)) + ' GMT' ;

            { restaure les dates/mois définit par l'utilisateur }
            InitDayName(ShortDayNames, gaUserShortDayNames) ;
            InitMonthName(ShortMonthNames, gaUserShortMonthNames) ;
        end ;

        if aoArguments.count > 3
        then begin
            lsPath := '; path=' + UrlEncode(aoArguments[3]) ;
        end
        else begin
            lsPath := '' ;
        end ;

        lsCookieString := lsCookieString + lsPath ;

        if aoArguments.count > 4
        then begin
            lsDomain := '; damain=' + UrlEncode(aoArguments[4]) ;
        end
        else begin
            lsDomain := '' ;
        end ;

        lsCookieString := lsCookieString + lsDomain ;

        if aoArguments.count > 5
        then begin
            if aoArguments[5]  <> csFalseValue
            then begin
                lsSecure := '; secure' ;
            end ;
        end
        else begin
            lsSecure := '' ;
        end ;

        lsCookieString := lsCookieString + lsSecure ;

        if aoArguments.count > 6
        then begin
            if aoArguments[6]  <> csFalseValue
            then begin
                lsHttpOnly := '; httponly' ;
            end ;
        end
        else begin
            lsHttpOnly := '' ;
        end ;

        lsCookieString := lsCookieString + lsHttpOnly ;

        AddHeader(lsCookieString) ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 7
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure swsinfoCommande(aoArguments : TStringList) ;
var
    { liste cookie/get/post/file }
    loListe : TStrings ;
    { index de cookie/get/post/file }
    liIndex : Integer ;
    { Nom du cookie/get/post/file }
    lsName : String ;
    { Valeur du cookie/get/post/file }
    lsValue : String ;
    
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
    if aoArguments.count = 0
    then begin
        loListe := TStringList.Create ;

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
        OutPutString('<h1>Simple Web Script ' + csVersion + ' Information </h1>', false) ;
        OutPutString('<h2>Simple Web Scrip configuration (sws.ini)</h2>', false) ;
        OutPutString('<table width="0" border="0" cellspacing="0" cellpadding="3">', false) ;

        putCol('Time maximum of execution in second', IntToStr(giElapseTime)) ;
        putCol('Maximum memory can be used in Mb', IntToStr(giMaxMemorySize)) ;
        putCol('Maximum size of post data in Mb', IntToStr(giMaxPostSize)) ;
        putCol('Maximum size of file to post in Mb', IntToStr(giUploadMaxFilesize)) ;
        putCol('Disabled functions', gsDisabledFunctions) ;

        if not gbHideCfg
        then begin
            putCol('Tempory directory', gsTmpDir) ;
            putCol('Extention directory', gsExtDir) ;
            putCol('Root of document', gsDocRoot) ;
        end ;
        
        OutPutString('</table>', false) ;
        OutPutString('<h2>Server environment</h2>', false) ;

        OSgetAllEnvVar(loListe) ;

        if loListe.Count > 0
        then begin
            OutPutString('<table width="0" border="0" cellspacing="0" cellpadding="3">', false) ;

            for liIndex := 0 to loListe.Count - 1 do
            begin
                putCol(loListe[liIndex], htmlspecialcharencode(GetEnvironmentVariable(loListe[liIndex]), gsDefaultCharset, 2, false)) ;
            end ;

            OutPutString('</table>', false) ;
        end ;

        OutPutString('<h2>Get variables</h2>', false) ;

        if goVarGetPostCookieFileData.goGetData.Count > 0
        then begin
            OutPutString('<table width="0" border="0" cellspacing="0" cellpadding="3">', false) ;

            for liIndex := 0 to goVarGetPostCookieFileData.goGetData.Count - 1 do
            begin
                lsName := goVarGetPostCookieFileData.goGetData.GiveVarNameByIndex(liIndex) ;
                lsValue := goVarGetPostCookieFileData.goGetData.Give(lsName) ;
                lsValue := showData(lsValue, '', 0) ;
                ReplaceOneOccurence('\n', lsValue, '<br />', true) ;
                putCol(lsName, htmlspecialcharencode(lsValue, gsDefaultCharset, 2, false)) ;
            end ;

            OutPutString('</table>', false) ;
        end ;

        OutPutString('<h2>Post variables</h2>', false) ;

        if goVarGetPostCookieFileData.goPostData.Count > 0
        then begin
            OutPutString('<table width="0" border="0" cellspacing="0" cellpadding="3">', false) ;

            for liIndex := 0 to goVarGetPostCookieFileData.goPostData.Count - 1 do
            begin
                lsName := goVarGetPostCookieFileData.goPostData.GiveVarNameByIndex(liIndex) ;
                lsValue := goVarGetPostCookieFileData.goPostData.Give(lsName) ;
                lsValue := showData(lsValue, '', 0) ;
                ReplaceOneOccurence('\n', lsValue, '<br />', true) ;
                putCol(lsName, htmlspecialcharencode(lsValue, 'iso-8859-1', 2, false)) ;
            end ;

            OutPutString('</table>', false) ;
        end ;

        OutPutString('<h2>Cookie variables</h2>', false) ;

        if goVarGetPostCookieFileData.goCookieData.Count > 0
        then begin
            OutPutString('<table width="0" border="0" cellspacing="0" cellpadding="3">', false) ;

            for liIndex := 0 to goVarGetPostCookieFileData.goCookieData.Count - 1 do
            begin
                lsName := goVarGetPostCookieFileData.goCookieData.GiveVarNameByIndex(liIndex) ;
                lsValue := goVarGetPostCookieFileData.goCookieData.Give(lsName) ;
                lsValue := showData(lsValue, '', 0) ;
                ReplaceOneOccurence('\n', lsValue, '<br />', true) ;
                putCol(lsName, htmlspecialcharencode(lsValue, gsDefaultCharset, 2, false)) ;
            end ;

            OutPutString('</table>', false) ;
        end ;

        OutPutString('<h2>File variables</h2>', false) ;

        if goVarGetPostCookieFileData.goFileData.Count > 0
        then begin
            OutPutString('<table width="0" border="0" cellspacing="0" cellpadding="3">', false) ;

            for liIndex := 0 to goVarGetPostCookieFileData.goFileData.Count - 1 do
            begin
                lsName := goVarGetPostCookieFileData.goFileData.GiveVarNameByIndex(liIndex) ;
                lsValue := goVarGetPostCookieFileData.goFileData.Give(lsName) ;
                lsValue := showData(lsValue, '', 0) ;
                lsValue := htmlspecialcharencode(lsValue, gsDefaultCharset, csAllQuoteConversion, false) ;
                
                ReplaceOneOccurence('\n', lsValue, '<br />', true) ;
                putCol(lsName, lsValue) ;
            end ;

            OutPutString('</table>', false) ;
        end ;

        OutPutString('<div><br /><br />Power by <a href="http://www.lazarus.freepascal.org/">Lazarus</a></div>', false) ;        
        OutPutString('</body>', false) ;
        OutPutString('</html>', false) ;

        loListe.Free ;
    end
    else if aoArguments.count < 0
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 0
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure getCfgVarsCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := '' ;
            
        if aoArguments[0] = 'max_execution_time'
        then begin
            gsResultFunction := IntToStr(giElapseTime) ;
        end
        else if aoArguments[0] = 'memory_limit'
        then begin
            gsResultFunction := IntToStr(giMaxMemorySize) ;
        end
        else if aoArguments[0] = 'disabled_function'
        then begin
            gsResultFunction := gsDisabledFunctions ;
        end
        else if aoArguments[0] = 'upload_max_filesize'
        then begin
            gsResultFunction := IntToStr(giUploadMaxFilesize) ;
        end
        else if aoArguments[0] = 'file_uploads'
        then begin
            if (gbFileUpload = True)
            then begin
                gsResultFunction := csTrueValue ;
        end
            else begin
                gsResultFunction := csFalseValue ;
        end ;
        end ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure getFileCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := goVarGetPostCookieFileData.getFile(aoArguments[0]) ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure SetLocalCommande(aoArguments : TStringList) ;
var
    { Liste des valeurs passé en paramètre }
    loListe : TStringList ;
    { Compteur de boucle }
    liIndex : Integer ;
    { Longueur du tableau passé en paramètre }
    liListeLength : Integer ;
begin
    if aoArguments.count = 2
    then begin
        loListe := TStringList.Create ;
        aoArguments[0] := LowerCase(aoArguments[0]) ;

        if aoArguments[0] = 'shortdayname'
        then begin
            if goVariables.InternalIsArray(aoArguments[1])
            then begin
                goVariables.Explode(loListe, aoArguments[1]) ;

                if loListe.Count > 7
                then begin
                    liListeLength := 7 ;
                end
                else begin
                    liListeLength := loListe.Count ;
                end ;

                for liIndex := 0 to liListeLength - 1 do
                begin
                    gaUserShortDayNames[liIndex + 1] := loListe[liIndex] ;
                    ShortDayNames[liIndex + 1] := loListe[liIndex] ;
                end ;
            end
            else begin
                WarningMsg(csMustBeAnArray) ;
        end ;
        end
        else if aoArguments[0] = 'longdayname'
        then begin
            if goVariables.InternalIsArray(aoArguments[1])
            then begin
                goVariables.Explode(loListe, aoArguments[1]) ;

                if loListe.Count > 7
                then begin
                    liListeLength := 7 ;
                end
                else begin
                    liListeLength := loListe.Count ;
        end ;

                for liIndex := 0 to liListeLength - 1 do
                begin
                    LongDayNames[liIndex + 1] := loListe[liIndex] ;
                end ;
            end
            else begin
                WarningMsg(csMustBeAnArray) ;
            end ;
        end
        else if aoArguments[0] = 'shortmonthname'
        then begin
            if goVariables.InternalIsArray(aoArguments[1])
            then begin
                goVariables.Explode(loListe, aoArguments[1]) ;

                if loListe.Count > 12
                then begin
                    liListeLength := 12
                end
                else begin
                    liListeLength := loListe.Count ;
        end ;

                for liIndex := 0 to liListeLength - 1 do
                begin
                    gaUserShortMonthNames[liIndex + 1] := loListe[liIndex] ;
                    ShortMonthNames[liIndex + 1] := loListe[liIndex] ;
                end ;
            end
            else begin
                WarningMsg(csMustBeAnArray) ;
            end ;
        end
        else if aoArguments[0] = 'longmonthname'
        then begin
            if goVariables.InternalIsArray(aoArguments[1])
            then begin
                goVariables.Explode(loListe, aoArguments[1]) ;

                if loListe.Count > 12
                then begin
                    liListeLength := 12
                end
                else begin
                    liListeLength := loListe.Count ;
                end ;

                for liIndex := 0 to liListeLength - 1 do
                begin
                    LongMonthNames[liIndex + 1] := loListe[liIndex] ;
                end ;
            end
            else begin
                WarningMsg(csMustBeAnArray) ;
            end ;
        end
        else if aoArguments[0] = 'floatseparator'
        then begin
            gsFloatSeparator := aoArguments[1] ;
        end
        else if aoArguments[0] = 'millierseparator'
        then begin
            gsMillierSeparator := aoArguments[1] ;
        end
        else if aoArguments[0] = 'charset'
        then begin
            gsDefaultCharset := LowerCase(aoArguments[1]) ;
        end ;

        loListe.Free ;
    end
    else if aoArguments.count < 2
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 2
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure OutputBufferStartCommande(aoArguments : TStringList) ;
Var ListArguments : TStringList ;
begin
    if (aoArguments.count = 0) or (aoArguments.count = 1)
    then begin
        gsResultFunction := csFalseValue ;

        if goListProcedure.Give(aoArguments[0]) <> - 1
        then begin
            ListArguments := TStringList.Create ;
            ListArguments.Text := goListProcedure.GiveArguments(aoArguments[0]) ;

            if ListArguments.Count = 1
            then begin
                gbIsOutPuBuffered := True ;

                if aoArguments.Count > 0
                then begin
                    gsOutPutFunction := aoArguments[0] ;
                end
                else begin
                    gsOutPutFunction := '' ;
        end ;

                gsResultFunction := csTrueValue ;
                ListArguments.Free ;
            end ;
        end ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure OutputBufferWriteCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 0
    then begin
        if (not gbIsHeaderSend)
        then
            SendHeader ;

        write(gsOutPutContent) ;
        gsOutPutContent := '' ;
    end
    else if aoArguments.count > 0
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure OutputBufferClearCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 0
    then begin
        gsOutPutContent := '' ;
    end
    else if aoArguments.count > 0
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure OutputBufferStopCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 0
    then begin
        gbIsOutPuBuffered := False ;
    end
    else if aoArguments.count > 0
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure OutputBufferGetCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 0
    then begin
        gsResultFunction := gsOutPutContent ;
    end
    else if aoArguments.count > 0
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure ShellExecCommande(aoArguments : TStringList) ;
var
    { temps maximal d'exécution de la commande }
    liDelay : integer ;
begin
    if aoArguments.count = 1
    then begin
        liDelay := FloatToInt(SecondSpan(Now, now + (giElapseTime  div (24*3600)))) * 1000 ;

        gsResultFunction := OsShellExec(aoArguments[0], liDelay) ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure Crc32Commande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := IntToStr(CRC32(aoArguments[0])) ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure SleepCommande(aoArguments : TStringList) ;
var
    { Temps d'attente }
    liDelay : Integer ;
begin
    if aoArguments.count = 1
    then begin
        liDelay := MyStrToInt(aoArguments[0]) ;

        if liDelay >= 0
        then begin
            Sleep(liDelay)
    end
        else begin
            WarningMsg(csNotAcceptNegativeValue) ;
    end ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end  ;

procedure bintohexCommande(aoArguments : TStringList) ;
var
    { Index de chaine à convertir }
    liIndex : Integer ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := '' ;

        for liIndex := 1 to Length(aoArguments[0]) do
        begin
            gsResultFunction := gsResultFunction + DecToHex(Byte(aoArguments[0][liIndex])) ;
        end ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end  ;

{*****************************************************************************
 * Rol
 * MARTINEAU Emeric
 *
 * Effectue un rotation logique de bit à gauche
 *
 * Paramètres d'entrée :
 *   - abOctet : octet à transformer,
 *   - aiDecalage : décalage à effectuer,
 *
 * Retour : octet transformé
 *****************************************************************************}
function Rol(abOctet : byte; aiDecalage : integer) : byte ;
var
    { Compteur de décalage }
    liIndex : Integer ;
begin
    Result := abOctet ;
    
    for liIndex := 1 to aiDecalage do
    begin
        Result := (Result shl 1) or ((Result and 128) shr 7) ;
    end ;
end ;

{*****************************************************************************
 * Rol
 * MARTINEAU Emeric
 *
 * Effectue un rotation logique de bit à droite
 *
 * Paramètres d'entrée :
 *   - abOctet : octet à transformer,
 *   - aiDecalage : décalage à effectuer,
 *
 * Retour : octet transformé
 *****************************************************************************}
function Ror(abOctet : byte; aiDecalage : integer) : byte ;
var
    { Compteur de décalage }
    liIndex : Integer ;
begin
    Result := abOctet ;
    
    for liIndex := 1 to aiDecalage do
    begin
        Result := ((Result and 1) shl 7) or (Result shr 1) ;
    end ;
end ;

procedure RolCommande(aoArguments : TStringList) ;
var
    { Octet à décaler }
    liOctet : Integer ;
    { Décalage à éffecter }
    liDecalage : Integer ;
begin
    if (aoArguments.count = 1) or (aoArguments.count = 2)
    then begin
        if IsInteger(aoArguments[0])
        then begin
            liOctet := MyStrToInt(aoArguments[0]) ;
            liDecalage := 1 ;

            if aoArguments.count = 2
            then begin
                if IsInteger(aoArguments[0])
                then begin
                    liDecalage := MyStrToInt(aoArguments[1]) ;
                end
                else begin
                    ErrorMsg(csDecalgeMustBeInteger) ;
                end ;
            end ;

            if liOctet < 256
            then begin
                gsResultFunction := IntToStr(Rol(Byte(liOctet), liDecalage))
            end
            else begin
                ErrorMsg(csMustBeAByte) ;
            end ;
        end
        else begin
            ErrorMsg(csMustBeAByte) ;
        end ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 2
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end  ;

procedure RorCommande(aoArguments : TStringList) ;
var
    { Octet à décaler }
    liOctet : Integer ;
    { Décalage à éffecter }
    liDecalage : Integer ;
begin
    if (aoArguments.count = 1) or (aoArguments.count = 2)
    then begin
        if IsInteger(aoArguments[0])
        then begin
            liOctet := MyStrToInt(aoArguments[0]) ;
            liDecalage := 1 ;

            if aoArguments.count = 2
            then begin
                if IsInteger(aoArguments[0])
                then begin
                    liDecalage := MyStrToInt(aoArguments[1]) ;
                end
                else begin
                    ErrorMsg(csDecalgeMustBeInteger) ;
                end ;
            end ;

            if liOctet < 256
            then begin
                gsResultFunction := IntToStr(Ror(Byte(liOctet), liDecalage))
            end
            else begin
                ErrorMsg(csMustBeAByte) ;
            end ;
        end
        else begin
            ErrorMsg(csMustBeAByte) ;
        end ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 2
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end  ;

procedure Md5Commande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := MD5(aoArguments[0]) ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end  ;

procedure IsSetGetCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if goVarGetPostCookieFileData.IsSetGet(aoArguments[0])
        then begin
            gsResultFunction := csTrueValue ;
        end
        else begin
            gsResultFunction := csFalseValue ;
        end ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end  ;

procedure IsSetPostCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if goVarGetPostCookieFileData.IsSetPost(aoArguments[0])
        then begin
            gsResultFunction := csTrueValue ;
        end
        else begin
            gsResultFunction := csFalseValue ;
        end ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end  ;

procedure IsSetCookieCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if goVarGetPostCookieFileData.IsSetCookie(aoArguments[0])
        then begin
            gsResultFunction := csTrueValue ;
        end
        else begin
            gsResultFunction := csFalseValue ;
        end ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end  ;

procedure IsSetFileCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if goVarGetPostCookieFileData.IsSetFile(aoArguments[0])
        then begin
            gsResultFunction := csTrueValue ;
        end
        else begin
            gsResultFunction := csFalseValue ;
        end ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end  ;

procedure MiscellaneousFunctionsInit ;
begin
    goInternalFunction.Add('header', @headerCommande, true) ;
    goInternalFunction.Add('getget', @getGetCommande, true) ;
    goInternalFunction.Add('getcookie', @getCookieCommande, true) ;
    goInternalFunction.Add('getgetnumber', @getGetNumberCommande, true) ;
    goInternalFunction.Add('getcookienumber', @getCookieCommande, true) ;
    goInternalFunction.Add('getenv', @getenvCommande, true) ;
    goInternalFunction.Add('setcookie', @setCookieCommande, true) ;
    goInternalFunction.Add('swsinfo', @swsinfoCommande, true) ;
    goInternalFunction.Add('getpost', @getpostCommande, true) ;
    goInternalFunction.Add('getpostnumber', @getPostNumberCommande, true) ;
    goInternalFunction.Add('getcfgvars', @getCfgVarsCommande, true) ;
    goInternalFunction.Add('getfile', @getFileCommande, true) ;
    goInternalFunction.Add('setlocal', @setLocalCommande, true) ;
    goInternalFunction.Add('outputbufferstart', @OutputBufferStartCommande, true) ;
    goInternalFunction.Add('outputbufferwrite', @OutputBufferWriteCommande, true) ;
    goInternalFunction.Add('outputbufferclear', @OutputBufferClearCommande, true) ;
    goInternalFunction.Add('outputbufferstop', @OutputBufferStopCommande, true) ;
    goInternalFunction.Add('outputbufferget', @OutputBufferGetCommande, true) ;
    goInternalFunction.Add('shellexec', @ShellExecCommande, true) ;
    goInternalFunction.Add('crc32', @Crc32Commande, true) ;
    goInternalFunction.Add('sleep', @SleepCommande, true) ;
    goInternalFunction.Add('rol', @RolCommande, true) ;
    goInternalFunction.Add('ror', @RorCommande, true) ;
    goInternalFunction.Add('md5', @Md5Commande, true) ;
    goInternalFunction.Add('issetget', @IsSetGetCommande, true) ;
    goInternalFunction.Add('issetpost', @IsSetPostCommande, true) ;
    goInternalFunction.Add('issetcookie', @IsSetCookieCommande, true) ;
    goInternalFunction.Add('issetfile', @IsSetFileCommande, true) ;
end ;

end.
