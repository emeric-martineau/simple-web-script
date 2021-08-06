{*****************************************************************************
 * InitDayName
 * MARTINEAU Emeric
 *
 * Initialise le tableau des jours
 *
 * Paramètres d'entrée :
 *   - aaValue     : jours de la semaines (1er jour dimanche)
 *
 * Paramètre de sortie :
 *   - aaArray : tableau à initialiser (tableau commençat à 1)
 *****************************************************************************}
procedure InitDayName(var aaArray : array of string; aaValue : array of string) ;
var
    liIndex : Integer ;
begin
    for liIndex := 1 to 7 do
    begin
        aaArray[liIndex] := aaValue[liIndex - 1] ;
    end ;
end ;