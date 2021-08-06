{*****************************************************************************
 * SetReferenceFromPointer
 * MARTINEAU Emeric
 *
 * Donne une valeur suivant un variable pointer
 *
 * Paramètres d'entrée :
 *   - asPointer : le pointer de variable qu'il faut
 *                        écrire.
 *   - asTab : partie tableau
 *   - asValue : valeur à donner
 *
 *****************************************************************************}
procedure SetReferenceFromPointer(asPointer : string; asTab : String; asValue : string) ;
var
    { Partie pointer sur TVariable }
    lsPointerOfVar : string ;
    { Partie nom de variable }
    lsVarName : String ;
    { Pointer sur TVariable }
    loPointedVariable : TVariables ;
begin
    lsPointerOfVar := getPointeurOfVariable(asPointer) ;
    lsVarName := getVarNameOfVariable(asPointer) ;

    if (lsPointerOfVar <> '') and (lsVarName <> '')
    then begin
        loPointedVariable := goPointerOfVariables.Give(lsPointerOfVar) ;

        if loPointedVariable <> nil
        then begin
            loPointedVariable.Add(lsVarName + asTab, asValue) ;
        end ;
    end
    else begin
        ErrorMsg(csNotValidPointer) ;
    end ;
end ;