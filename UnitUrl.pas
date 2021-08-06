unit UnitUrl;
{*******************************************************************************
 * Copyright (C) 2007 MARTINEAU Emeric (php4php@free.fr)
 *
 * Simple Web Script
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation; either version 2 of the License, or (at your option) any later
 * version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
 * Place, Suite 330, Boston, MA 02111-1307 USA
 *
 *******************************************************************************
 * This unit containt string function :
 *   URLDECODE
 *   URLENCODE
 ******************************************************************************}
interface

{$I config.inc}

uses Classes, Functions, UnitMessages, InternalFunction ;

procedure UrlFunctionsInit ;
procedure urlDecodeCommande(arguments : TStringList) ;
procedure urlEncodeCommande(arguments : TStringList) ;

implementation

uses Code, SysUtils ;


procedure urlDecodeCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := UrlDecode(arguments[0]) ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 1
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure urlEncodeCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := UrlEncode(arguments[0]) ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 1
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;



procedure UrlFunctionsInit ;
begin
    ListFunction.Add('urldecode', @urlDecodeCommande, true) ;
    ListFunction.Add('urlencode', @urlEncodeCommande, true) ;
end ;

end.
