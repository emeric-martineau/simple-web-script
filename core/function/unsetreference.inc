{*****************************************************************************
 * UnSetReference
 * MARTINEAU Emeric
 *
 * Supprime une variable pointée
 *
 * Paramètres d'entrée :
 *   - asVarNamePointed : variable contenant le pointer de variable qu'il faut
 *                        écrire.
 *
 *****************************************************************************}
procedure UnSetReference(asVarNamePointed : string) ;
var
    { Partie pointeur de TVariable }
    lsPointerOfVar : String ;
    { Partie variable du pointer }
    lsVarName : String ;
    { Variable temporaire }
    lsTmp : String ;
    { Partie tableau de la variable }
    lsTab : String ;
    { Position de début des crochets }
    liStartTab : Integer ;
    { TVariable contenant la variable }
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
    asVarNamePointed := goVariables.Give(asVarNamePointed) ;
    lsPointerOfVar := getPointeurOfVariable(asVarNamePointed) ;
    lsVarName := getVarNameOfVariable(asVarNamePointed) ;

    if (lsPointerOfVar <> '') and (lsVarName <> '')
    then begin
        loPointedVariable := goPointerOfVariables.Give(lsPointerOfVar) ;

        if loPointedVariable <> nil
        then begin
            loPointedVariable.Delete(lsVarName + lsTab) ;
        end ;
    end
    else begin
        ErrorMsg(csNotValidPointer) ;
    end ;
end ;