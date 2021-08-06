{*****************************************************************************
 * RepeterCaractere
 * MARTINEAU Emeric
 *
 * Répète un caractère
 *
 * Paramètres d'entrée :
 *   - asText : texte à répéter
 *   - aiNumber : nombre de fois à répéter
 *
 * Retour : chaine
 *****************************************************************************}
function RepeterCaractere(asText : string; aiNumber : Int64) : String ;
var
    { Compteur de boucle }
    liIndex : Int64 ;
begin
    Result := '' ;

    liIndex := 0 ;

    while (liIndex < aiNumber) do
    begin
        Result := Result + asText ;

        Inc(liIndex) ;
    end ;
end ;