{*****************************************************************************
 * IsFloat
 * MARTINEAU Emeric
 *
 * Indique s'il s'agit d'un floattant
 *
 * Param�tres d'entr�e :
 *   - asNumber : nombre sous forme de chaine
 *
 * Retrour : true s'il s'agit d'un floattant ou integer (mais pas sous forme
 *           hexa-d�cimal)
 *****************************************************************************}
function isFloat(asNumber : String) : Boolean ;
var
    { Boucle de compteur }
    liIndex : Integer ;
    { Position de d�part du nombre }
    liStart : Integer ;
    { Taille de la chaine � analyser }
    liLength : Integer ;
    { Indique si le point � �t� trouv�. Evite d'avoir deux fois un point }
    lbPoint : Boolean ;
begin
    Result := True ;
    lbPoint := False ;

    if asNumber <> ''
    then begin
        liLength := Length(asNumber) ;

        if asNumber[1] = '-'
        then begin
            liStart := 2 ;
        end
        else begin
            liStart := 1 ;
        end ;

        for liIndex := liStart to liLength do
        begin
            if not (asNumber[liIndex] in ['0'..'9'])
            then begin
                if (asNumber[liIndex] = '.') and (lbPoint = False)
                then begin
                    lbPoint := True ;
                end
                else begin
                    Result := False ;
                    break ;
                end ;
            end ;
        end ;
    end
    else begin
        Result := False ;
    end ;
end ;