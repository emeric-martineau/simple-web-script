unit UserFunction;
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
 * Class to register line of user function & label
 ******************************************************************************}

interface

{$I config.inc}

uses Classes, SysUtils ;

type
  TUserFunction = class
  private
      FunctionName : TStringList ;
      Arguments : TStringList ;
      Line: array of Integer ;
      LineToEnd : array of Integer ;
  protected
  public
      constructor Create ;
      destructor Free ;
      procedure Add(NameOfVar : string; ValueOfVar : integer; EndPos : Integer; ArgumentsList : String) ;
      function Give(NameOfVar : string) : integer;
      function GiveEnd(NameOfVar : string) : integer ;
      function GiveFunctionNameByIndex(Index : Integer) : string ;
      procedure Delete(NameOfVar : String) ;
      function Count : integer ;
      procedure Clear ;
      function isSet(NameOfVar : string) : boolean ;
      function rename(OldName, NewName : String) : boolean ;
      function GiveArguments(NameOfVar : string) : string ;            
  end ;

Var ListProcedure : TUserFunction ;
    
implementation

{******************************************************************************
 * Consructeur
 ******************************************************************************}
constructor TUserFunction.Create ;
begin
    inherited Create();

    { Créer l'objet FileName }
    FunctionName := TStringList.Create ;
    Arguments := TStringList.Create ;
end ;

{******************************************************************************
 * Destructeur
 ******************************************************************************}
destructor TUserFunction.Free ;
begin
    FunctionName.Free ;
    Arguments.Free ;
    SetLength(Line, 0) ;
end ;

{******************************************************************************
 * Ajouter une variable
 ******************************************************************************}
procedure TUserFunction.Add(NameOfVar : string; ValueOfVar : integer; EndPos : Integer; ArgumentsList : String) ;
var nb : Integer ;
begin
    FunctionName.Add(LowerCase(NameOfVar)) ;
    Arguments.Add(ArgumentsList) ;
    
    nb := FunctionName.Count ;

    SetLength(Line, nb) ;
    SetLength(LineToEnd, nb) ;    
    Line[nb - 1] := ValueOfVar ;
    LineToEnd[nb - 1] := EndPos ;
end ;

{******************************************************************************
 * Supprimer l'entrée correspondant dans le tableau.
 ******************************************************************************}
procedure TUserFunction.Delete(NameOfVar : String) ;
Var Index : Integer ;
    i : Integer ;
begin
    Index := FunctionName.IndexOf(LowerCase(NameOfVar)) ;

    if (Index <> -1)
    then begin
        FunctionName.Delete(Index) ;

        for i := Index to FunctionName.Count - 1 do
        begin
            Line[i] := Line[i + 1] ;
            LineToEnd[i] := LineToEnd[i + 1] ;
        end ;

        SetLength(Line, FunctionName.Count) ;
        SetLength(LineToEnd, FunctionName.Count) ;        
    end ;
end;

{******************************************************************************
 * Donne le nombre de fichiers récents
 ******************************************************************************}
function TUserFunction.Count : Integer ;
begin
    Result := FunctionName.Count ;
end ;

{******************************************************************************
 * Donne la fichier correspondant à l'index.
 ******************************************************************************}
function TUserFunction.Give(NameOfVar : string) : integer ;
Var Index : Integer ;
begin
    Index := FunctionName.IndexOf(LowerCase(NameOfVar)) ;

    if Index <> -1
    then
        Result := Line[Index]
    else
        Result := -1 ;
end ;

{******************************************************************************
 * Donne la fichier correspondant à l'index.
 ******************************************************************************}
function TUserFunction.GiveEnd(NameOfVar : string) : integer ;
Var Index : Integer ;
begin
    Index := FunctionName.IndexOf(LowerCase(NameOfVar)) ;

    if Index <> -1
    then
        Result := LineToEnd[Index]
    else
        Result := -1 ;
end ;

{******************************************************************************
 * Indique si la variable existe
 ******************************************************************************}
function TUserFunction.isSet(NameOfVar : string) : boolean ;
Var Index : Integer ;
begin
    Index := FunctionName.IndexOf(LowerCase(NameOfVar)) ;

    if Index <> -1
    then
        Result := True
    else
        Result := False ;
end ;

procedure TUserFunction.Clear ;
begin
    FunctionName.Clear ;
    SetLength(Line, 0) ;
end ;

{*******************************************************************************
 * Retourne le nom de la variable par l'index
 ******************************************************************************}
function TUserFunction.GiveFunctionNameByIndex(Index : Integer) : string ;
begin
    Result := '' ;

    if Index <> -1
    then begin
        if Index < FunctionName.Count
        then begin
            Result := FunctionName[Index] ;
        end
    end
end ;

{******************************************************************************
 * Renomme la fonction OldName par NewName
 ******************************************************************************}
function TUserFunction.rename(OldName, NewName : String) : boolean ;
var Index : Integer ;
begin
    Index := FunctionName.IndexOf(LowerCase(OldName)) ;

    if Index <> -1
    then begin
        FunctionName[Index] := LowerCase(NewName) ;
        Result := True ;
    end
    else
        Result := False ;
end ;

{******************************************************************************
 * Donne les arguments correspondant à l'index.
 ******************************************************************************}
function TUserFunction.GiveArguments(NameOfVar : string) : string ;
Var Index : Integer ;
begin
    Index := FunctionName.IndexOf(LowerCase(NameOfVar)) ;

    if Index <> -1
    then
        Result := Arguments[Index]
    else
        Result := '' ;
end ;

end.
