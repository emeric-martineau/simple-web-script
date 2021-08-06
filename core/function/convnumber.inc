{*****************************************************************************
 * convNumber
 * MARTINEAU Emeric
 *
 * Convertit un nombre en entier
 *
 * Paramètres d'entrée :
 *   - acCaractere : nombre a convertir
 *
 * Retour : entier
 *****************************************************************************}
function convNumber(acCaractere : char) : SmallInt ;
begin
    if acCaractere = '0'
    then begin
        Result := 0 ;
    end
    else if acCaractere = '1'
    then begin
        Result := 1 ;
    end
    else if acCaractere = '2'
    then begin
        Result := 2 ;
    end
    else if acCaractere = '3'
    then begin
        Result := 3 ;
    end
    else if acCaractere = '4'
    then begin
        Result := 4 ;
    end
    else if acCaractere = '5'
    then begin
        Result := 5 ;
    end
    else if acCaractere = '6'
    then begin
        Result := 6 ;
    end
    else if acCaractere = '7'
    then begin
        Result := 7 ;
    end
    else if acCaractere = '8'
    then begin
        Result := 8 ;
    end
    else if acCaractere = '9'
    then begin
        Result := 9 ;
    end
    else begin
        Result := -1 ;
    end ;
end ;