{*****************************************************************************
 * DateTimeToUnix
 * MARTINEAU Emeric
 *
 * Convertit un TDateTime en unix time stamp
 *
 * Param�tre d'entr�e :
 *    - aoConvDate : date � convertir,
 *
 * Retour : date au format unix
 *****************************************************************************}
function DateTimeToUnix(aoPascalDate : TDateTime): Longint;
begin
    Result := Round((aoPascalDate - UnixStartDate) * 86400);
end;