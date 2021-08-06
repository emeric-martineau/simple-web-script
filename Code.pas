unit Code;
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
 * This unit run code
 ******************************************************************************}
interface

{$I config.inc}

uses SysUtils, CoreFunctions, Variable, classes,
     UserFunction, UserLabel, UnitMessages, GetPostCookieFileData ;

Const
      trueValue : string = '1' ;
      falseValue : string = '0' ;
      version : string = '0.0.5' ;
      StartSwsTag : String = '<@' ;
      EndSwsTag : String = '@>' ;

Var { Contietn le code à exécuter }
    CodeList : TStringList ;
    { Indique si une erreur est survenue }
    GlobalError : Boolean ;
    { Indique si on doit quitter absolument (exemple si commande "quit" dans le
      debuggeur ou la fonction die() }
    GlobalQuit : Boolean ;
    {$IFDEF COMMANDLINE}
    { Indique si on est en mode debugger }
    Debug : Boolean ;
    {$ENDIF}
    { Indique s'il faut afficher ou non les warnings }
    Warning : boolean ;
    { Ligne courante qu'on exécute dans CodeList }
    CurrentLineNumber : Integer ;
    { Liste des fichiers. Utilisé pour include_once et erreur }
    ListOfFile : TStringList ;
    { Fait la corespondance entre ligne et n° de ligne dans le fichier }
    LineToFileLine : TStringList ;
    { Fait la correspondance entre la ligne et le fichier }
    LineToFile : TStringList ;
    { Resultat des fonctions }
    ResultFunction : string ;
    { Pointeur sur la premier variable de type TVariables }
    FirstVariables : TVariables ;
    { Contient les variables passées en globales }
    GlobalVariable : TStringList ;
    { Indique si les labels ont été lus }
    LabelReading : Boolean ;
    { Indique s'il s'agit d'un goto qui nous fait arrêter pour ne pas l'afficher
      deux fois en debug }
    isGoto : Boolean ;
    { Nom de la fonction }
    CurrentFunctionName : TStringList ;
    { Indique de ne pas tenir compte de l'erreur, sert pour loadcode }
    NoError : Boolean ;
    { Contient les données transmisent pas Get, Post, Cookie, File }
    VarGetPostCookieFileData : TGetPostCookieFileData ;
    { Indique si l'entête à déjà été envoyé }
    isHeaderSend : boolean ;
    { Indique si l'header original a été nettoyé }
    isOriginalHeaderClear : boolean ;
    { header }
    Header : TStringList ;
    { Indique où a été envoyé l'entête }
    LineWhereHeaderSend : Integer ;
    { Contient les cookiees à afficher }
    ListCookie : TStringList ;
    { répertoire de base du doc_root }
    doc_root : String ;
    { Nombre de seconde maxi pour l'exécution du script }
    ElapseTime : Integer ;
    { Temps de début }
    StartTime : TDateTime ;
    { Taille maximum en mémoire }
    MaxMemorySize : Integer ;
    { Répertoire temporaire }
    tmpDir : String ;
    { Taille maxi des données post }
    MaxPostSize : Integer ;
    { chemin des extensions }
    ExtDir : String ;
    { liste des fonctions désactivées }
    DisabledFunctions : String ;
    { Indique si on cache un partie de la configuration dans swsinfo() }
    hideCfg : Boolean ;
    { indique si l'upload de fichier est autorisé }
    fileUpload : Boolean ;
    { Taille maximuum du fichier à uploader }
    uploadMaxFilesize : Integer ;
    { Contient le chemin relatif }
    CurrentRootOfFile : TStrings ;
    { Mode safe. Empache l'inclusion et la lecture de fichier en dehors du
      doc_root }
    SafeMode : Boolean ;
    { Indique si on est dans un code exécutable }
    isExecutableCode : Boolean ;
    { Indique que la sortie est mise en tampon }
    isOutPuBuffered : Boolean ;
    { Variables cotenant la sortie }
    OutPutContent : String ;
    { Nom de la fonction à appeler }
    OutPutFunction : String ;
    { Tableau contenant les noms de mois et de jour du script. Utiliser pour
      basculer sur les dates anglaises lorsque setcookie est appelé }
    UserShortMonthNames: array[1..12] of string;
    UserShortDayNames: array[1..7] of string;
    { Définit le séparateur de réel }
    FloatSeparator : String ;
    { Séparateur de milliers }
    MillierSeparator : String ;
    { Charset par défaut }
    DefaultCharset : string ;

function ReadCode(start : integer; endcondition : TStringList; VarCode : TStringList) : integer ;

implementation

uses functions, InternalFunction ;

{*******************************************************************************
 * Transforme une expression $var=vvv en set $var vvv
 ******************************************************************************}
procedure AssignVarWithEqual(Ligne : TStringList) ;
var Index : Integer ;
begin
    Index := Ligne.IndexOf('=') ;

    if Index <> -1
    then begin
        Ligne.Delete(Index) ;
        setCommande(Ligne) ;
    end
    else begin
        ErrorMsg(sAffectWithOutEqual) ;
    end ;
end ;

{*******************************************************************************
 * Vérifier qu'il y a un nom en paramètre
 * Vérifier que le fichier existe
 *
 * Pour chaque ligne du fichier
 *   séparer les divers élements
 *   appeler fonction correspondante
 * FinPour
 ******************************************************************************}
function ReadCode(start : integer; endcondition : TStringList; VarCode : TStringList) : integer ;
Var Line : Integer ;
    i : Integer ;
    CurrentLine : TStringList ;
    tmp : string ;
    Commande : string ;
    {$IFDEF COMMANDLINE}
    { Use for debug }
    DebugCommand : string ;
    MyCmdLineDebug : TStringList ;
    tmpDebug : string ;
    {$ENDIF}
    isEnd : Boolean ;
    fonction : ModelProcedure ;
label CheckIfCodeExecutable ;
begin
    isGoto := False ;
    isEnd := False ;
    Line := Start ;
    CurrentLine := TStringList.Create ;

    {$IFDEF COMMANDLINE}
    if Debug
    then begin
        MyCmdLineDebug := TStringList.Create ;
    end ;
    {$ENDIF}
    
    while Line < VarCode.Count do
    begin
        OverTimeAndMemory ;

        { Si une erreur dans une fonction }
        if GlobalError or GlobalQuit
        then begin
            Line := -1 ;
            break ;
        end ;

        if isGoto
        then begin
            Line := CurrentLineNumber ;
        end ;

CheckIfCodeExecutable :
        if not isExecutableCode
        then begin
            { Cherche un début de code }
            while (Line < VarCode.Count) do
            begin
                if (VarCode[Line] = StartSwsTag)
                then begin
                    break ;
                end ;

                { Affiche la ligne HTML }
                OutPutString(VarCode[Line], false) ;
                
                Inc(Line) ;
            end ;

            Inc(Line) ;

            isExecutableCode := not isExecutableCode ;
            goto CheckIfCodeExecutable ;
        end
        else begin
            { Cherche une fin de code }
            if Line < VarCode.Count
            then begin
                if VarCode[Line] = EndSwsTag
                then begin
                    Inc(Line) ;

                    isExecutableCode := not isExecutableCode ;

                    goto CheckIfCodeExecutable ;
                end ;
            end ;
        end ;

        { Avec le code ci dessus Line peut être supérieur à VarCode.Count }
        if Line > VarCode.Count
        then begin
            break ;
        end ;

        CurrentLineNumber := Line ;
        tmp := VarCode[Line] ;

        if (tmp[length(tmp)] <> ':')
        then begin
            { Indique numéro de ligne }
            Variables.Add('$_line', IntToStr(CurrentLineNumber + 1));
            Variables.Add('$_scriptname', ListOfFile[MyStrToInt(LineToFile[CurrentLineNumber])]) ;

            {$IFDEF COMMANDLINE}
            { Debuggage }
            if Debug and not isGoto
            then begin
                repeat
                    writeln('in ' + ListOfFile[MyStrToInt(LineToFile[CurrentLineNumber])]) ;
                    writeln(Format('[%s] %s', [LineToFileLine[CurrentLineNumber], tmp])) ;
                    write('> ') ;
                    readln(DebugCommand) ;

                    if DebugCommand <> ''
                    then begin
                        ExplodeStrings(DebugCommand, MyCmdLineDebug) ;

                        if LowerCase(MyCmdLineDebug[0]) = 'quit'
                        then begin
                            GlobalQuit := True ;
                            CurrentLine.Free ;
                            Result := -1 ;
                            Exit ;
                        end
                        else if LowerCase(MyCmdLineDebug[0]) = 'next'
                        then begin
                            // rien
                        end
                        else if LowerCase(MyCmdLineDebug[0]) = 'skip'
                        then begin
                            Inc(Line) ;
                            tmp := Trim(VarCode[Line]) ;
                        end
                        else if LowerCase(MyCmdLineDebug[0]) = 'setvar'
                        then begin
                            if MyCmdLineDebug.Count <> 3
                            then begin
                                writeln('Missing arguments or too arguments') ;
                            end
                            else begin
                                if isVar(MyCmdLineDebug[1])
                                then begin
                                    setVar(MyCmdLineDebug[1], MyCmdLineDebug[2]) ;
                                end
                                else begin
                                    writeln(Format(sNotAVariable, [MyCmdLineDebug[1]])) ;
                                end ;
                            end ;
                        end
                        else if LowerCase(MyCmdLineDebug[0]) = 'getvar'
                        then begin
                            if MyCmdLineDebug.Count <> 2
                            then begin
                                writeln('Missing arguments or too arguments') ;
                            end
                            else begin
                                if isVar(MyCmdLineDebug[1])
                                then begin
                                    writeln(getVar(MyCmdLineDebug[1])) ;
                                end
                                else begin
                                    writeln(Format(sNotAVariable, [MyCmdLineDebug[1]])) ;
                                end ;
                            end ;
                        end
                        else if LowerCase(MyCmdLineDebug[0]) = 'showvar'
                        then begin
                            for i := 0 to Variables.Count - 1 do
                            begin
                                writeln(Variables.GiveVarNameByIndex(i)) ;
                            end ;
                        end
                        else if LowerCase(MyCmdLineDebug[0]) = 'showlabel'
                        then begin
                            ReadLabel ;

                            for i := 0 to ListLabel.Count - 1 do
                            begin
                                tmpDebug := ListLabel.GiveLabelNameByIndex(i) ;
                                writeln(tmpDebug + ' ' +  IntToStr(ListLabel.Give(tmpDebug))) ;
                            end ;
                        end
                        else if LowerCase(MyCmdLineDebug[0]) = 'showproc'
                        then begin
                            for i := 0 to ListProcedure.Count - 1 do
                            begin
                                tmpDebug := ListProcedure.GiveFunctionNameByIndex(i) ;
                                write(tmpDebug + ' ' +  IntToStr(ListProcedure.Give(tmpDebug))) ;
                            end ;
                        end
                        else if LowerCase(MyCmdLineDebug[0]) = 'help'
                        then begin
                            writeln('quit : stop program') ;
                            writeln('next : goto next instruction') ;
                            writeln('skip : skip next line') ;
                            writeln('setvar $variable value : set variable value') ;
                            writeln('getvar $variable : get variable value') ;
                            writeln('showvar : show list of variable') ;
                            writeln('showlabel : show list of label') ;
                            writeln('showproc : show list of procedure') ;
                        end
                        else begin
                            writeln('Unknow command') ;
                        end ;
                    end ;
                until DebugCommand = 'next' ;
            end ;
            {$ENDIF}

            if isGoto
            then begin
                isGoto := False ;
            end ;

            ExplodeStrings(tmp, CurrentLine) ;

            { Si une erreur dans ExplodeStrings}
            if GlobalError or GlobalQuit
            then begin
                break ;
            end ;

            Commande := LowerCase(CurrentLine[0]) ;

            for i := 0 to EndCondition.Count - 1 do
            begin
                if Commande = EndCondition[i]
                then begin
                    { Se position à la ligne suivante }
                    Inc(Line) ;
                    isEnd := True ;
                    break ;
                end ;
            end ;

            if isEnd
            then begin
                break ;
            end ;

            if Commande = '@'
            then begin
                Warning := False ;
                CurrentLine.Delete(0) ;
                Commande := LowerCase(CurrentLine[0]) ;
            end
            else begin
                Warning := True ;
            end ;

            {****** COMANDES ******}
            if Commande = 'localgoto'
            then begin
                Line := gotoCommande(CurrentLine) ;
            end
            else if Commande = 'function'
            then begin
                Line := FunctionCommande(CurrentLine) ;
            end
            else if Commande = 'exit'
            then begin
                { Se position à la ligne suivante }
                Inc(Line) ;
                break ;
            end
            else if Commande = 'if'
            then begin
                Line := ifCommande(CurrentLine) ;
            end
            else if Commande = 'while'
            then begin
                Line := whileCommande(CurrentLine) ;
            end
            else if Commande = 'repeat'
            then begin
                Line := repeatUntilCommande(CurrentLine) ;
            end
            else if Commande = 'for'
            then begin
                Line := forCommande(CurrentLine) ;
            end
            else if Commande = 'switch'
            then begin
                Line := switchCommande(CurrentLine) ;
            end
            else if (Commande[1] = '$')
            then begin
                AssignVarWithEqual(CurrentLine) ;
            end
            else if (Commande[1] = '*')
            then begin
                if Length(Commande) > 2
                then begin
                    if Commande[2] = '$'
                    then begin
                        AssignVarWithEqual(CurrentLine) ;
                    end
                    else begin
                        ErrorMsg(Format(sNotAVariable, [Commande[1]]))
                    end ;
                end
                else begin
                     ErrorMsg(Format(sNotAVariable, [Commande[1]]))
                end ;
            end
            else begin
                Commande := CurrentLine[0] ;
                CurrentLine.Delete(0) ;
                DeleteVirguleAndParenthese(CurrentLine) ;

                fonction := ListFunction.Give(Commande) ;
                ResultFunction := '' ;

                if @fonction <> nil
                then begin
                    if ListFunction.isParse(Commande)
                    then begin
                        GetValueOfStrings(CurrentLine) ;
                    end ;
                    
                    fonction(CurrentLine) ;

                    { Include et IncludeOnce modifie CurrentLineNumber }
                    Line := CurrentLineNumber ;
                end
                else begin
                    GetValueOfStrings(CurrentLine) ;

                    if not CallExtension(Commande, CurrentLine)
                    then begin
                        i := ExecuteUserProcedure(Commande, CurrentLine) ;

                        if i <> -1
                        then begin
                            Line := i ;
                        end ;
                    end ;
                end ;
            end ;

            {**** END COMMANDE ****}

            { Le goto va se positionner sur la ligne. Si c'est extérieur à
              notre bloc on doit sortir }
            if Line < Start
            then begin
                break ;
            end ;
        end ;

        Inc(Line) ;
    end ;

    { Se position à la ligne suivante }
    Result := Line ;

    CurrentLine.Free ;
end ;

end.
