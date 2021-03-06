{*****************************************************************************
 * OutputString
 * MARTINEAU Emeric
 *
 * Ecrit sur la sortie standard. V�rifie au pr�alable que l'ent�te � �t� envoy�.
 * Si ce n'est pas le cas, envoie l'ent�te.
 *
 * Param�tre d'entr�e :
 *     - asText : texte � afficher,
 *     - lbParse : indique si on doit interpr�ter les \n, \t, \r, \0
 ****************************************************************************}
procedure OutputString(asText : String; abParse : boolean)  ;
var
    { Compteur de boucle de chaine }
    liIndex : Integer ;
    { Taille de la chaine � afficher }
    liLength : Integer ;
    { Texte � afficher }
    lsTexteDeSortie : String ;
    { Argument de la fonction output }
    loOutPutFunctionArgs : TStringList ;
    { Ancienne valeur gbIsExecutableCode }
    lbOldEC : Boolean ;
begin
    { On envoie l'ent�te si �a n'a pas �t� fait }
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
            { Prochain caract�re }
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
            { Il se peut que la fonction soit appel�e dans du code HTML.
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