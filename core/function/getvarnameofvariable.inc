{*****************************************************************************
 * GetVarNameOfVariable
 * MARTINEAU Emeric
 *
 * Retourne la partie pointer sur la variable Variables d'une variable pointer
 *
 * Paramètres d'entrée :
 *   - asPointer : pointer de variable xxxx$yyyyy
 *
 * Retour : partie variable
 *****************************************************************************}
function GetVarNameOfVariable(asPointer : string) : string;
var
    { Position du dollard }
    liPositionOfDollard : Integer ;
    { Compteur de boucle }
    liIndex : integer ;
begin
    liPositionOfDollard := pos('$', asPointer);
    Result := '' ;

    if liPositionOfDollard > 0
    then begin
        for liIndex := liPositionOfDollard to Length(asPointer) - 1 do
        begin
            Result := Result + asPointer[liIndex] ;
        end ;
    end ;
end ;