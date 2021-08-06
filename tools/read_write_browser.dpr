program read_write_browser;

{$APPTYPE CONSOLE}

uses
  SysUtils;
  
var essai : char ;
    count : Integer ;
    F : File ;
begin
    writeln('content-type: text/plain') ;
    writeln('') ;

    FileMode := fmOpenRead ;
    AssignFile(F, '') ;
    Reset(F, 1) ;

    try
        BlockRead(F, essai, 1, count);

        while count = 1 do
        begin
            if (essai = #13)
            then
                write('[13]')
            else if (essai = #10)
            then
                write('[10]') ;

            write(essai) ; //BlockWrite(F, essai, 1) ;
            BlockRead(F, essai, 1, count);
        end ;
    except
       on EInOutError do ;
    end ;

    CloseFile(F) ;
end.
