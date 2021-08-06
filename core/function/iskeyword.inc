{*****************************************************************************
 * IsKeyWord
 * MARTINEAU Emeric
 *
 * indique s'il s'agit d'un mot clef
 *
 * Paramètres d'entrée :
 *   - asKeyword : mot clef
 *
 * Retour : true si mot clef
 *****************************************************************************}
function IsKeyWord(asKeyword : String) : boolean ;
begin
    Result := False ;
    
    if (asKeyword = 'in') or (asKeyword = 'or') or
       (asKeyword = 'xor') or (asKeyword = 'and') or
       (asKeyword = 'not') or (asKeyword = 'to') or
       (asKeyword = 'step') or (asKeyword = 'case') or
       (asKeyword = 'bitor') or (asKeyword = 'bitand') or
       (asKeyword = 'bitxor') or (asKeyword = 'default')
    then begin
        Result := True ;
    end ;
end ;