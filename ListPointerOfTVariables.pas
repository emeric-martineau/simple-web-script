unit ListPointerOfTVariables;
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
 * Class to make link between pointer of tvariable and pointer in script
 ******************************************************************************}

interface

{$I config.inc}

uses Classes, SysUtils, Variable ;

type
  TPointerOfTVariable = class
  private
      VarName : TStringList ;
      Line: array of TVariables ;
  protected
  public
      constructor Create ;
      destructor Free ;
      procedure Add(NameOfVar : string; ValueOfVar : TVariables) ;
      function Give(NameOfVar : string) : TVariables;
      function GiveVarNameByIndex(Index : Integer) : string ;
      procedure Delete(NameOfVar : String) ;
      function Count : integer ;
      procedure Clear ;
      function isSet(NameOfVar : string) : boolean ;
  end ;

Var PointerOFVariables : TPointerOfTVariable ;
    
implementation

{******************************************************************************
 * Consructeur
 ******************************************************************************}
constructor TPointerOfTVariable.Create ;
begin
    inherited Create();

    { Créer l'objet FileName }
    VarName := TStringList.Create ;
end ;

{******************************************************************************
 * Destructeur
 ******************************************************************************}
destructor TPointerOfTVariable.Free ;
begin
    VarName.Free ;
    SetLength(Line, 0) ;
end ;

{******************************************************************************
 * Ajouter une variable
 ******************************************************************************}
procedure TPointerOfTVariable.Add(NameOfVar : string; ValueOfVar : TVariables) ;
var nb : Integer ;
begin
    VarName.Add(LowerCase(NameOfVar)) ;

    nb := VarName.Count ;

    SetLength(Line, nb) ;
    Line[nb - 1] := ValueOfVar ;
end ;

{******************************************************************************
 * Supprimer l'entrée correspondant dans le tableau.
 ******************************************************************************}
procedure TPointerOfTVariable.Delete(NameOfVar : String) ;
Var Index : Integer ;
    i : Integer ;
begin
    Index := VarName.IndexOf(NameOfVar) ;

    if (Index <> -1)
    then begin
        VarName.Delete(Index) ;

        for i := Index to VarName.Count - 1 do
        begin
            Line[i] := Line[i + 1] ;
        end ;

        SetLength(Line, VarName.Count) ;
    end ;
end;

{******************************************************************************
 * Donne le nombre de fichiers récents
 ******************************************************************************}
function TPointerOfTVariable.Count : Integer ;
begin
    Result := VarName.Count ;
end ;

{******************************************************************************
 * Donne la fichier correspondant à l'index.
 ******************************************************************************}
function TPointerOfTVariable.Give(NameOfVar : string) : TVariables ;
Var Index : Integer ;
begin
    Index := VarName.IndexOf(NameOfVar) ;

    if Index <> -1
    then
        Result := Line[Index]
    else
        Result := nil ;
end ;

{******************************************************************************
 * Indique si la variable existe
 ******************************************************************************}
function TPointerOfTVariable.isSet(NameOfVar : string) : boolean ;
Var Index : Integer ;
begin
    Index := VarName.IndexOf(NameOfVar) ;

    if Index <> -1
    then
        Result := True
    else
        Result := False ;
end ;

procedure TPointerOfTVariable.Clear ;
begin
    VarName.Clear ;
    SetLength(Line, 0) ;
end ;

{*******************************************************************************
 * Retourne le nom de la variable par l'index
 ******************************************************************************}
function TPointerOfTVariable.GiveVarNameByIndex(Index : Integer) : string ;
begin
    Result := '' ;

    if Index <> -1
    then begin
        if Index < VarName.Count
        then begin
            Result := VarName[Index] ;
        end
    end
end ;

end.
