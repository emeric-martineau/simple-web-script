{*****************************************************************************
 * MyStrToFloat
 * MARTINEAU Emeric
 *
 * Convertie une chaine de caractère en float
 *
 * Paramètres d'entrée :
 *   - asNumber : nombre sous forme de chaine
 *
 * Retrour : nombre floattant
 *****************************************************************************}
function MyStrToFloat(asNumber : string) : Extended ;
begin
    Result := 0 ;

    try
        DecimalSeparator := '.' ;
        
        Result := StrToFloat(asNumber) ;
    except
        on EConvertError do ErrorMsg(Format(csNumberToBig, [asNumber])) ;
    end ;
end ;