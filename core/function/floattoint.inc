{*****************************************************************************
 * FloatToInt
 * MARTINEAU Emeric
 *
 * Converti un floattant en entier
 *
 * Param�tres d'entr�e :
 *   - aeNumber : nombre sous forme de chaine
 *
 * Retrour : true ou false
 *****************************************************************************}
function FloatToInt(aeNumber : extended) : Int64 ;
begin
    Result := 0 ;

    try
        Result := Trunc(aeNumber) ;
    except
        on EinvalidOp do ErrorMsg(Format(csNumberToBig, [aeNumber])) ;
    end ;
end ;