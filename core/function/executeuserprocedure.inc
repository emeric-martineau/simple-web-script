{*****************************************************************************
 * ExecuteUserProcedure
 * MARTINEAU Emeric
 *
 * Fonction qui ex�cute une fonction d�finit par l'utilisateur
 *
 * Param�tres d'entr�e :
 *   - asCommande : nom de la fonction � ex�cuter
 *   - aoCurrentLine : TStringList contenant les param�tres
 *
 * Retour : La ligne o� il faut se positionner si goto sinon -1
 *****************************************************************************}
function ExecuteUserProcedure(asCommande : String; aoCurrentLine : TStringList) : integer ;
var
    { Ligne de d�but de la proc�dure }
    liLineOfProcedure : Integer ;
    { TStringList contenant les conditions de fin }
    loEndCondition : TStringList ;
    { Ligne de retour de la proc�dure utilisateur. -1 indique une erreur }
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
    { Ancienne position de la ligne courante }
    liOldCurrentLineNumber : Integer ;
    { Ancienne variables globales si app�le de fonction utilisateur dans fonction utilisateur }
    loOldGlobalVariable : TStringList ;

    procedure setFixedParams(aoListArguments : TStringList; aoCurrentLine : TStringList) ;
    var
        { Position de fin des param�tres fixe }
        liFinFixedArgs : Integer ;
        { Compteur de boucle }
        liIndex : Integer ;
    begin
        { se place au premier param�tre optionnel }
        liFinFixedArgs := aoListArguments.IndexOf('=') - 1 ;

        if liFinFixedArgs < 0
        then begin
            { se place au premier param�tre ... }
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
        { D�but des param�tres optionnels }
        liDebut : Integer ;
        { Position de la variable dans les arguments }
        liPosVarInCall : Integer ;
        { Fin des param�tres optionnels }
        liFin : Integer ;
        { Compteur de boucles }
        liIndex : Integer ;
        { Valeur � affecter � la variable }
        lsVal : String ;
    begin
        { se place au premier param�tre optionnel }
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
                { A-t-on 3 �l�ments ; $var=val }
                if liIndex + 2 < aoListArguments.Count
                then begin
                    if isVar(aoListArguments[liIndex])
                    then begin
                        if aoListArguments[liIndex + 1] = '='
                        then begin
                            lsVal := aoListArguments[liIndex + 2] ;

                            { L'�l�ment est-il d�finit lors de l'appel de la fonction }
                            if liPosVarInCall < aoCurrentLine.Count
                            then begin
                                lsVal := aoCurrentLine[liPosVarInCall] ;
                            end
                            else begin
                                { pour r�cup�rer variable $true ou $false ou une
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
        { Position de d�but }
        liDebut : Integer ;
        { Compteur de boucle }
        liIndex : Integer ;
    begin
        liDebut := ListArguments.IndexOf('...') ;

        if liDebut = -1
        then begin
            liDebut := ListArguments.Count -1 ;
        end ;

        { Cr�er les param�tres }
        goVariables.Add('$argcount', IntToStr(CurrentLine.Count - liDebut)) ;

        for liIndex := liDebut to CurrentLine.Count - 1 do
        begin
            goVariables.Add('$args[' + IntToStr(liIndex + 1) + ']', CurrentLine[liIndex]) ;
        end ;
    end ;
begin
    { On n'a pas effectu� la commande return pour l'instant }
    gbReturn := False ;

    { Par d�faut la proc�dure ne renvoit aucune donn�e }
    gsResultFunction := '' ;

    { Sauvegarde les anciennes variables globales }
    loOldGlobalVariable := goGlobalVariable ;
    { Cr�er un nouvelle objet de variable globale pour la fonction en cours }
    goGlobalVariable := TStringList.Create() ;

    liOldCurrentLineNumber := giCurrentLineNumber ;

    Result := -1 ;
    
    { V�rifie si on ne trouve pas la commande dans la liste des
      proc�dures }
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

        { Cr�er les variables locales }
        goVariables := TVariables.Create ;

        goConstantes.Add('#_scriptname', goListOfFile[goLineToFile[giCurrentLineNumber]]) ;

        loListArguments := TStringList.Create ;

        loListArguments.Text := goListProcedure.GiveArguments(asCommande) ;

        liPosEqual := loListArguments.IndexOf('=') ;
        liPos3Dot := loListArguments.IndexOf('...') ;

        if  (liPosEqual = -1) and (liPos3Dot <> -1)
        then begin
            { Param�tre fixe + optionnel }
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
            { Param�tre non fixe + pas optionnel }
            if aoCurrentLine.Count >= (liPosEqual - 1)
            then begin
                { A-t-on plus d'argument pass� lors de l'appel que de param�tre optionel }
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
            { Param�tre non fixe + optionnel }
            ErrorMsg(csNotEqualAnd3Dot) ;
        end
        else begin
            { On a que des param�tres fixe }
            if loListArguments.Count = aoCurrentLine.Count
            then begin
                { La fonction n'a pas de param�tre optionnelles ni de ... }
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

        if (not gbQuit)
        then begin
            loEndCondition := TStringList.Create ;
            loEndCondition.Add('endfunc') ;

            { Cr�er la variable pour ne pas avoir de warning }
            //goVariables.Add('$result', '') ;

            liReturnLine := ReadCode(liLineOfProcedure, loEndCondition, goCodeList) ;

            { Si c'est la commande return on ne propage pas l'arr�t du script }
            if gbReturn = True
            then begin
               gbQuit := False ;

               gbReturn := False ;
            end ;

            FreeAndNil(loEndCondition) ;

            //gsResultFunction := goVariables.Give('$result') ;

            if (liReturnLine >= 0) and (gbQuit = False)
            then begin
                Result := liReturnLine ;

                { Bascule les donn�es de Variables dans les variables globales }
                for liIndexGlobalVariable := 0 to goGlobalVariable.Count - 1 do
                begin
                    lsNameOfVar := goGlobalVariable[liIndexGlobalVariable] ;

                    goFirstVariables.Add(lsNameOfVar, goVariables.Give(lsNameOfVar));
                    
                    if goFirstVariables <> loOldVariables
                    then begin
                        { Il faut recopier la valeur des variables globales dans les
                          variables de la proc�dure qui appelait }
                        loOldVariables.Add(lsNameOfVar, goVariables.Give(lsNameOfVar)) ;
                    end ;
                end ;
            end ;

            FreeAndNil(goGlobalVariable) ;
            
            { Restaure les anciennes variables globales }
            goGlobalVariable := loOldGlobalVariable ;
        end ;

        { Supprime la fonction de la liste des fonctions en cours d'ex�cution pour
          permettre � WarningMsg et ErrorMsg d'afficher le nom de la fonction
          d'o� vient le message }
        goCurrentFunctionName.Delete(goCurrentFunctionName.Count - 1) ;
        FreeAndNil(goVariables) ;
        FreeAndNil(loListArguments) ;
        goVariables := loOldVariables ;
    end ;

    giCurrentLineNumber := liOldCurrentLineNumber ;
end ;