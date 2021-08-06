{*****************************************************************************
 * MyStrToInt
 * MARTINEAU Emeric
 *
 * Convertit une chaine en entier
 *
 * Paramètres d'entrée :
 *   - asNombre : chaine a convertir
 *
 * Retour : valeur correspondante au texte
 *****************************************************************************}
function MyStrToInt(asNumber : string) : Integer ;
var
    { Compteur de boucle du nombre }
    liIndexNumber : Integer ;
    { Position de départ du nombre }
    liStartNumber : Integer ;
    { Longueur du nombre }
    liLength : Integer ;
    { Indique si le chiffre est un nombre hexa décimal }
    lbHexa : boolean ;
    { Indique si c'est une notation octale }
    lbOctal : boolean ;
    { Indice du chiffre en cours. Sert à multiplier le chiffre par la base }
    liIndice : Integer ;
    { Base du nombre : 10 ou 16 }
    liBase : Integer ;
    { Signe du nombre }
    liSigne : SmallInt ;
    { Chiffre en cours }
    liChiffre : SmallInt ;
begin
    Result := 0 ;

    try
        lbHexa := False ;
        lbOctal := False ;
        
        if asNumber <> ''
        then begin
            asNumber := LowerCase(asNumber) ;

            if asNumber <> ''
            then begin
                liLength := Length(asNumber) ;
                liIndice := 0 ;
                liSigne := 1 ;

                if asNumber[1] = '-'
                then begin
                    liStartNumber := 2;
                    liSigne := -1 ;
                end
                else begin
                    liStartNumber := 1 ;
                end ;

                if liLength > 2
                then begin
                    { Est un nombre hexadécimmal ? }
                    if (asNumber[1] = '0') and (LowerCase(asNumber[2]) = 'x')
                    then begin
                        lbHexa := True ;
                        liStartNumber := liStartNumber + 2 ;
                    end
                    else begin
                        lbOctal := True ;
                    end ;
                end ;

                if lbHexa
                then begin
                    liBase := 16 ;
                end
                else if lbOctal
                then begin
                    liBase := 8 ;
                end
                else begin
                    liBase := 10 ;
                end ;

                for liIndexNumber := liLength downto liStartNumber do
                begin
                    liChiffre := -1 ;

                    if asNumber[liIndexNumber] in ['0'..'9']
                    then begin
                        liChiffre := convNumber(Char(asNumber[liIndexNumber])) ;
                    end
                    else begin
                        if lbHexa
                        then begin
                            if asNumber[liIndexNumber] in ['a'..'f']
                            then begin
                                liChiffre := convHexa(Char(asNumber[liIndexNumber])) ;
                            end ;
                        end ;
                    end ;

                    if liChiffre <> -1
                    then begin
                        { On a le chiffre (ex : 9) mais il faut le multiplier par la base
                          (16, 10) pour avoir la bonne valeur }
                        Result := Result + liChiffre * MyAbsPower(liBase, liIndice) ;
                    end
                    else if lbHexa
                    then begin
                        ErrorMsg(Format(csNoHexa, [asNumber])) ;
                        break ;
                    end
                    else begin
                        ErrorMsg(Format(csNoNumber, [asNumber])) ;
                        break ;
                    end ;

                    Inc(liIndice) ;
                end ;

                Result := liSigne * Result ;
            end ;
        end ;
    except
        on EConvertError do ErrorMsg(Format(csNumberToBig, [asNumber])) ;
    end ;
end ;