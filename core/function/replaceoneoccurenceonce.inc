{*****************************************************************************
 * ReplaceOneOccurenceOnce
 * MARTINEAU Emeric
 *
 * Remplace une occurence dans une chaine de caractère si la chaine n'a pas été
 * modifié précédement.
 *
 * Paramètres d'entrée :
 *   - asSubStr     : chaine à remplacer
 *   - asStr        : chaine à traiter
 *   - asReplaceStr : chaine de remplacement
 *   - asStrMod     : chaine aussi longue que Str contenant que 0. Les caractères
 *                    modifiés seront mis à 1
 *
 * Paramètre de sortie :
 *   - asStr        : chaine modifiée avec l'occurence substr
 *   - asStrMod     : les caractère modifiés sont mis à 1
 *****************************************************************************}
procedure ReplaceOneOccurenceOnce(asSubStr : string; var asStr : string; asReplaceStr : string; var asStrMod : String) ;
var
    { Position de SubStr }
    liPositionOfSubStr : Integer;
    { Longueur de SubStr }
    liLengthSubStr : Integer ;
    { Longueur de ReplaceStr }
    liLengthReplaceStr : Integer ;

    function ModifiedString(stringmodified : string; start, len : Integer) : Boolean ;
    var i : Integer ;
    begin
        Result := False ;

        for i := start to (start + len - 1) do
        begin
            if stringmodified[i] = '1'
            then begin
                Result := True ;
                break ;
            end ;
        end ;
    end ;
begin
    liLengthSubStr := Length(asSubStr) ;
    liLengthReplaceStr := Length(asReplaceStr) ;

    liPositionOfSubStr := posString(asSubStr, asStr, 1, true) ;

    while liPositionOfSubStr <> 0 do
    begin
        OverTimeAndMemory ;
        
        if gbQuit
        then
            break ;

        if not ModifiedString(asStrMod, liPositionOfSubStr, liLengthSubStr)
        then begin
            Delete(asStr, liPositionOfSubStr, liLengthSubStr) ;
            Insert(asReplaceStr, asStr, liPositionOfSubStr) ;

            Delete(asStrMod, liPositionOfSubStr, liLengthSubStr) ;
            Insert(RepeterCaractere('1', liLengthReplaceStr), asStrMod, liPositionOfSubStr) ;
            
            liPositionOfSubStr := posString(asSubStr, asStr, liPositionOfSubStr + liLengthReplaceStr, true) ;
        end
        else begin
            liPositionOfSubStr := posString(asSubStr, asStr, liPositionOfSubStr + liLengthReplaceStr, true) ;
        end ;
    end ;
end ;