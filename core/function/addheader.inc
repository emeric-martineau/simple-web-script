{*****************************************************************************
 * AddHeader
 * MARTINEAU Emeric
 *
 * Ajoute une ent�te
 *
 * Param�tre d'entr�e :
 *   - asLine : ligne � ajouter
 *****************************************************************************}
procedure AddHeader(asLine : String) ;
var
    { Compteur de boucle }
    liIndex : Integer ;
    { Indique si la donn�e a �t� ins�r�e s'il s'agit de content-type }
    lbIsInsered : boolean ;
begin
    lbIsInsered := False ;

    { Insert les donn�es avant la ligne vide s'il y en a une }
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

    { si les donn�es non pas �t� ins�r�e }
    if not lbIsInsered
    then begin
        Header.Add(asLine) ;
    end ;
end ;