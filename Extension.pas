unit Extension;
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
 * Class to manage label. It's just 2 TLiteStrings management.
 ******************************************************************************}
{$I config.inc}

interface

uses SysUtils, Classes;

type
  TProcExt = function (Commande : PChar; Parameters : PChar; scriptname : PChar; versionofsws : PChar; line : Integer; GlobalError : PBoolean) : boolean ; stdcall;
  TProcResult = function(Resultat : Pointer) : Integer ; stdcall;
  TProcInit = procedure(DocRoot : PChar; TmpDir : PChar; SafeMode : Boolean) ; stdcall ;

  TExtension = class
  private
      Extension : array of TProcExt ;
      ExtensionGetResult : array of TProcResult ;
      HandleExt : array of Integer ;
      NameOfExtension : TStringList ;
  protected
  public
      constructor Create ;
      destructor Free ;
      procedure Add(NameOfExt : String; HandleOfExt : Integer; proc : TProcExt; procresult : TProcResult) ;
      procedure Give(NameOfExt : String; var HandleOfExt : Integer; var proc : TProcExt) ;
      function GiveProcByIndex(Index : Integer) : TProcExt ;
      procedure DeleteByIndex(index : Integer) ;
      procedure DeleteByName(NameOfExt : String) ;
      function  Count : integer ;
      procedure Clear ;
      function  GiveNameByIndex(Index : Integer) : String ;
      function GetResult(Index : Integer) : String ;
      function isExists(NameOfExt : String) : boolean ;
  end ;

Var ListOfExtension : TExtension ;

implementation

{******************************************************************************
 * Consructeur
 ******************************************************************************}
constructor TExtension.Create ;
begin
    inherited Create();
    NameOfExtension := TStringList.Create ;
end ;

{******************************************************************************
 * Destructeur
 ******************************************************************************}
destructor TExtension.Free ;
begin
    Clear ;
    NameOfExtension.Free ;
end ;

{******************************************************************************
 * Ajouter une variable
 ******************************************************************************}
procedure TExtension.Add(NameOfExt : String; HandleOfExt : Integer; proc : TProcExt; procresult : TProcResult) ;
var nb : Integer ;
begin
    NameOfExtension.Add(NameOfExt) ;

    nb := NameOfExtension.Count ;

    SetLength(Extension, nb) ;
    SetLength(HandleExt, nb) ;
    SetLength(ExtensionGetResult, nb) ;

    Extension[nb-1] := proc ;
    HandleExt[nb-1] := HandleOfExt ;
    ExtensionGetResult[nb-1] := procresult ;
end ;

{******************************************************************************
 * Supprimer l'entrée correspondant dans le tableau.
 ******************************************************************************}
procedure TExtension.DeleteByName(NameOfExt : String) ;
Var
    index : Integer ;
begin
    Index := NameOfExtension.IndexOf(NameOfExt) ;

    if (Index > -1)
    then begin
        DeleteByIndex(Index) ; 
    end ;
end;

{******************************************************************************
 * Supprimer l'entrée correspondant dans le tableau.
 ******************************************************************************}
procedure TExtension.DeleteByIndex(Index : Integer) ;
Var i : Integer ;
    nb : Integer ;
begin
    if (Index > -1)
    then begin
        nb := NameOfExtension.Count ;

        for i := Index to nb - 1 do
        begin
            Extension[i] := Extension[i + 1] ;
            HandleExt[i] := HandleExt[i + 1] ;
            ExtensionGetResult[i] := ExtensionGetResult[i + 1] ;
        end ;

        Dec(nb) ;

        SetLength(Extension, nb) ;
        SetLength(HandleExt, nb) ;
        SetLength(ExtensionGetResult, nb) ;

        NameOfExtension.Delete(Index);
    end ;
end;
{******************************************************************************
 * Donne le nombre de fichiers récents
 ******************************************************************************}
function TExtension.Count : Integer ;
begin
     result := NameOfExtension.count ;
end ;

{******************************************************************************
 * Donne la fichier correspondant à l'index.
 ******************************************************************************}
procedure TExtension.Give(NameOfExt : String; var HandleOfExt : Integer; var proc : TProcExt) ;
Var Index : Integer ;
begin
    Index := NameOfExtension.IndexOf(NameOfExt) ;

    if Index > -1
    then begin
        proc := Extension[Index] ;
        HandleOfExt := HandleExt[Index] ;
    end
    else begin
        proc := nil ;
        HandleOfExt := -1;
    end ;
end ;

{******************************************************************************
 * Donne la fichier correspondant à l'index.
 ******************************************************************************}
function TExtension.GiveNameByIndex(Index : Integer) : String ;
begin
    Result := '' ;
    
    if (Index > -1) and (Index < NameOfExtension.Count - 1)
    then begin
        Result := NameOfExtension[Index] ;
    end
end ;

{******************************************************************************
 * Donne la procédure par rapport à l'index.
 ******************************************************************************}
function TExtension.GiveProcByIndex(Index : Integer) : TProcExt ;
begin
    if Index > -1
    then begin
        Result := Extension[Index] ;
    end
    else begin
        Result := nil ;
    end ;
end ;

{*******************************************************************************
 * Efface la liste
 ******************************************************************************}
procedure TExtension.Clear ;
begin
    SetLength(Extension, 0) ;
    SetLength(HandleExt, 0) ;
    SetLength(ExtensionGetResult, 0) ;

    NameOfExtension.Clear ;
end ;

{*******************************************************************************
 * Récupère la valeur de retour
 ******************************************************************************}
function TExtension.GetResult(Index : Integer) : String ;
var procresult : TProcResult ;
    len : Integer ;
begin
    { Prend le pointeur su la fonction GetResult }
    procresult := ExtensionGetResult[index] ;

    { Appel à GetResult }
    len := procresult(nil) ;

    if len > 0
    then begin
        SetLength(Result, len) ;

        procresult(Pchar(Result)) ;
    end ;
end ;

function TExtension.isExists(NameOfExt : String) : boolean ;
var index : Integer ;
begin
     index := NameOfExtension.IndexOf(NameOfExt) ;

     if Index > -1
     then
         Result := True
     else
         Result := False ;
end ;

end.
