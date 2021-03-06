{*****************************************************************************
 * CheckVarName
 * MARTINEAU Emeric
 *
 * Fonction v�rfie si le nom de la variable est valide
 *
 * Param�tres d'entr�e :
 *   aiStart : Index de d�but de v�rification de la variable (juste apr�s le $)
 *   asVarName : texte contenant la variable
 *
 * Retour : true si c'est un nom valide pour une variable
 *****************************************************************************}
function CheckVarName(aiStart : Integer; asVarName : string) : boolean ;
var
    { Compteur de boucle }
    liIndex : Integer;
    { Longueur de la variable }
    liLength : Integer ;
begin
    if not (asVarName[aiStart] in ['0'..'9'])
    then begin
        Result := True ;
        liLength := Length(asVarName) ;

        for liIndex := aiStart to liLength do
        begin
            if not ((LowerCase(asVarName[liIndex]) in ['a'..'z']) or (asVarName[liIndex] in ['0'..'9']) or (asVarName[liIndex] = '_'))
            then begin
                Result := False ;
                break ;                
            end ;
        end ;

        { Si il y a une erreur c'est peut-�tre un crochet }
        if Result = False
        then begin
            if (asVarName[liIndex] = '[') and (asVarName[liLength] = ']')
            then begin
                Result := True ;
            end ;
        end ;
    end
    else begin
        Result := False ;
    end ;

    if Result = False
    then begin
        ErrorMsg(csInvalidVarName) ;
    end ;
end ;