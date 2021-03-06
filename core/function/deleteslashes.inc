{*****************************************************************************
 * DeleteSlashes
 * MARTINEAU Emeric
 *
 * Supprime les slash
 *
 * Param�tres d'entr�e :
 *   - asText : texte � traiter
 *
 * Retour : texte avec caract�re d'�chappement
 *****************************************************************************}
function DeleteSlashes(asText : String) : String ;
var
    { Compteur de boucle }
    liIndex : Integer ;
    { Longueur de la chaine }
    liLength : Integer ;
begin
    liLength := Length(asText) ;
    Result := '' ;

    liIndex := 1 ;
    
    while liIndex <= liLength do
    begin
        if asText[liIndex] = '\'
        then begin
            Inc(liIndex) ;
        end ;

        Result := Result + asText[liIndex] ;
        
        Inc(liIndex) ;
    end ;
end ;