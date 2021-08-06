{*****************************************************************************
 * IsEndOperatorBy
 * MARTINEAU Emeric
 *
 * Extrait la première partie jusqu'au premier espace ou tabulation
 *
 * Paramètres d'entrée :
 *   - asText : texte à traiter
 *
 * Retour : texte jusqu'au premier espace ou tabulation
 *****************************************************************************}
function IsEndOperatorBy(asEndOfLine : string) : boolean ;
begin
    if AnsiIndexStr(asEndOfLine, ['+', '-', '/', '*', '^', '|', 'bitand', '&|', '<<', '>>',
                                  '~', '%', '.', '=', '<=', '<', '<>', '>=', '>', 'and',
                                  'or', 'xor', 'in', 'not', '?', ':']) <> -1
    then begin
        Result := true ;
    end
    else begin
        Result := false ;
    end ;
end ;