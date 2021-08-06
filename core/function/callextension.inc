{*****************************************************************************
 * CallExtension
 * MARTINEAU Emeric
 *
 * Appele la fonction dans une extension
 *
 * Paramètres d'entrée :
 *   - asCommand : nom de la fonction,
 *   - aoArguments : liste des arguments
 *
 * Retour : true si commande exécutée
 *****************************************************************************}
function CallExtension(asCommande : String; aoArguments : TStringList) : Boolean ;
var
    { Compteur de boucle des extensions }
    liIndexOfExt : Integer ;
    { Procedure Execute }
    lProc : TProcExt ;
    { Arguments }
    lArgs : PChar ;
    { Nom du script }
    lScriptName : PChar ;
    { Version du moteur }
    lVersion : PChar ;
    { Commande a exécuter }
    lCommande : PChar ;
begin
    Result := False ;

    {$IFDEF FPC}
    // Supprime les warnings de Free Pascal Compiler
    lScriptName := nil ;
    lVersion := nil ;
    lCommande := nil ;
    {$ENDIF}

    lArgs := nil ;

    { + 1 pour le \0 }
    GetMem(lScriptName, Length(goConstantes.Give('#_scriptname')) + 1) ;

    if lScriptName = nil
    then begin
        ErrorMsg(csCanInitialiseDataToCallExtension) ;
        exit ;
    end ;

    lScriptName[0] := #0 ;

    StrPCopy(lScriptName, goConstantes.Give('#_scriptname')) ;

    { + 1 pour le \0 }
    GetMem(lVersion, Length(csVersion) + 1) ;

    if lVersion = nil
    then begin
        ErrorMsg(csCanInitialiseDataToCallExtension) ;
        exit ;
    end ;

    lVersion[0] := #0 ;

    StrPCopy(lVersion, csVersion) ;

    { + 1 pour le \0 }
    GetMem(lCommande, Length(asCommande) + 1) ;

    if lCommande = nil
    then begin
        ErrorMsg(csCanInitialiseDataToCallExtension) ;
        exit ;
    end ;

    lCommande[0] := #0 ;

    StrPCopy(lCommande, asCommande) ;

    for liIndexOfExt := 0 to goListOfExtension.Count - 1 do
    begin
        lProc := goListOfExtension.GiveProcByIndex(liIndexOfExt) ;

        TStringListToPChar(aoArguments, lArgs) ;

        if lProc(lCommande, lArgs, lScriptName, lVersion, StrToInt(goConstantes.Give('#_line')), @gbQuit)
        then begin
            Result := True ;

            gsResultFunction := goListOfExtension.GetResult(liIndexOfExt) ;

            break ;
        end ;
    end ;
end ;