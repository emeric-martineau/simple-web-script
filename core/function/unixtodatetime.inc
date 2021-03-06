{*****************************************************************************
 * UnixToDateTime
 * MARTINEAU Emeric
 *
 * Convertit un unix time stamp en TDateTime
 *
 * Param�tre d'entr�e :
 *    - aiUnixTime : date au format unix
 *
 * Retour : date au format pascal
 *****************************************************************************}
function UnixToDateTime(aiUnixTime : Longint): TDateTime;
begin
    Result := (aiUnixTime div 86400) + UnixStartDate;
end;