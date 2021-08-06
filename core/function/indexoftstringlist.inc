{*****************************************************************************
 * IndexOfTStringList
 * MARTINEAU Emeric
 *
 * Retourne la position d'une chaine dans une TStringList
 *
 * Paramètres d'entrée :
 *   - aiStart : position de démarage,
 *   - aoList : TStringList où il faut chercher,
 *   - asSearch : ce qu'il faut chercher,
 *
 * Retour : index si trouvé, -1 sinon
 *****************************************************************************}
function IndexOfTStringList(aiStart : Integer; aoList : TStringList; asSearch : String) : Integer ;
var
    { Compteur de boucle }
    liCompteur : Integer ;
begin
    Result := -1 ;

    liCompteur := aiStart ;

    if liCompteur < 0
    then begin
        liCompteur := 0 ;
    end ;

    asSearch := asSearch ;

    for liCompteur := liCompteur to aoList.count - 1 do
    begin
        if aoList[liCompteur] = asSearch
        then begin
            Result := liCompteur ;
            break ;
        end ;
    end ;
end ;