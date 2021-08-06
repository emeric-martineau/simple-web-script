{*****************************************************************************
 * ExtractEndOperator
 * MARTINEAU Emeric
 *
 * Extrait la fin de chaine jusqu'au caractère non valide
 *
 * Paramètres d'entrée :
 *   - asText : texte à traiter
 *
 * Retour : texte jusqu'au premier espace ou tabulation
 *****************************************************************************}
function ExtractEndOperator(asText : string) : string ;
var
    { Compteur de boucle }
    liIndexText : Integer ;
    { Longueur d'asText }
    liLength : Integer ;
    { Compteur pour l'operateur }
    liIndexOperator : Integer ;
begin
    asText := Trim(asText) ;
    Result := '' ;

    liLength := Length(asText) ;
    
    if liLength > 0
    then begin
        for liIndexText := liLength downto 1 do
        begin
            if (asText[liIndexText] = '-') or
               (asText[liIndexText] = '+') or
               (asText[liIndexText] = '%') or
               (asText[liIndexText] = '=') or
               (asText[liIndexText] = '.') or
               (asText[liIndexText] = ',') or
               (asText[liIndexText] = '*') or
               (asText[liIndexText] = '/') or
               (asText[liIndexText] = '^') or
               (asText[liIndexText] = '~') or
               (asText[liIndexText] = '&') or
               (asText[liIndexText] = ';') or
               (asText[liIndexText] = ':') or
               (asText[liIndexText] = '?')
            then begin
                Result := asText[liIndexText] ;
                break ;
            end
            else if asText[liIndexText] = '|'
            then begin
                Result := '|' ;
                
                if liIndexText > 1
                then begin
                    if asText[liIndexText - 1] = '&'
                    then begin
                        Result := '&' + Result ;
                    end ;
                end ;
                
                break ;
            end
            else if asText[liIndexText] = '<'
            then begin
                Result := '<' ;

                if liIndexText > 1
                then begin
                    if asText[liIndexText - 1] = '<'
                    then begin
                        Result := '<' + Result ;
                    end ;
                end ;

                break ;
            end
            else if asText[liIndexText] = '>'
            then begin
                Result := '>' ;

                if liIndexText > 1
                then begin
                    if asText[liIndexText - 1] = '>'
                    then begin
                        Result := '>' + Result ;
                    end ;
                end ;

                break ;
            end
            else begin
                for liIndexOperator := liIndexText downto 1 do
                begin
                    if asText[liIndexOperator] in ['a'..'z']
                    then begin
                        Result := asText[liIndexOperator] + Result ;
                    end
                    else begin
                        break ;
                    end ;
                end ;
                
                break ;
            end ;
        end ;
    end ;
end ;