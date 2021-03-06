{*****************************************************************************
 * OverTimeAndMemory
 * MARTINEAU Emeric
 *
 * V�rifie que le temps n'est pas �coul�
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