{*****************************************************************************
 * AddSlashes
 * MARTINEAU Emeric
 *
 * Ajoute des slash
 *
 * Param�tres d'entr�e :
 *   - asText : texte � traiter
 *
 * Retour : texte avec caract�re d'�chappement
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