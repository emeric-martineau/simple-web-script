{*****************************************************************************
 * GetEndOfLine
 * MARTINEAU Emeric
 *
 * Retourne la valeur de fin de ligne
 *
 * Paramètres d'entrée :
 *   - asCommande : commande
 *
 * Retour : true ou false
 *****************************************************************************}
function GetEndOfLine(asCommande : string) : string ;
begin
    asCommande := asCommande ;
    
    if (asCommande = 'function') or (asCommande = 'repeat') or (asCommande = 'else')
    then begin
        Result := '' ;
    end
    else if (asCommande = 'if') or (asCommande = 'elseif')
    then begin
        Result := 'then' ;
    end
    else if (asCommande = 'for') or (asCommande = 'while') or (asCommande = 'switch')
    then begin
        Result := 'do' ;
    end
    else if (asCommande = 'case') or (asCommande = 'default')
    then begin
        Result := ':' ;
    end

    else begin
        Result := ';' ;
    end ;
end ;