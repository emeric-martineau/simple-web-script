{*****************************************************************************
 * UrlDecode
 * MARTINEAU Emeric
 *
 * Décode une url
 *
 * Paramètres d'entrée :
 *   - asUrl : Url à décoder
 *
 * Retour : url décodée
 *****************************************************************************}
function UrlDecode(asUrl : String) : String ;
var
    { Compteur de boucle }
    liIndex : Integer ;
    { Longueur de l'url }
    liLength : Integer ;
    { Chiffre hexa }
    lsHexa : String ;
begin
    liLength := Length(asUrl) ;
    liIndex := 1 ;
    Result := '' ;

    while liIndex <= liLength do
    begin
        if asUrl[liIndex] = '+'
        then begin
            Result := Result + ' ' ;
        end
        else if (asUrl[liIndex] = '%') and ((liLength - liIndex) > 1)
        then begin
            lsHexa := '0x' + Copy(asUrl, liIndex + 1, 2) ;

            if IsHexa(lsHexa)
            then begin
               Result := Result + Chr(MyStrToInt(lsHexa)) ;
               Inc(liIndex, 3) ;
            end
            else begin
                Result := Result + asUrl[liIndex] ;
                Inc(liIndex) ;
            end
        end
        else begin
            Result := Result + asUrl[liIndex] ;
            Inc(liIndex) ;
        end ;
    end ;
end ;