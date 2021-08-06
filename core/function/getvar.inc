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
    { Indique le nombre de fois qu'on a une référence }
    liNumberReference : Integer ;
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

            if (not gbQuit)
            then begin
                lsTab := '' ;

                for liIndex := 0 to loExplodeTab.Count - 1 do
                begin
                    lsTab := lsTab + loExplodeTab[liIndex] ;
                end ;
            end ;

            FreeAndNil(loExplodeTab) ;

            asVariable := lsVarName ;
        end
        else begin
            lsTab := '' ;
        end ;

        if (not gbQuit)
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
                    liNumberReference := 1 ;

                    while (asVariable[liNumberReference] = '*') do
                    begin
                        Inc(liNumberReference) ;
                    end ;

                    lsVarName := copy(asVariable, liNumberReference, liLength - 1) ;

                    { On doit décrémenter car on commence à 1 }
                    Dec(liNumberReference) ;

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

        if (not gbQuit)
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
                if (liNumberReference = 1)
                then begin
                    { Pointeur simple }
                    Result := GetReferenceFromVar(lsVarName + lsTab) ;
                end
                else begin
                    { Pointeur multiple }
                    Result := GetReferenceFromVar(lsVarName) ;

                    while (liNumberReference > 2) do
                    begin
                        Result := GetReferenceFromPointer(Result, '') ;

                        Dec(liNumberReference) ;
                    end ;

                    Result := GetReferenceFromPointer(Result, lsTab) ;
                end ;
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