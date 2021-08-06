unit UnitCore;
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
 * This unit containt core function :
 *   GOTO
 *   ISSET
 *   SET
 *   UNSET
 *   PROCEDURE
 *   ISNUMERIC
 *   ISFLOAT
 *   ISINTEGER
 *   ISSTRING
 *   ISARRAY
 *   EXIT 
 *   IF/ELSE/ENDIF
 *   WHILE/ENDWHILE
 *   REPEAT/UNTIL
 *   FOR/ENDFOR
 *   BREAK
 *   LENGTH
 *   ARRAYPUSH
 *   ARRAYINSERT
 *   ARRAYPOP
 *   ARRAYEXCHANGE
 *   ARRAYCHUNK
 *   ARRAYMERGE
 *   ARRAYFILL
 *   GLOBAL
 *   ISHEXA
 *   SWITCH
 *   COUNT
 *   EXTENSIONLOAD
 *   EXTENSIONUNLOAD
 *   ISEXTENSIONLOADED
 *   EVAL
 *   GETCOOKIE
 *
 *   DisabelFunction
 ******************************************************************************}

interface

{$I config.inc}

{$IFDEF FPC}
    {$mode objfpc}{$H+}
{$ENDIF}

uses SysUtils, UnitMessages, InternalFunction, classes, Extension, UnitOS,
     GetPostCookieFileData, Constantes ;

procedure CoreFunctionsInit ;

procedure setCommande(aoArguments : TStringList) ;
procedure unSetCommande(aoArguments : TStringList) ;
procedure isSetCommande(aoArguments : TStringList) ;
procedure LengthCommande(aoArguments : TStringList) ;
function FunctionCommande(aoArguments : TStringList) : Integer ;
function ifCommande(aoArguments : TStringList) : Integer ;
function WhileCommande(aoArguments : TStringList) : Integer ;
function RepeatUntilCommande(aoArguments : TStringList) : Integer ;
function ForCommande(aoArguments : TStringList) : Integer ;
procedure isIntegerCommande(aoArguments : TStringList) ;
procedure isFloatCommande(aoArguments : TStringList) ;
procedure isNumericCommande(aoArguments : TStringList) ;
procedure isStringCommande(aoArguments : TStringList) ;
procedure isArrayCommande(aoArguments : TStringList) ;
procedure arrayPushCommande(aoArguments : TStringList) ;
procedure arrayInsertCommande(aoArguments : TStringList) ;
procedure arrayPopCommande(aoArguments : TStringList) ;
procedure arrayExchangeCommande(aoArguments : TStringList) ;
procedure arrayChunkCommande(aoArguments : TStringList) ;
procedure arrayMergeCommande(aoArguments : TStringList) ;
procedure arrayFillCommande(aoArguments : TStringList) ;
procedure arraySortCommande(aoArguments : TStringList) ;
procedure GlobalCommande(aoArguments : TStringList) ;
procedure isHexaCommande(aoArguments : TStringList) ;
procedure functionExistsCommande(aoArguments : TStringList) ;
procedure functionDeleteCommande(aoArguments : TStringList) ;
procedure functionRenameCommande(aoArguments : TStringList) ;
function  GotoNextEndSwitch(aoCode : TStringList; aiPosition : Integer) : Integer ;
function  GotoNextCaseOrEndSwitch(aoCode : TStringList; aiPosition : Integer) : Integer ;
function  SwitchCommande(aoArguments : TStringList) : Integer ;
procedure loadCommande(aoArguments : TStringList) ;
procedure GetCookieCommande(aoArguments : TStringList) ;
procedure FunctionDisabled(aoArguments : TStringList) ;
procedure includeCommande(aoArguments : TStringList) ;
procedure arrayrSortCommande(aoArguments : TStringList) ;
procedure arrayRevCommande(aoArguments : TStringList) ;
procedure arrayShiftCommande(aoArguments : TStringList) ;
procedure arraySpliceCommande(aoArguments : TStringList) ;
procedure arrayShuffleCommande(aoArguments : TStringList) ;
procedure DefineCommande(aoArguments : TStringList) ;
procedure DefinedCommande(aoArguments : TStringList) ;
procedure TrueCommande(aoArguments : TStringList) ;
procedure FalseCommande(aoArguments : TStringList) ;
procedure ListShuffle(aoList : TStrings) ;
function LoadExtension(asNameOfExt : String) : boolean ;
procedure UnLoadExtension(asNameOfExt : String) ;
function IsExtensionLoaded(asNameOfExt : String) : Boolean ;
function FindEndBoucle(aoCode : TStringList; aiPosition : Integer) : Integer ;
function FindEndLoop(aoCode : TStringList; aiPosition : Integer) : Integer ;
function getEndIf(aoCode : TStringList; aiPosition : Integer) : Integer ;
function getElseIfElseEndIf(aoCode : TStringList; aiPosition : Integer) : Integer ;

implementation

uses Variable, Functions, Code, UserFunction, IntegerList ;

{*****************************************************************************
 * ListShuffle
 * MARTINEAU Emeric
 *
 * Trie un liste en ordre aléatoire
 *
 * Paramètres d'entrée :
 *   - aoList : liste à mélanger,
 *
 * Paramètre de sortie :
 *   - aoList : liste mélangée
 *
 * Retour : position de la sous chaine
 *****************************************************************************}
procedure ListShuffle(aoList : TStrings) ;
var
    { Nouvelle liste }
    loNewList : TStringList ;
    { Compteur de boucle }
    liIndexList : Integer ;
    { Longueur de la liste }
    liLength : Integer ;
    { Index de aoList à reporter dans loNewList }
    liIndex : Integer ;
begin
    loNewList := TStringList.Create ;

    Randomize ;

    liLength := aoList.Count - 1 ;

    for liIndexList := 0 to liLength do
    begin
        liIndex := random(aoList.Count) ;
        loNewList.Add(aoList[liIndex]) ;
        aoList.Delete(liIndex);
    end ;

    FreeAndNil(aoList) ;

    aoList := loNewList ;
end ;

{*****************************************************************************
 * LoadExtension
 * MARTINEAU Emeric
 *
 * Charge une extension
 *
 * Paramètres d'entrée :
 *   - asNameOfExt : Nom de l'extension
 *
 * Retour : true si chargée
 *****************************************************************************}
function LoadExtension(asNameOfExt : String) : boolean ;
var
    { Procedure Execute }
    lProc : TProcExt ;
    { Procedure Result }
    lProcResult : TProcResult ;
    { Procedure Init }
    lProcInit : TProcInit ;
    { Handle de la DLL }
    liHandleOfExt : Integer ;
    { Variable recevant les paramètres pour initialisation de l'extension }
    lsInitDocRoot : String ;
    lsInitTmpDir : String ;
    lbInitSafeMode : Boolean ;
begin
    lProc := nil ;
    lProcResult := nil ;
    lProcInit := nil ;
    liHandleOfExt := 0 ;

    Result := False ;

    if not goListOfExtension.isExists(asNameOfExt)
    then begin
        OsLoadExtension(asNameOfExt, liHandleOfExt, lProc, lProcResult, lProcInit) ;

        if (@lProc <> nil) and (@lProcResult <> nil) and (@lProcInit <> nil)
        then begin
            {$IFDEF FPC}
            goListOfExtension.Add(asNameOfExt, liHandleOfExt, lProc, lProcResult) ;
            {$ELSE}
            goListOfExtension.Add(asNameOfExt, liHandleOfExt, @lProc, @lProcResult) ;
            {$ENDIF}

            { On recopie les répertoires afin d'enpêcher toutes modifications.
              L'extension devra alors recopier les paramètres. On désactive
              l'optimisation pour qu'il ne supprime pas les variables locales }
            {$O-}
            lsInitDocRoot := Copy(gsDocRoot, 1, length(gsDocRoot)) ;
            lsInitTmpDir := Copy(gsTmpDir, 1, length(gsTmpDir)) ;
            lbInitSafeMode := gbSafeMode ;

            lProcInit(PChar(lsInitDocRoot), PChar(lsInitTmpDir), lbInitSafeMode) ;
            {$O+}

            Result := True ;
        end
        else begin
            OsUnLoadExtension(asNameOfExt) ;
        end ;
    end
    else begin
        Result := True ;
    end ;
end ;

{*****************************************************************************
 * UnLoadExtension
 * MARTINEAU Emeric
 *
 * Décharge une extension
 *
 * Paramètres d'entrée :
 *   - asNameOfExt : Nom de l'extension
 *
 *****************************************************************************}
procedure UnLoadExtension(asNameOfExt : String) ;
begin
    OsUnLoadExtension(asNameOfExt) ;

    goListOfExtension.DeleteByName(asNameOfExt);
end ;

{*****************************************************************************
 * IsExtensionLoaded
 * MARTINEAU Emeric
 *
 * Indique si une extension est chargée
 *
 * Paramètres d'entrée :
 *   - asNameOfExt : Nom de l'extension
 *
 * Retour : true si l'extension chargée
 *****************************************************************************}
function IsExtensionLoaded(asNameOfExt : String) : Boolean ;
var
    { Procédure exécute }
    lProc : TProcExt ;
    { Handle de la DLL }
    liHandleOfExt : Integer ;
begin
    liHandleOfExt := -1 ;
    lProc := nil ;

    goListOfExtension.Give(asNameOfExt, liHandleOfExt, lProc) ;

    Result := False ;

    if @lProc <> nil
    then begin
        Result := True ;
    end ;
end ;

procedure setCommande(aoArguments : TStringList) ;
var
    { Nom de la variable }
    lsVariableName : string ;
begin
    if aoArguments.Count > 0
    then begin
        lsVariableName := aoArguments[0] ;

        if isVar(lsVariableName)
        then begin
            { supprime la variable }
            aoArguments.Delete(0);

            if GetValueOfStrings(aoArguments) = 1
            then begin
                SetVar(lsVariableName, aoArguments[0]) ;
            end
            else begin
                ErrorMsg(csMissingOperator) ;
            end ;
        end
        else begin
            ErrorMsg(Format(csNotAVariable ,[lsVariableName])) ;
        end ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure unSetCommande(aoArguments : TStringList) ;
var
    { Index de la variable dan la liste de variable }
    liIndex : Integer ;
begin
    if aoArguments.count > 0
    then begin
        for liIndex := 0 to aoArguments.count - 1 do
        begin
             if isVar(aoArguments[liIndex])
             then begin
                 delVar(aoArguments[liIndex]) ;
             end
             else begin
                 ErrorMsg(Format(csNotAVariable ,[aoArguments[liIndex] ])) ;
             end ;
        end ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure isSetCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count > 0
    then begin
        if aoArguments.count < 2
        then begin
            if isVar(aoArguments[0])
            then begin
                if isSetVar(aoArguments[0])
                then begin
                    gsResultFunction := csTrueValue ;
                end
                else begin
                    gsResultFunction := csFalseValue ;
                end ;
            end
            else begin
                ErrorMsg(Format(csNotAVariable, [aoArguments[0]])) ;
            end ;
        end
        else begin
            ErrorMsg(csTooArguments) ;
        end ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure LengthCommande(aoArguments : TStringList) ;
begin
    if aoArguments.Count = 1
    then begin
        gsResultFunction := IntToStr(System.length(aoArguments[0])) ;
    end
    else if aoArguments.Count > 1
    then begin
        ErrorMsg(csTooArguments)
    end    
    else begin
        ErrorMsg(csMissingArgument) ;
    end ;
end ;

function FunctionCommande(aoArguments : TStringList) : Integer ;
var
    { Index de ligne }
    liIndex : Integer ;
    { Commande = function/endfunc }
    lsCommande : String ;
    { Position de début de la fonction }
    liStartPos : Integer ;
begin
    Result := -1 ;

    {$IFDEF FPC}
    if (goListProcedure.Give(aoArguments[1]) = -1) and (goInternalFunction.Give(aoArguments[1]) = nil)
    {$ELSE}
    if (ListProcedure.Give(aoArguments[1]) = -1) and (@goInternalFunction.Give(aoArguments[1]) = nil)
    {$ENDIF}
    then begin
        if IsKeyWord(aoArguments[1])
        then begin
            ErrorMsg(Format(csReservedWord, [aoArguments[1]]))
        end
        else begin
            liStartPos := giCurrentLineNumber + 1 ;

            { Va à la fin de procedure }
            for liIndex := giCurrentLineNumber + 1 to goCodeList.Count - 1 do
            begin
                lsCommande := extractCommande(goCodeList[liIndex]) ;

                if lsCommande = 'endfunc'
                then begin
                    Result := liIndex ;
                    break ;
                end
                else if lsCommande = 'function'
                then begin
                    break ;
                end ;
            end ;

            if Result = -1
            then begin
                ErrorMsg(csNoEndProc) ;
            end
            else begin
                lsCommande := aoArguments[1] ;

                { Supprime function }
                aoArguments.Delete(0);
                { Supprime nom de la fonction }
                aoArguments.Delete(0);

                DeleteVirguleAndParenthese(aoArguments) ;

                goListProcedure.Add(lsCommande, liStartPos, Result - 1, aoArguments.text) ;
            end ;
        end ;
    end
    else begin
        ErrorMsg(Format(csProcedureAlreadyExist, [aoArguments[1]])) ;
    end ;
end ;

{*****************************************************************************
 * GetEndIF
 * MARTINEAU Emeric
 *
 * Retourne la position du EndIf associé au If dont la position + 1 est 
 * passée en paramètre.
 *
 * Paramètres d'entrée :
 *   - aoCode : code dans lequel il faut chercher,
 *   - aiPosition : position de départ de la recherche
 *
 * Retour : position du EndIf
 *****************************************************************************}
function GetEndIf(aoCode : TStringList; aiPosition : Integer) : Integer ;
var
    { Commande if/endif }
    lsCommande : String ;
begin
    Result := aiPosition ;
    
    while aiPosition < aoCode.count do
    begin
        lsCommande := extractCommande(aoCode[aiPosition]) ;

        if lsCommande = 'if'
        then begin
            aiPosition := GetEndIf(aoCode, aiPosition + 1) + 1 ;
        end
        else begin
            if lsCommande = 'endif'
            then begin
                Result := aiPosition ;
                break ;
            end ;

            Inc(aiPosition) ;
        end ;
    end ;
end ;

{*****************************************************************************
 * GetElseIfElseEndIf
 * MARTINEAU Emeric
 *
 * Retourne la position + 1 du EndIf/ElseIf/Else associé au If dont la position
 *  + 1 est passée en paramètre.
 *
 * Paramètres d'entrée :
 *   - aoCode : code dans lequel il faut chercher,
 *   - aiPosition : position de départ de la recherche
 *
 * Retour : position du EndIf
 *****************************************************************************}
function GetElseIfElseEndIf(aoCode : TStringList; aiPosition : Integer) : Integer ;
var
    { Commande = if/else/elseif/endif }
    lsCommande : String ;
begin
    Result := aiPosition ;
    
    while aiPosition < aoCode.count do
    begin
        lsCommande := extractCommande(aoCode[aiPosition]) ;

        if lsCommande = 'if'
        then begin
            aiPosition := GetEndIf(aoCode, aiPosition + 1) + 1 ;
        end
        else begin
            if (lsCommande = 'elseif') or (lsCommande = 'else') or (lsCommande = 'endif')
            then begin
                Result := aiPosition ;
                break ;
            end ;

            Inc(aiPosition) ;
        end ;
    end ;
end ;

function ifCommande(aoArguments : TStringList) : Integer ;
var
    { Condition de fin }
    loEndCondition : TStringList ;
    { Nouvelle position dans le code }
    liNewLine : Integer ;
    { Position de la ligne de retour }
    liIndex : Integer ;
    { Indique si on est dans un ElseIf }
    lbIsElseIf : Boolean ;
    { Indique si on est dans un Else }
    lbIsElse : Boolean ;
    { Commande = endif/else/elseif }
    lsCommande : String ;
    { Condition de test du elseif }
    loTestElseIf : TStringList ;
begin
    aoArguments.Delete(0) ;
    Result := -1 ;
    lbIsElse := False ;
    loTestElseIf := TStringList.Create ;
    
    { Le denier argument est then on le supprime }
    if aoArguments.Count > 0
    then begin
        aoArguments.Delete(aoArguments.Count - 1) ;
    end ;
    
    if GetValueOfStrings(aoArguments) = 1
    then begin
        loEndCondition := TStringList.Create ;

        if aoArguments[0] = csFalseValue
        then begin
            loEndCondition.Add('endif') ;

            lbIsElseIf := False ;

            liIndex := giCurrentLineNumber + 1 ;

            while liIndex < goCodeList.Count do
            begin
                lsCommande := extractCommande(goCodeList[liIndex]) ;

                if lsCommande = 'if'
                then begin
                    liIndex := GetEndIf(goCodeList, liIndex + 1) ;
                end ;

                if lsCommande = 'endif'
                then begin
                    Result := liIndex ;
                    break ;
                end
                else if lsCommande = 'else'
                then begin
                    { + 1 pour pointer sur l'instruction suivante }
                    Inc(liIndex) ;
                    lbIsElse := True ;
                    break ;
                end
                else if lsCommande = 'elseif'
                then begin
                    lbIsElseIf := True ;
                    lbIsElse := True ;

                    ExplodeStrings(goCodeList[liIndex], loTestElseIf) ;

                    { supprime elseif }
                    loTestElseIf.Delete(0) ;

                    GetValueOfStrings(loTestElseIf) ;

                    if loTestElseIf[0] = csFalseValue
                    then begin
                        lbIsElseIf := False ;
                        lbIsElse := False ;

                        { se positionner au prochain elseif ou else ou endif}
                        liIndex := GetElseIfElseEndIf(goCodeList, liIndex + 1) - 1 ;
                    end
                    else begin
                        { + 1 pour pointer sur l'instruction suivante }
                        Inc(liIndex) ;
                        break ;
                    end ;
                end ;

                Inc(liIndex) ;
            end ;

            if lbIsElse
            then begin
                if lbIsElseIf
                then begin
                    loEndCondition.Add('else') ;
                    loEndCondition.Add('elseif') ;
                end ;

                Result := ReadCode(liIndex, loEndCondition, goCodeList) ;

                if (gbBreak = True) or (gbQuit = True)
                then begin
                    Result := 0
                end
                else if Result <> -1
                then begin
                    if lbIsElseIf
                    then begin
                        { Si c'est un elseif on doit pointer sur la ligne suivante }
                        Result := getEndIf(goCodeList, Result) + 1 ;
                    end ;

                    { On pointe sur la ligne suivante après le endif. Or dans
                      ReadCode, après la commande on fait un Inc(Line) }
                    Dec(Result) ;
                end ;
            end ;
        end
        else begin
            loEndCondition.Add('else') ;
            loEndCondition.Add('endif') ;

            liNewLine := ReadCode(giCurrentLineNumber + 1, loEndCondition, goCodeList) ;

            if (liNewLine > -1) and (gbQuit = False)
            then begin
                lsCommande := extractCommande(goCodeList[liNewLine - 1]) ;

                if gbBreak = True
                then begin
                    { on a un break dans un if. Or le if c'est un bloc à part. Il
                      faut donc sortir du bloc if et du bloc précédent }
                    Result := 0 ;
                end
                else if liNewLine <> -1
                then begin
                    Result := liNewLine - 1 ;

                    if lsCommande = 'else'
                    then begin
                        liIndex := giCurrentLineNumber + 1 ;

                        while liIndex < goCodeList.Count do
                        begin
                            lsCommande := extractCommande(goCodeList[liIndex]) ;

                            if lsCommande = 'if'
                            then begin
                                { -1 pour prendre en compte le endif }
                                liIndex := getEndIf(goCodeList, liIndex + 1) - 1 ;
                            end ;

                            if lsCommande = 'endif'
                            then begin
                                Result := liIndex ;
                                break ;
                            end ;

                            Inc(liIndex) ;
                        end ;
                    end ;
                end ;
            end ;
        end ;
        
        FreeAndNil(loEndCondition) ;
    end
    else begin
        ErrorMsg(csMissingOperator) ;
    end ;

    FreeAndNil(loTestElseIf) ;
end ;

function WhileCommande(aoArguments : TStringList) : Integer ;
var
    { Condition de fin }
    loEndCondition : TStringList ;
    { Memorise les conditions de départ pour l'évaluation à chaque itération }
    loCondition : TStringList ;
    { Position de la ligne de condition }
    liConditionLine : Integer ;
    { Position de la ligne de retour }
    liIndex : Integer ;
    { Commande = break/goto permet de savoir si on doit quitter la boucle while
      ou si on refait un itération }
    lsCommande : String ;
    { Position de fin de boucle }
    liPositionEndLoop : Integer ;
    { Label du while }
    lsWhileLabel : String ;
begin
    Result := -1 ;
    liPositionEndLoop := -1 ;
    aoArguments.Delete(0) ;
    loCondition := TStringList.Create ;
    loCondition.Text := aoArguments.Text ;

    { Le denier argument est do on le supprime }
    if (aoArguments.Count > 0)
    then begin
        aoArguments.Delete(aoArguments.Count - 1) ;
    end ;

    if GetValueOfStrings(aoArguments) = 1
    then begin
        loEndCondition := TStringList.Create ;
        loEndCondition.Add('endwhile') ;

        liConditionLine := giCurrentLineNumber ;

        lsWhileLabel := gsCurrentLabel ;
        
        while aoArguments[0] = csTrueValue do
        begin
            OverTimeAndMemory ;
            
            if gbQuit
            then begin
                break ;
            end ;

            liIndex := ReadCode(liConditionLine + 1, loEndCondition, goCodeList) ;

            { Si c'est un break qui déclanche la fin du code avec le
              label qui correspond à notre for ou si pas de label }
            if ((lsWhileLabel = gsCurrentLabel) or (gsCurrentLabel = ''))
            then begin
                if (gbBreak = True) or (gbContinue = True)
                then begin
                    gbQuit := False ;
                end ;
            end ;

            if (gbQuit = True)
            then begin
                break ;
            end ;

            if (gbContinue = False)
            then begin
                if (gbBreak = True)
                then begin
                    gbBreak := False ;

                    break ;
                end
                else if liPositionEndLoop = -1
                then begin
                    { Mémorise la position de fin de boucle si ce n'est pas
                      déjà fait
                      -1 car ReadCode renvoie la ligne d'après  }
                    liPositionEndLoop := liIndex - 1 ;
                end ;
            end
            else begin
                gbContinue := False ;
            end ;

            aoArguments.Text := loCondition.Text ;

            GetValueOfStrings(aoArguments) ;
        end ;

        if (liPositionEndLoop = -1) and (gbQuit = False)
        then begin
            Result := FindEndLoop(goCodeList, liConditionLine) ;
        end
        else begin
            Result := liPositionEndLoop ;
        end ;

        FreeAndNil(loEndCondition) ;
    end
    else begin
        ErrorMsg(csMissingOperatorOrValue) ;
    end ;
        
    FreeAndNil(loCondition) ;
end ;

function RepeatUntilCommande(aoArguments : TStringList) : Integer ;
var
    { Condition de fin }
    loEndCondition : TStringList ;
    { Position de la ligne de condition }
    liConditionLine : Integer ;
    { Position de la ligne de retour }
    liIndex : Integer ;
    { Commande break/goto }
    lsCommande : String ;
    { Position de fin de boucle }
    liPositionEndLoop : Integer ;
    { Label du while }
    lsRepeatLabel : String ;
begin
    loEndCondition := TStringList.Create ;
    loEndCondition.Add('until') ;
    
    liPositionEndLoop := -1 ;
    Result := - 1 ;

    liConditionLine := giCurrentLineNumber ;

    lsRepeatLabel := gsCurrentLabel ;

    repeat
        OverTimeAndMemory ;
        
        if gbQuit
        then begin
            break ;
        end ;
            
        liIndex := ReadCode(liConditionLine + 1, loEndCondition, goCodeList) ;

        { Si c'est un break qui déclanche la fin du code avec le
          label qui correspond à notre for ou si pas de label }
        if ((lsRepeatLabel = gsCurrentLabel) or (gsCurrentLabel = ''))
        then begin
            if (gbBreak = True)
            then begin
                gbQuit := False ;
            end
            else if (gbContinue = True)
            then begin
                gbContinue := False ;
                gbQuit := False ;

                { Dans le cas du repeat/until on n'a rien a faire autre que
                  trouver la fin de ligne }
                if liPositionEndLoop = -1
                then begin
                    { Dans notre cas, on ne passe pas dans ReadCode donc il faut
                      incrémenter.
                      +1 car fait pointer sur la ligne avant }
                    liPositionEndLoop := FindEndLoop(goCodeList, liConditionLine + 1) ;
                end ;

                { On doit initialiser pour tester, de plus liIndex est
                  décrémenté après }
                liIndex := liPositionEndLoop + 1 ;
            end ;
        end ;

        if (gbQuit = True)
        then begin
            break ;
        end ;

        if (gbBreak = True)
        then begin
            gbBreak := False ;

            break ;
        end
        else if liPositionEndLoop = -1
        then begin
            { Mémorise la position de fin de boucle si ce n'est pas
              déjà fait
              -1 car ReadCode renvoie la ligne d'après }
            liPositionEndLoop := liIndex - 1 ;
        end ;

        ExplodeStrings(goCodeList[liIndex - 1], aoArguments) ;

        aoArguments.Delete(0) ;

        { Evaluation de la condition }
        if GetValueOfStrings(aoArguments) <> 1
        then begin
            ErrorMsg(csMissingOperatorOrValue) ;

            break ;
        end ;
    until aoArguments[0] = csTrueValue ;

    if (liPositionEndLoop = -1) and (gbQuit = False)
    then begin
        Result := FindEndLoop(goCodeList, liConditionLine) ;
    end
    else begin
        Result := liPositionEndLoop ;
    end ;

    FreeAndNil(loEndCondition) ;
end ;

function ForCommande(aoArguments : TStringList) : Integer ;
var
    { Condition de fin }
    loEndCondition : TStringList ;
    { Position de la ligne de condition }
    liConditionLine : Integer ;
    { Position de la ligne de retour }
    liIndex : Integer ;
    { Variable compteur de foucle for du script }
    lsVariable : string ;
    { Valeur de début de la boucle for du script }
    liStartValue : Int64 ;
    { Valeur de fin de la boucle for du script }
    liEndValue : Int64 ;
    { Valeur d'incrément de la boucle for du script }
    liIncrement : Int64 ;
    { Indique s'il y a eu une erreur de paramètre }
    lbError : Boolean ;
    { Commande = break/goto }
    lsCommande : String ;
    { Position de fin de boucle }
    liPositionEndLoop : Integer ;
    { Nombre d'argument }
    liNumberOfArgument : Integer ;
    { Label du for }
    lsForLabel : String ;
begin
    Result := - 1 ;
    liPositionEndLoop := -1 ;

    { Le denier argument est do on le supprime }
    if (aoArguments.Count > 0)
    then begin
        aoArguments.Delete(aoArguments.Count - 1) ;
    end ;

    if aoArguments.Count > 4
    then begin
         lbError := True ;

         if isVar(aoArguments[1])
         then begin
             { supprime le for }
             aoArguments.Delete(0) ;

             lsVariable := aoArguments[0] ;

             { supprime la variable }
             aoArguments.Delete(0) ;

             if aoArguments[0] = '='
             then begin
                 { supprime le = }
                 aoArguments.Delete(0) ;

                 liNumberOfArgument := GetValueOfStrings(aoArguments) ;

                 if (liNumberOfArgument = 5) or (liNumberOfArgument = 3)
                 then begin
                     if isNumeric(aoArguments[0])
                     then begin
                         if aoArguments[1] = 'to'
                         then begin
                             if isNumeric(aoArguments[2])
                             then begin
                                 if (liNumberOfArgument = 5)
                                 then begin
                                     if aoArguments[3] = 'step'
                                     then begin
                                         if isNumeric(aoArguments[4])
                                         then begin
                                             lbError := False ;
                                         end
                                         else begin
                                             ErrorMsg(csIncValNotValidNum) ;
                                         end ;
                                     end
                                     else begin
                                          ErrorMsg(csMissingStep) ;
                                     end ;
                                 end
                                 else if (liNumberOfArgument = 3)
                                 then begin
                                     lbError := False ;
                                 end
                                 else begin
                                     lbError := False ;
                                 end ;
                             end
                             else begin
                                 ErrorMsg(csEndValNotValidNum) ;
                             end ;
                         end
                         else begin
                             ErrorMsg(csMissingTo) ;
                         end ;
                     end
                     else begin
                         ErrorMsg(csStartValNotValidNum) ;
                     end ;
                 end
                 else begin
                     ErrorMsg(csMissingOrTooArguments) ;
                 end ;
             end
             else begin
                 ErrorMsg(csMissingEqual) ;
             end ;

            if not lbError
            then begin
                {
                 0 = valeur de depart
                 1 = to
                 2 = valeur d'arrivée
                 3 = step
                 4 = incrément
                }
                liStartValue := MyStrToInt64(aoArguments[0]) ;
                liEndValue := MyStrToInt64(aoArguments[2]) ;

                if (liNumberOfArgument = 5)
                then begin
                    liIncrement := MyStrToInt64(aoArguments[4]) ;
                end
                else begin
                    liIncrement := 1 ;
                end ;

                loEndCondition := TStringList.Create ;
                loEndCondition.Add('endfor') ;

                liConditionLine := giCurrentLineNumber ;

                setVar(lsVariable, IntToStr(liStartValue)) ;

                lsForLabel := gsCurrentLabel ;

                while MyStrToInt64(getVar(lsVariable)) <= liEndValue do
                begin
                    OverTimeAndMemory ;

                    if gbQuit
                    then begin
                        break ;
                    end ;

                    liIndex := ReadCode(liConditionLine + 1, loEndCondition, goCodeList) ;

                    { Si c'est un break qui déclanche la fin du code avec le
                      label qui correspond à notre for ou si pas de label }
                    if ((lsForLabel = gsCurrentLabel) or (gsCurrentLabel = ''))
                    then begin
                        if (gbBreak = True) or (gbContinue = True)
                        then begin
                            gbQuit := False ;
                        end ;
                    end ;

                    if (gbQuit = True)
                    then begin
                        break ;
                    end ;

                    if (gbContinue = False)
                    then begin
                        if (gbBreak = True)
                        then begin
                            { On ne propage pas le break puisqu'il nous concerne }
                            gbBreak := False ;

                            break ;
                        end
                        else if liPositionEndLoop = -1
                        then begin
                            { Mémorise la position de fin de boucle si ce n'est pas
                              déjà fait
                              -1 car ReadCode renvoie la ligne d'après }
                            liPositionEndLoop := liIndex - 1 ;
                        end ;
                    end
                    else begin
                        gbContinue := False ;
                    end ;
                    
                    SetVar(lsVariable, IntToStr(MyStrToInt64(getVar(lsVariable)) + liIncrement)) ;
                end ;

                { Si on ne connait pas la position de la
                  fin de boucle }
                if (liPositionEndLoop = -1) and (gbQuit = False)
                then begin
                    { Si c'est un break on cherche la fin de boucle }
                    Result := FindEndLoop(goCodeList, liConditionLine) ;
                end
                else begin
                    Result := liPositionEndLoop ;
                end ;

                FreeAndNil(loEndCondition) ;
            end ;
         end
         else begin
             ErrorMsg(Format(csNotAVariable, [aoArguments[0]])) ;
         end ;

    end
    else begin
        ErrorMsg(csInvalidFor) ;
    end ;
end ;

{*****************************************************************************
 * FindEndBoucle
 * MARTINEAU Emeric
 *
 * Retour la position de la fin d'une boucle for/while/repeat
 *
 * Paramètres d'entrée :
 *   - aiCode : code à lire,
 *   - aiPosition : position de départ,
 *
 * Retour : position de la fin de boucle
 *****************************************************************************}
function FindEndBoucle(aoCode : TStringList; aiPosition : Integer) : Integer ;
Var
    { Index de boucle }
    liIndex : Integer ;
    { Commande lue }
    lsCommande : String ;
begin
    Result := -1 ;
    { se positionner à la fin de la boucle }
    liIndex := aiPosition ;

    while liIndex < aoCode.Count do
    begin
        lsCommande := extractCommande(aoCode[liIndex]) ;

        if (lsCommande = 'for') or (lsCommande = 'while') or (lsCommande = 'repeat')
        then begin
            liIndex := FindEndBoucle(aoCode, liIndex + 1)
        end
        else if (lsCommande = 'endfor') or (lsCommande = 'endwhile') or (lsCommande = 'until')
        then begin
            Result := liIndex ;
            break ;
        end ;

        Inc(liIndex) ;
    end
end ;

function FindEndLoop(aoCode : TStringList; aiPosition : Integer) : Integer ;
var
    { Pile de fin à trouver }
    loStackOfEndToFound : TStringList ;
    { Index de boucle }
    liIndex : Integer ;
    { Commande lue }
    lsCommande : String ;
    { Derniere position dans la liste }
    liLastPostStack : Integer ;
begin
    loStackOfEndToFound := TStringList.Create ;

    Result := -1 ;

    { -1 car la première commande fait + 1 }
    liLastPostStack := -1 ;

    { se positionner à la fin de la boucle }
    liIndex := aiPosition ;

    while liIndex < aoCode.Count do
    begin
        lsCommande := extractCommande(aoCode[liIndex]) ;

        if lsCommande = 'for'
        then begin
            loStackOfEndToFound.add('endfor') ;

            Inc(liLastPostStack) ;
        end
        else if lsCommande = 'while'
        then begin
            loStackOfEndToFound.add('endwhile') ;

            Inc(liLastPostStack) ;
        end
        else if lsCommande = 'repeat'
        then begin
            loStackOfEndToFound.add('until') ;

            Inc(liLastPostStack) ;
        end
        else if (lsCommande = 'endfor') or (lsCommande = 'endwhile') or (lsCommande = 'until')
        then begin
           if loStackOfEndToFound[liLastPostStack] = lsCommande
           then begin
               { On a trouver la fin qu'il fallait et on est sur le premier
                 élément, alors c'est la fin }
               if liLastPostStack = 0
               then begin
                   Result := liIndex ;

                   break ;
               end ;

               loStackOfEndToFound.Delete(liLastPostStack) ;

               Dec(liLastPostStack) ;
           end
           else begin
               ErrorMsg(Format(csNotFoundEndButFound, [loStackOfEndToFound[liLastPostStack], lsCommande]));
           end ;
        end ;

        Inc(liIndex) ;
    end ;

    if Result = -1
    then begin
        ErrorMsg(Format(csNotFoundEnd, [loStackOfEndToFound[liLastPostStack]]));
    end ;

    loStackOfEndToFound.Free ;
end ;

procedure isNumericCommande(aoArguments : TStringList) ;
begin
    GetValueOfStrings(aoArguments) ;

    if aoArguments.count > 0
    then begin
        if aoArguments.count < 2
        then begin
            if isNumeric(aoArguments[0])
            then begin
                gsResultFunction := csTrueValue
            end
            else begin
                gsResultFunction := csFalseValue ;
            end ;
        end
        else begin
            ErrorMsg(csTooArguments) ;
        end ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure isFloatCommande(aoArguments : TStringList) ;
begin
    GetValueOfStrings(aoArguments) ;

    if aoArguments.count > 0
    then begin
        if aoArguments.count < 2
        then begin
            if isFloat(aoArguments[0])
            then begin
                gsResultFunction := csTrueValue
            end
            else begin
                gsResultFunction := csFalseValue ;
            end ;
        end
        else begin
            ErrorMsg(csTooArguments) ;
        end ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure isIntegerCommande(aoArguments : TStringList) ;
begin
    GetValueOfStrings(aoArguments) ;

    if aoArguments.count > 0
    then begin
        if aoArguments.count < 2
        then begin
            if isInteger(aoArguments[0])
            then begin
                gsResultFunction := csTrueValue
            end
            else begin
                gsResultFunction := csFalseValue ;
            end ;
        end
        else begin
            ErrorMsg(csTooArguments) ;
        end ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure isStringCommande(aoArguments : TStringList) ;
begin
    GetValueOfStrings(aoArguments) ;

    if aoArguments.count > 0
    then begin
        if aoArguments.count < 2
        then begin
            if isFloat(aoArguments[0]) or goVariables.isArray(aoArguments[0])
            then begin
                gsResultFunction := csFalseValue ;
            end
            else begin
                gsResultFunction := csTrueValue ;
            end ;
        end
        else begin
            ErrorMsg(csTooArguments) ;
        end ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure isArrayCommande(aoArguments : TStringList) ;
begin
    GetValueOfStrings(aoArguments) ;

    if aoArguments.count > 0
    then begin
        if aoArguments.count < 2
        then begin
            if isVar(aoArguments[0])
            then begin
                { supprime la variable }
                aoArguments.Delete(0);

                if goVariables.isArray(aoArguments[0])
                then begin
                    gsResultFunction := csTrueValue ;
                end
                else begin
                    gsResultFunction :=  csFalseValue ;
                end
            end
            else begin
                ErrorMsg(Format(csNotAVariable, [aoArguments[0]])) ;
            end ;
        end
        else begin
            ErrorMsg(csTooArguments) ;
        end ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure arrayPushCommande(aoArguments : TStringList) ;
var
    { Nom du tableau }
    lsTableau : String ;
    { Compteur de boucle }
    liIndex : Integer ;
begin
    lsTableau := aoArguments[0] ;
    aoArguments.delete(0) ;

    GetValueOfStrings(aoArguments) ;

    if aoArguments.count > 1
    then begin
        if isVar(lsTableau)
        then begin
            for liIndex := 0 to aoArguments.Count - 1 do
            begin
                goVariables.Push(lsTableau, aoArguments[liIndex])
            end ;
        end
        else begin
            ErrorMsg(Format(csNotAVariable, [lsTableau])) ;
        end ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure arrayInsertCommande(aoArguments : TStringList) ;
var
    { Nom du tableau }
    lsTableau : String ;
begin
    lsTableau := aoArguments[0] ;
    aoArguments.delete(0) ;

    GetValueOfStrings(aoArguments) ;

    if aoArguments.count > 0
    then begin
        if aoArguments.count < 3
        then begin
            if isVar(lsTableau)
            then begin
                if goVariables.Insert(lsTableau, MyStrToInt(aoArguments[0]), aoArguments[1]) = False
                then begin
                    ErrorMsg(csCantInsertDataInArray) ;
                end ;
            end
            else begin
                ErrorMsg(Format(csNotAVariable, [lsTableau])) ;
            end ;
        end
        else begin
            ErrorMsg(csTooArguments) ;
        end ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure arrayPopCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count > 0
    then begin
        if aoArguments.count < 2
        then begin
            if isVar(aoArguments[0])
            then begin
                if not goVariables.isSet(aoArguments[0])
                then begin
                    WarningMsg(Format(csVariableDoesntExist, [aoArguments[0]])) ;
                end
                else begin
                    gsResultFunction := goVariables.Pop(aoArguments[0]) ;
                end ;                
            end
            else begin
                ErrorMsg(Format(csNotAVariable, [aoArguments[0]])) ;
            end ;
        end
        else begin
            ErrorMsg(csTooArguments) ;
        end ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure arrayExchangeCommande(aoArguments : TStringList) ;
var
    { Longueur du tableau }
    liLengthOfArray : Integer ;
    { 1er index du tableau à échanger }
    liIndex1 : Integer ;
    { 2ème index du tableau à échanger }
    liIndex2 : Integer ;
begin
    if aoArguments.count > 0
    then begin
        if aoArguments.count < 4
        then begin
            if isVar(aoArguments[0])
            then begin
                if isInteger(aoArguments[1])
                then begin
                    if isInteger(aoArguments[2])
                    then begin
                        liLengthOfArray := goVariables.length(aoArguments[0]) ;
                        liIndex1 := MyStrToInt(aoArguments[1]) ;
                        liIndex2 := MyStrToInt(aoArguments[2]) ;

                        if (liIndex1 <= liLengthOfArray) and (liIndex1 > 0)
                        then begin
                            if (liIndex2 <= liLengthOfArray) and (liIndex2 > 0)
                            then begin
                                if not goVariables.Exchange(aoArguments[0], liIndex1 - 1, liIndex2 - 1)
                                then begin
                                    ErrorMsg(csCanExchangeData);
                                end ;
                            end
                            else begin
                                ErrorMsg(csSndIndexOutBound);
                            end ;
                        end
                        else begin
                            ErrorMsg(csFirstIndexOutBound)
                        end ;
                    end
                    else begin
                        ErrorMsg(csSndMustInt)
                    end ;
                end
                else begin
                    ErrorMsg(csFirstMustInt)
                end ;
            end
            else begin
                ErrorMsg(Format(csNotAVariable, [aoArguments[0]])) ;
            end ;
        end
        else begin
            ErrorMsg(csTooArguments) ;
        end ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;


procedure arrayChunkCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count > 0
    then begin
        if aoArguments.count < 3
        then begin
            if isVar(aoArguments[0])
            then begin
                if isInteger(aoArguments[1])
                then begin
                    if not goVariables.Chunk(aoArguments[0], MyStrToInt(aoArguments[1]))
                    then begin
                        ErrorMsg(csCantChunk) ;
                    end ;
                end
                else begin
                    ErrorMsg(csSizeMustBeInt) ;
                end ;
            end
            else begin
                ErrorMsg(Format(csNotAVariable, [aoArguments[0]])) ;
            end ;
        end
        else begin
            ErrorMsg(csTooArguments) ;
        end ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure arrayMergeCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count > 0
    then begin
        gsResultFunction := goVariables.Merge(aoArguments)
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure arrayCreateCommande(aoArguments : TStringList) ;
begin
    // inutile d'appeler DeleteVirguleAndParenthese car appelé automatiquement
    // si dans fonction goInternalFunction()
    gsResultFunction := goVariables.CreateArray(aoArguments) ;
end ;

procedure ArrayFillCommande(aoArguments : TStringList) ;
var
    { Nom du tableau }
    lsTableau : string ;
begin
    if aoArguments.Count > 0
    then begin
        lsTableau := aoArguments[0] ;

        if isVar(lsTableau)
        then begin
            { supprime la variable }
            aoArguments.Delete(0);

            if GetValueOfStrings(aoArguments) = 1
            then begin
                goVariables.ArrayFill(lsTableau, aoArguments[0])
            end
            else begin
                ErrorMsg(csMissingOperator) ;
            end ;
        end
        else begin
            ErrorMsg(Format(csNotAVariable ,[lsTableau])) ;
        end ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure arraySortCommande(aoArguments : TStringList) ;
var
    { Résultat de la commande arraysort }
    lsResultat : string ;
begin
    if aoArguments.count > 0
    then begin
        if aoArguments.count < 2
        then begin
            lsResultat := aoArguments[0] ;
            
            if goVariables.arraySort(lsResultat)
            then begin
                gsResultFunction := lsResultat ;
            end
            else begin
                gsResultFunction := '' ;
                WarningMsg(csMustBeAnArray)
            end ;
        end
        else begin
            ErrorMsg(csTooArguments) ;
        end ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure arraySearchCommande(aoArguments : TStringList) ;
var
    { Résultat de la commande arraysearch }
    liResultat : Integer ;
begin
    if aoArguments.count > 0
    then begin
        if aoArguments.count < 4
        then begin
            liResultat := goVariables.arraySearch(aoArguments[0], aoArguments[1], aoArguments[2] = csTrueValue) ;

            gsResultFunction := IntToStr(liResultat) ;
        end
        else begin
            ErrorMsg(csTooArguments) ;
        end ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure GlobalCommande(aoArguments : TStringList) ;
var
    { Index de boucle }
    liIndex : Integer ;
    { Nom de la variable }
    lsNameOfVar : String ;
begin
    if goVariables <> goFirstVariables
    then begin
        if aoArguments.count > 0
        then begin
            for liIndex := 0 to aoArguments.Count - 1 do
            begin
                lsNameOfVar := aoArguments[liIndex] ;

                goGlobalVariable.Add(lsNameOfVar) ;

                if not goFirstVariables.isSet(lsNameOfVar)
                then begin
                    WarningMsg(Format(csVariableDoesntExist, [lsNameOfVar])) ;
                end ;

                goVariables.Add(lsNameOfVar, goFirstVariables.Give(lsNameOfVar)) ;
            end ;
        end
        else begin
            ErrorMsg(csMissingargument) ;
        end ;
    end
    else begin
        WarningMsg(csGlobalInMain) ;
    end ;
end ;

procedure isHexaCommande(aoArguments : TStringList) ;
begin
    GetValueOfStrings(aoArguments) ;

    if aoArguments.count > 0
    then begin
        if aoArguments.count < 2
        then begin
            if isHexa(aoArguments[0])
            then begin
                gsResultFunction := csTrueValue
            end
            else begin
                gsResultFunction := csFalseValue ;
            end ;
        end
        else begin
            ErrorMsg(csTooArguments) ;
        end ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure functionExistsCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count > 0
    then begin
        if aoArguments.count < 2
        then begin
        {$IFDEF FPC}
        if Assigned(goInternalFunction.Give(aoArguments[0])) or (goListProcedure.Give(aoArguments[0]) <> -1)
            {$ELSE}
            if Assigned(@goInternalFunction.Give(aoArguments[0])) or (ListProcedure.Give(aoArguments[0]) <> -1)
            {$ENDIF}
            then begin
                gsResultFunction := csTrueValue
            end
            else begin
                gsResultFunction := csFalseValue ;
            end ;
        end
        else begin
            ErrorMsg(csTooArguments) ;
        end ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure functionDeleteCommande(aoArguments : TStringList) ;
var i : Integer ;
begin
    if aoArguments.count > 0
    then begin
        for i := 0 to aoArguments.count - 1 do
        begin
            gsResultFunction := csTrueValue ;

            {$IFDEF FPC}
            if Assigned(goInternalFunction.Give(aoArguments[0]))
            {$ELSE}
            if Assigned(@goInternalFunction.Give(aoArguments[0]))
            {$ENDIF}
            then begin
                goInternalFunction.Delete(aoArguments[0]) ;
            end
            else if goListProcedure.Give(aoArguments[0]) <> -1
            then begin
                goListProcedure.Delete(aoArguments[0])
            end
            else begin
                WarningMsg(Format(csCantFindFunctionToDelete, [aoArguments[0]])) ;
                gsResultFunction := csFalseValue ;
            end ;
        end ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure functionRenameCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count > 0
    then begin
        if aoArguments.count < 3
        then begin
            if goInternalFunction.Rename(aoArguments[0], aoArguments[1]) or goListProcedure.Rename(aoArguments[0], aoArguments[1])
            then begin
                gsResultFunction := csTrueValue ;
            end
            else begin
                gsResultFunction := csFalseValue ;
            end ;
        end
        else begin
            ErrorMsg(csTooArguments) ;
        end ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

{*****************************************************************************
 * GotoNextEndSwitch
 * MARTINEAU Emeric
 *
 * Retourne la position du EndSwitch
 *
 * Paramètres d'entrée :
 *   - aiCode : code à lire,
 *   - aiPosition : position de départ à lire soit typiquement position du 
 *     switch + 1,
 *
 * Retour : Poisiotn du EndSwitch
 *****************************************************************************}
function GotoNextEndSwitch(aoCode : TStringList; aiPosition: Integer) : Integer ;
var
    { Nombre de ligne }
    liNbLigne : Integer ;
    { Commande = endswitch/switch }
    lsCommande : String ;
begin
    Result := -1 ;

    liNbLigne := aoCode.Count ;

    while aiPosition < liNbLigne do
    begin
        lsCommande := ExtractCommande(aoCode[aiPosition]) ;

        if (lsCommande = 'endswitch')
        then begin
            Result := aiPosition ;
            break ;
        end
        else if (lsCommande = 'switch')
        then begin
            if GotoNextEndSwitch(aoCode, aiPosition) = -1
            then begin
                break ;
            end ;
        end ;

        Inc(aiPosition) ;
    end ;
end ;

{*****************************************************************************
 * GotoNextCaseOrEndSwitch
 * MARTINEAU Emeric
 *
 * Retourne la position du Case/Default suivant ou de EndSwitch
 *
 * Paramètres d'entrée :
 *   - aiCode : code à lire,
 *   - aiPosition : position de départ à lire soit typiquement position du 
 *     switch + 1,
 *
 * Retour : Position du Case/Default ou EndSwitch
 *****************************************************************************}
function GotoNextCaseOrEndSwitch(aoCode : TStringList; aiPosition : Integer) : Integer ;
var
    { Nombre de ligne }
    liNbLigne : Integer ;
    { Commande = endswitch/switch/case/default }
    lsCommande : String ;
begin
    Result := - 1 ;
    
    liNbLigne := aoCode.Count ;

    while aiPosition < liNbLigne do
    begin
        lsCommande := ExtractCommande(aoCode[aiPosition]) ;

        if (lsCommande = 'case') or (lsCommande = 'endswitch') or (lsCommande = 'default')
        then begin
            Result := aiPosition ;
            break ;
        end
        else if (lsCommande = 'switch')
        then begin
            if gotoNextEndSwitch(aoCode, aiPosition) = -1
            then begin
                break ;
            end ;
        end ;

        Inc(aiPosition) ;
    end ;
end ;

function switchCommande(aoArguments : TStringList) : Integer ;
var
    { Index d'argument }
    liIndex : Integer ;
    { Nombre de ligne }
    liNbLigne : Integer ;
    { Condition à analyser }
    lsCondition : String ;
    { Condition de fin }
    loEndCondition : TStringList ;
    { Quitte le switch via endswitch/goto }
    lbExitSwitch : Boolean ;
    { Commande en cours }
    lsCommande : String ;
    { Indique si la condition est vérifié }
    lbCondOk : Boolean ;
    { Label du switch }
    lsSwitchLabel : String ;
begin
    Result := -1;

    if aoArguments.Count > 0
    then begin
        { Supprime le case }
        aoArguments.Delete(0) ;
    end ;
    
    if aoArguments.Count > 0
    then begin
        { Supprime le do }
        aoArguments.Delete(aoArguments.Count - 1) ;
    end ;

    GetValueOfStrings(aoArguments) ;

    if (not gbQuit)
    then begin
        if aoArguments.count > 0
        then begin
            if aoArguments.count < 3
            then begin
                loEndCondition := TStringList.Create ;

                Result := giCurrentLineNumber + 1 ;
                liNbLigne := goCodeList.Count ;
                lsCondition := aoArguments[0] ;
                lbExitSwitch := False ;

                lsSwitchLabel := gsCurrentLabel ;

                while Result < liNbLigne do
                begin
                    ExplodeStrings(goCodeList[Result], aoArguments) ;
                    GetValueOfStrings(aoArguments) ;

                    if (not gbQuit)
                    then begin
                        if aoArguments.Count > 0
                        then begin
                            lsCommande := aoArguments[0] ;
                            
                            if lsCommande = 'default'
                            then begin
                                loEndCondition.Add('case') ;
                                loEndCondition.Add('endswitch') ;

                                Inc(Result) ;

                                Result := ReadCode(Result, loEndCondition, goCodeList) ;

                                { Si c'est un break qui déclanche la fin du code avec le
                                  label qui correspond à notre for ou si pas de label }
                                if ((lsSwitchLabel = gsCurrentLabel) or (gsCurrentLabel = ''))
                                then begin
                                    if (gbBreak = True)
                                    then begin
                                        gbQuit := False ;

                                        gbBreak := False ;

                                        break ;
                                    end ;
                                end ;

                                lbExitSwitch := True ;

                                break ;
                            end
                            else if lsCommande = 'case'
                            then begin
                                { Si la ligne case est correct }
                                if aoArguments.Count > 1
                                then begin
                                    lbCondOk := False ;

                                    for liIndex := 1 to aoArguments.count -1 do
                                    begin
                                        if aoArguments[liIndex] = lsCondition
                                        then begin
                                            lbCondOk := True ;
                                            break ;
                                        end ;
                                    end ;
                                    
                                    { test la condition }
                                    if lbCondOk
                                    then begin
                                        loEndCondition.Add('case') ;
                                        loEndCondition.Add('default') ;
                                        loEndCondition.Add('endswitch') ;

                                        { Pointe sur la ligne après le case }
                                        Inc(Result) ;

                                        Result := ReadCode(Result, loEndCondition, goCodeList) ;

                                        { Si c'est un break qui déclanche la fin du code avec le
                                          label qui correspond à notre for ou si pas de label }
                                        if ((lsSwitchLabel = gsCurrentLabel) or (gsCurrentLabel = ''))
                                        then begin
                                            if (gbBreak = True)
                                            then begin
                                                gbQuit := False ;

                                                gbBreak := False ;

                                                break ;
                                            end ;
                                        end ;

                                        if (Result = -1) or (gbQuit = True)
                                        then begin
                                            lbExitSwitch := True ;

                                            break ;
                                        end
                                        else begin
                                            lsCommande := extractCommande(goCodeList[Result - 1]) ;

                                            if lsCommande = 'default'
                                            then begin
                                                break
                                            end
                                            else if lsCommande = 'endswitch'
                                            then begin
                                                { décrémente de 1 car Inc dans ReadCode }
                                                Dec(Result) ;
                                                lbExitSwitch := True ;
                                                break ;
                                            end
                                            else begin
                                                ErrorMsg(csMissingBreakInCase) ;
                                                lbExitSwitch := True ;
                                                Result := -1 ;
                                                break ;
                                            end ;
                                        end ;
                                    end
                                    else begin
                                         { Aller au prochain case ou endswitch
                                           -1 car Inc(Result) à la fin de la boucle }
                                         liIndex := GotoNextCaseOrEndSwitch(goCodeList, Result + 1) - 1;

                                         { Un bug dans Delphi fait que Result = -1 est
                                           toujours vrai }
                                         if liIndex = -1
                                         then begin
                                             break ;
                                         end ;

                                         Result := liIndex  ;
                                    end ;
                                end
                                else begin
                                    ErrorMsg(csMissingCompInCase) ;
                                end ;
                            end
                        end ;

                        Inc(Result) ;
                    end ;
                end ;

                if not lbExitSwitch
                then begin
                    Result := gotoNextEndSwitch(goCodeList, Result) ;
                end
                else begin
                    { On décrémente car dans ReadCode on incrémente }
                    Dec(Result) ;
                end ;
                
                FreeAndNil(loEndCondition) ;
            end
            else begin
                ErrorMsg(csTooArguments) ;
            end ;
        end
        else begin
            ErrorMsg(csMissingargument) ;
        end ;
    end ;
end ;

procedure chrCommande(aoArguments : TStringList) ;
begin
    if aoArguments.Count = 1
    then begin
        if isInteger(aoArguments[0])
        then begin
            gsResultFunction := chr(MyStrToInt(aoArguments[0]))
        end
        else begin
            ErrorMsg(Format(csNoNumber, [aoArguments[0]])) ;
        end ;
    end
    else if aoArguments.Count > 1
    then begin
        ErrorMsg(csTooArguments)
    end
    else begin
        ErrorMsg(csMissingArgument) ;
    end ;
end ;

procedure ordCommande(aoArguments : TStringList) ;
var
    { Index de boucle }
    liIndex : Integer ;
begin
    if aoArguments.Count = 1
    then begin
        for liIndex := 1 to Length(aoArguments[0]) do
        begin
            gsResultFunction := IntToStr(ord(aoArguments[0][liIndex])) ;
        end ;
    end
    else if aoArguments.Count > 1
    then begin
        ErrorMsg(csTooArguments)
    end
    else begin
        ErrorMsg(csMissingArgument) ;
    end
end ;

procedure countCommande(aoArguments : TStringList) ;
var
    { Longueur de l'argument 0}
    liLenArgument : Integer ;
    { Nom de la variable }
    lsVarName : string ;
begin
    if aoArguments.Count = 1
    then begin
        if isVar(aoArguments[0])
        then begin
            liLenArgument := Length(aoArguments[0]) ;
            lsVarName := aoArguments[0] ;

            { Si variable $$xxx }
            if liLenArgument > 2
            then begin
                if aoArguments[0][2] = '$'
                then begin
                    lsVarName := copy(aoArguments[0], 2, liLenArgument - 1) ;
                    aoArguments[0] := getVar(lsVarName) ;
                end ;
            end ;

            if goVariables.isSet(lsVarName) = False
            then begin
                WarningMsg(Format(csVariableDoesntExist, [lsVarName])) ;
            end ;

            gsResultFunction := IntToStr(goVariables.Length(aoArguments[0])) ;
        end
        else begin
            ErrorMsg(csInvalidVarName) ;
        end ;
    end
    else if aoArguments.Count > 1
    then begin
        ErrorMsg(csTooArguments)
    end 
    else begin
        ErrorMsg(csMissingArgument) ;
    end
end ;

procedure loadCommande(aoArguments : TStringList) ;
begin
    if aoArguments.Count = 1
    then begin
        if LoadExtension(aoArguments[0])
        then begin
            gsResultFunction := csTrueValue
        end
        else begin
            gsResultFunction := csFalseValue ;
        end ;
    end
    else if aoArguments.Count > 1
    then begin
        ErrorMsg(csTooArguments)
    end
    else begin
        ErrorMsg(csMissingArgument) ;
    end ;
end ;

procedure unLoadCommande(aoArguments : TStringList) ;
begin
    if aoArguments.Count = 1
    then begin
        UnLoadExtension(aoArguments[0])
    end
    else if aoArguments.Count > 1
    then begin
        ErrorMsg(csTooArguments)
    end
    else begin
        ErrorMsg(csMissingArgument) ;
    end ;
end ;

procedure isExtLoadCommande(aoArguments : TStringList) ;
begin
    if aoArguments.Count = 1
    then begin
        if isExtensionLoaded(aoArguments[0])
        then begin
            gsResultFunction := csTrueValue
        end
        else begin
            gsResultFunction := csFalseValue ;
        end ;
    end
    else if aoArguments.Count > 1
    then begin
        ErrorMsg(csTooArguments)
    end
    else begin
        ErrorMsg(csMissingArgument) ;
    end ;
end ;

procedure evalCommande(aoArguments : TStringList) ;
var
    { Code à exécuter }
    loListOfCode : TStringList ;
    { Liste des fichiers. Utilisé pour include_once et erreur }
    loOldListOfFile : TStringList ;
    { Fait la correspondance entre ligne et n° de ligne dans le fichier }
    loOldLineToFileLine : TStringList ;
    { Fait la correspondance entre la ligne et le fichier }
    loOldLineToFile : TIntegerList ;
    { Liste des commandes mettant fin au code eval exécuté }
    loEndCondition : TStringList ;
    { Compteur de boucle pour initialiser les numéro de ligne et les fichiers
      correspondant (soit "eval command") }
    liIndex : Integer ;
begin
    if aoArguments.Count = 1
    then begin
        loListOfCode := TStringList.Create ;

        if goVariables.InternalisArray(aoArguments[0])
        then begin
            goVariables.explode(loListOfCode, aoArguments[0])
        end
        else begin
            loListOfCode.Add(aoArguments[0]) ;
        end ;

        { On fait correspondre les lignes executées et le code }
        { Liste des fichiers. Utilisé pour include_once et erreur }
        loOldListOfFile := goListOfFile ;
        { Fait la corespondance entre ligne et n° de ligne dans le fichier }
        loOldLineToFileLine := goLineToFileLine ;
        { Fait la correspondance entre la ligne et le fichier }
        loOldLineToFile := goLineToFile ;

        loEndCondition := TStringList.Create ;

        goListOfFile := TStringList.Create ;
        goLineToFileLine := TStringList.Create ;
        goLineToFile := TIntegerList.Create ;

        goListOfFile.Add('eval command') ;

        for liIndex := 0 to loListOfCode.Count - 1 do
        begin
            goLineToFileLine.Add(IntToStr(liIndex + 1)) ;
            goLineToFile.Add(0) ;
        end ;

        gbError := False ;
        
        ReadCode(0, loEndCondition, loListOfCode) ;

        FreeAndNil(goListOfFile) ;
        FreeAndNil(goLineToFileLine) ;
        FreeAndNil(goLineToFile) ;

        { Liste des fichiers. Utilisé pour include_once et erreur }
        goListOfFile := loOldListOfFile ;
        { Fait la corespondance entre ligne et n° de ligne dans le fichier }
        goLineToFileLine := loOldLineToFileLine ;
        { Fait la correspondance entre la ligne et le fichier }
        goLineToFile := loOldLineToFile ;

        FreeAndNil(loEndCondition) ;

        FreeAndNil(loListOfCode) ;
        
        if gbError and not gbQuit
        then begin
            gsResultFunction := csFalseValue ;
            
            { Quoi qu'il se passe on n'arrête pas le script parce que l'erreur est
              dans l'eval et pas dans le script même }
            gbError := False ;
        end
        else begin
            gsResultFunction := csTrueValue ;
        end ;
    end
    else if aoArguments.Count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end 
    else begin
        ErrorMsg(csMissingArgument) ;
    end
end ;

procedure GetCookieCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := goVarGetPostCookieFileData.GetCookie(aoArguments[0]) ;
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


procedure IncludeCommande(aoArguments : TStringList) ;
var
    { Ancien gsDocRoot pour que les chemins relatif se fasse
      par rapport au fichier inclu }
    lsOldDocRoot : String ;
begin
    if aoArguments.count = 1
    then begin
        lsOldDocRoot := gsDocRoot ;
        
        { goLineToFile contient la correspondance entre le numéro de ligne et le numéro
          du fichier en cours d'exécution }
        gsDocRoot := goCurrentRootOfFile[goLineToFile[giCurrentLineNumber]] ;

        // ajouter @>
        goCodeList.Insert(giCurrentLineNumber, csEndSwsTag) ;
        goLineToFile.Insert(giCurrentLineNumber, goLineToFile[giCurrentLineNumber]) ;
        goLineToFileLine.Insert(giCurrentLineNumber, goLineToFileLine[giCurrentLineNumber]) ;

        Inc(giCurrentLineNumber) ;

        //ajouter <@
        goCodeList.Insert(giCurrentLineNumber + 1, csStartSwsTag) ;
        goLineToFile.Insert(giCurrentLineNumber + 1, goLineToFile[giCurrentLineNumber]) ;
        goLineToFileLine.Insert(giCurrentLineNumber + 1, goLineToFileLine[giCurrentLineNumber]) ;

        // Inclue le code
        LoadCode(aoArguments[0], giCurrentLineNumber + 1) ;

        gsDocRoot := lsOldDocRoot ;

        { On supprime la ligne include('xxx') }
        goCodeList.Delete(giCurrentLineNumber);
        goLineToFile.Delete(giCurrentLineNumber) ;
        goLineToFileLine.Delete(giCurrentLineNumber);

        { Par défaut le nouveau fichier est considéré comme du HTML }
        gbIsExecutableCode := False ;

        Dec(giCurrentLineNumber) ;
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

procedure includeOnceCommande(aoArguments : TStringList) ;
var
    { Ancien gsDocRoot pour que les chemins relatif se fasse
      par rapport au fichier inclu }
    lsOldDocRoot : String ;
begin
    if aoArguments.count = 1
    then begin
        lsOldDocRoot := gsDocRoot ;
        
        { goLineToFile contient la correspondance entre le numéro de ligne et le numéro
          du fichier en cours d'exécution }
        gsDocRoot := goCurrentRootOfFile[goLineToFile[giCurrentLineNumber]] ;

        if goListOfFile.IndexOf(Realpath(aoArguments[0])) = -1
        then begin
            includeCommande(aoArguments) ;
        end
        else begin
            { On supprime la ligne includeOnce('xxx') }
            goCodeList.Delete(giCurrentLineNumber);
            goLineToFile.Delete(giCurrentLineNumber) ;
            goLineToFileLine.Delete(giCurrentLineNumber);
            
            Dec(giCurrentLineNumber) ;
        end ;

        gsDocRoot := lsOldDocRoot ;
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

procedure arrayrSortCommande(aoArguments : TStringList) ;
var
    { Résultat du sort }
    lsResultat : string ;
begin
    if aoArguments.count > 0
    then begin
        if aoArguments.count < 2
        then begin
            lsResultat := aoArguments[0] ;
            
            if goVariables.arrayrSort(lsResultat)
            then begin
                gsResultFunction := lsResultat ;
            end
            else begin
                gsResultFunction := '' ;
                WarningMsg(csMustBeAnArray)
            end ;
        end
        else begin
            ErrorMsg(csTooArguments) ;
        end ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure arrayRevCommande(aoArguments : TStringList) ;
var
    { Tableau temporaire recevant le tableau d'origine
      à l'envers }
    loTableau : TStringList ;
    { Nombre d'élément dans le tableau }
    liNbItemInArray : Integer ;
    { Index de parcour du tableau }
    liIndex : Integer ;
    { Valeur de l'elément à échanger }
    lsTmp : String ;
begin
    if aoArguments.Count = 1
    then begin
        if goVariables.InternalisArray(aoArguments[0])
        then begin
            loTableau := TStringList.Create ;
            goVariables.explode(loTableau, aoArguments[0]);
            liNbItemInArray := loTableau.Count - 1 ;

            for liIndex := 0 to (liNbItemInArray div 2) do
            begin
                lsTmp := loTableau[liIndex] ;
                loTableau[liIndex] := loTableau[liNbItemInArray - liIndex] ;
                loTableau[liNbItemInArray - liIndex] := lsTmp ;
            end ;

            gsResultFunction := goVariables.CreateArray(loTableau) ;

            FreeAndNil(loTableau) ;
        end
        else begin
            WarningMsg(csMustBeAnArray) ;
        end ;
    end
    else if aoArguments.Count > 1
    then begin
        ErrorMsg(csTooArguments)
    end
    else begin
        ErrorMsg(csMissingArgument) ;
    end ;
end ;

procedure arrayShiftCommande(aoArguments : TStringList) ;
var
    { Tableau à décaler }
    loTableau : TStringList ;
    { Valeur de la variable du tableau et nouvelle valeur du tableau }
    lsTmp : String ;
begin
    if aoArguments.Count = 1
    then begin
        if isVar(aoArguments[0])
        then begin
            lsTmp := getVar(aoArguments[0]);

            if goVariables.InternalisArray(lsTmp)
            then begin
                loTableau := TStringList.Create ;
                goVariables.explode(loTableau, lsTmp);

                if loTableau.Count > 0
                then begin
                    gsResultFunction := loTableau[0] ;

                    loTableau.Delete(0) ;

                    lsTmp := goVariables.CreateArray(loTableau) ;

                    setVar(aoArguments[0], lsTmp) ;
                end ;

                FreeAndNil(loTableau) ;
            end
            else begin
                WarningMsg(csMustBeAnArray) ;
            end ;
        end
        else begin
            ErrorMsg(Format(csNotAVariable, [aoArguments[0]])) ;
        end ;
    end
    else if aoArguments.Count > 1
    then begin
        ErrorMsg(csTooArguments)
    end
    else begin
        ErrorMsg(csMissingArgument) ;
    end ;
end ;

procedure arraySliceCommande(aoArguments : TStringList) ;
var
    { Tableau à retourner }
    loTableau : TStringList ;
    { Longeur à retourner }
    liLength : Integer ;
    { Offset (indice de départ) }
    liOffset : Integer ;
    { Indice pour le parcours du tableau }
    liIndex : Integer ;
begin
    if (aoArguments.Count > 1) and (aoArguments.Count < 4)
    then begin
        if goVariables.InternalisArray(aoArguments[0])
        then begin
            loTableau := TStringList.Create ;
            goVariables.explode(loTableau, aoArguments[0]);

            liOffset := MyStrToInt(aoArguments[1]) - 1 ;

            if aoArguments.Count = 3
            then begin
                liLength := MyStrToInt(aoArguments[2]) ;
            end
            else begin
                liLength := loTableau.Count ;
            end ;

            if liOffset < 0
            then begin
                liOffset := loTableau.Count + liOffset ; // + car offset est négatif
            end ;

            { Supprime tout ce qu'il y a avant offset }
            for liIndex := 0 to liOffset - 1 do
            begin
                loTableau.Delete(0) ;
            end ;

            { Supprime tout ce qu'il y a après }
            for liIndex := liLength to loTableau.Count - 1 do
            begin
                loTableau.Delete(liLength) ;
            end ;

            gsResultFunction := goVariables.CreateArray(loTableau) ;

            FreeAndNil(loTableau) ;
        end
        else begin
            WarningMsg(csMustBeAnArray) ;
        end ;
    end
    else if aoArguments.Count > 4
    then begin
        ErrorMsg(csTooArguments)
    end
    else begin
        ErrorMsg(csMissingArgument) ;
    end ;
end ;

procedure arraySpliceCommande(aoArguments : TStringList) ;
var
    { Tableau du départ }
    loOldArray : TStringList ;
    { Nouveau tableau}
    loNewArray : TStringList ;
    { Longueur du tableau à retourner }
    liLength : Integer ;
    { Offset (départ) dans le tableau à retourner }
    liOffset : Integer ;
    { Compteur du tableau }
    liIndex : Integer ;
    { Valeur de la variable tableau }
    lsTmp : string ;
    { Tableau de remplacement }
    loReplaceArray : TStringList ;
    { Index en cours du tableau de replacement }
    liIndexReplace : Integer ;
    { Fin du tableau à lire }
    liEndOldArray : Integer ;
    { Indique s'il y a une valeur de remplacement }
    lbHaveReplaceValeur : Boolean ;
    { Nom de la variable }
    lsVarName : String ;
begin
    if (aoArguments.Count > 1)
    then begin
        if isVar(aoArguments[0])
        then begin
            lsTmp := getVar(aoArguments[0]) ;

            if goVariables.InternalisArray(lsTmp)
            then begin
                loOldArray := TStringList.Create ;
                loNewArray := TStringList.Create ;
                loReplaceArray  := TStringList.Create ;
                
                liIndexReplace := 0 ;
                
                lbHaveReplaceValeur := False ;
                
                lsVarName := aoArguments[0] ;

                goVariables.explode(loOldArray, lsTmp);

                liOffset := MyStrToInt(aoArguments[1]) - 1 ;

                if aoArguments.Count > 2
                then begin
                    liLength := MyStrToInt(aoArguments[2]) ;
                end
                else begin
                    liLength := loOldArray.Count ;
                end ;
                
                if aoArguments.Count > 3
                then begin
                    { Supprime les commandes précédente pour avoir le résultat
                      du paramètre replacement }
                    aoArguments.Delete(0) ;
                    aoArguments.Delete(0) ;
                    aoArguments.Delete(0) ;
                    
                    if GetValueOfStrings(aoArguments) = 1
                    then begin
                        if goVariables.InternalisArray(aoArguments[0])
                        then begin
                            goVariables.explode(loReplaceArray, aoArguments[0]) ;
                        end
                        else begin
                            loReplaceArray.Add(aoArguments[0]) ;
                        end ;

                        lbHaveReplaceValeur := True ;
                    end
                    else begin
                        ErrorMsg(csTooArguments) ;
                    end ;
                end ;

                if gbQuit = False
                then begin
                    if liOffset < 0
                    then begin
                        liOffset := loOldArray.Count + liOffset ; // + car offset est négatif
                    end ;

                    liEndOldArray := liOffset + liLength ;

                    { Si la longeur est suppérieur à la longueur du tableau on s'arrête à la
                      fin du tableau }
                    if liEndOldArray > loOldArray.Count
                    then begin
                        liEndOldArray := loOldArray.Count ;
                    end ;

                    for liIndex := liOffset to  liEndOldArray - 1 do
                    begin
                        if lbHaveReplaceValeur = True
                        then begin
                            loNewArray.Add(loOldArray[liIndex]) ;
                            loOldArray[liIndex] := loReplaceArray[liIndexReplace] ;

                            if (liIndexReplace = (loReplaceArray.Count - 1))
                            then begin
                                liIndexReplace := 0 ;
                            end
                            else begin
                                Inc(liIndexReplace) ;
                            end ;
                        end
                        else begin
                            loNewArray.Add(loOldArray[liOffset]) ;
                            loOldArray.Delete(liOffset) ;
                        end ;
                    end ;

                    gsResultFunction := goVariables.CreateArray(loNewArray) ;

                    lsTmp := goVariables.CreateArray(loOldArray) ;

                    SetVar(lsVarName, lsTmp) ;
                end ;
                
                FreeAndNil(loOldArray) ;
                FreeAndNil(loNewArray) ;
                FreeAndNil(loReplaceArray) ;
            end
            else begin
                WarningMsg(csMustBeAnArray) ;
            end ;
        end
        else begin
            ErrorMsg(Format(csNotAVariable, [aoArguments[0]])) ;
        end ;
    end
    else begin
        ErrorMsg(csMissingArgument) ;
    end ;
end ;

procedure arrayShuffleCommande(aoArguments : TStringList) ;
var
    { Tableau à mélanger }
    loTableau : TStringList ;
begin
    if aoArguments.Count = 1
    then begin
        if goVariables.InternalisArray(aoArguments[0])
        then begin
            loTableau := TStringList.Create ;
            goVariables.explode(loTableau, aoArguments[0]);

            ListShuffle(loTableau) ;

            gsResultFunction := goVariables.CreateArray(loTableau) ;

            FreeAndNil(loTableau) ;
        end
        else begin
            WarningMsg(csMustBeAnArray) ;
        end ;
    end
    else if aoArguments.Count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end
    else begin
        ErrorMsg(csMissingArgument) ;
    end ;
end ;

procedure FunctionDisabled(aoArguments : TStringList) ;
begin
    WarningMsg(csFunctionDisabled) ;
end ;

procedure DefineCommande(aoArguments : TStringList) ;
var
    { Nom de la constantes }
    lsConstanteName : String ;
begin
    if aoArguments.count = 2
    then begin
        lsConstanteName := '#' + aoArguments[0] ;
        
        if IsConst(lsConstanteName)
        then begin
            if IsSetConst(lsConstanteName)
            then begin
                WarningMsg(Format(csConstanteAlreadyDefine, [lsConstanteName])) ;
            end
            else begin
                goConstantes.Add(lsConstanteName, aoArguments[1]) ;
            end ;
        end
        else begin
            ErrorMsg(Format(csNotAConstante, [aoArguments[0]])) ;
        end ;
    end
    else if aoArguments.Count > 2
    then begin
        ErrorMsg(csTooArguments) ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure DefinedCommande(aoArguments : TStringList) ;
var
    { Nom de la constantes }
    lsConstanteName : String ;
begin
    if aoArguments.count = 1
    then begin
        lsConstanteName := '#' + aoArguments[0] ;

        if IsConst(lsConstanteName)
        then begin
            if IsSetConst(lsConstanteName)
            then begin
                gsResultFunction := csTrueValue ;
            end
            else begin
                gsResultFunction := csFalseValue ;
            end ;
        end
        else begin
            ErrorMsg(Format(csNotAConstante, [aoArguments[0]])) ;
        end ;
    end
    else if aoArguments.Count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure TrueCommande(aoArguments : TStringList) ;
begin
    gsResultFunction := csTrueValue ;
end ;

procedure FalseCommande(aoArguments : TStringList) ;
begin
    gsResultFunction := csFalseValue ;
end ;

procedure isOctalCommande(aoArguments : TStringList) ;
begin
    GetValueOfStrings(aoArguments) ;

    if aoArguments.count > 0
    then begin
        if aoArguments.count < 2
        then begin
            if isInteger(aoArguments[0]) and (Length(aoArguments[0]) > 0) and
               (aoArguments[0][1] = '0')
            then begin
                gsResultFunction := csTrueValue
            end
            else begin
                gsResultFunction := csFalseValue ;
            end ;
        end
        else begin
            ErrorMsg(csTooArguments) ;
        end ;
    end
    else begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure returnCommande(aoArguments : TStringList) ;
begin
    if aoArguments.Count = 1
    then begin
        gsResultFunction := aoArguments[0] ;

        gbQuit := True ;
        gbReturn := True ;
    end
    else if aoArguments.Count = 0
    then begin
        gsResultFunction := '' ;

        gbQuit := True ;
        gbReturn := True ;
    end
    else begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure exitCommande(aoArguments : TStringList) ;
begin
    if aoArguments.Count = 1
    then begin
        ExitCode := MyStrToInt(aoArguments[0]) ;
    end
    else if aoArguments.Count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;

    gbQuit := True ;
end ;

procedure breakCommande(aoArguments : TStringList) ;
begin
    if aoArguments.Count = 1
    then begin
        gsCurrentLabel := aoArguments[0] ;
    end
    else if aoArguments.Count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end
    else begin
        gsCurrentLabel := '' ;
    end ;

    gbBreak := True ;

    gbQuit := True ;
end ;

procedure ContinueCommande(aoArguments : TStringList) ;
begin
    if aoArguments.Count = 1
    then begin
        gsCurrentLabel := aoArguments[0] ;
    end
    else if aoArguments.Count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end
    else begin
        gsCurrentLabel := '' ;
    end ;

    gbContinue := True ;

    gbQuit := True ;
end ;

procedure CoreFunctionsInit ;
begin
    goInternalFunction.Add('length', @LengthCommande, true) ;
    goInternalFunction.Add('isNumeric', @isNumericCommande, true) ;
    goInternalFunction.Add('isFloat', @isNumericCommande, true) ;
    goInternalFunction.Add('isInteger', @isIntegerCommande, true) ;
    goInternalFunction.Add('isString', @isStringCommande, true) ;
    goInternalFunction.Add('isArray', @isArrayCommande, true) ;
    goInternalFunction.Add('array', @arrayCreateCommande, true) ;
    goInternalFunction.Add('isHexa', @ishexaCommande, true) ;
    goInternalFunction.Add('arrayMerge', @arraymergeCommande, true) ;
    goInternalFunction.Add('arraySort', @arraySortCommande, true) ;
    goInternalFunction.Add('arraySearch', @arraySearchCommande, true) ;
    goInternalFunction.Add('functionExists', @functionexistsCommande, true) ;
    goInternalFunction.Add('functionDelete', @functionDeleteCommande, true) ;
    goInternalFunction.Add('functionRename', @functionRenameCommande, true) ;
    goInternalFunction.Add('chr', @chrCommande, true) ;
    goInternalFunction.Add('ord', @ordCommande, true) ;
    goInternalFunction.Add('extensionLoad', @loadCommande, true) ;
    goInternalFunction.Add('extensionUnLoad', @unLoadCommande, true) ;
    goInternalFunction.Add('isExtensionLoaded', @isExtLoadCommande, true) ;
    goInternalFunction.Add('eval', @evalCommande, true) ;
    goInternalFunction.Add('getCookie', @getCookieCommande, true) ;
    goInternalFunction.Add('include', @includeCommande, true) ;
    goInternalFunction.Add('includeOnce', @includeOnceCommande, true) ;
    goInternalFunction.Add('arrayRSort', @arrayrSortCommande, true) ;
    goInternalFunction.Add('arrayRev', @arrayRevCommande, true) ;
    goInternalFunction.Add('arraySlice', @arraySliceCommande, true) ;
    goInternalFunction.Add('arrayShuffle', @arrayShuffleCommande, true) ;

    goInternalFunction.Add('isSet', @isSetCommande, false) ;
    goInternalFunction.Add('set', @SetCommande, false) ;
    goInternalFunction.Add('unSet', @unSetCommande, false) ;
    goInternalFunction.Add('arrayPush', @arrayPushCommande, false) ;
    goInternalFunction.Add('arrayInsert', @arrayinsertCommande, false) ;
    goInternalFunction.Add('arrayPop', @arraypopCommande, false) ;
    goInternalFunction.Add('arrayExchange', @arrayexchangeCommande, false) ;
    goInternalFunction.Add('arrayChunk', @arraychunkCommande, false) ;
    goInternalFunction.Add('arrayFill', @arrayfillCommande, false) ;
    goInternalFunction.Add('global', @globalCommande, false) ;
    goInternalFunction.Add('count', @countCommande, false) ;
    goInternalFunction.Add('arrayShift', @arrayShiftCommande, false) ;
    goInternalFunction.Add('arraySplice', @arraySpliceCommande, false) ;
    
    goInternalFunction.Add('define', @DefineCommande, true) ;
    goInternalFunction.Add('defined', @DefinedCommande, true) ;
    
    goInternalFunction.Add('true', @TrueCommande, false) ;
    goInternalFunction.Add('false', @FalseCommande, false) ;

    goInternalFunction.Add('isOctal', @isOctalCommande, true) ;

    goInternalFunction.Add('return', @returnCommande, true) ;
    goInternalFunction.Add('exit', @exitCommande, true) ;
    goInternalFunction.Add('break', @breakCommande, false) ;
    goInternalFunction.Add('continue', @continueCommande, false) ;
end ;

end.
