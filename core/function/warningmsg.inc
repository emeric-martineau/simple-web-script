{*****************************************************************************
 * WarningMsg
 * MARTINEAU Emeric
 *
 * Affiche une alerte
 *
 * Paramètres d'entrée :
 *   - asText : texte à afficher
 *
 *****************************************************************************}
procedure WarningMsg(asText : string) ;
begin
    if (not gbIsHeaderSend)
    then begin
        SendHeader ;
    end ;
    
    if gbWarning
    then begin
        //OutPutString(sWarningIn + ListOfFile[MyStrToInt(LineToFile[CurrentLineNumber])], false) ;
        WriteLn(csWarningIn + goListOfFile[goLineToFile[giCurrentLineNumber]]) ;

        //OutPutString(Format(' [%s:%s] %s', [CurrentFunctionName[CurrentFunctionName.Count - 1],LineToFileLine[CurrentLineNumber], text]) + '\n', true) ;
        WriteLn(Format(' [%s:%s] %s', [goCurrentFunctionName[goCurrentFunctionName.Count - 1], goLineToFileLine[giCurrentLineNumber], asText])) ;
    end ;
end ;