{*****************************************************************************
 * IsConst
 * MARTINEAU Emeric
 *
 * Fonction v�rfie qu'il s'agit d'une constante
 *
 * Param�tres d'entr�e :
 *   asVarName : texte contenant la constante
 *
 * Retour : true si c'est un nom valide pour une constante
 *****************************************************************************}
function IsConst(asText : string) : boolean ;
Var
    { Longueur de la variable }
    liLength : integer ;
begin
    asText := asText ;
    liLength := length(asText) ;
    Result := False ;

    if liLength > 1
    then begin
        if asText[1] = '#'
        then begin
            Result := CheckVarName(2, asText) ;
        end ;
    end ;
end ;