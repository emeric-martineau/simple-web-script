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
    { Indique le nombre de fois qu'on a une référence }
    liNumberReference : Integer ;
    { Valeur des pointeurs }
    lsResult : String ;
begin
    lbIsPointer := False ;
    // inutile cas fait dans le Variables.Add
    //asVariable := LowerCase(asVariable) ;

    if Length(asVariable) > 2
    then begin
        if asVariable[1] = '*'
        then begin
            { Pointer de asVariable }
            liNumberReference := 1 ;

            while (asVariable[liNumberReference] = '*') do
            begin
                Inc(liNumberReference) ;
            end ;

            asVariable := copy(asVariable, liNumberReference, Length(asVariable) - 1) ;

            { On doit décrémenter car on commence à 1 }
            Dec(liNumberReference) ;

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

        if (not gbQuit)
        then begin
            lsTab := '' ;

            for liIndex := 0 to loExplodeTab.Count - 1 do
            begin
                lsTab := lsTab + loExplodeTab[liIndex] ;
            end ;
        end ;

        FreeAndNil(loExplodeTab) ;

        asVariable := lsVarNameWithoutTab ;
    end
    else begin
        lsTab := '' ;
    end ;

    if (not gbQuit)
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
            if (liNumberReference = 1)
            then begin
                SetReferenceFromVar(asVariable + lsTab, asValue) ;
            end
            else begin
                { Pointeur multiple }
                lsResult := GetReferenceFromVar(asVariable) ;

                while (liNumberReference > 2) do
                begin
                    lsResult := GetReferenceFromPointer(lsResult, '') ;

                    Dec(liNumberReference) ;
                end ;

                SetReferenceFromPointer(lsResult, lsTab, asValue) ;
            end ;
        end
        else begin
            goVariables.Add(asVariable + lsTab, asValue) ;
        end ;
    end ;
end ;