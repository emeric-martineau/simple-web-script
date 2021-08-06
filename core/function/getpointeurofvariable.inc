{*****************************************************************************
 * GetPointeurOfVariable
 * MARTINEAU Emeric
 *
 * Retourne la partie pointer sur la variable Variables d'une variable pointer
 *
 * Paramètres d'entrée :
 *   - asPointer : pointer de variable xxxx$yyyyy
 *
 * Retour : partie pointeur
 *****************************************************************************}
function GetPointeurOfVariable(asPointer : string) : string ;
var
    { Compteur de boucle }
    liIndex : Integer ;
begin
    Result := '' ;

    if Length(asPointer) > 1
    then begin
        for liIndex := 3 to Length(asPointer) do
        begin
            if asPointer[liIndex] = '$'
            then begin
                break ;
            end
            else begin
                Result := Result + asPointer[liIndex] ;
            end ;
        end ;
    end
    else begin
        Result := '' ;
    end ;
end ;