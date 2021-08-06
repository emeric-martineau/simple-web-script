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

            if (not gbQuit)
            then begin
                lsTab := '' ;

                for liIndexTab := 0 to loValueOfTab.Count - 1 do
                begin
                    lsTab := lsTab + loValueOfTab[liIndexTab] ;
                end ;
            end ;

            FreeAndNil(loValueOfTab) ;

            asVariable := lsTmpVarName ;
        end
        else begin
            lsTab := '' ;
        end ;

        if (not gbQuit)
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