{*****************************************************************************
 * UniqId
 * MARTINEAU Emeric
 *
 * Renvoie un identifiant unique
 *
 * Retour : un numéro unique
 *****************************************************************************}
function UniqId : string ;
begin
    Randomize ;
    Result := FormatDateTime('yyyymmddhhnnsszzz', now) + MyFloatToStr(Random(9));
end ;