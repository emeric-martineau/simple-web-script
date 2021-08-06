{*****************************************************************************
 * ExtractIntPart
 * MARTINEAU Emeric
 *
 * Extrait la partie entière d'un nombre
 *
 * Paramètres d'entrée :
 *   - asText : nombre sous forme de chaine
 *
 * Retour : partie entière
 *****************************************************************************}
function ExtractIntPart(asNumber : String) : String ;
var
    { Position du point }
    liPositionOfDot : Integer ;
begin
    liPositionOfDot := pos('.', asNumber) ;

    if liPositionOfDot <> 0
    then begin
        Result := Copy(asNumber, 1, liPositionOfDot - 1) ;
    end
    else begin
        Result := asNumber ;
    end ;
end ;