unit UserLabel;
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
  TUserLabel = class
  private
      LabelName : TStringList ;
      Line: array of Integer ;
  protected
  public
      constructor Create ;
      destructor Free ;
      procedure Add(NameOfVar : string; ValueOfVar : integer) ;
      function Give(NameOfVar : string) : integer;
      function GiveLabelNameByIndex(Index : Integer) : string ;
      procedure Delete(NameOfVar : String) ;
      function Count : integer ;
      procedure Clear ;
      function isSet(NameOfVar : string) : boolean ;
      function rename(OldName, NewName : String) : boolean ;      
  end ;

Var ListLabel : TUserLabel ;
    
implementation

{******************************************************************************
 * Consructeur
 ******************************************************************************}
constructor TUserLabel.Create ;
begin
    inherited Create();

    { Créer l'objet FileName }
    LabelName := TStringList.Create ;
end ;

{******************************************************************************
 * Destructeur
 ******************************************************************************}
destructor TUserLabel.Free ;
begin
    LabelName.Free ;
    SetLength(Line, 0) ;
end ;

{******************************************************************************
 * Ajouter une variable
 ******************************************************************************}
procedure TUserLabel.Add(NameOfVar : string; ValueOfVar : integer) ;
var nb : Integer ;
begin
    LabelName.Add(LowerCase(NameOfVar)) ;

    nb := LabelName.Count ;

    SetLength(Line, nb) ;
    Line[nb - 1] := ValueOfVar ;
end ;

{******************************************************************************
 * Supprimer l'entrée correspondant dans le tableau.
 ******************************************************************************}
procedure TUserLabel.Delete(NameOfVar : String) ;
Var Index : Integer ;
    i : Integer ;
begin
    Index := LabelName.IndexOf(LowerCase(NameOfVar)) ;

    if (Index <> -1)
    then begin
        LabelName.Delete(Index) ;

        for i := Index to LabelName.Count - 1 do
        begin
            Line[i] := Line[i + 1] ;
        end ;

        SetLength(Line, LabelName.Count) ;
    end ;
end;

{******************************************************************************
 * Donne le nombre de fichiers récents
 ******************************************************************************}
function TUserLabel.Count : Integer ;
begin
    Result := LabelName.Count ;
end ;

{******************************************************************************
 * Donne la fichier correspondant à l'index.
 ******************************************************************************}
function TUserLabel.Give(NameOfVar : string) : integer ;
Var Index : Integer ;
begin
    Index := LabelName.IndexOf(LowerCase(NameOfVar)) ;

    if Index <> -1
    then
        Result := Line[Index]
    else
        Result := -1 ;
end ;

{******************************************************************************
 * Indique si la variable existe
 ******************************************************************************}
function TUserLabel.isSet(NameOfVar : string) : boolean ;
Var Index : Integer ;
begin
    Index := LabelName.IndexOf(LowerCase(NameOfVar)) ;

    if Index <> -1
    then
        Result := True
    else
        Result := False ;
end ;

procedure TUserLabel.Clear ;
begin
    LabelName.Clear ;
    SetLength(Line, 0) ;
end ;

{*******************************************************************************
 * Retourne le nom de la variable par l'index
 ******************************************************************************}
function TUserLabel.GiveLabelNameByIndex(Index : Integer) : string ;
begin
    Result := '' ;

    if Index <> -1
    then begin
        if Index < LabelName.Count
        then begin
            Result := LabelName[Index] ;
        end
    end
end ;

{******************************************************************************
 * Renomme la fonction OldName par NewName
 ******************************************************************************}
function TUserLabel.rename(OldName, NewName : String) : boolean ;
var Index : Integer ;
begin
    Index := LabelName.IndexOf(LowerCase(OldName)) ;

    if Index <> -1
    then begin
        LabelName[Index] := LowerCase(NewName) ;
        Result := True ;
    end
    else
        Result := False ;
end ;

end.
