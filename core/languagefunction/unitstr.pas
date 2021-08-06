unit UnitStr;
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
 *   ECHO
 *   DIE
 *   STRTRIM
 *   STRTRIMLEFT
 *   STRTRIMRIGHT
 *   STRREPLACE
 *   STRDELETE
 *   STRINSERT
 *   STREXPLODE
 *   STRIMPLODE
 *   STRLOADFROMFILE
 *   STRSAVETOFILE
 *   STRADDSLASHES
 *   STRDELETESLASHES
 *   STRPRINTR
 *   STRREPEATSTRING
 *   STRPRINTF
 *   STRBASE64ENCODE
 *   SOUNDEX
 *   UCFIRST
 ******************************************************************************}
interface

{$I config.inc}

{$IFDEF FPC}
    {$mode objfpc}{$H+}
{$ENDIF}

uses classes, Functions, UnitMessages, InternalFunction, Math ;

procedure StrFunctionsInit ;
procedure echoCommande(aoArguments : TStringList) ;
procedure dieCommande(aoArguments : TStringList) ;
procedure strTrimCommande(aoArguments : TStringList) ;
procedure strTrimLeftCommande(aoArguments : TStringList) ;
procedure strTrimRightCommande(aoArguments : TStringList) ;
procedure strReplaceCommande(aoArguments : TStringList) ;
procedure strDeleteCommande(aoArguments : TStringList) ;
procedure strInsertCommande(aoArguments : TStringList) ;
procedure strExplodeCommande(aoArguments : TStringList) ;
procedure strImplodeCommande(aoArguments : TStringList) ;
procedure strLoadFromFileCommande(aoArguments : TStringList) ;
procedure strSaveToFileCommande(aoArguments : TStringList) ;
procedure strAddSlashesCommande(aoArguments : TStringList) ;
procedure strDeleteSlashesCommande(aoArguments : TStringList) ;
procedure strPrintRCommande(aoArguments : TStringList) ;
procedure strRepeatStringCommande(aoArguments : TStringList) ;
procedure strPrintFCommande(aoArguments : TStringList) ;
procedure strBase64EncodeCommande(aoArguments : TStringList) ;
procedure strSoundExCommande(aoArguments : TStringList) ;
procedure strUcFirstCommande(aoArguments : TStringList) ;
procedure struppercaseCommande(aoArguments : TStringList) ;
procedure strlowercaseCommande(aoArguments : TStringList) ;
procedure strUcWordsCommande(aoArguments : TStringList) ;
procedure striReplaceCommande(aoArguments : TStringList) ;
procedure striposCommande(aoArguments : TStringList) ;
procedure strrposCommande(aoArguments : TStringList) ;
procedure strriposCommande(aoArguments : TStringList) ;
procedure strtrCommande(aoArguments : TStringList) ;
procedure strrevCommande(aoArguments : TStringList) ;
procedure strcspnCommande(aoArguments : TStringList) ;
procedure strspnCommande(aoArguments : TStringList) ;
procedure strReplaceAccentCommande(aoArguments : TStringList) ;
procedure strNumberFormatCommande(aoArguments : TStringList) ;
procedure printfCommande(aoArguments : TStringList) ;
procedure strEmptyCommande(aoArguments : TStringList) ;
procedure strLeftCommande(aoArguments : TStringList) ;
procedure strRightCommande(aoArguments : TStringList) ;
procedure strStartWithCommande(aoArguments : TStringList) ;
procedure strEndWithCommande(aoArguments : TStringList) ;

procedure configParameter(var aiStart : integer; var aiLength : integer; var aoSearch : TStringList; aoArguments : TStringList) ;
procedure strposGlobalCommande(aoArguments : TStringList; lbCaseSensitive : Boolean; lbStartEnd : Boolean) ;
procedure strReplaceGlobalCommande(aoArguments : TStringList; lbCaseSensitive : Boolean) ;
function Encode64(asString : string): string;
function Decode64(asString: string): string;
function Soundex(asString : String) : String ;
function UpperChar(acChar : Char) : Char ;
function ReplaceAccent(asStr : string) : string ;

implementation

uses Code, SysUtils, Variable ;

const
    Code64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

{*****************************************************************************
 * Encode64
 * MARTINEAU Emeric
 *
 * Convertit une chaine binaire en Base64
 *
 * Paramètres d'entrée :
 *   - asString : chaine à convertir
 *
 * Retour : valeur sous forme base64
 *****************************************************************************}
function Encode64(asString: string): string;
var
    { Chaine à encoder }
    lsTmp : string ;
    { Compteur de boucle }
    liIndex : Integer ;

    function Block64Encode(asString : string) : string ;
    var liLength : SmallInt ;
        liIndex : Cardinal ;
    begin
        { Par défaut si on n'a rien, on retourne des = }
        Result := '====' ;
        liLength := Length(asString) ;
        liIndex := 1 ;

        if liLength > 0
        then begin
            Result[1] := Code64[(Ord(asString[1]) shr 2) + 1 ] ;
            liIndex := (Ord(asString[1]) and 3) shl 4 ;
            Result[2] := Code64[ liIndex + 1 ] ;
        end ;

        if liLength > 1
        then begin
            liIndex := liIndex + (Ord(asString[2]) shr 4) ;
            Result[2] := Code64[ liIndex + 1 ] ;
            liIndex := (Ord(asString[2]) and 15) shl 2 ;
            Result[3] := Code64[ liIndex + 1 ] ;
        end ;

        if liLength > 2
        then begin
            liIndex := liIndex + (Ord(asString[3]) shr 6) ;

            Result[3] := Code64[ liIndex + 1 ] ;
            Result[4] := Code64[(Ord(asString[3]) and 63) + 1] ;
        end ;
    end ;
begin
    Result := '' ;
    lsTmp := '' ;

    for liIndex := 1 to Length(asString) do
    begin
        if (liIndex mod 3) = 0
        then begin
            lsTmp := lsTmp + asString[liIndex] ;
            { On encode par paquet de 3 carctères }
            Result := Result + Block64Encode(lsTmp) ;
            lsTmp := '' ;
        end
        else begin
            lsTmp := lsTmp + asString[liIndex] ;
        end ;
    end ;

    if lsTmp <> ''
    then begin
        Result := Result + Block64Encode(lsTmp) ;
    end ;
end ;

{*****************************************************************************
 * Encode64
 * MARTINEAU Emeric
 *
 * Convertit une chaine Base64 en chaine binaire
 *
 * Paramètres d'entrée :
 *   - asString : chaine à convertir
 *
 * Retour : valeur sous forme binaire
 *****************************************************************************}
function Decode64(asString : String) : String ;
var
    { Chaine décodée }
    lsTmp : String ;
    { Compteur de boucle }
    liIndex : Integer ;

    function GetValueOfBase64(lcChar : char) : SmallInt ;
    var liIndex : SmallInt ;
    begin
        Result := 0 ;

        for liIndex := 1 to length(Code64) do
        begin
            if lcChar = Code64[liIndex]
            then begin
                Result := liIndex - 1 ;
                break ;
            end ;
        end ;
    end ;

    function Block64Decode(asString : String) : String ;
    var liIndex : Integer ;
        liLength : Integer ;
    begin
        Result := '' ;
        liLength := Length(asString) ;

        if liLength > 0
        then begin
            if asString[1] <> '='
            then begin
                liIndex := GetValueOfBase64(asString[1]) ;
                liIndex := liIndex shl 2 ;
                Result := char( liIndex ) ;
            end ;
        end ;

        if liLength > 1
        then begin
            if asString[2] <> '='
            then begin
                if Length(Result) > 0
                then begin
                    liIndex := GetValueOfBase64(asString[2]) shr 4 ;
                    Result[1] := Char(Ord(Result[1]) + liIndex) ;
                end ;

                liIndex := GetValueOfBase64(asString[2]) shl 4 ;
                Result := Result + char( liIndex ) ;
            end ;
        end ;

        if liLength > 2
        then begin
            if asString[3] <> '='
            then begin
                if Length(Result) > 1
                then begin
                    liIndex := GetValueOfBase64(asString[3]) shr 2 ;
                    Result[2] := Char(Ord(Result[2]) + liIndex) ;
                end ;

                liIndex := GetValueOfBase64(asString[3]) shl 6 ;

                Result := Result + char( liIndex ) ;
            end ;
        end ;

        if liLength > 3
        then begin
            if asString[4] <> '='
            then begin
                if Length(Result) > 2
                then begin
                    liIndex := GetValueOfBase64(asString[4]) ;
                    Result[3] := Char(Ord(Result[3]) + liIndex) ;
                end ;
            end ;
        end ;
    end ;
begin
    Result := '' ;
    lsTmp := '' ;

    for liIndex := 1 to Length(asString) do
    begin
        if (liIndex mod 4) = 0
        then begin
            lsTmp := lsTmp + asString[liIndex] ;
            { On décode par paquet de 4 caractères }
            Result := Result + Block64Decode(lsTmp) ;
            lsTmp := '' ;
        end
        else begin
            lsTmp := lsTmp + asString[liIndex] ;
        end ;
    end ;

    if lsTmp <> ''
    then begin
        Result := Result + Block64Decode(lsTmp) ;
    end ;
end ;

{*****************************************************************************
 * Soundex
 * MARTINEAU Emeric
 *
 * Convertit une chaine en équivalent soundex
 *
 * Paramètres d'entrée :
 *   - asString : chaine à traiter
 *
 * Retour : chaine soundex
 *****************************************************************************}
function Soundex(asString : String) : String ;
const soundex_table : array[0..25] of char =
    (#0,   // A
     '1',  // B
     '2',  // C
     '3',  // D
     #0,   // E
     '1',  // F
     '2',  // G
     #0,   // H
     #0,   // I
     '2',  // J
     '2',  // K
     '4',  // L
     '5',  // M
     '5',  // N
     #0,   // O
     '1',  // P
     '2',  // Q
     '6',  // R
     '2',  // S
     '3',  // T
     #0,   // U
     '1',  // V
     #0,   // W
     '2',  // X
     #0,   // Y
     '2'); // Z

var
    { Compteur de boucle }
    liIndex : Integer ;
    { Caractère à traiter }
    lcChar : Char ;
    { Position du caractère dans le tableau de résultat }
    liPosInResult : SmallInt ;
    { Dernier caractère traiter }
    lcLastChar : Char ;
    { Resultat 4 caractères  }
    laResultat : array[0..3] of char ;
begin
    Result := '' ;
    liPosInResult := 0 ;
    lcLastChar := #0 ;

    for liIndex := 0 to High(laResultat) do
    begin
        laResultat[liIndex] := #0 ;
    end ;

    asString := UpperCase(asString) ;

    for liIndex := 1 to Length(asString) do
    begin
        lcChar := asString[liIndex] ;

        { on ne prend en compte que les lettres. C'est idiot car la langue
          française par exemple contient des caractères spéciaux }
        if lcChar in ['A'..'Z']
        then begin
            if liPosInResult = 0
            then begin
                laResultat[liPosInResult] := lcChar ;
                Inc(liPosInResult) ;
                lcLastChar := soundex_table[Ord(lcChar) - Ord('A')] ;
            end
            else begin
                lcChar := soundex_table[Ord(lcChar) - Ord('A')] ;

                if (lcChar <> lcLastChar)
                then begin
                    if lcChar <> #0
                    then begin
                        laResultat[liPosInResult] := lcChar;
                        Inc(liPosInResult) ;
                    end ;
                end ;
            end ;
        end ;
    end ;

    Result := '' ;

    for liIndex := 0 to 3 do
    begin
        if laResultat[liIndex] <> #0
        then begin
            Result := Result + laResultat[liIndex] ;
        end
        else begin
            Result := Result + '0' ;
        end ;
    end ;
end ;

{*****************************************************************************
 * UpperChar
 * MARTINEAU Emeric
 *
 * Convertit un caractère en majuscule et retourne un caractère
 *
 * Paramètres d'entrée :
 *   - acChar : caractère à traiter
 *
 * Retour : caractère en majuscule
 *****************************************************************************}
function UpperChar(acChar : Char) : Char ;
var lsTmp : String ;
begin
    lsTmp := AnsiUpperCase(acChar) ;
    Result := lsTmp[1] ;
end ;

procedure echoCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count <= 1
    then begin
        if aoArguments.count <> 0
        then begin
            OutPutString(aoArguments[0], false) ;
        end ;
    end
    else begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

{*****************************************************************************
 * ReplaceAccent
 * MARTINEAU Emeric
 *
 * Remplace les caractères accentués dans une chaine
 *
 * Paramètres d'entrée :
 *   - asStr           : chaine à dans laquel il faut chercher
 *
 * Retour : chaine dont les accents sont convertit
 *****************************************************************************}
function ReplaceAccent(asStr : string) : string ;
const csAccent : String = 'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûýýþÿ' ;
      csNoAccent : String = 'AAAAAAACEEEEIIIIDNOOOOOOUUUUYbsaaaaaaaceeeeiiiidnoooooouuuyyby' ;
var
    { Compteur de boucle }
    liIndex : Integer ;
    { Position du caractère }
    liPosition : Integer ;
begin
    Result := '' ;

    for liIndex := 1 to length(asStr) do
    begin
        liPosition := Pos(asStr[liIndex], csAccent);

        if liPosition = 0
        then begin
            Result := Result + asStr[liIndex] ;
        end
        else begin
            Result := Result + csNoAccent[liPosition] ;
        end ;
    end ;
end ;

procedure dieCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count <= 1
    then begin
        if aoArguments.count <> 0
        then begin
            OutPutString(aoArguments[0], false) ;
        end ;

        gbQuit := True ;
    end
    else begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure struppercaseCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := AnsiUpperCase(aoArguments[0]) ;
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

procedure strlowercaseCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := AnsiLowerCase(aoArguments[0]) ;
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

procedure strcopyCommande(aoArguments : TStringList) ;
var
    { Position de départ }
    liStartPos : Integer ;
    { Longueur à copier }
    liLength : Integer ;
begin
    if (aoArguments.count = 2) or (aoArguments.count = 3)
    then begin
        liStartPos := MyStrToInt(aoArguments[1]) + 1 ;
        
        if aoArguments.count = 3
        then begin
            liLength := MyStrToInt(aoArguments[2]) ;
        end
        else begin
            liLength := Length(aoArguments[0]) ;
        end ;

        if liStartPos < 0
        then begin
            ErrorMsg(csStartValNotValidNum)
        end
        else if liLength < 0
        then begin
            ErrorMsg(csEndValNotValidNum)
        end
        else begin
            gsResultFunction := Copy(aoArguments[0], liStartPos, liLength - liStartPos) ;
        end ;
    end
    else if aoArguments.count < 2
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 3
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure strposCommande(aoArguments : TStringList) ;
begin
    strposGlobalCommande(aoArguments, true, false) ;
end ;

procedure striposCommande(aoArguments : TStringList) ;
begin
    strposGlobalCommande(aoArguments, false, false) ;
end ;

procedure strrposCommande(aoArguments : TStringList) ;
begin
    strposGlobalCommande(aoArguments, true, true) ;
end ;

procedure strriposCommande(aoArguments : TStringList) ;
begin
    strposGlobalCommande(aoArguments, false, true) ;
end ;

{*****************************************************************************
 * strposGlobalCommande
 * MARTINEAU Emeric
 *
 * Recherche une sous-chaine dans une chaine.
 * Appel PosrString() ou PosString()
 *
 * Paramètres d'entrée :
 *   - aoArguments : aoArguments passé en commande depuis le script,
 *   - lbCaseSensitive : doit-on être sensible à la case,
 *   - lbStartEnd : indique s'il faut commencer par la fin,
 *
 *****************************************************************************}
procedure strposGlobalCommande(aoArguments : TStringList; lbCaseSensitive : Boolean; lbStartEnd : Boolean) ;
var
    { Position à laquelle il faut commencer }
    liIndex : Integer ;
begin
    if (aoArguments.count > 1) and (aoArguments.count < 4)
    then begin
        if aoArguments.count = 3
        then begin
            if isInteger(aoArguments[2])
            then begin
                liIndex := MyStrToInt(aoArguments[2]) + 1 ;
            end
            else begin
                liIndex := 1 ;
            end ;
        end
        else begin
            if lbStartEnd
            then begin
                liIndex := Length(aoArguments[1]) ;
            end
            else begin
                liIndex := 1 ;
            end ;
        end ;

        if liIndex > 0
        then begin
            if lbStartEnd
            then begin
                gsResultFunction := IntToStr(PosrString(aoArguments[0], aoArguments[1], liIndex, lbCaseSensitive) - 1) ;
            end
            else begin
                gsResultFunction := IntToStr(PosString(aoArguments[0], aoArguments[1], liIndex, lbCaseSensitive) - 1) ;
            end ;
        end
        else begin
            ErrorMsg(csInvalidIndex) ;
        end ;
    end
    else if aoArguments.count < 2
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 3
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure strTrimCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := Trim(aoArguments[0]) ;
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

procedure strTrimLeftCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := TrimLeft(aoArguments[0]) ;
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

procedure strTrimRightCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := TrimRight(aoArguments[0]) ;
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

procedure strReplaceCommande(aoArguments : TStringList) ;
begin
    strReplaceGlobalCommande(aoArguments, true) ;
end ;

procedure striReplaceCommande(aoArguments : TStringList) ;
begin
    strReplaceGlobalCommande(aoArguments, false) ;
end ;

{*****************************************************************************
 * strReplaceGlobalCommande
 * MARTINEAU Emeric
 *
 * Remplace une sous-chaine dans une chaine.
  *
 * Paramètres d'entrée :
 *   - aoArguments : aoArguments passé en commande depuis le script,
 *   - lbCaseSensitive : doit-on être sensible à la case,
 *
 *****************************************************************************}
procedure strReplaceGlobalCommande(aoArguments : TStringList; lbCaseSensitive : Boolean) ;
var
    { Position du dernier argument }
    liPositionDernierArgument : integer ;
    { Variable script recevant le nombre de d'occurence remplacée }
    lsCountVar : string ;
    { Nombre d'occurence remplacée }
    lcCount : Cardinal ;
    { Chaine à rechercher }
    lsSubStr : String ;
    { Chaine à lire }
    lsStr : String ;
    { Chaine de remplacement }
    lsReplaceStr : String ;
    { Liste d'élément à remplacer }
    loListeAREmplacer : TStringList ;
begin
    // strReplace(substr, str, replacetext [, $count])
    if (aoArguments.count > 2)
    then begin
        { Le dernier élément peut contenir le compteur }
        liPositionDernierArgument := aoArguments.count - 1 ;
        lcCount := 0 ;
        lsCountVar := aoArguments[liPositionDernierArgument] ;

        if isVar(lsCountVar)
        then begin
            { On efface la variable pour ne pas avoir l'affichage comme quoi la
              variable n'existe pas.
              On ne supprime SURTOUT pas aoArguments[Position] car cela permet de
              vérifier le nombre total d'arguement }
            aoArguments[liPositionDernierArgument] := '' ;
        end
        else begin
            lsCountVar := ''
        end ;

        { Parse les données }
        GetValueOfStrings(aoArguments) ;

        if (aoArguments.count = 4) and (lsCountVar = '')
        then begin
            ErrorMsg(Format(csNotAVariable, [lsCountVar])) ;
        end
        else if (aoArguments.count > 4)
        then begin
            ErrorMsg(csTooArguments) ;
        end
        else begin
            { Est un tableau ou une chaine }
            lsSubStr := aoArguments[0] ;
            lsStr := aoArguments[1] ;
            lsReplaceStr := aoArguments[2] ;

            if goVariables.InternalisArray(lsSubStr)
            then begin
                loListeAREmplacer := TStringList.Create() ;
                goVariables.explode(loListeAREmplacer, lsSubStr);

                if loListeAREmplacer.Count > 0
                then begin
                    for liPositionDernierArgument := 0 to loListeAREmplacer.Count - 1 do
                    begin
                        lcCount := lcCount + ReplaceOneOccurence(loListeAREmplacer[liPositionDernierArgument], lsStr, lsReplaceStr, lbCaseSensitive) ;
                    end ;
                end ;

                FreeAndNil(loListeAREmplacer) ;
            end
            else begin
               lcCount := lcCount + ReplaceOneOccurence(lsSubstr, lsStr, lsReplaceStr, lbCaseSensitive) ;
            end ;

            gsResultFunction := lsStr ;

            if lsCountVar <> ''
            then begin
                goVariables.Add(lsCountVar, IntToStr(lcCount));
            end ;
        end ;
    end
    else if aoArguments.count < 2
    then begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure strInsertCommande(aoArguments : TStringList) ;
var
    { Postion où insérer le text }
    liStartPos : Integer ;
    { Variable temporaire de résultat }
    lsTmp : string ;
begin
    if aoArguments.count = 3
    then begin
        liStartPos := MyStrToInt(aoArguments[2]) + 1 ;

        if liStartPos >= 0
        then begin
            lsTmp := aoArguments[1] ;
            Insert(aoArguments[0], lsTmp, liStartPos) ;
            gsResultFunction := lsTmp ;
        end
        else begin
            ErrorMsg(csInvalidIndex) ;
        end ;
    end
    else if aoArguments.count < 3
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 3
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure strDeleteCommande(aoArguments : TStringList) ;
var
    { Position de départ }
    liStart : Integer ;
    { Longueur à supprimer }
    liLength : Integer ;
    { Variable temporaire pour supprimer les caractère }
    lsTmp : string ;
begin
    if aoArguments.count = 3
    then begin
        liStart := MyStrToInt(aoArguments[1]) + 1 ;
        liLength := MyStrToInt(aoArguments[2]) ;

        if aoArguments.count = 3
        then begin
            liLength := MyStrToInt(aoArguments[2]) ;
        end
        else begin
            liLength := Length(aoArguments[0]) ;
        end ;

        if liStart < 0
        then begin
            ErrorMsg(csStartValNotValidNum)
        end
        else if liLength < 0
        then begin
            ErrorMsg(csEndValNotValidNum)
        end
        else begin
            lsTmp := aoArguments[0] ;
            Delete(lsTmp, liStart, liLength) ;
            gsResultFunction := lsTmp ;
        end ;
    end
    else if aoArguments.count < 3
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 3
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure strExplodeCommande(aoArguments : TStringList) ;
var
    { Tableau recevant la liste des chaines }
    loTableau : TStringList ;
begin
    if aoArguments.count = 2
    then begin
        loTableau := TStringList.Create ;

        Explode(aoArguments[1], loTableau, aoArguments[0]) ;

        gsResultFunction := goVariables.CreateArray(loTableau) ;

        FreeAndNil(loTableau) ;
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

procedure strImplodeCommande(aoArguments : TStringList) ;
var 
    { Recoit les éléments à regrouper }
    loTableau : TStringList ;
    { Index du tableau }
    liIndexTableau : Integer ;
begin
    if aoArguments.count = 2
    then begin
        loTableau := TStringList.Create ;
        goVariables.explode(loTableau, aoArguments[1]);

        gsResultFunction := '' ;

        for liIndexTableau := 0 to loTableau.Count -1 do
        begin
            gsResultFunction := gsResultFunction + loTableau[liIndexTableau] ;

            { Si c'est le dernier éléments, on ne met pas de séparateur }
            if liIndexTableau <> (loTableau.Count - 1)
            then begin
                gsResultFunction := gsResultFunction + aoArguments[0] ;
            end ;
        end ;

        FreeAndNil(loTableau) ;
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

procedure strLoadFromFileCommande(aoArguments : TStringList) ;
var
    { Contient le fichier à mettre en tableau }
    loTableau : TStringList ;
    { Indique s'il y a une erreur }
    lbError : Boolean ;
begin
    if aoArguments.count = 1
    then begin
        lbError := False ;
        aoArguments[0] := RealPath(aoArguments[0]) ;

        { Vérifie l'inclusion du fichier si on est en safe mode }
        if (gbSafeMode = True) and (gsDocRoot <> '')
        then begin
            if Pos(gsDocRoot, aoArguments[0]) = 0
            then begin
                lbError := True ;
                WarningMsg(csCantDoThisInSafeMode) ;
            end ;
        end ;

        if not lbError
        then begin
            loTableau := TStringList.Create ;

            loTableau.LoadFromFile(aoArguments[0]);

            gsResultFunction := goVariables.CreateArray(loTableau) ;

            FreeAndNil(loTableau) ;
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

procedure strSaveToFileCommande(aoArguments : TStringList) ;
var
    { Contient le tableau à mettre en fichier }
    loTableau : TStringList ;
    { Indique s'il y a eu une erreur }
    lbError : Boolean ;
begin
    if aoArguments.count = 2
    then begin
        lbError := False ;
        aoArguments[1] := RealPath(aoArguments[1]) ;
        gsResultFunction := csFalseValue ;

        { Vérifie l'inclusion du fichier si on est en safe mode }
        if (gbSafeMode = True) and (gsDocRoot <> '')
        then begin
            if Pos(gsDocRoot, aoArguments[1]) = 0
            then begin
                lbError := True ;
                WarningMsg(csCantDoThisInSafeMode) ;
            end ;
        end ;

        if not lbError
        then begin
            loTableau := TStringList.Create ;

            goVariables.explode(loTableau, aoArguments[0]);

            {$I-}
            loTableau.SaveToFile(aoArguments[1]) ;
            {$I+}

            if IOResult = 0
            then begin
                gsResultFunction := csTrueValue ;
            end ;
                
            FreeAndNil(loTableau) ;
        end ;
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

procedure strAddSlashesCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := AddSlashes(aoArguments[0]);
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

procedure strDeleteSlashesCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := DeleteSlashes(aoArguments[0]) ;
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

procedure strPrintRCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isVar(aoArguments[0])
        then begin
            OutPutString(showData(getVar(aoArguments[0]), '', 0), true) ;
        end
        else begin
            ErrorMsg(Format(csNotAVariable, [aoArguments[0]])) ;
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

procedure strRepeatStringCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 2
    then begin
        if isInteger(aoArguments[1])
        then
            gsResultFunction := RepeterCaractere(aoArguments[0], MyStrToInt(aoArguments[1]))
        else
            ErrorMsg(csSizeMustBeInt) ;
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

{ ** ATTENTION ** strPrintf est une des fonctions, sinon la fonction, la plus compliquer.
  Il m'a fallu plusieurs jour pour l'écrire. Bon courrage à ceux qui veulent la comprendre }
procedure strPrintFCommande(aoArguments : TStringList) ;
var
    { Chiffre debut et fin f8.2d }
    liLongueurDebut : Int64 ;
    liLongueurFin : Int64 ;
    { Contient le caractère d'espacement peut être 0 ou espace }
    lsEspacement : String ;
    { Contient le caractère de remplissage peut être 0 ou espace }
    lsRemplissage : String ;
    { Indique s'il faut aligner à droite }
    lbAlignerAGauche : Boolean ;
    { Indique le type de donnée }
    lsTypeData : String ;
    { Indique si le nombre est negatif }
    lbIsNeg : Boolean ;
    { Indique l'indice si c'est + au - }
    lsIndice : String ;
    { Force l'affichage du signe }
    lbForceSign : Boolean ;
    { Ajoute des éléments devant e.g. 0x devant l'hexa }
    lbAddBefore : Boolean ;
    { Index de la chaine template à traiter }
    liIndexChaineATraiter : Integer ;
    { Index de départ, pour savoir si la chaine à avancé }
    liAvancementIndex : Integer ;
    { Taille du template }
    liLengthChaineATraiter : Integer ;
    { Pointe sur les aoArguments à afficher. Commence à 1 car aoArguments[0] contient
      le template }
    liIndexArgument : Integer ;
    { Chaine de formatage de l'affichage (ex : "%8.2f" }
    lsTextTemplate : string ;
    { Indique le nombre d'agrument à afficher }
    liMaxArgs : Integer ;
    { Variable temporaire }
    lsTmp : String ;
    lsTmp2 : String ;
    lsTmp3 : String ;
    { Permet de savoir si on a une partie fractionnaire }
    lfTmpFloat : Extended ;
    { Permet d'obtenir la partie entière }
    liTmpInt : Integer ;
    
    { Retoure le chiffre sous aiCurrentIndex }
    function GetNumberOfElement(asText : String; var aiCurrentIndex : Integer) : Int64 ;
    var
        { Taille de la chaine passée en paramètre }
        liTextLength : Integer ;
        { Fin du chiffre }
        liFin : Integer ;
        { Début du chiffre }
        liDebut : Integer ;
    begin
        liTextLength := Length(asText) ;
        liFin := 0 ;
        
        { 1 - Récupère le numéro d'argument à afficher }
        liDebut := aiCurrentIndex ;

        while aiCurrentIndex <= liTextLength do
        begin
            OverTimeAndMemory ;
            
            if gbQuit
            then begin
                break ;
            end ;

            if not (asText[aiCurrentIndex] in ['0'..'9'])
            then begin
                liFin := aiCurrentIndex ;
                break ;
            end ;

            Inc(aiCurrentIndex) ;
        end ;

        if liFin - liDebut > 0
        then begin
            Result := MyStrToInt(Copy(asText, liDebut, liFin - liDebut)) ;
        end
        else begin
            Result := 0 ;
        end ;
    end ;

    { Ajoute le signe à une chaine représentant un nombre. S'il y a un remplissage devant,
      ajoute insert le signe au début, sinon, l'ajoute }
    function SetSign(asText : string; isNeg : Boolean; aiLongueurDebut : Integer; lsRemplissage : String) : string ;
    var
        { Index de chaine }
        liIndex : Integer ;
    begin
        if aiLongueurDebut > 0
        then begin
            { position le - au premier espace trouvé }
            for liIndex := Length(asText) downto 1 do
            begin
                if asText[liIndex] = lsRemplissage
                then begin
                    if isNeg
                    then begin
                        asText[liIndex] := '-'
                    end
                    else begin
                        asText[liIndex] := '+' ;
                    end ;

                    break ;
                end
                else begin
                    { si aucun remplissage n'est trouvé il faut alors
                      ajouter le moins devant }
                    if liIndex = 1
                    then begin
                        if isNeg
                        then begin
                            asText := asText + '-' ;
                        end
                        else begin
                            asText := asText + '+' ;
                        end ;
                    end ;
               end ;
            end ;
        end
        else begin
            if isNeg
            then begin
                asText := '-' + asText ;
            end
            else begin
                asText := '+' + asText ;
            end ;
        end ;

        Result := asText ;
    end ;
begin
    if aoArguments.count > 1
    then begin
        { Nombre maximum d'argument passé en paramètre. - 1 car le premier
          élément est la chaine }
        liMaxArgs := aoArguments.Count - 1 ;

        liIndexChaineATraiter := 1 ;

        { index pointe sur l'élément à convertir. 1 Car 0 contient la chaine à
          afficher }
        liIndexArgument := 1 ;

        liLengthChaineATraiter := Length(aoArguments[0]) ;
        lsTextTemplate := aoArguments[0] ;

        while liIndexChaineATraiter <= liLengthChaineATraiter do
        begin
            OverTimeAndMemory ;

            if gbQuit
            then begin
                break ;
            end ;

            { Si on a un % c'est qu'on doit convertir une données }
            if lsTextTemplate[liIndexChaineATraiter] = '%'
            then begin
                if (liLengthChaineATraiter - liIndexChaineATraiter) > 0
                then begin
                    Inc(liIndexChaineATraiter) ;

                    if lsTextTemplate[liIndexChaineATraiter] <> '%'
                    then begin
                        if (lsTextTemplate[liIndexChaineATraiter] = '+')
                        then begin
                            lbForceSign := True ;
                            Inc(liIndexChaineATraiter) ;
                        end
                        else begin
                            lbForceSign := False ;
                        end ;

                        if (lsTextTemplate[liIndexChaineATraiter] = '#')
                        then begin
                            lbAddBefore := True ;
                        end
                        else begin
                            lbAddBefore := False ;
                        end ;

                        { Espacement }
                        if (lsTextTemplate[liIndexChaineATraiter] = ' ') or (lsTextTemplate[liIndexChaineATraiter] = '0') or (lsTextTemplate[liIndexChaineATraiter] = '''')
                        then begin
                            if (lsTextTemplate[liIndexChaineATraiter] = '''')
                            then begin
                                Inc(liIndexChaineATraiter) ;
                            end ;

                            lsEspacement := lsTextTemplate[liIndexChaineATraiter] ;
                            Inc(liIndexChaineATraiter) ;
                        end
                        else begin
                            lsEspacement := ' ' ;
                        end ;

                        { Remplissage }
                        if (lsTextTemplate[liIndexChaineATraiter] = ' ') or (lsTextTemplate[liIndexChaineATraiter] = '0') or (lsTextTemplate[liIndexChaineATraiter] = '''')
                        then begin
                            if (lsTextTemplate[liIndexChaineATraiter] = '''')
                            then begin
                                Inc(liIndexChaineATraiter) ;
                            end ;

                            lsRemplissage := lsTextTemplate[liIndexChaineATraiter] ;
                            Inc(liIndexChaineATraiter) ;
                        end
                        else begin
                            lsRemplissage := ' ' ;
                        end ;

                        if lsTextTemplate[liIndexChaineATraiter] = '-'
                        then begin
                            lbAlignerAGauche := True ;
                            Inc(liIndexChaineATraiter) ;
                        end
                        else begin
                            lbAlignerAGauche := False ;
                        end ;

                        { Longueur de début }
                        liAvancementIndex := liIndexChaineATraiter ;
                        liLongueurDebut := GetNumberOfElement(lsTextTemplate, liIndexChaineATraiter) ;

                        { Si le pointeur de chaine n'a pas avancé }
                        if liIndexChaineATraiter = liAvancementIndex
                        then begin
                            if lsTextTemplate[liIndexChaineATraiter] = '*'
                            then begin
                                liLongueurDebut := MyStrToInt(aoArguments[liIndexArgument]) ;
                                Inc(liIndexArgument) ;
                                Inc(liIndexChaineATraiter) ;
                            end ;
                        end ;

                        liLongueurFin := 6 ;

                        { Est-ce un point ? }
                        if lsTextTemplate[liIndexChaineATraiter] = '.'
                        then begin
                            Inc(liIndexChaineATraiter) ;

                            { Longueur de fin }
                            liAvancementIndex := liIndexChaineATraiter ;
                            liLongueurFin := GetNumberOfElement(lsTextTemplate, liIndexChaineATraiter) ;

                            { Si le pointeur de chaine n'a pas avancé }
                            if liIndexChaineATraiter = liAvancementIndex
                            then begin
                                if lsTextTemplate[liIndexChaineATraiter] = '*'
                                then begin
                                    liLongueurFin := MyStrToInt(aoArguments[liIndexArgument]) ;
                                    Inc(liIndexArgument) ;
                                    Inc(liIndexChaineATraiter) ;
                                end ;
                            end ;
                        end ;

                        lsTypeData := lsTextTemplate[liIndexChaineATraiter] ;

                        if liIndexArgument <= liMaxArgs
                        then begin
                            if lsTypeData = 'u'
                            then begin
                                lsTypeData := 'd' ;

                                if isInteger(aoArguments[liIndexArgument])
                                then begin
                                    lsTmp := aoArguments[liIndexArgument] ;

                                    if lsTmp <> ''
                                    then begin
                                        if lsTmp[1] = '-'
                                        then begin
                                            aoArguments[liIndexArgument] := copy(lsTmp, 2, length(lsTmp) - 1) ;
                                        end ;
                                    end ;
                                end ;
                            end ;

                            if lsTypeData = 'c'
                            then begin
                                if isInteger(aoArguments[liIndexArgument])
                                then begin
                                    gsResultFunction := gsResultFunction + Chr(MyStrToInt(aoArguments[liIndexArgument])) ;
                                end ;
                            end
                            else if lsTypeData = 'd'
                            then begin
                                if isFloat(aoArguments[liIndexArgument])
                                then begin
                                    lsTmp := extractIntPart(aoArguments[liIndexArgument]) ;

                                    if lbAlignerAGauche
                                    then begin
                                        if lbForceSign
                                        then begin
                                            if lsTmp[1] <> '-'
                                            then begin
                                                lsTmp := '+' + lsTmp ;
                                            end ;
                                        end ;

                                        lsTmp := lsTmp + RepeterCaractere(lsEspacement, liLongueurDebut - Length(lsTmp))
                                    end
                                    else begin
                                        lbIsNeg := False ;

                                        if lsTmp <> ''
                                        then begin
                                            if lsTmp[1] = '-'
                                            then begin
                                                lbIsNeg := True ;
                                                lsTmp := copy(lsTmp, 2, length(lsTmp) - 1) ;
                                            end ;
                                        end ;

                                        lsTmp := RepeterCaractere(lsRemplissage, liLongueurDebut - Length(lsTmp)) + lsTmp ;

                                        if lbIsNeg or lbForceSign
                                        then begin
                                            lsTmp := SetSign(lsTmp, lbIsNeg, liLongueurDebut, lsRemplissage) ;
                                        end ;
                                    end ;

                                    gsResultFunction := gsResultFunction + lsTmp ;
                                end
                            end
                            else if lsTypeData = 'f'
                            then begin
                                if isFloat(aoArguments[liIndexArgument])
                                then begin
                                    lsTmp := extractIntPart(aoArguments[liIndexArgument]) ;
                                    lsTmp2 := extractFloatPart(aoArguments[liIndexArgument]) ;

                                    { Tronque la partie flottante }
                                    if liLongueurFin > 0
                                    then
                                        lsTmp2 := '.' + Copy(lsTmp2, 1, liLongueurFin)
                                    else
                                        { si la précision est à 0 on n'affiche même pas le . }
                                        lsTmp2 := '' ;

                                    if Length(lsTmp2) < liLongueurFin
                                    then begin
                                        lsTmp2 := lsTmp2 + RepeterCaractere('0', liLongueurFin - Length(lsTmp2)) ;
                                    end ;

                                    if lbAlignerAGauche
                                    then begin
                                        if lbForceSign
                                        then begin
                                            if lsTmp[1] <> '-'
                                            then begin
                                                lsTmp := '+' + lsTmp ;
                                            end ;
                                        end ;

                                        lsTmp := lsTmp + lsTmp2 + RepeterCaractere(lsRemplissage, liLongueurDebut - Int64((length(lsTmp)) + Int64(length(lsTmp2))))
                                    end
                                    else begin
                                        lbIsNeg := False ;

                                        if lsTmp <> ''
                                        then begin
                                            if lsTmp[1] = '-'
                                            then begin
                                                lbIsNeg := True ;
                                                lsTmp := copy(lsTmp, 2, length(lsTmp) - 1) ;
                                            end ;
                                        end ;

                                        lsTmp := RepeterCaractere(lsRemplissage, liLongueurDebut - Length(lsTmp) - Length(lsTmp2)) + lsTmp + lsTmp2 ;

                                        if lbIsNeg or lbForceSign
                                        then begin
                                            lsTmp := SetSign(lsTmp, lbIsNeg, liLongueurDebut, lsRemplissage) ;
                                        end ;
                                    end ;

                                    gsResultFunction := gsResultFunction + lsTmp ;
                                end ;
                            end
                            else if lsTypeData = 's'
                            then begin
                                lsTmp := aoArguments[liIndexArgument] ;

                                lsTmp := Copy(aoArguments[liIndexArgument], 1, liLongueurFin) ;

                                if lbAlignerAGauche
                                then
                                    lsTmp := lsTmp + RepeterCaractere(lsRemplissage, liLongueurDebut)
                                else begin
                                    lsTmp := RepeterCaractere(lsRemplissage, liLongueurDebut - Length(lsTmp)) + lsTmp ;
                                end ;

                                gsResultFunction := gsResultFunction + lsTmp ;
                            end
                            else if (lsTypeData = 'x') or (lsTypeData = 'X')
                            then begin
                                if isFloat(aoArguments[liIndexArgument])
                                then begin
                                    lsTmp := ExtractIntPart(aoArguments[liIndexArgument]) ;

                                    lsTmp := DecToHex(MyStrToInt(lsTmp)) ;

                                    if lbAddBefore
                                    then begin
                                        lsTmp := '0x' + lsTmp ;
                                    end ;

                                    if lsTypeData = 'X'
                                    then begin
                                        lsTmp := UpperCase(lsTmp) ;
                                    end ;

                                    if lbAlignerAGauche
                                    then begin
                                        lsTmp := lsTmp + RepeterCaractere(lsRemplissage, liLongueurDebut) ;
                                    end
                                    else begin
                                        lsTmp := RepeterCaractere(lsRemplissage, liLongueurDebut - Length(lsTmp)) + lsTmp ;
                                    end ;

                                    gsResultFunction := gsResultFunction + lsTmp ;
                                end
                            end
                            else if (lsTypeData = 'o') or (lsTypeData = 'b')
                            then begin
                                if isFloat(aoArguments[liIndexArgument])
                                then begin
                                    lsTmp := ExtractIntPart(aoArguments[liIndexArgument]) ;

                                    if (lsTypeData = 'o')
                                    then begin
                                        lsTmp := DecToOct(MyStrToInt(lsTmp)) ;

                                        if lbAddBefore
                                        then begin
                                            lsTmp := '0' + lsTmp ;
                                        end ;
                                    end
                                    else begin
                                        lsTmp := DecToBin(MyStrToInt(lsTmp)) ;
                                    end ;

                                    if lbAlignerAGauche
                                    then begin
                                        lsTmp := lsTmp + RepeterCaractere(lsRemplissage, liLongueurDebut) ;
                                    end
                                    else begin
                                        lsTmp := RepeterCaractere(lsRemplissage, liLongueurDebut - Length(lsTmp)) + lsTmp ;
                                    end ;

                                    gsResultFunction := gsResultFunction + lsTmp ;
                                end
                            end
                            else if lsTypeData = 'e'
                            then begin
                                if isFloat(aoArguments[liIndexArgument])
                                then begin
                                    { Est-ce une partie fractionnaire ? }
                                    lfTmpFloat := Abs(MyStrToFloat(aoArguments[liIndexArgument])) ;

                                    if lfTmpFloat < 1
                                    then begin
                                        { Si le nombre est inférieur à 1 on affichera en xxxE-xxx}
                                        if lfTmpFloat <> 0
                                        then begin
                                            lsIndice := '-' ;

                                            liTmpInt := 0 ;

                                            while lfTmpFloat < 1 do
                                            begin
                                                OverTimeAndMemory ;

                                                if gbQuit
                                                then begin
                                                    break ;
                                                end ;

                                                lfTmpFloat := lfTmpFloat * 10 ;
                                                Inc(liTmpInt) ;
                                            end ;

                                            aoArguments[liIndexArgument] := MyFloatToStr(lfTmpFloat) ;

                                        end
                                        else begin
                                            lsIndice := '+' ;
                                            liTmpInt := 0 ;
                                        end ;
                                    end
                                    else begin
                                        { Si le nombre est supérieur à 1 on affichera le nombre en xxxE+xx}
                                        lsIndice := '+' ;

                                        { On arrondi la virgule et obtient un entier }
                                        liTmpInt := Round(MyStrToFloat(aoArguments[liIndexArgument])) ;

                                        lsTmp := IntToStr(liTmpInt) ;

                                        { calculer le nombre d'élément après la virgule }
                                        liTmpInt := Length(lsTmp) - liLongueurFin ;

                                        { On insère la virgule pour obtenir un nombre en x.xxxx }
                                        if lsTmp[1] = '-'
                                        then begin
                                            Insert('.', lsTmp, 3) ;
                                        end
                                        else begin
                                            Insert('.', lsTmp, 2) ;
                                        end ;

                                        { Convertit en float pour arrondir }
                                        lfTmpFloat := MyStrToFloat(lsTmp) ;
                                        lfTmpFloat := RoundTo(lfTmpFloat, -1 * liLongueurFin) ;

                                        { force le séparateur décimal à '.' }
                                        DecimalSeparator := '.' ;

                                        aoArguments[liIndexArgument] := FloatToStr(lfTmpFloat) ;
                                    end ;

                                    { Construit la partie exposant xxE-/+ }
                                    lsTmp3 := 'e' + lsIndice + IntToStr(liTmpInt) ;

                                    { Sépare la partie floattant de la partie entiere }
                                    lsTmp := extractIntPart(aoArguments[liIndexArgument]) ;
                                    lsTmp2 := extractFloatPart(aoArguments[liIndexArgument]) ;

                                    { Tronque la partie flottante }
                                    lsTmp2 := Copy(lsTmp2, 1, liLongueurFin) ;

                                    if Length(lsTmp2) < liLongueurFin
                                    then begin
                                        lsTmp2 := lsTmp2 + RepeterCaractere('0', liLongueurFin - Length(lsTmp2)) ;
                                    end ;

                                    if lbAlignerAGauche
                                    then begin
                                        if lbForceSign
                                        then begin
                                            if lsTmp[1] <> '-'
                                            then begin
                                                lsTmp := '+' + lsTmp ;
                                            end ;
                                        end ;

                                        lsTmp := lsTmp + '.' + lsTmp2 + lsTmp3 + RepeterCaractere(lsRemplissage, liLongueurDebut - Int64((length(lsTmp)) + Int64(length(lsTmp2)) + 1 + Int64(Length(lsTmp3))))
                                    end
                                    else begin
                                        lbIsNeg := False ;

                                        if lsTmp <> ''
                                        then begin
                                            if lsTmp[1] = '-'
                                            then begin
                                                lbIsNeg := True ;
                                                lsTmp := copy(lsTmp, 2, length(lsTmp) - 1) ;
                                            end ;
                                        end ;

                                        lsTmp := RepeterCaractere(lsRemplissage, liLongueurDebut - Length(lsTmp) - Length(lsTmp2) - 1 - Length(lsTmp3)) + lsTmp + '.' + lsTmp2 + lsTmp3 ;

                                        if lbIsNeg or lbForceSign
                                        then begin
                                            lsTmp := SetSign(lsTmp, lbIsNeg, liLongueurDebut, lsRemplissage) ;
                                        end ;
                                    end ;

                                    gsResultFunction := gsResultFunction + lsTmp ;
                                end ;
                            end ;
                        end
                        else begin
                            ErrorMsg(csTooArguments) ;
                            break ;
                        end ;

                        Inc(liIndexArgument) ;
                    end
                    else begin
                        gsResultFunction := gsResultFunction + '%' ;
                    end ;
                end ;
            end
            else begin
                gsResultFunction := gsResultFunction + lsTextTemplate[liIndexChaineATraiter] ;
            end ;

            Inc(liIndexChaineATraiter) ;
        end ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
end ;

procedure strBase64EncodeCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := Encode64(aoArguments[0]) ;
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

procedure strBase64DecodeCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := Decode64(aoArguments[0]) ;
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

procedure strSoundExCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := soundex(aoArguments[0]) ;
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

procedure strUcFirstCommande(aoArguments : TStringList) ;
var
    { Compteur de position de chaine }
    liIndex : Integer ;
begin
    if aoArguments.count = 1
    then begin
        liIndex := 1 ;

        if length(aoArguments[0]) > 0
        then begin
            while (aoArguments[0][liIndex] = ' ') or (aoArguments[0][liIndex] = #9) do
            begin
                Inc(liIndex) ;
            end ;

            gsResultFunction := aoArguments[0] ;
            gsResultFunction[liIndex] := UpperChar(gsResultFunction[liIndex]) ;
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

procedure strUcWordsCommande(aoArguments : TStringList) ;
var
    { Compteur de boucle de caractère }
    liIndex : Integer ;
    { Taille de la chaine à traiter }
    liLenght : Integer ;
begin
    if aoArguments.count = 1
    then begin
        liIndex := 1 ;
        gsResultFunction := aoArguments[0] ;
        liLenght  := length(aoArguments[0]) ;

        while liIndex < liLenght  do
        begin
            while (aoArguments[0][liIndex] = ' ') or (aoArguments[0][liIndex] = #9) do
            begin
                Inc(liIndex) ;

                if liIndex > liLenght
                then begin
                    break ;
                end ;
            end ;

            gsResultFunction[liIndex] := UpperChar(gsResultFunction[liIndex]) ;

            while (aoArguments[0][liIndex] <> ' ') and (aoArguments[0][liIndex] <> #9) do
            begin
                Inc(liIndex) ;

                if liIndex > liLenght
                then begin
                    break ;                
                end ;
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

procedure strtrCommande(aoArguments : TStringList) ;
var
    { Liste des caractères à remplacer }
    loListeCaractereARemplacer : TStringList ;
    { Liste des caractères de remplacement }
    loListeCaractereRemplacement : TStringList ;
    { Index de chaine }
    liIndex : Integer ;
    { Chaine temporaire recevant la chaine modifiée au fur et à mesure }
    lsModifiedString : String ;
    { Chaine à remplacer }
    lsStr : String ;
begin
    if aoArguments.count = 3
    then begin
        loListeCaractereARemplacer := TStringList.Create ;
        loListeCaractereRemplacement := TStringList.Create ;

        if goVariables.InternalisArray(aoArguments[1])
        then begin
            goVariables.explode(loListeCaractereARemplacer, aoArguments[1]) ;
        end
        else begin
            for liIndex := 1 to Length(aoArguments[1]) do
            begin
                loListeCaractereARemplacer.Add(aoArguments[1][liIndex]) ;
            end ;
        end ;

        if goVariables.InternalisArray(aoArguments[2])
        then begin
            goVariables.explode(loListeCaractereRemplacement, aoArguments[2]) ;
        end
        else begin
            for liIndex := 0 to loListeCaractereRemplacement.Count - 1 do
            begin
                loListeCaractereRemplacement.Add(aoArguments[2][liIndex]) ;
            end ;
        end ;

        lsStr := aoArguments[0] ;

        lsModifiedString := RepeterCaractere('0', Length(lsStr)) ;

        for liIndex := 0 to loListeCaractereARemplacer.Count - 1 do
        begin
            if liIndex > (loListeCaractereRemplacement.Count - 1)
            then begin
                break ;
            end ;
            
            ReplaceOneOccurenceOnce(loListeCaractereARemplacer[liIndex], lsStr, loListeCaractereRemplacement[liIndex], lsModifiedString) ;
        end ;

        gsResultFunction := lsStr ;

        FreeAndNil(loListeCaractereARemplacer) ;
        FreeAndNil(loListeCaractereRemplacement) ;
    end
    else if aoArguments.count < 3
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 3
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure strrevCommande(aoArguments : TStringList) ;
var
    { Compteur de boucle }
    liIndex : Integer ;
    { Longueur de la chaine à inverser}
    liLength : Integer ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := '' ;
        liLength := Length(aoArguments[0]) ;

        for liIndex := liLength downto 1 do
        begin
            gsResultFunction := gsResultFunction + aoArguments[0][liIndex] ;
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

{*****************************************************************************
 * configParameter
 * MARTINEAU Emeric
 *
 * Configure les paramètres en fonctions des paramètres passés en script.
 * Utilisé par strcspnCommande() et strspnCommande()
 *
 * Paramètres d'entrée :
 *   - aoArguments : aoArguments passés à la fonction
 *
 * Paramètres de sortie :
 *   - aiStart : paramètre de début,
 *   - aiLength : paramètre de longueur,
 *   - aoSearch : paramètre de recherche
 *
 *****************************************************************************}
procedure configParameter(var aiStart : integer; var aiLength : integer; var aoSearch : TStringList; aoArguments : TStringList) ;
var i : Integer ;
begin
    if aoArguments.count > 2
    then begin
        aiStart := MyStrToInt(aoArguments[2]) ;
    end
    else begin
        aiStart := 1 ;
    end ;

    if aoArguments.count > 3
    then begin
        aiLength := MyStrToInt(aoArguments[3]) ;
    end
    else begin
        aiLength := length(aoArguments[0]) ;
    end ;

    if goVariables.InternalIsArray(aoArguments[1])
    then begin
        goVariables.Explode(aoSearch, aoArguments[1]) ;
    end
    else begin
        for i := 1 to length(aoArguments[1]) do
        begin
            aoSearch.add(aoArguments[1][i]) ;
        end ;
    end ;
end ;

procedure strcspnCommande(aoArguments : TStringList) ;
var
    { Position de départ de recherche }
    liStart : Integer ;
    { Longueur maxi de recherche }
    liLength : Integer ;
    { Longueur en cours }
    liLongueur : Integer ;
    { Longueur maxi trouvée }
    liMaxLongueur : Integer;
    { Compteur }
    liIndex : integer ;
    { Caractère à rechercher }
    loSearch : TStringList ;
begin
    if (aoArguments.count > 1) and (aoArguments.count < 5)
    then begin
        loSearch := TStringList.create ;
        liMaxLongueur := 0 ;
        liLongueur := 0 ;
        liLength := 0 ;
        liStart := 0 ;

        configParameter(liStart, liLength, loSearch, aoArguments) ;

        for liIndex := liStart to liLength do
        begin
            if loSearch.IndexOf(aoArguments[0][liIndex]) = -1
            then begin
                Inc(liLongueur) ;
            end
            else begin
                liLongueur := 0 ;
            end ;

            if liLongueur > liMaxLongueur
            then begin
                liMaxLongueur := liLongueur ;
            end ;
        end ;

        gsResultFunction := IntToStr(liMaxLongueur) ;

        FreeAndNil(loSearch) ;
    end
    else if aoArguments.count < 2
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 4
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure strspnCommande(aoArguments : TStringList) ;
var
    { Position de départ de recherche }
    liStart : Integer ;
    { Longueur maxi de recherche }
    liLength : Integer ;
    { Longueur en cours }
    liLongueur : Integer ;
    { Longueur maxi trouvée }
    liMaxLongueur : Integer;
    { Compteur }
    liIndex : integer ;
    { Caractère à rechercher }
    loSearch : TStringList ;
begin
    if (aoArguments.count > 1) and (aoArguments.count < 5)
    then begin
        loSearch := TStringList.create ;
        liMaxLongueur := 0 ;
        liLongueur := 0 ;
        liLength := 0 ;
        liStart := 0 ;
        
        configParameter(liStart, liLength, loSearch, aoArguments) ;

        for liIndex := liStart to liLength do
        begin
            if loSearch.IndexOf(aoArguments[0][liIndex]) <> -1
            then begin
                Inc(liLongueur) ;
            end
            else begin
                liLongueur := 0 ;
            end ;

            if liLongueur > liMaxLongueur
            then begin
                liMaxLongueur := liLongueur ;
            end ;
        end ;

        gsResultFunction := IntToStr(liMaxLongueur) ;

        FreeAndNil(loSearch) ;
    end
    else if aoArguments.count < 2
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 4
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure strReplaceAccentCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := ReplaceAccent(aoArguments[0]) ;
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

procedure strNumberFormatCommande(aoArguments : TStringList) ;
var
    { Compteur de boucle }
    liIndex : Integer ;
    { Indique le nombre de chiffre en cours d'ajout pour savoir quand
      mettre le séparateur de millier }
    liNbChiffre : Integer ;
    { Position du séparateur décimal }
    liPositionSeparateurDecimal : Integer ;
    { Séparateur décimal }
    lsSeparateurDecimal : String ;
    { Séparateur de millier }
    lsSeparateurMillier : String ;
begin
    if (aoArguments.count > 0) and (aoArguments.count < 4)
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := '' ;

            if aoArguments.count > 1
            then begin
                lsSeparateurDecimal := aoArguments[1] ;
            end
            else begin
                lsSeparateurDecimal := gsFloatSeparator ;
            end ;

            if aoArguments.count > 2
            then begin
                lsSeparateurMillier := aoArguments[2] ;
            end
            else begin
                lsSeparateurMillier := gsMillierSeparator ;
            end ;

            liPositionSeparateurDecimal := pos('.', aoArguments[0]) ;
            
            { S'il y a une partie floattante }
            if liPositionSeparateurDecimal <> 0
            then begin
                for liIndex := Length(aoArguments[0]) downto liPositionSeparateurDecimal + 1 do
                begin
                    gsResultFunction := aoArguments[0][liIndex] + gsResultFunction ;
                end ;
                
                gsResultFunction := lsSeparateurDecimal + gsResultFunction ;
            end
            else begin
                liPositionSeparateurDecimal := Length(aoArguments[0]) ;
            end ;

            liNbChiffre := 1 ;

            for liIndex := liPositionSeparateurDecimal - 1 downto 1 do
            begin
                if (liNbChiffre mod 4) = 0
                then begin
                    gsResultFunction := lsSeparateurMillier + gsResultFunction ;
                    liNbChiffre := 1 ;
                end ;

                gsResultFunction := aoArguments[0][liIndex] + gsResultFunction ;
                Inc(liNbChiffre) ;
            end ;
        end
        else begin
            WarningMsg(csMustBeFloat ) ;
        end ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 3
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure printfCommande(aoArguments : TStringList) ;
begin
    strPrintFCommande(aoArguments) ;
    
    OutPutString(gsResultFunction, false) ;
    
    gsResultFunction := '' ;
end ;

procedure strEmptyCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if Length(aoArguments[0]) = 0
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
end ;

procedure strLeftCommande(aoArguments : TStringList) ;
Var
    { Taille de ce qu'il faut copier }
    liLength : Integer ;
begin
    if aoArguments.count = 2
    then begin
        { Si le nombre est un floattant, il y a un avertissement }
        if IsFloat(aoArguments[1]) and not IsInteger(aoArguments[1])
        then begin
            liLength := -1 ;
        end
        else begin
            liLength := MyStrToInt(aoArguments[1]) ;
        end ;
        
        if not gbQuit
        then begin
            if (liLength > 0)
            then begin
                gsResultFunction := Copy(aoArguments[0], 1, liLength) ;
            end
            else begin
                WarningMsg(csInvalidIndex) ;
            end ;
        end ;
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

procedure strRightCommande(aoArguments : TStringList) ;
Var
    { Taille de ce qu'il faut copier }
    liLength : Integer ;
begin
    if aoArguments.count = 2
    then begin
        { Si le nombre est un floattant, il y a un avertissement }
        if IsFloat(aoArguments[1]) and not IsInteger(aoArguments[1])
        then begin
            liLength := -1 ;
        end
        else begin
            liLength := MyStrToInt(aoArguments[1]) ;
        end ;

        if not gbQuit
        then begin
            if (liLength > 0)
            then begin
                gsResultFunction := Copy(aoArguments[0], Length(aoArguments[0]) - liLength + 1, liLength) ;
            end
            else begin
                WarningMsg(csInvalidIndex) ;
            end ;
        end ;
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

procedure strEndWithCommande(aoArguments : TStringList) ;
Var
    { Taille de ce qu'il faut regarder }
    liLength : Integer ;
    { Portion de chaine qui servira à la comparaison }
    lsPortionOfString : String ;
begin
    if aoArguments.count = 2
    then begin
        liLength := Length(aoArguments[1]) ;
        
        lsPortionOfString := Copy(aoArguments[0], Length(aoArguments[0]) - liLength + 1, liLength) ;

        if lsPortionOfString = aoArguments[1]
        then begin
            gsResultFunction := csTrueValue ;
        end
        else begin
            gsResultFunction := csFalseValue ;
        end ;
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

procedure strStartWithCommande(aoArguments : TStringList) ;
Var
    { Taille de ce qu'il faut regarder }
    liLength : Integer ;
    { Portion de chaine qui servira à la comparaison }
    lsPortionOfString : String ;
begin
    if aoArguments.count = 2
    then begin
        liLength := Length(aoArguments[1]) ;

        lsPortionOfString := Copy(aoArguments[0], 1, liLength) ;

        if lsPortionOfString = aoArguments[1]
        then begin
            gsResultFunction := csTrueValue ;
        end
        else begin
            gsResultFunction := csFalseValue ;
        end ;
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

procedure StrFunctionsInit ;
begin
    goInternalFunction.Add('echo', @echoCommande, true) ;
    goInternalFunction.Add('die', @dieCommande, true) ;
    goInternalFunction.Add('strUpperCase', @struppercaseCommande, true) ;
    goInternalFunction.Add('strLowerCase', @strlowercaseCommande, true) ;
    goInternalFunction.Add('strCopy', @strcopyCommande, true) ;
    goInternalFunction.Add('strPos', @strposCommande, true) ;
    goInternalFunction.Add('striPos', @striposCommande, true) ;
    goInternalFunction.Add('strrPos', @strrposCommande, true) ;
    goInternalFunction.Add('strriPos', @strriposCommande, true) ;
    goInternalFunction.Add('strTrim', @strtrimCommande, true) ;
    goInternalFunction.Add('strTrimLeft', @strtrimleftCommande, true) ;
    goInternalFunction.Add('strTrimRight', @strtrimrightCommande, true) ;

    goInternalFunction.Add('strReplace', @strreplaceCommande, false) ;
    goInternalFunction.Add('striReplace', @strreplaceCommande, false) ;

    goInternalFunction.Add('strInsert', @strinsertCommande, true) ;
    goInternalFunction.Add('strDelete', @strdeleteCommande, true) ;
    goInternalFunction.Add('strExplode', @strexplodeCommande, true) ;
    goInternalFunction.Add('strImplode', @strimplodeCommande, true) ;
    goInternalFunction.Add('strLoadFromFile', @strLoadFromFileCommande, true) ;
    goInternalFunction.Add('strSaveToFile', @strSaveToFileCommande, true) ;
    goInternalFunction.Add('strAddSlashes', @strAddSlashesCommande, true) ;
    goInternalFunction.Add('strDeleteSlashes', @strDeleteSlashesCommande, true) ;

    goInternalFunction.Add('strPrintr', @strPrintRCommande, false) ;

    goInternalFunction.Add('strPrintf', @strPrintFCommande, true) ;
    goInternalFunction.Add('strRepeatString', @strRepeatStringCommande, true) ;
    goInternalFunction.Add('strBase64Encode', @strBase64EncodeCommande, true) ;
    goInternalFunction.Add('strBase64Decode', @strBase64DecodeCommande, true) ;
    goInternalFunction.Add('strSoundex', @strSoundExCommande, true) ;
    goInternalFunction.Add('strUcFirst', @strUcFirstCommande, true) ;
    goInternalFunction.Add('strucWords', @strUcWordsCommande, true) ;
    goInternalFunction.Add('strTr', @strtrCommande, true) ;
    goInternalFunction.Add('strRev', @strrevCommande, true) ;
    goInternalFunction.Add('strcSpn', @strcspnCommande, true) ;
    goInternalFunction.Add('strSpn', @strspnCommande, true) ;
    goInternalFunction.Add('strReplaceAccent', @strReplaceAccentCommande, true) ;
    goInternalFunction.Add('strNumberFloat', @strNumberFormatCommande, true) ;
    goInternalFunction.Add('printf', @PrintFCommande, true) ;
    goInternalFunction.Add('strEmpty', @strEmptyCommande, true) ;
    goInternalFunction.Add('strLeft', @strLeftCommande, true) ;
    goInternalFunction.Add('strRight', @strRightCommande, true) ;
    goInternalFunction.Add('strStartWith', @strStartWithCommande, true) ;
    goInternalFunction.Add('strEndWith', @strEndWithCommande, true) ;
end ;

end.
