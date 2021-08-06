unit CoreFunctions;
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
 *   CALL
 *   GETCOOKIE
 *
 *   DisabelFunction
 ******************************************************************************}

interface

{$I config.inc}

uses SysUtils, UnitMessages, InternalFunction, classes ;

procedure CoreFunctionsInit ;

function gotoCommande(arguments : TStringList) : Integer ;
procedure setCommande(arguments : TStringList) ;
procedure unSetCommande(arguments : TStringList) ;
procedure isSetCommande(arguments : TStringList) ;
procedure LengthCommande(arguments : TStringList) ;
function FunctionCommande(arguments : TStringList) : Integer ;
function getEndIf(arguments : TStringList; position : Integer) : Integer ;
function getElseIfElseEndIf(arguments : TStringList; position : Integer) : Integer ;
function ifCommande(arguments : TStringList) : Integer ;
function whileCommande(arguments : TStringList) : Integer ;
function repeatUntilCommande(arguments : TStringList) : Integer ;
function forCommande(arguments : TStringList) : Integer ;
function findEndBoucle(CodeList : TStringList; start : Integer) : Integer ;
procedure isIntegerCommande(arguments : TStringList) ;
procedure isFloatCommande(arguments : TStringList) ;
procedure isNumericCommande(arguments : TStringList) ;
procedure isStringCommande(arguments : TStringList) ;
procedure isArrayCommande(arguments : TStringList) ;
procedure arrayPushCommande(arguments : TStringList) ;
procedure arrayInsertCommande(arguments : TStringList) ;
procedure arrayPopCommande(arguments : TStringList) ;
procedure arrayExchangeCommande(arguments : TStringList) ;
procedure arrayChunkCommande(arguments : TStringList) ;
procedure arrayMergeCommande(arguments : TStringList) ;
procedure arrayFillCommande(arguments : TStringList) ;
procedure arraySortCommande(arguments : TStringList) ;
procedure GlobalCommande(arguments : TStringList) ;
procedure isHexaCommande(arguments : TStringList) ;
procedure functionExistsCommande(arguments : TStringList) ;
procedure functionDeleteCommande(arguments : TStringList) ;
procedure functionRenameCommande(arguments : TStringList) ;
function gotoNextEndSwitch(Start : Integer; Code : TStringList) : Integer ;
function gotoNextCaseOrEndSwitch(Start : Integer; Code : TStringList) : Integer ;
function switchCommande(arguments : TStringList) : Integer ;
procedure loadCommande(arguments : TStringList) ;
procedure GetCookieCommande(arguments : TStringList) ;
procedure FunctionDisabled(arguments : TStringList) ;
procedure includeCommande(arguments : TStringList) ;
procedure arrayrSortCommande(arguments : TStringList) ;
procedure arrayRevCommande(arguments : TStringList) ;
procedure arrayShiftCommande(arguments : TStringList) ;
procedure arraySpliceCommande(arguments : TStringList) ;
procedure arrayShuffleCommande(arguments : TStringList) ;

implementation

uses Variable, Functions, Code, UserFunction, UserLabel ;

function gotoCommande(arguments : TStringList) : Integer ;
var debut, fin : Integer ;
begin
    ReadLabel ;
    
    Result := -1 ;

    {-- WARNING -- argument[0] = 'goto' }

    if arguments.Count = 2
    then begin
        if  ListLabel.isSet(arguments[1]) = False
        then
            ErrorMsg(Format('Label %s not found', [arguments[1]]))
        else
            { ListLabel.Give(arguments[1]) = line label }
            Result := ListLabel.Give(arguments[1]) ;

            debut := ListProcedure.Give(CurrentFunctionName[CurrentFunctionName.Count - 1]) ;
            fin := ListProcedure.GiveEnd(CurrentFunctionName[CurrentFunctionName.Count - 1]) ;

            if (Result < debut) or (Result > fin)
            then begin
                Result := -1 ;
                ErrorMsg(sLabelOutOfPrecedure)
            end ;
    end
    else
        ErrorMsg(sMissingLabelOrArguments) ;

end ;

procedure setCommande(arguments : TStringList) ;
var variableName : string ;
begin
    if arguments.Count > 0
    then begin
        variableName := arguments[0] ;

        if isVar(variableName)
        then begin
            { supprime la variable }
            arguments.Delete(0);

            if GetValueOfStrings(arguments) = 1
            then
                setVar(variableName, arguments[0])
            else
                ErrorMsg(sMissingOperator) ;
        end
        else begin
            ErrorMsg(Format(sNotAVariable ,[variableName])) ;
        end ;
    end
    else
        ErrorMsg(sMissingargument) ;
end ;

procedure unSetCommande(arguments : TStringList) ;
var i : Integer ;
begin
    if arguments.count > 0
    then begin
        for i := 0 to arguments.count - 1 do
        begin
             if isVar(arguments[i])
             then
                 delVar(arguments[i])
             else
                 ErrorMsg(Format(sNotAVariable ,[arguments[i] ])) ;
        end ;
    end
    else
        ErrorMsg(sMissingargument) ;
end ;

procedure isSetCommande(arguments : TStringList) ;
begin
    if arguments.count > 0
    then begin
        if arguments.count < 2
        then begin
            if isVar(arguments[0])
            then begin
                if isSet(arguments[0])
                then
                    ResultFunction := TrueValue
                else
                    ResultFunction := FalseValue ;
            end
            else begin
                ErrorMsg(Format(sNotAVariable, [arguments[0]])) ;
            end ;
        end
        else
            ErrorMsg(sTooArguments) ;
    end
    else
        ErrorMsg(sMissingargument) ;
end ;

procedure LengthCommande(arguments : TStringList) ;
begin
    if arguments.Count = 1
    then begin
        ResultFunction := IntToStr(System.length(arguments[0])) ;
    end
    else if arguments.Count > 1
    then
        ErrorMsg(sTooArguments)
    else
        ErrorMsg(sMissingArgument) ;
end ;

function FunctionCommande(arguments : TStringList) : Integer ;
var i : Integer ;
    Commande : String ;
    StartPos : Integer ;
begin
    Result := -1 ;

	{$IFDEF FPC}
	if (ListProcedure.Give(arguments[1]) = -1) and (ListFunction.Give(arguments[1]) = nil)
	{$ELSE}
    if (ListProcedure.Give(arguments[1]) = -1) and (@ListFunction.Give(arguments[1]) = nil)
	{$ENDIF}
    then begin
        if AnsiIndexStr(LowerCase(arguments[1]), ['in', 'or', 'xor', 'and', 'not',
                                                  'to', 'step', 'break', 'if',
                                                  'else', 'elseif', 'endif',
                                                  'while', 'endwhile', 'for',
                                                  'endfor', 'repeat', 'until',
                                                  'switch', 'endswitch', 'case',
                                                  'default', 'goto', 'labelgoto']) <> -1
        then begin
            ErrorMsg(Format(sReservedWord, [arguments[1]]))
        end
        else begin
            StartPos := CurrentLineNumber + 1 ;

            { Va à la fin de procedure }
            for i := CurrentLineNumber + 1 to CodeList.Count - 1 do
            begin
                Commande := LowerCase(extractCommande(CodeList[i])) ;

                if Commande = 'endfunc'
                then begin
                    Result := i ;
                    break ;
                end
                else if Commande = 'function'
                then begin
                    break ;
                end ;
            end ;

            if Result = -1
            then
                ErrorMsg(sNoEndProc)
            else begin
                Commande := arguments[1] ;

                { Supprime function }
                arguments.Delete(0);
                { Supprime nom de la fonction }
                arguments.Delete(0);

                DeleteVirguleAndParenthese(arguments) ;

                ListProcedure.Add(Commande, StartPos, Result - 1, arguments.text) ;
            end ;
        end ;
    end
    else begin
        ErrorMsg(Format(sProcedureAlreadyExist, [arguments[1]])) ;
    end ;
end ;

function getEndIf(arguments : TStringList; position : Integer) : Integer ;
var Commande : String ;
begin
    Result := position ;
    
    while position < arguments.count do
    begin
        Commande := extractCommande(arguments[position]) ;

        if Commande = 'if'
        then
            position := getEndIf(arguments, position + 1)
        else begin
            if Commande = 'endif'
            then begin
                Result := position + 1 ;
                break ;
            end ;

            Inc(position) ;
        end ;
    end ;
end ;

function getElseIfElseEndIf(arguments : TStringList; position : Integer) : Integer ;
var Commande : String ;
begin
    Result := position ;
    
    while position < arguments.count do
    begin
        Commande := extractCommande(arguments[position]) ;

        if Commande = 'if'
        then
            position := getEndIf(arguments, position + 1)
        else begin
            if (Commande = 'elseif') or (Commande = 'else') or (Commande = 'endif')
            then begin
                Result := position + 1 ;
                break ;
            end ;

            Inc(position) ;
        end ;
    end ;
end ;

function ifCommande(arguments : TStringList) : Integer ;
var endcondition : TStringList ;
    NewLine : Integer ;
    i : Integer ;
    isElseIf : Boolean ;
    isElse : Boolean ;
    Commande : String ;
    TestElseIf : TStringList ;
begin
    arguments.Delete(0) ;
    Result := -1 ;
    isElse := False ;
    TestElseIf := TStringList.Create ;
    
    if GetValueOfStrings(arguments) = 1
    then begin
        endcondition := TStringList.Create ;
        EndCondition.Add('break') ;
        EndCondition.Add('goto') ;        

        if arguments[0] = falseValue
        then begin
            EndCondition.Add('endif') ;

            isElseIf := False ;

            i := CurrentLineNumber + 1 ;

            while i < CodeList.Count do
            begin
                Commande := extractCommande(CodeList[i]) ;

                if Commande = 'if'
                then begin
                    { -1 pour prendre en compte le endif }
                    i := getEndIf(CodeList, i+1) - 1 ;
                end ;

                if Commande = 'endif'
                then begin
                    Result := i ;
                    break ;
                end
                else if Commande = 'else'
                then begin
                    { + 1 pour pointer sur l'instruction suivante }                
                    Inc(i) ;
                    isElse := True ;
                    break ;
                end
                else if Commande = 'elseif'
                then begin
                    isElseIf := True ;
                    isElse := True ;

                    ExplodeStrings(CodeList[i], TestElseIf) ;

                    { supprime elseif }
                    TestElseIf.Delete(0) ;

                    GetValueOfStrings(TestElseIf) ;

                    if TestElseIf[0] = falseValue
                    then begin
                        isElseIf := False ;
                        isElse := False ;

                        { se positionner au prochain elseif ou else ou endif}
                        i := getElseIfElseEndIf(CodeList, i + 1) - 2 ;                        
                    end
                    else begin
                        { + 1 pour pointer sur l'instruction suivante }
                        Inc(i) ;
                        break ;
                    end ;
                end ;

                Inc(i) ;
            end ;

            if isElse
            then begin
                if isElseIf
                then begin
                    EndCondition.Add('else') ;
                    EndCondition.Add('elseif') ;
                end ;

                Result := ReadCode(i, endcondition, CodeList) ;

                Commande := extractCommande(LowerCase(CodeList[result - 1])) ;

                if Commande = 'break'
                then begin
                    { on a un break dans un if. Or le if c'est un bloc à part. Il
                      faut donc sortir du bloc if et du bloc précédent }
                    Result := findEndBoucle(CodeList, Result) ;
                end
                else if commande = 'goto'
                then begin
                    { -1 pour la ligne précédent + -1 pour le fait qu'il y ait un Inc
                      à la fin de ReadCode }
                    Result := Result - 2 ;
                    isGoto := True ;
                end
                else if Result <> -1
                then begin
                    if isElseIf
                    then begin
                        { Si c'est un elseif on doit pointer sur la ligne suivante }
                        Result := getEndIf(CodeList, Result) ;
                    end ;

                    { On pointe sur la ligne suivante après le endif. Or dans
                      ReadCode, après la commande on fait un Inc(Line) }
                    Dec(Result) ;
                end ;
            end ;
        end
        else begin
            endcondition.Add('else') ;
            endcondition.Add('endif') ;

            NewLine := ReadCode(CurrentLineNumber + 1, endcondition, CodeList) ;

            if NewLine > -1
            then begin
                Commande := extractCommande(LowerCase(CodeList[NewLine - 1])) ;

                if commande = 'break'
                then begin
                    { on a un break dans un if. Or le if c'est un bloc à part. Il
                      faut donc sortir du bloc if et du bloc précédent }
                    Result := findEndBoucle(CodeList, NewLine) ;
                end
                else if commande = 'goto'
                then begin
                    { -1 pour la ligne précédent + -1 pour le fait qu'il y ait un Inc
                      à la fin de ReadCode }
                    Result := NewLine - 2 ;
                    isGoto := True ;
                end
                else if NewLine <> -1
                then begin
                    Result := NewLine - 1 ;

                    if Commande = 'else'
                    then begin
                        i := CurrentLineNumber + 1 ;

                        while i < CodeList.Count do
                        begin
                            Commande := extractCommande(CodeList[i]) ;

                            if Commande = 'if'
                            then begin
                                { -1 pour prendre en compte le endif }
                                i := getEndIf(CodeList, i+1) - 1 ;
                            end ;

                            if Commande = 'endif'
                            then begin
                                Result := i ;
                                break ;
                            end ;

                            Inc(i) ;
                        end ;
                    end ;
                end ;
            end ;
        end ;
        
        endcondition.Free ;
    end
    else
        ErrorMsg(sMissingOperator) ;

    TestElseIf.Free ;        
end ;

function whileCommande(arguments : TStringList) : Integer ;
var endcondition : TStringList ;
    condition : TStringList ;
    ConditionLine : Integer ;
    i : Integer ;
    ExitWhile : boolean ;
    Commande : String ;
begin
    Result := -1 ;
    arguments.Delete(0) ;
    condition := TStringList.Create ;
    condition.Text := arguments.Text ;

    if GetValueOfStrings(arguments) = 1
    then begin
        endcondition := TStringList.Create ;
        endcondition.Add('endwhile') ;
        endcondition.Add('break') ;
        endcondition.Add('goto') ;

        ConditionLine := CurrentLineNumber ;
        ExitWhile := False ;
        
        while arguments[0] = trueValue do
        begin
            OverTimeAndMemory ;
            
            if GlobalError
            then
                break ;

            i := ReadCode(ConditionLine + 1, endcondition, CodeList) ;

            if i = -1
            then begin
                ExitWhile := True ;
                break ;
            end ;

            Commande := extractCommande(LowerCase(CodeList[i - 1])) ;

            if Commande = 'break'
            then
                break
            else if commande = 'goto'
            then begin
                { -1 pour la ligne précédent + -1 pour le fait qu'il y ait un Inc
                  à la fin de ReadCode }
                Result := i - 2 ;
                isGoto := True ;
                ExitWhile := True ;
                break ;
            end ;

            arguments.Text := condition.Text ;
            GetValueOfStrings(arguments) ;
        end ;

        if not ExitWhile
        then
            Result := findEndBoucle(CodeList, ConditionLine + 1) ;

        endcondition.Free ;
    end
    else
        ErrorMsg(sMissingOperatorOrValue) ;
        
    condition.Free ;
end ;

function repeatUntilCommande(arguments : TStringList) : Integer ;
var endcondition : TStringList ;
    ConditionLine : Integer ;
    index : Integer ;
    ExitUntil : boolean ;
    Commande : String ;
begin
    endcondition := TStringList.Create ;
    endcondition.Add('until') ;
    endcondition.Add('break') ;
    endcondition.Add('goto') ;

    Result := - 1 ;

    ConditionLine := CurrentLineNumber ;
    ExitUntil := False ;

    repeat
        OverTimeAndMemory ;
        if GlobalError
        then
            break ;
            
        index := ReadCode(ConditionLine + 1, endcondition, CodeList) ;

        if index = -1
        then begin
            ExitUntil := True ;
            break ;
        end ;

		Commande := extractCommande(LowerCase(CodeList[index - 1])) ;

        if Commande = 'break'
        then
            break
        else if commande = 'goto'
        then begin
            { -1 pour la ligne précédent + -1 pour le fait qu'il y ait un Inc
              à la fin de ReadCode }
            Result := index - 2 ;
            isGoto := True ;
            ExitUntil := True ;
            break ;
        end ;

        ExplodeStrings(CodeList[index - 1], arguments) ;

        arguments.Delete(0) ;

        if GetValueOfStrings(arguments) <> 1
        then begin
            ErrorMsg(sMissingOperatorOrValue) ;
            break ;
        end ;
    until arguments[0] = trueValue ;

    if not ExitUntil
    then
        Result := findEndBoucle(CodeList, ConditionLine + 1) ;

    endcondition.Free ;
end ;

function forCommande(arguments : TStringList) : Integer ;
var endcondition : TStringList ;
    ConditionLine : Integer ;
    i : Integer ;
    variable : string ;
    startValue : integer ;
    endValue : integer ;
    increment : Integer ;
    Error : Boolean ;
    ExitFor : boolean ;
    Commande : String ;
begin
    Result := - 1 ;

    if arguments.Count > 4
    then begin
         Error := True ;

         if isVar(arguments[1])
         then begin
             { supprime le for }
             arguments.Delete(0) ;

             variable := arguments[0] ;

             { supprime la variable }
             arguments.Delete(0) ;

             if arguments[0] = '='
             then begin
                 { supprime le = }
                 arguments.Delete(0) ;

                 if GetValueOfStrings(arguments) = 5
                 then begin
                     if isNumeric(arguments[0])
                     then
                         if LowerCase(arguments[1]) = 'to'
                         then
                             if isNumeric(arguments[2])
                             then
                                 if LowerCase(arguments[3]) = 'step'
                                 then
                                     if isNumeric(arguments[4])
                                     then
                                         Error := False
                                     else
                                         ErrorMsg(sIncValNotValidNum)
                                 else
                                      ErrorMsg(sMissingStep)
                             else
                                 ErrorMsg(sEndValNotValidNum)
                         else
                             ErrorMsg(sMissingTo)
                     else
                         ErrorMsg(sStartValNotValidNum)
                 end
                 else
                     ErrorMsg(sMissingOrTooArguments) ;
             end
             else
                 ErrorMsg(sMissingEqual) ;

            if not Error
            then begin
                {
                 0 = valeur de depart
                 1 = to
                 2 = valeur d'arrivée
                 3 = step
                 4 = incrément
                }
                startValue := MyStrToInt(arguments[0]) ;
                endValue := MyStrToInt(arguments[2]) ;
                increment := MyStrToInt(arguments[4]) ;

                endcondition := TStringList.Create ;
                endcondition.Add('break') ;
                endcondition.Add('endfor') ;
                endcondition.Add('goto') ;

                ConditionLine := CurrentLineNumber ;

                setVar(variable, IntToStr(startValue)) ;

                ExitFor := False ;

                while MyStrToInt(getVar(variable)) <= endValue do
                begin
                    OverTimeAndMemory ;
                    if GlobalError
                    then
                        break ;

                    i := ReadCode(ConditionLine + 1, endcondition, CodeList) ;

                    if i = -1
                    then begin
                        ExitFor := True ;
                        break ;
                    end ;

                    Commande := extractCommande(LowerCase(CodeList[i - 1])) ;

                    if Commande = 'break'
                    then
                        break
                    else if commande = 'goto'
                    then begin
                        { -1 pour la ligne précédent + -1 pour le fait qu'il y ait un Inc
                          à la fin de ReadCode }
                        Result := i - 2 ;
                        isGoto := True ;
                        ExitFor := True ;                        
                        break ;
                    end ;
                    
                    setVar(variable, IntToStr(MyStrToInt(getVar(variable)) + increment)) ;
                end ;

                if not ExitFor
                then
                    Result := findEndBoucle(CodeList, ConditionLine + 1) ;

                endcondition.Free ;
            end ;
         end
         else
             ErrorMsg(Format(sNotAVariable, [arguments[0]])) ;

    end
    else
        ErrorMsg(sInvalidFor) ;
end ;

function findEndBoucle(CodeList : TStringList; start : Integer) : Integer ;
Var Index : Integer ;
    Commande : String ;
begin
    Result := -1 ;
    { se positionner à la fin de la boucle }
    Index := Start ;

    while Index < CodeList.Count do
    begin
        Commande := LowerCase(extractCommande(CodeList[Index])) ;

        if (Commande = 'for') or (Commande = 'while') or (Commande = 'repeat')
        then
            Index := findEndBoucle(CodeList, Index + 1)
        else if (Commande = 'endfor') or (Commande = 'endwhile') or (Commande = 'until')
        then begin
            Result := Index ;
            break ;
        end ;

        Inc(Index) ;
    end
end ;

procedure isNumericCommande(arguments : TStringList) ;
begin
    GetValueOfStrings(arguments) ;

    if arguments.count > 0
    then begin
        if arguments.count < 2
        then begin
            if isNumeric(arguments[0])
            then
                ResultFunction := trueValue
            else
                ResultFunction := FalseValue ;
        end
        else
            ErrorMsg(sTooArguments) ;
    end
    else
        ErrorMsg(sMissingargument) ;
end ;

procedure isFloatCommande(arguments : TStringList) ;
begin
    GetValueOfStrings(arguments) ;

    if arguments.count > 0
    then begin
        if arguments.count < 2
        then begin
            if isFloat(arguments[0])
            then
                ResultFunction := trueValue
            else
                ResultFunction := FalseValue ;
        end
        else
            ErrorMsg(sTooArguments) ;
    end
    else
        ErrorMsg(sMissingargument) ;
end ;

procedure isIntegerCommande(arguments : TStringList) ;
begin
    GetValueOfStrings(arguments) ;

    if arguments.count > 0
    then begin
        if arguments.count < 2
        then begin
            if isInteger(arguments[0])
            then
                ResultFunction := trueValue
            else
                ResultFunction := FalseValue ;
        end
        else
            ErrorMsg(sTooArguments) ;
    end
    else
        ErrorMsg(sMissingargument) ;
end ;

procedure isStringCommande(arguments : TStringList) ;
begin
    GetValueOfStrings(arguments) ;

    if arguments.count > 0
    then begin
        if arguments.count < 2
        then begin
            if isFloat(arguments[0]) or Variables.isArray(arguments[0])
            then
                ResultFunction := falseValue
            else
                ResultFunction := trueValue ;
        end
        else
            ErrorMsg(sTooArguments) ;
    end
    else
        ErrorMsg(sMissingargument) ;
end ;

procedure isArrayCommande(arguments : TStringList) ;
begin
    GetValueOfStrings(arguments) ;

    if arguments.count > 0
    then begin
        if arguments.count < 2
        then begin
            if isVar(arguments[0])
            then begin
                { supprime la variable }
                arguments.Delete(0);

                if Variables.isArray(arguments[0])
                then
                    ResultFunction := trueValue
                else
                    ResultFunction :=  FalseValue ;
            end
            else begin
                ErrorMsg(Format(sNotAVariable, [arguments[0]])) ;
            end ;
        end
        else
            ErrorMsg(sTooArguments) ;
    end
    else
        ErrorMsg(sMissingargument) ;
end ;

procedure arrayPushCommande(arguments : TStringList) ;
var tableau : String ;
    i : Integer ;
begin
    tableau := arguments[0] ;
    arguments.delete(0) ;

    GetValueOfStrings(arguments) ;

    if arguments.count > 1
    then begin
        if isVar(tableau)
        then begin
            for i := 0 to arguments.Count - 1 do
            begin
                Variables.Push(tableau, arguments[i])
            end ;
        end
        else begin
            ErrorMsg(Format(sNotAVariable, [tableau])) ;
        end ;
    end
    else
        ErrorMsg(sMissingargument) ;
end ;

procedure arrayInsertCommande(arguments : TStringList) ;
var tableau : String ;
begin
    tableau := arguments[0] ;
    arguments.delete(0) ;

    GetValueOfStrings(arguments) ;

    if arguments.count > 0
    then begin
        if arguments.count < 3
        then begin
            if isVar(tableau)
            then begin
                if Variables.Insert(tableau, MyStrToInt(arguments[0]), arguments[1]) = False
                then
                    ErrorMsg(sCantInsertDataInArray) ;
            end
            else begin
                ErrorMsg(Format(sNotAVariable, [tableau])) ;
            end ;
        end
        else
            ErrorMsg(sTooArguments) ;
    end
    else
        ErrorMsg(sMissingargument) ;
end ;

procedure arrayPopCommande(arguments : TStringList) ;
begin
    if arguments.count > 0
    then begin
        if arguments.count < 2
        then begin
            if isVar(arguments[0])
            then begin
                if not Variables.isSet(arguments[0])
                then
                    WarningMsg(Format(sVarDoesExist, [arguments[0]])) ;

                ResultFunction := Variables.Pop(arguments[0]) ;
            end
            else begin
                ErrorMsg(Format(sNotAVariable, [arguments[0]])) ;
            end ;
        end
        else
            ErrorMsg(sTooArguments) ;
    end
    else
        ErrorMsg(sMissingargument) ;
end ;

procedure arrayExchangeCommande(arguments : TStringList) ;
var nb : Integer ;
    index1, index2 : Integer ;
begin
    if arguments.count > 0
    then begin
        if arguments.count < 4
        then begin
            if isVar(arguments[0])
            then begin
                if isInteger(arguments[1])
                then begin
                    if isInteger(arguments[2])
                    then begin
                        nb := Variables.length(arguments[0]) ;
                        index1 := MyStrToInt(arguments[1]) ;
                        index2 := MyStrToInt(arguments[2]) ;

                        if (index1 <= nb) and (index1 > 0)
                        then begin
                            if (index2 <= nb) and (index2 > 0)
                            then begin
                                if not Variables.Exchange(arguments[0], index1 - 1, index2 - 1)
                                then
                                    ErrorMsg(sCanExchangeData)
                            end
                            else
                                ErrorMsg(sSndIndexOutBound)
                        end
                        else
                            ErrorMsg(sFirstIndexOutBound)
                    end
                    else
                        ErrorMsg(sSndMustInt)
                end
                else
                    ErrorMsg(sFirstMustInt)
            end
            else begin
                ErrorMsg(Format(sNotAVariable, [arguments[0]])) ;
            end ;
        end
        else
            ErrorMsg(sTooArguments) ;
    end
    else
        ErrorMsg(sMissingargument) ;            
end ;


procedure arrayChunkCommande(arguments : TStringList) ;
begin
    if arguments.count > 0
    then begin
        if arguments.count < 3
        then begin
            if isVar(arguments[0])
            then begin
                if isInteger(arguments[1])
                then begin
                    if not Variables.Chunk(arguments[0], MyStrToInt(arguments[1]))
                    then
                        ErrorMsg(sCantChunk)
                end
                else
                    ErrorMsg(sSizeMustBeInt)
            end
            else begin
                ErrorMsg(Format(sNotAVariable, [arguments[0]])) ;
            end ;
        end
        else
            ErrorMsg(sTooArguments) ;
    end
    else
        ErrorMsg(sMissingargument) ;
end ;

procedure arrayMergeCommande(arguments : TStringList) ;
begin
    if arguments.count > 0
    then begin
        ResultFunction := Variables.Merge(arguments)
    end
    else
        ErrorMsg(sMissingargument) ;
end ;

procedure arrayCreateCommande(arguments : TStringList) ;
begin
    // inutile d'appeler DeleteVirguleAndParenthese car appelé automatiquement
    // si dans fonction dans ListFunction
    ResultFunction := Variables.CreateArray(arguments) ;
end ;

procedure ArrayFillCommande(arguments : TStringList) ;
var variableName : string ;
begin
    if arguments.Count > 0
    then begin
        variableName := arguments[0] ;

        if isVar(variableName)
        then begin
            { supprime la variable }
            arguments.Delete(0);

            if GetValueOfStrings(arguments) = 1
            then
                Variables.ArrayFill(variableName, arguments[0])
            else
                ErrorMsg(sMissingOperator) ;
        end
        else begin
            ErrorMsg(Format(sNotAVariable ,[variableName])) ;
        end ;
    end
    else
        ErrorMsg(sMissingargument) ;
end ;

procedure arraySortCommande(arguments : TStringList) ;
var resultat : string ;
begin
    if arguments.count > 0
    then begin
        if arguments.count < 2
        then begin
            resultat := arguments[0] ;
            if Variables.arraySort(resultat)
            then
                ResultFunction := resultat
            else begin
                ResultFunction := '' ;
                WarningMsg(sMustBeAnArray)
            end ;
        end
        else
            ErrorMsg(sTooArguments) ;
    end
    else
        ErrorMsg(sMissingargument) ;
end ;

procedure arraySearchCommande(arguments : TStringList) ;
var resultat : integer ;
begin
    if arguments.count > 0
    then begin
        if arguments.count < 4
        then begin
            resultat := Variables.arraySearch(arguments[0], arguments[1], arguments[2] = trueValue) ;

            ResultFunction := IntToStr(resultat) ;
        end
        else
            ErrorMsg(sTooArguments) ;
    end
    else
        ErrorMsg(sMissingargument) ;
end ;

procedure GlobalCommande(arguments : TStringList) ;
var i : Integer ;
    NameOfVar : String ;
begin
    if Variables <> FirstVariables
    then begin
        if arguments.count > 0
        then begin
            for i := 0 to arguments.Count - 1 do
            begin
                NameOfVar := arguments[i] ;

                GlobalVariable.Add(NameOfVar) ;

                if not FirstVariables.isSet(NameOfVar)
                then
                    WarningMsg(Format(sVariableDoesntExist, [NameOfVar])) ;

                Variables.Add(NameOfVar, FirstVariables.Give(NameOfVar)) ;
            end ;
        end
        else
            ErrorMsg(sMissingargument) ;
    end
    else
        WarningMsg(sGlobalInMain) ;
end ;

procedure isHexaCommande(arguments : TStringList) ;
begin
    GetValueOfStrings(arguments) ;

    if arguments.count > 0
    then begin
        if arguments.count < 2
        then begin
            if isHexa(arguments[0])
            then
                ResultFunction := trueValue
            else
                ResultFunction := FalseValue ;
        end
        else
            ErrorMsg(sTooArguments) ;
    end
    else
        ErrorMsg(sMissingargument) ;
end ;

procedure functionExistsCommande(arguments : TStringList) ;
begin
    if arguments.count > 0
    then begin
        if arguments.count < 2
        then begin
		    {$IFDEF FPC}
		    if Assigned(ListFunction.Give(arguments[0])) or (ListProcedure.Give(arguments[0]) <> -1)
			{$ELSE}
            if Assigned(@ListFunction.Give(arguments[0])) or (ListProcedure.Give(arguments[0]) <> -1)
			{$ENDIF}
            then
                ResultFunction := trueValue
            else
                ResultFunction := FalseValue ;
        end
        else
            ErrorMsg(sTooArguments) ;
    end
    else
        ErrorMsg(sMissingargument) ;
end ;

procedure functionDeleteCommande(arguments : TStringList) ;
var i : Integer ;
begin
    if arguments.count > 0
    then begin
        for i := 0 to arguments.count - 1 do
        begin
            ResultFunction := trueValue ;

			{$IFDEF FPC}
			if Assigned(ListFunction.Give(arguments[0]))
			{$ELSE}
            if Assigned(@ListFunction.Give(arguments[0]))
			{$ENDIF}
            then
                ListFunction.Delete(arguments[0])
            else if ListProcedure.Give(arguments[0]) <> -1
            then
                ListProcedure.Delete(arguments[0])
            else begin
                WarningMsg(Format(sCantFindFunctionToDelete, [arguments[0]])) ;
                ResultFunction := FalseValue ;
            end ;
        end ;
    end
    else
        ErrorMsg(sMissingargument) ;
end ;

procedure functionRenameCommande(arguments : TStringList) ;
begin
    if arguments.count > 0
    then begin
        if arguments.count < 3
        then begin
            if ListFunction.Rename(arguments[0], arguments[1]) or ListProcedure.Rename(arguments[0], arguments[1])
            then
                ResultFunction := trueValue
            else
                ResultFunction := FalseValue ;
        end
        else
            ErrorMsg(sTooArguments) ;
    end
    else
        ErrorMsg(sMissingargument) ;
end ;

function gotoNextEndSwitch(Start : Integer; Code : TStringList) : Integer ;
var nb : Integer ;
    arguments : TStringList ;
    Commande : String ;
begin
    Result := -1 ;

    nb := Code.Count ;
    arguments := TStringList.Create ;

    while start < nb do
    begin
        Commande := LowerCase(ExtractCommande(Code[start])) ;

        if (Commande = 'endswitch')
        then begin
            Result := start ;
            break ;
        end
        else if (Commande = 'switch')
        then begin
            if gotoNextEndSwitch(Start, Code) = -1
            then
                break ;
        end ;

        Inc(start) ;
    end ;

    arguments.Free ;
end ;

function gotoNextCaseOrEndSwitch(Start : Integer; Code : TStringList) : Integer ;
var nb : Integer ;
    arguments : TStringList ;
    Commande : String ;
begin
    Result := - 1 ;
    
    nb := Code.Count ;
    arguments := TStringList.Create ;

    while start < nb do
    begin
        Commande := LowerCase(ExtractCommande(Code[start])) ;

        if (Commande = 'case') or (Commande = 'endswitch') or (Commande = 'default')
        then begin
            Result := start ;
            break ;
        end
        else if (Commande = 'switch')
        then
            if gotoNextEndSwitch(Start,Code) = -1
            then
                break ;

        Inc(start) ;
    end ;

    arguments.Free ;
end ;

function switchCommande(arguments : TStringList) : Integer ;
var i, nb : Integer ;
    Condition : String ;
    endcondition : TStringList ;
    ExitSwitch : Boolean ;
    commande : String ;
    CondOk : Boolean ;
begin
    Result := -1;

    { Supprime le case }
    arguments.Delete(0) ;

    GetValueOfStrings(arguments) ;

    if (not GlobalError) and (not GlobalQuit)
    then begin
        if arguments.count > 0
        then begin
            if arguments.count < 3
            then begin
                endcondition := TStringList.Create ;

                Result := CurrentLineNumber + 1 ;
                nb := CodeList.Count ;
                Condition := arguments[0] ;
                ExitSwitch := False ;

                while Result < nb do
                begin
                    ExplodeStrings(CodeList[Result], arguments) ;
                    GetValueOfStrings(arguments) ;

                    if (not GlobalError) and (not GlobalQuit)
                    then begin
                        if arguments.Count > 0
                        then begin
                            commande := LowerCase(arguments[0]) ;
                            if commande = 'default'
                            then begin
                                endcondition.Add('endswitch') ;
                                endcondition.Add('break') ;
                                endcondition.Add('goto') ;

                                Inc(Result) ;

                                Result := ReadCode(Result, endcondition, CodeList) ;

			                    Commande := extractCommande(LowerCase(CodeList[Result - 1])) ;

                                if commande = 'goto'
                                then begin
                                    { -1 pour la ligne précédent + -1 pour le fait qu'il y ait un Inc
                                      à la fin de ReadCode }
                                    Result := Result - 2 ;
                                    isGoto := True ;
                                end
                                else if commande = 'break'
                                then
                                    break ;

                                ExitSwitch := True ;

                                break ;
                            end
                            else if commande = 'case'
                            then begin
                                { Si la ligne case est correct }
                                if arguments.Count > 1
                                then begin
                                    CondOk := False ;

                                    for i := 1 to arguments.count -1 do
                                    begin
                                        if arguments[i] = Condition
                                        then begin
                                            CondOk := True ;
                                            break ;
                                        end ;
                                    end ;
                                    
                                    { test la condition }
                                    if CondOk
                                    then begin
                                        endcondition.Add('case') ;
                                        endcondition.Add('break') ;
                                        endcondition.Add('default') ;
                                        endcondition.Add('endswitch') ;
                                        endcondition.Add('goto') ;

                                        { Pointe sur la ligne après le case }
                                        Inc(Result) ;

                                        Result := ReadCode(Result, endcondition, CodeList) ;

                                        if Result = -1
                                        then begin
                                            ExitSwitch := True ;
                                            break ;
                                        end
                                        else begin
                                            Commande := extractCommande(LowerCase(CodeList[Result - 1])) ;

                                            if commande = 'default'
                                            then
                                                break
                                            else if commande = 'break'
                                            then
                                                break
                                            else if commande = 'endswitch'
                                            then begin
                                                { décrémente de 1 car Inc dans ReadCode }
                                                Dec(Result) ;
                                                ExitSwitch := True ;
                                                break ;
                                            end
                                            else if commande = 'goto'
                                            then begin
                                                { -1 pour la ligne précédent + -1 pour le fait qu'il y ait un Inc
                                                  à la fin de ReadCode }
                                                Result := Result - 2 ;
                                                isGoto := True ;
                                                ExitSwitch := True ;
                                                break ;
                                            end
                                            else begin
                                                ErrorMsg(sMissingBreakInCase) ;
                                                ExitSwitch := True ;
                                                Result := -1 ;
                                                break ;
                                            end ;
                                        end ;
                                    end
                                    else begin
                                         { Aller au prochain case ou endswitch
                                           -1 car Inc(Result) à la fin de la boucle }
                                         i := gotoNextCaseOrEndSwitch(Result + 1, CodeList) - 1;

                                         { Un bug dans Delphi fait que Result = -1 est
                                           toujours vrai }
                                         if i = -1
                                         then begin
                                             break ;
                                         end ;

                                         Result := i  ;
                                    end ;
                                end
                                else begin
                                    ErrorMsg(sMissingCompInCase) ;
                                end ;
                            end
                        end ;

                        Inc(Result) ;
                    end ;
                end ;

                if not ExitSwitch
                then
                    Result := gotoNextEndSwitch(Result, CodeList) ;

                endcondition.Free ;
            end
            else
                ErrorMsg(sTooArguments) ;
        end
        else
            ErrorMsg(sMissingargument) ;
    end ;
end ;

procedure chrCommande(arguments : TStringList) ;
begin
    if arguments.Count = 1
    then begin
        if isInteger(arguments[0])
        then
            ResultFunction := chr(MyStrToInt(arguments[0]))
        else
            ErrorMsg(Format(sNoNumber, [arguments[0]])) ;
    end
    else if arguments.Count > 1
    then
        ErrorMsg(sTooArguments)
    else
        ErrorMsg(sMissingArgument) ;
end ;

procedure ordCommande(arguments : TStringList) ;
var i : Integer ;
begin
    if arguments.Count = 1
    then begin
        for i := 1 to Length(arguments[0]) do
        begin
            ResultFunction := IntToStr(ord(arguments[0][i])) ;
        end ;
    end
    else if arguments.Count > 1
    then
        ErrorMsg(sTooArguments)
    else
        ErrorMsg(sMissingArgument) ;
end ;

procedure countCommande(arguments : TStringList) ;
var nb : Integer ;
    varname : string ;
begin
    if arguments.Count = 1
    then begin
        if isVar(arguments[0])
        then begin
            nb := Length(arguments[0]) ;
            varname := arguments[0] ;

            { Si variable $$xxx }
            if nb > 2
            then begin
                if arguments[0][2] = '$'
                then begin
                    varname := copy(arguments[0], 2, nb - 1) ;
                    arguments[0] := getVar(varname) ;
                end ;
            end ;

            if Variables.isSet(varname) = False
            then
                WarningMsg(Format(sVariableDoesntExist, [varname])) ;


            ResultFunction := IntToStr(Variables.Length(arguments[0])) ;
        end
        else
            ErrorMsg(sInvalidVarName) ;
    end
    else if arguments.Count > 1
    then
        ErrorMsg(sTooArguments)
    else
        ErrorMsg(sMissingArgument) ;
end ;

procedure loadCommande(arguments : TStringList) ;
begin
    if arguments.Count = 1
    then begin
        if LoadExtension(arguments[0])
        then
            ResultFunction := trueValue
        else
            ResultFunction := falseValue ;
    end
    else if arguments.Count > 1
    then
        ErrorMsg(sTooArguments)
    else
        ErrorMsg(sMissingArgument) ;
end ;

procedure unLoadCommande(arguments : TStringList) ;
begin
    if arguments.Count = 1
    then begin
        UnLoadExtension(arguments[0])
    end
    else if arguments.Count > 1
    then
        ErrorMsg(sTooArguments)
    else
        ErrorMsg(sMissingArgument) ;
end ;

procedure isExtLoadCommande(arguments : TStringList) ;
begin
    if arguments.Count = 1
    then begin
        if isExtensionLoaded(arguments[0])
        then
            ResultFunction := TrueValue
        else
            ResultFunction := FalseValue ;
    end
    else if arguments.Count > 1
    then
        ErrorMsg(sTooArguments)
    else
        ErrorMsg(sMissingArgument) ;
end ;

procedure evalCommande(arguments : TStringList) ;
var ListOfCode : TStringList ;
    { Liste des fichiers. Utilisé pour include_once et erreur }
    OldListOfFile : TStringList ;
    { Fait la corespondance entre ligne et n° de ligne dans le fichier }
    OldLineToFileLine : TStringList ;
    { Fait la correspondance entre la ligne et le fichier }
    OldLineToFile : TStringList ;
    endCondition : TStringList ;
    i : Integer ;
begin
    if arguments.Count = 1
    then begin
        ListOfCode := TStringList.Create ;

        if Variables.InternalisArray(arguments[0])
        then
            Variables.explode(ListOfCode, arguments[0])
        else
            ListOfCode.Add(arguments[0]) ;

        { On fait correspondre les lignes executées et le code }
        { Liste des fichiers. Utilisé pour include_once et erreur }
        OldListOfFile := ListOfFile ;
        { Fait la corespondance entre ligne et n° de ligne dans le fichier }
        OldLineToFileLine := LineToFileLine ;
        { Fait la correspondance entre la ligne et le fichier }
        OldLineToFile := LineToFile ;

        endCondition := TStringList.Create ;

        ListOfFile := TStringList.Create ;
        LineToFileLine := TStringList.Create ;
        LineToFile := TStringList.Create ;

        ListOfFile.Add('eval command') ;

        for i := 0 to ListOfCode.Count - 1 do
        begin
            LineToFileLine.Add(IntToStr(i + 1)) ;
            LineToFile.Add('0') ;
        end ;

        endCondition.Add('exit') ;
        
        ReadCode(0, endCondition, ListOfCode) ;

        ListOfFile.Free ;
        LineToFileLine.Free ;
        LineToFile.Free ;

        { Liste des fichiers. Utilisé pour include_once et erreur }
        ListOfFile := OldListOfFile ;
        { Fait la corespondance entre ligne et n° de ligne dans le fichier }
        LineToFileLine := OldLineToFileLine ;
        { Fait la correspondance entre la ligne et le fichier }
        LineToFile := OldLineToFile ;

        endCondition.Free ;

        ListOfCode.Free ;

        if GlobalError and not GlobalQuit
        then begin
            ResultFunction := FalseValue ;
            
            { Quoi qu'il se passe on n'arrête pas le script parce que l'erreur est
              dans l'eval et pas dans le script même }
            GlobalError := False ;
        end
        else
            ResultFunction := TrueValue ;
    end
    else if arguments.Count > 1
    then
        ErrorMsg(sTooArguments)
    else
        ErrorMsg(sMissingArgument) ;

end ;

procedure callCommande(arguments : TStringList) ;
var Commande : String ;
    fonction : ModelProcedure ;
begin
    if arguments.Count > 1
    then begin
        Commande := arguments[0] ;
        arguments.Delete(0) ;

        fonction := ListFunction.Give(Commande) ;
        ResultFunction := '' ;

        if @fonction <> nil
        then begin
            fonction(arguments) ;
        end
        else begin
            if not CallExtension(Commande, arguments)
            then
                ExecuteUserProcedure(Commande, arguments) ;
        end ;
    end
    else
        ErrorMsg(sMissingArgument) ;
end ;

procedure GetCookieCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := VarGetPostCookieFileData.GetCookie(arguments[0]) ;
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


procedure includeCommande(arguments : TStringList) ;
var OldDocRoot : String ;
begin
    if arguments.count = 1
    then begin
        OldDocRoot := doc_root ;
        doc_root := CurrentRootOfFile[MyStrToInt(LineToFile[CurrentLineNumber])] ;

        // ajouter @>
        CodeList.Insert(CurrentLineNumber, EndSwsTag) ;
        LineToFile.Insert(CurrentLineNumber, LineToFile[CurrentLineNumber]) ;
        LineToFileLine.Insert(CurrentLineNumber, LineToFileLine[CurrentLineNumber]) ;

        Inc(CurrentLineNumber) ;

        //ajouter <@
        CodeList.Insert(CurrentLineNumber + 1, StartSwsTag) ;
        LineToFile.Insert(CurrentLineNumber + 1, LineToFile[CurrentLineNumber]) ;
        LineToFileLine.Insert(CurrentLineNumber + 1, LineToFileLine[CurrentLineNumber]) ;

        // Inclue le code
        LoadCode(arguments[0], CurrentLineNumber + 1) ;

        doc_root := OldDocRoot ;

        { On supprime la ligne include('xxx') }
        CodeList.Delete(CurrentLineNumber);
        LineToFile.Delete(CurrentLineNumber) ;
        LineToFileLine.Delete(CurrentLineNumber);

        { Par défaut le nouveau fichier est considéré comme du HTML }
        isExecutableCode := False ;

        Dec(CurrentLineNumber) ;
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

procedure includeOnceCommande(arguments : TStringList) ;
var OldDocRoot : String ;
begin
    if arguments.count = 1
    then begin
        OldDocRoot := doc_root ;
        doc_root := CurrentRootOfFile[MyStrToInt(LineToFile[CurrentLineNumber])] ;

        if ListOfFile.IndexOf(Realpath(arguments[0])) = -1
        then begin
            includeCommande(arguments) ;
        end
        else begin
            { On supprime la ligne include('xxx') }
            CodeList.Delete(CurrentLineNumber);
            LineToFile.Delete(CurrentLineNumber) ;
            LineToFileLine.Delete(CurrentLineNumber);
            
            Dec(CurrentLineNumber) ;
        end ;

        doc_root := OldDocRoot ;
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

procedure arrayrSortCommande(arguments : TStringList) ;
var resultat : string ;
begin
    if arguments.count > 0
    then begin
        if arguments.count < 2
        then begin
            resultat := arguments[0] ;
            
            if Variables.arrayrSort(resultat)
            then
                ResultFunction := resultat
            else begin
                ResultFunction := '' ;
                WarningMsg(sMustBeAnArray)
            end ;
        end
        else
            ErrorMsg(sTooArguments) ;
    end
    else
        ErrorMsg(sMissingargument) ;
end ;

procedure arrayRevCommande(arguments : TStringList) ;
var Liste : TStringList ;
    len, i : Integer ;
    tmp : String ;
begin
    if arguments.Count = 1
    then begin
        if Variables.InternalisArray(arguments[0])
        then begin
            Liste := TStringList.Create ;
            Variables.explode(Liste, arguments[0]);
            len := Liste.Count - 1 ;

            for i := 0 to (len div 2) do
            begin
                tmp := Liste[i] ;
                Liste[i] := Liste[len - i] ;
                Liste[len - i] := Tmp ;
            end ;

            ResultFunction := Variables.CreateArray(Liste) ;

            Liste.Free ;
        end
        else begin
            WarningMsg(sMustBeAnArray) ;
        end ;
    end
    else if arguments.Count > 1
    then
        ErrorMsg(sTooArguments)
    else
        ErrorMsg(sMissingArgument) ;
end ;

procedure arrayShiftCommande(arguments : TStringList) ;
var Liste : TStringList ;
    tmp : String ;
begin
    if arguments.Count = 1
    then begin
        if isVar(arguments[0])
        then begin
            tmp := getVar(arguments[0]);

            if Variables.InternalisArray(tmp)
            then begin
                Liste := TStringList.Create ;
                Variables.explode(Liste, tmp);

                if Liste.Count > 0
                then begin
                    ResultFunction := Liste[0] ;

                    Liste.Delete(0) ;

                    tmp := Variables.CreateArray(Liste) ;

                    setVar(arguments[0], tmp) ;
                end ;

                Liste.Free ;
            end
            else begin
                WarningMsg(sMustBeAnArray) ;
            end ;
        end
        else begin
            ErrorMsg(Format(sNotAVariable, [arguments[0]])) ;
        end ;
    end
    else if arguments.Count > 1
    then
        ErrorMsg(sTooArguments)
    else
        ErrorMsg(sMissingArgument) ;
end ;

procedure arraySliceCommande(arguments : TStringList) ;
var Liste : TStringList ;
    len, offset, i : Integer ;
begin
    if (arguments.Count > 1) and (arguments.Count < 4)
    then begin
        if Variables.InternalisArray(arguments[0])
        then begin
            Liste := TStringList.Create ;
            Variables.explode(Liste, arguments[0]);

            offset := MyStrToInt(arguments[1]) - 1 ;

            if arguments.Count = 3
            then begin
                len := MyStrToInt(arguments[2]) ;
            end
            else begin
                len := Liste.Count ;
            end ;

            if offset < 0
            then begin
                offset := Liste.Count + offset ; // + car offset est négatif
            end ;

            { Supprime tout ce qu'il y a avant offset }
            for i := 0 to offset - 1 do
            begin
                Liste.Delete(0) ;
            end ;

            { Supprime tout ce qu'il y a après }
            for i := len to Liste.Count - 1 do
            begin
                Liste.Delete(len) ;
            end ;

            ResultFunction := Variables.CreateArray(Liste) ;

            Liste.Free ;
        end
        else begin
            WarningMsg(sMustBeAnArray) ;
        end ;
    end
    else if arguments.Count > 4
    then
        ErrorMsg(sTooArguments)
    else
        ErrorMsg(sMissingArgument) ;
end ;

procedure arraySpliceCommande(arguments : TStringList) ;
var oldArray : TStringList ;
    NewArray : TStringList ;
    len, offset, i : Integer ;
    tmp : string ;
begin
    if (arguments.Count > 1) and (arguments.Count < 4)
    then begin
        if isVar(arguments[0])
        then begin
            tmp := getVar(arguments[0]) ;

            if Variables.InternalisArray(tmp)
            then begin
                OldArray := TStringList.Create ;
                NewArray := TStringList.Create ;

                Variables.explode(OldArray, tmp);

                offset := MyStrToInt(arguments[1]) - 1 ;

                if arguments.Count = 3
                then begin
                    len := MyStrToInt(arguments[2]) ;
                end
                else begin
                    len := OldArray.Count ;
                end ;

                if offset < 0
                then begin
                    offset := OldArray.Count + offset ; // + car offset est négatif
                end ;

                { Supprime tout ce qu'il y a avant offset }
                for i := 0 to offset - 1 do
                begin
                    NewArray.Add(OldArray[0]) ;
                    OldArray.Delete(0) ;
                end ;

                { Supprime tout ce qu'il y a après }
                for i := len to OldArray.Count - 1 do
                begin
                    NewArray.Add(OldArray[len]) ;
                    OldArray.Delete(len) ;
                end ;

                ResultFunction := Variables.CreateArray(OldArray) ;

                SetVar(arguments[0], Variables.CreateArray(NewArray)) ;

                OldArray.Free ;
                NewArray.Free ;
            end
            else begin
                WarningMsg(sMustBeAnArray) ;
            end ;
        end
        else begin
            ErrorMsg(Format(sNotAVariable, [arguments[0]])) ;
        end ;
    end
    else if arguments.Count > 4
    then
        ErrorMsg(sTooArguments)
    else
        ErrorMsg(sMissingArgument) ;
end ;

procedure arrayShuffleCommande(arguments : TStringList) ;
var Liste : TStringList ;
begin
    if arguments.Count = 1
    then begin
        if Variables.InternalisArray(arguments[0])
        then begin
            Liste := TStringList.Create ;
            Variables.explode(Liste, arguments[0]);

            ListShuffle(Liste) ;

            ResultFunction := Variables.CreateArray(Liste) ;

            Liste.Free ;
        end
        else begin
            WarningMsg(sMustBeAnArray) ;
        end ;
    end
    else if arguments.Count > 1
    then
        ErrorMsg(sTooArguments)
    else
        ErrorMsg(sMissingArgument) ;
end ;

procedure FunctionDisabled(arguments : TStringList) ;
begin
    WarningMsg(sFunctionDisabled) ;
end ;

procedure CoreFunctionsInit ;
begin
    ListFunction.Add('length', @LengthCommande, true) ;
    ListFunction.Add('isnumeric', @isNumericCommande, true) ;
    ListFunction.Add('isfloat', @isNumericCommande, true) ;
    ListFunction.Add('isinteger', @isIntegerCommande, true) ;
    ListFunction.Add('isstring', @isStringCommande, true) ;
    ListFunction.Add('isarray', @isArrayCommande, true) ;
    ListFunction.Add('array', @arrayCreateCommande, true) ;
    ListFunction.Add('ishexa', @ishexaCommande, true) ;
    ListFunction.Add('arraymerge', @arraymergeCommande, true) ;
    ListFunction.Add('arraysort', @arraySortCommande, true) ;
    ListFunction.Add('arraysearch', @arraySearchCommande, true) ;
    ListFunction.Add('functionexists', @functionexistsCommande, true) ;
    ListFunction.Add('functiondelete', @functionDeleteCommande, true) ;
    ListFunction.Add('functionrename', @functionRenameCommande, true) ;
    ListFunction.Add('chr', @chrCommande, true) ;
    ListFunction.Add('ord', @ordCommande, true) ;
    ListFunction.Add('extensionload', @loadCommande, true) ;
    ListFunction.Add('extensionunload', @unLoadCommande, true) ;
    ListFunction.Add('isextensionloaded', @isExtLoadCommande, true) ;
    ListFunction.Add('eval', @evalCommande, true) ;    
    ListFunction.Add('call', @callCommande, true) ;
    ListFunction.Add('getcookie', @getCookieCommande, true) ;
    ListFunction.Add('include', @includeCommande, true) ;
    ListFunction.Add('includeonce', @includeOnceCommande, true) ;
    ListFunction.Add('arrayrsort', @arrayrSortCommande, true) ;
    ListFunction.Add('arrayrev', @arrayRevCommande, true) ;
    ListFunction.Add('arrayslice', @arraySliceCommande, true) ;
    ListFunction.Add('arrayshuffle', @arrayShuffleCommande, true) ;    

    ListFunction.Add('isset', @isSetCommande, false) ;
    ListFunction.Add('set', @SetCommande, false) ;
    ListFunction.Add('unset', @unSetCommande, false) ;
    ListFunction.Add('arraypush', @arrayPushCommande, false) ;
    ListFunction.Add('arrayinsert', @arrayinsertCommande, false) ;
    ListFunction.Add('arraypop', @arraypopCommande, false) ;
    ListFunction.Add('arrayexchange', @arrayexchangeCommande, false) ;
    ListFunction.Add('arraychunk', @arraychunkCommande, false) ;
    ListFunction.Add('arrayfill', @arrayfillCommande, false) ;
    ListFunction.Add('global', @globalCommande, false) ;
    ListFunction.Add('count', @countCommande, false) ;
    ListFunction.Add('arrayshift', @arrayShiftCommande, false) ;
    ListFunction.Add('arraysplice', @arraySpliceCommande, false) ;
end ;

end.
