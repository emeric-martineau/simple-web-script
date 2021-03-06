{*****************************************************************************
 * GetConst
 * MARTINEAU Emeric
 *
 * Retourne la valeur de la constante
 *
 * Param�tres d'entr�e :
 *   - asConstante : nom de la constante (avec #)
 *
 * Retour : true ou false
 *****************************************************************************}
function GetConst(asConstante : string) : string ;
begin
    if not goConstantes.isSet(asConstante)
    then begin
        WarningMsg(Format(csConstanteDoesntExist, [asConstante])) ;
    end ;
    
    Result := goConstantes.Give(asConstante) ;
end ;