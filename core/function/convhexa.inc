{*****************************************************************************
 * convHexa
 * MARTINEAU Emeric
 *
 * Convertit un nombre hexa en entier
 *
 * Paramètres d'entrée :
 *   - acCaractere : nombre a convertir
 *
 * Retour : entier
 *****************************************************************************}
function convHexa(acCaractere : char) : SmallInt ;
begin
    if acCaractere = 'a'
    then begin
        Result := 10 ;
    end
    else if acCaractere = 'b'
    then begin
        Result := 11 ;
    end
    else if acCaractere = 'c'
    then begin
        Result := 12 ;
    end
    else if acCaractere = 'd'
    then begin
        Result := 13 ;
    end
    else if acCaractere = 'e'
    then begin
        Result := 14 ;
    end
    else if acCaractere = 'f'
    then begin
        Result := 15 ;
    end
    else begin
        Result := -1 ;
    end ;
end ;