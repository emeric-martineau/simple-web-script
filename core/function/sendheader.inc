{*****************************************************************************
 * SendHeader
 * MARTINEAU Emeric
 *
 * Fonction qui envoie le header
 *****************************************************************************}
procedure SendHeader ;
var
    { Compteur de boucle }
    liIndex : Integer ;
begin
    { M�morise d'o� est envoy� les insormations }
    giLineWhereHeaderSend := giCurrentLineNumber ;

    gbIsHeaderSend := True ;

    for liIndex := 0 to Header.Count - 1 do
    begin
        writeln(Header[liIndex]) ;
    end ;
end ;