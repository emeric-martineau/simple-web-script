{*****************************************************************************
 * Explose
 * MARTINEAU Emeric
 *
 * Fonction explose une chaine en tableau en fonction d'un séparateur
 *
 * Paramètres d'entrée :
 *   - asText : chaine à traiter
 *   - asSeparator
 *
 * Paramètre de sortie :
 *    - aoLine : Liste des éléments
 *****************************************************************************}
procedure Explode(asText : string; aoLine : TStringList; asSeparator : string) ;
var
    { Valeur de la ligne courante }
    lsCurrentLine : string ;
    { Longueur du séparateur }
    liLengthSeparator : Integer ;
    { Varaible temporaire pour comparaison avec le séparateur }
    lsTmp : String ;
    { Compteur de boucle }
    liIndex : Integer ;
begin
    aoLine.Clear ;

    lsCurrentLine := '' ;

    liLengthSeparator := Length(asSeparator) ;
    liIndex := 1 ;

    while liIndex <= Length(asText) do
    begin
        lsTmp := Copy(asText, liIndex, liLengthSeparator) ;

        if lsTmp = asSeparator
        then begin
            aoLine.Add(lsCurrentLine) ;
            lsCurrentLine := '' ;
            Inc(liIndex, liLengthSeparator) ;
        end
        else begin
            lsCurrentLine := lsCurrentLine + asText[liIndex] ;
            Inc(liIndex) ;
        end ;
    end ;

    if lsCurrentLine <> ''
    then begin
        aoLine.Add(lsCurrentLine) ;
    end ;
end ;