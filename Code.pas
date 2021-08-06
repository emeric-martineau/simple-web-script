unit Code;
{******************************************************************************
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
 ******************************************************************************
 *
 * Variables names :
 *  xyZZZZZ :
 *            x : l : local variable
 *                g : global variable/public variable
 *                p : private/protected variable
 *                a : argument variable
 *                c : constante
 *                
 *            y : s : string
 *                i : integer
 *                f : fload
 *                d : double
 *                a : array
 *                l : list<>
 *                o : object
 *                b : bool
 *                c : char
 *                l : long
 *                
 *           ZZZZ : name of variable 
 ******************************************************************************
 * This unit run code
 ******************************************************************************}
interface

{$I config.inc}

{$IFDEF FPC}
    {$mode objfpc}{$H+}
{$ENDIF}

uses SysUtils, UnitCore, Variable, classes,
     {$IFDEF COMMANDLINE}
     UserFunction, UserLabel,
     {$ENDIF}
     UnitMessages,
     Constantes ;

Const
      csTrueValue : string = '1' ;
      csFalseValue : string = '0' ;
      csVersion : string = '0.1.1' ;
      csStartSwsTag : String = '<@' ;
      csEndSwsTag : String = '@>' ;
      csMultiLineCommentStart : String = '/*' ;
      csMultiLineCommentStop : String = '*/' ;
      csSingleComment : String = '//' ;

Var { Contient le code � ex�cuter }
    goCodeList : TStringList ;
    { Indique si une erreur est survenue }
    gbError : Boolean ;
    { Indique si on doit quitter absolument (exemple si commande "quit" dans le
      debuggeur ou la fonction die() }
    gbQuit : Boolean ;
    {$IFDEF COMMANDLINE}
    { Indique si on est en mode debugger }
    gbDebug : Boolean ;
    {$ENDIF}
    { Indique s'il faut afficher ou non les warnings }
    gbWarning : boolean ;
    { Ligne courante qu'on ex�cute dans CodeList }
    giCurrentLineNumber : Integer ;
    { Liste des fichiers. Utilis� pour include_once et erreur }
    goListOfFile : TStringList ;
    { Fait la corespondance entre ligne et n� de ligne dans le fichier }
    goLineToFileLine : TStringList ;
    { Fait la correspondance entre la ligne et le fichier }
    goLineToFile : TStringList ;
    { Resultat des fonctions }
    gsResultFunction : string ;
    { Pointeur sur la premier variable de type TVariables }
    goFirstVariables : TVariables ;
    { Contient les variables pass�es en globales }
    goGlobalVariable : TStringList ;
    { Indique si les labels ont �t� lus }
    gbLabelReading : Boolean ;
    { Indique s'il s'agit d'un goto qui nous fait arr�ter pour ne pas l'afficher
      deux fois en debug }
    gbIsGoto : Boolean ;
    { Nom de la fonction utilisateur. Permet de faire le lien entre num�ro de ligne
      et nom de la fonction }
    goCurrentFunctionName : TStringList ;
    { Indique de ne pas tenir compte de l'erreur, sert pour ErrorMsg() }
    gbNoError : Boolean ;
    { Indique si l'ent�te � d�j� �t� envoy� }
    gbIsHeaderSend : boolean ;
    { Indique si l'header original a �t� nettoy� }
    gbIsOriginalHeaderClear : boolean ;
    { header }
    Header : TStringList ;
    { Indique o� a �t� envoy� l'ent�te }
    giLineWhereHeaderSend : Integer ;
    { r�pertoire de base du doc_root }
    gsDocRoot : String ;
    { Nombre de seconde maxi pour l'ex�cution du script }
    giElapseTime : Integer ;
    { Temps de d�but }
    goStartTime : TDateTime ;
    { Taille maximum en m�moire }
    giMaxMemorySize : Integer ;
    { R�pertoire temporaire }
    gsTmpDir : String ;
    { Taille maxi des donn�es post }
    giMaxPostSize : Integer ;
    { chemin des extensions }
    gsExtDir : String ;
    { liste des fonctions d�sactiv�es }
    gsDisabledFunctions : String ;
    { Indique si on cache un partie de la configuration dans swsinfo() }
    gbHideCfg : Boolean ;
    { indique si l'upload de fichier est autoris� }
    gbFileUpload : Boolean ;
    { Taille maximuum du fichier � uploader }
    giUploadMaxFilesize : Integer ;
    { Contient le chemin relatif }
    goCurrentRootOfFile : TStrings ;
    { Mode safe. Empache l'inclusion et la lecture de fichier en dehors du
      doc_root }
    gbSafeMode : Boolean ;
    { Indique si on est dans un code ex�cutable }
    gbIsExecutableCode : Boolean ;
    { Indique que la sortie est mise en tampon }
    gbIsOutPuBuffered : Boolean ;
    { Variables cotenant la sortie }
    gsOutPutContent : String ;
    { Nom de la fonction � appeler }
    gsOutPutFunction : String ;
    { Tableau contenant les noms de mois et de jour du script. Utiliser pour
      basculer sur les dates anglaises lorsque setcookie est appel� }
    gaUserShortMonthNames: array[1..12] of string;
    gaUserShortDayNames: array[1..7] of string;
    { D�finit le s�parateur de r�el }
    gsFloatSeparator : String ;
    { S�parateur de milliers }
    gsMillierSeparator : String ;
    { Charset par d�faut }
    gsDefaultCharset : string ;

function ReadCode(aiStart : integer; aoEndCondition : TStringList; aoCode : TStringList) : integer ;

implementation

uses Functions, InternalFunction ;

{*******************************************************************************
 * Transforme une expression $var=vvv en set $var vvv
 ******************************************************************************}
procedure AssignVarWithEqual(aoLigne : TStringList) ;
var liIndex : Integer ;
begin
    liIndex := aoLigne.IndexOf('=') ;

    if liIndex <> -1
    then begin
        aoLigne.Delete(liIndex) ;
        setCommande(aoLigne) ;
    end
    else begin
        ErrorMsg(csAffectWithOutEqual) ;
    end ;
end ;

{*****************************************************************************
 * ReadCode
 * MARTINEAU Emeric
 *
 * Ex�cute un code
 *
 * Param�tres d'entr�e :
 *   - aiStart : d�but du code,
 *   - aoEndCondition : TStringList avec les commandes qui mettent fin �
 *     l'ex�cution du code,
 *   - aoCode : Code � �c�cuter,
 *
 * Retour : position de fin du code,
 *****************************************************************************}
function ReadCode(aiStart : integer; aoEndCondition : TStringList; aoCode : TStringList) : integer ;
Var
    { Inique le num�ro de ligne � ex�cuter }
    liLine : Integer ;
    { Compteur de boucle et valeur de retour de fonction }
    liIndex : Integer ;
    { Ligne en cours d'ex�cution }
    loCurrentLine : TStringList ;
    { Variable temporaire pour certaine action (label...) }
    lsTmp : string ;
    { Commmande/Fonction � ex�cuter }
    lsCommande : string ;
    {$IFDEF COMMANDLINE}
    { Commande saisie dans la ligne de debug }
    lsDebugCommand : string ;
    { Liste Commmand + argument de debug }
    loMyCmdLineDebug : TStringList ;
    { Variable temporaire }
    lsTmpDebug : string ;
    {$ENDIF}
    { Indique s'il faut quitter la fonction (endfunc est rencontr�) }
    lbIsEnd : Boolean ;
    { Fonction a ex�cuter }
    lFonction : ModelProcedure ;

label CheckIfCodeExecutable ;
begin
    gbIsGoto := False ;
    lbIsEnd := False ;
    liLine := aiStart ;
    loCurrentLine := TStringList.Create ;

    {$IFDEF COMMANDLINE}
    if gbDebug
    then begin
        loMyCmdLineDebug := TStringList.Create ;
    end ;
    {$ENDIF}
    
    while liLine < aoCode.Count do
    begin
        OverTimeAndMemory ;

        { Si une erreur dans une fonction }
        if gbError or gbQuit
        then begin
            liLine := -1 ;
            break ;
        end ;

        if gbIsGoto
        then begin
            liLine := giCurrentLineNumber ;
        end ;

CheckIfCodeExecutable :
        if not gbIsExecutableCode
        then begin
            { Cherche un d�but de code }
            while (liLine < aoCode.Count) do
            begin
                if (aoCode[liLine] = csStartSwsTag)
                then begin
                    break ;
                end ;

                { Affiche la ligne HTML }
                OutPutString(aoCode[liLine], false) ;
                
                Inc(liLine) ;
            end ;

            Inc(liLine) ;

            gbIsExecutableCode := not gbIsExecutableCode ;
            goto CheckIfCodeExecutable ;
        end
        else begin
            { Cherche une fin de code }
            if liLine < aoCode.Count
            then begin
                if aoCode[liLine] = csEndSwsTag
                then begin
                    Inc(liLine) ;

                    gbIsExecutableCode := not gbIsExecutableCode ;

                    goto CheckIfCodeExecutable ;
                end ;
            end ;
        end ;

        { Avec le code ci dessus liLine peut �tre sup�rieur � VarCode.Count }
        if liLine > aoCode.Count
        then begin
            break ;
        end ;

        giCurrentLineNumber := liLine ;
        lsTmp := aoCode[liLine] ;

        if (lsTmp[length(lsTmp)] <> ':')
        then begin
            { Indique num�ro de ligne }
            goConstantes.Add('#_line', IntToStr(giCurrentLineNumber + 1));
            goConstantes.Add('#_scriptname', goListOfFile[MyStrToInt(goLineToFile[giCurrentLineNumber])]) ;

            {$IFDEF COMMANDLINE}
            { Debuggage }
            if gbDebug and not gbIsGoto
            then begin
                repeat
                    writeln('') ;
                    writeln('in ' + goListOfFile[MyStrToInt(goLineToFile[giCurrentLineNumber])]) ;
                    writeln(Format('[%s] %s', [goLineToFileLine[giCurrentLineNumber], lsTmp])) ;
                    write('> ') ;
                    readln(lsDebugCommand) ;

                    if lsDebugCommand <> ''
                    then begin
                        ExplodeStrings(lsDebugCommand, loMyCmdLineDebug) ;

                        if LowerCase(loMyCmdLineDebug[0]) = 'quit'
                        then begin
                            gbQuit := True ;
                            loCurrentLine.Free ;
                            Result := -1 ;
                            Exit ;
                        end
                        else if LowerCase(loMyCmdLineDebug[0]) = 'next'
                        then begin
                            // rien
                        end
                        else if LowerCase(loMyCmdLineDebug[0]) = 'skip'
                        then begin
                            Inc(liLine) ;
                            lsTmp := Trim(aoCode[liLine]) ;
                        end
                        else if LowerCase(loMyCmdLineDebug[0]) = 'setvar'
                        then begin
                            if loMyCmdLineDebug.Count <> 3
                            then begin
                                writeln(csDebugToMany) ;
                            end
                            else begin
                                if isVar(loMyCmdLineDebug[1])
                                then begin
                                    setVar(loMyCmdLineDebug[1], loMyCmdLineDebug[2]) ;
                                end
                                else begin
                                    writeln(Format(csNotAVariable, [loMyCmdLineDebug[1]])) ;
                                end ;
                            end ;
                        end
                        else if LowerCase(loMyCmdLineDebug[0]) = 'getvar'
                        then begin
                            if loMyCmdLineDebug.Count <> 2
                            then begin
                                writeln(csDebugToMany) ;
                            end
                            else begin
                                if isVar(loMyCmdLineDebug[1])
                                then begin
                                    writeln(getVar(loMyCmdLineDebug[1])) ;
                                end
                                else begin
                                    writeln(Format(csNotAVariable, [loMyCmdLineDebug[1]])) ;
                                end ;
                            end ;
                        end
                        else if LowerCase(loMyCmdLineDebug[0]) = 'showvar'
                        then begin
                            for liIndex := 0 to goVariables.Count - 1 do
                            begin
                                writeln(goVariables.GiveVarNameByIndex(liIndex)) ;
                            end ;
                        end
                        else if LowerCase(loMyCmdLineDebug[0]) = 'showlabel'
                        then begin
                            ReadLabel ;

                            for liIndex := 0 to goListLabel.Count - 1 do
                            begin
                                lsTmpDebug := goListLabel.GiveLabelNameByIndex(liIndex) ;
                                writeln(lsTmpDebug + ' ' +  IntToStr(goListLabel.Give(lsTmpDebug))) ;
                            end ;
                        end
                        else if LowerCase(loMyCmdLineDebug[0]) = 'showproc'
                        then begin
                            for liIndex := 0 to goListProcedure.Count - 1 do
                            begin
                                lsTmpDebug := goListProcedure.GiveFunctionNameByIndex(liIndex) ;
                                write(lsTmpDebug + ' ' +  IntToStr(goListProcedure.Give(lsTmpDebug))) ;
                            end ;
                        end
                        else if LowerCase(loMyCmdLineDebug[0]) = 'showconst'
                        then begin
                            for liIndex := 0 to goConstantes.Count - 1 do
                            begin
                                writeln(goConstantes.GiveVarNameByIndex(liIndex)) ;
                            end ;
                        end
                        else if LowerCase(loMyCmdLineDebug[0]) = 'getconst'
                        then begin
                            if loMyCmdLineDebug.Count <> 2
                            then begin
                                writeln(csDebugToMany) ;
                            end
                            else begin
                                if IsConst(loMyCmdLineDebug[1])
                                then begin
                                    writeln(GetConst(loMyCmdLineDebug[1])) ;
                                end
                                else begin
                                    writeln(Format(csNotAConstante, [loMyCmdLineDebug[1]])) ;
                                end ;
                            end ;
                        end
                        else if LowerCase(loMyCmdLineDebug[0]) = 'help'
                        then begin
                            writeln('quit : stop program') ;
                            writeln('next : goto next instruction') ;
                            writeln('skip : skip next line') ;
                            writeln('setvar $variable value : set variable value') ;
                            writeln('getvar $variable : get variable value') ;
                            writeln('showvar : show list of variable') ;
                            writeln('showlabel : show list of label') ;
                            writeln('showproc : show list of procedure') ;
                            writeln('showconst : show list of constante') ;
                        end
                        else begin
                            writeln('Unknow command') ;
                        end ;
                    end ;
                until lsDebugCommand = 'next' ;
            end ;
            {$ENDIF}

            if gbIsGoto
            then begin
                gbIsGoto := False ;
            end ;
            
            ExplodeStrings(lsTmp, loCurrentLine) ;
            
            { Si une erreur dans ExplodeStrings}
            if gbError or gbQuit
            then begin
                break ;
            end ;

            lsCommande := LowerCase(loCurrentLine[0]) ;

            for liIndex := 0 to aoEndCondition.Count - 1 do
            begin
                if lsCommande = aoEndCondition[liIndex]
                then begin
                    { Se position � la ligne suivante }
                    Inc(liLine) ;
                    lbIsEnd := True ;
                    break ;
                end ;
            end ;

            if lbIsEnd
            then begin
                break ;
            end ;

            { Si on ne doit pas afficher de warning, la command commence par @ }
            if lsCommande = '@'
            then begin
                gbWarning := False ;
                loCurrentLine.Delete(0) ;
                lsCommande := LowerCase(loCurrentLine[0]) ;
            end
            else begin
                gbWarning := True ;
            end ;

            {****** COMANDES ******}
            if lsCommande = 'localgoto'
            then begin
                liLine := gotoCommande(loCurrentLine) ;
            end
            else if lsCommande = 'function'
            then begin
                liLine := FunctionCommande(loCurrentLine) ;
            end
            else if lsCommande = 'exit'
            then begin
                { Se position � la ligne suivante }
                Inc(liLine) ;
                break ;
            end
            else if lsCommande = 'if'
            then begin
                liLine := ifCommande(loCurrentLine) ;
            end
            else if lsCommande = 'while'
            then begin
                liLine := whileCommande(loCurrentLine) ;
            end
            else if lsCommande = 'repeat'
            then begin
                liLine := repeatUntilCommande(loCurrentLine) ;
            end
            else if lsCommande = 'for'
            then begin
                liLine := forCommande(loCurrentLine) ;
            end
            else if lsCommande = 'switch'
            then begin
                liLine := switchCommande(loCurrentLine) ;
            end
            else if (lsCommande[1] = '$')
            then begin
                AssignVarWithEqual(loCurrentLine) ;
            end
            else if (lsCommande[1] = '*')
            then begin
                if Length(lsCommande) > 2
                then begin
                    if lsCommande[2] = '$'
                    then begin
                        AssignVarWithEqual(loCurrentLine) ;
                    end
                    else begin
                        ErrorMsg(Format(csNotAVariable, [lsCommande[1]]))
                    end ;
                end
                else begin
                     ErrorMsg(Format(csNotAVariable, [lsCommande[1]]))
                end ;
            end
            else begin
                lsCommande := loCurrentLine[0] ;
                loCurrentLine.Delete(0) ;
                DeleteVirguleAndParenthese(loCurrentLine) ;

                lFonction := goInternalFunction.Give(lsCommande) ;
                gsResultFunction := '' ;

                {$IFDEF FPC}
                if lFonction <> nil
                {$ELSE}
                if @lFonction <> nil
                {$ENDIF}
                then begin
                    if goInternalFunction.isParse(lsCommande)
                    then begin
                        GetValueOfStrings(loCurrentLine) ;
                    end ;
                    
                    lFonction(loCurrentLine) ;

                    { Include et IncludeOnce modifie CurrentLineNumber }
                    liLine := giCurrentLineNumber ;
                end
                else begin
                    GetValueOfStrings(loCurrentLine) ;

                    if not CallExtension(lsCommande, loCurrentLine)
                    then begin
                        liIndex := ExecuteUserProcedure(lsCommande, loCurrentLine) ;

                        if liIndex <> -1
                        then begin
                            liLine := liIndex ;
                        end ;
                    end ;
                end ;
            end ;

            {**** END COMMANDE ****}

            { Le goto va se positionner sur la ligne. Si c'est ext�rieur �
              notre bloc on doit sortir }
            if liLine < aiStart
            then begin
                break ;
            end ;
        end ;

        Inc(liLine) ;
    end ;

    { Se position � la ligne suivante }
    Result := liLine ;

    loCurrentLine.Free ;
end ;

end.
