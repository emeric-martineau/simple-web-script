program read_write_browser;

{$APPTYPE CONSOLE}

uses
  SysUtils;

var 
    tabString : array of string ;
    Nb : Integer ;
    Index : Integer ;
begin
    Nb := 1 ;
    while not Eof do
    begin
        SetLength(tabString, Nb) ;
        readln(tabString[Nb - 1]) ;
        Inc(Nb) ;
    end ;


    writeln('content-type: text/plain') ;
    writeln('') ;
    writeln('Nombre de ligne : ' + IntToStr(Nb)) ;
    writeln('------------------') ;        

    for Index := Low(tabString) to High(tabString) do
    begin
        writeln(Format('[%d]', [Index]) + tabString[Index]) ;
    end ;
end.
 