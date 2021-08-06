{*****************************************************************************
 * Caree
 * MARTINEAU Emeric
 *
 * Fonction qui donne la valeur exposant
 *
 * Paramètres d'entrée :
 *   aeValue    : nombre à exposer
 *   aiExposant : exposant
 *
 * Retour : valeur du nombre à la puissance exposant
 *****************************************************************************}
function caree(aeValue : Extended; aiExposant : integer) : Extended;
var
    { Valeur avant division }
    leValueBefore :Extended;
    { Compteur de boucle pour l'exposant }
    liExposantCount : Integer ;
begin
    if (aiExposant >= 0)
    then begin
        Result := 1 ;

        for liExposantCount := 1 to aiExposant do
        begin
            Result := Result * aeValue ;
        end ;

        if aiExposant = 0
        then begin
            Result := 1 ;
        end ;
    end
    else begin
        aiExposant := -1 * aiExposant ;

        leValueBefore := caree(aeValue, aiExposant) ;
        
        Result := 1 / leValueBefore ;
    end ;
end ;