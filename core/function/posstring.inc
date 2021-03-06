{*****************************************************************************
 * PosString
 * MARTINEAU Emeric
 *
 * Retourne la position de subst dans str � partir d'index
 *
 * Param�tres d'entr�e :
 *   - asSubstr        : chaine � rechercer
 *   - asStr           : chaine � dans laquel il faut chercher
 *   - aiIndex         : position de d�part
 *   - abCaseSensitive : tenir compte de la caase
 *
 * Retour : position de la sous chaine
 *****************************************************************************}
function PosString(asSubStr : String; asStr : String; aiIndex : Integer; abCaseSensitive : boolean) : Cardinal ;
var
    { Compteur de boucle }
    liIndexStr : Cardinal ;
    { Partie de la chaine � comparer }
    lsTmp : String ;
    { Longueur de la chaine � regarder }
    liLengthStr : Integer ;
    { Longueur de la chaine � rechercher }
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

        if abCaseSensitive
        then begin
            for liIndexStr := aiIndex to liLengthStr do
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
            for liIndexStr := aiIndex to liLengthStr do
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