{*****************************************************************************
 * UnixToDateTime
 * MARTINEAU Emeric
 *
 * Convertit un unix time stamp en TDateTime
 *
 * Paramètre d'entrée :
 *    - aiUnixTime : date au format unix
 *
 * Retour : date au format pascal
 *****************************************************************************}
function UnixToDateTime(aiUnixTime : Longint): TDateTime;
begin
    Result := (aiUnixTime div 86400) + UnixStartDate;
end;