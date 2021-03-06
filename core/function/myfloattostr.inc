{*****************************************************************************
 * MyFloatToStr
 * MARTINEAU Emeric
 *
 * Convertie un floattant en chaine
 *
 * Param�tres d'entr�e :
 *   - aeNumber : nombre sous forme de chaine
 *
 * Retrour : nombre floattant sous forme de chaine
 *****************************************************************************}
function MyFloatToStr(aeNumber : Extended) : string ;
begin
    DecimalSeparator := '.' ;
    Result := FloatToStr(aeNumber) ;
end ;