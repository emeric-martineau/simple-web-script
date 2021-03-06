{*****************************************************************************
 * DecToHex
 * MARTINEAU Emeric
 *
 * Convertit un nombre en hexa
 *
 * Param�tres d'entr�e :
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
    { Nombre repr�sentatif }
    lsHexaNumber : string ;
begin
    if aiNumber = 0
    then begin
        result := '0' ;
    end
    else begin
        if aiNumber < 0
        then begin
            { pour obtenir la repr�sentation d'un nombre n�gatif, c'est le
              compl�ment � un + 1 }
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