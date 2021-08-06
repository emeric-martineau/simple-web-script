{*****************************************************************************
 * AddSlashes
 * MARTINEAU Emeric
 *
 * Ajoute des slash
 *
 * Paramètres d'entrée :
 *   - asText : texte à traiter
 *
 * Retour : texte avec caractère d'échappement
 *****************************************************************************}
function AddSlashes(asText : String) : String ;
var
    { Compteur de boucle }
    liIndex : Integer ;
    { Longueur de la chaine }
    liLength : Integer ;
begin
    liLength := Length(asText) ;
    Result := '' ;

    for liIndex := 1 to liLength do
    begin
        if (asText[liIndex] = '\') or (asText[liIndex] = '"') or (asText[liIndex] = '''')
        then begin
            Result := Result + '\' ;
        end ;

        Result := Result + asText[liIndex] ;
    end ;
end ;