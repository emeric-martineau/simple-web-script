{*****************************************************************************
 * AnsiIndexStr
 * MARTINEAU Emeric
 *
 * Retourne la position d'une chaine dans un tableau
 *
 * Param�tres d'entr�e :
 *   - asText
 *
 * Retour : index si trouv�, -1 sinon
 *****************************************************************************}
function AnsiIndexStr(asText : string; const asValues : array of string) : integer;
begin
    Result := 0 ;

    while Result <= High(asValues) do
    begin
        if (asValues[Result] = asText)
        then begin
            exit ;
        end
        else begin
            inc(Result) ;
        end ;
    end ;

    Result := -1;
end;