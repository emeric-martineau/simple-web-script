{*****************************************************************************
 * DecToBin
 * MARTINEAU Emeric
 *
 * Convertit un nombre en binaire
 *
 * Param�tres d'entr�e :
 *   - aiNumber : nombre
 *
 * Retour : valeur du nombre
 *****************************************************************************}
function DecToBin(aiNumber : Int64) : String ;
begin
    Result := DecToMyBase(aiNumber, 2) ;
end ;