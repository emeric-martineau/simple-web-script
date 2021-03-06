{*****************************************************************************
 * Realpath
 * MARTINEAU Emeric
 *
 * Fonction qui split les commandes
 *
 * Param�tres d'entr�e :
 *   - asFileName : nom du fichier
 *
 * Retour : nom du fichier complet
 *****************************************************************************}
function Realpath(asFileName : string) : String ;
var
    { Contient la liste de r�pertoire + le fichier pass� en param�tre }
    ListDirectory  : TStringList ;
    { Contient la liste de r�pertoire du r�pertoire racine ajout� si la chaine
      commence par un point (.) }
    ListDirecoryRoot : TStringList ;
    { Compteur de boucle }
    liIndexCounter : Integer ;
    { Position de . ou .. }
    liIndex : Integer ;
    { Contient le r�pertoire racine }
    lsRoot : String ;
begin
    if asFileName <> ''
    then begin
        ListDirectory := TStringList.Create ;

        Explode(asFileName, ListDirectory, '/') ;
        lsRoot := '' ;

        if ListDirectory.Count > 0
        then begin
            { On ajoute doc_root si on commence par . ou si le chemin ne
              commence pas par la racine }
            if ListDirectory[0] = '.'
            then begin
                lsRoot := gsDocRoot ;
            end
            else begin
                if not OsIsRootDirectory(asFileName)
                then begin
                    lsRoot := gsDocRoot ;
                end ;
            end ;

            { Si tmp <> '' c'est qu'on a ajout� nous m�me la racine. On doit
              donc l'exploser }
            if lsRoot <> ''
            then begin
                ListDirecoryRoot := TStringList.Create ;

                Explode(lsRoot, ListDirecoryRoot, OsAddFinalDirSeparator('')) ;

                for liIndexCounter := 0 to ListDirecoryRoot.Count - 1 do
                begin
                    ListDirectory.Insert(liIndexCounter, ListDirecoryRoot[liIndexCounter]);
                end ;

                FreeAndNil(ListDirecoryRoot) ;
            end ;

            { Supprime tout les . }
            repeat
                liIndex := ListDirectory.IndexOf('.') ;

                if liIndex <> - 1
                then begin
                    ListDirectory.Delete(liIndex) ;
                end ;
            until liIndex = -1 ;
        end ;

        repeat
            liIndex := ListDirectory.IndexOf('..') ;

            if liIndex <> - 1
            then begin
                if liIndex <> 0
                then begin
                     ListDirectory.Delete(liIndex - 1) ;
                     Dec(liIndex) ;
                end ;

                if liIndex <> -1
                then begin
                    ListDirectory.Delete(liIndex) ;
                end ;
            end ;
        until liIndex = -1 ;

        if not OsIsRootDirectory(asFileName)
        then begin
            Result := '' ;
        end
        else begin
            Result := OsRootDirectory ;
        end ;

        for liIndexCounter := 0 to ListDirectory.Count - 1 do
        begin
            Result := Result + ListDirectory[liIndexCounter] ;

            if liIndexCounter < ListDirectory.Count - 1
            then begin
                Result := OsAddFinalDirSeparator(Result) ;
            end ;
        end ;

        FreeAndNil(ListDirectory) ;
    end ;
end ;