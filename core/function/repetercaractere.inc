{*****************************************************************************
 * RepeterCaractere
 * MARTINEAU Emeric
 *
 * R�p�te un caract�re
 *
 * Param�tres d'entr�e :
 *   - asText : texte � r�p�ter
 *   - aiNumber : nombre de fois � r�p�ter
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