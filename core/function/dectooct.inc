{*****************************************************************************
 * DecToOct
 * MARTINEAU Emeric
 *
 * Convertit un nombre en octal
 *
 * Param�tres d'entr�e :
 *   - aiNumber : nombre
 *
 * Retour : valeur du nombre
 *****************************************************************************}
function DecToOct(aiNumber : Int64) : String ;
begin
    Result := DecToMyBase(aiNumber, 8) ;
end ;