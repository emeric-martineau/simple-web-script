{*****************************************************************************
 * InitMonthName
 * MARTINEAU Emeric
 *
 * Initialise le tableau des mois
 *
 * Param�tres d'entr�e :
 *   - aaValue     : jours de la semaines (1er jour dimanche)
 *
 * Param�tre de sortie :
 *   - aaArray : tableau � initialiser (tableau commen�at � 1)
 *****************************************************************************}
procedure InitMonthName(var aaArray : array of string; aaValue : array of string) ;
var
    liIndex : Integer ;
begin
    for liIndex := 1 to 12 do
    begin
        aaArray[liIndex] := aaValue[liIndex - 1] ;
    end ;
end ;