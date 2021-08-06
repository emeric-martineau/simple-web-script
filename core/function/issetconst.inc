{*****************************************************************************
 * IsSetConst
 * MARTINEAU Emeric
 *
 * Indique si la constante existe
 *
 * Paramètres d'entrée :
 *   - asConstante : nom de la constante (avec #)
 *
 * Retour : true ou false
 *****************************************************************************}
function IsSetConst(asConstante : string) : boolean ;
begin
    Result := goConstantes.IsSet(asConstante) ;
end ;