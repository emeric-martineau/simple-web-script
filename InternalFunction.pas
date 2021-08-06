unit InternalFunction;
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
 * Class to register pointer of function
 ******************************************************************************}

interface

{$I config.inc}

uses SysUtils, Classes ;

type
  ModelProcedure = procedure (arguments : TStringList) ;

  TInternalFunction = class
  private
      VarName : TStringList ;
      Line: array of ModelProcedure ;
      Parse : array of boolean ;
  protected
  public
      constructor Create ;
      destructor Free ;
      procedure Add(NameOfVar : string; ValueOfVar : ModelProcedure; Parsed : boolean) ;
      procedure Change(NameOfVar : string; ValueOfVar : ModelProcedure; Parsed : boolean) ;
      function Give(NameOfVar : string) : ModelProcedure;
      function GiveVarNameByIndex(Index : Integer) : string ;
      procedure Delete(NameOfVar : String) ;
      function Count : integer ;
      procedure Clear ;
      function isSet(NameOfVar : string) : boolean ;
      function isParse(FunctionName : String) : boolean ;
      function rename(OldName, NewName : String) : boolean ;
  end ;

Var ListFunction : TInternalFunction ;
    
implementation

{******************************************************************************
 * Consructeur
 ******************************************************************************}
constructor TInternalFunction.Create ;
begin
    inherited Create();

    { Créer l'objet FileName }
    VarName := TStringList.Create ;
end ;

{******************************************************************************
 * Destructeur
 ******************************************************************************}
destructor TInternalFunction.Free ;
begin
    VarName.Free ;
    SetLength(Line, 0) ;
end ;

{******************************************************************************
 * Ajouter une variable
 ******************************************************************************}
procedure TInternalFunction.Add(NameOfVar : string; ValueOfVar : ModelProcedure; Parsed : boolean) ;
var nb : Integer ;
begin
    VarName.Add(LowerCase(NameOfVar)) ;

    nb := VarName.Count ;

    SetLength(Line, nb) ;
    Line[nb - 1] := ValueOfVar ;

    SetLength(Parse, nb) ;
    Parse[nb - 1] := Parsed ;
end ;

{******************************************************************************
 * Supprimer l'entrée correspondant dans le tableau.
 ******************************************************************************}
procedure TInternalFunction.Delete(NameOfVar : String) ;
Var Index : Integer ;
    i : Integer ;
begin
    Index := VarName.IndexOf(LowerCase(NameOfVar)) ;

    if (Index <> -1)
    then begin
        VarName.Delete(Index) ;

        for i := Index to VarName.Count - 1 do
        begin
            Line[i] := Line[i + 1] ;
            Parse[i] := Parse[i + 1] ;
        end ;

        SetLength(Line, VarName.Count) ;
        SetLength(Parse, VarName.Count) ;
    end ;
end;

{******************************************************************************
 * Donne le nombre de fichiers récents
 ******************************************************************************}
function TInternalFunction.Count : Integer ;
begin
    Result := VarName.Count ;
end ;

{******************************************************************************
 * Donne la fichier correspondant à l'index.
 ******************************************************************************}
function TInternalFunction.Give(NameOfVar : string) : ModelProcedure ;
Var Index : Integer ;
begin
    Index := VarName.IndexOf(LowerCase(NameOfVar)) ;

    if Index <> -1
    then
        Result := Line[Index]
    else
        Result := nil ;
end ;

{******************************************************************************
 * Indique si la variable existe
 ******************************************************************************}
function TInternalFunction.isSet(NameOfVar : string) : boolean ;
Var Index : Integer ;
begin
    Index := VarName.IndexOf(LowerCase(NameOfVar)) ;

    if Index <> -1
    then
        Result := True
    else
        Result := False ;
end ;

procedure TInternalFunction.Clear ;
begin
    VarName.Clear ;
    SetLength(Line, 0) ;
end ;

{*******************************************************************************
 * Retourne le nom de la variable par l'index
 ******************************************************************************}
function TInternalFunction.GiveVarNameByIndex(Index : Integer) : string ;
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

{******************************************************************************
 * Indique s'il faut parser les arguments (convertir $var en valeur)
 ******************************************************************************}
function TInternalFunction.isParse(FunctionName : String) : boolean ;
var Index : Integer ;
begin
    Index := VarName.IndexOf(LowerCase(FunctionName)) ;

    if Index <> -1
    then
        Result := Parse[Index]
    else
        Result := False ;
end ;

{******************************************************************************
 * Renomme la fonction OldName par NewName
 ******************************************************************************}
function TInternalFunction.rename(OldName, NewName : String) : boolean ;
var Index : Integer ;
begin
    Index := VarName.IndexOf(LowerCase(OldName)) ;

    if Index <> -1
    then begin
        VarName[Index] := LowerCase(NewName) ;
        Result := True ;
    end
    else
        Result := False ;
end ;

{******************************************************************************
 * Ajouter une variable
 ******************************************************************************}
procedure TInternalFunction.Change(NameOfVar : string; ValueOfVar : ModelProcedure; Parsed : boolean) ;
var Index : Integer ;
begin
    Index := VarName.IndexOf(LowerCase(NameOfVar)) ;

    if Index <> -1
    then begin
        Line[Index] := ValueOfVar ;
        Parse[Index] := Parsed ;
    end ;
end ;

end.
