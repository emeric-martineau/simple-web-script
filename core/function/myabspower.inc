{*****************************************************************************
 * MyAbsPower
 * MARTINEAU Emeric
 *
 * Power mais en entier
 *
 * Param�tres d'entr�e :
 *   - asBase : base
 *   - asExponent : exposant
 *
 * Retour : entier
 *****************************************************************************}
function MyAbsPower(asBase : Integer; asExponent : Integer) : Integer ;
var
    { Compteur }
    liCounter : Integer ;
begin
    Result := 1 ;

    for liCounter := 1 to asExponent do
    begin
        Result := Result * asBase ;
    end ;
end ;