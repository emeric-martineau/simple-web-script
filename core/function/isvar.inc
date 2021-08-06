{*****************************************************************************
 * IsVar
 * MARTINEAU Emeric
 *
 * Fonction vérfie qu'il s'agit d'une variable
 *
 * Paramètres d'entrée :
 *   asVarName : texte contenant la variable
 *
 * Retour : true si c'est un nom valide pour une variable
 *****************************************************************************}
function IsVar(asText : string) : boolean ;
Var
    { Longueur de la variable }
    liLength : integer ;
    { Indique la position de départ de la variable }
    liStartVarName : Integer ;
begin
    asText := asText ;
    liLength := length(asText) ;
    Result := False ;
    
    if liLength > 1
    then begin
        if asText[1] = '$'
        then begin
            if liLength > 1
            then begin
                if asText[2] = '$'
                then begin
                    Result := CheckVarName(3, asText) ;
                end
                else begin
                    Result := CheckVarName(2, asText) ;
                end ;
            end
            else begin
                Result := CheckVarName(2, asText) ;
            end ;
        end
        else if (asText[1] = '&')
        then begin
            { Est-ce un pointeur sur une variable ? }
            if liLength > 2
            then begin
                if asText[2] = '$'
                then begin
                    Result := CheckVarName(3, asText) ;
                end ;
            end
            else begin
                Result := False ;            
            end ;
        end
        else if (asText[1] = '*')
        then begin
            { Est-ce un pointeur sur une variable ? }
            if liLength > 2
            then begin
                liStartVarName := 1 ;

                while (asText[liStartVarName] = '*') do
                begin
                    Inc(liStartVarName) ;
                end ;

                if asText[liStartVarName] = '$'
                then begin
                    { Pointe sur le début du nom de la variable }
                    Inc(liStartVarName) ;

                    Result := CheckVarName(liStartVarName, asText) ;
                end ;
            end
            else begin
                Result := False ;
            end ;
        end
        else begin
            Result := False ;
        end ;
    end
    else begin
        Result := False ;
    end ;
end ;