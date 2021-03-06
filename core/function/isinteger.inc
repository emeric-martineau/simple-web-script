{*****************************************************************************
 * IsInteger
 * MARTINEAU Emeric
 *
 * Indique si la chaine pass�e en param�tre est un entier
 *
 * Param�tres d'entr�e :
 *   - asNumber : nombre sous forme de chaine
 *
 * Retrour : true ou false
 *****************************************************************************}
function isInteger(asNumber : string) : boolean ;
var
    { Compteur de boucle }
    liIndex : Integer ;
    { D�but � analyser }
    liStart : Integer ;
    { Taille de la chaine }
    liLength : Integer ;
begin
    if asNumber <> ''
    then begin
        liLength := Length(asNumber) ;

        if asNumber[1] = '-'
        then begin
            liStart := 2 ;
        end 
        else begin
            liStart := 1 ;
        end ;

        Result := isHexa(asNumber) ;

        if not Result
        then begin
            Result := True ;
            
            for liIndex := liStart to liLength do
            begin
                if not ( (asNumber[liIndex] in ['0'..'9']) )
                then begin
                    Result := False ;
                    break ;
                end ;
            end ;
        end ;
    end
    else begin
        Result := False ;
    end ;
end ;