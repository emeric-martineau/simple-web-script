unit DoubleStrings;
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
 * Class to manage label. It's just 2 TStringList management.
 ******************************************************************************}
{$I config.inc}

interface

uses SysUtils, Classes ;

type
  TDoubleStrings = class
  private
      VarName : TStringList ;
      VarValue: TStringList ;
  protected
  public
      constructor Create ;
      destructor Free ;
      procedure Add(NameOfVar : string; ValueOfVar : string) ;
      function Give(NameOfVar : string) : string;
      function GiveVarNameByIndex(Index : Integer) : string ;
      procedure Delete(NameOfVar : String) ;
      function Count : integer ;
      procedure Clear ;
      function isSet(NameOfVar : string) : boolean ;
  end ;

implementation

{******************************************************************************
 * Consructeur
 ******************************************************************************}
constructor TDoubleStrings.Create ;
begin
    inherited Create();

    { Créer l'objet FileName }
    VarName := TStringList.Create ;
    VarValue := TStringList.Create ;
end ;

{******************************************************************************
 * Destructeur
 ******************************************************************************}
destructor TDoubleStrings.Free ;
begin
    VarName.Free ;
    VarValue.Free ;
end ;

{******************************************************************************
 * Ajouter une variable
 ******************************************************************************}
procedure TDoubleStrings.Add(NameOfVar : string; ValueOfVar : string) ;
var index : Integer ;
begin
    NameOfVar := LowerCase(NameOfVar) ;

    index := VarName.IndexOf(NameOfVar) ;

    if index = -1
    then begin
        VarName.Add(NameOfVar) ;
        VarValue.Add(ValueOfVar) ;
    end
    else
        VarValue[index] := ValueOfVar ;
end ;

{******************************************************************************
 * Supprimer l'entrée correspondant dans le tableau.
 ******************************************************************************}
procedure TDoubleStrings.Delete(NameOfVar : String) ;
Var Index : Integer ;
begin
    Index := VarName.IndexOf(NameOfVar) ;

    if (Index <> -1)
    then begin
        VarName.Delete(Index) ;
        VarValue.Delete(Index) ;
    end ;
end;

{******************************************************************************
 * Donne le nombre de fichiers récents
 ******************************************************************************}
function TDoubleStrings.Count : Integer ;
begin
    Result := VarName.Count ;
end ;

{******************************************************************************
 * Donne la fichier correspondant à l'index.
 ******************************************************************************}
function TDoubleStrings.Give(NameOfVar : string) : string ;
Var Index : Integer ;
begin
    Index := VarName.IndexOf(NameOfVar) ;

    if Index <> -1
    then
        Result := VarValue[Index]
    else
        Result := ''
end ;

{******************************************************************************
 * Indique si la variable existe
 ******************************************************************************}
function TDoubleStrings.isSet(NameOfVar : string) : boolean ;
Var Index : Integer ;
begin
    Index := VarName.IndexOf(NameOfVar) ;

    if Index <> -1
    then
        Result := True
    else
        Result := False ;
end ;

procedure TDoubleStrings.Clear ;
begin
    VarValue.Clear ;
    VarName.Clear ;
end ;

{*******************************************************************************
 * Retourne le nom de la variable par l'index
 ******************************************************************************}
function TDoubleStrings.GiveVarNameByIndex(Index : Integer) : string ;
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
