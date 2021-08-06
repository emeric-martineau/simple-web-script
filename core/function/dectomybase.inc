{*****************************************************************************
 * DecToMyBase
 * MARTINEAU Emeric
 *
 * Convertit un nombre en une base donnée
 *
 * Paramètres d'entrée :
 *   - aiNumber : nombre
 *   - aBase : 2, 8, 10
 *
 * Retour : valeur du nombre
 *****************************************************************************}
function DecToMyBase(aiNumber : Int64; aBase : Byte) : String ;
var
    { Modulo du nombre }
    liModulo : SmallInt ;
    { Nouveau nombre }
    liNewNumber : Int64 ;
    { Nombre représentatif }
    lsNumber : string ;
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

        Result := '' ;

        while liNewNumber > 0 do
        begin
            liModulo := liNewNumber mod aBase ;
            liNewNumber := liNewNumber div aBase ;

            lsNumber := IntToStr(liModulo) ;

            Result := lsNumber + Result
        end ;
    end ;
end ;