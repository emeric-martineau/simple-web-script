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

{$IFDEF FPC}
    {$mode objfpc}{$H+}
{$ENDIF}

uses Classes, Functions, UnitMessages, InternalFunction ;

procedure UrlFunctionsInit ;
procedure urlDecodeCommande(aoArguments : TStringList) ;
procedure urlEncodeCommande(aoArguments : TStringList) ;

implementation

uses Code, SysUtils ;


procedure urlDecodeCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := UrlDecode(aoArguments[0]) ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure urlEncodeCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := UrlEncode(aoArguments[0]) ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;



procedure UrlFunctionsInit ;
begin
    goInternalFunction.Add('urldecode', @urlDecodeCommande, true) ;
    goInternalFunction.Add('urlencode', @urlEncodeCommande, true) ;
end ;

end.
