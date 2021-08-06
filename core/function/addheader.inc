{*****************************************************************************
 * AddHeader
 * MARTINEAU Emeric
 *
 * Ajoute une entête
 *
 * Paramètre d'entrée :
 *   - asLine : ligne à ajouter
 *****************************************************************************}
procedure AddHeader(asLine : String) ;
var
    { Compteur de boucle }
    liIndex : Integer ;
    { Indique si la donnée a été insérée s'il s'agit de content-type }
    lbIsInsered : boolean ;
begin
    lbIsInsered := False ;

    { Insert les données avant la ligne vide s'il y en a une }
    for liIndex := 0 to Header.Count - 1 do
    begin
        //if pos('Content-Type', Header[i]) = 1
        if posString('Content-Type', Header[liIndex], 1, false) = 1
        then begin
            Header.Insert(liIndex, asLine) ;
            lbIsInsered := True ;
            break ;
        end ;
    end ;

    { si les données non pas été insérée }
    if not lbIsInsered
    then begin
        Header.Add(asLine) ;
    end ;
end ;