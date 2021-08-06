{*****************************************************************************
 * LoadCode
 * MARTINEAU Emeric
 *
 * Charge un fichier de code en supprimant les lignes commentées
 *
 * Paramètres d'entrée :
 *   - asFileName : nom du fichier à charger,
 *   - aiStartLine : numéro de ligne de départ dans goCodeList
 *
 * Retrour : true si le fichier est chargé
 *****************************************************************************}
function LoadCode(asFileName : String; aiStartLine : Integer) : boolean ;
Var
    { TStringList recevant le code du fichier à lire }
    loTmpCode : TStringList ;
    { Compteur de boucle de loTmpCode }
    liIndexTmpCode : integer ;
    { Numéro du fichier dans goLineToFile }
    liNumFile : Integer ;
    { Valeur de décalage par rapport à l'offset dans le fichier lors de l'ajout
      d'une ligne }
    liIncOfOffset : Integer ;
    { Variable temporaire pour extraire le code entre balise <@ et @>}
    lsTmp : String ;
    { Position des balises <@ ou @> }
    liPositionOfTag : Integer ;
    { Indique si on est dans du HTML ou dans du code }
    lbInHTML : Boolean ;
    { Indique qu'il n'y a plus de balise code <@ @> }
    lbWorkInLineIsEnd : Boolean ;
    { Index de chaine pour savoir ou est la balise @> ou // /* }
    liIndexBalise : Integer ;
    { Ligne courante }
    lsCurrentLine : String ;
    { Caractère ouvrant une chaine }
    lcOpenString : Char ;
    { Longueur de la ligne courante }
    liLengthCurrentLine : Integer ;
    { Indique si on est dans un commentaire multi ligne }
    lbInMultiLineComment : boolean ;
    { Position de la fin de commentarie multi ligne }
    liEndOfMultiLineComment : Integer ;
    { Operateur de commande }
    lsCommande : String ;
    { Fin de ligne }
    lsEndOfLine : String ;
    { Ligne d'avant }
    lsBeforeLine : String ;
    { Position de départ de la ligne }
    liStartLineNumber : Integer ;
    { Fin de ligne à trouver }
    lsEndOfLineToFound : String ;
    { Contient l'ancienne valeur de ligne courante pour afficher l'erreur au bon
      endroit}
    liOldCurrentLineNumber : Integer ;

    procedure add(asText : String) ;
    var
        lsMulTiLine : String ;
    begin
        if (asText <> '') or (lbInHTML)
        then begin
            goCodeList.Insert(aiStartLine + liIncOfOffset, asText) ;
            goLineToFile.Insert(aiStartLine + liIncOfOffset, liNumFile) ;
            
            if (liStartLineNumber = -1)
            then begin
                goLineToFileLine.Insert(aiStartLine + liIncOfOffset, IntToStr(liIndexTmpCode + 1)) ;
            end
            else begin
                lsMulTiLine := csLineToLine ;
                ReplaceOneOccurence('%line1', lsMulTiLine, IntToStr(liStartLineNumber + 1) , false) ;
                ReplaceOneOccurence('%line2', lsMulTiLine, IntToStr(liIndexTmpCode + 1) , false) ;
                goLineToFileLine.Insert(aiStartLine + liIncOfOffset, lsMulTiLine) ;
            end ;
            
            Inc(liIncOfOffset) ;
        end ;
    end ;
begin
    Result := False ;
    asFileName := Realpath(asFilename) ;
    lbInMultiLineComment := false ;
    lsBeforeLine := '' ;
    liStartLineNumber := -1 ;
    liOldCurrentLineNumber := giCurrentLineNumber ;

    { Vérifie l'inclusion du fichier si on est en safe mode }
    if (gbSafeMode = True) and (gsDocRoot <> '')
    then begin
        if Pos(gsDocRoot, asFileName) = 0
        then begin
            ErrorMsg(csCantDoThisInSafeMode) ;

            exit ;
        end ;
    end ;

    {$I-}
    try
        if FileExists(asFileName)
        then begin
            liNumFile := goListOfFile.Count ;

            goListOfFile.Add(asFileName) ;

            goCurrentRootOfFile.Add(OsAddFinalDirSeparator(ExtractFileDir(asFileName))) ;

            loTmpCode := TStringList.Create ;

            loTmpCode.LoadFromFile(asFileName) ;

            liIndexTmpCode := 0 ;
            liIncOfOffset := 0 ;
            lbInHTML := True ;

            while liIndexTmpCode < loTmpCode.Count do
            begin
                OverTimeAndMemory ;
                
                if gbQuit
                then begin
                    break ;
                end ;

                repeat
                    lbWorkInLineIsEnd := False ;
                
                    if lbInHTML
                    then begin
                        { Code HTML }
                        liPositionOfTag := pos(csStartSwsTag, loTmpCode[liIndexTmpCode]) ;

                        if liPositionOfTag <> 0
                        then begin
                            { Si <@ est en début de ligne, tmp sera égal à ''. On ajoutera
                              donc une ligne vide à tord }
                            if liPositionOfTag > 1
                            then begin
                                lsTmp := Copy(loTmpCode[liIndexTmpCode], 1, liPositionOfTag - 1) ;
                                add(lsTmp) ;
                            end ;

                            add(csStartSwsTag) ;

                            { On met à jour la ligne en cours de traitement pour continuer
                              à la traiter }
                            loTmpCode[liIndexTmpCode] := Copy(loTmpCode[liIndexTmpCode], liPositionOfTag + Length(csStartSwsTag), length(loTmpCode[liIndexTmpCode]) - (liPositionOfTag + 1) ) ;

                            lbInHTML := False ;
                        end
                        else begin
                            lbWorkInLineIsEnd := True ;
                        end ;
                    end
                    else begin
                        { Code SWS }

                        { Recherche de commentaire }
                        lsCurrentLine := loTmpCode[liIndexTmpCode] ;

                        lsCurrentLine := Trim(lsCurrentLine) ;

                        liIndexBalise := 1 ;

                        liLengthCurrentLine := Length(lsCurrentLine) +1 ;

                        liPositionOfTag := 0 ;

                        lsCommande := ExtractCommande(lsCurrentLine) ;

                        { C'est un label il n'y a pas de fin }
                        if (lsCommande = '')
                        then begin
                            lsEndOfLineToFound := '' ;
                        end
                        else begin
                            lsEndOfLineToFound := GetEndOfLine(lsCommande) ;
                        end ;

                        while liIndexBalise < liLengthCurrentLine do
                        begin
                            if (lsCurrentLine[liIndexBalise] = '"') or
                               (lsCurrentLine[liIndexBalise] = '''')
                            then begin
                                { On entre dans une chaine }
                                lcOpenString := lsCurrentLine[liIndexBalise] ;

                                Inc(liIndexBalise) ;

                                while liIndexBalise < liLengthCurrentLine do
                                begin
                                    if lsCurrentLine[liIndexBalise] = '\'
                                    then begin
                                        { Caractère d'échappement on ignore le caractère
                                          suivant }
                                        Inc(liIndexBalise)
                                    end
                                    else if lsCurrentLine[liIndexBalise] = lcOpenString
                                    then begin
                                        { On a atteind la fin de la chaine }
                                        break ;
                                    end ;

                                    Inc(liIndexBalise) ;
                                end ;
                            end
                            else if Copy(lsCurrentLine, liIndexBalise, Length(csMultiLineCommentStart)) = csMultiLineCommentStart
                            then begin
                                { Commentaire multi ligne }
                                lsTmp := Copy(lsCurrentLine, 1, liIndexBalise - 1) ;

                                { On recherche la fin de commentaire dans la ligne }
                                liEndOfMultiLineComment := pos(csMultiLineCommentStop, lsCurrentLine) ;

                                if liEndOfMultiLineComment <> 0
                                then begin
                                    lsCurrentLine := Trim(lsTmp + Copy(lsCurrentLine, liEndOfMultiLineComment + Length(csMultiLineCommentStart),  Length(lsCurrentLine))) ;

                                    liLengthCurrentLine := Length(lsCurrentLine) ;

                                    { Il faut décrémenté car on incrément après }
                                    Dec(liIndexBalise) ;

                                    { Si le commentaire est au début de la ligne, il faut
                                      relire la commande }
                                    if liIndexBalise = 0
                                    then begin
                                        lsCommande := ExtractCommande(lsCurrentLine) ;

                                        lsEndOfLineToFound := GetEndOfLine(lsCommande) ;
                                    end ;
                                end
                                else begin
                                    lsCurrentLine := Trim(Copy(lsCurrentLine, 1, liIndexBalise - 1)) ;

                                    lbInMultiLineComment := true ;

                                    lbWorkInLineIsEnd := True ;

                                    liPositionOfTag := 0 ;
                                    
                                    break ;
                                end ;
                            end
                            else if Copy(lsCurrentLine, liIndexBalise, Length(csSingleComment)) = csSingleComment
                            then begin
                                { Commentaire mono ligne }
                                lsCurrentLine := Trim(Copy(lsCurrentLine, 1, liIndexBalise - 1)) ;
                                
                                liPositionOfTag := 0 ;
                                
                                lbWorkInLineIsEnd := True ;
                                
                                break ;
                            end
                            else if Copy(lsCurrentLine, liIndexBalise, Length(csEndSwsTag)) = csEndSwsTag
                            then begin
                                { Fin de tag SWS trouvée }
                                liPositionOfTag := liIndexBalise ;
                                break ;
                            end
                            else if (Copy(lsCurrentLine, liIndexBalise, Length(lsEndOfLineToFound)) = lsEndOfLineToFound) or
                                    (lsEndOfLineToFound = '')
                            then begin
                                { fin de commande trouvée }
                                if (lsEndOfLineToFound <> '')
                                then begin
                                    { Si on a un séparateur de commande }
                                    { On sauvegarde la ligne car on doit la couper en deux }
                                    lsTmp := lsCurrentLine ;
                                
                                    lsCurrentLine := Trim(Copy(lsTmp, 1, liIndexBalise + Length(lsEndOfLineToFound))) ;
                                
                                    lsTmp := Copy(lsTmp, liIndexBalise + Length(lsEndOfLineToFound), Length(lsTmp)) ;
                                
                                    loTmpCode[liIndexTmpCode] := lsTmp ;
                                end
                                else begin
                                    Inc(liIndexTmpCode) ;
                                end ;

                                liPositionOfTag := 0 ;

                                break ;
                            end ;

                            Inc(liIndexBalise) ;
                        end ;

                        { Si on a un fin de tag SWS }
                        if liPositionOfTag <> 0
                        then begin
                            lsTmp := Copy(lsCurrentLine, 1, liPositionOfTag - 1) ;

                            if (lsTmp <> '')
                            then begin
                                lsTmp := Trim(lsTmp) ;
                                add(lsTmp) ;
                            end ;

                            lbInHTML := True ;

                            add(csEndSwsTag) ;

                            { On met à jour la ligne en cours de traitement pour continuer
                              à la traiter }
                            loTmpCode[liIndexTmpCode] := Copy(lsCurrentLine, liPositionOfTag + Length(csEndSwsTag), length(loTmpCode[liIndexTmpCode]) - (liPositionOfTag + 1) ) ;
                            
                            { Evite d'inclure la ligne }
                            lsCurrentLine := '' ;
                        end
                        else begin
                            if lbWorkInLineIsEnd = True
                            then begin
                                { Evite d'inclure 2 fois la ligne }
                                loTmpCode[liIndexTmpCode] := '' ;
                            end ;
                        end ;

                        if lsCurrentLine <> ''
                        then begin
                            { Vérifie que la ligne se termine bien par ce qui est prévu }
                            {
                            On l'a déjà
                            lsCommande := ExtractCommande(lsCurrentLine) ;

                            lsEndOfLineToFound :=  GetEndOfLine(lsCommande) ;
                            }

                            lsEndOfLine := ExtractEndOperator(lsCurrentLine) ;

                            if (lsEndOfLineToFound = '') or (lsEndOfLine = lsEndOfLineToFound)
                            then begin
                                add(lsBeforeLine + lsCurrentLine) ;
                                
                                lsBeforeLine := '' ;
                                
                                liStartLineNumber := -1 ;
                            end
                            else if IsEndOperatorBy(lsEndOfLine)
                            then begin
                                if liStartLineNumber = -1
                                then begin
                                    liStartLineNumber := liIndexTmpCode ;
                                end ;
                                
                                lsBeforeLine := lsBeforeLine + lsCurrentLine ;
                                
                                Inc(liIndexTmpCode) ;
                            end
                            else begin
                                { On ajoute un ligne pour avoir le numéro de ligne }
                                add('Error !!!!') ;

                                ErrorMsg(Format(csMissingEndOfLine, [GetEndOfLine(lsCommande)])) ;
                            end ;
                        end
                        else begin
                            { Evite d'inclure la ligne si elle est vide }
                            loTmpCode[liIndexTmpCode] := '' ;
                            { Le traitement de la ligne est fini }
                            lbWorkInLineIsEnd := True ;
                        end ;
                    end ;
                until (lbWorkInLineIsEnd = True) or (gbQuit = True) ;

                { On charge la correspondance de ligne au fur et a mesure mais
                  il faut incrémenter l'index de ligne pour afficher l'erreur au
                  bon endroit }
                Inc(giCurrentLineNumber) ;

                if gbQuit
                then begin
                    break ;
                end ;

                if (loTmpCode[liIndexTmpCode] <> '') or (lbInHTML)
                then begin
                    if lbInHTML
                    then begin
                        if liIndexTmpCode <> (loTmpCode.Count - 1)
                        then begin
                            loTmpCode[liIndexTmpCode] := loTmpCode[liIndexTmpCode] + #13 ;
                        end ;
                    end ;
                        
                    add(loTmpCode[liIndexTmpCode]) ;
                end ;

                Inc(liIndexTmpCode) ;
                
                { Si on est dans un commentaire multi ligne }
                if lbInMultiLineComment
                then begin
                    lbInMultiLineComment := false ;
                    
                    { On va chercher la fin du commentaire }
                    while liIndexTmpCode < loTmpCode.Count do
                    begin
                        liIndexBalise := pos(csMultiLineCommentStop, loTmpCode[liIndexTmpCode]) ;
                        
                        if liIndexBalise <> 0
                        then begin
                            lsCurrentLine := loTmpCode[liIndexTmpCode] ;
                            
                            { On recopie la ligne dans loTmpCode pour qu'elle soit de nouveau parsé }
                            lsCurrentLine := Copy(lsCurrentLine, liIndexBalise + Length(csMultiLineCommentStop), Length(lsCurrentLine)) ; ;
                            
                            loTmpCode[liIndexTmpCode] := Trim(lsCurrentLine) ;
                            
                            break ;
                        end ;
                        
                        Inc(liIndexTmpCode) ;
                    end ;
                end ;
            end ;

            FreeAndNil(loTmpCode) ;

            if not gbQuit
            then begin
                Result := True ;
            end ;
        end
        else begin
            if goListOfFile.Count > 0
            then begin
                if goLineToFileLine.Count = 0
                then begin
                    goLineToFileLine.Add('1') ;
                    goLineToFile.Add(0) ;
                end ;

                ErrorMsg(Format(csFileNotFound, [asFileName])) ;
            end
            else begin
                ErrorMsg(Format(csMainFileNotFound, [asFileName])) ;
            end ;
        end ;
    except
        on EInOutError do ErrorMsg(Format(csCantReadFile, [asFileName])) ;
    end ;
    {$I+}

    giCurrentLineNumber := liOldCurrentLineNumber ;
end ;