{*****************************************************************************
 * UrlEncode
 * MARTINEAU Emeric
 *
 * Encode une url
 *
 * Paramètres d'entrée :
 *   - asUrl : Url à encoder
 *
 * Retour : url encodée
 *****************************************************************************}
function UrlEncode(asUrl : string): string;
var
   liIndex : Integer ;
begin
    Result := '';

    for liIndex := 1 to Length(asUrl) do
    begin
        if asUrl[liIndex] in ['A'..'Z', 'a'..'z', '0'..'9', '-', '_', '.']
        then begin
            Result := Result + asUrl[liIndex] ;
        end
        else if asUrl[liIndex] = ' '
        then begin
            Result := Result + '+' ;
        end
        else begin
            Result := Result + '%' + IntToHex(Ord(asUrl[liIndex]), 2) ;
        end ;
    end;
end;