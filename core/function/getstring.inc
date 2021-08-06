{*****************************************************************************
 * GetString
 * MARTINEAU Emeric
 *
 * Retourne la chaine qu'il y a entre " et '
 *
 * Paramètres d'entrée :
 *   - asText : texte entre " ou '
 *
 * Retour : texte
 *****************************************************************************}
function GetString(asText : String) : String ;
var
    { Delimiter " ou ' }
    lsDelimiter : String ;
    { Longueur de la chaine }
    liLength : Integer ;
begin
    liLength := length(asText) ;

    if liLength > 0
    then begin
        lsDelimiter := asText[1] ;

        Result := asText ;

        if (lsDelimiter = '"') or (lsDelimiter = '''')
        then begin
            if asText[liLength] = lsDelimiter
            then begin
                Result := copy(asText, 2, liLength - 2) ;
            end ;
        end ;
    end ;
end ;