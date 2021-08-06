{*****************************************************************************
 * OutputString
 * MARTINEAU Emeric
 *
 * Ecrit sur la sortie standard. Vérifie au préalable que l'entête à été envoyé.
 * Si ce n'est pas le cas, envoie l'entête.
 *
 * Paramètre d'entrée :
 *     - asText : texte à afficher,
 *     - lbParse : indique si on doit interpréter les \n, \t, \r, \0
 ****************************************************************************}
procedure OutputString(asText : String; abParse : boolean)  ;
var
    { Compteur de boucle de chaine }
    liIndex : Integer ;
    { Taille de la chaine à afficher }
    liLength : Integer ;
    { Texte à afficher }
    lsTexteDeSortie : String ;
    { Argument de la fonction output }
    loOutPutFunctionArgs : TStringList ;
    { Ancienne valeur gbIsExecutableCode }
    lbOldEC : Boolean ;
begin
    { On envoie l'entête si ça n'a pas été fait }
    if (not gbIsHeaderSend) and (not gbIsOutPuBuffered)
    then begin
        SendHeader ;
    end ;

    if abParse
    then begin
        liIndex := 1 ;
        liLength := Length(asText) ;
        lsTexteDeSortie := '' ;

        while liIndex <= liLength do
        begin
            { Prochain caractère }
            if asText[liIndex] = '\'
            then begin
                Inc(liIndex) ;

                if liIndex <= liLength
                then begin
                    if asText[liIndex] = 'n'
                    then begin
                        lsTexteDeSortie := lsTexteDeSortie + char(10) ;
                    end
                    else if asText[liIndex] = 'r'
                    then begin
                        lsTexteDeSortie := lsTexteDeSortie + char(13) ;
                    end
                    else if asText[liIndex] = 't'
                    then begin
                        lsTexteDeSortie := lsTexteDeSortie + char(9) ;
                    end
                    else begin
                        lsTexteDeSortie := lsTexteDeSortie + asText[liIndex] ;
                    end
                end
                else begin
                    lsTexteDeSortie := lsTexteDeSortie + asText[liIndex] ;
                end ;
            end
            else begin
                lsTexteDeSortie := lsTexteDeSortie + asText[liIndex] ;
            end ;

            Inc(liIndex) ;
        end ;
    end
    else begin
        lsTexteDeSortie := asText ;
    end ;

    if gbIsOutPuBuffered
    then begin

        loOutPutFunctionArgs := TStringList.Create ;
        loOutPutFunctionArgs.Add(lsTexteDeSortie) ;

        if gsOutPutFunction <> ''
        then begin
            { Il se peut que la fonction soit appelée dans du code HTML.
              De ce fait, ExecuteUserProcedure sera en mode HTML et pas
              en mode code. }
            lbOldEC := gbIsExecutableCode ;
            gbIsExecutableCode := True ;

            ExecuteUserProcedure(gsOutPutFunction, loOutPutFunctionArgs) ;

            gbIsExecutableCode := lbOldEC ;
        end
        else begin
            gsResultFunction := lsTexteDeSortie ;
        end ;
        
        FreeAndNil(loOutPutFunctionArgs) ;
        gsOutPutContent := gsOutPutContent + gsResultFunction ;
    end
    else begin
        write(lsTexteDeSortie) ;
    end ;
end ;