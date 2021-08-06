{*****************************************************************************
 * IsSetReference
 * MARTINEAU Emeric
 *
 * Indique si une variable point�e existe (et donc un pointer est valide)
 *
 * Param�tres d'entr�e :
 *   - asVarNamePointed : variable contenant le pointer de variable qu'il faut
 *                        �crire.
 *
 *****************************************************************************}
function isSetReference(asVarNamePointed : string) : Boolean ;
var
    { Partie pointeur de TVariable }
    lsPointerOfVar : String ;
    { Partie variable du pointer }
    lsVarName : String ;
    { Variable temporaire }
    lsTmp : String ;
    { Partie tableau de la variable }
    lsTab : String ;
    { Position de d�but des crochets }
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
    
    { On r�cup�re la valeur de la variable pour la traiter }
    asVarNamePointed := goVariables.Give(asVarNamePointed) ;
    lsPointerOfVar := getPointeurOfVariable(asVarNamePointed) ;
    lsVarName := getVarNameOfVariable(asVarNamePointed) ;
    Result := False ;

    if (lsPointerOfVar <> '') and (lsVarName <> '')
    then begin
        loPointedVariable := goPointerOfVariables.Give(lsPointerOfVar) ;

        if loPointedVariable <> nil
        then begin
            Result := loPointedVariable.isSet(lsVarName + lsTab) ;
        end 
        else begin
            Result := False ;
        end ;
    end
    else begin
        ErrorMsg(csNotValidPointer) ;
    end ;
end ;