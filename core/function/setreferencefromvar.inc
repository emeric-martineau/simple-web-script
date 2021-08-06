{*****************************************************************************
 * SetReferenceFromVar
 * MARTINEAU Emeric
 *
 * Donne une valeur suivant un variable pointer
 *
 * Paramètres d'entrée :
 *   - asVarNamePointed : variable contenant le pointer de variable qu'il faut
 *                        écrire.
 *   - asValue : valeur à donner
 *
 *****************************************************************************}
procedure SetReferenceFromVar(asVarNamePointed : string; asValue : string) ;
var
    { Partie pointer sur TVariable }
    lsPointerOfVar : string ;
    { Partie nom de variable }
    lsVarName : String ;
    { Position des crochets }
    liStartTab : Integer ;
    { Variabel temporaire }
    lsTmp : String ;
    { Partie entre crochet }
    lsTab : String ;
    { Pointer sur TVariable }
    loPointedVariable : TVariables ;
begin
    liStartTab := pos('[', asVarNamePointed) ;

    if liStartTab > 0
    then begin
        lsTmp := copy(asVarNamePointed, 1, liStartTab - 1) ;
        lsTab := copy(asVarNamePointed, liStartTab, Length(asVarNamePointed) - liStartTab + 1) ;

        asVarNamePointed := lsTmp ;
    end
    else begin
        lsTab := '' ;
    end ;

    { On récupère la valeur de la variable pour la traiter }
    if goVariables.isArray(asVarNamePointed)
    then begin
        asVarNamePointed := goVariables.Give(asVarNamePointed + lsTab) ;
    end
    else begin
        asVarNamePointed := goVariables.Give(asVarNamePointed) ;
    end ;
        
    lsPointerOfVar := getPointeurOfVariable(asVarNamePointed) ;
    lsVarName := getVarNameOfVariable(asVarNamePointed) ;

    if (lsPointerOfVar <> '') and (lsVarName <> '')
    then begin
        loPointedVariable := goPointerOfVariables.Give(lsPointerOfVar) ;

        if loPointedVariable <> nil
        then begin
            loPointedVariable.Add(lsVarName + lsTab, asValue) ;
        end ;
    end
    else begin
        ErrorMsg(csNotValidPointer) ;
    end ;
end ;