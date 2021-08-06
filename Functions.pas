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

{$IFDEF FPC}
    {$mode objfpc}{$H+}
{$ENDIF}

interface

uses SysUtils, Variable, UnitMessages, Classes, Extension,
     InternalFunction, ListPointerOfTVariables, UnitOS,
     GetPostCookieFileData, Constantes
     {$IFNDEF COMMANDLINE}
     , DateUtils
     {$ENDIF}
      ;

procedure FinishProgram ;

procedure ExplodeStrings(asText : string; aoLigne : TStringList) ;
procedure ErrorMsg(asText : string) ;
procedure WarningMsg(asText : string) ;
function GetLabel(asText : string) : string ;
procedure SetVar(asVariable : string; asValue : string) ;
function GetVar(asVariable : string) : String ;
function CheckVarName(aiStart : Integer; asVarName : string) : boolean ;
function IsVar(asText : string) : boolean ;
function GetValueOfStrings(var aoArguments : TStringList) : Integer ;
function IsNumeric(asNombre : string) : boolean ;
function Caree(aeValue : Extended; aiExposant : integer) : Extended;
procedure DelVar(asVariable : string) ;
function IsSetVar(asVariable : string) : boolean ;
function MyStrToInt(asNumber : string) : LongInt;
function GetPointeurOfVariable(asPointer : string) : string ;
function GetVarNameOfVariable(asPointer : string) : string ;
function GetReference(asVarNamePointed : string) : string;
procedure SetReference(asVarNamePointed : string; asValue : string) ;
procedure UnSetReference(asVarNamePointed : string) ;
function IsSetReference(asVarNamePointed : string) : Boolean ;
function IsFloat(asNumber : String) : Boolean ;
function MyStrToFloat(asNumber : string) : Extended ;
function MyFloatToStr(aeNumber : Extended) : string ;
function IsInteger(asNumber : string) : boolean ;
function FloatToInt(aeNumber : extended) : LongInt ;
function LoadCode(asFileName : String; aiStartLine : Integer) : boolean ;
procedure Explode(asText : string; aoLine : TStringList; asSeparator : string) ;
function ExecuteUserProcedure(asCommande : String; aoCurrentLine : TStringList) : integer ;
procedure DeleteVirguleAndParenthese(aoArgumentsWithParentheses : TStringList) ;
function GetString(asText : String) : String ;
procedure ReadLabel ;
function IsHexa(asNumber : string) : boolean ;
function ExtractCommande(asText : string) : string ;
procedure TStringListToPChar(aoArgTStringList : TStringList; var aArgPChar : PChar) ;
function CallExtension(asCommande : String; aoArguments : TStringList) : Boolean ;
function UrlDecode(asUrl : String) : String ;
function UrlEncode(asUrl : string): string;
function RealPath(asFileName : String) : string ;
function RepeterCaractere(asText : string; aiNumber : integer) : String ;
function ExtractIntPart(asNumber : String) : String ;
function ExtractFloatPart(asNumber : String) : String ;
function AddSlashes(asText : String) : String ;
function DeleteSlashes(asText : String) : String ;
function DecToHex(aiNumber : Integer) : string ;
function DecToMyBase(aiNumber : Integer; aBase : Byte) : String ;
function DecToOct(aiNumber : Integer) : String ;
function DecToBin(aiNumber : Integer) : String ;
function UniqId : string ;
procedure AddHeader(asLine : String) ;
procedure SendHeader ;
function DateTimeToUnix(aoPascalDate : TDateTime): Longint;
function UnixToDateTime(aiUnixTime: Longint): TDateTime;
procedure OverTimeAndMemory ;
procedure OutputString(asText : String; abParse : boolean) ;
function ShowData(asData : string; asDecalage : String; aiIndex : Integer) : String ;
function ReplaceOneOccurence(asSubstr : string; var asStr : string; asReplaceStr : string; abCaseSensitive : Boolean) : Cardinal ;
function PosString(asSubStr : String; asStr : String; aiIndex : Integer; abCaseSensitive : boolean) : Cardinal ;
function PosrString(asSubStr : String; asStr : String; aiIndex : Integer; abCaseSensitive : boolean) : Cardinal ;
procedure ReplaceOneOccurenceOnce(asSubStr : string; var asStr : string; asReplaceStr : string; var asStrMod : String) ;
procedure setShortDayName ;
procedure setLongDayName ;
procedure setShortMonthName ;
procedure setLongMonthName ;
procedure InitDayName(var aaArray : array of string; aaValue : array of string) ;
procedure InitMonthName(var aaArray : array of string; aaValue : array of string) ;
function IsKeyWord(asKeyword : String) : boolean ;
function IsConst(asText : string) : boolean ;
function IsSetConst(asConstante : string) : boolean ;
function GetConst(asConstante : string) : string ;
function GetEndOfLine(asCommande : string) : string ;
function ExtractEndOperator(asText : string) : string ;
function IsEndOperatorBy(asEndOfLine : string) : boolean ;
function AnsiIndexStr(asText : string; const asValues : array of string) : integer;
function IndexOfTStringList(aiStart : Integer; aoList : TStringList; asSearch : String) : Integer ;

implementation

uses Code, UserFunction, UserLabel ;

const
  { Configure UnixStartDate vers TDateTime à 01/01/1970 }
  UnixStartDate: TDateTime = 25569.0;

{*****************************************************************************
 * FinishProgram
 * MARTINEAU Emeric
 *
 * Effectue les tâches avant l'arrêt du programme
 *
 *****************************************************************************}
procedure FinishProgram ;
var i : Integer ;
begin
    if Assigned(goCodeList) = true
    then begin
        goCodeList.Free ;
    end;
        
    if Assigned(goVariables)
    then begin
        goVariables.Free ;
    end ;

    if Assigned(goListLabel)
    then begin
        goListLabel.Free ;
    end ;
    
    if Assigned(goListProcedure)
    then begin
        goListProcedure.Free ;
    end ;
    
    if Assigned(goListOfFile)
    then begin
        goListOfFile.Free ;
    end ;
    
    if Assigned(goLineToFileLine)
    then begin
        goLineToFileLine.Free ;
    end ;
    
    if Assigned(goLineToFile)
    then begin
        goLineToFile.Free ;
    end ;
    
    if Assigned(goInternalFunction)
    then begin
        goInternalFunction.Free ;
    end ;
    
    if Assigned(goPointerOFVariables)
    then begin
        goPointerOFVariables.Free ;
    end ;
    
    if Assigned(goCurrentFunctionName)
    then begin
        goCurrentFunctionName.Free ;
    end ;
    
    if Assigned(goVarGetPostCookieFileData)
    then begin
        goVarGetPostCookieFileData.Free ;
    end ;
    
    if Assigned(Header)
    then begin
        Header.Free ;
    end ;
    
    if Assigned(goCurrentRootOfFile)
    then begin
        goCurrentRootOfFile.Free ;
    end ;
    
    if Assigned(goListOfExtension)
    then begin
        for i := 0 to goListOfExtension.Count - 1 do
        begin
            OsUnLoadExtension(goListOfExtension.GiveNameByIndex(i)) ;
        end ;
    end ;

    if Assigned(goListOfExtension)
    then begin
        goListOfExtension.Free ;
    end ;

    if Assigned(goConstantes)
    then begin
        goConstantes.Free ;
    end ;
end ;

{*****************************************************************************
 * ExplodeStrings
 * MARTINEAU Emeric
 *
 * Fonction qui split les commandes
 *
 * Paramètres d'entrée :
 *   - asText : texte à traiter
 *
 * Paramètre de sortie :
 *   - asListe : TStringList contenant les divers élément
 *
 *****************************************************************************}
procedure ExplodeStrings(asText : string; aoLigne : TStringList) ;
var
    { Element courant }
    lsElementCourant : string ;
    { Compteur de boucle pour asText }
    liIndexText : Integer ;
    { Compteur pour traiter un sous chaine dans asText }
    liIndexSousChaine : Integer ;
    { Longueur de asText }
    liLengthText : Integer ;
    { Indique si on est dans une chaine "" ou '' }
    lbInQuote : boolean ;
    { Caractère courant. On utilise string pour LowerCase() }
    lsCaractere : string ;
    { Délimiteur de chaine " ou ' }
    lsDelimiter : string ;
    { Indique si on est dans un nombre et si on a trouvé un point. Permet de la pas
      avoir de nombre avec plusieurs points }
    lbDotFound : boolean ;
    { Indique si on a trouvé un X est si on est donc en hexa décimal }
    lbXFound : boolean ;
    { Indique qu'il s'agit d'un pointeur }
    lbPointer : boolean ;
    { Position de fin de commentaire multi-ligne }

    procedure CopyVarName ;
    begin
        { Si on est dans le cas $$var }
        if asText[liIndexText] = '$'
        then begin
            lsElementCourant := lsElementCourant + '$' ;
            Inc(liIndexText) ;
        end ;
        
        while liIndexText < liLengthText do
        begin
            lsElementCourant := lsElementCourant + asText[liIndexText] ;
            Inc(liIndexText) ;

            lsCaractere := LowerCase(asText[liIndexText]) ;

            if not ((asText[liIndexText] in ['0'..'9']) or (lsCaractere[1] in ['a'..'z']) or (asText[liIndexText] = '_'))
            then begin
                if asText[liIndexText] = '['
                then begin
                    liIndexSousChaine := 0 ;

                    while liIndexSousChaine < (liLengthText - liIndexText) do
                    begin
                        if asText[liIndexText+liIndexSousChaine] <> ']'
                        then begin
                            lsElementCourant := lsElementCourant + asText[liIndexText+liIndexSousChaine] ;
                            Inc(liIndexSousChaine) ;
                        end
                        else begin
                            break ;
                        end ;
                    end ;

                    { Inutile d'ajouter ] car on refait un tour dans la boucle principal et c'est ajouté automatiquement }
                    Inc(liIndexText, liIndexSousChaine) ;
                end
                else begin
                    break ;
                end ;
            end ;
        end ;
    end ;
begin
    aoLigne.Clear ;

    lsElementCourant := '' ;
    liIndexText := 1 ;
    liLengthText := Length(asText) + 1 ;

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

    while liIndexText < liLengthText do
    begin
        if (asText[liIndexText] = '(') or
           (asText[liIndexText] = ')') or
           (asText[liIndexText] = '-') or
           (asText[liIndexText] = '+') or
           (asText[liIndexText] = '%') or
           (asText[liIndexText] = '=') or
           (asText[liIndexText] = '[') or
           (asText[liIndexText] = ']') or
           (asText[liIndexText] = ',') or
           (asText[liIndexText] = '/') or
           (asText[liIndexText] = '^') or
           (asText[liIndexText] = '~') or
           (asText[liIndexText] = '|')
        then begin
            aoLigne.Add(asText[liIndexText]) ;
        end
        else if (asText[liIndexText] = ';')
        then begin
            break ;
        end
        else if asText[liIndexText] = '.'
        then begin
            lsElementCourant := '.' ;

            if (liIndexText + 2) < liLengthText
            then begin
                if (asText[liIndexText+1] = '.') and (asText[liIndexText+2] = '.')
                then begin
                    lsElementCourant := lsElementCourant + '..' ;
                    Inc(liIndexText, 2) ;
                end ;
            end ;

            aoLigne.Add(lsElementCourant)
        end
        else if asText[liIndexText] = '*'
        then begin
            if liIndexText < liLengthText
            then begin
                { Si c'est une variable qui suit et qu'il n'y a rien avant, c'est un pointer }
                if (asText[liIndexText + 1] = '$') and (liIndexText = 0)
                then begin
                    lbPointer := True ;
                end
                else if (asText[liIndexText + 1] = '$') and (liIndexText > 0)
                then begin
                   { Si c'est une variable, on regarde avant l'étoile pour savoir si c'est
                     un nom de variable. Si c'est le cas, c'est un multiplication sinon, c'est
                     un pointeur }
                   if not (LowerCase(asText[liIndexText - 1]) in ['a'..'z']) and not (asText[liIndexText - 1] in ['0'..'9']) and not (asText[liIndexText - 1] = '_')
                   then begin
                       lbPointer := True ;
                   end
                   else begin
                       lbPointer := False ;
                   end ;
                end
                else begin
                    lbPointer := False ;
                end ;

                if lbPointer
                then begin

                    { C'est une variable }
                    lsElementCourant := '*' ;
                    Inc(liIndexText) ;

                    CopyVarName ;
                    
                    { Décrémente pour qu'on pointe sur le caratère qui nous à fait arrêté }
                    Dec(liIndexText) ;

                    aoLigne.Add(lsElementCourant) ;
                end
                else begin
                    aoLigne.Add('*') ;
                end ;
            end
            else begin
                aoLigne.Add('*') ;
            end ;
        end
        else if asText[liIndexText] = '&'
        then begin
            if liIndexText < liLengthText
            then begin
                { Si c'est une variable qui suit et qu'il n'y a rien avant, c'est un pointer }
                if (asText[liIndexText + 1] = '$') and (liIndexText = 0)
                then begin
                    lbPointer := True ;
                end
                else if (asText[liIndexText + 1] = '$') and (liIndexText > 0)
                then begin
                   { Si c'est une variable, on regarde avant l'étoile pour savoir si c'est
                     un nom de variable. Si c'est le cas, c'est un multiplication sinon, c'est
                     un pointeur }
                   if not (LowerCase(asText[liIndexText - 1]) in ['a'..'z']) and not (asText[liIndexText - 1] in ['0'..'9']) and not (asText[liIndexText - 1] = '_')
                   then begin
                       lbPointer := True ;
                   end
                   else begin
                       lbPointer := False ;
                   end ;
                end
                else begin
                    lbPointer := False ;
                end ;

                if lbPointer
                then begin

                    { C'est une variable }
                    lsElementCourant := '&' ;
                    Inc(liIndexText) ;

                    CopyVarName ;

                    { Décrémente pour qu'on pointe sur le caratère qui nous à fait arrêté }
                    Dec(liIndexText) ;

                    aoLigne.Add(lsElementCourant) ;
                end
                else begin
                    aoLigne.Add('&') ;
                end ;
            end
            else begin
                aoLigne.Add('&') ;
            end ;
        end
        else if asText[liIndexText] = '<'
        then begin
            if liIndexText < liLengthText
            then begin
                if asText[liIndexText+1] = '<'
                then begin
                    Inc(liIndexText) ;
                    aoLigne.Add('<<')
                end
                else if asText[liIndexText+1] = '='
                then begin
                    Inc(liIndexText) ;
                    aoLigne.Add('<=')
                end
                else if asText[liIndexText+1] = '>'
                then begin
                    Inc(liIndexText) ;
                    aoLigne.Add('<>')
                end
                else begin
                    aoLigne.Add('<') ;
                end ;
            end
            else begin
                aoLigne.Add('<') ;
            end ;
        end
        else if asText[liIndexText] = '>'
        then begin
            if liIndexText < liLengthText
            then begin
                if asText[liIndexText+1] = '>'
                then begin
                    Inc(liIndexText) ;
                    aoLigne.Add('>>')
                end
                else if asText[liIndexText+1] = '='
                then begin
                    Inc(liIndexText) ;
                    aoLigne.Add('>=')
                end
                else begin
                    aoLigne.Add('>') ;
                end ;
            end
            else begin
                aoLigne.Add('>') ;
            end ;
        end
        else if (asText[liIndexText] in ['0'..'9'])
        then begin
            { C'est un nombre }
            lsElementCourant := '' ;
            lbDotFound := False ;
            lbXFound := False ;

            while liIndexText < liLengthText do
            begin
                if (asText[liIndexText] in ['0'..'9']) or (asText[liIndexText] in ['a'..'f']) or (asText[liIndexText] in ['A'..'F'])
                then
                    lsElementCourant := lsElementCourant + asText[liIndexText]
                else if (not lbDotFound) and (asText[liIndexText] = '.')
                then begin
                    lbDotFound := True ;
                    lsElementCourant := lsElementCourant + asText[liIndexText] ;
                end
                else if (not lbXFound) and (asText[liIndexText] = 'x')
                then begin
                    lbXFound := True ;
                    lsElementCourant := lsElementCourant + asText[liIndexText] ;
                end
                else begin
                    break ;
                end ;

                Inc(liIndexText) ;
            end ;

            aoLigne.Add(lsElementCourant) ;

            { Décrément car on à une Inc(liIndexText) à la fin de la boucle }
            Dec(liIndexText) ;
        end
        else if (asText[liIndexText] = '"') or (asText[liIndexText] = '''')
        then begin
            lsDelimiter := asText[liIndexText] ;

            { On est dans une chaine }
            lsElementCourant := '' ;
            lbInQuote := True ;
            Inc(liIndexText) ;

            while liIndexText <= liLengthText do
            begin
                { Prochain caractère }
                if asText[liIndexText] = '\'
                then begin
                    Inc(liIndexText) ;

                    if liIndexText <= liLengthText
                    then begin
                        if asText[liIndexText] = 'n'
                        then begin
                            asText[liIndexText] := char(10) ;
                        end
                        else if asText[liIndexText] = 'r'
                        then begin
                            asText[liIndexText] := char(13) ;
                        end
                        else if asText[liIndexText] = '0'
                        then begin
                            asText[liIndexText] := char(0) ;
                        end
                        else if asText[liIndexText] = 't'
                        then begin
                            asText[liIndexText] := char(9) ;
                        end ;
                    end
                end
                else if asText[liIndexText] = lsDelimiter
                then begin
                    lbInQuote := False ;
                    break ;
                end ;

                lsElementCourant := lsElementCourant + asText[liIndexText] ;

                Inc(liIndexText) ;
            end ;

            aoLigne.Add('"' + lsElementCourant + '"') ;

            if lbInQuote
            then begin
                ErrorMsg(csNoEndString) ;
            end ;
        end
        else begin
            if (asText[liIndexText] <> #9) and (asText[liIndexText] <> ' ')
            then begin
                lsElementCourant := '' ;

                CopyVarName ;

                { Décrémente pour qu'on pointe sur le caratère qui nous à fait arrêté }
                Dec(liIndexText) ;

                aoLigne.Add(lsElementCourant) ;
            end ;
        end ;

        Inc(liIndexText) ;
    end ;
end ;

{*****************************************************************************
 * ErrorMsg
 * MARTINEAU Emeric
 *
 * Affiche une erreur et inquique au programme qu'il y a une erreur
 *
 * Paramètres d'entrée :
 *   - asText : texte à traiter
 *
 *****************************************************************************}
procedure ErrorMsg(asText : string) ;
begin
    if (not gbIsHeaderSend)
    then begin
        SendHeader ;
    end ;

    { Evite d'afficher un message d'erreur s'il y a déjà un message d'erreur
      d'affiché }
    if not gbNoError and not gbError
    then begin
        if goLineToFile.count > 0
        then begin
            //OutPutString(sErrorIn + ListOfFile[MyStrToInt(LineToFile[CurrentLineNumber])], false)
            WriteLn(csErrorIn + goListOfFile[MyStrToInt(goLineToFile[giCurrentLineNumber])]) ;
        end
        else begin
            //OutPutString(sGeneralError + text, false) ;
            WriteLn(csGeneralError + asText) ;
        end ;

        if (goCurrentFunctionName.Count > 0) and (goLineToFileLine.Count >0)
        then begin
            //OutPutString(AddSlashes(Format(' [%s:%s] %s', [CurrentFunctionName[CurrentFunctionName.Count - 1], LineToFileLine[CurrentLineNumber], text])) + '\n', true) ;
            WriteLn(Format(' [%s:%s] %s', [goCurrentFunctionName[goCurrentFunctionName.Count - 1], goLineToFileLine[giCurrentLineNumber], asText])) ;
        end ;

        gbError := True ;
    end ;
end ;

{*****************************************************************************
 * ErrorMsg
 * MARTINEAU Emeric
 *
 * Affiche une erreur et inquique au programme qu'il y a une erreur
 *
 * Paramètres d'entrée :
 *   - asText : texte à traiter
 *
 * Retour : nom du label
 *****************************************************************************}
function GetLabel(asText : string) : string ;
Var
    { Compteur de boucle }
    liIndex : Integer ;
    { Longueur de asText }
    liLength : integer ;
begin
    asText := copy(asText, 1, pos(':', asText) - 1) ;

    asText := LowerCase(Trim(asText)) ;

    if not (asText[1] in ['0'..'9'])
    then begin
        liLength := length(asText) ;

        for liIndex := 2 to liLength do
        begin
            if not ((asText[liIndex] in ['a'..'z']) or (asText[liIndex] in ['0'..'9']))
            then begin
                asText := '' ;
                break ;                
            end ;
        end ;

        Result := asText ;
    end
    else begin
        Result := '' ;
    end ;
end ;

{*****************************************************************************
 * WarningMsg
 * MARTINEAU Emeric
 *
 * Affiche une alerte
 *
 * Paramètres d'entrée :
 *   - asText : texte à afficher
 *
 *****************************************************************************}
procedure WarningMsg(asText : string) ;
begin
    if (not gbIsHeaderSend)
    then begin
        SendHeader ;
    end ;
    
    if gbWarning
    then begin
        //OutPutString(sWarningIn + ListOfFile[MyStrToInt(LineToFile[CurrentLineNumber])], false) ;
        WriteLn(csWarningIn + goListOfFile[MyStrToInt(goLineToFile[giCurrentLineNumber])]) ;

        //OutPutString(Format(' [%s:%s] %s', [CurrentFunctionName[CurrentFunctionName.Count - 1],LineToFileLine[CurrentLineNumber], text]) + '\n', true) ;
        WriteLn(Format(' [%s:%s] %s', [goCurrentFunctionName[goCurrentFunctionName.Count - 1], goLineToFileLine[giCurrentLineNumber], asText])) ;
    end ;
end ;

{*****************************************************************************
 * SetVar
 * MARTINEAU Emeric
 *
 * Donne la valeur à une variable
 *
 * Paramètres d'entrée :
 *   - asVariable : nom de la variable avec le $
 *   - asValue    : valeur de la variable
 *
 *****************************************************************************}
procedure SetVar(asVariable : string; asValue : string) ;
var
    { Longueur du nom de la variable }
    liLength : Integer ;
    { Indique s'il s'agit d'un pointeur }
    lbIsPointer : boolean ;
    { Contient la partie crochet de la variable }
    lsTab : String ;
    { Contient le nom de la variable sans les crochets }
    lsVarNameWithoutTab : String ;
    { Position du crochet ouvrant }
    liStartTab : Integer ;
    { Contient la pratie crochet [, 1, ]}
    loExplodeTab : TStringList ;
    { Compteur de boucle }
    liIndex : Integer ;
begin
    lbIsPointer := False ;
    // inutile cas fait dans le Variables.Add
    //asVariable := LowerCase(asVariable) ;

    if Length(asVariable) > 2
    then begin
        if asVariable[1] = '*'
        then begin
            { Pointer de asVariable }
            asVariable := copy(asVariable, 2, Length(asVariable) - 1) ;
            lbIsPointer := True ;
        end ;
    end ;

    liStartTab := pos('[', asVariable) ;

    if liStartTab > 0
    then begin
        lsVarNameWithoutTab := copy(asVariable, 1, liStartTab-1) ;
        lsTab := copy(asVariable, liStartTab, length(asVariable) - liStartTab + 1) ;

        loExplodeTab := TStringList.Create ;

        { Eclate tout les tableaux }
        ExplodeStrings(lsTab, loExplodeTab) ;

        { Convertit les valeurs }
        GetValueOfStrings(loExplodeTab) ;

        { Vérifie que pour chaque élément on ait bien un nombre entier}
        for liIndex := 0 to loExplodeTab.Count - 1 do
        begin
            if (loExplodeTab[liIndex] <> '[') and (loExplodeTab[liIndex] <> ']')
            then begin
                if MyStrToInt(loExplodeTab[liIndex]) < 0
                then begin
                    ErrorMsg(csInvalidIndex) ;
                    Break ;
                end ;
            end ;
        end ;

        if (not gbError) and (not gbQuit)
        then begin
            lsTab := '' ;

            for liIndex := 0 to loExplodeTab.Count - 1 do
            begin
                lsTab := lsTab + loExplodeTab[liIndex] ;
            end ;
        end ;

        loExplodeTab.Free ;

        asVariable := lsVarNameWithoutTab ;
    end
    else begin
        lsTab := '' ;
    end ;

    if (not gbError) and (not gbQuit)
    then begin
        liLength := Length(asVariable) ;

        if liLength > 2
        then begin
            if asVariable[2] = '$'
            then begin
                asVariable := Copy(asVariable, 2, liLength - 1) ;

                asVariable := getVar(asVariable) ;
                
                { On vérifie que dans la variable il y ait le $ au début }
                if Length(asVariable) > 0
                then begin
                    if asVariable[1] <> '$'
                    then begin
                        asVariable := '$' + asVariable ;
                    end ;
                    
                    if not CheckVarName(2, asVariable)
                    then begin
                        ErrorMsg(Format(csNotAVariable, [asVariable])) ;
                    end ;
                end ;
            end ;
        end ;

        if lbIsPointer
        then begin
            SetReference(asVariable + lsTab, asValue) ;
        end
        else begin
            goVariables.Add(asVariable + lsTab, asValue) ;
        end ;
    end ;
end ;

{*****************************************************************************
 * GetVar
 * MARTINEAU Emeric
 *
 * Retourne la valeur d'un variable
 *
 * Paramètres d'entrée :
 *   - asVariable : nom de la variable avec le $
 *
 *****************************************************************************}
function GetVar(asVariable : string) : String ;
var
    { Nom de la variable sous & ou [] }
    lsVarName : String ;
    { Nom du pointer si c'est &$truc }
    lsPointerName : string ;
    { Longueur du nom de la variable }
    liLength : Integer ;
    { Indique s'il s'agit d'un pointeur &$truc }
    lbIsPointer : boolean ;
    { Indique s'il s'agit d'une référence *$truc }
    lbIsReference : Boolean ;
    { Contient la partie crochet [..][..] }
    lsTab : String ;
    { Position de départ du crochet }
    liStartTab : Integer ;
    { Contient la pratie crochet [, 1, ]}
    loExplodeTab : TStringList ;
    { Compteur de boucle }
    liIndex : Integer ;
begin
    liLength := Length(asVariable) ;
    lbIsPointer := False ;
    lbIsReference := False ;

    if liLength > 1
    then begin
        liStartTab := pos('[', asVariable) ;

        if liStartTab > 0
        then begin
            lsVarName := copy(asVariable, 1, liStartTab-1) ;
            lsTab := copy(asVariable, liStartTab, liLength - liStartTab + 1) ;
            loExplodeTab := TStringList.Create ;

            { Eclate tout les tableaux }
            ExplodeStrings(lsTab, loExplodeTab) ;

            { Convertit les valeurs }
            GetValueOfStrings(loExplodeTab) ;

            { Vérifie que pour chaque élément on ait bien un nombre entier}
            for liIndex := 0 to loExplodeTab.Count - 1 do
            begin
                if (loExplodeTab[liIndex] <> '[') and (loExplodeTab[liIndex] <> ']')
                then begin
                    if MyStrToInt(loExplodeTab[liIndex]) < 0
                    then begin
                        ErrorMsg(csInvalidIndex) ;
                        Break ;
                    end ;
                end ;
            end ;

            if (not gbError) and (not gbQuit)
            then begin
                lsTab := '' ;

                for liIndex := 0 to loExplodeTab.Count - 1 do
                begin
                    lsTab := lsTab + loExplodeTab[liIndex] ;
                end ;
            end ;

            loExplodeTab.Free ;

            asVariable := lsVarName ;
        end
        else begin
            lsTab := '' ;
        end ;

        if (not gbError) and (not gbQuit)
        then begin
            lsVarName := asVariable ;

            if asVariable[1] = '&'
            then begin
                { C'est un pointer de asVariable }
                if liLength > 2
                then begin
                    lsVarName := copy(asVariable, 2, liLength - 1) ;
                    lbIsPointer := True ;
                end
                else begin
                    ErrorMsg(csInvalidPointer) ;
                    Result := '' ;
                end ;
            end
            else if asVariable[1] = '*'
            then begin
                { C'est une récupération de asVariable }
                if liLength > 2
                then begin
                    lsVarName := copy(asVariable, 2, liLength - 1) ;
                    lbIsReference := True ;
                end
                else begin
                    ErrorMsg(csInvalidPointer) ;
                    Result := '' ;
                end ;
            end
            else if asVariable[2] = '$'
            then begin
                { On peut avoir un $$x }
                if liLength > 2
                then begin
                    { La asVariable est du type $$x }
                    lsVarName := copy(asVariable, 2, liLength - 1) ;

                    lsVarName := goVariables.Give(lsVarName) ;

                    { On vérifie que dans la variable il y ait le $ au début }
                    if Length(lsVarName) > 0
                    then begin
                        if lsVarName[1] <> '$'
                        then begin
                            lsVarName := '$' + lsVarName ;
                        end ;

                        if not CheckVarName(2, lsVarName)
                        then begin
                            ErrorMsg(Format(csNotAVariable, [lsVarName])) ;
                        end ;
                    end ;
                end
                else begin
                    ErrorMsg(csInvalidVarName) ;
                    Result := '' ;
                end ;
            end ;
        end ;

        if (not gbError) and (not gbQuit)
        then begin
            if lbIsPointer
            then begin
                if goPointerOfVariables.IsSetByVarName(lsVarName + lsTab)
                then begin
                    Result := 'p{' + goPointerOfVariables.GivePointerByVarName(lsVarName + lsTab) + lsVarName + '}';
                end
                else begin
                    { Si c'est un pointeur on récupère l'adresse de la asVariable
                      Variables et on ajoute le nom de la asVariable }
                    lsPointerName := UniqId ;
                    goPointerOfVariables.Add(lsPointerName, lsVarName + lsTab, goVariables) ;
                    Result := 'p{' + lsPointerName + lsVarName + lsTab + '}';
                end ;
            end
            else if lbIsReference
            then begin
                Result := GetReference(lsVarName + lsTab)
            end
            else begin
                Result := goVariables.Give(lsVarName + lsTab) ;
            end ;

            if goVariables.isSet(lsVarName + lsTab) = False
            then begin
                WarningMsg(Format(csVariableDoesntExist, [lsVarName ])) ;
            end ;
        end ;
    end
    else begin
        ErrorMsg(csInvalidVarName) ;
        Result := '' ;
    end ;
end ;

{*****************************************************************************
 * CheckVarName
 * MARTINEAU Emeric
 *
 * Fonction vérfie si le nom de la variable est valide
 *
 * Paramètres d'entrée :
 *   aiStart : Index de début de vérification de la variable (juste après le $)
 *   asVarName : texte contenant la variable
 *
 * Retour : true si c'est un nom valide pour une variable
 *****************************************************************************}
function CheckVarName(aiStart : Integer; asVarName : string) : boolean ;
var
    { Compteur de boucle }
    liIndex : Integer;
    { Longueur de la variable }
    liLength : Integer ;
begin
    if not (asVarName[aiStart] in ['0'..'9'])
    then begin
        Result := True ;
        liLength := Length(asVarName) ;

        for liIndex := aiStart to liLength do
        begin
            if not ((asVarName[liIndex] in ['a'..'z']) or (asVarName[liIndex] in ['0'..'9']) or (asVarName[aiStart] = '_'))
            then begin
                Result := False ;
                break ;                
            end ;
        end ;

        { Si il y a une erreur c'est peut-être un crochet }
        if Result = False
        then begin
            if (asVarName[liIndex] = '[') and (asVarName[liLength] = ']')
            then begin
                Result := True ;
            end ;
        end ;
    end
    else begin
        Result := False ;
    end ;

    if Result = False
    then begin
        ErrorMsg(csInvalidVarName) ;
    end ;
end ;

{*****************************************************************************
 * IsVar
 * MARTINEAU Emeric
 *
 * Fonction vérfie qu'il s'agit d'une variable
 *
 * Paramètres d'entrée :
 *   asVarName : texte contenant la variable
 *
 * Retour : true si c'est un nom valide pour une variable
 *****************************************************************************}
function IsVar(asText : string) : boolean ;
Var
    { Longueur de la variable }
    liLength : integer ;
begin
    asText := LowerCase(asText) ;
    liLength := length(asText) ;
    Result := False ;
    
    if liLength > 1
    then begin
        if asText[1] = '$'
        then begin
            if liLength > 1
            then begin
                if asText[2] = '$'
                then begin
                    Result := CheckVarName(3, asText) ;
                end
                else begin
                    Result := CheckVarName(2, asText) ;
                end ;
            end
            else begin
                Result := CheckVarName(2, asText) ;
            end ;
        end
        else if (asText[1] = '&') or (asText[1] = '*')
        then begin
            { Est-ce un pointeur sur une variable ? }
            if liLength > 2
            then begin
                if asText[2] = '$'
                then begin
                    Result := CheckVarName(3, asText) ;
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

{*****************************************************************************
 * GetValueOfStrings
 * MARTINEAU Emeric
 *
 * Fonction convertit une TStringList liste en valeur (1+2 => 3)
 *
 * Paramètres d'entrée :
 *   aoArguments : liste de valeurs à traiter
 *
 * Retour : nombre d'élément restant
 *****************************************************************************}
function GetValueOfStrings(var aoArguments : TStringList) : Integer ;
var
    { Compteur de boucle }
    liCompteur : Integer ;
    { Position de l'item (&, * ...) rechercher dans la liste aoArguments }
    liIndexItem : Integer ;
    { Variable recevant la valeur entière si c'est un nombre }
    liEntier : LongInt ;
    { Liste d'argument avec les parenthèses si c'est un appel de fonction }
    loArgumentsAvecParentheses : TStringList ;
    { Nombre de parenthèses recontrées pour savoir quand s'arrête les aoArguments
      de fonction }
    liNbParentheses : Integer ;
    { Nombre d'élément dans l'appel de la fonction }
    liNbElements : Integer ;
    { Indique si l'opérateur in a été trouvé }
    lbFoundInValue : Boolean ;
    { Variable recevant la valeur float si c'est un nombre }
    lfFloattant : Extended ;
    { Position de l'élément dans l'opérateur in trouvé }
    liPosInValue : Integer ;
    { fonction}
    lFonction : ModelProcedure ;
    { Nombre d'élément aoArguments }
    liCountArgs : Integer ;
    { Valeur entière temporaire }
    liTmpInteger : Integer ;
    { Valeur temporaire }
    lsTmp1 : String ;
    lsTmp2 : String ;
    { Marqueur de fonction }
    loFunctionMarque : TStringList ;
    { Condition pour savoir si c'est un mot clef }
    lsCondition : String ;

    procedure DeleteElementInCurrentLine(liIndexItem : Integer) ;
    begin
        aoArguments.Delete(liIndexItem) ;

        if liIndexItem < loFunctionMarque.Count
        then
            loFunctionMarque.Delete(liIndexItem) ;
    end ;

label EndOfGetValueOfStrings ;

begin
    loArgumentsAvecParentheses := TStringList.Create ;
    loFunctionMarque := TStringList.Create ;

    liCountArgs := aoArguments.Count ;
    liCompteur := 0 ;

    {ETAPE 0 : marquer les fonctions }
    while liCompteur < liCountArgs do
    begin
        lsCondition := LowerCase(aoArguments[liCompteur]) ;

        if aoArguments[liCompteur] <> ''
        then begin
            if ((aoArguments[liCompteur][1] in ['a'..'z']) or (aoArguments[liCompteur][1] in ['A'..'Z']) or (aoArguments[liCompteur][1] = '_')) and
               not IsKeyword(lsCondition)
            then begin
                { c'est une fonction }
                loFunctionMarque.Add('1') ;
            end
            else begin
                loFunctionMarque.Add('0') ;
            end ;
        end
        else begin
            loFunctionMarque.Add('0') ;
        end ;

        Inc(liCompteur) ;
    end ;
    liCompteur := 0 ;

    {ETAPE 1 : convertire les variables et fonctions }
    while liCompteur < liCountArgs do
    begin
        lsCondition := LowerCase(aoArguments[liCompteur]) ;

        if aoArguments[liCompteur] <> ''
        then begin
            if isVar(aoArguments[liCompteur])
            then begin
                aoArguments[liCompteur] := GetVar(aoArguments[liCompteur])
            end
            else if IsConst(aoArguments[liCompteur])
            then begin
                aoArguments[liCompteur] := GetConst(aoArguments[liCompteur])
            end
            else begin
                { Est-ce une fonction ? }
                if loFunctionMarque[liCompteur] = '1'
                then begin
                    { Si on a trouvé une parenthèse ouvrante, on doit la traiter à part }
                    liNbParentheses := 0 ;
                    liNbElements := 0 ;
                    loArgumentsAvecParentheses.Clear ;

                    for liIndexItem := (liCompteur + 1) to aoArguments.Count - 1 do
                    begin
                        { Compte le nombre d'élément }
                        Inc(liNbElements) ;
                        loArgumentsAvecParentheses.Add(aoArguments[liIndexItem]) ;

                        if aoArguments[liIndexItem] = '('
                        then begin
                            Inc(liNbParentheses) ;
                        end
                        else if aoArguments[liIndexItem] = ')'
                        then begin
                            Dec(liNbParentheses) ;
                        end ;

                        if liNbParentheses = 0
                        then begin
                            break ;
                        end ;
                    end ;

                    { Supprime les paramètres de la ligne de commandee }
                    for liIndexItem := 1 to liNbElements do
                    begin
                        DeleteElementInCurrentLine(liCompteur+1) ;
                        Dec(liCountArgs) ;
                    end ;

                    DeleteVirguleAndParenthese(loArgumentsAvecParentheses) ;

                    lFonction := goInternalFunction.Give(aoArguments[liCompteur]) ;
                    gsResultFunction := '' ;

                    {$IFDEF FPC}
                    if lFonction <> nil
                    {$ELSE}
                    if @lFonction <> nil
                    {$ENDIF}
                    then begin
                        if goInternalFunction.isParse(aoArguments[liCompteur])
                        then begin
                            GetValueOfStrings(loArgumentsAvecParentheses) ;
                        end ;

                        lFonction(loArgumentsAvecParentheses) ;
                    end
                    else begin
                        GetValueOfStrings(loArgumentsAvecParentheses) ;

                        if not CallExtension(aoArguments[liCompteur], loArgumentsAvecParentheses)
                        then begin
                            liTmpInteger := ExecuteUserProcedure(aoArguments[liCompteur], loArgumentsAvecParentheses) ;

                            if liTmpInteger <> -1
                            then begin
                                { +1 car ExecuteUserProcedure 1 de trop pour notre cas }
                                giCurrentLineNumber := liTmpInteger + 1 ;
                                goto EndOfGetValueOfStrings ;
                            end ;
                        end ;
                    end ;

                    { On met le résultat entre quillemet pour éviter que le résultat soit
                      interprété par exemple sur on retourne le caractère - }
                    aoArguments[liCompteur] := '"' + gsResultFunction + '"' ;
                end ;
            end ;
        end ;

        Inc(liCompteur) ;
    end ;

    {ETAPE 2 : chercher les parenthèses }
    if (not gbError) and (not gbQuit)
    then begin
        repeat
            liIndexItem := aoArguments.IndexOf('(') ;

            if liIndexItem <> -1
            then begin
                { On a trouvé une parenthèse ouvrante, on doit la traiter à part }
                liNbParentheses := 1 ;
                liNbElements := 0 ;
                loArgumentsAvecParentheses.Clear ;

                { démarre après la parenthèse ouvrante }
                for liCompteur := (liIndexItem + 1) to aoArguments.Count - 1 do
                begin
                    if aoArguments[liCompteur] = '('
                    then begin
                        Inc(liNbParentheses) ;
                    end
                    else if aoArguments[liCompteur] = ')'
                    then begin
                        Dec(liNbParentheses) ;
                    end ;

                    { évite d'avoir la parenthèse fermante }
                    if liNbParentheses = 0
                    then begin
                        break ;
                    end ;

                    loArgumentsAvecParentheses.Add(aoArguments[liCompteur]) ;
                    { Compte le nombre d'élément }
                    Inc(liNbElements) ;
                end ;

                { Vérifie qu'on n'a pas oublié de parenthèses }
                if (liIndexItem + liNbElements + 1) < aoArguments.Count
                then begin
                    { Supprime tout les éléments qu'il y entre parenthèse + la dernière
                      parenthèse }
                    for liCompteur := 1 to liNbElements + 1 do
                    begin
                        aoArguments.Delete(liIndexItem) ;
                    end ;

                    { Enregistre à la place de la parenthèse la valeur }
                    if GetValueOfStrings(loArgumentsAvecParentheses) = 1
                    then begin
                        aoArguments[liIndexItem] := loArgumentsAvecParentheses[0]
                    end
                    else begin
                        ErrorMsg(csMissingOperator) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(csMissingPar) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 2bis convertir x * - y en x * (-1)}
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := -1 ;

        repeat
            Inc(liIndexItem) ;
        
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, '-') ;

            if liIndexItem <> -1
            then begin
                if liIndexItem > 0
                then begin
                    if not isNumeric(GetString(aoArguments[liIndexItem - 1]))
                    then begin
                        { Supprime le - }
                        aoArguments.Delete(liIndexItem) ;
                        { le nouvelle index pointe sur le chiffre }
                        aoArguments[liIndexItem] := '-' + GetString(aoArguments[liIndexItem]) ;
                    end
                    else begin
                        { Remplace le - par + }
                        aoArguments[liIndexItem] := '+' ;
                        { le nouvelle index pointe sur le chiffre }
                        aoArguments[liIndexItem + 1] := '-' + GetString(aoArguments[liIndexItem + 1]) ;
                    end ;
                end
                else begin
                    lsTmp1 := GetString(aoArguments[liIndexItem + 1]) ;

                    if isNumeric(lsTmp1)
                    then begin
                        aoArguments.Delete(liIndexItem) ;
                        aoArguments[liIndexItem] := '-' + lsTmp1 ;
                    end
                    else begin
                        ErrorMsg(Format(csNoOnString, ['-'])) ;
                    end ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 3 : Chercher in }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            { L'aventage de IndexOf c'est qu'il fait une recherche sans tenir
              compte de la case }
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, 'in') ;

            if liIndexItem <> -1
            then begin
                { $var in [ "truc", "machin" }
                if aoArguments[liIndexItem + 1] = '['
                then begin
                    lbFoundInValue := False ;

                    { Supprime le "in" }
                    aoArguments.Delete(liIndexItem) ;

                    { supprime le "[" }
                    aoArguments.Delete(liIndexItem) ;

                    liPosInValue := 0 ;

                    aoArguments[liIndexItem - 1] := GetString(aoArguments[liIndexItem - 1]) ;

                    while liIndexItem < (aoArguments.Count - 1) do
                    begin
                        if not lbFoundInValue
                        then begin
                            if GetString(aoArguments[liIndexItem]) = aoArguments[liIndexItem - 1]
                            then begin
                                lbFoundInValue := True ;
                            end ;
                        end
                        else begin
                            Inc(liPosInValue) ;
                        end ;

                        { Va à l'élément suivant }
                        aoArguments.Delete(liIndexItem) ;

                        if aoArguments[liIndexItem] = ','
                        then begin
                            aoArguments.Delete(liIndexItem) ;
                        end
                        else if aoArguments[liIndexItem] = ']'
                        then begin
                            break ;
                        end ;
                    end ;

                    if aoArguments[liIndexItem] <> ']'
                    then begin
                        { On a atteind la fin de la ligne sans trouver de "]"}
                        ErrorMsg(csMissingCrochet) ;
                        break ;
                    end
                    else begin
                        { Supprimer le ']' }
                        aoArguments.Delete(liIndexItem) ;

                        if lbFoundInValue
                        then begin
                           aoArguments[liIndexItem - 1] := IntToStr(liPosInValue)
                        end
                        else begin
                           aoArguments[liIndexItem - 1] := '-1' ;
                        end ;

                        { supprimer les éléments }
                    end ;
                end
                else begin
                    ErrorMsg(csMissingCrochet2) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 5 : Chercher ~ (not) }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := -1 ;
        
        repeat
            Inc(liIndexItem) ;
            
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, '~') ;
            
            if liIndexItem <> -1
            then begin
                { Si ce n'est pas le dernier élément }
                if (liIndexItem + 1) < aoArguments.Count
                then begin
                    lsTmp1 := GetString(aoArguments[liIndexItem + 1]) ;

                    if isNumeric(lsTmp1)
                    then begin
                        { x   : ~
                          x+1 : value

                          on remplace x par la valeur négative. Il faut alors
                          supprimer x+1 }
                        if isInteger(lsTmp1)
                        then begin
                            liEntier := MyStrToInt(lsTmp1) ;
                            aoArguments[liIndexItem] := IntToStr(not liEntier) ;
                        end
                        else begin
                            ErrorMsg(csNoTildeOnFloat) ;
                            break ;
                        end ;

                        aoArguments.Delete(liIndexItem + 1);
                    end
                    else begin
                        ErrorMsg(Format(csNoOnString, ['~'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(csMissingAfterOperator, ['~'])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 6 : Chercher ^ (puissance) }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, '^') ;

            if liIndexItem <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((liIndexItem + 1) < aoArguments.Count) and (liIndexItem <> 0)
                then begin
                    lsTmp1 := GetString(aoArguments[liIndexItem + 1]) ;
                    lsTmp2 := GetString(aoArguments[liIndexItem - 1]) ;

                    if isInteger(lsTmp1) and isInteger(lsTmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        liEntier := MyStrToInt(lsTmp1) ;

                        liEntier := FloatToInt(caree(MyStrToFloat(lsTmp2), liEntier)) ;

                        aoArguments[liIndexItem] := IntToStr(liEntier) ;
                        aoArguments.Delete(liIndexItem - 1);
                        { x-1 : ^
                          x  : value
                        }
                        aoArguments.Delete(liIndexItem);
                    end
                    else if isFloat(lsTmp1) and isFloat(lsTmp2)
                    then begin
                        if isInteger(lsTmp1)
                        then begin
                            { x-1  : value
                              x   : ^
                              x+2 : value
                              on remplace x par le résultat. Il faut alors supprimer
                              x et x+2}
                            lfFloattant := MyStrToFloat(lsTmp2) ;

                            liEntier := MyStrToInt(lsTmp1) ;

                            lfFloattant := caree(lfFloattant, liEntier) ;
                            aoArguments[liIndexItem] := MyFloatToStr(lfFloattant) ;
                            aoArguments.Delete(liIndexItem - 1);
                            { x-1 : ^
                              x  : value
                            }
                            aoArguments.Delete(liIndexItem);
                        end
                        else begin
                             ErrorMsg(csExposantNotInteger) ;
                             break ;
                        end ;
                    end
                    else begin
                        ErrorMsg(Format(csNoOnString, ['^'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(csMissingAfterOperator, ['^'])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 7 : Chercher *  }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := 0 ;
            
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, '*') ;
            
            if liIndexItem <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((liIndexItem + 1) < aoArguments.Count) and (liIndexItem <> 0)
                then begin
                    lsTmp1 := GetString(aoArguments[liIndexItem + 1]) ;
                    lsTmp2 := GetString(aoArguments[liIndexItem - 1]) ;

                    if isInteger(lsTmp1) and isInteger(lsTmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        liEntier := MyStrToInt(lsTmp2) * MyStrToInt(lsTmp1) ;
                        aoArguments[liIndexItem] := IntToStr(liEntier) ;
                        aoArguments.Delete(liIndexItem - 1);
                        { x-1 : ^
                          x  : value
                        }
                        aoArguments.Delete(liIndexItem);
                    end
                    else if isFloat(lsTmp1) and isFloat(lsTmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        lfFloattant := MyStrToFloat(lsTmp2) * MyStrToFloat(lsTmp1) ;
                        aoArguments[liIndexItem] := MyFloatToStr(lfFloattant) ;
                        aoArguments.Delete(liIndexItem - 1);
                        { x-1 : ^
                          x  : value
                        }
                        aoArguments.Delete(liIndexItem);
                    end
                    else begin
                        ErrorMsg(Format(csNoOnString, ['*'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['*'])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 8 : Chercher /  }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, '/') ;

            if liIndexItem <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((liIndexItem + 1) < aoArguments.Count) and (liIndexItem <> 0)
                then begin
                    lsTmp1 := GetString(aoArguments[liIndexItem + 1]) ;
                    lsTmp2 := GetString(aoArguments[liIndexItem - 1]) ;

                    if isInteger(lsTmp1) and isInteger(lsTmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        liEntier := MyStrToInt(lsTmp1) ;

                        if liEntier <> 0
                        then begin
                            liEntier := MyStrToInt(lsTmp2) div liEntier ;
                            aoArguments[liIndexItem] := IntToStr(liEntier) ;
                            aoArguments.Delete(liIndexItem - 1);
                            { x-1 : ^
                              x  : value
                            }
                            aoArguments.Delete(liIndexItem);
                        end
                        else begin
                             ErrorMsg(csDivideByZero) ;
                             break ;
                        end ;
                    end
                    else if isFloat(lsTmp1) and isFloat(lsTmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        lfFloattant := MyStrToFloat(lsTmp1) ;

                        if lfFloattant <> 0
                        then begin
                            lfFloattant := MyStrToFloat(lsTmp2) / lfFloattant ;
                            aoArguments[liIndexItem] := MyFloatToStr(lfFloattant) ;
                            aoArguments.Delete(liIndexItem - 1);
                            { x-1 : ^
                              x  : value
                            }
                            aoArguments.Delete(liIndexItem);
                        end
                        else begin
                             ErrorMsg(csDivideByZero) ;
                             break ;
                        end ;
                    end
                    else begin
                        ErrorMsg(Format(csNoOnString, ['/'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['/'])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 9 : Chercher %  }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, '%') ;

            if liIndexItem <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((liIndexItem + 1) < aoArguments.Count) and (liIndexItem <> 0)
                then begin
                    lsTmp1 := GetString(aoArguments[liIndexItem + 1]) ;
                    lsTmp2 := GetString(aoArguments[liIndexItem - 1]) ;

                    if isInteger(lsTmp1) and isInteger(lsTmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        liEntier := MyStrToInt(lsTmp2) mod MyStrToInt(lsTmp1) ;
                        aoArguments[liIndexItem] := IntToStr(liEntier) ;
                        aoArguments.Delete(liIndexItem - 1);
                        { x-1 : ^
                          x  : value
                        }
                        aoArguments.Delete(liIndexItem);
                    end
                    else begin
                        ErrorMsg(csNoOnStringOrFloat) ;
                        Break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['%'])) ;
                    Break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 10 : Chercher +  }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, '+') ;

            if liIndexItem <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((liIndexItem + 1) < aoArguments.Count) and (liIndexItem <> 0)
                then begin
                    lsTmp1 := GetString(aoArguments[liIndexItem + 1]) ;
                    lsTmp2 := GetString(aoArguments[liIndexItem - 1]) ;

                    if isInteger(lsTmp1) and isInteger(lsTmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x+1 par le résultat. Il faut alors supprimer
                          x et x+2}
                        liEntier := MyStrToInt(lsTmp2) + MyStrToInt(lsTmp1) ;
                        aoArguments[liIndexItem] := IntToStr(liEntier) ;
                        aoArguments.Delete(liIndexItem - 1);
                        { x-1 : ^
                          x  : value
                        }
                        aoArguments.Delete(liIndexItem);
                    end
                    else if isFloat(lsTmp1) and isFloat(lsTmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x+1 par le résultat. Il faut alors supprimer
                          x et x+2}
                        lfFloattant := MyStrToFloat(lsTmp2) + MyStrToFloat(lsTmp1) ;
                        aoArguments[liIndexItem] := MyFloatToStr(lfFloattant) ;
                        aoArguments.Delete(liIndexItem - 1);
                        { x-1 : ^
                          x  : value
                        }
                        aoArguments.Delete(liIndexItem);
                    end
                    else begin
                        { x-1 : string
                          x   : +
                          x+1 : string
                        }
                        aoArguments[liIndexItem - 1] := lsTmp2 + lsTmp1 ;

                        aoArguments.Delete(liIndexItem);
                        aoArguments.Delete(liIndexItem);
                    end ;
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['+'])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 11 : Chercher <<  }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, '<<') ;

            if liIndexItem <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((liIndexItem + 1) < aoArguments.Count) and (liIndexItem <> 0)
                then begin
                    lsTmp1 := GetString(aoArguments[liIndexItem + 1]) ;
                    lsTmp2 := GetString(aoArguments[liIndexItem - 1]) ;

                    if isNumeric(lsTmp1) and isNumeric(lsTmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        liEntier := MyStrToInt(lsTmp2) shr MyStrToInt(lsTmp1) ;
                        aoArguments[liIndexItem] := IntToStr(liEntier) ;
                        aoArguments.Delete(liIndexItem - 1);
                        { x-1 : ^
                          x  : value
                        }
                        aoArguments.Delete(liIndexItem);
                    end
                    else begin
                        ErrorMsg(Format(csNoOnString, ['<<'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['<<'])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 12 : Chercher >>  }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, '>>') ;

            if liIndexItem <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((liIndexItem + 1) < aoArguments.Count) and (liIndexItem <> 0)
                then begin
                    lsTmp1 := GetString(aoArguments[liIndexItem + 1]) ;
                    lsTmp2 := GetString(aoArguments[liIndexItem - 1]) ;

                    if isNumeric(lsTmp1) and isNumeric(lsTmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        liEntier := MyStrToInt(lsTmp2) shl MyStrToInt(lsTmp1) ;
                        aoArguments[liIndexItem] := IntToStr(liEntier) ;
                        aoArguments.Delete(liIndexItem - 1);
                        { x-1 : ^
                          x  : value
                        }
                        aoArguments.Delete(liIndexItem);
                    end
                    else begin
                        ErrorMsg(Format(csNoOnString, ['>>'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['>>'])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 13 : Chercher &  }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, '&') ;

            if liIndexItem <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((liIndexItem + 1) < aoArguments.Count) and (liIndexItem <> 0)
                then begin
                    lsTmp1 := GetString(aoArguments[liIndexItem + 1]) ;
                    lsTmp2 := GetString(aoArguments[liIndexItem - 1]) ;

                    if isNumeric(lsTmp1) and isNumeric(lsTmp2)
                    then begin
                        { x-1  : value
                          x   : &
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        liEntier := MyStrToInt(lsTmp2) and MyStrToInt(lsTmp1) ;
                        aoArguments[liIndexItem] := IntToStr(liEntier) ;
                        aoArguments.Delete(liIndexItem - 1);
                        { x-1 : ^
                          x  : value
                        }
                        aoArguments.Delete(liIndexItem);
                    end
                    else begin
                        ErrorMsg(Format(csNoOnString, ['&'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['&'])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 14 : Chercher &|  }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, '&|') ;

            if liIndexItem <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((liIndexItem + 1) < aoArguments.Count) and (liIndexItem <> 0)
                then begin
                    lsTmp1 := GetString(aoArguments[liIndexItem + 1]) ;
                    lsTmp2 := GetString(aoArguments[liIndexItem - 1]) ;

                    if isNumeric(lsTmp1) and isNumeric(lsTmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        liEntier := MyStrToInt(lsTmp2) xor MyStrToInt(lsTmp1) ;
                        aoArguments[liIndexItem] := IntToStr(liEntier) ;
                        aoArguments.Delete(liIndexItem - 1);
                        { x-1 : ^
                          x  : value
                        }
                        aoArguments.Delete(liIndexItem);
                    end
                    else begin
                        ErrorMsg(Format(csNoOnString, ['&|'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['&|'])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 15 : Chercher |  }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, '|') ;

            if liIndexItem <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((liIndexItem + 1) < aoArguments.Count) and (liIndexItem <> 0)
                then begin
                    lsTmp1 := GetString(aoArguments[liIndexItem + 1]) ;
                    lsTmp2 := GetString(aoArguments[liIndexItem - 1]) ;

                    if isNumeric(lsTmp1) and isNumeric(lsTmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        liEntier := MyStrToInt(lsTmp2) or MyStrToInt(lsTmp1) ;
                        aoArguments[liIndexItem] := IntToStr(liEntier) ;
                        aoArguments.Delete(liIndexItem - 1);
                        { x-1 : ^
                          x  : value
                        }
                        aoArguments.Delete(liIndexItem);
                    end
                    else begin
                        ErrorMsg(Format(csNoOnString, ['|'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['|'])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 16 : Chercher = }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, '=') ;

            if liIndexItem <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((liIndexItem + 1) < aoArguments.Count) and (liIndexItem <> 0)
                then begin
                    { x-1  : value
                      x   : =
                      x+2 : value
                      on remplace x par le résultat. Il faut alors supprimer
                      x et x+2}
                    lsTmp1 := GetString(aoArguments[liIndexItem + 1]) ;
                    lsTmp2 := GetString(aoArguments[liIndexItem - 1]) ;

                    if isFloat(lsTmp2) and isFloat(lsTmp1)
                    then begin
                        if (MyStrToFloat(lsTmp2) = MyStrToFloat(lsTmp1))
                        then begin
                           aoArguments[liIndexItem] := csTrueValue
                        end
                        else begin
                           aoArguments[liIndexItem] := csFalseValue ;
                        end
                    end
                    else begin
                        if (lsTmp1 = lsTmp2)
                        then begin
                           aoArguments[liIndexItem] := csTrueValue
                        end
                        else begin
                           aoArguments[liIndexItem] := csFalseValue ;
                        end ;
                    end ;

                    aoArguments.Delete(liIndexItem - 1);
                    { x-1 : ^
                      x  : value
                    }
                    aoArguments.Delete(liIndexItem);
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['='])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 17 : Chercher > }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, '>') ;

            if liIndexItem <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((liIndexItem + 1) < aoArguments.Count) and (liIndexItem <> 0)
                then begin
                    { x-1  : value
                      x   : >
                      x+2 : value
                      on remplace x par le résultat. Il faut alors supprimer
                      x et x+2}
                    lsTmp1 := GetString(aoArguments[liIndexItem + 1]) ;
                    lsTmp2 := GetString(aoArguments[liIndexItem - 1]) ;

                    if isFloat(lsTmp2) and isFloat(lsTmp1)
                    then begin
                        if (MyStrToFloat(lsTmp2) > MyStrToFloat(lsTmp1))
                        then begin
                           aoArguments[liIndexItem] := csTrueValue ;
                        end
                        else begin
                           aoArguments[liIndexItem] := csFalseValue ;
                        end ;
                    end
                    else begin
                        if (lsTmp2 > lsTmp1)
                        then begin
                           aoArguments[liIndexItem] := csTrueValue ;
                        end
                        else begin
                           aoArguments[liIndexItem] := csFalseValue ;
                        end ;
                    end ;

                    aoArguments.Delete(liIndexItem - 1);
                    { x-1 : ^
                      x  : value
                    }
                    aoArguments.Delete(liIndexItem);
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['>'])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 18 : Chercher < }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, '<') ;

            if liIndexItem <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((liIndexItem + 1) < aoArguments.Count) and (liIndexItem <> 0)
                then begin
                    { x-1  : value
                      x   : <
                      x+2 : value
                      on remplace x par le résultat. Il faut alors supprimer
                      x et x+2}
                    lsTmp1 := GetString(aoArguments[liIndexItem + 1]) ;
                    lsTmp2 := GetString(aoArguments[liIndexItem - 1]) ;

                    if isFloat(lsTmp2) and isFloat(lsTmp1)
                    then begin
                        if (MyStrToFloat(lsTmp2) < MyStrToFloat(lsTmp1))
                        then begin
                           aoArguments[liIndexItem] := csTrueValue ;
                        end
                        else begin
                           aoArguments[liIndexItem] := csFalseValue ;
                        end ;
                    end
                    else begin
                        if (lsTmp2 < lsTmp1)
                        then begin
                           aoArguments[liIndexItem] := csTrueValue ;
                        end
                        else begin
                           aoArguments[liIndexItem] := csFalseValue ;
                        end ;
                    end ;

                    aoArguments.Delete(liIndexItem - 1);
                    { x-1 : ^
                      x  : value
                    }
                    aoArguments.Delete(liIndexItem);
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['<'])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 19 : Chercher >= }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, '>=') ;

            if liIndexItem <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((liIndexItem + 1) < aoArguments.Count) and (liIndexItem <> 0)
                then begin
                    { x-1  : value
                      x   : ^
                      x+2 : value
                      on remplace x par le résultat. Il faut alors supprimer
                      x et x+2}
                    lsTmp1 := GetString(aoArguments[liIndexItem + 1]) ;
                    lsTmp2 := GetString(aoArguments[liIndexItem - 1]) ;

                    if isFloat(lsTmp2) and isFloat(lsTmp1)
                    then begin
                        if (MyStrToFloat(lsTmp2) >= MyStrToFloat(lsTmp1))
                        then begin
                           aoArguments[liIndexItem] := csTRueValue ;
                        end
                        else begin
                           aoArguments[liIndexItem] := csFalseValue ;
                        end ;
                    end
                    else begin
                        if (lsTmp2 >= lsTmp1)
                        then begin
                           aoArguments[liIndexItem] := csTrueValue ;
                        end
                        else begin
                           aoArguments[liIndexItem] := csFalseValue ;
                        end ;
                    end ;

                    aoArguments.Delete(liIndexItem - 1);
                    { x-1 : ^
                      x  : value
                    }
                    aoArguments.Delete(liIndexItem);
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['>='])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 20 : Chercher <= }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, '<=') ;

            if liIndexItem <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((liIndexItem + 1) < aoArguments.Count) and (liIndexItem <> 0)
                then begin
                    { x-1  : value
                      x   : ^
                      x+2 : value
                      on remplace x par le résultat. Il faut alors supprimer
                      x et x+2}
                    lsTmp1 := GetString(aoArguments[liIndexItem + 1]) ;
                    lsTmp2 := GetString(aoArguments[liIndexItem - 1]) ;

                    if isFloat(lsTmp2) and isFloat(lsTmp1)
                    then begin
                        if (MyStrToFloat(lsTmp2) <= MyStrToFloat(lsTmp1))
                        then begin
                           aoArguments[liIndexItem] := csTrueValue ;
                        end
                        else begin
                           aoArguments[liIndexItem] := csFalseValue ;
                        end ;
                    end
                    else begin
                        if (lsTmp2 <= lsTmp1)
                        then begin
                           aoArguments[liIndexItem] := csTrueValue ;
                        end
                        else begin
                           aoArguments[liIndexItem] := csFalseValue ;
                        end ;
                    end ;

                    aoArguments.Delete(liIndexItem - 1);
                    { x-1 : ^
                      x  : value
                    }
                    aoArguments.Delete(liIndexItem);
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['<='])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 21 : Chercher <> }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, '<>') ;
            
            if liIndexItem <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((liIndexItem + 1) < aoArguments.Count) and (liIndexItem <> 0)
                then begin
                    { x-1  : value
                      x   : ^
                      x+2 : value
                      on remplace x par le résultat. Il faut alors supprimer
                      x et x+2}
                    lsTmp1 := GetString(aoArguments[liIndexItem + 1]) ;
                    lsTmp2 := GetString(aoArguments[liIndexItem - 1]) ;

                    if isFloat(lsTmp2) and isFloat(lsTmp1)
                    then begin
                        if (MyStrToFloat(lsTmp2) <> MyStrToFloat(lsTmp1))
                        then begin
                           aoArguments[liIndexItem] := csTrueValue ;
                        end
                        else begin
                           aoArguments[liIndexItem] := csFalseValue ;
                        end ;
                    end
                    else begin
                        if (lsTmp2 <> lsTmp1)
                        then begin
                           aoArguments[liIndexItem] := csTrueValue ;
                        end
                        else begin
                           aoArguments[liIndexItem] := csFalseValue ;
                        end ;
                    end ;

                    aoArguments.Delete(liIndexItem - 1);
                    { x-1 : ^
                      x  : value
                    }
                    aoArguments.Delete(liIndexItem);
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['<>'])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 22 : Chercher and  }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, 'and') ;

            if liIndexItem <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((liIndexItem + 1) < aoArguments.Count) and (liIndexItem <> 0)
                then begin
                    lsTmp1 := GetString(aoArguments[liIndexItem + 1]) ;
                    lsTmp2 := GetString(aoArguments[liIndexItem - 1]) ;

                    if isNumeric(lsTmp1) and isNumeric(lsTmp2)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}

                        if (lsTmp1 <> csFalseValue) and (lsTmp2 <> csFalseValue)
                        then begin
                           aoArguments[liIndexItem] := csTrueValue ;
                        end
                        else begin
                           aoArguments[liIndexItem] := csFalseValue ;
                        end ;

                        aoArguments.Delete(liIndexItem - 1);
                        { x-1 : ^
                          x  : value
                        }
                        aoArguments.Delete(liIndexItem);
                    end
                    else begin
                        ErrorMsg(Format(csNoOnString, ['and'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['and'])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 23 : Chercher xor }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, 'xor') ;

            if liIndexItem <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((liIndexItem + 1) < aoArguments.Count) and (liIndexItem <> 0)
                then begin
                    lsTmp1 := GetString(aoArguments[liIndexItem + 1]) ;
                    lsTmp2 := GetString(aoArguments[liIndexItem - 1]) ;

                    if isNumeric(aoArguments[liIndexItem + 1]) and isNumeric(aoArguments[liIndexItem - 1])
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}

                        if (lsTmp2 <> csFalseValue) xor (lsTmp1 <> csFalseValue)
                        then begin
                           aoArguments[liIndexItem] := csTrueValue ;
                        end
                        else begin
                           aoArguments[liIndexItem] := csFalseValue ;
                        end ;

                        aoArguments.Delete(liIndexItem - 1);
                        { x-1 : ^
                          x  : value
                        }
                        aoArguments.Delete(liIndexItem);
                    end
                    else begin
                        ErrorMsg(Format(csNoOnString, ['xor'])) ;
                        Break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['xor'])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 24 : Chercher or }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, 'or') ;

            if liIndexItem <> -1
            then begin
                { Si ce n'est pas le dernier élément et pas le premier }
                if ((liIndexItem + 1) < aoArguments.Count) and (liIndexItem <> 0)
                then begin
                    lsTmp1 := GetString(aoArguments[liIndexItem + 1]) ;
                    lsTmp2 := GetString(aoArguments[liIndexItem - 1]) ;

                    if isNumeric(lsTmp2) and isNumeric(lsTmp1)
                    then begin
                        { x-1  : value
                          x   : ^
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}

                        if (lsTmp2 <> csFalseValue) or (lsTmp1 <> csFalseValue)
                        then begin
                           aoArguments[liIndexItem] := csTrueValue ;
                        end
                        else begin
                           aoArguments[liIndexItem] := csFalseValue ;
                        end ;

                        aoArguments.Delete(liIndexItem - 1);
                        { x-1 : ^
                          x  : value
                        }
                        aoArguments.Delete(liIndexItem);
                    end
                    else begin
                        ErrorMsg(Format(csNoOnString, ['or'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['or'])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 25 : Chercher not }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := -1 ;
        
        repeat
            Inc(liIndexItem) ;
            
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, 'not') ;

            if liIndexItem <> -1
            then begin
                { Si ce n'est pas le dernier élément }
                if (liIndexItem + 1) < aoArguments.Count
                then begin
                    lsTmp1 := GetString(aoArguments[liIndexItem + 1]) ;

                    if isNumeric(lsTmp1)
                    then begin
                        { x   : ~
                          x+1 : value

                          on remplace x par la valeur négative. Il faut alors
                          supprimer x+1 }
                        if lsTmp1 = csFalseValue
                        then begin
                            aoArguments[liIndexItem] := csFalseValue ;
                        end
                        else begin
                            aoArguments[liIndexItem] := csFalseValue ;
                        end ;

                        aoArguments.Delete(liIndexItem + 1);
                    end
                    else begin
                        ErrorMsg(Format(csNoOnString, ['not'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['not'])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 26 : Chercher . }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, '.') ;

            if liIndexItem <> -1
            then begin
                { Si ce n'est pas le dernier élément }
                if (liIndexItem + 1) < aoArguments.Count
                then begin
                        { x-1 : value
                          x   : .
                          x+1 : value
                        }
                        aoArguments[liIndexItem - 1] := GetString(aoArguments[liIndexItem - 1]) + GetString(aoArguments[liIndexItem + 1]) ;

                        aoArguments.Delete(liIndexItem);
                        aoArguments.Delete(liIndexItem);
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['.'])) ;
                    Break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 27 : Chercher ? }
    if (not gbError) and (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, '?') ;

            if liIndexItem <> -1
            then begin
                if (liIndexItem = 0) or ((liIndexItem + 1) > (aoArguments.Count - 1))
                then begin
                    ErrorMsg(csMissingargument) ;
                    break ;
                end
                else begin
                    lsTmp2 := GetString(aoArguments[liIndexItem - 1]) ;

                    if lsTmp2 = csFalseValue
                    then begin
                        Dec(liIndexItem) ;
                        { Supprime la condition }
                        aoArguments.Delete(liIndexItem) ;
                        { Supprime le ? }
                        aoArguments.Delete(liIndexItem) ;
                        { Supprime la valeur si }
                        aoArguments.Delete(liIndexItem) ;

                        if liIndexItem >= aoArguments.Count
                        then
                            aoArguments.Add('')
                        else
                            { Maintement liIndexItem pointe sur ":" normalement }
                            if aoArguments[liIndexItem] = ':'
                            then begin
                                { supprime le : }
                                aoArguments.Delete(liIndexItem) ;
                            end ;
                    end
                    else begin
                        { liIndexItem = ?, liIndexItem+1 = valeur_si_vrai, liIndexItem+2 = :}
                        for liCompteur := liIndexItem + 2 to aoArguments.Count - 1 do
                        begin
                            if aoArguments[liCompteur] = ':'
                            then begin
                                if liCompteur < aoArguments.Count
                                then
                                    aoArguments.Delete(liCompteur) ;

                                aoArguments.Delete(liCompteur) ;

                                break ;
                            end ;
                        end ;

                        { Supprime la valeur de teste }
                        aoArguments.Delete(liIndexItem - 1) ;
                        { Supprime le ? }
                        aoArguments.Delete(liIndexItem - 1) ;
                    end ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

EndOfGetValueOfStrings :
    Result := aoArguments.Count ;

    for liCompteur := 0 to aoArguments.Count - 1 do
    begin
        aoArguments[liCompteur] := GetString(aoArguments[liCompteur]) ;
    end ;

    loArgumentsAvecParentheses.Free ;
end ;

{*****************************************************************************
 * IsNumeric
 * MARTINEAU Emeric
 *
 * Fonction qui indique si la valeur est un nombre (entier, flottant, hexadecimal)
 *
 * Paramètres d'entrée :
 *   - asNombre : chaine représentant le nombre
 *
 * Retour : true si c'est un nombre
 *****************************************************************************}
function IsNumeric(asNombre : string) : boolean ;
var
    { Compteur de boucle du nombre }
    liIndex : Integer ;
    { Position de démarrage du controle de nombre }
    liStart : Integer ;
    { Indique s'il s'agit d'un nombre hexadecimal }
    lbHexaNumber : Boolean ;
    { Longueur de la chaine à traiter }
    liLength : Integer ;
    point : Boolean ;
begin
    Result := True ;
    point := False ;
    lbHexaNumber := False ;

    if asNombre <> ''
    then begin
        liLength := Length(asNombre) ;

        if asNombre[1] = '-'
        then begin
            liStart := 2 ;
        end
        else begin
            liStart := 1 ;
        end ;

        if liLength > 2
        then begin
            { Est un nombre hexadécimmal ? }
            if (asNombre[1] = '0') and (LowerCase(asNombre[2]) = 'x')
            then begin
                liStart := liStart + 2 ;
                lbHexaNumber := True ;
            end ;
        end ;

        liIndex := liStart ;

        while liIndex <= liLength do
        begin
            if (asNombre[liIndex] = '.') and (Point = False)
            then begin
                Point := True ;
                Inc(liIndex) ;
            end ;

            if not (asNombre[liIndex] in ['0'..'9'])
            then begin
                if lbHexaNumber
                then begin
                    if not ( (asNombre[liIndex] in ['a'..'f']) or
                     (asNombre[liIndex] in ['A'..'F']) )
                    then begin
                        Result := False ;
                        break ;
                    end ;
                end
                else begin
                    Result := False ;
                    break ;
                end ;
            end ;

            Inc(liIndex) ;
        end ;
    end
    else begin
        Result := False ;
    end ;
end ;

{*****************************************************************************
 * Caree
 * MARTINEAU Emeric
 *
 * Fonction qui donne la valeur exposant
 *
 * Paramètres d'entrée :
 *   aeValue    : nombre à exposer
 *   aiExposant : exposant
 *
 * Retour : valeur du nombre à la puissance exposant
 *****************************************************************************}
function caree(aeValue : Extended; aiExposant : integer) : Extended;
var
    { Valeur avant division }
    leValueBefore :Extended;
    { Compteur de boucle pour l'exposant }
    liExposantCount : Integer ;
begin
    if (aiExposant >= 0)
    then begin
        Result := 1 ;

        for liExposantCount := 1 to aiExposant do
        begin
            Result := Result * aeValue ;
        end ;

        if aiExposant = 0
        then begin
            Result := 1 ;
        end ;
    end
    else begin
        aiExposant := -1 * aiExposant ;

        leValueBefore := caree(aeValue, aiExposant) ;
        
        Result := 1 / leValueBefore ;
    end ;
end ;

{*****************************************************************************
 * DelVar
 * MARTINEAU Emeric
 *
 * Supprime la variable
 *
 * Paramètres d'entrée :
 *   - asVariable : nom de la variable à supprimer (avec $)
 *
 *****************************************************************************}
procedure DelVar(asVariable : string) ;
var
    { Variable temporaire recevant le nom de la variable }
    lsTmpVarName : string ;
    { Longueur du nom de la variable }
    liLength : Integer ;
    { Indique s'il s'agit d'un pointeur }
    lbIsPointer : boolean ;
    { Contient la partie tableau du nom de la variable }
    lsTab : String ;
    { Valeur de la partie tableau }
    loValueOfTab : TStringList ;
    { Position de démarrage de la partie tableau du nom de la variable }
    liStartTab : Integer ;
    { Compteur de boucle pour reconstitution de la partie tableau du nom
      de la variable }
    liIndexTab : Integer ;
begin
    liLength := Length(asVariable) ;
    lbIspointer := False ;

    if liLength > 1
    then begin
        if Length(asVariable) > 2
        then begin
            if asVariable[1] = '*'
            then begin
                { Pointer de variable }
                asVariable := copy(asVariable, 2, Length(asVariable) - 1) ;
                lbIsPointer := True ;
            end ;
        end ;

        lsTmpVarName := asVariable ;

        { On peut avoir un $$x }
        if asVariable[2] = '$'
        then begin
            if liLength > 2
            then begin
                { La variable est du type $$x }
                lsTmpVarName := copy(asVariable, 2, liLength - 1) ;

                lsTmpVarName := goVariables.Give(lsTmpVarName) ;

                { On vérifie que dans la variable il y ait le $ au début }
                if Length(lsTmpVarName) > 0
                then begin
                    if lsTmpVarName[1] <> '$'
                    then begin
                        lsTmpVarName := '$' + lsTmpVarName ;
                    end ;

                    if not CheckVarName(2, lsTmpVarName)
                    then begin
                        ErrorMsg(Format(csNotAVariable, [lsTmpVarName])) ;
                    end ;
                end ;

            end
            else begin
                ErrorMsg(csInvalidVarName) ;
            end ;
        end ;

        asVariable := lsTmpVarName ;

        liStartTab := pos('[', asVariable) ;

        if liStartTab > 0
        then begin
            lsTmpVarName := copy(asVariable, 1, liStartTab - 1) ;
            lsTab := copy(asVariable, liStartTab, length(asVariable) - liStartTab + 1) ;

            loValueOfTab := TStringList.Create ;

            { Eclate tout les tableaux }
            ExplodeStrings(lsTab, loValueOfTab) ;

            { Convertit les valeurs }
            GetValueOfStrings(loValueOfTab) ;

            { Vérifie que pour chaque élément on ait bien un nombre entier}
            for liIndexTab := 0 to loValueOfTab.Count - 1 do
            begin
                if (loValueOfTab[liIndexTab] <> '[') and (loValueOfTab[liIndexTab] <> ']')
                then begin
                    if MyStrToInt(loValueOfTab[liIndexTab]) < 0
                    then begin
                        ErrorMsg(csInvalidIndex) ;
                        Break ;
                    end ;
                end ;
            end ;

            if (not gbError) and (not gbQuit)
            then begin
                lsTab := '' ;

                for liIndexTab := 0 to loValueOfTab.Count - 1 do
                begin
                    lsTab := lsTab + loValueOfTab[liIndexTab] ;
                end ;
            end ;

            loValueOfTab.Free ;

            asVariable := lsTmpVarName ;
        end
        else begin
            lsTab := '' ;
        end ;

        if (not gbError) and (not gbQuit)
        then begin
            if lbIsPointer
            then begin
                unSetReference(asVariable + lsTab) ;
            end
            else begin
                goVariables.Delete(asVariable + lsTab) ;
            end ;
        end ;
    end
    else begin
        ErrorMsg(csInvalidVarName) ;
    end ;
end ;

{*****************************************************************************
 * IsSetVar
 * MARTINEAU Emeric
 *
 * Indique si la variable existe
 *
 * Paramètres d'entrée :
 *   - asVariable : nom de la variable (avec $)
 *
 * Retour : true ou false
 *****************************************************************************}
function isSetVar(asVariable : string) : boolean ;
var
    { Variable temporaire recevant le nom de la variable }
    lsTmpVarName : string ;
    { Longueur du nom de la variable }
    liLength : Integer ;
    { Indique s'il s'agit d'un pointeur }
    lbIsPointer : boolean ;
    { Contient la partie tableau du nom de la variable }
    lsTab : String ;
    { Valeur de la partie tableau }
    loValueOfTab : TStringList ;
    { Position de démarrage de la partie tableau du nom de la variable }
    liStartTab : Integer ;
    { Compteur de boucle pour reconstitution de la partie tableau du nom
      de la variable }
    liIndexTab : Integer ;
begin
    liLength := Length(asVariable) ;
    Result := False ;
    lbIsPointer := False ;

    if liLength > 1
    then begin
        if Length(asVariable) > 2
        then begin
            if asVariable[1] = '*'
            then begin
                { Pointer de variable }
                asVariable := copy(asVariable, 2, Length(asVariable) - 1) ;
                lbIsPointer := True ;
            end ;
        end ;

        lsTmpVarName := asVariable ;

        { On peut avoir un $$x }
        if asVariable[2] = '$'
        then begin
            if liLength > 2
            then begin
                { La variable est du type $$x }
                lsTmpVarName := copy(asVariable, 2, liLength - 1) ;

                lsTmpVarName := goVariables.Give(lsTmpVarName) ;

                { On peut ne pas avoir de $ pour le nom de variable }
                if lsTmpVarName[1] <> '$'
                then begin
                    lsTmpVarName := '$' + lsTmpVarName ;
                end ;

            end
            else begin
                ErrorMsg(csInvalidVarName) ;
            end ;
        end ;

        asVariable := lsTmpVarName ;

        liStartTab := pos('[', asVariable) ;

        if liStartTab > 0
        then begin
            lsTmpVarName := copy(asVariable, 1, liStartTab - 1) ;
            lsTab := copy(asVariable, liStartTab, length(asVariable) - liStartTab + 1) ;

            loValueOfTab := TStringList.Create ;

            { Eclate tout les tableaux }
            ExplodeStrings(lsTab, loValueOfTab) ;

            { Convertit les valeurs }
            GetValueOfStrings(loValueOfTab) ;

            { Vérifie que pour chaque élément on ait bien un nombre entier}
            for liIndexTab := 0 to loValueOfTab.Count - 1 do
            begin
                if (loValueOfTab[liIndexTab] <> '[') and (loValueOfTab[liIndexTab] <> ']')
                then begin
                    if MyStrToInt(loValueOfTab[liIndexTab]) < 0
                    then begin
                        ErrorMsg(csInvalidIndex) ;
                        Break ;
                    end ;
                end ;
            end ;

            if (not gbError) and (not gbQuit)
            then begin
                lsTab := '' ;

                for liIndexTab := 0 to loValueOfTab.Count - 1 do
                begin
                    lsTab := lsTab + loValueOfTab[liIndexTab] ;
                end ;
            end ;

            loValueOfTab.Free ;

            asVariable := lsTmpVarName ;
        end
        else begin
            lsTab := '' ;
        end ;

        if (not gbError) and (not gbQuit)
        then begin
            if lbIsPointer
            then begin
                Result := isSetReference(asVariable + lsTab) ;
            end
            else begin
                Result := goVariables.isSet(asVariable + lsTab) ;
            end ;
        end ;
    end
    else begin
        ErrorMsg(csInvalidVarName) ;
    end ;
end ;

{*****************************************************************************
 * MyStrToInt
 * MARTINEAU Emeric
 *
 * Convertit une chaine en entier
 *
 * Paramètres d'entrée :
 *   - asNombre : chaine a convertir
 *
 * Retour : valeur correspondante au texte
 *****************************************************************************}
function MyStrToInt(asNumber : string) : LongInt ;
var
    { Compteur de boucle du nombre }
    liIndexNumber : Integer ;
    { Position de départ du nombre }
    liStartNumber : Integer ;
    { Longueur du nombre }
    liLength : Integer ;
    { Indique si le chiffre est un nombre hexa décimal }
    lbHexa : boolean ;
    { Indice du chiffre en cours. Sert à multiplier le chiffre par la base }
    liIndice : Integer ;
    { Base du nombre : 10 ou 16 }
    liBase : Integer ;
    { Signe du nombre }
    liSigne : SmallInt ;
    { Chiffre en cours }
    liChiffre : SmallInt ;

    function convNumber(acCaractere : char) : SmallInt ;
    begin
        if acCaractere = '0'
        then begin
            Result := 0 ;
        end
        else if acCaractere = '1'
        then begin
            Result := 1 ;
        end
        else if acCaractere = '2'
        then begin
            Result := 2 ;
        end
        else if acCaractere = '3'
        then begin
            Result := 3 ;
        end
        else if acCaractere = '4'
        then begin
            Result := 4 ;
        end
        else if acCaractere = '5'
        then begin
            Result := 5 ;
        end
        else if acCaractere = '6'
        then begin
            Result := 6 ;
        end 
        else if acCaractere = '7'
        then begin
            Result := 7 ;
        end
        else if acCaractere = '8'
        then begin
            Result := 8 ;
        end
        else if acCaractere = '9'
        then begin
            Result := 9 ;
        end
        else begin
            Result := -1 ;
        end ;
    end ;

    function convHexa(acCaractere : char) : SmallInt ;
    begin
        if acCaractere = 'a'
        then begin
            Result := 10 ;
        end
        else if acCaractere = 'b'
        then begin
            Result := 11 ;
        end
        else if acCaractere = 'c'
        then begin
            Result := 12 ;
        end
        else if acCaractere = 'd'
        then begin
            Result := 13 ;
        end
        else if acCaractere = 'e'
        then begin
            Result := 14 ;
        end
        else if acCaractere = 'f'
        then begin
            Result := 15 ;
        end 
        else begin
            Result := -1 ;
        end ;
    end ;
begin
    Result := 0 ;

    try
        lbHexa := False ;
        
        if asNumber <> ''
        then begin
            asNumber := LowerCase(asNumber) ;

            if asNumber <> ''
            then begin
                liLength := Length(asNumber) ;
                liIndice := 0 ;
                liSigne := 1 ;

                if asNumber[1] = '-'
                then begin
                    liStartNumber := 2;
                    liSigne := -1 ;
                end
                else begin
                    liStartNumber := 1 ;
                end ;

                if liLength > 2
                then begin
                    { Est un nombre hexadécimmal ? }
                    if (asNumber[1] = '0') and (LowerCase(asNumber[2]) = 'x')
                    then begin
                        lbHexa := true ;
                        liStartNumber := liStartNumber + 2 ;
                    end
                    else begin
                        lbHexa := False ;
                    end ;
                end ;

                if lbHexa
                then begin
                    liBase := 16 ;
                end
                else begin
                    liBase := 10 ;
                end ;

                for liIndexNumber := liLength downto liStartNumber do
                begin
                    liChiffre := -1 ;

                    if asNumber[liIndexNumber] in ['0'..'9']
                    then begin
                        liChiffre := convNumber(Char(asNumber[liIndexNumber])) ;
                    end
                    else begin
                        if lbHexa
                        then begin
                            if asNumber[liIndexNumber] in ['a'..'f']
                            then begin
                                liChiffre := convHexa(Char(asNumber[liIndexNumber])) ;
                            end ;
                        end ;
                    end ;

                    if liChiffre <> -1
                    then begin
                        { On a le chiffre (ex : 9) mais il faut le multiplier par la base
                          (16, 10) pour avoir la bonne valeur }
                        Result := Result + liChiffre * FloatToInt(caree(liBase, liIndice)) ;
                    end
                    else if lbHexa
                    then begin
                        ErrorMsg(Format(csNoHexa, [asNumber])) ;
                        break ;
                    end
                    else begin
                        ErrorMsg(Format(csNoNumber, [asNumber])) ;
                        break ;
                    end ;

                    Inc(liIndice) ;
                end ;

                Result := liSigne * Result ;
            end ;
        end ;
    except
        on EConvertError do ErrorMsg(Format(csNumberToBig, [asNumber])) ;
    end ;
end ;

{*****************************************************************************
 * GetPointeurOfVariable
 * MARTINEAU Emeric
 *
 * Retourne la partie pointer sur la variable Variables d'une variable pointer
 *
 * Paramètres d'entrée :
 *   - asPointer : pointer de variable xxxx$yyyyy
 *
 * Retour : partie pointeur
 *****************************************************************************}
function GetPointeurOfVariable(asPointer : string) : string ;
var
    { Compteur de boucle }
    liIndex : Integer ;
begin
    Result := '' ;

    if Length(asPointer) > 1
    then begin
        for liIndex := 3 to Length(asPointer) do
        begin
            if asPointer[liIndex] = '$'
            then begin
                break ;
            end
            else begin
                Result := Result + asPointer[liIndex] ;
            end ;
        end ;
    end
    else begin
        Result := '' ;
    end ;
end ;

{*****************************************************************************
 * etVarNameOfVariable
 * MARTINEAU Emeric
 *
 * Retourne la partie pointer sur la variable Variables d'une variable pointer
 *
 * Paramètres d'entrée :
 *   - asPointer : pointer de variable xxxx$yyyyy
 *
 * Retour : partie variable
 *****************************************************************************}
function GetVarNameOfVariable(asPointer : string) : string;
var
    { Position du dollard }
    liPositionOfDollard : Integer ;
    { Compteur de boucle }
    liIndex : integer ;
begin
    liPositionOfDollard := pos('$', asPointer);
    Result := '' ;

    if liPositionOfDollard > 0
    then begin
        for liIndex := liPositionOfDollard to Length(asPointer) - 1 do
        begin
            Result := Result + asPointer[liIndex] ;
        end ;
    end ;
end ;

{*****************************************************************************
 * GetReference
 * MARTINEAU Emeric
 *
 * Retourne le valeur d'une variable en fonction de son pointer
 *
 * Paramètres d'entrée :
 *   - asVarNamePointed : variable contenant le pointer de variable qu'il faut
 *                        lire.
 *
 * Retour : pointer de variable
 *****************************************************************************}
function GetReference(asVarNamePointed : string) : string;
var
    { Pointer de la structure TVariable }
    lsPointerOfVar : String ;
    { Nom de la variable }
    lsVarName : String ;
    { Position des crochets }
    liStartTab : Integer ;
    { Variable temporaire }
    lsTmp : String ;
    { Partie de la variable avec les crochets }
    lsTab : String ;
    { Structure contenant la variable }
    loPointedVariable : TVariables ;
begin
    liStartTab := pos('[', asVarNamePointed) ;

    if liStartTab > 0
    then begin
        lsTmp := copy(asVarNamePointed, 1, liStartTab - 1) ;
        lsTab := copy(asVarNamePointed, liStartTab, Length(asVarNamePointed) - liStartTab + 1) ;

        asVarNamePointed := lsTmp ;
    end
    else begin
        lsTab := '' ;
    end ;

    { On récupère la valeur de la variable pour la traiter }
    asVarNamePointed := goVariables.Give(asVarNamePointed) ;
    lsPointerOfVar := GetPointeurOfVariable(asVarNamePointed) ;
    lsVarName := GetVarNameOfVariable(asVarNamePointed) ;
    Result := '' ;

    if (lsPointerOfVar <> '') and (lsVarName <> '')
    then begin
        loPointedVariable := goPointerOfVariables.Give(lsPointerOfVar) ;

        if loPointedVariable <> nil
        then begin
            Result := loPointedVariable.Give(lsVarName + lsTab) ;
        end
        else begin
            Result := '' ;
        end ;
    end
    else begin
        ErrorMsg(csNotValidPointer) ;
    end ;
end ;

{*****************************************************************************
 * SetReference
 * MARTINEAU Emeric
 *
 * Donne une valeur suivant un variable pointer
 *
 * Paramètres d'entrée :
 *   - asVarNamePointed : variable contenant le pointer de variable qu'il faut
 *                        écrire.
 *   - asValue : valeur à donner
 *
 *****************************************************************************}
procedure SetReference(asVarNamePointed : string; asValue : string) ;
var
    { Partie pointer sur TVariable }
    lsPointerOfVar : string ;
    { Partie nom de variable }
    lsVarName : String ;
    { Position des crochets }
    liStartTab : Integer ;
    { Variabel temporaire }
    lsTmp : String ;
    { Partie entre crochet }
    lsTab : String ;
    { Pointer sur TVariable }
    loPointedVariable : TVariables ;
begin
    liStartTab := pos('[', asVarNamePointed) ;

    if liStartTab > 0
    then begin
        lsTmp := copy(asVarNamePointed, 1, liStartTab - 1) ;
        lsTab := copy(asVarNamePointed, liStartTab, Length(asVarNamePointed) - liStartTab + 1) ;

        asVarNamePointed := lsTmp ;
    end
    else begin
        lsTab := '' ;
    end ;

    { On récupère la valeur de la variable pour la traiter }
    if goVariables.isArray(asVarNamePointed)
    then begin
        asVarNamePointed := goVariables.Give(asVarNamePointed + lsTab) ;
    end
    else begin
        asVarNamePointed := goVariables.Give(asVarNamePointed) ;
    end ;
        
    lsPointerOfVar := getPointeurOfVariable(asVarNamePointed) ;
    lsVarName := getVarNameOfVariable(asVarNamePointed) ;

    if (lsPointerOfVar <> '') and (lsVarName <> '')
    then begin
        loPointedVariable := goPointerOfVariables.Give(lsPointerOfVar) ;

        if loPointedVariable <> nil
        then begin
            loPointedVariable.Add(lsVarName + lsTab, asValue) ;
        end ;
    end
    else begin
        ErrorMsg(csNotValidPointer) ;
    end ;
end ;

{*****************************************************************************
 * UnSetReference
 * MARTINEAU Emeric
 *
 * Supprime une variable pointée
 *
 * Paramètres d'entrée :
 *   - asVarNamePointed : variable contenant le pointer de variable qu'il faut
 *                        écrire.
 *
 *****************************************************************************}
procedure UnSetReference(asVarNamePointed : string) ;
var
    { Partie pointeur de TVariable }
    lsPointerOfVar : String ;
    { Partie variable du pointer }
    lsVarName : String ;
    { Variable temporaire }
    lsTmp : String ;
    { Partie tableau de la variable }
    lsTab : String ;
    { Position de début des crochets }
    liStartTab : Integer ;
    { TVariable contenant la variable }
    loPointedVariable : TVariables ;
begin
    liStartTab := pos('[', asVarNamePointed) ;

    if liStartTab > 0
    then begin
        lsTmp := copy(asVarNamePointed, 1, liStartTab - 1) ;
        lsTab := copy(asVarNamePointed, liStartTab, Length(asVarNamePointed) - liStartTab + 1) ;

        asVarNamePointed := lsTmp ;
    end
    else begin
        lsTab := '' ;
    end ;
    
    { On récupère la valeur de la variable pour la traiter }
    asVarNamePointed := goVariables.Give(asVarNamePointed) ;
    lsPointerOfVar := getPointeurOfVariable(asVarNamePointed) ;
    lsVarName := getVarNameOfVariable(asVarNamePointed) ;

    if (lsPointerOfVar <> '') and (lsVarName <> '')
    then begin
        loPointedVariable := goPointerOfVariables.Give(lsPointerOfVar) ;

        if loPointedVariable <> nil
        then begin
            loPointedVariable.Delete(lsVarName + lsTab) ;
        end ;
    end
    else begin
        ErrorMsg(csNotValidPointer) ;
    end ;
end ;

{*****************************************************************************
 * IsSetReference
 * MARTINEAU Emeric
 *
 * Indique si une variable pointée existe (et donc un pointer est valide)
 *
 * Paramètres d'entrée :
 *   - asVarNamePointed : variable contenant le pointer de variable qu'il faut
 *                        écrire.
 *
 *****************************************************************************}
function isSetReference(asVarNamePointed : string) : Boolean ;
var
    { Partie pointeur de TVariable }
    lsPointerOfVar : String ;
    { Partie variable du pointer }
    lsVarName : String ;
    { Variable temporaire }
    lsTmp : String ;
    { Partie tableau de la variable }
    lsTab : String ;
    { Position de début des crochets }
    liStartTab : Integer ;
    { TVariable contenant la variable }
    loPointedVariable : TVariables ;
begin
    liStartTab := pos('[', asVarNamePointed) ;

    if liStartTab > 0
    then begin
        lsTmp := copy(asVarNamePointed, 1, liStartTab - 1) ;
        lsTab := copy(asVarNamePointed, liStartTab, Length(asVarNamePointed) - liStartTab + 1) ;

        asVarNamePointed := lsTmp ;
    end
    else begin
        lsTab := '' ;
    end ;
    
    { On récupère la valeur de la variable pour la traiter }
    asVarNamePointed := goVariables.Give(asVarNamePointed) ;
    lsPointerOfVar := getPointeurOfVariable(asVarNamePointed) ;
    lsVarName := getVarNameOfVariable(asVarNamePointed) ;
    Result := False ;

    if (lsPointerOfVar <> '') and (lsVarName <> '')
    then begin
        loPointedVariable := goPointerOfVariables.Give(lsPointerOfVar) ;

        if loPointedVariable <> nil
        then begin
            Result := loPointedVariable.isSet(lsVarName + lsTab) ;
        end 
        else begin
            Result := False ;
        end ;
    end
    else begin
        ErrorMsg(csNotValidPointer) ;
    end ;
end ;

{*****************************************************************************
 * IsFloat
 * MARTINEAU Emeric
 *
 * Indique s'il s'agit d'un floattant
 *
 * Paramètres d'entrée :
 *   - asNumber : nombre sous forme de chaine
 *
 * Retrour : true s'il s'agit d'un floattant ou integer (mais pas sous forme
 *           hexa-décimal)
 *****************************************************************************}
function isFloat(asNumber : String) : Boolean ;
var
    { Boucle de compteur }
    liIndex : Integer ;
    { Position de départ du nombre }
    liStart : Integer ;
    { Taille de la chaine à analyser }
    liLength : Integer ;
    { Indique si le point à été trouvé. Evite d'avoir deux fois un point }
    lbPoint : Boolean ;
begin
    Result := True ;
    lbPoint := False ;

    if asNumber <> ''
    then begin
        liLength := Length(asNumber) ;

        if asNumber[1] = '-'
        then begin
            liStart := 2 ;
        end
        else begin
            liStart := 1 ;
        end ;

        for liIndex := liStart to liLength do
        begin
            if not (asNumber[liIndex] in ['0'..'9'])
            then begin
                if (asNumber[liIndex] = '.') and (lbPoint = False)
                then begin
                    lbPoint := True ;
                end
                else begin
                    Result := False ;
                    break ;
                end ;
            end ;
        end ;
    end
    else begin
        Result := False ;
    end ;
end ;

{*****************************************************************************
 * MyStrToFloat
 * MARTINEAU Emeric
 *
 * Convertie une chaine de caractère en float
 *
 * Paramètres d'entrée :
 *   - asNumber : nombre sous forme de chaine
 *
 * Retrour : nombre floattant
 *****************************************************************************}
function MyStrToFloat(asNumber : string) : Extended ;
begin
    Result := 0 ;

    try
        DecimalSeparator := '.' ;
        
        Result := StrToFloat(asNumber) ;
    except
        on EConvertError do ErrorMsg(Format(csNumberToBig, [asNumber])) ;
    end ;
end ;

{*****************************************************************************
 * MyFloatToStr
 * MARTINEAU Emeric
 *
 * Convertie un floattant en chaine
 *
 * Paramètres d'entrée :
 *   - aeNumber : nombre sous forme de chaine
 *
 * Retrour : nombre floattant sous forme de chaine
 *****************************************************************************}
function MyFloatToStr(aeNumber : Extended) : string ;
begin
    DecimalSeparator := '.' ;
    Result := FloatToStr(aeNumber) ;
end ;

{*****************************************************************************
 * IsInteger
 * MARTINEAU Emeric
 *
 * Indique si la chaine passée en paramètre est un entier
 *
 * Paramètres d'entrée :
 *   - asNumber : nombre sous forme de chaine
 *
 * Retrour : true ou false
 *****************************************************************************}
function isInteger(asNumber : string) : boolean ;
var
    { Compteur de boucle }
    liIndex : Integer ;
    { Début à analyser }
    liStart : Integer ;
    { Taille de la chaine }
    liLength : Integer ;
begin
    if asNumber <> ''
    then begin
        liLength := Length(asNumber) ;

        if asNumber[1] = '-'
        then begin
            liStart := 2 ;
        end 
        else begin
            liStart := 1 ;
        end ;

        Result := isHexa(asNumber) ;

        if not Result
        then begin
            Result := True ;
            
            for liIndex := liStart to liLength do
            begin
                if not ( (asNumber[liIndex] in ['0'..'9']) )
                then begin
                    Result := False ;
                    break ;
                end ;
            end ;
        end ;
    end
    else begin
        Result := False ;
    end ;
end ;

{*****************************************************************************
 * FloatToInt
 * MARTINEAU Emeric
 *
 * Converti un floattant en entier
 *
 * Paramètres d'entrée :
 *   - aeNumber : nombre sous forme de chaine
 *
 * Retrour : true ou false
 *****************************************************************************}
function FloatToInt(aeNumber : extended) : LongInt ;
begin
    Result := 0 ;

    try
        Result := Trunc(aeNumber) ;
    except
        on EinvalidOp do ErrorMsg(Format(csNumberToBig, [aeNumber])) ;
    end ;
end ;

{*****************************************************************************
 * LoadCode
 * MARTINEAU Emeric
 *
 * Charge un fichier de code en supprimant les lignes commentées
 *
 * Paramètres d'entrée :
 *   - asFileName : nom du fichier à charger,
 *   - aiStartLine : numéro de ligne de départ dans goCodeList
 *
 * Retrour : true si le fichier est chargé
 *****************************************************************************}
function LoadCode(asFileName : String; aiStartLine : Integer) : boolean ;
Var
    { TStringList recevant le code du fichier à lire }
    loTmpCode : TStringList ;
    { Compteur de boucle de loTmpCode }
    liIndexTmpCode : integer ;
    { Numéro du fichier dans goLineToFile }
    liNumFile : Integer ;
    { Valeur de décalage par rapport à l'offset dans le fichier lors de l'ajout
      d'une ligne }
    liIncOfOffset : Integer ;
    { Variable temporaire pour extraire le code entre balise <@ et @>}
    lsTmp : String ;
    { Position des balises <@ ou @> }
    liPositionOfTag : Integer ;
    { Indique si on est dans du HTML ou dans du code }
    lbInHTML : Boolean ;
    { Indique qu'il n'y a plus de balise code <@ @> }
    lbWorkInLineIsEnd : Boolean ;
    { Index de chaine pour savoir ou est la balise @> ou // /* }
    liIndexBalise : Integer ;
    { Ligne courante }
    lsCurrentLine : String ;
    { Caractère ouvrant une chaine }
    lcOpenString : Char ;
    { Longueur de la ligne courante }
    liLengthCurrentLine : Integer ;
    { Indique si on est dans un commentaire multi ligne }
    lbInMultiLineComment : boolean ;
    { Position de la fin de commentarie multi ligne }
    liEndOfMultiLineComment : Integer ;
    { Operateur de commande }
    lsCommande : String ;
    { Fin de ligne }
    lsEndOfLine : String ;
    { Ligne d'avant }
    lsBeforeLine : String ;
    { Position de départ de la ligne }
    liStartLineNumber : Integer ;
    { Fin de ligne à trouver }
    lsEndOfLineToFound : String ;

    procedure add(asText : String) ;
    var
        lsMulTiLine : String ;
    begin
        if (asText <> '') or (lbInHTML)
        then begin
            goCodeList.Insert(aiStartLine + liIncOfOffset, asText) ;
            goLineToFile.Insert(aiStartLine + liIncOfOffset, IntToStr(liNumFile)) ;
            
            if (liStartLineNumber = -1)
            then begin
                goLineToFileLine.Insert(aiStartLine + liIncOfOffset, IntToStr(liIndexTmpCode + 1)) ;
            end
            else begin
                lsMulTiLine := csLineToLine ;
                ReplaceOneOccurence('%line1', lsMulTiLine, IntToStr(liStartLineNumber + 1) , false) ;
                ReplaceOneOccurence('%line2', lsMulTiLine, IntToStr(liIndexTmpCode + 1) , false) ;
                goLineToFileLine.Insert(aiStartLine + liIncOfOffset, lsMulTiLine) ;
            end ;
            
            Inc(liIncOfOffset) ;
        end ;
    end ;
begin
    Result := False ;
    asFileName := Realpath(asFilename) ;
    lbInMultiLineComment := false ;
    lsBeforeLine := '' ;
    liStartLineNumber := -1 ;

    { Vérifie l'inclusion du fichier si on est en safe mode }
    if (gbSafeMode = True) and (gsDocRoot <> '')
    then begin
        if Pos(gsDocRoot, asFileName) = 0
        then begin
            ErrorMsg(csCantDoThisInSafeMode) ;
            exit ;
        end ;
    end ;

    {$I-}
    try
        if FileExists(asFileName)
        then begin
            liNumFile := goListOfFile.Count ;

            goListOfFile.Add(asFileName) ;

            goCurrentRootOfFile.Add(OsAddFinalDirSeparator(ExtractFileDir(asFileName))) ;

            loTmpCode := TStringList.Create ;

            loTmpCode.LoadFromFile(asFileName) ;

            liIndexTmpCode := 0 ;
            liIncOfOffset := 0 ;
            lbInHTML := True ;

            while liIndexTmpCode < loTmpCode.Count do
            begin
                OverTimeAndMemory ;
                
                if gbError
                then begin
                    break ;
                end ;

                repeat
                    lbWorkInLineIsEnd := False ;
                
                    if lbInHTML
                    then begin
                        { Code HTML }
                        liPositionOfTag := pos(csStartSwsTag, loTmpCode[liIndexTmpCode]) ;

                        if liPositionOfTag <> 0
                        then begin
                            { Si <@ est en début de ligne, tmp sera égal à ''. On ajoutera
                              donc une ligne vide à tord }
                            if liPositionOfTag > 1
                            then begin
                                lsTmp := Copy(loTmpCode[liIndexTmpCode], 1, liPositionOfTag - 1) ;
                                add(lsTmp) ;
                            end ;

                            add(csStartSwsTag) ;

                            { On met à jour la ligne en cours de traitement pour continuer
                              à la traiter }
                            loTmpCode[liIndexTmpCode] := Copy(loTmpCode[liIndexTmpCode], liPositionOfTag + Length(csStartSwsTag), length(loTmpCode[liIndexTmpCode]) - (liPositionOfTag + 1) ) ;

                            lbInHTML := False ;
                        end
                        else begin
                            lbWorkInLineIsEnd := True ;
                        end ;
                    end
                    else begin
                        { Code SWS }

                        { Recherche de commentaire }
                        lsCurrentLine := loTmpCode[liIndexTmpCode] ;

                        liIndexBalise := 1 ;

                        liLengthCurrentLine := Length(lsCurrentLine) +1 ;

                        liPositionOfTag := 0 ;

                        lsCommande := ExtractCommande(lsCurrentLine) ;

                        lsEndOfLineToFound := GetEndOfLine(lsCommande) ;

                        while liIndexBalise < liLengthCurrentLine do
                        begin
                            if (lsCurrentLine[liIndexBalise] = '"') or
                               (lsCurrentLine[liIndexBalise] = '''')
                            then begin
                                { On entre dans une chaine }
                                lcOpenString := lsCurrentLine[liIndexBalise] ;

                                Inc(liIndexBalise) ;

                                while liIndexBalise < liLengthCurrentLine do
                                begin
                                    if lsCurrentLine[liIndexBalise] = '\'
                                    then begin
                                        { Caractère d'échappement on ignore le caractère
                                          suivant }
                                        Inc(liIndexBalise)
                                    end
                                    else if lsCurrentLine[liIndexBalise] = lcOpenString
                                    then begin
                                        { On a atteind la fin de la chaine }
                                        break ;
                                    end ;

                                    Inc(liIndexBalise) ;
                                end ;
                            end
                            else if Copy(lsCurrentLine, liIndexBalise, Length(csMultiLineCommentStart)) = csMultiLineCommentStart
                            then begin
                                { Commentaire multi ligne }
                                lsTmp := Copy(lsCurrentLine, 1, liIndexBalise - 1) ;

                                { On recherche la fin de commentaire dans la ligne }
                                liEndOfMultiLineComment := pos(csMultiLineCommentStop, lsCurrentLine) ;

                                if liEndOfMultiLineComment <> 0
                                then begin
                                    lsCurrentLine := lsTmp + Copy(lsCurrentLine, liEndOfMultiLineComment + Length(csMultiLineCommentStart),  Length(lsCurrentLine)) ;

                                    liLengthCurrentLine := Length(lsCurrentLine) ;

                                    { Il faut décrémenté car on incrément après }
                                    Dec(liIndexBalise) ;

                                    { Si le commentaire est au début de la ligne, il faut
                                      relire la commande }
                                    if liEndOfMultiLineComment = 1
                                    then begin
                                        lsCommande := ExtractCommande(lsCurrentLine) ;

                                        lsEndOfLineToFound := GetEndOfLine(lsCommande) ;
                                    end ;
                                end
                                else begin
                                    lsCurrentLine := Copy(lsCurrentLine, 1, liIndexBalise - 1) ;

                                    lbInMultiLineComment := true ;

                                    lbWorkInLineIsEnd := True ;

                                    liPositionOfTag := 0 ;
                                    
                                    break ;
                                end ;
                            end
                            else if Copy(lsCurrentLine, liIndexBalise, Length(csSingleComment)) = csSingleComment
                            then begin
                                { Commentaire mono ligne }
                                lsCurrentLine := Copy(lsCurrentLine, 1, liIndexBalise - 1) ;
                                
                                liPositionOfTag := 0 ;
                                
                                lbWorkInLineIsEnd := True ;
                                
                                break ;
                            end
                            else if Copy(lsCurrentLine, liIndexBalise, Length(csEndSwsTag)) = csEndSwsTag
                            then begin
                                { Fin de tag SWS trouvée }
                                liPositionOfTag := liIndexBalise ;
                                break ;
                            end
                            else if Copy(lsCurrentLine, liIndexBalise, Length(lsEndOfLineToFound)) = lsEndOfLineToFound
                            then begin
                                { fin de commande trouvée }
                                { On sauvegarde la ligne car on doit la couper en deux }
                                lsTmp := lsCurrentLine ;
                                
                                lsCurrentLine := Copy(lsTmp, 1, liIndexBalise + Length(lsEndOfLineToFound)) ;
                                
                                lsTmp := Copy(lsTmp, liIndexBalise + Length(lsEndOfLineToFound), Length(lsTmp)) ;
                                
                                loTmpCode[liIndexTmpCode] := lsTmp ;
                                
                                liPositionOfTag := 0 ;

                                break ;
                            end ;

                            Inc(liIndexBalise) ;
                        end ;

                        { Si on a un fin de tag SWS }
                        if liPositionOfTag <> 0
                        then begin
                            lsTmp := Copy(lsCurrentLine, 1, liPositionOfTag - 1) ;

                            if (lsTmp <> '')
                            then begin
                                lsTmp := Trim(lsTmp) ;
                                add(lsTmp) ;
                            end ;

                            lbInHTML := True ;

                            add(csEndSwsTag) ;

                            { On met à jour la ligne en cours de traitement pour continuer
                              à la traiter }
                            loTmpCode[liIndexTmpCode] := Copy(lsCurrentLine, liPositionOfTag + Length(csEndSwsTag), length(loTmpCode[liIndexTmpCode]) - (liPositionOfTag + 1) ) ;
                            
                            { Evite d'inclure la ligne }
                            lsCurrentLine := '' ;
                        end
                        else begin
                            if lbWorkInLineIsEnd = True
                            then begin
                                { Evite d'inclure 2 fois la ligne }
                                loTmpCode[liIndexTmpCode] := '' ;
                            end ;
                        end ;

                        lsCurrentLine := Trim(lsCurrentLine) ;

                        if lsCurrentLine <> ''
                        then begin
                            { Vérifie que la ligne se termine bien par ce qui est prévu }
                            lsCommande := ExtractCommande(lsCurrentLine) ;
                            
                            lsEndOfLine := ExtractEndOperator(lsCurrentLine) ;

                            if lsEndOfLine = GetEndOfLine(lsCommande)
                            then begin
                                add(lsBeforeLine + lsCurrentLine) ;
                                
                                lsBeforeLine := '' ;
                                
                                liStartLineNumber := -1 ;
                            end
                            else if IsEndOperatorBy(lsEndOfLine)
                            then begin
                                if liStartLineNumber = -1
                                then begin
                                    liStartLineNumber := liIndexTmpCode ;
                                end ;
                                
                                lsBeforeLine := lsBeforeLine + lsCurrentLine ;
                                
                                Inc(liIndexTmpCode) ;
                            end
                            else begin
                                ErrorMsg(Format(csMissingEndOfLine, [GetEndOfLine(lsCommande)])) ;
                            end ;
                        end
                        else begin
                            { Evite d'inclure la ligne si elle est vide }
                            loTmpCode[liIndexTmpCode] := '' ;
                            { Le traitement de la ligne est fini }
                            lbWorkInLineIsEnd := True ;
                        end ;
                    end ;
                until (lbWorkInLineIsEnd = True) or (gbError = True) ;

                if gbError
                then begin
                    break ;
                end ;

                if (loTmpCode[liIndexTmpCode] <> '') or (lbInHTML)
                then begin
                    if lbInHTML
                    then begin
                        if liIndexTmpCode <> (loTmpCode.Count - 1)
                        then begin
                            loTmpCode[liIndexTmpCode] := loTmpCode[liIndexTmpCode] + #13 ;
                        end ;
                    end ;
                        
                    add(loTmpCode[liIndexTmpCode]) ;
                end ;

                Inc(liIndexTmpCode) ;
                
                { Si on est dans un commentaire multi ligne }
                if lbInMultiLineComment
                then begin
                    lbInMultiLineComment := false ;
                    
                    { On va chercher la fin du commentaire }
                    while liIndexTmpCode < loTmpCode.Count do
                    begin
                        liIndexBalise := pos(csMultiLineCommentStop, loTmpCode[liIndexTmpCode]) ;
                        
                        if liIndexBalise <> 0
                        then begin
                            lsCurrentLine := loTmpCode[liIndexTmpCode] ;
                            
                            { On recopie la ligne dans loTmpCode pour qu'elle soit de nouveau parsé }
                            lsCurrentLine := Copy(lsCurrentLine, liIndexBalise + Length(csMultiLineCommentStop), Length(lsCurrentLine)) ; ;
                            
                            loTmpCode[liIndexTmpCode] := Trim(lsCurrentLine) ;
                            
                            break ;
                        end ;
                        
                        Inc(liIndexTmpCode) ;
                    end ;
                end ;
            end ;

            loTmpCode.Free ;

            if not gbError
            then begin
                Result := True ;
            end ;
        end
        else begin
            if goListOfFile.Count > 0
            then begin
                if goLineToFileLine.Count = 0
                then begin
                    goLineToFileLine.Add('1') ;
                    goLineToFile.Add('0') ;
                end ;

                ErrorMsg(Format(csFileNotFound, [asFileName])) ;
            end
            else begin
                ErrorMsg(Format(csMainFileNotFound, [asFileName])) ;
            end ;
        end ;
    except
        on EInOutError do ErrorMsg(Format(csCantReadFile, [asFileName])) ;
    end ;
    {$I+}
end ;


{*****************************************************************************
 * Explose
 * MARTINEAU Emeric
 *
 * Fonction explose une chaine en tableau en fonction d'un séparateur
 *
 * Paramètres d'entrée :
 *   - asText : chaine à traiter
 *   - asSeparator
 *
 * Paramètre de sortie :
 *    - aoLine : Liste des éléments
 *****************************************************************************}
procedure Explode(asText : string; aoLine : TStringList; asSeparator : string) ;
var
    { Valeur de la ligne courante }
    lsCurrentLine : string ;
    { Longueur du séparateur }
    liLengthSeparator : Integer ;
    { Varaible temporaire pour comparaison avec le séparateur }
    lsTmp : String ;
    { Compteur de boucle }
    liIndex : Integer ;
begin
    aoLine.Clear ;

    lsCurrentLine := '' ;

    liLengthSeparator := Length(asSeparator) ;
    liIndex := 1 ;

    while liIndex <= Length(asText) do
    begin
        lsTmp := Copy(asText, liIndex, liLengthSeparator) ;

        if lsTmp = asSeparator
        then begin
            aoLine.Add(lsCurrentLine) ;
            lsCurrentLine := '' ;
            Inc(liIndex, liLengthSeparator) ;
        end
        else begin
            lsCurrentLine := lsCurrentLine + asText[liIndex] ;
            Inc(liIndex) ;
        end ;
    end ;

    if lsCurrentLine <> ''
    then begin
        aoLine.Add(lsCurrentLine) ;
    end ;
end ;

{*****************************************************************************
 * ExecuteUserProcedure
 * MARTINEAU Emeric
 *
 * Fonction qui exécute une fonction définit par l'utilisateur
 *
 * Paramètres d'entrée :
 *   - asCommande : nom de la fonction à exécuter
 *   - aoCurrentLine : TStringList contenant les paramètres
 *
 * Retour : -1 en cas d'erreur, sinon ligne où il faut se positionner si goto
 *****************************************************************************}
function ExecuteUserProcedure(asCommande : String; aoCurrentLine : TStringList) : integer ;
var
    { Ligne de début de la procédure }
    liLineOfProcedure : Integer ;
    { TStringList contenant les conditions de fin }
    loEndCondition : TStringList ;
    { Ligne de retour de la procédure utilisateur. -1 indique une erreur }
    liReturnLine : Integer ;
    { Index de boucle }
    liIndexGlobalVariable : Integer ;
    { Pointe sur l'ancien objet variable }
    loOldVariables : TVariables ;
    { Nom de la variable global }
    lsNameOfVar : String ;
    { Liste des arguments du prototyle de la fonction }
    loListArguments : TStringList ;
    { Position du = dans le prototype de fonction }
    liPosEqual : Integer ;
    { Position du ... dans le prototype de fonction }
    liPos3Dot : Integer ;
    { Nombre d'agument fixe }
    liNbArgFixe : Integer ;
    { Commande ayant mis fin à la fonction utilisateur }
    lsCmdEnd : String ;
    { Ancienne position de la ligne courante }
    liOldCurrentLineNumber : Integer ;
    { Ancienne variables globales si appèle de fonction utilisateur dans fonction utilisateur }
    loOldGlobalVariable : TStringList ;

    procedure setFixedParams(aoListArguments : TStringList; aoCurrentLine : TStringList) ;
    var
        { Position de fin des paramètres fixe }
        liFinFixedArgs : Integer ;
        { Compteur de boucle }
        liIndex : Integer ;
    begin
        { se place au premier paramètre optionnel }
        liFinFixedArgs := aoListArguments.IndexOf('=') - 1 ;

        if liFinFixedArgs < 0
        then begin
            { se place au premier paramètre ... }
            liFinFixedArgs := aoListArguments.IndexOf('...') ;

            if liFinFixedArgs < 0
            then begin
                liFinFixedArgs := aoCurrentLine.Count - 1 ;
            end ;
        end ;

        if liFinFixedArgs > 0
        then begin
            for liIndex := 0 to liFinFixedArgs do
            begin
                goVariables.Add(aoListArguments[liIndex], aoCurrentLine[liIndex]) ;
            end ;
        end ;
    end ;

    procedure setOptionnalParams(aoListArguments : TStringList; aoCurrentLine : TStringList) ;
    var
        { Début des paramètres optionnels }
        liDebut : Integer ;
        { Position de la variable dans les arguments }
        liPosVarInCall : Integer ;
        { Fin des paramètres optionnels }
        liFin : Integer ;
        { Compteur de boucles }
        liIndex : Integer ;
        { Valeur à affecter à la variable }
        lsVal : String ;
    begin
        { se place au premier paramètre optionnel }
        liDebut := aoListArguments.IndexOf('=') - 1 ;

        if liDebut >= 0
        then begin
            liFin := aoListArguments.IndexOf('...') - 1 ;

            if liFin < 0
            then begin
                liFin := aoListArguments.Count -1 ;
            end ;

            liIndex := liDebut ;
            liPosVarInCall := liDebut ;

            while liIndex <= liFin do
            begin
                { A-t-on 3 éléments ; $var=val }
                if liIndex + 2 < aoListArguments.Count
                then begin
                    if isVar(aoListArguments[liIndex])
                    then begin
                        if aoListArguments[liIndex + 1] = '='
                        then begin
                            lsVal := aoListArguments[liIndex + 2] ;

                            { L'élément est-il définit lors de l'appel de la fonction }
                            if liPosVarInCall < aoCurrentLine.Count
                            then begin
                                lsVal := aoCurrentLine[liPosVarInCall] ;
                            end
                            else begin
                                { pour récupérer variable $true ou $false ou une
                                  quelconque variable }
                                if isVar(lsVal)
                                then begin
                                    lsVal := goFirstVariables.Give(lsVal) ;
                                end
                                else begin
                                    lsVal := GetString(lsVal) ;
                                end ;
                            end ;

                            goVariables.Add(aoListArguments[liIndex], lsVal) ;

                            Inc(liIndex, 3) ;
                            Inc(liPosVarInCall) ;
                        end
                        else begin
                            ErrorMsg(csMustOptionalParameterAfter) ;
                            break ;
                        end ;
                    end
                    else begin
                        ErrorMsg(Format(csNotAVariable, [aoCurrentLine[liIndex]])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(csParamFunctionIncorrect) ;
                    break ;
                end ;
            end ;
        end
        else begin
            ErrorMsg(csParamFunctionIncorrect) ;
        end ;
    end ;

    procedure setVariableArgument(ListArguments : TStringList; CurrentLine : TStringList) ;
    var
        { Position de début }
        liDebut : Integer ;
        { Compteur de boucle }
        liIndex : Integer ;
    begin
        liDebut := ListArguments.IndexOf('...') ;

        if liDebut = -1
        then begin
            liDebut := ListArguments.Count -1 ;
        end ;

        { Créer les paramètres }
        goVariables.Add('$argcount', IntToStr(CurrentLine.Count - liDebut)) ;

        for liIndex := liDebut to CurrentLine.Count - 1 do
        begin
            goVariables.Add('$args[' + IntToStr(liIndex + 1) + ']', CurrentLine[liIndex]) ;
        end ;
    end ;
begin
    { Sauvegarde les anciennes variables globales }
    loOldGlobalVariable := goGlobalVariable ;
    { Créer un nouvelle objet de variable globale pour la fonction en cours }
    goGlobalVariable := TStringList.Create() ;

    liOldCurrentLineNumber := giCurrentLineNumber ;
    Result := -1 ;
    
    { Vérifie si on ne trouve pas la commande dans la liste des
      procédures }
    liLineOfProcedure := goListProcedure.Give(asCommande) ;

    if liLineOfProcedure = -1
    then begin
        ErrorMsg(Format(csUnknowCommande, [asCommande])) ;
    end
    else begin
        goCurrentFunctionName.Add(asCommande) ;

        { Translate les valeurs }
        //GetValueOfStrings(CurrentLine) ;

        { sauvegarde les variables }
        loOldVariables := goVariables ;

        { Créer les variables locales }
        goVariables := TVariables.Create ;

        goConstantes.Add('#_scriptname', goListOfFile[MyStrToInt(goLineToFile[giCurrentLineNumber])]) ;

        loListArguments := TStringList.Create ;

        loListArguments.Text := goListProcedure.GiveArguments(asCommande) ;

        liPosEqual := loListArguments.IndexOf('=') ;
        liPos3Dot := loListArguments.IndexOf('...') ;

        if  (liPosEqual = -1) and (liPos3Dot <> -1)
        then begin
            { Paramètre fixe + optionnel }
            if aoCurrentLine.Count >= (liPos3Dot)
            then begin
                setFixedParams(loListArguments, aoCurrentLine) ;
                setVariableArgument(loListArguments, aoCurrentLine) ;
            end
            else begin
                ErrorMsg(csMissingargument) ;
            end ;
        end
        else if (liPosEqual <> -1) and (liPos3Dot = -1)
        then begin
            { Paramètre non fixe + pas optionnel }
            if aoCurrentLine.Count >= (liPosEqual - 1)
            then begin
                { A-t-on plus d'argument passé lors de l'appel que de paramètre optionel }
                liNbArgFixe := liPosEqual - 1 ;

                if  aoCurrentLine.Count <= (liNbArgFixe + ((loListArguments.Count - liNbArgFixe) div 3 ))
                then begin
                    setFixedParams(loListArguments, aoCurrentLine) ;
                    setOptionnalParams(loListArguments, aoCurrentLine) ;
                end
                else begin
                    ErrorMsg(csTooArguments) ;
                end ;
            end
            else begin
                ErrorMsg(csMissingargument) ;
            end ;
        end
        else if (liPosEqual <> -1) and (liPos3Dot <> -1)
        then begin
            { Paramètre non fixe + optionnel }
            ErrorMsg(csNotEqualAnd3Dot) ;
        end
        else begin
            { On a que des paramètres fixe }
            if loListArguments.Count = aoCurrentLine.Count
            then begin
                { La fonction n'a pas de paramètre optionnelles ni de ... }
                setFixedParams(loListArguments, aoCurrentLine) ;
            end
            else if loListArguments.Count > aoCurrentLine.Count
            then begin
                ErrorMsg(csMissingargument) ;
            end
            else if loListArguments.Count < aoCurrentLine.Count
            then begin
                ErrorMsg(csTooArguments) ;
            end ;
        end ;

        if (not gbError) and (not gbQuit)
        then begin
            loEndCondition := TStringList.Create ;
            loEndCondition.Add('endfunc') ;
            loEndCondition.Add('goto') ;

            { Créer la variable pour ne pas avoir de warning }
            goVariables.Add('$result', '') ;

            liReturnLine := ReadCode(liLineOfProcedure, loEndCondition, goCodeList) ;

            loEndCondition.Free ;

            gsResultFunction := goVariables.Give('$result') ;

            if liReturnLine >= 0
            then begin
                lsCmdEnd := extractCommande(LowerCase(goCodeList[liReturnLine - 1])) ;

                if lsCmdEnd = 'goto'
                then begin
                    { -1 pour la ligne précédent + -1 pour le fait qu'il y ait un Inc
                      à la fin de ReadCode }
                    Result := liReturnLine - 2 ;
                    gbIsGoto := True ;
                end
                else begin
                    Result := liReturnLine ;
                end ;

                { Bascule les données de Variables dans les variables globales }
                for liIndexGlobalVariable := 0 to goGlobalVariable.Count - 1 do
                begin
                    lsNameOfVar := goGlobalVariable[liIndexGlobalVariable] ;

                    goFirstVariables.Add(lsNameOfVar, goVariables.Give(lsNameOfVar));
                    
                    if goFirstVariables <> loOldVariables
                    then begin
                        { Il faut recopier la valeur des variables globales dans les
                          variables de la procédure qui appelait }
                        loOldVariables.Add(lsNameOfVar, goVariables.Give(lsNameOfVar)) ;
                    end ;
                end ;
            end ;

            goGlobalVariable.Free() ;
            
            { Restaure les anciennes variables globales }
            goGlobalVariable := loOldGlobalVariable ;
        end ;

        { Supprime la fonction de la liste des fonctions en cours d'exécution pour
          permettre à WarningMsg et ErrorMsg d'afficher le nom de la fonction
          d'où vient le message }
        goCurrentFunctionName.Delete(goCurrentFunctionName.Count - 1) ;
        goVariables.Free ;
        loListArguments.Free ;
        goVariables := loOldVariables ;
    end ;

    giCurrentLineNumber := liOldCurrentLineNumber ;
end ;

{*****************************************************************************
 * DeleteVirguleAndParenthese
 * MARTINEAU Emeric
 *
 * Fonction qui supprime les virgules et parenthèse de début et fin
 *
 * Paramètres d'entrée :
 *   - aoArgumentsWithParentheses : liste à traiter
 *
 * Paramètres de sortie :
 *   - aoArgumentsWithParentheses : liste traitée
 *****************************************************************************}
procedure DeleteVirguleAndParenthese(aoArgumentsWithParentheses : TStringList) ;
var nb : Integer ;
    Index : Integer ;
    Parentheses : array of Integer ;
    EnleverParenthese : boolean ;
begin
    { Supprime les "," }
    Index := 0 ;

    while Index < aoArgumentsWithParentheses.Count do
    begin
        if aoArgumentsWithParentheses[Index] = ','
        then begin
            aoArgumentsWithParentheses.Delete(Index) ;
        end
        else begin
            Inc(Index) ;
        end ;
    end ;

    { si on a une parenthèse ouvrante, peut-être s'agit-il d'un appel xxx(...)}
    if aoArgumentsWithParentheses.Count > 0
    then begin
        if aoArgumentsWithParentheses[0] = '('
        then begin
            Index := 0 ;
            EnleverParenthese := False ;
            
            { on va compter le nombre de parenthèse }
            for nb := 0 to aoArgumentsWithParentheses.Count - 1 do
            begin
                if aoArgumentsWithParentheses[nb] = '('
                then begin
                    Inc(Index) ;
                    try
                        SetLength(Parentheses, Index) ;
                    except
                        on EOutOfMemory do begin
                            ErrorMsg(csOutOfMemory) ;
                            break ;
                        end ;
                    end ;

                    Parentheses[Index - 1] := nb ;
                end ;

                if aoArgumentsWithParentheses[nb] = ')'
                then begin
                    { si la parenthèse est sur la dernière case }
                    if (nb = aoArgumentsWithParentheses.Count - 1)
                    then
                        if Index > 0
                        then
                            { Est-ce la parenthèse correspondante est à la position 0 }
                            if Parentheses[Index - 1] = 0
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
                aoArgumentsWithParentheses.Delete(0) ;
                nb := aoArgumentsWithParentheses.Count - 1 ;
                aoArgumentsWithParentheses.Delete(nb) ;
            end ;
        end ;
    end ;
end ;

{*****************************************************************************
 * GetString
 * MARTINEAU Emeric
 *
 * Retourne la chaine qu'il y a entre " et '
 *
 * Paramètres d'entrée :
 *   - asText : texte entre " ou '
 *
 * Retour : texte
 *****************************************************************************}
function GetString(asText : String) : String ;
var
    { Delimiter " ou ' }
    lsDelimiter : String ;
    { Longueur de la chaine }
    liLength : Integer ;
begin
    liLength := length(asText) ;

    if liLength > 0
    then begin
        lsDelimiter := asText[1] ;

        Result := asText ;

        if (lsDelimiter = '"') or (lsDelimiter = '''')
        then begin
            if asText[liLength] = lsDelimiter
            then begin
                Result := copy(asText, 2, liLength - 2) ;
            end ;
        end ;
    end ;
end ;

{*****************************************************************************
 * ReadLabel
 * MARTINEAU Emeric
 *
 * Fonction qui initialise la table des labels
 *****************************************************************************}
procedure ReadLabel ;
var
    { Compteur de boucle }
    liIndex : Integer ;
    { Nom du label }
    lsLabel : string ;
    { Taille de la ligne à lire }
    liLength : Integer ;
begin
    if not gbLabelReading
    then begin
        gbLabelReading := True ;
        
        { Lit tous les labels }
        for liIndex := 0 to goCodeList.Count - 1 do
        begin
            liLength := Length(goCodeList[liIndex]) ;

            if liLength > 0
            then begin
                { si on trouve un : sur la ligne }
                if pos(':', goCodeList[liIndex]) = liLength
                then begin
                    { Vérifie s'il s'agit d'un label }
                    lsLabel := GetLabel(goCodeList[liIndex]) ;

                    if lsLabel <> ''
                    then begin
                        if goListLabel.Give(lsLabel) = -1
                        then begin
                            goListLabel.Add(lsLabel, liIndex) ;
                        end
                        else begin
                            ErrorMsg(Format(csLabelAlreadyExist, [lsLabel])) ;
                            exit ;
                        end ;
                    end ;
                end ;
            end ;
        end ;
    end ;
end ;

{*****************************************************************************
 * IsHexa
 * MARTINEAU Emeric
 *
 * Indique si c'est un chiffre hexadécimel
 *
 * Paramètres d'entrée :
 *   - asNumber : nombre
 *
 * Retour : true si la chaine représente un nombre hexa
 *****************************************************************************}
function IsHexa(asNumber : string) : boolean ;
var
    { Taille de la chaine }
    liLength : Integer ;
    { Compteur de boucle }
    liIndex : Integer ;
begin
    Result := False ;
    liLength := Length(asNumber) ;

    if liLength > 2
    then begin
        if (asNumber[1] = '0') and ((asNumber[2] = 'x') or (asNumber[2] = 'X'))
        then begin
            Result := True ;

            for liIndex := 3 to liLength do
            begin
                if not ((asNumber[liIndex] in ['0'..'9']) or
                        (asNumber[liIndex] in ['A'..'F']) or
                        (asNumber[liIndex] in ['a'..'f']))
                then begin
                    Result := False ;
                    break ;
                end ;
            end ;
        end ;
    end ;
end ;

{*****************************************************************************
 * ExtractCommande
 * MARTINEAU Emeric
 *
 * Extrait la première partie jusqu'au premier caractère non valide
 *
 * Paramètres d'entrée :
 *   - asText : texte à traiter
 *
 * Retour : texte jusqu'au premier espace ou tabulation
 *****************************************************************************}
function ExtractCommande(asText : string) : string ;
var
    { Compteur de boucle }
    liIndex : Integer ;
begin
    asText := Trim(asText) ;
    Result := '' ;

    for liIndex := 1 to Length(asText) do
    begin
        if (asText[liIndex] in ['a'..'z']) or (asText[liIndex] in ['a'..'z']) or
           (asText[liIndex] in ['0'..'9']) or (asText[liIndex] = '_')
        // (asText[liIndex] <> ' ') and (asText[liIndex] <> #9)
        then begin
            Result := Result + asText[liIndex] ;
        end
        else begin
            break ;
        end ;
    end ;

    Result := LowerCase(Result) ;
end ;

{*****************************************************************************
 * TStringListToPChar
 * MARTINEAU Emeric
 *
 * Converti une TStringList en PChar
 *
 * Paramètres d'entrée :
 *   - aoArgTStringList : Liste à traiter
 *
 * Paramètre de sortie :
 *   - aArgPChar : Chaine ASCIIZ
 *
 * Retour : true si l'extension chargée
 *****************************************************************************}
procedure TStringListToPChar(aoArgTStringList : TStringList; var aArgPChar : PChar) ;
Var
    { Compteur de boucle }
    liIndex : Integer ;
    { Longueur de la chaine de destination }
    liLength : Integer ;
begin
    liLength := 0 ;

    for liIndex := 0 to aoArgTStringList.Count - 1 do
    begin
        { +1 pour le #0 }
        liLength := liLength + Length(aoArgTStringList[liIndex]) + 1 ;
    end ;

    { +1 pour le double #0 }
    GetMem(aArgPChar, liLength + 1) ;

    liLength := 0 ;

    for liIndex := 0 to aoArgTStringList.Count - 1 do
    begin
        StrPCopy(@aArgPChar[liLength], aoArgTStringList[liIndex]) ;

        liLength := liLength + Length(aoArgTStringList[liIndex]) ; ;
        aArgPChar[liLength] := #0 ;
        Inc(liLength) ;
    end ;

    aArgPChar[liLength] := #0 ;
end ;

{*****************************************************************************
 * CallExtension
 * MARTINEAU Emeric
 *
 * Appele la fonction dans une extension
 *
 * Paramètres d'entrée :
 *   - asCommand : nom de la fonction,
 *   - aoArguments : liste des arguments
 *
 * Retour : true si commande exécutée
 *****************************************************************************}
function CallExtension(asCommande : String; aoArguments : TStringList) : Boolean ;
var
    { Compteur de boucle des extensions }
    liIndexOfExt : Integer ;
    { Procedure Execute }
    lProc : TProcExt ;
    { Arguments }
    lArgs : PChar ;
    { Nom du script }
    lScriptName : PChar ;
    { Version du moteur }
    lVersion : PChar ;
    { Commande a exécuter }
    lCommande : PChar ;
begin
    Result := False ;

    {$IFDEF FPC}
    // Supprime les warnings de Free Pascal Compiler
    lScriptName := nil ;
    lVersion := nil ;
    lCommande := nil ;
    {$ENDIF}

    lArgs := nil ;

    { + 1 pour le \0 }
    GetMem(lScriptName, Length(goConstantes.Give('#_scriptname')) + 1) ;

    if lScriptName = nil
    then begin
        ErrorMsg(csCanInitialiseDataToCallExtension) ;
        exit ;
    end ;

    lScriptName[0] := #0 ;

    StrPCopy(lScriptName, goConstantes.Give('#_scriptname')) ;

    { + 1 pour le \0 }
    GetMem(lVersion, Length(csVersion) + 1) ;

    if lVersion = nil
    then begin
        ErrorMsg(csCanInitialiseDataToCallExtension) ;
        exit ;
    end ;

    lVersion[0] := #0 ;

    StrPCopy(lVersion, csVersion) ;

    { + 1 pour le \0 }
    GetMem(lCommande, Length(asCommande) + 1) ;

    if lCommande = nil
    then begin
        ErrorMsg(csCanInitialiseDataToCallExtension) ;
        exit ;
    end ;

    lCommande[0] := #0 ;

    StrPCopy(lCommande, asCommande) ;

    for liIndexOfExt := 0 to goListOfExtension.Count - 1 do
    begin
        lProc := goListOfExtension.GiveProcByIndex(liIndexOfExt) ;

        TStringListToPChar(aoArguments, lArgs) ;

        if lProc(lCommande, lArgs, lScriptName, lVersion, StrToInt(goConstantes.Give('#_line')), @gbError)
        then begin
            Result := True ;

            gsResultFunction := goListOfExtension.GetResult(liIndexOfExt) ;

            break ;
        end ;
    end ;
end ;

{*****************************************************************************
 * UrlDecode
 * MARTINEAU Emeric
 *
 * Décode une url
 *
 * Paramètres d'entrée :
 *   - asUrl : Url à décoder
 *
 * Retour : url décodée
 *****************************************************************************}
function UrlDecode(asUrl : String) : String ;
var
    { Compteur de boucle }
    liIndex : Integer ;
    { Longueur de l'url }
    liLength : Integer ;
    { Chiffre hexa }
    lsHexa : String ;
begin
    liLength := Length(asUrl) ;
    liIndex := 1 ;
    Result := '' ;

    while liIndex <= liLength do
    begin
        if asUrl[liIndex] = '+'
        then begin
            Result := Result + ' ' ;
        end
        else if (asUrl[liIndex] = '%') and ((liLength - liIndex) > 1)
        then begin
            lsHexa := '0x' + Copy(asUrl, liIndex + 1, 2) ;

            if IsHexa(lsHexa)
            then begin
               Result := Result + Chr(MyStrToInt(lsHexa)) ;
               Inc(liIndex, 3) ;
            end
            else begin
                Result := Result + asUrl[liIndex] ;
                Inc(liIndex) ;
            end
        end
        else begin
            Result := Result + asUrl[liIndex] ;
            Inc(liIndex) ;
        end ;
    end ;
end ;

{*****************************************************************************
 * UrlEncode
 * MARTINEAU Emeric
 *
 * Encode une url
 *
 * Paramètres d'entrée :
 *   - asUrl : Url à encoder
 *
 * Retour : url encodée
 *****************************************************************************}
function UrlEncode(asUrl : string): string;
var
   liIndex : Integer ;
begin
    Result := '';

    for liIndex := 1 to Length(asUrl) do
    begin
        if asUrl[liIndex] in ['A'..'Z', 'a'..'z', '0'..'9', '-', '_', '.']
        then begin
            Result := Result + asUrl[liIndex] ;
        end
        else if asUrl[liIndex] = ' '
        then begin
            Result := Result + '+' ;
        end
        else begin
            Result := Result + '%' + IntToHex(Ord(asUrl[liIndex]), 2) ;
        end ;
    end;
end;

{*****************************************************************************
 * RepeterCaractere
 * MARTINEAU Emeric
 *
 * Répète un caractère
 *
 * Paramètres d'entrée :
 *   - asText : texte à répéter
 *   - aiNumber : nombre de fois à répéter
 *
 * Retour : chaine
 *****************************************************************************}
function RepeterCaractere(asText : string; aiNumber : integer) : String ;
var
    { Compteur de boucle }
    liIndex : Integer ;
begin
    Result := '' ;

    for liIndex := 1 to aiNumber do
    begin
        Result := Result + asText ;
    end ;
end ;

{*****************************************************************************
 * ExtractIntPart
 * MARTINEAU Emeric
 *
 * Extrait la partie entière d'un nombre
 *
 * Paramètres d'entrée :
 *   - asText : nombre sous forme de chaine
 *
 * Retour : partie entière
 *****************************************************************************}
function ExtractIntPart(asNumber : String) : String ;
var
    { Position du point }
    liPositionOfDot : Integer ;
begin
    liPositionOfDot := pos('.', asNumber) ;

    if liPositionOfDot <> 0
    then begin
        Result := Copy(asNumber, 1, liPositionOfDot - 1) ;
    end
    else begin
        Result := asNumber ;
    end ;
end ;

{*****************************************************************************
 * ExtractIntPart
 * MARTINEAU Emeric
 *
 * Extrait la partie fractionnaire d'un nombre
 *
 * Paramètres d'entrée :
 *   - asText : nombre sous forme de chaine
 *
 * Retour : partie fractionnaire
 *****************************************************************************}
function ExtractFloatPart(asNumber : String) : String ;
var
    { Position du point }
    liPositionOfDot : Integer ;
begin
    liPositionOfDot := pos('.', asNumber) ;

    if liPositionOfDot <> 0
    then begin
        Result := Copy(asNumber, liPositionOfDot + 1, length(asNumber) - liPositionOfDot) ;
    end
    else begin
        Result := '' ;
    end ;
end ;

{*****************************************************************************
 * AddSlashes
 * MARTINEAU Emeric
 *
 * Ajoute des slash
 *
 * Paramètres d'entrée :
 *   - asText : texte à traiter
 *
 * Retour : texte avec caractère d'échappement
 *****************************************************************************}
function AddSlashes(asText : String) : String ;
var
    { Compteur de boucle }
    liIndex : Integer ;
    { Longueur de la chaine }
    liLength : Integer ;
begin
    liLength := Length(asText) ;
    Result := '' ;

    for liIndex := 1 to liLength do
    begin
        if (asText[liIndex] = '\') or (asText[liIndex] = '"') or (asText[liIndex] = '''')
        then begin
            Result := Result + '\' ;
        end ;

        Result := Result + asText[liIndex] ;
    end ;
end ;

{*****************************************************************************
 * DeleteSlashes
 * MARTINEAU Emeric
 *
 * Supprime les slash
 *
 * Paramètres d'entrée :
 *   - asText : texte à traiter
 *
 * Retour : texte avec caractère d'échappement
 *****************************************************************************}
function DeleteSlashes(asText : String) : String ;
var
    { Compteur de boucle }
    liIndex : Integer ;
    { Longueur de la chaine }
    liLength : Integer ;
begin
    liLength := Length(asText) ;
    Result := '' ;

    liIndex := 1 ;
    
    while liIndex <= liLength do
    begin
        if asText[liIndex] = '\'
        then begin
            Inc(liIndex) ;
        end ;

        Result := Result + asText[liIndex] ;
        
        Inc(liIndex) ;
    end ;
end ;

{*****************************************************************************
 * DecToHex
 * MARTINEAU Emeric
 *
 * Convertit un nombre en hexa
 *
 * Paramètres d'entrée :
 *   - aiNumber : nombre
 *
 * Retour : valeur hexa
 *****************************************************************************}
function DecToHex(aiNumber : Integer) : string ;
var
    { Modulo du nombre }
    liModulo : SmallInt ;
    { Nouveau nombre }
    liNewNumber : Integer ;
    { Nombre représentatif }
    lsHexaNumber : string ;
begin
    if aiNumber = 0
    then begin
        result := '0' ;
    end
    else begin
        if aiNumber < 0
        then begin
            { pour obtenir la représentation d'un nombre négatif, c'est le
              complément à un + 1 }
            liNewNumber := (not Abs(aiNumber)) + 1 ;
        end
        else begin
            liNewNumber := aiNumber ;
        end ;

        result := '' ;

        while liNewNumber > 0 do
        begin
            liModulo := liNewNumber mod 16 ;
            liNewNumber := liNewNumber div 16 ;

            if liModulo < 10
            then begin
                lsHexaNumber := IntToStr(liModulo) ;
            end
            else if liModulo = 10
            then begin
                lsHexaNumber := 'a' ;
            end
            else if liModulo = 11
            then begin
                lsHexaNumber := 'b' ;
            end
            else if liModulo = 12
            then begin
                lsHexaNumber := 'c' ;
            end
            else if liModulo = 13
            then begin
                lsHexaNumber := 'd' ;
            end
            else if liModulo = 14
            then begin
                lsHexaNumber := 'e' ;
            end
            else if liModulo = 15
            then begin
                lsHexaNumber := 'f' ;
            end ;

            Result := lsHexaNumber + Result
        end ;
    end ;
end ;

{*****************************************************************************
 * DecToMyBase
 * MARTINEAU Emeric
 *
 * Convertit un nombre en une base donnée
 *
 * Paramètres d'entrée :
 *   - aiNumber : nombre
 *   - aBase : 2, 8, 10
 *
 * Retour : valeur du nombre
 *****************************************************************************}
function DecToMyBase(aiNumber : Integer; aBase : Byte) : String ;
var
    { Modulo du nombre }
    liModulo : SmallInt ;
    { Nouveau nombre }
    liNewNumber : Integer ;
    { Nombre représentatif }
    lsNumber : string ;
begin
    if aiNumber = 0
    then begin
        result := '0' ;
    end
    else begin
        if aiNumber < 0
        then begin
            { pour obtenir la représentation d'un nombre négatif, c'est le
              complément à un + 1 }
            liNewNumber := (not Abs(aiNumber)) + 1 ;
        end
        else begin
            liNewNumber := aiNumber ;
        end ;

        Result := '' ;

        while liNewNumber > 0 do
        begin
            liModulo := liNewNumber mod aBase ;
            liNewNumber := liNewNumber div aBase ;

            lsNumber := IntToStr(liModulo) ;

            Result := lsNumber + Result
        end ;
    end ;
end ;

{*****************************************************************************
 * DecToOct
 * MARTINEAU Emeric
 *
 * Convertit un nombre en octal
 *
 * Paramètres d'entrée :
 *   - aiNumber : nombre
 *
 * Retour : valeur du nombre
 *****************************************************************************}
function DecToOct(aiNumber : Integer) : String ;
begin
    Result := DecToMyBase(aiNumber, 8) ;
end ;

{*****************************************************************************
 * DecToOct
 * MARTINEAU Emeric
 *
 * Convertit un nombre en binaire
 *
 * Paramètres d'entrée :
 *   - aiNumber : nombre
 *
 * Retour : valeur du nombre
 *****************************************************************************}
function DecToBin(aiNumber : Integer) : String ;
begin
    Result := DecToMyBase(aiNumber, 2) ;
end ;

{*****************************************************************************
 * UniqId
 * MARTINEAU Emeric
 *
 * Renvoie un identifiant unique
 *
 * Retour : un numéro unique
 *****************************************************************************}
function UniqId : string ;
begin
    Randomize ;
    Result := FormatDateTime('yyyymmddhhnnsszzz', now) + MyFloatToStr(Random(9));
end ;

{*****************************************************************************
 * AddHeader
 * MARTINEAU Emeric
 *
 * Ajoute une entête
 *
 * Paramètre d'entrée :
 *   - asLine : ligne à ajouter
 *****************************************************************************}
procedure AddHeader(asLine : String) ;
var
    { Compteur de boucle }
    liIndex : Integer ;
    { Indique si la donnée a été insérée s'il s'agit de content-type }
    lbIsInsered : boolean ;
begin
    lbIsInsered := False ;

    { Insert les données avant la ligne vide s'il y en a une }
    for liIndex := 0 to Header.Count - 1 do
    begin
        //if pos('Content-Type', Header[i]) = 1
        if posString('Content-Type', Header[liIndex], 1, false) = 1
        then begin
            Header.Insert(liIndex, asLine) ;
            lbIsInsered := True ;
            break ;
        end ;
    end ;

    { si les données non pas été insérée }
    if not lbIsInsered
    then begin
        Header.Add(asLine) ;
    end ;
end ;

{*****************************************************************************
 * SendHeader
 * MARTINEAU Emeric
 *
 * Fonction qui envoie le header
 *****************************************************************************}
procedure SendHeader ;
var
    { Compteur de boucle }
    liIndex : Integer ;
begin
    { Mémorise d'où est envoyé les insormations }
    giLineWhereHeaderSend := giCurrentLineNumber ;

    gbIsHeaderSend := True ;

    for liIndex := 0 to Header.Count - 1 do
    begin
        writeln(Header[liIndex]) ;
    end ;
end ;

{*****************************************************************************
 * DateTimeToUnix
 * MARTINEAU Emeric
 *
 * Convertit un TDateTime en unix time stamp
 *
 * Paramètre d'entrée :
 *    - aoConvDate : date à convertir,
 *
 * Retour : date au format unix
 *****************************************************************************}
function DateTimeToUnix(aoPascalDate : TDateTime): Longint;
begin
    Result := Round((aoPascalDate - UnixStartDate) * 86400);
end;

{*****************************************************************************
 * UnixToDateTime
 * MARTINEAU Emeric
 *
 * Convertit un unix time stamp en TDateTime
 *
 * Paramètre d'entrée :
 *    - aiUnixTime : date au format unix
 *
 * Retour : date au format pascal
 *****************************************************************************}
function UnixToDateTime(aiUnixTime : Longint): TDateTime;
begin
    Result := (aiUnixTime div 86400) + UnixStartDate;
end;

{*****************************************************************************
 * OverTimeAndMemory
 * MARTINEAU Emeric
 *
 * Vérifie que le temps n'est pas écoulé
 ****************************************************************************}
procedure OverTimeAndMemory ;
begin
    {$IFNDEF COMMANDLINE}
    if SecondSpan(goStartTime, Now) > giElapseTime
    then begin
        ErrorMsg(csTimeIsEnd) ;
    end ;
    
    if OSUsageMemory > (giMaxMemorySize)
    then begin
        ErrorMsg(csMemoryLimit) ;
    end ;
    {$ENDIF}
end ;

{*****************************************************************************
 * OutputString
 * MARTINEAU Emeric
 *
 * Ecrit sur la sortie standard. Vérifie au préalable que l'entête à été envoyé.
 * Si ce n'est pas le cas, envoie l'entête.
 *
 * Paramètre d'entrée :
 *     - asText : texte à afficher,
 *     - lbParse : indique si on doit interpréter les \n, \t, \r, \0
 ****************************************************************************}
procedure OutputString(asText : String; abParse : boolean)  ;
var
    { Compteur de boucle de chaine }
    liIndex : Integer ;
    { Taille de la chaine à afficher }
    liLength : Integer ;
    { Texte à afficher }
    lsTexteDeSortie : String ;
    { Argument de la fonction output }
    loOutPutFunctionArgs : TStringList ;
    { Ancienne valeur gbIsExecutableCode }
    lbOldEC : Boolean ;
begin
    { On envoie l'entête si ça n'a pas été fait }
    if (not gbIsHeaderSend) and (not gbIsOutPuBuffered)
    then begin
        SendHeader ;
    end ;

    if abParse
    then begin
        liIndex := 1 ;
        liLength := Length(asText) ;
        lsTexteDeSortie := '' ;

        while liIndex <= liLength do
        begin
            { Prochain caractère }
            if asText[liIndex] = '\'
            then begin
                Inc(liIndex) ;

                if liIndex <= liLength
                then begin
                    if asText[liIndex] = 'n'
                    then begin
                        lsTexteDeSortie := lsTexteDeSortie + char(10) ;
                    end
                    else if asText[liIndex] = 'r'
                    then begin
                        lsTexteDeSortie := lsTexteDeSortie + char(13) ;
                    end
                    else if asText[liIndex] = 't'
                    then begin
                        lsTexteDeSortie := lsTexteDeSortie + char(9) ;
                    end
                    else begin
                        lsTexteDeSortie := lsTexteDeSortie + asText[liIndex] ;
                    end
                end
                else begin
                    lsTexteDeSortie := lsTexteDeSortie + asText[liIndex] ;
                end ;
            end
            else begin
                lsTexteDeSortie := lsTexteDeSortie + asText[liIndex] ;
            end ;

            Inc(liIndex) ;
        end ;
    end
    else begin
        lsTexteDeSortie := asText ;
    end ;

    if gbIsOutPuBuffered
    then begin

        loOutPutFunctionArgs := TStringList.Create ;
        loOutPutFunctionArgs.Add(lsTexteDeSortie) ;

        if gsOutPutFunction <> ''
        then begin
            { Il se peut que la fonction soit appelée dans du code HTML.
              De ce fait, ExecuteUserProcedure sera en mode HTML et pas
              en mode code. }
            lbOldEC := gbIsExecutableCode ;
            gbIsExecutableCode := True ;

            ExecuteUserProcedure(gsOutPutFunction, loOutPutFunctionArgs) ;

            gbIsExecutableCode := lbOldEC ;
        end
        else begin
            gsResultFunction := lsTexteDeSortie ;
        end ;
        
        loOutPutFunctionArgs.Free ;
        gsOutPutContent := gsOutPutContent + gsResultFunction ;
    end
    else begin
        write(lsTexteDeSortie) ;
    end ;
end ;

{*****************************************************************************
 * Realpath
 * MARTINEAU Emeric
 *
 * Fonction qui split les commandes
 *
 * Paramètres d'entrée :
 *   - asFileName : nom du fichier
 *
 * Retour : nom du fichier complet
 *****************************************************************************}
function Realpath(asFileName : string) : String ;
var
    { Contient la liste de répertoire + le fichier passé en paramètre }
    ListDirectory  : TStringList ;
    { Contient la liste de répertoire du répertoire racine ajouté si la chaine
      commence par un point (.) }
    ListDirecoryRoot : TStringList ;
    { Compteur de boucle }
    liIndexCounter : Integer ;
    { Position de . ou .. }
    liIndex : Integer ;
    { Contient le répertoire racine }
    lsRoot : String ;
begin
    if asFileName <> ''
    then begin
        ListDirectory := TStringList.Create ;

        Explode(asFileName, ListDirectory, '/') ;
        lsRoot := '' ;

        if ListDirectory.Count > 0
        then begin
            { On ajoute doc_root si on commence par . ou si le chemin ne
              commence pas par la racine }
            if ListDirectory[0] = '.'
            then begin
                lsRoot := gsDocRoot ;
            end
            else begin
                if not OsIsRootDirectory(asFileName)
                then begin
                    lsRoot := gsDocRoot ;
                end ;
            end ;

            { Si tmp <> '' c'est qu'on a ajouté nous même la racine. On doit
              donc l'exploser }
            if lsRoot <> ''
            then begin
                ListDirecoryRoot := TStringList.Create ;

                Explode(lsRoot, ListDirecoryRoot, OsAddFinalDirSeparator('')) ;

                for liIndexCounter := 0 to ListDirecoryRoot.Count - 1 do
                begin
                    ListDirectory.Insert(liIndexCounter, ListDirecoryRoot[liIndexCounter]);
                end ;

                ListDirecoryRoot.Free ;
            end ;

            { Supprime tout les . }
            repeat
                liIndex := ListDirectory.IndexOf('.') ;

                if liIndex <> - 1
                then begin
                    ListDirectory.Delete(liIndex) ;
                end ;
            until liIndex = -1 ;
        end ;

        repeat
            liIndex := ListDirectory.IndexOf('..') ;

            if liIndex <> - 1
            then begin
                if liIndex <> 0
                then begin
                     ListDirectory.Delete(liIndex - 1) ;
                     Dec(liIndex) ;
                end ;

                if liIndex <> -1
                then begin
                    ListDirectory.Delete(liIndex) ;
                end ;
            end ;
        until liIndex = -1 ;

        if not OsIsRootDirectory(asFileName)
        then begin
            Result := '' ;
        end
        else begin
            Result := OsRootDirectory ;
        end ;

        for liIndexCounter := 0 to ListDirectory.Count - 1 do
        begin
            Result := Result + ListDirectory[liIndexCounter] ;

            if liIndexCounter < ListDirectory.Count - 1
            then begin
                Result := OsAddFinalDirSeparator(Result) ;
            end ;
        end ;

        ListDirectory.Free ;
    end ;
end ;

{*****************************************************************************
 * ShowData
 * MARTINEAU Emeric
 *
 * Affiche les données si c'est un tableau, un entier...
 *
 * Paramètres d'entrée :
 *   - asData     : donnée à afficher (entier, tableau, pointer)
 *   - asDecalage : texte à afficher devant la donnée
 *   - aiIndex    : index dans le tableau
 *
 * Retour : chaine de caractère contenant les données à afficher. Contient
 *           '\n' donc il faut parser la chaine
 *****************************************************************************}
function ShowData(asData : string; asDecalage : String; aiIndex : Integer) : String ;
var
    { Type de donnée }
    lsTypeData : string ;
    { Donnée du tableau }
    loArrayData : TStringList ;
    { Compteur de boucle }
    liIndex : Integer ;
begin
    Result := '' ;

    if goVariables.InternalisArray(asData)
    then begin
        Result := Result + asDecalage + csArray + ' = {\n' ;

        loArrayData := TStringList.Create ;

        goVariables.explode(loArrayData, asData);

        for liIndex := 0 to loArrayData.Count - 1 do
        begin
            Result := Result + ShowData(loArrayData[liIndex], asDecalage + '    ', liIndex + 1) ;
        end ;

        loArrayData.Free ;

        Result := Result + '}\n' ;
    end
    else begin
        lsTypeData := csString ;

        if isHexa(asData)
        then begin
            lsTypeData := csHexa  ;
        end
        else if isInteger(asData)
        then begin
            lsTypeData := csInteger ;
        end
        else if isFloat(asData)
        then begin
            lsTypeData := csFloat ;
        end ;

        Result := Result + asDecalage ;

        if aiIndex > 0
        then begin
            Result := Result + '[' + IntToStr(aiIndex) + '] ' ;
        end ;

        Result := Result + lsTypeData + ' : ' + asData + '\n';
    end ;
end ;

{*****************************************************************************
 * ReplaceOneOccurence
 * MARTINEAU Emeric
 *
 * Remplace une occurence dans une chaine de caractère
 *
 * Paramètres d'entrée :
 *   - asSubstr        : chaine à remplacer
 *   - asStr           : chaine à traiter
 *   - asReplaceStr    : chaine de remplacement
 *   - abCaseSensitive : tenir compte de la caase
 *
 * Paramètre de sortie :
 *   - asStr           : nouvelle chaine
 *****************************************************************************}
function ReplaceOneOccurence(asSubstr : string; var asStr : string; asReplaceStr : string; abCaseSensitive : Boolean) : Cardinal ;
var
    { Position de la chaine à remplacer }
    liPositionOfStr : Integer;
    { Longueur de la chaine à remplacer }
    liLenSubStr : Integer ;
    { Longueur de la chaine de remplacement }
    liLenReplaceStr : Integer ;
begin
    liPositionOfStr := posString(asSubstr, asStr, 1, abCaseSensitive) ;
    Result := 0 ;
    liLenReplaceStr := length(asReplaceStr) ;
    liLenSubStr := Length(asSubstr) ;

    while liPositionOfStr <> 0 do
    begin
        OverTimeAndMemory ;
        
        if gbError
        then begin
            break ;
        end ;
        
        Inc(Result) ;
        Delete(asStr, liPositionOfStr, liLenSubStr) ;
        Insert(asReplaceStr, asStr, liPositionOfStr) ;
        liPositionOfStr := posString(asSubstr, asStr, liPositionOfStr + liLenReplaceStr, abCaseSensitive) ;
    end ;
end ;

{*****************************************************************************
 * PosString
 * MARTINEAU Emeric
 *
 * Retourne la position de subst dans str à partir d'index
 *
 * Paramètres d'entrée :
 *   - asSubstr        : chaine à rechercer
 *   - asStr           : chaine à dans laquel il faut chercher
 *   - aiIndex         : position de départ
 *   - abCaseSensitive : tenir compte de la caase
 *
 * Retour : position de la sous chaine
 *****************************************************************************}
function PosString(asSubStr : String; asStr : String; aiIndex : Integer; abCaseSensitive : boolean) : Cardinal ;
var
    { Compteur de boucle }
    liIndexStr : Cardinal ;
    { Partie de la chaine à comparer }
    lsTmp : String ;
    { Longueur de la chaine à regarder }
    liLengthStr : Integer ;
    { Longueur de la chaine à rechercher }
    liLengthSubStr : Integer ;
begin
    Result := 0 ;
    liLengthStr := Length(asStr) ;
    liLengthSubStr := Length(asSubStr) ;

    if aiIndex > 0
    then begin
        if not abCaseSensitive
        then begin
            asSubStr := AnsiLowerCase(asSubStr) ;
        end ;

        if abCaseSensitive
        then begin
            for liIndexStr := aiIndex to liLengthStr do
            begin
                lsTmp := Copy(asStr, liIndexStr, liLengthSubStr) ;

                if lsTmp = asSubStr
                then begin
                    Result := liIndexStr ;
                    break ;
                end ;
            end ;
        end
        else begin
            for liIndexStr := aiIndex to liLengthStr do
            begin
                lsTmp := Copy(asStr, liIndexStr, liLengthSubStr) ;
                
                if AnsiLowerCase(lsTmp) = asSubStr
                then begin
                    Result := liIndexStr ;
                    break ;
                end ;
            end ;
        end ;
    end ;
end ;

{*****************************************************************************
 * PosString
 * MARTINEAU Emeric
 *
 * Retourne la position de subst dans str à partir d'index en partant de la fin
 *
 * Paramètres d'entrée :
 *   - asSubstr        : chaine à rechercer
 *   - asStr           : chaine à dans laquel il faut chercher
 *   - aiIndex         : position de départ
 *   - abCaseSensitive : tenir compte de la caase
 *
 * Retour : position de la sous chaine
 *****************************************************************************}
function posrString(asSubStr : String; asStr : String; aiIndex : Integer; abCaseSensitive : boolean) : Cardinal ;
var
    { Compteur de boucle }
    liIndexStr : Cardinal ;
    { Partie de la chaine à comparer }
    lsTmp : String ;
    { Longueur de la chaine à regarder }
    liLengthStr : Integer ;
    { Longueur de la chaine à rechercher }
    liLengthSubStr : Integer ;
begin
    Result := 0 ;
    liLengthStr := Length(asStr) ;
    liLengthSubStr := Length(asSubStr) ;

    if aiIndex > 0
    then begin
        if not abCaseSensitive
        then begin
            asSubStr := AnsiLowerCase(asSubStr) ;
        end ;
    
        if aiIndex > liLengthStr
        then begin
            aiIndex := liLengthStr ;
        end ;

        if abCaseSensitive
        then begin
            for liIndexStr := aiIndex downto 1 do
            begin
                lsTmp := Copy(asStr, liIndexStr, liLengthSubStr) ;

                if lsTmp = asSubStr
                then begin
                    Result := liIndexStr ;
                    break ;
                end ;
            end ;
        end
        else begin
            for liIndexStr := aiIndex downto 1 do
            begin
                lsTmp := Copy(asStr, liIndexStr, liLengthSubStr) ;

                if AnsiLowerCase(lsTmp) = asSubStr
                then begin
                    Result := liIndexStr ;
                    break ;
                end ;
            end ;
        end ;
    end ;
end ;

{*****************************************************************************
 * ReplaceOneOccurenceOnce
 * MARTINEAU Emeric
 *
 * Remplace une occurence dans une chaine de caractère si la chaine n'a pas été
 * modifié précédement.
 *
 * Paramètres d'entrée :
 *   - asSubStr     : chaine à remplacer
 *   - asStr        : chaine à traiter
 *   - asReplaceStr : chaine de remplacement
 *   - asStrMod     : chaine aussi longue que Str contenant que 0. Les caractères
 *                    modifiés seront mis à 1
 *
 * Paramètre de sortie :
 *   - asStr        : chaine modifiée avec l'occurence substr
 *   - asStrMod     : les caractère modifiés sont mis à 1
 *****************************************************************************}
procedure ReplaceOneOccurenceOnce(asSubStr : string; var asStr : string; asReplaceStr : string; var asStrMod : String) ;
var
    { Position de SubStr }
    liPositionOfSubStr : Integer;
    { Longueur de SubStr }
    liLengthSubStr : Integer ;
    { Longueur de ReplaceStr }
    liLengthReplaceStr : Integer ;

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
    liLengthSubStr := Length(asSubStr) ;
    liLengthReplaceStr := Length(asReplaceStr) ;

    liPositionOfSubStr := posString(asSubStr, asStr, 1, true) ;

    while liPositionOfSubStr <> 0 do
    begin
        OverTimeAndMemory ;
        if gbError
        then
            break ;

        if not ModifiedString(asStrMod, liPositionOfSubStr, liLengthSubStr)
        then begin
            Delete(asStr, liPositionOfSubStr, liLengthSubStr) ;
            Insert(asReplaceStr, asStr, liPositionOfSubStr) ;

            Delete(asStrMod, liPositionOfSubStr, liLengthSubStr) ;
            Insert(RepeterCaractere('1', liLengthReplaceStr), asStrMod, liPositionOfSubStr) ;
            
            liPositionOfSubStr := posString(asSubStr, asStr, liPositionOfSubStr + liLengthReplaceStr, true) ;
        end
        else begin
            liPositionOfSubStr := posString(asSubStr, asStr, liPositionOfSubStr + liLengthReplaceStr, true) ;
        end ;
    end ;
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

{*****************************************************************************
 * InitDayName
 * MARTINEAU Emeric
 *
 * Initialise le tableau des jours
 *
 * Paramètres d'entrée :
 *   - aaValue     : jours de la semaines (1er jour dimanche)
 *
 * Paramètre de sortie :
 *   - aaArray : tableau à initialiser (tableau commençat à 1)
 *****************************************************************************}
procedure InitDayName(var aaArray : array of string; aaValue : array of string) ;
var
    liIndex : Integer ;
begin
    for liIndex := 1 to 7 do
    begin
        aaArray[liIndex] := aaValue[liIndex - 1] ;
    end ;
end ;

{*****************************************************************************
 * InitDayName
 * MARTINEAU Emeric
 *
 * Initialise le tableau des mois
 *
 * Paramètres d'entrée :
 *   - aaValue     : jours de la semaines (1er jour dimanche)
 *
 * Paramètre de sortie :
 *   - aaArray : tableau à initialiser (tableau commençat à 1)
 *****************************************************************************}
procedure InitMonthName(var aaArray : array of string; aaValue : array of string) ;
var
    liIndex : Integer ;
begin
    for liIndex := 1 to 12 do
    begin
        aaArray[liIndex] := aaValue[liIndex - 1] ;
    end ;
end ;

{*****************************************************************************
 * IsKeyWord
 * MARTINEAU Emeric
 *
 * indique s'il s'agit d'un mot clef
 *
 * Paramètres d'entrée :
 *   - asKeyword : mot clef
 *
 * Retour : true si mot clef
 *****************************************************************************}
function IsKeyWord(asKeyword : String) : boolean ;
begin
    Result := False ;
    
    if (asKeyword = 'in') or (asKeyword = 'or') or
       (asKeyword = 'xor') or (asKeyword = 'and') or
       (asKeyword = 'not') or (asKeyword = 'to') or
       (asKeyword = 'step') or (asKeyword = 'case') or
       (asKeyword = 'default')
    then begin
        Result := True ;
    end ;
end ;

{*****************************************************************************
 * IsConst
 * MARTINEAU Emeric
 *
 * Fonction vérfie qu'il s'agit d'une constante
 *
 * Paramètres d'entrée :
 *   asVarName : texte contenant la constante
 *
 * Retour : true si c'est un nom valide pour une constante
 *****************************************************************************}
function IsConst(asText : string) : boolean ;
Var
    { Longueur de la variable }
    liLength : integer ;
begin
    asText := LowerCase(asText) ;
    liLength := length(asText) ;
    Result := False ;

    if liLength > 1
    then begin
        if asText[1] = '#'
        then begin
            Result := CheckVarName(2, asText) ;
        end ;
    end ;
end ;

{*****************************************************************************
 * IsSetConst
 * MARTINEAU Emeric
 *
 * Indique si la constante existe
 *
 * Paramètres d'entrée :
 *   - asConstante : nom de la constante (avec #)
 *
 * Retour : true ou false
 *****************************************************************************}
function IsSetConst(asConstante : string) : boolean ;
begin
    Result := goConstantes.IsSet(asConstante) ;
end ;

{*****************************************************************************
 * GetConst
 * MARTINEAU Emeric
 *
 * Retourne la valeur de la constante
 *
 * Paramètres d'entrée :
 *   - asConstante : nom de la constante (avec #)
 *
 * Retour : true ou false
 *****************************************************************************}
function GetConst(asConstante : string) : string ;
begin
    if not goConstantes.isSet(asConstante)
    then begin
        WarningMsg(Format(csConstanteDoesntExist, [asConstante])) ;
    end ;
    
    Result := goConstantes.Give(asConstante) ;
end ;

{*****************************************************************************
 * GetEndOfLine
 * MARTINEAU Emeric
 *
 * Retourne la valeur de fin de ligne
 *
 * Paramètres d'entrée :
 *   - asCommande : commande
 *
 * Retour : true ou false
 *****************************************************************************}
function GetEndOfLine(asCommande : string) : string ;
begin
    asCommande := LowerCase(asCommande) ;
    
    if (asCommande = 'function') or (asCommande = 'repeat') or (asCommande = 'else')
    then begin
        Result := '' ;
    end
    else if (asCommande = 'if') or (asCommande = 'elseif')
    then begin
        Result := 'then' ;
    end
    else if (asCommande = 'for') or (asCommande = 'while') or (asCommande = 'switch')
    then begin
        Result := 'do' ;
    end
    else if (asCommande = 'case') or (asCommande = 'default')
    then begin
        Result := ':' ;
    end

    else begin
        Result := ';' ;
    end ;
end ;

{*****************************************************************************
 * ExtractEndOperator
 * MARTINEAU Emeric
 *
 * Extrait la fin de chaine jusqu'au caractère non valide
 *
 * Paramètres d'entrée :
 *   - asText : texte à traiter
 *
 * Retour : texte jusqu'au premier espace ou tabulation
 *****************************************************************************}
function ExtractEndOperator(asText : string) : string ;
var
    { Compteur de boucle }
    liIndexText : Integer ;
    { Longueur d'asText }
    liLength : Integer ;
    { Compteur pour l'operateur }
    liIndexOperator : Integer ;
begin
    asText := LowerCase(Trim(asText)) ;
    Result := '' ;

    liLength := Length(asText) ;
    
    if liLength > 0
    then begin
        for liIndexText := liLength downto 1 do
        begin
            if (asText[liIndexText] = '-') or
               (asText[liIndexText] = '+') or
               (asText[liIndexText] = '%') or
               (asText[liIndexText] = '=') or
               (asText[liIndexText] = '.') or
               (asText[liIndexText] = ',') or
               (asText[liIndexText] = '*') or
               (asText[liIndexText] = '/') or
               (asText[liIndexText] = '^') or
               (asText[liIndexText] = '~') or
               (asText[liIndexText] = '&') or
               (asText[liIndexText] = ';') or
               (asText[liIndexText] = ':') or
               (asText[liIndexText] = '?')
            then begin
                Result := asText[liIndexText] ;
                break ;
            end
            else if asText[liIndexText] = '|'
            then begin
                Result := '|' ;
                
                if liIndexText > 1
                then begin
                    if asText[liIndexText - 1] = '&'
                    then begin
                        Result := '&' + Result ;
                    end ;
                end ;
                
                break ;
            end
            else if asText[liIndexText] = '<'
            then begin
                Result := '<' ;

                if liIndexText > 1
                then begin
                    if asText[liIndexText - 1] = '<'
                    then begin
                        Result := '<' + Result ;
                    end ;
                end ;

                break ;
            end
            else if asText[liIndexText] = '>'
            then begin
                Result := '>' ;

                if liIndexText > 1
                then begin
                    if asText[liIndexText - 1] = '>'
                    then begin
                        Result := '>' + Result ;
                    end ;
                end ;

                break ;
            end
            else begin
                for liIndexOperator := liIndexText downto 1 do
                begin
                    if asText[liIndexOperator] in ['a'..'z']
                    then begin
                        Result := asText[liIndexOperator] + Result ;
                    end
                    else begin
                        break ;
                    end ;
                end ;
                
                break ;
            end ;
        end ;
    end ;
end ;

{*****************************************************************************
 * IsEndOperatorBy
 * MARTINEAU Emeric
 *
 * Extrait la première partie jusqu'au premier espace ou tabulation
 *
 * Paramètres d'entrée :
 *   - asText : texte à traiter
 *
 * Retour : texte jusqu'au premier espace ou tabulation
 *****************************************************************************}
function IsEndOperatorBy(asEndOfLine : string) : boolean ;
begin
    if AnsiIndexStr(asEndOfLine, ['+', '-', '/', '*', '^', '|', '&', '&|', '<<', '>>',
                                  '~', '%', '.', '=', '<=', '<', '<>', '>=', '>', 'and',
                                  'or', 'xor', 'in', 'not', '?', ':']) <> -1
    then begin
        Result := true ;
    end
    else begin
        Result := false ;
    end ;
end ;

{*****************************************************************************
 * AnsiIndexStr
 * MARTINEAU Emeric
 *
 * Retourne la position d'une chaine dans un tableau
 *
 * Paramètres d'entrée :
 *   - asText
 *
 * Retour : index si trouvé, -1 sinon
 *****************************************************************************}
function AnsiIndexStr(asText : string; const asValues : array of string) : integer;
begin
    Result := 0 ;

    while Result <= High(asValues) do
    begin
        if (asValues[Result] = asText)
        then begin
            exit ;
        end
        else begin
            inc(Result) ;
        end ;
    end ;

    Result := -1;
end;

{*****************************************************************************
 * IndexOfTStringList
 * MARTINEAU Emeric
 *
 * Retourne la position d'une chaine dans une TStringList
 *
 * Paramètres d'entrée :
 *   - aiStart : position de démarage,
 *   - aoList : TStringList où il faut chercher,
 *   - asSearch : ce qu'il faut chercher,
 *
 * Retour : index si trouvé, -1 sinon
 *****************************************************************************}
function IndexOfTStringList(aiStart : Integer; aoList : TStringList; asSearch : String) : Integer ;
var
    { Compteur de boucle }
    liCompteur : Integer ;
begin
    Result := -1 ;

    liCompteur := aiStart ;

    if liCompteur < 0
    then begin
        liCompteur := 0 ;
    end ;

    asSearch := LowerCase(asSearch) ;

    for liCompteur := liCompteur to aoList.count - 1 do
    begin
        if LowerCase(aoList[liCompteur]) = asSearch
        then begin
            Result := liCompteur ;
            break ;
        end ;
    end ;
end ;

end.

