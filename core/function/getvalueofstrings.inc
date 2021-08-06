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
    liEntier : Int64 ;
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
        lsCondition := aoArguments[liCompteur] ;

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
        lsCondition := aoArguments[liCompteur] ;

        if aoArguments[liCompteur] <> ''
        then begin
            if isVar(aoArguments[liCompteur])
            then begin
                aoArguments[liCompteur] := '"' + GetVar(aoArguments[liCompteur]) + '"' ;
            end
            else if IsConst(aoArguments[liCompteur])
            then begin
                aoArguments[liCompteur] := '"' + GetConst(aoArguments[liCompteur]) + '"' ;
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

                        if (gbQuit = False)
                        then begin
                            lFonction(loArgumentsAvecParentheses) ;
                        end
                        else begin
                            goto EndOfGetValueOfStrings ;
                        end ;
                    end
                    else begin
                        GetValueOfStrings(loArgumentsAvecParentheses) ;

                        if not CallExtension(aoArguments[liCompteur], loArgumentsAvecParentheses)
                        then begin
                            ExecuteUserProcedure(aoArguments[liCompteur], loArgumentsAvecParentheses) ;

                            { S'il y a eu une erreur }
                            if gbQuit
                            then begin
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
    if (not gbQuit)
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
    if (not gbQuit)
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
    if (not gbQuit)
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
    if (not gbQuit)
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
                            liEntier := MyStrToInt64(lsTmp1) ;
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
    if (not gbQuit)
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
                        liEntier := MyStrToInt64(lsTmp1) ;

                        liEntier := MyAbsPower(MyStrToInt64(lsTmp2), liEntier) ;

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
    if (not gbQuit)
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
                        liEntier := MyStrToInt64(lsTmp2) * MyStrToInt64(lsTmp1) ;
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
    if (not gbQuit)
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
                        liEntier := MyStrToInt64(lsTmp1) ;

                        if liEntier <> 0
                        then begin
                            liEntier := MyStrToInt64(lsTmp2) div liEntier ;
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
    if (not gbQuit)
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
                        liEntier := MyStrToInt64(lsTmp2) mod MyStrToInt64(lsTmp1) ;
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
    if (not gbQuit)
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
                        liEntier := MyStrToInt64(lsTmp2) + MyStrToInt64(lsTmp1) ;
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
    if (not gbQuit)
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
                        liEntier := MyStrToInt64(lsTmp2) shr MyStrToInt64(lsTmp1) ;
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
    if (not gbQuit)
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
                        liEntier := MyStrToInt64(lsTmp2) shl MyStrToInt64(lsTmp1) ;
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

    {ETAPE 13 : Chercher bitand  }
    if (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, 'bitand') ;

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
                          x   : bitand
                          x+2 : value
                          on remplace x par le résultat. Il faut alors supprimer
                          x et x+2}
                        liEntier := MyStrToInt64(lsTmp2) and MyStrToInt64(lsTmp1) ;
                        aoArguments[liIndexItem] := IntToStr(liEntier) ;
                        aoArguments.Delete(liIndexItem - 1);
                        { x-1 : ^
                          x  : value
                        }
                        aoArguments.Delete(liIndexItem);
                    end
                    else begin
                        ErrorMsg(Format(csNoOnString, ['bitand'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['bitand'])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 14 : Chercher &|  }
    if (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, 'bitxor') ;

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
                        liEntier := MyStrToInt64(lsTmp2) xor MyStrToInt64(lsTmp1) ;
                        aoArguments[liIndexItem] := IntToStr(liEntier) ;
                        aoArguments.Delete(liIndexItem - 1);
                        { x-1 : ^
                          x  : value
                        }
                        aoArguments.Delete(liIndexItem);
                    end
                    else begin
                        ErrorMsg(Format(csNoOnString, ['bitxor'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['bitxor'])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 15 : Chercher |  }
    if (not gbQuit)
    then begin
        liIndexItem := 0 ;
        
        repeat
            liIndexItem := IndexOfTStringList(liIndexItem, aoArguments, 'bitor') ;

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
                        liEntier := MyStrToInt64(lsTmp2) or MyStrToInt64(lsTmp1) ;
                        aoArguments[liIndexItem] := IntToStr(liEntier) ;
                        aoArguments.Delete(liIndexItem - 1);
                        { x-1 : ^
                          x  : value
                        }
                        aoArguments.Delete(liIndexItem);
                    end
                    else begin
                        ErrorMsg(Format(csNoOnString, ['bitor'])) ;
                        break ;
                    end ;
                end
                else begin
                    ErrorMsg(Format(csNoValueAfter, ['bitor'])) ;
                    break ;
                end ;
            end ;
        until liIndexItem = -1 ;
    end ;

    {ETAPE 16 : Chercher = }
    if (not gbQuit)
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
    if (not gbQuit)
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
    if (not gbQuit)
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
    if (not gbQuit)
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
    if (not gbQuit)
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
    if (not gbQuit)
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
    if (not gbQuit)
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
    if (not gbQuit)
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
    if (not gbQuit)
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
    if (not gbQuit)
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
    if (not gbQuit)
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
    if (not gbQuit)
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

    for liCompteur := 0 to aoArguments.Count - 1 do
    begin
        aoArguments[liCompteur] := GetString(aoArguments[liCompteur]) ;
    end ;

EndOfGetValueOfStrings :
    Result := aoArguments.Count ;

    FreeAndNil(loArgumentsAvecParentheses) ;
end ;