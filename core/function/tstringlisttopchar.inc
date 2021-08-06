{*****************************************************************************
 * TStringListToPChar
 * MARTINEAU Emeric
 *
 * Converti une TStringList en PChar
 *
 * Paramètres d'entrée :
 *   - aoArgTStringList : Liste à traiter
 *
 * Paramètre de sortie :
 *   - aArgPChar : Chaine ASCIIZ
 *
 * Retour : true si l'extension chargée
 *****************************************************************************}
procedure TStringListToPChar(aoArgTStringList : TStringList; var aArgPChar : PChar) ;
Var
    { Compteur de boucle }
    liIndex : Integer ;
    { Longueur de la chaine de destination }
    liLength : Integer ;
begin
    liLength := 0 ;

    for liIndex := 0 to aoArgTStringList.Count - 1 do
    begin
        { +1 pour le #0 }
        liLength := liLength + Length(aoArgTStringList[liIndex]) + 1 ;
    end ;

    { +1 pour le double #0 }
    GetMem(aArgPChar, liLength + 1) ;

    liLength := 0 ;

    for liIndex := 0 to aoArgTStringList.Count - 1 do
    begin
        StrPCopy(@aArgPChar[liLength], aoArgTStringList[liIndex]) ;

        liLength := liLength + Length(aoArgTStringList[liIndex]) ; ;
        aArgPChar[liLength] := #0 ;
        Inc(liLength) ;
    end ;

    aArgPChar[liLength] := #0 ;
end ;