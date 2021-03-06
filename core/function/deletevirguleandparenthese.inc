{*****************************************************************************
 * DeleteVirguleAndParenthese
 * MARTINEAU Emeric
 *
 * Fonction qui supprime les virgules et parenth�se de d�but et fin
 *
 * Param�tres d'entr�e :
 *   - aoArgumentsWithParentheses : liste � traiter
 *
 * Param�tres de sortie :
 *   - aoArgumentsWithParentheses : liste trait�e
 *****************************************************************************}
procedure DeleteVirguleAndParenthese(aoArgumentsWithParentheses : TStringList) ;
var nb : Integer ;
    Index : Integer ;
    Parentheses : array of Integer ;
    EnleverParenthese : boolean ;
begin
    { Supprime les "," }
    Index := 0 ;

    while Index < aoArgumentsWithParentheses.Count do
    begin
        if aoArgumentsWithParentheses[Index] = ','
        then begin
            aoArgumentsWithParentheses.Delete(Index) ;
        end
        else begin
            Inc(Index) ;
        end ;
    end ;

    { si on a une parenth�se ouvrante, peut-�tre s'agit-il d'un appel xxx(...)}
    if aoArgumentsWithParentheses.Count > 0
    then begin
        if aoArgumentsWithParentheses[0] = '('
        then begin
            Index := 0 ;
            EnleverParenthese := False ;
            
            { on va compter le nombre de parenth�se }
            for nb := 0 to aoArgumentsWithParentheses.Count - 1 do
            begin
                if aoArgumentsWithParentheses[nb] = '('
                then begin
                    Inc(Index) ;
                    try
                        SetLength(Parentheses, Index) ;
                    except
                        on EOutOfMemory do begin
                            ErrorMsg(csOutOfMemory) ;
                            break ;
                        end ;
                    end ;

                    Parentheses[Index - 1] := nb ;
                end ;

                if aoArgumentsWithParentheses[nb] = ')'
                then begin
                    { si la parenth�se est sur la derni�re case }
                    if (nb = aoArgumentsWithParentheses.Count - 1)
                    then
                        if Index > 0
                        then
                            { Est-ce la parenth�se correspondante est � la position 0 }
                            if Parentheses[Index - 1] = 0
                            then begin
                                EnleverParenthese := True ;
                                break ;
                            end ;

                    Dec(Index) ;
                end ;
            end ;

            { Lib�re le tableau }
            SetLength(Parentheses, 0) ;

            { Supprime les parenth�ses de d�but et de fin }
            if EnleverParenthese
            then begin
                aoArgumentsWithParentheses.Delete(0) ;
                nb := aoArgumentsWithParentheses.Count - 1 ;
                aoArgumentsWithParentheses.Delete(nb) ;
            end ;
        end ;
    end ;
end ;