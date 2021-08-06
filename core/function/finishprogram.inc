{*****************************************************************************
 * FinishProgram
 * MARTINEAU Emeric
 *
 * Effectue les tâches avant l'arrêt du programme
 *
 *****************************************************************************}
procedure FinishProgram ;
var i : Integer ;
begin
    FreeAndNil(goCodeList) ;

    FreeAndNil(goVariables);
    
    FreeAndNil(goListProcedure) ;
    
    FreeAndNil(goListOfFile) ;
    
    FreeAndNil(goLineToFileLine) ;
    
    FreeAndNil(goLineToFile) ;
    
    FreeAndNil(goInternalFunction) ;
    
    FreeAndNil(goPointerOFVariables) ;
    
    FreeAndNil(goCurrentFunctionName) ;
    
    FreeAndNil(goVarGetPostCookieFileData) ;
    
    FreeAndNil(Header) ;
    
    FreeAndNil(goCurrentRootOfFile) ;
    
    if Assigned(goListOfExtension)
    then begin
        for i := 0 to goListOfExtension.Count - 1 do
        begin
            OsUnLoadExtension(goListOfExtension.GiveNameByIndex(i)) ;
        end ;
    end ;

    FreeAndNil(goListOfExtension) ;

    FreeAndNil(goConstantes) ;
end ;