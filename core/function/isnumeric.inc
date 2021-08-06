{*****************************************************************************
 * IsNumeric
 * MARTINEAU Emeric
 *
 * Fonction qui indique si la valeur est un nombre (entier, flottant, hexadecimal)
 *
 * Paramètres d'entrée :
 *   - asNombre : chaine représentant le nombre
 *
 * Retour : true si c'est un nombre
 *****************************************************************************}
function IsNumeric(asNombre : string) : boolean ;
var
    { Compteur de boucle du nombre }
    liIndex : Integer ;
    { Position de démarrage du controle de nombre }
    liStart : Integer ;
    { Indique s'il s'agit d'un nombre hexadecimal }
    lbHexaNumber : Boolean ;
    { Longueur de la chaine à traiter }
    liLength : Integer ;
    point : Boolean ;
begin
    Result := True ;
    point := False ;
    lbHexaNumber := False ;

    if asNombre <> ''
    then begin
        liLength := Length(asNombre) ;

        if asNombre[1] = '-'
        then begin
            liStart := 2 ;
        end
        else begin
            liStart := 1 ;
        end ;

        if liLength > 2
        then begin
            { Est un nombre hexadécimmal ? }
            if (asNombre[1] = '0') and (LowerCase(asNombre[2]) = 'x')
            then begin
                liStart := liStart + 2 ;
                lbHexaNumber := True ;
            end ;
        end ;

        liIndex := liStart ;

        while liIndex <= liLength do
        begin
            if (asNombre[liIndex] = '.') and (Point = False)
            then begin
                Point := True ;
                Inc(liIndex) ;
            end ;

            if not (asNombre[liIndex] in ['0'..'9'])
            then begin
                if lbHexaNumber
                then begin
                    if not ( (asNombre[liIndex] in ['a'..'f']) or
                     (asNombre[liIndex] in ['A'..'F']) )
                    then begin
                        Result := False ;
                        break ;
                    end ;
                end
                else begin
                    Result := False ;
                    break ;
                end ;
            end ;

            Inc(liIndex) ;
        end ;
    end
    else begin
        Result := False ;
    end ;
end ;