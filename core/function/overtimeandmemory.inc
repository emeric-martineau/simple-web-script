{*****************************************************************************
 * OverTimeAndMemory
 * MARTINEAU Emeric
 *
 * Vérifie que le temps n'est pas écoulé
 ****************************************************************************}
procedure OverTimeAndMemory ;
begin
    {$IFNDEF COMMANDLINE}
    if SecondSpan(goStartTime, Now) > giElapseTime
    then begin
        ErrorMsg(csTimeIsEnd) ;
    end ;
    
    if OSUsageMemory > (giMaxMemorySize)
    then begin
        ErrorMsg(csMemoryLimit) ;
    end ;
    {$ENDIF}
end ;