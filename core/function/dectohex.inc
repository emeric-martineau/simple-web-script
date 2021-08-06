{*****************************************************************************
 * DecToHex
 * MARTINEAU Emeric
 *
 * Convertit un nombre en hexa
 *
 * Paramètres d'entrée :
 *   - aiNumber : nombre
 *
 * Retour : valeur hexa
 *****************************************************************************}
function DecToHex(aiNumber : Int64) : string ;
var
    { Modulo du nombre }
    liModulo : SmallInt ;
    { Nouveau nombre }
    liNewNumber : Int64 ;
    { Nombre représentatif }
    lsHexaNumber : string ;
begin
    if aiNumber = 0
    then begin
        result := '0' ;
    end
    else begin
        if aiNumber < 0
        then begin
            { pour obtenir la représentation d'un nombre négatif, c'est le
              complément à un + 1 }
            liNewNumber := (not Abs(aiNumber)) + 1 ;
        end
        else begin
            liNewNumber := aiNumber ;
        end ;

        result := '' ;

        while liNewNumber > 0 do
        begin
            liModulo := liNewNumber mod 16 ;
            liNewNumber := liNewNumber div 16 ;

            if liModulo < 10
            then begin
                lsHexaNumber := IntToStr(liModulo) ;
            end
            else if liModulo = 10
            then begin
                lsHexaNumber := 'a' ;
            end
            else if liModulo = 11
            then begin
                lsHexaNumber := 'b' ;
            end
            else if liModulo = 12
            then begin
                lsHexaNumber := 'c' ;
            end
            else if liModulo = 13
            then begin
                lsHexaNumber := 'd' ;
            end
            else if liModulo = 14
            then begin
                lsHexaNumber := 'e' ;
            end
            else if liModulo = 15
            then begin
                lsHexaNumber := 'f' ;
            end ;

            Result := lsHexaNumber + Result
        end ;
    end ;
end ;