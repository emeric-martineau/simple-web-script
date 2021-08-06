{*****************************************************************************
 * DeleteSlashes
 * MARTINEAU Emeric
 *
 * Supprime les slash
 *
 * Paramètres d'entrée :
 *   - asText : texte à traiter
 *
 * Retour : texte avec caractère d'échappement
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