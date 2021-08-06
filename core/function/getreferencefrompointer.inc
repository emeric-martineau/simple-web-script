{*****************************************************************************
 * GetReferenceFromPointer
 * MARTINEAU Emeric
 *
 * Retourne le valeur d'une variable en fonction de son pointer
 *
 * Paramètres d'entrée :
 *   - asVarNamePointed : pointer de variable qu'il faut
 *                        lire.
 *   - asTab : partie tableau
 *
 * Retour : pointer de variable
 *****************************************************************************}
function GetReferenceFromPointer(asPointer : string; asTab : String) : string;
var
    { Pointer de la structure TVariable }
    lsPointerOfVar : String ;
    { Nom de la variable }
    lsVarName : String ;
    { Structure contenant la variable }
    loPointedVariable : TVariables ;
begin
    { On récupère la valeur de la variable pour la traiter }
    lsPointerOfVar := GetPointeurOfVariable(asPointer) ;
    lsVarName := GetVarNameOfVariable(asPointer) ;
    Result := '' ;

    if (lsPointerOfVar <> '') and (lsVarName <> '')
    then begin
        loPointedVariable := goPointerOfVariables.Give(lsPointerOfVar) ;

        if loPointedVariable <> nil
        then begin
            Result := loPointedVariable.Give(lsVarName + asTab) ;
        end
        else begin
            Result := '' ;
        end ;
    end
    else begin
        ErrorMsg(csNotValidPointer) ;
    end ;
end ;