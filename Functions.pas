unit Functions;
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
 * This unit containt all function are not functions or keyword of SimpleWebScript
 ******************************************************************************}
{$I config.inc}

interface

uses SysUtils, Variable, UnitMessages, Classes,  
     InternalFunction, ListPointerOfTVariables, Extension, UnitOS
     {$IFNDEF COMMANDLINE}
     , DateUtils
     {$ENDIF}
      ;

procedure FinishProgramm ;
procedure ExplodeStrings(text : string; Ligne : TStringList) ;
procedure ErrorMsg(text : string) ;
procedure WarningMsg(text : string) ;
function GetLabel(text : string) : string ;
procedure setVar(variable : string; value : string) ;
function getVar(variable : string) : String ;
function CheckVarName(start : Integer; VarName : string) : boolean ;
function isVar(text : string) : boolean ;
function GetValueOfStrings(var arguments : TStringList) : Integer ;
function isNumeric(nombre : string) : boolean ;
function caree(value : Extended; exposant : integer) : Extended;
procedure delVar(variable : string) ;
function isSet(variable : string) : boolean ;
function MyStrToInt(nombre : string) : LongInt;
function getPointeurOfVariable(text : string) : string ;
function getVarNameOfVariable(text : string) : string ;
function GetReference(text : string) : string;
procedure SetReference(text : string; value : string) ;
procedure unSetReference(text : string) ;
function isSetReference(text : string) : Boolean ;
function AddFinalSlash(text : string) : string ;
function isFloat(nombre : String) : Boolean ;
function MyStrToFloat(nombre : string) : Extended ;
function MyFloatToStr(nombre : Extended) : string ;
function isInteger(nombre : string) : boolean ;
function FloatToInt(nombre : extended) : LongInt ;
function LoadCode(FileName : String; Offset : Integer) : boolean ;
procedure Explode(text : string; Ligne : TStringList; Separateur : string) ;
function ExecuteUserProcedure(Commande : String; CurrentLine : TStringList) : integer ;
procedure DeleteVirguleAndParenthese(argumentsAvecParentheses : TStringList) ;
function AnsiIndexStr(Text : string; const Values : array of string) : integer;
function GetString(Text : String) : String ;
procedure ReadLabel ;
function isHexa(nombre : string) : boolean ;
function extractCommande(text : string) : string ;
function LoadExtension(NameOfExt : String) : boolean ;
procedure UnLoadExtension(NameOfExt : String) ;
function isExtensionLoaded(NameOfExt : String) : Boolean ;
procedure TStringListToPChar(ArgTStringList : TStringList; var ArgPChar : PChar) ;
function CallExtension(Commande : String; Arguments : TStringList) : Boolean ;
function UrlDecode(Text : String) : String ;
function UrlEncode(Text : string): string;
function RealPath(FileName : String) : string ;
function RepeterCaractere(Text : string; Nb : integer) : String ;
function extractIntPart(Text : String) : String ;
function extractFloatPart(Text : String) : String ;
function AddSlashes(Text : String) : String ;
function DeleteSlashes(Text : String) : String ;
function DecToHex(nombre : Integer) : string ;
function DecToMyBase(nombre : Integer; Base : Byte) : String ;
function DecToOct(nombre : Integer) : String ;
function DecToBin(nombre : Integer) : String ;
function Encode64(S: string): string;
function Decode64(S: string): string;
function UniqId : string ;
procedure AddHeader(line : String) ;
procedure SendHeader ;
function DateTimeToUnix(ConvDate: TDateTime): Longint;
function UnixToDateTime(USec: Longint): TDateTime;
procedure OverTimeAndMemory ;
procedure OutputString(Text : String; parse : boolean) ;
function showData(data : string; decalage : String; Index : Integer) : String ;
function ReplaceOneOccurence(Substr : string; var Str : string; ReplaceStr : string; CaseSensitive : Boolean) : Cardinal ;
function soundex(S : String) : String ;
function upperChar(C : Char) : Char ;
function posString(substr : String; str : String; index : Integer; CaseSensitive : boolean) : Cardinal ;
function posrString(substr : String; str : String; index : Integer; CaseSensitive : boolean) : Cardinal ;
procedure ReplaceOneOccurenceOnce(Substr : string; var Str : string; ReplaceStr : string; var strmod : String) ;
function ReplaceAccent(str : string) : string ;
procedure ListShuffle(Liste : TStrings) ;
procedure setShortDayName ;
procedure setLongDayName ;
procedure setShortMonthName ;
procedure setLongMonthName ;
procedure InitDayName(var tableaudestination : array of string; valeur : array of string) ;
procedure InitMonthName(var tableaudestination : array of string; valeur : array of string) ;
function CRC32(Text : String) : Integer ;

implementation

uses Code, UserFunction, UserLabel ;

const
  Code64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  { Configure UnixStartDate vers TDateTime à 01/01/1970 }
  UnixStartDate: TDateTime = 25569.0;

procedure FinishProgramm ;
var i : Integer ;
begin
    CodeList.Free ;
    Variables.Free ;
    ListLabel.Free ;
    ListProcedure.Free ;
    ListOfFile.Free ;
    LineToFileLine.Free ;
    LineToFile.Free ;
    ListFunction.Free ;
    GlobalVariable.Free ;
    PointerOFVariables.Free ;
    CurrentFunctionName.Free ;
    VarGetPostCookieFileData.Free ;
    Header.Free ;
    ListCookie.Free ;
    CurrentRootOfFile.Free ;
    
    for i := 0 to ListOfExtension.Count - 1 do
    begin
        OsUnLoadExtension(ListOfExtension.GiveNameByIndex(i)) ;
    end ;

    ListOfExtension.Free ;
end ;

{*******************************************************************************
 * Fonction qui split les commandes
 *
 *  Entrée
 *   Text : chaine à traiter
 *
 *  Sortie
 *   Liste : TStringList contenant tous les éléments de la chaine
 ******************************************************************************}
procedure ExplodeStrings(text : string; Ligne : TStringList) ;
var tmp : string ;
    i, j, nb : Integer ;
    InQuote : boolean ;
    Caractere : string ;
    Delimiter : string ;
    DotFound : boolean ;
    xFound : boolean ;
begin
    Ligne.Clear ;

    tmp := '' ;
    i := 1 ;
    nb := Length(text) + 1 ;
    {
    1 - si on est dans une chaine copier jusqu'à la fin de la chaine si fin de chaine mère alors manque un "
    2 - si c'est un nom de variable
    3 - gérer tous les cas
        ()
        -
        +
        *
        /
        ^
        #
        @
        &
        |
        &|
        <<
        >>
        ~
        %
        .
        =
        <=
        <
        <>
        >=
        >
     }

    while i < nb do
    begin
        if Text[i] = '('
        then
            Ligne.Add('(')
        else if Text[i] = ')'
        then
            Ligne.Add(')')
        else if Text[i] = '-'
        then
            Ligne.Add('-')
        else if Text[i] = '+'
        then
            Ligne.Add('+')
        else if Text[i] = '%'
        then
            Ligne.Add('%')
        else if Text[i] = '@'
        then
            Ligne.Add('@')
        else if Text[i] = '='
        then
            Ligne.Add('=')
        else if Text[i] = '.'
        then begin
            tmp := '.' ;

            if (i + 2) < nb
            then begin
                if (Text[i+1] = '.') and (Text[i+2] = '.')
                then begin
                    tmp := tmp + '..' ;
                    Inc(i, 2) ;
                end ;
            end ;

            Ligne.Add(tmp)
        end
        else if Text[i] = '['
        then
            Ligne.Add('[')
        else if Text[i] = ']'
        then
            Ligne.Add(']')
        else if Text[i] = ','
        then
            Ligne.Add(',')
        else if Text[i] = '*'
        then begin
            if i < nb
            then begin
                if Text[i+1] = '$'
                then begin
                    { C'est une variable }
                    tmp := '*' ;
                    Inc(i) ;

                    while i < nb do
                    begin
                        tmp := tmp + Text[i] ;
                        Inc(i) ;

                        Caractere := LowerCase(Text[i]) ;

                        if not ((Text[i] in ['0'..'9']) or (Caractere[1] in ['a'..'z']) or (Text[i] = '_'))
                        then
                            if Text[i] = '['
                            then begin
                                j := 0 ;

                                while j < (nb - i) do
                                begin
                                    if Text[i+j] <> ']'
                                    then begin
                                        tmp := tmp + Text[i+j] ;
                                        Inc(j) ;
                                    end
                                    else
                                        break ;
                                end ;

                                { Inutile d'ajouter ] car on refait un tour dans la boucle principal et c'est ajouté automatiquement }
                                Inc(i, j) ;
                            end
                            else
                                break ;
                    end ;

                    { Décrémente pour qu'on pointe sur le caratère qui nous à fait arrêté }
                    Dec(i) ;

                    Ligne.Add(tmp) ;
                end
                else
                    Ligne.Add('*') ;
            end
            else
                Ligne.Add('*') ;
        end
        else if Text[i] = '/'
        then begin
            if i < nb
            then begin
                if Text[i + 1] = '/'
                then begin
                    { C'est un commentaire }
                    break ;
                end ;
            end
            else begin
                Ligne.Add('/')
            end ;
        end
        else if Text[i] = '^'
        then
            Ligne.Add('^')
        else if (Text[i] = '#')
        then
            { c'est un commentaire }
            break
        (* Si on permet le ; en fin de ligne, on risque la confusion et faire
           croire que le multi ligne est possible alors que non
        else if (Text[i] = ';')
        then begin
            { vérifie que le prochain caractère est un # }
            Inc(i) ;

            while i < nb do
            begin
                if Text[i] = '#'
                then
                    break
                else if (Text[i] <> ' ') or (Text[i] <> #9)
                then begin
                    ErrorMsg(sNotCommentAfterSemiColumn) ;
                    break ;
                end ;
            end ;

            break ;
        end
        *)
        else if Text[i] = '~'
        then
            Ligne.Add('~')
        else if Text[i] = '&'
        then begin
            if i < nb
            then begin
                if Text[i+1] = '|'
                then begin
                    Inc(i) ;
                    Ligne.Add('&|')
                end
                else if Text[i+1] = '$'
                then begin
                    { C'est une variable }
                    tmp := '&' ;
                    Inc(i) ;

                    while i < nb do
                    begin
                        tmp := tmp + Text[i] ;
                        Inc(i) ;

                        Caractere := LowerCase(Text[i]) ;

                        if not ((Text[i] in ['0'..'9']) or (Caractere[1] in ['a'..'z']) or (Text[i] = '_'))
                        then
                            if Text[i] = '['
                            then begin
                                j := 0 ;

                                while j < (nb - i) do
                                begin
                                    if Text[i+j] <> ']'
                                    then begin
                                        tmp := tmp + Text[i+j];
                                        Inc(j) ;
                                    end
                                    else
                                        break ;
                                end ;

                                { Inutile d'ajouter ] car on refait un tour dans la boucle principal et c'est ajouté automatiquement }
                                Inc(i, j) ;
                            end
                            else
                                break ;
                    end ;

                    { Décrémente pour qu'on pointe sur le caratère qui nous à fait arrêté }
                    Dec(i) ;

                    Ligne.Add(tmp) ;
                end
                else
                    Ligne.Add('&') ;
            end
            else
                Ligne.Add('&') ;
        end
        else if Text[i] = '|'
        then
            Ligne.Add('|')
        else if Text[i] = '<'
        then begin
            if i < nb
            then begin
                if Text[i+1] = '<'
                then begin
                    Inc(i) ;
                    Ligne.Add('<<')
                end
                else if Text[i+1] = '='
                then begin
                    Inc(i) ;
                    Ligne.Add('<=')
                end
                else if Text[i+1] = '>'
                then begin
                    Inc(i) ;
                    Ligne.Add('<>')
                end
                else
                    Ligne.Add('<') ;
            end
            else
                Ligne.Add('<') ;
        end
        else if Text[i] = '>'
        then begin
            if i < nb
            then begin
                if Text[i+1] = '>'
                then begin
                    Inc(i) ;
                    Ligne.Add('>>')
                end
                else if Text[i+1] = '='
                then begin
                    Inc(i) ;
                    Ligne.Add('>=')
                end
                else
                    Ligne.Add('>') ;
            end
            else
                Ligne.Add('>') ;
        end
        else if (Text[i] in ['0'..'9'])
        then begin
            { C'est un nombre }
            tmp := '' ;
            DotFound := False ;
            xFound := False ;

            while i < nb do
            begin
                if (Text[i] in ['0'..'9']) or (Text[i] in ['a'..'f']) or (Text[i] in ['A'..'F'])
                then
                    tmp := tmp + Text[i]
                else if (not DotFound) and (Text[i] = '.')
                then begin
                    DotFound := True ;
                    tmp := tmp + Text[i] ;
                end
                else if (not xFound) and (Text[i] = 'x')
                then begin
                    xFound := True ;
                    tmp := tmp + Text[i] ;
                end
                else
                    break ;
                    
                Inc(i) ;
            end ;

            Ligne.Add(tmp) ;

            { Décrément car on à une Inc(i) à la fin de la boucle }
            Dec(i) ;
        end
        else if (Text[i] = '"') or (Text[i] = '''')
        then begin
            Delimiter := Text[i] ;

            { On est dans une chaine }
            tmp := '' ;
            InQuote := True ;
            Inc(i) ;

            while i <= nb do
            begin
                { Prochain caractère }
                if Text[i] = '\'
                then begin
                    Inc(i) ;

                    if i <= nb
                    then begin                        
                        if Text[i] = 'n'
                        then
                            Text[i] := char(10)
                        else if Text[i] = 'r'
                        then
                            Text[i] := char(13)
                        else if Text[i] = '0'
                        then
                            Text[i] := char(0)
                        else if Text[i] = 't'
                        then
                            Text[i] := char(9)
                    end
                end
                else if Text[i] = Delimiter
                then begin
                    InQuote := False ;
                    break ;
                end ;
            
                tmp := tmp + Text[i] ;

                Inc(i) ;
            end ;

            //Dec(i) ;
            
            Ligne.Add('"' + tmp + '"') ;

            if InQuote
            then begin
                ErrorMsg(sNoEndString) ;
            end ;
        end
        else begin
            if (Text[i] <> #9) and (Text[i] <> ' ')
            then begin
                tmp := '' ;

                while i < nb do
                begin
                    tmp := tmp + Text[i] ;
                    Inc(i) ;

                    { Cas où on a $$xxx }
                    if Text[i] = '$'
                    then begin
                        tmp := tmp + Text[i] ;
                        Inc(i) ;
                    end ;

                    Caractere := LowerCase(Text[i]) ;

                    if not ((Text[i] in ['0'..'9']) or (Caractere[1] in ['a'..'z']) or (Text[i] = '_'))
                    then
                        if Text[i] = '['
                        then begin
                            j := 0 ;

                            while j < (nb - i) do
                            begin
                                if Text[i+j] <> ']'
                                then begin
                                    tmp := tmp + Text[i+j];
                                    Inc(j) ;
                                end
                                else
                                    break ;
                            end ;

                            { Inutile d'ajouter ] car on refait un tour dans la boucle principal et c'est ajouté automatiquement }
                            Inc(i, j) ;
                        end
                        else
                            break ;
                end ;

                { Décrémente pour qu'on pointe sur le caratère qui nous à fait arrêté }
                Dec(i) ;

                Ligne.Add(tmp) ;
            end ;
        end ;

        Inc(i) ;
    end ;
end ;

{*******************************************************************************
 * Affiche une erreur et inquique au programme qu'il y a une erreur
 *
 *  Entrée
 *   Text : texte à afficher
 ******************************************************************************}
procedure ErrorMsg(text : string) ;
begin
    if (not isHeaderSend)
    then
        SendHeader ;

    { Evite d'afficher un message d'erreur s'il y a déjà un message d'erreur
      d'affiché }
    if not NoError and not GlobalError
    then begin
        if LineToFile.count > 0
        then
            //OutPutString(sErrorIn + ListOfFile[MyStrToInt(LineToFile[CurrentLineNumber])], false)
            WriteLn(sErrorIn + ListOfFile[MyStrToInt(LineToFile[CurrentLineNumber])])
        else
            //OutPutString(sGeneralError + text, false) ;
            WriteLn(sGeneralError + text) ;

        if (CurrentFunctionName.Count > 0) and (LineToFileLine.Count >0)
        then
            //OutPutString(AddSlashes(Format(' [%s:%s] %s', [CurrentFunctionName[CurrentFunctionName.Count - 1], LineToFileLine[CurrentLineNumber], text])) + '\n', true) ;
            WriteLn(Format(' [%s:%s] %s', [CurrentFunctionName[CurrentFunctionName.Count - 1], LineToFileLine[CurrentLineNumber], text])) ;

        GlobalError := True ;
    end ;
end ;

{*******************************************************************************
 * Fonction retournant le nom du label sans les :
 *
 *  Entrée
 *   text : label à lire
 ******************************************************************************}
function GetLabel(text : string) : string ;
Var i, nb : integer ;
begin
    text := copy(text, 1, pos(':', text) - 1) ;

    text := LowerCase(Trim(text)) ;

    if not (text[1] in ['0'..'9'])
    then begin
        nb := length(text) ;

        for i := 2 to nb do
        begin
            if not ((Text[i] in ['a'..'z']) or (Text[i] in ['0'..'9']))
            then begin
                text := '' ;
                break ;                
            end ;
        end ;

        Result := text ;
    end
    else
        Result := '' ;
end ;

{*******************************************************************************
 * Affiche une alerte
 *
 *  Entrée
 *   Text : texte à afficher
 ******************************************************************************}
procedure WarningMsg(text : string) ;
begin
    if (not isHeaderSend)
    then
        SendHeader ;

    if Warning
    then begin
        //OutPutString(sWarningIn + ListOfFile[MyStrToInt(LineToFile[CurrentLineNumber])], false) ;
        WriteLn(sWarningIn + ListOfFile[MyStrToInt(LineToFile[CurrentLineNumber])]) ;

        //OutPutString(Format(' [%s:%s] %s', [CurrentFunctionName[CurrentFunctionName.Count - 1],LineToFileLine[CurrentLineNumber], text]) + '\n', true) ;
        WriteLn(Format(' [%s:%s] %s', [CurrentFunctionName[CurrentFunctionName.Count - 1],LineToFileLine[CurrentLineNumber], text])) ;
    end ;
end ;

{*******************************************************************************
 * donne une valeur à une variable
 *
 *  Entrée
 *   variable : nom de la variable avec le $
 *   value    : valeur de la variable
 ******************************************************************************}
procedure setVar(variable : string; value : string) ;
var nb : Integer ;
    isPointer : boolean ;
    Tab, tmp : String ;
    StartTab : Integer ;
    value1 : TStringList ;
    i : Integer ;
begin
    isPointer := False ;
    // inutile cas fait dans le Variables.Add
    //variable := LowerCase(variable) ;

    if Length(variable) > 2
    then begin
        if variable[1] = '*'
        then begin
            { Pointer de variable }
            variable := copy(variable, 2, Length(variable) - 1) ;
            isPointer := True ;
        end ;
    end ;

    if (variable <> '$true') and (variable <> '$false') and
       (variable <> '$_version') and
       (variable <> '$_scriptname')
    then begin
        StartTab := pos('[', variable) ;

        if StartTab > 0
        then begin
            tmp := copy(variable, 1, StartTab-1) ;
            Tab := copy(variable, StartTab, length(variable) - StartTab + 1) ;

            value1 := TStringList.Create ;

            { Eclate tout les tableaux }
            ExplodeStrings(Tab, value1) ;

            { Convertit les valeurs }
            GetValueOfStrings(value1) ;

            { Vérifie que pour chaque élément on ait bien un nombre entier}
            for i := 0 to value1.Count - 1 do
            begin
                if (value1[i] <> '[') and (value1[i] <> ']')
                then begin
                    if MyStrToInt(value1[i]) = 0
                    then begin
                        ErrorMsg(sInvalidIndex) ;
                        Break ;
                    end ;
                end ;
            end ;

            if (not GlobalError) and (not GlobalQuit)
            then begin
                Tab := '' ;

                for i := 0 to value1.Count - 1 do
                begin
                    Tab := Tab + value1[i] ;
                end ;
            end ;

            value1.Free ;

            variable := tmp ;
        end
        else
            Tab := '' ;

        if (not GlobalError) and (not GlobalQuit)
        then begin    
            nb := Length(variable) ;

            if nb > 2
            then
                if variable[2] = '$'
                then begin
                    variable := Copy(variable, 2, nb - 1) ;

                    variable := getVar(variable) ;
                end ;

            if isPointer
            then
                SetReference(variable + Tab, value)
            else
                Variables.Add(variable + Tab, value) ;
        end ;
    end
    else
        WarningMsg(sCantAffectPredifinedVar) ;
end ;

{*******************************************************************************
 * Retour la valeur d'une variable
 *
 *  Entrée
 *   variable : nom de la variable avec le $
 *
 *  Retour : valeur de la variable
 ******************************************************************************}
function getVar(variable : string) : String ;
var tmp, tmp2 : string ;
    Len : Integer ;
    isPointer : boolean ;
    isReference : Boolean ;
    Tab : String ;
    StartTab : Integer ;
    value : TStringList ;
    i : Integer ;
begin
    Len := Length(variable) ;
    isPointer := False ;
    isReference := False ;

    if Len > 1
    then begin
        StartTab := pos('[', variable) ;

        if StartTab > 0
        then begin
            tmp := copy(variable, 1, StartTab-1) ;
            Tab := copy(variable, StartTab, len - StartTab + 1) ;
            value := TStringList.Create ;

            { Eclate tout les tableaux }
            ExplodeStrings(Tab, value) ;

            { Convertit les valeurs }
            GetValueOfStrings(value) ;

            { Vérifie que pour chaque élément on ait bien un nombre entier}
            for i := 0 to value.Count - 1 do
            begin
                if (value[i] <> '[') and (value[i] <> ']')
                then begin
                    if MyStrToInt(value[i]) = 0
                    then begin
                        ErrorMsg(sInvalidIndex) ;
                        Break ;
                    end ;
                end ;
            end ;

            if (not GlobalError) and (not GlobalQuit)
            then begin
                Tab := '' ;

                for i := 0 to value.Count - 1 do
                begin
                    Tab := Tab + value[i] ;
                end ;
            end ;

            value.Free ;

            variable := tmp ;
        end
        else
            Tab := '' ;


        if (not GlobalError) and (not GlobalQuit)
        then begin
            tmp := variable ;

            if variable[1] = '&'
            then begin
                { C'est un pointer de variable }
                if Len > 2
                then begin
                    tmp := copy(variable, 2, Len - 1) ;
                    isPointer := True ;
                end
                else begin
                    ErrorMsg(sInvalidPointer) ;
                    Result := '' ;
                end ;
            end
            else if variable[1] = '*'
            then begin
                { C'est une récupération de variable }
                if Len > 2
                then begin
                    tmp := copy(variable, 2, Len - 1) ;
                    isReference := True ;
                end
                else begin
                    ErrorMsg(sInvalidPointer) ;
                    Result := '' ;
                end ;
            end
            else if variable[2] = '$'
            then begin
                { On peut avoir un $$x }
                if Len > 2
                then begin
                    { La variable est du type $$x }
                    tmp := copy(variable, 2, Len - 1) ;

                    tmp := Variables.Give(tmp) ;

                    if tmp[1] <> '$'
                    then
                        tmp := '$' + tmp ;

                end
                else begin
                    ErrorMsg(sInvalidVarName) ;
                    Result := '' ;
                end ;
            end ;
        end ;

        if (not GlobalError) and (not GlobalQuit)
        then begin
            if isPointer
            then begin
                { Si c'est un pointeur on récupère l'adresse de la variable
                  Variables et on ajoute le nom de la variable }
                tmp2 := UniqId ;
                PointerOfVariables.Add(tmp2, Variables) ;
                Result := 'p{' + tmp2 + tmp  + Tab + '}'
            end
            else if isReference
            then
                Result := GetReference(tmp + Tab)
            else
                Result := Variables.Give(tmp + Tab) ;

            if Variables.isSet(tmp + Tab) = False
            then
                WarningMsg(Format(sVariableDoesntExist, [tmp ])) ;

        end ;
    end
    else begin
        ErrorMsg(sInvalidVarName) ;
        Result := '' ;
    end ;
end ;


{*******************************************************************************
 * Fonction vérfie si le nom de la variable est valide
 *
 *  Entrée
 *   start   : Index de début de vérification de la variable (juste après le $)
 *   VarName : texte contenant la variable
 *
 *  Retour : true ou false
 ******************************************************************************}
function CheckVarName(start : Integer; VarName : string) : boolean ;
var i, nb : Integer ;
begin
    if not (VarName[start] in ['0'..'9'])
    then begin
        Result := True ;
        nb := Length(VarName) ;

        // (start + 1)
        for i := start to nb do
        begin
            if not ((VarName[i] in ['a'..'z']) or (VarName[i] in ['0'..'9']) or (VarName[start] = '_'))
            then begin
                Result := False ;
                break ;                
            end ;
        end ;

        { Si il y a une erreur c'est peut-être un crochet }
        if Result = False
        then begin
            if (VarName[i] = '[') and (VarName[nb] = ']')
            then begin
                Result := True ;
            end ;
        end ;
    end
    else
        Result := False ;

    if Result = False
    then
        ErrorMsg(sInvalidVarName) ;
end ;

{*******************************************************************************
 * Fonction vérfie qu'il s'agit d'une variable
 *
 *  Entrée
 *   text : nom de la variable
 *
 *  Retour : true ou false
 ******************************************************************************}
function isVar(text : string) : boolean ;
Var nb : integer ;
begin
    text := LowerCase(text) ;
    nb := length(text) ;
    Result := False ;
    
    if nb > 1
    then begin
        if text[1] = '$'
        then begin
            if nb > 1
            then begin
                if text[2] = '$'
                then begin
                    Result := CheckVarName(3, text) ;
                end
                else begin
                    Result := CheckVarName(2, text) ;
                end ;
            end
            else begin
                Result := CheckVarName(2, text) ;
            end ;
        end
        else if (text[1] = '&') or (text[1] = '*')
        then begin
            { Est-ce un pointeur sur une variable ? }
            if nb > 2
            then begin
                if text[2] = '$'
                then begin
                    Result := CheckVarName(3, text) ;
                end ;
            end
            else begin
                Result := False ;            
            end ;
        end 
        else begin
            Result := False ;
        end ;
    end
    else begin
        Result := False ;
    end ;
end ;

{*******************************************************************************
 * Fonction convertit une TStringList liste en valeur (1+2 => 3)
 ******************************************************************************}
function GetValueOfStrings(var arguments : TStringList) : Integer ;
var i, Index : Integer ;
    Entier : LongInt ;
    argumentsAvecParentheses : TStringList ;
    nbParentheses : Integer ;
    nbElements : Integer ;
    foundIn : Boolean ;
    Floattant : Extended ;
    Pos : Integer ;
    fonction : ModelProcedure ;
    nb : Integer ;
    condition : String ;
    Itmp : Integer ;
    tmp1, tmp2 : String ;
    { Marqueur de fonction }
    FunctionMarque : TStringList ;

    procedure DeleteElementInCurrentLine(Index : Integer) ;
    begin
        arguments.Delete(Index) ;

        if Index < FunctionMarque.Count
        then
            FunctionMarque.Delete(Index) ;
    end ;

label EndOfGetValueOfStrings ;

begin
    argumentsAvecParentheses := TStringList.Create ;
    FunctionMarque := TStringList.Create ;

    nb := arguments.Count ;
    i := 0 ;

    {ETAPE 0 : marquer les fonctions }
    while i < nb do
    begin
        condition := LowerCase(arguments[i]) ;

        if arguments[i] <> ''
        then begin
            if ((arguments[i][1] in ['a'..'z']) or (arguments[i][1] in ['A'..'Z']) or (arguments[i][1] = '_')) and
                    (condition <> 'in') and (condition <> 'or') and
                    (condition <> 'xor') and (condition <> 'and') and
                    (condition <> 'not') and (condition <> 'to') and
                    (condition <> 'step') and (condition <> 'case') and
                    (condition <> 'default')
            then begin
                { c'est une fonction }
                FunctionMarque.Add('1') ;
            end
            else begin
                FunctionMarque.Add('0') ;
            end ;
        end ;

        Inc(i) ;
   end ;

    i := 0 ;


    {ETAPE 1 : convertire les variables et fonctions }
    while i < nb do
    begin
        condition := LowerCase(arguments[i]) ;

        if arguments[i] <> ''
        then begin
            if isVar(arguments[i])
            then begin
                arguments[i] := getVar(arguments[i])
            end
            else begin
                { Est-ce une fonction ? }
                if FunctionMarque[i] = '1'
                then begin
                    { Si on a trouvé une parenthèse ouvrante, on doit la traiter à part }
                    nbParentheses := 0 ;
                    nbElements := 0 ;
                    argumentsAvecParentheses.Clear ;
                    
                    for Index := (i + 1) to arguments.Count - 1 do
                    begin
                        { Compte le nombre d'élément }
                        Inc(nbElements) ;
                        argumentsAvecParentheses.Add(arguments[Index]) ;

                        if arguments[Index] = '('
                        then
                            Inc(nbParentheses)
                        else if arguments[Index] = ')'
                        then
                            Dec(nbParentheses) ;

                        if nbParentheses = 0
                        then
                            break ;
                    end ;

                    { Supprime les paramètres de la ligne de commandee }
                    for Index := 1 to nbElements do
                    begin
                        DeleteElementInCurrentLine(i+1) ;
                        Dec(nb) ;
                    end ;

                    DeleteVirguleAndParenthese(argumentsAvecParentheses) ;

                    fonction := ListFunction.Give(arguments[i]) ;
                    ResultFunction := '' ;

                    if @fonction <> nil
                    then begin
                        if ListFunction.isParse(arguments[i])
                        then
                            GetValueOfStrings(argumentsAvecParentheses) ;

                        fonction(argumentsAvecParentheses) ;
                    end
                    else begin
                        GetValueOfStrings(argumentsAvecParentheses) ;

                        if not CallExtension(arguments[i], argumentsAvecParentheses)
                        then begin
                            Itmp := ExecuteUserProcedure(arguments[i], argumentsAvecParentheses) ;

                            if Itmp <> -1
                            then begin
                                { +1 car ExecuteUserProcedure 1 de trop pour notre cas }
                                CurrentLineNumber := Itmp + 1 ;
                                goto EndOfGetValueOfStrings ;
                            end ;
                        end ;
                    end ;

                    { On met le résultat entre crochet pour éviter que le résultat soit
                      interprété par exemple sur on retourne le caractère - }
                    arguments[i] := '"' + ResultFunction + '"' ;
                end ;
            end ;
        end ;

        Inc(i) ;
    end ;

    {ETAPE 2 : chercher les parenthèses }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('(') ;

            if Index <> -1
            then begin
                { On a trouvé une parenthèse ouvrante, on doit la traiter à part }
                nbParentheses := 1 ;
                nbElements := 0 ;
                argumentsAvecParentheses.Clear ;

                { démarre après la parenthèse ouvrante }
                for i := (Index + 1) to arguments.Count - 1 do
                begin
                    if arguments[i] = '('
                    then
                        Inc(nbParentheses)
                    else if arguments[i] = ')'
                    then
                        Dec(nbParentheses) ;

                    { évite d'avoir la parenthèse fermante }
                    if nbParentheses = 0
                    then
                        break ;

                    argumentsAvecParentheses.Add(arguments[i]) ;
                    { Compte le nombre d'élément }
                    Inc(nbElements) ;
                end ;

                { Vérifie qu'on n'a pas oublié de parenthèses }
                if (Index + NbElements + 1) < arguments.Count
                then begin
                    { Supprime tout les éléments qu'il y entre parenthèse + la dernière
                      parenthèse }
                    for i := 1 to nbElements + 1 do
                    begin
                        arguments.Delete(Index) ;
                    end ;

                    { Enregistre à la place de la parenthèse la valeur }
                    if GetValueOfStrings(argumentsAvecParentheses) = 1
                    then
                        arguments[Index] := argumentsAvecParentheses[0]
                    else begin
                        ErrorMsg(sMissingOperator) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(sMissingPar) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 2bis convertir x * - y en x * (-1)}
    if (not GlobalError) and (not GlobalQuit)
    then begin
        Index := -1 ;

        repeat
            if Index = -1
            then
                i := 0
            else
                i := Index + 1 ;
                
            Index := -1 ;

            for i := i to arguments.count - 1 do
            begin
                if arguments[i] = '-'
                then begin
                    Index := i ;
                    break ;
                end ;
            end ;

            if Index <> -1
            then begin
                if Index > 0
                then begin
                    if not isNumeric(GetString(arguments[Index - 1]))
                    then begin
                        arguments.Delete(Index) ;
                        arguments[Index] := '-' + GetString(arguments[Index]) ;
                    end ;
                end
                else begin
                    tmp1 := GetString(arguments[Index + 1]) ;

                    if isNumeric(tmp1)
                    then begin
                        arguments.Delete(Index) ;
                        arguments[Index] := '-' + tmp1 ;
                    end
                    else
                        ErrorMsg(Format(sNoOnString, ['-'])) ;
                end ;
            end ;
        until Index = -1 ;
    end ;

    {ETAPE 3 : Chercher in }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            { L'aventage de IndexOf c'est qu'il fait une recherche sans tenir
              compte de la case }
            Index := arguments.IndexOf('in') ;

            if Index <> -1
            then begin
                { $var in [ "truc", "machin" }
                if arguments[Index + 1] = '['
                then begin
                    foundIn := False ;

                    { Supprime le "in" }
                    arguments.Delete(Index) ;

                    { supprime le "[" }
                    arguments.Delete(Index) ;

                    Pos := 1 ;
                    
                    while Index < (arguments.Count - 1) do
                    begin
                        if not foundIn
                        then begin
                            if GetString(arguments[Index]) = arguments[Index - 1]
                            then begin
                                foundIn := True ;
                            end ;
                        end ;

                        { Va à l'élément suivant }
                        arguments.Delete(Index) ;

                        if arguments[Index] = ','
                        then
                            arguments.Delete(Index)
                        else if arguments[Index] = ']'
                        then
                            break ;

                        Inc(Pos) ;
                    end ;

                    if arguments[Index] <> ']'
                    then begin
                        { On a atteind la fin de la ligne sans trouver de "]"}
                        ErrorMsg(sMissingCrochet) ;
                        break ;
                    end
                    else begin
                        { Supprimer le ']' }
                        arguments.Delete(Index) ;
                        
                        if foundIn
                        then
                           { -1 car Inc(Index) avant de quitter la boucle }
                           arguments[Index - 1] := IntToStr(Pos)
                        else
                           arguments[Index - 1] := falseValue ;

                        { supprimer les éléments }
                    end ;

                end
                else begin
                    ErrorMsg(sMissingCrochet2) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 5 : Chercher ~ (not) }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('~') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément }
                if (Index + 1) < arguments.Count
                then begin
                    tmp1 := GetString(arguments[Index + 1]) ;

                    if isNumeric(tmp1)
                    then begin
                        { x   : ~
                          x+1 : value

                          on remplace x par la valeur négative. Il faut alors
                          supprimer x+1 }
                        if isInteger(tmp1)
                        then begin
                            Entier := MyStrToInt(tmp1) ;
                            arguments[Index] := IntToStr(not Entier) ;
                        end
                        else begin
                            ErrorMsg(sNoTildeOnFloat) ;
                            break ;
                        end ;

                        arguments.Delete(Index + 1);
                    end
                    else begin
                        ErrorMsg(Format(sNoOnString, ['~'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(sMissingAfterOperator, ['~'])) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 6 : Chercher ^ (puissance) }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('^') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((Index + 1) < arguments.Count) and (Index <> 0)
                then begin
                    tmp1 := GetString(arguments[Index + 1]) ;
                    tmp2 := GetString(arguments[Index - 1]) ;

                    if isInteger(tmp1) and isInteger(tmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        Entier := MyStrToInt(tmp1) ;

                        Entier := FloatToInt(caree(MyStrToFloat(tmp2), Entier)) ;

                        arguments[Index] := IntToStr(Entier) ;
                        arguments.Delete(Index - 1);
                        { x-1 : ^
                          x  : value
                        }
                        arguments.Delete(Index);
                    end
                    else if isFloat(tmp1) and isFloat(tmp2)
                    then begin
                        if isInteger(tmp1)
                        then begin
                            { x-1  : value
                              x   : ^
                              x+2 : value
                              on remplace x par le résultat. Il faut alors supprimer
                              x et x+2}
                            Floattant := MyStrToFloat(tmp2) ;

                            Entier := MyStrToInt(tmp1) ;
                                
                            Floattant := caree(Floattant, Entier) ;
                            arguments[Index] := MyFloatToStr(Floattant) ;
                            arguments.Delete(Index - 1);
                            { x-1 : ^
                              x  : value
                            }
                            arguments.Delete(Index);
                        end
                        else begin
                             ErrorMsg(sExposantNotInteger) ;
                             break ;
                        end ;
                    end
                    else begin
                        ErrorMsg(Format(sNoOnString, ['^'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(sMissingAfterOperator, ['^'])) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 7 : Chercher *  }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('*') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((Index + 1) < arguments.Count) and (Index <> 0)
                then begin
                    tmp1 := GetString(arguments[Index + 1]) ;
                    tmp2 := GetString(arguments[Index - 1]) ;

                    if isInteger(tmp1) and isInteger(tmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        Entier := MyStrToInt(tmp2) * MyStrToInt(tmp1) ;
                        arguments[Index] := IntToStr(Entier) ;
                        arguments.Delete(Index - 1);
                        { x-1 : ^
                          x  : value
                        }
                        arguments.Delete(Index);
                    end
                    else if isFloat(tmp1) and isFloat(tmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        Floattant := MyStrToFloat(tmp2) * MyStrToFloat(tmp1) ;
                        arguments[Index] := MyFloatToStr(Floattant) ;
                        arguments.Delete(Index - 1);
                        { x-1 : ^
                          x  : value
                        }
                        arguments.Delete(Index);
                    end
                    else begin
                        ErrorMsg(Format(sNoOnString, ['*'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(sNoValueAfter, ['*'])) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 8 : Chercher /  }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('/') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((Index + 1) < arguments.Count) and (Index <> 0)
                then begin
                    tmp1 := GetString(arguments[Index + 1]) ;
                    tmp2 := GetString(arguments[Index - 1]) ;

                    if isInteger(tmp1) and isInteger(tmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        Entier := MyStrToInt(tmp1) ;

                        if Entier <> 0
                        then begin
                            Entier := MyStrToInt(tmp2) div Entier ;
                            arguments[Index] := IntToStr(Entier) ;
                            arguments.Delete(Index - 1);
                            { x-1 : ^
                              x  : value
                            }
                            arguments.Delete(Index);
                        end
                        else begin
                             ErrorMsg(sDivideByZero) ;
                             break ;
                        end ;
                    end
                    else if isFloat(tmp1) and isFloat(tmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        Floattant := MyStrToFloat(tmp1) ;

                        if Floattant <> 0
                        then begin
                            Floattant := MyStrToFloat(tmp2) / Floattant ;
                            arguments[Index] := MyFloatToStr(Floattant) ;
                            arguments.Delete(Index - 1);
                            { x-1 : ^
                              x  : value
                            }
                            arguments.Delete(Index);
                        end
                        else begin
                             ErrorMsg(sDivideByZero) ;
                             break ;
                        end ;
                    end
                    else begin
                        ErrorMsg(Format(sNoOnString, ['/'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(sNoValueAfter, ['/'])) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 9 : Chercher %  }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('%') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((Index + 1) < arguments.Count) and (Index <> 0)
                then begin
                    tmp1 := GetString(arguments[Index + 1]) ;
                    tmp2 := GetString(arguments[Index - 1]) ;

                    if isInteger(tmp1) and isInteger(tmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        Entier := MyStrToInt(tmp2) mod MyStrToInt(tmp1) ;
                        arguments[Index] := IntToStr(Entier) ;
                        arguments.Delete(Index - 1);
                        { x-1 : ^
                          x  : value
                        }
                        arguments.Delete(Index);
                    end
                    else begin
                        ErrorMsg(sNoOnStringOrFloat) ;
                        Break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(sNoValueAfter, ['%'])) ;
                    Break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 10 : Chercher +  }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('+') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((Index + 1) < arguments.Count) and (Index <> 0)
                then begin
                    tmp1 := GetString(arguments[Index + 1]) ;
                    tmp2 := GetString(arguments[Index - 1]) ;

                    if isInteger(tmp1) and isInteger(tmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x+1 par le résultat. Il faut alors supprimer
                          x et x+2}
                        Entier := MyStrToInt(tmp2) + MyStrToInt(tmp1) ;
                        arguments[Index] := IntToStr(Entier) ;
                        arguments.Delete(Index - 1);
                        { x-1 : ^
                          x  : value
                        }
                        arguments.Delete(Index);
                    end
                    else if isFloat(tmp1) and isFloat(tmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x+1 par le résultat. Il faut alors supprimer
                          x et x+2}
                        Floattant := MyStrToFloat(tmp2) + MyStrToFloat(tmp1) ;
                        arguments[Index] := MyFloatToStr(Floattant) ;
                        arguments.Delete(Index - 1);
                        { x-1 : ^
                          x  : value
                        }
                        arguments.Delete(Index);
                    end
                    else begin
                        { x-1 : string
                          x   : +
                          x+1 : string
                        }
                        arguments[Index - 1] := tmp2 + tmp1 ;

                        arguments.Delete(Index);
                        arguments.Delete(Index);
                    end ;
                end
                else begin
                    ErrorMsg(Format(sNoValueAfter, ['+'])) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 10 : Chercher -  }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('-') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément }
                if ((Index + 1) < arguments.Count)
                then begin
                    tmp1 := GetString(arguments[Index + 1]) ;
                    tmp2 := GetString(arguments[Index - 1]) ;

                    if isInteger(tmp1) or isInteger(tmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        Entier := MyStrToInt(tmp2) - MyStrToInt(tmp1) ;
                        arguments[Index] := IntToStr(Entier) ;
                        arguments.Delete(Index - 1);
                        { x-1 : ^
                          x  : value
                        }
                        arguments.Delete(Index);
                    end
                    else if isFloat(tmp1) or isFloat(tmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        Floattant := MyStrToFloat(tmp2) - MyStrToFloat(tmp1) ;
                        arguments[Index] := MyFloatToStr(Floattant) ;
                        arguments.Delete(Index - 1);
                        { x-1 : ^
                          x  : value
                        }
                        arguments.Delete(Index);
                    end ;
                end
                else begin
                    ErrorMsg(Format(sNoValueAfter, ['-'])) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 12 : Chercher <<  }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('<<') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((Index + 1) < arguments.Count) and (Index <> 0)
                then begin
                    tmp1 := GetString(arguments[Index + 1]) ;
                    tmp2 := GetString(arguments[Index - 1]) ;

                    if isNumeric(tmp1) and isNumeric(tmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        Entier := MyStrToInt(tmp2) shr MyStrToInt(tmp1) ;
                        arguments[Index] := IntToStr(Entier) ;
                        arguments.Delete(Index - 1);
                        { x-1 : ^
                          x  : value
                        }
                        arguments.Delete(Index);
                    end
                    else begin
                        ErrorMsg(Format(sNoOnString, ['<<'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(sNoValueAfter, ['<<'])) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 13 : Chercher >>  }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('>>') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((Index + 1) < arguments.Count) and (Index <> 0)
                then begin
                    tmp1 := GetString(arguments[Index + 1]) ;
                    tmp2 := GetString(arguments[Index - 1]) ;

                    if isNumeric(tmp1) and isNumeric(tmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        Entier := MyStrToInt(tmp2) shl MyStrToInt(tmp1) ;
                        arguments[Index] := IntToStr(Entier) ;
                        arguments.Delete(Index - 1);
                        { x-1 : ^
                          x  : value
                        }
                        arguments.Delete(Index);
                    end
                    else begin
                        ErrorMsg(Format(sNoOnString, ['>>'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(sNoValueAfter, ['>>'])) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 14 : Chercher &  }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('&') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((Index + 1) < arguments.Count) and (Index <> 0)
                then begin
                    tmp1 := GetString(arguments[Index + 1]) ;
                    tmp2 := GetString(arguments[Index - 1]) ;

                    if isNumeric(tmp1) and isNumeric(tmp2)
                    then begin
                        { x-1  : value
                          x   : &
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        Entier := MyStrToInt(tmp2) and MyStrToInt(tmp1) ;
                        arguments[Index] := IntToStr(Entier) ;
                        arguments.Delete(Index - 1);
                        { x-1 : ^
                          x  : value
                        }
                        arguments.Delete(Index);
                    end
                    else begin
                        ErrorMsg(Format(sNoOnString, ['&'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(sNoValueAfter, ['&'])) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 15 : Chercher &|  }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('&|') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((Index + 1) < arguments.Count) and (Index <> 0)
                then begin
                    tmp1 := GetString(arguments[Index + 1]) ;
                    tmp2 := GetString(arguments[Index - 1]) ;

                    if isNumeric(tmp1) and isNumeric(tmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        Entier := MyStrToInt(tmp2) xor MyStrToInt(tmp1) ;
                        arguments[Index] := IntToStr(Entier) ;
                        arguments.Delete(Index - 1);
                        { x-1 : ^
                          x  : value
                        }
                        arguments.Delete(Index);
                    end
                    else begin
                        ErrorMsg(Format(sNoOnString, ['&|'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(sNoValueAfter, ['&|'])) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 16 : Chercher |  }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('|') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((Index + 1) < arguments.Count) and (Index <> 0)
                then begin
                    tmp1 := GetString(arguments[Index + 1]) ;
                    tmp2 := GetString(arguments[Index - 1]) ;

                    if isNumeric(tmp1) and isNumeric(tmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        Entier := MyStrToInt(tmp2) xor MyStrToInt(tmp1) ;
                        arguments[Index] := IntToStr(Entier) ;
                        arguments.Delete(Index - 1);
                        { x-1 : ^
                          x  : value
                        }
                        arguments.Delete(Index);
                    end
                    else begin
                        ErrorMsg(Format(sNoOnString, ['|'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(sNoValueAfter, ['|'])) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 17 : Chercher = }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('=') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((Index + 1) < arguments.Count) and (Index <> 0)
                then begin
                    { x-1  : value
                      x   : =
                      x+2 : value
                      on remplace x par le résultat. Il faut alors supprimer
                      x et x+2}
                    tmp1 := GetString(arguments[Index + 1]) ;
                    tmp2 := GetString(arguments[Index - 1]) ;

                    if isFloat(tmp2) and isFloat(tmp1)
                    then begin
                        if (MyStrToFloat(tmp2) = MyStrToFloat(tmp1))
                        then
                           arguments[Index] := TrueValue
                        else
                           arguments[Index] := FalseValue ;
                    end
                    else begin
                        if (tmp1 = tmp2)
                        then
                           arguments[Index] := TrueValue
                        else
                           arguments[Index] := FalseValue ;
                    end ;

                    arguments.Delete(Index - 1);
                    { x-1 : ^
                      x  : value
                    }
                    arguments.Delete(Index);
                end
                else begin
                    ErrorMsg(Format(sNoValueAfter, ['='])) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 18 : Chercher > }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('>') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((Index + 1) < arguments.Count) and (Index <> 0)
                then begin
                    { x-1  : value
                      x   : >
                      x+2 : value
                      on remplace x par le résultat. Il faut alors supprimer
                      x et x+2}
                    tmp1 := GetString(arguments[Index + 1]) ;
                    tmp2 := GetString(arguments[Index - 1]) ;

                    if isFloat(tmp2) and isFloat(tmp1)
                    then begin
                        if (MyStrToFloat(tmp2) > MyStrToFloat(tmp1))
                        then
                           arguments[Index] := TrueValue
                        else
                           arguments[Index] := FalseValue ;
                    end
                    else begin
                        if (tmp2 > tmp1)
                        then
                           arguments[Index] := TrueValue
                        else
                           arguments[Index] := FalseValue ;
                    end ;


                    arguments.Delete(Index - 1);
                    { x-1 : ^
                      x  : value
                    }
                    arguments.Delete(Index);
                end
                else begin
                    ErrorMsg(Format(sNoValueAfter, ['>'])) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 19 : Chercher < }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('<') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((Index + 1) < arguments.Count) and (Index <> 0)
                then begin
                    { x-1  : value
                      x   : <
                      x+2 : value
                      on remplace x par le résultat. Il faut alors supprimer
                      x et x+2}
                    tmp1 := GetString(arguments[Index + 1]) ;
                    tmp2 := GetString(arguments[Index - 1]) ;

                    if isFloat(tmp2) and isFloat(tmp1)
                    then begin
                        if (MyStrToFloat(tmp2) < MyStrToFloat(tmp1))
                        then
                           arguments[Index] := TrueValue
                        else
                           arguments[Index] := FalseValue ;
                    end
                    else begin
                        if (tmp2 < tmp1)
                        then
                           arguments[Index] := TrueValue
                        else
                           arguments[Index] := FalseValue ;
                    end ;


                    arguments.Delete(Index - 1);
                    { x-1 : ^
                      x  : value
                    }
                    arguments.Delete(Index);
                end
                else begin
                    ErrorMsg(Format(sNoValueAfter, ['<'])) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 20 : Chercher >= }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('>=') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((Index + 1) < arguments.Count) and (Index <> 0)
                then begin
                    { x-1  : value
                      x   : ^
                      x+2 : value
                      on remplace x par le résultat. Il faut alors supprimer
                      x et x+2}
                    tmp1 := GetString(arguments[Index + 1]) ;
                    tmp2 := GetString(arguments[Index - 1]) ;

                    if isFloat(tmp2) and isFloat(tmp1)
                    then begin
                        if (MyStrToFloat(tmp2) >= MyStrToFloat(tmp1))
                        then
                           arguments[Index] := TrueValue
                        else
                           arguments[Index] := FalseValue ;
                    end
                    else begin
                        if (tmp2 >= tmp1)
                        then
                           arguments[Index] := TrueValue
                        else
                           arguments[Index] := FalseValue ;
                    end ;

                    arguments.Delete(Index - 1);
                    { x-1 : ^
                      x  : value
                    }
                    arguments.Delete(Index);
                end
                else begin
                    ErrorMsg(Format(sNoValueAfter, ['>='])) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 21 : Chercher <= }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('<=') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((Index + 1) < arguments.Count) and (Index <> 0)
                then begin
                    { x-1  : value
                      x   : ^
                      x+2 : value
                      on remplace x par le résultat. Il faut alors supprimer
                      x et x+2}
                    tmp1 := GetString(arguments[Index + 1]) ;
                    tmp2 := GetString(arguments[Index - 1]) ;

                    if isFloat(tmp2) and isFloat(tmp1)
                    then begin
                        if (MyStrToFloat(tmp2) <= MyStrToFloat(tmp1))
                        then
                           arguments[Index] := TrueValue
                        else
                           arguments[Index] := FalseValue ;
                    end
                    else begin
                        if (tmp2 <= tmp1)
                        then
                           arguments[Index] := TrueValue
                        else
                           arguments[Index] := FalseValue ;
                    end ;

                    arguments.Delete(Index - 1);
                    { x-1 : ^
                      x  : value
                    }
                    arguments.Delete(Index);
                end
                else begin
                    ErrorMsg(Format(sNoValueAfter, ['<='])) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 22 : Chercher <> }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('<>') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((Index + 1) < arguments.Count) and (Index <> 0)
                then begin
                    { x-1  : value
                      x   : ^
                      x+2 : value
                      on remplace x par le résultat. Il faut alors supprimer
                      x et x+2}
                    tmp1 := GetString(arguments[Index + 1]) ;
                    tmp2 := GetString(arguments[Index - 1]) ;

                    if isFloat(tmp2) and isFloat(tmp1)
                    then begin
                        if (MyStrToFloat(tmp2) <> MyStrToFloat(tmp1))
                        then
                           arguments[Index] := TrueValue
                        else
                           arguments[Index] := FalseValue ;
                    end
                    else begin
                        if (tmp2 <> tmp1)
                        then
                           arguments[Index] := TrueValue
                        else
                           arguments[Index] := FalseValue ;
                    end ;

                    arguments.Delete(Index - 1);
                    { x-1 : ^
                      x  : value
                    }
                    arguments.Delete(Index);
                end
                else begin
                    ErrorMsg(Format(sNoValueAfter, ['<>'])) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 23 : Chercher and  }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('and') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((Index + 1) < arguments.Count) and (Index <> 0)
                then begin
                    tmp1 := GetString(arguments[Index + 1]) ;
                    tmp2 := GetString(arguments[Index - 1]) ;

                    if isNumeric(tmp1) and isNumeric(tmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}

                        if (tmp1 <> FalseValue) and (tmp2 <> FalseValue)
                        then
                           arguments[Index] := TRueValue
                        else
                           arguments[Index] := FalseValue ;

                        arguments.Delete(Index - 1);
                        { x-1 : ^
                          x  : value
                        }
                        arguments.Delete(Index);
                    end
                    else begin
                        ErrorMsg(Format(sNoOnString, ['and'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(sNoValueAfter, ['and'])) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 24 : Chercher xor }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('xor') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((Index + 1) < arguments.Count) and (Index <> 0)
                then begin
                    tmp1 := GetString(arguments[Index + 1]) ;
                    tmp2 := GetString(arguments[Index - 1]) ;

                    if isNumeric(arguments[Index + 1]) and isNumeric(arguments[Index - 1])
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}

                        if (tmp2 <> FalseValue) xor (tmp1 <> FalseValue)
                        then
                           arguments[Index] := TrueValue
                        else
                           arguments[Index] := FalseValue ;

                        arguments.Delete(Index - 1);
                        { x-1 : ^
                          x  : value
                        }
                        arguments.Delete(Index);
                    end
                    else begin
                        ErrorMsg(Format(sNoOnString, ['xor'])) ;
                        Break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(sNoValueAfter, ['xor'])) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 25 : Chercher or }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('or') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((Index + 1) < arguments.Count) and (Index <> 0)
                then begin
                    tmp1 := GetString(arguments[Index + 1]) ;
                    tmp2 := GetString(arguments[Index - 1]) ;

                    if isNumeric(tmp2) and isNumeric(tmp1)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}

                        if (tmp2 <> FalseValue) or (tmp1 <> FalseValue)
                        then
                           arguments[Index] := TrueValue
                        else
                           arguments[Index] := FalseValue ;

                        arguments.Delete(Index - 1);
                        { x-1 : ^
                          x  : value
                        }
                        arguments.Delete(Index);
                    end
                    else begin
                        ErrorMsg(Format(sNoOnString, ['or'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(sNoValueAfter, ['or'])) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 26 : Chercher not }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('not') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément }
                if (Index + 1) < arguments.Count
                then begin
                    tmp1 := GetString(arguments[Index + 1]) ;

                    if isNumeric(tmp1)
                    then begin
                        { x   : ~
                          x+1 : value

                          on remplace x par la valeur négative. Il faut alors
                          supprimer x+1 }
                        if tmp1 = FalseValue
                        then
                            arguments[Index] := FalseValue
                        else
                            arguments[Index] := TrueValue ;

                        arguments.Delete(Index + 1);
                    end
                    else begin
                        ErrorMsg(Format(sNoOnString, ['not'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(sNoValueAfter, ['not'])) ;
                    break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 27 : Chercher . }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('.') ;

            if Index <> -1
            then begin
                { Si ce n'est pas le dernier élément }
                if (Index + 1) < arguments.Count
                then begin
                        { x-1 : value
                          x   : .
                          x+1 : value
                        }
                        arguments[Index - 1] := GetString(arguments[Index - 1]) + GetString(arguments[Index + 1]) ;

                        arguments.Delete(Index);
                        arguments.Delete(Index);
                end
                else begin
                    ErrorMsg(Format(sNoValueAfter, ['.'])) ;
                    Break ;
                end ;
            end ;
        until Index = -1 ;

    {ETAPE 28 : Chercher ? }
    if (not GlobalError) and (not GlobalQuit)
    then
        repeat
            Index := arguments.IndexOf('?') ;

            if Index <> -1
            then begin
                if (Index = 0) or ((Index + 1) > (arguments.Count - 1))
                then begin
                    ErrorMsg(sMissingargument) ;
                    break ;
                end
                else begin
                    tmp2 := GetString(arguments[Index - 1]) ;
                    
                    if tmp2 = falseValue
                    then begin
                        Dec(Index) ;
                        { Supprime la condition }
                        arguments.Delete(Index) ;
                        { Supprime le ? }
                        arguments.Delete(Index) ;
                        { Supprime la valeur si }
                        arguments.Delete(Index) ;

                        if Index >= arguments.Count
                        then
                            arguments.Add('')
                        else
                            { Maintement index pointe sur ":" normalement }
                            if arguments[Index] = ':'
                            then begin
                                { supprime le : }
                                arguments.Delete(Index) ;
                            end ;
                    end
                    else begin
                        { Index = ?, Index+1 = valeur_si_vrai, Index+2 = :}
                        for i := Index + 2 to arguments.Count - 1 do
                        begin
                            if arguments[i] = ':'
                            then begin
                                if i < arguments.Count
                                then
                                    arguments.Delete(i) ;

                                arguments.Delete(i) ;

                                break ;
                            end ;
                        end ;

                        { Supprime la valeur de teste }
                        arguments.Delete(Index - 1) ;
                        { Supprime le ? }
                        arguments.Delete(Index - 1) ;
                    end ;
                end ;
            end ;
        until Index = -1 ;

EndOfGetValueOfStrings :
    Result := arguments.Count ;

    for i := 0 to arguments.Count - 1 do
    begin
        arguments[i] := GetString(arguments[i]) ;
    end ;

    argumentsAvecParentheses.Free ;
end ;

{*******************************************************************************
 * Fonction qui indique si la valeur est un nombre
 *
 *  Entrée
 *   nombre : texte à vérifier
 ******************************************************************************}
function isNumeric(nombre : string) : boolean ;
var i : Integer ;
    start : Integer ;
    nb : Integer ;
    point : Boolean ;
begin
    Result := True ;
    point := False ;

    if nombre <> ''
    then begin
        nb := Length(nombre) ;

        if nombre[1] = '-'
        then
            start := 2
        else
            start := 1 ;

        if nb > 2
        then begin
            { Est un nombre hexadécimmal ? }
            if (nombre[1] = '0') and (LowerCase(nombre[2]) = 'x')
            then
                start := start + 2 ;
        end ;

        //for i := start to nb do
        i := start ;

        while i < nb + 1 do
        begin
            if (nombre[i] = '.') and (Point = False)
            then begin
                Point := True ;
                Inc(i) ;
            end ;

            if not ( (nombre[i] in ['0'..'9']) or (nombre[i] in ['a'..'f']) or
                     (nombre[i] in ['A'..'F']) )
            then begin
                Result := False ;
                break ;
            end ;

            Inc(i) ;
        end ;
    end
    else
        Result := False ;
end ;

{*******************************************************************************
 * Fonction qui donne la valeur exposant
 *
 *  Entrée
 *   value    : nombre à exposer
 *   exposant : exposant
 *
 *  Retour : valeur du nombre à la puissance exposant
 ******************************************************************************}
function caree(value : Extended; exposant : integer) : Extended;
var
    i:Extended;
    j : Integer ;
begin
    if (exposant >= 0)
    then begin
        Result := 1 ;

        for j := 1 to exposant do
            Result := Result * value ;

        if exposant = 0
        then
            Result := 1 ;
    end
    else begin
        exposant := -1 * exposant ;

        i := caree(value, exposant) ; 
        Result := 1 / i ;
    end ;
end ;

{*******************************************************************************
 * Supprime la variable
 *
 *  Entrée
 *   variable : nom de la variable à supprimer (avec $)
 ******************************************************************************}
procedure delVar(variable : string) ;
var tmp : string ;
    Len : Integer ;
    isPointer : boolean ;
    Tab : String ;
    Value : TStringList ;
    StartTab : Integer ;
    i : Integer ;
begin
    if (variable <> '$true') and (variable <> '$false') and
       (variable <> '$_version') and
       (variable <> '$_scriptname')
    then begin
        Len := Length(variable) ;
        ispointer := False ;

        if Len > 1
        then begin
            if Length(variable) > 2
            then begin
                if variable[1] = '*'
                then begin
                    { Pointer de variable }
                    variable := copy(variable, 2, Length(variable) - 1) ;
                    isPointer := True ;
                end ;
            end ;

            tmp := variable ;

            { On peut avoir un $$x }
            if variable[2] = '$'
            then begin
                if Len > 2
                then begin
                    { La variable est du type $$x }
                    tmp := copy(variable, 2, Len - 1) ;

                    tmp := Variables.Give(tmp) ;

                    { On peut ne pas avoir de $ pour le nom de variable }
                    if tmp[1] <> '$'
                    then
                        tmp := '$' + tmp ;

                end
                else begin
                    ErrorMsg(sInvalidVarName) ;
                end ;
            end ;

            variable := tmp ;

            StartTab := pos('[', variable) ;

            if StartTab > 0
            then begin
                tmp := copy(variable, 1, StartTab-1) ;
                Tab := copy(variable, StartTab, length(variable) - StartTab + 1) ;

                value := TStringList.Create ;

                { Eclate tout les tableaux }
                ExplodeStrings(Tab, value) ;

                { Convertit les valeurs }
                GetValueOfStrings(value) ;

                { Vérifie que pour chaque élément on ait bien un nombre entier}
                for i := 0 to value.Count - 1 do
                begin
                    if (value[i] <> '[') and (value[i] <> ']')
                    then begin
                        if MyStrToInt(value[i]) = 0
                        then begin
                            ErrorMsg(sInvalidIndex) ;
                            Break ;
                        end ;
                    end ;
                end ;

                if (not GlobalError) and (not GlobalQuit)
                then begin
                    Tab := '' ;

                    for i := 0 to value.Count - 1 do
                    begin
                        Tab := Tab + value[i] ;
                    end ;
                end ;

                value.Free ;

                variable := tmp ;
            end
            else
                Tab := '' ;

            if (not GlobalError) and (not GlobalQuit)
            then begin
                if isPointer
                then
                    unSetReference(variable + Tab)
                else
                    Variables.Delete(variable + Tab) ;
            end ;
        end
        else begin
            ErrorMsg(sInvalidVarName) ;
        end ;
    end
    else
        WarningMsg(sCantDelredifinedVar) ;
end ;

{*******************************************************************************
 * Indique si la variable existe
 *
 *  Entrée
 *   variable : nom de la variable avec $
 *
 *  Retour : true ou false
 ******************************************************************************}
function isSet(variable : string) : boolean ;
var tmp : string ;
    Len : Integer ;
    isPointer : boolean ;
    Tab : String ;
    Value : TStringList ;
    StartTab : Integer ;
    i : Integer ;
begin
    Len := Length(variable) ;
    Result := False ;
    ispointer := False ;

    if Len > 1
    then begin
        if Length(variable) > 2
        then begin
            if variable[1] = '*'
            then begin
                { Pointer de variable }
                variable := copy(variable, 2, Length(variable) - 1) ;
                isPointer := True ;
            end ;
        end ;

        tmp := variable ;

        { On peut avoir un $$x }
        if variable[2] = '$'
        then begin
            if Len > 2
            then begin
                { La variable est du type $$x }
                tmp := copy(variable, 2, Len - 1) ;

                tmp := Variables.Give(tmp) ;

                { On peut ne pas avoir de $ pour le nom de variable }
                if tmp[1] <> '$'
                then
                    tmp := '$' + tmp ;

            end
            else begin
                ErrorMsg(sInvalidVarName) ;
            end ;
        end ;

        variable := tmp ;

        StartTab := pos('[', variable) ;

        if StartTab > 0
        then begin
            tmp := copy(variable, 1, StartTab-1) ;
            Tab := copy(variable, StartTab, length(variable) - StartTab + 1) ;

            value := TStringList.Create ;

            { Eclate tout les tableaux }
            ExplodeStrings(Tab, value) ;

            { Convertit les valeurs }
            GetValueOfStrings(value) ;

            { Vérifie que pour chaque élément on ait bien un nombre entier}
            for i := 0 to value.Count - 1 do
            begin
                if (value[i] <> '[') and (value[i] <> ']')
                then begin
                    if MyStrToInt(value[i]) = 0
                    then begin
                        ErrorMsg(sInvalidIndex) ;
                        Break ;
                    end ;
                end ;
            end ;

            if (not GlobalError) and (not GlobalQuit)
            then begin
                Tab := '' ;

                for i := 0 to value.Count - 1 do
                begin
                    Tab := Tab + value[i] ;
                end ;
            end ;

            value.Free ;

            variable := tmp ;
        end
        else
            Tab := '' ;

        if (not GlobalError) and (not GlobalQuit)
        then begin
            if isPointer
            then
                Result := isSetReference(variable + Tab)
            else
                Result := Variables.isSet(variable + Tab) ;
        end ;
    end
    else begin
        ErrorMsg(sInvalidVarName) ;
    end ;
end ;

{*******************************************************************************
 * Convertit une chaine en entier
 *
 *  Entrée
 *   Nombre : chaine à convertir
 *
 *  Retour : valeur correspondante au texte
 ******************************************************************************}
function MyStrToInt(nombre : string) : LongInt ;
var i : Integer ;
    start : Integer ;
    nb : Integer ;
    hexa : boolean ;
    Indice : Integer ;
    base : Integer ;
    signe : SmallInt ;
    chiffre : SmallInt ;

    function convNumber(caractere : char) : SmallInt ;
    begin
        if caractere = '0'
        then
            Result := 0
        else if caractere = '1'
        then
            Result := 1
        else if caractere = '2'
        then
            Result := 2
        else if caractere = '3'
        then
            Result := 3
        else if caractere = '4'
        then
            Result := 4
        else if caractere = '5'
        then
            Result := 5
        else if caractere = '6'
        then
            Result := 6
        else if caractere = '7'
        then
            Result := 7
        else if caractere = '8'
        then
            Result := 8
        else if caractere = '9'
        then
            Result := 9
        else
            Result := -1
    end ;

    function convHexa(caractere : char) : SmallInt ;
    begin
        if caractere = 'a'
        then
            Result := 10
        else if caractere = 'b'
        then
            Result := 11
        else if caractere = 'c'
        then
            Result := 12
        else if caractere = 'd'
        then
            Result := 13
        else if caractere = 'e'
        then
            Result := 14
        else if caractere = 'f'
        then
            Result := 15
        else
            Result := -1
    end ;
begin
    Result := 0 ;

    try
        hexa := False ;
        if nombre <> ''
        then begin
            nombre := LowerCase(nombre) ;

            nb := Length(nombre) ;
            Indice := 0 ;
            signe := 1 ;

            if nombre[1] = '-'
            then begin
                start := 2;
                signe := -1 ;
            end
            else
                start := 1 ;

            if nb > 2
            then begin
                { Est un nombre hexadécimmal ? }
                if (nombre[1] = '0') and (LowerCase(nombre[2]) = 'x')
                then begin
                    hexa := true ;
                    start := start + 2 ;
                end
                else
                    hexa := False ;
            end ;

            if hexa
            then
                base := 16
            else
                base := 10 ;

            for i := nb downto start do
            begin
                Chiffre := -1 ;

                if nombre[i] in ['0'..'9']
                then begin
                    chiffre := convNumber(Char(nombre[i])) ;
                end
                else begin
                    if hexa
                    then begin
                        if nombre[i] in ['a'..'f']
                        then begin
                            chiffre := convHexa(Char(nombre[i])) ;
                        end ;
                    end ;
                end ;

                if Chiffre <> -1
                then
                    Result := Result + chiffre * FloatToInt(caree(base, Indice))
                else if Hexa
                then
                    ErrorMsg(Format(sNoHexa, [nombre]))
                else
                    ErrorMsg(Format(sNoNumber, [nombre])) ;

                Inc(Indice) ;
            end ;

            Result := signe * Result ;
        end ;
    except
        on EConvertError do ErrorMsg(Format(sNumberToBig, [nombre])) ;
    end ;
end ;

{*******************************************************************************
 * Retourne la partie pointer sur la variable Variables d'une variable pointer
 *
 *  Entrée
 *   text : pointer de variable xxxx$yyyyy
 *
 *  Retour : xxxx
 ******************************************************************************}
function getPointeurOfVariable(text : string) : string ;
var i : Integer ;
begin
    Result := '' ;

    if Length(text) > 1
    then begin
        for i := 3 to Length(text) do
        begin
            if Text[i] = '$'
            then
                break
            else
                Result := Result + Text[i] ;
        end ;
    end
    else
        Result := '' ;
end ;

{*******************************************************************************
 * Retourne la partie variable sur la variable Variables d'une variable pointer
 *
 *  Entrée
 *   text : pointer de variable xxxx$yyyyy
 *
 *  Retour : $yyyyy
 ******************************************************************************}
function getVarNameOfVariable(text : string) : string;
var position : Integer ;
    i : integer ;
begin
    position := pos('$', Text);
    Result := '' ;

    if position > 0
    then begin
        for i := position to Length(Text) - 1 do
        begin
            Result := Result + Text[i] ;
        end ;
    end ;
end ;

{*******************************************************************************
 * Retourne la partie valeur d'une variable pointée
 *
 *  Entrée
 *   text : variable dont il faut retourner la référence
 *
 *  Retour : valeur de la variable
 ******************************************************************************}
function GetReference(text : string) : string;
var PointerOfVar : String ;
    VarName : String ;
    StartTab : Integer ;
    tmp, Tab : String ;
    PointedVariable : TVariables ;
begin
    StartTab := pos('[', text) ;

    if StartTab > 0
    then begin
        tmp := copy(text, 1, StartTab-1) ;
        Tab := copy(text, StartTab, Length(text) - StartTab + 1) ;

        text := tmp ;
    end
    else
        Tab := '' ;

    { On récupère la valeur de la variable pour la traiter }
    text := Variables.Give(text + Tab) ;
    PointerOfVar := getPointeurOfVariable(text) ;
    VarName := getVarNameOfVariable(Text) ;
    Result := '' ;

    if (PointerOfVar <> '') and (VarName <> '')
    then begin
        PointedVariable := PointerOfVariables.Give(PointerOfVar) ;

        if PointedVariable <> nil
        then
            Result := PointedVariable.Give(VarName + Tab)
        else
            Result := '' ;
    end
    else begin
        ErrorMsg(sNotValidPointer) ;
    end ;
end ;

{*******************************************************************************
 * Donne la valeur à une variable pointée
 *
 *  Entrée
 *   text : variable
 *   value : valeur à donner
 ******************************************************************************}
procedure SetReference(text : string; value : string) ;
var PointerOfVar : string ;
    VarName : String ;
    StartTab : Integer ;
    tmp, Tab : String ;
    PointedVariable : TVariables ;
begin
    StartTab := pos('[', text) ;

    if StartTab > 0
    then begin
        tmp := copy(text, 1, StartTab-1) ;
        Tab := copy(text, StartTab, Length(text) - StartTab + 1) ;

        text := tmp ;
    end
    else
        Tab := '' ;

    { On récupère la valeur de la variable pour la traiter }
    if Variables.isArray(text)
    then
        text := Variables.Give(text + Tab)
    else
        text := Variables.Give(text) ;
        
    PointerOfVar := getPointeurOfVariable(text) ;
    VarName := getVarNameOfVariable(Text) ;

    if (PointerOfVar <> '') and (VarName <> '')
    then begin
        PointedVariable := PointerOfVariables.Give(PointerOfVar) ;

        if PointedVariable <> nil
        then
            PointedVariable.Add(VarName + Tab, value) ;
    end
    else begin
        ErrorMsg(sNotValidPointer) ;
    end ;
end ;

{*******************************************************************************
 * Supprime un variable pointée
 *
 *  Entrée
 *   text : variable à supprimer
 ******************************************************************************}
procedure unSetReference(text : string) ;
var PointerOfVar : String ;
    VarName : String ;
    tmp, tab : String ;
    StartTab : Integer ;
    PointedVariable : TVariables ;
begin
    StartTab := pos('[', text) ;

    if StartTab > 0
    then begin
        tmp := copy(text, 1, StartTab-1) ;
        Tab := copy(text, StartTab, Length(text) - StartTab + 1) ;

        text := tmp ;
    end
    else
        Tab := '' ;

    { On récupère la valeur de la variable pour la traiter }
    text := Variables.Give(text) ;
    PointerOfVar := getPointeurOfVariable(text) ;
    VarName := getVarNameOfVariable(Text) ;

    if (PointerOfVar <> '') and (VarName <> '')
    then begin
        PointedVariable := PointerOfVariables.Give(PointerOfVar) ;

        if PointedVariable <> nil
        then
            PointedVariable.Delete(VarName + Tab) ;
    end
    else begin
        ErrorMsg(sNotValidPointer) ;
    end ;
end ;

{*******************************************************************************
 * Indique si une variable pointée existe
 *
 *  Entrée
 *   text : variable à vérifier
 *
 *  Retour : true ou false
 ******************************************************************************}
function isSetReference(text : string) : Boolean ;
var PointerOfVar : String ;
    VarName : String ;
    tmp, tab : String ;
    StartTab : Integer ;
    PointedVariable : TVariables ;
begin
    StartTab := pos('[', text) ;

    if StartTab > 0
    then begin
        tmp := copy(text, 1, StartTab-1) ;
        Tab := copy(text, StartTab, Length(text) - StartTab + 1) ;

        text := tmp ;
    end
    else
        Tab := '' ;

    { On récupère la valeur de la variable pour la traiter }
    text := Variables.Give(text) ;
    PointerOfVar := getPointeurOfVariable(text) ;
    VarName := getVarNameOfVariable(Text) ;
    Result := False ;

    if (PointerOfVar <> '') and (VarName <> '')
    then begin
        PointedVariable := PointerOfVariables.Give(PointerOfVar) ;

        if PointedVariable <> nil
        then
            Result := PointedVariable.isSet(VarName + Tab)
        else
            Result := False ;
    end
    else begin
        ErrorMsg(sNotValidPointer) ;
    end ;
end ;


{*******************************************************************************
 * Ajoute un \ à la fin s'il n'y en a pas
 *
 *  Entrée
 *   text : texte à traiter
 *
 *  Retour : texte traité
 ******************************************************************************}
function AddFinalSlash(text : string) : string ;
begin
    { Vérifie qu'il y a bien le \ final}
    if text[length(text)] <> '\'
    then
        Result := text + '\'
    else
        Result := text ;
end ;

{*******************************************************************************
 * Indique s'il s'agit d'un float
 *
 *  Entrée
 *   nombre : texte à vérifier
 *
 *  Retour : true ou false
 ******************************************************************************}
function isFloat(nombre : String) : Boolean ;
var i : Integer ;
    start : Integer ;
    nb : Integer ;
    Point : Boolean ;
begin
    Result := True ;
    Point := False ;

    if nombre <> ''
    then begin
        nb := Length(nombre) ;

        if nombre[1] = '-'
        then
            start := 2
        else
            start := 1 ;

        for i := start to nb do
        begin
            if not (nombre[i] in ['0'..'9'])
            then begin
                if (nombre[i] = '.') and (Point = False)
                then
                    Point := True
                else begin
                    Result := False ;
                    break ;
                end ;
            end ;
        end ;
    end
    else
        Result := False ;
end ;

{*******************************************************************************
 * Convertie une chaine de caractère en float
 *
 *  Entrée
 *   nombre : texte à convertir
 *
 *  Retour : valeur
 ******************************************************************************}
function MyStrToFloat(nombre : string) : Extended ;
var PartieEntiere : String ;
    PartieFlottante : String ;
    PosPoint : Integer ;
    Entier : LongInt ;
    Decimal : Extended ;
    start : Integer ;
    signe : SmallInt ;

    function convPartieFlottante(nombre : string) : Extended ;
    var i : Integer ;
    begin
        Result := 0 ;

        for i := 1 to Length(nombre) do
        begin
            Result := Result + (MyStrToInt(nombre[i]) / caree(10, i)) ;
        end ;
    end ;
begin
    Result := 0 ;

    try
        PosPoint := pos('.', nombre) ;

        if nombre[1] = '-'
        then begin
            signe := -1 ;
            start := 1 ;
        end
        else begin
            signe := 1 ;
            start := 0 ;
        end ;

        if PosPoint = 0
        then begin
            PartieEntiere := nombre ;
            PartieFlottante := '0' ;
        end
        else begin
            PartieEntiere := copy(nombre, 1 + start, PosPoint - (1 + start)) ;
            PartieFlottante := copy(nombre, PosPoint + 1, Length(nombre) - PosPoint) ;
        end ;

        Entier := MyStrToInt(PartieEntiere) ;

        Decimal := convPartieFlottante(PartieFlottante) ;

        Result := signe * (Entier + Decimal) ;
    except
        on EConvertError do ErrorMsg(Format(sNumberToBig, [nombre])) ;
    end ;
end ;

{*******************************************************************************
 * Convertie un float en chaine de caractère
 *
 * NOTE : on utilise pas directement FloatToStr car nous voulont un séparateur
 *        de flottant en point (.)
 *
 *  Entrée
 *   nombre : nombre à convertir
 *
 *  Retour : chaine
 ******************************************************************************}
function MyFloatToStr(nombre : Extended) : string ;
var PEinteger : LongInt ;
     PartieFlottante : String ;
     signe : boolean ;
begin
    if Nombre < 0
    then begin
        signe := true ;
    end
    else
        signe := false ;

    PEinteger := FloatToInt(nombre) ;
    PartieFlottante := FloatToStr(nombre - PEInteger) ;

    PartieFlottante := copy(PartieFlottante, pos(DecimalSeparator, PartieFlottante) + 1, length(PartieFlottante)) ;

    Result := IntToStr(PEInteger) + '.' + PartieFlottante ;

    if signe
    then
        Result := '-' + Result ;
end ;

{*******************************************************************************
 * Fonction qui indique si la valeur est un entier
 *
 *  Entrée
 *   nombre : chaine à vérifier
 *
 *  Retour : true ou false
 ******************************************************************************}
function isInteger(nombre : string) : boolean ;
var i : Integer ;
    start : Integer ;
    nb : Integer ;
begin
    if nombre <> ''
    then begin
        nb := Length(nombre) ;

        if nombre[1] = '-'
        then
            start := 2
        else
            start := 1 ;

        if nb > 2
        then begin
            { Est un nombre hexadécimmal ? }
            if (nombre[start] = '0') and (LowerCase(nombre[start+1]) = 'x')
            then
                start := start + 2 ;
        end ;

        Result := isHexa(nombre) ;

        if not Result
        then begin
            Result := True ;
            
            for i := start to nb do
            begin
                if not ( (nombre[i] in ['0'..'9']) )
                then begin
                    Result := False ;
                    break ;
                end ;
            end ;
        end ;
    end
    else
        Result := False ;
end ;

{*******************************************************************************
 * Fonction qui convertit un float en entier
 *
 * NOTE : on n'utilise pas trunc car on souhaite intercepter l'erreur
 *
 *  Entrée
 *   nombre : nombre à convertir
 *
 *  Retour : entier
 ******************************************************************************}
function FloatToInt(nombre : extended) : LongInt ;
begin
    Result := 0 ;

    try
        Result := Trunc(nombre) ;
    except
        on EinvalidOp do ErrorMsg(Format(sNumberToBig, [nombre])) ;
    end ;
end ;

{*******************************************************************************
 * Fonction qui charge un fichier de code
 *
 *  Entrée
 *   FileName : nom du fichier à charger
 *   Offset : Numéro de ligne de départ dans CodeList...
 *
 *  Retour : true si le fichier est chargé
 ******************************************************************************}
function LoadCode(FileName : String; Offset : Integer) : boolean ;
Var TmpCode : TStringList ;
    i : integer ;
    CurrentLine : TStringList ;
    NumFile : Integer ;
    { Valeur de décalage par rapport à l'offset dans le fichier lors de l'ajout
      d'une ligne }
    IncOfOffset : Integer ;
    Position : Integer ;
    EndComment : String ;
    tmp : String ;
    PositionOfTag : Integer ;
    inHTML : Boolean ;
    WorkInLineIsEnd : Boolean ;
    
    procedure add(Text : String) ;
    begin
        if (Text <> '') or (inHTML)
        then begin
            CodeList.Insert(Offset + IncOfOffset, Text) ;
            LineToFile.Insert(Offset + IncOfOffset, IntToStr(NumFile)) ;
            LineToFileLine.Insert(Offset + IncOfOffset, IntToStr(i + 1)) ;
            Inc(IncOfOffset) ;
        end ;
    end ;

label ReadLineToCheckComment ;
begin
    Result := False ;
    FileName := Realpath(Filename) ;

    { Vérifie l'inclusion du fichier si on est en safe mode }
    if (SafeMode = True) and (doc_root <> '')
    then begin
        if Pos(doc_root, FileName) = 0
        then begin
            ErrorMsg(sCantDoThisInSafeMode) ;
            exit ;
        end ;
    end ;

    {$I-}
    try
        if FileExists(FileName)
        then begin
            NumFile := ListOfFile.Count ;

            ListOfFile.Add(FileName) ;
            CurrentLine := TStringList.Create ;
            CurrentRootOfFile.Add(OsAddFinalDirSeparator(ExtractFileDir(FileName))) ;

            TmpCode := TStringList.Create ;

            TmpCode.LoadFromFile(FileName) ;

            i := 0 ;
            IncOfOffset := 0 ;
            inHTML := True ;

            while i < TmpCode.Count do
            begin
                OverTimeAndMemory ;
                if GlobalError
                then
                    break ;

                WorkInLineIsEnd := False ;

                repeat
                    if inHTML
                    then begin
                        { Code HTML }
                        PositionOfTag := pos(StartSwsTag, TmpCode[i]) ;

                        if PositionOfTag <> 0
                        then begin
                            tmp := Copy(TmpCode[i], 1, PositionOfTag - 1) ;

                            add(tmp) ;
                            add('<@') ;

                            TmpCode[i] := Copy(TmpCode[i], PositionOfTag + 2, length(TmpCode[i]) - (PositionOfTag + 1) ) ;

                            inHTML := False ;
                        end
                        else begin
                            WorkInLineIsEnd := True ;
                        end ;
                    end
                    else begin
                        { Code SWS }
                        PositionOfTag := pos(EndSwsTag, TmpCode[i]) ;

                        if PositionOfTag <> 0
                        then begin
                            tmp := Copy(TmpCode[i], 1, PositionOfTag - 1) ;

                            tmp := Trim(tmp) ;
                            add(tmp) ;

                            { Pour ne pas inclure la ligne 2 fois }
                            tmp := '' ;

                            inHTML := True ;

                            add(EndSwsTag) ;

                            TmpCode[i] := Copy(TmpCode[i], PositionOfTag + 2, length(TmpCode[i]) - (PositionOfTag + 1) ) ;
                        end
                        else begin
                            WorkInLineIsEnd := True ;
                        end ;
ReadLineToCheckComment :
                        if PositionOfTag = 0
                        then begin
                            tmp := TmpCode[i] ;
                        end ;

                        tmp := Trim(tmp) ;

                        if Tmp <> ''
                        then begin
                            Position := Pos('/*', Tmp) ;
                            EndComment := '*/' ;

                            if Position = 0
                            then begin
                                Position := Pos('(*', Tmp) ;
                                EndComment := '*)' ;
                            end ;

                            { Est-ce une aide mutli ligne }
                            if Position <> 0
                            then begin
                                { L'erreur ici serait de passer à la ligne suivant or
                                  la fin de commentaire peut se trouver sur la même
                                  ligne que le début de commentaire }
                                while i < TmpCode.Count do
                                begin
                                    TmpCode[i] := Trim(TmpCode[i]) ;

                                    if TmpCode[i] <> ''
                                    then begin
                                        Position := Pos(EndComment, TmpCode[i]) ;

                                        if Position <> 0
                                        then begin
                                            Inc(i) ;
                                            { Si deux lignes de commentaires se suivent }
                                            goto ReadLineToCheckComment ;
                                        end ;
                                    end ;

                                    Inc(i) ;
                                end ;

                                tmp := Trim(TmpCode[i]) ;
                            end ;

                            { Si pas un commentaire multi mono ligne }
                            if (Pos('#', Tmp) <> 1) and (Pos('//', Tmp) <> 1)
                            then begin
                                add(tmp) ;
                            end ;
                        end ;

                        { Evite d'inclure 2 fois la ligne }
                        if PositionOfTag = 0
                        then begin
                            TmpCode[i] := '' ;
                        end ;
                    end ;
                until WorkInLineIsEnd = True ;

                if (TmpCode[i] <> '') or (inHTML)
                then begin
                    if inHTML
                    then
                        if i <> (TmpCode.Count - 1)
                        then
                            TmpCode[i] := TmpCode[i] + #13 ;
                        
                    add(TmpCode[i]) ;
                end ;

                Inc(i) ;
            end ;

            TmpCode.Free ;
            CurrentLine.Free ;

            Result := True ;
        end
        else begin
            if ListOfFile.Count > 0
            then begin
                if LineToFileLine.Count = 0
                then begin
                    LineToFileLine.Add('1') ;
                    LineToFile.Add('0') ;
                end ;

                ErrorMsg(Format(sFileNotFound, [FileName])) ;
            end
            else begin
                ErrorMsg(Format(sMainFileNotFound, [FileName])) ;
            end ;
        end ;
    except
        on EInOutError do ErrorMsg(Format(sCantReadFile, [FileName])) ;
    end ;
    {$I+}
end ;

{*******************************************************************************
 * Fonction explose une chaine en tableau en fonction d'un séparateur
 *
 *  Entrée
 *   text : chaine à exploser
 *   Ligne : TStringList contenant la chaine explosée
 *   Separateur : séparateur de champ
 ******************************************************************************}
procedure Explode(text : string; Ligne : TStringList; Separateur : string) ;
var Resultat : string ;
    len : Integer ;
    tmp : String ;
    i : Integer ;
begin
    Ligne.Clear ;

    Resultat := '' ;

    len := Length(Separateur) ;
    i := 1 ;

    while i <= Length(Text) do
    begin
        tmp := Copy(Text, i, len) ;

        if tmp = Separateur
        then begin
            Ligne.Add(Resultat) ;
            Resultat := '' ;
            Inc(i, len) ;
        end
        else begin
            Resultat := Resultat + Text[i] ;
            Inc(i) ;
        end ;
    end ;

    if Resultat <> ''
    then
        Ligne.Add(Resultat) ;
end ;

{*******************************************************************************
 * Fonction qui exécute une fonction définit par l'utilisateur
 *
 *  Entrée
 *   Commande : nom de la fonction à exécuter
 *   CurrentLine : Ligne courrante exécutée
 *
 *  Retour : Ligne à laquel il faut sauter
 ******************************************************************************}
function ExecuteUserProcedure(Commande : String; CurrentLine : TStringList) : integer ;
var LineOfProcedure : Integer ;
    EndCondition2 : TStringList ;
    i : Integer ;
    OldVariables : TVariables ;
    NameOfVar : String ;
    ListArguments : TStringList ;
    PosEqual, Pos3Dot : Integer ;
    NbArgFixe : Integer ;
    Cmd : String ;
    OldCurrentLineNumber : Integer ;
    
    procedure setFixedParams(ListArguments : TStringList; CurrentLine : TStringList) ;
    var fin : Integer ;
        i : Integer ;
    begin
        { se place au premier paramètre optionnel }
        fin := ListArguments.IndexOf('=') - 1 ;

        if fin < 0
        then begin
            { se place au premier paramètre ... }
            fin := ListArguments.IndexOf('...') ;

            if fin < 0
            then
                fin := CurrentLine.Count - 1 ;
        end ;

        for i := 0 to fin do
        begin
            Variables.Add(ListArguments[i], CurrentLine[i]) ;
        end ;
    end ;

    procedure setOptionnalParams(ListArguments : TStringList; CurrentLine : TStringList) ;
    var debut : Integer ;
        posVarInCall : Integer ;
        fin : Integer ;
        i : Integer ;
        val : String ;
    begin
        { se place au premier paramètre optionnel }
        debut := ListArguments.IndexOf('=') - 1 ;

        if debut > 0
        then begin
            fin := ListArguments.IndexOf('...') - 1 ;

            if fin < 0
            then
                fin := ListArguments.Count -1 ;

            i := debut ;
            posVarInCall := debut ;

            while i <= fin do
            begin
                { A-t-on 3 éléments ; $var=val }
                if i + 2 < ListArguments.Count
                then begin
                    if isVar(ListArguments[i])
                    then begin
                        if ListArguments[i + 1] = '='
                        then begin
                            val := ListArguments[i + 2] ;

                            { L'élément est-il définit lors de l'appel de la fonction }
                            if posVarInCall < CurrentLine.Count
                            then begin
                                val := CurrentLine[PosVarInCall] ;
                            end
                            else begin
                                { pour récupérer variable $true ou $false }
                                if isVar(val)
                                then
                                    val := Variables.Give(val)
                                else
                                    val := GetString(val) ;
                            end ;

                            Variables.Add(ListArguments[i], val) ;

                            Inc(i, 3) ;
                            Inc(posVarInCall) ;
                        end
                        else begin
                            ErrorMsg(sMustOptionalParameterAfter) ;
                            break ;
                        end ;
                    end
                    else begin
                        ErrorMsg(Format(sNotAVariable, [CurrentLine[i]])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(sParamFunctionIncorrect) ;
                    break ;
                end ;
            end ;
        end
        else begin
            ErrorMsg(sParamFunctionIncorrect) ;
        end ;
    end ;

    procedure setVariableArgument(ListArguments : TStringList; CurrentLine : TStringList) ;
    var debut : Integer ;
        i : Integer ;
    begin
        debut := ListArguments.IndexOf('...') ;

        if debut = -1
        then
            debut := ListArguments.Count -1 ;

        { Créer les paramètres }
        Variables.Add('$argcount', IntToStr(CurrentLine.Count - debut)) ;

        for i := debut to CurrentLine.Count - 1 do
        begin
            Variables.Add('$args[' + IntToStr(i+1) + ']', CurrentLine[i]) ;
        end ;
    end ;
begin
    OldCurrentLineNumber := CurrentLineNumber ;
    Result := -1 ;
    
    { Vérifie si on ne trouve pas la commande dans la liste des
      procédures }
    LineOfProcedure := ListProcedure.Give(Commande) ;

    if LineOfProcedure = -1
    then begin
        ErrorMsg(Format(sUnknowCommande, [Commande])) ;
    end
    else begin
        CurrentFunctionName.Add(Commande) ;

        { Translate les valeurs }
        //GetValueOfStrings(CurrentLine) ;

        { sauvegarde les variables }
        OldVariables := Variables ;

        { Créer les variables locales }
        Variables := TVariables.Create ;

        Variables.Add('$true', trueValue);
        Variables.Add('$false', FalseValue);
        Variables.Add('$_version', version);
        Variables.Add('$_scriptname', ListOfFile[MyStrToInt(LineToFile[CurrentLineNumber])]) ;

        ListArguments := TStringList.Create ;

        ListArguments.Text := ListProcedure.GiveArguments(Commande) ;

        PosEqual := ListArguments.IndexOf('=') ;
        Pos3Dot := ListArguments.IndexOf('...') ;

        if  (PosEqual = -1) and (Pos3Dot <> -1)
        then begin
            { Paramètre fixe + optionnel }
            if CurrentLine.Count >= (Pos3Dot)
            then begin
                setFixedParams(ListArguments, CurrentLine) ;
                setVariableArgument(ListArguments, CurrentLine) ;
            end
            else
                ErrorMsg(sMissingargument) ;

        end
        else if (PosEqual <> -1) and (Pos3Dot = -1)
        then begin
            { Paramètre fixe + optionnel }
            if CurrentLine.Count >= (PosEqual - 1)
            then begin
                { A-t-on plus d'argument passé lors de l'appel que de paramètre optionel }
                NbArgFixe := PosEqual - 1 ;

                if  CurrentLine.Count <= (NbArgFixe + ((ListArguments.Count - NbArgFixe) div 3 ))
                then begin
                    setFixedParams(ListArguments, CurrentLine) ;
                    setOptionnalParams(ListArguments, CurrentLine) ;
                end
                else
                    ErrorMsg(sTooArguments) ;
            end
            else
                ErrorMsg(sMissingargument) ;
        end
        else if  (PosEqual <> -1) and (Pos3Dot <> -1)
        then begin
            ErrorMsg(sNotEqualAnd3Dot) ;
        end
        else begin
            { On a que des paramètres fixe }
            if ListArguments.Count = CurrentLine.Count
            then
                { La fonction n'a pas de paramètre optionnelles ni de ... }
                setFixedParams(ListArguments, CurrentLine)
            else if ListArguments.Count > CurrentLine.Count
            then
                ErrorMsg(sMissingargument)
            else if ListArguments.Count < CurrentLine.Count
            then
                ErrorMsg(sTooArguments) ;
        end ;

        if (not GlobalError) and (not GlobalQuit)
        then begin
            EndCondition2 := TStringList.Create ;
            EndCondition2.Add('endfunc') ;
            EndCondition2.Add('goto') ;

            i := ReadCode(LineOfProcedure, EndCondition2, CodeList) ;

            EndCondition2.Free ;

            ResultFunction := Variables.Give('$result') ;

            if i >= 0
            then begin
                Cmd := extractCommande(LowerCase(CodeList[i - 1])) ;

                if cmd = 'goto'
                then begin
                    { -1 pour la ligne précédent + -1 pour le fait qu'il y ait un Inc
                      à la fin de ReadCode }
                    Result := i - 2 ;
                    isGoto := True ;
                end ;

                { Bascule les données de Variables dans les variables globales }
                for i := 0 to GlobalVariable.Count - 1 do
                begin
                    NameOfVar := GlobalVariable[i] ;

                    FirstVariables.Add(NameOfVar, Variables.Give(NameOfVar));
                end ;
            end ;

            GlobalVariable.Clear ;
        end ;

        CurrentFunctionName.Delete(CurrentFunctionName.Count - 1) ;
        Variables.Free ;
        ListArguments.Free ;
        Variables := OldVariables ;
    end ;

    CurrentLineNumber := OldCurrentLineNumber ;
end ;

{*******************************************************************************
 * Fonction qui supprime les virgules et parenthèse de début et fin
 *
 *  Entrée
 *   Liste à lire
 *
 *  Sortie
 *   Liste traitée
 ******************************************************************************}
procedure DeleteVirguleAndParenthese(argumentsAvecParentheses : TStringList) ;
var nb : Integer ;
    Index : Integer ;
    Parentheses : array of Integer ;
    EnleverParenthese : boolean ;
begin
    { Supprime les "," }
    Index := 0 ;

    while Index < argumentsAvecParentheses.Count do
    begin
        if argumentsAvecParentheses[Index] = ','
        then
            argumentsAvecParentheses.Delete(Index)
        else
            Inc(Index) ;
    end ;

    { si on a une parenthèse ouvrante, peut-être s'agit-il d'un appel xxx(...)}
    if argumentsAvecParentheses.Count > 0
    then begin
        if argumentsAvecParentheses[0] = '('
        then begin
            Index := 0 ;
            EnleverParenthese := False ;
            
            { on va compter le nombre de parenthèse }
            for nb := 0 to argumentsAvecParentheses.Count - 1 do
            begin
                if argumentsAvecParentheses[nb] = '('
                then begin
                    Inc(Index) ;
                    try
                        SetLength(Parentheses, Index) ;
                    except
                        on EOutOfMemory do begin
                            ErrorMsg(sOutOfMemory) ;
                            break ;
                        end ;
                    end ;

                    Parentheses[Index - 1] := nb ;
                end ;

                if argumentsAvecParentheses[nb] = ')'
                then begin
                    { si la parenthèse est sur la dernière case }
                    if (nb = argumentsAvecParentheses.Count - 1)
                    then
                        if Index > 0
                        then
                            { Est-ce la parenthèse correspondante est à la position 0 }
                            if Parentheses[Index-1] = 0
                            then begin
                                EnleverParenthese := True ;
                                break ;
                            end ;

                    Dec(Index) ;
                end ;
            end ;

            { Libère le tableau }
            SetLength(Parentheses, 0) ;

            { Supprime les parenthèses de début et de fin }
            if EnleverParenthese
            then begin
                argumentsAvecParentheses.Delete(0) ;
                nb := argumentsAvecParentheses.Count - 1 ;
                argumentsAvecParentheses.Delete(nb) ;
            end ;
        end ;
    end ;
end ;

{*******************************************************************************
 * Retourne la position d'une chaine dans un tableau
 *
 *  Entrée
 *   Text : texte à chercher
 *   Values : liste des valeur
 *
 *  Retour : position du texte cherché dans le tableau
 ******************************************************************************}
function AnsiIndexStr(Text : string; const Values : array of string) : integer;
begin
    Result := 0 ;

    while Result <= High(Values) do
    begin
        if (Values[Result] = Text)
        then
            exit
        else
            inc(Result);
    end ;
    
    Result := -1;
end;

{*******************************************************************************
 * Retourne la chaine qu'il y a entre " et '
 *
 *  Entrée
 *   Text : texte entre " ou '
 *
 *  Retour : texte
 ******************************************************************************}
function GetString(Text : String) : String ;
var Delimiter : String ;
    nb : Integer ;
begin
    nb := length(Text) ;

    if nb > 0
    then begin
        Delimiter := Text[1] ;

        Result := Text ;

        if (Delimiter = '"') or (Delimiter = '''')
        then
            if Text[nb] = Delimiter
            then
                Result := copy(Text, 2, nb - 2)
    end ;
end ;

{*******************************************************************************
 * Fonction qui initialise la table des labels
 ******************************************************************************}
procedure ReadLabel ;
var i : Integer ;
    ALabel : string ;
    nb : Integer ;
begin
    if not LabelReading
    then begin
        LabelReading := True ;
        
        { Lit tous les labels }
        for i := 0 to CodeList.Count - 1 do
        begin
            nb := Length(CodeList[i]) ;

            if nb > 0
            then begin
                { si on trouve un : sur la ligne }
                if pos(':', CodeList[i]) = nb
                then begin
                    { Vérifie s'il s'agit d'un label }
                    ALabel := GetLabel(CodeList[i]) ;

                    if ALabel <> ''
                    then
                        if ListLabel.Give(ALabel) = -1
                        then
                            ListLabel.Add(ALabel, i)
                        else begin
                            ErrorMsg(Format('Label %s already exist', [ALabel])) ;
                            exit ;
                        end ;
                end ;
            end ;
        end ;
    end ;
end ;

{*******************************************************************************
 * Indique si c'est un chiffre hexadécimel
 *
 *  Entrée
 *   nombre : nombre à traiter sous forme de chaine
 *
 *  Retour : true ou false
 ******************************************************************************}
function isHexa(nombre : string) : boolean ;
var  nb : Integer ;
     i : Integer ;
begin
    Result := False ;
    nb := Length(nombre) ;

    if nb > 2
    then begin
        if (nombre[1] = '0') and ((nombre[2] = 'x') or (nombre[2] = 'X'))
        then begin
            Result := True ;

            for i := 3 to nb do
            begin
                if not ((nombre[i] in ['0'..'9']) or (nombre[i] in ['A'..'F']) or (nombre[i] in ['a'..'f']))
                then begin
                    Result := False ;
                    break ;
                end ;
            end ;
        end ;
    end ;
end ;

{*******************************************************************************
 * Extrait la première partie jusqu'au premier espace ou tabulation
 *
 *  Entrée
 *   Text : ligne à traiter
 *
 *  Retour : commande
 ******************************************************************************}
function extractCommande(text : string) : string ;
var j : Integer ;
begin
    text := Trim(Text) ;
    Result := '' ;

    for j := 1 to Length(text) do
    begin
        if (text[j] <> ' ') and (text[j] <> #9)
        then
            Result := Result + text[j]
        else
            break ;
    end ;

    Result := LowerCase(Result) ;
end ;

{*******************************************************************************
 * Charge une extension
 *
 *  Entrée
 *   Nombre de la librairie à charger sans l'extention (.dll ou .so)
 *
 *  Retour : true si chargée
 ******************************************************************************}
function LoadExtension(NameOfExt : String) : boolean ;
var proc : TProcExt ;
    procresult : TProcResult ;
    procinit : TProcInit ;
    HandleOfExt : Integer ;
    InitDocRoot : String ;
    InitTmpDir : String ;
    InitSafeMode : Boolean ;
begin
    proc := nil ;
    procresult := nil ;
    HandleOfExt := 0 ;

    Result := False ;

    if not ListOfExtension.isExists(NameOfExt)
    then begin
        OsLoadExtension(NameOfExt, HandleOfExt, proc, procresult, procinit) ;

        if (@proc <> nil) and (@procresult <> nil) and (@procinit <> nil)
        then begin
            {$IFDEF FPC}
            ListOfExtension.Add(NameOfExt, HandleOfExt, proc, procresult) ;
            {$ELSE}
            ListOfExtension.Add(NameOfExt, HandleOfExt, @proc, @procresult) ;
            {$ENDIF}

            { On recopie les répertoires afin d'enpêcher toutes modifications.
              L'extension devra alors recopier les paramètres. On désactive
              l'optimisation pour pas qu'il supprime les variables locales }
            {$O-}
            InitDocRoot := Copy(doc_root, 1, length(doc_root)) ;
            InitTmpDir := Copy(TmpDir, 1, length(TmpDir)) ;
            InitSafeMode := SafeMode ;

            procinit(PChar(InitDocRoot), PChar(InitTmpDir), InitSafeMode) ;
            {$O+}
            
            Result := True ;
        end
        else begin
            OsUnLoadExtension(NameOfExt) ;
        end ;
    end
    else
        Result := True ;
end ;

{*******************************************************************************
 * Décharge une extension
 *
 *  Entrée
 *   Nombre de la librairie à charger sans l'extention (.dll ou .so)
 ******************************************************************************}
procedure UnLoadExtension(NameOfExt : String) ;
begin
    OsUnLoadExtension(NameOfExt) ;

    ListOfExtension.DeleteByName(NameOfExt);
end ;

{*******************************************************************************
 * Indique si une extension est chargée
 *
 *  Entrée
 *   Nombre de la librairie à charger sans l'extention (.dll ou .so)
 *
 *  Retour : true si chargée
 ******************************************************************************}
function isExtensionLoaded(NameOfExt : String) : Boolean ;
var proc : TProcExt ;
    HandleOfExt : Integer ;
begin
    HandleOfExt := -1 ;
    proc := nil ;
    
    ListOfExtension.Give(NameOfExt, HandleOfExt, proc) ;

    Result := False ;

    if @proc <> nil
    then
        Result := True ;
end ;

{*******************************************************************************
 * Converti une TStringList en PChar
 *
 *  Entrée
 *   Liste à traiter
 *
 *  Sortie
 *   ArgPChar : chaine
 ******************************************************************************}
procedure TStringListToPChar(ArgTStringList : TStringList; var ArgPChar : PChar) ;
Var i : Integer ;
    len : Integer ;
begin
    len := 0 ;

    for i := 0 to ArgTStringList.Count - 1 do
    begin
        { +1 pour le #0 }
        len := len + Length(ArgTStringList[i]) + 1 ;
    end ;

    GetMem(ArgPChar, len + 1) ;

    len := 0 ;

    for i := 0 to ArgTStringList.Count - 1 do
    begin
        StrPCopy(@ArgPChar[len], ArgTStringList[i]) ;

        { +1 pour le \0 }
        len := len + Length(ArgTStringList[i]) ; ;
        ArgPChar[len] := #0 ;
        Inc(len) ;
    end ;

    ArgPChar[len] := #0 ;
end ;

{*******************************************************************************
 * Appele la fonction dans une extension
 *
 *  Entrée
 *   Nom de la fonction
 *   Argument
 *
 *  Retour : true si applée
 ******************************************************************************}
function CallExtension(Commande : String; Arguments : TStringList) : Boolean ;
var i : Integer ;
    proc : TProcExt ;
    args : PChar ;
    scriptname : PChar ;
    localversion : PChar ;
    Commande2 : PChar ;
begin
    Result := False ;

    {$IFDEF FPC}
    // Supprime les warnings de Free Pascal Compiler
    scriptname := nil ;
    localversion := nil ;
    Commande2 := nil ;
    {$ENDIF}

    args := nil ;

    { + 1 pour le \0 }
    GetMem(scriptname, Length(Variables.Give('$_scriptname')) + 1) ;

    if scriptname = nil
    then begin
        ErrorMsg(sCanInitialiseDataToCallExtension) ;
        exit ;
    end ;

    scriptname[0] := #0 ;

    StrPCopy(scriptname, Variables.Give('$_scriptname')) ;

    { + 1 pour le \0 }
    GetMem(localversion, Length(version) + 1) ;

    if localversion = nil
    then begin
        ErrorMsg(sCanInitialiseDataToCallExtension) ;
        exit ;
    end ;

    localversion[0] := #0 ;

    StrPCopy(localversion, version) ;

    { + 1 pour le \0 }
    GetMem(Commande2, Length(Commande) + 1) ;

    if Commande2 = nil
    then begin
        ErrorMsg(sCanInitialiseDataToCallExtension) ;
        exit ;
    end ;

    Commande2[0] := #0 ;

    StrPCopy(Commande2, Commande) ;

    for i := 0 to ListOfExtension.Count - 1 do
    begin
        proc := ListOfExtension.GiveProcByIndex(i) ;

        TStringListToPChar(Arguments, args) ;

        if proc(Commande2, args, scriptname, localversion, StrToInt(Variables.Give('$_line')), @GlobalError)
        then begin
            Result := True ;

            ResultFunction := ListOfExtension.GetResult(i) ;

            break ;
        end ;
    end ;
end ;

{*******************************************************************************
 * Décode une url
 *
 *  Entrée
 *   Text : url encodée
 *
 *  Retour : url décodée
 ******************************************************************************}
function UrlDecode(Text : String) : String ;
var i : Integer ;
    len : Integer ;
    hexa : String ;
begin
    len := Length(Text) ;
    i := 1 ;
    Result := '' ;

    while i <= len do
    begin
        if Text[i] = '+'
        then
            Result := Result + ' '
        else if (Text[i] = '%') and ((len - i) > 1)
        then begin
            Hexa := '0x' + Copy(Text, i + 1, 2) ;

            if isHexa(Hexa)
            then begin
               Result := Result + Chr(MyStrToInt(Hexa)) ;
               Inc(i, 3) ;
            end
            else begin
                Result := Result + Text[i] ;
                Inc(i) ;
            end
        end
        else begin
            Result := Result + Text[i] ;
            Inc(i) ;
        end ;
    end ;
end ;

{*******************************************************************************
 * Encode une url
 *
 *  Entrée
 *   url à encoder
 *
 *  Retour : url encodée
 ******************************************************************************}
function UrlEncode(Text : string): string;
var
   i : Integer ;
begin
    Result := '';

    for i := 1 to Length(Text) do
    begin
        if Text[i] in ['A'..'Z', 'a'..'z', '0'..'9', '-', '_', '.']
        then
            Result := Result + Text[i]
        else if Text[i] = ' '
        then
            Result := Result + '+'
        else
            Result := Result + '%' + IntToHex(Ord(Text[i]), 2);
    end;
end;

{*******************************************************************************
 * Répète un caractère
 *
 *  Entrée
 *   Texte à répéter
 *   Nombre de fois à répéter
 *
 *  Retour : chaine contenant le texte répété
 ******************************************************************************}
function RepeterCaractere(Text : string; Nb : integer) : String ;
var i : Integer ;
begin
    Result := '' ;

    for i := 1 to nb do
    begin
        Result := Result + Text ;
    end ;
end ;

{*******************************************************************************
 * Extrait la partie entière d'un nombre
 *
 *  Entrée
 *   Text : nombre flottant sous forme de chaine
 *
 *  Retour : partie entière
 ******************************************************************************}
function extractIntPart(Text : String) : String ;
var position : Integer ;
begin
    position := pos('.', Text) ;

    if position <> 0
    then
        Result := Copy(Text, 1, position - 1)
    else
        Result := Text ;
end ;

{*******************************************************************************
 * Etrait la partie flottante d'un nombre
 *
 *  Entrée
 *   Text : nombre flottant sous forme de chaine
 *
 *  Retour : partie flottante
 ******************************************************************************}
function extractFloatPart(Text : String) : String ;
var position : Integer ;
begin
    position := pos('.', Text) ;

    if position <> 0
    then
        Result := Copy(Text, position + 1, length(Text) - position)
    else
        Result := '' ;
end ;

{*******************************************************************************
 * Ajoute des slash
 *
 *  Entrée
 *   Text : texte à traiter
 *
 *  Retour : texte traité
 ******************************************************************************}
function AddSlashes(Text : String) : String ;
var i, nb : Integer ;
begin
    nb := Length(text) ;
    Result := '' ;

    for i := 1 to nb do
    begin
         if (Text[i] = '\') or (Text[i] = '"') or (Text[i] = '''')
         then
             Result := Result + '\' ;

         Result := Result + Text[i] ;
    end ;
end ;

{*******************************************************************************
 * Supprime des slash
  *
 *  Entrée
 *   Text : texte à traiter
 *
 *  Retour : texte traité
 ******************************************************************************}
function DeleteSlashes(Text : String) : String ;
var i, nb : Integer ;
begin
    nb := Length(text) ;
    Result := '' ;

    i := 1 ;
    while i <= nb do
    begin
        if Text[i] = '\'
        then
            Inc(i) ;

        Result := Result + Text[i] ;
        Inc(i) ;
    end ;
end ;

{*******************************************************************************
 * Convertit un nombre en hexa
 *
 *  Entrée
 *   nombre : nombre à convertir
 *
 *  Retour : nombre convertit dans une chaine de caratère
 ******************************************************************************}
function DecToHex(nombre : Integer) : string ;
var modulo : SmallInt ;
    tmp : string ;
    nombre2 : Cardinal ;
begin
    if nombre = 0
    then
        result := '0'
    else begin
        if nombre < 0
        then
            { pour obtenir la représentation d'un nombre négatif, c'est le
              complément à un + 1 }
            nombre2 := (not Abs(nombre)) + 1
        else
            nombre2 := nombre ;

        result := '' ;

        while nombre2 > 0 do
        begin
            modulo := nombre2 mod 16 ;
            nombre2 := nombre2 div 16 ;

            if modulo < 10
            then
                tmp := IntToStr(modulo)
            else if modulo = 10
            then
                tmp := 'a'
            else if modulo = 11
            then
                tmp := 'b'
            else if modulo = 12
            then
                tmp := 'c'
            else if modulo = 13
            then
                tmp := 'd'
            else if modulo = 14
            then
                tmp := 'e'
            else if modulo = 15
            then
                tmp := 'f' ;

            Result := tmp + Result
        end ;
    end ;
end ;

{*******************************************************************************
 * Convertit un nombre en une base donnée
 *
 *  Entrée
 *   Nombre : nombre à traité
 *   base : 2, 8, 10
 *
 *  Retour chaine de caractère contanant le nombre convertit
 ******************************************************************************}
function DecToMyBase(nombre : Integer; Base : Byte) : String ;
var modulo : SmallInt ;
    tmp : string ;
    nombre2 : Cardinal ;
begin
    if nombre = 0
    then
        result := '0'
    else begin
        if nombre < 0
        then
            { pour obtenir la représentation d'un nombre négatif, c'est le
              complément à un + 1 }
            nombre2 := (not Abs(nombre)) + 1
        else
            nombre2 := nombre ;

        result := '' ;

        while nombre2 > 0 do
        begin
            modulo := nombre2 mod base ;
            nombre2 := nombre2 div base ;

            tmp := IntToStr(modulo) ;

            Result := tmp + Result
        end ;
    end ;
end ;

{*******************************************************************************
 * Convertit un nombre en octal
 *
 *  Entrée
 *   Nombre : nombre à traité
 *
 *  Retour : nombre octal
 ******************************************************************************}
function DecToOct(nombre : Integer) : String ;
begin
    Result := DecToMyBase(nombre, 8) ;
end ;

{*******************************************************************************
 * Convertit un nombre en binaire
 *
 *  Entrée
 *   Nombre : nombre à traité
 *
 *  Retour : nombre binaire
 ******************************************************************************}
function DecToBin(nombre : Integer) : String ;
begin
    Result := DecToMyBase(nombre, 2) ;
end ;

{*******************************************************************************
 * Convertit une chaine binaire en Base64
 *
 *  Entrée
 *   S : texte à convertir
 *
 *  Retour : texte codé en base64
 ******************************************************************************}
function Encode64(S: string): string;
var tmp : string ;
    i : Integer ;
  function Block64Encode(S : string) : string ;
  var len : SmallInt ;
      i : Integer ;
  begin
      { Par défaut si on n'a rien, on retourne des = }
      Result := '====' ;
      len := Length(S) ;
      i := 1 ;

      if len > 0
      then begin
          Result[1] := Code64[(Ord(S[1]) shr 2) + 1 ] ;
          i := (Ord(S[1]) and 3) shl 4 ;
          Result[2] := Code64[ i + 1 ] ;
      end ;

      if len > 1
      then begin
          i := i + (Ord(S[2]) shr 4) ;
          Result[2] := Code64[ i + 1 ] ;
          i := (Ord(S[2]) and 15) shl 2 ;
          Result[3] := Code64[ i + 1 ] ;
      end ;

      if len > 2
      then begin
          i := i + (Ord(S[3]) shr 6) ;

          Result[3] := Code64[ i + 1 ] ;
          Result[4] := Code64[(Ord(S[3]) and 63) + 1] ;
      end ;
  end ;
begin
    Result := '' ;
    tmp := '' ;
    
    for i := 1 to Length(S) do
    begin
        if (i mod 3) = 0
        then begin
            tmp := tmp + S[i] ;
            { On encode par paquet de 3 carctères }
            Result := Result + Block64Encode(tmp) ;
            tmp := '' ;
        end
        else
            tmp := tmp + S[i] ;
    end ;

    if tmp <> ''
    then
        Result := Result + Block64Encode(tmp) ;
end ;

{*******************************************************************************
 * Convertit une chaine Base64 en binaire
 *
 *  Entrée
 *   S : texte à convertir
 *
 *  Retour : texte binaire
 ******************************************************************************}
function Decode64(S : String) : String ;
var tmp : String ;
    i : Integer ;

    function GetValueOfBase64(Char1 : char) : SmallInt ;
    var i : SmallInt ;
    begin
        Result := 0 ;
        for i := 1 to length(Code64) do
        begin
            if Char1 = Code64[i]
            then begin
                Result := i - 1 ;
                break ;
            end ;
        end ;
    end ;

    function Block64Decode(S : String) : String ;
    var i : Integer ;
        len : Integer ;
    begin
        Result := '' ;
        len := Length(S) ;

        if len > 0
        then begin
            if S[1] <> '='
            then begin
                i := GetValueOfBase64(S[1]) ;
                i := i shl 2 ;
                Result := char( i ) ;
            end ;
        end ;

        if len > 1
        then begin
            if S[2] <> '='
            then begin
                if Length(Result) > 0
                then begin
                    i := GetValueOfBase64(S[2]) shr 4 ;
                    Result[1] := Char(Ord(Result[1]) + i) ;
                end ;

                i := GetValueOfBase64(S[2]) shl 4 ;
                Result := Result + char( i ) ;
            end ;
        end ;

        if len > 2
        then begin
            if S[3] <> '='
            then begin
                if Length(Result) > 1
                then begin
                    i := GetValueOfBase64(S[3]) shr 2 ;
                    Result[2] := Char(Ord(Result[2]) + i) ;
                end ;

                i := GetValueOfBase64(S[3]) shl 6 ;

                Result := Result + char( i ) ;
            end ;
        end ;

        if len > 3
        then begin
            if S[4] <> '='
            then begin
                if Length(Result) > 2
                then begin
                    i := GetValueOfBase64(S[4]) ;
                    Result[3] := Char(Ord(Result[3]) + i) ;
                end ;
            end ;
        end ;
    end ;
begin
    Result := '' ;
    tmp := '' ;
    
    for i := 1 to Length(S) do
    begin
        if (i mod 4) = 0
        then begin
            tmp := tmp + S[i] ;
            { On décode par paquet de 4 caractères }
            Result := Result + Block64Decode(tmp) ;
            tmp := '' ;
        end
        else
            tmp := tmp + S[i] ;
    end ;

    if tmp <> ''
    then
        Result := Result + Block64Decode(tmp) ;
end ;

{*******************************************************************************
 * Renvoie un identifiant unique
 *
 *  Retour : un numéro unique
 ******************************************************************************}
function UniqId : string ;
begin
    Result := FormatDateTime('yyyymmddhhnnsszzz', now) ; ;
end ;

{*******************************************************************************
 * Ajoute une entête
 *
 *  Entrée
 *   Entête à ajouter
 ******************************************************************************}
procedure AddHeader(line : String) ;
var i : Integer ;
    isInsered : boolean ;
begin
    isInsered := False ;

    { Insert les données avant la ligne vide s'il y en a une }
    for i := 0 to Header.Count - 1 do
    begin
        if pos('Content-Type', Header[i]) = 1
        then begin
            Header.Insert(i, line) ;
            isInsered := True ;
            break ;
        end ;
    end ;

    { si les données non pas été insérée }
    if not isInsered
    then
        Header.Add(line) ;
end ;

{*******************************************************************************
 * Fonction qui envoie le header
 ******************************************************************************}
procedure SendHeader ;
var i : Integer ;
begin
    { Mémorise d'où est envoyé les insormations }
    LineWhereHeaderSend := CurrentLineNumber ;

    isHeaderSend := True ;

    for i := 0 to Header.Count - 1 do
    begin
        writeln(Header[i]) ;
    end ;
end ;

{*******************************************************************************
 * Convertit un TDateTime en unix time stamp
 *
 *  Entrée
 *   Date à convertir
 *
 *  Retour : date unix
 ******************************************************************************}
function DateTimeToUnix(ConvDate: TDateTime): Longint;
begin
  Result := Round((ConvDate - UnixStartDate) * 86400);
end;

{*******************************************************************************
 * Convertit un unix time stamp en TDateTime
 *
 *  Entrée
 *   Date à convertir
 *
 *  Retour : date delphi
 ******************************************************************************}
function UnixToDateTime(USec: Longint): TDateTime;
begin
  Result := (Usec div 86400) + UnixStartDate;
end;

{*******************************************************************************
 * Vérifie que le temps n'est pas écoulé
 ******************************************************************************}
procedure OverTimeAndMemory ;
begin
    {$IFNDEF COMMANDLINE}
    if SecondSpan(StartTime, Now) > ElapseTime
    then
        ErrorMsg(sTimeIsEnd) ;
    {$ENDIF}

    if OSUsageMemory > (MaxMemorySize)
    then
        ErrorMsg(sMemoryLimit) ;
end ;

{*******************************************************************************
 * Ecrit sur la sortie standard. Vérifie au préalable que l'entête à été envoyé.
 * Si ce n'est pas le cas, envoie l'entête.
 *
 *  Entrée
 *   Text  : Texte à afficher
 *   parse : Doit-on interpréter les \n, \t, \r, \0
 ******************************************************************************}
procedure OutputString(Text : String; parse : boolean)  ;
var i, nb : Integer ;
    TexteDeSortie : String ;
    OutPutFunctionArgs : TStringList ;
    OldEC : Boolean ;
begin
    { On envoie l'entête si ça n'a pas été fait }
    if (not isHeaderSend) and (not isOutPuBuffered)
    then
        SendHeader ;

    if parse
    then begin
        i := 1 ;
        nb := Length(Text) ;
        TexteDeSortie := '' ;

        while i <= nb do
        begin
            { Prochain caractère }
            if Text[i] = '\'
            then begin
                Inc(i) ;

                if i <= nb
                then begin
                    if Text[i] = 'n'
                    then
                        TexteDeSortie := TexteDeSortie + char(10)
                    else if Text[i] = 'r'
                    then
                        TexteDeSortie := TexteDeSortie + char(13)
                    else if Text[i] = 't'
                    then
                        TexteDeSortie := TexteDeSortie + char(9)
                    else
                        TexteDeSortie := TexteDeSortie + Text[i] ;
                end
                else
                    TexteDeSortie := TexteDeSortie + Text[i] ;
            end
            else begin
                TexteDeSortie := TexteDeSortie + Text[i] ;
            end ;

            Inc(i) ;
        end ;
    end
    else
        TexteDeSortie := Text ;

    if isOutPuBuffered
    then begin

        OutPutFunctionArgs := TStringList.Create ;
        OutPutFunctionArgs.Add(TexteDeSortie) ;

        if OutPutFunction <> ''
        then begin
            OldEC := isExecutableCode ;
            isExecutableCode := True ;

            ExecuteUserProcedure(OutPutFunction, OutPutFunctionArgs) ;

            isExecutableCode := OldEC ;
        end
        else begin
            ResultFunction := TexteDeSortie ;
        end ;
        
        OutPutFunctionArgs.Free ;
        OutPutContent := OutPutContent + ResultFunction ;
    end
    else begin
        write(TexteDeSortie) ;
    end ;
end ;

{*******************************************************************************
 * Fonction qui retourne le chemin complet d'un fichier
 *
 *  Entrée
 *   Filename : nom du fichier
 *
 *  Retour : nom du fichier complet
 ******************************************************************************}
function Realpath(FileName : string) : String ;
var Liste, Liste2 : TStringList ;
    i : Integer ;
    Index : Integer ;
    tmp : String ;
begin
    if FileName <> ''
    then begin
        Liste := TStringList.Create ;

        Explode(FileName, Liste, '/') ;
        tmp := '' ;

        if Liste.Count > 0
        then begin
            { On ajoute doc_root si on commence par . ou si le chemin ne
              commence pas par la racine }
            if Liste[0] = '.'
            then begin
                tmp := doc_root ;
            end
            else begin
                if not OsIsRootDirectory(FileName)
                then begin
                    tmp := doc_root ;
                end ;
            end ;

            { Si tmp <> '' c'est qu'on a ajouté nous même la racine. On doit
              donc l'exploser }
            if tmp <> ''
            then begin
                Liste2 := TStringList.Create ;

                Explode(tmp, Liste2, OsAddFinalDirSeparator('')) ;

                for i := 0 to Liste2.Count - 1 do
                begin
                    Liste.Insert(i, Liste2[i]);
                end ;

                Liste2.Free ;
            end ;

            { Supprime tout les . }
            repeat
                Index := Liste.IndexOf('.') ;

                if Index <> - 1
                then begin
                    Liste.Delete(Index) ;
                end ;
            until Index = -1 ;
        end ;

        repeat
            Index := Liste.IndexOf('..') ;

            if Index <> - 1
            then begin
                if Index <> 0
                then begin
                     Liste.Delete(Index - 1) ;
                     Dec(Index) ;
                end ;

                if Index <> -1
                then
                    Liste.Delete(Index) ;
            end ;
        until Index = -1 ;

        if not OsIsRootDirectory(FileName)
        then
            Result := ''
        else
            Result := OsRootDirectory ;

        for i := 0 to Liste.Count - 1 do
        begin
            Result := Result + Liste[i] ;

            if i < Liste.Count - 1
            then
                Result := OsAddFinalDirSeparator(Result) ;
        end ;

        Liste.Free ;
    end ;
end ;

{*******************************************************************************
 * Affiche les données si c'est un tableau, un entier...
 *
 *  Entrée
 *   data     : donnée à afficher (entier, tableau, pointer)
 *   decalage : texte à afficher devant la donnée
 *   index    : index dans le tableau
 *
 *  Retour : chaine de caractère contenant les données à afficher. Contient
 *           '\n' donc il faut parser la chaine 
 ******************************************************************************}
function showData(data : string; decalage : String; Index : Integer) : String ;
var typedata : string ;
  Liste : TStringList ;
  i : Integer ;
begin
    Result := '' ;

    if Variables.InternalisArray(data)
    then begin
        Result := Result + decalage + sArray + ' = {\n' ;

        Liste := TStringList.Create ;

        Variables.explode(Liste, data);

        for i := 0 to Liste.Count - 1 do
        begin
            Result := Result + showData(Liste[i], decalage + '    ', i + 1) ;
        end ;

        Liste.Free ;

        Result := Result + '}\n' ;
    end
    else begin
        typedata := sString ;

        if isHexa(data)
        then
            typedata := sHexa
        else if isInteger(data)
        then
            typedata := sInteger
        else if isFloat(data)
        then
            typedata := sFloat ;

        Result := Result + decalage ;

        if Index > 0
        then
            Result := Result + '[' + IntToStr(Index) + '] ' ;

        Result := Result + typedata + ' : ' + data + '\n';
    end ;
end ;

{*******************************************************************************
 * Remplace une occurence dans une chaine de caractère
 *
 *  Entrée
 *   Substr        : chaine à remplacer
 *   Str           : chaine à traiter
 *   ReplaceStr    : chaine de remplacement
 *   CaseSensitive : tenir compte de la caase
 *
 *  Sortie
 *   Str           : nouvelle chaine
 *
 *  Retour : nombre d'occurence trouvée
 ******************************************************************************}
function ReplaceOneOccurence(Substr : string; var Str : string; ReplaceStr : string; CaseSensitive : Boolean) : Cardinal ;
var Position: Integer;
    lensubstr, lenreplacestr : Integer ;
begin
    Position := posString(substr, str, 1, CaseSensitive) ;
    Result := 0 ;
    lenreplacestr := length(ReplaceStr) ;
    lensubstr := Length(Substr) ;

    while Position <> 0 do
    begin
        OverTimeAndMemory ;
        if GlobalError
        then
            break ;

        Inc(Result) ;
        Delete(Str, Position, lensubstr) ;
        Insert(ReplaceStr, Str, Position) ;
        Position := posString(substr, str, Position + lenreplacestr, CaseSensitive) ;
    end ;
end ;

{*******************************************************************************
 * Convertit une chaine en équivalent soundex
 *
 *  Entrée
 *   S : chaine à traiter
 *
 *  Retour : chaine soundex
 ******************************************************************************}
function soundex(S : String) : String ;
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

var i : Integer ;
    C : Char ;
    PosInResult : SmallInt ;
    LastChar : Char ;
    { Resultat 4 caractères  }
    Resultat : array[0..3] of char ;
begin
    Result := '' ;
    PosInResult := 0 ;
    LastChar := #0 ;

    for i := 0 to High(Resultat) do
    begin
        Resultat[i] := #0 ;
    end ;

    S := UpperCase(S) ;

    for i := 1 to Length(S) do
    begin
        C := S[i] ;

        { on ne prend en compte que les lettres. C'est idiot car la langue
          française par exemple contient des caractères spéciaux }
        if C in ['A'..'Z']
        then begin
            if PosInResult = 0
            then begin
                Resultat[PosInResult] := C ;
                Inc(PosInResult) ;
                LastChar := soundex_table[Ord(C) - Ord('A')] ;
            end
            else begin
				C := soundex_table[Ord(C) - Ord('A')] ;

				if (C <> LastChar)
                then begin
                    if C <> #0
                    then begin
                        Resultat[PosInResult] := C;
                        Inc(PosInResult) ;
                    end ;
                end ;
            end ;
        end ;
    end ;

    Result := '' ;

    for i := 0 to 3 do
    begin
        if Resultat[i] <> #0
        then
            Result := Result + Resultat[i]
        else
            Result := Result + '0' ;
    end ;
end ;

{*******************************************************************************
 * Convertit un caractère en majuscule et retourne un caractère
 *
 *  Entrée
 *   C : caractère à convertir
 *
 *  Retour : caractère convertit
 ******************************************************************************}
function upperChar(C : Char) : Char ;
var tmp : String ;
begin
    tmp := AnsiUpperCase(C) ;
    Result := tmp[1] ;
end ;

{*******************************************************************************
 * Retourne la position de subst dans str à partir d'index
 *
 *  Entrée
 *   substr        : chaine à rechercher
 *   str           : chaine dans laquelle il faut chercher
 *   index         : position à partir de laquelle il faut chercher
 *   CaseSensitive : sensible à la case
 *
 *  Retour : position de la sous chaine
 ******************************************************************************}
function posString(substr : String; str : String; index : Integer; CaseSensitive : boolean) : Cardinal ;
var i : Cardinal ;
    tmp : String ;
    len, lensubstr : Integer ;
begin
    Result := 0 ;
    len := Length(str) ;
    lensubstr := Length(substr) ;

    if Index > 0
    then begin
        for i := index to len do
        begin
            tmp := Copy(str, i, lensubstr) ;

            if CaseSensitive
            then begin
                if tmp = substr
                then begin
                    Result := i ;
                    break ;
                end ;
            end
            else begin
                if AnsiLowerCase(tmp) = AnsiLowerCase(substr)
                then begin
                    Result := i ;
                    break ;
                end ;
            end ;
        end ;
    end ;
end ;

{*******************************************************************************
 * Retourne la position de subst dans str à partir d'index en partant de la fin
 *
 *  Entrée
 *   substr        : chaine à rechercher
 *   str           : chaine dans laquelle il faut chercher
 *   index         : position à partir de laquelle il faut chercher
 *   CaseSensitive : sensible à la case
 *
 *  Retour : position de la sous chaine
 ******************************************************************************}
function posrString(substr : String; str : String; index : Integer; CaseSensitive : boolean) : Cardinal ;
var i : Cardinal ;
    tmp : String ;
    len, lensubstr : Integer ;
begin
    Result := 0 ;
    len := Length(str) ;
    lensubstr := Length(substr) ;

    if Index > 0
    then begin
        if index > len
        then
            index := len ;
            
        for i := index downto 1 do
        begin
            tmp := Copy(str, i, lensubstr) ;

            if CaseSensitive
            then begin
                if tmp = substr
                then begin
                    Result := i ;
                    break ;
                end ;
            end
            else begin
                if AnsiLowerCase(tmp) = AnsiLowerCase(substr)
                then begin
                    Result := i ;
                    break ;
                end ;
            end ;
        end ;
    end ;
end ;

{*******************************************************************************
 * Remplace une occurence dans une chaine de caractère si la chaine n'a pas été
 * modifié précédement.
 *
 *  Entrée
 *   substr     : chaine à remplacer
 *   str        : chaine à traiter
 *   ReplaceStr : chaine de remplacement
 *   strmod     : chaine aussi longue que Str contenant que 0. Les caractères
 *                modifiés seront mis à 1
 *
 *  Sortie
 *   str        : chaine modifiée avec l'occurence substr
 *   strmod     : les caractère modifiés sont mis à 1
 ******************************************************************************}
procedure ReplaceOneOccurenceOnce(Substr : string; var Str : string; ReplaceStr : string; var strmod : String) ;
var Position: Integer;
    lensubstr, lenreplacestr : Integer ;

    function ModifiedString(stringmodified : string; start, len : Integer) : Boolean ;
    var i : Integer ;
    begin
        Result := False ;

        for i := start to (start + len - 1) do
        begin
            if stringmodified[i] = '1'
            then begin
                Result := True ;
                break ;
            end ;
        end ;
    end ;
begin
    lensubstr := Length(Substr) ;
    lenreplacestr := Length(ReplaceStr) ;

    Position := posString(substr, str, 1, true) ;

    while Position <> 0 do
    begin
        OverTimeAndMemory ;
        if GlobalError
        then
            break ;

        if not ModifiedString(strmod, position, lensubstr)
        then begin
            Delete(Str, Position, lensubstr) ;
            Insert(ReplaceStr, Str, Position) ;

            Delete(StrMod, Position, lensubstr) ;
            Insert(RepeterCaractere('1',lenreplacestr), StrMod, Position) ;
            
            Position := posString(substr, str, Position + lenreplacestr + 1, true) ;
        end
        else begin
            Inc(Position, lensubstr + 1) ;
        end ;
    end ;
end ;

{*******************************************************************************
 * Remplace les caractères accentués dans une chaine
 *
 *  Entrée
 *   str : chaine à traiter
 *
 *  Retour : chaine dont les accents sont convertit 
 ******************************************************************************}
function ReplaceAccent(str : string) : string ;
const accent : string = 'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûýýþÿ' ;
      noaccent : string = 'AAAAAAACEEEEIIIIDNOOOOOOUUUUYbsaaaaaaaceeeeiiiidnoooooouuuyyby' ;
var i : Integer ;
    position : Integer ;
begin
    Result := '' ;

    for i := 0 to length(str) do
    begin
        position := pos(str[i], accent) ;

        if position = 0
        then
            Result := Result + str[i]
        else
            Result := Result + noaccent[position] ;
    end ;
end ;

{*******************************************************************************
 * Trie un liste en ordre aléatoire
 *
 *  Entrée
 *   Liste : liste à trier
 *
 *  Sortie
 *   Liste triée
 ******************************************************************************}
procedure ListShuffle(Liste : TStrings) ;
var
    NewList : TStringList ;
    i, len, Index : Integer ;
begin
    NewList := TStringList.Create ;

    Randomize ;

    len := Liste.Count - 1 ;

    for i := 0 to len do
    begin
        Index := random(Liste.Count) ;
        NewList.Add(Liste[Index]) ;
        Liste.Delete(Index);
    end ;

    Liste.Text := NewList.Text ;

    NewList.Free ;
end ;

{*******************************************************************************
 * Initialise le tableau de date courte
 ******************************************************************************}
procedure setShortDayName ;
begin
    ShortDayNames[1] := 'Sun' ;
    ShortDayNames[2] := 'Mon' ;
    ShortDayNames[3] := 'Tue' ;
    ShortDayNames[4] := 'Wed' ;
    ShortDayNames[5] := 'Thu' ;
    ShortDayNames[6] := 'Fri' ;
    ShortDayNames[7] := 'Sat' ;
end ;

{*******************************************************************************
 * Initialise le tableau de date longue
 ******************************************************************************}
procedure setLongDayName ;
begin
    LongDayNames[1] := 'Sunday' ;
    LongDayNames[2] := 'Monday' ;
    LongDayNames[3] := 'Tuesday' ;
    LongDayNames[4] := 'Wednesday' ;
    LongDayNames[5] := 'Thursday' ;
    LongDayNames[6] := 'Friday' ;
    LongDayNames[7] := 'Saturday' ;
end ;

{*******************************************************************************
 * Initialise le tableau de mois court
 ******************************************************************************}
procedure setShortMonthName ;
begin
    ShortMonthNames[1] := 'Jan' ;
    ShortMonthNames[2] := 'Feb' ;
    ShortMonthNames[3] := 'Mar' ;
    ShortMonthNames[4] := 'Apr' ;
    ShortMonthNames[5] := 'May' ;
    ShortMonthNames[6] := 'Jun' ;
    ShortMonthNames[7] := 'Jul' ;
    ShortMonthNames[8] := 'Aug' ;
    ShortMonthNames[9] := 'Sep' ;
    ShortMonthNames[10] := 'Oct' ;
    ShortMonthNames[11] := 'Nov' ;
    ShortMonthNames[12] := 'Dec' ;
end ;

{*******************************************************************************
 * Initialise le tableau de mois long
 ******************************************************************************}
procedure setLongMonthName ;
begin
    LongMonthNames[1] := 'January' ;
    LongMonthNames[2] := 'Febuary' ;
    LongMonthNames[3] := 'March' ;
    LongMonthNames[4] := 'April' ;
    LongMonthNames[5] := 'May' ;
    LongMonthNames[6] := 'June' ;
    LongMonthNames[7] := 'July' ;
    LongMonthNames[8] := 'August' ;
    LongMonthNames[9] := 'September' ;
    LongMonthNames[10] := 'October' ;
    LongMonthNames[11] := 'November' ;
    LongMonthNames[12] := 'December' ;
end ;

{*******************************************************************************
 * Initialise le tableau des jours
 *
 *  Entrée
 *   valeur : jours de la semaines (1er jour dimanche)
 *
 *  Sortie
 *   tableaudestination : tableau à initialiser
 ******************************************************************************}
procedure InitDayName(var tableaudestination : array of string; valeur : array of string) ;
var i : Integer ;
begin
    for i := 1 to 7 do
    begin
        tableaudestination[i] := valeur[i - 1] ;
    end ;
end ;

{*******************************************************************************
 * Initialise le tableau de mois
 *
 *  Entrée
 *   valeur : mois (1er jour janvier)
 *
 *  Sortie
 *   tableaudestination : tableau à initialiser
 ******************************************************************************}
procedure InitMonthName(var tableaudestination : array of string; valeur : array of string) ;
var i : Integer ;
begin
    for i := 1 to 12 do
    begin
        tableaudestination[i] := valeur[i - 1] ;
    end ;
end ; 

{*******************************************************************************
 * Calcule le CRC32 d'une chaine de caractère
 *
 *  Entrée
 *   Text : chaine à traiter
 *
 *  Retour : entier 32 bits représentant le CRC32
 ******************************************************************************}
function CRC32(Text : String) : Integer ;
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

    for i := 1 to Length(Text) do
    begin
        Result := (Result shr 8) xor Integer(CRC32Table[Byte(Text[i]) xor byte(Result)]) ;
    end;

    Result := not result;
end ;

end.

