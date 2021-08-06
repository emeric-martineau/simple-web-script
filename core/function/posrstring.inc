{*****************************************************************************
 * PosString
 * MARTINEAU Emeric
 *
 * Retourne la position de subst dans str à partir d'index en partant de la fin
 *
 * Paramètres d'entrée :
 *   - asSubstr        : chaine à rechercer
 *   - asStr           : chaine à dans laquel il faut chercher
 *   - aiIndex         : position de départ
 *   - abCaseSensitive : tenir compte de la caase
 *
 * Retour : position de la sous chaine
 *****************************************************************************}
function posrString(asSubStr : String; asStr : String; aiIndex : Integer; abCaseSensitive : boolean) : Cardinal ;
var
    { Compteur de boucle }
    liIndexStr : Cardinal ;
    { Partie de la chaine à comparer }
    lsTmp : String ;
    { Longueur de la chaine à regarder }
    liLengthStr : Integer ;
    { Longueur de la chaine à rechercher }
    liLengthSubStr : Integer ;
begin
    Result := 0 ;
    liLengthStr := Length(asStr) ;
    liLengthSubStr := Length(asSubStr) ;

    if aiIndex > 0
    then begin
        if not abCaseSensitive
        then begin
            asSubStr := AnsiLowerCase(asSubStr) ;
        end ;
    
        if aiIndex > liLengthStr
        then begin
            aiIndex := liLengthStr ;
        end ;

        if abCaseSensitive
        then begin
            for liIndexStr := aiIndex downto 1 do
            begin
                lsTmp := Copy(asStr, liIndexStr, liLengthSubStr) ;

                if lsTmp = asSubStr
                then begin
                    Result := liIndexStr ;
                    break ;
                end ;
            end ;
        end
        else begin
            for liIndexStr := aiIndex downto 1 do
            begin
                lsTmp := Copy(asStr, liIndexStr, liLengthSubStr) ;

                if AnsiLowerCase(lsTmp) = asSubStr
                then begin
                    Result := liIndexStr ;
                    break ;
                end ;
            end ;
        end ;
    end ;
end ;