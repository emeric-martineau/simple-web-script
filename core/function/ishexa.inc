{*****************************************************************************
 * IsHexa
 * MARTINEAU Emeric
 *
 * Indique si c'est un chiffre hexadécimel
 *
 * Paramètres d'entrée :
 *   - asNumber : nombre
 *
 * Retour : true si la chaine représente un nombre hexa
 *****************************************************************************}
function IsHexa(asNumber : string) : boolean ;
var
    { Taille de la chaine }
    liLength : Integer ;
    { Compteur de boucle }
    liIndex : Integer ;
begin
    Result := False ;
    liLength := Length(asNumber) ;

    if liLength > 2
    then begin
        if (asNumber[1] = '0') and ((asNumber[2] = 'x') or (asNumber[2] = 'X'))
        then begin
            Result := True ;

            for liIndex := 3 to liLength do
            begin
                if not ((asNumber[liIndex] in ['0'..'9']) or
                        (asNumber[liIndex] in ['A'..'F']) or
                        (asNumber[liIndex] in ['a'..'f']))
                then begin
                    Result := False ;
                    break ;
                end ;
            end ;
        end ;
    end ;
end ;