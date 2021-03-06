{*****************************************************************************
 * ExtractCommande
 * MARTINEAU Emeric
 *
 * Extrait la premi�re partie jusqu'au premier caract�re non valide
 *
 * Param�tres d'entr�e :
 *   - asText : texte � traiter
 *
 * Retour : texte jusqu'au premier espace ou tabulation
 *****************************************************************************}
function ExtractCommande(asText : string) : string ;
var
    { Compteur de boucle }
    liIndex : Integer ;
    { Longueur du texte }
    liLengthOfString : Integer ;
begin
    //asText := Trim(asText) ;
    Result := '' ;

    liLengthOfString := Length(asText) + 1 ;

    liIndex := 1 ;

    while (liIndex < liLengthOfString) do
    begin
        if (LowerCase(asText[liIndex]) in ['a'..'z']) or
           (asText[liIndex] in ['0'..'9']) or (asText[liIndex] = '_')
        then begin
            Result := Result + asText[liIndex] ;
        end
        else if (asText[liIndex] = ' ') or (asText[liIndex] = #9) or
             (asText[liIndex] = ':')
        then begin
            { Attention case et default ne doivent pas �tre pris comme un label }
            if (Result = 'case') or (Result = 'default')
            then begin
                break ;
            end ;

            if (asText[liIndex] <> ':')
            then begin
                { On ne tient pas compte des espaces }
                Inc(liIndex) ;

                while (asText[liIndex] = ' ') or (asText[liIndex] = #9) do
                begin
                    Inc(liIndex) ;
                end ;
            end ;

            if (asText[liIndex] = ':')
            then begin
                { Il s'agit d'un label et non d'un commande on recomme
                l'op�ration }
                Result := '' ;

                { On ne tient pas compte des espaces suivant }
                Inc(liIndex) ;

                while (asText[liIndex] = ' ') or (asText[liIndex] = #9) do
                begin
                    Inc(liIndex) ;
                end ;
            end
            else begin
                break ;
            end ;

            { On d�cr�mente car � la fin de la boucle on incr�ment }
            Dec(liIndex) ;
        end
        else begin
            break ;
        end ;

        Inc(liIndex) ;
    end ;
end ;