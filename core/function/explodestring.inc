{*****************************************************************************
 * ExplodeStrings
 * MARTINEAU Emeric
 *
 * Fonction qui split les commandes
 *
 * Paramètres d'entrée :
 *   - asText : texte à traiter
 *
 * Paramètre de sortie :
 *   - asListe : TStringList contenant les divers élément
 *
 *****************************************************************************}
procedure ExplodeStrings(asText : string; aoLigne : TStringList) ;
var
    { Element courant }
    lsElementCourant : string ;
    { Compteur de boucle pour asText }
    liIndexText : Integer ;
    { Compteur pour traiter un sous chaine dans asText }
    liIndexSousChaine : Integer ;
    { Longueur de asText }
    liLengthText : Integer ;
    { Indique si on est dans une chaine "" ou '' }
    lbInQuote : boolean ;
    { Caractère courant. On utilise string pour LowerCase() }
    lsCaractere : string ;
    { Délimiteur de chaine " ou ' }
    lsDelimiter : string ;
    { Indique si on est dans un nombre et si on a trouvé un point. Permet de la pas
      avoir de nombre avec plusieurs points }
    lbDotFound : boolean ;
    { Indique si on a trouvé un X est si on est donc en hexa décimal }
    lbXFound : boolean ;
    { Indique qu'il s'agit d'un pointeur }
    lbPointer : boolean ;
    { Position de fin de commentaire multi-ligne }

    procedure CopyVarName ;
    begin
        { Si on est dans le cas $$var }
        if asText[liIndexText] = '$'
        then begin
            lsElementCourant := lsElementCourant + '$' ;
            Inc(liIndexText) ;
        end ;
        
        while liIndexText < liLengthText do
        begin
            lsElementCourant := lsElementCourant + asText[liIndexText] ;
            Inc(liIndexText) ;

            lsCaractere := LowerCase(asText[liIndexText]) ;

            if not ((asText[liIndexText] in ['0'..'9']) or (lsCaractere[1] in ['a'..'z']) or (asText[liIndexText] = '_'))
            then begin
                if asText[liIndexText] = '['
                then begin
                    liIndexSousChaine := 0 ;

                    while liIndexSousChaine < (liLengthText - liIndexText) do
                    begin
                        if asText[liIndexText+liIndexSousChaine] <> ']'
                        then begin
                            lsElementCourant := lsElementCourant + asText[liIndexText+liIndexSousChaine] ;
                            Inc(liIndexSousChaine) ;
                        end
                        else begin
                            break ;
                        end ;
                    end ;

                    { Inutile d'ajouter ] car on refait un tour dans la boucle principal et c'est ajouté automatiquement }
                    Inc(liIndexText, liIndexSousChaine) ;
                end
                else begin
                    break ;
                end ;
            end ;
        end ;
    end ;

    procedure CopyToVarName ;
    begin
        while (asText[liIndexText] = '*') do
        begin
            lsElementCourant := lsElementCourant + asText[liIndexText] ;

            Inc(liIndexText) ;
        end ;
    end ;
begin
    aoLigne.Clear ;

    lsElementCourant := '' ;
    liIndexText := 1 ;
    liLengthText := Length(asText) + 1 ;

    {
    1 - si on est dans une chaine copier jusqu'à la fin de la chaine si fin de chaine mère alors manque un "
    2 - si c'est un nom de variable
    3 - gérer tous les cas
        ()
        -
        +
        *
        /
        ^
        #
        @
        <<
        >>
        ~
        %
        .
        =
        <=
        <
        <>
        >=
        >
     }

    while liIndexText < liLengthText do
    begin
        if (asText[liIndexText] = '(') or
           (asText[liIndexText] = ')') or
           (asText[liIndexText] = '-') or
           (asText[liIndexText] = '+') or
           (asText[liIndexText] = '%') or
           (asText[liIndexText] = '=') or
           (asText[liIndexText] = '[') or
           (asText[liIndexText] = ']') or
           (asText[liIndexText] = ',') or
           (asText[liIndexText] = '/') or
           (asText[liIndexText] = '^') or
           (asText[liIndexText] = '~') or
           (asText[liIndexText] = '|')
        then begin
            aoLigne.Add(asText[liIndexText]) ;
        end
        else if (asText[liIndexText] = ';')
        then begin
            break ;
        end
        else if asText[liIndexText] = '.'
        then begin
            lsElementCourant := '.' ;

            if (liIndexText + 2) < liLengthText
            then begin
                if (asText[liIndexText+1] = '.') and (asText[liIndexText+2] = '.')
                then begin
                    lsElementCourant := lsElementCourant + '..' ;
                    Inc(liIndexText, 2) ;
                end ;
            end ;

            aoLigne.Add(lsElementCourant)
        end
        else if asText[liIndexText] = '*'
        then begin
            if liIndexText < liLengthText
            then begin
                { Si c'est une variable qui suit et qu'il n'y a rien avant, c'est un pointer }
                if ((asText[liIndexText + 1] = '$') or (asText[liIndexText + 1] = '*')) and (liIndexText = 1)
                then begin
                    lbPointer := True ;
                end
                else if ((asText[liIndexText + 1] = '$') or (asText[liIndexText + 1] = '*')) and (liIndexText > 0)
                then begin
                   { Si c'est une variable, on regarde avant l'étoile pour savoir si c'est
                     un nom de variable. Si c'est le cas, c'est un multiplication sinon, c'est
                     un pointeur }
                   if not (LowerCase(asText[liIndexText - 1]) in ['a'..'z']) and not (asText[liIndexText - 1] in ['0'..'9']) and not (asText[liIndexText - 1] = '_')
                   then begin
                       lbPointer := True ;
                   end
                   else begin
                       lbPointer := False ;
                   end ;
                end
                else begin
                    lbPointer := False ;
                end ;

                if lbPointer
                then begin

                    { C'est une variable }
                    lsElementCourant := '' ;
                    { Copie les étoiles }
                    CopyToVarName ;
                    { Copie le nom de variable }
                    CopyVarName ;
                    
                    { Décrémente pour qu'on pointe sur le caratère qui nous à fait arrêté }
                    Dec(liIndexText) ;

                    aoLigne.Add(lsElementCourant) ;
                end
                else begin
                    aoLigne.Add('*') ;
                end ;
            end
            else begin
                aoLigne.Add('*') ;
            end ;
        end
        else if asText[liIndexText] = '&'
        then begin
            lbPointer := False ;
            
            if liIndexText < liLengthText
            then begin
                { Si c'est une variable qui suit et qu'il n'y a rien avant, c'est un pointer }
                if (asText[liIndexText + 1] = '$') and (liIndexText = 1)
                then begin
                    lbPointer := True ;
                end
                else if (asText[liIndexText + 1] = '$') and (liIndexText > 0)
                then begin
                   { On vérifie qu'il s'agit d'un nom de variable }
                   if not (LowerCase(asText[liIndexText - 1]) in ['a'..'z']) and not (asText[liIndexText - 1] in ['0'..'9']) and not (asText[liIndexText - 1] = '_')
                   then begin
                       lbPointer := True ;
                   end ;
                end ;
            end ;

            if lbPointer
            then begin
                { C'est une variable }
                lsElementCourant := '&' ;
                Inc(liIndexText) ;

                CopyVarName ;

                { Décrémente pour qu'on pointe sur le caratère qui nous à fait arrêté }
                Dec(liIndexText) ;

                aoLigne.Add(lsElementCourant) ;
            end
            else begin
                ErrorMsg(csNotVariableAfterAmp) ;
            end ;
        end
        else if asText[liIndexText] = '<'
        then begin
            if liIndexText < liLengthText
            then begin
                if asText[liIndexText+1] = '<'
                then begin
                    Inc(liIndexText) ;
                    aoLigne.Add('<<')
                end
                else if asText[liIndexText+1] = '='
                then begin
                    Inc(liIndexText) ;
                    aoLigne.Add('<=')
                end
                else if asText[liIndexText+1] = '>'
                then begin
                    Inc(liIndexText) ;
                    aoLigne.Add('<>')
                end
                else begin
                    aoLigne.Add('<') ;
                end ;
            end
            else begin
                aoLigne.Add('<') ;
            end ;
        end
        else if asText[liIndexText] = '>'
        then begin
            if liIndexText < liLengthText
            then begin
                if asText[liIndexText+1] = '>'
                then begin
                    Inc(liIndexText) ;
                    aoLigne.Add('>>')
                end
                else if asText[liIndexText+1] = '='
                then begin
                    Inc(liIndexText) ;
                    aoLigne.Add('>=')
                end
                else begin
                    aoLigne.Add('>') ;
                end ;
            end
            else begin
                aoLigne.Add('>') ;
            end ;
        end
        else if (asText[liIndexText] in ['0'..'9'])
        then begin
            { C'est un nombre }
            lsElementCourant := '' ;
            lbDotFound := False ;
            lbXFound := False ;

            while liIndexText < liLengthText do
            begin
                if (asText[liIndexText] in ['0'..'9']) or (asText[liIndexText] in ['a'..'f']) or (asText[liIndexText] in ['A'..'F'])
                then
                    lsElementCourant := lsElementCourant + asText[liIndexText]
                else if (not lbDotFound) and (asText[liIndexText] = '.')
                then begin
                    lbDotFound := True ;
                    lsElementCourant := lsElementCourant + asText[liIndexText] ;
                end
                else if (not lbXFound) and (asText[liIndexText] = 'x')
                then begin
                    lbXFound := True ;
                    lsElementCourant := lsElementCourant + asText[liIndexText] ;
                end
                else begin
                    break ;
                end ;

                Inc(liIndexText) ;
            end ;

            aoLigne.Add(lsElementCourant) ;

            { Décrément car on à une Inc(liIndexText) à la fin de la boucle }
            Dec(liIndexText) ;
        end
        else if (asText[liIndexText] = '"') or (asText[liIndexText] = '''')
        then begin
            lsDelimiter := asText[liIndexText] ;

            { On est dans une chaine }
            lsElementCourant := '' ;
            lbInQuote := True ;
            Inc(liIndexText) ;

            while liIndexText <= liLengthText do
            begin
                { Prochain caractère }
                if asText[liIndexText] = '\'
                then begin
                    Inc(liIndexText) ;

                    if liIndexText <= liLengthText
                    then begin
                        if asText[liIndexText] = 'n'
                        then begin
                            asText[liIndexText] := char(10) ;
                        end
                        else if asText[liIndexText] = 'r'
                        then begin
                            asText[liIndexText] := char(13) ;
                        end
                        else if asText[liIndexText] = '0'
                        then begin
                            asText[liIndexText] := char(0) ;
                        end
                        else if asText[liIndexText] = 't'
                        then begin
                            asText[liIndexText] := char(9) ;
                        end ;
                    end
                end
                else if asText[liIndexText] = lsDelimiter
                then begin
                    lbInQuote := False ;
                    break ;
                end ;

                lsElementCourant := lsElementCourant + asText[liIndexText] ;

                Inc(liIndexText) ;
            end ;

            aoLigne.Add('"' + lsElementCourant + '"') ;

            if lbInQuote
            then begin
                ErrorMsg(csNoEndString) ;
            end ;
        end
        else begin
            if (asText[liIndexText] <> #9) and (asText[liIndexText] <> ' ')
            then begin
                lsElementCourant := '' ;

                CopyVarName ;

                { Décrémente pour qu'on pointe sur le caratère qui nous à fait arrêté }
                Dec(liIndexText) ;

                aoLigne.Add(lsElementCourant) ;
            end ;
        end ;

        Inc(liIndexText) ;
    end ;
end ;