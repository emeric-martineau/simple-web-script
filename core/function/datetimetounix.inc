{*****************************************************************************
 * DateTimeToUnix
 * MARTINEAU Emeric
 *
 * Convertit un TDateTime en unix time stamp
 *
 * Paramètre d'entrée :
 *    - aoConvDate : date à convertir,
 *
 * Retour : date au format unix
 *****************************************************************************}
function DateTimeToUnix(aoPascalDate : TDateTime): Longint;
begin
    Result := Round((aoPascalDate - UnixStartDate) * 86400);
end;