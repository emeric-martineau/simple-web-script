{*****************************************************************************
 * ReplaceOneOccurence
 * MARTINEAU Emeric
 *
 * Remplace une occurence dans une chaine de caract�re
 *
 * Param�tres d'entr�e :
 *   - asSubstr        : chaine � remplacer
 *   - asStr           : chaine � traiter
 *   - asReplaceStr    : chaine de remplacement
 *   - abCaseSensitive : tenir compte de la caase
 *
 * Param�tre de sortie :
 *   - asStr           : nouvelle chaine
 *****************************************************************************}
function ReplaceOneOccurence(asSubstr : string; var asStr : string; asReplaceStr : string; abCaseSensitive : Boolean) : Cardinal ;
var
    { Position de la chaine � remplacer }
    liPositionOfStr : Integer;
    { Longueur de la chaine � remplacer }
    liLenSubStr : Integer ;
    { Longueur de la chaine de remplacement }
    liLenReplaceStr : Integer ;
begin
    liPositionOfStr := posString(asSubstr, asStr, 1, abCaseSensitive) ;
    Result := 0 ;
    liLenReplaceStr := length(asReplaceStr) ;
    liLenSubStr := Length(asSubstr) ;

    while liPositionOfStr <> 0 do
    begin
        OverTimeAndMemory ;
        
        if gbQuit
        then begin
            break ;
        end ;
        
        Inc(Result) ;
        Delete(asStr, liPositionOfStr, liLenSubStr) ;
        Insert(asReplaceStr, asStr, liPositionOfStr) ;
        liPositionOfStr := posString(asSubstr, asStr, liPositionOfStr + liLenReplaceStr, abCaseSensitive) ;
    end ;
end ;