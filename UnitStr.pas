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

uses classes, Functions, UnitMessages, InternalFunction, Math ;

procedure StrFunctionsInit ;
procedure echoCommande(arguments : TStringList) ;
procedure dieCommande(arguments : TStringList) ;
procedure strTrimCommande(arguments : TStringList) ;
procedure strTrimLeftCommande(arguments : TStringList) ;
procedure strTrimRightCommande(arguments : TStringList) ;
procedure strReplaceCommande(arguments : TStringList) ;
procedure strDeleteCommande(arguments : TStringList) ;
procedure strInsertCommande(arguments : TStringList) ;
procedure strExplodeCommande(arguments : TStringList) ;
procedure strImplodeCommande(arguments : TStringList) ;
procedure strLoadFromFileCommande(arguments : TStringList) ;
procedure strSaveToFileCommande(arguments : TStringList) ;
procedure strAddSlashesCommande(arguments : TStringList) ;
procedure strDeleteSlashesCommande(arguments : TStringList) ;
procedure strPrintRCommande(arguments : TStringList) ;
procedure strRepeatStringCommande(arguments : TStringList) ;
procedure strPrintFCommande(arguments : TStringList) ;
procedure strBase64EncodeCommande(arguments : TStringList) ;
procedure strSoundExCommande(arguments : TStringList) ;
procedure strUcFirstCommande(arguments : TStringList) ;
procedure struppercaseCommande(arguments : TStringList) ;
procedure strlowercaseCommande(arguments : TStringList) ;
procedure strUcWordsCommande(arguments : TStringList) ;
procedure striReplaceCommande(arguments : TStringList) ;
procedure strReplaceGlobalCommande(arguments : TStringList; SensitiveCase : Boolean) ;
procedure strposGlobalCommande(arguments : TStringList; CaseSensitive : Boolean; StartEnd : Boolean) ;
procedure striposCommande(arguments : TStringList) ;
procedure strrposCommande(arguments : TStringList) ;
procedure strriposCommande(arguments : TStringList) ;
procedure strtrCommande(arguments : TStringList) ;
procedure strrevCommande(arguments : TStringList) ;
procedure strcspnCommande(arguments : TStringList) ;
procedure strspnCommande(arguments : TStringList) ;
procedure strNumberFormatCommande(arguments : TStringList) ;

procedure configParameter(var start : integer; var len : integer; var search : TStringList; arguments : TStringList) ;

implementation

uses Code, SysUtils, Variable ;

procedure echoCommande(arguments : TStringList) ;
begin
    if arguments.count <= 1
    then begin
        if arguments.count <> 0
        then
            OutPutString(arguments[0], false) ;
    end
    else begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure dieCommande(arguments : TStringList) ;
begin
    if arguments.count <= 1
    then begin
        if arguments.count <> 0
        then
            OutPutString(arguments[0], false) ;

        GlobalQuit := True ;
    end
    else begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure struppercaseCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := AnsiUpperCase(arguments[0]) ;
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

procedure strlowercaseCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := AnsiLowerCase(arguments[0]) ;
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

procedure strcopyCommande(arguments : TStringList) ;
var startpos, endpos : integer ;
begin
    if arguments.count = 3
    then begin
        startpos := MyStrToInt(arguments[1]) ;
        endpos := MyStrToInt(arguments[2]) ;

        if startpos = 0
        then
            ErrorMsg(sStartValNotValidNum)
        else if endpos = 0
        then
            ErrorMsg(sEndValNotValidNum)
        else
            ResultFunction := Copy(arguments[0], startpos, startpos - endpos) ;
    end
    else if arguments.count < 3
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 3
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure strposCommande(arguments : TStringList) ;
begin
    strposGlobalCommande(arguments, true, false) ;
end ;

procedure striposCommande(arguments : TStringList) ;
begin
    strposGlobalCommande(arguments, false, false) ;
end ;

procedure strrposCommande(arguments : TStringList) ;
begin
    strposGlobalCommande(arguments, true, true) ;
end ;

procedure strriposCommande(arguments : TStringList) ;
begin
    strposGlobalCommande(arguments, false, true) ;
end ;

procedure strposGlobalCommande(arguments : TStringList; CaseSensitive : Boolean; StartEnd : Boolean) ;
var Index : Integer ;
begin
    if (arguments.count > 1) and (arguments.count < 4)
    then begin
        if arguments.count = 3
        then begin
            if isInteger(arguments[2])
            then
                Index := MyStrToInt(arguments[2])
            else
                Index := 0 ;
        end
        else begin
            if StartEnd
            then
                Index := Length(arguments[1])
            else
                Index := 1 ;
        end ;

        if Index > 0
        then begin
            if StartEnd
            then
                ResultFunction := IntToStr(PosrString(arguments[0], arguments[1], Index, CaseSensitive))
            else
                ResultFunction := IntToStr(PosString(arguments[0], arguments[1], Index, CaseSensitive)) ;
        end
        else begin
            ErrorMsg(sInvalidIndex) ;
        end ;
    end
    else if arguments.count < 2
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 3
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure strTrimCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := Trim(arguments[0]) ; 
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

procedure strTrimLeftCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := TrimLeft(arguments[0]) ;
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

procedure strTrimRightCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := TrimRight(arguments[0]) ;
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

procedure strReplaceCommande(arguments : TStringList) ;
begin
    strReplaceGlobalCommande(arguments, true) ;
end ;

procedure striReplaceCommande(arguments : TStringList) ;
begin
    strReplaceGlobalCommande(arguments, false) ;
end ;

procedure strReplaceGlobalCommande(arguments : TStringList; SensitiveCase : Boolean) ;
var
  position : integer ;
  countvar : string ;
  count : Cardinal ;
  SubStr, Str, ReplaceStr : String ;
  Liste : TStringList ;
begin
    // strReplace(substr, str, replacetext [, $count])
    if (arguments.count > 2)
    then begin
        { Le dernier élément peut contenir le compteur }
        Position := arguments.count - 1 ;
        count := 0 ;
        countvar := arguments[Position] ;

        if isVar(countvar)
        then begin
            { On efface la variable pour ne pas avoir l'affichage comme quoi la
              variable n'existe pas.
              On ne supprime SURTOUT pas arguments[Position] car cela permet de
              vérifier le nombre total d'arguement }
            arguments[Position] := '' ;
        end
        else begin
            countvar := ''
        end ;

        { Parse les données }
        GetValueOfStrings(arguments) ;

        if (arguments.count = 4) and (countvar = '')
        then begin
            ErrorMsg(Format(sNotAVariable, [countvar])) ;
        end
        else if (arguments.count > 4)
        then begin
            ErrorMsg(sTooArguments) ;
        end
        else begin
            { Est un tableau ou une chaine }
            SubStr := arguments[0] ;
            Str := arguments[1] ;
            ReplaceStr := arguments[2] ;

            if Variables.InternalisArray(SubStr)
            then begin
                Liste := TStringList.Create() ;
                Variables.explode(Liste, SubStr);

                if Liste.Count > 0
                then begin
                    for position := 0 to Liste.Count - 1 do
                    begin
                        count := count + ReplaceOneOccurence(Liste[position], Str, ReplaceStr, SensitiveCase) ;
                    end ;
                end ;

                Liste.Free ;
            end
            else begin
               count := count + ReplaceOneOccurence(Substr, Str, ReplaceStr, SensitiveCase) ;
            end ;

            ResultFunction := Str ;

            if countvar <> ''
            then
                Variables.Add(countvar, IntToStr(count));
        end ;
    end
    else if arguments.count < 2
    then begin
        ErrorMsg(sMissingargument) ;
    end ;
end ;

procedure strInsertCommande(arguments : TStringList) ;
var index : integer ;
    tmp : string ;
begin
    if arguments.count = 3
    then begin
        index := MyStrToInt(arguments[2]) ;

        if index > 0
        then begin
            tmp := arguments[1] ;
            Insert(arguments[0], tmp, index) ;
            ResultFunction := tmp ;
        end
        else
            ErrorMsg(sInvalidIndex) ;
    end
    else if arguments.count < 3
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 3
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure strDeleteCommande(arguments : TStringList) ;
var index, count : integer ;
    tmp : string ;
begin
    if arguments.count = 3
    then begin
        index := MyStrToInt(arguments[1]) ;
        count := MyStrToInt(arguments[2]) ;

        if (index > 0) and (count > 0)
        then begin
            tmp := arguments[0] ;
            Delete(tmp, index, count) ;
            ResultFunction := tmp ;
        end
        else
            ErrorMsg(sInvalidIndex) ;
    end
    else if arguments.count < 3
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 3
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure strExplodeCommande(arguments : TStringList) ;
var Liste : TStringList ;
begin
    if arguments.count = 2
    then begin
        Liste := TStringList.Create ;

        Explode(arguments[1], Liste, arguments[0]) ;

        ResultFunction := Variables.CreateArray(Liste) ;

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

procedure strImplodeCommande(arguments : TStringList) ;
var 
    Liste : TStringList ;
    i : Integer ;
begin
    if arguments.count = 2
    then begin
        Liste := TStringList.Create ;
        Variables.explode(Liste, arguments[1]);

        ResultFunction := '' ;

        for i := 0 to Liste.Count -1 do
        begin
            ResultFunction := ResultFunction + Liste[i] ;

            if i <> (Liste.Count - 1)
            then
                ResultFunction := ResultFunction + arguments[0] ;
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

procedure strLoadFromFileCommande(arguments : TStringList) ;
var Liste : TStringList ;
    error : Boolean ;
begin
    if arguments.count = 1
    then begin
        error := False ;
        arguments[0] := RealPath(arguments[0]) ;

        { Vérifie l'inclusion du fichier si on est en safe mode }
        if (SafeMode = True) and (doc_root <> '')
        then begin
            if Pos(doc_root, arguments[0]) = 0
            then begin
                error := True ;
                WarningMsg(sCantDoThisInSafeMode) ;
            end ;
        end ;

        if not error
        then begin
            Liste := TStringList.Create ;

            Liste.LoadFromFile(arguments[0]);

            ResultFunction := Variables.CreateArray(Liste) ;

            Liste.Free ;
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

procedure strSaveToFileCommande(arguments : TStringList) ;
var Liste : TStringList ;
    error : Boolean ;
begin
    if arguments.count = 2
    then begin
        error := False ;
        arguments[1] := RealPath(arguments[1]) ;
        ResultFunction := falseValue ;

        { Vérifie l'inclusion du fichier si on est en safe mode }
        if (SafeMode = True) and (doc_root <> '')
        then begin
            if Pos(doc_root, arguments[1]) = 0
            then begin
                error := True ;
                WarningMsg(sCantDoThisInSafeMode) ;
            end ;
        end ;

        if not error
        then begin
            Liste := TStringList.Create ;

            Variables.explode(Liste, arguments[0]);

            {$I-}
            Liste.SaveToFile(arguments[1]) ;
            {$I+}

            if IOResult = 0
            then
                ResultFunction := trueValue ;
                
            Liste.Free ;
        end ;
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

procedure strAddSlashesCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := AddSlashes(arguments[0]);
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

procedure strDeleteSlashesCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := DeleteSlashes(arguments[0]) ;
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

procedure strPrintRCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isVar(arguments[0])
        then
            OutPutString(showData(getVar(arguments[0]), '', 0), true)
        else
            ErrorMsg(Format(sNotAVariable, [arguments[0]])) ;
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

procedure strRepeatStringCommande(arguments : TStringList) ;
begin
    if arguments.count = 2
    then begin
        if isInteger(arguments[1])
        then
            ResultFunction := RepeterCaractere(arguments[0], MyStrToInt(arguments[1]))
        else
            ErrorMsg(sSizeMustBeInt) ;
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

procedure strPrintFCommande(arguments : TStringList) ;
var
    { Chiffre debut et fin f8.2d }
    longueurDebut, LongueurFin : Integer ;
    { Contient le caractère d'espacement peut être 0 ou espace }
    Espacement : String ;
    { Contient le caractère de remplissage peut être 0 ou espace }
    Remplissage : String ;
    { Indique s'il faut aligner à droite }
    AlignerAGauche : Boolean ;
    { Indique le type de donnée }
    TypeData : String ;
    { Indique si le nombre est negatif }
    isNeg : Boolean ;
    { Indique l'indice si c'est + au - }
    Indice : String ;
    { Force l'affichage du signe }
    ForceSign : Boolean ;
    { Ajoute des éléments devant e.g. 0x devant l'hexa }
    AddBefore : Boolean ;

    i, j, len, index : Integer ;
    Text : string ;
    MaxArgs : Integer ;
    tmp, tmp2, tmp3 : String ;
    tmpFloat : Extended ;
    tmpInt : Integer ;
    
    function GetNumberOfElement(Text : String; var i : Integer) : Integer ;
    var len : Integer ;
        fin : Integer ;
        debut : Integer ;
    begin
        len := Length(Text) ;
        fin := 0 ;
        
        { 1 - Récupère le numéro d'argument à afficher }
        debut := i ;

        while i <= len do
        begin
            OverTimeAndMemory ;
            if GlobalError
            then
                break ;

            if not (Text[i] in ['0'..'9'])
            then begin
                fin := i ;
                break ;
            end ;

            Inc(i) ;
        end ;

        if fin - debut > 0
        then
            Result := MyStrToInt(Copy(Text, debut, fin - debut))
        else
            Result := 0 ;

    end ;

    function SetSign(tmp : string; isNeg : Boolean; LongueurDebut : Integer; Remplissage : String) : string ;
    var j : Integer ;
    begin
        if LongueurDebut > 0
        then begin
            { position le - au premier espace trouvé }
            for j := Length(tmp) downto 1 do
            begin
                if tmp[j] = Remplissage
                then begin
                    if isNeg
                    then
                        tmp[j] := '-'
                    else
                        tmp[j] := '+' ;

                    break ;
                end
                else begin
                    { si aucun espace n'est trouvé il faut alors
                      ajouter le moins devant }
                    if j = 1
                    then begin
                        if isNeg
                        then
                            tmp := tmp + '-'
                        else
                            tmp := tmp + '+' ;
                    end ;
               end ;
            end ;
        end
        else begin
            if isNeg
            then
                tmp := '-' + tmp
            else
                tmp := '+' + tmp ;
        end ;

        Result := Tmp ;
    end ;
begin
    if arguments.count > 1
    then begin
        { Nombre maximum d'argument passé en paramètre. - 1 car le premier
          élément est la chaine }
        MaxArgs := arguments.Count - 1 ;

        i := 1 ;
        
        { index pointe sur l'élément à convertir. 1 Car 0 contient la chaine à
          afficher }
        index := 1 ;

        len := Length(arguments[0]) ;
        Text := arguments[0] ;

        while i <= len do
        begin
            OverTimeAndMemory ;
            if GlobalError
            then
                break ;

            { Si on a un % c'est qu'on doit convertir une données }
            if Text[i] = '%'
            then begin
                if (len - i) > 0
                then begin
                    Inc(i) ;

                    if Text[i] <> '%'
                    then begin
                        if (Text[i] = '+')
                        then begin
                            ForceSign := True ;
                            Inc(i) ;
                        end
                        else
                            ForceSign := False ;

                        if (Text[i] = '#')
                        then
                            AddBefore := True
                        else
                            AddBefore := False ;

                        { Espacement }
                        if (Text[i] = ' ') or (Text[i] = '0') or (Text[i] = '''')
                        then begin
                            if (Text[i] = '''')
                            then
                                Inc(i) ;

                            Espacement := Text[i] ;
                            Inc(i) ;
                        end
                        else
                            Espacement := ' ' ;

                        { Remplissage }
                        if (Text[i] = ' ') or (Text[i] = '0') or (Text[i] = '''')
                        then begin
                            if (Text[i] = '''')
                            then
                                Inc(i) ;

                            Remplissage := Text[i] ;
                            Inc(i) ;
                        end
                        else
                            Remplissage := ' ' ;

                        if Text[i] = '-'
                        then begin
                            AlignerAGauche := True ;
                            Inc(i) ;
                        end
                        else
                            AlignerAGauche := False ;

                        { Longueur de début }
                        j := i ;
                        longueurDebut := GetNumberOfElement(Text, i) ;

                        { Si le pointeur de chaine n'a pas avancé }
                        if i = j
                        then begin
                            if Text[i] = '*'
                            then begin
                                longueurDebut := MyStrToInt(arguments[index]) ;
                                Inc(Index) ;
                                Inc(i) ;
                            end ;
                        end ;

                        longueurFin := 6 ;
                        
                        { Est-ce un point ? }
                        if Text[i] = '.'
                        then begin
                            Inc(i) ;

                            { Longueur de fin }
                            j := i ;
                            longueurFin := GetNumberOfElement(Text, i) ;

                            { Si le pointeur de chaine n'a pas avancé }
                            if i = j
                            then begin
                                if Text[i] = '*'
                                then begin
                                    longueurFin := MyStrToInt(arguments[index]) ;
                                    Inc(Index) ;
                                    Inc(i) ;
                                end ;
                            end ;
                        end ;

                        TypeData := Text[i] ;

                        if Index <= MaxArgs
                        then begin
                            if TypeData = 'u'
                            then begin
                                TypeData := 'd' ;
                                
                                if isInteger(arguments[index])
                                then begin
                                    tmp := arguments[index] ;
                                    
                                    if tmp <> ''
                                    then begin
                                        if tmp[1] = '-'
                                        then begin
                                            arguments[index] := copy(tmp, 2, length(tmp) - 1) ;
                                        end ;
                                    end ;
                                end ;
                            end ;

                            if TypeData = 'c'
                            then begin
                                if isInteger(arguments[index])
                                then begin
                                    ResultFunction := ResultFunction + Chr(MyStrToInt(arguments[index])) ;
                                end ;
                            end
                            else if TypeData = 'd'
                            then begin
                                if isFloat(arguments[index])
                                then begin
                                    tmp := extractIntPart(arguments[index]) ;

                                    if AlignerAGauche
                                    then begin
                                        if ForceSign
                                        then begin
                                            if tmp[1] <> '-'
                                            then
                                                tmp := '+' + tmp ;
                                        end ;

                                        tmp := tmp + RepeterCaractere(Espacement, LongueurDebut - Length(tmp))
                                    end
                                    else begin
                                        isNeg := False ;

                                        if tmp <> ''
                                        then begin
                                            if tmp[1] = '-'
                                            then begin
                                                isNeg := True ;
                                                tmp := copy(tmp, 2, length(tmp) - 1) ;
                                            end ;
                                        end ;

                                        tmp := RepeterCaractere(Remplissage, LongueurDebut - Length(tmp)) + tmp ;

                                        if isNeg or ForceSign
                                        then begin
                                            tmp := SetSign(tmp, isNeg, longueurDebut, Remplissage) ;
                                        end ;
                                    end ;

                                    ResultFunction := ResultFunction + tmp ;
                                end
                            end
                            else if TypeData = 'f'
                            then begin
                                if isFloat(arguments[index])
                                then begin
                                    tmp := extractIntPart(arguments[index]) ;
                                    tmp2 := extractFloatPart(arguments[index]) ;

                                    { Tronque la partie flottante }
                                    if LongueurFin > 0
                                    then
                                        tmp2 := '.' + Copy(tmp2, 1, LongueurFin)
                                    else
                                        { si la précision est à 0 on n'affiche même pas le . }
                                        tmp2 := '' ;

                                    if Length(tmp2) < LongueurFin
                                    then
                                        tmp2 := tmp2 + RepeterCaractere('0', LongueurFin - Length(tmp2)) ;

                                    if AlignerAGauche
                                    then begin
                                        if ForceSign
                                        then begin
                                            if tmp[1] <> '-'
                                            then
                                                tmp := '+' + tmp ;
                                        end ;

                                        tmp := tmp + tmp2 + RepeterCaractere(Remplissage, LongueurDebut - (length(tmp) + length(tmp2)))
                                    end
                                    else begin
                                        isNeg := False ;

                                        if tmp <> ''
                                        then begin
                                            if tmp[1] = '-'
                                            then begin
                                                isNeg := True ;
                                                tmp := copy(tmp, 2, length(tmp) - 1) ;
                                            end ;
                                        end ;

                                        tmp := RepeterCaractere(Remplissage, LongueurDebut - Length(tmp) - Length(tmp2)) + tmp + tmp2 ;

                                        if isNeg or ForceSign
                                        then begin
                                            tmp := SetSign(tmp, isNeg, longueurDebut, Remplissage) ;
                                        end ;
                                    end ;

                                    ResultFunction := ResultFunction + tmp ;
                                end ;
                            end
                            else if TypeData = 's'
                            then begin
                                tmp := arguments[index] ;

                                tmp := Copy(arguments[index], 1, LongueurFin) ;

                                if AlignerAGauche
                                then
                                    tmp := tmp + RepeterCaractere(Remplissage, LongueurDebut)
                                else begin
                                    tmp := RepeterCaractere(Remplissage, LongueurDebut - Length(tmp)) + tmp ;
                                end ;

                                ResultFunction := ResultFunction + tmp ;
                            end
                            else if (TypeData = 'x') or (TypeData = 'X')
                            then begin
                                if isFloat(arguments[index])
                                then begin
                                    tmp := ExtractIntPart(arguments[index]) ;

                                    tmp := DecToHex(MyStrToInt(tmp)) ;

                                    if AddBefore
                                    then
                                        tmp := '0x' + tmp ;

                                    if TypeData = 'X'
                                    then
                                        tmp := UpperCase(tmp) ;

                                    if AlignerAGauche
                                    then
                                        tmp := tmp + RepeterCaractere(Remplissage, LongueurDebut)
                                    else begin
                                        tmp := RepeterCaractere(Remplissage, LongueurDebut - Length(tmp)) + tmp ;
                                    end ;

                                    ResultFunction := ResultFunction + tmp ;
                                end
                            end
                            else if (TypeData = 'o') or (TypeData = 'b')
                            then begin
                                if isFloat(arguments[index])
                                then begin
                                    tmp := ExtractIntPart(arguments[index]) ;

                                    if (TypeData = 'o')
                                    then begin
                                        tmp := DecToOct(MyStrToInt(tmp)) ;

                                        if AddBefore
                                        then
                                            tmp := '0' + tmp ;
                                    end
                                    else
                                        tmp := DecToBin(MyStrToInt(tmp)) ;

                                    if AlignerAGauche
                                    then
                                        tmp := tmp + RepeterCaractere(Remplissage, LongueurDebut)
                                    else begin
                                        tmp := RepeterCaractere(Remplissage, LongueurDebut - Length(tmp)) + tmp ;
                                    end ;

                                    ResultFunction := ResultFunction + tmp ;
                                end
                            end
                            else if TypeData = 'e'
                            then begin
                                if isFloat(arguments[index])
                                then begin
                                    { Est-ce une partie fractionnaire ? }
                                    tmpFloat := Abs(MyStrToFloat(arguments[index])) ;

                                    if tmpFloat < 1
                                    then begin
                                        { Si le nombre est inférieur à 1 on affichera en xxxE-xxx}
                                        if tmpFloat <> 0
                                        then begin
                                            Indice := '-' ;

                                            tmpInt := 0 ;

                                            while tmpFloat < 1 do
                                            begin
                                                OverTimeAndMemory ;
                                                if GlobalError
                                                then
                                                    break ;

                                                tmpFloat := tmpFloat * 10 ;
                                                Inc(tmpInt) ;
                                            end ;

                                            arguments[index] := MyFloatToStr(tmpFloat) ;

                                        end
                                        else begin
                                            Indice := '+' ;
                                            tmpInt := 0 ;
                                        end ;
                                    end
                                    else begin
                                        { Si le nombre est supérieur à 1 on affichera le nombre en xxxE+xx}
                                        Indice := '+' ;

                                        { On arrondi la virgule et obtient un entier }
                                        tmpInt := Round(MyStrToFloat(arguments[index])) ;

                                        tmp := IntToStr(tmpInt) ;

                                        { calculer le nombre d'élément après la virgule }
                                        tmpInt := Length(tmp) - LongueurFin ;

                                        { On insère la virgule pour obtenir un nombre en x.xxxx }
                                        if tmp[1] = '-'
                                        then
                                            Insert('.', tmp, 3)
                                        else
                                            Insert('.', tmp, 2) ;

                                        { Convertit en float pour arrondir }
                                        tmpFloat := MyStrToFloat(tmp) ;
                                        tmpFloat := RoundTo(tmpFloat, -1 * LongueurFin) ;

                                        { force le séparateur décimal à '.' }
                                        DecimalSeparator := '.' ;

                                        arguments[index] := FloatToStr(tmpFloat) ;
                                    end ;

                                    { Construit la partie exposant xxE-/+ }
                                    tmp3 := 'e' + Indice + IntToStr(tmpInt) ;

                                    { Sépare la partie floattant de la partie entiere }
                                    tmp := extractIntPart(arguments[index]) ;
                                    tmp2 := extractFloatPart(arguments[index]) ;

                                    { Tronque la partie flottante }
                                    tmp2 := Copy(tmp2, 1, LongueurFin) ;

                                    if Length(tmp2) < LongueurFin
                                    then
                                        tmp2 := tmp2 + RepeterCaractere('0', LongueurFin - Length(tmp2)) ;

                                    if AlignerAGauche
                                    then begin
                                        if ForceSign
                                        then begin
                                            if tmp[1] <> '-'
                                            then
                                                tmp := '+' + tmp ;
                                        end ;
                                                                            
                                        tmp := tmp + '.' + tmp2 + tmp3 + RepeterCaractere(Remplissage, LongueurDebut - (length(tmp) + length(tmp2) + 1 + Length(tmp3)))
                                    end
                                    else begin
                                        isNeg := False ;

                                        if tmp <> ''
                                        then begin
                                            if tmp[1] = '-'
                                            then begin
                                                isNeg := True ;
                                                tmp := copy(tmp, 2, length(tmp) - 1) ;
                                            end ;
                                        end ;

                                        tmp := RepeterCaractere(Remplissage, LongueurDebut - Length(tmp) - Length(tmp2) - 1 - Length(tmp3)) + tmp + '.' + tmp2 + tmp3 ;

                                        if isNeg or ForceSign
                                        then begin
                                            tmp := SetSign(tmp, isNeg, longueurDebut, Remplissage) ;
                                        end ;
                                    end ;

                                    ResultFunction := ResultFunction + tmp ;
                                end ;
                            end ;                            
                        end
                        else begin
                            ErrorMsg(sTooArguments) ;
                            break ;
                        end ;

                        Inc(Index) ;
                    end
                    else begin
                        ResultFunction := ResultFunction + '%' ;
                    end ;
                end ;
            end
            else begin
                ResultFunction := resultFunction + Text[i] ;
            end ;

            Inc(i) ;
        end ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
end ;

procedure strBase64EncodeCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := Encode64(arguments[0]) ;
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

procedure strBase64DecodeCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := Decode64(arguments[0]) ;
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

procedure strSoundExCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := soundex(arguments[0]) ;
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

procedure strUcFirstCommande(arguments : TStringList) ;
var index : Integer ;
begin
    if arguments.count = 1
    then begin
        index := 1 ;

        if length(arguments[0]) > 0
        then begin
            while (arguments[0][index] = ' ') or (arguments[0][index] = #9) do
            begin
                Inc(Index) ;
            end ;

            ResultFunction := arguments[0] ;
            ResultFunction[index] := UpperChar(ResultFunction[index]) ;
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

procedure strUcWordsCommande(arguments : TStringList) ;
var index : Integer ;
    len : Integer ;
begin
    if arguments.count = 1
    then begin
        index := 1 ;
        ResultFunction := arguments[0] ;
        len := length(arguments[0]) ;

        while index < len do
        begin
            while (arguments[0][index] = ' ') or (arguments[0][index] = #9) do
            begin
                Inc(Index) ;

                if Index > len
                then
                    break ;
            end ;

            ResultFunction[index] := UpperChar(ResultFunction[index]) ;

            while (arguments[0][index] <> ' ') and (arguments[0][index] <> #9) do
            begin
                Inc(Index) ;

                if Index > len
                then
                    break ;                
            end ;
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

procedure strtrCommande(arguments : TStringList) ;
var Liste1, Liste2 : TStringList ;
    i : Integer ;
    modifiedstring : String ;
    len : Integer ;
    Str : String ;
begin
    if arguments.count = 3
    then begin
        Liste1 := TStringList.Create ;
        Liste2 := TStringList.Create ;

        if Variables.InternalisArray(arguments[1])
        then
            Variables.explode(Liste1, arguments[1])
        else begin
            for i := 1 to Length(arguments[1]) do
            begin
                Liste1.Add(arguments[1][i]) ;
            end ;
        end ;

        if Variables.InternalisArray(arguments[2])
        then
            Variables.explode(Liste2, arguments[2])
        else begin
            len := length(arguments[2]) ;

            for i := 1 to Length(arguments[1]) do
            begin
                { On vérifie qu'on a pas plus d'élément dans liste1 que dans
                  liste2 }
                if i <= len
                then
                    Liste2.Add(arguments[2][i])
                else
                    Liste2.Add('') ;
            end ;
        end ;

        Str := arguments[0] ;

        modifiedstring := RepeterCaractere('0', Length(Str)) ;

        for i := 0 to Liste1.Count - 1 do
        begin
            ReplaceOneOccurenceOnce(Liste1[i], Str, Liste2[i], modifiedstring) ;
        end ;

        ResultFunction := Str ;

        Liste1.Free ;
        Liste2.Free ;
    end
    else if arguments.count < 3
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 3
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure strrevCommande(arguments : TStringList) ;
var i, len : Integer ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := '' ;
        len := Length(arguments[0]) ;

        for i := len downto 1 do
        begin
            ResultFunction := ResultFunction + arguments[0][i] ;
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

procedure configParameter(var start : integer; var len : integer; var search : TStringList; arguments : TStringList) ;
var i : Integer ;
begin
    if arguments.count > 2
    then
        start := MyStrToInt(arguments[2])
    else
        start := 1 ;

    if arguments.count > 3
    then
        len := MyStrToInt(arguments[3])
    else
        len := length(arguments[0]) ;

    if Variables.InternalIsArray(arguments[1])
    then begin
        Variables.Explode(search, arguments[1]) ;
    end
    else begin
        for i := 1 to length(arguments[1]) do
        begin
            search.add(arguments[1][i]) ;
        end ;
    end ;
end ;

procedure strcspnCommande(arguments : TStringList) ;
var start, len, longueur, maxlongueur, i : integer ;
     search : TStringList ;
begin
    if (arguments.count > 1) and (arguments.count < 5)
    then begin
        search := TStringList.create ;
        maxlongueur := 0 ;
        longueur := 0 ;
        len := 0 ;
        start := 0 ;

        configParameter(start, len, search, arguments) ;

        for i := start to len do
        begin
            if search.IndexOf(arguments[0][i]) = -1
            then begin
                Inc(longueur) ;
            end
            else begin
                longueur := 0 ;
            end ;

            if longueur > MaxLongueur
            then
                MaxLongueur := Longueur ;
        end ;

        ResultFunction := IntToStr(MaxLongueur) ;

        search.Free ;
    end
    else if arguments.count < 2
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 4
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure strspnCommande(arguments : TStringList) ;
var start, len, longueur, maxlongueur, i : integer ;
     search : TStringList ;
begin
    if (arguments.count > 1) and (arguments.count < 5)
    then begin
        search := TStringList.create ;
        maxlongueur := 0 ;
        longueur := 0 ;
        len := 0 ;
        start := 0 ;
        
        configParameter(start, len, search, arguments) ;

        for i := start to len do
        begin
            if search.IndexOf(arguments[0][i]) <> -1
            then begin
                Inc(longueur) ;
            end
            else begin
                longueur := 0 ;
            end ;

            if longueur > MaxLongueur
            then
                MaxLongueur := Longueur ;
        end ;

        ResultFunction := IntToStr(MaxLongueur) ;

        search.Free ;
    end
    else if arguments.count < 2
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 4
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure replaceAccentCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := ReplaceAccent(arguments[0]) ;
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

procedure strNumberFormatCommande(arguments : TStringList) ;
var i, nb, position : Integer ;
    separateur_float, separateur_millier : String ;

begin
    if (arguments.count > 0) and (arguments.count < 4)
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := '' ;

            if arguments.count > 1
            then
                separateur_float := arguments[1]
            else
                separateur_float := FloatSeparator ;

            if arguments.count > 2
            then
                separateur_millier := arguments[2]
            else
                separateur_millier := MillierSeparator ;


            position := pos('.', arguments[0]) ;
            
            { S'il y a une partie floattante }
            if position <> 0
            then begin
                for i := Length(arguments[0]) downto position + 1 do
                begin
                    ResultFunction := arguments[0][i] + ResultFunction ;
                end ;
                
                ResultFunction := separateur_float + ResultFunction ;
            end
            else begin
                position := Length(arguments[0]) ;
            end ;

            nb := 1 ;

            for i := position - 1 downto 1 do
            begin
                if (nb mod 4) = 0
                then begin
                    ResultFunction := separateur_millier + ResultFunction ;
                    Nb := 1 ;
                end ;

                ResultFunction := arguments[0][i] + ResultFunction ;    
                Inc(Nb) ;
            end ;
        end
        else begin
            WarningMsg(sMustBeFloat ) ;
        end ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 3
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure StrFunctionsInit ;
begin
    ListFunction.Add('echo', @echoCommande, true) ;
    ListFunction.Add('die', @dieCommande, true) ;
    ListFunction.Add('struppercase', @struppercaseCommande, true) ;
    ListFunction.Add('strlowercase', @strlowercaseCommande, true) ;
    ListFunction.Add('strcopy', @strcopyCommande, true) ;
    ListFunction.Add('strpos', @strposCommande, true) ;
    ListFunction.Add('stripos', @striposCommande, true) ;
    ListFunction.Add('strrpos', @strrposCommande, true) ;
    ListFunction.Add('strripos', @strriposCommande, true) ;
    ListFunction.Add('strtrim', @strtrimCommande, true) ;
    ListFunction.Add('strtrimleft', @strtrimleftCommande, true) ;
    ListFunction.Add('strtrimright', @strtrimrightCommande, true) ;

    ListFunction.Add('strreplace', @strreplaceCommande, false) ;
    ListFunction.Add('strireplace', @strreplaceCommande, false) ;    

    ListFunction.Add('strinsert', @strinsertCommande, true) ;
    ListFunction.Add('strdelete', @strdeleteCommande, true) ;
    ListFunction.Add('strexplode', @strexplodeCommande, true) ;
    ListFunction.Add('strimplode', @strimplodeCommande, true) ;
    ListFunction.Add('strloadfromfile', @strLoadFromFileCommande, true) ;
    ListFunction.Add('strsavetofile', @strSaveToFileCommande, true) ;
    ListFunction.Add('straddslashes', @strAddSlashesCommande, true) ;
    ListFunction.Add('strdeleteslashes', @strDeleteSlashesCommande, true) ;

    ListFunction.Add('strprintr', @strPrintRCommande, false) ;

    ListFunction.Add('strprintf', @strPrintFCommande, true) ;
    ListFunction.Add('strrepeatstring', @strRepeatStringCommande, true) ;
    ListFunction.Add('strbase64encode', @strBase64EncodeCommande, true) ;
    ListFunction.Add('strbase64decode', @strBase64DecodeCommande, true) ;
    ListFunction.Add('strsoundex', @strSoundExCommande, true) ;
    ListFunction.Add('strucfirst', @strUcFirstCommande, true) ;
    ListFunction.Add('strucwords', @strUcWordsCommande, true) ;
    ListFunction.Add('strtr', @strtrCommande, true) ;
    ListFunction.Add('strrev', @strrevCommande, true) ;
    ListFunction.Add('strcspn', @strcspnCommande, true) ;
    ListFunction.Add('strspn', @strspnCommande, true) ;
    ListFunction.Add('strreplaceaccent', @replaceAccentCommande, true) ;
    ListFunction.Add('strnumberfloat', @strNumberFormatCommande, true) ;    
end ;

end.
