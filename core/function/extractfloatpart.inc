{*****************************************************************************
 * ExtractFloatPart
 * MARTINEAU Emeric
 *
 * Extrait la partie fractionnaire d'un nombre
 *
 * Paramètres d'entrée :
 *   - asText : nombre sous forme de chaine
 *
 * Retour : partie fractionnaire
 *****************************************************************************}
function ExtractFloatPart(asNumber : String) : String ;
var
    { Position du point }
    liPositionOfDot : Integer ;
begin
    liPositionOfDot := pos('.', asNumber) ;

    if liPositionOfDot <> 0
    then begin
        Result := Copy(asNumber, liPositionOfDot + 1, length(asNumber) - liPositionOfDot) ;
    end
    else begin
        Result := '' ;
    end ;
end ;