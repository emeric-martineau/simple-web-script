{*****************************************************************************
 * GetReferenceFromVar
 * MARTINEAU Emeric
 *
 * Retourne le valeur d'une variable en fonction de son pointer
 *
 * Paramètres d'entrée :
 *   - asVarNamePointed : variable contenant le pointer de variable qu'il faut
 *                        lire.
 *
 * Retour : pointer de variable
 *****************************************************************************}
function GetReferenceFromVar(asVarNamePointed : string) : string;
var
    { Pointer de la structure TVariable }
    lsPointerOfVar : String ;
    { Nom de la variable }
    lsVarName : String ;
    { Position des crochets }
    liStartTab : Integer ;
    { Variable temporaire }
    lsTmp : String ;
    { Partie de la variable avec les crochets }
    lsTab : String ;
    { Structure contenant la variable }
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
    lsPointerOfVar := GetPointeurOfVariable(asVarNamePointed) ;
    lsVarName := GetVarNameOfVariable(asVarNamePointed) ;
    Result := '' ;

    if (lsPointerOfVar <> '') and (lsVarName <> '')
    then begin
        loPointedVariable := goPointerOfVariables.Give(lsPointerOfVar) ;

        if loPointedVariable <> nil
        then begin
            Result := loPointedVariable.Give(lsVarName + lsTab) ;
        end
        else begin
            Result := '' ;
        end ;
    end
    else begin
        ErrorMsg(csNotValidPointer) ;
    end ;
end ;