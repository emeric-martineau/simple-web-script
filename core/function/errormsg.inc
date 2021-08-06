{*****************************************************************************
 * ErrorMsg
 * MARTINEAU Emeric
 *
 * Affiche une erreur et inquique au programme qu'il y a une erreur
 *
 * Paramètres d'entrée :
 *   - asText : texte à traiter
 *
 *****************************************************************************}
procedure ErrorMsg(asText : string) ;
begin
    if (not gbIsHeaderSend)
    then begin
        SendHeader ;
    end ;

    { Evite d'afficher un message d'erreur s'il y a déjà un message d'erreur
      d'affiché }
    if not gbNoError and not gbError
    then begin
        if goLineToFile.count > 0
        then begin
            //OutPutString(sErrorIn + ListOfFile[MyStrToInt(LineToFile[CurrentLineNumber])], false)
            WriteLn(csErrorIn + goListOfFile[goLineToFile[giCurrentLineNumber]]) ;
        end
        else begin
            //OutPutString(sGeneralError + text, false) ;
            WriteLn(csGeneralError + asText) ;
        end ;

        if (goCurrentFunctionName.Count > 0) and (goLineToFileLine.Count >0)
        then begin
            //OutPutString(AddSlashes(Format(' [%s:%s] %s', [CurrentFunctionName[CurrentFunctionName.Count - 1], LineToFileLine[CurrentLineNumber], text])) + '\n', true) ;
            WriteLn(Format(' [%s:%s] %s', [goCurrentFunctionName[goCurrentFunctionName.Count - 1], goLineToFileLine[giCurrentLineNumber], asText])) ;
        end ;

        gbError := True ;
        gbQuit := True ;
    end ;
end ;